# Changelog

One entry per working session, newest first. Each entry covers what was studied, what was built,
and any decisions made.

## 2026-10-02

**Built**
- Fig 2.9 Party contact mechanism: `contact_mechanism` supertype with `telecommunications_number`
  and `electronic_address` subtype tables, a `contact_mechanism_type` lookup (with an added
  `applies_to_kind`), and dated `party_contact_mechanism` links carrying the do-not-solicit flag.
- Fig 2.10 Party contact mechanism (expanded): postal address became a third contact-mechanism
  subtype, plus dated purposes per link, a phone extension and an optional role type on the link,
  and `contact_mechanism_link`. Two new data-quality queries (purpose outside its link's period,
  link for a role the party never plays).
- Fig 2.11 Facility versus contact mechanism: `facility` (typed, nesting through `part_of`),
  `facility_role` and `facility_contact_mechanism`. The seed shows a warehouse with two
  addresses and one address shared by two buildings. A recursive query catches facility cycles.
- Fig 2.12 Communication event: participants through `communication_event_role`, several
  purposes per event, a status and a medium on each event, and the `valid_contact_mechanism_role`
  rule table. The relationship is now optional context.

**Decisions**
- Fig 2.10 folds the 2.8 address tables in: `postal_address` keys on `contact_mechanism_id` and
  `party_postal_address` is gone. The 2.8 queries now go through contact mechanism.
- Fig 2.11: dates added to facility roles and facility contact mechanisms (the book has none).
- Fig 2.12: the event subtypes became `contact_mechanism_type` rows (FACE_TO_FACE added), and
  event statuses are a group in the shared `status_type`.
- "To ponder" stays small: at most about 3 questions per figure, focused on the pattern. Small
  drift from the book (e.g. `contact_number`) is fine as long as NOTES.md records it.

**Next**
- Vol 1, Ch 2: remaining figures after 2.12 (the user sends them), then write the chapter
  exercises and distill section 0 into a short core set.

## 2026-09-30

**Built**
- Simplified keys across Ch 2 (the user asked for consistency): every table now has a single-column
  primary key and plain foreign keys. The composite keys and composite FKs from 2.2b–2.4
  (`party_kind` pairs, the `role_type_party_kind` table, passport → citizenship) are gone. The
  rules they enforced are now data-quality queries, each with a deliberate bad seed row to catch.
- Fig 2.5 Specific party relationships: `employment`, `customer_relationship` and
  `organization_rollup`, each linking two party roles. They answer "employee of whom?" from 2.4.
- Fig 2.6a Common party relationships: one generic `party_relationship` plus
  `party_relationship_type` (book's single from/to role type), a recursive `role_type_ancestor`
  view, and one hierarchy-aware data-quality query. The 2.5 tables stay for comparison.
- Table 2.5 loaded as seed data (the ABC corporate family), giving the org chart a two-level
  hierarchy. CUSTOMER is now an assignable role type, as the table uses it. Table 2.5 confirmed
  two of the assumed relationship directions (supplier, agent).
- Fig 2.7 Party relationship information: optional priority and status on relationships
  (`priority_type`, a parent-grouped `status_type`), and `communication_event` logged within a
  relationship. Three new data-quality queries (wrong status group, status contradicting dates,
  events outside the relationship period). Timestamps print in UTC.
- Fig 2.8 Postal address information: addresses linked to parties with dates, city/state/postal
  code/country as geographic boundaries nesting through a many-to-many association, a recursive
  `geographic_boundary_ancestor` view, and `country` folded into `geographic_boundary`.

**Decisions**
- Key style: surrogate PKs and plain FKs everywhere. Deviating from the book to simplify is fine
  as long as NOTES.md records it (CLAUDE.md updated).
- `thru_date` is exclusive; the book's inclusive thru dates are stored +1 day (CLAUDE.md updated).

**Next**
- Vol 1, Ch 2: remaining figures after 2.6a (the user sends them), then write the chapter exercises.

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
