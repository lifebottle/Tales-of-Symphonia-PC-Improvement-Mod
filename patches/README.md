# Patch Packages

Patches load from `mods/asm/*/patch.toml` beside `d3d9.dll`. Each package folder holds a manifest plus its `.asm` files. The DLL assembles and validates them at startup and installs the enabled features. No Cheat Engine required.

## Installing

- Install the current DLL and the package folders together, keeping each package's `patch.toml` and all `.asm` files in one folder.
- Enable features in `d3d9_config.ini`, then restart the game.
- Don't run the same scripts in Cheat Engine at the same time.

## Battle Enhancements

Add to `d3d9_config.ini`. Booleans default to `0`, spell slot counts default to `1`.

```ini
[BattleEnhancements]
ArtesSphere=1
FreeRun=1
ManualOverLimit=1
OverLimitGauge=1
SpellQueueFix=1
NoSpellPause=1
FreeRunMovementPenalty=0.20
PartySpellSlots=4
EnemySpellSlots=3
```

| Option | Notes |
|--------|-------|
| `ArtesSphere` | Enabled automatically by New Free Run and Manual Over Limit. |
| `FreeRun` | Hold LT to free run. |
| `FreeRunMovementPenalty` | (0 to <1, default 0.20) is subtracted from movement speed when free running |
| `ManualOverLimit` | Press RT to trigger when conditions are met. Also prevents the victory drain. |
| `OverLimitGauge` | Damage-based gauge gain, drawn with the game's own HUD code. Works independently. |
| `SpellQueueFix` | Allow spells to be cast in the order that they are ready. |
| `NoSpellPause` | Disables spell pause (EXPERIMENTAL) |
| `PartySpellSlots` | 1-4 concurrent party casts. |
| `EnemySpellSlots` | 1-3 concurrent enemy casts. |

### Controls

Based on the controller mappings; Steam Input can change the physical buttons.

- **LB/L1 (hold):** use Sub artes for new battle inputs. Release for Main artes. Works with remapped face buttons.
- **Select/Back:** switch Main/Sub pages in the arte assignment menus.
- **LT (hold):** Free Run.
- **RT:** request Manual Over Limit.
- **Right stick up/down:** battle shortcuts (moved here by Artes Sphere).

### Additional Spell Slots

Add additional spell slots to allow casting multiple high level spells at the same time. Party and enemy slots are separately configured. Party max is 4, enemy max is 3.

### Spell Queue Fix

No punishment for running multiple casters. Spells are cast in the order they are ready rather than being stuck in a predetermined order.

## Lloyd Super Chain

Adds Super Chain to Lloyd's MAX-gem EX skill list, makes all of his Level 3 artes chainable, and allows chaining two Level 1 artes together at any point in the combo if Ability Plus is active. Once-per-chain and same-arte restrictions still apply.

```ini
[LloydSuperChain]
Enabled=1
```

## QoL

This section is for quality of life enhancements. Currently the only option is 'SkippableFMVs` which allows you to skip story cutscenes and the end credits.

```ini
[QoL]
SkippableFMVs=1
```

## Debug

Copy the complete `debug` folder into `mods/asm/debug/` and set these independent
options in `d3d9_config.ini`:

```ini
[Debug]
Hitboxes=0
Hurtboxes=0
HitboxAlpha=0.20
EnemiesDontAttack=0
DealMinimumDamage=0 ; boolean
DisableEncounters=0
DebugMapLoader=1
```

### Debug map loader (experimental)

`DebugMapLoader=1` adds a Start-button menu in eligible field/overworld gameplay. Requires companion TLFile for English translation.

## Troubleshooting

Check `d3d9.log`.

- **Success looks like:** `[Patches] lloyd-super-chain 1.0.0: installed 17 patches` (Battle Enhancements logs its version and patch count similarly).
- **If anything goes wrong** (unexpected instructions, conflicting hooks, unsupported executable), the entire requested set is disabled for that launch and the failing site is logged. Texture, archive, and fast-forward features keep working.
- **Disabling an option** only stops the hooks on the next launch. It doesn't undo arte assignments or other state the game already saved.
- **Switching from the IDA memory script to Lloyd Super Chain:** do a fresh launch first, since both use the same hook sites.
