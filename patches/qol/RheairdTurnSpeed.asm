// Rheaird camera yaw multiplier. Default 1 leaves the hook off.
// Scale the final signed angular delta after the native input clamp and tick
// multiplier, preserving the existing turn buildup/release and angle wrapping.
[ENABLE]
define(turn_site,TOS.exe+B55E7)
define(turn_return,TOS.exe+B55F1)

assert(turn_site,D8 4C 24 38 D8 83 D0 F8 09 00)
assert(turn_return,D9 5C 24 18 D9 44 24 18 D9 93 D0 F8 09 00)
// Same world-state flight flag used by the native player movement branch.
assert(TOS.exe+BC483,8B 87 FC F8 09 00 A8 08 74 62)

alloc(turn_code,100)
alloc(turn_settings,4)
label(turn_multiplier)
label(original)

turn_settings:
turn_multiplier:
  dd (float)1

turn_code:
  fmul dword ptr [esp+38]
  pushfd
  test byte ptr [ebx+9F8FC],8
  jz original
  fmul dword ptr [turn_multiplier]
original:
  popfd
  fadd dword ptr [ebx+9F8D0]
  jmp turn_return

turn_site:
  jmp turn_code
  nop 5

[DISABLE]
turn_site:
  db D8 4C 24 38 D8 83 D0 F8 09 00
dealloc(turn_code)
dealloc(turn_settings)
