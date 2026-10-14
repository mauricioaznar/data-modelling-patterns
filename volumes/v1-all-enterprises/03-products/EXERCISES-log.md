# Vol 1, Chapter 3 — Exercises log

History behind the tracker in `EXERCISES.md`: answers to section 0 items and the dated gaps
log. Append new entries; read only when a row's evidence is needed.

## Section 0 answers

## Gaps log
Misunderstandings and reinforce attempts, oldest first.

### 2026-10-10: Submodel 1 exam, Q1 (Remember)
Stationery shop: pen 12-pack, gift wrapping, "Pens" + "Back to school", EAN + manufacturer part no.
- Product name on PRODUCT: right.
- Identification: right shape unprompted (an identification type table + a link row per code).
- Categories: named both, linked "Back to school" to party types via marketing (= market
  interest). Didn't name the product↔category link entity.
- **Gap:** called GOOD a subtype of the *category* ("office-utensils (good subtype)"). GOOD and
  SERVICE are subtypes of PRODUCT; gift wrapping was called "a product" but not a service.
- Brought in features (submodel 2, not in the scenario) and product-to-product links (a later
  Ch 3 figure, not shared yet).
- Follow-up (with help): GOOD/SERVICE are PRODUCT subtypes, pen → good, wrapping → service ✓.
  Product category classification + primary flag to stop double counting ✓. Called the
  primary flag a "discriminator" (that word is for the subtype column, e.g. `product_kind`).
  Scores: product 2, classification 2.

### 2026-10-10: Submodel 1 exam, Q2 (Understand)
"Business forms" under "Paper products" and "Printed materials"; dev proposes parent_category_id.
- Single parent column limits a category to one parent; book uses PRODUCT CATEGORY ROLLUP
  (many-to-many) ✓. Called the parent column "one to one" (it's many-to-one).
- Grand total double counting: named both causes unprompted: a product in several categories
  (fix: primary flag ✓) and a category under several parents ✓.
- Assumed "top level" means two levels; the rollup has any depth (ancestor view).
- Open: how to fix the multi-parent double count (follow-up asked).
Scores: rollup 3, classification 3 (primary flag applied unprompted).
- Follow-up: "adding a primary flag would fix it": right if it's a new flag on the rollup (an
  addition to the book); didn't say where. Missed the simpler fix: compute the grand total from
  the sales themselves, not by summing per-parent totals. Rollup stays 3.

### 2026-10-10: Submodel 1 exam, Q3 (Apply)
Rows for pen (EAN + SKU, "Pens" from 2026-01-01, "Back to school" 2026-08-01..09-15 incl.),
gift wrapping (SKU, no category), market interest "Parents" → "Back to school".
- Exclusive thru date 2026-09-16 ✓ (effectivity applied unprompted).
- Identification: one row per code with its type ✓, but gave the codes from/thru dates
  (GOOD IDENTIFICATION has none) and forgot table names.
- Gift wrapping: thought it's an identification row "with from date null"; dates don't apply,
  and from_date is never null where it exists.
- Missing: the product rows (+ good/service), the category rows, the "Pens" classification,
  the primary flags, the market interest row.
- Follow-up: pen GOOD, wrapping SERVICE ✓ (after "what tells them apart"). Market interest
  table + party type link ✓ (no columns or dates). Missed the "Pens" classification row
  (it was in the scenario) and put the primary flag on "Back to school": a temporary,
  promotional category, so the pen would have no primary after 2026-09-15.
Scores: product 2, classification 3 → 2 (gap reappeared), market interest 2, identification 2.

### 2026-10-11: Submodel 1 exam, Q4 (Analyze: which entity owns the fact)
- Pen in "Writing instruments" since 2019, reported under it → classification with primary ✓
  (primary on the lasting category, unprompted: Q3 gap closed).
- Logistics companies buy copiers → market interest (party type + category) ✓.
- Contoso bought three copiers → not this submodel, orders/invoices ✓ (kept type vs fact apart).
- UPC-A is 12 digits → said "product identification"; it's IDENTIFICATION TYPE (our
  value_pattern). Still forgets the table names.
- Business forms inside Paper → rollup, parent/child right ✓.
- Ribbon stopped selling 2004-01-01 → product.sales_discontinuation_date ✓.
- Paper's ISBN → "relationship table between product and identification" ✓ shape; it links to
  GOOD now (confirmed 2026-10-11), names not recalled.
Scores: classification 2 → 3, market interest 2 → 3, identification stays 2.

### 2026-10-11: Submodel 1 exam, Q5 (Evaluate: flawed schema)
Proposal: product(category_id, sku, upc, discontinued bool), category(parent_category_id),
product_category(product_id, category_id), good_identification(product_id → product, from_date).
- First pass, unprompted: sku/upc columns duplicate good_identification and drift ✓;
  noticed the single category_id on product (reasoning unclear).
- Missed on first pass: single parent, no dates/primary on product_category, two places for
  category, discontinued boolean, FK to product instead of good. Follow-up asked.
- Follow-up (with table-by-table prompts):
  1. parent_category_id: said "can't have multiple descendants" (wrong direction: children are
     fine, it's one *parent* only); asked for rollup dates (the book's rollup has none).
  2. product_category: said "name" missing; missed from/thru (history) and primary (double
     counting), with the report as a hint. **Gap reappeared.**
  3. discontinued boolean: needs the dates, sales vs support ✓.
  4. FK to product: didn't see it; expected product_id. Column name is right, the target is
     `good` (services carry no codes).
Scores: classification 3 → 2, rollup 3 → 2, product 2 (lifecycle dates ✓), identification 2.

### 2026-10-12: Submodel 1, soft ball (print shop: A4 ream + spiral binding)
- Both in `product`, ream GOOD, binding SERVICE; UPC through `good_identification` with a
  UPCA `identification_type` row ✓. Said binding lives in a `services` table (there is none:
  SERVICE is only `product_kind`).
- Why GOOD gets a table: first business reason only ("can't stamp a code on a service" ✓),
  then "goods carry properties" (`good` has no columns). After the hint (what points to
  `good`?): attributes **or relationships** earn a table; GOOD has the identification FK ✓.
Score: product + good/service stays 2 (rule reached with a hint).

### 2026-10-12: Submodel 1 exam, Q6 (Create: bookshop sells coffee beans + tasting workshop)
- First pass: bag as product GOOD + `good` row ✓; EAN-13 and SKU as `good_identification`
  rows typed by `identification_type` ✓ (names right, no dates); Gifts classification closed
  with thru 2026-12-01 (exclusive, not deleted) ✓.
- Missed: primary flag (reports would double count; **gap reappeared**); classified under
  Coffee/Gifts instead of the leaves; workshop made a child category in
  "party-classification-rollup"; added market_interest unasked ("sales" read as marketing).
- Follow-up: "primary flag on coffee" (it's on the bag's Single origin classification row);
  rollups Coffee → Single origin, Gifts → Under $20 ✓; workshop = SERVICE product classified
  under Coffee ✓; market interest defined right (party type ↔ category) and dropped ✓.
Scores: identification 2 → 3; classification, rollup, product stay 2; market interest 3.
Exam (Q1–Q6) done; next: reinforce loop on the rows at 2.

### 2026-10-14: Submodel 1 reinforce, classification primary flag (garden centre: climbing rose)
- Explained through the diskettes' three classification rows (primary moved in 2000, Plastic
  never primary) and the pen's double-primary bad row.
- Fresh question: rose in Shrubs + Pet-safe since 2024-04-01, reported under Shrubs; from
  2027-03-01 reported under Flowering climbers. Rows: Shrubs closed thru 2027-03-01 (exclusive)
  and still primary, Pet-safe open and not primary, new Flowering climbers row primary from
  2027-03-01 ✓, all unprompted. Left out the "why" on the first pass.
- Follow-up: no primary means the product falls out of the report; two primaries double count ✓.
  The closed row keeps true so history isn't lost, and it no longer counts because it has ended ✓.
Score: classification 2 → 3. Neighbourhood question next.
- Neighbourhood: named product and category but couldn't say what a row means ("hard to
  remember the verbs"). Taught the row-to-sentence habit (FK, verb, FK, a clause per column);
  the rose sentence was given on request, no credit. Then, unprompted: rollup links category
  to category ("a category is part of another") ✓; market interest links category to party
  type ✓ (verb loose: "taken into account by"; "is of interest to"). Left out dates in the
  sentences and the explicit contrast with classification.

### 2026-10-14: Submodel 2, mental model walk-through + warm-up (red pen row)
- Taught the three layers through the seed (feature catalogue, applicability, interaction;
  UOM on the side), explorer allowed. The user asked to build mental models for submodels 2–3
  before finishing submodel 1's reinforce.
- Row as sentence: product, feature and dates ✓; thru read as inclusive ("to 2020-01-01");
  left SELECTABLE out of the sentence.
- After a concrete prompt (an order with no colour): SELECTABLE means we must ask, and exactly
  one is picked ✓; with OPTIONAL the order goes through without a colour, which the user called
  wrong for a pen, unprompted (a good Evaluate point: the type on the link carries business meaning).
Score: feature + applicability 0 → 2 (needed the concrete prompt).

### 2026-10-14: Submodel 2, feature interaction (stapler/duplex, scan-to-email)
- Both rules read as sentences, direction and null product right ✓.
- Why a row, not code: rules added without a developer ✓ (unprompted). Knew our version only
  checks after the fact (data-quality query), and what the context-product check flags ✓.
- Why the product context: first said only "it applies whenever selected". After a second
  copier (BigOffice, duplex built into its finisher): an unscoped rule would wrongly flag a
  valid BigOffice order; the dependency belongs to this copier model ✓.
- Unprompted, challenged the global scan-to-email rule (a product may have the card built in)
  and proposed a separate feature, "stapling finisher with duplex": a valid alternative (split
  the feature when it's a different thing; scope the rule when it's the same feature).
Score: feature interaction 0 → 3.

### 2026-10-14: Submodel 2, built-in network card (LaserNet printer + global scan-to-email rule)
- The user asked first: how to group two stapler features (feature category; one FK only, no
  feature hierarchy) and whether "built in" is a feature (no: it's how the product has it;
  feature vs product test; ponder 9a).
- First pass: built-in card typed "standalone" (not a type); no applicability row for
  scan-to-email; re-added a product interaction although the global rule covers it. Saw the
  dependency's direction unprompted ✓.
- Follow-up: REQUIRED over STANDARD, a guess ✓. Put the optional scan-to-email feature in
  *interaction* instead of applicability, and thought interaction rules are checked against
  applicability. **Gap:** mixed up the layers. Applicability is the menu (what the product
  offers, and how); interaction constrains the *chosen* features of a configuration; the check
  counts required and standard features as chosen. ("Included in applicability" was close: it
  passes because the card is REQUIRED.)
Scores: applicability stays 2; interaction 3 → 2 (the layer mix-up undercuts it).
- Asked whether applicability and interaction "never talk": explained the order of the check
  (applicability completes the chosen set, then rules run) and the context-product sanity query.
- Fresh question (Commuter bike: fitted lights, M/L frame, mudguards, rear rack, "rack needs
  mudguards on any bike"): all applicability rows and types right, layers kept apart ✓;
  chosen set (lights + L + rack) and the report (mudguards missing) right ✓. Lights justified
  as "come by default" (STANDARD's wording). Interaction written backwards (mudguards depend
  on rack), fixed when asked to reread it; product context needed the two seed rules as a
  reminder, then null ✓.
Scores: applicability 2 → 3; interaction stays 2 (direction slip, scope after a reminder).

### 2026-10-14: Submodel 2, units of measure (garden hose by the metre, 15 mm diameter)
- Rows: product.uom → metre; a DIMENSION feature, number 15, uom → mm ✓ (unprompted).
- Why two places: "product uom describes the measurement the business is interested in"
  (close: it's the unit you count, sell and stock in) and an unsure idea that the metre hangs in
  both places. Said they're not confident about UOM. Taught: product uom = "how many?" (changes
  per order); a dimension = "what is it like?" (the same for every unit).
Score: unit of measure 0 → 2.
- Asked: do hose and cable have length and width dimensions; are 50 m and 100 m hoses two
  products? Answered: width yes; length only if fixed per unit sold; two products vs a selectable
  length (ponder 7), decided by the barcode (identification hangs on the good).
- Reels ("1 reel = 25 m" and "1 reel = 100 m" in the conversion table): unit is how it's sold ✓;
  a reel depends on the product, so only one conversion can be true; separate "hose reel" /
  "cable reel" units would work ✓. Didn't say where else a reel's length could go. Called
  dimensions "presentational only" (they also feed configuration and rules).
Score: unit of measure 2 → 3.
