# Phase 3 — Classic+ runtime acceptance

This is the deferred real-PC gate for Phase 3. It is intentionally separate from engineering completion.

Use a Windows x64 RTT test package built from the current merged `main`, legally supplied Diablo data, a keyboard/mouse and an Xbox-class controller. Run `scripts/phase3-acceptance-evidence.ps1` after or alongside the test to record the result.

## Required checks

1. Launch RTT without missing-asset errors and confirm the RTT mod is active.
2. Open a vendor and confirm the visual-grid store is the default shop presentation and remains usable with mouse and controller.
3. Confirm Loot Filter 2.0 labels behave sensibly with the default `balanced` preset; magic/unique items, gold and consumables must not disappear.
4. Inspect identified equipment and confirm the RTT comparison block shows deltas against the relevant equipped item.
5. Hover monsters and confirm exact Magic/Fire/Lightning resistance/immunity categories are visible immediately.
6. Equip a one-hand weapon + shield, press `W`, verify the second set, then swap back.
7. Repeat weapon swap with a two-hand weapon.
8. Save with weapon set 2 active, quit, reload, and verify both weapon sets and the active-set state survive.
9. Repeat weapon swap with controller `Back/Select + Y`.
10. Verify Ctrl-click inventory/stash transfer, auto-gold pickup and belt refill behavior.
11. Exercise controller navigation through menu, movement, combat, inventory, stash and vendor UI.
12. In a two-client RTT multiplayer game, swap weapons and confirm the other client sees the active equipped pair without crash/desync.
13. Complete the original campaign regression path through Diablo, checking that Classic+ QoL does not block quests, transitions, combat, saving or loading.

## Pass rule

The Phase 3 runtime gate passes only when every required check is confirmed. The evidence collector writes `out/runtime-acceptance/evidence/phase3-YYYYMMDD-HHMMSS.json` and sets `passed: true` only when all answers are positive.

A failed or incomplete run does not invalidate engineering completion; it keeps Phase 3 in `MANUAL RUNTIME ACCEPTANCE PENDING` and blocks promotion from `0.1.0-dev` to the first Classic+ alpha.
