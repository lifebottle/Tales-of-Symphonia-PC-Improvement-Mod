// Install at startup. Framework allocations replace the original fixed caves.
// Lloyd Super Chain; port of the tested 2026-09-19 IDA memory installer.
[ENABLE]
// Validate and patch rebuilt battle descriptors
alloc(mem_init_hook,0x37a)
// Lloyd MAX gem Super Chain menu
alloc(mem_menu_hook,0x88)
// Ability Plus and Super Chain eligibility
alloc(mem_ability_hook,0x84)
// Expanded EX skill list
alloc(mem_menu_buffer,0x20)
// Descriptor rebuild diagnostics
alloc(mem_status,0x20)
// Nine descriptor validation rows
alloc(mem_rows,0x18c)
// .patch_init
assert(TOS.exe+0x678e0,8b 8d c4 fe ff ff)
// .patch_menu
assert(TOS.exe+0xf34a0,80 f9 05 72 47)
// .patch_eligibility
assert(TOS.exe+0x3f0de,8a c3 24 0f 3c 01 8b c6)
// .patch_execution
assert(TOS.exe+0x3f665,0f b7 87 6c 13 00 00 24 0f 3c 01 8b c7)
// EX menu buffer reference 1
assert(TOS.exe+0xf1876,88 39 b1 00)
// EX menu buffer reference 2
assert(TOS.exe+0xf1e22,88 39 b1 00)
// EX menu buffer reference 3
assert(TOS.exe+0xf1e91,88 39 b1 00)
// EX menu buffer reference 4
assert(TOS.exe+0xf26af,88 39 b1 00)
// EX menu buffer reference 5
assert(TOS.exe+0xf295d,88 39 b1 00)
// EX menu buffer reference 6
assert(TOS.exe+0xf2a8b,88 39 b1 00)
// EX menu buffer reference 7
assert(TOS.exe+0xf2e80,88 39 b1 00)
// EX menu buffer reference 8
assert(TOS.exe+0xf2f2b,88 39 b1 00)
// EX menu buffer reference 9
assert(TOS.exe+0xf34d6,88 39 b1 00)
// EX menu buffer reference 10
assert(TOS.exe+0xf351c,88 39 b1 00)
// EX menu buffer reference 11
assert(TOS.exe+0xf3696,88 39 b1 00)
// EX menu buffer reference 12
assert(TOS.exe+0xf3e95,88 39 b1 00)
// EX menu buffer reference 13
assert(TOS.exe+0xf4561,88 39 b1 00)
assert(TOS.exe+0x678e6,83 39 09 7f 0c c7 85 dc fe ff ff 00 00 00 00 eb)
assert(TOS.exe+0xf34ec,80 f9 01 72 40 0f b6 c9 32 c0 8d 0c 91 a2 9d 39)
assert(TOS.exe+0x3f0e6,75 3e ba 0f 00 00 00 e8 6e 3c 00 00 85 c0 0f 84)
assert(TOS.exe+0x3f672,75 3d ba 0f 00 00 00 e8 e2 36 00 00 85 c0 0f 84)
assert(TOS.exe+0x42d60,8b 08 33 c0 85 c9 74 1d 0f bf d2 56 8d 64 24 00)
assert(TOS.exe+0x4e0a60,00 00 00 00 39 ea 72 00 34 ea 72 00 30 ea 72 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 01 02 03 04 05 17 07 12 09 0a 13 14 0d 15 16 0e 17 02 03 05 0a 06 18 0c 09 0b 19 1a 0d 1b 1c 1d 17 02 03 05 0a 1e 1a 1f 09 0b 1b 0c 0d 20 1c 21 01 02 03 04 05 06 07 22 09 0a 1a 23 0c 0b 0d 1b 01 17 03 05 0a 06 07 28 09 29 2a 0c 0d 1b 0e 1d 01 02 03 04 2b 06 07 2c 09 2d 2e 0c 0d 2f 30 31 01 02 03 04 05 06 07 32 09 0a 0b 0c 0d 0e 33 34)
define(InitContinue,TOS.exe+0x678e6)
define(NormalMenu,TOS.exe+0xf34ec)
define(NativeMaxSkills,TOS.exe+0x4e0a60)
define(MenuCount,TOS.exe+0x71399d)
define(HasExSkill,TOS.exe+0x42d60)
registersymbol(InitHook)
registersymbol(MenuHook)
registersymbol(AbilityHook)
registersymbol(MenuBuffer)
registersymbol(Status)
registersymbol(Rows)
registersymbol(RowsEnd)


// Validate and patch rebuilt battle descriptors
mem_init_hook:
InitHook:
  pushfd
  pushad
  mov eax, [ebp-#316]
  mov edx, [edi+#39512]
  call descriptor_apply
  popad
  popfd
  mov ecx, [ebp-#316] // replay displaced instruction
  jmp InitContinue

// EAX = loaded PAC, EDX = completed runtime table.
// Returns EAX=1 on success, 0 on mismatch. Preserves EBX/EBP/ESI/EDI.
// No calls, allocation, or heap-address constants. Does not modify the PAC.
// Status: magic, attempts, successes, failures, PAC, table, failure row, reserved.
// Row: runtime offset, source descriptor offset, block offset,
// duration/recovery, replacement window, effect,
// four script offsets, directory-entry offset.
descriptor_apply:
  push ebp
  push ebx
  push esi
  push edi
  mov ebp, eax
  mov edi, edx
  inc dword ptr [Status+#4]
  mov [Status+#16], eax
  mov [Status+#20], edx
  mov esi, -#1
  test ebp, ebp
  jz mismatch
  test edi, edi
  jz mismatch
  cmp dword ptr [ebp], #8
  jbe mismatch
  cmp dword ptr [ebp+#36], 0x49F60
  jne mismatch
  cmp dword ptr [ebp+0x49F60], #155
  jne mismatch
  mov esi, Rows
validate_row:
  mov ecx, [esi+#40]
  mov ecx, [ebp+ecx+0x49F60]
  add ecx, 0x49F60
  cmp ecx, [esi+#8]
  jne mismatch
  mov ebx, [esi+#4]
  add ebx, ebp
  mov edx, [esi]
  add edx, edi
  mov eax, [esi+#12]
  cmp [ebx], eax // source duration/recovery
  jne mismatch
  cmp [edx], eax // runtime duration/recovery
  jne mismatch
  mov eax, [esi+#20]
  cmp [ebx+#8], eax // source effect
  jne mismatch
  cmp [edx+#8], eax // runtime effect
  jne mismatch
  mov eax, [ebx+#4]
  test eax, eax
  jz source_window_ok
  cmp eax, [esi+#16] // permit this session's prior memory patch
  jne mismatch
source_window_ok:
  mov eax, [edx+#4]
  test eax, eax
  jz runtime_window_ok
  cmp eax, [esi+#16]
  jne mismatch
runtime_window_ok:
// Verify source section/index arithmetic AND all relocated runtime pointers.
  mov eax, [esi+#8]
  add eax, ebp
  mov eax, [eax+#4*#0]
  mov ecx, [ebx+#12+#4*#0]
  imul ecx, ecx, #28
  add eax, ecx
  add eax, [esi+#8]
  cmp eax, [esi+#24+#4*#0]
  jne mismatch
  add eax, ebp
  cmp eax, [edx+#12+#4*#0]
  jne mismatch
  mov eax, [esi+#8]
  add eax, ebp
  mov eax, [eax+#4*#1]
  mov ecx, [ebx+#12+#4*#1]
  imul ecx, ecx, #32
  add eax, ecx
  add eax, [esi+#8]
  cmp eax, [esi+#24+#4*#1]
  jne mismatch
  add eax, ebp
  cmp eax, [edx+#12+#4*#1]
  jne mismatch
  mov eax, [esi+#8]
  add eax, ebp
  mov eax, [eax+#4*#2]
  mov ecx, [ebx+#12+#4*#2]
  imul ecx, ecx, #12
  add eax, ecx
  add eax, [esi+#8]
  cmp eax, [esi+#24+#4*#2]
  jne mismatch
  add eax, ebp
  cmp eax, [edx+#12+#4*#2]
  jne mismatch
  mov eax, [esi+#8]
  add eax, ebp
  mov eax, [eax+#4*#3]
  mov ecx, [ebx+#12+#4*#3]
  imul ecx, ecx, #2
  add eax, ecx
  add eax, [esi+#8]
  cmp eax, [esi+#24+#4*#3]
  jne mismatch
  add eax, ebp
  cmp eax, [edx+#12+#4*#3]
  jne mismatch
  add esi, #44
  cmp esi, RowsEnd
  jne validate_row

// All nine descriptors validated; only now change the runtime windows.
  mov esi, Rows
write_row:
  mov edx, [esi]
  mov eax, [esi+#16]
  mov [edi+edx+#4], eax
  add esi, #44
  cmp esi, RowsEnd
  jne write_row
  inc dword ptr [Status+#8]
  mov dword ptr [Status+#24], #0
  mov eax, #1
  jmp init_done
mismatch:
  inc dword ptr [Status+#12]
  mov [Status+#24], esi
  xor eax, eax
init_done:
  pop edi
  pop esi
  pop ebx
  pop ebp
  ret


// Lloyd MAX gem Super Chain menu
mem_menu_hook:
MenuHook:
  cmp cl, #5
  jb normal
  push ecx
  push esi
  mov esi, edx
  shl esi, #4
  add esi, NativeMaxSkills
  xor eax, eax
copy:
  mov cl, byte ptr [esi+eax]
  mov byte ptr [MenuBuffer+eax], cl
  inc eax
  cmp eax, #16
  jb copy
  cmp byte ptr [esp+#4], #5
  jne menu_done
  cmp edx, #1
  jne menu_done
  mov byte ptr [MenuBuffer+#16], #42
  inc eax
menu_done:
  mov byte ptr [MenuCount], al
  pop esi
  pop ecx
  ret
normal:
  jmp NormalMenu


// Ability Plus and Super Chain eligibility
mem_ability_hook:
AbilityHook:
  push eax
  push ecx
  push edx
  movzx edx, word ptr [eax+#4972]
  and edx, #15
  cmp edx, #1
  je allowed
  test dl, #8
  jnz denied
  test dl, #1
  jz denied
  mov ecx, dword ptr [eax+#12]
  test ecx, ecx
  jz denied
  test byte ptr [ecx+#56], #4
  jz denied
  mov edx, #42
  call HasExSkill
  test eax, eax
  jz denied
allowed:
  cmp eax, eax
  jmp ability_done
denied:
  or eax, #1
ability_done:
  pop edx
  pop ecx
  pop eax
  ret

// Startup installation precedes menu construction; no live list needs copying.

// Expanded EX skill list
mem_menu_buffer:
MenuBuffer:
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00


// Descriptor rebuild diagnostics
mem_status:
Status:
  db "SCW1"
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00

// Immutable rows, kept in a non-executable allocation.
// runtime offset, source offset, block, duration/recovery, window, effect,
// four script offsets, directory entry offset.

// Nine descriptor validation rows
mem_rows:
Rows:
// Arte 23, variant 0
  dd 0xa10, 0x4d4f0, 0x4d4e0, 0xa0046, 0x370046, 0x44, 0x4d560, 0x4d598, 0x4d618, 0x4d660, 0x60
// Arte 24, variant 0
  dd 0xa80, 0x4d6b0, 0x4d6a0, 0xa0050, 0x410050, 0x43, 0x4d720, 0x4d758, 0x4d7b8, 0x4d7dc, 0x64
// Arte 25, variant 0
  dd 0xaf0, 0x4d830, 0x4d820, 0x10005f, 0x50005f, 0x47, 0x4d8a0, 0x4d8f4, 0x4da74, 0x4db1c, 0x68
// Arte 26, variant 0
  dd 0xb60, 0x4dbf0, 0x4dbe0, 0xa005e, 0x4f005e, 0x45, 0x4dc60, 0x4dcb4, 0x4dd74, 0x4dd98, 0x6c
// Arte 27, variant 0
  dd 0xbd0, 0x4de30, 0x4de20, 0xa005f, 0x50005f, 0x46, 0x4dea0, 0x4def4, 0x4dfb4, 0x4dfd8, 0x70
// Arte 29, variant 0
  dd 0xcb0, 0x4e3b0, 0x4e3a0, 0xa0078, 0x690078, 0x26, 0x4e420, 0x4e458, 0x4e558, 0x4e5d0, 0x78
// Arte 29, variant 1
  dd 0xccc, 0x4e3cc, 0x4e3a0, 0xa0078, 0x690078, 0x27, 0x4e420, 0x4e498, 0x4e57c, 0x4e628, 0x78
// Arte 29, variant 2
  dd 0xce8, 0x4e3e8, 0x4e3a0, 0xa0078, 0x690078, 0x89, 0x4e420, 0x4e4d8, 0x4e594, 0x4e660, 0x78
// Arte 29, variant 3
  dd 0xd04, 0x4e404, 0x4e3a0, 0xa0078, 0x690078, 0x8a, 0x4e420, 0x4e518, 0x4e5b8, 0x4e6c8, 0x78
RowsEnd:


// .patch_init
TOS.exe+0x678e0:
  jmp InitHook
  nop


// .patch_menu
TOS.exe+0xf34a0:
  jmp MenuHook


// .patch_eligibility
TOS.exe+0x3f0de:
  db 0x8b, 0xc6 // mov eax, esi (retain tested encoding)
  call AbilityHook
  nop


// .patch_execution
TOS.exe+0x3f665:
  db 0x8b, 0xc7 // mov eax, edi (retain tested encoding)
  call AbilityHook
  nop #6


// EX menu buffer reference 1
TOS.exe+0xf1876:
  dd MenuBuffer


// EX menu buffer reference 2
TOS.exe+0xf1e22:
  dd MenuBuffer


// EX menu buffer reference 3
TOS.exe+0xf1e91:
  dd MenuBuffer


// EX menu buffer reference 4
TOS.exe+0xf26af:
  dd MenuBuffer


// EX menu buffer reference 5
TOS.exe+0xf295d:
  dd MenuBuffer


// EX menu buffer reference 6
TOS.exe+0xf2a8b:
  dd MenuBuffer


// EX menu buffer reference 7
TOS.exe+0xf2e80:
  dd MenuBuffer


// EX menu buffer reference 8
TOS.exe+0xf2f2b:
  dd MenuBuffer


// EX menu buffer reference 9
TOS.exe+0xf34d6:
  dd MenuBuffer


// EX menu buffer reference 10
TOS.exe+0xf351c:
  dd MenuBuffer


// EX menu buffer reference 11
TOS.exe+0xf3696:
  dd MenuBuffer


// EX menu buffer reference 12
TOS.exe+0xf3e95:
  dd MenuBuffer


// EX menu buffer reference 13
TOS.exe+0xf4561:
  dd MenuBuffer
