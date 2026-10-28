# Vol 1, Chapter 4 — Exercises

Do these after the chapter's last figure is implemented. Each exercise is small. Answers and
the gaps log go in `EXERCISES-log.md` (or the chapter's SQL files) and get reviewed; no
answers are provided up front. Process: `docs/practice.md`.

**Flow, per submodel (about 3 hours each):** exam (about 6 questions, one at a time, climbing
Bloom's levels) → reinforce each gap with a fresh question → practice scenario → doc entry.
The sections below are a menu of formats, not a list to complete. A submodel is done when
every row scores 3+ and its scenario holds up.

**Submodels:**
1. **Orders, items and order parties** (Figs 4.1–4.5). ~3 h
2. **Order adjustments** (Fig 4.6). ~3 h
3. **Order status, terms and item associations** (Figs 4.7–4.8). ~3 h
4. **Requirements** (Fig 4.9). ~3 h
5. **Requests and quotes** (Figs 4.10–4.11). ~3 h
6. **Agreements** (Figs 4.12–4.13). ~3 h
7. **Agreement terms and pricing** (Figs 4.14–4.16). ~3 h

Fig 4.17, the overall order model, is the architecture figure: no practice of its own, it
gets the architecture card.

## Progress

### Comprehension (0–4 scale)
Built when the last figure is done: one row per concept (a pattern or a small group of tables),
covering every figure, listing the `schema.sql` tables it covers (every table belongs to
some row). "Understood" means: what it's **for**, how it **relates** to its neighbours, and
**spotting a wrong implementation**. No attribute-level detail.
0 untested · 1 recognises · 2 explains with help · 3 explains unprompted · 4 applies cold.
Below 3 = gap: reinforce in a loop until the evidence reaches 3, the neighbourhood question
(which entities it connects to, and what each connection means) is answered, and we agree
it's understood.

| Concept | Fig | Tables | Level | Evidence |
|---|---|---|---|---|
| **Submodel 1: orders, items and order parties** (practice started early, 2026-10-23, the user's call: points 1–9 settled, refactor pending, so explanations use the agreed design, not the old columns) | | | | |
| One order for both directions (supertype/subtype, the order kind) | 4.1–4.2 | `order`, `sales_order`, `purchase_order` | 3 | Q1: the kind named, on the right table; Q4: two order tables judged by repeated columns only, the doubled child tables missed; 2026-10-24 R4: the doubled children (parties, mechanisms) and the trade-off (readability, a true FK) unprompted, the line and its children not named |
| The line: product, feature or neither, the agreed price as a snapshot, ordered for | 4.2 | `order_item`, `sales_order_item`, `purchase_order_item` | 3 | 10-28 recall 3 (Muebles Roca): two sofa lines, each fabric a feature line ordered for its own sofa's line, prices on the lines, cold; the split into two sofa lines a guess, owned up (ordered for cold; stays 3 until the split and the description line are retested cold). 10-27 recall 2 (Ciclos Brava): order items, product/feature/neither and the snapshot cold; ordered for guessed as a link to the product ✗, the description missed (2 → 3). 10-26 Nevada order 77: catalogue rows given for order items ✗, the one-off engraving made a feature (not a description line) ✗, ordered for not named ✗, price put on price_component then the snapshot on the line in part 3 ✓. Q1: price snapshot on the line, unprompted; Q2: said ship-to "per product", not per line; Contoso: split per line right, but asked if serialized goods need a line each; Q4: price drift and product-not-unit both right, unprompted |
| Scoped roles on the order and the line (generic all the way) | 4.3–4.5 | `order_role`, `order_role_type`, `order_item_role`, `order_item_role_type` | 4 | 2026-10-25 order 31 (Ofisur → Grupo Lema): PLACED_BY, TAKEN_BY, BILL_TO, then SHIP_TO + END_USER for one party on line 1 and split across two parties on line 2, all cold. Q1: order-level hat right, line ship-to missed; florist: line ship-to after a nudge, placer missed; Q2: line ship-to unprompted, no why; Contoso: all four hats right, unprompted; ops manager: SALESPERSON filed as PLACED_BY twice; 2026-10-24 R1 (purchase order 9): all five order hats right cold on a purchase, the keyer kept off PLACED_BY, ENTERED_BY's name forgotten; 2026-10-24 R2 (Greenleaf): SALESPERSON with the 70/30 shares on the order and SHIP_TO per line, cold; END_USER missed (Verde SL receives and uses). END_USER still to retest for 4 |
| Where: contact mechanisms with a purpose, on the order and the line | 4.3–4.5 | `order_contact_mechanism`, `order_item_contact_mechanism` | 4 | 2026-10-25 order 31: the billing address on the order (follows BILL_TO) and SHIPPING per line, cold. Q1: both levels right; florist: billing address and purposes missed; Q2: line address missed, "one place" for the who; Contoso: billing and both line addresses right with purposes, placing e-mail missed; Q3: delivery contact put on the order, not the line; 2026-10-24 R2: both line addresses with SHIPPING, unprompted (not asked); R3: placing e-mail on the order and the delivery contact on the line, cold |
| Rules beside facts: which hats each order kind allows, and the standing role each needs | 4.5 (points 7, 9) | `order_role_rule`, `order_item_role_rule` (refactor) | 3 | Florist: the rule row and its after-the-fact check, unprompted (Q1 had said "doesn't do anything"); Q3: stored the taker rule as a role row (question worded ambiguously, retest); Q4: hard-coded taker not seen as a rule, TAKEN_BY read as the client; ops manager: dated rule and after-the-fact check unprompted, but cardinality put in the rule table |
| **Submodel 2: order adjustments** (practice started 2026-10-26, after its overview) | | | | |
| Every price change a typed row, on the order or one line (not a column per charge; the six top types, the sign from the type) | 4.6 (point 10) | `order_adjustment`, `order_adjustment_type` | 4 | 2026-10-28 recall 1 (Floristería Brisa): the rush SURCHARGE, the delivery shipping, the card FEE, cold; the six named right after Claude's FLOUTS slip (not counted); the card fee on the order with its why, once the wording was fixed (3 → 4). 2026-10-27 round Q1 (Vivero Alba): the six named cold (FLOUTS), the van typed shipping cold; the 5% rush typed MISCELLANEOUS, not SURCHARGE (stays 3). R1 (Olmo e-mail): the van typed shipping, cold (2 → 3). Q3 (Llano): normal delivery typed FEE a third time; the rush, discounts and tax right; a tax_per_line column proposed. 2026-10-27 recall 1 (Tostadero Luna): normal delivery typed FEE, surcharge, fee and discount right, the six not named (3 → 2). Q1 Harina Norte: two rows on the order, typed, cold; the plain delivery typed SURCHARGE, not SHIPPING_AND_HANDLING ✗ (retest the six) |
| An amount or a percentage: the amount the total charged, the percentage of the value before any adjustment, discounts as adjustments by convention | 4.6 (points 11, 42, 43) | `order_adjustment` | 2 | 2026-10-28 recall 2 (Papelería Sol): the 10% taken after the line's €10 again (5 and 45, not 6 and 44), the convention's direction reversed; the 60 base only once told it runs the other way, the why not given (3 → 2). 2026-10-27 round Q1 (Vivero Alba): both percentages on 160, the value before any adjustment, cold (4 on a later day). R1 (Olmo e-mail): the line discount as the 30.00 total and its staleness at 40 bags, cold; "a query flags it" off (2 → 3). Q3 (Llano): the line discount row missed, €0.50 per unit read as 50% (the stale amount still untested). 2026-10-27 recall 3 (Panadería Olmo): amount vs percentage and levels right; the 20.00 total not said, the unit price convention missed, the 10% taken after the line discount (300, not 298). Q1: the percentage vs amount split right; the total, the base and the convention untested |
| Sales tax: a dated rate per boundary and optional category, copied onto the order | 4.6 (point 12) | `sales_tax_lookup` | 3 | 2026-10-27 Q2 (Pinecone, Austin): rows per boundary and category right, the order date not the ship date, the snapshot, cold; the rates 8.25 and 2.0 and the stored percentage not said |

### Open threads
-

## 0. To ponder (collected while reading)
Questions and ideas raised while the chapter was being built, tagged with their figure.
At most 5 per submodel. Answer in a sentence or three under each item. Group them under
`### Submodel N: name` headings, numbered as in STATUS.md, so `npm run check` can count them.

### Submodel 1: orders, items and order parties
1. **[4.2]** ORDER ITEM keeps its own UNIT PRICE, though Ch 3's price components can work out
   a price. Why store it, and what would go wrong if an item only pointed at the price
   components that priced it?
2. **[4.2]** The copier's duplex unit is an ORDER ITEM of its own, "ordered for" the copier's
   item, not a column or a list on the copier's item. What does that buy, and which rules must
   then hold that no foreign key checks?
3. **[4.3]** SALES ORDER names its placing customer, taking organization and bill-to through
   PARTY ROLE, while ORDER ROLE names a PARTY and a type. Why the difference, and how do you
   decide whether a new kind of order party gets a line of its own or a row in ORDER ROLE?
4. **[4.4]** `purchase_order` has the same six party lines as `sales_order`, and every party
   check is written twice. Which Fig 4.1 problem is back, one level down? Why might Silverston
   still draw the lines on each subtype rather than once on ORDER?
5. **[4.5]** Fig 4.5 turns every party and contact mechanism line into a typed row. Name two
   rules that 4.3's columns enforced for free and the rows don't, and describe a business
   for which you'd still choose 4.5.

### Submodel 2: order adjustments
1. **[4.6]** An adjustment is a row, not a `discount` or `tax` column on the order. What does
   that buy? And what does a percentage leave unsaid: of what is it taken, and in which order
   are adjustments applied?
2. **[4.6]** SALES TAX LOOKUP has no line to ORDER ADJUSTMENT. How does a sales tax adjustment
   get its rate, and why copy the rate instead of pointing at the lookup row?
3. **[4.6]** A 10% volume discount on a line could be a lower unit price or an adjustment.
   When would you use each, and what does each make easy or hard to report?

### Submodel 3: order status, terms and item associations
1. **[4.7]** ORDER STATUS is a dated row per change, on the order or on one item, not a
   `status` column on the order. What does each of those two choices buy, and how do you find
   an order's current status?
2. **[4.7]** Shipped, invoiced and backordered can be worked out from other facts, yet the
   book lets you store them as status types. What can go wrong once you store them, and how
   would you catch it?
3. **[4.7]** An ORDER TERM's value is a bare number: 25 means a percentage, 10 a number of
   days, only through the TERM TYPE. What does a query that works out a cancellation deadline
   have to know, and what would you add if terms needed units or text?
4. **[4.8]** ORDER ITEM ASSOCIATION has no quantity. 12564's 100 pens fill a 30-pen and a
   20-pen sales line. What can't the model tell you, and what would you add to fix it? Why
   might Silverston have left it out?

### Submodel 4: requirements
1. **[4.9]** A requirement is a need before any order. Why not record it as a draft order
   instead? Name two things REQUIREMENT holds that an order item can't.
2. **[4.9]** Table 4.11 names no product on any requirement, only desired features. Why might
   a need be described by features rather than by a product, and how would you find the
   products that could fill it?
3. **[4.9]** ORDER REQUIREMENT COMMITMENT carries a quantity; 4.8's ORDER ITEM ASSOCIATION
   doesn't. Why does the commitment need one?
4. **[4.9]** REQUIREMENT has two sets of subtypes (customer or internal; product or work).
   How did we build two independent sets, and what would one four-way list get wrong?

### Submodel 5: requests and quotes
1. **[4.10]** A REQUEST ITEM names no product; it reaches its requirements through
   REQUIREMENT REQUEST, a many-to-many. Why no product, and what would break if each request
   item could carry only one requirement?
2. **[4.11]** QUOTE ITEM names its own product, although you could reach a product from the
   request item through its requirement. Why keep both paths? Use Paperline's quote, or
   Table 4.15's black pens.
3. **[4.11]** Walk Northwind's paper from need to order: which entities and lines does it
   pass through, and which of those links carry a quantity?

### Submodel 6: agreements
1. **[4.12]** An AGREEMENT may point to the PARTY RELATIONSHIP it formalizes, and it also has
   AGREEMENT ROLES. Why both? What goes wrong with only the relationship, and what with only
   the roles?
2. **[4.12]** AGREEMENT is drawn with subtypes (product, sales, purchase, employment, other)
   and with an AGREEMENT TYPE. When does a kind of agreement deserve a subtype box, and when
   is a type row enough?
3. **[4.13]** A pricing program with no product applicability rows: does it apply to every
   product or to none? Pick a reading, and say what each one costs when a new product joins
   the catalogue.
4. **[4.13]** Why record an ADDENDUM instead of editing the item's text, and why may it
   change the whole agreement or one item, but not both?
5. **[4.13]** A SUB AGREEMENT is an item of its agreement, not an AGREEMENT of its own under a
   parent. What can't it have that way (its own parties, its own dates), and when would you
   make it a full agreement instead?

### Submodel 7: agreement terms and pricing
1. **[4.14]** An AGREEMENT TERM has dates of its own, inside an agreement that already has
   dates. Why? Use Table 4.18's two caps on the paper, and say what a term with no dates
   would have to mean.
2. **[4.14]** Order, quote and agreement terms now share one TERM TYPE, with the five
   agreement-term subtypes at its top. What does sharing the list buy, and what goes wrong
   if each term table keeps its own?
3. **[4.15]** An agreed price is a Ch 3 PRICE COMPONENT with one more line, not an AGREEMENT
   PRICE entity of its own. What does reusing PRICE COMPONENT buy, and what must every query
   that reads "the price list" now do differently?
4. **[4.16]** No line joins ORDER to AGREEMENT. How does an order line find the agreement items
   that govern it, and why might Silverston prefer that to an `agreement_id` on the order?
   When would you store the link anyway?
5. **[4.16]** The order line keeps its own unit price (4.2) although the agreement says what
   it should be. Why keep both? Use 12573's paper and 12562's pens: what does comparing
   them catch that neither catches alone?

## 1. Redraw from memory
Without the book, NOTES or schema, write out the chapter's main model in the transcription
notation (entities, key attributes, relationships and cardinality). Then diff it against
`NOTES.md` and list what you missed or got wrong.

## 2. Explain why
Short answers, 2–3 sentences each.
1.
2.
3.

## 3. Spot the flaw
A model with a deliberate mistake. Find it, say what data it would corrupt or fail to hold,
and fix it.

```
```

## 4. Extend it
A new business requirement the chapter's model doesn't cover yet. Change the model (and the
SQL if needed) to support it.

**Requirement:**

## 5. Write the queries
Add each one to `queries.sql` under a `-- name:` header.
1.
2.

## 6. Break the model
Try to insert data that *should* be invalid. For each attempt, note whether it got through,
and if it did, whether it deserves a constraint, a data-quality query, or just a note.
1.
2.

## 7. Trade-offs
Two ways to model the same thing. Which would you choose, for which kind of system, and why?

## 8. In your own words
Rewrite these NOTES.md sections yourself, 3–5 bullets each:
- The problem this pattern solves
- When NOT to use this

## 9. Capstone
A small real-world problem to model from scratch using this chapter's patterns, without the
book. Then compare with the book's model and note the differences.

**Scenario:**
