#pragma once
// ============================================================================
// Tales of Symphonia PC Improvement Mod — Game Memory Patches
//
// Binary patches applied to a running TOS.exe instance:
//   1. Multi-PATCH archive loader (enumerate PATCH subdirectories)
//   2. I/O buffer size increase (256 MB → 1 GB)
//
// All addresses are for the Steam release (non-ASLR, base 0x400000).
// ============================================================================

namespace GamePatches {
    // Install all game patches. Call from DllMain (DLL_PROCESS_ATTACH).
    void InstallAll();
}
