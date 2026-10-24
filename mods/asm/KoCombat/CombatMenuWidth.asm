//######################################################################################################
//# Tales of Symphonia - Battle Command Box Widths
//# Substitutes short measurement strings for six battle command labels.
//# Companion patch for CommandLabels.asm; displayed text remains unchanged.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_command_width_hook,0x800)

//################################################
//# Check original instruction
//################################################

// Cover all seven bytes replaced by the JMP and two NOPs.
assert(TOS.exe+0x6BC79,8D 94 24 B4 00 00 00)

//################################################
//# Return address
//################################################

define(CommandWidthReturn,TOS.exe+0x6BC80)

//################################################
//# Find a replacement measurement string
//################################################

mem_command_width_hook:
CommandWidthHook:
  // Skip lookup when EAX contains no text pointer.
  test eax,eax
  je cmd_width_original

  // Preserve the working registers while checking string pairs.
  push ecx
  push edx
  push esi
  push edi
  mov esi,CommandWidthTable

cmd_width_entry:
  // A zero byte at the start of an entry ends the table.
  cmp byte ptr [esi],0x00
  je cmd_width_finish
  mov edi,eax
  mov ecx,esi

cmd_width_compare:
  // Compare the incoming text with the original string.
  mov dl,[ecx]
  cmp dl,[edi]
  jne cmd_width_skip_original
  test dl,dl
  je cmd_width_found
  inc ecx
  inc edi
  jmp cmd_width_compare

cmd_width_skip_original:
  // Advance past the original text.
  cmp byte ptr [esi],0x00
  je cmd_width_original_end
  inc esi
  jmp cmd_width_skip_original

cmd_width_original_end:
  inc esi

cmd_width_skip_replacement:
  // Advance past the associated measurement string.
  cmp byte ptr [esi],0x00
  je cmd_width_replacement_end
  inc esi
  jmp cmd_width_skip_replacement

cmd_width_replacement_end:
  inc esi
  jmp cmd_width_entry

cmd_width_found:
  // Point EAX to the shorter text used by the width routine.
  lea eax,[ecx+0x01]

cmd_width_finish:
  pop edi
  pop esi
  pop edx
  pop ecx

cmd_width_original:
  // Replay the original seven-byte instruction and continue.
  lea edx,[esp+0xB4]
  jmp CommandWidthReturn

//################################################
//# Original label / measurement text pairs
//################################################

// Preserve the exact text and ordering from the working CE script.
CommandWidthTable:
  db "U. Attack"
  db 0x00
  db "Uniso."
  db 0x00

  db "Strat"
  db 0x00
  db "Str"
  db 0x00

  db "Equip"
  db 0x00
  db "Equi"
  db 0x00

  db "Escape"
  db 0x00
  db "Run "
  db 0x00

  db "Tech"
  db 0x00
  db "Te"
  db 0x00

  db "Item"
  db 0x00
  db "It"
  db 0x00

  db 0x00

//################################################
//# Install hook
//################################################

TOS.exe+0x6BC79:
  jmp CommandWidthHook
  nop #2
