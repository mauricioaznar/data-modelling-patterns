// Wipes the local database and replays every chapter's schema.sql then seed.sql,
// volume by volume. Each volume loads into its own Postgres schema (v1, v2, v3).
// Usage: npm run db:rebuild             (everything)
//        npm run db:rebuild -- v1       (up to the end of volume 1)
//        npm run db:rebuild -- v1/03    (up to volume 1, chapter 03)
import { rmSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { openDb, listVolumes, listChapters, sessionSetupFor, resolveTarget, DATA_DIR, existsSync } from './db.js';

const stop = process.argv[2] ? resolveTarget(process.argv[2]) : null;
rmSync(DATA_DIR, { recursive: true, force: true });
const db = openDb();

for (const volume of listVolumes()) {
  if (stop && volume.schema > stop.volume.schema) break;
  await db.exec(`create schema ${volume.schema}; ${sessionSetupFor(volume)}`);

  for (const chapter of listChapters(volume)) {
    if (stop?.chapter && volume.schema === stop.volume.schema && chapter.number > stop.chapter.number) break;
    for (const file of ['schema.sql', 'seed.sql']) {
      const path = join(chapter.path, file);
      if (!existsSync(path)) continue;
      const sql = readFileSync(path, 'utf8');
      if (!sql.replace(/--.*$/gm, '').trim()) continue;
      const label = `${volume.dir}/${chapter.dir}/${file}`;
      try {
        await db.exec(sql);
        console.log(`✓ ${label}`);
      } catch (err) {
        console.error(`✗ ${label}\n  ${err.message}`);
        process.exit(1);
      }
    }
  }
}

await db.close();
console.log('Database rebuilt.');
