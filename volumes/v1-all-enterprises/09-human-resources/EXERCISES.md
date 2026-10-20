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
3. Pay and benefits (Figs 9.7–9.8)
4. Payroll (Fig 9.9)
5. Applications and qualifications (Figs 9.10–9.11)
6. Performance and termination (Figs 9.12a, 9.13)

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
4. *(9.6)* On Jan 1, 2001 the director's slot closes and two managers take its three
   reports. List the rows that change in 9.6's model and in 9.1's. Which one still
   answers "who did the business analyst report to in June 2000"?
5. *(9.6)* Reporting runs slot to slot. When does that give the wrong answer to "who is
   Kim's boss?" (hint: vacancies, job shares, acting managers), and how would you
   answer it from these tables?

### Submodel 3: pay and benefits
1. *(9.7)* A position type rate holds an amount or a salary step, never both. Which
   enterprise uses each? What goes wrong when one row has both?
2. *(9.7)* A grade's step amount is updated in place. What question can no longer be
   answered after a raise, and what is the smallest change that would answer it?
3. *(9.7)* Pay history hangs on the employment, not on the position or the person. John
   Smith moves from programmer to analyst inside ABC Corporation, then joins a second
   employer part time. What happens to his pay history in each case?
4. *(9.8)* Three places say how much the employer pays: BENEFIT TYPE's employer paid
   percentage, PARTY BENEFIT's actual employer paid percent, POSITION TYPE's benefit
   percent (9.3). What question does each answer? Could you drop one?
5. *(9.8)* John Smith has 15 vacation days as PARTY BENEFIT's available time. He takes
   three days off in March. What do you write, and where is the record of the three
   days? Is available time an entitlement or a balance?
### Submodel 4: payroll
1. *(9.9)* PAYROLL PREFERENCE is keyed on the employee's role and the hiring firm's, not on
   the employment. What does that allow, and what can it get wrong?
2. *(9.9)* The $125 insurance appears twice: as preference 4 and as deduction 4 on check
   1001. Which is the plan and which the fact? What would you lose with only one?
3. *(9.9)* The payment holds the gross $2,000 and the net is derived. Argue for storing
   the net instead. What would Ch 7's bank deposits and Ch 8's postings need either way?
4. *(9.9)* On Nov 2, 1999 John Smith changes banks: row 1 closes and row 3 opens. Why
   not update row 1's account number?
### Submodel 5: applications and qualifications
1. *(9.10)* An application's slot is optional. Give two business questions that need it
   filled and one that works without it. What would you do with an application for a
   slot that was later cancelled?
2. *(9.10)* The application has one current status, no history. Which recruiting question
   does that kill (hint: time to hire), and what would you add?
3. *(9.11)* Qualifications, skills and resumes hang on PARTY, training on PERSON. Give an
   organization's example for each of the first three, and say why training is different.
4. *(9.11)* Slot 101 needs an MBA and three years of business analysis. Nothing in Ch 9
   says what a position type requires. Where would you add it, by analogy with Ch 6's
   skill standards and 9.3's valid responsibilities, and what query would it unlock?


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
