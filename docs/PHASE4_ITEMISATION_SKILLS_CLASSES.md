# Phase 4 — Itemisation, skills and classes

Status: **ACTIVE**

Phase 4 turns the Phase 2 framework into a versioned gameplay platform. The non-negotiable rule is that generated RTT items and progression must survive save/load and multiplayer reconstruction without silently changing identity.

## 1. Stable identity

Canonical semantic identities live in `config/content-ids.json` and are append-only. Phase 4 adds concrete development entries for item archetypes, affixes, uniques, sets, recipes, skills and the first RTT class.

Semantic IDs such as `RTT_AFFIX_0008` are never derived from a TSV row number. Once released, an ID may be deprecated but never reused for different content.

The initial class vertical slice is `RTT_CLASS_0002` — **Necromancer**.

## 2. Compact item metadata v1

DevilutionX reconstructs packed items from base index, seed, creation info and `dwBuff`. RTT therefore uses the otherwise unused high bits of `Item.dwBuff` as the deterministic item-metadata carrier instead of expanding `PlayerPack`.

| Bits | Owner | Meaning |
| --- | --- | --- |
| 0 | DevilutionX | `CF_HELLFIRE` |
| 1–4 | DevilutionX | `CF_UIDOFFSET` |
| 5–10 | RTT | affix slot 0, compact code 0–63 |
| 11–16 | RTT | affix slot 1, compact code 0–63 |
| 17–22 | RTT | affix slot 2, compact code 0–63 |
| 23–28 | RTT | affix slot 3, compact code 0–63 |
| 29–30 | RTT | RTT rarity code |
| 31 | RTT | RTT item-metadata marker |

The complete RTT mask is `0xFFFFFFE0`; the upstream-reserved mask is `0x0000001F`. CI rejects any overlap.

Compact affix code `0` means no affix. Codes `1..63` are append-only and never reused. The semantic stable ID remains authoritative; the compact code is only a serialization/network representation.

Initial rarity codes:

- `0` — vanilla-compatible/generated item;
- `1` — RTT Rare;
- `2` — RTT Set;
- `3` — reserved for a future migrated rarity layer.

Vanilla Unique remains represented by DevilutionX's native unique machinery until the RTT unique bridge is enabled.

## 3. No item morphing

The rare engine must distinguish **fresh generation** from **reconstruction**.

Planned engine contract:

1. Fresh eligible dungeon equipment enters RTT generation with `generateRttMetadata=true`.
2. If the RTT marker is absent, a local deterministic hash of the existing item seed/base/level selects whether the item becomes RTT Rare and selects compact affix codes. This hash must not consume DevilutionX's global RNG stream.
3. The selected metadata is written to `dwBuff` before the item is transmitted or saved.
4. `RecreateItem` calls the same overlay with `generateRttMetadata=false`.
5. If an RTT marker exists, the exact encoded rarity/affix codes are reapplied.
6. If no RTT marker exists during reconstruction, the item is treated as a pre-Phase-4/vanilla item and is **not upgraded or rerolled**.

This prevents installing a newer RTT build from turning an old saved magic item into a different Rare.

## 4. Tiered affixes

`Data/itemization/affixes.json` is the canonical initial affix catalog. Phase 4 starts with 12 immutable entries across four families:

- Gravebound T1–T3 — weapon damage;
- Stalwart T1–T3 — armor;
- of Embers T1–T3 — fire resistance;
- of Storms T1–T3 — lightning resistance.

The engine slice may initially generate fewer than four affixes per item, but the serialized layout supports four slots from day one so future 2-prefix/2-suffix Rares do not require a destructive format change.

## 5. Uniques, sets and crafting

Canonical prototype content:

- Ashen Covenant — Bone Wand unique;
- Boneward — Graveward Shield unique;
- Gravewhisper — Boneweave Robe unique;
- Ossuary Regalia — first set-framework definition.

Crafting contracts, all under the `blacksmith` system (`Data/crafting/recipes.json`'s `systems.values` also reserves `alchemy`, `runes` and `corruption` for later — empty today, since adding a recipe there means designing a new resource economy or mechanic, not wiring up an existing pattern):

- Reforge Rare (blacksmith);
- Raise Affix Tier (blacksmith);
- Reroll Affix Slot (blacksmith).

All three currently spend only inventory gold (`currencyModel: "inventory-gold"`). Alchemy/Runes/Corruption recipes would need that decided explicitly: new drop-based materials, or stay gold-gated to keep the "easy to understand, hard to optimize" philosophy.

Crafting must reconstruct the item from its stable base and metadata before applying a new metadata word. It must never incrementally stack an effect on top of already-applied derived stats.

## 6. Save Schema v2

Phase 4 raises RTT Save Schema from v1 to v2 while keeping v1 readable.

New top-level state:

- `itemization_state`
  - `metadata_version = 1`
  - `compact_affix_map_version = 1`
- `progression_state`
  - `class_id`
  - `skill_points`
  - `skills`
  - `passives`

Migration `1 -> 2` only adds missing state and preserves existing/unknown fields.

## 7. Skills and progression

The first progression catalog contains:

- Bone Spike — active, level 1;
- Bone Armor — active, level 4;
- Grave Pact — active, level 8;
- Soul Siphon — notable;
- Ossuary Mastery — mastery.

The target model remains PoE-lite rather than a full Path of Exile clone: active skill upgrades, one specialization choice and a readable passive/notable/mastery layer.

## 8. Necromancer vertical slice

Necromancer is initially an RTT logical class overlay with Sorcerer-compatible presentation. This lets RTT stabilize class identity, save state, skill progression and itemisation without introducing or redistributing proprietary presentation assets.

The vertical slice identity is bone/shadow/sustain/risk-reward. A dedicated class-selection entry and dedicated legally distributable presentation can follow after the gameplay contract is stable.

## 9. Phase 4 implementation sequence

1. **Foundation:** stable catalogs, compact metadata layout, Save Schema v2/migration, runtime registry, CI.  
2. **Rare engine:** fresh-vs-recreate split, deterministic local roll, Rare metadata encode/apply, Rare UI.  
3. **Unique/set bridge:** stable RTT unique/set metadata and bonuses.  
4. **Crafting engine:** metadata-safe mutations through deterministic reconstruction.  
5. **Progression engine:** skill points, active upgrades, passive/notable/mastery state.  
6. **Necromancer playable slice:** class activation, first three actives and passive/mastery effects.  
7. **Regression:** save migration, item round-trip, multiplayer reconstruction and campaign build-archetype tests.

## 10. Exit criterion

Phase 4 engineering is complete when at least one Necromancer build can use RTT Rare/Unique/Set itemisation, skill progression and crafting through the original campaign path, and automated contracts prove that stable generated items and progression survive v1→v2 migration and repeated save/recreate cycles without identity drift.

Real-machine gameplay acceptance may remain a separate gate, as with Phase 3, but CI/build/save/network contracts must be green before Phase 4 is called engineering-complete.
