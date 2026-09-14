# DevilutionX upstream baseline

Return to Tristram pins DevilutionX as a git submodule.

- Repository: `https://github.com/diasurgical/DevilutionX.git`
- Branch tracked for research: `master`
- Pinned commit: `ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6`
- Upstream commit date: 2026-09-13
- Latest stable release observed when pinning: `1.5.5`
- RTT target: development baseline leading toward DevilutionX 1.6 mod infrastructure

## Why master instead of 1.5.5

RTT depends on the newer data-driven and Lua-oriented mod work that is being developed for the 1.6 line. The stable 1.5.x line is useful as a compatibility reference, but it is not the feature baseline for RTT.

## Updating the baseline

Do not advance the submodule casually. An update must:

1. record the old and new SHA;
2. review upstream mod/data changes;
3. run `scripts/verify-baseline.py`;
4. build and launch the Classic+ smoke test;
5. verify save/load and controller input;
6. record breaking changes in `docs/UPSTREAM_CHANGES.md`.
