// Turns docs/recall.md into an Anki import file (docs/recall-anki.txt).
// docs/recall.md stays the source of truth: edit it, rerun, re-import.
// The parsing lives in recall.js, shared with check.js.
import { writeFileSync } from 'node:fs';
import { readRecall, buildAnki, RECALL_ANKI } from './recall.js';

const { text, count } = buildAnki(readRecall());
writeFileSync(RECALL_ANKI, text);
console.log(`docs/recall-anki.txt: ${count} cards`);
