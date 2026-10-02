// Enable with [QoL] FastBlockPush=1; defaults off.
// Reverses the tested 60 FPS block-speed correction in the supported EXE.
// Restore the extra +/-3 movement for BOTH the block and player in all four
// directions: 6 units/frame for 25 frames instead of 3 units/frame for 50.
// Each push/pull still travels 150 units; x87 stack depth stays unchanged.
// Older EXEs already containing these fast instructions fail the assertions.
[ENABLE]
define(push_north_block,TOS.exe+CB310)
define(push_north_player,TOS.exe+CB322)
define(push_west_block,TOS.exe+CB338)
define(push_west_player,TOS.exe+CB34A)
define(push_south_block,TOS.exe+CB35D)
define(push_south_player,TOS.exe+CB36F)
define(push_east_block,TOS.exe+CB385)
define(push_east_player,TOS.exe+CB397)
define(pull_north_block,TOS.exe+CB560)
define(pull_north_player,TOS.exe+CB572)
define(pull_west_block,TOS.exe+CB588)
define(pull_west_player,TOS.exe+CB59A)
define(pull_south_block,TOS.exe+CB5AD)
define(pull_south_player,TOS.exe+CB5BF)
define(pull_east_block,TOS.exe+CB5D5)
define(pull_east_player,TOS.exe+CB5E7)
define(push_timer,TOS.exe+CB3A8)
define(pull_timer,TOS.exe+CB5F8)

assert(push_north_block,90 90)
assert(push_north_player,90 90)
assert(push_west_block,90 90)
assert(push_west_player,90 90)
assert(push_south_block,90 90)
assert(push_south_player,90 90)
assert(push_east_block,90 90)
assert(push_east_player,90 90)
assert(pull_north_block,90 90)
assert(pull_north_player,90 90)
assert(pull_west_block,90 90)
assert(pull_west_player,90 90)
assert(pull_south_block,90 90)
assert(pull_south_player,90 90)
assert(pull_east_block,90 90)
assert(pull_east_player,90 90)
assert(push_timer,83 BE B0 00 00 00 32)
assert(pull_timer,83 BE B0 00 00 00 32)
// Shared movement increment must remain 3.0; never change the global constant.
assert(TOS.exe+482940,00 00 00 00 00 00 08 40)

push_north_block:
  fadd st(1),st(0)
push_north_player:
  fadd st(0),st(1)
push_west_block:
  fsub st(1),st(0)
push_west_player:
  fsub st(0),st(1)
push_south_block:
  fsub st(1),st(0)
push_south_player:
  fsub st(0),st(1)
push_east_block:
  fadd st(1),st(0)
push_east_player:
  fadd st(0),st(1)
pull_north_block:
  fsub st(1),st(0)
pull_north_player:
  fsub st(0),st(1)
pull_west_block:
  fadd st(1),st(0)
pull_west_player:
  fadd st(0),st(1)
pull_south_block:
  fadd st(1),st(0)
pull_south_player:
  fadd st(0),st(1)
pull_east_block:
  fsub st(1),st(0)
pull_east_player:
  fsub st(0),st(1)
push_timer:
  cmp dword ptr [esi+B0],#25
pull_timer:
  cmp dword ptr [esi+B0],#25

[DISABLE]
push_north_block:
  nop 2
push_north_player:
  nop 2
push_west_block:
  nop 2
push_west_player:
  nop 2
push_south_block:
  nop 2
push_south_player:
  nop 2
push_east_block:
  nop 2
push_east_player:
  nop 2
pull_north_block:
  nop 2
pull_north_player:
  nop 2
pull_west_block:
  nop 2
pull_west_player:
  nop 2
pull_south_block:
  nop 2
pull_south_player:
  nop 2
pull_east_block:
  nop 2
pull_east_player:
  nop 2
push_timer:
  cmp dword ptr [esi+B0],#50
pull_timer:
  cmp dword ptr [esi+B0],#50
