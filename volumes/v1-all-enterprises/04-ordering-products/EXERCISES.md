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
3. *(to come: the rest of Ch 4's figures.)*

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
