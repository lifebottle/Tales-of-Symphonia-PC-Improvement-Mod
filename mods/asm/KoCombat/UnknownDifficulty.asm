//######################################################################################################
//# Tales of Symphonia - Unknown Difficulty
//# Fourth difficulty option (ID 3), menu label and enemy stat multipliers
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_unknown_menu,0x400)
alloc(mem_unknown_stats,0x400)


//################################################
//# Check original instructions
//################################################

assert(TOS.exe+0xFB785,8B 34 90 51 57)
assert(TOS.exe+0xFB7C4,8B 34 91 6A 1E)
assert(TOS.exe+0xFB7DE,83 F8 03)
assert(TOS.exe+0x595FC,0F B6 80 51 02 00 00)
// Compare opcode + address, intentionally excluding the last byte (the difficulty limit).
assert(TOS.exe+0xFCA22,80 3D 71 A0 D5 01)
// The patch changes only the final immediate byte at 0xFCA28.
assert(TOS.exe+0xFCA28,02)

//################################################
//# Addresses and functions
//################################################

define(UnknownDrawText,TOS.exe+0x132250)
define(UnknownMeasureText,TOS.exe+0x1327D0)
define(UnknownDrawReturn,TOS.exe+0xFB78F)
define(UnknownDrawOriginalReturn,TOS.exe+0xFB78A)
define(UnknownWidthReturn,TOS.exe+0xFB7CE)
define(UnknownWidthOriginalReturn,TOS.exe+0xFB7C9)
define(UnknownStatsOriginalReturn,TOS.exe+0x59603)
define(UnknownStatsDone,TOS.exe+0x59754)

//################################################
//# Menu hooks: display and measure "Unknown"
//################################################

mem_unknown_menu:
UnknownMenuHook:
  cmp edx,0x03
  jne unknown_draw_original

  mov esi,0x095D
  push ecx
  push edi
  mov eax,UnknownText
  call UnknownDrawText
  jmp UnknownDrawReturn

unknown_draw_original:
  mov esi,[eax+edx*4]
  push ecx
  push edi
  jmp UnknownDrawOriginalReturn

UnknownWidthHook:
  cmp edx,0x03
  jne unknown_width_original

  mov esi,0x095D
  push 0x1E
  mov eax,UnknownText
  call UnknownMeasureText
  jmp UnknownWidthReturn

unknown_width_original:
  mov esi,[ecx+edx*4]
  push 0x1E
  jmp UnknownWidthOriginalReturn

UnknownText:
  db "Unknown"
  db 0x00

//################################################
//# Enemy difficulty dispatcher
//################################################

mem_unknown_stats:
UnknownStatsHook:
  // Instruction replaced by the hook.
  movzx eax,byte ptr [eax+0x251]

  cmp eax,0x03
  je unknown_apply_stats
  jmp UnknownStatsOriginalReturn

unknown_apply_stats:
  mov eax,[ebx+0x08]

  // Maximum HP x3
  mov ecx,[eax+0x20]
  imul ecx,ecx,0x03
  mov [eax+0x20],ecx

  // Current HP x3
  mov edx,[eax+0x24]
  imul edx,edx,0x03
  mov [eax+0x24],edx

  // Maximum TP x2
  mov cx,[eax+0x28]
  add cx,cx
  mov [eax+0x28],cx

  // Current TP x2
  mov dx,[eax+0x2A]
  add dx,dx
  mov [eax+0x2A],dx

  // Attack 1 x2
  mov cx,[eax+0x2C]
  add cx,cx
  mov [eax+0x2C],cx

  // Attack 2 x2
  mov dx,[eax+0x2E]
  add dx,dx
  mov [eax+0x2E],dx

  // Defense +0x30 unchanged.

  // Magic x2
  mov cx,[eax+0x32]
  add cx,cx
  mov [eax+0x32],cx

  // Other value +0x34 x1.5 (same algorithm as working CE script)
  movzx ecx,word ptr [eax+0x34]
  mov dx,cx
  sar dx,1
  add dx,cx
  mov [eax+0x34],dx

  // Other value +0x36 x1.5
  movzx ecx,word ptr [eax+0x36]
  mov dx,cx
  sar dx,1
  add dx,cx
  mov [eax+0x36],dx

  jmp UnknownStatsDone

//################################################
//# Install hooks
//################################################

// Override only the fourth difficulty's text.
TOS.exe+0xFB785:
  jmp UnknownMenuHook

// Override only the fourth difficulty's text-width lookup.
TOS.exe+0xFB7C4:
  jmp UnknownWidthHook

// Render four difficulty slots instead of three.
TOS.exe+0xFB7DE:
  db 0x83, 0xF8, 0x04

// Allow difficulty index 3 when scrolling.
TOS.exe+0xFCA28:
  db 0x03

// Use custom enemy multipliers for difficulty index 3.
TOS.exe+0x595FC:
  jmp UnknownStatsHook
  nop #2
