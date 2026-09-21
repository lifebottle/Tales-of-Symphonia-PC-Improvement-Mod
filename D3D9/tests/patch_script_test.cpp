#include "ct_import.h"
#include "../third_party/tomlplusplus/toml.hpp"
#include <algorithm>
#include <cassert>
#include <cstring>
#include <fstream>
#include <iostream>
#include <functional>
#include <regex>
#include <chrono>
#include <sstream>
#include <tuple>
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
void ManifestDefaults(const Image &image, const fs::path &temporary) {
    auto directory = temporary / "manifest-defaults";
    fs::create_directories(directory / "nested");
    auto manifest = directory / "patch.toml";
    auto original = Convert(image);
    auto &script = original.scripts.front();
    script.id = script.name = "State";
    script.file = "nested/State.asm";
    original.parameters.push_back({"Value", "Enabled", "State", "value", 7, 0, 10});
    Write(directory / script.file, script.text);
    auto read = [&](const std::string &text) {
        Write(manifest, text);
        return ReadPackage(manifest);
    };
    auto text = Manifest(original);
    auto table = toml::parse(text);
    auto &entry = *table["scripts"].as_array()->at(0).as_table();
    assert(!entry.contains("id") && !entry.contains("name") && !entry.contains("feature"));
    assert(entry["file"].value<std::string>() == script.file);
    assert(entry["writable"].as_array()->size() == 1);
    assert(!table["features"].as_array()->at(0).as_table()->contains("requires"));
    auto loaded = read(text);
    auto &resolved = loaded.scripts.front();
    assert(resolved.id == "State" && resolved.name == "State" && resolved.feature == "Enabled");
    assert(resolved.writable == script.writable);
    assert(loaded.parameters.front().script == "State");

    // Explicit format-1 metadata and compact metadata must compile identically.
    entry.insert("id", "State");
    entry.insert("name", "State");
    entry.insert("feature", "Enabled");
    auto fromTable = [&] {
        std::ostringstream out;
        out << table;
        return read(out.str());
    };
    auto explicitPackage = fromTable();
    auto expected = Compile(explicitPackage), actual = Compile(loaded);
    assert(actual.symbols == expected.symbols);
    const auto &a = actual.definition, &b = expected.definition;
    assert(a.bytes == b.bytes && a.segments.size() == b.segments.size());
    assert(a.fixups.size() == b.fixups.size() && a.guards.size() == b.guards.size());
    for (size_t i = 0; i < a.segments.size(); ++i) {
        const auto &x = a.segments[i], &y = b.segments[i];
        assert(std::tie(x.group, x.kind, x.size, x.bytes, x.count, x.rva, x.expected, x.name) ==
               std::tie(y.group, y.kind, y.size, y.bytes, y.count, y.rva, y.expected, y.name));
    }
    for (size_t i = 0; i < a.fixups.size(); ++i) {
        const auto &x = a.fixups[i], &y = b.fixups[i];
        assert(std::tie(x.owner, x.offset, x.target, x.addend, x.type) ==
               std::tie(y.owner, y.offset, y.target, y.addend, y.type));
    }
    for (size_t i = 0; i < a.guards.size(); ++i) {
        const auto &x = a.guards[i], &y = b.guards[i];
        assert(std::tie(x.group, x.rva, x.bytes, x.count) == std::tie(y.group, y.rva, y.bytes, y.count));
    }
    assert(a.parameters.size() == 1 && b.parameters.size() == 1);
    const auto &x = a.parameters.front(), &y = b.parameters.front();
    assert(std::tie(x.group, x.segment, x.offset, x.value, x.minimum, x.maximum, x.key) ==
           std::tie(y.group, y.segment, y.offset, y.value, y.minimum, y.maximum, y.key));
    assert(Manifest(explicitPackage) == text);

    for (auto key : {"id", "name", "feature"}) {
        entry.insert_or_assign(key, 42);
        Reject([&] { fromTable(); }, std::string("Invalid/missing field: ") + key);
        entry.insert_or_assign(key, "");
        Reject([&] { fromTable(); }, std::string("Invalid/missing field: ") + key);
        entry.erase(key);
    }
    entry.insert("feature", "Missing");
    Reject([&] { fromTable(); }, "Unknown script feature");
    entry.erase("feature");
    entry.insert_or_assign("file", "nested/bad name.asm");
    Reject([&] { fromTable(); }, "Invalid/duplicate script ID");
    entry.insert_or_assign("file", script.file);

    // Duplicate stems (including case-only differences) need explicit IDs.
    Write(directory / "state.asm", script.text);
    auto duplicate = text + "\n[[scripts]]\nfile = 'state.asm'\n";
    Reject([&] { read(duplicate); }, "Invalid/duplicate script ID");
    auto unique = read(duplicate + "id = 'other'\n");
    assert(unique.scripts.back().id == "other" && unique.scripts.back().name == "other");

    // Multiple features infer only an exact match, using the resolved ID.
    original.features.push_back({2, 1, "State"});
    script.feature = "State";
    original.parameters.front().feature = "State";
    loaded = read(Manifest(original));
    assert(loaded.scripts.front().feature == "State" && loaded.features[1].dependencies == 1);
    Compile(loaded);
    script.feature = "Enabled"; // An explicit override wins over the matching feature.
    loaded = read(Manifest(original));
    assert(loaded.scripts.front().feature == "Enabled");
    auto missing = Replace(text, "[[features]]", "[[features]]\nkey = 'Other'\n\n[[features]]");
    Reject([&] { read(missing); }, "specify feature explicitly");
    Reject([&] { read(Replace(missing, "key = 'Other'", "key = 'state'")); }, "specify feature explicitly");
    auto overrideId = read(Replace(missing, "[[scripts]]", "[[scripts]]\nid = 'Other'"));
    assert(overrideId.scripts.front().id == "Other" && overrideId.scripts.front().name == "Other" &&
           overrideId.scripts.front().feature == "Other");

    // Imported IDs and descriptions remain explicit even with feature inference.
    auto imported = Convert(image);
    Write(directory / imported.scripts.front().file, imported.scripts.front().text);
    loaded = read(Manifest(imported));
    assert(loaded.scripts.front().id == "1" && loaded.scripts.front().name == "CT 1: Fixture");
    assert(loaded.scripts.front().feature == "Enabled");
    assert(Compile(loaded).definition.bytes == Compile(imported).definition.bytes);

    // A script without writable allocations can serialize to just its filename.
    auto minimal = Convert(image, "[ENABLE]\nFixture.exe+1000:\nnop\n");
    minimal.scripts.front().id = minimal.scripts.front().name = "entry-1";
    text = Manifest(minimal);
    auto minimalTable = toml::parse(text);
    assert(minimalTable["scripts"].as_array()->at(0).as_table()->size() == 1);
    Write(directory / minimal.scripts.front().file, minimal.scripts.front().text);
    loaded = read(text);
    assert(loaded.scripts.front().writable.empty());
    assert(Compile(loaded).definition.bytes == Compile(minimal).definition.bytes);
}
void ChildActivation(const Image &image, const fs::path &temporary) {
    // Actual CT XML exercises saved options, not just hand-constructed Entry flags.
    auto ct = temporary / "activation.CT";
    Write(ct, R"(<CheatTable><CheatEntries><CheatEntry>
<ID>10</ID><Description>Parent</Description>
<Options moActivateChildrenAsWell="1" moDeactivateChildrenAsWell="1"/>
<AssemblerScript>[ENABLE]
alloc(parentState,4)
parentState:
dd 0
</AssemblerScript><CheatEntries><CheatEntry>
<ID>20</ID><Description>Nested group</Description><GroupHeader>1</GroupHeader>
<Options moActivateChildrenAsWell="1"/>
<CheatEntries><CheatEntry>
<ID>30</ID><Description>Nested script</Description>
<Options moActivateChildrenAsWell="1"/>
<AssemblerScript>)" + Hook + R"(</AssemblerScript>
<CheatEntries><CheatEntry><ID>31</ID><Description>Leaf</Description>
<AssemblerScript>[ENABLE]
alloc(leafState,4)
leafState:
dd 1
</AssemblerScript></CheatEntry></CheatEntries></CheatEntry></CheatEntries>
</CheatEntry><CheatEntry>
<ID>40</ID><Description>Ordinary group</Description><GroupHeader>1</GroupHeader>
<Options moHideChildren="1" moDeactivateChildrenAsWell="1"/>
<CheatEntries><CheatEntry><ID>41</ID><Description>Optional value</Description>
<VariableType>4 Bytes</VariableType><Address>0</Address>
</CheatEntry></CheatEntries></CheatEntry><CheatEntry>
<ID>50</ID><Description>Ordinary script</Description>
<Options moActivateChildrenAsWell="0" moAlwaysHideChildren="1"/>
<AssemblerScript>[ENABLE]
alloc(optionalState,4)
optionalState:
dd 2
</AssemblerScript><CheatEntries><CheatEntry>
<ID>51</ID><Description>Optional Lua</Description>
<AssemblerScript>[ENABLE]
{$lua}
print('not activated')
</AssemblerScript></CheatEntry></CheatEntries></CheatEntry>
</CheatEntries></CheatEntry></CheatEntries></CheatTable>)");
    auto table = Table::Read(ct);
    auto p = Import(table, image, {{"10", "Parent"}}, "activation", "Activation");
    assert(p.features.size() == 1 && p.scripts.size() == 4);
    std::set<std::string> ids;
    for (const auto &script : p.scripts) {
        ids.insert(script.id);
        assert(script.feature == "Parent");
    }
    assert((ids == std::set<std::string>{"10", "30", "31", "50"}));
    // Separately checked descendants keep their keys and must still activate
    // from the parent, regardless of selection order. No reverse dependency is
    // inferred just because an entry has a parent in the tree.
    std::vector<Selection> selected = {{"10", "Parent"}, {"20", "Nested"}, {"30", "Child"}};
    do {
        p = Import(table, image, selected, "activation", "Activation");
        assert(p.scripts.size() == 4 && p.features.size() == 3);
        auto d = Compile(p).definition;
        std::map<std::string, uint32_t> bits;
        for (const auto &feature : p.features)
            bits[feature.key] = feature.bit;
        assert(Dependencies(d, bits["Parent"]) == 7);
        assert(Dependencies(d, bits["Nested"]) == (bits["Nested"] | bits["Child"]));
        assert(Dependencies(d, bits["Child"]) == bits["Child"]);
        assert(Dependencies(d, 0) == 0);
        for (const auto &script : p.scripts)
            assert(script.feature == (script.id == "30" || script.id == "31" ? "Child" : "Parent"));
    } while (std::next_permutation(selected.begin(), selected.end(),
                                   [](const Selection &a, const Selection &b) { return a.id < b.id; }));
    Export(p, temporary / "activation-export");
    auto loaded = ReadPackage(temporary / "activation-export" / "patch.toml");
    auto d = Compile(loaded).definition;
    assert(d.features[2].key == "Parent" && Dependencies(d, d.features[2].bit) == 7);
    assert(ReadText(temporary / "activation-export" / "INSTALL.txt").find(
               "Parent also enables Nested.") != std::string::npos);
    Reject([&] { Import(table, image, {{"40", "Group"}}, "activation", "Activation"); },
           "does not activate any scripts");
    Reject([&] { Import(table, image, {{"10", "Parent"}, {"41", "Value"}}, "activation", "Activation"); },
           "pointer/value records");
    for (auto &entry : table.entries)
        if (entry.id == "40")
            entry.activateChildren = true;
    Reject([&] { Import(table, image, {{"10", "Parent"}}, "activation", "Activation"); },
           "Entry 41 (Optional value): pointer/value records");
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
    {
        auto assemble = [&](const std::string &instruction) {
            auto p = Convert(image, "[ENABLE]\nalloc(code,100)\ncode:\n" + instruction +
                                    "\nFixture.exe+1000:\nnop\n");
            auto c = Compile(p);
            assert(c.definition.segments.size() == 2);
            const auto &segment = c.definition.segments[0];
            auto begin = c.definition.bytes.begin() + segment.bytes;
            return std::vector<uint8_t>(begin, begin + segment.count);
        };
        // CE defaults an unsized integer memory/immediate operand to DWORD.
        // EDX's address width and a small immediate do not imply a byte access.
        assert((assemble("cmp [edx],0") == std::vector<uint8_t>{0x83, 0x3a, 0x00}));
        assert((assemble("cmp [edx],#128") ==
                std::vector<uint8_t>{0x81, 0x3a, 0x80, 0x00, 0x00, 0x00}));
        assert((assemble("cmp byte ptr [edx],0") == std::vector<uint8_t>{0x80, 0x3a, 0x00}));
        assert((assemble("cmp word ptr [edx],0") == std::vector<uint8_t>{0x66, 0x83, 0x3a, 0x00}));
        assert((assemble("cmp [edx],al") == std::vector<uint8_t>{0x38, 0x02}));
        assert((assemble("cmp [edx],ax") == std::vector<uint8_t>{0x66, 0x39, 0x02}));
        assert((assemble("cmp [edx],eax") == std::vector<uint8_t>{0x39, 0x02}));
        for (const std::string cmd : {"adc", "add", "and", "cmp", "mov", "or", "sbb", "sub", "test", "xor"})
            assert(assemble(cmd + " [edx],1") == assemble(cmd + " dword ptr [edx],1"));
        auto p = Convert(image, Replace(Hook, "mov eax,[value]", "cmp [value],0\nmov eax,[value]"));
        assert(Compile(p).definition.fixups.size() == 4);
    }
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
        t.entries[0].activateChildren = true;
        t.entries[0].children = {"2"};
        t.entries[1].parent = "1";
        p = Import(t, image, {{"1", "State"}, {"2", "Hook"}}, "shared", "Shared");
        assert(p.features[0].dependencies == 2 && p.features[1].dependencies == 1);
        // Parent activation and child symbol requirements may form a cycle.
        // The existing runtime closure enables both and terminates.
        assert(Dependencies(Compile(p).definition, 1) == 3);
        assert(Dependencies(Compile(p).definition, 2) == 3);
        t.hasLua = true;
        Reject([&] { Import(t, image, {{"1", "State"}, {"2", "Hook"}}, "shared", "Shared"); },
               "Table-level Lua");
        Import(t, image, {{"1", "State"}, {"2", "Hook"}}, "shared", "Shared", true);
        t.entries[1].callbacks = true;
        Reject([&] { Import(t, image, {{"2", "Hook"}}, "shared", "Shared", true); }, "callbacks");
    }
    {
        Table t;
        t.entries = {{"10", "Group", "", "", {"1"}, true, true}, {"1", "Child", Hook, "10", {}}};
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
        ManifestDefaults(image, temporary);
        ChildActivation(image, temporary);
        auto exportPath = temporary / "readable patch";
        Export(package, exportPath);
        auto loaded = ReadPackage(exportPath / "patch.toml");
        auto c = Compile(loaded);
        assert(c.definition.bytes == d.bytes && c.definition.fixups.size() == d.fixups.size());
        auto original = ReadText(exportPath / "patch.toml");
        // GUI and CLI both publish through Export: verify the actual file is compact.
        auto exported = toml::parse(original);
        const auto &exportedScript = *exported["scripts"].as_array()->at(0).as_table();
        assert(exportedScript["id"].value<std::string>() == "1");
        assert(exportedScript["name"].value<std::string>() == "CT 1: Fixture");
        assert(!exportedScript.contains("feature"));
        assert(!exported["features"].as_array()->at(0).as_table()->contains("requires"));
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
