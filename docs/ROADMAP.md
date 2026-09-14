# Roadmap

## Phase 0 — Foundation reset

- [x] Preserve previous prototype on backup branch
- [x] Replace project layout with modular skeleton
- [x] Add third-party source/licence policy
- [x] Add bootstrap data schemas

## Phase 1 — DevilutionX baseline

- [x] Select exact upstream revision
- [x] Record upstream licence and commit
- [x] Integrate engine source as an auditable git submodule
- [x] Add baseline verification
- [x] Add Windows bootstrap/build wrapper
- [x] Add minimal runtime mod manifest
- [x] Add baseline/data validation CI
- [ ] Confirm Windows x64 build on developer workstation
- [ ] Verify vanilla campaign launch
- [ ] Verify RTT entry in mod loader
- [ ] Verify save/load
- [ ] Verify controller input
- [ ] Verify multiplayer baseline

## Phase 2 — Mod framework

- [x] Initial feature flag/config file
- [x] Runtime package skeleton
- [ ] Map RTT source schemas to pinned DevilutionX TSV schemas
- [ ] Project data converter
- [ ] Module hook interfaces
- [ ] One demonstrator feature per module
- [ ] Multiplayer compatibility policy for Lua/TSV/MPQ mods

## Phase 3 — Classic+

- [ ] QoL baseline
- [ ] Shared/expanded stash design
- [ ] Loot filter
- [ ] Controller-first UX review
- [ ] Balance-safe item additions

## Phase 4 — Resurrected campaign

- [ ] Expanded quest framework
- [ ] Additional classes
- [ ] Skill progression
- [ ] New/expanded monsters and bosses
- [ ] Extended itemisation and crafting

## Phase 5 — Abyss

- [ ] Abyss keys
- [ ] Tier system
- [ ] Dungeon modifiers
- [ ] Corruption
- [ ] Endgame boss pool
- [ ] Risk/reward tuning

## Phase 6 — Hardening

- [ ] Save migration strategy
- [ ] Multiplayer determinism tests
- [ ] MPQ packaging
- [ ] Documentation
- [ ] Release pipeline
