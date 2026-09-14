# Phase 1 runtime acceptance

Phase 1 is not complete merely because DevilutionX compiles. Return to Tristram must be exercised on a real Windows runtime with legally obtained Diablo game data and the RTT loose mod enabled.

This document defines the repeatable acceptance procedure and the evidence required to mark **Phase 1 — DevilutionX baseline** complete.

## Automated gates

The acceptance harness verifies before gameplay:

1. the repository is on the exact pinned DevilutionX baseline;
2. the RTT-patched Windows build succeeds unless `-SkipBuild` is used;
3. the RTT runtime package is staged unless `-SkipStage` is used;
4. `devilutionx.exe` exists in the expected Windows build output;
5. the supplied data directory contains `DIABDAT.MPQ` / `diabdat.mpq`;
6. the staged RTT package contains `manifest.ini` and the RTT Lua bootstrap;
7. the loose mod is copied to `mods/return-to-tristram` next to the executable;
8. an isolated `diablo.ini` enables the `return-to-tristram` mod;
9. `devilutionx.exe --version` exits successfully;
10. after the first gameplay session, the isolated save tree contains an RTT save namespace/file marker.

The harness never copies Diablo game data into the repository and never commits proprietary assets.

## Manual runtime gates

A human must verify the parts that require rendered UI, gameplay, physical controller input or two live clients:

1. **RTT mod discovery** — Return to Tristram is visible/enabled and loads for the game;
2. **campaign launch** — a new Diablo game reaches Tristram normally;
3. **Cathedral entry** — Cathedral Level 1 loads correctly;
4. **combat + RTT hooks** — kill at least one monster and verify the RTT loot-filter and exact resistance/immunity display do not break normal play;
5. **save/reload** — save, exit, launch again and load the RTT character successfully;
6. **controller flow** — with an Xbox-class controller, verify menu navigation, movement, combat and inventory;
7. **multiplayer baseline** — launch two isolated clients, connect both to the same game, move both characters and perform basic combat without an obvious crash/desync.

A failed or skipped manual gate means Phase 1 remains incomplete.

## Running the acceptance pass

From a Windows PowerShell terminal in the repository root:

```powershell
./scripts/runtime-acceptance.ps1 -DiabloDataPath "C:\Games\Diablo"
```

The supplied directory must contain a legally obtained `DIABDAT.MPQ` (case-insensitive).

Useful development options:

```powershell
# Re-use an existing Release build.
./scripts/runtime-acceptance.ps1 -DiabloDataPath "C:\Games\Diablo" -SkipBuild

# Verify all non-GUI preconditions without launching the game.
./scripts/runtime-acceptance.ps1 -DiabloDataPath "C:\Games\Diablo" -SkipBuild -NoLaunch
```

The harness uses isolated directories under:

```text
out/runtime-acceptance/
├── config/
├── saves/
├── config-client2/
├── saves-client2/
└── evidence/
```

It does not overwrite the user's normal DevilutionX configuration or save directory.

## Evidence and pass criteria

Every run writes a JSON evidence file:

```text
out/runtime-acceptance/evidence/phase1-YYYYMMDD-HHMMSS.json
```

The record contains:

- RTT commit SHA;
- pinned DevilutionX commit SHA;
- build configuration;
- executable preflight result;
- data/mod/save detection results;
- manual gate results;
- final `passed` value.

Exit codes:

- `0` — all requested gates passed, or preflight-only mode completed successfully;
- `2` — a full runtime acceptance run finished but one or more acceptance gates were not confirmed;
- any other non-zero code — setup/build/runtime harness failure.

**Phase 1 can be marked COMPLETE only after a full run records `passed: true`.** A `-NoLaunch` preflight is useful for engineering validation but is not Phase 1 completion evidence.

## Why this remains a local acceptance gate

RTT does not distribute Blizzard game data. CI therefore verifies the engine build, patches, data pipeline, runtime package and harness wiring, while the final campaign/controller/multiplayer acceptance is intentionally executed on a workstation that has legally obtained Diablo data.

The pinned DevilutionX baseline supports loose mods under `mods/<name>/manifest.ini` and command-line isolation through `--data-dir`, `--save-dir` and `--config-dir`; the RTT harness uses those upstream mechanisms rather than inventing a parallel runtime loader.
