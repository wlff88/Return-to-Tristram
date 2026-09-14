# Return to Tristram

Return to Tristram is a Diablo I expansion/overhaul project built around a clean DevilutionX-based architecture.

The project uses one engine foundation and re-implements selected mechanics inspired by the Diablo I modding scene as isolated, reviewable modules instead of trying to merge several incompatible executables.

## Design pillars

- Preserve the atmosphere and readability of Diablo I.
- Use DevilutionX as the engine foundation.
- Keep gameplay systems modular and data-driven.
- Separate classic campaign, expanded campaign and endgame systems.
- Keep proprietary Diablo assets outside the repository.
- Review licensing before importing third-party mod code.

## Target modes

1. Classic+ — original-style campaign with modern QoL.
2. Resurrected — expanded quests, classes, itemisation and encounters.
3. Abyss — campaign plus repeatable endgame dungeons and corruption systems.
4. Hardcore — optional high-difficulty ruleset.

## Repository layout

```text
Return-to-Tristram/
├── Engine/
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
├── Data/
├── Assets/
│   ├── original/
│   └── custom/
├── docs/
└── scripts/
```

## Source policy

Projects such as Tchernobog, Belzebub, The Hell and Infernity are feature/reference sources. Each candidate feature is classified as reimplement, adapt, reference only or reject before code is imported.

See `docs/MOD_SOURCE_MATRIX.md`.

## Current phase

Phase 0: foundation reset. The previous prototype is preserved on a backup branch. The new `main` is the clean skeleton for the DevilutionX-based version.

Next milestone: pin a DevilutionX baseline and build the first playable Classic+ vertical slice.

## Asset policy

This repository does not distribute Blizzard game data. Users must provide legally obtained Diablo/Hellfire data locally when required.
