# Roadmap

## Phase 0 — Reset / bootstrap

- [x] Preserve old D2RMM prototype as `legacy-d2rmm`.
- [x] Reset `main` around Abyss Resurrected architecture.
- [x] Add README, agent mission, architecture and asset boundaries.
- [ ] Audit current upstream Abyss.
- [ ] ADR 0001: select upstream integration strategy.

## Phase 1 — Abyss baseline

- [ ] Pin upstream revision.
- [ ] Reproducible Windows x64 build.
- [ ] Existing tests passing.
- [ ] CI using only freely distributable/synthetic data.
- [ ] Document renderer/content seams.

## Phase 2 — Resurrected provider layer

- [ ] `AssetProvider` contract.
- [ ] `AssetResolver`.
- [ ] `AssetManifest` and source fingerprinting.
- [ ] `TestAssetProvider`.
- [ ] local cache abstraction.
- [ ] provider contract tests.

## Phase 3 — D2R local provider POC

- [ ] explicit D2R installation configuration.
- [ ] safe Windows installation detection.
- [ ] installed build compatibility record.
- [ ] resolve one environment set.
- [ ] resolve Fallen model/material/animations.
- [ ] no proprietary files in Git/CI/release artifacts.

Acceptance loop:

```text
Rogue Encampment -> Blood Moor -> Fallen -> attack -> death -> drop
```

## Phase 4 — Return to Tristram vertical slice

- [ ] original key/portal flow.
- [ ] original uber encounter.
- [ ] original reward/charm-equivalent system.
- [ ] data-driven boss phases.
- [ ] deterministic test scenario.

## Phase 5 — content systems

- [ ] expanded skill data model.
- [ ] item/affix system.
- [ ] crafting/recipes.
- [ ] scalable endgame tiers/modifiers.
- [ ] richer boss scripting.
- [ ] world/map extension without D2R level-ID constraints.

## Phase 6 — HD production pipeline

- [ ] asset provenance manifest.
- [ ] project-owned texture/icon super-resolution workflow.
- [ ] PBR material reconstruction workflow.
- [ ] HD billboard pipeline for legacy project-owned sprites.
- [ ] native 3D replacement workflow for priority assets.

## Phase 7 — tools/editor

- [ ] asset mapper.
- [ ] item/skill editor.
- [ ] encounter editor.
- [ ] semantic map importer.
- [ ] WYSIWYG map/world editor.

## Explicitly deferred

- Battle.net compatibility.
- multiplayer protocol recreation.
- full D2R asset extraction.
- wholesale Median XL import.
- mass AI asset generation before the engine vertical slice works.
