# Patch Packages

Patches load from `mods/asm/*/patch.toml` beside `d3d9.dll`. Each package folder holds a manifest plus its `.asm` files. The DLL assembles and validates them at startup and installs the enabled features. No Cheat Engine required.

## Installing

- Install the current DLL and the package folders together, keeping each package's `patch.toml` and all `.asm` files in one folder.
- Enable features in `d3d9_config.ini`.
- Missing options are added to `d3d9_config.ini` with default values on game start.
- Options are enumerated at game startup. Changes require a restart.

### Example Config

```ini
[60FPS]
Enabled=0

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

[QoL]
SkippableFMVs=1
EnhancedHolyBottles=1
FastText=1
RheairdMoveSpeedMultiplier=2.0
RheairdTurnSpeedMultiplier=2.5
FastBlockPush=1
DisableBackgroundPause=0
MenuOverflowFix=0
SaveAnywhere=0
DisablePartyReqs=0
ForceControllerDisplay=0

[KoQoL]
SubtitleToggle=1
SubtitleSizeAdjust=1
TitleParaDisplay=1
CostumeOnly=1
ShadowScale=1
TSTypeSwitch=1

[KoCombat]
AlwaysMagicLens=1
BetterArteChains=1
CombatMenuText=1
CombatMenuWidth=1
ExpandedEXGemMax=1
MidAirAndFamilyChaining=0
MidAirArtes=0
UnknownDifficulty=1

[KoPartyBuff]
SheenaForceSealDamage=0
KraZelHealingBuff=0
SheenaLifeSpiritBuff=0
PermaTetheSylvSeal=0
ColetteHolySongHeal=0
ChargeTPRecovery=0
RegalHealingBuffs=0
```


## 60FPS

Set `Enabled=1` under `[60FPS]` to run the game at 60FPS (disabled by default). Use alongside the [60FPS Fixes TLFile mod](../tlfile/README.md#60fps-fixes) for additional arte and animation fixes.

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
| `PartySpellSlots` | 1-4 concurrent party casts |
| `EnemySpellSlots` | 1-3 concurrent enemy casts |
| `AllowArteFamilyChaining` | Allows chaining family artes together in a combo. E.g. Demon Fang -> Double Demon Fang |

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

| Option | Notes |
|--------|-------|
| `Enabled` | 1 = Enabled, 0 = Disabled |

## QoL

This section is for quality of life enhancements.

| Option | Notes |
|--------|-------|
| `EnableVoicedSkits` | Enables Japanese dub for skits when playing in English |
| `SkippableFMVs` | Allows skipping story cutscenes and the end credits |
| `FastText` | Hold B to skip dialogue |
| `EnhancedHolyBottles` | Walk through enemies when holy bottle is active, hold B to temporarily disable |
| `RheairdMoveSpeedMultiplier` | Multiplies move speed of Rheaird by this value |
| `RheairdTurnSpeedMultiplier` | Multiplies turn speed of Rheaird by this value |
| `FastBlockPush` | Push/pull blocks faster, explicitly overriding the 60fps block-speed correction when present |
| `DisableBackgroundPause` | Prevents the game from pausing when the window is inactive |
| `MenuOverflowFix` | Fixes the menu overflow glitch that occurs in the artes menu |
| `SaveAnywhere` | Enables the ability to save without a memory circle |
| `DisablePartyReqs` | Disables the requirement for certain characters to be in the party for a fight |
| `ForceControllerDisplay` | Forces the controller inputs to always display |

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

## KoQoL

Quality-of-life and visual enhancements.

| Option | Notes |
|--------|-------|
| `SubtitleToggle` | Controls subtitles for voiced dialogue: `0` displays subtitles, `1` disables them. |
| `SubtitleSizeAdjust` | Reduces subtitle text size and removes its background box. |
| `TitleParaDisplay` | Displays level-up parameter bonuses when highlighting titles in the Titles menu. |
| `CostumeOnly` | Allows a costume to be equipped independently of a stat-boosting title; the costume selection is retained when saving and loading. |
| `ShadowScale` | Increases the radius of shadows beneath the player and NPCs in towns and dungeons. |
| `TSTypeSwitch` | Allows instant switching between S/T Style from the EX Skill menu. |

**Note:** `SubtitleToggle=1` means subtitles **off**, not on.

## KoCombat

Battle interface improvements and additional combat mechanics.

| Option | Notes |
|--------|-------|
| `AlwaysMagicLens` | Always displays enemy HP and TP without using a Magic Lens or Inspect Eye. |
| `BetterArteChains` | Reduces recovery times for selected Artes to improve combo chaining. Integrates Lloyd Super Chain's chaining behavior, including Ability Plus and Lloyd's Level 3 chaining windows. Requires `ExpandedEXGemMax`. |
| `CombatMenuText` | Expands abbreviated battle command names to their full text. |
| `CombatMenuWidth` | Adjusts battle command menu widths to fit the expanded text. Requires `CombatMenuText`. |
| `ExpandedEXGemMax` | Expands EX Gem MAX with a 17th entry for every party member. |
| `MidAirAndFamilyChaining` | Allows chaining Artes while airborne and between Artes in the same family. Requires `MidAirArtes`. |
| `MidAirArtes` | Allows selected Artes for Lloyd, Presea, and Kratos/Zelos to be used mid-air without the Sky Cancel compound EX Skill. |
| `UnknownDifficulty` | Adds Unknown difficulty to Battle Rank, with 3× enemy HP, 2× TP, 2× Attack, and 2× Magic. |

**Compatibility:** `MidAirAndFamilyChaining` already includes same-family chaining. Do not enable the separate `AllowArteFamilyChaining` feature from Battle Enhancements alongside it, as the patches overlap.

## KoPartyBuff

Character-specific Arte adjustments, recovery improvements, and balance changes. All options are disabled by default in the supplied example configuration.

| Option | Notes |
|--------|-------|
| `SheenaForceSealDamage` | Force Seal now deals damage against its current target, while retaining the original effect. |
| `KraZelHealingBuff` | Healing Wind restores 36% of Max HP (3 × 12%) and Healing Stream restores 50% (5 × 10%). Kratos's Guardian Field now restores 10% instead of 5% of Max HP and also heals Kratos himself. |
| `SheenaLifeSpiritBuff` | Increases Life Seal's HP recovery from 10% to 30% of damage dealt, and Spirit Seal's TP recovery from 3% to 4% of damage dealt. |
| `PermaTetheSylvSeal` | Extends Sheena's Tethe and Sylva elemental buffs for the entire battle. |
| `ColetteHolySongHeal` | Adds party-wide HP recovery equal to 20% of Max HP to Holy Song |
| `ChargeTPRecovery` | Changes Raine's Charge to restore 5% of the target's Max TP instead of a fixed 15 TP. |
| `RegalHealingBuffs` | Reduces cast times and distance penalties for Regal's Healer and Grand Healer Artes. Chi Healer restores 30% of Max HP or revives a fallen ally, with increased TP cost and casting time. |

## Patch overrides

When two patches change the same part of the game, the loader normally skips the conflicting feature. To let a script replace another package's changes, add `overrides` under that script's entry in `patch.toml`:

```toml
[[scripts]]
file = "FastBlockPush.asm"
overrides = ["60fps"]
```

Use the other package's `id` from its `patch.toml`, spelled exactly the same. You can list more than one: `overrides = ["package-a", "package-b"]`. This applies only to the script listed above it. The package being overridden must load first; package folders load alphabetically.

Only use this for patches intended to work together. The loader still checks that the game code matches what the script expects. Restart the game to apply changes. A log message such as `FastBlockPush overrides 60fps` confirms success.

## Troubleshooting

Check `d3d9.log`.

- **Success looks like:** an `installed ... patches` log entry for each enabled package (such as `KoCombat`, `KoPartyBuff`, or `KoQoL`). Exact patch counts depend on the selected features.
- **If anything goes wrong** (unexpected instructions, conflicting hooks, unsupported executable), the entire requested set is disabled for that launch and the failing site is logged. Texture, archive, and fast-forward features keep working.
- **Disabling an option** only stops the hooks on the next launch. It doesn't undo arte assignments or other state the game already saved.
