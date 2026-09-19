#pragma once

#include <d3d9.h>

namespace FastForward {
    // Draw to the primary backbuffer, outside the game's BeginScene/EndScene
    // pair. Uses the real device and restores the game's graphics state.
    // No persistent GPU resources, so device reset needs no cleanup.
    HRESULT DrawOverlay(IDirect3DDevice9* device, unsigned speed);
}
