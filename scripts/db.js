import { PGlite } from '@electric-sql/pglite';
import { readdirSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

export const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
export const DATA_DIR = join(ROOT, '.pgdata');
export const VOLUMES_DIR = join(ROOT, 'volumes');

const DATE_OID = 1082;
const TIMESTAMP_OID = 1114;
const TIMESTAMPTZ_OID = 1184;

export function openDb() {
  // Keep date/time columns as the strings Postgres prints instead of JS Date objects.
  const asText = (value) => value;
  return new PGlite(DATA_DIR, {
    parsers: { [DATE_OID]: asText, [TIMESTAMP_OID]: asText, [TIMESTAMPTZ_OID]: asText },
  });
}

function subdirs(dir, pattern) {
  return readdirSync(dir, { withFileTypes: true })
    .filter((d) => d.isDirectory() && pattern.test(d.name))
    .map((d) => d.name)
    .sort();
}

// Volume folders are "vN-slug"; each volume gets its own Postgres schema "vN"
// so the same table name can exist in several books without clashing.
export function listVolumes() {
  return subdirs(VOLUMES_DIR, /^v\d-/).map((dir) => ({
    dir,
    schema: dir.slice(0, 2),
    path: join(VOLUMES_DIR, dir),
  }));
}

// Chapter folders are "NN-slug" and load in numeric order, because later
// chapters reference tables from earlier ones (everything hangs off PARTY).
export function listChapters(volume) {
  return subdirs(volume.path, /^\d{2}-/).map((dir) => ({
    dir,
    number: dir.slice(0, 2),
    path: join(volume.path, dir),
  }));
}

// Session settings for working in a volume. Unqualified names resolve in its
// own schema first, then in earlier volumes (Vol 2's industry models extend
// Vol 1's tables), and timestamps print in UTC so results don't depend on the
// machine's time zone.
export function sessionSetupFor(volume) {
  const schemas = listVolumes()
    .map((v) => v.schema)
    .filter((s) => s <= volume.schema)
    .reverse();
  return `set search_path to ${schemas.join(', ')}, public; set time zone 'UTC';`;
}

// Parse "v1", "v1/02" or "1/2" into { volume, chapter? }.
export function resolveTarget(arg) {
  const m = /^v?(\d)(?:\/(\d{1,2}))?$/.exec(arg ?? '');
  if (!m) throw new Error(`Expected "v1" or "v1/02", got "${arg}"`);
  const volume = listVolumes().find((v) => v.schema === `v${m[1]}`);
  if (!volume) throw new Error(`No volume v${m[1]} under volumes/`);
  if (!m[2]) return { volume };
  const number = m[2].padStart(2, '0');
  const chapter = listChapters(volume).find((c) => c.number === number);
  if (!chapter) throw new Error(`No chapter ${number} in ${volume.dir}`);
  return { volume, chapter };
}

export function printResult(result) {
  if (result.fields.length === 0) {
    if (result.affectedRows) console.log(`(${result.affectedRows} rows affected)`);
    return;
  }
  if (result.rows.length === 0) console.log('(no rows)');
  else console.table(result.rows);
}

export { existsSync };
