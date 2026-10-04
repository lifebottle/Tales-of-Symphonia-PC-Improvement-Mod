// TOS NoTSFix v26.10, entry 3202: [Disable Spell Cancel Scale], 2026-10-01.
[ENABLE]

define(SpellCancelScale,TOS.exe+2708B)
define(AllowSpellCancel,TOS.exe+2709C)

assert(SpellCancelScale,7E 0F)
// Guard the native cancel path reached by the unconditional branch.
assert(AllowSpellCancel,33 C0 66 89 83 58 13 00 00 8B 43 04)

SpellCancelScale:
    jmp short AllowSpellCancel

[DISABLE]

SpellCancelScale:
    db 7E 0F
