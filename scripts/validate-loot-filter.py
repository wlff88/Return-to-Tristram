#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
FILTER = ROOT / "packaging/mod/lua/mods/rtt/qol/loot_filter.lua"
CONFIG = ROOT / "packaging/mod/lua/mods/rtt/qol/loot_filter_config.lua"
MODULE = ROOT / "packaging/mod/lua/mods/rtt/modules/qol.lua"
DOC = ROOT / "docs/LOOT_FILTER.md"


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)

for path in (FILTER, CONFIG, MODULE, DOC):
    if not path.is_file():
        fail(f"missing Loot Filter 2.0 file: {path.relative_to(ROOT)}")

filter_text = FILTER.read_text(encoding="utf-8")
config_text = CONFIG.read_text(encoding="utf-8")
module_text = MODULE.read_text(encoding="utf-8")
doc_text = DOC.read_text(encoding="utf-8")

for token in (
    "permissive = {",
    "balanced = {",
    "strict = {",
    "item.magical ~= 0",
    "item:isGold()",
    "item:isUsable()",
    "not item:isEquipment()",
    "alwaysShowNames",
    "hideNormalNames",
    "normalValueOverrides",
):
    if token not in filter_text:
        fail(f"loot filter implementation missing token: {token}")

for token in (
    'preset = "balanced"',
    "normalValueOverrides",
    "alwaysShowNames",
    "hideNormalNames",
):
    if token not in config_text:
        fail(f"loot filter config missing token: {token}")

if "ShouldShowItemLabel" not in module_text or "lootFilter.shouldShow" not in module_text:
    fail("QOL module is not wired to the presentation-only item-label hook")

for heading in ("## Presets", "## User rules", "## Safety invariants", "## Runtime acceptance"):
    if heading not in doc_text:
        fail(f"loot filter documentation missing heading: {heading}")

print("OK: Loot Filter 2.0 contract is internally consistent")
