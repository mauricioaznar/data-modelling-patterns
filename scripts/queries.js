// Run a chapter's queries.sql, where each query is introduced by a
// "-- name: <question it answers>" line, and print every result.
// Usage: npm run queries -- v1/02
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { openDb, resolveTarget, searchPathFor, printResult, existsSync } from './db.js';

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

const blocks = readFileSync(path, 'utf8')
  .split(/^-- name:\s*/m)
  .slice(1)
  .map((block) => {
    const [title, ...body] = block.split('\n');
    return { title: title.trim(), sql: body.join('\n').trim() };
  });

const db = openDb();
await db.exec(searchPathFor(volume));
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
