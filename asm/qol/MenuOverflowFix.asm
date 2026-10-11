//Fixes that annoying menu overflow glitch.
//No more of those pesky cheaters poking around
//outside the designated arte list smh my head.
[ENABLE]
define(MenuOverflow,TOS.exe+1258B1)

assert(MenuOverflow,7E 2C 66 83 05 B8 3A B1 00 07)

alloc(Mem_MenuOverflow,100)

Mem_MenuOverflow:
    jle TOS.exe+1258DF
    movzx edx,cx
    sub dx,word [TOS.exe+713AB8]
    cmp dx,#14
    jg AddPage
    movzx edx,cx
    sub dx,7
    mov word [TOS.exe+713AB8],dx
    jmp Ret_MenuOverflow
AddPage:
    add word [TOS.exe+713AB8],7
    jmp Ret_MenuOverflow
	
MenuOverflow:
	jmp Mem_MenuOverflow
	nop 5
Ret_MenuOverflow:

[DISABLE]
MenuOverflow:
	db 7E 2C
	db 66 83 05 B8 3A B1 00 07
	
	dealloc(Mem_MenuOverflow)