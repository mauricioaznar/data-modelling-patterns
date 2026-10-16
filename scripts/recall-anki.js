// Turns docs/recall.md into an Anki import file (docs/recall-anki.txt).
// docs/recall.md stays the source of truth: edit it, rerun, re-import.
// Each note gets a stable id (Anki's GUID) from its volume, chapter and figures,
// or its pattern number, so renumbering or rewording a card updates the note
// and keeps its review history instead of adding a duplicate.
import { readFileSync, writeFileSync } from 'node:fs';

// Windows checkouts (core.autocrlf) have CRLF; the regexes below expect LF.
const src = readFileSync('docs/recall.md', 'utf8').replace(/\r\n/g, '\n');

// Minimal markdown → HTML for one field.
const html = (md) =>
  md
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/\*\*(.+?)\*\*/g, '<b>$1</b>')
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\*([^*]+)\*/g, '<i>$1</i>');

// A "- **Label:** text" bullet, possibly wrapped over several lines.
const field = (block, label) => {
  const m = block.match(new RegExp(`- \\*\\*${label}:\\*\\* ([\\s\\S]*?)(?=\\n- \\*\\*|\\n\\n|$)`));
  if (!m) return '';
  return m[1]
    .replace(/\s*\n\s*/g, ' ')
    .replace(/\s*\*\(Claude's, at the user's request\)\*/, '')
    .replace(/^\*\(yours\)\*$/, '')
    .replace(/^"|"$/g, '')
    .trim();
};

const rows = [];

for (const block of src.split(/\n(?=### Card )/).slice(1)) {
  const title = block.match(/^### (.+)/)[1].trim();
  const cue = field(block, 'Cue');
  const hook = field(block, 'Hook') || '(not written yet)';
  const mantra = field(block, 'Mantra') || '(not written yet)';
  const key = block.match(/<summary>Key<\/summary>\n([\s\S]*?)<\/details>/)[1];
  const keyHtml = key
    .trim()
    .split(/\n(?=- )/)
    .map((item) => html(item.replace(/^- /, '').replace(/\s*\n\s*/g, ' ')))
    .join('<br><br>');
  const [, volume, ch] = title.match(/V(\d+) Ch (\d+)/);
  const chapter = ch.padStart(2, '0');
  const figs = title.match(/\(Figs? ([^)]+)\)/)[1].replace(/–/g, '-').replace(/,\s*/g, '_');
  rows.push([
    `${html(title)}<br><br>${html(cue)}`,
    `<b>Hook:</b> ${html(hook)}<br><b>Mantra:</b> ${html(mantra)}<hr>${keyHtml}`,
    `v${volume}::ch${chapter}`,
    'Data Models::Submodels',
    `dm-v${volume}-ch${chapter}-${figs}`,
  ]);
}

for (const m of src.matchAll(/^- \*\*(P\d+) · (.+?)\*\* Cue: "(.+)"$/gm)) {
  const [, id, name, cue] = m;
  rows.push([
    `Pattern ${id}<br><br>${html(cue)}`,
    `<b>${html(name)}</b><br><br>Now: two examples from different chapters, and when not to use it.`,
    'pattern',
    'Data Models::Patterns',
    `dm-pattern-${id.toLowerCase()}`,
  ]);
}

const header = [
  '#separator:tab',
  '#html:true',
  '#notetype:Basic',
  '#tags column:3',
  '#deck column:4',
  '#guid column:5',
];
writeFileSync('docs/recall-anki.txt', [...header, ...rows.map((r) => r.join('\t'))].join('\n') + '\n');
console.log(`docs/recall-anki.txt: ${rows.length} cards`);
