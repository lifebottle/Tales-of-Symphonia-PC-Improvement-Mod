//Enable the ability to chain same family artes.
//e.g. Demon Fang -> Double Demon Fang -> Demonic Chaos
[ENABLE]
define(AllowArteFamilyChaining,TOS.exe+3EFCC)

assert(AllowArteFamilyChaining,0F 84 7D 02 00 00)

AllowArteFamilyChaining:
	jmp TOS.exe+3F24F
	nop
