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
- **Any question, challenge or idea for the user to think about** that comes up while teaching
  goes into the chapter's `EXERCISES.md`, section 0 "To ponder", in the same change and tagged
  with its figure. The user is reading and may not answer in chat; nothing should be lost. Create
  `EXERCISES.md` from the template at the chapter's first figure if it doesn't exist.
- One figure per commit. `schema.sql` grows in book order, with a section header per figure.
- Never copy book prose or reproduce figures verbatim in committed files. Write notes in our own
  words. `book-refs/` is gitignored and must stay that way.

### End of a chapter (the user practises)
- The aim is **conceptual understanding at a high level**. Implementation depth comes later
  (mini apps). Don't build more exercises than will actually be done.
- **What "understood" means**, for every concept: the user can (a) say what the table or
  pattern is **for**, meaning the problem it solves and what the naive design gets wrong;
  (b) say how it **relates** to its neighbours, conceptually rather than column by column; and
  (c) **spot a wrong implementation** of it and say what data it would lose or corrupt.
  Attribute lists, syntax and exact cardinalities are out of scope. Going deeper risks
  overlearning; a concept can be revisited later (recall questions, mini apps, later chapters).
- **0. Build the concept tracker** as soon as the chapter's last figure is built, before the
  exam. In `EXERCISES.md` under *Gaps found*, add the comprehension table: one row per concept,
  covering every figure. A concept is a pattern or a small group of tables that make sense
  together (e.g. "PARTY RELATIONSHIP + TYPE"), not a single table. Each row lists the
  `schema.sql` tables it covers, so every table belongs to some row and understanding stays
  tied to how the schema was built. Aim for roughly 10–20 rows, all starting at 0. This table fixes the chapter's scope: don't test anything that isn't in
  it, and add a row only when a real gap shows it's missing. Then pick the exam questions so
  each main row gets at least one.
- **1. Exam (find the gaps).** Ask about 12 questions in chat, one at a time, covering every
  figure's main idea: what problem it solves and what the naive design gets wrong. Record
  answers in `EXERCISES.md`.
- **2. Reinforce (close the gaps).** Any row below 3 is a gap. Work through it in a loop:
  explain it **through the chapter's own schema** (open its tables and seed rows, and say why
  each table exists and why it's shaped that way), then ask a fresh question in a new setting
  with no hints. If the answer falls short, log it, explain again from a different angle, and
  ask another fresh question. A row is closed only when the evidence reaches 3 **and** the user
  agrees they understand it; either of us can reopen it. Use cheap formats: a quick sketch on
  paper, or Claude runs SQL and the user predicts the result. Write SQL by hand only when the
  concept lives in the query (e.g. as-of dates). No full schema rewrites; syntax errors don't
  teach modelling.
- **3. Capstone.** One small new-domain problem, modelled on paper and compared with the book.
- **Done when:** every main concept scores 3+ on the scale below, the capstone holds up, and
  no logged gap reappears when tested cold. Only then tick the chapter in `TODO.md`.
- **Don't include answers.** Review attempts like a pull request: say what's wrong, then ask a
  guiding question before giving the fix. Explain the book's reasoning before any pragmatic
  critique, and check the schema before claiming how the model works.
- Record every misunderstanding under **Gaps found** in `EXERCISES.md`, and keep the
  comprehension table current: score each concept on the **0–4 evidence scale**, citing the
  answer behind each score: 0 untested · 1 recognises (understood once explained, or picked from options) ·
  2 explains with help · 3 explains unprompted · 4 applies cold (new setting, later session,
  no hints). Target before moving on: 3+ on every main concept, with 4 coming from the capstone.
  Score strictly from evidence, not impressions.
- **Data explorer (`npm run explore`):** keep it closed for the exam and gap checks, and open
  for learning and for checking an answer *after* giving it from memory. An answer found with
  the explorer open scores 2 at most ("with help").
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
