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

[DISABLE]
CameraRotationA:
    db D9 5E 50 EB C7
CameraRotationB:
    db D9 5E 50 EB BF
dealloc(camera_rotation_code)
