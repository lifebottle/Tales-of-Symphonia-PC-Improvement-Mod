// Additional spell slots and concurrent Unison Mystic Artes.
// Maintained CE-style source; MA fixes share this allocator and its lifecycle.
// Native helpers and writable arena remain separately allocated.
[ENABLE]

// Helpers
alloc(mem_spell_code,0x2000)
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
choose_find:
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
// During Unison, all party MAs and summons may share the expanded spell slots.
// Empty native reservations are not loaded attacks. Loaded slots retain owner,
// whitelist, capacity and resource-bank checks.
choose_unison:
  cmp edi, #512
  jae choose_unison_legacy
  cmp byte ptr [mm_allowed+edi], #0
  je choose_unison_legacy
  xor ecx, ecx
choose_unison_scan:
  mov eax, ecx
  call busy_addr
  cmp byte ptr [eax], #0
  je choose_unison_next
  mov eax, ecx
  call slot_addr
  cmp dword ptr [eax+#4], #0
  je choose_unison_next
  cmp dword ptr [eax+#444], esi
  je choose_no
  movzx eax, word ptr [eax+#454]
  cmp eax, #512
  jae choose_no
  cmp byte ptr [mm_allowed+eax], #0
  je choose_no
choose_unison_next:
  inc ecx
  cmp ecx, #3
  jne choose_unison_bound
  mov ecx, #6
choose_unison_bound:
  cmp ecx, #10
  jb choose_unison_scan
  jmp choose_find

// Unsupported cinematic artes retain native routing, but must wait for every
// loaded slot to finish rather than overwriting another MA's resources.
choose_unison_legacy:
  xor ecx, ecx
choose_legacy_scan:
  mov eax, ecx
  call busy_addr
  cmp byte ptr [eax], #0
  je choose_legacy_next
  mov eax, ecx
  call slot_addr
  cmp dword ptr [eax+#4], #0
  jne choose_no
choose_legacy_next:
  inc ecx
  cmp ecx, #3
  jne choose_legacy_bound
  mov ecx, #6
choose_legacy_bound:
  cmp ecx, #10
  jb choose_legacy_scan
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
// Party slots are 0, 2, 6, 7. Slot 1 remains an enemy slot during Unison.
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
  pushfd
  pushad
  mov esi, ebx
  call mm_slot_header
  test eax, eax
  jz unison_a_unassigned
  popad
  popfd
  jmp unison_a_extra
unison_a_unassigned:
  popad
  popfd
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
  pushfd
  pushad
  mov esi, ebx
  call mm_slot_header
  test eax, eax
  jz unison_b_unassigned
  popad
  popfd
  jmp unison_b_extra
unison_b_unassigned:
  popad
  popfd
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
  cmp byte ptr [mm_allowed+ecx], #0
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

// Writable state
alloc(mem_arena,0x280000)
registersymbol(ARENA)
registersymbol(PARTY_SLOTS)
registersymbol(ENEMY_SLOTS)

mem_arena:
ARENA:
mem_arena+0x4000:
  db "SPL5"
  dd #5
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00
PARTY_SLOTS:
  dd (float)1
ENEMY_SLOTS:
  dd (float)1
mem_arena+0x4100:
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #1, #1, #1, #0, #1, #1, #1
  db #0, #1, #1, #1, #0, #1, #1, #1, #0, #1, #1, #1, #0, #1, #1, #1
  db #1, #0, #1, #1, #1, #1, #1, #1, #1, #1, #0, #0, #0, #1, #1, #0
  db #1, #1, #0, #1, #1, #0, #1, #1, #0, #1, #1, #1, #1, #1, #0, #1
  db #1, #1, #1, #1, #1, #1, #0, #0, #0, #1, #0, #1, #1, #1, #1, #1
  db #0, #0, #0, #0, #0, #0, #1, #0, #0, #0, #1, #1, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0

// Hooks
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

// Original-byte guards
assert(TOS.exe+0x9325,d9 5d 08 d9 45 08 83 ec)
assert(TOS.exe+0xc5f1,57 8d bc 01 10 b3 15 00)
assert(TOS.exe+0xcae6,8b 96 9c 38 01 00 89 45)
assert(TOS.exe+0xcb66,8b 96 9c 38 01 00 89 45)
assert(TOS.exe+0xcbf8,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xcc7f,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xd27e,8b 96 9c 38 01 00 89 45)
assert(TOS.exe+0xd305,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xda1e,8b 96 9c 38 01 00 89 45)
assert(TOS.exe+0xdaa5,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xdb2c,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xdbb3,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xdc3a,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xde41,57 8d bc 01 10 b3 15 00)
assert(TOS.exe+0xe397,89 55 f8 8b 96 9c 38 01)
assert(TOS.exe+0xe417,8b 96 9c 38 01 00 89 45)
assert(TOS.exe+0xe4b6,89 45 fc 8b c4 89 08 8b)
assert(TOS.exe+0xe54c,89 45 fc 8b c4 89 08 8b)
assert(TOS.exe+0xe8c1,57 8d bc 01 10 b3 15 00)
assert(TOS.exe+0xee2c,89 55 f8 8b 96 9c 38 01)
assert(TOS.exe+0xeeac,8b 96 9c 38 01 00 89 45)
assert(TOS.exe+0xef4b,89 45 fc 8b c4 89 08 8b)
assert(TOS.exe+0xefe1,89 45 fc 8b c4 89 08 8b)
assert(TOS.exe+0xf1a0,d8 8e d8 38 01 00 de c1)
assert(TOS.exe+0xf639,89 55 f8 8b 96 9c 38 01)
assert(TOS.exe+0xf6bd,89 55 fc 8b 96 9c 38 01)
assert(TOS.exe+0xf7e9,56 57 8b 7d 0c 8d 94 08)
assert(TOS.exe+0xfdf2,89 4c 24 2c 8b 4b 20 8b)
assert(TOS.exe+0xff7b,8b c4 89 10 8b 54 24 38)
assert(TOS.exe+0xfffc,89 4c 24 30 8b 4c 24 34)
assert(TOS.exe+0x10084,8b 4c 24 34 89 44 24 30)
assert(TOS.exe+0x10584,8d 41 20 8b cc 89 39 8b)
assert(TOS.exe+0x109f4,d9 5c 24 0c 8b 51 20 89)
assert(TOS.exe+0x10a41,d9 5c 24 0c 8d 41 20 8b)
assert(TOS.exe+0x10b8d,89 55 f8 8b 57 20 8b c4)
assert(TOS.exe+0x10c04,89 45 fc 8d 47 20 8b 38)
assert(TOS.exe+0x10d54,8b c4 89 10 8b 57 24 89)
assert(TOS.exe+0x10dc4,8d 47 20 8b 38 89 39 8b)
assert(TOS.exe+0x110f4,8d 41 20 8b cc 89 39 8b)
assert(TOS.exe+0x11424,8b cc 89 11 8b 57 24 89)
assert(TOS.exe+0x11490,8b c4 89 10 8b 57 24 89)
assert(TOS.exe+0x11503,8d 47 20 8b 38 89 39 8b)
assert(TOS.exe+0x11644,8d 41 20 8b cc 89 39 8b)
assert(TOS.exe+0x11784,8b cc 89 11 8b 57 24 89)
assert(TOS.exe+0x11802,8d 47 20 8b 38 8b cc 89)
assert(TOS.exe+0x11a0d,89 55 fc 8b 56 20 8b c4)
assert(TOS.exe+0x11bd0,8b cc 89 39 8b 7e 24 89)
assert(TOS.exe+0x11d34,8b cc 89 11 8b 57 24 89)
assert(TOS.exe+0x11d9d,8d 47 20 8b 38 8b cc 89)
assert(TOS.exe+0x1223c,8b 54 24 2c 8b c4 d9 5c)
assert(TOS.exe+0x12484,8d 41 20 8b cc 89 39 8b)
assert(TOS.exe+0x125c4,8d 41 20 8b cc 89 39 8b)
assert(TOS.exe+0x12764,8d 41 20 8b cc 89 39 8b)
assert(TOS.exe+0x129ea,8b 56 20 8b c4 89 10 8b)
assert(TOS.exe+0x12b34,8d 41 20 8b cc 89 39 8b)
assert(TOS.exe+0x12e38,8b 17 8b c4 89 10 8b 57)
assert(TOS.exe+0x12f14,8b 17 8b c4 89 10 8b 57)
assert(TOS.exe+0x13061,8b 50 20 89 4d f8 8b cc)
assert(TOS.exe+0x130e4,8b cc 89 39 8b 7d f0 89)
assert(TOS.exe+0x1348e,8b c4 89 10 8b 54 24 2c)
assert(TOS.exe+0x13649,8b c4 89 10 8b 54 24 2c)
assert(TOS.exe+0x13a47,8b 54 24 1c 8b c4 89 10)
assert(TOS.exe+0x15b24,8b c4 89 10 8b 97 3c 39)
assert(TOS.exe+0x15b98,8b 97 38 39 01 00 8b c4)
assert(TOS.exe+0x15eb4,8b 54 24 1c 8b c4 89 10)
assert(TOS.exe+0x162bb,d9 44 24 4c 8b 54 24 50)
assert(TOS.exe+0x163d4,8b 54 24 2c 8b c4 89 10)
assert(TOS.exe+0x178fc,8b 51 20 89 45 f4 8b c4)
assert(TOS.exe+0x17f7b,d9 45 cc 8b 91 9c 38 01)
assert(TOS.exe+0x186a9,8b c4 89 38 89 50 04 8b)
assert(TOS.exe+0x18986,d9 5c 24 0c 8b c4 89 30)
assert(TOS.exe+0x18a0c,8b c4 89 30 8b 74 24 2c)
assert(TOS.exe+0x19084,8b c4 89 10 8b 57 24 89)
assert(TOS.exe+0x190f2,8b 57 20 8b c4 89 10 8b)
assert(TOS.exe+0x1916e,8b c4 89 10 8b 57 24 89)
assert(TOS.exe+0x1a28a,8b c4 89 38 8b 7c 24 48)
assert(TOS.exe+0x1a33d,8d 94 08 10 b3 15 00 57)
assert(TOS.exe+0x1a62a,8b c4 89 10 8b 53 24 89)
assert(TOS.exe+0x1a69b,8b 53 20 89 10 8b 53 24)
assert(TOS.exe+0x1a715,8b c4 89 10 8b 53 24 89)
assert(TOS.exe+0x1a78e,8b c4 89 10 8b 53 24 89)
assert(TOS.exe+0x1a804,8b c4 89 10 8b 53 24 89)
assert(TOS.exe+0x1aa48,8b c4 89 30 8b 77 24 89)
assert(TOS.exe+0x1ac02,0f be d0 6b d2 34 34 01)
assert(TOS.exe+0x1b13a,8b c4 89 38 8b 7b 24 89)
assert(TOS.exe+0x1b7ea,d8 44 24 40 8b 54 24 2c)
assert(TOS.exe+0x1bd73,8b 53 20 8b c4 89 10 8b)
assert(TOS.exe+0x1be1e,8b c4 89 10 8b 53 24 89)
assert(TOS.exe+0x1be9c,8b c4 89 10 8b 53 24 89)
assert(TOS.exe+0x1c302,8b 4b 20 8b c4 89 08 8b)
assert(TOS.exe+0x1c378,8b c4 88 4c 24 1f 8b 4b)
assert(TOS.exe+0x1c8d5,8b 53 20 8b c4 d9 5c 24)
assert(TOS.exe+0x1c981,8b c4 d9 5c 24 24 d9 44)
assert(TOS.exe+0x1ca33,de c1 8b c4 d9 5c 24 24)
assert(TOS.exe+0x1cae4,de c1 8b c4 d9 5c 24 24)
assert(TOS.exe+0x1cf6b,83 ec 10 8b cc d9 5c 24)
assert(TOS.exe+0x1d634,d9 44 24 50 8b 54 24 58)
assert(TOS.exe+0x1db42,8b c4 89 38 8b 7b 24 89)
assert(TOS.exe+0x1e1aa,83 c4 24 8b c4 89 38 89)
assert(TOS.exe+0x1e6af,8b c4 89 38 8b 7b 24 89)
assert(TOS.exe+0x1f082,8b 54 24 2c 8b c4 89 10)
assert(TOS.exe+0x20169,8b c4 89 4d f8 8b 4d e8)
assert(TOS.exe+0x204be,8b cc 89 39 8b be 3c 39)
assert(TOS.exe+0x20801,8b cc 89 39 8b be 3c 39)
assert(TOS.exe+0x20dae,8b cc 89 39 8b be 3c 39)
assert(TOS.exe+0x210d4,8b c4 89 38 8b be a0 38)
assert(TOS.exe+0x211a9,8b c4 89 38 8b b9 a0 38)
assert(TOS.exe+0x21583,89 54 24 24 8b c4 d9 5c)
assert(TOS.exe+0x21b2a,8b c4 89 38 8b b9 a0 38)
assert(TOS.exe+0x21fc1,d9 5c 24 0c 8b c4 89 38)
assert(TOS.exe+0x222de,8b cc 89 39 8b be 3c 39)
assert(TOS.exe+0x2251d,d9 5c 24 0c 8b d4 89 3a)
assert(TOS.exe+0x22845,8b cc 89 39 8b be 3c 39)
assert(TOS.exe+0x228b7,8b cc 89 39 8b be 3c 39)
assert(TOS.exe+0x22eb1,8b cc 89 39 8b be a0 38)
assert(TOS.exe+0x23626,8b c4 89 38 8b 7c 24 24)
assert(TOS.exe+0x23782,8b c4 89 38 8b 7c 24 24)
assert(TOS.exe+0x23ade,8b cc 89 39 8b be 3c 39)
assert(TOS.exe+0x23da8,89 55 f8 8b 91 9c 38 01)
assert(TOS.exe+0x23e26,8b 91 9c 38 01 00 83 ec)
assert(TOS.exe+0x243c6,8b b9 38 39 01 00 83 ec)
assert(TOS.exe+0x245e8,8b c4 89 38 8b 7c 24 28)
assert(TOS.exe+0x24a14,8b c4 89 38 8b 7d f4 89)
assert(TOS.exe+0x2504a,8b c4 89 10 8b 97 a0 38)
assert(TOS.exe+0x250c8,8b 86 6c 39 01 00 8b 90)
assert(TOS.exe+0x2515e,8b 86 6c 39 01 00 8b cc)
assert(TOS.exe+0x25252,8b 86 6c 39 01 00 8b cc)
assert(TOS.exe+0x253b9,8b 4d 08 8b 55 0c 89 48)
assert(TOS.exe+0x2599c,0f b6 d0 80 bc 32 ee 93)
assert(TOS.exe+0x259bf,80 be 08 91 00 00 00 0f)
assert(TOS.exe+0x26646,0f b6 d0 80 bc 0a ee 93)
assert(TOS.exe+0x26675,f6 83 20 13 00 00 02 74)
assert(TOS.exe+0x26bb2,74 0b a9 00 00 00 20 0f)
assert(TOS.exe+0x27214,8b fb e8 25 16 00 00 f6)
assert(TOS.exe+0x27245,74 08 f7 c1 00 00 00 20)
assert(TOS.exe+0x27987,8b 35 dc 2e ad 00 83 c4)
assert(TOS.exe+0x27d3f,5e 32 c0 5b 8b e5 5d c3)
assert(TOS.exe+0x28120,80 60 35 fc 5e 59 5d c3)
assert(TOS.exe+0x282d0,57 8d 84 11 10 b3 15 00)
assert(TOS.exe+0x28984,0f 94 c1 8b c1 c3 cc cc)
assert(TOS.exe+0x33ccb,0f 85 f7 fd ff ff a9 00)
assert(TOS.exe+0x3ede9,32 c0 5f 5e 5b 8b e5 5d)
assert(TOS.exe+0x3efb3,f7 c2 00 00 00 10 74 0d)
assert(TOS.exe+0x3f548,5f 5e 5b 8b 4c 24 30 33)
assert(TOS.exe+0x3fc5c,a9 00 00 00 10 74 17 0f)
assert(TOS.exe+0x3fc7a,f6 43 38 20 0f 84 a8 00)
assert(TOS.exe+0x51b61,33 c0 85 c9 75 02 5e c3)
assert(TOS.exe+0x56b63,8b 4d 0c 8a 81 de 00 00)
assert(TOS.exe+0x57ecf,5f 89 8e 48 01 00 00 38)
assert(TOS.exe+0x61013,d9 96 b0 00 00 00 33 d2)
assert(TOS.exe+0x6dee0,55 8b ec 83 ec 10 0f b6)
assert(TOS.exe+0x6def6,83 bc 08 14 b3 15 00 00)
assert(TOS.exe+0x6dffd,33 f6 83 c4 04 3b d6 7c)
assert(TOS.exe+0x6e050,55 8b ec 83 e4 f8 83 ec)
assert(TOS.exe+0x6e069,53 56 57 8b f0 a1 dc 2e)
assert(TOS.exe+0x6e2ae,3d c8 00 00 00 7d 0e 0f)
assert(TOS.exe+0x6e380,55 8b ec 6a ff 68 fe 42)
assert(TOS.exe+0x6e3cc,8b 94 38 10 b3 15 00 8d)
assert(TOS.exe+0x6e484,7d 0a 0f be ca)
assert(TOS.exe+0x6e490,8b 43 04 83 78 08 00 74)
assert(TOS.exe+0x6e4bc,50 52 e8 fd 4c 11 00 eb)
assert(TOS.exe+0x6e7a3,eb 06 89 bb 90 01 00 00)
assert(TOS.exe+0x6e9cd,89 ba 80 08 00 00 89 ba)
assert(TOS.exe+0x6ea47,f6 84 01 d4 b4 15 00 02)
assert(TOS.exe+0x6eaa0,8d b4 01 10 b3 15 00 8d)
assert(TOS.exe+0x6eb00,83 c4 04 f6 83 c4 01 00)
assert(TOS.exe+0x74510,8b 45 18 a9 00 00 80 00)
assert(TOS.exe+0x74f1b,e8 06 17 27 00 89 3d 68)
assert(TOS.exe+0x7a6d1,66 89 87 0e 94 00 00 6a)
assert(TOS.exe+0x7a9e0,8b 4d f0 81 c1 8c 90 00)
assert(TOS.exe+0x7bc18,8d bc 3b 00 00 00 0d 89 bc b0 ec b1 15 00 eb)
assert(TOS.exe+0x7bc28,03 df 89 9c b0 ec b1 15)
assert(TOS.exe+0x4d84e8,00 00 00 00)
assert(TOS.exe+0x4d8548,06 11 04 00)
assert(TOS.exe+0x4d85a8,0a 11 04 00)
assert(TOS.exe+0x4d8608,12 11 04 00)
assert(TOS.exe+0x4d8668,08 01 04 00)
assert(TOS.exe+0x4d86c8,10 01 04 00)
assert(TOS.exe+0x4d8728,04 01 04 00)
assert(TOS.exe+0x4d8788,08 01 04 00)
assert(TOS.exe+0x4d87e8,08 01 04 00)
assert(TOS.exe+0x4d8848,10 01 04 00)
assert(TOS.exe+0x4d88a8,04 01 04 00)
assert(TOS.exe+0x4d8908,08 01 04 00)
assert(TOS.exe+0x4d8968,08 01 04 00)
assert(TOS.exe+0x4d89c8,04 01 04 00)
assert(TOS.exe+0x4d8a28,08 01 04 00)
assert(TOS.exe+0x4d8a88,10 01 04 00)
assert(TOS.exe+0x4d8ae8,08 01 04 00)
assert(TOS.exe+0x4d8b48,44 41 04 00)
assert(TOS.exe+0x4d8ba8,48 41 04 00)
assert(TOS.exe+0x4d8c08,48 41 04 00)
assert(TOS.exe+0x4d8c68,08 01 04 00)
assert(TOS.exe+0x4d8cc8,10 01 04 00)
assert(TOS.exe+0x4d8d28,10 01 04 00)
assert(TOS.exe+0x4d8d88,10 01 04 00)
assert(TOS.exe+0x4d8de8,10 01 04 00)
assert(TOS.exe+0x4d8e48,10 01 04 00)
assert(TOS.exe+0x4d8ea8,10 01 04 00)
assert(TOS.exe+0x4d8f08,10 01 04 00)
assert(TOS.exe+0x4d8f68,10 01 04 00)
assert(TOS.exe+0x4d8fc8,50 01 04 00)
assert(TOS.exe+0x4d9028,10 01 04 00)
assert(TOS.exe+0x4d9088,20 01 00 00)
assert(TOS.exe+0x4d90e8,20 01 00 00)
assert(TOS.exe+0x4d9148,04 01 00 00)
assert(TOS.exe+0x4d91a8,10 00 12 02)
assert(TOS.exe+0x4d9208,06 11 04 00)
assert(TOS.exe+0x4d9268,0a 11 04 00)
assert(TOS.exe+0x4d92c8,12 11 04 00)
assert(TOS.exe+0x4d9328,08 01 04 00)
assert(TOS.exe+0x4d9388,10 01 04 00)
assert(TOS.exe+0x4d93e8,06 51 04 00)
assert(TOS.exe+0x4d9448,0a 51 04 00)
assert(TOS.exe+0x4d94a8,12 51 04 00)
assert(TOS.exe+0x4d9508,0a 01 04 00)
assert(TOS.exe+0x4d9568,12 01 04 00)
assert(TOS.exe+0x4d95c8,08 01 04 00)
assert(TOS.exe+0x4d9628,10 01 04 00)
assert(TOS.exe+0x4d9688,08 01 04 00)
assert(TOS.exe+0x4d96e8,10 01 04 00)
assert(TOS.exe+0x4d9748,08 01 04 00)
assert(TOS.exe+0x4d97a8,10 01 04 00)
assert(TOS.exe+0x4d9808,11 01 04 00)
assert(TOS.exe+0x4d9868,12 01 04 00)
assert(TOS.exe+0x4d98c8,20 01 00 00)
assert(TOS.exe+0x4d9928,20 01 00 00)
assert(TOS.exe+0x4d9988,20 01 00 00)
assert(TOS.exe+0x4d99e8,93 01 04 01)
assert(TOS.exe+0x4d9a48,93 04 08 01)
assert(TOS.exe+0x4d9aa8,93 01 04 01)
assert(TOS.exe+0x4d9b08,93 04 08 01)
assert(TOS.exe+0x4d9b68,93 01 04 01)
assert(TOS.exe+0x4d9bc8,20 01 00 00)
assert(TOS.exe+0x4d9c28,86 41 44 00)
assert(TOS.exe+0x4d9c88,8b 01 44 00)
assert(TOS.exe+0x4d9ce8,93 01 44 00)
assert(TOS.exe+0x4d9d48,8b 01 44 00)
assert(TOS.exe+0x4d9da8,86 41 44 00)
assert(TOS.exe+0x4d9e08,8b 01 44 00)
assert(TOS.exe+0x4d9e68,8b 01 44 00)
assert(TOS.exe+0x4d9ec8,8b 01 44 00)
assert(TOS.exe+0x4d9f28,86 41 44 00)
assert(TOS.exe+0x4d9f88,8b 01 44 00)
assert(TOS.exe+0x4d9fe8,93 01 44 00)
assert(TOS.exe+0x4da048,8b 01 44 00)
assert(TOS.exe+0x4da0a8,86 01 44 00)
assert(TOS.exe+0x4da108,8b 01 44 00)
assert(TOS.exe+0x4da168,8b 01 44 00)
assert(TOS.exe+0x4da1c8,8b 01 44 00)
assert(TOS.exe+0x4da228,86 01 44 00)
assert(TOS.exe+0x4da288,8b 01 44 00)
assert(TOS.exe+0x4da2e8,93 01 44 00)
assert(TOS.exe+0x4da348,8b 01 44 00)
assert(TOS.exe+0x4da3a8,86 01 44 00)
assert(TOS.exe+0x4da408,8b 01 44 00)
assert(TOS.exe+0x4da468,8b 01 44 00)
assert(TOS.exe+0x4da4c8,93 01 44 00)
assert(TOS.exe+0x4da528,93 01 44 00)
assert(TOS.exe+0x4da588,92 01 00 00)
assert(TOS.exe+0x4da5e8,93 01 44 00)
assert(TOS.exe+0x4da648,93 01 44 00)
assert(TOS.exe+0x4da6a8,93 01 44 00)
assert(TOS.exe+0x4da708,93 01 44 00)
assert(TOS.exe+0x4da768,93 01 44 00)
assert(TOS.exe+0x4da7c8,93 01 44 00)
assert(TOS.exe+0x4da828,93 01 44 00)
assert(TOS.exe+0x4da888,93 01 44 00)
assert(TOS.exe+0x4da8e8,a3 01 44 00)
assert(TOS.exe+0x4da948,a3 01 44 00)
assert(TOS.exe+0x4da9a8,86 02 88 00)
assert(TOS.exe+0x4daa08,8b 02 88 00)
assert(TOS.exe+0x4daa68,8b 02 88 00)
assert(TOS.exe+0x4daac8,86 80 88 00)
assert(TOS.exe+0x4dab28,8b 80 88 00)
assert(TOS.exe+0x4dab88,8b 80 88 00)
assert(TOS.exe+0x4dabe8,86 00 89 00)
assert(TOS.exe+0x4dac48,8b 00 89 00)
assert(TOS.exe+0x4daca8,8b 00 89 00)
assert(TOS.exe+0x4dad08,86 04 88 00)
assert(TOS.exe+0x4dad68,8b 04 88 00)
assert(TOS.exe+0x4dadc8,8b 04 88 00)
assert(TOS.exe+0x4dae28,86 04 88 00)
assert(TOS.exe+0x4dae88,8b 04 88 00)
assert(TOS.exe+0x4daee8,8b 04 88 00)
assert(TOS.exe+0x4daf48,8b 01 84 00)
assert(TOS.exe+0x4dafa8,93 01 84 00)
assert(TOS.exe+0x4db008,93 01 84 00)
assert(TOS.exe+0x4db068,86 00 a8 00)
assert(TOS.exe+0x4db0c8,8b 02 88 00)
assert(TOS.exe+0x4db128,8b 02 88 00)
assert(TOS.exe+0x4db188,93 02 88 00)
assert(TOS.exe+0x4db1e8,8b 02 88 00)
assert(TOS.exe+0x4db248,8b 20 88 00)
assert(TOS.exe+0x4db2a8,93 02 88 00)
assert(TOS.exe+0x4db308,93 02 88 00)
assert(TOS.exe+0x4db368,93 01 04 01)
assert(TOS.exe+0x4db3c8,10 01 04 00)
assert(TOS.exe+0x4db428,04 01 04 00)
assert(TOS.exe+0x4db488,08 01 04 00)
assert(TOS.exe+0x4db4e8,08 01 04 00)
assert(TOS.exe+0x4db548,04 01 04 00)
assert(TOS.exe+0x4db5a8,08 01 04 00)
assert(TOS.exe+0x4db608,08 01 04 00)
assert(TOS.exe+0x4db668,04 01 04 00)
assert(TOS.exe+0x4db6c8,08 01 04 00)
assert(TOS.exe+0x4db728,08 01 04 00)
assert(TOS.exe+0x4db788,08 01 04 00)
assert(TOS.exe+0x4db7e8,08 01 04 00)
assert(TOS.exe+0x4db848,8a 04 88 00)
assert(TOS.exe+0x4db8a8,8a 04 88 00)
assert(TOS.exe+0x4db908,93 01 84 40)
assert(TOS.exe+0x4db968,12 01 04 00)
assert(TOS.exe+0x4db9c8,10 01 04 00)
assert(TOS.exe+0x4dba28,92 20 88 80)
assert(TOS.exe+0x4dba88,12 01 04 00)
assert(TOS.exe+0x4dbae8,a3 01 04 01)
assert(TOS.exe+0x4dbb48,08 01 04 00)
assert(TOS.exe+0x4dbba8,10 01 04 00)
assert(TOS.exe+0x4dbc08,10 01 04 00)
assert(TOS.exe+0x4dbc68,10 41 04 00)
assert(TOS.exe+0x4dbcc8,08 01 04 00)
assert(TOS.exe+0x4dbd28,10 01 04 00)
assert(TOS.exe+0x4dbd88,10 01 04 00)
assert(TOS.exe+0x4dbde8,10 01 04 00)
assert(TOS.exe+0x4dbe48,21 01 04 00)
assert(TOS.exe+0x4dbea8,04 01 04 00)
assert(TOS.exe+0x4dbf08,08 01 04 00)
assert(TOS.exe+0x4dbf68,10 01 04 00)
assert(TOS.exe+0x4dbfc8,08 01 04 00)
assert(TOS.exe+0x4dc028,10 01 00 00)
assert(TOS.exe+0x4dc088,04 01 04 00)
assert(TOS.exe+0x4dc0e8,08 01 04 00)
assert(TOS.exe+0x4dc148,10 01 04 00)
assert(TOS.exe+0x4dc1a8,08 01 04 00)
assert(TOS.exe+0x4dc208,04 01 04 00)
assert(TOS.exe+0x4dc268,08 01 04 00)
assert(TOS.exe+0x4dc2c8,08 01 04 00)
assert(TOS.exe+0x4dc328,10 01 00 00)
assert(TOS.exe+0x4dc388,04 01 04 00)
assert(TOS.exe+0x4dc3e8,08 01 04 00)
assert(TOS.exe+0x4dc448,08 01 04 00)
assert(TOS.exe+0x4dc4a8,10 01 04 00)
assert(TOS.exe+0x4dc508,10 01 04 00)
assert(TOS.exe+0x4dc568,10 01 04 00)
assert(TOS.exe+0x4dc5c8,10 01 04 00)
assert(TOS.exe+0x4dc628,10 01 00 00)
assert(TOS.exe+0x4dc688,10 01 04 00)
assert(TOS.exe+0x4dc6e8,00 01 04 04)
assert(TOS.exe+0x4dc748,00 01 04 02)
assert(TOS.exe+0x4dc7a8,00 01 04 02)
assert(TOS.exe+0x4dc808,00 01 04 02)
assert(TOS.exe+0x4dc868,00 01 04 02)
assert(TOS.exe+0x4dc8c8,00 01 04 02)
assert(TOS.exe+0x4dc928,00 01 04 04)
assert(TOS.exe+0x4dc988,00 01 04 04)
assert(TOS.exe+0x4dc9e8,00 01 04 04)
assert(TOS.exe+0x4dca48,00 01 04 08)
assert(TOS.exe+0x4dcaa8,00 01 04 08)
assert(TOS.exe+0x4dcb08,00 01 04 08)
assert(TOS.exe+0x4dcb68,00 01 04 04)
assert(TOS.exe+0x4dcbc8,00 01 04 04)
assert(TOS.exe+0x4dcc28,00 01 04 04)
assert(TOS.exe+0x4dcc88,00 01 04 02)
assert(TOS.exe+0x4dcce8,86 02 88 82)
assert(TOS.exe+0x4dcd48,8a 02 88 02)
assert(TOS.exe+0x4dcda8,8a 02 88 02)
assert(TOS.exe+0x4dce08,00 01 04 08)
assert(TOS.exe+0x4dce68,10 01 04 00)
assert(TOS.exe+0x4dcec8,00 01 04 04)
assert(TOS.exe+0x4dcf28,00 01 04 04)
assert(TOS.exe+0x4dcf88,00 01 04 02)
assert(TOS.exe+0x4dcfe8,21 01 04 00)
assert(TOS.exe+0x4dd048,00 00 04 02)
assert(TOS.exe+0x4dd0a8,10 00 12 02)
assert(TOS.exe+0x4dd108,10 00 12 02)
assert(TOS.exe+0x4dd168,10 00 12 02)
assert(TOS.exe+0x4dd1c8,10 00 12 02)
assert(TOS.exe+0x4dd228,10 00 12 00)
assert(TOS.exe+0x4dd288,06 11 04 00)
assert(TOS.exe+0x4dd2e8,0a 11 04 00)
assert(TOS.exe+0x4dd348,08 01 04 00)
assert(TOS.exe+0x4dd3a8,04 01 04 00)
assert(TOS.exe+0x4dd408,08 01 04 00)
assert(TOS.exe+0x4dd468,08 01 04 00)
assert(TOS.exe+0x4dd4c8,86 41 44 00)
assert(TOS.exe+0x4dd528,8b 01 44 00)
assert(TOS.exe+0x4dd588,86 41 44 00)
assert(TOS.exe+0x4dd5e8,8b 01 44 00)
assert(TOS.exe+0x4dd648,86 01 44 00)
assert(TOS.exe+0x4dd6a8,8b 01 44 00)
assert(TOS.exe+0x4dd708,86 01 44 00)
assert(TOS.exe+0x4dd768,8b 01 44 00)
assert(TOS.exe+0x4dd7c8,86 02 88 00)
assert(TOS.exe+0x4dd828,a3 01 84 00)
assert(TOS.exe+0x4dd888,08 01 04 00)
assert(TOS.exe+0x4dd8e8,10 01 04 00)
assert(TOS.exe+0x4dd948,86 00 84 00)
assert(TOS.exe+0x4dd9a8,87 00 84 00)
assert(TOS.exe+0x4dda08,93 00 84 00)
assert(TOS.exe+0x4dda68,21 01 04 00)
assert(TOS.exe+0x4ddac8,8a 04 88 00)
assert(TOS.exe+0x4ddb28,8a 04 88 00)
assert(TOS.exe+0x4ddb88,8a 04 88 00)
assert(TOS.exe+0x4ddbe8,8a 04 88 00)
assert(TOS.exe+0x4ddc48,8a 04 88 00)
assert(TOS.exe+0x4ddca8,8a 04 88 00)
assert(TOS.exe+0x4ddd08,a1 01 84 20)
assert(TOS.exe+0x4ddd68,a1 01 84 20)
assert(TOS.exe+0x4dddc8,a1 01 84 20)
assert(TOS.exe+0x4dde28,a1 01 84 20)
assert(TOS.exe+0x4dde88,a1 01 84 20)
assert(TOS.exe+0x4ddee8,a1 01 84 20)
assert(TOS.exe+0x4ddf48,a1 01 84 20)
assert(TOS.exe+0x4ddfa8,a1 01 84 20)
assert(TOS.exe+0x4de008,a1 01 84 20)
assert(TOS.exe+0x4de068,a1 01 84 20)
assert(TOS.exe+0x4de0c8,a1 01 84 20)
assert(TOS.exe+0x4de128,87 01 84 00)
assert(TOS.exe+0x4de188,a3 01 84 00)
assert(TOS.exe+0x4de1e8,a3 01 44 00)
assert(TOS.exe+0x4de248,21 01 04 00)
assert(TOS.exe+0x4de2a8,87 01 84 00)
assert(TOS.exe+0x4de308,a3 00 04 01)
assert(TOS.exe+0x4de368,93 01 04 01)
assert(TOS.exe+0x4de3c8,21 01 04 00)
assert(TOS.exe+0x4de428,21 01 04 00)
assert(TOS.exe+0x4e9e2c,74 b8 8e 00 44 b8 8e 00 14 b8 8e 00)
assert(TOS.exe+0x4e9e3c,b8 b7 8e 00 88 b7 8e 00 58 b7 8e 00)
assert(TOS.exe+0x4e9e4c,fc b6 8e 00 cc b6 8e 00 9c b6 8e 00)
assert(TOS.exe+0x4e9e5c,40 b6 8e 00 10 b6 8e 00 e0 b5 8e 00)
assert(TOS.exe+0x4e9e6c,84 b5 8e 00 54 b5 8e 00 24 b5 8e 00)
assert(TOS.exe+0x4e9e7c,c8 b4 8e 00 98 b4 8e 00 68 b4 8e 00 38 b4 8e 00)
assert(TOS.exe+0x4e9e90,08 b4 8e 00 d8 b3 8e 00 a8 b3 8e 00 78 b3 8e 00 48 b3 8e 00 18 b3 8e 00 e8 b2 8e 00 b8 b2 8e 00)
assert(TOS.exe+0x4e9ebc,5c b2 8e 00 2c b2 8e 00)
assert(TOS.exe+0x4e9ec8,d0 b1 8e 00 a0 b1 8e 00)
assert(TOS.exe+0x4e9ed4,44 b1 8e 00 14 b1 8e 00)
assert(TOS.exe+0x4e9ee0,a0 b0 8e 00 58 b0 8e 00)
assert(TOS.exe+0x4e9eec,cc af 8e 00 84 af 8e 00 3c af 8e 00 0c af 8e 00 dc ae 8e 00)
assert(TOS.exe+0x4e9f04,80 ae 8e 00 50 ae 8e 00 20 ae 8e 00 f0 ad 8e 00 c0 ad 8e 00 90 ad 8e 00 60 ad 8e 00)
assert(TOS.exe+0x4e9f2c,bc ac 8e 00)
assert(TOS.exe+0x4e9f34,5c ac 8e 00 2c ac 8e 00 fc ab 8e 00 cc ab 8e 00 9c ab 8e 00)
assert(TOS.exe+0x4e9f60,3c af 8e 00)
assert(TOS.exe+0x4e9f70,18 aa 8e 00 dc ae 8e 00)
assert(TOS.exe+0x4eaa20,f0 80 42 00)
assert(TOS.exe+0x4eaba4,f0 80 42 00)
assert(TOS.exe+0x4eabd4,f0 80 42 00)
assert(TOS.exe+0x4eac04,f0 80 42 00)
assert(TOS.exe+0x4eac34,f0 80 42 00)
assert(TOS.exe+0x4eac64,f0 80 42 00)
assert(TOS.exe+0x4eacc4,f0 80 42 00)
assert(TOS.exe+0x4ead68,f0 80 42 00)
assert(TOS.exe+0x4ead98,f0 80 42 00)
assert(TOS.exe+0x4eadc8,f0 80 42 00)
assert(TOS.exe+0x4eadf8,f0 80 42 00)
assert(TOS.exe+0x4eae28,f0 80 42 00)
assert(TOS.exe+0x4eae58,f0 80 42 00)
assert(TOS.exe+0x4eae88,f0 80 42 00)
assert(TOS.exe+0x4eaee4,f0 80 42 00)
assert(TOS.exe+0x4eaf14,f0 80 42 00)
assert(TOS.exe+0x4eaf44,f0 80 42 00)
assert(TOS.exe+0x4eaf8c,f0 80 42 00)
assert(TOS.exe+0x4eafd4,f0 80 42 00)
assert(TOS.exe+0x4eb060,f0 80 42 00)
assert(TOS.exe+0x4eb0a8,f0 80 42 00)
assert(TOS.exe+0x4eb11c,f0 80 42 00)
assert(TOS.exe+0x4eb14c,f0 80 42 00)
assert(TOS.exe+0x4eb1a8,f0 80 42 00)
assert(TOS.exe+0x4eb1d8,f0 80 42 00)
assert(TOS.exe+0x4eb234,f0 80 42 00)
assert(TOS.exe+0x4eb264,f0 80 42 00)
assert(TOS.exe+0x4eb2c0,f0 80 42 00)
assert(TOS.exe+0x4eb2f0,f0 80 42 00)
assert(TOS.exe+0x4eb320,f0 80 42 00)
assert(TOS.exe+0x4eb350,f0 80 42 00)
assert(TOS.exe+0x4eb380,f0 80 42 00)
assert(TOS.exe+0x4eb3b0,f0 80 42 00)
assert(TOS.exe+0x4eb3e0,f0 80 42 00)
assert(TOS.exe+0x4eb410,f0 80 42 00)
assert(TOS.exe+0x4eb440,f0 80 42 00)
assert(TOS.exe+0x4eb470,f0 80 42 00)
assert(TOS.exe+0x4eb4a0,f0 80 42 00)
assert(TOS.exe+0x4eb4d0,f0 80 42 00)
assert(TOS.exe+0x4eb52c,f0 80 42 00)
assert(TOS.exe+0x4eb55c,f0 80 42 00)
assert(TOS.exe+0x4eb58c,f0 80 42 00)
assert(TOS.exe+0x4eb5e8,f0 80 42 00)
assert(TOS.exe+0x4eb618,f0 80 42 00)
assert(TOS.exe+0x4eb648,f0 80 42 00)
assert(TOS.exe+0x4eb6a4,f0 80 42 00)
assert(TOS.exe+0x4eb6d4,f0 80 42 00)
assert(TOS.exe+0x4eb704,f0 80 42 00)
assert(TOS.exe+0x4eb760,f0 80 42 00)
assert(TOS.exe+0x4eb790,f0 80 42 00)
assert(TOS.exe+0x4eb7c0,f0 80 42 00)
assert(TOS.exe+0x4eb81c,f0 80 42 00)
assert(TOS.exe+0x4eb84c,f0 80 42 00)
assert(TOS.exe+0x4eb87c,f0 80 42 00)


// Concurrent Unison Mystic Artes and summons, using the spell-slot lifecycle.
// Each caster retains its own resources, portraits and busy flag.
alloc(mem_multi_ma,0x1000)
alloc(ma_state,0x200)
alloc(ma_whitelist,0x400)
registersymbol(mm_allowed)

mem_multi_ma:
// Do not let an MA cancel other party members' casts during Unison.
mm_exclusive:
  push ecx
  cmp byte ptr [edx+0x9108], #0
  je mm_exclusive_native
  test byte ptr [eax+0x1320], #1
  jnz mm_exclusive_native
  mov ecx, [eax+#12]
  test ecx, ecx
  jz mm_exclusive_native
  movzx ecx, word ptr [ecx]
  cmp ecx, #512
  jae mm_exclusive_native
  cmp byte ptr [mm_mystic+ecx], #0
  je mm_exclusive_native
mm_exclusive_allow:
  movzx eax, byte ptr [edx+0x934C]
  pop ecx
  jmp TOS.exe+0x633F7
mm_exclusive_native:
  pop ecx
  mov [edx+0x13298], eax
  jmp TOS.exe+0x6331F

// Let the remaining Unison MA chants finish despite another active MA.
mm_chant_gate:
    push ecx
    mov eax, [TOS.exe+0x6d2edc]
    cmp byte ptr [eax+0x9108], #0
    je mm_chant_native
    test byte ptr [edi+0x1320], #1
    jne mm_chant_native
    mov ecx, [edi+#12]
    test ecx, ecx
    jz mm_chant_native
    movzx ecx, word ptr [ecx]
    cmp ecx, #512
    jae mm_chant_native
    cmp byte ptr [mm_mystic+ecx], #0
    je mm_chant_native
mm_chant_allow:
    mov edx, eax
    xor eax, eax
    pop ecx
    ret
mm_chant_native:
    pop ecx
    jmp TOS.exe+0x28840

// ESI actor -> EAX boolean; EBX battle and EDX arte.
mm_is_unison_ma:
    mov ebx,[TOS.exe+0x6d2edc]
    test ebx,ebx
    jz mm_invalid
    cmp byte ptr [ebx+0x9108],#0
    je mm_invalid
    test esi,esi
    jz mm_invalid
    test byte ptr [esi+0x1320],#1
    jnz mm_invalid
    mov edx,[esi+#12]
    test edx,edx
    jz mm_invalid
    movzx edx,word ptr [edx]
    cmp edx, #512
    jae mm_invalid
    cmp byte ptr [mm_mystic+edx], #0
    je mm_invalid
    mov eax,#1
    ret

// ESI actor -> EAX owned slot header or zero; EBX battle, EDI slot, EDX arte.
mm_slot_header:
    call mm_is_unison_ma
    test eax,eax
    jz mm_invalid
    movzx edi,byte ptr [esi+0x13ab0]
    cmp edi,#10
    jae mm_invalid
    cmp edi,#3
    jb mm_header_slot
    cmp edi,#6
    jb mm_invalid
mm_header_slot:
    mov eax,edi
    call slot_addr
    cmp [eax+#444],esi
    jne mm_invalid
    cmp word ptr [eax+#454],dx
    jne mm_invalid
    cmp dword ptr [eax+#4],#0
    je mm_invalid
    ret
mm_invalid:
    xor eax,eax
    ret
mm_portrait_load:
    pushfd
    pushad
    push #0
    jmp mm_load_common
mm_portrait_load_second:
    pushfd
    pushad
    push #1
    jmp mm_load_common
mm_portrait_load_ebx:
    pushfd
    pushad
    mov esi,ebx
    push #0
mm_load_common:
    call mm_is_unison_ma
    test eax,eax
    jz mm_load_done
    call mm_slot_header
    test eax,eax
    jz mm_load_missing
    mov edx,[esp]
    mov ecx,[eax+edx*#4+#404]
    test ecx,ecx
    jz mm_load_missing
    mov [ebx+0x15b2b8],ecx
    mov [esp+#28],ecx
    mov eax,edi
    shl eax,#8
    add eax,0x53530000
    add eax,edx
    mov [esp+#44],eax
    mov edx,edi
    add edx,#112
    cmp edi,#6
    jb mm_tag_ready
    lea edx,[edi+0x53510000]
mm_tag_ready:
    mov [esp+#48],edx
    mov [ma_state],ebx
    lea edx,[ma_state+0x100+edi*#8]
    mov [edx],esi
    mov [edx+#4],eax
mm_load_done:
    add esp,#4
    popad
    popfd
    jmp TOS.exe+0x1831c0
mm_load_missing:
    add esp,#4
    popad
    popfd
    xor eax,eax
    ret
mm_portrait_select:
    pushfd
    pushad
    test byte ptr [esp+#44],0x80
    jz mm_select_done
    mov dword ptr [ma_state+#4],#0
    call mm_slot_header
    test eax,eax
    jz mm_select_done
    cmp [ma_state],ebx
    jne mm_select_done
    lea ecx,[ma_state+0x100+edi*#8]
    cmp [ecx],esi
    jne mm_select_done
    mov eax,[ecx+#4]
    mov [ma_state+#4],eax
mm_select_done:
    popad
    popfd
    push ebp
    mov ebp,esp
    push ebx
    mov bl,[ebp+#12]
    jmp TOS.exe+0x60c17
mm_portrait_draw:
    pushfd
    push ecx
    mov ecx,0x0d00001b
    cmp [ma_state],eax
    jne mm_draw_done
    cmp dword ptr [ma_state+#4],#0
    je mm_draw_done
    mov ecx,[ma_state+#4]
mm_draw_done:
    mov [eax+0x15b208],ecx
    pop ecx
    popfd
    jmp TOS.exe+0x515e3
mm_portrait_scale:
    cmp dword ptr [edx+ecx*#4+0x15b1ec],0x0d00001b
    je mm_scale_done
    push eax
    mov eax,[edx+ecx*#4+0x15b1ec]
    and eax,0xffff0000
    cmp eax,0x53530000
    pop eax
mm_scale_done:
    jmp TOS.exe+0x7c411

// MA animation swaps use the caster's slot; native model restores are unchanged.
mm_model_load:
    pushfd
    pushad
    mov esi,[esp+#40]
    call mm_is_unison_ma
    test eax,eax
    jz mm_model_done
    call mm_slot_header
    test eax,eax
    jz mm_model_missing
    mov eax,[eax+#408]
    test eax,eax
    jz mm_model_missing
    mov [esp+#48],eax
mm_model_done:
    popad
    popfd
    jmp TOS.exe+0x3e600
mm_model_missing:
    popad
    popfd
    xor eax,eax
    ret

// Refresh repositioned model coordinates before Unison collision-distance math.
mm_placement_transform:
    pushfd
    push eax
    mov eax,[TOS.exe+0x6d2edc]
    cmp byte ptr [eax+0x9108],#0
    je mm_transform_done
// This call follows an explicit reposition. Freeze flags must not reuse
// the old model position when calculating the melee starting distance.
    mov dword ptr [esp+#20],#0
mm_transform_done:
    pop eax
    popfd
    jmp TOS.exe+0x370d0


// An MA owns only its assigned slot; other casts keep their reservations.
mm_reserve_40C806:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_40C806_native
    popad
    test esp,esp
    ret
mm_reserve_40C806_native:
    popad
    cmp byte ptr [edx+eax+0x93EE], #0
    ret
mm_reserve_40D054:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_40D054_native
    popad
    test esp,esp
    ret
mm_reserve_40D054_native:
    popad
    cmp byte ptr [edx+eax+0x93EE], #0
    ret
mm_reserve_40D624:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_40D624_native
    popad
    test esp,esp
    ret
mm_reserve_40D624_native:
    popad
    cmp byte ptr [edx+eax+0x93EE], #0
    ret
mm_reserve_40E097:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_40E097_native
    popad
    test esp,esp
    ret
mm_reserve_40E097_native:
    popad
    cmp byte ptr [edx+eax+0x93EE], #0
    ret
mm_reserve_40EB05:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_40EB05_native
    popad
    test esp,esp
    ret
mm_reserve_40EB05_native:
    popad
    cmp byte ptr [ecx+edi+0x93EE], #0
    ret
mm_reserve_40F443:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_40F443_native
    popad
    test esp,esp
    ret
mm_reserve_40F443_native:
    popad
    cmp byte ptr [edx+eax+0x93EE], #0
    ret
mm_reserve_40F9B0:
    pushad
    mov esi,ebx
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_40F9B0_native
    popad
    test esp,esp
    ret
mm_reserve_40F9B0_native:
    popad
    cmp byte ptr [ecx+edx+0x93EE], #0
    ret
mm_reserve_417721:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_417721_native
    popad
    test esp,esp
    ret
mm_reserve_417721_native:
    popad
    cmp byte ptr [ecx+eax+0x93EE], #0
    ret
mm_reserve_419BC2:
    pushad
    mov esi,ebx
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_419BC2_native
    popad
    test esp,esp
    ret
mm_reserve_419BC2_native:
    popad
    cmp byte ptr [eax+ecx+0x93EE], #0
    ret
mm_reserve_41A451:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_41A451_native
    popad
    test esp,esp
    ret
mm_reserve_41A451_native:
    popad
    cmp byte ptr [ecx+eax+0x93EE], #0
    ret
mm_reserve_41EA94:
    pushad
    mov esi,esi
    call mm_is_unison_ma
    test eax,eax
    jz mm_reserve_41EA94_native
    popad
    test esp,esp
    ret
mm_reserve_41EA94_native:
    popad
    cmp byte ptr [ecx+eax+0x93EE], bl
    ret
mm_release_melee:
    pushfd
    pushad
    call mm_is_unison_ma
    test eax,eax
    jz mm_release_melee_native
    call mm_slot_header
    test eax,eax
    jz mm_release_melee_done
    mov eax,edi
    call busy_addr
    mov byte ptr [eax],#0
mm_release_melee_done:
    popad
    popfd
    ret
mm_release_melee_native:
    popad
    popfd
    mov [ecx+eax+0x93EE],bl
    ret

// Spell/summon script cleanup callbacks also hard-code the party side's slot.
// The hooks enter at the release CALL, with its original argument on the stack.
// Each continuation skips both native busy writes and their stack adjustment.
mm_cleanup_spell:
    pushfd
    pushad
    push TOS.exe+0x17D94
    jmp mm_cleanup_common
mm_cleanup_mystic:
    pushfd
    pushad
    push TOS.exe+0x1A8D4
    jmp mm_cleanup_common
mm_cleanup_summon:
    pushfd
    pushad
    push TOS.exe+0x1B88C
mm_cleanup_common:
    mov esi,[ebp+#8]
    call mm_is_unison_ma
    test eax,eax
    jz mm_cleanup_native
    call mm_slot_header
    test eax,eax
    jz mm_cleanup_finished
    push edi
    call TOS.exe+0x6DEE0
    add esp,#4
    mov eax,edi
    call busy_addr
    mov byte ptr [eax],#0
mm_cleanup_finished:
// The native continuations expect the script state in EAX or ECX.
    mov eax,[ebp+#12]
    mov [esp+#32],eax
    mov [esp+#28],eax
    mov eax,[esp]
    mov [esp+#40],eax
    add esp,#4
    popad
    popfd
    ret #4
mm_cleanup_native:
    add esp,#4
    popad
    popfd
    jmp TOS.exe+0x6DEE0

// Portrait battle/selection and ten owner/texture records. Zero-initialized.
ma_state:
  dd #0, #0
ma_state+0x100:
  dd #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0

// Ordinary overlap whitelist plus every party MA and summon.
ma_whitelist:
mm_allowed:
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #1, #0, #0, #0
  db #0, #0, #1, #1, #1, #0, #0, #1, #1, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #1, #1, #1, #0, #1, #1, #1
  db #0, #1, #1, #1, #0, #1, #1, #1, #0, #1, #1, #1, #0, #1, #1, #1
  db #1, #0, #1, #1, #1, #1, #1, #1, #1, #1, #0, #0, #0, #1, #1, #0
  db #1, #1, #0, #1, #1, #0, #1, #1, #0, #1, #1, #1, #1, #1, #0, #1
  db #1, #1, #1, #1, #1, #1, #0, #1, #0, #1, #0, #1, #1, #1, #1, #1
  db #0, #0, #0, #0, #0, #0, #1, #1, #1, #1, #1, #1, #1, #1, #1, #1
  db #1, #1, #1, #1, #1, #1, #0, #0, #1, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0

// MA-specific behavior: 140, 146-148, 151-152, 263, 279-282, 284-293, 296.
ma_whitelist+0x200:
mm_mystic:
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #1, #0, #0, #0
  db #0, #0, #1, #1, #1, #0, #0, #1, #1, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #1, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #1, #1, #1, #1, #0, #1, #1, #1, #1
  db #1, #1, #1, #1, #1, #1, #0, #0, #1, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  db #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0

// Original game instructions, independent of the extra-slot allocation layout.

assert(TOS.exe+0x63319,89 82 98 32 01 00)
TOS.exe+0x63319:
  jmp mm_exclusive
  nop #1

assert(TOS.exe+0x27216,E8 25 16 00 00)
TOS.exe+0x27216:
  call mm_chant_gate

assert(TOS.exe+0xC72F,E8 8C 6A 17 00)
TOS.exe+0xC72F:
  call mm_portrait_load

assert(TOS.exe+0xCF7D,E8 3E 62 17 00)
TOS.exe+0xCF7D:
  call mm_portrait_load

assert(TOS.exe+0xD54D,E8 6E 5C 17 00)
TOS.exe+0xD54D:
  call mm_portrait_load

assert(TOS.exe+0xD7F8,E8 C3 59 17 00)
TOS.exe+0xD7F8:
  call mm_portrait_load_second

assert(TOS.exe+0xDFC0,E8 FB 51 17 00)
TOS.exe+0xDFC0:
  call mm_portrait_load

assert(TOS.exe+0xEA2D,E8 8E 47 17 00)
TOS.exe+0xEA2D:
  call mm_portrait_load

assert(TOS.exe+0xF36C,E8 4F 3E 17 00)
TOS.exe+0xF36C:
  call mm_portrait_load

assert(TOS.exe+0xF96E,E8 4D 38 17 00)
TOS.exe+0xF96E:
  call mm_portrait_load_ebx

assert(TOS.exe+0x176E0,E8 DB BA 16 00)
TOS.exe+0x176E0:
  call mm_portrait_load

assert(TOS.exe+0x19B80,E8 3B 96 16 00)
TOS.exe+0x19B80:
  call mm_portrait_load_ebx

assert(TOS.exe+0x1A410,E8 AB 8D 16 00)
TOS.exe+0x1A410:
  call mm_portrait_load

assert(TOS.exe+0x1EA53,E8 68 47 16 00)
TOS.exe+0x1EA53:
  call mm_portrait_load

assert(TOS.exe+0x60C10,55 8B EC 53 8A 5D 0C)
TOS.exe+0x60C10:
  jmp mm_portrait_select
  nop #2

assert(TOS.exe+0x515D9,C7 80 08 B2 15 00 1B 00 00 0D)
TOS.exe+0x515D9:
  jmp mm_portrait_draw
  nop #5

assert(TOS.exe+0x7C406,81 BC 8A EC B1 15 00 1B 00 00 0D)
TOS.exe+0x7C406:
  jmp mm_portrait_scale
  nop #6

assert(TOS.exe+0xC95B,E8 A0 1C 03 00)
TOS.exe+0xC95B:
  call mm_model_load

assert(TOS.exe+0xE32D,E8 CE 02 03 00)
TOS.exe+0xE32D:
  call mm_model_load

assert(TOS.exe+0x73884,E8 47 38 FC FF)
TOS.exe+0x73884:
  call mm_placement_transform

assert(TOS.exe+0x7389F,E8 2C 38 FC FF)
TOS.exe+0x7389F:
  call mm_placement_transform


// MA reservation and cleanup hooks.
assert(TOS.exe+0xC806,80 bc 02 ee 93 00 00 00)
TOS.exe+0xC806:
  call mm_reserve_40C806
  nop #3

assert(TOS.exe+0xD054,80 bc 02 ee 93 00 00 00)
TOS.exe+0xD054:
  call mm_reserve_40D054
  nop #3

assert(TOS.exe+0xD624,80 bc 02 ee 93 00 00 00)
TOS.exe+0xD624:
  call mm_reserve_40D624
  nop #3

assert(TOS.exe+0xE097,80 bc 02 ee 93 00 00 00)
TOS.exe+0xE097:
  call mm_reserve_40E097
  nop #3

assert(TOS.exe+0xEB05,80 bc 39 ee 93 00 00 00)
TOS.exe+0xEB05:
  call mm_reserve_40EB05
  nop #3

assert(TOS.exe+0xF443,80 bc 02 ee 93 00 00 00)
TOS.exe+0xF443:
  call mm_reserve_40F443
  nop #3

assert(TOS.exe+0xF9B0,80 bc 11 ee 93 00 00 00)
TOS.exe+0xF9B0:
  call mm_reserve_40F9B0
  nop #3

assert(TOS.exe+0x17721,80 bc 01 ee 93 00 00 00)
TOS.exe+0x17721:
  call mm_reserve_417721
  nop #3

assert(TOS.exe+0x19BC2,80 bc 08 ee 93 00 00 00)
TOS.exe+0x19BC2:
  call mm_reserve_419BC2
  nop #3

assert(TOS.exe+0x1A451,80 bc 01 ee 93 00 00 00)
TOS.exe+0x1A451:
  call mm_reserve_41A451
  nop #3

assert(TOS.exe+0x1EA94,38 9c 01 ee 93 00 00)
TOS.exe+0x1EA94:
  call mm_reserve_41EA94
  nop #2

assert(TOS.exe+0xDD39,88 9c 01 ee 93 00 00)
TOS.exe+0xDD39:
  call mm_release_melee
  nop #2

assert(TOS.exe+0xF079,88 9c 01 ee 93 00 00)
TOS.exe+0xF079:
  call mm_release_melee
  nop #2

// Preserve other MAs when a spell or summon finishes.
assert(TOS.exe+0x17D53,e8 88 61 05 00)
TOS.exe+0x17D53:
  call mm_cleanup_spell

assert(TOS.exe+0x1A894,e8 47 36 05 00)
TOS.exe+0x1A894:
  call mm_cleanup_mystic

assert(TOS.exe+0x1B873,e8 68 26 05 00)
TOS.exe+0x1B873:
  call mm_cleanup_summon

// Static arte metadata: Unison duration, in frames (word at descriptor +0x56).
// Keep the Unison window open for the MA animations. These writes are enabled
// with SpellSlots; every party MA and summon uses 453 frames.
// Falcon's Crest
assert(TOS.exe+0x4DDA86,5A 00)
TOS.exe+0x4DDA86:
  dw #513
// Holy Judgement
assert(TOS.exe+0x4DE326,96 00)
TOS.exe+0x4DE326:
  dw #513
// Indignation Judgment
assert(TOS.exe+0x4DE206,50 00)
TOS.exe+0x4DE206:
  dw #513
// Sacred Light
assert(TOS.exe+0x4DD846,50 00)
TOS.exe+0x4DD846:
  dw #513
// Fairy Circle
assert(TOS.exe+0x4DE1A6,50 00)
TOS.exe+0x4DE1A6:
  dw #513
// Summon: Fire
assert(TOS.exe+0x4DDD26,50 00)
TOS.exe+0x4DDD26:
  dw #513
// Summon: Water
assert(TOS.exe+0x4DDD86,50 00)
TOS.exe+0x4DDD86:
  dw #513
// Luminous Bind
assert(TOS.exe+0x4DBE66,5A 00)
TOS.exe+0x4DBE66:
  dw #513
// Divine Judgement
assert(TOS.exe+0x4DBB06,5A 00)
TOS.exe+0x4DBB06:
  dw #513
// Infernal Ruin
assert(TOS.exe+0x4DE3E6,5A 00)
TOS.exe+0x4DE3E6:
  dw #513
// Crimson Devastation
assert(TOS.exe+0x4DE446,5A 00)
TOS.exe+0x4DE446:
  dw #513
// Fanged Finality
assert(TOS.exe+0x4DD006,5A 00)
TOS.exe+0x4DD006:
  dw #513
// Shining Bind
assert(TOS.exe+0x4DE266,5A 00)
TOS.exe+0x4DE266:
  dw #513

// Summon variant, arte 286
assert(TOS.exe+0x4DDDE6,50 00)
TOS.exe+0x4DDDE6:
  dw #513

// Summon variant, arte 290
assert(TOS.exe+0x4DDE46,50 00)
TOS.exe+0x4DDE46:
  dw #513

// Summon variant, arte 287
assert(TOS.exe+0x4DDEA6,50 00)
TOS.exe+0x4DDEA6:
  dw #513

// Summon variant, arte 288
assert(TOS.exe+0x4DDF06,50 00)
TOS.exe+0x4DDF06:
  dw #513

// Summon variant, arte 289
assert(TOS.exe+0x4DDF66,50 00)
TOS.exe+0x4DDF66:
  dw #513

// Summon variant, arte 291
assert(TOS.exe+0x4DDFC6,50 00)
TOS.exe+0x4DDFC6:
  dw #513

// Summon variant, arte 293
assert(TOS.exe+0x4DE026,50 00)
TOS.exe+0x4DE026:
  dw #513

// Summon variant, arte 292
assert(TOS.exe+0x4DE086,50 00)
TOS.exe+0x4DE086:
  dw #513

// Summon variant, arte 282
assert(TOS.exe+0x4DE0E6,50 00)
TOS.exe+0x4DE0E6:
  dw #513
