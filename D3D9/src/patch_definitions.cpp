#include "patch_runtime.h"
#include "logger.h"
#include "ini_settings.h"
#include "../third_party/nlohmann/json.hpp"
#include <map>
#include <windows.h>
#include <algorithm>
#include <cmath>
#include <charconv>
#include <cstring>
#include <cwchar>
#include <set>
#include <stdexcept>

namespace PatchFramework {
namespace {
constexpr size_t Limit = 8 * 1024 * 1024;
bool Identifier(const std::string& s) {
    return !s.empty() && s.size() <= 80 && std::all_of(s.begin(), s.end(), [](unsigned char c) {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
               (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.';
    });
}
std::string Key(std::string s) {
    for (auto& c:s) if (c>='A' && c<='Z') c=static_cast<char>(c-'A'+'a');
    return s;
}
bool Range(size_t offset, size_t count, size_t size) { return offset <= size && count <= size-offset; }
using Json = nlohmann::json;
void Fields(const Json& object, std::initializer_list<const char*> allowed) {
    if (!object.is_object()) throw std::runtime_error("expected JSON object");
    for (auto it=object.begin();it!=object.end();++it)
        if (std::none_of(allowed.begin(),allowed.end(),[&](const char* key) { return it.key()==key; }))
            throw std::runtime_error("unknown field: "+it.key());
}
uint32_t U32(const Json& value) {
    uint64_t result=0;
    if (value.is_number_unsigned()) result=value.get<uint64_t>();
    else if (value.is_number_integer()) {
        auto n=value.get<int64_t>();
        if (n<0) throw std::runtime_error("expected unsigned integer");
        result=static_cast<uint64_t>(n);
    } else if (value.is_string()) {
        const auto s=value.get<std::string>();
        size_t i=0; unsigned base=10;
        if (s.size()>2 && s[0]=='0' && (s[1]=='x' || s[1]=='X')) { base=16; i=2; }
        if (i==s.size()) throw std::runtime_error("empty integer");
        for (;i<s.size();++i) {
            const char c=s[i];
            unsigned digit=c>='0' && c<='9' ? c-'0' : c>='a' && c<='f' ? c-'a'+10 : c>='A' && c<='F' ? c-'A'+10 : 99;
            if (digit>=base || result>(UINT32_MAX-digit)/base) throw std::runtime_error("invalid 32-bit integer: "+s);
            result=result*base+digit;
        }
    } else throw std::runtime_error("expected integer or hex string");
    if (result>UINT32_MAX) throw std::runtime_error("32-bit integer overflow");
    return static_cast<uint32_t>(result);
}
std::string Text(const Json& value) {
    if (!value.is_string()) throw std::runtime_error("expected string");
    auto s=value.get<std::string>();
    if (s.size()>1024 || s.find('\0')!=std::string::npos) throw std::runtime_error("invalid string length/NUL");
    return s;
}
const Json& Array(const Json& object,const char* key,size_t limit) {
    static const Json empty=Json::array();
    const auto it=object.find(key);
    if (it==object.end()) return empty;
    if (!it->is_array() || it->size()>limit) throw std::runtime_error(std::string("invalid array: ")+key);
    return *it;
}
std::vector<uint8_t> Hex(const Json& value) {
    if (!value.is_string()) throw std::runtime_error("expected hex byte string");
    const auto& s=value.get_ref<const std::string&>();
    std::vector<uint8_t> bytes;
    int high=-1;
    for (char c:s) {
        if (c==' ' || c=='\t' || c=='\r' || c=='\n') continue;
        int n=c>='0' && c<='9' ? c-'0' : c>='a' && c<='f' ? c-'a'+10 : c>='A' && c<='F' ? c-'A'+10 : -1;
        if (n<0) throw std::runtime_error("invalid hex byte");
        if (high<0) high=n;
        else { bytes.push_back(static_cast<uint8_t>((high<<4)|n)); high=-1; }
    }
    if (high>=0) throw std::runtime_error("odd hex byte count");
    return bytes;
}
float Number(const Json& value) {
    if (!value.is_number()) throw std::runtime_error("expected numeric parameter value");
    return value.get<float>();
}
std::wstring Wide(const std::string& s) { return std::wstring(s.begin(),s.end()); }
std::wstring Setting(const Definition& p,const std::wstring& ini,const std::string& key,const wchar_t* fallback) {
    wchar_t value[128];
    const auto section=Wide(p.configSection), name=Wide(key);
    GetPrivateProfileStringW(section.c_str(),name.c_str(),L"",value,128,ini.c_str());
    if (!value[0]) {
        IniSettings::WriteDefault(section.c_str(),name.c_str(),fallback,ini.c_str());
        return fallback;
    }
    return value;
}
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

bool Parse(const std::vector<uint8_t>& bytes,Definition& definition,std::string& error) {
    try {
        if (bytes.empty() || bytes.size()>Limit || std::find(bytes.begin(),bytes.end(),0)!=bytes.end()) throw std::runtime_error("invalid JSON file size");
        std::vector<std::set<std::string>> objectKeys;
        auto callback=[&](int depth,Json::parse_event_t event,Json& value) {
            if (depth>32) throw std::runtime_error("JSON nesting limit exceeded");
            if (event==Json::parse_event_t::object_start) objectKeys.emplace_back();
            if (event==Json::parse_event_t::object_end) objectKeys.pop_back();
            if (event==Json::parse_event_t::key && !objectKeys.back().insert(value.get<std::string>()).second)
                throw std::runtime_error("duplicate JSON key: "+value.get<std::string>());
            return true;
        };
        const auto root=Json::parse(bytes.begin(),bytes.end(),callback);
        Fields(root,{"id","version","config_section","image_size","image_base","features","segments","fixups","guards","parameters"});
        Definition p;
        p.id=Text(root.at("id")); p.version=Text(root.value("version",Json("1")));
        p.configSection=Text(root.at("config_section"));
        p.imageSize=U32(root.at("image_size")); p.imageBase=U32(root.value("image_base",Json(0)));
        std::map<std::string,uint32_t> features, segments;
        const auto& featureList=Array(root,"features",32);
        for (const auto& f:featureList) {
            Fields(f,{"key","requires"});
            auto key=Text(f.at("key"));
            uint32_t bit=uint32_t(1)<<p.features.size();
            if (!features.emplace(key,bit).second) throw std::runtime_error("duplicate feature: "+key);
            p.features.push_back({bit,0,key});
        }
        auto feature=[&](const Json& name) {
            auto key=Text(name); auto it=features.find(key);
            if (it==features.end()) throw std::runtime_error("unknown feature: "+key);
            return it->second;
        };
        for (size_t i=0;i<featureList.size();++i)
            for (const auto& dep:Array(featureList[i],"requires",32)) p.features[i].dependencies|=feature(dep);
        auto append=[&](const std::vector<uint8_t>& data) {
            if (data.size()>Limit-p.bytes.size()) throw std::runtime_error("payload size limit exceeded");
            auto offset=static_cast<uint32_t>(p.bytes.size());
            p.bytes.insert(p.bytes.end(),data.begin(),data.end()); return offset;
        };
        for (const auto& s:Array(root,"segments",4096)) {
            Fields(s,{"id","group","kind","name","bytes","size","rva","expected"});
            const auto id=Text(s.at("id")), kind=Text(s.at("kind"));
            if (id.empty() || !segments.emplace(id,static_cast<uint32_t>(p.segments.size())).second)
                throw std::runtime_error("empty/duplicate segment ID");
            Kind type;
            if (kind=="patch") type=Kind::Patch;
            else if (kind=="code") type=Kind::Code;
            else if (kind=="data") type=Kind::Data;
            else throw std::runtime_error("unknown segment kind: "+kind);
            auto payload=Hex(s.at("bytes"));
            auto expected=type==Kind::Patch ? Hex(s.at("expected")) : std::vector<uint8_t>{};
            if (type==Kind::Patch && payload.size()!=expected.size()) throw std::runtime_error("patch and expected lengths differ");
            if (type!=Kind::Patch && (s.contains("rva") || s.contains("expected"))) throw std::runtime_error("rva/expected only apply to patches");
            const auto count=static_cast<uint32_t>(payload.size());
            p.segments.push_back({feature(s.at("group")),type,U32(s.value("size",Json(count))),append(payload),count,
                                 type==Kind::Patch ? U32(s.at("rva")) : 0,append(expected),Text(s.value("name",Json(id)))});
        }
        auto segment=[&](const Json& value) {
            auto id=Text(value); auto it=segments.find(id);
            if (it==segments.end()) throw std::runtime_error("unknown segment: "+id);
            return it->second;
        };
        for (const auto& f:Array(root,"fixups",65536)) {
            Fields(f,{"owner","offset","target","addend","type"});
            auto type=Text(f.at("type"));
            uint32_t kind=type=="abs32" ? 1 : type=="rel32" ? 2 : type=="rel8" ? 23 : 0;
            p.fixups.push_back({segment(f.at("owner")),U32(f.at("offset")),
                f.at("target").is_null() ? -1 : static_cast<int32_t>(segment(f.at("target"))),
                U32(f.value("addend",Json(0))),kind});
        }
        for (const auto& g:Array(root,"guards",4096)) {
            Fields(g,{"group","rva","expected"});
            auto expected=Hex(g.at("expected"));
            p.guards.push_back({feature(g.at("group")),U32(g.at("rva")),append(expected),static_cast<uint32_t>(expected.size())});
        }
        for (const auto& v:Array(root,"parameters",256)) {
            Fields(v,{"key","group","segment","offset","default","min","max_exclusive"});
            p.parameters.push_back({feature(v.at("group")),segment(v.at("segment")),U32(v.at("offset")),
                Number(v.at("default")),Number(v.at("min")),Number(v.at("max_exclusive")),Text(v.at("key"))});
        }
        if (!Validate(p,error)) return false;
        definition=std::move(p); error.clear(); return true;
    } catch (const std::exception& e) { error=e.what(); return false; }
}

bool Load(const std::wstring& filename,Definition& definition,std::string& error) {
    HANDLE file=CreateFileW(filename.c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,nullptr);
    if (file==INVALID_HANDLE_VALUE) { error="cannot open definition"; return false; }
    LARGE_INTEGER size{};
    if (!GetFileSizeEx(file,&size) || size.QuadPart<0 || size.QuadPart>static_cast<LONGLONG>(Limit)) {
        CloseHandle(file); error="invalid definition file size"; return false;
    }
    std::vector<uint8_t> bytes(static_cast<size_t>(size.QuadPart));
    DWORD read=0;
    bool ok=ReadFile(file,bytes.data(),static_cast<DWORD>(bytes.size()),&read,nullptr) && read==bytes.size();
    CloseHandle(file);
    if (!ok) { error="cannot read definition"; return false; }
    return Parse(bytes,definition,error);
}

uint32_t Dependencies(const Definition& p,uint32_t requested) {
    uint32_t old;
    do { old=requested; for (const auto& f:p.features) if (f.bit & requested) requested|=f.dependencies; } while (old!=requested);
    return requested;
}
Options ReadOptions(const Definition& p,const std::wstring& ini) {
    Options result;
    for (const auto& f:p.features) {
        auto value=Setting(p,ini,f.key,L"0");
        if (value==L"1") result.enabled|=f.bit;
        else if (value!=L"0") LOG("[Patches] %s: invalid %s; disabled",p.id.c_str(),f.key.c_str());
    }
    auto expanded=Dependencies(p,result.enabled);
    if (expanded!=result.enabled) LOG("[Patches] %s: enabling required dependencies",p.id.c_str());
    result.enabled=expanded;
    for (const auto& v:p.parameters) {
        char buffer[64];
        const auto converted=std::to_chars(buffer,buffer+sizeof(buffer),v.value);
        if (converted.ec!=std::errc()) throw std::runtime_error("cannot format parameter default");
        std::string decimal(buffer,converted.ptr);
        const auto dot=decimal.find('.');
        if (dot!=std::string::npos && decimal.find_first_of("eE")==std::string::npos && decimal.size()-dot==2)
            decimal+='0';
        auto text=Setting(p,ini,v.key,Wide(decimal).c_str());
        wchar_t* end=nullptr;
        float value=std::wcstof(text.c_str(),&end);
        if (end==text.c_str() || *end || !std::isfinite(value) || value<v.minimum || value>=v.maximum) {
            LOG("[Patches] %s: invalid %s; using default",p.id.c_str(),v.key.c_str()); value=v.value;
        }
        result.parameters.push_back(value);
    }
    return result;
}
}
