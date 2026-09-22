# Readable patches

Patches are loaded from `mods/asm/*/patch.toml` beside `d3d9.dll`. Each folder
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

The `[BattleEnhancements]` section is added to `d3d9_config.ini` on launch. All six
boolean options default to `0`; both spell-slot counts default to `1`. To enable
the boolean features and expand spell capacity, use:

```ini
[BattleEnhancements]
ArtesSphere=1
NewFreeRun=1
ManualOverLimit=1
OverLimitGauge=1
SpellQueueFix=1
NoSpellPause=1
FreeRunMovementPenalty=0.20
PartySpellSlots=4
EnemySpellSlots=3
```

Restart after changes. New Free Run and Manual Over Limit automatically enable
Artes Sphere because they use its controller state. Manual Over Limit also prevents the victory drain.
The gauge and Spell Queue Fix can be used independently. `FreeRunMovementPenalty` is subtracted from
the table's movement multiplier (1.00 normally, 1.15 with Dash); accepted values
are at least 0 and less than 1. The default is 0.20.

Spell Queue Fix in [battle-enhancements/patch.toml](battle-enhancements/patch.toml) version 1.4.0 includes the
completed queue algorithm and supports all expanded party and enemy slot settings. Enable
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

Installation occurs once during D3D initialization. The log reports the package
version and installed patch count for the enabled features. Unexpected
instructions, conflicting hooks, or an unsupported executable disable the entire
requested set for that launch, with the failing site logged. Existing texture,
archive, and fast-forward features continue independently. Do not simultaneously
enable these same scripts in Cheat Engine. Disabling an INI option prevents its
runtime hooks on the next launch; it does not undo arte assignments or other
state already saved by the game.

### Additional Spell Slots

Battle Enhancements expands spell storage with separate code and writable state.
Set the counts in `d3d9_config.ini`, then restart:

```ini
[BattleEnhancements]
PartySpellSlots=4
EnemySpellSlots=3
```

Both settings default to `1`. Fractions are truncated, then `PartySpellSlots`
is clamped to 1–4 and `EnemySpellSlots` to 1–3. Missing, malformed, or nonfinite
values use `1`. Expansion is enabled automatically when either resulting count
exceeds `1`; if both are `1` or unset, it is disabled. There is no separate
enable switch. Clamping does not rewrite user-entered INI values. Spell Queue Fix
supports all 12 integer configurations and remains independently selectable.

Chanting progresses when any configured slot can admit the
pending spell, even if the actor's previous slot is occupied. Final admission
rechecks capacity before assigning a slot. Spell Queue Fix also lets
the last chant tick reach zero before applying queue waits, so additional slots
work with Spell Queue Fix enabled or disabled.

The source is in [battle-enhancements/AddSpellSlots.asm](battle-enhancements/AddSpellSlots.asm),
with sections for helpers, writable state, hooks, and guards. Change the INI
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
the same hook sites.
