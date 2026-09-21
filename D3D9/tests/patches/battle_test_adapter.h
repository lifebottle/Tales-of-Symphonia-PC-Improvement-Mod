#pragma once
#include "patch_script.h"
#include <windows.h>
#include <algorithm>
#include <array>
#include <cassert>
#include <cmath>
#include <cstring>
#include <iterator>
#include <vector>
namespace BattlePatches {
constexpr uint32_t ArtesSphere=1, NewFreeRun=2, ManualOverLimit=4, OverLimitGauge=8, SpellQueueFix=16;
inline const PatchScript::Compiled& TestCompiled() {
    static auto compiled=[] {
        auto p=PatchScript::ReadPackage("D3D9/patches/battle-enhancements/patch.toml");
        auto c=PatchScript::Compile(p);c.definition.imageBase=0;return c;
    }();return compiled;
}
inline const PatchFramework::Definition& TestDefinition(){return TestCompiled().definition;}
namespace Data {
using Kind=PatchFramework::Kind;
inline const auto& Segments=TestDefinition().segments;
inline const auto& Fixups=TestDefinition().fixups;
inline const auto& Guards=TestDefinition().guards;
inline const auto* Bytes=TestDefinition().bytes.data();
inline const auto ImageSize=TestDefinition().imageSize;
inline const auto PenaltySegment=TestCompiled().symbols.at("NewFreeRun:penaltyspeed").first;
inline const auto ControlsSegment=TestCompiled().symbols.at("ArtesSphere:storedcontrols").first;
inline const auto CharBufferSegment=TestCompiled().symbols.at("ArtesSphere:charbuffer").first;
}
inline const size_t SegmentCount=Data::Segments.size();
struct Options {uint32_t enabled=0;float penalty=0.20f;};
inline uint32_t Dependencies(uint32_t enabled){return PatchFramework::Dependencies(TestDefinition(),enabled);}
inline Options ReadOptions(const std::wstring& ini){auto o=PatchFramework::ReadOptions(TestDefinition(),ini);return {o.enabled,o.parameters.at(0)};}
inline bool Install(uint8_t* image,size_t size,const Options& options){PatchFramework::Session session;std::string error;return PatchFramework::Install(session,TestDefinition(),image,size,{options.enabled,{options.penalty}},error);}
}
