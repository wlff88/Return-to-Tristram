import { findRow, findRowAny, readTsv, requireRow, requireRowAny, setKnown, upsertLocalization, writeTsv } from './tsv';

const MONSTATS = 'global\\excel\\monstats.txt';
const TC = 'global\\excel\\treasureclassex.txt';
const MONSTER_STRINGS = 'local\\lng\\strings\\monsters.json';

function setGuardianTreasureClass(table: { headers: string[] }, row: Record<string, string>): void {
  for (const header of table.headers) {
    if (/^TreasureClass/i.test(header)) row[header] = 'RTT Rift Guardian';
  }
}

export function applyMonsters(api: any): void {
  const tc = readTsv(api, TC);
  let guardianTc = findRow(tc, 'Treasure Class', 'RTT Rift Guardian');
  if (!guardianTc) {
    guardianTc = { ...requireRow(tc, 'Treasure Class', 'Countess Item (H)') };
    tc.rows.push(guardianTc);
  }
  setKnown(tc, guardianTc, {
    'Treasure Class': 'RTT Rift Guardian', Picks: 1, NoDrop: 0,
  });
  for (let i = 1; i <= 10; i += 1) {
    if (tc.headers.includes(`Item${i}`)) guardianTc[`Item${i}`] = '';
    if (tc.headers.includes(`Prob${i}`)) guardianTc[`Prob${i}`] = '';
  }
  guardianTc.Item1 = 'coe';
  guardianTc.Prob1 = '1';

  const countess = requireRow(tc, 'Treasure Class', 'Countess Item (H)');
  let materialSlot = 0;
  for (let i = 1; i <= 10; i += 1) {
    if (countess[`Item${i}`] === 'dme') {
      materialSlot = i;
      break;
    }
    if (!materialSlot && !countess[`Item${i}`]) materialSlot = i;
  }
  if (!materialSlot) throw new Error('Return to Tristram: no free Countess Item (H) treasure-class slot.');
  countess[`Item${materialSlot}`] = 'dme';
  countess[`Prob${materialSlot}`] = '4';
  writeTsv(api, TC, tc);

  const monstats = readTsv(api, MONSTATS);
  let guardian = findRowAny(monstats, ['Id', 'id'], 'rtt_riftguardian_t1');
  if (!guardian) {
    guardian = { ...requireRowAny(monstats, ['Id', 'id'], 'uberizual') };
    monstats.rows.push(guardian);
  }
  setKnown(monstats, guardian, {
    Id: 'rtt_riftguardian_t1', id: 'rtt_riftguardian_t1',
    NameStr: 'RTT_Vharzak', DescStr: 'RTT_Vharzak',
    boss: 1, killable: 1,
    'Level(H)': 95,
  });
  setGuardianTreasureClass(monstats, guardian);
  writeTsv(api, MONSTATS, monstats);

  upsertLocalization(api, MONSTER_STRINGS, 61100, 'RTT_Vharzak', 'Vharzak, Rift Guardian', 'Vharzak, Strażnik Szczeliny');
}
