// Original bytes verified during CT export.
assert(TOS.exe+0x26b13,80 BB B1 01 00 00 05 0F 84 F4 06 00 00 8B 15 DC 2E AD 00)
assert(TOS.exe+0x27228,8B 4E 38 F6 C1 01 74 1F 0F B6 93 B0 3A 01 00 8B 3D DC 2E AD 00 80 BC 3A EE 93 00 00 00 74 08 F7 C1 00 00 00 20 74 2C)
assert(TOS.exe+0x67dba,C6 05 52 86 B1 00 00)
assert(TOS.exe+0x6ff76,C6 87 B0 01 00 00 15)
assert(TOS.exe+0x7140e,A1 DC 2E AD 00)
assert(TOS.exe+0x6ff7d,E8 AE 36 FD FF)
assert(TOS.exe+0x71413,80 8E 08 91 00 00 04)
assert(TOS.exe+0x7141a,66 C7 80 79 8F 00 00 03 00)
// Continuations retained by the compatibility adaptation.
assert(TOS.exe+0x26b26,66 83 BA F0 90 00 00 00 0F 85 E0 06 00 00)
assert(TOS.exe+0x26ffa,80 BB B1 01 00 00 04 74 49)
assert(TOS.exe+0x27214,8B FB)
assert(TOS.exe+0x2724f,85 C0 75 28 0F B7 83 BE 01 00 00 66 85 C0 74 08 48 66 89 83 BE 01 00 00 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90)
assert(TOS.exe+0x2727b,F6 83 90 02 00 00 10)

// TOS NoTSFix v26.9.5, entry 3164, by sd (2026-09-26).
// Adapted for the bundled Battle Enhancements. Queue ready party casts, remove
// guarding/held casters, and reset at battle end / Unison start.
//
// The CT NOPs +27228..+2724E, including AddSpellSlots' +2723D hook. Instead,
// +27228 jumps straight to the native countdown at +2724F. Cast readiness uses
// the now-detached busy comparison at +27237..+27244, then rejoins our queue at
// +27245. With extra slots this runs choose(assign=0), including capacity,
// owner and resource checks; without them it checks the native party slot.
// No optional symbol references: either feature still works independently.

[ENABLE]

define(SpellHold,TOS.exe+26B13)
define(SpellTimer,TOS.exe+27228)
define(QueueCapacityResult,TOS.exe+27245)
define(BattleEnd,TOS.exe+67DBA)
define(UnisonSlash,TOS.exe+6FF76)
define(UnisonTrigger,TOS.exe+7140E)
alloc(Mem_SpellHold,$1000,SpellHold)
alloc(QueueList,4)
registersymbol(QueueList)

Mem_SpellHold:
    pushfd
    pushad
    // ECX is scratch across the preceding game calls. Use the actor's side
    // rather than the CT's test ecx,ecx to keep enemies out of the party FIFO.
    test byte [ebx+1320],1
    jnz NativeSpellHold
    lea edi,[QueueList]
    cmp byte [ebx+1B1],4
    je RemoveQueue_Start
    cmp byte [ebx+1B1],5
    je RemoveQueue_Start
    mov edx,[TOS.exe+6D2EDC]
    cmp byte [edx+9108],0
    jne ResumeSpellHold
    mov eax,[ebx+C]
    test byte [eax+38],1
    jz ResumeSpellHold
    // Query slot 0 in the native game. AddSpellSlots replaces the comparison
    // with its full admission check and ignores this provisional slot index.
    xor edx,edx
    jmp TOS.exe+27237

Mem_QueueCapacityResult:
    lea edi,[QueueList]   // LEA preserves the admission comparison's ZF.
    jne AddQueue_Start
    cmp dword ptr [edi],0
    je ResumeSpellHold
    movzx eax,byte [ebx+1322]
    cmp byte [edi],al
    jne WaitSpell
    shr dword ptr [edi],8
    jmp ResumeSpellHold

AddQueue_Start:
    xor ecx,ecx
    movzx eax,byte [ebx+1322]
AddQueue_Loop:
    cmp byte [edi+ecx],0
    je AddQueue
    cmp byte [edi+ecx],al
    je WaitSpell
    inc ecx
    cmp ecx,3
    jb AddQueue_Loop
    jmp WaitSpell
AddQueue:
    mov byte [edi+ecx],al
WaitSpell:
    popad
    popfd
    jmp TOS.exe+26FFA

RemoveQueue_Start:
    movzx eax,byte [ebx+1322]
    call RemoveQueue
    cmp byte [ebx+1B1],4
    je WaitSpell
NativeSpellHold:
    cmp byte [ebx+1B1],5
    jne ResumeSpellHold
    popad
    popfd
    jmp TOS.exe+27214
ResumeSpellHold:
    popad
    popfd
    mov edx,[TOS.exe+6D2EDC]
    jmp Ret_SpellHold

// EDI = FIFO, AL = character ID. Preserve order, including middle removals.
// Byte 3 stays zero so removing the third entry never reads past QueueList.
RemoveQueue:
    xor ecx,ecx
RemoveQueue_Loop:
    cmp byte [edi+ecx],0
    je RemoveQueue_Exit
    cmp byte [edi+ecx],al
    je RemoveQueue_Found
    inc ecx
    cmp ecx,3
    jb RemoveQueue_Loop
    ret
RemoveQueue_Found:
    shr word ptr [edi+ecx],8
    test ecx,ecx
    jnz RemoveQueue_Exit
    shr word ptr [edi+1],8
RemoveQueue_Exit:
    ret

Mem_BattleEnd:
    mov dword ptr [QueueList],0
    mov byte [TOS.exe+718652],0
    jmp Ret_BattleEnd

Mem_UnisonSlash:
    mov byte [edi+1B0],15
    pushfd
    pushad
    movzx eax,byte [edi+1322]
    lea edi,[QueueList]
    call RemoveQueue
    popad
    popfd
    // Preserve the original CALL at +6FF7D and its register inputs.
    jmp Ret_UnisonSlash

Mem_UnisonTrigger:
    mov dword ptr [QueueList],0
    mov eax,[TOS.exe+6D2EDC]
    jmp Ret_UnisonTrigger

SpellHold:
    jmp Mem_SpellHold
    nop E
Ret_SpellHold:

SpellTimer:
    jmp TOS.exe+2724F
    nop

QueueCapacityResult:
    jmp Mem_QueueCapacityResult
    nop 3

BattleEnd:
    jmp Mem_BattleEnd
    nop 2
Ret_BattleEnd:

UnisonSlash:
    jmp Mem_UnisonSlash
    nop 2
Ret_UnisonSlash:

UnisonTrigger:
    jmp Mem_UnisonTrigger
Ret_UnisonTrigger:
