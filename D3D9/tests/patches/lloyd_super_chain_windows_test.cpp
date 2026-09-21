// Execute the readable package through the real installer in synthetic memory.
// Does not attach to TOS, touch game files, or use fixed debugger code caves.
#include "patch_runtime.h"
#include <windows.h>
#include <array>
#include <cassert>
#include <cstdio>
#include <cstring>
using namespace PatchFramework;
struct Registers { void* entry; uint32_t eax,ebx,ecx,edx,esi,edi,ebp,flags; };
extern "C" void Invoke(Registers*);
__asm__(
 ".intel_syntax noprefix\n.text\n.global _Invoke\n_Invoke:\n"
 "pushad\nmov ebp,[esp+36]\npush ebp\npush DWORD PTR [ebp]\n"
 "push DWORD PTR [ebp+32]\npopfd\n"
 "mov eax,[ebp+4]\nmov ebx,[ebp+8]\nmov ecx,[ebp+12]\n"
 "mov edx,[ebp+16]\nmov esi,[ebp+20]\nmov edi,[ebp+24]\nmov ebp,[ebp+28]\n"
 "call DWORD PTR [esp]\npushfd\npushad\nmov ebp,[esp+40]\n"
 "mov eax,[esp+28]\nmov [ebp+4],eax\nmov eax,[esp+16]\nmov [ebp+8],eax\n"
 "mov eax,[esp+24]\nmov [ebp+12],eax\nmov eax,[esp+20]\nmov [ebp+16],eax\n"
 "mov eax,[esp+4]\nmov [ebp+20],eax\nmov eax,[esp]\nmov [ebp+24],eax\n"
 "mov eax,[esp+8]\nmov [ebp+28],eax\nmov eax,[esp+32]\nmov [ebp+32],eax\n"
 "add esp,44\npopad\nret\n.att_syntax prefix\n");
uint32_t Address(const void* p) { return static_cast<uint32_t>(reinterpret_cast<uintptr_t>(p)); }
uint32_t Read32(const void* p) { uint32_t n; std::memcpy(&n,p,4); return n; }
void Put32(void* p,uint32_t n) { std::memcpy(p,&n,4); }
void Check(bool ok,const std::string& error) { if (!ok) { std::fprintf(stderr,"%s\n",error.c_str()); std::abort(); } }
int main() {
 Definition d; std::string error;
 Check(Load(L"D3D9/patches/lloyd-super-chain/patch.toml",d,error),error);
 assert(d.features.size()==1 && d.features[0].key=="Enabled");
 auto* image=static_cast<uint8_t*>(VirtualAlloc(nullptr,d.imageSize,MEM_COMMIT|MEM_RESERVE,PAGE_EXECUTE_READWRITE));
 assert(image); d.imageBase=0; // Exercise all references at a different game base.
 for (auto& g:d.guards) std::memcpy(image+g.rva,d.bytes.data()+g.bytes,g.count);
 for (auto& s:d.segments) if(s.kind==Kind::Patch) std::memcpy(image+s.rva,d.bytes.data()+s.expected,s.count);
 Session session;
 Check(Install(session,d,image,d.imageSize,{0,{}},error),error);
 assert(image[0x678e0]==0x8b);
 // One wrong original must reject the entire installation without writes.
 image[0x3f0de]^=1;
 assert(!Install(session,d,image,d.imageSize,{1,{}},error));
 assert(image[0x678e0]==0x8b && image[0xf34a0]==0x80 && session.installed.empty());
 image[0x3f0de]^=1;
 // Battle context and PAC globals remain zero throughout installation.
 Check(Install(session,d,image,d.imageSize,{1,{}},error),error);
 assert(!Install(session,d,image,d.imageSize,{1,{}},error));
 assert(!Read32(image+0x6d2edc) && !Read32(image+0x4ed7ec));
 // Recover allocated segment addresses from installed relocation fields.
 std::vector<uint8_t*> bases(d.segments.size(),nullptr);
 for(size_t i=0;i<d.segments.size();++i) if(d.segments[i].kind==Kind::Patch) bases[i]=image+d.segments[i].rva;
 for(size_t pass=0;pass<d.segments.size();++pass) for(auto& f:d.fixups) {
  if(!bases[f.owner] || f.target<0 || bases[f.target]) continue;
  uint32_t value=Read32(bases[f.owner]+f.offset)-f.addend;
  if(f.type==2) value+=Address(bases[f.owner]+f.offset); else assert(f.type==1);
  bases[f.target]=reinterpret_cast<uint8_t*>(static_cast<uintptr_t>(value));
 }
 uint8_t *status=nullptr,*rows=nullptr;
 for(size_t i=0;i<d.segments.size();++i) {
  const auto& s=d.segments[i]; assert(bases[i]);
  MEMORY_BASIC_INFORMATION info{}; assert(VirtualQuery(bases[i],&info,sizeof(info)));
  if(s.kind==Kind::Code) assert(info.Protect==PAGE_EXECUTE_READ);
  if(s.kind==Kind::Data) assert(info.Protect==PAGE_READWRITE);
  if(s.name.find(": mem_status")!=s.name.npos) status=bases[i];
  if(s.name.find(": mem_rows")!=s.name.npos) rows=bases[i];
 }
 assert(status && rows && Read32(status)==0x31574353);
 struct Row { uint32_t runtime,source,block,header,window,effect,scripts[4],directory; };
 static_assert(sizeof(Row)==44,"row size");
 std::array<Row,9> records{}; std::memcpy(records.data(),rows,sizeof(records));
 const uint32_t expectedWindows[]={0x00370046,0x00410050,0x0050005f,0x004f005e,0x0050005f,0x00690078,0x00690078,0x00690078,0x00690078};
 for(size_t i=0;i<records.size();++i) assert(records[i].window==expectedWindows[i]);
 std::vector<uint8_t> pac(0x60000),table(155*112),battle(40000),frame(512);
 auto reset=[&] {
  std::fill(pac.begin(),pac.end(),0); std::fill(table.begin(),table.end(),0xa5);
  Put32(pac.data(),9); Put32(pac.data()+36,0x49f60); Put32(pac.data()+0x49f60,155);
  for(const auto& r:records) {
   Put32(pac.data()+0x49f60+r.directory,r.block-0x49f60);
   Put32(pac.data()+r.source,r.header); Put32(pac.data()+r.source+8,r.effect);
   Put32(table.data()+r.runtime,r.header); Put32(table.data()+r.runtime+4,0); Put32(table.data()+r.runtime+8,r.effect);
   const uint32_t strides[]={28,32,12,2};
   for(unsigned k=0;k<4;++k) {
    auto* section=pac.data()+r.block+4*k;
    if(!Read32(section)) Put32(section,r.scripts[k]-r.block);
    uint32_t delta=r.scripts[k]-r.block-Read32(section);
    assert(delta%strides[k]==0);
    Put32(pac.data()+r.source+12+4*k,delta/strides[k]);
    Put32(table.data()+r.runtime+12+4*k,Address(pac.data())+r.scripts[k]);
   }
  }
 };
 image[0x678e6]=0xc3; // Return to harness at the native continuation.
 unsigned attempts=0,successes=0,failures=0;
 auto rebuild=[&](bool valid,bool nullPac=false,bool nullTable=false) {
  auto sourceBefore=pac,expected=table;
  if(valid) for(const auto& r:records) Put32(expected.data()+r.runtime+4,r.window);
  Put32(frame.data(),nullPac?0:Address(pac.data()));
  Put32(battle.data()+39512,nullTable?0:Address(table.data()));
  Registers regs{image+0x678e0,0x11,0x22,0x33,0x44,0x55,Address(battle.data()),Address(frame.data()+316),0x246};
  Invoke(&regs);
  assert(regs.eax==0x11 && regs.ebx==0x22 && regs.edx==0x44 && regs.esi==0x55);
  assert(regs.edi==Address(battle.data()) && regs.ebp==Address(frame.data()+316));
  assert(regs.ecx==(nullPac?0:Address(pac.data())) && (regs.flags&0xcd5)==(0x246&0xcd5));
  assert(table==expected && pac==sourceBefore);
  ++attempts; if(valid) ++successes; else ++failures;
  assert(Read32(status+4)==attempts && Read32(status+8)==successes && Read32(status+12)==failures);
  assert(Read32(status+16)==(nullPac?0:Address(pac.data())) && Read32(status+20)==(nullTable?0:Address(table.data())));
  assert((Read32(status+24)==0)==valid);
 };
 reset(); rebuild(true); rebuild(true);
 // Fresh allocations for the next battle, while old ones are still owned.
 auto oldPac=std::move(pac),oldTable=std::move(table);
 pac.resize(0x60000); table.resize(155*112); reset(); rebuild(true);
 assert(Address(pac.data())!=Address(oldPac.data()) && Address(table.data())!=Address(oldTable.data()));
 reset(); for(const auto& r:records) Put32(pac.data()+r.source+4,r.window); rebuild(true);
 unsigned mismatches=0;
 for(const auto& r:records) {
  // Every header/effect/window/index/pointer/section field, including late rows.
  std::vector<std::pair<bool,uint32_t>> fields={{true,0x49f60+r.directory}};
  for(unsigned off: {0u,4u,8u,12u,16u,20u,24u}) { fields.push_back({true,r.source+off}); fields.push_back({false,r.runtime+off}); }
  for(unsigned k=0;k<4;++k) fields.push_back({true,r.block+4*k});
  for(auto field:fields) { reset(); (field.first?pac:table)[field.second]^=1; rebuild(false); ++mismatches; }
 }
 for(unsigned off:{0u,36u,0x49f60u}) { reset(); Put32(pac.data()+off,0); rebuild(false); ++mismatches; }
 reset(); rebuild(false,true); rebuild(false,false,true);
 std::printf("Descriptor hook: changed allocations, repeat rebuilds, source preservation, %u mismatches, null inputs and register/flag preservation passed.\n",mismatches);
 // MAX menu paths. The native normal-level destination is a marker + return.
 std::memcpy(image+0xf34ec,"\xb8\x78\x56\x34\x12\xc3",6);
 auto* buffer=reinterpret_cast<uint8_t*>(static_cast<uintptr_t>(Read32(image+0xf1876)));
 const uint32_t operands[]={0xf1876,0xf1e22,0xf1e91,0xf26af,0xf295d,0xf2a8b,0xf2e80,0xf2f2b,0xf34d6,0xf351c,0xf3696,0xf3e95,0xf4561};
 for(auto off:operands) assert(Read32(image+off)==Address(buffer));
 for(uint32_t actor=0;actor<9;++actor) for(uint32_t level=0;level<=6;++level) {
  Registers r{image+0xf34a0,0,0x22,level,actor,0x55,0x66,0x77,0x202}; Invoke(&r);
  assert(r.ebx==0x22 && r.ecx==level && r.edx==actor && r.esi==0x55 && r.edi==0x66 && r.ebp==0x77);
  if(level<5) assert(r.eax==0x12345678);
  else {
   assert(!std::memcmp(buffer,image+0x4e0a60+16*actor,16));
   const bool extra=actor==1 && level==5;
   assert(image[0x71399d]==(extra?17:16)); if(extra) assert(buffer[16]==42);
  }
 }
 // Ability Plus native skill lookup stub verifies actor input and skill 42.
 // Return EAX from the synthetic actor's first DWORD, or zero for wrong skill.
 const uint8_t lookup[]={0x83,0xfa,0x2a,0x75,0x03,0x8b,0x00,0xc3,0x31,0xc0,0xc3};
 std::memcpy(image+0x42d60,lookup,sizeof(lookup));
 image[0x3f0e6]=image[0x3f672]=0xc3;
 std::vector<uint8_t> actor(5000),skills(64);
 for(uint32_t site:{0x3f0deu,0x3f665u}) for(uint32_t bits=0;bits<16;++bits)
 for(bool skill:{false,true}) for(bool ability:{false,true}) for(bool present:{false,true}) {
  Put32(actor.data(),skill); Put32(actor.data()+12,present?Address(skills.data()):0);
  Put32(actor.data()+4972,bits); skills[56]=ability?4:0;
  const bool allowed=bits==1 || (!(bits&8) && (bits&1) && present && ability && skill);
  Registers r{image+site,0x11,0x22,0x33,0x44,Address(actor.data()),Address(actor.data()),0x77,0x202}; Invoke(&r);
  assert(r.eax==Address(actor.data()) && r.ebx==0x22 && r.ecx==0x33 && r.edx==0x44);
  assert(r.esi==Address(actor.data()) && r.edi==Address(actor.data()) && r.ebp==0x77);
  assert(bool(r.flags&0x40)==allowed);
 }
 std::puts("script package runtime: startup install, disabled/duplicate/rejected install, RX/RW allocations, 13 buffer references, MAX/normal menu and both Ability Plus gates passed.");
 VirtualFree(image,0,MEM_RELEASE);
}
