// Port of CT v26.9.5 entry 1455, Enemies don't attack (Sora3100).
// Always take the existing branch that skips enemy attack selection.
[ENABLE]
define(enemy_action_site,TOS.exe+419A6)
define(skip_enemy_action,TOS.exe+41A74)

assert(enemy_action_site,0F 85 C8 00 00 00)
assert(TOS.exe+419AC,8B 88 98 32 01 00 85 C9 74 27)
assert(skip_enemy_action,8B 46 04 F7 40 5C 00 00 00 80)

enemy_action_site:
  jmp skip_enemy_action
  nop

[DISABLE]
enemy_action_site:
  db 0F 85 C8 00 00 00
