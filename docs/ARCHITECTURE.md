# Architecture

## Core principle

Return to Tristram is one game built on one engine foundation. Existing Diablo I mods are treated as feature/reference sources, not executables to be mechanically merged.

## Layers

```text
Return to Tristram content & systems
quests / classes / skills / abyss
              ↓
Project data & compatibility layer
loaders / hooks / feature flags
              ↓
DevilutionX engine baseline
rendering / input / save / net / UI
              ↓
User-supplied Diablo game data
```

## Why not merge source trees directly?

Long-lived Diablo I mods diverge in player structures, item logic, save formats, network state, dungeon generation and balance assumptions. A literal merge would make upstream updates and debugging expensive.

Features are therefore decomposed into behaviours and reimplemented against a single stable engine model.

## Compatibility boundaries

Changes touching save serialization, network state, deterministic RNG, item IDs, monster IDs, quest-state IDs or dungeon generation require explicit review.

## Dependency direction

`Mods/*` may depend on stable project/engine interfaces. The engine should not depend on specific Return to Tristram content unless unavoidable.

## Feature flags

Classic+, Resurrected, Abyss and Hardcore are composed from feature sets rather than maintained as separate forks.
