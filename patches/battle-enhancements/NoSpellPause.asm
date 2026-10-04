// TOS NoTSFix v26.10, entry 3220: [Disable Spell Pause] (NEW), 2026-10-02.
// Inline replacement; no allocation or mutable patch state is needed.
[ENABLE]

define(SpellPause,TOS.exe+6E12E)
define(FreezeTimer,TOS.exe+6EA8D)
define(SpellCasting,TOS.exe+6EAB2)
define(FreezeA,TOS.exe+84DD3)

assert(SpellPause,6A 03)
assert(FreezeTimer,0F 8F 5B 02 00 00)
assert(SpellCasting,B1 04 85 C0 74 25 A1 DC 2E AD 00 08 88 EC 93 00 00 8B 44 24 14 BA FC FF 00 00 66 21 90 F0 90 00 00 C7 80 E0 93 00 00 00 00 00 00 8B 44 24 14 84 88 EC 93 00 00 0F 84 01 02 00 00)
assert(FreezeA,0F 85 1F 01 00 00)
// Keep the native pause callback and its other arguments intact. This also
// rejects the old NoSpellPause/CE trampoline at +6E132.
assert(TOS.exe+6E130,6A 4B B2 01 B8 3C 00 00 00 E8 D2 2A FF FF)
// Native timer layout and the fallthrough/exit contracts used below.
assert(TOS.exe+6EA85,66 83 BA E8 93 00 00 00)
assert(TOS.exe+6EA93,0F B6 88 ED 93 00 00)
assert(TOS.exe+6EAED,8B 4C 24 18 0F B6 11)
assert(TOS.exe+6ECEE,5F 5E 5B 8B E5 5D C3)
assert(TOS.exe+84DCC,80 BA EC 93 00 00 00)
assert(TOS.exe+84DD9,0F B6 83 20 13 00 00)

SpellPause:
    push 0

FreezeTimer:
    nop 6

SpellCasting:
    mov cl,4
    test eax,eax
    je CheckFreeze
    mov eax,[TOS.exe+6D2EDC]
    // AsmTK's absolute EAX load is one byte shorter than CE's here.
    // Five NOPs keep CheckFreeze at +6EADC and the end at +6EAED.
    nop 5
    mov eax,[esp+14]
    mov edx,FFFC
    and [eax+90F0],dx
    mov dword ptr [eax+93E0],0
CheckFreeze:
    mov eax,[esp+14]
    cmp byte ptr [eax+93E8],0
    jne TOS.exe+6ECEE

FreezeA:
    nop 6

[DISABLE]

SpellPause:
    db 6A 03
FreezeTimer:
    db 0F 8F 5B 02 00 00
SpellCasting:
    db B1 04 85 C0 74 25 A1 DC 2E AD 00 08 88 EC 93 00 00
    db 8B 44 24 14 BA FC FF 00 00 66 21 90 F0 90 00 00
    db C7 80 E0 93 00 00 00 00 00 00 8B 44 24 14
    db 84 88 EC 93 00 00 0F 84 01 02 00 00
FreezeA:
    db 0F 85 1F 01 00 00
