#!/usr/bin/env python3
from __future__ import annotations

import argparse
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
ENGINE = ROOT / "Engine" / "devilutionx"
PATCH_DIR = ROOT / "Engine" / "patches"

# DevilutionX currently contains a mix of LF and CRLF source files. RTT patch
# files are stored with LF, so context matching must tolerate EOL-only
# whitespace differences while still requiring the actual source text to match.
#
# Several RTT patches are maintained manually after follow-up edits. --recount
# makes git derive hunk sizes from the hunk bodies instead of trusting stale
# line counts in @@ headers; context still has to match the pinned baseline.
PATCH_MATCH_ARGS = ["--recount", "--ignore-space-change", "--ignore-whitespace"]


def run_git(
    args: list[str],
    *,
    cwd: pathlib.Path = ENGINE,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def apply_args(*extra: str) -> list[str]:
    return ["apply", *PATCH_MATCH_ARGS, *extra]


def check_patch_series(patches: list[pathlib.Path]) -> int:
    """Validate patches in real application order without mutating the engine checkout."""
    with tempfile.TemporaryDirectory(prefix="rtt-patch-check-") as temp_dir:
        worktree = pathlib.Path(temp_dir) / "engine"
        added = run_git(["worktree", "add", "--detach", str(worktree), "HEAD"])
        if added.returncode != 0:
            print("ERROR: unable to create temporary DevilutionX worktree for patch validation", file=sys.stderr)
            print(added.stderr, file=sys.stderr)
            return added.returncode

        try:
            for patch in patches:
                rel = patch.relative_to(ROOT)
                forward = run_git(apply_args("--check", str(patch)), cwd=worktree)
                if forward.returncode == 0:
                    applied = run_git(apply_args(str(patch)), cwd=worktree)
                    if applied.returncode != 0:
                        print(f"ERROR: {rel} passed --check but failed while applying validation series", file=sys.stderr)
                        print(applied.stderr, file=sys.stderr)
                        return applied.returncode
                    print(f"OK: {rel} applies cleanly in series")
                    continue

                reverse = run_git(apply_args("--reverse", "--check", str(patch)), cwd=worktree)
                if reverse.returncode == 0:
                    print(f"OK: {rel} is already applied in series")
                    continue

                print(f"ERROR: {rel} neither applies after previous RTT patches nor appears to be already applied", file=sys.stderr)
                print(forward.stderr, file=sys.stderr)
                return 3
        finally:
            removed = run_git(["worktree", "remove", "--force", str(worktree)])
            if removed.returncode != 0:
                print("WARNING: temporary patch-validation worktree could not be removed cleanly", file=sys.stderr)
                print(removed.stderr, file=sys.stderr)

    return 0


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

    if args.check:
        return check_patch_series(patches)

    for patch in patches:
        rel = patch.relative_to(ROOT)
        forward = run_git(apply_args("--check", str(patch)))
        if forward.returncode == 0:
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
