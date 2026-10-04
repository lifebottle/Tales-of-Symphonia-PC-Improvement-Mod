// TOS NoTSFix v26.10, entry 2577: [Clamp Camera Min Zoom].
// MinCameraDistance=x (integer 0..100), native minimum=26*x+2400.
// The manifest leaves this hook uninstalled at x=0 (the default).
[ENABLE]

define(BattleCameraZoom,TOS.exe+2BD8A)
define(CameraReturn,TOS.exe+2BD90)
assert(BattleCameraZoom,D9 46 68 D8 66 6C)
assert(CameraReturn,D9 5C 24 18 D9 44 24 18 D9 E1 D9 5C 24 18 D9 44 24 18 DC 0D B0 33 88 00 EB 3C)

alloc(camera_code,100)
alloc(camera_settings,4)
label(camera_distance)
label(camera_scale)
label(camera_base)
label(restore_eax)
label(original)

camera_settings:
camera_distance:
    dd (float)0

camera_code:
    pushfd
    // Retain the table's camera-mode bypass and signed float-bit comparison.
    cmp word ptr [esi+D4],0
    jne original
    push eax
    // Convert the configured scale without disturbing live x87/SSE state.
    sub esp,14
    movdqu [esp],xmm0
    stmxcsr [esp+10]
    movss xmm0,[camera_distance]
    mulss xmm0,[camera_scale]
    addss xmm0,[camera_base]
    movd eax,xmm0
    ldmxcsr [esp+10]
    movdqu xmm0,[esp]
    lea esp,[esp+14]
    cmp eax,[esi+6C]
    jl restore_eax
    mov [esi+6C],eax
restore_eax:
    pop eax
original:
    popfd
    fld dword ptr [esi+68]
    fsub dword ptr [esi+6C]
    jmp CameraReturn

camera_scale:
    dd (float)26
camera_base:
    dd (float)2400

BattleCameraZoom:
    jmp camera_code
    nop

[DISABLE]
BattleCameraZoom:
    db D9 46 68 D8 66 6C
dealloc(camera_code)
dealloc(camera_settings)
