#pragma once
/*
 * D3D9 Texture Replacement Proxy - Texture Manager
 * Scans for replacement textures, computes CRC32 hashes, handles injection.
 * 
 * Directory layout:
 *   <game_dir>/mods/textures/dump/     - dumped original textures (CRC32.dds)
 *   <game_dir>/mods/textures/replace/  - replacement textures (CRC32.dds)
 *
 * Workflow:
 *   1. On texture creation/load, compute CRC32 of the source data
 *   2. Optionally dump the texture to mods/textures/dump/<crc32>.dds
 *   3. Check if mods/textures/replace/<crc32>.dds exists
 *   4. If it does, load and return the replacement texture instead
 */

#include <d3d9.h>
#include <cstdint>
#include <string>
#include <unordered_map>
#include <mutex>

class TextureManager {
public:
    static TextureManager& Instance() {
        static TextureManager instance;
        return instance;
    }

    // Initialize - call after the real device is available
    // basePath is the game directory (where d3d9.dll lives)
    void Init(const std::wstring& basePath);

    // Scan the replace/ folder and build a set of available replacement CRC32s
    void ScanReplacements();

    // Check if a replacement texture exists for the given CRC32
    bool HasReplacement(uint32_t crc32) const;

    // Get the file path for a replacement texture
    std::wstring GetReplacementPath(uint32_t crc32) const;

    // Dump texture data to the dump/ folder
    void DumpTexture(uint32_t crc32, IDirect3DTexture9* pTexture);

    // Try to replace a texture. Returns the replacement texture (AddRef'd) or nullptr.
    IDirect3DTexture9* GetReplacementTexture(IDirect3DDevice9* pDevice, uint32_t crc32);

    // Settings
    bool IsDumpEnabled() const { return m_dumpEnabled; }
    void SetDumpEnabled(bool val) { m_dumpEnabled = val; }
    bool IsReplaceEnabled() const { return m_replaceEnabled; }
    void SetReplaceEnabled(bool val) { m_replaceEnabled = val; }
    bool IsLoggingEnabled() const { return m_loggingEnabled; }
    void SetLoggingEnabled(bool val) { m_loggingEnabled = val; }
    bool IsNativeTextureSizeEnabled() const { return m_nativeTextureSize; }
    void SetNativeTextureSizeEnabled(bool val) { m_nativeTextureSize = val; }

private:
    TextureManager();
    ~TextureManager() = default;
    TextureManager(const TextureManager&) = delete;
    TextureManager& operator=(const TextureManager&) = delete;

    void LoadConfig();
    void EnsureDirectories();

    std::wstring m_basePath;
    std::wstring m_dumpPath;
    std::wstring m_replacePath;

    bool m_dumpEnabled;
    bool m_replaceEnabled;
    bool m_loggingEnabled;
    bool m_nativeTextureSize;
    bool m_initialized;

    // Map of CRC32 values to their full file paths
    std::unordered_map<uint32_t, std::wstring> m_replacementPaths;

    // Cache of loaded replacement textures (CRC32 -> texture)
    std::unordered_map<uint32_t, IDirect3DTexture9*> m_textureCache;

    mutable std::mutex m_mutex;
};
