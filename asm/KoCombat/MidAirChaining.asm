//######################################################################################################
//# Mid-Air Arte Chaining
//# Allows artes to be chained during mid-air combat.
//# Requires the MidAirArtes feature.
//######################################################################################################
[ENABLE]

//################################################
//# Verify original instructions
//################################################

// Check the preceding comparison from the original AOB signature.
assert(TOS.exe+0x3EFC8,80 7d 10 00)

// Verify every byte replaced by the unconditional jump and NOP.
assert(TOS.exe+0x3EFCC,0f 84 7d 02 00 00)

//################################################
//# Mid-air chaining branch
//################################################

// Replace the conditional JE with a JMP to TOS.exe+0x3F24F.
// The trailing NOP preserves the original six-byte instruction span.
TOS.exe+0x3EFCC:
  db 0xE9, 0x7E, 0x02, 0x00, 0x00, 0x90
