// Disposable data explorer. Loads every chapter's schema.sql + seed.sql into an
// in-memory PGlite (never touches .pgdata) and serves a small UI to browse rows,
// follow foreign keys in both directions, run each chapter's saved queries
// (queries.sql) and run SQL. "Reload" replays the files,
// so experiments in the SQL box are thrown away.
// Usage: npm run explore   (then open http://localhost:4317)
import { createServer } from 'node:http';
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { openDb, loadChapters, listVolumes, listChapters, sessionSetupFor } from '../../scripts/db.js';

const HERE = dirname(fileURLToPath(import.meta.url));
const PORT = Number(process.env.PORT ?? 4317);
const VOLUME_SCHEMA = String.raw`^v\d$`;

let db;
let meta;   // key "v1.party" -> { schema, name, kind, figure, chapter, columns, pk, fks, referencedBy, count }
let data;   // key -> { rows, byPk: Map }  (base tables only)
let display; // key -> Map(pk -> name), from views named <table>_display_name

// ---- loading ---------------------------------------------------------------

async function load() {
  if (db) await db.close();
  db = openDb('memory://');
  await loadChapters(db, null, () => {});
  await db.exec(sessionSetupFor(listVolumes().at(-1)));
  await refresh();
}

// Re-read the catalogue and every table; cheap at seed sizes. Called after
// each SQL run so the browser always shows what the SQL box changed.
async function refresh() {
  meta = await readMeta();
  data = {};
  display = {};
  for (const t of Object.values(meta)) {
    const q = `${t.schema}.${t.name}`;
    if (t.kind === 'table') {
      const order = t.pk ? ` order by ${t.pk}` : '';
      const { rows } = await db.query(`select * from ${q}${order}`);
      data[q] = { rows, byPk: new Map(rows.map((r) => [String(r[t.pk]), r])) };
      t.count = rows.length;
    } else if (t.name.endsWith('_display_name')) {
      const { rows, fields } = await db.query(`select * from ${q}`);
      const target = `${t.schema}.${t.name.replace(/_display_name$/, '')}`;
      display[target] = new Map(rows.map((r) => [String(r[fields[0].name]), r.name ?? r.display_name]));
    }
  }
}

// Section headers in schema.sql look like a line of "=" above and below
// "-- Fig 2.4 — Party roles"; every create table/view after one belongs to it.
function readFigures() {
  const map = new Map();
  const rule = /^-- =+\s*$/;
  for (const volume of listVolumes()) {
    for (const chapter of listChapters(volume)) {
      const path = join(chapter.path, 'schema.sql');
      if (!existsSync(path)) continue;
      const lines = readFileSync(path, 'utf8').split(/\r?\n/);
      let figure = 'Other';
      lines.forEach((line, i) => {
        if (rule.test(lines[i - 1] ?? '') && rule.test(lines[i + 1] ?? '') && line.startsWith('-- ')) {
          figure = line.slice(3).trim();
        }
        const m = /^create\s+(?:or\s+replace\s+)?(?:table|view)\s+(\w+)/i.exec(line);
        if (m) map.set(`${volume.schema}.${m[1]}`, { chapter: `${volume.schema}/${chapter.dir}`, figure });
      });
    }
  }
  return map;
}

async function readMeta() {
  const figures = readFigures();
  const tables = {};
  const { rows: rels } = await db.query(
    `select table_schema as schema, table_name as name, table_type
       from information_schema.tables where table_schema ~ $1`, [VOLUME_SCHEMA]);
  for (const r of rels) {
    const key = `${r.schema}.${r.name}`;
    const fig = figures.get(key) ?? { chapter: r.schema, figure: 'Other' };
    tables[key] = {
      key, schema: r.schema, name: r.name, kind: r.table_type === 'VIEW' ? 'view' : 'table',
      ...fig, columns: [], pk: null, fks: [], referencedBy: [], subtypes: [], count: null,
    };
  }

  const { rows: cols } = await db.query(
    `select table_schema as schema, table_name as name, column_name as column,
            data_type as type, is_nullable = 'YES' as nullable
       from information_schema.columns where table_schema ~ $1
      order by table_schema, table_name, ordinal_position`, [VOLUME_SCHEMA]);
  for (const c of cols) {
    tables[`${c.schema}.${c.name}`]?.columns.push({ name: c.column, type: c.type, nullable: c.nullable });
  }

  // Keys here are single-column by convention, so the first key column is enough.
  const { rows: keys } = await db.query(
    `select k.contype as kind, n.nspname as schema, t.relname as name, a.attname as column,
            fn.nspname as ref_schema, ft.relname as ref_name, fa.attname as ref_column
       from pg_constraint k
       join pg_class t      on t.oid = k.conrelid
       join pg_namespace n  on n.oid = t.relnamespace
       join pg_attribute a  on a.attrelid = k.conrelid and a.attnum = k.conkey[1]
       left join pg_class ft     on ft.oid = k.confrelid
       left join pg_namespace fn on fn.oid = ft.relnamespace
       left join pg_attribute fa on fa.attrelid = k.confrelid and fa.attnum = k.confkey[1]
      where k.contype in ('p', 'f') and n.nspname ~ $1
      order by n.nspname, t.relname, a.attnum`, [VOLUME_SCHEMA]);
  for (const k of keys) {
    const t = tables[`${k.schema}.${k.name}`];
    if (!t) continue;
    if (k.kind === 'p') t.pk = k.column;
    else {
      const ref = `${k.ref_schema}.${k.ref_name}`;
      t.fks.push({ column: k.column, ref, refColumn: k.ref_column });
      tables[ref]?.referencedBy.push({ table: t.key, column: k.column });
    }
  }
  // A subtype table's primary key is also its foreign key to the supertype.
  for (const t of Object.values(tables)) {
    for (const fk of t.fks) if (fk.column === t.pk) tables[fk.ref]?.subtypes.push(t.key);
  }
  return tables;
}

// ---- saved queries ---------------------------------------------------------
// Each chapter's queries.sql: "-- name: <question>" starts a query, and the
// same "=" section headers as schema.sql name its figure. Re-read on every
// request, so edits show up without restarting the explorer.

function readQueries() {
  const out = [];
  const rule = /^-- =+\s*$/;
  for (const volume of listVolumes()) {
    for (const chapter of listChapters(volume)) {
      const path = join(chapter.path, 'queries.sql');
      if (!existsSync(path)) continue;
      const lines = readFileSync(path, 'utf8').split(/\r?\n/);
      let figure = 'Other';
      let current = null;
      const finish = () => {
        if (!current) return;
        current.sql = current.body.join('\n').trim();
        delete current.body;
        if (current.sql) out.push(current);
        current = null;
      };
      lines.forEach((line, i) => {
        if (rule.test(line)) { finish(); return; }
        if (rule.test(lines[i - 1] ?? '') && rule.test(lines[i + 1] ?? '') && line.startsWith('-- ')) {
          figure = line.slice(3).trim();
          return;
        }
        const m = /^-- name:\s*(.*)$/.exec(line);
        if (m) {
          finish();
          current = { chapter: `${volume.schema}/${chapter.dir}`, figure, title: m[1].trim(), body: [] };
        } else if (current) current.body.push(line);
      });
      finish();
    }
  }
  return out.map((q, id) => ({ id, ...q, check: /data-quality check/i.test(q.title) }));
}

// ---- labels ----------------------------------------------------------------
// A human-readable name for a row: the display-name view if there is one, else
// a name/description/note column, else the text of its subtype row (a contact
// mechanism shows its actual address or number), else the labels of the rows
// it points at (party_role → "Ana · Employee"), two levels deep at most.

const LABEL_COLUMNS = ['name', 'description', 'title', 'note'];

function ownText(t, row) {
  const fkCols = new Set(t.fks.map((fk) => fk.column));
  return t.columns
    .filter((c) => c.name !== t.pk && !fkCols.has(c.name) && c.type === 'text' && row[c.name] != null)
    .slice(0, 3)
    .map((c) => row[c.name])
    .join(' ');
}

function label(table, id, depth = 0) {
  if (id == null) return null;
  const names = display[table];
  if (names?.has(String(id))) return names.get(String(id));
  const t = meta[table];
  const row = data[table]?.byPk.get(String(id));
  if (!t || !row) return String(id);
  for (const c of LABEL_COLUMNS) if (row[c] != null) return String(row[c]);
  for (const sub of t.subtypes) {
    const subRow = data[sub]?.byPk.get(String(id));
    const text = subRow && ownText(meta[sub], subRow);
    if (text) return text;
  }
  if (depth >= 2) return null;
  const parts = t.fks
    .filter((fk) => row[fk.column] != null)
    .map((fk) => label(fk.ref, row[fk.column], depth + 1))
    .filter(Boolean);
  if (depth === 0 && row.from_date) parts.push(`from ${row.from_date}`);
  return parts.length ? parts.join(' · ') : depth === 0 ? `#${id}` : null;
}

function fkLabels(t, rows) {
  const out = {};
  for (const fk of t.fks) {
    out[fk.column] = {};
    for (const r of rows) {
      const v = r[fk.column];
      if (v != null) out[fk.column][v] = label(fk.ref, v, 1);
    }
  }
  return out;
}

// ---- API -------------------------------------------------------------------

const api = {
  'GET /api/meta': () => ({ tables: Object.values(meta) }),

  'GET /api/rows': async (q) => {
    const t = meta[q.get('t')];
    if (!t) throw new Error(`Unknown table ${q.get('t')}`);
    const rows = t.kind === 'table'
      ? data[t.key].rows
      : (await db.query(`select * from ${t.key} limit 1000`)).rows;
    const pkLabels = t.pk ? Object.fromEntries(rows.map((r) => [r[t.pk], label(t.key, r[t.pk])])) : {};
    return { rows, fkLabels: fkLabels(t, rows), pkLabels };
  },

  'GET /api/row': (q) => {
    const t = meta[q.get('t')];
    const id = q.get('id');
    const row = data[t?.key]?.byPk.get(id);
    if (!row) throw new Error(`No row ${id} in ${q.get('t')}`);
    const referencedBy = t.referencedBy.map(({ table, column }) => {
      const src = meta[table];
      const rows = data[table].rows.filter((r) => String(r[column]) === id);
      return { table, column, rows: rows.map((r) => ({ id: r[src.pk], label: label(table, r[src.pk]) })) };
    });
    return { row, label: label(t.key, id), fkLabels: fkLabels(t, [row]), referencedBy };
  },

  'POST /api/sql': async (_q, body) => {
    try {
      const results = await db.exec(body.sql ?? '');
      return { results: results.map((r) => ({ fields: r.fields.map((f) => f.name), rows: r.rows, affectedRows: r.affectedRows })) };
    } catch (err) {
      return { error: err.message };
    } finally {
      // Saved queries are read-only, so they skip the (slower) re-read of every table.
      if (body.refresh !== false) await refresh();
    }
  },

  'GET /api/queries': () => ({ queries: readQueries() }),

  'POST /api/reload': async () => {
    await load();
    return { ok: true };
  },
};

const json = (res, status, value) => {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(JSON.stringify(value, (_k, v) => (typeof v === 'bigint' ? v.toString() : v)));
};

try {
  await load();
} catch (err) {
  console.error(`✗ ${err.message}`);
  process.exit(1);
}

createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  if (url.pathname === '/') {
    res.writeHead(200, { 'content-type': 'text/html; charset=utf-8' });
    res.end(readFileSync(join(HERE, 'index.html')));
    return;
  }
  const handler = api[`${req.method} ${url.pathname}`];
  if (!handler) return json(res, 404, { error: 'Not found' });
  try {
    let body = {};
    if (req.method === 'POST') {
      let raw = '';
      for await (const chunk of req) raw += chunk;
      body = raw ? JSON.parse(raw) : {};
    }
    json(res, 200, await handler(url.searchParams, body));
  } catch (err) {
    json(res, 400, { error: err.message });
  }
})
  .on('error', (err) => {
    if (err.code !== 'EADDRINUSE') throw err;
    console.error(`✗ Port ${PORT} is already in use; is the explorer already running?`);
    console.error(`  Open http://localhost:${PORT}, or pick another port: PORT=4318 npm run explore`);
    process.exit(1);
  })
  .listen(PORT, () => console.log(`Explorer ready: http://localhost:${PORT}`));
