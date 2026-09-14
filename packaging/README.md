# Runtime packaging

`packaging/mod/` mirrors the structure expected by the DevilutionX mod loader.

The current package is deliberately minimal: a manifest plus a no-op Lua bootstrap. Gameplay data is not copied from `Data/` until a converter has mapped RTT schemas to the exact pinned DevilutionX 1.6 TSV schemas.

Stage a development package with:

```powershell
./scripts/stage-mod.ps1
```

The result is written to `out/mods/return-to-tristram/` and can later be packed into an MPQ for multiplayer-compatible distribution.
