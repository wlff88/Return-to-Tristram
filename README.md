# Return to Tristram

Return to Tristram is a Diablo I expansion/overhaul project built on a pinned DevilutionX development baseline.

The project uses one engine foundation and re-implements selected mechanics inspired by the Diablo I modding scene as isolated, reviewable modules instead of trying to merge several incompatible executables.

## Project status

**Foundation reset is complete.** RTT now has a single-engine architecture, a pinned DevilutionX baseline, reproducible Windows MSVC CI, sparse TSV runtime generation, auditable engine patches and the first RTT gameplay/QoL features.

Current development focus is the transition from **Phase 2 — Mod framework** into **Phase 3 — Classic+**.

Implemented RTT-specific features include:

- sparse TSV override/export pipeline;
- Classic+ starter-gold gameplay override;
- Lua-driven loot-filter hook and default loot filter;
- immediate exact monster resistance/immunity display;
- ordered, CI-validated DevilutionX patch application;
- Windows MSVC compile gate that verifies `devilutionx.exe` is produced;
- repeatable Phase 1 Windows runtime-acceptance harness with isolated saves/config and JSON evidence.

The remaining Phase 1 baseline work is one real runtime acceptance pass with legally supplied Diablo data: launch, RTT mod discovery, Tristram/Cathedral combat, save/reload, controller flow and two-client multiplayer baseline.

See `docs/PROJECT_STATUS.md` for the current acceptance state and `docs/ROADMAP.md` for the implementation roadmap.

## Current engine baseline

- Upstream: `diasurgical/DevilutionX`
- Integration: git submodule at `Engine/devilutionx`
- Pinned commit: `ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`
- Target: 1.6-era TSV/Lua mod infrastructure
- Stable reference: DevilutionX 1.5.5

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/wlff88/Return-to-Tristram.git
```

On Windows:

```powershell
./scripts/bootstrap-devilutionx.ps1
./scripts/build-windows.ps1 -Configuration Release
./scripts/stage-mod.ps1
```

To execute the canonical Phase 1 runtime acceptance pass against a directory containing a legally obtained `DIABDAT.MPQ`:

```powershell
./scripts/runtime-acceptance.ps1 -DiabloDataPath "C:\Games\Diablo"
```

The full procedure and pass criteria are defined in `docs/PHASE1_RUNTIME_ACCEPTANCE.md`.

## Design pillars

- Preserve the atmosphere and readability of Diablo I.
- Use DevilutionX as the single engine foundation.
- Keep gameplay systems modular and data-driven.
- Separate classic campaign, expanded campaign and endgame systems through feature sets rather than engine forks.
- Keep proprietary Diablo assets outside the repository.
- Review licensing and provenance before importing third-party mod code.
- Treat save serialization, deterministic RNG, network state and stable content IDs as explicit compatibility boundaries.

## Target modes

1. **Classic+** — original-style campaign with modern QoL.
2. **Resurrected** — expanded quests, classes, itemisation and encounters.
3. **Abyss** — campaign plus repeatable endgame dungeons and corruption systems.
4. **Hardcore** — optional high-difficulty ruleset.

## Repository layout

```text
Return-to-Tristram/
├── Engine/
│   ├── devilutionx/          # pinned upstream submodule
│   └── patches/              # small, ordered RTT engine extension patches
├── Mods/
│   ├── core/
│   ├── quests/
│   ├── classes/
│   ├── skills/
│   ├── itemization/
│   ├── crafting/
│   ├── monsters/
│   ├── bosses/
│   ├── abyss/
│   └── qol/
├── Data/                     # RTT source schemas and sparse overrides
├── packaging/mod/            # staged DevilutionX mod runtime layout
├── config/
├── Assets/
├── docs/
└── scripts/
```

## Versioning

The current development line is `0.1.0-dev`. It is **not** a Classic+ release yet. Pre-release and release gates are defined in `docs/VERSIONING.md`.

## Source policy

Tchernobog, Belzebub, The Hell and Infernity are feature/reference sources. Every candidate feature is classified as reimplement, adapt, reference only or reject before code is imported. See `docs/MOD_SOURCE_MATRIX.md`.

The former dual-runtime Abyss/DevilutionX experiment is superseded and retained only as repository history; RTT now uses the single-engine architecture described in `docs/ARCHITECTURE.md`.

## Asset and licence policy

This repository does not distribute Blizzard game data. Users must provide legally obtained Diablo/Hellfire data locally when required. DevilutionX at the pinned revision uses the Sustainable Use License 1.0; see `docs/DEVILUTIONX_LICENSE.md` and the upstream licence in the submodule.
