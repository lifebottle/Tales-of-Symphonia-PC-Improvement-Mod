#include "fast_forward_presentation.h"
#include "logger.h"
#include <chrono>
#include <condition_variable>
#include <mutex>

namespace FastForward {

namespace {
constexpr UINT updateMessage = WM_APP + 1;
constexpr wchar_t dispatchClass[] = L"TOSImprovementMod.VSyncDispatch";
}

// The window and controller share this state. Queued messages remain safe if
// the proxy is released on the render thread before the window is destroyed.
struct Presentation::Dispatch {
    std::mutex mutex;
    std::condition_variable condition;
    Presentation* owner = nullptr;
    HWND window = nullptr;
};

Presentation::~Presentation() {
    if (dispatch_) {
        HWND window;
        {
            std::lock_guard<std::mutex> lock(dispatch_->mutex);
            dispatch_->owner = nullptr;
            window = dispatch_->window;
            dispatch_->condition.notify_all();
        }
        if (window) {
            if (GetCurrentThreadId() == thread_) DestroyWindow(window);
            else PostMessageW(window, WM_CLOSE, 0, 0);
        }
    }
    if (device_) device_->Release();
}

LRESULT CALLBACK Presentation::DispatchWindowProc(HWND window, UINT message,
                                                  WPARAM wParam, LPARAM lParam) {
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
            // Wait without holding the lock so the render worker can finish.
            // Recheck the owner afterward in case the proxy was released.
            std::unique_lock<std::mutex> lock(state->mutex);
            auto* owner = state->owner;
            if (owner) {
                owner->pauseRequested_ = true;
                const bool idle = state->condition.wait_for(lock, std::chrono::milliseconds(100), [&] {
                    return !state->owner || !owner->frameActive_;
                });
                if (state->owner) {
                    if (idle) owner->failure_.store(owner->ApplyInterval());
                    else if (!owner->deferredLogged_) {
                        LOG("[FastForward] VSync switch waiting for a render frame boundary; will retry");
                        owner->deferredLogged_ = true;
                    }
                    owner->pauseRequested_ = false;
                    owner->messageQueued_ = false;
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
    if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                           GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           reinterpret_cast<LPCWSTR>(&DispatchWindowProc), &module)) return;
    WNDCLASSW type{};
    type.lpfnWndProc = DispatchWindowProc;
    type.hInstance = module;
    type.lpszClassName = dispatchClass;
    if (!RegisterClassW(&type) && GetLastError() != ERROR_CLASS_ALREADY_EXISTS) return;
    dispatch_->window = CreateWindowExW(0, dispatchClass, L"", 0, 0, 0, 0, 0,
                                       HWND_MESSAGE, nullptr, module, &dispatch_);
    if (dispatch_->window)
        LOG("[FastForward] VSync dispatcher ready on device creation thread %lu", thread_);
    else
        LOG("[FastForward] Could not create VSync dispatcher (error %lu)", GetLastError());
}

void Presentation::Init(IDirect3DDevice9* device) {
    // Local GUID avoids a dependency on dxguid.lib or d3d9.lib.
    static const GUID device9Ex = {0xb18b10ce, 0x2649, 0x405a,
        {0x87, 0x0f, 0x95, 0xf7, 0x77, 0xd4, 0x31, 0x3a}};
    if (FAILED(device->QueryInterface(device9Ex, reinterpret_cast<void**>(&device_)))) {
        LOG("[FastForward] D3D9Ex unavailable; keeping the game's VSync settings");
        return;
    }
    thread_ = GetCurrentThreadId();
    D3DDEVICE_CREATION_PARAMETERS creation{};
    if (FAILED(device_->GetCreationParameters(&creation)) ||
        (creation.BehaviorFlags & D3DCREATE_ADAPTERGROUP_DEVICE)) {
        LOG("[FastForward] Unsupported device configuration; keeping the game's VSync settings");
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
    if (ready_) requestedInterval_ = appliedInterval_ = params.PresentationInterval;
    else LOG("[FastForward] Could not read presentation settings; VSync switching unavailable");
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
    if (!ready_ || blocked_) return D3D_OK;
    const UINT target = immediate_ ? D3DPRESENT_INTERVAL_IMMEDIATE : requestedInterval_;
    if (target == appliedInterval_) return D3D_OK;
    if (GetCurrentThreadId() != thread_) {
        if (!messageQueued_) {
            if (dispatch_->window && PostMessageW(dispatch_->window, updateMessage, 0, 0)) {
                messageQueued_ = true;
                LOG("[FastForward] Queued VSync switch from render thread %lu to creation thread %lu",
                    GetCurrentThreadId(), thread_);
            } else {
                blocked_ = true;
                LOG("[FastForward] Could not queue VSync switch; keeping current presentation settings");
            }
        }
        return D3D_OK;
    }
    const HRESULT result = ApplyInterval();
    failure_.store(result);
    return result;
}

HRESULT Presentation::ApplyInterval() {
    if (!ready_ || blocked_ || resetting_.load()) return D3D_OK;
    const UINT target = immediate_ ? D3DPRESENT_INTERVAL_IMMEDIATE : requestedInterval_;
    if (target == appliedInterval_) return D3D_OK;

    D3DPRESENT_PARAMETERS previous{};
    D3DDISPLAYMODEEX mode{};
    mode.Size = sizeof(mode);
    HRESULT result = ReadParameters(previous);
    if (SUCCEEDED(result) && !previous.Windowed)
        result = device_->GetDisplayModeEx(0, &mode, nullptr);
    if (FAILED(result)) {
        blocked_ = true;
        LOG("[FastForward] Could not read swap-chain/display mode (0x%08X); VSync switching disabled",
            static_cast<unsigned>(result));
        return D3D_OK;
    }

    auto params = previous;
    auto requestedMode = mode;
    params.PresentationInterval = target;
    // ResetEx preserves textures and render state. Plain Reset does not.
    // ResetEx can dispatch window messages; skip reentrant Present calls.
    resetting_ = true;
    result = device_->ResetEx(&params, previous.Windowed ? nullptr : &requestedMode);
    if (FAILED(result)) {
        LOG("[FastForward] VSync switch failed (0x%08X); restoring previous presentation settings",
            static_cast<unsigned>(result));
        // ResetEx mutates its arguments and a failed reset can lose the device.
        // Retry from fresh copies before making any other device calls.
        params = previous;
        requestedMode = mode;
        result = device_->ResetEx(&params, previous.Windowed ? nullptr : &requestedMode);
        resetting_ = false;
        blocked_ = true; // Retry only after a successful game-initiated reset.
        if (FAILED(result)) {
            ready_ = false;
            LOG("[FastForward] Presentation recovery failed (0x%08X); requesting game device recovery",
                static_cast<unsigned>(result));
            return D3DERR_DEVICELOST;
        }
        return D3D_OK;
    }
    resetting_ = false;
    appliedInterval_ = target;
    deferredLogged_ = false;
    LOG("[FastForward] Presentation interval=0x%08X (%s), applied on thread %lu", target,
        immediate_ ? "VSync bypassed" : "game settings restored", GetCurrentThreadId());
    return D3D_OK;
}

} // namespace FastForward
