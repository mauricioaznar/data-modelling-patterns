// Run ad-hoc SQL against the local database.
// Usage: npm run sql -- "select * from party"
//        npm run sql -- path/to/file.sql
import { readFileSync } from 'node:fs';
import { openDb, printResult, existsSync } from './db.js';

const arg = process.argv.slice(2).join(' ');
if (!arg) {
  console.error('Usage: npm run sql -- "<sql>" | <file.sql>');
  process.exit(1);
}

const sql = arg.endsWith('.sql') && existsSync(arg) ? readFileSync(arg, 'utf8') : arg;
const db = openDb();
try {
  for (const result of await db.exec(sql)) printResult(result);
} catch (err) {
  console.error(err.message);
  process.exitCode = 1;
}
await db.close();
