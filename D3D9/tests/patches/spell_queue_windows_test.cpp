// Execute the maintained queue package and real spell-slot hooks in synthetic memory.
// No game process, installation, or save files are modified.
#include "patch_script.h"
#include <windows.h>
#include <algorithm>
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <set>
using namespace PatchFramework;

uint32_t Address(const void* p) { return static_cast<uint32_t>(reinterpret_cast<uintptr_t>(p)); }
uint32_t Read32(const void* p) { uint32_t n; std::memcpy(&n,p,4); return n; }
void Put32(void* p,uint32_t n) { std::memcpy(p,&n,4); }
uint16_t Read16(const void* p) { uint16_t n; std::memcpy(&n,p,2); return n; }
void Put16(void* p,uint16_t n) { std::memcpy(p,&n,2); }
void Check(bool ok,const std::string& error) {
    if(!ok) { std::fprintf(stderr,"%s\n",error.c_str()); std::abort(); }
}

struct Registers {
    void* entry;
    uint32_t eax=0,ebx=0,ecx=0x12345678,edx=0x23456789,esi=0x3456789a,edi=0x456789ab;
    uint32_t flags=0x202,stack=0,actor=0,target=0;
};
extern "C" void InvokeQueue(Registers*);
extern "C" void InvokeEnd(Registers*);
// EBP holds the harness frame; both paths must preserve it and balance the stack.
__asm__(
    ".intel_syntax noprefix\n.text\n.global _InvokeQueue\n_InvokeQueue:\n"
    "pushad\nmov ebp,[esp+36]\nmov [ebp+32],esp\n"
    "mov eax,[ebp+4]\nmov ebx,[ebp+8]\nmov ecx,[ebp+12]\n"
    "mov edx,[ebp+16]\nmov esi,[ebp+20]\nmov edi,[ebp+24]\n"
    "push DWORD PTR [ebp+28]\npopfd\ncall DWORD PTR [ebp]\njmp capture_queue_regs\n"
    ".global _InvokeEnd\n_InvokeEnd:\n"
    "pushad\nmov ebp,[esp+36]\nmov [ebp+32],esp\n"
    "mov eax,[ebp+4]\nmov ebx,[ebp+8]\nmov ecx,[ebp+12]\n"
    "mov edx,[ebp+16]\nmov esi,[ebp+20]\nmov edi,[ebp+24]\n"
    "push DWORD PTR [ebp+40]\npush DWORD PTR [ebp+36]\n"
    "push DWORD PTR [ebp+28]\npopfd\ncall DWORD PTR [ebp]\n"
    "lea esp,[esp+8]\n"
    "capture_queue_regs:\npushfd\npop DWORD PTR [ebp+28]\n"
    "mov [ebp+4],eax\nmov [ebp+8],ebx\nmov [ebp+12],ecx\n"
    "mov [ebp+16],edx\nmov [ebp+20],esi\nmov [ebp+24],edi\n"
    "mov eax,esp\nsub eax,[ebp+32]\nmov [ebp+32],eax\n"
    "popad\nret\n.att_syntax prefix\n");

void Seed(uint8_t* image,const Definition& d) {
    for(const auto& g:d.guards) std::memcpy(image+g.rva,d.bytes.data()+g.bytes,g.count);
    for(const auto& s:d.segments) if(s.kind==Kind::Patch)
        std::memcpy(image+s.rva,d.bytes.data()+s.expected,s.count);
}
std::vector<uint8_t*> Bases(uint8_t* image,const Definition& d,uint32_t enabled) {
    std::vector<uint8_t*> bases(d.segments.size());
    for(size_t i=0;i<bases.size();++i)
        if(d.segments[i].kind==Kind::Patch && (d.segments[i].group&enabled)) bases[i]=image+d.segments[i].rva;
    for(size_t pass=0;pass<bases.size();++pass) for(const auto& f:d.fixups) {
        if(!bases[f.owner] || f.target<0 || bases[f.target]) continue;
        uint32_t value=Read32(bases[f.owner]+f.offset)-f.addend;
        if(f.type==2) value+=Address(bases[f.owner]+f.offset); else assert(f.type==1);
        bases[f.target]=reinterpret_cast<uint8_t*>(static_cast<uintptr_t>(value));
    }
    return bases;
}
void Release(const Definition& d,const std::vector<uint8_t*>& bases) {
    // The installer packs all code segments into one allocation and all state
    // segments into another. Free each allocation once, not each interior symbol.
    std::set<void*> allocations;
    for(size_t i=0;i<bases.size();++i) if(d.segments[i].kind!=Kind::Patch && bases[i]) {
        MEMORY_BASIC_INFORMATION info{};
        assert(VirtualQuery(bases[i],&info,sizeof(info)) && info.State==MEM_COMMIT);
        allocations.insert(info.AllocationBase);
    }
    for(auto* allocation:allocations) assert(VirtualFree(allocation,0,MEM_RELEASE));
}

// Original +280F0..+28127, verified against the supported TOS.exe. Execute the
// complete epilogue so that the moved hook and busy-clear hook really compose.
const uint8_t endFunction[]={
    0x55,0x8b,0xec,0x51,0x56,0x8b,0x75,0x08,0x0f,0xb6,0x86,0xb0,0x3a,0x01,0x00,
    0x50,0xe8,0xdb,0x5d,0x04,0x00,0x0f,0xb6,0x8e,0xb0,0x3a,0x01,0x00,
    0x8b,0x15,0xdc,0x2e,0xad,0x00,0x8b,0x45,0x0c,0x83,0xc4,0x04,
    0xc6,0x84,0x11,0xee,0x93,0x00,0x00,0x00,0x80,0x60,0x35,0xfc,0x5e,0x59,0x5d,0xc3
};

unsigned Exercise(const PatchScript::Compiled& queuePackage,const PatchScript::Compiled& slotsPackage,
                  int party,int enemy,bool slotsFirst,bool allFeatures) {
    auto d=queuePackage.definition, slots=slotsPackage.definition;
    d.imageBase=slots.imageBase=0;
    uint32_t queueFeature=0, enabled=0;
    for(const auto& f:d.features) {
        if(f.key=="SpellQueueFix") queueFeature=f.bit;
        if(allFeatures) enabled|=f.bit;
    }
    assert(queueFeature);
    enabled|=queueFeature;
    const Options options{enabled,{0.2f}};
    const auto queueSymbol=queuePackage.symbols.at("SpellQueueFix:queuelist");
    // Test-only padding around the original four-byte allocation detects spills
    // on either side, without changing any queue instructions or branch logic.
    assert(d.segments[queueSymbol.first].size==4 && queueSymbol.second==0);
    d.segments[queueSymbol.first].size+=32;
    for(auto& f:d.fixups) if(f.target==queueSymbol.first) f.addend+=16;

    auto* image=static_cast<uint8_t*>(VirtualAlloc(nullptr,d.imageSize,MEM_COMMIT|MEM_RESERVE,PAGE_EXECUTE_READWRITE));
    assert(image);
    Seed(image,slots); Seed(image,d);
    std::memcpy(image+0x280f0,endFunction,sizeof(endFunction));
    std::vector<uint8_t> pristine(image,image+d.imageSize);
    Session session; std::string error;
    Check(Install(session,d,image,d.imageSize,{0,{0.2f}},error),error);
    assert(session.installed.empty());
    // Check every overwritten byte plus a guarded return destination. Rejection
    // must leave all bytes and session ownership unchanged.
    std::vector<uint32_t> corrupt{0x2727b};
    for(const auto& s:d.segments) if(s.kind==Kind::Patch && (s.group&queueFeature))
        for(uint32_t i=0;i<s.count;++i) corrupt.push_back(s.rva+i);
    for(auto rva:corrupt) {
        image[rva]^=1;
        assert(!Install(session,d,image,d.imageSize,options,error));
        assert(session.installed.empty() && session.ranges.empty());
        image[rva]^=1;
        assert(std::memcmp(image,pristine.data(),d.imageSize)==0);
    }
    if(party && slotsFirst) Check(Install(session,slots,image,slots.imageSize,{1,{float(party),float(enemy)}},error),error);
    Check(Install(session,d,image,d.imageSize,options,error),error);
    if(party && !slotsFirst) Check(Install(session,slots,image,slots.imageSize,{1,{float(party),float(enemy)}},error),error);
    auto bases=Bases(image,d,enabled);
    auto* queue=bases[queueSymbol.first]+16;
    std::memset(queue-16,0xa5,16); std::memset(queue+4,0x5a,16);
    assert(Read32(queue)==0);
    auto sentinels=[&]() {
        for(int i=0;i<16;++i) assert(queue[i-16]==0xa5 && queue[i+4]==0x5a);
    };
    std::vector<uint8_t> team(0x180000),actor(0x14000),target(0x80);
    Put32(image+0x6d2edc,Address(team.data()));
    std::vector<uint8_t*> slotBases;
    uint8_t* arena=nullptr;
    if(party) {
        slotBases=Bases(image,slots,1);
        auto sym=slotsPackage.symbols.at("helpers:prepare_battle");
        auto prepare=reinterpret_cast<uint32_t (*)(void*)>(slotBases[sym.first]+sym.second);
        auto arenaSym=slotsPackage.symbols.at("state:arena");
        arena=slotBases[arenaSym.first]+arenaSym.second;
        assert(prepare(team.data())==Address(arena+0xd000));
        assert(*reinterpret_cast<float*>(arena+0x403c)==party);
        assert(*reinterpret_cast<float*>(arena+0x4040)==enemy);
    }
    // Only replace external game work: return from the queue continuation and
    // the VFX purge. Relocate the untouched native absolute battle-global load.
    image[0x2727b]=0xc3; image[0x6dee0]=0xc3;
    Put32(image+0x2810e,Address(image+0x6d2edc));
    actor[0x1b0]=0xc; actor[0x1322]=1;
    auto invoke=[&](uint32_t eax=0) {
        Registers r{image+0x2722e}; r.eax=eax; r.ebx=Address(actor.data());
        InvokeQueue(&r);
        assert(r.stack==0 && r.ebx==Address(actor.data()) && r.esi==0x3456789a);
        sentinels(); return r;
    };
    auto finish=[&]() {
        target[0x35]=0xff;
        Registers r{image+0x280f0}; r.ebx=0x11223344;
        r.actor=Address(actor.data()); r.target=Address(target.data());
        InvokeEnd(&r);
        assert(r.stack==0 && r.ebx==0x11223344 && r.ecx==0x12345678);
        assert(r.esi==0x3456789a && r.edi==0x456789ab);
        assert(r.eax==Address(target.data()) && r.edx==Address(team.data()));
        assert(target[0x35]==0xfc && (r.flags&0xc5)==0x84); // AND flags: SF/PF set, ZF/CF clear.
        sentinels();
    };
    unsigned cases=0;
    for(int slot:{0,1,2,6,7,8,9}) {
        if(!party && slot>=6) continue;
        actor[0x13ab0]=static_cast<uint8_t>(slot);
        auto* busy=slot<3 ? team.data()+0x93ee + slot : arena+0x4080+slot-6;
        for(int active:{0,1}) for(int timer:{0,1,2,0xffff}) {
            team[0x93ee + slot]=static_cast<uint8_t>(!active);
            *busy=static_cast<uint8_t>(active);
            Put32(queue,0); Put16(actor.data()+0x1be,static_cast<uint16_t>(timer));
            auto r=invoke();
            assert(Read16(actor.data()+0x1be)==(timer>1 ? timer-1 : active ? 1 : 0));
            assert(Read32(queue)==(active && timer<=1 ? 1u : 0u));
            if(timer<=1) assert(r.edi==Address(team.data()));
            ++cases;
        }
        // Completion must clear exactly this slot plus the global queue lock.
        std::fill(team.begin()+0x93ee,team.begin()+0x93ee + 10,0x7b);
        if(arena) std::memset(arena+0x4080,0x6c,4);
        *busy=1; Put32(queue,0x01030201);
        finish();
        assert(*busy==0 && Read32(queue)==0x00030201);
        for(int i=0;i<10;++i) assert(team[0x93ee + i]==(i==slot && slot<3 ? 0 : 0x7b));
        if(arena) for(int i=0;i<4;++i) assert(arena[0x4080+i]==(i==slot-6 ? 0 : 0x6c));
    }

    actor[0x13ab0]=0; actor[0x1322]=1; team[0x93ee]=1;
    Put32(queue,0); Put16(actor.data()+0x1be,7);
    auto bypass=invoke(1);
    assert(Read16(actor.data()+0x1be)==7 && Read32(queue)==0);
    assert(bypass.eax==1 && bypass.ecx==0x12345678 && bypass.edx==0x23456789 && bypass.edi==0x456789ab);
    Put16(actor.data()+0x1be,0);
    for(int id:{1,2,3,2,4}) { actor[0x1322]=static_cast<uint8_t>(id); invoke(); }
    assert(Read32(queue)==0x00030201); // Full queue, duplicate, and overflow attempt.
    actor[0x1322]=2; actor[0x1b0]=0; invoke();
    assert(Read32(queue)==0x00000103); // Preserve this version's existing reorder order.
    actor[0x1322]=3; invoke(); assert(Read32(queue)==1);
    actor[0x1322]=1; invoke(); assert(Read32(queue)==0);
    invoke(); assert(Read32(queue)==0); // Empty queue, non-chanting actor.

    actor[0x1b0]=0xc; team[0x93ee]=0;
    Put32(queue,0x00030201); Put16(actor.data()+0x1be,0);
    actor[0x1322]=2; invoke();
    assert(Read32(queue)==0x00030201 && Read16(actor.data()+0x1be)==1); // Wait for head.
    actor[0x1322]=1; invoke();
    assert(Read32(queue)==0x01000302 && Read16(actor.data()+0x1be)==0);
    actor[0x1322]=2; Put16(actor.data()+0x1be,0); invoke();
    assert(Read32(queue)==0x01000302 && Read16(actor.data()+0x1be)==1); // Lock blocks head.
    finish(); assert(Read32(queue)==0x00000302);
    invoke(); assert(Read32(queue)==0x01000003 && Read16(actor.data()+0x1be)==0);

    team[0x9108]=1; Put32(queue,0x01030201); Put16(actor.data()+0x1be,2);
    invoke(); assert(Read32(queue)==0x00030201 && Read16(actor.data()+0x1be)==1);
    Put16(actor.data()+0x1be,0); invoke(); assert(Read16(actor.data()+0x1be)==0);
    sentinels();

    Release(d,bases);
    Release(slots,slotBases);
    assert(VirtualFree(image,0,MEM_RELEASE));
    return cases;
}

void Config(const Definition& d) {
    wchar_t dir[MAX_PATH],ini[MAX_PATH];
    assert(GetTempPathW(MAX_PATH,dir) && GetTempFileNameW(dir,L"sqf",0,ini));
    auto options=ReadOptions(d,ini);
    assert(options.enabled==0);
    assert(WritePrivateProfileStringW(L"Battle",L"SpellQueueFix2",L"1",ini));
    assert(ReadOptions(d,ini).enabled==0); // Retired standalone key is not an alias.
    assert(WritePrivateProfileStringW(L"BattleEnhancements",L"SpellQueueFix",L"1",ini));
    options=ReadOptions(d,ini);
    assert(options.enabled==16 && Dependencies(d,options.enabled)==16);
    assert(options.parameters==std::vector<float>{0.2f});
    assert(DeleteFileW(ini));
}

int main() {
    auto q=PatchScript::ReadPackage("D3D9/patches/battle-enhancements/patch.toml");
    auto s=PatchScript::ReadPackage("D3D9/patches/add-spell-slots/patch.toml");
    auto queue=PatchScript::Compile(q),slots=PatchScript::Compile(s);
    assert(queue.definition.configSection=="BattleEnhancements" && queue.definition.features.at(4).key=="SpellQueueFix");
    Config(queue.definition);
    unsigned cases=0;
    for(bool allFeatures:{false,true}) {
        cases+=Exercise(queue,slots,0,0,false,allFeatures);
        for(int party=1;party<=4;++party) for(int enemy=1;enemy<=3;++enemy) for(bool first:{false,true})
            cases+=Exercise(queue,slots,party,enemy,first,allFeatures);
    }
    std::printf("SpellQueueFix passed: INI key, queue alone/all battle features, all 12 slot configurations in both orders, %u busy/timer cases, completion, queue behavior, guards, registers/stack, and allocation sentinels.\n",cases);
}
