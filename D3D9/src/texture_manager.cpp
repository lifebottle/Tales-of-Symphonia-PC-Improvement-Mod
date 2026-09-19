/*
 * D3D9 Texture Replacement Proxy - Texture Manager Implementation
 */

#include "texture_manager.h"
#include "dds_loader.h"
#include "logger.h"

#include <windows.h>
#include <cstdio>
#include <cwchar>
#include <algorithm>
#include <filesystem>

TextureManager::TextureManager()
    : m_dumpEnabled(false)
    , m_replaceEnabled(true)
    , m_loggingEnabled(true)
    , m_nativeTextureSize(true)
    , m_initialized(false) {
}

void TextureManager::Init(const std::wstring& basePath) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_initialized) return;

    m_basePath    = basePath;
    m_dumpPath    = basePath + L"\\textures\\dump";
    m_replacePath = basePath + L"\\textures\\replace";

    EnsureDirectories();
    LoadConfig();
    ScanReplacements();

    m_initialized = true;
    LOG("[TexMgr] Initialized. dump=%s, replace=%s, nativeSize=%s",
        m_dumpEnabled ? "ON" : "OFF",
        m_replaceEnabled ? "ON" : "OFF",
        m_nativeTextureSize ? "ON" : "OFF");
}

void TextureManager::LoadConfig() {
    // Load config from d3d9_config.ini if it exists
    std::wstring configPath = m_basePath + L"\\d3d9_config.ini";

    // Simple INI parsing
    wchar_t buf[64];

    // Check if file exists first
    DWORD attrs = GetFileAttributesW(configPath.c_str());
    if (attrs == INVALID_FILE_ATTRIBUTES) {
        // Create default config
        FILE* f = _wfopen(configPath.c_str(), L"w");
        if (f) {
            fprintf(f, "[TextureProxy]\n");
            fprintf(f, "; Set to 1 to dump all textures to textures/dump/ as DDS files\n");
            fprintf(f, "; The filename will be the CRC32 hash: e.g. A1B2C3D4.dds\n");
            fprintf(f, "DumpTextures=0\n\n");
            fprintf(f, "; Set to 1 to replace textures from textures/replace/\n");
            fprintf(f, "; Place your replacement DDS files named by CRC32 hash\n");
            fprintf(f, "ReplaceTextures=1\n\n");
            fprintf(f, "; Set to 1 to log texture hashes, replacements and dumps to tos_improvement_mod.log\n");
            fprintf(f, "EnableLogging=1\n\n");
            fprintf(f, "; Set to 1 to load D3DX textures at their native DDS resolution\n");
            fprintf(f, "; instead of the size the game requests (needed for hi-res PATCH textures)\n");
            fprintf(f, "NativeTextureSize=1\n");
            fclose(f);
        }
        return;
    }

    GetPrivateProfileStringW(L"TextureProxy", L"DumpTextures", L"0",
                             buf, 64, configPath.c_str());
    m_dumpEnabled = (_wtoi(buf) != 0);

    GetPrivateProfileStringW(L"TextureProxy", L"ReplaceTextures", L"1",
                             buf, 64, configPath.c_str());
    m_replaceEnabled = (_wtoi(buf) != 0);

    GetPrivateProfileStringW(L"TextureProxy", L"EnableLogging", L"1",
                             buf, 64, configPath.c_str());
    m_loggingEnabled = (_wtoi(buf) != 0);

    GetPrivateProfileStringW(L"TextureProxy", L"NativeTextureSize", L"1",
                             buf, 64, configPath.c_str());
    m_nativeTextureSize = (_wtoi(buf) != 0);
}

void TextureManager::EnsureDirectories() {
    // Create directory tree: textures/, textures/dump/, textures/replace/
    std::wstring texDir = m_basePath + L"\\textures";
    CreateDirectoryW(texDir.c_str(), nullptr);
    CreateDirectoryW(m_dumpPath.c_str(), nullptr);
    CreateDirectoryW(m_replacePath.c_str(), nullptr);
}

void TextureManager::ScanReplacements() {
    namespace fs = std::filesystem;
    m_replacementPaths.clear();

    int count = 0;
    std::error_code ec;

    for (const auto& entry : fs::recursive_directory_iterator(m_replacePath, ec)) {
        if (!entry.is_regular_file())
            continue;

        // Case-insensitive .dds extension check
        std::wstring ext = entry.path().extension().wstring();
        if (_wcsicmp(ext.c_str(), L".dds") != 0)
            continue;

        // Parse stem as hex CRC32: "A1B2C3D4"
        std::wstring stem = entry.path().stem().wstring();
        uint32_t crc32 = 0;
        if (swscanf(stem.c_str(), L"%X", &crc32) == 1) {
            m_replacementPaths[crc32] = entry.path().wstring();
            count++;
        }
    }

    if (count == 0)
        LOG("[TexMgr] No replacement textures found in textures/replace/");
    else
        LOG("[TexMgr] Scanned %d replacement texture(s)", count);
}

bool TextureManager::HasReplacement(uint32_t crc32) const {
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_replaceEnabled && m_replacementPaths.count(crc32) > 0;
}

std::wstring TextureManager::GetReplacementPath(uint32_t crc32) const {
    auto it = m_replacementPaths.find(crc32);
    if (it != m_replacementPaths.end())
        return it->second;
    // Fallback to root replace folder
    wchar_t filename[MAX_PATH];
    swprintf(filename, MAX_PATH, L"%s\\%08X.dds", m_replacePath.c_str(), crc32);
    return filename;
}

void TextureManager::DumpTexture(uint32_t crc32, IDirect3DTexture9* pTexture) {
    if (!m_dumpEnabled || !pTexture) return;

    wchar_t filepath[MAX_PATH];
    swprintf(filepath, MAX_PATH, L"%s\\%08X.dds", m_dumpPath.c_str(), crc32);

    // Check if already dumped
    if (GetFileAttributesW(filepath) != INVALID_FILE_ATTRIBUTES)
        return;

    // Get surface description
    D3DSURFACE_DESC desc;
    if (FAILED(pTexture->GetLevelDesc(0, &desc)))
        return;

    // Skip render targets and depth stencils
    if (desc.Usage & (D3DUSAGE_RENDERTARGET | D3DUSAGE_DEPTHSTENCIL))
        return;

    // Lock and write DDS
    // In D3D9Ex, DEFAULT pool textures can be locked directly.
    // In plain D3D9, only MANAGED/SYSTEMMEM can be locked.
    D3DLOCKED_RECT locked;
    if (SUCCEEDED(pTexture->LockRect(0, &locked, nullptr, D3DLOCK_READONLY))) {
        FILE* f = _wfopen(filepath, L"wb");
        if (f) {
            // DDS Magic
            uint32_t magic = DDS_MAGIC;
            fwrite(&magic, sizeof(magic), 1, f);

            // Build DDS header
            DDS_HEADER hdr = {};
            hdr.dwSize = 124;
            hdr.dwFlags = DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH | DDSD_PIXELFORMAT;
            hdr.dwHeight = desc.Height;
            hdr.dwWidth  = desc.Width;
            hdr.dwCaps   = DDSCAPS_TEXTURE;

            // Set pixel format based on D3DFORMAT
            hdr.ddspf.dwSize = sizeof(DDS_PIXELFORMAT);
            switch (desc.Format) {
                case D3DFMT_DXT1:
                    hdr.ddspf.dwFlags  = DDPF_FOURCC;
                    hdr.ddspf.dwFourCC = MAKEFOURCC('D','X','T','1');
                    hdr.dwFlags |= DDSD_LINEARSIZE;
                    hdr.dwPitchOrLinearSize = ((desc.Width + 3) / 4) * ((desc.Height + 3) / 4) * 8;
                    break;
                case D3DFMT_DXT3:
                    hdr.ddspf.dwFlags  = DDPF_FOURCC;
                    hdr.ddspf.dwFourCC = MAKEFOURCC('D','X','T','3');
                    hdr.dwFlags |= DDSD_LINEARSIZE;
                    hdr.dwPitchOrLinearSize = ((desc.Width + 3) / 4) * ((desc.Height + 3) / 4) * 16;
                    break;
                case D3DFMT_DXT5:
                    hdr.ddspf.dwFlags  = DDPF_FOURCC;
                    hdr.ddspf.dwFourCC = MAKEFOURCC('D','X','T','5');
                    hdr.dwFlags |= DDSD_LINEARSIZE;
                    hdr.dwPitchOrLinearSize = ((desc.Width + 3) / 4) * ((desc.Height + 3) / 4) * 16;
                    break;
                case D3DFMT_A8R8G8B8:
                    hdr.ddspf.dwFlags       = DDPF_RGB | DDPF_ALPHAPIXELS;
                    hdr.ddspf.dwRGBBitCount = 32;
                    hdr.ddspf.dwRBitMask    = 0x00FF0000;
                    hdr.ddspf.dwGBitMask    = 0x0000FF00;
                    hdr.ddspf.dwBBitMask    = 0x000000FF;
                    hdr.ddspf.dwABitMask    = 0xFF000000;
                    hdr.dwFlags |= DDSD_PITCH;
                    hdr.dwPitchOrLinearSize = desc.Width * 4;
                    break;
                case D3DFMT_X8R8G8B8:
                    hdr.ddspf.dwFlags       = DDPF_RGB;
                    hdr.ddspf.dwRGBBitCount = 32;
                    hdr.ddspf.dwRBitMask    = 0x00FF0000;
                    hdr.ddspf.dwGBitMask    = 0x0000FF00;
                    hdr.ddspf.dwBBitMask    = 0x000000FF;
                    hdr.ddspf.dwABitMask    = 0x00000000;
                    hdr.dwFlags |= DDSD_PITCH;
                    hdr.dwPitchOrLinearSize = desc.Width * 4;
                    break;
                default:
                    // Best-effort: write as 32-bit ARGB
                    hdr.ddspf.dwFlags       = DDPF_RGB | DDPF_ALPHAPIXELS;
                    hdr.ddspf.dwRGBBitCount = 32;
                    hdr.ddspf.dwRBitMask    = 0x00FF0000;
                    hdr.ddspf.dwGBitMask    = 0x0000FF00;
                    hdr.ddspf.dwBBitMask    = 0x000000FF;
                    hdr.ddspf.dwABitMask    = 0xFF000000;
                    hdr.dwFlags |= DDSD_PITCH;
                    hdr.dwPitchOrLinearSize = desc.Width * 4;
                    break;
            }

            fwrite(&hdr, sizeof(hdr), 1, f);

            // Write pixel data
            bool isCompressed = (desc.Format == D3DFMT_DXT1 || desc.Format == D3DFMT_DXT3 ||
                                desc.Format == D3DFMT_DXT5 || desc.Format == D3DFMT_DXT2 ||
                                desc.Format == D3DFMT_DXT4);
            if (isCompressed) {
                fwrite(locked.pBits, 1, hdr.dwPitchOrLinearSize, f);
            } else {
                uint32_t rowBytes = desc.Width * (hdr.ddspf.dwRGBBitCount / 8);
                uint8_t* src = static_cast<uint8_t*>(locked.pBits);
                for (uint32_t row = 0; row < desc.Height; row++) {
                    fwrite(src, 1, rowBytes, f);
                    src += locked.Pitch;
                }
            }
            fclose(f);
            if (m_loggingEnabled) {
                LOG("[TexMgr] Dumped texture %08X (%ux%u)", crc32, desc.Width, desc.Height);
            }
        }
        pTexture->UnlockRect(0);
    }
}

IDirect3DTexture9* TextureManager::GetReplacementTexture(IDirect3DDevice9* pDevice, uint32_t crc32) {
    std::lock_guard<std::mutex> lock(m_mutex);

    if (!m_replaceEnabled || !pDevice)
        return nullptr;

    // Check cache first
    auto it = m_textureCache.find(crc32);
    if (it != m_textureCache.end()) {
        it->second->AddRef();
        return it->second;
    }

    // Check if replacement exists
    if (m_replacementPaths.count(crc32) == 0)
        return nullptr;

    // Load the replacement DDS
    std::wstring path = GetReplacementPath(crc32);
    IDirect3DTexture9* pNewTex = nullptr;
    HRESULT hr = LoadDDSTexture(pDevice, path.c_str(), &pNewTex);

    if (SUCCEEDED(hr) && pNewTex) {
        // Cache it (the cache holds one reference)
        m_textureCache[crc32] = pNewTex;
        pNewTex->AddRef(); // One for cache, one for caller
        if (m_loggingEnabled) {
            LOG("[TexMgr] Loaded replacement texture %08X", crc32);
        }
        return pNewTex;
    }

    LOG("[TexMgr] Failed to load replacement texture %08X (hr=0x%08X)", crc32, hr);
    return nullptr;
}
