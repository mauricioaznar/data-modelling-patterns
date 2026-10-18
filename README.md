# Data Modelling Patterns

A study companion for Len Silverston's *The Data Model Resource Book* series.
We go one chapter at a time and one figure at a time, and turn each universal data model into
runnable PostgreSQL along with notes on why it is shaped the way it is. The goal is a reference
to come back to when designing a real application.

- [TODO.md](TODO.md): the remaining chapters, tooling to install, and open decisions
- [CHANGELOG.md](CHANGELOG.md): what got done in each session

## Volumes

Chapter numbers restart in each book, so chapters are nested under a volume folder. Each volume
loads into its own Postgres schema (`v1`, `v2`, `v3`), which lets the same table name exist in
more than one book.

| Folder | Book | Schema |
|--------|------|--------|
| [`volumes/v1-all-enterprises`](volumes/v1-all-enterprises) | Vol 1: A Library of Universal Data Models for All Enterprises (Silverston) | `v1` |
| [`volumes/v2-industry-types`](volumes/v2-industry-types) | Vol 2: A Library of Universal Data Models by Industry Types (Silverston) | `v2` |
| [`volumes/v3-universal-patterns`](volumes/v3-universal-patterns) | Vol 3: Universal Patterns for Data Modeling (Silverston & Agnew) | `v3` |

When a volume loads, unqualified names resolve to its own schema first and then to earlier
volumes. Vol 2's industry models can therefore extend Vol 1's `party` directly.

### Progress

| Vol | Ch | Chapter | Status |
|-----|----|---------|--------|
| 1 | 02 | [People and Organizations](volumes/v1-all-enterprises/02-people-and-organizations/NOTES.md) | practice in progress (3 submodels) |
| 1 | 03 | [Products](volumes/v1-all-enterprises/03-products/NOTES.md) | every figure built (3.9b and 3.10a alternates; 3.11 is the architecture figure, no SQL); doc drafts and cards for all 5 submodels; overview next, then practice |
| 1 | 04 | [Ordering Products](volumes/v1-all-enterprises/04-ordering-products/NOTES.md) | Figs 4.1–4.13 in (4.1 not built); submodels 1–6 drafted and carded; more figures to come |

Each chapter folder contains:

| File | Purpose |
|------|---------|
| `NOTES.md` | Transcription of each figure, discussion, design decisions, when *not* to use it |
| `diagram.md` | Mermaid ER diagram (renders on GitHub and in VS Code) |
| `schema.sql` | DDL, grown one figure at a time |
| `seed.sql` | Data that exercises the tricky cases |
| `queries.sql` | The business questions the model can answer |
| `EXERCISES.md` | Practice: submodels, concept tracker, open threads, practice scenarios, then an optional exercise menu |
| `EXERCISES-log.md` | Practice history: answers and the dated gaps log behind the tracker |

A new chapter starts as a copy of `templates/chapter/`.

## Running it

The database is [PGlite](https://pglite.dev), real PostgreSQL compiled to WASM and run from Node.
There is nothing to install besides `npm install`. Data is stored in `.pgdata/` (gitignored).

```bash
npm install
npm run db:rebuild                            # wipe and load every volume and chapter, in order
npm run db:rebuild -- v1/03                   # stop after volume 1, chapter 03
npm run queries -- v1/02                      # run the named queries for vol 1, chapter 02
npm run sql -- "select * from party"          # resolves against v1 by default
npm run sql -- --vol 2 "select * from party"  # resolves v2 first, then v1
npm run check                                 # check every chapter against the workflow
npm run check -- v1/03                        # one chapter; rewrites its STATUS.md tables
npm run cards:anki                           # regenerate the Anki export from docs/cards.md
```

Chapters load cumulatively because later models reference earlier ones: orders, shipments and
invoices all point back to `party`.

## Workflow for each chapter

Three Claude Code skills hold the fixed steps, and `npm run check` verifies what the repo can
show. Each chapter's `STATUS.md` tracks where every figure and submodel stands.

1. Photograph the figures into `book-refs/vN/chNN/` (gitignored; see [book-refs/README.md](book-refs/README.md)).
2. **`/figures`**: transcribe, build one figure per commit, draft the design reference entries
   and cards, run the checker.
3. **`/overview`**: after the chapter's last figure, discuss the doubtful readings, refactor,
   card pass.
4. Practice per submodel ([docs/practice.md](docs/practice.md)), then **`/close-submodel`**.

## Notation used in transcriptions

Follows the book's conventions:

```
ENTITY
  # identifier
  * mandatory attribute
  o optional attribute
  -> OTHER_ENTITY (cardinality)
  subtypes: A, B
```
