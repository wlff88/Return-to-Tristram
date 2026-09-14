# RTT engine patch policy

DevilutionX remains pinned as an upstream git submodule. Return to Tristram engine changes are stored as small ordered patch files under `Engine/patches/` rather than silently editing or vendoring the upstream source tree.

## Rules

1. Every patch must be narrowly scoped and independently reviewable.
2. Prefer TSV/Lua/runtime mod APIs over C++ patches.
3. A C++ patch is allowed only when the current mod API cannot expose the required extension point cleanly.
4. `scripts/apply-engine-patches.py --check` must pass against the pinned upstream SHA.
5. Build scripts apply patches idempotently before compilation.
6. Patches affecting RNG, network state, save serialization, item generation, or simulation require explicit compatibility tests.
7. Presentation-only hooks should not mutate deterministic game state.

## Patch 0001 — Lua item-label visibility hook

Purpose: expose a single `ShouldShowItemLabel(Item*) -> bool` event to Lua and call it from `AddItemToLabelQueue()`.

Properties:

- presentation-only;
- does not alter item generation, world state, RNG, save data or pickup behaviour;
- default return is `true` when no mod handles the event;
- RTT registers the event itself at runtime;
- allows loot-filter policy to live in Lua rather than in the engine.
