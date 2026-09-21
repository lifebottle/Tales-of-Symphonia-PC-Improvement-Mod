// Runs actual x86 payloads on a synthetic image. Never loads or modifies TOS.
#include "battle_test_adapter.h"
#include <cassert>
#include <cstdio>
#include <string>
using namespace BattlePatches;

// Preserve the test caller's registers; supply the game's hook register context.
struct Registers { void* entry; uint32_t eax, ebx, ecx, edx, esi, edi, flags; };
extern "C" void Invoke(Registers*);
__asm__(
    ".intel_syntax noprefix\n"
    ".text\n.global _Invoke\n_Invoke:\n"
    "pushad\nmov ebp, [esp+36]\n"
    "mov eax,[ebp+4]\nmov ebx,[ebp+8]\nmov ecx,[ebp+12]\n"
    "mov edx,[ebp+16]\nmov esi,[ebp+20]\nmov edi,[ebp+24]\n"
    "call DWORD PTR [ebp]\n"
    "mov [ebp+4],eax\nmov [ebp+8],ebx\nmov [ebp+12],ecx\n"
    "mov [ebp+16],edx\nmov [ebp+20],esi\nmov [ebp+24],edi\n"
    "pushfd\npop DWORD PTR [ebp+28]\npopad\nret\n.att_syntax prefix\n");

// A continuation that measures and repairs the hook stack before returning.
// Unlike a RET stub, this reports an unbalanced path instead of jumping through
// a leftover saved register. EBP points at the harness throughout these hooks.
struct CheckedRegisters { Registers registers; uint32_t stack; int32_t delta; uint32_t exit; };
extern "C" void InvokeChecked(CheckedRegisters*);
extern "C" void FinishChecked();
__asm__(
    ".intel_syntax noprefix\n.text\n.global _InvokeChecked\n_InvokeChecked:\n"
    "pushad\nmov ebp,[esp+36]\nmov [ebp+32],esp\n"
    "mov eax,[ebp+4]\nmov ebx,[ebp+8]\nmov ecx,[ebp+12]\n"
    "mov edx,[ebp+16]\nmov esi,[ebp+20]\nmov edi,[ebp+24]\n"
    "call DWORD PTR [ebp]\nud2\n"
    ".global _FinishChecked\n_FinishChecked:\n"
    "pushfd\npop DWORD PTR [ebp+28]\n"
    "mov [ebp+4],eax\nmov [ebp+8],ebx\nmov [ebp+12],ecx\n"
    "mov [ebp+16],edx\nmov [ebp+20],esi\nmov [ebp+24],edi\n"
    "mov eax,esp\nsub eax,[ebp+32]\nadd eax,4\nmov [ebp+36],eax\n"
    "mov esp,[ebp+32]\npopad\nret\n.att_syntax prefix\n");

uint32_t Address(const void* p) { return static_cast<uint32_t>(reinterpret_cast<uintptr_t>(p)); }
uint32_t Read32(const void* p) { uint32_t v; std::memcpy(&v, p, 4); return v; }
void Put32(void* p, uint32_t v) { std::memcpy(p, &v, 4); }
void Put16(void* p, uint16_t v) { std::memcpy(p, &v, 2); }
uint16_t Read16(const void* p) { uint16_t v; std::memcpy(&v, p, 2); return v; }

struct Image {
    uint8_t* bytes = static_cast<uint8_t*>(VirtualAlloc(nullptr, Data::ImageSize,
        MEM_RESERVE | MEM_COMMIT, PAGE_EXECUTE_READWRITE));
    Image() {
        assert(bytes);
        bytes[0x8073a] = 0x33; // First untouched byte after the victory-drain branch.
        for (const auto& s : Data::Segments)
            if (s.kind == Data::Kind::Patch) std::memcpy(bytes + s.rva, Data::Bytes + s.expected, s.count);
        for (const auto& g : Data::Guards) std::memcpy(bytes + g.rva, Data::Bytes + g.bytes, g.count);
    }
    ~Image() { VirtualFree(bytes, 0, MEM_RELEASE); }
    void ReadOnlyCode() {
        DWORD old;
        assert(VirtualProtect(bytes, Data::ImageSize, PAGE_EXECUTE_READ, &old));
    }
};

// Recover installed arena addresses from the same relocations the CPU executes.
// This catches incorrect absolute/relative relocation math independently.
std::vector<uint8_t*> Resolve(Image& image, uint32_t enabled) {
    std::vector<uint8_t*> addresses(SegmentCount);
    for (size_t i = 0; i < SegmentCount; ++i)
        if ((Data::Segments[i].group & enabled) && Data::Segments[i].kind == Data::Kind::Patch)
            addresses[i] = image.bytes + Data::Segments[i].rva;
    for (size_t pass = 0; pass < SegmentCount; ++pass) {
        for (const auto& f : Data::Fixups) {
            if (!addresses[f.owner]) continue;
            const auto* place = addresses[f.owner] + f.offset;
            uint32_t value = f.type == 23 ? static_cast<int8_t>(*place) : Read32(place);
            if (f.type != 1) value += Address(place);
            value -= f.addend;
            if (f.target < 0) assert(value == Address(image.bytes));
            else if (addresses[f.target]) assert(value == Address(addresses[f.target]));
            else addresses[f.target] = reinterpret_cast<uint8_t*>(static_cast<uintptr_t>(value));
        }
    }
    return addresses;
}

void Combinations() {
    for (uint32_t requested = 0; requested < 32; ++requested) {
        Image image;
        image.ReadOnlyCode();
        const auto enabled = Dependencies(requested);
        assert(Install(image.bytes, Data::ImageSize, {requested, 0.25f}));
        for (const auto& s : Data::Segments) {
            if (s.kind != Data::Kind::Patch) continue;
            const bool changed = std::memcmp(image.bytes + s.rva, Data::Bytes + s.expected, s.count) != 0;
            assert(changed == bool(enabled & s.group));
            MEMORY_BASIC_INFORMATION info{};
            assert(VirtualQuery(image.bytes + s.rva, &info, sizeof(info)));
            assert(info.Protect == PAGE_EXECUTE_READ);
        }
        auto addresses = Resolve(image, enabled);
        for (size_t i = 0; i < SegmentCount; ++i) {
            if (!addresses[i] || Data::Segments[i].kind == Data::Kind::Patch) continue;
            MEMORY_BASIC_INFORMATION info{};
            assert(VirtualQuery(addresses[i], &info, sizeof(info)));
            assert(info.Protect == (Data::Segments[i].kind == Data::Kind::Code ? PAGE_EXECUTE_READ : PAGE_READWRITE));
        }
        if (enabled & NewFreeRun) {
            float penalty;
            std::memcpy(&penalty, addresses[Data::PenaltySegment], 4);
            assert(penalty == 0.25f);
        }
        if (enabled & ManualOverLimit) {
            assert(image.bytes[0x80738] == 0xeb && image.bytes[0x80739] == 9);
            assert(image.bytes[0x8073a] == 0x33); // No partial overwrite of next instruction.
        } else {
            assert(image.bytes[0x80738] == 0x75 && image.bytes[0x80739] == 9);
        }
    }
}

void Rejection() {
    // Every original instruction and independent target guard must fail closed.
    for (const auto& s : Data::Segments) {
        if (s.kind != Data::Kind::Patch) continue;
        Image image;
        image.bytes[s.rva] ^= 1;
        std::vector<uint8_t> before(image.bytes, image.bytes + Data::ImageSize);
        assert(!Install(image.bytes, Data::ImageSize, {31, 0.15f}));
        assert(!std::memcmp(before.data(), image.bytes, before.size()));
    }
    for (const auto& g : Data::Guards) {
        Image image;
        image.bytes[g.rva] ^= 1;
        std::vector<uint8_t> before(image.bytes, image.bytes + Data::ImageSize);
        assert(!Install(image.bytes, Data::ImageSize, {31, 0.15f}));
        assert(!std::memcmp(before.data(), image.bytes, before.size()));
    }
    Image image;
    assert(!Install(image.bytes, 1024, {31, 0.15f}));
    assert(Install(image.bytes, Data::ImageSize, {31, 0.15f}));
    assert(!Install(image.bytes, Data::ImageSize, {31, 0.15f}));
}

void ExecuteHooks() {
    Image image;
    assert(Install(image.bytes, Data::ImageSize, {31, 0.15f}));
    auto addresses = Resolve(image, 31);
    auto* controls = addresses[Data::ControlsSegment];
    uint8_t save[0x1200]{};
    std::vector<uint8_t> actor(0x14000);
    uint8_t input[64]{};
    // Return to the harness at each original code continuation/exit.
    for (uint32_t rva : {0x211a78u, 0x64561u, 0x64571u, 0x39132u, 0x3944eu,
                         0x7679cu, 0x84d1eu}) image.bytes[rva] = 0xc3;
    FlushInstructionCache(GetCurrentProcess(), image.bytes, Data::ImageSize);
    Registers r{image.bytes + 0x211a73, 0, Address(image.bytes + 0xa2de20), 0x1234,
                0, Address(input), 0, 0};
    Invoke(&r); // No save-data pointer yet: original input behavior, no crash.
    assert(Read32(input + 0x10) == 0x1234 && r.edx == 0x1234);
    Put32(image.bytes + 0x6d3f68, Address(save));
    save[0xf4d] = 1;
    r.ecx = 0x400; // LT held; one controller only.
    Invoke(&r);
    assert(controls[10] == 1 && controls[26] == 0);
    r.ebx = Address(image.bytes + 0xa2de20);
    Invoke(&r);
    assert(controls[10] == 2);
    r.ecx = 0;
    r.ebx = Address(image.bytes + 0xa2de20);
    Invoke(&r);
    assert(controls[10] == 0);
    // Switching saves must use the new base, not a pointer captured at startup.
    uint8_t secondSave[0x1200]{};
    secondSave[0xf4d] = 1;
    Put32(image.bytes + 0x6d3f68, Address(secondSave));
    r.ecx = 0x100;
    r.ebx = Address(image.bytes + 0xa2de20);
    Invoke(&r);
    assert(controls[8] == 1);
    // Exercise real Main/Sub page swapping against the newly loaded save.
    image.bytes[0x124da1] = 0xc3; // Artes-menu-enter continuation.
    image.bytes[0x12e5b0] = 0xc3; // Stub only the game's sound routine.
    FlushInstructionCache(GetCurrentProcess(), image.bytes, Data::ImageSize);
    Registers menu{image.bytes + 0x124d98, 0, 0, 0, 0, 0, 0, 0};
    Invoke(&menu);
    Put16(image.bytes + 0x713ab0, 2); // Cursor in arte-slot area.
    std::memset(secondSave + 0x440, 0x11, 14);
    std::memset(secondSave + 0x114, 0x22, 14);
    r.ebx = Address(image.bytes + 0xa2de20);
    r.ecx = 0; // First menu frame establishes the current character page.
    Invoke(&r);
    r.ebx = Address(image.bytes + 0xa2de20);
    r.ecx = 0x20; // Fresh Select/Back press.
    Invoke(&r);
    for (size_t i = 0; i < 14; ++i) {
        assert(secondSave[0x440 + i] == 0x22);
        assert(secondSave[0x114 + i] == 0x11);
        assert(save[0x440 + i] == 0); // Old save untouched.
    }
    assert(Read16(secondSave + 0x192) == 1); // Persisted active-page mask.
    r.ebx = Address(image.bytes + 0xa2de20);
    r.ecx = 0; // Release, then press to swap back.
    Invoke(&r);
    r.ebx = Address(image.bytes + 0xa2de20);
    r.ecx = 0x20;
    Invoke(&r);
    assert(secondSave[0x440] == 0x11 && secondSave[0x114] == 0x22);
    assert(Read16(secondSave + 0x192) == 0);
    // Out-of-range controller pointer bypasses arrays instead of corrupting state.
    r.ebx = Address(image.bytes + 0xa2df20);
    r.ecx = 0x55;
    Invoke(&r);
    assert(Read32(input + 0x10) == 0x55);

    uint8_t attack[32]{};
    actor[0x1322] = 1;
    r = {image.bytes + 0x6455c, 0x12345678, 0x87654321, Address(attack),
         0xffffffff, Address(actor.data()), 0, 0};
    Put16(attack + 0xe, 800);
    Put16(actor.data() + 0x134c, 20);
    Invoke(&r); // EDX deliberately nonzero: division must not fault.
    assert(Read16(actor.data() + 0x134c) == 120);
    assert(r.eax == 0x12345678 && r.ebx == 0x87654321 && r.edx == 0xffffffff);
    Put16(attack + 0xe, 0);
    Invoke(&r);
    assert(Read16(actor.data() + 0x134c) == 130); // Minimum gain is ten.
    Put16(actor.data() + 0x134c, 999);
    Invoke(&r);
    assert(Read16(actor.data() + 0x134c) == 1000);
    actor[0x1321] = 0x80; // Already in Over Limit: no additional gain.
    Put16(actor.data() + 0x134c, 100);
    Invoke(&r);
    assert(Read16(actor.data() + 0x134c) == 100);
    actor[0x1321] = 0;
    actor[0x1320] = 0x44; // Live human mode (1), plus an unrelated flag.
    r = {image.bytes + 0x3912c, 0, 0, 0, 0, 0, Address(actor.data()), 0};
    controls[11] = 0;
    Invoke(&r);
    assert((r.ecx & 0xff) == 0); // No RT press: bypass activation.
    controls[11] = 1;
    Invoke(&r);
    assert((r.ecx & 0xff) == 0x44); // Fresh RT press: execute the original gate.
    controls[11] = 2;
    r.ecx = 0;
    Invoke(&r);
    assert((r.ecx & 0xff) == 0); // Held trigger is not another activation.
    // Free Run stick test preserves EDX and returns the expected condition flags.
    Put32(image.bytes + 0x6d37a8, 0);
    r = {image.bytes + 0x76794, 0, 0, 0, 0, 0, Address(actor.data()), 0};
    controls[10] = 0;
    Invoke(&r);
    assert(r.flags & 0x40);
    controls[10] = 1;
    Invoke(&r);
    assert(!(r.flags & 0x40) && r.edx == 0);

    // Execute camera-relative Free Run movement, substituting FPATAN only for
    // the game's math helper. Its real destination is separately fingerprinted.
    image.bytes[0x84ccf] = 0xc3;
    image.bytes[0x84cd4] = 0xc3;
    image.bytes[0x2e7ce4] = 0xd9;
    image.bytes[0x2e7ce5] = 0xf3; // fpatan
    image.bytes[0x2e7ce6] = 0xc3;
    FlushInstructionCache(GetCurrentProcess(), image.bytes, Data::ImageSize);
    uint8_t stats[256]{}, camera[128]{};
    Put32(actor.data(), Address(stats));
    Put32(image.bytes + 0x6d2edc, Address(camera));
    Put16(image.bytes + 0x6d3770, 72);
    Put16(image.bytes + 0x6d3772, 0);
    float vector[3]{};
    r = {image.bytes + 0x84cc9, 0, Address(actor.data()), 0, 0, Address(vector), 0, 0};
    controls[10] = 1;
    Invoke(&r);
    float speed;
    std::memcpy(&speed, actor.data() + 0x12ec, 4);
    assert(std::fabs(speed - 0.85f) < 0.0001f);
    assert(std::fabs(vector[0]*vector[0] + vector[2]*vector[2] - 1.0f) < 0.001f);
    const float firstX = vector[0], firstZ = vector[2];
    const float yaw = 90;
    std::memcpy(camera + 0x50, &yaw, 4);
    stats[0xee] = 6; // Dash EX skill.
    Invoke(&r);
    std::memcpy(&speed, actor.data() + 0x12ec, 4);
    assert(std::fabs(speed - 1.0f) < 0.0001f);
    assert(std::fabs(vector[0]*firstX + vector[2]*firstZ) < 0.001f);
    controls[10] = 0;
    Invoke(&r);
    std::memcpy(&speed, actor.data() + 0x12ec, 4);
    assert(std::fabs(speed - 1.15f) < 0.0001f);
}

void ArtesBattleRegression() {
    Image image;
    assert(Install(image.bytes, Data::ImageSize, {ArtesSphere, 0.15f}));
    auto addresses = Resolve(image, ArtesSphere);
    auto* charBuffer = addresses[Data::CharBufferSegment];
    uint8_t save[0x1200]{}, input[64]{};
    std::vector<uint8_t> actor(0x14000), battle(0x9400);
    Put32(image.bytes + 0x6d3f68, Address(save));
    image.bytes[0x718652] = 1; // In battle.
    // Stub continuations record which branch was taken and capture flags/stack.
    auto finish = [&](uint32_t rva) {
        auto* p = image.bytes + rva;
        p[0] = 0xc7; p[1] = 0x45; p[2] = 40; // mov [ebp+40], rva
        Put32(p + 3, rva);
        p[7] = 0xe9;
        Put32(p + 8, Address(reinterpret_cast<void*>(&FinishChecked)) - Address(p + 12));
    };
    for (auto rva : {0x211a78u, 0x75d32u, 0x75d4fu, 0x346abu, 0x346e9u,
                     0x75a25u, 0x75a7bu, 0x75d48u, 0x76131u, 0x346c7u,
                     0x34819u, 0x75a67u}) finish(rva);
    FlushInstructionCache(GetCurrentProcess(), image.bytes, Data::ImageSize);
    int failures = 0;
    auto check = [&](bool ok, const char* what, unsigned controller, unsigned id, uint32_t binding) {
        if (!ok && failures++ < 20)
            std::printf("Artes regression: %s (controller=%u char=%u binding=%x)\n", what, controller, id, binding);
    };
    for (unsigned controller = 0; controller < 4; ++controller) {
        for (unsigned id = 1; id <= 9; ++id) {
            std::memset(save, 0, sizeof(save));
            save[0xf4d + controller] = static_cast<uint8_t>(id);
            auto* main = save + 0x368 + (id - 1)*0x118;
            auto* sub = save + 0x114 + (id - 1)*14;
            for (unsigned slot = 0; slot < 4; ++slot) {
                Put16(main + 0xd8 + slot*2, static_cast<uint16_t>(100 + slot));
                Put16(sub + slot*2, static_cast<uint16_t>(200 + slot));
            }
            actor[0x1321] = static_cast<uint8_t>(controller);
            actor[0x1322] = static_cast<uint8_t>(id);
            Put32(actor.data(), Address(main));
            for (uint32_t binding : {0x2000u, 0x1000u, 0x4000u}) {
                Put32(battle.data() + 0x9070, binding);
                for (bool held : {false, true, false}) {
                    // Real input hook captures L1 before masking it out of vanilla actions.
                    CheckedRegisters inputCall{{image.bytes + 0x211a73, 0,
                        Address(image.bytes + 0xa2de20 + controller*0x40),
                        binding | (held ? 0x100u : 0u), 0, Address(input), 0, 0}, 0, 0, 0};
                    InvokeChecked(&inputCall);
                    check(inputCall.delta == 0, "input stack", controller, id, binding);
                    check(bool(addresses[Data::ControlsSegment][controller*16+8]) == held,
                          "L1 tracking", controller, id, binding);
                    for (unsigned phase = 0; phase < 3; ++phase) {
                        const uint32_t entry[] = {0x75d2c, 0x346a5, 0x75a1f};
                        const uint32_t cont[] = {0x75d32, 0x346ab, 0x75a25};
                        uint32_t buttons = binding;
                        Put16(charBuffer, held ? 0 : uint16_t(1u << (id - 1)));
                        CheckedRegisters buffer{{image.bytes + entry[phase],
                            phase == 2 ? 0u : Address(battle.data()), 0x12345678,
                            phase == 2 ? Address(battle.data()) : binding,
                            phase == 2 ? Address(&buttons) : binding,
                            Address(actor.data()), Address(actor.data()), 0}, 0, 0, 0};
                        InvokeChecked(&buffer);
                        check(buffer.delta == 0 && buffer.exit == cont[phase],
                              "configured arte button reaches selection", controller, id, binding);
                        check(bool(Read16(charBuffer) & (1u << (id - 1))) == held,
                              "Main/Sub latch", controller, id, binding);
                        // For default mapping, exercise the real check/use hooks too.
                        if (buffer.exit != cont[phase]) continue;
                        for (unsigned slot = 0; slot < 4; ++slot) {
                            if (phase != 2) {
                                const uint32_t site = phase == 0 ? 0x75d3f : 0x346be;
                                CheckedRegisters exists{{image.bytes + site, 0x12345678,
                                    phase == 0 ? Address(main) : 0x12345678, slot, Address(main),
                                    Address(actor.data()), Address(actor.data()), 0}, 0, 0, 0};
                                const auto savedEBX = exists.registers.ebx;
                                InvokeChecked(&exists);
                                check(exists.delta == 0 && exists.registers.ebx == savedEBX,
                                      "arte check preserves stack/EBX", controller, id, binding);
                                check(!(exists.registers.flags & 0x40), "assigned arte exists", controller, id, binding);
                            }
                            const uint32_t uses[] = {0x76129, 0x34811, 0x75a5f};
                            CheckedRegisters use{{image.bytes + uses[phase],
                                phase == 1 ? Address(main) : 0u, 0x12345678, slot,
                                phase == 1 ? slot : Address(main),
                                Address(actor.data()), Address(actor.data()), 0}, 0, 0, 0};
                            InvokeChecked(&use);
                            check(use.delta == 0, "arte use stack", controller, id, binding);
                            const auto arte = phase == 1 ? use.registers.ebx : use.registers.eax;
                            check(arte == (held ? 200 : 100) + slot, "correct Main/Sub arte", controller, id, binding);
                        }
                    }
                }
            }
        }
    }
    std::printf("Artes battle regression failures: %d\n", failures);
    assert(failures == 0);
}

void ArtesShortcutRegression() {
    Image image;
    assert(Install(image.bytes, Data::ImageSize, {ArtesSphere, 0.15f}));
    auto addresses = Resolve(image, ArtesSphere);
    auto* controls = addresses[Data::ControlsSegment];
    auto* charBuffer = addresses[Data::CharBufferSegment];
    uint8_t save[0x1200]{};
    std::vector<uint8_t> owner(0x14000), unrelated(0x14000), selected(0x14000);
    Put32(image.bytes + 0x6d3f68, Address(save));
    auto* main = save + 0x368;
    auto* sub = save + 0x114;
    owner[0x1321] = 0;
    owner[0x1322] = 1;
    unrelated[0x1321] = 1;
    unrelated[0x1322] = 2;
    selected[0x1321] = 2;
    selected[0x1322] = 3;
    main[0xe4] = 3;
    sub[0xc] = 4;
    Put16(main + 0xe0, 101);
    Put16(sub + 8, 201);
    for (auto rva : {0x751e0u, 0x751edu}) {
        auto* p = image.bytes + rva;
        p[0] = 0xe9;
        Put32(p + 1, Address(reinterpret_cast<void*>(&FinishChecked)) - Address(p + 5));
    }
    FlushInstructionCache(GetCurrentProcess(), image.bytes, Data::ImageSize);
    for (bool held : {false, true, false}) {
        controls[8] = held;
        controls[24] = 0;
        controls[40] = !held; // Target's controller must not choose the source page.
        Put16(charBuffer, 0);
        // At +751d9 EAX/EBP+8 identify the owner. ESI has not yet been assigned;
        // the original game fills it with the selected character *after* +751e6.
        CheckedRegisters command{{image.bytes + 0x751d9, Address(owner.data()),
            Address(owner.data()), 0, 0x12345678, Address(unrelated.data()), Address(main), 0}, 0, 0, 0};
        InvokeChecked(&command);
        assert(command.delta == 0);
        assert(command.registers.ecx == (held ? 4u : 3u));
        assert(bool(Read16(charBuffer) & 1) == held);
        CheckedRegisters arte{{image.bytes + 0x751e6, Address(selected.data()),
            Address(owner.data()), 0, 0x12345678, Address(unrelated.data()), command.registers.edi, 0}, 0, 0, 0};
        InvokeChecked(&arte);
        assert(arte.delta == 0);
        assert(arte.registers.edi == (held ? 201u : 101u));
        assert(arte.registers.eax == Address(selected.data()));
    }
}

void RightStickLayerRegression() {
    Image image;
    assert(Install(image.bytes, Data::ImageSize, {ArtesSphere, 0.15f}));
    auto addresses = Resolve(image, ArtesSphere);
    auto* charBuffer = addresses[Data::CharBufferSegment];
    uint8_t save[0x1200]{}, input[64]{}, stick[64]{};
    std::vector<uint8_t> actor(0x14000), battle(0x9400);
    Put32(image.bytes + 0x6d3f68, Address(save));
    image.bytes[0x718652] = 1;
    auto finish = [&](uint32_t rva) {
        auto* p = image.bytes + rva;
        p[0] = 0xe9;
        Put32(p+1, Address(reinterpret_cast<void*>(&FinishChecked)) - Address(p+5));
    };
    for (auto rva : {0x211a78u, 0x211acau, 0x75d34u, 0x75d4fu, 0x346abu,
                     0x346e9u, 0x75a27u, 0x75a7bu, 0x75d68u, 0x75d88u,
                     0x76155u, 0x76196u, 0x34702u, 0x34723u, 0x34714u,
                     0x34735u, 0x75aa5u, 0x75adbu, 0x75ab6u, 0x75afbu}) finish(rva);
    // Preserve the real instructions after the first/air buffer hook: shortcut
    // input must refresh the layer without becoming a face-button arte request.
    image.bytes[0x75d32] = 0x23; image.bytes[0x75d33] = 0xf2; // and esi,edx
    image.bytes[0x75a25] = 0x85; image.bytes[0x75a26] = 0x02; // test [edx],eax
    FlushInstructionCache(GetCurrentProcess(), image.bytes, Data::ImageSize);
    int failures = 0;
    auto check = [&](bool ok) { if (!ok) ++failures; };
    for (unsigned controller = 0; controller < 4; ++controller)
    for (unsigned id = 1; id <= 9; ++id)
    for (uint32_t binding : {0x2000u, 0x1000u, 0x4000u})
    for (unsigned phase = 0; phase < 3; ++phase)
    for (unsigned direction = 0; direction < 2; ++direction) {
        auto* main = save + 0x368 + (id-1)*0x118;
        auto* sub = save + 0x114 + (id-1)*14;
        actor[0x1321] = static_cast<uint8_t>(controller);
        actor[0x1322] = static_cast<uint8_t>(id);
        save[0xf4d+controller] = static_cast<uint8_t>(id);
        Put32(actor.data(), Address(main));
        Put32(battle.data()+0x9070, binding);
        // Only the chosen layer assigns the shortcut to this character; the
        // other layer targets someone else and has a different arte.
        const auto mask = static_cast<uint16_t>(1u << (id-1));
        Put16(charBuffer, static_cast<uint16_t>(0x1ff ^ mask));
        for (bool held : {true, false, true, true, false, false}) {
            main[0xe4+direction] = static_cast<uint8_t>(held ? (id%9)+1 : id);
            sub[0xc+direction] = static_cast<uint8_t>(held ? id : (id%9)+1);
            Put16(main+0xe0+direction*2, static_cast<uint16_t>(101+direction));
            Put16(sub+8+direction*2, static_cast<uint16_t>(201+direction));
            CheckedRegisters inputCall{{image.bytes+0x211a73,0,
                Address(image.bytes+0xa2de20+controller*0x40),held ? 0x100u : 0u,
                0,Address(input),0,0},0,0,0};
            InvokeChecked(&inputCall);
            check(inputCall.delta == 0);
            // Real right-stick mapping produces the shortcut bits after the
            // input hook captured L1; neither face button nor LT/RT is pressed.
            CheckedRegisters remap{{image.bytes+0x211ac4,Address(stick),0,Address(stick),
                direction == 0 ? 32767u : static_cast<uint32_t>(-32767),
                Address(input),0,0},0,0,0};
            InvokeChecked(&remap);
            const uint32_t buttons = Read32(input+0x10);
            check(remap.delta == 0 && buttons == (direction == 0 ? 0x800u : 0x400u));
            const uint32_t entry[] = {0x75d2c,0x346a5,0x75a1f};
            CheckedRegisters buffer{{image.bytes+entry[phase],
                phase == 2 ? 0u : Address(battle.data()),0x12345678,
                phase == 2 ? Address(battle.data()) : buttons,
                phase == 2 ? Address(&buttons) : buttons,
                Address(actor.data()),Address(actor.data()),0},0,0,0};
            InvokeChecked(&buffer);
            check(buffer.delta == 0 && (buffer.registers.flags & 0x40));
            check(Read16(charBuffer) == static_cast<uint16_t>((0x1ff ^ mask) | (held ? mask : 0)));
            const uint32_t targetChecks[][2] = {{0x75d62,0x75d82},{0x346fc,0x3471d},{0x75a9f,0x75ad5}};
            CheckedRegisters target{{image.bytes+targetChecks[phase][direction],Address(main),
                phase == 0 ? Address(main) : id,id,id,
                Address(actor.data()),Address(actor.data()),0},0,0,0};
            InvokeChecked(&target);
            check(target.delta == 0 && (target.registers.flags & 0x40));
            const uint32_t uses[][2] = {{0x7614e,0x7618f},{0x3470c,0x3472d},{0x75aaf,0x75af4}};
            CheckedRegisters use{{image.bytes+uses[phase][direction],Address(main),0x12345678,0,0,
                Address(actor.data()),Address(actor.data()),0},0,0,0};
            if (phase == 1) { // Combo queues a shortcut only if this layer has an arte.
                Put16(main+0xe0+direction*2, held ? 0 : 101);
                Put16(sub+8+direction*2, held ? 201 : 0);
            }
            InvokeChecked(&use);
            check(use.delta == 0 && use.registers.ebx == 0x12345678);
            if (phase == 1) check(!(use.registers.flags & 0x40));
            else check((phase == 0 ? use.registers.esi : use.registers.eax) ==
                       (held ? 201u : 101u)+direction);
        }
    }
    std::printf("Right-stick layer regression failures: %d\n", failures);
    assert(failures == 0);
}

void ManualOverLimitRegression() {
    Image image;
    // Actual +3911a..+39176 game instructions: gauge comparison, our hook,
    // party-limit check, Sheena flag update, and the Over Limit state write.
    const uint8_t activation[] = {
        0xba,0xe8,0x03,0x00,0x00,0x66,0x39,0x97,0x4c,0x13,0x00,0x00,0x0f,0x8c,0x22,0x03,
        0x00,0x00,0x8a,0x8f,0x20,0x13,0x00,0x00,0x80,0xe1,0x01,0xe8,0x96,0xfe,0xff,0xff,
        0x85,0xc0,0x0f,0x85,0x0c,0x03,0x00,0x00,0x8a,0x87,0x22,0x13,0x00,0x00,0x24,0x0f,
        0x3c,0x05,0x75,0x13,0x8b,0x07,0x81,0x88,0x80,0x00,0x00,0x00,0x00,0x00,0x00,0xfc,
        0x83,0x88,0x84,0x00,0x00,0x00,0x1f,0x8a,0x8f,0x21,0x13,0x00,0x00,0x80,0xe1,0x1f,
        0x80,0xc9,0x80,0x6a,0x3b,0x8b,0xc7,0x88,0x8f,0x21,0x13,0x00,0x00,
    };
    static_assert(sizeof(activation) == 0x5d);
    std::memcpy(image.bytes + 0x3911a, activation, sizeof(activation));
    assert(Install(image.bytes, Data::ImageSize, {ManualOverLimit, 0.15f}));
    auto addresses = Resolve(image, Dependencies(ManualOverLimit));
    auto* controls = addresses[Data::ControlsSegment];
    uint8_t save[0x1200]{};
    std::vector<uint8_t> actor(0x14000);
    Put32(image.bytes + 0x6d3f68, Address(save));
    Put32(actor.data(), Address(save + 0x368));
    // Replace only the game's party-count helper and the exits after the tested
    // state transition. Leave its real gauge condition and activation store intact.
    image.bytes[0x38fd0] = 0x31; image.bytes[0x38fd1] = 0xc0; image.bytes[0x38fd2] = 0xc3;
    auto finish = [&](uint32_t rva, bool hasEffectArgument) {
        auto* p = image.bytes + rva;
        if (hasEffectArgument) { // The game pushed its upcoming effect argument.
            p[0]=0x8d; p[1]=0x64; p[2]=0x24; p[3]=4; p += 4;
        }
        p[0]=0xe9;
        Put32(p+1, Address(reinterpret_cast<void*>(&FinishChecked)) - Address(p+5));
    };
    finish(0x39177, true);
    finish(0x3944e, false);
    FlushInstructionCache(GetCurrentProcess(), image.bytes, Data::ImageSize);
    int failures = 0;
    for (unsigned id = 0; id <= 9; ++id)
    for (unsigned slot = 0; slot < 4; ++slot)
    for (unsigned side = 0; side < 2; ++side)
    for (unsigned liveMode = 0; liveMode < 8; ++liveMode)
    for (unsigned savedMode = 0; savedMode < 3; ++savedMode)
    for (unsigned gauge : {999u,1000u,1001u})
    for (unsigned press : {0u,1u,2u,255u}) {
        save[0xf55+slot] = static_cast<uint8_t>(savedMode);
        actor[0x1320] = static_cast<uint8_t>(0xe0 | (liveMode << 2) | side);
        actor[0x1321] = static_cast<uint8_t>(0x60 | slot); // Game's ready state.
        actor[0x1322] = static_cast<uint8_t>(id);
        Put16(actor.data()+0x134c, static_cast<uint16_t>(gauge));
        std::memset(controls,0,64);
        controls[slot*16+11] = static_cast<uint8_t>(press);
        // Another controller's new press must never activate this character.
        controls[((slot+1)%4)*16+11] = 1;
        CheckedRegisters call{{image.bytes+0x3911a,0,0,0,0,0,Address(actor.data()),0},0,0,0};
        InvokeChecked(&call);
        const bool expected = gauge >= 1000 && (id == 0 || side == 1 || liveMode >= 2 || press == 1);
        const bool active = (actor[0x1321]&0xe0) == 0x80;
        if (active != expected || call.delta != 0) {
            if (failures++ < 8) std::printf("Manual OL failure: id=%u slot=%u side=%u live=%u saved=%u gauge=%u press=%u active=%d\n",
                id,slot,side,liveMode,savedMode,gauge,press,active);
        }
        assert(Read16(actor.data()+0x134c) == gauge);
    }
    std::printf("Manual Over Limit regression failures: %d\n", failures);
    assert(failures == 0);
}

void Config() {
    wchar_t temporary[MAX_PATH], filename[MAX_PATH];
    assert(GetTempPathW(MAX_PATH, temporary));
    assert(GetTempFileNameW(temporary, L"tos", 0, filename));
    auto options = ReadOptions(filename);
    assert(options.enabled == 0 && std::fabs(options.penalty - 0.20f) < 0.00001f);
    // The obsolete key cannot opt into or out of the merged victory-drain patch.
    WritePrivateProfileStringW(L"BattleEnhancements", L"DisableOvLVictoryDrain", L"0", filename);
    WritePrivateProfileStringW(L"BattleEnhancements", L"ManualOverLimit", L"1", filename);
    assert(ReadOptions(filename).enabled == (ManualOverLimit | ArtesSphere));
    WritePrivateProfileStringW(L"BattleEnhancements", L"DisableOvLVictoryDrain", L"1", filename);
    WritePrivateProfileStringW(L"BattleEnhancements", L"ManualOverLimit", L"0", filename);
    assert(ReadOptions(filename).enabled == 0);
    WritePrivateProfileStringW(L"BattleEnhancements", L"NewFreeRun", L"1", filename);
    WritePrivateProfileStringW(L"BattleEnhancements", L"FreeRunMovementPenalty", L"0.2", filename);
    options = ReadOptions(filename);
    assert(options.enabled == (NewFreeRun | ArtesSphere) && std::fabs(options.penalty - 0.2f) < 0.00001f);
    WritePrivateProfileStringW(L"BattleEnhancements", L"NewFreeRun", L"garbage", filename);
    WritePrivateProfileStringW(L"BattleEnhancements", L"FreeRunMovementPenalty", L"nan", filename);
    options = ReadOptions(filename);
    assert(options.enabled == 0 && std::fabs(options.penalty - 0.20f) < 0.00001f);
    assert(DeleteFileW(filename));
}

int main() {
    RightStickLayerRegression();
    ManualOverLimitRegression();
    ArtesBattleRegression();
    ArtesShortcutRegression();
    Config();
    Combinations();
    Rejection();
    ExecuteHooks();
    std::puts("Battle patch tests passed: 32 configurations, 65 sites, original-byte and destination guards, native hooks and config.");
}
