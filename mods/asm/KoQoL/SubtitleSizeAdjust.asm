[ENABLE]

//################################################
//# Removes black subtitles bar & reduces size.
//################################################

// Allocate memory for the values and the two hooks.
alloc(mem_style_const,0x20)
alloc(mem_style_size_hook,0x30)
alloc(mem_style_pos_hook,0x60)

// Make sure the original instructions are still there before patching.
assert(TOS.exe+0x8E061,0f b7 47 1c dd d8)
assert(TOS.exe+0x8E0EB,d9 5d f8 83 ec 10 d9 c9)

// Where to continue after the hooks are done.
define(StyleSizeReturn,TOS.exe+0x8E067)
define(StylePosReturn,TOS.exe+0x8E0F3)

// Make the values and hooks visible in Cheat Engine.
registersymbol(StyleSizeVal)
registersymbol(StyleDxVal)
registersymbol(StyleDyVal)
registersymbol(StyleSizeHook)
registersymbol(StylePosHook)


//################################################
//# Customize Values
//################################################

// Subtitle size: 0x18 = 24.
// Both position offsets start at 0.0.
mem_style_const:
StyleSizeVal:
   db 0x1F, 0x00
StyleDxVal:
  dd 0x00000000
StyleDyVal:
  dd 0x00000000


//################################################
//# Subtitle size hook
//################################################

// Replace the original size with our own value.
// This keeps the smaller size consistent when measuring and drawing subtitles.
mem_style_size_hook:
StyleSizeHook:
  movzx eax, word ptr [StyleSizeVal]
  mov word ptr [edi+0x1C], ax
  db 0xDD, 0xD8 // Pop the top x87 value, just like the original code.
  jmp StyleSizeReturn // Continue where the original code left off.


//################################################
//# Subtitle position hook
//################################################

// Adjust the subtitle coordinates using cuztomiz X and Y offsets.
// The original instructions are still executed, with the offsets added in between.
mem_style_pos_hook:
StylePosHook:
  db 0xD9, 0x5D, 0xF8 // Store the coordinate at [ebp-8] and pop ST(0).
  db 0xD9, 0x45, 0xF8 // Load the coordinate back onto the x87 stack.
  db 0xD8, 0x05 // Add the offset.
  dd StyleDyVal
  db 0xD9, 0x5D, 0xF8 // Store the adjusted coordinate.
  db 0xD9, 0x45, 0xFC // Load the other coordinate from [ebp-4].
  db 0xD8, 0x05 // Add the X offset.
  dd StyleDxVal
  db 0xD9, 0x5D, 0xFC // Store the adjusted coordinate.
  sub esp, #16 // Keep the original 16-byte stack allocation.
  db 0xD9, 0xC9 // Restore the original x87 register order.
  jmp StylePosReturn // Continue after the overwritten instructions.


//################################################
//# Apply the hooks
//################################################

// Redirect the original size code to the custom hook.
// The NOP fills the remaining overwritten byte.
TOS.exe+0x8E061:
  jmp StyleSizeHook
  nop #1

// Redirect the original position code to the custom hook.
// The NOPs fill the remaining overwritten bytes.
TOS.exe+0x8E0EB:
  jmp StylePosHook
  nop #3