#!/usr/bin/env python3
from __future__ import annotations

import configparser
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "runtime-acceptance.ps1"
DOC = ROOT / "docs" / "PHASE1_RUNTIME_ACCEPTANCE.md"
MANIFEST = ROOT / "packaging" / "mod" / "manifest.ini"
MOD_ENTRY = ROOT / "packaging" / "mod" / "lua" / "mods" / "return-to-tristram" / "init.lua"


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


for path in (SCRIPT, DOC, MANIFEST, MOD_ENTRY):
    if not path.is_file():
        fail(f"required Phase 1 runtime acceptance file is missing: {path.relative_to(ROOT)}")

entry = MOD_ENTRY.read_text(encoding="utf-8")
if 'require("mods.rtt.init")' not in entry:
    fail("DevilutionX loose-mod entry point must delegate to mods.rtt.init")

script = SCRIPT.read_text(encoding="utf-8")
required_script_tokens = (
    "--data-dir",
    "--save-dir",
    "--config-dir",
    "return-to-tristram=1",
    "scripts/verify-baseline.py",
    "stage-mod.ps1",
    "rttSaveDetected",
    "controllerFlow",
    "multiplayerBaseline",
    "phase1-$Timestamp.json",
)
for token in required_script_tokens:
    if token not in script:
        fail(f"runtime acceptance harness is missing required token: {token}")

config = configparser.ConfigParser()
config.optionxform = str
config.read(MANIFEST, encoding="utf-8")
if "mod" not in config:
    fail("runtime manifest has no [mod] section")
mod = config["mod"]
if mod.get("programId") != "RTRM":
    fail("runtime manifest programId must be RTRM")
if mod.get("saveExtension") != "rtt":
    fail("runtime manifest saveExtension must be rtt")
if mod.get("name") != "Return to Tristram":
    fail("runtime manifest name must be Return to Tristram")

text = DOC.read_text(encoding="utf-8")
for heading in (
    "## Automated gates",
    "## Manual runtime gates",
    "## Running the acceptance pass",
    "## Evidence and pass criteria",
):
    if heading not in text:
        fail(f"Phase 1 runtime acceptance documentation is missing heading: {heading}")

print("OK: Phase 1 runtime acceptance harness wiring is internally consistent")
