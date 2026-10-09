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
- **Questions for the user to think about** that come up while teaching go into the chapter's
  `EXERCISES.md`, section 0 "To ponder", tagged with their figure, but **at most 5 per
  submodel**: keep only the ones that test a main idea, and settle the rest in chat. Create
  `EXERCISES.md` from the template at the chapter's first figure if it doesn't exist.
- One figure per commit. `schema.sql` grows in book order, with a section header per figure.
- Never copy book prose or reproduce figures verbatim in committed files. Write notes in our own
  words. `book-refs/` is gitignored and must stay that way.

### After the reading (the user practises, one submodel at a time)
- Practice is **per submodel** (a group of figures that answer one set of business questions,
  e.g. Ch 2: parties/roles/relationships, contact mechanisms, communication events/case), not
  per chapter. Follow **`docs/practice.md`**: exam climbing Bloom's levels → reinforce gaps →
  practice scenario, scored on the 0–4 evidence scale.
- **Time budget: about 3 hours of practice per submodel.** Go over only when a gap still needs
  reinforcing, and say so first. Don't write more exercises than fit the budget.
- **Ask one question at a time** and wait for the answer.
- **Next session start:** open with 3 quick recall questions on the most recently finished
  submodel, favouring its open gaps.

### Design reference (the distilled output)
- The claude.ai doc **Universal Data Models — Design Reference**
  (https://claude.ai/code/artifact/4fa81da7-e02f-4ef5-863c-119128b4b4c5) is the single source of
  truth for what was learnt: a question index, the cross-chapter **Core patterns** table, one
  entry per submodel and the roadmap. Chat is temporary; anything worth keeping goes there.
- Repo files are the working material (figure transcriptions, SQL, exercises, logs). The doc
  holds the distilled answer to "what do I reach for when I face this problem?"
- When a submodel's practice ends, write its entry in seven sections: questions it answers
  (Apply) · core entities (Remember) · optional add-ons, each with the question that justifies
  it (Analyze) · design choices and why (Understand) · patterns used (Analyze) · pitfalls from
  the user's own mistakes (Evaluate) · practice scenario (Create).
- **Patterns first:** add a new pattern to Core patterns, or a new example to an existing row.
  Then add the submodel's questions to the question index and mark it Done on the roadmap.
- Cover every chapter, including Shipments, Invoicing and Accounting.

### Every 3 chapters (mini app)
- A tiny app over the last 3 chapters' models, framed as a **problem to solve**. The user
  decides which models and patterns apply and why, and Claude writes the plumbing.
- Use a different JS stack and ops/testing practice each time (deploy, stress test, E2E…). The
  plan is in `TODO.md` under *Mini apps*; agree on the stack and practice with the user before
  starting.

## Tracking progress
- **Start of session:** read `TODO.md` and the latest `CHANGELOG.md` entry to pick up where we left off.
- **Keep context small:** read files in slices (the section you need, found with grep), not
  whole. Later chapters reach earlier ones through `NOTES.md`, not schema or seed.
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
- **Keep keys simple (the user's preference, applied to every table):** surrogate primary keys and plain
  foreign keys. Don't add composite keys or composite FKs to enforce rules. Rules a plain FK can't
  express become a data-quality query in `queries.sql` (and a deliberate bad seed row that it
  catches). Deviating from the book to simplify is welcome; record it in NOTES.md.
- Subtypes: the supertype table plus a subtype table sharing its PK (e.g. `person.party_id` → `party`).
  Record in NOTES.md whenever another strategy is chosen. Exclusive subtypes get a discriminator
  column on the supertype (`party.party_kind`), checked by a data-quality query. Attribute-less
  subtypes become rows in a `*_type` hierarchy, with `applies_to_kind` when only some parties may
  use a type.
- Parties: `organization` and `person` key on `party_id`. Use the `party_display_name` view for
  a party's current name.
- `*_TYPE` entities become lookup tables, not enums, to stay faithful to the book.
- Effectivity: `from_date date not null`, `thru_date date` (null = still current). `thru_date` is
  **exclusive** (the first day no longer valid); store the book's inclusive thru dates +1 day. As-of
  test: `from_date <= d and (thru_date is null or thru_date > d)`.
- Verify with `npm run db:rebuild && npm run queries -- vN/NN` after any change.
