# ADR 0001: pinned submodule with extension targets

Status: implemented on the bootstrap branch, pending merge.

Upstream: https://github.com/AbyssEngine/AbyssEngine
Revision: `885eea067f0d41a4fb75de2e88b3704215859a58`.

## Evidence

The current C tree contains intro/main-menu scenes, SDL2 DC6 sprites,
MPQ streams, audio/video and one ring-buffer test. It does not contain a
playable world, DS1/DT1 map loader, monster simulation, combat, loot or a
3D renderer. The older OpenDiablo2 Go implementation is a different codebase.
The proposed Blood Moor loop therefore requires simulation work as well as
asset loading. The architecture is not yet proven.

## Options

| Approach | Benefits | Costs |
| --- | --- | --- |
| Direct fork/vendor | Easy invasive changes and standalone checkout | Large copied tree, manual upstream merges and attribution maintenance |
| Subtree | One checkout, explicit update commits | Noisy imports, harder separation of local changes |
| Submodule plus extensions | Exact source identity, original license retained, small RTT changes | Recursive checkout required; integration adapter still necessary |

Choose the submodule at `engine/abyss`. RTT owns separate CMake targets and
provider contracts. Build the unchanged upstream as its own CMake project:
its CMakeLists uses CMAKE_SOURCE_DIR for content and modules, so embedding it
with add_subdirectory would change assumptions. No upstream gameplay patches
are justified during bootstrap.

## Consequences

The dependency-free provider target can run without SDL or game files. The
upstream ring-buffer test is compiled from the pinned sources as a separate
baseline check. This is explicitly not a full engine build. The full build
needs SDL2, zlib, libarchive and FFmpeg (avcodec, avformat, avutil, swscale,
swresample). Library versions remain pinned by upstream's manifest baseline
`b4a3d89125e45bc8f80fb94bef9761d4f4e14fb9`. Use host vcpkg scripts at
`04a9d8e5212d01ee1dd9478eadd9caade4f8b0d4`: the old host scripts require
`bash-5.2.026-1-x86_64.pkg.tar.zst`, which returned HTTP 404 on all six mirrors
during the Windows build. Separate host-tool pinning from library pinning.

The first presentation integration point is Sprite_Create/Sprite__LoadDC6;
FileManager_OpenFile returns an MPQ-specific stream and terminates on misses.
Do not implement fallback by calling that fatal API speculatively. A future
adapter must translate a resolved asset view into renderer-owned textures.
The current contracts and their tests do not imply that adapter exists.
