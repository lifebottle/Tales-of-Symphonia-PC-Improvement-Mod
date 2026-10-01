// Port of TOS NoTSFix v26.9.6 CT entry 3179, Enhanced Holy Bottles (sd).
// Enable with [QoL] EnhancedHolyBottles=1. An active Holy Bottle forces
// encounter dodge; holding B/Circle bypasses that suppression. Without a
// bottle, retain the native Dodge skill search and chance calculation.
// Shares both sites with [Debug] DisableEncounters: enable only one option.
[ENABLE]
define(dodge_skill_site,TOS.exe+8E230)
define(dodge_skill_return,TOS.exe+8E238)
define(dodge_skill_found,TOS.exe+8E254)
define(encounter_chance_site,TOS.exe+D65FF)
define(encounter_chance_return,TOS.exe+D6618)
define(held_buttons,TOS.exe+19EA6D0)
define(game_state,TOS.exe+6D3F68)
define(dodge_chance_divisor,TOS.exe+482A98)

assert(dodge_skill_site,0F B6 B4 02 EE 00 00 00)
assert(dodge_skill_return,3B F1 74 18 40 83 F8 04 7C EE)
assert(dodge_skill_found,8B 4D FC 5E 33 CD B8 01 00 00 00 5B)
assert(encounter_chance_site,0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24)
// Retain the RNG call and native modulo-101/comparison sequence.
assert(encounter_chance_return,FF D7 99 B9 65 00 00 00 F7 F9 89 54 24 20 DB 44 24 20 D9 44 24 24 DE D9 DF E0 F6 C4 41 75 0E)
assert(dodge_chance_divisor,00 00 00 00 00 00 F8 3F)

alloc(holy_bottle_code,1000)
label(native_skill_search)
label(encounter_chance)
label(native_chance)
label(bottle_cancel)
label(bottle_chance)

holy_bottle_code:
  cmp ecx,22
  jne native_skill_search
  test word ptr [held_buttons],2000
  jnz native_skill_search
  mov esi,[game_state]
  cmp byte ptr [esi+1AEB],0
  jne dodge_skill_found
native_skill_search:
  movzx esi,byte ptr [edx+eax+EE]
  jmp dodge_skill_return

encounter_chance:
  push eax
  mov eax,[game_state]
  cmp byte ptr [eax+1AEB],0
  je native_chance
  test word ptr [held_buttons],2000
  jnz bottle_cancel
  mov ecx,65
  jmp bottle_chance
bottle_cancel:
  xor ecx,ecx
bottle_chance:
  pop eax
  mov [esp+20],ecx
  fild dword ptr [esp+20]
  fstp dword ptr [esp+24]
  jmp encounter_chance_return
native_chance:
  pop eax
  movsx ecx,word ptr [eax+80A]
  mov [esp+20],ecx
  fild dword ptr [esp+20]
  fdiv qword ptr [dodge_chance_divisor]
  fstp dword ptr [esp+24]
  jmp encounter_chance_return

dodge_skill_site:
  jmp holy_bottle_code
  nop 3
encounter_chance_site:
  jmp encounter_chance
  nop 14

[DISABLE]
dodge_skill_site:
  db 0F B6 B4 02 EE 00 00 00
encounter_chance_site:
  db 0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24 FF D7
dealloc(holy_bottle_code)
