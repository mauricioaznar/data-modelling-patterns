// Run a chapter's queries.sql, where each query is introduced by a
// "-- name: <question it answers>" line, and print every result.
// Usage: npm run queries -- v1/02
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { openDb, resolveTarget, sessionSetupFor, printResult, parseQueries, existsSync } from './db.js';

const { volume, chapter } = resolveTarget(process.argv[2]);
if (!chapter) {
  console.error('Usage: npm run queries -- v<volume>/<chapter>, e.g. v1/02');
  process.exit(1);
}

const path = join(chapter.path, 'queries.sql');
if (!existsSync(path)) {
  console.error(`No queries.sql in ${chapter.path}`);
  process.exit(1);
}

const blocks = parseQueries(readFileSync(path, 'utf8'));

const db = openDb();
await db.exec(sessionSetupFor(volume));
for (const { title, sql } of blocks) {
  console.log(`\n▶ ${title}`);
  try {
    for (const result of await db.exec(sql)) printResult(result);
  } catch (err) {
    console.error(`  error: ${err.message}`);
    process.exitCode = 1;
  }
}
await db.close();
