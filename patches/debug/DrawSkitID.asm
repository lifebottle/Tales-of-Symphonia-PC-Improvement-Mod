// Draw the selector ID and script filename while a skit is rendered.
// Independent of DebugMapLoader. Native dialog rendering still runs first.
// Bottom-left edge: background x=0, y=screen height-36; text x=8, y=height-30.
// Port of the live skit-39 prototype; this ASM is the maintained runtime source.
[ENABLE]
alloc(skit_label_code,1000)
alloc(skit_label_data,100)
define(skit_draw_site,TOS.exe+155435)
define(native_dialog,TOS.exe+176F60)
define(native_rect,TOS.exe+134770)
define(native_text,TOS.exe+132250)
define(game_mode,TOS.exe+6D3F64)
define(game_skit_id,TOS.exe+71862C)
define(game_skit_name,TOS.exe+718634)
define(game_height,TOS.exe+518614)

assert(skit_draw_site,E8 26 1B 02 00)
assert(native_dialog,55 8B EC 83 E4 F8 56 57 C7 05 00 CE 8A 00 02 00)
assert(native_rect,55 8B EC 56 6A 01 E8 05 D6 FF FF 83 C4 04 68 34)
assert(native_text,55 8B EC 83 E4 F8 83 EC 0C 53 56 8B F0 0F B7 45)
assert(TOS.exe+15543A,B8 01 00 00 00 01 05 D8 C3 C3 01 A3 D4 C3 C3 01)
// Guard native filename/ID assignment and the end-of-skit reset contract.
assert(TOS.exe+159E93,8B 0C BD BC 3C 8B 00 89 0D 34 86 B1 00)
assert(TOS.exe+159ECC,8B 34 90 E8 DC AF 02 00 89 3D 2C 86 B1 00)
assert(TOS.exe+155633,89 3D E4 C2 C3 01 89 3D 34 86 B1 00 89 3D 30 86 B1 00 C7 05 2C 86 B1 00 FF FF FF FF)

skit_draw_site:
call skit_label_hook

skit_label_code:
skit_label_hook:
call native_dialog
// Preserve the machine state left by the displaced call, including live x87/SSE.
pushfd
pushad
mov ebp,esp
sub esp,#528
and esp,-#16
fxsave [esp]
fninit
cld
call draw_skit_label
fxrstor [esp]
mov esp,ebp
popad
popfd
ret

draw_skit_label:
mov eax,[game_mode]
and eax,7F
cmp eax,#11
jne label_done
mov eax,[game_skit_id]
cmp eax,FFFFFFFF
je label_done
mov ebx,[game_skit_name]
test ebx,ebx
jz label_done

// Format decimal ID without a CRT dependency; all ten uint32 digits fit.
mov edi,label_buffer
mov dword ptr [edi],74696B53
mov byte ptr [edi+#4],20
add edi,#5
mov esi,reversed_digits
mov ecx,#10
decimal_digit:
xor edx,edx
div ecx
add dl,30
mov [esi],dl
inc esi
test eax,eax
jnz decimal_digit
copy_digit:
dec esi
mov al,[esi]
mov [edi],al
inc edi
cmp esi,reversed_digits
jne copy_digit
mov byte ptr [edi],20
mov byte ptr [edi+#1],7C
mov byte ptr [edi+#2],20
add edi,#3

// Native filenames are ASCII. Bound the 80-byte buffer and suppress controls.
copy_filename:
cmp edi,label_buffer+#79
jae filename_done
mov al,[ebx]
test al,al
jz filename_done
mov dl,al
sub dl,20
cmp dl,#95
jb filename_printable
mov al,3F
filename_printable:
mov [edi],al
inc edi
inc ebx
jmp copy_filename
filename_done:
mov byte ptr [edi],00

mov ebx,[game_height]
sub ebx,#36
jns position_ready
xor ebx,ebx
position_ready:
push D0101018
lea eax,[ebx+#36]
push eax
push #390
push ebx
push #0
call native_rect
add esp,#20
// Native text ABI: EAX=string; cdecl stack x,y,palette,opacity,width,height.
push #24
push #24
push #128
push #9
add ebx,#6
push ebx
push #8
mov eax,label_buffer
call native_text
add esp,#24
label_done:
ret

// Allocations start zeroed; no debugger initialization or captured heap pointer.
skit_label_data:
label_buffer:
db 00
skit_label_data+50:
reversed_digits:
db 00

[DISABLE]
skit_draw_site:
db E8 26 1B 02 00
dealloc(skit_label_code)
dealloc(skit_label_data)
