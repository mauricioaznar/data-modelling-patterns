# Changelog

One entry per working session, newest first. Each entry covers what was studied, what was built,
and any decisions made.

## 2026-10-18

**Built**
- Ch 4 (Ordering Products) started from the template, with its first three figures (photos):
  4.1 standard order model, 4.2 orders and order items, 4.3 sales order parties and contact
  mechanisms. All transcribed into NOTES, each with its "To check against the book" list.
- Fig 4.1 transcribed, not built: the book's straw man (twin sales and purchase models), which
  4.2 replaces.
- Fig 4.2 built: `"order"` (quoted, a reserved word) with `order_kind`, `order_item` (line
  number, agreed unit price, for a product or a feature, "ordered for" another item) and
  `sales_order_item` (the customer's PO number). Seed: Table 4.2's order 12560 and seven more.
  Queries: the order as a tree, agreed vs list price, one query for both directions, and six
  data-quality checks, each catching a deliberate bad row.
- Fig 4.3 built: `sales_order` (placed by, taken by, bill-to as party roles; placed using,
  taken via, billed to as contact mechanisms), ship-to on `sales_order_item`, and `order_role`
  with `order_role_type` and percent shares. A new PLACING_CUSTOMER role type, Contoso's St.
  Louis depot, a `contact_mechanism_display_name` helper view. Queries: who placed, took and
  pays (the placer when no bill-to), where each item ships, salespeople's credit, every party on
  an order, and five data-quality checks.
- Ponders 1–3; ER diagram; design reference entry *Orders, items and order parties* (draft),
  Core patterns gains a Ch 4 column and two patterns (specific lines beside a generic role;
  snapshot of an agreed value), a question index row, roadmap Ch 4 In progress. Card 10; Anki
  export 20 cards.
- The data explorer now reads a quoted table name (`create table "order"`).
- Figs 4.4–4.6 (photos), each transcribed with its "To check against the book" list:
  - 4.4 built: `purchase_order` and `purchase_order_item`, the mirror of 4.3; role types
    PLACING_BUYER, BILL_TO_PURCHASER and SHIP_TO_BUYER under a new BUYER grouping; three more
    purchase orders (a drop ship, a wrong hat, a role not yet current) and the clerk's mistake
    on 12567. Queries: who placed, took and pays; where purchase items ship (a drop ship
    labelled); Contoso's orders both ways; four data-quality checks, 4.3's copied.
  - 4.5 built beside 4.3 and 4.4: `order_item_role` (+ type), `order_contact_mechanism` and
    `order_item_contact_mechanism` on Ch 2's purpose types; order 12571 recorded the generic
    way only. Queries: an order from the generic tables, who pays from whichever model holds
    it, item parties no column could hold, and three checks (duplicates, one per order, one
    job in both models).
  - 4.6 built: `order_adjustment` (+ type, the six subtypes on top) and `sales_tax_lookup`.
    Queries: order 12561's bill, every order's value after adjustments, the tax rate per line
    from ship-to boundaries and product categories against the rate charged, four checks.
- Ponders 4–5 (submodel 1) and 1–3 (submodel 2); ER diagram extended. Design reference:
  submodel 1's entry revised for 4.4–4.5, a new *Order adjustments* entry (draft), Core
  patterns gains Ch 4 examples on six rows and a new pattern (typed rows instead of columns),
  a question index row, roadmap "2 submodels so far". Card 10 now Figs 4.1–4.5, card 11 new;
  Anki export 21 cards.
- Card status in the Anki export: each submodel and architecture card reads its status from
  its chapter's STATUS.md (draft until Overview is ticked, reviewed after, done once Doc done
  is ticked), gets a `dm::status::…` tag, and goes to *Drafts* or *Settled* under Submodels or
  Architecture. Today: 4 settled (Ch 2's submodels), 9 drafts. STATUS.md parsing moved from
  `check.js` to a shared `scripts/status.js`.
- Tables 4.3–4.7 (photos, shared after their figures were built): noted under Figs 4.2–4.4.
  Order 12560 gets Table 4.3's date (June 8, 2001) and Table 4.5's parties and addresses;
  purchase order A2395 is seeded as 2395 (Ace Cleaning Service, ABC Retail Store). Table 4.4
  seems to put a feature on its product's own line (point 2); Table 4.7's buyer roles are all
  ABC's (point 7).
- Figs 4.7–4.11 (photos, with Tables 4.9–4.14), each transcribed with its "To check" list:
  - 4.7 built: `order_status` (a dated history, the ORDER_STATUS group in Ch 2's
    `status_type`) and `order_term` on a general `term_type`, each for the order or one
    line; Table 4.9's terms; a cancellation-window query; four checks.
  - 4.8 built: `order_item_association`, FKs on the two item subtypes; Table 4.10's orders
    13480 and 23490; 4.4's drop ship linked; backorders derived beside the status recorded;
    three checks.
  - 4.9 built: `requirement` with two discriminators (customer or internal; product or work),
    `product_requirement`, `desired_feature` on Ch 3's features, dated `requirement_role`,
    `requirement_status`, `order_requirement_commitment` with a quantity; Table 4.11 seeded;
    a query matching needs to catalogue products by feature; five checks. A new Ch 3 feature,
    "Formatted".
  - 4.10 built: `request` (RFI, RFP, RFQ as `request_type` rows), `request_item`,
    `requirement_request`, `request_role`, `responding_party`; Tables 4.12–4.13; two PC
    repair vendors; four checks.
  - 4.11 built: `quote` (issuer and receiver columns, `quote_type` rows), `quote_item`
    (product or work effort under the drawn arc, answering a request item, accepted through
    `order_item.quote_item_id`), `quote_role`, `quote_term` on `term_type`; Table 4.14; a
    box of pencils added to Ch 3's catalogue; the need-to-order trail; three checks.
- Ponders: submodel 3 has 4, submodel 4 has 4, submodel 5 has 3; ER diagram extended. Design
  reference: three draft entries (*Order status, terms and item associations*,
  *Requirements*, *Requests and quotes*), Core patterns gains Ch 4 examples on seven rows and
  a new pattern (status history), three question index rows, roadmap "5 submodels so far".
  Cards 12–14; Anki export 24 cards.

**Decisions**
- A card joins the morning study loop at its chapter's overview, not when its figures are
  built (the user's call): drafts are Claude's reading, there to look up, kept out of study
  by a Drafts options preset with zero new cards and reviews. Moving a card from Drafts to
  Settled stays a manual step in Anki (re-imports don't move cards; AnkiConnect turned down),
  done at each overview's close. Ch 2's submodel cards count as settled: they were built
  before overviews existed.
- Submodel 1 is *orders, items and order parties* (Figs 4.1–4.5): 4.4 and 4.5 answer its
  questions. Submodel 2 is *order adjustments* (Fig 4.6).
- Readings left for the Ch 4 overview (NOTES, points 1–12): 4.1 not built; an item names a
  product or a feature, not both (no arc drawn); every party line optional, with the bill-to
  falling back to the placer; ORDER ROLE identified by order + party + type; ORDER ROLE TYPE
  kept as its own lookup, though it triggers TODO's ROLE TYPE refactor; PURCHASE ORDER ITEM's
  ITEM DESCRIPTION read as ORDER ITEM's; buyer roles not checked as ours; 4.5 built beside
  4.3/4.4 (like Ch 2's 2.5 and 2.6a); direction-neutral order role types; an adjustment for
  the order or one item, not both; a percentage of the value before any adjustment; the tax
  lookup kept without dates.
- Submodel 3 is *order status, terms and item associations* (Figs 4.7–4.8; 4.7's text derives
  "backordered" from 4.8). Submodel 4 is *requirements* (Fig 4.9). Submodel 5 is *requests
  and quotes* (Figs 4.10–4.11).
- Statuses join Ch 2's shared `status_type` as groups, as Ch 2 foresaw, while each role type
  stays its own lookup (six now): both settle at the overview (points 5, 15).
- Readings left for the overview (NOTES, points 13–22): TERM VALUE optional; status and term
  for the order or one line (Fig 4.11's drawn arcs back it); TERM TYPE shared; the
  association sales-to-purchase only and without a quantity; the requirement's product line
  optional; Table 4.11's "2002" dates read as 2001 and 34988 beside 24905 (Table 4.13 pairs
  them); "owner" of a part; Table 4.12's 23498 read as 2002 and 38967 as an RFP; Table 4.14's
  36908 read as issued in 2002.

**Next**
- Share the rest of Ch 4's figures (agreements and the overall figure, presumably).
- Re-import `docs/cards-anki.txt` in Anki (cards 11–14 are new; card 10's note id changed
  with its figures, so delete the old card 10 note), then the one-time deck setup and moves
  in TODO.md (Cards).
- Still open from 2026-10-17: the associations walk-through (substitute direction), the pricing
  column review, and the Ch 3 overview discussion.

## 2026-10-17

**Built**
- Status review of every submodel (Ch 2 and Ch 3): all built, drafted and carded; none has
  finished practice; Ch 3 submodels 4–5 untested.
- Housekeeping: the P8 card item ticked in TODO (the card landed 2026-10-16), with the
  doc-alignment half kept open for the overview.
- Ch 3 overview started, book checks first (the user's call): all 11 points to discuss
  settled. Points 1 and 4–9 from the photos, 2, 3, 5 and 10 with the user checking the book,
  11 from the user's photo of the text after 3.10b. Ten kept as read; point 11 changed the SQL.
- Point 11 (Figs 3.9b, 3.10a): the MARKETING_PACKAGE and COMPONENT association rows merged into
  one COMPONENT row. Seed, queries (the component check no longer insists on goods), NOTES,
  card 9, the Anki export and the doc entry follow.
- Fig 2.14 point 1 kept by reasoning: the facility contact mechanism line means CONTACT
  MECHANISM (its labels, and a link entity needs both ends).

**Decisions**
- Design reference roadmap: Ch 2 parties and contact mechanisms set back from Done to In
  progress. STATUS.md was right: their practice (scenarios, the gaps at 2) isn't finished.
- MARKETING PACKAGE is PRODUCT COMPONENT's other name, apt only once PART takes the
  assemblies. We keep no PART (as 3.11), so one link carries kits and BOMs; telling them
  apart is what PART is for.

- Pricing walk-through (submodel 4, Fig 3.7) from the user's own model: price components,
  base-price competition, conditions and how they activate (walk-up trees, plain checks,
  AND). New progress rows for submodel 4 (four at 2, charge kind at 1); parked at the column
  review. Refactor candidates noted in NOTES (point 1), none applied: the user asked for no
  model changes yet.
- Associations walk-through (submodel 5, Fig 3.9b) from the user's own model, one fact at a
  time after a five-fact opener proved too much: the replacement link, the typed table (like
  party relationship), the kit's rows and where its quantity lives. The user's question on kit
  pricing (the parts' prices don't stack; a kit has its own price components) found that the
  seeded starter kit has no price: a refactor candidate in NOTES (point 11), not applied. New
  progress rows for submodel 5 (two at 2, two at 1) and ponder 24. Paused by the user at the
  substitute's direction.

**Next**
- Resume associations at the paper question (substitute direction, a/b/c); then the typed
  table's cost (ponder 20) and the BOM explosion (3.10a). Retest the feature vs product line.
- Resume the pricing column review at the value columns (price, percent); retest base
  competition and activation cold.
- Ch 3 overview, discussion: charge kind on discounts and surcharges (parked), and Fig 2.14's
  bare event. Then drafts and cards feedback, refactor, card pass.
- Re-import `docs/cards-anki.txt` in Anki (card 9 changed).

## 2026-10-16

**Built**
- Hooks and mantras for all six recall cards, written by Claude at the user's request (the
  user first kept card 3, then asked for all). Card 1's mantra patched (the user's call) to
  unpack into party_classification.
- `npm run recall:anki`: exports `docs/recall.md` to an Anki import file (tab-separated, HTML,
  13 cards: 6 submodels and 7 patterns).
- Recall card for the parked postal addresses, facilities and geography submodel (Figs 2.8,
  2.11), hook and mantra by Claude at the user's request. It slots in as Card 3, so the cards
  are renumbered in chapter order (old 3–6 are now 4–7; mentions above use the old numbers).
  The Anki export now reads CRLF checkouts too (14 cards).
- Anki export ready to scale: subdecks *Data Models::Submodels* and *Data Models::Patterns*,
  a stable note id per card (volume, chapter and figures, or pattern number) so renumbering
  no longer duplicates notes, and `v1::ch02` tags. Card headings now carry the volume.
- Ch 3: the last figures shared (3.7 pricing, 3.8 estimated cost, 3.9a/b associations,
  3.10a/b parts, 3.11 overall) and transcribed into NOTES, each with its "To check against
  the book" list. Two more submodels proposed: pricing and costing, associations and parts.
- Ch 3 built: Fig 3.7 pricing (price components on two subtype axes, quantity breaks, order
  values, sale types, currency and time-frequency units, and a "price a line" query), Fig 3.8
  estimated cost (type hierarchy, product-or-feature arc, margin query) and Fig 3.9b product
  associations. Ponders 15–22.
- Ch 3 Fig 3.10a built as Fig 3.11 keeps it: `good.good_kind` (raw material, subassembly,
  finished good) and a COMPONENT association type, with a two-level BOM for the copier, an
  explosion query with a cycle guard and a raw-material-with-components check. 3.10b's PART
  discussed, not built. Ponder 23. The photos confirmed the 3.10–3.11 transcriptions; 3.11 had
  two unnamed lines (manufacturer, unit of measure), now in NOTES and "How it flows".
- Ch 2 Fig 2.14 (overall party model) shared and transcribed as an architecture figure, with
  its "How it flows" and two points to discuss (a stray line, the bare event).
- Recall cards 8 (pricing and costing) and 9 (associations and parts); Anki export 16 cards.
- Design reference doc: drafts for the five Ch 3 submodels, architecture entries for Ch 2 and
  Ch 3, a refreshed study loop, a Ch 3 column and three new rows in Core patterns (rules as
  rows, exclusive arc, catalogue vs physical instance), six question-index rows, Ch 3 In
  progress on the roadmap.
- Design reference doc, Ch 2 catch-up: a draft for postal addresses, facilities and geography
  (with its two pitfalls from item 49, and a roadmap row), and the communication events entry
  regrouped from its "learnt so far" notes into the seven sections ("To verify" kept).
- The other session was told about the new rules; it acknowledged with commit f361f95.
- Deterministic workflow: `npm run check` (`scripts/check.js`) checks each chapter against the
  rules (figures classified and built, cards, doc-draft ticks, ponders, every query runs, every
  data-quality check catches a bad row, Anki export current) and rewrites the generated tables
  in its `STATUS.md`. STATUS.md for Ch 2, Ch 3 and the template; the skills `/figures`,
  `/overview` and `/close-submodel`; `recall.js` and `parseQueries` split out so scripts
  share them. Tested by breaking eight things on purpose: all caught.
- "Recall" renamed to **cards** (the user's call): `docs/cards.md`, `docs/cards-anki.txt`,
  `scripts/cards.js`, `scripts/cards-anki.js`, `npm run cards:anki`, and every mention in
  CLAUDE.md, the skills, the checker, TODO, README and practice.md. Anki note ids are
  unchanged, so importing the new file updates the notes. Entries above keep the old names.
- Pattern card P8 (catalogue vs physical instance), the Core patterns row from Ch 3 that had
  no card.
- **Architecture cards** for Ch 2 (Fig 2.14) and Ch 3 (Fig 3.11) under a new *Deck:
  architecture* in `docs/cards.md`, with S · W · T · D read as hubs, hand-overs, the naive
  mistake and the drawing with lines in from earlier chapters. The Anki export gains a
  *Data Models::Architecture* subdeck (note ids `dm-vN-chNN-arch`; 19 cards), and
  `npm run check` fails a chapter whose "How it flows" has no architecture card and shows it
  on the `A` row. The /figures and /overview skills, CLAUDE.md and the STATUS template say so.

**Decisions**
- `docs/recall.md` stays the source of truth; Anki is a generated copy, re-imported on change.
- Cards follow chapter order; the stable note ids make renumbering safe.
- Cards become part of the workflow (the user's call): one per submodel after its
  walk-through, and a card pass at the end of each chapter (CLAUDE.md).
- Figs 3.7–3.11 accepted as read. The doubtful readings become "points to discuss after the
  overview", and any refactor waits until then. CLAUDE.md now says to always aim for
  Silverston's intention (the user's rule).
- Build 3.9b, not 3.9a (the user's choice). 3.10a vs 3.10b was to wait for the renaming
  passage; superseded below, since 3.10 was built on assumptions under the new rule.
- Workflow reorganised (the user's call), replacing the card rule above: when images arrive,
  Claude builds everything on its own reading, with no confirmation gate. That means the
  transcription, the SQL, a *Draft (assumptions)* doc entry (the five sections the figures can
  answer) and the recall card. The chapter overview collects feedback, drives the refactor and
  holds the card pass. Practice then finishes the doc entry (pitfalls, scenario) and swaps each
  card's Trap for a real mistake. CLAUDE.md, `docs/practice.md` and `docs/recall.md` updated.
- New category, **architecture figures** (the user's call): a chapter's last, overall figure
  gets no SQL, just a short "How it flows" in NOTES and an architecture entry in the doc.
  Ch 3's is written under Fig 3.11.
- Architecture figures get a card too (the user's call, after asking where they were): the
  Map warm-up only chains the chapters, so nothing scheduled the hubs, the plug-ins from
  earlier chapters or the alternates kept.
- `/close-submodel` checks the card against NOTES.md (the user's call): S, D, W, T and the
  mantra against the submodel's transcriptions and design decisions, and the architecture
  card against "How it flows" when it's the chapter's last submodel. NOTES wins unless
  practice proved NOTES wrong. Only the export step is scripted, so the check is Claude's.
- `/overview` runs the same check (the user's call): on the cards a point or a piece of
  feedback touches, as soon as it's agreed, and on every card of the chapter once the
  refactor is finished.
- 3.10 built on assumptions under the new rule (point 11): no separate PRODUCT COMPONENT table,
  since 3.11 has none. Ponder 21's renaming passage may turn it into MARKETING PACKAGE reuse.
- The design reference doc's drafts answer some ponders, so it stays closed during exams,
  like the explorer (`docs/practice.md`). Roadmap uses its existing *In progress* for drafts.
- Steps become fixed procedures (the user's call): skills hold the order, `npm run check` is
  the gate before commits, STATUS.md holds the ticks no script can verify (the claude.ai doc).
  The Stop hook is held back until skipping proves to still happen.

**Next**
- The user re-imports the deck (19 cards, now with the architecture subdeck); mantras that
  fail twice get rewritten in the user's words.
- Card 1 shower question: Laura at the climbing gym, employment or generic relationship?
- Ch 3 overview: the 11 points to discuss (plus Fig 2.14's two), the doc drafts and cards 8–9;
  refactor from the feedback, then practice resumes (walk-throughs for submodels 4 and 5).

## 2026-10-15

**Built**
- `docs/recall.md`: a 30-minute solo morning routine. One card per submodel (hook → mantra →
  hidden key in S · W · T · D shape: spine, why, trap, draw), Leitner boxes, a pattern deck and
  a log. Keys written for the six submodels so far; mantras left for the user.
- Ch 3 submodel 3: a concept session on inventory balances instead of the recall questions
  (the user's choice). Fig 3.6 NOTES now hold our working vocabulary (qoh, balance,
  movements, variance), the two consistency checks, and two discussed alternatives (leave qoh
  alone; two qoh columns).

**Decisions**
- Keep the book's variance convention: quantity_on_hand is updated, and the variance explains why.
- The repo stays the book's: simplify only when first building tables from a figure; after
  that, alternatives are discussed and noted, not adopted.

**Next**
- The user writes the six mantras; check each explodes into its key.
- Recall 1 (K-17 lot recall) when the user says so, then recalls 2–3.
- Ch 5: check receipt / issuance against inventory item; add the qoh = balance check.

## 2026-10-14

**Built**
- Ch 3 submodel 1 reinforce: classification primary flag through the diskettes' rows, then a
  garden-centre rose (2 → 3). Neighbourhood answered; classification and market interest await
  the user's OK to close. Taught the row-to-sentence habit for link tables.
- Ch 3 submodel 2 (product features): mental-model walk-through through the seed, then
  questions (red pen, stapler/duplex, LaserNet, Commuter bike, hose, reels, laptops).
  Applicability 0 → 3, interaction 0 → 3 (dipped to 2 when applicability and interaction were
  mixed up), units of measure 0 → 3. Ponder 9a (the user's question): built-in part as feature
  or product.

**Decisions**
- CLAUDE.md: honesty over flattery, in a light mood (the user's request).
- Overlapping scopes and quantity_on_hand vs variance: the table doesn't record the convention;
  it has to be decided and written down.
- Every tracker row of the three chapters reaches 4 before their mini app starts.
- The user chose to build mental models for submodels 2–3 before finishing submodel 1's reinforce.
- Configuration check order: applicability completes the chosen set (required + standard),
  then interaction rules run on it. Rules are not checked against applicability.
- Two products vs one with a selectable feature: separate barcodes mean separate goods.
- Conversion per product: reel as a product with a Length dimension, or an optional product on
  the conversion (the same local/global trick as interaction).

**Next**
- Submodel 3: both figures walked through. Scores: manufacturer vs supplier 2, reorder 2,
  inventory item 3, location + lot 2, variance 3. Next: the lot question (batch K-17 recall in
  Valencia, asked, unanswered), then reorder and supplier to 3, then neighbourhoods.
- Submodel 2: the neighbourhood question for product_feature (asked, unanswered), OK to close.
- Submodel 1: OK to close classification and market interest; reinforce rollup and good/service.

## 2026-10-12

**Built**
- Ch 2 submodel 3 (communication events and case) reinforce loop for case and work effort,
  explained through the seed, then a fresh scenario (Lucía's leak). Logged in
  `EXERCISES-log.md`; tracker evidence updated. Case stays at 2.
- Ponder item 56 (the user's question): case status has no date; when to keep a status history.
- Ch 2 submodel 2 (contact mechanisms) reinforce: non-solicitation explained through the seed,
  then a gym scenario (shared inbox, one member opts out); neighbourhood of
  `party_contact_mechanism`. Non-solicitation 2 → 3; effectivity stays 2 (thru + 1 day again).
  The parked neighbourhood thread for move vs typo and purpose is closed.
- Ch 3 submodel 1: soft ball (good vs service) and exam Q6 (bookshop coffee). Identification
  2 → 3; classification (primary flag missed a third time), rollup and good/service stay 2.

**Decisions**
- Dating a change to an undated attribute on a link (non-solicitation): end the link and open a
  new one on the same day, carrying its purposes over. Marketing is never a purpose.
- Test for whether an event triggers a work effort: after it, does someone have work to
  schedule and track (date, hours, budget)? The medium doesn't matter.
- Ordering a part can be left out as a work effort (the order itself is Ch 4).

**Next**
- Ch 3 submodel 1 reinforce loop, starting with the primary flag on the classification row.
- Ch 2 contact mechanisms: exercise 3a (asked, unanswered), then the scenario and doc entry;
  then submodel 1 (specific vs generic relationships).
- Lucía round finished (four-event sweep and case roles given on request, no score credit).
  Next: one fresh no-hint question for case → 3, then the submodel 3 practice scenario.

## 2026-10-11

**Built**
- Figs 3.2–3.4 confirmed against the book by the user.
  - 3.3: GOOD IDENTIFICATION links to GOOD, so a `good` subtype table (sharing `product_id`)
    now sits under `good_identification`; service codes removed; a data-quality query checks
    `product_kind` against it (bad row: the maintenance plan).
  - 3.4: the unit of measure is on DIMENSION only and optional; the data-quality query now
    flags units on non-dimensions (bad row: hourly billing).
- Figs 3.5 (suppliers, manufacturers, reorder guidelines) and 3.6 (inventory items, lots,
  containers, variances) transcribed from photos, confirmed, then built with schema, seed
  (bad rows for roles, overlaps, serials, lots, variances), queries, notes and diagram.
- Ch 3 `EXERCISES.md`: submodel 3 (suppliers and inventory) tracker rows, 5 "to ponder" items,
  practice scenario (bike-parts distributor).
- Ch 3 submodel 1 exam Q4 (Analyze) and Q5 (Evaluate): classification and market interest
  reached 3 in Q4; in Q5 classification and rollup fell back to 2 (missed dates + primary on the
  link, read a single parent column backwards). Identification 2 (table names, type vs code).
- Overview of Figs 3.5–3.6 in chat; discussed stored vs computed stock and where stock
  movements come in (Shipments, Work Effort).

**Decisions**
- Primary category stays "one per product": the book doesn't say one per what.
- SELECTABLE set read as "the product's selectable features of one feature type" (the book
  doesn't define it).
- Fig 3.5: FKs go to `organization`; supplier and internal-organization roles are data-quality
  queries. Fig 3.6: inventory subtypes as a kind column + nullable columns; the facility/container
  arc is a check constraint.

**Next**
- Ch 3 submodel 1: exam Q6 (Create), then reinforce the 2s: classification (dates + primary
  on the link), rollup (one parent vs many children), identification (cold recall of
  product → good → good_identification ← identification_type), product (good/service).
- Share the rest of Ch 3's figures.

## 2026-10-10

**Built**
- Vol 1 Ch 3 (Products) started: Figs 3.1–3.4 transcribed, then schema, seed (office-supply
  company with deliberate bad rows), queries, diagram and notes, one commit per figure.
  - 3.1 product (good/service as `product_kind`), life-cycle dates.
  - 3.2 category classification (dated, primary flag), many-to-many rollup with a
    cycle-safe ancestor view, market interest linking Ch 2 party types to categories.
  - 3.3 identification codes as rows, with a regex per identification type (addition).
  - 3.4 features, applicability, interactions (with a configuration check query), units of
    measure and conversions.
- Ch 3 `EXERCISES.md`: two submodels, comprehension tracker, 9 "to ponder" items as the exam
  pool, reinforce menu, and a practice scenario per submodel (bookshop-café, bicycle shop).
- Ch 3 submodel 1 exam, Q1–Q3 (Remember, Understand, Apply): rollup 3; product,
  classification, market interest, identification 2. Logged in `EXERCISES-log.md`.
- Discussed in chat: a classification owned per department (owner party on the link, or
  per-department category types); the user's production category → type → product tree vs
  Silverston's link + rollup; feature applicability vs interaction, global interaction rules and
  how to check them against the catalogue.

**Decisions**
- Figs 3.2–3.4 were built before they were confirmed, at the user's request. The questions for
  the book are listed under each figure and in NOTES "Open questions".
- Surrogate `product_id`; the book's readable product codes are stored as SKU identifications.
- `product.uom_id` added by `alter table` in the 3.4 section so the schema keeps book order.
- No department-owned classification and no primary flag on the rollup for now (the book only
  mentions the first in passing; the second would be our addition).

**Next**
- Check Figs 3.2–3.4 against the book; adjust the SQL if any reading was wrong.
- Share the rest of Ch 3's figures (they may add a third submodel).
- Ch 2 reinforce and scenarios still open.
- The user adds the missing Ch 3 pieces (figure checks, remaining figures) to complete the schema.
- Ch 3 submodel 1: exam Q4–Q6 (Analyze, Evaluate, Create), then reinforce the 2s; the primary
  flag on a temporary category came back in Q3.

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
- Postal addresses, facilities and geography (Figs 2.8, 2.11) parked until Shipments, by the
  user's choice; Ch 2 submodel 2 is now contact mechanisms only.
- Practice questions name the submodel only, with no concept or table hints.

- Ch 2 mixed recall session (9 questions, vet clinic): event roles, type/fact/rule layers,
  party supertype, relationship direction and contact mechanism subtypes 2 → 3; case 1 → 2.
  Tracker and log updated.

**Next**
- Ch 2 reinforce: specific vs generic relationships (shared-key relationship subtypes, dated
  pay history), non-solicitation on the link, case + work effort (follow-up work decided in an
  event), exclusive thru dates. Then the three practice scenarios.

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
