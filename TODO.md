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

## Vol 1: A Library of Universal Data Models for All Enterprises

Chapter titles are from memory; verify them against the book's table of contents.

- [ ] Ch 01: Introduction (read only; key conventions go into README notation)
- [ ] Ch 02: People and Organizations *(in progress: 2.1–2.7 done)*
  - [ ] Confirm PERSON NAME → PERSON NAME TYPE optionality against the book
  - [ ] Try enforcing non-overlapping from/thru periods (exclusion constraint with `btree_gist`; check PGlite support)
  - [ ] Refactor `role_type` into a ROLE TYPE supertype with a PARTY ROLE TYPE subtype once another role-type subtype appears (see NOTES, Fig 2.4)
- [ ] Ch 03: Products
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
