# RTT Loot Filter 2.0

The Return to Tristram loot filter is a presentation-only ground-label filter. It never changes drops, RNG, item data, pickup eligibility, save data or multiplayer state.

## Presets

User configuration lives in `packaging/mod/lua/mods/rtt/qol/loot_filter_config.lua`.

Three built-in presets are available:

- `permissive` — shows all normal equipment labels;
- `balanced` — hides low-value normal weapons/armor below 200 gold while keeping jewelry visible;
- `strict` — raises normal-equipment thresholds to reduce label clutter later in progression.

An unknown preset safely falls back to `balanced`.

## User rules

`normalValueOverrides` can override the preset threshold independently for weapons, armor, jewelry and fallback equipment.

`alwaysShowNames` forces an exact translated item name to remain visible.

`hideNormalNames` suppresses an exact translated name only when the item is normal equipment. It cannot suppress magic/unique items, gold, consumables, quest/misc items or other non-equipment.

## Safety invariants

The filter returns only a show/hide decision to RTT's `ShouldShowItemLabel` presentation hook. A hidden label does not remove the item from the world and does not make it unpickable.

Magic and unique items always remain visible in Loot Filter 2.0. Gold, usable items and non-equipment also always remain visible. These invariants are deliberate until RTT itemisation introduces additional stable quality/content semantics.

## Runtime acceptance

Drop or place a mixture of cheap normal equipment, valuable normal equipment, magic/unique items, gold and consumables. Verify that the selected preset changes only normal-equipment labels; every item must remain present and pickable. Then edit the config to test one `alwaysShowNames` entry and one `hideNormalNames` entry and restart the game/mod so the Lua configuration is reloaded.
