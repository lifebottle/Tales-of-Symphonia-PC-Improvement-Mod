# D3D9 (Name TBD)

A drop-in `d3d9.dll` proxy for the Steam release of *Tales of Symphonia* with four features:

1. **Multi-PATCH archive loader** — patches `TOS.exe` in memory so that every subfolder of the game's `Files/WIN/PATCH` directory is mounted as an additional archive root, with a higher priority than the stock `R01` data. Multiple TLFile mods can be installed side by side without repacking. Also raises the game's I/O buffer from 256 MB to 1 GB so larger modded files load.
2. **Texture replacement** — TSFix-compatible: hashes every DDS the game loads via D3DX with the same CRC32 TSFix uses, and swaps in `textures/replace/<CRC32>.dds` if present. Existing TSFix texture packs work without renaming. Textures loaded from `PATCH` folders are also created at their native DDS resolution instead of being downscaled to the size the game asks for.
3. **Fast-forward cycle** — press **F6** to cycle **1× → 2× → 4× → 8× → 16× → 1×**, primarily for getting through dialogue and cutscenes. A label in the upper-right corner shows the active speed and disappears at 1×. Dialogue still uses the normal advance input.
4. **Readable patch scripts** — a reusable native patch runtime with INI options and a versioned mod-loader API. The [bundled patches](patches/README.md) include battle enhancements, additional spell slots, and Lloyd Super Chain. A portable Windows GUI converts Cheat Tables into CE-style assembly packages. Update scripts without rebuilding the DLL; players do not need Cheat Engine.

Works on **native Windows** and **Proton/Wine** (Steam Deck, Linux). TSFix and SpecialK don't run under Wine; this does, because it uses COM wrapping and a small self-contained IAT patch instead of a detours library.

## How It Works

```
TOS.exe loads d3d9.dll (our proxy)
  ├─ DllMain: patch TOS.exe in place
  │    ├─ 0x5A2177  call → trampoline that loads Files\WIN\PATCH\R01 then every PATCH\<subdir>
  │    └─ 0x5C1380 / 0x5C13F0  I/O buffer 0x10000000 → 0x40000000
  │
  └─ Direct3DCreate9[Ex]() returns our IDirect3D9[Ex] proxy
       └─ CreateDevice[Ex]() returns our IDirect3DDevice9 proxy
            │
            ├─ IAT hook: D3DXCreateTextureFromFileInMemory[Ex]
            │    ├─ CRC32 of the whole DDS blob (TSFix-compatible)
            │    ├─ Width/Height forced to 0 → native DDS resolution
            │    └─ texture pointer → CRC32 mapping stored
            │
            └─ SetTexture() intercepts texture binding:
                 1. Look up CRC32 from the IAT hook map
                 2. If no hash, fall back to LockRect pixel hashing
                 3. Check textures/replace/<CRC32>.dds
                 4. If found, load it and swap it in (cached afterwards)
```

The game addresses are for the Steam release (non-ASLR, image base `0x400000`). If the executable is ever updated they will need to be re-derived; the log will show `WARNING: unexpected value` at the I/O patch sites if the bytes don't match.

## Building

### Cross-compile on Linux (primary — for Proton)

Requires CMake 3.31+ and `mingw-w64` (32-bit target — the game is a 32-bit executable).

```bash
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw32.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build build --target d3d9 -j
```

Output: `build/d3d9.dll`. Build the GUI converter separately:

```bash
cmake --build build --target tos-ct-converter -j
```

### Windows (MSVC)

Requires Visual Studio 2019+ and a Windows SDK with DirectX 9 headers.

```bash
cmake -S . -B build -A Win32
cmake --build build --config Release --target d3d9
# Build the converter separately when needed:
cmake --build build --config Release --target tos-ct-converter
```

> Must be built as **Win32 (32-bit)**. A 64-bit DLL will not load into the game.

## Installation

1. Copy `d3d9.dll` next to `TOS.exe`.
2. Copy the `patches/` directory into the same game directory. When building from source, use `D3D9/patches/` from the checkout:

   ```
   <game_dir>/
   ├── TOS.exe
   ├── d3d9.dll
   └── patches/
       ├── README.md                   ← patch configuration and controls
       ├── battle-enhancements/
       │   ├── patch.toml              ← package manifest
       │   ├── ArtesSphere.asm
       │   ├── ManualOverLimit.asm
       │   ├── NewFreeRun.asm
       │   ├── OverLimitGauge.asm
       │   └── SpellQueueFix.asm
       ├── add-spell-slots/
       │   ├── patch.toml
       │   ├── guards.asm
       │   ├── helpers.asm
       │   ├── hooks.asm
       │   └── state.asm
       └── lloyd-super-chain/
           ├── patch.toml
           └── Enabled.asm
   ```

   Keep each package's `patch.toml` and all its `.asm` files together in its subfolder. See the [patch README](patches/README.md) for settings and controls.
3. Put TLFile mods in subfolders of `Files/WIN/PATCH` (not the top-level game directory), and TSFix-style textures in `textures/replace/`:

   ```
   <game_dir>/
   ├── TOS.exe
   ├── d3d9.dll                     ← this mod
   ├── d3d9_config.ini              ← created on first run
   ├── Files/
   │   └── WIN/
   │       └── PATCH/
   │           ├── 01 MyModA/       ← each subfolder is loaded as its own archive root
   │           │   ├── FILEHEADER.TOFHDB
   │           │   └── TLFILE.TLDAT
   │           └── 02 MyModB/
   │               ├── FILEHEADER.TOFHDB
   │               └── TLFILE.TLDAT
   └── textures/
       └── replace/                 ← <CRC32>.dds files go here
   ```
   Each mod folder must contain **both** `FILEHEADER.TOFHDB` (the file index) and `TLFILE.TLDAT` (the file data). A folder with only `TLFILE.TLDAT` is registered but resolves to nothing.
4. Run the game.

### Proton / Steam Deck

In Steam: right-click the game → Properties → Launch Options:

```
WINEDLLOVERRIDES="d3d9=n,b" %command%
```

This makes Wine load the native (our) `d3d9.dll` instead of its built-in one.

## Configuration (`d3d9_config.ini`)

Created automatically on first run:

```ini
[TextureProxy]
; Dump all textures as DDS files to textures/dump/
DumpTextures=0

; Replace textures from textures/replace/
ReplaceTextures=1

; Log texture hashes, replacements and dumps to tos_improvement_mod.log
EnableLogging=1

; Load D3DX textures at their native DDS resolution instead of the size
; the game requests (needed for hi-res textures shipped in PATCH folders)
NativeTextureSize=1

[FastForward]
Enabled=1
; Windows virtual-key code: 0x75 = F6
ToggleKey=0x75
DisableVSync=1
```

### Fast-forward

Fast-forward starts off every launch. The hotkey works while the game has focus;
holding it does not repeatedly toggle. Losing focus turns fast-forward off on
the next presented frame. A held key must be released before toggling again.
The `[FastForward]` defaults are also added to existing config files. Restart
the game after editing configuration.

The speed cycle is fixed at 1×, 2×, 4×, 8×, and 16×. The old `Multiplier` setting
is ignored if present in an existing config; no config edits are required.
The on-screen `FAST FORWARD 2X`, `4X`, `8X`, or `16X` label stays visible while active.
It uses a small built-in font and scales with the backbuffer resolution.
`ToggleKey` accepts a decimal or `0x` hexadecimal Windows virtual-key code
(1–254). For example, F6 is `0x75` and F7 is `0x76`.
Set `Enabled=0` to disable the feature completely.

`DisableVSync=1` requests immediate presentation at device creation and reset
for the entire session, including normal speed. The game's software limiter
still controls pacing; this avoids a graphics-device reset on each toggle.
Tearing is possible. Set `DisableVSync=0` to preserve the game's presentation
settings, at the cost of potentially limiting fast-forward to the display's
refresh rate. If the driver rejects immediate presentation, the proxy retries
the original settings and logs the fallback. External frame caps can also
limit the achieved speed.

The multiplier accelerates the whole game, including menus and gameplay; it
does not automatically select dialogue choices or press the advance button.
Audio and movie synchronization are not corrected. Existing 60 FPS animation
and timing patches remain in place.

The clock hook verifies two known game call sites and the resolved system
`QueryPerformanceCounter` pointer before installing. An unrecognized or
already hooked clock disables this feature and leaves presentation settings
alone. Check `[FastForward] Ready` and `[FastForward] ON/OFF` in the log.

The PATCH loader and I/O buffer patches are always applied — they run in `DllMain` before the game's own code, so there is nowhere to read a config from yet.

## Readable patches

The DLL loads enabled CE-style assembly packages from `patches/*/patch.toml` at
startup. See the [patch README](patches/README.md) for bundled features, INI
settings, controls, compatibility notes, and source provenance.

Use **tos-ct-converter.exe** to convert saved Cheat Tables into patch folders.
The [converter and authoring guide](docs/PATCH_AUTHORING.md) covers supported
scripts and compact manifests.

## PATCH priority scheme

The game resolves file lookups by priority. `R01` gets `base + 0x3000`; each additional subfolder gets `base + 0x3010`, `+0x3020`, … in directory enumeration order (NTFS: alphabetical). A higher priority wins, so later folders override earlier ones, and every subfolder overrides `R01`.

## Supported DDS formats (replacement textures)

- **Compressed:** DXT1, DXT2, DXT3, DXT4, DXT5
- **Uncompressed:** A8R8G8B8, X8R8G8B8, R8G8B8, R5G6B5, A1R5G5B5, A4R4G4B4, A8, L8, A8L8, L16

Replacement DDS files are loaded by a built-in loader (no D3DX dependency), staged in `SYSTEMMEM` and copied to a `DEFAULT` pool texture — required because the game uses D3D9Ex, which has no `MANAGED` pool.

## Log file

`tos_improvement_mod.log` in the game directory:

| Tag        | Meaning                                              |
|------------|------------------------------------------------------|
| `[Patch]`  | Binary patches, PATCH subfolders found and priorities |
| `[IAT]`    | D3DX hook installation                               |
| `[D3DX]`   | CRC32 of each texture created through D3DX           |
| `[SetTex]` | Texture replacement activity                         |
| `[DDS]`    | Replacement DDS loading                              |
| `[VEH]`    | Access-violation diagnostics if the game crashes     |
| `[FastForward]` | Clock hook, hotkey toggles, presentation fallback |
| `[Patches]` | Definition loading, config, dependencies, validation and installation |

## Source layout

```
src/
├── dllmain.cpp           # DLL entry, all 13 d3d9.dll exports, applies game patches
├── game_patches.h/cpp    # TOS.exe in-memory patches: multi-PATCH loader, I/O buffer, VEH
├── fast_forward.h/cpp    # Validated game clock hook, toggle, presentation settings
├── fast_forward_clock.h # Clock scaling and hotkey state logic
├── fast_forward_overlay.h/cpp # Speed label; saves and restores graphics state
├── d3d9_proxy.h/cpp      # IDirect3D9 wrapper
├── d3d9ex_proxy.h/cpp    # IDirect3D9Ex wrapper (the game uses D3D9Ex)
├── device_proxy.h/cpp    # IDirect3DDevice9 wrapper (SetTexture interception)
├── d3dx9_hook.h/cpp      # D3DX IAT hook: CRC32 hashing + native-size override
├── texture_manager.h/cpp # Config, replacement scanning, caching, DDS dump/load
├── dds_loader.h/cpp      # Pure DDS file loader (no D3DX dependency)
├── crc32.h               # CRC32 (zlib-compatible)
└── logger.h              # Thread-safe file logger
```

## Troubleshooting

**Game crashes on startup**
- Make sure the DLL is 32-bit.
- On Proton, make sure `WINEDLLOVERRIDES="d3d9=n,b"` is set.
- Check the log for `[VEH] ACCESS VIOLATION` and `[Patch] WARNING` lines.

**Mods in PATCH subfolders aren't loading**
- Make sure the folders are under `Files/WIN/PATCH/`, not a `PATCH` folder next to `TOS.exe`. The log's `[Patch] patchPath = "..."` line shows the exact directory being scanned.
- Check the log for `[Patch] Loading "<path>" (priority 0x...)` lines — one per subfolder.
- Each subfolder needs both `FILEHEADER.TOFHDB` and `TLFILE.TLDAT`. A `[Patch] Loading` line only means the folder was registered, not that its index was valid.

**No textures are being replaced**
- Check for `[IAT] Hooked D3DXCreateTextureFromFileInMemoryEx` in the log.
- Check `[D3DX] Tracked texture ... CRC32=` lines and confirm the filename matches.
- Confirm the replacement DDS uses a supported format.

## License

MIT
