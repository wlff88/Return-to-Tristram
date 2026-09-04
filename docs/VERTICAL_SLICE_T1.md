# Worldstone Rift T1 — first playable vertical slice

This SDK version implements the first complete Return to Tristram endgame loop as a **data-only D2R mod prototype**.

## Player loop

```text
Hell Countess
  -> Demonic Essence
  -> 3x Demonic Essence + Town Portal Scroll
  -> Worldstone Rift Key — Tier I
  -> Rift Key + Town Portal Scroll
  -> Red Portal to level ID 139
  -> Worldstone Rift — Tier I
  -> Vharzak, Rift Guardian
  -> Corrupted Essence
  -> Corrupted Essence + Perfect Skull
  -> Heart of Tristram (Mythic Charm)
```

A development shortcut is intentionally enabled:

```text
Town Portal Scroll + Identify Scroll -> Rift Key T1
```

Remove or disable `RTT DEV - Scrolls to Rift Key T1` before a release build.

## Gameplay values in v0.2.0

- Rift level ID: `139`
- Act: V (`Act = 4` in `levels.txt`)
- Rift monster level in Hell: `95`
- Rift layout: procedural Act V hell-portal tiles, based on Abaddon
- Rift size: 8 maze rooms in Hell
- Guardian base: Uber Izual asset/AI family
- Guardian drop: guaranteed `Corrupted Essence` through `RTT Rift Guardian` Treasure Class
- First Mythic: `Heart of Tristram`, a custom small-charm base

The Countess material source is implemented by adding `Demonic Essence` to `Countess Item (H)` with weight 4. With the current Countess item pool and five picks, the practical per-kill chance is intended to be noticeable rather than rare. Balance this only after the loop is proven stable.

## Vanilla files to extract locally

The repository does **not** contain Blizzard data. Extract these files from your own current D2R installation into `vendor/vanilla/data/` preserving paths:

```text
vendor/vanilla/data/
├── global/
│   └── excel/
│       ├── misc.txt
│       ├── uniqueitems.txt
│       ├── cubemain.txt
│       ├── treasureclassex.txt
│       ├── monstats.txt
│       ├── levels.txt
│       └── lvlmaze.txt
└── local/
    └── lng/
        └── strings/
            ├── item-names.json
            ├── monsters.json
            └── levels.json
```

Then run:

```powershell
python scripts/preflight_vertical_slice.py
python scripts/validate_sdk.py
python scripts/test_vertical_slice.py
python scripts/build.py
```

The preflight checks anchor rows, custom item-code collisions, localization-key collisions and whether level ID 139 is still free in your current patch.

## Native build output

```text
dist/ReturnToTristram/ReturnToTristram.mpq/
├── modinfo.json
└── data/
    ├── global/excel/...
    └── local/lng/strings/...
```

Install with `scripts/install.ps1`, then start using:

```text
D2R.exe -mod ReturnToTristram -txt
```

## D2RMM mode

The same vertical-slice logic is mirrored in:

```text
src/d2rmm/ReturnToTristram/
```

The D2RMM version:

- appends the custom misc items,
- appends Heart of Tristram,
- creates the Guardian,
- creates the Treasure Class,
- appends the Cube recipes,
- creates level 139 + its maze definition,
- adds English and Polish localization strings.

Do not install the native patch build and the D2RMM version of the same Return to Tristram feature simultaneously unless you deliberately know how the resulting data merge will behave.

## In-game acceptance test

Static SDK tests are not a substitute for D2R engine testing. Test in this order with backed-up saves:

1. Launch a new isolated Return to Tristram save.
2. Verify `Town Portal Scroll + Identify Scroll` creates `Worldstone Rift Key — Tier I`.
3. In Hell, transmute Rift Key + Town Portal Scroll in town.
4. Confirm a red portal is created and enters `Worldstone Rift — Tier I`.
5. Confirm the procedural level generates without missing tiles, crash or black rooms.
6. Confirm Town Portal can be opened inside the Rift and can be used to escape.
7. Confirm `Vharzak, Rift Guardian` appears exactly once or at least once as intended by the special-monster slot.
8. Kill Vharzak and confirm `Corrupted Essence` drops.
9. Transmute `Corrupted Essence + Perfect Skull` and confirm `Heart of Tristram` is created.
10. Save, exit and reload. Verify the Rift reward survives inventory/shared-stash transfer.
11. Kill Hell Countess repeatedly and confirm `Demonic Essence` can drop.
12. Run D2RLint and record only new Return to Tristram errors, if any.

### First likely runtime tuning point

The Guardian is placed through `cmon1/cpct1/camt1` in `levels.txt`. This is deliberately isolated so it can be replaced with a preset DS1 object or a super-unique placement later if engine behavior is not deterministic enough.

## Why Red Portal

Current D2R CubeMain supports a `Red Portal` output that directly targets a `levels.txt` ID. This lets Return to Tristram add a separate Act V endgame level instead of replacing the Cow Level or Uber Tristram.

## Next milestone after this works

Do not add T2 until the T1 acceptance test is clean. Then generalize:

```text
Rift definition
  -> tier config
  -> level ID allocator
  -> monster scaling
  -> material scaling
  -> guardian TC scaling
  -> T1..T5
```
