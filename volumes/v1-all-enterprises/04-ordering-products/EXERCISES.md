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
7. *(to come: the rest of Ch 4's figures.)*

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
|  |  |  | 0 | |

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
