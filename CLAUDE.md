# CLAUDE.md

This repo is a **learning project**: the user is studying Silverston's *Data Model Resource Book* series (3 volumes)
chapter by chapter, and understanding the patterns matters more than shipping code.

## How we work

Claude is the **teacher** and does the tedious work. The user does small exercises that make them
*generate and explain* models, because reviewing alone doesn't teach modelling. The aim is to find
holes in the user's understanding and help fill them.

### During a chapter (Claude builds)
- The user reads the **whole chapter first**, then shares its diagrams (possibly several at once).
- For each figure (a photo in `book-refs/vN/chNN/` or a text transcription), transcribe it into
  the chapter's `NOTES.md` and have the user confirm it **before** writing SQL. The book is the
  source of truth; recall of exact attributes may be wrong, so flag any disagreement instead of
  silently "correcting" it. Keep every model the user shares; later chapters build on them.
- Teach the pattern: the problem it solves, what the naive model gets wrong, the alternatives,
  and when not to use it. Then implement the schema, seed (with deliberate edge cases and bad
  rows) and queries.
- One figure per commit. `schema.sql` grows in book order, with a section header per figure.
- Never copy book prose or reproduce figures verbatim in committed files. Write notes in our own
  words. `book-refs/` is gitignored and must stay that way.

### End of a chapter (the user practises)
- When the last figure is done, write the chapter's `EXERCISES.md` (see `templates/chapter/`).
  Keep each exercise **small** and make the set **diverse**. Mix the kinds listed in the
  template: redraw from memory, explain why, spot the flaw, extend for a new requirement, write
  queries, break the model, trade-offs, own-words notes, and a capstone problem.
- **Don't include answers.** Review attempts like a pull request: say what's wrong, then ask a
  guiding question before giving the fix.
- Record every misunderstanding found under **Gaps found** in `EXERCISES.md`. Later warm-ups and
  exercises should revisit those gaps.
- A chapter is only ticked in `TODO.md` once its exercises are done.
- **Next session start:** open with 3 quick recall questions on the most recently finished
  chapter, favouring its open gaps.

### Every 3 chapters (mini app)
- A tiny app over the last 3 chapters' models, framed as a **problem to solve**. The user
  decides which models and patterns apply and why, and Claude writes the plumbing.
- Use a different JS stack and ops/testing practice each time (deploy, stress test, E2E…). The
  plan is in `TODO.md` under *Mini apps*; agree on the stack and practice with the user before
  starting.

## Tracking progress
- **Start of session:** read `TODO.md` and the latest `CHANGELOG.md` entry to pick up where we left off.
- **`TODO.md`:** tick items as they are done and add new ones as they come up (chapters, open
  decisions, follow-ups). Keep the README progress table in sync when a chapter's status changes.
- **Missing tools:** when a task would need a tool that isn't installed (Python, Postgres, Docker,
  etc.), don't install it or silently work around it. Add it under *Tooling* in `TODO.md` and say
  so, then use an available alternative if one exists.
- **`CHANGELOG.md`:** before the last commit of a session, add or extend today's entry (newest
  first) with **Built**, **Decisions**, and **Next**. Use absolute dates, and write one entry per
  day even if several sessions happen that day.

## Layout
- `volumes/vN-slug/NN-slug/`. Chapter numbers restart per volume. Each volume is its own Postgres
  schema (`v1`, `v2`, `v3`); the loader sets `search_path` so a volume sees its own tables first,
  then earlier volumes. Never hard-code a schema prefix in chapter SQL.
- New chapters start as a copy of `templates/chapter/`.

## SQL conventions
- PostgreSQL (run through PGlite). Tables are singular snake_case (`party`, `party_role`), and
  primary keys are `<table>_id`.
- Subtypes: the supertype table plus a subtype table sharing its PK (e.g. `person.party_id` → `party`).
  Record in NOTES.md whenever another strategy is chosen. Exclusive subtypes use a discriminator:
  `party (party_id, party_kind)` is unique, and each subtype has a fixed `party_kind` plus a
  composite FK to that pair. Attribute-less subtypes become rows in a `*_type` hierarchy.
- Parties: `organization` and `person` key on `party_id`. Use the `party_display_name` view for
  a party's current name.
- `*_TYPE` entities become lookup tables, not enums, to stay faithful to the book.
- Effectivity: `from_date date not null`, `thru_date date` (null = still current).
- Verify with `npm run db:rebuild && npm run queries -- vN/NN` after any change.
