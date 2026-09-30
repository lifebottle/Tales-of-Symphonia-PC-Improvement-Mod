// Port of CT v26.9.5 entry 2365, Minimum Damage (Sora3100).
// Applies to every actor reaching this HP adjustment, without a team filter.
// Positive healing takes the native bypass before this hook. Zero stays zero;
// every nonzero delta reaching the hook becomes -1, including EBX itself.
[ENABLE]
define(damage_site,TOS.exe+40287)
define(damage_return,TOS.exe+4028D)

assert(damage_site,01 58 24 8B 4E 08)
assert(TOS.exe+4026F,85 DB 7E 11)
assert(damage_return,83 79 24 00)

alloc(minimum_damage_code,1000)
label(apply_delta)

minimum_damage_code:
  cmp ebx,0
  je apply_delta
  mov ebx,FFFFFFFF
apply_delta:
  add [eax+24],ebx
  mov ecx,[esi+08]
  jmp damage_return

damage_site:
  jmp minimum_damage_code
  nop

[DISABLE]
damage_site:
  db 01 58 24 8B 4E 08
dealloc(minimum_damage_code)
