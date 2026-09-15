#!/usr/bin/env python3
"""Phase 4 gate: require real engine test evidence; missing/skipped tests fail closed."""
from pathlib import Path
import argparse
import json
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = {
    'LegacyNoMarker', 'RareEveryCountAndTier', 'FreshDropsNamedAndRareCounts',
    'UniqueRoundTrip', 'SetPieceRoundTripEquipUnequip',
    'CraftRecipesAndFailureAtomicity', 'NecromancerCreateUnlockSaveChoices',
    'NormalXpMultiplierOnly', 'ArmorUpgradeReducesDamage',
}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--results', type=Path, required=True, help='GoogleTest XML emitted by the patched C++ engine')
    args = parser.parse_args()
    if not args.results.is_file():
        raise SystemExit('Missing Phase 4 engine evidence; completion is not established')
    document = ET.parse(args.results).getroot()
    cases = {case.attrib['name']: case for case in document.iter('testcase') if case.attrib.get('classname') == 'RttPhase4'}
    missing = REQUIRED - cases.keys()
    if missing:
        raise SystemExit(f'Missing Phase 4 contracts: {sorted(missing)}')
    for name in REQUIRED:
        case = cases[name]
        if any(case.find(tag) is not None for tag in ('failure','error','skipped')) or case.attrib.get('status') != 'run':
            raise SystemExit(f'Phase 4 contract did not pass: {name}')
    affixes = json.loads((ROOT/'Data/itemization/affixes.json').read_text())
    sets = json.loads((ROOT/'Data/itemization/sets.json').read_text())['entries']
    pieces = sets[0]['pieces']
    assert len({piece['stableId'] for piece in pieces}) == 2
    assert {piece['identityCode'] for piece in pieces} == {61,62}
    assert {piece['identityCode']:piece['stableId'] for piece in pieces} == {piece['identityCode']:piece['stableId'] for piece in reversed(pieces)}
    assert max(a['compactCode'] for a in affixes['entries']) < 60
    schema = json.loads((ROOT/'config/save-schema.json').read_text())
    assert schema['binaryProgressionProjection']['size'] == 20
    assert json.loads((ROOT/'config/network-policy.json').read_text())['protocolVersion'] == 2
    print(f'OK: {len(REQUIRED)} Phase 4 C++ engine contracts passed; no skipped tests')

if __name__ == '__main__':
    main()
