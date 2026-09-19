#pragma once
#include <windows.h>
#include <cstdio>
#include <string>

namespace IniSettings {
// Keep comments, values, existing whitespace and line endings. Only insert a
// blank line when a section immediately follows a nonblank line.
template<class Char>
std::basic_string<Char> SeparateSections(const std::basic_string<Char>& input) {
    using Text = std::basic_string<Char>;
    Text output;
    Text newline(1, Char('\n'));
    if (input.find(Text{Char('\r'), Char('\n')}) != Text::npos)
        newline.insert(newline.begin(), Char('\r'));
    bool content = false, previousBlank = true;
    for (size_t pos = 0; pos < input.size();) {
        auto end = input.find(Char('\n'), pos);
        end = end == Text::npos ? input.size() : end + 1;
        auto first = pos;
        while (first < end && (input[first] == Char(' ') || input[first] == Char('\t') ||
               input[first] == Char('\r') || input[first] == Char('\n'))) ++first;
        const bool blank = first == end;
        const bool section = !blank && input[first] == Char('[') &&
            input.find(Char(']'), first + 1) < end;
        if (section && content && !previousBlank) output += newline;
        output.append(input, pos, end - pos);
        content |= !blank;
        previousBlank = blank;
        pos = end;
    }
    return output;
}

inline bool SeparateSections(const wchar_t* path) {
    // Flush profile writes before editing the text. Write in place so editors
    // watching the INI continue watching the same file.
    WritePrivateProfileStringW(nullptr, nullptr, nullptr, path);
    FILE* file = _wfopen(path, L"r+b");
    if (!file) return false;
    if (std::fseek(file, 0, SEEK_END) != 0) { std::fclose(file); return false; }
    const long size = std::ftell(file);
    if (size < 0 || size > 1024 * 1024 || std::fseek(file, 0, SEEK_SET) != 0) {
        std::fclose(file); return false;
    }
    std::string original(static_cast<size_t>(size), '\0');
    if (std::fread(original.data(), 1, original.size(), file) != original.size()) {
        std::fclose(file); return false;
    }
    std::string formatted;
    const bool little = original.compare(0, 2, "\xff\xfe") == 0;
    const bool big = original.compare(0, 2, "\xfe\xff") == 0;
    if (little || big) {
        if (original.size() % 2) { std::fclose(file); return false; }
        std::u16string text;
        for (size_t i = 2; i < original.size(); i += 2) {
            const auto a = static_cast<unsigned char>(original[i]);
            const auto b = static_cast<unsigned char>(original[i + 1]);
            text += static_cast<char16_t>(little ? a | (b << 8) : (a << 8) | b);
        }
        formatted = original.substr(0, 2);
        for (char16_t c : SeparateSections(text)) {
            formatted += static_cast<char>(little ? c & 255 : c >> 8);
            formatted += static_cast<char>(little ? c >> 8 : c & 255);
        }
    } else {
        const size_t bom = original.compare(0, 3, "\xef\xbb\xbf") == 0 ? 3 : 0;
        formatted = original.substr(0, bom) + SeparateSections(original.substr(bom));
    }
    bool ok = true;
    if (formatted != original) {
        // Formatting only inserts bytes, so truncation is unnecessary.
        ok = std::fseek(file, 0, SEEK_SET) == 0 &&
             std::fwrite(formatted.data(), 1, formatted.size(), file) == formatted.size();
    }
    return std::fclose(file) == 0 && ok;
}

inline bool WriteDefault(const wchar_t* section, const wchar_t* key,
                         const wchar_t* value, const wchar_t* path) {
    return WritePrivateProfileStringW(section, key, value, path) && SeparateSections(path);
}
} // namespace IniSettings
