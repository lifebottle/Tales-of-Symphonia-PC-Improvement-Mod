#include "patch_api.h"
#include "patch_runtime.h"
#include "logger.h"
#include <windows.h>
#include <cstring>
#include <exception>
#include <mutex>

namespace {
std::mutex sessionMutex;
PatchFramework::Session session;
bool Absolute(const wchar_t* p) {
    if (!p || !p[0] || !p[1]) return false;
    return (p[0]==L'\\' && p[1]==L'\\') ||
           (((p[0]>=L'A' && p[0]<=L'Z') || (p[0]>=L'a' && p[0]<=L'z')) &&
            p[1]==L':' && (p[2]==L'\\' || p[2]==L'/'));
}
uint32_t Result(const std::string& message,char* output,uint32_t capacity) {
    if (output && capacity) {
        const auto n=(std::min)(message.size(),size_t(capacity-1));
        std::memcpy(output,message.data(),n); output[n]=0;
    }
    return message.empty() ? TOS_PATCH_OK : TOS_PATCH_ERROR;
}
uint32_t TOS_PATCH_CALL ValidateFile(const wchar_t* path,char* output,uint32_t capacity) {
    try {
        std::string error;
        PatchFramework::Definition definition;
        if (!Absolute(path)) error="definition path must be absolute";
        else PatchFramework::Load(path,definition,error);
        return Result(error,output,capacity);
    } catch (const std::exception& e) { return Result(e.what(),output,capacity); }
    catch (...) { return Result("unexpected definition error",output,capacity); }
}
uint32_t TOS_PATCH_CALL ApplyFile(const wchar_t* path,const wchar_t* ini,char* output,uint32_t capacity) {
    try {
        std::lock_guard<std::mutex> lock(sessionMutex);
        std::string error;
        PatchFramework::Definition definition;
        if (!Absolute(path) || !Absolute(ini)) return Result("definition and INI paths must be absolute",output,capacity);
        if (!PatchFramework::Load(path,definition,error)) return Result(error,output,capacity);
        uint8_t* image=nullptr; size_t imageSize=0;
        if (!PatchFramework::ProcessImage(image,imageSize,error)) return Result(error,output,capacity);
        const auto options=PatchFramework::ReadOptions(definition,ini);
        if (!options.enabled) {
            LOG("[Patches] %s: disabled by config",definition.id.c_str());
            return Result("",output,capacity);
        }
        PatchFramework::Install(session,definition,image,imageSize,options,error);
        return Result(error,output,capacity);
    } catch (const std::exception& e) { return Result(e.what(),output,capacity); }
    catch (...) { return Result("unexpected install error",output,capacity); }
}
const TOSPatchAPI api{sizeof(TOSPatchAPI),TOS_PATCH_API_VERSION,ValidateFile,ApplyFile};
}
extern "C" const TOSPatchAPI* TOS_PATCH_CALL TOSPatchGetAPI(uint32_t version) {
    return version==TOS_PATCH_API_VERSION ? &api : nullptr;
}
