# Vol 1, Chapter 3 — Exercises

Figures 3.1–3.6 are built (the rest of Ch 3 isn't shared yet). Answers and the gaps log go in
`EXERCISES-log.md` (or the chapter's SQL files) and get reviewed; no answers are provided up
front. Process: `docs/practice.md`.

**Flow, per submodel (about 3 hours each):** exam (about 6 questions, one at a time, climbing
Bloom's levels) → reinforce each gap with a fresh question → practice scenario → doc entry.
Section 0 is the exam pool. Sections 1–7 are a menu of formats for reinforcing, not a list to
complete. A submodel is done when every row scores 3+ and its scenario holds up.

**Submodels**
1. **Product definition, categories and identification** (Figs 3.1–3.3). ~3 h
2. **Product features** (Fig 3.4). ~3 h
3. **Suppliers and inventory** (Figs 3.5–3.6). ~3 h
4. *(to come: the rest of Ch 3, e.g. pricing, costs, associations.)*

## Progress

### Comprehension (0–4 scale)
0 untested · 1 recognises · 2 explains with help · 3 explains unprompted · 4 applies cold.
Below 3 = gap: reinforce in a loop until the evidence reaches 3, the neighbourhood question
(which entities it connects to, and what each connection means) is answered, and we agree
it's understood.

#### 1. Product definition, categories and identification

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| PRODUCT (what we offer) + good/service | 3.1 | product | 2 | reinforce | Q1: put GOOD under category; fixed after a prompt. 10-12 soft ball: kinds right, invented a `service` table; why `good` exists (identification FK) after a hint |
| Category classification (dated, primary) | 3.2 | product_category_type, product_category, product_category_classification | 3 | agree to close | 10-14 neighbourhood (product, category; rollup and market interest beside it) ✓. 10-14 reinforce (rose): primary, dates and why (double count / dropped; history), unprompted. 10-12 Q6: exclusive thru right; primary missed again, then put "on coffee" (it's the classification row). Q4: primary unprompted; Q5: missed dates + primary on the link even with a hint |
| Category rollup (network, not tree) | 3.2 | product_category_rollup, product_category_ancestor (view) | 2 | reinforce | 10-12 Q6: classified under parents, rollup rows right after prompt; made a service a child category. Q2: unprompted; Q5: read a single parent column as "no multiple descendants" |
| Market interest | 3.2 | market_interest (→ Ch 2 party_type) | 3 | agree to close | 10-14 neighbourhood: links category to party type, dated ✓ (verb loose). Q4: type-level vs a real sale, unprompted |
| Identification codes as rows | 3.3 | identification_type, good_identification | 3 | neighbourhood | 10-12 Q6: EAN-13 + SKU rows typed by identification_type, names right, no dates, unprompted. Q1: shape unprompted; Q3: invented dates; Q4: put the format rule on the code, not the type; names forgotten |

#### 2. Product features

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| Feature + applicability | 3.4 | product_feature_type, product_feature_category, product_feature, product_feature_applicability_type, product_feature_applicability | 3 | neighbourhood | 10-14 Commuter bike: all types and layers right, unprompted. Warm-up: red pen row as a sentence; SELECTABLE vs OPTIONAL after a concrete prompt (order with no colour), saw OPTIONAL is wrong for a pen |
| Feature interaction (rule as data) | 3.4 | product_feature_interaction_type, product_feature_interaction | 3 | neighbourhood | 10-14 laptops: rows, scope, direction and symmetry unprompted; second flag after "is that all?". Commuter: layers right; rule backwards, fixed on reread; null product after a reminder. LaserNet: thought rules check against applicability, put an optional feature in interaction (layers mixed). Earlier 10-14: why a row ✓; product context after the BigOffice prompt; unprompted, challenged the global rule and proposed splitting the feature (valid trade-off) |
| Unit of measure + conversion | 3.4 | unit_of_measure, unit_of_measure_conversion, product.uom_id | 3 | neighbourhood | 10-14 reels: conversion is per unit pair, not product, unprompted. Hose: both rows right; why two places only half there, unsure |

#### 3. Suppliers and inventory

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| Manufacturer vs supplier (supplier product) | 3.5 | product.manufacturer_party_id, supplier_product, preference_type, rating_type | 2 | exam | 10-14 bike shop: supplier rows ✓; Ana's Garage as manufacturer, fixed after the Johnson prompt |
| Reorder guideline (scoped rule) | 3.5 | reorder_guideline | 2 | reinforce | 10-14 helmets: two scoped rows unprompted; Madrid level misread, fixed on prompt. Bike shop: read two scoped levels as one row (level + quantity) twice; given |
| Inventory item (good vs physical stock, subtypes, status) | 3.6 | inventory_item, inventory_item_status_type | 3 | neighbourhood | 10-14 Valencia: serialized vs counted, status choice with a new status, unprompted; phone count misread |
| Where stock is (facility XOR container) + lot | 3.6 | container, container_type, lot | 2 | exam | 10-14 Valencia: looked through the container to the facility unprompted; lot first read as origin, not yet applied |
| Variance (count adjustments) | 3.6 | inventory_item_variance, reason | 3 | neighbourhood | 10-14 Valencia: −2 THEFT row ✓; argued reported + correction = derived and saw the convention isn't in the table |

#### Cross-cutting (carried over from Ch 2, tested inside the submodels)

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| Subtype vs type row | all | every `*_type` here (product_kind, product_feature_type…) | 3 (Ch 2) | in scenarios | |
| Type / fact / rule layers | 3.2, 3.4 | market_interest, product_feature_interaction, identification_type.value_pattern | 3 (Ch 2) | in scenarios | |
| Effectivity (as-of, exclusive thru) | all | every from/thru; product discontinuation dates | 2 (Ch 2) | in scenarios | |

### Open threads
- Figs 3.2–3.4 checked against the book 2026-10-11: GOOD IDENTIFICATION links to GOOD (new
  `good` table, services carry no codes), and the unit of measure hangs off DIMENSION only.

## 0. To ponder (collected while reading)
Questions and ideas raised while the chapter was being built, tagged with their figure.
At most 5 per submodel. Answer in a sentence or three under each item.

### Submodel 1: product definition, categories and identification
1. **[3.1]** Price, supplier and quantity on hand are *not* attributes of PRODUCT. For each
   one, say what else it varies by, and what breaks if it's a column on `product`.
2. **[3.2 vs Ch 2 Fig 2.3]** PRODUCT CATEGORY CLASSIFICATION and PARTY CLASSIFICATION have the
   same shape. Describe the shape in one sentence, and name one more place in a business where
   you'd expect to find it.
3. **[3.2]** What goes wrong in a sales-by-category report without the primary flag? Should
   "primary" be one per product, or one per product per dimension (usage, industry, materials)?
4. **[3.2]** MARKET INTEREST links party types to product categories. Which layer (type, fact
   or rule; your Ch 2 item 54) does it belong to, and how do you get from it to a list of
   real customers to call?
5. **[3.3]** Two rules: "a product has one value per code type" and "a code identifies only
   one product". Which one is the book's identifier, which one does a cashier's scanner depend
   on, and why are both data-quality queries here rather than constraints?

### Submodel 2: product features
6. **[3.4]** Why does required / standard / optional / selectable sit on PRODUCT FEATURE
   APPLICABILITY and not on PRODUCT FEATURE?
7. **[3.4]** A pen in blue and black: one product with two selectable features, or two
   products? When is each answer right?
8. **[3.4]** PRODUCT FEATURE INTERACTION is a rule stored as data. What actually enforces it,
   and what do you gain and lose compared with a rule in code or a check constraint?
9. **[3.4]** "1 box = 10 each." Where does UNIT OF MEASURE CONVERSION break down, and how
   would you change the model to fix it?
9a. **[3.4]** (the user's question) A duplex unit built into one copier and sold as an add-on
    for another: when is it a feature, when a product of its own, and when both?

### Submodel 3: suppliers and inventory
10. **[3.5]** Johnson Paper Mills makes the paper *and* sells it to us. Which two places in the
    model record that, and why isn't one enough?
11. **[3.5]** SUPPLIER PRODUCT links to PRODUCT but REORDER GUIDELINE links to GOOD. Why the
    difference?
12. **[3.5]** A reorder guideline for paper at the Chatham warehouse and another for paper
    across Illinois are both current, and Chatham is in Illinois. Which one applies, and does the
    model say?
    *Answered 2026-10-14 (log: Submodel 3, helmets overlap).*
13. **[3.6]** Why is `quantity_on_hand` on NON SERIALIZED INVENTORY ITEM and not on PRODUCT
    (or GOOD)? What can't you answer if it lives on the product?
14. **[3.6]** A count finds 3 reams missing. Record it two ways: update `quantity_on_hand`, or
    add a variance. What does each lose?
    *Answered 2026-10-14 (log: Submodel 3, Valencia phone shop).*

## 1. Redraw from memory
Without the book, NOTES or schema, write out one submodel in the transcription notation
(entities, key attributes, relationships and cardinality). Then diff it against `NOTES.md`
and list what you missed or got wrong.
- a. Submodel 1: PRODUCT, its categories (classification, rollup, market interest) and codes.
- b. Submodel 2: features, applicability, interactions and units of measure.

## 2. Explain why
Short answers, 2–3 sentences each.
1. **[3.2]** Why is PRODUCT CATEGORY ROLLUP a separate table rather than a `parent_id` column
   on PRODUCT CATEGORY?
2. **[3.3]** Why has GOOD IDENTIFICATION no from/thru dates, and when would you add them?
3. **[3.4]** Why is DIMENSION the only feature subtype with an attribute?

## 3. Spot the flaw
A model with a deliberate mistake. Find it, say what data it would corrupt or fail to hold,
and fix it.

a. Submodel 1:
```
PRODUCT
  # product_id
  * name
  * category_id      -> PRODUCT CATEGORY
  o upc
  o isbn
  o sku
```

b. Submodel 2:
```
PRODUCT FEATURE
  # product_feature_id
  * description
  * applicability     (REQUIRED / STANDARD / OPTIONAL / SELECTABLE)
  -> PRODUCT          (many features belong to 1 product)
```

## 4. Extend it
A new business requirement the model doesn't cover yet. Change the model (and the SQL if
needed) to support it.
- a. **[3.2]** Marketing wants a "primary category for the web shop" *and* a different
  "primary category for sales reports" for the same product.
- b. **[3.4]** A copier option costs extra only when added after purchase (a field upgrade), and
  the duplex unit is only compatible with copiers made after 2021.

## 5. Write the queries
Add each one to `queries.sql` under a `-- name:` header.
1. **[3.2]** Every category's full path(s) to the top, e.g. "Office supplies > Paper > Business
   forms" (Business forms has two).
2. **[3.4]** Extend the configuration check: a product with SELECTABLE features needs exactly
   one chosen per feature type.

## 6. Break the model
Try to insert data that *should* be invalid. For each attempt, note whether it got through,
and if it did, whether it deserves a constraint, a data-quality query, or just a note.
1. A product classified in a category that ends before it starts, or in the same category twice
   over overlapping periods.
2. A feature interaction where the two features are on different products than the context.
3. A unit conversion chain that contradicts itself (A→B, B→C, A→C).

## 7. Trade-offs
Two ways to model the same thing. Which would you choose, for which kind of system, and why?
- T-shirts in S/M/L × three colours: one PRODUCT with selectable features, or nine products
  (or a product + variant table)? Think about stock, price and barcodes.

## 8. Practice scenarios (one per submodel, the Create step)
Model from scratch, without the book, NOTES or schema. Give entities and a few sample rows,
then compare with the chapter.

**Submodel 1: a bookshop and café.** It sells books (ISBN and its own shelf code), board games
(UPC and the publisher's part number), coffee beans by the kilo, and a monthly book-club
subscription. The owner groups stock by genre (Fiction > Crime, Fiction > Fantasy), by age group
(Kids, Teens, Adults) and by occasion (Gifts). A crime novel for teens appears under several of
these. Last year "Graphic novels" moved from under Fiction to its own top-level group, and the
owner still wants last year's sales report by the old grouping. Schools tend to buy kids' books.

**Submodel 2: a bicycle shop.** A city bike comes in three frame sizes (pick one) and two
colours (pick one). Lights are standard, a basket and a child seat are optional, and the child
seat needs the rear rack. The basket can't go on the carbon handlebar upgrade. Frame size is
in centimetres, but US customers ask in inches. Tyres are sold singly, inner tubes in packs of 5.

**Submodel 3: a bike-parts distributor.** It buys brake pads from the manufacturer and from two
wholesalers, preferring the manufacturer, and rates each one. It also resells a repair service
that a local workshop performs. It keeps stock in two warehouses; in one, small parts sit in
labelled bins. E-bike batteries are tracked by serial number, brake pads by quantity, and
tyres by production batch because rubber ages. The big warehouse reorders pads at 200, the
small one at 20. Last month's count found 12 pads missing and one battery damaged.
