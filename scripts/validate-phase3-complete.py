#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

required_files = [
    'Engine/patches/0003-rtt-classic-plus-visual-store-default.patch',
    'Engine/patches/0004-rtt-item-comparison-tooltip.patch',
    'Engine/patches/0005-rtt-weapon-swap.patch',
    'scripts/validate-classic-plus.py',
    'scripts/validate-loot-filter.py',
    'scripts/validate-item-tooltip.py',
    'scripts/validate-weapon-swap.py',
    'scripts/phase3-acceptance-evidence.ps1',
    'docs/PHASE3_CLASSIC_PLUS.md',
    'docs/PHASE3_RUNTIME_ACCEPTANCE.md',
    'docs/PHASE3_WEAPON_SWAP.md',
    'docs/ROADMAP.md',
    'docs/PROJECT_STATUS.md',
    'README.md',
    'VERSION',
]

missing = [path for path in required_files if not (ROOT / path).is_file()]
if missing:
    raise SystemExit('Phase 3 completion files missing: ' + ', '.join(missing))

version = (ROOT / 'VERSION').read_text(encoding='utf-8').strip()
if version != '0.1.0-dev':
    raise SystemExit(f'Phase 3 manual runtime acceptance is pending; VERSION must remain 0.1.0-dev, found {version!r}')

roadmap = (ROOT / 'docs/ROADMAP.md').read_text(encoding='utf-8')
status = (ROOT / 'docs/PROJECT_STATUS.md').read_text(encoding='utf-8')
readme = (ROOT / 'README.md').read_text(encoding='utf-8')
classic = (ROOT / 'docs/PHASE3_CLASSIC_PLUS.md').read_text(encoding='utf-8')
acceptance = (ROOT / 'docs/PHASE3_RUNTIME_ACCEPTANCE.md').read_text(encoding='utf-8')
collector = (ROOT / 'scripts/phase3-acceptance-evidence.ps1').read_text(encoding='utf-8')
weapon = (ROOT / 'Engine/patches/0005-rtt-weapon-swap.patch').read_text(encoding='utf-8')

required_roadmap = [
    'Phase 3 — Classic+ — ENGINEERING COMPLETE / MANUAL RUNTIME ACCEPTANCE PENDING',
    '[x] Alternate weapon set / weapon swap with versioned RTT persistence',
    '[x] Advanced RTT item comparison tooltip',
    '[x] Loot filter 2.0 with user-configurable rules/presets',
    '[ ] Full Classic+ Windows/controller/multiplayer/campaign runtime regression pass',
]
for token in required_roadmap:
    if token not in roadmap:
        raise SystemExit(f'ROADMAP Phase 3 contract missing: {token}')

required_status = [
    'Phase 3 — Classic+:** ENGINEERING COMPLETE / MANUAL RUNTIME ACCEPTANCE PENDING',
    'Phase 4 — Itemisation, skills and classes:** next engineering phase',
    'The development version therefore remains `0.1.0-dev`',
]
for token in required_status:
    if token not in status:
        raise SystemExit(f'PROJECT_STATUS Phase 3 contract missing: {token}')

if 'Phase 3 is **runtime accepted**' in status or 'Phase 3 — Classic+:** COMPLETE' in status:
    raise SystemExit('PROJECT_STATUS must not claim Phase 3 runtime acceptance before real-PC evidence exists')

required_readme = [
    'the engineering scope of Phase 3 are complete',
    'Phase 1 and Phase 3 still require real-machine runtime acceptance',
    'persistent alternate weapon set / weapon swap',
]
for token in required_readme:
    if token not in readme:
        raise SystemExit(f'README Phase 3 status missing: {token}')

for token in [
    'Phase 3 is **engineering complete**',
    'Phase 3 is **runtime accepted** only after a real Windows run',
    'generated RTT itemisation belongs to Phase 4',
]:
    if token not in classic:
        raise SystemExit(f'PHASE3_CLASSIC_PLUS contract missing: {token}')

for token in [
    'visual-grid store',
    'Loot Filter 2.0',
    'weapon set 2 active',
    'Back/Select + Y',
    'two-client RTT multiplayer game',
    'original campaign regression path through Diablo',
    'passed: true',
]:
    if token not in acceptance:
        raise SystemExit(f'Phase 3 runtime acceptance checklist missing: {token}')

for token in [
    'phase3-$Timestamp.json',
    'weaponSwapKeyboard',
    'weaponSwapController',
    'weaponSwapSaveReload',
    'multiplayerWeaponSync',
    'campaignRegression',
    '$Result.passed = $Passed',
]:
    if token not in collector:
        raise SystemExit(f'Phase 3 evidence collector missing: {token}')

for token in [
    'RttAlternateWeaponSet[2]',
    'RttWeaponSetVersion = 1',
    'rtt_weapon_set',
    'GetActiveModSaveExtension() == "rtt"',
    'ControllerButton_BUTTON_BACK, ControllerButton_BUTTON_Y',
]:
    if token not in weapon:
        raise SystemExit(f'Weapon swap final patch missing: {token}')

if 'struct PlayerPack' in weapon or 'PlayerPack Rtt' in weapon:
    raise SystemExit('Weapon swap must not extend PlayerPack')

print('OK: Phase 3 Classic+ engineering-completion contract')
