//######################################################################################################
//# Regal - Healer / Grand Healer Distance Penalty
//# Reduces the distance penalty applied when using these healing artes.
//# Preserves the original base values and return paths.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_regal_healer_hook,0x80)
alloc(mem_regal_grand_healer_hook,0x80)

//################################################
//# Check original instructions
//################################################

// Each hook replaces one complete 8-byte instruction sequence.
assert(TOS.exe+0x192EE,BA 05 00 00 00 66 2B D0)
assert(TOS.exe+0x1966E,BA 09 00 00 00 66 2B D0)

//################################################
//# Return addresses
//################################################

define(RegalHealerReturn,TOS.exe+0x192F6)
define(RegalGrandHealerReturn,TOS.exe+0x19676)

//################################################
//# Healer - reduced distance penalty
//################################################

mem_regal_healer_hook:
RegalHealerHook:
  // Halve the distance-related input before subtracting it from 5.
  sar ax,0x01
  mov edx,0x00000005
  sub dx,ax
  jmp RegalHealerReturn

//################################################
//# Grand Healer - reduced distance penalty
//################################################

mem_regal_grand_healer_hook:
RegalGrandHealerHook:
  // Halve the distance-related input before subtracting it from 9.
  sar ax,0x01
  mov edx,0x00000009
  sub dx,ax
  jmp RegalGrandHealerReturn

//################################################
//# Install hooks
//################################################

TOS.exe+0x192EE:
  jmp RegalHealerHook
  nop #3

TOS.exe+0x1966E:
  jmp RegalGrandHealerHook
  nop #3
