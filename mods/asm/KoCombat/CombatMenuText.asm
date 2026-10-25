//######################################################################################################
//# Tales of Symphonia - Expanded Command Menu Labels
//# Replaces six shortened battle command labels with longer text.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_command_labels_hook,0x800)

//################################################
//# Check original instructions
//################################################

// Covers the entire six-byte function prologue replaced by JMP + NOP.
assert(TOS.exe+0x60930,55 8B EC 83 EC 08)

//################################################
//# Return address
//################################################

define(CommandLabelsReturn,TOS.exe+0x60936)

//################################################
//# Find and replace command labels
//################################################

mem_command_labels_hook:
CommandLabelsHook:
  // Preserve registers while checking the text pointer in EAX.
  pushad
  test eax,eax
  je cmd_done
  mov esi,CommandLabelsTable

cmd_entry:
  // A zero byte at the start of an entry marks the end of the table.
  cmp byte ptr [esi],0x00
  je cmd_done
  mov edi,eax
  mov ecx,esi

cmd_compare:
  // Compare the original text against the first string in each pair.
  mov dl,[ecx]
  cmp dl,[edi]
  jne cmd_nomatch
  test dl,dl
  je cmd_found
  inc ecx
  inc edi
  jmp cmd_compare

cmd_found:
  // Point the saved EAX to the replacement string for POPAD to restore.
  lea eax,[ecx+0x01]
  mov [esp+0x1C],eax
  jmp cmd_done

cmd_nomatch:
  // Skip the original string, then its replacement string.
cmd_skip_original:
  cmp byte ptr [esi],0x00
  je cmd_original_end
  inc esi
  jmp cmd_skip_original

cmd_original_end:
  inc esi

cmd_skip_replacement:
  cmp byte ptr [esi],0x00
  je cmd_replacement_end
  inc esi
  jmp cmd_skip_replacement

cmd_replacement_end:
  inc esi
  jmp cmd_entry

cmd_done:
  // Execute the original function prologue before returning.
  popad
  push ebp
  mov ebp,esp
  sub esp,0x08
  jmp CommandLabelsReturn

//################################################
//# Original text / replacement text pairs
//################################################

// Maintain the same six replacements and their order as the working CE script.
CommandLabelsTable:
  db "U. Attack"
  db 0x00
  db "Unison Attack"
  db 0x00

  db "Strat"
  db 0x00
  db "Strategy"
  db 0x00

  db "Equip"
  db 0x00
  db "Equipment"
  db 0x00

  db "Escape"
  db 0x00
  db "Run Away"
  db 0x00

  db "Tech"
  db 0x00
  db "Tech"
  db 0x00

  db "Item"
  db 0x00
  db "Items"
  db 0x00

  db 0x00

//################################################
//# Install hook
//################################################

// Replace the six-byte prologue with a five-byte JMP and one NOP.
TOS.exe+0x60930:
  jmp CommandLabelsHook
  nop #1
