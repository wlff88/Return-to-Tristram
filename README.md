# Return to Tristram

Return to Tristram is a Diablo I expansion/overhaul project built on a pinned DevilutionX development baseline.

The project uses one engine foundation and re-implements selected mechanics inspired by the Diablo I modding scene as isolated, reviewable modules instead of trying to merge several incompatible executables.

## Project status

**Phase 0, Phase 2 and the engineering scope of Phase 3 are complete.** RTT now has a single-engine architecture, a pinned DevilutionX baseline, a deterministic/versioned mod framework, reproducible Windows MSVC CI, sparse TSV runtime generation, stable content IDs, Save Schema v1, a multiplayer compatibility contract and a complete Classic+ engineering baseline.

**Phase 1 and Phase 3 still require real-machine runtime acceptance.** Those manual Windows/controller/multiplayer tests are deliberately separate from engineering completion. Until they pass, RTT remains `0.1.0-dev` and is not promoted to the first Classic+ alpha.

Implemented RTT-specific capabilities include:

- deterministic ten-module Lua lifecycle framework;
- table-map schema v2 for items, affixes, uniques, monsters, spells and all shipped class tables;
- append-only stable RTT content-ID registry;
- RTT Save Schema v1 + migration API;
- generated runtime compatibility fingerprints;
- explicit multiplayer compatibility policy;
- sparse TSV override/export pipeline;
- Classic+ starter-gold gameplay override;
- Classic+ QoL default profile with visual-grid vendor inventory, auto-gold, belt refill, floating item info and other native DevilutionX QoL enabled;
- Loot Filter 2.0 with presets and safe user rules;
- immediate exact monster resistance/immunity display;
- RTT equipped-item comparison tooltip;
- persistent alternate weapon set / weapon swap without changing `PlayerPack`;
- native stash, 12 spell hotkeys and Ctrl-click inventory/stash transfer reused rather than duplicated;
- ordered, CI-validated DevilutionX patch application;
- Windows MSVC compile/package gate;
- repeatable Phase 1 runtime-acceptance harness with isolated saves/config and JSON evidence;
- dedicated Phase 3 Classic+ runtime checklist and JSON evidence collector.

See `docs/PROJECT_STATUS.md`, `docs/PHASE3_CLASSIC_PLUS.md`, `docs/PHASE3_RUNTIME_ACCEPTANCE.md` and `docs/ROADMAP.md`.

## Current engine baseline

- Upstream: `diasurgical/DevilutionX`
- Integration: git submodule at `Engine/devilutionx`
- Pinned commit: `ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`
- Target: 1.6-era TSV/Lua mod infrastructure

On Windows:

```powershell
./scripts/bootstrap-devilutionx.ps1
./scripts/build-windows.ps1 -Configuration Release
./scripts/stage-mod.ps1
```

Canonical Phase 1 runtime acceptance:

```powershell
./scripts/runtime-acceptance.ps1 -DiabloDataPath "C:\Games\Diablo"
```

Deferred Phase 3 evidence collector:

```powershell
./scripts/phase3-acceptance-evidence.ps1
```

## Design pillars

- Preserve the atmosphere and readability of Diablo I.
- Use DevilutionX as the single engine foundation.
- Keep gameplay systems modular and data-driven.
- Keep proprietary Diablo assets outside the repository.
- Treat save serialization, deterministic RNG, network state and stable content IDs as explicit compatibility boundaries.

## Target modes

1. **Classic+** — original-style campaign with modern QoL.
2. **Resurrected** — expanded quests, classes, itemisation and encounters.
3. **Abyss** — campaign plus repeatable endgame dungeons and corruption systems.
4. **Hardcore** — optional high-difficulty ruleset.

## Versioning

The current development line is `0.1.0-dev`. It is **not** a Classic+ release yet. Pre-release and release gates are defined in `docs/VERSIONING.md`.

## Asset and licence policy

This repository does not distribute Blizzard game data. Users must provide legally obtained Diablo/Hellfire data locally when required. DevilutionX at the pinned revision uses the Sustainable Use License 1.0; see `docs/DEVILUTIONX_LICENSE.md`.
