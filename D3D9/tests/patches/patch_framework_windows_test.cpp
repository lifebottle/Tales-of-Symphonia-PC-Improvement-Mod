#include "patch_runtime.h"
#include "patch_api.h"
#include "ini_settings.h"
#include <windows.h>
#include <cassert>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iterator>
#include <limits>
#include <cmath>
using namespace PatchFramework;

Definition Fixture() {
    // The patch jumps into separately allocated code, which reads a configured
    // float from RW state, converts it to an integer, and returns to the caller.
    Definition p;p.id="fixture";p.version="1";p.configSection="Fixture";p.imageSize=4096;
    p.features={{1,0,"State"},{2,1,"Hook"}};
    auto bytes=[&](std::initializer_list<uint8_t> data){auto at=uint32_t(p.bytes.size());p.bytes.insert(p.bytes.end(),data);return at;};
    auto patch=bytes({0xe9,0,0,0,0}),expected=bytes({0x90,0x90,0x90,0x90,0x90});
    auto code=bytes({0xd9,0x05,0,0,0,0,0x83,0xec,4,0xdb,0x1c,0x24,0x58,0xc3});
    auto state=bytes({0,0,0,0}),guard=bytes({0x90});
    p.segments={{2,Kind::Patch,5,patch,5,32,expected,"entry"},{2,Kind::Code,14,code,14,0,0,"code"},{1,Kind::Data,4,state,4,0,0,"value"}};
    p.fixups={{0,1,1,0xfffffffc,2},{1,2,2,0,1}};
    p.parameters={{1,2,0,3,0,20,"Value"}};p.guards={{2,80,guard,1}};
    return p;
}

void IniDefaults() {
    // Preserve comments, unknown keys, existing spacing, and both newline styles.
    const std::string compact="; custom\n[One]\nx=keep\n[Two]\ny=2\n";
    const std::string spaced="; custom\n\n[One]\nx=keep\n\n[Two]\ny=2\n";
    assert(IniSettings::SeparateSections(compact)==spaced);
    assert(IniSettings::SeparateSections(spaced)==spaced);
    assert(IniSettings::SeparateSections(std::string("[One]\r\nx=1\r\n[Two]\r\n"))==
           "[One]\r\nx=1\r\n\r\n[Two]\r\n");
    wchar_t directory[MAX_PATH],path[MAX_PATH];
    assert(GetTempPathW(MAX_PATH,directory) && GetTempFileNameW(directory,L"ini",0,path));
    auto write=[&](const std::string& bytes) {
        FILE* file=_wfopen(path,L"wb");assert(file);
        assert(std::fwrite(bytes.data(),1,bytes.size(),file)==bytes.size());
        assert(std::fclose(file)==0);
    };
    auto read=[&]() {
        FILE* file=_wfopen(path,L"rb");assert(file);
        std::string bytes;char buffer[1024];size_t n;
        while ((n=std::fread(buffer,1,sizeof(buffer),file))) bytes.append(buffer,n);
        assert(std::fclose(file)==0);return bytes;
    };
    // A UTF-16 INI must retain its BOM and non-ASCII comment.
    const std::wstring unicode=L"\ufeff[One]\r\n; caf\u00e9\r\nx=1\r\n[Two]\r\ny=2\r\n";
    const std::wstring unicodeExpected=L"\ufeff[One]\r\n; caf\u00e9\r\nx=1\r\n\r\n[Two]\r\ny=2\r\n";
    write(std::string(reinterpret_cast<const char*>(unicode.data()),unicode.size()*sizeof(wchar_t)));
    assert(IniSettings::SeparateSections(path));
    assert(read()==std::string(reinterpret_cast<const char*>(unicodeExpected.data()),unicodeExpected.size()*sizeof(wchar_t)));

    write("[TextureProxy]\r\nEnableLogging=0\r\nCustom=keep\r\n");
    assert(IniSettings::WriteDefault(L"FastForward",L"Enabled",L"1",path));
    auto definition=Fixture();definition.parameters[0].value=0.20f;
    auto options=ReadOptions(definition,path);
    assert(options.enabled==0 && std::fabs(options.parameters[0]-0.20f)<0.0000001f);
    const auto generated=read();
    assert(generated.find("\r\n\r\n[FastForward]")!=std::string::npos);
    assert(generated.find("\r\n\r\n[Fixture]")!=std::string::npos);
    assert(generated.find("Value=0.20")!=std::string::npos);
    assert(generated.find("EnableLogging=0")!=std::string::npos && generated.find("Custom=keep")!=std::string::npos);
    ReadOptions(definition,path);
    assert(read()==generated); // Existing settings are not rewritten.
    definition.configSection="Another";definition.parameters[0].value=1.0f/3;
    const auto roundtrip=ReadOptions(definition,path);
    assert(std::memcmp(&roundtrip.parameters[0],&definition.parameters[0].value,sizeof(float))==0);
    assert(read().find("\r\n\r\n[Another]")!=std::string::npos);
    assert(DeleteFileW(path));
}
int main() {
    IniDefaults();
    std::string error;
    Definition shipped;
    assert(Load(L"D3D9/patches/battle-enhancements/patch.toml",shipped,error));
    assert(shipped.features.size()==5 && shipped.segments.size()==139);
    assert(!Load(L"D3D9/patches/battle-enhancements.json",shipped,error));

    auto p=Fixture(); assert(Validate(p,error));
    assert(Dependencies(p,2)==3);
    auto rejects=[&](Definition badDefinition) { assert(!Validate(badDefinition,error) && !error.empty()); };
    auto q=p; q.fixups[0].owner=99; rejects(q);
    q=p; q.fixups[0].target=-2; rejects(q);
    q=p; q.fixups[0].offset=3; rejects(q);
    q=p; q.fixups[0].type=100; rejects(q);
    q=p; q.features[1].dependencies=0; rejects(q);
    q=p; q.features[1].dependencies=4; rejects(q);
    q=p; q.features[1].key="state"; rejects(q);
    q=p; q.fixups.push_back(q.fixups[0]); rejects(q);
    q=p; q.segments[0].rva=4095; rejects(q);
    q=p; q.segments[1].size=0xffffffff; rejects(q);
    q=p; q.segments[0].bytes=0xffffffff; rejects(q);
    q=p; q.segments.push_back(q.segments[0]); rejects(q);
    q=p; q.parameters[0].segment=1; rejects(q);
    q=p; q.parameters[0].value=std::numeric_limits<float>::quiet_NaN(); rejects(q);
    q=p; q.guards[0].bytes=0xffffffff; rejects(q);

    auto* image=static_cast<uint8_t*>(VirtualAlloc(nullptr,4096,MEM_COMMIT|MEM_RESERVE,PAGE_EXECUTE_READWRITE));
    assert(image); std::memset(image,0x90,4096);
    Session session;
    assert(!Install(session,p,image,4096,{2,{}},error));
    assert(!Install(session,p,image,4096,{2,{20}},error));
    assert(!Install(session,p,image,4096,{4,{3}},error));
    q=p; q.imageBase=1; assert(!Install(session,q,image,4096,{2,{3}},error));
    image[80]=0;
    assert(!Install(session,p,image,4096,{2,{3}},error));
    assert(image[32]==0x90 && session.installed.empty());
    image[80]=0x90;
    assert(Install(session,p,image,4096,{2,{7}},error));
    using Function=int (*)();
    assert(reinterpret_cast<Function>(image+32)()==7);
    assert(!Install(session,p,image,4096,{2,{7}},error));
    // Reject guard/write collisions even if expected bytes would match.
    q=p; q.id="conflict"; q.segments[0].rva=80;
    assert(!Install(session,q,image,4096,{2,{7}},error));
    assert(error.find("conflicts")!=std::string::npos && image[80]==0x90);
    q=p; q.id="other"; q.segments[0].rva=100; q.guards[0].rva=150;
    assert(Install(session,q,image,4096,{2,{11}},error));
    assert(reinterpret_cast<Function>(image+100)()==11);
    VirtualFree(image,0,MEM_RELEASE);

    wchar_t dir[MAX_PATH], ini[MAX_PATH];
    assert(GetTempPathW(MAX_PATH,dir)); assert(GetTempFileNameW(dir,L"tpf",0,ini));
    auto options=ReadOptions(p,ini);
    assert(options.enabled==0 && options.parameters[0]==3);
    WritePrivateProfileStringW(L"Fixture",L"Hook",L"1",ini);
    WritePrivateProfileStringW(L"Fixture",L"Value",L"9",ini);
    options=ReadOptions(p,ini); assert(options.enabled==3 && options.parameters[0]==9);
    WritePrivateProfileStringW(L"Fixture",L"Value",L"nan",ini);
    assert(ReadOptions(p,ini).parameters[0]==3);
    assert(DeleteFileW(ini));

    const auto* api=TOSPatchGetAPI(2);
    assert(api && api->size==sizeof(TOSPatchAPI) && !TOSPatchGetAPI(1));
    char message[128]; wchar_t absolute[MAX_PATH];
    assert(GetFullPathNameW(L"D3D9/patches/battle-enhancements/patch.toml",MAX_PATH,absolute,nullptr));
    assert(api->validate(absolute,message,sizeof(message))==TOS_PATCH_OK && !message[0]);
    assert(api->validate(L"relative.json",message,1)==TOS_PATCH_ERROR && message[0]==0);
    assert(api->apply(absolute,L"relative.ini",message,sizeof(message))==TOS_PATCH_ERROR);
    std::puts("Patch framework passed: definition parsing, validation, dependencies, native relocations/parameters, conflicts, INI and C ABI.");
}
