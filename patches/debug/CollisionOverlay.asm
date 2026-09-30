// Battle collision visualization, ported from the corrected draw-hitboxes prototype.
// This readable ASM is authoritative; the private prototype is provenance only.
// Blue hurtboxes and green hitboxes share the configurable fill/outline Alpha.
// Native XYZ coordinates and perimeter-order quads preserve the corrected geometry.
// Hooks preserve GPRs, EFLAGS, x87 and SSE state. No saved heap pointers or caves.
[ENABLE]
alloc(overlay_code,0x4000)
alloc(overlay_data,0x2800)
define(game_battle,TOS.exe+0x6d2edc)
define(game_draw_cursor,TOS.exe+0x183c40c)
define(game_draw_end,TOS.exe+0x183c408)
define(game_line_vtable,TOS.exe+0x478940)
define(game_rect_vtable,TOS.exe+0x478990)
define(game_draw_matrix,TOS.exe+0x4f0424)
define(game_bone_position,TOS.exe+0x6a40)
define(game_submit,TOS.exe+0x1873d0)
assert(TOS.exe+0x5ee4f,e8 7c 4a 00 00)
assert(TOS.exe+0x5f0c4,e8 e7 27 00 00)
assert(TOS.exe+0x5ed79,89 87 e8 b1 15 00)
// Guard the native callback/renderer contracts and the reset continuation.
assert(TOS.exe+0x6a40,55 8b ec 83 e4 f0 83 ec 64 53 8b 5d 08 56 8b 75)
assert(TOS.exe+0x1873d0,55 8b ec 6a ff 68 c8 e2 6e 00 64 a1 00 00 00 00)
assert(TOS.exe+0x638d0,55 8b ec 83 e4 f8 83 ec 0c 53 56 57 8b 3d dc 2e)
assert(TOS.exe+0x618b0,55 8b ec 83 ec 3c a1 c4 8d 8a 00 33 c5 89 45 fc)
assert(TOS.exe+0x5ed7f,0f b7 86 ba 90 00 00 66)
assert(TOS.exe+0x478940,20 6b 58 00 30 86 58 00 d0 73 58 00)
assert(TOS.exe+0x478990,20 6b 58 00 30 86 58 00 d0 73 58 00)

TOS.exe+0x5ee4f:
  call capture_hook
TOS.exe+0x5f0c4:
  call render_hook
TOS.exe+0x5ed79:
  jmp reset_hook
  nop

overlay_code:
capture_hook:
  pushfd
  pushad
  mov ebp,esp
  sub esp,#528
  and esp,-#16
  fxsave [esp]
  fninit
  cld
  call capture
  fxrstor [esp]
  mov esp,ebp
  popad
  popfd
  jmp TOS.exe+0x638d0

render_hook:
  pushfd
  pushad
  mov ebp,esp
  sub esp,#528
  and esp,-#16
  fxsave [esp]
  fninit
  cld
  call render
  fxrstor [esp]
  mov esp,ebp
  popad
  popfd
  jmp TOS.exe+0x618b0

reset_hook:
  mov [edi+0x15b1e8],eax // replay queue reset
  pushfd
  pushad
  mov ebp,esp
  sub esp,#528
  and esp,-#16
  fxsave [esp]
  fninit
  cld
  call reset_snapshot
  fxrstor [esp]
  mov esp,ebp
  popad
  popfd
  jmp TOS.exe+0x5ed7f

submit:
  mov ecx,[esp+#4]
  jmp game_submit


// Reject non-finite and implausible collision coordinates.
finite:
  push	ebp
  mov	ebp, esp
  fld	DWORD PTR [ebp+#8]
  fucomi st(0)
  jnp	L2
  fstp	st(0)
  jmp	L4
L9:
  fstp	st(0)
L4:
  xor	eax, eax
  jmp	L1
L2:
  fld	DWORD PTR [LC1]
  fxch	st(1)
  fcomi st(1)
  fstp	st(1)
  jbe	L9
  fld	DWORD PTR [LC2]
  xor	eax, eax
  fcomip st(1)
  fstp	st(0)
  seta	al
L1:
  pop	ebp
  ret

// Validate a Volume: center XYZ, radius, height and inner radius.
valid:
  push	ebp
  mov	edx, eax
  mov	ebp, esp
  sub	esp, #8
  push	DWORD PTR [eax]
  call	finite
  pop	ecx
  test	eax, eax
  je	L10
  push	DWORD PTR [edx+#4]
  call	finite
  pop	ecx
  test	eax, eax
  je	L10
  push	DWORD PTR [edx+#8]
  call	finite
  pop	ecx
  test	eax, eax
  je	L10
  fld	DWORD PTR [edx+#12]
  push	eax
  fst	DWORD PTR [ebp-#4]
  fstp	DWORD PTR [esp]
  call	finite
  pop	ecx
  test	eax, eax
  je	L10
  fld	DWORD PTR [edx+#16]
  push	ecx
  fst	DWORD PTR [esp]
  fstp	DWORD PTR [ebp-#8]
  call	finite
  pop	ecx
  test	eax, eax
  je	L10
  push	DWORD PTR [edx+#20]
  call	finite
  pop	edx
  test	eax, eax
  je	L10
  fldz
  fld	DWORD PTR [ebp-#4]
  fcomip st(1)
  fld	DWORD PTR [ebp-#8]
  ja	L12
  fstp	st(0)
  fstp	st(0)
  jmp	L13
L37:
  fstp	st(0)
  fstp	st(0)
  fstp	st(0)
  jmp	L13
L38:
  fstp	st(0)
  fstp	st(0)
L13:
  xor	eax, eax
  jmp	L10
L12:
  fld	DWORD PTR [ebp-#4]
  fld	DWORD PTR [LC5]
  fcomi st(1)
  fstp	st(1)
  jbe	L37
  fxch	st(1)
  fcomi st(2)
  fstp	st(2)
  jb	L38
  xor	eax, eax
  fcomip st(1)
  fstp	st(0)
  seta	al
L10:
  leave
  ret

// Build a world-space point from the 12-segment circle tables.
ringpoint:
  push	ebp
  mov	ebp, esp
  fld	DWORD PTR [ebp+#8]
  fld	DWORD PTR [ebp+#12]
  fadd	DWORD PTR [edx+#4]
  pop	ebp
  fld	DWORD PTR [sn+#0+ecx*#4]
  fmul	st, st(2)
  fadd	DWORD PTR [edx+#8]
  fxch	st(2)
  fmul	DWORD PTR [circle_cos+#0+ecx*#4]
  fadd	DWORD PTR [edx]
  fstp	DWORD PTR [eax]
  fstp	DWORD PTR [eax+#4]
  fstp	DWORD PTR [eax+#8]
  ret

// Submit native LinePC/RectPC commands; bound queue use and keep 256 KiB headroom.
// Header + positions + colors are separate arrays. Test mode checks winding/bounds.
emit:
  push	ebp
  mov	ebp, esp
  push	edi
  push	esi
  push	ebx
  mov	ebx, eax
  sub	esp, #180
  mov	eax, DWORD PTR [state+#64]
  test	eax, eax
  je	L42
  cmp	edx, #4
  jne	L43
  fld	DWORD PTR [ebx]
  fld	DWORD PTR [ebx+#4]
  fld	DWORD PTR [ebx+#8]
  fld	DWORD PTR [ebx+#24]
  fsub	st, st(3)
  fld	DWORD PTR [ebx+#28]
  fsub	st, st(3)
  fld	DWORD PTR [ebx+#32]
  fsub	st, st(3)
  fld	DWORD PTR [ebx+#12]
  fsub	st, st(6)
  fstp	DWORD PTR [ebp-#184]
  fld	DWORD PTR [ebx+#16]
  fsub	st, st(5)
  fstp	DWORD PTR [ebp-#188]
  fld	DWORD PTR [ebx+#20]
  fsub	st, st(4)
  fld	DWORD PTR [ebx+#36]
  fsubrp st(7)
  fxch	st(5)
  fsubr	DWORD PTR [ebx+#40]
  fst	DWORD PTR [ebp-#180]
  fxch	st(4)
  fsubr	DWORD PTR [ebx+#44]
  fld	st(0)
  fmul	st, st(3)
  fxch	st(5)
  fmul	st, st(2)
  fsubp st(5)
  fld	DWORD PTR [ebp-#188]
  fmul	st, st(2)
  fstp	DWORD PTR [ebp-#192]
  fld	st(5)
  fmul	st, st(3)
  fsubr	DWORD PTR [ebp-#192]
  fmulp st(5)
  fld	st(6)
  fmul	st, st(2)
  fxch	st(1)
  fmul	st, st(4)
  fsubp st(1)
  fxch	st(5)
  fmul	st, st(3)
  fxch	st(1)
  fmul	DWORD PTR [ebp-#184]
  fsubp st(1)
  fmulp st(4)
  fxch	st(3)
  faddp st(2)
  fld	DWORD PTR [ebp-#180]
  fmul	st, st(1)
  fxch	st(4)
  fmul	st, st(3)
  fsubp st(4)
  fld	DWORD PTR [ebp-#184]
  fmulp st(3)
  fld	DWORD PTR [ebp-#188]
  fmulp st(1)
  fsubp st(2)
  fxch	st(2)
  fmulp st(1)
  faddp st(1)
  fld	DWORD PTR [LC7]
  fcomip st(1)
  fstp	st(0)
  jbe	L43
  inc	DWORD PTR [geometry_errors]
L43:
  cmp	edx, #2
  mov	ecx, #24
  mov	eax, #48
  cmovne	ecx, eax
  xor	edx, edx
L50:
  xor	eax, eax
  lea	esi, [ebx+edx]
L49:
  fld	DWORD PTR [esi+eax*#4]
  fld	DWORD PTR [state+#72+eax*#4]
  fcomip st(1)
  jbe	L72
  fstp	DWORD PTR [state+#72+eax*#4]
  jmp	L45
L72:
  fstp	st(0)
L45:
  fld	DWORD PTR [state+#84+eax*#4]
  fld	DWORD PTR [esi+eax*#4]
  fcomi st(1)
  fstp	st(1)
  jbe	L73
  fstp	DWORD PTR [state+#84+eax*#4]
  jmp	L47
L73:
  fstp	st(0)
L47:
  inc	eax
  cmp	eax, #3
  jne	L49
  add	edx, #12
  cmp	edx, ecx
  jne	L50
  inc	DWORD PTR [state+#68]
  jmp	L41
L42:
  cmp	DWORD PTR [state+#52], #3199
  ja	L52
  mov	esi, ecx
  mov	ecx, DWORD PTR [game_draw_cursor]
  add	ecx, #262320
  cmp	DWORD PTR [game_draw_end], ecx
  jnb	L53
L52:
  inc	DWORD PTR [state+#60]
  jmp	L41
L53:
  lea	edi, [ebp-#172]
  mov	ecx, #40
  cmp	edx, #2
  rep stosd
  mov	edi, game_line_vtable
  mov	ecx, game_rect_vtable
  mov	DWORD PTR [ebp-#168], #2
  cmove	ecx, edi
  mov	edi, #48
  mov	DWORD PTR [ebp-#164], #2
  mov	DWORD PTR [ebp-#160], #1
  mov	DWORD PTR [ebp-#176], ecx
  mov	ecx, DWORD PTR [game_draw_matrix]
  mov	DWORD PTR [ebp-#152], #1
  mov	DWORD PTR [ebp-#144], ecx
  mov	ecx, DWORD PTR [game_draw_matrix+#4]
  mov	DWORD PTR [ebp-#128], #1
  mov	DWORD PTR [ebp-#140], ecx
  mov	ecx, DWORD PTR [game_draw_matrix+#8]
  mov	DWORD PTR [ebp-#136], ecx
  mov	ecx, DWORD PTR [game_draw_matrix+#12]
  mov	DWORD PTR [ebp-#132], ecx
  mov	ecx, #24
  cmovne	ecx, edi
L55:
  fld	DWORD PTR [ebx+eax]
  fstp	DWORD PTR [ebp-#124+eax]
  fld	DWORD PTR [ebx+#4+eax]
  fstp	DWORD PTR [ebp-#120+eax]
  fld	DWORD PTR [ebx+#8+eax]
  fstp	DWORD PTR [ebp-#116+eax]
  add	eax, #12
  cmp	eax, ecx
  jne	L55
  fld1
  lea	ecx, [ebp-#100]
  lea	eax, [ebp-#76]
  cmp	edx, #2
  fldz
  cmove	eax, ecx
  test	esi, esi
  fld	st(0)
  fcmove st(2)
  fxch	st(2)
  fcmove st(1)
  fstp	st(1)
  fld	DWORD PTR [Alpha]
  fxch	st(2)
  sal	edx, #4
  add	edx, eax
  jmp	L58
L74:
  fxch	st(1)
L58:
  fst	DWORD PTR [eax+#4]
  fxch	st(1)
  fst	DWORD PTR [eax+#8]
  mov	DWORD PTR [eax], 0x00000000
  fld	st(2)
  fstp	DWORD PTR [eax+#12]
  add	eax, #16
  cmp	edx, eax
  jne	L74
  fstp	st(0)
  fstp	st(0)
  fstp	st(0)
  lea	eax, [ebp-#176]
  push	eax
  call	submit
  inc	DWORD PTR [state+#52]
  pop	eax
L41:
  lea	esp, [ebp-#12]
  pop	ebx
  pop	esi
  pop	edi
  pop	ebp
  ret

// Perimeter-order corners: RectPC triangulates (0,1,2) and (0,2,3).
quad:
  push	ebp
  mov	ebp, esp
  push	edi
  push	esi
  lea	edi, [ebp-#56]
  lea	esi, [ebp-#68]
  sub	esp, #60
  mov	DWORD PTR [ebp-#68], eax
  lea	eax, [ebp-#56]
  mov	DWORD PTR [ebp-#64], edx
  mov	edx, #4
  mov	DWORD PTR [ebp-#60], ecx
  mov	ecx, #3
  rep movsd
  lea	edi, [ebp-#44]
  lea	esi, [ebp+#8]
  mov	ecx, #3
  rep movsd
  lea	edi, [ebp-#32]
  lea	esi, [ebp+#20]
  mov	ecx, #3
  rep movsd
  lea	edi, [ebp-#20]
  lea	esi, [ebp+#32]
  mov	ecx, #3
  rep movsd
  push	#0
  mov	ecx, DWORD PTR [ebp+#44]
  call	emit
  pop	eax
  lea	esp, [ebp-#8]
  pop	esi
  pop	edi
  pop	ebp
  ret

// Submit a two-point outline, retaining native XYZ order.
line:
  push	ebp
  mov	ebp, esp
  push	edi
  push	esi
  lea	edi, [ebp-#32]
  lea	esi, [ebp-#44]
  sub	esp, #36
  mov	DWORD PTR [ebp-#44], eax
  lea	eax, [ebp-#32]
  mov	DWORD PTR [ebp-#40], edx
  mov	edx, #2
  mov	DWORD PTR [ebp-#36], ecx
  mov	ecx, #3
  rep movsd
  lea	edi, [ebp-#20]
  lea	esi, [ebp+#8]
  mov	ecx, #3
  rep movsd
  push	#1
  mov	ecx, DWORD PTR [ebp+#20]
  call	emit
  pop	eax
  lea	esp, [ebp-#8]
  pop	esi
  pop	edi
  pop	ebp
  ret
  align #4
LC0:
  db #0,#1,#3,#2
  db #4,#5,#7,#6
  db #0,#1,#5,#4
  db #2,#3,#7,#6
  db #0,#2,#6,#4
  db #1,#3,#7,#5

// Shapes: box, cylinder, grounded XZ disc, annulus, sphere.
// Hurt bones use boxes; annulus radial endpoints are unscaled.
draw_volume_mesh:
  push	ebp
  mov	ebp, esp
  push	edi
  push	esi
  push	ebx
  mov	ebx, eax
  sub	esp, #256
  mov	eax, DWORD PTR [eax+#24]
  mov	DWORD PTR [ebp-#232], edx
  test	eax, eax
  jne	L80
  fld	DWORD PTR [ebx]
  fld	DWORD PTR [ebx+#4]
  lea	edx, [ebp-#108]
  fstp	DWORD PTR [ebp-#236]
  fld	DWORD PTR [ebx+#8]
  fstp	DWORD PTR [ebp-#240]
  fld	DWORD PTR [ebx+#12]
  fld	st(0)
  fchs
  fld	DWORD PTR [ebx+#16]
  fld	st(0)
  fchs
L84:
  test	al, #4
  fld	st(3)
  fcmove st(3)
  test	al, #2
  fld	st(2)
  fcmove st(2)
  test	al, #1
  fld	st(5)
  fcmove st(5)
  inc	eax
  add	edx, #12
  fadd	st, st(7)
  fstp	DWORD PTR [edx-#12]
  fadd	DWORD PTR [ebp-#236]
  fstp	DWORD PTR [edx-#8]
  fadd	DWORD PTR [ebp-#240]
  fstp	DWORD PTR [edx-#4]
  cmp	eax, #8
  jne	L84
  fstp	st(0)
  fstp	st(0)
  fstp	st(0)
  fstp	st(0)
  fstp	st(0)
  lea	edi, [ebp-#132]
  mov	esi, LC0
  mov	ecx, #6
  rep movsd
  lea	ebx, [ebp-#132]
L85:
  movzx	eax, BYTE PTR [ebx]
  mov	ecx, #3
  add	ebx, #4
  imul	edx, eax, #12
  lea	eax, [ebp-#108+edx]
  mov	DWORD PTR [ebp-#236], eax
  push	DWORD PTR [ebp-#232]
  movzx	eax, BYTE PTR [ebx-#1]
  imul	eax, eax, #12
  sub	esp, #12
  mov	edi, esp
  sub	esp, #12
  lea	esi, [ebp-#108+eax]
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  sub	esp, #12
  movzx	eax, BYTE PTR [ebx-#2]
  imul	eax, eax, #12
  lea	esi, [ebp-#108+eax]
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  movzx	eax, BYTE PTR [ebx-#3]
  imul	eax, eax, #12
  lea	esi, [ebp-#108+eax]
  rep movsd
  mov	eax, DWORD PTR [ebp-#108+edx]
  mov	edi, DWORD PTR [ebp-#236]
  mov	edx, DWORD PTR [ebp-#236]
  mov	edx, DWORD PTR [edx+#4]
  mov	ecx, DWORD PTR [edi+#8]
  call	quad
  lea	eax, [ebp-#108]
  add	esp, #40
  cmp	ebx, eax
  jne	L85
  xor	ebx, ebx
L86:
  mov	DWORD PTR [ebp-#244], #3
  mov	DWORD PTR [ebp-#236], #1
L88:
  test	DWORD PTR [ebp-#236], ebx
  jne	L87
  imul	edx, ebx, #12
  mov	ecx, #3
  lea	eax, [ebp-#108+edx]
  mov	DWORD PTR [ebp-#240], eax
  mov	eax, DWORD PTR [ebp-#236]
  push	DWORD PTR [ebp-#232]
  or	eax, ebx
  imul	eax, eax, #12
  sub	esp, #12
  mov	edi, esp
  lea	esi, [ebp-#108+eax]
  rep movsd
  mov	eax, DWORD PTR [ebp-#108+edx]
  mov	edi, DWORD PTR [ebp-#240]
  mov	edx, DWORD PTR [ebp-#240]
  mov	edx, DWORD PTR [edx+#4]
  mov	ecx, DWORD PTR [edi+#8]
  call	line
  add	esp, #16
L87:
  sal	DWORD PTR [ebp-#236],#1
  dec	DWORD PTR [ebp-#244]
  jne	L88
  inc	ebx
  cmp	ebx, #8
  jne	L86
  jmp	L79
L80:
  cmp	eax, #4
  jne	L123
  mov	DWORD PTR [ebp-#248], 0x00000000
  xor	eax, eax
  mov	DWORD PTR [ebp-#244], 0xbf800000
  mov	DWORD PTR [ebp-#240], eax
L91:
  inc	DWORD PTR [ebp-#240]
  mov	eax, DWORD PTR [ebp-#240]
  xor	edi, edi
  mov	DWORD PTR [ebp-#236], edi
  fld	DWORD PTR [lats+#0+eax*#4]
  fld	DWORD PTR [latc+#0+eax*#4]
  jmp	L93
L125:
  fxch	st(1)
L93:
  fld	DWORD PTR [ebx+#12]
  lea	esi, [ebp-#108]
  mov	edx, ebx
  fld	st(0)
  fmul	st, st(3)
  fxch	st(3)
  fstp	DWORD PTR [ebp-#268]
  fld	st(0)
  fstp	DWORD PTR [ebp-#264]
  fmul	st, st(1)
  fxch	st(1)
  fstp	DWORD PTR [ebp-#260]
  fxch	st(1)
  push	eax
  push	eax
  mov	ecx, DWORD PTR [ebp-#236]
  mov	eax, esi
  fst	DWORD PTR [esp+#4]
  fstp	DWORD PTR [ebp-#256]
  fst	DWORD PTR [esp]
  fstp	DWORD PTR [ebp-#252]
  call	ringpoint
  mov	edi, DWORD PTR [ebp-#236]
  fld	DWORD PTR [ebp-#256]
  inc	DWORD PTR [ebp-#236]
  push	eax
  push	eax
  mov	ecx, DWORD PTR [ebp-#236]
  lea	eax, [ebp-#132]
  fstp	DWORD PTR [esp+#4]
  fld	DWORD PTR [ebp-#252]
  fstp	DWORD PTR [esp]
  call	ringpoint
  fld	DWORD PTR [ebp-#244]
  fld	DWORD PTR [ebp-#264]
  fmul	st(1), st
  fmul	DWORD PTR [ebp-#248]
  fxch	st(1)
  push	eax
  push	eax
  mov	ecx, DWORD PTR [ebp-#236]
  lea	eax, [ebp-#144]
  fst	DWORD PTR [esp+#4]
  fstp	DWORD PTR [ebp-#256]
  fst	DWORD PTR [esp]
  fstp	DWORD PTR [ebp-#252]
  call	ringpoint
  fld	DWORD PTR [ebp-#256]
  push	ecx
  lea	eax, [ebp-#156]
  push	ecx
  mov	ecx, edi
  fstp	DWORD PTR [esp+#4]
  fld	DWORD PTR [ebp-#252]
  fstp	DWORD PTR [esp]
  call	ringpoint
  add	esp, #32
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  sub	esp, #12
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  lea	esi, [ebp-#132]
  sub	esp, #12
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  lea	esi, [ebp-#144]
  rep movsd
  mov	eax, DWORD PTR [ebp-#156]
  mov	edx, DWORD PTR [ebp-#152]
  mov	ecx, DWORD PTR [ebp-#148]
  call	quad
  add	esp, #40
  cmp	DWORD PTR [ebp-#236], #12
  fld	DWORD PTR [ebp-#260]
  fld	DWORD PTR [ebp-#268]
  jne	L125
  cmp	DWORD PTR [ebp-#240], #6
  je	L109
  fxch	st(1)
  fstp	DWORD PTR [ebp-#248]
  fstp	DWORD PTR [ebp-#244]
  jmp	L91
L109:
  fstp	st(0)
  fstp	st(0)
  xor	esi, esi
  mov	DWORD PTR [ebp-#236], esi
L94:
  mov	edi, DWORD PTR [ebp-#236]
  fld	DWORD PTR [ebx+#12]
  lea	esi, [ebp-#168]
  mov	edx, ebx
  inc	DWORD PTR [ebp-#236]
  push	0x00000000
  push	eax
  mov	ecx, DWORD PTR [ebp-#236]
  mov	eax, esi
  fst	DWORD PTR [esp]
  fstp	DWORD PTR [ebp-#240]
  call	ringpoint
  push	0x00000000
  fld	DWORD PTR [ebp-#240]
  lea	eax, [ebp-#180]
  push	ecx
  mov	ecx, edi
  fstp	DWORD PTR [esp]
  call	ringpoint
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  rep movsd
  lea	esi, [ebp-#192]
  mov	eax, DWORD PTR [ebp-#180]
  mov	edx, DWORD PTR [ebp-#176]
  mov	ecx, DWORD PTR [ebp-#172]
  call	line
  fld	DWORD PTR [ebx+#12]
  add	esp, #32
  mov	ecx, #3
  mov	eax, DWORD PTR [ebp-#236]
  fld	DWORD PTR [sn+#0+eax*#4]
  fld	DWORD PTR [circle_cos+#0+eax*#4]
  fld	DWORD PTR [ebx]
  fld	DWORD PTR [ebx+#4]
  fldz
  fadd	DWORD PTR [ebx+#8]
  fld	st(5)
  fmul	st, st(4)
  fxch	st(4)
  fstp	DWORD PTR [ebp-#252]
  fxch	st(3)
  fadd	st, st(2)
  fstp	DWORD PTR [ebp-#192]
  fld	st(4)
  fmul	st, st(4)
  fxch	st(4)
  fstp	DWORD PTR [ebp-#248]
  fadd	st(3), st
  fxch	st(3)
  fstp	DWORD PTR [ebp-#188]
  fxch	st(1)
  fst	DWORD PTR [ebp-#184]
  fld	DWORD PTR [sn+-#4+eax*#4]
  fstp	DWORD PTR [ebp-#240]
  fld	DWORD PTR [circle_cos+-#4+eax*#4]
  fld	st(4)
  fmul	st, st(1)
  fxch	st(1)
  fstp	DWORD PTR [ebp-#244]
  faddp st(2)
  fxch	st(1)
  fstp	DWORD PTR [ebp-#204]
  fxch	st(2)
  fmul	DWORD PTR [ebp-#240]
  faddp st(1)
  fstp	DWORD PTR [ebp-#200]
  fstp	DWORD PTR [ebp-#196]
  push	DWORD PTR [ebp-#232]
  sub	esp, #12
  mov	edi, esp
  rep movsd
  lea	esi, [ebp-#216]
  mov	eax, DWORD PTR [ebp-#204]
  mov	edx, DWORD PTR [ebp-#200]
  mov	ecx, DWORD PTR [ebp-#196]
  call	line
  fld	DWORD PTR [ebx+#12]
  mov	ecx, #3
  fldz
  fadd	DWORD PTR [ebx]
  fld	DWORD PTR [ebx+#4]
  fld	DWORD PTR [ebx+#8]
  fxch	st(2)
  fst	DWORD PTR [ebp-#216]
  fld	DWORD PTR [ebp-#252]
  fmul	st, st(4)
  fadd	st, st(2)
  fstp	DWORD PTR [ebp-#212]
  fld	DWORD PTR [ebp-#248]
  fmul	st, st(4)
  fadd	st, st(3)
  fstp	DWORD PTR [ebp-#208]
  fstp	DWORD PTR [ebp-#228]
  fld	DWORD PTR [ebp-#244]
  fmul	st, st(3)
  faddp st(1)
  fstp	DWORD PTR [ebp-#224]
  fld	DWORD PTR [ebp-#240]
  fmulp st(2)
  faddp st(1)
  fstp	DWORD PTR [ebp-#220]
  push	DWORD PTR [ebp-#232]
  sub	esp, #12
  mov	edi, esp
  rep movsd
  mov	eax, DWORD PTR [ebp-#228]
  mov	edx, DWORD PTR [ebp-#224]
  mov	ecx, DWORD PTR [ebp-#220]
  call	line
  add	esp, #32
  cmp	DWORD PTR [ebp-#236], #12
  jne	L94
  jmp	L79
L123:
  cmp	eax, #3
  jne	L95
  fld	DWORD PTR [ebx+#20]
  fstp	DWORD PTR [ebp-#244]
  jmp	L96
L95:
  mov	DWORD PTR [ebp-#244], 0x00000000
  cmp	eax, #2
  je	L110
L96:
  fld	DWORD PTR [ebx+#16]
  fstp	DWORD PTR [ebp-#236]
  jmp	L97
L110:
  mov	DWORD PTR [ebp-#236], 0x00000000
L97:
  fld	DWORD PTR [ebp-#236]
  xor	ecx, ecx
  mov	DWORD PTR [ebp-#240], ecx
  fchs
  fstp	DWORD PTR [ebp-#248]
L104:
  fld	DWORD PTR [ebx+#12]
  lea	eax, [ebp-#204]
  fst	DWORD PTR [ebp-#252]
  push	DWORD PTR [ebp-#248]
  push	edx
  mov	edx, ebx
  mov	ecx, DWORD PTR [ebp-#240]
  fstp	DWORD PTR [esp]
  call	ringpoint
  mov	eax, DWORD PTR [ebp-#240]
  inc	DWORD PTR [ebp-#240]
  mov	ecx, DWORD PTR [ebp-#240]
  mov	DWORD PTR [ebp-#256], eax
  lea	eax, [ebp-#192]
  push	DWORD PTR [ebp-#248]
  push	DWORD PTR [ebp-#252]
  call	ringpoint
  push	DWORD PTR [ebp-#236]
  mov	ecx, DWORD PTR [ebp-#240]
  lea	eax, [ebp-#180]
  push	DWORD PTR [ebp-#252]
  call	ringpoint
  push	DWORD PTR [ebp-#236]
  mov	ecx, DWORD PTR [ebp-#256]
  lea	eax, [ebp-#168]
  push	DWORD PTR [ebp-#252]
  call	ringpoint
  add	esp, #32
  push	DWORD PTR [ebp-#248]
  mov	ecx, DWORD PTR [ebp-#256]
  push	DWORD PTR [ebp-#244]
  lea	eax, [ebp-#156]
  call	ringpoint
  push	DWORD PTR [ebp-#248]
  mov	ecx, DWORD PTR [ebp-#240]
  lea	eax, [ebp-#144]
  push	DWORD PTR [ebp-#244]
  call	ringpoint
  push	DWORD PTR [ebp-#236]
  mov	ecx, DWORD PTR [ebp-#240]
  lea	eax, [ebp-#132]
  push	DWORD PTR [ebp-#244]
  call	ringpoint
  push	DWORD PTR [ebp-#236]
  mov	ecx, DWORD PTR [ebp-#256]
  lea	eax, [ebp-#108]
  push	DWORD PTR [ebp-#244]
  call	ringpoint
  fldz
  fld	DWORD PTR [ebp-#236]
  add	esp, #32
  fcomip st(1)
  fstp	st(0)
  jbe	L98
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  lea	esi, [ebp-#168]
  sub	esp, #12
  mov	edi, esp
  sub	esp, #12
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  lea	esi, [ebp-#180]
  sub	esp, #12
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  lea	esi, [ebp-#192]
  rep movsd
  lea	esi, [ebp-#156]
  mov	eax, DWORD PTR [ebp-#204]
  mov	edx, DWORD PTR [ebp-#200]
  mov	ecx, DWORD PTR [ebp-#196]
  call	quad
  add	esp, #40
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  sub	esp, #12
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  lea	esi, [ebp-#144]
  sub	esp, #12
  rep movsd
  mov	edi, esp
  mov	ecx, #3
  lea	esi, [ebp-#192]
  rep movsd
  lea	esi, [ebp-#192]
  mov	eax, DWORD PTR [ebp-#204]
  mov	edx, DWORD PTR [ebp-#200]
  mov	ecx, DWORD PTR [ebp-#196]
  call	quad
  add	esp, #40
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  rep movsd
  mov	eax, DWORD PTR [ebp-#204]
  mov	edx, DWORD PTR [ebp-#200]
  mov	ecx, DWORD PTR [ebp-#196]
  call	line
  mov	eax, DWORD PTR [ebp-#256]
  mov	ecx, #3
  add	esp, #16
  cdq
  idiv	ecx
  test	edx, edx
  jne	L98
  push	DWORD PTR [ebp-#232]
  lea	esi, [ebp-#168]
  sub	esp, #12
  mov	edi, esp
  rep movsd
  mov	eax, DWORD PTR [ebp-#204]
  mov	edx, DWORD PTR [ebp-#200]
  mov	ecx, DWORD PTR [ebp-#196]
  call	line
  add	esp, #16
L98:
  push	DWORD PTR [ebp-#232]
  lea	esi, [ebp-#108]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  sub	esp, #12
  rep movsd
  mov	edi, esp
  lea	esi, [ebp-#132]
  mov	ecx, #3
  sub	esp, #12
  rep movsd
  mov	edi, esp
  lea	esi, [ebp-#180]
  mov	ecx, #3
  rep movsd
  lea	esi, [ebp-#180]
  mov	eax, DWORD PTR [ebp-#168]
  mov	edx, DWORD PTR [ebp-#164]
  mov	ecx, DWORD PTR [ebp-#160]
  call	quad
  add	esp, #40
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  rep movsd
  mov	eax, DWORD PTR [ebp-#168]
  mov	edx, DWORD PTR [ebp-#164]
  mov	ecx, DWORD PTR [ebp-#160]
  call	line
  fldz
  fld	DWORD PTR [ebp-#244]
  add	esp, #16
  fcomip st(1)
  jbe	L126
  fld	DWORD PTR [ebp-#236]
  fcomip st(1)
  fstp	st(0)
  jbe	L102
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  lea	esi, [ebp-#108]
  sub	esp, #12
  mov	edi, esp
  sub	esp, #12
  rep movsd
  mov	edi, esp
  lea	esi, [ebp-#132]
  mov	ecx, #3
  sub	esp, #12
  rep movsd
  mov	edi, esp
  lea	esi, [ebp-#144]
  mov	ecx, #3
  rep movsd
  lea	esi, [ebp-#144]
  mov	eax, DWORD PTR [ebp-#156]
  mov	edx, DWORD PTR [ebp-#152]
  mov	ecx, DWORD PTR [ebp-#148]
  call	quad
  add	esp, #40
  push	DWORD PTR [ebp-#232]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  rep movsd
  mov	eax, DWORD PTR [ebp-#156]
  mov	edx, DWORD PTR [ebp-#152]
  mov	ecx, DWORD PTR [ebp-#148]
  call	line
  add	esp, #16
L102:
  push	DWORD PTR [ebp-#232]
  lea	esi, [ebp-#132]
  mov	ecx, #3
  sub	esp, #12
  mov	edi, esp
  rep movsd
  mov	eax, DWORD PTR [ebp-#108]
  mov	edx, DWORD PTR [ebp-#104]
  mov	ecx, DWORD PTR [ebp-#100]
  call	line
  add	esp, #16
  jmp	L100
L126:
  fstp	st(0)
L100:
  cmp	DWORD PTR [ebp-#240], #12
  jne	L104
L79:
  lea	esp, [ebp-#12]
  pop	ebx
  pop	esi
  pop	edi
  pop	ebp
  ret

// Clear counts whenever the native battle collision queue is reset.
reset_snapshot:
  xor	eax, eax
  inc	DWORD PTR [state+#56]
  mov	DWORD PTR [state+#36], eax
  mov	DWORD PTR [state+#40], eax
  mov	eax, DWORD PTR [game_battle]
  mov	DWORD PTR [state+#20], eax
  ret

// Resolve the current battle and actors on every capture.
// Bound attack queues to 40 per side, actors to 4 per side, hurt volumes to 128.
// Skip disabled categories. Capture immediately before native collision processing.
capture:
  push	ebp
  mov	ebp, esp
  push	edi
  push	esi
  xor	esi, esi
  push	ebx
  sub	esp, #92
  mov	eax, DWORD PTR [game_battle]
  mov	DWORD PTR [state+#36], esi
  mov	DWORD PTR [state+#40], esi
  mov	DWORD PTR [ebp-#64], eax
  mov	DWORD PTR [state+#20], eax
  test	eax, eax
  je	L128
  cmp	DWORD PTR [state+#4], #0
  je	L128
  mov	eax, DWORD PTR [eax+#37084]
  inc	DWORD PTR [state+#28]
  mov	DWORD PTR [state+#24], eax
  test DWORD PTR [state+#8], 0x7fffffff
  je	L130
  mov	eax, DWORD PTR [ebp-#64]
  xor	ebx, ebx
  mov	DWORD PTR [ebp-#72], ebx
  add	eax, #1421800
  mov	DWORD PTR [ebp-#80], eax
  mov	eax, DWORD PTR [ebp-#64]
  add	eax, #1419244
  mov	DWORD PTR [ebp-#84], eax
L144:
  mov	eax, DWORD PTR [ebp-#80]
  movzx	eax, WORD PTR [eax]
  mov	DWORD PTR [ebp-#68], eax
  cmp	eax, #40
  jbe	L131
  inc	DWORD PTR [state+#48]
  mov	DWORD PTR [ebp-#68], #40
L131:
  xor	ecx, ecx
  mov	ebx, DWORD PTR [ebp-#84]
  mov	DWORD PTR [ebp-#76], ecx
L132:
  mov	edi, DWORD PTR [ebp-#76]
  cmp	DWORD PTR [ebp-#68], edi
  je	L172
  mov	ecx, DWORD PTR [ebx]
  mov	eax, DWORD PTR [ebx+#4]
  test	ecx, ecx
  je	L142
  test	eax, eax
  je	L142
  cmp	DWORD PTR [ecx+#4], #0
  je	L142
  cmp	DWORD PTR [eax+#8], #0
  je	L142
  mov	eax, DWORD PTR [eax+#8]
  movzx	edx, BYTE PTR [eax+#8]
  mov	esi, DWORD PTR [ecx+#4]
  fld	DWORD PTR [esi+#132]
  cmp	edx, #4
  jbe	L136
  fstp	st(0)
  inc	DWORD PTR [state+#44]
  jmp	L135
L136:
  fld	DWORD PTR [ebx+#16]
  mov	edi, DWORD PTR [ebp-#72]
  fstp	DWORD PTR [ebp-#60]
  fld	DWORD PTR [ebx+#20]
  fstp	DWORD PTR [ebp-#56]
  fld	DWORD PTR [ebx+#24]
  fstp	DWORD PTR [ebp-#52]
  fld	DWORD PTR [eax]
  fmul	st, st(1)
  fstp	DWORD PTR [ebp-#48]
  fmul	DWORD PTR [eax+#4]
  mov	DWORD PTR [ebp-#32], ecx
  movzx	ecx, WORD PTR [ebx+#12]
  mov	DWORD PTR [ebp-#40], 0x00000000
  mov	DWORD PTR [ebp-#36], edx
  mov	DWORD PTR [ebp-#28], ecx
  mov	DWORD PTR [ebp-#24], eax
  mov	DWORD PTR [ebp-#20], edi
  mov	DWORD PTR [ebp-#16], #1
  fstp	DWORD PTR [ebp-#44]
  cmp	edx, #3
  jne	L137
  fld	DWORD PTR [eax]
  fld	DWORD PTR [eax+#20]
  fadd	st, st(1)
  fcomi st(1)
  fld	st(1)
  fcmovbe st(1)
  fxch	st(2)
  fcomi st(1)
  fcmovbe st(1)
  fstp	st(1)
  fstp	DWORD PTR [ebp-#48]
  fldz
  fucomi st(1)
  fcmovbe st(1)
  fstp	st(1)
  fstp	DWORD PTR [ebp-#40]
  jmp	L140
L137:
  cmp	edx, #2
  jne	L140
  mov	DWORD PTR [ebp-#56], 0x00000000
  mov	DWORD PTR [ebp-#44], 0x00000000
L140:
  lea	eax, [ebp-#60]
  call	valid
  test	eax, eax
  je	L142
  mov	eax, DWORD PTR [state+#40]
  mov	ecx, #12
  lea	esi, [ebp-#60]
  lea	edx, [eax+#1]
  imul	eax, eax, #48
  mov	DWORD PTR [state+#40], edx
  lea	edi, [state+eax+#96]
  rep movsd
  jmp	L135
L142:
  inc	DWORD PTR [state+#48]
L135:
  inc	DWORD PTR [ebp-#76]
  add	ebx, #32
  jmp	L132
L172:
  add	DWORD PTR [ebp-#80], #2
  add	DWORD PTR [ebp-#84], #1280
  cmp	DWORD PTR [ebp-#72], #1
  je	L130
  mov	DWORD PTR [ebp-#72], #1
  jmp	L144
L130:
  test DWORD PTR [state+#12], 0x7fffffff
  je	L128
  mov	eax, DWORD PTR [ebp-#64]
  xor	edx, edx
  mov	DWORD PTR [ebp-#68], edx
  add	eax, #36956
  mov	DWORD PTR [ebp-#80], eax
L157:
  mov	eax, DWORD PTR [ebp-#64]
  mov	edi, DWORD PTR [ebp-#68]
  movzx	eax, BYTE PTR [eax+#37708+edi]
  cmp	eax, #4
  jbe	L145
  inc	DWORD PTR [state+#48]
  mov	eax, #4
L145:
  mov	edi, DWORD PTR [ebp-#68]
  lea	esi, [#0+edi*#4]
  mov	DWORD PTR [ebp-#100], esi
  mov	esi, DWORD PTR [ebp-#80]
  add	eax, esi
  mov	DWORD PTR [ebp-#76], esi
  mov	DWORD PTR [ebp-#92], eax
L146:
  mov	ebx, DWORD PTR [ebp-#92]
  cmp	DWORD PTR [ebp-#76], ebx
  je	L173
  mov	eax, DWORD PTR [ebp-#76]
  movzx	eax, BYTE PTR [eax]
  cmp	eax, #3
  ja	L171
  add	eax, DWORD PTR [ebp-#100]
  mov	esi, DWORD PTR [ebp-#64]
  imul	eax, eax, #80864
  lea	ebx, [eax+esi]
  mov	eax, DWORD PTR [ebx+#78500]
  mov	DWORD PTR [ebp-#84], eax
  mov	eax, DWORD PTR [ebx+#158916]
  cmp	DWORD PTR [ebp-#84], #0
  mov	DWORD PTR [ebp-#72], eax
  sete	dl
  cmp	DWORD PTR [ebp-#72], #0
  sete	cl
  mov	eax, DWORD PTR [ebx+#81072]
  or	dl, cl
  jne	L148
  test	eax, eax
  je	L148
  cmp	DWORD PTR [eax+#564], #0
  je	L148
  mov	eax, DWORD PTR [eax+#564]
  mov	eax, DWORD PTR [eax+#16]
  mov	DWORD PTR [ebp-#88], eax
  cmp	eax, #256
  ja	L171
  lea	eax, [ebx+#78496]
  xor	edx, edx
  mov	DWORD PTR [ebp-#96], eax
  jmp	L150
L152:
  and	eax, #15
  lea	esi, [ebp-#60]
  imul	eax, eax, #10
  mov	DWORD PTR [ebp-#104], eax
  mov	eax, DWORD PTR [ebp-#84]
  fild	DWORD PTR [ebp-#104]
  fmul	DWORD PTR [eax+#132]
  xor	eax, eax
  mov	DWORD PTR [ebp-#28], edx
  mov	DWORD PTR [ebp-#36], eax
  mov	eax, DWORD PTR [ebp-#96]
  mov	DWORD PTR [ebp-#60], 0x00000000
  mov	DWORD PTR [ebp-#32], eax
  mov	eax, DWORD PTR [ebp-#72]
  fst	DWORD PTR [ebp-#48]
  mov	DWORD PTR [ebp-#24], eax
  mov	eax, DWORD PTR [ebp-#68]
  fstp	DWORD PTR [ebp-#44]
  mov	DWORD PTR [ebp-#56], 0x00000000
  mov	DWORD PTR [ebp-#52], 0x00000000
  mov	DWORD PTR [ebp-#40], 0x00000000
  mov	DWORD PTR [ebp-#20], eax
  mov	al, BYTE PTR [ebx+#83393]
  and	eax, -#32
  cmp	al, #64
  seta	al
  movzx	eax, al
  mov	DWORD PTR [ebp-#16], eax
  lea	eax, [ebx+#79216]
  push	#0
  push	edx
  mov	DWORD PTR [ebp-#104], edx
  push	eax
  push	esi
  call	game_bone_position
  mov	eax, esi
  call	valid
  add	esp, #16
  mov	edx, DWORD PTR [ebp-#104]
  test	eax, eax
  je	L153
  mov	eax, DWORD PTR [state+#36]
  lea	ecx, [eax+#1]
  add	eax, #80
  imul	eax, eax, #48
  mov	DWORD PTR [state+#36], ecx
  mov	ecx, #12
  lea	edi, [state+eax+#96]
  rep movsd
L154:
  add	DWORD PTR [ebp-#72], #2
  inc	edx
L150:
  cmp	edx, DWORD PTR [ebp-#88]
  je	L148
  mov	eax, DWORD PTR [ebp-#72]
  mov	ax, WORD PTR [eax]
  test	al, #32
  je	L154
  cmp	DWORD PTR [state+#36], #127
  jbe	L152
L171:
  inc	DWORD PTR [state+#48]
  jmp	L148
L153:
  inc	DWORD PTR [state+#48]
  jmp	L154
L148:
  inc	DWORD PTR [ebp-#76]
  jmp	L146
L173:
  add	DWORD PTR [ebp-#80], #8
  cmp	DWORD PTR [ebp-#68], #1
  je	L128
  mov	DWORD PTR [ebp-#68], #1
  jmp	L157
L128:
  lea	esp, [ebp-#12]
  pop	ebx
  pop	esi
  pop	edi
  pop	ebp
  ret
draw_volume:
  push	ebp
  mov	ebp, esp
  push	esi
  push	ebx
  mov	eax, DWORD PTR [ebp+#8]
  call	valid
  test	eax, eax
  je	L174
  mov	edx, DWORD PTR [ebp+#12]
  mov	eax, DWORD PTR [ebp+#8]
  pop	ebx
  pop	esi
  pop	ebp
  jmp	draw_volume_mesh
L174:
  pop	ebx
  pop	esi
  pop	ebp
  ret

// Render only a snapshot belonging to the current non-null battle.
// Draw blue hurtboxes first, then green hitboxes; no trails or render-time bones.
render:
  xor	eax, eax
  inc	DWORD PTR [state+#32]
  mov	DWORD PTR [state+#52], eax
  mov	eax, DWORD PTR [game_battle]
  cmp	DWORD PTR [state+#4], #0
  je	L187
  test	eax, eax
  je	L187
  cmp	DWORD PTR [state+#20], eax
  jne	L187
  push	ebp
  mov	ebp, esp
  push	esi
  push	ebx
  test DWORD PTR [state+#12], 0x7fffffff
  je	L181
  mov	esi, state+#3936
  xor	ebx, ebx
  jmp	L182
L181:
  test DWORD PTR [state+#8], 0x7fffffff
  je	L177
  mov	esi, state+#96
  xor	ebx, ebx
  jmp	L183
L182:
  cmp	ebx, DWORD PTR [state+#36]
  jnb	L181
  push	#1
  inc	ebx
  push	esi
  add	esi, #48
  call	draw_volume
  pop	ecx
  pop	eax
  jmp	L182
L183:
  cmp	ebx, DWORD PTR [state+#40]
  jnb	L177
  push	#0
  inc	ebx
  push	esi
  add	esi, #48
  call	draw_volume
  pop	eax
  pop	edx
  jmp	L183
L177:
  lea	esp, [ebp-#8]
  pop	ebx
  pop	esi
  pop	ebp
  ret
L187:
  ret

// Offline harness entry: asymmetric center and known bounds for all five shapes.
geometry_test:
  push	ebp
  xor	ecx, ecx
  xor	edx, edx
  mov	ebp, esp
  sub	esp, #48
  fld	DWORD PTR [LC11]
  mov	DWORD PTR [state+#64], #1
  mov	eax, DWORD PTR [ebp+#8]
  mov	DWORD PTR [state+#68], edx
  mov	DWORD PTR [geometry_errors], edx
  fst	DWORD PTR [state+#72]
  fld	DWORD PTR [LC12]
  mov	DWORD PTR [ebp-#48], 0x42c80000
  mov	DWORD PTR [ebp-#44], 0x43480000
  fst	DWORD PTR [state+#84]
  fxch	st(1)
  fst	DWORD PTR [state+#76]
  fxch	st(1)
  fst	DWORD PTR [state+#88]
  fxch	st(1)
  fstp	DWORD PTR [state+#80]
  mov	DWORD PTR [ebp-#40], 0x43960000
  mov	DWORD PTR [ebp-#36], 0x42700000
  mov	DWORD PTR [ebp-#32], 0x42200000
  mov	DWORD PTR [ebp-#28], 0x41a00000
  mov	DWORD PTR [ebp-#24], eax
  mov	DWORD PTR [ebp-#20], ecx
  mov	DWORD PTR [ebp-#16], ecx
  mov	DWORD PTR [ebp-#12], ecx
  mov	DWORD PTR [ebp-#8], ecx
  mov	DWORD PTR [ebp-#4], #1
  fstp	DWORD PTR [state+#92]
  cmp	eax, #2
  jne	L191
  mov	DWORD PTR [ebp-#44], 0x00000000
  mov	DWORD PTR [ebp-#32], 0x00000000
L191:
  lea	eax, [ebp-#48]
  push	#0
  push	eax
  call	draw_volume
  xor	eax, eax
  mov	DWORD PTR [state+#64], eax
  mov	eax, DWORD PTR [state+#68]
  leave
  ret
  align #4
lats:
  dd	-#1082130432
  dd	-#1084378153
  dd	-#1090519040
  dd	#0
  dd	#1056964608
  dd	#1063105495
  dd	#1065353216
  align #4
latc:
  dd	#0
  dd	#1056964608
  dd	#1063105495
  dd	#1065353216
  dd	#1063105495
  dd	#1056964608
  dd	#0
  align #32
sn:
  dd	#0
  dd	#1056964608
  dd	#1063105495
  dd	#1065353216
  dd	#1063105495
  dd	#1056964608
  dd	#0
  dd	-#1090519040
  dd	-#1084378153
  dd	-#1082130432
  dd	-#1084378153
  dd	-#1090519040
  dd	#0
  align #32
circle_cos:
  dd	#1065353216
  dd	#1063105495
  dd	#1056964608
  dd	#0
  dd	-#1090519040
  dd	-#1084378153
  dd	-#1082130432
  dd	-#1084378153
  dd	-#1090519040
  dd	#0
  dd	#1056964608
  dd	#1063105495
  dd	#1065353216
  align #4
LC1:
  dd	-#887581056
  align #4
LC2:
  dd	#1259902592
  align #4
LC5:
  dd	#1203982336
  align #4
LC7:
  dd	-#1165815185
  align #4
LC11:
  dd	#1232348160
  align #4
LC12:
  dd	-#915135488

overlay_data:
  align #4
geometry_errors:
  db #0,#0,#0,#0
  align #32

// State layout: magic, enabled, HitboxesFlag, HurtboxesFlag, reserved;
// battle, tick, captures, renders, hurt/attack counts, diagnostics, test state;
// bounds[6], then 80 attack and 128 hurt Volume records (48 bytes each).
// INI flags are float32 0/1 written by the loader; sign-masked zero tests handle both +0.0 and -0.0.
// Unspecified allocation bytes, including all snapshots, start at zero.
state:
  dd	#1212307505
  dd	#1
HitboxesFlag:
  dd	#0
HurtboxesFlag:
  dd	#0
  dd	#0 // former per-hurtbox alpha; keep snapshot offsets stable

[DISABLE]
TOS.exe+0x5ee4f:
  db e8 7c 4a 00 00
TOS.exe+0x5f0c4:
  db e8 e7 27 00 00
TOS.exe+0x5ed79:
  db 89 87 e8 b1 15 00
dealloc(overlay_code)
dealloc(overlay_data)
