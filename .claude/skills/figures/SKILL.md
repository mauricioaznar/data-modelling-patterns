---
name: figures
description: Fixed procedure for when the user shares book figures (photos or transcriptions) for a chapter. Transcribes them, builds the SQL, drafts the design reference entries and recall cards, then runs the checker. Use whenever figure images arrive, even without the slash command.
argument-hint: vN/NN
---

# /figures: build everything the figures show

Run every step in order. Don't wait for confirmation (the user's rule, 2026-10-16): build on
your own reading and leave doubts for the overview. When a step doesn't apply, say so in the
report instead of skipping it silently.

## 0. Orient
- Find the chapter (`vN/NN`) and read its `STATUS.md`, its TODO.md lines and the latest
  CHANGELOG.md entry. A new chapter starts as a copy of `templates/chapter/` (STATUS.md
  included).
- List the figures in the photos. Decide for each: **submodel figure**, **alternate not
  built** (the book offers a/b versions and the overall figure keeps the other one), or
  **architecture figure** (the chapter's last, overall figure).

## 1. Transcribe (NOTES.md, under `## Figures`, in book order)
- One `### Fig N.M — Title` per figure, with a `**Transcription**` line and the notation
  block, in our own words. Anything unsure goes under "To check against the book".
- Aim for Silverston's intention. Doubtful readings go to "Points to discuss after the
  overview" under the chapter's last figure.

## 2. Classify in STATUS.md
- Put each figure in a submodel's `Figs`, in `Not built`, or in `Architecture figure`. A new
  submodel gets a row here and in the submodel lists of NOTES.md and EXERCISES.md.

## 3. Build each submodel figure (book order, one commit per figure)
1. NOTES: the problem, the naive model, the alternatives and when not to use it; then the
   book → SQL choices under `## Design decisions`.
2. `schema.sql`, `seed.sql`, `queries.sql`: a section per figure (a `-- ====` line, then
   `-- Fig N.M — Title`). Seed edge cases and deliberate bad rows; every rule a plain FK can't
   hold gets a data-quality query that catches one of them.
3. Ponders in EXERCISES.md section 0, under the submodel, tagged with the figure: at most 5
   per submodel.
4. `npm run db:rebuild && npm run queries -- vN/NN`; fix every error.
5. Commit: `Vol N Ch N: Fig N.M <title> (<what it adds>); ponders …`.

## 4. The architecture figure (no SQL)
- Transcription (entities and lines), "What it adds or settles", a `**How it flows**` of
  about ten lines (hubs, how each submodel hands over to the next, what plugs in from earlier
  chapters, which alternates win) and its points to discuss. Commit.

## 5. Doc and cards, for each submodel whose figures are now built
1. Design reference doc (load the docs skill first): the entry's five sections (questions,
   core entities, optional add-ons, design choices, patterns used), marked *Draft
   (assumptions)*. New patterns or examples in Core patterns, its questions in the question
   index, roadmap *In progress*.
2. Recall card in `docs/recall.md`, headed `### Card N · VN Ch N · name (Figs …)` with the
   same `Figs` as STATUS.md: hook, mantra (about 20 words at most), key in S · W · T · D (the
   Trap is the naive-model trap until practice). Keep cards in chapter order. Then
   `npm run recall:anki`.
3. Tick `Doc draft` in STATUS.md with today's date.
4. The architecture figure: its "Ch N architecture" entry in the doc, then tick the `A` row.

## 6. Bookkeeping
- TODO.md (tick, add), the README progress table, CHANGELOG.md (today's entry: Built,
  Decisions, Next).

## 7. Check and commit
- `npm run check -- vN/NN`. Fix every ✗ and rerun until none is left. Read each ! and either
  fix it or say why it stays.
- Commit what's left, STATUS.md's generated tables included.

## 8. Report
- What was built, per figure; the readings that went to "Points to discuss"; the checker's
  last line; anything you couldn't do. If cards changed, remind the user to re-import Anki.
