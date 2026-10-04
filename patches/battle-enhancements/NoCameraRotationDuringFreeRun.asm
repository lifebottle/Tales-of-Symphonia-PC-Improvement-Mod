// TOS NoTSFix v26.10, entry 424: [Disable Camera Rot During Free Run].
// Like the table, follow the first actor's Free Run state, not any party member.
// FreeRun owns and refreshes freerun_mem; both camera paths consume one x87 value.
[ENABLE]

define(CameraRotationA,TOS.exe+2B9E8)
define(CameraRotationB,TOS.exe+2B9F0)
define(CameraContinue,TOS.exe+2B9B4)
assert(CameraRotationA,D9 5E 50 EB C7)
assert(CameraRotationB,D9 5E 50 EB BF)
assert(CameraContinue,80 BE EC 93 00 00 00 75 5E 83 BE E0 93 00 00 00)

alloc(camera_rotation_code,100)
label(skip_rotation)

camera_rotation_code:
    pushfd
    cmp dword ptr [freerun_mem],1
    je skip_rotation
    popfd
    fstp dword ptr [esi+50]
    jmp CameraContinue
skip_rotation:
    popfd
    fstp st(0)
    jmp CameraContinue

CameraRotationA:
    jmp camera_rotation_code
CameraRotationB:
    jmp camera_rotation_code

// Camera-right focus and zoom from camera-right-focus-zoom.asm.
// Always active with this option, matching the prototype (no Free Run/L2 gate).
// Native single-player fallback, actor eligibility and downstream zoom stay intact.
define(CameraRight,TOS.exe+19B23C0)
define(BattleState,TOS.exe+6D2EDC)
define(FocusContinue,TOS.exe+2CBAB)
define(CountPlayers,TOS.exe+61D50)
define(FirstPlayer,TOS.exe+61CD0)
define(NativeZoom,TOS.exe+2D260)
define(EligibleActor,TOS.exe+2D970)
// Guard skipped setup, continuation, and native callback/layout assumptions.
assert(TOS.exe+2CBA0,8D 7D B4 8D 75 8C)
assert(FocusContinue,D9 85 70 FF FF FF)
assert(TOS.exe+2DAB1,D9 45 C0 D8 4D E4)
assert(CountPlayers,8B 15 DC 2E AD 00 56 0F B6 B2 4C 93 00 00 57 33 FF 33 C9 85 F6)
assert(TOS.exe+61D78,69 C0 E0 3B 01 00 8A 84 10 C0 45 01 00 24 1C 3C 08)
assert(FirstPlayer,8B 0D DC 2E AD 00 0F B6 81 5C 90 00 00 69 C0 E0 3B 01 00)
assert(NativeZoom,55 8B EC 83 EC 70 53 56 57 8B F0 E8 E0 4A 03 00 83 F8 02 0F 8C 3F 06 00 00)
assert(EligibleActor,8A 82 20 13 00 00 C0 E8 02 24 07 74 63 3C 01 74 5F)
assert(TOS.exe+2D9C4,3B 90 6C 39 01 00 74 0B)

assert(TOS.exe+2CB9B,E8 30 73 16 00)
assert(TOS.exe+2CBA6,E8 25 73 16 00)
assert(TOS.exe+2DAAB,D9 45 C4 D8 4D E8)
assert(TOS.exe+2C6DB,E8 80 0B 00 00)
alloc(camera_right_code,1000,TOS.exe)
label(focus_right)
label(write_axes)
label(adjustment_axes)
label(zoom_right)
label(multiplayer)
label(group_loop)
label(actor_loop)
label(next_group)
label(include_actor)
label(project_right)

camera_right_code:

focus_right:
    mov eax, esi
    lea edx, [eax+24]
    push FocusContinue
write_axes:
    mov ecx, CameraRight
    fld dword ptr [ecx]
    fst dword ptr [eax]
    fchs
    fstp dword ptr [edx]
    fldz
    fst dword ptr [eax+4]
    fstp dword ptr [edx+4]
    fld dword ptr [ecx+20]
    fst dword ptr [eax+8]
    fchs
    fstp dword ptr [edx+8]
    ret
adjustment_axes:
    lea eax, [ebp-40]
    lea edx, [ebp-34]
    call write_axes
    fld dword ptr [ebp-3C]
    fmul dword ptr [ebp-18]
    ret

// This call site consumes only ST(0); its two side outputs are unused.
zoom_right:
    pushad
    call CountPlayers
    cmp eax, 2
    jge multiplayer
    popad
    jmp NativeZoom
multiplayer:
    call FirstPlayer
    mov edx, eax
    mov ebp, [eax+1396C]
    call project_right
    fld st(0)                     // min, max
    mov edx, ebp
    call include_actor
    mov edi, dword ptr [BattleState]
    lea ebp, [edi+905C]
    movzx esi, word ptr [edi+934C] // packed party/enemy counts
    add edi, 132A0
group_loop:
    mov eax, esi
    movzx ebx, al
actor_loop:
    dec ebx
    js next_group
    movzx edx, byte ptr [ebp+ebx]
    imul edx, edx, 13BE0
    add edx, edi
    call EligibleActor            // integer-only; preserves EDX and x87 stack
    test eax, eax
    jz actor_loop
    call include_actor
    jmp actor_loop
next_group:
    add edi, 4EF80
    add ebp, 8
    shr esi, 8
    jnz group_loop
    fsubp st(1)                    // max - min
    popad
    ret

include_actor:
    call project_right            // value, min, max
    fld st(0)                     // value, value, min, max
    fcomi st(2)
    fcmovnb st(2)
    fstp st(2)                    // value, new min, max
    fcomi st(2)
    fcmovb st(2)
    fstp st(2)                    // new min, new max
    ret
project_right:
    add edx, 1389C
    mov ecx, CameraRight
    fld dword ptr [edx]
    fmul dword ptr [ecx]
    fld dword ptr [edx+8]
    fmul dword ptr [ecx+20]
    faddp st(1)
    ret

TOS.exe+2CB9B:
    jmp focus_right
TOS.exe+2DAAB:
    call adjustment_axes
    nop
TOS.exe+2C6DB:
    call zoom_right
[DISABLE]
CameraRotationA:
    db D9 5E 50 EB C7
CameraRotationB:
    db D9 5E 50 EB BF
dealloc(camera_rotation_code)

TOS.exe+2CB9B:
    db E8 30 73 16 00
TOS.exe+2DAAB:
    db D9 45 C4 D8 4D E8
TOS.exe+2C6DB:
    db E8 80 0B 00 00
dealloc(camera_right_code)
