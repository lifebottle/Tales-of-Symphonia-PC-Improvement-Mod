// Original bytes verified during CT export.
assert(TOS.exe+0x40287,01 58 24 8B 4E 08)

{ Game   : TOS.exe
  Version: 
  Date   : 2023-06-01
  Author : thing

  This script is so bad lmao
}

[ENABLE]

define(minDMG,TOS.exe+0x40287) // resolved from aobscanmodule
alloc(Mem_minDMG,$1000)

label(code)
label(return)

Mem_minDMG:
  cmp ebx,0
  je code
  mov ebx,FFFFFFFF
code:
  add [eax+24],ebx
  mov ecx,[esi+08]
  jmp return

minDMG:
  jmp Mem_minDMG
  nop
return:
registersymbol(minDMG)

[DISABLE]

minDMG:
  db 01 58 24 8B 4E 08

unregistersymbol(minDMG)
dealloc(Mem_minDMG)

{
// ORIGINAL CODE - INJECTION POINT: TOS.exe+40287

TOS.exe+4026B: 66 8B 55 0C           - mov dx,[ebp+0C]
TOS.exe+4026F: 85 DB                 - test ebx,ebx
TOS.exe+40271: 7E 11                 - jle TOS.exe+40284
TOS.exe+40273: 53                    - push ebx
TOS.exe+40274: 8B D6                 - mov edx,esi
TOS.exe+40276: E8 35 FC FF FF        - call TOS.exe+3FEB0
TOS.exe+4027B: 66 8B 55 0C           - mov dx,[ebp+0C]
TOS.exe+4027F: 83 C4 04              - add esp,04
TOS.exe+40282: EB 29                 - jmp TOS.exe+402AD
TOS.exe+40284: 8B 46 08              - mov eax,[esi+08]
// ---------- INJECTING HERE ----------
TOS.exe+40287: 01 58 24              - add [eax+24],ebx
// ---------- DONE INJECTING  ----------
TOS.exe+4028A: 8B 4E 08              - mov ecx,[esi+08]
TOS.exe+4028D: 83 79 24 00           - cmp dword ptr [ecx+24],00
TOS.exe+40291: 7D 09                 - jnl TOS.exe+4029C
TOS.exe+40293: 8B C1                 - mov eax,ecx
TOS.exe+40295: C7 40 24 00 00 00 00  - mov [eax+24],00000000
TOS.exe+4029C: 8B 46 08              - mov eax,[esi+08]
TOS.exe+4029F: 39 78 24              - cmp [eax+24],edi
TOS.exe+402A2: 7E 09                 - jle TOS.exe+402AD
TOS.exe+402A4: 39 7C 24 14           - cmp [esp+14],edi
TOS.exe+402A8: 7F 03                 - jg TOS.exe+402AD
}
