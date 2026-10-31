// Battle particles/projectiles, HUD, chant portraits, cut-ins, flashes and rendering.
// Tales of Symphonia 60FPS v0.0.46; controlled by [60FPS] Enabled=1.
// Fresh launch required. Reference VAs identify source bytes, not runtime allocations.
// Bare ASM numbers are hexadecimal; # introduces decimal.
// Sections:
//   Battle hud
//   Battle cutins
//   Battle particles projectiles
//   Battle rendering
//   Crescent moon orientation

[ENABLE]

// ======================================================================
// Battle hud
// Combo display, target panels, HUD timers and chant portrait compositing.
// ======================================================================

alloc(fps_battle_hud_code,1000)

label(fps_chant_portrait_additive)
label(fps_loc_02EFF955)
label(fps_loc_02EFF95A)
label(fps_loc_02EFF971)
label(fps_loc_02EFF97B)
label(fps_loc_02EFF985)
label(fps_loc_02EFF995)

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+4BD52,5E 5D C3 CC CC)
assert(TOS.exe+4C1F6,8B 55 08 0F B6)
assert(TOS.exe+4D5B3,41 83 F9 03 0F)
assert(TOS.exe+5045D,83 CF FF BE F0)
assert(TOS.exe+504C6,66 39 90 26 02)
assert(TOS.exe+50527,66 39 90 42 02)
assert(TOS.exe+50588,0F B7 88 70 02)
assert(TOS.exe+505F3,0F B7 90 0C 13)
assert(TOS.exe+508A9,C3 CC CC CC CC)

// Reference VA 004385EF..004385F6.
// Advance the actor combo-hit display timer at +139EA by one per update.
assert(TOS.exe+385EF,66 83 86 EA 39 01 00 02)
TOS.exe+385EF:
// Vanilla: add word ptr [esi + 0x139ea], 2
  add word ptr [esi + 0x139ea], #1 // 004385EF

// Reference VA 004487EA..004487F1.
// Slide the target-selection panel inward by 32 in v46, versus 96 in vanilla. Older notes describing a
// step of 48 are superseded.
assert(TOS.exe+487EA,66 83 86 54 8C 00 00 A0)
TOS.exe+487EA:
// Vanilla: add word ptr [esi + 0x8c54], -0x60
  db 66,83,86,54,8C,00,00,E0 // add word ptr [esi + 0x8c54], -0x20 // 004487EA

// Reference VA 0044880B..00448812.
// Slide the target-selection panel outward by 32 in v46, versus 96 in vanilla.
assert(TOS.exe+4880B,66 83 86 54 8C 00 00 60)
TOS.exe+4880B:
// Vanilla: add word ptr [esi + 0x8c54], 0x60
  add word ptr [esi + 0x8c54], 0x20 // 0044880B

// Reference VA 0044885D..00448863.
// Advance the HUD effect timer at +85FE once per update.
assert(TOS.exe+4885D,80 87 FE 85 00 00 02)
TOS.exe+4885D:
// Vanilla: add byte ptr [edi + 0x85fe], 2
  add byte ptr [edi + 0x85fe], #1 // 0044885D

// Reference VA 00449A22..00449A26.
// Draw the chanting portrait with channels capped at 128 and an additive RGB-excess pass, then restore
// the original blend selector.
assert(TOS.exe+49A22,E8 B9 22 03 00)
TOS.exe+49A22:
// Vanilla: call 0x47bce0
  call fps_chant_portrait_additive // 00449A22

// Reference VA 0044BCF0..0044BCF7.
// Slide the battle menu inward by 10 in v46, versus 48 in vanilla. Preserve the target version tuning.
assert(TOS.exe+4BCF0,66 83 86 52 8C 00 00 D0)
TOS.exe+4BCF0:
// Vanilla: add word ptr [esi + 0x8c52], -0x30
  db 66,83,86,52,8C,00,00,F6 // add word ptr [esi + 0x8c52], -0xa // 0044BCF0

// Reference VA 0044BD05..0044BD0C.
// Slide the battle menu outward by 10 in v46, versus 48 in vanilla.
assert(TOS.exe+4BD05,66 83 86 52 8C 00 00 30)
TOS.exe+4BD05:
// Vanilla: add word ptr [esi + 0x8c52], 0x30
  add word ptr [esi + 0x8c52], 0xa // 0044BD05

// Reference VA 0044BD48..0044BD49.
// Skip the second arte-queue display timer increment unconditionally.
assert(TOS.exe+4BD48,7D 08)
TOS.exe+4BD48:
// Vanilla: jge 0x44bd52
  jmp short TOS.exe+4BD52 // 0044BD48

// Reference VA 0044C1F0..0044C1F1.
// Skip the repeated update in this HUD display timer path.
assert(TOS.exe+4C1F0,7D 04)
TOS.exe+4C1F0:
// Vanilla: jge 0x44c1f6
  jmp short TOS.exe+4C1F6 // 0044C1F0

// Reference VA 0044D533..0044D534.
// Remove the second decrement of the billboard/display fade byte.
assert(TOS.exe+4D533,FE CA)
TOS.exe+4D533:
// Vanilla: dec dl
  nop // 0044D533
  nop // 0044D534

// Reference VA 0044D54B..0044D54C.
// Remove the second increment of the billboard/display fade byte.
assert(TOS.exe+4D54B,FE C2)
TOS.exe+4D54B:
// Vanilla: inc dl
  nop // 0044D54B
  nop // 0044D54C

// Reference VA 0044D5A8..0044D5A9.
// Skip the repeated billboard/display update while preserving the existing loop continuation.
assert(TOS.exe+4D5A8,74 09)
TOS.exe+4D5A8:
// Vanilla: je 0x44d5b3
  jmp short TOS.exe+4D5B3 // 0044D5A8

// Reference VA 0044E163..0044E167.
// Advance the per-entry display timer at +A by one per update.
assert(TOS.exe+4E163,80 44 08 0A 02)
TOS.exe+4E163:
// Vanilla: add byte ptr [eax + ecx + 0xa], 2
  add byte ptr [eax + ecx + 0xa], #1 // 0044E163

// Reference VA 004503FC..00450400.
// Use one as the shared increment for status-display updates.
assert(TOS.exe+503FC,BB 02 00 00 00)
TOS.exe+503FC:
// Vanilla: mov ebx, 2
  mov ebx, #1 // 004503FC

// Reference VA 00450426..00450427.
// Skip the second decrement in this status-display block while retaining its first update and expiry
// handling.
assert(TOS.exe+50426,74 35)
TOS.exe+50426:
// Vanilla: je 0x45045d
  jmp short TOS.exe+5045D // 00450426

// Reference VA 00450491..00450492.
// Skip the second decrement in this status-display block while retaining its first update and expiry
// handling.
assert(TOS.exe+50491,74 33)
TOS.exe+50491:
// Vanilla: je 0x4504c6
  jmp short TOS.exe+504C6 // 00450491

// Reference VA 004504F2..004504F3.
// Skip the second decrement in this status-display block while retaining its first update and expiry
// handling.
assert(TOS.exe+504F2,74 33)
TOS.exe+504F2:
// Vanilla: je 0x450527
  jmp short TOS.exe+50527 // 004504F2

// Reference VA 00450553..00450554.
// Skip the second decrement in this status-display block while retaining its first update and expiry
// handling.
assert(TOS.exe+50553,74 33)
TOS.exe+50553:
// Vanilla: je 0x450588
  jmp short TOS.exe+50588 // 00450553

// Reference VA 004505BD..004505BE.
// Skip the second decrement in this status-display block while retaining its first update and expiry
// handling.
assert(TOS.exe+505BD,74 34)
TOS.exe+505BD:
// Vanilla: je 0x4505f3
  jmp short TOS.exe+505F3 // 004505BD

// Reference VA 0045089F..004508A0.
// Skip the repeated decrement in this status-display countdown path.
assert(TOS.exe+5089F,74 08)
TOS.exe+5089F:
// Vanilla: je 0x4508a9
  jmp short TOS.exe+508A9 // 0045089F

// ----------------------------------------------------------------------
// Reference payload 02EFF920..02EFF9FF; retained code/data/padding.
fps_battle_hud_code+0:
// Draw channels capped at 128, then RGB excess with native SRCALPHA/ONE; restore blend selector. Stateless final v46 helper.
fps_chant_portrait_additive:
  push ebp // 02EFF920
  mov ebp, esp // 02EFF921
  push edi // 02EFF923
  push esi // 02EFF924
  mov esi, edx // 02EFF925
  push ebx // 02EFF927
  mov ebx, ecx // 02EFF928
  sub esp, 0x3c // 02EFF92A
  cmp byte ptr [ecx + 0x2c], 0x80 // 02EFF92D
  seta al // 02EFF931
  cmp byte ptr [ecx + 0x2d], 0x80 // 02EFF934
  seta dl // 02EFF938
  or al, dl // 02EFF93B
  jne short fps_loc_02EFF955 // 02EFF93D
  cmp byte ptr [ecx + 0x2e], 0x80 // 02EFF93F
  ja short fps_loc_02EFF955 // 02EFF943
  add esp, 0x3c // 02EFF945
  mov edx, esi // 02EFF948
  mov eax, TOS.exe+7BCE0 // 02EFF94A
  pop ebx // 02EFF94F
  pop esi // 02EFF950
  pop edi // 02EFF951
  pop ebp // 02EFF952
  jmp eax // 02EFF953
fps_loc_02EFF955:
  xor eax, eax // 02EFF955
  lea ecx, [ebp - 0x48] // 02EFF957
fps_loc_02EFF95A:
  db 8A,14,03 // mov dl, byte ptr [ebx + eax] // 02EFF95A
  inc eax // 02EFF95D
  mov byte ptr [eax + ecx - #1], dl // 02EFF95E
  cmp eax, 0x3c // 02EFF962
  jne short fps_loc_02EFF95A // 02EFF965
  cmp byte ptr [ebp - 0x1c], 0x80 // 02EFF967
  jbe short fps_loc_02EFF971 // 02EFF96B
  mov byte ptr [ebp - 0x1c], 0x80 // 02EFF96D
fps_loc_02EFF971:
  cmp byte ptr [ebp - 0x1b], 0x80 // 02EFF971
  jbe short fps_loc_02EFF97B // 02EFF975
  mov byte ptr [ebp - 0x1b], 0x80 // 02EFF977
fps_loc_02EFF97B:
  cmp byte ptr [ebp - 0x1a], 0x80 // 02EFF97B
  jbe short fps_loc_02EFF985 // 02EFF97F
  mov byte ptr [ebp - 0x1a], 0x80 // 02EFF981
fps_loc_02EFF985:
  mov edx, esi // 02EFF985
  mov eax, TOS.exe+7BCE0 // 02EFF987
  xor edi, edi // 02EFF98C
  call eax // 02EFF98E
  mov edx, 0x2c // 02EFF990
fps_loc_02EFF995:
  mov al, byte ptr [ebx + edx] // 02EFF995
  lea ecx, [ebp - 0x48] // 02EFF998
  sub al, 0x80 // 02EFF99B
  cmovb eax, edi // 02EFF99D
  mov byte ptr [ebp + edx - 0x48], al // 02EFF9A0
  inc edx // 02EFF9A4
  cmp edx, 0x2f // 02EFF9A5
  jne short fps_loc_02EFF995 // 02EFF9A8
  mov ebx, dword ptr [TOS.exe+1977FC4] // 02EFF9AA
  mov edx, esi // 02EFF9B0
  mov eax, TOS.exe+7BCE0 // 02EFF9B2
  mov dword ptr [TOS.exe+1977FC4], #2 // 02EFF9B7
  call eax // 02EFF9C1
  mov dword ptr [TOS.exe+1977FC4], ebx // 02EFF9C3
  add esp, 0x3c // 02EFF9C9
  pop ebx // 02EFF9CC
  pop esi // 02EFF9CD
  pop edi // 02EFF9CE
  pop ebp // 02EFF9CF
  ret // 02EFF9D0
  nop // 02EFF9D1
  nop // 02EFF9D2
  nop // 02EFF9D3
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF9D4: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF9E4: constants / retained padding
  db 00,00,00,00,00,00,00,00,00,00,00,00 // 02EFF9F4: constants / retained padding

// ======================================================================
// Battle cutins
// Cut-in portraits, fades, unison flashes and screen zoom effects.
// ======================================================================

// Reference VA 00451156..0045115D.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+51156,66 83 81 10 8D 00 00 02)
TOS.exe+51156:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 00451156

// Reference VA 00451180..00451187.
// Reduce type-5 portrait fade-out from 25 to 13 per update, the rounded v46 half rate.
assert(TOS.exe+51180,66 83 81 12 8D 00 00 E7)
TOS.exe+51180:
// Vanilla: add word ptr [ecx + 0x8d12], -0x19
  db 66,83,81,12,8D,00,00,F3 // add word ptr [ecx + 0x8d12], -0xd // 00451180

// Reference VA 00451190..00451197.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+51190,66 83 81 10 8D 00 00 02)
TOS.exe+51190:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 00451190

// Reference VA 00451236..0045123D.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+51236,66 83 81 10 8D 00 00 02)
TOS.exe+51236:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 00451236

// Reference VA 0045127B..00451282.
// Reduce type-0 horizontal cut-in portrait fade-out from 32 to 16 per update.
assert(TOS.exe+5127B,66 83 81 12 8D 00 00 E0)
TOS.exe+5127B:
// Vanilla: add word ptr [ecx + 0x8d12], -0x20
  db 66,83,81,12,8D,00,00,F0 // add word ptr [ecx + 0x8d12], -0x10 // 0045127B

// Reference VA 0045135B..00451362.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+5135B,66 83 81 10 8D 00 00 02)
TOS.exe+5135B:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 0045135B

// Reference VA 00451383..0045138A.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+51383,66 83 81 10 8D 00 00 02)
TOS.exe+51383:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 00451383

// Reference VA 0045139E..004513A5.
// Reduce type-1 horizontal cut-in portrait fade-out from 32 to 16 per update.
assert(TOS.exe+5139E,66 83 81 12 8D 00 00 E0)
TOS.exe+5139E:
// Vanilla: add word ptr [ecx + 0x8d12], -0x20
  db 66,83,81,12,8D,00,00,F0 // add word ptr [ecx + 0x8d12], -0x10 // 0045139E

// Reference VA 0045142A..00451431.
// Reduce type-2 portrait fade-out from 32 to 16 per update.
assert(TOS.exe+5142A,66 83 81 12 8D 00 00 E0)
TOS.exe+5142A:
// Vanilla: add word ptr [ecx + 0x8d12], -0x20
  db 66,83,81,12,8D,00,00,F0 // add word ptr [ecx + 0x8d12], -0x10 // 0045142A

// Reference VA 00451508..0045150A.
// Advance this vertical cut-in phase value by one rather than two.
assert(TOS.exe+51508,83 C0 02)
TOS.exe+51508:
// Vanilla: add eax, 2
  add eax, #1 // 00451508

// Reference VA 00451510..00451517.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+51510,66 83 81 10 8D 00 00 02)
TOS.exe+51510:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 00451510

// Reference VA 0045152B..00451532.
// Pan the vertical Crimson cut-in by two rather than four per update; phase and alpha clocks remain
// separate.
assert(TOS.exe+5152B,66 83 81 0A 8D 00 00 FC)
TOS.exe+5152B:
// Vanilla: add word ptr [ecx + 0x8d0a], -4
  db 66,83,81,0A,8D,00,00,FE // add word ptr [ecx + 0x8d0a], -#2 // 0045152B

// Reference VA 0045154E..00451555.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+5154E,66 83 81 10 8D 00 00 02)
TOS.exe+5154E:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 0045154E

// Reference VA 00451567..0045156E.
// Reduce type-3/4 vertical cut-in fade-out from 16 to eight per update.
assert(TOS.exe+51567,66 83 81 12 8D 00 00 F0)
TOS.exe+51567:
// Vanilla: add word ptr [ecx + 0x8d12], -0x10
  db 66,83,81,12,8D,00,00,F8 // add word ptr [ecx + 0x8d12], -#8 // 00451567

// Reference VA 0045158C..00451593.
// Advance the cut-in phase timer at +8D10 by one per update instead of two.
assert(TOS.exe+5158C,66 83 81 10 8D 00 00 02)
TOS.exe+5158C:
// Vanilla: add word ptr [ecx + 0x8d10], 2
  add word ptr [ecx + 0x8d10], #1 // 0045158C

// Reference VA 00460C2E..00460C2F.
// Keep the full unison flash duration instead of halving the initialization argument.
assert(TOS.exe+60C2E,D1 FF)
TOS.exe+60C2E:
// Vanilla: sar edi, 1
  nop // 00460C2E
  nop // 00460C2F

// Reference VA 00460D32..00460D34.
// Use the unison-flash duration once instead of doubling it.
assert(TOS.exe+60D32,8D 0C 3F)
TOS.exe+60D32:
// Vanilla: lea ecx, [edi + edi]
  lea ecx, [edi] // 00460D32
  nop // 00460D34

// Reference VA 00460D42..00460D48.
// Take the v46 flash-update path directly rather than the original duration comparison path.
assert(TOS.exe+60D42,66 39 96 54 93 00 00)
TOS.exe+60D42:
// Vanilla: cmp word ptr [esi + 0x9354], dx
  jmp short TOS.exe+60D54 // 00460D42
  nop // 00460D44
  nop // 00460D45
  nop // 00460D46
  nop // 00460D47
  nop // 00460D48

// Reference VA 00460D54..00460D5B.
// Increase flash intensity by 16 instead of 32 per update.
assert(TOS.exe+60D54,66 83 86 56 93 00 00 20)
TOS.exe+60D54:
// Vanilla: add word ptr [esi + 0x9356], 0x20
  add word ptr [esi + 0x9356], 0x10 // 00460D54

// Reference VA 00460D81..00460D82.
// Retain the target executable encoding of the flash updater frame-pointer setup; this is a byte-parity
// edit with unchanged instruction semantics.
assert(TOS.exe+60D81,8B EC)
TOS.exe+60D81:
// Vanilla: mov ebp, esp
  mov ebp, esp // 00460D81

// Reference VA 00460D95..00460DD8.
// Update flash duration by two and intensity by eight, clamp expired values to zero, and preserve the
// upper-duration completion path and return convention.
assert(TOS.exe+60D95,BA 00 04 00 00 66 3B CA 7C 0D 8B CA 66 89 88 54 93 00 00 B0 01 5D C3 83 C1 FC 66 89 88 54 93 00 00 66 85 C9 79 1C 33 D2 66 83 80 56 93 00 00 F0 66 89 90 54 93 00 00 79 09 33 C9 66 89 88 56 93 00 00 32 C0)
TOS.exe+60D95:
  sub cx, #2 // 00460D95
  mov word ptr [eax + 0x9354], cx // 00460D99
  test cx, cx // 00460DA0
  jns short TOS.exe+60DBF // 00460DA3
  xor ecx, ecx // 00460DA5
  mov word ptr [eax + 0x9354], cx // 00460DA7
  sub word ptr [eax + 0x9356], #8 // 00460DAE
  jns short TOS.exe+60DBF // 00460DB6
  mov word ptr [eax + 0x9356], cx // 00460DB8
  cmp cx, 0x400 // 00460DBF
  jle short TOS.exe+60DD7 // 00460DC4
  mov word ptr [eax + 0x9354], 0x400 // 00460DC6
  mov al, #1 // 00460DCF
  pop ebp // 00460DD1
  ret // 00460DD2
  nop // 00460DD3
  nop // 00460DD4
  nop // 00460DD5
  nop // 00460DD6
  xor al, al // 00460DD7

// Reference VA 00461278..0046127F.
// Remove the second screen-zoom flash intensity increment.
assert(TOS.exe+61278,FE C1 88 88 28 9A 00 00)
TOS.exe+61278:
// Vanilla: inc cl; mov byte ptr [eax + 0x9a28], cl
  nop // 00461278
  nop // 00461279
  nop // 0046127A
  nop // 0046127B
  nop // 0046127C
  nop // 0046127D
  nop // 0046127E
  nop // 0046127F

// Reference VA 0046128F..00461296.
// Remove the second screen-zoom flash duration decrement.
assert(TOS.exe+6128F,49 66 89 88 24 9A 00 00)
TOS.exe+6128F:
// Vanilla: dec ecx; mov word ptr [eax + 0x9a24], cx
  nop // 0046128F
  nop // 00461290
  nop // 00461291
  nop // 00461292
  nop // 00461293
  nop // 00461294
  nop // 00461295
  nop // 00461296

// Reference VA 004612AF..004612B6.
// Remove the second screen-zoom flash intensity decrement.
assert(TOS.exe+612AF,FE C9 88 88 28 9A 00 00)
TOS.exe+612AF:
// Vanilla: dec cl; mov byte ptr [eax + 0x9a28], cl
  nop // 004612AF
  nop // 004612B0
  nop // 004612B1
  nop // 004612B2
  nop // 004612B3
  nop // 004612B4
  nop // 004612B5
  nop // 004612B6

// ======================================================================
// Battle particles projectiles
// Combat emission, particle lifetime/physics and projectile movement.
// ======================================================================

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+8D7B2,8A 53 17 84 D2)
assert(TOS.exe+8D7F2,8A 53 17 84 D2)
assert(TOS.exe+8D831,8A 53 17 84 D2)
assert(TOS.exe+8D872,8A 53 17 84 D2)

// Reference VA 00429B8F..00429B97.
// Advance this actor overlay/particle clock by one unit instead of two per update.
assert(TOS.exe+29B8F,66 83 84 73 34 E7 00 00 FE)
TOS.exe+29B8F:
// Vanilla: add word ptr [ebx + esi*2 + 0xe734], -2
  db 66,83,84,73,34,E7,00,00,FF // add word ptr [ebx + esi*#2 + 0xe734], -#1 // 00429B8F

// Reference VA 00429CA3..00429CA4.
// Advance this actor overlay/particle clock by one unit instead of two per update.
assert(TOS.exe+29CA3,04 02)
TOS.exe+29CA3:
// Vanilla: add al, 2
  add al, #1 // 00429CA3

// Reference VA 0043CEA2..0043CEA6.
// Run the primary actor particle emitter once per update. Secondary and movement emitter loop counts
// remain distinct.
assert(TOS.exe+3CEA2,BF 02 00 00 00)
TOS.exe+3CEA2:
// Vanilla: mov edi, 2
  mov edi, #1 // 0043CEA2

// Reference VA 004575EB..004575EF.
// Advance particle-emitter animation at +36 by one per update.
assert(TOS.exe+575EB,66 83 47 36 02)
TOS.exe+575EB:
// Vanilla: add word ptr [edi + 0x36], 2
  add word ptr [edi + 0x36], #1 // 004575EB

// Reference VA 00457632..00457636.
// Advance particle-emitter lifetime at +10 by one per update.
assert(TOS.exe+57632,66 83 46 10 02)
TOS.exe+57632:
// Vanilla: add word ptr [esi + 0x10], 2
  add word ptr [esi + 0x10], #1 // 00457632

// Reference VA 0048B262..0048B264.
// Advance the first VFX lifetime path by one per update.
assert(TOS.exe+8B262,83 C0 02)
TOS.exe+8B262:
// Vanilla: add eax, 2
  add eax, #1 // 0048B262

// Reference VA 0048B27B..0048B27D.
// Advance the alternate VFX lifetime path by one per update.
assert(TOS.exe+8B27B,83 C0 02)
TOS.exe+8B27B:
// Vanilla: add eax, 2
  add eax, #1 // 0048B27B

// Reference VA 0048B7D0..0048B805.
// Remove repeated VFX XYZ position and velocity integration for the +3C position vector.
assert(TOS.exe+8B7D0,D9 43 48 D8 43 3C D9 5B 3C D9 43 4C D8 43 40 D9 5B 40 D9 43 50 D8 43 44 D9 5B 44 D9 43 48 D8 43 54 D9 5B 48 D9 43 4C D8 43 58 D9 5B 4C D9 43 50 D8 43 5C D9 5B 50)
TOS.exe+8B7D0:
  nop // 0048B7D0
  nop // 0048B7D1
  nop // 0048B7D2
  nop // 0048B7D3
  nop // 0048B7D4
  nop // 0048B7D5
  nop // 0048B7D6
  nop // 0048B7D7
  nop // 0048B7D8
  nop // 0048B7D9
  nop // 0048B7DA
  nop // 0048B7DB
  nop // 0048B7DC
  nop // 0048B7DD
  nop // 0048B7DE
  nop // 0048B7DF
  nop // 0048B7E0
  nop // 0048B7E1
  nop // 0048B7E2
  nop // 0048B7E3
  nop // 0048B7E4
  nop // 0048B7E5
  nop // 0048B7E6
  nop // 0048B7E7
  nop // 0048B7E8
  nop // 0048B7E9
  nop // 0048B7EA
  nop // 0048B7EB
  nop // 0048B7EC
  nop // 0048B7ED
  nop // 0048B7EE
  nop // 0048B7EF
  nop // 0048B7F0
  nop // 0048B7F1
  nop // 0048B7F2
  nop // 0048B7F3
  nop // 0048B7F4
  nop // 0048B7F5
  nop // 0048B7F6
  nop // 0048B7F7
  nop // 0048B7F8
  nop // 0048B7F9
  nop // 0048B7FA
  nop // 0048B7FB
  nop // 0048B7FC
  nop // 0048B7FD
  nop // 0048B7FE
  nop // 0048B7FF
  nop // 0048B800
  nop // 0048B801
  nop // 0048B802
  nop // 0048B803
  nop // 0048B804
  nop // 0048B805

// Reference VA 0048B836..0048B853.
// Remove the repeated VFX acceleration-vector update.
assert(TOS.exe+8B836,D9 43 78 D8 43 54 D9 5B 54 D9 43 58 D8 43 7C D9 5B 58 D9 83 80 00 00 00 D8 43 5C D9 5B 5C)
TOS.exe+8B836:
  nop // 0048B836
  nop // 0048B837
  nop // 0048B838
  nop // 0048B839
  nop // 0048B83A
  nop // 0048B83B
  nop // 0048B83C
  nop // 0048B83D
  nop // 0048B83E
  nop // 0048B83F
  nop // 0048B840
  nop // 0048B841
  nop // 0048B842
  nop // 0048B843
  nop // 0048B844
  nop // 0048B845
  nop // 0048B846
  nop // 0048B847
  nop // 0048B848
  nop // 0048B849
  nop // 0048B84A
  nop // 0048B84B
  nop // 0048B84C
  nop // 0048B84D
  nop // 0048B84E
  nop // 0048B84F
  nop // 0048B850
  nop // 0048B851
  nop // 0048B852
  nop // 0048B853

// Reference VA 0048B8C5..0048B90C.
// Remove repeated VFX XYZ position and velocity integration for the alternate +150 position vector.
assert(TOS.exe+8B8C5,D9 43 48 D8 83 50 01 00 00 D9 9B 50 01 00 00 D9 43 4C D8 83 54 01 00 00 D9 9B 54 01 00 00 D9 43 50 D8 83 58 01 00 00 D9 9B 58 01 00 00 D9 43 48 D8 43 54 D9 5B 48 D9 43 4C D8 43 58 D9 5B 4C D9 43 50 D8 43 5C D9 5B 50)
TOS.exe+8B8C5:
  nop // 0048B8C5
  nop // 0048B8C6
  nop // 0048B8C7
  nop // 0048B8C8
  nop // 0048B8C9
  nop // 0048B8CA
  nop // 0048B8CB
  nop // 0048B8CC
  nop // 0048B8CD
  nop // 0048B8CE
  nop // 0048B8CF
  nop // 0048B8D0
  nop // 0048B8D1
  nop // 0048B8D2
  nop // 0048B8D3
  nop // 0048B8D4
  nop // 0048B8D5
  nop // 0048B8D6
  nop // 0048B8D7
  nop // 0048B8D8
  nop // 0048B8D9
  nop // 0048B8DA
  nop // 0048B8DB
  nop // 0048B8DC
  nop // 0048B8DD
  nop // 0048B8DE
  nop // 0048B8DF
  nop // 0048B8E0
  nop // 0048B8E1
  nop // 0048B8E2
  nop // 0048B8E3
  nop // 0048B8E4
  nop // 0048B8E5
  nop // 0048B8E6
  nop // 0048B8E7
  nop // 0048B8E8
  nop // 0048B8E9
  nop // 0048B8EA
  nop // 0048B8EB
  nop // 0048B8EC
  nop // 0048B8ED
  nop // 0048B8EE
  nop // 0048B8EF
  nop // 0048B8F0
  nop // 0048B8F1
  nop // 0048B8F2
  nop // 0048B8F3
  nop // 0048B8F4
  nop // 0048B8F5
  nop // 0048B8F6
  nop // 0048B8F7
  nop // 0048B8F8
  nop // 0048B8F9
  nop // 0048B8FA
  nop // 0048B8FB
  nop // 0048B8FC
  nop // 0048B8FD
  nop // 0048B8FE
  nop // 0048B8FF
  nop // 0048B900
  nop // 0048B901
  nop // 0048B902
  nop // 0048B903
  nop // 0048B904
  nop // 0048B905
  nop // 0048B906
  nop // 0048B907
  nop // 0048B908
  nop // 0048B909
  nop // 0048B90A
  nop // 0048B90B
  nop // 0048B90C

// Reference VA 0048BB44..0048BB5E.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BB44,D9 43 60 D8 43 6C D9 5B 60 D9 43 70 D8 43 64 D9 5B 64 D9 43 74 D8 43 68 D9 5B 68)
TOS.exe+8BB44:
  nop // 0048BB44
  nop // 0048BB45
  nop // 0048BB46
  nop // 0048BB47
  nop // 0048BB48
  nop // 0048BB49
  nop // 0048BB4A
  nop // 0048BB4B
  nop // 0048BB4C
  nop // 0048BB4D
  nop // 0048BB4E
  nop // 0048BB4F
  nop // 0048BB50
  nop // 0048BB51
  nop // 0048BB52
  nop // 0048BB53
  nop // 0048BB54
  nop // 0048BB55
  nop // 0048BB56
  nop // 0048BB57
  nop // 0048BB58
  nop // 0048BB59
  nop // 0048BB5A
  nop // 0048BB5B
  nop // 0048BB5C
  nop // 0048BB5D
  nop // 0048BB5E

// Reference VA 0048BBB3..0048BBE8.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BBB3,D9 83 A0 00 00 00 D8 83 AC 00 00 00 D9 9B A0 00 00 00 D9 83 A4 00 00 00 D8 83 B0 00 00 00 D9 9B A4 00 00 00 D9 83 B4 00 00 00 D8 83 A8 00 00 00 D9 9B A8 00 00 00)
TOS.exe+8BBB3:
  nop // 0048BBB3
  nop // 0048BBB4
  nop // 0048BBB5
  nop // 0048BBB6
  nop // 0048BBB7
  nop // 0048BBB8
  nop // 0048BBB9
  nop // 0048BBBA
  nop // 0048BBBB
  nop // 0048BBBC
  nop // 0048BBBD
  nop // 0048BBBE
  nop // 0048BBBF
  nop // 0048BBC0
  nop // 0048BBC1
  nop // 0048BBC2
  nop // 0048BBC3
  nop // 0048BBC4
  nop // 0048BBC5
  nop // 0048BBC6
  nop // 0048BBC7
  nop // 0048BBC8
  nop // 0048BBC9
  nop // 0048BBCA
  nop // 0048BBCB
  nop // 0048BBCC
  nop // 0048BBCD
  nop // 0048BBCE
  nop // 0048BBCF
  nop // 0048BBD0
  nop // 0048BBD1
  nop // 0048BBD2
  nop // 0048BBD3
  nop // 0048BBD4
  nop // 0048BBD5
  nop // 0048BBD6
  nop // 0048BBD7
  nop // 0048BBD8
  nop // 0048BBD9
  nop // 0048BBDA
  nop // 0048BBDB
  nop // 0048BBDC
  nop // 0048BBDD
  nop // 0048BBDE
  nop // 0048BBDF
  nop // 0048BBE0
  nop // 0048BBE1
  nop // 0048BBE2
  nop // 0048BBE3
  nop // 0048BBE4
  nop // 0048BBE5
  nop // 0048BBE6
  nop // 0048BBE7
  nop // 0048BBE8

// Reference VA 0048BC4A..0048BC7F.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BC4A,D9 83 B8 00 00 00 D8 83 E8 00 00 00 D9 9B B8 00 00 00 D9 83 EC 00 00 00 D8 83 BC 00 00 00 D9 9B BC 00 00 00 D9 83 F0 00 00 00 D8 83 C0 00 00 00 D9 9B C0 00 00 00)
TOS.exe+8BC4A:
  nop // 0048BC4A
  nop // 0048BC4B
  nop // 0048BC4C
  nop // 0048BC4D
  nop // 0048BC4E
  nop // 0048BC4F
  nop // 0048BC50
  nop // 0048BC51
  nop // 0048BC52
  nop // 0048BC53
  nop // 0048BC54
  nop // 0048BC55
  nop // 0048BC56
  nop // 0048BC57
  nop // 0048BC58
  nop // 0048BC59
  nop // 0048BC5A
  nop // 0048BC5B
  nop // 0048BC5C
  nop // 0048BC5D
  nop // 0048BC5E
  nop // 0048BC5F
  nop // 0048BC60
  nop // 0048BC61
  nop // 0048BC62
  nop // 0048BC63
  nop // 0048BC64
  nop // 0048BC65
  nop // 0048BC66
  nop // 0048BC67
  nop // 0048BC68
  nop // 0048BC69
  nop // 0048BC6A
  nop // 0048BC6B
  nop // 0048BC6C
  nop // 0048BC6D
  nop // 0048BC6E
  nop // 0048BC6F
  nop // 0048BC70
  nop // 0048BC71
  nop // 0048BC72
  nop // 0048BC73
  nop // 0048BC74
  nop // 0048BC75
  nop // 0048BC76
  nop // 0048BC77
  nop // 0048BC78
  nop // 0048BC79
  nop // 0048BC7A
  nop // 0048BC7B
  nop // 0048BC7C
  nop // 0048BC7D
  nop // 0048BC7E
  nop // 0048BC7F

// Reference VA 0048BCB6..0048BCEB.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BCB6,D9 83 C4 00 00 00 D8 83 F4 00 00 00 D9 9B C4 00 00 00 D9 83 F8 00 00 00 D8 83 C8 00 00 00 D9 9B C8 00 00 00 D9 83 FC 00 00 00 D8 83 CC 00 00 00 D9 9B CC 00 00 00)
TOS.exe+8BCB6:
  nop // 0048BCB6
  nop // 0048BCB7
  nop // 0048BCB8
  nop // 0048BCB9
  nop // 0048BCBA
  nop // 0048BCBB
  nop // 0048BCBC
  nop // 0048BCBD
  nop // 0048BCBE
  nop // 0048BCBF
  nop // 0048BCC0
  nop // 0048BCC1
  nop // 0048BCC2
  nop // 0048BCC3
  nop // 0048BCC4
  nop // 0048BCC5
  nop // 0048BCC6
  nop // 0048BCC7
  nop // 0048BCC8
  nop // 0048BCC9
  nop // 0048BCCA
  nop // 0048BCCB
  nop // 0048BCCC
  nop // 0048BCCD
  nop // 0048BCCE
  nop // 0048BCCF
  nop // 0048BCD0
  nop // 0048BCD1
  nop // 0048BCD2
  nop // 0048BCD3
  nop // 0048BCD4
  nop // 0048BCD5
  nop // 0048BCD6
  nop // 0048BCD7
  nop // 0048BCD8
  nop // 0048BCD9
  nop // 0048BCDA
  nop // 0048BCDB
  nop // 0048BCDC
  nop // 0048BCDD
  nop // 0048BCDE
  nop // 0048BCDF
  nop // 0048BCE0
  nop // 0048BCE1
  nop // 0048BCE2
  nop // 0048BCE3
  nop // 0048BCE4
  nop // 0048BCE5
  nop // 0048BCE6
  nop // 0048BCE7
  nop // 0048BCE8
  nop // 0048BCE9
  nop // 0048BCEA
  nop // 0048BCEB

// Reference VA 0048BD22..0048BD57.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BD22,D9 83 00 01 00 00 D8 83 D0 00 00 00 D9 9B D0 00 00 00 D9 83 04 01 00 00 D8 83 D4 00 00 00 D9 9B D4 00 00 00 D9 83 D8 00 00 00 D8 83 08 01 00 00 D9 9B D8 00 00 00)
TOS.exe+8BD22:
  nop // 0048BD22
  nop // 0048BD23
  nop // 0048BD24
  nop // 0048BD25
  nop // 0048BD26
  nop // 0048BD27
  nop // 0048BD28
  nop // 0048BD29
  nop // 0048BD2A
  nop // 0048BD2B
  nop // 0048BD2C
  nop // 0048BD2D
  nop // 0048BD2E
  nop // 0048BD2F
  nop // 0048BD30
  nop // 0048BD31
  nop // 0048BD32
  nop // 0048BD33
  nop // 0048BD34
  nop // 0048BD35
  nop // 0048BD36
  nop // 0048BD37
  nop // 0048BD38
  nop // 0048BD39
  nop // 0048BD3A
  nop // 0048BD3B
  nop // 0048BD3C
  nop // 0048BD3D
  nop // 0048BD3E
  nop // 0048BD3F
  nop // 0048BD40
  nop // 0048BD41
  nop // 0048BD42
  nop // 0048BD43
  nop // 0048BD44
  nop // 0048BD45
  nop // 0048BD46
  nop // 0048BD47
  nop // 0048BD48
  nop // 0048BD49
  nop // 0048BD4A
  nop // 0048BD4B
  nop // 0048BD4C
  nop // 0048BD4D
  nop // 0048BD4E
  nop // 0048BD4F
  nop // 0048BD50
  nop // 0048BD51
  nop // 0048BD52
  nop // 0048BD53
  nop // 0048BD54
  nop // 0048BD55
  nop // 0048BD56
  nop // 0048BD57

// Reference VA 0048BD8E..0048BDC3.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BD8E,D9 83 DC 00 00 00 D8 83 0C 01 00 00 D9 9B DC 00 00 00 D9 83 E0 00 00 00 D8 83 10 01 00 00 D9 9B E0 00 00 00 D9 83 E4 00 00 00 D8 83 14 01 00 00 D9 9B E4 00 00 00)
TOS.exe+8BD8E:
  nop // 0048BD8E
  nop // 0048BD8F
  nop // 0048BD90
  nop // 0048BD91
  nop // 0048BD92
  nop // 0048BD93
  nop // 0048BD94
  nop // 0048BD95
  nop // 0048BD96
  nop // 0048BD97
  nop // 0048BD98
  nop // 0048BD99
  nop // 0048BD9A
  nop // 0048BD9B
  nop // 0048BD9C
  nop // 0048BD9D
  nop // 0048BD9E
  nop // 0048BD9F
  nop // 0048BDA0
  nop // 0048BDA1
  nop // 0048BDA2
  nop // 0048BDA3
  nop // 0048BDA4
  nop // 0048BDA5
  nop // 0048BDA6
  nop // 0048BDA7
  nop // 0048BDA8
  nop // 0048BDA9
  nop // 0048BDAA
  nop // 0048BDAB
  nop // 0048BDAC
  nop // 0048BDAD
  nop // 0048BDAE
  nop // 0048BDAF
  nop // 0048BDB0
  nop // 0048BDB1
  nop // 0048BDB2
  nop // 0048BDB3
  nop // 0048BDB4
  nop // 0048BDB5
  nop // 0048BDB6
  nop // 0048BDB7
  nop // 0048BDB8
  nop // 0048BDB9
  nop // 0048BDBA
  nop // 0048BDBB
  nop // 0048BDBC
  nop // 0048BDBD
  nop // 0048BDBE
  nop // 0048BDBF
  nop // 0048BDC0
  nop // 0048BDC1
  nop // 0048BDC2
  nop // 0048BDC3

// Reference VA 0048BE5E..0048BE93.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BE5E,D9 83 C4 00 00 00 D8 83 B8 00 00 00 D9 9B B8 00 00 00 D9 83 C8 00 00 00 D8 83 BC 00 00 00 D9 9B BC 00 00 00 D9 83 C0 00 00 00 D8 83 CC 00 00 00 D9 9B C0 00 00 00)
TOS.exe+8BE5E:
  nop // 0048BE5E
  nop // 0048BE5F
  nop // 0048BE60
  nop // 0048BE61
  nop // 0048BE62
  nop // 0048BE63
  nop // 0048BE64
  nop // 0048BE65
  nop // 0048BE66
  nop // 0048BE67
  nop // 0048BE68
  nop // 0048BE69
  nop // 0048BE6A
  nop // 0048BE6B
  nop // 0048BE6C
  nop // 0048BE6D
  nop // 0048BE6E
  nop // 0048BE6F
  nop // 0048BE70
  nop // 0048BE71
  nop // 0048BE72
  nop // 0048BE73
  nop // 0048BE74
  nop // 0048BE75
  nop // 0048BE76
  nop // 0048BE77
  nop // 0048BE78
  nop // 0048BE79
  nop // 0048BE7A
  nop // 0048BE7B
  nop // 0048BE7C
  nop // 0048BE7D
  nop // 0048BE7E
  nop // 0048BE7F
  nop // 0048BE80
  nop // 0048BE81
  nop // 0048BE82
  nop // 0048BE83
  nop // 0048BE84
  nop // 0048BE85
  nop // 0048BE86
  nop // 0048BE87
  nop // 0048BE88
  nop // 0048BE89
  nop // 0048BE8A
  nop // 0048BE8B
  nop // 0048BE8C
  nop // 0048BE8D
  nop // 0048BE8E
  nop // 0048BE8F
  nop // 0048BE90
  nop // 0048BE91
  nop // 0048BE92
  nop // 0048BE93

// Reference VA 0048BEB1..0048BEE6.
// Remove the repeated VFX vector-component accumulation at this stage of the physics update.
assert(TOS.exe+8BEB1,D9 83 C4 00 00 00 D8 83 D0 00 00 00 D9 9B C4 00 00 00 D9 83 D4 00 00 00 D8 83 C8 00 00 00 D9 9B C8 00 00 00 D9 83 D8 00 00 00 D8 83 CC 00 00 00 D9 9B CC 00 00 00)
TOS.exe+8BEB1:
  nop // 0048BEB1
  nop // 0048BEB2
  nop // 0048BEB3
  nop // 0048BEB4
  nop // 0048BEB5
  nop // 0048BEB6
  nop // 0048BEB7
  nop // 0048BEB8
  nop // 0048BEB9
  nop // 0048BEBA
  nop // 0048BEBB
  nop // 0048BEBC
  nop // 0048BEBD
  nop // 0048BEBE
  nop // 0048BEBF
  nop // 0048BEC0
  nop // 0048BEC1
  nop // 0048BEC2
  nop // 0048BEC3
  nop // 0048BEC4
  nop // 0048BEC5
  nop // 0048BEC6
  nop // 0048BEC7
  nop // 0048BEC8
  nop // 0048BEC9
  nop // 0048BECA
  nop // 0048BECB
  nop // 0048BECC
  nop // 0048BECD
  nop // 0048BECE
  nop // 0048BECF
  nop // 0048BED0
  nop // 0048BED1
  nop // 0048BED2
  nop // 0048BED3
  nop // 0048BED4
  nop // 0048BED5
  nop // 0048BED6
  nop // 0048BED7
  nop // 0048BED8
  nop // 0048BED9
  nop // 0048BEDA
  nop // 0048BEDB
  nop // 0048BEDC
  nop // 0048BEDD
  nop // 0048BEDE
  nop // 0048BEDF
  nop // 0048BEE0
  nop // 0048BEE1
  nop // 0048BEE2
  nop // 0048BEE3
  nop // 0048BEE4
  nop // 0048BEE5
  nop // 0048BEE6

// Reference VA 0048BF6B..0048BFD2.
// Remove the second per-channel VFX color increment and clamp pass.
assert(TOS.exe+8BF6B,0F B6 4B 30 66 01 4C C3 20 0F B6 4B 31 66 01 4C C3 22 0F B6 4B 32 66 01 4C C3 24 0F B6 4B 33 66 01 4C C3 26 B9 FF 00 00 00 66 39 4C C3 20 7E 05 66 89 4C C3 20 B9 FF 00 00 00 66 39 4C C3 22 7E 05 66 89 4C C3 22 B9 FF 00 00 00 66 39 4C C3 24 7E 05 66 89 4C C3 24 B9 FF 00 00 00 66 39 4C C3 26 7E 05 66 89 4C C3 26)
TOS.exe+8BF6B:
  nop // 0048BF6B
  nop // 0048BF6C
  nop // 0048BF6D
  nop // 0048BF6E
  nop // 0048BF6F
  nop // 0048BF70
  nop // 0048BF71
  nop // 0048BF72
  nop // 0048BF73
  nop // 0048BF74
  nop // 0048BF75
  nop // 0048BF76
  nop // 0048BF77
  nop // 0048BF78
  nop // 0048BF79
  nop // 0048BF7A
  nop // 0048BF7B
  nop // 0048BF7C
  nop // 0048BF7D
  nop // 0048BF7E
  nop // 0048BF7F
  nop // 0048BF80
  nop // 0048BF81
  nop // 0048BF82
  nop // 0048BF83
  nop // 0048BF84
  nop // 0048BF85
  nop // 0048BF86
  nop // 0048BF87
  nop // 0048BF88
  nop // 0048BF89
  nop // 0048BF8A
  nop // 0048BF8B
  nop // 0048BF8C
  nop // 0048BF8D
  nop // 0048BF8E
  nop // 0048BF8F
  nop // 0048BF90
  nop // 0048BF91
  nop // 0048BF92
  nop // 0048BF93
  nop // 0048BF94
  nop // 0048BF95
  nop // 0048BF96
  nop // 0048BF97
  nop // 0048BF98
  nop // 0048BF99
  nop // 0048BF9A
  nop // 0048BF9B
  nop // 0048BF9C
  nop // 0048BF9D
  nop // 0048BF9E
  nop // 0048BF9F
  nop // 0048BFA0
  nop // 0048BFA1
  nop // 0048BFA2
  nop // 0048BFA3
  nop // 0048BFA4
  nop // 0048BFA5
  nop // 0048BFA6
  nop // 0048BFA7
  nop // 0048BFA8
  nop // 0048BFA9
  nop // 0048BFAA
  nop // 0048BFAB
  nop // 0048BFAC
  nop // 0048BFAD
  nop // 0048BFAE
  nop // 0048BFAF
  nop // 0048BFB0
  nop // 0048BFB1
  nop // 0048BFB2
  nop // 0048BFB3
  nop // 0048BFB4
  nop // 0048BFB5
  nop // 0048BFB6
  nop // 0048BFB7
  nop // 0048BFB8
  nop // 0048BFB9
  nop // 0048BFBA
  nop // 0048BFBB
  nop // 0048BFBC
  nop // 0048BFBD
  nop // 0048BFBE
  nop // 0048BFBF
  nop // 0048BFC0
  nop // 0048BFC1
  nop // 0048BFC2
  nop // 0048BFC3
  nop // 0048BFC4
  nop // 0048BFC5
  nop // 0048BFC6
  nop // 0048BFC7
  nop // 0048BFC8
  nop // 0048BFC9
  nop // 0048BFCA
  nop // 0048BFCB
  nop // 0048BFCC
  nop // 0048BFCD
  nop // 0048BFCE
  nop // 0048BFCF
  nop // 0048BFD0
  nop // 0048BFD1
  nop // 0048BFD2

// Reference VA 0048C055..0048C0B4.
// Remove the second per-channel VFX color decrement and clamp pass.
assert(TOS.exe+8C055,0F B6 4B 34 66 29 4C C3 20 0F B6 4B 35 66 29 4C C3 22 0F B6 4B 36 66 29 4C C3 24 0F B6 4B 37 66 29 4C C3 26 66 83 7C C3 20 00 7D 07 33 C9 66 89 4C C3 20 66 83 7C C3 22 00 7D 07 33 C9 66 89 4C C3 22 66 83 7C C3 24 00 7D 07 33 C9 66 89 4C C3 24 66 83 7C C3 26 00 7D 07 33 C9 66 89 4C C3 26)
TOS.exe+8C055:
  nop // 0048C055
  nop // 0048C056
  nop // 0048C057
  nop // 0048C058
  nop // 0048C059
  nop // 0048C05A
  nop // 0048C05B
  nop // 0048C05C
  nop // 0048C05D
  nop // 0048C05E
  nop // 0048C05F
  nop // 0048C060
  nop // 0048C061
  nop // 0048C062
  nop // 0048C063
  nop // 0048C064
  nop // 0048C065
  nop // 0048C066
  nop // 0048C067
  nop // 0048C068
  nop // 0048C069
  nop // 0048C06A
  nop // 0048C06B
  nop // 0048C06C
  nop // 0048C06D
  nop // 0048C06E
  nop // 0048C06F
  nop // 0048C070
  nop // 0048C071
  nop // 0048C072
  nop // 0048C073
  nop // 0048C074
  nop // 0048C075
  nop // 0048C076
  nop // 0048C077
  nop // 0048C078
  nop // 0048C079
  nop // 0048C07A
  nop // 0048C07B
  nop // 0048C07C
  nop // 0048C07D
  nop // 0048C07E
  nop // 0048C07F
  nop // 0048C080
  nop // 0048C081
  nop // 0048C082
  nop // 0048C083
  nop // 0048C084
  nop // 0048C085
  nop // 0048C086
  nop // 0048C087
  nop // 0048C088
  nop // 0048C089
  nop // 0048C08A
  nop // 0048C08B
  nop // 0048C08C
  nop // 0048C08D
  nop // 0048C08E
  nop // 0048C08F
  nop // 0048C090
  nop // 0048C091
  nop // 0048C092
  nop // 0048C093
  nop // 0048C094
  nop // 0048C095
  nop // 0048C096
  nop // 0048C097
  nop // 0048C098
  nop // 0048C099
  nop // 0048C09A
  nop // 0048C09B
  nop // 0048C09C
  nop // 0048C09D
  nop // 0048C09E
  nop // 0048C09F
  nop // 0048C0A0
  nop // 0048C0A1
  nop // 0048C0A2
  nop // 0048C0A3
  nop // 0048C0A4
  nop // 0048C0A5
  nop // 0048C0A6
  nop // 0048C0A7
  nop // 0048C0A8
  nop // 0048C0A9
  nop // 0048C0AA
  nop // 0048C0AB
  nop // 0048C0AC
  nop // 0048C0AD
  nop // 0048C0AE
  nop // 0048C0AF
  nop // 0048C0B0
  nop // 0048C0B1
  nop // 0048C0B2
  nop // 0048C0B3
  nop // 0048C0B4

// Reference VA 0048C17E..0048C18D.
// Remove the second pair of VFX texture-coordinate updates.
assert(TOS.exe+8C17E,0F B7 48 04 66 01 4B 08 0F B7 50 06 66 01 53 0A)
TOS.exe+8C17E:
// Vanilla: movzx ecx, word ptr [eax + 4]; add word ptr [ebx + 8], cx; movzx edx, word ptr [eax + 6]; add word ptr [ebx + 0xa], dx
  nop // 0048C17E
  nop // 0048C17F
  nop // 0048C180
  nop // 0048C181
  nop // 0048C182
  nop // 0048C183
  nop // 0048C184
  nop // 0048C185
  nop // 0048C186
  nop // 0048C187
  nop // 0048C188
  nop // 0048C189
  nop // 0048C18A
  nop // 0048C18B
  nop // 0048C18C
  nop // 0048C18D

// Reference VA 0048C2CF..0048C2D6.
// Advance the VFX word timer at +28A by one per update.
assert(TOS.exe+8C2CF,66 83 86 8A 02 00 00 02)
TOS.exe+8C2CF:
// Vanilla: add word ptr [esi + 0x28a], 2
  add word ptr [esi + 0x28a], #1 // 0048C2CF

// Reference VA 0048C2E4..0048C2EA.
// Advance the VFX byte timer at +293 by one per update.
assert(TOS.exe+8C2E4,80 86 93 02 00 00 02)
TOS.exe+8C2E4:
// Vanilla: add byte ptr [esi + 0x293], 2
  add byte ptr [esi + 0x293], #1 // 0048C2E4

// Reference VA 0048CDA0..0048CDA5.
// Use the private -1.0 value in projectile lifetime/countdown handling instead of the vanilla -2.0
// value.
assert(TOS.exe+8CDA0,DD 05 80 2C 88 00)
TOS.exe+8CDA0:
// Vanilla: fld qword ptr [0x882c80]
  fld qword ptr [fps_double_negative_one] // 0048CDA0

// Projectile hitbox growth: accepted Explosion trial, added after v0.0.46.
// The shared update added each dimension's growth twice while its lifetime
// already advances once per 60 FPS tick. Retain the first addition and remove
// the duplicate: size 32 with growth 10 now adds 10, not 20, each update.
// Initial dimensions, lifetime and x87 stack depth remain unchanged. Applies
// to all growing projectiles; pairs with the +1 lifetime counter below.
assert(TOS.exe+8CF48,D8 43 50)
TOS.exe+8CF48:
// Vanilla: fadd dword ptr [ebx+50]
  nop 3

assert(TOS.exe+8CF60,D8 43 54)
TOS.exe+8CF60:
// Vanilla: fadd dword ptr [ebx+54]
  nop 3

// Reference VA 0048CFC8..0048CFCA.
// Advance the projectile update counter by one rather than two.
assert(TOS.exe+8CFC8,83 C7 02)
TOS.exe+8CFC8:
// Vanilla: add edi, 2
  add edi, #1 // 0048CFC8

// Reference VA 0048D0FE..0048D111.
// Discard the duplicate projectile position contribution with three x87 pops, retaining the original
// stack balance.
assert(TOS.exe+8D0FE,D9 00 DE C3 D9 CA D9 18 D8 40 04 D9 58 04 D8 40 08 D9 58 08)
TOS.exe+8D0FE:
// Vanilla: fld dword ptr [eax]; faddp st(3); fxch st(2); fstp dword ptr [eax]; fadd dword ptr [eax + 4]; fstp dword ptr [eax + 4]; fadd dword ptr [eax + 8]; fstp dword ptr [eax + 8]
  fstp st(0) // 0048D0FE
  fstp st(0) // 0048D100
  fstp st(0) // 0048D102
  nop // 0048D104
  nop // 0048D105
  nop // 0048D106
  nop // 0048D107
  nop // 0048D108
  nop // 0048D109
  nop // 0048D10A
  nop // 0048D10B
  nop // 0048D10C
  nop // 0048D10D
  nop // 0048D10E
  nop // 0048D10F
  nop // 0048D110
  nop // 0048D111

// Reference VA 0048D145..0048D175.
// Remove the second projectile XYZ position and velocity integration block. This is not an odd-frame
// update gate.
assert(TOS.exe+8D145,D9 07 D8 00 D9 18 D9 40 04 D8 47 04 D9 58 04 D9 40 08 D8 47 08 D9 58 08 D9 07 D8 43 30 D9 1F D9 43 34 D8 47 04 D9 5F 04 D9 47 08 D8 43 38 D9 5F 08)
TOS.exe+8D145:
  nop // 0048D145
  nop // 0048D146
  nop // 0048D147
  nop // 0048D148
  nop // 0048D149
  nop // 0048D14A
  nop // 0048D14B
  nop // 0048D14C
  nop // 0048D14D
  nop // 0048D14E
  nop // 0048D14F
  nop // 0048D150
  nop // 0048D151
  nop // 0048D152
  nop // 0048D153
  nop // 0048D154
  nop // 0048D155
  nop // 0048D156
  nop // 0048D157
  nop // 0048D158
  nop // 0048D159
  nop // 0048D15A
  nop // 0048D15B
  nop // 0048D15C
  nop // 0048D15D
  nop // 0048D15E
  nop // 0048D15F
  nop // 0048D160
  nop // 0048D161
  nop // 0048D162
  nop // 0048D163
  nop // 0048D164
  nop // 0048D165
  nop // 0048D166
  nop // 0048D167
  nop // 0048D168
  nop // 0048D169
  nop // 0048D16A
  nop // 0048D16B
  nop // 0048D16C
  nop // 0048D16D
  nop // 0048D16E
  nop // 0048D16F
  nop // 0048D170
  nop // 0048D171
  nop // 0048D172
  nop // 0048D173
  nop // 0048D174
  nop // 0048D175

// Reference VA 0048D2D0..0048D2D5.
// Use a single-update factor of 1.0 in projectile physics.
assert(TOS.exe+8D2D0,DD 05 B8 29 88 00)
TOS.exe+8D2D0:
// Vanilla: fld qword ptr [0x8829b8]
  fld qword ptr [fps_double_one] // 0048D2D0

// Reference VA 0048D79A..0048D79B.
// Redirect the zero-count branch past the repeated projectile counter decrement; keep the original
// subsequent state check.
assert(TOS.exe+8D79A,74 05)
TOS.exe+8D79A:
// Vanilla: je 0x48d7a1
  je short TOS.exe+8D7B2 // 0048D79A

// Reference VA 0048D7CA..0048D7CD.
// Remove the second projectile counter decrement and its redundant conditional branch.
assert(TOS.exe+8D7CA,74 05 FE C9)
TOS.exe+8D7CA:
// Vanilla: je 0x48d7d1; dec cl
  nop // 0048D7CA
  nop // 0048D7CB
  nop // 0048D7CC
  nop // 0048D7CD

// Reference VA 0048D7DA..0048D7DB.
// Redirect the zero-count branch past the repeated projectile counter decrement; keep the original
// subsequent state check.
assert(TOS.exe+8D7DA,74 05)
TOS.exe+8D7DA:
// Vanilla: je 0x48d7e1
  je short TOS.exe+8D7F2 // 0048D7DA

// Reference VA 0048D809..0048D80C.
// Remove the second projectile counter decrement and its redundant conditional branch.
assert(TOS.exe+8D809,74 04 FE C9)
TOS.exe+8D809:
// Vanilla: je 0x48d80f; dec cl
  nop // 0048D809
  nop // 0048D80A
  nop // 0048D80B
  nop // 0048D80C

// Reference VA 0048D819..0048D81A.
// Redirect the zero-count branch past the repeated projectile counter decrement; keep the original
// subsequent state check.
assert(TOS.exe+8D819,74 05)
TOS.exe+8D819:
// Vanilla: je 0x48d820
  je short TOS.exe+8D831 // 0048D819

// Reference VA 0048D849..0048D84C.
// Remove the second projectile counter decrement and its redundant conditional branch.
assert(TOS.exe+8D849,74 05 FE C9)
TOS.exe+8D849:
// Vanilla: je 0x48d850; dec cl
  nop // 0048D849
  nop // 0048D84A
  nop // 0048D84B
  nop // 0048D84C

// Reference VA 0048D85A..0048D85B.
// Redirect the zero-count branch past the repeated projectile counter decrement; keep the original
// subsequent state check.
assert(TOS.exe+8D85A,74 05)
TOS.exe+8D85A:
// Vanilla: je 0x48d861
  je short TOS.exe+8D872 // 0048D85A

// Reference VA 0048D88A..0048D88D.
// Remove the second projectile counter decrement and its redundant conditional branch.
assert(TOS.exe+8D88A,74 05 FE C9)
TOS.exe+8D88A:
// Vanilla: je 0x48d891; dec cl
  nop // 0048D88A
  nop // 0048D88B
  nop // 0048D88C
  nop // 0048D88D

// ======================================================================
// Battle rendering
// Actor/render cadence and the retained packed drawing-data adjustment.
// The packed draw-data change at 00403C8E is preserved exactly; its precise visual purpose remains
// unverified.
// ======================================================================

// Reference VA 00403C8E..00403C9D.
// Change the two packed drawing values from 03030000/03030500 to 03070000/03070500 before the call to
// 47BCE0. The exact visual role is unverified; do not describe this as a timer change.
assert(TOS.exe+3C8E,C7 44 24 10 00 00 03 03 C7 44 24 14 00 05 03 03)
TOS.exe+3C8E:
// Vanilla: mov dword ptr [esp + 0x10], 0x3030000; mov dword ptr [esp + 0x14], 0x3030500
  mov dword ptr [esp + 0x10], 0x3070000 // 00403C8E
  mov dword ptr [esp + 0x14], 0x3070500 // 00403C96

// Reference VA 0043723E..0043723F.
// Remove the doubled x87 term in the actor model-transform path; retain the single computed
// contribution.
assert(TOS.exe+3723E,DC C0)
TOS.exe+3723E:
// Vanilla: fadd st(0), st(0)
  nop // 0043723E
  nop // 0043723F

// Reference VA 00437FA8..00437FAD.
// Subtract one unit, rather than two, in the actor/weapon render timing path.
assert(TOS.exe+37FA8,DC 25 B8 29 88 00)
TOS.exe+37FA8:
// Vanilla: fsub qword ptr [0x8829b8]
  fsub qword ptr [fps_double_one] // 00437FA8

// Reference VA 0045F288..0045F289.
// Remove the conditional branch in the battle render path, preserving the v46 fallthrough behavior.
// Exact visual purpose requires further confirmation.
assert(TOS.exe+5F288,75 40)
TOS.exe+5F288:
// Vanilla: jne 0x45f2ca
  nop // 0045F288
  nop // 0045F289

// ======================================================================
// Crescent moon orientation
// Reflect only the Infliction/Crescent Moon texture layers.
// ======================================================================

alloc(moonfix_code,100)
label(moonfix_original)

assert(TOS.exe+521A6,E8 45 5E 00 00)
assert(TOS.exe+521AB,83 C4 0C F7 43 18 00 00 00 40)
assert(TOS.exe+57FF0,55 8B EC 83 E4 F0 81 EC 8C 00 00 00 53 8B 5E 18)
assert(TOS.exe+581D2,E8 E9 E4 13 00)

TOS.exe+521A6:
  call moonfix_code

moonfix_code:
  pushfd

  // Shared arte atlas / palette 28, the two U origins, and the crescent strip.
  // Exact flags exclude culled, attached, alternate and billboard variants.
  cmp dword ptr [esi],1C010104
  jne moonfix_original
  cmp dword ptr [esi+18],04182010
  jne moonfix_original
  test word ptr [esi+8],FF7F
  jne moonfix_original
  cmp word ptr [esi+A],0080
  jne moonfix_original
  cmp dword ptr [esi+C],00200008
  jne moonfix_original
  popfd

  // Reverse animated roll in a private copy of the 360-byte effect record.
  // ESI is the source, EDI the draw matrix; translation is passed by value.
  push ebp
  mov ebp,esp
  push esi
  push ecx
  push edi
  sub esp,168
  mov edi,esp
  mov ecx,5A
  rep movsd
  mov esi,esp
  xor byte ptr [esi+6B],80
  mov edi,[ebp-C]
  mov ecx,[ebp-8]
  push dword ptr [ebp+10]
  push dword ptr [ebp+C]
  push dword ptr [ebp+8]
  call TOS.exe+57FF0
  lea esp,[ebp-4]
  pop esi
  pop ebp

  // Reflect local X without changing translation or culling state.
  pushfd
  xor byte ptr [edi+3],80
  xor byte ptr [edi+13],80
  xor byte ptr [edi+23],80
  popfd
  ret
moonfix_original:
  popfd
  jmp TOS.exe+57FF0

[DISABLE]
// Restoration evidence only; settings take effect on a fresh launch.

// Battle hud
TOS.exe+385EF:
  db 66,83,86,EA,39,01,00,02
TOS.exe+487EA:
  db 66,83,86,54,8C,00,00,A0
TOS.exe+4880B:
  db 66,83,86,54,8C,00,00,60
TOS.exe+4885D:
  db 80,87,FE,85,00,00,02
TOS.exe+49A22:
  db E8,B9,22,03,00
TOS.exe+4BCF0:
  db 66,83,86,52,8C,00,00,D0
TOS.exe+4BD05:
  db 66,83,86,52,8C,00,00,30
TOS.exe+4BD48:
  db 7D,08
TOS.exe+4C1F0:
  db 7D,04
TOS.exe+4D533:
  db FE,CA
TOS.exe+4D54B:
  db FE,C2
TOS.exe+4D5A8:
  db 74,09
TOS.exe+4E163:
  db 80,44,08,0A,02
TOS.exe+503FC:
  db BB,02,00,00,00
TOS.exe+50426:
  db 74,35
TOS.exe+50491:
  db 74,33
TOS.exe+504F2:
  db 74,33
TOS.exe+50553:
  db 74,33
TOS.exe+505BD:
  db 74,34
TOS.exe+5089F:
  db 74,08
dealloc(fps_battle_hud_code)

// Battle cutins
TOS.exe+51156:
  db 66,83,81,10,8D,00,00,02
TOS.exe+51180:
  db 66,83,81,12,8D,00,00,E7
TOS.exe+51190:
  db 66,83,81,10,8D,00,00,02
TOS.exe+51236:
  db 66,83,81,10,8D,00,00,02
TOS.exe+5127B:
  db 66,83,81,12,8D,00,00,E0
TOS.exe+5135B:
  db 66,83,81,10,8D,00,00,02
TOS.exe+51383:
  db 66,83,81,10,8D,00,00,02
TOS.exe+5139E:
  db 66,83,81,12,8D,00,00,E0
TOS.exe+5142A:
  db 66,83,81,12,8D,00,00,E0
TOS.exe+51508:
  db 83,C0,02
TOS.exe+51510:
  db 66,83,81,10,8D,00,00,02
TOS.exe+5152B:
  db 66,83,81,0A,8D,00,00,FC
TOS.exe+5154E:
  db 66,83,81,10,8D,00,00,02
TOS.exe+51567:
  db 66,83,81,12,8D,00,00,F0
TOS.exe+5158C:
  db 66,83,81,10,8D,00,00,02
TOS.exe+60C2E:
  db D1,FF
TOS.exe+60D32:
  db 8D,0C,3F
TOS.exe+60D42:
  db 66,39,96,54,93,00,00
TOS.exe+60D54:
  db 66,83,86,56,93,00,00,20
TOS.exe+60D81:
  db 8B,EC
TOS.exe+60D95:
  db BA,00,04,00,00,66,3B,CA,7C,0D,8B,CA,66,89,88,54,93,00,00,B0,01,5D,C3,83,C1,FC,66,89,88,54,93,00,00,66,85,C9,79,1C,33,D2,66,83,80,56,93,00,00,F0,66,89,90,54,93,00,00,79,09,33,C9,66,89,88,56,93,00,00,32,C0
TOS.exe+61278:
  db FE,C1,88,88,28,9A,00,00
TOS.exe+6128F:
  db 49,66,89,88,24,9A,00,00
TOS.exe+612AF:
  db FE,C9,88,88,28,9A,00,00

// Battle particles projectiles
TOS.exe+29B8F:
  db 66,83,84,73,34,E7,00,00,FE
TOS.exe+29CA3:
  db 04,02
TOS.exe+3CEA2:
  db BF,02,00,00,00
TOS.exe+575EB:
  db 66,83,47,36,02
TOS.exe+57632:
  db 66,83,46,10,02
TOS.exe+8B262:
  db 83,C0,02
TOS.exe+8B27B:
  db 83,C0,02
TOS.exe+8B7D0:
  db D9,43,48,D8,43,3C,D9,5B,3C,D9,43,4C,D8,43,40,D9,5B,40,D9,43,50,D8,43,44,D9,5B,44,D9,43,48,D8,43,54,D9,5B,48,D9,43,4C,D8,43,58,D9,5B,4C,D9,43,50,D8,43,5C,D9,5B,50
TOS.exe+8B836:
  db D9,43,78,D8,43,54,D9,5B,54,D9,43,58,D8,43,7C,D9,5B,58,D9,83,80,00,00,00,D8,43,5C,D9,5B,5C
TOS.exe+8B8C5:
  db D9,43,48,D8,83,50,01,00,00,D9,9B,50,01,00,00,D9,43,4C,D8,83,54,01,00,00,D9,9B,54,01,00,00,D9,43,50,D8,83,58,01,00,00,D9,9B,58,01,00,00,D9,43,48,D8,43,54,D9,5B,48,D9,43,4C,D8,43,58,D9,5B,4C,D9,43,50,D8,43,5C,D9,5B,50
TOS.exe+8BB44:
  db D9,43,60,D8,43,6C,D9,5B,60,D9,43,70,D8,43,64,D9,5B,64,D9,43,74,D8,43,68,D9,5B,68
TOS.exe+8BBB3:
  db D9,83,A0,00,00,00,D8,83,AC,00,00,00,D9,9B,A0,00,00,00,D9,83,A4,00,00,00,D8,83,B0,00,00,00,D9,9B,A4,00,00,00,D9,83,B4,00,00,00,D8,83,A8,00,00,00,D9,9B,A8,00,00,00
TOS.exe+8BC4A:
  db D9,83,B8,00,00,00,D8,83,E8,00,00,00,D9,9B,B8,00,00,00,D9,83,EC,00,00,00,D8,83,BC,00,00,00,D9,9B,BC,00,00,00,D9,83,F0,00,00,00,D8,83,C0,00,00,00,D9,9B,C0,00,00,00
TOS.exe+8BCB6:
  db D9,83,C4,00,00,00,D8,83,F4,00,00,00,D9,9B,C4,00,00,00,D9,83,F8,00,00,00,D8,83,C8,00,00,00,D9,9B,C8,00,00,00,D9,83,FC,00,00,00,D8,83,CC,00,00,00,D9,9B,CC,00,00,00
TOS.exe+8BD22:
  db D9,83,00,01,00,00,D8,83,D0,00,00,00,D9,9B,D0,00,00,00,D9,83,04,01,00,00,D8,83,D4,00,00,00,D9,9B,D4,00,00,00,D9,83,D8,00,00,00,D8,83,08,01,00,00,D9,9B,D8,00,00,00
TOS.exe+8BD8E:
  db D9,83,DC,00,00,00,D8,83,0C,01,00,00,D9,9B,DC,00,00,00,D9,83,E0,00,00,00,D8,83,10,01,00,00,D9,9B,E0,00,00,00,D9,83,E4,00,00,00,D8,83,14,01,00,00,D9,9B,E4,00,00,00
TOS.exe+8BE5E:
  db D9,83,C4,00,00,00,D8,83,B8,00,00,00,D9,9B,B8,00,00,00,D9,83,C8,00,00,00,D8,83,BC,00,00,00,D9,9B,BC,00,00,00,D9,83,C0,00,00,00,D8,83,CC,00,00,00,D9,9B,C0,00,00,00
TOS.exe+8BEB1:
  db D9,83,C4,00,00,00,D8,83,D0,00,00,00,D9,9B,C4,00,00,00,D9,83,D4,00,00,00,D8,83,C8,00,00,00,D9,9B,C8,00,00,00,D9,83,D8,00,00,00,D8,83,CC,00,00,00,D9,9B,CC,00,00,00
TOS.exe+8BF6B:
  db 0F,B6,4B,30,66,01,4C,C3,20,0F,B6,4B,31,66,01,4C,C3,22,0F,B6,4B,32,66,01,4C,C3,24,0F,B6,4B,33,66,01,4C,C3,26,B9,FF,00,00,00,66,39,4C,C3,20,7E,05,66,89,4C,C3,20,B9,FF,00,00,00,66,39,4C,C3,22,7E,05,66,89,4C,C3,22,B9,FF,00,00,00,66,39,4C,C3,24,7E,05,66,89,4C,C3,24,B9,FF,00,00,00,66,39,4C,C3,26,7E,05,66,89,4C,C3,26
TOS.exe+8C055:
  db 0F,B6,4B,34,66,29,4C,C3,20,0F,B6,4B,35,66,29,4C,C3,22,0F,B6,4B,36,66,29,4C,C3,24,0F,B6,4B,37,66,29,4C,C3,26,66,83,7C,C3,20,00,7D,07,33,C9,66,89,4C,C3,20,66,83,7C,C3,22,00,7D,07,33,C9,66,89,4C,C3,22,66,83,7C,C3,24,00,7D,07,33,C9,66,89,4C,C3,24,66,83,7C,C3,26,00,7D,07,33,C9,66,89,4C,C3,26
TOS.exe+8C17E:
  db 0F,B7,48,04,66,01,4B,08,0F,B7,50,06,66,01,53,0A
TOS.exe+8C2CF:
  db 66,83,86,8A,02,00,00,02
TOS.exe+8C2E4:
  db 80,86,93,02,00,00,02
TOS.exe+8CDA0:
  db DD,05,80,2C,88,00
TOS.exe+8CF48:
  db D8,43,50
TOS.exe+8CF60:
  db D8,43,54
TOS.exe+8CFC8:
  db 83,C7,02
TOS.exe+8D0FE:
  db D9,00,DE,C3,D9,CA,D9,18,D8,40,04,D9,58,04,D8,40,08,D9,58,08
TOS.exe+8D145:
  db D9,07,D8,00,D9,18,D9,40,04,D8,47,04,D9,58,04,D9,40,08,D8,47,08,D9,58,08,D9,07,D8,43,30,D9,1F,D9,43,34,D8,47,04,D9,5F,04,D9,47,08,D8,43,38,D9,5F,08
TOS.exe+8D2D0:
  db DD,05,B8,29,88,00
TOS.exe+8D79A:
  db 74,05
TOS.exe+8D7CA:
  db 74,05,FE,C9
TOS.exe+8D7DA:
  db 74,05
TOS.exe+8D809:
  db 74,04,FE,C9
TOS.exe+8D819:
  db 74,05
TOS.exe+8D849:
  db 74,05,FE,C9
TOS.exe+8D85A:
  db 74,05
TOS.exe+8D88A:
  db 74,05,FE,C9

// Battle rendering
TOS.exe+3C8E:
  db C7,44,24,10,00,00,03,03,C7,44,24,14,00,05,03,03
TOS.exe+3723E:
  db DC,C0
TOS.exe+37FA8:
  db DC,25,B8,29,88,00
TOS.exe+5F288:
  db 75,40

// Crescent moon orientation
TOS.exe+521A6:
  db E8 45 5E 00 00
dealloc(moonfix_code)
