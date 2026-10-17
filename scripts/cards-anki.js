// Turns docs/cards.md into an Anki import file (docs/cards-anki.txt).
// docs/cards.md stays the source of truth: edit it, rerun, re-import.
// The parsing lives in cards.js, shared with check.js.
import { writeFileSync } from 'node:fs';
import { readCards, buildAnki, CARDS_ANKI } from './cards.js';

const { text, count } = buildAnki(readCards());
writeFileSync(CARDS_ANKI, text);
console.log(`docs/cards-anki.txt: ${count} cards`);
