// Port of TOS NoTSFix v26.9.6 CT entry 3178 (sd, 2026-09-29).
// Force the Dodge EX skill (22 hex) to be present and its encounter-dodge
// threshold to 101 (65 hex). The native RNG call remains after the 25-byte edit.
// Do not combine with the CT's Enhanced Holy Bottles or Disable Encounters.
[ENABLE]
define(dodge_skill_site,TOS.exe+8E230)
define(dodge_skill_return,TOS.exe+8E238)
define(dodge_skill_found,TOS.exe+8E254)
define(encounter_chance_site,TOS.exe+D65FF)

assert(dodge_skill_site,0F B6 B4 02 EE 00 00 00)
// Native skill comparison/loop and successful return path.
assert(dodge_skill_return,3B F1 74 18 40 83 F8 04 7C EE)
assert(dodge_skill_found,8B 4D FC 5E 33 CD B8 01 00 00 00 5B)
assert(encounter_chance_site,0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24 FF D7)
// Native modulo-101 roll, float comparison, and encounter-routing branch.
assert(TOS.exe+D661A,99 B9 65 00 00 00 F7 F9 89 54 24 20 DB 44 24 20 D9 44 24 24 DE D9 DF E0 F6 C4 41 75 0E)

alloc(dodge_skill_code,1000)

dodge_skill_code:
  cmp ecx,22
  je dodge_skill_found
  movzx esi,byte ptr [edx+eax+EE]
  jmp dodge_skill_return

dodge_skill_site:
  jmp dodge_skill_code
  nop 3

encounter_chance_site:
  mov ecx,65
  mov [esp+20],ecx
  fild dword ptr [esp+20]
  fstp dword ptr [esp+24]
  nop 8

[DISABLE]
dodge_skill_site:
  db 0F B6 B4 02 EE 00 00 00
encounter_chance_site:
  db 0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24 FF D7
dealloc(dodge_skill_code)
