#pragma once
#include "patch_runtime.h"
#include <filesystem>
#include <map>
#include <set>

namespace PatchScript {
namespace fs = std::filesystem;
// Immutable, file-backed PE image. Never reads or modifies a running process.
struct Image {
    uint32_t base = 0, size = 0;
    std::string module;
    std::map<uint32_t, std::vector<uint8_t>> regions;
    static Image Read(const fs::path &path);
    std::vector<uint8_t> ReadBytes(uint32_t rva, size_t count) const;
    uint32_t Scan(const std::string &moduleName, const std::string &pattern) const;
};
struct Script {
    std::string id, name, file, feature, text;
    std::set<std::string> writable;
};
struct Parameter {
    std::string key, feature, script, symbol;
    float value = 0, minimum = 0, maximum = 1;
    bool integer = false, clamp = false;
};
struct Package {
    std::string id, version = "1", section, module = "TOS.exe";
    uint32_t imageBase = 0, imageSize = 0;
    std::vector<PatchFramework::Feature> features;
    std::vector<Script> scripts;
    std::vector<Parameter> parameters;
};
struct Compiled {
    PatchFramework::Definition definition;
    // script-id:symbol -> segment index / offset (image references use -1).
    std::map<std::string, std::pair<int32_t, uint32_t>> symbols;
};
Package ReadPackage(const fs::path &manifest);
std::string Manifest(const Package &package);
// Import mode captures missing original-byte assertions from image. Runtime mode
// requires existing assertions; it never blesses arbitrary current bytes.
Compiled Compile(Package &package, const Image *image = nullptr, bool importing = false);
std::string ReadText(const fs::path &file, size_t limit = 8 * 1024 * 1024);
std::string Lower(std::string text);
std::string Trim(const std::string &text);
std::string Hex(uint64_t value);
} // namespace PatchScript
