//WiP Currently only fixes spell timers
//and fixes cancelling spell hold.
[ENABLE]
define(SetSpellCharge,TOS.exe+26A13)
define(SpellHold,TOS.exe+26B13)
define(SpellTimer,TOS.exe+27226)

assert(SetSpellCharge,85 97 6C 90 00 00 74 02)
assert(SpellHold,80 BB B1 01 00 00 05 0F 84 F4 06 00 00 8B 15 DC 2E AD 00)
assert(SpellTimer,75 53 8B 4E 38 F6 C1 01 74 1F 0F B6 93 B0 3A 01 00 8B 3D DC 2E AD 00 80 BC 3A EE 93 00 00 00 74 08 F7 C1 00 00 00 20 74 2C)

alloc(Mem_SpellQueueFix,200)

//===[Allocated Memory]===//
Mem_SpellQueueFix:
//Start
Mem_SetSpellCharge:
    cmp byte [ebx+1B1],5
    jne TOS.exe+26A1D
    test edx,1000
    jz TOS.exe+26A1D
    jmp Ret_SetSpellCharge

Mem_SpellHold:
    cmp byte [ebx+1B1],5
    je TOS.exe+27214
    cmp byte [ebx+1B1],4
    je TOS.exe+26FFA
    jmp Ret_SpellHold

//===[Addresses]===//
SetSpellCharge:
    jmp Mem_SetSpellCharge
    nop 3
Ret_SetSpellCharge:

SpellHold:
    jmp Mem_SpellHold
    nop 8
Ret_SpellHold:

SpellTimer:
    jmp TOS.exe+2724F
