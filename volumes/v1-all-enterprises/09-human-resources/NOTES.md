# Vol 1, Chapter 9 — Human Resources

## The problem this pattern solves
Every HR system starts as the textbook EMP and DEPT pair: an employee row with a name, a
job title, a hire date, a department and a manager. It breaks as soon as time and
structure move. When someone is promoted, the old title is overwritten. When someone
leaves, the job disappears with them, even though the company still budgets for it and
wants to fill it. Two people sharing one job can't be recorded, and neither can one
person reporting to two bosses. A reorganization means rewriting every employee's
manager. And "employee" is a person typed into HR again, although Ch 2 already knows
them as a party. Ch 9 splits it. **Employment** is Ch 2's party relationship between a
person (employee role) and an internal organization. The **position** is a slot the
organization creates, funds through a budget item and describes by a **position type**
(title, responsibilities, classifications, union). **Position fulfillment** puts a person
in a slot for a while, and **position reporting structure** makes slots report to slots,
not people to people. The person moves; the slot and the org chart stay.

## Submodels (proposed 2026-10-20, from Figs 9.1–9.6)
1. **Positions** (Figs 9.3–9.4): which slots does the enterprise have, of which type,
   salaried or hourly, exempt or not, full-time or part-time, permanent or temporary,
   from when to when (planned and actual); which budget item funds each, and is it
   authorized; what each slot and each type is responsible for; how each type is
   classified, since when, for how many hours; which union represents it?

2. **Employment, fulfillment and reporting** (Figs 9.2, 9.5–9.6): who is employed by
   which internal organization, since when, in what state; which hiring company each
   slot is in and what state it's in; who has filled each slot, from when to when; which
   slot reports to which, which line is the main one, and how the chart looked on a
   given day?

Fig 9.1 is the naive model the chapter replaces: transcribed, not built.

## Figures

### Fig 9.1 — Standard emp dept model (not built)
**Transcription** (accepted: ☐; photo)

```
EMP
  # emp_id
  * emp_name
  * position
  * date_hired
  -> EMP   (many "reports to" 0..1, dashed both ends; emp "the manager of" many)
  -> DEPT  (many "within" 1; dept "for" many, dashed on the dept end)

DEPT
  # dept_id
  * description
```

**Discussion**
- **The textbook model, here to be taken apart.** Everything the chapter builds is a
  fix for one of its columns: `position` is a string on the person (so the job dies
  with the person and its history is overwritten); `date_hired` is one date (so a
  rehire loses the first stint); `reports to` joins people (so a vacancy breaks the
  chart, and a reorganization edits every row); `DEPT` is a second kind of organization
  that Ch 2's party model already covers.
- **Not built:** there is nothing in it Ch 2 and Figs 9.2–9.6 don't hold better. It is
  the "naive model" for this chapter's cards.

### Fig 9.2 — Employment
**Transcription** (accepted: ☐; photo)

```
PARTY RELATIONSHIP
  # from_date
  o thru_date
  o comment
  -> PARTY RELATIONSHIP STATUS TYPE  (many "defined by" 0..1; type "set the status for" many)
  -> PARTY RELATIONSHIP TYPE         (many "described by" 1; type "the description for" many)

  EMPLOYMENT (subtype, no attributes)
    -> PARTY ROLE > PERSON ROLE > EMPLOYEE
         (many "established to" 1, tilde; employee "employed within" many)
    -> PARTY ROLE > ORGANIZATION ROLE > INTERNAL ORGANIZATION
         (many "established from" 1, tilde; internal organization "employer of" many)

PARTY RELATIONSHIP TYPE
  # party_relationship_type_id
  * description

PARTY RELATIONSHIP STATUS TYPE (no attributes drawn)

PARTY ROLE
  # party_id
  # party_role_id
```

**To check against the book**
- Both lines to the two types look dashed all the way. Ch 2 built the type mandatory and
  the status optional (2.6a–2.7); kept (point 3).
- "ORGANIZTION ROLE" in the drawing: a misprint for ORGANIZATION ROLE.

**Discussion**
- **Employment is a relationship, not a person.** The employee is a role a person plays,
  and the employer is the internal organization. The relationship carries the dates, so
  a person who leaves and comes back has two employments, not an overwritten hire date.
- **Nothing new to build:** it is exactly Ch 2's Fig 2.6a row typed EMPLOYMENT (from the
  internal organization, to the employee), with 2.7's status. Ch 9 hangs pay, benefits
  and termination on it in its later figures.
- **The naive model** puts `date_hired` and `dept_id` on the person: one employer, one
  stint, nothing to attach a salary history or a termination reason to.

### Fig 9.3 — Position definition
**Transcription** (accepted: ☐; photo with Tables 9.1–9.2)

```
POSITION
  # position_id
  * estimated_from_date
  o estimated_thru_date
  * salary_flag
  * exempt_flag
  * fulltime_flag
  * temporary_flag
  o actual_from_date
  o actual_thru_date
  -> POSITION TYPE  (many "described by" 1; type "used to describe" many)
  -> BUDGET ITEM    (many "approved thru" 0..1; item "the approval for" many)

POSITION RESPONSIBILITY
  # from_date
  o thru_date
  o comment
  -> POSITION             (many "associated with" 1, tilde; position "assigned to" many)
  -> RESPONSIBILITY TYPE  (many "defined by" 1, tilde; type "used to define" many)

VALID RESPONSIBILITY
  # from_date
  o thru_date
  o comment
  -> POSITION TYPE        (many "associated with" 1, tilde; type "optionally defined using" many)
  -> RESPONSIBILITY TYPE  (many "defined by" 1, tilde; type "used to define" many)

RESPONSIBILITY TYPE
  # responsibility_type_id
  * description

POSITION TYPE
  # position_type_id
  * description
  * title
  o benefit_percent

BUDGET ITEM (Ch 8)
  # budget_item_seq_id
  * amount
  o purpose
  o justification
```

**Table 9.1, positions** (id · estimated from · estimated thru · salaried · exempt ·
full-time · temporary)
- 101 · Jan 1, 2001 · – · yes · no · yes · no
- 204 · Jun 1, 2001 · Aug 31, 2001 · yes · yes · yes · yes

**Table 9.2, position types** (book id · title · benefit % · what the job does, in our
words)
- 1100 · Business Analyst · 100 · recommends business policies, procedures and mechanisms
- 2200 · Accounting Clerk · 50 · enters the books, files the papers, does the
  administrative accounting work

**To check against the book**
- The "approved thru" line's ends can't be told from the photo. Read as optional on the
  position's side: the text says a position *can* be approved through a budget item
  (point 8).
- Table 9.1 gives no type for 101 and 204. Read as Table 9.2's two: 101 a business
  analyst, 204 a summer accounting clerk (point 7).

**Discussion**
- **A position is a slot, not a person.** It exists before anyone fills it (estimated
  dates: when the enterprise plans to have it) and may outlive its holders (actual
  dates: when it really opened and closed). The four flags describe the slot (salaried
  or hourly, exempt from overtime rules or not, full or part time, permanent or
  temporary), so they stay put when the person changes.
- **Funded through a budget item** (Ch 8): one item ("programmers, 2001") can fund
  several slots. A position tied to a budget is *authorized* once that budget's status
  reaches approved: authorization is derived, not stored.
- **Type and instance, twice.** POSITION TYPE is the job description (title, what it
  does, the share of benefits the enterprise pays); POSITION is one slot of that kind.
  The same split repeats for responsibilities: VALID RESPONSIBILITY says what a type of
  job *may* be given, POSITION RESPONSIBILITY what this slot *is* given, both dated so
  job descriptions can change over time.
- **The rule a line can't hold** (the text): a slot's responsibility should first be a
  valid responsibility of its type. A data check, not a key.
- **The naive model** keeps `title` and `responsibilities` as text on the employee: the
  job description is retyped per person and lost when they leave.

### Fig 9.4 — Position type definition
**Transcription** (accepted: ☐; photo with Table 9.3)

```
POSITION TYPE CLASS
  # from_date
  o thru_date
  o standard_hours_per_week
  -> POSITION TYPE                 (many "for" 1, tilde; type "classified via" many)
  -> POSITION CLASSIFICATION TYPE  (many "defined by" 1, tilde; class type "used to define" many)

POSITION CLASSIFICATION TYPE
  # position_class_type_id
  * description

POSITION TYPE
  # position_type_id
  * description
  * title
  o benefit_percent
  -> ORGANIZATION ROLE > UNION  (many "unionized by" 0..1, dashed; union "the union for" many)
```

**Table 9.3, position type classifications** (type · class · from · thru)
- Programmer · Computer · Jan 1, 1995 · –
- Programmer · Technical · Jan 1, 1995 · –
- System Administrator · Computer · Jan 1, 1995 · –
- System Administrator · Admin Support · Apr 1, 1997 · –
- Business Analyst · Computer · Jan 1, 1995 · Dec 31, 1999
- Business Analyst · MIS · Jan 1, 2000 · –

**To check against the book**
- Table 9.3 gives no standard hours per week; seeded null (point 11).
- "System Administrator" here, "Systems Administrator" in Table 9.4: read as one type
  (point 13).

**Discussion**
- **Classifications are many and dated.** A position type can sit in several groupings
  at once (Programmer is both Computer and Technical), and a grouping can change
  (Business Analyst moved from Computer to MIS in 2000) without touching the type. It's
  the classification pattern of Ch 2's PARTY CLASSIFICATION and Ch 3's PRODUCT CATEGORY
  CLASSIFICATION, applied to job types.
- **Standard hours sit on the classification**, so the same type can have a different
  standard week depending on how it's classed (point 11).
- **The union is an organization role** (Ch 2): a party playing UNION. It represents a
  type of job, not a person, so every slot of that type is covered.
- **The naive model** has a `job_category` column on the type: one grouping, no history.

### Fig 9.5 — Position fulfillment
**Transcription** (accepted: ☐; photo with Table 9.5)

```
POSITION FULFILLMENT
  # from_date
  o thru_date
  o comment
  -> POSITION  (many "the fulfillment of" 1, tilde; position "filled by" many)
  -> PERSON    (many "accepted by" 1, tilde; person "the acceptor of" many)

POSITION
  (9.3's attributes)
  -> POSITION TYPE         (many "described by" 1; type "used to describe" many)
  -> POSITION STATUS TYPE  (many "in the state of" 1; type "the status of" many)
  -> ORGANIZATION          (many "within" 1; organization "the hiring company for" many)

POSITION TYPE (# id, * description); POSITION STATUS TYPE (no attributes drawn)
PARTY (# party id, o credit rating) > ORGANIZATION (* name, o federal tax id num),
  PERSON (* current last name, * current first name)
```

**Table 9.5, position fulfillments** (person · position · from · thru)
- Mike Johnson · Mail Clerk · May 31, 1980 · Jun 1, 1980
- Mike Johnson · Mail Supervisor · Jun 1, 1980 · Dec 31, 1983
- Mike Johnson · Office Manager · Jan 1, 1984 · May 31, 1990
- Mike Johnson · Regional Manager · Jun 1, 1990 · May 31, 1996
- Mike Johnson · CEO · Jun 1, 1996 · –
- Sue Jones · Programmer · Mar 1, 1995 · Feb 27, 1997
- Sue Jones · Business Analyst · Feb 28, 1997 · Mar 14, 1999
- Sue Jones · MIS Manager · Mar 15, 1999 · Nov 1, 2000
- Sue Jones · CIO · Nov 2, 2000 · –

**To check against the book**
- The "in the state of" line looks solid on the position's end: read as mandatory, one
  current status per position, no history (point 15).
- Mike Johnson's mail clerk stint ends Jun 1, 1980, the day the supervisor job starts;
  every other row hands over on the next day. Read as a handover on Jun 1 (point 17).
- No status types named. Ours: planned, active, inactive (point 15).

**Discussion**
- **Fulfillment is the person-to-slot link, dated.** Mike Johnson's 16 years read as
  five rows against five slots, and each slot keeps its own history of holders. The
  title on the business card comes from the slot's type, never from the person.
- **A person, not an employee role:** whoever accepts the slot (point 18). Most are
  employees, but the model doesn't forbid a contractor.
- **Several people can fill one slot at once** (the text: a job share, two half-time
  people in one full-time position). FTE and head count are counted on positions, not
  people, so they stay right however the slot is shared.
- **The hiring company** is the organization the slot belongs to; with the status, it
  tells which slots are open, planned or closed.
- **The naive model** writes the title on EMP and overwrites it at each promotion: Table
  9.5 can't be told, and an empty slot doesn't exist.

### Fig 9.6 — Position reporting relationships
**Transcription** (accepted: ☐; photo with Table 9.4)

```
POSITION REPORTING STRUCTURE
  # from_date
  o thru_date
  o comment
  * primary_flag
  -> POSITION  (many "the reports to structure" for 1, tilde; position "reporting to" many)
  -> POSITION  (many "managed by" 1, tilde; position "the manager of" many)

POSITION (9.3's attributes)
```

**Table 9.4, position reporting** (manager · reporting position · from · thru · primary)
- Director of Business Information Systems · Business Analyst · Jan 1, 2000 ·
  Dec 30, 2000 · yes
- Director of Business Information Systems · Systems Administrator · Jan 1, 2000 ·
  Dec 31, 2000 · yes
- Director of Business Information Systems · Programmer/Analyst · Jan 1, 2000 ·
  Dec 31, 2000 · yes
- IS Development Manager · Business Analyst · Jan 1, 2001 · – · yes
- IS Development Manager · Systems Administrator · Jan 1, 2001 · – · no
- IS Development Manager · Programmer/Analyst · Jan 1, 2001 · – · yes
- Maintenance Manager · Systems Administrator · Jan 1, 2001 · – · yes
- Maintenance Manager · Programmer/Analyst · Jan 1, 2001 · – · no

**To check against the book**
- The table heads its first column "reporting to position" and its second "the manager
  of position", yet the first holds the managers. Read by the text, which has the
  programmer/analyst and systems administrator reporting to the two managers (point 20).
- The business analyst's line ends Dec 30, 2000, the other two Dec 31. Read as Dec 31
  (point 21).

**Discussion**
- **Slots report to slots.** The org chart stands even when a box is empty, and a
  reorganization (Jan 1, 2001: the director's three reports move to two new managers)
  closes old rows and opens new ones, without touching a single person.
- **Matrix reporting:** a slot can report to several managers at once; the primary flag
  says which line it ultimately reports through (the systems administrator mainly to
  maintenance, the programmer/analyst mainly to development).
- **Dated,** so the chart can be drawn as of any day, and a future thru date plans a
  change ahead.
- **The naive model** is 9.1's "reports to" between people: a vacancy cuts the chart in
  two, one boss only, no history.

### Points to discuss after the overview (Figs 9.1–9.6, so far)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing. The list moves under the chapter's last figure when it lands.

1. **9.1 not built:** the naive model the chapter argues against, transcribed only.
2. **9.2 adds no table:** Ch 2's party relationship already has the EMPLOYMENT type
   (from the internal organization, to the employee) and 2.7's status. Built as a view,
   `employment_relationship`, that names both parties. Ch 2's 2.5 `employment` table
   stays as Ch 2's comparison and is not used.
3. **9.2's type and status lines** look dashed at both ends; Ch 2's reading (type
   mandatory, status optional) kept.
4. **Mike Johnson's employer:** hired by ABC Corporation in 1980, but Ch 2's seed makes
   ABC Corporation an internal organization only from 1990. Kept; the employment is ours,
   the book names no employer.
5. **Sue Jones read as Ch 8's Susan Jones** (party 68), who reviewed the marketing
   budget in 2000 as MIS manager. Ours.
6. **A position has no name:** the tables name each slot by its type's title. Every
   slot in Tables 9.4–9.5 is seeded with a type of that title.
7. **Table 9.1's types:** 101 a business analyst, 204 a summer accounting clerk (Table
   9.2's two types). Ours.
8. **"Approved thru" optional:** the text says a position *can* be approved through a
   budget item. Positions with no budget item are simply not tied to one.
9. **Position type ids:** the book's 1100 and 2200 become mnemonic text ids
   (BUSINESS_ANALYST, ACCOUNTING_CLERK), as Ch 6 built POSITION TYPE.
10. **Title mandatory:** Ch 6's three types (PROGRAMMER, SENIOR_PROGRAMMER,
    PROJECT_MANAGER) take their description as title when the column arrives.
11. **Standard hours per week on the classification,** not the type. Table 9.3 gives
    none; seeded null except one of ours (Business Analyst under MIS, 40).
12. **Thru dates stored exclusive:** Business Analyst's Computer class ends Dec 31,
    1999, stored Jan 1, 2000.
13. **"System Administrator" (9.3) and "Systems Administrator" (9.4)** are one type,
    SYSTEMS_ADMINISTRATOR.
14. **UNION** becomes a role type under ORGANIZATION_ROLE and the position type points
    at the union's party role (a plain FK, with a check that it is a union role). The
    union and the types it covers are ours (mail clerks, accounting clerks).
15. **POSITION STATUS TYPE:** status types under a POSITION_STATUS group, as Ch 8 did
    for budgets, but a current value on the position (no history drawn), mandatory.
    Statuses ours: planned, active, inactive.
16. **The hiring company is an ORGANIZATION,** not an internal organization role. Built
    as a plain FK to `organization`; a check flags a hiring company that is not an
    internal organization.
17. **Mike Johnson's mail clerk days:** May 31 to Jun 1, 1980 as printed, with the
    supervisor job from Jun 1. Read as a handover on Jun 1: stored thru Jun 1 (exclusive),
    so the clerk stint is one day.
18. **Fulfillment by a person, not an employee role:** a review query lists fulfillments
    with no employment by the hiring company at the time, without calling them errors.
19. **Job shares allowed:** two people may fill one slot at once (the text); no check
    against overlapping fulfillments of a position.
20. **Table 9.4's headers read reversed:** the first column holds the managers. Built by
    the text.
21. **The business analyst's Dec 30, 2000:** read as Dec 31, like the other two rows
    (stored Jan 1, 2001).
22. **Table 9.4's slots:** the Director of Business Information Systems slot closes at
    the end of 2000, and the two manager slots open on Jan 1, 2001. Ours, from the text.
23. **One primary line per slot at a time:** implied by the text ("to which position
    each of these ultimately reports"). A check, ours.
24. **Table 9.5's slots:** one slot per row (ids ours), all in ABC Corporation. Sue Jones's
    business analyst slot is not Table 9.1's 101 (that one opens in 2001).

## Design decisions (book → SQL)

### Fig 9.2
- **No table:** the view **`employment_relationship`** over Ch 2's `party_relationship`
  rows typed EMPLOYMENT, with the employer's and the employee's party ids beside their
  roles (point 2). Ch 2's 2.5 consistency check already lists later chapters'
  employments (William Jones since Ch 7); Ch 9's join it, as expected.
- **Check:** one person employed twice by one employer over overlapping dates.
  **Query:** who is employed by whom, since when, in what state.
- **Seed:** Mike Johnson (party 70) and Sue Jones (Ch 8's 68) as ABC Corporation's
  employees (points 4–5). Bad row: Mike Johnson "hired" again in 1996 as CEO while his
  1980 employment is still open.

### Fig 9.3
- **`position_type`** (Ch 6) gains `title`, not null after Ch 6's rows take their
  description (point 10), and `benefit_percent` (0–100). Text ids kept (point 9).
- **`position`** with a surrogate key, the type not null, the budget item nullable
  (point 8), the four flags as booleans not null, estimated and actual dates with
  thru after from. **`responsibility_type`** a lookup; **`valid_responsibility`**
  (type × responsibility) and **`position_responsibility`** (slot × responsibility),
  surrogate keys, the book's triple unique, dated.
- **Checks:** a slot's responsibility not valid for its type on the day it starts (the
  book's rule); a slot opened before the budget that funds it was approved.
  **Queries:** Tables 9.1–9.2; is each funded slot authorized (its budget's latest
  status); slot 101's job description on a day.
- **Seed:** Table 9.2's two types; Table 9.1's two slots (types ours, point 7); the 2001
  *Information systems staffing* budget 41001 (ours) with three item types mapped to
  Salaries expense, approved Nov 15, 2000; six responsibility types and their valid and
  assigned rows (ours). Bad rows: slot 102 opened Nov 1, 2000, before its budget's
  approval; slot 101 given the clerk's bookkeeping.

### Fig 9.4
- **`position_classification_type`** a plain lookup; **`position_type_class`** (type ×
  class, dated) with a surrogate key, the book's triple unique, standard hours per week
  optional and between 0 and 168 (point 11).
- **`position_type.union_party_role_id`**, a nullable plain FK to Ch 2's `party_role`;
  UNION a role type under ORGANIZATION_ROLE (point 14).
- **Checks:** a type classed the same way twice over overlapping dates; a type
  "unionized by" a role that isn't a union. **Queries:** Table 9.3; which types were
  Computer on two days (Business Analyst leaves in 2000); which union covers which type,
  with its slot count.
- **Seed:** SYSTEMS_ADMINISTRATOR (point 13); four classification types; Table 9.3 with
  the analyst's 40 hours (ours); Office Workers Union Local 12 (party 71) for accounting
  clerks. Bad rows: Programmer classed Computer again from 1998; systems administrators
  "unionized by" ABC Corporation's internal organization role.

## When NOT to use this
- **A small company with one office:** a `job_title` and `manager_id` on the person, and
  a hire date, is honest when nobody budgets slots or keeps a job-description history.
  Positions earn their keep once vacancies, reorganizations or headcount planning matter.
- **HR is often bought:** most enterprises run payroll and HR in a package and only need
  the party, the employment and the position ids in their own models.

## Open questions
