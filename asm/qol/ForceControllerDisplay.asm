//Forces the controller input to display instead of the keyboard input.
//Address defined is named after what it's changing.
[ENABLE]
define(SetKeyboardDisplay,TOS.exe+2118E7)

assert(SetKeyboardDisplay,C7 05 24 DF E2 00 01 00 00 00)

SetKeyboardDisplay:
    mov [TOS.exe+A2DF24],2