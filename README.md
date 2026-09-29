# Data Modelling Patterns

A study companion for Len Silverston's *The Data Model Resource Book, Volume 1 (Revised Edition)*.
We go one chapter at a time and one figure at a time, and turn each universal data model into
runnable PostgreSQL along with notes on why it is shaped the way it is. The goal is a reference
to come back to when designing a real application.

## Chapters

| # | Chapter | Status |
|---|---------|--------|
| 02 | [People and Organizations](chapters/02-people-and-organizations/NOTES.md) | in progress |
| 03 | Products | — |
| 04 | Ordering Products | — |
| 05 | Shipments | — |
| 06 | Work Effort | — |
| 07 | Invoicing | — |
| 08 | Accounting and Budgeting | — |
| 09 | Human Resources | — |

Each chapter folder contains:

| File | Purpose |
|------|---------|
| `NOTES.md` | Transcription of each figure, discussion, design decisions, when *not* to use it |
| `diagram.md` | Mermaid ER diagram (renders on GitHub and in VS Code) |
| `schema.sql` | DDL, grown one figure at a time |
| `seed.sql` | Data that exercises the tricky cases |
| `queries.sql` | The business questions the model can answer |

A new chapter starts as a copy of `chapters/_template/`.

## Running it

The database is [PGlite](https://pglite.dev), real PostgreSQL compiled to WASM and run from Node.
There is nothing to install besides `npm install`. Data is stored in `.pgdata/` (gitignored).

```bash
npm install
npm run db:rebuild            # wipe and load schema + seed for every chapter, in order
npm run db:rebuild -- 02      # only up to chapter 02
npm run queries -- 02         # run chapter 02's named queries
npm run sql -- "select * from party"
```

Chapters load cumulatively because later models reference earlier ones: orders, shipments and
invoices all point back to `party`.

## Workflow for each figure

1. Photograph the figure into `book-refs/chNN/` (gitignored; see [book-refs/README.md](book-refs/README.md)).
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
