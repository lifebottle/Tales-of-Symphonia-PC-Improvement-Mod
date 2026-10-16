//################################################
//# Arte level adjustments
//################################################
[ENABLE]

//################################################
//# Check original values
//################################################

// Level 2 = 0x08; the third value is inferred from Ring Whirlwind's level.
assert(TOS.exe+0x4DB7E8,08)
assert(TOS.exe+0x4DBCC8,08)
assert(TOS.exe+0x4D95C8,08)

//################################################
//# Apply arte level changes
//################################################

// Spirit Seal: Level 2 -> Level 3.
TOS.exe+0x4DB7E8:
  db 0x10

// Lightning Blade: Level 2 -> Level 1.
TOS.exe+0x4DBCC8:
  db 0x04

// Ring Whirlwind: Level 2 -> Level 1.
TOS.exe+0x4D95C8:
  db 0x04
