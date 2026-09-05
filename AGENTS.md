# Engineering entry point

Read README.md, CLAUDE.md, NOTICE.md and docs/UPSTREAM_AUDIT.md. The agent
mission in CLAUDE.md applies to Codex too; the filename is historical.
Use docs/adr/0001-abyss-integration-strategy.md for the integration decision.

Build/test: tools/build-windows.ps1, or portable CMake/CTest plus
python -m unittest discover -s tests -p "test_*.py".

Do not describe the synthetic provider as HD support or a playable simulation.
Keep proprietary sources/caches external. Never stage build/ or game assets.
Do not change the upstream gitlink without recording the new revision and audit.
