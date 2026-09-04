// Reconstructed from the surviving v0.2.0 manifest, ID registry and T1 vertical-slice specification.
// This is a clean-room reconstruction, not a byte-for-byte recovery of the lost archive.

import { diagnostics } from './modules/diagnostics';
import { applyItems } from './modules/items';
import { applyMonsters } from './modules/monsters';
import { applyEndgame } from './modules/endgame';

diagnostics(D2RMM);
applyItems(D2RMM);
applyMonsters(D2RMM);
applyEndgame(D2RMM, config.enableDevShortcut !== false);

console.log('[Return to Tristram] reconstructed v0.2.0 vertical slice installed.');
