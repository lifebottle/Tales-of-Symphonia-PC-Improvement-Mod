// Experimental Start-button loader for six retained debug maps.
// Port of the tested 2026-09-30-v1 memory snapshot; this ASM is authoritative.
// Package registrations are built lazily from a fingerprinted native registry.
// Mutable buffers are RW; code and static registration templates are RX.
// State (RW dwords): +04 enabled, +08 open, +0C selection, +10 frames,
// +14 opens, +18 warps, +1C last map, +20 pending, +24 test edges (zero),
// +2C eligibility, +38 translated-input ownership, +44 error, +48 load frames,
// +4C load tracking, +50 recoveries, +58 scenery fallback enabled,
// +60 previous raw keys, +64 hardware snapshot, +68 consume until release,
// +70 missing skits, +74 last missing skit, +78 notice lifetime.
// Error 7 means the live PKKP registry did not match the supported fingerprint.
[ENABLE]
alloc(mapmenu_code,4000)
alloc(mapmenu_data,CB000)
alloc(registry_added,1000)
define(game_rect,TOS.exe+134770)
define(game_change_map,TOS.exe+1646E0)
define(game_package_lookup,TOS.exe+198740)
define(game_input_ready,TOS.exe+4A9086)
define(game_player_input,TOS.exe+4AD7AD)
define(game_destination,TOS.exe+4CF124)
define(game_width,TOS.exe+518610)
define(game_height,TOS.exe+518614)
define(game_submode,TOS.exe+6D3E2A)
define(game_mode,TOS.exe+6D3F64)
define(game_state,TOS.exe+6D3F68)
define(game_pad_pointers,TOS.exe+71488C)
define(game_skit_id,TOS.exe+71862C)
define(game_skit_name,TOS.exe+718634)
define(game_input,TOS.exe+7193B8)
define(game_input_end,TOS.exe+719428)
define(game_registry,TOS.exe+7297F8)
define(game_cutscene,TOS.exe+1830C88)
define(game_fade,TOS.exe+1830CB8)
define(game_loading,TOS.exe+19780E4)
define(game_hardware_minus_one,TOS.exe+19EA6CF)
define(game_hardware,TOS.exe+19EA6D0)
define(menu_site,TOS.exe+17846C)
define(model_site,TOS.exe+C7394)
define(skit_site,TOS.exe+1550F8)
define(otumoo_site,TOS.exe+16E595)
define(testmap_name,TOS.exe+472B7C)
define(game_main,TOS.exe+C3720)
define(native_model,TOS.exe+18A7E0)
define(skit_continue,TOS.exe+1550FF)
define(skit_cancel,TOS.exe+155516)
define(game_file_exists,TOS.exe+1AAAE0)
define(game_text,TOS.exe+132250)
define(native_load,TOS.exe+1831C0)
define(game_skit_exit,TOS.exe+183C2E4)
assert(TOS.exe+17846C,e8 af b2 f4 ff)
assert(TOS.exe+C7394,e8 47 34 0c 00)
assert(TOS.exe+1550F8,f6 05 64 3f ad 00 80)
assert(TOS.exe+16E595,e8 26 4c 01 00)
assert(TOS.exe+472B7C,5f 61 6e 61 62 75 6b 69 2e 70 61 63 00)
assert(TOS.exe+C3720,55 8b ec 6a ff 68 43 46 6f 00 64 a1 00 00 00 00)
assert(TOS.exe+134770,55 8b ec 56 6a 01 e8 05 d6 ff ff 83 c4 04 68 34)
assert(TOS.exe+132250,55 8b ec 83 e4 f8 83 ec 0c 53 56 8b f0 0f b7 45)
assert(TOS.exe+1646E0,55 8b ec 83 05 d8 c3 c3 01 02 53 56 8b 75 08 8b 86 44 08 00 00 57 8b bc 86 34 08 00 00 bb)
assert(TOS.exe+198740,55 8b ec 81 ec 14 01 00 00 a1 c4 8d 8a 00 33 c5)
assert(TOS.exe+1AAAE0,55 8b ec 51 53 8b 5d 08 56 be c0 78 db 01 8b ff)
assert(TOS.exe+18A7E0,55 8b ec 83 e4 f8 6a ff 68 2b 39 6f 00 64 a1 00)
assert(TOS.exe+1831C0,55 8b ec 83 e4 f8 6a ff 68 e2 29 6f 00 64 a1 00)
assert(TOS.exe+1550FF,0f 85 56 02 00 00 8b 35)
assert(TOS.exe+155516,0f b6 05 ee 85 b1 00 e8)
assert(TOS.exe+16E350,55 8b ec 83 e4 f8 51 53 8b 5d 08 8b 83 44 08 00 00 56 57 8b bc 83 40 08 00 00 8b 84 83 3c)
menu_site:
call menu_hook
model_site:
call model_hook
skit_site:
jmp skit_hook
nop #2
otumoo_site:
call otumoo_hook
testmap_name:
db "testmap.pac",00,00
mapmenu_code:
// Wrap Game_MainUpdate; capture input once and draw after native work.
menu_hook:
pushfd
pushad
mov ebp,esp
sub esp,#528
and esp,-#16
fxsave [esp]
fninit
cld
call before_update
fxrstor [esp]
mov esp,ebp
popad
popfd
call game_main
pushfd
pushad
mov ebp,esp
sub esp,#528
and esp,-#16
fxsave [esp]
fninit
cld
call after_update
fxrstor [esp]
mov esp,ebp
popad
popfd
ret
// Replace only the EDX model-name argument; retain native resource ownership.
model_hook:
pushfd
pushad
mov ebp,esp
sub esp,#528
and esp,-#16
fxsave [esp]
fninit
cld
push edx
call model_replacement
add esp,#4
mov [ebp+#20],eax
fxrstor [esp]
mov esp,ebp
popad
popfd
jmp native_model
skit_hook:
pushfd
pushad
mov ebp,esp
sub esp,#528
and esp,-#16
fxsave [esp]
fninit
cld
call skit_available
test eax,eax
jz missing_skit
fxrstor [esp]
mov esp,ebp
popad
popfd
test byte ptr [game_mode],80
jmp skit_continue
missing_skit:
fxrstor [esp]
mov esp,ebp
popad
popfd
mov ebx,#1
mov dword ptr [game_skit_exit],#1
jmp skit_cancel
// Otumoo alone can pass an empty resource slot as a filename.
otumoo_hook:
pushfd
push edx
mov edx,[game_state]
cmp dword ptr [edx+#4480],#541
jne otumoo_original
cmp dword ptr [ebx+844],#3
jne otumoo_original
mov edx,[ebx+84C]
cmp edx,FFEE0000
jne otumoo_original
pop edx
popfd
mov eax,FFFFFFFF
ret #8
otumoo_original:
pop edx
popfd
jmp native_load
file_exists:
push ebp
mov ebp,esp
push edi
mov edi,[ebp+#12]
push dword ptr [ebp+#8]
mov eax,game_file_exists
call eax
add esp,#4
movzx eax,al
pop edi
pop ebp
ret
draw_text:
push ebp
mov ebp,esp
push dword ptr [ebp+#32]
push dword ptr [ebp+#28]
push dword ptr [ebp+#24]
push dword ptr [ebp+#20]
push dword ptr [ebp+#16]
push dword ptr [ebp+#12]
mov eax,[ebp+#8]
mov edx,game_text
call edx
add esp,#24
pop ebp
ret
// Suppress hardware input before native code regenerates translated input.
mask_inputs:
push	ebp
mov	ebp, esp
push	edi
push	esi
push	ebx
cmp	DWORD PTR [state+#100], #0
jne	L2
xor	eax, eax
L4:
imul	edi, eax, #88
xor	edx, edx
imul	ebx, eax, #72
L3:
mov	cl, BYTE PTR [edx+game_hardware+edi]
mov	BYTE PTR [edx+game_hardware+edi], #0
mov	BYTE PTR [hardware_copy+ebx+edx], cl
inc	edx
cmp	edx, #72
jne	L3
inc	eax
cmp	eax, #4
jne	L4
mov	DWORD PTR [state+#100], #1
L2:
mov	eax, game_input
L5:
mov	BYTE PTR [eax], #0
inc	eax
cmp	eax, game_input_end
jne	L5
xor	edx, edx
L11:
mov	eax, DWORD PTR [game_pad_pointers+edx*#4]
xor	ecx, ecx
L6:
cmp	ecx, edx
je	L23
cmp	DWORD PTR [pad_ptr+#0+ecx*#4], eax
jne	L7
xor	eax, eax
L7:
inc	ecx
jmp	L6
L23:
mov	DWORD PTR [pad_ptr+#0+edx*#4], eax
test	eax, eax
je	L9
lea	ecx, [eax+#8]
add	eax, #40
L10:
mov	BYTE PTR [ecx], #0
inc	ecx
cmp	ecx, eax
jne	L10
L9:
inc	edx
cmp	edx, #4
jne	L11
mov	DWORD PTR [state+#56], #1
pop	ebx
inc	DWORD PTR [state+#108]
pop	esi
pop	edi
pop	ebp
ret
// Wait for the native registry; validate then build the portable extension.
ensure_registry:
mov	eax, DWORD PTR [game_registry]
cmp	eax, registry_copy
je	L48
test	eax, eax
je	L49
cmp	eax, DWORD PTR [rejected_registry]
je	L49
push	ebp
mov	ebp, esp
push	esi
push	ebx
cmp	DWORD PTR [eax], #1347111760
jne	L27
cmp	DWORD PTR [eax+#4], #16
jne	L27
cmp	DWORD PTR [eax+#8], #4751
jne	L27
mov	ecx, DWORD PTR [eax+#12]
test	ecx, ecx
jne	L27
cmp	DWORD PTR [eax+#16], #19024
jne	L27
xor	ebx, ebx
mov	esi, -#2128831035
L28:
movzx	edx, BYTE PTR [eax+ebx]
inc	ebx
xor	edx, esi
imul	esi, edx, #16777619
cmp	ebx, #824256
jne	L28
cmp	edx, -#1897183923
jne	L27
xor	edx, edx
L29:
mov	bl, BYTE PTR [eax+edx]
inc	edx
mov	BYTE PTR [registry_copy+edx-#1], bl
cmp	edx, #19024
jne	L29
L30:
mov	bl, BYTE PTR [eax+edx]
inc	edx
mov	BYTE PTR [registry_copy+edx+#47], bl
cmp	edx, #824256
jne	L30
mov	ebx, registry_copy
lea	edx, [eax+#16]
lea	esi, [eax+#19020]
mov	DWORD PTR [registry_copy+#8], #4763
sub	ebx, eax
L31:
mov	eax, DWORD PTR [edx]
add	eax, #48
mov	DWORD PTR [ebx+edx], eax
add	edx, #4
cmp	esi, edx
jne	L31
xor	eax, eax
L32:
mov	edx, DWORD PTR [registry_offsets+eax]
add	eax, #4
mov	DWORD PTR [registry_copy+eax+#19016], edx
cmp	eax, #48
jne	L32
L33:
mov	al, BYTE PTR [registry_added+ecx]
inc	ecx
mov	BYTE PTR [registry_copy+ecx+#824303], al
cmp	ecx, #3568
jne	L33
mov	DWORD PTR [game_registry], registry_copy
mov	eax, #1
jmp	L24
L27:
mov	DWORD PTR [state+#68], #7
mov	DWORD PTR [rejected_registry], eax
xor	eax, eax
L24:
pop	ebx
pop	esi
pop	ebp
ret
L48:
mov	eax, #1
ret
L49:
xor	eax, eax
ret
LC0:
db "Missing skit: ",00
// Check the archive before allowing a skit selector to load an absent file.
skit_available:
push	ebp
mov	ebp, esp
push	esi
push	ebx
mov	ebx, DWORD PTR [game_mode]
and	ebx, #128
jne	L54
mov	esi, DWORD PTR [game_skit_name]
test	esi, esi
jne	L65
mov	BYTE PTR [skit_basename], #0
jmp	L56
L65:
xor	eax, eax
L55:
lea	ecx, [esi+eax]
mov	dl, BYTE PTR [ecx]
test	dl, dl
je	L57
cmp	dl, #46
je	L57
cmp	eax, #63
je	L57
mov	BYTE PTR [skit_basename+eax], dl
inc	eax
jmp	L55
L57:
mov	BYTE PTR [skit_basename+eax], #0
cmp	BYTE PTR [ecx], #46
jne	L56
lea	eax, [esi+#1+eax]
push	eax
push	skit_basename
call	file_exists
pop	edx
pop	ecx
test	eax, eax
je	L56
L54:
mov	eax, #1
jmp	L53
L56:
inc	DWORD PTR [state+#112]
mov	eax, DWORD PTR [game_skit_id]
mov	DWORD PTR [state+#116], eax
mov	DWORD PTR [state+#68], #6
mov	DWORD PTR [state+#120], #180
L60:
mov	al, BYTE PTR [LC0+ebx]
inc	ebx
mov	BYTE PTR [skit_notice+ebx-#1], al
cmp	ebx, #14
jne	L60
test	esi, esi
je	L62
L61:
mov	al, BYTE PTR [esi-#14+ebx]
test	al, al
je	L62
cmp	ebx, #79
je	L62
inc	ebx
mov	BYTE PTR [skit_notice+ebx-#1], al
jmp	L61
L62:
mov	BYTE PTR [skit_notice+ebx], #0
xor	eax, eax
L53:
lea	esp, [ebp-#8]
pop	ebx
pop	esi
pop	ebp
ret
LC1:
db "testmap_OBJ000",00
// Substitute only the four known missing main scenery names.
model_replacement:
push	ebp
mov	ebp, esp
push	edi
mov	edi, DWORD PTR [ebp+#8]
push	esi
push	ebx
cmp	DWORD PTR [state+#88], #0
je	L87
xor	edx, edx
L83:
mov	ebx, DWORD PTR [missing_models+#0+edx*#4]
xor	eax, eax
L88:
mov	cl, BYTE PTR [edi+eax]
test	cl, cl
je	L84
cmp	cl, BYTE PTR [ebx+eax]
jne	L86
inc	eax
jmp	L88
L84:
cmp	BYTE PTR [ebx+eax], #0
jne	L86
inc	DWORD PTR [state+#92]
mov	edi, LC1
jmp	L87
L86:
inc	edx
cmp	edx, #4
jne	L83
L87:
pop	ebx
mov	eax, edi
pop	esi
pop	edi
pop	ebp
ret
// Rising edges prevent held Start from opening/closing every frame.
menu_edges:
push	ebp
mov	eax, DWORD PTR [state+#96]
not	eax
mov	ebp, esp
mov	edx, DWORD PTR [ebp+#8]
pop	ebp
and	eax, edx
mov	DWORD PTR [state+#96], edx
ret
// Menu state machine: Start, Cancel, Up/Down and Confirm.
menu_keys:
push	ebp
mov	ebp, esp
push	ebx
mov	ecx, DWORD PTR [ebp+#8]
test	cl, #16
je	L99
xor	eax, eax
cmp	DWORD PTR [state+#8], #0
sete	al
mov	DWORD PTR [state+#8], eax
cmp	DWORD PTR [state+#8], #0
je	L98
inc	DWORD PTR [state+#20]
jmp	L98
L99:
cmp	DWORD PTR [state+#8], #0
je	L98
bt	ecx, #27
jc	L126
cmp	ecx, #67108863
ja	L102
bt	ecx, #13
jnc	L103
jmp	L126
L102:
bt	ecx, #28
jc	L104
jmp	L127
L103:
test	cl, #1
je	L106
L104:
mov	eax, DWORD PTR [state+#12]
add	eax, #5
jmp	L125
L127:
bt	ecx, #29
jc	L108
jmp	L107
L106:
test	cl, #2
jne	L108
L110:
and	ecx, -#67104768
cmp	ecx, #4096
jne	L98
jmp	L109
L108:
mov	eax, DWORD PTR [state+#12]
inc	eax
L125:
mov	ebx, #6
xor	edx, edx
div	ebx
mov	DWORD PTR [state+#12], edx
L107:
bt	ecx, #26
jnc	L110
L109:
mov	eax, DWORD PTR [state+#12]
inc	eax
mov	DWORD PTR [state+#32], eax
L126:
xor	eax, eax
mov	DWORD PTR [state+#8], eax
L98:
pop	ebx
pop	ebp
ret
// Eligibility, completed-warp handling and input ownership for this frame.
before_update:
push	ebp
mov	ebp, esp
push	esi
push	ebx
inc	DWORD PTR [state+#16]
call	ensure_registry
test	eax, eax
jne	L129
xor	eax, eax
mov	DWORD PTR [state+#44], eax
mov	DWORD PTR [state+#8], eax
mov	DWORD PTR [state+#32], eax
jmp	L128
L129:
mov	ecx, DWORD PTR [game_mode]
mov	ebx, eax
and	ecx, #127
mov	DWORD PTR [state+#60], ecx
mov	esi, DWORD PTR [game_hardware]
push	esi
call	menu_edges
mov	edx, eax
pop	eax
cmp	DWORD PTR [state+#76], #0
je	L131
cmp	ecx, #8
jne	L132
mov	eax, DWORD PTR [state+#72]
inc	eax
mov	DWORD PTR [state+#72], eax
cmp	eax, #300
jbe	L131
mov	eax, DWORD PTR [game_state]
mov	DWORD PTR [eax+#4480], #3
mov	DWORD PTR [eax+#4484], 0x00000000
mov	DWORD PTR [eax+#4488], 0x00000000
mov	DWORD PTR [eax+#4492], 0x00000000
mov	DWORD PTR [eax+#4496], 0x00000000
mov	eax, DWORD PTR [state+#28]
mov	DWORD PTR [state+#84], eax
inc	DWORD PTR [state+#80]
mov	DWORD PTR [state+#68], #4
jmp	L174
L132:
cmp	ecx, #7
jne	L131
fld	DWORD PTR [game_fade]
fldz
fcomip st(1)
fstp	st(0)
jb	L131
cmp	BYTE PTR [game_cutscene], #0
jne	L131
L174:
xor	eax, eax
mov	DWORD PTR [state+#76], eax
L131:
mov	eax, DWORD PTR [game_loading]
test	eax, eax
je	L134
cmp	ecx, #7
sete	bl
cmp	eax, #2
sete	al
movzx	eax, al
and	ebx, eax
L134:
cmp	DWORD PTR [state+#4], #0
jne	L135
L137:
xor	eax, eax
jmp	L136
L135:
cmp	ecx, #7
je	L147
cmp	ecx, #10
jne	L137
L147:
cmp	BYTE PTR [game_submode], #0
jne	L137
cmp	BYTE PTR [game_input_ready], #0
je	L137
and	bl, #1
je	L137
fld	DWORD PTR [game_fade]
fldz
fcomip st(1)
fstp	st(0)
jb	L137
cmp	BYTE PTR [game_cutscene], #0
jne	L137
xor	eax, eax
cmp	BYTE PTR [game_player_input], #0
setne	al
L136:
mov	DWORD PTR [state+#44], eax
cmp	DWORD PTR [state+#44], #0
jne	L140
xor	ebx, ebx
mov	DWORD PTR [state+#8], ebx
mov	DWORD PTR [state+#32], ebx
cmp	DWORD PTR [state+#76], #0
jne	L141
cmp	DWORD PTR [state+#104], #0
je	L177
L141:
call	mask_inputs
jmp	L177
L140:
mov	ebx, DWORD PTR [state+#8]
mov	eax, DWORD PTR [state+#36]
or	eax, edx
xor	edx, edx
mov	DWORD PTR [state+#36], edx
mov	DWORD PTR [state+#40], eax
push	eax
call	menu_keys
pop	ecx
test	ebx, ebx
jne	L143
cmp	DWORD PTR [state+#8], #0
jne	L143
cmp	DWORD PTR [state+#32], #0
je	L144
L143:
mov	DWORD PTR [state+#104], #1
L144:
cmp	DWORD PTR [state+#104], #0
jne	L145
cmp	DWORD PTR [state+#76], #0
je	L128
L145:
call	mask_inputs
inc	DWORD PTR [state+#52]
cmp	DWORD PTR [state+#8], #0
jne	L128
cmp	DWORD PTR [state+#32], #0
jne	L128
L177:
or	esi, DWORD PTR [state+#76]
jne	L128
xor	eax, eax
mov	DWORD PTR [state+#104], eax
L128:
lea	esp, [ebp-#8]
pop	ebx
pop	esi
pop	ebp
ret
LC4:
db ">",00
LC5:
db " ",00
LC6:
db "Unavailable skit skipped",00
LC7:
db "Last load failed; returned safely",00
LC8:
db "Uses temporary testmap scenery",00
LC9:
db "Up/Down: select   Confirm: load",00
LC10:
db "DEBUG MAPS",00
LC11:
db "Start / Cancel: close",00
// Restore hardware, process one native warp request, then draw the menu.
after_update:
push	ebp
xor	eax, eax
mov	ebp, esp
push	edi
push	esi
push	ebx
sub	esp, #8
mov	DWORD PTR [state+#56], eax
cmp	DWORD PTR [state+#100], #0
je	L179
xor	eax, eax
L181:
imul	ecx, eax, #88
xor	edx, edx
imul	esi, eax, #72
L180:
mov	bl, BYTE PTR [hardware_copy+esi+edx]
inc	edx
mov	BYTE PTR [edx+game_hardware_minus_one+ecx], bl
cmp	edx, #72
jne	L180
inc	eax
cmp	eax, #4
jne	L181
xor	eax, eax
mov	DWORD PTR [state+#100], eax
L179:
cmp	DWORD PTR [state+#4], #0
je	L178
cmp	DWORD PTR [state+#120], #0
je	L183
cmp	DWORD PTR [state+#44], #0
je	L183
push	#24
push	#24
push	#128
push	#9
push	#32
push	#32
push	skit_notice
call	draw_text
dec	DWORD PTR [state+#120]
add	esp, #28
L183:
mov	edi, DWORD PTR [state+#32]
test	edi, edi
je	L184
mov	eax, DWORD PTR [state+#32]
xor	edi, edi
mov	DWORD PTR [state+#32], edi
lea	ebx, [eax-#1]
cmp	ebx, #5
jbe	L185
mov	DWORD PTR [state+#68], #1
jmp	L178
L185:
mov	edx, DWORD PTR [game_mode]
and	edx, #127
cmp	edx, #7
je	L203
cmp	edx, #10
jne	L186
L203:
cmp	BYTE PTR [game_submode], #0
je	L188
L186:
mov	DWORD PTR [state+#68], #2
jmp	L178
L188:
sub	eax, #2
cmp	eax, #2
jbe	L204
cmp	ebx, #5
jne	L189
L204:
cmp	DWORD PTR [state+#88], #0
jne	L189
mov	DWORD PTR [state+#68], #5
mov	DWORD PTR [state+#8], #1
jmp	L178
L189:
push	DWORD PTR [packages+#0+ebx*#4]
mov	eax, game_package_lookup
call	eax
pop	esi
test	eax, eax
mov	eax, command_context
jne	L192
mov	DWORD PTR [state+#68], #3
jmp	L178
L192:
mov	BYTE PTR [eax], #0
inc	eax
cmp	eax, command_context+#2660
jne	L192
mov	ebx, DWORD PTR [maps+#0+ebx*#4]
mov	eax, game_change_map
mov	DWORD PTR [command_context+#2116], #5
mov	DWORD PTR [command_context+#2120], ebx
push	command_context
call	eax
xor	eax, eax
xor	edx, edx
mov	DWORD PTR [state+#28], ebx
inc	DWORD PTR [state+#24]
mov	DWORD PTR [state+#72], eax
mov	DWORD PTR [state+#76], #1
mov	DWORD PTR [state+#68], edx
mov	eax, DWORD PTR [game_destination]
mov	DWORD PTR [state+#64], eax
pop	ecx
jmp	L178
L184:
cmp	DWORD PTR [state+#8], #0
je	L178
cmp	DWORD PTR [state+#44], #0
je	L178
cmp	BYTE PTR [game_submode], #0
jne	L178
mov	eax, DWORD PTR [game_width]
mov	ecx, #2
mov	ebx, DWORD PTR [game_height]
push	-#8351568
sub	eax, #600
cdq
idiv	ecx
mov	esi, eax
lea	eax, [ebx-#430]
cdq
idiv	ecx
mov	ebx, eax
lea	eax, [eax+#433]
push	eax
lea	eax, [esi+#603]
push	eax
lea	eax, [ebx-#3]
push	eax
lea	eax, [esi-#3]
push	eax
mov	eax, game_rect
call	eax
lea	edx, [ebx+#430]
push	-#266856416
mov	eax, game_rect
push	edx
lea	edx, [esi+#600]
push	edx
push	ebx
push	esi
call	eax
lea	eax, [esi+#28]
mov	DWORD PTR [ebp-#16], eax
lea	eax, [ebx+#20]
add	esp, #40
push	#32
push	#32
push	#128
push	#9
push	eax
push	DWORD PTR [ebp-#16]
push	LC10
call	draw_text
lea	eax, [ebx+#82]
add	esp, #28
L195:
cmp	DWORD PTR [state+#12], edi
jne	L193
lea	edx, [eax+#34]
push	-#800047024
push	edx
lea	edx, [esi+#584]
push	edx
lea	edx, [eax-#4]
mov	DWORD PTR [ebp-#20], eax
push	edx
lea	edx, [esi+#16]
push	edx
mov	edx, game_rect
call	edx
mov	eax, DWORD PTR [ebp-#20]
add	esp, #20
L193:
cmp	DWORD PTR [state+#12], edi
mov	ecx, LC4
mov	edx, LC5
push	#28
cmove	edx, ecx
push	#28
push	#128
push	#9
push	eax
mov	DWORD PTR [ebp-#20], eax
push	DWORD PTR [ebp-#16]
push	edx
call	draw_text
mov	eax, DWORD PTR [ebp-#20]
lea	edx, [esi+#68]
push	#28
push	#28
push	#128
push	#9
push	eax
push	edx
push	DWORD PTR [names+#0+edi*#4]
inc	edi
call	draw_text
mov	eax, DWORD PTR [ebp-#20]
add	esp, #56
add	eax, #42
cmp	edi, #6
jne	L195
lea	edx, [ebx+#356]
cmp	DWORD PTR [state+#68], #6
je	L200
mov	eax, LC7
cmp	DWORD PTR [state+#68], #0
jne	L196
cmp	DWORD PTR [state+#12], #1
je	L197
cmp	DWORD PTR [state+#12], #2
jne	L198
L197:
mov	eax, LC8
jmp	L196
L198:
cmp	DWORD PTR [state+#12], #3
je	L197
cmp	DWORD PTR [state+#12], #5
mov	eax, LC8
mov	ecx, LC9
cmovne	eax, ecx
jmp	L196
L200:
mov	eax, LC6
L196:
push	#22
add	ebx, #390
push	#22
push	#128
push	#9
push	edx
push	DWORD PTR [ebp-#16]
push	eax
call	draw_text
push	#22
push	#22
push	#128
push	#9
push	ebx
push	DWORD PTR [ebp-#16]
push	LC11
call	draw_text
inc	DWORD PTR [state+#48]
add	esp, #56
L178:
lea	esp, [ebp-#12]
pop	ebx
pop	esi
pop	edi
pop	ebp
ret
align #32
registry_offsets:
dd #824304
dd #826928
dd #827232
dd #827296
dd #827360
dd #827424
dd #827488
dd #827552
dd #827616
dd #827680
dd #827744
dd #827808
LC12:
db "_kanemaru_OBJ000",00
LC13:
db "_miya_OBJ000",00
LC14:
db "_ichio_OBJ000",00
LC15:
db "_sawada_OBJ000",00
align #4
missing_models:
dd LC12
dd LC13
dd LC14
dd LC15
LC16:
db "testmap.pac",00
LC17:
db "_kanemaru.pac",00
LC18:
db "_miya.pac",00
LC19:
db "_ichio.pac",00
LC20:
db "_otumoo.pac",00
LC21:
db "_sawada.pac",00
align #4
packages:
dd LC16
dd LC17
dd LC18
dd LC19
dd LC20
dd LC21
align #4
maps:
dd #3
dd #1
dd #2
dd #4
dd #541
dd #543
LC22:
db "testmap",00
LC23:
db "_kanemaru",00
LC24:
db "_miya",00
LC25:
db "_ichio",00
LC26:
db "_otumoo",00
LC27:
db "_sawada",00
align #4
names:
dd LC22
dd LC23
dd LC24
dd LC25
dd LC26
dd LC27
mapmenu_data+#0:
rejected_registry:
mapmenu_data+#32:
registry_copy:
mapmenu_data+#827904:
skit_notice:
mapmenu_data+#828000:
skit_basename:
mapmenu_data+#828064:
command_context:
mapmenu_data+#830752:
hardware_copy:
mapmenu_data+#831040:
pad_ptr:
mapmenu_data+#831072:
align #32
state:
dd #1296904241
dd #1
db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
dd #1
db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
// PKKP descriptors reconstructed from retained _KANEMARU*.PAC manifests.
// 12 records: hash, byte size, resource count, category counts, table offsets.
// Child names occupy 256-byte slots; all omitted padding is initially zero.
// _KANEMARU.PAC
registry_added+#0:
dd 3DB169F2,00000A40,0000001B,000A0101,02000001,00000000,00000030,00000A30,00000000,00000000,00000000,00000000
registry_added+#48:
db "_kanemaru_b000.pac",00
registry_added+#304:
db "_kanemaru_b001.pac",00
registry_added+#560:
db "_kanemaru_b002.pac",00
registry_added+#816:
db "_kanemaru_b003.pac",00
registry_added+#1072:
db "_kanemaru_b004.pac",00
registry_added+#1328:
db "_kanemaru_b005.pac",00
registry_added+#1584:
db "_kanemaru_b006.pac",00
registry_added+#1840:
db "_kanemaru_b007.pac",00
registry_added+#2096:
db "_kanemaru_b008.pac",00
registry_added+#2352:
db "_kanemaru_b009.pac",00
registry_added+#2608:
db 00,01
// _KANEMARU_B000.PAC
registry_added+#2624:
dd D0A11A30,00000130,00000002,00010000,01000000,00000000,00000030,00000130,00000000,00000000,00000000,00000000
registry_added+#2672:
db "_kanemaru_b000_b000.pac",00
// _KANEMARU_B000_B000.PAC
registry_added+#2928:
dd 9A8B7350,00000040,00000020,0C000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#2976:
db 00,01
// _KANEMARU_B001.PAC
registry_added+#2992:
dd DF287BE4,00000040,00000020,03000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3040:
db 00,01
// _KANEMARU_B002.PAC
registry_added+#3056:
dd D92014A4,00000040,00000020,04000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3104:
db 00,01
// _KANEMARU_B003.PAC
registry_added+#3120:
dd D821D120,00000040,00000020,08000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3168:
db 00,01
// _KANEMARU_B004.PAC
registry_added+#3184:
dd D8128D2C,00000040,00000020,03000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3232:
db 00,01
// _KANEMARU_B005.PAC
registry_added+#3248:
dd 2B01E2E0,00000040,00000020,03000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3296:
db 00,01
// _KANEMARU_B006.PAC
registry_added+#3312:
dd 946A7301,00000040,00000020,03000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3360:
db 00,01
// _KANEMARU_B007.PAC
registry_added+#3376:
dd 9279AD43,00000040,00000020,03000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3424:
db 00,01
// _KANEMARU_B008.PAC
registry_added+#3440:
dd 937AB06D,00000040,00000020,03000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3488:
db 00,01
// _KANEMARU_B009.PAC
registry_added+#3504:
dd EB9501B3,00000040,00000020,04000101,00000001,00000000,00000030,00000030,00000000,00000000,00000000,00000000
registry_added+#3552:
db 00,01
[DISABLE]
TOS.exe+17846C:
db e8 af b2 f4 ff
TOS.exe+C7394:
db e8 47 34 0c 00
TOS.exe+1550F8:
db f6 05 64 3f ad 00 80
TOS.exe+16E595:
db e8 26 4c 01 00
TOS.exe+472B7C:
db 5f 61 6e 61 62 75 6b 69 2e 70 61 63 00
dealloc(mapmenu_code)
dealloc(mapmenu_data)
dealloc(registry_added)
