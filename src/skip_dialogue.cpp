#include "skip_dialogue.h"
#include "logger.h"
#include <windows.h>
#include <asmjit/x86.h>
#include <cstdlib>
#include <stdexcept>

namespace FastForward::DialogueSkip {
namespace {
alignas(4) volatile LONG active = 0;

std::vector<uint8_t> HexBytes(const char* hex) {
    std::vector<uint8_t> result;
    while (*hex) {
        const char pair[] = {hex[0], hex[1], 0};
        result.push_back(static_cast<uint8_t>(std::strtoul(pair, nullptr, 16)));
        hex += 2;
    }
    return result;
}
uint32_t Append(PatchFramework::Definition& d, const std::vector<uint8_t>& bytes) {
    const auto offset = static_cast<uint32_t>(d.bytes.size());
    d.bytes.insert(d.bytes.end(), bytes.begin(), bytes.end());
    return offset;
}
void Guard(PatchFramework::Definition& d, uint32_t rva, const char* hex) {
    const auto bytes = HexBytes(hex);
    d.guards.push_back({1, rva, Append(d, bytes), uint32_t(bytes.size())});
}
void Hook(PatchFramework::Definition& d, const char* name, uint32_t site, const char* expected,
          uint32_t nativeReturn, uint32_t skipReturn, uint32_t mask, bool speed, bool inputA = false) {
    asmjit::CodeHolder holder;
    if (holder.init(asmjit::Environment(asmjit::Arch::kX86)) != asmjit::Error::kOk)
        throw std::runtime_error("Cannot initialize dialogue hook assembler");
    struct Errors : asmjit::ErrorHandler {
        void handle_error(asmjit::Error, const char* message, asmjit::BaseEmitter*) override {
            throw std::runtime_error(message);
        }
    } errors;
    holder.set_error_handler(&errors);
    asmjit::x86::Assembler a(&holder);
    using namespace asmjit::x86;
    const auto native = a.new_label();
    a.cmp(dword_ptr(reinterpret_cast<uintptr_t>(&active)), 0);
    a.je(native);
    if (speed) a.xor_(eax, eax);
    // push/ret transfers to the native continuation without consuming a GPR
    // or changing flags. The game sees its original stack at either destination.
    a.push(d.imageBase + skipReturn);
    a.ret();
    a.bind(native);
    a.test(inputA ? eax : ecx, mask);
    a.push(d.imageBase + nativeReturn);
    a.ret();
    const auto& buffer = holder.section_by_id(0)->buffer();
    const std::vector<uint8_t> code(buffer.data(), buffer.data() + buffer.size());
    const uint32_t target = static_cast<uint32_t>(d.segments.size());
    d.segments.push_back({1, PatchFramework::Kind::Code, uint32_t(code.size()), Append(d, code),
                          uint32_t(code.size()), 0, 0, name});
    const auto original = HexBytes(expected);
    std::vector<uint8_t> patch(original.size(), 0x90);
    patch[0] = 0xE9;
    const uint32_t owner = static_cast<uint32_t>(d.segments.size());
    d.segments.push_back({1, PatchFramework::Kind::Patch, uint32_t(patch.size()), Append(d, patch),
                          uint32_t(patch.size()), site, Append(d, original), name});
    d.fixups.push_back({owner, 1, int32_t(target), uint32_t(-4), 2});
}
}

PatchFramework::Definition BuildDefinition(uintptr_t imageBase) {
    // Fast Dialogue (sd), TOS NoTSFix v26.9.6 entry 3189 / former FastText.asm.
    // Preserve its three proven paths; only the activation source changes.
    PatchFramework::Definition d;
    d.id = "builtin-skip-dialogue";
    d.version = "1";
    d.configSection = "FastForward";
    d.imageBase = static_cast<uint32_t>(imageBase);
    d.imageSize = 0x2AFF000;
    d.features.push_back({1, 0, "SkipDialogue"});
    Hook(d, "message_speed", 0x176344, "f7c100100004", 0x17634A, 0x176356, 0x04001000, true);
    Hook(d, "message_input_a", 0x17653D, "a90030000c", 0x176542, 0x176550, 0x0C003000, false, true);
    Hook(d, "message_input_b", 0x176777, "f7c100200008", 0x17677D, 0x17677F, 0x08002000, false);
    Guard(d, 0x17634A, "74116685c0740cb801000000");
    Guard(d, 0x176356, "66898624280000");
    Guard(d, 0x176542, "750cc6864227000004e951020000");
    Guard(d, 0x176550, "b90100000066018e20280000");
    Guard(d, 0x17677D, "7422");
    Guard(d, 0x17677F, "c605add78a0001c6864327000004c7866827000020000000eb08");
    return d;
}

bool Install() {
    try {
        uint8_t* image = nullptr;
        size_t size = 0;
        std::string error;
        if (PatchFramework::ProcessImage(image, size, error) &&
            PatchFramework::InstallBuiltin(BuildDefinition(reinterpret_cast<uintptr_t>(image)), error)) {
            LOG("[FastForward] SkipDialogue hooks installed");
            return true;
        }
        LOG("[FastForward] SkipDialogue unavailable: %s", error.empty() ? "dialogue hooks already owned" : error.c_str());
    } catch (const std::exception& e) {
        LOG("[FastForward] SkipDialogue unavailable: %s", e.what());
    }
    return false;
}

void SetActive(bool enabled) { InterlockedExchange(&active, enabled ? 1 : 0); }
}
