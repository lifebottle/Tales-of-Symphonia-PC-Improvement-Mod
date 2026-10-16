//######################################################################################################
//# Sheena - Persistent Tethe/Sylv Elemental Buffs
//# Prevents the original duration-related value from being written during combat.
//# Intended effect: Tethe/Sylv elemental buffs last for the entire battle.
//######################################################################################################
[ENABLE]

//################################################
//# Verify original instruction
//################################################

// Verify the entire 8-byte write before replacing it.
assert(TOS.exe+0x3C2E2,66 89 b4 5f 38 3a 01 00)

//################################################
//# Suppress the original write
//################################################

// Original: mov [edi+ebx*2+0x13A38],si
// Skipping this instruction is equivalent to the supplied CE hook,
// which immediately jumps to TOS.exe+0x3C2EA.
TOS.exe+0x3C2E2:
  nop #8
