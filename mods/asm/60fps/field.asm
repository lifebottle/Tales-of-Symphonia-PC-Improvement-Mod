// Field updates, scripted camera/waits, movement/collision, NPCs and character animation.
// Tales of Symphonia 60FPS v0.0.46; controlled by [60FPS] Enabled=1.
// Fresh launch required. Reference VAs identify source bytes, not runtime allocations.
// Bare ASM numbers are hexadecimal; # introduces decimal.
// Sections:
//   Field updates
//   Field movement
//   Sewer small-form walking
//   Field animation slots
//   Scripted bone rotation timing
//   Field facial animation
//   Field block movement
//   Hostile field npcs
//   Scenario camera

[ENABLE]

// ======================================================================
// Field updates
// Field/cutscene update cadence, repeated calls and scenario waits.
// ======================================================================

// Reference VA 004C50E9..004C50F1.
// Remove the second call to native update routine 0x571E20, including its argument push and cleanup, in
// the corresponding field update path.
assert(TOS.exe+C50E9,56 E8 31 CD 0A 00 83 C4 04)
TOS.exe+C50E9:
// Vanilla: push esi; call 0x571e20; add esp, 4
  nop // 004C50E9
  nop // 004C50EA
  nop // 004C50EB
  nop // 004C50EC
  nop // 004C50ED
  nop // 004C50EE
  nop // 004C50EF
  nop // 004C50F0
  nop // 004C50F1

// Reference VA 004C513A..004C5140.
// Decrement field timer byte 0xAD3E2B once rather than twice per update.
assert(TOS.exe+C513A,80 05 2B 3E AD 00 FE)
TOS.exe+C513A:
// Vanilla: add byte ptr [0xad3e2b], 0xfe
  add byte ptr [TOS.exe+6D3E2B], 0xff // 004C513A

// Reference VA 004C5170..004C5171.
// Remove this duplicate indirect update call; preserve the other native call and surrounding dispatch
// order.
assert(TOS.exe+C5170,FF D6)
TOS.exe+C5170:
// Vanilla: call esi
  nop // 004C5170
  nop // 004C5171

// Reference VA 004C52F0..004C52F1.
// Remove this duplicate indirect update call; preserve the other native call and surrounding dispatch
// order.
assert(TOS.exe+C52F0,FF D6)
TOS.exe+C52F0:
// Vanilla: call esi
  nop // 004C52F0
  nop // 004C52F1

// Reference VA 004C5397..004C5398.
// Remove this duplicate indirect update call; preserve the other native call and surrounding dispatch
// order.
assert(TOS.exe+C5397,FF D6)
TOS.exe+C5397:
// Vanilla: call esi
  nop // 004C5397
  nop // 004C5398

// Reference VA 004C5540..004C5548.
// Remove the second decrement and zero-transition block for this field countdown; retain the earlier
// native step.
assert(TOS.exe+C5540,7E 09 49 89 08 3B CB 75 02)
TOS.exe+C5540:
// Vanilla: jle 0x4c554b; dec ecx; mov dword ptr [eax], ecx; cmp ecx, ebx; jne 0x4c554b
  nop // 004C5540
  nop // 004C5541
  nop // 004C5542
  nop // 004C5543
  nop // 004C5544
  nop // 004C5545
  nop // 004C5546
  nop // 004C5547
  nop // 004C5548

// Reference VA 004C555B..004C555D.
// Advance this field counter by one rather than two per update.
assert(TOS.exe+C555B,8D 7A 02)
TOS.exe+C555B:
// Vanilla: lea edi, [edx + 2]
  lea edi, [edx + #1] // 004C555B

// Reference VA 004C558B..004C559B.
// Remove the duplicate conditional countdown step for game-state field +0x1B28; retain the first
// decrement.
assert(TOS.exe+C558B,8B 86 28 1B 00 00 85 C0 74 07 48 89 86 28 1B 00 00)
TOS.exe+C558B:
// Vanilla: mov eax, dword ptr [esi + 0x1b28]; test eax, eax; je 0x4c559c; dec eax; mov dword ptr [esi + 0x1b28], eax
  nop // 004C558B
  nop // 004C558C
  nop // 004C558D
  nop // 004C558E
  nop // 004C558F
  nop // 004C5590
  nop // 004C5591
  nop // 004C5592
  nop // 004C5593
  nop // 004C5594
  nop // 004C5595
  nop // 004C5596
  nop // 004C5597
  nop // 004C5598
  nop // 004C5599
  nop // 004C559A
  nop // 004C559B

// Reference VA 004C55C1..004C55D1.
// Remove the duplicate conditional countdown step for game-state field +0x1B30; retain the first
// decrement.
assert(TOS.exe+C55C1,8B 86 30 1B 00 00 85 C0 74 07 48 89 86 30 1B 00 00)
TOS.exe+C55C1:
// Vanilla: mov eax, dword ptr [esi + 0x1b30]; test eax, eax; je 0x4c55d2; dec eax; mov dword ptr [esi + 0x1b30], eax
  nop // 004C55C1
  nop // 004C55C2
  nop // 004C55C3
  nop // 004C55C4
  nop // 004C55C5
  nop // 004C55C6
  nop // 004C55C7
  nop // 004C55C8
  nop // 004C55C9
  nop // 004C55CA
  nop // 004C55CB
  nop // 004C55CC
  nop // 004C55CD
  nop // 004C55CE
  nop // 004C55CF
  nop // 004C55D0
  nop // 004C55D1

// Reference VA 004C584E..004C5856.
// Remove the second call to native update routine 0x571E20, including its argument push and cleanup, in
// the corresponding field update path.
assert(TOS.exe+C584E,56 E8 CC C5 0A 00 83 C4 04)
TOS.exe+C584E:
// Vanilla: push esi; call 0x571e20; add esp, 4
  nop // 004C584E
  nop // 004C584F
  nop // 004C5850
  nop // 004C5851
  nop // 004C5852
  nop // 004C5853
  nop // 004C5854
  nop // 004C5855
  nop // 004C5856

// Reference VA 004C58C1..004C58C2.
// Remove this duplicate indirect update call; preserve the other native call and surrounding dispatch
// order.
assert(TOS.exe+C58C1,FF D6)
TOS.exe+C58C1:
// Vanilla: call esi
  nop // 004C58C1
  nop // 004C58C2

// Reference VA 004C5A0C..004C5A0D.
// Remove this duplicate indirect update call; preserve the other native call and surrounding dispatch
// order.
assert(TOS.exe+C5A0C,FF D6)
TOS.exe+C5A0C:
// Vanilla: call esi
  nop // 004C5A0C
  nop // 004C5A0D

// Reference VA 0055C615..0055C61A.
// Consume one scenario-VM wait unit per update instead of two. Retain the native floating-point
// conversion and truncation behavior.
assert(TOS.exe+15C615,D8 25 18 F4 72 00)
TOS.exe+15C615:
// Vanilla: fsub dword ptr [0x72f418]
  fsub dword ptr [TOS.exe+307294] // 0055C615

// ======================================================================
// Field movement
// NPC/player facing, collision scaling, integration, waypoint arrival and scripted speed.
// Halve movement before collision, then integrate the already-scaled delta exactly once. Keep these
// hooks and the arrival clamps together.
// Historical unused NPC/terrain helpers remain as reference payload; their presence does not enable the
// superseded paths.
// ======================================================================

alloc(fps_field_movement_code,1000)

label(fps_flight_multi_arrival_store)
label(fps_flight_single_arrival_compare)
label(fps_ground_multi_arrival_compare)
label(fps_ground_multi_arrival_store)
label(fps_ground_single_arrival_compare)
label(fps_ground_single_arrival_redirect)
label(fps_legacy_npc_half_integrator)
label(fps_legacy_terrain_velocity_adjustment)
label(fps_loc_02EFF657)
label(fps_loc_02EFF74A)
label(fps_loc_02EFF76A)
label(fps_loc_02EFF822)
label(fps_loc_02EFF826)
label(fps_loc_02EFF828)
label(fps_loc_02EFFA0E)
label(fps_multi_arrival_compare_legacy)
label(fps_npc_animation_speed)
label(fps_npc_capped_arrival_store)
label(fps_npc_direct_delta_integration)
label(fps_npc_half_delta_before_collision)
label(fps_npc_pursuit_positive_speed)
label(fps_scenario_cmd17_speed)

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+C7F30,55 8B EC 83 EC)
assert(TOS.exe+C9C2C,DF E0 F6 C4 41)
assert(TOS.exe+C9D4F,0F B6 C1 40 89)
assert(TOS.exe+C9D76,74 0C DC 0D 50)
assert(TOS.exe+C9F40,0F B6 D1 42 89)
assert(TOS.exe+C9F5F,74 0C DC 0D 50)
assert(TOS.exe+C9F6F,0F BE 83 33 09)
assert(TOS.exe+CA0B1,0F B6 D1 42 89)
assert(TOS.exe+CA0D0,74 0C DC 0D 50)
assert(TOS.exe+CCF53,D9 46 28 D9 EE)
assert(TOS.exe+CD55C,E8 6F 69 0C 00)
assert(TOS.exe+CF211,8B 53 04 8B 43)
assert(TOS.exe+15F72D,80 A6 34 09 00)
assert(TOS.exe+15F7BF,83 87 44 08 00)

// Reference VA 004C89A8..004C89AD.
// Remove the native double-rate facing interpolation contribution at 60 FPS.
assert(TOS.exe+C89A8,DD 05 B8 29 88 00)
TOS.exe+C89A8:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 004C89A8

// Reference VA 004C8A18..004C8A19.
// Remove the native double-rate facing interpolation contribution at 60 FPS.
assert(TOS.exe+C8A18,D8 C9)
TOS.exe+C8A18:
// Vanilla: fmul st(1)
  nop // 004C8A18
  nop // 004C8A19

// Reference VA 004C9C26..004C9C2B.
// Flight single-destination arrival comparison: compare against twice the remaining distance.
assert(TOS.exe+C9C26,D9 44 24 24 D8 D9)
TOS.exe+C9C26:
// Vanilla: fld dword ptr [esp + 0x24]; fcomp st(1)
  jmp near fps_flight_single_arrival_compare // 004C9C26
  nop // 004C9C2B

// Reference VA 004C9D49..004C9D4E.
// Ground single-destination comparison hook: current helper replays the native substep-byte load; its
// old doubling is NOPed.
assert(TOS.exe+C9D49,8A 0D DD C3 C3 01)
TOS.exe+C9D49:
// Vanilla: mov cl, byte ptr [0x1c3c3dd]
  jmp near fps_ground_single_arrival_compare // 004C9D49
  nop // 004C9D4E

// Reference VA 004C9D70..004C9D75.
// Ground arrival store: player stores twice the remaining distance; regular NPC clamps the stored step
// to min(scaled speed, twice remaining distance).
assert(TOS.exe+C9D70,D9 54 24 24 84 C9)
TOS.exe+C9D70:
// Vanilla: fst dword ptr [esp + 0x24]; test cl, cl
  jmp near fps_ground_single_arrival_redirect // 004C9D70
  nop // 004C9D75

// Reference VA 004C9F3A..004C9F3F.
// Flight multi-destination comparison hook: current entry resumes the native comparison; historical
// helper tail remains retained.
assert(TOS.exe+C9F3A,8A 0D DD C3 C3 01)
TOS.exe+C9F3A:
// Vanilla: mov cl, byte ptr [0x1c3c3dd]
  jmp near fps_multi_arrival_compare_legacy // 004C9F3A
  nop // 004C9F3F

// Reference VA 004C9F59..004C9F5E.
// Flight multi-destination arrival store: double remaining distance only for the player, preserving
// flags for the native continuation.
assert(TOS.exe+C9F59,D9 54 24 24 84 C9)
TOS.exe+C9F59:
// Vanilla: fst dword ptr [esp + 0x24]; test cl, cl
  jmp near fps_flight_multi_arrival_store // 004C9F59
  nop // 004C9F5E

// Reference VA 004CA0AB..004CA0B0.
// Ground multi-destination comparison hook: replay the native substep-byte load; former comparison
// doubling is NOPed.
assert(TOS.exe+CA0AB,8A 0D DD C3 C3 01)
TOS.exe+CA0AB:
// Vanilla: mov cl, byte ptr [0x1c3c3dd]
  jmp near fps_ground_multi_arrival_compare // 004CA0AB
  nop // 004CA0B0

// Reference VA 004CA0CA..004CA0CF.
// Ground multi-destination arrival store: double remaining distance only for the player, preserving
// native test flags.
assert(TOS.exe+CA0CA,D9 54 24 24 84 C9)
TOS.exe+CA0CA:
// Vanilla: fst dword ptr [esp + 0x24]; test cl, cl
  jmp near fps_ground_multi_arrival_store // 004CA0CA
  nop // 004CA0CF

// Reference VA 004CA40C..004CA411.
// Use the 0.5 walk-animation speed coefficient with the corrected stored movement speed (previously
// 0.25).
assert(TOS.exe+CA40C,DC 0D A8 2A 88 00)
TOS.exe+CA40C:
// Vanilla: fmul qword ptr [0x882aa8]
  fmul qword ptr [TOS.exe+482950] // 004CA40C

// Reference VA 004CC963..004CC96C.
// Double this movement-input state duration from 15 to 30 updates. Exact user-visible action remains
// unidentified.
assert(TOS.exe+CC963,C7 86 B0 00 00 00 0F 00 00 00)
TOS.exe+CC963:
// Vanilla: mov dword ptr [esi + 0xb0], 0xf
  mov dword ptr [esi + 0xb0], 0x1e // 004CC963

// Reference VA 004CCF4D..004CCF52.
// Halve the movement magnitude stored in entity+0x938; selection below recomputes raw velocity.
assert(TOS.exe+CCF4D,D9 9E 38 09 00 00)
TOS.exe+CCF4D:
// Vanilla: fstp dword ptr [esi + 0x938]
  jmp near fps_npc_animation_speed // 004CCF4D
  nop // 004CCF52

// Reference VA 004CCFF4..004CCFF8.
// Remove the second movement-timer update call in this input branch.
assert(TOS.exe+CCFF4,E8 B7 5D FF FF)
TOS.exe+CCFF4:
// Vanilla: call 0x4c2db0
  nop // 004CCFF4
  nop // 004CCFF5
  nop // 004CCFF6
  nop // 004CCFF7
  nop // 004CCFF8

// Reference VA 004CD02E..004CD032.
// Remove the second movement-timer update call in this input branch.
assert(TOS.exe+CD02E,E8 7D 5D FF FF)
TOS.exe+CD02E:
// Vanilla: call 0x4c2db0
  nop // 004CD02E
  nop // 004CD02F
  nop // 004CD030
  nop // 004CD031
  nop // 004CD032

// Reference VA 004CEEAC..004CEEB0.
// Halve the rebuilt XYZ movement delta before native collision and terrain testing; pair with direct
// integration so displacement is not halved twice.
assert(TOS.exe+CEEAC,E8 7F 90 FF FF)
TOS.exe+CEEAC:
// Vanilla: call 0x4c7f30
  call fps_npc_half_delta_before_collision // 004CEEAC

// Reference VA 004CEEBA..004CEEBE.
// Integrate the already-halved XYZ delta once after collision; this must remain paired with the early
// delta-scaling hook.
assert(TOS.exe+CEEBA,E9 37 03 00 00)
TOS.exe+CEEBA:
// Vanilla: jmp 0x4cf1f6
  jmp near fps_npc_direct_delta_integration // 004CEEBA

// Reference VA 004CEF14..004CEF18.
// Halve the rebuilt XYZ movement delta before native collision and terrain testing; pair with direct
// integration so displacement is not halved twice.
assert(TOS.exe+CEF14,E8 17 90 FF FF)
TOS.exe+CEF14:
// Vanilla: call 0x4c7f30
  call fps_npc_half_delta_before_collision // 004CEF14

// Reference VA 004CF1F6..004CF210.
// Integrate the already-halved XYZ delta once after collision; this must remain paired with the early
// delta-scaling hook.
assert(TOS.exe+CF1F6,D9 43 28 D8 43 04 D9 5B 04 D9 43 2C D8 43 08 D9 5B 08 D9 43 30 D8 43 0C D9 5B 0C)
TOS.exe+CF1F6:
  jmp near fps_npc_direct_delta_integration // 004CF1F6
  nop // 004CF1FB
  nop // 004CF1FC
  nop // 004CF1FD
  nop // 004CF1FE
  nop // 004CF1FF
  nop // 004CF200
  nop // 004CF201
  nop // 004CF202
  nop // 004CF203
  nop // 004CF204
  nop // 004CF205
  nop // 004CF206
  nop // 004CF207
  nop // 004CF208
  nop // 004CF209
  nop // 004CF20A
  nop // 004CF20B
  db 43,0C,D9,5B,0C // Unreachable original instruction tail after unconditional jump.

// Reference VA 004CF3D5..004CF3DA.
// Apply the NPC gravity contribution once per update instead of twice.
assert(TOS.exe+CF3D5,DC 05 B8 29 88 00)
TOS.exe+CF3D5:
// Vanilla: fadd qword ptr [0x8829b8]
  fadd qword ptr [fps_double_one] // 004CF3D5

// Reference VA 0055F727..0055F72C.
// Double positive script movement speed except for hostile pursuit callback 0x4D5F00; retain the
// separate native duration path.
assert(TOS.exe+15F727,DB 44 24 14 DC C0)
TOS.exe+15F727:
// Vanilla: fild dword ptr [esp + 0x14]; fadd st(0), st(0)
  jmp near fps_npc_pursuit_positive_speed // 0055F727
  nop // 0055F72C

// Reference VA 0055F7A9..0055F7AA.
// Remove the extra script-side movement-speed doubling for this speed-setting path; retain the current
// v46 interaction with common motion scaling.
assert(TOS.exe+15F7A9,DC C0)
TOS.exe+15F7A9:
// Vanilla: fadd st(0), st(0)
  nop // 0055F7A9
  nop // 0055F7AA

// Reference VA 0055F7B9..0055F7BE.
// Replay scenario command 0x17 speed storage with the compensating doubling required by the common half-
// step motion pipeline.
assert(TOS.exe+15F7B9,D9 98 38 09 00 00)
TOS.exe+15F7B9:
// Vanilla: fstp dword ptr [eax + 0x938]
  jmp near fps_scenario_cmd17_speed // 0055F7B9
  nop // 0055F7BE

// Reference VA 00560CEF..00560CF0.
// Remove the extra script-side movement-speed doubling for this speed-setting path; retain the current
// v46 interaction with common motion scaling.
assert(TOS.exe+160CEF,DC C0)
TOS.exe+160CEF:
// Vanilla: fadd st(0), st(0)
  nop // 00560CEF
  nop // 00560CF0

// ----------------------------------------------------------------------
// Reference payload 02EFF04F..02EFF0B7; retained code/data/padding.
fps_field_movement_code+F:
// Historical half-step XYZ position integration retained in reference; current common NPC hooks use early collision scaling and direct integration.
fps_legacy_npc_half_integrator:
  fld dword ptr [ebx + 0x28] // 02EFF04F
  fmul dword ptr [fps_float_half] // 02EFF052
  fadd dword ptr [ebx + #4] // 02EFF058
  fstp dword ptr [ebx + #4] // 02EFF05B
  fld dword ptr [ebx + 0x2c] // 02EFF05E
  fmul dword ptr [fps_float_half] // 02EFF061
  fadd dword ptr [ebx + #8] // 02EFF067
  fstp dword ptr [ebx + #8] // 02EFF06A
  fld dword ptr [ebx + 0x30] // 02EFF06D
  fmul dword ptr [fps_float_half] // 02EFF070
  fadd dword ptr [ebx + 0xc] // 02EFF076
  fstp dword ptr [ebx + 0xc] // 02EFF079
  jmp near TOS.exe+CF211 // 02EFF07C
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF081: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF091: constants / retained padding

// Halve animation rate on NPC animation setup and replay displaced store.
fps_npc_animation_speed:
  fmul dword ptr [fps_float_half] // 02EFF0A0
  fstp dword ptr [esi + 0x938] // 02EFF0A6
  jmp near TOS.exe+CCF53 // 02EFF0AC
  db 00,00,00,00,00,00,00 // 02EFF0B1: constants / retained padding

// ----------------------------------------------------------------------
// Reference payload 02EFF16A..02EFF1AB; retained code/data/padding.
fps_field_movement_code+8A:
// Double supplied movement speed and replay script-store before returning.
fps_scenario_cmd17_speed:
  db DC,C0 // fadd st(0), st(0) // 02EFF16A
  fstp dword ptr [eax + 0x938] // 02EFF16C
  jmp near TOS.exe+15F7BF // 02EFF172
  db 00 // 02EFF177: constants / retained padding

// Historical doubled terrain velocity compensation; reference retains bytes after original caller was restored.
fps_legacy_terrain_velocity_adjustment:
  fld dword ptr [ebx + 0x28] // 02EFF178
  mov dword ptr [ebx + 0xa8], ecx // 02EFF17B
  fld dword ptr [TOS.exe+71333C] // 02EFF181
  fadd st(0), st(0) // 02EFF187
  faddp st(1) // 02EFF189
  mov edi, TOS.exe+713348 // 02EFF18B
  mov esi, edi // 02EFF190
  fstp dword ptr [ebx + 0x28] // 02EFF192
  fld dword ptr [ebx + 0x2c] // 02EFF195
  fld dword ptr [TOS.exe+713340] // 02EFF198
  fadd st(0), st(0) // 02EFF19E
  faddp st(1) // 02EFF1A0
  fstp dword ptr [ebx + 0x2c] // 02EFF1A2
  jmp near TOS.exe+CD55C // 02EFF1A5
  db 00,00 // 02EFF1AA: constants / retained padding

// ----------------------------------------------------------------------
// Reference payload 02EFF600..02EFF77F; retained code/data/padding.
fps_field_movement_code+D0:
// Legacy flight-single clamp doubles remaining distance before comparison.
fps_flight_single_arrival_compare:
  fadd st(0), st(0) // 02EFF600
  fld dword ptr [esp + 0x24] // 02EFF602
  fcomp st(1) // 02EFF606
  jmp near TOS.exe+C9C2C // 02EFF608
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF60D: constants / retained padding
  db 00,00,00 // 02EFF61D: constants / retained padding

// Retained hook replays native substep-byte load; former doubling has been NOPed.
fps_ground_single_arrival_compare:
  nop // 02EFF620
  nop // 02EFF621
  mov cl, byte ptr [TOS.exe+183C3DD] // 02EFF622
  jmp near TOS.exe+C9D4F // 02EFF628
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF62D: constants / retained padding
  db 00,00,00 // 02EFF63D: constants / retained padding

// Current entry directly resumes native compare; remaining historical tail is retained but unreachable from entry.
fps_multi_arrival_compare_legacy:
  mov cl, byte ptr [TOS.exe+183C3DD] // 02EFF640
  jmp near TOS.exe+C9F40 // 02EFF646
  db C4,41,75 // les eax, ptr [ecx + 0x75] // 02EFF64B
  push es // 02EFF64E
  fstp dword ptr [esp + 0x24] // 02EFF64F
  jmp short fps_loc_02EFF657 // 02EFF653
  fstp st(0) // 02EFF655
fps_loc_02EFF657:
  jmp near TOS.exe+C9F6F // 02EFF657
  add byte ptr [eax], al // 02EFF65C
  add byte ptr [eax], al // 02EFF65E

// Retained hook replays native substep-byte load; former doubling has been NOPed.
fps_ground_multi_arrival_compare:
  nop // 02EFF660
  nop // 02EFF661
  mov cl, byte ptr [TOS.exe+183C3DD] // 02EFF662
  jmp near TOS.exe+CA0B1 // 02EFF668
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF66D: constants / retained padding
  db 00,00,00 // 02EFF67D: constants / retained padding

// Halve XYZ movement delta in place before native collision/terrain tests; vector is rebuilt every update.
fps_npc_half_delta_before_collision:
  fld dword ptr [ebx + 0x28] // 02EFF680
  fmul dword ptr [fps_float_half] // 02EFF683
  fstp dword ptr [ebx + 0x28] // 02EFF689
  fld dword ptr [ebx + 0x2c] // 02EFF68C
  fmul dword ptr [fps_float_half] // 02EFF68F
  fstp dword ptr [ebx + 0x2c] // 02EFF695
  fld dword ptr [ebx + 0x30] // 02EFF698
  fmul dword ptr [fps_float_half] // 02EFF69B
  fstp dword ptr [ebx + 0x30] // 02EFF6A1
  jmp near TOS.exe+C7F30 // 02EFF6A4
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF6A9: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF6B9: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF6C9: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF6D9: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF6E9: constants / retained padding
  db 00,00,00,00,00,00,00 // 02EFF6F9: constants / retained padding

// Add already-halved XYZ delta once, with no second halve after collision.
fps_npc_direct_delta_integration:
  fld dword ptr [ebx + 0x28] // 02EFF700
  fadd dword ptr [ebx + #4] // 02EFF703
  fstp dword ptr [ebx + #4] // 02EFF706
  fld dword ptr [ebx + 0x2c] // 02EFF709
  fadd dword ptr [ebx + #8] // 02EFF70C
  fstp dword ptr [ebx + #8] // 02EFF70F
  fld dword ptr [ebx + 0x30] // 02EFF712
  fadd dword ptr [ebx + 0xc] // 02EFF715
  fstp dword ptr [ebx + 0xc] // 02EFF718
  jmp near TOS.exe+CF211 // 02EFF71B

// Redirect to capped NPC/player clamp; old trailing player-only instructions retained.
fps_ground_single_arrival_redirect:
  jmp near fps_npc_capped_arrival_store // 02EFF720
  add dword ptr [ebp + #2], esi // 02EFF725
  db DC,C0 // fadd st(0), st(0) // 02EFF728
  fst dword ptr [esp + 0x24] // 02EFF72A
  test cl, cl // 02EFF72E
  jmp near TOS.exe+C9D76 // 02EFF730
  db 00,00,00,00,00,00,00,00,00,00,00 // 02EFF735: constants / retained padding

// Double remaining-distance store for player actor only; preserve test-cl flags consumed by native continuation.
fps_flight_multi_arrival_store:
  cmp ebx, TOS.exe+1955AF0 // 02EFF740
  jne short fps_loc_02EFF74A // 02EFF746
  db DC,C0 // fadd st(0), st(0) // 02EFF748
fps_loc_02EFF74A:
  fst dword ptr [esp + 0x24] // 02EFF74A
  test cl, cl // 02EFF74E
  jmp near TOS.exe+C9F5F // 02EFF750
  db 00,00,00,00,00,00,00,00,00,00,00 // 02EFF755: constants / retained padding

// Double remaining-distance store for player actor only; preserve test-cl flags consumed by native continuation.
fps_ground_multi_arrival_store:
  cmp ebx, TOS.exe+1955AF0 // 02EFF760
  jne short fps_loc_02EFF76A // 02EFF766
  db DC,C0 // fadd st(0), st(0) // 02EFF768
fps_loc_02EFF76A:
  fst dword ptr [esp + 0x24] // 02EFF76A
  test cl, cl // 02EFF76E
  jmp near TOS.exe+CA0D0 // 02EFF770
  db 00,00,00,00,00,00,00,00,00,00,00 // 02EFF775: constants / retained padding

// ----------------------------------------------------------------------
// Reference payload 02EFF800..02EFF83F; retained code/data/padding.
fps_field_movement_code+250:
// Player stores twice remaining distance; regular NPC stores min(scaled speed, twice remaining); other actors preserve native store.
fps_npc_capped_arrival_store:
  cmp ebx, TOS.exe+1955AF0 // 02EFF800
  je short fps_loc_02EFF826 // 02EFF806
  cmp dword ptr [ebx], TOS.exe+CE730 // 02EFF808
  jne short fps_loc_02EFF828 // 02EFF80E
  fadd st(0), st(0) // 02EFF810
  fld dword ptr [esp + 0x24] // 02EFF812
  fmul dword ptr [esp + 0x28] // 02EFF816
  fcomi st(1) // 02EFF81A
  jbe short fps_loc_02EFF822 // 02EFF81C
  fstp st(0) // 02EFF81E
  jmp short fps_loc_02EFF828 // 02EFF820
fps_loc_02EFF822:
  fstp st(1) // 02EFF822
  jmp short fps_loc_02EFF828 // 02EFF824
fps_loc_02EFF826:
  fadd st(0), st(0) // 02EFF826
fps_loc_02EFF828:
  fst dword ptr [esp + 0x24] // 02EFF828
  test cl, cl // 02EFF82C
  jmp near TOS.exe+C9D76 // 02EFF82E
  db 00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF833: constants / retained padding

// ----------------------------------------------------------------------
// Reference payload 02EFFA00..02EFFA1F; retained code/data/padding.
fps_field_movement_code+290:
// Double positive script movement speed except hostile pursuit callback 4D5F00; shared duration path stays native.
fps_npc_pursuit_positive_speed:
  fild dword ptr [esp + 0x14] // 02EFFA00
  cmp dword ptr [esi], TOS.exe+D5F00 // 02EFFA04
  je short fps_loc_02EFFA0E // 02EFFA0A
  db DC,C0 // fadd st(0), st(0) // 02EFFA0C
fps_loc_02EFFA0E:
  jmp near TOS.exe+15F72D // 02EFFA0E
  db 00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFA13: constants / retained padding

// ======================================================================
// Sewer small walk
// Keep walking with Lloyd Personal enabled and halve the small-form playback rate.
// ======================================================================

alloc(fps_sewer_small_walk_code,100)
label(fps_sewer_small_walk_select)
label(fps_sewer_small_walk_normal)
label(fps_sewer_small_walk_rate)

assert(TOS.exe+CCFE4,DF E0 F6 C4 01)
assert(TOS.exe+CD029,E8 82 5D FF FF)
assert(TOS.exe+CA460,D9 5C 24 10)
assert(TOS.exe+482A44,00 00 00 41)

assert(TOS.exe+CCFDE,D8 1D 20 2B 88 00)
TOS.exe+CCFDE:
  jmp near fps_sewer_small_walk_select
  nop

// Native party, sewer-map and small-form checks guard this load.
assert(TOS.exe+CA45A,D9 05 1C 83 75 00)
TOS.exe+CA45A:
  fld dword ptr [fps_sewer_small_walk_rate]

fps_sewer_small_walk_code:
fps_sewer_small_walk_select:
  cmp byte ptr [TOS.exe+6D4682],#0
  je short fps_sewer_small_walk_normal
  push eax
  mov eax,[TOS.exe+6D3F68]
  mov eax,[eax+1180]
  sub eax,#466
  cmp eax,#7
  pop eax
  ja short fps_sewer_small_walk_normal
  fstp st(0) // Consume the displaced comparison operand before selecting walk.
  jmp near TOS.exe+CD029
fps_sewer_small_walk_normal:
  fcomp dword ptr [TOS.exe+482A44] // Preserve the existing threshold outside small sewer form.
  jmp near TOS.exe+CCFE4
  align 4
fps_sewer_small_walk_rate:
  dd (float)0.75

// ======================================================================
// Field animation slots
// Prevent reuse of animation descriptors still owned by active or pending nodes.
// ======================================================================

alloc(fps_field_animation_slots_code,1000)

label(fps_field_animation_slot_reuse_guard)
label(fps_loc_02EFFF8B)
label(fps_loc_02EFFF99)
label(fps_loc_02EFFFAC)
label(fps_loc_02EFFFB1)
label(fps_loc_02EFFFC2)

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+C8936,8D 82 4C 08 00)

// Reference VA 004C8920..004C8927.
// Reject descriptors that are busy or still referenced by active/pending animation nodes before reuse;
// retain the native exhausted-pool fallback.
assert(TOS.exe+C8920,33 C0 8D 8A 5C 08 00 00)
TOS.exe+C8920:
// Vanilla: xor eax, eax; lea ecx, [edx + 0x85c]
  jmp near fps_field_animation_slot_reuse_guard // 004C8920
  nop // 004C8925
  nop // 004C8926
  nop // 004C8927

// ----------------------------------------------------------------------
// Reference payload 02EFFF80..02EFFFFF; retained code/data/padding.
fps_field_animation_slots_code+0:
// Reject busy descriptors and descriptors referenced by active/pending nodes; preserve native exhausted-pool fallback.
fps_field_animation_slot_reuse_guard:
  push ebx // 02EFFF80
  push esi // 02EFFF81
  push edi // 02EFFF82
  xor eax, eax // 02EFFF83
  lea ecx, [edx + 0x85c] // 02EFFF85
fps_loc_02EFFF8B:
  cmp byte ptr [ecx], #0 // 02EFFF8B
  jne short fps_loc_02EFFFB1 // 02EFFF8E
  lea ebx, [ecx - 0x10] // 02EFFF90
  mov esi, dword ptr [edx + 0x808] // 02EFFF93
fps_loc_02EFFF99:
  test esi, esi // 02EFFF99
  je short fps_loc_02EFFFC2 // 02EFFF9B
  cmp dword ptr [esi], ebx // 02EFFF9D
  je short fps_loc_02EFFFB1 // 02EFFF9F
  mov edi, dword ptr [esi + 0x30] // 02EFFFA1
  test edi, edi // 02EFFFA4
  je short fps_loc_02EFFFAC // 02EFFFA6
  cmp dword ptr [edi], ebx // 02EFFFA8
  je short fps_loc_02EFFFB1 // 02EFFFAA
fps_loc_02EFFFAC:
  mov esi, dword ptr [esi + 0x2c] // 02EFFFAC
  jmp short fps_loc_02EFFF99 // 02EFFFAF
fps_loc_02EFFFB1:
  inc eax // 02EFFFB1
  add ecx, 0x4c // 02EFFFB2
  cmp eax, #3 // 02EFFFB5
  jne short fps_loc_02EFFF8B // 02EFFFB8
  pop edi // 02EFFFBA
  pop esi // 02EFFFBB
  pop ebx // 02EFFFBC
  jmp near TOS.exe+C8936 // 02EFFFBD
fps_loc_02EFFFC2:
  pop edi // 02EFFFC2
  pop esi // 02EFFFC3
  pop ebx // 02EFFFC4
  ret // 02EFFFC5
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFFC6: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFFD6: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFFFE6: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00 // 02EFFFF6: constants / retained padding

// ======================================================================
// Field facial animation
// Eye/mouth animation counters and their matching duration tables.
// The duration comparisons use timer > duration. The odd eye/mouth table thresholds belong with the one-
// step timer increments.
// ======================================================================

// Reference VA 004CDC54..004CDC5B.
// Advance eye/mouth texture timers by one instead of two; keep the corresponding odd duration thresholds
// because the comparison is timer > duration.
assert(TOS.exe+CDC54,66 83 86 C8 00 00 00 02)
TOS.exe+CDC54:
// Vanilla: add word ptr [esi + 0xc8], 2
  add word ptr [esi + 0xc8], #1 // 004CDC54

// Reference VA 004CDDBD..004CDDC4.
// Advance eye/mouth texture timers by one instead of two; keep the corresponding odd duration thresholds
// because the comparison is timer > duration.
assert(TOS.exe+CDDBD,66 83 81 CE 00 00 00 02)
TOS.exe+CDDBD:
// Vanilla: add word ptr [ecx + 0xce], 2
  add word ptr [ecx + 0xce], #1 // 004CDDBD

// Reference VA 008CEE4A..008CEE4A.
// Facial-animation duration 120 -> 121: paired with single-step timers to preserve cadence under the
// native strict-greater comparison.
assert(TOS.exe+4CEE4A,78)
TOS.exe+4CEE4A:
  db 79

// Reference VA 008CEE5A..008CEE5A.
// Facial-animation duration 8 -> 9: paired with single-step timers to preserve cadence under the native
// strict-greater comparison.
assert(TOS.exe+4CEE5A,08)
TOS.exe+4CEE5A:
  db 09

// Reference VA 008CEE5E..008CEE5E.
// Facial-animation duration 8 -> 9: paired with single-step timers to preserve cadence under the native
// strict-greater comparison.
assert(TOS.exe+4CEE5E,08)
TOS.exe+4CEE5E:
  db 09

// ======================================================================
// Field block movement
// Paired push/pull movement and completion timing.
// ======================================================================

// Reference VA 004CB310..004CB311.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB310,DC C1)
TOS.exe+CB310:
// Vanilla: fadd st(1), st(0)
  nop // 004CB310
  nop // 004CB311

// Reference VA 004CB322..004CB323.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB322,D8 C1)
TOS.exe+CB322:
// Vanilla: fadd st(1)
  nop // 004CB322
  nop // 004CB323

// Reference VA 004CB338..004CB339.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB338,DC E9)
TOS.exe+CB338:
// Vanilla: fsub st(1), st(0)
  nop // 004CB338
  nop // 004CB339

// Reference VA 004CB34A..004CB34B.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB34A,D8 E1)
TOS.exe+CB34A:
// Vanilla: fsub st(1)
  nop // 004CB34A
  nop // 004CB34B

// Reference VA 004CB35D..004CB35E.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB35D,DC E9)
TOS.exe+CB35D:
// Vanilla: fsub st(1), st(0)
  nop // 004CB35D
  nop // 004CB35E

// Reference VA 004CB36F..004CB370.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB36F,D8 E1)
TOS.exe+CB36F:
// Vanilla: fsub st(1)
  nop // 004CB36F
  nop // 004CB370

// Reference VA 004CB385..004CB386.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB385,DC C1)
TOS.exe+CB385:
// Vanilla: fadd st(1), st(0)
  nop // 004CB385
  nop // 004CB386

// Reference VA 004CB397..004CB398.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB397,D8 C1)
TOS.exe+CB397:
// Vanilla: fadd st(1)
  nop // 004CB397
  nop // 004CB398

// Reference VA 004CB3A8..004CB3AE.
// Double block push/pull completion duration from 25 to 50 updates to match the single displacement
// step.
assert(TOS.exe+CB3A8,83 BE B0 00 00 00 19)
TOS.exe+CB3A8:
// Vanilla: cmp dword ptr [esi + 0xb0], 0x19
  cmp dword ptr [esi + 0xb0], 0x32 // 004CB3A8

// Reference VA 004CB560..004CB561.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB560,DC E9)
TOS.exe+CB560:
// Vanilla: fsub st(1), st(0)
  nop // 004CB560
  nop // 004CB561

// Reference VA 004CB572..004CB573.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB572,D8 E1)
TOS.exe+CB572:
// Vanilla: fsub st(1)
  nop // 004CB572
  nop // 004CB573

// Reference VA 004CB588..004CB589.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB588,DC C1)
TOS.exe+CB588:
// Vanilla: fadd st(1), st(0)
  nop // 004CB588
  nop // 004CB589

// Reference VA 004CB59A..004CB59B.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB59A,D8 C1)
TOS.exe+CB59A:
// Vanilla: fadd st(1)
  nop // 004CB59A
  nop // 004CB59B

// Reference VA 004CB5AD..004CB5AE.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB5AD,DC C1)
TOS.exe+CB5AD:
// Vanilla: fadd st(1), st(0)
  nop // 004CB5AD
  nop // 004CB5AE

// Reference VA 004CB5BF..004CB5C0.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB5BF,D8 C1)
TOS.exe+CB5BF:
// Vanilla: fadd st(1)
  nop // 004CB5BF
  nop // 004CB5C0

// Reference VA 004CB5D5..004CB5D6.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB5D5,DC E9)
TOS.exe+CB5D5:
// Vanilla: fsub st(1), st(0)
  nop // 004CB5D5
  nop // 004CB5D6

// Reference VA 004CB5E7..004CB5E8.
// Remove the duplicate push/pull displacement contribution; keep both directions and the doubled
// completion-duration threshold together.
assert(TOS.exe+CB5E7,D8 E1)
TOS.exe+CB5E7:
// Vanilla: fsub st(1)
  nop // 004CB5E7
  nop // 004CB5E8

// Reference VA 004CB5F8..004CB5FE.
// Double block push/pull completion duration from 25 to 50 updates to match the single displacement
// step.
assert(TOS.exe+CB5F8,83 BE B0 00 00 00 19)
TOS.exe+CB5F8:
// Vanilla: cmp dword ptr [esi + 0xb0], 0x19
  cmp dword ptr [esi + 0xb0], 0x32 // 004CB5F8

// ======================================================================
// Hostile field npcs
// Enemy wandering/pursuit state timing and spawn speed initialization.
// ======================================================================

// Reference VA 004D397D..004D3982.
// Retain v0.0.46's multiplier 1.0 (vanilla 2.0) for wander/chase speeds when game-state byte +1AEB
// equals 2. The surrounding native condition remains intact.
assert(TOS.exe+D397D,DD 05 B8 29 88 00)
TOS.exe+D397D:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 004D397D

// Reference VA 004D3EAA..004D3EAC.
// Test direction-timer expiry at <=1 instead of <=2 using a temporary value; this instruction does not
// store a decremented timer. Native reset logic remains intact.
assert(TOS.exe+D3EAA,83 E8 02)
TOS.exe+D3EAA:
// Vanilla: sub eax, 2
  sub eax, #1 // 004D3EAA

// Reference VA 004D3FDD..004D3FE2.
// Retain v0.0.46's multiplier 1.0 (vanilla 2.0) for wander/chase speeds when game-state byte +1AEB
// equals 2. The surrounding native condition remains intact.
assert(TOS.exe+D3FDD,DD 05 B8 29 88 00)
TOS.exe+D3FDD:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 004D3FDD

// Reference VA 004D4423..004D4425.
// Test direction-timer expiry at <=1 instead of <=2 using a temporary value; this instruction does not
// store a decremented timer. Native reset logic remains intact.
assert(TOS.exe+D4423,83 E8 02)
TOS.exe+D4423:
// Vanilla: sub eax, 2
  sub eax, #1 // 004D4423

// Reference VA 004D45DD..004D45E2.
// Retain v0.0.46's multiplier 1.0 (vanilla 2.0) for wander/chase speeds when game-state byte +1AEB
// equals 2. The surrounding native condition remains intact.
assert(TOS.exe+D45DD,DD 05 B8 29 88 00)
TOS.exe+D45DD:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 004D45DD

// Reference VA 004D4A23..004D4A25.
// Test direction-timer expiry at <=1 instead of <=2 using a temporary value; this instruction does not
// store a decremented timer. Native reset logic remains intact.
assert(TOS.exe+D4A23,83 E8 02)
TOS.exe+D4A23:
// Vanilla: sub eax, 2
  sub eax, #1 // 004D4A23

// Reference VA 004D56CE..004D56D0.
// Test direction-timer expiry at <=1 instead of <=2 using a temporary value; this instruction does not
// store a decremented timer. Native reset logic remains intact.
assert(TOS.exe+D56CE,83 EA 02)
TOS.exe+D56CE:
// Vanilla: sub edx, 2
  sub edx, #1 // 004D56CE

// Reference VA 004D58DD..004D58E2.
// Retain v0.0.46's multiplier 1.0 (vanilla 2.0) for wander/chase speeds when game-state byte +1AEB
// equals 2. The surrounding native condition remains intact.
assert(TOS.exe+D58DD,DD 05 B8 29 88 00)
TOS.exe+D58DD:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 004D58DD

// Reference VA 004D5DB5..004D5DB7.
// Test direction-timer expiry at <=1 instead of <=2 using a temporary value; this instruction does not
// store a decremented timer. Native reset logic remains intact.
assert(TOS.exe+D5DB5,83 E8 02)
TOS.exe+D5DB5:
// Vanilla: sub eax, 2
  sub eax, #1 // 004D5DB5

// NOP double decrement of NPC respawn timer in Temple of Earth
assert(TOS.exe+D6F7E,48)
TOS.exe+D6F7E:
// Vanilla: dec eax
  nop // 004D6F7E

// Reference VA 00561CB2..00561CB7.
// Initialize hostile wander/chase speed with multiplier 1 instead of 2; this single load feeds both
// speed calculations.
assert(TOS.exe+161CB2,DD 05 B8 29 88 00)
TOS.exe+161CB2:
// Vanilla: fld qword ptr [0x8829b8]
  fld1 // 00561CB2
  nop // 00561CB4
  nop // 00561CB5
  nop // 00561CB6
  nop // 00561CB7

// Reference VA 00561E6C..00561E71.
// Use multiplier 1 instead of 2 in the script-created hostile spawn-point initialization; handler
// 0x561D10 installs HostileNPC_SpawnPoint_TickAndRender.
assert(TOS.exe+161E6C,DD 05 B8 29 88 00)
TOS.exe+161E6C:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 00561E6C

// ======================================================================
// Scenario camera
// The existing script-controlled camera timing adjustment.
// The instruction-level multiplier change is established; its full visual effect is less documented.
// Preserve it without importing rejected camera experiments.
// ======================================================================

// Reference VA 0056777A..0056777F.
// Use multiplier 1 instead of 2 in scenario-camera handler 0x567660. Preserve the accepted reference
// behavior; exact visual effect of this path is not established.
assert(TOS.exe+16777A,DD 05 B8 29 88 00)
TOS.exe+16777A:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 0056777A

// ======================================================================
// Fix statue rotation in Temple of Ice by clamping scripted bone rotation
// before converting it to native half-rate units so one-tick resets finish
// in one update. max(n,1)*0.5 preserves all durations >=2.
// ======================================================================

label(fps_c1_duration_positive)
assert(TOS.exe+16AE92,DB 84 9F 44 08 00 00 DC 0D 50 29 88 00 D9 5D D8 D9 E8 D8 55 D8 DF E0 F6 C4 41 75 05 D9 5D D8 EB 02 DD D8)
assert(TOS.exe+16AEB5,D9 45 D8 8B 45 C4)
assert(TOS.exe+482950,00 00 00 00 00 00 E0 3F)
TOS.exe+16AE92:
  mov eax,[edi+ebx*4+844]
  cmp eax,#1
  jge short fps_c1_duration_positive
  mov eax,#1
fps_c1_duration_positive:
  mov [ebp-28],eax
  fild dword ptr [ebp-28]
  fmul qword ptr [TOS.exe+482950]
  fstp dword ptr [ebp-28]
  nop
  nop
  nop

[DISABLE]
// Restoration evidence only; settings take effect on a fresh launch.

// Field updates
TOS.exe+C50E9:
  db 56,E8,31,CD,0A,00,83,C4,04
TOS.exe+C513A:
  db 80,05,2B,3E,AD,00,FE
TOS.exe+C5170:
  db FF,D6
TOS.exe+C52F0:
  db FF,D6
TOS.exe+C5397:
  db FF,D6
TOS.exe+C5540:
  db 7E,09,49,89,08,3B,CB,75,02
TOS.exe+C555B:
  db 8D,7A,02
TOS.exe+C558B:
  db 8B,86,28,1B,00,00,85,C0,74,07,48,89,86,28,1B,00,00
TOS.exe+C55C1:
  db 8B,86,30,1B,00,00,85,C0,74,07,48,89,86,30,1B,00,00
TOS.exe+C584E:
  db 56,E8,CC,C5,0A,00,83,C4,04
TOS.exe+C58C1:
  db FF,D6
TOS.exe+C5A0C:
  db FF,D6
TOS.exe+15C615:
  db D8,25,18,F4,72,00

// Field movement
TOS.exe+C89A8:
  db DD,05,B8,29,88,00
TOS.exe+C8A18:
  db D8,C9
TOS.exe+C9C26:
  db D9,44,24,24,D8,D9
TOS.exe+C9D49:
  db 8A,0D,DD,C3,C3,01
TOS.exe+C9D70:
  db D9,54,24,24,84,C9
TOS.exe+C9F3A:
  db 8A,0D,DD,C3,C3,01
TOS.exe+C9F59:
  db D9,54,24,24,84,C9
TOS.exe+CA0AB:
  db 8A,0D,DD,C3,C3,01
TOS.exe+CA0CA:
  db D9,54,24,24,84,C9
TOS.exe+CA40C:
  db DC,0D,A8,2A,88,00
TOS.exe+CC963:
  db C7,86,B0,00,00,00,0F,00,00,00
TOS.exe+CCF4D:
  db D9,9E,38,09,00,00
TOS.exe+CCFDE:
  db D8,1D,20,2B,88,00
TOS.exe+CCFF4:
  db E8,B7,5D,FF,FF
TOS.exe+CD02E:
  db E8,7D,5D,FF,FF
TOS.exe+CEEAC:
  db E8,7F,90,FF,FF
TOS.exe+CEEBA:
  db E9,37,03,00,00
TOS.exe+CEF14:
  db E8,17,90,FF,FF
TOS.exe+CF1F6:
  db D9,43,28,D8,43,04,D9,5B,04,D9,43,2C,D8,43,08,D9,5B,08,D9,43,30,D8,43,0C,D9,5B,0C
TOS.exe+CF3D5:
  db DC,05,B8,29,88,00
TOS.exe+15F727:
  db DB,44,24,14,DC,C0
TOS.exe+15F7A9:
  db DC,C0
TOS.exe+15F7B9:
  db D9,98,38,09,00,00
TOS.exe+160CEF:
  db DC,C0
dealloc(fps_field_movement_code)

// Sewer small-form walking (CCFDE restoration remains in Field movement above).
TOS.exe+CA45A:
  db D9,05,1C,83,75,00
dealloc(fps_sewer_small_walk_code)

// Field animation slots
TOS.exe+C8920:
  db 33,C0,8D,8A,5C,08,00,00
dealloc(fps_field_animation_slots_code)

// Field facial animation
TOS.exe+CDC54:
  db 66,83,86,C8,00,00,00,02
TOS.exe+CDDBD:
  db 66,83,81,CE,00,00,00,02
TOS.exe+4CEE4A:
  db 78
TOS.exe+4CEE5A:
  db 08
TOS.exe+4CEE5E:
  db 08

// Field block movement
TOS.exe+CB310:
  db DC,C1
TOS.exe+CB322:
  db D8,C1
TOS.exe+CB338:
  db DC,E9
TOS.exe+CB34A:
  db D8,E1
TOS.exe+CB35D:
  db DC,E9
TOS.exe+CB36F:
  db D8,E1
TOS.exe+CB385:
  db DC,C1
TOS.exe+CB397:
  db D8,C1
TOS.exe+CB3A8:
  db 83,BE,B0,00,00,00,19
TOS.exe+CB560:
  db DC,E9
TOS.exe+CB572:
  db D8,E1
TOS.exe+CB588:
  db DC,C1
TOS.exe+CB59A:
  db D8,C1
TOS.exe+CB5AD:
  db DC,C1
TOS.exe+CB5BF:
  db D8,C1
TOS.exe+CB5D5:
  db DC,E9
TOS.exe+CB5E7:
  db D8,E1
TOS.exe+CB5F8:
  db 83,BE,B0,00,00,00,19

// Hostile field npcs
TOS.exe+D397D:
  db DD,05,B8,29,88,00
TOS.exe+D3EAA:
  db 83,E8,02
TOS.exe+D3FDD:
  db DD,05,B8,29,88,00
TOS.exe+D4423:
  db 83,E8,02
TOS.exe+D45DD:
  db DD,05,B8,29,88,00
TOS.exe+D4A23:
  db 83,E8,02
TOS.exe+D56CE:
  db 83,EA,02
TOS.exe+D58DD:
  db DD,05,B8,29,88,00
TOS.exe+D5DB5:
  db 83,E8,02
TOS.exe+D6F7E:
  db 48
TOS.exe+161CB2:
  db DD,05,B8,29,88,00
TOS.exe+161E6C:
  db DD,05,B8,29,88,00

// Scenario camera
TOS.exe+16777A:
  db DD,05,B8,29,88,00

// Scripted bone rotation timing: restore the original duration conversion/clamp.
TOS.exe+16AE92:
  db DB 84 9F 44 08 00 00 DC 0D 50 29 88 00 D9 5D D8 D9 E8 D8 55 D8 DF E0 F6 C4 41 75 05 D9 5D D8 EB 02 DD D8
