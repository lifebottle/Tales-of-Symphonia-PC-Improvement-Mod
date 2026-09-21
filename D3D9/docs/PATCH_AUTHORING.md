# Cheat Engine to readable patches

Keep developing and testing your enhancements in Cheat Engine. The converter reads
saved `.CT` files and exports CE-style assembly that the mod assembles at startup.
Players need the new `d3d9.dll` and the exported patch folder; they do not need
Cheat Engine, Python, WSL, or an external assembler.

## Portable Windows converter

1. Unzip the release and run **tos-ct-converter.exe**.
2. Choose your saved Cheat Table and the game's unmodified **TOS.exe**.
3. Check the enhancements to export. Selecting a group includes its children;
   selecting a script includes children only when its CT activation options say so.
   The child-selection checkbox can disable this behavior.
4. Select an entry to preview its script and edit its INI feature key. Give the
   package a distinct ID and choose its INI section.
5. Click **Validate**. Resolve errors before exporting. Shared symbols require
   their defining entries to be selected in the same package; dependencies between
   the selected features are detected automatically.
6. Choose a **new export folder** and click **Export**. Existing folders are never
   overwritten; use a new folder for each revised export. Failed exports leave
   the previous export and both input files intact.
7. Copy the exported folder into `patches` beside `d3d9.dll`, enable the desired
   keys in `d3d9_config.ini`, and restart. `INSTALL.txt` lists the keys. Avoid
   installing two revisions of the same package or enabling the same hooks in CE.

The converter never attaches to the game or enables installed patches. It reads
TOS.exe for original bytes and static AOB matches. A successful conversion checks
installation requirements; gameplay still needs your usual in-game testing.

A table containing Lua is rejected by default. **Ignore table-level Lua** is only
for selected static scripts that do not depend on that Lua. It does not execute
Lua or permit Lua inside selected scripts.

## Package layout

```text
patches/
  my-enhancement/
    patch.toml
    entry-2365.asm
    INSTALL.txt
```

`patch.toml` contains identity, feature mappings, dependencies, writable allocation
names, and parameters. Assembly, labels, hook destinations, and byte assertions
live in the `.asm` files. There are no serialized code buffers or fixup tables.
Split larger packages into logical scripts sharing registered symbols; each script
has its own local label scope. Cross-package symbol references are unsupported.

Small byte-patch example, `patch.toml`:

```toml
format = 1
id = "example.victory-drain"
version = "1.0.0"
config_section = "ExampleVictoryDrain"
image_base = 0x400000
image_size = 0x2b00000

[[features]]
key = "DisableDrain"
requires = []

[[scripts]]
id = "drain"
name = "Disable victory drain"
file = "drain.asm"
feature = "DisableDrain"
writable = []
```

`drain.asm`:

```asm
[ENABLE]
assert(TOS.exe+80738,75 09)
TOS.exe+80738:
  db EB 09

[DISABLE]
TOS.exe+80738:
  db 75 09
```

This example overlaps Manual Over Limit's existing victory-drain prevention;
use only one of those packages at that site.

## Supported script subset

- `[ENABLE]` x86 instructions, forward labels, `label`, `define`, `alloc`, and
  `registersymbol`. Bare numbers are **hexadecimal**, `#10` and `(int)10` are decimal,
  and `0x10`/`$10` are explicit hexadecimal. Module offsets use the same rules.
- Module-relative/static addresses, allocated blocks, and allocation-offset
  destinations (`arena+4000:`). Ordinary label definitions name the current cursor.
- Addition, subtraction, multiplication by constants, parentheses, and constant
  integer division. Address expressions must reduce to at most one relocatable
  base. `imul eax,10` retains CE's two-operand immediate shorthand.
- `db`, `dw`, `dd`, `dq`, literal byte strings, `(float)`/`(double)` data, `nop count`,
  and `align power_of_two` (zero padding). Addresses in data require `dd`.
- `assert(address, exact bytes)`. Every overwritten byte must be covered by an
  assertion in its script. The converter fills missing assertions from TOS.exe;
  runtime compilation never adopts unchecked live bytes as originals.
- `aobscanmodule` with exact, wildcard, or nibble-wildcard patterns. The converter
  requires exactly one file-backed match, exports a module-relative `define`, and
  preserves exact bytes as an assertion. Hand-maintained packages can retain scans;
  the DLL resolves them against the host executable on disk, then checks live bytes
  before installation. Scans do not cover dynamically generated or patched memory.
- Static `[DISABLE]` bytes/instructions are restoration checks. `dealloc` and
  `unregistersymbol` are accepted there but do not execute. Hooks last until exit.
- CE `//`, `/* */`, and `{ }` comments; semicolon comments are also accepted.

The optional manifest `module` field defaults to `TOS.exe`; the importer records
the supplied executable's filename. Script paths stay inside the package.

The converter infers data-only allocations and lists them in `writable`. The
runtime keeps code RX and data RW. Separate code and mutable state into distinct
`alloc` blocks. Direct writes to executable allocations and branches into declared
writable data are rejected. Indirect self-modification cannot always be detected
and requires manual adaptation.

Unsupported input fails conversion: Lua/mode directives, activation callbacks,
timers, thread creation, pointer/value records and freezes, dynamic `readmem`,
external libraries, runtime-generated symbols, and unimplemented CE directives.
This is a supported Auto Assembler subset, not a complete CE interpreter.

Exports preserve source comments and labels. Generated assertion headers and
resolved AOB directives are marked. Some assembly encodings can differ from CE's;
the compiler checks patch boundaries and rejects hooks that split original
instructions. Use explicit `short`/`near` branches or literal `db` for intentional
encoding-specific byte edits.

## Features and parameters

Feature keys default to off. `requires` names other feature keys in the same
package; enabling a dependent feature enables its requirements. Registered symbols
are visible across scripts in the package, with dependencies enforced by the
runtime compiler.

Parameters remain float32 INI values, including the existing spell-slot thresholds:

```toml
[[parameters]]
key = "MovementPenalty"
feature = "Enabled"
script = "movement"
symbol = "penalty"
default = 0.20
min = 0.0
max_exclusive = 1.0
```

The symbol must address four bytes in that feature's writable allocation. Invalid
or nonfinite INI values use the default. Existing battle/spell-slot INI sections,
keys, defaults, and parameter semantics are unchanged.

## Command line and builds

The GUI and CLI use the same C++ importer and compiler as the DLL:

```text
tos-patch.exe list table.CT
tos-patch.exe convert table.CT --exe TOS.exe --entry 2365=MinimumDamage --id minimum-damage --section ImportedPatches --output exported-minimum-damage
tos-patch.exe check exported-minimum-damage/patch.toml --exe TOS.exe
```

Repeat `--entry ID=Key` for multiple features. `--no-children` and
`--ignore-table-lua` correspond to the GUI options. `check` without `--exe`
compiles exported packages and checks assertions for coverage; supplying the
executable also compares their bytes against that file.

Building requires CMake 3.31+ and a C++17 compiler. Build on Windows with Visual Studio's Win32 target:

```sh
cmake -S D3D9 -B D3D9/build -A Win32
cmake --build D3D9/build --config Release
cpack --config D3D9/build/CPackConfig.cmake -C Release
```

Or cross-compile with the existing MinGW toolchain. All dependency sources are
vendored at pinned revisions. Neither building nor running the tools downloads
anything. A native Linux build produces the CLI and portable compiler tests:

```sh
cmake -S D3D9 -B /tmp/tos-patch-native -DCMAKE_BUILD_TYPE=Debug
cmake --build /tmp/tos-patch-native -j
ctest --test-dir /tmp/tos-patch-native --output-on-failure
```

## Migrating from JSON / loader API

Install the new DLL and complete package folders together. Remove old patch JSON
files; this version logs and ignores them. Existing INI settings continue to work.
The original table is not authoritative for patches that received fixes after
porting: maintain the shipped assembly sources, including those fixes.

`TOSPatchGetAPI(2)` exposes the existing `validate` and `apply` function layout with
absolute `patch.toml` paths. Version 1 is rejected. Validation compiles without
installing hooks; application uses the existing transactional installer and
shared conflict ownership. Call from an ordinary thread after initialization,
never DllMain. `[Patches] AutoLoad=0` leaves installation to an external loader.
There is no live unload or reload. Logs retain the `[Patches]` tag.
