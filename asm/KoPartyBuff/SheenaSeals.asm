//################################################
//# Sheena - Life Seal and Spirit Seal
//################################################
//# Increases Life Seal recovery from 10% to 30%
//# and Spirit Seal recovery from 3% to 4%.
//# Immediate values can be adjusted independently.
//################################################

[ENABLE]

//################################################
//# Check original instructions
//################################################

// Verify the complete instruction ranges before patching.
assert(TOS.exe+0xA31A,8d 0c 80 03 c9)
assert(TOS.exe+0xA4DA,8d 0c 40)

//################################################
//# Life Seal - 30% of damage dealt
//################################################

// Replace the original x10 calculation with x30.
// Change 0x1E to adjust the multiplier.
TOS.exe+0xA31A:
  db 0x6B, 0xC8, 0x1E, 0x90, 0x90

//################################################
//# Spirit Seal - 4% of damage dealt
//################################################

// Replace the original x3 calculation with x5.
// Change 0x05 to adjust the multiplier.
TOS.exe+0xA4DA:
  db 0x6B, 0xC8, 0x04
