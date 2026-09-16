# Return to Tristram — Project Status

Last status update: 2026-09-16

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
- Warrior/Rogue/Sorcerer starter gold override: **65,535 gold (temporary)** — raised from 200 on 2026-09-16 specifically to let a tester afford Horadric Knowledge purchases (5,000-400,000 gold per tier) without a debug build's console commands, which don't exist in Release builds (`_DEBUG`-gated). 65,535 is the actual ceiling: the starting-loadout gold field is a `uint16_t` (`playerdat.hpp`), so a single starting stack cannot go higher — covers Horadric Knowledge tiers I-III (5,000/20,000/60,000); tiers IV-V (150,000/400,000) still need gold earned in-game. Revert to a real balance value (200, or whatever Phase 3's actual target is) once Item UX/Salvage/Crafting manual testing is done — see the new section below;
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

## Item UX / Salvage / Crafting rework (2026-09-16)

A separate, later body of work from a standalone user design spec ("Return to Tristram — Item UX, Salvage i Crafting"), not part of the Phase 0-5 roadmap above. Implemented as patches 0017-0024, all merged to `main`. Order followed: Tooltip -> Sell/Salvage -> Cain/Horadric Knowledge -> Horadric Cube, per the user's own explicit choice.

### Current state

- **D2-style dual tooltip** (patch 0017): hovering any item shows its own full stat box; if it occupies an equipped slot, a second independent box shows the currently-equipped item's stats beside it — never merged into one box. Wired into inventory, stash, visual store, and ground-item hover (previously name-only).
- **Sell/Salvage split** (patch 0019): Sell unchanged (any vendor, gold). New "Salvage Item" option at Griswold destroys an equipped-type item for materials tiered by rarity (Normal/Magic/Rare/Unique-or-Set -> Iron Scrap/Arcane Dust/Blood Shard/Radiant Shard), reusing 4 new item indexes with existing vanilla graphics (Magic Rock/Spectral Elixir/Blood Stone/Auric Amulet).
- **Cain: Identify All + Horadric Knowledge** (patch 0020): batched identify at one combined gold cost; 5-tier gold-gated crafting-knowledge progression (5,000/20,000/60,000/150,000/400,000 gold, purchasable only in order, tier V also requires character level 30) persisted in a new `rtt_crafting_state` save archive entry.
- **Horadric Cube** (patch 0021): physical object near Cain; holding a Rare item and clicking it opens a real recipe menu (new `TalkID::RttHoradricCube` store-dialog page) listing the 3 recipes actually implemented (Reforge Rare, Reroll Affix Slot — tier II; Raise Affix Tier — tier III), locked tiers shown as "Unknown Recipe" rather than hidden.
- **Physical object placement** (patch 0023): stash chest near Ogden/Tavern, crafting anchor near Griswold/Smith, Horadric Cube near Cain/Storyteller, waypoint circle (town) near the Cathedral entrance — all NPC positions read at runtime from `towners.tsv`, not hardcoded.
- **Town object click fix** (patch 0024): `LeftMouseCmd()`'s town branch never checked `ObjectUnderCursor` at all (vanilla town never had operable objects, so nobody had reason to) — mouse clicks on any physical town object silently did nothing even though hovering correctly showed its name. Fixed; the gamepad/controller path was already correct.
- **Debug stash seed** (patch 0018, `_DEBUG` builds only): `dev.seedStashTestData()` drops test gold + placeholder items into the stash for manual testing.

### Known problems (not yet fixed)

- Only 3 of the ~15 named recipes in the user's spec have real engine support (`RttReforgeHeldRare`/`RttRerollHeldAffixSlot`/`RttRaiseHeldAffixTier`, Rare tier only, from the earlier Phase 4 crafting engine). The Cube has nothing to offer a Normal/Magic-tier item, and Horadric Knowledge tier I (Enchant Normal Item/Reforge Magic Item/Reroll Affix Value) unlocks nothing usable yet.
- Unique/Set materials should also drop from bosses per the spec (so destroying a Unique/Set item for its rare material is never required for progression) — this is a boss loot-table change, not done.
- No "Required Level" tooltip line exists anywhere, because no such field exists on `Item` in vanilla or RTT code today — adding one is a content/save-format decision (a new persisted attribute), deliberately not invented unilaterally.
- Patch 0024 (the click fix) has not been manually confirmed working yet — it was diagnosed and fixed via full source-chain tracing (click handler -> network command -> action dispatch -> `OperateObject()`), not by reproducing the failure interactively. Needs the user's next playtest to confirm.
- Starting gold is temporarily 65,535 (see above, the `uint16_t` ceiling for a single starting stack) — not a real balance value, must be reverted once testing is done. Testing Horadric Knowledge tiers IV-V needs gold earned in-game on top of the starting amount.
- General: this whole rework has had exactly one round of real human playtesting so far (which caught the town-load crash fixed in patch 0022, the object placement fixed in 0023, and led directly to diagnosing 0024). None of patches 0017-0021, 0023, 0024 have been confirmed working end-to-end in a real game session yet.

### Next steps

1. User to re-test with patch 0024 (physical objects should now actually respond to clicks) — confirm stash/crafting-anchor/Horadric-Cube menu all open correctly, and that the D2 tooltip, Salvage, and Cain's options all work as designed.
2. Once confirmed, revert the 65,535 starting-gold testing override.
3. Decide whether to extend the crafting engine to cover more of the spec's named recipes (Enchant Normal Item, Preserve Affix, Awaken Unique, etc.) — each needs new mutation logic, not just menu wiring.
4. Boss loot-table change for Unique/Set salvage materials — separate, self-contained follow-up.
5. Decide on the "Required Level" tooltip field — needs a save-format/content decision before implementation.
6. This rework's 8 patches (0017-0024) are still undocumented in this file's "Overall state" phase list above, since it's orthogonal to the Phase 0-5 roadmap — consider whether it should be folded into a numbered phase or tracked as its own permanent line item once it stabilizes.

## Runtime acceptance still required

Engineering progress is not a claim that the full runtime has been manually accepted.

Phase 1 still requires its real Windows baseline acceptance pass with legally obtained Diablo data.

Phase 3 additionally requires the checklist in `docs/PHASE3_RUNTIME_ACCEPTANCE.md`: visual vendor, Loot Filter 2.0, item comparison, resistance UI, weapon swap and persistence, controller flow, stash/gold QoL, two-client weapon synchronization and original-campaign regression. The evidence collector writes `out/runtime-acceptance/evidence/phase3-*.json`; runtime acceptance requires `passed: true`.

The development version therefore remains `0.1.0-dev`. Promotion to the first Classic+ alpha is blocked until the real runtime gate passes.

## Current priority order

1. keep Phase 1/Phase 3 real-PC acceptance as a deferred release gate;
2. get real Windows/controller hands on a Necromancer save and play it through the original campaign (Tristram -> Diablo) to close Phase 4's runtime exit criterion;
3. ~~extend the Rare engine from the current single-item-type prototypes (Sword/Staff/Shield/LightArmor) to the full base-item catalogue~~ — **done**: `BuildRttRareCodes`/`IsRttAffixCompatible` were already type-agnostic; `RttPhase4.RareRoundTripAcrossAllEquipmentTypes` now proves the round-trip for Axe/Bow/Mace/Helm/MediumArmor/HeavyArmor/Ring/Amulet too, and `RttPhase4.JewelryNeverGetsArmorClassAffix` documents the intentional exclusion of the armor-class affix family on Ring/Amulet;
4. ~~add a player-facing way to call `RttChooseProgression()`~~ — **done**: F4 hotkey ([PR #29](https://github.com/wlff88/Return-to-Tristram/pull/29)) spends the next available progression point, plus a D2-style waypoint fast-travel panel ([PR #31](https://github.com/wlff88/Return-to-Tristram/pull/31), M key in town);
5. begin Phase 5 (Resurrected campaign) planning once the above close out Phase 4 — note this touches gameplay direction/lore/scope and should be scoped with the user rather than decided unilaterally;
6. ~~Windows CI build time~~ — **done**: the MSVC job now builds with Ninja + ccache (GitHub Actions cache backend), matching upstream DevilutionX's own Windows CI ([PR #32](https://github.com/wlff88/Return-to-Tristram/pull/32)); confirmed with a cache-hit run at 388/388 compiles served from cache, cutting the build from ~18-20 min to ~6 min. A plain developer workstation is unaffected (still builds with the Visual Studio generator by default).
7. not yet done: vcpkg's own dependencies (SDL2, gtest, libsodium, lua, etc.) still rebuild from source on every Windows run — the "Cache pinned vcpkg" step only caches the vcpkg tool checkout, not the `vcpkg_installed/` package tree, so this is likely a bigger remaining chunk of the build time than the DevilutionX/RTT compile step ccache now covers. vcpkg's own binary-caching feature (e.g. via `lukka/run-vcpkg`'s built-in GitHub Actions cache integration) would address this; not yet attempted.

See `docs/PHASE2_MOD_FRAMEWORK.md`, `docs/PHASE3_CLASSIC_PLUS.md`, `docs/PHASE3_RUNTIME_ACCEPTANCE.md`, `docs/PHASE3_WEAPON_SWAP.md`, `docs/PHASE4_ITEMISATION_SKILLS_CLASSES.md`, `docs/MULTIPLAYER_COMPATIBILITY.md` and `docs/ROADMAP.md`.
