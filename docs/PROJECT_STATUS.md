# Return to Tristram — Project Status

Last status update: 2026-09-15

## Overall state

- **Phase 0 — Foundation reset:** COMPLETE
- **Phase 1 — DevilutionX baseline:** engine/build and acceptance harness complete; real Windows runtime acceptance pending
- **Phase 2 — Mod framework:** COMPLETE
- **Phase 3 — Classic+:** ENGINEERING COMPLETE / MANUAL RUNTIME ACCEPTANCE PENDING
- **Phase 4 — Itemisation, skills and classes:** ACTIVE — stable data/save foundation implemented; gameplay engine slices in progress
- **Later phases:** planned, not yet feature-complete

## Pinned engine baseline

- Repository: `diasurgical/DevilutionX`
- Pinned revision: `ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`
- Integration: `Engine/devilutionx` git submodule
- RTT save extension: `.rtt`
- RTT program ID: `RTRM`
- Development version: `0.1.0-dev`

## Phase 2 framework

RTT has a formal mod platform rather than isolated feature wiring: deterministic ten-module runtime lifecycle; exact DevilutionX loose-mod discovery; table-map schema v2 covering items, affixes, uniques, monsters, spells and every shipped class table; append-only stable semantic content IDs; sequential save migrations; Multiplayer Compatibility Policy v1; generated runtime compatibility fingerprints; module self-tests; and CI enforcement of the framework contract.

The sparse TSV exporter still rejects new upstream rows. That remains intentional: Phase 4 generated identity is carried by stable RTT IDs and versioned metadata instead of silently relying on mutable row positions.

## Phase 3 Classic+ engineering scope implemented

- canonical Classic+ default profile;
- DevilutionX visual-grid vendor inventory used as RTT's default shop baseline;
- Diablo-I-native visual-store art-direction rule with no proprietary asset import into the repository;
- Lua Loot Filter 2.0 with permissive/balanced/strict presets and safe user rules;
- exact monster Magic/Fire/Lightning resistance and immunity display;
- floating item information plus RTT equipped-item comparison deltas;
- alternate weapon set / weapon swap with keyboard and controller bindings;
- alternate weapon-set state saved in versioned `rtt_weapon_set` data without changing `PlayerPack`;
- native stash, 12 spell hotkeys and Ctrl-click inventory/stash transfer reused;
- auto-gold and belt refill enabled by the Classic+ profile;
- Warrior/Rogue/Sorcerer starter gold override: 200 gold;
- dedicated Phase 3 runtime checklist and JSON evidence collector.

## Phase 4 foundation implemented

Phase 4 has started with compatibility boundaries first rather than with ad-hoc drops.

- content registry schema v2 adds `set` and `skill` namespaces while preserving append-only semantic IDs;
- four initial item archetypes: Bone Wand, Ossuary Blade, Graveward Shield and Boneweave Robe;
- 12 immutable tiered affixes with compact codes 1–12;
- three prototype uniques: Ashen Covenant, Boneward and Gravewhisper;
- first set contract: Ossuary Regalia;
- three crafting recipe contracts;
- five-skill Necromancer progression catalog: Bone Spike, Bone Armor, Grave Pact, Soul Siphon and Ossuary Mastery;
- first RTT logical class: `RTT_CLASS_0002` Necromancer;
- Save Schema v2 with sequential v1 -> v2 migration and new `itemization_state` / `progression_state`;
- compact item metadata v1 reserves only `Item.dwBuff` bits 5–31, leaving DevilutionX bits 0–4 untouched;
- four 6-bit compact affix slots are reserved from the beginning, avoiding a format migration when RTT moves to 2-prefix/2-suffix Rares;
- Lua itemization/crafting/skills/classes modules now load the Phase 4 runtime catalog;
- CI validates stable references, compact-code uniqueness, bit-mask separation and save migration contracts.

The next engine slice must implement fresh-only Rare generation and exact reconstruction from persisted RTT metadata. A pre-Phase-4 saved item with no RTT marker must remain unchanged when loaded by a newer build.

See `docs/PHASE4_ITEMISATION_SKILLS_CLASSES.md` for the serialization and progression contract.

## Runtime acceptance still required

Engineering progress is not a claim that the full runtime has been manually accepted.

Phase 1 still requires its real Windows baseline acceptance pass with legally obtained Diablo data.

Phase 3 additionally requires the checklist in `docs/PHASE3_RUNTIME_ACCEPTANCE.md`: visual vendor, Loot Filter 2.0, item comparison, resistance UI, weapon swap and persistence, controller flow, stash/gold QoL, two-client weapon synchronization and original-campaign regression. The evidence collector writes `out/runtime-acceptance/evidence/phase3-*.json`; runtime acceptance requires `passed: true`.

The development version therefore remains `0.1.0-dev`. Promotion to the first Classic+ alpha is blocked until the real runtime gate passes.

## Current priority order

1. finish/merge the Phase 3 weapon-swap and finalization trees once Windows CI is green;
2. merge the Phase 4 stable data/save foundation;
3. implement deterministic Rare generation + exact `dwBuff` reconstruction;
4. implement RTT unique/set engine bridges and metadata-safe crafting;
5. implement active/passive progression and make the Necromancer vertical slice playable;
6. add save round-trip and multiplayer reconstruction regression tests.

See `docs/PHASE2_MOD_FRAMEWORK.md`, `docs/PHASE3_CLASSIC_PLUS.md`, `docs/PHASE3_RUNTIME_ACCEPTANCE.md`, `docs/PHASE3_WEAPON_SWAP.md`, `docs/PHASE4_ITEMISATION_SKILLS_CLASSES.md`, `docs/MULTIPLAYER_COMPATIBILITY.md` and `docs/ROADMAP.md`.
