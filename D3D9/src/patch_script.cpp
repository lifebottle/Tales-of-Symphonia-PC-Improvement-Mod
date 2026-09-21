#include "patch_script.h"
#include <asmtk/asmtk.h>
#include <asmjit/x86.h>
#include <Zydis/Zydis.h>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <functional>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <tuple>

namespace PatchScript {
namespace {
using namespace PatchFramework;
constexpr int Constant = -2, Game = -1;
struct Ref {
    int base = Constant;
    int64_t offset = 0;
};
struct Value {
    int64_t n = 0;
    std::map<int, int64_t> bases;
    std::map<std::string, int64_t> regs;
    void Add(const Value &b, int64_t factor = 1) {
        long double sum = static_cast<long double>(n) + static_cast<long double>(b.n) * factor;
        if (sum < -4294967295.0L || sum > 4294967295.0L)
            throw std::runtime_error("32-bit expression overflow");
        n = int64_t(sum);
        for (auto &[k, v] : b.bases) {
            auto next = static_cast<long double>(bases[k]) + static_cast<long double>(v) * factor;
            if (next < -4294967295.0L || next > 4294967295.0L)
                throw std::runtime_error("Address coefficient overflow");
            bases[k] = int64_t(next);
            if (!bases[k])
                bases.erase(k);
        }
        for (auto &[k, v] : b.regs) {
            auto next = static_cast<long double>(regs[k]) + static_cast<long double>(v) * factor;
            if (next < -4294967295.0L || next > 4294967295.0L)
                throw std::runtime_error("Register coefficient overflow");
            regs[k] = int64_t(next);
            if (!regs[k])
                regs.erase(k);
        }
    }
    Ref Address() const {
        if (!regs.empty() || bases.size() > 1 || (!bases.empty() && bases.begin()->second != 1))
            throw std::runtime_error("Expression must contain at most one relocatable address");
        return {bases.empty() ? Constant : bases.begin()->first, n};
    }
};
Value From(Ref r) {
    Value v;
    v.n = r.offset;
    if (r.base != Constant)
        v.bases[r.base] = 1;
    return v;
}
bool Reg(const std::string &s) {
    static const std::set<std::string> names = {
        "eax", "ebx", "ecx",  "edx",  "esi",  "edi",  "esp",  "ebp",  "ax",   "bx",  "cx",
        "dx",  "si",  "di",   "sp",   "bp",   "al",   "ah",   "bl",   "bh",   "cl",  "ch",
        "dl",  "dh",  "cs",   "ds",   "es",   "fs",   "gs",   "ss",   "st0",  "st1", "st2",
        "st3", "st4", "st5",  "st6",  "st7",  "mm0",  "mm1",  "mm2",  "mm3",  "mm4", "mm5",
        "mm6", "mm7", "xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6", "xmm7"};
    return names.count(Lower(s));
}
std::vector<std::string> Split(const std::string &s, char separator = ',') {
    std::vector<std::string> out;
    size_t begin = 0;
    int depth = 0;
    char quote = 0;
    for (size_t i = 0; i <= s.size(); ++i) {
        char c = i < s.size() ? s[i] : separator;
        if (quote) {
            if (c == '\\' && i + 1 < s.size()) {
                ++i;
                continue;
            }
            if (c == quote)
                quote = 0;
            continue;
        }
        if (c == '\'' || c == '"') {
            quote = c;
            continue;
        }
        if (c == '(' || c == '[')
            ++depth;
        if (c == ')' || c == ']')
            --depth;
        if (c == separator && !depth) {
            out.push_back(Trim(s.substr(begin, i - begin)));
            begin = i + 1;
        }
    }
    if (quote || depth)
        throw std::runtime_error("Unclosed string or expression");
    return out;
}
std::string Unquote(std::string s) {
    s = Trim(s);
    if (s.size() >= 2 && (s.front() == '"' || s.front() == '\'') && s.back() == s.front())
        return s.substr(1, s.size() - 2);
    return s;
}
std::string Clean(const std::string &s) {
    std::string out;
    char quote = 0;
    int comment = 0;
    for (size_t i = 0; i < s.size(); ++i) {
        char c = s[i], next = i + 1 < s.size() ? s[i + 1] : 0;
        if (!c)
            throw std::runtime_error("NUL in script");
        if (comment) {
            if (c == '\n') {
                out += c;
                if (comment == 1)
                    comment = 0;
            } else if (comment == 2 && c == '*' && next == '/') {
                comment = 0;
                ++i;
                out += "  ";
            } else if (comment == 3 && c == '}') {
                comment = 0;
                out += ' ';
            } else
                out += ' ';
        } else if (quote) {
            out += c;
            if (c == '\\' && next) {
                out += next;
                ++i;
            } else if (c == quote)
                quote = 0;
        } else if (c == '"' || c == '\'') {
            quote = c;
            out += c;
        } else if (c == '/' && next == '/') {
            comment = 1;
            ++i;
            out += "  ";
        } else if (c == '/' && next == '*') {
            comment = 2;
            ++i;
            out += "  ";
        } else if (c == '{') {
            if (next == '$')
                throw std::runtime_error("Lua/assembler mode directives are unsupported");
            comment = 3;
            out += ' ';
        } else if (c == ';') {
            comment = 1;
            out += ' ';
        } else
            out += c;
    }
    if (quote || comment > 1)
        throw std::runtime_error("Unclosed comment or string");
    return out;
}
struct Row {
    size_t script, line;
    std::string text;
    bool disabled = false;
    int block = -1;
};
struct Block {
    size_t script;
    std::string name;
    uint32_t group, size = 0, rva = 0;
    Kind kind = Kind::Code;
    bool allocation = true, instructions = false;
    std::vector<uint8_t> bytes;
};
struct Assertion {
    size_t script;
    Ref ref;
    std::vector<uint8_t> bytes;
};
std::vector<uint8_t> Bytes(const std::string &s) {
    std::string h;
    for (char c : s)
        if (!isspace(uint8_t(c)))
            h += c;
    if (h.empty() || h.size() % 2)
        throw std::runtime_error("Expected exact hex bytes");
    std::vector<uint8_t> out;
    for (size_t i = 0; i < h.size(); i += 2) {
        auto b = h.substr(i, 2);
        if (b.find_first_not_of("0123456789abcdefABCDEF") != b.npos)
            throw std::runtime_error("Expected exact hex bytes (no wildcards)");
        out.push_back(uint8_t(std::stoul(b, nullptr, 16)));
    }
    return out;
}
std::string ByteText(const std::vector<uint8_t> &bytes) {
    const char *h = "0123456789ABCDEF";
    std::string s;
    for (auto b : bytes) {
        if (!s.empty())
            s += ' ';
        s += h[b >> 4];
        s += h[b & 15];
    }
    return s;
}

class Compiler {
    Package &package;
    const Image *image;
    bool importing;
    std::vector<Row> rows;
    std::vector<Block> blocks;
    std::map<std::string, Ref> symbols;
    std::map<std::string, std::string> defines;
    std::map<std::string, size_t> exports;
    std::set<std::string> allocations, declared, definedLabels;
    std::vector<Assertion> assertions;
    std::vector<Fixup> fixups;
    std::vector<int> writtenAllocations, executedAllocations;
    std::map<uint32_t, size_t> featureIndices;
    size_t owner = 0, line = 0;
    bool first = true, final = false;
    uint32_t Group(size_t script) const {
        for (auto &f : package.features)
            if (f.key == package.scripts[script].feature)
                return f.bit;
        throw std::runtime_error("Unknown script feature");
    }
    std::string Key(size_t script, const std::string &s) const {
        return package.scripts[script].id + ":" + Lower(s);
    }
    [[noreturn]] void Fail(const std::string &s) const {
        throw std::runtime_error(package.scripts[owner].file + ":" + std::to_string(line) + " (" +
                                 package.scripts[owner].name + "): " + s);
    }
    uint32_t Virtual(Ref r) const {
        uint32_t base = 0;
        if (r.base == Game)
            base = package.imageBase;
        else if (r.base >= 0)
            base = blocks.at(r.base).allocation ? 0x10000000u + uint32_t(r.base) * 0x10000u
                                                : package.imageBase + blocks.at(r.base).rva;
        return base + uint32_t(r.offset);
    }
    Ref Canonical(Ref r) const {
        if (r.base >= 0 && !blocks.at(r.base).allocation) {
            r.offset += blocks.at(r.base).rva;
            r.base = Game;
        }
        return r;
    }
    Value Lookup(std::string name, std::set<std::string> &stack) {
        name = Lower(Unquote(name));
        if (name == "tos.exe" || name == Lower(package.module) || (image && name == Lower(image->module)) ||
            name == "gamebase")
            return From({Game, 0});
        if (Reg(name)) {
            Value v;
            v.regs[name] = 1;
            return v;
        }
        auto key = Key(owner, name);
        auto d = defines.find(key);
        if (d != defines.end()) {
            if (!stack.insert(key).second || stack.size() > 128)
                Fail("Recursive define " + name);
            auto v = Expression(d->second, stack);
            stack.erase(key);
            return v;
        }
        auto it = symbols.find(key);
        if (it != symbols.end())
            return From(Canonical(it->second));
        auto exp = exports.find(name);
        if (exp != exports.end() && exp->second != owner) {
            auto previous = owner;
            auto consumer = Group(owner), provider = Group(exp->second);
            owner = exp->second;
            auto v = Lookup(name, stack);
            owner = previous;
            if (importing && consumer != provider)
                package.features.at(featureIndices.at(consumer)).dependencies |= provider;
            return v;
        }
        // CE literals default to hex, but symbols take precedence.
        int radix = 16;
        std::string number = name;
        if (number.rfind("#", 0) == 0) {
            radix = 10;
            number.erase(0, 1);
        } else if (number.rfind("$", 0) == 0)
            number.erase(0, 1);
        else if (number.rfind("0x", 0) == 0)
            number.erase(0, 2);
        if (!number.empty() &&
            number.find_first_not_of(radix == 16 ? "0123456789abcdef" : "0123456789") == number.npos) {
            size_t used = 0;
            auto n = std::stoull(number, &used, radix);
            if (n > UINT32_MAX)
                Fail("32-bit literal overflow");
            Value v;
            v.n = int64_t(n);
            return v;
        }
        if (first && declared.count(key))
            return From({Constant, 0x12345678});
        Fail("Unresolved symbol " + name + "; select its defining CT entry too");
    }
    Value Expression(const std::string &input, std::set<std::string> &stack) {
        std::string s = Trim(input);
        size_t at = 0;
        unsigned nesting = 0;
        std::function<Value()> sum, product, atom;
        auto space = [&] {
            while (at < s.size() && isspace(uint8_t(s[at])))
                ++at;
        };
        atom = [&]() -> Value {
            struct Depth {
                unsigned &n;
                ~Depth() { --n; }
            } depth{nesting};
            if (++nesting > 128)
                Fail("Expression nesting limit exceeded");
            space();
            if (at >= s.size())
                Fail("Incomplete expression: " + s);
            if (s[at] == '+' || s[at] == '-') {
                char op = s[at++];
                auto v = atom();
                if (op == '-') {
                    Value n;
                    n.Add(v, -1);
                    return n;
                }
                return v;
            }
            if (Lower(s.substr(at, 5)) == "(int)") {
                at += 5;
                space();
                size_t start = at;
                while (at < s.size() &&
                       (isdigit(uint8_t(s[at])) || ((s[at] == '+' || s[at] == '-') && at == start)))
                    ++at;
                Value v;
                v.n = std::stoll(s.substr(start, at - start));
                if (v.n < INT32_MIN || v.n > UINT32_MAX)
                    Fail("32-bit literal overflow");
                return v;
            }
            if (s[at] == '(') {
                ++at;
                auto v = sum();
                space();
                if (at >= s.size() || s[at++] != ')')
                    Fail("Missing closing parenthesis");
                return v;
            }
            size_t begin = at;
            if (s[at] == '\'' || s[at] == '"') {
                char quote = s[at++];
                while (at < s.size() && s[at] != quote)
                    ++at;
                if (at == s.size())
                    Fail("Unclosed name");
                ++at;
            } else
                while (at < s.size() && (isalnum(uint8_t(s[at])) || s[at] == '_' || s[at] == '.' ||
                                         s[at] == '$' || s[at] == '#'))
                    ++at;
            if (at == begin)
                Fail("Invalid expression: " + s);
            return Lookup(s.substr(begin, at - begin), stack);
        };
        product = [&]() {
            auto a = atom();
            space();
            while (at < s.size() && (s[at] == '*' || s[at] == '/')) {
                char op = s[at++];
                auto b = atom();
                if (op == '/') {
                    if (!a.bases.empty() || !a.regs.empty() || !b.bases.empty() || !b.regs.empty() || !b.n)
                        Fail("Division requires constants and a nonzero divisor");
                    a.n /= b.n;
                } else if (!a.bases.empty() || !a.regs.empty()) {
                    if (!b.bases.empty() || !b.regs.empty())
                        Fail("Nonlinear address expression");
                    Value v;
                    v.Add(a, b.n);
                    a = v;
                } else {
                    Value v;
                    v.Add(b, a.n);
                    a = v;
                }
                space();
            }
            return a;
        };
        sum = [&]() {
            auto a = product();
            space();
            while (at < s.size() && (s[at] == '+' || s[at] == '-')) {
                char op = s[at++];
                a.Add(product(), op == '+' ? 1 : -1);
                space();
            }
            return a;
        };
        auto value = sum();
        space();
        if (at != s.size())
            Fail("Invalid expression: " + s);
        return value;
    }
    Value Expression(const std::string &s) {
        std::set<std::string> stack;
        return Expression(s, stack);
    }
    Ref Address(const std::string &s) {
        auto r = Expression(s).Address();
        if (r.base == Constant && r.offset >= package.imageBase &&
            uint64_t(r.offset) < uint64_t(package.imageBase) + package.imageSize) {
            r.base = Game;
            r.offset -= package.imageBase;
        }
        return Canonical(r);
    }
    uint32_t Integer(const std::string &s) {
        auto r = Expression(s).Address();
        if (r.base != Constant || r.offset < 0 || uint64_t(r.offset) > UINT32_MAX)
            Fail("Expected unsigned integer: " + s);
        return uint32_t(r.offset);
    }
    void Declare(const std::string &name) {
        if (!std::regex_match(name, std::regex("[A-Za-z_][A-Za-z_0-9.]*")))
            Fail("Invalid symbol: " + name);
        declared.insert(Key(owner, name));
    }
    void Prepare() {
        for (size_t i = 0; i < package.features.size(); ++i)
            featureIndices[package.features[i].bit] = i;
        for (owner = 0; owner < package.scripts.size(); ++owner) {
            auto &script = package.scripts[owner];
            std::istringstream in(Clean(script.text));
            std::string raw;
            bool disabled = false;
            line = 0;
            while (std::getline(in, raw)) {
                ++line;
                auto text = Trim(raw);
                if (text.empty())
                    continue;
                if (Lower(text) == "[enable]") {
                    if (disabled)
                        Fail("ENABLE after DISABLE");
                    continue;
                }
                if (Lower(text) == "[disable]") {
                    disabled = true;
                    continue;
                }
                std::smatch m;
                if (!disabled &&
                    std::regex_match(text, m, std::regex("([A-Za-z_][A-Za-z_0-9]*)\\s*\\((.*)\\)"))) {
                    auto cmd = Lower(m[1]);
                    auto args = Split(m[2]);
                    if (cmd == "define" && args.size() == 2) {
                        Declare(args[0]);
                        auto key = Key(owner, args[0]);
                        if (defines.count(key) || symbols.count(key))
                            Fail("Duplicate define " + args[0]);
                        defines[key] = args[1];
                        continue;
                    }
                    if (cmd == "alloc" && (args.size() == 2 || args.size() == 3)) {
                        Declare(args[0]);
                        auto key = Key(owner, args[0]);
                        if (symbols.count(key) || defines.count(key))
                            Fail("Duplicate allocation");
                        auto size = Integer(args[1]);
                        if (!size || size > 64 * 1024 * 1024 || blocks.size() >= 4096)
                            Fail("Allocation limit exceeded");
                        symbols[key] = {int(blocks.size()), 0};
                        allocations.insert(key);
                        blocks.push_back({owner,
                                          args[0],
                                          Group(owner),
                                          size,
                                          0,
                                          script.writable.count(Lower(args[0])) ? Kind::Data : Kind::Code,
                                          true,
                                          false,
                                          {}});
                        continue;
                    }
                    if (cmd == "label" || cmd == "registersymbol") {
                        for (auto &arg : args) {
                            Declare(arg);
                            if (cmd == "registersymbol" && !exports.emplace(Lower(arg), owner).second)
                                Fail("Duplicate registered symbol " + arg);
                        }
                        continue;
                    }
                    if (cmd == "aobscanmodule" && args.size() == 3) {
                        if (!image)
                            Fail("AOB scan needs a reference executable; export this script through the "
                                 "converter");
                        auto rva = image->Scan(Unquote(args[1]), args[2]);
                        Declare(args[0]);
                        auto key = Key(owner, args[0]);
                        if (defines.count(key) || symbols.count(key))
                            Fail("Duplicate scan symbol");
                        defines[key] = "GameBase+" + Hex(rva);
                        std::istringstream pattern(args[2]);
                        std::string b;
                        size_t count = 0;
                        while (pattern >> b)
                            ++count;
                        rows.push_back({owner, line,
                                        "assert(GameBase+" + Hex(rva) + "," +
                                            ByteText(image->ReadBytes(rva, count)) + ")"});
                        // Keep the export independent of the game executable at load time.
                        if (importing) {
                            std::istringstream original(script.text);
                            std::string rebuilt, l;
                            size_t n = 0;
                            while (std::getline(original, l)) {
                                ++n;
                                if (n == line)
                                    l = "define(" + args[0] + ",TOS.exe+" + Hex(rva) +
                                        ") // resolved from aobscanmodule";
                                rebuilt += l + '\n';
                            }
                            script.text = rebuilt;
                        }
                        continue;
                    }
                    if (cmd != "assert" && cmd != "db" && cmd != "dw" && cmd != "dd" && cmd != "dq" &&
                        text[m[1].length()] == '(')
                        Fail("Unsupported Auto Assembler directive: " + cmd);
                }
                if (!disabled && text.back() == ':') {
                    auto name = Trim(text.substr(0, text.size() - 1));
                    if (std::regex_match(name, std::regex("[A-Za-z_][A-Za-z_0-9.]*")))
                        Declare(name);
                }
                rows.push_back({owner, line, text, disabled});
                if (rows.size() > 200000)
                    Fail("Script instruction limit exceeded");
            }
        }
        for (owner = 0; owner < package.scripts.size(); ++owner)
            for (auto &name : package.scripts[owner].writable)
                if (!allocations.count(Key(owner, name)))
                    Fail("Writable entry is not an allocation: " + name);
    }
    void AddFixup(int block, uint32_t offset, Ref r, uint32_t type, uint32_t width) {
        r = Canonical(r);
        if (r.base == Constant)
            return;
        if (type != 1)
            r.offset -= width;
        fixups.push_back({uint32_t(block), offset, r.base, uint32_t(r.offset), type});
    }
    struct Encoded {
        std::vector<uint8_t> bytes;
        std::vector<std::tuple<bool, Ref, size_t>> refs;
        ZydisDecodedInstruction decoded{};
        bool instruction = false;
    };
    Encoded Encode(const std::string &text, Ref pc) {
        Encoded out;
        auto space = text.find_first_of(" \t");
        auto cmd = Lower(text.substr(0, space));
        auto tail = space == text.npos ? "" : Trim(text.substr(space + 1));
        std::string prefix;
        if (cmd == "rep" || cmd == "repe" || cmd == "repne" || cmd == "repz" || cmd == "repnz" ||
            cmd == "lock") {
            prefix = cmd + " ";
            space = tail.find_first_of(" \t");
            cmd = Lower(tail.substr(0, space));
            tail = space == tail.npos ? "" : Trim(tail.substr(space + 1));
        }
        if (cmd == "db" || cmd == "dw" || cmd == "dd" || cmd == "dq") {
            size_t width = cmd == "db" ? 1 : cmd == "dw" ? 2 : cmd == "dd" ? 4 : 8;
            auto args = Split(tail);
            if (args.size() == 1 && tail.find(',') == tail.npos && tail.find_first_of("\"'()") == tail.npos) {
                std::istringstream in(tail);
                std::string v;
                args.clear();
                while (in >> v)
                    args.push_back(v);
            }
            for (auto &arg : args) {
                if (arg.size() >= 2 && (arg.front() == '"' || arg.front() == '\'')) {
                    if (width != 1)
                        Fail("Strings require db");
                    auto s = Unquote(arg);
                    out.bytes.insert(out.bytes.end(), s.begin(), s.end());
                    continue;
                }
                uint64_t bits = 0;
                auto lower = Lower(arg);
                Ref ref;
                if (lower.rfind("(float)", 0) == 0 || lower.rfind("(double)", 0) == 0) {
                    bool single = lower[1] == 'f';
                    size_t used = 0;
                    auto n = std::stod(arg.substr(single ? 7 : 8), &used);
                    if (used != arg.size() - (single ? 7 : 8) || !std::isfinite(n) ||
                        width != (single ? 4 : 8))
                        Fail("Invalid typed float/double data");
                    if (single) {
                        float f = float(n);
                        if (!std::isfinite(f))
                            Fail("Float overflow");
                        std::memcpy(&bits, &f, 4);
                    } else
                        std::memcpy(&bits, &n, 8);
                } else if (width == 8 &&
                           std::regex_match(lower, std::regex("(?:0x|\\$)?[0-9a-f]+|#[0-9]+"))) {
                    auto number = lower;
                    int radix = 16;
                    if (number[0] == '#') {
                        radix = 10;
                        number.erase(0, 1);
                    } else if (number[0] == '$')
                        number.erase(0, 1);
                    bits = std::stoull(number, nullptr, radix);
                } else {
                    ref = Expression(arg).Address();
                    bits = ref.base == Constant ? uint64_t(ref.offset) : Virtual(ref);
                    if (ref.base != Constant && width != 4)
                        Fail("Address data requires dd");
                }
                if (ref.base == Constant && width < 4 && bits >= (uint64_t(1) << (width * 8)) &&
                    !(ref.offset < 0 && ref.offset >= -(int64_t(1) << (width * 8 - 1))))
                    Fail("Data value exceeds directive width");
                if (final && ref.base != Constant)
                    AddFixup(pc.base, uint32_t(pc.offset + out.bytes.size()), ref, 1, 4);
                for (size_t i = 0; i < width; ++i)
                    out.bytes.push_back(uint8_t(bits >> (i * 8)));
            }
            return out;
        }
        if (cmd == "align") {
            auto n = Integer(tail);
            if (!n || n > 4096 || (n & (n - 1)))
                Fail("Invalid alignment");
            out.bytes.assign((n - uint32_t(pc.offset) % n) % n, 0);
            return out;
        }
        if (cmd == "nop" && !tail.empty()) {
            auto n = Integer(tail);
            if (n > 1024 * 1024)
                Fail("NOP count exceeds limit");
            out.bytes.assign(n, 0x90);
            out.instruction = true;
            return out;
        }
        out.instruction = true;
        // CE x87 names and aliases accepted by the native parser.
        std::vector<std::string> operands = tail.empty() ? std::vector<std::string>{} : Split(tail);
        if (cmd == "imul" && operands.size() == 2 && Reg(Trim(operands[0])) &&
            operands[1].find('[') == std::string::npos && !Reg(Trim(operands[1])))
            operands.insert(operands.begin() + 1, operands[0]);
        // CE's x86 integer memory/immediate shorthand defaults to DWORD.
        // AsmTK requires the size explicitly. Limit the default to these forms:
        // register operands infer their own width, and other instruction families
        // (such as movzx and x87) have different sizing rules.
        static const std::set<std::string> memoryImmediate = {
            "adc", "add", "and", "cmp", "mov", "or", "sbb", "sub", "test", "xor"};
        if (memoryImmediate.count(cmd) && operands.size() == 2) {
            auto memory = Trim(operands[0]);
            auto source = Lower(Trim(operands[1]));
            if (!memory.empty() && memory.front() == '[' &&
                source.find('[') == std::string::npos && !Reg(source))
                operands[0] = "dword ptr " + memory;
        }
        std::string normalized = prefix + cmd;
        bool branch =
            (cmd == "call" || cmd == "jmp" || (cmd.size() > 1 && cmd[0] == 'j') || cmd.rfind("loop", 0) == 0);
        bool forceLong = false, forceShort = false;
        if (!operands.empty()) {
            auto low = Lower(operands[0]);
            if (low.rfind("short ", 0) == 0) {
                forceShort = true;
                operands[0] = Trim(operands[0].substr(6));
            } else if (low.rfind("near ", 0) == 0) {
                forceLong = true;
                operands[0] = Trim(operands[0].substr(5));
            }
        }
        for (size_t i = 0; i < operands.size(); ++i) {
            std::string op = Trim(operands[i]);
            normalized += i ? ", " : " ";
            auto low = Lower(op);
            if (low == "st")
                low = "st0";
            if (std::regex_match(low, std::regex("st\\([0-7]\\)")))
                low = "st" + low.substr(3, 1);
            if (Reg(low)) {
                normalized += low;
                continue;
            }
            auto open = op.find('['), close = op.find(']');
            if (open != op.npos) {
                if (close != op.size() - 1)
                    Fail("Invalid memory operand");
                auto value = Expression(op.substr(open + 1, close - open - 1));
                auto regs = value.regs;
                value.regs.clear();
                auto ref = value.Address();
                normalized += Lower(op.substr(0, open)) + "[";
                bool any = false;
                // ESP cannot be an index register; emit it as the base first.
                if (regs.count("esp") && regs.at("esp") == 1) {
                    normalized += "esp";
                    any = true;
                    regs.erase("esp");
                }
                for (auto &[reg, factor] : regs) {
                    if (factor != 1 && factor != 2 && factor != 4 && factor != 8)
                        Fail("Invalid register scale");
                    if (any)
                        normalized += '+';
                    normalized += reg;
                    if (factor != 1)
                        normalized += "*" + std::to_string(factor);
                    any = true;
                }
                if (any)
                    normalized += '+';
                normalized += Hex(Virtual(ref)) + "]";
                if (ref.base != Constant)
                    out.refs.push_back({true, ref, i});
            } else {
                auto ref = Expression(op).Address();
                if (branch)
                    ref = Address(op);
                if (first && branch && ref.base == Constant && ref.offset == 0x12345678)
                    ref = Canonical(pc);
                normalized += Hex(Virtual(ref));
                if (ref.base != Constant)
                    out.refs.push_back({false, ref, i});
                if (branch && !forceShort && cmd.rfind("loop", 0) != 0 && cmd != "jecxz" && cmd != "jcxz") {
                    auto current = Canonical(pc);
                    if (ref.base != current.base || cmd == "call" || first)
                        forceLong = true;
                }
            }
        }
        if (forceShort)
            normalized = "short " + normalized;
        else if (forceLong)
            normalized = "long " + normalized;
        asmjit::Environment env(asmjit::Arch::kX86);
        asmjit::CodeHolder code;
        auto err = code.init(env, Virtual(pc));
        if (err != asmjit::Error::kOk)
            Fail("Cannot initialize assembler");
        asmjit::x86::Assembler assembler(&code);
        asmtk::AsmParser parser(&assembler);
        err = parser.parse(normalized.c_str());
        if (err != asmjit::Error::kOk)
            Fail("Assembly error: " + std::string(asmjit::DebugUtils::error_as_string(err)) + " in `" + text +
                 "` (" + normalized + ")");
        auto &buffer = code.section_by_id(0)->buffer();
        out.bytes.assign(buffer.data(), buffer.data() + buffer.size());
        ZydisDecoder decoder;
        ZydisDecoderInit(&decoder, ZYDIS_MACHINE_MODE_LEGACY_32, ZYDIS_STACK_WIDTH_32);
        if (!ZYAN_SUCCESS(ZydisDecoderDecodeInstruction(&decoder, nullptr, out.bytes.data(), out.bytes.size(),
                                                        &out.decoded)) ||
            out.decoded.length != out.bytes.size())
            Fail("Cannot decode assembled instruction");
        if (final)
            for (auto &[memory, ref, operandIndex] : out.refs) {
                ZydisDecodedOperand operandsDecoded[ZYDIS_MAX_OPERAND_COUNT]{};
                ZydisDecodedInstruction decoded{};
                if (!ZYAN_SUCCESS(ZydisDecoderDecodeFull(&decoder, out.bytes.data(), out.bytes.size(),
                                                         &decoded, operandsDecoded)))
                    Fail("Cannot inspect instruction operands");
                if (ref.base >= 0 && memory && operandIndex < decoded.operand_count_visible &&
                    (operandsDecoded[operandIndex].actions & ZYDIS_OPERAND_ACTION_MASK_WRITE))
                    writtenAllocations.push_back(ref.base);
                if (ref.base >= 0 && !memory && branch)
                    executedAllocations.push_back(ref.base);
                auto fieldOffset = memory ? out.decoded.raw.disp.offset : out.decoded.raw.imm[0].offset;
                auto bits = memory ? out.decoded.raw.disp.size : out.decoded.raw.imm[0].size;
                bool relative = !memory && out.decoded.raw.imm[0].is_relative;
                auto current = Canonical(pc);
                ref = Canonical(ref);
                if (relative && ref.base == current.base)
                    continue; // Base cancels for same allocation/image.
                if ((bits != 32 && !(relative && bits == 8)) || !bits)
                    Fail("Unsupported address encoding width");
                AddFixup(pc.base, uint32_t(pc.offset + fieldOffset), ref, relative ? (bits == 8 ? 23 : 2) : 1,
                         bits / 8);
            }
        return out;
    }
    void Layout() {
        std::vector<uint32_t> cursor(blocks.size());
        for (auto &b : blocks)
            b.bytes.clear();
        assertions.clear();
        fixups.clear();
        writtenAllocations.clear();
        executedAllocations.clear();
        definedLabels.clear();
        size_t previous = SIZE_MAX;
        int current = -1;
        for (auto &row : rows) {
            owner = row.script;
            line = row.line;
            if (owner != previous) {
                previous = owner;
                current = -1;
            }
            if (row.disabled)
                continue;
            std::string text = row.text;
            std::smatch m;
            if (std::regex_match(text, m, std::regex("assert\\s*\\((.*)\\)", std::regex::icase))) {
                auto args = Split(m[1]);
                if (args.size() != 2)
                    Fail("assert needs address and bytes");
                if (!first)
                    assertions.push_back({owner, Address(args[0]), Bytes(args[1])});
                continue;
            }
            if (text.back() == ':') {
                auto name = Trim(text.substr(0, text.size() - 1));
                auto key = Key(owner, name);
                bool location = allocations.count(key) || defines.count(key) ||
                                name.find_first_of("+-\"'") != name.npos || isdigit(uint8_t(name[0]));
                if (location) {
                    auto ref = Address(name);
                    if (ref.base == Game) {
                        if (ref.offset < 0 || uint64_t(ref.offset) >= package.imageSize)
                            Fail("Patch address outside image");
                        if (row.block < 0) {
                            if (!first)
                                Fail("Unstable patch destination");
                            row.block = int(blocks.size());
                            blocks.push_back({owner,
                                              name,
                                              Group(owner),
                                              0,
                                              uint32_t(ref.offset),
                                              Kind::Patch,
                                              false,
                                              false,
                                              {}});
                            cursor.push_back(0);
                        }
                        current = row.block;
                        cursor[current] = 0;
                    } else if (ref.base >= 0) {
                        current = ref.base;
                        if (ref.offset < 0 || uint64_t(ref.offset) > blocks[current].size)
                            Fail("Allocation offset out of range");
                        cursor[current] = uint32_t(ref.offset);
                    } else
                        Fail("Address label does not name game memory or an allocation");
                } else {
                    if (current < 0)
                        Fail("Label has no assembly destination");
                    if (!definedLabels.insert(key).second)
                        Fail("Duplicate label " + name);
                    symbols[key] = {current, cursor[current]};
                }
                continue;
            }
            if (current < 0)
                Fail("Instruction/data has no assembly destination");
            auto pc = Ref{current, cursor[current]};
            auto encoded = Encode(text, pc);
            auto &b = blocks[current];
            if (encoded.instruction) {
                b.instructions = true;
                if (b.kind == Kind::Data)
                    Fail("Executable instructions in writable allocation");
            }
            if (encoded.bytes.size() > 8 * 1024 * 1024 ||
                cursor[current] > 8 * 1024 * 1024 - encoded.bytes.size())
                Fail("Payload exceeds 8 MiB");
            if (b.allocation && uint64_t(cursor[current]) + encoded.bytes.size() > b.size)
                Fail("Allocation exceeded: " + b.name);
            if (cursor[current] < b.bytes.size())
                Fail("Overlapping writes inside allocation/patch");
            b.bytes.resize(cursor[current], 0);
            b.bytes.insert(b.bytes.end(), encoded.bytes.begin(), encoded.bytes.end());
            cursor[current] += uint32_t(encoded.bytes.size());
        }
    }
    void CheckDisable() {
        int current = -1;
        uint32_t at = 0;
        size_t previous = SIZE_MAX;
        for (auto &row : rows)
            if (row.disabled) {
                owner = row.script;
                line = row.line;
                if (owner != previous) {
                    previous = owner;
                    current = -1;
                }
                auto text = row.text;
                std::smatch m;
                if (std::regex_match(text, m,
                                     std::regex("(dealloc|unregistersymbol)\\s*\\(.*\\)", std::regex::icase)))
                    continue;
                if (text.back() == ':') {
                    auto ref = Address(text.substr(0, text.size() - 1));
                    if (ref.base != Game)
                        Fail("DISABLE restore address must be game memory");
                    at = uint32_t(ref.offset);
                    current = Game;
                    continue;
                }
                if (current != Game)
                    Fail("Unsupported DISABLE directive or missing restore address");
                // Disable checking only emits into a temporary patch context, no fixups.
                bool wasFinal = final;
                final = false;
                auto encoded = Encode(text, {Game, at});
                final = wasFinal;
                if (image && image->ReadBytes(at, encoded.bytes.size()) != encoded.bytes)
                    Fail("DISABLE restore bytes differ from executable");
                bool missingAssertion = false;
                for (size_t i = 0; i < encoded.bytes.size(); ++i) {
                    bool found = false;
                    for (auto &g : assertions)
                        if (g.script == owner && g.ref.base == Game && at + i >= uint64_t(g.ref.offset) &&
                            at + i < uint64_t(g.ref.offset) + g.bytes.size()) {
                            if (g.bytes[at + i - g.ref.offset] != encoded.bytes[i])
                                Fail("DISABLE restore bytes disagree with assert");
                            found = true;
                        }
                    if (!found && !importing)
                        Fail("DISABLE restore bytes are not covered by assert");
                    missingAssertion |= !found;
                }
                if (importing && missingAssertion)
                    assertions.push_back({owner, {Game, at}, encoded.bytes});
                at += uint32_t(encoded.bytes.size());
            }
    }

  public:
    Compiler(Package &p, const Image *i, bool import) : package(p), image(i), importing(import) {}
    Compiled Run() {
        if (package.scripts.empty() || package.scripts.size() > 4096 || package.features.empty() ||
            package.features.size() > 32)
            throw std::runtime_error("Invalid package script/feature count");
        if (image && (image->base != package.imageBase || image->size != package.imageSize))
            throw std::runtime_error("Executable layout differs from package");
        Prepare();
        Layout();
        first = false;
        bool stable = false;
        for (unsigned pass = 0; pass < 32; ++pass) {
            auto old = symbols;
            std::vector<size_t> sizes;
            for (auto &b : blocks)
                sizes.push_back(b.bytes.size());
            Layout();
            stable = old.size() == symbols.size();
            for (auto &[key, ref] : symbols) {
                auto it = old.find(key);
                stable &= it != old.end() && it->second.base == ref.base && it->second.offset == ref.offset;
            }
            for (size_t i = 0; i < blocks.size(); ++i)
                stable &= sizes[i] == blocks[i].bytes.size();
            if (stable)
                break;
        }
        if (!stable)
            Fail("Assembly layout did not converge");
        final = true;
        Layout();
        // Infer data-only allocations for CT import. Runtime uses explicit metadata.
        if (importing)
            for (auto &b : blocks)
                if (b.allocation && !b.instructions) {
                    b.kind = Kind::Data;
                    package.scripts[b.script].writable.insert(Lower(b.name));
                }
        for (auto index : writtenAllocations)
            if (blocks[index].allocation && blocks[index].kind != Kind::Data)
                Fail("Mixed writable state and executable code in allocation " + blocks[index].name +
                     "; separate code and data");
        for (auto index : executedAllocations)
            if (blocks[index].allocation && blocks[index].kind == Kind::Data)
                Fail("Branch into writable data allocation " + blocks[index].name);
        Compiled result;
        auto &d = result.definition;
        d.id = package.id;
        d.version = package.version;
        d.configSection = package.section;
        d.imageBase = package.imageBase;
        d.imageSize = package.imageSize;
        d.features = package.features;
        auto append = [&](const std::vector<uint8_t> &bytes) {
            if (bytes.size() > 8 * 1024 * 1024 - d.bytes.size())
                Fail("Payload exceeds 8 MiB");
            uint32_t offset = uint32_t(d.bytes.size());
            d.bytes.insert(d.bytes.end(), bytes.begin(), bytes.end());
            return offset;
        };
        std::vector<int> indices(blocks.size(), -1);
        std::vector<std::string> added(package.scripts.size());
        for (size_t i = 0; i < blocks.size(); ++i) {
            auto &b = blocks[i];
            owner = b.script;
            if (!b.allocation && b.bytes.empty())
                continue;
            std::vector<uint8_t> expected;
            if (!b.allocation) {
                expected.resize(b.bytes.size());
                std::vector<bool> covered(b.bytes.size());
                for (auto &g : assertions)
                    if (g.script == owner && g.ref.base == Game)
                        for (size_t j = 0; j < expected.size(); ++j)
                            if (b.rva + j >= uint64_t(g.ref.offset) &&
                                b.rva + j < uint64_t(g.ref.offset) + g.bytes.size()) {
                                auto v = g.bytes[b.rva + j - g.ref.offset];
                                if (covered[j] && expected[j] != v)
                                    Fail("Conflicting assertions");
                                expected[j] = v;
                                covered[j] = true;
                            }
                if (std::find(covered.begin(), covered.end(), false) != covered.end()) {
                    if (!importing || !image)
                        Fail("Patch at TOS.exe+" + Hex(b.rva) +
                             " lacks assert covering every overwritten byte");
                    auto original = image->ReadBytes(b.rva, b.bytes.size());
                    for (size_t j = 0; j < expected.size(); ++j)
                        if (covered[j] && expected[j] != original[j])
                            Fail("assert differs from executable");
                    expected = original;
                    assertions.push_back({owner, {Game, b.rva}, expected});
                }
                if (image && image->ReadBytes(b.rva, expected.size()) != expected)
                    Fail("assert differs from executable");
                if (b.instructions) {
                    ZydisDecoder decoder;
                    ZydisDecoderInit(&decoder, ZYDIS_MACHINE_MODE_LEGACY_32, ZYDIS_STACK_WIDTH_32);
                    size_t pos = 0;
                    while (pos < expected.size()) {
                        ZydisDecodedInstruction instruction{};
                        if (!ZYAN_SUCCESS(ZydisDecoderDecodeInstruction(&decoder, nullptr,
                                                                        expected.data() + pos,
                                                                        expected.size() - pos, &instruction)))
                            Fail("Hook splits an original instruction at +" + Hex(b.rva));
                        pos += instruction.length;
                    }
                }
            }
            indices[i] = int(d.segments.size());
            uint32_t count = uint32_t(b.bytes.size());
            d.segments.push_back({b.group, b.kind, b.allocation ? b.size : count, append(b.bytes), count,
                                  b.rva, append(expected), package.scripts[owner].name + ": " + b.name});
        }
        CheckDisable();
        for (auto &g : assertions) {
            owner = g.script;
            if (g.ref.base != Game || g.ref.offset < 0 ||
                uint64_t(g.ref.offset) + g.bytes.size() > package.imageSize)
                Fail("assert address outside game image");
            if (image && image->ReadBytes(uint32_t(g.ref.offset), g.bytes.size()) != g.bytes)
                Fail("assert differs from executable at +" + Hex(g.ref.offset));
            d.guards.push_back(
                {Group(owner), uint32_t(g.ref.offset), append(g.bytes), uint32_t(g.bytes.size())});
            if (importing)
                added[owner] += "assert(TOS.exe+" + Hex(g.ref.offset) + "," + ByteText(g.bytes) + ")\n";
        }
        for (auto f : fixups) {
            if (indices.at(f.owner) < 0)
                Fail("Fixup in empty segment");
            f.owner = uint32_t(indices[f.owner]);
            if (f.target >= 0) {
                if (indices.at(f.target) < 0)
                    Fail("Fixup to empty allocation");
                f.target = indices[f.target];
            }
            d.fixups.push_back(f);
        }
        for (auto &[key, ref] : symbols) {
            auto r = Canonical(ref);
            if (r.base >= 0)
                r.base = indices.at(r.base);
            result.symbols[key] = {r.base, uint32_t(r.offset)};
        }
        for (auto &p : package.parameters) {
            auto it = result.symbols.find(p.script + ":" + Lower(p.symbol));
            if (it == result.symbols.end() || it->second.first < 0)
                Fail("Unknown parameter symbol " + p.symbol);
            uint32_t group = 0;
            for (auto &f : d.features)
                if (f.key == p.feature)
                    group = f.bit;
            d.parameters.push_back(
                {group, uint32_t(it->second.first), it->second.second, p.value, p.minimum, p.maximum, p.key});
        }
        if (std::none_of(d.segments.begin(), d.segments.end(), [](auto &s) { return s.kind == Kind::Patch; }))
            Fail("Selected scripts do not install any patches");
        std::string error;
        if (!Validate(d, error))
            Fail(error);
        if (importing)
            for (size_t i = 0; i < package.scripts.size(); ++i)
                package.scripts[i].text = "// Original bytes verified during CT export.\n" + added[i] + "\n" +
                                          package.scripts[i].text;
        return result;
    }
};
} // namespace
Compiled Compile(Package &p, const Image *image, bool importing) {
    return Compiler(p, image, importing).Run();
}
} // namespace PatchScript
