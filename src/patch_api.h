#pragma once
#include <stdint.h>
#include <wchar.h>

// Versioned C ABI for a future loader. Resolve TOSPatchGetAPI with GetProcAddress.
// Call on an ordinary thread after game initialization, never from DllMain.
// All paths must be absolute. Hooks last until process exit; no hot reload/unload.
// Files contain native code and must be trusted like DLL mods.
#ifdef _WIN32
#define TOS_PATCH_CALL __cdecl
#else
#define TOS_PATCH_CALL
#endif
#ifdef __cplusplus
extern "C" {
#endif
#define TOS_PATCH_API_VERSION 2u
#define TOS_PATCH_OK 0u
#define TOS_PATCH_ERROR 1u
// Output is NUL-terminated UTF-8/ASCII, caller-owned; NULL/zero is allowed.
typedef struct TOSPatchAPI {
    uint32_t size;
    uint32_t version;
    uint32_t (TOS_PATCH_CALL *validate)(const wchar_t* manifest_path, char* error, uint32_t capacity);
    // INI selects feature keys/parameters in the section declared by the definition.
    // Missing settings are written with safe defaults (all features off).
    uint32_t (TOS_PATCH_CALL *apply)(const wchar_t* manifest_path, const wchar_t* ini_path,
                                    char* error, uint32_t capacity);
} TOSPatchAPI;
const TOSPatchAPI* TOS_PATCH_CALL TOSPatchGetAPI(uint32_t version);
#ifdef __cplusplus
}
#endif
