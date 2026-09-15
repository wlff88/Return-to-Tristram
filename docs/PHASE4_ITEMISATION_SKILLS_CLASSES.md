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

Rarity codes (matching `Data/itemization/affixes.json`'s `encoding.rarities` block, the shipped source of truth):

- `0` — vanilla-compatible/generated item;
- `1` — RTT Rare;
- `2` — RTT Set;
- `3` — RTT Unique.

The RTT unique bridge is implemented: three prototype uniques (Ashen Covenant, Boneward, Gravewhisper) carry rarity code `3` and round-trip through save/network via the same compact-metadata mechanism as Rares and Sets. Vanilla's own native unique machinery is unrelated and still used for non-RTT uniques (e.g. pre-Phase-4 saves, non-`rtt`-mod games); the two do not overlap.

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

`Data/itemization/affixes.json` is the canonical affix catalog, currently 15 entries across five families, each tagged with one `category` from the taxonomy declared in that file's own `taxonomy.categories` list (`offensive`, `defensive`, `utility`, `resource`, `elemental`, `class`, `skill`, `endgame`, `corrupted`):

- Gravebound T1–T3 — weapon damage (`offensive`);
- Stalwart T1–T3 — armor (`defensive`);
- of Embers T1–T3 — fire resistance (`elemental`);
- of Storms T1–T3 — lightning resistance (`elemental`);
- Marrow T1–T3 — vitality (`resource`).

Four categories (`utility`, `class`, `skill`, `endgame`) and one reserved for the Abyss/corruption endgame layer (`corrupted`) have no affixes yet — the taxonomy exists so they can be added later, but adding one is a stat-pool/balance decision (exact values, weights, tags), not something to invent unprompted.

The engine slice may initially generate fewer than four affixes per item, but the serialized layout supports four slots from day one so future 2-prefix/2-suffix Rares do not require a destructive format change.

### How to add a new affix family (cookbook)

`Data/itemization/affixes.json` is the design source of truth, but it is **not** parsed by the engine at runtime — the compact-code effect logic in `Source/items.cpp` is a separate, hand-written implementation that must be kept in sync by hand. Adding a new family (new compact codes, e.g. 16–18) touches exactly these functions, all in `Source/items.cpp`:

1. `IsRttPrefixCode()` / `IsRttSuffixCode()` — add the new code range to whichever the family is.
2. `RttAffixMinItemLevel()` — extend the `code > 15` bound to the new max code.
3. `IsRttAffixCompatible()` — extend the `code <= 15` bound, and add an item-type gate if the family shouldn't apply to all equipment (mirroring the existing `code <= 3 -> isWeapon()` / `code <= 6 -> isArmor()||isShield()||isHelm()` pattern).
4. `ApplyRttAffix()` — add the new `if (code >= X && code <= Y) { item._iPLWhatever += RttRoll(...); }` block (may need a new `Item` field if no existing one fits, which is itself a save-format question — see `docs/ENGINE_PATCH_POLICY.md` rule 8).
5. `RttAffixLine()` — add the matching tooltip-text branch.
6. `BuildRttRareCodes()`'s `families` array — decide whether the new family enters the 4-slot random-family rotation (today exactly 4 families are eligible per item: weapon-damage-or-armor, Marrow, of Embers, of Storms) and, if so, which existing family it displaces or how the rotation itself needs to change to pick among more than 4 candidates.

Every one of these is a small, mechanical change once the stat values and item-type rules are decided — the decision itself (what the affix does, its tier curve, which items it applies to) is the part that needs sign-off, not the wiring.

## 5. Uniques, sets and crafting

Canonical prototype content:

- Ashen Covenant — Bone Wand unique;
- Boneward — Graveward Shield unique;
- Gravewhisper — Boneweave Robe unique;
- Ossuary Regalia — first set-framework definition.

Crafting contracts are defined before mutation is enabled:

- Reforge Rare;
- Raise Affix Tier;
- Reroll Affix Slot.

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

1. **Foundation** — DONE: stable catalogs, compact metadata layout, Save Schema v2/migration, runtime registry, CI.
2. **Rare engine** — DONE: fresh-vs-recreate split, deterministic local roll, Rare metadata encode/apply, Rare UI; extended across the full base-item catalogue (`RttPhase4.RareRoundTripAcrossAllEquipmentTypes`), currently 15 affixes across 5 families (Gravebound/Stalwart/of Embers/of Storms/Marrow).
3. **Unique/set bridge** — DONE for the initial 3 uniques + 1 set (2-piece bonus only); both are narrow prototypes, not a finished content set — see `docs/PROJECT_STATUS.md` priority list for what's still open.
4. **Crafting engine** — DONE for 3 recipes (Reforge Rare, Raise Affix Tier, Reroll Affix Slot); no sockets, base-upgrade or unique-limited-upgrade yet.
5. **Progression engine** — DONE for the Necromancer's 5-skill catalog (unlock/spend gating, one specialization); no broader passive tree.
6. **Necromancer playable slice** — DONE at the engineering level (class activation, 5 actives/passives/mastery wired); **real-machine campaign playthrough not yet performed**.
7. **Regression** — DONE: save migration, item round-trip, multiplayer reconstruction (`RttPhase4.NetworkChoiceAppliesToSenderNotSelf` and the item-metadata host/client tests) are CI-green; campaign build-archetype tests remain manual (stage 6's real-machine gap).

## 10. Exit criterion

**Engineering criterion met**: automated contracts prove stable generated items and progression survive v1→v2 migration and repeated save/recreate cycles without identity drift (see `scripts/validate-phase4-complete.py`'s required `RttPhase4.*` test list).

**Runtime criterion not yet met**: nobody has played a Necromancer build using RTT Rare/Unique/Set itemisation, skill progression and crafting through the original campaign path on a real machine. Real-machine gameplay acceptance remains a separate gate, as with Phase 3.
