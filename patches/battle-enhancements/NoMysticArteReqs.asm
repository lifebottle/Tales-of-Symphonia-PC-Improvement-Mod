// TOS NoTSFix v26.10.1: parents 2308, 2332, 2342, 2586, 2584 and
// their auto-enabled children. One switch preserves the combined CT behavior.
// Lloyd/Kratos replace low HP with Over Limit; other native gates still apply.
// No persistent state or dependency on ManualOverLimit is required.
[ENABLE]

define(LloydLimit,TOS.exe+C87D)
define(LloydWeapon,TOS.exe+7604D)
define(LloydStory,TOS.exe+76066)
define(LloydHP,TOS.exe+7607C)
define(LloydReady,TOS.exe+76082)
define(MysticRejected,TOS.exe+761B7)
define(KratosLimit,TOS.exe+E106)
define(KratosStory,TOS.exe+7609A)
define(KratosHP,TOS.exe+760B4)
define(KratosReady,TOS.exe+760BD)
define(KratosWeapon,TOS.exe+760C9)
define(ZelosLimit,TOS.exe+EB80)
define(ZelosCharacter,TOS.exe+7696A)
define(SharedStory,TOS.exe+76986)
define(ZelosArte,TOS.exe+769A5)
define(ZelosPartner,TOS.exe+769C2)
define(ZelosSecondCharacter,TOS.exe+76A66)
define(ZelosStory,TOS.exe+76A87)
define(ZelosStat,TOS.exe+76ABB)
define(ZelosHP,TOS.exe+76ACC)
define(ZelosSpellStory,TOS.exe+25C2B)
define(ZelosSpellUsage,TOS.exe+25C4D)
define(PreseaLimitA,TOS.exe+D0C0)
define(PreseaLimitB,TOS.exe+D690)
define(RegalLimit,TOS.exe+F4B2)
define(RegalStory,TOS.exe+34857)

assert(LloydLimit,F7 D2 21 97 84 00 00 00)
assert(LloydWeapon,B8 9A 00 00 00 66 39 42 4A 0F 85 5B 01 00 00)
assert(LloydStory,0F 84 4B 01 00 00)
assert(LloydHP,0F 8D 35 01 00 00)
assert(KratosLimit,F7 D0 21 87 80 00 00 00)
assert(KratosStory,80 B9 A7 0F 00 00 00 0F 84 10 01 00 00)
assert(KratosHP,83 F8 0F 0F 8D FA 00 00 00)
assert(KratosWeapon,75 0A)
assert(ZelosLimit,F7 D0 21 83 80 00 00 00)
assert(ZelosCharacter,3C 07 0F 85 EB 00 00 00)
assert(SharedStory,85 C0 0F 84 CF 00 00 00)
assert(ZelosArte,66 39 55 08 0F 85 AE 00 00 00)
assert(ZelosPartner,3C 01 75 47 66 83 BF 5C 13 00 00 00 0F 84 89 00 00 00 F7 87 88 3A 01 00 00 00 00 02 74 2D)
assert(ZelosSecondCharacter,80 FA 06 0F 85 98 00 00 00)
assert(ZelosStory,81 79 40 30 4D 54 01 7C 77)
assert(ZelosStat,66 83 79 2A 64 7C 45)
assert(ZelosHP,83 F8 0F 7F 36)
assert(ZelosSpellStory,81 79 40 30 4D 54 01 7C 79)
assert(ZelosSpellUsage,7C 5E)
assert(PreseaLimitA,F7 D0 21 87 80 00 00 00)
assert(PreseaLimitB,F7 D0 21 87 80 00 00 00)
assert(RegalLimit,F7 D0 21 87 80 00 00 00)
assert(RegalStory,85 C0 74 76 8A 87 21 13 00 00)

// Guard the hook continuations and the actor status layout used by both hooks.
assert(LloydReady,68 E4 00 00 00 E9 21 01 00 00)
assert(KratosReady,6A 01 E8 EC D5 FC FF 83 C4 04 85 C0)
assert(MysticRejected,8A 97 21 13 00 00)
assert(SharedStory+8,8A 8F 21 13 00 00 80 E1 E0 80 F9 80 0F 82 BD 00 00 00)

alloc(LloydOverLimit,100)
alloc(KratosOverLimit,100)

// CT 2321: the HP arithmetic remains native; only its rejection branch changes.
// DL and flags intentionally carry the same results as the original CE hook.
LloydOverLimit:
    mov dl,[edi+1321]
    and dl,E0
    cmp dl,80
    jb MysticRejected
    jmp LloydReady

// CT 2353: EAX and flags intentionally match the original CE replacement.
KratosOverLimit:
    movzx eax,byte ptr [edi+1321]
    and al,E0
    cmp al,80
    jb MysticRejected
    jmp KratosReady

// Retain the CT's NOT instructions, removing only the per-battle bit clearing.
LloydLimit:
    not edx
    nop 6
KratosLimit:
    not eax
    nop 6
ZelosLimit:
    not eax
    nop 6
PreseaLimitA:
    not eax
    nop 6
PreseaLimitB:
    not eax
    nop 6
RegalLimit:
    not eax
    nop 6

LloydWeapon:
    nop F
LloydStory:
    nop 6
LloydHP:
    jmp LloydOverLimit
    nop
KratosStory:
    cmp byte ptr [ecx+FA7],0
    nop 6
KratosHP:
    jmp KratosOverLimit
    nop 4
KratosWeapon:
    nop 2

ZelosCharacter:
    nop 8
// CT 2325 and 2597 overlap. Own this site once, retaining Presea's TEST.
// The following AND/CMP overwrites flags before the next conditional branch.
SharedStory:
    test eax,eax
    nop 6
ZelosArte:
    nop A
ZelosPartner:
    nop 1E
ZelosSecondCharacter:
    nop 9
ZelosStory:
    nop 9
ZelosStat:
    nop 7
ZelosHP:
    nop 5
ZelosSpellStory:
    // A scalar story-progress threshold, not an address to relocate.
    cmp dword ptr [ecx+40],01544D30
    nop 2
ZelosSpellUsage:
    nop 2
RegalStory:
    test eax,eax
    nop 2
    mov al,[edi+1321]

[DISABLE]

LloydLimit:
    db F7 D2 21 97 84 00 00 00
LloydWeapon:
    db B8 9A 00 00 00 66 39 42 4A 0F 85 5B 01 00 00
LloydStory:
    db 0F 84 4B 01 00 00
LloydHP:
    db 0F 8D 35 01 00 00
KratosLimit:
    db F7 D0 21 87 80 00 00 00
KratosStory:
    db 80 B9 A7 0F 00 00 00 0F 84 10 01 00 00
KratosHP:
    db 83 F8 0F 0F 8D FA 00 00 00
KratosWeapon:
    db 75 0A
ZelosLimit:
    db F7 D0 21 83 80 00 00 00
ZelosCharacter:
    db 3C 07 0F 85 EB 00 00 00
SharedStory:
    db 85 C0 0F 84 CF 00 00 00
ZelosArte:
    db 66 39 55 08 0F 85 AE 00 00 00
ZelosPartner:
    db 3C 01 75 47 66 83 BF 5C 13 00 00 00 0F 84 89 00 00 00 F7 87 88 3A 01 00 00 00 00 02 74 2D
ZelosSecondCharacter:
    db 80 FA 06 0F 85 98 00 00 00
ZelosStory:
    db 81 79 40 30 4D 54 01 7C 77
ZelosStat:
    db 66 83 79 2A 64 7C 45
ZelosHP:
    db 83 F8 0F 7F 36
ZelosSpellStory:
    db 81 79 40 30 4D 54 01 7C 79
ZelosSpellUsage:
    db 7C 5E
PreseaLimitA:
    db F7 D0 21 87 80 00 00 00
PreseaLimitB:
    db F7 D0 21 87 80 00 00 00
RegalLimit:
    db F7 D0 21 87 80 00 00 00
RegalStory:
    db 85 C0 74 76 8A 87 21 13 00 00

dealloc(LloydOverLimit)
dealloc(KratosOverLimit)
