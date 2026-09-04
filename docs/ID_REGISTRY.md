# Return to Tristram ID registry

Keep custom IDs and codes centralized. Check collisions against every new D2R patch before building.

## Level IDs

| Feature | ID |
|---|---:|
| Worldstone Rift T1 | 139 |

Reserve `140–149` for the first Rift tier family unless Blizzard claims those IDs in a later patch.

## Item codes

| Code | Meaning |
|---|---|
| `dme` | Demonic Essence |
| `rk1` | Worldstone Rift Key T1 |
| `coe` | Corrupted Essence |
| `mh1` | Mythic Charm base #1 |

## Runtime/string identifiers

- Monster ID: `rtt_riftguardian_t1`
- Treasure Class: `RTT Rift Guardian`
- Level internal name: `RTT - Worldstone Rift T1`
- Localization keys use `RTT_` prefix.

## Localization IDs

- `61000–61099`: item strings
- `61100–61199`: monster strings
- `61200–61299`: level strings

These numeric localization IDs are an SDK convention, not a claim that Blizzard permanently reserves this range. The preflight checks string-key collisions; review numeric ID collisions too if your local string tables have grown into this range.
