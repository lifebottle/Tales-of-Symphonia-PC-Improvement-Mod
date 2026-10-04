// TOS NoTSFix v26.10, entry 3220: [Disable Spell Pause] (NEW), 2026-10-02.
// Keep asynchronous resource completion separate from the spell freeze timer.
[ENABLE]

alloc(LoadGate,100)

define(SpellPause,TOS.exe+6E12E)
define(SpellStart,TOS.exe+6E139)
define(FreezeTimer,TOS.exe+6EA8D)
define(SpellCasting,TOS.exe+6EAB2)
define(FreezeA,TOS.exe+84DD3)
define(CollisionGate,TOS.exe+5EE3E)

assert(SpellPause,6A 03)
assert(SpellStart,E8 D2 2A FF FF)
assert(FreezeTimer,0F 8F 5B 02 00 00)
assert(SpellCasting,B1 04 85 C0 74 25 A1 DC 2E AD 00 08 88 EC 93 00 00 8B 44 24 14 BA FC FF 00 00 66 21 90 F0 90 00 00 C7 80 E0 93 00 00 00 00 00 00 8B 44 24 14 84 88 EC 93 00 00 0F 84 01 02 00 00)
assert(FreezeA,0F 85 1F 01 00 00)
assert(CollisionGate,75 19)
// Preserve actual freeze-owner and simulation-tick gates. The collision call
// at +5EE4F remains available to the debug overlay's capture wrapper.
assert(TOS.exe+5EE37,80 BE EC 93 00 00 00)
assert(TOS.exe+5EE40,83 BE E0 93 00 00 00 75 10 80 7D 08 00 75 05)
// Spell scripts retain their own pending-resource gate in the dispatcher.
assert(TOS.exe+252FA,80 B8 EC 93 00 00 00)
assert(TOS.exe+25308,75 48)
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

SpellStart:
    call StartWithoutFreeze

FreezeTimer:
    nop 6

SpellCasting:
    jmp LoadGate
    nop #54

LoadGate:
    mov cl,4
    test eax,eax
    je CheckFreeze
    mov eax,[TOS.exe+6D2EDC]
    // Latch successful completion before considering the timer. Pending loads
    // retain source=NULL and size=-1 and must never reach the model copy.
    or [eax+93EC],cl
    mov eax,[esp+14]
    mov edx,FFFC
    and [eax+90F0],dx
    mov dword ptr [eax+93E0],0
CheckFreeze:
    mov eax,[esp+14]
    test byte ptr [eax+93EC],4
    jz TOS.exe+6ECEE
    // This is a signed 16-bit countdown, as in the native gate at +6EA85.
    cmp word ptr [eax+93E8],0
    jg TOS.exe+6ECEE
    jmp TOS.exe+6EAED

// The native callback stores ESI as freeze owner even with pause flags zero.
// Remove that owner before returning to the casting tick, rather than waiting
// for resource completion. Other callers still retain normal freeze behavior.
StartWithoutFreeze:
    push dword ptr [esp+8]
    push dword ptr [esp+8]
    call TOS.exe+60C10
    lea esp,[esp+8]
    push eax
    mov eax,[TOS.exe+6D2EDC]
    mov dword ptr [eax+93E0],0
    pop eax
    ret

FreezeA:
    nop 6

// Actor motion is already allowed during spell loading. Process the same
// tick's collisions too; do not clear the loading flag or bypass real freezes.
CollisionGate:
    nop 2

[DISABLE]

SpellStart:
    db E8 D2 2A FF FF

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

CollisionGate:
    db 75 19
