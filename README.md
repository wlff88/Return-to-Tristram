# Return to Tristram

Return to Tristram is a Diablo I expansion/overhaul project built on a pinned DevilutionX development baseline.

The project uses one engine foundation and re-implements selected mechanics inspired by the Diablo I modding scene as isolated, reviewable modules instead of trying to merge several incompatible executables.

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

## Design pillars

- Preserve the atmosphere and readability of Diablo I.
- Use DevilutionX as the engine foundation.
- Keep gameplay systems modular and data-driven.
- Separate classic campaign, expanded campaign and endgame systems.
- Keep proprietary Diablo assets outside the repository.
- Review licensing and provenance before importing third-party mod code.

## Target modes

1. **Classic+** — original-style campaign with modern QoL.
2. **Resurrected** — expanded quests, classes, itemisation and encounters.
3. **Abyss** — campaign plus repeatable endgame dungeons and corruption systems.
4. **Hardcore** — optional high-difficulty ruleset.

## Repository layout

```text
Return-to-Tristram/
├── Engine/
│   └── devilutionx/          # pinned upstream submodule
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
├── Data/                     # RTT source schemas
├── packaging/mod/            # runtime DevilutionX mod layout
├── config/
├── Assets/
├── docs/
└── scripts/
```

## Source policy

Tchernobog, Belzebub, The Hell and Infernity are feature/reference sources. Every candidate feature is classified as reimplement, adapt, reference only or reject before code is imported. See `docs/MOD_SOURCE_MATRIX.md`.

## Current phase

**Phase 1 — DevilutionX baseline.** The engine revision is pinned, baseline verification and Windows build tooling exist, and a minimal RTT mod manifest is staged. The next acceptance gate is a real Windows x64 build + vanilla launch + RTT mod-loader smoke test.

## Asset and licence policy

This repository does not distribute Blizzard game data. Users must provide legally obtained Diablo/Hellfire data locally when required. DevilutionX at the pinned revision uses the Sustainable Use License 1.0; see `docs/DEVILUTIONX_LICENSE.md` and the upstream licence in the submodule.
