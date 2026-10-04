// Port of TOS NoTSFix v26.10.1 CT entry 3179, Enhanced Holy Bottles (sd).
// Fixed Disable Encounters=1: no Holy Bottle or Sheena required.
// Enable with [Debug] DisableEncounters=1.
// Hold B/Circle to allow encounters; release to resume suppression.
// Shares all three sites with the other version: enable only one option.
[ENABLE]
define(bottle_counter_site,TOS.exe+D65CE)
define(encounter_check,TOS.exe+D65EC)
define(dodge_skill_site,TOS.exe+D65EE)
define(dodge_skill_return,TOS.exe+D65F3)
define(native_skill_check,TOS.exe+8E180)
define(encounter_chance_site,TOS.exe+D65FF)
define(encounter_chance_return,TOS.exe+D6618)
define(held_buttons,TOS.exe+19EA6D0)

// The caller supplies the current game state in ECX and pushes Sheena's ID (5).
assert(TOS.exe+D65B9,8B 0D 68 3F AD 00 80 B9 EB 1A 00 00 01 C7 44 24 1C 01 00 00 00)
assert(bottle_counter_site,75 1C)
assert(encounter_check,6A 05)
assert(dodge_skill_site,E8 8D 7B FB FF)
assert(dodge_skill_return,83 C4 04 85 C0 74 4B A1 68 3F AD 00)
// Guard the native fallback and reject the old shared EX-skill hook.
assert(native_skill_check,55 8B EC 83 EC 18 A1 C4 8D 8A 00 33 C5 89 45 FC)
assert(TOS.exe+8E230,0F B6 B4 02 EE 00 00 00)
assert(encounter_chance_site,0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24)
// Retain the RNG call and native modulo-101/comparison sequence.
assert(encounter_chance_return,FF D7 99 B9 65 00 00 00 F7 F9 89 54 24 20 DB 44 24 20 D9 44 24 24 DE D9 DF E0 F6 C4 41 75 0E)

alloc(dodge_skill_code,1000)
label(native_skill_search)
label(encounter_chance)
label(allow_encounters)
label(store_chance)

dodge_skill_code:
  test word ptr [held_buttons],2000
  jnz native_skill_search
  // Bypass the party search at this encounter call site only.
  mov eax,1
  jmp dodge_skill_return
native_skill_search:
  // The original argument is still on the stack; CALL supplies its return address.
  call native_skill_check
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

// Bypass the native per-enemy bottle counter, as in the updated CT.
bottle_counter_site:
  jmp short encounter_check

dodge_skill_site:
  jmp dodge_skill_code

// Replace 25 bytes; keep the native RNG call at the continuation intact.
encounter_chance_site:
  jmp encounter_chance
  nop 14

[DISABLE]
bottle_counter_site:
  db 75 1C
dodge_skill_site:
  db E8 8D 7B FB FF
encounter_chance_site:
  db 0F BF 88 0A 08 00 00 89 4C 24 20 DB 44 24 20 DC 35 98 2A 88 00 D9 5C 24 24
dealloc(dodge_skill_code)
