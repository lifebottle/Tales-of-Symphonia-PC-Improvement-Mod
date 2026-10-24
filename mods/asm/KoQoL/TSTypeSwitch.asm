//######################################################################################################
//# T/S Type Switch - KoQoL
//# Adds a selectable T-Type / S-Type label above the T/S slot list.
//# Confirm switches the character's type, mirrors accumulated T/S points,
//# and invokes the game's own routine to recalculate the T/S lean.
//######################################################################################################

[ENABLE]

//################################################
//# Verify original instructions
//################################################

assert(TOS.exe+0x130DCF,0F B7 46 36 5F)
assert(TOS.exe+0xF18CB,A0 DC 39 B1 00)
assert(TOS.exe+0xF18E2,53 57 8B CE BA BC 00 00 00)
assert(TOS.exe+0xF20F2,66 8B 15 7A 39 B1 00)
assert(TOS.exe+0xF2455,83 C4 18 E9 4F 01 00 00)
assert(TOS.exe+0xF262F,0F B7 05 7A 39 B1 00)
assert(TOS.exe+0xF3B4A,F7 C6 00 00 00 08)
assert(TOS.exe+0xF3D91,66 A1 7A 39 B1 00)

//################################################
//# Separate allocations: executable code, writable state,
//# read-only strings, and writable description buffer.
//################################################

alloc(mem_ts_code,0x1000)
alloc(mem_ts_state,0x100)
alloc(mem_ts_text,0x200)
alloc(mem_ts_buffer,0x40)

//################################################
//# Labels and registered tuning/state symbols
//################################################

label(TSGetCharID)
label(TSLeanHook)
label(TSLeanSkip)
label(TSCharHook)
label(TSDescHook)
label(TSDescOwn)
label(TSDescPlain)
label(TSDescIcon)
label(TSDescIconReady)
label(TSDescCopy)
label(TSDescDraw)
label(TSDescDone)
label(TSBarHook)
label(TSBarOrig)
label(TSHandHook)
label(TSHandOrig)
label(TSLabelHook)
label(TSPickPal)
label(TSPalDone)
label(TSXDone)
label(TSSkipLabel)
label(TSUpHook)
label(TSUpLoop)
label(TSUpNone)
label(TSUpSome)
label(TSInputHook)
label(TSInputSelected)
label(TSNoAltCancel)
label(TSNoAltConfirm)
label(TSSwallow)
label(TSDown)
label(TSCancel)
label(TSPass)
label(TSConfirm)
label(TSConfirmSkip)

label(TSFlip)
label(TSChar)
label(TSSel)
label(TSAnchorY)
label(TSGap)
label(TSFixedX)
label(TSXOff)
label(TSPal)
label(TSPalSel)
label(TSSize)
label(TSDescX)
label(TSDescY)
label(TSDescPal)
label(TSDescSize)
label(TSBtn)
label(TSUseIcon)
label(TSTxtT)
label(TSTxtS)
label(TSTxtN)
label(TSTxtToS)
label(TSTxtToT)
label(TSTxtToAny)
label(TSTxtIcToS)
label(TSTxtIcToT)
label(TSTxtIcToAny)
label(TSTxtBuf)

registersymbol(TSFlip)
registersymbol(TSChar)
registersymbol(TSSel)
registersymbol(TSAnchorY)
registersymbol(TSGap)
registersymbol(TSFixedX)
registersymbol(TSXOff)
registersymbol(TSPal)
registersymbol(TSPalSel)
registersymbol(TSSize)
registersymbol(TSDescX)
registersymbol(TSDescY)
registersymbol(TSDescPal)
registersymbol(TSDescSize)
registersymbol(TSBtn)
registersymbol(TSUseIcon)

//################################################
//# Hook code
//################################################

mem_ts_code:

// Character struct (ESI) -> character ID (EBX), game's own arithmetic.
TSGetCharID:
  mov ecx,esi
  sub ecx,[TOS.exe+0x6D3F68]
  mov eax,0xEA0EA0EB
  sub ecx,0x368
  imul ecx
  add edx,ecx
  sar edx,0x08
  mov ecx,edx
  shr ecx,0x1F
  add ecx,edx
  mov eax,0xD41D41D5
  mul ecx
  sub ecx,edx
  shr ecx,0x01
  lea ebx,[edx+ecx]
  shr ebx,0x08
  movzx ebx,bl
  ret

// 130DCF: mirror the lean when this character has been switched.
TSLeanHook:
  pushad
  call TSGetCharID
  cmp ebx,0x0F
  ja TSLeanSkip
  cmp byte ptr [TSFlip+ebx],0x00
  je TSLeanSkip
  neg dword ptr [ebp-0x38]
TSLeanSkip:
  popad
  movzx eax,word ptr [esi+0x36]      // displaced
  pop edi                              // displaced
  jmp TOS.exe+0x130DD4

// F18CB: remember the menu's current character pointer.
TSCharHook:
  push eax
  mov eax,[esp+0x34]
  mov [TSChar],eax
  pop eax
  mov al,[TOS.exe+0x7139DC]          // displaced
  jmp TOS.exe+0xF18D0

// F18E2: take over the description only when the new label is selected.
TSDescHook:
  cmp byte ptr [TSSel],0x00
  jne TSDescOwn
  push ebx                             // displaced
  push edi                             // displaced
  mov ecx,esi                          // displaced
  mov edx,0x000000BC                   // displaced
  jmp TOS.exe+0xF18EB                 // original call follows here

TSDescOwn:
  pushad
  mov ecx,[TSChar]
  test ecx,ecx
  jz TSDescDone
  movsx eax,byte ptr [ecx+0x24]
  cmp byte ptr [TSUseIcon],0x00
  jne TSDescIcon
TSDescPlain:
  mov esi,TSTxtToAny
  test eax,eax
  jz TSDescDraw
  mov esi,TSTxtToS                     // current T-type
  js TSDescDraw
  mov esi,TSTxtToT                     // current S-type
  jmp TSDescDraw
TSDescIcon:
  mov esi,TSTxtIcToAny
  test eax,eax
  jz TSDescIconReady
  mov esi,TSTxtIcToS
  js TSDescIconReady
  mov esi,TSTxtIcToT
TSDescIconReady:
  mov edi,TSTxtBuf                      // 0B <button> followed by text
  mov byte ptr [edi],0x0B
  mov al,[TSBtn]
  mov [edi+0x01],al
  add edi,0x02
TSDescCopy:
  mov al,[esi]
  mov [edi],al
  inc esi
  inc edi
  test al,al
  jnz TSDescCopy
  mov esi,TSTxtBuf
TSDescDraw:
  push 0x24
  push dword ptr [TSDescSize]
  push 0x07F698FF
  push dword ptr [TSDescPal]
  push dword ptr [TSDescY]
  push dword ptr [TSDescX]
  mov eax,esi
  call TOS.exe+0x132400
  add esp,0x18
TSDescDone:
  popad
  jmp TOS.exe+0xF18F3                 // skip original call and add esp,8

// F20F2: highlight bar uses (row * 0x27 + 0xA7).
TSBarHook:
  cmp byte ptr [TSSel],0x00
  je TSBarOrig
  mov dx,0xFFFF                        // row -1 selects the label
  jmp TOS.exe+0xF20F9
TSBarOrig:
  mov dx,[TOS.exe+0x71397A]            // displaced
  jmp TOS.exe+0xF20F9

// F262F: hand cursor uses (row * 0x27 + 0xB3).
TSHandHook:
  cmp byte ptr [TSSel],0x00
  je TSHandOrig
  mov eax,0x0000FFFF                   // row -1
  jmp TOS.exe+0xF2636
TSHandOrig:
  movzx eax,word ptr [TOS.exe+0x71397A] // displaced
  jmp TOS.exe+0xF2636

// F2455: draw T-Type/S-Type label above slot 0.
TSLabelHook:
  pushad
  mov eax,[esp+0x24]                   // row Y coordinate
  cmp eax,[TSAnchorY]
  jne TSSkipLabel
  mov ecx,[TSChar]
  test ecx,ecx
  jz TSSkipLabel
  movsx eax,byte ptr [ecx+0x24]
  mov esi,TSTxtN
  test eax,eax
  jz TSPickPal
  mov esi,TSTxtT
  js TSPickPal
  mov esi,TSTxtS
TSPickPal:
  mov ebx,[TSPal]
  cmp byte ptr [TSSel],0x00
  je TSPalDone
  mov ebx,[TSPalSel]
TSPalDone:
  mov edi,[esp+0x2C]                   // slot label flags
  mov ecx,[TSFixedX]
  test ecx,ecx
  jnz TSXDone
  mov ecx,[esp+0x20]
  add ecx,[TSXOff]
TSXDone:
  mov edx,[esp+0x24]
  sub edx,[TSGap]
  push 0x24
  push dword ptr [TSSize]
  push edi
  push ebx
  push edx
  push ecx
  mov eax,esi
  call TOS.exe+0x132400
  add esp,0x18
TSSkipLabel:
  popad
  add esp,0x18                        // displaced
  jmp TOS.exe+0xF25AC                 // displaced

// F3D91: pressing Up with no earlier valid slot selects the label.
TSUpHook:
  push eax
  push ecx
  movsx eax,word ptr [TOS.exe+0x71397A]
  mov ecx,[ebp-0x0C]
TSUpLoop:
  dec eax
  js TSUpNone
  cmp byte ptr [ecx+eax+0xEA],0x00
  ja TSUpSome
  jmp TSUpLoop
TSUpNone:
  pop ecx
  pop eax
  mov byte ptr [TSSel],0x01
  jmp TOS.exe+0xF4613
TSUpSome:
  pop ecx
  pop eax
  mov ax,[TOS.exe+0x71397A]          // displaced
  jmp TOS.exe+0xF3D97

// F3B4A: selected-label input handling.
TSInputHook:
  cmp byte ptr [TSSel],0x00
  jne TSInputSelected
  test esi,0x08000000                  // displaced
  jmp TOS.exe+0xF3B50

TSInputSelected:
  push eax
  test esi,0x08000000                  // cancel
  jnz TSCancel
  mov eax,esi
  and eax,0xFC000000
  jnz TSNoAltCancel
  test esi,0x00002000                  // alternate cancel
  jnz TSCancel
TSNoAltCancel:
  test esi,0x00000300                  // previous/next character
  jnz TSPass
  test esi,0x04000000                  // confirm
  jnz TSConfirm
  test eax,eax
  jnz TSNoAltConfirm
  test esi,0x00001000                  // alternate confirm
  jnz TSConfirm
TSNoAltConfirm:
  mov eax,[ebp-0x10]                   // held/repeat input
  test eax,0x20000000                  // down
  jnz TSDown
  test eax,0xFC000000
  jnz TSSwallow
  test al,0x02                         // alternate down
  jnz TSDown
TSSwallow:
  pop eax
  jmp TOS.exe+0xF4613
TSDown:
  mov byte ptr [TSSel],0x00
  jmp TSSwallow
TSCancel:
  mov byte ptr [TSSel],0x00
TSPass:
  pop eax
  test esi,0x08000000                  // displaced
  jmp TOS.exe+0xF3B50
TSConfirm:
  pop eax
  pushad
  mov esi,[ebp-0x0C]                  // character struct
  test esi,esi
  jz TSConfirmSkip
  call TSGetCharID
  cmp ebx,0x0F
  ja TSConfirmSkip
  xor byte ptr [TSFlip+ebx],0x01
  neg byte ptr [esi+0x10C]            // reverse accumulated T/S points
  call TOS.exe+0x1308F0                // recalculate character lean
TSConfirmSkip:
  popad
  jmp TOS.exe+0xF4613

//################################################
//# Mutable state and settings (writable allocation)
//################################################

mem_ts_state:
TSFlip:
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
TSChar:
  dd 0x00
TSSel:
  db 0x00
TSAnchorY:
  dd #167
TSGap:
  dd #39
TSFixedX:
  dd #332
TSXOff:
  dd 0x00
TSPal:
  dd 0x02
TSPalSel:
  dd 0x04
TSSize:
  dd 0x1E
TSDescX:
  dd #210
TSDescY:
  dd #539
TSDescPal:
  dd 0x05
TSDescSize:
  dd 0x2C
TSBtn:
  db 0x12
TSUseIcon:
  db 0x01

//################################################
//# Fixed strings (not writable)
//################################################

mem_ts_text:
TSTxtT:
  db "T-Type"
  db 0x00
TSTxtS:
  db "S-Type"
  db 0x00
TSTxtN:
  db "--"
  db 0x00
TSTxtToS:
  db "Confirm to switch to S-Type."
  db 0x00
TSTxtToT:
  db "Confirm to switch to T-Type."
  db 0x00
TSTxtToAny:
  db "Confirm to switch type."
  db 0x00
TSTxtIcToS:
  db " Switch to S-Type."
  db 0x00
TSTxtIcToT:
  db " Switch to T-Type."
  db 0x00
TSTxtIcToAny:
  db " Switch type."
  db 0x00

//################################################
//# Description text buffer (writable allocation)
//################################################

mem_ts_buffer:
TSTxtBuf:
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
  db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

//################################################
//# Install hooks: same eight addresses and overwritten lengths as CE
//################################################

TOS.exe+0x130DCF:
  jmp TSLeanHook

TOS.exe+0xF18CB:
  jmp TSCharHook

TOS.exe+0xF18E2:
  jmp TSDescHook
  nop #4

TOS.exe+0xF20F2:
  jmp TSBarHook
  nop #2

TOS.exe+0xF2455:
  jmp TSLabelHook
  nop #3

TOS.exe+0xF262F:
  jmp TSHandHook
  nop #2

TOS.exe+0xF3B4A:
  jmp TSInputHook
  nop #1

TOS.exe+0xF3D91:
  jmp TSUpHook
  nop #1
