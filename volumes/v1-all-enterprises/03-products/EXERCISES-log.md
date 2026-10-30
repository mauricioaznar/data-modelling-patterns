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
- Asked for fixes 2 and 3 with rows: reel as a product with a Length dimension (no conversion
  row needed), and an optional product on conversion (same local/global trick as interaction;
  a deviation from the book).

### 2026-10-14: Submodel 2, interaction again (laptops: Model X/Y, chargers, memory, graphics)
- Products separate, chargers SELECTABLE on both; incompatibility 16 GB / Basic board scoped to
  Model X; dependency graphics card → 90 W with no product ✓, all unprompted. Noted unprompted
  that incompatibility is symmetric, so feature vs factor doesn't matter there ✓.
- Report: flagged the Model X rule only; on "is that all?", found the global dependency too ✓.
Score: interaction 2 → 3.

### 2026-10-14: Submodel 3, Fig 3.5 walk-through + bike shop (Velo, CycleTrade, Ana's Garage, reorder)
- Taught Fig 3.5 through the seed (manufacturer column; paper's three supplier_product rows;
  reorder guidelines scoped by facility / boundary / internal org). The user's explorer had run
  since 10-10 and lacked Figs 3.5–3.6; a fresh one was opened.
- Suppliers: two supplier_product rows with lead times and dates ✓; left out preference and
  Velo as manufacturer, both placed right when asked ✓.
- Tune-up: made Ana's Garage the *manufacturer*. After the Johnson maker/supplier prompt: a
  supplier_product row for the service ✓.
- Reorder: read "city centre reorders at 2, the rest of the chain at 10" as one row (level 2,
  quantity 10), twice, even after level vs quantity were defined. **Gap:** didn't see two scoped
  rows (facility vs the chain) with the same column. Answer given on the third pass.
Scores: manufacturer vs supplier 0 → 2; reorder guideline 0 → 1.
- After the example rows, the user saw the cause themself: the quantity was never stated, both
  numbers were levels; a misread. Score stays 1 until a fresh question. Pending (asked,
  unanswered): helmets across Spain at 30 / buy 100, Madrid warehouse at 80.
- Helmets (Spain at 30 / buy 100; Madrid warehouse at 80): two rows, boundary vs facility
  scope, unprompted ✓; Spain's numbers ✓. Madrid given level 30 / quantity 80 (the "reorders
  at" misread again); fixed to level 80 after the prompt, quantity 100 taken from Spain (the
  model doesn't inherit between rows: an assumption to confirm, or leave it empty).
Score: reorder guideline 1 → 2 (scoped rows unprompted; numbers needed a prompt).
- Overlap (Madrid at 50; Spain and Madrid rows both current), ponder 12: found unprompted
  that a boundary row can mean per-warehouse or the total for the area; argued per-warehouse
  with the most specific row winning ✓ (good business reasoning). Asked three times whether
  the *model* records that choice; answered with a precedence order (internal org → geo →
  facility) and "it would behave globally", never "no, it lives in the purchasing code".
  Given: nothing in the table says it; it's a convention in application code or docs. If both
  rows apply, Madrid places two orders (over-ordering). Org and geography are different axes,
  so even the precedence order is a design choice.
Score: reorder guideline stays 2.

### 2026-10-14: Submodel 3, Fig 3.6 walk-through + Valencia phone shop
- Taught Fig 3.6 through the seed. The user's own summary: item + status + facility/container
  ✓, serialized vs counted ✓; variance "adds or subtracts" (it records the difference and why);
  lot as "where the product comes from" ✗ (a batch made or received together; cuts across
  places). Corrected.
- Phones: one serialized row per phone ✓, but only two phones (read the returned one as one of
  the cabinet pair; question wording partly ambiguous). Cracked phone: "damaged", then proposed
  a new "requires repair" status since it won't be sold ✓ (status is a lookup row; DEFECTIVE /
  BEING_REPAIRED exist).
- Cases: 25 at the facility, 40 in container R-2, variance −2 THEFT ✓. Sellable = 63, looking
  through the container to the facility, unprompted ✓.
- Asked whether R-2 should read 40 or 38: chose 40 (reported) + variance (correction) =
  derived total, and noticed unprompted that the table doesn't say which convention holds, like
  the overlapping scopes. Valid design (a ledger); our notes assume quantity_on_hand is updated
  to 38 and the variance explains why. Mixing the two subtracts twice (61). Ponder 14 answered.
Scores: inventory item 0 → 3; facility XOR container + lot 0 → 2 (lot not yet applied);
variance 0 → 3.

### 2026-10-15: Submodel 3, concept discussion (qoh, balance, variance)
- Session-start recall 1 (K-17 recall, lot) asked; the user gave a model tour instead and
  parked the question to discuss concepts first.
- Tour gaps: claimed "our convention" leaves quantity_on_hand alone ✗ (notes update it; the
  ledger version was only called valid); left out the serialized / non-serialized subtypes ✗;
  lot now a batch ✓; reason as a lookup ✓.
- Chose the book's convention (the repo stays the book's; simplify only when first building
  tables). Proposed two qoh columns (reported + after variance); taught denormalization and
  why it gains nothing here.
- Ledger walk-through: daily carry-over framing ✗ (no daily figure; order matters; theft is
  found at a count, not recorded when it happens); missing starting point ✓ (good catch);
  "ledger = sum" ✗ twice (ledger = the rows, balance = their sum); qoh as "counted snapshot" ✗
  (the system's belief); variance as "the count" ✗ (the gap the count finds). Final summary in
  the user's words ✓. Vocabulary now in NOTES.
No scores changed (concept discussion, not assessment). Recall 1 still open.

### 2026-10-17: Submodel 4, pricing walk-through from the user's own model (Fig 3.7)
- The user asked to start from how they imagine pricing and be led to the implementation.
- First model: product price + feature prices, each times quantity, components added on top ✓
  (backbone right). Break #1 (42 list, 40 Midwest, +3 Mexico all summed): "product and feature
  prices must agree, not add" ✗; "we need a base amount" ✓.
- Picking the component: primary flag ✗ (one winner for everyone), "a rule" ✓ but vague;
  "when it's included in the product" ✗ (all three are); geographic boundary ✓ but "a
  subtype" ✗ (conditions are links, subtypes are what it is). Table given.
- Competing base prices: LIFO ✗ (time is the dates' job); "more conditions match" ✓ after a
  strong hint. Quantity range as from/thru columns on the discount (content ✓, place ✗:
  QUANTITY BREAK, shared, on the supertype). Category as a condition ✓ (guiding question).
- Column review started: final price on product ✗ (belongs to the sale); type column ✓
  (not null, lookup); charge kind: discriminator + own attributes ✓, never empty on base
  prices (agreed, refactor), discounts parked by the user. One-line formula given on request.
- Activation ("the hierarchy cascade" confused the user): explained as walk-up trees + plain
  checks + AND. Springfield ✗ (thought it was in Chicago; Claude's tree also wrongly put the
  Chicago area beside Illinois), table check 2/4 (Chicago again, list price left out),
  Mexico ✓ (45 over 42), AND check ✓ unprompted.
Scores (new rows): components 0 → 2, base competition 0 → 2, conditions 0 → 2, feature
prices 0 → 2, charge kind 0 → 1. Parked at the column review; next: the value columns
(price, percent).

### 2026-10-17: Submodel 5, associations walk-through from the user's own model (Fig 3.9b)
- Office shop, five facts at once (kit contents, one-way paper substitute, X100 → X200, toner
  with copiers, gel pen vs carbon forms). First answer, all features ✗: the kit as one product
  with features, the papers as selectable features, the replacement as applicability dates;
  asked whether associations hold product-to-feature rules ✗ (that's applicability, 3.4). "Too
  complex": blame mostly Claude's (five facts at once), so one fact at a time from here.
  Bridge given: an association is 3.4's feature interaction one level up.
- Replacement: from X100 → to X200 as a link row ✓ unprompted (dodged `replaced_by_product_id`;
  same direction as the schema); the date only after a prompt.
- Table or type: chose one typed table, "like party relationship" ✓ unprompted.
- Kit: linked each product to the type ✗. "Not a chained relationship, nor a root": read
  from/to as a sequence ✗; explained as one row per pair, a star with the kit at the root,
  and as option b's cost (generic from/to). "A product linked to a product?" settled by the
  recursive pattern. Then `b1 → (p1..p3)`: kit as from ✓, three rows for two products ✗, the
  quantity missing for the third time. "A rule about the subtype": the column is the package
  subtype's ✓ (3.9b), the 2 is the row's value ✗. Rows given.
- Substitute: "subtype relationship" (the type, not the rows); a/b/c offered, not answered.
- The user's own question: do a kit's parts' prices stack? No: the kit has its own price
  components; the association is a contents list for picking and stock. The user then proposed
  kit and parts prices "ideally match" ✗ (one fact stored twice; parts' prices are
  conditional). Claude's table: own price (the book), derived in code, both (never). Found:
  the seeded starter kit has no price (NOTES point 11). Ponder 24 added.
- Questions paused by the user to reflect; the session ended with a commit.
Scores (new rows): link 0 → 2, typed table 0 → 2, type-only attributes 0 → 1, kit pricing
0 → 1; direction and BOM untested. Next: the paper question (a/b/c).

### 2026-10-19: Submodels 4–5, high-level pass (during an NFL game)
- The user's rewrites of cards 8 and 9 checked first: card 8's hook "the product recipe" cued
  card 9's BOM (now "the price recipe"), discounts and surcharges "add up" became "stack per
  unit"; card 9 listed package and component as two types ✗ (point 11: one COMPONENT row),
  "named" in place of "dated", "replacement" for substitute (it named the successor on 10-17).
- Q1 where the price paid lives: orders ✓, also "price component" ✗ (the rule, not the
  receipt). Q2 42 everyone vs 40 Midwest: most specific wins ✓ cold. Q3 a bare 5% discount:
  "all items" ✓ (empty = any). Q4 product + feature on one row: right shape, no business case.
- Engraving digression (the user's): proposed engraving as a service linked by a complement,
  a valid alternative. "An association is suggested on an order item" ✗ (catalogue data; the
  order ties lines with "ordered for"); "a feature is part of the product" ✗ (it describes a
  product, applicability says which). Agreed test: sold alone, stocked or worked on → product;
  a choice describing the thing bought → feature. Card 6's W gains it.
- Q5 one customer's price: listed five conditions (missed sale type and organization), didn't
  know. Claude's slip: hinted at Ch 4, which the user hasn't read (chapters 4–8 are built,
  not read). Answered within Ch 2–3: a party type (a real segment, not a type of one).
- Q6 what 3.8 answers that one cost column can't: "cost by supplier" ✗ (not on the row);
  after the columns were listed, components and history ✓; geography/organization missed.
- Q7 premium stands in for standard: SUBSTITUTE, one row ✓, direction backwards ✗ (from =
  the product wanted). Q8 gel pen vs carbon forms: one row, no direction ✓ unprompted.
- Q9 copier, 2 cartridges, 3 kg powder each: 2 rows ✓, "sum" ✗ (multiply: 6 kg), powder as a
  feature ✗ (third product squeezed into a feature), cartridge standalone ✓, "package" ~
  (COMPONENT, an assembly). Redo: both rows mashed into one, the 2 lost again.
- Q10 the kit's price: from the kit only ✓ cold.
Scores: base competition 2 → 3, conditions 2 → 3, estimated cost 0 → 2, direction 0 → 2,
kit pricing 1 → 3, BOM 0 → 1; feature prices and type-only attributes stay (2, 1). Next: the
quantity on the link and the substitute's direction, retested cold.

### 2026-10-19: Mixed drill (features, products, associations, categories), items 1–6
- 1 nibs on a fountain pen: product + selectable features ✓. The user's questions: a standard
  size among others is STANDARD + SELECTABLE rows; a dearer size is a price row, not a new
  product (that needs its own stock or barcode).
- 2 a pack of 5 cartridges sold separately: complement ✓, a product ✓ (implied), direction
  backwards ~ (pen → pack), `quantity_used` 5 on a complement ✗. Then "complement uses
  quantity" ✗ (the substitute does). Printer → cartridge can be COMPONENT (ships inside) and
  COMPLEMENT (refills) at once; only components explode. The user mapped the printer back onto
  the pen (Claude's example invited it): the 5 is the pack's contents, not the pen's.
- 3 "Writing instruments": category + classification ✓; subcategories + rollup the likelier
  reading, not seen (Claude's plural made it ambiguous).
- 4 the gel pen under two categories: two classifications, one primary ✓ unprompted; the
  seasonal row's thru date added by Claude.
- 5 X100 → X200: successor ✓, direction ✓ once asked to fill the row, from date ✗ again.
- 6 a bundle of 3 notebooks and 2 gel pens: a product + two COMPONENT rows with 3 and 2 ✓
  unprompted, the first quantity that came unprompted; the bundle kept apart from item 4's
  category of the same name.
- 7 (two 250-sheet packs for a 500-sheet ream) asked, unanswered: the user went to sleep.
Scores: type-only attributes 1 → 2; direction stays 2; the link stays 2 (dates). Next: item 7
opens the next session.

### 2026-10-20: Submodel 5, item 7 (the paper substitute) and a units digression
- Item 7: two products, SUBSTITUTE from the 500 ream to the 250 pack, quantity 2 ✓ unprompted;
  the date missed a third time. The why for the direction was circular ("that is what it
  means"); Claude gave it (from = the product asked for, to = what may be given instead).
- The user's question: sheets sold in one unit. A unit per pack size (PACK_250): its cost (a unit
  explosion) ✓ unprompted. Built after hints: product in EACH, a DIMENSION feature per pack
  size in SHEET (first EACH ✗), REQUIRED applicability (STANDARD offered ~), no conversion
  row; sheets = sum of quantity x number specified ✓ (multiplied, unlike the toner on 10-19).
  "Product carries quantity 1" ✗ (the product names its unit only).
- Card 6 gains both statements (S: counted vs inside; W: the PACK_250 trap). CLAUDE.md: the
  user answers in short bits; no next question until they say done.
Scores: type-only attributes 2 -> 3; direction stays 2 (the why); the link stays 2 (dates).
- Q2 X200 -> X300: SUCCESSOR from X200 to X300, from 2026-11-15, thru null ✓, the date unprompted
  (first time in four); on 1 Nov the row is stored but not in effect ✓. "Old machine" for the
  cartridge (slip). Asked for a UI banner with boobs; declined.
- The user's question: what should a successor carry over? Claude (own view, the book is
  silent): nothing flows by itself, on purpose. Copy-then-review on setup, the old product's
  discontinuation dates for retiring it, and rewrite or resolve at read time for references.
  The user called read-time resolution a costly luxury; Claude held that the query is cheap
  (two recursive CTEs here already), the cost is the business rules, worth it at scale.
  English: predecessor / successor; "first generation" over "original" (OEM in cartridges).
Scores: the link stays 2 (one dated row; retest cold once more before 3).

### 2026-10-21: Random recall across Chs 2–3 (the Ch 3 questions; Ch 2's are in its gaps log)
- Q2 (on our pens, gold engraving can't go with the transparent barrel): product feature
  interaction, INCOMPATIBILITY, read both ways ✓ unprompted; the type called
  "interoperability" (vocabulary); the product context column left out. The applicability vs
  interaction mix-up didn't come back.
- Q3 (Gel pens under Pens and under Back to school): two rollup rows, one child, two parents ✓
  unprompted, the first practice of the rollup.
- Q5 (500 reams in Main, 200 in the Annex): two non-serialized inventory items, one per
  facility, the count in quantity on hand ✓; the good each row is stock of left out, though
  the question asked what each row points at.
- Q6 (the Fine Pen's base is $2, the West region gets 10% off): two components on the pen,
  the base with no conditions, the discount on the West boundary, "each says when it
  applies" ✓. Left out: ONE_TIME on the base (agreed at the overview), the from dates, the
  currency. The user's questions: currency vs unit of measure (a currency is a unit of measure
  subtype); a price in pesos is a second base row, and the line's currency filters which rows
  compete (a percent has no currency, an amount does).
- Q9 (the Gel Pen 0.7 also in Back to school, September only): a classification row, dated,
  kept apart from Q3's rollup ✓ cold. Claude first marked the primary flag and exact dates as
  missing; the user pushed back (neither was asked, and `primary_flag` defaults to false) and
  was right.
- Q11 (Pens A and B substitute for each other: how many association rows, and why?) asked,
  parked by the user unanswered.
Scores: interaction 3; rollup 3; inventory item 3; price components 3; classification 4.
Next: Q11 (direction) opens the next session.

### 2026-10-21 (later session): Submodel 5, Q11 (A and B substitute for each other)
- SUBSTITUTE (called "replacement"), not successor (OBSOLESCENCE in our seed) ✓; two rows,
  "direction matters", quantity 1 ✓. The why was the claim again; after the follow-up "why
  can't one row cover both ways?": substitution isn't symmetric (standard may stand in for
  premium, not the reverse), and one row read both ways would imply the reverse and hand out
  the luxury paper ✓. "Circular" for the implied reverse (wording). Claude tied it to Q2:
  substitute = a row each way, incompatibility = one row read both ways.
- The user asked why 3 and not 4: the why came after a narrowing follow-up (the Q8 flag
  precedent, right but late).
Scores: direction 2 → 3. For a 4: the asymmetry as the why on the first pass, in a new story.

### 2026-10-23: Submodel 4 cold retest (the Trail 29 bike)
- Pricing: two bases, $950 on Colorado the more specific ✓; the $900 thru-dated at 2026-12-01
  and a new $990 from 2026-12-01, no overwrite ✓ cold; club 10% as a discount on the party type
  ✓, but without the product, so it reads as 10% off anything a club buys; carbon wheels called
  a surcharge ✗: it's a base price on the feature, which adds to the winning base (the
  selectable applicability named ✓). Missed again: the charge kind, the currency.
- The order: two lines, the wheels ordered for the bike, each with its final price as a
  snapshot ✓. The sum: (950 + 250) × 0.1 ✗, twice over: 10% *off* is × 0.9, and the discount
  is the bike's only. Right: bike $855 (950 beats 990 on 15 Dec, then −10%), wheels $250,
  $1,105. Same slip as 2026-10-19 (an adjustment applied the wrong way); Colorado comes from
  the ship-to address, not named.
Scores: price components 2 → 3; feature prices stay at 2.

### 2026-10-24: Submodel 5, BOM retest (Spokes' Tourer: 2 Rolla wheels; a wheel, 1 hub and 32 spokes; a hub, 2 bearings)
- Before answering, asked: "something that doesn't get sold but is part of something is a
  feature, correct?" ✗: the 2026-10-19 slip ("a feature is part of the product") back. The
  agreed test restated: sold alone, stocked or worked on → product; a choice describing the
  thing bought → feature. Being sold doesn't decide it. Feature row 3 → 2.
- Pushback: "anything can be a feature or a product, depending on the operation" (half right:
  it depends on what *this* business does with the thing; a shop that buys whole wheels could
  hold "32 spokes" as a dimension feature of the wheel) and "a product is something you build
  on your own" (the test misremembered: card 6 says sold alone, stocked *or* worked on in its
  own right). Held: Spokes stocks spokes and builds with them, so they're products; a feature
  can't have a supplier product, an inventory item or a `quantity_used` (all point at product).
- The answer: Tourer → Rolla 2, Tourer → frame 1, Rolla → hub 1, Rolla → spoke 32, hub →
  bearing 2, all COMPONENT, from = the whole ✓ cold (10-19's mashed row and lost 2 not
  repeated). The spare: no row given ✓, "every product is in the catalogue, so what difference
  does it make" ✓, then hedged with a "spare" category or an association "joined to whom" (no
  association; a category is an optional extra for browsing). Not named: the one real
  difference is a base price component on the Rolla, which its parts never get (the starter
  kit gap, point 11). Score: 4 on the rows; BOM 1 → 3, the explosion still to retest.
- Q3 (10 Tourers and 4 spare Rollas: spokes and bearings from stock): 20 + 4 = 24 wheels, 24 ×
  32 spokes, 24 × (1 hub × 2) bearings, i.e. 768 and 48 ✓ cold, multiplied down (10-19's sum
  not repeated), the spares merged at the wheel level. Slip in the follow-up: "each bicycle
  carries 32 spokes and 2 bearings" (each *wheel*; a bike carries 64 and 4). Fair point raised:
  the question assumed a build to order (blame Claude's). Asked: does ordering an assembly
  always need its components? (no: the BOM is the recipe; an order line orders the Tourer, and
  stock of finished Tourers ships as is) and do prices double count? (no: a line takes the
  price of the product it orders, not a "root"; components carry no price into it, only
  features ordered for the line add on top). Score: 4 on the explosion; BOM stays 3 until
  `good_kind` is asked.
- Follow-up (the user's, after the price point): "optional or selectable features get added
  separately on the order line with their price" ✓, prompted by Claude's mention. Sharpened:
  a SELECTABLE feature is always chosen (one of its type must be), so it always gets a line,
  maybe at 0.00; the line is ordered for the product's line and names only the feature (Ch 4,
  point 2). No score change (prompted).

### 2026-10-24: question round Q3, Submodel 5 (Greenleaf: from 1 Nov 2026, offer two 10 L bags when the 20 L is out; not the reverse)
- One SUBSTITUTE row, from = the 20 L wanted, to = the 10 L offered, 2 on `quantity` (not
  `quantity_used`) ✓ cold. The from date given unprompted for the first time (missed 10-17,
  10-19, 10-20), but 1 October, not 1 November (a misread, not a gap).
- Why the direction: "read the other way, a 10 L request gets two 20 L bags, 40 L" ✓,
  concrete, not circular as on 10-20. Not named: the row states the rule "when from is
  wanted, offer quantity × to", so flipping it states a rule Greenleaf never made, and the
  reverse, if allowed, is a second row with its own quantity. Score: 3. Link (dated) 2 → 3,
  direction 2 → 3.

### 2026-10-24: question round Q5, Submodels 1–2 (Tostado: a grind picked per bag; a bought, shelved valve sealed into every bag, never sold alone)
- Grind: a SELECTABLE feature of the bag ✓ cold, OPTIONAL ruled out because one must be
  picked, no STANDARD feature present ✓.
- Valve: a product "because it gets stocked" ✓ cold, the morning slip named and corrected
  unprompted ("I was only considering elements that could get sold"). Not named, not asked:
  what follows (a COMPONENT row bag → valve, the supplier product, the shelf stock as an
  inventory item, all pointing at product).
- Fairness point (the user's): the wording didn't say a grind is required, and "whole bean"
  as a grind is coffee jargon. Read right anyway, so no blame to split; "must pick one" would
  have been crisper. Score: 4. Feature row 2 → 3 and PRODUCT row 2 → 3; 4 waits for a later
  day, since the test slipped this morning.

### 2026-10-25: question round Q1, Submodels 1–2 (Pedalia's City bike: a frame size the buyer must pick; a €15 kickstand the factory fits; a bell bought by the box, shelved, fitted to every bike)
- Frame size: SELECTABLE, no standard ✓ cold.
- Kickstand: a feature, "not stocked, sold or modified on its own" ✓ cold. The price is the
  bait (being sold doesn't decide it) and it held.
- Bell: a product, "it is stocked" ✓ cold. Not named, not needed: Pedalia also works on it
  (fits it), and stock means a supplier product and an inventory item, both on product.
- The test on a later day, in a new setting, with no slip. Score: 4. PRODUCT row 3 → 4
  (good vs service still open), feature row 3 → 4.

### 2026-10-25: question round Q4, Q6, Q7, sent as text (the user answers offline, brings the answers to a later session)
- Q4 (rollup): Pedalia's "Bikes", "Kids" (also helmets, gloves) and "Kids' bikes", which sits
  under both. Which rows in which tables so the Rolla Junior (a kids' bike) shows under all
  three, and how many classification rows does it need? Key: two rollup rows (Kids' bikes →
  Bikes, → Kids), one classification row (→ Kids' bikes, primary, dated); the parents come
  through the rollup; one parent column can't hold two parents.
- Q6 (feature prices): City bike base €400 for anyone, €420 in the Basque Country; the
  kickstand's base €15. Ane in Bilbao buys both: the rows, what she pays, why. Key: three
  components; 435, the most specific product base wins (Bilbao inside the Basque Country),
  the feature's base adds on top and competes only with that feature's.
- Q7 (`good_kind`): Molina buys burrs, motors and casings, builds a burr set from 2 burrs, a
  grinder from 1 burr set, 1 motor, 1 casing, and sells only the grinder. Each good's kind,
  and what the kind tells that the COMPONENT rows can't. Key: grinder FINISHED_GOOD, burr set
  SUBASSEMBLY, burr, motor, casing RAW_MATERIAL; packages and assemblies share the COMPONENT
  row, only the kind tells a BOM line from a package line (and a raw material made of
  something is caught by a check).
- **Q7 answered the same day (in this session, not offline).** "Burr, motor, casing and
  grinder are all products" ✓ (the burr set too, by the same test); "the burr set and the
  grinder are assemblies made of components" ✓ for the structure, but no kinds given (asked):
  RAW_MATERIAL, SUBASSEMBLY and FINISHED_GOOD not recalled, and "assembly" for both blurs the
  subassembly with the finished good. What the kind tells: "which items are complete, not
  add-ons" ~ (half the finished-good idea; "add-on" is feature vocabulary); "the good kind has
  the inventory mechanism" ✗ (inventory item points at any good; the kind doesn't decide
  stocking). Missed: the COMPONENT row is shared by assemblies and marketing packages, only
  the kind tells a BOM line from a package line, and a raw material with components is a
  check failure. Blame split: `good_kind` had never been tested or drilled (only settled at
  the overview, point 11), so the question tested something never taught in practice: mostly
  mine. Score: 1. Taught in chat. Retest cold on a later day.
- **Q6 answered the same day (pasted in this session).** Catalogue rows: two bike bases and
  one kickstand base ✓. Geography: "assuming the Basque Country is inside Bilbao's borders"
  ✗, the containment reversed (Bilbao sits inside the Basque Country, so Ane's sale matches
  the €420 condition; the 10-17 Springfield activation slip, again); why 420 beats 400 (most
  specific wins) not said. The kickstand: the text pointed at Q1, which the WhatsApp copy
  didn't carry, so the user branched (standard → 420; optional or selectable → its component
  counted separately on the order; a product → its own line). Blame: mostly Claude's (the
  question wasn't self-contained), though it did say "the feature" with its own €15 base.
  "Counted separately" implies adding, but no total given: Ane pays 435 (the 420 base wins,
  the feature's base adds on top and competes only with that feature's). Score: 2. Feature
  prices stay at 2; conditions row keeps 3, the containment to retest.
  The user's defence: 420 picked as "the one that belongs to Bilbao", one base only, so one
  wins. Credit for one base winning and the right one; held at 2, since "the one that
  matches" is the wrong rule: the €400 base (no condition) matches Ane too (empty = any), and
  the more specific one wins. Asked whether the kickstand is STANDARD: no, OPTIONAL (Q1: the
  buyer can add it).
- **Q4 answered the same day (pasted in this session).** Rollup: Kids' bikes under both Bikes
  and Kids ✓ cold, the network read right (two parents). Helmets and gloves made
  subcategories of Kids: a fair reading of "Kids also holds helmets and gloves" (Claude's
  wording, ambiguous; meant products classified under Kids). Classification: three rows, the
  Rolla Junior under Kids' bikes (primary ✓), Bikes and Kids ✗: the 10-12 Q6 gap again
  (classified under the parents). One row is enough; the parents come through the rollup,
  and the extra rows double-count in rolled-up totals and can drift from the rollup. Score:
  2. Rollup stays at 2 (the rollup half at 3, classifying under parents still open).
  Pushback (the user's): "classify at the leaf" assumes products always sit on a leaf, and
  what a category is stays grey. Half right, Claude's overstatement: the rule is the most
  specific category that is true (it may be an inner node), and no row for an ancestor of a
  category already used, since a rollup means containment. Grey categories are why the model
  is a dated network with a primary flag; the no-ancestor rule is Claude's normalisation
  reading, not a book quote. Grade held at 2 (the stated tree made both parent rows copies).
  Follow-ups: "isn't primary for double counting?" Yes, across categories where neither
  contains the other (primary picks one for one-bucket reports); it can't stop rows that copy
  the tree. The user saw it: the full classification is built from the row plus the rollup,
  never stored. The rule per product, not per category (Kids can still hold a helmet's row);
  "real category" (Claude's vague word) = one not reached by climbing the rollup from a
  category the product already has; walked through with a table.

### 2026-10-26: question round Q1, Submodel 5 (Mecha: wax and wicks bought, a candle body poured, the Vela Lavanda sold; matchboxes bought and sold loose; a Gift Box of 3 candles and 1 matchbox)
- Key: wax, wick RAW_MATERIAL; candle body SUBASSEMBLY; Vela Lavanda, matchbox, Gift Box
  FINISHED_GOOD. Both kinds of line are COMPONENT rows; the child's kind tells them apart
  (raw or subassembly → a build line; finished good → a package line).
- Answer: all six kinds right, cold (the matchbox too, bought in but sold as it comes).
  Part 2 ✗ half: "the association tree only tells how a product gets built" (no, Gift Box →
  Vela Lavanda is a COMPONENT row too), and `good_kind` named as the lever but framed as
  bought vs built (that tells raw from subassembly, not a build line from a package line).
  Score: 3 (part 1 at 4, part 2 at 2). `good_kind` 1 → 3; the line rule to retest cold.

### 2026-10-26: question round Q3, Submodels 1 and 4 (Librería Faro: Books → Fiction → Crime, Books → Children's, Gifts on its own; a children's crime novel, shown in Gifts 1 Dec 2026 – 6 Jan 2027)
- Key: three rows, Crime, Children's (neither contains the other) and Gifts from 2026-12-01
  thru 2027-01-07 (exclusive); none for Fiction or Books (reached by the rollup). Primary:
  one of Crime or Children's, a business call (the report that needs one bucket); not Gifts.
- Answer: Gifts with 011226 / 070127 ✓ (exclusive thru cold); Children's ✓, primary ✓
  (Gifts is temporary; children's books have their own section); no Books row ✓. Crime left
  out ✗: "both leaves of the same subtree", plus a shopper's view (an adult browsing Crime).
  Same subtree is not containment: Crime and Children's are siblings' descendants, both
  true, so both get a row; what a shelf shows is a display choice, and primary covers the
  one-bucket report. Without Crime the book doesn't reach Fiction either. Arrival date not
  given in the question (Claude's blame, the user's −1 accepted). Score: 2. Rollup row
  stays 2: no ancestor rows ✓, the rule misread as "one per subtree".

### 2026-10-26: question round Q4, Submodel 4 (Nevada Sports: Pico €300 any, €320 Andalusia; binding mount €20 any, €15 Andalusia; €25 off for Students; Lucía, a student in Granada)
- Key: 320 (Andalusia contains Granada, more specific than any) + 15 (the mount's own bases
  compete) − 25 (every matching discount applies) = 310; 300 and 20 match too but lose.
- Answer: all of it ✓ cold, both "match but less specific" said, 310 given. The containment
  (Granada inside Andalusia) used, not stated. Score: 4. Base competition 3 → 4, feature
  prices 2 → 4 (the 10-25 gaps, containment and the sum, closed).

### 2026-10-26: question round Q7, Submodel 3 (Nevada Sports: Altura makes the Pico; Nieve preferred, 5 days, Montaña backup, 10 days; reorder at 4 → 10 in general, at 6 → 12 at the Granada store; Granada has 5)
- Key: `product.manufacturer_party_id` → Altura; two `supplier_product` rows (preference
  type, rating type, standard lead time, available from); two `reorder_guideline` rows for
  the good, one unscoped (4, 10), one based on the Granada facility (6, 12), the most
  specific wins; Granada at 5 ≤ 6 → reorder 12, from Nieve (the preference guides the buyer).
- Answer: (1) all ✓ cold; the rating named "quality type" (purpose right). (2) two rows,
  one scoped to Granada ✓, level read as "falls to" ✓; "if stock gets lower than 5 anywhere
  but Granada it doesn't trigger a restock" muddled (read as: Granada follows only its own
  row); the rule not named; the general row's scope called "the general area" (it's empty =
  any). (3) 12 from Nieve ✓. Score: 3. Manufacturer vs supplier 2 → 3, reorder 2 → 3.
  Clarified by the user: the Granada row triggers at ≤ 6 in Granada only, and never
  elsewhere ✓ (the muddle was wording). Held at 3: the rule (most specific wins, the general
  row loses in Granada) not named, and the general row's scope is empty = any.

### 2026-10-27: round Q3, Submodel 1 (Ferretería Roble: Tools → Power tools → Cordless, Tools → Garden tools; a cordless hedge trimmer from 1 Mar 2027; a one-bucket report at the second level)
- Key: two rows, Cordless and Garden tools, from 2027-03-01, thru null; none for Power tools
  (an ancestor of Cordless) or Tools (reached by the rollup). Both under Tools, neither
  contains the other, so both get a row. The report: primary on one of the two, a business
  call.
- Answer: Cordless and Garden tools, dates right, no ancestor rows, cold ✓; the primary flag
  on either one, not both ✓. Same subtree vs containment passed cold, a day after Faro.
  Score: 4. Rollup 2 → 4 (the most specific true categories, none an ancestor of another).

### 2026-10-27: round Q4, Submodel 5 (Panal: bulk honey and glass jars filled into Miel de Azahar 250 g, sold; dippers bought and sold as they come; a Breakfast Set of 2 jars and 1 dipper; four COMPONENT rows shown)
- Key: (1) honey, jar RAW_MATERIAL; Miel de Azahar, dipper, Breakfast Set FINISHED_GOOD.
  (2) Miel → honey and Miel → jar are build lines (the child is a raw material); Set → Miel
  and Set → dipper are package lines (the child is a finished good). The database tells them
  apart by the child's `good_kind`, not the association type.
- Answer: (1) all five right, cold, Miel too (worked on and a component, but sold, so
  finished) ✓. (2) not answered as asked: the kinds re-justified, no row called build or
  package, no lever named ✗ (the same gap as Mecha's part 2). Score: 2. Row stays 3: the
  kinds are solid on a second day; the line rule (the child's kind) still to retest cold.

### 2026-10-27: round Q6, Submodel 3 (Farmacia Ribera: paracetamol 40 boxes lot B-221 and 25 boxes lot B-305 on shelf A3; two blood pressure monitors BP-9001, BP-9002 on shelf C1; reorder level 30 chain-wide, 60 at the Calle Mayor store)
- Key: (1) four items: two NON_SERIALIZED (paracetamol, one per lot, 40 and 25, in container
  A3), two SERIALIZED (monitor, serial each, no quantity, in container C1); the location
  arc: a container or a facility, exactly one (here the shelf, which sits in the store).
  (2) 60: the facility-scoped guideline is more specific than the chain-wide one; most
  specific wins.
- Answer: (1) one row per lot with its quantity ✓, one row per serial ✓, quantity empty on a
  serialized item ✓ (first said 0, then "assumed 1"); the kind first given as "container"
  then corrected to serialized / non-serialized, self-caught ✓; where it is not given for
  any row ✗ (the shelf, through the container arc). (2) 60, "the facility wins over the
  whole chain" ✓ cold, most specific in its own words. Score: 3. Inventory item stays 3
  (the location arc to retest); reorder guideline 3 → 4.

### 2026-10-28: Q4, Submodel 5 (Jabonería Clara: olive oil and lye bought, the Jabón de Oliva bar made and sold; sponges bought and sold as they come; a Bath Set of 2 bars and 1 sponge; four COMPONENT rows shown)
- Key: (1, Analyze) Jabón → olive oil and Jabón → lye are build lines; Bath Set → Jabón and
  Bath Set → sponge are package lines. (2, Analyze) the child's `good_kind`, on `good`: a
  RAW_MATERIAL or SUBASSEMBLY child makes a build line, a FINISHED_GOOD child a package line.
  The parent can't decide it: both parents are finished goods.
- Answer: (1) all four right, cold ✓ (first time: Mecha and Panal never sorted the rows).
  (2) `good_kind` named cold ✓, the kinds right (no subassembly) ✓; the table and whose kind
  not said. Guiding question: "goods" ✓; "whose kind" not understood (Claude's question too
  compressed); with a table of rows a and c and an a/b choice, the child's ✓, with the why
  (both parents finished, no difference) ✓; the rule offered as "we can suspect", raw only
  (subassembly too, and it's the rule we built, not a hunch). Score: 3. Row stays 3: the
  child's kind to retest cold.

### 2026-10-28: Q5, Submodel 3 (Vinoteca Duero's Valladolid warehouse: 30 bottles of Ribera Crianza in rack R2; a wine-cooling cabinet, serial WC-77, on the floor in no rack)
- Key: (1, Apply) bottles NON_SERIALIZED, quantity 30, `container_id` R2, no facility;
  cabinet SERIALIZED, `serial_num` WC-77, no quantity, `facility_id` the warehouse, no
  container. (2, Understand) the container only: R2 already sits in the warehouse, and the
  arc allows exactly one, so the location can't contradict itself.
- Answer: (1) the bottles exactly as the key, the arc named unprompted ✓; the cabinet's kind,
  null quantity (first "0q", corrected in the same line) and the facility ✓; the serial
  WC-77 not written ✗ (asked: "quantity or serial"). (2) the container only, with the why: a
  facility as well would have to agree with the container's, and could drift ✓ cold.
  Score: 3 (the serial). Inventory item 3 → 4: yesterday's gap, the location arc, cold with
  its why; the serial per item was right yesterday. Neighbourhood still to ask.

### 2026-10-30: question round, pending (asked 10-29, answered in a later session; order in TODO)
- **Q3 · Product associations and parts · Apply, Understand (recall: the child's
  `good_kind`).** Cera Viva makes a candle from wax and a cotton wick, both bought in, and
  sells it alone; it also sells a gift set: one candle and a matchbox (bought in, also sold
  alone). Write the component rows and say for each whether it's a build (BOM) or a package
  line, and what decides. Key: candle ← wax, candle ← wick: build (children raw material);
  gift set ← candle, gift set ← matchbox: package (children finished goods). The child's
  `good_kind` decides, not the parent's; the row itself is the same COMPONENT link.
- **Q4 · Suppliers and inventory · Apply, Analyze (gap: where stock is, lot).** Farmacia
  Tajo's Toledo warehouse holds ibuprofen 400 mg: 200 boxes of lot L-77 (made 2026-03-01,
  expires 2027-03-01) in bin B4; 100 boxes of L-77 on the receiving floor, in no bin; 50
  boxes of lot L-81 in bin B4. A recall of L-77 arrives. Write the rows, then say how you
  find every place holding L-77 and how much ibuprofen is at Toledo. Key: `lot` rows L-77
  and L-81 (creation date, quantity, expiry); `container` B4 (type bin) located at Toledo;
  three non-serialized `inventory_item` rows, each with its lot: L-77 in B4 (200), L-77 at
  Toledo directly (100), L-81 in B4 (50); facility XOR container on each. Recall: items by
  lot, place = the container's facility or the item's own. Toledo total 350, which must look
  through containers (filtering on the item's facility alone gives 100).
- **Q7 · Product features · Apply (maintenance: feature + applicability, last 4 on 10-25).**
  Brío 2 espresso machine: the buyer must pick black, red or white; a milk frother can be
  added; a built-in grinder comes with every machine; a travel case is also sold on its own.
  Write the rows. Key: colour features (one category) black, red, white each SELECTABLE on
  Brío 2; frother OPTIONAL; grinder STANDARD; the travel case a product, not a feature (sold
  alone), linked to Brío 2 by a product association if anything (complement).
