# RTT engine patch policy

DevilutionX remains pinned as an upstream git submodule. Return to Tristram engine changes are stored as small ordered patch files under `Engine/patches/` rather than silently editing or vendoring the upstream source tree.

## Rules

1. Every patch must be narrowly scoped and independently reviewable.
2. Prefer TSV/Lua/runtime mod APIs over C++ patches.
3. A C++ patch is allowed only when the current mod API cannot expose the required extension point cleanly.
4. `scripts/apply-engine-patches.py --check` must pass against the pinned upstream SHA.
5. Build scripts apply patches idempotently before compilation.
6. Patches affecting RNG, network state, save serialization, item generation, or simulation require explicit compatibility tests and documentation.
7. Presentation-only hooks should not mutate deterministic game state.
8. Save-format extensions should prefer separate, versioned RTT archive entries over changing upstream packed structures when practical.

## Patch 0001 — Lua item-label visibility hook

Purpose: expose a single `ShouldShowItemLabel(Item*) -> bool` event to Lua and call it from `AddItemToLabelQueue()`.

Properties:

- presentation-only;
- does not alter item generation, world state, RNG, save data or pickup behaviour;
- default return is `true` when no mod handles the event;
- RTT registers the event itself at runtime;
- allows loot-filter policy to live in Lua rather than in the engine.

## Patch 0002 — immediate monster resistance display

Purpose: show the exact Magic/Fire/Lightning resistance and immunity categories for the hovered monster without the vanilla kill-count knowledge gate.

Properties:

- presentation-only;
- reads existing monster resistance flags;
- does not alter monster stats, combat, RNG, saves or network simulation;
- keeps the unrelated vanilla HP-knowledge gate unchanged.

## Patch 0003 — Classic+ default profile

Purpose: make the selected native DevilutionX QoL options the default RTT Classic+ experience, including Visual Grid vendors and the reviewed convenience options.

Properties:

- changes option defaults only;
- every option remains user-configurable;
- does not change item generation, quest state or deterministic simulation;
- reuses upstream implementations rather than duplicating store/stash/controller systems.

## Patch 0004 — equipped-item comparison tooltip

Purpose: append RTT comparison deltas to identified equipment tooltips.

Properties:

- presentation-only;
- reads the inspected and currently equipped `Item` objects;
- compares damage/armor, core attribute bonuses and elemental/magic resistances;
- does not mutate equipment, RNG, save state or network state.

## Patch 0005 — alternate weapon set / weapon swap

Purpose: provide a Diablo-II-style second main/off-hand set while preserving upstream `PlayerPack` compatibility.

Properties:

- the active pair remains `InvBody[INVLOC_HAND_LEFT/RIGHT]`;
- the inactive pair is stored in RTT runtime `Player` state and does not contribute stats while inactive;
- swapping recalculates derived inventory stats and reuses existing `NetSendCmdChItem` equipment synchronization for the active pair;
- keyboard and controller actions use the native remappable input system;
- alternate-set persistence uses the separate versioned `rtt_weapon_set` archive entry;
- `PlayerPack` is not resized or extended;
- old `.rtt` saves without `rtt_weapon_set` fall back to an empty alternate set;
- generated RTT affix/rare/unique systems remain deferred to Phase 4 and its save-migration policy.

See `docs/PHASE3_WEAPON_SWAP.md` for the compatibility model and `docs/PHASE3_RUNTIME_ACCEPTANCE.md` for the deferred real-PC checks.
