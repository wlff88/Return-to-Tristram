# Phase 1 — DevilutionX baseline

## Selected baseline

Return to Tristram uses DevilutionX commit:

`ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`

The engine is linked as `Engine/devilutionx` through a git submodule. This keeps upstream history separate and makes RTT engine patches explicit instead of hiding them inside a copied source tree.

## Why this revision

At the time of selection, the stable release is 1.5.5 while the development branch contains the 1.6-era mod work RTT needs: data-table overrides, mod manifests, Lua infrastructure and ongoing mod compatibility work.

## Windows developer path

Prerequisites:

- Git for Windows
- CMake
- Visual Studio with Desktop development with C++ and a Windows SDK
- vcpkg recommended; set `VCPKG_ROOT`
- legally obtained Diablo game data for local runtime testing

Bootstrap and build:

```powershell
./scripts/bootstrap-devilutionx.ps1
./scripts/build-windows.ps1 -Configuration Release
./scripts/stage-mod.ps1
```

## Phase 1 acceptance checklist

- [x] Exact upstream revision selected
- [x] Engine integrated as auditable submodule
- [x] Upstream licence identified as Sustainable Use License 1.0
- [x] Baseline SHA verification script
- [x] Windows bootstrap script
- [x] Windows CMake build wrapper
- [x] Minimal DevilutionX-compatible mod manifest
- [x] CI validation for baseline and RTT data
- [ ] Confirm a clean Windows x64 build on a developer workstation
- [ ] Launch vanilla Diablo through the pinned engine
- [ ] Confirm RTT mod appears in the mod loader
- [ ] Verify save/load using `.rtt` save extension
- [ ] Verify controller input
- [ ] Verify multiplayer baseline before gameplay changes

## Constraint

Do not import Tchernobog, Belzebub, The Hell or Infernity source code during Phase 1. Their mechanics are evaluated only after the engine baseline is reproducible.
