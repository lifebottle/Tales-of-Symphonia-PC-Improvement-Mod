#pragma once
/*
 * D3D9 Texture Replacement Proxy - CRC32
 * Computes CRC32 checksums of texture data for identification.
 * Uses the standard CRC32 polynomial (same as zlib).
 */

#include <cstdint>
#include <cstddef>

namespace detail {
    constexpr uint32_t crc32_table_entry(uint32_t idx) {
        uint32_t crc = idx;
        for (int j = 0; j < 8; j++) {
            if (crc & 1)
                crc = (crc >> 1) ^ 0xEDB88320;
            else
                crc >>= 1;
        }
        return crc;
    }

    struct CRC32Table {
        uint32_t entries[256];
        constexpr CRC32Table() : entries{} {
            for (uint32_t i = 0; i < 256; i++)
                entries[i] = crc32_table_entry(i);
        }
    };

    constexpr CRC32Table crc32_table{};
}

inline uint32_t crc32_compute(const void* data, size_t length) {
    const uint8_t* buf = static_cast<const uint8_t*>(data);
    uint32_t crc = 0xFFFFFFFF;
    for (size_t i = 0; i < length; i++) {
        crc = detail::crc32_table.entries[(crc ^ buf[i]) & 0xFF] ^ (crc >> 8);
    }
    return crc ^ 0xFFFFFFFF;
}
