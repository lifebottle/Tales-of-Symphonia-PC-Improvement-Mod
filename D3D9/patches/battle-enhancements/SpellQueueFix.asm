// ArtesSphere / CT 2109: Detect Battle Menu
// Table script authors: sdail; see README.md for provenance and port fixes.
// Native x86 port of selected TOS NoTSFix v26.9.1 entries.
[ENABLE]
// CT 2692: [Spell Queue Fix]
alloc(mem_ct_2692_alloc_0,0xa00)
// CT 2692: [Spell Queue Fix]
assert(TOS.exe+0x2722e,74 1f 0f b6 93 b0 3a 01 00 8b 3d dc 2e ad 00)
// CT 2692: [Spell Queue Fix]
alloc(mem_ct_2692_state_3,0x4)
assert(TOS.exe+0x2722e,74 1f 0f b6 93 b0 3a 01 00 8b 3d dc 2e ad 00)
assert(TOS.exe+0x27245,74 08 f7 c1 00 00 00 20)
assert(TOS.exe+0x2722e,74 1f 0f b6 93 b0 3a 01 00 8b 3d dc 2e ad 00)
assert(TOS.exe+0x27245,74 08 f7 c1 00 00 00 20 74 2c 85 c0 75 28 0f b7 83 be 01 00 00 66 85 c0 74 08 48 66 89 83 be 01 00 00 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90)
assert(TOS.exe+0x2727b,f6)
assert(TOS.exe+0x2727b,f6 83 90 02 00 00 10 0f)
assert(TOS.exe+0x2727b,f6 83 90 02 00 00 10 0f 85 32 01 00 00 0f bf 83 fa 12 00 00 25 07 00 00 80)
define(BattleMenu_Enter,TOS.exe+0x5d8a3)
define(BattleMenu_Exit,TOS.exe+0x5d8f7)
define(ShortcutState_Exit,TOS.exe+0x124c02)
define(ShortcutState_Enter,TOS.exe+0x1255e6)
define(ArtesMenu_Enter,TOS.exe+0x124d98)
define(ArtesMenu_Exit,TOS.exe+0x124eb3)
define(ArtesMenuHMN_Exit,TOS.exe+0x125617)
define(ArtesMenuCPU_Exit,TOS.exe+0x1265ad)
define(UnisonMenu_Enter,TOS.exe+0x127b3a)
define(UnisonMenu_Exit,TOS.exe+0x1280be)
define(CharState,TOS.exe+0x497aa)
define(ButtonInputs,TOS.exe+0x211a73)
define(ArtePageIndicator,TOS.exe+0x120b83)
define(UnisonPageIndicator,TOS.exe+0x1270f0)
define(BattleArteBuffer,TOS.exe+0x75d2c)
define(BattleArteBufferCombo,TOS.exe+0x346a5)
define(BattleArteBufferAir,TOS.exe+0x75a1f)
define(BattleArte,TOS.exe+0x75d3f)
define(BattleArteSelect,TOS.exe+0x76129)
define(BattleArteCombo,TOS.exe+0x346be)
define(BattleArteSelectCombo,TOS.exe+0x34811)
define(BattleArteSelectAir,TOS.exe+0x75a5f)
define(BattleArteCommand1,TOS.exe+0x751d9)
define(BattleArteCommand2,TOS.exe+0x75214)
define(BattleArteChar1_A,TOS.exe+0x75d62)
define(BattleArteChar2_A,TOS.exe+0x75d82)
define(BattleArteSelectShortcut1_B,TOS.exe+0x7614e)
define(BattleArteSelectShortcut2_B,TOS.exe+0x7618f)
define(BattleArteChar1Combo,TOS.exe+0x346fc)
define(BattleArteChar1Air,TOS.exe+0x75a9f)
define(BattleArteChar2Air,TOS.exe+0x75ad5)
define(BattleArteUnison,TOS.exe+0x722f8)
define(LeftTriggerFix,TOS.exe+0x2111d7)
define(RightTriggerFix,TOS.exe+0x2111eb)
define(DisableRStickX,TOS.exe+0x211abe)
define(DisableRStickY,TOS.exe+0x211ac4)
define(RemoveShortcutFix,TOS.exe+0x125348)
define(ManualOverlimit,TOS.exe+0x3912c)
define(DisableOverlimitPartyLimit,TOS.exe+0x3913c)
define(OverlimitPortrait,TOS.exe+0x4e186)
define(OverLimitVictoryEmpty,TOS.exe+0x80738)
define(MathFunctions,TOS.exe+0x2e7cf0)
define(StickWalkCheck,TOS.exe+0x76794)
define(FreeRun2,TOS.exe+0x84cc9)
define(MoveSideCheck,TOS.exe+0x84d15)
define(BattleState,TOS.exe+0x718652)
define(OverLimitVictoryEnd,TOS.exe+0x80743)
define(game_2727b,TOS.exe+0x2727b)
define(game_6d2edc,TOS.exe+0x6d2edc)
define(game_2722e,TOS.exe+0x2722e)
define(ct_base_ct_2692_patch_2,TOS.exe+0x2727b)
define(e2692_site_3,TOS.exe+0x2727b)
registersymbol(e2692_Mem_SpellQueue)
registersymbol(e2692_AddQueueLoop)
registersymbol(e2692_RotateQueue)
registersymbol(e2692_DecTimer)
registersymbol(e2692_RemoveQueue)
registersymbol(e2692_Func_CheckQueue)
registersymbol(e2692_CheckQueueLoop)
registersymbol(e2692_FoundChar)
registersymbol(e2692_Func_ReorderQueue)
registersymbol(e2692_ReorderQueueLoop)
registersymbol(e2692_IncReorderQueue)
registersymbol(e2692_site_2)
registersymbol(e2692_QueueList)


// CT 2692: [Spell Queue Fix]
mem_ct_2692_alloc_0:
ct_base_ct_2692_alloc_0:
e2692_Mem_SpellQueue:
  test eax,eax
  jne game_2727b
  cmp byte ptr [ebx+0x1b0],0xc
  jne e2692_RemoveQueue
  movzx eax,word ptr [ebx+0x1be]
  movzx edx,byte ptr [ebx+0x13ab0]
  mov edi,[game_6d2edc]
// AddSpellSlots attaches its slot-2 buffer before assigning logical slots 6..9.
// Their busy flags are at buffer-0x8f80+(slot-6). Preserve EDI and CMP flags.
  cmp edx,#6
  jb e2692_NativeBusy
  cmp edx,#9
  ja e2692_NativeBusy
  push edi
  mov edi,[edi+0x16f950]
  cmp byte ptr [edi+edx-0x8f86],#0
  pop edi
  jmp e2692_BusyDone
e2692_NativeBusy:
  cmp byte ptr [edx+edi+0x93ee],0x0
e2692_BusyDone:
  je e2692_DecTimer
  test ax,ax
  jnz e2692_DecTimer
  call e2692_Func_CheckQueue
  cmp ecx,0x3
  jbe game_2727b
  xor ecx,ecx
  mov eax,[e2692_QueueList]
e2692_AddQueueLoop:
  test al,al
  jnz e2692_RotateQueue
  mov al,byte ptr [ebx+0x1322]
  imul ecx,0x8
  rol eax,cl
  mov [e2692_QueueList],eax
  jmp game_2727b
e2692_RotateQueue:
  inc ecx
  ror eax,0x8
  jmp e2692_AddQueueLoop
e2692_DecTimer:
  test ax,ax
  jz game_2727b
  dec eax
  mov [ebx+0x1be],ax
  jmp game_2727b
e2692_RemoveQueue:
  call e2692_Func_CheckQueue
  cmp ecx,0x3
  ja game_2727b
  mov byte ptr [e2692_QueueList+ecx],0x0
  call e2692_Func_ReorderQueue
  jmp game_2727b
e2692_Func_CheckQueue:
  xor ecx,ecx
  movzx eax,byte ptr [ebx+0x1322]
e2692_CheckQueueLoop:
  cmp byte ptr [e2692_QueueList+ecx],al
  je e2692_FoundChar
  inc ecx
  cmp ecx,0x3
  jbe e2692_CheckQueueLoop
e2692_FoundChar:
  ret
e2692_Func_ReorderQueue:
  mov eax,[e2692_QueueList]
  xor ecx,ecx
  xor edx,edx
e2692_ReorderQueueLoop:
  test al,al
  jz e2692_IncReorderQueue
  shl edx,0x8
  mov dl,al
e2692_IncReorderQueue:
  shr eax,0x8
  inc ecx
  cmp ecx,0x3
  jbe e2692_ReorderQueueLoop
  mov [e2692_QueueList],edx
  ret

// CT 2692: [Spell Queue Fix]
TOS.exe+0x2722e:
ct_base_ct_2692_patch_1:
e2692_site_2:
  jmp e2692_Mem_SpellQueue
  nop #8
  nop #2

// CT 2692: [Spell Queue Fix]
mem_ct_2692_state_3:
ct_base_ct_2692_state_3:
e2692_QueueList:
  db #0
