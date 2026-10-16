//######################################################################################################
//# Colette - Holy Song HP Recovery
//# Adds HP recovery equal to 20% of maximum HP to Holy Song.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_holy_song_hook,0x200)

//################################################
//# Verify original instructions
//################################################

// The hook replaces the complete six-byte instruction.
assert(TOS.exe+0x18220,8a 97 b0 3a 01 00)

//################################################
//# Game functions and return address
//################################################

define(HolySongHealFn,TOS.exe+0x3FEB0)
define(HolySongEffectFn,TOS.exe+0x8A3D0)
define(HolySongReturn,TOS.exe+0x18226)

//################################################
//# Additional Holy Song HP recovery
//################################################

mem_holy_song_hook:
HolySongHook:
  pushfd
  pushad

  // Read maximum HP and calculate one fifth (20%).
  mov eax,[esi+0x08]
  test eax,eax
  jz holy_song_done
  mov eax,[eax+0x20]
  xor edx,edx
  mov ecx,#5
  div ecx
  test ax,ax
  jz holy_song_done

  // Apply recovery and trigger the existing effect routine.
  push eax
  mov edx,esi
  call HolySongHealFn
  add esp,#4
  movsx eax,ax
  push 0x28
  push dword ptr [esi+0x13940]
  push dword ptr [esi+0x1393C]
  push dword ptr [esi+0x13938]
  push eax
  call HolySongEffectFn
  add esp,0x14

holy_song_done:
  popad
  popfd

  // Restore the displaced instruction and continue.
  mov dl,[edi+0x13AB0]
  jmp HolySongReturn

//################################################
//# Install hook
//################################################

TOS.exe+0x18220:
  jmp HolySongHook
  nop #1
