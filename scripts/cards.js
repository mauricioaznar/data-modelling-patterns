// Reads docs/cards.md: the submodel cards, the architecture cards and the pattern cue lines.
// Shared by cards-anki.js (writes the Anki file) and check.js (checks it's current).
// Each note gets a stable id (Anki's GUID) from its volume, chapter and figures,
// its volume and chapter (architecture), or its pattern number, so renumbering or
// rewording a card updates the note and keeps its review history instead of adding
// a duplicate.
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
export const CARDS_MD = join(ROOT, 'docs', 'cards.md');
export const CARDS_ANKI = join(ROOT, 'docs', 'cards-anki.txt');

// Windows checkouts (core.autocrlf) have CRLF; the regexes below expect LF.
export const readCards = () => readFileSync(CARDS_MD, 'utf8').replace(/\r\n/g, '\n');

// "### Card 9 · V1 Ch 3 · Product associations and parts (Figs 3.9–3.10)"
export function parseCardHeadings(src) {
  return [...src.matchAll(/^### Card (\d+) · V(\d+) Ch (\d+) · (.+?) \(Figs? ([^)]+)\)[ \t]*$/gm)].map((m) => ({
    number: Number(m[1]),
    volume: Number(m[2]),
    chapter: Number(m[3]),
    name: m[4],
    figs: m[5],
  }));
}

// "### Architecture · V1 Ch 3 · Products (Fig 3.11)": one per chapter, from its architecture figure.
export function parseArchHeadings(src) {
  return [...src.matchAll(/^### Architecture · V(\d+) Ch (\d+) · (.+?) \(Figs? ([^)]+)\)[ \t]*$/gm)].map((m) => ({
    volume: Number(m[1]),
    chapter: Number(m[2]),
    name: m[3],
    figs: m[4],
  }));
}

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

// The Anki import file for a cards.md source: { text, count }.
export function buildAnki(src) {
  const rows = [];

  // Submodel and architecture cards share a shape; each block runs to the next heading.
  for (const block of src.split(/\n(?=#{1,3} )/).filter((b) => /^### (Card|Architecture) /.test(b))) {
    const arch = block.startsWith('### Architecture ');
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
      arch ? `v${volume}::ch${chapter} architecture` : `v${volume}::ch${chapter}`,
      arch ? 'Data Models::Architecture' : 'Data Models::Submodels',
      arch ? `dm-v${volume}-ch${chapter}-arch` : `dm-v${volume}-ch${chapter}-${figs}`,
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
  return { text: [...header, ...rows.map((r) => r.join('\t'))].join('\n') + '\n', count: rows.length };
}
