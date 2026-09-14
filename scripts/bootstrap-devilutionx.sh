#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/Engine/devilutionx"

if [[ -e "$ENGINE_DIR" ]]; then
  echo "Engine/devilutionx already exists; refusing to overwrite." >&2
  exit 1
fi

echo "No DevilutionX baseline has been selected yet."
echo "Record the approved upstream commit in docs/MOD_SOURCE_MATRIX.md, then update this script to clone and checkout that exact revision."
exit 2
