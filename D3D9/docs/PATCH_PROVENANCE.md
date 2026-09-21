# Patch source provenance

These readable packages replace the former runtime JSON definitions. Their
assembly is maintained directly in `D3D9/patches/` and copied unchanged to releases.

- **Battle Enhancements 1.2.2** preserves the maintained native port of selected
  TOS NoTSFix v26.9.1 table scripts (table script authors: sdail). It includes the
  port's input/combo/shortcut fixes, live control-mode handling for Manual Over
  Limit, and Spell Queue Fix support for expanded spell slots. Reimporting the
  original table does not reproduce these later fixes.
- **Additional Spell Slots 1.0.0** preserves the maintained native port of
  `spell_slots_expanded_memory.s`, including separate code/state allocation,
  float32 configuration thresholds, original-byte guards, and all 162 patch sites.
  Its source is divided into helpers, state, hooks, and guards.
- **Lloyd Super Chain 1.0.0** preserves the maintained assembly implementing the
  descriptor-rebuild, MAX-gem menu, and Ability Plus changes.
- **Minimum Damage** comes from CT entry 2365, “[Minimum Damage] (Sora3100),” in
  TOS NoTSFix v26.9.1. It changes every nonzero HP delta to -1, including healing;
  the migration intentionally preserves that behavior.

The full external CT and game executable are not included. The tracked migration
fixture freezes only the original patch sites and guarded bytes already present
in this repository's previous definitions. It verifies all 245 patch sites and
5,015 distinct guarded bytes across the four packages.

Native regressions execute hooks against synthetic images and cover the existing
battle, spell-slot, queue, descriptor, menu, register/stack, and installer checks.
They do not substitute for live gameplay and HUD acceptance on Windows and Proton.
