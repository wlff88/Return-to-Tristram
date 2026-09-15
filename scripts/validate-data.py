#!/usr/bin/env python3
from __future__ import annotations

import csv
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "Data"
REQUIRED = {
    "items.tsv": ["id", "display_name", "base_type", "tier", "source", "status", "notes"],
    "uniques.tsv": ["id", "display_name", "base_item", "level", "source", "status", "notes"],
    "monsters.tsv": ["id", "display_name", "family", "min_level", "max_level", "source", "status", "notes"],
    "spells.tsv": ["id", "display_name", "category", "class_scope", "source", "status", "notes"],
    "affixes.tsv": ["id", "display_name", "kind", "item_scope", "min_level", "source", "status", "notes"],
    "recipes.tsv": ["id", "display_name", "inputs", "output", "source", "status", "notes"],
    "bosses.tsv": ["id", "display_name", "family", "min_level", "max_level", "source", "status", "notes"],
    "quests.tsv": ["id", "display_name", "chapter", "trigger", "source", "status", "notes"],
    "classes.tsv": ["id", "display_name", "archetype", "source", "status", "notes"],
    "abyss_modifiers.tsv": ["id", "display_name", "effect", "source", "status", "notes"],
}


def validate_file(name: str, expected: list[str]) -> list[str]:
    path = DATA / name
    if not path.exists():
        return [f"missing: {path.relative_to(ROOT)}"]
    with path.open("r", encoding="utf-8", newline="") as fh:
        reader = csv.reader(fh, delimiter="\t")
        try:
            header = next(reader)
        except StopIteration:
            return [f"empty: {path.relative_to(ROOT)}"]
    if header != expected:
        return [f"bad header: {path.relative_to(ROOT)}", f"  expected: {expected}", f"  got:      {header}"]
    return []


def main() -> int:
    errors: list[str] = []
    for name, columns in REQUIRED.items():
        errors.extend(validate_file(name, columns))
    if errors:
        print("Data validation failed:")
        for error in errors:
            print(error)
        return 1
    print(f"Validated {len(REQUIRED)} TSV schemas.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
