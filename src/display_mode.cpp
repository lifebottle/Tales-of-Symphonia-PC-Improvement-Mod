#include "display_mode.h"
#include "logger.h"
#include "patch_runtime.h"

#include <asmjit/x86.h>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <mutex>
#include <stdexcept>

namespace DisplayMode {
namespace {
// These values are written to the game's settings file. Keep the original Off/On values.
enum class Mode : uint32_t { Windowed = 0, Exclusive = 1, Borderless = 2 };
constexpr Mode DecodeMode(int value) {
    return value == 2 ? Mode::Borderless : value > 0 ? Mode::Exclusive : Mode::Windowed;
}

constexpr bool IsWindowed(Mode mode) { return mode != Mode::Exclusive; }
constexpr Mode StepMode(Mode mode, int direction) {
    const int index = mode == Mode::Exclusive ? 0 : mode == Mode::Windowed ? 1 : 2;
    const int next = index + direction;
    return next <= 0 ? Mode::Exclusive : next >= 2 ? Mode::Borderless : Mode::Windowed;
}

static_assert(sizeof(void*) == 4, "TOS display hooks require x86");
constexpr uintptr_t imageBase = 0x400000;
constexpr UINT updateMessage = WM_APP + 1;
constexpr wchar_t dispatchClass[] = L"TOSImprovementMod.VSyncDispatch";

template <class T> T& Game(uintptr_t address) { return *reinterpret_cast<T*>(address); }
inline uint32_t& Selection() { return Game<uint32_t>(0x1D59FBC); }
inline D3DPRESENT_PARAMETERS& Parameters() { return Game<D3DPRESENT_PARAMETERS>(0xB29960); }
inline HWND GameWindow() { return Game<HWND>(0x1C3D060); }
inline IDirect3DDevice9* Device() { return Game<IDirect3DDevice9*>(0xB2999C); }
inline uint8_t& GameWindowed() { return Game<uint8_t>(0x8A9085); }
inline uint8_t& DeviceLost() { return Game<uint8_t>(0xB192BF); }

// Game calls take arguments in EAX/ESI/EDI followed by up to six stack arguments.
// The caller cleans the stack, so unused trailing arguments are safe.
#if defined(__GNUC__)
__attribute__((naked)) unsigned __cdecl CallGame(uintptr_t, uint32_t, uint32_t, uint32_t, int, int, int, int, int,
                                                 int) {
    __asm__("push %ebp; mov %esp,%ebp; push %esi; push %edi; push %ebx;"
            "push 44(%ebp); push 40(%ebp); push 36(%ebp); push 32(%ebp); push 28(%ebp); push 24(%ebp);"
            "mov 12(%ebp),%eax; mov 16(%ebp),%esi; mov 20(%ebp),%edi; call *8(%ebp);"
            "lea -12(%ebp),%esp; pop %ebx; pop %edi; pop %esi; leave; ret");
}
#else
__declspec(naked) unsigned __cdecl CallGame(uintptr_t, uint32_t, uint32_t, uint32_t, int, int, int, int, int, int) {
    __asm {
        push ebp
        mov ebp, esp
        push esi
        push edi
        push ebx
        push [ebp+44]
        push [ebp+40]
        push [ebp+36]
        push [ebp+32]
        push [ebp+28]
        push [ebp+24]
        mov eax, [ebp+12]
        mov esi, [ebp+16]
        mov edi, [ebp+20]
        call dword ptr [ebp+8]
        lea esp, [ebp-12]
        pop ebx
        pop edi
        pop esi
        leave
        ret
    }
}
#endif

void DrawText(const char* text, int x, int y, int color, int alpha, int width, int height) {
    CallGame(0x532250, reinterpret_cast<uintptr_t>(text), 0, 0, x, y, color, alpha, width, height);
}

void DrawResource(int id, int x, int y, int color, int alpha, int width, int height) {
    CallGame(0x538550, 0, id, 0, x, y, color, alpha, width, height);
}

unsigned ApplyNative(int width, int height, unsigned windowed, unsigned force) {
    return CallGame(0x5C9920, 0, height, width, windowed, force, 0, 0, 0, 0) & 0xFF;
}

using StyleFn = LONG(WINAPI*)(HWND, int, LONG);
using PositionFn = BOOL(WINAPI*)(HWND, HWND, int, int, int, int, UINT);
using ShowFn = BOOL(WINAPI*)(HWND, int);
StyleFn realStyle = nullptr;
PositionFn realPosition = nullptr;
ShowFn realShow = nullptr;
std::atomic<bool> enabled{false};
std::atomic<bool> transitioning{false};
std::atomic<Mode> currentMode{Mode::Windowed};
DWORD deviceThread = 0;
Presentation* presentation = nullptr;
HWND observedWindow = nullptr;
WNDPROC previousWindowProc = nullptr;
HRESULT lastReset = D3D_OK;
bool resetAttempted = false;
// Keep the ordinary window placement for the return from fullscreen.
WINDOWPLACEMENT normalPlacement{sizeof(WINDOWPLACEMENT)};
bool haveNormalPlacement = false;
LONG normalStyle = 0, normalExStyle = 0;

// A failed attempt must restore both the game settings and the actual window.
struct ModeChange {
    bool failed = false;
    bool rolledBack = false;
    bool restoring = false;
    Mode previous = Mode::Windowed, target = Mode::Windowed;
    D3DPRESENT_PARAMETERS parameters{};
    WINDOWPLACEMENT placement{sizeof(WINDOWPLACEMENT)};
    LONG style = 0, exStyle = 0;
    uint32_t resolution = 0, samples = 0, quality = 0;
} modeChange;

Mode ModeForWindow() { return transitioning ? modeChange.target : currentMode.load(); }
bool ClampMSAA(Mode mode) {
    Game<uint8_t>(0x1DB9AC0) = IsWindowed(mode);
    return reinterpret_cast<bool(__stdcall*)(void*)>(0x5CBC90)(reinterpret_cast<void*>(0x1DB9A88));
}

void SyncMode(Mode mode) {
    Selection() = static_cast<uint32_t>(mode);
    Game<uint32_t>(0x1D59FC0) = Selection();
    const auto state = Game<uintptr_t>(0xAD3F68);
    if (state) Game<uint32_t>(state + 0x19C) = Selection();
}

LONG WriteStyle(HWND window, int index, LONG style) {
    SetLastError(0);
    const LONG previous = realStyle(window, index, style);
    if (!previous && GetLastError() && transitioning && window == GameWindow()) modeChange.failed = true;
    return previous;
}

LONG WINAPI SetStyle(HWND window, int index, LONG style) {
    if (enabled && window == GameWindow() && index == GWL_STYLE) {
        if (ModeForWindow() == Mode::Borderless) {
            style = (style & ~WS_OVERLAPPEDWINDOW) | WS_POPUP;
            const LONG extended = GetWindowLongW(window, GWL_EXSTYLE);
            WriteStyle(window, GWL_EXSTYLE, extended & ~(WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE | WS_EX_DLGMODALFRAME));
        } else if (ModeForWindow() == Mode::Windowed) {
            style = haveNormalPlacement ? normalStyle : ((style & ~WS_POPUP) | WS_OVERLAPPEDWINDOW);
            if (haveNormalPlacement) WriteStyle(window, GWL_EXSTYLE, normalExStyle);
        }
        // Native mode code uses style constants without WS_VISIBLE, then calls
        // ShowWindow(SW_SHOW), which activates the window. Keep visibility here.
        constexpr LONG dynamic = WS_VISIBLE | WS_MINIMIZE | WS_MAXIMIZE;
        style = (style & ~dynamic) | (GetWindowLongW(window, GWL_STYLE) & dynamic);
    }
    return WriteStyle(window, index, style);
}

BOOL WINAPI Show(HWND window, int command) {
    if (enabled && transitioning && window == GameWindow() && IsWindowed(ModeForWindow()) && command == SW_SHOW)
        command = SW_SHOWNOACTIVATE;
    return realShow(window, command);
}

BOOL WINAPI SetPosition(HWND window, HWND after, int x, int y, int width, int height, UINT flags) {
    const Mode mode = ModeForWindow();
    if (enabled && window == GameWindow() && (mode == Mode::Borderless || (transitioning && mode == Mode::Windowed))) {
        if (mode == Mode::Borderless) {
            MONITORINFO monitor{sizeof(monitor)};
            if (!GetMonitorInfoW(MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST), &monitor)) {
                if (transitioning) modeChange.failed = true;
                return FALSE;
            }
            x = monitor.rcMonitor.left;
            y = monitor.rcMonitor.top;
            width = monitor.rcMonitor.right - x;
            height = monitor.rcMonitor.bottom - y;
        } else {
            RECT rect{0, 0, static_cast<LONG>(Parameters().BackBufferWidth),
                      static_cast<LONG>(Parameters().BackBufferHeight)};
            if (AdjustWindowRectEx(&rect, GetWindowLongW(window, GWL_STYLE), FALSE,
                                   GetWindowLongW(window, GWL_EXSTYLE))) {
                width = rect.right - rect.left;
                height = rect.bottom - rect.top;
            }
            if (haveNormalPlacement) {
                x = normalPlacement.rcNormalPosition.left;
                y = normalPlacement.rcNormalPosition.top;
                // WINDOWPLACEMENT uses workspace coordinates for ordinary windows.
                MONITORINFO monitor{sizeof(monitor)};
                if (GetMonitorInfoW(MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST), &monitor)) {
                    x += monitor.rcWork.left - monitor.rcMonitor.left;
                    y += monitor.rcWork.top - monitor.rcMonitor.top;
                    if (x >= monitor.rcWork.right || y >= monitor.rcWork.bottom || x + width <= monitor.rcWork.left ||
                        y + height <= monitor.rcWork.top) {
                        x = monitor.rcWork.left;
                        y = monitor.rcWork.top;
                    }
                }
            }
        }
        after = HWND_NOTOPMOST;
        flags = (flags & ~(SWP_NOMOVE | SWP_NOSIZE)) | SWP_FRAMECHANGED | SWP_NOACTIVATE;
        if (GetWindowLongW(window, GWL_EXSTYLE) & WS_EX_TOPMOST)
            flags &= ~SWP_NOZORDER;
        else
            flags |= SWP_NOZORDER;
    }
    const BOOL result = realPosition(window, after, x, y, width, height, flags);
    if (!result && transitioning && window == GameWindow()) modeChange.failed = true;
    return result;
}

bool ReadParameters(D3DPRESENT_PARAMETERS& value) {
    if (!Device()) return false;
    IDirect3DSwapChain9* chain = nullptr;
    if (FAILED(Device()->GetSwapChain(0, &chain))) return false;
    const HRESULT result = chain->GetPresentParameters(&value);
    chain->Release();
    return SUCCEEDED(result);
}

void RestoreGameState() {
    Parameters() = modeChange.parameters;
    GameWindowed() = IsWindowed(modeChange.previous);
    Game<uint32_t>(0xB2995C) = Game<uint32_t>(0xB29938) = Game<uint32_t>(0x1DB9A88) =
        modeChange.parameters.BackBufferWidth;
    Game<uint32_t>(0xB29958) = Game<uint32_t>(0xB29934) = Game<uint32_t>(0x1DB9A8C) =
        modeChange.parameters.BackBufferHeight;
    Game<uint32_t>(0x1D59FC4) = Game<uint32_t>(0x8C69C4) = modeChange.resolution;
    Game<uint32_t>(0x1DB9A90) = Game<uint32_t>(0x1D5A098) = modeChange.samples;
    Game<uint32_t>(0x1DB9A94) = Game<uint32_t>(0x1D5A09C) = modeChange.quality;
    Game<uint8_t>(0x1DB9AC0) = IsWindowed(modeChange.previous);
    SyncMode(modeChange.previous);
    const auto state = Game<uintptr_t>(0xAD3F68);
    if (state) {
        Game<uint32_t>(state + 0x1A4) = modeChange.resolution;
        Game<uint32_t>(state + 0x278) = modeChange.samples;
        Game<uint32_t>(state + 0x27C) = modeChange.quality;
    }
}

void RestoreWindow() {
    const HWND window = GameWindow();
    realStyle(window, GWL_STYLE, modeChange.style);
    realStyle(window, GWL_EXSTYLE, modeChange.exStyle);
    SetWindowPlacement(window, &modeChange.placement);
    realPosition(window, modeChange.exStyle & WS_EX_TOPMOST ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0,
                 SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_FRAMECHANGED);
}

bool ApplyDisplayMode(int width, int height, Mode target) {
    if (transitioning || (presentation && presentation->IsResetting()) ||
        (deviceThread && GetCurrentThreadId() != deviceThread) || width <= 0 || height <= 0) {
        LOG("[Display] Reentrant/off-thread/invalid mode change rejected");
        return false;
    }
    struct EndModeChange {
        ~EndModeChange() { transitioning = false; }
    } endModeChange;
    modeChange = ModeChange{};
    modeChange.previous = currentMode.load();
    modeChange.target = target;
    modeChange.resolution = Game<uint32_t>(0x8C69C4);
    if (!ReadParameters(modeChange.parameters)) {
        SyncMode(modeChange.previous);
        return false;
    }
    modeChange.samples = modeChange.parameters.MultiSampleType;
    modeChange.quality = modeChange.parameters.MultiSampleQuality;
    const HWND window = GameWindow();
    if (!GetWindowPlacement(window, &modeChange.placement)) {
        SyncMode(modeChange.previous);
        return false;
    }
    modeChange.style = GetWindowLongW(window, GWL_STYLE);
    modeChange.exStyle = GetWindowLongW(window, GWL_EXSTYLE);
    if (modeChange.previous == Mode::Windowed) {
        normalPlacement = modeChange.placement;
        normalStyle = modeChange.style;
        normalExStyle = modeChange.exStyle;
        haveNormalPlacement = true;
    }
    transitioning = true;
    resetAttempted = false;
    lastReset = D3D_OK;
    // The game waits for its render worker here before releasing resources.
    const bool nativeOK = ApplyNative(width, height, IsWindowed(target), 1) != 0;
    const bool ok = nativeOK && resetAttempted && SUCCEEDED(lastReset);
    if (!ok || modeChange.failed) {
        LOG("[Display] Mode %u failed (reset=0x%08X); restoring mode %u", unsigned(target), unsigned(lastReset),
            unsigned(modeChange.previous));
        // ResetGame may already have restored the old mode. Avoid resetting it again.
        if (!modeChange.rolledBack && (!resetAttempted || ok)) {
            // Handle rejection before Reset, or a window failure after a successful Reset.
            modeChange.restoring = true;
            modeChange.target = modeChange.previous;
            modeChange.failed = false;
            RestoreGameState();
            resetAttempted = false;
            lastReset = D3DERR_DEVICELOST;
            const bool restored =
                ApplyNative(modeChange.parameters.BackBufferWidth, modeChange.parameters.BackBufferHeight,
                            IsWindowed(modeChange.previous), 1) != 0;
            modeChange.rolledBack = restored && resetAttempted && SUCCEEDED(lastReset) && !modeChange.failed;
        }
        RestoreGameState();
        RestoreWindow();
        DeviceLost() = !modeChange.rolledBack;
        return false;
    }
    currentMode.store(target);
    SyncMode(target);
    LOG("[Display] Mode=%u, render=%dx%d, thread=%lu", unsigned(target), width, height, GetCurrentThreadId());
    return true;
}

HRESULT ResetGame() {
    resetAttempted = true;
    auto* device = Device();
    if (!device || (deviceThread && GetCurrentThreadId() != deviceThread)) {
        if (transitioning) modeChange.failed = true;
        return lastReset = D3DERR_INVALIDCALL;
    }
    auto requested = Parameters(); // Reset mutates its arguments; keep the game's copy intact.
    if (ModeForWindow() == Mode::Borderless) {
        requested.Windowed = TRUE;
        requested.FullScreen_RefreshRateInHz = 0;
        requested.BackBufferFormat = D3DFMT_UNKNOWN;
    }
    HRESULT result = transitioning && modeChange.failed ? D3DERR_INVALIDCALL : device->Reset(&requested);
    if (FAILED(result) && transitioning && !modeChange.restoring) {
        LOG("[Display] Reset failed (0x%08X); retrying previous presentation", unsigned(result));
        modeChange.failed = true;
        modeChange.target = modeChange.previous;
        RestoreGameState();
        RestoreWindow();
        auto previous = modeChange.parameters;
        result = device->Reset(&previous);
        modeChange.rolledBack = SUCCEEDED(result);
    }
    if (FAILED(result) && transitioning) modeChange.failed = true;
    lastReset = result;
    LOG("[Display] Reset result=0x%08X, recovered=%u", unsigned(result), unsigned(modeChange.rolledBack));
    return result;
}

bool RecoverDevice() {
    // This game function may skip Reset and call Sleep while the device is lost.
    // Only ResetGame can turn lastReset into a successful HRESULT.
    lastReset = D3DERR_DEVICELOST;
    reinterpret_cast<void(__cdecl*)()>(0x5C8380)();
    if (SUCCEEDED(lastReset)) return true;
    Game<uint8_t>(0xB192BA) = 0;
    DeviceLost() = 1;
    return false;
}

LRESULT CALLBACK WindowProc(HWND window, UINT message, WPARAM wParam, LPARAM lParam) {
    // Block F10 from trying to trigger menu in borderless
    if (message == WM_SYSCOMMAND &&
        (wParam & 0xFFF0) == SC_KEYMENU &&
        ModeForWindow() == Mode::Borderless)
        return 0;

    if (message == WM_PAINT && (transitioning || DeviceLost() || (presentation && presentation->IsResetting()))) {
        PAINTSTRUCT paint{};
        BeginPaint(window, &paint);
        EndPaint(window, &paint);
        return 0;
    }
    const auto previous = previousWindowProc;
    if (message == WM_NCDESTROY) {
        SetWindowLongPtrA(window, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(previous));
        observedWindow = nullptr;
        previousWindowProc = nullptr;
    }
    return CallWindowProcA(previous, window, message, wParam, lParam);
}

// The hook stub saves registers in this order (pushad, flags, return address).
struct Registers {
    uint32_t edi, esi, ebp, savedEsp, ebx, edx, ecx, eax, flags, resume;
    uintptr_t Stack() const { return savedEsp + 8; }
};
using Handler = void(__cdecl*)(Registers*);

// Fullscreen option: On / Off / Borderless.
void __cdecl DrawModeOption(Registers* r) {
    int language = Game<int>(0x7305FC + Game<uint32_t>(0x8A9060) * 4);
    if (language < 0 || language > 5) language = 1;
    const auto labels = Game<uintptr_t>(0x8C6580 + language * 4);
    const int x = r->edi, y = Game<int>(r->Stack() + 0x1C);
    const auto mode = DecodeMode(Selection());
    DrawResource(Game<int>(labels), x, y, mode == Mode::Exclusive ? 9 : 7, r->ebx, 30, 36);
    DrawResource(Game<int>(labels + 4), x + 90, y, mode == Mode::Windowed ? 9 : 7, r->ebx, 30, 36);
    DrawText("Borderless", x + 180, y, mode == Mode::Borderless ? 9 : 7, r->ebx, 30, 36);
}

void __cdecl HandleModeInput(Registers* r) {
    const bool gamepad = (r->ebx & 0xFC000000u) != 0;
    int direction = 0;
    if ((r->ebx & 0x40000000u) || (!gamepad && (r->ebx & 4)))
        direction = -1;
    else if ((r->ebx & 0x80000000u) || (!gamepad && (r->ebx & 8)))
        direction = 1;
    const Mode previous = DecodeMode(Selection());
    const Mode next = StepMode(previous, direction);
    if (next != previous) Game<int>(r->ebp - 0x18) = 0x1C;
    Selection() = static_cast<uint32_t>(next);
    r->esi = Selection();
    r->eax = ClampMSAA(next);
}

void __cdecl LoadModeOption(Registers* r) {
    const auto mode = DecodeMode(static_cast<int>(r->eax));
    Selection() = static_cast<uint32_t>(mode);
    r->esi = Selection();
    Game<uint8_t>(r->ebp - 0xAD) = mode == Mode::Exclusive;
    r->eax = ClampMSAA(mode);
}

void __cdecl RestoreSaved(Registers* r) { r->eax = ClampMSAA(DecodeMode(Selection())); }
void __cdecl RestoreSelection(Registers* r) {
    r->esi = Selection();
    r->eax = ClampMSAA(DecodeMode(Selection()));
}

void __cdecl SaveModeOption(Registers* r) { r->ecx = static_cast<uint32_t>(DecodeMode(Selection())); }
void __cdecl SyncMenuMode(Registers* r) {
    Selection() = static_cast<uint32_t>(currentMode.load());
    r->eax = ClampMSAA(currentMode.load());
}

void __cdecl SyncMainMenuMode(Registers* r) {
    Game<uint32_t>(r->esi + 0x19C) = static_cast<uint32_t>(currentMode.load());
    r->eax = ClampMSAA(currentMode.load());
}

void __cdecl ApplyOption(Registers* r) { r->eax = ApplyDisplayMode(r->edi, r->esi, DecodeMode(Selection())); }
void __cdecl ApplyResolution(Registers* r) {
    const auto entry = Game<uintptr_t>(0x1D59F8C) + Game<uint32_t>(0x1D59FC4) * 8;
    r->eax = ApplyDisplayMode(Game<int>(entry), Game<int>(entry + 4), DecodeMode(Selection()));
}

void __cdecl ApplySavedMode(Registers* r) {
    ApplyDisplayMode(Game<int>(r->ebp - 0xB4), Game<int>(r->ebp - 0xB8), DecodeMode(Selection()));
}
void __cdecl Reset(Registers* r) { r->eax = ResetGame(); }
void __cdecl Recover(Registers* r) {
    // The native recovery routine ignores Reset's HRESULT and clears device loss.
    // Both continuations have the same stack depth; skip rebuilding on failure.
    if (!RecoverDevice()) r->resume = 0x5C88F6;
}

// Hook construction. Expected bytes below belong to the Steam x86 executable.
std::vector<uint8_t> HexBytes(const char* hex) {
    std::vector<uint8_t> result;
    while (*hex) {
        char pair[3]{hex[0], hex[1], 0};
        result.push_back(static_cast<uint8_t>(std::strtoul(pair, nullptr, 16)));
        hex += 2;
    }
    return result;
}

void AppendWord(std::vector<uint8_t>& bytes, uint32_t value) {
    for (int i = 0; i < 4; ++i) bytes.push_back(static_cast<uint8_t>(value >> (i * 8)));
}

uint32_t AppendBytes(PatchFramework::Definition& d, const std::vector<uint8_t>& bytes) {
    const auto offset = static_cast<uint32_t>(d.bytes.size());
    d.bytes.insert(d.bytes.end(), bytes.begin(), bytes.end());
    return offset;
}

void Hook(PatchFramework::Definition& d, const char* name, uint32_t address, uint32_t resume, const char* expected,
          Handler callback) {
    auto original = HexBytes(expected);
    asmjit::CodeHolder holder;
    if (holder.init(asmjit::Environment(asmjit::Arch::kX86)) != asmjit::Error::kOk)
        throw std::runtime_error("Cannot initialize display hook assembler");
    struct Errors : asmjit::ErrorHandler {
        void handle_error(asmjit::Error, const char* message, asmjit::BaseEmitter*) override {
            throw std::runtime_error(message);
        }
    } errors;
    holder.set_error_handler(&errors);
    asmjit::x86::Assembler a(&holder);
    using namespace asmjit::x86;
    // Registers describes pushad's layout. The extra return slot allows a C++
    // handler to select a continuation without encoding game logic in assembly.
    a.push(resume);
    a.pushfd();
    a.pushad();
    a.mov(ebx, esp);
    a.and_(esp, -16);
    a.sub(esp, 512);
    a.fxsave(ptr(esp));
    a.sub(esp, 16);
    a.mov(dword_ptr(esp), ebx);
    a.cld(); // The C++ ABI requires a clear direction flag; popfd restores it.
    a.mov(eax, reinterpret_cast<uintptr_t>(callback));
    a.call(eax);
    a.add(esp, 16);
    a.fxrstor(ptr(esp));
    a.mov(esp, ebx);
    a.popad();
    a.popfd();
    a.ret();
    const auto& buffer = holder.section_by_id(0)->buffer();
    std::vector<uint8_t> code(buffer.data(), buffer.data() + buffer.size());
    const uint32_t target = static_cast<uint32_t>(d.segments.size());
    d.segments.push_back({1, PatchFramework::Kind::Code, uint32_t(code.size()), AppendBytes(d, code),
                          uint32_t(code.size()), 0, 0, name});
    std::vector<uint8_t> patch(original.size(), 0x90);
    patch[0] = 0xE9;
    const uint32_t owner = static_cast<uint32_t>(d.segments.size());
    d.segments.push_back({1, PatchFramework::Kind::Patch, uint32_t(patch.size()), AppendBytes(d, patch),
                          uint32_t(patch.size()), address - imageBase, AppendBytes(d, original), name});
    d.fixups.push_back({owner, 1, int32_t(target), uint32_t(-4), 2});
}

void Guard(PatchFramework::Definition& d, uint32_t address, const char* expected) {
    const auto bytes = HexBytes(expected);
    d.guards.push_back({1, address - imageBase, AppendBytes(d, bytes), uint32_t(bytes.size())});
}

void Import(PatchFramework::Definition& d, uint32_t address, uintptr_t replacement, const char* name) {
    const auto original = reinterpret_cast<uintptr_t>(GetProcAddress(GetModuleHandleW(L"user32.dll"), name));
    std::vector<uint8_t> before, after;
    AppendWord(before, original);
    AppendWord(after, replacement);
    d.segments.push_back({1, PatchFramework::Kind::Patch, 4, AppendBytes(d, after), 4, address - imageBase,
                          AppendBytes(d, before), name});
}

PatchFramework::Definition BuildPatchDefinition() {
    PatchFramework::Definition d;
    d.id = "builtin-display-mode";
    d.version = "2";
    d.configSection = "Display";
    d.imageBase = imageBase;
    d.imageSize = 0x2B01000;
    d.features.push_back({1, 0, "Borderless"});
    // Check overwritten instructions and the native code each hook relies on.
    // clang-format off
    Hook(d,"restore_saved",0x4fc771,0x4fc78b,"833dbc9fd50100",&RestoreSaved);
    Guard(d,0x4fc771,"833dbc9fd5010068889adb010f94c1880dc09adb01e805f50c00");
    Hook(d,"restore_defaults",0x4fc81c,0x4fc836,"8b35bc9fd501",&RestoreSelection);
    Guard(d,0x4fc81c,"8b35bc9fd50185f60f94c068889adb01a2c09adb01e85af40c00");
    Hook(d,"draw",0x4fbaa5,0x4fbf9f,"c744241400000000",&DrawModeOption);
    Hook(d,"input",0x4fda97,0x4fdaf9,"f7c300000040",&HandleModeInput);
    Hook(d,"load",0x4f8801,0x4f8830,"85c00f9fc0",&LoadModeOption);
    Hook(d,"save",0x4f8f9a,0x4f8fa1,"33c984db0f95c1",&SaveModeOption);
    Hook(d,"sync_menu",0x4f9719,0x4f973d,"33c0380585908a00",&SyncMenuMode);
    Hook(d,"sync_main",0x4c3758,0x4c377d,"33c0380585908a00",&SyncMainMenuMode);
    Hook(d,"apply_exit",0x4fc6b9,0x4fc6be,"e862d20c00",&ApplyOption);
    Hook(d,"apply_defaults",0x4fc8ba,0x4fc8bf,"e861d00c00",&ApplyOption);
    Hook(d,"apply_option",0x4fdb5d,0x4fdb62,"e8bebd0c00",&ApplyOption);
    Hook(d,"apply_resolution",0x4fd586,0x4fd712,"833dbc9fd50101a18c9fd501",&ApplyResolution);
    Hook(d,"apply_load",0x4f8a5b,0x4f8c63,"81bd4cffffff00050000",&ApplySavedMode);
    // Menu-only mode changes: jump over the native Alt+Enter toggle (0x5C85D7 -> 0x5C85F2).
    d.segments.push_back({1, PatchFramework::Kind::Patch, 6, AppendBytes(d, HexBytes("e91600000090")), 6,
                          0x5C85D7 - imageBase, AppendBytes(d, HexBytes("8a0d85908a00")), "disable_alt_enter"});
    Hook(d,"recovery_result",0x5c87a3,0x5c87a8,"e8d8fbffff",&Recover);
    Guard(d,0x5c88f6,"8b4c24445f5e5b33cce802d811008be55dc3");
    Hook(d,"reset",0x5c83b3,0x5c83c5,"a19c99b200",&Reset);
    Guard(d,0x4fbaa5,"c744241400000000c7442418010000008b4c24188b1560908a0033c0390dbc9fd5010f94c08d4400070fb7f08b0495fc05730085c0780583f8057e12682c748700e8b5800a0083c404b8010000008b4c241c8b048580658c008b5424146a246a1e53568b34105157e83eca03008b4424308344242c044883c41883c75a8944241883f8ff7f8ae96f040000");
    Guard(d,0x4fda97,"f7c300000040752c8bc325000000fc7505f6c304751e85db780985c0752af6c308742533f68935bc9fd501c745e81c000000eb1abe010000008935bc9fd501c745e81c000000eb068b35bc9fd50185f60f94c068889adb01a2c09adb01e897e10c00");
    Guard(d,0x4f8801,"85c00f9fc033c984c00f95c168889adb01888553ffffff8bf13bf70f94c28935bc9fd5018815c09adb01e860340d00");
    Guard(d,0x4f9719,"33c0380585908a0068889adb010f94c085c0a3bc9fd5010f94c0a2c09adb01e853250d00");
    Guard(d,0x4c3758,"33c0380585908a0068889adb010f94c089869c0100003bc30f94c0a2c09adb01e813851000");
    Guard(d,0x4fd586,"833dbc9fd50101a18c9fd5018b0dc49fd5018b34c88b7cc8040f95c3381d85908a00751439355c99b200750c393d5899b2000f8454010000e89d2a0d00e8d8570d00e853120e00e81e130e00a1649adb0133c98988bc0000008988c0000000a19899b2008b088b511050ffd2a19899b2008b088d55ec526a00508b4120ffd0a19899b2008b088b511050ffd2a19899b2008b080fb6d3526a166a166a016a00508b4124ffd085c00f85df0000008ac38bce8bd7a285908a00890d5c99b20089155899b2008935889adb01893d8c9adb0184db7531a19899b2008b088b511050ffd2a19899b2008b088d55ec526a00508b4120ffd0a085908a008b0d5c99b2008b155899b200890d6099b200890d3899b2000fb6c889156499b20089153499b200890d8099b20084c0742e8b1560d0c301680000ca006af052c7056899b20000000000ff154c357000a160d0c3016a0550ff1550357000eb1e8b0d60d0c30168000008906af051c7056899b20016000000ff154c357000e8afab0c00e81aa90c00c605bf92b10001e8feaf0c00");
    Guard(d,0x4f8a5b,"81bd4cffffff00050000752481bd48ffffffd0020000751884db7516393d98a0d501750c393d9ca0d5010f84d801000084db0f94c3381d85908a0075208b8d4cffffff390d5c99b20075128b9548ffffff39155899b2000f84ab010000e8a3750d00e8dea20d008b356c88910081fe6c889100741c3bf774058d4efceb0233c98b018b5008ffd28b3681fe6c88910075e48b359088910081fe9088910074228d9b000000003bf774058d4efceb0233c98b018b5008ffd28b3681fe9088910075e4a1649adb0189b8bc00000089b8c0000000a19899b2008b088b511050ffd2a19899b2008b088d9554ffffff5257508b4120ffd0a19899b2008b088b511050ffd2a19899b2008b080fb6d3526a166a166a0157508b4124ffd085c00f85e70000008bb548ffffff8b8d4cffffff8ac38bd6a285908a00890d5c99b20089355899b200890d889adb0189158c9adb0184db7533a19899b2008b088b511050ffd2a19899b2008b088d9554ffffff5257508b4120ffd0a085908a008b0d5c99b2008b355899b200890d6099b200890d3899b2000fb6c889356499b20089353499b200890d8099b20084c0742a8b1560d0c301680000ca006af052893d6899b200ff154c357000a160d0c3016a0550ff1550357000eb1e8b0d60d0c30168000008906af051c7056899b20016000000ff154c357000e85ef60c00e8c9f30c00c605bf92b10001e8adfa0c00");
    Guard(d,0x5c85d7,"8a0d85908a0084c90f94c0c60579d0c301013ac87405e80efdffff");
    Guard(d,0x5c83b3,"a19c99b2008b088b5140686099b20050ffd2");
    Guard(d,0x5c9920,"558bec83ec14a1c48d8a0033c58945fc807d0c00538a5d08751c381d85908a007514393d5c99b200750c39355899b2000f845d010000e805670000e840940000e8bb4e0100e8864f0100a1649adb0133c98988bc0000008988c0000000a19899b2008b088b511050ffd2a19899b2008b088d55ec526a00508b4120ffd0a19899b2008b088b511050ffd2a19899b2008b080fb6d3526a166a166a016a00508b4124ffd085c0741132c05b8b4dfc33cde832c711008be55dc38bc78bce881d85908a00a35c99b200890d5899b200893d889adb0189358c9adb0184db7531a19899b2008b088b511050ffd2a19899b2008b088d55ec526a00508b4120ffd08a1d85908a00a15c99b2008b0d5899b200890d6499b200890d3499b2000fb6cba36099b200a33899b200890d8099b20084db742e8b1560d0c301680000ca006af052c7056899b20000000000ff154c357000a160d0c3016a0550ff1550357000eb1e8b0d60d0c30168000008906af051c7056899b20016000000ff154c357000e80ee8ffffe879e5ffffc605bf92b10001e85decffff8b4dfc33cdb0015be846c611008be55dc3");
    Guard(d,0x532250,"558bec83e4f883ec0c53568bf00fb74508578944241485f60f84530100008b7d");
    Guard(d,0x538550,"558bec85f6743e8b15447fd70133c985d2740d8b421485c0740603c274028bc8");
    Guard(d,0x5cbc90,"558bec83ec08538b5d080fb653388b430856578d7b0803d28d74d3188945fc57");
    // clang-format on
    Import(d, 0x70354C, reinterpret_cast<uintptr_t>(&SetStyle), "SetWindowLongA");
    Import(d, 0x703588, reinterpret_cast<uintptr_t>(&SetPosition), "SetWindowPos");
    Import(d, 0x703550, reinterpret_cast<uintptr_t>(&Show), "ShowWindow");
    return d;
}

void DeviceCreated(IDirect3DDevice9* device, Presentation* controller) {
    if (!enabled) return;
    presentation = controller;
    deviceThread = GetCurrentThreadId(); // D3D resets belong to the device creation thread.
    D3DDEVICE_CREATION_PARAMETERS creation{};
    if (FAILED(device->GetCreationParameters(&creation)) || !creation.hFocusWindow) return;
    observedWindow = creation.hFocusWindow;
    SetLastError(0);
    previousWindowProc = reinterpret_cast<WNDPROC>(
        SetWindowLongPtrA(observedWindow, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(&WindowProc)));
    if (!previousWindowProc) {
        LOG("[Display] Cannot observe window messages (error %lu)", GetLastError());
        observedWindow = nullptr;
    }
    LOG("[Display] Device creation thread=%lu", deviceThread);
}

void DeviceDestroyed(Presentation* controller) {
    if (presentation != controller) return;
    presentation = nullptr;
    if (observedWindow && reinterpret_cast<WNDPROC>(GetWindowLongPtrA(observedWindow, GWLP_WNDPROC)) == &WindowProc) {
        SetWindowLongPtrA(observedWindow, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(previousWindowProc));
        observedWindow = nullptr;
        previousWindowProc = nullptr;
    }
}
} // namespace

void Init() {
    static std::once_flag once;
    std::call_once(once, [] {
        try {
            auto user = GetModuleHandleW(L"user32.dll");
            realStyle = reinterpret_cast<StyleFn>(GetProcAddress(user, "SetWindowLongA"));
            realPosition = reinterpret_cast<PositionFn>(GetProcAddress(user, "SetWindowPos"));
            realShow = reinterpret_cast<ShowFn>(GetProcAddress(user, "ShowWindow"));
            if (!realStyle || !realPosition || !realShow) return;
            std::string error;
            if (!PatchFramework::InstallBuiltin(BuildPatchDefinition(), error)) {
                LOG("[Display] Borderless unavailable: %s", error.c_str());
                return;
            }
            currentMode.store(GameWindowed() ? Mode::Windowed : Mode::Exclusive);
            Game<uint32_t>(0x1D59FC0) = static_cast<uint32_t>(currentMode.load());
            enabled = true;
            LOG("[Display] Three-state fullscreen menu installed");
        } catch (const std::exception& e) {
            LOG("[Display] Initialization failed: %s", e.what());
        }
    });
}

// The window and controller share this state. Queued messages remain safe if
// the proxy is released on the render thread before the window is destroyed.
struct Presentation::Dispatch {
    std::mutex mutex;
    std::condition_variable condition;
    Presentation* owner = nullptr;
    HWND window = nullptr;
    std::atomic<bool> resetting{false};
    std::atomic<bool> messageQueued{false};
};

bool Presentation::IsResetting() const { return dispatch_ && dispatch_->resetting && GetCurrentThreadId() == thread_; }

Presentation::~Presentation() {
    DeviceDestroyed(this);
    if (dispatch_) {
        HWND window;
        {
            std::lock_guard<std::mutex> lock(dispatch_->mutex);
            dispatch_->owner = nullptr;
            window = dispatch_->window;
            dispatch_->condition.notify_all();
        }
        if (window) {
            if (GetCurrentThreadId() == thread_)
                DestroyWindow(window);
            else
                PostMessageW(window, WM_CLOSE, 0, 0);
        }
    }
    if (device_) device_->Release();
}

LRESULT CALLBACK Presentation::DispatchWindowProc(HWND window, UINT message, WPARAM wParam, LPARAM lParam) {
    using Holder = std::shared_ptr<Dispatch>;
    if (message == WM_NCCREATE) {
        const auto* create = reinterpret_cast<CREATESTRUCTW*>(lParam);
        auto* holder = new Holder(*static_cast<Holder*>(create->lpCreateParams));
        SetWindowLongPtrW(window, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(holder));
    }
    auto* holder = reinterpret_cast<Holder*>(GetWindowLongPtrW(window, GWLP_USERDATA));
    if (holder) {
        auto state = *holder;
        if (message == updateMessage) {
            // A reset may dispatch window messages while this mutex is held.
            if (state->resetting || transitioning) {
                state->messageQueued = false;
                return 0; // Retry the desired interval after the next frame.
            }
            // Wait without holding the lock so the render worker can finish.
            // Recheck the owner afterward in case the proxy was released.
            std::unique_lock<std::mutex> lock(state->mutex);
            auto* owner = state->owner;
            if (owner) {
                owner->pauseRequested_ = true;
                const bool idle = state->condition.wait_for(lock, std::chrono::milliseconds(100),
                                                            [&] { return !state->owner || !owner->frameActive_; });
                if (state->owner) {
                    if (idle)
                        owner->failure_.store(owner->ApplyInterval());
                    else if (!owner->deferredLogged_) {
                        LOG("[Display] VSync switch waiting for a render frame boundary; will retry");
                        owner->deferredLogged_ = true;
                    }
                    owner->pauseRequested_ = false;
                    state->messageQueued = false;
                }
                state->condition.notify_all();
            }
            return 0;
        }
        if (message == WM_NCDESTROY) {
            {
                std::lock_guard<std::mutex> lock(state->mutex);
                state->window = nullptr;
            }
            SetWindowLongPtrW(window, GWLP_USERDATA, 0);
            delete holder;
        }
    }
    return DefWindowProcW(window, message, wParam, lParam);
}

void Presentation::CreateDispatcher() {
    dispatch_ = std::make_shared<Dispatch>();
    dispatch_->owner = this;
    HMODULE module = nullptr;
    if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                            reinterpret_cast<LPCWSTR>(&DispatchWindowProc), &module))
        return;
    WNDCLASSW type{};
    type.lpfnWndProc = DispatchWindowProc;
    type.hInstance = module;
    type.lpszClassName = dispatchClass;
    if (!RegisterClassW(&type) && GetLastError() != ERROR_CLASS_ALREADY_EXISTS) return;
    dispatch_->window =
        CreateWindowExW(0, dispatchClass, L"", 0, 0, 0, 0, 0, HWND_MESSAGE, nullptr, module, &dispatch_);
    if (dispatch_->window)
        LOG("[Display] VSync dispatcher ready on device creation thread %lu", thread_);
    else
        LOG("[Display] Could not create VSync dispatcher (error %lu)", GetLastError());
}

void Presentation::Init(IDirect3DDevice9* device) {
    DeviceCreated(device, this);
    // Local GUID avoids a dependency on dxguid.lib or d3d9.lib.
    static const GUID device9Ex = {0xb18b10ce, 0x2649, 0x405a, {0x87, 0x0f, 0x95, 0xf7, 0x77, 0xd4, 0x31, 0x3a}};
    if (FAILED(device->QueryInterface(device9Ex, reinterpret_cast<void**>(&device_)))) {
        LOG("[Display] D3D9Ex unavailable; keeping the game's VSync settings");
        return;
    }
    thread_ = GetCurrentThreadId();
    D3DDEVICE_CREATION_PARAMETERS creation{};
    if (FAILED(device_->GetCreationParameters(&creation)) || (creation.BehaviorFlags & D3DCREATE_ADAPTERGROUP_DEVICE)) {
        LOG("[Display] Unsupported device configuration; keeping the game's VSync settings");
        device_->Release();
        device_ = nullptr;
        return;
    }
    CreateDispatcher();
    OnGameReset();
}

HRESULT Presentation::ReadParameters(D3DPRESENT_PARAMETERS& params) {
    IDirect3DSwapChain9* chain = nullptr;
    HRESULT result = device_->GetSwapChain(0, &chain);
    if (FAILED(result)) return result;
    result = chain->GetPresentParameters(&params);
    chain->Release(); // Do not retain a swap-chain reference across ResetEx.
    return result;
}

void Presentation::OnGameReset() {
    if (!device_ || !dispatch_ || IsResetting()) return;
    std::lock_guard<std::mutex> lock(dispatch_->mutex);
    D3DPRESENT_PARAMETERS params{};
    ready_ = SUCCEEDED(ReadParameters(params));
    blocked_ = false;
    frameActive_ = false;
    failure_.store(D3D_OK);
    dispatch_->condition.notify_all();
    if (ready_)
        requestedInterval_ = appliedInterval_ = params.PresentationInterval;
    else
        LOG("[Display] Could not read presentation settings; VSync switching unavailable");
}

HRESULT Presentation::BeginFrame() {
    if (!dispatch_) return D3D_OK;
    if (IsResetting()) return D3DERR_DEVICELOST;
    std::unique_lock<std::mutex> lock(dispatch_->mutex);
    // A second BeginScene in the current frame must be allowed to finish it.
    dispatch_->condition.wait(lock, [&] { return !pauseRequested_ || frameActive_; });
    if (FAILED(failure_.load())) return failure_.load();
    frameActive_ = true;
    return D3D_OK;
}

HRESULT Presentation::Update(bool immediate) {
    if (!dispatch_ || IsResetting()) return D3D_OK;
    std::lock_guard<std::mutex> lock(dispatch_->mutex);
    frameActive_ = false;
    immediate_ = immediate;
    dispatch_->condition.notify_all();
    if (FAILED(failure_.load())) return failure_.load();
    if (!ready_ || blocked_ || transitioning) return D3D_OK;
    const UINT target = immediate_ ? D3DPRESENT_INTERVAL_IMMEDIATE : requestedInterval_;
    if (target == appliedInterval_) return D3D_OK;
    if (GetCurrentThreadId() != thread_) {
        if (!dispatch_->messageQueued) {
            if (dispatch_->window && PostMessageW(dispatch_->window, updateMessage, 0, 0)) {
                dispatch_->messageQueued = true;
                LOG("[Display] Queued VSync switch from render thread %lu to creation thread %lu", GetCurrentThreadId(),
                    thread_);
            } else {
                blocked_ = true;
                LOG("[Display] Could not queue VSync switch; keeping current presentation settings");
            }
        }
        return D3D_OK;
    }
    const HRESULT result = ApplyInterval();
    failure_.store(result);
    return result;
}

HRESULT Presentation::ApplyInterval() {
    if (!ready_ || blocked_ || IsResetting()) return D3D_OK;
    const UINT target = immediate_ ? D3DPRESENT_INTERVAL_IMMEDIATE : requestedInterval_;
    if (target == appliedInterval_) return D3D_OK;

    D3DPRESENT_PARAMETERS previous{};
    D3DDISPLAYMODEEX mode{};
    mode.Size = sizeof(mode);
    HRESULT result = ReadParameters(previous);
    if (SUCCEEDED(result) && !previous.Windowed) result = device_->GetDisplayModeEx(0, &mode, nullptr);
    if (FAILED(result)) {
        blocked_ = true;
        LOG("[Display] Could not read swap-chain/display mode (0x%08X); VSync switching disabled",
            static_cast<unsigned>(result));
        return D3D_OK;
    }

    auto params = previous;
    auto requestedMode = mode;
    params.PresentationInterval = target;
    // ResetEx preserves textures and render state. Plain Reset does not.
    // ResetEx can dispatch window messages; skip reentrant Present calls.
    dispatch_->resetting = true;
    result = device_->ResetEx(&params, previous.Windowed ? nullptr : &requestedMode);
    if (FAILED(result)) {
        LOG("[Display] VSync switch failed (0x%08X); restoring previous presentation settings",
            static_cast<unsigned>(result));
        // ResetEx mutates its arguments and a failed reset can lose the device.
        // Retry from fresh copies before making any other device calls.
        params = previous;
        requestedMode = mode;
        result = device_->ResetEx(&params, previous.Windowed ? nullptr : &requestedMode);
        dispatch_->resetting = false;
        blocked_ = true; // Retry only after a successful game-initiated reset.
        if (FAILED(result)) {
            ready_ = false;
            LOG("[Display] Presentation recovery failed (0x%08X); requesting game device recovery",
                static_cast<unsigned>(result));
            return D3DERR_DEVICELOST;
        }
        return D3D_OK;
    }
    dispatch_->resetting = false;
    appliedInterval_ = target;
    deferredLogged_ = false;
    LOG("[Display] Presentation interval=0x%08X (%s), applied on thread %lu", target,
        immediate_ ? "VSync bypassed" : "game settings restored", GetCurrentThreadId());
    return D3D_OK;
}

} // namespace DisplayMode
