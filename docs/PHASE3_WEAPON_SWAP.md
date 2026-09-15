# Phase 3 — Classic+ weapon swap

RTT adds a Diablo-II-style alternate weapon set without changing DevilutionX `PlayerPack`.

## Runtime model

- `InvBody[INVLOC_HAND_LEFT/RIGHT]` remains the authoritative active equipment pair.
- `Player::RttAlternateWeaponSet[2]` stores the inactive main/off-hand pair.
- `Player::RttActiveWeaponSet` records whether set 1 or set 2 is currently active.
- Swapping exchanges both hand slots atomically and recalculates player inventory-derived stats.
- The active hand pair is synchronized with the existing `NetSendCmdChItem` messages, so peers only need to know the currently equipped set.
- Swapping is rejected while the cursor is holding an item.

## Controls

- Keyboard default: `W`.
- Controller default: `Back/Select + Y`.
- Both bindings remain remappable through the existing DevilutionX key/pad mapper.

## Save compatibility

The alternate pair is stored in a separate encoded save-archive entry named `rtt_weapon_set`.

Version 1 contains:

1. format version,
2. Diablo/Hellfire item-format flag,
3. active set index,
4. two packed items using the existing `ItemPack`/`PackItem` representation.

The feature is only saved/loaded when the active mod save extension is `rtt`. Existing `.rtt` characters that predate this feature have no `rtt_weapon_set` entry; loading such a character simply starts with an empty alternate set and active set 1. This deliberately avoids changing the binary size/layout of `PlayerPack`.

Future generated RTT affixes/rarities must follow the broader RTT save-migration policy before relying on seeded `ItemPack` recreation for new item systems.

## Manual acceptance pending

The engineering gate is compile/package CI. Final runtime acceptance on Windows should later verify:

- equip one-hand + shield, swap to empty set and back,
- equip a two-hand weapon and swap both directions,
- save with set 2 active, quit, reload, and recover both sets,
- controller `Back/Select + Y`,
- two-client multiplayer visibility of the active equipped pair.
