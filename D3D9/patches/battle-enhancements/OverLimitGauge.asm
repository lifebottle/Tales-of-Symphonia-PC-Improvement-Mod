// ArtesSphere / CT 2109: Detect Battle Menu
// Table script authors: sdail; see README.md for provenance and port fixes.
// Native x86 port of selected TOS NoTSFix v26.9.1 entries.
[ENABLE]
// Over Limit Gauge
alloc(mem_payload_e726_newmem,0x4090)
// Over Limit Gauge
alloc(mem_payload_e726_tempstr,0x4)
// Over Limit Gauge
assert(TOS.exe+0x49ee0,e8 fb 1d 03 00)
assert(TOS.exe+0x7bce0,53 8b dc 83 ec 08 83 e4 f0 83 c4 04)
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
registersymbol(e726_newmem)
registersymbol(e726_tempstr)
registersymbol(e726_originalcode)
registersymbol(e726_exit)
registersymbol(e726_returnhere)


// Over Limit Gauge
mem_payload_e726_newmem:
e726_newmem:

// Over Limit Gauge
mem_payload_e726_tempstr:
e726_tempstr:

// Over Limit Gauge
mem_payload_e726_newmem:
e726_originalcode:
  call TOS.exe+0x7BCE0
  fldz
  mov edi,esi
  xor ecx,ecx
  mov edx,0x000002BD
  fst dword ptr [ebp-0x5C]
  mov [ebp-0x7C],ecx
  fstp dword ptr [ebp-0x58]
  mov ecx,edx
  mov [ebp-0x72],dx
  mov edx,0x000002C6
  xor eax,eax
  mov [ebp-0x6A],dx
  mov [ebp-0x66],edx
  xor edx,edx
  mov [ebp-0x78],eax
  lea eax,[edi+0x54]
  mov [ebp-0x6E],cx
  mov [ebp-0x62],dx
  mov [ebp-0x54],dl
  mov [ebp-0x4F],dx
  lea ecx,[ebp-0x7C]
  or edx,-0x01
  mov [ebp-0x74],di
  mov [ebp-0x70],ax
  mov [ebp-0x6C],di
  mov [ebp-0x68],ax
  mov DWORD PTR [ebp-0x53],0x0001040C
  mov [ebp-0x4D],bl
  call TOS.exe+0x7BCE0
  mov eax,[ebp-0x00000094]
  lea ecx,[ebp-0x7c]
  push edx
  push eax
  push edi
  mov edx,eax
  mov ecx,[edx+0x08]
  mov ax,[eax+0x134c]
  movzx eax,ax
  mov ecx,0x3E8
  imul eax,eax,0x64
  cdq
  idiv ecx
  imul eax,eax,0x54
  fldz
  fst dword ptr [ebp-0x5C]
  fstp dword ptr [ebp-0x58]
  mov ecx,eax
  mov eax,0x51EB851F
  imul ecx
  sar edx,0x05
  mov eax,edx
  shr eax,0x1F
  add eax,edx
  xor ecx,ecx
  mov [e726_tempstr],ax
  mov edi,[e726_tempstr]
  mov [ebp-0x7C],ecx
  xor eax,eax
  mov edx,0x000002B7
  mov ecx,edx
  mov [ebp-0x72],dx
  mov [ebp-0x78],eax
  mov edx,0x000002C0
  mov [ebp-0x6A],dx
  mov [ebp-0x66],edx
  xor edx,edx
  lea eax,[esi+edi]
  mov [ebp-0x70],ax
  mov [ebp-0x68],ax
  mov eax,[ebp-0x000000E4]
  mov [ebp-0x6E],cx
  mov ecx,[ebp-0x000000E0]
  mov [ebp-0x62],dx
  mov [ebp-0x54],dl
  mov edx,[ebp-0x000000DC]
  mov DWORD PTR [ebp-0x50],0xFFFFFFFF
  mov [ebp-0x50],eax
  mov eax,[ebp-0x000000D8]
  mov [ebp-0x4C],ecx
  mov [ebp-0x48],edx
  lea ecx,[ebp-0x7C]
  or edx,-0x01
  mov [ebp-0x74],si
  mov [ebp-0x6C],si
  mov word ptr [ebp-0x53],0x040C
  mov byte ptr [ebp-0x51],0x04
  mov [ebp-0x44],eax
  mov edx,0xFF105020
  mov [ebp-0x50],edx
  mov [ebp-0x48],edx
  mov edx,0xFF409090
  mov [ebp-0x4c],edx
  mov [ebp-0x44],edx
  pop edi
  pop eax
  pop edx
  mov edx,0xFFFFFFFF
  mov eax,0xFFFFFFFF
  call TOS.exe+0x7BCE0
e726_exit:
  jmp e726_returnhere

// Over Limit Gauge
mem_payload_e726_tempstr:

// Over Limit Gauge
TOS.exe+0x49ee0:
  jmp e726_newmem
e726_returnhere:

// DisableOvLVictoryDrain / CT 2285: Disable OvL Victory Drain
