#pragma once
#include <cstdint>
#include <cstddef>
#include <string>
#include <optional>
#include <vector>

// Host-independent definition model. Installation is implemented by the Win32 backend.
namespace PatchFramework {
enum class Kind : uint32_t { Code, Data, Patch };
struct Segment {
    uint32_t group; Kind kind;
    uint32_t size, bytes, count, rva, expected;
    std::string name;
};
struct Fixup { uint32_t owner, offset; int32_t target; uint32_t addend, type; };
struct Guard { uint32_t group, rva, bytes, count; };
struct Feature {
    uint32_t bit, dependencies;
    std::string key;
    std::optional<float> enableAbove = std::nullopt; // infer from this feature's parameters
};
struct Parameter {
    uint32_t group, segment, offset;
    float value, minimum, maximum; // minimum inclusive, maximum exclusive
    std::string key;
    bool integer = false, clamp = false;
};
struct Definition {
    uint32_t imageSize = 0, imageBase = 0;
    std::string id, version, configSection;
    std::vector<Feature> features;
    std::vector<Parameter> parameters;
    std::vector<uint8_t> bytes;
    std::vector<Segment> segments;
    std::vector<Fixup> fixups;
    std::vector<Guard> guards;
};
struct Options { uint32_t enabled = 0; std::vector<float> parameters; };
// One session per target process/image. Retain it for the lifetime of installed
// hooks. Records ownership to reject collisions, including guarded destinations.
struct Session {
    struct Range { uintptr_t start, end; bool write; };
    std::vector<Range> ranges;
    std::vector<std::string> installed;
};

bool Load(const std::wstring& filename, Definition& definition, std::string& error);
bool Validate(const Definition& definition, std::string& error);
uint32_t Dependencies(const Definition& definition, uint32_t requested);
Options ReadOptions(const Definition& definition, const std::wstring& ini);
bool Install(Session& session, const Definition& definition, uint8_t* image, size_t imageSize,
             const Options& options, std::string& error);
bool ProcessImage(uint8_t*& image, size_t& imageSize, std::string& error);
}
