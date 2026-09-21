// ArtesSphere / CT 2109: Detect Battle Menu
// Table script authors: sdail; see README.md for provenance and port fixes.
// Native x86 port of selected TOS NoTSFix v26.9.1 entries.
[ENABLE]
// New Stick Walk Check
alloc(mem_payload_e2159_Mem_StickWalkCheck,0xc8)
// New Stick Walk Check
assert(TOS.exe+0x76794,f6 04 95 a8 37 ad 00 08)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_e47_newmem6,0x4090)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_freerun_mem,0x128)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_e47_newmem5,0x4090)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_e47_newmem4,0x4090)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_e47_newmem3,0x4090)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_e47_newmem2,0x4090)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_e47_newmem,0x4090)
// fr poc 1 (Disables Jump During Freerun)
alloc(mem_payload_e47_chr_freerun,0x4)
// fr poc 1 (Disables Jump During Freerun)
assert(TOS.exe+0x765a4,7a 20 d9 87 d8 38 01 00)
// fr poc 1 (Disables Jump During Freerun)
assert(TOS.exe+0x76455,7a 20 d9 87 d8 38 01 00)
// fr poc 1 (Disables Jump During Freerun)
assert(TOS.exe+0x766f7,7a 2c d9 87 d8 38 01 00)
// fr poc 1 (Disables Jump During Freerun)
assert(TOS.exe+0x76351,7a 2c d9 87 d8 38 01 00)
// fr poc 1 (Disables Jump During Freerun)
assert(TOS.exe+0x767af,66 83 b8 72 37 ad 00 28)
// fr poc 1 (Disables Jump During Freerun)
assert(TOS.exe+0x761c9,8b 04 85 a8 37 ad 00)
// Free Run 2
alloc(mem_payload_e2161_Mem_FreeRun2,0xa24)
// Free Run 2
alloc(mem_payload_e2161_mval,0x64)
// Free Run 2
alloc(mem_payload_MovementSpeed,0x4)
// Free Run 2
alloc(mem_payload_PenaltySpeed,0x4)
// Free Run 2
assert(TOS.exe+0x84cc9,81 c1 58 39 01 00)
// Free Run 3 (Fix directly above or below enemy)
alloc(mem_payload_e2752_Mem_MoveSideCheck,0x2000)
// Free Run 3 (Fix directly above or below enemy)
assert(TOS.exe+0x84d15,8d 44 24 18 e8 52 a0 0f 00)
assert(TOS.exe+0x7637f,d9 87 d8 38 01 00 d9 9f cc 38 01 00)
assert(TOS.exe+0x76477,d9 87 d8 38 01 00 dd 05 10 2a 88 00)
assert(TOS.exe+0x765c6,d9 87 d8 38 01 00 dd 05 10 2a 88 00)
assert(TOS.exe+0x76725,d9 87 d8 38 01 00 d9 9f cc 38 01 00)
assert(TOS.exe+0x7684d,8b 15 dc 2e ad 00 80 a7 bd 39 01 00)
assert(TOS.exe+0x84cd4,d9 ee 8b 8b a0 38 01 00 8b 83 9c 38)
assert(TOS.exe+0x17ed70,55 8b ec 83 e4 f8 83 ec 3c d9 00 53)
assert(TOS.exe+0x2e7ce4,ff 25 b0 33 70 00 ff 25 b4 33 70 00)
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
registersymbol(e2159_Mem_StickWalkCheck)
registersymbol(e2159_FailedStick)
registersymbol(e2159_Code_StickWalkCheck)
registersymbol(e2159_Ret_StickWalkCheck)
registersymbol(e47_newmem6)
registersymbol(freerun_mem)
registersymbol(e47_newmem5)
registersymbol(e47_newmem4)
registersymbol(e47_newmem3)
registersymbol(e47_newmem2)
registersymbol(e47_newmem)
registersymbol(e47_chr_freerun)
registersymbol(e47_originalcode6)
registersymbol(e47_here_do)
registersymbol(e47_exit6)
registersymbol(e47_returnhere6)
registersymbol(e47_originalcode5)
registersymbol(e47_here_go)
registersymbol(e47_exit5)
registersymbol(e47_returnhere5)
registersymbol(e47_originalcode4)
registersymbol(e47_exit4)
registersymbol(e47_returnhere4)
registersymbol(e47_originalcode3)
registersymbol(e47_exit3)
registersymbol(e47_returnhere3)
registersymbol(e47_originalcode2)
registersymbol(e47_exit2)
registersymbol(e47_returnhere2)
registersymbol(e47_originalcode)
registersymbol(e47_StateCheck)
registersymbol(e47_rwalk)
registersymbol(e47_lwalk)
registersymbol(e47_erflag)
registersymbol(e47_adflag)
registersymbol(e47_life)
registersymbol(e47_after)
registersymbol(e47_death)
registersymbol(e47_exit)
registersymbol(e47_tst)
registersymbol(e47_returnhere)
registersymbol(e2161_Mem_FreeRun2)
registersymbol(e2161_mval)
registersymbol(MovementSpeed)
registersymbol(PenaltySpeed)
registersymbol(e2161_DashCheck)
registersymbol(e2161_FoundDash)
registersymbol(e2161_NotFoundDash)
registersymbol(e2161_DashEnd)
registersymbol(e2161_non_ghost)
registersymbol(e2161_Code_FreeRun2)
registersymbol(e2161_fcalc)
registersymbol(e2161_Ret_FreeRun2)
registersymbol(e2752_Mem_MoveSideCheck)
registersymbol(e2752_NotFreerun)
registersymbol(e2752_Ret_MoveSideCheck)


// New Stick Walk Check
mem_payload_e2159_Mem_StickWalkCheck:
e2159_Mem_StickWalkCheck:

// New Stick Walk Check
mem_payload_e2159_Mem_StickWalkCheck:
  push edx
  movzx edx,byte ptr [edi+0x1321]
  and edx,0x3
  imul edx,0x10
  test byte ptr [StoredControls+edx+0xA],0xFF
  jne e2159_FailedStick
  pop edx
  test byte ptr [edx*0x4+TOS.exe+0x6D37A8],0x8
  jmp e2159_Ret_StickWalkCheck
e2159_FailedStick:
  mov edx,0x1
  pop edx
  jmp e2159_Ret_StickWalkCheck
e2159_Code_StickWalkCheck:
  jmp e2159_Ret_StickWalkCheck

// New Stick Walk Check
TOS.exe+0x76794:
  jmp e2159_Mem_StickWalkCheck
  nop #3
e2159_Ret_StickWalkCheck:

// NewFreeRun / CT 47: fr poc 1 (Disables Jump During Freerun)

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem6:
e47_newmem6:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_freerun_mem:
freerun_mem:
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem5:
e47_newmem5:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem4:
e47_newmem4:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem3:
e47_newmem3:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem2:
e47_newmem2:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem:
e47_newmem:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_chr_freerun:
e47_chr_freerun:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem6:
e47_originalcode6:
  push ebx
  mov ebx,[e47_chr_freerun]
  cmp ebx,0x0
  pop ebx
  jg e47_here_do
  test ah,0x05
  jp TOS.exe+0x765C6
e47_here_do:
  fld dword ptr [edi+0x000138D8]
e47_exit6:
  jmp e47_returnhere6

// fr poc 1 (Disables Jump During Freerun)
TOS.exe+0x765a4:
  jmp e47_newmem6
  nop #3
e47_returnhere6:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem5:
e47_originalcode5:
  push ebx
  mov ebx,[e47_chr_freerun]
  cmp ebx,0x0
  pop ebx
  jg e47_here_go
  test ah,0x05
  jp TOS.exe+0x76477
e47_here_go:
  fld dword ptr [edi+0x000138D8]
e47_exit5:
  jmp e47_returnhere5

// fr poc 1 (Disables Jump During Freerun)
TOS.exe+0x76455:
  jmp e47_newmem5
  nop #3
e47_returnhere5:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem4:
e47_originalcode4:
  jp TOS.exe+0x76725
  push eax
  mov eax,[e47_chr_freerun]
  cmp eax,0x0
  pop eax
  jg TOS.exe+0x76725
  fld dword ptr [edi+0x000138D8]
e47_exit4:
  jmp e47_returnhere4

// fr poc 1 (Disables Jump During Freerun)
TOS.exe+0x766f7:
  jmp e47_newmem4
  nop #3
e47_returnhere4:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem3:
e47_originalcode3:
  jp TOS.exe+0x7637F
  push eax
  mov eax,[e47_chr_freerun]
  cmp eax,0x0
  pop eax
  jg TOS.exe+0x7637F
  fld dword ptr [edi+0x000138D8]
e47_exit3:
  jmp e47_returnhere3

// fr poc 1 (Disables Jump During Freerun)
TOS.exe+0x76351:
  jmp e47_newmem3
  nop #3
e47_returnhere3:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem2:
e47_originalcode2:
  push eax
  mov eax,[e47_chr_freerun]
  cmp eax,0x0
  pop eax
  jne TOS.exe+0x7684D
  cmp word ptr [eax+TOS.exe+0x6D3772],0x28
e47_exit2:
  jmp e47_returnhere2

// fr poc 1 (Disables Jump During Freerun)
TOS.exe+0x767af:
  jmp e47_newmem2
  nop #3
e47_returnhere2:

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_newmem:
e47_originalcode:
  push ebx
  push esi
  xor ebx,ebx
  mov [e47_chr_freerun],ebx
  mov ebx,eax
  mov eax,[eax*0x4+TOS.exe+0x6D37A8]
  movzx ecx,dl
  and ecx,0x3
  imul ecx,ecx,0x10
  cmp byte ptr [edi+0x1B0],0x4
  je e47_StateCheck
  cmp byte ptr [edi+0x1B0],0x5
  je e47_StateCheck
  cmp byte ptr [edi+0x1B0],0x2
  ja e47_death
e47_StateCheck:
  cmp byte ptr [StoredControls+ecx+0xA],0x0
  je e47_death
  test eax,0x4000
  jne e47_death
  and dl,0x3
  movzx ecx,dl
  mov dl,0x1
  shl dl,cl
  or byte ptr [FreeRunActive],dl
  mov dl,byte ptr [edi+0x1321]
  mov DWORD PTR [e47_chr_freerun],0x1
  movzx eax, WORD PTR [ebx*0x4+TOS.exe+0x6D37AA]
  cmp al,0x00
  jle e47_death
  mov ebx,eax
  mov eax,0x00080008
  mov esi,[edi+0x1321]
  cmp bl,0x08
  je e47_rwalk
  cmp bl,0x04
  je e47_lwalk
e47_rwalk:
  test dl,0x10
  jne e47_erflag
  jmp e47_after
e47_lwalk:
  test dl,0x10
  je e47_adflag
  jmp e47_after
e47_erflag:
  sub dl,0x10
  jmp e47_after
e47_adflag:
  add dl,0x10
  jmp e47_after
e47_life:
e47_after:
e47_death:
  pop esi
  pop ebx
e47_exit:
  jmp e47_returnhere

// fr poc 1 (Disables Jump During Freerun)
mem_payload_e47_chr_freerun:
  dd #0
e47_tst:

// fr poc 1 (Disables Jump During Freerun)
TOS.exe+0x761c9:
  jmp e47_newmem
  nop #2
e47_returnhere:

// NewFreeRun / CT 2161: Free Run 2

// Free Run 2
mem_payload_e2161_Mem_FreeRun2:
e2161_Mem_FreeRun2:

// Free Run 2
mem_payload_e2161_mval:
e2161_mval:

// Free Run 2
mem_payload_MovementSpeed:
MovementSpeed:
  db 00, 00, 00, 00

// Free Run 2
mem_payload_PenaltySpeed:
PenaltySpeed:

// Free Run 2
mem_payload_PenaltySpeed:
  dd (float)0.20

// Free Run 2
mem_payload_e2161_Mem_FreeRun2:
  add ecx,0x00013958
  push ecx
  push edx
  push eax
  push ebx
  push esi
  movzx eax,byte ptr [ebx+0x1322]
  cmp eax,0x0
  je e2161_non_ghost
  movzx eax,byte ptr [ebx+0x1321]
  and eax,0x03
  imul eax,eax,0x10
  xor ecx,ecx
e2161_DashCheck:
  cmp ecx,0x4
  je e2161_NotFoundDash
  mov edx,[ebx]
  movzx edx,byte ptr [edx+ecx+0xEE]
  cmp dl,0x6
  je e2161_FoundDash
  inc ecx
  jmp e2161_DashCheck
e2161_FoundDash:
  mov DWORD PTR [MovementSpeed],0x3f933333
  jmp e2161_DashEnd
e2161_NotFoundDash:
  mov DWORD PTR [MovementSpeed],0x3f800000
e2161_DashEnd:
  mov ecx,[MovementSpeed]
  mov [ebx+0x12EC],ecx
  cmp byte ptr [StoredControls+eax+0xA],0x0
  je e2161_non_ghost
  movss xmm5,dword ptr [MovementSpeed]
  subss xmm5,dword ptr [PenaltySpeed]
  movss dword ptr [ebx+0x12EC],xmm5
  movzx eax,byte ptr [ebx+0x1321]
  and eax,0x03
  push ebx
  imul ebx,eax,0x10
  movsx ecx, WORD PTR [ebx+TOS.exe+0x6D3770]
  movsx edx, WORD PTR [ebx+TOS.exe+0x6D3772]
  pop ebx
  movd xmm3,ecx
  movd xmm5,edx
  cvtdq2ps xmm3,xmm3
  cvtdq2ps xmm5,xmm5
  mulss xmm3,[e2161_mval+0x4]
  mulss xmm5,[e2161_mval+0x4]
  mulss xmm3,[e2161_mval+0x1c]
  movss [e2161_fcalc+0x30],xmm3
  movss [e2161_fcalc+0x38],xmm5
  fld DWORD PTR [e2161_fcalc+0x30]
  fld DWORD PTR [e2161_fcalc+0x38]
  call MathFunctions-0xC
  fstp DWORD PTR [e2161_fcalc+0x28]
  push edx
  mov edx,[TOS.exe+0x6D2EDC]
  movss xmm6,[e2161_mval+0x0c]
  movss xmm7,[e2161_mval+0x10]
  divss xmm6,xmm7
  movss xmm7,[edx+0x50]
  mulss xmm7,xmm6
  addss xmm7,[e2161_fcalc+0x28]
  movss [e2161_fcalc],xmm7
  fld DWORD PTR [e2161_fcalc]
  FSINCOS
  fstp DWORD PTR [e2161_fcalc]
  fstp DWORD PTR [e2161_fcalc+0x4]
  pop edx
  movss xmm6,[e2161_fcalc+0x4]
  movss xmm7,[e2161_fcalc]
  mulss xmm7,[e2161_mval+0x1c]
  mulss xmm6,[e2161_mval+0x1c]
  movss [esi+0x8],xmm6
  movss [esi],xmm7
  xor eax,eax
  pop esi
  pop ebx
  pop eax
  pop edx
  pop ecx
  jmp FreeRun2+0xB
e2161_non_ghost:
  pop esi
  pop ebx
  pop eax
  pop edx
  pop ecx
e2161_Code_FreeRun2:
  jmp e2161_Ret_FreeRun2

// Free Run 2
mem_payload_e2161_mval:
  align 0x2
  dd 0x3c23d70a
  dd 0x3fb33333
  dd 0x3dcccccd
  dd 0x40490fdb
  dd 0x43340000
  dd 0xc2b40000
  dd 0x42c80000
  dd 0xbf800000
e2161_fcalc:

// Free Run 2
TOS.exe+0x84cc9:
  jmp e2161_Mem_FreeRun2
  nop
e2161_Ret_FreeRun2:

// NewFreeRun / CT 2752: Free Run 3 (Fix directly above or below enemy)

// Free Run 3 (Fix directly above or below enemy)
mem_payload_e2752_Mem_MoveSideCheck:
e2752_Mem_MoveSideCheck:

// Free Run 3 (Fix directly above or below enemy)
mem_payload_e2752_Mem_MoveSideCheck:
  movzx eax,byte ptr [ebx+0x1322]
  cmp eax,0x0
  je e2752_NotFreerun
  movzx eax,byte ptr [ebx+0x1321]
  and eax,0x3
  imul eax,0x10
  cmp byte ptr [StoredControls+eax+0xA],0x0
  jne e2752_Ret_MoveSideCheck
e2752_NotFreerun:
  lea eax,[esp+0x18]
  call TOS.exe+0x17ED70
  jmp e2752_Ret_MoveSideCheck

// Free Run 3 (Fix directly above or below enemy)
TOS.exe+0x84d15:
  jmp e2752_Mem_MoveSideCheck
  nop #4
e2752_Ret_MoveSideCheck:

// CT #2692: Spell Queue Fix (sdail), converted from v26.9.1.
