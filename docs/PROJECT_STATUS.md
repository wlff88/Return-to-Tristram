# Return to Tristram — Project Status

Last status update: 2026-09-15

## Overall state

- **Phase 0 — Foundation reset:** COMPLETE
- **Phase 1 — DevilutionX baseline:** engine/build and acceptance harness complete; real Windows runtime acceptance pending
- **Phase 2 — Mod framework:** COMPLETE
- **Phase 3 — Classic+:** active
- **Later phases:** planned, not yet feature-complete

## Phase 2 framework now implemented

RTT now has a formal mod platform rather than isolated feature wiring: deterministic ten-module runtime lifecycle; exact DevilutionX loose-mod discovery; table-map schema v2 covering items, affixes, uniques, monsters, spells and every shipped class table; append-only stable semantic content IDs; Save Schema v1 and sequential migration API; Multiplayer Compatibility Policy v1; generated runtime compatibility fingerprints; passive/self-test demonstrators for all gameplay modules; and CI enforcement of the complete contract.

The exporter still rejects new upstream rows. That is intentional until each generated-content system implements its stable-ID/save/network semantics.

## Pinned engine baseline

- Repository: `diasurgical/DevilutionX`
- Pinned revision: `ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`
- Integration: `Engine/devilutionx` git submodule
- RTT save extension: `.rtt`
- RTT program ID: `RTRM`

## Implemented RTT-specific functionality

### Framework

- deterministic module lifecycle/hook dispatcher;
- feature/config contract;
- sparse TSV override pipeline with 39 validated table mappings;
- stable append-only content identity;
- Save Schema v1 migration API;
- multiplayer compatibility policy;
- generated compatibility fingerprint contract;
- ordered/idempotent engine patch manager.

### Gameplay/QoL demonstrators

- Warrior/Rogue/Sorcerer starter gold override: 200 gold;
- Lua-driven item-label loot filter;
- immediate exact monster resistance/immunity display.

## Runtime acceptance still required

The final Phase 1 pass must run on Windows with legally obtained Diablo data. A successful run writes `out/runtime-acceptance/evidence/phase1-*.json` with `passed: true`.

## Current priority order

1. finish real Phase 1 runtime acceptance with the correctly discovered RTT loose mod;
2. Diablo II-style visual vendor inventory in RTT/Diablo I art direction;
3. alternate weapon set / weapon swap;
4. advanced item tooltip;
5. loot filter 2.0;
6. controller-first Classic+ UX pass;
7. begin Phase 4 rare-item/affix vertical slice using the completed stable-ID/save/network contracts.

See `docs/PHASE2_MOD_FRAMEWORK.md`, `docs/MULTIPLAYER_COMPATIBILITY.md` and `docs/ROADMAP.md`.
