#include "patch_runtime.h"
#include "logger.h"
#include <windows.h>
#include <tlhelp32.h>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <vector>
static_assert(sizeof(uintptr_t)==4, "Patch runtime requires x86");
namespace PatchFramework {
namespace {
bool Readable(const void* address, size_t size) {
    uintptr_t cursor = reinterpret_cast<uintptr_t>(address);
    const uintptr_t end = cursor + size;
    if (end < cursor) return false;
    while (cursor < end) {
        MEMORY_BASIC_INFORMATION info{};
        if (!VirtualQuery(reinterpret_cast<void*>(cursor), &info, sizeof(info)) ||
            info.State != MEM_COMMIT || (info.Protect & (PAGE_GUARD | PAGE_NOACCESS))) return false;
        const auto next = reinterpret_cast<uintptr_t>(info.BaseAddress) + info.RegionSize;
        if (next <= cursor) return false;
        cursor = next;
    }
    return true;
}

struct Allocation {
    uint8_t* memory = nullptr;
    ~Allocation() { if (memory) VirtualFree(memory, 0, MEM_RELEASE); }
    bool Create(size_t size) {
        memory = static_cast<uint8_t*>(VirtualAlloc(nullptr, std::max(size, size_t(1)),
                                                   MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE));
        return memory != nullptr;
    }
    void Keep() { memory = nullptr; } // Installed hooks live until process exit.
};
struct Write { uint8_t* address; const uint8_t* bytes; const uint8_t* original; size_t size; };
struct Page { void* address; DWORD protection = 0; };

// Acquire thread handles before suspending anything. No heap allocation, logging,
// or C++ synchronization is allowed while peers might hold those locks.
class FrozenThreads {
    struct Thread { HANDLE handle; bool suspended; };
    std::vector<Thread> threads;
public:
    ~FrozenThreads() {
        for (auto& thread : threads) {
            if (thread.suspended) ResumeThread(thread.handle);
            CloseHandle(thread.handle);
        }
    }
    bool Prepare() {
        HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
        if (snapshot == INVALID_HANDLE_VALUE) return false;
        THREADENTRY32 entry{};
        entry.dwSize = sizeof(entry);
        bool ok = Thread32First(snapshot, &entry) != FALSE;
        if (ok) do {
            if (entry.th32OwnerProcessID != GetCurrentProcessId() ||
                entry.th32ThreadID == GetCurrentThreadId()) continue;
            HANDLE handle = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT |
                                       THREAD_QUERY_INFORMATION, FALSE, entry.th32ThreadID);
            if (!handle) { ok = false; break; }
            threads.push_back({handle, false});
        } while (Thread32Next(snapshot, &entry));
        CloseHandle(snapshot);
        return ok;
    }
    bool Freeze(const std::vector<Write>& writes) {
        for (auto& thread : threads) {
            if (SuspendThread(thread.handle) == DWORD(-1)) return false;
            thread.suspended = true;
            CONTEXT context{};
            context.ContextFlags = CONTEXT_CONTROL;
            if (!GetThreadContext(thread.handle, &context)) return false;
            for (const auto& write : writes) {
                const auto start = reinterpret_cast<uintptr_t>(write.address);
                if (context.Eip >= start && context.Eip < start + write.size) return false;
            }
        }
        return true;
    }
};

bool Commit(const std::vector<Write>& writes, bool& protectionWarning) {
    SYSTEM_INFO system{};
    GetSystemInfo(&system);
    std::vector<Page> pages;
    for (const auto& write : writes) {
        const auto begin = reinterpret_cast<uintptr_t>(write.address);
        for (auto page = begin & ~(uintptr_t(system.dwPageSize) - 1);
             page < begin + write.size; page += system.dwPageSize) {
            void* address = reinterpret_cast<void*>(page);
            if (std::none_of(pages.begin(), pages.end(), [=](const Page& p) { return p.address == address; }))
                pages.push_back({address, 0});
        }
    }
    FrozenThreads frozen;
    if (!frozen.Prepare() || !frozen.Freeze(writes)) return false;
    // Recheck while threads are stopped, before the first code write.
    for (const auto& write : writes)
        if (std::memcmp(write.address, write.original, write.size)) return false;
    size_t writable = 0;
    for (; writable < pages.size(); ++writable)
        if (!VirtualProtect(pages[writable].address, system.dwPageSize,
                            PAGE_EXECUTE_READWRITE, &pages[writable].protection)) break;
    bool success = writable == pages.size();
    if (success) {
        for (const auto& write : writes) std::memcpy(write.address, write.bytes, write.size);
        success = FlushInstructionCache(GetCurrentProcess(), nullptr, 0) != FALSE;
        if (!success) {
            for (const auto& write : writes) std::memcpy(write.address, write.original, write.size);
            FlushInstructionCache(GetCurrentProcess(), nullptr, 0);
        }
    }
    for (size_t i = 0; i < writable; ++i) {
        DWORD ignored;
        if (!VirtualProtect(pages[i].address, system.dwPageSize, pages[i].protection, &ignored))
            protectionWarning = true;
    }
    return success;
}

} // namespace

bool Install(Session& session, const Definition& definition, uint8_t* image, size_t imageSize,
             const Options& options, std::string& error) {
    if (!Validate(definition,error)) return false;
    auto fail=[&](const std::string& s) { error=s; return false; };
    if (!image || imageSize!=definition.imageSize) return fail("executable image size mismatch");
    if (definition.imageBase && reinterpret_cast<uintptr_t>(image)!=definition.imageBase)
        return fail("executable base address mismatch");
    uint32_t known=0;
    for (const auto& feature:definition.features) known|=feature.bit;
    if (options.enabled & ~known) return fail("unknown feature bit");
    if (options.parameters.size()!=definition.parameters.size()) return fail("parameter count mismatch");
    for (size_t i=0;i<definition.parameters.size();++i) {
        const auto& p=definition.parameters[i]; const auto value=options.parameters[i];
        if (!std::isfinite(value) || value<p.minimum || value>=p.maximum) return fail("parameter out of range");
    }
    const uint32_t enabled = Dependencies(definition,options.enabled);
    if (!enabled) return true;
    if (std::find(session.installed.begin(),session.installed.end(),definition.id)!=session.installed.end())
        return fail("definition is already installed; restart to update");
    std::vector<Session::Range> ranges;
    for (const auto& s:definition.segments) if ((s.group & enabled) && s.kind==Kind::Patch)
        ranges.push_back({reinterpret_cast<uintptr_t>(image+s.rva),reinterpret_cast<uintptr_t>(image+s.rva+s.count),true});
    for (const auto& g:definition.guards) if (g.group & enabled)
        ranges.push_back({reinterpret_cast<uintptr_t>(image+g.rva),reinterpret_cast<uintptr_t>(image+g.rva+g.count),false});
    for (const auto& a:ranges) for (const auto& b:session.ranges)
        if ((a.write || b.write) && a.start<b.end && b.start<a.end)
            return fail("patch/guard conflicts with an installed definition");
    // Reserve all ownership records before committing executable writes.
    auto ownedRanges=session.ranges;
    ownedRanges.insert(ownedRanges.end(),ranges.begin(),ranges.end());
    auto installed=session.installed; installed.push_back(definition.id);
    auto matches = [&](uint32_t rva, uint32_t bytes, uint32_t count) {
        return rva <= imageSize && count <= imageSize - rva &&
               Readable(image + rva, count) && !std::memcmp(image + rva, definition.bytes.data() + bytes, count);
    };
    for (const auto& segment : definition.segments) {
        if (!(segment.group & enabled) || segment.kind != Kind::Patch) continue;
        if (!matches(segment.rva, segment.expected, segment.count)) {
            LOG("[Patches] Unsupported/already patched site +0x%X (%s); no patches installed",
                segment.rva, segment.name.c_str());
            return fail("original bytes mismatch at " + segment.name);
        }
    }
    for (const auto& guard : definition.guards) {
        if ((guard.group & enabled) && !matches(guard.rva, guard.bytes, guard.count)) {
            LOG("[Patches] Unsupported code destination +0x%X; no patches installed", guard.rva);
            return fail("guard bytes mismatch");
        }
    }
    const auto SegmentCount=definition.segments.size();
    std::vector<uint8_t*> addresses(SegmentCount);
    std::vector<size_t> offsets(SegmentCount);
    size_t codeSize = 0, stateSize = 0;
    for (size_t i = 0; i < SegmentCount; ++i) {
        const auto& segment = definition.segments[i];
        if (!(segment.group & enabled)) continue;
        if (segment.kind == Kind::Patch) { addresses[i] = image + segment.rva; continue; }
        auto& size = segment.kind == Kind::Code ? codeSize : stateSize;
        offsets[i] = size;
        size += (segment.size + 15u) & ~15u;
    }
    Allocation code, state;
    if (!code.Create(codeSize) || !state.Create(stateSize)) return fail("allocation failed");
    std::vector<std::vector<uint8_t>> patchBytes(SegmentCount);
    std::vector<Write> writes;
    for (size_t i = 0; i < SegmentCount; ++i) {
        const auto& segment = definition.segments[i];
        if (!(segment.group & enabled)) continue;
        if (segment.kind == Kind::Patch) {
            patchBytes[i].assign(definition.bytes.data() + segment.bytes, definition.bytes.data() + segment.bytes + segment.count);
        } else {
            addresses[i] = (segment.kind == Kind::Code ? code.memory : state.memory) + offsets[i];
            std::memcpy(addresses[i], definition.bytes.data() + segment.bytes, segment.count);
        }
    }
    for (const auto& fixup : definition.fixups) {
        const auto& owner = definition.segments[fixup.owner];
        if (!(owner.group & enabled)) continue;
        uint8_t* target = fixup.target < 0 ? image : addresses[fixup.target];
        if (!target) return fail("missing relocation dependency");
        uint8_t* destination = owner.kind == Kind::Patch ? patchBytes[fixup.owner].data() : addresses[fixup.owner];
        uint32_t value = static_cast<uint32_t>(reinterpret_cast<uintptr_t>(target)) + fixup.addend;
        if (fixup.type != 1) value -= static_cast<uint32_t>(reinterpret_cast<uintptr_t>(addresses[fixup.owner] + fixup.offset));
        if (fixup.type == 23) {
            const int32_t displacement = static_cast<int32_t>(value);
            if (displacement < -128 || displacement > 127) return fail("relative byte relocation out of range");
            destination[fixup.offset] = static_cast<uint8_t>(value);
        } else std::memcpy(destination + fixup.offset, &value, sizeof(value));
    }
    for (size_t i=0;i<definition.parameters.size();++i) {
        const auto& p=definition.parameters[i];
        if (p.group & enabled) std::memcpy(addresses[p.segment]+p.offset,&options.parameters[i],4);
    }
    DWORD ignored;
    if (!VirtualProtect(code.memory, std::max(codeSize, size_t(1)), PAGE_EXECUTE_READ, &ignored) ||
        !FlushInstructionCache(GetCurrentProcess(), code.memory, codeSize)) return fail("cannot protect/flush hook code");
    for (size_t i = 0; i < SegmentCount; ++i) {
        const auto& segment = definition.segments[i];
        if ((segment.group & enabled) && segment.kind == Kind::Patch)
            writes.push_back({addresses[i], patchBytes[i].data(), definition.bytes.data() + segment.expected, segment.count});
    }
    bool protectionWarning = false;
    const bool committed = Commit(writes, protectionWarning);
    if (protectionWarning) LOG("[Patches] WARNING: failed to restore one or more game page protections");
    if (!committed) return fail("could not safely commit hooks");
    code.Keep();
    state.Keep();
    session.ranges.swap(ownedRanges); session.installed.swap(installed);
    error.clear();
    LOG("[Patches] %s %s: installed %u patches (features 0x%X)",
        definition.id.c_str(),definition.version.c_str(),static_cast<unsigned>(writes.size()),enabled);
    return true;
}

bool ProcessImage(uint8_t*& image,size_t& imageSize,std::string& error) {
    image=reinterpret_cast<uint8_t*>(GetModuleHandleW(nullptr));
    auto fail=[&]() { error="unsupported executable layout"; return false; };
    if (!image || !Readable(image,sizeof(IMAGE_DOS_HEADER))) return fail();
    const auto* dos=reinterpret_cast<const IMAGE_DOS_HEADER*>(image);
    if (dos->e_magic!=IMAGE_DOS_SIGNATURE || dos->e_lfanew<=0 || dos->e_lfanew>0x1000) return fail();
    const auto* nt=reinterpret_cast<const IMAGE_NT_HEADERS32*>(image+dos->e_lfanew);
    if (!Readable(nt,sizeof(*nt)) || nt->Signature!=IMAGE_NT_SIGNATURE ||
        nt->FileHeader.Machine!=IMAGE_FILE_MACHINE_I386 || nt->OptionalHeader.Magic!=IMAGE_NT_OPTIONAL_HDR32_MAGIC)
        return fail();
    imageSize=nt->OptionalHeader.SizeOfImage; return true;
}
} // namespace PatchFramework
