// Additional spell slots: maintained CE-style source.
// Native helpers and writable arena remain separately allocated.
[ENABLE]
define(BC_GLOBAL,TOS.exe+0x6d2edc)
define(DATA,ARENA + 0x4000)
define(ALLOWED,DATA + 0x100)
define(BUFFER,ARENA + 0xD000)
define(EXTRA_BUSY,DATA + 0x80)
define(PROJECTILES,DATA + 0x300)
define(EXTRA_EFFECTS,DATA + 0x340)
define(EXTRA_MODELS,DATA + 0x350)
define(LAUNCH_COUNTS,DATA + 0x380)
define(EXTRA_SLOTS,ARENA + 0x80000)
define(EXTRA_SLOT_STRIDE,0x80000)
define(PRIVATE_DEFS,ARENA + 0x5000)

assert(TOS.exe+0x26b9d,0f b6 8b b0 3a 01 00 8b 15 dc 2e ad 00)
TOS.exe+0x26b9d:
  jmp cast_ready
  nop #8


// alternate_launch
assert(TOS.exe+0x2795d,0f b6 c8 83 e1 01)
TOS.exe+0x2795d:
  jmp alternate_launch
  nop #1


// direct_launch
assert(TOS.exe+0x3fc46,8b 43 38 a8 01 74 0f)
TOS.exe+0x3fc46:
  jmp direct_launch
  nop #2


// can_use
assert(TOS.exe+0x3efa5,80 bc 18 ee 93 00 00 00)
TOS.exe+0x3efa5:
  jmp can_use
  nop #3


// ai_capacity
assert(TOS.exe+0x33cc3,80 bc 32 ee 93 00 00 00)
TOS.exe+0x33cc3:
  jmp ai_capacity
  nop #3


// general_capacity
assert(TOS.exe+0x2897d,38 8c 10 ee 93 00 00)
TOS.exe+0x2897d:
  jmp general_capacity
  nop #2


// unison_a
assert(TOS.exe+0x25996,8a 83 b0 3a 01 00)
TOS.exe+0x25996:
  jmp unison_a
  nop #1


// unison_b
assert(TOS.exe+0x26640,8a 83 b0 3a 01 00)
TOS.exe+0x26640:
  jmp unison_b
  nop #1


// buffer_init
assert(TOS.exe+0x7a6cb,89 96 50 f9 16 00)
TOS.exe+0x7a6cb:
  jmp buffer_init
  nop #1


// launch_stats
assert(TOS.exe+0x6e2a6,c6 84 0a ee 93 00 00 01)
TOS.exe+0x6e2a6:
  jmp launch_stats
  nop #3


// cleanup_extra
assert(TOS.exe+0x61008,d9 ee 66 c7 86 ee 93 00 00 00 00)
TOS.exe+0x61008:
  jmp cleanup_extra
  nop #6


// loaded_defs
assert(TOS.exe+0x6eafb,e8 80 f8 ff ff)
TOS.exe+0x6eafb:
  call loaded_defs


// script_defs
assert(TOS.exe+0x253a7,89 48 18 eb 0d)
TOS.exe+0x253a7:
  jmp script_defs


// native_40CADF
assert(TOS.exe+0xcadf,8b 84 97 4c 9a 00 00)
TOS.exe+0xcadf:
patch_native_40CADF:
  mov eax, [PROJECTILES+edx*#4]
padding_122:
  nop #7-(padding_122-patch_native_40CADF)


// native_40CB5F
assert(TOS.exe+0xcb5f,8b 84 97 4c 9a 00 00)
TOS.exe+0xcb5f:
patch_native_40CB5F:
  mov eax, [PROJECTILES+edx*#4]
padding_123:
  nop #7-(padding_123-patch_native_40CB5F)


// native_40CBF1
assert(TOS.exe+0xcbf1,8b 94 87 4c 9a 00 00)
TOS.exe+0xcbf1:
patch_native_40CBF1:
  mov edx, [PROJECTILES+eax*#4]
padding_124:
  nop #7-(padding_124-patch_native_40CBF1)


// native_40CC78
assert(TOS.exe+0xcc78,8b 94 87 4c 9a 00 00)
TOS.exe+0xcc78:
patch_native_40CC78:
  mov edx, [PROJECTILES+eax*#4]
padding_125:
  nop #7-(padding_125-patch_native_40CC78)


// native_40D277
assert(TOS.exe+0xd277,8b 84 97 4c 9a 00 00)
TOS.exe+0xd277:
patch_native_40D277:
  mov eax, [PROJECTILES+edx*#4]
padding_126:
  nop #7-(padding_126-patch_native_40D277)


// native_40D2FE
assert(TOS.exe+0xd2fe,8b 94 87 4c 9a 00 00)
TOS.exe+0xd2fe:
patch_native_40D2FE:
  mov edx, [PROJECTILES+eax*#4]
padding_127:
  nop #7-(padding_127-patch_native_40D2FE)


// native_40DA17
assert(TOS.exe+0xda17,8b 84 97 4c 9a 00 00)
TOS.exe+0xda17:
patch_native_40DA17:
  mov eax, [PROJECTILES+edx*#4]
padding_128:
  nop #7-(padding_128-patch_native_40DA17)


// native_40DA9E
assert(TOS.exe+0xda9e,8b 94 87 4c 9a 00 00)
TOS.exe+0xda9e:
patch_native_40DA9E:
  mov edx, [PROJECTILES+eax*#4]
padding_129:
  nop #7-(padding_129-patch_native_40DA9E)


// native_40DB25
assert(TOS.exe+0xdb25,8b 94 87 4c 9a 00 00)
TOS.exe+0xdb25:
patch_native_40DB25:
  mov edx, [PROJECTILES+eax*#4]
padding_130:
  nop #7-(padding_130-patch_native_40DB25)


// native_40DBAC
assert(TOS.exe+0xdbac,8b 94 87 4c 9a 00 00)
TOS.exe+0xdbac:
patch_native_40DBAC:
  mov edx, [PROJECTILES+eax*#4]
padding_131:
  nop #7-(padding_131-patch_native_40DBAC)


// native_40DC33
assert(TOS.exe+0xdc33,8b 94 87 4c 9a 00 00)
TOS.exe+0xdc33:
patch_native_40DC33:
  mov edx, [PROJECTILES+eax*#4]
padding_132:
  nop #7-(padding_132-patch_native_40DC33)


// native_40E390
assert(TOS.exe+0xe390,8b 94 87 4c 9a 00 00)
TOS.exe+0xe390:
patch_native_40E390:
  mov edx, [PROJECTILES+eax*#4]
padding_133:
  nop #7-(padding_133-patch_native_40E390)


// native_40E410
assert(TOS.exe+0xe410,8b 84 97 4c 9a 00 00)
TOS.exe+0xe410:
patch_native_40E410:
  mov eax, [PROJECTILES+edx*#4]
padding_134:
  nop #7-(padding_134-patch_native_40E410)


// native_40E4AF
assert(TOS.exe+0xe4af,8b 84 87 4c 9a 00 00)
TOS.exe+0xe4af:
patch_native_40E4AF:
  mov eax, [PROJECTILES+eax*#4]
padding_135:
  nop #7-(padding_135-patch_native_40E4AF)


// native_40E545
assert(TOS.exe+0xe545,8b 84 87 4c 9a 00 00)
TOS.exe+0xe545:
patch_native_40E545:
  mov eax, [PROJECTILES+eax*#4]
padding_136:
  nop #7-(padding_136-patch_native_40E545)


// native_40EE25
assert(TOS.exe+0xee25,8b 94 87 4c 9a 00 00)
TOS.exe+0xee25:
patch_native_40EE25:
  mov edx, [PROJECTILES+eax*#4]
padding_137:
  nop #7-(padding_137-patch_native_40EE25)


// native_40EEA5
assert(TOS.exe+0xeea5,8b 84 97 4c 9a 00 00)
TOS.exe+0xeea5:
patch_native_40EEA5:
  mov eax, [PROJECTILES+edx*#4]
padding_138:
  nop #7-(padding_138-patch_native_40EEA5)


// native_40EF44
assert(TOS.exe+0xef44,8b 84 87 4c 9a 00 00)
TOS.exe+0xef44:
patch_native_40EF44:
  mov eax, [PROJECTILES+eax*#4]
padding_139:
  nop #7-(padding_139-patch_native_40EF44)


// native_40EFDA
assert(TOS.exe+0xefda,8b 84 87 4c 9a 00 00)
TOS.exe+0xefda:
patch_native_40EFDA:
  mov eax, [PROJECTILES+eax*#4]
padding_140:
  nop #7-(padding_140-patch_native_40EFDA)


// native_40F632
assert(TOS.exe+0xf632,8b 94 87 4c 9a 00 00)
TOS.exe+0xf632:
patch_native_40F632:
  mov edx, [PROJECTILES+eax*#4]
padding_141:
  nop #7-(padding_141-patch_native_40F632)


// native_40F6B6
assert(TOS.exe+0xf6b6,8b 94 87 4c 9a 00 00)
TOS.exe+0xf6b6:
patch_native_40F6B6:
  mov edx, [PROJECTILES+eax*#4]
padding_142:
  nop #7-(padding_142-patch_native_40F6B6)


// native_40FDEB
assert(TOS.exe+0xfdeb,8b 8c 87 4c 9a 00 00)
TOS.exe+0xfdeb:
patch_native_40FDEB:
  mov ecx, [PROJECTILES+eax*#4]
padding_143:
  nop #7-(padding_143-patch_native_40FDEB)


// native_40FF74
assert(TOS.exe+0xff74,8b 8c 87 4c 9a 00 00)
TOS.exe+0xff74:
patch_native_40FF74:
  mov ecx, [PROJECTILES+eax*#4]
padding_144:
  nop #7-(padding_144-patch_native_40FF74)


// native_40FFF5
assert(TOS.exe+0xfff5,8b 8c 87 4c 9a 00 00)
TOS.exe+0xfff5:
patch_native_40FFF5:
  mov ecx, [PROJECTILES+eax*#4]
padding_145:
  nop #7-(padding_145-patch_native_40FFF5)


// native_41007D
assert(TOS.exe+0x1007d,8b 84 8f 4c 9a 00 00)
TOS.exe+0x1007d:
patch_native_41007D:
  mov eax, [PROJECTILES+ecx*#4]
padding_146:
  nop #7-(padding_146-patch_native_41007D)


// native_41057D
assert(TOS.exe+0x1057d,8b b4 86 4c 9a 00 00)
TOS.exe+0x1057d:
patch_native_41057D:
  mov esi, [PROJECTILES+eax*#4]
padding_147:
  nop #7-(padding_147-patch_native_41057D)


// native_4109ED
assert(TOS.exe+0x109ed,8b 84 82 4c 9a 00 00)
TOS.exe+0x109ed:
patch_native_4109ED:
  mov eax, [PROJECTILES+eax*#4]
padding_148:
  nop #7-(padding_148-patch_native_4109ED)


// native_410A3A
assert(TOS.exe+0x10a3a,8b 94 90 4c 9a 00 00)
TOS.exe+0x10a3a:
patch_native_410A3A:
  mov edx, [PROJECTILES+edx*#4]
padding_149:
  nop #7-(padding_149-patch_native_410A3A)


// native_410B86
assert(TOS.exe+0x10b86,8b 94 90 4c 9a 00 00)
TOS.exe+0x10b86:
patch_native_410B86:
  mov edx, [PROJECTILES+edx*#4]
padding_150:
  nop #7-(padding_150-patch_native_410B86)


// native_410BFD
assert(TOS.exe+0x10bfd,8b 84 81 4c 9a 00 00)
TOS.exe+0x10bfd:
patch_native_410BFD:
  mov eax, [PROJECTILES+eax*#4]
padding_151:
  nop #7-(padding_151-patch_native_410BFD)


// native_410D4D
assert(TOS.exe+0x10d4d,8b 8c 81 4c 9a 00 00)
TOS.exe+0x10d4d:
patch_native_410D4D:
  mov ecx, [PROJECTILES+eax*#4]
padding_152:
  nop #7-(padding_152-patch_native_410D4D)


// native_410DBD
assert(TOS.exe+0x10dbd,8b 94 90 4c 9a 00 00)
TOS.exe+0x10dbd:
patch_native_410DBD:
  mov edx, [PROJECTILES+edx*#4]
padding_153:
  nop #7-(padding_153-patch_native_410DBD)


// native_4110ED
assert(TOS.exe+0x110ed,8b b4 86 4c 9a 00 00)
TOS.exe+0x110ed:
patch_native_4110ED:
  mov esi, [PROJECTILES+eax*#4]
padding_154:
  nop #7-(padding_154-patch_native_4110ED)


// native_41141D
assert(TOS.exe+0x1141d,8b 84 81 4c 9a 00 00)
TOS.exe+0x1141d:
patch_native_41141D:
  mov eax, [PROJECTILES+eax*#4]
padding_155:
  nop #7-(padding_155-patch_native_41141D)


// native_411489
assert(TOS.exe+0x11489,8b 8c 81 4c 9a 00 00)
TOS.exe+0x11489:
patch_native_411489:
  mov ecx, [PROJECTILES+eax*#4]
padding_156:
  nop #7-(padding_156-patch_native_411489)


// native_4114FC
assert(TOS.exe+0x114fc,8b 94 90 4c 9a 00 00)
TOS.exe+0x114fc:
patch_native_4114FC:
  mov edx, [PROJECTILES+edx*#4]
padding_157:
  nop #7-(padding_157-patch_native_4114FC)


// native_41163D
assert(TOS.exe+0x1163d,8b b4 86 4c 9a 00 00)
TOS.exe+0x1163d:
patch_native_41163D:
  mov esi, [PROJECTILES+eax*#4]
padding_158:
  nop #7-(padding_158-patch_native_41163D)


// native_41177D
assert(TOS.exe+0x1177d,8b 84 81 4c 9a 00 00)
TOS.exe+0x1177d:
patch_native_41177D:
  mov eax, [PROJECTILES+eax*#4]
padding_159:
  nop #7-(padding_159-patch_native_41177D)


// native_4117FB
assert(TOS.exe+0x117fb,8b 94 81 4c 9a 00 00)
TOS.exe+0x117fb:
patch_native_4117FB:
  mov edx, [PROJECTILES+eax*#4]
padding_160:
  nop #7-(padding_160-patch_native_4117FB)


// native_411A06
assert(TOS.exe+0x11a06,8b 94 90 4c 9a 00 00)
TOS.exe+0x11a06:
patch_native_411A06:
  mov edx, [PROJECTILES+edx*#4]
padding_161:
  nop #7-(padding_161-patch_native_411A06)


// native_411BC9
assert(TOS.exe+0x11bc9,8b 84 81 4c 9a 00 00)
TOS.exe+0x11bc9:
patch_native_411BC9:
  mov eax, [PROJECTILES+eax*#4]
padding_162:
  nop #7-(padding_162-patch_native_411BC9)


// native_411D2D
assert(TOS.exe+0x11d2d,8b 84 81 4c 9a 00 00)
TOS.exe+0x11d2d:
patch_native_411D2D:
  mov eax, [PROJECTILES+eax*#4]
padding_163:
  nop #7-(padding_163-patch_native_411D2D)


// native_411D96
assert(TOS.exe+0x11d96,8b 94 81 4c 9a 00 00)
TOS.exe+0x11d96:
patch_native_411D96:
  mov edx, [PROJECTILES+eax*#4]
padding_164:
  nop #7-(padding_164-patch_native_411D96)


// native_412235
assert(TOS.exe+0x12235,8b 8c 8a 4c 9a 00 00)
TOS.exe+0x12235:
patch_native_412235:
  mov ecx, [PROJECTILES+ecx*#4]
padding_165:
  nop #7-(padding_165-patch_native_412235)


// native_41247D
assert(TOS.exe+0x1247d,8b b4 86 4c 9a 00 00)
TOS.exe+0x1247d:
patch_native_41247D:
  mov esi, [PROJECTILES+eax*#4]
padding_166:
  nop #7-(padding_166-patch_native_41247D)


// native_4125BD
assert(TOS.exe+0x125bd,8b b4 86 4c 9a 00 00)
TOS.exe+0x125bd:
patch_native_4125BD:
  mov esi, [PROJECTILES+eax*#4]
padding_167:
  nop #7-(padding_167-patch_native_4125BD)


// native_41275D
assert(TOS.exe+0x1275d,8b b4 86 4c 9a 00 00)
TOS.exe+0x1275d:
patch_native_41275D:
  mov esi, [PROJECTILES+eax*#4]
padding_168:
  nop #7-(padding_168-patch_native_41275D)


// native_4129E3
assert(TOS.exe+0x129e3,8b 8c 90 4c 9a 00 00)
TOS.exe+0x129e3:
patch_native_4129E3:
  mov ecx, [PROJECTILES+edx*#4]
padding_169:
  nop #7-(padding_169-patch_native_4129E3)


// native_412B2D
assert(TOS.exe+0x12b2d,8b b4 86 4c 9a 00 00)
TOS.exe+0x12b2d:
patch_native_412B2D:
  mov esi, [PROJECTILES+eax*#4]
padding_170:
  nop #7-(padding_170-patch_native_412B2D)


// native_412E31
assert(TOS.exe+0x12e31,8b 8c 90 4c 9a 00 00)
TOS.exe+0x12e31:
patch_native_412E31:
  mov ecx, [PROJECTILES+edx*#4]
padding_171:
  nop #7-(padding_171-patch_native_412E31)


// native_412F0D
assert(TOS.exe+0x12f0d,8b 8c 90 4c 9a 00 00)
TOS.exe+0x12f0d:
patch_native_412F0D:
  mov ecx, [PROJECTILES+edx*#4]
padding_172:
  nop #7-(padding_172-patch_native_412F0D)


// native_41305A
assert(TOS.exe+0x1305a,8b 8c 8a 4c 9a 00 00)
TOS.exe+0x1305a:
patch_native_41305A:
  mov ecx, [PROJECTILES+ecx*#4]
padding_173:
  nop #7-(padding_173-patch_native_41305A)


// native_4130DD
assert(TOS.exe+0x130dd,8b 84 88 4c 9a 00 00)
TOS.exe+0x130dd:
patch_native_4130DD:
  mov eax, [PROJECTILES+ecx*#4]
padding_174:
  nop #7-(padding_174-patch_native_4130DD)


// native_413487
assert(TOS.exe+0x13487,8b 8c 81 4c 9a 00 00)
TOS.exe+0x13487:
patch_native_413487:
  mov ecx, [PROJECTILES+eax*#4]
padding_175:
  nop #7-(padding_175-patch_native_413487)


// native_413642
assert(TOS.exe+0x13642,8b 8c 81 4c 9a 00 00)
TOS.exe+0x13642:
patch_native_413642:
  mov ecx, [PROJECTILES+eax*#4]
padding_176:
  nop #7-(padding_176-patch_native_413642)


// native_413A40
assert(TOS.exe+0x13a40,8b 8c 81 4c 9a 00 00)
TOS.exe+0x13a40:
patch_native_413A40:
  mov ecx, [PROJECTILES+eax*#4]
padding_177:
  nop #7-(padding_177-patch_native_413A40)


// native_415B1D
assert(TOS.exe+0x15b1d,8b 8c 81 4c 9a 00 00)
TOS.exe+0x15b1d:
patch_native_415B1D:
  mov ecx, [PROJECTILES+eax*#4]
padding_178:
  nop #7-(padding_178-patch_native_415B1D)


// native_415B91
assert(TOS.exe+0x15b91,8b 8c 90 4c 9a 00 00)
TOS.exe+0x15b91:
patch_native_415B91:
  mov ecx, [PROJECTILES+edx*#4]
padding_179:
  nop #7-(padding_179-patch_native_415B91)


// native_415EAD
assert(TOS.exe+0x15ead,8b 8c 81 4c 9a 00 00)
TOS.exe+0x15ead:
patch_native_415EAD:
  mov ecx, [PROJECTILES+eax*#4]
padding_180:
  nop #7-(padding_180-patch_native_415EAD)


// native_4162B4
assert(TOS.exe+0x162b4,8b 8c 81 4c 9a 00 00)
TOS.exe+0x162b4:
patch_native_4162B4:
  mov ecx, [PROJECTILES+eax*#4]
padding_181:
  nop #7-(padding_181-patch_native_4162B4)


// native_4163CD
assert(TOS.exe+0x163cd,8b 8c 90 4c 9a 00 00)
TOS.exe+0x163cd:
patch_native_4163CD:
  mov ecx, [PROJECTILES+edx*#4]
padding_182:
  nop #7-(padding_182-patch_native_4163CD)


// native_4178F5
assert(TOS.exe+0x178f5,8b 84 97 4c 9a 00 00)
TOS.exe+0x178f5:
patch_native_4178F5:
  mov eax, [PROJECTILES+edx*#4]
padding_183:
  nop #7-(padding_183-patch_native_4178F5)


// native_417F74
assert(TOS.exe+0x17f74,8b 84 82 4c 9a 00 00)
TOS.exe+0x17f74:
patch_native_417F74:
  mov eax, [PROJECTILES+eax*#4]
padding_184:
  nop #7-(padding_184-patch_native_417F74)


// native_4186A2
assert(TOS.exe+0x186a2,8b 8c 81 4c 9a 00 00)
TOS.exe+0x186a2:
patch_native_4186A2:
  mov ecx, [PROJECTILES+eax*#4]
padding_185:
  nop #7-(padding_185-patch_native_4186A2)


// native_41897F
assert(TOS.exe+0x1897f,8b 94 90 4c 9a 00 00)
TOS.exe+0x1897f:
patch_native_41897F:
  mov edx, [PROJECTILES+edx*#4]
padding_186:
  nop #7-(padding_186-patch_native_41897F)


// native_418A05
assert(TOS.exe+0x18a05,8b 94 82 4c 9a 00 00)
TOS.exe+0x18a05:
patch_native_418A05:
  mov edx, [PROJECTILES+eax*#4]
padding_187:
  nop #7-(padding_187-patch_native_418A05)


// native_41907D
assert(TOS.exe+0x1907d,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1907d:
patch_native_41907D:
  mov ecx, [PROJECTILES+eax*#4]
padding_188:
  nop #7-(padding_188-patch_native_41907D)


// native_4190EB
assert(TOS.exe+0x190eb,8b 8c 90 4c 9a 00 00)
TOS.exe+0x190eb:
patch_native_4190EB:
  mov ecx, [PROJECTILES+edx*#4]
padding_189:
  nop #7-(padding_189-patch_native_4190EB)


// native_419167
assert(TOS.exe+0x19167,8b 8c 81 4c 9a 00 00)
TOS.exe+0x19167:
patch_native_419167:
  mov ecx, [PROJECTILES+eax*#4]
padding_190:
  nop #7-(padding_190-patch_native_419167)


// native_41A283
assert(TOS.exe+0x1a283,8b 8c 83 4c 9a 00 00)
TOS.exe+0x1a283:
patch_native_41A283:
  mov ecx, [PROJECTILES+eax*#4]
padding_191:
  nop #7-(padding_191-patch_native_41A283)


// native_41A623
assert(TOS.exe+0x1a623,8b 8c 87 4c 9a 00 00)
TOS.exe+0x1a623:
patch_native_41A623:
  mov ecx, [PROJECTILES+eax*#4]
padding_192:
  nop #7-(padding_192-patch_native_41A623)


// native_41A694
assert(TOS.exe+0x1a694,8b 8c 97 4c 9a 00 00)
TOS.exe+0x1a694:
patch_native_41A694:
  mov ecx, [PROJECTILES+edx*#4]
padding_193:
  nop #7-(padding_193-patch_native_41A694)


// native_41A70E
assert(TOS.exe+0x1a70e,8b 8c 87 4c 9a 00 00)
TOS.exe+0x1a70e:
patch_native_41A70E:
  mov ecx, [PROJECTILES+eax*#4]
padding_194:
  nop #7-(padding_194-patch_native_41A70E)


// native_41A787
assert(TOS.exe+0x1a787,8b 8c 87 4c 9a 00 00)
TOS.exe+0x1a787:
patch_native_41A787:
  mov ecx, [PROJECTILES+eax*#4]
padding_195:
  nop #7-(padding_195-patch_native_41A787)


// native_41A7FD
assert(TOS.exe+0x1a7fd,8b 8c 87 4c 9a 00 00)
TOS.exe+0x1a7fd:
patch_native_41A7FD:
  mov ecx, [PROJECTILES+eax*#4]
padding_196:
  nop #7-(padding_196-patch_native_41A7FD)


// native_41AA41
assert(TOS.exe+0x1aa41,8b 94 90 4c 9a 00 00)
TOS.exe+0x1aa41:
patch_native_41AA41:
  mov edx, [PROJECTILES+edx*#4]
padding_197:
  nop #7-(padding_197-patch_native_41AA41)


// native_41B133
assert(TOS.exe+0x1b133,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1b133:
patch_native_41B133:
  mov ecx, [PROJECTILES+eax*#4]
padding_198:
  nop #7-(padding_198-patch_native_41B133)


// native_41B7E3
assert(TOS.exe+0x1b7e3,8b 8c 90 4c 9a 00 00)
TOS.exe+0x1b7e3:
patch_native_41B7E3:
  mov ecx, [PROJECTILES+edx*#4]
padding_199:
  nop #7-(padding_199-patch_native_41B7E3)


// native_41BD6C
assert(TOS.exe+0x1bd6c,8b 8c 8a 4c 9a 00 00)
TOS.exe+0x1bd6c:
patch_native_41BD6C:
  mov ecx, [PROJECTILES+ecx*#4]
padding_200:
  nop #7-(padding_200-patch_native_41BD6C)


// native_41BE17
assert(TOS.exe+0x1be17,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1be17:
patch_native_41BE17:
  mov ecx, [PROJECTILES+eax*#4]
padding_201:
  nop #7-(padding_201-patch_native_41BE17)


// native_41BE95
assert(TOS.exe+0x1be95,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1be95:
patch_native_41BE95:
  mov ecx, [PROJECTILES+eax*#4]
padding_202:
  nop #7-(padding_202-patch_native_41BE95)


// native_41C2FB
assert(TOS.exe+0x1c2fb,8b 94 8a 4c 9a 00 00)
TOS.exe+0x1c2fb:
patch_native_41C2FB:
  mov edx, [PROJECTILES+ecx*#4]
padding_203:
  nop #7-(padding_203-patch_native_41C2FB)


// native_41C371
assert(TOS.exe+0x1c371,8b 94 82 4c 9a 00 00)
TOS.exe+0x1c371:
patch_native_41C371:
  mov edx, [PROJECTILES+eax*#4]
padding_204:
  nop #7-(padding_204-patch_native_41C371)


// native_41C8CE
assert(TOS.exe+0x1c8ce,8b 8c 8a 4c 9a 00 00)
TOS.exe+0x1c8ce:
patch_native_41C8CE:
  mov ecx, [PROJECTILES+ecx*#4]
padding_205:
  nop #7-(padding_205-patch_native_41C8CE)


// native_41C97A
assert(TOS.exe+0x1c97a,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1c97a:
patch_native_41C97A:
  mov ecx, [PROJECTILES+eax*#4]
padding_206:
  nop #7-(padding_206-patch_native_41C97A)


// native_41CA2C
assert(TOS.exe+0x1ca2c,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1ca2c:
patch_native_41CA2C:
  mov ecx, [PROJECTILES+eax*#4]
padding_207:
  nop #7-(padding_207-patch_native_41CA2C)


// native_41CADD
assert(TOS.exe+0x1cadd,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1cadd:
patch_native_41CADD:
  mov ecx, [PROJECTILES+eax*#4]
padding_208:
  nop #7-(padding_208-patch_native_41CADD)


// native_41CF64
assert(TOS.exe+0x1cf64,8b 94 8a 4c 9a 00 00)
TOS.exe+0x1cf64:
patch_native_41CF64:
  mov edx, [PROJECTILES+ecx*#4]
padding_209:
  nop #7-(padding_209-patch_native_41CF64)


// native_41D62D
assert(TOS.exe+0x1d62d,8b 8c 90 4c 9a 00 00)
TOS.exe+0x1d62d:
patch_native_41D62D:
  mov ecx, [PROJECTILES+edx*#4]
padding_210:
  nop #7-(padding_210-patch_native_41D62D)


// native_41DB3B
assert(TOS.exe+0x1db3b,8b 8c 88 4c 9a 00 00)
TOS.exe+0x1db3b:
patch_native_41DB3B:
  mov ecx, [PROJECTILES+ecx*#4]
padding_211:
  nop #7-(padding_211-patch_native_41DB3B)


// native_41E1A3
assert(TOS.exe+0x1e1a3,8b 8c 81 4c 9a 00 00)
TOS.exe+0x1e1a3:
patch_native_41E1A3:
  mov ecx, [PROJECTILES+eax*#4]
padding_212:
  nop #7-(padding_212-patch_native_41E1A3)


// native_41E6A8
assert(TOS.exe+0x1e6a8,8b 8c 88 4c 9a 00 00)
TOS.exe+0x1e6a8:
patch_native_41E6A8:
  mov ecx, [PROJECTILES+ecx*#4]
padding_213:
  nop #7-(padding_213-patch_native_41E6A8)


// native_41F07B
assert(TOS.exe+0x1f07b,8b 8c 97 4c 9a 00 00)
TOS.exe+0x1f07b:
patch_native_41F07B:
  mov ecx, [PROJECTILES+edx*#4]
padding_214:
  nop #7-(padding_214-patch_native_41F07B)


// native_420162
assert(TOS.exe+0x20162,8b 8c 86 4c 9a 00 00)
TOS.exe+0x20162:
patch_native_420162:
  mov ecx, [PROJECTILES+eax*#4]
padding_215:
  nop #7-(padding_215-patch_native_420162)


// native_4204B7
assert(TOS.exe+0x204b7,8b 94 8a 4c 9a 00 00)
TOS.exe+0x204b7:
patch_native_4204B7:
  mov edx, [PROJECTILES+ecx*#4]
padding_216:
  nop #7-(padding_216-patch_native_4204B7)


// native_4207FA
assert(TOS.exe+0x207fa,8b 94 8a 4c 9a 00 00)
TOS.exe+0x207fa:
patch_native_4207FA:
  mov edx, [PROJECTILES+ecx*#4]
padding_217:
  nop #7-(padding_217-patch_native_4207FA)


// native_420DA7
assert(TOS.exe+0x20da7,8b 94 8a 4c 9a 00 00)
TOS.exe+0x20da7:
patch_native_420DA7:
  mov edx, [PROJECTILES+ecx*#4]
padding_218:
  nop #7-(padding_218-patch_native_420DA7)


// native_4210CD
assert(TOS.exe+0x210cd,8b 94 82 4c 9a 00 00)
TOS.exe+0x210cd:
patch_native_4210CD:
  mov edx, [PROJECTILES+eax*#4]
padding_219:
  nop #7-(padding_219-patch_native_4210CD)


// native_4211A2
assert(TOS.exe+0x211a2,8b 94 90 4c 9a 00 00)
TOS.exe+0x211a2:
patch_native_4211A2:
  mov edx, [PROJECTILES+edx*#4]
padding_220:
  nop #7-(padding_220-patch_native_4211A2)


// native_42157C
assert(TOS.exe+0x2157c,8b 94 90 4c 9a 00 00)
TOS.exe+0x2157c:
patch_native_42157C:
  mov edx, [PROJECTILES+edx*#4]
padding_221:
  nop #7-(padding_221-patch_native_42157C)


// native_421B23
assert(TOS.exe+0x21b23,8b 94 90 4c 9a 00 00)
TOS.exe+0x21b23:
patch_native_421B23:
  mov edx, [PROJECTILES+edx*#4]
padding_222:
  nop #7-(padding_222-patch_native_421B23)


// native_421FBA
assert(TOS.exe+0x21fba,8b 94 90 4c 9a 00 00)
TOS.exe+0x21fba:
patch_native_421FBA:
  mov edx, [PROJECTILES+edx*#4]
padding_223:
  nop #7-(padding_223-patch_native_421FBA)


// native_4222D7
assert(TOS.exe+0x222d7,8b 94 8a 4c 9a 00 00)
TOS.exe+0x222d7:
patch_native_4222D7:
  mov edx, [PROJECTILES+ecx*#4]
padding_224:
  nop #7-(padding_224-patch_native_4222D7)


// native_422516
assert(TOS.exe+0x22516,8b b4 96 4c 9a 00 00)
TOS.exe+0x22516:
patch_native_422516:
  mov esi, [PROJECTILES+edx*#4]
padding_225:
  nop #7-(padding_225-patch_native_422516)


// native_42283E
assert(TOS.exe+0x2283e,8b 94 8a 4c 9a 00 00)
TOS.exe+0x2283e:
patch_native_42283E:
  mov edx, [PROJECTILES+ecx*#4]
padding_226:
  nop #7-(padding_226-patch_native_42283E)


// native_4228B0
assert(TOS.exe+0x228b0,8b 94 8a 4c 9a 00 00)
TOS.exe+0x228b0:
patch_native_4228B0:
  mov edx, [PROJECTILES+ecx*#4]
padding_227:
  nop #7-(padding_227-patch_native_4228B0)


// native_422EAA
assert(TOS.exe+0x22eaa,8b 94 8a 4c 9a 00 00)
TOS.exe+0x22eaa:
patch_native_422EAA:
  mov edx, [PROJECTILES+ecx*#4]
padding_228:
  nop #7-(padding_228-patch_native_422EAA)


// native_42361F
assert(TOS.exe+0x2361f,8b 94 90 4c 9a 00 00)
TOS.exe+0x2361f:
patch_native_42361F:
  mov edx, [PROJECTILES+edx*#4]
padding_229:
  nop #7-(padding_229-patch_native_42361F)


// native_42377B
assert(TOS.exe+0x2377b,8b 94 90 4c 9a 00 00)
TOS.exe+0x2377b:
patch_native_42377B:
  mov edx, [PROJECTILES+edx*#4]
padding_230:
  nop #7-(padding_230-patch_native_42377B)


// native_423AD7
assert(TOS.exe+0x23ad7,8b 94 8a 4c 9a 00 00)
TOS.exe+0x23ad7:
patch_native_423AD7:
  mov edx, [PROJECTILES+ecx*#4]
padding_231:
  nop #7-(padding_231-patch_native_423AD7)


// native_423DA1
assert(TOS.exe+0x23da1,8b 94 87 4c 9a 00 00)
TOS.exe+0x23da1:
patch_native_423DA1:
  mov edx, [PROJECTILES+eax*#4]
padding_232:
  nop #7-(padding_232-patch_native_423DA1)


// native_423E1F
assert(TOS.exe+0x23e1f,8b bc 97 4c 9a 00 00)
TOS.exe+0x23e1f:
patch_native_423E1F:
  mov edi, [PROJECTILES+edx*#4]
padding_233:
  nop #7-(padding_233-patch_native_423E1F)


// native_4243BF
assert(TOS.exe+0x243bf,8b 94 97 4c 9a 00 00)
TOS.exe+0x243bf:
patch_native_4243BF:
  mov edx, [PROJECTILES+edx*#4]
padding_234:
  nop #7-(padding_234-patch_native_4243BF)


// native_4245E1
assert(TOS.exe+0x245e1,8b 94 90 4c 9a 00 00)
TOS.exe+0x245e1:
patch_native_4245E1:
  mov edx, [PROJECTILES+edx*#4]
padding_235:
  nop #7-(padding_235-patch_native_4245E1)


// native_424A0D
assert(TOS.exe+0x24a0d,8b 94 90 4c 9a 00 00)
TOS.exe+0x24a0d:
patch_native_424A0D:
  mov edx, [PROJECTILES+edx*#4]
padding_236:
  nop #7-(padding_236-patch_native_424A0D)


// native_425043
assert(TOS.exe+0x25043,8b 8c 81 4c 9a 00 00)
TOS.exe+0x25043:
patch_native_425043:
  mov ecx, [PROJECTILES+eax*#4]
padding_237:
  nop #7-(padding_237-patch_native_425043)


// native_4250C1
assert(TOS.exe+0x250c1,8b 8c 90 4c 9a 00 00)
TOS.exe+0x250c1:
patch_native_4250C1:
  mov ecx, [PROJECTILES+edx*#4]
padding_238:
  nop #7-(padding_238-patch_native_4250C1)


// native_425157
assert(TOS.exe+0x25157,8b 94 81 4c 9a 00 00)
TOS.exe+0x25157:
patch_native_425157:
  mov edx, [PROJECTILES+eax*#4]
padding_239:
  nop #7-(padding_239-patch_native_425157)


// native_42524B
assert(TOS.exe+0x2524b,8b 94 81 4c 9a 00 00)
TOS.exe+0x2524b:
patch_native_42524B:
  mov edx, [PROJECTILES+eax*#4]
padding_240:
  nop #7-(padding_240-patch_native_42524B)


// native_40931F
assert(TOS.exe+0x931f,8b 99 54 9a 00 00)
TOS.exe+0x931f:
patch_native_40931F:
  mov ebx, [PROJECTILES+#8]
padding_241:
  nop #6-(padding_241-patch_native_40931F)


// native_40C5EB
assert(TOS.exe+0xc5eb,69 c9 20 a3 00 00)
TOS.exe+0xc5eb:
  jmp native_40C5EB
  nop #1


// native_40DE3B
assert(TOS.exe+0xde3b,69 c9 20 a3 00 00)
TOS.exe+0xde3b:
  jmp native_40DE3B
  nop #1


// native_40E8BB
assert(TOS.exe+0xe8bb,69 c9 20 a3 00 00)
TOS.exe+0xe8bb:
  jmp native_40E8BB
  nop #1


// native_40F19A
assert(TOS.exe+0xf19a,69 c0 20 a3 00 00)
TOS.exe+0xf19a:
  jmp native_40F19A
  nop #1


// native_40F7E3
assert(TOS.exe+0xf7e3,69 c0 20 a3 00 00)
TOS.exe+0xf7e3:
  jmp native_40F7E3
  nop #1


// native_41A337
assert(TOS.exe+0x1a337,69 c0 20 a3 00 00)
TOS.exe+0x1a337:
  jmp native_41A337
  nop #1


// native_4282CA
assert(TOS.exe+0x282ca,69 c9 20 a3 00 00)
TOS.exe+0x282ca:
  jmp native_4282CA
  nop #1


// native_46DEF0
assert(TOS.exe+0x6def0,69 c0 20 a3 00 00)
TOS.exe+0x6def0:
  jmp native_46DEF0
  nop #1


// native_46E063
assert(TOS.exe+0x6e063,69 d2 20 a3 00 00)
TOS.exe+0x6e063:
  jmp native_46E063
  nop #1


// native_46E3C6
assert(TOS.exe+0x6e3c6,69 c0 20 a3 00 00)
TOS.exe+0x6e3c6:
  jmp native_46E3C6
  nop #1


// native_46EA41
assert(TOS.exe+0x6ea41,69 c9 20 a3 00 00)
TOS.exe+0x6ea41:
  jmp native_46EA41
  nop #1


// native_46EA9A
assert(TOS.exe+0x6ea9a,69 c9 20 a3 00 00)
TOS.exe+0x6ea9a:
  jmp native_46EA9A
  nop #1


// native_451B5A
assert(TOS.exe+0x51b5a,8b 8c 8e bc 71 15 00)
TOS.exe+0x51b5a:
  jmp native_451B5A
  nop #2


// native_46E489
assert(TOS.exe+0x6e489,89 84 8f bc 71 15 00)
TOS.exe+0x6e489:
  jmp native_46E489
  nop #2


// native_41ABFB
assert(TOS.exe+0x1abfb,8b 8c 8a ec 71 15 00)
TOS.exe+0x1abfb:
  jmp native_41ABFB
  nop #2


// native_456B5C
assert(TOS.exe+0x56b5c,03 b4 90 ec 71 15 00)
TOS.exe+0x56b5c:
  jmp native_456B5C
  nop #2


// native_457EC8
assert(TOS.exe+0x57ec8,03 8c 87 ec 71 15 00)
TOS.exe+0x57ec8:
  jmp native_457EC8
  nop #2


// native_46E9C6
assert(TOS.exe+0x6e9c6,89 94 81 ec 71 15 00)
TOS.exe+0x6e9c6:
  jmp native_46E9C6
  nop #2


// native_426BAA
assert(TOS.exe+0x26baa,80 bc 11 ee 93 00 00 00)
TOS.exe+0x26baa:
  jmp native_426BAA
  nop #3


// native_42723D
assert(TOS.exe+0x2723d,80 bc 3a ee 93 00 00 00)
TOS.exe+0x2723d:
  jmp native_42723D
  nop #3


// native_428118
assert(TOS.exe+0x28118,c6 84 11 ee 93 00 00 00)
TOS.exe+0x28118:
  jmp native_428118
  nop #3


// native_46E481
assert(TOS.exe+0x6e481,80 fa 0c)
TOS.exe+0x6e481:
patch_native_46E481:
  cmp dl, #16
padding_242:
  nop #3-(padding_242-patch_native_46E481)


// projectile_write
assert(TOS.exe+0x6e79c,89 84 8e 4c 9a 00 00)
TOS.exe+0x6e79c:
  jmp projectile_write
  nop #2


// texture_tag_load
assert(TOS.exe+0x6e4b3,8b 85 d8 fe ff ff 83 c0 70)
TOS.exe+0x6e4b3:
  jmp texture_tag_load
  nop #4


// texture_tag_release
assert(TOS.exe+0x6dff6,0f b6 55 08 83 c2 70)
TOS.exe+0x6dff6:
  jmp texture_tag_release
  nop #2


// teardown_extra
assert(TOS.exe+0x7a9db,e8 00 35 ff ff)
TOS.exe+0x7a9db:
  call teardown_extra


// texture_selector
assert(TOS.exe+0x744e3,88 45 fe eb 28)
TOS.exe+0x744e3:
  jmp texture_selector


// texture_bind
assert(TOS.exe+0x7bc13,83 ff 1b 77 10)
TOS.exe+0x7bc13:
  jmp texture_bind


// texture_draw
assert(TOS.exe+0x74f15,8d b8 00 00 00 0d)
TOS.exe+0x74f15:
  jmp texture_draw
  nop #1


// .arena
