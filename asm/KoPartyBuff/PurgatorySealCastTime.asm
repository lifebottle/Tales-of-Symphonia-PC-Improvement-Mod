//######################################################################################################
//# Purgatory Seal - Reduced Casting Time
//# Replaces the original casting-time value (0x76) with 0x20.
//######################################################################################################
[ENABLE]

//################################################
//# Verify original byte
//################################################

// The patch changes one byte; the assertion covers that exact address.
assert(TOS.exe+0x4DBA2C,78)

//################################################
//# Purgatory Seal casting time
//################################################

// Change 0x20 to another hexadecimal value to customize the casting time.
TOS.exe+0x4DBA2C:
  db 0x20
