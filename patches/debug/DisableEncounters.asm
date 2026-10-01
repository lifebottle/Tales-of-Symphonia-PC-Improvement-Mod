// Port of TOS NoTSFix v26.9.6 CT entry 3178 (sd, 2026-09-29).
// Force the Dodge EX skill (22 hex) and encounter-dodge threshold 101 (65 hex).
// Hold B/Circle to use the native skill search and threshold 0, temporarily
// allowing encounters. Release to resume suppression; no Holy Bottle required.
// The input override follows the shipped EnhancedHolyBottles patch.
// Do not combine with EnhancedHolyBottles or either overlapping CT script.
[ENABLE]
define(dodge_skill_site,TOS.exe+8E230)
define(dodge_skill_return,TOS.exe+8E238)
define(dodge_skill_found,TOS.exe+8E254)
define(encounter_chance_site,TOS.exe+D65FF)
define(encounter_chance_return,TOS.exe+D6618)
define(held_buttons,TOS.exe+19EA6D0)

assert(dodge_skill_site,0F B6 B4 02 EE 00 00 00)
// Native skill comparison/loop and successful return path.
assert(dodge_skill_return,3B F1 74 18 40 83 F8 04 7C EE)
assert(dodge_skill_found,8B 4D FC 5E 33 CD B8 01 00 00 00 5B)
assert(encounter_chance_site,0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24 FF D7)
// Native modulo-101 roll, float comparison, and encounter-routing branch.
assert(TOS.exe+D661A,99 B9 65 00 00 00 F7 F9 89 54 24 20 DB 44 24 20 D9 44 24 24 DE D9 DF E0 F6 C4 41 75 0E)

alloc(dodge_skill_code,1000)
label(native_skill_search)
label(encounter_chance)
label(allow_encounters)
label(store_chance)

dodge_skill_code:
  cmp ecx,22
  jne native_skill_search
  test word ptr [held_buttons],2000
  jz dodge_skill_found
native_skill_search:
  movzx esi,byte ptr [edx+eax+EE]
  jmp dodge_skill_return

encounter_chance:
  test word ptr [held_buttons],2000
  jnz allow_encounters
  mov ecx,65
  jmp store_chance
allow_encounters:
  xor ecx,ecx
store_chance:
  mov [esp+20],ecx
  fild dword ptr [esp+20]
  fstp dword ptr [esp+24]
  jmp encounter_chance_return

dodge_skill_site:
  jmp dodge_skill_code
  nop 3

// Replace 25 bytes; keep the native RNG call at the continuation intact.
encounter_chance_site:
  jmp encounter_chance
  nop 14

[DISABLE]
dodge_skill_site:
  db 0F B6 B4 02 EE 00 00 00
encounter_chance_site:
  db 0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24 FF D7
dealloc(dodge_skill_code)
