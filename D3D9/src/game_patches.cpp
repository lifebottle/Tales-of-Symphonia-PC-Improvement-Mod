// ============================================================================
// Tales of Symphonia PC Improvement Mod — Game Memory Patches Implementation
//
// Binary patches for TOS.exe (Steam, non-ASLR, base 0x400000):
//   1. Multi-PATCH archive loader
//   2. I/O buffer size increase
// ============================================================================

#include "game_patches.h"
#include "logger.h"

#include <windows.h>
#include <cstdio>

// ============================================================================
// Game addresses
// ============================================================================

// Hook site: call to sub_625890 for PATCH tier (5 bytes: E8 xx xx xx xx)
static constexpr DWORD ADDR_HOOK_SITE      = 0x5A2177;

// sub_625890 — AddRootPath (ECX=path, stack=priorityOffset, caller cleanup)
static constexpr DWORD ADDR_SUB_625890     = 0x625890;

// sub_5AAE50 — ArchiveRootInit (ECX=path, EDX=separator, stack=priority, caller cleanup)
static constexpr DWORD ADDR_SUB_5AAE50     = 0x5AAE50;

// Empty string in .rdata, separator arg for sub_5AAE50
static constexpr DWORD ADDR_SEPARATOR      = 0x72EA39;

// Base priority global (always 0x10000 at runtime)
static constexpr DWORD ADDR_BASE_PRIORITY  = 0x1C3D0F0;

// I/O buffer size patch sites
static constexpr DWORD ADDR_IO_ALLOC_SIZE  = 0x5C1380;
static constexpr DWORD ADDR_IO_CAP_FIELD   = 0x5C13F0;
static constexpr DWORD IO_ORIG_SIZE        = 0x10000000;  // 256 MB
static constexpr DWORD IO_NEW_SIZE         = 0x40000000;  // 1 GB

// ============================================================================
// Game function call wrappers (portable inline ASM)
// ============================================================================

// CallAddRootPath: ECX=path, push priorityOffset, call, add esp 4
static void CallAddRootPath(const char* path, int priorityOffset)
{
#ifdef _MSC_VER
    DWORD fn = ADDR_SUB_625890;
    __asm {
        push priorityOffset
        mov  ecx, path
        call fn
        add  esp, 4
    }
#else
    __asm__ volatile (
        "pushl %[prio]\n\t"
        "call  *%[fn]\n\t"
        "addl  $4, %%esp\n\t"
        :
        : [prio] "r" (priorityOffset),
          "c" (path),
          [fn] "r" ((void*)(uintptr_t)ADDR_SUB_625890)
        : "eax", "edx", "memory", "cc"
    );
#endif
}

// CallArchiveRootInit: ECX=path, EDX=separator, push absPriority, call, add esp 4
static void CallArchiveRootInit(const char* path, const char* separator, int absPriority)
{
#ifdef _MSC_VER
    DWORD fn = ADDR_SUB_5AAE50;
    __asm {
        push absPriority
        mov  edx, separator
        mov  ecx, path
        call fn
        add  esp, 4
    }
#else
    __asm__ volatile (
        "pushl %[prio]\n\t"
        "call  *%[fn]\n\t"
        "addl  $4, %%esp\n\t"
        :
        : [prio] "r" (absPriority),
          "c" (path),
          "d" (separator),
          [fn] "r" ((void*)(uintptr_t)ADDR_SUB_5AAE50)
        : "eax", "memory", "cc"
    );
#endif
}

// ============================================================================
// Multi-PATCH archive loader
// ============================================================================

// Priority scheme:
//   PATCH R01 (normal): base + 0x3000
//   Custom folder 1:    base + 0x3010
//   Custom folder N:    base + 0x3000 + N*0x10
static void __cdecl LoadMultiPatchArchives(const char* patchPath)
{
    LOG("[Patch] patchPath = \"%s\"", patchPath);

    // Call original sub_625890 for normal R01 PATCH loading
    CallAddRootPath(patchPath, 0x3000);

    // Enumerate subdirectories
    char wildcard[MAX_PATH];
    sprintf(wildcard, "%s\\*", patchPath);

    WIN32_FIND_DATAA fd;
    HANDLE hFind = FindFirstFileA(wildcard, &fd);
    if (hFind == INVALID_HANDLE_VALUE) {
        LOG("[Patch] PATCH directory empty or not found, skipping");
        return;
    }

    const char* separator = (const char*)(uintptr_t)ADDR_SEPARATOR;
    int priorityOffset = 0x3010;

    do {
        if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
            continue;
        if (fd.cFileName[0] == '.') {
            if (fd.cFileName[1] == '\0') continue;
            if (fd.cFileName[1] == '.' && fd.cFileName[2] == '\0') continue;
        }

        char fullPath[MAX_PATH];
        sprintf(fullPath, "%s\\%s", patchPath, fd.cFileName);

        int absPriority = *(int*)(uintptr_t)ADDR_BASE_PRIORITY + priorityOffset;
        LOG("[Patch] Loading \"%s\" (priority 0x%X)", fullPath, absPriority);

        CallArchiveRootInit(fullPath, separator, absPriority);
        priorityOffset += 0x10;

    } while (FindNextFileA(hFind, &fd));

    FindClose(hFind);
    LOG("[Patch] Finished enumerating PATCH subdirectories");
}

// Install the PATCH hook: overwrite call at 0x5A2177 with our trampoline
static void InstallMultiPatchHook()
{
    LOG("[Patch] Installing multi-PATCH hook at 0x%X...", ADDR_HOOK_SITE);

    BYTE* tramp = (BYTE*)VirtualAlloc(NULL, 64, MEM_COMMIT | MEM_RESERVE,
                                       PAGE_EXECUTE_READWRITE);
    if (!tramp) {
        LOG("[Patch] FATAL: VirtualAlloc for trampoline failed (err=%u)", GetLastError());
        return;
    }

    tramp[0] = 0x51;  // push ecx
    tramp[1] = 0xE8;  // call rel32
    *(DWORD*)(tramp + 2) = (DWORD)(uintptr_t)&LoadMultiPatchArchives
                          - (DWORD)(uintptr_t)(tramp + 6);
    tramp[6] = 0x83;  // add esp, 4
    tramp[7] = 0xC4;
    tramp[8] = 0x04;
    tramp[9] = 0xC3;  // ret

    BYTE* hookSite = (BYTE*)(uintptr_t)ADDR_HOOK_SITE;
    DWORD oldProtect;
    VirtualProtect(hookSite, 5, PAGE_EXECUTE_READWRITE, &oldProtect);
    hookSite[0] = 0xE8;  // call rel32
    *(DWORD*)(hookSite + 1) = (DWORD)(uintptr_t)tramp
                             - (DWORD)(uintptr_t)(hookSite + 5);
    VirtualProtect(hookSite, 5, oldProtect, &oldProtect);

    LOG("[Patch] Multi-PATCH hook installed");
}

// ============================================================================
// I/O buffer size increase (256 MB → 1 GB)
// ============================================================================
static void IncreaseIOBufferSize()
{
    DWORD oldProt;

    DWORD* pAlloc = (DWORD*)(uintptr_t)ADDR_IO_ALLOC_SIZE;
    VirtualProtect(pAlloc, 4, PAGE_EXECUTE_READWRITE, &oldProt);
    if (*pAlloc == IO_ORIG_SIZE) {
        *pAlloc = IO_NEW_SIZE;
        LOG("[Patch] I/O alloc size: 0x%X → 0x%X (%u MB)",
            IO_ORIG_SIZE, IO_NEW_SIZE, IO_NEW_SIZE / (1024 * 1024));
    } else {
        LOG("[Patch] WARNING: unexpected value 0x%X at alloc site", *pAlloc);
    }
    VirtualProtect(pAlloc, 4, oldProt, &oldProt);

    DWORD* pCap = (DWORD*)(uintptr_t)ADDR_IO_CAP_FIELD;
    VirtualProtect(pCap, 4, PAGE_EXECUTE_READWRITE, &oldProt);
    if (*pCap == IO_ORIG_SIZE) {
        *pCap = IO_NEW_SIZE;
        LOG("[Patch] I/O capacity field: 0x%X → 0x%X", IO_ORIG_SIZE, IO_NEW_SIZE);
    } else {
        LOG("[Patch] WARNING: unexpected value 0x%X at cap site", *pCap);
    }
    VirtualProtect(pCap, 4, oldProt, &oldProt);
}

// ============================================================================
// VEH crash diagnosis (safety net)
// ============================================================================
static LONG CALLBACK VehHandler(PEXCEPTION_POINTERS pExInfo)
{
    DWORD code = pExInfo->ExceptionRecord->ExceptionCode;

    if (code == 0x40010006 || code == 0x40010007)
        return EXCEPTION_CONTINUE_SEARCH;

    if (code == 0xC0000005) {
        DWORD eip   = (DWORD)(uintptr_t)pExInfo->ExceptionRecord->ExceptionAddress;
        DWORD rwFlag = (DWORD)pExInfo->ExceptionRecord->ExceptionInformation[0];
        DWORD addr   = (DWORD)pExInfo->ExceptionRecord->ExceptionInformation[1];
        LOG("[VEH] ACCESS VIOLATION at EIP=0x%08X (%s 0x%08X)",
            eip, rwFlag ? "write" : "read", addr);
    }
    return EXCEPTION_CONTINUE_SEARCH;
}

// ============================================================================
// Public API
// ============================================================================
namespace GamePatches {

void InstallAll()
{
    LOG("[Patch] Installing game patches...");

    IncreaseIOBufferSize();
    InstallMultiPatchHook();

    AddVectoredExceptionHandler(1, VehHandler);
    LOG("[Patch] VEH installed for crash diagnosis");

    LOG("[Patch] All game patches installed");
}

} // namespace GamePatches
