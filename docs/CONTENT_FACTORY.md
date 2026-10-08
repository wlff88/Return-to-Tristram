# RTT Content Factory

## Goal

RTT Content Factory is the higher-level orchestration layer above Asset Factory. It turns a campaign brief into a structured, reviewable content package for Return to Tristram.

It does **not** automatically ship generated content. It produces drafts, assets, data proposals, validation reports and export-ready packages for human approval.

## Content Factory architecture

```text
Campaign / act brief
        |
        v
  Narrative Planner
        |
        +-----------------------------+
        |             |               |
        v             v               v
 Encounter Planner  Loot Planner   Environment Planner
        |             |               |
        v             v               v
 Monster Factory   Item Factory   Environment Factory
        |             |               |
        +-------------+---------------+
                      |
                      v
                 Balance Engine
                      |
                      v
                  QA / Review
                      |
                      v
                 RTT Exporter
```

## 1. Campaign Brief

Example:

```yaml
content_id: rtt_resurrected_fallen_horadrim
mode: resurrected
working_title: The Fallen Horadrim
estimated_playtime_minutes: 180
theme:
  - ruined_monastery
  - corrupted_horadrim
  - undead_clergy
primary_location: tristram_region
boss_theme: last_horadrim
loot_theme: relics_bone_ritual_steel
```

## 2. Content Pack Output

```text
Generated/ContentPacks/fallen_horadrim/
├── brief.yaml
├── narrative/
│   ├── story_outline.md
│   ├── quests.json
│   └── dialogue_drafts.json
├── encounters/
│   ├── monster_families.json
│   ├── encounter_tables.json
│   ├── elites.json
│   └── bosses.json
├── items/
│   ├── bases.json
│   ├── uniques.json
│   ├── sets.json
│   └── recipes.json
├── environments/
│   ├── themes.json
│   ├── props.json
│   └── layout_rules.json
├── balance/
│   ├── report.json
│   └── warnings.md
├── provenance/
│   └── manifest.json
└── export/
```

## 3. Narrative Planner

The planner creates structured story content without directly mutating runtime state.

Outputs:

- campaign beats
- quest concepts
- NPC roles
- boss motivations
- optional lore entries
- environmental storytelling prompts

Quest drafts should reference stable logical IDs, not hard-coded engine values.

Example:

```json
{
  "id": "rtt_quest_horadrim_vault",
  "title": "The Sealed Vault",
  "prerequisites": ["rtt_quest_cathedral_echoes"],
  "objectives": [
    "find_vault_key",
    "enter_vault",
    "defeat_warden"
  ],
  "rewards": ["rtt_unique_spine_apostate"]
}
```

## 4. Encounter Planner

Encounter plans are generated from authored constraints.

Each area should define:

- target monster families
- density band
- elite frequency
- ranged/melee ratio
- crowd-control pressure
- resistance profile
- boss/miniboss presence
- expected player power band

Example:

```json
{
  "area": "rtt_horadrim_vault_01",
  "powerBand": "midgame",
  "families": [
    "fallen_horadrim_guard",
    "ossuary_scribe",
    "vault_construct"
  ],
  "eliteChance": 0.08,
  "density": "medium",
  "designIntent": "slow_pressure_with_burst_elites"
}
```

## 5. Monster Family Generator

A family is generated as a coherent group rather than isolated monsters.

Example family:

```text
Fallen Horadrim
├── Acolyte
├── Guard
├── Scribe
├── Warden
└── High Preceptor
```

Each family defines:

- shared visual language
- role matrix
- damage types
- resistances
- signature abilities
- elite variants
- drop bias

## 6. Boss Factory

Bosses require explicit design review.

Boss package:

```text
boss identity
 -> arena concept
 -> phase graph
 -> ability kit
 -> summon/add logic
 -> reward table
 -> failure modes
 -> save/network considerations
```

Example phase definition:

```json
{
  "bossId": "rtt_boss_last_horadrim",
  "phases": [
    {
      "id": "p1",
      "healthRange": [1.0, 0.65],
      "abilities": ["ritual_bolt", "summon_guard"]
    },
    {
      "id": "p2",
      "healthRange": [0.65, 0.30],
      "abilities": ["bone_circle", "teleport", "summon_scribe"]
    },
    {
      "id": "p3",
      "healthRange": [0.30, 0.0],
      "abilities": ["enrage", "corruption_nova"]
    }
  ]
}
```

Generated phase logic is only a proposal until implemented and covered by deterministic multiplayer/runtime tests.

## 7. Loot Pool Generator

Input:

```yaml
content_pack: fallen_horadrim
base_items: 12
uniques: 20
set_items: 8
recipes: 6
power_band: midgame_to_endgame
```

The generator distributes rewards among:

- common area drops
- elite-biased drops
- miniboss drops
- boss drops
- quest rewards
- crafting recipes
- Abyss-exclusive sources where applicable

It must avoid making one source mandatory for every build.

## 8. Item Role Matrix

Generated loot should cover distinct purposes:

```text
melee damage
ranged damage
caster
summoner
survivability
resistance
resource sustain
mobility
magic find
crowd control
bossing
hybrid
```

A content pack should publish a coverage report showing which roles are underserved or oversupplied.

## 9. Balance Engine

The balance engine compares proposed content against existing RTT content.

Required checks:

- power-budget range
- level requirement consistency
- slot competition
- build concentration
- resistance pressure
- expected time-to-kill bands
- boss reward value
- crafting cost vs reward
- set completion power

Example warning:

```text
WARNING: rtt_unique_spine_apostate
Necromancer summoner projected slot usage: 91%
Target maximum: 65%
Reason: signature power + skill bonus + cast-speed stack too efficiently.
```

## 10. Build Simulator

A simplified simulator should model representative archetypes rather than attempt frame-perfect engine emulation.

Inputs:

```text
class
level
skill profile
gear profile
monster profile
area difficulty
```

Outputs:

```text
relative DPS
survivability score
resource sustainability
clear-speed proxy
boss-damage proxy
build dependency
```

Use it for comparative tuning, not as authoritative runtime truth.

## 11. Content Coverage Report

Every generated content pack should emit a report such as:

```text
Monster roles
  melee frontliner      4
  ranged pressure       2
  caster/control        2
  summoner              1
  tank                   1

Loot archetypes
  melee                  7
  caster                 6
  summoner               5
  defensive              4
  utility                3

Warnings
  - insufficient cold-resistant elite coverage
  - two unique helms compete for identical build role
  - boss reward table lacks non-class-specific option
```

## 12. Content Approval Workflow

```text
BRIEF
 -> GENERATED_DRAFT
 -> DESIGN_REVIEW
 -> ART_REVIEW
 -> BALANCE_REVIEW
 -> TECHNICAL_VALIDATION
 -> APPROVED
 -> EXPORTED
 -> RUNTIME_TESTED
```

No content reaches the shipped runtime merely because generation succeeded.

## 13. Export Contract

Approved content is transformed into the existing RTT architecture:

```text
Content Factory
      |
      +--> Data tables / sparse overrides
      +--> Lua module data
      +--> stable content IDs
      +--> original project assets
      +--> compatibility fingerprints where required
```

The export layer must respect the project's existing save schema, item reconstruction and multiplayer compatibility contracts.

## 14. Suggested CLI

```text
rtt-content new-pack fallen_horadrim
rtt-content generate items fallen_horadrim
rtt-content generate monsters fallen_horadrim
rtt-content validate fallen_horadrim
rtt-content report fallen_horadrim
rtt-content approve rtt_unique_spine_apostate
rtt-content export fallen_horadrim
```

Example:

```text
$ rtt-content validate fallen_horadrim

Schemas                 PASS
Stable IDs              PASS
Item power budgets      PASS
Affix legality          PASS
Monster references      PASS
Provenance              PASS
Balance warnings        3
Human approvals         41/47

EXPORT BLOCKED
Reason: 6 assets remain REVIEW_REQUIRED
```

## 15. Suggested implementation phases

### CF-0 — Schemas and manifests

- content-pack schema
- item/monster/environment references
- provenance model
- approval-state model

### CF-1 — Item-first vertical slice

- unique-item brief
- affix selection
- power validation
- icon workflow
- stable ID integration
- RTT data export

### CF-2 — Monster family vertical slice

- family brief
- role matrix
- asset manifest
- stat proposal
- export adapter

### CF-3 — Encounter planning

- encounter tables
- elite distribution
- area power bands
- boss draft schema

### CF-4 — Campaign-pack generation

- quest drafts
- encounter package
- loot package
- environment package
- coverage report

### CF-5 — Balance automation

- representative build profiles
- content comparison
- slot-usage warnings
- boss reward analysis

## 16. Relationship to RTT roadmap

Content Factory primarily supports:

- Phase 4 itemisation expansion
- Phase 5 Resurrected campaign
- Phase 6 Abyss endgame

It should remain optional developer tooling and must not delay runtime acceptance work for already-completed engineering phases.

## 17. First practical milestone

The first useful milestone is intentionally small:

```text
one original unique item
 + one generated icon
 + deterministic approved stats
 + provenance manifest
 + RTT stable ID
 + successful table export
 + save/recreate test
```

Once that end-to-end path works, scale to sets, monster families and complete content packs.
