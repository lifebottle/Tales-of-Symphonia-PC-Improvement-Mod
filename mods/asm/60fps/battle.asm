// Battle flow, actors, movement, combat input, cameras, artes, chanting, entry and results.
// Tales of Symphonia 60FPS v0.0.46; controlled by [60FPS] Enabled=1.
// Fresh launch required. Reference VAs identify source bytes, not runtime allocations.
// Bare ASM numbers are hexadecimal; # introduces decimal.
// Sections:
//   Battle cutscenes
//   Battle flow
//   Battle actor timing
//   Battle artes
//   Chant timing
//   Battle camera
//   Battle input
//   Battle entry
//   Battle results

[ENABLE]

// ======================================================================
// Battle cutscenes
// Battle intro and scripted character/enemy sequence clocks.
// ======================================================================

// Reference VA 004011A3..004011AA.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+11A3,66 83 86 14 01 00 00 02)
TOS.exe+11A3:
// Vanilla: add word ptr [esi + 0x114], 2
  add word ptr [esi + 0x114], #1 // 004011A3

// Reference VA 00401807..00401809.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+1807,8D 47 02)
TOS.exe+1807:
// Vanilla: lea eax, [edi + 2]
  lea eax, [edi + #1] // 00401807

// Reference VA 00401D7C..00401D7E.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+1D7C,83 06 02)
TOS.exe+1D7C:
// Vanilla: add dword ptr [esi], 2
  add dword ptr [esi], #1 // 00401D7C

// Reference VA 00401E47..00401E49.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+1E47,83 07 02)
TOS.exe+1E47:
// Vanilla: add dword ptr [edi], 2
  add dword ptr [edi], #1 // 00401E47

// Reference VA 00402A06..00402A08.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+2A06,8D 47 02)
TOS.exe+2A06:
// Vanilla: lea eax, [edi + 2]
  lea eax, [edi + #1] // 00402A06

// Reference VA 004030AE..004030B0.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+30AE,8D 47 02)
TOS.exe+30AE:
// Vanilla: lea eax, [edi + 2]
  lea eax, [edi + #1] // 004030AE

// Reference VA 00403AF6..00403AFD.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+3AF6,66 83 86 14 01 00 00 02)
TOS.exe+3AF6:
// Vanilla: add word ptr [esi + 0x114], 2
  add word ptr [esi + 0x114], #1 // 00403AF6

// Reference VA 00404E2B..00404E32.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+4E2B,66 83 86 14 01 00 00 02)
TOS.exe+4E2B:
// Vanilla: add word ptr [esi + 0x114], 2
  add word ptr [esi + 0x114], #1 // 00404E2B

// Reference VA 0040570D..00405714.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+570D,66 83 86 14 01 00 00 02)
TOS.exe+570D:
// Vanilla: add word ptr [esi + 0x114], 2
  add word ptr [esi + 0x114], #1 // 0040570D

// Reference VA 00405A50..00405A50.
// Remove the second decrement of this scene object countdown at +4. The countdown operation is
// established; the precise object identity is unverified.
assert(TOS.exe+5A50,48)
TOS.exe+5A50:
// Vanilla: dec eax
  nop // 00405A50

// Reference VA 0040666A..00406671.
// Advance this battle intro/cutscene clock by one per update instead of two.
assert(TOS.exe+666A,66 83 86 14 01 00 00 02)
TOS.exe+666A:
// Vanilla: add word ptr [esi + 0x114], 2
  add word ptr [esi + 0x114], #1 // 0040666A

// ======================================================================
// Battle flow
// Battle phases, shared timers, unison phases and action-state waits.
// ======================================================================

// Reference VA 0045CF10..0045CF16.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5CF10,83 80 D8 90 00 00 02)
TOS.exe+5CF10:
// Vanilla: add dword ptr [eax + 0x90d8], 2
  add dword ptr [eax + 0x90d8], #1 // 0045CF10

// Reference VA 0045D4FA..0045D500.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5D4FA,83 80 D8 90 00 00 02)
TOS.exe+5D4FA:
// Vanilla: add dword ptr [eax + 0x90d8], 2
  add dword ptr [eax + 0x90d8], #1 // 0045D4FA

// Reference VA 0045D7FC..0045D802.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5D7FC,83 86 D8 90 00 00 02)
TOS.exe+5D7FC:
// Vanilla: add dword ptr [esi + 0x90d8], 2
  add dword ptr [esi + 0x90d8], #1 // 0045D7FC

// Reference VA 0045D847..0045D84B.
// Use one as the mode-7 battle counter increment.
assert(TOS.exe+5D847,B9 02 00 00 00)
TOS.exe+5D847:
// Vanilla: mov ecx, 2
  mov ecx, #1 // 0045D847

// Reference VA 0045DC01..0045DC07.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5DC01,83 80 D8 90 00 00 02)
TOS.exe+5DC01:
// Vanilla: add dword ptr [eax + 0x90d8], 2
  add dword ptr [eax + 0x90d8], #1 // 0045DC01

// Reference VA 0045DC9B..0045DCA1.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5DC9B,83 80 D8 90 00 00 02)
TOS.exe+5DC9B:
// Vanilla: add dword ptr [eax + 0x90d8], 2
  add dword ptr [eax + 0x90d8], #1 // 0045DC9B

// Reference VA 0045DCF6..0045DCF8.
// Use the v46 cleanup/fade transition threshold of 90 instead of 60.
assert(TOS.exe+5DCF6,83 F9 3C)
TOS.exe+5DCF6:
// Vanilla: cmp ecx, 0x3c
  cmp ecx, 0x5a // 0045DCF6

// Reference VA 0045DD13..0045DD1B.
// Reduce this cleanup fade step from eight to four while preserving its mode byte.
assert(TOS.exe+5DD13,66 C7 80 12 94 00 00 01 08)
TOS.exe+5DD13:
// Vanilla: mov word ptr [eax + 0x9412], 0x801
  mov word ptr [eax + 0x9412], 0x401 // 0045DD13

// Reference VA 0045DD1E..0045DD26.
// Reduce the alternate cleanup fade step from sixteen to eight while preserving its mode byte.
assert(TOS.exe+5DD1E,66 C7 80 12 94 00 00 01 10)
TOS.exe+5DD1E:
// Vanilla: mov word ptr [eax + 0x9412], 0x1001
  mov word ptr [eax + 0x9412], 0x801 // 0045DD1E

// Reference VA 0045DD30..0045DD32.
// Use the matching v46 cleanup/fade transition threshold of 90.
assert(TOS.exe+5DD30,83 F9 3C)
TOS.exe+5DD30:
// Vanilla: cmp ecx, 0x3c
  cmp ecx, 0x5a // 0045DD30

// Reference VA 0045DD90..0045DD92.
// Advance the transition clock at battle+90D4 by one per update.
assert(TOS.exe+5DD90,83 07 02)
TOS.exe+5DD90:
// Vanilla: add dword ptr [edi], 2
  add dword ptr [edi], #1 // 0045DD90

// Reference VA 0045DD9A..0045DDA0.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5DD9A,83 80 D8 90 00 00 02)
TOS.exe+5DD9A:
// Vanilla: add dword ptr [eax + 0x90d8], 2
  add dword ptr [eax + 0x90d8], #1 // 0045DD9A

// Reference VA 0045DE64..0045DE6A.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5DE64,83 86 D8 90 00 00 02)
TOS.exe+5DE64:
// Vanilla: add dword ptr [esi + 0x90d8], 2
  add dword ptr [esi + 0x90d8], #1 // 0045DE64

// Reference VA 0045E0B8..0045E0BE.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5E0B8,83 86 D8 90 00 00 02)
TOS.exe+5E0B8:
// Vanilla: add dword ptr [esi + 0x90d8], 2
  add dword ptr [esi + 0x90d8], #1 // 0045E0B8

// Reference VA 0045E2CA..0045E2D0.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5E2CA,83 83 D8 90 00 00 02)
TOS.exe+5E2CA:
// Vanilla: add dword ptr [ebx + 0x90d8], 2
  add dword ptr [ebx + 0x90d8], #1 // 0045E2CA

// Reference VA 0045E6BF..0045E6C6.
// Advance unison progress at battle+93D4 once per update so its milestones keep the v46 timing.
assert(TOS.exe+5E6BF,66 83 83 D4 93 00 00 02)
TOS.exe+5E6BF:
// Vanilla: add word ptr [ebx + 0x93d4], 2
  add word ptr [ebx + 0x93d4], #1 // 0045E6BF

// Reference VA 0045E6CE..0045E6D4.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5E6CE,83 86 D8 90 00 00 02)
TOS.exe+5E6CE:
// Vanilla: add dword ptr [esi + 0x90d8], 2
  add dword ptr [esi + 0x90d8], #1 // 0045E6CE

// Reference VA 0045E75C..0045E762.
// Advance the battle mode timer at +90D8 by one per update instead of two.
assert(TOS.exe+5E75C,83 80 D8 90 00 00 02)
TOS.exe+5E75C:
// Vanilla: add dword ptr [eax + 0x90d8], 2
  add dword ptr [eax + 0x90d8], #1 // 0045E75C

// Reference VA 0045EB6C..0045EB75.
// Initialize the v46 transition clock to 75 instead of the vanilla 45; retain this deliberate timing
// adjustment.
assert(TOS.exe+5EB6C,C7 80 D4 90 00 00 2D 00 00 00)
TOS.exe+5EB6C:
// Vanilla: mov dword ptr [eax + 0x90d4], 0x2d
  mov dword ptr [eax + 0x90d4], 0x4b // 0045EB6C

// Reference VA 0045EC6E..0045EC73.
// Increment the shared battle clock at +90DC once without changing the EBX value used elsewhere.
assert(TOS.exe+5EC6E,01 9F DC 90 00 00)
TOS.exe+5EC6E:
// Vanilla: add dword ptr [edi + 0x90dc], ebx
  inc dword ptr [edi + 0x90dc] // 0045EC6E

// Reference VA 0045ECF1..0045ECF6.
// Increment the shared battle clock at +90E0 once without changing the EBX value used elsewhere.
assert(TOS.exe+5ECF1,01 9F E0 90 00 00)
TOS.exe+5ECF1:
// Vanilla: add dword ptr [edi + 0x90e0], ebx
  inc dword ptr [edi + 0x90e0] // 0045ECF1

// Reference VA 0045ED00..0045ED05.
// Increment the shared battle clock at +90E4 once without changing the EBX value used elsewhere.
assert(TOS.exe+5ED00,01 9F E4 90 00 00)
TOS.exe+5ED00:
// Vanilla: add dword ptr [edi + 0x90e4], ebx
  inc dword ptr [edi + 0x90e4] // 0045ED00

// Reference VA 0045ED35..0045ED37.
// Decrement this shared battle countdown by one rather than two.
assert(TOS.exe+5ED35,83 C0 FE)
TOS.exe+5ED35:
// Vanilla: add eax, -2
  add eax, -#1 // 0045ED35

// Reference VA 0045ED93..0045EDA6.
// Remove the second decrement of the +90BA battle timer. Preserve the first decrement so cooldowns
// continue to expire.
assert(TOS.exe+5ED93,0F B7 86 BA 90 00 00 66 85 C0 74 08 48 66 89 86 BA 90 00 00)
TOS.exe+5ED93:
// Vanilla: movzx eax, word ptr [esi + 0x90ba]; test ax, ax; je 0x45eda7; dec eax; mov word ptr [esi + 0x90ba], ax
  nop // 0045ED93
  nop // 0045ED94
  nop // 0045ED95
  nop // 0045ED96
  nop // 0045ED97
  nop // 0045ED98
  nop // 0045ED99
  nop // 0045ED9A
  nop // 0045ED9B
  nop // 0045ED9C
  nop // 0045ED9D
  nop // 0045ED9E
  nop // 0045ED9F
  nop // 0045EDA0
  nop // 0045EDA1
  nop // 0045EDA2
  nop // 0045EDA3
  nop // 0045EDA4
  nop // 0045EDA5
  nop // 0045EDA6

// Reference VA 0045EDB9..0045EDCA.
// Remove the second decrement of the +90E8 effect timer; retain its first decrement.
assert(TOS.exe+5EDB9,8A 86 E8 90 00 00 84 C0 74 08 FE C8 88 86 E8 90 00 00)
TOS.exe+5EDB9:
// Vanilla: mov al, byte ptr [esi + 0x90e8]; test al, al; je 0x45edcb; dec al; mov byte ptr [esi + 0x90e8], al
  nop // 0045EDB9
  nop // 0045EDBA
  nop // 0045EDBB
  nop // 0045EDBC
  nop // 0045EDBD
  nop // 0045EDBE
  nop // 0045EDBF
  nop // 0045EDC0
  nop // 0045EDC1
  nop // 0045EDC2
  nop // 0045EDC3
  nop // 0045EDC4
  nop // 0045EDC5
  nop // 0045EDC6
  nop // 0045EDC7
  nop // 0045EDC8
  nop // 0045EDC9
  nop // 0045EDCA

// Reference VA 0045EDDD..0045EDEE.
// Remove the second decrement of the +93CD pause timer; retain its first decrement.
assert(TOS.exe+5EDDD,8A 86 CD 93 00 00 84 C0 74 08 FE C8 88 86 CD 93 00 00)
TOS.exe+5EDDD:
// Vanilla: mov al, byte ptr [esi + 0x93cd]; test al, al; je 0x45edef; dec al; mov byte ptr [esi + 0x93cd], al
  nop // 0045EDDD
  nop // 0045EDDE
  nop // 0045EDDF
  nop // 0045EDE0
  nop // 0045EDE1
  nop // 0045EDE2
  nop // 0045EDE3
  nop // 0045EDE4
  nop // 0045EDE5
  nop // 0045EDE6
  nop // 0045EDE7
  nop // 0045EDE8
  nop // 0045EDE9
  nop // 0045EDEA
  nop // 0045EDEB
  nop // 0045EDEC
  nop // 0045EDED
  nop // 0045EDEE

// Reference VA 00471294..0047129B.
// Advance the unison/action state-6 wait clock at battle+910E once per update.
assert(TOS.exe+71294,66 83 82 0E 91 00 00 02)
TOS.exe+71294:
// Vanilla: add word ptr [edx + 0x910e], 2
  add word ptr [edx + 0x910e], #1 // 00471294

// Reference VA 0047142A..0047142E.
// Use one as the shared action-state fade step for the +92A0/+92A2 fields.
assert(TOS.exe+7142A,B8 02 00 00 00)
TOS.exe+7142A:
// Vanilla: mov eax, 2
  mov eax, #1 // 0047142A

// Reference VA 00471C11..00471C15.
// Advance the state-9 action-context clock at +E once per update.
assert(TOS.exe+71C11,66 83 46 0E 02)
TOS.exe+71C11:
// Vanilla: add word ptr [esi + 0xe], 2
  add word ptr [esi + 0xe], #1 // 00471C11

// Reference VA 00471F07..00471F0B.
// Advance the state-10 action-context clock at +E once per update.
assert(TOS.exe+71F07,66 83 47 0E 02)
TOS.exe+71F07:
// Vanilla: add word ptr [edi + 0xe], 2
  add word ptr [edi + 0xe], #1 // 00471F07

// ======================================================================
// Battle actor timing
// Actor movement, rotation, hit recovery, weapon tracking and delayed knockback.
// Delayed knockback copies stored XY velocity only on the nonzero-to-zero countdown transition.
// ======================================================================

alloc(fps_battle_actor_timing_code,1000)

label(fps_spell_knockback_timer)

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+86CFD,80 BB EF 17 00)

// Reference VA 0042669A..004266A1.
// Advance the movement-script timer at +12F8 by one per update instead of two.
assert(TOS.exe+2669A,66 83 83 F8 12 00 00 02)
TOS.exe+2669A:
// Vanilla: add word ptr [ebx + 0x12f8], 2
  add word ptr [ebx + 0x12f8], #1 // 0042669A

// Reference VA 00427267..0042727A.
// Remove the repeated decrement of the actor +1BE state timer in this attack-state path.
assert(TOS.exe+27267,0F B7 83 BE 01 00 00 66 85 C0 74 08 48 66 89 83 BE 01 00 00)
TOS.exe+27267:
// Vanilla: movzx eax, word ptr [ebx + 0x1be]; test ax, ax; je 0x42727b; dec eax; mov word ptr [ebx + 0x1be], ax
  nop // 00427267
  nop // 00427268
  nop // 00427269
  nop // 0042726A
  nop // 0042726B
  nop // 0042726C
  nop // 0042726D
  nop // 0042726E
  nop // 0042726F
  nop // 00427270
  nop // 00427271
  nop // 00427272
  nop // 00427273
  nop // 00427274
  nop // 00427275
  nop // 00427276
  nop // 00427277
  nop // 00427278
  nop // 00427279
  nop // 0042727A

// Reference VA 004274C9..004274D0.
// Advance the attack-script timer at +12FA by one per update instead of two.
assert(TOS.exe+274C9,66 83 83 FA 12 00 00 02)
TOS.exe+274C9:
// Vanilla: add word ptr [ebx + 0x12fa], 2
  add word ptr [ebx + 0x12fa], #1 // 004274C9

// Reference VA 004278E5..004278EC.
// Advance the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+278E5,66 83 86 BE 01 00 00 02)
TOS.exe+278E5:
// Vanilla: add word ptr [esi + 0x1be], 2
  add word ptr [esi + 0x1be], #1 // 004278E5

// Reference VA 00427F58..00427F5F.
// Advance the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+27F58,66 83 86 BE 01 00 00 02)
TOS.exe+27F58:
// Vanilla: add word ptr [esi + 0x1be], 2
  add word ptr [esi + 0x1be], #1 // 00427F58

// Reference VA 004280E6..004280E8.
// Advance this attack-script/state counter by one unit instead of two per update.
assert(TOS.exe+280E6,83 C0 02)
TOS.exe+280E6:
// Vanilla: add eax, 2
  add eax, #1 // 004280E6

// Reference VA 0042B3B6..0042B3B8.
// Advance this attack-script/state counter by one unit instead of two per update.
assert(TOS.exe+2B3B6,83 C0 02)
TOS.exe+2B3B6:
// Vanilla: add eax, 2
  add eax, #1 // 0042B3B6

// Reference VA 0042B401..0042B40C.
// Remove the repeated position-integration and collision calls in the player attack update.
assert(TOS.exe+2B401,E8 4A F6 00 00 8B CE E8 D3 F8 00 00)
TOS.exe+2B401:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 0042B401
  nop // 0042B402
  nop // 0042B403
  nop // 0042B404
  nop // 0042B405
  nop // 0042B406
  nop // 0042B407
  nop // 0042B408
  nop // 0042B409
  nop // 0042B40A
  nop // 0042B40B
  nop // 0042B40C

// Reference VA 0043A60A..0043A60B.
// Use the single facing-rotation contribution instead of doubling it for the old update rate.
assert(TOS.exe+3A60A,DC C0)
TOS.exe+3A60A:
// Vanilla: fadd st(0), st(0)
  nop // 0043A60A
  nop // 0043A60B

// Reference VA 0043A87C..0043A87D.
// Use the single turn-toward-direction contribution instead of doubling it.
assert(TOS.exe+3A87C,DC C0)
TOS.exe+3A87C:
// Vanilla: fadd st(0), st(0)
  nop // 0043A87C
  nop // 0043A87D

// Reference VA 0043AA39..0043AA44.
// Remove the repeated position-integration and collision pass; both calls remain in the first pass.
assert(TOS.exe+3AA39,E8 12 00 00 00 8B CE E8 9B 02 00 00)
TOS.exe+3AA39:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 0043AA39
  nop // 0043AA3A
  nop // 0043AA3B
  nop // 0043AA3C
  nop // 0043AA3D
  nop // 0043AA3E
  nop // 0043AA3F
  nop // 0043AA40
  nop // 0043AA41
  nop // 0043AA42
  nop // 0043AA43
  nop // 0043AA44

// Reference VA 0043AC6D..0043AC72.
// Add one, rather than two, in the actor motion accumulator.
assert(TOS.exe+3AC6D,DC 05 B8 29 88 00)
TOS.exe+3AC6D:
// Vanilla: fadd qword ptr [0x8829b8]
  fadd qword ptr [fps_double_one] // 0043AC6D

// Reference VA 0043CDAA..0043CDAC.
// Move Colette weapon hitboxes once per update. Chakrams here use weapon tracking, not the ordinary
// projectile subsystem.
assert(TOS.exe+3CDAA,83 F8 02)
TOS.exe+3CDAA:
// Vanilla: cmp eax, 2
  cmp eax, #1 // 0043CDAA

// Reference VA 0043E219..0043E21E.
// Use one update of motion when predicting actor position instead of the former two-update factor.
assert(TOS.exe+3E219,DD 05 B8 29 88 00)
TOS.exe+3E219:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 0043E219

// Reference VA 00441716..0044171D.
// Remove the repeated decrement/store of the actor +1BE state timer.
assert(TOS.exe+41716,48 66 89 83 BE 01 00 00)
TOS.exe+41716:
// Vanilla: dec eax; mov word ptr [ebx + 0x1be], ax
  nop // 00441716
  nop // 00441717
  nop // 00441718
  nop // 00441719
  nop // 0044171A
  nop // 0044171B
  nop // 0044171C
  nop // 0044171D

// Reference VA 00441A6C..00441A73.
// Decrement the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+41A6C,66 83 86 BE 01 00 00 FE)
TOS.exe+41A6C:
// Vanilla: add word ptr [esi + 0x1be], -2
  db 66,83,86,BE,01,00,00,FF // add word ptr [esi + 0x1be], -#1 // 00441A6C

// Reference VA 00444D85..00444D8C.
// Advance the attack-script timer at +12FA by one per update instead of two.
assert(TOS.exe+44D85,66 83 87 FA 12 00 00 02)
TOS.exe+44D85:
// Vanilla: add word ptr [edi + 0x12fa], 2
  add word ptr [edi + 0x12fa], #1 // 00444D85

// Reference VA 004467EE..004467F5.
// Advance the movement-script timer at +12F8 by one per update instead of two.
assert(TOS.exe+467EE,66 83 86 F8 12 00 00 02)
TOS.exe+467EE:
// Vanilla: add word ptr [esi + 0x12f8], 2
  add word ptr [esi + 0x12f8], #1 // 004467EE

// Reference VA 00475319..00475320.
// Decrement the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+75319,66 83 86 BE 01 00 00 FE)
TOS.exe+75319:
// Vanilla: add word ptr [esi + 0x1be], -2
  db 66,83,86,BE,01,00,00,FF // add word ptr [esi + 0x1be], -#1 // 00475319

// Reference VA 00484E22..00484E26.
// Remove the second consecutive call to actor state update 439030.
assert(TOS.exe+84E22,E8 09 42 FB FF)
TOS.exe+84E22:
// Vanilla: call 0x439030
  nop // 00484E22
  nop // 00484E23
  nop // 00484E24
  nop // 00484E25
  nop // 00484E26

// Reference VA 004857F8..00485808.
// Remove the second running-state position/collision/physics call sequence.
assert(TOS.exe+857F8,E8 53 52 FB FF 8B CB E8 5C 56 FB FF E8 57 57 FB FF)
TOS.exe+857F8:
// Vanilla: call 0x43aa50; mov ecx, ebx; call 0x43ae60; call 0x43af60
  nop // 004857F8
  nop // 004857F9
  nop // 004857FA
  nop // 004857FB
  nop // 004857FC
  nop // 004857FD
  nop // 004857FE
  nop // 004857FF
  nop // 00485800
  nop // 00485801
  nop // 00485802
  nop // 00485803
  nop // 00485804
  nop // 00485805
  nop // 00485806
  nop // 00485807
  nop // 00485808

// Reference VA 004858B6..004858BD.
// Advance the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+858B6,66 83 83 BE 01 00 00 02)
TOS.exe+858B6:
// Vanilla: add word ptr [ebx + 0x1be], 2
  add word ptr [ebx + 0x1be], #1 // 004858B6

// Reference VA 00485B06..00485B1B.
// Remove the repeated approach-state motion/collision sequence and its motion accumulator update.
assert(TOS.exe+85B06,E8 45 4F FB FF 8B CB E8 4E 53 FB FF E8 49 54 FB FF E8 F4 50 FB FF)
TOS.exe+85B06:
// Vanilla: call 0x43aa50; mov ecx, ebx; call 0x43ae60; call 0x43af60; call 0x43ac10
  nop // 00485B06
  nop // 00485B07
  nop // 00485B08
  nop // 00485B09
  nop // 00485B0A
  nop // 00485B0B
  nop // 00485B0C
  nop // 00485B0D
  nop // 00485B0E
  nop // 00485B0F
  nop // 00485B10
  nop // 00485B11
  nop // 00485B12
  nop // 00485B13
  nop // 00485B14
  nop // 00485B15
  nop // 00485B16
  nop // 00485B17
  nop // 00485B18
  nop // 00485B19
  nop // 00485B1A
  nop // 00485B1B

// Reference VA 00485F75..00485F80.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+85F75,E8 D6 4A FB FF 8B CE E8 5F 4D FB FF)
TOS.exe+85F75:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 00485F75
  nop // 00485F76
  nop // 00485F77
  nop // 00485F78
  nop // 00485F79
  nop // 00485F7A
  nop // 00485F7B
  nop // 00485F7C
  nop // 00485F7D
  nop // 00485F7E
  nop // 00485F7F
  nop // 00485F80

// Reference VA 00486037..0048603E.
// Advance the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+86037,66 83 83 BE 01 00 00 02)
TOS.exe+86037:
// Vanilla: add word ptr [ebx + 0x1be], 2
  add word ptr [ebx + 0x1be], #1 // 00486037

// Reference VA 004861B6..0048620B.
// Remove the repeated retreat-state motion/collision pass, including its conditional vertical
// oscillation and motion accumulation.
assert(TOS.exe+861B6,E8 95 48 FB FF 8B CB E8 9E 4C FB FF F6 83 91 02 00 00 07 74 3C 8B 43 04 F6 40 5C 02 74 33 0F B7 83 9E 02 00 00 03 C0 03 C0 99 B9 68 01 00 00 F7 F9 A1 DC 2E AD 00 8B 88 40 9A 00 00 D9 04 91 DC 0D 50 29 88 00 D8 83 A0 38 01 00 D9 9B A0 38 01 00 E8 04 4A FB FF)
TOS.exe+861B6:
  nop // 004861B6
  nop // 004861B7
  nop // 004861B8
  nop // 004861B9
  nop // 004861BA
  nop // 004861BB
  nop // 004861BC
  nop // 004861BD
  nop // 004861BE
  nop // 004861BF
  nop // 004861C0
  nop // 004861C1
  nop // 004861C2
  nop // 004861C3
  nop // 004861C4
  nop // 004861C5
  nop // 004861C6
  nop // 004861C7
  nop // 004861C8
  nop // 004861C9
  nop // 004861CA
  nop // 004861CB
  nop // 004861CC
  nop // 004861CD
  nop // 004861CE
  nop // 004861CF
  nop // 004861D0
  nop // 004861D1
  nop // 004861D2
  nop // 004861D3
  nop // 004861D4
  nop // 004861D5
  nop // 004861D6
  nop // 004861D7
  nop // 004861D8
  nop // 004861D9
  nop // 004861DA
  nop // 004861DB
  nop // 004861DC
  nop // 004861DD
  nop // 004861DE
  nop // 004861DF
  nop // 004861E0
  nop // 004861E1
  nop // 004861E2
  nop // 004861E3
  nop // 004861E4
  nop // 004861E5
  nop // 004861E6
  nop // 004861E7
  nop // 004861E8
  nop // 004861E9
  nop // 004861EA
  nop // 004861EB
  nop // 004861EC
  nop // 004861ED
  nop // 004861EE
  nop // 004861EF
  nop // 004861F0
  nop // 004861F1
  nop // 004861F2
  nop // 004861F3
  nop // 004861F4
  nop // 004861F5
  nop // 004861F6
  nop // 004861F7
  nop // 004861F8
  nop // 004861F9
  nop // 004861FA
  nop // 004861FB
  nop // 004861FC
  nop // 004861FD
  nop // 004861FE
  nop // 004861FF
  nop // 00486200
  nop // 00486201
  nop // 00486202
  nop // 00486203
  nop // 00486204
  nop // 00486205
  nop // 00486206
  nop // 00486207
  nop // 00486208
  nop // 00486209
  nop // 0048620A
  nop // 0048620B

// Reference VA 004864CA..004864D1.
// Advance the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+864CA,66 83 83 BE 01 00 00 02)
TOS.exe+864CA:
// Vanilla: add word ptr [ebx + 0x1be], 2
  add word ptr [ebx + 0x1be], #1 // 004864CA

// Reference VA 004869A2..004869A4.
// Decrement spell recovery by one instead of two per update.
assert(TOS.exe+869A2,83 C1 FE)
TOS.exe+869A2:
// Vanilla: add ecx, -2
  add ecx, -#1 // 004869A2

// Reference VA 004869E6..004869F1.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+869E6,E8 65 40 FB FF 8B CB E8 EE 42 FB FF)
TOS.exe+869E6:
// Vanilla: call 0x43aa50; mov ecx, ebx; call 0x43ace0
  nop // 004869E6
  nop // 004869E7
  nop // 004869E8
  nop // 004869E9
  nop // 004869EA
  nop // 004869EB
  nop // 004869EC
  nop // 004869ED
  nop // 004869EE
  nop // 004869EF
  nop // 004869F0
  nop // 004869F1

// Reference VA 00486A73..00486A7E.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+86A73,E8 D8 3F FB FF 8B CB E8 61 42 FB FF)
TOS.exe+86A73:
// Vanilla: call 0x43aa50; mov ecx, ebx; call 0x43ace0
  nop // 00486A73
  nop // 00486A74
  nop // 00486A75
  nop // 00486A76
  nop // 00486A77
  nop // 00486A78
  nop // 00486A79
  nop // 00486A7A
  nop // 00486A7B
  nop // 00486A7C
  nop // 00486A7D
  nop // 00486A7E

// Reference VA 00486CA5..00486CFC.
// Replace both delayed-knockback blocks with one countdown decrement; transfer stored XY velocity only
// on the nonzero-to-zero transition.
assert(TOS.exe+86CA5,8A 83 EF 17 00 00 84 C0 74 22 FE C8 88 83 EF 17 00 00 75 18 8B 93 50 39 01 00 8B 83 54 39 01 00 89 93 EC 38 01 00 89 83 F0 38 01 00 8A 83 EF 17 00 00 84 C0 74 22 FE C8 88 83 EF 17 00 00 75 18 8B 8B 50 39 01 00 8B 93 54 39 01 00 89 8B EC 38 01 00 89 93 F0 38 01 00)
TOS.exe+86CA5:
  jmp near fps_spell_knockback_timer // 00486CA5
  nop // 00486CAA
  nop // 00486CAB
  nop // 00486CAC
  nop // 00486CAD
  nop // 00486CAE
  nop // 00486CAF
  nop // 00486CB0
  nop // 00486CB1
  nop // 00486CB2
  nop // 00486CB3
  nop // 00486CB4
  nop // 00486CB5
  nop // 00486CB6
  nop // 00486CB7
  nop // 00486CB8
  nop // 00486CB9
  nop // 00486CBA
  nop // 00486CBB
  nop // 00486CBC
  nop // 00486CBD
  nop // 00486CBE
  nop // 00486CBF
  nop // 00486CC0
  nop // 00486CC1
  nop // 00486CC2
  nop // 00486CC3
  nop // 00486CC4
  nop // 00486CC5
  nop // 00486CC6
  nop // 00486CC7
  nop // 00486CC8
  nop // 00486CC9
  nop // 00486CCA
  nop // 00486CCB
  nop // 00486CCC
  nop // 00486CCD
  nop // 00486CCE
  nop // 00486CCF
  nop // 00486CD0
  nop // 00486CD1
  nop // 00486CD2
  nop // 00486CD3
  nop // 00486CD4
  nop // 00486CD5
  nop // 00486CD6
  nop // 00486CD7
  nop // 00486CD8
  nop // 00486CD9
  nop // 00486CDA
  nop // 00486CDB
  nop // 00486CDC
  nop // 00486CDD
  nop // 00486CDE
  nop // 00486CDF
  nop // 00486CE0
  nop // 00486CE1
  nop // 00486CE2
  nop // 00486CE3
  nop // 00486CE4
  nop // 00486CE5
  nop // 00486CE6
  nop // 00486CE7
  nop // 00486CE8
  nop // 00486CE9
  nop // 00486CEA
  nop // 00486CEB
  nop // 00486CEC
  nop // 00486CED
  nop // 00486CEE
  nop // 00486CEF
  nop // 00486CF0
  nop // 00486CF1
  nop // 00486CF2
  nop // 00486CF3
  nop // 00486CF4
  nop // 00486CF5
  nop // 00486CF6
  nop // 00486CF7
  nop // 00486CF8
  nop // 00486CF9
  nop // 00486CFA
  nop // 00486CFB
  nop // 00486CFC

// Reference VA 004870C8..004870CF.
// Decrement the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+870C8,66 83 83 BE 01 00 00 FE)
TOS.exe+870C8:
// Vanilla: add word ptr [ebx + 0x1be], -2
  db 66,83,83,BE,01,00,00,FF // add word ptr [ebx + 0x1be], -#1 // 004870C8

// Reference VA 0048726B..0048727B.
// Remove the repeated motion/collision sequence in this actor state.
assert(TOS.exe+8726B,E8 E0 37 FB FF 8B CE E8 E9 3B FB FF E8 64 3A FB FF)
TOS.exe+8726B:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ae60; call 0x43ace0
  nop // 0048726B
  nop // 0048726C
  nop // 0048726D
  nop // 0048726E
  nop // 0048726F
  nop // 00487270
  nop // 00487271
  nop // 00487272
  nop // 00487273
  nop // 00487274
  nop // 00487275
  nop // 00487276
  nop // 00487277
  nop // 00487278
  nop // 00487279
  nop // 0048727A
  nop // 0048727B

// Reference VA 00487861..00487861.
// Remove the second decrement of actor+1BE while preserving the remaining store and state continuation.
assert(TOS.exe+87861,48)
TOS.exe+87861:
// Vanilla: dec eax
  nop // 00487861

// Reference VA 00487BC4..00487BCF.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+87BC4,E8 87 2E FB FF 8B CB E8 10 31 FB FF)
TOS.exe+87BC4:
// Vanilla: call 0x43aa50; mov ecx, ebx; call 0x43ace0
  nop // 00487BC4
  nop // 00487BC5
  nop // 00487BC6
  nop // 00487BC7
  nop // 00487BC8
  nop // 00487BC9
  nop // 00487BCA
  nop // 00487BCB
  nop // 00487BCC
  nop // 00487BCD
  nop // 00487BCE
  nop // 00487BCF

// Reference VA 00487C07..00487C0E.
// Advance the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+87C07,66 83 83 BE 01 00 00 02)
TOS.exe+87C07:
// Vanilla: add word ptr [ebx + 0x1be], 2
  add word ptr [ebx + 0x1be], #1 // 00487C07

// Reference VA 00487C6E..00487C75.
// Advance the movement-script timer at +12F8 by one per update instead of two.
assert(TOS.exe+87C6E,66 83 86 F8 12 00 00 02)
TOS.exe+87C6E:
// Vanilla: add word ptr [esi + 0x12f8], 2
  add word ptr [esi + 0x12f8], #1 // 00487C6E

// Reference VA 00487D1D..00487D28.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+87D1D,E8 2E 2D FB FF 8B CE E8 B7 2F FB FF)
TOS.exe+87D1D:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 00487D1D
  nop // 00487D1E
  nop // 00487D1F
  nop // 00487D20
  nop // 00487D21
  nop // 00487D22
  nop // 00487D23
  nop // 00487D24
  nop // 00487D25
  nop // 00487D26
  nop // 00487D27
  nop // 00487D28

// Reference VA 00487D35..00487D3C.
// Advance the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+87D35,66 83 86 BE 01 00 00 02)
TOS.exe+87D35:
// Vanilla: add word ptr [esi + 0x1be], 2
  add word ptr [esi + 0x1be], #1 // 00487D35

// Reference VA 00488065..0048806C.
// Decrement the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+88065,66 83 86 BE 01 00 00 FE)
TOS.exe+88065:
// Vanilla: add word ptr [esi + 0x1be], -2
  db 66,83,86,BE,01,00,00,FF // add word ptr [esi + 0x1be], -#1 // 00488065

// Reference VA 004880C8..004880D3.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+880C8,E8 83 29 FB FF 8B CE E8 0C 2C FB FF)
TOS.exe+880C8:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 004880C8
  nop // 004880C9
  nop // 004880CA
  nop // 004880CB
  nop // 004880CC
  nop // 004880CD
  nop // 004880CE
  nop // 004880CF
  nop // 004880D0
  nop // 004880D1
  nop // 004880D2
  nop // 004880D3

// Reference VA 00488122..00488129.
// Decrement the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+88122,66 83 86 BE 01 00 00 FE)
TOS.exe+88122:
// Vanilla: add word ptr [esi + 0x1be], -2
  db 66,83,86,BE,01,00,00,FF // add word ptr [esi + 0x1be], -#1 // 00488122

// Reference VA 00488576..00488581.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+88576,E8 D5 24 FB FF 8B CE E8 5E 27 FB FF)
TOS.exe+88576:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 00488576
  nop // 00488577
  nop // 00488578
  nop // 00488579
  nop // 0048857A
  nop // 0048857B
  nop // 0048857C
  nop // 0048857D
  nop // 0048857E
  nop // 0048857F
  nop // 00488580
  nop // 00488581

// Reference VA 004886A4..004886AF.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+886A4,E8 A7 23 FB FF 8B CE E8 30 26 FB FF)
TOS.exe+886A4:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 004886A4
  nop // 004886A5
  nop // 004886A6
  nop // 004886A7
  nop // 004886A8
  nop // 004886A9
  nop // 004886AA
  nop // 004886AB
  nop // 004886AC
  nop // 004886AD
  nop // 004886AE
  nop // 004886AF

// Reference VA 0048879C..004887A7.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+8879C,E8 AF 22 FB FF 8B CE E8 38 25 FB FF)
TOS.exe+8879C:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 0048879C
  nop // 0048879D
  nop // 0048879E
  nop // 0048879F
  nop // 004887A0
  nop // 004887A1
  nop // 004887A2
  nop // 004887A3
  nop // 004887A4
  nop // 004887A5
  nop // 004887A6
  nop // 004887A7

// Reference VA 0048884E..00488859.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+8884E,E8 FD 21 FB FF 8B CE E8 86 24 FB FF)
TOS.exe+8884E:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 0048884E
  nop // 0048884F
  nop // 00488850
  nop // 00488851
  nop // 00488852
  nop // 00488853
  nop // 00488854
  nop // 00488855
  nop // 00488856
  nop // 00488857
  nop // 00488858
  nop // 00488859

// Reference VA 004888EF..004888F6.
// Decrement the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+888EF,66 83 86 BE 01 00 00 FE)
TOS.exe+888EF:
// Vanilla: add word ptr [esi + 0x1be], -2
  db 66,83,86,BE,01,00,00,FF // add word ptr [esi + 0x1be], -#1 // 004888EF

// Reference VA 004889D7..004889E2.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+889D7,E8 74 20 FB FF 8B CE E8 FD 22 FB FF)
TOS.exe+889D7:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 004889D7
  nop // 004889D8
  nop // 004889D9
  nop // 004889DA
  nop // 004889DB
  nop // 004889DC
  nop // 004889DD
  nop // 004889DE
  nop // 004889DF
  nop // 004889E0
  nop // 004889E1
  nop // 004889E2

// Reference VA 00488C05..00488C5A.
// Remove the repeated motion/collision pass and its conditional vertical oscillation in this actor
// state.
assert(TOS.exe+88C05,E8 46 1E FB FF 8B CB E8 4F 22 FB FF F6 83 91 02 00 00 07 74 3C 8B 53 04 F6 42 5C 02 74 33 0F B7 83 9E 02 00 00 03 C0 03 C0 99 B9 68 01 00 00 F7 F9 A1 DC 2E AD 00 8B 88 40 9A 00 00 D9 04 91 DC 0D 50 29 88 00 D8 83 A0 38 01 00 D9 9B A0 38 01 00 E8 B5 1F FB FF)
TOS.exe+88C05:
  nop // 00488C05
  nop // 00488C06
  nop // 00488C07
  nop // 00488C08
  nop // 00488C09
  nop // 00488C0A
  nop // 00488C0B
  nop // 00488C0C
  nop // 00488C0D
  nop // 00488C0E
  nop // 00488C0F
  nop // 00488C10
  nop // 00488C11
  nop // 00488C12
  nop // 00488C13
  nop // 00488C14
  nop // 00488C15
  nop // 00488C16
  nop // 00488C17
  nop // 00488C18
  nop // 00488C19
  nop // 00488C1A
  nop // 00488C1B
  nop // 00488C1C
  nop // 00488C1D
  nop // 00488C1E
  nop // 00488C1F
  nop // 00488C20
  nop // 00488C21
  nop // 00488C22
  nop // 00488C23
  nop // 00488C24
  nop // 00488C25
  nop // 00488C26
  nop // 00488C27
  nop // 00488C28
  nop // 00488C29
  nop // 00488C2A
  nop // 00488C2B
  nop // 00488C2C
  nop // 00488C2D
  nop // 00488C2E
  nop // 00488C2F
  nop // 00488C30
  nop // 00488C31
  nop // 00488C32
  nop // 00488C33
  nop // 00488C34
  nop // 00488C35
  nop // 00488C36
  nop // 00488C37
  nop // 00488C38
  nop // 00488C39
  nop // 00488C3A
  nop // 00488C3B
  nop // 00488C3C
  nop // 00488C3D
  nop // 00488C3E
  nop // 00488C3F
  nop // 00488C40
  nop // 00488C41
  nop // 00488C42
  nop // 00488C43
  nop // 00488C44
  nop // 00488C45
  nop // 00488C46
  nop // 00488C47
  nop // 00488C48
  nop // 00488C49
  nop // 00488C4A
  nop // 00488C4B
  nop // 00488C4C
  nop // 00488C4D
  nop // 00488C4E
  nop // 00488C4F
  nop // 00488C50
  nop // 00488C51
  nop // 00488C52
  nop // 00488C53
  nop // 00488C54
  nop // 00488C55
  nop // 00488C56
  nop // 00488C57
  nop // 00488C58
  nop // 00488C59
  nop // 00488C5A

// Reference VA 0048921A..0048921C.
// Decrement the alternate spell-recovery clock by one instead of two.
assert(TOS.exe+8921A,83 C0 FE)
TOS.exe+8921A:
// Vanilla: add eax, -2
  add eax, -#1 // 0048921A

// Reference VA 0048925C..00489267.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+8925C,E8 EF 17 FB FF 8B CE E8 78 1A FB FF)
TOS.exe+8925C:
// Vanilla: call 0x43aa50; mov ecx, esi; call 0x43ace0
  nop // 0048925C
  nop // 0048925D
  nop // 0048925E
  nop // 0048925F
  nop // 00489260
  nop // 00489261
  nop // 00489262
  nop // 00489263
  nop // 00489264
  nop // 00489265
  nop // 00489266
  nop // 00489267

// Reference VA 0048948B..00489492.
// Decrement the actor state timer at +1BE by one per update instead of two.
assert(TOS.exe+8948B,66 83 83 BE 01 00 00 FE)
TOS.exe+8948B:
// Vanilla: add word ptr [ebx + 0x1be], -2
  db 66,83,83,BE,01,00,00,FF // add word ptr [ebx + 0x1be], -#1 // 0048948B

// Reference VA 004894CD..004894D8.
// Remove the repeated actor position-integration and collision pass in this state handler.
assert(TOS.exe+894CD,E8 7E 15 FB FF 8B CB E8 07 18 FB FF)
TOS.exe+894CD:
// Vanilla: call 0x43aa50; mov ecx, ebx; call 0x43ace0
  nop // 004894CD
  nop // 004894CE
  nop // 004894CF
  nop // 004894D0
  nop // 004894D1
  nop // 004894D2
  nop // 004894D3
  nop // 004894D4
  nop // 004894D5
  nop // 004894D6
  nop // 004894D7
  nop // 004894D8

// ----------------------------------------------------------------------
// Reference payload 02EFF230..02EFF269; retained code/data/padding.
fps_battle_actor_timing_code+0:
// Decrement delayed knockback once; transfer stored XY velocity only on nonzero-to-zero transition.
fps_spell_knockback_timer:
  mov al, byte ptr [ebx + 0x17ef] // 02EFF230
  test al, al // 02EFF236
  je near TOS.exe+86CFD // 02EFF238
  dec al // 02EFF23E
  mov byte ptr [ebx + 0x17ef], al // 02EFF240
  jne near TOS.exe+86CFD // 02EFF246
  mov edx, dword ptr [ebx + 0x13950] // 02EFF24C
  mov eax, dword ptr [ebx + 0x13954] // 02EFF252
  mov dword ptr [ebx + 0x138ec], edx // 02EFF258
  mov dword ptr [ebx + 0x138f0], eax // 02EFF25E
  jmp near TOS.exe+86CFD // 02EFF264
  db 00 // 02EFF269: constants / retained padding

// ======================================================================
// Battle artes
// Arte cooldown/compensation, blend-node cleanup, callback guards and Crimson duplicate updates.
// Actor +12FF cooldown and +12E9 pending compensation form one protocol: keep reset, consumption and
// attack compensation together.
// Animation cleanup preserves active/pending/rendered ownership. Crimson frame state starts at zero,
// matching the reference executable.
// ======================================================================

alloc(fps_battle_artes_code,1000)
alloc(crimson_frame,2)

define(fps_crimson_last_frame,crimson_frame)
label(fps_animation_pool_cleanup)
label(fps_arte_animation_cooldown)
label(fps_arte_callback_blend_guard)
label(fps_arte_pending_reset)
label(fps_attack_pending_compensation)
label(fps_crimson_duplicate_frame_guard)
label(fps_loc_007021AE)
label(fps_loc_007021D4)
label(fps_loc_01E4A01B)
label(fps_loc_01E4A049)
label(fps_loc_01E4A04D)
label(fps_loc_01E4A054)
label(fps_loc_01E4A059)
label(fps_loc_01E4A067)
label(fps_loc_01E4A06C)
label(fps_loc_01E4A072)
label(fps_loc_01E4A0EA)
label(fps_loc_01E4A10B)
label(fps_loc_01E4A11C)
label(fps_loc_01E4A155)
label(fps_loc_01E4A176)
label(fps_loc_01E4A183)
label(fps_loc_01E4A1C5)
label(fps_loc_01E4A1D7)
label(fps_loc_01E4A206)
label(fps_loc_01E4A20E)
label(fps_loc_01E4A221)
label(fps_loc_01E4A223)
label(fps_loc_02EFF2A1)
label(fps_loc_02EFFF19)
label(fps_loc_02EFFF29)
label(fps_loc_02EFFF2B)
label(fps_loc_02EFFF35)
label(fps_loc_02EFFF3A)

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+D726,53 56 8B 75 08)
assert(TOS.exe+27F2F,74 06 56 FF D0)
assert(TOS.exe+27F37,53 8B C6 E8 F1)
assert(TOS.exe+4083E,8B FF 83 3E 00)
assert(TOS.exe+41070,8B 8E F0 12 00)
assert(TOS.exe+45238,F6 87 20 13 00)

// Reference VA 0040D720..0040D725.
// Enter the Crimson callback through a frame-counter guard so repeated callbacks in the same engine
// frame do not advance this effect twice.
assert(TOS.exe+D720,55 8B EC 83 EC 28)
TOS.exe+D720:
// Vanilla: push ebp; mov ebp, esp; sub esp, 0x28
  jmp near fps_crimson_duplicate_frame_guard // 0040D720
  nop // 0040D725

// Reference VA 00427F28..00427F2E.
// Find the type-6 animation node, falling back to the first node when none is found. Skip the physical-
// arte callback while the selected node blends; preserve native outer state updates and callback flags.
assert(TOS.exe+27F28,8B 46 18 33 DB 3B C3)
TOS.exe+27F28:
// Vanilla: mov eax, dword ptr [esi + 0x18]; xor ebx, ebx; cmp eax, ebx
  jmp near fps_arte_callback_blend_guard // 00427F28
  nop // 00427F2D
  nop // 00427F2E

// Reference VA 00440836..0044083D.
// Reclaim eligible stale blend-node slots before selecting an arte animation node; protect active,
// pending and rendered nodes.
assert(TOS.exe+40836,33 C0 8D B7 70 11 00 00)
TOS.exe+40836:
// Vanilla: xor eax, eax; lea esi, [edi + 0x1170]
  jmp near fps_animation_pool_cleanup // 00440836
  nop // 0044083B
  nop // 0044083C
  nop // 0044083D

// Reference VA 00441009..0044100E.
// Do not add a stale +12FF cooldown byte to the incoming animation blend parameter. The cooldown flag is
// repurposed by the v46 arte protocol.
assert(TOS.exe+41009,02 97 FF 12 00 00)
TOS.exe+41009:
// Vanilla: add dl, byte ptr [edi + 0x12ff]
  nop // 00441009
  nop // 0044100A
  nop // 0044100B
  nop // 0044100C
  nop // 0044100D
  nop // 0044100E

// Reference VA 00441050..0044105D.
// Replay the native animation timer/index initialization and clear the pending compensation count at
// actor+12E9.
assert(TOS.exe+41050,C7 87 FC 12 00 00 00 00 01 00 8B E5 5D C3)
TOS.exe+41050:
// Vanilla: mov dword ptr [edi + 0x12fc], 0x10000; mov esp, ebp; pop ebp; ret
  jmp near fps_arte_pending_reset // 00441050
  nop // 00441055
  nop // 00441056
  nop // 00441057
  nop // 00441058
  nop // 00441059
  nop // 0044105A
  nop // 0044105B
  nop // 0044105C
  nop // 0044105D

// Reference VA 00441069..0044106F.
// Consume one cooldown skip at actor+12FF and record it at +12E9; otherwise continue the original
// animation entry lookup.
assert(TOS.exe+41069,0F BE 86 FE 12 00 00)
TOS.exe+41069:
// Vanilla: movsx eax, byte ptr [esi + 0x12fe]
  jmp near fps_arte_animation_cooldown // 00441069
  nop // 0044106E
  nop // 0044106F

// Reference VA 004412D1..004412E9.
// Set the one-update animation cooldown after a transition, and advance the normal animation-script
// timer by one. Keep this with pending compensation.
assert(TOS.exe+412D1,B8 11 00 00 00 5F 5E 8B E5 5D C3 66 83 86 FC 12 00 00 02 5F B8 01 00 00 00)
TOS.exe+412D1:
// Vanilla: mov eax, 0x11; pop edi; pop esi; mov esp, ebp; pop ebp; ret ; add word ptr [esi + 0x12fc], 2; pop edi; mov eax, 1
  mov byte ptr [esi + 0x12ff], #1 // 004412D1
  mov al, 0x11 // 004412D8
  jmp short TOS.exe+412E9 // 004412DA
  add word ptr [esi + 0x12fc], #1 // 004412DC
  mov eax, #1 // 004412E4
  pop edi // 004412E9

// Reference VA 00445231..00445237.
// Advance the attack entry and consume one pending cooldown compensation only when actor+12E9 is
// nonzero.
assert(TOS.exe+45231,83 87 10 01 00 00 20)
TOS.exe+45231:
// Vanilla: add dword ptr [edi + 0x110], 0x20
  jmp near fps_attack_pending_compensation // 00445231
  nop // 00445236
  nop // 00445237

// ----------------------------------------------------------------------
// Reference payload 00702185..007021DF; retained code/data/padding.
fps_battle_artes_code+5:
// Replicate Crimson prologue and skip duplicate frame-counter callbacks, preserving billboard/voice timing.
fps_crimson_duplicate_frame_guard:
  push ebp // 00702185
  db 8B,EC // mov ebp, esp // 00702186
  sub esp, 0x28 // 00702188
  push eax // 0070218B
  push ecx // 0070218C
  mov eax, dword ptr [ebp + #8] // 0070218D
  movzx ecx, word ptr [eax + 0x1be] // 00702190
  cmp cx, word ptr [fps_crimson_last_frame] // 00702197
  je short fps_loc_007021AE // 0070219E
  mov word ptr [fps_crimson_last_frame], cx // 007021A0
  pop ecx // 007021A7
  pop eax // 007021A8
  jmp near TOS.exe+D726 // 007021A9
fps_loc_007021AE:
  pop ecx // 007021AE
  pop eax // 007021AF
  db 8B,E5 // mov esp, ebp // 007021B0
  pop ebp // 007021B2
  ret // 007021B3

// Consume animation transition cooldown and increment actor+12E9 pending compensation; otherwise replay original index load.
fps_arte_animation_cooldown:
  cmp byte ptr [esi + 0x12ff], #0 // 007021B4
  je short fps_loc_007021D4 // 007021BB
  mov byte ptr [esi + 0x12ff], #0 // 007021BD
  inc byte ptr [esi + 0x12e9] // 007021C4
  mov eax, #1 // 007021CA
  pop esi // 007021CF
  db 8B,E5 // mov esp, ebp // 007021D0
  pop ebp // 007021D2
  ret // 007021D3
fps_loc_007021D4:
  movsx eax, byte ptr [esi + 0x12fe] // 007021D4
  jmp near TOS.exe+41070 // 007021DB

// ----------------------------------------------------------------------
// Reference payload 01E4A000..01E4A22F; retained code/data/padding.
fps_battle_artes_code+60:
// Before battle animation allocation, collect only unreachable outgoing nodes; preserve roots, pending links, shared resources and deferred release protocol.
fps_animation_pool_cleanup:
  pushfd // 01E4A000
  pushad // 01E4A001
  push ecx // 01E4A002
  push edi // 01E4A003
  call fps_loc_01E4A072 // 01E4A004
  add esp, #8 // 01E4A009
  popad // 01E4A00C
  popfd // 01E4A00D
  xor eax, eax // 01E4A00E
  lea esi, [edi + 0x1170] // 01E4A010
  jmp near TOS.exe+4083E // 01E4A016
fps_loc_01E4A01B:
  test edx, edx // 01E4A01B
  je short fps_loc_01E4A06C // 01E4A01D
  push ebp // 01E4A01F
  mov ebp, esp // 01E4A020
  push ebx // 01E4A022
  mov ebx, ecx // 01E4A023
  cmp edx, eax // 01E4A025
  je short fps_loc_01E4A049 // 01E4A027
  lea ecx, [eax + 0x34] // 01E4A029
  cmp edx, ecx // 01E4A02C
  je short fps_loc_01E4A04D // 01E4A02E
  lea ecx, [eax + 0x68] // 01E4A030
  cmp edx, ecx // 01E4A033
  je short fps_loc_01E4A054 // 01E4A035
  add eax, 0x9c // 01E4A037
  xor ecx, ecx // 01E4A03C
  cmp edx, eax // 01E4A03E
  jne short fps_loc_01E4A067 // 01E4A040
  mov ecx, #3 // 01E4A042
  jmp short fps_loc_01E4A059 // 01E4A047
fps_loc_01E4A049:
  xor ecx, ecx // 01E4A049
  jmp short fps_loc_01E4A059 // 01E4A04B
fps_loc_01E4A04D:
  mov ecx, #1 // 01E4A04D
  jmp short fps_loc_01E4A059 // 01E4A052
fps_loc_01E4A054:
  mov ecx, #2 // 01E4A054
fps_loc_01E4A059:
  mov eax, #1 // 01E4A059
  shl eax, cl // 01E4A05E
  or dword ptr [ebx], eax // 01E4A060
  mov ecx, #1 // 01E4A062
fps_loc_01E4A067:
  mov eax, ecx // 01E4A067
  pop ebx // 01E4A069
  pop ebp // 01E4A06A
  ret // 01E4A06B
fps_loc_01E4A06C:
  mov eax, #1 // 01E4A06C
  ret // 01E4A071
fps_loc_01E4A072:
  push ebp // 01E4A072
  mov ebp, esp // 01E4A073
  push edi // 01E4A075
  xor edi, edi // 01E4A076
  push esi // 01E4A078
  push ebx // 01E4A079
  sub esp, 0x18 // 01E4A07A
  mov eax, dword ptr [ebp + #8] // 01E4A07D
  mov dword ptr [ebp - 0x10], edi // 01E4A080
  mov ebx, dword ptr [eax + 0x2c4] // 01E4A083
  test ebx, ebx // 01E4A089
  je near fps_loc_01E4A223 // 01E4A08B
  mov edx, dword ptr [ebx + 0x718] // 01E4A091
  test edx, edx // 01E4A097
  je near fps_loc_01E4A221 // 01E4A099
  mov ebx, dword ptr [ebx + 0x740] // 01E4A09F
  test ebx, ebx // 01E4A0A5
  je near fps_loc_01E4A223 // 01E4A0A7
  add eax, 0x1170 // 01E4A0AD
  lea ecx, [ebp - 0x10] // 01E4A0B2
  mov dword ptr [ebp - 0x14], eax // 01E4A0B5
  call fps_loc_01E4A01B // 01E4A0B8
  test eax, eax // 01E4A0BD
  je near fps_loc_01E4A221 // 01E4A0BF
  mov edx, dword ptr [ebx + 0x3264] // 01E4A0C5
  mov eax, dword ptr [ebp - 0x14] // 01E4A0CB
  lea ecx, [ebp - 0x10] // 01E4A0CE
  call fps_loc_01E4A01B // 01E4A0D1
  test eax, eax // 01E4A0D6
  je near fps_loc_01E4A221 // 01E4A0D8
  lea esi, [ebx + 0x326c] // 01E4A0DE
  add ebx, 0x334c // 01E4A0E4
fps_loc_01E4A0EA:
  mov edx, dword ptr [esi] // 01E4A0EA
  mov eax, dword ptr [ebp - 0x14] // 01E4A0EC
  lea ecx, [ebp - 0x10] // 01E4A0EF
  call fps_loc_01E4A01B // 01E4A0F2
  test eax, eax // 01E4A0F7
  je near fps_loc_01E4A221 // 01E4A0F9
  add esi, 0x38 // 01E4A0FF
  cmp ebx, esi // 01E4A102
  jne short fps_loc_01E4A0EA // 01E4A104
  mov ebx, #4 // 01E4A106
fps_loc_01E4A10B:
  mov eax, dword ptr [ebp - 0x10] // 01E4A10B
  xor edi, edi // 01E4A10E
  mov dword ptr [ebp - 0x18], eax // 01E4A110
  mov eax, dword ptr [ebp + #8] // 01E4A113
  lea esi, [eax + 0x11a0] // 01E4A116
fps_loc_01E4A11C:
  mov eax, #1 // 01E4A11C
  mov ecx, edi // 01E4A121
  shl eax, cl // 01E4A123
  test dword ptr [ebp - 0x10], eax // 01E4A125
  je short fps_loc_01E4A155 // 01E4A128
  mov edx, dword ptr [esi - #4] // 01E4A12A
  mov eax, dword ptr [ebp - 0x14] // 01E4A12D
  lea ecx, [ebp - 0x10] // 01E4A130
  call fps_loc_01E4A01B // 01E4A133
  test eax, eax // 01E4A138
  je near fps_loc_01E4A221 // 01E4A13A
  mov edx, dword ptr [esi] // 01E4A140
  mov eax, dword ptr [ebp - 0x14] // 01E4A142
  lea ecx, [ebp - 0x10] // 01E4A145
  call fps_loc_01E4A01B // 01E4A148
  test eax, eax // 01E4A14D
  je near fps_loc_01E4A221 // 01E4A14F
fps_loc_01E4A155:
  inc edi // 01E4A155
  add esi, 0x34 // 01E4A156
  cmp edi, #4 // 01E4A159
  jne short fps_loc_01E4A11C // 01E4A15C
  mov eax, dword ptr [ebp - 0x18] // 01E4A15E
  cmp dword ptr [ebp - 0x10], eax // 01E4A161
  je short fps_loc_01E4A176 // 01E4A164
  dec ebx // 01E4A166
  jne short fps_loc_01E4A10B // 01E4A167
  mov eax, dword ptr [ebp - 0x14] // 01E4A169
  xor esi, esi // 01E4A16C
  mov dword ptr [ebp - 0x20], esi // 01E4A16E
  mov dword ptr [ebp - 0x1c], eax // 01E4A171
  jmp short fps_loc_01E4A183 // 01E4A174
fps_loc_01E4A176:
  mov eax, dword ptr [ebp - 0x14] // 01E4A176
  xor ecx, ecx // 01E4A179
  xor ebx, ebx // 01E4A17B
  mov dword ptr [ebp - 0x20], ecx // 01E4A17D
  mov dword ptr [ebp - 0x1c], eax // 01E4A180
fps_loc_01E4A183:
  mov eax, dword ptr [ebp - 0x1c] // 01E4A183
  mov cl, byte ptr [ebp - 0x20] // 01E4A186
  mov eax, dword ptr [eax] // 01E4A189
  mov dword ptr [ebp - 0x18], eax // 01E4A18B
  mov eax, #1 // 01E4A18E
  shl eax, cl // 01E4A193
  test dword ptr [ebp - 0x10], eax // 01E4A195
  jne short fps_loc_01E4A20E // 01E4A198
  cmp dword ptr [ebp - 0x18], #0 // 01E4A19A
  je short fps_loc_01E4A20E // 01E4A19E
  mov eax, dword ptr [ebp - 0x1c] // 01E4A1A0
  mov eax, dword ptr [eax + 0x1c] // 01E4A1A3
  mov dword ptr [ebp - 0x24], eax // 01E4A1A6
  not eax // 01E4A1A9
  test eax, 0xc0000000 // 01E4A1AB
  jne short fps_loc_01E4A20E // 01E4A1B0
  mov eax, dword ptr [ebp - 0x18] // 01E4A1B2
  cmp eax, dword ptr [ebp + 0xc] // 01E4A1B5
  sete al // 01E4A1B8
  mov ecx, dword ptr [ebp - 0x14] // 01E4A1BB
  movzx eax, al // 01E4A1BE
  mov edi, eax // 01E4A1C1
  xor eax, eax // 01E4A1C3
fps_loc_01E4A1C5:
  cmp dword ptr [ebp - 0x20], eax // 01E4A1C5
  je short fps_loc_01E4A1D7 // 01E4A1C8
  mov edx, dword ptr [ebp - 0x18] // 01E4A1CA
  cmp dword ptr [ecx], edx // 01E4A1CD
  sete dl // 01E4A1CF
  movzx edx, dl // 01E4A1D2
  or edi, edx // 01E4A1D5
fps_loc_01E4A1D7:
  inc eax // 01E4A1D7
  add ecx, 0x34 // 01E4A1D8
  cmp eax, #4 // 01E4A1DB
  jne short fps_loc_01E4A1C5 // 01E4A1DE
  test edi, edi // 01E4A1E0
  jne short fps_loc_01E4A206 // 01E4A1E2
  mov eax, dword ptr [ebp - 0x18] // 01E4A1E4
  mov esi, dword ptr [eax + 0x44] // 01E4A1E7
  mov byte ptr [eax + 0x10], #0 // 01E4A1EA
  test esi, esi // 01E4A1EE
  je short fps_loc_01E4A206 // 01E4A1F0
  cmp byte ptr [eax + 0x48], #0 // 01E4A1F2
  je short fps_loc_01E4A206 // 01E4A1F6
  mov edi, TOS.exe+17B3D0 // 01E4A1F8
  call edi // 01E4A1FD
  mov eax, dword ptr [ebp - 0x18] // 01E4A1FF
  mov byte ptr [eax + 0x48], #0 // 01E4A202
fps_loc_01E4A206:
  mov eax, dword ptr [ebp - 0x1c] // 01E4A206
  xor edx, edx // 01E4A209
  inc ebx // 01E4A20B
  mov dword ptr [eax], edx // 01E4A20C
fps_loc_01E4A20E:
  inc dword ptr [ebp - 0x20] // 01E4A20E
  add dword ptr [ebp - 0x1c], 0x34 // 01E4A211
  cmp dword ptr [ebp - 0x20], #4 // 01E4A215
  jne near fps_loc_01E4A183 // 01E4A219
  jmp short fps_loc_01E4A223 // 01E4A21F
fps_loc_01E4A221:
  xor ebx, ebx // 01E4A221
fps_loc_01E4A223:
  add esp, 0x18 // 01E4A223
  mov eax, ebx // 01E4A226
  pop ebx // 01E4A228
  pop esi // 01E4A229
  pop edi // 01E4A22A
  pop ebp // 01E4A22B
  ret // 01E4A22C

// Retained INT3 tail from the original cleanup reservation.
  db CC,CC,CC // 01E4A22D: constants / retained padding

// ----------------------------------------------------------------------
// Reference payload 02EFF283..02EFF2CB; retained code/data/padding.
fps_battle_artes_code+293:
// Advance hit-table entry; consume pending actor+12E9 and subtract one attack tick only for a real cooldown event.
fps_attack_pending_compensation:
  add dword ptr [edi + 0x110], 0x20 // 02EFF283
  cmp byte ptr [edi + 0x12e9], #0 // 02EFF28A
  je short fps_loc_02EFF2A1 // 02EFF291
  dec byte ptr [edi + 0x12e9] // 02EFF293
  sub word ptr [edi + 0x12fa], #1 // 02EFF299
fps_loc_02EFF2A1:
  jmp near TOS.exe+45238 // 02EFF2A1
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF2A6: constants / retained padding

// Replay arte timer/index initialization and zero actor+12E9 pending compensation.
fps_arte_pending_reset:
  mov dword ptr [edi + 0x12fc], 0x10000 // 02EFF2B6
  mov byte ptr [edi + 0x12e9], #0 // 02EFF2C0
  db 8B,E5 // mov esp, ebp // 02EFF2C7
  pop ebp // 02EFF2C9
  ret // 02EFF2CA
  db 00 // 02EFF2CB: constants / retained padding

// ----------------------------------------------------------------------
// Reference payload 02EFFEC0..02EFFF7F; retained code/data/padding.
fps_battle_artes_code+2E0:
db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFEC0: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFED0: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFEE0: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFEF0: constants / retained padding

// Prefer the type-6 node, or the first node if no type-6 node exists. Skip callbacks while
// the selected node blends; preserve native outer attack-state updates and flags.
fps_arte_callback_blend_guard:
  mov eax, dword ptr [esi + 0x18] // 02EFFF00
  xor ebx, ebx // 02EFFF03
  cmp eax, ebx // 02EFFF05
  je short fps_loc_02EFFF35 // 02EFFF07
  push eax // 02EFFF09
  push ecx // 02EFFF0A
  mov eax, dword ptr [esi + 0x2c4] // 02EFFF0B
  mov eax, dword ptr [eax + 0x718] // 02EFFF11
  mov ecx, eax // 02EFFF17
fps_loc_02EFFF19:
  test eax, eax // 02EFFF19
  je short fps_loc_02EFFF29 // 02EFFF1B
  cmp word ptr [eax + #6], #6 // 02EFFF1D
  je short fps_loc_02EFFF2B // 02EFFF22
  mov eax, dword ptr [eax + 0x2c] // 02EFFF24
  jmp short fps_loc_02EFFF19 // 02EFFF27
fps_loc_02EFFF29:
  mov eax, ecx // 02EFFF29
fps_loc_02EFFF2B:
  test byte ptr [eax + 0x20], 0x80 // 02EFFF2B
  pop ecx // 02EFFF2F
  pop eax // 02EFFF30
  jne short fps_loc_02EFFF3A // 02EFFF31
  cmp eax, ebx // 02EFFF33
fps_loc_02EFFF35:
  jmp near TOS.exe+27F2F // 02EFFF35
fps_loc_02EFFF3A:
  jmp near TOS.exe+27F37 // 02EFFF3A
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFF3F: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFF4F: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFF5F: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFF6F: constants / retained padding
  db 00 // 02EFFF7F: constants / retained padding

// Private RW state; reference 01E37FF0..01E37FF1.
crimson_frame:
// Historical docs specify FFFF, but this cell has no file backing; normal fresh PE page initialization is zero. Preserve requested xdelta runtime initialization unless deliberately fixing behavior.
// Allocation bytes start at zero; no debugger state is copied.
  db 00

// ======================================================================
// Chant timing
// Active voice-bank chant duration lookup and cache lifecycle.
// Keep chant hooks and the intro-duration consumer with the zero-initialized cache pointer.
// Audio reset and bank replacement invalidate the same state; intros retain authored durations.
// ======================================================================

alloc(fps_chant_timing_code,1000)
alloc(chant_cache,4)

define(fps_chant_voice_state_ptr,chant_cache)
label(fps_chant_hook_audio_reset)
label(fps_chant_hook_bank)
label(fps_chant_hook_selected)
label(fps_chant_hook_shared)
label(fps_chant_hook_table)
label(fps_chant_hook_intro)
label(fps_chant_intro_native)
label(fps_chant_intro_done)
label(fps_abyssion_intro_timeout)
label(fps_abyssion_intro_done)
label(fps_chant_le32)
label(fps_chant_read_at)
label(fps_chant_voice_bank_changed)
label(fps_chant_voice_build)
label(fps_chant_voice_ensure)
label(fps_chant_voice_get_state)
label(fps_chant_voice_table_loaded)
label(fps_chant_voice_ticks)
label(fps_loc_01E4A335)
label(fps_loc_01E4A35C)
label(fps_loc_01E4A38B)
label(fps_loc_01E4A3D7)
label(fps_loc_01E4A3D9)
label(fps_loc_01E4A420)
label(fps_loc_01E4A432)
label(fps_loc_01E4A448)
label(fps_loc_01E4A44C)
label(fps_loc_01E4A458)
label(fps_loc_01E4A489)
label(fps_loc_01E4A59B)
label(fps_loc_01E4A5CF)
label(fps_loc_01E4A5E7)
label(fps_loc_01E4A65C)
label(fps_loc_01E4A6A4)
label(fps_loc_01E4A6A7)
label(fps_loc_01E4A6C6)
label(fps_loc_01E4A6CD)
label(fps_loc_01E4A6D6)
label(fps_loc_01E4A790)
label(fps_loc_01E4A79E)
label(fps_loc_01E4A7BF)
label(fps_loc_01E4A7F9)
label(fps_loc_01E4A800)
label(fps_loc_01E4A815)
label(fps_loc_01E4A818)
label(fps_loc_01E4A830)
label(fps_loc_01E4A838)
label(fps_loc_01E4A85A)
label(fps_loc_01E4A85E)
label(fps_loc_01E4A883)
label(fps_loc_01E4A89F)

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+267D8,0F B7 C6 F7 C6)
assert(TOS.exe+632B6,A9 00 00 FF FF)
assert(TOS.exe+67B00,8B 45 08 8B 4D)
assert(TOS.exe+181682,D9 15 E8 BF B1)
assert(TOS.exe+182972,C6 86 6C AE B1)

// Preserve authored intro timing independently of measured chant lengths.
// The generic intro also serves seven camera indices and two scripted fallbacks.
// Accepted memory trial: tos-60-experiments/abyssion-intro/original-duration-hook.
// Keep native even-rounding after the helper; the 60 FPS counter edits stay intact.
assert(TOS.exe+10F2,74 01 41 0F B7 F9)
assert(TOS.exe+10EB,0F B7 0C 4A F6 C1 01)
TOS.exe+10EB:
// Vanilla: movzx ecx, word ptr [edx + ecx*2]; test cl, 1
  jmp near fps_chant_hook_intro
  nop
  nop

// Abyssion's English intro should end in the gap before "power".
// Accepted 3300 ms playback cap; retain native AI and measured chant timings.
// Guards cover the original queue call, return site and native callees.
assert(TOS.exe+39619,E8 B2 87 00 00)
assert(TOS.exe+3961E,8A 87 AC 3A 01 00)
assert(TOS.exe+28A10,0F B7 C0 8B 04 85 C0 2E AD 00 E8 11 9C 15 00)
assert(TOS.exe+41DD0,53 56 8B F0 57 8B 7E 04)
TOS.exe+39619:
// Vanilla: call TOS.exe+41DD0 (queued voice processing, actor in EAX).
  call fps_abyssion_intro_timeout

// Reference VA 004267D2..004267D7.
// Use the duration from the currently loaded voice bank when selecting a chant; the helper follows the
// active-bank cache lifecycle.
assert(TOS.exe+267D2,8B B3 A0 3A 01 00)
TOS.exe+267D2:
// Vanilla: mov esi, dword ptr [ebx + 0x13aa0]
  jmp near fps_chant_hook_selected // 004267D2
  nop // 004267D7

// Reference VA 004632B0..004632B5.
// Route the shared chant-duration lookup through the active-bank cache.
assert(TOS.exe+632B0,8B 0D DC 2E AD 00)
TOS.exe+632B0:
// Vanilla: mov ecx, dword ptr [0xad2edc]
  jmp near fps_chant_hook_shared // 004632B0
  nop // 004632B5

// Reference VA 00467AFA..00467AFF.
// Capture/install durations for the active battle voice table through the shared cache helper.
assert(TOS.exe+67AFA,89 87 3C 9A 00 00)
TOS.exe+67AFA:
// Vanilla: mov dword ptr [edi + 0x9a3c], eax
  jmp near fps_chant_hook_table // 00467AFA
  nop // 00467AFF

// Reference VA 0058167C..00581681.
// Active-bank chant durations: hook_audio_reset. Executable correction; cache follows loaded BTLSTR bank.
assert(TOS.exe+18167C,89 1D 7C AE B1 00)
TOS.exe+18167C:
// Vanilla: mov dword ptr [0xb1ae7c], ebx
  jmp near fps_chant_hook_audio_reset // 0058167C
  nop // 00581681

// Reference VA 0058296B..00582971.
// Active-bank chant durations: hook_bank. Executable correction; cache follows loaded BTLSTR bank.
assert(TOS.exe+18296B,89 04 B5 08 C0 B1 00)
TOS.exe+18296B:
// Vanilla: mov dword ptr [esi*4 + 0xb1c008], eax
  jmp near fps_chant_hook_bank // 0058296B
  nop // 00582970
  nop // 00582971

// ----------------------------------------------------------------------
// Reference payload 01E4A300..01E4A977; retained code/data/padding.
fps_chant_timing_code+0:
// Read active AWB/ADX sample durations, maintain pristine timing-table fallback and cache by voice bank; invalidate on bank/audio reset and table replacement.
fps_chant_le32:
  mov eax, dword ptr [eax] // 01E4A300
  ret // 01E4A302
fps_chant_read_at:
  push ebp // 01E4A303
  mov ebp, esp // 01E4A304
  push edi // 01E4A306
  mov edi, edx // 01E4A307
  push esi // 01E4A309
  mov esi, eax // 01E4A30A
  xor eax, eax // 01E4A30C
  push ebx // 01E4A30E
  mov ebx, ecx // 01E4A30F
  sub esp, #8 // 01E4A311
  mov dword ptr [ebp - 0x14], eax // 01E4A314
  mov dword ptr [ebp - 0x10], eax // 01E4A317
  lea eax, [ebp - 0x10] // 01E4A31A
  push #0 // 01E4A31D
  push eax // 01E4A31F
  push edx // 01E4A320
  push esi // 01E4A321
  call dword ptr [TOS.exe+2A989DD] // 01E4A322
  mov ecx, 0xffffffff // 01E4A328
  cmp dword ptr [ebp - 0x10], #0 // 01E4A32D
  jne short fps_loc_01E4A335 // 01E4A331
  mov ecx, eax // 01E4A333
fps_loc_01E4A335:
  xor eax, eax // 01E4A335
  cmp edi, ecx // 01E4A337
  jne short fps_loc_01E4A35C // 01E4A339
  lea eax, [ebp - 0x14] // 01E4A33B
  push #0 // 01E4A33E
  push eax // 01E4A340
  push dword ptr [ebp + #8] // 01E4A341
  push ebx // 01E4A344
  push esi // 01E4A345
  call dword ptr [TOS.exe+2A989E1] // 01E4A346
  test eax, eax // 01E4A34C
  je short fps_loc_01E4A35C // 01E4A34E
  mov eax, dword ptr [ebp + #8] // 01E4A350
  cmp dword ptr [ebp - 0x14], eax // 01E4A353
  sete al // 01E4A356
  movzx eax, al // 01E4A359
fps_loc_01E4A35C:
  lea esp, [ebp - 0xc] // 01E4A35C
  pop ebx // 01E4A35F
  pop esi // 01E4A360
  pop edi // 01E4A361
  pop ebp // 01E4A362
  ret // 01E4A363
fps_chant_voice_get_state:
  mov eax, dword ptr [fps_chant_voice_state_ptr] // 01E4A364
  test eax, eax // 01E4A369
  jne short fps_loc_01E4A38B // 01E4A36B
  push ebp // 01E4A36D
  mov ebp, esp // 01E4A36E
  push #4 // 01E4A370
  push 0x3000 // 01E4A372
  push 0xb154 // 01E4A377
  push #0 // 01E4A37C
  call dword ptr [TOS.exe+2A98A55] // 01E4A37E
  mov dword ptr [fps_chant_voice_state_ptr], eax // 01E4A384
  leave // 01E4A389
  ret // 01E4A38A
fps_loc_01E4A38B:
  ret // 01E4A38B
fps_chant_voice_ticks:
  push ebp // 01E4A38C
  mov ebp, esp // 01E4A38D
  push ebx // 01E4A38F
  mov ebx, dword ptr [ebp + 0xc] // 01E4A390
  mov eax, dword ptr [ebp + #8] // 01E4A393
  lea edx, [ebx - 0x1f40] // 01E4A396
  cmp edx, 0x5bcc0 // 01E4A39C
  ja short fps_loc_01E4A3D7 // 01E4A3A2
  test eax, eax // 01E4A3A4
  je short fps_loc_01E4A3D7 // 01E4A3A6
  xor edx, edx // 01E4A3A8
  div ebx // 01E4A3AA
  mov ecx, eax // 01E4A3AC
  mov eax, 0x7fee // 01E4A3AE
  cmp ecx, 0x221 // 01E4A3B3
  ja short fps_loc_01E4A3D9 // 01E4A3B9
  imul edx, edx, 0x3c // 01E4A3BB
  imul ecx, ecx, 0x3c // 01E4A3BE
  lea eax, [ebx + edx - #1] // 01E4A3C1
  xor edx, edx // 01E4A3C5
  div ebx // 01E4A3C7
  mov edx, 0x7fee // 01E4A3C9
  add eax, ecx // 01E4A3CE
  cmp eax, edx // 01E4A3D0
  cmova eax, edx // 01E4A3D2
  jmp short fps_loc_01E4A3D9 // 01E4A3D5
fps_loc_01E4A3D7:
  xor eax, eax // 01E4A3D7
fps_loc_01E4A3D9:
  pop ebx // 01E4A3D9
  pop ebp // 01E4A3DA
  ret // 01E4A3DB
fps_chant_voice_build:
  push ebp // 01E4A3DC
  mov ebp, esp // 01E4A3DD
  push edi // 01E4A3DF
  push esi // 01E4A3E0
  push ebx // 01E4A3E1
  sub esp, 0x44 // 01E4A3E2
  mov esi, dword ptr [ebp + #8] // 01E4A3E5
  call fps_chant_voice_get_state // 01E4A3E8
  xor edx, edx // 01E4A3ED
  mov dword ptr [ebp - 0x38], edx // 01E4A3EF
  test eax, eax // 01E4A3F2
  je near fps_loc_01E4A6D6 // 01E4A3F4
  xor edi, edi // 01E4A3FA
  inc dword ptr [eax + 0x2c] // 01E4A3FC
  mov ebx, eax // 01E4A3FF
  mov dword ptr [eax + #4], #1 // 01E4A401
  mov dword ptr [eax + 0x14], esi // 01E4A408
  mov dword ptr [eax + #8], edi // 01E4A40B
  mov dword ptr [eax + 0x1c], edi // 01E4A40E
  mov dword ptr [eax + 0x34], edi // 01E4A411
  mov dword ptr [eax + 0x38], edi // 01E4A414
  mov dword ptr [eax + 0x3c], #1 // 01E4A417
  xor eax, eax // 01E4A41E
fps_loc_01E4A420:
  db C6,84,03,40,41,00,00,00 // mov byte ptr [ebx + eax + 0x4140], #0 // 01E4A420
  inc eax // 01E4A428
  cmp eax, 0x1000 // 01E4A429
  jne short fps_loc_01E4A420 // 01E4A42E
  xor eax, eax // 01E4A430
fps_loc_01E4A432:
  mov dl, byte ptr [eax + esi + 0x1c] // 01E4A432
  db 88,54,03,40 // mov byte ptr [ebx + eax + 0x40], dl // 01E4A436
  test dl, dl // 01E4A43A
  je short fps_loc_01E4A448 // 01E4A43C
  inc eax // 01E4A43E
  cmp eax, 0x100 // 01E4A43F
  jne short fps_loc_01E4A432 // 01E4A444
  jmp short fps_loc_01E4A44C // 01E4A446
fps_loc_01E4A448:
  test eax, eax // 01E4A448
  jne short fps_loc_01E4A458 // 01E4A44A
fps_loc_01E4A44C:
  mov dword ptr [ebx + 0x3c], #2 // 01E4A44C
  jmp near fps_loc_01E4A6D6 // 01E4A453
fps_loc_01E4A458:
  lea eax, [ebx + 0x40] // 01E4A458
  push #0 // 01E4A45B
  push 0x80 // 01E4A45D
  push #3 // 01E4A462
  push #0 // 01E4A464
  push #7 // 01E4A466
  push 0x80000000 // 01E4A468
  push eax // 01E4A46D
  call dword ptr [TOS.exe+2A989ED] // 01E4A46E
  mov dword ptr [ebp - 0x3c], eax // 01E4A474
  dec eax // 01E4A477
  cmp eax, -#3 // 01E4A478
  jbe short fps_loc_01E4A489 // 01E4A47B
  mov dword ptr [ebx + 0x3c], #3 // 01E4A47D
  jmp near fps_loc_01E4A6D6 // 01E4A484
fps_loc_01E4A489:
  lea eax, [ebp - 0x38] // 01E4A489
  push eax // 01E4A48C
  push dword ptr [ebp - 0x3c] // 01E4A48D
  call dword ptr [TOS.exe+2A98A75] // 01E4A490
  mov dword ptr [ebp - 0x4c], eax // 01E4A496
  cmp dword ptr [ebp - 0x38], #0 // 01E4A499
  jne near fps_loc_01E4A6C6 // 01E4A49D
  sub eax, 0x14 // 01E4A4A3
  cmp eax, -0x16 // 01E4A4A6
  ja near fps_loc_01E4A6C6 // 01E4A4A9
  push 0x10 // 01E4A4AF
  mov eax, dword ptr [ebp - 0x3c] // 01E4A4B1
  lea ecx, [ebp - 0x34] // 01E4A4B4
  xor edx, edx // 01E4A4B7
  call fps_chant_read_at // 01E4A4B9
  pop esi // 01E4A4BE
  test eax, eax // 01E4A4BF
  je near fps_loc_01E4A6C6 // 01E4A4C1
  lea eax, [ebp - 0x34] // 01E4A4C7
  call fps_chant_le32 // 01E4A4CA
  cmp eax, 0x32534641 // 01E4A4CF
  jne near fps_loc_01E4A6C6 // 01E4A4D4
  cmp byte ptr [ebp - 0x30], #1 // 01E4A4DA
  jne near fps_loc_01E4A6C6 // 01E4A4DE
  cmp byte ptr [ebp - 0x2f], #4 // 01E4A4E4
  jne near fps_loc_01E4A6C6 // 01E4A4E8
  cmp byte ptr [ebp - 0x2e], #2 // 01E4A4EE
  jne near fps_loc_01E4A6C6 // 01E4A4F2
  cmp byte ptr [ebp - 0x2d], #0 // 01E4A4F8
  jne near fps_loc_01E4A6C6 // 01E4A4FC
  lea eax, [ebp - 0x2c] // 01E4A502
  call fps_chant_le32 // 01E4A505
  mov dword ptr [ebp - 0x40], eax // 01E4A50A
  movzx eax, word ptr [ebp - 0x28] // 01E4A50D
  mov dword ptr [ebp - 0x44], eax // 01E4A511
  mov eax, dword ptr [ebp - 0x40] // 01E4A514
  dec eax // 01E4A517
  cmp eax, 0xfff // 01E4A518
  ja near fps_loc_01E4A6C6 // 01E4A51D
  cmp dword ptr [ebp - 0x44], #0 // 01E4A523
  je near fps_loc_01E4A6C6 // 01E4A527
  mov eax, dword ptr [ebp - 0x44] // 01E4A52D
  dec eax // 01E4A530
  mov dword ptr [ebp - 0x50], eax // 01E4A531
  and eax, dword ptr [ebp - 0x44] // 01E4A534
  mov dword ptr [ebp - 0x48], eax // 01E4A537
  jne near fps_loc_01E4A6C6 // 01E4A53A
  cmp word ptr [ebp - 0x26], #0 // 01E4A540
  jne near fps_loc_01E4A6C6 // 01E4A545
  imul esi, dword ptr [ebp - 0x40], #6 // 01E4A54B
  add esi, 0x14 // 01E4A54F
  cmp dword ptr [ebp - 0x4c], esi // 01E4A552
  jb near fps_loc_01E4A6C6 // 01E4A555
  push esi // 01E4A55B
  mov eax, dword ptr [ebp - 0x3c] // 01E4A55C
  lea ecx, [ebx + 0x5140] // 01E4A55F
  xor edx, edx // 01E4A565
  call fps_chant_read_at // 01E4A567
  pop ecx // 01E4A56C
  test eax, eax // 01E4A56D
  je near fps_loc_01E4A6C6 // 01E4A56F
  mov eax, dword ptr [ebp - 0x40] // 01E4A575
  lea eax, [ebx + eax*#2 + 0x5150] // 01E4A578
  call fps_chant_le32 // 01E4A57F
  cmp eax, esi // 01E4A584
  jb near fps_loc_01E4A6C6 // 01E4A586
  mov ecx, dword ptr [ebp - 0x40] // 01E4A58C
  xor edx, edx // 01E4A58F
  db 8D,34,09 // lea esi, [ecx + ecx] // 01E4A591
  lea ecx, [ebx + esi + 0x5154] // 01E4A594
fps_loc_01E4A59B:
  mov edi, eax // 01E4A59B
  mov eax, ecx // 01E4A59D
  call fps_chant_le32 // 01E4A59F
  cmp eax, edi // 01E4A5A4
  jb near fps_loc_01E4A6C6 // 01E4A5A6
  cmp dword ptr [ebp - 0x4c], eax // 01E4A5AC
  jb near fps_loc_01E4A6C6 // 01E4A5AF
  test edx, edx // 01E4A5B5
  je short fps_loc_01E4A5CF // 01E4A5B7
  mov di, word ptr [ebx + edx*#2 + 0x5150] // 01E4A5B9
  cmp word ptr [ebx + edx*#2 + 0x514e], di // 01E4A5C1
  jae near fps_loc_01E4A6C6 // 01E4A5C9
fps_loc_01E4A5CF:
  inc edx // 01E4A5CF
  add ecx, #4 // 01E4A5D0
  cmp edx, dword ptr [ebp - 0x40] // 01E4A5D3
  jb short fps_loc_01E4A59B // 01E4A5D6
  mov eax, dword ptr [ebp - 0x44] // 01E4A5D8
  lea esi, [ebx + esi + 0x5150] // 01E4A5DB
  neg eax // 01E4A5E2
  mov dword ptr [ebp - 0x44], eax // 01E4A5E4
fps_loc_01E4A5E7:
  mov eax, esi // 01E4A5E7
  call fps_chant_le32 // 01E4A5E9
  inc dword ptr [ebp - 0x48] // 01E4A5EE
  mov edx, eax // 01E4A5F1
  cmp dword ptr [ebp - 0x44], eax // 01E4A5F3
  jb near fps_loc_01E4A6A4 // 01E4A5F6
  mov eax, dword ptr [ebp - 0x48] // 01E4A5FC
  movzx edi, word ptr [ebx + eax*#2 + 0x514e] // 01E4A5FF
  lea eax, [esi + #4] // 01E4A607
  call fps_chant_le32 // 01E4A60A
  add edx, dword ptr [ebp - 0x50] // 01E4A60F
  and edx, dword ptr [ebp - 0x44] // 01E4A612
  cmp edi, 0xfff // 01E4A615
  ja near fps_loc_01E4A6A4 // 01E4A61B
  cmp eax, edx // 01E4A621
  jb short fps_loc_01E4A6A4 // 01E4A623
  sub eax, edx // 01E4A625
  mov dword ptr [ebp - 0x4c], eax // 01E4A627
  cmp eax, 0x27 // 01E4A62A
  jbe short fps_loc_01E4A6A4 // 01E4A62D
  push 0x28 // 01E4A62F
  mov eax, dword ptr [ebp - 0x3c] // 01E4A631
  lea ecx, [ebp - 0x34] // 01E4A634
  call fps_chant_read_at // 01E4A637
  pop edx // 01E4A63C
  test eax, eax // 01E4A63D
  je short fps_loc_01E4A6A4 // 01E4A63F
  cmp byte ptr [ebp - 0x34], 0x80 // 01E4A641
  jne short fps_loc_01E4A6A4 // 01E4A645
  cmp byte ptr [ebp - 0x33], #0 // 01E4A647
  jne short fps_loc_01E4A6A4 // 01E4A64B
  mov al, byte ptr [ebp - 0x30] // 01E4A64D
  lea edx, [eax - #3] // 01E4A650
  cmp dl, #1 // 01E4A653
  jbe short fps_loc_01E4A65C // 01E4A656
  cmp al, 0x10 // 01E4A658
  jne short fps_loc_01E4A6A4 // 01E4A65A
fps_loc_01E4A65C:
  cmp byte ptr [ebp - 0x2d], #0 // 01E4A65C
  je short fps_loc_01E4A6A4 // 01E4A660
  mov ax, word ptr [ebp - 0x32] // 01E4A662
  xchg al, ah // 01E4A666
  movzx eax, ax // 01E4A668
  add eax, #4 // 01E4A66B
  cmp eax, 0x13 // 01E4A66E
  jbe short fps_loc_01E4A6A4 // 01E4A671
  cmp dword ptr [ebp - 0x4c], eax // 01E4A673
  jb short fps_loc_01E4A6A4 // 01E4A676
  mov edx, dword ptr [ebp - 0x2c] // 01E4A678
  mov eax, dword ptr [ebp - 0x28] // 01E4A67B
  bswap edx // 01E4A67E
  bswap eax // 01E4A680
  push edx // 01E4A682
  push eax // 01E4A683
  call fps_chant_voice_ticks // 01E4A684
  pop edx // 01E4A689
  pop ecx // 01E4A68A
  test eax, eax // 01E4A68B
  je short fps_loc_01E4A6A4 // 01E4A68D
  mov word ptr [ebx + edi*#2 + 0x140], ax // 01E4A68F
  mov byte ptr [ebx + edi + 0x4140], #1 // 01E4A697
  inc dword ptr [ebx + 0x34] // 01E4A69F
  jmp short fps_loc_01E4A6A7 // 01E4A6A2
fps_loc_01E4A6A4:
  inc dword ptr [ebx + 0x38] // 01E4A6A4
fps_loc_01E4A6A7:
  mov edi, dword ptr [ebp - 0x40] // 01E4A6A7
  add esi, #4 // 01E4A6AA
  cmp dword ptr [ebp - 0x48], edi // 01E4A6AD
  jb near fps_loc_01E4A5E7 // 01E4A6B0
  mov dword ptr [ebx + #8], #1 // 01E4A6B6
  mov dword ptr [ebx + 0x3c], #5 // 01E4A6BD
  jmp short fps_loc_01E4A6CD // 01E4A6C4
fps_loc_01E4A6C6:
  mov dword ptr [ebx + 0x3c], #4 // 01E4A6C6
fps_loc_01E4A6CD:
  push dword ptr [ebp - 0x3c] // 01E4A6CD
  call dword ptr [TOS.exe+2A98A99] // 01E4A6D0
fps_loc_01E4A6D6:
  lea esp, [ebp - 0xc] // 01E4A6D6
  pop ebx // 01E4A6D9
  pop esi // 01E4A6DA
  pop edi // 01E4A6DB
  pop ebp // 01E4A6DC
  ret // 01E4A6DD
fps_chant_voice_ensure:
  push ebp // 01E4A6DE
  mov ebp, esp // 01E4A6DF
  push edi // 01E4A6E1
  push esi // 01E4A6E2
  push ebx // 01E4A6E3
  sub esp, 0xc // 01E4A6E4
  call fps_chant_voice_get_state // 01E4A6E7
  test eax, eax // 01E4A6EC
  je near fps_loc_01E4A85E // 01E4A6EE
  mov ebx, eax // 01E4A6F4
  cmp dword ptr [eax], #0 // 01E4A6F6
  jne near fps_loc_01E4A85E // 01E4A6F9
  mov esi, dword ptr [TOS.exe+6D2EDC] // 01E4A6FF
  mov ecx, dword ptr [TOS.exe+4ED7EC] // 01E4A705
  test esi, esi // 01E4A70B
  je near fps_loc_01E4A85E // 01E4A70D
  test ecx, ecx // 01E4A713
  je near fps_loc_01E4A85E // 01E4A715
  cmp dword ptr [ecx], 0xd // 01E4A71B
  jbe near fps_loc_01E4A85E // 01E4A71E
  mov edx, dword ptr [ecx + 0x34] // 01E4A724
  mov eax, dword ptr [ecx + 0x38] // 01E4A727
  test edx, edx // 01E4A72A
  je near fps_loc_01E4A85E // 01E4A72C
  cmp edx, eax // 01E4A732
  jae near fps_loc_01E4A85E // 01E4A734
  sub eax, edx // 01E4A73A
  mov edi, eax // 01E4A73C
  and edi, #1 // 01E4A73E
  jne near fps_loc_01E4A85E // 01E4A741
  mov esi, dword ptr [esi + 0x9a3c] // 01E4A747
  add edx, ecx // 01E4A74D
  cmp edx, esi // 01E4A74F
  jne near fps_loc_01E4A85E // 01E4A751
  shr eax, #1 // 01E4A757
  lea edx, [eax - 0x28d] // 01E4A759
  cmp edx, 0xfff // 01E4A75F
  ja near fps_loc_01E4A85E // 01E4A765
  lea ecx, [eax - 0x28c] // 01E4A76B
  mov dword ptr [ebx], #1 // 01E4A771
  mov dword ptr [ebp - 0x14], ecx // 01E4A777
  lea ecx, [esi + 0x518] // 01E4A77A
  mov dword ptr [ebp - 0x10], ecx // 01E4A780
  cmp dword ptr [ebx + 0x18], esi // 01E4A783
  jne short fps_loc_01E4A790 // 01E4A786
  mov ecx, dword ptr [ebp - 0x14] // 01E4A788
  cmp dword ptr [ebx + 0x20], ecx // 01E4A78B
  je short fps_loc_01E4A7BF // 01E4A78E
fps_loc_01E4A790:
  add eax, eax // 01E4A790
  mov ecx, ebx // 01E4A792
  mov edx, dword ptr [ebp - 0x10] // 01E4A794
  add eax, esi // 01E4A797
  sub ecx, esi // 01E4A799
  mov dword ptr [ebp - 0x18], eax // 01E4A79B
fps_loc_01E4A79E:
  mov ax, word ptr [edx] // 01E4A79E
  mov word ptr [ecx + edx + 0x1c28], ax // 01E4A7A1
  add edx, #2 // 01E4A7A9
  cmp edx, dword ptr [ebp - 0x18] // 01E4A7AC
  jne short fps_loc_01E4A79E // 01E4A7AF
  mov eax, dword ptr [ebp - 0x14] // 01E4A7B1
  mov dword ptr [ebx + 0x18], esi // 01E4A7B4
  mov dword ptr [ebx + 0x20], eax // 01E4A7B7
  xor eax, eax // 01E4A7BA
  mov dword ptr [ebx + 0x1c], eax // 01E4A7BC
fps_loc_01E4A7BF:
  mov edx, dword ptr [TOS.exe+71C048] // 01E4A7BF
  test edx, edx // 01E4A7C5
  je near fps_loc_01E4A85A // 01E4A7C7
  cmp byte ptr [TOS.exe+71AE7C], #0 // 01E4A7CD
  je near fps_loc_01E4A85A // 01E4A7D4
  push edx // 01E4A7DA
  mov eax, TOS.exe+26D409 // 01E4A7DB
  mov dword ptr [ebp - 0x18], edx // 01E4A7E0
  call eax // 01E4A7E3
  pop ecx // 01E4A7E5
  cmp eax, #2 // 01E4A7E6
  jne short fps_loc_01E4A85A // 01E4A7E9
  cmp dword ptr [ebx + #4], #0 // 01E4A7EB
  mov edx, dword ptr [ebp - 0x18] // 01E4A7EF
  je short fps_loc_01E4A7F9 // 01E4A7F2
  cmp dword ptr [ebx + 0x14], edx // 01E4A7F4
  je short fps_loc_01E4A800 // 01E4A7F7
fps_loc_01E4A7F9:
  push edx // 01E4A7F9
  call fps_chant_voice_build // 01E4A7FA
  pop edx // 01E4A7FF
fps_loc_01E4A800:
  cmp dword ptr [ebx + 0x1c], esi // 01E4A800
  jne short fps_loc_01E4A815 // 01E4A803
  mov eax, dword ptr [ebx + 0xc] // 01E4A805
  cmp dword ptr [ebx + 0x24], eax // 01E4A808
  jne short fps_loc_01E4A815 // 01E4A80B
  mov eax, dword ptr [ebx + 0x10] // 01E4A80D
  cmp dword ptr [ebx + 0x28], eax // 01E4A810
  je short fps_loc_01E4A85A // 01E4A813
fps_loc_01E4A815:
  mov edx, dword ptr [ebx + #8] // 01E4A815
fps_loc_01E4A818:
  test edx, edx // 01E4A818
  je short fps_loc_01E4A830 // 01E4A81A
  cmp byte ptr [ebx + edi + 0x4140], #0 // 01E4A81C
  je short fps_loc_01E4A830 // 01E4A824
  mov ax, word ptr [ebx + edi*#2 + 0x140] // 01E4A826
  jmp short fps_loc_01E4A838 // 01E4A82E
fps_loc_01E4A830:
  mov ax, word ptr [ebx + edi*#2 + 0x2140] // 01E4A830
fps_loc_01E4A838:
  mov ecx, dword ptr [ebp - 0x10] // 01E4A838
  inc edi // 01E4A83B
  add dword ptr [ebp - 0x10], #2 // 01E4A83C
  mov word ptr [ecx], ax // 01E4A840
  cmp edi, dword ptr [ebp - 0x14] // 01E4A843
  jb short fps_loc_01E4A818 // 01E4A846
  mov eax, dword ptr [ebx + 0xc] // 01E4A848
  inc dword ptr [ebx + 0x30] // 01E4A84B
  mov dword ptr [ebx + 0x1c], esi // 01E4A84E
  mov dword ptr [ebx + 0x24], eax // 01E4A851
  mov eax, dword ptr [ebx + 0x10] // 01E4A854
  mov dword ptr [ebx + 0x28], eax // 01E4A857
fps_loc_01E4A85A:
  xor eax, eax // 01E4A85A
  mov dword ptr [ebx], eax // 01E4A85C
fps_loc_01E4A85E:
  lea esp, [ebp - 0xc] // 01E4A85E
  pop ebx // 01E4A861
  pop esi // 01E4A862
  pop edi // 01E4A863
  pop ebp // 01E4A864
  ret // 01E4A865
fps_chant_voice_bank_changed:
  push ebp // 01E4A866
  mov ebp, esp // 01E4A867
  cmp dword ptr [ebp + #8], 0x10 // 01E4A869
  jne short fps_loc_01E4A883 // 01E4A86D
  call fps_chant_voice_get_state // 01E4A86F
  test eax, eax // 01E4A874
  je short fps_loc_01E4A883 // 01E4A876
  xor edx, edx // 01E4A878
  inc dword ptr [eax + 0xc] // 01E4A87A
  mov dword ptr [eax + #4], edx // 01E4A87D
  mov dword ptr [eax + 0x1c], edx // 01E4A880
fps_loc_01E4A883:
  pop ebp // 01E4A883
  ret // 01E4A884
fps_chant_voice_table_loaded:
  push ebp // 01E4A885
  mov ebp, esp // 01E4A886
  call fps_chant_voice_get_state // 01E4A888
  test eax, eax // 01E4A88D
  je short fps_loc_01E4A89F // 01E4A88F
  inc dword ptr [eax + 0x10] // 01E4A891
  xor edx, edx // 01E4A894
  mov dword ptr [eax + 0x1c], edx // 01E4A896
  pop ebp // 01E4A899
  jmp near fps_chant_voice_ensure // 01E4A89A
fps_loc_01E4A89F:
  pop ebp // 01E4A89F
  ret // 01E4A8A0
fps_chant_hook_bank:
  mov dword ptr [esi*#4 + TOS.exe+71C008], eax // 01E4A8A1
  pushfd // 01E4A8A8
  pushad // 01E4A8A9
  mov ebp, esp // 01E4A8AA
  sub esp, 0x210 // 01E4A8AC
  and esp, 0xfffffff0 // 01E4A8B2
  fxsave [esp] // 01E4A8B5
  push esi // 01E4A8B9
  call fps_chant_voice_bank_changed // 01E4A8BA
  add esp, #4 // 01E4A8BF
  fxrstor [esp] // 01E4A8C2
  mov esp, ebp // 01E4A8C6
  popad // 01E4A8C8
  popfd // 01E4A8C9
  jmp near TOS.exe+182972 // 01E4A8CA
fps_chant_hook_table:
  mov dword ptr [edi + 0x9a3c], eax // 01E4A8CF
  pushfd // 01E4A8D5
  pushad // 01E4A8D6
  mov ebp, esp // 01E4A8D7
  sub esp, 0x210 // 01E4A8D9
  and esp, 0xfffffff0 // 01E4A8DF
  fxsave [esp] // 01E4A8E2
  call fps_chant_voice_table_loaded // 01E4A8E6
  fxrstor [esp] // 01E4A8EB
  mov esp, ebp // 01E4A8EF
  popad // 01E4A8F1
  popfd // 01E4A8F2
  jmp near TOS.exe+67B00 // 01E4A8F3
fps_chant_hook_selected:
  pushfd // 01E4A8F8
  pushad // 01E4A8F9
  mov ebp, esp // 01E4A8FA
  sub esp, 0x210 // 01E4A8FC
  and esp, 0xfffffff0 // 01E4A902
  fxsave [esp] // 01E4A905
  call fps_chant_voice_ensure // 01E4A909
  fxrstor [esp] // 01E4A90E
  mov esp, ebp // 01E4A912
  popad // 01E4A914
  popfd // 01E4A915
  mov esi, dword ptr [ebx + 0x13aa0] // 01E4A916
  jmp near TOS.exe+267D8 // 01E4A91C
fps_chant_hook_shared:
  pushfd // 01E4A921
  pushad // 01E4A922
  mov ebp, esp // 01E4A923
  sub esp, 0x210 // 01E4A925
  and esp, 0xfffffff0 // 01E4A92B
  fxsave [esp] // 01E4A92E
  call fps_chant_voice_ensure // 01E4A932
  fxrstor [esp] // 01E4A937
  mov esp, ebp // 01E4A93B
  popad // 01E4A93D
  popfd // 01E4A93E
  mov ecx, dword ptr [TOS.exe+6D2EDC] // 01E4A93F
  jmp near TOS.exe+632B6 // 01E4A945
fps_chant_hook_audio_reset:
  mov dword ptr [TOS.exe+71AE7C], ebx // 01E4A94A
  pushfd // 01E4A950
  pushad // 01E4A951
  mov ebp, esp // 01E4A952
  sub esp, 0x210 // 01E4A954
  and esp, 0xfffffff0 // 01E4A95A
  fxsave [esp] // 01E4A95D
  push 0x10 // 01E4A961
  call fps_chant_voice_bank_changed // 01E4A963
  add esp, #4 // 01E4A968
  fxrstor [esp] // 01E4A96B
  mov esp, ebp // 01E4A96F
  popad // 01E4A971
  popfd // 01E4A972
  jmp near TOS.exe+181682 // 01E4A973

// Added intro-only consumer of the existing pristine snapshot. No table writes.
// ECX is the resolved duration-table index, EDX the current table. Snapshot
// entries start at streaming index 652; +18 owns the table, +20 bounds the count.
// Read the pointer each time so table/cache replacement follows the existing
// lifecycle. Missing/mismatched snapshots and non-streaming entries stay native.
fps_chant_hook_intro:
  push eax
  push ebx
  mov eax, dword ptr [fps_chant_voice_state_ptr]
  test eax, eax
  jz short fps_chant_intro_native
  cmp dword ptr [eax + 0x18], edx
  jne short fps_chant_intro_native
  mov ebx, ecx
  sub ebx, #652
  jb short fps_chant_intro_native
  cmp ebx, #4096
  jae short fps_chant_intro_native
  cmp ebx, dword ptr [eax + 0x20]
  jae short fps_chant_intro_native
  movzx ecx, word ptr [eax + ebx*2 + 0x2140]
  jmp short fps_chant_intro_done
fps_chant_intro_native:
  movzx ecx, word ptr [edx + ecx*2]
fps_chant_intro_done:
  pop ebx
  pop eax
  test cl, 1
  jmp near TOS.exe+10F2

// Abyssion-only intro cap. Evidence: tos-60-experiments/abyssion-intro/manual-timeout.
// Match current voice and authored intro voice 935 during active combat.
// The existing media update caches played milliseconds per physical channel.
// Request a stop at 3300 ms only while playing and not already stopping;
// an earlier native interruption remains possible. No new mutable state.
// Preserve the CALL's entry state, then tail-jump to the original queue callee.
fps_abyssion_intro_timeout:
  pushfd
  pushad
  test eax, eax
  jz near fps_abyssion_intro_done
  cmp dword ptr [eax+0x1368], #935
  jne near fps_abyssion_intro_done
  mov edx, dword ptr [eax+4]
  test edx, edx
  jz near fps_abyssion_intro_done
  cmp word ptr [edx+0xfc], #935
  jne near fps_abyssion_intro_done
  mov edx, dword ptr [TOS.exe+6D2EDC]
  test edx, edx
  jz short fps_abyssion_intro_done
  cmp dword ptr [edx+0x8f78], #5
  jne short fps_abyssion_intro_done
  movzx ebx, word ptr [eax+0x13a9e]
  cmp ebx, #6
  ja short fps_abyssion_intro_done
  mov ecx, dword ptr [TOS.exe+6D2EC0+ebx*4]
  test ecx, ecx
  jz short fps_abyssion_intro_done
  cmp ecx, #8
  ja short fps_abyssion_intro_done
  mov edx, dword ptr [TOS.exe+71B084+ecx*4]
  test edx, edx
  jz short fps_abyssion_intro_done
  cmp word ptr [edx+0x176], #2
  jne short fps_abyssion_intro_done
  cmp byte ptr [edx+0x179], #0
  jne short fps_abyssion_intro_done
  cmp dword ptr [TOS.exe+71BF74+ecx*8], #0
  jne short fps_abyssion_intro_done
  cmp dword ptr [TOS.exe+71BF70+ecx*8], #3300
  jb short fps_abyssion_intro_done
  mov eax, ebx
  mov ebp, esp
  sub esp, 0x210
  and esp, 0xfffffff0
  fxsave [esp]
  call TOS.exe+28A10
  fxrstor [esp]
  mov esp, ebp
fps_abyssion_intro_done:
  popad
  popfd
  jmp near TOS.exe+41DD0

// Private RW state; reference 01E37D00..01E37D03.
chant_cache:
// Zero on fresh launch. Lazily VirtualAlloc 45396 bytes, retaining native timing if allocation fails; no file-backed preimage.
// Allocation bytes start at zero; no debugger state is copied.
  db 00

// ======================================================================
// Battle camera
// Combat targeting, screen shake and victory camera motion.
// ======================================================================

alloc(fps_battle_camera_code,1000)

label(fps_target_camera_constants)

// Reference VA 0042B9CF..0042B9D4.
// Use the v46 combat-camera coefficient at native constant 8833D0. Preserve this tuned value instead of
// assuming every coefficient is simply halved.
assert(TOS.exe+2B9CF,D9 05 B4 35 7A 00)
TOS.exe+2B9CF:
// Vanilla: fld dword ptr [0x7a35b4]
  fld dword ptr [TOS.exe+4833D0] // 0042B9CF

// Reference VA 0042BBEA..0042BBEF.
// Use the private 15.0 target-switch camera constant.
assert(TOS.exe+2BBEA,D9 05 54 04 73 00)
TOS.exe+2BBEA:
// Vanilla: fld dword ptr [0x730454]
  fld dword ptr [fps_target_camera_constants] // 0042BBEA

// Reference VA 0042BC01..0042BC06.
// Use the private 22.5 target-switch camera constant.
assert(TOS.exe+2BC01,D9 05 50 32 88 00)
TOS.exe+2BC01:
// Vanilla: fld dword ptr [0x883250]
  fld dword ptr [fps_target_camera_constants+4] // 0042BC01

// Reference VA 0042BD2B..0042BD36.
// Use private 0.05 and 7.5 constants for the target-switch camera interpolation expression.
assert(TOS.exe+2BD2B,DC 0D 50 2B 88 00 DC 05 88 2B 88 00)
TOS.exe+2BD2B:
// Vanilla: fmul qword ptr [0x882b50]; fadd qword ptr [0x882b88]
  fmul qword ptr [fps_target_camera_constants+8] // 0042BD2B
  fadd qword ptr [fps_target_camera_constants+10] // 0042BD31

// Reference VA 0042BF41..0042BF43.
// Run the combat camera integration loop once per update instead of twice.
assert(TOS.exe+2BF41,83 F8 02)
TOS.exe+2BF41:
// Vanilla: cmp eax, 2
  cmp eax, #1 // 0042BF41

// Reference VA 0042DF94..0042DF99.
// Subtract one unit, rather than two, from the screen-shake clock each update.
assert(TOS.exe+2DF94,DC 25 B8 29 88 00)
TOS.exe+2DF94:
// Vanilla: fsub qword ptr [0x8829b8]
  fsub qword ptr [fps_double_one] // 0042DF94

// Reference VA 0048249E..004824A7.
// Discard the duplicate victory camera radius calculation while preserving the x87 stack depth with two
// fstp operations.
assert(TOS.exe+8249E,D9 C0 DE F2 D9 C9 DE CA DE E1)
TOS.exe+8249E:
// Vanilla: fld st(0); fdivrp st(2); fxch st(1); fmulp st(2); fsubrp st(1)
  fstp st(1) // 0048249E
  fstp st(1) // 004824A0
  nop // 004824A2
  nop // 004824A3
  nop // 004824A4
  nop // 004824A5
  nop // 004824A6
  nop // 004824A7

// Reference VA 004824EC..004824F1.
// Remove the second victory-camera yaw addition so the orbit advances once per update.
assert(TOS.exe+824EC,D8 83 94 00 00 00)
TOS.exe+824EC:
// Vanilla: fadd dword ptr [ebx + 0x94]
  nop // 004824EC
  nop // 004824ED
  nop // 004824EE
  nop // 004824EF
  nop // 004824F0
  nop // 004824F1

// ----------------------------------------------------------------------
// Reference payload 02EFF26A..02EFF282; retained code/data/padding.
fps_battle_camera_code+A:
// float32 15/22.5 and float64 0.05/7.5 target-focus camera rates.
fps_target_camera_constants:
  db 00,00,70,41,00,00,B4,41,9A,99,99,99,99,99,A9,3F // 02EFF26A: constants / retained padding
  db 00,00,00,00,00,00,1E,40,00 // 02EFF27A: constants / retained padding

// ======================================================================
// Battle input
// Combat input counters, run/skid timing and rejected-arte movement fallback.
// ======================================================================

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+76237,F6 C3 03 0F 85)
assert(TOS.exe+7623A,0F 85 60 05 00)

// Reference VA 00475056..00475058.
// Increment the R1 hold-to-target timer once per update so a short press remains distinct from manual
// target selection.
assert(TOS.exe+75056,83 C0 02)
TOS.exe+75056:
// Vanilla: add eax, 2
  add eax, #1 // 00475056

// Reference VA 0047622C..00476236.
// If the requested arte was rejected and BL is zero, allow normal directional movement handling in the
// same update; preserve nonzero command handling.
assert(TOS.exe+7622C,80 7C 24 11 00 0F 85 69 05 00 00)
TOS.exe+7622C:
// Vanilla: cmp byte ptr [esp + 0x11], 0; jne 0x4767a0
  test bl, bl // 0047622C
  je short TOS.exe+76237 // 0047622E
  cmp byte ptr [esp + 0x11], #0 // 00476230
  jne short TOS.exe+7623A // 00476235

// Reference VA 0047683B..0047683D.
// Remove the second low-seven-bit increment of actor+139BD while preserving its high flag bit. The exact
// input action is not yet established.
assert(TOS.exe+7683B,8D 48 01)
TOS.exe+7683B:
// Vanilla: lea ecx, [eax + 1]
  db 8D,48,00 // lea ecx, [eax] // 0047683B

// Reference VA 004853AE..004853B7.
// Keep the first low-seven-bit run-duration increment and its high flag bit; remove only the second
// increment before the skid threshold check.
assert(TOS.exe+853AE,8D 48 01 32 C8 80 E1 7F 32 C8)
TOS.exe+853AE:
// Vanilla: lea ecx, [eax + 1]; xor cl, al; and cl, 0x7f; xor cl, al
  mov cl, al // 004853AE
  nop // 004853B0
  nop // 004853B1
  nop // 004853B2
  nop // 004853B3
  nop // 004853B4
  nop // 004853B5
  nop // 004853B6
  nop // 004853B7

// ======================================================================
// Battle entry
// Battle-entry waits, white fade and screen-shatter motion/opacity.
// ======================================================================

// Reference VA 0045B355..0045B35D.
// Configure the normal battle-entry white fade with step 16 instead of 32.
assert(TOS.exe+5B355,66 C7 87 12 94 00 00 00 20)
TOS.exe+5B355:
// Vanilla: mov word ptr [edi + 0x9412], 0x2000
  mov word ptr [edi + 0x9412], 0x1000 // 0045B355

// Reference VA 0045B6C1..0045B6CA.
// Use the GameCube normal-entry minimum counter threshold of 80 instead of 130; retain the loader-
// completion gate.
assert(TOS.exe+5B6C1,81 BE D4 90 00 00 82 00 00 00)
TOS.exe+5B6C1:
// Vanilla: cmp dword ptr [esi + 0x90d4], 0x82
  db 81,BE,D4,90,00,00,50,00,00,00 // cmp dword ptr [esi + 0x90d4], 0x50 // 0045B6C1

// Reference VA 0045B6DA..0045B6DF.
// Increment the normal-entry counter once while preserving EDX=2 for the separate render delta.
assert(TOS.exe+5B6DA,01 96 D4 90 00 00)
TOS.exe+5B6DA:
// Vanilla: add dword ptr [esi + 0x90d4], edx
  inc dword ptr [esi + 0x90d4] // 0045B6DA

// Reference VA 00461525..0046152A.
// Remove the second shard motion contribution in the first component.
assert(TOS.exe+61525,D8 80 0C FF FF FF)
TOS.exe+61525:
// Vanilla: fadd dword ptr [eax - 0xf4]
  nop // 00461525
  nop // 00461526
  nop // 00461527
  nop // 00461528
  nop // 00461529
  nop // 0046152A

// Reference VA 00461543..00461548.
// Remove the second shard motion contribution in the second component.
assert(TOS.exe+61543,D8 80 10 FF FF FF)
TOS.exe+61543:
// Vanilla: fadd dword ptr [eax - 0xf0]
  nop // 00461543
  nop // 00461544
  nop // 00461545
  nop // 00461546
  nop // 00461547
  nop // 00461548

// Reference VA 00461561..00461566.
// Remove the second shard motion contribution in the third component.
assert(TOS.exe+61561,D8 80 18 FF FF FF)
TOS.exe+61561:
// Vanilla: fadd dword ptr [eax - 0xe8]
  nop // 00461561
  nop // 00461562
  nop // 00461563
  nop // 00461564
  nop // 00461565
  nop // 00461566

// Reference VA 00461591..004615B4.
// Remove the repeated pair of shard motion/velocity updates.
assert(TOS.exe+61591,D9 80 58 FF FF FF D8 80 60 FF FF FF D9 98 58 FF FF FF D9 80 64 FF FF FF D8 80 5C FF FF FF D9 98 5C FF FF FF)
TOS.exe+61591:
// Vanilla: fld dword ptr [eax - 0xa8]; fadd dword ptr [eax - 0xa0]; fstp dword ptr [eax - 0xa8]; fld dword ptr [eax - 0x9c]; fadd dword ptr [eax - 0xa4]; fstp dword ptr [eax - 0xa4]
  nop // 00461591
  nop // 00461592
  nop // 00461593
  nop // 00461594
  nop // 00461595
  nop // 00461596
  nop // 00461597
  nop // 00461598
  nop // 00461599
  nop // 0046159A
  nop // 0046159B
  nop // 0046159C
  nop // 0046159D
  nop // 0046159E
  nop // 0046159F
  nop // 004615A0
  nop // 004615A1
  nop // 004615A2
  nop // 004615A3
  nop // 004615A4
  nop // 004615A5
  nop // 004615A6
  nop // 004615A7
  nop // 004615A8
  nop // 004615A9
  nop // 004615AA
  nop // 004615AB
  nop // 004615AC
  nop // 004615AD
  nop // 004615AE
  nop // 004615AF
  nop // 004615B0
  nop // 004615B1
  nop // 004615B2
  nop // 004615B3
  nop // 004615B4

// Reference VA 004615CD..004615D2.
// Remove the second shard rotation/motion contribution at this component.
assert(TOS.exe+615CD,D8 80 6C FF FF FF)
TOS.exe+615CD:
// Vanilla: fadd dword ptr [eax - 0x94]
  nop // 004615CD
  nop // 004615CE
  nop // 004615CF
  nop // 004615D0
  nop // 004615D1
  nop // 004615D2

// Reference VA 004615F9..004615FB.
// Advance the battle-entry shard timer once per update.
assert(TOS.exe+615F9,83 C0 02)
TOS.exe+615F9:
// Vanilla: add eax, 2
  add eax, #1 // 004615F9

// Reference VA 0046165F..00461663.
// Make the entry shard alpha reach zero at counter 120, matching the GC timing.
assert(TOS.exe+6165F,BE 82 00 00 00)
TOS.exe+6165F:
// Vanilla: mov esi, 0x82
  mov esi, 0x78 // 0046165F

// Reference VA 0046166D..0046166F.
// Begin entry shard fading at counter 57.
assert(TOS.exe+6166D,83 F9 43)
TOS.exe+6166D:
// Vanilla: cmp ecx, 0x43
  cmp ecx, 0x39 // 0046166D

// Reference VA 0046167D..00461681.
// Use alpha intercept 483 for the shard fade formula 255 - 4*(counter - 57).
assert(TOS.exe+6167D,BE 0B 02 00 00)
TOS.exe+6167D:
// Vanilla: mov esi, 0x20b
  mov esi, 0x1e3 // 0046167D

// ======================================================================
// Battle results
// Victory presentation and the existing full-overlimit preservation change.
// Preserving a full overlimit gauge on victory is existing v0.0.46 behavior, not a new timing fix.
// ======================================================================

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+7E7CA,0F B6 93 4C 93)

// Reference VA 0047E7BF..0047E7C0.
// Always skip clearing a full overlimit gauge on victory. This incidental v46 behavior is preserved; it
// is not a timer fix or the separate manual-L3 activation hook.
assert(TOS.exe+7E7BF,7C 09)
TOS.exe+7E7BF:
// Vanilla: jl 0x47e7ca
  jmp short TOS.exe+7E7CA // 0047E7BF

// Reference VA 004812E8..004812F0.
// Halve this victory presentation update step while preserving its existing destination and clamps.
assert(TOS.exe+812E8,66 83 40 FC 40 66 83 E9 40)
TOS.exe+812E8:
// Vanilla: add word ptr [eax - 4], 0x40; sub cx, 0x40
  add word ptr [eax - #4], 0x20 // 004812E8
  sub cx, 0x20 // 004812ED

// Reference VA 00481313..00481316.
// Halve this victory presentation update step while preserving its existing destination and clamps.
assert(TOS.exe+81313,66 83 02 20)
TOS.exe+81313:
// Vanilla: add word ptr [edx], 0x20
  add word ptr [edx], 0x10 // 00481313

// Reference VA 0048136E..00481371.
// Halve this victory presentation update step while preserving its existing destination and clamps.
assert(TOS.exe+8136E,66 83 00 DC)
TOS.exe+8136E:
// Vanilla: add word ptr [eax], -0x24
  db 66,83,00,EE // add word ptr [eax], -0x12 // 0048136E

// Reference VA 00481381..00481384.
// Halve this victory presentation update step while preserving its existing destination and clamps.
assert(TOS.exe+81381,66 83 01 08)
TOS.exe+81381:
// Vanilla: add word ptr [ecx], 8
  add word ptr [ecx], #4 // 00481381

// Reference VA 004813BC..004813C4.
// Halve this victory presentation update step while preserving its existing destination and clamps.
assert(TOS.exe+813BC,66 83 40 FC 64 66 83 E9 64)
TOS.exe+813BC:
// Vanilla: add word ptr [eax - 4], 0x64; sub cx, 0x64
  add word ptr [eax - #4], 0x32 // 004813BC
  sub cx, 0x32 // 004813C1

// Reference VA 004813F0..004813F3.
// Halve this victory presentation update step while preserving its existing destination and clamps.
assert(TOS.exe+813F0,66 83 02 20)
TOS.exe+813F0:
// Vanilla: add word ptr [edx], 0x20
  add word ptr [edx], 0x10 // 004813F0

// Reference VA 0048251C..0048251F.
// Advance the victory result counter once per update.
assert(TOS.exe+8251C,83 43 04 02)
TOS.exe+8251C:
// Vanilla: add dword ptr [ebx + 4], 2
  add dword ptr [ebx + #4], #1 // 0048251C

// Reference VA 00483C60..00483C67.
// Reduce this result-display fade/position decrement from 96 to 48.
assert(TOS.exe+83C60,66 83 80 9C 00 00 00 A0)
TOS.exe+83C60:
// Vanilla: add word ptr [eax + 0x9c], -0x60
  db 66,83,80,9C,00,00,00,D0 // add word ptr [eax + 0x9c], -0x30 // 00483C60

// Reference VA 00483D6D..00483D71.
// Use -48, rather than -96, for the matching result-display update step.
assert(TOS.exe+83D6D,BE A0 FF FF FF)
TOS.exe+83D6D:
// Vanilla: mov esi, 0xffffffa0
  mov esi, 0xffffffd0 // 00483D6D

[DISABLE]
// Restoration evidence only; settings take effect on a fresh launch.

// Battle cutscenes
TOS.exe+11A3:
  db 66,83,86,14,01,00,00,02
TOS.exe+1807:
  db 8D,47,02
TOS.exe+1D7C:
  db 83,06,02
TOS.exe+1E47:
  db 83,07,02
TOS.exe+2A06:
  db 8D,47,02
TOS.exe+30AE:
  db 8D,47,02
TOS.exe+3AF6:
  db 66,83,86,14,01,00,00,02
TOS.exe+4E2B:
  db 66,83,86,14,01,00,00,02
TOS.exe+570D:
  db 66,83,86,14,01,00,00,02
TOS.exe+5A50:
  db 48
TOS.exe+666A:
  db 66,83,86,14,01,00,00,02

// Battle flow
TOS.exe+5CF10:
  db 83,80,D8,90,00,00,02
TOS.exe+5D4FA:
  db 83,80,D8,90,00,00,02
TOS.exe+5D7FC:
  db 83,86,D8,90,00,00,02
TOS.exe+5D847:
  db B9,02,00,00,00
TOS.exe+5DC01:
  db 83,80,D8,90,00,00,02
TOS.exe+5DC9B:
  db 83,80,D8,90,00,00,02
TOS.exe+5DCF6:
  db 83,F9,3C
TOS.exe+5DD13:
  db 66,C7,80,12,94,00,00,01,08
TOS.exe+5DD1E:
  db 66,C7,80,12,94,00,00,01,10
TOS.exe+5DD30:
  db 83,F9,3C
TOS.exe+5DD90:
  db 83,07,02
TOS.exe+5DD9A:
  db 83,80,D8,90,00,00,02
TOS.exe+5DE64:
  db 83,86,D8,90,00,00,02
TOS.exe+5E0B8:
  db 83,86,D8,90,00,00,02
TOS.exe+5E2CA:
  db 83,83,D8,90,00,00,02
TOS.exe+5E6BF:
  db 66,83,83,D4,93,00,00,02
TOS.exe+5E6CE:
  db 83,86,D8,90,00,00,02
TOS.exe+5E75C:
  db 83,80,D8,90,00,00,02
TOS.exe+5EB6C:
  db C7,80,D4,90,00,00,2D,00,00,00
TOS.exe+5EC6E:
  db 01,9F,DC,90,00,00
TOS.exe+5ECF1:
  db 01,9F,E0,90,00,00
TOS.exe+5ED00:
  db 01,9F,E4,90,00,00
TOS.exe+5ED35:
  db 83,C0,FE
TOS.exe+5ED93:
  db 0F,B7,86,BA,90,00,00,66,85,C0,74,08,48,66,89,86,BA,90,00,00
TOS.exe+5EDB9:
  db 8A,86,E8,90,00,00,84,C0,74,08,FE,C8,88,86,E8,90,00,00
TOS.exe+5EDDD:
  db 8A,86,CD,93,00,00,84,C0,74,08,FE,C8,88,86,CD,93,00,00
TOS.exe+71294:
  db 66,83,82,0E,91,00,00,02
TOS.exe+7142A:
  db B8,02,00,00,00
TOS.exe+71C11:
  db 66,83,46,0E,02
TOS.exe+71F07:
  db 66,83,47,0E,02

// Battle actor timing
TOS.exe+2669A:
  db 66,83,83,F8,12,00,00,02
TOS.exe+27267:
  db 0F,B7,83,BE,01,00,00,66,85,C0,74,08,48,66,89,83,BE,01,00,00
TOS.exe+274C9:
  db 66,83,83,FA,12,00,00,02
TOS.exe+278E5:
  db 66,83,86,BE,01,00,00,02
TOS.exe+27F58:
  db 66,83,86,BE,01,00,00,02
TOS.exe+280E6:
  db 83,C0,02
TOS.exe+2B3B6:
  db 83,C0,02
TOS.exe+2B401:
  db E8,4A,F6,00,00,8B,CE,E8,D3,F8,00,00
TOS.exe+3A60A:
  db DC,C0
TOS.exe+3A87C:
  db DC,C0
TOS.exe+3AA39:
  db E8,12,00,00,00,8B,CE,E8,9B,02,00,00
TOS.exe+3AC6D:
  db DC,05,B8,29,88,00
TOS.exe+3CDAA:
  db 83,F8,02
TOS.exe+3E219:
  db DD,05,B8,29,88,00
TOS.exe+41716:
  db 48,66,89,83,BE,01,00,00
TOS.exe+41A6C:
  db 66,83,86,BE,01,00,00,FE
TOS.exe+44D85:
  db 66,83,87,FA,12,00,00,02
TOS.exe+467EE:
  db 66,83,86,F8,12,00,00,02
TOS.exe+75319:
  db 66,83,86,BE,01,00,00,FE
TOS.exe+84E22:
  db E8,09,42,FB,FF
TOS.exe+857F8:
  db E8,53,52,FB,FF,8B,CB,E8,5C,56,FB,FF,E8,57,57,FB,FF
TOS.exe+858B6:
  db 66,83,83,BE,01,00,00,02
TOS.exe+85B06:
  db E8,45,4F,FB,FF,8B,CB,E8,4E,53,FB,FF,E8,49,54,FB,FF,E8,F4,50,FB,FF
TOS.exe+85F75:
  db E8,D6,4A,FB,FF,8B,CE,E8,5F,4D,FB,FF
TOS.exe+86037:
  db 66,83,83,BE,01,00,00,02
TOS.exe+861B6:
  db E8,95,48,FB,FF,8B,CB,E8,9E,4C,FB,FF,F6,83,91,02,00,00,07,74,3C,8B,43,04,F6,40,5C,02,74,33,0F,B7,83,9E,02,00,00,03,C0,03,C0,99,B9,68,01,00,00,F7,F9,A1,DC,2E,AD,00,8B,88,40,9A,00,00,D9,04,91,DC,0D,50,29,88,00,D8,83,A0,38,01,00,D9,9B,A0,38,01,00,E8,04,4A,FB,FF
TOS.exe+864CA:
  db 66,83,83,BE,01,00,00,02
TOS.exe+869A2:
  db 83,C1,FE
TOS.exe+869E6:
  db E8,65,40,FB,FF,8B,CB,E8,EE,42,FB,FF
TOS.exe+86A73:
  db E8,D8,3F,FB,FF,8B,CB,E8,61,42,FB,FF
TOS.exe+86CA5:
  db 8A,83,EF,17,00,00,84,C0,74,22,FE,C8,88,83,EF,17,00,00,75,18,8B,93,50,39,01,00,8B,83,54,39,01,00,89,93,EC,38,01,00,89,83,F0,38,01,00,8A,83,EF,17,00,00,84,C0,74,22,FE,C8,88,83,EF,17,00,00,75,18,8B,8B,50,39,01,00,8B,93,54,39,01,00,89,8B,EC,38,01,00,89,93,F0,38,01,00
TOS.exe+870C8:
  db 66,83,83,BE,01,00,00,FE
TOS.exe+8726B:
  db E8,E0,37,FB,FF,8B,CE,E8,E9,3B,FB,FF,E8,64,3A,FB,FF
TOS.exe+87861:
  db 48
TOS.exe+87BC4:
  db E8,87,2E,FB,FF,8B,CB,E8,10,31,FB,FF
TOS.exe+87C07:
  db 66,83,83,BE,01,00,00,02
TOS.exe+87C6E:
  db 66,83,86,F8,12,00,00,02
TOS.exe+87D1D:
  db E8,2E,2D,FB,FF,8B,CE,E8,B7,2F,FB,FF
TOS.exe+87D35:
  db 66,83,86,BE,01,00,00,02
TOS.exe+88065:
  db 66,83,86,BE,01,00,00,FE
TOS.exe+880C8:
  db E8,83,29,FB,FF,8B,CE,E8,0C,2C,FB,FF
TOS.exe+88122:
  db 66,83,86,BE,01,00,00,FE
TOS.exe+88576:
  db E8,D5,24,FB,FF,8B,CE,E8,5E,27,FB,FF
TOS.exe+886A4:
  db E8,A7,23,FB,FF,8B,CE,E8,30,26,FB,FF
TOS.exe+8879C:
  db E8,AF,22,FB,FF,8B,CE,E8,38,25,FB,FF
TOS.exe+8884E:
  db E8,FD,21,FB,FF,8B,CE,E8,86,24,FB,FF
TOS.exe+888EF:
  db 66,83,86,BE,01,00,00,FE
TOS.exe+889D7:
  db E8,74,20,FB,FF,8B,CE,E8,FD,22,FB,FF
TOS.exe+88C05:
  db E8,46,1E,FB,FF,8B,CB,E8,4F,22,FB,FF,F6,83,91,02,00,00,07,74,3C,8B,53,04,F6,42,5C,02,74,33,0F,B7,83,9E,02,00,00,03,C0,03,C0,99,B9,68,01,00,00,F7,F9,A1,DC,2E,AD,00,8B,88,40,9A,00,00,D9,04,91,DC,0D,50,29,88,00,D8,83,A0,38,01,00,D9,9B,A0,38,01,00,E8,B5,1F,FB,FF
TOS.exe+8921A:
  db 83,C0,FE
TOS.exe+8925C:
  db E8,EF,17,FB,FF,8B,CE,E8,78,1A,FB,FF
TOS.exe+8948B:
  db 66,83,83,BE,01,00,00,FE
TOS.exe+894CD:
  db E8,7E,15,FB,FF,8B,CB,E8,07,18,FB,FF
dealloc(fps_battle_actor_timing_code)

// Battle artes
TOS.exe+D720:
  db 55,8B,EC,83,EC,28
TOS.exe+27F28:
  db 8B,46,18,33,DB,3B,C3
TOS.exe+40836:
  db 33,C0,8D,B7,70,11,00,00
TOS.exe+41009:
  db 02,97,FF,12,00,00
TOS.exe+41050:
  db C7,87,FC,12,00,00,00,00,01,00,8B,E5,5D,C3
TOS.exe+41069:
  db 0F,BE,86,FE,12,00,00
TOS.exe+412D1:
  db B8,11,00,00,00,5F,5E,8B,E5,5D,C3,66,83,86,FC,12,00,00,02,5F,B8,01,00,00,00
TOS.exe+45231:
  db 83,87,10,01,00,00,20
dealloc(fps_battle_artes_code)
dealloc(crimson_frame)

// Chant timing
TOS.exe+10EB:
  db 0F,B7,0C,4A,F6,C1,01
TOS.exe+267D2:
  db 8B,B3,A0,3A,01,00
TOS.exe+632B0:
  db 8B,0D,DC,2E,AD,00
TOS.exe+67AFA:
  db 89,87,3C,9A,00,00
TOS.exe+18167C:
  db 89,1D,7C,AE,B1,00
TOS.exe+18296B:
  db 89,04,B5,08,C0,B1,00
TOS.exe+39619:
  db E8,B2,87,00,00
dealloc(fps_chant_timing_code)
dealloc(chant_cache)

// Battle camera
TOS.exe+2B9CF:
  db D9,05,B4,35,7A,00
TOS.exe+2BBEA:
  db D9,05,54,04,73,00
TOS.exe+2BC01:
  db D9,05,50,32,88,00
TOS.exe+2BD2B:
  db DC,0D,50,2B,88,00,DC,05,88,2B,88,00
TOS.exe+2BF41:
  db 83,F8,02
TOS.exe+2DF94:
  db DC,25,B8,29,88,00
TOS.exe+8249E:
  db D9,C0,DE,F2,D9,C9,DE,CA,DE,E1
TOS.exe+824EC:
  db D8,83,94,00,00,00
dealloc(fps_battle_camera_code)

// Battle input
TOS.exe+75056:
  db 83,C0,02
TOS.exe+7622C:
  db 80,7C,24,11,00,0F,85,69,05,00,00
TOS.exe+7683B:
  db 8D,48,01
TOS.exe+853AE:
  db 8D,48,01,32,C8,80,E1,7F,32,C8

// Battle entry
TOS.exe+5B355:
  db 66,C7,87,12,94,00,00,00,20
TOS.exe+5B6C1:
  db 81,BE,D4,90,00,00,82,00,00,00
TOS.exe+5B6DA:
  db 01,96,D4,90,00,00
TOS.exe+61525:
  db D8,80,0C,FF,FF,FF
TOS.exe+61543:
  db D8,80,10,FF,FF,FF
TOS.exe+61561:
  db D8,80,18,FF,FF,FF
TOS.exe+61591:
  db D9,80,58,FF,FF,FF,D8,80,60,FF,FF,FF,D9,98,58,FF,FF,FF,D9,80,64,FF,FF,FF,D8,80,5C,FF,FF,FF,D9,98,5C,FF,FF,FF
TOS.exe+615CD:
  db D8,80,6C,FF,FF,FF
TOS.exe+615F9:
  db 83,C0,02
TOS.exe+6165F:
  db BE,82,00,00,00
TOS.exe+6166D:
  db 83,F9,43
TOS.exe+6167D:
  db BE,0B,02,00,00

// Battle results
TOS.exe+7E7BF:
  db 7C,09
TOS.exe+812E8:
  db 66,83,40,FC,40,66,83,E9,40
TOS.exe+81313:
  db 66,83,02,20
TOS.exe+8136E:
  db 66,83,00,DC
TOS.exe+81381:
  db 66,83,01,08
TOS.exe+813BC:
  db 66,83,40,FC,64,66,83,E9,64
TOS.exe+813F0:
  db 66,83,02,20
TOS.exe+8251C:
  db 83,43,04,02
TOS.exe+83C60:
  db 66,83,80,9C,00,00,00,A0
TOS.exe+83D6D:
  db BE,A0,FF,FF,FF
