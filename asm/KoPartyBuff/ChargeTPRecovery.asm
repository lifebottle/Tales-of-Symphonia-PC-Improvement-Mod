//######################################################################################################
//# Charge - Percentage-Based TP Recovery
//# Restores 5% of the target's maximum TP when Charge is used.
//# Uses the same recovery amount for floating and portrait TP notifications.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

// Hook code is executable; the recovery amount is writable data.
alloc(mem_charge_code,0x200)
alloc(mem_charge_data,0x10)

//################################################
//# Check original instructions
//################################################

// Restore TP: original 5-byte add word ptr [eax+0x2A],0x0E.
assert(TOS.exe+0x16650,66 83 40 2A 0F)

// Floating number: original 2-byte push 0x0F and 3-byte mov [eax+0x08],edx.
assert(TOS.exe+0x16684,6A 0F 89 50 08)

// Portrait number: original 2-byte push 0x0F, push 0x01, mov eax,edi.
assert(TOS.exe+0x1668E,6A 0F 6A 01 8B C7)

//################################################
//# Return addresses
//################################################

define(ChargeRestoreReturn,TOS.exe+0x16655)
define(ChargeFloatingReturn,TOS.exe+0x16689)
define(ChargePortraitReturn,TOS.exe+0x16694)

//################################################
//# Shared TP recovery amount
//################################################

registersymbol(ChargeAmount)

mem_charge_data:
ChargeAmount:
  dd 0x00000000

//################################################
//# Charge TP restoration
//################################################

mem_charge_code:
ChargeRestoreHook:
  // Preserve original registers and flags while calculating the recovery.
  pushfd
  pushad

  // EAX initially points to the target's battle stats.
  mov ecx,eax
  movzx eax,word ptr [ecx+0x28]
  imul eax,eax,0x05
  xor edx,edx
  mov ebx,0x64           // Divide by 100 decimal to obtain 5%.
  div ebx

  // Save the amount for both displays and add it to current TP.
  mov [ChargeAmount],eax
  add word ptr [ecx+0x2A],ax

  popad
  popfd
  jmp ChargeRestoreReturn

//################################################
//# Floating recovery number
//################################################

ChargeFloatingHook:
  // Replace fixed +15 with the calculated TP recovery amount.
  push dword ptr [ChargeAmount]
  mov [eax+0x08],edx
  jmp ChargeFloatingReturn

//################################################
//# Portrait recovery number
//################################################

ChargePortraitHook:
  // Use the same amount in the portrait notification.
  push dword ptr [ChargeAmount]
  push 0x01
  mov eax,edi
  jmp ChargePortraitReturn

//################################################
//# Install hooks
//################################################

TOS.exe+0x16650:
  jmp ChargeRestoreHook

TOS.exe+0x16684:
  jmp ChargeFloatingHook

TOS.exe+0x1668E:
  jmp ChargePortraitHook
  nop #1
