#!/usr/bin/env python3
from __future__ import annotations

import argparse
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
ENGINE = ROOT / "Engine" / "devilutionx"
PATCH_DIR = ROOT / "Engine" / "patches"

# DevilutionX currently contains a mix of LF and CRLF source files. RTT patch
# files are stored with LF, so context matching must tolerate EOL-only
# whitespace differences while still requiring the actual source text to match.
PATCH_MATCH_ARGS = ["--ignore-space-change", "--ignore-whitespace"]


def run_git(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=ENGINE,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def apply_args(*extra: str) -> list[str]:
    return ["apply", *PATCH_MATCH_ARGS, *extra]


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate or apply RTT patches to the pinned DevilutionX submodule")
    parser.add_argument("--check", action="store_true", help="Only verify that every patch applies or is already applied")
    args = parser.parse_args()

    if not (ENGINE / "CMakeLists.txt").exists():
        print("ERROR: Engine/devilutionx is missing; initialize submodules first", file=sys.stderr)
        return 2

    patches = sorted(PATCH_DIR.glob("*.patch"))
    if not patches:
        print("No RTT engine patches found.")
        return 0

    for patch in patches:
        rel = patch.relative_to(ROOT)
        forward = run_git(apply_args("--check", str(patch)))
        if forward.returncode == 0:
            if args.check:
                print(f"OK: {rel} applies cleanly")
            else:
                applied = run_git(apply_args(str(patch)))
                if applied.returncode != 0:
                    print(applied.stderr, file=sys.stderr)
                    return applied.returncode
                print(f"APPLIED: {rel}")
            continue

        reverse = run_git(apply_args("--reverse", "--check", str(patch)))
        if reverse.returncode == 0:
            print(f"OK: {rel} is already applied")
            continue

        print(f"ERROR: {rel} neither applies nor appears to be already applied", file=sys.stderr)
        print(forward.stderr, file=sys.stderr)
        return 3

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
