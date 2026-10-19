# Vol 1, Chapter 6 — Work Effort

## The problem this pattern solves
Most enterprises don't only buy and sell: they also do work, such as making goods, repairing
machines, running projects and providing services. The naive model is a `job` or `task` table
with a "requested by" column, a "for order" column and a status. It breaks once you separate
the **need** from the **work**. One need gets filled by two production runs, and one run
fills two needs. A sales order line starts work directly, with no planning step. The same
kind of work is sometimes a program, sometimes a project and sometimes a single activity.
Ch 6 splits the two. A WORK REQUIREMENT is a need for work: what to produce, which machine to
fix, which deliverable to write. Parties are attached to it in dated roles. A WORK EFFORT is
the work actually planned and done. Associative entities join the two, and join work to
order lines. The recurring moves: need versus fulfilment (Ch 4's requirement and order),
many-to-many fulfilment links, and two independent subtype sets, each held as a type lookup.

## Submodels (proposed 2026-10-19, Figs 6.1–6.3b shared so far)
1. **Work requirements and their roles** (Figs 6.1–6.2): what work is needed, of which type
   (a production run, maintenance, an internal project), to produce which product or
   deliverable, or to work on which machine; who created it, for whom, who is responsible for
   it and when, and who authorised it?

2. **Work effort generation** (Fig 6.3a; 6.3b the alternate): what work is planned and done,
   at what level (program down to activity) and for what purpose (production run,
   maintenance, research), where it happens, which needs it fulfils and which order lines;
   for a production run, how many to make and how many came out good or rejected?

## Figures

### Fig 6.1 — Work requirement
**Transcription** (accepted: ☐; photo with Tables 6.1–6.2; open points under "To check
against the book")

```
REQUIREMENT                       (Ch 4's, redrawn)
  # requirement_id
  * description
  o requirement_creation_date
  o required_by_date
  o estimated_budget
  o quantity
  o reason
  -> REQUIREMENT               (many "part of" 1; "composed of" many: recursive)
  -> REQUIREMENT TYPE          (many "described by" 1 type; type "the description for" many)
  subtypes, set 1: CUSTOMER REQUIREMENT, INTERNAL REQUIREMENT
  subtypes, set 2: PRODUCT REQUIREMENT, WORK REQUIREMENT

WORK REQUIREMENT                  (all three lines dashed: optional)
  -> DELIVERABLE               (many "for work to produce" 1; deliverable "produced by" many)
  -> FIXED ASSET               (many "related to" 1; asset "worked on via" many)
  -> PRODUCT                   (many "produce" 1; product "produced by" many)

REQUIREMENT TYPE
  # requirement_type_id
  * description

DELIVERABLE
  # deliverable_id
  * name
  o description
  -> DELIVERABLE TYPE          (many "defined by" 1; type "used to define" many)

DELIVERABLE TYPE
  # deliverable_type_id
  * description

FIXED ASSET
  # fixed_asset_id
  * name
  * date_acquired
  o date_last_serviced
  o date_next_service
  o production_capacity

PRODUCT (Ch 3's attributes: name, introduction, sales and support discontinuation dates,
comment)
```

**Table 6.1, work requirement data** (id · type · created · required by · description)
- 50985 · production run · Jul 5, 2000 · Aug 5, 2000 · anticipated demand of 2,000 custom
  engraved black pens with gold trim
- 60102 · internal project · Oct 15, 2000 · Dec 15, 2000 · develop the sales and marketing
  plan for 2002
- 70485 · maintenance · Jun 16, 2000 · Jun 18, 2000 · fix the engraving machine

**Table 6.2, work requirement types** (id · type · description · product · quantity ·
deliverable · fixed asset)
- 50985 · production run · 2,000 pens as above · the engraved black pen with gold trim ·
  2,000
- 51245 · production run · 1,500 of the same pen · the same product · 1,500
- 51285 · production run · 3,000 of the same pen · the same product · 3,000
- 60102 · internal project · sales and marketing plan *for 2001* · · · deliverable "2001
  Sales/Marketing Plan"
- 70485 · maintenance · fix the engraving machine · · · · fixed asset 5025

**To check against the book**
- "Described by" REQUIREMENT TYPE is solid at the requirement end (each requirement has a
  type), but Ch 4's requirements have none (point 1).
- REQUIREMENT TYPE sits beside the two drawn subtype sets: is it a third set, or the same
  information again (point 2)?
- Ch 4's "needed at" FACILITY line isn't drawn here. Read as an abbreviation.
- Table 6.1 plans for 2002 and Table 6.2 for 2001; the deliverable says 2001 (point 3).

**Discussion**
- **A need for work, beside a need for goods.** Ch 4's REQUIREMENT already split PRODUCT
  from WORK. Ch 6 fills in WORK REQUIREMENT. What it can name depends on its type. A
  production run names the product and how many. A repair or maintenance job names the
  machine (a FIXED ASSET). An internal project names what it hands over (a DELIVERABLE: a
  report, a plan, a new business method). All three lines are optional because each type
  uses a different one. The type says which is expected, and a check enforces it.
- **The type is a lookup, not more subtypes.** Production run, internal project and
  maintenance have no attributes of their own, so they're REQUIREMENT TYPE rows (as Ch 5's
  shipment and document types were).
- **FIXED ASSET gets its own attributes here**: when it was acquired, when it was last
  serviced and is next due, and its capacity. Ch 5 created it with only a name, for
  vehicles. Ch 8 will extend it again.
- **The naive model** puts `product_id`, `machine_id` and `report_name` columns on a
  `job` table and leaves most of them null. That's roughly what the subtype does. The
  difference is that here the need is kept apart from the job that fills it (Fig 6.3a), so
  one need can be filled by several jobs.

### Fig 6.2 — Work requirement roles
**Transcription** (accepted: ☐; photo with Table 6.3)

```
REQUIREMENT ROLE
  # from_date                  (with the three lines below: the identifier)
  o thru_date
  o comment
  -> REQUIREMENT               (many "involved in" 1 requirement; requirement "involving" many)
  -> PARTY                     (many "established for" 1 party; party "acting in" many)
  -> REQUIREMENT ROLE TYPE     (many "described by" 1 type; type "the description for" many)

REQUIREMENT (6.1's attributes; recursive "part of"; the same two subtype sets)

PARTY
  # party_id

REQUIREMENT ROLE TYPE           (no attributes drawn)
```

**Table 6.3, party work requirement role data** (requirement · party · role type · from ·
thru)
- 50985 · ABC Manufacturing, Inc. · created for · Jul 5, 2000
- 50985 · John Smith · created by · Jul 5, 2000
- 50985 · John Smith · responsible for · Jul 5, 2000 · Dec 15, 2000
- 50985 · Sam Bossman · authorized by · Jul 8, 2000
- 50985 · Dick Jones · responsible for · *Dec 16, 2001* · Feb 20, 2001
- 50985 · John Smith · responsible for · *Feb 21, 2000*
- 60102 · Sam Bossman · created for · Jun 10, 2000
- 60102 · Dick Jones · responsible for · Jun 15, 2000 · Jan 1, 2001

**To check against the book**
- Dick Jones's from date (2001) falls after his thru date, and John Smith's return (2000)
  falls before Dick's start. Read as Dec 16, 2000 and Feb 21, 2001: responsibility passes
  John → Dick → John with no gap (point 4).
- 60102's roles start in June 2000, but Table 6.1 creates 60102 on Oct 15, 2000 (point 5).
- REQUIREMENT ROLE TYPE has no attributes drawn: a description, as everywhere else.

**Discussion**
- **Ch 4's requirement role again, with a comment.** Fig 4.9 already had REQUIREMENT ROLE.
  Ch 6 redraws it for work requirements, makes the from date part of the identifier and
  adds a comment.
- **Responsibility moves over time.** Table 6.3 hands 50985 from John to Dick and back. A
  `responsible_party_id` column would keep only the latest of the three, and the history is
  what answers "who was on it in January?". One responsible party at a time is our reading,
  checked by a query.
- **Created for versus created by.** Created for is the party whose need it is (ABC
  Manufacturing, or Sam Bossman for the plan); created by is whoever keyed it in. Authorized
  by is a third person again. One role row per job keeps all three apart.

### Fig 6.3a — Work effort generation
**Transcription** (accepted: ☐; photo with Tables 6.4–6.5)

```
WORK EFFORT
  # work_effort_id
  * name
  * description
  o scheduled_start_date
  o scheduled_completion_date
  o total_dollars_allowed
  o total_hours_allowed
  o estimated_hours
  o actual_start_datetime
  o actual_completion_datetime
  o actual_hours
  o special_terms
  subtypes, set 1 (no attributes): PROGRAM, PROJECT, PHASE, TASK, ACTIVITY
      -> WORK EFFORT TYPE      (set 1's box: many "described by" 1 type; type "used to
                                describe" many)
  subtypes, set 2: PRODUCTION RUN (o quantity_to_produce, o quantity_produced,
      o quantity_rejected), MAINTENANCE, WORK FLOW, RESEARCH
      -> WORK EFFORT PURPOSE TYPE  (set 2's box: many "for the purpose of" 1 type; type "the
                                purpose for" many)
  -> FACILITY                  (many "performed at" 1; facility "the location of" many;
                                dashed: optional)

WORK EFFORT TYPE
  # work_effort_type_id
  * description
  o standard_work_hours

WORK EFFORT PURPOSE TYPE
  # work_effort_purpose_type_id
  * description

WORK REQUIREMENT FULFILLMENT      (no attributes)
  -> WORK EFFORT               (many "fulfilled by" 1 effort; effort "a fulfillment of" many)
  -> WORK REQUIREMENT          (many "of" 1; requirement "fulfilled by" many)

WORK ORDER ITEM FULFILLMENT       (no attributes)
  -> WORK EFFORT               (many "fulfilled by" 1 effort; effort "a fulfillment of" many)
  -> WORK ORDER ITEM           (many "the fulfillment of" 1 item; item "fulfilled by" many)

ORDER REQUIREMENT COMMITMENT      (Ch 4's, redrawn)
  o quantity
  -> ORDER ITEM                (many "a usage of" 1; item "the fulfiller of" many)
  -> REQUIREMENT               (many "the commitment of" 1; requirement "committed by" many)

ORDER ITEM                        (Ch 4's attributes)
  subtypes, set 1 (new): WORK ORDER ITEM, PRODUCT ORDER ITEM
  subtypes, set 2: PURCHASE ORDER ITEM, SALES ORDER ITEM (o corresponding_po_id)

REQUIREMENT (6.1's, with both subtype sets); FACILITY (Ch 2's)
```

**Table 6.4, work efforts from work requirements** (effort · name · description ·
scheduled start · the work requirements it fills)
- 28045 · production run · a run of 3,500 *pencils* · Jun 1, 2000 · 50985 (2,000 pens) and
  51245 (1,500 pens)
- 51285 · production run · a run of 1,500 pencils · Dec 5, 2000 · 51285 (3,000 pens)
- 51298 · production run · a run of 1,500 pencils · Dec 6, 2000 · *blank*
- 32898 · fix engraving machine · repair machine #12, which may not power up · Dec 12, 2000 ·
  "repair of engraving machine"
- 39409 · sales and marketing plan development · the 2002 plan, with sales projections,
  channel strategy and competitive analysis · Dec 15, 2000 · 60102

**Table 6.5, work efforts from order items** (effort · name · description · scheduled start
· order item · requirement)
- 29534 · production run #1 of pens · 1,500 customised engraved pens with gold lettering ·
  Feb 23, 2001 · the sales order item for 2,500 such pens · "need for customised pens"
- 29874 · production run #2 of pens · 1,000 of the same · Mar 23, 2001 · the same item ·
  the same need

**To check against the book**
- Each set of subtypes has its own type line, drawn from the set's box: WORK EFFORT TYPE
  for set 1, WORK EFFORT PURPOSE TYPE for set 2. Whether the purpose is mandatory can't be
  read from the photo (point 6).
- The fulfilment lines run to the WORK REQUIREMENT and WORK ORDER ITEM subtypes, not to
  their supertypes.
- Table 6.4 says "pencils" while the requirements are for pens; the quantities match
  (2,000 + 1,500 = 3,500) (point 7).
- 51298's requirement cell is blank. Read as "same as above": 51285 and 51298, 1,500 each,
  fill 51285's 3,000 together (point 8).
- 32898 is scheduled for Dec 12, 2000, six months after 70485's required-by date of Jun 18,
  2000 (point 9).
- No type is given for any effort in Table 6.4 or 6.5 (point 10).

**Discussion**
- **Need and fulfilment again.** Ch 4 kept the need (REQUIREMENT) apart from the order
  that fills it. Ch 6 does the same for work. One need can take several runs (51285 and
  51298), and one run can fill several needs (28045 makes 50985's and 51245's pens in one
  go). So WORK REQUIREMENT FULFILLMENT is many-to-many with nothing on it. Unlike ORDER
  REQUIREMENT COMMITMENT, it carries no quantity. A production run's quantities are on the
  run itself.
- **Work can come straight from an order.** A customer orders 2,500 customised pens.
  WORK ORDER ITEM FULFILLMENT ties the two runs (1,500 + 1,000) to that sales line, with no
  planning step in between. Fig 6.3a also keeps ORDER REQUIREMENT COMMITMENT, so the same
  line can reach its work through a requirement too. Table 6.5 shows both: the order item
  and the need. Fig 6.3b drops the direct path (point 11).
- **Two subtype sets, two questions.** The level of the work (program, project, phase,
  task, activity) is one question. Its purpose (a production run, maintenance, workflow,
  research) is another. They're independent: a maintenance job can be a project or a single
  task. Each set becomes a type lookup. Only PRODUCTION RUN has attributes, so it's the
  only one with a subtype table.
- **Where the work happens** is optional. With no facility, the work is assumed to happen
  where its parent effort does (the breakdown comes later in the chapter) or the place
  doesn't matter. Only work done away from the main site needs one.
- **PRODUCTION RUN names no product.** What to make reaches it through the requirement it
  fills (6.1's product line) or the order line (its product). A run started from a request
  with neither has nothing to say what it makes (ponder).
- **The naive model** gives the job an `order_item_id` and a `requirement_id` column: one
  of each. Table 6.4's 28045 already needs two requirements, and Table 6.5's order line
  needs two runs.

### Fig 6.3b — Work effort generation, alternate model
**Transcription** (accepted: ☐; not built, see STATUS)

```
WORK EFFORT                       (6.3a's attributes and both subtype sets)
  -> WORK EFFORT TYPE          (set 1: many "described by" 1; type "used to describe" many)
  -> WORK EFFORT PURPOSE TYPE  (set 2: many "categorized by" 1; type "used to categorize" many)
  -> FACILITY                  (many "performed at" 1; facility "the location of" many)

WORK REQUIREMENT FULFILLMENT      (no attributes)
  -> WORK EFFORT               (many "fulfilled by" 1 effort; effort "a fulfillment of" many)
  -> WORK REQUIREMENT          (many "the fulfillment of" 1; requirement "fulfilled by" many)

REQUIREMENT (6.1's, both subtype sets), WORK EFFORT TYPE (with standard_work_hours) and
WORK EFFORT PURPOSE TYPE as in 6.3a.
```

**What it changes**: ORDER ITEM, WORK ORDER ITEM FULFILLMENT and ORDER REQUIREMENT COMMITMENT
are gone. Work is generated only from work requirements, so an order line that needs work
first becomes a requirement (Ch 4's commitment, out of this picture), and the requirement
generates the work. One path instead of two, at the cost of a requirement for every sold job.
The purpose line is renamed ("categorized by"), with no change in meaning.

**Not built**: 6.3a is built because it holds both paths. Which one the chapter's overall
figure keeps decides whether the direct path stays (point 11).

### Points to discuss after the overview (Figs 6.1–6.3b)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing.

1. **6.1, the type is drawn mandatory:** each requirement is "described by" a type, but Ch
   4's requirements have none. Built nullable. Ch 4's three work requirements get a type in
   Ch 6's seed, and a check catches work requirements with none. Product requirements stay
   untyped until the overview says what their types would be.
2. **6.1, REQUIREMENT TYPE beside the subtypes:** built as a hierarchy with
   PRODUCT_REQUIREMENT and WORK_REQUIREMENT as grouping rows, so the type also implies Ch
   4's `requirement_kind`. A check makes the two agree. Alternative: drop `requirement_kind`
   and keep only the type (one fact, one place).
3. **Tables 6.1–6.2, 2001 or 2002:** 60102 plans for 2002 in Tables 6.1 and 6.4, for 2001
   in Table 6.2, and its deliverable is the "2001 Sales/Marketing Plan". Seeded as printed:
   the description says 2002, the deliverable 2001.
4. **Table 6.3, Dick Jones's dates:** a from of Dec 16, 2001 with a thru of Feb 20, 2001,
   then John Smith from Feb 21, 2000. Read as typos for Dec 16, 2000 and Feb 21, 2001, a
   clean hand-over.
5. **Table 6.3, roles before creation:** 60102's roles start Jun 10 and 15, 2000, four
   months before Table 6.1 creates it. Seeded as printed; a review query shows them.
6. **6.3a, purpose optional:** built nullable, because the efforts from Chs 2 and 4 and the
   marketing plan (39409) fit none of the four purposes. If the line is mandatory, the list
   needs a catch-all row.
7. **Table 6.4, pencils:** the runs say "pencils", while the requirements they fill are for
   engraved black pens, and the quantities match. Seeded as printed; read as a slip.
8. **Table 6.4, 51298's blank:** read as "same as the row above", like 28045's second
   requirement row. 51285 and 51298 fill 51285 together (1,500 + 1,500 = 3,000). Note the
   effort 51285 shares its number with the requirement it fills.
9. **Table 6.4, 32898's date:** the repair is scheduled half a year after the need was due.
   Seeded as printed; a review query shows late efforts. And Table 6.1 calls 70485
   maintenance while Table 6.4 and the effort call it a repair.
10. **Tables 6.4–6.5, no work effort type:** Ch 2 made the type mandatory. Production runs
    typed PROJECT, the repair a TASK, the plan a PROJECT. The overview may give a better
    level for a run.
11. **6.3a or 6.3b:** 6.3a lets an order line reach its work directly (WORK ORDER ITEM
    FULFILLMENT) or through a requirement (ORDER REQUIREMENT COMMITMENT, then WORK
    REQUIREMENT FULFILLMENT). 6.3b keeps only the second. Built: 6.3a. The chapter's overall
    figure decides.
12. **6.3a, WORK ORDER ITEM as a subtype set:** ORDER ITEM gets a second set (WORK or
    PRODUCT), built as an `order_item_kind` column defaulting to PRODUCT, so Ch 4's lines
    stay as they were. A sold job like Table 6.5's is a SALES ORDER ITEM and a WORK ORDER
    ITEM at once.
13. **6.1, one fixed asset per requirement:** Table 4.11's "Repair 14 PCs" (24905) and
    "Repair 15 PCs" (34988) can't name 14 machines. Typed REPAIR and left with no asset:
    the check lists them beside our own bad row. Splitting them into one child requirement
    per PC is the model's answer.
14. **Table 6.3, the role types:** created for, created by, responsible for, authorized by
    are added beside Ch 4's OWNER, REQUESTER and APPROVER, which overlap (APPROVER with
    authorized by, OWNER with responsible for). Merge at the overview?

## Design decisions (book → SQL)

### Fig 6.1
- **`requirement_type`: a text key and a parent** (points 1–2): PRODUCT_REQUIREMENT and
  WORK_REQUIREMENT are grouping rows; under WORK, PRODUCTION_RUN, INTERNAL_PROJECT,
  MAINTENANCE and REPAIR (the text names repair beside maintenance), and our OTHER_WORK for
  Ch 4's office cleaning. `requirement` gains a
  nullable `requirement_type_id`. Checks: a requirement typed with a grouping row, a type
  whose group contradicts `requirement_kind`, and a work requirement with no type.
- **`work_requirement`**, a subtype table sharing the requirement's key (as Ch 4's
  `product_requirement`), with three nullable FKs: `product_id`, `fixed_asset_id`,
  `deliverable_id`. Ch 4's three work requirements get their row and type in Ch 6's seed. A
  check: a `work_requirement` row exactly when `requirement_kind` is WORK (Ch 4's check
  covered the product side).
- **What each type needs** (data-quality queries): maintenance or repair names a fixed
  asset (point 13), a production run names a product and a quantity.
- **`deliverable`** and **`deliverable_type`**, as drawn.
- **`fixed_asset`** gains `date_acquired`, `date_last_serviced`, `date_next_service` and
  `production_capacity`. `date_acquired` is drawn mandatory but stays nullable: Ch 5's three
  assets are dated in Ch 6's seed, and a check catches one that isn't. Next service before
  last service is a check constraint.
- **Seed:** Tables 6.1–6.2 with their ids. ABC Manufacturing, Inc. (party 53) is the
  manufacturer whose demand it is: an internal organization, so the production runs are
  INTERNAL needs. 51245 and 51285 have no dates in the book; ours. Product 22, the engraved
  black pen with gold trim; fixed asset 5025, engraving machine #12; deliverable 1, the
  "2001 Sales/Marketing Plan". Bad rows: 70501, a maintenance need naming no machine;
  70502, a production run with no product; 70503, a work requirement typed with the group
  row; 70504, a product requirement typed as a production run; 70505, a work requirement
  with no type; 70506, a work requirement with no `work_requirement` row. Fixed asset 3,
  Ch 5's dock conveyor, left with no acquisition date. Ch 4's dock door repair (50003) gets
  its type and row here and stays in the no-machine list with the PC repairs.

### Fig 6.2
- **`requirement_role`** gains `comment`. The book's identifier (requirement, party, type,
  from date) stays a data-quality query beside the surrogate key.
- **Role types:** CREATED_FOR, CREATED_BY, RESPONSIBLE_FOR, AUTHORIZED_BY added to Ch 4's
  `requirement_role_type` (point 14).
- **One responsible party at a time** (our reading of Table 6.3): overlapping
  RESPONSIBLE_FOR periods on one requirement are a data-quality query.
- **Seed:** Table 6.3 with point 4's dates, thru dates +1 day (exclusive). John Smith (54),
  Sam Bossman (55) and Dick Jones (56), new people at ABC Manufacturing. Bad rows: Sam
  Bossman responsible for 50985 from Jan 15, 2001, inside Dick's period; and Table 6.3's
  first row keyed in twice.

### Fig 6.3a
- **`work_effort`** (Ch 2's) gains `actual_start_datetime`, `actual_completion_datetime`,
  `actual_hours`, `special_terms`, `facility_id` (optional) and `work_effort_purpose_type_id`
  (optional, point 6). Actual completion before actual start is a check constraint.
  `work_effort_type` gains `standard_work_hours`.
- **`work_effort_purpose_type`**: PRODUCTION_RUN, MAINTENANCE, WORK_FLOW, RESEARCH.
- **`production_run`**, a subtype table sharing the effort's key: `quantity_to_produce`,
  `quantity_produced`, `quantity_rejected`. A check: a row exactly when the purpose is
  PRODUCTION_RUN.
- **`work_requirement_fulfillment`**: `work_effort_id` and a `requirement_id` that
  references `work_requirement`, so the FK itself keeps product requirements out.
- **`order_item_kind`** on `order_item`: PRODUCT (the default) or WORK (point 12).
  **`work_order_item_fulfillment`**: `work_effort_id` and `order_item_id`. A check: the
  item is a WORK item.
- **Duplicate links** in either fulfilment table are a data-quality query.
- **Seed:** Table 6.4's five efforts and Table 6.5's two, with their ids, at ABC
  Manufacturing's pen plant (facility 15) or its head office (16). Actuals ours for the
  runs already done. Requirement 52001, "need for customised pens" (a customer need), and
  sales order 23500 with its line for 2,500 customised engraved pens (product 23, a WORK
  item) committed to it; the order (ACME's, ours) also takes 500 plain engraved pens (line 2,
  a PRODUCT line) committed to the forecast 51285, so its work is reached through the need:
  both paths on one order. Bad rows: effort 29900, a research job with a `production_run` row;
  51298 also linked to Ch 4's order line 1 (a product line); 28045's link to 50985 twice.

## When NOT to use this
- **A shop that only sells** never generates work: a service it sells is a product line on
  an order (Ch 4), and nothing needs WORK EFFORT.
- **One job per order line, always:** if every job comes from exactly one order line and
  fills it whole, an `order_item_id` on the job is enough. The fulfilment tables earn their
  place when one need takes several jobs, or one job fills several needs.
- **No planning step:** if work starts straight from orders, skip WORK REQUIREMENT and keep
  only the order path (6.3a's direct link). If work always goes through planning, keep only
  the requirement path (6.3b).
- **Purpose and level together** are only worth two lookups when people ask both questions
  ("all maintenance, at any level"; "every task, whatever its purpose"). A small team can
  live with one type.

## Open questions
- What the chapter's overall figure keeps from 6.3a and 6.3b (point 11).
