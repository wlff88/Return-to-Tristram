# Return to Tristram — Project Status

Last status update: 2026-09-15

## Overall state

- **Phase 0 — Foundation reset:** COMPLETE
- **Phase 1 — DevilutionX baseline:** engine/build and acceptance harness complete; real Windows runtime acceptance pending
- **Phase 2 — Mod framework:** COMPLETE
- **Phase 3 — Classic+:** ENGINEERING COMPLETE / MANUAL RUNTIME ACCEPTANCE PENDING
- **Phase 4 — Itemisation, skills and classes:** next engineering phase
- **Later phases:** planned, not yet feature-complete

## Pinned engine baseline

- Repository: `diasurgical/DevilutionX`
- Pinned revision: `ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`
- Integration: `Engine/devilutionx` git submodule
- RTT save extension: `.rtt`
- RTT program ID: `RTRM`
- Development version: `0.1.0-dev`

## Phase 2 framework

RTT has a formal mod platform rather than isolated feature wiring: deterministic ten-module runtime lifecycle; exact DevilutionX loose-mod discovery; table-map schema v2 covering items, affixes, uniques, monsters, spells and every shipped class table; append-only stable semantic content IDs; Save Schema v1 and sequential migration API; Multiplayer Compatibility Policy v1; generated runtime compatibility fingerprints; passive/self-test demonstrators for all gameplay modules; and CI enforcement of the complete contract.

The exporter still rejects new upstream rows. That remains intentional until generated-content systems implement stable-ID/save/network semantics.

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
- controller-first source/interaction review completed;
- generated rare/affix/unique additions deliberately deferred to Phase 4 to preserve seeded-item/save compatibility;
- dedicated Phase 3 runtime checklist and JSON evidence collector added.

## Runtime acceptance still required

Engineering completion is not a claim that the full runtime has been manually accepted.

Phase 1 still requires its real Windows baseline acceptance pass with legally obtained Diablo data.

Phase 3 additionally requires the checklist in `docs/PHASE3_RUNTIME_ACCEPTANCE.md`: visual vendor, Loot Filter 2.0, item comparison, resistance UI, weapon swap and persistence, controller flow, stash/gold QoL, two-client weapon synchronization and original-campaign regression. The evidence collector writes `out/runtime-acceptance/evidence/phase3-*.json`; runtime acceptance requires `passed: true`.

The development version therefore remains `0.1.0-dev`. Promotion to the first Classic+ alpha is blocked until the real runtime gate passes.

## Current priority order

1. keep Phase 1/Phase 3 real-PC acceptance as a deferred release gate;
2. begin Phase 4 stable itemisation vertical slice using completed stable-ID/save/network contracts;
3. implement rare-item generation and tiered affixes without item morphing after save/load;
4. add the RTT unique/set framework and crafting foundation;
5. implement the active/passive skill framework and first new class vertical slice.

See `docs/PHASE2_MOD_FRAMEWORK.md`, `docs/PHASE3_CLASSIC_PLUS.md`, `docs/PHASE3_RUNTIME_ACCEPTANCE.md`, `docs/PHASE3_WEAPON_SWAP.md`, `docs/MULTIPLAYER_COMPATIBILITY.md` and `docs/ROADMAP.md`.
