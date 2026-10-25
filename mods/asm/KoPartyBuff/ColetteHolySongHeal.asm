//######################################################################################################
//# Colette - Holy Song HP Recovery
//# Restores 20% of maximum HP and adds standard healing numbers, glow and sound.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_holy_song_hook,0x400)

//################################################
//# Verify original instruction
//################################################

assert(TOS.exe+0x18220,8A 97 B0 3A 01 00)

//################################################
//# Game functions and return address
//################################################

define(HolySongHealFn,TOS.exe+0x3FEB0)
define(HolySongEffectFn,TOS.exe+0x8A3D0)
define(HolySongNumberFn,TOS.exe+0x4E040)
define(HolySongGlowFn,TOS.exe+0x89700)
define(HolySongReturn,TOS.exe+0x18226)

//################################################
//# Holy Song HP recovery
//################################################

mem_holy_song_hook:
HolySongHook:
  pushfd
  pushad

  mov eax,[esi+0x08]
  test eax,eax
  jz holy_song_done

  mov eax,[eax+0x20]
  xor edx,edx
  mov ecx,#5
  div ecx

  test ax,ax
  jz holy_song_done

  push eax
  mov edx,esi
  call HolySongHealFn
  add esp,0x04

  movzx ebx,ax

//################################################
//# Existing healing effect
//################################################

  movsx eax,bx
  push 0x28
  push dword ptr [esi+0x13940]
  push dword ptr [esi+0x1393C]
  push dword ptr [esi+0x13938]
  push eax
  call HolySongEffectFn
  add esp,0x14

//################################################
//# Portrait healing number
//################################################

  push ebx
  push 0x00
  mov eax,esi
  call HolySongNumberFn
  add esp,0x08

//################################################
//# First Aid healing glow and sound
//################################################

  mov eax,[esi+0x04]
  test eax,eax
  jz holy_song_done

  push dword ptr [eax+0x8C]

  lea eax,[esi+0x2D0]
  push eax
  push 0x00
  push 0x00
  push 0x00

  lea eax,[esi+0x13938]
  push eax
  push esi
  push esi
  push 0x14
  push 0x01

  sub esp,0x0C

  mov eax,[esi+0x13938]
  mov [esp],eax
  mov eax,[esi+0x1393C]
  mov [esp+0x04],eax
  mov eax,[esi+0x13940]
  mov [esp+0x08],eax

  xor al,al
  call HolySongGlowFn
  add esp,0x34

//################################################
//# Restore original execution
//################################################

holy_song_done:
  popad
  popfd
  mov dl,[edi+0x13AB0]
  jmp HolySongReturn

//################################################
//# Install hook
//################################################

TOS.exe+0x18220:
  jmp HolySongHook
  nop #1
