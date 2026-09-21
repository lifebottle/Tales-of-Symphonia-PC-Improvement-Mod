#define UNICODE
#define _UNICODE
#include "ct_import.h"
#include <windows.h>
#include <commctrl.h>
#include <commdlg.h>
#include <shlobj.h>
#include <thread>
#include <memory>
#include <sstream>
using namespace PatchScript;
namespace {
enum {
    CtPath = 101,
    ExePath,
    OutPath,
    Id,
    Section,
    Key,
    Tree,
    Preview,
    Status,
    IgnoreLua,
    ActivationNote,
    OpenCt,
    OpenExe,
    OpenOut,
    Validate,
    ExportButton
};
constexpr UINT Completed = WM_APP + 1;
HWND window;
HFONT font, mono;
std::map<int, HWND> controls;
std::vector<HWND> labels;
std::map<std::string, HTREEITEM> items;
std::map<std::string, std::string> keys;
Table table;
std::string current;
std::thread worker;
bool busy = false, settingKey = false;
std::wstring Wide(const std::string &s) {
    int n = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, s.data(), int(s.size()), nullptr, 0);
    std::wstring out(n, 0);
    MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, s.data(), int(s.size()), out.data(), n);
    return out;
}
std::string Utf8(const std::wstring &s) {
    int n = WideCharToMultiByte(CP_UTF8, 0, s.data(), int(s.size()), nullptr, 0, nullptr, nullptr);
    std::string out(n, 0);
    WideCharToMultiByte(CP_UTF8, 0, s.data(), int(s.size()), out.data(), n, nullptr, nullptr);
    return out;
}
std::wstring Text(int id) {
    int n = GetWindowTextLengthW(controls.at(id));
    std::wstring out(size_t(n) + 1, 0);
    GetWindowTextW(controls.at(id), out.data(), n + 1);
    out.resize(n);
    return out;
}
void Set(int id, const std::string &text) {
    auto s = Wide(text);
    SetWindowTextW(controls.at(id), s.c_str());
}
void Error(const std::exception &e) { Set(Status, e.what()); }
void Place(HWND h, int x, int y, int w, int height) { MoveWindow(h, x, y, w, height, TRUE); }
HWND Make(const wchar_t *cls, const wchar_t *text, DWORD style, int id) {
    auto h = CreateWindowExW(cls == std::wstring(L"EDIT") ? WS_EX_CLIENTEDGE : 0, cls, text,
                             WS_CHILD | WS_VISIBLE | style, 0, 0, 0, 0, window,
                             reinterpret_cast<HMENU>(INT_PTR(id)), nullptr, nullptr);
    SendMessageW(h, WM_SETFONT, reinterpret_cast<WPARAM>(font), TRUE);
    controls[id] = h;
    return h;
}
void Label(const wchar_t *text) {
    auto h =
        CreateWindowW(L"STATIC", text, WS_CHILD | WS_VISIBLE, 0, 0, 0, 0, window, nullptr, nullptr, nullptr);
    SendMessageW(h, WM_SETFONT, reinterpret_cast<WPARAM>(font), TRUE);
    labels.push_back(h);
}
void Layout() {
    RECT r;
    GetClientRect(window, &r);
    int w = r.right, h = r.bottom, left = w / 3;
    for (int i = 0; i < 3; ++i) {
        Place(labels[i], 12, 15 + i * 34, 85, 23);
        Place(controls[101 + i], 100, 10 + i * 34, w - 207, 25);
        Place(controls[OpenCt + i], w - 97, 10 + i * 34, 85, 25);
    }
    Place(labels[3], 12, 117, 85, 23);
    Place(controls[Id], 100, 112, w / 2 - 115, 25);
    Place(labels[4], w / 2, 117, 90, 23);
    Place(controls[Section], w / 2 + 90, 112, w / 2 - 102, 25);
    Place(controls[IgnoreLua], 12, 145, w - 24, 23);
    Place(controls[ActivationNote], 12, 171, w - 24, 23);
    Place(labels[5], 12, 205, left - 16, 22);
    Place(labels[6], left + 12, 205, 90, 22);
    Place(controls[Key], left + 105, 200, w - left - 117, 25);
    Place(controls[Tree], 12, 232, left - 12, h - 380);
    Place(controls[Preview], left + 12, 232, w - left - 24, h - 380);
    Place(controls[Status], 12, h - 137, w - 24, 85);
    Place(controls[Validate], w - 244, h - 42, 110, 29);
    Place(controls[ExportButton], w - 122, h - 42, 110, 29);
}
void LoadTable() {
    auto loaded = Table::Read(fs::path(Text(CtPath)));
    table = std::move(loaded);
    items.clear();
    keys.clear();
    current.clear();
    TreeView_DeleteAllItems(controls[Tree]);
    Set(Preview, "");
    Set(Key, "");
    for (size_t i = 0; i < table.entries.size(); ++i) {
        auto &e = table.entries[i];
        auto title =
            Wide(e.name + " [" + e.id + "]" + (e.script.empty() && !e.group ? " (value/pointer)" : "") +
                 (e.activateChildren ? " (auto-enables children)" : ""));
        TVINSERTSTRUCTW insert{};
        insert.hParent = e.parent.empty() ? TVI_ROOT : items.at(e.parent);
        insert.hInsertAfter = TVI_LAST;
        insert.item.mask = TVIF_TEXT | TVIF_PARAM;
        insert.item.pszText = title.data();
        insert.item.lParam = LPARAM(i);
        items[e.id] = TreeView_InsertItem(controls[Tree], &insert);
        keys[e.id] = "Entry" + e.id;
    }
    Set(Status, "Loaded " + std::to_string(table.entries.size()) +
                    " entries. Check feature roots, then Validate.\r\n" +
                    (table.hasLua ? std::string("This table contains Lua; static independent entries require "
                                                "the explicit checkbox above.")
                                  : ""));
}
void ChooseFile(int id, const wchar_t *filter) {
    wchar_t path[32768]{};
    OPENFILENAMEW ofn{};
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = window;
    ofn.lpstrFilter = filter;
    ofn.lpstrFile = path;
    ofn.nMaxFile = 32768;
    ofn.Flags = OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_NOCHANGEDIR;
    if (GetOpenFileNameW(&ofn)) {
        SetWindowTextW(controls[id], path);
        if (id == CtPath)
            LoadTable();
    }
}
void ChooseFolder() {
    IFileDialog *dialog = nullptr;
    if (FAILED(CoCreateInstance(CLSID_FileOpenDialog, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&dialog))))
        throw std::runtime_error("Cannot open folder picker");
    dialog->SetOptions(FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM);
    dialog->SetTitle(L"Choose parent folder for the new patch export");
    if (SUCCEEDED(dialog->Show(window))) {
        IShellItem *item = nullptr;
        if (SUCCEEDED(dialog->GetResult(&item))) {
            PWSTR path = nullptr;
            if (SUCCEEDED(item->GetDisplayName(SIGDN_FILESYSPATH, &path))) {
                auto output = fs::path(path) / fs::path(Text(Id));
                SetWindowTextW(controls[OutPath], output.c_str());
                CoTaskMemFree(path);
            }
            item->Release();
        }
    }
    dialog->Release();
}
struct Result {
    bool ok = false;
    std::string text;
};
void Start(bool exporting) {
    if (busy)
        return;
    if (table.path != fs::path(Text(CtPath)))
        LoadTable();
    std::vector<Selection> selections;
    for (auto &e : table.entries)
        if (TreeView_GetCheckState(controls[Tree], items.at(e.id)))
            selections.push_back({e.id, keys.at(e.id)});
    auto input = table;
    auto exe = fs::path(Text(ExePath)), output = fs::path(Text(OutPath));
    auto id = Utf8(Text(Id)), section = Utf8(Text(Section));
    bool ignore = SendMessageW(controls[IgnoreLua], BM_GETCHECK, 0, 0) == BST_CHECKED;
    if (exe.empty() || (exporting && output.empty()))
        throw std::runtime_error("Choose the game executable and an export folder.");
    busy = true;
    for (auto &[key, h] : controls)
        if (key != Status)
            EnableWindow(h, FALSE);
    Set(Status, exporting ? "Validating and exporting readable scripts…" : "Validating selected entries…");
    worker = std::thread([input, exe, output, id, section, ignore, selections, exporting] {
        auto result = std::make_unique<Result>();
        try {
            auto package = Import(input, Image::Read(exe), selections, id, section, ignore);
            if (exporting)
                Export(package, output);
            result->ok = true;
            result->text = exporting ? "Export complete: " + output.u8string()
                                     : "Validation passed. Ready to export " +
                                           std::to_string(package.scripts.size()) + " scripts.";
            for (auto &feature : package.features) {
                result->text += "\r\n" + feature.key;
                for (auto &dependency : package.features)
                    if (feature.dependencies & dependency.bit)
                        result->text += " requires " + dependency.key;
            }
            result->text += "\r\nIncluded scripts:";
            for (const auto &script : package.scripts)
                result->text += "\r\n" + script.name + " -> " + script.feature;
            if (exporting)
                result->text += "\r\nCopy the folder into the game's patches directory. Follow INSTALL.txt, "
                                "then restart.";
        } catch (const std::exception &e) {
            result->text = e.what();
        }
        PostMessageW(window, Completed, 0, reinterpret_cast<LPARAM>(result.release()));
    });
}
LRESULT CALLBACK Proc(HWND hwnd, UINT message, WPARAM w, LPARAM l) {
    try {
        switch (message) {
        case WM_CREATE: {
            window = hwnd;
            font = static_cast<HFONT>(GetStockObject(DEFAULT_GUI_FONT));
            mono =
                CreateFontW(-14, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                            CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, FIXED_PITCH, L"Consolas");
            Label(L"Cheat table");
            Label(L"Game EXE");
            Label(L"Export folder");
            Label(L"Patch ID");
            Label(L"INI section");
            Label(L"Enhancements");
            Label(L"Feature key");
            for (int id : {CtPath, ExePath, OutPath, Id, Section, Key})
                Make(L"EDIT", L"", ES_AUTOHSCROLL | WS_TABSTOP, id);
            for (auto pair : {std::pair<int, const wchar_t *>{OpenCt, L"Browse…"},
                              {OpenExe, L"Browse…"},
                              {OpenOut, L"Browse…"},
                              {Validate, L"Validate"},
                              {ExportButton, L"Export"}})
                Make(L"BUTTON", pair.second, WS_TABSTOP, pair.first);
            Make(L"BUTTON", L"Ignore table-level Lua (only if selected scripts are independent of it)",
                 BS_AUTOCHECKBOX | WS_TABSTOP, IgnoreLua);
            Make(L"STATIC", L"Children follow the table's activation options, including nested entries.",
                 0, ActivationNote);
            Make(WC_TREEVIEWW, L"",
                 TVS_CHECKBOXES | TVS_HASLINES | TVS_LINESATROOT | TVS_HASBUTTONS | TVS_SHOWSELALWAYS |
                     WS_BORDER | WS_TABSTOP,
                 Tree);
            Make(L"EDIT", L"",
                 ES_MULTILINE | ES_READONLY | ES_AUTOVSCROLL | ES_AUTOHSCROLL | WS_VSCROLL | WS_HSCROLL,
                 Preview);
            SendMessageW(controls[Preview], WM_SETFONT, reinterpret_cast<WPARAM>(mono), TRUE);
            Make(L"EDIT", L"", ES_MULTILINE | ES_READONLY | ES_AUTOVSCROLL | WS_VSCROLL, Status);
            Set(Id, "my-enhancement");
            Set(Section, "ImportedPatches");
            Set(Status, "Choose your saved Cheat Table and TOS.exe. The executable is read only.");
            Layout();
            return 0;
        }
        case WM_SIZE:
            Layout();
            return 0;
        case WM_GETMINMAXINFO:
            reinterpret_cast<MINMAXINFO *>(l)->ptMinTrackSize = {780, 620};
            return 0;
        case WM_COMMAND:
            if (HIWORD(w) == EN_KILLFOCUS && LOWORD(w) == CtPath && !Text(CtPath).empty() &&
                table.path != fs::path(Text(CtPath)))
                LoadTable();
            else if (HIWORD(w) == EN_CHANGE && LOWORD(w) == Key && !settingKey && !current.empty())
                keys[current] = Utf8(Text(Key));
            else if (HIWORD(w) == BN_CLICKED) {
                switch (LOWORD(w)) {
                case OpenCt:
                    ChooseFile(CtPath, L"Cheat tables (*.CT)\0*.CT\0\0");
                    break;
                case OpenExe:
                    ChooseFile(ExePath, L"Executables (*.exe)\0*.exe\0\0");
                    break;
                case OpenOut:
                    ChooseFolder();
                    break;
                case Validate:
                    Start(false);
                    break;
                case ExportButton:
                    Start(true);
                    break;
                }
            }
            return 0;
        case WM_NOTIFY: {
            auto header = reinterpret_cast<NMHDR *>(l);
            if (header->idFrom == Tree && header->code == TVN_SELCHANGEDW) {
                auto change = reinterpret_cast<NMTREEVIEWW *>(l);
                auto &e = table.entries.at(size_t(change->itemNew.lParam));
                current = e.id;
                settingKey = true;
                Set(Key, keys.at(e.id));
                settingKey = false;
                std::string preview = e.script;
                for (size_t at = 0; (at = preview.find('\n', at)) != preview.npos; at += 2)
                    if (!at || preview[at - 1] != '\r')
                        preview.insert(at, "\r");
                Set(Preview, preview);
            }
            return 0;
        }
        case Completed: {
            std::unique_ptr<Result> result(reinterpret_cast<Result *>(l));
            if (worker.joinable())
                worker.join();
            busy = false;
            for (auto &[id, h] : controls)
                EnableWindow(h, TRUE);
            Set(Status, result->text);
            return 0;
        }
        case WM_CLOSE:
            if (busy) {
                Set(Status, "Please wait for validation/export to finish before closing.");
                return 0;
            }
            DestroyWindow(hwnd);
            return 0;
        case WM_DESTROY:
            DeleteObject(mono);
            PostQuitMessage(0);
            return 0;
        }
    } catch (const std::exception &e) {
        Error(e);
        return 0;
    }
    return DefWindowProcW(hwnd, message, w, l);
}
} // namespace
int WINAPI wWinMain(HINSTANCE instance, HINSTANCE, LPWSTR, int show) {
    CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    INITCOMMONCONTROLSEX common{sizeof(common), ICC_TREEVIEW_CLASSES};
    InitCommonControlsEx(&common);
    WNDCLASSW cls{};
    cls.lpfnWndProc = Proc;
    cls.hInstance = instance;
    cls.lpszClassName = L"TOSPatchConverter";
    cls.hCursor = LoadCursorW(nullptr, IDC_ARROW);
    cls.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_BTNFACE + 1);
    RegisterClassW(&cls);
    auto hwnd =
        CreateWindowW(cls.lpszClassName, L"Tales of Symphonia — Cheat Table Converter", WS_OVERLAPPEDWINDOW,
                      CW_USEDEFAULT, CW_USEDEFAULT, 1050, 780, nullptr, nullptr, instance, nullptr);
    if (!hwnd)
        return 1;
    ShowWindow(hwnd, show);
    MSG msg;
    while (GetMessageW(&msg, nullptr, 0, 0) > 0)
        if (!IsDialogMessageW(hwnd, &msg)) {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    CoUninitialize();
    return int(msg.wParam);
}
