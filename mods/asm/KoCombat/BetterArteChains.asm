//######################################################################################################
//# Better Arte Chains - KoCombat
//# Recovery Thresholds, Ability Plus / Super Chain and Lloyd Level 3 Chaining Windows
//# Lloyd descriptor validation adapted from Lloyd Super Chain
//######################################################################################################

[ENABLE]

//################################################
//# Verify original instructions
//################################################

assert(TOS.exe+0x3479B,0F B7 9F 1C 14 00 00)
assert(TOS.exe+0x3F0DE,8A C3 24 0F 3C 01 8B C6)
assert(TOS.exe+0x3F665,0F B7 87 6C 13 00 00 24 0F 3C 01 8B C7)
assert(TOS.exe+0x678E0,8B 8D C4 FE FF FF)
assert(TOS.exe+0x678E6,83 39 09 7F 0C C7 85 DC FE FF FF 00 00 00 00 EB)

//################################################
//# Memory allocations
//################################################

alloc(mem_BACRecoveryData,0x400)
alloc(mem_BACRecoveryCode,0x400)
alloc(mem_BACAbilityCode,0x400)
alloc(mem_BACDescriptorCode,0x1000)
alloc(mem_BACStatus,0x20)
alloc(mem_BACRows,0x18C)

//################################################
//# Labels and symbols
//################################################

label(BACRecoveryEnabled)
label(BACRecoveryRules)
label(BACRecoveryHook)
label(BACRecoveryLoop)
label(BACRecoveryApply)
label(BACRecoveryNext)
label(BACRecoveryDone)
label(BACRecoveryReturn)

label(BACAbilityCheck)
label(BACAbilityAllowed)
label(BACAbilityDenied)
label(BACAbilityDone)

label(BACInitHook)
label(BACApply)
label(BACValidateRow)
label(BACSourceWindowOK)
label(BACRuntimeWindowOK)
label(BACWriteRow)
label(BACMismatch)
label(BACDone)
label(BACStatus)
label(BACRows)
label(BACRowsEnd)

define(BACHasExSkill,TOS.exe+0x42D60)

registersymbol(BACRecoveryEnabled)
registersymbol(BACRecoveryRules)
registersymbol(BACStatus)
registersymbol(BACRows)
registersymbol(BACRowsEnd)

//######################################################################################################
//# Recovery threshold data
//######################################################################################################

mem_BACRecoveryData:

BACRecoveryEnabled:
  dd #1

BACRecoveryRules:

//################################################
//# Presea
//################################################

//# Destruction
  dd 0x5A,#55,#50,#0
//# Deadly Destruction
  dd 0x5B,#90,#70,#0
//# Fiery Destruction
  dd 0x5D,#90,#70,#0
//# Punishment
  dd 0x5F,#50,#44,#0
//# Dual Punishment
  dd 0x60,#68,#56,#0
//# Finality Punishment
  dd 0x62,#110,#72,#0
//# Rising Punishment
  dd 0x61,#128,#90,#0
//# Dual Infliction
  dd 0x64,#98,#40,#0
//# Resolute Infliction
  dd 0x65,#98,#60,#0
//# Endless Infliction
  dd 0x6D,#175,#132,#0
//# Devastation
  dd 0x67,#70,#40,#0
//# Mass Devastation
  dd 0x69,#65,#59,#0
//# Finite Devastation
  dd 0x68,#70,#62,#0
//# Fiery Infliction
  dd 0x6A,#165,#78,#0
//# Eternal Damnation
  dd 0x6B,#130,#126,#0

//################################################
//# Colette
//################################################

//# Ray Thrust
  dd 0x23,#46,#38,#0
//# Dual Ray Thrust
  dd 0x24,#130,#86,#0
//# Triple Ray Thrust
  dd 0x25,#46,#42,#0
//# Pow Hammer
  dd 0x28,#27,#23,#0
//# Ring Whirlwind
  dd 0x2D,#70,#50,#0
//# Whirlwind Rush
  dd 0x30,#108,#88,#0
//# Ring Cyclone
  dd 0x2E,#80,#68,#0
//# Para Ball
  dd 0x8A,#50,#46,#0
//# Torrential Para Ball
  dd 0x8B,#90,#84,#0
//# Grand Chariot
  dd 0x32,#46,#44,#0

//################################################
//# Kratos
//################################################

//# Fierce Demon Fang
  dd 0x04,#45,#35,#0
//# Light Spear Cannon
  dd 0x53,#95,#75,#0
//# Lightning Blade
  dd 0x55,#42,#38,#0
//# Hell Pyre
  dd 0x54,#45,#40,#0
//# Demon Spear
  dd 0x56,#105,#71,#0
//# Guardian Field
  dd 0x96,#50,#38,#0
//# Victory Light Spear
  dd 0x52,#80,#50,#0

//################################################
//# Regal
//################################################

//# Crescent Moon
  dd 0x70,#25,#21,#0
//# Wolverine
  dd 0x73,#135,#73,#0
//# Swallow Dance
  dd 0x77,#42,#40,#0
//# Dragon Dance
  dd 0x78,#70,#54,#0
//# Dragon Fury
  dd 0x7D,#65,#61,#0
//# Heaven Rising
  dd 0x86,#78,#75,#0
//# Triple Kick
  dd 0x72,#65,#61,#0
//# Dragon's Talon
  dd 0x87,#120,#114,#0

//################################################
//# End of recovery rules
//################################################

  dd 0xFFFFFFFF

//######################################################################################################
//# Recovery threshold engine
//######################################################################################################

mem_BACRecoveryCode:

BACRecoveryHook:
  movzx ebx,word ptr [edi+0x141C]

  pushfd
  push eax
  push ecx
  push edx
  push esi

  cmp dword ptr [BACRecoveryEnabled],#0
  je BACRecoveryDone

  movzx eax,word ptr [edi+0x1422]
  movzx ecx,word ptr [edi+0x1CC]
  mov esi,BACRecoveryRules

BACRecoveryLoop:
  cmp dword ptr [esi],0xFFFFFFFF
  je BACRecoveryDone

  cmp eax,[esi+0x00]
  jne BACRecoveryNext
  cmp ebx,[esi+0x04]
  jne BACRecoveryNext

  cmp ecx,eax
  je BACRecoveryApply

  lea edx,[eax+0x40]
  cmp ecx,edx
  jne BACRecoveryNext

BACRecoveryApply:
  mov ebx,[esi+0x08]
  inc dword ptr [esi+0x0C]
  jmp BACRecoveryDone

BACRecoveryNext:
  add esi,0x10
  jmp BACRecoveryLoop

BACRecoveryDone:
  pop esi
  pop edx
  pop ecx
  pop eax
  popfd
  jmp BACRecoveryReturn

//######################################################################################################
//# Ability Plus / Super Chain eligibility
//######################################################################################################

mem_BACAbilityCode:

BACAbilityCheck:
  push eax
  push ecx
  push edx

  movzx edx,word ptr [eax+0x136C]
  and edx,0x0F
  cmp edx,0x01
  je BACAbilityAllowed

  test dl,0x08
  jnz BACAbilityDenied
  test dl,0x01
  jz BACAbilityDenied

  mov ecx,[eax+0x0C]
  test ecx,ecx
  jz BACAbilityDenied
  test byte ptr [ecx+0x38],0x04
  jz BACAbilityDenied

  mov edx,0x2A
  call BACHasExSkill
  test eax,eax
  jz BACAbilityDenied

BACAbilityAllowed:
  cmp eax,eax
  jmp BACAbilityDone

BACAbilityDenied:
  or eax,0x01

BACAbilityDone:
  pop edx
  pop ecx
  pop eax
  ret

//######################################################################################################
//# Lloyd Level 3 descriptor initialization
//######################################################################################################

mem_BACDescriptorCode:

BACInitHook:
  pushfd
  pushad
  mov eax,[ebp-0x13C]
  mov edx,[edi+0x9A58]
  call BACApply
  popad
  popfd
  mov ecx,[ebp-0x13C]
  jmp TOS.exe+0x678E6

//################################################
//# Descriptor validation setup
//################################################

BACApply:
  push ebp
  push ebx
  push esi
  push edi

  mov ebp,eax
  mov edi,edx
  inc dword ptr [BACStatus+0x04]
  mov [BACStatus+0x10],eax
  mov [BACStatus+0x14],edx

  mov esi,-1
  test ebp,ebp
  jz BACMismatch
  test edi,edi
  jz BACMismatch
  cmp dword ptr [ebp],0x08
  jbe BACMismatch
  cmp dword ptr [ebp+0x24],0x49F60
  jne BACMismatch
  cmp dword ptr [ebp+0x49F60],0x9B
  jne BACMismatch

  mov esi,BACRows

//################################################
//# Descriptor and recovery checks
//################################################

BACValidateRow:
  mov ecx,[esi+0x28]
  mov ecx,[ebp+ecx+0x49F60]
  add ecx,0x49F60
  cmp ecx,[esi+0x08]
  jne BACMismatch

  mov ebx,[esi+0x04]
  add ebx,ebp
  mov edx,[esi]
  add edx,edi

  mov eax,[esi+0x0C]
  cmp [ebx],eax
  jne BACMismatch
  cmp [edx],eax
  jne BACMismatch

  mov eax,[esi+0x14]
  cmp [ebx+0x08],eax
  jne BACMismatch
  cmp [edx+0x08],eax
  jne BACMismatch

  mov eax,[ebx+0x04]
  test eax,eax
  jz BACSourceWindowOK
  cmp eax,[esi+0x10]
  jne BACMismatch

BACSourceWindowOK:
  mov eax,[edx+0x04]
  test eax,eax
  jz BACRuntimeWindowOK
  cmp eax,[esi+0x10]
  jne BACMismatch

//################################################
//# Script pointer validation
//################################################

BACRuntimeWindowOK:
  mov eax,[esi+0x08]
  add eax,ebp
  mov eax,[eax]
  mov ecx,[ebx+0x0C]
  imul ecx,ecx,0x1C
  add eax,ecx
  add eax,[esi+0x08]
  cmp eax,[esi+0x18]
  jne BACMismatch
  add eax,ebp
  cmp eax,[edx+0x0C]
  jne BACMismatch

  mov eax,[esi+0x08]
  add eax,ebp
  mov eax,[eax+0x04]
  mov ecx,[ebx+0x10]
  imul ecx,ecx,0x20
  add eax,ecx
  add eax,[esi+0x08]
  cmp eax,[esi+0x1C]
  jne BACMismatch
  add eax,ebp
  cmp eax,[edx+0x10]
  jne BACMismatch

  mov eax,[esi+0x08]
  add eax,ebp
  mov eax,[eax+0x08]
  mov ecx,[ebx+0x14]
  imul ecx,ecx,0x0C
  add eax,ecx
  add eax,[esi+0x08]
  cmp eax,[esi+0x20]
  jne BACMismatch
  add eax,ebp
  cmp eax,[edx+0x14]
  jne BACMismatch

  mov eax,[esi+0x08]
  add eax,ebp
  mov eax,[eax+0x0C]
  mov ecx,[ebx+0x18]
  imul ecx,ecx,0x02
  add eax,ecx
  add eax,[esi+0x08]
  cmp eax,[esi+0x24]
  jne BACMismatch
  add eax,ebp
  cmp eax,[edx+0x18]
  jne BACMismatch

  add esi,0x2C
  cmp esi,BACRowsEnd
  jne BACValidateRow

//################################################
//# Descriptor window updates
//################################################

  mov esi,BACRows

BACWriteRow:
  mov edx,[esi]
  mov eax,[esi+0x10]
  mov [edi+edx+0x04],eax
  add esi,0x2C
  cmp esi,BACRowsEnd
  jne BACWriteRow

  inc dword ptr [BACStatus+0x08]
  mov dword ptr [BACStatus+0x18],0x00
  mov eax,0x01
  jmp BACDone

BACMismatch:
  inc dword ptr [BACStatus+0x0C]
  mov [BACStatus+0x18],esi
  xor eax,eax

BACDone:
  pop edi
  pop esi
  pop ebx
  pop ebp
  ret

//######################################################################################################
//# Descriptor diagnostics
//######################################################################################################

mem_BACStatus:

BACStatus:
  db 0x53,0x43,0x57,0x31
  dd 0x0,0x0,0x0,0x0,0x0,0x0,0x0

//######################################################################################################
//# Lloyd Level 3 descriptor rows
//######################################################################################################

mem_BACRows:

BACRows:

//# Demonic Tiger Blade
  dd 0xA10,0x4D4F0,0x4D4E0,0xA0046,0x370046,0x44,0x4D560,0x4D598,0x4D618,0x4D660,0x60
//# Demonic Thrust
  dd 0xA80,0x4D6B0,0x4D6A0,0xA0050,0x410050,0x43,0x4D720,0x4D758,0x4D7B8,0x4D7DC,0x64
//# Raining Tiger Blade
  dd 0xAF0,0x4D830,0x4D820,0x10005F,0x50005F,0x47,0x4D8A0,0x4D8F4,0x4DA74,0x4DB1C,0x68
//# Tempest Thrust
  dd 0xB60,0x4DBF0,0x4DBE0,0xA005E,0x4F005E,0x45,0x4DC60,0x4DCB4,0x4DD74,0x4DD98,0x6C
//# Tempest Beast
  dd 0xBD0,0x4DE30,0x4DE20,0xA005F,0x50005F,0x46,0x4DEA0,0x4DEF4,0x4DFB4,0x4DFD8,0x70
//# Rising Falcon / Phoenix - Variant 0
  dd 0xCB0,0x4E3B0,0x4E3A0,0xA0078,0x690078,0x26,0x4E420,0x4E458,0x4E558,0x4E5D0,0x78
//# Rising Falcon / Phoenix - Variant 1
  dd 0xCCC,0x4E3CC,0x4E3A0,0xA0078,0x690078,0x27,0x4E420,0x4E498,0x4E57C,0x4E628,0x78
//# Rising Falcon / Phoenix - Variant 2
  dd 0xCE8,0x4E3E8,0x4E3A0,0xA0078,0x690078,0x89,0x4E420,0x4E4D8,0x4E594,0x4E660,0x78
//# Rising Falcon / Phoenix - Variant 3
  dd 0xD04,0x4E404,0x4E3A0,0xA0078,0x690078,0x8A,0x4E420,0x4E518,0x4E5B8,0x4E6C8,0x78

BACRowsEnd:

//######################################################################################################
//# Install hooks
//######################################################################################################

TOS.exe+0x3479B:
  jmp BACRecoveryHook
  nop #2

BACRecoveryReturn:

TOS.exe+0x3F0DE:
  mov eax,esi
  call BACAbilityCheck
  nop

TOS.exe+0x3F665:
  mov eax,edi
  call BACAbilityCheck
  nop #6

TOS.exe+0x678E0:
  jmp BACInitHook
  nop
