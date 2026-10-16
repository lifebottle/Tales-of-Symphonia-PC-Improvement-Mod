[ENABLE]
//######################################################################################################
//# Displays stat boosts upon level up when selecting titles.
//######################################################################################################
//################################################
//# Memory allocation
//################################################

// Storage for the text offset, colour and text buffer.
alloc(mem_boost_data,0x40)

// Code for displaying the boost numbers above the parameters.
alloc(mem_boost_hook,0x100)


//################################################
//# Check original instructions
//################################################

// Make sure the original function call is still present before hooking it.
assert(TOS.exe+0x12A040,e8 0b 82 00 00)


//################################################
//# Function addresses
//################################################

// Original function used to draw the text.
define(BoostTextFn,TOS.exe+0x132250)


//################################################
//# Register symbols
//################################################

// Make the settings, buffer and hook accessible in Cheat Engine.
registersymbol(BoostNumY)
registersymbol(BoostNumColor)
registersymbol(BoostBuf)
registersymbol(BoostHook)


//################################################
//# Display settings
//################################################

// Vertical offset: -22.
// Colour: 8.
mem_boost_data:
BoostNumY:
  dd 0xFFFFFFEA
BoostNumColor:
  db 0x08, 0x00, 0x00, 0x00

// Buffer used to build the formatted text, including the colour code and + sign.
BoostBuf:
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


//################################################
//# Boost number hook
//################################################

// Draw the boost number before continuing with the original text drawing.
mem_boost_hook:
BoostHook:
  pushad // Save the registers so the original function can continue normally.
  mov ecx, [esp+0x54]
  movzx eax, byte ptr [ecx] // Read the value used for the boost number.
  test eax, eax
  je bst_skipnum // Skip the extra number if the value is zero.


//################################################
//# Build the boost text
//################################################

// Add the game's text colour control code and configured colour.
  mov edi, BoostBuf
  mov byte ptr [edi], 0x0C
  mov dl, [BoostNumColor]
  mov [edi+#1], dl

// Add the + sign before the number.
  mov byte ptr [edi+#2], 0x2B
  add edi, #3

// Convert two-digit values into separate decimal characters.
  cmp eax, #10
  jb bst_onedigit
  xor edx, edx
  mov ecx, #10
  div ecx
  add al, 0x30
  mov [edi], al
  inc edi
  mov eax, edx

// Convert the remaining value into a decimal character.
bst_onedigit:
  add al, 0x30
  mov [edi], al
  mov byte ptr [edi+#1], #0


//################################################
//# Draw the boost number
//################################################

// Pass the drawing parameters along with the adjusted vertical position.
  push dword ptr [esp+0x38]
  push dword ptr [esp+0x38]
  push dword ptr [esp+0x38]
  push dword ptr [esp+0x38]
  mov eax, [esp+0x38]
  sub eax, [BoostNumY] // Apply the configured Y adjustment.
  push eax
  push dword ptr [esp+0x38]

// Draw the formatted boost number, then clean up the pushed arguments.
  mov eax, BoostBuf
  call BoostTextFn
  add esp, #24

// Restore the saved registers and continue with the original text drawing.
bst_skipnum:
  popad
  jmp BoostTextFn

//################################################
//# Install hook
//################################################

// Replace the original text function call with the custom hook.
// The hook draws the boost number first, then continues into the original function.
TOS.exe+0x12A040:
  call BoostHook