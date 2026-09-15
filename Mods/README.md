# Gameplay modules

Each subdirectory owns one gameplay family. Runtime modules communicate through the deterministic Phase 2 lifecycle framework rather than modifying each other's internals directly.

The repository-level `Mods/<family>` directories document ownership. Runtime Lua implementations live under `packaging/mod/lua/mods/rtt/modules/`.

All ten module families are registered by the framework:

`core -> qol -> quests -> classes -> skills -> itemization -> crafting -> monsters -> bosses -> abyss`

Future gameplay is gated independently from module registration. A module may be framework-enabled for lifecycle/self-test coverage while its later-phase gameplay features remain disabled.
