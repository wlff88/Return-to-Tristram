# Return to Tristram — Project Status

Last status update: 2026-09-15

## Overall state

- **Phase 0 — Foundation reset:** COMPLETE
- **Phase 1 — DevilutionX baseline:** engine/build and acceptance harness complete; real Windows runtime acceptance pending
- **Phase 2 — Mod framework:** COMPLETE
- **Phase 3 — Classic+:** ENGINEERING COMPLETE / MANUAL RUNTIME ACCEPTANCE PENDING
- **Phase 4 — Itemisation, skills and classes:** ENGINEERING COMPLETE for the foundation + first Necromancer vertical slice (Rare/Unique/Set round-trip, crafting, skill progression, save migration all CI-green) / **NECROMANCER CAMPAIGN RUNTIME ACCEPTANCE PENDING** — nobody has played it through the original campaign on a real Windows build yet
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

## Phase 4 foundation and first engine slice implemented

Phase 4 started with compatibility boundaries first, then landed a working engine slice behind them ([PR #23](https://github.com/wlff88/Return-to-Tristram/pull/23)):

- content registry schema v2 adds `set` and `skill` namespaces while preserving append-only semantic IDs;
- four initial item archetypes: Bone Wand, Ossuary Blade, Graveward Shield and Boneweave Robe;
- 12 immutable tiered affixes with compact codes 1–12;
- three prototype uniques: Ashen Covenant, Boneward and Gravewhisper;
- first set contract: Ossuary Regalia, with a working `rttBoneArmorRank` equip-count bonus in `CalcPlrItemVals`;
- three crafting recipe contracts backed by `RttPrepareCraft`/`RttCraftHeldRare` (atomic on bad target/cost, preserves base/level/seed);
- five-skill Necromancer progression catalog: Bone Spike, Bone Armor, Grave Pact, Soul Siphon and Ossuary Mastery, with `RttChooseProgression` gating unlock/spend and the armor slot verified to reduce incoming damage;
- first RTT logical class: `RTT_CLASS_0002` Necromancer, gated on `HeroClass::Sorcerer` + the active "rtt" mod via `EnsureRttNecromancerProgression`;
- Save Schema v2 with sequential v1 -> v2 migration and new `itemization_state` / `progression_state`;
- compact item metadata v1 reserves only `Item.dwBuff` bits 5–31, leaving DevilutionX bits 0–4 untouched;
- four 6-bit compact affix slots are reserved from the beginning, avoiding a format migration when RTT moves to 2-prefix/2-suffix Rares;
- fresh-only generation: `SetupAllItems`/`RecreateItem` only stamp RTT metadata on new drops; loaded/recreated no-marker items are never touched;
- Lua itemization/crafting/skills/classes modules now load the Phase 4 runtime catalog;
- CI validates stable references, compact-code uniqueness, bit-mask separation, save migration contracts, and a `generate -> pack -> unpack/recreate -> compare` round-trip for Rares/Uniques/Sets plus a `PackPlayer`/`UnPackPlayer` round-trip for Necromancer progression state, on both Windows MSVC and Linux.

**Fixed forward after merge (2026-09-15):** the `build` and `contracts` gates on PR #23 were red at merge time and fixed in follow-up commits rather than merged broken: `rtt_phase4_test`'s `SetUp()` called `CreatePlayer()`, which needs the proprietary `objcurs.cel` game asset unavailable (and undesirable) in CI — replaced with a manual, cursor-free reproduction of the same stat/level setup. `addExperience()` unconditionally routes through `NetSendCmdParam1`, even single-player, and segfaulted on a null network provider — fixed by bootstrapping the in-memory loopback provider once, mirroring `InitSingle()`. The Windows job resolved unpacked test assets (`txtdata/items/itemdat.tsv`) from the wrong directory, because DevilutionX looks them up relative to the executable's own folder (`SDL_GetBasePath()+"assets/"`) while CMake's `copy_files()` stages them at the plain build directory, not the per-config `Release/` subdirectory MSVC uses — fixed by mirroring the assets alongside the test binary in the workflow.

**Not yet done:** nobody has manually played a Necromancer through the original campaign on a real Windows build using this itemisation/progression stack. That remains open before Phase 4's runtime exit criterion is met. (Multiplayer network broadcast of a progression choice now has a host/client contract test — `RttPhase4.NetworkChoiceAppliesToSenderNotSelf`, [PR #25](https://github.com/wlff88/Return-to-Tristram/pull/25).)

See `docs/PHASE4_ITEMISATION_SKILLS_CLASSES.md` for the serialization and progression contract.

## Runtime acceptance still required

Engineering progress is not a claim that the full runtime has been manually accepted.

Phase 1 still requires its real Windows baseline acceptance pass with legally obtained Diablo data.

Phase 3 additionally requires the checklist in `docs/PHASE3_RUNTIME_ACCEPTANCE.md`: visual vendor, Loot Filter 2.0, item comparison, resistance UI, weapon swap and persistence, controller flow, stash/gold QoL, two-client weapon synchronization and original-campaign regression. The evidence collector writes `out/runtime-acceptance/evidence/phase3-*.json`; runtime acceptance requires `passed: true`.

The development version therefore remains `0.1.0-dev`. Promotion to the first Classic+ alpha is blocked until the real runtime gate passes.

## Current priority order

1. keep Phase 1/Phase 3 real-PC acceptance as a deferred release gate;
2. get real Windows/controller hands on a Necromancer save and play it through the original campaign (Tristram -> Diablo) to close Phase 4's runtime exit criterion;
3. extend the Rare engine from the current single-item-type prototypes (Sword/Staff/Shield/LightArmor) to the full base-item catalogue;
4. add a player-facing way to call `RttChooseProgression()` — it exists and is CI-tested, but nothing calls it outside the test yet (no menu/hotkey UI), so a real player has no way to spend a Necromancer upgrade point;
5. begin Phase 5 (Resurrected campaign) planning once the above close out Phase 4.

See `docs/PHASE2_MOD_FRAMEWORK.md`, `docs/PHASE3_CLASSIC_PLUS.md`, `docs/PHASE3_RUNTIME_ACCEPTANCE.md`, `docs/PHASE3_WEAPON_SWAP.md`, `docs/PHASE4_ITEMISATION_SKILLS_CLASSES.md`, `docs/MULTIPLAYER_COMPATIBILITY.md` and `docs/ROADMAP.md`.
