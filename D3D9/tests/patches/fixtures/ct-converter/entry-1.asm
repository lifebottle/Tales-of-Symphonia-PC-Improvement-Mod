// Original bytes verified during CT export.
assert(TOS.exe+0x1010,B8 01 00 00 00 C3)

[ENABLE]
define(site,TOS.exe+0x1010) // resolved from aobscanmodule
alloc(newmem,100,site)
alloc(value,4)
label(returnhere)
newmem:
  mov eax,[value]
  jmp returnhere
value:
  dd 7
site:
  jmp newmem
returnhere:
[DISABLE]
site:
  db B8 01 00 00 00
dealloc(newmem)
dealloc(value)
