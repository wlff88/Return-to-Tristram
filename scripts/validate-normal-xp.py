#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
patch = ROOT / "Engine/patches/0006-rtt-normal-xp-multiplier.patch"
if not patch.is_file():
    raise SystemExit("missing RTT Normal XP multiplier patch")
text = patch.read_text(encoding="utf-8")
required = [
    '#include "mods/mod_identity.h"',
    'GetActiveModSaveExtension() == "rtt"',
    'sgGameInitInfo.nDifficulty == DIFF_NORMAL',
    'static_cast<uint64_t>(clampedExp) * 3 / 2',
    'if (gbIsMultiplayer)',
]
missing = [token for token in required if token not in text]
if missing:
    raise SystemExit("Normal XP patch contract missing: " + ", ".join(missing))

multiplier = text.index('GetActiveModSaveExtension() == "rtt"')
mp_cap = text.index('if (gbIsMultiplayer)')
if multiplier > mp_cap:
    raise SystemExit("RTT Normal XP multiplier must be applied before the multiplayer anti-power-level cap")
if 'DIFF_NIGHTMARE' in text or 'DIFF_HELL' in text:
    raise SystemExit("Normal XP patch must not modify Nightmare/Hell")

print("OK: RTT Normal difficulty experience multiplier is 1.5x and preserves the multiplayer cap")
