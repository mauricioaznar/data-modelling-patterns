// Wipes the local database and replays every chapter's schema.sql then seed.sql,
// volume by volume. Each volume loads into its own Postgres schema (v1, v2, v3).
// Usage: npm run db:rebuild             (everything)
//        npm run db:rebuild -- v1       (up to the end of volume 1)
//        npm run db:rebuild -- v1/03    (up to volume 1, chapter 03)
import { rmSync } from 'node:fs';
import { openDb, loadChapters, resolveTarget, DATA_DIR } from './db.js';

const stop = process.argv[2] ? resolveTarget(process.argv[2]) : null;
rmSync(DATA_DIR, { recursive: true, force: true });
const db = openDb();

try {
  await loadChapters(db, stop);
} catch (err) {
  console.error(`✗ ${err.message}`);
  process.exit(1);
}

await db.close();
console.log('Database rebuilt.');
