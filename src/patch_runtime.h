#pragma once
#include <cstdint>
#include <cstddef>
#include <string>
#include <optional>
#include <vector>

// Host-independent definition model. Installation is implemented by the Win32 backend.
namespace PatchFramework {
enum class Kind : uint32_t { Code, Data, Patch };
struct SourceLocation {
    std::string file;
    size_t line = 0;
};
struct Segment {
    uint32_t group; Kind kind;
    uint32_t size, bytes, count, rva, expected;
    std::string name;
    SourceLocation source = {};
};
struct Fixup { uint32_t owner, offset; int32_t target; uint32_t addend, type; };
struct Guard { uint32_t group, rva, bytes, count; SourceLocation source = {}; };
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
    struct Range {
        uintptr_t start, end;
        bool write;
        std::string owner = {};
    };
    std::vector<Range> ranges;
    std::vector<std::string> installed;
};

// Shared by validation and runtime; endpoints are stored exclusive, displayed inclusive.
bool Conflicts(const Session::Range& a, const Session::Range& b);
std::string DescribeOwner(const Definition& definition, uint32_t group,
                          const std::string& name, const SourceLocation& source);
std::string DescribeConflict(const Session::Range& a, const Session::Range& b,
                             uintptr_t imageBase = 0);

bool Load(const std::wstring& filename, Definition& definition, std::string& error);
bool Validate(const Definition& definition, std::string& error);
uint32_t Dependencies(const Definition& definition, uint32_t requested);
Options ReadOptions(const Definition& definition, const std::wstring& ini);
bool Install(Session& session, const Definition& definition, uint8_t* image, size_t imageSize,
             const Options& options, std::string& error);
// Built-in hooks share the host session with external patch packages.
bool InstallBuiltin(const Definition& definition, std::string& error);
bool ProcessImage(uint8_t*& image, size_t& imageSize, std::string& error);
}
