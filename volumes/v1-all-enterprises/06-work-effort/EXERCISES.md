# Vol 1, Chapter 6 — Exercises

Do these after the chapter's last figure is implemented. Each exercise is small. Answers and
the gaps log go in `EXERCISES-log.md` (or the chapter's SQL files) and get reviewed; no
answers are provided up front. Process: `docs/practice.md`.

**Flow, per submodel (about 3 hours each):** exam (about 6 questions, one at a time, climbing
Bloom's levels) → reinforce each gap with a fresh question → practice scenario → doc entry.
The sections below are a menu of formats, not a list to complete. A submodel is done when
every row scores 3+ and its scenario holds up.

**Submodels:**
1. Work requirements and roles (Figs 6.1–6.2)
2. Work effort generation (Fig 6.3a; 6.3b the alternate)

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

### Submodel 1: work requirements and roles
1. **[6.1]** WORK REQUIREMENT has three optional lines: to a product, a fixed asset and a
   deliverable. Why are they optional, what decides which one a row should fill, and where
   does that rule live if not in the foreign keys?
2. **[6.1]** A work requirement names at most one FIXED ASSET. What do you do with Ch 4's
   "Repair 14 PCs" (24905)? Give two ways to fix it, and say which one the model favours.
3. **[6.2]** Table 6.3 passes 50985 from John Smith to Dick Jones and back. What would a
   `responsible_party_id` column on REQUIREMENT lose, and which question could you no longer
   answer?

### Submodel 2: work effort generation
1. **[6.3a]** ORDER REQUIREMENT COMMITMENT carries a quantity; WORK REQUIREMENT FULFILLMENT
   carries none. Where does Table 6.4's 28045 record how much of its 3,500 goes to 50985 and
   how much to 51245, and does it need to?
2. **[6.3a]** Order 23500 reaches its work two ways: line 1 straight through WORK ORDER ITEM
   FULFILLMENT, line 2 through a requirement. Fig 6.3b keeps only the second. What does each
   choice cost, and which kind of business would pick each?
3. **[6.3a]** PRODUCTION RUN has quantities but no line to PRODUCT. How does a run know what
   it makes, and what happens to a run that fills neither a need nor an order line?
4. **[6.3a]** WORK EFFORT has two subtype sets: level (program to activity) and purpose
   (production run to research). Give a question only the first answers and one only the
   second answers. Why does only PRODUCTION RUN get a table of its own?
5. **[6.3a]** The facility is optional, and an effort without one is taken to happen where
   its parent does. What would a mandatory facility force you to record, and when would
   that be wrong?

### Submodel 3: work effort breakdown
1. **[6.4]** Table 6.6's set-up (120001) is part of two production runs. What does a
   `parent_work_effort_id` column on WORK EFFORT do with that row, and what would you have
   to copy to make it fit?
2. **[6.4]** Breakdown, precedency and concurrency all live in one association table. Which
   earlier pattern is this, and what does a query need to know about a concurrency that it
   doesn't need for a precedency?
3. **[6.4]** Table 6.6 gives each activity its own standard hours, yet the attribute sits on
   WORK EFFORT TYPE. What does that tell you about what WORK EFFORT TYPE really lists, and
   why does it fight with Ch 2's PROGRAM…ACTIVITY rows?

### Submodel 4: work effort assignments and time
1. **[6.5]** John Smith is a team member on 39409 twice, with a gap for his vacation. Which
   attribute in the assignment's key makes that possible, and what would break if the key
   were only effort, party and role?
2. **[6.5]** USA Consulting is assigned to 29005 and has skills. Why PARTY and not PERSON on
   both, and what does the enterprise give up by not knowing who at USA Consulting does it?
3. **[6.6]** A TIMESHEET hangs off a PARTY ROLE (a worker), while a TIME ENTRY hangs off a
   WORK EFFORT, not off the assignment. What does each choice buy, and which question
   (asked of Table 6.10) does the second one make hard?
4. **[6.6]** Why have TIMESHEET at all? Say what you lose if TIME ENTRY points straight at
   the party role and the timesheet disappears.

### Submodel 5: work effort rates
1. **[6.7]** Table 6.11 hangs Gary Smith's rates on his assignment, not on him. What does an
   `hourly_rate` column on PERSON lose? Name two rows of Table 6.11 it can't hold.
2. **[6.7]** A rate can sit on a position type, a party or an assignment. For Gary Smith's
   May 21, 2001 hours, which billing rate applies, and why doesn't the model itself say so?
   Where does that rule live?
3. **[6.7]** After his raise, Gary Smith's overtime pay equals his regular pay. Why record
   an overtime rate at all instead of leaving it out?

### Submodel 6: inventory and fixed asset assignments
1. **[6.8]** WORK EFFORT INVENTORY ASSIGNMENT points at an INVENTORY ITEM, while Fig 6.11's
   plan points at a GOOD. Why the item here? What could you no longer answer if it pointed
   at the good?
2. **[6.9]** FIXED ASSET has four subtypes and a FIXED ASSET TYPE that nests (vehicle,
   truck, 18-wheeler). Why both? And why is the overlap check stricter for an asset on work
   efforts than for a person on them (Fig 6.5)?

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
