# Phase 3 — Classic+

Phase 3 turns the original Diablo campaign into the RTT Classic+ baseline. The engineering scope is intentionally limited to quality-of-life, presentation and low-risk compatibility work; generated RTT itemisation belongs to Phase 4.

## Engineering-complete feature set

- canonical RTT Classic+ default profile;
- DevilutionX visual-grid vendor inventory enabled as the default shop mode;
- native floating item information plus RTT equipped-item comparison deltas;
- Loot Filter 2.0 with permissive/balanced/strict presets and safe user rules;
- exact monster resistance/immunity display without the vanilla kill-count knowledge gate;
- alternate weapon set / weapon swap with keyboard and controller bindings;
- versioned alternate-set persistence outside `PlayerPack`;
- native stash and 12 spell hotkeys reused rather than duplicated;
- native Ctrl-click inventory/stash transfer reused;
- auto-gold and belt refill enabled in the Classic+ profile;
- controller-first source review for inventory, vendor, combat and UI navigation;
- starter gold override for the three original Diablo classes.

## Visual-store art direction

RTT keeps the upstream DevilutionX visual store as the Classic+ shop foundation. It already presents vendor goods as item icons beside the player inventory and is navigable by mouse/controller. Phase 3 deliberately reuses the Diablo-native UI assets shipped by the legal game/DevilutionX asset layer instead of adding copied Blizzard art or an unrelated visual skin.

The Classic+ art-direction rule is therefore: Diablo I visual language, compact grid, item-first presentation, no proprietary art imported into the repository, and no vendor balance changes hidden inside UI work. A later RTT-specific skin may be added only from original/licensed assets.

Runtime visual acceptance on a real Windows machine remains a manual gate.

## Item-content boundary

Phase 3 does **not** append new generated affixes, rare systems or unique rows. That is intentional. Seeded Diablo item recreation and row/index identity can morph items if generation tables change without migration support. The completed Phase 2 stable-ID/save contracts are the foundation for Phase 4, where itemisation can be introduced deliberately.

This means the Phase 3 checklist item formerly described as "balance-safe item additions" is satisfied as an engineering review: Classic+ keeps existing item-generation identity stable and defers generated content additions to Phase 4.

## Completion definition

Phase 3 is **engineering complete** when all Classic+ source/data/patch validators and the Windows MSVC/package workflow are green on the merged tree.

Phase 3 is **runtime accepted** only after a real Windows run confirms the checklist in `docs/PHASE3_RUNTIME_ACCEPTANCE.md` and records a `phase3-*.json` result with `passed: true`.

Until that manual gate passes, the project remains on `0.1.0-dev`; it must not be promoted to the first Classic+ alpha solely on CI evidence.
