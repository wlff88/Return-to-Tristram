# Phase 2 — RTT Mod Framework

Status: **COMPLETE**

Phase 2 turns Return to Tristram from a collection of isolated overrides into a deterministic, versioned mod platform on top of the pinned DevilutionX baseline.

## Runtime bootstrap

DevilutionX discovers the loose mod as `return-to-tristram`, so the required entry point is `lua/mods/return-to-tristram/init.lua`. That entry delegates to `mods.rtt.init`.

The RTT bootstrap loads runtime configuration, a generated compatibility contract, the generated stable content-ID registry, Save Schema v1, the deterministic module catalog and lifecycle framework.

## Module lifecycle

All Phase 2 gameplay families are registered in deterministic order: core, qol, quests, classes, skills, itemization, crafting, monsters, bosses and abyss.

A module declares `id`, `key`, `order`, dependencies, a demonstrator description and `probe()`. Optional lifecycle callbacks are dispatched from native DevilutionX Lua events.

Supported hooks are `on_mods_loaded`, `on_item_data_loaded`, `on_unique_item_data_loaded`, `on_monster_data_loaded`, `on_unique_monster_data_loaded`, `on_game_start`, `on_game_draw_complete`, `on_store_opened`, `on_monster_take_damage`, `on_player_take_damage` and `on_player_gain_experience`.

Framework modules are enabled so their passive demonstrators and lifecycle wiring are testable. Future gameplay features remain disabled under `[gameplay]` until their roadmap phase.

## Demonstrators

| Module | Phase 2 demonstrator |
| --- | --- |
| core | deterministic lifecycle bootstrap + self-test |
| qol | real Lua item-label loot filter |
| quests | GameStart observation |
| classes | class framework GameStart observation |
| skills | experience-event observation |
| itemization | item/unique-item data-load observation |
| crafting | store-open observation |
| monsters | monster data-load observation |
| bosses | unique-monster data-load observation |
| abyss | deterministic GameStart observation |

Except for the already-approved QoL hook, demonstrators are passive and do not modify gameplay state.

## Data/table mapping

`config/table-map.json` schema v2 maps the pinned DevilutionX TSV surface for Experience, base items, item prefixes, item suffixes, unique items, monsters, unique monsters, spells, the class catalog, and animations/attributes/sounds/sprites/starting loadouts for Warrior, Rogue, Sorcerer, Monk, Bard and Barbarian.

Optional mappings are validated even when RTT has no authored patch yet. Adding an override is therefore a data change, not a new engine-edit workflow.

The exporter still rejects new TSV rows. New generated rows remain blocked until stable-ID/save/network rules for that content family are implemented.

## Stable content IDs

`config/content-ids.json` is the append-only source of truth for RTT semantic IDs. IDs use namespaces such as `RTT_ITEM_0001`, `RTT_AFFIX_0001`, `RTT_MONSTER_0001`, `RTT_QUEST_0001` and `RTT_ABYSSMOD_0001` and are never derived from TSV row order.

Released IDs may not be reused. Phase 2 sentinel IDs are reserved and are not emitted as gameplay content.

## Save schema and migrations

`config/save-schema.json` defines RTT Save Schema v1. Runtime API `mods.rtt.core.save` provides `CURRENT_VERSION`, `newState()`, sequential `registerMigration(from, to, fn)` and `migrate(document)`.

Phase 2 defines the versioning/migration contract; it does not yet patch DevilutionX serialization to persist future RTT-only item structures. Any feature that needs new serialized state must add a migration before becoming release-capable.

## Multiplayer contract

See `docs/MULTIPLAYER_COMPATIBILITY.md`. Equal RTT version, pinned engine baseline, stable content registry and save schema are required for stateful/gameplay-symmetric features. Presentation-only hooks may be client-local only when they cannot alter gameplay state.

## Generated runtime contract

Staging generates `lua/mods/rtt/generated/content_ids.lua` and `lua/mods/rtt/generated/contract.lua` containing framework/save/network versions, pinned engine SHA and compatibility fingerprints.

## CI gates

Phase 2 CI validates mapped upstream TSV paths/keys, every class table family, stable ID format/ranges/uniqueness, manifest/save consistency, multiplayer requirements, exact loose-mod discovery, all ten runtime module descriptors/demonstrators, and the generated runtime contract.

## Exit criterion

Phase 2 is complete when RTT can route content and lifecycle work through stable module/data interfaces without adding ad-hoc engine edits, and when stable ID, save-version and multiplayer policies exist before generated content systems expand. These criteria are enforced by CI.
