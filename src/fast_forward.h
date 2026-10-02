#pragma once

#include <d3d9.h>
#include <string>

namespace FastForward {
    // Called after config directories exist, outside DllMain.
    void Init(const std::wstring& basePath);
    void PollHotkey();
    unsigned CurrentSpeed();
    bool ShouldDisableVSync();
}
