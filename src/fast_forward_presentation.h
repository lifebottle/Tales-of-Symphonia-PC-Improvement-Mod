#pragma once

#include <d3d9.h>
#include <atomic>
#include <memory>

namespace FastForward {

// Owns an Ex interface reference, but never changes the game's parameters.
// BeginFrame/Update bracket rendering. Cross-thread changes are dispatched to
// the device creation thread's message loop and applied between frames.
class Presentation {
public:
    Presentation() = default;
    ~Presentation();
    Presentation(const Presentation&) = delete;
    Presentation& operator=(const Presentation&) = delete;

    void Init(IDirect3DDevice9* device);
    void OnGameReset();
    HRESULT BeginFrame();
    HRESULT Update(bool immediate);
    HRESULT PendingFailure() const { return failure_.load(); }
    bool IsResetting() const { return resetting_.load() && GetCurrentThreadId() == thread_; }

private:
    struct Dispatch;
    static LRESULT CALLBACK DispatchWindowProc(HWND window, UINT message, WPARAM wParam, LPARAM lParam);
    void CreateDispatcher();
    HRESULT ApplyInterval(); // Caller holds the dispatch lock on the creation thread.
    HRESULT ReadParameters(D3DPRESENT_PARAMETERS& params);
    std::shared_ptr<Dispatch> dispatch_;
    IDirect3DDevice9Ex* device_ = nullptr;
    DWORD thread_ = 0;
    UINT requestedInterval_ = D3DPRESENT_INTERVAL_DEFAULT;
    UINT appliedInterval_ = D3DPRESENT_INTERVAL_DEFAULT;
    bool ready_ = false;
    bool blocked_ = false;
    bool frameActive_ = false;
    bool pauseRequested_ = false;
    bool messageQueued_ = false;
    bool immediate_ = false;
    bool deferredLogged_ = false;
    std::atomic<bool> resetting_{false};
    std::atomic<HRESULT> failure_{D3D_OK};
};

} // namespace FastForward
