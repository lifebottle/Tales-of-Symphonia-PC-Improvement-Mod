//	Can Escape Any Battle
[Enable]
define(CanEscape,TOS.exe+5B5F6)

assert(CanEscape,74 08)

CanEscape:
    jmp TOS.exe+5B600
