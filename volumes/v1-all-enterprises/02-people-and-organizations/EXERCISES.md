# Vol 1, Chapter 2 — Exercises

The chapter is still being read and built. Section 0 collects every question and idea raised
along the way. The remaining sections are completed when the chapter's last figure is done.
Answers go in this file (or the chapter's SQL files) and get reviewed; no answers are provided
up front.

## 0. To ponder (collected while reading)

Answer in a sentence or three under each item. Tags show which figure raised it.

### Why the model is shaped this way
1. **[before 2.1]** Why make PARTY a supertype at all, instead of separate `customer`,
   `supplier` and `employee` tables? What goes wrong with the separate tables?
2. **[2.2b]** Height and weight moved from columns into PHYSICAL CHARACTERISTIC rows (type +
   value). What can you do with rows that you can't with columns? What does the database stop
   checking for you?
3. **[2.1 vs 2.3]** In 2.1 an organization has exactly *one* type (a single column). In 2.3 a
   party has *many* dated classifications. Why did Silverston keep Legal/Informal as a subtype,
   but make Industry and Size classifications? What's the rule for deciding which is which?
4. **[2.2b]** A passport belongs to a CITIZENSHIP, not directly to a PERSON. What does that
   say about the real world, and what would be lost by linking the passport straight to the person?
5. **[2.2b]** Some attributes moved into dated entities (name, marital status) and others stayed
   on PERSON (birth date, SSN, mother's maiden name). What's the test for which is which?

### Challenge the book (and our implementation)
6. **[2.2b]** The book draws PHYSICAL CHARACTERISTIC's `from_date` as `*` (not part of the
   identifier), which allows one value per person and type, ever. Is that an erratum, or can you
   find a reading where it's intentional? We deviated; do you agree?
7. **[2.3]** Fig 2.3 makes first and last name mandatory. Kiri has only one name. Should the
   rule exist? Who pays when a model's rule doesn't match reality: the database, the app, or
   the user?
8. **[2.2b]** Chloe has no marital status rows. How is "unknown" different from "single", and
   why does the flat 2.2a model hide that difference?
9. **[2.2b]** PASSPORT carries a three-column foreign key to CITIZENSHIP (the natural key). The
   alternative is a surrogate `citizenship_id`. What does each choice give you, and which would
   you pick in a real app?

### Where rules should live
10. **[2.1, 2.3]** These rules are *not* enforced by the schema: an informal organization can
    have a tax ID; a party can be SMALL and MEDIUM at once; two current last names can coexist;
    a party can exist with no person/organization row. For each one: database constraint,
    application code, or a periodic data-quality query? Why?
11. **[2.3]** We added `party_kind` with composite foreign keys so the database rejects a person
    being an organization. Was that worth an extra column on every subtype table? When would you
    skip it?

### When not to use it
12. **[2.2b]** Attributes-as-rows (EAV) vs. plain columns vs. a Postgres `jsonb` column: when
    would you choose each one?
13. **[general]** Universal models are generic up front. When is a plain `customers` table the
    *right* design, and what signal tells you it's time to refactor to PARTY?

### Roles (Fig 2.4)
14. **[2.4]** Roles and classifications both link a party to a type with dates. What's the
    conceptual difference? Could "customer" be a classification instead? Could "industry" be a role?
15. **[2.4]** PARTY ROLE has its own `party_role_id`, and `from_date` isn't part of its
    identifier. PARTY CLASSIFICATION is identified by (party, type, from_date). Why would a role
    need an identity of its own? What might reference it?
16. **[2.4]** A company is both your customer and your supplier. How does a naive
    `customer` + `supplier` table design handle that, and what breaks when its address changes?
17. **[2.4]** "Ana is an EMPLOYEE." Employee *of whom*? What can't a role alone express, and
    where should that information live?
18. **[2.4]** Why is DEPARTMENT a *role* an organization plays, rather than an organization
    *type* like CORPORATION in 2.1?
19. **[2.4]** Some roles are person-only, some organization-only, some either. Should the
    database enforce that (like we did for classifications), and how would you enforce "either"?

## 1. Redraw from memory
*(completed at chapter end)*

## 2. Explain why
*(completed at chapter end; section 0 feeds into it)*

## 3. Spot the flaw
*(completed at chapter end)*

## 4. Extend it
*(completed at chapter end)*

## 5. Write the queries
Add each one to `queries.sql` under a `-- name:` header.
1. **[2.2b]** Who changed their last name in the last 10 years? Show the old and new name.
2. *(more at chapter end)*

## 6. Break the model
Try to insert data that *should* be invalid. For each attempt, note whether it got through,
and if it did, whether it deserves a constraint, a data-quality query, or just a note.
1. **[2.2b]** Give someone two current (open) last names.
2. **[2.3]** Classify Contoso as SIZE_SMALL and SIZE_LARGE for the same period.
3. *(more at chapter end)*

## 7. Trade-offs
*(completed at chapter end; see section 0, items 9, 11 and 12)*

## 8. In your own words
Rewrite these NOTES.md sections yourself, 3–5 bullets each:
- The problem this pattern solves
- When NOT to use this

## 9. Capstone
*(completed at chapter end)*

---

## Gaps found
Filled in during review: misunderstandings to revisit in warm-ups and later exercises.
