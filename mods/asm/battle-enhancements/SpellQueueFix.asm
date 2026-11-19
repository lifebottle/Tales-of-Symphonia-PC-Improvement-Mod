//Adds a spell queue and unlocks the spell timer.
//Mystic spells have priority over Lv2 and Lv3.
[ENABLE]
define(SetSpellCharge,TOS.exe+26A13)
define(SpellHold,TOS.exe+26B13)
define(UnisonSlot,TOS.exe+2665C)
define(SpellTimerLogic,TOS.exe+27226)
define(SpellTimer,TOS.exe+27253)
define(SetCharID,TOS.exe+42B05)
define(SetEnemyID,TOS.exe+5A1EC)
define(SpellQueue_Main,TOS.exe+84DB7)

assert(SetSpellCharge,85 97 6C 90 00 00 74 02)
assert(SpellHold,80 BB B1 01 00 00 05 0F 84 F4 06 00 00 8B 15 DC 2E AD 00)
assert(UnisonSlot,75 17)
assert(SpellTimerLogic,75 53 8B 4E 38 F6 C1 01 74 1F 0F B6 93 B0 3A 01 00 8B 3D DC 2E AD 00 80 BC 3A EE 93 00 00 00 74 08 F7 C1 00 00 00 20 74 2C)
assert(SpellTimer,0F B7 83 BE 01 00 00 66 85 C0 74 08 48 66 89 83 BE 01 00 00)
assert(SetCharID,30 8B 22 13 00 00)
assert(SetEnemyID,80 A0 22 13 00 00 F0)
assert(SpellQueue_Main,74 0D 80 BB AC 01 00 00 12)

alloc(Mem_SpellQueueFix,1000)


//===[Allocated Memory]===//
Mem_SpellQueueFix:
//Start
Mem_SetSpellCharge:
	cmp byte [ebx+1B1],5
	jne TOS.exe+26A1D
	test edx,1000
	jz TOS.exe+26A1D
	jmp Ret_SetSpellCharge

Mem_SpellHold:
	cmp byte [ebx+1B1],5
	je TOS.exe+27214
	cmp byte [ebx+1B1],4
	je TOS.exe+26FFA
	mov edi,[TOS.exe+6D2EDC]
//Check Unison State
	cmp byte [edi+9108],0
	jne Ret_SpellHold
	movzx edx,byte [ebx+13AB0]
	cmp byte [edx+edi+93EE],0
	jne TOS.exe+26FFA
	mov eax,[ebx+C]
//Check Spell (>= Lv2)
	test byte [eax+38],1
	jz Ret_SpellHold
//Grab Actor ID
	movzx edx,byte [ebx+13AB4]
	cmp byte [edi+1BC],0
	jne SpellHold_Mystic
	cmp byte [ebx+13AB0],0
	jne SpellHold_Enemy
	cmp byte [edi+1B0],dl
	jne TOS.exe+26FFA
	jmp Ret_SpellHold
SpellHold_Enemy:
	cmp byte [edi+1B4],dl
	jne TOS.exe+26FFA
	jmp Ret_SpellHold
SpellHold_Mystic:
	cmp byte [edi+1BC],dl
	jne TOS.exe+26FFA
	jmp Ret_SpellHold

Mem_SpellTimer:
	movzx eax,word [ebx+1BE]
	test ax,ax
	jz AddActor
	dec eax
	mov [ebx+1BE],ax
	cmp byte [edx+9108],0
	jne Ret_SpellTimer
	test ax,ax
	jnz Ret_SpellTimer
AddActor:
	movzx ecx,byte [ebx+13AB4]
	dec ecx
	mov eax,1
	shl eax,cl
	inc ecx
	mov eax,ecx
	mov ecx,[ebx+C]
	test byte [ecx+38],20
	jnz AddMystic
//Check "Team"
	cmp byte [ebx+13AB0],0
	je AddPlayer
	jmp AddEnemy
AddMystic:
	xor ecx,ecx
AddMystic_Loop:
	cmp byte [ecx+edx+1BC],al
	je Ret_SpellTimer
	cmp byte [ecx+edx+1BC],0
	je AddMysticFound
	inc ecx
	cmp cl,#12
	jb AddMystic_Loop
	jmp Ret_SpellTimer
AddMysticFound:
	mov byte [ecx+edx+1BC],al
	jmp Ret_SpellTimer
AddPlayer:
	xor ecx,ecx
AddPlayer_Loop:
	cmp byte [ecx+edx+1B0],al
	je Ret_SpellTimer
	cmp byte [ecx+edx+1B0],0
	je AddPlayerFound
	inc ecx
	cmp cl,4
	jb AddPlayer_Loop
	jmp Ret_SpellTimer
AddPlayerFound:
	mov byte [ecx+edx+1B0],al
	jmp Ret_SpellTimer

AddEnemy:
	xor ecx,ecx
AddEnemy_Loop:
	cmp byte [ecx+edx+1B4],al
	je Ret_SpellTimer
	cmp byte [ecx+edx+1B4],0
	je AddEnemyFound
	inc ecx
	cmp cl,8
	jb AddEnemy_Loop
	jmp Ret_SpellTimer
AddEnemyFound:
	mov byte [ecx+edx+1B4],al
	jmp Ret_SpellTimer

Mem_SetCharID:
	xor [ebx+1322],cl
	mov cl,byte [ebp+10]
	inc ecx
	mov [ebx+13AB4],cl
	jmp Ret_SetCharID

Mem_SetEnemyID:
	and byte [eax+1322],F0
	mov ebx,[TOS.exe+6D2EDC]
//Player Party Size
	movzx ebx,byte [ebx+934C]
	inc ebx
	add bl,[ebp+20]
	mov [eax+13AB4],bl
	mov ebx,eax
	jmp Ret_SetEnemyID

Mem_SpellQueue_Main:
	mov edx,[TOS.exe+6D2EDC]
	cmp byte [ebx+1B0],C
	jne RemoveActor
	cmp word [ebx+1BE],0
	je Code_SkipA
RemoveActor:
//Grab Actor ID
	movzx ecx,byte [ebx+13AB4]
	dec ecx
	mov eax,1
	shl eax,cl
	inc ecx
	mov eax,ecx
	cmp byte [edx+1BC],0
	jne RemoveMystic
MysticExit:
//Check "Team"
	cmp byte [ebx+13AB0],0
	je RemovePlayer
	jmp RemoveEnemy
RemoveMystic:
	xor ecx,ecx
RemoveMystic_Loop:
	cmp byte [ecx+edx+1BC],al
	je RemoveMysticFound
	cmp byte [ecx+edx+1BC],0
	je MysticExit
	inc ecx
	cmp cl,#12
	jb RemoveMystic_Loop
	jmp MysticExit
RemoveMysticFound:
	cmp cl,#11
	jae RemoveMysticFound_End
RemoveMysticFound_Loop:
	shr word [ecx+edx+1BC],8
	cmp byte [ecx+edx+1BC],0
	je MysticExit
	inc ecx
	cmp cl,#11
	jb RemoveMysticFound
	jmp MysticExit
RemoveMysticFound_End:
	mov byte [ecx+edx+1BC],0
	jmp MysticExit
RemovePlayer:
	xor ecx,ecx
RemovePlayer_Loop:
	cmp byte [ecx+edx+1B0],al
	je RemovePlayerFound
	cmp byte [ecx+edx+1B0],0
	je Code_SkipA
	inc ecx
	cmp cl,4
	jb RemovePlayer_Loop
	jmp Code_SkipA
RemovePlayerFound:
	cmp cl,3
	jae RemovePlayerFound_End
RemovePlayerFound_Loop:
	shr word [ecx+edx+1B0],8
	cmp byte [ecx+edx+1B0],0
	je Code_SkipA
	inc ecx
	cmp cl,3
	jb RemovePlayerFound
	jmp Code_SkipA
RemovePlayerFound_End:
	mov byte [ecx+edx+1B0],0
	jmp Code_SkipA
RemoveEnemy:
	xor ecx,ecx
RemoveEnemy_Loop:
	cmp byte [ecx+edx+1B4],al
	je RemoveEnemyFound
	cmp byte [ecx+edx+1B4],0
	je Code_SkipA
	inc ecx
	cmp cl,8
	jb RemoveEnemy_Loop
	jmp Code_SkipA
RemoveEnemyFound:
	cmp cl,7
	jae RemoveEnemyFound_End
RemoveEnemyFound_Loop:
	shr word [ecx+edx+1B4],8
	cmp byte [ecx+edx+1B4],0
	je Code_SkipA
	inc ecx
	cmp cl,7
	jb RemoveEnemyFound
	jmp Code_SkipA
RemoveEnemyFound_End:
	mov byte [ecx+edx+1B4],0
	jmp Code_SkipA
Code_SkipA:
	mov edx,[TOS.exe+6D2EDC]
	cmp byte [edx+93EC],0
	jne TOS.exe+84EF8
	jmp Ret_SpellQueue_Main


//===[Addresses]===//
SetSpellCharge:
	jmp Mem_SetSpellCharge
	nop 3
Ret_SetSpellCharge:

SpellHold:
	jmp Mem_SpellHold
	nop 8
Ret_SpellHold:

UnisonSlot:
	nop 2

SpellTimerLogic:
	jmp TOS.exe+27253

SpellTimer:
	jmp Mem_SpellTimer
Ret_SpellTimer:
	jmp TOS.exe+27267
	nop 3

SetCharID:
	jmp Mem_SetCharID
	nop
Ret_SetCharID:

SetEnemyID:
	jmp Mem_SetEnemyID
	nop 2
Ret_SetEnemyID:

SpellQueue_Main:
	jmp Mem_SpellQueue_Main
Ret_SpellQueue_Main:
	jmp TOS.exe+84DD9
	nop 2
