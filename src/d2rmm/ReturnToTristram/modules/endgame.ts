import { blankRow, findRow, readTsv, requireRow, setKnown, upsertLocalization, writeTsv } from './tsv';

const CUBE = 'global\\excel\\cubemain.txt';
const LEVELS = 'global\\excel\\levels.txt';
const MAZE = 'global\\excel\\lvlmaze.txt';
const LEVEL_STRINGS = 'local\\lng\\strings\\levels.json';

function upsertRecipe(table: any, description: string, patch: Record<string, string | number | boolean>): void {
  let row = findRow(table, 'description', description);
  if (!row) {
    row = blankRow(table);
    table.rows.push(row);
  }
  setKnown(table, row, { description, enabled: 1, version: 100, ...patch, '*eol': 0 });
}

function patchLevelTable(api: any, path: string): void {
  const levels = readTsv(api, path);
  const occupied = findRow(levels, 'Id', '139');
  if (occupied && occupied.Name !== 'RTT - Worldstone Rift T1') {
    throw new Error(`Return to Tristram: level ID 139 is occupied by ${occupied.Name || 'another level'}.`);
  }

  let rift = occupied;
  if (!rift) {
    rift = { ...requireRow(levels, 'Id', '125') }; // Abaddon / Act 5 - Hell 1
    levels.rows.push(rift);
  }
  setKnown(levels, rift, {
    Name: 'RTT - Worldstone Rift T1',
    '*StringName': 'RTT_WorldstoneRiftT1',
    Id: 139,
    Layer: 139,
    Act: 4,
    'MonLvl(H)': 95,
    'MonLvlEx(H)': 95,
    cmon1: 'rtt_riftguardian_t1',
    cpct1: 100,
    camt1: 1,
    cmon2: '', cmon3: '', cmon4: '',
    cpct2: 0, cpct3: 0, cpct4: 0,
    camt2: 0, camt3: 0, camt4: 0,
    LevelName: 'RTT_WorldstoneRiftT1',
    LevelEntry: 'RTT_EnteringWorldstoneRiftT1',
    PreventTownPortal: 0,
  });
  writeTsv(api, path, levels);
}

export function applyEndgame(api: any, enableDevShortcut: boolean): void {
  const cube = readTsv(api, CUBE);

  upsertRecipe(cube, 'RTT - Demonic Essence to Rift Key T1', {
    'min diff': 2,
    numinputs: 4,
    'input 1': 'dme,qty=3',
    'input 2': 'tsc',
    output: 'rk1',
  });

  upsertRecipe(cube, 'RTT - Open Worldstone Rift T1', {
    'min diff': 2,
    numinputs: 2,
    'input 1': 'rk1',
    'input 2': 'tsc',
    output: 'Red Portal,lvl=139',
  });

  upsertRecipe(cube, 'RTT - Corrupted Essence to Heart of Tristram', {
    'min diff': 0,
    numinputs: 2,
    'input 1': 'coe',
    'input 2': 'skz',
    output: 'mh1,uni',
  });

  upsertRecipe(cube, 'RTT DEV - Scrolls to Rift Key T1', {
    enabled: enableDevShortcut ? 1 : 0,
    'min diff': 0,
    numinputs: 2,
    'input 1': 'tsc',
    'input 2': 'isc',
    output: 'rk1',
  });
  writeTsv(api, CUBE, cube);

  patchLevelTable(api, LEVELS);

  // Current D2R/D2RMM builds may also expose base/levels.txt. If present, keep it synchronized.
  try {
    patchLevelTable(api, 'global\\excel\\base\\levels.txt');
  } catch (error) {
    console.warn('[Return to Tristram] base/levels.txt not patched: ' + String(error));
  }

  const maze = readTsv(api, MAZE);
  let riftMaze = findRow(maze, 'Level', '139');
  if (!riftMaze) {
    riftMaze = { ...requireRow(maze, 'Level', '125') };
    maze.rows.push(riftMaze);
  }
  setKnown(maze, riftMaze, {
    Name: 'RTT - Worldstone Rift T1',
    Level: 139,
    'Rooms(H)': 8,
  });
  writeTsv(api, MAZE, maze);

  upsertLocalization(api, LEVEL_STRINGS, 61200, 'RTT_WorldstoneRiftT1', 'Worldstone Rift — Tier I', 'Szczelina Kamienia Świata — Poziom I');
  upsertLocalization(api, LEVEL_STRINGS, 61201, 'RTT_EnteringWorldstoneRiftT1', 'Entering Worldstone Rift — Tier I', 'Wkraczasz do Szczeliny Kamienia Świata — Poziom I');
}
