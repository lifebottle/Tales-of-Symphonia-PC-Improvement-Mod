//Allows the ability to save without a memory circle.
[ENABLE]
define(SaveAnywhere,TOS.exe+C4071)

assert(SaveAnywhere,C6 05 89 0C C3 01 00)

SaveAnywhere:
	mov byte [TOS.exe+1830C89],1