// Run ad-hoc SQL against the local database.
// Unqualified names resolve against volume 1 unless --vol is given;
// any table can always be qualified, e.g. v2.some_table.
// Usage: npm run sql -- "select * from party"
//        npm run sql -- --vol 2 "select * from party"
//        npm run sql -- path/to/file.sql
import { readFileSync } from 'node:fs';
import { openDb, resolveTarget, searchPathFor, printResult, existsSync } from './db.js';

const args = process.argv.slice(2);
let vol = 'v1';
const volFlag = args.indexOf('--vol');
if (volFlag !== -1) [, vol] = args.splice(volFlag, 2);

const arg = args.join(' ');
if (!arg) {
  console.error('Usage: npm run sql -- [--vol N] "<sql>" | <file.sql>');
  process.exit(1);
}

const sql = arg.endsWith('.sql') && existsSync(arg) ? readFileSync(arg, 'utf8') : arg;
const db = openDb();
try {
  await db.exec(searchPathFor(resolveTarget(vol).volume));
  for (const result of await db.exec(sql)) printResult(result);
} catch (err) {
  console.error(err.message);
  process.exitCode = 1;
}
await db.close();
