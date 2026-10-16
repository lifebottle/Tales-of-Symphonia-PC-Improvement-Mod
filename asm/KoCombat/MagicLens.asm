//######################################################################################################
//# Magic Lens - Always show enemy HP/TP when targeting
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_lens_hook,0x80)

//################################################
//# Check original instruction
//################################################

// Verify all seven bytes replaced by the JMP and two NOPs.
assert(TOS.exe+0x5F2E4,80 bb b9 90 00 00 05)

//################################################
//# Return address
//################################################

define(LensReturn,TOS.exe+0x5F2EB)

//################################################
//# Enemy HP/TP visibility
//################################################

mem_lens_hook:
LensHook:
  // Set the visibility byte to FF so enemy HP/TP can be viewed without using a Magic Lens.
  or byte ptr [ebx+0x9396], 0xFF

  // Execute the original comparison before returning to the game.
  cmp byte ptr [ebx+0x90B9], #5
  jmp LensReturn

//################################################
//# Install hook
//################################################

TOS.exe+0x5F2E4:
  jmp LensHook
  nop #2
