# Runtime packaging

`packaging/mod/` mirrors the structure expected by the DevilutionX mod loader.

RTT source data lives under `Data/`. `scripts/export-mod-data.py` reads the exact TSV schema from the pinned DevilutionX submodule, applies sparse RTT overrides, and writes complete runtime tables into the staged mod.

Stage a development package with:

```powershell
./scripts/stage-mod.ps1
```

Output: `out/mods/return-to-tristram/`.
