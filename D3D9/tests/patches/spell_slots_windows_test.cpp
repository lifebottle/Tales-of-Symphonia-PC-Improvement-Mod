// Real Win32 script package installer and x86 helpers, with synthetic battle memory.
#include "patch_runtime.h"
#include "patch_script.h"
#include <windows.h>
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
using namespace PatchFramework;
uint32_t Address(const void* p) { return static_cast<uint32_t>(reinterpret_cast<uintptr_t>(p)); }
uint32_t Read32(const void* p) { uint32_t n; std::memcpy(&n,p,4); return n; }
void Put32(void* p,uint32_t n) { std::memcpy(p,&n,4); }
void Check(bool ok,const std::string& error) { if(!ok) { std::fprintf(stderr,"%s\n",error.c_str()); std::abort(); } }

void Config(Definition d) {
 wchar_t dir[MAX_PATH],ini[MAX_PATH];
 assert(GetTempPathW(MAX_PATH,dir) && GetTempFileNameW(dir,L"spl",0,ini));
 auto options=ReadOptions(d,ini);
 assert(options.enabled==0 && options.parameters==std::vector<float>({1,1}));
 WritePrivateProfileStringW(L"AddSpellSlots",L"Enabled",L"1",ini);
 wchar_t value[32];
 GetPrivateProfileStringW(L"AddSpellSlots",L"PARTY_SLOTS",L"",value,32,ini);
 assert(std::wstring(value)==L"1");
 for(int party=1;party<=4;++party) for(int enemy=1;enemy<=3;++enemy) {
  assert(WritePrivateProfileStringW(L"AddSpellSlots",L"PARTY_SLOTS",std::to_wstring(party).c_str(),ini));
  assert(WritePrivateProfileStringW(L"AddSpellSlots",L"ENEMY_SLOTS",std::to_wstring(enemy).c_str(),ini));
  options=ReadOptions(d,ini);
  assert(options.parameters[0]==party && options.parameters[1]==enemy);
 }
 for(const auto* bad:{L"0",L"-1",L"5",L"nan",L"inf",L"2oops",L"4294967296"}) {
  WritePrivateProfileStringW(L"AddSpellSlots",L"PARTY_SLOTS",bad,ini);
  options=ReadOptions(d,ini);
  assert(options.parameters[0]==1 && options.parameters[1]==3);
 }
 WritePrivateProfileStringW(L"AddSpellSlots",L"PARTY_SLOTS",L"4",ini);
 for(const auto* bad:{L"0",L"4",L"nan",L"xyz"}) {
  WritePrivateProfileStringW(L"AddSpellSlots",L"ENEMY_SLOTS",bad,ini);
  options=ReadOptions(d,ini);
  assert(options.parameters[0]==4 && options.parameters[1]==1);
 }
 WritePrivateProfileStringW(L"AddSpellSlots",L"Enabled",L"0",ini);
 assert(ReadOptions(d,ini).enabled==0);
 assert(DeleteFileW(ini));

}

int main() {
 Definition spells,battle; std::string error;
 Check(Load(L"D3D9/patches/add-spell-slots/patch.toml",spells,error),error);
 Check(Load(L"D3D9/patches/battle-enhancements/patch.toml",battle,error),error);
 assert(spells.parameters.size()==2);
 assert(std::count_if(spells.segments.begin(),spells.segments.end(),[](const Segment& s){return s.kind==Kind::Patch;})==162);
 auto package=PatchScript::ReadPackage("D3D9/patches/add-spell-slots/patch.toml");
 auto symbols=PatchScript::Compile(package).symbols;
 auto chooseOffset=symbols.at("helpers:choose").second;
 auto capacityOffset=symbols.at("helpers:capacity").second;
 auto prepare_battleOffset=symbols.at("helpers:prepare_battle").second;
 Config(spells);
 spells.imageBase=battle.imageBase=0; // Every game reference must relocate too.
 unsigned cases=0;
 for(int party=1;party<=4;++party) for(int enemy=1;enemy<=3;++enemy) {
  auto* image=static_cast<uint8_t*>(VirtualAlloc(nullptr,spells.imageSize,MEM_COMMIT|MEM_RESERVE,PAGE_EXECUTE_READWRITE));
  assert(image);
  for(const auto* d:{&spells,&battle}) {
   for(const auto& g:d->guards) std::memcpy(image+g.rva,d->bytes.data()+g.bytes,g.count);
   for(const auto& s:d->segments) if(s.kind==Kind::Patch) std::memcpy(image+s.rva,d->bytes.data()+s.expected,s.count);
  }
  Session session;
  Check(Install(session,spells,image,spells.imageSize,{0,{1,1}},error),error);
  assert(image[0x26b9d]==0x0f);
  // Bad original/guard must reject the entire set before any patch changes.
  image[0x26b9d]^=1;
  assert(!Install(session,spells,image,spells.imageSize,{1,{1,1}},error));
  image[0x26b9d]^=1;
  const auto guard=spells.guards.back(); image[guard.rva]^=1;
  assert(!Install(session,spells,image,spells.imageSize,{1,{1,1}},error));
  image[guard.rva]^=1;
  assert(image[0x26b9d]==0x0f && session.installed.empty());
  Options battleOptions{31,{0.2f}}; // Include Spell Queue Fix in both install orders.
  if((party+enemy)%2) Check(Install(session,battle,image,battle.imageSize,battleOptions,error),error);
  Check(Install(session,spells,image,spells.imageSize,{1,{float(party),float(enemy)}},error),error);
  if(!((party+enemy)%2)) Check(Install(session,battle,image,battle.imageSize,battleOptions,error),error);
  assert(!Install(session,spells,image,spells.imageSize,{1,{1,1}},error));
  assert(!Read32(image+0x6d2edc)); // No battle existed during either installation.
  std::vector<uint8_t*> bases(spells.segments.size(),nullptr);
  for(size_t i=0;i<bases.size();++i) if(spells.segments[i].kind==Kind::Patch) bases[i]=image+spells.segments[i].rva;
  for(size_t pass=0;pass<bases.size();++pass) for(const auto& f:spells.fixups) {
   if(!bases[f.owner] || f.target<0 || bases[f.target]) continue;
   uint32_t value=Read32(bases[f.owner]+f.offset)-f.addend;
   if(f.type==2) value+=Address(bases[f.owner]+f.offset); else assert(f.type==1);
   bases[f.target]=reinterpret_cast<uint8_t*>(static_cast<uintptr_t>(value));
  }
  auto* code=bases[0]; auto* arena=bases[1]; assert(code && arena);
  for(size_t i=0;i<2;++i) {
   MEMORY_BASIC_INFORMATION info{}; assert(VirtualQuery(bases[i],&info,sizeof(info)));
   assert(info.Protect==(i==0 ? PAGE_EXECUTE_READ : PAGE_READWRITE));
  }
  assert(*reinterpret_cast<float*>(arena+0x403c)==party && *reinterpret_cast<float*>(arena+0x4040)==enemy);
  // Symbol offsets come from the assembled conversion.
  auto prepare=reinterpret_cast<uint32_t (*)(void*)>(code+prepare_battleOffset);
  auto choose=reinterpret_cast<int (*)(void*,void*,int,int)>(code+chooseOffset);
  auto capacity=reinterpret_cast<int (*)(void*,int)>(code+capacityOffset);
  std::vector<uint8_t> team(0x180000),actor(0x14000),owner(0x14000);
  auto* b=team.data(); Put32(image+0x6d2edc,Address(b));
  assert(prepare(b)==Address(arena+0xd000));
  assert(Read32(b+0x16f950)==Address(arena+0xd000));
  const int slots[]={0,1,2,6,7,8,9};
  auto busy=[&](int slot){return slot<3 ? b+0x93ee + slot : arena+0x4080+slot-6;};
  auto slotAddress=[&](int slot){return slot<3 ? b+0x15b310+slot*0xa320 : arena+0x80000+(slot-6)*0x80000;};
  for(int slot:slots) {
   auto* data=slotAddress(slot); Put32(data+4,1); Put32(data+444,Address(owner.data())); data[454]=201; data[455]=0;
  }
  for(int unison=0;unison<2;++unison) for(int conflict=0;conflict<2;++conflict)
   for(int mask=0;mask<128;++mask) for(int side=0;side<2;++side) {
    for(int i=0;i<7;++i) *busy(slots[i])=(mask>>i)&1;
    b[0x9108]=static_cast<uint8_t>(unison); Put32(arena+0x4038,conflict); actor[0x1320]=static_cast<uint8_t>(side);
    std::vector<int> candidates=side ? std::vector<int>{1} : std::vector<int>{0};
    if(!side && unison) candidates.push_back(1);
    if(!side && party>=2) candidates.push_back(2);
    if(!conflict) {
     if(!side && party>=3) candidates.push_back(6);
     if(!side && party>=4) candidates.push_back(7);
     if(side && enemy>=2) candidates.push_back(8);
     if(side && enemy>=3) candidates.push_back(9);
    }
    int expected=-1; for(int slot:candidates) if(!*busy(slot)) {expected=slot;break;}
    assert(choose(b,actor.data(),201,1)==expected);
    if(expected>=0) assert(actor[0x13ab0]==expected);
    assert(capacity(b,side)==(expected==-1)); ++cases;
   }
  // Every battle clears expanded state and attaches fresh descriptors/buffers,
  // while retaining the configured counts.
  std::fill(arena+0x5000,arena+0x5a00,0xaa); Put32(arena+0x4080,0xffffffff);
  prepare(b);
  assert(Read32(arena+0x4080)==0 && Read32(arena+0x5000)==0);
  assert(*reinterpret_cast<float*>(arena+0x403c)==party && *reinterpret_cast<float*>(arena+0x4040)==enemy);
  assert(VirtualFree(image,0,MEM_RELEASE));
 }
 std::printf("Spell slots passed: 12 configurations, %u native admission/capacity cases, defaults/invalid INI, guards, co-installation in both orders, lifecycle and RX/RW memory.\n",cases);
}
