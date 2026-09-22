#include "patch_runtime.h"
#include "logger.h"
#include "ini_settings.h"
#include <windows.h>
#include <algorithm>
#include <charconv>
#include <cmath>
#include <stdexcept>
namespace PatchFramework {
namespace {
std::wstring Wide(const std::string &s) { return std::wstring(s.begin(), s.end()); }
std::wstring Setting(const Definition &p, const std::wstring &ini, const std::string &key,
                     const wchar_t *fallback) {
    wchar_t value[128];
    const auto section = Wide(p.configSection), name = Wide(key);
    GetPrivateProfileStringW(section.c_str(), name.c_str(), L"", value, 128, ini.c_str());
    if (!value[0]) {
        IniSettings::WriteDefault(section.c_str(), name.c_str(), fallback, ini.c_str());
        return fallback;
    }
    return value;
}
} // namespace
Options ReadOptions(const Definition &p, const std::wstring &ini) {
    Options result;
    for (const auto &f : p.features) {
        if (f.enableAbove)
            continue;
        auto value = Setting(p, ini, f.key, L"0");
        if (value == L"1")
            result.enabled |= f.bit;
        else if (value != L"0")
            LOG("[Patches] %s: invalid %s; disabled", p.id.c_str(), f.key.c_str());
    }
    for (const auto &v : p.parameters) {
        char buffer[64];
        const auto converted = std::to_chars(buffer, buffer + sizeof(buffer), v.value);
        if (converted.ec != std::errc())
            throw std::runtime_error("cannot format parameter default");
        std::string decimal(buffer, converted.ptr);
        const auto dot = decimal.find('.');
        if (dot != std::string::npos && decimal.find_first_of("eE") == std::string::npos &&
            decimal.size() - dot == 2)
            decimal += '0';
        auto text = Setting(p, ini, v.key, Wide(decimal).c_str());
        wchar_t *end = nullptr;
        float value = std::wcstof(text.c_str(), &end);
        if (end == text.c_str() || *end || !std::isfinite(value)) {
            LOG("[Patches] %s: invalid %s; using default", p.id.c_str(), v.key.c_str());
            value = v.value;
        } else {
            if (v.integer)
                value = std::trunc(value);
            if (v.clamp) {
                const float upper = std::nextafter(v.maximum, v.minimum);
                value = std::clamp(value, v.integer ? std::ceil(v.minimum) : v.minimum,
                                   v.integer ? std::floor(upper) : upper);
            } else if (value < v.minimum || value >= v.maximum) {
                LOG("[Patches] %s: invalid %s; using default", p.id.c_str(), v.key.c_str());
                value = v.value;
            }
        }
        result.parameters.push_back(value);
    }
    for (const auto &f : p.features) {
        if (!f.enableAbove)
            continue;
        for (size_t i = 0; i < p.parameters.size(); ++i)
            if ((p.parameters[i].group & f.bit) && result.parameters[i] > *f.enableAbove)
                result.enabled |= f.bit;
    }
    auto expanded = Dependencies(p, result.enabled);
    if (expanded != result.enabled)
        LOG("[Patches] %s: enabling required dependencies", p.id.c_str());
    result.enabled = expanded;
    return result;
}
} // namespace PatchFramework
