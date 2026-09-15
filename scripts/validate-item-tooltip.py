#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PATCH = ROOT / "Engine/patches/0004-rtt-item-comparison-tooltip.patch"
DOC = ROOT / "docs/ITEM_TOOLTIP.md"


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)

for path in (PATCH, DOC):
    if not path.is_file():
        fail(f"missing item-tooltip contract file: {path.relative_to(ROOT)}")

patch = PATCH.read_text(encoding="utf-8")
for token in (
    "GetRttComparisonItem",
    "PrintRttItemComparison",
    "INVLOC_HAND_LEFT",
    "INVLOC_HAND_RIGHT",
    "INVLOC_CHEST",
    "INVLOC_HEAD",
    "INVLOC_AMULET",
    "INVLOC_RING_LEFT",
    "vs equipped Damage",
    "vs equipped Armor",
    "vs equipped STR",
    "vs equipped Resist",
    "PrintRttItemComparison(item)",
):
    if token not in patch:
        fail(f"item comparison patch missing token: {token}")

text = DOC.read_text(encoding="utf-8")
for heading in ("## Comparison rules", "## Displayed deltas", "## Compatibility", "## Runtime acceptance"):
    if heading not in text:
        fail(f"item tooltip documentation missing heading: {heading}")

print("OK: RTT item comparison tooltip contract is internally consistent")
