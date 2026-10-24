
 //######################################################################################################
 //# Regal - Healing Buff
 //# Improves Healer, Grand Healer, and Chi Healer casting times.
 //# Reduces distance-based healing penalties for Healer and Grand Healer.
 //# Enables Chi Healer to heal and revive fallen allies with adjusted TP cost and healing potency.
 //######################################################################################################
 [ENABLE]

 //################################################
 //# Memory allocation
 //################################################

 alloc(mem_regal_chi_healer_hook,0x100)
 alloc(mem_regal_healer_hook,0x80)
 alloc(mem_regal_grand_healer_hook,0x80)

 //################################################
 //# Check original instructions
 //################################################

 assert(TOS.exe+0x4DCD49,02)
 assert(TOS.exe+0x4DCD18,19)
 assert(TOS.exe+0x1942F,E8 3C DA 02 00)
 assert(TOS.exe+0x1949D,23)
 assert(TOS.exe+0x28654,8B 79 38 8B DF)
 assert(TOS.exe+0x3EF8E,8B 96 E8 84 8D 00)

 assert(TOS.exe+0x192EE,BA 05 00 00 00 66 2B D0)
 assert(TOS.exe+0x1966E,BA 09 00 00 00 66 2B D0)

 assert(TOS.exe+0x4DCCEC,96)
 assert(TOS.exe+0x4DCDAC,C3)
 assert(TOS.exe+0x4DCD4C,C3)

 //################################################
 //# Addresses and functions
 //################################################

 define(RegalChiHealerCall,TOS.exe+0x32440)
 define(RegalChiHealerReturn,TOS.exe+0x19434)
 define(RegalChiHealerTargetReturn,TOS.exe+0x28659)
 define(RegalChiHealerCastReturn,TOS.exe+0x3EF94)
 define(RegalChiHealerArte,TOS.exe+0x4DCD10)

 define(RegalHealerReturn,TOS.exe+0x192F6)
 define(RegalGrandHealerReturn,TOS.exe+0x19676)

 //################################################
 //# Chi Healer - Healing and revival
 //################################################

 mem_regal_chi_healer_hook:

 RegalChiHealerHook:
   mov eax,[esp]
   push 0x00
   call RegalChiHealerCall
   add esp,0x04

   mov eax,[esp]
   cmp byte ptr [eax+0x1AC],0x12
   jne regal_chi_healer_done
   mov byte ptr [eax+0x1AC],0x03

 regal_chi_healer_done:
   jmp RegalChiHealerReturn

 //################################################
 //# Chi Healer - Command-based targeting
 //################################################

 RegalChiHealerTargetHook:
   mov edi,[ecx+0x38]
   cmp ecx,RegalChiHealerArte
   jne regal_chi_healer_target_done
   or edi,0x2000

 regal_chi_healer_target_done:
   mov ebx,edi
   jmp RegalChiHealerTargetReturn

 //################################################
 //# Chi Healer - Manual casting targeting
 //################################################

 RegalChiHealerCastHook:
   pushfd
   cmp esi,0x4860
   jne regal_chi_healer_cast_done
   mov byte ptr [TOS.exe+0x4DCD49],0x22

 regal_chi_healer_cast_done:
   popfd
   mov edx,[esi+TOS.exe+0x4D84E8]
   jmp RegalChiHealerCastReturn

 //################################################
 //# Healer - Reduced distance penalty
 //################################################

 mem_regal_healer_hook:

 RegalHealerHook:
   sar ax,0x01
   mov edx,0x00000005
   sub dx,ax
   jmp RegalHealerReturn

 //################################################
 //# Grand Healer - Reduced distance penalty
 //################################################

 mem_regal_grand_healer_hook:

 RegalGrandHealerHook:
   sar ax,0x01
   mov edx,0x00000009
   sub dx,ax
   jmp RegalGrandHealerReturn

 //################################################
 //# Chi Healer - TP cost and healing adjustment
 //################################################

 TOS.exe+0x4DCD18:
   db 0x2A

 TOS.exe+0x1949D:
   db 0x1E

 //################################################
 //# Healer - Casting time
 //################################################

 TOS.exe+0x4DCCEC:
   db 0x50

 //################################################
 //# Grand Healer - Casting time
 //################################################

 TOS.exe+0x4DCDAC:
   db 0x96

 //################################################
 //# Chi Healer - Casting time
 //################################################

 TOS.exe+0x4DCD4C:
   db 0xFA

 //################################################
 //# Install Chi Healer revival hooks
 //################################################

 TOS.exe+0x1942F:
   jmp RegalChiHealerHook

 TOS.exe+0x28654:
   jmp RegalChiHealerTargetHook

 TOS.exe+0x3EF8E:
   jmp RegalChiHealerCastHook
   nop #1

 //################################################
 //# Install healing distance hooks
 //################################################

 TOS.exe+0x192EE:
   jmp RegalHealerHook
   nop #3

 TOS.exe+0x1966E:
   jmp RegalGrandHealerHook
   nop #3
