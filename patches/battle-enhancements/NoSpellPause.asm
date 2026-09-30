// Original bytes verified during CT export.
assert(TOS.exe+0x6e132,B2 01 B8 3C 00 00 00 E8 D2 2A FF FF)

{ Game   : TOS.exe
  Version: 
  Date   : 2026-09-20
  Author : sdail
  Description : 

  <Optional info>
}

[ENABLE]

define(SpellPause,TOS.exe+6E132)

alloc(Mem_SpellPause,$1000,SpellPause)

registersymbol(SpellPause)



Mem_SpellPause:
    mov edx,[esi+C]
    //add edx,TOS.exe+4D84BC
    test [edx+38],20
    jz Ret_SpellPause
    mov dl,01
    mov eax,0000003C
    call TOS.exe+60C10
    jmp Ret_SpellPause
//============================================================================//
SpellPause:
    jmp Mem_SpellPause
    nop 5
    nop 2
Ret_SpellPause:

[DISABLE]

SpellPause:
  db B2 01
  db B8 3C 00 00 00
  db E8 D2 2A FF FF

unregistersymbol(SpellPause)
dealloc(Mem_SpellPause)

{
// ORIGINAL CODE - INJECTION POINT: TOS.exe+6E12E

TOS.exe+6E100: EB 06                 - jmp TOS.exe+6E108
TOS.exe+6E102: 88 88 51 E8 10 00     - mov [eax+0010E851],cl
TOS.exe+6E108: 8A 88 4E E8 10 00     - mov cl,[eax+0010E84E]
TOS.exe+6E10E: 3A CA                 - cmp cl,dl
TOS.exe+6E110: 76 08                 - jna TOS.exe+6E11A
TOS.exe+6E112: 88 90 52 E8 10 00     - mov [eax+0010E852],dl
TOS.exe+6E118: EB 06                 - jmp TOS.exe+6E120
TOS.exe+6E11A: 88 88 52 E8 10 00     - mov [eax+0010E852],cl
TOS.exe+6E120: C6 80 33 E8 10 00 04  - mov byte ptr [eax+0010E833],04
TOS.exe+6E127: 80 88 31 E8 10 00 02  - or byte ptr [eax+0010E831],02
// ---------- INJECTING HERE ----------
TOS.exe+6E12E: 6A 03                 - push 03
// ---------- DONE INJECTING  ----------
TOS.exe+6E130: 6A 4B                 - push 4B
TOS.exe+6E132: B2 01                 - mov dl,01                        <---
TOS.exe+6E134: B8 3C 00 00 00        - mov eax,0000003C
TOS.exe+6E139: E8 D2 2A FF FF        - call TOS.exe+60C10
TOS.exe+6E13E: 8B 4C 24 14           - mov ecx,[esp+14]
TOS.exe+6E142: 8B 56 04              - mov edx,[esi+04]
TOS.exe+6E145: D9 82 8C 00 00 00     - fld dword ptr [edx+0000008C]
TOS.exe+6E14B: 83 C4 08              - add esp,08
TOS.exe+6E14E: F7 41 38 00 00 00 01  - test [ecx+38],TOS.exe+C00000
TOS.exe+6E155: 51                    - push ecx
}
