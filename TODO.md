# TODO

Tick items off (`- [x]`) as they are done; add new items as they come up.
Session-by-session history lives in [CHANGELOG.md](CHANGELOG.md).

## Tooling

The machine currently has Node only; everything runs through PGlite. These tools are not
blockers, but each one unlocks something:

- [ ] **Python 3**: handy for scripted file edits and data generation, and needed by some tools
- [ ] **PostgreSQL 16+** (native, including `psql`): inspect the DB interactively and compare behaviour against PGlite
- [ ] **Docker Desktop**: throwaway Postgres containers, and later the per-chapter app/deploy experiments
- [ ] **A DB GUI** (DBeaver or pgAdmin): browse tables and relationships visually
- [ ] **VS Code Mermaid preview extension**: render `diagram.md` files locally
- [x] **Data explorer** (`npm run explore`, `tools/explorer/`): a disposable browser UI over an
  in-memory copy of every chapter. Browse rows, follow foreign keys both ways, run SQL.

## Vol 1: A Library of Universal Data Models for All Enterprises

Chapter titles are from memory; verify them against the book's table of contents.

- [ ] Ch 01: Introduction (read only; key conventions go into README notation)
- [ ] Ch 02: People and Organizations *(figures 2.1–2.13 built; exam done; practice trimmed 2026-10-09 to three submodels, ~3 h each)*
  - [ ] Submodel 1: parties, roles and relationships (reinforce specific vs generic relationships, recall relationship naming + 2 rows, scenario, doc entry)
  - [ ] Submodel 2: contact mechanisms (reinforce non-solicitation, exercise 3a, scenario, doc entry)
  - [ ] Postal addresses, facilities and geography (Figs 2.8, 2.11): parked 2026-10-09 by the user's choice; practise them with Shipments
  - [ ] Submodel 3: communication events and case (reinforce case + work effort, scenario, doc entry)
  - [ ] Confirm PERSON NAME → PERSON NAME TYPE optionality against the book
  - [ ] Try enforcing non-overlapping from/thru periods (exclusion constraint with `btree_gist`; check PGlite support)
  - [ ] Refactor `role_type` into a ROLE TYPE supertype with a PARTY ROLE TYPE subtype once another role-type subtype appears (see NOTES, Fig 2.4)
- [ ] Ch 03: Products *(Figs 3.1–3.4 built 2026-10-10; exercises ready; 3.2–3.4 still to check against the book)*
  - [ ] Submodel 1: product definition, categories, identification (Figs 3.1–3.3): exam, reinforce, scenario, doc entry
  - [ ] Submodel 2: product features (Fig 3.4): exam, reinforce, scenario, doc entry
  - [ ] **Next session:** confirm Figs 3.2–3.4 against the book, then fix the SQL if a reading was wrong:
    - [ ] 3.2: does PRODUCT CATEGORY ROLLUP really have no from/thru dates? Which side is parent ("made up of") and which child ("part of")?
    - [ ] 3.2: is the primary flag one per product, or one per product per purpose/dimension (catalogue vs sales analysis)?
    - [ ] 3.3: does GOOD IDENTIFICATION link to PRODUCT (not GOOD)? Are product + identification type its whole identifier?
    - [ ] 3.4: is PRODUCT → UNIT OF MEASURE mandatory or optional? PRODUCT FEATURE → UNIT OF MEASURE? PRODUCT FEATURE → PRODUCT FEATURE CATEGORY?
    - [ ] 3.4: is PRODUCT FEATURE INTERACTION → PRODUCT optional, and does the interaction really have no dates?
    - [ ] 3.4: check our reading of required / standard / optional / selectable against the book's text
  - [ ] Share the remaining Ch 3 figures (suppliers, inventory, pricing, costs, associations…)
- [ ] Ch 04: Ordering Products
- [ ] Ch 05: Shipments
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

- [ ] App 1: Vol 1 Ch 02–04 (Party, Product, Order): order entry. Suggested: Express + Knex, deploy to a DigitalOcean droplet
- [ ] App 2: Vol 1 Ch 05–07 (Shipment, Work Effort, Invoice): fulfilment and billing. Suggested: Fastify + Drizzle, k6 stress testing
- [ ] App 3: Vol 1 Ch 08–10 (Accounting, HR, DW): reporting. Suggested: Next.js + Prisma, Playwright E2E

## Vol 2: A Library of Universal Data Models by Industry Types

- [ ] Add chapter list once started

## Vol 3: Universal Patterns for Data Modeling

- [ ] Add chapter list once started

## Open decisions

- [ ] Should Vol 3 extend Vol 1's tables (current loader behaviour) or load into a clean slate?
