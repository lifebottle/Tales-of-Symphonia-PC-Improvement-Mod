//######################################################################################################
//# Regal - Healing Arte Cast Times
//# Reduces cast times for Healer, Grand Healer, and Chi Healer.
//# Values are customizable hexadecimal bytes.
//######################################################################################################
[ENABLE]

//################################################
//# Check original bytes
//################################################

// Original values taken from the supplied Cheat Engine [DISABLE] section.
assert(TOS.exe+0x4DCCEC,96)
assert(TOS.exe+0x4DCDAC,C3)
assert(TOS.exe+0x4DCD4C,C3)

//################################################
//# Healer cast time
//################################################

// Replace the original value 0x96 with 0x50.
TOS.exe+0x4DCCEC:
  db 0x50

//################################################
//# Grand Healer cast time
//################################################

// Replace the original value 0xC3 with 0x96.
TOS.exe+0x4DCDAC:
  db 0x96

//################################################
//# Chi Healer cast time
//################################################

// Replace the original value 0xC3 with 0xFA.
TOS.exe+0x4DCD4C:
  db 0xFA
