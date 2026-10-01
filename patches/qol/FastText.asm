// Port of TOS NoTSFix v26.9.6 CT entry 3189, Fast Dialogue (sd).
// Enable with [QoL] FastText=1. Hold B/Circle to remove the message delay
// and take the native dialogue-advance paths. Released input stays native.
[ENABLE]
define(held_buttons,TOS.exe+19EA6D0)
define(message_speed_site,TOS.exe+176344)
define(message_speed_return,TOS.exe+17634A)
define(message_speed_store,TOS.exe+176356)
define(message_input_a_site,TOS.exe+17653D)
define(message_input_a_return,TOS.exe+176542)
define(message_input_a_advance,TOS.exe+176550)
define(message_input_b_site,TOS.exe+176777)
define(message_input_b_return,TOS.exe+17677D)
define(message_input_b_advance,TOS.exe+17677F)

assert(message_speed_site,F7 C1 00 10 00 04)
assert(message_speed_return,74 11 66 85 C0 74 0C B8 01 00 00 00)
assert(message_speed_store,66 89 86 24 28 00 00)
assert(message_input_a_site,A9 00 30 00 0C)
assert(message_input_a_return,75 0C C6 86 42 27 00 00 04 E9 51 02 00 00)
assert(message_input_a_advance,B9 01 00 00 00 66 01 8E 20 28 00 00)
assert(message_input_b_site,F7 C1 00 20 00 08)
assert(message_input_b_return,74 22)
assert(message_input_b_advance,C6 05 AD D7 8A 00 01 C6 86 43 27 00 00 04 C7 86 68 27 00 00 20 00 00 00 EB 08)

alloc(fast_text_code,1000)
label(native_message_speed)
label(message_input_a)
label(message_input_b)

fast_text_code:
  test word ptr [held_buttons],2000
  jz native_message_speed
  xor eax,eax
  jmp message_speed_store
native_message_speed:
  test ecx,04001000
  jmp message_speed_return

message_input_a:
  test word ptr [held_buttons],2000
  jnz message_input_a_advance
  test eax,0C003000
  jmp message_input_a_return

message_input_b:
  test word ptr [held_buttons],2000
  jnz message_input_b_advance
  test ecx,08002000
  jmp message_input_b_return

message_speed_site:
  jmp fast_text_code
  nop
message_input_a_site:
  jmp message_input_a
message_input_b_site:
  jmp message_input_b
  nop

[DISABLE]
message_speed_site:
  db F7 C1 00 10 00 04
message_input_a_site:
  db A9 00 30 00 0C
message_input_b_site:
  db F7 C1 00 20 00 08
dealloc(fast_text_code)
