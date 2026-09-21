#pragma once
#include "patch_script.h"
namespace PatchScript {
struct Entry {
    std::string id, name, script, parent;
    std::vector<std::string> children;
    bool group = false, activateChildren = false, callbacks = false;
};
struct Table {
    fs::path path;
    bool hasLua = false;
    std::vector<Entry> entries;
    static Table Read(const fs::path &path);
};
struct Selection {
    std::string id, key;
};
Package Import(const Table &table, const Image &image, const std::vector<Selection> &selected,
               const std::string &id, const std::string &section, bool ignoreLua = false);
// Publishes a complete package. Existing exports are never overwritten implicitly.
void Export(const Package &package, const fs::path &directory);
} // namespace PatchScript
