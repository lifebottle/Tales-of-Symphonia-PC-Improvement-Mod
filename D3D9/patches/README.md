# Readable patches

Patches are loaded from `patches/*/patch.toml` beside `d3d9.dll`. Each folder
contains a small manifest and readable CE-style `.asm` files. The DLL assembles
and validates them at startup, then installs the enabled features.

Use **tos-ct-converter.exe** on Windows to select entries from a saved Cheat Table,
validate them against TOS.exe, and export a patch folder. No WSL, Python, or
external assembler is needed. See the [authoring guide](../docs/PATCH_AUTHORING.md)
for the supported CE subset and package format.

This replaces the previous JSON format: install the new DLL and package folders
together, then remove the old `.json` files. Legacy files are logged and ignored.
Existing INI settings are retained. Sources and tools now live in the repository;
`private/` is not required to build or maintain these packages.

## Battle Enhancements

The `[BattleEnhancements]` section is added to `d3d9_config.ini` on launch. All five
options default to `0`. To enable all five features, use:

```ini
[BattleEnhancements]
ArtesSphere=1
NewFreeRun=1
ManualOverLimit=1
OverLimitGauge=1
SpellQueueFix=1
FreeRunMovementPenalty=0.20
```

Restart after changes. New Free Run and Manual Over Limit automatically enable
Artes Sphere because they use its controller state. Manual Over Limit also prevents the victory drain.
The gauge and Spell Queue Fix can be used independently. `FreeRunMovementPenalty` is subtracted from
the table's movement multiplier (1.00 normally, 1.15 with Dash); accepted values
are at least 0 and less than 1. The default is 0.20.

Spell Queue Fix in [battle-enhancements/patch.toml](battle-enhancements/patch.toml) version 1.3.0 includes the
completed queue algorithm and supports [add-spell-slots/patch.toml](add-spell-slots/patch.toml), including
all expanded party and enemy slot settings in either installation order. Enable
it with `[BattleEnhancements] SpellQueueFix=1`, independently or alongside the
other battle features. Install the current DLL and package folders together, then
restart. Compact manifests require the updated manifest loader.

Controls follow the table's controller mappings: hold **LB/L1** to select Sub
artes for new battle inputs; release it to select Main artes again. This also
works with remapped arte face buttons. Use **Select/Back** to switch Main/Sub pages in the arte assignment
menus, hold **LT** for Free Run, and press **RT** to request Manual Over Limit
when its activation conditions are met. Artes Sphere also moves the two battle
shortcuts to right-stick up/down. These are the table's logical controller
buttons; Steam Input or game bindings can change the physical buttons.

Manual Over Limit includes the table's damage-based gauge gain and portrait/
party-limit adjustments. The gauge uses the game's own battle HUD drawing code.
Free Run includes the directly-above/below-enemy correction.

Installation occurs once during D3D initialization. The log reports
`[Patches] battle-enhancements 1.3.0: installed 66 patches` with all five features enabled. Unexpected
instructions, conflicting hooks, or an unsupported executable disable the entire
requested set for that launch, with the failing site logged. Existing texture,
archive, and fast-forward features continue independently. Do not simultaneously
enable these same scripts in Cheat Engine. Disabling an INI option prevents its
runtime hooks on the next launch; it does not undo arte assignments or other
state already saved by the game.

Automated checks cover installation and selected native hook behavior on a
synthetic image. Full battle/HUD behavior still needs in-game validation on
Windows and Proton.

## Additional Spell Slots

[add-spell-slots/patch.toml](add-spell-slots/patch.toml) expands spell storage with
separate code and writable state. Enable it in `d3d9_config.ini`, then restart:

```ini
[AddSpellSlots]
Enabled=1
PartySlots=1
EnemySlots=1
```

`Enabled` defaults to `0`; both slot settings default to `1`. Use `PartySlots`
values 1 through 4 and `EnemySlots` values 1 through 3 for the supported integer
configurations. The settings are float32 thresholds: accepted values are at least
1 and less than 5 for party slots, and at least 1 and less than 4 for enemy slots.
Invalid or nonfinite values fall back to the defaults. Spell Queue Fix supports
all 12 integer configurations in either installation order.

The source is divided into helpers, state, hooks, and guards. Change the INI
settings to configure capacity; the assembly contains the maintained allocation,
lifecycle, and original-byte checks.

## Lloyd Super Chain

[lloyd-super-chain/patch.toml](lloyd-super-chain/patch.toml) adds Super Chain to Lloyd's MAX-gem EX skill
list, fixes the chaining windows for Demonic Tiger Blade, Demonic Thrust,
Raining Tiger Blade, Tempest Thrust, Tempest Beast, and all four Rising Falcon
variants, and extends the Ability Plus consecutive Level 1 allowance when
both skills are active. The original once-per-chain and same-arte restrictions
remain in place.

Enable it in `d3d9_config.ini`, then restart:

```ini
[LloydSuperChain]
Enabled=1
```

The option defaults to `0` and works independently of `[BattleEnhancements]`.
It installs during startup and applies the nine window changes whenever battle
descriptors are rebuilt. No debugger, Python, or on-disk PAC change is needed.
The log reports `[Patches] lloyd-super-chain 1.0.0: installed 17 patches`.
An unexpected battle-data layout skips all nine window writes for that rebuild.
Use a fresh launch when switching from the IDA memory script; both versions use
the same hook sites. The script port has native synthetic tests; its full in-game
acceptance remains separate from live gameplay acceptance.

## Source provenance

These readable packages replace the former runtime JSON definitions. Their
assembly is maintained directly in this folder and copied unchanged to releases.

- **Battle Enhancements 1.3.0** preserves the maintained native port of selected
  TOS NoTSFix v26.9.1 table scripts (table script authors: sdail). It includes the
  port's input/combo/shortcut fixes, live control-mode handling for Manual Over
  Limit, and the completed Spell Queue Fix from sdail's CT entry 2692 (dated
  2026-08-18), formerly maintained as `spell-queue-fix-2`. The queue keeps its
  ordering/timer behavior, with expanded-slot busy lookups, a separate unlock
  hook at +28105, and byte-sized lock resets. Reimporting the original table
  does not reproduce these later fixes.
- **Additional Spell Slots 1.0.0** preserves the maintained native port of
  `spell_slots_expanded_memory.s`, including separate code/state allocation,
  float32 configuration thresholds, original-byte guards, and all 162 patch sites.
  Its source is divided into helpers, state, hooks, and guards.
- **Lloyd Super Chain 1.0.0** preserves the maintained assembly implementing the
  descriptor-rebuild, MAX-gem menu, and Ability Plus changes.
- **Minimum Damage (legacy, no longer bundled)** comes from CT entry 2365, “[Minimum Damage] (Sora3100),” in
  TOS NoTSFix v26.9.1. It changes every nonzero HP delta to -1, including healing;
  the migration intentionally preserves that behavior.

The full external CT and game executable are not included. The tracked migration
fixture freezes only the original patch sites and guarded bytes already present
in this repository's previous definitions: 245 patch sites and 5,015 distinct
guarded bytes. The migration test applies the explicit queue upgrade delta
(the +28105 hook and removal of eight unused guards at +27245), then verifies
246 sites and 5,014 guarded bytes across the original four packages. That test
still requires the removed Minimum Damage package; it cannot run against only the
three currently bundled packages.

Native regressions execute hooks against synthetic images and cover the existing
battle, spell-slot, queue, descriptor, menu, register/stack, and installer checks.
They do not substitute for live gameplay and HUD acceptance on Windows and Proton.

In a source checkout, `D3D9/tests/patches/README.md` contains test commands and
acceptance checks.
