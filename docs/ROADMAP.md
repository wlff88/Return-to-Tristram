# Roadmap

This roadmap reflects the current single-engine Return to Tristram architecture. DevilutionX is the engine foundation; RTT gameplay/content is layered through data, Lua and small audited engine hooks.

## Phase 0 — Foundation reset — COMPLETE

- [x] Preserve previous prototype on `backup-before-ultimate-reset-2026-09-14`
- [x] Replace project layout with modular DevilutionX-based skeleton
- [x] Establish one-engine architecture and retire the dual-runtime direction
- [x] Add third-party source/licence policy
- [x] Audit Tchernobog, Belzebub, The Hell 4 and Infernity source/provenance status
- [x] Add bootstrap data schemas
- [x] Add project status and versioning policy
- [x] Align README and roadmap with actual `main` state

**Exit criterion:** repository structure, source policy, project direction and status documentation are internally consistent.

## Phase 1 — DevilutionX baseline — ENGINE/HARNESS COMPLETE / REAL RUNTIME ACCEPTANCE PENDING

- [x] Select exact upstream revision
- [x] Record upstream licence and commit
- [x] Integrate engine source as an auditable git submodule
- [x] Add baseline SHA verification
- [x] Add Windows bootstrap/build wrapper
- [x] Add minimal runtime mod manifest
- [x] Add baseline/data validation CI
- [x] Add Windows MSVC compile CI
- [x] Verify CI produces `devilutionx.exe`
- [x] Add repeatable Windows runtime-acceptance harness
- [x] Add isolated config/save directories and machine-readable acceptance evidence
- [x] Add CI wiring validation for the acceptance harness
- [ ] Confirm Windows x64 build on developer workstation
- [ ] Verify vanilla campaign launch with legally supplied game data
- [ ] Verify RTT entry in mod loader
- [ ] Verify RTT save/load
- [ ] Verify controller flow from menu through combat/inventory
- [ ] Verify two-client multiplayer baseline

**Exit criterion:** one real Windows runtime acceptance run records `passed: true` after launch -> Tristram -> Cathedral -> combat -> save -> reload, controller flow and a basic multiplayer connection test.

## Phase 2 — Mod framework — COMPLETE

- [x] Initial feature flag/config file
- [x] Runtime package skeleton
- [x] Generic sparse-override to DevilutionX TSV exporter
- [x] First no-op end-to-end table export (`Experience.tsv`)
- [x] First real gameplay TSV override (starter gold)
- [x] Ordered/idempotent engine patch application
- [x] CI validation that all RTT engine patches apply to the pinned baseline
- [x] First presentation-only Lua engine extension hook
- [x] Lua-driven loot-filter demonstrator
- [x] Monster resistance/immunity display demonstrator
- [x] Expand table map to items, affixes, uniques, monsters, spells and all class tables
- [x] Define stable RTT content-ID registry
- [x] Define RTT save-version/migration layer before generated item systems expand
- [x] Formal module lifecycle/hook interfaces
- [x] One demonstrator feature per gameplay module
- [x] Multiplayer compatibility policy for Lua/TSV/MPQ/runtime extensions
- [x] Generate a runtime compatibility contract with registry/schema/policy fingerprints
- [x] CI validation of the complete Phase 2 framework contract

**Exit criterion:** RTT can add/override content in every planned gameplay family without ad-hoc engine edits, with stable IDs and an explicit save/network policy. **Satisfied.**

## Phase 3 — Classic+ — ENGINEERING COMPLETE / MANUAL RUNTIME ACCEPTANCE PENDING

- [x] Establish canonical Classic+ defaults/profile
- [x] Loot filter v1
- [x] Exact monster resistance/immunity display
- [x] Use upstream stash instead of duplicating it
- [x] Use upstream 12 spell hotkeys instead of duplicating them
- [x] Enable upstream visual-grid vendor inventory as the Classic+ baseline
- [x] Define RTT visual-store art direction: Diablo I-native presentation, no unlicensed/proprietary asset imports
- [ ] Confirm visual-store presentation and controller interaction on a real Windows runtime
- [x] Alternate weapon set / weapon swap with versioned RTT persistence
- [x] Advanced RTT item comparison tooltip
- [x] Loot filter 2.0 with user-configurable rules/presets
- [x] Controller-first source/interaction review
- [x] Quick inventory/stash transfer review — reuse native Ctrl-click transfer
- [x] Gold handling QoL review — auto-gold enabled; preserve 5000 stack cap for compatibility
- [x] Balance-safe item-content review — preserve seeded generation identity in Classic+ and defer generated item systems to Phase 4
- [x] Add dedicated Phase 3 runtime acceptance checklist and JSON evidence collector
- [ ] Full Classic+ Windows/controller/multiplayer/campaign runtime regression pass

**Engineering exit criterion:** all Classic+ data, Lua and engine patches validate; the pinned Windows MSVC build and test-package workflow are green. **Satisfied once the final Phase 3 merge tree passes CI.**

**Runtime exit criterion:** one real Windows run confirms `docs/PHASE3_RUNTIME_ACCEPTANCE.md` and records `phase3-*.json` with `passed: true`. Until then Phase 3 remains manual-runtime-acceptance pending and version stays `0.1.0-dev`.

## Phase 4 — Itemisation, skills and classes — ENGINEERING ACTIVE / NECROMANCER RUNTIME ACCEPTANCE PENDING

### Foundation

- [x] Expand stable content-ID registry with `set` and `skill` namespaces
- [x] Populate first stable item archetypes, tiered affixes, uniques, set, recipes, skills and class IDs
- [x] Define compact RTT item metadata v1 in `Item.dwBuff` without overlapping DevilutionX bits 0–4
- [x] Reserve four append-only compact affix slots for future 2-prefix/2-suffix Rares
- [x] Add Save Schema v2 with sequential v1 -> v2 migration
- [x] Add itemization/progression state contracts
- [x] Activate Phase 4 catalogs in itemization/crafting/skills/classes Lua modules
- [x] Define first Necromancer logical class vertical slice and five-skill progression catalog
- [x] Add cross-reference/bit-layout/save-migration CI validation

### Gameplay engines

- [x] Rare item generation for fresh eligible drops only (`SetupAllItems`/`RecreateItem` only stamp RTT metadata on fresh generation; loaded/recreated no-marker items are never touched)
- [x] Exact Rare reconstruction from persisted compact metadata (deterministic `_iSeed + compactCode + slot` rebuild; covered by the `generate -> pack -> unpack/recreate -> compare` contract test)
- [x] Tiered affix application and Rare naming/UI (stable names derived from base identity + seed, not from mutable `dwBuff`; item comparison tooltip already displays RTT Rare stats since Phase 3)
- [x] RTT unique-item engine bridge (Ashen Covenant, Boneward, Gravewhisper prototypes round-trip correctly)
- [x] Set-item engine bridge and set-bonus evaluation (Ossuary Regalia equip-count -> `rttBoneArmorRank` bonus verified on equip/unequip via `CalcPlrItemVals`)
- [x] Crafting mutation engine using deterministic item reconstruction (`RttPrepareCraft`/`RttCraftHeldRare` preserve base/level/seed and fail atomically on bad target/cost)
- [x] Active skill progression and upgrade selection (`RttChooseProgression` unlock/spend/gate logic for the four Necromancer upgrade slots)
- [x] Passive/notable/mastery progression baseline (armor-upgrade slot verified to reduce incoming damage via the mana-shield path)
- [x] Class activation/persistence layer (`EnsureRttNecromancerProgression` gates on `HeroClass::Sorcerer` + active "rtt" mod; state round-trips through `PackPlayer`/`UnPackPlayer`)
- [x] Save migration/item round-trip tests for generated items and progression (Save Schema v1 -> v2 migration; CI-enforced `rtt_phase4_test` contract, Windows + Linux)
- [x] Multiplayer reconstruction tests for RTT item metadata and class progression — item metadata reconstruction is tested host + a second client (`PackNetItem`/`UnPackNetItem` compared across two `Player` instances); progression-choice network **broadcast** is now exercised too (`RttPhase4.NetworkChoiceAppliesToSenderNotSelf`, [PR #25](https://github.com/wlff88/Return-to-Tristram/pull/25)): a `CMD_RTT_CHOICE` command fed through `ParseCmd()` as another player's send correctly lands on that player via `OnRttChoice()`, a command nominally from yourself is echo-suppressed, `RttChooseProgression()` still refuses to broadcast someone else's choice, and your own broadcast enqueues exactly one correctly-sized packet on the loopback provider
- [ ] Playable Necromancer vertical slice — **not yet manually verified**; the engineering contracts above are CI-green but no one has played a Necromancer through the original campaign on a real Windows build yet

**Engineering exit criterion:** the round-trip/crafting/progression/save-migration/network contracts above validate in CI on both platforms. **Satisfied as of PR #25.** (PR #23, the Phase 4 foundation merge, landed with `build` and `contracts` red and was fixed forward: `rtt_phase4_test` was calling `CreatePlayer()`, which needs the proprietary `objcurs.cel`; it unconditionally called networked `addExperience()` with no loopback provider bootstrapped; and the Windows job resolved unpacked test assets from the wrong per-config directory.)

**Runtime exit criterion (unchanged, not yet met):** at least one Necromancer build can progress through the original campaign using RTT Rare/Unique/Set itemisation, skills and class mechanics without item morphing after save/load or network reconstruction, confirmed on a real Windows run.

## Phase 5 — Resurrected campaign

- [ ] Expanded quest state machine
- [ ] Restored/reimagined quest content where legally appropriate
- [ ] Additional classes
- [ ] New/expanded monster families
- [ ] Elite/champion modifier framework
- [ ] New/expanded bosses with phase support
- [ ] Additional locations/dungeons
- [ ] Extended itemisation and crafting content
- [ ] Difficulty progression beyond vanilla balance assumptions

**Exit criterion:** a complete expanded campaign path from Tristram to a new RTT campaign endpoint is playable and save/network stable.

## Phase 6 — Abyss endgame

- [ ] Abyss key system
- [ ] Tier system
- [ ] Dungeon modifier system
- [ ] Procedural/repeatable endgame instance pipeline
- [ ] Corruption system
- [ ] Endgame boss pool
- [ ] Boss-fragment/key progression
- [ ] Risk/reward tuning
- [ ] Endgame-exclusive itemisation layer

**Exit criterion:** campaign completion feeds a repeatable T1+ endgame loop with deterministic generation, meaningful progression and stable saves/multiplayer.

## Phase 7 — Hardcore and multiplayer completion

- [ ] Hardcore ruleset/permadeath
- [ ] Shared multiplayer map decision/implementation
- [ ] Shared multiplayer XP decision/implementation
- [ ] Determinism tests for item RNG
- [ ] Determinism tests for monster/boss state
- [ ] Determinism tests for quests and Abyss generation
- [ ] Host/client crafting verification
- [ ] Host/client save/reconnect verification

**Exit criterion:** all supported modes have documented multiplayer semantics and deterministic regression coverage.

## Phase 8 — Hardening and release engineering

- [ ] Save migration strategy finalized across released versions
- [ ] Packaging without proprietary Blizzard assets
- [ ] Windows release artifact
- [ ] Linux release artifact
- [ ] macOS release artifact
- [ ] Automated release pipeline
- [ ] User installation/update documentation
- [ ] Mod/content author documentation
- [ ] Performance pass
- [ ] Crash/telemetry/logging review
- [ ] Feature freeze and regression campaign

**Exit criterion:** reproducible public release packages can be built from tagged source without distributing proprietary game data.

## Release milestones

- `0.1.x` — Classic+ development line
- `0.2.x` — itemisation core
- `0.3.x` — skills/classes vertical slice
- `0.4.x` — Resurrected campaign
- `0.5.x` — monster/boss content completion
- `0.6.x` — crafting/content depth
- `0.7.x` — Abyss endgame
- `0.8.x` — multiplayer/hardcore feature complete
- `0.9.x` — beta / feature freeze
- `1.0.0` — full Return to Tristram release
