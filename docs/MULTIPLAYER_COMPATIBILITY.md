# RTT multiplayer compatibility policy

RTT inherits DevilutionX networking, but RTT features are classified before merge according to whether they can affect synchronized gameplay state.

## Required symmetry

The following must match between participating gameplay clients for RTT stateful features: RTT version, pinned DevilutionX baseline, network protocol version, stable content-ID registry, RTT save schema version and enabled gameplay modules that can mutate synchronized state.

The generated RTT runtime contract fingerprints the content registry, save schema and network policy.

## Change classes

### Presentation-only

Examples: item-label visibility and resistance text. A feature may be client-local only if it cannot alter RNG, movement, combat, inventory, drops, quests, saves or packet-visible state.

### Data gameplay

Examples: items, affixes, uniques, monster statistics, spells and classes. Requires explicit multiplayer review and symmetric runtime data.

### Stateful gameplay

Examples: quests, crafting, boss phases and Abyss generation. Requires multiplayer review plus deterministic host/client regression coverage before release.

### Engine hooks

Any hook touching RNG, serialization, IDs or network packets is a compatibility boundary and requires an explicit compatibility test plan.

## Forbidden patterns

RTT gameplay code must not use client-only gameplay mutations, wall-clock/OS-random gameplay RNG, unstable TSV row positions as RTT content identity, or divergent host/client gameplay feature flags.

## Version changes

Increment `networkProtocolVersion` when a compatible client can no longer safely participate with the previous RTT gameplay protocol. Changing save schema alone does not automatically require a network protocol bump, but the change must still pass multiplayer review.
