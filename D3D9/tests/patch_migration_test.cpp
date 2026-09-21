#include "patch_script.h"
#include <cassert>
#include <fstream>
#include <iostream>
#include <sstream>
using namespace PatchScript;
using namespace PatchFramework;
int main() {
    std::map<std::string, Compiled> packages;
    for (auto name : {"add-spell-slots", "battle-enhancements", "lloyd-super-chain", "minimum-damage"}) {
        auto p = ReadPackage(fs::path("D3D9/patches") / name / "patch.toml");
        packages[name] = Compile(p);
    }
    using ByteKey = std::tuple<std::string, std::string, uint32_t>;
    using SiteKey = std::tuple<std::string, std::string, uint32_t, size_t>;
    std::map<ByteKey, uint8_t> oldBytes, newBytes;
    std::set<SiteKey> oldSites, newSites;
    std::ifstream file("D3D9/tests/patches/fixtures/migration-sites.txt");
    assert(file);
    std::string row;
    while (std::getline(file, row)) {
        if (row.empty() || row[0] == '#')
            continue;
        std::istringstream in(row);
        std::string kind, name, feature, rva, hex;
        in >> kind >> name >> feature >> rva >> hex;
        assert(in);
        uint32_t start = std::stoul(rva, nullptr, 0);
        if (kind == "P")
            oldSites.emplace(name, feature, start, hex.size() / 2);
        for (size_t i = 0; i < hex.size(); i += 2) {
            auto key = ByteKey{name, feature, start + uint32_t(i / 2)};
            auto value = uint8_t(std::stoul(hex.substr(i, 2), nullptr, 16));
            auto found = oldBytes.find(key);
            assert(found == oldBytes.end() || found->second == value);
            oldBytes[key] = value;
        }
    }
    for (auto &[name, c] : packages) {
        auto &d = c.definition;
        assert(d.imageBase == 0x400000 && d.imageSize == 0x2b00000);
        auto add = [&](uint32_t group, uint32_t rva, uint32_t offset, uint32_t count, bool patch) {
            for (auto &f : d.features)
                if (group & f.bit) {
                    if (patch)
                        newSites.emplace(name, f.key, rva, count);
                    for (uint32_t i = 0; i < count; ++i) {
                        auto key = ByteKey{name, f.key, rva + i};
                        auto value = d.bytes[offset + i];
                        auto found = newBytes.find(key);
                        assert(found == newBytes.end() || found->second == value);
                        newBytes[key] = value;
                    }
                }
        };
        for (auto &s : d.segments)
            if (s.kind == Kind::Patch)
                add(s.group, s.rva, s.expected, s.count, true);
        for (auto &g : d.guards)
            add(g.group, g.rva, g.bytes, g.count, false);
    }
    assert(oldSites == newSites);
    assert(oldBytes == newBytes);
    auto &battle = packages.at("battle-enhancements").definition;
    assert(battle.features.size() == 5 && battle.features[1].dependencies == 1 &&
           battle.features[2].dependencies == 1 && battle.features[3].dependencies == 0 &&
           battle.features[4].dependencies == 0);
    assert(battle.parameters.size() == 1 && battle.parameters[0].key == "FreeRunMovementPenalty" &&
           battle.parameters[0].value == 0.2f);
    auto &slots = packages.at("add-spell-slots").definition;
    assert(slots.parameters.size() == 2 && slots.parameters[0].value == 1 && slots.parameters[1].value == 1);
    auto &arena = slots.segments.at(packages.at("add-spell-slots").symbols.at("state:arena").first);
    assert(arena.kind == Kind::Data && arena.size == 0x280000);
    std::cout << "Migration matched " << oldSites.size() << " original patch sites and " << oldBytes.size()
              << " guarded bytes across all four packages.\n";
}
