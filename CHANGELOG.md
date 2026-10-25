# Changelog

One entry per working session, newest first. Each entry covers what was studied, what was built,
and any decisions made.

## 2026-10-25

**Built**
- A question round (seven planned, Q1–Q3 asked so far), logged in the Ch 3, Ch 4 and Ch 2
  logs. Q1 Pedalia (Ch 3): frame size SELECTABLE, the €15 factory-fitted kickstand a feature,
  the shelved bell a product, all cold on a later day: feature and PRODUCT rows 3 → 4. Q2
  order 31 (Ch 4): END_USER for one party with two hats and split across two parties, the
  billing address on the order, cold: roles and wheres 3 → 4. Q3 FitZone (Ch 2): one case,
  event roles and work efforts on the event cold; a one-call clerk made a case stakeholder,
  how the case ends (status, no thru) not given (3).
- Taught in chat: events and cases carry no effectivity (a fact holds from/thru; an event
  happens, with timestamps; a case is a process with a status).
- Ch 2 tracker fixed: the case and event-role rows hadn't taken 10-21's scores (case 3,
  event roles 4).

**Decisions**
- None.

**Next**
- The round's Q4–Q7, sent as text for the user to answer offline (wording and key in the Ch 3 and Ch 2 logs, 2026-10-25): category rollup (Ch 3), the costs of generic relationships (Ch 2),
  feature prices on top of the base (Ch 3), `good_kind` (Ch 3). Then Ch 4 orders: the line
  and its children, Create, the scenario and the doc entry; Ch 2: retest how a case ends.

## 2026-10-24

**Built**
- A question round, logged in the Ch 4 and Ch 3 logs. Ch 4 orders, R1 (purchase order 9,
  Acme buys from Paperco): all five order hats right cold, the keyer kept off PLACED_BY,
  ENTERED_BY's name forgotten; roles row 2 → 3.
- Ch 3 associations, Spokes' Tourer: five COMPONENT rows (Q2) and the explosion, 768 spokes
  and 48 bearings (Q3), both cold, multiplied down; BOM row 1 → 3, `good_kind` left. Before
  Q2, "not sold but part of something = feature" (the 10-19 slip back): feature row 3 → 2.
- Taught in chat: the product-or-feature test (sold alone, stocked or worked on → product;
  being sold doesn't decide it); a spare needs no extra row, only a base price; the BOM is the
  recipe, not a build order; a line counts only the price of the product it orders, plus the
  features ordered for it on their own lines.
- A second question round (six questions, Chs 2–4). Q1 Greenleaf (Ch 4): SALESPERSON 70/30
  on the order and SHIP_TO per line cold, END_USER missed (3). Q2 Paula's mobile (Ch 2):
  exclusive thru cold, effectivity 2 → 3 (4). Q3 Greenleaf compost (Ch 3): SUBSTITUTE row
  dated unprompted (wrong month), why half there; link and direction 2 → 3 (3). Q4 (Ch 4):
  placing e-mail and delivery contact cold, wheres 2 → 3 (4). Q5 Tostado (Ch 3): grind as a
  selectable feature, the shelved valve a product, cold; feature and PRODUCT 2 → 3 (4). Q6
  (Ch 4): two order tables, the doubled children and the trade-off; one order 2 → 3 (3).

**Decisions**
- Question rounds stay inside reviewed material: only submodels past their overview (Ch 4:
  orders only, as of today). Claude offered order adjustments and the user turned it down.

**Next**
- Ch 4 orders: END_USER and the billing address, then Create, the scenario and the doc entry.
  Ch 3: `good_kind`, and the feature-vs-product test cold on a later day (for 4).

## 2026-10-23

**Built**
- Vol 1 Ch 4 overview, points 4–7 and 9 settled. Point 4 taught: what an identifier is (a uniqueness rule, which a
  surrogate key moves to a check query rather than removing), and cardinality.
- Card 10's explode test: S missed the line roles and the contact mechanism tables (the old
  mantra never named the "where"); W right at the core, the costs missing (a party on both
  sides as two rows, one party per job); T right (the price snapshot); D half right (arrows
  drawn parent to child, the association tables skipped, an FK drawn from `order_role` to
  the rules, which are matched on values). New mantra picked.
- Design reference: *Orders, items and order parties* reviewed with the user and revised to
  points 1–9 (lead, a sixth question, core entities on the generic tables, add-ons with the
  role rules, seven design choices, patterns); Core patterns' Ch 4 cells updated (rules as
  rows, typed rows, specific lines as a counter-example, one scoped ROLE TYPE); question
  index row extended. Still a draft until practice.
- Ch 4 submodel 1 practice, started early (the user's call): Q1–Q4 (Remember to Evaluate) and
  three reinforces (the florist, Contoso's laptops, the ops manager's four notes). Tracker:
  the line and rules beside facts at 3; order kind, who and where at 2. Taught: the buyer
  places and the seller takes; a customer's staff is an organization contact, not employment;
  a rule row gives a hat's shape, a check query its count.

**Decisions**
- No `min_count` / `max_count` on `order_role_rule`: cardinality stays in check queries, as
  point 4 settled (the user's call).
- Point 4: kept as read. Order + party + type is the identifier; order + type is a
  per-role-type cardinality rule (one bill-to, many buyers), covered by 4.5's check.
- Point 5: one `role_type` table with a `scope` column for all 18 role-type lookups (Ch 2's
  three included), a scope check per role table; the composite FK noted as the production
  option the simple-keys rule leaves out. Branch a scope out only if it earns an attribute.
- Point 6: item description stays one free-text field on `order_item`; a supplier's own
  wording would belong to Ch 3's supplier product, not the line.
- Point 7: on a purchase order, PLACED_BY and BILL_TO require INTERNAL_ORGANIZATION; SHIP_TO
  has no rule (drop ships pass). A rule tests only the party's own standing role, never a
  relationship; rules carry dates.
- Point 9: neutral role types; one rules table, `order_role_rule` (order kind, role type,
  optional required standing role, dated), beside the facts in `order_role`; two checks.
  Lines get the twin. The orders submodel's points are all settled.
- Composite keys stay out of the repo: the core app enforces its rules in the database, with
  negative tests, and takes the repo's data-quality checks as its spec (TODO, Core app).

**Next**
- Submodel 1 practice: reinforce the hats (placer, taker, salesperson, bill-to) and the
  line's wheres beyond shipping, probe the order kind, then Create, the scenario and the doc
  entry. Then points 10–40 with their entries and cards, and the refactor (its running
  list is in TODO under Ch 4). Watch D's arrow direction (FK from the holder) as a
  candidate trap for card 10.

## 2026-10-22

**Built**
- Vol 1 Ch 4 overview started, on the orders submodel (Figs 4.1–4.5). The user recited
  card 10's mantra first; the explode test waits for the drafts-and-cards step.

**Decisions**
- Point 1: Fig 4.1 stays unbuilt (its failure is structural).
- Point 2: the strict reading. An order item names a product, a feature or neither, never
  both; every feature gets its own line ordered for a product's line.
- Point 3: the bill-to stays optional, the placer fallback stays; revisit at Ch 7 or the
  core app.
- Found under point 4: the generic `order_role` points at `party`, so it skips the column
  version's "set up to be billed" rule. For the refactor: an order role type → required
  standing role type mapping and a check (recorded under point 8).
- Point 8 (taken early): generic all the way. The refactor moves every order onto
  `order_role` and the generic contact-mechanism tables, and card 10 leads with them.

**Next**
- Point 4 (ORDER ROLE's identifier): the user's answers to its three questions, then
  points 5–7 and 9, then card 10's explode test and the rest of the chapter's points.

## 2026-10-21

**Built**
- Random recall across Chs 2–3, ten questions on one Acme story, scored and logged in both
  chapters' logs: case 3, event roles 2 (the old party-role slip, self-caught), specific vs
  generic 2, case vs work effort 4, contact mechanisms 3, role vs classification 3; feature
  interaction 3, category rollup 3, inventory item 3, price components 3, classification 4.
- Side answers in chat: `_kind` (a fixed exclusive split, with or without subtype tables) vs
  `_type` (an open lookup); currency as a unit of measure subtype; one base price row per
  currency; valid time vs bitemporal on the non-solicitation flag.
- Later session: Q11 (substitution direction) 2 → 3, the asymmetry as the why after a
  follow-up; Q12 (Tom the caller) event roles 2 → 4 cold, after the user's pushback; Q13 (the
  CRM, specific vs generic) asked, unanswered.

**Decisions**
- A yes to Claude's read-back counts as done (the user hesitated at a second "done?").
- Grade only what the question asked: Q9 went 3 → 4 after the user's pushback (primary flag
  defaults to false, dates weren't asked).

**Next**
- Q13 (the CRM: which relationship model, and why?) opens the next session; then check that
  event roles hold at 4, and direction's why on the first pass.

## 2026-10-20

**Built**
- Ch 9 (Human Resources) started from the template, with Figs 9.1–9.6 and Tables 9.1–9.5
  (photos), transcribed with 24 points to discuss.
- Fig 9.1 transcribed, not built: the standard emp dept model, the naive model.
- Fig 9.2 built with no table: the `employment_relationship` view over Ch 2's party
  relationship. Mike Johnson (party 70) and Sue Jones (Ch 8's Susan Jones) employed by
  ABC Corporation. One check.
- Fig 9.3 built: `position_type` gains title and benefit percent; `position`,
  `responsibility_type`, `valid_responsibility`, `position_responsibility`. Tables
  9.1–9.2; the 2001 staffing budget 41001 funds the slots; authorization read from the
  budget's status. Two checks.
- Fig 9.4 built: `position_classification_type`, `position_type_class`, the UNION role on
  `position_type`. Table 9.3; Office Workers Union Local 12. Two checks.
- Fig 9.5 built: `position` gains its hiring company and status; `position_fulfillment`.
  Table 9.5 with Mike Johnson's and Sue Jones's slots; slots on a day, held or vacant.
  Two checks and a review.
- Fig 9.6 built: `position_reporting_structure`. Table 9.4 and the 2001 reorganization;
  the chart before and after; a chain of command up the primary lines. One check.
- Cards 39–40, Anki export 55 cards. Design reference: *Positions* and *Employment,
  fulfillment and reporting* drafted, a Ch 9 column in Core patterns with twelve
  examples, two question index rows, roadmap Ch 9 In progress.
- Ch 8's last figures, 8.8–8.12 with Tables 8.11–8.14 (photos), transcribed with points
  25–39.
- Fig 8.8 built: `budget_review` (budget, reviewer, result, date, comment) and
  `budget_review_result_type`. Table 8.11 with Susan Jones and John Smith; 29839's
  statuses, revisions and reviews on one timeline. One check.
- Fig 8.9 built: `budget_scenario`, `budget_scenario_rule` (scenario × item type),
  `budget_scenario_application` (an item or a whole budget; an amount or a percentage).
  Table 8.12; where the plan departs from the rule; the marketing budget under each
  scenario. One check.
- Fig 8.10 built: `order_item.budget_item_id`, `requirement_budget_allocation`,
  `payment_budget_allocation`. Table 8.13's check 2903; the office budget's usage
  (earmarked, committed, paid, left). Two checks.
- Fig 8.11 built: `gl_budget_xref`. Table 8.14 with Salaries expense; the marketing budget
  against the 2001 books by account. One check.
- Fig 8.12, the architecture: How it flows, MAP's Ch 8 section rewritten and ticked, hub
  lines fixed.
- Submodel 4 (budget usage and the ledger) opened; card 37 gains 8.8–8.9, card 38 and the
  Ch 8 architecture card drafted, Anki export 53 cards. Design reference: Budgets revised,
  *Budget usage and the ledger* and *Ch 8 architecture* drafted, Ch 8 examples on eight
  Core patterns rows, a question index row, roadmap.

- Ch 9's second batch, Figs 9.7–9.14 with Tables 9.6–9.12 (photos), transcribed with
  points 25–52; the points list now sits under 9.14.
- Fig 9.7 built: `pay_grade`, `salary_step`; Ch 6's `position_type_rate` gains the
  period and an optional step (amount or step, never both); `pay_history` on the
  employment. Tables 9.6–9.9, 9.8 on Programmer/Analyst; John Smith's ABC Corporation
  employment. Two checks.
- Fig 9.8 built: `benefit_type`, `party_benefit`. Table 9.10. One check.
- Fig 9.9 built: `deduction_type`, `payroll_preference`, `paycheck` (a Ch 7 payment
  subtype), `deduction`. Tables 9.11–9.12, check 1001's net and where it went. Two checks.
- Fig 9.10 built: `employment_application` and its source type; applicants Ana Ruiz, John
  Doe, Lee Wong; Ana Ruiz hired into slot 101. One check.
- Fig 9.11 built: `qualification_type` (degree and certification groups),
  `party_qualification`, `training_class_type`, `person_training`, `resume`; Ch 6's
  `party_skill` gains a started-using date. One check.
- Fig 9.12a built: review item and note types, Ch 3's `rating_type` reused, MANAGER role,
  `performance_review` (+ items, three outcomes), `performance_note`. One check. 9.12b
  transcribed, not built.
- Fig 9.13 built: termination types and reasons, `employment_termination`,
  `unemployment_claim`; Tom Baker and Rita Gomez. One check.
- Fig 9.14 transcribed with its How it flows; MAP.md's Ch 9 rewritten and marked ✓.
- Cards 41–44 and the Ch 9 architecture card, Anki export 60 cards. Design reference:
  four entries and the Ch 9 architecture entry drafted, Ch 9 examples on eleven more
  Core patterns rows, four question index rows, roadmap row extended.
- Ch 3 practice, submodel 5: item 7 (the paper substitute), Q2 (the X200 → X300 successor,
  dated unprompted for the first time) and two digressions (sheets sold in one unit; what a
  successor should carry over). Card 6 gains the EACH vs SHEET lines.
- Ch 4 preview in chat (the user hasn't read the chapter): the story of need → ask → offer →
  order, agreements, and how Chs 2–7 hand over. Two questions answered: why the order line
  copies the price (history, and a deal the list never had) and how an agreement governs a
  line with no link (date, party, item applicability, derived).
- Ch 4 NOTES, Fig 4.16: ending an agreement forward vs back (a retroactive end takes later
  lines out from under it while their prices stay, often the right answer: the discount
  wasn't owed); the stored link is one nullable column, kept honest by the view as a check.
  Point 41 for the overview.
- Ch 2 NOTES, Fig 2.2b: the bitemporal limit of from/thru (valid time only, corrections
  overwrite; recorded time is the other timeline, an audit table the lighter fix).
- Design reference: the Core patterns row "Link entity with from/thru dates" gains
  bitemporal in its title and valid time / recorded time in its meaning. Card P4 renamed to
  match; Anki export 60 cards.

**Decisions**
- Ch 9's second batch makes submodels 3–6: pay and benefits (9.7–9.8), payroll (9.9),
  applications and qualifications (9.10–9.11), performance and termination (9.12a, 9.13).
  9.12b not built (9.14 keeps 9.12a); 9.14 the architecture figure.
- Rate type joins POSITION TYPE RATE's key; Table 9.8 seeded on another type. A paycheck's
  payment holds the gross. EMPLOYMENT's ending is a subtype table on the relationship's
  key, named `employment_termination` since Ch 2's comparison table owns `employment`.
- Ch 9 split into two submodels so far: positions (9.3–9.4), and employment, fulfillment
  and reporting (9.2, 9.5–9.6). 9.1 is the naive model, not built.
- POSITION's hiring company and status built mandatory, as drawn; the status is a current
  value, not a history. Fulfillment points at a person, and job shares are allowed.
- Reviews and scenarios join submodel 3; allocations and the GL xref make submodel 4.
- Built 8.10's order line as a plain column, as drawn, though 8.12 drops it.
- 8.12 draws 8.7a's loop; 8.7b stays built until the overview (point 37). 8.12 settles
  8.3a over 8.3b and standard periods apart from accounting periods.
- OLTP and OLAP split (the user's call): a warehouse card gets a `- **Kind:** OLAP`
  bullet, which the export turns into a `dm::olap` tag and an [OLAP] mark on the front. It
  stays in its usual deck, and Vol 1's deck names stay as they are. Vol 2's industry cards
  will get a new deck of their own.
- Vol 1's warehouse chapters (Ch 10 on) are set aside: after Ch 9 comes Vol 2.
- One core app over Ch 2–9's OLTP models replaces the three mini apps. Vol 2's industry
  types are extra documentation on top; whether they get their own app or versions of the
  core app is open.
- Practice: the user answers in short bits; no grading or next question until they say done
  (CLAUDE.md).
- Bitemporal goes on the existing effectivity row and card, not a new pattern: Silverston
  doesn't model it, so it has no chapter examples of its own.

**Next**
- Ch 8 overview: points 1–39, the doc drafts and cards 35–38 plus the architecture card.
- Ch 9 overview: points 1–52, the doc drafts and cards 39–44 plus the architecture card.
- Then Vol 2: agree on the industry deck before its first card.
- The user to say which overview they meant to cover now (Ch 4's needs the chapter read
  first).
- Re-import the Anki export (P4's back changed; same note id).

## 2026-10-19

**Built**
- Pulled the branch (Chs 4–5 and the workflow tooling from the other machine).
- Ch 6 (Work Effort) started from the template, with Figs 6.1, 6.2, 6.3a and 6.3b and Tables
  6.1–6.5 (photos). All four transcribed into NOTES with "To check against the book" lists and
  14 points to discuss.
- Fig 6.1 built: `requirement_type` (a hierarchy over Ch 4's PRODUCT and WORK) on Ch 4's
  `requirement`; `work_requirement`, a subtype table with optional product, fixed asset and
  deliverable; `deliverable` + type; `fixed_asset` gains acquisition, service dates and capacity.
  Tables 6.1–6.2 seeded with ABC Manufacturing, Inc., the engraved black pen and engraving
  machine 5025; Ch 4's work requirements typed. Seven checks.
- Fig 6.2 built: `requirement_role` gains a comment; four role types from Table 6.3; John
  Smith, Sam Bossman and Dick Jones. Who was responsible on a day; two checks.
- Fig 6.3a built: `work_effort` gains actuals, special terms, a facility and a purpose;
  `work_effort_purpose_type`, `production_run`, `work_requirement_fulfillment`, `order_item_kind`
  and `work_order_item_fulfillment`. Tables 6.4–6.5 seeded; sales order 23500 reaches its work
  by both paths. Three checks. Fig 6.3b transcribed, not built.
- Ponders 1–3 (submodel 1) and 1–5 (submodel 2); ER diagram; cards 22–23, Anki export 35
  cards. Design reference: entries *Work requirements and roles* and *Work effort generation*
  (drafts), Core patterns gains a Ch 6 column and a pattern (need apart from what fills it),
  two question index rows, roadmap Ch 6 In progress.
- Figs 6.4, 6.5 and 6.6 with Tables 6.6–6.10 (photos), transcribed with points 15–27.
- Fig 6.4 built: `work_effort_association` (breakdown, precedency, concurrency as a type
  hierarchy), `version_of_work_effort_id`, and Ch 2's `work_effort_type` gains a parent so the
  levels (plus JOB) group the kinds of work with their standard hours. Table 6.6 seeded; the
  set-up 120001 serves runs #1 and #2. Three checks.
- Fig 6.5 built: `work_effort_party_assignment`, `skill_type` + `party_skill`,
  `work_effort_status` (Ch 2's status types, a new group). Tables 6.7–6.9 with Bob Jenkins,
  Jane Smith and USA Consulting; the plan 39409 gets its parts. Five checks.
- Fig 6.6 built: WORKER over Ch 2's EMPLOYEE and CONTRACTOR, `timesheet`, `time_entry`,
  `timesheet_role` + type. Table 6.10 seeded; a review lists time no assignment covers. Four
  checks.
- Submodels 3 (breakdown) and 4 (assignments and time); ponders 1–3 and 1–4; cards 24–25,
  Anki export 37 cards. Design reference: two draft entries, Ch 6 examples on eight Core
  patterns rows, two question index rows, roadmap "4 submodels so far".
- Figs 6.7–6.13 with Tables 6.11–6.18 (photos), transcribed with points 28–42.
- Fig 6.7 built: `rate_type`, `position_type` (ahead of Ch 9) and three rate tables
  (position type, party, assignment). Table 6.11 on Gary Smith's assignment; a cost query
  takes the assignment's rate, else the party's. Two checks.
- Fig 6.8 built: `work_effort_inventory_assignment`. Table 6.12 on a pencil job's assembly
  task, new raw materials and plant stock. Two checks.
- Fig 6.9 built: `fixed_asset_type` nests under the four subtypes as top rows, capacity
  units, `work_effort_fixed_asset_assignment` with a status group. Tables 6.13–6.15. Three
  checks.
- Fig 6.10 built: `party_fixed_asset_assignment` (active, lost). Table 6.16 with Car #25 and
  Tool set #5. Three checks.
- Fig 6.11 built: what a kind of work repairs or produces (an arc), the type association,
  skill, good and fixed asset standards. Tables 6.17–6.18 on large pencil and pen runs; the
  pencil job is short of labels and erasers. Two checks.
- Fig 6.12 built: inventory and deliverables produced, the repaired asset. One check.
- Fig 6.13, the architecture: How it flows; MAP's Ch 6 section rewritten and marked done,
  hub lines updated.
- Submodels 5 (rates), 6 (inventory and fixed asset assignments) and 7 (standards and
  results); ponders 1–3, 1–3 and 1–4; cards 26–28 and the Ch 6 architecture card, Anki
  export 41 cards. Design reference: three draft entries and the Ch 6 architecture entry,
  Ch 6 examples on twelve Core patterns rows and a new row (general to specific, most
  specific wins), three question index rows, roadmap "7 submodels + architecture".
- Ch 7 (Invoicing) started from the template, with Figs 7.1a, 7.1b, 7.2, 7.3a and 7.3b and
  Tables 7.1–7.6 (photos), transcribed with 12 points to discuss.
- Fig 7.1a built: `invoice` (a SALES/PURCHASE kind), `invoice_item_type` (7.1b's acquiring
  and adjustment sets as the hierarchy's top rows), `invoice_item` with "adjusted by" and
  "sold with". Tables 7.1–7.3; a copier billed by serial number, a discount on its line, the
  book's −2 ream correction on a later bill (30016). Six checks, all fed by bad invoice 30011.
- Fig 7.2 built: billed to and from as lines to PARTY, addressed to and sent from any
  contact mechanism; `invoice_role` + type. Table 7.4 with new addresses and e-mails, each
  with a BILLING purpose. Three checks and a review (30010, neither side ours).
- Fig 7.3a built: `billing_account` (billed at a mechanism), dated `billing_account_role` +
  type, the billed-to arc as a check constraint, a requested bill-to account on Ch 4's
  orders. Tables 7.5–7.6; who owes an account invoice on its date. Five checks.
- Submodels 1 (invoices and items) and 2 (invoice parties and billing accounts); ponders 1–3
  and 1–4; ER diagram; cards 29–30, Anki export 43 cards. Design reference: two draft
  entries, a Ch 7 column in Core patterns with examples on fourteen rows, two question index
  rows, roadmap Ch 7 In progress.
- Figs 7.4–7.10 with Tables 7.7–7.12 (photos, some sent twice), transcribed with points
  13–29; Fig 7.10 settles points 3, 11 and 19 (7.1a, 7.3a and 7.8a kept).
- Fig 7.4 built: `invoice_status` (an INVOICE_STATUS group in Ch 2's status types, no PAID),
  `invoice_term` on Ch 4's shared term types, its arc a check constraint. Tables 7.7–7.8;
  five checks.
- Fig 7.5 built: `shipment_item_billing`; shipments 1235 and 1330 (ours) to Table 7.9's
  intention, a credit billing a shipment line again; unbilled shipments ignore void bills.
  Three checks.
- Fig 7.6 built: `time_entry_billing`, `work_effort_billing` (a percentage); 30017 bills John
  Smith's interview hours and half the project plan. Three checks and a review.
- Fig 7.7 built: `order_item_billing` (quantity, amount); Table 7.10 as our purchases from
  Hartley Accounting (ours), invoices 990023 and 990026. Three checks, one for a line
  billed through both its order and its shipment.
- Fig 7.8a built: `payment` (receipt or disbursement, a method, from and to parties),
  `payment_application` to an invoice or on account (an arc constraint), an
  `invoice_total` view; Table 7.11 and Table 7.12's other payments; outstanding and
  overdue balances. Four checks and a review.
- Fig 7.9 built: `financial_account` (the bank's number as a bigint key, kind + type
  hierarchy), dated `financial_account_role`, `financial_account_transaction` (an amount
  for adjustments only), payments banked; Table 7.12's $917.04 deposit. Five checks.
- Fig 7.10, the architecture: How it flows; MAP's Ch 7 section rewritten and marked done.
- Submodels 3–6 and the architecture; ponders 1–3, 1–4, 1–3, 1–3; cards 31–34 and the Ch 7
  architecture card, Anki export 48 cards. Design reference: four draft entries and the Ch 7
  architecture entry, Ch 7 examples on eleven Core patterns rows, four question index rows,
  roadmap "6 submodels + architecture".
- Ch 8 (Accounting and Budgeting) started from the template, with Figs 8.1, 8.2, 8.3a and
  8.3b and Tables 8.1–8.5 (photos), transcribed with 12 points to discuss.
- Fig 8.1 built: `general_ledger_account` keyed on the account number, its type,
  `organization_gl_account` dated per internal organization, `period_type` and nested
  `accounting_period`. Tables 8.1–8.2 with eight accounts of ours. Three checks.
- Fig 8.2 built: `accounting_transaction_type` holding the book's subtype tree, a class
  view, `accounting_transaction` with from/to parties and one source document. Table 8.3,
  Table 8.5's three, and ABC Subsidiary posting Ch 7's invoice 30002 and payment 12298398;
  Johnson Recycling new. Three checks and a review.
- Fig 8.3a built: `transaction_detail` with a debit/credit flag and the detail it settles.
  Tables 8.4–8.5 and the rest of Table 8.3; open receivables, a trial balance that nets to
  zero. Three checks.
- Fig 8.3b built: `organization_gl_account_balance` for ABC Corporation's 2000 closing,
  statements and profit from it. Two checks.
- Submodels 1 (chart of accounts) and 2 (accounting transactions); ponders 1–3 and 1–5;
  ER diagram; cards 35–36, Anki export 50 cards. Design reference: two draft entries, Core
  patterns gains a Ch 8 column (nine rows) and a pattern (event and its balanced
  postings), two question index rows, roadmap Ch 8 In progress.
- Figs 8.4, 8.5, 8.6 and 8.7 with Tables 8.6–8.10 (photos), transcribed with points 13–24.
- Fig 8.4 built: `organization_gl_account` gains a parent and references to a supplier or
  bill-to customer role, a product category and a product; payables per supplier, sales per
  category and product, ABC Subsidiary's receivables for ACME. Control balances with their
  subsidiaries. Two checks; 8.1's duplicate check now compares what an account tracks.
- Fig 8.5 built: the depreciated fixed asset on `accounting_transaction`,
  `depreciation_method`, `fixed_asset_depreciation_method`; Table 8.6 with the pen engraver
  (new). Three checks and a review.
- Fig 8.6 built: `standard_time_period`, `budget` with operating and capital as type rows,
  nested `budget_item`, `budget_status`, `budget_role`; Tables 8.7–8.9 with three
  departments of ABC Corporation (ours); budgets rolled up the organization. Three checks.
- Fig 8.7b built: `budget_revision`, `budget_revision_impact`; Table 8.10, the marketing
  budget after each revision (65,000 → 53,000 → 51,000). Two checks. 8.7a not built.
- Submodel 3 (budgets); ponders 4–5 (submodel 1) and 1–5 (submodel 3); ER diagram; cards
  35–36 revised, card 37 new, Anki export 51 cards. Design reference: both Ch 8 entries
  revised, a Budgets draft entry, Ch 8 examples on ten Core patterns rows, a question index
  row, the roadmap row.
- Ch 3 cards 8 and 9 rewritten in the user's words (overview step 2), checked against the
  keys; Anki export regenerated (51 cards).
- Ch 3 high-level pass over submodels 4–5 (ten questions, logged with scores): base
  competition and conditions reach 3, estimated cost 2, association direction 2, kit pricing
  3, the BOM 1. Card 6's W and Fig 3.4's NOTES gain the feature-or-product test (the
  engraving talk).
- Ch 3 mixed drill (features, products, associations, categories), items 1–6 logged: the
  bundle's quantities came unprompted (type-only attributes 1 → 2); item 7 left open.

**Decisions**
- Card 8: hook "the price recipe" (the user's "product recipe" would cue card 9's bill of
  materials); discounts and surcharges "stack per unit", the twist on the user's per-line
  slip at the overview. Card 9: package and component stay one COMPONENT type (point 11),
  "dated" kept, "replacement" dropped (it named the successor on 10-17).
- Ch 8: no amount on the accounting transaction, it is worth its debits (Table 8.3's
  $1,200 fits; 39776's $700 against $900 is point 4).
- Ch 8: the subtype tree becomes the top rows of ACCOUNTING TRANSACTION TYPE, with a view
  for each type's subtype; one from party for both "from" lines (point 12).
- Ch 8: 46325's −$300 "receipt" built as a returned-payment disbursement (point 6); the
  detail's account read as mandatory (point 7); the debit/credit flag kept (point 8).
- Ch 8: Figs 8.4 and 8.5 join submodels 1 and 2 instead of making a fourth (point 15), so
  cards 35 and 36 change their figures and their Anki note ids.
- Ch 8: a subsidiary account keeps its parent's GL number (point 14); a revision's amount
  is the signed change, an added item its own row (point 22); 8.7b over 8.7a (point 20).
- Ch 8: 8.3b's balance built beside 8.3a, not instead of it; the overall figure decides
  (point 9).
- Ch 7: Table 7.9's 30002 isn't Table 7.2's, so its links are built to its intention
  with our shipments (point 14); Table 7.10's purchase orders read as ours (point 16).
- Ch 7: no PAID status; balances, deposit amounts and "unbilled" are all computed, never
  stored. Only a bank adjustment carries an amount (point 24).
- Ch 7: a payment application is an invoice or a billing account, exactly one (point 18);
  the financial account keeps the bank's number as its key, a bigint (point 26).
- Ch 7: build 7.1a and 7.2–7.3a, not the alternates 7.1b and 7.3b; their rules become
  checks, and the chapter's overall figure decides (points 3 and 11).
- Ch 7: every invoice item is typed, product lines too (point 1); amount is per unit, so
  Table 7.3's tax fits no clean rate, seeded as printed (point 2).
- Ch 7: billed to stays nullable for the arc with the billing account; billed from is
  mandatory. Table 7.6's text slip (Joe for John) read in the table's favour (point 9).
- Ch 7: John Smith (54) and Jane Smith (58) are Ch 6's people, now also customers; Joe Smith
  and Tom Jones are new. ACME's and ABC Subsidiary's Table 7.4 addresses are new mechanisms
  beside Ch 4's (point 5).
- WORK EFFORT TYPE read as a catalogue of kinds of work (Table 6.6 gives standard hours per
  activity), the levels its grouping rows (point 16); a sixth level, JOB, and the runs
  retyped JOB (points 10 and 15).
- Jane Smith's from date read as Aug 6, 2001, covering John Smith's vacation (point 21); the
  two 29005s split, team-member work seeded as 29006 (point 23).
- Run #1 (28045) is in progress per Table 6.9, so our invented completion and yield for it
  are removed.
- Rates are submodel 5, not part of 4, so card 25's heading stays (point 28).
- The asset links' from date is starred, not hashed: read as a slip, built dated, and the
  real rule (one job or one holder at a time) is the check (point 31).
- Table 6.18's "pencil labeler" added as an asset type, and labeler #1 typed with it (point
  35). Ch 5's trucks stay VEHICLE, since Ch 5's queries test that type by name.
- Fig 6.13 keeps 6.3a's direct order-to-work line (settles point 11); its asset standard on
  FIXED ASSET read as a slip for FIXED ASSET TYPE (point 39).
- Build 6.3a, not 6.3b: it holds both the direct order-to-work path and the path through a
  requirement; the chapter's overall figure decides (point 11).
- REQUIREMENT TYPE drawn mandatory, built nullable: Ch 4's product requirements have no type
  yet; work requirements must have one (a check).
- Table 6.3's impossible dates read as typos (Dec 16, 2000 and Feb 21, 2001); 51298's blank
  requirement read as "same as above".
- Work effort purpose optional; production runs typed PROJECT for want of a level in the book.

**Next**
- Ch 3: open with the drill's item 7 (two 250-sheet packs for a ream: the substitute's
  direction and its quantity), then recall on dates on associations; then the BOM explosion
  walk-through. Practice questions stay inside
  settled material: Chs 4–8 are built, not read.
- Ch 8's remaining figures (budget review, scenarios, usage and sources, the tie to the
  ledger, the overall model) when shared.
- The Ch 4, 5, 6 and 7 overviews (Ch 6: 42 points, Ch 7: 29); then practice, submodel by
  submodel. Re-import the Anki export (51 cards; cards 31–37 and the Ch 7 architecture
  card land in Drafts; delete the old notes of cards 35 and 36, whose ids changed).

## 2026-10-18

**Built**
- Ch 4 (Ordering Products) started from the template, with its first three figures (photos):
  4.1 standard order model, 4.2 orders and order items, 4.3 sales order parties and contact
  mechanisms. All transcribed into NOTES, each with its "To check against the book" list.
- Fig 4.1 transcribed, not built: the book's straw man (twin sales and purchase models), which
  4.2 replaces.
- Fig 4.2 built: `"order"` (quoted, a reserved word) with `order_kind`, `order_item` (line
  number, agreed unit price, for a product or a feature, "ordered for" another item) and
  `sales_order_item` (the customer's PO number). Seed: Table 4.2's order 12560 and seven more.
  Queries: the order as a tree, agreed vs list price, one query for both directions, and six
  data-quality checks, each catching a deliberate bad row.
- Fig 4.3 built: `sales_order` (placed by, taken by, bill-to as party roles; placed using,
  taken via, billed to as contact mechanisms), ship-to on `sales_order_item`, and `order_role`
  with `order_role_type` and percent shares. A new PLACING_CUSTOMER role type, Contoso's St.
  Louis depot, a `contact_mechanism_display_name` helper view. Queries: who placed, took and
  pays (the placer when no bill-to), where each item ships, salespeople's credit, every party on
  an order, and five data-quality checks.
- Ponders 1–3; ER diagram; design reference entry *Orders, items and order parties* (draft),
  Core patterns gains a Ch 4 column and two patterns (specific lines beside a generic role;
  snapshot of an agreed value), a question index row, roadmap Ch 4 In progress. Card 10; Anki
  export 20 cards.
- The data explorer now reads a quoted table name (`create table "order"`).
- Figs 4.4–4.6 (photos), each transcribed with its "To check against the book" list:
  - 4.4 built: `purchase_order` and `purchase_order_item`, the mirror of 4.3; role types
    PLACING_BUYER, BILL_TO_PURCHASER and SHIP_TO_BUYER under a new BUYER grouping; three more
    purchase orders (a drop ship, a wrong hat, a role not yet current) and the clerk's mistake
    on 12567. Queries: who placed, took and pays; where purchase items ship (a drop ship
    labelled); Contoso's orders both ways; four data-quality checks, 4.3's copied.
  - 4.5 built beside 4.3 and 4.4: `order_item_role` (+ type), `order_contact_mechanism` and
    `order_item_contact_mechanism` on Ch 2's purpose types; order 12571 recorded the generic
    way only. Queries: an order from the generic tables, who pays from whichever model holds
    it, item parties no column could hold, and three checks (duplicates, one per order, one
    job in both models).
  - 4.6 built: `order_adjustment` (+ type, the six subtypes on top) and `sales_tax_lookup`.
    Queries: order 12561's bill, every order's value after adjustments, the tax rate per line
    from ship-to boundaries and product categories against the rate charged, four checks.
- Ponders 4–5 (submodel 1) and 1–3 (submodel 2); ER diagram extended. Design reference:
  submodel 1's entry revised for 4.4–4.5, a new *Order adjustments* entry (draft), Core
  patterns gains Ch 4 examples on six rows and a new pattern (typed rows instead of columns),
  a question index row, roadmap "2 submodels so far". Card 10 now Figs 4.1–4.5, card 11 new;
  Anki export 21 cards.
- Card status in the Anki export: each submodel and architecture card reads its status from
  its chapter's STATUS.md (draft until Overview is ticked, reviewed after, done once Doc done
  is ticked), gets a `dm::status::…` tag, and goes to *Drafts* or *Settled* under Submodels or
  Architecture. Today: 4 settled (Ch 2's submodels), 9 drafts. STATUS.md parsing moved from
  `check.js` to a shared `scripts/status.js`.
- Tables 4.3–4.7 (photos, shared after their figures were built): noted under Figs 4.2–4.4.
  Order 12560 gets Table 4.3's date (June 8, 2001) and Table 4.5's parties and addresses;
  purchase order A2395 is seeded as 2395 (Ace Cleaning Service, ABC Retail Store). Table 4.4
  seems to put a feature on its product's own line (point 2); Table 4.7's buyer roles are all
  ABC's (point 7).
- Figs 4.7–4.11 (photos, with Tables 4.9–4.14), each transcribed with its "To check" list:
  - 4.7 built: `order_status` (a dated history, the ORDER_STATUS group in Ch 2's
    `status_type`) and `order_term` on a general `term_type`, each for the order or one
    line; Table 4.9's terms; a cancellation-window query; four checks.
  - 4.8 built: `order_item_association`, FKs on the two item subtypes; Table 4.10's orders
    13480 and 23490; 4.4's drop ship linked; backorders derived beside the status recorded;
    three checks.
  - 4.9 built: `requirement` with two discriminators (customer or internal; product or work),
    `product_requirement`, `desired_feature` on Ch 3's features, dated `requirement_role`,
    `requirement_status`, `order_requirement_commitment` with a quantity; Table 4.11 seeded;
    a query matching needs to catalogue products by feature; five checks. A new Ch 3 feature,
    "Formatted".
  - 4.10 built: `request` (RFI, RFP, RFQ as `request_type` rows), `request_item`,
    `requirement_request`, `request_role`, `responding_party`; Tables 4.12–4.13; two PC
    repair vendors; four checks.
  - 4.11 built: `quote` (issuer and receiver columns, `quote_type` rows), `quote_item`
    (product or work effort under the drawn arc, answering a request item, accepted through
    `order_item.quote_item_id`), `quote_role`, `quote_term` on `term_type`; Table 4.14; a
    box of pencils added to Ch 3's catalogue; the need-to-order trail; three checks.
- Ponders: submodel 3 has 4, submodel 4 has 4, submodel 5 has 3; ER diagram extended. Design
  reference: three draft entries (*Order status, terms and item associations*,
  *Requirements*, *Requests and quotes*), Core patterns gains Ch 4 examples on seven rows and
  a new pattern (status history), three question index rows, roadmap "5 submodels so far".
  Cards 12–14; Anki export 24 cards.
- Table 4.15 (photo, shared after Fig 4.11 was built): the book's quote lines. 35678 quotes
  70 hours of PC repair for the RFP 38967 (relinked from the RFI); 36908 quotes paper and
  Johnson black pens for ACME's RFQ, where the need wants a blue pen. New products PC repair
  (a service, by the hour) and Johnson black pen; Byte Doctors' rival proposal keeps the
  work-effort branch of the arc; the text's central-contact term. The comparison query now
  lists the must-have features a quoted product lacks ("lacks Blue"). Card 14's trap gains
  the pens.
- Figs 4.12–4.13 (photos, with Table 4.16), each transcribed with its "To check" list:
  - 4.12 built: `agreement` with an `agreement_type` hierarchy (PRODUCT over SALES and
    PURCHASE, EMPLOYMENT, OTHER over partnership), an optional link to Ch 2's party
    relationship, `agreement_role` (+ type, the seventh role-type lookup). Table 4.16 seeded,
    with William Jones (ABC Corporation's employee since 1990) and XYZ Corporation;
    Northwind's 2025 sales agreement with Contoso. Three checks, one flagging the book's
    10002 against Ch 2's customer relationship.
  - 4.13 built: `agreement_item` (+ type; nested within one agreement), `addendum` (the
    agreement or one item, the arc), organization, product and geographical applicability.
    Contoso's 70001 outlined with three pricing programs and a sub-agreement; a query finds
    the pricing programs that apply to each sales order line; three checks.
- Submodel 6, *agreements* (Figs 4.12–4.13): ponders 1–5, ER diagram extended, design
  reference entry (draft), Core patterns gains Ch 4 examples on seven rows and a new pattern
  (amendment kept beside the original), a question index row, roadmap "6 submodels so far".
  Card 15; Anki export 25 cards.
- `volumes/v1-all-enterprises/MAP.md`: a one-page map of how Vol 1's chapters connect (the
  chain from need to books, the shapes that repeat, a section per chapter, the hub entities
  and which chapters hang lines on them). Ch 2, Ch 3 and Ch 4 up to Fig 4.13 come from the
  repo (✓); Ch 4's rest and Ch 5–9 are Claude's recall, marked ~ and unverified.
- Figs 4.14–4.17 (photos, with Tables 4.17–4.19; Fig 4.11 and Tables 4.13–4.14 came again
  and match what was built), each transcribed with its "To check" list:
  - Table 4.17 re-seeds 10002's items: item 1 the Johnson bond paper (a pricing program),
    item 2 the diskettes (a section), each limited to its product.
  - 4.14 built: `term_type` becomes a hierarchy under the five term subtypes (legal,
    financial, incentive, threshold, other), with the order and quote term types filed under
    them; `agreement_term` on the agreement or one item, with its own dates. Table 4.18
    seeded, with a new 23884 (Ridgeway's PC repair for ABC Corporation, ours). Two checks;
    one flags the book's own quantity cap, a day past its agreement.
  - 4.15 built: `agreement_pricing_program` as a subtype table, `price_component.agreement_item_id`
    (null = a list price); Table 4.19 on 10002's paper with new Eastern and Western regions
    (the Mississippi split), Contoso's pens at 2.25 in Missouri. Three checks. Ch 3's query
    output is unchanged (compared before and after).
  - 4.16 built as the view `order_item_agreement_item` (which agreement items govern each
    sales line), ACME's three 2002 orders under 10002, and queries for each line's terms,
    agreement price and caps used. Two checks: the price check also caught our own 12562
    pens, sold at list in St. Louis though 70001 says 2.25.
  - 4.17, the overall order model, is the architecture figure: How it flows, points 29–40
    (the list now sits under it), MAP.md's Ch 4 section rewritten and marked whole.
- Submodel 7, *agreement terms and pricing* (Figs 4.14–4.16): ponders 1–5, ER diagram
  extended, design reference entry (draft) and the Ch 4 architecture entry; Core patterns
  gains three patterns (one more optional line, not a parallel entity; child dates inside
  the parent's; derived link instead of a foreign key) and Ch 4 examples on five rows;
  question index and roadmap. Card 16 and the Ch 4 architecture card; Anki export 27 cards.
- The Ch 4 overview started (`/overview`, preconditions clean): point 1 asked, then paused
  when Ch 5's first photos arrived. Fig 4.17 was sent again; it matches the transcription.
- Ch 5 (Shipments) started from the template, with Figs 5.1–5.3 and Tables 5.1–5.7 (photos),
  each transcribed with its "To check against the book" list:
  - 5.1 built: `shipment` (the plan's dates and costs, sender and receiver parties, postal
    addresses, an inquiry mechanism and a receiving number), `shipment_type` as a hierarchy
    with ours/theirs flags, and the view `shipment_end` (whose ends are ours, from Ch 2's
    INTERNAL_ORGANIZATION roles). Table 5.1's eight shipments, General Goods and three
    addresses, our customer return 9600. Four checks: a grouping type, a "transfer" to ACME,
    an address not on file, a plan arriving before it ships.
  - 5.2 built: `shipment_item` (a good or a described content, numbered, in response to
    another line) and `shipment_status` (a SHIPMENT_STATUS group in Ch 2's `status_type`).
    Tables 5.2 and 5.3, Table 5.5's lines, the Jones pencil and the standard eraser. Queries
    for the current status, planned against actual, and returns. Six checks.
  - 5.3 built: `order_shipment` (Ch 4's order lines to shipment lines, with a quantity) and
    `shipment_item_feature`. Tables 5.4–5.7 as ACME's orders 100 and 200 (blue feature lines,
    9000's pens shipped black); ours: purchase order 300, sales order 400, shipment 9500.
    Queries for how each line was filled, lines shared by two orders, orders per shipment
    (derived), unclaimed shipment lines, ordered against shipped features. Five checks.
  - Ch 2–4's data-quality checks catch the same rows as before (compared before and after
    each figure); only their informational queries grew.
- Ponders 1–5 (submodel 1) and 1–4 (submodel 2); ER diagram. Design reference: entries
  *Shipments, items and status* and *Shipments and orders* (drafts), Core patterns gains a
  Ch 5 column (examples on ten rows) and two patterns (item-to-item hand-over with its own
  quantity; plan beside the facts), question index rows, roadmap Ch 5 In progress. Cards 17
  and 18; Anki export 29 cards.
- Fig 5.4 with Table 5.8 (photos), built as submodel 3, *packages and receipts*:
  `shipment_package` (no line to shipment), `packaging_content`, `shipment_receipt` (one
  good counted out of one package, accepted and rejected, stored into an inventory item,
  checked against an order line), `rejection_reason`, `shipment_receipt_role` + type, and
  the view `shipment_package_shipment`. Table 5.8's packages and receipts; ABC's two
  warehouses (Ch 2) and six inventory items (Ch 3). Table 5.8 re-seeds 1146, 1149 and 3485,
  and purchase order 300 is re-planned to match. Queries for the line-by-line receipts,
  package contents, shipped against counted, ordered against shipped and accepted,
  rejections, and stock received. Eight checks.
- Ponders 1–5 (submodel 3); ER diagram. Design reference: entry *Packages and receipts*
  (draft), Core patterns gains a pattern (shortcut line checked against the path) and Ch 5
  examples on six rows, a question index row, roadmap "3 submodels so far". Card 19; Anki
  export 30 cards.
- Figs 5.5–5.8 with Tables 5.9–5.11 (photos), the rest of Ch 5:
  - 5.5 built as submodel 4, *issuances and picklists*: `item_issuance` (from an inventory
    item, for a shipment line or none, by a picklist item), `picklist` + `picklist_item`,
    `item_issuance_role` + type. Table 5.9's issuances and packages; ABC Subsidiary's stock
    (six inventory items, two bins) with opening counts as variances; Rosa Diaz. Queries for
    Table 5.9, picked against issued and packed, each picklist's shipments, the stock ledger,
    who pulled what; seven checks, among them Ch 3's promised qoh = balance. 5.4's
    mixed-package bad row moved to 9400's pencils so each check still catches one row.
  - 5.6 built as the first half of submodel 5: `document` + `document_type` (the eight
    kinds as rows under SHIPPING_DOCUMENT) and `shipping_document` for a shipment, a line or
    a package. Documents all ours; three checks.
  - 5.7 built as the second half: `shipment_route_segment` (a leg, numbered within its
    shipment, facility to facility, estimated beside actual, mileage, fuel),
    `shipment_method_type`, CARRIER as a Ch 2 role type with `carrier_shipment_method`,
    `fixed_asset` + type (VEHICLE, ahead of Ch 8). Tables 5.10–5.11; 9002 seeded as a
    transfer on Truck #1's run with 9000; status times moved to match the trucks. Five
    checks, and a review query showing the shared run counted twice per truck.
  - 5.8 transcribed as the architecture figure (no SQL), with its How it flows; the Vol 1
    MAP's Ch 5 section rewritten from it and marked ✓, the hub table updated.
- Ponders 1–5 for submodels 4 and 5; ER diagram extended. Design reference: entries
  *Issuances and picklists*, *Shipping documents and route segments* (drafts) and *Ch 5
  architecture*; Core patterns gains a pattern (cached balance beside its movements) and
  Ch 5 examples on thirteen rows; three question index rows; roadmap "5 submodels +
  architecture". Cards 20, 21 and the Ch 5 architecture card; Anki export 33 cards.

**Decisions**
- A card joins the morning study loop at its chapter's overview, not when its figures are
  built (the user's call): drafts are Claude's reading, there to look up, kept out of study
  by a Drafts options preset with zero new cards and reviews. Moving a card from Drafts to
  Settled stays a manual step in Anki (re-imports don't move cards; AnkiConnect turned down),
  done at each overview's close. Ch 2's submodel cards count as settled: they were built
  before overviews existed.
- Submodel 1 is *orders, items and order parties* (Figs 4.1–4.5): 4.4 and 4.5 answer its
  questions. Submodel 2 is *order adjustments* (Fig 4.6).
- Readings left for the Ch 4 overview (NOTES, points 1–12): 4.1 not built; an item names a
  product or a feature, not both (no arc drawn); every party line optional, with the bill-to
  falling back to the placer; ORDER ROLE identified by order + party + type; ORDER ROLE TYPE
  kept as its own lookup, though it triggers TODO's ROLE TYPE refactor; PURCHASE ORDER ITEM's
  ITEM DESCRIPTION read as ORDER ITEM's; buyer roles not checked as ours; 4.5 built beside
  4.3/4.4 (like Ch 2's 2.5 and 2.6a); direction-neutral order role types; an adjustment for
  the order or one item, not both; a percentage of the value before any adjustment; the tax
  lookup kept without dates.
- Submodel 3 is *order status, terms and item associations* (Figs 4.7–4.8; 4.7's text derives
  "backordered" from 4.8). Submodel 4 is *requirements* (Fig 4.9). Submodel 5 is *requests
  and quotes* (Figs 4.10–4.11).
- Statuses join Ch 2's shared `status_type` as groups, as Ch 2 foresaw, while each role type
  stays its own lookup (six now): both settle at the overview (points 5, 15).
- Readings left for the overview (NOTES, points 13–22): TERM VALUE optional; status and term
  for the order or one line (Fig 4.11's drawn arcs back it); TERM TYPE shared; the
  association sales-to-purchase only and without a quantity; the requirement's product line
  optional; Table 4.11's "2002" dates read as 2001 and 34988 beside 24905 (Table 4.13 pairs
  them); "owner" of a part; Table 4.12's 23498 read as 2002 and 38967 as an RFP; Table 4.14's
  36908 read as issued in 2002.
- Submodel 6 is *agreements* (Figs 4.12–4.13); later agreement figures may join it.
- Cross-chapter context comes from the short volume map, not from drafting all eight
  chapters ahead (the user's call). CLAUDE.md sends sessions to it for cross-chapter
  questions; `/figures` rewrites a chapter's section from its How it flows at the
  architecture figure. Nothing is built from a ~ line.
- Readings left for the overview (NOTES, points 23–28): Table 4.16's 10002 linked to Ch 2's
  only ACME customer relationship (ABC Subsidiary's) though it names ABC Corporation; the
  agreement subtypes as type rows; an agreement starting while its relationship is current;
  applicability with nothing of a kind meaning no limit; the addendum's arc and dates; an
  item nested only within its own agreement. Point 22 revised by Table 4.15: both quotes
  predate the requests they answer.
- Figs 4.14–4.16 are submodel 7, not part of submodel 6: a different question (what was
  agreed and how it reaches an order), card 15's Anki id stays stable, and submodel 6's five
  ponders were taken (point 29 offers the merge).
- Readings left for the overview (NOTES, points 30–40): the term kinds as TERM TYPE's top
  rows; Table 4.18's dates (23884's none, 10002's cap a day past its agreement); AGREEMENT's
  thru date kept optional; a cap read as cumulative, beside a discount at the same 1,000
  reams; the pricing program as a subtype table, PARTY TYPE kept though not drawn; Ch 3's
  queries reading agreement prices as list prices; Table 4.19's regions split at the
  Mississippi; the order-to-agreement view for sales lines only; 4.17 keeps 4.5's generic
  order parties (answering point 8); the commitment drawn to ORDER; what 4.17 leaves out.
- A child's null thru date runs with its agreement, for terms and agreement prices alike.
- Ch 5's submodels, proposed from Figs 5.1–5.3: *shipments, items and status* (5.1–5.2) and
  *shipments and orders* (5.3, a different question: what a shipment fills). Later figures
  join one or start another.
- Readings left for the overview (Ch 5 NOTES, points 1–16), among them: the shipment
  subtypes as a type hierarchy, with the direction stored as two flags of ours and checked
  against INTERNAL_ORGANIZATION roles; SHIPMENT STATUS kept to one row per type (the book's
  two bars); Table 5.3's 4800 read as 2001; Table 5.5's 9200 line 3 left unclaimed, as
  printed; the text's "same place, same product" built as checks; sales lines on customer
  shipments, purchase lines on purchase shipments, either on a drop ship.
- Fig 5.4 is submodel 3 (packages and receipts), not part of submodel 1: it answers what
  arrived and how much was accepted, a different question. Item issuance, which the text
  under Table 5.8 opens, may join it.
- Table 5.8 wins over our own rows: 1146's and 1149's lines are the book's now, and its
  "4800 (transfer)" is read as 3485 (4800 is Table 5.1's cancelled drop ship). More
  readings for the overview in Ch 5 NOTES, points 17–26: a package's shipment derived from
  its contents, the second 12901 read as 12902, 1146's diskettes in two packages, the
  receipt's order line checked against ORDER SHIPMENT, receipts on incoming shipments only.
- Fig 5.5 is its own submodel 4 (issuances and picklists), not part of submodel 3: stock
  going out answers different questions from stock coming in, and submodel 3's five ponders
  were taken. Figs 5.6–5.7 share submodel 5 (what travels with a shipment and how): 5.6
  alone would be too thin for three hours of practice.
- Fig 5.5's two labels with no line ("issued via", "created to send") are read as
  leftovers, and Fig 5.8, which draws neither line, backs that. Table 5.9's 1,500 packed in
  62002 is read as 1,000; it also confirms 9200's 1,500-pencil line (point 13).
- The qoh check covers only items with a known starting point: a receipt, an issuance or
  an opening count. Ch 3's own items keep variances only and stay out.
- Readings left for the overview (Ch 5 NOTES, points 27–44), among them: issuances only on
  outgoing shipments and from stock at the ship-from address; no arc on a shipping
  document's three lines (at least one, and they agree); the leg's number within its
  shipment; CARRIER as a party role; VEHICLE built ahead of Ch 8; 9002 as ours; 5.8's
  document line drawn the other way, kept as 5.6.

**Next**
- The Ch 5 overview (`/overview`): 44 points, five doc drafts, the architecture entry and
  the cards. Or the Ch 4 overview first, which started at point 1.
- The Ch 4 overview, from point 1 (keep Fig 4.1 unbuilt?): the 40 points, the seven doc
  drafts, the architecture entry and the cards (`/overview`).
- Re-import `docs/cards-anki.txt` in Anki (cards 11–21 and the Ch 4 and Ch 5 architecture
  cards are new; card 10's note id changed with its figures, so delete the old card 10
  note), then the one-time deck setup and moves in TODO.md (Cards).
- Still open from 2026-10-17: the associations walk-through (substitute direction), the pricing
  column review, and the Ch 3 overview discussion.

## 2026-10-17

**Built**
- Status review of every submodel (Ch 2 and Ch 3): all built, drafted and carded; none has
  finished practice; Ch 3 submodels 4–5 untested.
- Housekeeping: the P8 card item ticked in TODO (the card landed 2026-10-16), with the
  doc-alignment half kept open for the overview.
- Ch 3 overview started, book checks first (the user's call): all 11 points to discuss
  settled. Points 1 and 4–9 from the photos, 2, 3, 5 and 10 with the user checking the book,
  11 from the user's photo of the text after 3.10b. Ten kept as read; point 11 changed the SQL.
- Point 11 (Figs 3.9b, 3.10a): the MARKETING_PACKAGE and COMPONENT association rows merged into
  one COMPONENT row. Seed, queries (the component check no longer insists on goods), NOTES,
  card 9, the Anki export and the doc entry follow.
- Fig 2.14 point 1 kept by reasoning: the facility contact mechanism line means CONTACT
  MECHANISM (its labels, and a link entity needs both ends).

**Decisions**
- Design reference roadmap: Ch 2 parties and contact mechanisms set back from Done to In
  progress. STATUS.md was right: their practice (scenarios, the gaps at 2) isn't finished.
- MARKETING PACKAGE is PRODUCT COMPONENT's other name, apt only once PART takes the
  assemblies. We keep no PART (as 3.11), so one link carries kits and BOMs; telling them
  apart is what PART is for.

- Pricing walk-through (submodel 4, Fig 3.7) from the user's own model: price components,
  base-price competition, conditions and how they activate (walk-up trees, plain checks,
  AND). New progress rows for submodel 4 (four at 2, charge kind at 1); parked at the column
  review. Refactor candidates noted in NOTES (point 1), none applied: the user asked for no
  model changes yet.
- Associations walk-through (submodel 5, Fig 3.9b) from the user's own model, one fact at a
  time after a five-fact opener proved too much: the replacement link, the typed table (like
  party relationship), the kit's rows and where its quantity lives. The user's question on kit
  pricing (the parts' prices don't stack; a kit has its own price components) found that the
  seeded starter kit has no price: a refactor candidate in NOTES (point 11), not applied. New
  progress rows for submodel 5 (two at 2, two at 1) and ponder 24. Paused by the user at the
  substitute's direction.

**Next**
- Resume associations at the paper question (substitute direction, a/b/c); then the typed
  table's cost (ponder 20) and the BOM explosion (3.10a). Retest the feature vs product line.
- Resume the pricing column review at the value columns (price, percent); retest base
  competition and activation cold.
- Ch 3 overview, discussion: charge kind on discounts and surcharges (parked), and Fig 2.14's
  bare event. Then drafts and cards feedback, refactor, card pass.
- Re-import `docs/cards-anki.txt` in Anki (card 9 changed).

## 2026-10-16

**Built**
- Hooks and mantras for all six recall cards, written by Claude at the user's request (the
  user first kept card 3, then asked for all). Card 1's mantra patched (the user's call) to
  unpack into party_classification.
- `npm run recall:anki`: exports `docs/recall.md` to an Anki import file (tab-separated, HTML,
  13 cards: 6 submodels and 7 patterns).
- Recall card for the parked postal addresses, facilities and geography submodel (Figs 2.8,
  2.11), hook and mantra by Claude at the user's request. It slots in as Card 3, so the cards
  are renumbered in chapter order (old 3–6 are now 4–7; mentions above use the old numbers).
  The Anki export now reads CRLF checkouts too (14 cards).
- Anki export ready to scale: subdecks *Data Models::Submodels* and *Data Models::Patterns*,
  a stable note id per card (volume, chapter and figures, or pattern number) so renumbering
  no longer duplicates notes, and `v1::ch02` tags. Card headings now carry the volume.
- Ch 3: the last figures shared (3.7 pricing, 3.8 estimated cost, 3.9a/b associations,
  3.10a/b parts, 3.11 overall) and transcribed into NOTES, each with its "To check against
  the book" list. Two more submodels proposed: pricing and costing, associations and parts.
- Ch 3 built: Fig 3.7 pricing (price components on two subtype axes, quantity breaks, order
  values, sale types, currency and time-frequency units, and a "price a line" query), Fig 3.8
  estimated cost (type hierarchy, product-or-feature arc, margin query) and Fig 3.9b product
  associations. Ponders 15–22.
- Ch 3 Fig 3.10a built as Fig 3.11 keeps it: `good.good_kind` (raw material, subassembly,
  finished good) and a COMPONENT association type, with a two-level BOM for the copier, an
  explosion query with a cycle guard and a raw-material-with-components check. 3.10b's PART
  discussed, not built. Ponder 23. The photos confirmed the 3.10–3.11 transcriptions; 3.11 had
  two unnamed lines (manufacturer, unit of measure), now in NOTES and "How it flows".
- Ch 2 Fig 2.14 (overall party model) shared and transcribed as an architecture figure, with
  its "How it flows" and two points to discuss (a stray line, the bare event).
- Recall cards 8 (pricing and costing) and 9 (associations and parts); Anki export 16 cards.
- Design reference doc: drafts for the five Ch 3 submodels, architecture entries for Ch 2 and
  Ch 3, a refreshed study loop, a Ch 3 column and three new rows in Core patterns (rules as
  rows, exclusive arc, catalogue vs physical instance), six question-index rows, Ch 3 In
  progress on the roadmap.
- Design reference doc, Ch 2 catch-up: a draft for postal addresses, facilities and geography
  (with its two pitfalls from item 49, and a roadmap row), and the communication events entry
  regrouped from its "learnt so far" notes into the seven sections ("To verify" kept).
- The other session was told about the new rules; it acknowledged with commit f361f95.
- Deterministic workflow: `npm run check` (`scripts/check.js`) checks each chapter against the
  rules (figures classified and built, cards, doc-draft ticks, ponders, every query runs, every
  data-quality check catches a bad row, Anki export current) and rewrites the generated tables
  in its `STATUS.md`. STATUS.md for Ch 2, Ch 3 and the template; the skills `/figures`,
  `/overview` and `/close-submodel`; `recall.js` and `parseQueries` split out so scripts
  share them. Tested by breaking eight things on purpose: all caught.
- "Recall" renamed to **cards** (the user's call): `docs/cards.md`, `docs/cards-anki.txt`,
  `scripts/cards.js`, `scripts/cards-anki.js`, `npm run cards:anki`, and every mention in
  CLAUDE.md, the skills, the checker, TODO, README and practice.md. Anki note ids are
  unchanged, so importing the new file updates the notes. Entries above keep the old names.
- Pattern card P8 (catalogue vs physical instance), the Core patterns row from Ch 3 that had
  no card.
- **Architecture cards** for Ch 2 (Fig 2.14) and Ch 3 (Fig 3.11) under a new *Deck:
  architecture* in `docs/cards.md`, with S · W · T · D read as hubs, hand-overs, the naive
  mistake and the drawing with lines in from earlier chapters. The Anki export gains a
  *Data Models::Architecture* subdeck (note ids `dm-vN-chNN-arch`; 19 cards), and
  `npm run check` fails a chapter whose "How it flows" has no architecture card and shows it
  on the `A` row. The /figures and /overview skills, CLAUDE.md and the STATUS template say so.

**Decisions**
- `docs/recall.md` stays the source of truth; Anki is a generated copy, re-imported on change.
- Cards follow chapter order; the stable note ids make renumbering safe.
- Cards become part of the workflow (the user's call): one per submodel after its
  walk-through, and a card pass at the end of each chapter (CLAUDE.md).
- Figs 3.7–3.11 accepted as read. The doubtful readings become "points to discuss after the
  overview", and any refactor waits until then. CLAUDE.md now says to always aim for
  Silverston's intention (the user's rule).
- Build 3.9b, not 3.9a (the user's choice). 3.10a vs 3.10b was to wait for the renaming
  passage; superseded below, since 3.10 was built on assumptions under the new rule.
- Workflow reorganised (the user's call), replacing the card rule above: when images arrive,
  Claude builds everything on its own reading, with no confirmation gate. That means the
  transcription, the SQL, a *Draft (assumptions)* doc entry (the five sections the figures can
  answer) and the recall card. The chapter overview collects feedback, drives the refactor and
  holds the card pass. Practice then finishes the doc entry (pitfalls, scenario) and swaps each
  card's Trap for a real mistake. CLAUDE.md, `docs/practice.md` and `docs/recall.md` updated.
- New category, **architecture figures** (the user's call): a chapter's last, overall figure
  gets no SQL, just a short "How it flows" in NOTES and an architecture entry in the doc.
  Ch 3's is written under Fig 3.11.
- Architecture figures get a card too (the user's call, after asking where they were): the
  Map warm-up only chains the chapters, so nothing scheduled the hubs, the plug-ins from
  earlier chapters or the alternates kept.
- `/close-submodel` checks the card against NOTES.md (the user's call): S, D, W, T and the
  mantra against the submodel's transcriptions and design decisions, and the architecture
  card against "How it flows" when it's the chapter's last submodel. NOTES wins unless
  practice proved NOTES wrong. Only the export step is scripted, so the check is Claude's.
- `/overview` runs the same check (the user's call): on the cards a point or a piece of
  feedback touches, as soon as it's agreed, and on every card of the chapter once the
  refactor is finished.
- 3.10 built on assumptions under the new rule (point 11): no separate PRODUCT COMPONENT table,
  since 3.11 has none. Ponder 21's renaming passage may turn it into MARKETING PACKAGE reuse.
- The design reference doc's drafts answer some ponders, so it stays closed during exams,
  like the explorer (`docs/practice.md`). Roadmap uses its existing *In progress* for drafts.
- Steps become fixed procedures (the user's call): skills hold the order, `npm run check` is
  the gate before commits, STATUS.md holds the ticks no script can verify (the claude.ai doc).
  The Stop hook is held back until skipping proves to still happen.

**Next**
- The user re-imports the deck (19 cards, now with the architecture subdeck); mantras that
  fail twice get rewritten in the user's words.
- Card 1 shower question: Laura at the climbing gym, employment or generic relationship?
- Ch 3 overview: the 11 points to discuss (plus Fig 2.14's two), the doc drafts and cards 8–9;
  refactor from the feedback, then practice resumes (walk-throughs for submodels 4 and 5).

## 2026-10-15

**Built**
- `docs/recall.md`: a 30-minute solo morning routine. One card per submodel (hook → mantra →
  hidden key in S · W · T · D shape: spine, why, trap, draw), Leitner boxes, a pattern deck and
  a log. Keys written for the six submodels so far; mantras left for the user.
- Ch 3 submodel 3: a concept session on inventory balances instead of the recall questions
  (the user's choice). Fig 3.6 NOTES now hold our working vocabulary (qoh, balance,
  movements, variance), the two consistency checks, and two discussed alternatives (leave qoh
  alone; two qoh columns).

**Decisions**
- Keep the book's variance convention: quantity_on_hand is updated, and the variance explains why.
- The repo stays the book's: simplify only when first building tables from a figure; after
  that, alternatives are discussed and noted, not adopted.

**Next**
- The user writes the six mantras; check each explodes into its key.
- Recall 1 (K-17 lot recall) when the user says so, then recalls 2–3.
- Ch 5: check receipt / issuance against inventory item; add the qoh = balance check.

## 2026-10-14

**Built**
- Ch 3 submodel 1 reinforce: classification primary flag through the diskettes' rows, then a
  garden-centre rose (2 → 3). Neighbourhood answered; classification and market interest await
  the user's OK to close. Taught the row-to-sentence habit for link tables.
- Ch 3 submodel 2 (product features): mental-model walk-through through the seed, then
  questions (red pen, stapler/duplex, LaserNet, Commuter bike, hose, reels, laptops).
  Applicability 0 → 3, interaction 0 → 3 (dipped to 2 when applicability and interaction were
  mixed up), units of measure 0 → 3. Ponder 9a (the user's question): built-in part as feature
  or product.

**Decisions**
- CLAUDE.md: honesty over flattery, in a light mood (the user's request).
- Overlapping scopes and quantity_on_hand vs variance: the table doesn't record the convention;
  it has to be decided and written down.
- Every tracker row of the three chapters reaches 4 before their mini app starts.
- The user chose to build mental models for submodels 2–3 before finishing submodel 1's reinforce.
- Configuration check order: applicability completes the chosen set (required + standard),
  then interaction rules run on it. Rules are not checked against applicability.
- Two products vs one with a selectable feature: separate barcodes mean separate goods.
- Conversion per product: reel as a product with a Length dimension, or an optional product on
  the conversion (the same local/global trick as interaction).

**Next**
- Submodel 3: both figures walked through. Scores: manufacturer vs supplier 2, reorder 2,
  inventory item 3, location + lot 2, variance 3. Next: the lot question (batch K-17 recall in
  Valencia, asked, unanswered), then reorder and supplier to 3, then neighbourhoods.
- Submodel 2: the neighbourhood question for product_feature (asked, unanswered), OK to close.
- Submodel 1: OK to close classification and market interest; reinforce rollup and good/service.

## 2026-10-12

**Built**
- Ch 2 submodel 3 (communication events and case) reinforce loop for case and work effort,
  explained through the seed, then a fresh scenario (Lucía's leak). Logged in
  `EXERCISES-log.md`; tracker evidence updated. Case stays at 2.
- Ponder item 56 (the user's question): case status has no date; when to keep a status history.
- Ch 2 submodel 2 (contact mechanisms) reinforce: non-solicitation explained through the seed,
  then a gym scenario (shared inbox, one member opts out); neighbourhood of
  `party_contact_mechanism`. Non-solicitation 2 → 3; effectivity stays 2 (thru + 1 day again).
  The parked neighbourhood thread for move vs typo and purpose is closed.
- Ch 3 submodel 1: soft ball (good vs service) and exam Q6 (bookshop coffee). Identification
  2 → 3; classification (primary flag missed a third time), rollup and good/service stay 2.

**Decisions**
- Dating a change to an undated attribute on a link (non-solicitation): end the link and open a
  new one on the same day, carrying its purposes over. Marketing is never a purpose.
- Test for whether an event triggers a work effort: after it, does someone have work to
  schedule and track (date, hours, budget)? The medium doesn't matter.
- Ordering a part can be left out as a work effort (the order itself is Ch 4).

**Next**
- Ch 3 submodel 1 reinforce loop, starting with the primary flag on the classification row.
- Ch 2 contact mechanisms: exercise 3a (asked, unanswered), then the scenario and doc entry;
  then submodel 1 (specific vs generic relationships).
- Lucía round finished (four-event sweep and case roles given on request, no score credit).
  Next: one fresh no-hint question for case → 3, then the submodel 3 practice scenario.

## 2026-10-11

**Built**
- Figs 3.2–3.4 confirmed against the book by the user.
  - 3.3: GOOD IDENTIFICATION links to GOOD, so a `good` subtype table (sharing `product_id`)
    now sits under `good_identification`; service codes removed; a data-quality query checks
    `product_kind` against it (bad row: the maintenance plan).
  - 3.4: the unit of measure is on DIMENSION only and optional; the data-quality query now
    flags units on non-dimensions (bad row: hourly billing).
- Figs 3.5 (suppliers, manufacturers, reorder guidelines) and 3.6 (inventory items, lots,
  containers, variances) transcribed from photos, confirmed, then built with schema, seed
  (bad rows for roles, overlaps, serials, lots, variances), queries, notes and diagram.
- Ch 3 `EXERCISES.md`: submodel 3 (suppliers and inventory) tracker rows, 5 "to ponder" items,
  practice scenario (bike-parts distributor).
- Ch 3 submodel 1 exam Q4 (Analyze) and Q5 (Evaluate): classification and market interest
  reached 3 in Q4; in Q5 classification and rollup fell back to 2 (missed dates + primary on the
  link, read a single parent column backwards). Identification 2 (table names, type vs code).
- Overview of Figs 3.5–3.6 in chat; discussed stored vs computed stock and where stock
  movements come in (Shipments, Work Effort).

**Decisions**
- Primary category stays "one per product": the book doesn't say one per what.
- SELECTABLE set read as "the product's selectable features of one feature type" (the book
  doesn't define it).
- Fig 3.5: FKs go to `organization`; supplier and internal-organization roles are data-quality
  queries. Fig 3.6: inventory subtypes as a kind column + nullable columns; the facility/container
  arc is a check constraint.

**Next**
- Ch 3 submodel 1: exam Q6 (Create), then reinforce the 2s: classification (dates + primary
  on the link), rollup (one parent vs many children), identification (cold recall of
  product → good → good_identification ← identification_type), product (good/service).
- Share the rest of Ch 3's figures.

## 2026-10-10

**Built**
- Vol 1 Ch 3 (Products) started: Figs 3.1–3.4 transcribed, then schema, seed (office-supply
  company with deliberate bad rows), queries, diagram and notes, one commit per figure.
  - 3.1 product (good/service as `product_kind`), life-cycle dates.
  - 3.2 category classification (dated, primary flag), many-to-many rollup with a
    cycle-safe ancestor view, market interest linking Ch 2 party types to categories.
  - 3.3 identification codes as rows, with a regex per identification type (addition).
  - 3.4 features, applicability, interactions (with a configuration check query), units of
    measure and conversions.
- Ch 3 `EXERCISES.md`: two submodels, comprehension tracker, 9 "to ponder" items as the exam
  pool, reinforce menu, and a practice scenario per submodel (bookshop-café, bicycle shop).
- Ch 3 submodel 1 exam, Q1–Q3 (Remember, Understand, Apply): rollup 3; product,
  classification, market interest, identification 2. Logged in `EXERCISES-log.md`.
- Discussed in chat: a classification owned per department (owner party on the link, or
  per-department category types); the user's production category → type → product tree vs
  Silverston's link + rollup; feature applicability vs interaction, global interaction rules and
  how to check them against the catalogue.

**Decisions**
- Figs 3.2–3.4 were built before they were confirmed, at the user's request. The questions for
  the book are listed under each figure and in NOTES "Open questions".
- Surrogate `product_id`; the book's readable product codes are stored as SKU identifications.
- `product.uom_id` added by `alter table` in the 3.4 section so the schema keeps book order.
- No department-owned classification and no primary flag on the rollup for now (the book only
  mentions the first in passing; the second would be our addition).

**Next**
- Check Figs 3.2–3.4 against the book; adjust the SQL if any reading was wrong.
- Share the rest of Ch 3's figures (they may add a third submodel).
- Ch 2 reinforce and scenarios still open.
- The user adds the missing Ch 3 pieces (figure checks, remaining figures) to complete the schema.
- Ch 3 submodel 1: exam Q4–Q6 (Analyze, Evaluate, Create), then reinforce the 2s; the primary
  flag on a temporary category came back in Q3.

## 2026-10-09

**Built**
- Practice process reworked around **submodels** with a **~3 hour budget each**
  (`docs/practice.md`, CLAUDE.md, chapter template): exam of about 6 questions, one at a time,
  climbing Bloom's levels (Remember → Create) → reinforce gaps → one practice scenario per
  submodel → entry in the design reference doc.
- Design reference doc on claude.ai (Universal Data Models — Design Reference): question index,
  Core patterns, one seven-section entry per submodel, roadmap. Party/role/relationship and
  contact mechanism entries drafted; communication event/case is a preview.
- Ch 2 trimmed: tracker regrouped into three submodels with a "Next" column (reinforce / recall);
  unanswered section 0 items and sections 1–9 made optional (only 3a kept); the section 9
  capstone replaced by three per-submodel practice scenarios.

**Decisions**
- About 3 hours of practice per submodel; go over only to close a gap, and agree first.
- At most 5 "To ponder" items per submodel while teaching.
- The design reference doc is the single source of truth for what was learnt; repo files are
  the working material.
- Cover every Vol 1 chapter, including Shipments, Invoicing and Accounting.
- Postal addresses, facilities and geography (Figs 2.8, 2.11) parked until Shipments, by the
  user's choice; Ch 2 submodel 2 is now contact mechanisms only.
- Practice questions name the submodel only, with no concept or table hints.

- Ch 2 mixed recall session (9 questions, vet clinic): event roles, type/fact/rule layers,
  party supertype, relationship direction and contact mechanism subtypes 2 → 3; case 1 → 2.
  Tracker and log updated.

**Next**
- Ch 2 reinforce: specific vs generic relationships (shared-key relationship subtypes, dated
  pay history), non-solicitation on the link, case + work effort (follow-up work decided in an
  event), exclusive thru dates. Then the three practice scenarios.

## 2026-10-08

**Built**
- Ch 2 reinforce loop, questions only. Subtype vs type row: cold retest in a new domain
  (payment methods), 2 → 3, neighbourhood answered, **closed**. Facility question asked, then
  parked at the user's request.
- Communication event (dental clinic video call): first put the participants in party
  relationship; after the role pattern was explained, the role and purpose rows were right.
  1 → 2.
- Communication event, Q4 (VIDEO channel): reuse-a-kind reasoning and the valid-role inserts
  right; kind name (ELECTRONIC_ADDRESS) and event → `contact_mechanism_type` needed showing.
  Said rule rows enforce on insert (they only feed a DQ query). Then switched to explanation
  at the user's request (the whole submodel: what / how / who / why / context / status). Own-words
  definition at the end: 2 → 3, to retest cold.

**Decisions**
- No new "To ponder" items during practice. Questions raised in chat get settled in chat and
  noted in the gaps log.
- A used type is never edited or deleted: retire it or add a new one (the FK already blocks
  deleting a type that rows still use).
- Keep the book's name `valid_contact_mechanism_role` (both its columns are types, but no rename).
- Ask one question at a time; stacked questions lost the user.

**Next**
- Cold retest of communication event (new domain, no hints) to close it; include "does a
  missing valid-role pair block the insert?". Then facility (parked) and the move vs typo
  neighbourhood.

## 2026-10-07

**Built**
- Exercise process in CLAUDE.md: exam → reinforce → capstone, scored on a 0–4 evidence scale.
- Concept tracker: step 0 at the end of each chapter builds a comprehension table with one row
  per concept, each listing the `schema.sql` tables it covers. Added to the chapter template.
  Ch 2's table now maps all of its tables to 19 rows.
- Ch 2 effectivity: 1 → 2 (Contoso rows right except the inclusive thru date; discussed why
  we store exclusive thru dates).
- Data explorer (`npm run explore`, http://localhost:4317). It loads every chapter into an
  in-memory PGlite and lets you browse tables grouped by figure, follow foreign keys in both
  directions ("referenced by"), read rows by label instead of id, and run SQL. Reload resets it.
  `loadChapters` moved into `scripts/db.js`, so the rebuild and the explorer share it.
- Ch 2 reinforce loop: move vs typo 1 → 3 and purpose 2 → 3 (neighbourhood question parked);
  contact mechanism + subtypes 1 → 2; subtype vs type row back to 1 (the gap reappeared: a
  type with no attributes of its own was read as needing its own table, then as having no value).
- Context trimming: the end-of-chapter process moved from CLAUDE.md to `docs/practice.md`
  (CLAUDE.md 9.1 KB → 5.4 KB). Ch 2 `EXERCISES.md` split: tracker and open threads at the top,
  answers and the gaps log in `EXERCISES-log.md`. Templates and README updated. Fixed a junk
  first line in Ch 2 `EXERCISES.md` (a bad regex in b2727e2).

**Decisions**
- Concepts first, implementation later. No long exercise lists that won't get done.
- "Understood" means: what a table or pattern is for, how it relates to its neighbours, and
  spotting a wrong implementation. No attribute-level depth, to avoid overlearning; concepts
  can be revisited later.
- A row below 3 is a gap. Reinforce it in a loop, explaining through the chapter's own schema,
  until the evidence reaches 3 and the user agrees they understand it.
- Before closing a row, ask a short neighbourhood question: which entities it connects to, and
  what each connection means.

**Next**
- Continue going table by table through the contact-mechanism group (next: `contact_mechanism_type`),
  to close subtype vs type row (kind = subtype table, type = category row). Then the parked
  neighbourhood question, the other level-1 rows (facility, communication event), the level-0
  rows, and the capstone.

## 2026-10-06

**Built**
- Ch 2 exercises: warm-up recall (3 questions) and the whole section 0 core set (12 items)
  done. Answers and review notes are recorded in EXERCISES.md.
- Five gaps logged: subtype vs type row (later stated correctly in item 44), the as-of
  condition (especially null `thru_date`), arguing for the generic model without weighing its
  cost, relationship ends (direction and INTERNAL_ORGANIZATION), and reading generic PARTY
  RELATIONSHIP as single-table inheritance.

**Decisions**
- Relationship direction: working rule is to read the type as a sentence, subject → object.
  Not every type is "us → them". Whether this is Silverston's rule is still open (item 27).
- Exercise rules (set by the user): explain the book's reasoning before any pragmatic critique,
  push back plainly when an answer is wrong, and check the schema before claiming how the
  model works.
- The user's question about rules for purpose types is parked on section 6 exercise 4.

**Next**
- Section 3 (Spot the flaw), starting at 3a, then sections 5–6 (queries, breaking the model).
- Then sections 1, 2, 4, 7, 8 and the capstone; recheck the open gaps along the way.

## 2026-10-02

**Built**
- Fig 2.9 Party contact mechanism: `contact_mechanism` supertype with `telecommunications_number`
  and `electronic_address` subtype tables, a `contact_mechanism_type` lookup (with an added
  `applies_to_kind`), and dated `party_contact_mechanism` links carrying the do-not-solicit flag.
- Fig 2.10 Party contact mechanism (expanded): postal address became a third contact-mechanism
  subtype, plus dated purposes per link, a phone extension and an optional role type on the link,
  and `contact_mechanism_link`. Two new data-quality queries (purpose outside its link's period,
  link for a role the party never plays).
- Fig 2.11 Facility versus contact mechanism: `facility` (typed, nesting through `part_of`),
  `facility_role` and `facility_contact_mechanism`. The seed shows a warehouse with two
  addresses and one address shared by two buildings. A recursive query catches facility cycles.
- Fig 2.12 Communication event: participants through `communication_event_role`, several
  purposes per event, a status and a medium on each event, and the `valid_contact_mechanism_role`
  rule table. The relationship is now optional context.
- Fig 2.13 Communication event follow-up: `communication_case` groups events, with its own
  roles and status; `work_effort` (minimal, Ch 6 preview) links to events many-to-many. This was
  the last figure of Ch 2.
- Ch 2 end-of-chapter exercises (sections 1–9) and a 12-question core set for section 0.

**Decisions**
- Fig 2.10 folds the 2.8 address tables in: `postal_address` keys on `contact_mechanism_id` and
  `party_postal_address` is gone. The 2.8 queries now go through contact mechanism.
- Fig 2.11: dates added to facility roles and facility contact mechanisms (the book has none).
- Fig 2.12: the event subtypes became `contact_mechanism_type` rows (FACE_TO_FACE added), and
  event statuses are a group in the shared `status_type`.
- Fig 2.13: CASE is `communication_case` (reserved word); `work_effort_type` added for the
  work-effort subtypes.
- "To ponder" stays small: at most about 3 questions per figure, focused on the pattern. Small
  drift from the book (e.g. `contact_number`) is fine as long as NOTES.md records it.

**Next**
- The user works through the Ch 2 exercises; review them like a PR and record gaps.
- Next session opens with 3 recall questions on Ch 2.
- Then Ch 3 (Products).

## 2026-09-30

**Built**
- Simplified keys across Ch 2 (the user asked for consistency): every table now has a single-column
  primary key and plain foreign keys. The composite keys and composite FKs from 2.2b–2.4
  (`party_kind` pairs, the `role_type_party_kind` table, passport → citizenship) are gone. The
  rules they enforced are now data-quality queries, each with a deliberate bad seed row to catch.
- Fig 2.5 Specific party relationships: `employment`, `customer_relationship` and
  `organization_rollup`, each linking two party roles. They answer "employee of whom?" from 2.4.
- Fig 2.6a Common party relationships: one generic `party_relationship` plus
  `party_relationship_type` (book's single from/to role type), a recursive `role_type_ancestor`
  view, and one hierarchy-aware data-quality query. The 2.5 tables stay for comparison.
- Table 2.5 loaded as seed data (the ABC corporate family), giving the org chart a two-level
  hierarchy. CUSTOMER is now an assignable role type, as the table uses it. Table 2.5 confirmed
  two of the assumed relationship directions (supplier, agent).
- Fig 2.7 Party relationship information: optional priority and status on relationships
  (`priority_type`, a parent-grouped `status_type`), and `communication_event` logged within a
  relationship. Three new data-quality queries (wrong status group, status contradicting dates,
  events outside the relationship period). Timestamps print in UTC.
- Fig 2.8 Postal address information: addresses linked to parties with dates, city/state/postal
  code/country as geographic boundaries nesting through a many-to-many association, a recursive
  `geographic_boundary_ancestor` view, and `country` folded into `geographic_boundary`.

**Decisions**
- Key style: surrogate PKs and plain FKs everywhere. Deviating from the book to simplify is fine
  as long as NOTES.md records it (CLAUDE.md updated).
- `thru_date` is exclusive; the book's inclusive thru dates are stored +1 day (CLAUDE.md updated).

**Next**
- Vol 1, Ch 2: remaining figures after 2.6a (the user sends them), then write the chapter exercises.

## 2026-09-29

**Built**
- Repo skeleton: PGlite-backed scripts (`db:rebuild`, `queries`, `sql`), chapter template,
  gitignored `book-refs/` for figure photos, README, and CLAUDE.md working rules.
- Restructured by volume (`volumes/vN-slug/NN-slug/`) because chapter numbers restart in each
  book. Each volume loads into its own Postgres schema (`v1`, `v2`, `v3`), with `search_path`
  falling back to earlier volumes.
- Added TODO.md (progress and tooling) and this changelog.

**Decisions**
- PGlite instead of Docker/Postgres, since neither is installed. Native tooling is tracked in TODO.md.
- Workflow: one figure at a time. The user photographs it, we transcribe and confirm, discuss,
  then implement. One commit per figure.
- The per-chapter mini-app and ops practice is deferred; the core deliverable is the SQL,
  the diagram, and the notes.

**Studied**
- Vol 1, Ch 2: Fig 2.1 Organization, 2.2a Person (flat), 2.2b Person alternate model,
  2.3 Party, and 2.4 Party roles, each transcribed, confirmed, implemented and committed separately.

**Decisions (Ch 2)**
- Attribute-less organization subtypes are a self-referencing `organization_type` table, not
  one table each.
- The 2.2a table is kept as `person_flat` so both person models can be queried side by side.
- Deviation: PHYSICAL CHARACTERISTIC includes `from_date` in its key (the book draws it as `*`).
- Identifying relationships are kept as composite keys (PASSPORT has a three-column FK to CITIZENSHIP).
- Dates print as `YYYY-MM-DD` (PGlite date parser override).
- 2.3: the 2.2b `person` became the Party subtype. `organization` and `person` now share
  `party_id`, and `party_kind` with composite FKs makes the database enforce exactly one subtype
  per party and classifications that match the party's kind.
- 2.4: roles are a `role_type` hierarchy plus a `role_type_party_kind` pairs table, so the
  database enforces which kind of party may play which role (and that only concrete roles are
  assigned). ROLE TYPE → PARTY ROLE TYPE is deferred as a refactor.

**Decisions (study flow)**
- The user reads a whole chapter first, then shares its diagrams, and Claude builds everything.
- At the end of each chapter, the user practises with small, varied exercises in `EXERCISES.md`
  (redraw from memory, explain why, spot the flaw, extend, queries, break it, trade-offs,
  own-words notes, capstone). No answers are given up front, and gaps found are tracked and revisited.
- Every 3 chapters, a mini app framed as a problem: the user makes the modelling decisions and
  Claude writes the plumbing, with a different JS stack and ops practice each time.

**Next**
- Vol 1, Ch 2: continue with the figures after 2.2b (toward PARTY).
