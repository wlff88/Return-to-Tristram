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

## Phase 4 — Itemisation, skills and classes

- [ ] Stable base item registry populated with released content
- [ ] Rare item generation
- [ ] Tiered affix system
- [ ] RTT unique-item framework
- [ ] Set-item framework
- [ ] Crafting foundation
- [ ] Active skill progression framework
- [ ] Passive/notable/mastery framework
- [ ] Class extension framework
- [ ] First new RTT class vertical slice
- [ ] Save migration tests for generated items and progression

**Exit criterion:** at least one complete new build archetype can progress through the campaign using RTT itemisation, skills and class mechanics without item morphing after save/load.

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
