# Classic+ QoL audit

This audit records which Phase 3 usability features already exist in the pinned DevilutionX baseline and therefore should be reused rather than reimplemented in RTT.

## Controller-first interaction

The pinned visual store initializes controller focus when opened and has dedicated grid navigation in the player-controller code. Inventory, stash and store panels therefore share the upstream controller navigation model.

Runtime controller acceptance is still required before Classic+ can be called complete; this source audit only establishes that RTT does not need a second input system.

## Inventory and stash transfer

DevilutionX already implements quick inventory/stash movement: when the stash is open, Ctrl-click transfers an inventory item to the stash. Stash code contains the inverse automatic-move path.

RTT keeps these native semantics for Classic+ instead of adding a second transfer protocol. This remains save/network-neutral because the actual item movement uses existing inventory/stash operations.

## Gold handling

Classic+ enables native `Auto Gold Pickup` by default.

RTT deliberately keeps the Diablo gold-pile cap at the pinned baseline value (`GOLD_MAX_LIMIT = 5000`) for now. Gold is serialized through a 16-bit packed value, and Hellfire applies additional max-gold behavior. A larger stack cap would therefore be a gameplay/compatibility change rather than a purely cosmetic QoL toggle and is deferred until it has explicit save/network regression coverage.

## Vendor UI

The native visual store is used as the Classic+ base: 10x9 icon grid, paging, Smith regular/premium tabs, repair, buy/sell, inventory shown alongside the store and controller focus. RTT art-direction polish may alter presentation later without replacing vendor stock or transaction logic.

## Decision summary

- reuse native visual-grid store;
- reuse native controller navigation;
- reuse native stash transfer operations;
- enable native auto-gold;
- preserve 5000 gold stack cap during the current Classic+ compatibility line;
- reserve new engine state for features that genuinely do not exist upstream, such as a true alternate weapon set.
