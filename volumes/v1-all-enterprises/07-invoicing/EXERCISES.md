# Vol 1, Chapter 7 — Exercises

Do these after the chapter's last figure is implemented. Each exercise is small. Answers and
the gaps log go in `EXERCISES-log.md` (or the chapter's SQL files) and get reviewed; no
answers are provided up front. Process: `docs/practice.md`.

**Flow, per submodel (about 3 hours each):** exam (about 6 questions, one at a time, climbing
Bloom's levels) → reinforce each gap with a fresh question → practice scenario → doc entry.
The sections below are a menu of formats, not a list to complete. A submodel is done when
every row scores 3+ and its scenario holds up.

**Submodels:**
1. Invoices and invoice items (Fig 7.1a)
2. Invoice parties and billing accounts (Figs 7.2–7.3a)

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

### Submodel 1: invoices and invoice items
1. **[7.1a]** Ch 4 kept order adjustments in their own ORDER ADJUSTMENT table; Ch 7 makes tax,
   shipping and fees plain INVOICE ITEMs with a type. What does the invoice gain from that,
   and what rule do you now have to check that the order's separate table gave you for free?
2. **[7.1a]** ACME was billed 10 reams on 30002 and got 8. Why does the book add a −2 line
   (on 30016, pointing back) instead of changing 30002's quantity to 8? Name one question
   the edit would make impossible to answer.
3. **[7.1a]** Two servers with different features on one invoice. Why can't you put
   `product_id` and `product_feature_id` on the same line and be done, and what does
   "sold with" fix?

### Submodel 2: invoice parties and billing accounts
1. **[7.2]** Billed to and billed from are lines on INVOICE, while "entered by" and
   "approver" are INVOICE ROLE rows. What decides which party gets a line and which gets a
   role row? Where else in the book have you seen the same split?
2. **[7.2]** 30005 went to jsmith@us.com. What would a `billing_address_id` pointing at a
   postal address table cost this business, and what check keeps the open CONTACT MECHANISM
   line honest?
3. **[7.3a]** An invoice is billed to a party *or* to a billing account. On 30013, billed to
   account 1459, who owes the money, and how do you find out? What changes on Jun 16, 2001?
4. **[7.3a]** Table 7.5 gives ACME two accounts at the same address. Why not one account
   with two descriptions, or no accounts and a "cost centre" column on the invoice?

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
