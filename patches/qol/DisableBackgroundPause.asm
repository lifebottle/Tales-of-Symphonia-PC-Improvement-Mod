[ENABLE]
define(MusicPause,TOS.exe+182D97)
define(SoundPause,TOS.exe+182E17)
define(GamePause,TOS.exe+1A7020)

assert(MusicPause,75 6C)
assert(SoundPause,0F 85 C0 00 00 00)
assert(GamePause,74 27)

MusicPause:
	jmp TOS.exe+182E05

SoundPause:
    jmp TOS.exe+182EDD
    nop

GamePause:
	jmp TOS.exe+1A7049