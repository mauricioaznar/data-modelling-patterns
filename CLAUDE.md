# CLAUDE.md

This repo is a **learning project**: the user is studying Silverston's *Data Model Resource Book Vol 1*
chapter by chapter, and understanding the patterns matters more than shipping code.

## How we work
- The user shares a figure (a photo in `book-refs/chNN/` or a text transcription). Transcribe it into
  the chapter's `NOTES.md` and have the user confirm it **before** writing SQL. The book is the
  source of truth; recall of exact attributes may be wrong, so flag any disagreement instead of
  silently "correcting" it.
- Discuss the pattern (the problem it solves, the alternatives, when not to use it) before or
  alongside implementing it.
- One figure per commit. `schema.sql` grows in book order, with a section header per figure.
- Never copy book prose or reproduce figures verbatim in committed files. Write notes in our own
  words. `book-refs/` is gitignored and must stay that way.

## SQL conventions
- PostgreSQL (run through PGlite). Tables are singular snake_case (`party`, `party_role`), and
  primary keys are `<table>_id`.
- Subtypes: the supertype table plus a subtype table sharing its PK (e.g. `person.party_id` → `party`).
  Record in NOTES.md whenever another strategy is chosen.
- `*_TYPE` entities become lookup tables, not enums, to stay faithful to the book.
- Effectivity: `from_date date not null`, `thru_date date` (null = still current).
- Verify with `npm run db:rebuild && npm run queries -- NN` after any change.
