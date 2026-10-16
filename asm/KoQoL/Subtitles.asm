//######################################################################################################
//# Adds a menu option to Enable/Disable Combat Subtitles
//######################################################################################################
[ENABLE]

//################################################
//# Memory allocation
//################################################

// Allocate memory for the subtitle flag, label and all the hooks.
alloc(mem_sub_flag,0x10)
alloc(mem_sub_text,0x20)
alloc(mem_sub_label_hook,0x40)
alloc(mem_sub_text_hook,0x40)
alloc(mem_sub_draw_hook,0x100)
alloc(mem_sub_cursor1_hook,0x30)
alloc(mem_sub_cursor2_hook,0x30)
alloc(mem_sub_help_hook,0x30)
alloc(mem_sub_down_hook,0x100)
alloc(mem_sub_up_hook,0x100)
alloc(mem_sub_input_hook,0x100)
alloc(mem_sub_voice_hook,0x30)
alloc(mem_sub_call_hook,0x30)


//################################################
//# Check original instructions
//################################################

// Make sure the original instructions match before installing the hooks.
assert(TOS.exe+0xFB560,8b 04 85 e0 99 91 00)
assert(TOS.exe+0xFB5A6,e8 f5 af 12 00)
assert(TOS.exe+0xFB5C6,83 7c 24 38 12)
assert(TOS.exe+0xFB497,0f b6 05 74 9f d5 01)
assert(TOS.exe+0xFC1C3,0f b6 05 74 9f d5 01)
assert(TOS.exe+0xFB434,a0 74 9f d5 01)
assert(TOS.exe+0xFC540,a0 74 9f d5 01)
assert(TOS.exe+0xFC5A0,a0 74 9f d5 01)
assert(TOS.exe+0xFC6F1,83 f8 13 0f 87 f4 08 00 00)
assert(TOS.exe+0x8E01C,e8 0f aa f9 ff)
assert(TOS.exe+0x8E072,e8 39 46 0a 00)
assert(TOS.exe+0x8DFA7,e8 54 6c 10 00)


//################################################
//# Addresses
//################################################

// Addresses used by the menu, text drawing and subtitle functions.
define(SubRow,TOS.exe+0x1959F74)
define(SubScroll,TOS.exe+0x1959F9E)
define(SubAnim,TOS.exe+0x1959FA0)
define(SubLabelTable,TOS.exe+0x5199E0)
define(SubLookup,TOS.exe+0x2265A0)
define(SubLangPtr,TOS.exe+0x4A9060)
define(SubLangTable,TOS.exe+0x3305FC)
define(SubOnOffTable,TOS.exe+0x4C6580)
define(SubErrStr,TOS.exe+0x47742C)
define(SubErrFn,TOS.exe+0x1A3BA0)
define(SubDrawText,TOS.exe+0x138550)
define(SubVoiceFn,TOS.exe+0x28A30)
define(SubMeasureFn,TOS.exe+0x1326B0)

// Return addresses for the hooks.
define(SubLabelReturn,TOS.exe+0xFB567)
define(SubTextReturn,TOS.exe+0xFB5AB)
define(SubDrawReturn,TOS.exe+0xFB5CB)
define(SubDrawEnd,TOS.exe+0xFBF9F)
define(SubCur1Return,TOS.exe+0xFB49E)
define(SubCur2Return,TOS.exe+0xFC1CA)
define(SubHelpReturn,TOS.exe+0xFB439)
define(SubHelpSkip,TOS.exe+0xFB4C3)
define(SubTail,TOS.exe+0xFC6EE)
define(SubInputTable,TOS.exe+0xFC6FA)
define(SubInputDone,TOS.exe+0xFCFEE)
define(SubInputAfter,TOS.exe+0xFCFF9)
define(SubVoiceReturn,TOS.exe+0x8E021)
define(SubCallReturn,TOS.exe+0x8E077)


//################################################
//# Register symbols
//################################################

// Expose the values and hooks so they can be accessed in Cheat Engine.
registersymbol(SubFlag)
registersymbol(SubText)
registersymbol(SubLabelHook)
registersymbol(SubTextHook)
registersymbol(SubDrawHook)
registersymbol(SubCursorHook1)
registersymbol(SubCursorHook2)
registersymbol(SubHelpHook)
registersymbol(SubDownHook)
registersymbol(SubUpHook)
registersymbol(SubInputHook)
registersymbol(SubVoiceHook)
registersymbol(SubCallHook)


//################################################
//# Subtitle setting
//################################################

// 1 = subtitles ON, 0 = subtitles OFF.
mem_sub_flag:
SubFlag:
  db 0x01, 0x00, 0x00, 0x00

// Text shown for the new option in the settings menu.
mem_sub_text:
SubText:
  db "Subtitles"
  db 0x00


//################################################
//# Add the subtitle label
//################################################

// Use unique label when the menu reaches list position 19.
// All other entries still use the original label table.
mem_sub_label_hook:
SubLabelHook:
  cmp eax, #19
  je sbt_label_row
  mov eax, [eax*4+SubLabelTable]
  jmp SubLabelReturn
sbt_label_row:
  mov eax, SubText
  jmp SubLabelReturn


//################################################
//# Handle the subtitle text lookup
//################################################

// Skip the normal string lookup for the new row.
// The label is already stored in SubText.
mem_sub_text_hook:
SubTextHook:
  cmp dword ptr [esp+0x54], #19
  je sbt_text_row
  call SubLookup
  jmp SubTextReturn
sbt_text_row:
  mov eax, SubText
  jmp SubTextReturn


//################################################
//# Draw the ON/OFF option
//################################################

// Draw the ON/OFF values for the new row.
// This follows the same drawing logic as the existing ON/OFF options.
mem_sub_draw_hook:
SubDrawHook:
  cmp dword ptr [esp+0x38], #19
  je sbt_draw_row
  cmp dword ptr [esp+0x38], #18
  jmp SubDrawReturn

sbt_draw_row:
  mov dword ptr [esp+0x18], #0
  mov dword ptr [esp+0x14], #1

sbt_draw_loop:
  movzx eax, byte ptr [SubFlag]
  mov edx, [SubLangPtr]
  and eax, #1
  xor ecx, ecx
  cmp eax, [esp+0x14]
  mov eax, [edx*4+SubLangTable]
  sete cl
  lea ecx, [ecx+ecx+#7]
  movzx esi, cx
  test eax, eax
  js sbt_draw_err
  cmp eax, #5
  jle sbt_draw_ok

// Handle an unexpected language/table value using the game's error function.
sbt_draw_err:
  push SubErrStr
  call SubErrFn
  add esp, #4
  mov eax, #1

sbt_draw_ok:
  mov ecx, [esp+0x1C]
  mov eax, [eax*4+SubOnOffTable]
  mov edx, [esp+0x18]
  push #36
  push #30
  push ebx
  push esi
  mov esi, [eax+edx]
  push ecx
  push edi
  call SubDrawText
  mov eax, [esp+0x2C]
  add dword ptr [esp+0x30], #4
  dec eax
  add esp, #24
  add edi, #90
  mov [esp+0x14], eax
  cmp eax, -#1
  jg sbt_draw_loop
  jmp SubDrawEnd


//################################################
//# Cursor position
//################################################

// The menu uses row 20 for the new option, but it is drawn at list position 19.
// Adjust the index so the cursor lines up with the new row.
mem_sub_cursor1_hook:
SubCursorHook1:
  movzx eax, byte ptr [SubRow]
  cmp eax, #20
  jne sbt_cur1_ok
  mov eax, #19
sbt_cur1_ok:
  jmp SubCur1Return

mem_sub_cursor2_hook:
SubCursorHook2:
  movzx eax, byte ptr [SubRow]
  cmp eax, #20
  jne sbt_cur2_ok
  mov eax, #19
sbt_cur2_ok:
  jmp SubCur2Return


//################################################
//# Help text
//################################################

// No help text, so skip the normal help-text handling.
mem_sub_help_hook:
SubHelpHook:
  mov al, [SubRow]
  cmp al, #20
  je SubHelpSkip
  jmp SubHelpReturn


//################################################
//# Move down through the menu
//################################################

// Handle the extra row when moving down.
// Row 18 -> Subtitles (20) -> Cancel (19) -> first row (0).
mem_sub_down_hook:
SubDownHook:
  mov al, [SubRow]
  cmp al, #19
  je sbt_down_wrap
  cmp al, #20
  je sbt_down_cancel
  cmp al, #18
  je sbt_down_row
  inc al
  mov [SubRow], al
  movsx ecx, word ptr [SubScroll]
  movzx esi, al
  add ecx, #9
  cmp ecx, esi
  jg sbt_down_end
  inc word ptr [SubScroll]
  mov ecx, #1
  mov [SubAnim], cx
  jmp sbt_down_end

// Moving down from Cancel wraps back to the first row.
sbt_down_wrap:
  xor al, al
  xor ecx, ecx
  mov [SubRow], al
  mov [SubScroll], cx
  jmp sbt_down_end

// Moving down from Subtitles goes to Cancel.
sbt_down_cancel:
  mov al, #19
  mov [SubRow], al
  jmp sbt_down_end

// Insert the Subtitles row after the existing row 18.
sbt_down_row:
  mov al, #20
  mov [SubRow], al
  movsx ecx, word ptr [SubScroll]
  add ecx, #9
  cmp ecx, #19
  jg sbt_down_end
  inc word ptr [SubScroll]
  mov ecx, #1
  mov [SubAnim], cx

sbt_down_end:
  mov dword ptr [ebp-#24], #28
  jmp SubTail


//################################################
//# Move up through the menu
//################################################

// Handle the extra row when moving up.
// Row 0 -> Cancel (19) -> Subtitles (20) -> row 18.
mem_sub_up_hook:
SubUpHook:
  mov al, [SubRow]
  test al, al
  jne sbt_up_nonzero
  mov al, #19
  mov [SubRow], al
  jmp sbt_up_end

sbt_up_nonzero:
  cmp al, #19
  je sbt_up_cancel
  cmp al, #20
  je sbt_up_row
  dec al
  mov [SubRow], al
  mov cx, [SubScroll]
  test cx, cx
  je sbt_up_end
  movzx esi, al
  cmp cx, si
  jle sbt_up_end
  or esi, -#1
  dec cx
  mov [SubAnim], si
  mov [SubScroll], cx
  jmp sbt_up_end

// Moving up from Cancel selects the Subtitles option.
sbt_up_cancel:
  mov al, #20
  mov [SubRow], al
  mov ecx, #11
  mov [SubScroll], cx
  jmp sbt_up_end

// Moving up from Subtitles returns to row 18.
sbt_up_row:
  mov al, #18
  mov [SubRow], al

sbt_up_end:
  mov dword ptr [ebp-#24], #28
  jmp SubTail


//################################################
//# Toggle subtitles ON/OFF
//################################################

// Handle left/right input separately when the Subtitles row is selected.
// The existing input handler is still used for the other menu entries.
mem_sub_input_hook:
SubInputHook:
  cmp eax, #20
  je sbt_input_row
  cmp eax, #19
  ja SubInputDone
  jmp SubInputTable

sbt_input_row:
  test ebx, 0x40000000
  jne sbt_input_right
  mov eax, ebx
  and eax, 0xFC000000
  jne sbt_input_check
  test bl, #4
  jne sbt_input_right

sbt_input_check:
  test ebx, ebx
  js sbt_input_left
  test eax, eax
  jne SubInputDone
  test bl, #8
  je SubInputDone

// Set the flag to 0 when turning subtitles OFF.
sbt_input_left:
  mov byte ptr [SubFlag], #0
  mov dword ptr [ebp-#24], #28
  jmp SubInputAfter

// Set the flag to 1 when turning subtitles ON.
sbt_input_right:
  mov byte ptr [SubFlag], #1
  mov dword ptr [ebp-#24], #28
  jmp SubInputAfter


//################################################
//# Disable subtitle processing when OFF
//################################################

// When subtitles are OFF, skip the normal function call.
// When they are ON, let the original function run as usual.
mem_sub_voice_hook:
SubVoiceHook:
  cmp byte ptr [SubFlag], #0
  je sbt_voice_off
  call SubVoiceFn
  jmp SubVoiceReturn

sbt_voice_off:
  xor eax, eax
  jmp SubVoiceReturn


//################################################
//# Skip subtitle text when OFF
//################################################

// When subtitles are OFF, skip the text measurement/drawing call.
// Otherwise, execute the original call.
mem_sub_call_hook:
SubCallHook:
  cmp byte ptr [SubFlag], #0
  je SubCallReturn
  call SubMeasureFn
  jmp SubCallReturn


//################################################
//# Install hooks
//################################################

// Redirect the label lookup to the custom handler.
TOS.exe+0xFB560:
  jmp SubLabelHook
  nop #2

// Redirect the text lookup to the custom handler.
TOS.exe+0xFB5A6:
  jmp SubTextHook

// Redirect the ON/OFF drawing to the custom handler.
TOS.exe+0xFB5C6:
  jmp SubDrawHook

// Fix the cursor position for the new menu row.
TOS.exe+0xFB497:
  jmp SubCursorHook1
  nop #2
TOS.exe+0xFC1C3:
  jmp SubCursorHook2
  nop #2

// Skip help text for the new option.
TOS.exe+0xFB434:
  jmp SubHelpHook

// Add the new row to the menu navigation.
TOS.exe+0xFC540:
  jmp SubDownHook
TOS.exe+0xFC5A0:
  jmp SubUpHook

// Handle left/right input for the ON/OFF toggle.
TOS.exe+0xFC6F1:
  jmp SubInputHook
  nop #4

// Control subtitle processing based on the flag.
TOS.exe+0x8E01C:
  jmp SubVoiceHook
TOS.exe+0x8E072:
  jmp SubCallHook

// Always remove the black subtitle box.
TOS.exe+0x8DFA7:
  nop #5