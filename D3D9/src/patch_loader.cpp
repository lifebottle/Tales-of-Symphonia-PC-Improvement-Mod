#include "patch_loader.h"
#include "patch_api.h"
#include "logger.h"
#include <windows.h>
#include <algorithm>
#include <exception>
#include <mutex>
#include <vector>

// Discover and apply patch packages at startup.
namespace PatchLoader {
void Init(const std::wstring& basePath) {
    static std::once_flag once;
    std::call_once(once,[&] {
        try {
            const auto ini=basePath+L"\\d3d9_config.ini";
            if (GetPrivateProfileIntW(L"Patches",L"AutoLoad",1,ini.c_str())==0) {
                LOG("[Patches] Automatic loading disabled; API remains available"); return;
            }
            const auto directory=basePath+L"\\patches\\";
            WIN32_FIND_DATAW entry{};
            HANDLE find=FindFirstFileW((directory+L"*").c_str(),&entry);
            if (find==INVALID_HANDLE_VALUE) { LOG("[Patches] No patch packages found"); return; }
            std::vector<std::wstring> files;
            do {
                const std::wstring name=entry.cFileName;
                if ((entry.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) && name!=L"." && name!=L"..") {
                    auto manifest=name+L"\\patch.toml";
                    if (GetFileAttributesW((directory+manifest).c_str())!=INVALID_FILE_ATTRIBUTES) files.push_back(manifest);
                } else if (name.size()>=5 && _wcsicmp(name.c_str()+name.size()-5,L".json")==0)
                    LOG("[Patches] Legacy JSON %ls ignored; install the readable patch package and remove the old JSON",name.c_str());
            } while (FindNextFileW(find,&entry));
            FindClose(find);
            std::sort(files.begin(),files.end());
            const auto* api=TOSPatchGetAPI(TOS_PATCH_API_VERSION);
            for (const auto& file:files) {
                char error[512]{};
                if (api->apply((directory+file).c_str(),ini.c_str(),error,sizeof(error))!=TOS_PATCH_OK)
                    LOG("[Patches] %ls rejected: %s",file.c_str(),error);
            }
        } catch (const std::exception& e) { LOG("[Patches] Startup failed: %s",e.what()); }
    });
}
}
