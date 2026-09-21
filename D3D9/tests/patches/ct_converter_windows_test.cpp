#include "patch_runtime.h"
#include <windows.h>
#include <cassert>
#include <cstdio>
#include <cstring>
using namespace PatchFramework;

// Optional acceptance tests use the user's converted TOS definitions. Only
// synthetic memory is executed; the game process and saves are never opened.
struct Registers { void* entry; uint32_t eax, ebx, ecx, edx, esi, edi; };
extern "C" void Invoke(Registers*);
__asm__(
    ".intel_syntax noprefix\n.text\n.global _Invoke\n_Invoke:\n"
    "pushad\nmov ebp,[esp+36]\n"
    "mov eax,[ebp+4]\nmov ebx,[ebp+8]\nmov ecx,[ebp+12]\n"
    "mov edx,[ebp+16]\nmov esi,[ebp+20]\nmov edi,[ebp+24]\n"
    "call DWORD PTR [ebp]\n"
    "mov [ebp+4],eax\nmov [ebp+8],ebx\nmov [ebp+12],ecx\n"
    "mov [ebp+16],edx\nmov [ebp+20],esi\nmov [ebp+24],edi\n"
    "popad\nret\n.att_syntax prefix\n");
uint32_t Address(const void* p) { return static_cast<uint32_t>(reinterpret_cast<uintptr_t>(p)); }
uint32_t Read32(const void* p) { uint32_t n; std::memcpy(&n,p,4); return n; }
void Put32(void* p,uint32_t n) { std::memcpy(p,&n,4); }
void Put16(void* p,uint16_t n) { std::memcpy(p,&n,2); }
uint16_t Read16(const void* p) { uint16_t n; std::memcpy(&n,p,2); return n; }

struct TestImage {
    Definition definition;
    Session session;
    uint8_t* bytes;
    explicit TestImage(const char* path) {
        std::string name(path),error;
        assert(Load(std::wstring(name.begin(),name.end()),definition,error));
        assert(definition.imageSize==0x2b00000);
        bytes=static_cast<uint8_t*>(VirtualAlloc(nullptr,definition.imageSize,
            MEM_COMMIT|MEM_RESERVE,PAGE_EXECUTE_READWRITE));
        assert(bytes);
        definition.imageBase=0;
        for (const auto& g:definition.guards)
            std::memcpy(bytes+g.rva,definition.bytes.data()+g.bytes,g.count);
        for (const auto& s:definition.segments)
            if (s.kind==Kind::Patch)
                std::memcpy(bytes+s.rva,definition.bytes.data()+s.expected,s.count);
        Options options;
        for (const auto& feature:definition.features) options.enabled |= feature.bit;
        for (const auto& parameter:definition.parameters) options.parameters.push_back(parameter.value);
        assert(Install(session,definition,bytes,definition.imageSize,options,error));
    }
    ~TestImage() { VirtualFree(bytes,0,MEM_RELEASE); }
};

void MinimumDamage(const char* path) {
    TestImage image(path);
    image.bytes[0x4028d]=0xc3; // Return to harness after the displaced instructions.
    uint32_t actor[3]={0,0,0x12345678};
    uint8_t target[0x28]{};
    for (int delta : {-100,0,25}) {
        Put32(target+0x24,1000);
        Registers r{image.bytes+0x40287,Address(target),static_cast<uint32_t>(delta),0,0,Address(actor),0};
        Invoke(&r);
        assert(Read32(target+0x24)==(delta ? 999u : 1000u));
        assert(r.ebx==(delta ? 0xffffffffu : 0u));
        assert(r.ecx==actor[2]);
    }
    std::puts("Minimum Damage: converted hook changes every nonzero HP delta to -1, including healing.");
}

void SpellQueue(const char* path) {
    TestImage image(path);
    image.bytes[0x2727b]=0xc3; // The original return destination, not a patch site.
    std::vector<uint8_t> character(0x13ac0),team(0x180000),arena(0x280000);
    Put32(image.bytes+0x6d2edc,Address(team.data()));
    auto* code=image.bytes + 0x2722e + 5 + static_cast<int32_t>(Read32(image.bytes + 0x2722e + 1));
    uint32_t spellGroup=0;
    for (const auto& f:image.definition.features)
        if (f.key=="SpellQueueFix") spellGroup=f.bit;
    assert(spellGroup);
    uint8_t* queue=nullptr;
    for (const auto& f:image.definition.fixups)
        if (f.target>=0 && f.type==1 && f.addend==0 &&
            image.definition.segments[f.owner].kind==Kind::Code &&
            image.definition.segments[f.owner].group==spellGroup &&
            image.definition.segments[f.target].kind==Kind::Data) {
            queue=reinterpret_cast<uint8_t*>(static_cast<uintptr_t>(Read32(code+f.offset)));
            break;
        }
    assert(queue && Read32(queue)==0);
    auto invoke=[&](uint32_t eax=0) {
        Registers r{image.bytes+0x2722e,eax,Address(character.data()),0,0,0,0};
        Invoke(&r);
        assert(r.ebx==Address(character.data()));
    };
    character[0x1b0]=0xc;
    character[0x1322]=1;
    Put16(character.data()+0x1be,2);
    invoke(1); // Early exit leaves the timer alone.
    assert(Read16(character.data()+0x1be)==2 && Read32(queue)==0);
    invoke();
    assert(Read16(character.data()+0x1be)==1 && Read32(queue)==0);
    invoke();
    assert(Read16(character.data()+0x1be)==0 && Read32(queue)==0);
    invoke(); // No team spell: zero timer stays zero, without enqueuing.
    assert(Read16(character.data()+0x1be)==0 && Read32(queue)==0);
    team[0x93ee]=1;
    invoke();
    assert(Read32(queue)==1);
    invoke(); // Existing character must not be added twice.
    assert(Read32(queue)==1);
    character[0x1322]=2;
    invoke();
    assert(Read32(queue)==0x201);
    character[0x1322]=1;
    character[0x1b0]=0;
    invoke(); // Stops chanting: remove first character and compact queue.
    assert(Read32(queue)==2);
    character[0x1322]=2;
    invoke();
    assert(Read32(queue)==0);
    // Native slots must work without an expanded buffer; slots 6..9 must read
    // private busy flags even when native storage contains the opposite value.
    character[0x1b0]=0xc;
    for(int slot:{0,1,2,6,7,8,9}) for(int busy=0;busy<=1;++busy) {
        character[0x13ab0]=static_cast<uint8_t>(slot);
        Put32(team.data()+0x16f950,slot<3 ? 0 : Address(arena.data()+0xd000));
        team[0x93ee + slot]=static_cast<uint8_t>(slot<3 ? busy : !busy);
        if(slot>=6) arena[0x4080+slot-6]=static_cast<uint8_t>(busy);
        for(int timer:{0,1,2}) {
            Put32(queue,0);
            Put16(character.data()+0x1be,static_cast<uint16_t>(timer));
            Registers r{image.bytes+0x2722e,0,Address(character.data()),0,0,0,0};
            Invoke(&r);
            if(timer<=1) assert(r.edi==Address(team.data()));
            assert(r.ebx==Address(character.data()));
            assert(Read32(queue)==(busy && timer<=1 ? 2u : 0u));
            assert(Read16(character.data()+0x1be)==(timer>1 ? timer-1 : busy ? 1 : 0));
        }
    }
    std::puts("Spell Queue: bypass, timer, queue insertion/removal, and all seven native/expanded slot lookups passed.");
}

int main(int argc,char** argv) {
    Definition definition;
    std::string error;
    // Produced from an actual CT XML + PE fixture by the shared CT importer.
    assert(Load(L"D3D9/tests/patches/fixtures/ct-converter/patch.toml", definition, error));
    assert(definition.features.size() == 1 && definition.segments.size() == 3);
    auto* image = static_cast<uint8_t*>(VirtualAlloc(nullptr, definition.imageSize,
        MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE));
    assert(image);
    definition.imageBase = 0; // The fixture has no fixed absolute game addresses.
    std::memset(image, 0x90, definition.imageSize);
    for (const auto& guard : definition.guards)
        std::memcpy(image + guard.rva, definition.bytes.data() + guard.bytes, guard.count);
    for (const auto& segment : definition.segments)
        if (segment.kind == Kind::Patch)
            std::memcpy(image + segment.rva, definition.bytes.data() + segment.expected, segment.count);
    using Function = int (*)();
    auto function = reinterpret_cast<Function>(image + 0x1010);
    assert(function() == 1);
    Session session;
    assert(Install(session, definition, image, definition.imageSize, {0, {}}, error));
    assert(function() == 1);
    assert(Install(session, definition, image, definition.imageSize, {1, {}}, error));
    // Runs converted hook -> separate RW value -> return to original RET.
    assert(function() == 7);
    assert(VirtualFree(image, 0, MEM_RELEASE));
    std::puts("CT conversion passed: script package load, disabled option, native hook, data relocation and return.");
    if (argc==3) { MinimumDamage(argv[1]); SpellQueue(argv[2]); }
    else assert(argc==1);
}
