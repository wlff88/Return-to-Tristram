# CLAUDE.md — Return to Tristram engineering rules

## Mission

Build Return to Tristram as a maintainable Diablo I overhaul on top of DevilutionX. Do not attempt a literal source-code merge of DevilutionX, Tchernobog, Belzebub, The Hell or Infernity.

## Rules

1. DevilutionX is the engine foundation.
2. Keep new gameplay outside engine code whenever practical.
3. Prefer data-driven definitions over hard-coded tables.
4. Keep each gameplay family isolated under `Mods/<module>`.
5. Never add proprietary Blizzard assets to git.
6. Do not import third-party mod source until licence and provenance are documented in `docs/MOD_SOURCE_MATRIX.md`.
7. Treat save/network compatibility as explicit design constraints.
8. Document unavoidable patches to upstream DevilutionX.

## Module ownership

- `Mods/core`: hooks, feature flags, configuration and compatibility glue.
- `Mods/quests`: campaign and quest extensions.
- `Mods/classes`: class definitions and class mechanics.
- `Mods/skills`: active/passive skills and skill-tree logic.
- `Mods/itemization`: affixes, rarity, uniques, sets and corruption.
- `Mods/crafting`: recipes, runes, upgrades and rerolls.
- `Mods/monsters`: monsters, AI tuning and encounters.
- `Mods/bosses`: bosses, phases and boss modifiers.
- `Mods/abyss`: endgame dungeon generation, tiers and modifiers.
- `Mods/qol`: stash, loot filters, controls and interface QoL.

## Implementation order

1. Pin DevilutionX baseline.
2. Establish clean build/bootstrap.
3. Confirm vanilla campaign start, save/load and controller input.
4. Add feature flags/config.
5. Add project data loading.
6. Add one demonstrator change per module.
7. Build Classic+ vertical slice.
8. Begin larger campaign/endgame work.

## Third-party handling

For every adapted file record upstream project, repository, exact commit/tag, files used, licence, modifications and compatibility notes. If provenance is unclear, treat it as reference only.
