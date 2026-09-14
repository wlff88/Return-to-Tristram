#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import subprocess
import sys

EXPECTED = "ae73bd0d451aa69bfcc8b1b02c6d14fc742944f6"
ROOT = pathlib.Path(__file__).resolve().parents[1]
ENGINE = ROOT / "Engine" / "devilutionx"


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def main() -> int:
    if not ENGINE.exists():
        print("ERROR: Engine/devilutionx is missing. Initialize submodules.", file=sys.stderr)
        return 2

    actual = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ENGINE, text=True
    ).strip()
    if actual != EXPECTED:
        print(f"ERROR: DevilutionX baseline mismatch: expected {EXPECTED}, got {actual}", file=sys.stderr)
        return 3

    status = git("status", "--porcelain", "--", "Engine/devilutionx")
    if status and not status.startswith(" ?"):
        print(f"WARNING: submodule state reported by git: {status}")

    print(f"OK: DevilutionX baseline {actual}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
