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
9. Every patch must have a matching entry in `Engine/patches/MANIFEST.json` (`upstream_commit`, `purpose`, `save_safe`, `network_safe`, `rng_safe`), enforced by `scripts/apply-engine-patches.py --check-manifest`.

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

## Patch 0006 — Classic+/Normal XP multiplier

Purpose: increase earned XP by 50% on Normal difficulty for RTT-enabled games, to shorten the early Classic+ leveling pace.

Properties:

- gated on `GetActiveModSaveExtension() == "rtt"` and `DIFF_NORMAL` only; Nightmare/Hell are untouched;
- applies after the existing level-delta XP adjustment and before the existing multiplayer power-leveling cap, so the anti-power-level cap still applies to the RTT-scaled value;
- pure arithmetic on an already-computed XP value; does not touch RNG, item generation, saves or network packets beyond the XP number itself (which is already network-synced by vanilla);
- covered by `RttPhase4.NormalXpMultiplierOnly`.

## Patch 0007 — Phase 4 itemization/crafting foundation

Purpose: add the `generateRttMetadata` parameter to `SetupAllItems`/`RecreateItem` and the first Rare/Unique/Set generation and crafting-mutation hooks (`RttReforgeHeldRare`/`RttRaiseHeldAffixTier`/`RttRerollHeldAffixSlot`, later superseded by patch 0010's shared implementation).

Properties:

- **item generation** — requires explicit compatibility tests and documentation per rule 6;
- fresh-only: only newly generated equipment gets RTT metadata (`generateRttMetadata=true`); reconstruction (`RecreateItem` with `generateRttMetadata=false`) reapplies an existing marker's exact encoded metadata rather than rerolling it, so installing a newer RTT build never turns an old saved magic item into a different Rare;
- compact metadata lives in the otherwise-unused high bits of `Item.dwBuff` (bits 5-31), leaving DevilutionX's own bits 0-4 (`CF_HELLFIRE`, `CF_UIDOFFSET`) untouched;
- covered by `RttPhase4.LegacyNoMarker`, `RttPhase4.RareEveryCountAndTier`, `RttPhase4.FreshDropsNamedAndRareCounts`.

## Patch 0008 — Necromancer vertical slice (class identity)

Purpose: make `getClassName()` report "Necromancer" when `_pClass == HeroClass::Sorcerer` and the active mod's save extension is `"rtt"`.

Properties:

- presentation-only; does not change `_pClass`, stats, spell access or save data — Necromancer is a display/identity overlay on the existing Sorcerer class so RTT ships no new class-select slot or proprietary presentation assets;
- covered by `RttPhase4.NecromancerCreateUnlockSaveChoices`.

## Patch 0009 — Rare-serialization hardening

Purpose: mix the item's slot index into `RttRoll()`'s seed derivation (alongside `_iSeed` and the affix code) so two different affix slots on the same item never roll identical values from a coincidentally-matching code.

Properties:

- **RNG and item generation** — requires explicit compatibility tests and documentation per rule 6;
- deterministic: still derived only from `_iSeed`/code/slot, no engine RNG stream consumption, so host and client independently compute identical results;
- changes affix roll VALUES for newly generated items only; does not change the compact metadata encoding or break reconstruction of already-saved items (the compact code + slot are still sufficient to reproduce the exact same roll);
- covered by `RttPhase4.RareEveryCountAndTier`, `RttPhase4.FreshDropsNamedAndRareCounts`.

## Patch 0010 — Phase 4 completion (named identity, shared crafting engine)

Purpose: add `RttNamedIdentity()` (an append-only named/set/unique item identity code independent of TSV row indices) and the shared `RttPrepareCraft`/`RttCraftHeldRare` crafting-mutation engine backing all three crafting recipes.

Properties:

- **item generation, save serialization and simulation** — requires explicit compatibility tests and documentation per rule 6;
- `RttPrepareCraft` reconstructs the item from its stable base/seed/metadata before applying a new metadata word — it never incrementally stacks a mutation on top of already-applied derived stats — and fails atomically (no partial mutation) on an incompatible target, slot or insufficient level;
- `RttCraftHeldRare` only ever mutates `MyPlayer`'s own held item (`&player == MyPlayer` check) and syncs the gold cost over the network via existing `NetSyncInvItem`, adding no new packet types;
- the Reroll Affix Slot recipe's candidate selection is a deterministic `RttMix()` pick, not an engine RNG draw, keeping it host/client-identical without a network round-trip;
- covered by `RttPhase4.UniqueRoundTrip`, `RttPhase4.SetPieceRoundTripEquipUnequip`, `RttPhase4.CraftRecipesAndFailureAtomicity`, `RttPhase4.ArmorUpgradeReducesDamage`.

## Patch 0011 — Progression spend hotkey

Purpose: add `RttSpendNextProgressionPoint(Player&)`, a player-facing wrapper around the existing `RttChooseProgression()` that spends on the lowest-numbered unlocked/unspent/affordable slot, bound to F4.

Properties:

- pure UI convenience over an already-tested engine function; adds no new state and no new network command (reuses `RttChooseProgression`'s existing `CMD_RTT_CHOICE` broadcast path);
- owning-peer-only, matching `RttChooseProgression`'s own guard;
- covered by `RttPhase4.SpendNextProgressionPointHotkey`.

## Patch 0012 — Waypoint warp foundation

Purpose: add `RttWarpToLevel(Player&, uint8_t level)`, reusing the already-persisted, already-multiplayer-safe `_pLvlVisited[]` array instead of adding new save state.

Properties:

- no new save schema — reuses vanilla `_pLvlVisited[]`;
- calls the existing vanilla `StartNewLvl(..., WM_DIABTOWNWARP, ...)` level-transition path, the same one vanilla's own town-warp triggers use;
- gated on `&player == MyPlayer`, target level 1-16, and the target level being in `_pLvlVisited[]`;
- covered by `RttPhase4.WarpToLevelGating` (the success path itself is not exercised headlessly, since it drives real dungeon generation).

## Patch 0013 — D2-style waypoint fast-travel panel (UI)

Purpose: add a full graphical waypoint panel (`Source/panels/waypoint_panel.cpp/.hpp`), opened by the M hotkey in town, mirroring `panels/quest_log.cpp`'s architecture at every integration point (mutual exclusion with other panels, keyboard/mouse/controller input, render dispatch, cursor repositioning).

Properties:

- presentation-only UI; the actual warp is delegated entirely to patch 0012's already-tested `RttWarpToLevel()`;
- reuses the existing `pQLogCel` background art — no new art assets;
- not exercised by the headless test suite (needs real rendering); verified by manual review against `quest_log.cpp`'s exact behavior at each of ~10 integration points.

## Patch 0014 — Physical waypoint objects (town + every 2nd dungeon floor)

Purpose: place a clickable RTT waypoint object (a reused `OBJ_MCIRCLE1` magic circle, no new art) in Tristram and on dungeon levels 2/4/6/8/10/12/14/16, opening the same waypoint panel from patch 0013 on click; loosens `RttWarpToLevel()`'s previous town-only restriction since a click on a physical waypoint now establishes legitimate context on its own.

Properties:

- **RNG/simulation** — requires explicit compatibility tests and documentation per rule 6;
- placement is idempotent (scans for an already-tagged object rather than re-checking a position, since the entry anchor varies by which of a level's several entrances was used) and deliberately ignores live monster/player position so every multiplayer client derives the identical tile from the same seed-deterministic inputs (level geometry, other seed-placed objects) — the same guarantee vanilla's own `InitObjects()` already provides;
- tagged via `_oVar1` (a field `AddMagicCircle()` never touches) to avoid colliding with vanilla's own `Q_BETRAYER` Chamber of Bone circles, which share the same `_object_id`;
- town never placed objects or loaded object graphics before this patch; adds `ClrAllObjects()`/`InitObjectGFX()` calls to town's level-load path for exactly this feature;
- covered by `RttPhase4.WaypointLevelSelection`, `RttPhase4.EnsureWaypointObjectNoOpOffWaypointLevel`; the actual in-world placement/click is not exercised headlessly (needs real dungeon generation/rendering).

## Patch 0015 — Fix ActiveObjectCount test export

Purpose: mark `ActiveObjectCount` `DVL_API_FOR_TEST` so it is `dllexport`-ed from `libdevilutionx_so.dll` on the MSVC+`BUILD_TESTING` configuration, matching `Objects[]`'s existing annotation for the same reason.

Properties:

- presentation/build-only; a one-line header annotation, no runtime behavior change;
- fixes a Windows-only link failure surfaced by patch 0014's own new test reading the symbol directly for the first time (Linux was unaffected since the macro is a no-op there).
