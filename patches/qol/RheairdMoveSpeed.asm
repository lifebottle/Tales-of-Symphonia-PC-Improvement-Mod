// Rheaird forward/backward travel multiplier. Default 1 leaves the hook off.
// Scale the player's local movement delta before terrain/collision checks.
// Any lateral right-stick input (including diagonals) retains native speed.
// Match the game's +/-128 raw-axis deadzone; the left stick's flight steering
// is independent. Forward thrust with neutral/no right stick is also scaled.
// Acceleration, altitude controls, other actors and non-flight modes are native.
[ENABLE]
define(move_site,TOS.exe+BC403)
define(move_return,TOS.exe+BC40A)
define(controller_slot,TOS.exe+71488C)

assert(move_site,D9 5C 24 18 D9 43 10)
assert(move_return,8D 4B 18 51 83 EC 08 D9 5C 24 04)
// Player iteration and flight flag consumed by the following movement branch.
assert(TOS.exe+BC478,83 7C 24 10 00 0F 85 3B 01 00 00 8B 87 FC F8 09 00 A8 08 74 62)
// Native controller pointer and raw horizontal-axis load/deadzone/conversion.
assert(TOS.exe+B9374,8B 35 8C 48 B1 00)
assert(TOS.exe+B9480,0F B7 46 18 66 3B C1 7E 0F BA 80 00 00 00 66 3B C2 7E 12 83 C0 80 EB 0F 7D 0D 66 83 F8 80 7D 05 83 E8 80 EB 02 33 C0 98 99 2B C2 D1 F8 0F B7 C0 89 44 24 24)

alloc(move_code,100)
alloc(move_settings,4)
label(move_multiplier)
label(boost)
label(restore_eax)
label(original)

move_settings:
move_multiplier:
  dd (float)1

move_code:
  // ST(0) is the frame's tick delta; EBX is the actor, EDI the player/world base.
  pushfd
  cmp ebx,edi
  jne original
  test byte ptr [edi+9F8FC],8
  jz original
  push eax
  mov eax,[controller_slot]
  test eax,eax
  jz boost
  movsx eax,word ptr [eax+18]
  cmp eax,#128
  jg restore_eax
  cmp eax,-#128
  jl restore_eax
boost:
  fmul dword ptr [move_multiplier]
restore_eax:
  pop eax
original:
  popfd
  fstp dword ptr [esp+18]
  fld dword ptr [ebx+10]
  jmp move_return

move_site:
  jmp move_code
  nop 2

[DISABLE]
move_site:
  db D9 5C 24 18 D9 43 10
dealloc(move_code)
dealloc(move_settings)
