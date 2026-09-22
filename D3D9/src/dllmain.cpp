/*
 * Tales of Symphonia PC Improvement Mod - DLL Entry Point
 *
 * This is a proxy/wrapper d3d9.dll. When the game loads d3d9.dll, it loads
 * this DLL instead. We then load the REAL d3d9.dll from the system directory
 * and forward all calls through our wrappers.
 *
 * The proxy approach works on both native Windows AND Proton/Wine because
 * it relies on COM interface wrapping plus a small, self-contained IAT patch
 * rather than a detours library.
 *
 * What happens, in order:
 *   1. DllMain (DLL_PROCESS_ATTACH)
 *      -> Game patches are applied in-place to TOS.exe (multi-PATCH archive
 *         loader, 1 GB I/O buffer). This must happen before the game's own
 *         init code runs, so it is done here rather than lazily.
 *   2. Game calls Direct3DCreate9[Ex] -> returns our IDirect3D9[Ex] proxy
 *   3. Game calls CreateDevice[Ex]   -> returns our IDirect3DDevice9 proxy,
 *         which installs the D3DX IAT hook (d3dx9_hook.cpp)
 *   4. Game loads textures via D3DXCreateTextureFromFileInMemoryEx
 *      -> hook computes a TSFix-compatible CRC32 of the DDS blob and forces
 *         native DDS resolution (Width/Height = 0)
 *   5. Game calls SetTexture -> replacement from mods/textures/replace/ is swapped in
 */

#include <windows.h>
#include <d3d9.h>
#include <cstdio>
#include <string>

#include "d3d9_proxy.h"
#include "d3d9ex_proxy.h"
#include "texture_manager.h"
#include "archive_loader.h"
#include "fast_forward.h"
#include "patch_loader.h"
#include "logger.h"

// ============================================================================
// Globals
// ============================================================================
static HMODULE g_hRealD3D9 = nullptr;
static HMODULE g_hSelf     = nullptr;

// Real Direct3DCreate9 function pointer
typedef IDirect3D9* (WINAPI *Direct3DCreate9_t)(UINT SDKVersion);
static Direct3DCreate9_t g_pRealDirect3DCreate9 = nullptr;

// ============================================================================
// Forwarded export function pointers
// All of these must be resolved from the real d3d9.dll so the game
// doesn't crash when the loader tries to resolve its imports.
// ============================================================================
typedef HRESULT (WINAPI *Direct3DCreate9Ex_t)(UINT, IDirect3D9Ex**);
static Direct3DCreate9Ex_t g_pDirect3DCreate9Ex = nullptr;

// D3DPERF functions (PIX/profiler integration - many games import these)
typedef int     (WINAPI *D3DPERF_BeginEvent_t)(D3DCOLOR, LPCWSTR);
typedef int     (WINAPI *D3DPERF_EndEvent_t)(void);
typedef DWORD   (WINAPI *D3DPERF_GetStatus_t)(void);
typedef BOOL    (WINAPI *D3DPERF_QueryRepeatFrame_t)(void);
typedef void    (WINAPI *D3DPERF_SetMarker_t)(D3DCOLOR, LPCWSTR);
typedef void    (WINAPI *D3DPERF_SetOptions_t)(DWORD);
typedef void    (WINAPI *D3DPERF_SetRegion_t)(D3DCOLOR, LPCWSTR);
// On12 functions (Windows 10+, optional)
typedef HRESULT (WINAPI *Direct3DCreate9On12_t)(UINT, void*, UINT, IDirect3D9**);
typedef HRESULT (WINAPI *Direct3DCreate9On12Ex_t)(UINT, void*, UINT, IDirect3D9Ex**);
// Debug functions
typedef void    (WINAPI *DebugSetLevel_t)(DWORD);
typedef void    (WINAPI *DebugSetMute_t)(void);

static D3DPERF_BeginEvent_t         g_pD3DPERF_BeginEvent = nullptr;
static D3DPERF_EndEvent_t           g_pD3DPERF_EndEvent = nullptr;
static D3DPERF_GetStatus_t          g_pD3DPERF_GetStatus = nullptr;
static D3DPERF_QueryRepeatFrame_t   g_pD3DPERF_QueryRepeatFrame = nullptr;
static D3DPERF_SetMarker_t          g_pD3DPERF_SetMarker = nullptr;
static D3DPERF_SetOptions_t         g_pD3DPERF_SetOptions = nullptr;
static D3DPERF_SetRegion_t          g_pD3DPERF_SetRegion = nullptr;
static Direct3DCreate9On12_t        g_pDirect3DCreate9On12 = nullptr;
static Direct3DCreate9On12Ex_t      g_pDirect3DCreate9On12Ex = nullptr;
static DebugSetLevel_t              g_pDebugSetLevel = nullptr;
static DebugSetMute_t               g_pDebugSetMute = nullptr;

// ============================================================================
// Helper: Get the directory where this DLL lives
// ============================================================================
static std::wstring GetDLLDirectory() {
    wchar_t path[MAX_PATH];
    GetModuleFileNameW(g_hSelf, path, MAX_PATH);
    std::wstring dir(path);
    size_t pos = dir.find_last_of(L"\\/");
    if (pos != std::wstring::npos)
        dir = dir.substr(0, pos);
    return dir;
}

// ============================================================================
// Helper: Load the real system d3d9.dll
// Works on Windows (System32), Wine/Proton (wine d3d9 or native)
// ============================================================================
static bool LoadRealD3D9() {
    if (g_hRealD3D9) return true;

    wchar_t sysDir[MAX_PATH];
    GetSystemDirectoryW(sysDir, MAX_PATH);

    std::wstring realPath = std::wstring(sysDir) + L"\\d3d9.dll";
    g_hRealD3D9 = LoadLibraryW(realPath.c_str());

    if (!g_hRealD3D9) {
        LOG("[DLL] FATAL: Could not load real d3d9.dll from: %ls", realPath.c_str());
        return false;
    }

    g_pRealDirect3DCreate9 = (Direct3DCreate9_t)GetProcAddress(g_hRealD3D9, "Direct3DCreate9");
    if (!g_pRealDirect3DCreate9) {
        LOG("[DLL] FATAL: Could not find Direct3DCreate9 in real d3d9.dll");
        return false;
    }

    // Resolve all other exports (some may be NULL on older Windows — that's OK)
    g_pDirect3DCreate9Ex        = (Direct3DCreate9Ex_t)       GetProcAddress(g_hRealD3D9, "Direct3DCreate9Ex");
    g_pD3DPERF_BeginEvent       = (D3DPERF_BeginEvent_t)      GetProcAddress(g_hRealD3D9, "D3DPERF_BeginEvent");
    g_pD3DPERF_EndEvent         = (D3DPERF_EndEvent_t)        GetProcAddress(g_hRealD3D9, "D3DPERF_EndEvent");
    g_pD3DPERF_GetStatus        = (D3DPERF_GetStatus_t)       GetProcAddress(g_hRealD3D9, "D3DPERF_GetStatus");
    g_pD3DPERF_QueryRepeatFrame = (D3DPERF_QueryRepeatFrame_t)GetProcAddress(g_hRealD3D9, "D3DPERF_QueryRepeatFrame");
    g_pD3DPERF_SetMarker        = (D3DPERF_SetMarker_t)       GetProcAddress(g_hRealD3D9, "D3DPERF_SetMarker");
    g_pD3DPERF_SetOptions       = (D3DPERF_SetOptions_t)      GetProcAddress(g_hRealD3D9, "D3DPERF_SetOptions");
    g_pD3DPERF_SetRegion        = (D3DPERF_SetRegion_t)       GetProcAddress(g_hRealD3D9, "D3DPERF_SetRegion");
    g_pDirect3DCreate9On12      = (Direct3DCreate9On12_t)     GetProcAddress(g_hRealD3D9, "Direct3DCreate9On12");
    g_pDirect3DCreate9On12Ex    = (Direct3DCreate9On12Ex_t)   GetProcAddress(g_hRealD3D9, "Direct3DCreate9On12Ex");
    g_pDebugSetLevel            = (DebugSetLevel_t)           GetProcAddress(g_hRealD3D9, "DebugSetLevel");
    g_pDebugSetMute             = (DebugSetMute_t)            GetProcAddress(g_hRealD3D9, "DebugSetMute");

    LOG("[DLL] Loaded real d3d9.dll from: %ls", realPath.c_str());
    return true;
}

// ============================================================================
// Forwarded exports — these must exist so the Windows loader doesn't
// reject the DLL when resolving game imports from d3d9.dll.
// ============================================================================
extern "C" HRESULT WINAPI Direct3DCreate9Ex(UINT SDKVersion, IDirect3D9Ex** ppD3D) {
    LOG("[DLL] Direct3DCreate9Ex called (SDK version %u)", SDKVersion);
    LoadRealD3D9();
    if (!g_pDirect3DCreate9Ex) {
        LOG("[DLL] Direct3DCreate9Ex not available on this system");
        return E_NOTIMPL;
    }

    // Create the real D3D9Ex object
    IDirect3D9Ex* pRealD3D9Ex = nullptr;
    HRESULT hr = g_pDirect3DCreate9Ex(SDKVersion, &pRealD3D9Ex);
    if (FAILED(hr) || !pRealD3D9Ex) {
        LOG("[DLL] Real Direct3DCreate9Ex failed (hr=0x%08X)", hr);
        if (ppD3D) *ppD3D = nullptr;
        return hr;
    }

    // Initialize the texture manager
    TextureManager::Instance().Init(GetDLLDirectory());
    FastForward::Init(GetDLLDirectory());
    PatchLoader::Init(GetDLLDirectory());

    // Wrap it in our proxy so CreateDevice[Ex] returns our device proxy.
    LOG("[DLL] Wrapping IDirect3D9Ex with proxy");
    Direct3D9ExProxy* pProxy = new Direct3D9ExProxy(pRealD3D9Ex);
    *ppD3D = pProxy;
    return S_OK;
}

extern "C" int WINAPI D3DPERF_BeginEvent(D3DCOLOR col, LPCWSTR wszName) {
    LoadRealD3D9();
    if (g_pD3DPERF_BeginEvent) return g_pD3DPERF_BeginEvent(col, wszName);
    return 0;
}

extern "C" int WINAPI D3DPERF_EndEvent(void) {
    LoadRealD3D9();
    if (g_pD3DPERF_EndEvent) return g_pD3DPERF_EndEvent();
    return 0;
}

extern "C" DWORD WINAPI D3DPERF_GetStatus(void) {
    LoadRealD3D9();
    if (g_pD3DPERF_GetStatus) return g_pD3DPERF_GetStatus();
    return 0;
}

extern "C" BOOL WINAPI D3DPERF_QueryRepeatFrame(void) {
    LoadRealD3D9();
    if (g_pD3DPERF_QueryRepeatFrame) return g_pD3DPERF_QueryRepeatFrame();
    return FALSE;
}

extern "C" void WINAPI D3DPERF_SetMarker(D3DCOLOR col, LPCWSTR wszName) {
    LoadRealD3D9();
    if (g_pD3DPERF_SetMarker) g_pD3DPERF_SetMarker(col, wszName);
}

extern "C" void WINAPI D3DPERF_SetOptions(DWORD dwOptions) {
    LoadRealD3D9();
    if (g_pD3DPERF_SetOptions) g_pD3DPERF_SetOptions(dwOptions);
}

extern "C" void WINAPI D3DPERF_SetRegion(D3DCOLOR col, LPCWSTR wszName) {
    LoadRealD3D9();
    if (g_pD3DPERF_SetRegion) g_pD3DPERF_SetRegion(col, wszName);
}

extern "C" HRESULT WINAPI Direct3DCreate9On12(UINT SDKVersion, void* pOverrideList, UINT NumOverrides, IDirect3D9** ppD3D) {
    LoadRealD3D9();
    if (g_pDirect3DCreate9On12) return g_pDirect3DCreate9On12(SDKVersion, pOverrideList, NumOverrides, ppD3D);
    return E_NOTIMPL;
}

extern "C" HRESULT WINAPI Direct3DCreate9On12Ex(UINT SDKVersion, void* pOverrideList, UINT NumOverrides, IDirect3D9Ex** ppD3D) {
    LoadRealD3D9();
    if (g_pDirect3DCreate9On12Ex) return g_pDirect3DCreate9On12Ex(SDKVersion, pOverrideList, NumOverrides, ppD3D);
    return E_NOTIMPL;
}

extern "C" void WINAPI DebugSetLevel(DWORD dw) {
    LoadRealD3D9();
    if (g_pDebugSetLevel) g_pDebugSetLevel(dw);
}

extern "C" void WINAPI DebugSetMute(void) {
    LoadRealD3D9();
    if (g_pDebugSetMute) g_pDebugSetMute();
}

// ============================================================================
// Exported: Direct3DCreate9
// This is what the game calls. We return our proxy IDirect3D9.
// ============================================================================
// Note: Export is handled by d3d9.def, not __declspec(dllexport)
// We must match the declaration in d3d9.h (no dllexport/dllimport)
IDirect3D9* WINAPI Direct3DCreate9(UINT SDKVersion) {
    LOG("[DLL] Direct3DCreate9 called (SDK version %u)", SDKVersion);

    if (!LoadRealD3D9()) {
        LOG("[DLL] FATAL: Cannot load real d3d9.dll");
        return nullptr;
    }

    IDirect3D9* pRealD3D9 = g_pRealDirect3DCreate9(SDKVersion);
    if (!pRealD3D9) {
        LOG("[DLL] FATAL: Real Direct3DCreate9 returned NULL");
        return nullptr;
    }

    // Initialize the texture manager
    TextureManager::Instance().Init(GetDLLDirectory());
    FastForward::Init(GetDLLDirectory());
    PatchLoader::Init(GetDLLDirectory());

    // Return our proxy
    return new Direct3D9Proxy(pRealD3D9);
}

// ============================================================================
// DLL Entry Point
// ============================================================================
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
        case DLL_PROCESS_ATTACH:
            g_hSelf = hModule;
            DisableThreadLibraryCalls(hModule);
            Logger::Instance().Init("tos_improvement_mod.log");
            LOG("[DLL] ============================================");
            LOG("[DLL] Tales of Symphonia PC Improvement Mod loaded");
            LOG("[DLL] d3d9.dll proxy: multi-PATCH loader + texture replacement");
            LOG("[DLL] Compatible with Windows and Proton/Wine");
            LOG("[DLL] ============================================");

            // Install binary patches (multi-PATCH loader, I/O buffer increase).
            // This runs before any game code, patching TOS.exe in-place.
            ArchiveLoader::InstallAll(hModule);

            // Real d3d9.dll is loaded lazily on first API call, NOT here.
            // Loading it during DllMain can cause the loader to resolve
            // the game's imports against the system d3d9 instead of ours.
            break;

        case DLL_PROCESS_DETACH:
            LOG("[DLL] Proxy DLL unloading");
            if (g_hRealD3D9) {
                FreeLibrary(g_hRealD3D9);
                g_hRealD3D9 = nullptr;
            }
            Logger::Instance().Shutdown();
            break;
    }
    return TRUE;
}
