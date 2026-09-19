// Exercise the real Windows hook installer against a synthetic TOS image.
// Including the implementation keeps the test seam out of the DLL interface.
#include "../src/fast_forward.cpp"
#include <cassert>
#include <iostream>
#include <thread>
#include <vector>

int main() {
    using namespace FastForward;
    constexpr size_t size = 0x400000;
    auto* image = static_cast<unsigned char*>(VirtualAlloc(
        nullptr, size, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE));
    assert(image);
    auto* dos = reinterpret_cast<IMAGE_DOS_HEADER*>(image);
    dos->e_magic = IMAGE_DOS_SIGNATURE;
    dos->e_lfanew = sizeof(*dos);
    auto* nt = reinterpret_cast<IMAGE_NT_HEADERS32*>(image + dos->e_lfanew);
    nt->Signature = IMAGE_NT_SIGNATURE;
    nt->FileHeader.Machine = IMAGE_FILE_MACHINE_I386;
    nt->OptionalHeader.Magic = IMAGE_NT_OPTIONAL_HDR32_MAGIC;
    nt->OptionalHeader.SizeOfImage = size;
    auto** slot = reinterpret_cast<void**>(image + (0x703074 - 0x400000));
    const auto qpc = GetProcAddress(GetModuleHandleW(L"kernel32.dll"), "QueryPerformanceCounter");
    *slot = reinterpret_cast<void*>(qpc);
    assert(!InstallClock(image)); // Missing game instructions must fail closed.
    assert(*slot == reinterpret_cast<void*>(qpc));

    const unsigned char prologue[] = {0x55,0x8b,0xec,0x83,0xec,0x0c,0x8d,0x45,0xf4,0x50};
    std::memcpy(image + (0x5D2090 - 0x400000), prologue, sizeof(prologue));
    for (uintptr_t address : {uintptr_t(0x5D209A), uintptr_t(0x5C92D4)}) {
        auto* call = image + (address - 0x400000);
        call[0] = 0xff;
        call[1] = 0x15;
        const auto operand = reinterpret_cast<uintptr_t>(slot);
        std::memcpy(call + 2, &operand, sizeof(operand));
    }
    *slot = reinterpret_cast<void*>(GetProcAddress(GetModuleHandleW(L"kernel32.dll"), "GetTickCount"));
    assert(!InstallClock(image)); // Never replace another hook or unrelated API.
    *slot = reinterpret_cast<void*>(qpc);
    DWORD oldProtection = 0;
    assert(VirtualProtect(slot, sizeof(*slot), PAGE_READONLY, &oldProtection));
    assert(InstallClock(image));
    assert(*slot == reinterpret_cast<void*>(&ReadCounter));
    MEMORY_BASIC_INFORMATION info{};
    assert(VirtualQuery(slot, &info, sizeof(info)));
    assert(info.Protect == PAGE_READONLY);

    // Multiple game threads must observe monotonically increasing samples
    // while the render thread repeatedly toggles the multiplier.
    std::vector<std::thread> readers;
    for (int i = 0; i < 4; ++i) readers.emplace_back([slot] {
        auto read = reinterpret_cast<CounterFn>(*slot);
        LARGE_INTEGER previous{};
        assert(read(&previous));
        for (int j = 0; j < 10000; ++j) {
            LARGE_INTEGER now{};
            assert(read(&now));
            assert(now.QuadPart >= previous.QuadPart);
            previous = now;
        }
    });
    for (int i = 0; i < 1000; ++i) {
        AcquireSRWLockExclusive(&clockLock);
        LARGE_INTEGER now{};
        assert(realCounter(&now));
        counter.SetSpeed(now.QuadPart, (i & 1) ? 1.0 : 4.0);
        ReleaseSRWLockExclusive(&clockLock);
    }
    for (auto& thread : readers) thread.join();

    D3DPRESENT_PARAMETERS params{};
    params.PresentationInterval = D3DPRESENT_INTERVAL_ONE;
    int calls = 0;
    assert(WithPresentationParameters(&params, [&] {
        ++calls;
        assert(params.PresentationInterval == D3DPRESENT_INTERVAL_ONE);
        return S_OK;
    }) == S_OK); // Not enabled until initialization publishes success.
    assert(calls == 1);
    installed.store(true);
    calls = 0;
    assert(WithPresentationParameters(&params, [&] {
        ++calls;
        assert(params.PresentationInterval == D3DPRESENT_INTERVAL_IMMEDIATE);
        params.BackBufferWidth = 1280; // Preserve ordinary driver outputs.
        return S_OK;
    }) == S_OK);
    assert(calls == 1 && params.BackBufferWidth == 1280);
    assert(params.PresentationInterval == D3DPRESENT_INTERVAL_ONE);
    calls = 0;
    assert(WithPresentationParameters(&params, [&] {
        if (++calls == 1) {
            assert(params.PresentationInterval == D3DPRESENT_INTERVAL_IMMEDIATE);
            params.BackBufferWidth = 0;
            return D3DERR_INVALIDCALL;
        }
        assert(params.PresentationInterval == D3DPRESENT_INTERVAL_ONE);
        assert(params.BackBufferWidth == 1280);
        return S_OK;
    }) == S_OK);
    assert(calls == 2);
    disableVSync = false;
    assert(WithPresentationParameters(&params, [&] {
        assert(params.PresentationInterval == D3DPRESENT_INTERVAL_ONE);
        return D3DERR_DEVICELOST;
    }) == D3DERR_DEVICELOST);
    assert(VirtualFree(image, 0, MEM_RELEASE));
    std::cout << "Windows clock hook, concurrency, and presentation tests passed\n";
}
