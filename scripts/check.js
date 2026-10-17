// Checks chapters against the workflow in CLAUDE.md and rewrites the generated
// tables in each chapter's STATUS.md. Only what the repo can show: the design
// reference doc lives on claude.ai, so its STATUS.md columns are on trust.
// Usage: npm run check              (every chapter with a STATUS.md)
//        npm run check -- v1        (every chapter of volume 1 with a STATUS.md)
//        npm run check -- v1/03     (one chapter)
// Prints ✗ (must fix), ! (look at it) and ✓ lines; exits 1 when anything is ✗.
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join, relative } from 'node:path';
import { execSync } from 'node:child_process';
import {
  ROOT, openDb, loadChapters, listVolumes, listChapters, resolveTarget, sessionSetupFor, parseQueries,
} from './db.js';
import { readCards, parseCardHeadings, buildAnki, CARDS_ANKI } from './cards.js';

const BEGIN = '<!-- check:begin -->';
const END = '<!-- check:end -->';

const readText = (path) => (existsSync(path) ? readFileSync(path, 'utf8').replace(/\r\n/g, '\n') : null);
const today = new Intl.DateTimeFormat('en-CA', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date());

// STATUS.md cells: a date (or any text) = done, "–" = doesn't apply, empty = not yet.
const isNa = (v) => /^[–—-]$/.test((v ?? '').trim());
const isDone = (v) => !!(v ?? '').trim() && !isNa(v);

function parseFigId(id) {
  const m = /^(\d+)\.(\d+)([a-z]?)$/.exec((id ?? '').trim());
  return m ? { major: Number(m[1]), minor: Number(m[2]), suffix: m[3] } : null;
}

// Does a figure list like "2.7, 2.12–2.13" cover figure "2.12"? A range or a bare
// number covers every lettered variant (3.9–3.10 covers 3.9a and 3.10b);
// "3.9b" covers only itself.
function covers(spec, figId) {
  const fig = parseFigId(figId);
  if (!fig) return false;
  const key = (f) => f.major * 1000 + f.minor;
  return (spec ?? '').split(',').some((part) => {
    const [loText, hiText] = part.split(/[–—-]/);
    const lo = parseFigId(loText);
    if (!lo) return false;
    if (hiText === undefined) return key(lo) === key(fig) && (!lo.suffix || lo.suffix === fig.suffix);
    const hi = parseFigId(hiText);
    return !!hi && key(lo) <= key(fig) && key(fig) <= key(hi);
  });
}

const sameFigs = (a, b) => {
  const norm = (s) => (s ?? '').replace(/\s*[—–-]\s*/g, '–').replace(/\s*,\s*/g, ',').trim();
  return norm(a) === norm(b);
};

// The lines under a heading that starts with `prefix`, up to the next "## ".
function section(text, prefix) {
  const lines = (text ?? '').split('\n');
  const start = lines.findIndex((l) => l.startsWith(prefix));
  if (start < 0) return null;
  let end = start + 1;
  while (end < lines.length && !/^## /.test(lines[end])) end++;
  return lines.slice(start + 1, end).join('\n');
}

// Every "### Fig N.M — Title" under NOTES's "## Figures", with its text.
function notesFigures(notes) {
  return (section(notes, '## Figures') ?? '').split(/\n(?=### )/).flatMap((part) => {
    const m = /^### Fig (\d+\.\d+[a-z]?)\b/.exec(part);
    return m ? [{ id: m[1], body: part }] : [];
  });
}

// Figure ids with a section header ("-- ====" then "-- Fig 3.9b — …") in a SQL file.
const sqlSections = (sql) =>
  new Set([...(sql ?? '').matchAll(/^-- =+\n-- (?:Fig|Table) (\d+\.\d+[a-z]?)\b/gm)].map((m) => m[1]));

function parseStatus(text) {
  const figList = (label) => {
    const m = new RegExp(`^${label}[^:\\n]*:[ \\t]*(.*)$`, 'm').exec(text);
    return m ? m[1].split(',').map((s) => s.trim()).filter((s) => parseFigId(s)) : [];
  };
  const lines = (section(text, '## Submodels') ?? '').split('\n').filter((l) => l.trim().startsWith('|'));
  const cells = (line) => line.trim().replace(/^\||\|$/g, '').split('|').map((c) => c.trim());
  const header = cells(lines[0] ?? '').map((h) => h.toLowerCase());
  const rows = lines.slice(2).map((line) => {
    const c = cells(line);
    return Object.fromEntries(header.map((h, i) => [h, c[i] ?? '']));
  });
  return { notBuilt: figList('Not built'), architecture: figList('Architecture figure'), rows };
}

// Ponder counts per submodel, when EXERCISES.md groups section 0 by "### Submodel N".
function pondersBySubmodel(exercises) {
  const sec = section(exercises, '## 0. To ponder');
  if (!sec || !/^### Submodel \d+/m.test(sec)) return null;
  const counts = {};
  for (const part of sec.split(/\n(?=### )/)) {
    const m = /^### Submodel (\d+)/.exec(part);
    if (m) counts[m[1]] = (part.match(/^\d+\. /gm) ?? []).length;
  }
  return counts;
}

const table = (head, rows) =>
  [`| ${head.join(' | ')} |`, `|${head.map(() => '---').join('|')}|`, ...rows.map((r) => `| ${r.join(' | ')} |`)].join('\n');

async function checkChapter({ volume, chapter }, ctx) {
  const out = [];
  const fail = (t) => out.push(['✗', t]);
  const warn = (t) => out.push(['!', t]);
  const ok = (t) => out.push(['✓', t]);
  const file = (name) => readText(join(chapter.path, name));

  const statusPath = join(chapter.path, 'STATUS.md');
  const statusText = file('STATUS.md');
  if (!statusText) {
    fail('no STATUS.md: copy templates/chapter/STATUS.md and fill it');
    return { out };
  }
  const status = parseStatus(statusText);
  const notes = file('NOTES.md') ?? '';
  const figures = notesFigures(notes);
  const sql = Object.fromEntries(['schema', 'seed', 'queries'].map((k) => [k, sqlSections(file(`${k}.sql`))]));
  const submodels = status.rows.filter((r) => r['#'] && r['#'] !== 'A');
  const archRow = status.rows.find((r) => r['#'] === 'A');
  const isArch = (id) => status.architecture.includes(id);
  const isNotBuilt = (id) => status.notBuilt.includes(id);

  // Figures: each one is built, the architecture figure, or listed as not built.
  const figureRows = [];
  const kinds = {};
  for (const fig of figures) {
    const owners = submodels.filter((r) => covers(r.figs, fig.id)).map((r) => r['#']);
    const kind = isArch(fig.id) ? 'architecture' : isNotBuilt(fig.id) ? 'not built' : owners.length ? 'built' : 'unassigned';
    kinds[kind] = (kinds[kind] ?? 0) + 1;
    const has = (k) => sql[k].has(fig.id);
    const transcribed = fig.body.includes('**Transcription**');
    const flows = fig.body.includes('**How it flows**');
    const mark = (k, level) => (has(k) ? '✓' : level);
    if (!transcribed) fail(`Fig ${fig.id}: no **Transcription** under it in NOTES`);
    if (kind === 'unassigned') fail(`Fig ${fig.id}: in no submodel's Figs, not the architecture figure, not listed as not built`);
    if (kind === 'built') {
      if (!has('schema')) fail(`Fig ${fig.id}: no schema.sql section`);
      if (!has('seed')) warn(`Fig ${fig.id}: no seed.sql section`);
      if (!has('queries')) warn(`Fig ${fig.id}: no queries.sql section`);
    }
    if (kind === 'architecture') {
      if (!flows) fail(`Fig ${fig.id}: architecture figure without a **How it flows** in NOTES`);
      if (has('schema')) fail(`Fig ${fig.id}: architecture figure with a schema.sql section (these get no SQL)`);
    }
    if (kind === 'not built' && has('schema')) warn(`Fig ${fig.id}: listed as not built, yet has a schema.sql section`);
    figureRows.push([
      fig.id, kind, owners.join(', ') || '–', transcribed ? '✓' : '✗',
      kind === 'built' ? mark('schema', '✗') : '–',
      kind === 'built' ? mark('seed', '!') : '–',
      kind === 'built' ? mark('queries', '!') : '–',
      kind === 'architecture' ? (flows ? '✓' : '✗') : '–',
    ]);
  }
  for (const id of [...status.notBuilt, ...status.architecture]) {
    if (!figures.some((f) => f.id === id)) fail(`STATUS.md names Fig ${id}, but NOTES has no such figure`);
  }
  if (!status.architecture.length) warn('no architecture figure named yet (fine until the chapter\'s last figure arrives)');
  if (!/^### Points to discuss/m.test(notes)) warn('NOTES has no "Points to discuss after the overview" list');
  if (figures.length) {
    ok(`${figures.length} figures: ${Object.entries(kinds).map(([k, n]) => `${n} ${k}`).join(', ')}`);
  }

  // Submodels: a card and a ticked doc draft once any of their figures is built.
  const cards = ctx.cards.filter((c) => `v${c.volume}` === volume.schema && c.chapter === Number(chapter.number));
  const ponders = pondersBySubmodel(file('EXERCISES.md'));
  const submodelRows = [];
  for (const r of submodels) {
    const label = `Submodel ${r['#']} (${r.submodel})`;
    const mine = figures.filter((f) => covers(r.figs, f.id));
    const built = mine.some((f) => !isArch(f.id) && !isNotBuilt(f.id) && sql.schema.has(f.id));
    const card = cards.find((c) => sameFigs(c.figs, r.figs));
    if (!mine.length) fail(`${label}: none of its figures (${r.figs}) is in NOTES`);
    if (built && !card) fail(`${label}: no card headed "(Figs ${r.figs})" in docs/cards.md`);
    if (built && !isDone(r['doc draft'])) fail(`${label}: doc draft not ticked in STATUS.md (write it in the design reference, then tick)`);
    if (isDone(r['doc done']) && !isDone(r.practice)) fail(`${label}: doc done is ticked but practice isn't`);
    const n = ponders ? ponders[r['#']] ?? 0 : null;
    if (n > 5) fail(`${label}: ${n} ponders in EXERCISES.md (at most 5)`);
    submodelRows.push([r['#'], r.submodel, built ? '✓' : '–', card ? `Card ${card.number}` : built ? '✗' : '–', n ?? '–']);
  }
  for (const c of cards) {
    if (!submodels.some((r) => sameFigs(r.figs, c.figs))) warn(`Card ${c.number} (${c.name}) matches no submodel row in STATUS.md`);
  }
  if (status.architecture.length) {
    const flows = figures.some((f) => isArch(f.id) && f.body.includes('**How it flows**'));
    if (!archRow) fail('STATUS.md names an architecture figure but has no "A" row');
    else if (flows && !isDone(archRow['doc draft'])) fail('Architecture: doc entry not ticked in STATUS.md');
  }
  if (submodels.length) ok(`${submodels.length} submodels checked for cards, doc drafts and ponders`);

  // Queries: every one runs; every data-quality check catches a deliberate bad row.
  if (ctx.loadError) {
    fail(`database load failed: ${ctx.loadError}`);
  } else {
    const blocks = parseQueries(file('queries.sql') ?? '');
    await ctx.db.exec(sessionSetupFor(volume));
    let errors = 0;
    let checks = 0;
    for (const { title, sql: text } of blocks) {
      try {
        const results = await ctx.db.exec(text);
        if (/data-quality check/i.test(title)) {
          checks++;
          if (!(results.at(-1)?.rows?.length)) warn(`"${title}" catches no deliberate bad row`);
        }
      } catch (err) {
        errors++;
        fail(`query "${title}" fails: ${err.message}`);
      }
    }
    if (!errors) ok(`${blocks.length} queries run, ${checks} of them data-quality checks`);
  }

  // Rewrite the generated part of STATUS.md.
  const counts = { '✗': 0, '!': 0 };
  for (const [level] of out) if (level in counts) counts[level]++;
  const generated = [
    BEGIN,
    table(['Fig', 'Kind', 'Submodel', 'Transcribed', 'schema', 'seed', 'queries', 'How it flows'], figureRows),
    '',
    table(['#', 'Submodel', 'Figures built', 'Card', 'Ponders'], submodelRows),
    '',
    `Last check: ${counts['✗']} ✗ · ${counts['!']} !`,
    END,
  ].join('\n');
  const raw = readFileSync(statusPath, 'utf8');
  const eol = raw.includes('\r\n') ? '\r\n' : '\n';
  const lf = raw.replace(/\r\n/g, '\n');
  const updated = lf.includes(BEGIN) && lf.includes(END)
    ? lf.slice(0, lf.indexOf(BEGIN)) + generated + lf.slice(lf.indexOf(END) + END.length)
    : `${lf.trimEnd()}\n\n## Repo (generated by \`npm run check\`, don't edit)\n${generated}\n`;
  if (updated !== lf) writeFileSync(statusPath, updated.replace(/\n/g, eol));

  return { out };
}

function repoChecks(ctx, dirty) {
  const out = [];
  const src = readCards();
  const anki = readText(CARDS_ANKI);
  if (anki !== buildAnki(src).text) out.push(['✗', 'docs/cards-anki.txt is stale: run npm run cards:anki, then re-import in Anki']);
  else out.push(['✓', 'docs/cards-anki.txt matches docs/cards.md']);
  const numbers = ctx.cards.map((c) => c.number);
  if (numbers.some((n, i) => n !== i + 1)) out.push(['!', `cards aren't numbered 1..${numbers.length} in order: ${numbers.join(', ')}`]);
  if (!new RegExp(`^## ${today}$`, 'm').test(readText(join(ROOT, 'CHANGELOG.md')) ?? '')) {
    out.push(['!', `CHANGELOG.md has no entry for ${today} (add one before the session's last commit)`]);
  }
  if (dirty.length) out.push(['!', `${dirty.length} uncommitted file(s): ${dirty.slice(0, 5).join(', ')}${dirty.length > 5 ? ', …' : ''}`]);
  return out;
}

function targets(arg) {
  const all = listVolumes().flatMap((volume) => listChapters(volume).map((chapter) => ({ volume, chapter })));
  const withStatus = (list) => list.filter(({ chapter }) => existsSync(join(chapter.path, 'STATUS.md')));
  if (!arg) return withStatus(all);
  const t = resolveTarget(arg);
  return t.chapter ? [t] : withStatus(all.filter(({ volume }) => volume.schema === t.volume.schema));
}

let dirty = [];
try {
  dirty = execSync('git status --porcelain', { cwd: ROOT, encoding: 'utf8' }).split('\n').filter(Boolean).map((l) => l.slice(3));
} catch {
  // not a git checkout: skip the uncommitted-files check
}

const db = openDb('memory://');
const ctx = { db, cards: parseCardHeadings(readCards()), loadError: null };
try {
  await loadChapters(db, null, () => {});
} catch (err) {
  ctx.loadError = err.message;
}

const sections = [];
for (const target of targets(process.argv[2])) {
  const { out } = await checkChapter(target, ctx);
  sections.push([`${target.volume.schema.toUpperCase()} Ch ${target.chapter.number} (${relative(ROOT, target.chapter.path).replace(/\\/g, '/')})`, out]);
}
sections.push(['Repo', repoChecks(ctx, dirty)]);
await db.close();

const order = { '✗': 0, '!': 1, '✓': 2 };
let fails = 0;
let warns = 0;
for (const [title, out] of sections) {
  console.log(`\n${title}`);
  for (const [level, text] of [...out].sort((a, b) => order[a[0]] - order[b[0]])) {
    console.log(`  ${level} ${text}`);
    if (level === '✗') fails++;
    if (level === '!') warns++;
  }
}
console.log(`\n${fails} ✗ · ${warns} !${fails ? ' (fix the ✗ lines, then run again)' : ''}`);
process.exitCode = fails ? 1 : 0;
