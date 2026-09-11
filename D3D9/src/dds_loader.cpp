/*
 * D3D9 Texture Replacement Proxy - DDS Loader Implementation
 * Handles DDS file parsing and texture creation without D3DX dependency.
 * Supports DXT1-5, uncompressed ARGB/XRGB, and common formats.
 */

#include "dds_loader.h"
#include "logger.h"
#include <cstdio>
#include <cstring>
#include <vector>
#include <algorithm>

// DDS structs/constants are now in dds_loader.h

static D3DFORMAT GetD3DFormat(const DDS_PIXELFORMAT& pf) {
    if (pf.dwFlags & DDPF_FOURCC) {
        switch (pf.dwFourCC) {
            case MAKEFOURCC('D','X','T','1'): return D3DFMT_DXT1;
            case MAKEFOURCC('D','X','T','2'): return D3DFMT_DXT2;
            case MAKEFOURCC('D','X','T','3'): return D3DFMT_DXT3;
            case MAKEFOURCC('D','X','T','4'): return D3DFMT_DXT4;
            case MAKEFOURCC('D','X','T','5'): return D3DFMT_DXT5;
            default:
                LOG("[DDS] Unsupported FourCC: 0x%08X", pf.dwFourCC);
                return D3DFMT_UNKNOWN;
        }
    }

    if (pf.dwFlags & DDPF_RGB) {
        switch (pf.dwRGBBitCount) {
            case 32:
                if (pf.dwABitMask == 0xFF000000 && pf.dwRBitMask == 0x00FF0000 &&
                    pf.dwGBitMask == 0x0000FF00 && pf.dwBBitMask == 0x000000FF) {
                    return (pf.dwFlags & DDPF_ALPHAPIXELS) ? D3DFMT_A8R8G8B8 : D3DFMT_X8R8G8B8;
                }
                if (pf.dwRBitMask == 0x000000FF && pf.dwGBitMask == 0x0000FF00 &&
                    pf.dwBBitMask == 0x00FF0000) {
                    return (pf.dwFlags & DDPF_ALPHAPIXELS) ? D3DFMT_A8B8G8R8 : D3DFMT_X8B8G8R8;
                }
                break;
            case 24:
                if (pf.dwRBitMask == 0xFF0000 && pf.dwGBitMask == 0x00FF00 &&
                    pf.dwBBitMask == 0x0000FF) {
                    return D3DFMT_R8G8B8;
                }
                break;
            case 16:
                if (pf.dwRBitMask == 0xF800 && pf.dwGBitMask == 0x07E0 &&
                    pf.dwBBitMask == 0x001F) {
                    return D3DFMT_R5G6B5;
                }
                if (pf.dwRBitMask == 0x7C00 && pf.dwGBitMask == 0x03E0 &&
                    pf.dwBBitMask == 0x001F) {
                    return (pf.dwFlags & DDPF_ALPHAPIXELS) ? D3DFMT_A1R5G5B5 : D3DFMT_X1R5G5B5;
                }
                if (pf.dwRBitMask == 0x0F00 && pf.dwGBitMask == 0x00F0 &&
                    pf.dwBBitMask == 0x000F) {
                    return (pf.dwFlags & DDPF_ALPHAPIXELS) ? D3DFMT_A4R4G4B4 : D3DFMT_X4R4G4B4;
                }
                break;
        }
    }

    if (pf.dwFlags & DDPF_LUMINANCE) {
        if (pf.dwRGBBitCount == 8)
            return D3DFMT_L8;
        if (pf.dwRGBBitCount == 16) {
            if (pf.dwFlags & DDPF_ALPHAPIXELS)
                return D3DFMT_A8L8;
            return D3DFMT_L16;
        }
    }

    if (pf.dwFlags & DDPF_ALPHA) {
        if (pf.dwRGBBitCount == 8)
            return D3DFMT_A8;
    }

    LOG("[DDS] Unsupported pixel format: flags=0x%X, bpp=%u", pf.dwFlags, pf.dwRGBBitCount);
    return D3DFMT_UNKNOWN;
}

static bool IsCompressed(D3DFORMAT fmt) {
    return fmt == D3DFMT_DXT1 || fmt == D3DFMT_DXT2 ||
           fmt == D3DFMT_DXT3 || fmt == D3DFMT_DXT4 || fmt == D3DFMT_DXT5;
}

static uint32_t GetBlockSize(D3DFORMAT fmt) {
    return (fmt == D3DFMT_DXT1) ? 8 : 16;
}

static uint32_t GetBitsPerPixel(D3DFORMAT fmt) {
    switch (fmt) {
        case D3DFMT_A8R8G8B8: case D3DFMT_X8R8G8B8:
        case D3DFMT_A8B8G8R8: case D3DFMT_X8B8G8R8:
            return 32;
        case D3DFMT_R8G8B8:
            return 24;
        case D3DFMT_R5G6B5: case D3DFMT_A1R5G5B5: case D3DFMT_X1R5G5B5:
        case D3DFMT_A4R4G4B4: case D3DFMT_X4R4G4B4: case D3DFMT_A8L8:
        case D3DFMT_L16:
            return 16;
        case D3DFMT_A8: case D3DFMT_L8:
            return 8;
        default:
            return 0;
    }
}

static uint32_t CalcMipSize(uint32_t width, uint32_t height, D3DFORMAT fmt) {
    if (IsCompressed(fmt)) {
        uint32_t bw = (std::max)(1u, (width + 3) / 4);
        uint32_t bh = (std::max)(1u, (height + 3) / 4);
        return bw * bh * GetBlockSize(fmt);
    }
    uint32_t bpp = GetBitsPerPixel(fmt);
    return (std::max)(1u, width) * (std::max)(1u, height) * bpp / 8;
}

HRESULT LoadDDSTexture(IDirect3DDevice9* pDevice,
                       const wchar_t*    filePath,
                       IDirect3DTexture9** ppTexture) {
    if (!pDevice || !filePath || !ppTexture)
        return E_INVALIDARG;

    *ppTexture = nullptr;

    // Open file - use _wfopen for wide path support (works on both Windows and Wine)
    FILE* f = _wfopen(filePath, L"rb");
    if (!f) {
        LOG("[DDS] Cannot open file");
        return E_FAIL;
    }

    // Read magic
    uint32_t magic = 0;
    if (fread(&magic, sizeof(magic), 1, f) != 1 || magic != DDS_MAGIC) {
        LOG("[DDS] Invalid DDS magic");
        fclose(f);
        return E_FAIL;
    }

    // Read header
    DDS_HEADER header;
    if (fread(&header, sizeof(header), 1, f) != 1 || header.dwSize != 124) {
        LOG("[DDS] Invalid DDS header");
        fclose(f);
        return E_FAIL;
    }

    D3DFORMAT format = GetD3DFormat(header.ddspf);
    if (format == D3DFMT_UNKNOWN) {
        fclose(f);
        return E_FAIL;
    }

    uint32_t width  = header.dwWidth;
    uint32_t height = header.dwHeight;
    uint32_t mipCount = (header.dwFlags & DDSD_MIPMAPCOUNT) ? header.dwMipMapCount : 1;
    if (mipCount == 0) mipCount = 1;

    // Create the texture.
    // Strategy: create a SYSTEMMEM staging texture (always lockable), fill it,
    // then try to create a DEFAULT texture and UpdateTexture into it.
    // If DEFAULT creation or UpdateTexture fails (plain D3D9), just use the
    // SYSTEMMEM texture directly. If SYSTEMMEM fails, try MANAGED (plain D3D9).
    IDirect3DTexture9* pStaging = nullptr;
    HRESULT hr = pDevice->CreateTexture(width, height, mipCount, 0, format,
                                         D3DPOOL_SYSTEMMEM, &pStaging, nullptr);
    if (FAILED(hr)) {
        // SYSTEMMEM failed — try MANAGED (plain D3D9 fallback)
        hr = pDevice->CreateTexture(width, height, mipCount, 0, format,
                                     D3DPOOL_MANAGED, &pStaging, nullptr);
        if (FAILED(hr)) {
            LOG("[DDS] CreateTexture failed: 0x%08X (fmt=%d, %ux%u, mips=%u)",
                hr, format, width, height, mipCount);
            fclose(f);
            return hr;
        }
        // MANAGED textures are directly usable — no need for UpdateTexture later
    }

    // Fill each mip level into the staging texture
    uint32_t mipW = width;
    uint32_t mipH = height;
    for (uint32_t mip = 0; mip < mipCount; mip++) {
        uint32_t dataSize = CalcMipSize(mipW, mipH, format);

        D3DLOCKED_RECT locked;
        hr = pStaging->LockRect(mip, &locked, nullptr, 0);
        if (FAILED(hr)) {
            LOG("[DDS] LockRect failed for mip %u: 0x%08X", mip, hr);
            pStaging->Release();
            fclose(f);
            return hr;
        }

        if (IsCompressed(format)) {
            // Compressed: read the whole block in one shot
            if (fread(locked.pBits, 1, dataSize, f) != dataSize) {
                LOG("[DDS] Failed to read compressed mip %u data", mip);
                pStaging->UnlockRect(mip);
                pStaging->Release();
                fclose(f);
                return E_FAIL;
            }
        } else {
            // Uncompressed: read row by row to handle pitch differences
            uint32_t bpp = GetBitsPerPixel(format);
            uint32_t srcPitch = (std::max)(1u, mipW) * bpp / 8;
            uint8_t* dst = static_cast<uint8_t*>(locked.pBits);

            for (uint32_t row = 0; row < (std::max)(1u, mipH); row++) {
                if (fread(dst, 1, srcPitch, f) != srcPitch) {
                    LOG("[DDS] Failed to read uncompressed mip %u row %u", mip, row);
                    pStaging->UnlockRect(mip);
                    pStaging->Release();
                    fclose(f);
                    return E_FAIL;
                }
                dst += locked.Pitch;
            }
        }

        pStaging->UnlockRect(mip);

        mipW = (std::max)(1u, mipW / 2);
        mipH = (std::max)(1u, mipH / 2);
    }

    fclose(f);

    // Check what pool the staging texture ended up in
    D3DSURFACE_DESC stagingDesc;
    pStaging->GetLevelDesc(0, &stagingDesc);

    if (stagingDesc.Pool == D3DPOOL_SYSTEMMEM) {
        // Try to promote to a DEFAULT pool texture via UpdateTexture
        // (required for D3D9Ex — SYSTEMMEM textures can't be set as source for rendering)
        IDirect3DTexture9* pGPUTex = nullptr;
        hr = pDevice->CreateTexture(width, height, mipCount, 0, format,
                                     D3DPOOL_DEFAULT, &pGPUTex, nullptr);
        if (SUCCEEDED(hr)) {
            hr = pDevice->UpdateTexture(pStaging, pGPUTex);
            if (SUCCEEDED(hr)) {
                // Success — use the GPU texture, release staging
                pStaging->Release();
                *ppTexture = pGPUTex;
                return S_OK;
            }
            // UpdateTexture failed — fall through to use staging
            LOG("[DDS] UpdateTexture failed: 0x%08X, using SYSTEMMEM texture", hr);
            pGPUTex->Release();
        } else {
            LOG("[DDS] DEFAULT CreateTexture failed: 0x%08X, using SYSTEMMEM texture", hr);
        }
    }

    // Use the staging/managed texture directly
    *ppTexture = pStaging;
    return S_OK;
}

HRESULT LoadDDSTextureA(IDirect3DDevice9* pDevice,
                        const char*       filePath,
                        IDirect3DTexture9** ppTexture) {
    // Convert narrow to wide string
    int len = MultiByteToWideChar(CP_UTF8, 0, filePath, -1, nullptr, 0);
    if (len <= 0) return E_FAIL;

    std::vector<wchar_t> wpath(len);
    MultiByteToWideChar(CP_UTF8, 0, filePath, -1, wpath.data(), len);
    return LoadDDSTexture(pDevice, wpath.data(), ppTexture);
}
