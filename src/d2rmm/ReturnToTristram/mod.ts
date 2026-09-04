// RECONSTRUCTED from the v0.2.0 file manifest and surviving vertical-slice specification.
// Compare against the original archive if it becomes available.

import { applyItems } from './modules/items';
import { applyMonsters } from './modules/monsters';
import { applyEndgame } from './modules/endgame';
import { diagnostics } from './modules/diagnostics';

export default function mod({ D2RMM }: any) {
  diagnostics(D2RMM);
  applyItems(D2RMM);
  applyMonsters(D2RMM);
  applyEndgame(D2RMM);
}
