//######################################################################################################
//# Tales of Symphonia - Mid-Air Artes Without Sky Cancel
//# Allows selected Lloyd, Kratos and Presea artes to be used mid-air without Sky Cancel.
//# Keeps the existing Sky Cancel check and the original denied path for unlisted artes.
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

alloc(mem_midair_hook,0x400)

//################################################
//# Check original instructions
//################################################

// The first hook replaces a 10-byte test and conditional jump.
assert(TOS.exe+0x3F62D,F6 43 38 40 0F 84 0F FF FF FF)

// The second patch changes JNE to JMP, retaining its original displacement.
assert(TOS.exe+0x3F645,75 14)

//################################################
//# Return addresses
//################################################

define(MidAirReturn,TOS.exe+0x3F637)
define(MidAirDenied,TOS.exe+0x3F546)

//################################################
//# Mid-air arte permission check
//################################################

mem_midair_hook:
MidAirHook:
  // Preserve the original Sky Cancel check.
  test byte ptr [ebx+0x38],0x40
  jne midair_allowed

  // Lloyd: Tiger Blade, Tiger Rage, Heavy Tiger Blade,
  // Twin Tiger Blade, Tempest, Omega Tempest, Psi Tempest,
  // Raging Beast, Hunting Beast and Rising Falcon.
  cmp word ptr [ebx],0x06
  je midair_allowed
  cmp word ptr [ebx],0x07
  je midair_allowed
  cmp word ptr [ebx],0x08
  je midair_allowed
  cmp word ptr [ebx],0x09
  je midair_allowed
  cmp word ptr [ebx],0x11
  je midair_allowed
  cmp word ptr [ebx],0x12
  je midair_allowed
  cmp word ptr [ebx],0x13
  je midair_allowed
  cmp word ptr [ebx],0x15
  je midair_allowed
  cmp word ptr [ebx],0x16
  je midair_allowed
  cmp word ptr [ebx],0x1D
  je midair_allowed

  // Kratos: Light Spear, Victory Light Spear,
  // Hell Pyre and Fierce Demon Fang.
  cmp word ptr [ebx],0x51
  je midair_allowed
  cmp word ptr [ebx],0x52
  je midair_allowed
  cmp word ptr [ebx],0x54
  je midair_allowed
  cmp word ptr [ebx],0x04
  je midair_allowed

  // Presea: Destruction family, Infliction family,
  // Punishment family, Devastation family and Eternal artes.
  cmp word ptr [ebx],0x5A  // Destruction
  je midair_allowed
  cmp word ptr [ebx],0x5B  // Deadly Destruction
  je midair_allowed
  cmp word ptr [ebx],0x5C  // Infinite Destruction
  je midair_allowed
  cmp word ptr [ebx],0x5D  // Fiery Destruction
  je midair_allowed
  cmp word ptr [ebx],0x63  // Infliction
  je midair_allowed
  cmp word ptr [ebx],0x64  // Dual Infliction
  je midair_allowed
  cmp word ptr [ebx],0x60  // Dual Punishment
  je midair_allowed
  cmp word ptr [ebx],0x61  // Rising Punishment
  je midair_allowed
  cmp word ptr [ebx],0x67  // Devastation
  je midair_allowed
  cmp word ptr [ebx],0x68  // Finite Devastation
  je midair_allowed
  cmp word ptr [ebx],0x69  // Mass Devastation
  je midair_allowed
  cmp word ptr [ebx],0x6B  // Eternal Damnation
  je midair_allowed
  cmp word ptr [ebx],0x6F  // Eternal Devastation
  je midair_allowed

  // Unlisted artes continue along the original failed-check path.
  jmp MidAirDenied

midair_allowed:
  // Resume immediately after the displaced instruction.
  jmp MidAirReturn

//################################################
//# Install patches
//################################################

// Replace the original Sky Cancel check with the filtered arte check.
TOS.exe+0x3F62D:
  jmp MidAirHook
  nop #5

// Preserve the CE script's JNE -> JMP change.
TOS.exe+0x3F645:
  db 0xEB
