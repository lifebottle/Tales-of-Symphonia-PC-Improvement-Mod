# Patch Packages

Patches load from `mods/asm/*/patch.toml` beside `d3d9.dll`. Each package folder holds a manifest plus its `.asm` files. The DLL assembles and validates them at startup and installs the enabled features. No Cheat Engine required.

## Installing

- Install the current DLL and the package folders together, keeping each package's `patch.toml` and all `.asm` files in one folder.
- Enable features in `d3d9_config.ini`.
- Missing options are added to `d3d9_config.ini` with default values on game start.
- Options are enumerated at game startup. Changes require a restart.

### Example Config

```ini
[BattleEnhancements]
ArtesSphere=1
FreeRun=1
ManualOverLimit=1
OverLimitGauge=1
SpellQueueFix=1
NoSpellPause=0
FreeRunMovementPenalty=0.20
PartySpellSlots=4
EnemySpellSlots=3

[LloydSuperChain]
Enabled=1

[QoL]
SkippableFMVs=1
EnhancedHolyBottles=1
FastText=1
RheairdMoveSpeedMultiplier=2.0
RheairdTurnSpeedMultiplier=2.5
FastBlockPush=1
```


## Battle Enhancements

| Option | Notes |
|--------|-------|
| `ArtesSphere` | Adds a second set of assignable artes |
| `FreeRun` | Hold LT to free run |
| `FreeRunMovementPenalty` | (0 to <1, default 0.20) is subtracted from movement speed when free running |
| `MinCameraDistance` | (1 - 100, 0 = disabled) Keeps the camera from zooming in past a certain distance |
| `NoCameraRotationDuringFreeRun` | Disables camera rotation during free run, use with MinCameraDistance |
| `ManualOverLimit` | Press RT to trigger over limit |
| `OverLimitGauge` | Damage-based gauge gain, drawn with the game's own HUD code. Works independently |
| `SpellQueueFix` | Allow spells to be cast in the order that they are ready |
| `NoMysticArteReqs` | Disables weapon and story requirements for Lloyd, Zelos, Kratos, Presea, and Regal MA's. Change Lloyd's low HP requirement to an OVL requirement |
| `NoSpellCancelReqs` | Removes the arte usage requirement for spell canceling that was introduced in Chronicles |
| `NoSpellPause` | Disables spell pause |
| `PartySpellSlots` | 1-4 concurrent party casts |
| `EnemySpellSlots` | 1-3 concurrent enemy casts |

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

| Option | Notes |
|--------|-------|
| `Enabled` | 1 = Enabled, 0 = Disabled |

## QoL

This section is for quality of life enhancements.

| Option | Notes |
|--------|-------|
| `SkippableFMVs` | Allows skipping story cutscenes and the end credits |
| `FastText` | Hold B to skip dialogue |
| `EnhancedHolyBottles` | Walk through enemies when holy bottle is active, hold B to temporarily disable |
| `RheairdMoveSpeedMultiplier` | Multiplies move speed of Rheaird by this value |
| `RheairdTurnSpeedMultiplier` | Multiplies turn speed of Rheaird by this value |
| `FastBlockPush` | Push/pull blocks faster |

## Debug

Copy the complete `debug` folder into `mods/asm/debug/` and set these independent
options in `d3d9_config.ini`:

| Option | Notes |
|--------|-------|
| `Hitboxes` | Draws hitboxes on weapons/attacks |
| `Hurtboxes` | Draws hurtboxes on enemies/allies |
| `HitboxAlpha` | Configurable hitbox/hurtbox alpha, default 0.20 |
| `EnemiesDontAttack` | Disables enemy AI |
| `DealMinimumDamage` | Always deal 1 damage to enemies |
| `DisableEncounters` | Always have enhanced holy bottle active, incompatible with `EnhancedHolyBottles` |
| `DebugMapLoader` | Press Start to open debug map loader, requires companion TLFile for English translation |
| `DrawSkitID` | Draws the current skit ID on the bottom-left of the screen, maps to debug map skit loader |

## Troubleshooting

Check `d3d9.log`.

- **Success looks like:** `[Patches] lloyd-super-chain 1.0.0: installed 17 patches` (Battle Enhancements logs its version and patch count similarly).
- **If anything goes wrong** (unexpected instructions, conflicting hooks, unsupported executable), the entire requested set is disabled for that launch and the failing site is logged. Texture, archive, and fast-forward features keep working.
- **Disabling an option** only stops the hooks on the next launch. It doesn't undo arte assignments or other state the game already saved.
- **Switching from the IDA memory script to Lloyd Super Chain:** do a fresh launch first, since both use the same hook sites.
