[ENABLE]
alloc(mem_sub_voice_hook,0x30)
alloc(mem_sub_call_hook,0x30)

assert(TOS.exe+0x8E01C,e8 0f aa f9 ff)
assert(TOS.exe+0x8E072,e8 39 46 0a 00)
assert(TOS.exe+0x8DFA7,e8 54 6c 10 00)

define(SubVoiceFn,TOS.exe+0x28A30)
define(SubMeasureFn,TOS.exe+0x1326B0)
define(SubVoiceReturn,TOS.exe+0x8E021)
define(SubCallReturn,TOS.exe+0x8E077)

registersymbol(SubVoiceHook)
registersymbol(SubCallHook)

mem_sub_voice_hook:
SubVoiceHook:
  call SubVoiceFn
  jmp SubVoiceReturn

mem_sub_call_hook:
SubCallHook:
  call SubMeasureFn
  jmp SubCallReturn

TOS.exe+0x8E01C:
  jmp SubVoiceHook
TOS.exe+0x8E072:
  jmp SubCallHook
TOS.exe+0x8DFA7:
  nop #5