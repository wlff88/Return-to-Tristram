#!/usr/bin/env python3
from pathlib import Path

patch = Path('Engine/patches/0005-rtt-weapon-swap.patch')
doc = Path('docs/PHASE3_WEAPON_SWAP.md')

if not patch.is_file():
    raise SystemExit('missing weapon swap engine patch')
if not doc.is_file():
    raise SystemExit('missing weapon swap documentation')

text = patch.read_text(encoding='utf-8')
required = [
    'RttAlternateWeaponSet[2]',
    'RttActiveWeaponSet',
    'bool SwapWeaponSet(Player &player)',
    'rtt_weapon_set',
    'RttWeaponSetVersion = 1',
    'SaveRttWeaponSet',
    'LoadRttWeaponSet',
    'PackItem(packedItem, item, gbIsHellfire)',
    'UnPackItem(packedItem, player, item, isHellfireSave)',
    'GetActiveModSaveExtension() == "rtt"',
    'NetSendCmdDelItem(false, location)',
    'NetSendCmdChItem(false, location, true)',
    'syncHand(INVLOC_HAND_LEFT)',
    'syncHand(INVLOC_HAND_RIGHT)',
    '"WeaponSwap"',
    "'W'",
    'ControllerButton_BUTTON_BACK, ControllerButton_BUTTON_Y',
]
missing = [token for token in required if token not in text]
if missing:
    raise SystemExit('weapon swap patch contract missing: ' + ', '.join(missing))

if 'struct PlayerPack' in text:
    raise SystemExit('weapon swap patch must not extend PlayerPack')

print('OK: RTT weapon swap save/network/input contract')
