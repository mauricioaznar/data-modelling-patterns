# Changelog

One entry per working session, newest first. Each entry covers what was studied, what was built,
and any decisions made.

## 2026-09-30

**Built**
- Simplified keys across Ch 2 (the user asked for consistency): every table now has a single-column
  primary key and plain foreign keys. The composite keys and composite FKs from 2.2b–2.4
  (`party_kind` pairs, the `role_type_party_kind` table, passport → citizenship) are gone. The
  rules they enforced are now data-quality queries, each with a deliberate bad seed row to catch.

**Decisions**
- Key style: surrogate PKs and plain FKs everywhere. Deviating from the book to simplify is fine
  as long as NOTES.md records it (CLAUDE.md updated).

**Next**
- Vol 1, Ch 2: Fig 2.5 (specific relationships) is transcribed and built; then 2.6a (generic).

## 2026-09-29

**Built**
- Repo skeleton: PGlite-backed scripts (`db:rebuild`, `queries`, `sql`), chapter template,
  gitignored `book-refs/` for figure photos, README, and CLAUDE.md working rules.
- Restructured by volume (`volumes/vN-slug/NN-slug/`) because chapter numbers restart in each
  book. Each volume loads into its own Postgres schema (`v1`, `v2`, `v3`), with `search_path`
  falling back to earlier volumes.
- Added TODO.md (progress and tooling) and this changelog.

**Decisions**
- PGlite instead of Docker/Postgres, since neither is installed. Native tooling is tracked in TODO.md.
- Workflow: one figure at a time. The user photographs it, we transcribe and confirm, discuss,
  then implement. One commit per figure.
- The per-chapter mini-app and ops practice is deferred; the core deliverable is the SQL,
  the diagram, and the notes.

**Studied**
- Vol 1, Ch 2: Fig 2.1 Organization, 2.2a Person (flat), 2.2b Person alternate model,
  2.3 Party, and 2.4 Party roles, each transcribed, confirmed, implemented and committed separately.

**Decisions (Ch 2)**
- Attribute-less organization subtypes are a self-referencing `organization_type` table, not
  one table each.
- The 2.2a table is kept as `person_flat` so both person models can be queried side by side.
- Deviation: PHYSICAL CHARACTERISTIC includes `from_date` in its key (the book draws it as `*`).
- Identifying relationships are kept as composite keys (PASSPORT has a three-column FK to CITIZENSHIP).
- Dates print as `YYYY-MM-DD` (PGlite date parser override).
- 2.3: the 2.2b `person` became the Party subtype. `organization` and `person` now share
  `party_id`, and `party_kind` with composite FKs makes the database enforce exactly one subtype
  per party and classifications that match the party's kind.
- 2.4: roles are a `role_type` hierarchy plus a `role_type_party_kind` pairs table, so the
  database enforces which kind of party may play which role (and that only concrete roles are
  assigned). ROLE TYPE → PARTY ROLE TYPE is deferred as a refactor.

**Decisions (study flow)**
- The user reads a whole chapter first, then shares its diagrams, and Claude builds everything.
- At the end of each chapter, the user practises with small, varied exercises in `EXERCISES.md`
  (redraw from memory, explain why, spot the flaw, extend, queries, break it, trade-offs,
  own-words notes, capstone). No answers are given up front, and gaps found are tracked and revisited.
- Every 3 chapters, a mini app framed as a problem: the user makes the modelling decisions and
  Claude writes the plumbing, with a different JS stack and ops practice each time.

**Next**
- Vol 1, Ch 2: continue with the figures after 2.2b (toward PARTY).
