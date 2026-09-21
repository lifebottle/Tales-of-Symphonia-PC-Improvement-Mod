#include "ct_import.h"
#include <cassert>
#include <cstring>
#include <fstream>
#include <iostream>
#include <functional>
#include <regex>
#include <chrono>
using namespace PatchScript;
using namespace PatchFramework;
const std::string Hook = R"([ENABLE]
aobscanmodule(site,Fixture.exe,B8 01 00 00 00 C3)
alloc(newmem,100,site)
alloc(value,4)
label(returnhere)
newmem:
mov eax,[value]
jmp returnhere
value:
dd 7
site:
jmp newmem
returnhere:
[DISABLE]
site:
db B8 01 00 00 00
dealloc(newmem)
dealloc(value)
)";
std::string Replace(std::string s, const std::string &from, const std::string &to) {
    auto i = s.find(from);
    assert(i != s.npos);
    s.replace(i, from.size(), to);
    return s;
}
void Reject(const std::function<void()> &f, const std::string &message) {
    try {
        f();
    } catch (const std::exception &e) {
        if (std::string(e.what()).find(message) == std::string::npos) {
            std::cerr << "Expected " << message << ", got " << e.what() << '\n';
            std::abort();
        }
        return;
    }
    std::cerr << "Expected rejection: " << message << '\n';
    std::abort();
}
Image Fixture() {
    Image image;
    image.base = 0x400000;
    image.size = 0x2000;
    image.module = "Fixture.exe";
    auto &data = image.regions[0x1000];
    data.resize(0x400, 0x90);
    std::vector<uint8_t> hook = {0xb8, 1, 0, 0, 0, 0xc3}, shortJump = {0x75, 9, 0x33, 0xd2, 0xc3};
    std::copy(hook.begin(), hook.end(), data.begin() + 0x10);
    std::copy(shortJump.begin(), shortJump.end(), data.begin() + 0x40);
    return image;
}
Package Convert(const Image &image, std::string script = Hook) {
    Table table;
    table.entries.push_back({"1", "Fixture", script, "", {}, false, false, false});
    return Import(table, image, {{"1", "Enabled"}}, "fixture", "Fixture");
}
void Write(const fs::path &path, const std::string &data) {
    std::ofstream f(path, std::ios::binary);
    f << data;
    assert(f.good());
}
int main() {
    auto image = Fixture();
    auto package = Convert(image);
    auto compiled = Compile(package);
    auto &d = compiled.definition;
    assert(d.segments.size() == 3 && d.fixups.size() == 3);
    assert(d.segments[0].kind == Kind::Code && d.segments[0].size == 0x100);
    assert(d.segments[1].kind == Kind::Data && d.bytes[d.segments[1].bytes] == 7);
    assert(d.segments[2].rva == 0x1010 && d.segments[2].count == 5);
    assert(package.scripts[0].text.find("define(site,TOS.exe+0x1010)") != std::string::npos);
    for (auto input : {std::string("#10"), std::string("(int)10")}) {
        auto p = Convert(image, Replace(Hook, "dd 7", "dd " + input));
        auto c = Compile(p);
        assert(c.definition.bytes[c.definition.segments[1].bytes] == 10);
    }
    {
        auto p = Convert(image, Replace(Hook, "dd 7", "dd 10"));
        auto c = Compile(p);
        assert(c.definition.bytes[c.definition.segments[1].bytes] == 16);
    }
    {
        auto p = Convert(image, Replace(Hook, "B8 01 00 00 00 C3", "B? 01 ** ?? 00 C3"));
        Compile(p);
    }
    {
        auto p = Convert(image, Replace(Hook, "mov eax,[value]", "imul eax,#16\nmov eax,[value]"));
        Compile(p);
    }
    {
        std::string script = "[ENABLE]\naobscanmodule(site,Fixture.exe,75 09 33 D2 C3)\nsite:\njmp "
                             "Fixture.exe+104B\n[DISABLE]\nsite:\njne Fixture.exe+104B\n";
        auto p = Convert(image, script);
        auto c = Compile(p);
        assert(c.definition.segments[0].count == 2 && c.definition.bytes[0] == 0xeb &&
               c.definition.bytes[1] == 9 && c.definition.fixups.empty());
    }
    {
        auto duplicate = image;
        auto &bytes = duplicate.regions[0x1000];
        std::copy(bytes.begin() + 0x10, bytes.begin() + 0x16, bytes.begin() + 0x80);
        Reject([&] { Convert(duplicate); }, "ambiguous");
    }
    for (auto pair : {std::pair<std::string, std::string>{"alloc(value,1)", "Allocation exceeded"},
                      {"createthread(newmem)", "Unsupported"},
                      {"alloc(value,100000000)", "overflow"}})
        Reject([&] { Convert(image, Replace(Hook, "alloc(value,4)", pair.first)); }, pair.second);
    Reject([&] { Convert(image, Replace(Hook, "[ENABLE]", "[ENABLE]\n{$lua}\nprint(1)")); }, "Lua");
    Reject([&] { Convert(image, Replace(Hook, "mov eax,[value]", "mov eax,[UnknownState]")); },
           "Unresolved symbol");
    Reject([&] { Convert(image, Replace(Hook, "db B8 01", "db B8 02")); }, "DISABLE restore bytes");
    Reject([&] { Convert(image, Replace(Hook, "jmp newmem\nreturnhere:", "nop 4\nreturnhere:")); },
           "splits an original instruction");
    Reject(
        [&] { Convert(image, Replace(Hook, "mov eax,[value]", "inc dword ptr [newmem]\nmov eax,[value]")); },
        "Mixed writable");
    Reject([&] { Convert(image, Replace(Hook, "B8 01 00 00 00 C3", "DE AD BE EF")); }, "did not match");
    {
        auto p = package;
        p.scripts[0].text = std::regex_replace(p.scripts[0].text, std::regex("assert\\([^\\n]*\\)"), "");
        Reject([&] { Compile(p); }, "lacks assert");
    }
    {
        Table t;
        t.entries = {
            {"1", "Provider", "[ENABLE]\nalloc(shared,4)\nregistersymbol(shared)\nshared:\ndd 7\n", "", {}},
            {"2",
             "Consumer",
             Replace(Replace(Replace(Hook, "alloc(value,4)", ""), "value:\ndd 7", ""), "[value]", "[shared]"),
             "",
             {}}};
        t.entries[1].script = Replace(t.entries[1].script, "dealloc(value)", "");
        auto p = Import(t, image, {{"1", "State"}, {"2", "Hook"}}, "shared", "Shared");
        assert(p.features[1].dependencies == 1);
        Compile(p);
        p.features[1].dependencies = 0;
        Reject([&] { Compile(p); }, "undeclared feature dependency");
        t.hasLua = true;
        Reject([&] { Import(t, image, {{"1", "State"}, {"2", "Hook"}}, "shared", "Shared"); },
               "Table-level Lua");
        Import(t, image, {{"1", "State"}, {"2", "Hook"}}, "shared", "Shared", true);
        t.entries[1].callbacks = true;
        Reject([&] { Import(t, image, {{"2", "Hook"}}, "shared", "Shared", true); }, "callbacks");
    }
    {
        Table t;
        t.entries = {{"10", "Group", "", "", {"1"}, true}, {"1", "Child", Hook, "10", {}}};
        auto p = Import(t, image, {{"10", "Together"}}, "group", "Group");
        assert(p.features.size() == 1 && p.scripts[0].feature == "Together");
    }
    {
        auto source = Replace(Replace(Hook, "alloc(value,4)", "alloc(value,10)"), "dd 7",
                              "db -1\ndw #258\ndd (float)1.25\ndq 1122334455667788");
        auto p = Convert(image, source);
        auto c = Compile(p);
        auto &seg = c.definition.segments[1];
        const std::vector<uint8_t> expected = {0xff, 2,    1,    0,    0,    0xa0, 0x3f, 0x88,
                                               0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11};
        assert(seg.count == expected.size());
        assert(std::equal(expected.begin(), expected.end(), c.definition.bytes.begin() + seg.bytes));
    }
    {
        auto p = Convert(image, Replace(Hook, "mov eax,[value]", "loop forward\nmov eax,[value]\nforward:"));
        Compile(p);
    }
    {
        auto p = Convert(image, Replace(Hook, "mov eax,[value]", "mov eax,[esp+eax]\nmov eax,[value]"));
        Compile(p);
    }
    {
        auto p = Convert(image, Replace(Replace(Hook, "B8 01 00 00 00 C3", "B8 01 00 00 00"),
                                        "db B8 01 00 00 00", "db B8 01 00 00 00 C3"));
        Compile(p);
    }
    Reject(
        [&] {
            Convert(image,
                    Replace(Hook, "dd 7", "dd " + std::string(140, '(') + "1" + std::string(140, ')')));
        },
        "nesting limit");
    Reject([&] { Convert(image, Replace(Hook, "mov eax,[value]", "mov eax,[eax*ffffffff*ffffffff]")); },
           "coefficient overflow");
    auto temporary =
        fs::temp_directory_path() /
        fs::u8path("tos-script-" +
                   std::to_string(std::chrono::steady_clock::now().time_since_epoch().count()) + " café");
    fs::create_directories(temporary);
    try {
        auto exportPath = temporary / "readable patch";
        Export(package, exportPath);
        auto loaded = ReadPackage(exportPath / "patch.toml");
        auto c = Compile(loaded);
        assert(c.definition.bytes == d.bytes && c.definition.fixups.size() == d.fixups.size());
        auto original = ReadText(exportPath / "patch.toml");
        Reject([&] { Export(package, exportPath); }, "already exists");
        assert(ReadText(exportPath / "patch.toml") == original);
        Write(exportPath / "patch.toml", original + "\n[unknown]\nx=1\n");
        Reject([&] { ReadPackage(exportPath / "patch.toml"); }, "Unknown metadata field");
        Write(exportPath / "patch.toml", Replace(original, "entry-1.asm", "../outside.asm"));
        Write(temporary / "outside.asm", Hook);
        Reject([&] { ReadPackage(exportPath / "patch.toml"); }, "outside package");
        Write(exportPath / "patch.toml", Replace(original, "format = 1", "format = 2"));
        Reject([&] { ReadPackage(exportPath / "patch.toml"); }, "format version");
        Write(exportPath / "patch.toml", original + std::string(1, 0));
        Reject([&] { ReadPackage(exportPath / "patch.toml"); }, "NUL");
        Write(temporary / "bad.CT", "<!DOCTYPE x><CheatTable/>");
        Reject([&] { Table::Read(temporary / "bad.CT"); }, "DOCTYPE");
        Write(temporary / "good.CT", "<CheatTable><CheatEntries><CheatEntry><ID>1</ID><Description>Test</"
                                     "Description><AssemblerScript>[ENABLE]</AssemblerScript></CheatEntry></"
                                     "CheatEntries></CheatTable>");
        assert(Table::Read(temporary / "good.CT").entries[0].name == "Test");
        // A real, bounded PE file exercises the executable reader rather than only Image fixtures.
        std::string pe(0x600, '\0');
        auto put = [&](size_t at, uint32_t n, size_t count) {
            for (size_t i = 0; i < count; ++i)
                pe[at + i] = char(n >> (8 * i));
        };
        put(0, 0x5a4d, 2);
        put(0x3c, 0x80, 4);
        put(0x80, 0x4550, 4);
        put(0x84, 0x14c, 2);
        put(0x86, 1, 2);
        put(0x94, 0xe0, 2);
        put(0x98, 0x10b, 2);
        put(0x98 + 28, 0x400000, 4);
        put(0x98 + 56, 0x2000, 4);
        put(0x98 + 60, 0x200, 4);
        size_t sec = 0x178;
        put(sec + 8, 0x400, 4);
        put(sec + 12, 0x1000, 4);
        put(sec + 16, 0x400, 4);
        put(sec + 20, 0x200, 4);
        std::memcpy(pe.data() + 0x200, image.regions.at(0x1000).data(), 0x400);
        Write(temporary / "Fixture.exe", pe);
        auto parsed = Image::Read(temporary / "Fixture.exe");
        assert(parsed.Scan("Fixture.exe", "B8 01 00 00 00 C3") == 0x1010);
        Convert(parsed);
        for (size_t n : {size_t(0), size_t(64), size_t(0x100), size_t(0x300)}) {
            Write(temporary / "truncated.exe", pe.substr(0, n));
            Reject([&] { Image::Read(temporary / "truncated.exe"); }, n < 0x100   ? "Truncated"
                                                                      : n < 0x200 ? "headers"
                                                                                  : "range");
        }
        fs::remove_all(temporary);
    } catch (...) {
        fs::remove_all(temporary);
        throw;
    }
    std::cout << "Script/compiler/import/export regressions passed.\n";
}
