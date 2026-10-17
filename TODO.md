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

## Workflow tooling

- [x] `npm run check` (`scripts/check.js`): figures classified and built, cards, doc-draft ticks, ponders, queries and data-quality checks, Anki export, changelog, uncommitted files; rewrites each chapter's STATUS.md tables (2026-10-16)
- [x] `STATUS.md` per chapter (Ch 2, Ch 3, template) and the skills `/figures`, `/overview`, `/close-submodel` (2026-10-16)
- [ ] Stop hook that runs `npm run check` at the end of a turn: held back by the user's choice; add it if steps still get skipped
- [x] Roadmap said Done for Ch 2 parties and contact mechanisms, but their practice isn't finished: STATUS.md was right, both rows set back to In progress (2026-10-17)

## Cards

- [x] Hooks and mantras for cards 1–6 (Claude's, at the user's request, 2026-10-16)
- [x] Card 1: mantra patched to unpack into party_classification (2026-10-16)
- [ ] Rewrite any mantra that fails to explode twice, in your own words
- [x] Anki export: `npm run cards:anki` → `docs/cards-anki.txt` (2026-10-16)
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
  - [x] Settle those 11 points (and Fig 2.14's point 1) against the book (2026-10-17): ten kept, point 11 merged the package and component rows
  - [ ] Overview discussion: `charge_kind` on discounts and surcharges (parked by the user 2026-10-17; base prices: mandatory, agreed), and Fig 2.14's bare event (its point 2)
  - [ ] Refactor candidates from the pricing walk-through (NOTES, point 1; no change until the user agrees): charge kind on base prices, split `per_uom_id`, features in the "price a line" query, depth as a tie-break
  - [x] 3.9a vs 3.9b: build 3.9b, the one Fig 3.11 keeps (the user's choice, 2026-10-16)
  - [x] 3.10: built as 3.11 keeps it (GOOD's subtypes + a COMPONENT association type), on assumptions (2026-10-16); 3.10b's PART discussed, not built. Point 11 settled 2026-10-17: COMPONENT is the one row for packages and assemblies
  - [ ] Submodel 4: pricing and costing (Figs 3.7–3.8): built 2026-10-16 (ponders 15–19); doc draft and card 8 done; walk-through of 3.7 from the user's own model 2026-10-17, parked at the column review (next: the value columns, price and percent); still to do: finish 3.7, 3.8, exercises
  - [ ] Submodel 5: product associations and parts (Figs 3.9–3.10): built 2026-10-16 (ponders 20–23); doc draft and card 9 done; walk-through of 3.9b from the user's own model 2026-10-17, paused at the substitute's direction (a/b/c); still to do: finish 3.9b, 3.10a (BOM), exercises
  - [ ] Refactor candidate from the associations walk-through (NOTES, point 11; no change until the user agrees): give the seeded starter kit a base price
  - [x] New workflow catch-up (2026-10-16): cards 8–9; doc drafts for Ch 3 submodels 1–5; architecture entries for Ch 2 and Ch 3; Core patterns gains a Ch 3 column and three patterns (rules as rows, exclusive arc, catalogue vs physical instance); question index and roadmap updated
  - [x] Doc drafts for Ch 2 postal addresses, facilities and geography (with its two pitfalls from item 49, roadmap row added) and communication events (the "learnt so far" notes regrouped into the seven sections; "To verify" kept) (2026-10-16)
  - [x] The other session told about the new rules (2026-10-16); it acknowledged with commit f361f95
  - [x] Ch 2: overall figure 2.14 shared (2026-10-16); transcribed with its "How it flows" (no SQL), two points to discuss
  - [x] Cards: a pattern card for P8 · catalogue vs physical instance (new in the doc's Core patterns) (2026-10-16)
  - [ ] Align the doc's Core patterns rows with cards P1–P8 at the overview
  - [ ] Ch 3 overview: the user's feedback on the points to discuss, the doc drafts and the cards; refactor from it; card pass (pattern cards, `npm run cards:anki`); then practice resumes
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
