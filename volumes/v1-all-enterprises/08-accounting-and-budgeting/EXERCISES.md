# Vol 1, Chapter 8 — Exercises

Do these after the chapter's last figure is implemented. Each exercise is small. Answers and
the gaps log go in `EXERCISES-log.md` (or the chapter's SQL files) and get reviewed; no
answers are provided up front. Process: `docs/practice.md`.

**Flow, per submodel (about 3 hours each):** exam (about 6 questions, one at a time, climbing
Bloom's levels) → reinforce each gap with a fresh question → practice scenario → doc entry.
The sections below are a menu of formats, not a list to complete. A submodel is done when
every row scores 3+ and its scenario holds up.

**Submodels:**
1. Chart of accounts (Figs 8.1, 8.4)
2. Accounting transactions (Figs 8.2–8.3b, 8.5)
3. Budgets (Figs 8.6–8.7b)

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

### Submodel 1: chart of accounts
1. *(8.1)* ABC Corporation splits "marketing expense" into advertising and trade shows in
   1997, but ABC Subsidiary keeps it. Why does the split live on ORGANIZATION GL ACCOUNT and
   not on GENERAL LEDGER ACCOUNT? What would go wrong if each organization had its own chart?
2. *(8.1)* Why does an ACCOUNTING PERIOD belong to an internal organization rather than to
   the enterprise? Give a case where two organizations' "2001" can't be the same row.
3. *(8.1)* The type (asset, liability, equity, revenue, expense) sits on the chart's
   account, not on the organization's. When could that be wrong, and what would you do?
4. *(8.4)* Why break receivables down by subsidiary accounts that reference the customer,
   instead of opening "120-ACME" in the chart? What does the chart look like after 5,000
   customers either way?
5. *(8.4)* ABC Subsidiary's receivables control account has its own postings *and*
   subsidiaries (the 8.4 balance query). Should a control account ever be posted to
   directly? What would you change to stop it?

### Submodel 2: accounting transactions
1. *(8.2)* A depreciation has no "to" party, an invoice has both. Why does the book split
   INTERNAL and EXTERNAL instead of making "to" optional on every transaction?
2. *(8.2)* Why point the transaction at its invoice or payment, when the invoice already
   holds the amounts? What question can't you answer without that line?
3. *(8.3a)* 39776 records $900 against receivables, but only $882 reached the bank. Model
   it with one amount on the transaction instead of details: what is lost?
4. *(8.3a)* How does "associated with" let you list open invoices without an "amount
   paid" column? What breaks if a customer pays on account, as ACME did in 45894?
5. *(8.3b)* Stored balances are derived data. When is storing them right, and what must
   be true of a period before you trust its stored balance over its postings?

### Submodel 3: budgets
1. *(8.6)* Whose budget it is lives in BUDGET ROLE, not in a column on BUDGET. What does
   that buy, and why does the text want budgets at the lowest organization level?
2. *(8.6)* A BUDGET ITEM has a purpose and a justification; an ORDER ITEM has neither.
   What is a budget for, that it needs them? Write one pair for "a new laptop".
3. *(8.6)* Budget periods are STANDARD TIME PERIODs, not 8.1's ACCOUNTING PERIODs. When
   would you want the budget tied to an organization's fiscal period instead?
4. *(8.7)* 8.7a copies the whole budget per revision; 8.7b records impacts. Which
   questions does each answer cheaply? Pick one for a 10-line team budget, and say why.
5. *(8.7b)* Revision 1.1 *adds* item 4. Where does the $5,000 live, and why must the
   "budget after each revision" query not count it twice?

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
