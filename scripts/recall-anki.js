// Turns docs/recall.md into an Anki import file (docs/recall-anki.txt).
// docs/recall.md stays the source of truth: edit it, rerun, re-import.
// Anki updates existing notes whose first field (the front) is unchanged,
// so keep card titles and cues stable to keep review history.
import { readFileSync, writeFileSync } from 'node:fs';

const src = readFileSync('docs/recall.md', 'utf8');

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
  const chapter = title.match(/Ch (\d+)/)[1].padStart(2, '0');
  rows.push([
    `${html(title)}<br><br>${html(cue)}`,
    `<b>Hook:</b> ${html(hook)}<br><b>Mantra:</b> ${html(mantra)}<hr>${keyHtml}`,
    `submodel ch${chapter}`,
  ]);
}

for (const m of src.matchAll(/^- \*\*(P\d+) · (.+?)\*\* Cue: "(.+)"$/gm)) {
  const [, id, name, cue] = m;
  rows.push([
    `Pattern ${id}<br><br>${html(cue)}`,
    `<b>${html(name)}</b><br><br>Now: two examples from different chapters, and when not to use it.`,
    'pattern',
  ]);
}

const header = [
  '#separator:tab',
  '#html:true',
  '#notetype:Basic',
  '#deck:Data Models::Recall',
  '#tags column:3',
];
writeFileSync('docs/recall-anki.txt', [...header, ...rows.map((r) => r.join('\t'))].join('\n') + '\n');
console.log(`docs/recall-anki.txt: ${rows.length} cards`);
