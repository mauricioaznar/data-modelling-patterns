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

## Submodels (proposed 2026-10-19, all figures shared; Fig 6.13 is the architecture)
1. **Work requirements and their roles** (Figs 6.1–6.2): what work is needed, of which type
   (a production run, maintenance, an internal project), to produce which product or
   deliverable, or to work on which machine; who created it, for whom, who is responsible for
   it and when, and who authorised it?

2. **Work effort generation** (Fig 6.3a; 6.3b the alternate): what work is planned and done,
   at what level (program down to activity) and for what purpose (production run,
   maintenance, research), where it happens, which needs it fulfils and which order lines;
   for a production run, how many to make and how many came out good or rejected?

3. **Work effort breakdown** (Fig 6.4): what is this work made of, which parts serve more
   than one job, what must finish before what and what must run together, and which effort
   redoes which? What is the standard time for each kind of work?

4. **Work effort assignments and time** (Figs 6.5–6.6): who works on an effort, in which
   role, where and for which dates; what each party is skilled at; what state the work is in
   and since when; how many hours each worker spent on which effort, gathered on timesheets
   per period, and who else is involved in each timesheet?

5. **Work effort rates** (Fig 6.7): what does an hour of this person on this job cost us,
   and what do we bill for it, regular or overtime, on a given day? What is the standard
   rate for a kind of position, or for a party wherever they work?

6. **Inventory and fixed asset assignments** (Figs 6.8–6.10): which stock a job used up, and
   how much; which machines, vehicles and tools a job uses and when, in what state and at
   what cost; what kinds of asset there are; who has which asset checked out, and is it
   still active or lost?

7. **Work effort standards and results** (Figs 6.11–6.12): for a kind of work, what does it
   usually break into, and how many people of which skill, how many of which goods, and
   which kinds of asset for how long does it need? What does it normally produce or repair?
   And what did each actual effort produce (stock, deliverables) or repair?

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

### Fig 6.4 — Work effort breakdown
**Transcription** (accepted: ☐; photo with Table 6.6)

```
WORK EFFORT ASSOCIATION
  # effective_from_date
  o effective_thru_date
  subtypes: WORK EFFORT BREAKDOWN; WORK EFFORT DEPENDENCY, itself with subtypes
            WORK EFFORT PRECEDENCY and WORK EFFORT CONCURRENCY (none has attributes)
  -> WORK EFFORT               (many "associated with" 1 effort, as "from"; part of the key)
  -> WORK EFFORT               (many "associated with" 1 effort, as "to"; part of the key)

WORK EFFORT                       (6.3a's attributes; set 1 PROGRAM, PROJECT, PHASE, TASK,
                                   ACTIVITY; set 2 PRODUCTION RUN with its quantities,
                                   MAINTENANCE, WORK FLOW, RESEARCH)
  -> WORK EFFORT               (dashed, optional: "a version of" 1 effort; the effort
                                "redone via" many)
  -> WORK EFFORT TYPE          (many "described by" 1; type "used to describe" many; drawn
                                from the whole box this time)

WORK EFFORT TYPE
  # work_effort_type_id
  * description
  o standard_work_hours
```

**Table 6.6, work effort breakdown** (effort · subtype · description · parent(s) ·
standard hours · scheduled start–completion · estimated hours)
- 28045 · Job · production run #1 · – · – · Jun 1–Jun 4, 2000 · –
- 120001 · Activity · set up production line · 28045 run #1 *and* 51245 run #2 · 20 ·
  Jun 1–Jun 2 · 20
- 120002 · Activity · operate machinery · 28045 · 10 · Jun 3–Jun 3 · 10
- 120003 · Activity · clean up machinery · 28045 · 5 · Jun 4–Jun 4 · 5
- 120004 · Activity · quality assure the goods produced · 28045 · 10 · Jun 3–Jun 4 · 10
- 3454587 · Task · move the pen machinery into place · "1200" set up production line · 5 ·
  Jun 1 · 4
- 3454588 · Task · move raw materials into place for the run · "1200" · 8 · Jun 1 · 7
- 3454589 · Task · set up the assembly line rollers · "1200" · 7 · Jun 1 · 6

**To check against the book**
- "Job" is the subtype printed for 28045, but JOB isn't one of the five drawn (point 15).
- Standard work hours are given per effort, while the attribute sits on WORK EFFORT TYPE
  (point 16).
- 51245 "Production run #2" is a requirement's number in Table 6.4, not an effort's (point 17).
- The tasks' parent is printed "1200", read as 120001, set up production line (point 18).
- Which end is "from" in a dependency isn't drawn (point 19).
- The "redone via" line: is it dashed on both ends (optional both ways)? Read as optional.

**Discussion**
- **Work is a tree, and more than a tree.** A job breaks into activities, an activity into
  tasks. The naive model is a `parent_id` on the effort: one parent each. Table 6.6 already
  breaks it: set-up 120001 serves two runs. So the breakdown is an association between two
  efforts, many-to-many, dated so a plan can be reshaped without losing what it was.
- **Same association, other meanings.** Beyond "is part of", two efforts can depend on each
  other: one must finish before the other starts (precedency), or both must run at the same
  time (concurrency). One table holds all three; the subtype says which. It's Ch 2's party
  relationship move applied to work: a typed, dated link between two rows of one table.
- **Versions.** A job redone (a rework, a re-run) points at the effort it redoes. It's a
  plain self-reference: one original, many redos.
- **When not to:** a team whose work is always a strict tree, never shared and never
  sequenced, lives happily with `parent_id`. The association earns its place with shared
  sub-work or with scheduling (dependencies are what a Gantt chart draws).

### Fig 6.5 — Work effort party assignment
**Transcription** (accepted: ☐; photo with Tables 6.7–6.9)

```
WORK EFFORT PARTY ASSIGNMENT
  # from_date
  o thru_date
  o comment
  -> PARTY                     (many "the assignment of" 1; party "allocated via" many; key)
  -> WORK EFFORT               (many "for" 1; effort "assigned via" many; key)
  -> WORK EFFORT ROLE TYPE     (many "described by" 1; type "used in" many; key)
  -> FACILITY                  (many "assigned at" 1; facility "used in" many; not in the
                                key, read as optional)

WORK EFFORT ROLE TYPE             (no attributes drawn)

PARTY SKILL
  o years_experience
  o rating
  -> PARTY                     (many "details about" 1; party "described by" many; key)
  -> SKILL TYPE                (many "defined by" 1; type "used to define" many; key)

SKILL TYPE
  # skill_type_id
  * description

WORK EFFORT STATUS
  o datetime
  -> WORK EFFORT STATUS TYPE   (many "defined using" 1; type "used to define" many; key)
  -> WORK EFFORT               (many "for" 1; effort "in the state of" many; key)

WORK EFFORT STATUS TYPE           (no attributes drawn)
WORK EFFORT                       (6.3a's attributes); PARTY, FACILITY (Ch 2's)
```

**Table 6.7, party assignments** (effort · party · role · from · thru · comment)
- 39409 develop a sales and marketing plan · Dick Jones · project manager · Jan 2–Sep 15, 2001
- 39409 · Bob Jenkins · project administrator · *no dates*
- 39409 · John Smith · team member · Mar 5–Aug 6, 2001 · leaving on a three-week holiday Aug 7
- 39409 · John Smith · team member · Sep 1–Dec 2, 2001
- 39409 · Jane Smith · team member · Aug 6, *2000*–Sep 15, 2001 · keen on the assignment
- 29000 develop project plan (part of 39409) · Dick Jones · creator · Jan 2–Jan 4, 2001
- 29000 · Bob Jenkins · data entry in system · Jan 4–Jan 4, 2001
- 29003 conduct initial interviews (part of 39409) · John Smith · performer · Jan 5–Feb 5, 2001
- 29005 conduct market research (part of 39409) · USA Consulting · outsourcing
  responsibility · Mar 1–Jul 1, 2001 · contracted outside

**Table 6.8, party skills** (party · skill · years · rating)
- John Smith · project management · 20 · 10; marketing · 5 · 6
- Dick Jones · project management · 12 · 8
- USA Consulting · market research · 25 · 10; sales analysis · 15 · 7; data warehousing · 5 · 5

**Table 6.9, statuses** (Table 6.6's efforts, with status and when)
- 28045 · in progress (no time)
- 120001 · started Jun 2, 2000 1 PM; completed Jun 2, 2000 2 PM
- 120002 · started Jun 3 1 PM; completed Jun 3 4 PM
- 120003 · started Jun 4 9 AM; completed Jun 4 10 AM
- 120004 · pending

**To check against the book**
- Bob Jenkins's project administrator row has no from date, which is part of the key
  (point 20).
- Jane Smith's from date, Aug 6, 2000, starts before the project exists (point 21).
- The status's datetime is drawn optional, and the key is the effort and the status type
  alone: one row per status per effort (point 22).
- The facility line's optionality is hard to read; read as optional.

**Discussion**
- **Who works on what, as what, and when.** The naive model puts an `assigned_to` column
  on the job: one person, no role, no dates. Table 6.7 has five parties on one project, in
  three roles, one of them twice (John Smith leaves for a holiday and comes back), and a
  company among them. The assignment is a dated, role-typed link between a party and an
  effort. From date is in the key, so the same person can come back in the same role.
- **Party, not person.** USA Consulting takes the market research: the enterprise only
  cares that it gets done, not who in that firm does it. Skills are the same: a firm has
  25 years of market research.
- **Skills are a fact about the party, not about the assignment.** PARTY SKILL says what a
  party can do (years, a rating); it's what a manager looks at before assigning. Nothing
  forces an assignment to match a skill.
- **Status as history.** WORK EFFORT STATUS is a list of status events per effort (started
  at, completed at), the same move as Ch 4's order status. The current status is the latest.
- **Roles on the effort, not on the requirement.** Fig 6.2's roles are about the need (who
  asked, who authorised); these are about the work (who manages, who performs).

### Fig 6.6 — Work effort time tracking
**Transcription** (accepted: ☐; photos with Table 6.10)

```
TIME ENTRY
  # time_entry_id
  * from_datetime
  * thru_datetime
  * hours
  o comment
  -> TIMESHEET                 (many "within" 1; timesheet "composed of" many)
  -> WORK EFFORT               (many "the time spent on" 1; effort "tracked via" many)

TIMESHEET
  # timesheet_id
  * from_date
  * thru_date
  o comment
  -> PARTY ROLE                (many "for the hours of" 1 role; role "submitting" many),
                                the role being a WORKER

TIMESHEET ROLE                    (no attributes drawn)
  -> PARTY                     (many "of" 1; party "involved in" many; key)
  -> TIMESHEET ROLE TYPE       (many "described by" 1; type "the description for" many; key)
  -> TIMESHEET                 (many "for" 1; timesheet "involving" many; key)

PARTY ROLE                        (Ch 2's) with subtype WORKER, itself with subtypes
                                   EMPLOYEE and CONTRACTOR
  -> PARTY                     (many "for" 1; party "acting as" many)

WORK EFFORT PARTY ASSIGNMENT
  # from_date
  * thru_date                  (mandatory here, optional in 6.5)
  o comment
  -> PARTY                     (many "the assignment of" 1; "allocated via")
  -> WORK EFFORT               (many "for" 1; "assigned via")

PARTY (with PERSON, ORGANIZATION), WORK EFFORT (6.3a's attributes)
```

**Table 6.10, timesheets and time entries** (timesheet · from–thru · party · effort ·
entry from–thru · hours)
- 1390 · Jan 1–Jan 15, 2001 · Dick Jones
  - 29000 develop project plan (part of 39409) · Jan 2–Jan 4 · 13
  - 29005 identify potential team members for the project · Jan 5–Jan 6 · 7
- 1200 · Feb 1–Feb 15, 2001 · John Smith
  - 29003 conduct initial interviews · Feb 1–Feb 5 · 30
  - 294395 facilitate the monthly goals session · Feb 6–Feb 6 · 6
- 1450 · Feb 16–Mar 1, 2001 · John Smith
  - 29003 conduct initial interviews · Feb 16–Mar 1 · 45

**To check against the book**
- 29005 is "conduct market research" in Table 6.7 and "identify potential team members" in
  Table 6.10 (point 23).
- John Smith logs time on 29003 to Mar 1, while his assignment to it ended Feb 5; and on
  294395, to which he has no assignment (point 24).
- WORK EFFORT PARTY ASSIGNMENT's thru date is starred here, a circle in 6.5 (point 25).
- The entries' times are printed as days; read as whole days.

**Discussion**
- **Time is recorded against the work, and gathered per worker.** A time entry says "these
  hours, on this effort, between these times". A timesheet gathers a worker's entries for a
  period, so it can be submitted and approved as one. The naive model puts `hours` on the
  assignment, which loses when the hours happened and can't be approved period by period.
- **A timesheet belongs to a worker role**, not to a party: the same person is an employee
  in one period and a contractor in another, and their sheets follow the role. WORKER
  groups EMPLOYEE and CONTRACTOR in Ch 2's role hierarchy.
- **Other parties on a timesheet** (who approved it, who entered it) are TIMESHEET ROLEs,
  the usual role triangle on a new hub.
- **Nothing ties the entry to the assignment.** Time and assignment both meet the work
  effort, separately. Whether someone logged time on work they weren't assigned to is a
  question for a query, and Table 6.10 already answers yes (point 24).

### Fig 6.7 — Work effort rates
**Transcription** (accepted: ☐; photos with Table 6.11)

```
POSITION TYPE RATE
  # from_date
  o thru_date
  o rate
  -> POSITION TYPE             (many "for" 1; type "with a rate of" many; key)
  -> RATE TYPE                 (many "of" 1; type "used to define" many; key)

PARTY RATE
  # from_date
  o thru_date
  o rate
  -> PARTY                     (many "for" 1; party "with a rate of" many; key)
  -> RATE TYPE                 (many "of" 1; type "used to define" many; key)

WORK EFFORT ASSIGNMENT RATE
  # from_date
  o thru_date
  o rate
  -> WORK EFFORT PARTY ASSIGNMENT (many 1; the assignment "with a rate of" many; key)
  -> RATE TYPE                 (many "associated with" 1; type "used to define" many; key)

RATE TYPE
  # rate_type_id
  * description

POSITION TYPE
  # position_type_id
  * description

WORK EFFORT PARTY ASSIGNMENT
  # from_date
  * thru_date                  (starred, as in 6.6)
  o comment
  -> PARTY                     ("the assignment of" / "allocated via")
  -> WORK EFFORT               ("for" / "assigned via")

PARTY (with PERSON, ORGANIZATION); WORK EFFORT (6.3a's attributes)
```

**Table 6.11, rates** (work task · party · rate type · from · thru · rate)
- Develop accounting program · Gary Smith · regular billing · May 15, 2000–May 14, 2001 · $65
- same · overtime billing · same dates · $70
- same · regular pay · same dates · $40
- same · overtime pay · same dates · $43
- same · regular pay · from May 15, 2001 · $45
- same · overtime pay · from May 15, 2001 · $45

**To check against the book**
- The line from WORK EFFORT ASSIGNMENT RATE to the assignment is labelled "with a rate of"
  at both ends in the photo; read as the rate "for" the assignment.
- Table 6.11's header says "work task" and "party": read as Gary Smith's assignment to the
  task, the only place an assignment rate can hang.
- No unit on any rate: read as dollars an hour, since the text multiplies it by time entry
  hours.

**Discussion**
- **Hours become money only through a rate.** A time entry has hours, not dollars. To bill a
  client or pay a worker you multiply the hours by the rate in force on the day, of the right
  kind (regular or overtime, billing or pay). The naive model puts `hourly_rate` on the
  person: one number, so billing and pay can't differ, and a raise rewrites last year's
  invoices.
- **Three levels, from general to specific.** A standard rate for a kind of position (all
  senior programmers), a rate for a party wherever they work, and a rate for one assignment.
  Each is dated and typed by RATE TYPE. The model stores all three; which one wins is a
  business rule outside it (the text says so). The usual rule is that the most specific wins.
- **Rate type, not columns.** Regular, overtime, billing and pay are rows of RATE TYPE, so a
  holiday rate or a weekend rate is a new row, not a new column.
- **Overtime equal to regular.** After the raise, overtime pay is $45, the same as regular.
  Storing it anyway keeps the payroll process unchanged: it still looks up an overtime rate,
  which happens to be no higher.

### Fig 6.8 — Inventory assignments
**Transcription** (accepted: ☐; photos with Table 6.12)

```
WORK EFFORT INVENTORY ASSIGNMENT
  o quantity
  -> INVENTORY ITEM            (many "the use of" 1; item "used in" many; key)
  -> WORK EFFORT               (many "used in the completion of" 1; effort "in need of" many; key)

INVENTORY ITEM
  # inventory_item_id
  subtypes SERIALIZED INVENTORY ITEM (* serial_num), NON SERIALIZED INVENTORY ITEM
           (* quantity_on_hand)

WORK EFFORT (6.3a's attributes)
```

**Table 6.12, inventory used** (effort · item · quantity)
- Assemble pencil components · pencil cartridges · 100
- Assemble pencil components · erasers · 100
- Assemble pencil components · labels · 100

**To check against the book**
- The key is the item and the effort alone: one row per item per effort, with a single
  quantity.
- Quantity is drawn optional; a serialized item has no quantity to give.

**Discussion**
- **Work consumes stock.** A job takes physical stock (Ch 3's inventory items) and uses it
  up. The link says which stock and how much. The naive model puts a `materials` text on the
  job, which no stock count can use.
- **Item, not good.** The link points at the inventory item (these 100 cartridges on that
  shelf), not at the catalogue good. The plan side (Fig 6.11) points at the good.
- **Depletion is a process, not a line.** The text says the business must lower the item's
  quantity on hand when a job uses it; the model doesn't do it by itself. Ch 5's balance (count
  + receipts − issuances) now gets a fourth term: what work efforts used, and Fig 6.12 adds a
  fifth, what they produced.

### Fig 6.9 — Fixed asset assignments
**Transcription** (accepted: ☐; photos with Tables 6.13–6.15)

```
WORK EFFORT FIXED ASSET ASSIGNMENT
  * from_date                  (a star, not a hash: not in the key as drawn)
  o thru_date
  o allocated_cost
  o comment
  -> FIXED ASSET               (many "a usage of" 1; asset "used in" many; key)
  -> WORK EFFORT               (many "used to perform" 1; effort "assigned fixed assets via"
                                many; key)
  -> WORK EFF ASSET ASSIGN STATUS TYPE (many "in the state of" 1; type "the status for" many;
                                not in the key)

WORK EFF ASSET ASSIGN STATUS TYPE (no attributes drawn)

FIXED ASSET
  # fixed_asset_id
  * name
  * date_acquired
  o date_last_serviced
  o date_next_service
  o production_capacity
  o description
  subtypes PROPERTY, VEHICLE, EQUIPMENT, OTHER FIXED ASSET
  -> UNIT OF MEASURE           (many "associated with" 1; unit "the capacity uom" many)
  -> FIXED ASSET TYPE          (many "described by" 1; type "used to describe" many)

FIXED ASSET TYPE
  # fixed_asset_type_id
  * description
  -> FIXED ASSET TYPE          (recursive: "a type of" / "sub-typed by", dashed)

UNIT OF MEASURE
  # uom_id
  * description
```

**Table 6.13, fixed assets** (id · type · name · acquired · last serviced · next service ·
capacity · unit)
- 1000 · pencil-making machine · Pencil labeler #1 · Jun 12, 2000 · Jun 12, 2000 · Jun 12,
  2001 · 1,000,000 · pens/day
- 2266 · fork lift · Fork lift #25 · Mar 1, 1999 · Mar 15, 2001 · Aug 1, 2001 · 5 · people

**Table 6.14, fixed asset types** (id · description · parent)
- 1000 Equipment; 1390 Pencil-making machine, 1458 Pen-making machine, 1532 Paper-making
  machine, each under Equipment
- 2000 Vehicle; 2019 Truck, 2266 Fork lift, 2356 Jet airplane, 2567 Car under Vehicle; 2188
  Mac truck-18 wheels under Truck

**Table 6.15, assets on efforts** (effort · asset · from · thru · comment)
- Label pencils · Pencil labeler #1 · Jun 12–Jun 15, 2000
- Move raw materials in place for production run · Fork lift #25 · Apr 15–May 15, 2000 ·
  may need it for longer
- Test database tool · Office laptop #2 · from Jul 1, 2000 · an ongoing effort

**To check against the book**
- From date is starred, not hashed, in both assignment entities (point 31).
- Table 6.13's asset ids 1000 and 2266 are also type ids in Table 6.14 (Equipment, Fork
  lift); the pencil labeler is measured in pens a day, the fork lift in people (point 32).
- The status line's optionality: solid at the assignment, read as mandatory.

**Discussion**
- **One machine, one job at a time.** The text's reason for the entity: a machine can usually
  serve only one effort at a time, so scheduling needs to know when each asset is booked. The
  dates matter more than for people, and two overlapping bookings of one asset are the
  mistake to catch.
- **Status on the booking.** Requested or assigned: a booking can be asked for before it's
  granted. Here it's a single current status, not a history like WORK EFFORT STATUS.
- **Allocated cost.** How much of the asset's cost the job carries, for costing the job.
- **Subtypes and a type hierarchy side by side.** PROPERTY, VEHICLE, EQUIPMENT and OTHER are
  the subtypes; FIXED ASSET TYPE nests further (vehicle, truck, an 18-wheeler) as deep as
  needed. Ch 5 already built the type as a lookup with VEHICLE and EQUIPMENT; the subtypes
  become its top rows and the recursion its parent column.
- **Capacity needs a unit.** 1,000,000 of what, per what: production capacity comes with a
  UNIT OF MEASURE (Ch 3's).

### Fig 6.10 — Party fixed asset assignments
**Transcription** (accepted: ☐; photos with Table 6.16)

```
PARTY FIXED ASSET ASSIGNMENT
  * from_date                  (a star again)
  o thru_date
  o allocated_cost
  o comment
  -> FIXED ASSET               (many "an assignment for" 1; asset "assigned via" many; key)
  -> PARTY                     (many "an assignment to" 1; party "assigned" many; key)
  -> PARTY ASSET ASSIGN STATUS TYPE (many "in the state of" 1; type "the status for" many)

PARTY ASSET ASSIGN STATUS TYPE    (no attributes drawn)
FIXED ASSET (as in 6.9, subtypes PROPERTY, VEHICLE, EQUIPMENT, OTHER ASSET); PARTY
```

**Table 6.16, assets held by parties** (party · asset · start · end · status)
- John Smith · Car#25 · Jan 1, 2000–Jan 1, 2001 · active
- Dick Jones · Tool set #5 · Mar 15, 2000–Mar 15, 2000 · lost

**To check against the book**
- Table 6.16 says "Car#25", the text says "Truck #25" and then "this car" (point 33).
- 6.10 calls the last subtype OTHER ASSET, 6.9 OTHER FIXED ASSET.

**Discussion**
- **Assets go to parties too.** Checked out, not used on a job: a car to a salesman, a tool
  set to a fitter. The party answers for it while it's out. This is how the enterprise knows
  where its assets are and that the car isn't free to give someone else.
- **Same shape as 6.9, other end.** Dates, allocated cost, a comment and a current status
  (active, lost). "Lost" ends the story: the status carries the outcome the dates can't.
- **Party, not person or role.** A department could hold the photocopier.

### Fig 6.11 — Work effort type standards
**Transcription** (accepted: ☐; photos with Tables 6.17–6.18)

```
WORK EFFORT TYPE ASSOCIATION
  subtypes WORK EFFORT TYPE BREAKDOWN, WORK EFFORT TYPE DEPENDENCY
  -> WORK EFFORT TYPE          (many "associated with" 1, "from"; key)
  -> WORK EFFORT TYPE          (many "associated with" 1, "to"; key)
  (no attributes drawn)

WORK EFFORT SKILL STANDARD
  * estimated_num_people
  * estimated_duration
  o estimated_cost
  -> SKILL TYPE                (many "for" 1; type "needed in" many; key)
  -> WORK EFFORT TYPE          (many "for" 1; type "in need of" many; key)

WORK EFFORT GOOD STANDARD
  * estimated_quantity
  o estimated_cost
  -> GOOD                      (many "for" 1; good "needed in" many; key)
  -> WORK EFFORT TYPE          (many "for" 1; type "in need of" many; key)

WORK EFFORT FIXED ASSET STANDARD
  * estimated_quantity
  * estimated_duration
  o estimated_cost
  -> FIXED ASSET TYPE          (many "for" 1; type "needed in" many; key)
  -> WORK EFFORT TYPE          (many "for" 1; type "of" many; key)

WORK EFFORT TYPE
  # work_effort_type_id
  * description
  o standard_work_hours
  -> FIXED ASSET TYPE          (many "used to repair" 1; "repaired from" many)   } an arc:
  -> DELIVERABLE TYPE          (many "used to produce" 1; "created from" many)   } at most
  -> PRODUCT                   (many "used to produce" 1; "created from" many)   } one

SKILL TYPE (# id, * description); GOOD; FIXED ASSET TYPE (# id, * description);
DELIVERABLE TYPE (# id, * description); PRODUCT (Ch 3's attributes)
```

**Table 6.17, goods standards** (work effort type · item · estimated quantity · cost)
- Large production run of pencils · erasers · 1,000 · $2,500
- Large production run of pencils · labels · 1,000 · $2,000
- Large production run of pens · ink cartridges · 2,000 · $3,000

**Table 6.18, fixed asset standards** (work effort type · asset type · quantity · duration)
- Large production run of pencils · pencil labeler · 1 · 10 days
- Large production run of pencils · fork lift · 2 · 5 days

**To check against the book**
- The arc over the three "used to" lines: read as at most one of them (point 36).
- Table 6.18's "pencil labeler" isn't a type in Table 6.14 (point 35).
- No sample data for the skill standard; ours.
- The text says the PARTS model of "Figure 2.10b" would put PART in place of GOOD: read as
  Fig 3.10b.

**Discussion**
- **Plan from the type, record on the instance.** A kind of work (a large production run of
  pencils) has standards: so many people of this skill for so long, so many erasers, two
  fork lifts for five days. From the work scheduled you predict what you'll need and prepare.
  The naive model copies the list onto every job, or keeps it in a spreadsheet.
- **Good, not inventory item.** For planning you only need the kind of good. Comparing the
  standard with stock on hand says whether there's enough to run the job.
- **Asset type, not asset.** Likewise, the plan needs "a fork lift", not Fork lift #25.
- **The type's own breakdown.** WORK EFFORT TYPE ASSOCIATION is Fig 6.4's association one
  level up: the standard plan of a kind of work (a large run is set-up, operate, clean up,
  QA; set-up comes first). Instances copy it when the job is planned.
- **What the type is for.** A kind of work repairs a kind of asset, or produces a kind of
  deliverable, or produces a product: the expected outcome, set beside the actual one of Fig
  6.12.

### Fig 6.12 — Work effort results
**Transcription** (accepted: ☐; photo, text on the next page)

```
WORK EFFORT INVENTORY PRODUCED    (no attributes)
  -> WORK EFFORT               (many "by" 1; effort "producing" many; key)
  -> INVENTORY ITEM            (many "resulting in production of" 1; item "produced by" many;
                                key)

WORK EFFORT DELIVERABLE PRODUCED  (no attributes)
  -> WORK EFFORT               (many "by" 1; effort "producing" many; key)
  -> DELIVERABLE               (many "resulting in production of" 1; deliverable "produced
                                by" many; key)

WORK EFFORT
  (6.3a's attributes, both subtype sets)
  -> FIXED ASSET               (many "resulting in the repair of" 1; asset "repaired via"
                                many; optional)

INVENTORY ITEM (SERIALIZED with * serial_num, NON SERIALIZED with * quantity_on_hand);
DELIVERABLE (# id, * name, o description); FIXED ASSET (6.9's attributes)
```

**To check against the book**
- No quantity on WORK EFFORT INVENTORY PRODUCED (point 38).
- The repair line is drawn optional at both ends.

**Discussion**
- **Standards say what should come out; results say what did.** An effort produces stock (an
  inventory item), a deliverable (a plan, a report), or repairs a fixed asset. All three
  optional: a meeting produces nothing you can store.
- **Record results low, roll them up.** The text says to hang results on the lowest efforts
  (the task that wrote the report), so a project's results are the union of its parts'.
- **Closing the loop with Ch 3 and Fig 6.1.** The requirement said "produce this product" or
  "fix that machine"; the result says which stock came out or which machine was fixed. Each
  can be checked against the other.

### Fig 6.13 — Overall work effort model
**Transcription** (accepted: ☐; one photo; identifiers only, a few attributes; open points
under "Points to discuss after the overview")

```
Shown:
  WORK ORDER ITEM FULFILLMENT, ORDER REQUIREMENT COMMITMENT (o quantity), ORDER ITEM
  (# order_item_seq_id), WORK REQUIREMENT FULFILLMENT, REQUIREMENT (loop),
  WORK EFFORT DELIVERABLE PRODUCED, WORK EFFORT INVENTORY PRODUCED,
  WORK EFFORT (# id; PROGRAM, PHASE, PROJECT, TASK, ACTIVITY; PRODUCTION RUN, MAINTENANCE,
  RESEARCH, WORK FLOW; a loop), WORK EFFORT STATUS, WORK EFFORT STATUS TYPE,
  WORK EFFORT PARTY ASSIGNMENT (# from_date), WORK EFFORT ROLE TYPE, FACILITY (twice),
  WORK EFFORT ASSIGNMENT RATE (# from_date), WORK EFFORT INVENTORY ASSIGNMENT, INVENTORY
  ITEM, WORK EFFORT FIXED ASSET ASSIGNMENT, FIXED ASSET, UNIT OF MEASURE, WORK EFFORT FIXED
  ASSET STANDARD, WORK EFFORT TYPE (# id), WORK EFFORT PURPOSE TYPE (# id), WORK EFFORT
  SKILL STANDARD, WORK EFFORT GOOD STANDARD, GOOD, TIMESHEET ROLE, TIMESHEET (# from_date),
  WORKER (EMPLOYEE, CONTRACTOR), TIME ENTRY (# from_datetime), PARTY RATE, PARTY SKILL,
  PARTY, SKILL TYPE, POSITION TYPE RATE (# from_date), POSITION TYPE (# id, * description)

Lines, as read:
  WORK ORDER ITEM FULFILLMENT -> ORDER ITEM, WORK EFFORT
  ORDER REQUIREMENT COMMITMENT -> ORDER ITEM, REQUIREMENT
  WORK REQUIREMENT FULFILLMENT -> REQUIREMENT, WORK EFFORT;  REQUIREMENT loop (dashed)
  WORK EFFORT DELIVERABLE PRODUCED, WORK EFFORT INVENTORY PRODUCED -> WORK EFFORT
  WORK EFFORT STATUS -> WORK EFFORT, WORK EFFORT STATUS TYPE
  WORK EFFORT PARTY ASSIGNMENT -> WORK EFFORT, FACILITY, PARTY, WORK EFFORT ROLE TYPE
  WORK EFFORT ASSIGNMENT RATE -> WORK EFFORT PARTY ASSIGNMENT
  WORK EFFORT INVENTORY ASSIGNMENT -> WORK EFFORT, INVENTORY ITEM
  WORK EFFORT FIXED ASSET ASSIGNMENT -> WORK EFFORT, FIXED ASSET
  FIXED ASSET -> UNIT OF MEASURE
  WORK EFFORT FIXED ASSET STANDARD -> FIXED ASSET (not FIXED ASSET TYPE), WORK EFFORT TYPE
  WORK EFFORT -> FACILITY, WORK EFFORT TYPE, WORK EFFORT PURPOSE TYPE; WORK EFFORT loop
  WORK EFFORT SKILL STANDARD -> WORK EFFORT TYPE, SKILL TYPE
  WORK EFFORT GOOD STANDARD -> WORK EFFORT TYPE, GOOD
  TIMESHEET ROLE -> TIMESHEET, PARTY;  TIMESHEET -> WORKER;  TIME ENTRY -> TIMESHEET,
  WORK EFFORT
  PARTY RATE, PARTY SKILL -> PARTY;  PARTY SKILL -> SKILL TYPE
  POSITION TYPE RATE -> POSITION TYPE
```

What it adds or settles:
- **6.3a wins over 6.3b:** WORK ORDER ITEM FULFILLMENT is there, so an order line can reach
  its work directly (settles point 11).
- **The standard needs an asset, not an asset type?** WORK EFFORT FIXED ASSET STANDARD hangs
  on FIXED ASSET here, FIXED ASSET TYPE in 6.11, which drops out of the figure (point 39).
- **WORK EFFORT's loop** stands for Fig 6.4's association (and the redo line), as Ch 4's
  overall model drew REQUIREMENT's loop.
- Left out: every association, role, rate and status type; WORK REQUIREMENT and its roles;
  DELIVERABLE (and type) and the repair line; PARTY FIXED ASSET ASSIGNMENT and its status;
  WORK EFFORT TYPE ASSOCIATION; FIXED ASSET TYPE; the type's "used to" arc. Read as
  abbreviation, as for Figs 3.11, 4.17 and 5.8 (point 40).

**How it flows** (architecture figure: no SQL, on assumptions until the overview)
- **Two hubs, need and work:** a WORK REQUIREMENT (Ch 4's REQUIREMENT, work kind) says what
  work is needed; a WORK EFFORT is the work planned and done, at a level (program to
  activity, or job) and for a purpose (production run, maintenance, research, work flow).
- **How work is started:** WORK REQUIREMENT FULFILLMENT (need → work) or WORK ORDER ITEM
  FULFILLMENT (a sold line → work); ORDER REQUIREMENT COMMITMENT links the two from Ch 4.
- **How work is shaped:** WORK EFFORT ASSOCIATION breaks it down and orders it; a STATUS
  history says where it stands.
- **What it takes:** parties in roles, dated (PARTY ASSIGNMENT), priced by rates at three
  levels; hours on TIME ENTRYs gathered on a WORKER's TIMESHEET; stock used up (INVENTORY
  ASSIGNMENT); machines booked (FIXED ASSET ASSIGNMENT). Assets also go out to parties.
- **What it should take and give:** WORK EFFORT TYPE carries standards (skills, goods,
  assets, hours) and its own breakdown; RESULTS record stock and deliverables produced and
  assets repaired.
- **From Ch 2:** PARTY, PARTY ROLE (WORKER), FACILITY, STATUS TYPE. **From Ch 3:** PRODUCT,
  GOOD, INVENTORY ITEM, UNIT OF MEASURE. **From Ch 4:** REQUIREMENT, ORDER ITEM. **From Ch 5
  (ahead of Ch 8):** FIXED ASSET. **Ahead of Ch 9:** POSITION TYPE.
- **Alternates:** 6.3a kept, 6.3b dropped.

### Points to discuss after the overview (Figs 6.1–6.13)
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
15. **Table 6.6, JOB:** 28045's subtype is "Job", not one of the five drawn. Built as a
    sixth level row, and every production run retyped JOB (this settles point 10 for runs).
16. **Table 6.6, standard hours per effort:** the attribute is on WORK EFFORT TYPE, yet each
    activity has its own standard. Read: WORK EFFORT TYPE is a catalogue of kinds of work
    ("set up production line", 20 hours), not only the five levels. Built: Ch 2's
    `work_effort_type` gains a parent, the levels become its grouping rows and the kinds of
    work its leaves, so the type implies the level. Alternative: level and kind of work in
    two columns (Ch 2 merged them).
17. **Table 6.6, 51245 "Production run #2":** 51245 is a requirement in Table 6.4, filled
    by 28045. Seeded as a new effort 51245, a second run sharing #1's set-up, which is the
    point the row makes.
18. **Table 6.6, "1200":** read as 120001, set up production line, the only set-up.
19. **6.4, direction:** breakdown runs from the parent to the part; a precedency from the
    effort that comes first to the one that waits; a concurrency either way (a query reads
    both directions).
20. **Table 6.7, Bob Jenkins without dates:** from date is part of the key. Seeded from Jan
    2, 2001, Dick Jones's start (ours).
21. **Table 6.7, Jane Smith from Aug 6, 2000:** read as Aug 6, 2001: she starts the day John
    Smith leaves for three weeks, and both stop on Sep 15. Seeded as 2001.
22. **6.5, status keyed by type:** one row per status per effort, the datetime optional
    ("in progress" and "pending" have none). Built with a surrogate key; a duplicate is a
    check. A status that comes back (paused, then in progress again) would need the
    datetime in the key.
23. **Tables 6.7 and 6.10, 29005:** market research (USA Consulting) in one, team members
    (Dick Jones) in the other. 29005 kept as market research; the team-member work seeded
    as 29006 (ours), part of 39409.
24. **Table 6.10, time outside assignments:** John Smith's Feb 16–Mar 1 hours on 29003, and
    his 294395 session. Seeded as printed; a review query lists time with no assignment
    covering it, counting an assignment to a parent effort as covering its parts.
25. **6.6, thru date starred:** 6.5 draws it optional and the text speaks of open-ended
    assignments. Built optional.
26. **Submodel 4's figures:** 6.5–6.6 for now. If Fig 6.7 (rates) joins it, its card heading
    changes and Anki makes a new note.
27. **6.5, two places for "started at":** a STARTED status with its datetime and WORK
    EFFORT's actual start datetime say the same thing. Table 6.9's activities have statuses
    and no actuals; seeded that way. Which one is the record, or does the status fill the
    actual?
28. **6.7 is its own submodel:** rates became submodel 5, not part of 4, so card 25's heading
    stays (settles point 26). Rates answer "what does the hour cost", a separate question.
29. **6.7, which rate wins:** the model stores three levels and leaves the choice to a
    business rule. Built: a query takes the assignment's rate, else the party's. Position
    type rates stand alone: nothing ties a party to a position type until Ch 9's position
    fulfilment.
30. **6.7, POSITION TYPE ahead of Ch 9:** built here as a plain lookup, as Ch 5 built FIXED
    ASSET ahead of Ch 8. Gary Smith, the accounting program, his assignment (role, dates),
    the position rates, his party rates and his time entries are ours; only Table 6.11's
    assignment rates are the book's.
31. **6.9–6.10, from date starred, not hashed:** every other dated link in the book keys on
    its from date, and without it an asset couldn't go back to the same job or person twice.
    Read as a drawing slip. Built with a surrogate key; the rule the text gives (one asset,
    one job at a time; a car held by one person at a time) is the check: overlapping
    bookings of one asset.
32. **Table 6.13, ids and units:** the asset ids 1000 and 2266 are also type ids in Table
    6.14 (Equipment, Fork lift). Seeded as printed: assets and types are separate number
    spaces, and our type ids are text anyway. The pencil labeler's "pens/day" and the fork
    lift's "people" seeded as printed, as units of their own.
33. **Table 6.16, Car #25 or Truck #25:** seeded as a new asset "Car #25" of type CAR, apart
    from Ch 5's Truck #25 (fixed asset 2). If it's the same truck, John Smith's checkout
    joins Ch 5's route segments.
34. **Table 6.15 against Table 6.6, moving raw materials:** the effort is Table 6.6's 3454588,
    scheduled Jun 1, 2000, while the fork lift is booked Apr 15–May 15. Seeded on 3454588 as
    printed; a review lists bookings outside their effort's schedule.
35. **Table 6.18, "pencil labeler":** not a type in Table 6.14. Added as a type under
    pencil-making machine, and Table 6.13's Pencil labeler #1 typed with it, so a planner can
    see the standard is met by a real asset.
36. **6.11, the "used to" arc:** at most one of asset type repaired, deliverable type or
    product produced, a single-row rule built as a check constraint. Ch 2's and point 16's
    `parent_type_id` (a kind of) stays apart from the new WORK EFFORT TYPE ASSOCIATION (made
    of). The association reuses 6.4's type lookup and its leaves (breakdown, precedency,
    concurrency); the drawn DEPENDENCY is a grouping row there, so using it is a check.
37. **Tables 6.12 and 6.17, the goods:** pencil cartridges, labels and ink cartridges are new
    raw materials; erasers are Ch 5's standard eraser. Stock at the pen plant is ours.
    "Assemble pencil components" and "Label pencils" are seeded as parts of a new job (ours),
    a large production run of pencils typed with Table 6.17's type.
38. **6.12, no quantity produced:** the link has no quantity, so when two efforts feed one
    stock item (51285 and 51298 into the plant's pens) you can't tell who made how many. A
    production run's own quantity produced fills the gap for runs. Add a quantity to the link?
39. **6.13, asset standard on FIXED ASSET:** 6.11 draws it on FIXED ASSET TYPE and the text
    says the plan needs only the kind. Built per 6.11; 6.13 read as a slip.
40. **6.13 leaves out:** WORK REQUIREMENT and its roles, the association and type
    association, every role, rate and status type, deliverables and the repair line, PARTY
    FIXED ASSET ASSIGNMENT, FIXED ASSET TYPE. Read as abbreviation, as for Figs 3.11, 4.17 and
    5.8, not removal.
41. **6.9–6.10, the two status types:** built as Ch 2 `status_type` rows under two new groups,
    as 6.5's work effort status was, not as two new tables. Both drawn mandatory, built `not
    null`.
42. **Table 6.11, billing after the raise:** the billing rates stop on May 14, 2001 and only
    pay rates go on. Hours after that have no billing rate; the cost query shows the gap.

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

### Fig 6.4
- **`work_effort_type` gains `parent_type_id`** (point 16): the five levels and our JOB
  (point 15) are grouping rows; the kinds of work in Table 6.6 (set up production line, move
  raw materials into place…) are leaves under ACTIVITY or TASK, each with its standard hours.
  An effort typed with a leaf has its level one step up; Chs 2 and 4's efforts keep their
  level rows. Table 6.6's production runs are retyped JOB.
- **`work_effort_association`**: one table for the three subtypes, with
  `work_effort_association_type` as their lookup (BREAKDOWN; DEPENDENCY grouping PRECEDENCY
  and CONCURRENCY), `from_work_effort_id`, `to_work_effort_id` and the usual `from_date` and
  `thru_date` for the book's effective dates. Directions as point 19. An effort linked to
  itself is a check constraint.
- **Checks** (data-quality queries): an association typed with the DEPENDENCY grouping row;
  a cycle in the breakdown; a precedency whose second effort is scheduled to start before
  the first is scheduled to finish.
- **`version_of_work_effort_id`** on `work_effort`, optional ("a version of"); an effort
  that is its own version is a check constraint.
- **Seed:** Table 6.6 with its ids; 51245 as production run #2 (point 17), "1200" as 120001
  (point 18). 28045's scheduled completion becomes Jun 4, as Table 6.6 prints it. Ours: the
  associations' from date (May 15, 2000, the day the run was planned), the dependencies
  (set-up before operating, operating before cleaning, machinery in place before the
  rollers; QA alongside operating), and 120005, a second clean-up that redoes 120003. Bad
  rows: 3454589 drawn as the parent of 28045 (a cycle); 120003 → 120004 typed DEPENDENCY;
  120004 to finish before 120002 starts, though it's scheduled a day later.

### Fig 6.5
- **`work_effort_party_assignment`**: effort, party, `work_effort_role_type`, an optional
  facility, from and thru dates, a comment. The book's key (effort, party, role, from date)
  is a surrogate key here, and overlapping periods for one party in one role on one effort
  are a data-quality query (exact duplicates included).
- **`skill_type`** and **`party_skill`** (years, rating), as drawn. One row per party and
  skill (the book's key) is a data-quality query. A rating scale isn't given; only
  non-negative is enforced.
- **`work_effort_status`**: effort, `status_type_id` from Ch 2's `status_type` under a new
  WORK_EFFORT_STATUS group (as Ch 4 did for orders), and an optional datetime (point 22).
  Checks: a type outside the group, the same status twice for one effort, completed before
  started.
- **Seed:** Tables 6.7–6.9. Bob Jenkins (57), Jane Smith (58) and USA Consulting (59) are
  new; the people's gender isn't given (NOT_DISCLOSED). 39409's parts 29000, 29003, 29005
  and our 29006 (point 23) are tasks under it, and 39409 now runs to Dec 15, 2001. Run #1
  (28045) is in progress, so 6.3a's completion and yield for it (ours) are removed. Bad
  rows: a third John Smith team-member row overlapping both of his; Dick Jones's project
  management twice; 120005 started twice and completed before it started; 51245 given the
  grouping row as a status.

### Fig 6.6
- **WORKER** joins Ch 2's `role_type` under PERSON_ROLE, and EMPLOYEE and CONTRACTOR move
  under it, so `role_type_ancestor` answers "is this role a worker?".
- **`timesheet`**: a `party_role_id` (the worker's role), from and thru dates (thru
  exclusive, as everywhere), a comment. That the role is a WORKER is a data-quality query.
- **`time_entry`**: timesheet, work effort, from and thru datetimes, hours, a comment. Thru
  after from is a check constraint. Checks: an entry outside its timesheet's period, and
  more hours than the entry's span holds.
- **`timesheet_role`** and **`timesheet_role_type`** (APPROVER, ENTERED_BY: ours, the book
  draws no rows). A worker approving their own timesheet is a check.
- **Assignments stay as 6.5 built them** (point 25): thru date optional.
- **Seed:** Table 6.10 with its ids. Dick Jones and John Smith become employees of ABC
  Manufacturing (party roles 81 and 82, dates ours). Entries printed as days run midnight to
  midnight. 294395, the goals session, is an activity outside the plan. Ours: the timesheet
  roles. Bad rows: timesheet 1500 on ACME's placing-customer role; an entry on 1450 dated
  after the sheet; 30 hours in one day on 1200; Dick Jones approving his own sheet. A review
  query lists time with no covering assignment (point 24): John Smith's goals session and
  his Feb 16–Mar 1 interviews.

### Fig 6.7
- **`rate_type`** (regular and overtime, billing and pay), a lookup.
- **`position_type`**, ahead of Ch 9 (point 30): only the id and description drawn here.
- **Three rate tables, one shape:** `position_type_rate`, `party_rate` and
  `work_effort_assignment_rate`, each with its owner, a rate type, from and thru dates
  (exclusive thru) and the rate. The rate is drawn optional; built `not null`, since a rate
  row without a rate says nothing. Surrogate keys; two rates of one type in force at once
  for the same owner is a check across all three, and an assignment rate outside its
  assignment's dates is another.
- **Which rate wins** is a query, not a column (point 29): the cost query takes the
  assignment's rate, else the party's. Position rates can't join in until Ch 9 ties a party
  to a position.
- **Seed:** Table 6.11 on Gary Smith's assignment (100) to the accounting program (40100),
  both ours, as are his employee role (83), the position types and rates, two party rates
  (Gary Smith's billing rate, USA Consulting's fee) and his May 2001 time. After the raise
  the cost query falls back to his party billing rate, since the assignment's billing rates
  stop on May 14 (point 42). Bad rows: an overtime pay rate overlapping both of his, and a
  billing rate from before his assignment.

### Fig 6.8
- **`work_effort_inventory_assignment`**: work effort, inventory item, an optional quantity
  (positive). Surrogate key; the book's key (item and effort) is a check, and so is a
  serialized item used in any quantity but one.
- **No trigger lowers quantity on hand**: the text leaves depletion to a business process.
  Ch 5's balance query is left as it was; use belongs in it once the overview agrees.
- **Seed:** Table 6.12 on "Assemble pencil components" (41001), part of a pencil job
  (41000, ours) with "Label pencils" (41002, Table 6.15's). New raw materials: pencil
  cartridges (24) and labels (25); erasers are Ch 5's (21). Stock items 30–32 at the pen
  plant, quantities ours. Bad rows: erasers twice on 41001; Ch 3's serialized copier used
  three times on the sample-pen research task.

### Fig 6.9
- **FIXED ASSET's subtypes are type rows:** Ch 5's `fixed_asset_type` gains a parent, and
  PROPERTY, VEHICLE, EQUIPMENT and OTHER_FIXED_ASSET are its top rows; Table 6.14 nests
  below them. Text ids as in Ch 5, the book's numbers in seed comments.
- **`fixed_asset`** gains a description and `capacity_uom_id` (Ch 3's unit of measure). A
  capacity with no unit is a check.
- **`work_effort_fixed_asset_assignment`**: effort, asset, a status (Ch 2's `status_type`
  under a WORK_EFFORT_ASSET_ASSIGN_STATUS group, point 41), from and thru dates, allocated
  cost, comment. Surrogate key (point 31). Checks: one asset on two efforts at overlapping
  times, and a status from outside the group. A review lists bookings outside their effort's
  schedule (point 34).
- **Seed:** Tables 6.13–6.15 with the book's asset ids. The engraving machine 5025 becomes a
  pen-making machine measured in pens an hour; Ch 5's trucks stay VEHICLE, since Ch 5's
  queries test that type by name. "Test database tool" (41100) and Office laptop #2 (3002)
  are ours to number. Statuses and costs ours. Bad rows: Fork lift #26 with a capacity and
  no unit; the labeler requested for 41001 while booked on 41002; a work effort status
  (STARTED) on a booking.

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
