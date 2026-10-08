# RTT Asset Factory

## Purpose

RTT Asset Factory is a human-reviewed content-generation pipeline for **Return to Tristram**. It accelerates creation of original RTT monsters, items, UI art and environment assets while preserving the project's Diablo I visual identity, deterministic data model and licensing rules.

The factory is a **tooling layer**, not an engine dependency. Generated content is reviewed, normalized and exported into RTT-owned source assets and data before entering the runtime package.

## Design principles

1. Preserve Diablo I readability, scale and atmosphere.
2. Keep proprietary Blizzard assets outside the repository.
3. Prefer original generated/source art over derivative extraction.
4. Human approval is mandatory before runtime export.
5. Generated gameplay data must use stable RTT IDs and existing TSV/Lua schemas.
6. Engine code must not depend on a specific AI provider.
7. Every generated asset must have provenance metadata.
8. Deterministic gameplay state is authoritative; generative tooling must never run during gameplay.

## High-level pipeline

```text
Prompt / content brief
        |
        v
  Content Designer
        |
        +-----------------------+
        |                       |
        v                       v
   Art Generator           Data Generator
        |                       |
        v                       v
   Normalization           Balance Validator
        |                       |
        +-----------+-----------+
                    |
                    v
               Human Review
                    |
                    v
               RTT Exporter
                    |
          +---------+---------+
          |                   |
          v                   v
       Assets/*             Data/*
```

## 1. Item Factory

### Input

Example authoring request:

```yaml
kind: unique_item
name_hint: Spine of the Apostate
base_type: dagger
archetype: summoner
class_affinity: necromancer
power_band: midgame
theme:
  - corrupted_cathedral
  - bone
  - fallen_horadrim
```

### Output

```text
Generated/Items/spine_of_the_apostate/
├── source/
│   ├── concept.png
│   └── source.json
├── processed/
│   ├── inventory.png
│   └── preview.png
├── data/
│   ├── item.json
│   ├── stats.json
│   └── strings.json
└── manifest.json
```

`Generated/` is a suggested local working directory and should not contain third-party proprietary source assets.

### Item definition

```json
{
  "id": "rtt_unique_spine_apostate",
  "name": "Spine of the Apostate",
  "baseType": "dagger",
  "quality": "unique",
  "archetype": "summoner",
  "requiredLevel": 24,
  "powerBudget": 100,
  "signaturePower": "raise_on_kill",
  "art": "items/spine_of_the_apostate.png"
}
```

### Item generation stages

```text
brief
 -> candidate names
 -> candidate stats
 -> power-budget validation
 -> synergy validation
 -> signature-power selection
 -> icon generation
 -> silhouette/readability normalization
 -> human review
 -> stable RTT ID allocation
 -> TSV/Lua export
```

### Power budget

AI may propose stats, but numeric legality and final power are deterministic.

Each modifier receives:

- `power_cost`
- minimum item level
- slot restrictions
- archetype tags
- class tags
- incompatibility tags

Example:

```json
{
  "id": "faster_cast_10",
  "type": "suffix",
  "stat": "faster_cast_rate",
  "value": 10,
  "powerCost": 12,
  "tags": ["caster", "speed"]
}
```

### Evaluation scores

Each generated item receives:

- Power Score
- Synergy Score
- Novelty Score
- Build Impact
- Slot Competition Score

An item must pass configured thresholds before export.

## 2. Affix Engine

The Affix Engine is deterministic and data-driven.

Supported content families:

```text
Magic
Rare
Crafted
Set
Unique
Corrupted
```

Affixes include explicit legality metadata instead of free-form LLM logic.

```json
{
  "id": "rtt_affix_grave_ward",
  "kind": "prefix",
  "stat": "armor_class",
  "min": 6,
  "max": 10,
  "tier": 2,
  "allowed": ["armor", "helm", "shield"],
  "tags": ["defensive"]
}
```

### Anti-junk rules

Examples:

```text
caster archetype -> strongly downweight melee-only stats
summoner archetype -> increase minion/summon weighting
jewelry -> forbid armor-class-only affixes where the RTT schema forbids them
bow/ranged archetype -> reject melee-only properties
```

The existing RTT item schema and save/network contracts remain authoritative.

## 3. Signature Powers

Signature Powers are reusable authored mechanics referenced by generated items.

Example catalog:

```text
SP001  enemy_explode_on_kill
SP002  summon_on_kill
SP003  cast_spell_on_hit
SP004  cast_spell_when_struck
SP005  temporary_aura
SP006  convert_damage_type
SP007  extra_projectile
SP008  execute_low_health_enemy
SP009  curse_on_hit
SP010  short_range_blink_trigger
```

Generated items may select from approved powers and parameter ranges. New powers require code/design review before being added to the catalog.

## 4. Set Factory

Input:

```yaml
kind: set
name_hint: The Last Horadrim
class_affinity: sorcerer
pieces: 5
theme: fallen_horadrim
power_band: endgame
```

Output includes:

- coherent names
- coherent visual motifs
- per-piece stats
- partial-set bonuses
- full-set bonus
- stable RTT IDs
- generated preview sheet

A set is validated as a whole, not only item-by-item.

## 5. Corruption Factory

Corruption is intended primarily for the Abyss content line.

Possible positive mutations:

- add affix
- upgrade affix tier
- add signature power
- add socket-like RTT mechanic if supported by the runtime
- convert one stat family into another

Possible costs:

- reduced durability
- increased requirements
- reduced resistance
- life/resource penalty
- repair restriction

Corruption must be deterministic once applied and persist through RTT save/network reconstruction.

## 6. Monster Factory

### Pipeline

```text
monster brief
 -> concept sheet
 -> 3D or 2D master source
 -> rig / animation authoring
 -> directional renders
 -> frame normalization
 -> palette/readability pass
 -> collision/gameplay metadata
 -> human review
 -> RTT asset export
```

Suggested animation set:

- idle
- walk
- attack A
- attack B
- hit
- death
- cast, where applicable

### Monster metadata

```json
{
  "id": "rtt_monster_fallen_horadrim_guard",
  "family": "undead_humanoid",
  "tier": "elite",
  "theme": "fallen_horadrim",
  "animations": ["idle", "walk", "attack", "hit", "death"],
  "artSource": "generated-original",
  "reviewStatus": "approved"
}
```

Gameplay stats are generated through the existing RTT data pipeline, never embedded in image-generation prompts as authoritative values.

## 7. Environment / Tileset Factory

The environment generator should produce modular source packs rather than monolithic backgrounds.

Example pack:

```text
fallen_horadrim_cathedral/
├── floors/
├── walls/
├── doors/
├── pillars/
├── rubble/
├── props/
├── decals/
└── manifest.json
```

Every pack defines:

- intended dungeon/theme
- tile dimensions
- anchor rules
- collision intent
- lighting assumptions
- palette/readability constraints
- provenance

## 8. Art Style Profiles

Initial RTT profiles:

```text
tristram_gothic
cathedral_corruption
catacombs_ossuary
caves_ancient
hell_infernal
fallen_horadrim
abyss_corruption
```

Profiles contain constraints, not copyrighted source images.

Example:

```json
{
  "id": "fallen_horadrim",
  "lighting": "low_key_warm_cold_contrast",
  "materials": ["aged_iron", "bone", "stone", "faded_cloth"],
  "shapeLanguage": ["gothic", "ritual", "fortified"],
  "avoid": ["modern_ui", "anime", "high_saturation", "photorealistic_background"]
}
```

## 9. Provenance manifest

Every generated source asset should have a manifest.

```json
{
  "assetId": "rtt_item_spine_apostate",
  "createdBy": "rtt-asset-factory",
  "sourceType": "generated-original",
  "generator": "provider/model-or-manual",
  "promptHash": "sha256:...",
  "sourceFiles": ["source/concept.png"],
  "reviewed": true,
  "reviewer": "human",
  "licenseStatus": "project-original"
}
```

Provider-specific metadata may be stored locally if publishing it is undesirable.

## 10. QA gates

### Visual QA

- transparent/expected background
- correct frame dimensions
- no clipped silhouette
- readable at in-game size
- acceptable palette and contrast
- no embedded text unless explicitly designed
- no obvious generation artifacts
- coherent style profile

### Gameplay QA

- stable ID exists
- allowed affix combination
- power budget passes
- no invalid cross-reference
- save/recreate round-trip passes
- multiplayer reconstruction passes when gameplay state changes
- runtime tables validate

### Legal/provenance QA

- source provenance present
- no proprietary Blizzard source asset committed
- no unlicensed third-party asset committed
- generated work marked as project-original/generated source

## 11. Human approval states

```text
DRAFT
 -> GENERATED
 -> AUTO_VALIDATED
 -> REVIEW_REQUIRED
 -> APPROVED
 -> EXPORTED
 -> RUNTIME_VERIFIED
```

Only `APPROVED` assets may enter normal RTT content exports.

## 12. Suggested implementation layout

```text
tools/asset-factory/
├── README.md
├── schemas/
│   ├── asset.schema.json
│   ├── item.schema.json
│   ├── monster.schema.json
│   └── provenance.schema.json
├── profiles/
├── prompts/
├── generators/
├── validators/
├── exporters/
└── tests/
```

The implementation should remain optional developer tooling and should not become a runtime requirement.

## 13. MVP order

### v0.1 — Item Factory

- item JSON schema
- approved affix catalog adapter
- power-budget validator
- icon generation adapter
- image normalization
- provenance manifest
- human review gate
- RTT table exporter

### v0.2 — Monster Factory

- monster brief schema
- directional render contract
- animation-frame normalizer
- monster provenance
- content-table exporter

### v0.3 — Environment Factory

- modular environment-pack schema
- tile/prop normalization
- collision metadata
- dungeon-theme exporter

### v0.4 — Balance automation

- build/archetype simulations
- slot competition analysis
- automatic overpowered-item warnings
- generated balance report

## 14. Non-goals

RTT Asset Factory must not:

- run generative models inside gameplay runtime;
- replace human art/design approval;
- commit proprietary Diablo/Hellfire data;
- bypass RTT stable content IDs;
- introduce nondeterministic item/monster state into saves or multiplayer;
- create an engine dependency on any external AI API.
