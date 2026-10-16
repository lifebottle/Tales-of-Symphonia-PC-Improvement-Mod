//######################################################################################################
//# Tales of Symphonia - Player Shadow Scale
//# Enlarges the shadow transform used for player shadows in towns and dungeons.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_shadow_code,0x100)
alloc(mem_shadow_settings,0x10)

//################################################
//# Check original instructions
//################################################

// All five bytes overwritten by the jump.
assert(TOS.exe+0xDAC7A,B9 10 00 00 00)

// Neighboring instructions, retained as checks from the CE script.
assert(TOS.exe+0xDAC7F,8D B5 C0 FD FF FF)
assert(TOS.exe+0xDAC75,E8 66 A2 0C 00)

//################################################
//# Addresses and settings
//################################################

define(ShadowReturn,TOS.exe+0xDAC7F)

registersymbol(ShadowScale)

// Writable floating-point multiplier (1.4f = 0x3FB33333).
mem_shadow_settings:
ShadowScale:
  dd 0x3FB33333

//################################################
//# Scale the player shadow transform
//################################################

mem_shadow_code:
ShadowScaleHook:
  // Preserve flags, EAX, and XMM0 during the calculation.
  pushfd
  push eax
  sub esp,0x10
  movdqu [esp],xmm0

  // Scale the first 12 floats at [EBP-0x240].
  // The final four floats (including expected translation) remain unchanged.
  lea eax,[ebp-0x240]
  mov ecx,0x0C

shadow_scale_loop:
  movss xmm0,[eax]
  mulss xmm0,[ShadowScale]
  movss [eax],xmm0
  add eax,0x04
  dec ecx
  jnz shadow_scale_loop

  // Restore registers and replay the original instruction.
  movdqu xmm0,[esp]
  add esp,0x10
  pop eax
  popfd
  mov ecx,0x10
  jmp ShadowReturn

//################################################
//# Install hook
//################################################

TOS.exe+0xDAC7A:
  jmp ShadowScaleHook
