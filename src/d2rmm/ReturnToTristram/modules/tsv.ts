export type Row = Record<string, string>;
export type TsvTable = { headers: string[]; rows: Row[] };

const LANGS = ['enUS', 'zhTW', 'deDE', 'esES', 'frFR', 'itIT', 'koKR', 'plPL', 'esMX', 'jaJP', 'ptBR', 'ruRU', 'zhCN'];

export function readTsv(api: any, path: string): TsvTable {
  return api.readTsv(path, { removeCarriageReturns: true }) as TsvTable;
}

export function writeTsv(api: any, path: string, table: TsvTable): void {
  api.writeTsv(path, table, { addCarriageReturns: true });
}

export function findRow(table: TsvTable, column: string, value: string): Row | undefined {
  return table.rows.find((row) => String(row[column] ?? '') === String(value));
}

export function findRowAny(table: TsvTable, columns: string[], value: string): Row | undefined {
  for (const column of columns) {
    if (!table.headers.includes(column)) continue;
    const row = findRow(table, column, value);
    if (row) return row;
  }
  return undefined;
}

export function requireRow(table: TsvTable, column: string, value: string): Row {
  const row = findRow(table, column, value);
  if (!row) throw new Error(`Return to Tristram: required row not found: ${column}=${value}`);
  return row;
}

export function requireRowAny(table: TsvTable, columns: string[], value: string): Row {
  const row = findRowAny(table, columns, value);
  if (!row) throw new Error(`Return to Tristram: required row not found: ${columns.join('|')}=${value}`);
  return row;
}

export function cloneRow(row: Row): Row {
  return { ...row };
}

export function blankRow(table: TsvTable): Row {
  const row: Row = {};
  for (const header of table.headers) row[header] = '';
  if (table.headers.includes('*eol')) row['*eol'] = '0';
  return row;
}

export function setKnown(table: TsvTable, row: Row, patch: Record<string, string | number | boolean>): Row {
  for (const [key, value] of Object.entries(patch)) {
    if (table.headers.includes(key)) row[key] = String(value);
  }
  return row;
}

export function nextNumericId(table: TsvTable, column: string): number {
  let max = 0;
  for (const row of table.rows) {
    const value = Number(row[column]);
    if (Number.isFinite(value) && value > max) max = value;
  }
  return max + 1;
}

export function ensureCloneByCode(
  table: TsvTable,
  sourceCode: string,
  targetCode: string,
  expectedNameStr: string,
  patch: Record<string, string | number | boolean>,
): Row {
  let target = findRow(table, 'code', targetCode);
  if (target) {
    if (table.headers.includes('namestr') && target.namestr !== expectedNameStr) {
      throw new Error(`Return to Tristram: item code collision: ${targetCode}`);
    }
  } else {
    const source = requireRow(table, 'code', sourceCode);
    target = cloneRow(source);
    table.rows.push(target);
  }
  setKnown(table, target, { ...patch, code: targetCode, namestr: expectedNameStr });
  return target;
}

export function upsertLocalization(
  api: any,
  path: string,
  id: number,
  key: string,
  enUS: string,
  plPL: string,
): void {
  const data = api.readJson(path) as any[];
  const byKey = data.find((entry) => entry.Key === key);
  const byId = data.find((entry) => Number(entry.id) === id);

  if (byId && byId.Key !== key) {
    throw new Error(`Return to Tristram: localization ID collision in ${path}: ${id} belongs to ${byId.Key}`);
  }

  const entry = byKey || { id, Key: key };
  if (!byKey) data.push(entry);
  entry.id = id;
  entry.Key = key;
  for (const lang of LANGS) entry[lang] = lang === 'plPL' ? plPL : enUS;
  api.writeJson(path, data);
}
