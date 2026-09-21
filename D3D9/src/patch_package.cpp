#include "patch_script.h"
#include "../third_party/tomlplusplus/toml.hpp"
#include <algorithm>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <stdexcept>
#include <cstring>
#include <regex>
#ifdef _WIN32
#include <windows.h>
#endif

namespace PatchScript {
std::string Lower(std::string s) {
    for (auto &c : s)
        if (c >= 'A' && c <= 'Z')
            c += 32;
    return s;
}
std::string Trim(const std::string &s) {
    auto a = s.find_first_not_of(" \t\r\n");
    return a == s.npos ? "" : s.substr(a, s.find_last_not_of(" \t\r\n") - a + 1);
}
std::string Hex(uint64_t v) {
    std::ostringstream s;
    s << "0x" << std::hex << v;
    return s.str();
}
std::string ReadText(const fs::path &path, size_t limit) {
    std::ifstream f(path, std::ios::binary | std::ios::ate);
    if (!f)
        throw std::runtime_error("Cannot open " + path.u8string());
    auto size = f.tellg();
    if (size < 0 || uint64_t(size) > limit)
        throw std::runtime_error("File exceeds size limit: " + path.u8string());
    std::string out(size_t(size), '\0');
    f.seekg(0);
    if (!f.read(out.data(), size))
        throw std::runtime_error("Cannot read " + path.u8string());
    return out;
}
namespace {
void Require(bool ok, const std::string &error) {
    if (!ok)
        throw std::runtime_error(error);
}
uint32_t Get(const std::string &s, size_t offset, size_t n) {
    Require(offset <= s.size() && n <= s.size() - offset, "Truncated PE executable");
    uint32_t value = 0;
    for (size_t i = 0; i < n; ++i)
        value |= uint32_t(uint8_t(s[offset + i])) << (i * 8);
    return value;
}
std::string String(const toml::table &t, const char *key) {
    auto value = t[key].value<std::string>();
    Require(value && !value->empty() && value->size() <= 1024 && value->find('\0') == std::string::npos,
            std::string("Invalid/missing field: ") + key);
    return *value;
}
uint32_t Number(const toml::table &t, const char *key) {
    auto v = t[key].value<int64_t>();
    Require(v && *v >= 0 && uint64_t(*v) <= UINT32_MAX, std::string("Invalid integer: ") + key);
    return uint32_t(*v);
}
float Float(const toml::table &t, const char *key) {
    auto v = t[key].value<double>();
    Require(bool(v), std::string("Invalid number: ") + key);
    return float(*v);
}
void Fields(const toml::table &t, std::initializer_list<const char *> allowed) {
    for (const auto &[key, value] : t) {
        (void)value;
        Require(std::any_of(allowed.begin(), allowed.end(), [&](auto s) { return key == s; }),
                "Unknown metadata field: " + std::string(key.str()));
    }
}
const toml::array &Array(const toml::table &t, const char *key, size_t limit) {
    static const toml::array empty;
    auto n = t.get(key);
    if (!n)
        return empty;
    auto a = n->as_array();
    Require(a && a->size() <= limit, std::string("Invalid array: ") + key);
    return *a;
}
bool Identifier(const std::string &s) {
    return !s.empty() && s.size() <= 80 && std::all_of(s.begin(), s.end(), [](char c) {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' ||
               c == '-' || c == '.';
    });
}
std::string DefaultFeature(const Package &p, const std::string &id) {
    if (p.features.size() == 1)
        return p.features.front().key;
    for (const auto &feature : p.features)
        if (feature.key == id)
            return feature.key;
    return {};
}
} // namespace
Image Image::Read(const fs::path &path) {
    auto raw = ReadText(path, 512 * 1024 * 1024);
    Image p;
    p.module = path.filename().u8string();
    Require(Get(raw, 0, 2) == 0x5a4d, "Expected MZ executable");
    auto nt = Get(raw, 0x3c, 4);
    Require(nt <= raw.size() && raw.size() - nt >= 24, "Truncated PE executable");
    Require(Get(raw, nt, 4) == 0x4550, "Expected PE executable");
    Require(Get(raw, nt + 4, 2) == 0x14c && Get(raw, nt + 24, 2) == 0x10b,
            "Only x86 PE32 executables are supported");
    auto count = Get(raw, nt + 6, 2), optional = Get(raw, nt + 20, 2);
    Require(optional >= 96 && count > 0 && count <= 96, "Invalid PE section table");
    p.base = Get(raw, nt + 24 + 28, 4);
    p.size = Get(raw, nt + 24 + 56, 4);
    Require(p.size && p.size <= 512 * 1024 * 1024 && uint64_t(p.base) + p.size <= 0x100000000ULL,
            "Invalid PE image layout");
    auto headers = Get(raw, nt + 24 + 60, 4);
    Require(headers <= raw.size() && headers <= p.size, "Invalid PE headers");
    p.regions[0] = {raw.begin(), raw.begin() + headers};
    for (uint32_t i = 0; i < count; ++i) {
        size_t at = size_t(nt) + 24 + optional + 40 * i;
        uint32_t va = Get(raw, at + 12, 4), vsize = Get(raw, at + 8, 4), size = Get(raw, at + 16, 4),
                 off = Get(raw, at + 20, 4);
        size = std::min(size, vsize ? vsize : size);
        if (!size)
            continue;
        Require(va <= p.size && size <= p.size - va && off <= raw.size() && size <= raw.size() - off,
                "Invalid PE section range");
        for (auto &[start, data] : p.regions)
            Require(uint64_t(va) + size <= start || va >= uint64_t(start) + data.size(),
                    "Overlapping PE sections");
        p.regions[va] = {raw.begin() + off, raw.begin() + off + size};
    }
    return p;
}
std::vector<uint8_t> Image::ReadBytes(uint32_t rva, size_t count) const {
    for (auto &[start, data] : regions)
        if (rva >= start && rva - start <= data.size() && count <= data.size() - (rva - start))
            return {data.begin() + (rva - start), data.begin() + (rva - start) + count};
    throw std::runtime_error("Address is not backed by executable bytes: +" + Hex(rva));
}
uint32_t Image::Scan(const std::string &name, const std::string &pattern) const {
    Require(Lower(name) == Lower(module), "AOB module differs from executable: " + name);
    std::istringstream in(pattern);
    std::string token;
    std::vector<std::pair<uint8_t, uint8_t>> bytes;
    bool fixed = false;
    while (in >> token) {
        if (token == "?" || token == "*")
            token += token;
        Require(token.size() == 2 && bytes.size() < 4096, "Invalid AOB pattern");
        uint8_t mask = 0, value = 0;
        for (char c : Lower(token)) {
            mask <<= 4;
            value <<= 4;
            if (c == '?' || c == '*')
                continue;
            Require((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f'), "Invalid AOB byte");
            mask |= 15;
            value |= c <= '9' ? c - '0' : c - 'a' + 10;
        }
        fixed |= mask != 0;
        bytes.push_back({mask, value});
    }
    Require(fixed, "AOB must contain fixed bits");
    bool found = false;
    uint32_t result = 0;
    for (auto &[start, data] : regions)
        if (data.size() >= bytes.size())
            for (size_t i = 0; i <= data.size() - bytes.size(); ++i) {
                bool match = true;
                for (size_t j = 0; j < bytes.size(); ++j)
                    if ((data[i + j] & bytes[j].first) != bytes[j].second) {
                        match = false;
                        break;
                    }
                if (match) {
                    Require(!found, "AOB is ambiguous: " + pattern);
                    found = true;
                    result = start + uint32_t(i);
                }
            }
    Require(found, "AOB did not match the executable: " + pattern);
    return result;
}
Package ReadPackage(const fs::path &manifest) {
    Require(manifest.extension() == ".toml", "Expected patch.toml; JSON patches require migration");
    auto text = ReadText(manifest);
    Require(text.find('\0') == text.npos, "NUL in metadata");
    auto t = toml::parse(text, manifest.u8string());
    Fields(t, {"format", "id", "version", "config_section", "image_base", "image_size", "module", "features",
               "scripts", "parameters"});
    Require(Number(t, "format") == 1, "Unsupported patch format version");
    Package p;
    p.id = String(t, "id");
    p.version = String(t, "version");
    p.section = String(t, "config_section");
    p.module = t["module"].value_or(std::string("TOS.exe"));
    p.imageBase = Number(t, "image_base");
    p.imageSize = Number(t, "image_size");
    Require(Identifier(p.id) && Identifier(p.version) && Identifier(p.section), "Invalid package identifier");
    std::map<std::string, uint32_t> features;
    std::set<std::string> keys;
    for (auto &node : Array(t, "features", 32)) {
        auto f = node.as_table();
        Require(f, "Invalid feature");
        Fields(*f, {"key", "requires"});
        auto key = String(*f, "key");
        Require(Identifier(key) && keys.insert(Lower(key)).second, "Invalid/duplicate feature key");
        uint32_t bit = uint32_t(1) << p.features.size();
        features[key] = bit;
        p.features.push_back({bit, 0, key});
    }
    Require(!p.features.empty(), "Package needs features");
    size_t index = 0;
    for (auto &node : Array(t, "features", 32)) {
        for (auto &req : Array(*node.as_table(), "requires", 32)) {
            auto key = req.value<std::string>();
            Require(key && features.count(*key), "Unknown feature dependency");
            p.features[index].dependencies |= features.at(*key);
        }
        ++index;
    }
    std::set<std::string> ids, files;
    size_t total = text.size();
    auto root = fs::weakly_canonical(manifest.parent_path());
    for (auto &node : Array(t, "scripts", 4096)) {
        auto s = node.as_table();
        Require(s, "Invalid script");
        Fields(*s, {"id", "name", "file", "feature", "writable"});
        Script script;
        script.file = String(*s, "file");
        fs::path rel = fs::u8path(script.file);
        script.id = s->contains("id") ? String(*s, "id") : rel.stem().u8string();
        script.name = s->contains("name") ? String(*s, "name") : script.id;
        script.feature = s->contains("feature") ? String(*s, "feature") : DefaultFeature(p, script.id);
        Require(Identifier(script.id) && ids.insert(Lower(script.id)).second, "Invalid/duplicate script ID");
        Require(!script.feature.empty(), "Cannot infer feature for script " + script.id +
                                            "; specify feature explicitly");
        Require(features.count(script.feature), "Unknown script feature");
        auto full = fs::weakly_canonical(root / rel);
        Require(!rel.is_absolute() && rel.extension() == ".asm" && !rel.has_root_name(),
                "Script must be a relative .asm path");
        auto relative = full.lexically_relative(root);
        Require(!relative.empty() && *relative.begin() != fs::path("..") &&
                    files.insert(Lower(full.u8string())).second,
                "Duplicate script or path outside package");
        script.text = ReadText(full);
        total += script.text.size();
        Require(total <= 8 * 1024 * 1024, "Package exceeds 8 MiB");
        for (auto &item : Array(*s, "writable", 4096)) {
            auto n = item.value<std::string>();
            Require(n && script.writable.insert(Lower(*n)).second, "Invalid writable allocation");
        }
        p.scripts.push_back(std::move(script));
    }
    Require(!p.scripts.empty(), "Package needs scripts");
    for (auto &node : Array(t, "parameters", 256)) {
        auto v = node.as_table();
        Require(v, "Invalid parameter");
        Fields(*v, {"key", "feature", "script", "symbol", "default", "min", "max_exclusive"});
        p.parameters.push_back({String(*v, "key"), String(*v, "feature"), String(*v, "script"),
                                String(*v, "symbol"), Float(*v, "default"), Float(*v, "min"),
                                Float(*v, "max_exclusive")});
    }
    return p;
}
std::string Manifest(const Package &p) {
    toml::table t{{"format", 1},
                  {"id", p.id},
                  {"version", p.version},
                  {"config_section", p.section},
                  {"image_base", int64_t(p.imageBase)},
                  {"image_size", int64_t(p.imageSize)},
                  {"module", p.module}};
    toml::array features, scripts, parameters;
    for (auto &f : p.features) {
        toml::array dependencies;
        for (auto &dep : p.features)
            if (dep.bit & f.dependencies)
                dependencies.push_back(dep.key);
        toml::table feature{{"key", f.key}};
        if (!dependencies.empty())
            feature.insert("requires", dependencies);
        features.push_back(std::move(feature));
    }
    for (auto &s : p.scripts) {
        toml::array writable;
        for (auto &name : s.writable)
            writable.push_back(name);
        toml::table script{{"file", s.file}};
        if (s.id != fs::u8path(s.file).stem().u8string())
            script.insert("id", s.id);
        if (s.name != s.id)
            script.insert("name", s.name);
        if (s.feature != DefaultFeature(p, s.id))
            script.insert("feature", s.feature);
        if (!writable.empty())
            script.insert("writable", writable);
        scripts.push_back(std::move(script));
    }
    for (auto &v : p.parameters)
        parameters.push_back(toml::table{{"key", v.key},
                                         {"feature", v.feature},
                                         {"script", v.script},
                                         {"symbol", v.symbol},
                                         {"default", double(v.value)},
                                         {"min", double(v.minimum)},
                                         {"max_exclusive", double(v.maximum)}});
    t.insert("features", features);
    t.insert("scripts", scripts);
    if (!parameters.empty())
        t.insert("parameters", parameters);
    std::ostringstream out;
    out << "# Readable patch package, format 1. Feature defaults remain off.\n" << t << '\n';
    return out.str();
}
} // namespace PatchScript

namespace PatchFramework {
bool Load(const std::wstring &filename, Definition &definition, std::string &error) {
    try {
        auto p = PatchScript::ReadPackage(std::filesystem::path(filename));
        // Export resolves scans to defines. Hand-maintained packages may still
        // request scans; resolve those against the host executable on disk.
        bool scans = false;
        const std::regex scan("(^|[\\r\\n])\\s*aobscanmodule\\s*\\(", std::regex::icase);
        for (const auto &script : p.scripts)
            scans |= std::regex_search(script.text, scan);
        PatchScript::Image image;
        const PatchScript::Image *reference = nullptr;
        if (scans) {
#ifdef _WIN32
            std::wstring path(32768, 0);
            auto n = GetModuleFileNameW(nullptr, path.data(), DWORD(path.size()));
            if (!n || n >= path.size())
                throw std::runtime_error("Cannot locate executable for AOB scans");
            path.resize(n);
            image = PatchScript::Image::Read(std::filesystem::path(path));
            reference = &image;
#else
            throw std::runtime_error("Package uses AOB scans; supply a reference executable to Compile");
#endif
        }
        definition = PatchScript::Compile(p, reference).definition;
        error.clear();
        return true;
    } catch (const std::exception &e) {
        error = e.what();
        return false;
    }
}
} // namespace PatchFramework
