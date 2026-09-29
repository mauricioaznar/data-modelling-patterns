// Wipes the local database and replays every chapter's schema.sql then seed.sql.
// Usage: npm run db:rebuild            (all chapters)
//        npm run db:rebuild -- 03      (chapters up to and including 03)
import { rmSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { openDb, listChapters, CHAPTERS_DIR, DATA_DIR, existsSync } from './db.js';

const upTo = process.argv[2];
rmSync(DATA_DIR, { recursive: true, force: true });
const db = openDb();

for (const chapter of listChapters()) {
  if (upTo && chapter.slice(0, 2) > upTo.slice(0, 2)) break;
  for (const file of ['schema.sql', 'seed.sql']) {
    const path = join(CHAPTERS_DIR, chapter, file);
    if (!existsSync(path)) continue;
    const sql = readFileSync(path, 'utf8');
    if (!sql.replace(/--.*$/gm, '').trim()) continue;
    try {
      await db.exec(sql);
      console.log(`✓ ${chapter}/${file}`);
    } catch (err) {
      console.error(`✗ ${chapter}/${file}\n  ${err.message}`);
      process.exit(1);
    }
  }
}

await db.close();
console.log('Database rebuilt.');
