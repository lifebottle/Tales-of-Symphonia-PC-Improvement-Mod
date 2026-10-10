#pragma once

#include <windows.h>
#include <algorithm>
#include <string>
#include <system_error>
#include <vector>

// Resolve ordinary paths before opting into Windows extended-length syntax.
inline std::wstring ExtendedFilePath(
    const std::wstring& input, std::error_code& ec)
{
    ec.clear();

    if (input.empty()) {
        ec = std::error_code(ERROR_INVALID_NAME, std::system_category());
        return {};
    }

    if (input.compare(0, 4, L"\\\\?\\") == 0)
        return input;

    std::wstring normalized = input;
    std::replace(normalized.begin(), normalized.end(), L'/', L'\\');

    std::vector<wchar_t> buffer(256);
    for (;;) {
        DWORD length = GetFullPathNameW(
            normalized.c_str(),
            static_cast<DWORD>(buffer.size()),
            buffer.data(),
            nullptr);

        if (length == 0) {
            ec = std::error_code(GetLastError(), std::system_category());
            return {};
        }

        if (length >= buffer.size()) {
            buffer.resize(static_cast<size_t>(length) + 1);
            continue;
        }

        std::wstring absolute(buffer.data(), length);
        if (absolute.compare(0, 2, L"\\\\") == 0)
            return L"\\\\?\\UNC\\" + absolute.substr(2);

        return L"\\\\?\\" + absolute;
    }
}
