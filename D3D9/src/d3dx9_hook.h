#pragma once
/*
 * Tales of Symphonia PC Improvement Mod - D3DX9 IAT Hook
 *
 * Hooks D3DXCreateTextureFromFileInMemory[Ex] via Import Address Table patching
 * to compute CRC32 of the entire in-memory DDS blob — matching TSFix's hashing —
 * and (optionally) to force textures to load at native DDS resolution.
 *
 * TSFix computes CRC32(pSrcData, SrcDataSize) on the raw DDS file blob passed
 * to D3DXCreateTextureFromFileInMemoryEx. This module does the same, so that
 * existing TSFix-compatible texture packs work without renaming.
 */

#include <d3d9.h>
#include <cstdint>

namespace D3DXHook {
    // Install IAT hooks for D3DX texture creation functions.
    // Call once after the device is created (d3dx9 DLL must be loaded).
    void Install();

    // Look up the TSFix-compatible CRC32 for a texture pointer.
    // Returns 0 if the texture was not created via a hooked D3DX call.
    uint32_t GetTextureHash(IDirect3DBaseTexture9* pTexture);

    // Remove a texture from tracking (e.g. on Release / Reset).
    void RemoveTexture(IDirect3DBaseTexture9* pTexture);

    // Clear all tracked textures (e.g. on device Reset).
    void ClearAll();
}
