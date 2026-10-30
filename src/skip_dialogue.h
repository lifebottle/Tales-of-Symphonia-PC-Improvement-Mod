#pragma once
#include "patch_runtime.h"

namespace FastForward::DialogueSkip {
// Built-in replacement for QoL FastText; the DLL owns the active flag.
bool Install();
void SetActive(bool active);
PatchFramework::Definition BuildDefinition(uintptr_t imageBase);
}
