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

Set the counts in the INI. There is no separate enable switch: it turns on automatically when either count is above 1. Values are truncated to whole numbers and clamped; missing or invalid values use `1`. Your INI values aren't rewritten.

- Chanting continues as long as any configured slot can take the pending spell.
- Works with Spell Queue Fix on or off.
- **Unison / Mystic Artes (v1.6.1):** all party Mystic Artes and summons can be cast concurrently during Unison. Use `PartySpellSlots=4` for four at once, or `2` for two. Enemy slots don't affect the party limit.
- Each caster's resources, portraits, and cleanup are tied to its own slot, so finishing one MA can't release another caster's slot.
- Unison timers for all 22 party MA/summon artes are set to 453 frames.
- This does **not** unlock or assign Mystic Artes. Keep your existing arte setup.
- **Testing status:** Lloyd, Kratos, Raine, and Genis were verified together in game. The other MA combinations passed simulation only and still need in-game validation.

### Spell Queue Fix (v1.6.2)

Uses the new queue from TOS NoTSFix v26.9.5: completed party casts wait in order, guarding or holding a spell removes that caster, and battle end or Unison start clears the queue. Chant timers continue while slots are busy. Extra slots retain their existing capacity and resource checks; enemies use their own admission path.

The update passed isolated hook execution across all battle-option combinations and slot counts, including Unison/Mystic Arte checks. Live battle validation of this queue update is still pending.

## Lloyd Super Chain

Adds Super Chain to Lloyd's MAX-gem EX skill list, fixes the chain windows for Demonic Tiger Blade, Demonic Thrust, Raining Tiger Blade, Tempest Thrust, Tempest Beast, and all four Rising Falcon variants, and extends the Ability Plus consecutive Level 1 allowance when both skills are active. Once-per-chain and same-arte restrictions still apply.

```ini
[LloydSuperChain]
Enabled=1
```

Defaults to `0`. Works independently of Battle Enhancements. Restart after changing it.

## Troubleshooting

Check `d3d9.log`.

- **Success looks like:** `[Patches] lloyd-super-chain 1.0.0: installed 17 patches` (Battle Enhancements logs its version and patch count similarly).
- **If anything goes wrong** (unexpected instructions, conflicting hooks, unsupported executable), the entire requested set is disabled for that launch and the failing site is logged. Texture, archive, and fast-forward features keep working.
- **Disabling an option** only stops the hooks on the next launch. It doesn't undo arte assignments or other state the game already saved.
- **Switching from the IDA memory script to Lloyd Super Chain:** do a fresh launch first, since both use the same hook sites.
