#include "patch_runtime.h"
#include <algorithm>
#include <cmath>
#include <set>
namespace PatchFramework {
namespace {
constexpr size_t Limit = 8 * 1024 * 1024;
bool Identifier(const std::string& s) {
    return !s.empty() && s.size() <= 80 && std::all_of(s.begin(),s.end(),[](unsigned char c) {
        return (c>='a' && c<='z') || (c>='A' && c<='Z') || (c>='0' && c<='9') || c=='_' || c=='-' || c=='.';
    });
}
std::string Key(std::string s) { for(auto& c:s) if(c>='A' && c<='Z') c+=32; return s; }
bool Range(size_t offset,size_t count,size_t size) { return offset<=size && count<=size-offset; }
}
bool Validate(const Definition& p,std::string& error) {
    auto fail=[&](const char* s) { error=s; return false; };
    if (!Identifier(p.id) || !Identifier(p.version) || !Identifier(p.configSection) ||
        !p.imageSize || p.imageSize>512*1024*1024 || p.features.empty() || p.features.size()>32 ||
        p.segments.empty() || p.segments.size()>4096 || p.fixups.size()>65536 ||
        p.guards.size()>4096 || p.parameters.size()>256 || p.bytes.size()>Limit)
        return fail("invalid definition header or limits");
    uint32_t bits=0;
    std::set<std::string> keys;
    for (const auto& f:p.features) {
        if (!f.bit || (f.bit & (f.bit-1)) || (bits & f.bit) || !Identifier(f.key) || !keys.insert(Key(f.key)).second)
            return fail("invalid/duplicate feature");
        bits |= f.bit;
        if (f.enableAbove && (!std::isfinite(*f.enableAbove) ||
            std::none_of(p.parameters.begin(), p.parameters.end(), [&](const Parameter& v) {
                return (v.group & f.bit) != 0;
            })))
            return fail("inferred feature needs a finite threshold and parameters");
    }
    for (const auto& f:p.features) if (f.dependencies & ~bits) return fail("unknown dependency");
    size_t allocated=0;
    for (const auto& s:p.segments) {
        if (!s.group || (s.group & ~bits) || s.count>s.size || !s.size ||
            !Range(s.bytes,s.count,p.bytes.size()) || s.name.size()>1024)
            return fail("invalid segment bounds/group");
        if (s.kind==Kind::Patch) {
            if (!s.count || s.count!=s.size || !Range(s.rva,s.count,p.imageSize) ||
                !Range(s.expected,s.count,p.bytes.size())) return fail("invalid patch bounds");
        } else {
            if (s.kind!=Kind::Code && s.kind!=Kind::Data) return fail("unknown segment kind");
            if (s.size>64*1024*1024) return fail("segment allocation limit exceeded");
            allocated+=s.size;
            if (allocated>64*1024*1024) return fail("allocation limit exceeded");
        }
    }
    for (size_t i=0;i<p.segments.size();++i) for (size_t j=0;j<i;++j) {
        const auto &a=p.segments[i], &b=p.segments[j];
        if (a.kind==Kind::Patch && b.kind==Kind::Patch && a.rva<b.rva+b.count && b.rva<a.rva+a.count)
            return fail("overlapping patches within definition");
    }
    for (const auto& f:p.fixups) {
        if (f.owner>=p.segments.size() || f.target < -1 ||
            (f.target>=0 && size_t(f.target)>=p.segments.size()) || (f.type!=1 && f.type!=2 && f.type!=23))
            return fail("invalid relocation");
        const auto& owner=p.segments[f.owner];
        if (!Range(f.offset,f.type==23 ? 1 : 4,owner.count)) return fail("relocation outside payload");
        if (f.target>=0) for (const auto& feature:p.features) {
            if ((owner.group & feature.bit) && !(Dependencies(p,feature.bit) & p.segments[f.target].group))
                return fail("relocation requires undeclared feature dependency");
        }
    }
    auto relocations=p.fixups;
    std::sort(relocations.begin(),relocations.end(),[](const Fixup& a,const Fixup& b) {
        return a.owner==b.owner ? a.offset<b.offset : a.owner<b.owner;
    });
    for (size_t i=1;i<relocations.size();++i) {
        const auto &a=relocations[i-1], &b=relocations[i];
        if (a.owner==b.owner && b.offset<a.offset+(a.type==23 ? 1 : 4))
            return fail("overlapping relocations");
    }
    for (const auto& g:p.guards)
        if (!g.group || (g.group & ~bits) || !g.count || !Range(g.rva,g.count,p.imageSize) ||
            !Range(g.bytes,g.count,p.bytes.size())) return fail("invalid guard");
    for (const auto& v:p.parameters) {
        if (!v.group || (v.group & ~bits) || v.segment>=p.segments.size() ||
            !Identifier(v.key) || !keys.insert(Key(v.key)).second || !std::isfinite(v.value) ||
            !std::isfinite(v.minimum) || !std::isfinite(v.maximum) || v.value<v.minimum || v.value>=v.maximum)
            return fail("invalid float parameter");
        if (v.integer && std::trunc(v.value) != v.value)
            return fail("integer parameter needs an integer default");
        const auto& s=p.segments[v.segment];
        if (s.kind!=Kind::Data || !Range(v.offset,4,s.size) || (v.group & ~s.group))
            return fail("parameter must address its feature's writable state");
        for (const auto& f:p.fixups)
            if (f.owner==v.segment && v.offset<f.offset+(f.type==23 ? 1 : 4) && f.offset<v.offset+4)
                return fail("parameter overlaps relocation");
    }
    for (size_t i=0;i<p.parameters.size();++i) for (size_t j=0;j<i;++j) {
        const auto &a=p.parameters[i], &b=p.parameters[j];
        if (a.segment==b.segment && a.offset<b.offset+4 && b.offset<a.offset+4)
            return fail("overlapping parameters");
    }
    error.clear(); return true;
}
uint32_t Dependencies(const Definition& p,uint32_t requested) {
    uint32_t old;
    do { old=requested; for (const auto& f:p.features) if (f.bit & requested) requested|=f.dependencies; } while (old!=requested);
    return requested;
}
}
