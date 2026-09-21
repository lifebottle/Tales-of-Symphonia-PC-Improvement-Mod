-- Run in 32-bit Cheat Engine against CE itself, never against the game.
-- Set SPELL_SLOTS_CT to the absolute AddSpellSlots.CT path before dofile().
assert(type(SPELL_SLOTS_CT) == 'string', 'Set SPELL_SLOTS_CT to AddSpellSlots.CT')
openProcess(getCheatEngineProcessID())
assert(not targetIs64Bit(), 'Use 32-bit Cheat Engine for this x86 test')
loadTable(SPELL_SLOTS_CT)
local script = getAddressList().getMemoryRecordByID(80000).Script
unregisterSymbol('TOS.exe')
local image = assert(allocateMemory(0x2B00000))
registerSymbol('TOS.exe', image, true)
local function bytes(text)
  local result = {}
  for b in text:gmatch('%x%x') do result[#result+1] = tonumber(b,16) end
  return result
end
local function equal(a,b)
  if #a ~= #b then return false end
  for i=1,#a do if a[i] ~= b[i] then return false end end
  return true
end
for offset, original in script:gmatch('assert%(TOS%.exe%+(%x+),([^%)]+)%)') do
  assert(writeBytes(image+tonumber(offset,16),bytes(original)))
end
local sites, patched, neighbors = {}, {}, {}
local disable = assert(script:match('%[DISABLE%](.*)'))
for offset, original in disable:gmatch('TOS%.exe%+(%x+):%s*db ([%x ,]+)') do
  local address = image+tonumber(offset,16)
  local data = bytes(original)
  sites[#sites+1] = {address=address, data=data}
  for i=0,#data-1 do patched[address+i]=true end
  for i=-8,#data+7 do neighbors[address+i]=readBytes(address+i,1,false) end
end
assert(#sites==162)
local checked, error = autoAssembleCheck(script,true,false)
assert(checked,error)
-- A wrong original byte must reject enable without publishing allocations.
local first=sites[1]
writeBytes(first.address,(first.data[1]+1)%256)
local ok=autoAssemble(script)
assert(not ok and not getAddressSafe('TOS_SPL_ARENA'))
assert(writeBytes(first.address,first.data))
local enabled,info=autoAssemble(script)
assert(enabled,info)
assert(getAddress('TOS_SPL_PARTY_SLOTS')-getAddress('TOS_SPL_ARENA')==0x403C)
assert(getAddress('TOS_SPL_ENEMY_SLOTS')-getAddress('TOS_SPL_ARENA')==0x4040)
assert(equal(readBytes(getAddress('TOS_SPL_ARENA')+0x4000,4,true),{0x53,0x50,0x4C,0x35}))
assert(readFloat('TOS_SPL_PARTY_SLOTS')==4 and readFloat('TOS_SPL_ENEMY_SLOTS')==3)
for _,site in ipairs(sites) do assert(not equal(readBytes(site.address,#site.data,true),site.data)) end
for address,value in pairs(neighbors) do
  if not patched[address] then assert(readBytes(address,1,false)==value,'Hook exceeded original width') end
end
assert(autoAssemble(script,false,info))
for _,site in ipairs(sites) do assert(equal(readBytes(site.address,#site.data,true),site.data)) end
assert(not getAddressSafe('TOS_SPL_ARENA'))
enabled,info=autoAssemble(script)
assert(enabled,info)
print('CE assembly, original-byte rejection, all 162 hook bounds/restores, and re-enable passed')

-- A stdcall wrapper permits fast local invocation of the original cdecl helpers.
local wrapper=[[
[ENABLE]
alloc(TOS_SPL_TEST_CALL,1000)
alloc(TOS_SPL_TEST_ARGS,100)
registersymbol(TOS_SPL_TEST_CALL)
registersymbol(TOS_SPL_TEST_ARGS)
TOS_SPL_TEST_CALL:
push ebp
mov ebp,esp
push ebx
mov ebx,[ebp+8]
push [ebx+10]
push [ebx+C]
push [ebx+8]
push [ebx+4]
call [ebx]
add esp,10
mov [ebx+14],eax
pop ebx
pop ebp
ret 4
[DISABLE]
unregistersymbol(TOS_SPL_TEST_CALL)
unregistersymbol(TOS_SPL_TEST_ARGS)
dealloc(TOS_SPL_TEST_CALL)
dealloc(TOS_SPL_TEST_ARGS)
]]
local wrapperOK,wrapperInfo=autoAssemble(wrapper)
assert(wrapperOK,wrapperInfo)
local call=getAddress('TOS_SPL_TEST_CALL')
local args=getAddress('TOS_SPL_TEST_ARGS')
local function invoke(fn,a,b,c,d)
  writeInteger(args,fn)
  for i,value in ipairs({a or 0,b or 0,c or 0,d or 0}) do writeInteger(args+i*4,value) end
  executeCodeLocal(call,args)
  local result=readInteger(args+0x14)
  return result==0xFFFFFFFF and -1 or result
end
local arena=getAddress('TOS_SPL_ARENA')
local choose=getAddress('TOS_SPL_choose')
local capacity=getAddress('TOS_SPL_capacity')
local prepare=getAddress('TOS_SPL_prepare_battle')
local battle=assert(allocateMemory(0x180000))
local actor=assert(allocateMemory(0x14000))
local owner=assert(allocateMemory(0x14000))
writeInteger(image+0x6D2EDC,battle)
local slots={0,1,2,6,7,8,9}
local function busy(slot)
  return slot<3 and battle+0x93EE+slot or arena+0x4080+slot-6
end
local cases=0
for party=1,4 do for enemy=1,3 do
  writeFloat('TOS_SPL_PARTY_SLOTS',party)
  writeFloat('TOS_SPL_ENEMY_SLOTS',enemy)
  assert(invoke(prepare,battle)==arena+0xD000)
  assert(readInteger(battle+0x16F950)==arena+0xD000)
  for _,slot in ipairs(slots) do
    local data=slot<3 and battle+0x15B310+slot*0xA320 or arena+0x80000+(slot-6)*0x80000
    writeInteger(data+4,1);writeInteger(data+444,owner)
    writeBytes(data+454,201,0)
  end
  for unison=0,1 do for conflict=0,1 do for mask=0,127 do for side=0,1 do
    for i,slot in ipairs(slots) do writeBytes(busy(slot),math.floor(mask/2^(i-1))%2) end
    writeBytes(battle+0x9108,unison)
    writeInteger(arena+0x4038,conflict)
    writeBytes(actor+0x1320,side)
    local candidates={side==0 and 0 or 1}
    if side==0 and unison==1 then candidates[#candidates+1]=1 end
    if side==0 and party>=2 then candidates[#candidates+1]=2 end
    if conflict==0 then
      if side==0 and party>=3 then candidates[#candidates+1]=6 end
      if side==0 and party>=4 then candidates[#candidates+1]=7 end
      if side==1 and enemy>=2 then candidates[#candidates+1]=8 end
      if side==1 and enemy>=3 then candidates[#candidates+1]=9 end
    end
    local expected=-1
    for _,slot in ipairs(candidates) do if readBytes(busy(slot),1,false)==0 then expected=slot;break end end
    assert(invoke(choose,battle,actor,201,1)==expected,'choose mismatch')
    if expected>=0 then assert(readBytes(actor+0x13AB0,1,false)==expected) end
    assert(invoke(capacity,battle,side)==(expected==-1 and 1 or 0),'capacity mismatch')
    cases=cases+1
  end end end end
  writeInteger(arena+0x4080,0xFFFFFFFF)
  assert(invoke(prepare,battle)==arena+0xD000)
  assert(readInteger(arena+0x4080)==0)
  assert(readFloat('TOS_SPL_PARTY_SLOTS')==party and readFloat('TOS_SPL_ENEMY_SLOTS')==enemy)
end end
print('CE-assembled helpers:',cases,'admission/capacity cases across 12 configurations passed')
-- Production script must refuse live removal after its buffers have been used.
local callOK,disableOK=pcall(function() return autoAssemble(script,false,info) end)
assert(not callOK or not disableOK,'Live removal was not blocked')
assert(getAddressSafe('TOS_SPL_ARENA')==arena)
-- Synthetic test memory has no game-owned resources; clear marker only for cleanup.
writeInteger(arena+0x402C,0)
writeInteger(image+0x6D2EDC,0)
assert(autoAssemble(wrapper,false,wrapperInfo))
assert(autoAssemble(script,false,info))
for _,site in ipairs(sites) do assert(equal(readBytes(site.address,#site.data,true),site.data)) end
unregisterSymbol('TOS.exe')
deAlloc(image);deAlloc(battle);deAlloc(actor);deAlloc(owner)
print('CE lifecycle guard and final restore passed; no game or DLL was used')
