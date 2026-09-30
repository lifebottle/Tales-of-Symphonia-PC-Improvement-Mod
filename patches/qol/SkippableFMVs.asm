// Enable with [QoL] SkippableFMVs=1 on a fresh launch.
// Both paths use the opening FMV's native Start masks and normal cleanup.
// Ported from the memory-only prototype; full playback acceptance is separate
// from the debugger branch checks and compiled-ASM synthetic tests.
[ENABLE]
define(movie_skip_gate,TOS.exe+1541AD)
define(credits_exit_gate,TOS.exe+152F16)
define(credits_cleanup,TOS.exe+152F1F)
define(credits_continue,TOS.exe+152FD7)
define(pressed_buttons,TOS.exe+7193F8)
alloc(credits_skip,100)

// Standard FMVs: bypass only the per-movie permission flag. Retain the native
// pressed-button checks and stop request, including story/debug-menu playback.
assert(TOS.exe+1541A7,38 1D E1 85 B1 00)
assert(movie_skip_gate,74 16)
assert(TOS.exe+1541AF,A1 F8 93 B1 00 A9 00 00 00 08 75 04 A8 10 74 06)
assert(TOS.exe+1541BF,89 35 DC C2 C3 01 8B 0D 48 D0 C3 01)

// The ending credits use a separate player. Hook after input processing;
// preserve the original ESI==2 exit and otherwise accept either Start mask.
assert(TOS.exe+152F11,E8 8A B5 02 00)
assert(credits_exit_gate,83 FE 02 0F 85 B8 00 00 00)
assert(credits_cleanup,33 C0 E8 5A D8 01 00 83 CA FF 66 89 15 F8 D0 8A 00 E8 6B 10 00 00)
assert(credits_continue,5F 5E 5B C3)
assert(TOS.exe+153FA0,51 8B 0D 48 D0 C3 01 A1 C4 C3 C3 01 53 56 33 DB)

credits_skip:
  test dword ptr [pressed_buttons],08000010
  jnz credits_cleanup
  cmp esi,2
  je credits_cleanup
  jmp credits_continue

movie_skip_gate:
  nop 2

credits_exit_gate:
  jmp credits_skip
  nop 4

[DISABLE]
movie_skip_gate:
  db 74 16
credits_exit_gate:
  db 83 FE 02 0F 85 B8 00 00 00
dealloc(credits_skip)
