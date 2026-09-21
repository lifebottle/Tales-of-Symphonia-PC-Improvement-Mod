#include "ct_import.h"
#include <iostream>
#ifdef _WIN32
#include <windows.h>
#endif
using namespace PatchScript;
int Main(const std::vector<std::string> &args) {
    try {
        if (args.size() < 3)
            throw std::runtime_error("Usage: tos-patch check patch.toml [--exe TOS.exe] | list table.CT | "
                                     "convert table.CT --exe TOS.exe --entry ID[=Key] --output folder [--id "
                                     "ID] [--section Section] [--ignore-table-lua]");
        auto command = args[1];
        fs::path input = fs::u8path(args[2]), exe, output;
        std::vector<Selection> selected;
        std::string id = "imported.ct", section = "ImportedPatches";
        bool ignore = false;
        for (size_t i = 3; i < args.size(); ++i) {
            auto arg = args[i];
            if (arg == "--ignore-table-lua") {
                ignore = true;
                continue;
            }
            if (arg == "--no-children") {
                throw std::runtime_error("--no-children is no longer supported: automatic child "
                                         "activation follows the saved Cheat Engine table options.");
            }
            if (++i >= args.size())
                throw std::runtime_error("Missing value for " + arg);
            auto value = args[i];
            if (arg == "--exe")
                exe = fs::u8path(value);
            else if (arg == "--output")
                output = fs::u8path(value);
            else if (arg == "--id")
                id = value;
            else if (arg == "--section")
                section = value;
            else if (arg == "--entry") {
                auto at = value.find('=');
                selected.push_back({value.substr(0, at), at == value.npos ? "" : value.substr(at + 1)});
            } else
                throw std::runtime_error("Unknown option " + arg);
        }
        if (command == "check") {
            auto p = ReadPackage(input);
            Image image;
            Image *ptr = nullptr;
            if (!exe.empty()) {
                image = Image::Read(exe);
                ptr = &image;
            }
            auto c = Compile(p, ptr);
            std::cout << p.id << ": " << c.definition.segments.size() << " segments, "
                      << c.definition.fixups.size() << " relocations, " << c.definition.guards.size()
                      << " assertions\n";
        } else if (command == "list") {
            auto t = Table::Read(input);
            for (auto &e : t.entries)
                std::cout << e.id << "\t" << (e.script.empty() ? (e.group ? "group" : "value") : "script")
                          << "\t" << e.name << (e.activateChildren ? " [auto-enables children]" : "")
                          << "\n";
        } else if (command == "convert") {
            if (exe.empty() || output.empty())
                throw std::runtime_error("convert requires --exe and --output");
            if (id == "imported.ct")
                id = "imported." + output.filename().u8string();
            auto p = Import(Table::Read(input), Image::Read(exe), selected, id, section, ignore);
            Export(p, output);
            std::cout << "Exported " << p.scripts.size() << " scripts to " << output.u8string() << "\n";
        } else
            throw std::runtime_error("Unknown command " + command);
        return 0;
    } catch (const std::exception &e) {
        std::cerr << e.what() << '\n';
        return 1;
    }
}
#ifdef _WIN32
int wmain(int argc, wchar_t **argv) {
    std::vector<std::string> args;
    for (int i = 0; i < argc; ++i) {
        int n = WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, nullptr, 0, nullptr, nullptr);
        std::string s(n, '\0');
        WideCharToMultiByte(CP_UTF8, 0, argv[i], -1, s.data(), n, nullptr, nullptr);
        s.pop_back();
        args.push_back(s);
    }
    return Main(args);
}
#else
int main(int argc, char **argv) { return Main({argv, argv + argc}); }
#endif
