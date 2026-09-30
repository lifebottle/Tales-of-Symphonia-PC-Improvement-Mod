/*
 * Tales of Symphonia PC Improvement Mod - D3DX9 IAT Hook Implementation
 *
 * Patches the game executable's Import Address Table to intercept calls to
 * D3DXCreateTextureFromFileInMemory and D3DXCreateTextureFromFileInMemoryEx.
 *
 * For each intercepted call we:
 *   1. Compute CRC32 of the entire source data blob (matching TSFix's hashing
 *      behaviour) and store the mapping IDirect3DTexture9* --> uint32_t crc32.
 *      SetTexture then looks up this map instead of trying to LockRect.
 *   2. (Ex variant, if NativeTextureSize is enabled) Force Width/Height to 0
 *      so D3DX creates the texture at the DDS file's native resolution instead
 *      of the size the game asks for. This lets higher-resolution DDS files
 *      shipped in PATCH folders load without being downscaled.
 */

#include "d3dx9_hook.h"
#include "crc32.h"
#include "texture_manager.h"
#include "logger.h"

#include <windows.h>
#include <mutex>
#include <unordered_map>
#include <cstdio>

// ---------------------------------------------------------------------------
// Internal state
// ---------------------------------------------------------------------------
static std::mutex                                          g_mapMutex;
static std::unordered_map<IDirect3DBaseTexture9*, uint32_t> g_texHashMap;
static bool                                                g_installed = false;

// ---------------------------------------------------------------------------
// Original function pointers (set by IAT patching)
// ---------------------------------------------------------------------------

// D3DXCreateTextureFromFileInMemoryEx
typedef HRESULT(WINAPI* PFN_D3DXCreateTextureFromFileInMemoryEx)(
    LPDIRECT3DDEVICE9   pDevice,
    LPCVOID             pSrcData,
    UINT                SrcDataSize,
    UINT                Width,
    UINT                Height,
    UINT                MipLevels,
    DWORD               Usage,
    D3DFORMAT           Format,
    D3DPOOL             Pool,
    DWORD               Filter,
    DWORD               MipFilter,
    D3DCOLOR            ColorKey,
    void*               pSrcInfo,       // D3DXIMAGE_INFO* — we don't need the type
    PALETTEENTRY*       pPalette,
    LPDIRECT3DTEXTURE9* ppTexture);

static PFN_D3DXCreateTextureFromFileInMemoryEx g_origCreateTexFromMemEx = nullptr;

// D3DXCreateTextureFromFileInMemory
typedef HRESULT(WINAPI* PFN_D3DXCreateTextureFromFileInMemory)(
    LPDIRECT3DDEVICE9   pDevice,
    LPCVOID             pSrcData,
    UINT                SrcDataSize,
    LPDIRECT3DTEXTURE9* ppTexture);

static PFN_D3DXCreateTextureFromFileInMemory g_origCreateTexFromMem = nullptr;

// ---------------------------------------------------------------------------
// Hook implementations
// ---------------------------------------------------------------------------
static HRESULT WINAPI Hook_D3DXCreateTextureFromFileInMemoryEx(
    LPDIRECT3DDEVICE9   pDevice,
    LPCVOID             pSrcData,
    UINT                SrcDataSize,
    UINT                Width,
    UINT                Height,
    UINT                MipLevels,
    DWORD               Usage,
    D3DFORMAT           Format,
    D3DPOOL             Pool,
    DWORD               Filter,
    DWORD               MipFilter,
    D3DCOLOR            ColorKey,
    void*               pSrcInfo,
    PALETTEENTRY*       pPalette,
    LPDIRECT3DTEXTURE9* ppTexture)
{
    // Hash the entire source blob — this is exactly what TSFix does
    uint32_t crc = 0;
    if (pSrcData && SrcDataSize > 0) {
        crc = crc32_compute(pSrcData, SrcDataSize);
    }

    // Skip dynamic / RT textures like TSFix does
    if (Usage & (D3DUSAGE_DYNAMIC | D3DUSAGE_RENDERTARGET)) {
        crc = 0;
    }

    // Let D3DX size the texture from the DDS header rather than the game's
    // requested dimensions (0 == "take from file").
    if (TextureManager::Instance().IsNativeTextureSizeEnabled()) {
        Width  = 0;
        Height = 0;
    }

    HRESULT hr = g_origCreateTexFromMemEx(
        pDevice, pSrcData, SrcDataSize,
        Width, Height, MipLevels, Usage, Format, Pool,
        Filter, MipFilter, ColorKey,
        pSrcInfo, pPalette, ppTexture);

    if (SUCCEEDED(hr) && ppTexture && *ppTexture && crc != 0) {
        std::lock_guard<std::mutex> lock(g_mapMutex);
        g_texHashMap[*ppTexture] = crc;
        if (TextureManager::Instance().IsLoggingEnabled()) {
            LOG("[D3DX] Tracked texture %p  CRC32=%08X  %ux%u  fmt=%d",
                *ppTexture, crc, Width, Height, Format);
        }
    }

    return hr;
}

static HRESULT WINAPI Hook_D3DXCreateTextureFromFileInMemory(
    LPDIRECT3DDEVICE9   pDevice,
    LPCVOID             pSrcData,
    UINT                SrcDataSize,
    LPDIRECT3DTEXTURE9* ppTexture)
{
    uint32_t crc = 0;
    if (pSrcData && SrcDataSize > 0) {
        crc = crc32_compute(pSrcData, SrcDataSize);
    }

    HRESULT hr = g_origCreateTexFromMem(pDevice, pSrcData, SrcDataSize, ppTexture);

    if (SUCCEEDED(hr) && ppTexture && *ppTexture && crc != 0) {
        std::lock_guard<std::mutex> lock(g_mapMutex);
        g_texHashMap[*ppTexture] = crc;
        if (TextureManager::Instance().IsLoggingEnabled()) {
            LOG("[D3DX] Tracked texture %p  CRC32=%08X  (non-Ex)",
                *ppTexture, crc);
        }
    }

    return hr;
}

// ---------------------------------------------------------------------------
// IAT Patching helpers
// ---------------------------------------------------------------------------

// Check if a pointer is safely readable
static bool IsReadable(const void* ptr, size_t size) {
    MEMORY_BASIC_INFORMATION mbi;
    if (VirtualQuery(ptr, &mbi, sizeof(mbi)) == 0) return false;
    if (mbi.State != MEM_COMMIT) return false;
    if (mbi.Protect & (PAGE_NOACCESS | PAGE_GUARD)) return false;
    return true;
}

// Patch a single IAT/thunk entry, returning the original function pointer.
static void* PatchThunkEntry(void* pThunkSlot, void* pNewFunc) {
    DWORD oldProtect = 0;
    if (!VirtualProtect(pThunkSlot, sizeof(ULONG_PTR), PAGE_READWRITE, &oldProtect)) {
        LOG("[IAT] VirtualProtect failed for thunk at %p (err=%u)", pThunkSlot, GetLastError());
        return nullptr;
    }
    auto* pSlot = reinterpret_cast<ULONG_PTR*>(pThunkSlot);
    void* pOrig = reinterpret_cast<void*>(*pSlot);
    *pSlot = reinterpret_cast<ULONG_PTR>(pNewFunc);
    VirtualProtect(pThunkSlot, sizeof(ULONG_PTR), oldProtect, &oldProtect);
    return pOrig;
}

// Scan the game's memory for IAT entries matching known d3dx9 function addresses.
// Works regardless of how the import table is structured.
static void HookByAddressScan(HMODULE hGame) {
    // Find which d3dx9 DLL is loaded (try d3dx9_43 down to d3dx9_24)
    HMODULE hD3DX = nullptr;
    char dllName[32];
    for (int ver = 43; ver >= 24; ver--) {
        _snprintf(dllName, sizeof(dllName), "d3dx9_%d.dll", ver);
        hD3DX = GetModuleHandleA(dllName);
        if (hD3DX) {
            LOG("[IAT] Found loaded module: %s", dllName);
            break;
        }
    }

    if (!hD3DX) {
        LOG("[IAT] No d3dx9_XX.dll is currently loaded — D3DX hooks not possible yet");
        return;
    }

    FARPROC pRealCreateTexEx = GetProcAddress(hD3DX, "D3DXCreateTextureFromFileInMemoryEx");
    FARPROC pRealCreateTex   = GetProcAddress(hD3DX, "D3DXCreateTextureFromFileInMemory");

    LOG("[IAT] Target addresses: CreateTexFromMemEx=%p, CreateTexFromMem=%p",
        pRealCreateTexEx, pRealCreateTex);

    if (!pRealCreateTexEx && !pRealCreateTex) {
        LOG("[IAT] D3DX module has no texture creation exports?!");
        return;
    }

    // Get the PE image size of the game EXE
    auto* pBase = reinterpret_cast<uint8_t*>(hGame);
    auto* pDos = reinterpret_cast<PIMAGE_DOS_HEADER>(pBase);
    if (pDos->e_magic != IMAGE_DOS_SIGNATURE) return;
    auto* pNT = reinterpret_cast<PIMAGE_NT_HEADERS>(pBase + pDos->e_lfanew);
    if (pNT->Signature != IMAGE_NT_SIGNATURE) return;

    DWORD imageSize = pNT->OptionalHeader.SizeOfImage;
    LOG("[IAT] Game image base=%p, size=0x%X", pBase, imageSize);

    // Scan all of the game's writable/readable sections for pointers matching
    // the d3dx9 function addresses. This catches regular IAT, delay IAT, and
    // any other indirection tables.
    int patchCount = 0;
    DWORD offset = 0;
    while (offset + sizeof(ULONG_PTR) <= imageSize) {
        // Check if the current page is readable before dereferencing
        MEMORY_BASIC_INFORMATION mbi;
        if (VirtualQuery(pBase + offset, &mbi, sizeof(mbi)) == 0 ||
            mbi.State != MEM_COMMIT ||
            (mbi.Protect & (PAGE_NOACCESS | PAGE_GUARD))) {
            // Skip to next page boundary
            DWORD pageEnd = static_cast<DWORD>(
                reinterpret_cast<uint8_t*>(mbi.BaseAddress) + mbi.RegionSize - pBase);
            offset = (pageEnd + (sizeof(ULONG_PTR) - 1)) & ~(sizeof(ULONG_PTR) - 1);
            continue;
        }

        // We know the region is readable — calculate how far we can safely scan
        DWORD regionEnd = static_cast<DWORD>(
            reinterpret_cast<uint8_t*>(mbi.BaseAddress) + mbi.RegionSize - pBase);
        if (regionEnd > imageSize) regionEnd = imageSize;

        for (; offset + sizeof(ULONG_PTR) <= regionEnd; offset += sizeof(ULONG_PTR)) {
            auto* pSlot = reinterpret_cast<ULONG_PTR*>(pBase + offset);
            ULONG_PTR val = *pSlot;

            if (pRealCreateTexEx && val == reinterpret_cast<ULONG_PTR>(pRealCreateTexEx)) {
                if (!g_origCreateTexFromMemEx) {
                    void* orig = PatchThunkEntry(pSlot,
                        reinterpret_cast<void*>(&Hook_D3DXCreateTextureFromFileInMemoryEx));
                    if (orig) {
                        g_origCreateTexFromMemEx =
                            reinterpret_cast<PFN_D3DXCreateTextureFromFileInMemoryEx>(orig);
                        LOG("[IAT] Hooked D3DXCreateTextureFromFileInMemoryEx at offset 0x%X (%p)",
                            offset, pSlot);
                        patchCount++;
                    }
                }
            }
            else if (pRealCreateTex && val == reinterpret_cast<ULONG_PTR>(pRealCreateTex)) {
                if (!g_origCreateTexFromMem) {
                    void* orig = PatchThunkEntry(pSlot,
                        reinterpret_cast<void*>(&Hook_D3DXCreateTextureFromFileInMemory));
                    if (orig) {
                        g_origCreateTexFromMem =
                            reinterpret_cast<PFN_D3DXCreateTextureFromFileInMemory>(orig);
                        LOG("[IAT] Hooked D3DXCreateTextureFromFileInMemory at offset 0x%X (%p)",
                            offset, pSlot);
                        patchCount++;
                    }
                }
            }

            // Once we've found both, stop scanning
            if (g_origCreateTexFromMemEx && g_origCreateTexFromMem) break;
        }

        if (g_origCreateTexFromMemEx && g_origCreateTexFromMem) break;
    }

    LOG("[IAT] Address scan complete: %d hook(s) installed", patchCount);
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------
namespace D3DXHook {

void Install() {
    if (g_installed) return;
    g_installed = true;

    LOG("[D3DX] Installing IAT hooks for D3DX texture creation...");

    HMODULE hGame = GetModuleHandleW(nullptr);
    if (!hGame) {
        LOG("[D3DX] Failed to get game module handle");
        return;
    }

    // Use the robust address-scan approach — works with regular imports,
    // delay imports, bound imports, and any other IAT layout.
    HookByAddressScan(hGame);

    if (!g_origCreateTexFromMemEx && !g_origCreateTexFromMem) {
        LOG("[D3DX] WARNING: No D3DX texture function pointers found. "
            "Texture hashing will fall back to LockRect.");
    } else {
        LOG("[D3DX] IAT hooks installed successfully.");
    }
}

uint32_t GetTextureHash(IDirect3DBaseTexture9* pTexture) {
    std::lock_guard<std::mutex> lock(g_mapMutex);
    auto it = g_texHashMap.find(pTexture);
    if (it != g_texHashMap.end())
        return it->second;
    return 0;
}

void RemoveTexture(IDirect3DBaseTexture9* pTexture) {
    std::lock_guard<std::mutex> lock(g_mapMutex);
    g_texHashMap.erase(pTexture);
}

void ClearAll() {
    std::lock_guard<std::mutex> lock(g_mapMutex);
    g_texHashMap.clear();
    LOG("[D3DX] Cleared all texture hash mappings.");
}

} // namespace D3DXHook
