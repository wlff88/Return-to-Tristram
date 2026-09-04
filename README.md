# Return to Tristram — D2R Modding SDK

Starter SDK for developing a **Diablo II: Resurrected single-player data mod / overhaul**.

The repository intentionally contains **no Blizzard game data or assets**. You provide data extracted from your own D2R installation, or use D2RMM to read the installed game tables at build time.

> Recovery note (2026-09-04): this repository was restored from the project's ChatGPT File Library. Files documented as recovered are preserved from the saved v0.2.0 artifacts; missing source modules are being reconstructed from the saved manifest and vertical-slice specification. See `RECOVERY_STATUS.md`.

## What is included

- Native D2R mod scaffold: `mods/<name>/<name>.mpq/data/...`
- D2RMM TypeScript starter mod (`mod.json` + `mod.ts` + modules)
- JSON-driven TSV patch engine for reproducible changes
- Build / install / launch / lint PowerShell scripts
- Cross-platform Python build and validation scripts
- D2RLint integration
- VS Code tasks
- Documentation for items, skills, monsters, loot, maps, strings and endgame systems
- Git-friendly directory structure

## Recommended workflow

1. Install D2R and make a **backup of saves**.
2. Install D2RMM if you want composable scripted mods.
3. Extract only the vanilla data files you need from your own installation.
4. Copy `config.example.json` to `config.local.json` and set local paths.
5. Back up saves before risky testing:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/backup_saves.ps1
```

6. Build:

```powershell
python scripts/build.py
```

7. Validate:

```powershell
python scripts/validate_sdk.py
powershell -ExecutionPolicy Bypass -File scripts/lint.ps1
```

8. Install native build:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
```

9. Launch:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/launch.ps1
```

The native D2R launch pattern is:

```text
D2R.exe -mod ReturnToTristram -txt
```

## Native output layout

```text
Diablo II Resurrected/
└── mods/
    └── ReturnToTristram/
        └── ReturnToTristram.mpq/
            ├── modinfo.json
            └── data/
                ├── global/
                │   └── excel/
                ├── hd/
                └── local/
                    └── lng/
                        └── strings/
```

## Development modes

### A. Native overlay

Use `src/native/data/` for files you explicitly maintain. The build script copies them into `dist/ReturnToTristram/ReturnToTristram.mpq/data/`.

### B. Reproducible TSV patches

Put vanilla tables extracted from **your installation** under:

```text
vendor/vanilla/data/
```

Then define small JSON patches under `patches/`. The build script applies them to the vanilla table and writes only the modified result into `dist/`.

### C. D2RMM

Copy `src/d2rmm/ReturnToTristram/` to `<D2RMM>/mods/ReturnToTristram/`.

## Important safety / compatibility notes

- Use this for **offline/single-player modding** unless you know the exact rules of the environment you are using.
- Back up `.d2s` and shared stash files before testing changes to items, inventory or save-related systems.
- Do not commit extracted Blizzard game files to a public repository.
- A D2R patch may change table columns. Re-extract affected vanilla tables and re-run validation/linting after game updates.
- Keep different mod save paths separated to reduce save corruption and incompatibility risk.

## First milestones

1. Core build/lint pipeline
2. Item + affix framework
3. Crafting / cube recipes
4. Monster scaling and new super uniques
5. Treasure classes / endgame drops
6. Endgame portal/map loop
7. Boss progression
8. Skill/class changes
9. HD map visuals and custom assets
10. Engine/plugin work only if data modding is insufficient

See `docs/ROADMAP.md` and `docs/VERTICAL_SLICE_T1.md`.
