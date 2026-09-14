# Return to Tristram — Project Status

Last status reset: 2026-09-14

This document is the canonical short-form view of the current Return to Tristram engineering state. `docs/ROADMAP.md` defines the longer implementation path; this file answers what is true now.

## Overall state

- **Phase 0 — Foundation reset:** COMPLETE
- **Phase 1 — DevilutionX baseline:** engine/build foundation complete; runtime acceptance pending
- **Phase 2 — Mod framework:** active
- **Phase 3 — Classic+:** started through isolated QoL/gameplay features
- **Later phases:** planned, not yet feature-complete

## Architecture decision

Return to Tristram uses **one engine foundation: DevilutionX**.

Tchernobog, Belzebub, The Hell 4 and Infernity are feature/design/source references governed by `docs/MOD_SOURCE_MATRIX.md`. They are not maintained as parallel RTT runtimes and are not mechanically merged into one executable.

The former dual-runtime experiment in PR #3 is superseded and closed without merge.

## Pinned engine baseline

- Repository: `diasurgical/DevilutionX`
- Pinned revision: `ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`
- Integration: `Engine/devilutionx` git submodule
- Target infrastructure: DevilutionX 1.6-era TSV/Lua mod support
- RTT save extension: `.rtt`
- RTT program ID: `RTRM`

## Verified build/CI state

The repository currently verifies:

- exact pinned DevilutionX SHA;
- RTT authored data validation;
- sparse TSV generation into the runtime package;
- expected generated Experience table;
- Classic+ starter-gold overrides;
- RTT Lua runtime files;
- runtime manifest structure;
- ordered RTT engine patches apply cleanly to the pinned baseline;
- Windows MSVC build succeeds;
- the Windows build produces `devilutionx.exe`.

A green compile is not treated as a substitute for runtime acceptance with user-supplied Diablo data.

## Implemented RTT-specific functionality

### Data/runtime framework

- modular RTT repository layout;
- runtime DevilutionX mod package skeleton;
- feature flag/config foundation;
- sparse authored TSV override pipeline;
- generated runtime table export;
- ordered/idempotent engine patch manager;
- CI patch-compatibility gate.

### Gameplay/QoL demonstrators

- Warrior/Rogue/Sorcerer starter gold override: 200 gold;
- Lua-driven item-label loot filter hook;
- default loot filter hides labels for low-value normal equipment while preserving the item itself;
- immediate exact monster resistance/immunity display;
- unique monsters show exact Magic/Fire/Lightning categories rather than generic resistance text.

## Compatibility boundaries

Any change touching the following requires explicit compatibility review before merge:

- save serialization;
- deterministic RNG;
- network state;
- item IDs or generation ordering;
- monster IDs;
- quest-state IDs;
- dungeon generation;
- generated affix/unique pools.

New generated item systems must not be treated as release-ready until RTT save versioning and stable content IDs exist.

## Runtime acceptance still required

The next baseline acceptance pass must verify on a real installation with legally obtained Diablo data:

1. launch the pinned RTT build;
2. confirm RTT appears/loads as a mod;
3. create a new game and reach Tristram;
4. enter Cathedral Level 1;
5. kill at least one monster and confirm RTT UI/QoL hooks behave correctly;
6. save and exit;
7. reload the `.rtt` save successfully;
8. exercise controller navigation from menus through movement/combat/inventory;
9. connect two clients and verify the vanilla multiplayer baseline.

Until those tests pass, the project remains a development build rather than a public Classic+ alpha.

## Current priority order

1. runtime smoke acceptance;
2. RTT save-version/migration foundation;
3. stable RTT content-ID registry;
4. complete data-table mapping;
5. alternate weapon set / weapon swap;
6. advanced item tooltip and loot-filter 2.0;
7. rare item + tiered affix framework;
8. unique/crafting/skills/classes vertical slice;
9. expanded campaign framework;
10. Abyss endgame vertical slice.

## Definition of Phase 0 complete

Phase 0 is complete when all of the following are true:

- previous prototype is preserved;
- the current single-engine direction is documented;
- obsolete competing architecture is explicitly retired;
- module ownership is defined;
- source/licence policy exists;
- project README reflects reality;
- roadmap reflects reality;
- one canonical project-status document exists;
- versioning policy exists.

All Phase 0 criteria are satisfied as of this status update.
