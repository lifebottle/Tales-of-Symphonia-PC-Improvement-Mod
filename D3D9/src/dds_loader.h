#pragma once
/*
 * D3D9 Texture Replacement Proxy - DDS Loader
 * Loads DDS textures directly without requiring D3DX.
 * This is critical for Proton/Wine compatibility where D3DX may not be available.
 */

#include <d3d9.h>
#include <cstdint>
#include <string>

// ============================================================================
// DDS File Format Constants & Structures
// ============================================================================

#define DDS_MAGIC 0x20534444 // "DDS "

#define DDSD_CAPS        0x1
#define DDSD_HEIGHT      0x2
#define DDSD_WIDTH       0x4
#define DDSD_PITCH       0x8
#define DDSD_PIXELFORMAT 0x1000
#define DDSD_MIPMAPCOUNT 0x20000
#define DDSD_LINEARSIZE  0x80000
#define DDSD_DEPTH       0x800000

#define DDPF_ALPHAPIXELS 0x1
#define DDPF_ALPHA       0x2
#define DDPF_FOURCC      0x4
#define DDPF_RGB         0x40
#define DDPF_LUMINANCE   0x20000

#define DDSCAPS_COMPLEX  0x8
#define DDSCAPS_MIPMAP   0x400000
#define DDSCAPS_TEXTURE  0x1000

#ifndef MAKEFOURCC
#define MAKEFOURCC(ch0, ch1, ch2, ch3) \
    ((uint32_t)(uint8_t)(ch0)        | ((uint32_t)(uint8_t)(ch1) << 8) | \
     ((uint32_t)(uint8_t)(ch2) << 16) | ((uint32_t)(uint8_t)(ch3) << 24))
#endif

#pragma pack(push, 1)

struct DDS_PIXELFORMAT {
    uint32_t dwSize;
    uint32_t dwFlags;
    uint32_t dwFourCC;
    uint32_t dwRGBBitCount;
    uint32_t dwRBitMask;
    uint32_t dwGBitMask;
    uint32_t dwBBitMask;
    uint32_t dwABitMask;
};

struct DDS_HEADER {
    uint32_t        dwSize;
    uint32_t        dwFlags;
    uint32_t        dwHeight;
    uint32_t        dwWidth;
    uint32_t        dwPitchOrLinearSize;
    uint32_t        dwDepth;
    uint32_t        dwMipMapCount;
    uint32_t        dwReserved1[11];
    DDS_PIXELFORMAT ddspf;
    uint32_t        dwCaps;
    uint32_t        dwCaps2;
    uint32_t        dwCaps3;
    uint32_t        dwCaps4;
    uint32_t        dwReserved2;
};

#pragma pack(pop)

// ============================================================================
// DDS Loader API
// ============================================================================

// Load a DDS file from disk and create an IDirect3DTexture9
// Returns S_OK on success, error HRESULT on failure
HRESULT LoadDDSTexture(IDirect3DDevice9* pDevice,
                       const wchar_t*    filePath,
                       IDirect3DTexture9** ppTexture);

// Load a DDS file from disk and create an IDirect3DTexture9 (narrow string version)
HRESULT LoadDDSTextureA(IDirect3DDevice9* pDevice,
                        const char*       filePath,
                        IDirect3DTexture9** ppTexture);
