import { PGlite } from '@electric-sql/pglite';
import { readdirSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

export const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
export const DATA_DIR = join(ROOT, '.pgdata');
export const CHAPTERS_DIR = join(ROOT, 'chapters');

export function openDb() {
  return new PGlite(DATA_DIR);
}

// Chapter folders are named "NN-slug"; they load in numeric order because
// later chapters reference tables from earlier ones (everything hangs off PARTY).
export function listChapters() {
  return readdirSync(CHAPTERS_DIR, { withFileTypes: true })
    .filter((d) => d.isDirectory() && /^\d{2}-/.test(d.name))
    .map((d) => d.name)
    .sort();
}

// Resolve "02" or "02-people-and-organizations" to the chapter folder.
export function resolveChapter(arg) {
  const match = listChapters().find((c) => c === arg || c.startsWith(`${arg}-`));
  if (!match) throw new Error(`No chapter matching "${arg}". Have: ${listChapters().join(', ')}`);
  return join(CHAPTERS_DIR, match);
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
