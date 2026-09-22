// Original bytes verified during CT export.
// Leave +2723D to AddSpellSlots; only the entry's 15 bytes are overwritten.
assert(TOS.exe+0x2722e,74 1F 0F B6 93 B0 3A 01 00 8B 3D DC 2E AD 00)
assert(TOS.exe+0x2727b,F6 83 90 02 00 00 10 0F 85 32 01 00 00 0F BF 83 FA 12 00 00 25 07 00 00 80)
assert(TOS.exe+0x28105,0F B6 8E B0 3A 01 00)
assert(TOS.exe+0x2724d,74 2C)
assert(TOS.exe+0x2724f,85 C0)
assert(TOS.exe+0x27251,75 28)
assert(TOS.exe+0x27253,0F B7 83 BE 01 00 00)
assert(TOS.exe+0x2725a,66 85 C0)
assert(TOS.exe+0x2725d,74 08)
assert(TOS.exe+0x2725f,48 66 89 83 BE 01 00 00)
assert(TOS.exe+0x27267,90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90)

{ Game   : TOS.exe
  Version:
  Date   : 2026-08-18
  Author : sdail
  Description :

  <Optional info>
}

[ENABLE]

define(SpellQueue,TOS.exe+0x2722e) // resolved from aobscanmodule
define(Ret_SpellQueue,TOS.exe+0x2727b) // resolved from aobscanmodule
define(SpellQueueEnd,TOS.exe+28105)
alloc(Mem_SpellQueue,$2000,SpellQueue)
alloc(QueueList,4)

registersymbol(SpellQueue)
registersymbol(Ret_SpellQueue)
registersymbol(SpellQueueEnd)
registersymbol(QueueList)


//Make Mem check chanting animation


Mem_SpellQueue:
    test eax,eax        //Check Unknown
    jne Ret_SpellQueue  //
    mov eax,[TOS.exe+6D2EDC]
    cmp byte [eax+9108],0
    jne Unison_Exit
    cmp byte [ebx+1B0],C    //Check Char State (Chanting)
    jne Queue_Exit         //
    // Final slot admission runs before this timer hook, but only at timer 0.
    // Finish every positive countdown, including its last tick. Queue a ready
    // cast only after it has had a chance to select another free spell slot.
    cmp word [ebx+1BE],0
    ja DecTimer             //
    movzx edx,byte [ebx+13AB0]
    mov edi,[TOS.exe+6D2EDC]
    // AddSpellSlots assigns slots 6..9 only after attaching its buffer.
    // EXTRA_BUSY = buffer - 8F80; preserve EDI and the comparison flags.
    cmp edx,6
    jb NativeBusy
    cmp edx,9
    ja NativeBusy
    push edi
    mov edi,[edi+16F950]
    cmp byte [edi+edx-8F86],0
    pop edi
    jmp BusyDone
NativeBusy:
    cmp byte [edx+edi+93EE],0   //Check Active Team Queue (False)
BusyDone:
    je QueueFree                //
    call Func_SetTimer
    xor ecx,ecx
    movzx eax,byte [ebx+1322]   //Char ID
    lea edx,[QueueList]
    //mov byte [edx+3],0
AddQueue_Loop:
    cmp byte [edx+ecx],0
    je AddQueue
    cmp byte [edx+ecx],al
    je AddQueue_Exit
AddQueue_Inc:
    inc ecx
    cmp ecx,2
    jbe AddQueue_Loop
    jmp AddQueue_Exit
AddQueue:
    mov byte [edx+ecx],al
    //mov [QueueList],edx
AddQueue_Exit:
    cmp byte [ebx+1B0],C    //Check Char State (Chanting)
    je Ret_SpellQueue         //
    //jmp Ret_SpellQueue
RemoveQueue:
    mov byte [edx+ecx],0
    call Func_ReorderQueue
    jmp Ret_SpellQueue
QueueFree:
    call Func_SetTimer
    lea edx,[QueueList]
    cmp [edx],0   //Check Queue List (Empty)
    je DecTimer
    cmp byte [edx+3],0
    jne Ret_SpellQueue
    movzx eax,byte [ebx+1322]
    cmp byte [edx],al
    jne Ret_SpellQueue
    inc byte [edx+3]
    shr word [edx],8
    shr word [edx+1],8
  //  mov [QueueList],edx
DecTimer:
    cmp word [ebx+1BE],0
    je Ret_SpellQueue
    dec word [ebx+1BE]
    jmp Ret_SpellQueue
Unison_Exit:
    lea ecx,[QueueList]
    mov byte [ecx+3],0
    jmp DecTimer

Queue_Exit:
    lea edx,[QueueList]
    cmp word [edx],0
    jne Queue_Exit2
    cmp byte [edx+2],0
    jne Queue_Exit2
    jmp Ret_SpellQueue
Queue_Exit2:
    call Func_CheckQueue
    jmp RemoveQueue
//============================================================================//
Mem_UnlockTimer:
    // Unlock before the native/expanded busy-clear hook at +28118.
    // Replay the displaced slot load without changing registers or flags.
    movzx ecx,byte [esi+13AB0]
    mov byte [QueueList+3],0
    jmp Ret_SpellQueueEnd
//===[Functions]==============================================================//
Func_CheckQueue:
    xor ecx,ecx
    movzx eax,byte [ebx+1322]   //Char ID
CheckQueueLoop:
    cmp byte [edx+ecx],0
    je FoundChar
    cmp byte [edx+ecx],al
    je FoundChar
    inc ecx
    cmp ecx,2
    jbe CheckQueueLoop
FoundChar:
    ret
/*
AddToQueue:
    xor ecx,ecx
    movzx eax,byte [ebx+1322]
AddToQueueLoop:
    test byte [QueueList+ecx],al
    jnz FoundChar
    inc ecx
    cmp ecx,3
    jbe AddToQueueLoop
FoundSlot:
    ret
*/
Func_SetTimer:
    cmp word [ebx+1BE],0    //Check Spell Time
    jne TimerSet            //
    mov word [ebx+1BE],1
TimerSet:
    ret

Func_ReorderQueue:
    mov eax,[QueueList]
    xor ecx,ecx
    xor edx,edx
ReorderQueueLoop:
    test al,al
    jz IncReorderQueue
    shl edx,8
    mov dl,al
IncReorderQueue:
    shr eax,8
    inc ecx
    cmp ecx,2
    jbe ReorderQueueLoop
    mov [QueueList],edx
    ret

//============================================================================//
SpellQueue:
    jmp Mem_SpellQueue
    nop 8
    nop 2
Ret_SpellQueue:

SpellQueueEnd:
    jmp Mem_UnlockTimer
    nop 2
Ret_SpellQueueEnd:

[DISABLE]

SpellQueue:
    db 74 1F
    db 0F B6 93 B0 3A 01 00
    db 8B 3D DC 2E AD 00

SpellQueueEnd:
    db 0F B6 8E B0 3A 01 00

dealloc(Mem_SpellQueue)
dealloc(QueueList)

unregistersymbol(SpellQueue)
unregistersymbol(Ret_SpellQueue)
unregistersymbol(SpellQueueEnd)
unregistersymbol(QueueList)


{
// ORIGINAL CODE - INJECTION POINT: TOS.exe+2722E

TOS.exe+27203: 8B C3                          - mov eax,ebx
TOS.exe+27205: E8 06 88 00 00                 - call TOS.exe+2FA10
TOS.exe+2720A: C7 83 AC 01 00 00 02 00 00 00  - mov [ebx+000001AC],00000002
TOS.exe+27214: 8B FB                          - mov edi,ebx
TOS.exe+27216: E8 25 16 00 00                 - call TOS.exe+28840
TOS.exe+2721B: F6 83 BD 36 01 00 03           - test byte ptr [ebx+000136BD],03
TOS.exe+27222: 8B 74 24 10                    - mov esi,[esp+10]
TOS.exe+27226: 75 53                          - jne TOS.exe+2727B
TOS.exe+27228: 8B 4E 38                       - mov ecx,[esi+38]
TOS.exe+2722B: F6 C1 01                       - test cl,01
// ---------- INJECTING HERE ----------
TOS.exe+2722E: 74 1F                          - je TOS.exe+2724F
// ---------- DONE INJECTING  ----------
TOS.exe+27230: 0F B6 93 B0 3A 01 00           - movzx edx,byte ptr [ebx+00013AB0]
TOS.exe+27237: 8B 3D DC 2E AD 00              - mov edi,[TOS.exe+6D2EDC]
TOS.exe+2723D: 80 BC 3A EE 93 00 00 00        - cmp byte ptr [edx+edi+000093EE],00
TOS.exe+27245: 74 08                          - je TOS.exe+2724F
TOS.exe+27247: F7 C1 00 00 00 20              - test ecx,20000000
TOS.exe+2724D: 74 2C                          - je TOS.exe+2727B
TOS.exe+2724F: 85 C0                          - test eax,eax
TOS.exe+27251: 75 28                          - jne TOS.exe+2727B
TOS.exe+27253: 0F B7 83 BE 01 00 00           - movzx eax,word ptr [ebx+000001BE]
TOS.exe+2725A: 66 85 C0                       - test ax,ax
}

{
// ORIGINAL CODE - INJECTION POINT: TOS.exe+2727B

TOS.exe+27271: 90                    - nop
TOS.exe+27272: 90                    - nop
TOS.exe+27273: 90                    - nop
TOS.exe+27274: 90                    - nop
TOS.exe+27275: 90                    - nop
TOS.exe+27276: 90                    - nop
TOS.exe+27277: 90                    - nop
TOS.exe+27278: 90                    - nop
TOS.exe+27279: 90                    - nop
TOS.exe+2727A: 90                    - nop
// ---------- INJECTING HERE ----------
TOS.exe+2727B: F6 83 90 02 00 00 10  - test byte ptr [ebx+00000290],10
// ---------- DONE INJECTING  ----------
TOS.exe+27282: 0F 85 32 01 00 00     - jne TOS.exe+273BA
TOS.exe+27288: 0F BF 83 FA 12 00 00  - movsx eax,word ptr [ebx+000012FA]
TOS.exe+2728F: 25 07 00 00 80        - and eax,80000007
TOS.exe+27294: 79 05                 - jns TOS.exe+2729B
TOS.exe+27296: 48                    - dec eax
TOS.exe+27297: 83 C8 F8              - or eax,-08
TOS.exe+2729A: 40                    - inc eax
TOS.exe+2729B: 75 72                 - jne TOS.exe+2730F
TOS.exe+2729D: 8B 46 38              - mov eax,[esi+38]
TOS.exe+272A0: A9 00 00 40 00        - test eax,TOS.exe
}

{
// ORIGINAL CODE - [END MAGIC] INJECTION POINT: TOS.exe+28105

TOS.exe+280F3: 51                       - push ecx
TOS.exe+280F4: 56                       - push esi
TOS.exe+280F5: 8B 75 08                 - mov esi,[ebp+08]
TOS.exe+280F8: 0F B6 86 B0 3A 01 00     - movzx eax,byte ptr [esi+00013AB0]
TOS.exe+280FF: 50                       - push eax
TOS.exe+28100: E8 DB 5D 04 00           - call TOS.exe+6DEE0
// ---------- INJECTING HERE ----------
TOS.exe+28105: 0F B6 8E B0 3A 01 00     - movzx ecx,byte ptr [esi+00013AB0]
// ---------- DONE INJECTING  ----------
TOS.exe+2810C: 8B 15 DC 2E AD 00        - mov edx,[TOS.exe+6D2EDC]
TOS.exe+28112: 8B 45 0C                 - mov eax,[ebp+0C]
TOS.exe+28115: 83 C4 04                 - add esp,04
// AddSpellSlots owns this busy-clear site when enabled.
TOS.exe+28118: C6 84 11 EE 93 00 00 00  - mov byte ptr [ecx+edx+000093EE],00
TOS.exe+28120: 80 60 35 FC              - and byte ptr [eax+35],-04
TOS.exe+28124: 5E                       - pop esi
TOS.exe+28125: 59                       - pop ecx
TOS.exe+28126: 5D                       - pop ebp
TOS.exe+28127: C3                       - ret
TOS.exe+28128: CC                       - int 3
TOS.exe+28129: CC                       - int 3
TOS.exe+2812A: CC                       - int 3
TOS.exe+2812B: CC                       - int 3
TOS.exe+2812C: CC                       - int 3
}
