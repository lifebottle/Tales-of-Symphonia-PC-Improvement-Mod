#pragma once

#include <d3d9.h>
#include <string>

namespace FastForward {
    // Called after config directories exist, outside DllMain.
    void Init(const std::wstring& basePath);
    void PollHotkey();
    unsigned CurrentSpeed();
    bool OverridePresentation();
    void LogPresentationFallback(HRESULT error);

    // Keep the game-facing parameters intact apart from ordinary driver
    // output. Retry the requested settings if immediate presentation fails.
    template<typename Call>
    HRESULT WithPresentationParameters(D3DPRESENT_PARAMETERS* params, Call call) {
        if (!params || !OverridePresentation()) return call();
        const auto requested = *params;
        params->PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE;
        HRESULT result = call();
        if (FAILED(result)) {
            *params = requested;
            LogPresentationFallback(result);
            return call();
        }
        params->PresentationInterval = requested.PresentationInterval;
        return result;
    }
}
