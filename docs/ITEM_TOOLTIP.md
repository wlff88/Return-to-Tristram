# RTT advanced item comparison tooltip

Classic+ enables DevilutionX's floating item information box and extends identified equipment tooltips with a save-neutral comparison against currently equipped gear.

## Comparison rules

RTT selects the relevant equipped slot from the candidate item type:

- weapon -> left hand;
- shield -> right hand;
- helm -> head;
- body armor -> chest;
- amulet -> amulet slot;
- ring -> the first other equipped ring.

If no comparable item is equipped, no comparison lines are added.

## Displayed deltas

When applicable, the tooltip adds:

- equipped item name;
- weapon minimum/maximum damage delta;
- armor-class delta;
- Strength/Magic/Dexterity/Vitality bonus deltas;
- Fire/Lightning/Magic resistance deltas.

Positive and negative values are shown explicitly so the user can make a quick equipment decision without manually subtracting stats.

## Compatibility

This feature is presentation-only. It reads the candidate and equipped `Item` objects and appends text to the existing info box. It does not mutate inventory, item generation, RNG, serialized item fields or network state.

The first version intentionally compares raw item contributions rather than attempting a full damage-per-second or effective-defense model. Later itemisation systems can extend the comparison after their stable IDs and affix semantics exist.

## Runtime acceptance

Hover identified inventory/vendor/stash equipment while a comparable item is equipped. Confirm that the correct equipped item is named and damage/armor/stat/resistance deltas are sensible. Verify no comparison appears for consumables, gold or equipment slots with no current item.
