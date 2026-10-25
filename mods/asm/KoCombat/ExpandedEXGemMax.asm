//######################################################################################################
//# Tales of Symphonia - EX Gem MAX: 17th EX Skill
//# Adds an extra EX Skill entry for each party member's EX Gem MAX.
//# Preserves the original skill lookup for all other entries.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_exgem17_hook,0x400)

//################################################
//# Check original instructions
//################################################

// Seven bytes replaced by the skill lookup hook.
assert(TOS.exe+0xF34CD,8A 94 96 60 0A 8E 00)

// Two bytes replaced to expand the entry limit from 0x10 to 0x11.
assert(TOS.exe+0xF34E6,3C 10)

//################################################
//# Return address and original lookup
//################################################

define(EXGem17Return,TOS.exe+0xF34D4)
define(EXGem17Lookup,TOS.exe+0x4E0A60)

//################################################
//# Extra EX Skill per character
//################################################

mem_exgem17_hook:
EXGem17Hook:
  // The extra entry is selected only for index 0x10 (the 17th entry).
  cmp eax,0x10
  jne exgem17_original

  // Select a character-specific skill value using the existing ECX identifier.
  cmp ecx,0x04  // Lloyd
  je exgem17_lloyd
  cmp ecx,0x08  // Colette
  je exgem17_colette
  cmp ecx,0x0C  // Genis
  je exgem17_genis
  cmp ecx,0x10  // Raine
  je exgem17_raine
  cmp ecx,0x14  // Sheena
  je exgem17_sheena
  cmp ecx,0x18  // Zelos
  je exgem17_zelos
  cmp ecx,0x1C  // Presea
  je exgem17_presea
  cmp ecx,0x20  // Regal
  je exgem17_regal
  cmp ecx,0x24  // Kratos
  je exgem17_kratos
  jmp exgem17_original

exgem17_lloyd:
  mov dl,0x2A
  jmp EXGem17Return

exgem17_colette:
  mov dl,0x2A
  jmp EXGem17Return

exgem17_genis:
  mov dl,0x20
  jmp EXGem17Return

exgem17_raine:
  mov dl,0x15
  jmp EXGem17Return

exgem17_sheena:
  mov dl,0x0F
  jmp EXGem17Return

exgem17_zelos:
  mov dl,0x1C
  jmp EXGem17Return

exgem17_presea:
  mov dl,0x2A
  jmp EXGem17Return

exgem17_regal:
  mov dl,0x31
  jmp EXGem17Return

exgem17_kratos:
  mov dl,0x30
  jmp EXGem17Return

//################################################
//# Original skill lookup
//################################################

exgem17_original:
  // Execute the seven-byte instruction replaced by the hook.
  mov dl,[esi+edx*4+EXGem17Lookup]
  jmp EXGem17Return

//################################################
//# Install patches
//################################################

// Redirect the skill lookup to the extended character-specific handler.
TOS.exe+0xF34CD:
  jmp EXGem17Hook
  nop #2

// Increase the number of entries from 16 to 17.
TOS.exe+0xF34E6:
  db 0x3C, 0x11
