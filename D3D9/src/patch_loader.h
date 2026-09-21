#pragma once
#include <string>

namespace PatchLoader {
// Called once from Direct3DCreate9[Ex], after the texture config exists.
void Init(const std::wstring& basePath);
}
