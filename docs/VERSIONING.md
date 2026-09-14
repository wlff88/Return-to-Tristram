# Return to Tristram — Versioning Policy

Return to Tristram uses Semantic Versioning-style release numbers with explicit development/pre-release identifiers.

## Current line

Current development version: `0.1.0-dev`

This identifies the Classic+ development line before its first public alpha acceptance gate. It does **not** mean Classic+ is feature-complete.

## Version format

Stable releases use:

```text
MAJOR.MINOR.PATCH
```

Pre-release builds may use:

```text
MAJOR.MINOR.PATCH-alpha.N
MAJOR.MINOR.PATCH-beta.N
MAJOR.MINOR.PATCH-rc.N
```

Development branches may use:

```text
MAJOR.MINOR.PATCH-dev
```

## Milestone mapping

- `0.1.x` — Classic+ development/release line
- `0.2.x` — itemisation core
- `0.3.x` — skills/classes vertical slice
- `0.4.x` — Resurrected campaign
- `0.5.x` — monster/boss content completion
- `0.6.x` — crafting/content depth
- `0.7.x` — Abyss endgame
- `0.8.x` — multiplayer/hardcore feature complete
- `0.9.x` — beta / feature freeze
- `1.0.0` — full Return to Tristram release

Minor lines describe project milestones rather than promising strict API compatibility while RTT remains pre-1.0.

## Promotion gates

### `0.1.0-dev` -> `0.1.0-alpha.1`

Required:

- Windows runtime smoke test passes with legally supplied Diablo data;
- RTT loads through the intended mod path;
- new game reaches Tristram/Cathedral;
- save/load works using `.rtt` saves;
- controller baseline is verified;
- current RTT patches/features render and behave correctly in-game;
- no known blocker that can corrupt saves.

### Alpha -> Beta

Required:

- milestone feature set is complete;
- save migrations exist for released schema changes;
- multiplayer semantics are documented for gameplay-affecting systems;
- regression checklist is automated or repeatable;
- no known critical save corruption or deterministic multiplayer defect.

### Beta -> Release candidate

Required:

- feature freeze;
- only bug, compatibility, balance and packaging changes accepted;
- release packaging works without proprietary Blizzard assets;
- installation/update documentation is complete.

### Release candidate -> Stable

Required:

- release candidate completes the full regression campaign;
- supported platforms produce reproducible artifacts;
- migration from the preceding supported release is verified;
- no release-blocking crash, save, networking or progression issue remains.

## Patch releases

Patch versions are reserved primarily for:

- bug fixes;
- crash fixes;
- safe balance corrections;
- packaging fixes;
- compatibility fixes;
- save migration corrections.

A patch release should not silently introduce a new incompatible save schema.

## Save compatibility and versions

Before RTT enables generated rare/affix/corruption systems in a public release, saves must include an RTT schema/version identifier and the project must define forward migration rules.

If a release intentionally breaks compatibility during pre-1.0 development, that break must be stated in release notes and must not silently load an incompatible save as though it were valid.

## Source of truth

- `packaging/mod/manifest.ini` carries the runtime-visible mod version.
- this document defines release semantics;
- `docs/PROJECT_STATUS.md` defines the current engineering state;
- tagged releases are authoritative once public release automation exists.

Until the Classic+ alpha gate passes, keep the runtime version on the `0.1.0-dev` line.
