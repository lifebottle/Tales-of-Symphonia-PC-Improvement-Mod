/*
 * D3D9 Texture Replacement Proxy - Texture Manager Implementation
 */

#include "texture_manager.h"
#include "dds_loader.h"
#include "long_path.h"
#include "logger.h"

#include <windows.h>
#include <cstdio>
#include <cwchar>
#include <algorithm>

TextureManager::TextureManager()
    : m_dumpEnabled(false)
    , m_replaceEnabled(true)
    , m_loggingEnabled(false)
    , m_nativeTextureSize(true)
    , m_initialized(false) {
}

void TextureManager::Init(const std::wstring& basePath) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_initialized) return;

    m_basePath    = basePath;
    m_dumpPath    = basePath + L"\\mods\\textures\\dump";
    m_replacePath = basePath + L"\\mods\\textures\\replace";

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
            fprintf(f, "DumpTextures=0\n");
            fprintf(f, "ReplaceTextures=1\n");
            fprintf(f, "EnableLogging=0\n");
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

    GetPrivateProfileStringW(L"TextureProxy", L"EnableLogging", L"0",
                             buf, 64, configPath.c_str());
    m_loggingEnabled = (_wtoi(buf) != 0);

    GetPrivateProfileStringW(L"TextureProxy", L"NativeTextureSize", L"1",
                             buf, 64, configPath.c_str());
    m_nativeTextureSize = (_wtoi(buf) != 0);
}

void TextureManager::EnsureDirectories() {
    // Create the mods parent before the texture directories.
    std::wstring modsDir = m_basePath + L"\\mods";
    CreateDirectoryW(modsDir.c_str(), nullptr);
    std::wstring texDir = modsDir + L"\\textures";
    CreateDirectoryW(texDir.c_str(), nullptr);
    CreateDirectoryW(m_dumpPath.c_str(), nullptr);
    CreateDirectoryW(m_replacePath.c_str(), nullptr);
}

bool TextureManager::ScanReplacements() {
    std::unordered_map<uint32_t, std::wstring> paths;

    int count = 0;
    std::error_code ec;

    const std::wstring scanPath = ExtendedFilePath(m_replacePath, ec);
    if (ec) {
        LOG("[TexMgr] Cannot resolve replacement path \"%ls\": %s (code=%d)",
            m_replacePath.c_str(), ec.message().c_str(), ec.value());
        return false;
    }

    // Use Win32 enumeration directly: CRT-backed filesystem implementations
    // can still reject extended-length paths during traversal or file status.
    const auto scanDirectory = [&](const auto& self, const std::wstring& directory) -> void {
        WIN32_FIND_DATAW data{};
        HANDLE handle = FindFirstFileW((directory + L"\\*").c_str(), &data);
        if (handle == INVALID_HANDLE_VALUE) {
            const DWORD error = GetLastError();
            if (error != ERROR_FILE_NOT_FOUND) // An empty directory is valid.
                ec = std::error_code(error, std::system_category());
            return;
        }
        struct FindGuard {
            HANDLE handle;
            ~FindGuard() { FindClose(handle); }
        } guard{handle};

        do {
            if (wcscmp(data.cFileName, L".") == 0 || wcscmp(data.cFileName, L"..") == 0)
                continue;

            const std::wstring path = directory + L"\\" + data.cFileName;
            if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                // Match the previous scanner's default: do not follow directory
                // links, which could introduce cycles or leave the replace tree.
                if (!(data.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT))
                    self(self, path);
                if (ec)
                    return;
                continue;
            }

            const std::wstring filename = data.cFileName;
            const size_t dot = filename.find_last_of(L'.');
            if (dot == std::wstring::npos || _wcsicmp(filename.c_str() + dot, L".dds") != 0)
                continue;

            const std::wstring stem = filename.substr(0, dot);
            uint32_t crc32 = 0;
            if (swscanf(stem.c_str(), L"%X", &crc32) == 1) {
                paths[crc32] = path;
                count++;
            }
        } while (FindNextFileW(handle, &data));

        const DWORD error = GetLastError();
        if (error != ERROR_NO_MORE_FILES)
            ec = std::error_code(error, std::system_category());
    };
    scanDirectory(scanDirectory, scanPath);

    if (ec) {
        LOG("[TexMgr] Replacement scan failed under \"%ls\": %s "
            "(code=%d); keeping previous textures",
            scanPath.c_str(), ec.message().c_str(), ec.value());
        return false;
    }
    m_replacementPaths.swap(paths);

    if (count == 0)
        LOG("[TexMgr] No replacement textures found in mods/textures/replace/");
    else
        LOG("[TexMgr] Scanned %d replacement texture(s)", count);
    return true;
}

bool TextureManager::ReloadReplacements() {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_initialized || !m_replaceEnabled || !ScanReplacements())
        return false;

    for (auto& pair : m_textureCache)
        pair.second->Release();
    m_textureCache.clear();
    return true;
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
    wchar_t filename[13]; // Eight hex digits, ".dds", and terminating null.
    swprintf(filename, 13, L"%08X.dds", crc32);
    return m_replacePath + L"\\" + filename;
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
