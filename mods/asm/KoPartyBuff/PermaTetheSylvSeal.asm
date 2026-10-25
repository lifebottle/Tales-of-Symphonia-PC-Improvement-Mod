
 //######################################################################################################
 //# Sheena - Persistent Tethe/Sylv Elemental Buffs
 //# Prevents elemental buff durations from decreasing during combat.
 //# Intended effect: Tethe/Sylv elemental buffs last for the entire battle.
 //# Other timed status effects, including poison, remain unaffected.
 //######################################################################################################

 //################################################
 //# Verify original instruction
 //################################################

 // Verify the entire 8-byte write before replacing it.
 assert(TOS.exe+0x3C2E2,66 89 B4 5F 38 3A 01 00)

 //################################################
 //# Allocate memory and define labels
 //################################################

 alloc(memSheenaBuff,0x100)

 label(decreaseDuration)
 label(returnSheenaBuff)

 //################################################
 //# Check elemental buff duration
 //################################################

 memSheenaBuff:
   pushfd

   // EBX = 0x20 identifies the elemental buff duration entry.
   cmp ebx,0x20
   jne decreaseDuration

   // Elemental buff: skip the original duration write.
   popfd
   jmp returnSheenaBuff

 //################################################
 //# Preserve other status effects
 //################################################

 decreaseDuration:
   // Other statuses: execute the original instruction.
   popfd
   mov [edi+ebx*2+00013A38],si
   jmp returnSheenaBuff

 //################################################
 //# Inject the conditional duration hook
 //################################################

 // Original: mov [edi+ebx*2+0x13A38],si
 // Replace the 8-byte instruction with a jump.
 // The hook skips the write only when EBX = 0x20.
 TOS.exe+0x3C2E2:
   jmp memSheenaBuff
   nop #3

 returnSheenaBuff:
