# Tales of Symphonia Mod Loader

A drop-in `d3d9.dll` proxy for the Steam release of *Tales of Symphonia*. Works on native Windows and Proton/Wine (Steam Deck, Linux).

## Features

- **Multiple TLFile mods, no repacking.** Every subfolder of `mods/tlfile/` is loaded on top of the stock data. Later folders override earlier ones (alphabetical order). The I/O buffer is also raised to 1 GB so large modded files load.
- **Texture replacement.** TSFix-compatible: existing TSFix packs work without renaming. Drop DDS files in `mods/textures/replace/` (nested pack folders are fine). Press **F5** in-game to reload them.
- **Fast-forward.** Press **F6** to cycle 1× → 2× → 4× → 8× → 16× → 1×. A label in the upper-right shows the current speed.
- **Patch scripts.** Optional patch packages (battle enhancements, extra spell slots, Lloyd Super Chain) in `mods/asm/`, no Cheat Engine needed. See [patches](patches/README.md).

## Installation

1. Copy `d3d9.dll` next to `TOS.exe`.
2. Copy any patch packages you want into `mods/asm/`. Keep each package's `patch.toml` and all its `.asm` files together.
3. Put TLFile mods in `mods/tlfile/<mod name>/`. Each folder needs **both** `FILEHEADER.TOFHDB` and `TLFILE.TLDAT`.
4. Put texture packs in `mods/textures/replace/`.
5. **Proton only:** set the launch option `WINEDLLOVERRIDES="d3d9=n,b" %command%`.
6. Run the game.

```
<game_dir>/
├── TOS.exe
├── d3d9.dll
├── d3d9_config.ini        ← created on first run
└── mods/
    ├── asm/<package>/patch.toml + .asm files
    ├── textures/replace/<pack>/<CRC32>.dds
    └── tlfile/<mod>/FILEHEADER.TOFHDB + TLFILE.TLDAT
```

## Controls

| Key | Action |
|-----|--------|
| **F5** | Reload replacement textures |
| **F6** | Cycle fast-forward speed |

## Fast-forward notes

- Starts **off** every launch. Losing window focus turns it off.
- Speeds up everything, menus included. It does not auto-advance dialogue.
- Audio and movie sync are not corrected, so expect drift at high speeds.
- Driver or overlay frame caps can limit the speed you actually get.

## Configuration

`d3d9_config.ini` is created on first run. Restart the game after editing.

```ini
[TextureProxy]
DumpTextures=0        ; dump textures to mods/textures/dump/
ReplaceTextures=1     ; enable texture replacement
EnableLogging=1       ; write d3d9.log
NativeTextureSize=1   ; load hi-res textures at native size

[FastForward]
Enabled=1
ToggleKey=0x75        ; Windows virtual-key code (F6 = 0x75, F7 = 0x76)
DisableVSync=1        ; needed for high speeds; may cause tearing
```

## Supported texture formats

DXT1–DXT5, A8R8G8B8, X8R8G8B8, R8G8B8, R5G6B5, A1R5G5B5, A4R4G4B4, A8, L8, A8L8, L16.

## Troubleshooting

Check `d3d9.log` in the game folder first.

- **Crashes on startup:** make sure Steam is running and the DLL is 32-bit. Look for `[VEH] ACCESS VIOLATION` or `[Patch] WARNING` in the log. A warning usually means the game executable isn't the expected Steam version.
- **TLFile mods not loading:** the folder must be under `mods/tlfile/` and contain both required files. Look for `[Patch] Loading "<path>"` lines.
- **Textures not replaced:** check the DDS is in a supported format and the filename matches the `CRC32=` value in the `[D3DX]` log lines.
- **Fast-forward not working:** look for `[FastForward] Ready` in the log. If the game's clock isn't recognized, the feature disables itself.

## Building

Must be a **32-bit** build (the game is 32-bit).

```bash
# Linux cross-compile (mingw-w64, CMake 3.31+)
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw32.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build build --target d3d9 -j

# Windows (MSVC)
cmake -S . -B build -A Win32
cmake --build build --config Release --target d3d9
```

Output: `build/d3d9.dll`. Patch packages are not copied into the build; take them from `patches/` in the repo.
