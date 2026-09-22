// Additional spell slots: maintained CE-style source.
// Native helpers and writable arena remain separately allocated.
[ENABLE]
alloc(mem_spell_code,0x1c10)
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
registersymbol(slot_addr)
registersymbol(busy_addr)
registersymbol(choose)
registersymbol(find_free)
registersymbol(capacity)
registersymbol(cast_ready)
registersymbol(alternate_launch)
registersymbol(direct_launch)
registersymbol(can_use)
registersymbol(ai_capacity)
registersymbol(general_capacity)
registersymbol(unison_a)
registersymbol(unison_b)
registersymbol(buffer_init)
registersymbol(launch_stats)
registersymbol(cleanup_extra)
registersymbol(snapshot_defs)
registersymbol(resolve_defs)
registersymbol(loaded_defs)
registersymbol(script_defs)
registersymbol(prepare_battle)
registersymbol(slot_offset)
registersymbol(map_busy)
registersymbol(map_effect)
registersymbol(map_model)
registersymbol(projectile_write)
registersymbol(texture_tag_load)
registersymbol(texture_tag_release)
registersymbol(texture_selector)
registersymbol(texture_id)
registersymbol(texture_bind)
registersymbol(texture_draw)
registersymbol(teardown_extra)
registersymbol(queue_busy_compat)
registersymbol(native_40CADF)
registersymbol(native_40CB5F)
registersymbol(native_40CBF1)
registersymbol(native_40CC78)
registersymbol(native_40D277)
registersymbol(native_40D2FE)
registersymbol(native_40DA17)
registersymbol(native_40DA9E)
registersymbol(native_40DB25)
registersymbol(native_40DBAC)
registersymbol(native_40DC33)
registersymbol(native_40E390)
registersymbol(native_40E410)
registersymbol(native_40E4AF)
registersymbol(native_40E545)
registersymbol(native_40EE25)
registersymbol(native_40EEA5)
registersymbol(native_40EF44)
registersymbol(native_40EFDA)
registersymbol(native_40F632)
registersymbol(native_40F6B6)
registersymbol(native_40FDEB)
registersymbol(native_40FF74)
registersymbol(native_40FFF5)
registersymbol(native_41007D)
registersymbol(native_41057D)
registersymbol(native_4109ED)
registersymbol(native_410A3A)
registersymbol(native_410B86)
registersymbol(native_410BFD)
registersymbol(native_410D4D)
registersymbol(native_410DBD)
registersymbol(native_4110ED)
registersymbol(native_41141D)
registersymbol(native_411489)
registersymbol(native_4114FC)
registersymbol(native_41163D)
registersymbol(native_41177D)
registersymbol(native_4117FB)
registersymbol(native_411A06)
registersymbol(native_411BC9)
registersymbol(native_411D2D)
registersymbol(native_411D96)
registersymbol(native_412235)
registersymbol(native_41247D)
registersymbol(native_4125BD)
registersymbol(native_41275D)
registersymbol(native_4129E3)
registersymbol(native_412B2D)
registersymbol(native_412E31)
registersymbol(native_412F0D)
registersymbol(native_41305A)
registersymbol(native_4130DD)
registersymbol(native_413487)
registersymbol(native_413642)
registersymbol(native_413A40)
registersymbol(native_415B1D)
registersymbol(native_415B91)
registersymbol(native_415EAD)
registersymbol(native_4162B4)
registersymbol(native_4163CD)
registersymbol(native_4178F5)
registersymbol(native_417F74)
registersymbol(native_4186A2)
registersymbol(native_41897F)
registersymbol(native_418A05)
registersymbol(native_41907D)
registersymbol(native_4190EB)
registersymbol(native_419167)
registersymbol(native_41A283)
registersymbol(native_41A623)
registersymbol(native_41A694)
registersymbol(native_41A70E)
registersymbol(native_41A787)
registersymbol(native_41A7FD)
registersymbol(native_41AA41)
registersymbol(native_41B133)
registersymbol(native_41B7E3)
registersymbol(native_41BD6C)
registersymbol(native_41BE17)
registersymbol(native_41BE95)
registersymbol(native_41C2FB)
registersymbol(native_41C371)
registersymbol(native_41C8CE)
registersymbol(native_41C97A)
registersymbol(native_41CA2C)
registersymbol(native_41CADD)
registersymbol(native_41CF64)
registersymbol(native_41D62D)
registersymbol(native_41DB3B)
registersymbol(native_41E1A3)
registersymbol(native_41E6A8)
registersymbol(native_41F07B)
registersymbol(native_420162)
registersymbol(native_4204B7)
registersymbol(native_4207FA)
registersymbol(native_420DA7)
registersymbol(native_4210CD)
registersymbol(native_4211A2)
registersymbol(native_42157C)
registersymbol(native_421B23)
registersymbol(native_421FBA)
registersymbol(native_4222D7)
registersymbol(native_422516)
registersymbol(native_42283E)
registersymbol(native_4228B0)
registersymbol(native_422EAA)
registersymbol(native_42361F)
registersymbol(native_42377B)
registersymbol(native_423AD7)
registersymbol(native_423DA1)
registersymbol(native_423E1F)
registersymbol(native_4243BF)
registersymbol(native_4245E1)
registersymbol(native_424A0D)
registersymbol(native_425043)
registersymbol(native_4250C1)
registersymbol(native_425157)
registersymbol(native_42524B)
registersymbol(native_40931F)
registersymbol(native_40C5EB)
registersymbol(native_40DE3B)
registersymbol(native_40E8BB)
registersymbol(native_40F19A)
registersymbol(native_40F7E3)
registersymbol(native_41A337)
registersymbol(native_4282CA)
registersymbol(native_46DEF0)
registersymbol(native_46E063)
registersymbol(native_46E3C6)
registersymbol(native_46EA41)
registersymbol(native_46EA9A)
registersymbol(native_451B5A)
registersymbol(native_46E489)
registersymbol(native_41ABFB)
registersymbol(native_456B5C)
registersymbol(native_457EC8)
registersymbol(native_46E9C6)
registersymbol(native_426BAA)
registersymbol(native_42723D)
registersymbol(native_428118)
registersymbol(native_46E481)
registersymbol(code_end)

mem_spell_code:

// EAX = logical slot, EBX = battle. Other registers are preserved.
slot_addr:
  cmp eax, #6
  jb slot_native
  sub eax, #6
  shl eax, #19
  add eax, EXTRA_SLOTS
  ret
slot_native:
  imul eax, eax, 0xA320
  lea eax, [ebx+eax+0x15B310]
  ret
busy_addr:
  cmp eax, #6
  jb busy_native
  lea eax, [eax+EXTRA_BUSY-#6]
  ret
busy_native:
  lea eax, [ebx+eax+0x93EE]
  ret

// int choose(battle, actor, arte_id, assign). Physical slots 3/4/5 are skipped.
choose:
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi
  mov ebx, [ebp+#8]
  mov esi, [ebp+#12]
  mov edi, [ebp+#16]
  test ebx, ebx
  jz choose_no
  test esi, esi
  jz choose_no
  cmp byte ptr [ebx+0x93EC], #0
  jne choose_no
  cmp byte ptr [ebx+0x9108], #0
  jne choose_unison
choose_scan_start:
  xor ecx, ecx
choose_scan:
  mov eax, ecx
  call busy_addr
  cmp byte ptr [eax], #0
  je choose_next
  mov eax, ecx
  call slot_addr
  mov edx, eax
  cmp [edx+#444], esi
  je choose_no
  movzx eax, word ptr [edx+#454]
  cmp dword ptr [edx+#4], #0
  je choose_no
  cmp eax, #512
  jae choose_no
  cmp byte ptr [ALLOWED+eax], #0
  je choose_no
  cmp edi, #512
  jae choose_no
  cmp byte ptr [ALLOWED+edi], #0
  je choose_no
choose_next:
  inc ecx
  cmp ecx, #3
  jne choose_next_bound
  mov ecx, #6
choose_next_bound:
  cmp ecx, #10
  jb choose_scan
  movzx ecx, byte ptr [esi+0x1320]
  and ecx, #1
  call find_free
  cmp eax, -#1
  je choose_no
choose_store:
  cmp dword ptr [ebp+#20], #0
  je choose_done
  mov [esi+0x13AB0], al
choose_done:
  pop edi
  pop esi
  pop ebx
  pop ebp
  ret
choose_unison:
// Ordinary spells on either side use the ownership/overlap checks and expanded
// storage during Unison. Special/cinematic requests retain native routing.
  cmp edi, #512
  jae choose_unison_legacy
  cmp byte ptr [ALLOWED+edi], #0
  jne choose_scan_start
choose_unison_legacy:
  movzx eax, byte ptr [esi+0x13AB0]
  cmp eax, #2
  jb choose_store
  movzx eax, byte ptr [esi+0x1320]
  and eax, #1
  jmp choose_store
choose_no:
  mov eax, -#1
  jmp choose_done

// EBX = battle, ECX = side; returns free logical slot in EAX, or -1.
// Shared by final admission and coarse AI capacity so both honor both limits.
find_free:
  test ecx, ecx
  jnz free_enemy
  xor eax, eax
  cmp byte ptr [ebx+0x93EE], #0
  je free_done
  cmp byte ptr [ebx+0x9108], #0
  je free_party_extra
  mov eax, #1
  cmp byte ptr [ebx+0x93EF], #0
  je free_done
free_party_extra:
  cmp dword ptr [DATA+#60], 0x40000000
  jb free_none
  mov eax, #2
  cmp byte ptr [ebx+0x93F0], #0
  je free_done
  cmp dword ptr [DATA+#60], 0x40400000
  jb free_none
  cmp dword ptr [DATA+#56], #0
  jne free_none
  mov eax, #6
  cmp byte ptr [EXTRA_BUSY], #0
  je free_done
  cmp dword ptr [DATA+#60], 0x40800000
  jb free_none
  mov eax, #7
  cmp byte ptr [EXTRA_BUSY+#1], #0
  je free_done
  jmp free_none
free_enemy:
  mov eax, #1
  cmp byte ptr [ebx+0x93EF], #0
  je free_done
  cmp dword ptr [DATA+#64], 0x40000000
  jb free_none
  cmp dword ptr [DATA+#56], #0
  jne free_none
  mov eax, #8
  cmp byte ptr [EXTRA_BUSY+#2], #0
  je free_done
  cmp dword ptr [DATA+#64], 0x40400000
  jb free_none
  mov eax, #9
  cmp byte ptr [EXTRA_BUSY+#3], #0
  je free_done
free_none:
  mov eax, -#1
free_done:
  ret

// int capacity(battle, side): coarse AI test; choose() owns final admission.
capacity:
  push ebx
  mov ebx, [esp+#8]
  mov ecx, [esp+#12]
  and ecx, #1
  cmp byte ptr [ebx+ecx+0x93EE], #0
  je capacity_find
  mov eax, ecx
  call slot_addr
  cmp dword ptr [eax+#4], #0
  je capacity_full
  movzx edx, word ptr [eax+#454]
  cmp edx, #512
  jae capacity_full
  cmp byte ptr [ALLOWED+edx], #0
  je capacity_full
capacity_find:
  call find_free
  cmp eax, -#1
  sete al
  movzx eax, al
  pop ebx
  ret
capacity_full:
  mov eax, #1
  pop ebx
  ret

cast_ready:
  pushad
  movzx eax, word ptr [edi]
  push #1
  push eax
  push ebx
  push dword ptr [BC_GLOBAL]
  call choose
  add esp, #16
  cmp eax, -#1
  je cast_wait
  mov [esp+#24], eax
  mov eax, [BC_GLOBAL]
  mov [esp+#20], eax
  popad
  jmp TOS.exe+0x26baa
cast_wait:
  inc dword ptr [DATA+#24]
  popad
  jmp TOS.exe+0x27214

alternate_launch:
  pushad
  movsx eax, word ptr [ebp+#20]
  push #1
  push eax
  push edi
  push dword ptr [BC_GLOBAL]
  call choose
  add esp, #16
  cmp eax, -#1
  je alternate_wait
// Stock Unison path still checks occupancy before this alternate launch.
  mov edx, [BC_GLOBAL]
  cmp eax, #6
  jae alternate_extra_busy
  cmp byte ptr [edx+eax+0x93EE], #0
  jmp alternate_busy_done
alternate_extra_busy:
  cmp byte ptr [EXTRA_BUSY+eax-#6], #0
alternate_busy_done:
  jne alternate_wait
  mov [esp+#28], eax
  popad
  movsx ecx, word ptr [ebp+#20]
  push #0
  push #0
  push eax
  push ecx
  mov eax, edi
  call TOS.exe+0x6e050
  jmp TOS.exe+0x27987
alternate_wait:
  popad
  jmp TOS.exe+0x27d3f

direct_launch:
  mov eax, [ebx+#56]
  test al, #1
  jz direct_other
  pushad
  movsx eax, word ptr [ebx]
  push #1
  push eax
  push edi
  push dword ptr [BC_GLOBAL]
  call choose
  add esp, #16
  cmp eax, -#1
  je direct_wait
  mov [esp+#24], eax
  popad
  movzx eax, byte ptr [ebx+#88]
  push eax
  push #1
  push ecx
  movsx eax, word ptr [ebx]
  push eax
  mov eax, edi
  call TOS.exe+0x6e050
  add esp, #16
  jmp TOS.exe+0x3fc7a
direct_wait:
  popad
  xor al, al
  jmp TOS.exe+0x3f548
direct_other:
  jmp TOS.exe+0x3fc5c

can_use:
  pushad
  movsx eax, word ptr [ebp+#12]
  imul eax, eax, #96
  movzx eax, word ptr [eax+TOS.exe+0x4d84b0]
  push #0
  push eax
  push dword ptr [ebp+#8]
  push ebx
  call choose
  add esp, #16
  cmp eax, -#1
  je can_use_no
  popad
  jmp TOS.exe+0x3efb3
can_use_no:
  popad
  jmp TOS.exe+0x3ede9

ai_capacity:
  pushad
  push edx
  push esi
  call capacity
  add esp, #8
  test eax, eax
  popad
  jmp TOS.exe+0x33ccb

general_capacity:
  pushad
  push eax
  push edx
  call capacity
  add esp, #8
  test eax, eax
  popad
  jmp TOS.exe+0x28984

unison_a:
// An extra slot already assigned to this cast must survive subsequent
// Unison ticks. Skip the stock busy lookup/XOR, which only supports 0/1.
  mov al, [ebx+0x13AB0]
  cmp al, #2
  je unison_a_extra
  cmp al, #6
  je unison_a_extra
  cmp al, #7
  je unison_a_extra
  cmp byte ptr [ebx+0x13AB0], #2
  jb unison_a_read
  mov byte ptr [ebx+0x13AB0], #0
unison_a_read:
  mov al, [ebx+0x13AB0]
  jmp TOS.exe+0x2599c
unison_a_extra:
  jmp TOS.exe+0x259bf
unison_b:
  mov al, [ebx+0x13AB0]
  cmp al, #2
  je unison_b_extra
  cmp al, #6
  je unison_b_extra
  cmp al, #7
  je unison_b_extra
  cmp byte ptr [ebx+0x13AB0], #2
  jb unison_b_read
  mov byte ptr [ebx+0x13AB0], #0
unison_b_read:
  mov al, [ebx+0x13AB0]
  jmp TOS.exe+0x26646
unison_b_extra:
  jmp TOS.exe+0x26675

buffer_init:
  pushfd
  pushad
  push esi
  call prepare_battle
  add esp, #4
  popad
  popfd
  mov edx, BUFFER
  mov [esi+0x16F950], edx
  jmp TOS.exe+0x7a6d1

launch_stats:
  pushfd
  pushad
  mov ebx, ecx
  mov eax, edx
  call busy_addr
  mov byte ptr [eax], #1
  inc dword ptr [LAUNCH_COUNTS+edx*#4]
  mov [DATA+#32], edx
  mov [DATA+#36], esi
  mov eax, [esp+#28]
  mov [DATA+#40], eax
  mov [esi+0x13AB0], dl
  popad
  popfd
  jmp TOS.exe+0x6e2ae

cleanup_extra:
  pushfd
  pushad
// Called after the game's VFX purge and before its busy-flag reset.
  push #2
  call TOS.exe+0x6dee0
  add esp, #4
  push #6
  call TOS.exe+0x6dee0
  add esp, #4
  push #7
  call TOS.exe+0x6dee0
  add esp, #4
  push #8
  call TOS.exe+0x6dee0
  add esp, #4
  push #9
  call TOS.exe+0x6dee0
  add esp, #4
  mov dword ptr [EXTRA_BUSY], #0
  mov eax, [BC_GLOBAL]
  mov byte ptr [eax+0x93F0], #0
  lea edx, [eax+#78496]
  mov ecx, #12
cleanup_actors:
  cmp byte ptr [edx+0x13AB0], #2
  jb cleanup_next
  mov al, [edx+0x1320]
  and al, #1
  mov [edx+0x13AB0], al
  and byte ptr [edx+0x13AB1], 0xFE
cleanup_next:
  add edx, #80864
  loop cleanup_actors
  inc dword ptr [DATA+#20]
  popad
  popfd
  fldz
  mov word ptr [esi+0x93EE], #0
  jmp TOS.exe+0x61013


// Snapshot all four relocated attack variants immediately after resource load.
// int snapshot_defs(battle, slot); 256 bytes per slot, first 112 are descriptors.
snapshot_defs:
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi
  mov ebx, [ebp+#8]
  mov edx, [ebp+#12]
  xor eax, eax
  cmp edx, #10
  jae snapshot_done
  cmp edx, #3
  jb snapshot_valid
  cmp edx, #6
  jb snapshot_done
snapshot_valid:
  mov edi, edx
  shl edi, #8
  add edi, PRIVATE_DEFS
  mov dword ptr [edi+#120], #0
  mov eax, edx
  call slot_addr
  mov edx, eax
  xor eax, eax
  cmp dword ptr [edx+#4], #0
  je snapshot_done
  cmp dword ptr [edx+#444], #0
  je snapshot_done
  movzx ecx, word ptr [edx+#454]
  cmp ecx, #200
  jb snapshot_done
  cmp ecx, #512
  jae snapshot_done
  cmp byte ptr [ALLOWED+ecx], #0
  je snapshot_done
  mov [edi+#112], ecx
  mov eax, [edx+#444]
  mov [edi+#116], eax
  mov [edi+#120], ebx
  sub ecx, #200
  imul ecx, ecx, #112
  mov esi, [ebx+0x9A5C]
  add esi, ecx
  mov eax, edi
  mov ecx, #28
  cld
  rep movsd
snapshot_done:
  pop edi
  pop esi
  pop ebx
  pop ebp
  ret

// int resolve_defs(battle, script_state, stock_pointer)
// Only redirect known actor script states whose slot and snapshot agree.
resolve_defs:
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi
  mov ebx, [ebp+#8]
  mov esi, [ebp+#12]
  mov eax, [ebp+#16]
  mov edi, PRIVATE_DEFS
  xor ecx, ecx
resolve_scan:
  cmp [edi+#120], ebx
  jne resolve_next
  movzx edx, word ptr [esi+#212]
  cmp [edi+#112], edx
  jne resolve_next
  mov eax, ecx
  call slot_addr
  mov edx, eax
  cmp dword ptr [edx+#4], #0
  je resolve_next
  movzx eax, word ptr [edx+#454]
  cmp [edi+#112], eax
  jne resolve_next
  mov edx, [edx+#444]
  test edx, edx
  jz resolve_next
  cmp [edi+#116], edx
  jne resolve_next
  cmp [esi+#8], edx
  jne resolve_next
  add edx, #79496
  cmp esi, edx
  je resolve_found
  add edx, #248
  cmp esi, edx
  je resolve_found
resolve_next:
  inc ecx
  add edi, #256
  cmp ecx, #10
  jb resolve_scan
  mov eax, [ebp+#16]
  jmp resolve_done
resolve_found:
  mov eax, edi
resolve_done:
  pop edi
  pop esi
  pop ebx
  pop ebp
  ret

loaded_defs:
// Original call uses stack slot index and ECX actor owner.
  push dword ptr [esp+#4]
  call TOS.exe+0x6e380
  add esp, #4
  pushfd
  pushad
  mov eax, [esp+#40]
  push eax
  push dword ptr [BC_GLOBAL]
  call snapshot_defs
  add esp, #8
  popad
  popfd
  ret

script_defs:
  pushfd
  pushad
  push ecx
  push eax
  push dword ptr [BC_GLOBAL]
  call resolve_defs
  add esp, #12
  mov [esp+#24], eax
  popad
  popfd
  mov [eax+#24], ecx
  jmp TOS.exe+0x253b9


// Initialize at each native battle setup, or once during an idle live upgrade.
// Model records from a previous battle have been released through native teardown.
prepare_battle:
  push ebx
  push esi
  push edi
  mov ebx, [esp+#16]
  mov dword ptr [ebx+0x16F950], BUFFER
  mov dword ptr [DATA+#56], #0
  cmp dword ptr [ebx+0x15B27C], #0
  jne prepare_conflict
  cmp dword ptr [ebx+0x15B280], #0
  jne prepare_conflict
  cmp dword ptr [ebx+0x15B284], #0
  jne prepare_conflict
  cmp dword ptr [ebx+0x15B288], #0
  je prepare_clear
prepare_conflict:
  mov dword ptr [DATA+#56], #1
prepare_clear:
  mov edi, PRIVATE_DEFS
  xor eax, eax
  mov ecx, #640
  cld
  rep stosd
  mov dword ptr [EXTRA_BUSY], #0
  mov edi, PROJECTILES
  mov ecx, #10
  rep stosd
  mov edi, EXTRA_EFFECTS
  mov ecx, #8
  rep stosd
  lea esi, [ebx+0x9A4C]
  mov edi, PROJECTILES
  mov ecx, #3
  rep movsd
  mov edi, EXTRA_SLOTS+#0*EXTRA_SLOT_STRIDE
  mov ecx, 0xA320/#4
  rep stosd
  mov dword ptr [EXTRA_SLOTS+#0*EXTRA_SLOT_STRIDE], EXTRA_SLOTS+#0*EXTRA_SLOT_STRIDE+0xD000
  mov edi, EXTRA_SLOTS+#1*EXTRA_SLOT_STRIDE
  mov ecx, 0xA320/#4
  rep stosd
  mov dword ptr [EXTRA_SLOTS+#1*EXTRA_SLOT_STRIDE], EXTRA_SLOTS+#1*EXTRA_SLOT_STRIDE+0xD000
  mov edi, EXTRA_SLOTS+#2*EXTRA_SLOT_STRIDE
  mov ecx, 0xA320/#4
  rep stosd
  mov dword ptr [EXTRA_SLOTS+#2*EXTRA_SLOT_STRIDE], EXTRA_SLOTS+#2*EXTRA_SLOT_STRIDE+0xD000
  mov edi, EXTRA_SLOTS+#3*EXTRA_SLOT_STRIDE
  mov ecx, 0xA320/#4
  rep stosd
  mov dword ptr [EXTRA_SLOTS+#3*EXTRA_SLOT_STRIDE], EXTRA_SLOTS+#3*EXTRA_SLOT_STRIDE+0xD000
  inc dword ptr [DATA+#44]
  mov [DATA+#48], ebx
  mov eax, BUFFER
  pop edi
  pop esi
  pop ebx
  ret

// Native slot arithmetic expects a byte offset relative to the original BC base.
// Convert only logical slots 6–9; original slots retain their original storage.
slot_offset:
  cmp eax, #6
  jb slot_offset_native
  sub eax, #6
  shl eax, #19
  add eax, EXTRA_SLOTS
  sub eax, [BC_GLOBAL]
  sub eax, 0x15B310
  ret
slot_offset_native:
  imul eax, eax, 0xA320
  ret

// Map an already-computed native address in EBP. Preserve flags and all other regs.
map_busy:
  pushfd
  push eax
  mov eax, ebp
  sub eax, [BC_GLOBAL]
  sub eax, 0x93EE
  sub eax, #6
  cmp eax, #4
  jae map_busy_done
  lea ebp, [EXTRA_BUSY+eax]
map_busy_done:
  pop eax
  popfd
  ret
map_effect:
  pushfd
  push eax
  mov eax, ebp
  sub eax, [BC_GLOBAL]
  sub eax, 0x1571BC+#12*#4
  cmp eax, #16
  jae map_effect_done
  lea ebp, [EXTRA_EFFECTS+eax]
map_effect_done:
  pop eax
  popfd
  ret
map_model:
  pushfd
  push eax
  mov eax, ebp
  sub eax, [BC_GLOBAL]
  sub eax, 0x1571EC+#12*#4
  cmp eax, #16
  jae map_model_done
  lea ebp, [EXTRA_MODELS+eax]
map_model_done:
  pop eax
  popfd
  ret

// Keep original projectile table entries synchronized for native slots only.
projectile_write:
  mov [PROJECTILES+ecx*#4], eax
  pushfd
  cmp ecx, #3
  jae projectile_write_done
  mov [esi+ecx*#4+0x9A4C], eax
projectile_write_done:
  popfd
  jmp TOS.exe+0x6e7a3

// Texture ownership groups for new slots are distinct from existing game groups.
texture_tag_load:
  mov eax, [ebp-0x128]
  cmp eax, #6
  jb texture_tag_native
// Texture IDs 0x0D00000C/0D already belong to the shared battle atlas.
// Give each extra spell its own 256-ID range, separately from release tags.
  mov edx, eax
  sub edx, #6
  shl edx, #8
  add edx, 0x53520000
  add eax, 0x53510000
  jmp TOS.exe+0x6e4bc
texture_tag_native:
  add eax, #112
  jmp TOS.exe+0x6e4bc
texture_tag_release:
  movzx edx, byte ptr [ebp+#8]
  cmp edx, #6
  jb texture_release_native
  add edx, 0x53510000
  jmp TOS.exe+0x6dffd
texture_release_native:
  add edx, #112
  jmp TOS.exe+0x6dffd

// This entry is reached only from texture selector 6 (the caster's spell).
// Logical banks 12–15 become private renderer tokens 28–31. Direct selectors
// 12–15 still refer to the shared battle atlas. DX already holds the original
// bank's palette word, so no access beyond the native palette table is added.
texture_selector:
  cmp al, #12
  jb texture_selector_store
  cmp al, #15
  ja texture_selector_store
  add al, #16
texture_selector_store:
  mov [ebp-#2], al
  jmp TOS.exe+0x74510

// EDI: renderer token -> full texture resource ID; flags and other regs intact.
texture_id:
  pushfd
  cmp edi, #28
  jb texture_id_native
  cmp edi, #31
  jbe texture_id_private
texture_id_native:
  lea edi, [edi+0x0D000000]
  popfd
  ret
texture_id_private:
  sub edi, #28
  shl edi, #8
  add edi, 0x53520000
  popfd
  ret

// Preserve native handling of small bank indices and full resource IDs.
texture_bind:
  cmp edi, #28
  jb texture_bind_native
  cmp edi, #31
  jbe texture_bind_private
texture_bind_native:
  cmp edi, #27
  ja texture_bind_absolute
  jmp TOS.exe+0x7bc18
texture_bind_absolute:
  jmp TOS.exe+0x7bc28
texture_bind_private:
  call texture_id
  lea edi, [ebx+edi]
  jmp TOS.exe+0x7bc1f

// The particle draw path constructs its own resource ID after binding.
texture_draw:
  mov edi, eax
  call texture_id
  jmp TOS.exe+0x74f1b

teardown_extra:
  push dword ptr [esp+#4]
  call TOS.exe+0x6dee0
  add esp, #4
  pushfd
  pushad
  push #6
  call TOS.exe+0x6dee0
  add esp, #4
  push #7
  call TOS.exe+0x6dee0
  add esp, #4
  push #8
  call TOS.exe+0x6dee0
  add esp, #4
  push #9
  call TOS.exe+0x6dee0
  add esp, #4
  mov eax, [BC_GLOBAL]
  mov dword ptr [eax+0x15B27C], #0
  mov dword ptr [eax+0x15B280], #0
  mov dword ptr [eax+0x15B284], #0
  mov dword ptr [eax+0x15B288], #0
  mov dword ptr [EXTRA_BUSY], #0
  popad
  popfd
  ret

// Optional compatibility with the recognized pre-existing cast-order cave.
// Replaces only its busy comparison, via CALL; its queue logic is unchanged.
queue_busy_compat:
  push ebp
  lea ebp, [edx+edi+0x93EE]
  call map_busy
  cmp byte ptr [ebp], #0
  pop ebp
  ret

// BEGIN GENERATED NATIVE ROUTING — each original instruction is documented below.

// 0x40cadf: mov eax, [edi+edx*4+0x9a4c]
native_40CADF:
  mov eax, [PROJECTILES+edx*#4]
padding_1:
  nop #7-(padding_1-native_40CADF)

// 0x40cb5f: mov eax, [edi+edx*4+0x9a4c]
native_40CB5F:
  mov eax, [PROJECTILES+edx*#4]
padding_2:
  nop #7-(padding_2-native_40CB5F)

// 0x40cbf1: mov edx, [edi+eax*4+0x9a4c]
native_40CBF1:
  mov edx, [PROJECTILES+eax*#4]
padding_3:
  nop #7-(padding_3-native_40CBF1)

// 0x40cc78: mov edx, [edi+eax*4+0x9a4c]
native_40CC78:
  mov edx, [PROJECTILES+eax*#4]
padding_4:
  nop #7-(padding_4-native_40CC78)

// 0x40d277: mov eax, [edi+edx*4+0x9a4c]
native_40D277:
  mov eax, [PROJECTILES+edx*#4]
padding_5:
  nop #7-(padding_5-native_40D277)

// 0x40d2fe: mov edx, [edi+eax*4+0x9a4c]
native_40D2FE:
  mov edx, [PROJECTILES+eax*#4]
padding_6:
  nop #7-(padding_6-native_40D2FE)

// 0x40da17: mov eax, [edi+edx*4+0x9a4c]
native_40DA17:
  mov eax, [PROJECTILES+edx*#4]
padding_7:
  nop #7-(padding_7-native_40DA17)

// 0x40da9e: mov edx, [edi+eax*4+0x9a4c]
native_40DA9E:
  mov edx, [PROJECTILES+eax*#4]
padding_8:
  nop #7-(padding_8-native_40DA9E)

// 0x40db25: mov edx, [edi+eax*4+0x9a4c]
native_40DB25:
  mov edx, [PROJECTILES+eax*#4]
padding_9:
  nop #7-(padding_9-native_40DB25)

// 0x40dbac: mov edx, [edi+eax*4+0x9a4c]
native_40DBAC:
  mov edx, [PROJECTILES+eax*#4]
padding_10:
  nop #7-(padding_10-native_40DBAC)

// 0x40dc33: mov edx, [edi+eax*4+0x9a4c]
native_40DC33:
  mov edx, [PROJECTILES+eax*#4]
padding_11:
  nop #7-(padding_11-native_40DC33)

// 0x40e390: mov edx, [edi+eax*4+0x9a4c]
native_40E390:
  mov edx, [PROJECTILES+eax*#4]
padding_12:
  nop #7-(padding_12-native_40E390)

// 0x40e410: mov eax, [edi+edx*4+0x9a4c]
native_40E410:
  mov eax, [PROJECTILES+edx*#4]
padding_13:
  nop #7-(padding_13-native_40E410)

// 0x40e4af: mov eax, [edi+eax*4+0x9a4c]
native_40E4AF:
  mov eax, [PROJECTILES+eax*#4]
padding_14:
  nop #7-(padding_14-native_40E4AF)

// 0x40e545: mov eax, [edi+eax*4+0x9a4c]
native_40E545:
  mov eax, [PROJECTILES+eax*#4]
padding_15:
  nop #7-(padding_15-native_40E545)

// 0x40ee25: mov edx, [edi+eax*4+0x9a4c]
native_40EE25:
  mov edx, [PROJECTILES+eax*#4]
padding_16:
  nop #7-(padding_16-native_40EE25)

// 0x40eea5: mov eax, [edi+edx*4+0x9a4c]
native_40EEA5:
  mov eax, [PROJECTILES+edx*#4]
padding_17:
  nop #7-(padding_17-native_40EEA5)

// 0x40ef44: mov eax, [edi+eax*4+0x9a4c]
native_40EF44:
  mov eax, [PROJECTILES+eax*#4]
padding_18:
  nop #7-(padding_18-native_40EF44)

// 0x40efda: mov eax, [edi+eax*4+0x9a4c]
native_40EFDA:
  mov eax, [PROJECTILES+eax*#4]
padding_19:
  nop #7-(padding_19-native_40EFDA)

// 0x40f632: mov edx, [edi+eax*4+0x9a4c]
native_40F632:
  mov edx, [PROJECTILES+eax*#4]
padding_20:
  nop #7-(padding_20-native_40F632)

// 0x40f6b6: mov edx, [edi+eax*4+0x9a4c]
native_40F6B6:
  mov edx, [PROJECTILES+eax*#4]
padding_21:
  nop #7-(padding_21-native_40F6B6)

// 0x40fdeb: mov ecx, [edi+eax*4+0x9a4c]
native_40FDEB:
  mov ecx, [PROJECTILES+eax*#4]
padding_22:
  nop #7-(padding_22-native_40FDEB)

// 0x40ff74: mov ecx, [edi+eax*4+0x9a4c]
native_40FF74:
  mov ecx, [PROJECTILES+eax*#4]
padding_23:
  nop #7-(padding_23-native_40FF74)

// 0x40fff5: mov ecx, [edi+eax*4+0x9a4c]
native_40FFF5:
  mov ecx, [PROJECTILES+eax*#4]
padding_24:
  nop #7-(padding_24-native_40FFF5)

// 0x41007d: mov eax, [edi+ecx*4+0x9a4c]
native_41007D:
  mov eax, [PROJECTILES+ecx*#4]
padding_25:
  nop #7-(padding_25-native_41007D)

// 0x41057d: mov esi, [esi+eax*4+0x9a4c]
native_41057D:
  mov esi, [PROJECTILES+eax*#4]
padding_26:
  nop #7-(padding_26-native_41057D)

// 0x4109ed: mov eax, [edx+eax*4+0x9a4c]
native_4109ED:
  mov eax, [PROJECTILES+eax*#4]
padding_27:
  nop #7-(padding_27-native_4109ED)

// 0x410a3a: mov edx, [eax+edx*4+0x9a4c]
native_410A3A:
  mov edx, [PROJECTILES+edx*#4]
padding_28:
  nop #7-(padding_28-native_410A3A)

// 0x410b86: mov edx, [eax+edx*4+0x9a4c]
native_410B86:
  mov edx, [PROJECTILES+edx*#4]
padding_29:
  nop #7-(padding_29-native_410B86)

// 0x410bfd: mov eax, [ecx+eax*4+0x9a4c]
native_410BFD:
  mov eax, [PROJECTILES+eax*#4]
padding_30:
  nop #7-(padding_30-native_410BFD)

// 0x410d4d: mov ecx, [ecx+eax*4+0x9a4c]
native_410D4D:
  mov ecx, [PROJECTILES+eax*#4]
padding_31:
  nop #7-(padding_31-native_410D4D)

// 0x410dbd: mov edx, [eax+edx*4+0x9a4c]
native_410DBD:
  mov edx, [PROJECTILES+edx*#4]
padding_32:
  nop #7-(padding_32-native_410DBD)

// 0x4110ed: mov esi, [esi+eax*4+0x9a4c]
native_4110ED:
  mov esi, [PROJECTILES+eax*#4]
padding_33:
  nop #7-(padding_33-native_4110ED)

// 0x41141d: mov eax, [ecx+eax*4+0x9a4c]
native_41141D:
  mov eax, [PROJECTILES+eax*#4]
padding_34:
  nop #7-(padding_34-native_41141D)

// 0x411489: mov ecx, [ecx+eax*4+0x9a4c]
native_411489:
  mov ecx, [PROJECTILES+eax*#4]
padding_35:
  nop #7-(padding_35-native_411489)

// 0x4114fc: mov edx, [eax+edx*4+0x9a4c]
native_4114FC:
  mov edx, [PROJECTILES+edx*#4]
padding_36:
  nop #7-(padding_36-native_4114FC)

// 0x41163d: mov esi, [esi+eax*4+0x9a4c]
native_41163D:
  mov esi, [PROJECTILES+eax*#4]
padding_37:
  nop #7-(padding_37-native_41163D)

// 0x41177d: mov eax, [ecx+eax*4+0x9a4c]
native_41177D:
  mov eax, [PROJECTILES+eax*#4]
padding_38:
  nop #7-(padding_38-native_41177D)

// 0x4117fb: mov edx, [ecx+eax*4+0x9a4c]
native_4117FB:
  mov edx, [PROJECTILES+eax*#4]
padding_39:
  nop #7-(padding_39-native_4117FB)

// 0x411a06: mov edx, [eax+edx*4+0x9a4c]
native_411A06:
  mov edx, [PROJECTILES+edx*#4]
padding_40:
  nop #7-(padding_40-native_411A06)

// 0x411bc9: mov eax, [ecx+eax*4+0x9a4c]
native_411BC9:
  mov eax, [PROJECTILES+eax*#4]
padding_41:
  nop #7-(padding_41-native_411BC9)

// 0x411d2d: mov eax, [ecx+eax*4+0x9a4c]
native_411D2D:
  mov eax, [PROJECTILES+eax*#4]
padding_42:
  nop #7-(padding_42-native_411D2D)

// 0x411d96: mov edx, [ecx+eax*4+0x9a4c]
native_411D96:
  mov edx, [PROJECTILES+eax*#4]
padding_43:
  nop #7-(padding_43-native_411D96)

// 0x412235: mov ecx, [edx+ecx*4+0x9a4c]
native_412235:
  mov ecx, [PROJECTILES+ecx*#4]
padding_44:
  nop #7-(padding_44-native_412235)

// 0x41247d: mov esi, [esi+eax*4+0x9a4c]
native_41247D:
  mov esi, [PROJECTILES+eax*#4]
padding_45:
  nop #7-(padding_45-native_41247D)

// 0x4125bd: mov esi, [esi+eax*4+0x9a4c]
native_4125BD:
  mov esi, [PROJECTILES+eax*#4]
padding_46:
  nop #7-(padding_46-native_4125BD)

// 0x41275d: mov esi, [esi+eax*4+0x9a4c]
native_41275D:
  mov esi, [PROJECTILES+eax*#4]
padding_47:
  nop #7-(padding_47-native_41275D)

// 0x4129e3: mov ecx, [eax+edx*4+0x9a4c]
native_4129E3:
  mov ecx, [PROJECTILES+edx*#4]
padding_48:
  nop #7-(padding_48-native_4129E3)

// 0x412b2d: mov esi, [esi+eax*4+0x9a4c]
native_412B2D:
  mov esi, [PROJECTILES+eax*#4]
padding_49:
  nop #7-(padding_49-native_412B2D)

// 0x412e31: mov ecx, [eax+edx*4+0x9a4c]
native_412E31:
  mov ecx, [PROJECTILES+edx*#4]
padding_50:
  nop #7-(padding_50-native_412E31)

// 0x412f0d: mov ecx, [eax+edx*4+0x9a4c]
native_412F0D:
  mov ecx, [PROJECTILES+edx*#4]
padding_51:
  nop #7-(padding_51-native_412F0D)

// 0x41305a: mov ecx, [edx+ecx*4+0x9a4c]
native_41305A:
  mov ecx, [PROJECTILES+ecx*#4]
padding_52:
  nop #7-(padding_52-native_41305A)

// 0x4130dd: mov eax, [eax+ecx*4+0x9a4c]
native_4130DD:
  mov eax, [PROJECTILES+ecx*#4]
padding_53:
  nop #7-(padding_53-native_4130DD)

// 0x413487: mov ecx, [ecx+eax*4+0x9a4c]
native_413487:
  mov ecx, [PROJECTILES+eax*#4]
padding_54:
  nop #7-(padding_54-native_413487)

// 0x413642: mov ecx, [ecx+eax*4+0x9a4c]
native_413642:
  mov ecx, [PROJECTILES+eax*#4]
padding_55:
  nop #7-(padding_55-native_413642)

// 0x413a40: mov ecx, [ecx+eax*4+0x9a4c]
native_413A40:
  mov ecx, [PROJECTILES+eax*#4]
padding_56:
  nop #7-(padding_56-native_413A40)

// 0x415b1d: mov ecx, [ecx+eax*4+0x9a4c]
native_415B1D:
  mov ecx, [PROJECTILES+eax*#4]
padding_57:
  nop #7-(padding_57-native_415B1D)

// 0x415b91: mov ecx, [eax+edx*4+0x9a4c]
native_415B91:
  mov ecx, [PROJECTILES+edx*#4]
padding_58:
  nop #7-(padding_58-native_415B91)

// 0x415ead: mov ecx, [ecx+eax*4+0x9a4c]
native_415EAD:
  mov ecx, [PROJECTILES+eax*#4]
padding_59:
  nop #7-(padding_59-native_415EAD)

// 0x4162b4: mov ecx, [ecx+eax*4+0x9a4c]
native_4162B4:
  mov ecx, [PROJECTILES+eax*#4]
padding_60:
  nop #7-(padding_60-native_4162B4)

// 0x4163cd: mov ecx, [eax+edx*4+0x9a4c]
native_4163CD:
  mov ecx, [PROJECTILES+edx*#4]
padding_61:
  nop #7-(padding_61-native_4163CD)

// 0x4178f5: mov eax, [edi+edx*4+0x9a4c]
native_4178F5:
  mov eax, [PROJECTILES+edx*#4]
padding_62:
  nop #7-(padding_62-native_4178F5)

// 0x417f74: mov eax, [edx+eax*4+0x9a4c]
native_417F74:
  mov eax, [PROJECTILES+eax*#4]
padding_63:
  nop #7-(padding_63-native_417F74)

// 0x4186a2: mov ecx, [ecx+eax*4+0x9a4c]
native_4186A2:
  mov ecx, [PROJECTILES+eax*#4]
padding_64:
  nop #7-(padding_64-native_4186A2)

// 0x41897f: mov edx, [eax+edx*4+0x9a4c]
native_41897F:
  mov edx, [PROJECTILES+edx*#4]
padding_65:
  nop #7-(padding_65-native_41897F)

// 0x418a05: mov edx, [edx+eax*4+0x9a4c]
native_418A05:
  mov edx, [PROJECTILES+eax*#4]
padding_66:
  nop #7-(padding_66-native_418A05)

// 0x41907d: mov ecx, [ecx+eax*4+0x9a4c]
native_41907D:
  mov ecx, [PROJECTILES+eax*#4]
padding_67:
  nop #7-(padding_67-native_41907D)

// 0x4190eb: mov ecx, [eax+edx*4+0x9a4c]
native_4190EB:
  mov ecx, [PROJECTILES+edx*#4]
padding_68:
  nop #7-(padding_68-native_4190EB)

// 0x419167: mov ecx, [ecx+eax*4+0x9a4c]
native_419167:
  mov ecx, [PROJECTILES+eax*#4]
padding_69:
  nop #7-(padding_69-native_419167)

// 0x41a283: mov ecx, [ebx+eax*4+0x9a4c]
native_41A283:
  mov ecx, [PROJECTILES+eax*#4]
padding_70:
  nop #7-(padding_70-native_41A283)

// 0x41a623: mov ecx, [edi+eax*4+0x9a4c]
native_41A623:
  mov ecx, [PROJECTILES+eax*#4]
padding_71:
  nop #7-(padding_71-native_41A623)

// 0x41a694: mov ecx, [edi+edx*4+0x9a4c]
native_41A694:
  mov ecx, [PROJECTILES+edx*#4]
padding_72:
  nop #7-(padding_72-native_41A694)

// 0x41a70e: mov ecx, [edi+eax*4+0x9a4c]
native_41A70E:
  mov ecx, [PROJECTILES+eax*#4]
padding_73:
  nop #7-(padding_73-native_41A70E)

// 0x41a787: mov ecx, [edi+eax*4+0x9a4c]
native_41A787:
  mov ecx, [PROJECTILES+eax*#4]
padding_74:
  nop #7-(padding_74-native_41A787)

// 0x41a7fd: mov ecx, [edi+eax*4+0x9a4c]
native_41A7FD:
  mov ecx, [PROJECTILES+eax*#4]
padding_75:
  nop #7-(padding_75-native_41A7FD)

// 0x41aa41: mov edx, [eax+edx*4+0x9a4c]
native_41AA41:
  mov edx, [PROJECTILES+edx*#4]
padding_76:
  nop #7-(padding_76-native_41AA41)

// 0x41b133: mov ecx, [ecx+eax*4+0x9a4c]
native_41B133:
  mov ecx, [PROJECTILES+eax*#4]
padding_77:
  nop #7-(padding_77-native_41B133)

// 0x41b7e3: mov ecx, [eax+edx*4+0x9a4c]
native_41B7E3:
  mov ecx, [PROJECTILES+edx*#4]
padding_78:
  nop #7-(padding_78-native_41B7E3)

// 0x41bd6c: mov ecx, [edx+ecx*4+0x9a4c]
native_41BD6C:
  mov ecx, [PROJECTILES+ecx*#4]
padding_79:
  nop #7-(padding_79-native_41BD6C)

// 0x41be17: mov ecx, [ecx+eax*4+0x9a4c]
native_41BE17:
  mov ecx, [PROJECTILES+eax*#4]
padding_80:
  nop #7-(padding_80-native_41BE17)

// 0x41be95: mov ecx, [ecx+eax*4+0x9a4c]
native_41BE95:
  mov ecx, [PROJECTILES+eax*#4]
padding_81:
  nop #7-(padding_81-native_41BE95)

// 0x41c2fb: mov edx, [edx+ecx*4+0x9a4c]
native_41C2FB:
  mov edx, [PROJECTILES+ecx*#4]
padding_82:
  nop #7-(padding_82-native_41C2FB)

// 0x41c371: mov edx, [edx+eax*4+0x9a4c]
native_41C371:
  mov edx, [PROJECTILES+eax*#4]
padding_83:
  nop #7-(padding_83-native_41C371)

// 0x41c8ce: mov ecx, [edx+ecx*4+0x9a4c]
native_41C8CE:
  mov ecx, [PROJECTILES+ecx*#4]
padding_84:
  nop #7-(padding_84-native_41C8CE)

// 0x41c97a: mov ecx, [ecx+eax*4+0x9a4c]
native_41C97A:
  mov ecx, [PROJECTILES+eax*#4]
padding_85:
  nop #7-(padding_85-native_41C97A)

// 0x41ca2c: mov ecx, [ecx+eax*4+0x9a4c]
native_41CA2C:
  mov ecx, [PROJECTILES+eax*#4]
padding_86:
  nop #7-(padding_86-native_41CA2C)

// 0x41cadd: mov ecx, [ecx+eax*4+0x9a4c]
native_41CADD:
  mov ecx, [PROJECTILES+eax*#4]
padding_87:
  nop #7-(padding_87-native_41CADD)

// 0x41cf64: mov edx, [edx+ecx*4+0x9a4c]
native_41CF64:
  mov edx, [PROJECTILES+ecx*#4]
padding_88:
  nop #7-(padding_88-native_41CF64)

// 0x41d62d: mov ecx, [eax+edx*4+0x9a4c]
native_41D62D:
  mov ecx, [PROJECTILES+edx*#4]
padding_89:
  nop #7-(padding_89-native_41D62D)

// 0x41db3b: mov ecx, [eax+ecx*4+0x9a4c]
native_41DB3B:
  mov ecx, [PROJECTILES+ecx*#4]
padding_90:
  nop #7-(padding_90-native_41DB3B)

// 0x41e1a3: mov ecx, [ecx+eax*4+0x9a4c]
native_41E1A3:
  mov ecx, [PROJECTILES+eax*#4]
padding_91:
  nop #7-(padding_91-native_41E1A3)

// 0x41e6a8: mov ecx, [eax+ecx*4+0x9a4c]
native_41E6A8:
  mov ecx, [PROJECTILES+ecx*#4]
padding_92:
  nop #7-(padding_92-native_41E6A8)

// 0x41f07b: mov ecx, [edi+edx*4+0x9a4c]
native_41F07B:
  mov ecx, [PROJECTILES+edx*#4]
padding_93:
  nop #7-(padding_93-native_41F07B)

// 0x420162: mov ecx, [esi+eax*4+0x9a4c]
native_420162:
  mov ecx, [PROJECTILES+eax*#4]
padding_94:
  nop #7-(padding_94-native_420162)

// 0x4204b7: mov edx, [edx+ecx*4+0x9a4c]
native_4204B7:
  mov edx, [PROJECTILES+ecx*#4]
padding_95:
  nop #7-(padding_95-native_4204B7)

// 0x4207fa: mov edx, [edx+ecx*4+0x9a4c]
native_4207FA:
  mov edx, [PROJECTILES+ecx*#4]
padding_96:
  nop #7-(padding_96-native_4207FA)

// 0x420da7: mov edx, [edx+ecx*4+0x9a4c]
native_420DA7:
  mov edx, [PROJECTILES+ecx*#4]
padding_97:
  nop #7-(padding_97-native_420DA7)

// 0x4210cd: mov edx, [edx+eax*4+0x9a4c]
native_4210CD:
  mov edx, [PROJECTILES+eax*#4]
padding_98:
  nop #7-(padding_98-native_4210CD)

// 0x4211a2: mov edx, [eax+edx*4+0x9a4c]
native_4211A2:
  mov edx, [PROJECTILES+edx*#4]
padding_99:
  nop #7-(padding_99-native_4211A2)

// 0x42157c: mov edx, [eax+edx*4+0x9a4c]
native_42157C:
  mov edx, [PROJECTILES+edx*#4]
padding_100:
  nop #7-(padding_100-native_42157C)

// 0x421b23: mov edx, [eax+edx*4+0x9a4c]
native_421B23:
  mov edx, [PROJECTILES+edx*#4]
padding_101:
  nop #7-(padding_101-native_421B23)

// 0x421fba: mov edx, [eax+edx*4+0x9a4c]
native_421FBA:
  mov edx, [PROJECTILES+edx*#4]
padding_102:
  nop #7-(padding_102-native_421FBA)

// 0x4222d7: mov edx, [edx+ecx*4+0x9a4c]
native_4222D7:
  mov edx, [PROJECTILES+ecx*#4]
padding_103:
  nop #7-(padding_103-native_4222D7)

// 0x422516: mov esi, [esi+edx*4+0x9a4c]
native_422516:
  mov esi, [PROJECTILES+edx*#4]
padding_104:
  nop #7-(padding_104-native_422516)

// 0x42283e: mov edx, [edx+ecx*4+0x9a4c]
native_42283E:
  mov edx, [PROJECTILES+ecx*#4]
padding_105:
  nop #7-(padding_105-native_42283E)

// 0x4228b0: mov edx, [edx+ecx*4+0x9a4c]
native_4228B0:
  mov edx, [PROJECTILES+ecx*#4]
padding_106:
  nop #7-(padding_106-native_4228B0)

// 0x422eaa: mov edx, [edx+ecx*4+0x9a4c]
native_422EAA:
  mov edx, [PROJECTILES+ecx*#4]
padding_107:
  nop #7-(padding_107-native_422EAA)

// 0x42361f: mov edx, [eax+edx*4+0x9a4c]
native_42361F:
  mov edx, [PROJECTILES+edx*#4]
padding_108:
  nop #7-(padding_108-native_42361F)

// 0x42377b: mov edx, [eax+edx*4+0x9a4c]
native_42377B:
  mov edx, [PROJECTILES+edx*#4]
padding_109:
  nop #7-(padding_109-native_42377B)

// 0x423ad7: mov edx, [edx+ecx*4+0x9a4c]
native_423AD7:
  mov edx, [PROJECTILES+ecx*#4]
padding_110:
  nop #7-(padding_110-native_423AD7)

// 0x423da1: mov edx, [edi+eax*4+0x9a4c]
native_423DA1:
  mov edx, [PROJECTILES+eax*#4]
padding_111:
  nop #7-(padding_111-native_423DA1)

// 0x423e1f: mov edi, [edi+edx*4+0x9a4c]
native_423E1F:
  mov edi, [PROJECTILES+edx*#4]
padding_112:
  nop #7-(padding_112-native_423E1F)

// 0x4243bf: mov edx, [edi+edx*4+0x9a4c]
native_4243BF:
  mov edx, [PROJECTILES+edx*#4]
padding_113:
  nop #7-(padding_113-native_4243BF)

// 0x4245e1: mov edx, [eax+edx*4+0x9a4c]
native_4245E1:
  mov edx, [PROJECTILES+edx*#4]
padding_114:
  nop #7-(padding_114-native_4245E1)

// 0x424a0d: mov edx, [eax+edx*4+0x9a4c]
native_424A0D:
  mov edx, [PROJECTILES+edx*#4]
padding_115:
  nop #7-(padding_115-native_424A0D)

// 0x425043: mov ecx, [ecx+eax*4+0x9a4c]
native_425043:
  mov ecx, [PROJECTILES+eax*#4]
padding_116:
  nop #7-(padding_116-native_425043)

// 0x4250c1: mov ecx, [eax+edx*4+0x9a4c]
native_4250C1:
  mov ecx, [PROJECTILES+edx*#4]
padding_117:
  nop #7-(padding_117-native_4250C1)

// 0x425157: mov edx, [ecx+eax*4+0x9a4c]
native_425157:
  mov edx, [PROJECTILES+eax*#4]
padding_118:
  nop #7-(padding_118-native_425157)

// 0x42524b: mov edx, [ecx+eax*4+0x9a4c]
native_42524B:
  mov edx, [PROJECTILES+eax*#4]
padding_119:
  nop #7-(padding_119-native_42524B)

// 0x40931f: mov ebx, [ecx+0x9a54]
native_40931F:
  mov ebx, [PROJECTILES+#8]
padding_120:
  nop #6-(padding_120-native_40931F)

// 0x40c5eb: imul ecx, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_40C5EB:
  pushfd
  pushad
  mov eax, ecx
  call slot_offset
  mov [esp+#24], eax
  popad
  popfd
  jmp TOS.exe+0xc5f1

// 0x40de3b: imul ecx, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_40DE3B:
  pushfd
  pushad
  mov eax, ecx
  call slot_offset
  mov [esp+#24], eax
  popad
  popfd
  jmp TOS.exe+0xde41

// 0x40e8bb: imul ecx, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_40E8BB:
  pushfd
  pushad
  mov eax, ecx
  call slot_offset
  mov [esp+#24], eax
  popad
  popfd
  jmp TOS.exe+0xe8c1

// 0x40f19a: imul eax, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_40F19A:
  pushfd
  pushad
  mov eax, eax
  call slot_offset
  mov [esp+#28], eax
  popad
  popfd
  jmp TOS.exe+0xf1a0

// 0x40f7e3: imul eax, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_40F7E3:
  pushfd
  pushad
  mov eax, eax
  call slot_offset
  mov [esp+#28], eax
  popad
  popfd
  jmp TOS.exe+0xf7e9

// 0x41a337: imul eax, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_41A337:
  pushfd
  pushad
  mov eax, eax
  call slot_offset
  mov [esp+#28], eax
  popad
  popfd
  jmp TOS.exe+0x1a33d

// 0x4282ca: imul ecx, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_4282CA:
  pushfd
  pushad
  mov eax, ecx
  call slot_offset
  mov [esp+#24], eax
  popad
  popfd
  jmp TOS.exe+0x282d0

// 0x46def0: imul eax, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_46DEF0:
  pushfd
  pushad
  mov eax, eax
  call slot_offset
  mov [esp+#28], eax
  popad
  popfd
  jmp TOS.exe+0x6def6

// 0x46e063: imul edx, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_46E063:
  pushfd
  pushad
  mov eax, edx
  call slot_offset
  mov [esp+#20], eax
  popad
  popfd
  jmp TOS.exe+0x6e069

// 0x46e3c6: imul eax, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_46E3C6:
  pushfd
  pushad
  mov eax, eax
  call slot_offset
  mov [esp+#28], eax
  popad
  popfd
  jmp TOS.exe+0x6e3cc

// 0x46ea41: imul ecx, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_46EA41:
  pushfd
  pushad
  mov eax, ecx
  call slot_offset
  mov [esp+#24], eax
  popad
  popfd
  jmp TOS.exe+0x6ea47

// 0x46ea9a: imul ecx, 0x0a320; preserve native arithmetic for slots 0/1/2.
native_46EA9A:
  pushfd
  pushad
  mov eax, ecx
  call slot_offset
  mov [esp+#24], eax
  popad
  popfd
  jmp TOS.exe+0x6eaa0

// 0x451b5a: mov ecx, [esi+ecx*4+0x1571bc]; original banks/slots retain native addresses.
native_451B5A:
  push ebp
  lea ebp, [esi+ecx*#4+0x1571bc]
  call map_effect
  mov ecx, [ebp]
  pop ebp
  jmp TOS.exe+0x51b61

// 0x46e489: mov [edi+ecx*4+0x1571bc], eax; original banks/slots retain native addresses.
native_46E489:
  push ebp
  lea ebp, [edi+ecx*#4+0x1571bc]
  call map_effect
  mov [ebp], eax
  pop ebp
  jmp TOS.exe+0x6e490

// 0x41abfb: mov ecx, [edx+ecx*4+0x1571ec]; original banks/slots retain native addresses.
native_41ABFB:
  push ebp
  lea ebp, [edx+ecx*#4+0x1571ec]
  call map_model
  mov ecx, [ebp]
  pop ebp
  jmp TOS.exe+0x1ac02

// 0x456b5c: add esi, [eax+edx*4+0x1571ec]; original banks/slots retain native addresses.
native_456B5C:
  push ebp
  lea ebp, [eax+edx*#4+0x1571ec]
  call map_model
  add esi, [ebp]
  pop ebp
  jmp TOS.exe+0x56b63

// 0x457ec8: add ecx, [edi+eax*4+0x1571ec]; original banks/slots retain native addresses.
native_457EC8:
  push ebp
  lea ebp, [edi+eax*#4+0x1571ec]
  call map_model
  add ecx, [ebp]
  pop ebp
  jmp TOS.exe+0x57ecf

// 0x46e9c6: mov [ecx+eax*4+0x1571ec], edx; original banks/slots retain native addresses.
native_46E9C6:
  push ebp
  lea ebp, [ecx+eax*#4+0x1571ec]
  call map_model
  mov [ebp], edx
  pop ebp
  jmp TOS.exe+0x6e9cd

// 0x426baa: cmp byte ptr [ecx+edx+0x93ee], 0; original banks/slots retain native addresses.
native_426BAA:
  push ebp
  lea ebp, [ecx+edx+0x93ee]
  call map_busy
  cmp byte ptr [ebp], #0
  pop ebp
  jmp TOS.exe+0x26bb2

// The actor's previous slot is not its next cast's reservation. Let chanting
// progress when choose() can admit this spell into ANY configured slot. Do not
// assign it here: cast_ready rechecks admission immediately before launching.
// Preserve the native comparison contract: ZF means capacity is available.
native_42723D:
  pushad
  mov eax, [ebx+0xC]
  movzx eax, word ptr [eax]
  push #0
  push eax
  push ebx
  push edi
  call choose
  add esp, #16
  cmp eax, -#1
  sete al
  test al, al
  popad
  jmp TOS.exe+0x27245

// 0x428118: mov byte ptr [ecx+edx+0x93ee], 0; original banks/slots retain native addresses.
native_428118:
  push ebp
  lea ebp, [ecx+edx+0x93ee]
  call map_busy
  mov byte ptr [ebp], #0
  pop ebp
  jmp TOS.exe+0x28120

// 0x46e481: cmp dl, 0x0c
native_46E481:
  cmp dl, #16
padding_121:
  nop #3-(padding_121-native_46E481)

code_end:


// cast_ready
