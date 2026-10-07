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
| 1 | 02 | [People and Organizations](volumes/v1-all-enterprises/02-people-and-organizations/NOTES.md) | exercises pending |

Each chapter folder contains:

| File | Purpose |
|------|---------|
| `NOTES.md` | Transcription of each figure, discussion, design decisions, when *not* to use it |
| `diagram.md` | Mermaid ER diagram (renders on GitHub and in VS Code) |
| `schema.sql` | DDL, grown one figure at a time |
| `seed.sql` | Data that exercises the tricky cases |
| `queries.sql` | The business questions the model can answer |
| `EXERCISES.md` | Practice: concept tracker, open threads, then the exercise menu (recall, queries, break-it tasks, capstone) |
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
```

Chapters load cumulatively because later models reference earlier ones: orders, shipments and
invoices all point back to `party`.

## Workflow for each figure

1. Photograph the figure into `book-refs/vN/chNN/` (gitignored; see [book-refs/README.md](book-refs/README.md)).
2. Transcribe it into `NOTES.md` and confirm the transcription against the book.
3. Discuss: what problem is it solving, and what would the naive model get wrong?
4. Implement it in `schema.sql`, add seed rows and queries, then rebuild.
5. Commit, one figure per commit.

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
