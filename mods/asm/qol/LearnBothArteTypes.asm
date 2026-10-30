// Learn both S/T branches while retaining normal type and progression requirements.
[ENABLE]
define(LearnBothArteTypes,TOS.exe+31D94)
assert(LearnBothArteTypes,0F 85 C9 00 00 00 8B 74 24 2C 8A 4C 24 14)

LearnBothArteTypes:
  nop 6

[DISABLE]
LearnBothArteTypes:
  jnz TOS.exe+31E63
