#!/usr/bin/env python3
from __future__ import annotations

import configparser
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
ENGINE = ROOT / "Engine" / "devilutionx"
PROFILE = ROOT / "config" / "classic-plus.ini"
PATCH = ROOT / "Engine" / "patches" / "0003-rtt-classic-plus-visual-store-default.patch"
DOC = ROOT / "docs" / "CLASSIC_PLUS.md"

EXPECTED_GAME = {
    "Store UI": "2",
    "Run in Town": "1",
    "Quick Cast": "1",
    "Experience Bar": "1",
    "Floating Item Info Box": "1",
    "Show health values": "1",
    "Show mana values": "1",
    "Show Monster Type": "1",
    "Show Item Labels": "1",
    "Auto Refill Belt": "1",
    "Auto Gold Pickup": "1",
}


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


for path in (PROFILE, PATCH, DOC):
    if not path.is_file():
        fail(f"missing Classic+ contract file: {path.relative_to(ROOT)}")

for path in (
    ENGINE / "Source/qol/visual_store.cpp",
    ENGINE / "Source/qol/visual_store.h",
    ENGINE / "test/visual_store_test.cpp",
):
    if not path.is_file():
        fail(f"pinned DevilutionX visual-store dependency missing: {path.relative_to(ROOT)}")

config = configparser.ConfigParser(interpolation=None)
config.optionxform = str
config.read(PROFILE, encoding="utf-8")
if not config.getboolean("Mods", "return-to-tristram", fallback=False):
    fail("Classic+ profile must enable return-to-tristram")
for key, expected in EXPECTED_GAME.items():
    actual = config.get("Game", key, fallback=None)
    if actual != expected:
        fail(f"Classic+ profile mismatch for {key!r}: expected {expected!r}, got {actual!r}")

patch = PATCH.read_text(encoding="utf-8")
required_patch_tokens = (
    "StoreUi::VisualGrid",
    'experienceBar("Experience Bar"',
    'floatingInfoBox("Floating Item Info Box"',
    'autoGoldPickup("Auto Gold Pickup"',
    'showItemLabels("Show Item Labels"',
    'autoRefillBelt("Auto Refill Belt"',
    'quickCast("Quick Cast"',
)
for token in required_patch_tokens:
    if token not in patch:
        fail(f"Classic+ defaults patch missing token: {token}")

text = DOC.read_text(encoding="utf-8")
for heading in (
    "## Default profile",
    "## Visual vendor inventory",
    "## Compatibility boundary",
    "## Runtime acceptance",
):
    if heading not in text:
        fail(f"Classic+ documentation missing heading: {heading}")

print("OK: Classic+ baseline contract is internally consistent")
