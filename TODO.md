# TODO

Tick items off (`- [x]`) as they are done; add new items as they come up.
Session-by-session history lives in [CHANGELOG.md](CHANGELOG.md).

## Tooling

The machine currently has Node only; everything runs through PGlite. These tools are not
blockers, but each one unlocks something:

- [x] **Python 3** (3.9.6 found 2026-10-11): handy for scripted file edits and data generation, and needed by some tools
  - [ ] Not on the Git Bash PATH on 2026-10-18 (only the Microsoft Store alias answers `python`); Node did the scripted edits instead. Check where 3.9.6 lives and add it to PATH
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
- [x] Card status (the user's call, 2026-10-18): draft / reviewed / done from each chapter's STATUS.md, tagged `dm::status::…`; Submodels and Architecture split into *Drafts* (look up only) and *Settled*; a card joins the study loop at its chapter's overview, which settles it (cards.md, CLAUDE.md, the three skills)
- [ ] Anki, once, after the next re-import: create *Data Models::Submodels::Settled*, *::Architecture::Drafts* and *::Architecture::Settled* if the import didn't; give both Drafts an options preset with *New cards/day* 0 and *Maximum reviews/day* 0; move the existing cards: `"deck:Data Models::Submodels" tag:dm::status::draft` → *Submodels::Drafts*, `"deck:Data Models::Submodels" -tag:dm::status::draft` → *Submodels::Settled*, and both Architecture cards → *Architecture::Drafts*

## Vol 1: A Library of Universal Data Models for All Enterprises

Chapter titles are from memory; verify them against the book's table of contents.

- [ ] Ch 01: Introduction (read only; key conventions go into README notation)
- [ ] Ch 02: People and Organizations *(figures 2.1–2.13 built; exam done; practice trimmed 2026-10-09 to three submodels, ~3 h each)*
  - [ ] Submodel 1: parties, roles and relationships (reinforce specific vs generic relationships, still 2 on 2026-10-21: the deciding factor is how many kinds; Q13 (the CRM) asked, unanswered, opens the next session; recall relationship naming + 2 rows, scenario, doc entry)
  - [ ] Submodel 2: contact mechanisms (non-solicitation closed at 3 on 2026-10-12; next: exercise 3a (Q3 asked, unanswered), scenario, doc entry)
  - [ ] Postal addresses, facilities and geography (Figs 2.8, 2.11): parked 2026-10-09 by the user's choice; practise them with Shipments
  - [ ] Submodel 3: communication events and case (case vs work effort at 4 cold on 2026-10-21; event role → party, not party role, back to 2 the same day, self-caught, then 4 cold in a later session (Q12); scenario, doc entry)
  - [ ] Confirm PERSON NAME → PERSON NAME TYPE optionality against the book
  - [ ] Try enforcing non-overlapping from/thru periods (exclusion constraint with `btree_gist`; check PGlite support)
  - [ ] **Decided 2026-10-23 (Ch 4 NOTES, point 5): one `role_type` table with a `scope` column for all 18 role-type lookups (Ch 2's facility, communication event and case ones included), plus a scope check per role table; do it in Ch 4's refactor.** History: refactor `role_type` into a ROLE TYPE supertype with a PARTY ROLE TYPE subtype once another role-type subtype appears (see NOTES, Fig 2.4). Triggered 2026-10-18: Ch 4's ORDER ROLE TYPE, then ORDER ITEM ROLE TYPE (Fig 4.5), REQUIREMENT, REQUEST and QUOTE ROLE TYPE (Figs 4.9–4.11), AGREEMENT ROLE TYPE (Fig 4.12), then Ch 5's SHIPMENT RECEIPT ROLE TYPE (Fig 5.4) and ITEM ISSUANCE ROLE TYPE (Fig 5.5): nine role-type lookups now, each its own table (more since: Ch 6's work effort and timesheet role types, Ch 7's INVOICE ROLE TYPE and BILLING ACCOUNT ROLE TYPE, Ch 7 NOTES point 8); Ch 4 NOTES, points 5 and 15, decide at its overview (statuses went the other way: Ch 2's shared `status_type`)
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
  - [ ] Submodel 5: product associations and parts (Figs 3.9–3.10): built 2026-10-16 (ponders 20–23); doc draft and card 9 done; walk-through of 3.9b from the user's own model 2026-10-17, paused at the substitute's direction (a/b/c); 2026-10-21 random recall: Q11 (A and B substitute each other) answered later that day, direction 2 → 3 (the why after a follow-up); still to do: finish 3.9b, 3.10a (BOM), exercises
  - [ ] Refactor candidate from the associations walk-through (NOTES, point 11; no change until the user agrees): give the seeded starter kit a base price
  - [x] New workflow catch-up (2026-10-16): cards 8–9; doc drafts for Ch 3 submodels 1–5; architecture entries for Ch 2 and Ch 3; Core patterns gains a Ch 3 column and three patterns (rules as rows, exclusive arc, catalogue vs physical instance); question index and roadmap updated
  - [x] Doc drafts for Ch 2 postal addresses, facilities and geography (with its two pitfalls from item 49, roadmap row added) and communication events (the "learnt so far" notes regrouped into the seven sections; "To verify" kept) (2026-10-16)
  - [x] The other session told about the new rules (2026-10-16); it acknowledged with commit f361f95
  - [x] Ch 2: overall figure 2.14 shared (2026-10-16); transcribed with its "How it flows" (no SQL), two points to discuss
  - [x] Cards: a pattern card for P8 · catalogue vs physical instance (new in the doc's Core patterns) (2026-10-16)
  - [ ] Align the doc's Core patterns rows with cards P1–P8 at the overview
  - [ ] Ch 3 overview: the user's feedback on the points to discuss, the doc drafts and the cards; refactor from it; card pass (pattern cards, `npm run cards:anki`); then practice resumes
- [ ] Ch 04: Ordering Products *(Figs 4.1–4.17 shared and built 2026-10-18; ready for the overview)*
  - [x] Figs 4.1–4.3 (2026-10-18): 4.1 transcribed, not built (the book's straw man); 4.2 and 4.3 built; ponders 1–3; doc draft and card 10 for submodel 1
  - [x] Figs 4.4–4.6 (2026-10-18): 4.4 and 4.5 built and joined submodel 1 (Figs 4.1–4.5; card 10's heading grew); 4.6 built as submodel 2, order adjustments (card 11, doc draft); ponders 4–5 and submodel 2's 1–3
  - [x] Tables 4.3–4.7 (2026-10-18): the book's sample orders noted under Figs 4.2–4.4; 12560 dated and given Table 4.5's parties; purchase order A2395 seeded (as 2395)
  - [x] Figs 4.7–4.11 with Tables 4.9–4.14 (2026-10-18): 4.7–4.8 built as submodel 3 (order status, terms and item associations, card 12), 4.9 as submodel 4 (requirements, card 13), 4.10–4.11 as submodel 5 (requests and quotes, card 14); doc drafts for all three; Core patterns gains a status-history row; ponders 1–4, 1–4, 1–3
  - [x] Table 4.15 (2026-10-18): the book's quote lines on Fig 4.11; 35678 relinked to the RFP 38967; two new products (PC repair, Johnson black pen); point 22 revised
  - [x] Figs 4.12–4.13 with Table 4.16 (2026-10-18): built as submodel 6, agreements (card 15, doc draft); Core patterns gains Ch 4 examples on seven rows and a new pattern (amendment kept beside the original); ponders 1–5
  - [x] Figs 4.14–4.17 with Tables 4.17–4.19 (2026-10-18): 4.14–4.16 built as submodel 7, agreement terms and pricing (card 16, doc draft); 4.17 is the architecture figure (How it flows, architecture card, doc entry, MAP rewritten); Table 4.17 re-seeds 10002's items; Core patterns gains three patterns; ponders 1–5
  - [ ] Anki: card 10's note id changed with its figures (4.1–4.3 → 4.1–4.5): after re-importing, delete the old card 10 note
  - [ ] Ch 4 overview: the 40 points to discuss in NOTES (1–12 from Figs 4.1–4.6; 13–22: term value optional, status and term on order or item, shared status and term types, association sales-to-purchase only and without a quantity, the requirement's product line, Table 4.11's dates and 34988, who owns a part, Table 4.12's dates and types, Table 4.14's dates; 23–28: Table 4.16's 10002 against Ch 2's customer relationship, agreement subtypes as type rows, when a relationship-tied agreement may start, applicability with nothing of a kind, the addendum's arc and dates, an item inside an item; 29–40: 4.14–4.16 as their own submodel, the term kinds as TERM TYPE's top rows, Table 4.18's dates, AGREEMENT's thru date drawn mandatory, a cap and a discount at the same 1,000 reams, the pricing-program subtype table, Ch 3's queries reading agreement prices as list prices, Table 4.19's regions, the order-to-agreement view for sales lines only, 4.17's generic order parties (answers point 8), the commitment drawn to ORDER, what 4.17 leaves out). Point 2 gained Table 4.4's evidence, point 7 Table 4.7's, points 13–15 Fig 4.11's arcs and reused TERM TYPE
  - [ ] Pattern cards for the eight patterns new to Core patterns (specific lines beside a generic role; snapshot of an agreed value; typed rows instead of columns; status history; amendment kept beside the original; one more optional line, not a parallel entity; child dates inside the parent's; derived link instead of a foreign key), at the Ch 4 card pass
  - [ ] Ch 4 overview started 2026-10-18: point 1 (keep Fig 4.1 unbuilt?) asked, unanswered; paused when Ch 5's first photos arrived
- [ ] Ch 05: Shipments *(Figs 5.1–5.8 shared and built 2026-10-18; ready for the overview)*
  - [x] Figs 5.1–5.3 with Tables 5.1–5.7 (2026-10-18): 5.1–5.2 built as submodel 1, shipments, items and status (card 17), 5.3 as submodel 2, shipments and orders (card 18); doc drafts for both; Core patterns gains a Ch 5 column and two patterns (item-to-item hand-over with its own quantity; plan beside the facts); ponders 1–5 and 1–4
  - [x] Fig 5.4 with Table 5.8 (2026-10-18): built as submodel 3, packages and receipts (card 19, doc draft); Table 5.8 re-seeds 1146, 1149 and 3485 (its "4800 (transfer)") and purchase order 300 follows; Core patterns gains a pattern (shortcut line checked against the path); ponders 1–5
  - [x] Share the rest of Ch 5's figures (2026-10-18: Figs 5.5–5.8 with Tables 5.9–5.11; 5.8 is the architecture figure)
  - [x] Fig 5.5 with Table 5.9 (2026-10-18): built as submodel 4, issuances and picklists (card 20, doc draft); ABC Subsidiary's stock with opening counts; the qoh = balance check; two stray labels read as leftovers; Core patterns gains a pattern (cached balance beside its movements); ponders 1–5
  - [x] Figs 5.6–5.7 with Tables 5.10–5.11 (2026-10-18): built as submodel 5, shipping documents and route segments (card 21, doc draft); DOCUMENT with a type hierarchy; CARRIER as a party role; FIXED ASSET and VEHICLE ahead of Ch 8; 9002 seeded as ours; ponders 1–5
  - [x] Fig 5.8 (2026-10-18): architecture, no SQL; How it flows; doc entry and the Ch 5 architecture card; Vol 1 MAP rewritten
  - [ ] Ch 5 overview: the points to discuss in NOTES (44 in all; 27–44 from Figs 5.5–5.8: the stray labels, Table 5.9's 1,500 in 62002, the issuance's optionality, issuances only outward and from the ship-from site, the ninth role-type lookup, opening counts as variances, PICKLIST with no lines out, no arc on shipping documents, DOCUMENT TYPE beside the subtypes, 9002, Truck #1's shared run counted twice, the segment's optionality and number, CARRIER as a role, VEHICLE ahead of Ch 8, status times moved, 5.8's document line drawn the other way, 5.8's omissions as abbreviation; 1–26 below) (26 before Figs 5.5–5.8: optionality, the subtypes as type rows with ours/theirs flags, no facility, 4800's drop ship, the GOOD line optional, SHIPMENT STATUS's identifier, status types in Ch 2's table, Table 5.3's 4800 year, received vs delivered, what "in response to" may join, ORDER SHIPMENT's identifier, the text's "same place, same product" as checks, Table 5.5's 9200 line 3, ordered features as Ch 4's feature lines, which shipments fill which order lines, shipped features on the shipment line; 17–26: no line from package to shipment, Table 5.8's 4800 as 3485, Table 5.8 replacing our 1146 and 1149, the second 12901, 1146's diskettes in two packages, the receipt's optionality, the receipt's direct order line against ORDER SHIPMENT, receipts on incoming shipments only, SHIPMENT RECEIPT ROLE TYPE's own lookup, ORDER ITEM's attributes again)
  - [ ] Pattern cards for the four patterns new to Core patterns (item-to-item hand-over with its own quantity; plan beside the facts; shortcut line checked against the path; cached balance beside its movements), at the Ch 5 card pass
  - [x] Vol 1 MAP: Ch 5's section rewritten from Fig 5.8's How it flows and marked ✓ (2026-10-18): facilities sit on the route segment, not the shipment; hub table updated, DOCUMENT and FIXED ASSET rows added
  - [x] Check SHIPMENT RECEIPT and ITEM ISSUANCE link to INVENTORY ITEM (recalled 2026-10-15); add the qoh = balance data-quality query (Ch 3 NOTES, Fig 3.6 vocabulary). Both confirmed (Figs 5.4, 5.5) and the query added at Fig 5.5, over items with a receipt, an issuance or an opening count (2026-10-18)
  - [x] Ch 8: Fig 8.5 extends `fixed_asset` and `fixed_asset_type`, built early in Ch 5 for VEHICLE (Ch 5 NOTES, point 41). Done 2026-10-19: no change needed, Ch 5–6 already had every attribute and the subtypes as type rows
- [ ] Ch 06: Work Effort *(all figures shared and built 2026-10-19; overview next)*
  - [x] Figs 6.1–6.3b with Tables 6.1–6.5 (2026-10-19): 6.1–6.2 built as submodel 1, work requirements and roles (card 22), 6.3a as submodel 2, work effort generation (card 23); 6.3b transcribed, not built; doc drafts for both; Core patterns gains a Ch 6 column and a pattern (need apart from what fills it); ponders 1–3 and 1–5
  - [x] Figs 6.4–6.6 with Tables 6.6–6.10 (2026-10-19): 6.4 built as submodel 3, work effort breakdown (card 24), 6.5–6.6 as submodel 4, work effort assignments and time (card 25); doc drafts for both, Ch 6 examples on eight Core patterns rows; ponders 1–3 and 1–4
  - [x] Figs 6.7–6.13 with Tables 6.11–6.18 (2026-10-19): 6.7 built as submodel 5, work effort rates (card 26), 6.8–6.10 as submodel 6, inventory and fixed asset assignments (card 27), 6.11–6.12 as submodel 7, work effort standards and results (card 28); 6.13 the architecture (MAP rewritten, architecture card); doc drafts for all four, a new Core patterns row (general to specific, most specific wins); ponders 1–3, 1–3 and 1–4
  - [ ] Ch 6 overview: the 42 points to discuss in NOTES (points 28–42: rates as their own submodel, which rate wins, POSITION TYPE ahead of Ch 9, from date starred on asset links, Table 6.13's ids and units, Car or Truck #25, the fork lift booked before its effort, "pencil labeler" as a type, the "used to" arc, the goods, no quantity produced, the asset standard on FIXED ASSET in 6.13, what 6.13 leaves out, two status groups, billing after the raise; points 15–27: JOB, WORK EFFORT TYPE as kinds of work with standard hours, 51245 and "1200", dependency direction, Bob Jenkins's missing dates, Jane Smith's year, status keyed by type, the two 29005s, time outside assignments, thru date starred, submodel 4's figures, two places for "started at"; and the type drawn mandatory, REQUIREMENT TYPE beside the kinds, 2001 or 2002, Table 6.3's dates and roles before creation, purpose optional, pencils, 51298's blank, 32898's date, no effort types, 6.3a or 6.3b, WORK ORDER ITEM as a subtype set, one fixed asset per need, the overlapping role types)
  - [ ] Pattern cards for "need apart from what fills it" and "general to specific, most specific wins", at the Ch 6 card pass
- [ ] Ch 07: Invoicing *(all figures shared and built 2026-10-19; overview next)*
  - [x] Figs 7.1a–7.3b with Tables 7.1–7.6 (2026-10-19): 7.1a built as submodel 1, invoices and invoice items (card 29), 7.2–7.3a as submodel 2, invoice parties and billing accounts (card 30); 7.1b and 7.3b transcribed, not built; doc drafts for both, Core patterns gains a Ch 7 column; ponders 1–3 and 1–4
  - [x] Figs 7.4–7.10 with Tables 7.7–7.12 (2026-10-19): 7.4 built as submodel 3, invoice status and terms (card 31), 7.5–7.7 as submodel 4, billing for what was delivered (card 32), 7.8a as submodel 5, payments (card 33), 7.9 as submodel 6, financial accounts (card 34); 7.8b transcribed, not built; 7.10 the architecture (MAP rewritten, architecture card); doc drafts for all five, Ch 7 examples on eleven Core patterns rows, four question index rows; ponders 1–3, 1–4, 1–3, 1–3
  - [ ] Ch 7 overview: the 29 points to discuss in NOTES (points 13–29: term value drawn mandatory, Table 7.9's 30002 and its credit, no hours on time entry billing, Table 7.10's orders read as our purchases, two billing routes, the payment application arc, the $12.84 row, Table 7.11's tax and totals, 990023's quantity, no PAID status, the non-returnable feature line, an amount on adjustments only, 7.10's swapped captions, the bank number as a bigint key, one FK for receipts and checks, Table 7.12's other payments and ids; points 1–12 as before: the item type drawn mandatory, amount per unit and Table 7.3's tax, 7.1b's percentage (settled by 7.10), 30002 before Ch 4's order 12560, Table 7.4's addresses, sender and receiver role types, 30010 neither side ours, two more role-type lookups, Table 7.6's Joe or John, the role identifiers, 7.3a or 7.3b (settled by 7.10), who owes an account invoice)
- [ ] Ch 08: Accounting and Budgeting *(all figures shared and built 2026-10-20; overview next)*
  - [x] Figs 8.1–8.3b with Tables 8.1–8.5 (2026-10-19): 8.1 built as submodel 1, chart of accounts (card 35), 8.2–8.3b as submodel 2, accounting transactions (card 36); doc drafts for both, Core patterns gains a Ch 8 column and a pattern (event and its balanced postings); ponders 1–3 and 1–5
  - [x] Figs 8.4–8.7 with Tables 8.6–8.10 (2026-10-19): 8.4 joins submodel 1 (subsidiary accounts, card 35), 8.5 joins submodel 2 (depreciation methods, card 36), 8.6–8.7b built as submodel 3, budgets (card 37); 8.7a transcribed, not built; doc entries revised and drafted, Ch 8 examples on ten Core patterns rows, a question index row; ponders 4–5 (submodel 1) and 1–5 (submodel 3)
  - [x] Figs 8.8–8.12 with Tables 8.11–8.14 (2026-10-20): 8.8–8.9 join submodel 3 (reviews and scenarios, card 37), 8.10–8.11 built as submodel 4, budget usage and the ledger (card 38); 8.12 the architecture (MAP rewritten, architecture card); doc entries revised and drafted, Ch 8 examples on eight Core patterns rows, a question index row; submodel 3 ponders 2 and 5 swapped, submodel 4 ponders 1–4
  - [ ] Ch 8 overview: the 39 points to discuss in NOTES (25–39: the review's comment on the review, our reviewers, amount or percentage, the application's arc, scenarios on the item as first entered, the payment allocation's amount, order items by a plain column and 8.12's REQUIREMENT ITEM BUDGET ALLOCATION, our allocations, usage rolled up through parts, a type's shares adding to 100, our xref rows, budget against the books, 8.12 drawing 8.7a, 8.3a over 8.3b, 8.12's omissions; 13–24: no arc on the account references, a subsidiary on its parent's number, where 8.4 and 8.5 belong, date acquired starred, the sold engraver's open method, the budget description as comment, standard vs accounting period, 8.7a not built, revision numbers, the revised amount as a change, our departments and dates, item parts adding up; 1–12: accounts beyond Table 8.1, ABC Subsidiary's dates, no amount on the transaction, 39776's $700 or $900, source documents for Table 8.3, 46325 as a disbursement, the detail's account mandatory, the flag kept, 8.3b as an add-on, 45783's unnamed invoice, engraver or equipment, the subtypes as type rows)
  - [ ] Pattern card for "event and its balanced postings", at the Ch 8 card pass
- [ ] Ch 09: Human Resources *(Figs 9.1–9.14 shared and built 2026-10-20; overview next)*
  - [x] Figs 9.1–9.6 with Tables 9.1–9.5 (2026-10-20): 9.1 transcribed, not built (the naive emp dept model); 9.3–9.4 built as submodel 1, positions (card 39), 9.2 and 9.5–9.6 as submodel 2, employment, fulfillment and reporting (card 40); doc drafts for both, Ch 9 column in Core patterns with examples on twelve rows, two question index rows, roadmap In progress; ponders 1–5 and 1–5
  - [x] Figs 9.7–9.14 with Tables 9.6–9.12 (2026-10-20): 9.7–9.8 built as submodel 3, pay and benefits (card 41); 9.9 as submodel 4, payroll (card 42); 9.10–9.11 as submodel 5, applications and qualifications (card 43); 9.12a and 9.13 as submodel 6, performance and termination (card 44); 9.12b transcribed, not built; 9.14 the architecture figure (architecture card, MAP ✓); doc drafts for all four and the architecture entry; ponders 5, 4, 4 and 4
  - [ ] Ch 9 overview: the points to discuss in NOTES (1–52: 9.1 not built, 9.2 as a view, its dashed lines, Mike Johnson's employer before 1990, Sue Jones as Ch 8's Susan Jones, positions named by their type, Table 9.1's types, approval optional, text type ids, the title for Ch 6's types, standard hours on the class, Business Analyst's thru date, System(s) Administrator, UNION as a role, position status as a current value, the hiring company an ORGANIZATION, Mike Johnson's one clerk day, fulfillment by a person, job shares, Table 9.4's reversed headers, Dec 30, Table 9.4's slots, one primary line, Table 9.5's slots; thru rate, rate type in the key, Table 9.8 elsewhere, GG-5/6/8, two hourly rates, steps without history, John Smith's employer, undated vacation, days as a period, deductions on the paycheck, gross on the payment, check 1001 electronic, preferences on roles, no deposit/deduction arc, the source line's label, referrer optional, application status, the qualification key, skill level as rating, degree and certification groups, the note type box, MANAGER, 9.12b not built, `employment_termination`, employment status solid, claim status, what 9.14 leaves out, the three anchors)
- [ ] **Warehouse chapters set aside (the user's call, 2026-10-20):** after Ch 9 we jump to Vol 2 and come back later. Their cards carry `- **Kind:** OLAP`. Before starting, settle what replaces the submodel as the unit (a star schema?) and the practice shape. Check this list against the book's contents: the 2nd edition may run Ch 10–14 as warehouse and Ch 15 as implementing.
- [ ] Ch 10: Creating the Data Warehouse Data Model from the Enterprise Data Model
- [ ] Ch 11: A Sample Data Warehouse Data Model
- [ ] Ch 12: Additional Star Schema Designs
- [ ] Ch 13: Implementing the Universal Data Models

## Core app (the user's call, 2026-10-20)

One app over all of Vol 1's core OLTP models, Ch 2–9, in place of one app per three
chapters. Vol 2's industry types are extra documentation on top.

- **Gate (the user's decision, 2026-10-14):** before the app starts, every tracker row of Ch 2–9 reaches 4 (applies cold, later session, no hints).
- [ ] Agree on the problem, the stack and the ops/testing practice. Ideas from the old per-3-chapter plan: Express + Knex with a deploy, Fastify + Drizzle with k6 stress testing, Next.js + Prisma with Playwright E2E.
- [ ] Open: do the industry types get an app of their own, or versions of the core app?
- [ ] Integrity in the database (the user's call, 2026-10-23): the repo keeps simple keys and data-quality checks; the app enforces its rules as constraints (composite FKs such as role type + scope, exclusive arcs, triggers or exclusion constraints where keys can't reach, e.g. date overlaps and shares adding to 100), each with a negative test (an insert that must fail). The repo's data-quality checks are its spec.

## Vol 2: A Library of Universal Data Models by Industry Types

- [ ] Next after Ch 9's overview and practice (the user's call, 2026-10-20)
- [ ] A new Anki deck for the industry cards; agree on its name and shape before the first Vol 2 card. Vol 1's deck names stay as they are.
- [ ] Each industry chapter's star schemas get cards with `- **Kind:** OLAP`
- [ ] Add chapter list once started

## Vol 3: Universal Patterns for Data Modeling

- [ ] Add chapter list once started

## Open decisions

- [ ] Should Vol 3 extend Vol 1's tables (current loader behaviour) or load into a clean slate?
