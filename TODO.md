# TODO

Tick items off (`- [x]`) as they are done; add new items as they come up.
Session-by-session history lives in [CHANGELOG.md](CHANGELOG.md).

## Tooling

The machine currently has Node only; everything runs through PGlite. These tools are not
blockers, but each one unlocks something:

- [x] **Python 3** (3.9.6 found 2026-10-11): handy for scripted file edits and data generation, and needed by some tools
- [ ] **PostgreSQL 16+** (native, including `psql`): inspect the DB interactively and compare behaviour against PGlite
- [ ] **Docker Desktop**: throwaway Postgres containers, and later the per-chapter app/deploy experiments
- [ ] **A DB GUI** (DBeaver or pgAdmin): browse tables and relationships visually
- [ ] **VS Code Mermaid preview extension**: render `diagram.md` files locally
- [ ] **Node 18+ as the default**: the shell's nvm default is Node 16, which fails PGlite (`Blob is not defined`). Run with Node 20 (`nvm use 20`) or add an `.nvmrc`
- [x] **Data explorer** (`npm run explore`, `tools/explorer/`): a disposable browser UI over an
  in-memory copy of every chapter. Browse rows, follow foreign keys both ways, run SQL, and
  run each chapter's saved queries (Queries tab; data-quality checks get a red/green badge).

## Morning recall

- [x] Hooks and mantras for cards 1–6 (Claude's, at the user's request, 2026-10-16)
- [x] Card 1: mantra patched to unpack into party_classification (2026-10-16)
- [ ] Rewrite any mantra that fails to explode twice, in your own words
- [x] Anki export: `npm run recall:anki` → `docs/recall-anki.txt` (2026-10-16)
- [x] Card 3: postal addresses, facilities and geography, hook and mantra Claude's at the user's request; cards renumbered in chapter order, old 3–6 now 4–7 (2026-10-16)
- [x] Export: subdecks Data Models::Submodels and Data Models::Patterns, stable note ids, `v1::ch02` tags (2026-10-16)
- [ ] Anki, once: delete *Data Models::Recall* and its two empty subdecks (the old notes, without stable ids); keep *Data Models::Submodels* (7) and *Patterns* (7)
- [x] Workflow reorganised (the user's call, 2026-10-16): Claude drafts each submodel's card and doc entry when its figures land; card pass at the chapter overview (CLAUDE.md)
- [ ] Pick the next deck to add (shortlist 2026-10-16: Traps from the gaps logs, Scenarios as business → model, SQL idioms)

## Vol 1: A Library of Universal Data Models for All Enterprises

Chapter titles are from memory; verify them against the book's table of contents.

- [ ] Ch 01: Introduction (read only; key conventions go into README notation)
- [ ] Ch 02: People and Organizations *(figures 2.1–2.13 built; exam done; practice trimmed 2026-10-09 to three submodels, ~3 h each)*
  - [ ] Submodel 1: parties, roles and relationships (reinforce specific vs generic relationships, recall relationship naming + 2 rows, scenario, doc entry)
  - [ ] Submodel 2: contact mechanisms (non-solicitation closed at 3 on 2026-10-12; next: exercise 3a (Q3 asked, unanswered), scenario, doc entry)
  - [ ] Postal addresses, facilities and geography (Figs 2.8, 2.11): parked 2026-10-09 by the user's choice; practise them with Shipments
  - [ ] Submodel 3: communication events and case (reinforce case + work effort, scenario, doc entry)
  - [ ] Confirm PERSON NAME → PERSON NAME TYPE optionality against the book
  - [ ] Try enforcing non-overlapping from/thru periods (exclusion constraint with `btree_gist`; check PGlite support)
  - [ ] Refactor `role_type` into a ROLE TYPE supertype with a PARTY ROLE TYPE subtype once another role-type subtype appears (see NOTES, Fig 2.4)
- [ ] Ch 03: Products *(Figs 3.1–3.6 built and confirmed by 2026-10-11; submodel 1 exam done 2026-10-12)*
  - [ ] Submodel 1: product definition, categories, identification (Figs 3.1–3.3): exam done 2026-10-12; reinforce 2026-10-14: classification 2 → 3 and market interest neighbourhood done (both await the user's OK to close); paused by the user's choice to build mental models for submodels 2–3 first; still to do: rollup, good/service, identification neighbourhood, scenario, doc entry
  - [ ] Submodel 2: product features (Fig 3.4): walk-through and questions 2026-10-14, all three rows at 3; parked before the neighbourhood question (asked, unanswered); still to do: neighbourhood + OK to close, scenario, doc entry
  - [x] Confirm Figs 3.2–3.4 against the book (2026-10-11): 3.3 now links to a `good` subtype table; 3.4's unit of measure is on DIMENSION only
  - [ ] Submodel 3: suppliers and inventory (Figs 3.5–3.6, built 2026-10-11): both figures walked through 2026-10-14 (rows at 2–3); 2026-10-15: concept session on qoh / balance / variance (in NOTES); next: recall 1, the K-17 lot question (asked, parked by the user), supplier and reorder to 3, neighbourhoods, scenario, doc entry
  - [x] Share the remaining Ch 3 figures (2026-10-16: Figs 3.7–3.11, the last of the chapter)
  - [x] Figs 3.7–3.11 transcriptions accepted (2026-10-16); doubtful readings moved to "Points to discuss after the overview" in NOTES
  - [ ] Discuss those 10 points after the overview; refactor then if needed, aiming at Silverston's intention
  - [x] 3.9a vs 3.9b: build 3.9b, the one Fig 3.11 keeps (the user's choice, 2026-10-16)
  - [ ] 3.10a (product component) vs 3.10b (PART): decide after the user has read the 3.9b renaming passage (ponder 21), then build 3.10 and 3.11
  - [ ] Submodel 4: pricing and costing (Figs 3.7–3.8): built 2026-10-16 (ponders 15–19); still to do: walk-through, exercises
  - [ ] Submodel 5: product associations and parts (Figs 3.9–3.10): 3.9b built 2026-10-16 (ponders 20–22); still to do: 3.10, walk-through, exercises
  - [ ] New workflow catch-up: card 8 (pricing and costing) and card 9 (associations and parts), a *Draft (assumptions)* doc entry for every submodel that has none yet, and the Ch 3 architecture entry in the doc (from "How it flows" under Fig 3.11, no SQL)
  - [ ] Ch 2: check the book for an overall figure after 2.13; if there is one, it gets an architecture entry
  - [ ] Ch 3 overview: the user's feedback on the points to discuss, the doc drafts and the cards; refactor from it; card pass (pattern cards, `npm run recall:anki`); then practice resumes
- [ ] Ch 04: Ordering Products
- [ ] Ch 05: Shipments
  - [ ] Check SHIPMENT RECEIPT and ITEM ISSUANCE link to INVENTORY ITEM (recalled 2026-10-15); add the qoh = balance data-quality query (Ch 3 NOTES, Fig 3.6 vocabulary)
- [ ] Ch 06: Work Effort
- [ ] Ch 07: Invoicing
- [ ] Ch 08: Accounting and Budgeting
- [ ] Ch 09: Human Resources
- [ ] Ch 10: Creating the Data Warehouse Data Model from the Enterprise Data Model
- [ ] Ch 11: A Sample Data Warehouse Data Model
- [ ] Ch 12: Additional Star Schema Designs
- [ ] Ch 13: Implementing the Universal Data Models

## Mini apps (one per 3 finished chapters)

Each uses a different JS stack and a different ops/testing practice. The suggestions below
aren't final; agree on each one before starting.

- **Gate (the user's decision, 2026-10-14):** before a mini app starts, every tracker row of its three chapters reaches 4 (applies cold, later session, no hints).
- [ ] App 1: Vol 1 Ch 02–04 (Party, Product, Order): order entry. Suggested: Express + Knex, deploy to a DigitalOcean droplet
- [ ] App 2: Vol 1 Ch 05–07 (Shipment, Work Effort, Invoice): fulfilment and billing. Suggested: Fastify + Drizzle, k6 stress testing
- [ ] App 3: Vol 1 Ch 08–10 (Accounting, HR, DW): reporting. Suggested: Next.js + Prisma, Playwright E2E

## Vol 2: A Library of Universal Data Models by Industry Types

- [ ] Add chapter list once started

## Vol 3: Universal Patterns for Data Modeling

- [ ] Add chapter list once started

## Open decisions

- [ ] Should Vol 3 extend Vol 1's tables (current loader behaviour) or load into a clean slate?
