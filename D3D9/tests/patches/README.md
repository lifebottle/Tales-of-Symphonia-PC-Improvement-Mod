# Readable patch checks

Run from the repository root. No test attaches to TOS or touches saves.

The ordinary native CMake build runs `patch_script_test` and
`patch_migration_test` through CTest. These cover CT parsing/selection, CE syntax,
AOB resolution, diagnostics, original-byte and restoration checks, allocation and
relocation rules, dependency discovery, unsupported constructs, Unicode paths,
export preservation, and package parsing. Child activation checks cover saved CT
options, nested scripts/groups, separately selected descendants in every selection
order, runtime dependency closure and export/reload, optional children, unsupported
automatic children, and cycles with shared-symbol dependencies. Migration compares
246 original patch sites and 5,014 guarded bytes against the frozen pre-migration
fixture plus the explicitly checked Spell Queue Fix upgrade (one added unlock
hook and eight retired guard bytes).

The MinGW build also produces Windows x86 harnesses:

```sh
cmake -S D3D9 -B D3D9/build -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw32.cmake -DCMAKE_BUILD_TYPE=Debug
cmake --build D3D9/build -j
mkdir -p /tmp/tos-patches-wine
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/patch_script_test.exe
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/patch_migration_test.exe
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/patch_framework_test.exe
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/battle_patches_test.exe
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/lloyd_super_chain_test.exe
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/spell_slots_test.exe
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/spell_queue_test.exe
WINEPREFIX=/tmp/tos-patches-wine WINEDEBUG=-all wine D3D9/build/ct_converter_test.exe D3D9/patches/minimum-damage/patch.toml D3D9/patches/battle-enhancements/patch.toml
```

On Windows, run the executables directly from the repository root. The hook
harnesses use GCC-style x86 assembly and are built by MinGW; the portable compiler
and importer tests also build with MSVC. All test targets retain assertions in
Release builds.

Coverage retained from the former private harnesses:

- Installer: native absolute/relative relocations, float parameters, RX/RW
  protection, disabled/duplicate/rejected installation, conflicts, INI preservation,
  UTF-16 comments, float defaults, and API v2 negotiation.
- Battle: all 32 feature combinations and 66 sites; Main/Sub inputs, right-stick
  layers, register/stack handling, controller remapping, live Manual Over Limit
  controls, movement, gauge calculations, and original-byte/destination guards.
- Spell slots: all 12 configurations, 12,288 capacity/admission cases, invalid
  settings, lifecycle/state reset, and both installation orders with battle hooks.
- Spell Queue Fix: existing BattleEnhancements INI key, queue alone and with all
  battle features, and all 12 spell-slot configurations in both orders;
  native/expanded busy flags, complete spell-finish epilogue, timers, queue order,
  duplicate/full queues, lock release and Unison; register/stack preservation,
  sentinels around queue storage and original-byte rejection.
- Lloyd: descriptor rebuilds, 174 mismatches, source preservation, registers/flags,
  menu buffer references, and Ability Plus gates.
- CT: actual execution of a converted synthetic hook plus Minimum Damage and all
  seven native/expanded Spell Queue slot lookups.

GUI acceptance: unzip on a machine without developer tools, load a CT and TOS.exe,
select a script, edit its feature key, validate and export to a new folder. Verify
preview/error messages, grouped selection, Unicode/spaced paths, export failures,
and opening the generated folder with `tos-patch check`. The initial implementation
was exercised under Wine on a temporary virtual display; native Windows GUI and
live Windows/Proton gameplay remain separate acceptance checks.

Gameplay acceptance: enable each shipped feature independently and in its normal
combinations; check battle inputs, HUD, descriptor rebuilds, spell queues and map
transitions. Restart between script/INI changes. Confirm all-off defaults and
compatibility with existing texture/archive/fast-forward features. Do not enable
overlapping scripts in Cheat Engine during these checks.
