# Vol 1, Chapter 5 — Exercises

Do these after the chapter's last figure is implemented. Each exercise is small. Answers and
the gaps log go in `EXERCISES-log.md` (or the chapter's SQL files) and get reviewed; no
answers are provided up front. Process: `docs/practice.md`.

**Flow, per submodel (about 3 hours each):** exam (about 6 questions, one at a time, climbing
Bloom's levels) → reinforce each gap with a fresh question → practice scenario → doc entry.
The sections below are a menu of formats, not a list to complete. A submodel is done when
every row scores 3+ and its scenario holds up.

**Submodels:**
1. **Shipments, items and status** (Figs 5.1–5.2). ~3 h
2. **Shipments and orders** (Fig 5.3). ~3 h

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

### Submodel 1: shipments, items and status
1. **[5.1]** SHIPMENT points at PARTY for its sender and receiver, where Ch 4's SALES ORDER
   pointed at PARTY ROLE ("ACME as placing customer"). What would a role add on a shipment,
   and what tells you which side is ours without one?
2. **[5.1]** A customer shipment and a purchase return both leave one of our organizations
   for an outside party. If the direction is the same, what in the data tells them apart, and
   why keep them as two types?
3. **[5.2]** The estimated ship and arrival dates sit on SHIPMENT; when it really shipped and
   arrived sits in SHIPMENT STATUS. Why not an `actual_ship_date` column beside the estimate?
   What does the history answer that the column couldn't?
4. **[5.2]** SHIPMENT STATUS is identified by its shipment and its status type, where Ch 4's
   ORDER STATUS has an id of its own. What can a shipment's history not record because of
   that, and would you keep the book's identifier?
5. **[5.2]** Ch 4 let a status sit on the whole order or on one item. A shipment's status sits
   only on the shipment. When would a status per shipment item be missed, and what would you
   reach for instead?

### Submodel 2: shipments and orders
1. **[5.3]** ORDER SHIPMENT joins an order *item* to a shipment *item*, with a quantity. Why
   not a line from ORDER to SHIPMENT, or a foreign key from SHIPMENT ITEM to ORDER ITEM? Use
   9000's pen line and order 100's pencil line to show what each would lose.
2. **[5.3]** Table 5.5's 9200 carries 1,500 pencils that no line of Table 5.6 claims. Is that
   an error? Name two kinds of shipment line that rightly fill no order line, and say how the
   data tells them apart from a mistake.
3. **[5.3]** Blue pens were ordered and black ones shipped. The book records the shipped
   features on the shipment line, not on ORDER SHIPMENT. What can each place say that the
   other can't, when one shipment line fills two orders?
4. **[5.3]** A drop shipment fills two order lines at once. Which ones, whose are they, and
   why can't a customer shipment do the same?

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
