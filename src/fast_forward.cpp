#include "fast_forward.h"
#include "fast_forward_clock.h"
#include "logger.h"
#include "ini_settings.h"

#include <atomic>
#include <cstdint>
#include <cstring>
#include <cwchar>
#include <cwctype>
#include <mutex>

namespace FastForward {
namespace {
using CounterFn = BOOL (WINAPI*)(LARGE_INTEGER*);
CounterFn realCounter = nullptr;
SRWLOCK clockLock = SRWLOCK_INIT;
ScaledCounter counter;
SpeedCycle cycle;
std::mutex inputMutex;
std::once_flag initOnce;
std::atomic<bool> installed{false};
std::atomic<unsigned> currentSpeed{1};
int hotkey = VK_F6;
bool disableVSync = true;

BOOL WINAPI ReadCounter(LARGE_INTEGER* value) {
    // Sampling under the lock also orders simultaneous calls from the game's
    // update/render threads. The proxy and system DLLs keep using real QPC.
    AcquireSRWLockExclusive(&clockLock);
    const BOOL result = realCounter(value);
    if (result) value->QuadPart = counter.Sample(value->QuadPart);
    ReleaseSRWLockExclusive(&clockLock);
    return result;
}

std::wstring Setting(const std::wstring& path, const wchar_t* key,
                     const wchar_t* fallback) {
    wchar_t value[128] = {};
    GetPrivateProfileStringW(L"FastForward", key, L"", value, 128, path.c_str());
    if (!value[0]) {
        IniSettings::WriteDefault(L"FastForward", key, fallback, path.c_str());
        return fallback;
    }
    return value;
}

bool AtEnd(const wchar_t* end) {
    while (iswspace(*end)) ++end;
    return *end == L'\0';
}

bool Readable(const void* address, size_t length) {
    MEMORY_BASIC_INFORMATION info{};
    if (!VirtualQuery(address, &info, sizeof(info)) || info.State != MEM_COMMIT ||
        (info.Protect & (PAGE_NOACCESS | PAGE_GUARD))) return false;
    const auto start = reinterpret_cast<uintptr_t>(address);
    const auto end = reinterpret_cast<uintptr_t>(info.BaseAddress) + info.RegionSize;
    return start <= end && length <= end - start;
}

bool InstallClock(unsigned char* base) {
    static_assert(sizeof(void*) == 4, "TOS requires a 32-bit proxy");
    if (!base || !Readable(base, sizeof(IMAGE_DOS_HEADER))) return false;
    const auto* dos = reinterpret_cast<const IMAGE_DOS_HEADER*>(base);
    if (dos->e_magic != IMAGE_DOS_SIGNATURE || dos->e_lfanew <= 0 ||
        dos->e_lfanew > 4096) return false;
    const auto* nt = reinterpret_cast<const IMAGE_NT_HEADERS32*>(base + dos->e_lfanew);
    if (!Readable(nt, sizeof(*nt)) || nt->Signature != IMAGE_NT_SIGNATURE ||
        nt->FileHeader.Machine != IMAGE_FILE_MACHINE_I386 ||
        nt->OptionalHeader.Magic != IMAGE_NT_OPTIONAL_HDR32_MAGIC) return false;

    // These are game addresses verified in IDA, expressed relative to its
    // preferred image base. Do not scan arbitrary data for matching pointers.
    constexpr uintptr_t imageBase = 0x400000;
    constexpr uintptr_t slotOffset = 0x703074 - imageBase;
    if (nt->OptionalHeader.SizeOfImage < slotOffset + sizeof(void*)) return false;
    auto** slot = reinterpret_cast<void**>(base + slotOffset);
    if (!Readable(slot, sizeof(*slot))) return false;

    // Render_CalcFrameTime and D3D9_Present must both call this exact slot.
    const unsigned char prefix[] = {0x55, 0x8b, 0xec, 0x83, 0xec, 0x0c,
                                    0x8d, 0x45, 0xf4, 0x50};
    const auto* frameTime = base + (0x5D2090 - imageBase);
    if (!Readable(frameTime, sizeof(prefix)) ||
        std::memcmp(frameTime, prefix, sizeof(prefix))) return false;
    for (uintptr_t address : {uintptr_t(0x5D209A), uintptr_t(0x5C92D4)}) {
        const auto* call = base + (address - imageBase);
        uintptr_t operand = 0;
        if (!Readable(call, 6) || call[0] != 0xff || call[1] != 0x15) return false;
        std::memcpy(&operand, call + 2, sizeof(operand));
        if (operand != reinterpret_cast<uintptr_t>(slot)) return false;
    }

    const auto qpc = GetProcAddress(GetModuleHandleW(L"kernel32.dll"),
                                    "QueryPerformanceCounter");
    if (!qpc || *slot != reinterpret_cast<void*>(qpc)) {
        LOG("[FastForward] Game clock is not the system QPC; leaving it untouched");
        return false; // Includes an existing third-party speedhack.
    }
    static_assert(sizeof(realCounter) == sizeof(qpc));
    std::memcpy(&realCounter, &qpc, sizeof(realCounter));
    LARGE_INTEGER now{};
    if (!realCounter(&now)) return false;
    counter.Start(now.QuadPart);

    DWORD protection = 0;
    if (!VirtualProtect(slot, sizeof(*slot), PAGE_READWRITE, &protection)) return false;
    void* previous = InterlockedCompareExchangePointer(
        slot, reinterpret_cast<void*>(&ReadCounter), reinterpret_cast<void*>(qpc));
    DWORD ignored = 0;
    if (!VirtualProtect(slot, sizeof(*slot), protection, &ignored))
        LOG("[FastForward] WARNING: could not restore clock slot page protection");
    return previous == reinterpret_cast<void*>(qpc);
}
} // namespace

void Init(const std::wstring& basePath) {
    std::call_once(initOnce, [&] {
        const auto path = basePath + L"\\d3d9_config.ini";
        const bool enabled = Setting(path, L"Enabled", L"1") != L"0";
        wchar_t* end = nullptr;

        const auto key = Setting(path, L"ToggleKey", L"0x75");
        const auto parsedKey = std::wcstoul(key.c_str(), &end, 0);
        if (end != key.c_str() && AtEnd(end) && parsedKey >= 1 && parsedKey <= 254)
            hotkey = static_cast<int>(parsedKey);
        else LOG("[FastForward] Invalid ToggleKey; using F6");
        disableVSync = Setting(path, L"DisableVSync", L"1") != L"0";
        if (!enabled) {
            LOG("[FastForward] Disabled by config");
            return;
        }
        if (!InstallClock(reinterpret_cast<unsigned char*>(GetModuleHandleW(nullptr)))) {
            LOG("[FastForward] Unsupported or already hooked game clock; feature disabled");
            return;
        }
        installed.store(true);
        LOG("[FastForward] Ready: key=0x%02X, cycle=1x/2x/4x/8x/16x, disableVSync=%d; starts OFF",
            hotkey, disableVSync);
    });
}

void PollHotkey() {
    if (!installed.load()) return;
    std::lock_guard<std::mutex> lock(inputMutex);
    DWORD foregroundProcess = 0;
    GetWindowThreadProcessId(GetForegroundWindow(), &foregroundProcess);
    const bool focused = foregroundProcess == GetCurrentProcessId();
    const bool down = (GetAsyncKeyState(hotkey) & 0x8000) != 0;
    // Commit the input transition only if we can also commit its clock change.
    auto next = cycle;
    if (!next.Update(focused, down)) {
        cycle = next;
        return;
    }
    const unsigned speed = next.Speed();
    AcquireSRWLockExclusive(&clockLock);
    LARGE_INTEGER now{};
    const BOOL sampled = realCounter(&now);
    if (sampled) counter.SetSpeed(now.QuadPart, speed);
    ReleaseSRWLockExclusive(&clockLock);
    if (sampled) {
        cycle = next;
        currentSpeed.store(speed);
        LOG("[FastForward] %s (%ux)", speed > 1 ? "ON" : "OFF", speed);
    }
}

unsigned CurrentSpeed() {
    return currentSpeed.load();
}

bool OverridePresentation() {
    return installed.load() && disableVSync;
}

void LogPresentationFallback(HRESULT error) {
    LOG("[FastForward] Immediate presentation failed (0x%08X); retrying requested settings. "
        "Fast-forward may be limited by VSync.", static_cast<unsigned>(error));
}
} // namespace FastForward
