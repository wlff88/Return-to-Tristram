#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
ENGINE = ROOT / "Engine" / "devilutionx"
MAP_FILE = ROOT / "config" / "table-map.json"


def read_tsv(path: pathlib.Path):
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if reader.fieldnames is None:
            raise ValueError(f"TSV has no header: {path}")
        return list(reader.fieldnames), [dict(row) for row in reader]


def write_tsv(path: pathlib.Path, fields, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def verify_engine(expected: str):
    if not (ENGINE / "CMakeLists.txt").exists():
        raise RuntimeError("Engine/devilutionx is missing; initialize submodules first")
    actual = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ENGINE, text=True).strip()
    if actual != expected:
        raise RuntimeError(f"DevilutionX baseline mismatch: expected {expected}, got {actual}")


def apply_patch(base_path: pathlib.Path, patch_path: pathlib.Path, output_path: pathlib.Path, key: str):
    base_fields, base_rows = read_tsv(base_path)
    patch_fields, patch_rows = read_tsv(patch_path)
    if key not in base_fields or key not in patch_fields:
        raise ValueError(f"Missing key column {key!r}")
    unknown = [field for field in patch_fields if field not in base_fields]
    if unknown:
        raise ValueError(f"Unknown patch columns: {unknown}")

    index = {row[key]: i for i, row in enumerate(base_rows) if row.get(key)}
    changed = 0
    for patch in patch_rows:
        patch_key = patch.get(key, "").strip()
        if not patch_key:
            raise ValueError(f"Patch row has empty key {key!r}")
        if patch_key not in index:
            raise ValueError(f"Adding new rows is not enabled yet: {patch_key!r}")
        row = base_rows[index[patch_key]]
        for field in patch_fields:
            value = patch.get(field, "")
            if field != key and value != "":
                row[field] = value
        changed += 1

    write_tsv(output_path, base_fields, base_rows)
    return changed


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default=str(ROOT / "out" / "mods" / "return-to-tristram"))
    args = parser.parse_args()
    config = json.loads(MAP_FILE.read_text(encoding="utf-8"))
    verify_engine(config["baseline"])
    output_root = pathlib.Path(args.output)
    for table in config["tables"]:
        count = apply_patch(
            ENGINE / table["upstream"],
            ROOT / table["patch"],
            output_root / table["output"],
            table["key"],
        )
        print(f"{table['name']}: applied {count} override(s)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
