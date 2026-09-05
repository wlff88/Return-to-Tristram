# Claude / Cloud Engineering Mission

You are the lead engineer bootstrapping **Return to Tristram — Abyss Resurrected**.

Read `README.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md` and `NOTICE.md` before changing code. `README.md` is the product source of truth. If an implementation idea conflicts with it, stop and document the conflict instead of silently changing the product direction.

## Mission

Build an extensible Diablo II-style runtime by integrating/forking **AbyssEngine/AbyssEngine** and adding an optional **D2R local asset provider**. Then build **Return to Tristram** as an original gameplay/content layer on top.

This is **not** a Median XL port. You may study Median XL for high-level design patterns, but do not copy its content, data tables, names, maps, art, story, skills, item definitions or proprietary implementation.

## Hard constraints

1. Do not commit, upload, embed or redistribute Blizzard assets.
2. Do not commit caches generated from D2R.
3. Do not bypass DRM, encryption or technical protection measures.
4. Do not require proprietary assets in CI/tests.
5. Keep gameplay independent of D2R filesystem paths and file formats.
6. Preserve Abyss upstream license/copyright notices.
7. Prefer minimal upstream patches and explicit adapter layers.
8. Windows x64 is the first vertical-slice target, but engine-independent code should remain portable.
9. Do not reintroduce the previous D2RMM architecture from `legacy-d2rmm` as the foundation.
10. Make small, testable commits; do not perform an unreviewable mass rewrite.

## First session: required work order

### 1. Audit upstream Abyss

Inspect the current `AbyssEngine/AbyssEngine` repository and document:

- current commit SHA;
- build prerequisites;
- renderer structure;
- current asset/content loading path;
- world/map representation;
- unit/monster representation;
- animation path;
- current test infrastructure;
- seams where an `AssetProvider` abstraction can be introduced;
- likely blockers for a D2R presentation provider.

Create `docs/adr/0001-abyss-integration-strategy.md` comparing at least:

- direct fork/vendor;
- git subtree;
- submodule + extension layer.

Choose one and explain why before importing large amounts of upstream code.

### 2. Establish a reproducible upstream baseline

Make current Abyss build on Windows x64 using its existing CMake toolchain. Add exact build/run notes and pin the upstream revision. Do not change gameplay yet.

### 3. Introduce provider contracts before D2R parsing

Design and implement a minimal interface around logical asset IDs. Suggested concepts:

```text
AssetProvider
AssetResolver
AssetManifest
BuildCompatibility
LocalAssetCache
```

Add a `TestAssetProvider` backed only by tiny project-owned/synthetic fixtures. Prove unit tests and CI with this provider.

### 4. Add D2R installation detection

Implement configuration plus safe autodetection where appropriate. The user must be able to explicitly select the local D2R install directory.

Detection must:

- be read-only;
- report installed build/version when possible;
- fail clearly on unsupported/missing layouts;
- never download missing files;
- never bypass protection mechanisms.

### 5. Research the minimum D2R asset path for the POC

Do not attempt a complete extractor. Identify only what is required to render a minimal Blood Moor vertical slice.

Target logical resources:

- one ground/environment set;
- Fallen model/materials;
- Fallen idle/attack/death animations;
- minimal player representation if feasible;
- one drop/item representation.

If public documentation is insufficient or access would require circumvention, document the blocker and continue with the provider abstraction/test assets rather than using risky techniques.

### 6. Vertical slice

The first acceptance loop is:

```text
Rogue Encampment -> Blood Moor -> Fallen -> attack -> death -> drop
```

Abyss must own simulation. The D2R provider may supply only presentation resources.

### 7. First Return to Tristram feature

After the provider POC works, implement one **original** RTT endgame encounter:

- key/portal entry;
- one boss;
- at least one phase/mechanic;
- one original reward;
- data-driven configuration where practical.

The point is to prove that engine limits can be extended cleanly—not to recreate Median XL.

## Architecture preferences

Prefer interfaces and data boundaries resembling:

```text
engine/abyss
src/resurrected/assets
src/resurrected/cache
src/resurrected/compat
src/rtt/gameplay
src/rtt/endgame
data/rtt
tools/
tests/
```

Do not enforce this layout if upstream architecture makes another layout clearly superior; document the reason in an ADR.

## Asset mapping model

Gameplay requests logical IDs, for example:

```text
asset://monster/fallen/model
asset://monster/fallen/animation/death
asset://environment/blood_moor/ground
```

The resolver selects a provider. No RTT gameplay module should know a Blizzard filesystem path.

## Local cache requirements

Any transcoding/cache built from user-owned proprietary sources must:

- live outside Git working data by default;
- be ignored by `.gitignore` as a second line of defense;
- contain an input build/version fingerprint;
- be disposable/rebuildable;
- never be uploaded by CI;
- never be packaged into public releases.

## AI/HD asset rule

AI-assisted enhancement is allowed only for project-owned or explicitly permitted source material. Track source/provenance. AI output is not a justification for copying unlicensed third-party mod content.

## Definition of done for the bootstrap

Do not claim the architecture is proven until all are true:

- current Abyss revision is pinned and reproducibly builds;
- provider contract exists;
- test provider passes in CI;
- D2R install detection is implemented safely;
- the project has either a functioning minimal D2R provider POC or a precisely documented technical blocker;
- no proprietary asset is present in Git history created by this new architecture;
- at least one integration test demonstrates gameplay/render separation;
- next-step issues/tasks are documented.

## Working style

- Inspect before editing.
- Cite upstream file paths and functions in architecture notes.
- Prefer small PR-sized changes.
- Add tests with each abstraction.
- Record unknowns explicitly rather than inventing behavior.
- Keep `README.md` current when architecture facts become known.
- Create ADRs for irreversible choices.
- Never silently weaken the asset/legal boundaries for convenience.

Start now with the upstream audit and ADR 0001. Do not begin by importing Median XL or writing a large custom renderer.
