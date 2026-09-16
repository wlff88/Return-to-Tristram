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

## Patch 0016 — Physical stash chest and crafting anchor in Tristram

Purpose: place a clickable stash chest (reused `OBJ_CHEST1`, opens the same `RttOpenStash()` used by the Barmaid's "check the stash" dialogue) and a decorative crafting-station anchor prop (reused `OBJ_WEAPONRACK`) in Tristram, both via `RttEnsureTownServiceObjects()`.

Properties:

- no new save state — the stash's own contents already persist independently of how it's opened; the crafting anchor is purely decorative at this stage;
- placement is idempotent the same way as patch 0014's waypoints (scans `ActiveObjects[]`/`Objects[]` for an already-tagged instance rather than re-checking position, since Tristram's `ViewPosition` anchor varies by entry direction);
- tagged via `_oVar3` (confirmed free on both `OBJ_CHEST1` and `OBJ_WEAPONRACK` by reading `AddChest()`/`AddWeaponRack()`) to distinguish RTT-placed instances from any vanilla object sharing the same `_object_id`;
- covered by `RttPhase4.EnsureTownServiceObjectsNoOpOffTown`; the actual in-world placement/click is not exercised headlessly (needs real rendering).

## Patch 0017 — D2-style dual item tooltip

Purpose: replace patch 0004's single-box delta-comparison tooltip with two fully independent, side-by-side floating boxes — the hovered item's own complete stat box, and (when the hovered item occupies an equipment slot) a second box showing the currently-equipped item's own complete stat box. The two are never merged into one box or one string.

Properties:

- presentation-only; no new save state, no gameplay/RNG effect;
- adds a global `RttComparisonInfoString` beside the existing `InfoString`/`FloatingInfoString`, and a minimal redirect hook in `AddInfoBoxString` (`RttSetInfoBoxRedirect`) so the existing `PrintItemDetails`/`PrintItemInfo` pipeline can be re-run against the equipped item to populate the new buffer, instead of duplicating that pipeline;
- reuses patch 0004's `GetRttComparisonItem()` slot-resolution logic (helm/shield/ring/amulet/weapon/armor → matching `InvBody` slot) to find the comparison target, but drops its delta-line-appending behavior entirely;
- snapshots and restores `ShowUniqueItemInfoBox`/`curruitem` around the equipped-item pass, since `PrintItemDetails()` can set that shared unique-item-popup state and it must continue to reflect the actually-hovered item, not the comparison target;
- wired into every existing hover call site (inventory, stash, visual store) plus a new one (ground items, via `GetItemStr`), which previously showed only a name with no stat box at all;
- comparison box position is computed as an offset from the already-positioned primary box (to its right, flipped left if it would clip off-screen) rather than duplicating the primary box's whole per-context anchor switch;
- not exercised by the headless test suite (needs real rendering); verified by manual source review of every call site plus a full clean re-application of all 17 patches from the pinned commit.
- known gap, not addressed by this patch: no "Required Level" line exists anywhere in the tooltip, because no such field exists on `Item` in either vanilla or RTT code today — introducing one is a content/save-format decision, not a rendering one, and is left for a follow-up.

## Patch 0018 — Debug: seed stash test data

Purpose: add a `_DEBUG`-only Lua dev console command, `dev.seedStashTestData()`, that drops 5000 gold and three reused generic items (Full Healing/Mana Potion, Scroll of Town Portal) into the stash at fixed grid cells, so the physical stash chest added by patch 0016 has visible content to manually test instead of an empty stash.

Properties:

- test-only tooling, compiled only in `_DEBUG` builds (same gate as every other file under `lua/modules/dev/`); no effect on Release builds or shipped gameplay;
- the three seeded items are existing vanilla item types reused as stand-ins — they are explicitly NOT the real Iron Scrap/Arcane Dust/Blood Shard crafting materials from the planned Sell/Salvage rework (those don't exist as engine items yet and require their own `_item_indexes`/`AllItemsList` entries, per patch policy rule 3);
- writes directly into `Stash.stashList`/`Stash.GetCurrentGrid()`/`Stash.gold`, mirroring the insertion pattern `qol/stash.cpp`'s own `CheckStashPaste` already uses;
- not covered by the headless test suite (debug console command, needs a running game); to be deleted once real crafting materials exist and this ad hoc seed is no longer needed for testing.

## Patch 0019 — Sell/Salvage split: crafting materials

Purpose: implement the Sell vs Salvage split from the Item UX/Salvage/Crafting design. Sell already existed (any vendor buys items for gold, unchanged). Salvage is new: a "Salvage Item" option at Griswold destroys an equipped-type item and grants materials tiered by rarity (Normal -> Iron Scrap; Magic -> Iron Scrap + Arcane Dust; Rare -> Arcane Dust + Blood Shard; Unique/Set -> Radiant Shard).

Properties:

- **item generation and content-id-like additions** — requires explicit compatibility tests and documentation per rule 6, even though nothing here touches RNG or network state;
- adds 4 new `_item_indexes` enum values (`IDI_RTT_IRONSCRAP/ARCANEDUST/BLOODSHARD/RARESHARD`) appended immediately before `IDI_NUM_DEFAULT_ITEMS`, and matching rows in `assets/txtdata/items/itemdat.tsv` (a real upstream data file inside the pinned submodule, hence still a patch, not a free-standing RTT data file) - appending at the end leaves every existing item index's value untouched, so existing saves are unaffected;
- all 4 materials reuse existing vanilla cursor graphics (`MAGIC_ROCK`, `SPECTRAL_ELIXIR`, `BLOOD_STONE`, `AURIC_AMULET` - the same quest-item icons Diablo 1 already ships) instead of adding new art; `dropRate: 0` so they never appear in normal random loot, only via Salvage;
- reuses the existing `CURSOR_OIL` click-routing in `diablo.cpp` (the same generic "cursor mode + click an inventory/stash item" dispatch block already used by Identify/Repair/Recharge/Oil) instead of building a second full side-panel like the Stash - a new `RttSalvageModeActive` bool disambiguates "salvage" clicks from real Hellfire oil application, since both share the one cursor id; a small self-healing check in `CheckPanelInfo()` (`control_infobox.cpp`, already touched by patch 0017) clears the flag if the cursor was cancelled through any of the several existing paths that reset `pcurs` without going through the new click handler, so no other cancel path needed patching;
- `RegisterTownerDialogOption("griswold", ...)` (previously unused native infrastructure, confirmed dead code before this patch) adds the "Salvage Item" line; re-registered on every `StartStore()` call (idempotent, guarded by a bool cleared inside `ClearTownerDialogOptions()`) so it survives a Lua state reload;
- salvage materials are granted via `AutoPlaceItemInInventory(player, material, true)` - the same local-inventory-mutation-plus-`sendNetworkMessage=true` pattern already used by store purchases (`StoreAutoPlace`); gated to `&player == MyPlayer`, consistent with the existing crafting-mutation functions' "owning peer commits inventory mutations" convention;
- fixed (non-random) material quantities per tier - a deliberate placeholder pending balance, same spirit as the Horadric Knowledge gold costs; if inventory is full mid-grant, the item is still consumed and a red warning message is shown rather than silently losing materials or duplicating the source item;
- not covered by the headless test suite (needs a running game to click through the store dialog and cursor mode); verified by manual source review and a full clean re-application of all 19 patches from the pinned commit.
- known gap, not addressed by this patch: "Unique/Set materials should also drop from bosses" (so destroying a Unique/Set item is never required for progression) is a boss loot-table change, left for a follow-up.

## Patch 0020 — Cain: Identify All + Horadric Knowledge progression

Purpose: reassign Cain toward Identify / Identify All / Crafting Knowledge only (no blacksmith association, unchanged from vanilla otherwise). Adds two new dialog options: "Identify All Items" (batched identify) and Horadric Knowledge tier purchase (the gold-sink crafting-progression system gating which recipes the eventual Horadric Cube will allow).

Properties:

- **save serialization** — requires explicit compatibility tests and documentation per rule 6, since it adds new persisted player state;
- `RttIdentifyAllItems()` mirrors `StorytellerIdentifyItem()`'s existing single-item logic exactly, just batched over `InvBody` + `InvList`: sums each unidentified item's own `_iIvalue` identify cost, checks `PlayerCanAfford` once for the total, then identifies everything and takes the money - no partial-identify-then-run-out-of-gold state is possible;
- Horadric Knowledge is 5 tiers with placeholder gold costs (5,000/20,000/60,000/150,000/400,000 - explicitly to be balanced later, matching the user's own spec), purchasable only in order (`RttHoradricKnowledgeTier + 1`); tier V additionally requires character level 30 (also a placeholder) since the spec's quest-completion gate is deferred until an actual quest system exists;
- adds `Player::RttHoradricKnowledgeTier` (a plain `uint8_t` field, same style as `RttActiveWeaponSet`) and a new **separate, versioned RTT save archive entry** (`rtt_crafting_state`, version byte + tier byte) per patch policy rule 8, rather than touching `PlayerPack` or the reserved-zero bytes in `rtt_progression.h`'s `Progression` array (which are specifically scoped/documented as Necromancer-progression bytes) - loaded/saved at the same 3 call sites (`pfile_create_hero`, `pfile_write_hero`, `pfile_read_player_from_save`) as the existing `rtt_weapon_set` entry, guarded the same way (`GetActiveModSaveExtension() == "rtt"`, `!gbVanilla`);
- both new options use `RegisterTownerDialogOption("cain", ...)` - the same previously-unused hook patch 0019 gave its first caller for Griswold, now proven for a second towner;
- not covered by the headless test suite (needs a running game to open Cain's dialog); verified by manual source review and a full clean re-application of all 20 patches from the pinned commit.
- known gap, not addressed by this patch: the Horadric Cube itself, and any recipe actually gated by the purchased tier - `RttHoradricKnowledgeTier` is persisted and purchasable now, but nothing reads it yet. That's the next (and last) phase of the Item UX/Salvage/Crafting rework.

## Patch 0021 — Horadric Cube: physical object + recipe menu

Purpose: place a physical Horadric Cube near Cain (reusing `RttEnsureTownServiceObjects`'s idempotent placement pattern) and let the player actually craft with it: a new store-dialog page lists the recipes Horadric Knowledge II/III unlock, locked ones shown as "Unknown Recipe" per the Item UX/Salvage/Crafting spec's own transparency request.

Properties:

- reuses `OBJ_STORYBOOK` purely for its stationary "book on a stand" appearance; `IsRttHoradricCube()` bypasses both `OperateStoryBook()` (so clicking it never reveals vanilla story text) and `Object::name()`'s `StoryBookName[_oVar3]` lookup (so hovering it shows "Horadric Cube", not a random vanilla book title) - the second override was a real gap the crafting anchor/stash chest didn't need, since `AddStoryBook()` writes seed-derived data into `_oVar3` that the tag write silently overwrites;
- adds `RttIsRareTierItem()` (items.cpp/h) as a small public wrapper around the existing (internal-linkage) `GetRttItemRarity()`, since the Cube's eligibility check lives in `objects.cpp`, a different translation unit;
- clicking the Cube while empty-handed, holding a non-Rare item, or below Horadric Knowledge tier II reports why nothing happens (no dialog opens) - only a Rare item with tier II+ opens the new `TalkID::RttHoradricCube` page;
- the recipe page is a new top-level `TalkID` store-dialog entry, opened directly from the object click rather than through any towner-talk flow - it reuses 100% of the store system's already-wired rendering/input plumbing (`AddSText`/`ClearSText`/`StartStore`/`StoreEnter`/`StoreESC`) instead of building a second parallel panel system like the Stash/Waypoint panels (~8-10 files each); the only new wiring is one `case` added to each of `StartStore`'s, `StoreEnter`'s, and `StoreESC`'s exhaustive `switch (ActiveStore)` statements (required for the build to compile with `-Wswitch` as an error - confirmed at `HAVE_CXX_FLAG_PEDANTIC_ERRORS` in CI - since none of the three has a `default:` case);
- only 3 of the ~15 named recipes in the spec have a real backing implementation (`RttReforgeHeldRare`/`RttRerollHeldAffixSlot`/`RttRaiseHeldAffixTier`, patch 0010, Rare-tier only); costs (100/50/150 Gold) are read from that existing engine rather than re-specified here. The other ~10 (Enchant Normal Item, Preserve Affix, Awaken Unique, etc.) have no engine support yet and are out of scope for this patch;
- not covered by the headless test suite (needs a running game); verified by manual source review and a full clean re-application of all 21 patches from the pinned commit.
- known gap, intentional: recipes below Horadric Knowledge II (the spec's Level I: Enchant Normal Item/Reforge Magic Item/Reroll Affix Value) have no engine support, so the Cube has nothing to offer a Normal/Magic-tier item - only Rare items are actionable at all right now.
