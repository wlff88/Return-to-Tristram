# Abyss audit, 2026-09-05

Inspected https://github.com/AbyssEngine/AbyssEngine at
`885eea067f0d41a4fb75de2e88b3704215859a58`. Source is pinned in `engine/abyss`.
MIT notice is retained in `engine/abyss/LICENSE` (Timothy Sarbin, 2024).

| Area | Actual implementation at the pinned revision |
| --- | --- |
| Entry/render loop | `src/AbyssEngine.c:main`, SDL2 accelerated renderer, 800x600 logical surface |
| Scenes | `src/scenes/Scene.c:Scene_UpdateCurrentScene`, intro videos and main menu only |
| Gameplay | `MainMenu_Update` is empty. No implemented world, units, monsters, combat, loot or quests found in `src` |
| Map formats | No DS1/DT1 importer in this C tree |
| Sprites | `src/drawing/Sprite.c:Sprite_Create` accepts DC6 only; palette conversion to SDL textures |
| Animation | `Sprite_DrawAnimated` advances frames using SDL ticks; no skeletal mesh animation |
| Content | `src/common/FileManager.c:FileManager_OpenFile` normalizes paths and opens MPQ-specific streams; missing files are fatal |
| Configuration | `AbyssConfiguration.c` loads MPQ path/config; Windows config is `%APPDATA%/abyss/abyss.ini` |
| Tests | `tests/RingBufferTest.c`, assert-based ring-buffer test |
| Dependencies | C99, CMake >=3.20, SDL2, zlib, libarchive, FFmpeg 6.1 family via upstream vcpkg manifest |

## Practical extension boundaries

1. Keep logical asset IDs above FileManager. Its fatal-on-miss semantics are
   incompatible with optional-provider fallback.
2. Introduce a renderer adapter around Sprite loading after resolver tests.
   It must own SDL textures and release them before provider destruction.
3. Preserve Scene update/render separation, but add actual world simulation
   before claiming the Blood Moor acceptance loop.
4. Do not confuse the older Go OpenDiablo2 codecs/world with the current C
   rewrite. Reusing GPL codecs would require a separate license decision.

## Blood Moor HD blockers

- No world/monster/combat/drop simulation in the current upstream revision.
- No semantic DS1/DT1 importer in this C tree.
- No CASC provider, D2R mesh/material/animation decoder or HD renderer adapter.
- Installation metadata detection cannot certify model compatibility or ownership.
- Full upstream content path requires classic MPQs; a D2R-only install does not
  satisfy that path. Do not copy game content into the source tree to work around it.

Minimum future manifest: environment ground, one Fallen model/material,
idle/attack/death animations, one player visual and one drop icon. Resolve
actual dependency closures and document formats before implementing loaders.
No claim that these logical IDs already map to tested D2R resources is made.
