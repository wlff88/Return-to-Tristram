# Return to Tristram — Classic+

Classic+ keeps the original Diablo I campaign structure and atmosphere while enabling selected modern usability features from the pinned DevilutionX baseline and RTT-specific QoL hooks.

The rule for Phase 3 is simple: prefer an existing, tested DevilutionX implementation when it matches RTT design goals. Add an RTT engine hook only when the required behavior does not already exist upstream.

## Default profile

The canonical profile is `config/classic-plus.ini`. RTT-patched builds use the same defaults at engine level, while every exposed option remains user-overridable.

Enabled by default:

- visual grid store UI;
- run in town;
- quick cast;
- experience bar;
- floating item information box;
- health and mana values;
- monster type display;
- ground item labels;
- automatic belt refill;
- automatic gold pickup.

These are presentation or convenience defaults. They do not change item generation, quest state, deterministic RNG or the RTT save schema.

## Visual vendor inventory

The pinned DevilutionX baseline already contains `qol/visual_store`, including a 10x9 item grid, item icon rendering, Smith basic/premium tabs, paging, repair actions, selling from inventory, mouse interaction and controller navigation.

RTT therefore does not duplicate the vendor implementation. Classic+ selects the native `StoreUi::VisualGrid` mode by default and treats it as the base for later RTT art-direction polish.

Phase 3 vendor acceptance covers Griswold, Adria, Pepin and Wirt where applicable. The existing vendor stock and price logic remains authoritative; RTT changes presentation and interaction first.

No Diablo II art or proprietary assets are used. "Diablo II-style" refers to the visual item-grid interaction model only.

## Advanced item information

Classic+ enables DevilutionX's floating item info box by default. RTT-specific comparison lines, affix tiers and generated-item details belong to later itemisation work and must not be implemented by bypassing the Phase 2 save/content-ID contracts.

## Compatibility boundary

Classic+ defaults are safe to change because they do not add serialized content IDs or new network state.

Features that do cross compatibility boundaries must be implemented separately. In particular, a true alternate weapon-set system needs explicit save representation, deterministic multiplayer synchronization and migration behavior before it can be accepted into Phase 3.

The same rule applies to any balance-safe item additions: existing rows may be adjusted through the sparse TSV pipeline, but new generated content must use the stable RTT ID registry and save/network policies from Phase 2.

## Runtime acceptance

A Phase 3 baseline runtime pass should confirm:

1. RTT is actually loaded and a fresh supported class receives the RTT starter-gold override.
2. Griswold opens the visual item-grid store rather than the legacy text buy list.
3. Adria and Pepin open the visual grid where their store path supports it.
4. Vendor item hover/selection displays item information and price correctly.
5. Buy, sell and Smith repair actions work with mouse/keyboard.
6. The same store can be navigated and used with an Xbox-class controller.
7. Ground item labels and the RTT loot-filter hook still behave correctly.
8. Floating item information, XP bar, HP/MP values, auto-gold and belt refill work without breaking the original campaign.
9. Save/reload and a basic multiplayer connection remain stable.

Passing this baseline does not complete all of Phase 3. Weapon swap, loot-filter 2.0, broader controller UX review and full Classic+ campaign regression remain separate gates.
