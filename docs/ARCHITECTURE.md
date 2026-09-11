# Architecture Notes

## System boundaries

Return to Tristram is now a **multi-runtime ARPG project** with shared project-owned gameplay/data concepts and separate engine backends.

1. **Abyss Core** — upstream clean-room Diablo II-style simulation/runtime.
2. **DevilutionX Core** — upstream Diablo I/Hellfire runtime used as the Diablo I backend.
3. **Resurrected Compatibility Layer** — shared asset-provider, cache and presentation contracts, including the existing local D2R provider work.
4. **Return to Tristram** — project-owned gameplay/content/endgame layer and design source of truth.

The engines are not linked into one executable by default. They are treated as separate runtime backends with adapters.

```text
                         RETURN TO TRISTRAM
                  shared design / data / tooling
                              |
                 +------------+------------+
                 |                         |
           RuntimeAdapter             AssetResolver
                 |                         |
        +--------+--------+          +-----+------+------+
        |                 |          |            |      |
   Abyss backend    DevilutionX   RTT/Test   Classic   D2R-local
     (D2-like)       backend        assets     assets   provider
        |                 |
        +--------+--------+
                 |
          Presentation API
```

## Why two runtime backends

Abyss and DevilutionX solve different problems and use different codebases, languages, data models and licenses. Combining their internal source trees into one gameplay core would create unnecessary coupling and make upstream updates difficult.

Instead RTT should share **concepts and project-owned data**, not internal engine implementation details.

Candidate portable concepts:

- logical item/monster/skill/quest identifiers;
- encounter definitions;
- project-owned loot/affix metadata;
- asset logical IDs;
- telemetry/event naming;
- map metadata where semantics overlap;
- tooling and validators.

Backend-specific adapters translate those concepts into each engine's native representation.

## Runtime adapter contract

A future `RuntimeAdapter` interface should cover only concepts needed by RTT orchestration, for example:

- runtime identity/version;
- start/load game;
- world/level identity;
- spawn/query entity;
- grant/query item;
- quest/event hooks;
- player state snapshot;
- gameplay event stream;
- logical asset mapping hooks.

Do not attempt to abstract every engine subsystem. If a feature exists only in one engine, keep it backend-specific until there is a real cross-runtime use case.

## Asset-provider contract

A provider exposes capabilities and resolves logical asset identifiers. It must not leak source-specific paths into project gameplay code.

Minimum responsibilities:

- capability query;
- asset existence query;
- metadata/manifest lookup;
- load/open resource handle;
- source build fingerprint;
- diagnostics.

The resolver owns provider priority/fallback.

Example IDs:

```text
asset://monster/fallen/model
asset://monster/butcher/sprite
asset://item/sword/icon
asset://environment/tristram/ground
asset://audio/monster/death
```

## D2R provider security/distribution boundary

Treat the D2R installation as external user data.

- read-only source;
- no network retrieval;
- no repository writes;
- no CI dependency;
- no DRM/protection bypass;
- local derivative cache is disposable and build-fingerprinted;
- unsupported versions fail closed with diagnostics.

The existing D2R provider work remains useful with the Abyss backend and may later supply presentation resources to other RTT tools. It is **not** a dependency of DevilutionX gameplay.

## DevilutionX integration boundary

DevilutionX is pinned under `engine/devilutionx` as an upstream submodule. Keep upstream changes minimal and reviewable.

Initial DevilutionX goals:

1. build the pinned upstream baseline unchanged;
2. create an RTT adapter outside upstream sources where possible;
3. prove a tiny D1 vertical slice using legal local Diablo data;
4. map project logical IDs to DevilutionX entities;
5. move RTT-specific mechanics into project-owned data/modules instead of hard-coding large patches into upstream.

Do not copy Diablo game data into the repository.

## Licensing boundary

The backends have different licensing constraints and must remain clearly attributable.

DevilutionX currently uses the **Sustainable Use License 1.0**, which permits modification but limits use/distribution to the terms of that license, including non-commercial/free distribution conditions for the covered software. Preserve its notices and do not assume the RTT repository as a whole can be relicensed under one permissive license.

Abyss notices and terms must likewise remain preserved according to its upstream license.

Project-owned RTT code should be kept in clearly separate directories so ownership and distribution boundaries remain understandable.

## Data-driven RTT

RTT should move project content out of engine code wherever practical. Shared schemas should eventually cover:

- logical IDs and aliases;
- items/affixes;
- skills;
- monsters;
- encounter phases;
- loot tables;
- recipes;
- portals/keys;
- map metadata;
- asset mappings;
- backend capability requirements.

A definition may declare backend support explicitly rather than pretending all features are portable.

Example concept:

```text
encounter: butcher_returned
backends: [devilutionx, abyss]
assets:
  devilutionx: asset://monster/butcher/sprite
  abyss:       asset://monster/butcher/model
```

## Repository engine layout

```text
engine/
├── abyss/          # pinned upstream submodule
└── devilutionx/    # pinned upstream submodule

src/
├── resurrected/    # existing shared asset/provider work
├── runtime/        # future backend-neutral runtime contracts
│   ├── abyss/
│   └── devilutionx/
└── rtt/            # project-owned gameplay/orchestration modules

data/
├── common/
├── abyss/
└── devilutionx/
```

## Immediate vertical slices

### Abyss/D2R path

Keep the existing target:

```text
Rogue Encampment -> Blood Moor -> Fallen -> attack -> death -> drop
```

with D2R used only as a local presentation provider where technically appropriate.

### DevilutionX path

Start smaller:

```text
Tristram -> Cathedral Level 1 -> one monster -> kill -> one RTT-defined reward
```

Success means the RTT layer can identify the backend, receive gameplay events and apply one project-owned rule without embedding proprietary game data.

## Upstream integration rule

Prefer pinned submodules plus adapters first. Move to maintained forks only when RTT requires durable upstream modifications that cannot reasonably live outside the engine tree. Any such decision should be recorded as an ADR before large changes are made.

## Non-goals

Do not:

- merge Abyss and DevilutionX internals into a single engine;
- redistribute Diablo I, Hellfire, Diablo II or D2R proprietary assets;
- make D2R files mandatory for the DevilutionX backend;
- copy Belzebub/Median XL protected content directly;
- bypass DRM or technical protection mechanisms;
- promise feature parity between backends before adapters prove it is useful.
