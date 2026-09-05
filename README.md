# Return to Tristram — Abyss Resurrected

> A clean-room, data-driven Diablo II-style ARPG project built on **Abyss Engine**, with an optional high-resolution presentation layer that uses assets from the player's own locally installed copy of **Diablo II: Resurrected**.

## Status

**Bootstrap implementation; not a playable game.** Abyss is pinned at
`885eea067f0d41a4fb75de2e88b3704215859a58` in `engine/abyss`. The C provider
library, synthetic probe and upstream ring-buffer test compile on Windows x64.
Read-only D2R installation detection is implemented. HD loading and the combat
loop are still pending. See [audit](docs/UPSTREAM_AUDIT.md),
[ADR 0001](docs/adr/0001-abyss-integration-strategy.md), and
[provider contract](docs/PROVIDER_CONTRACT.md).

The current C upstream implements menu/media/MPQ loading, **not yet world or
combat simulation**. The older Go OpenDiablo2 implementation is not this engine.

This repository was reset on 2026-09-05 from the previous D2RMM prototype.
The previous implementation is preserved in `legacy-d2rmm` and Git history.

### Run the bootstrap

With Visual Studio C++ Build Tools, CMake 3.20+ and Python 3.10+ installed:

```powershell
git submodule update --init --recursive
./tools/build-windows.ps1
./build/bootstrap/Release/rtt_probe.exe
python tools/d2r_install.py --path "C:/Program Files (x86)/Diablo II Resurrected"
```

The probe resolves original synthetic pixels; it is a console diagnostic,
not a graphical game. `build-windows.ps1 -FullEngine` additionally prepares
the pinned vcpkg dependencies and builds the upstream application.
See [build notes](docs/BUILD.md) for verification status and limitations.

## Vision

The project has two names with different scopes:

- **Abyss Resurrected** — the engine/runtime layer: Abyss Engine plus a modern presentation and asset-provider architecture.
- **Return to Tristram (RTT)** — the game/mod built on that runtime.

The goal is **not** to port Median XL, copy its content, or redistribute Diablo II: Resurrected. RTT will implement its own content and progression while borrowing selected high-level ARPG design ideas such as difficult uber encounters, permanent/collectible rewards, deeper crafting, endgame keys/portals, denser itemization, build-defining affixes and scalable endgame encounters.

## Core principles

1. **Abyss is the simulation base.** Combat, units, maps, skills, items, AI, quests and world state belong to an open, extensible engine instead of hard-coded D2R limits.
2. **D2R is an optional local asset provider, not a dependency bundled with the project.** The repository and releases must contain no Blizzard models, textures, audio, maps or other proprietary assets.
3. **A legal local installation is required for D2R presentation.** The runtime should detect/configure the user's own installation, index it read-only and build only a local cache.
4. **Never bypass DRM or protection mechanisms.** If an asset cannot be accessed without circumventing a technical protection measure, the provider must fail gracefully rather than bypass it.
5. **No copyrighted third-party mod content is copied by default.** Median XL is a design reference only unless explicit permission is obtained for a specific asset or dataset.
6. **Custom RTT assets should be HD-first.** Low-resolution assets owned by the project may be enhanced/reconstructed with AI, with provenance recorded and outputs reviewed for consistency.
7. **Gameplay and presentation remain decoupled.** The game should be able to run with classic/free/test assets even when the D2R provider is unavailable.
8. **Data-driven first.** Skills, items, monsters, encounters and recipes should be defined in data/scripts where practical, not hard-coded into the engine.

## What “Abyss Resurrected” means

Abyss Engine is a clean-room reimplementation of Diablo II written in C. We use it as the starting point for gameplay/runtime work, then add an asset abstraction and modern renderer path.

Upstream: https://github.com/AbyssEngine/AbyssEngine

Conceptually:

```text
                       Return to Tristram
                              |
                  +-----------+-----------+
                  |                       |
            RTT GAMEPLAY              RTT DATA
        skills/items/ubers        maps/quests/loot
                  |                       |
                  +-----------+-----------+
                              |
                       ABYSS RESURRECTED
                              |
          +-------------------+-------------------+
          |                   |                   |
     Abyss simulation     Asset resolver      Renderer/VFX
          |                   |                   |
          |          +--------+---------+         |
          |          |                  |         |
          |      D2R provider       RTT provider  |
          |          |                  |         |
          |    local D2R install   project assets |
          |          |                  |         |
          +----------+--------+---------+---------+
                              |
                         local cache
```

### Important distinction

We are **not** trying to reproduce Blizzard's D2R executable or Battle.net implementation. The intended model is:

```text
Abyss simulation + RTT gameplay + locally resolved D2R presentation assets
```

The engine owns gameplay logic. The user's D2R installation supplies compatible visual/audio resources when available.

## Asset provider architecture

The engine should expose a logical API rather than letting gameplay code access filesystem paths directly.

Example logical IDs:

```text
asset://monster/fallen/model
asset://monster/fallen/animation/attack
asset://environment/blood_moor/ground
asset://item/sword/icon
asset://audio/fallen/death
```

Proposed providers:

```text
AssetProvider
├── TestAssetProvider
├── ClassicD2AssetProvider
├── D2RAssetProvider
└── ReturnToTristramAssetProvider
```

Resolution order must be configurable. A provider returns metadata/handles, never ownership assumptions.

### D2R provider

Responsibilities:

- locate or accept a configured path to a locally installed D2R copy;
- identify the installed build and record compatibility status;
- index supported local asset containers read-only;
- map D2/D2R logical game entities to presentation assets;
- expose models, textures, materials, animations, VFX, audio and environment resources through the common provider API;
- create derivative/transcoded data only in a local cache outside the repository;
- invalidate/rebuild cache after D2R updates;
- provide clear diagnostics for unsupported builds or missing resources.

Strict rules:

- no D2R assets in Git;
- no D2R assets in CI artifacts or releases;
- no automatic download of Blizzard assets;
- no upload of the user's extracted/cache data;
- no DRM bypass;
- cache paths must be ignored by Git by default.

## HD / AI asset pipeline

AI is a production tool for **project-owned or properly permitted** low-resolution assets, not a mechanism to make redistribution of third-party content acceptable.

Preferred pipeline depends on the asset type:

### Icons / UI / textures

```text
source -> cleanup -> AI super-resolution -> art-direction review -> mipmaps/compression -> RTT asset pack
```

### Materials

```text
source diffuse -> HD reconstruction -> normal/roughness/metallic derivation -> manual correction -> PBR material
```

### Legacy sprites

Two tiers are allowed:

1. **HD billboard:** frame-consistent upscale/reconstruction for fast compatibility.
2. **Native HD asset:** original 3D reconstruction, retopology, rig, animation and PBR materials for final quality.

### Maps

Do not upscale a map screenshot. Import map semantics (tiles, walls, collision, objects, warps, spawn regions) into an internal world representation, then render them with compatible HD environment assets.

## Return to Tristram gameplay direction

RTT is an original game layer built on the Diablo II ruleset and feel. The first design pillars are:

- Diablo II combat readability and pacing;
- modernized skills and build diversity;
- deeper itemization and meaningful affixes;
- deterministic and random crafting systems;
- endgame keys, portals and bespoke uber encounters;
- unique permanent/collectible rewards comparable in function to endgame charms, but original to RTT;
- scalable endgame tiers and encounter modifiers;
- data-driven monsters, bosses and reward tables;
- no dependence on D2R hard-coded level-ID limits.

Median XL may be studied as a reference for **design patterns only**. Do not copy its names, maps, art, data tables, story, monsters, skills, unique items or other protected content unless explicit permission is documented.

## Proposed repository layout

```text
/
├── README.md
├── CLAUDE.md
├── NOTICE.md
├── docs/
│   ├── ARCHITECTURE.md
│   └── ROADMAP.md
├── engine/                 # Abyss integration/fork/subtree after bootstrap decision
├── src/
│   ├── resurrected/        # provider/resolver/cache/renderer integration
│   └── rtt/                # Return to Tristram gameplay modules
├── data/                   # project-owned gameplay data
├── tools/                  # importers, validators, asset tooling
├── tests/
└── build/                  # ignored
```

The exact layout may change after the upstream Abyss audit. Do not vendor upstream blindly before the integration approach is documented.

## Engineering architecture

### Layer 1 — Abyss core

Keep upstream modifications minimal and reviewable. Prefer adapters/extensions over invasive edits. Preserve upstream MIT notices for copied/substantial upstream code.

### Layer 2 — Resurrected compatibility layer

Core abstractions:

- `AssetProvider`
- `AssetResolver`
- `AssetManifest`
- `BuildCompatibility`
- `LocalAssetCache`
- renderer-facing model/material/animation handles

Gameplay code must never require D2R-specific paths or formats.

### Layer 3 — RTT gameplay module

Owns:

- skills;
- items and affixes;
- crafting;
- monsters;
- encounters;
- quests;
- endgame progression;
- loot/reward logic.

### Layer 4 — tools

Eventually:

- D2/D2R data inspector;
- asset mapping UI;
- map importer/editor;
- skill/item editor;
- AI HD asset preparation pipeline;
- validation/provenance tooling.

## Initial vertical slice

The first proof must stay deliberately small.

### Milestone A — upstream baseline

- build current Abyss on Windows x64;
- run its existing content path;
- record upstream commit SHA;
- establish tests and CI that do not require proprietary assets.

### Milestone B — provider abstraction

- implement provider/resolver interfaces;
- implement a synthetic `TestAssetProvider`;
- add configuration and diagnostic logging;
- prove that the renderer can swap providers without gameplay changes.

### Milestone C — D2R local provider POC

Target one complete loop:

```text
Rogue Encampment -> Blood Moor -> Fallen -> attack -> death -> drop
```

For the POC, resolve only the minimum D2R presentation resources necessary for that loop. Do not attempt to import the whole game.

Success criteria:

- user points the runtime at an installed D2R copy;
- build is identified;
- one environment set is resolved;
- one monster visual/animation set is resolved;
- player/combat remains Abyss-driven;
- no proprietary asset is written into the repository;
- deleting the local cache and rebuilding it produces the same manifest.

### Milestone D — first RTT encounter

Create one original RTT endgame encounter with:

- one portal/key flow;
- one original boss mechanic;
- one original reward;
- telemetry/logging sufficient to debug the encounter;
- no Median XL content copied into the implementation.

Only after this works should the scope expand to broad content conversion, AI-assisted HD asset production or an editor.

## Build strategy

Upstream Abyss currently uses CMake and C. Keep that toolchain working first. New modules should avoid introducing large frameworks until the POC proves they are necessary.

Primary platform for the first vertical slice: **Windows x64**, because that is the main D2R installation target. Do not unnecessarily break upstream macOS/Linux portability in engine-independent code.

## Testing

Required from the beginning:

- unit tests for path/config/build detection;
- provider/resolver contract tests;
- deterministic manifest/cache tests;
- gameplay tests using synthetic/free test assets;
- zero CI dependency on a licensed D2R installation;
- explicit tests that proprietary asset/cache directories are not staged for commit.

## Legal / distribution boundary

This is a fan project and is not affiliated with or endorsed by Blizzard Entertainment or the Median XL team.

A technical design that reads assets from a user's own local installation reduces redistribution risk but **does not by itself guarantee legal or EULA compliance**. Before a public binary release, review the then-current Blizzard terms and the exact extraction/runtime behavior.

Distribution policy:

- distribute only original project code/data and licenses/notices for permitted third-party code;
- require users to supply any proprietary game installation themselves;
- do not ship proprietary game data or caches;
- do not market RTT as an official Diablo product;
- do not use Median XL content without documented permission.

## Non-goals for the bootstrap phase

Do **not** begin with:

- Battle.net compatibility;
- bypassing D2R protections;
- a full D2R asset dump;
- multiplayer reverse engineering;
- importing all Median XL content;
- hundreds of new skills/items;
- a full WYSIWYG editor;
- an AI-generated art library before the runtime pipeline works.

## Source of truth

`README.md` defines product scope and hard constraints. `CLAUDE.md` defines the initial engineering agent mission. Architecture-changing decisions should be captured as ADRs under `docs/adr/` before large implementation changes.

## Previous prototype

The old direct-D2R/D2RMM implementation is intentionally no longer on `main`. It remains available in:

```text
legacy-d2rmm
```

Use it only as historical reference. Do not rebuild the new architecture on top of its hard-coded D2R level-table approach.
