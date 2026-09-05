# Build and verification

## Bootstrap (verified locally on Windows x64)

Requirements: Visual Studio C++ Build Tools and Windows SDK, CMake 3.20+,
Python 3.10+, Git. The script locates Visual Studio's bundled CMake when it
is not on PATH. Tested with VS Build Tools 2019, MSVC 19.29.30159 and Python
3.13 on 2026-09-05.

```powershell
./tools/build-windows.ps1
./build/bootstrap/Release/rtt_probe.exe
python tools/d2r_install.py --path "C:/Program Files (x86)/Diablo II Resurrected"
```

Result: `rtt_assets.lib`, `rtt_probe.exe`, two passing CTest cases and six
passing Python tests. The ring-buffer test uses the exact pinned Abyss C
sources with assertions enabled even in Release. D2R metadata detection was
also exercised against a local 3.3.93847 installation. No game assets are
required by tests, copied into this checkout or uploaded as artifacts.

Portable equivalent:

```sh
git submodule update --init --recursive
cmake -S . -B build/bootstrap
cmake --build build/bootstrap --config Release
ctest --test-dir build/bootstrap -C Release --output-on-failure
python -m unittest discover -s tests -p 'test_*.py'
```

The GitHub workflow runs these on Windows and Linux; remote CI results must
be checked separately from the local verification above.

## Full upstream engine

```powershell
./tools/build-windows.ps1 -FullEngine
```

The script verifies the Abyss revision, pins vcpkg to upstream's manifest
baseline, downloads open-source build dependencies, then configures the
separate `build/abyss-vcpkg` directory. This keeps its toolchain cache apart
from direct CMake attempts. No game data is downloaded.

Initial direct configuration was blocked by missing SDL2. The full vcpkg
dependency build is a separate verification step; success of the bootstrap
target does not imply success of the full engine or its content path.

To run the full upstream executable after building, supply classic Diablo II
and LoD MPQs externally and configure `%APPDATA%/abyss/abyss.ini` using the
upstream template `engine/abyss/content/abyss.ini`. A D2R-only installation
does not provide that upstream content path. Running menus is not a playable
Blood Moor scene.

## Next implementation tasks

1. Establish actual upstream world simulation and map import; document scope
   before adding the Rogue/Blood Moor/combat/drop acceptance loop.
2. Add a renderer adapter consuming resolved asset views with explicit
   resource lifetime. Prove a provider swap at that boundary.
3. Research one D2R HD dependency set with versioned format evidence, then
   implement a read-only local provider and content-hashed external cache.
4. Add the original RTT encounter only after the complete loop works.
