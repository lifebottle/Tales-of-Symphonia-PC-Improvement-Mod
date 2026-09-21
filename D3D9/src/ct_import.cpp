#include "ct_import.h"
#include "../third_party/pugixml/src/pugixml.hpp"
#include <fstream>
#include <functional>
#include <regex>
#include <stdexcept>
#include <chrono>
namespace PatchScript {
Table Table::Read(const fs::path &path) {
    auto raw = ReadText(path, 32 * 1024 * 1024);
    auto lower = Lower(raw);
    if (lower.find("<!doctype") != lower.npos || lower.find("<!entity") != lower.npos)
        throw std::runtime_error("XML entities/DOCTYPE are unsupported");
    pugi::xml_document doc;
    auto result = doc.load_buffer(raw.data(), raw.size());
    if (!result)
        throw std::runtime_error(std::string("Invalid CT XML: ") + result.description());
    auto root = doc.child("CheatTable");
    if (!root)
        throw std::runtime_error("Expected CheatTable document");
    Table table;
    table.path = path;
    table.hasLua = !Trim(root.child_value("LuaScript")).empty();
    std::set<std::string> ids;
    std::function<void(pugi::xml_node, const std::string &, unsigned)> walk =
        [&](pugi::xml_node list, const std::string &parent, unsigned depth) {
            if (depth > 64)
                throw std::runtime_error("CT tree exceeds nesting limit");
            for (auto e : list.children("CheatEntry")) {
                Entry entry;
                entry.id = e.child_value("ID");
                entry.name = e.child_value("Description");
                if (entry.name.size() >= 2 && entry.name.front() == '"' && entry.name.back() == '"')
                    entry.name = entry.name.substr(1, entry.name.size() - 2);
                if (entry.id.empty() || entry.id.find_first_not_of("0123456789") != entry.id.npos ||
                    !ids.insert(entry.id).second)
                    throw std::runtime_error("Missing/duplicate CT entry ID");
                entry.script = e.child_value("AssemblerScript");
                entry.parent = parent;
                entry.group = std::string(e.child_value("GroupHeader")) == "1";
                entry.activateChildren = e.child("Options").attribute("moActivateChildrenAsWell").as_bool();
                entry.callbacks = bool(e.child("OnActivate")) || bool(e.child("OnDeactivate"));
                for (auto child : e.child("CheatEntries").children("CheatEntry"))
                    entry.children.push_back(child.child_value("ID"));
                table.entries.push_back(entry);
                if (table.entries.size() > 50000)
                    throw std::runtime_error("Too many CT entries");
                walk(e.child("CheatEntries"), entry.id, depth + 1);
            }
        };
    walk(root.child("CheatEntries"), "", 0);
    return table;
}
Package Import(const Table &table, const Image &image, const std::vector<Selection> &selected,
               const std::string &id, const std::string &section, bool ignoreLua, bool children) {
    if (table.hasLua && !ignoreLua)
        throw std::runtime_error(
            "Table-level Lua is present. Explicitly ignore it only for independent static entries.");
    if (selected.empty() || selected.size() > 32)
        throw std::runtime_error("Select 1–32 feature roots");
    std::map<std::string, const Entry *> entries;
    for (auto &e : table.entries)
        entries[e.id] = &e;
    Package p;
    p.id = id;
    p.section = section;
    p.imageBase = image.base;
    p.imageSize = image.size;
    p.module = image.module;
    std::map<std::string, std::string> roots;
    std::set<std::string> keys, seen;
    for (auto &s : selected) {
        auto key = s.key.empty() ? "Entry" + s.id : s.key;
        if (!std::regex_match(key, std::regex("[A-Za-z_][A-Za-z_0-9]{0,79}")) ||
            !keys.insert(Lower(key)).second)
            throw std::runtime_error("Feature keys must be unique INI identifiers");
        if (!entries.count(s.id) || !roots.emplace(s.id, key).second)
            throw std::runtime_error("Unknown/duplicate selected CT ID: " + s.id);
        p.features.push_back({uint32_t(1) << p.features.size(), 0, key});
    }
    std::function<void(const std::string &, std::string)> visit = [&](const std::string &id,
                                                                      std::string key) {
        if (!seen.insert(id).second)
            return;
        const auto &e = *entries.at(id);
        if (roots.count(id))
            key = roots[id];
        if (e.callbacks)
            throw std::runtime_error("Entry " + e.id + " (" + e.name +
                                     "): activation callbacks are unsupported");
        if (!e.script.empty())
            p.scripts.push_back(
                {e.id, "CT " + e.id + ": " + e.name, "entry-" + e.id + ".asm", key, e.script, {}});
        else if (!e.group)
            throw std::runtime_error("Entry " + e.id + " (" + e.name +
                                     "): pointer/value records and freezes are unsupported");
        if (children && (e.group || e.activateChildren))
            for (auto &child : e.children)
                visit(child, key);
    };
    for (auto &s : selected)
        visit(s.id, roots[s.id]);
    Compile(p, &image, true);
    // A second compile validates the actual exported text and explicit writable
    // metadata using precisely the runtime path, without a reference executable.
    Compile(p);
    return p;
}
void Export(const Package &p, const fs::path &directory) {
    auto copy = p;
    Compile(copy);
    std::set<std::string> files;
    for (const auto &script : p.scripts) {
        auto relative = fs::u8path(script.file);
        if (relative.is_absolute() || relative.has_root_name() || relative.extension() != ".asm" ||
            !files.insert(Lower(script.file)).second)
            throw std::runtime_error("Invalid export script path");
        for (const auto &part : relative)
            if (part == "..")
                throw std::runtime_error("Export script path escapes package");
    }
    if (fs::exists(directory))
        throw std::runtime_error(
            "Export folder already exists; choose a new folder to preserve the previous export");
    auto parent = fs::absolute(directory).parent_path();
    fs::create_directories(parent);
    auto staging = parent / (".tos-export-" +
                             std::to_string(std::chrono::steady_clock::now().time_since_epoch().count()));
    if (!fs::create_directory(staging))
        throw std::runtime_error("Cannot create export staging directory");
    try {
        auto write = [&](const fs::path &path, const std::string &text) {
            fs::create_directories(path.parent_path());
            std::ofstream f(path, std::ios::binary);
            f.write(text.data(), std::streamsize(text.size()));
            f.close();
            if (!f)
                throw std::runtime_error("Cannot write export file");
        };
        write(staging / "patch.toml", Manifest(p));
        for (auto &script : p.scripts)
            write(staging / fs::u8path(script.file), script.text);
        std::string readme =
            "Copy this entire folder into patches beside d3d9.dll.\nEnable desired keys in d3d9_config.ini "
            "and restart the game.\nDo not simultaneously enable the same hooks in Cheat Engine.\n\n[" +
            p.section + "]\n";
        for (auto &feature : p.features)
            readme += feature.key + "=0\n";
        readme += "\nChange the desired feature values to 1. No settings are changed by export.\n";
        write(staging / "INSTALL.txt", readme);
        auto checked = ReadPackage(staging / "patch.toml");
        Compile(checked);
        fs::rename(staging, directory);
    } catch (...) {
        fs::remove_all(staging);
        throw;
    }
}
} // namespace PatchScript
