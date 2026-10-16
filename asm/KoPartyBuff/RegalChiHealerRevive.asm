//######################################################################################################
//# Regal - Chi Healer Revival
//# Changes Chi Healer into a healing arte capable of reviving fallen allies.
//# Includes the supplied TP-cost and healing-percentage adjustments.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_regal_chi_healer_hook,0x80)

//################################################
//# Check original bytes
//################################################

// Original values taken from the supplied Cheat Engine [DISABLE] section.
assert(TOS.exe+0x4DCD49,02)
assert(TOS.exe+0x4DCD18,19)
assert(TOS.exe+0x1942F,E8 3C DA 02 00)
assert(TOS.exe+0x1949D,23)

//################################################
//# Addresses and functions
//################################################

define(RegalChiHealerCall,TOS.exe+0x32440)
define(RegalChiHealerReturn,TOS.exe+0x19434)

//################################################
//# Chi Healer healing and revival handling
//################################################

mem_regal_chi_healer_hook:
RegalChiHealerHook:
  // Execute the replacement healing call with an additional zero argument.
  mov eax,[esp]
  push 0x00
  call RegalChiHealerCall
  add esp,0x04

  // Convert state 0x12 to 0x03 for the revival behavior.
  mov eax,[esp]
  cmp byte ptr [eax+0x1AC],0x12
  jne regal_chi_healer_done
  mov byte ptr [eax+0x1AC],0x03

regal_chi_healer_done:
  jmp RegalChiHealerReturn

//################################################
//# Chi Healer balance adjustments
//################################################

// Apply the supplied TP-related and healing-value changes.
TOS.exe+0x4DCD49:
  db 0x22

TOS.exe+0x4DCD18:
  db 0x2A

TOS.exe+0x1949D:
  db 0x1E

//################################################
//# Install hook
//################################################

TOS.exe+0x1942F:
  jmp RegalChiHealerHook
