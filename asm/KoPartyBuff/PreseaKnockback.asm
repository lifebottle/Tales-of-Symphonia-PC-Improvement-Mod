//######################################################################################################
//# Tales of Symphonia - Presea Arte Knockback Adjustment
//# Reduces knockback for selected Punishment and Destruction artes to improve combo connections.
//# Preserves the original handling of Rising Punishment and Infinite Destruction.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_presea_knockback_hook,0x200)

//################################################
//# Check original instruction bytes
//################################################

// Original: mov [ebp-0x01],cl / mov bl,0x01 (5 bytes total).
assert(TOS.exe+0x36712,88 4D FF B3 01)

//################################################
//# Return address
//################################################

define(PreseaKnockbackReturn,TOS.exe+0x36717)

//################################################
//# Presea arte knockback checks
//################################################

mem_presea_knockback_hook:
PreseaKnockbackHook:
  // Preserve flags while checking the active arte.
  pushfd

  // Punishment-family IDs 0x5F and 0x60:
  // suppress knockback values from 2 through 5.
  cmp word ptr [edi+0x1422],0x5F
  je presea_check_strength
  cmp word ptr [edi+0x1422],0x60
  je presea_check_strength

  // Rising Punishment: retain original knockback.
  cmp word ptr [edi+0x1422],0x62
  je presea_finish

  // Selected Destruction-family artes: remove knockback.
  cmp word ptr [edi+0x1422],0x5A
  je presea_zero_knockback
  cmp word ptr [edi+0x1422],0x5B
  je presea_zero_knockback
  cmp word ptr [edi+0x1422],0x5D
  jne presea_finish

presea_zero_knockback:
  mov cl,0x00

presea_check_strength:
  // Preserve the original conditional range check.
  cmp cl,0x02
  jb presea_finish
  cmp cl,0x05
  ja presea_finish
  mov cl,0x00

presea_finish:
  // Restore flags and both instructions displaced by the hook.
  popfd
  mov [ebp-0x01],cl
  mov bl,0x01
  jmp PreseaKnockbackReturn

//################################################
//# Install hook
//################################################

TOS.exe+0x36712:
  jmp PreseaKnockbackHook
