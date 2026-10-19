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

## Submodels (proposed 2026-10-19, Figs 6.1–6.6 shared so far)
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

### Points to discuss after the overview (Figs 6.1–6.6)
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
