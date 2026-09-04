import { ensureCloneByCode, findRow, nextNumericId, readTsv, setKnown, upsertLocalization, writeTsv } from './tsv';

const MISC = 'global\\excel\\misc.txt';
const UNIQUES = 'global\\excel\\uniqueitems.txt';
const ITEM_STRINGS = 'local\\lng\\strings\\item-names.json';

function clearUniqueProperties(row: Record<string, string>): void {
  for (let i = 1; i <= 12; i += 1) {
    row[`prop${i}`] = '';
    row[`par${i}`] = '';
    row[`min${i}`] = '';
    row[`max${i}`] = '';
  }
}

export function applyItems(api: any): void {
  const misc = readTsv(api, MISC);

  // Pandemonium Key is a safe one-cell misc-item anchor for the three materials/key.
  ensureCloneByCode(misc, 'pk1', 'dme', 'RTT_DemonicEssence', {
    name: 'Demonic Essence', spawnable: 1, quest: 0, questdiffcheck: 0,
  });
  ensureCloneByCode(misc, 'pk1', 'rk1', 'RTT_RiftKeyT1', {
    name: 'Worldstone Rift Key - Tier I', spawnable: 1, quest: 0, questdiffcheck: 0,
  });
  ensureCloneByCode(misc, 'pk1', 'coe', 'RTT_CorruptedEssence', {
    name: 'Corrupted Essence', spawnable: 1, quest: 0, questdiffcheck: 0,
  });
  ensureCloneByCode(misc, 'cm1', 'mh1', 'RTT_MythicCharmBase', {
    name: 'Mythic Charm', spawnable: 0,
  });
  writeTsv(api, MISC, misc);

  const uniques = readTsv(api, UNIQUES);
  let heart = findRow(uniques, 'index', 'RTT_HeartOfTristram');
  if (!heart) {
    const annihilus = findRow(uniques, 'index', 'Annihilus');
    if (!annihilus) throw new Error('Return to Tristram: Annihilus unique anchor not found.');
    heart = { ...annihilus };
    uniques.rows.push(heart);
  }

  clearUniqueProperties(heart);
  setKnown(uniques, heart, {
    index: 'RTT_HeartOfTristram',
    '*ID': nextNumericId(uniques, '*ID'),
    disabled: 0,
    spawnable: 1,
    nolimit: 0,
    carry1: 1,
    code: 'mh1',
    '*ItemName': 'Heart of Tristram',
  });
  writeTsv(api, UNIQUES, uniques);

  upsertLocalization(api, ITEM_STRINGS, 61000, 'RTT_DemonicEssence', 'Demonic Essence', 'Demoniczna Esencja');
  upsertLocalization(api, ITEM_STRINGS, 61001, 'RTT_RiftKeyT1', 'Worldstone Rift Key — Tier I', 'Klucz do Szczeliny Kamienia Świata — Poziom I');
  upsertLocalization(api, ITEM_STRINGS, 61002, 'RTT_CorruptedEssence', 'Corrupted Essence', 'Skażona Esencja');
  upsertLocalization(api, ITEM_STRINGS, 61003, 'RTT_MythicCharmBase', 'Mythic Charm', 'Mityczny Talizman');
  upsertLocalization(api, ITEM_STRINGS, 61004, 'RTT_HeartOfTristram', 'Heart of Tristram', 'Serce Tristram');
}
