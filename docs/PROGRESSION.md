# Return to Tristram — Progression System

RTT progression should feel closer to a deep modern ARPG than to vanilla Diablo I. The design is inspired by the *type* of build freedom found in games such as Path of Exile, but uses original RTT systems, names, data and presentation.

## Pillars

1. **Large passive constellation** — hundreds of small and medium decisions rather than a short fixed skill tree.
2. **Build-defining keystones** — powerful rule-changing nodes with real trade-offs.
3. **Masteries** — thematic choices unlocked by reaching important clusters.
4. **Specializations** — late-game class evolutions with their own compact trees.
5. **Active skills + modifiers** — skills are separate from the passive tree and can be modified by socketed or linked modifiers.
6. **Respec with friction, not punishment** — partial respec is available through earned currency/rewards; full build changes remain meaningful.
7. **Controller-first navigation** — every node graph, skill socket and specialization screen must work with Xbox-class controllers.

## Character identity

Starting archetypes provide initial stats, presentation and a starting position in the passive constellation. They do not hard-lock the final build.

Initial archetypes:

- Warrior
- Rogue
- Sorcerer

Expansion-ready archetypes may include Monk, Necromancer and Paladin-like RTT-original equivalents where licensing and content direction permit.

## Passive constellation

Node types:

- **Minor** — attributes, damage, defense, resource, speed.
- **Notable** — stronger themed bonuses that anchor clusters.
- **Keystone** — changes a core gameplay rule and usually introduces a drawback or constraint.
- **Mastery** — choose one bonus from a thematic family after reaching a cluster.
- **Specialization** — connects to the character's late-game specialization layer.

Example original keystones:

### Blood Covenant
Life regeneration is disabled. A percentage of damage dealt is converted to delayed healing. Healing potions gain reduced immediate effect but stronger recovery over time.

### Iron Faith
Energy Shield cannot recharge naturally. Armor mitigation also applies partially to elemental damage. Blocking an attack restores a small amount of Energy Shield.

### Arcane Hunger
Spells cost Life after Mana reaches zero. Spell damage scales with missing Mana, but incoming healing is reduced while Mana is empty.

### Hunter's Rhythm
Repeated attacks against the same target gain accuracy and critical chance. Changing targets clears the bonus.

## Active skill system

Active abilities should not be tied directly to passive-tree nodes. RTT uses a modular skill system:

```text
Active Skill
  + Modifier A
  + Modifier B
  + Modifier C
  + optional Catalyst
```

Example:

```text
Chain Lightning
  + Forking Current
  + Static Buildup
  + Life Conduction
```

This allows one base skill to become several mechanically different builds without copying another game's skill gems or support gems.

## Specializations

At major progression milestones, characters complete challenge encounters called **Ordeals**. Completing Ordeals awards specialization points.

Each starting archetype should eventually have three original specialization paths. Example direction for the Sorcerer:

- **Elementalist** — elemental conversion, ailments, chain reactions.
- **Chronomancer** — cooldown manipulation, echoes, delayed casts, temporal defenses.
- **Archmage** — very high resource investment, heavy spell scaling, arcane defenses.

Names and mechanics are provisional and should be audited for originality before release.

## Endgame progression

Character growth continues after the campaign through:

- endgame encounter maps;
- challenge modifiers;
- boss invitations;
- permanent account unlocks;
- specialization points;
- crafting unlocks;
- rare progression currencies;
- build-defining unique items.

## Data architecture

The graph engine lives in `src/rtt/progression/` and must remain independent of both Abyss and DevilutionX. Runtime adapters expose character state and gameplay effects, while RTT owns progression rules.

Planned data layout:

```text
data/progression/
  passive-tree.json
  masteries.json
  specializations/
  skills/
  modifiers/
```

## Acceptance criteria

The first progression vertical slice should provide:

- at least 30 connected passive nodes;
- at least 3 notables;
- at least 1 keystone;
- one mastery choice;
- one specialization branch;
- controller navigation between nodes;
- persistence in a save game;
- deterministic validation of legal/illegal paths;
- one active skill with at least three modifier combinations.
