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

### 2026-10-30: round Q3 answered, Products and parts (Cera Viva; key above)
- Answer: four COMPONENT rows, whole → part ✓; candle builds, gift set packages ✓; the child
  decides ✓; "raw or subassembly → build" ✓. But subassembly also listed under package (a
  contradiction), and raw justified as "only bought in" ✗ (the matchbox is bought in and
  finished: `good_kind` is the good's role in making, not its source). No quantities.
- Score: 3. Rows and decider cold; the reasons need one clean pass for 4.

### 2026-10-30: round Q4 answered, Suppliers and inventory (Farmacia Tajo; key above)
- Answer: L-77 in B4 (200) ✓, L-77 at Toledo with no container (100) ✓, facility XOR
  container applied ✓; the Toledo total looks through containers, 350 ✓ (the gap, cold).
  The L-81 item written with "no lot" ✗; `lot` and `container` rows not written (the lot's
  dates described ✓); recall found items by lot ✓ but places not resolved (container's
  facility or the item's own).
- Score: 3. Where stock is fixed cold; the lot dropped once, so lot stays the open gap.
- After grading: lot quantities given (L-77 300, L-81 50) ✓. Taught: `lot.quantity` is as
  made or received; on hand is the sum of items. Score kept.

### 2026-10-30: round Q7 answered, Product features (Brío 2; key above; the shop's catalogue)
- Answer: black, red, white SELECTABLE ✓, frother OPTIONAL ✓, grinder STANDARD ✓, the
  travel case a product of its own, not a feature ✓, "some kind of association" hinted
  (the complement, not named). But the rows filed in the interaction table ("leaning
  interaction") ✗: they are `product_feature_applicability`; and "comes with every machine"
  read as a dependency, possibly a global applicability rule ✗: that is STANDARD; a
  dependency is an interaction between two features. The colour category not mentioned.
- Score: 4 → 3. The applicability types right cold, but the table that holds them named
  wrong and the two rule tables confused: retest applicability vs interaction cold.

### 2026-10-30: random, Submodel 4 (Gimnasio Roble: membership €40 a month, a €25 sign-up, sauna €3 per visit; our catalogue)
- Asked: Apply, write the price rows. Key: three BASE `price_component` rows on the
  membership (a service): 40 RECURRING per MONTH (`per_time_frequency_id`), 25 ONE_TIME, 3
  UTILIZATION per visit (`per_uom_id`); currency and from date on each.
- Answer: membership a service ✓; 40 a base ✓ "of monthly kind" (the kind is RECURRING,
  the month its "per": two columns, merged); 25 a SURCHARGE ✗ (a sign-up is a price of its
  own, a one-time base beside the recurring one; a surcharge adds to a base under a
  condition), ONE_TIME ✓; 3 "something × 3", UTILIZATION not recalled, per visit not said.
- Score: 1 → 2. The three-way split applied cold and unhinted, but one kind name of three,
  the "per" folded into the kind, and the one-time base filed as a surcharge.

### 2026-10-31: round Q4, Submodel 2 gap (applicability vs interaction; Arco 14 laptop; our catalogue)
- Asked: Apply. Arco 14: the buyer must pick 8 GB or 16 GB of memory; a touchscreen can be
  added; a matte screen finish can be added; a webcam comes with every one; the touchscreen
  needs the 16 GB; the matte finish can't go with the touchscreen. Write the rows, saying
  which table each goes in. Key: `product_feature_applicability` on Arco 14: 8 GB and 16 GB
  SELECTABLE, touchscreen OPTIONAL, matte OPTIONAL, webcam STANDARD; `product_feature_interaction`
  (feature to feature, Arco 14 as context or none): touchscreen DEPENDENCY → 16 GB (one
  way), matte INCOMPATIBILITY touchscreen (both ways, one row). Product + feature =
  applicability; feature + feature = interaction.
- Answer: applicability rows on Arco 14: 8 GB and 16 GB SELECTABLE ✓, touchscreen and matte
  OPTIONAL ✓, webcam "required" (STANDARD by name). Interaction rows scoped to Arco 14 ✓:
  touchscreen DEPENDENCY on 16 GB, one way ✓ (said unprompted); matte vs touchscreen a
  "clash", non-directional ✓ (INCOMPATIBILITY not recalled). Product + feature and feature
  + feature kept apart, both tables named right.
- Score: feature + applicability 3 → 4; feature interaction 3 → 4 (rows, scope, direction
  and symmetry cold, a later day). Two type names loose: STANDARD, INCOMPATIBILITY.

### 2026-10-31: round Q5, Submodel 4 gap (charge kind; Red Faro internet plan; our catalogue)
- Asked: Apply. Red Faro's Fibra plan: €30 a month; €50 to install, once; €0.10 per GB
  used; customers in the Sierra Alta region pay €5 a month more. Write the price rows. Key:
  on the Fibra plan (a service), BASE 30 RECURRING per MONTH; BASE 50 ONE_TIME; BASE 0.10
  UTILIZATION per GB (`per_uom_id`); SURCHARGE 5 RECURRING per MONTH with the Sierra Alta
  `geographic_boundary_id` condition. The installation a second base (a price of its own),
  the region extra a surcharge (adds to a base under a condition). Currency and from date on
  each.
- Answer: four `price_component` rows on the product ✓; 30 BASE RECURRING ✓; 50 BASE
  ONE_TIME ✓ (the 10-30 sign-up-as-surcharge miss not repeated); 0.10 BASE "quantity based"
  (UTILIZATION by name); 5 SURCHARGE RECURRING ✓. Missing: the "per" columns (month, GB) and
  the Sierra Alta condition on the surcharge ✗ (without it, every customer pays the €5).
- Score: charge kind 2 → 3 (kinds right cold, one-time base vs surcharge fixed; UTILIZATION
  and the "per" columns missing for 4). Conditions row kept at 3, the region missed: retest.

### 2026-10-31: round Q6, Submodel 1 maintenance (product + good/service; Horno Lino bakery; our catalogue)
- Asked: Apply. Horno Lino bakes and sells sourdough loaves; runs a Saturday baking class;
  sells bags of flour it buys from a mill (the same flour goes into its loaves); a loaf can
  have seeds on top for €0.50 more; it bakes in a wood oven. Which are products, which goods
  and which services, and which are not products at all? Key: loaf PRODUCT + GOOD; class
  PRODUCT + SERVICE; flour bag PRODUCT + GOOD (offered for sale, stocked; buying it in
  doesn't stop it being a product; its use in the loaf is a component link, not asked); seeds
  a PRODUCT FEATURE on the loaf (not sold on its own); the oven not a product (not offered;
  an asset).
- Answer: loaf PRODUCT + GOOD ✓ (baking itself a work effort, not sold: a good aside); class
  PRODUCT + SERVICE ✓ (Saturdays: no place in the product, a schedule); flour bag PRODUCT +
  GOOD ✓, bought in and still a product, and unprompted: flour → loaf a COMPONENT
  association ✓, the mill a `supplier_product` row ✓ (called "guideline"); seeds a FEATURE ✓,
  its €0.50 "a surcharge? one time" (hedged; a feature's own price component, adding to the
  loaf's base); the oven "if considered a product… I don't know" ✗ (a hedge counts as a
  blank: not a product, nothing we offer; an asset we use).
- Score: product + good/service 4 → 3 (the offered test failed on the one thing not
  offered). The feature price hedged, the feature-price row not lowered: retest.

### 2026-11-01: question round, pending (written for the phone; wording in `docs/round-2026-11-01.md`; order in TODO)
- **Q5 · Product + good/service · gap (10-31 Q6, the oven) · Apply; Understand for the
  whys.** Imprenta Sol: business cards, a logo design service, reams of paper bought from a
  mill, a gloss finish on the cards, the press it prints on. Key: business cards PRODUCT +
  GOOD; logo design PRODUCT + SERVICE; paper reams PRODUCT + GOOD (offered and stocked; buying
  them in doesn't stop them being a product; the mill a `supplier_product` row, not asked);
  gloss a PRODUCT FEATURE on the business cards (chosen on a product, never sold alone; its
  applicability type not asked); the press not a product (never offered; an asset the shop
  uses). A hedge on the press counts as a blank, as with the oven.
- **Q7 · Base prices compete + feature prices add on top · maintenance (both last 4 on
  10-26; the feature price also the 10-31 Q6 retest) · Apply; Understand for the why.**
  Bicis Alba: the Ruta's base €1,200 any, €1,140 Catalonia; its rack (a feature) €60 any,
  €45 for the Club party type; Marta, Club, in Girona (Catalonia). Key: both bases match (no
  condition = any; Catalonia contains Girona), €1,140 wins (most specific: more conditions
  match); both rack prices match, €45 wins, competing only with the rack's own prices, never
  the bike's; the feature price adds on top of the base: 1,140 + 45 = €1,185.

### 2026-11-01: round Q5, product + good/service gap (Imprenta Sol; key above)
- Answer: business cards PRODUCT + GOOD ✓; logo design PRODUCT + SERVICE ✓; paper reams
  PRODUCT + GOOD ✓, the mill a `supplier_product` row unprompted ✓; gloss a feature applied
  to the cards ✓ (OPTIONAL, not asked: fair), its feature type guessed PRODUCT_QUALITY (a
  fair pick from the nine; OTHER also defensible; the subtypes not known, owned up); the
  press not a product, flatly ✓ ("an internal operation", the work effort chapter's ground:
  printing is the work, the press a fixed asset it uses, Ch 6). No hedge this time.
- Score: PRODUCT + good/service 3 → 4 (the not-a-product called cold on a later day, the
  10-31 oven hedge gone). Feature row stays 4.

### 2026-11-01: round Q7, base and feature prices maintenance (Bicis Alba; key above)
- Answer: both bike bases match, €1,140 (Catalonia) wins over the no-condition €1,200, most
  specific ✓; the line takes 1,140 ✓; the rack's two base prices (on the feature) match, €45
  wins ✓, added on top: 1,140 + 45 = €1,185 ✓, all cold. That the rack's prices compete only
  among themselves shown by the layout, not said. Slips: Catalonia called a province (it's
  an autonomous community; Girona is the province; the boundary type doesn't change the
  match); the condition written "party type: customer" and "a member = customer": CUSTOMER is
  a party role (Ch 2), the party type is CLUB. Blame on member/customer about 70/30
  Claude's: the wording said "Club customers (a party type)" and then "a Club member".
- Score: base prices holds 4, feature prices holds 4. Note for Ch 2: party type vs party role.


### 2026-11-02: question round, pending (written for the phone; wording in `docs/round-2026-11-02.md`; order in TODO)
- **Q7 · Maintenance · category rollup, a network (last 4 on 10-27) · Apply.** Tienda Raíz:
  Food, Drinks, Organic, Organic drinks (under Drinks and Organic); a kombucha, also under
  Gifts in December. Key: `product_category_rollup` Drinks (parent) → Organic drinks (child)
  and Organic → Organic drinks: two parents, a network, not a tree. Food has no rows (nothing
  says Drinks sits under it). `product_category_classification`: kombucha → Organic drinks,
  primary, from a start date, thru null; kombucha → Gifts, not primary, from 1 Dec, thru
  1 Jan (exclusive). No rows for Drinks or Organic: the ancestor view gives them. Gifts needs
  its own category row first.

### 2026-11-02: round Q7, maintenance (category rollup, a network; Tienda Raíz; key above)
- Answer: rollup Drinks → Organic drinks and Organic → Organic drinks ✓ (two parents, cold);
  Food left without rows ✓. Classification: kombucha → Organic drinks, primary ✓ (no start
  date: none was given, Claude's wording); kombucha → Gifts, 1 Dec to 1 Jan with the thru
  exclusive ✓, not primary ✓. No rows for Drinks or Organic ✓.
- The user flagged Gifts as missing from the category list: fair, the wording should have
  listed it (the key only noted that Gifts needs its own category row). Blame Claude's.
- Score: category rollup holds 4 (new date).

### 2026-11-03: question round, pending (written for the phone; wording in `docs/round-2026-11-03.md`; order in TODO)
- **Q6 · Maintenance · reorder guideline, a scoped rule (last 4 on 10-27) · Apply,
  Analyze.** Papelería Mar, the black cartridge. Key: (a) `reorder_guideline` rows, all
  for the cartridge (a good): chain-wide (scoped to the internal organization Papelería
  Mar, or unscoped) level 20, quantity 50, from its start, thru 1 Dec (exclusive); chain-
  wide level 30, quantity 50, from 1 Dec, thru null (a new row, the old one ended, not
  updated); Valencia shop (facility) level 40, quantity 100, from its start, thru null.
  (b) Valencia at 35: its own facility row wins (the most specific scope), 35 ≤ 40, so it
  reorders 100. Sagunto at 25: no facility row, so the chain-wide row current on 10 Dec
  (level 30), 25 ≤ 30, reorders 50. The old level-20 row no longer applies (as-of test).

### 2026-11-03: round Q6, maintenance (reorder guideline; Papelería Mar; key above)
- Answer: (a) row 1 chain-wide ("no condition"), level 20, quantity 50, ended on 1 Dec ✓;
  row 2 Valencia scoped by geographic boundary ✗ (the question named the shop: a
  facility; a boundary covers every shop in the area), level 50 ✗ (40); row 3 chain-wide
  level 30, quantity 50, from 1 Dec ✓ (a new row, the old one ended, not updated); the
  current rows given "thru date set" ~ (null while current). (b) Valencia: its own row
  wins, most specific ✓, reorders 100 ✓. Sagunto: row 3 by the as-of test ✓, but "30 or
  less is not the case ... 5 short" ✗: 25 is below the level of 30, so it reorders 50.
- Blame: the user's; "when stock falls to" was in the wording.
- Score: reorder guideline 4 → 3 (back in the gap pool). Next: the shop as a facility
  scope, and the level as the floor.

### 2026-11-04: round Q2, Submodel 3 retest (reorder guideline; Ferretería Duna, screws 4×40)
- Asked live. One chain-wide row (from 2026-01-01, level 40, quantity 100). From 1 Dec 2026
  the Calle Mayor shop in Elche reorders at 60, 150 boxes; Alicante stays chain-wide; a
  second Elche shop opening next year starts chain-wide too. (a) the rows, (b) 3 Dec:
  Calle Mayor has 60, Alicante 41, (c) why that scope and not another.
- Answer: (a) the chain-wide row kept as is; a new row with the Calle Mayor facility, from
  1 Dec 2026, thru null, 60 and 150 ✓ cold (the 11-03 boundary scope and thru on current
  rows fixed). (b) Calle Mayor: its row, most specific, reorders 150 ✓; Alicante: the
  chain-wide row, no reorder until "40 or less" ✓ (the 11-03 floor miss fixed). (c) "the
  most specific zone wins" ✗: the mechanism, not why the facility over the Elche boundary
  (which would catch the new shop) or an internal organization; "zone" blurs the three (D15).
- Pushback: Claude wrote that an internal-organization scope is "wider still"; the user
  was right that it isn't wider than the chain-wide row, and it isn't wider than a boundary
  in general either: it scopes by who runs the shops, not which shop. After discussion the
  user gave the full why (a boundary or division row would catch a new shop silently); not
  counted cold.
- Score: reorder guideline 3 → 4 (the why for the facility to watch at its next maintenance).

### 2026-11-04: round Q4, Submodel 3 gap (where stock is + lot; Lácteos Sierra, yogurt lot Y-118)
- Asked live. One warehouse in Getafe, a cold room with shelves, a dock with an open floor.
  Lot Y-118 of Natural yogurt 4-pack: 400 packs, made 1 Nov, best before 20 Nov; 300 on
  shelf F2, 100 on the dock floor. (a) the lot and item rows, (b) the recall: every pack
  and its building, (c) why facility or container, never both.
- Answer: (a) two NON_SERIALIZED items, 300 with container F2, 100 with the facility (the
  dock as a facility, or the warehouse if the dock isn't one), both on Y-118 ✓ cold; the
  lot with 1 Nov, 20 Nov and 400 ✓ (a batch, not an origin: the 10-14 gap fixed), but a
  product on the lot ✗ (it's reached through the items; a copy could disagree). (b) filter
  items by lot; the building directly or through `container.facility_id` ✓. (c) the
  container knows its facility, two links could disagree, one fact in one place ✓ cold.
- Discussion: a lot with no items can't say its product (the price of keeping product off;
  born with its items, items stay at 0 on hand so the recall still reaches the product, a
  DQ query for itemless lots); `lot.quantity` is the batch's size, not the sum on hand; an
  item is "part of" the lot, not an allocation; only `inventory_item` points at `lot`;
  production runs, consumption and shipments reach it through the items (Ch 5, Ch 6).
- Score: where stock is + lot 2 → 3. Next: the lot holds no product.

### 2026-11-04: round Q5, Submodel 3 gap (estimated cost; Mesas Aliso, oak table + leaf)
- Asked live. Oak and walnut dining tables, an extension leaf option on either. Oak table:
  oak wood 120, carpentry 90; the leaf: hinges and runners 40, fitting 25; oak wood 140 from
  1 Jan 2027; the subsidiary Aliso Portugal (Porto) does carpentry at 60. (a) the rows
  (Apply), (b) Aliso Portugal's oak table with the leaf in Feb 2027: rows and total (Analyze),
  (c) "a cost column on the product and one on the feature" (Evaluate).
- Answer: (a) every estimate put on `supplier_product` ✗ (the 10-19 slip again: the table is
  `estimated_product_cost`, no supplier on it); carpentry made a feature ✗ (it's a LABOR
  component of the oak table; the leaf is the feature); the leaf rows hung off the oak
  product's row ✗ (the arc: they point at the leaf feature itself, so they serve the walnut
  table too); no cost component type ✗; the hinges row not in the paste ~; the 1 Jan 27
  change as thru on the old row plus a new 140 row ✓; Aliso Portugal's row scoped by the
  organization ✓, but on the carpentry "feature" ✗; from dates left blank ~ (not null).
  (b) oak wood from row #1 ✗ (that row ended 1 Jan 27; Feb takes the 140 row); Porto
  carpentry over the 90 ✓ (most specific wins); a new Porto leaf row #7 ✗ (the rest is the
  same: the general leaf rows apply); no total given ✗ (140 + 60 + 40 + 25 = 265).
  (c) history ✓, the split into components ✓ ("multiple costs"), "multiple suppliers" ✗;
  the per-organization cost (Porto's 60) missed.
- Score: estimated cost stays 2. Next: the table's name, carpentry as a component type not
  a feature, the arc points at the feature itself, the as-of row in a dated set.

### 2026-11-07: round Q1, Submodel 3 gap (estimated cost; Bicicletas Júcar, city bike + e-assist kit)
- Written for the phone, answered in chat. City and folding bikes, an e-assist kit on
  either; city bike frame 150 (bought from Cuadros Ebro), assembly 70; the kit's motor and
  battery 300, fitting 40; frame 165 from 1 Mar 2027; Júcar Norte (Castellón) assembles for
  55. (a) the rows (Apply), (b) Júcar Norte's city bike with the kit on 10 Apr 2027: rows
  and total (Analyze), (c) "put the 150 on Cuadros Ebro's supplier row" (Evaluate).
- Answer: (a) every row in the estimates table, Cuadros Ebro left to `supplier_product` ✓
  (the 11-04 gap fixed); a type on every row, MATERIALS or LABOR ✓; the kit's rows on the
  feature itself, written once ✓; the frame rise as thru 1 Mar 27 on the 150 row plus a 165
  row from 1 Mar 27 ✓; Júcar Norte scoped by organization ✓. But the Júcar Norte row
  "pointing to the assembly feature" and the rise on "the feature frame" ✗ (components
  called features, though the first rows pointed at the product); Júcar Norte's from date
  left unspecified ~ (not null: 1 Jan 2026); a "value" column naming each component ~
  (there is none: the type says it). (b) 165 as of 10 Apr ✓, 55 most specific over 70 ✓,
  the kit's 300 + 40 with nothing competing ✓; no total ✗ again (560). (c) the scope has
  nowhere to go ✓, the kit can't be split out ✓, a supplier row is another fact (who can
  supply, lead time, quality) with its own dates ✓; a second frame supplier giving two
  answers and margin missed.
- Discussion: the motor and battery have no name column; the type carries the kind of cost
  (PURCHASED_PART under MATERIALS, the frame's too: Cuadros Ebro decides the type, never
  the row); two finer child types if the motor and battery are costed apart. Card 8's cost
  line rewritten at the user's request to name the components (option B: "what the customer
  picks … split into the components we spend"); D18's Trap gains the slip. The guiding
  question (which arc column the 55 row fills) left unanswered.
- Score: estimated cost 2 → 3 (not 4: "feature" for a component came back twice). Next:
  retest cold, a component's row on the product (Júcar Norte's LABOR row); give the total.

### 2026-11-07: round Q3, Submodel 2 retest (where stock is + lot; Almazara Olivar, lot L-27)
- Written for the phone, asked in chat one part at a time (the user found the full text too
  long). Lot L-27 bottled 3 Oct 2026, 600 × 1 L extra virgin, best before 3 Oct 2028; 450 on
  pallet P7 in the Martos warehouse, 150 on the Jaén shop floor. (a) the lot and item rows
  (Apply), (b) the recall walk (Analyze), (c) "add product_id to the lot" (Evaluate).
- Answer: (a) no product on the lot ✓ cold (the 11-04 gap fixed); "the item has the link to
  the lot, not the other way round" ✓; expiry and the lot's name ✓; the creation date and
  the quantity 600 missed ✗ (both not null; the lot linked to "the 600 bottles inventory
  item row", which doesn't exist: 600 is the batch's own size); the 450 NON_SERIALIZED on
  container P7, the 150 NON_SERIALIZED on the Jaén shop facility, both on L-27 ✓ cold.
  (b) the product through the items ✓, container → facility ✓; "every lot row has a link to
  an inventory item" ~ (the arrow backwards, right in (a)); "every inventory item has a link
  to the facility" ~ (the pallet's 450 reach Martos only through P7: facility or container,
  never both); "group by lot" ~ (filter by L-27, then group). (c) one lot row per product,
  the lot's name and creation date repeated ~ (a real cost only if a lot held several
  products); "products on the lot expire differently" ✗ (one batch, one expiry); found it
  "tempting"; the core risk missed: the product on the lot and on every item, two copies that
  can disagree; and the recall still needs the items for the buildings.
- Score: where stock is + lot stays 3 (applied cold, but the why missed in (c) and the lot
  lost its own columns). Next: the why cold (a copy on the lot can disagree with its
  items), the lot's own columns (creation, quantity, expiry).

### 2026-11-07: round Q5, Submodel 4 gap (one typed table vs one entity per kind; Tinta Roble)
- Short version, asked in chat (the user's new default): Roble 2 replaces Roble 1 from
  1 Jan 2027; two A5 notebooks stand in for one A4, one way only. (a) the two
  `product_association` rows (Apply); (b) "a replacement table and a substitute table":
  what each design gives (Evaluate). The incompatibility, the gift box and the choice were
  cut.
- Answer: (a) "successor" Roble 1 → Roble 2 from 2027-01-01 ✓ (OBSOLESCENCE; Card 9 says
  successor); the substitute as A5 → A4 ~ ("A5 can replace A4" right, the arrow reversed:
  from is the one replaced, so A4 → A5) and no quantity 2 ✗ (the type-only column the
  question pointed at). (b) per kind: readable, `quantity` only on the substitute table,
  none on replacement ✓ unprompted (type-only columns where they apply); ours: new kinds as
  rows ✓; "reuse quantity and quantity_used" ✗ (each is used by one type only: nullable
  columns are the typed table's cost, not a gain); named ends (original, substitute) missed,
  though (a) had just tripped on from/to; one query for everything linked, NOT NULL by
  structure missed.
- Score: one typed table vs one entity per kind stays 2 (the from/to cost hit again in (a)
  and missed in (b); the shared columns taken for a gain). Next: the cost cold: from/to
  mean something different per type, type-only columns nullable and checked by queries.

### 2026-11-08: round Q7, Submodel 3 maintenance (inventory item; Ópticas Sauce, last 4 on 10-28)
- Short version, sent on WhatsApp 2026-11-07 with no column list, answered in chat today:
  two pairs of Sauce Sun (serials), SS-101 fine and SS-102 scratched, sold at a discount;
  40 lens sprays (counted), 4 with broken nozzles. (a) the inventory item rows (Apply),
  (b) the sprays: one row or two, and why (Understand). (c), the stock column on the
  product, was cut.
- Answer: (a) SS-102 SERIALIZED, no quantity, "damaged but sellable at a discount"
  (SLIGHTLY_DAMAGED) ✓; SS-101 good, no quantity ✓ (its kind left implied by the first
  row); the sprays NON_SERIALIZED, 36 good and 4 "damaged, not sellable" (DEFECTIVE) ✓;
  the product on every row ✓; the status and a facility on every row, unprompted ✓.
  "The rows are datd" was not decoded and isn't counted (if it means dated: an item
  carries no date, it is the stock as it stands, and counts change it through variance
  rows). (b) two rows: the 4 are in another state and there's no other way to say so (a
  row holds one status) ✓ cold.
- Score: inventory item stays 4 (maintenance passed, cold; status and where unprompted).

### 2026-11-08: round Q3, Submodel 3 retest (where stock is + lot; Quesería Valle, lot Q-12)
- Short, both parts in one go: lot Q-12 made 2 Nov 2026, 200 cheeses, best before 2 Feb
  2027; 150 on rack R4 in the Ávila warehouse, 50 on the Segovia shop floor. (a) the lot
  row and the item rows (Apply), (b) "put the product on the lot" (Evaluate).
- Answer: (a) the lot: its name, quantity 200, creation 2026-11-02, expiry 2027-02-02, no
  product ✓ cold (both 11-07 misses fixed); item 1 NON_SERIALIZED cheese 150 in container
  R4, no facility ✓; item 2 NON_SERIALIZED cheese 50 on the Segovia shop floor ✓; but
  neither item points at lot Q-12 ✗ (the link that ties the stock to its batch, which the
  recall walks; right on 11-07). (b) two copies of the product that can drift ✓ cold (the
  11-07 why); "a lot can't say 150 and 50 for two products (cheese and potatoes)" ~ (a lot
  is one batch of one product; the quantities sit on the items); that the recall walks the
  items anyway, so the copy saves nothing, not said.
- Score: where stock is + lot stays 3 (the lot's columns and the why both came back cold,
  but the items lost their lot). Next: the item → lot link cold, with the recall walk.

### 2026-11-08: round Q4, Submodel 4 retest (estimated cost; Carpintería Haya)
- Short, on WhatsApp, both parts in one go: the Haya chair since 1 Jan 2026, wood 40 (from
  Maderas Sil), labour 30, the Burgos workshop's labour 25; a cushion option on any chair,
  fabric 12. (a) the estimate rows (Apply), (b) a cushioned chair made in Burgos: the rows
  that count and the total (Analyze).
- Answer: (a) MATERIALS 40 on the chair ✓; LABOR on the chair written 40 ~ (30: a slip);
  LABOR 25 on the chair (the product, not a feature) scoped to Burgos ✓ cold (the 11-07
  gap); MATERIALS 12 on the cushion feature ✓; all from 2026-01-01 ✓; Maderas Sil left off
  ✓ unprompted. A "component" column naming wood, labour, fabric on every row ~ (again, as
  on 11-07: there's no such column, the type says the kind of cost; a finer child type if
  wood is costed apart). The scope as "the workshop Burgos facility" ~ (an estimate is
  scoped to a geographic boundary or one of our organizations, not a facility; the
  question's "workshop" invited it, so the blame is shared). (b) rows 1, 3 and 4: 40 + 25 +
  12 = 77 ✓ cold, the 25 most specific over the 30 ✓, the total given ✓ (missed twice
  before).
- Score: estimated cost 3 → 4 (both 11-07 gaps fixed cold; the slips noted). Next: none;
  the name column and the facility scope to watch.

### 2026-11-08: round Q5, Submodel 5 gap (one typed table vs one entity per kind; Papelería Cobre)
- Short, both parts in one go: two 0.5 L bottles of Cola Cobre stand in for one 1 L, one
  way only. (a) the product association row (Apply), (b) a table per kind
  (product_substitute with original, substitute, quantity, ...): what each design gives
  and costs (Evaluate).
- Answer: (a) SUBSTITUTE from the 1 L → to the 0.5 L, quantity 2 ✓ cold (the 11-07 arrow
  and quantity both fixed). (b) per kind: readable, "specific readable names" ✓ (the named
  ends, said loosely); its cost: each new kind a new table, and everything built on the
  generic type has to learn it ✓; ours: flexible, new kinds as rows ✓; when to pick it
  (kinds that keep coming) ✓, a good Evaluate call. No shared-columns gain claimed this
  time ✓. Missed again: what ours costs (from/to mean something different per type;
  type-only columns like quantity nullable, checked by queries instead of NOT NULL), and
  the per-kind table's type-only columns being NOT NULL where they apply.
- Score: one typed table vs one entity per kind stays 2 (gains and the per-kind cost
  right, but the generic table's own cost, the row's whole gap, missed a third time). Next:
  ours' cost cold, from/to per type and nullable type-only columns.

### 2026-11-10: round Q2, Submodel 3 retest (where stock is + lot; Conservas Brava, lot T-08)
- Short, live, both parts in one go: lot T-08 made 3 Nov 2026, 500 tins, best before 3 Nov
  2029; 300 in bin B2 in the Vigo warehouse, 200 on the Lugo shop shelves. (a) the lot row
  and the item rows (Apply), (b) the recall walk from the lot (Analyze).
- Answer: (a) the lot: name, creation 2026-11-03, expiry 2029-11-03, quantity 500, no
  product ✓ cold. Item 1 NON_SERIALIZED, 300, container B2 (the container sits in a
  facility, its own table) ✓; item 2 NON_SERIALIZED, 200, facility the Lugo shop ✓; product
  on both ✓. But neither row carries lot T-08 ✗ (the same miss as 11-08). (b) lot → the
  items that link to it → each item's facility, or its container joined to the
  container's facility ✓ cold; the product filter not needed, since the lot already picks
  the items ✓ (a sharp aside). The walk was cued by "starting from the lot".
- Score: where stock is + lot stays 3 (the walk cold and right, but the link left off the
  rows a second time). Next: write the lot on the item rows cold, without a walk to cue it.
- Discussion: the tables with `inventory_item.lot_id` filled in; the FK sits on the many
  side (the item), so the recall searches items by lot_id, and the lot knows nothing of its
  items. The user owned the miss ("I should have included the lot in the item rows").
  Agreed for the next retest: lot_id on the item rows unprompted, plus today's walk and
  the why (batch vs stock), makes it a 4.

### 2026-11-10: round Q3, Submodel 5 gap (one typed table vs one entity per kind; Ferretería Pino)
- Short, live, both parts in one go: drill D1 doesn't work with battery B2; since 1 Nov
  2026 screw pack S10 supersedes S8. (a) the product association rows (Apply), (b) two
  things the one table costs us (Evaluate).
- Answer: (a) "clash" D1 → B2 ~ (the type is INCOMPATIBILITY; own word, concept right; its
  from/to carry no direction, not said), the missing from date flagged as required ✓
  (from_date not null); "successor" S8 → S10 from 2026-11-01 ✓ (OBSOLESCENCE, superseded
  by, arrow and date right). (b) readable columns lost: generic from/to instead of
  meaningful FK names ~ (close to "from/to mean something different per type", but the
  cost to a reader or a query, that the type must be known to read the arrow, not said);
  nullable type-only columns, where a per-kind table holds its own quantity NOT NULL ✓
  cold (missed three times before).
- Score: one typed table vs one entity per kind 2 → 3 (both costs named, the nullable one
  cold at last; from/to said as naming, not as meaning per type). Next: from/to per type
  as a reading cost (incompatibility has no direction, obsolescence old → new).
- Discussion: the user pushed back ("I said it: meaningful FK and column names"); held at
  ~, since that names the per-kind gain, not our cost. Agreed for next time (the user's
  words): explain what our design costs us, not what the other design gains.

### 2026-11-11: round 2026-11-10 Q6, Submodel 2 maintenance (feature + applicability; Muebles Olmo, Olmo 3 sofa)
- Short, both parts in one go: oak legs always; grey, blue or green fabric, one must be
  picked; cushions included unless left out; a €90 footstool also sold on its own.
  (a) the applicability rows (Apply), (b) is the footstool a feature, and why (Understand).
- Answer: (a) oak legs REQUIRED ✓; grey, blue, green SELECTABLE ✓ cold; cushions OPTIONAL
  ✗ (key: STANDARD, in by default and can be left out; OPTIONAL is out unless asked for).
  No dates (not asked for in the short version, fine). (b) a product, not a feature: sold
  and stocked on its own ✓ cold; a COMPLEMENT product association sofa → footstool ✓
  unprompted.
- STANDARD missed a second time in a row: said as "required" on 10-31, as "optional" now.
  The four types are known; which way the default runs isn't held.
- Score: feature + applicability 4 → 3. Next: STANDARD vs OPTIONAL cold (default in, can
  be removed vs default out, can be added).

### 2026-11-11: round 2026-11-11 Q2, Submodel 3 retest (where stock is + lot; Miel Sierra, lot H-03)
- Short, both parts in one go: lot H-03 of rosemary honey made 2026-10-02, 400 jars,
  best before 2028-10-02; 250 on pallet P4 in the Teruel warehouse, 150 on the Zaragoza
  shop's shelf. (a) the rows that record the stock (Apply), (b) 100 jars move from P4 to
  the Zaragoza shelf: which rows change, which don't (Analyze).
- Answer: (a) the lot: H-03, creation 2026-10-02, expiration 2028-10-02, quantity 400, no
  product ✓ cold. Item 1 NON_SERIALIZED, 250, honey, container P4 ✓; item 2
  NON_SERIALIZED, 150, honey, facility the Zaragoza shop ✓; **both on lot H-03 ✓ cold**,
  the link missed 11-07, 11-08 and 11-10, now with no walk to cue it. P4 said to sit in
  "the Zaragoza shelf" facility, not the Teruel warehouse: a misreading, not counted. A
  from date and a null thru date put on both items ("set, but I didn't find it") ✗:
  `inventory_item` has no effectivity. (b) item 1 ended on the move date, a new P4 item
  at 150 and a new Zaragoza item at 100 opened from it, all on H-03 ✓ in substance; the
  lot and item 2 unchanged ✓ (the 400 is the batch, not what's left; the why wasn't
  asked). But the move versions the stock rows instead of updating them ✗: in the book,
  P4's item goes 250 → 150 on hand and Zaragoza's 150 → 250 (or a new item there), same
  rows, same ids.
- Why the dates don't fit (for the discussion): the inventory item is the current stock
  record, and other rows point at it (its variances here; Ch 5's shipment receipts and
  item issuances, whose balance the stored quantity on hand must equal). Ending it and
  opening a new one on each move leaves those pointing at a closed row and splits one
  stock into many ids. The history of moves is those events, not versions of the item.
- Score: where stock is + lot 3 → 4 (the lot on both items cold, the lot left alone by
  the move). Inventory item 4 → 3: a move updates quantity on hand in place, and the item
  carries no dates (retest).
- Discussion (asked to keep it short): a variance on the ended item points at a stale row
  ✓ (the user's words). Where the history lives: not known; the user read "no dates" as
  losing it. Taught: the item holds only the current quantity; the history is the events
  that point at it (receipts in, issuances out, variances for counts), and quantity on
  hand is their balance. A move is an issuance from P4's item and a receipt into
  Zaragoza's (a transfer shipment, Claude's recall of the shipments chapter, unverified).

### 2026-11-11: round 2026-11-11 Q4, Submodel 2 retest (feature + applicability; Bicis Ría, Ría 7)
- Short, both parts in one go: battery always fitted; rear rack on unless you ask to take
  it off; mudguards only if asked; frame M or L, one must be picked. (a) how each applies
  to the bike (Apply), (b) an order for a Ría 7 in M that says nothing else: rack,
  mudguards, and which row tells us (Understand).
- Answer: (a) battery REQUIRED, rear rack STANDARD, mudguards OPTIONAL, frame M and L
  SELECTABLE ✓ all cold; **STANDARD vs OPTIONAL right way round** (missed 10-31 and in
  round 2026-11-10 Q6). (b) the rack leaves on the bike, the mudguards don't ✓; the
  applicability row's type tells us: REQUIRED and STANDARD come without a word on the
  order, OPTIONAL and SELECTABLE only when the order names them ✓ cold.
- Score: feature + applicability 3 → 4. The 11-10 Q6 grading and D23 were earlier the
  same day, in another session; a later session with no hints, so it counts as cold, and
  the next maintenance check confirms it.

### 2026-11-11: round 2026-11-11 Q6, Submodel 2 maintenance (feature interaction; Ópticas Brisa, last 4 on 10-31)
- Short, both parts in one go: on the Brisa frame blue-light coating needs thin lenses,
  tinted can't take blue-light; on every frame polarized needs tinted. (a) the
  interaction rows (Apply), (b) why the first two name the frame and the third doesn't,
  and what goes wrong if the first names no product (Analyze).
- Answer: (a) DEPENDENCY blue-light → thin, one way, scoped to the Brisa ✓; tinted vs
  blue-light, direction doesn't matter, scoped to the Brisa ✓, typed "clashing
  (interoperability)" ~ (INCOMPATIBILITY; "clash" on 10-31 too, and interoperability means
  the opposite, working together); DEPENDENCY polarized → tinted, one way, no product ✓.
  All cold. (b) a product on the row confines the rule to that product, no product means
  every product ✓; with no product the first rule would bind every frame ✓ (the harm, a
  blue-light order on another frame flagged for lacking thin lenses, left implied).
- Score: feature interaction holds 4 (a pass; the type's name slipped a second time, a
  naming slip, not the concept).

### 2026-11-11: round 2026-11-11 Q7, Submodel 4 maintenance (base prices compete; Kayaks Delta, K2, last 4 on 11-01)
- Short, both parts in one go: K2 base prices €800, €760 in Galicia, €740 for CLUB
  customers in Galicia; Rosa (club, Vigo) and Ana (club, Madrid) order today. (a) each
  one's base price (Apply), (b) why Rosa's isn't 800 − 40 − 20 or any sum (Understand).
- Answer: (a) Rosa 740, both conditions match ✓ cold; Ana 800, the base with no
  conditions ✓ cold, worded "not a single condition matches" ~ (her club status does; the
  CLUB row also needs Galicia, so the row doesn't). Asked where −40 and −20 came from
  (the gaps between the three prices; the question's shorthand, fair to ask). (b) "prices
  that compete with each other depending on how specific they are" ✓, a readable
  catalogue with no extra step to compute ✓; stacked, every extra matching row would cut
  the price further ✓ (muddled wording); "we have ruling to determine which one apply a
  reduction", unclear at first, then explained ✓: stacking would need rules stored
  somewhere to say which rows reduce, and which to pick when several boundaries match
  (the order of application nobody stores).
- Score: base prices compete holds 4.

### 2026-11-13: question round, pending (wording in `docs/round-2026-11-13.md`; order in TODO)
- **Q4 key (inventory item; Ferretería Duna, screws 4×40).** (a) Before: one
  inventory_item, NON_SERIALIZED, the screws, facility Calle Mayor, quantity on hand 80, no
  dates. After: the same row, same id, 80 → 50 in place; a new item at Alicante, 30 (none
  there before). (b) Dates make each move end a row and open new ones: one stock splits
  into many ids, and the rows pointing at it (variances; Ch 5's receipts and issuances)
  point at a closed one. The history lives in those events; quantity on hand is their
  balance.
- **Q6 key (PRODUCT + good/service, maintenance; Jardines Musgo).** (a) Products: the
  olive tree (good), the workshop (service), the compost (good, bought in; Abonos Sur a
  supplier_product row). The large pot: a feature of the tree. The van: not a product,
  an asset we use (Ch 6's fixed asset, recall). Delivery is a charge on the order, not the
  van. (b) A product is what we offer for sale, not what we own or bought; the van is
  never sold, so as a product it'd show in the catalogue and in pricing.
- **Q7 key (feature prices add on top, maintenance; Sillas Nogal).** (a) 120 + 25 = 145.
  (b) A feature's price components compete only with that feature's (most specific wins:
  TRADE over any), and the sum of the winners adds on top of the product's base; the base
  and the feature price answer different parts of the price.
