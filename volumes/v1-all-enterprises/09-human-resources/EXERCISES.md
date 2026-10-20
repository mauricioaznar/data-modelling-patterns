# Vol 1, Chapter 9 — Exercises

Do these after the chapter's last figure is implemented. Each exercise is small. Answers and
the gaps log go in `EXERCISES-log.md` (or the chapter's SQL files) and get reviewed; no
answers are provided up front. Process: `docs/practice.md`.

**Flow, per submodel (about 3 hours each):** exam (about 6 questions, one at a time, climbing
Bloom's levels) → reinforce each gap with a fresh question → practice scenario → doc entry.
The sections below are a menu of formats, not a list to complete. A submodel is done when
every row scores 3+ and its scenario holds up.

**Submodels:**
1. Positions (Figs 9.3–9.4)
2. Employment, fulfillment and reporting (Figs 9.2, 9.5–9.6)

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
### Submodel 1: positions
1. *(9.3)* The salaried, exempt, full-time and temporary flags sit on POSITION, not on the
   person or the fulfillment. Why? Give a case where that's wrong (someone working half
   time in a full-time slot) and say where you'd record it.
2. *(9.3)* "Authorized" is never stored: it comes from the funding budget's status. What
   goes wrong if POSITION gets an `authorized_flag`?
3. *(9.3)* Why both VALID RESPONSIBILITY and POSITION RESPONSIBILITY? What would you lose
   with only the first, and what with only the second?
4. *(9.4)* Standard hours per week sit on POSITION TYPE CLASS, not on POSITION TYPE or
   POSITION. Argue for each of the three places. Which would you pick, and why?
5. *(9.4)* The union represents a *type* of job, not a person or a slot. A contractor
   fills a unionized slot: is the contractor covered? What does the model say, and what
   would you change if the answer had to be "no"?

### Submodel 2: employment, fulfillment and reporting
1. *(9.2, 9.5)* Employment links two party *roles* (employee, internal organization);
   fulfillment links a slot to a *person*. Why the difference? What does each allow that
   the other way round would not?
2. *(9.5)* Mike Johnson becomes CEO in 1996. In 9.1's model that's one UPDATE. Here,
   which rows are written or closed, and what can you still answer about 1990 that
   9.1 lost?
3. *(9.5)* Two half-time people share one full-time slot. How do you count FTEs and head
   count from these tables, and why does the book count on positions, not people?


## 1. Redraw from memory
Without the book, NOTES or schema, write out the chapter's main model in the transcription
notation (entities, key attributes, relationships and cardinality). Then diff it against
`NOTES.md` and list what you missed or got wrong.

## 2. Explain why
Short answers, 2–3 sentences each.
1. Positions (Figs 9.3–9.4)
2. Employment, fulfillment and reporting (Figs 9.2, 9.5–9.6)
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
1. Positions (Figs 9.3–9.4)
2. Employment, fulfillment and reporting (Figs 9.2, 9.5–9.6)
2.

## 6. Break the model
Try to insert data that *should* be invalid. For each attempt, note whether it got through,
and if it did, whether it deserves a constraint, a data-quality query, or just a note.
1. Positions (Figs 9.3–9.4)
2. Employment, fulfillment and reporting (Figs 9.2, 9.5–9.6)
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
