//#######################################################################################################
//# Allows parameter-boosting titles to be equipped along costume titles. 'A' will equip the title
//# as normal; 'X' equips the costume only.
//#######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

// Allocate memory for the costume data, names and hooks.
alloc(mem_cos_data,0x100)
alloc(mem_cos_names,0x400)
alloc(mem_cos_name_hook,0x200)
alloc(mem_cos_end_hook,0x100)
alloc(mem_cos_input_hook,0x80)
alloc(mem_cos_title_hook,0x60)
alloc(mem_cos_wrapper,0x100)

//################################################
//# Check original instructions
//################################################

// Make sure the original code matches before installing the hooks.
assert(TOS.exe+0x1323C1,5f 5e 5b 8b e5)
assert(TOS.exe+0x12A227,f7 c6 00 00 00 04 0f 85 d3 01 00 00)
assert(TOS.exe+0x12A437,66 89 94 39 76 03 00 00)
assert(TOS.exe+0x12A44C,e8 ff de ff ff)
assert(TOS.exe+0x129C28,e8 23 86 00 00)

//################################################
//# Addresses and functions
//################################################

// Addresses used to read character data, track the selected row
// and call the game's original costume and drawing functions.
define(CosPartyPtr,TOS.exe+0x6D3F68)
define(CosInputWord,TOS.exe+0x7148B0)
define(CosRowCaller,TOS.exe+0x129C2D)
define(CosScrollBase,TOS.exe+0x4F0184)
define(CosScrollFlag,TOS.exe+0x4F0186)
define(CosRowTable,TOS.exe+0x4F018A)
define(CosCharIdx,TOS.exe+0x4F0181)
define(CosDrawIcon,TOS.exe+0x131B70)
define(CosEquipFn,TOS.exe+0x128350)
define(CosTextFn,TOS.exe+0x132250)

// Return addresses for the hooks.
define(CosNameReturn,TOS.exe+0x129C2D)
define(CosEndReturn,TOS.exe+0x1323C6)
define(CosInputYes,TOS.exe+0x12A406)
define(CosInputNo,TOS.exe+0x12A233)
define(CosTitleReturn,TOS.exe+0x12A43F)

//################################################
//# Register symbols
//################################################

// Make the main variables and hooks accessible in Cheat Engine.
registersymbol(CosXMode)
registersymbol(CosXPrev)
registersymbol(CosXOldTitle)
registersymbol(CosXOldCostume)
registersymbol(CosXNewTitle)
registersymbol(CosSelArr)
registersymbol(CosIsCostume)
registersymbol(CosIsSel)
registersymbol(CosCfgColor)
registersymbol(CosCfgSelColor)
registersymbol(CosCfgSelIcon)
registersymbol(CosBuf)
registersymbol(CosNames)
registersymbol(CosNameHook)
registersymbol(CosEndHook)
registersymbol(CosInputHook)
registersymbol(CosTitleHook)
registersymbol(CosWrapper)
registersymbol(CosHintX)
registersymbol(CosHintY)
registersymbol(CosHintStr)
registersymbol(CosNameTwinsies)

//################################################
//# Costume selection data
//################################################

mem_cos_data:

// Tracks whether X is being used to switch between costume and title.
CosXMode:
  dd 0x00000000

// Prevents the X input from triggering repeatedly while held down.
CosXPrev:
  dd 0x00000000

// Stores the title before it gets replaced.
CosXOldTitle:
  dd 0x00000000

// Stores the costume before the change.
CosXOldCostume:
  dd 0x00000000

// Stores the newly selected title.
CosXNewTitle:
  dd 0x00000000

// Stores the selected costume for each character.
CosSelArr:
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

// Flags used when drawing costume names and selection icons.
CosIsCostume:
  dd 0x00000000
CosIsSel:
  dd 0x00000000

// Colour used for costume names.
CosCfgColor:
  db 0x08, 0x00, 0x00, 0x00

// Colour used for the currently selected costume name.
CosCfgSelColor:
  db 0x06, 0x00, 0x00, 0x00

// Icon displayed next to the selected costume name.
CosCfgSelIcon:
  dd 0xA2390004

// Buffer used to add colour formatting to costume names before drawing them.
CosBuf:
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

// Hint line position, relative to the first title row (signed, canvas units).
CosHintX:
  dd 0x000000D2    // left/right (negative = left)
CosHintY:
  dd 0xFFFFFFFA    // up/down (negative = up; 0xFFFFFFE2 = -30)
// Hint text: 0x0B + glyph index, then the words. Change the byte after 0x0B to pick the X button glyph.
CosHintStr:
  db 0x0B, 0x0A
  db " Costume Only"
  db 0x00
  db 0x00, 0x00

//################################################
//# Costume names
//################################################
// These names get the custom colour and costume icon.
mem_cos_names:
CosNames:
  db "Nobleman"
  db 0x00
  db "Arrgh, Me Hearties"
  db 0x00
  db "Beach Boy"
  db 0x00
  db "Unrivaled Blade"
  db 0x00
  db "Guardian"
  db 0x00
  db "Maid"
  db 0x00
  db "Fair Lady"
  db 0x00
  db "Mermaid"
  db 0x00
  db "Genius Researcher"
  db 0x00
  CosNameTwinsies: //Filter due to <3 symbol.
  db "Twinsies"
  db 0x00
  db "Easter Sunday"
  db 0x00
  db "Katz Katz Katz"
  db 0x00
  db "Beach Comber"
  db 0x00
  db "I'm Not Cold!"
  db 0x00
  db "Noble Son"
  db 0x00
  db "Glamorous Beauty"
  db 0x00
  db "Maiden"
  db 0x00
  db "No, Not the Sun!"
  db 0x00
  db "Chosen Beauty"
  db 0x00
  db "Vagabond"
  db 0x00
  db "Judgment"
  db 0x00
  db "Steel Demon"
  db 0x00
  db "Transforming Agent"
  db 0x00
  db "You Look Great!"
  db 0x00
  db "Successor"
  db 0x00
  db "Queen of the Beach"
  db 0x00
  db "Star Straddler"
  db 0x00
  db "Blastia Hunter"
  db 0x00
  db "Narcissist"
  db 0x00
  db "Masked Swordsman"
  db 0x00
  db "Pickup Artist"
  db 0x00
  db "Altamiran Rider"
  db 0x00
  db "Sword For Hire"
  db 0x00
  db "Little Madam"
  db 0x00
  db "Dream Traveler"
  db 0x00
  db "First-timer at Sea"
  db 0x00
  db "Gentle Warmth"
  db 0x00
  db "Plush Channeller"
  db 0x00
  db "Dandy"
  db 0x00
  db "God of The Kitchen"
  db 0x00
  db "Swimmer"
  db 0x00
  db "The Duke"
  db 0x00
  db "Knight Academy Instructor"
  db 0x00
  
//################################################
//# Costume name hook
//################################################
mem_cos_name_hook:
CosNameHook:
  mov byte ptr [CosIsCostume], #0
  mov byte ptr [CosIsSel], #0

// Work out whether this row is the costume picked with X.
  pushad
  movsx eax, word ptr [CosScrollBase]
  cmp word ptr [CosScrollFlag], #0
  jle cos_skipdec
  dec eax
cos_skipdec:
  add eax, ebx
  movzx edx, byte ptr [eax+CosRowTable]
  inc edx
  movzx ecx, byte ptr [CosCharIdx]
  mov eax, [CosPartyPtr]
  movsx ecx, byte ptr [ecx+eax+0x0F4D]
  dec ecx
  mov eax, CosSelArr
  cmp dl, [eax+ecx]
  jne cos_nosel
  mov byte ptr [CosIsSel], #1
cos_nosel:
  popad

// Draw the hint once per frame, on the first row only.
  test ebx, ebx
  jne cos_nohint
  pushad
  push dword ptr [esp+0x34]
  push dword ptr [esp+0x34]
  push dword ptr [esp+0x34]
  push dword ptr [esp+0x34]
  mov eax, [esp+0x34]
  add eax, [CosHintY]
  push eax
  mov eax, [esp+0x34]
  add eax, [CosHintX]
  push eax
  mov eax, CosHintStr
  call CosTextFn
  add esp, #24
  popad
cos_nohint:

// Check the row text against the costume names.
  push ecx
  push edx
  push esi
  push edi
  test eax, eax
  je cos_done
  mov esi, CosNames
cos_nameloop:
  cmp byte ptr [esi], #0
  je cos_done
  mov edi, eax
  mov ecx, esi
cos_cmploop:
  mov dl, [ecx]
  test dl, dl
  je cos_nameend
  cmp dl, [edi]
  jne cos_skipname
  inc ecx
  inc edi
  jmp cos_cmploop
cos_nameend:
  cmp esi, CosNameTwinsies
  je cos_match
  cmp byte ptr [edi], #0
  je cos_match
  jmp cos_skipname
cos_skipname:
  cmp byte ptr [esi], #0
  je cos_skipend
  inc esi
  jmp cos_skipname
cos_skipend:
  inc esi
  jmp cos_nameloop
cos_match:
  mov byte ptr [CosIsCostume], #1
  mov edi, CosBuf
  mov byte ptr [edi], 0x0C
  mov dl, [CosCfgColor]
  cmp byte ptr [CosIsSel], #0
  je cos_nocol
  mov dl, [CosCfgSelColor]
cos_nocol:
  mov [edi+#1], dl
  add edi, #2
  mov esi, eax
cos_copyloop:
  mov dl, [esi]
  mov [edi], dl
  inc esi
  inc edi
  test dl, dl
  jne cos_copyloop
  mov eax, CosBuf
cos_done:
  pop edi
  pop esi
  pop edx
  pop ecx
// Make the original call that this hook replaced, then continue.
  call CosTextFn
  jmp CosNameReturn

//################################################
//# Costume icons
//################################################

// Draw the costume icon next to a matching name.
// When the costume is selected, draw an additional selection icon.
mem_cos_end_hook:
CosEndHook:
  cmp byte ptr [CosIsCostume], #0
  je cos_endorig
  pushad
  movzx eax, word ptr [ebp+0x08]
  add eax, #6
  mov ecx, [ebp+0x0C]
  add ecx, #6
  push 0xFFFFFFFF
  push 0x40
  push 0x40
  push 0x24
  push 0x24
  push ecx
  push eax
  push 0x0EE1
  push 0xA2390018
  call CosDrawIcon
  add esp, #36

// Draw the extra icon only when the costume is selected.
  cmp byte ptr [CosIsSel], #0
  je cos_nosel2
  movzx eax, word ptr [ebp+0x08]
  add eax, 0x2E
  mov ecx, [ebp+0x0C]
  add ecx, #6
  push 0xFFFFFFFF
  push 0x40
  push 0x40
  push 0x24
  push 0x24
  push ecx
  push eax
  push 0x0EE1
  push dword ptr [CosCfgSelIcon]
  call CosDrawIcon
  add esp, #36
cos_nosel2:
  mov byte ptr [CosIsCostume], #0

// Restore the original registers and finish the drawing function.
  popad
cos_endorig:
  pop edi
  pop esi
  pop ebx
  mov esp, ebp
  jmp CosEndReturn

//################################################
//# X button input
//################################################

// Detect a new press of X instead of triggering repeatedly while held.
// The mode flag tells the other hooks that X is being used for this change.
mem_cos_input_hook:
CosInputHook:
  push eax
  mov byte ptr [CosXMode], #0
  mov eax, [CosInputWord]
  test eax, 0x00004000
  jne cos_xdown
  mov byte ptr [CosXPrev], #0
  jmp cos_inputdone
cos_xdown:
  cmp byte ptr [CosXPrev], #1
  je cos_inputdone
  mov byte ptr [CosXPrev], #1
  mov byte ptr [CosXMode], #1
  or esi, 0x04000000
cos_inputdone:
  pop eax
  test esi, 0x04000000
  jne CosInputYes
  jmp CosInputNo

//################################################
//# Title selection hook
//################################################

// While X is being used, save the previous title and the newly selected title.
// The original title write still happens after these values are stored.
mem_cos_title_hook:
CosTitleHook:
  cmp byte ptr [CosXMode], #0
  je cos_doit
  push eax
  mov ax, [ecx+edi+0x376]
  mov [CosXOldTitle], ax
  mov [CosXNewTitle], dx
  pop eax
cos_doit:
  mov [ecx+edi+0x376], dx
  jmp CosTitleReturn

//################################################
//# Costume and title handling
//################################################

// Call the original costume equip function, then restore the previous
// costume or title when needed so both can be kept at the same time.
mem_cos_wrapper:
CosWrapper:
  push ebx
  push ecx
  push edx
  movsx ecx, word ptr [esp+0x10]
  imul ecx, ecx, 0x118
  add ecx, [CosPartyPtr]
  lea ecx, [ecx+0x368]
  mov dl, [ecx+0x11]
  mov [CosXOldCostume], dl
  push dword ptr [esp+0x10]
  call CosEquipFn
  add esp, #4
  movsx ecx, word ptr [esp+0x10]
  imul ecx, ecx, 0x118
  add ecx, [CosPartyPtr]
  lea ecx, [ecx+0x368]

// Handle the costume/title selection depending on whether X was pressed.
  cmp byte ptr [CosXMode], #0
  jne cos_isx
  cmp byte ptr [ecx+0x11], #0
  jne cos_wfin
  mov dl, [CosXOldCostume]
  mov [ecx+0x11], dl
  jmp cos_wfin

// Restore the previous title and update the selected costume entry.
cos_isx:
  mov ax, [CosXOldTitle]
  mov [ecx+0x0E], ax
  mov byte ptr [CosXMode], #0
  movzx eax, byte ptr [CosXNewTitle+#1]
  xor edx, edx
  cmp byte ptr [ecx+0x11], #0
  je cos_storesel
  mov dl, [CosXNewTitle]
cos_storesel:
  mov ebx, CosSelArr
  mov [ebx+eax], dl

// Restore registers and return to the original caller.
cos_wfin:
  pop edx
  pop ecx
  pop ebx
  ret

//################################################
//# Install hooks
//################################################

// Hook the costume-name text drawing function.
TOS.exe+0x129C28:
  jmp CosNameHook

// Hook the end of the text drawing function to draw costume icons.
TOS.exe+0x1323C1:
  jmp CosEndHook

// Hook X button input.
TOS.exe+0x12A227:
  jmp CosInputHook
  nop #7

// Hook title selection to save the previous and newly selected titles.
TOS.exe+0x12A437:
  jmp CosTitleHook
  nop #3

// Hook costume selection to preserve the costume/title combination.
TOS.exe+0x12A44C:
  call CosWrapper