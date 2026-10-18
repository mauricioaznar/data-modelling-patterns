// Reads a chapter's STATUS.md: its figure lists and its Submodels table.
// Shared by check.js (checks the chapter) and cards.js (a card's status sets its Anki deck).

// STATUS.md cells: a date (or any text) = done, "–" = doesn't apply, empty = not yet.
export const isNa = (v) => /^[–—-]$/.test((v ?? '').trim());
export const isDone = (v) => !!(v ?? '').trim() && !isNa(v);

export function parseFigId(id) {
  const m = /^(\d+)\.(\d+)([a-z]?)$/.exec((id ?? '').trim());
  return m ? { major: Number(m[1]), minor: Number(m[2]), suffix: m[3] } : null;
}

export const sameFigs = (a, b) => {
  const norm = (s) => (s ?? '').replace(/\s*[—–-]\s*/g, '–').replace(/\s*,\s*/g, ',').trim();
  return norm(a) === norm(b);
};

// The lines under a heading that starts with `prefix`, up to the next "## ".
export function section(text, prefix) {
  const lines = (text ?? '').split('\n');
  const start = lines.findIndex((l) => l.startsWith(prefix));
  if (start < 0) return null;
  let end = start + 1;
  while (end < lines.length && !/^## /.test(lines[end])) end++;
  return lines.slice(start + 1, end).join('\n');
}

export function parseStatus(text) {
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

// A card's status, from its STATUS.md row (the user's call, 2026-10-18): draft until the
// chapter's overview, reviewed once Overview is ticked ("–" too: submodels built before the
// overview step existed), done once practice closes and Doc done is ticked. Architecture
// rows never get Doc done, so they stop at reviewed. No row means draft.
export function cardStatus(row) {
  if (!row) return 'draft';
  if (isDone(row['doc done'])) return 'done';
  if (isDone(row.overview) || isNa(row.overview)) return 'reviewed';
  return 'draft';
}
