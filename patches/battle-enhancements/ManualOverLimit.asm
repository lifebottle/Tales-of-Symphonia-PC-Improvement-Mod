// ArtesSphere / CT 2109: Detect Battle Menu
// Table script authors: sdail; see README.md for provenance and port fixes.
// Native x86 port of selected TOS NoTSFix v26.9.1 entries.
[ENABLE]
// [Manual Over Limit] (Requires Artes Sphere)
alloc(mem_payload_e785_Mem_ManualOverlimit,0xc8)
// [Manual Over Limit] (Requires Artes Sphere)
assert(TOS.exe+0x3912c,8a 8f 20 13 00 00)
// [Manual Over Limit] (Requires Artes Sphere)
assert(TOS.exe+0x3913c,0f 85 0c 03 00 00)
// [Manual Over Limit] (Requires Artes Sphere)
assert(TOS.exe+0x4e186,ba b6 03 00 00)
// [Manual Over Limit] (Requires Artes Sphere)
assert(TOS.exe+0x4e190,ba 84 03 00 00)
// player dmg gain ol
alloc(mem_payload_e757_newmem,0x4090)
// player dmg gain ol
assert(TOS.exe+0x6455c,f6 01 20 75 10)
// Disable OvL Victory Drain
assert(TOS.exe+0x80738,75 09)
assert(TOS.exe+0x80743,8b 87 40 93 00 00 f6 40 06 20 75 5b)
assert(TOS.exe+0x3944e,8a 97 22 13 00 00 80 e2 0f 80 fa 05)
assert(TOS.exe+0x64571,f7 44 24 18 00 02 00 00 74 15 6a 00)
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
registersymbol(e785_Mem_ManualOverlimit)
registersymbol(e785_Skip)
registersymbol(e785_Code_ManualOverlimit)
registersymbol(e785_Ret_ManualOverlimit)
registersymbol(e757_newmem)
registersymbol(e757_originalcode)
registersymbol(e757_base_atk)
registersymbol(e757_afterbase)
registersymbol(e757_cap)
registersymbol(e757_acap)
registersymbol(e757_nocap)
registersymbol(e757_exit)
registersymbol(e757_div_value)
registersymbol(e757_min_value)
registersymbol(e757_returnhere)


// [Manual Over Limit] (Requires Artes Sphere)
mem_payload_e785_Mem_ManualOverlimit:
e785_Mem_ManualOverlimit:

// [Manual Over Limit] (Requires Artes Sphere)
mem_payload_e785_Mem_ManualOverlimit:
  push eax
  movzx eax,byte ptr [edi+0x1322]
  and al,0x0F
  cmp al,0x0
  jle e785_Skip
// Use the actor's live control mode, not the saved party-slot setting.
// Bits 2..4 are mode: 0/1 human, 2 AI (game mode cycling at +692DD).
// Keep native activation for enemies and non-human modes.
  movzx eax,byte ptr [edi+0x1320]
  test al,0x1
  jne e785_Skip
  and eax,0x1C
  cmp eax,0x8
  jae e785_Skip
  movzx eax,byte ptr [edi+0x1321]
  and eax,0x3
  imul eax,eax,0x10
  cmp byte ptr [StoredControls+eax+0xB],0x1
  pop eax
  jne TOS.exe+0x3944E
  jmp e785_Code_ManualOverlimit
e785_Skip:
  pop eax
e785_Code_ManualOverlimit:
  mov cl,[edi+0x00001320]
  jmp e785_Ret_ManualOverlimit

// [Manual Over Limit] (Requires Artes Sphere)
TOS.exe+0x3912c:
  jmp e785_Mem_ManualOverlimit
  nop
e785_Ret_ManualOverlimit:

// [Manual Over Limit] (Requires Artes Sphere)
TOS.exe+0x3913c:
  nop #6

// [Manual Over Limit] (Requires Artes Sphere)
TOS.exe+0x4e186:
  mov edx,#2000

// [Manual Over Limit] (Requires Artes Sphere)
TOS.exe+0x4e190:
  mov edx,#1000

// ManualOverLimit / CT 757: player dmg gain ol

// player dmg gain ol
mem_payload_e757_newmem:
e757_newmem:

// player dmg gain ol
mem_payload_e757_newmem:
e757_originalcode:
  push eax
  mov al,[esi+0x1322]
  and al,0x0F
  cmp al,0x0
  jle e757_nocap
  mov al,[esi+0x1321]
  test al,0x80
  jne e757_nocap
  mov ax,[esi+0x134c]
  movzx eax,ax
  push ebx
  mov bx,[ecx+0x0E]
  movzx ebx,bx
  cmp ebx,0x0
  je e757_base_atk
  push eax
  mov eax,ebx
  mov ebx,[e757_div_value]
// Unsigned division consumes EDX:EAX; preserve the game's EDX.
  push edx
  xor edx, edx
  div ebx
  pop edx
  mov ebx,eax
  pop eax
  cmp ebx,[e757_min_value]
  jl e757_base_atk
  jmp e757_afterbase
e757_base_atk:
  mov ebx,[e757_min_value]
e757_afterbase:
  add eax,ebx
  pop ebx
  cmp eax,0x3e8
  jg e757_cap
  jmp e757_acap
e757_cap:
  mov eax,0x3e8
e757_acap:
  mov [esi+0x134c],ax
e757_nocap:
  pop eax
  test byte ptr [ecx],0x20
  jne TOS.exe+0x64571
e757_exit:
  jmp e757_returnhere
e757_div_value:
  dd 0x8
e757_min_value:
  dd 0x0A

// player dmg gain ol
TOS.exe+0x6455c:
  jmp e757_newmem
e757_returnhere:

// OverLimitGauge / CT 726: Over Limit Gauge

// Disable OvL Victory Drain
TOS.exe+0x80738:
// Preserve the two-byte patch boundary of the original short JNZ.
  jmp short OverLimitVictoryEnd

// NewFreeRun / CT 2189: Math Functions

// NewFreeRun / CT 2159: New Stick Walk Check
