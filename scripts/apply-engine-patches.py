#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
ENGINE = ROOT / "Engine" / "devilutionx"
PATCH_DIR = ROOT / "Engine" / "patches"
MANIFEST_PATH = PATCH_DIR / "MANIFEST.json"
MANIFEST_REQUIRED_FIELDS = {"upstream_commit", "purpose", "save_safe", "network_safe", "rng_safe"}

# DevilutionX currently contains a mix of LF and CRLF source files. RTT patch
# files are stored with LF, so context matching must tolerate EOL-only
# whitespace differences while still requiring the actual source text to match.
PATCH_MATCH_ARGS = ["--ignore-space-change", "--ignore-whitespace"]

# Patches 0006-0008 were edited manually after generation. Their source context
# is still valid, but one or more @@ hunk counts and file-boundary markers are
# stale. Older patches stay on the normal git-apply path.
RECOUNT_PATCHES = {
    "0006-rtt-normal-xp-multiplier.patch",
    "0007-rtt-phase4-itemization.patch",
    "0008-rtt-necromancer-vertical-slice.patch",
}


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


def normalize_patch_boundaries(patch: pathlib.Path) -> pathlib.Path:
    """Return a temporary patch with explicit diff boundaries and a valid EOF."""
    lines = patch.read_text(encoding="utf-8").splitlines(keepends=True)
    normalized: list[str] = []

    for index, line in enumerate(lines):
        if line.startswith("--- a/") and index + 1 < len(lines) and lines[index + 1].startswith("+++ b/"):
            old_path = line[4:].strip()
            new_path = lines[index + 1][4:].strip()
            if not normalized or not normalized[-1].startswith("diff --git "):
                normalized.append(f"diff --git {old_path} {new_path}\n")
        normalized.append(line)

    normalized_text = "".join(normalized)
    if normalized_text and not normalized_text.endswith("\n"):
        normalized_text += "\n"

    handle = tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        newline="\n",
        suffix=f"-{patch.name}",
        prefix="rtt-normalized-",
        delete=False,
    )
    try:
        handle.write(normalized_text)
    finally:
        handle.close()
    return pathlib.Path(handle.name)


def run_apply(
    patch: pathlib.Path,
    *,
    cwd: pathlib.Path,
    check: bool = False,
    reverse: bool = False,
) -> subprocess.CompletedProcess[str]:
    flags = [*PATCH_MATCH_ARGS]
    if reverse:
        flags.append("--reverse")
    if check:
        flags.append("--check")

    result = run_git(["apply", *flags, str(patch)], cwd=cwd)
    if result.returncode == 0 or patch.name not in RECOUNT_PATCHES:
        return result

    normalized_patch = normalize_patch_boundaries(patch)
    try:
        return run_git(
            ["apply", "--recount", "--verbose", *flags, str(normalized_patch)],
            cwd=cwd,
        )
    finally:
        normalized_patch.unlink(missing_ok=True)


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
                forward = run_apply(patch, cwd=worktree, check=True)
                if forward.returncode == 0:
                    applied = run_apply(patch, cwd=worktree)
                    if applied.returncode != 0:
                        print(f"ERROR: {rel} passed --check but failed while applying validation series", file=sys.stderr)
                        print(applied.stderr, file=sys.stderr)
                        return applied.returncode
                    print(f"OK: {rel} applies cleanly in series")
                    continue

                reverse = run_apply(patch, cwd=worktree, check=True, reverse=True)
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


def check_manifest(patches: list[pathlib.Path]) -> int:
    """Validate that every patch file has a complete MANIFEST.json entry and vice versa."""
    if not MANIFEST_PATH.exists():
        print(f"ERROR: {MANIFEST_PATH.relative_to(ROOT)} is missing", file=sys.stderr)
        return 2

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    entries: dict[str, dict] = manifest.get("patches", {})

    patch_names = {patch.name for patch in patches}
    manifest_names = set(entries.keys())

    missing = sorted(patch_names - manifest_names)
    for name in missing:
        print(f"ERROR: {name} has no MANIFEST.json entry", file=sys.stderr)

    orphaned = sorted(manifest_names - patch_names)
    for name in orphaned:
        print(f"ERROR: MANIFEST.json references {name}, which does not exist in {PATCH_DIR.relative_to(ROOT)}", file=sys.stderr)

    incomplete = False
    for name, fields in entries.items():
        missing_fields = MANIFEST_REQUIRED_FIELDS - fields.keys()
        if missing_fields:
            print(f"ERROR: {name}'s manifest entry is missing fields: {sorted(missing_fields)}", file=sys.stderr)
            incomplete = True

    if missing or orphaned or incomplete:
        return 3

    print(f"OK: MANIFEST.json has a complete entry for all {len(patches)} patches")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate or apply RTT patches to the pinned DevilutionX submodule")
    parser.add_argument("--check", action="store_true", help="Only verify that every patch applies or is already applied")
    parser.add_argument("--check-manifest", action="store_true", help="Only verify MANIFEST.json documents every patch")
    args = parser.parse_args()

    if args.check_manifest:
        patches = sorted(PATCH_DIR.glob("*.patch"))
        return check_manifest(patches)

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
        forward = run_apply(patch, cwd=ENGINE, check=True)
        if forward.returncode == 0:
            applied = run_apply(patch, cwd=ENGINE)
            if applied.returncode != 0:
                print(applied.stderr, file=sys.stderr)
                return applied.returncode
            print(f"APPLIED: {rel}")
            continue

        reverse = run_apply(patch, cwd=ENGINE, check=True, reverse=True)
        if reverse.returncode == 0:
            print(f"OK: {rel} is already applied")
            continue

        print(f"ERROR: {rel} neither applies nor appears to be already applied", file=sys.stderr)
        print(forward.stderr, file=sys.stderr)
        return 3

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
