# Changelog

One entry per working session, newest first. Each entry covers what was studied, what was built,
and any decisions made.

## 2026-10-09

**Built**
- Practice process reworked around **submodels** with a **~3 hour budget each**
  (`docs/practice.md`, CLAUDE.md, chapter template): exam of about 6 questions, one at a time,
  climbing Bloom's levels (Remember → Create) → reinforce gaps → one practice scenario per
  submodel → entry in the design reference doc.
- Design reference doc on claude.ai (Universal Data Models — Design Reference): question index,
  Core patterns, one seven-section entry per submodel, roadmap. Party/role/relationship and
  contact mechanism entries drafted; communication event/case is a preview.
- Ch 2 trimmed: tracker regrouped into three submodels with a "Next" column (reinforce / recall);
  unanswered section 0 items and sections 1–9 made optional (only 3a kept); the section 9
  capstone replaced by three per-submodel practice scenarios.

**Decisions**
- About 3 hours of practice per submodel; go over only to close a gap, and agree first.
- At most 5 "To ponder" items per submodel while teaching.
- The design reference doc is the single source of truth for what was learnt; repo files are
  the working material.
- Cover every Vol 1 chapter, including Shipments, Invoicing and Accounting.

**Next**
- Ch 2 submodel 3 (communication events and case): cold retest of communication event, then
  reinforce case and work effort, then its scenario.

## 2026-10-08

**Built**
- Ch 2 reinforce loop, questions only. Subtype vs type row: cold retest in a new domain
  (payment methods), 2 → 3, neighbourhood answered, **closed**. Facility question asked, then
  parked at the user's request.
- Communication event (dental clinic video call): first put the participants in party
  relationship; after the role pattern was explained, the role and purpose rows were right.
  1 → 2.
- Communication event, Q4 (VIDEO channel): reuse-a-kind reasoning and the valid-role inserts
  right; kind name (ELECTRONIC_ADDRESS) and event → `contact_mechanism_type` needed showing.
  Said rule rows enforce on insert (they only feed a DQ query). Then switched to explanation
  at the user's request (the whole submodel: what / how / who / why / context / status). Own-words
  definition at the end: 2 → 3, to retest cold.

**Decisions**
- No new "To ponder" items during practice. Questions raised in chat get settled in chat and
  noted in the gaps log.
- A used type is never edited or deleted: retire it or add a new one (the FK already blocks
  deleting a type that rows still use).
- Keep the book's name `valid_contact_mechanism_role` (both its columns are types, but no rename).
- Ask one question at a time; stacked questions lost the user.

**Next**
- Cold retest of communication event (new domain, no hints) to close it; include "does a
  missing valid-role pair block the insert?". Then facility (parked) and the move vs typo
  neighbourhood.

## 2026-10-07

**Built**
- Exercise process in CLAUDE.md: exam → reinforce → capstone, scored on a 0–4 evidence scale.
- Concept tracker: step 0 at the end of each chapter builds a comprehension table with one row
  per concept, each listing the `schema.sql` tables it covers. Added to the chapter template.
  Ch 2's table now maps all of its tables to 19 rows.
- Ch 2 effectivity: 1 → 2 (Contoso rows right except the inclusive thru date; discussed why
  we store exclusive thru dates).
- Data explorer (`npm run explore`, http://localhost:4317). It loads every chapter into an
  in-memory PGlite and lets you browse tables grouped by figure, follow foreign keys in both
  directions ("referenced by"), read rows by label instead of id, and run SQL. Reload resets it.
  `loadChapters` moved into `scripts/db.js`, so the rebuild and the explorer share it.
- Ch 2 reinforce loop: move vs typo 1 → 3 and purpose 2 → 3 (neighbourhood question parked);
  contact mechanism + subtypes 1 → 2; subtype vs type row back to 1 (the gap reappeared: a
  type with no attributes of its own was read as needing its own table, then as having no value).
- Context trimming: the end-of-chapter process moved from CLAUDE.md to `docs/practice.md`
  (CLAUDE.md 9.1 KB → 5.4 KB). Ch 2 `EXERCISES.md` split: tracker and open threads at the top,
  answers and the gaps log in `EXERCISES-log.md`. Templates and README updated. Fixed a junk
  first line in Ch 2 `EXERCISES.md` (a bad regex in b2727e2).

**Decisions**
- Concepts first, implementation later. No long exercise lists that won't get done.
- "Understood" means: what a table or pattern is for, how it relates to its neighbours, and
  spotting a wrong implementation. No attribute-level depth, to avoid overlearning; concepts
  can be revisited later.
- A row below 3 is a gap. Reinforce it in a loop, explaining through the chapter's own schema,
  until the evidence reaches 3 and the user agrees they understand it.
- Before closing a row, ask a short neighbourhood question: which entities it connects to, and
  what each connection means.

**Next**
- Continue going table by table through the contact-mechanism group (next: `contact_mechanism_type`),
  to close subtype vs type row (kind = subtype table, type = category row). Then the parked
  neighbourhood question, the other level-1 rows (facility, communication event), the level-0
  rows, and the capstone.

## 2026-10-06

**Built**
- Ch 2 exercises: warm-up recall (3 questions) and the whole section 0 core set (12 items)
  done. Answers and review notes are recorded in EXERCISES.md.
- Five gaps logged: subtype vs type row (later stated correctly in item 44), the as-of
  condition (especially null `thru_date`), arguing for the generic model without weighing its
  cost, relationship ends (direction and INTERNAL_ORGANIZATION), and reading generic PARTY
  RELATIONSHIP as single-table inheritance.

**Decisions**
- Relationship direction: working rule is to read the type as a sentence, subject → object.
  Not every type is "us → them". Whether this is Silverston's rule is still open (item 27).
- Exercise rules (set by the user): explain the book's reasoning before any pragmatic critique,
  push back plainly when an answer is wrong, and check the schema before claiming how the
  model works.
- The user's question about rules for purpose types is parked on section 6 exercise 4.

**Next**
- Section 3 (Spot the flaw), starting at 3a, then sections 5–6 (queries, breaking the model).
- Then sections 1, 2, 4, 7, 8 and the capstone; recheck the open gaps along the way.

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
- Fig 2.13 Communication event follow-up: `communication_case` groups events, with its own
  roles and status; `work_effort` (minimal, Ch 6 preview) links to events many-to-many. This was
  the last figure of Ch 2.
- Ch 2 end-of-chapter exercises (sections 1–9) and a 12-question core set for section 0.

**Decisions**
- Fig 2.10 folds the 2.8 address tables in: `postal_address` keys on `contact_mechanism_id` and
  `party_postal_address` is gone. The 2.8 queries now go through contact mechanism.
- Fig 2.11: dates added to facility roles and facility contact mechanisms (the book has none).
- Fig 2.12: the event subtypes became `contact_mechanism_type` rows (FACE_TO_FACE added), and
  event statuses are a group in the shared `status_type`.
- Fig 2.13: CASE is `communication_case` (reserved word); `work_effort_type` added for the
  work-effort subtypes.
- "To ponder" stays small: at most about 3 questions per figure, focused on the pattern. Small
  drift from the book (e.g. `contact_number`) is fine as long as NOTES.md records it.

**Next**
- The user works through the Ch 2 exercises; review them like a PR and record gaps.
- Next session opens with 3 recall questions on Ch 2.
- Then Ch 3 (Products).

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
