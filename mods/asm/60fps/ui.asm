// Menu transitions, screen/title fades and skit animation/presentation.
// Tales of Symphonia 60FPS v0.0.46; controlled by [60FPS] Enabled=1.
// Fresh launch required. Reference VAs identify source bytes, not runtime allocations.
// Bare ASM numbers are hexadecimal; # introduces decimal.
// Sections:
//   Menu transitions
//   Screen fades
//   Credits timing
//   Skit timing

[ENABLE]

// ======================================================================
// Menu transitions
// Menu/panel transitions and their corresponding initialization values.
// ======================================================================

// Reference VA 004F3722..004F3728.
assert(TOS.exe+F3722,80 3D D6 39 B1 00 CC)
TOS.exe+F3722:
// Vanilla: cmp byte ptr [0xb139d6], 0xcc
  cmp byte ptr [TOS.exe+7139D6], 0xdf // 004F3722

// Reference VA 004F373A..004F3747.
assert(TOS.exe+F373A,80 05 D8 39 B1 00 CD 80 05 D6 39 B1 00 33)
TOS.exe+F373A:
// Vanilla: add byte ptr [0xb139d8], 0xcd; add byte ptr [0xb139d6], 0x33
  add byte ptr [TOS.exe+7139D8], 0xe0 // 004F373A
  add byte ptr [TOS.exe+7139D6], 0x20 // 004F3741

// Reference VA 004F3751..004F3757.
assert(TOS.exe+F3751,80 3D D6 39 B1 00 33)
TOS.exe+F3751:
// Vanilla: cmp byte ptr [0xb139d6], 0x33
  cmp byte ptr [TOS.exe+7139D6], 0x20 // 004F3751

// Reference VA 004F376C..004F3772.
assert(TOS.exe+F376C,80 05 D6 39 B1 00 CD)
TOS.exe+F376C:
// Vanilla: add byte ptr [0xb139d6], 0xcd
  add byte ptr [TOS.exe+7139D6], 0xe0 // 004F376C

// Reference VA 004F377C..004F3782.
assert(TOS.exe+F377C,80 3D D6 39 B1 00 CC)
TOS.exe+F377C:
// Vanilla: cmp byte ptr [0xb139d6], 0xcc
  cmp byte ptr [TOS.exe+7139D6], 0xdf // 004F377C

// Reference VA 004F37A3..004F37A9.
assert(TOS.exe+F37A3,80 3D D2 39 B1 00 D7)
TOS.exe+F37A3:
// Vanilla: cmp byte ptr [0xb139d2], 0xd7
  cmp byte ptr [TOS.exe+7139D2], 0xe6 // 004F37A3

// Reference VA 004F37C5..004F37CB.
assert(TOS.exe+F37C5,80 05 D2 39 B1 00 28)
TOS.exe+F37C5:
// Vanilla: add byte ptr [0xb139d2], 0x28
  add byte ptr [TOS.exe+7139D2], 0x19 // 004F37C5

// Reference VA 004F37DE..004F37DF.
assert(TOS.exe+F37DE,3C 28)
TOS.exe+F37DE:
// Vanilla: cmp al, 0x28
  cmp al, 0x19 // 004F37DE

// Reference VA 004F3811..004F3812.
assert(TOS.exe+F3811,04 D8)
TOS.exe+F3811:
// Vanilla: add al, 0xd8
  add al, 0xe7 // 004F3811

// Reference VA 004F4215..004F4217.
assert(TOS.exe+F4215,83 C1 33)
TOS.exe+F4215:
// Vanilla: add ecx, 0x33
  add ecx, 0x20 // 004F4215

// Reference VA 004F4224..004F4225.
assert(TOS.exe+F4224,04 33)
TOS.exe+F4224:
// Vanilla: add al, 0x33
  add al, 0x20 // 004F4224

// Reference VA 004F4636..004F4637.
assert(TOS.exe+F4636,3C 33)
TOS.exe+F4636:
// Vanilla: cmp al, 0x33
  cmp al, 0x20 // 004F4636

// Reference VA 004F463A..004F463B.
assert(TOS.exe+F463A,04 CD)
TOS.exe+F463A:
// Vanilla: add al, 0xcd
  add al, 0xe0 // 004F463A

// Reference VA 004F4729..004F4732.
assert(TOS.exe+F4729,C7 05 D2 39 B1 00 D8 01 00 00)
TOS.exe+F4729:
// Vanilla: mov dword ptr [0xb139d2], 0x1d8
  mov dword ptr [TOS.exe+7139D2], 0x1e7 // 004F4729

// Reference VA 004F77F4..004F77FA.
assert(TOS.exe+F77F4,80 3D C8 0D C3 01 D7)
TOS.exe+F77F4:
// Vanilla: cmp byte ptr [0x1c30dc8], 0xd7
  cmp byte ptr [TOS.exe+1830DC8], 0xe6 // 004F77F4

// Reference VA 004F7810..004F7816.
assert(TOS.exe+F7810,80 05 C8 0D C3 01 28)
TOS.exe+F7810:
// Vanilla: add byte ptr [0x1c30dc8], 0x28
  add byte ptr [TOS.exe+1830DC8], 0x19 // 004F7810

// Reference VA 004F782A..004F782C.
assert(TOS.exe+F782A,80 F9 28)
TOS.exe+F782A:
// Vanilla: cmp cl, 0x28
  cmp cl, 0x19 // 004F782A

// Reference VA 004F785A..004F785C.
assert(TOS.exe+F785A,80 C1 D8)
TOS.exe+F785A:
// Vanilla: add cl, 0xd8
  add cl, 0xe7 // 004F785A

// Reference VA 004F8018..004F8021.
assert(TOS.exe+F8018,C7 05 C8 0D C3 01 D8 01 00 00)
TOS.exe+F8018:
// Vanilla: mov dword ptr [0x1c30dc8], 0x1d8
  mov dword ptr [TOS.exe+1830DC8], 0x1e7 // 004F8018

// Reference VA 004FC3B7..004FC3BD.
assert(TOS.exe+FC3B7,80 3D B0 9F D5 01 D7)
TOS.exe+FC3B7:
// Vanilla: cmp byte ptr [0x1d59fb0], 0xd7
  cmp byte ptr [TOS.exe+1959FB0], 0xe6 // 004FC3B7

// Reference VA 004FC3EB..004FC3F1.
assert(TOS.exe+FC3EB,80 05 B0 9F D5 01 28)
TOS.exe+FC3EB:
// Vanilla: add byte ptr [0x1d59fb0], 0x28
  add byte ptr [TOS.exe+1959FB0], 0x19 // 004FC3EB

// Reference VA 004FC40F..004FC411.
assert(TOS.exe+FC40F,80 F9 28)
TOS.exe+FC40F:
// Vanilla: cmp cl, 0x28
  cmp cl, 0x19 // 004FC40F

// Reference VA 004FC4DF..004FC4E1.
assert(TOS.exe+FC4DF,80 C1 D8)
TOS.exe+FC4DF:
// Vanilla: add cl, 0xd8
  add cl, 0xe7 // 004FC4DF

// Reference VA 004FE6E9..004FE6F1.
assert(TOS.exe+FE6E9,66 C7 05 B0 9F D5 01 D8 01)
TOS.exe+FE6E9:
// Vanilla: mov word ptr [0x1d59fb0], 0x1d8
  mov word ptr [TOS.exe+1959FB0], 0x1e7 // 004FE6E9

// Reference VA 005068F0..005068F6.
assert(TOS.exe+1068F0,80 3D 38 0E C3 01 D7)
TOS.exe+1068F0:
// Vanilla: cmp byte ptr [0x1c30e38], 0xd7
  cmp byte ptr [TOS.exe+1830E38], 0xe6 // 005068F0

// Reference VA 00506916..0050691C.
assert(TOS.exe+106916,80 05 38 0E C3 01 28)
TOS.exe+106916:
// Vanilla: add byte ptr [0x1c30e38], 0x28
  add byte ptr [TOS.exe+1830E38], 0x19 // 00506916

// Reference VA 00506939..0050693A.
assert(TOS.exe+106939,3C 28)
TOS.exe+106939:
// Vanilla: cmp al, 0x28
  cmp al, 0x19 // 00506939

// Reference VA 00506A2F..00506A30.
assert(TOS.exe+106A2F,04 D8)
TOS.exe+106A2F:
// Vanilla: add al, 0xd8
  add al, 0xe7 // 00506A2F

// Reference VA 00507CE7..00507CEF.
assert(TOS.exe+107CE7,66 C7 05 38 0E C3 01 D8 01)
TOS.exe+107CE7:
// Vanilla: mov word ptr [0x1c30e38], 0x1d8
  mov word ptr [TOS.exe+1830E38], 0x1e7 // 00507CE7

// Reference VA 0050ABC1..0050ABC7.
assert(TOS.exe+10ABC1,80 3D 2C 17 C3 01 D7)
TOS.exe+10ABC1:
// Vanilla: cmp byte ptr [0x1c3172c], 0xd7
  cmp byte ptr [TOS.exe+183172C], 0xe6 // 0050ABC1

// Reference VA 0050ABE7..0050ABED.
assert(TOS.exe+10ABE7,80 05 2C 17 C3 01 28)
TOS.exe+10ABE7:
// Vanilla: add byte ptr [0x1c3172c], 0x28
  add byte ptr [TOS.exe+183172C], 0x19 // 0050ABE7

// Reference VA 0050AC01..0050AC03.
assert(TOS.exe+10AC01,80 F9 28)
TOS.exe+10AC01:
// Vanilla: cmp cl, 0x28
  cmp cl, 0x19 // 0050AC01

// Reference VA 0050AC57..0050AC59.
assert(TOS.exe+10AC57,80 C1 D8)
TOS.exe+10AC57:
// Vanilla: add cl, 0xd8
  add cl, 0xe7 // 0050AC57

// Reference VA 0050BDC2..0050BDCA.
assert(TOS.exe+10BDC2,66 C7 05 2C 17 C3 01 D8 01)
TOS.exe+10BDC2:
// Vanilla: mov word ptr [0x1c3172c], 0x1d8
  mov word ptr [TOS.exe+183172C], 0x1e7 // 0050BDC2

// Reference VA 0051799B..005179A1.
assert(TOS.exe+11799B,80 3D 90 95 8B 00 D7)
TOS.exe+11799B:
// Vanilla: cmp byte ptr [0x8b9590], 0xd7
  cmp byte ptr [TOS.exe+4B9590], 0xe6 // 0051799B

// Reference VA 005179BB..005179C1.
assert(TOS.exe+1179BB,80 05 90 95 8B 00 28)
TOS.exe+1179BB:
// Vanilla: add byte ptr [0x8b9590], 0x28
  add byte ptr [TOS.exe+4B9590], 0x19 // 005179BB

// Reference VA 005179D5..005179D7.
assert(TOS.exe+1179D5,80 FA 28)
TOS.exe+1179D5:
// Vanilla: cmp dl, 0x28
  cmp dl, 0x19 // 005179D5

// Reference VA 00517A22..00517A24.
assert(TOS.exe+117A22,80 C2 D8)
TOS.exe+117A22:
// Vanilla: add dl, 0xd8
  add dl, 0xe7 // 00517A22

// Reference VA 00518E54..00518E5C.
assert(TOS.exe+118E54,66 C7 05 90 95 8B 00 D8 01)
TOS.exe+118E54:
// Vanilla: mov word ptr [0x8b9590], 0x1d8
  mov word ptr [TOS.exe+4B9590], 0x1e7 // 00518E54

// Reference VA 00518F44..00518F4C.
assert(TOS.exe+118F44,66 C7 05 90 95 8B 00 D8 01)
TOS.exe+118F44:
// Vanilla: mov word ptr [0x8b9590], 0x1d8
  mov word ptr [TOS.exe+4B9590], 0x1e7 // 00518F44

// Reference VA 00518FAD..00518FB5.
assert(TOS.exe+118FAD,66 C7 05 90 95 8B 00 D8 01)
TOS.exe+118FAD:
// Vanilla: mov word ptr [0x8b9590], 0x1d8
  mov word ptr [TOS.exe+4B9590], 0x1e7 // 00518FAD

// Reference VA 00519011..00519019.
assert(TOS.exe+119011,66 C7 05 90 95 8B 00 D8 01)
TOS.exe+119011:
// Vanilla: mov word ptr [0x8b9590], 0x1d8
  mov word ptr [TOS.exe+4B9590], 0x1e7 // 00519011

// Reference VA 005190AC..005190B4.
assert(TOS.exe+1190AC,66 C7 05 90 95 8B 00 D8 01)
TOS.exe+1190AC:
// Vanilla: mov word ptr [0x8b9590], 0x1d8
  mov word ptr [TOS.exe+4B9590], 0x1e7 // 005190AC

// Reference VA 0051B5B4..0051B5BA.
assert(TOS.exe+11B5B4,80 3D 6C 17 C3 01 33)
TOS.exe+11B5B4:
// Vanilla: cmp byte ptr [0x1c3176c], 0x33
  cmp byte ptr [TOS.exe+183176C], 0x20 // 0051B5B4

// Reference VA 0051B5CD..0051B5D3.
assert(TOS.exe+11B5CD,80 05 6C 17 C3 01 CD)
TOS.exe+11B5CD:
// Vanilla: add byte ptr [0x1c3176c], 0xcd
  add byte ptr [TOS.exe+183176C], 0xe0 // 0051B5CD

// Reference VA 0051B5DA..0051B5E0.
assert(TOS.exe+11B5DA,80 3D 6C 17 C3 01 CC)
TOS.exe+11B5DA:
// Vanilla: cmp byte ptr [0x1c3176c], 0xcc
  cmp byte ptr [TOS.exe+183176C], 0xdf // 0051B5DA

// Reference VA 0051B612..0051B614.
assert(TOS.exe+11B612,80 F9 28)
TOS.exe+11B612:
// Vanilla: cmp cl, 0x28
  cmp cl, 0x19 // 0051B612

// Reference VA 0051B65E..0051B660.
assert(TOS.exe+11B65E,80 C1 D8)
TOS.exe+11B65E:
// Vanilla: add cl, 0xd8
  add cl, 0xe7 // 0051B65E

// Reference VA 0051B66C..0051B672.
assert(TOS.exe+11B66C,80 3D 68 17 C3 01 D7)
TOS.exe+11B66C:
// Vanilla: cmp byte ptr [0x1c31768], 0xd7
  cmp byte ptr [TOS.exe+1831768], 0xe6 // 0051B66C

// Reference VA 0051B686..0051B68C.
assert(TOS.exe+11B686,80 05 68 17 C3 01 28)
TOS.exe+11B686:
// Vanilla: add byte ptr [0x1c31768], 0x28
  add byte ptr [TOS.exe+1831768], 0x19 // 0051B686

// Reference VA 0051BE64..0051BE6A.
assert(TOS.exe+11BE64,80 05 6C 17 C3 01 33)
TOS.exe+11BE64:
// Vanilla: add byte ptr [0x1c3176c], 0x33
  add byte ptr [TOS.exe+183176C], 0x20 // 0051BE64

// Reference VA 0051C122..0051C12B.
assert(TOS.exe+11C122,C7 05 68 17 C3 01 D8 01 00 00)
TOS.exe+11C122:
// Vanilla: mov dword ptr [0x1c31768], 0x1d8
  mov dword ptr [TOS.exe+1831768], 0x1e7 // 0051C122

// Reference VA 0051C68A..0051C693.
assert(TOS.exe+11C68A,C7 05 68 17 C3 01 D8 03 00 00)
TOS.exe+11C68A:
// Vanilla: mov dword ptr [0x1c31768], 0x3d8
  mov dword ptr [TOS.exe+1831768], 0x3e7 // 0051C68A

// Reference VA 00524BF5..00524BFB.
assert(TOS.exe+124BF5,80 3D C8 3A B1 00 33)
TOS.exe+124BF5:
// Vanilla: cmp byte ptr [0xb13ac8], 0x33
  cmp byte ptr [TOS.exe+713AC8], 0x20 // 00524BF5

// Reference VA 00524D1E..00524D24.
assert(TOS.exe+124D1E,80 05 C8 3A B1 00 CD)
TOS.exe+124D1E:
// Vanilla: add byte ptr [0xb13ac8], 0xcd
  add byte ptr [TOS.exe+713AC8], 0xe0 // 00524D1E

// Reference VA 00524D2E..00524D34.
assert(TOS.exe+124D2E,80 3D C8 3A B1 00 CC)
TOS.exe+124D2E:
// Vanilla: cmp byte ptr [0xb13ac8], 0xcc
  cmp byte ptr [TOS.exe+713AC8], 0xdf // 00524D2E

// Reference VA 00524D53..00524D59.
assert(TOS.exe+124D53,80 3D C4 3A B1 00 D7)
TOS.exe+124D53:
// Vanilla: cmp byte ptr [0xb13ac4], 0xd7
  cmp byte ptr [TOS.exe+713AC4], 0xe6 // 00524D53

// Reference VA 00524D79..00524D7F.
assert(TOS.exe+124D79,80 05 C4 3A B1 00 28)
TOS.exe+124D79:
// Vanilla: add byte ptr [0xb13ac4], 0x28
  add byte ptr [TOS.exe+713AC4], 0x19 // 00524D79

// Reference VA 00524D93..00524D95.
assert(TOS.exe+124D93,80 FA 28)
TOS.exe+124D93:
// Vanilla: cmp dl, 0x28
  cmp dl, 0x19 // 00524D93

// Reference VA 00524DC3..00524DC5.
assert(TOS.exe+124DC3,80 C2 D8)
TOS.exe+124DC3:
// Vanilla: add dl, 0xd8
  add dl, 0xe7 // 00524DC3

// Reference VA 005269E8..005269EE.
assert(TOS.exe+1269E8,80 05 C8 3A B1 00 33)
TOS.exe+1269E8:
// Vanilla: add byte ptr [0xb13ac8], 0x33
  add byte ptr [TOS.exe+713AC8], 0x20 // 005269E8

// Reference VA 00526C55..00526C5D.
assert(TOS.exe+126C55,66 C7 05 C4 3A B1 00 D8 01)
TOS.exe+126C55:
// Vanilla: mov word ptr [0xb13ac4], 0x1d8
  mov word ptr [TOS.exe+713AC4], 0x1e7 // 00526C55

// Reference VA 00527AA1..00527AA7.
assert(TOS.exe+127AA1,80 3D 1A 19 C3 01 33)
TOS.exe+127AA1:
// Vanilla: cmp byte ptr [0x1c3191a], 0x33
  cmp byte ptr [TOS.exe+183191A], 0x20 // 00527AA1

// Reference VA 00527ABA..00527AC0.
assert(TOS.exe+127ABA,80 05 1A 19 C3 01 CD)
TOS.exe+127ABA:
// Vanilla: add byte ptr [0x1c3191a], 0xcd
  add byte ptr [TOS.exe+183191A], 0xe0 // 00527ABA

// Reference VA 00527ACA..00527AD0.
assert(TOS.exe+127ACA,80 3D 1A 19 C3 01 CC)
TOS.exe+127ACA:
// Vanilla: cmp byte ptr [0x1c3191a], 0xcc
  cmp byte ptr [TOS.exe+183191A], 0xdf // 00527ACA

// Reference VA 00527AEF..00527AF5.
assert(TOS.exe+127AEF,80 3D 18 19 C3 01 D7)
TOS.exe+127AEF:
// Vanilla: cmp byte ptr [0x1c31918], 0xd7
  cmp byte ptr [TOS.exe+1831918], 0xe6 // 00527AEF

// Reference VA 00527B17..00527B1D.
assert(TOS.exe+127B17,80 05 18 19 C3 01 28)
TOS.exe+127B17:
// Vanilla: add byte ptr [0x1c31918], 0x28
  add byte ptr [TOS.exe+1831918], 0x19 // 00527B17

// Reference VA 00527B31..00527B33.
assert(TOS.exe+127B31,80 F9 28)
TOS.exe+127B31:
// Vanilla: cmp cl, 0x28
  cmp cl, 0x19 // 00527B31

// Reference VA 00527C27..00527C29.
assert(TOS.exe+127C27,80 C1 D8)
TOS.exe+127C27:
// Vanilla: add cl, 0xd8
  add cl, 0xe7 // 00527C27

// Reference VA 005280D3..005280D9.
assert(TOS.exe+1280D3,80 05 1A 19 C3 01 33)
TOS.exe+1280D3:
// Vanilla: add byte ptr [0x1c3191a], 0x33
  add byte ptr [TOS.exe+183191A], 0x20 // 005280D3

// Reference VA 00528218..00528221.
assert(TOS.exe+128218,C7 05 18 19 C3 01 D8 01 00 00)
TOS.exe+128218:
// Vanilla: mov dword ptr [0x1c31918], 0x1d8
  mov dword ptr [TOS.exe+1831918], 0x1e7 // 00528218

// Reference VA 0052A1CE..0052A1D0.
assert(TOS.exe+12A1CE,80 F9 28)
TOS.exe+12A1CE:
// Vanilla: cmp cl, 0x28
  cmp cl, 0x19 // 0052A1CE

// Reference VA 0052A2D1..0052A2D3.
assert(TOS.exe+12A2D1,80 C1 D8)
TOS.exe+12A2D1:
// Vanilla: add cl, 0xd8
  add cl, 0xe7 // 0052A2D1

// Reference VA 0052A2DF..0052A2E5.
assert(TOS.exe+12A2DF,80 3D E0 01 8F 00 D7)
TOS.exe+12A2DF:
// Vanilla: cmp byte ptr [0x8f01e0], 0xd7
  cmp byte ptr [TOS.exe+4F01E0], 0xe6 // 0052A2DF

// Reference VA 0052A311..0052A317.
assert(TOS.exe+12A311,80 05 E0 01 8F 00 28)
TOS.exe+12A311:
// Vanilla: add byte ptr [0x8f01e0], 0x28
  add byte ptr [TOS.exe+4F01E0], 0x19 // 0052A311

// Reference VA 0052A87E..0052A887.
assert(TOS.exe+12A87E,C7 05 E0 01 8F 00 D8 01 00 00)
TOS.exe+12A87E:
// Vanilla: mov dword ptr [0x8f01e0], 0x1d8
  mov dword ptr [TOS.exe+4F01E0], 0x1e7 // 0052A87E

// Reference VA 0052AA71..0052AA79.
assert(TOS.exe+12AA71,66 C7 05 E0 01 8F 00 D8 03)
TOS.exe+12AA71:
// Vanilla: mov word ptr [0x8f01e0], 0x3d8
  mov word ptr [TOS.exe+4F01E0], 0x3e7 // 0052AA71

// Reference VA 0052D2F7..0052D2FD.
assert(TOS.exe+12D2F7,80 3D B0 3E B1 00 D7)
TOS.exe+12D2F7:
// Vanilla: cmp byte ptr [0xb13eb0], 0xd7
  cmp byte ptr [TOS.exe+713EB0], 0xe6 // 0052D2F7

// Reference VA 0052D313..0052D319.
assert(TOS.exe+12D313,80 05 B0 3E B1 00 28)
TOS.exe+12D313:
// Vanilla: add byte ptr [0xb13eb0], 0x28
  add byte ptr [TOS.exe+713EB0], 0x19 // 0052D313

// Reference VA 0052D32C..0052D32D.
assert(TOS.exe+12D32C,3C 28)
TOS.exe+12D32C:
// Vanilla: cmp al, 0x28
  cmp al, 0x19 // 0052D32C

// Reference VA 0052D35F..0052D360.
assert(TOS.exe+12D35F,04 D8)
TOS.exe+12D35F:
// Vanilla: add al, 0xd8
  add al, 0xe7 // 0052D35F

// Reference VA 0052E34F..0052E358.
assert(TOS.exe+12E34F,C7 05 B0 3E B1 00 D8 01 00 00)
TOS.exe+12E34F:
// Vanilla: mov dword ptr [0xb13eb0], 0x1d8
  mov dword ptr [TOS.exe+713EB0], 0x1e7 // 0052E34F

// Reference VA 00539D23..00539D29.
assert(TOS.exe+139D23,80 3D 6C 71 8B 00 D7)
TOS.exe+139D23:
// Vanilla: cmp byte ptr [0x8b716c], 0xd7
  cmp byte ptr [TOS.exe+4B716C], 0xe6 // 00539D23

// Reference VA 00539D40..00539D46.
assert(TOS.exe+139D40,80 05 6C 71 8B 00 28)
TOS.exe+139D40:
// Vanilla: add byte ptr [0x8b716c], 0x28
  add byte ptr [TOS.exe+4B716C], 0x19 // 00539D40

// Reference VA 00539D58..00539D5A.
assert(TOS.exe+139D58,80 F9 28)
TOS.exe+139D58:
// Vanilla: cmp cl, 0x28
  cmp cl, 0x19 // 00539D58

// Reference VA 00539E63..00539E65.
assert(TOS.exe+139E63,80 C1 D8)
TOS.exe+139E63:
// Vanilla: add cl, 0xd8
  add cl, 0xe7 // 00539E63

// Reference VA 0053A3C3..0053A3CC.
assert(TOS.exe+13A3C3,C7 05 6C 71 8B 00 D8 01 00 00)
TOS.exe+13A3C3:
// Vanilla: mov dword ptr [0x8b716c], 0x1d8
  mov dword ptr [TOS.exe+4B716C], 0x1e7 // 0053A3C3

// ======================================================================
// Screen fades
// General screen fades, town entrance titles and title/logo fades.
// ======================================================================

// Reference VA 004A8ADB..004A8ADC.
// Remove the second town entrance title fade contribution. This is not the field damage-number renderer
// despite its historical Battle_DamageNumberDisplay label.
assert(TOS.exe+A8ADB,DC E9)
TOS.exe+A8ADB:
// Vanilla: fsub st(1), st(0)
  nop // 004A8ADB
  nop // 004A8ADC

// Reference VA 004D0C8D..004D0C8E.
// Remove rate doubling from the common screen-fade update.
assert(TOS.exe+D0C8D,DC C0)
TOS.exe+D0C8D:
// Vanilla: fadd st(0), st(0)
  nop // 004D0C8D
  nop // 004D0C8E

// Title idle reveal delay (accepted live threshold revision, 2026-10-24).
// B18658 starts at zero and increments once per update; EDX holds its old value.
// Compare 843 instead of 421: reveal on update 844 instead of 422, preserving
// ~14.07 seconds at 60 FPS. Button-triggered reveal bypasses this wait.
assert(TOS.exe+15A335,81 FA A5 01 00 00)
TOS.exe+15A335:
  cmp edx, #843

// Reference VA 0055A34C..0055A34E.
// Title/logo fade increment: 16 -> 8 per update.
assert(TOS.exe+15A34C,83 C0 10)
TOS.exe+15A34C:
// Vanilla: add eax, 0x10
  add eax, #8 // 0055A34C

// ======================================================================
// Credits timing
// ======================================================================

// Halve scroll speed: height/21600 - 0.01.
assert(TOS.exe+153736,DC 35 08 3A 88 00)
assert(TOS.exe+1534B9,D8 05 D8 1E C3 01)
assert(TOS.exe+482B40,00 00 00 40 E1 7A 84 3F)
assert(TOS.exe+483A08,00 00 00 00 00 18 C5 40)
TOS.exe+483A08:
  dq (double)21600
assert(TOS.exe+153762,DC 25 F0 2B 88 00)
TOS.exe+153762:
  fsub qword ptr [TOS.exe+482B40]

// Preserve the ~20-second end hold.
assert(TOS.exe+1534EF,83 C0 02)
TOS.exe+1534EF:
  add eax, #1

// Preserve the ~6-second exit countdown.
assert(TOS.exe+152E61,C7 05 C0 85 B1 00 B4 00 00 00)
TOS.exe+152E61:
  mov dword ptr [TOS.exe+7185C0], #360

// ======================================================================
// Skit timing
// Skit portrait motion, facial channels, fades and textbox movement.
// ======================================================================

alloc(fps_skit_timing_code,1000)

label(fps_scene_texture_animation_rate)
label(fps_scene_texture_motion)
label(fps_skit_short_wait)
label(fps_skit_short_wait_original)

// Scripted skit animation loops need at least two 60 FPS updates per wait.
assert(TOS.exe+165E16,3C 0B 74 6F)
assert(TOS.exe+165E89,85 FF 7F 1A 8A 56 0C)
assert(TOS.exe+165E90,F6 DA 02 D2 02 D2 32 D1 80 E2 1C 32 D1 88 56 03)
assert(TOS.exe+165EA0,C7 46 0C 01 00 00 00)
assert(TOS.exe+165EA7,5F 5E 8B E5 5D C3)
TOS.exe+165E89:
  jmp near fps_skit_short_wait
  nop 2
TOS.exe+165EA0:
  mov dword ptr [esi + 0xC], #2

// Guard the native callbacks and continuations used by this script.
assert(TOS.exe+156463,F6 83 C4 00 00)
assert(TOS.exe+156951,D8 83 D8 09 00)

// Reference VA 00554BDB..00554BDE.
// Skit background fade: +2 instead of +4 per update.
assert(TOS.exe+154BDB,66 83 C0 04)
TOS.exe+154BDB:
// Vanilla: add ax, 4
  add ax, #2 // 00554BDB

// Reference VA 00554F79..00554F7C.
// Skit foreground opacity: +8 instead of +16 per update.
assert(TOS.exe+154F79,66 83 C0 10)
TOS.exe+154F79:
// Vanilla: add ax, 0x10
  add ax, #8 // 00554F79

// Reference VA 00555026..00555029.
// Skit text-box entrance slide: +4 instead of +8 per update.
assert(TOS.exe+155026,66 83 C0 08)
TOS.exe+155026:
// Vanilla: add ax, 8
  add ax, #4 // 00555026

// Reference VA 00556448..00556462.
// Integrate skit/scene sprite XYZ displacement at half rate.
assert(TOS.exe+156448,D9 43 04 D8 43 28 D9 5B 04 D9 43 2C D8 43 08 D9 5B 08 D9 43 30 D8 43 0C D9 5B 0C)
TOS.exe+156448:
  jmp near fps_scene_texture_motion // 00556448
  nop // 0055644D
  nop // 0055644E
  nop // 0055644F
  nop // 00556450
  nop // 00556451
  nop // 00556452
  nop // 00556453
  nop // 00556454
  nop // 00556455
  nop // 00556456
  nop // 00556457
  nop // 00556458
  nop // 00556459
  nop // 0055645A
  nop // 0055645B
  nop // 0055645C
  nop // 0055645D
  nop // 0055645E
  nop // 0055645F
  nop // 00556460
  nop // 00556461
  nop // 00556462

// Reference VA 005564EC..005564F3.
// Advance skit facial texture channel 1 timer once instead of twice.
assert(TOS.exe+1564EC,66 83 83 C8 00 00 00 02)
TOS.exe+1564EC:
// Vanilla: add word ptr [ebx + 0xc8], 2
  add word ptr [ebx + 0xc8], #1 // 005564EC

// Reference VA 005565DD..005565E4.
// Advance skit facial texture channel 2 timer once instead of twice.
assert(TOS.exe+1565DD,66 83 83 CE 00 00 00 02)
TOS.exe+1565DD:
// Vanilla: add word ptr [ebx + 0xce], 2
  add word ptr [ebx + 0xce], #1 // 005565DD

// Reference VA 005566AF..005566B6.
// Advance skit facial texture channel 3 timer once instead of twice.
assert(TOS.exe+1566AF,66 83 83 D2 00 00 00 02)
TOS.exe+1566AF:
// Vanilla: add word ptr [ebx + 0xd2], 2
  add word ptr [ebx + 0xd2], #1 // 005566AF

// Reference VA 0055694B..00556950.
// Halve skit/scene texture animation speed in the accepted helper.
assert(TOS.exe+15694B,D9 83 EC 09 00 00)
TOS.exe+15694B:
// Vanilla: fld dword ptr [ebx + 0x9ec]
  jmp near fps_scene_texture_animation_rate // 0055694B
  nop // 00556950

// ----------------------------------------------------------------------
// Reference payload 02EFF1AC..02EFF1EF; retained code/data/padding.
fps_skit_timing_code+C:
// Integrate XYZ velocity at a half step for scene texture/effect motion.
fps_scene_texture_motion:
  fld dword ptr [ebx + 0x28] // 02EFF1AC
  fmul dword ptr [fps_float_half] // 02EFF1AF
  fadd dword ptr [ebx + #4] // 02EFF1B5
  fstp dword ptr [ebx + #4] // 02EFF1B8
  fld dword ptr [ebx + 0x2c] // 02EFF1BB
  fmul dword ptr [fps_float_half] // 02EFF1BE
  fadd dword ptr [ebx + #8] // 02EFF1C4
  fstp dword ptr [ebx + #8] // 02EFF1C7
  fld dword ptr [ebx + 0x30] // 02EFF1CA
  fmul dword ptr [fps_float_half] // 02EFF1CD
  fadd dword ptr [ebx + 0xc] // 02EFF1D3
  fstp dword ptr [ebx + 0xc] // 02EFF1D6
  jmp near TOS.exe+156463 // 02EFF1D9

// Halve animation speed increment in scene texture animation.
fps_scene_texture_animation_rate:
  fld dword ptr [ebx + 0x9ec] // 02EFF1DE
  fmul dword ptr [fps_float_half] // 02EFF1E4
  jmp near TOS.exe+156951 // 02EFF1EA
  db 00 // 02EFF1EF: constants / retained padding

fps_skit_short_wait:
  cmp edi, #1
  jne short fps_skit_short_wait_original
  mov dword ptr [esi + 0xC], #2
  jmp near TOS.exe+165EA7
fps_skit_short_wait_original:
  test edi, edi
  jg near TOS.exe+165EA7
  mov dl, [esi + 0xC]
  jmp near TOS.exe+165E90

[DISABLE]
// Restoration evidence only; settings take effect on a fresh launch.
TOS.exe+165E89:
  db 85 FF 7F 1A 8A 56 0C
TOS.exe+165EA0:
  db C7 46 0C 01 00 00 00

// Menu transitions
TOS.exe+F3722:
  db 80,3D,D6,39,B1,00,CC
TOS.exe+F373A:
  db 80,05,D8,39,B1,00,CD,80,05,D6,39,B1,00,33
TOS.exe+F3751:
  db 80,3D,D6,39,B1,00,33
TOS.exe+F376C:
  db 80,05,D6,39,B1,00,CD
TOS.exe+F377C:
  db 80,3D,D6,39,B1,00,CC
TOS.exe+F37A3:
  db 80,3D,D2,39,B1,00,D7
TOS.exe+F37C5:
  db 80,05,D2,39,B1,00,28
TOS.exe+F37DE:
  db 3C,28
TOS.exe+F3811:
  db 04,D8
TOS.exe+F4215:
  db 83,C1,33
TOS.exe+F4224:
  db 04,33
TOS.exe+F4636:
  db 3C,33
TOS.exe+F463A:
  db 04,CD
TOS.exe+F4729:
  db C7,05,D2,39,B1,00,D8,01,00,00
TOS.exe+F77F4:
  db 80,3D,C8,0D,C3,01,D7
TOS.exe+F7810:
  db 80,05,C8,0D,C3,01,28
TOS.exe+F782A:
  db 80,F9,28
TOS.exe+F785A:
  db 80,C1,D8
TOS.exe+F8018:
  db C7,05,C8,0D,C3,01,D8,01,00,00
TOS.exe+FC3B7:
  db 80,3D,B0,9F,D5,01,D7
TOS.exe+FC3EB:
  db 80,05,B0,9F,D5,01,28
TOS.exe+FC40F:
  db 80,F9,28
TOS.exe+FC4DF:
  db 80,C1,D8
TOS.exe+FE6E9:
  db 66,C7,05,B0,9F,D5,01,D8,01
TOS.exe+1068F0:
  db 80,3D,38,0E,C3,01,D7
TOS.exe+106916:
  db 80,05,38,0E,C3,01,28
TOS.exe+106939:
  db 3C,28
TOS.exe+106A2F:
  db 04,D8
TOS.exe+107CE7:
  db 66,C7,05,38,0E,C3,01,D8,01
TOS.exe+10ABC1:
  db 80,3D,2C,17,C3,01,D7
TOS.exe+10ABE7:
  db 80,05,2C,17,C3,01,28
TOS.exe+10AC01:
  db 80,F9,28
TOS.exe+10AC57:
  db 80,C1,D8
TOS.exe+10BDC2:
  db 66,C7,05,2C,17,C3,01,D8,01
TOS.exe+11799B:
  db 80,3D,90,95,8B,00,D7
TOS.exe+1179BB:
  db 80,05,90,95,8B,00,28
TOS.exe+1179D5:
  db 80,FA,28
TOS.exe+117A22:
  db 80,C2,D8
TOS.exe+118E54:
  db 66,C7,05,90,95,8B,00,D8,01
TOS.exe+118F44:
  db 66,C7,05,90,95,8B,00,D8,01
TOS.exe+118FAD:
  db 66,C7,05,90,95,8B,00,D8,01
TOS.exe+119011:
  db 66,C7,05,90,95,8B,00,D8,01
TOS.exe+1190AC:
  db 66,C7,05,90,95,8B,00,D8,01
TOS.exe+11B5B4:
  db 80,3D,6C,17,C3,01,33
TOS.exe+11B5CD:
  db 80,05,6C,17,C3,01,CD
TOS.exe+11B5DA:
  db 80,3D,6C,17,C3,01,CC
TOS.exe+11B612:
  db 80,F9,28
TOS.exe+11B65E:
  db 80,C1,D8
TOS.exe+11B66C:
  db 80,3D,68,17,C3,01,D7
TOS.exe+11B686:
  db 80,05,68,17,C3,01,28
TOS.exe+11BE64:
  db 80,05,6C,17,C3,01,33
TOS.exe+11C122:
  db C7,05,68,17,C3,01,D8,01,00,00
TOS.exe+11C68A:
  db C7,05,68,17,C3,01,D8,03,00,00
TOS.exe+124BF5:
  db 80,3D,C8,3A,B1,00,33
TOS.exe+124D1E:
  db 80,05,C8,3A,B1,00,CD
TOS.exe+124D2E:
  db 80,3D,C8,3A,B1,00,CC
TOS.exe+124D53:
  db 80,3D,C4,3A,B1,00,D7
TOS.exe+124D79:
  db 80,05,C4,3A,B1,00,28
TOS.exe+124D93:
  db 80,FA,28
TOS.exe+124DC3:
  db 80,C2,D8
TOS.exe+1269E8:
  db 80,05,C8,3A,B1,00,33
TOS.exe+126C55:
  db 66,C7,05,C4,3A,B1,00,D8,01
TOS.exe+127AA1:
  db 80,3D,1A,19,C3,01,33
TOS.exe+127ABA:
  db 80,05,1A,19,C3,01,CD
TOS.exe+127ACA:
  db 80,3D,1A,19,C3,01,CC
TOS.exe+127AEF:
  db 80,3D,18,19,C3,01,D7
TOS.exe+127B17:
  db 80,05,18,19,C3,01,28
TOS.exe+127B31:
  db 80,F9,28
TOS.exe+127C27:
  db 80,C1,D8
TOS.exe+1280D3:
  db 80,05,1A,19,C3,01,33
TOS.exe+128218:
  db C7,05,18,19,C3,01,D8,01,00,00
TOS.exe+12A1CE:
  db 80,F9,28
TOS.exe+12A2D1:
  db 80,C1,D8
TOS.exe+12A2DF:
  db 80,3D,E0,01,8F,00,D7
TOS.exe+12A311:
  db 80,05,E0,01,8F,00,28
TOS.exe+12A87E:
  db C7,05,E0,01,8F,00,D8,01,00,00
TOS.exe+12AA71:
  db 66,C7,05,E0,01,8F,00,D8,03
TOS.exe+12D2F7:
  db 80,3D,B0,3E,B1,00,D7
TOS.exe+12D313:
  db 80,05,B0,3E,B1,00,28
TOS.exe+12D32C:
  db 3C,28
TOS.exe+12D35F:
  db 04,D8
TOS.exe+12E34F:
  db C7,05,B0,3E,B1,00,D8,01,00,00
TOS.exe+139D23:
  db 80,3D,6C,71,8B,00,D7
TOS.exe+139D40:
  db 80,05,6C,71,8B,00,28
TOS.exe+139D58:
  db 80,F9,28
TOS.exe+139E63:
  db 80,C1,D8
TOS.exe+13A3C3:
  db C7,05,6C,71,8B,00,D8,01,00,00

// Screen fades
TOS.exe+A8ADB:
  db DC,E9
TOS.exe+D0C8D:
  db DC,C0
TOS.exe+15A335:
  cmp edx, #421
TOS.exe+15A34C:
  db 83,C0,10

// Credits timing
TOS.exe+483A08:
  dq (double)10800
TOS.exe+153762:
  fsub qword ptr [TOS.exe+482BF0]
TOS.exe+1534EF:
  add eax, #2
TOS.exe+152E61:
  mov dword ptr [TOS.exe+7185C0], #180

// Skit timing
TOS.exe+154BDB:
  db 66,83,C0,04
TOS.exe+154F79:
  db 66,83,C0,10
TOS.exe+155026:
  db 66,83,C0,08
TOS.exe+156448:
  db D9,43,04,D8,43,28,D9,5B,04,D9,43,2C,D8,43,08,D9,5B,08,D9,43,30,D8,43,0C,D9,5B,0C
TOS.exe+1564EC:
  db 66,83,83,C8,00,00,00,02
TOS.exe+1565DD:
  db 66,83,83,CE,00,00,00,02
TOS.exe+1566AF:
  db 66,83,83,D2,00,00,00,02
TOS.exe+15694B:
  db D9,83,EC,09,00,00
dealloc(fps_skit_timing_code)
