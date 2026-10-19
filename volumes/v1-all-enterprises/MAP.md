# Vol 1 map: how the chapters connect

Read this first for any question that crosses chapters, then read only the chapter slices it
points to. Every line carries a tag:

- **✓**: built in this repo from the book's figures. The chapter's NOTES hold the detail.
- **~**: Claude's recall of the book, **unverified**. It says where the model is heading, not
  what to build. The book wins: when a chapter's figures land, its section is rewritten from
  its "How it flows" and marked ✓, and any ~ line it contradicts is fixed or dropped.

As of 2026-10-19: Ch 2 to Ch 6 whole.

## The chain

```
          PARTY (Ch 2) ✓                       PRODUCT, GOOD (Ch 3) ✓
   roles, relationships, contact         features, prices, costs,
   mechanisms, facilities, boundaries    inventory items at facilities
                 \                               /
need ─────► ask ─────► offer ─────► commitment ─────► fulfilment ─────► bill ─────► settle ─────► book
REQUIREMENT REQUEST    QUOTE        ORDER, under an   SHIPMENT (goods)  INVOICE     PAYMENT      ACCOUNTING
 4 ✓        4 ✓        4 ✓          AGREEMENT 4 ✓     5 ✓               7 ~         7 ~          TRANSACTION 8 ~
                                                      WORK EFFORT
                                                      (services, production) 6 ✓
people: EMPLOYMENT and POSITION 9 ~, paid by PAYCHECK (a payment) 9 ~, funded by BUDGET ITEM 8 ~
```

Three shapes repeat down the chain:

- **Header + items:** ORDER, REQUEST, QUOTE, AGREEMENT and SHIPMENT with their items ✓;
  INVOICE, ACCOUNTING TRANSACTION (its details) and BUDGET with their items ~.
- **Each header gets** typed rows, a scoped role table, a status history and terms on TERM
  TYPE ✓ (Ch 4). Shipments take the typed rows and the status history, point at parties
  directly and put their scoped roles on receipts and issuances, with no terms ✓ (Ch 5);
  invoices and budgets ~.
- **Hand-overs are item-to-item links with their own quantity:** ORDER REQUIREMENT COMMITMENT
  and ORDER SHIPMENT ✓, and Ch 5's SHIPMENT RECEIPT and ITEM ISSUANCE between a shipment
  and Ch 3's stock ✓; the invoice item BILLING links and PAYMENT APPLICATION ~. That is how
  one order line can ship in parts and be billed in parts. Ch 6's WORK ORDER ITEM FULFILLMENT
  and WORK REQUIREMENT FULFILLMENT are the exception: many to many, no quantity ✓.

## Chapter by chapter

### Ch 2 People and organizations ✓ (Figs 2.1–2.14)
Hub PARTY (person or organization). PARTY ROLE says what a party acts as; PARTY RELATIONSHIP
joins two roles, dated; PARTY CONTACT MECHANISM joins parties to shared mechanisms, with
purposes; FACILITY is a physical place; GEOGRAPHIC BOUNDARY nests places; COMMUNICATION EVENT
and CASE record what was said. WORK EFFORT first shows up at 2.13, as follow-up work.

### Ch 3 Products ✓ (Figs 3.1–3.11)
Hubs PRODUCT (the catalogue idea) and GOOD (what can be held). Categories with market
interest, features with applicability and interactions, units of measure, supplier products,
identification codes, reorder guidelines, INVENTORY ITEM at a facility, PRICE COMPONENT and
ESTIMATED PRODUCT COST (each for a product or a feature), PRODUCT ASSOCIATION.
From Ch 2: ORGANIZATION, PARTY TYPE, FACILITY, GEOGRAPHIC BOUNDARY.

### Ch 4 Ordering products ✓ (Figs 4.1–4.17)
Two hubs, both header + items: ORDER + ORDER ITEM (sales or purchase; each line a snapshot of
product or feature and agreed price) and AGREEMENT + nested AGREEMENT ITEMs (what was agreed
for a period). Need → ask → offer → order: REQUIREMENT → REQUIREMENT REQUEST → REQUEST ITEM →
QUOTE ITEM → the ORDER ITEM accepting it; ORDER REQUIREMENT COMMITMENT back to the need.
Around the order, on it or one item: ORDER ROLE, contact mechanisms by purpose (the overall
model keeps 4.5's generic version over 4.3's columns), ORDER STATUS, ORDER TERM, ORDER
ADJUSTMENT. Around the agreement: AGREEMENT ROLE, the PARTY RELATIONSHIP it formalizes,
AGREEMENT TERM (TERM TYPE, shared with orders and quotes), and Ch 3's PRICE COMPONENTs on its
pricing programs. No line joins order and agreement: an agreement governs a line through its
dates, parties and its items' applicability (product, organization, place), derived (4.16).
From Ch 2: PARTY, PARTY ROLE, PARTY RELATIONSHIP, CONTACT MECHANISM, FACILITY, GEOGRAPHIC
BOUNDARY (tax, applicability, regional prices), WORK EFFORT (quote items). From Ch 3: PRODUCT,
PRODUCT FEATURE, PRODUCT CATEGORY (tax), PRICE COMPONENT.

### Ch 5 Shipments ✓ (Figs 5.1–5.8)
Hub SHIPMENT + SHIPMENT ITEMs (each a GOOD or a description), typed by direction (customer,
purchase, both returns, transfer, drop ship as type rows), from a party and postal address to
a party and postal address, the plan on the header beside a dated SHIPMENT STATUS history.
To orders: ORDER SHIPMENT ties order items to shipment items with a quantity, many to many;
SHIPMENT ITEM FEATURE says which features actually shipped. Handling: PACKAGING CONTENT puts
line quantities into SHIPMENT PACKAGEs (a package's shipment follows from its contents). To
Ch 3's stock: SHIPMENT RECEIPT counts a good out of an incoming package into an INVENTORY
ITEM, accepted or rejected, checked against an order line; ITEM ISSUANCE pulls from an
inventory item for an outgoing line, as a PICKLIST planned; both carry scoped roles, and the
stored quantity on hand must equal their balance. Paperwork: SHIPPING DOCUMENT (a DOCUMENT
with a DOCUMENT TYPE) for the shipment, a line or a package. Travel: SHIPMENT ROUTE SEGMENTs,
facility to facility, by a CARRIER (a party role, with the methods it offers), a SHIPMENT
METHOD TYPE and a VEHICLE, estimates beside actuals. From Ch 2: PARTY, PARTY ROLE, CONTACT
MECHANISM, FACILITY. From Ch 3: GOOD, PRODUCT FEATURE, INVENTORY ITEM. From Ch 4: ORDER ITEM.
From Ch 8, ahead of time: FIXED ASSET (VEHICLE).

### Ch 6 Work effort ✓ (Figs 6.1–6.13)
Two hubs, need and work: WORK REQUIREMENT (Ch 4's REQUIREMENT, work kind, typed; it names a
product, a fixed asset or a deliverable; dated roles) and WORK EFFORT (planned and done, at a
level, program to activity or job, and for a purpose: production run, maintenance, research,
work flow). Work starts from a need (WORK REQUIREMENT FULFILLMENT) or straight from a sold
WORK order line (WORK ORDER ITEM FULFILLMENT; 6.3a kept, 6.3b dropped). WORK EFFORT
ASSOCIATION breaks work down and orders it; a STATUS history. What it takes: PARTY
ASSIGNMENTs (dated, role-typed) priced by rates on a position type, a party or an
assignment; TIME ENTRYs on a WORKER's TIMESHEET; INVENTORY ASSIGNMENT (stock used up); FIXED
ASSET ASSIGNMENT (assets booked, one job at a time); assets also checked out to parties.
What it should take and give: WORK EFFORT TYPE, a catalogue of kinds of work under the
levels, with its own breakdown, standards (skills, goods, asset types, hours) and what it
repairs or produces. Results: stock and deliverables produced, an asset repaired.
From Ch 2: PARTY, PARTY ROLE (WORKER over EMPLOYEE and CONTRACTOR), FACILITY, STATUS TYPE.
From Ch 3: PRODUCT, GOOD, INVENTORY ITEM, UNIT OF MEASURE. From Ch 4: REQUIREMENT, ORDER ITEM.
From Ch 5 (ahead of Ch 8): FIXED ASSET, now typed in a hierarchy. Ahead of Ch 9: POSITION
TYPE. This repo's `work_effort` (Ch 2) is extended, not replaced.

### Ch 7 Invoicing ~
- INVOICE (sales or purchase) + INVOICE ITEM (a product, a feature, or an adjustment or tax
  line, which may adjust another item); billed from and to a party, sent to a contact
  mechanism; INVOICE ROLE, INVOICE STATUS, INVOICE TERM (TERM TYPE again); BILLING ACCOUNT for
  parties billed on account.
- What an item bills, each a link with its own quantity or amount: ORDER ITEM BILLING,
  SHIPMENT ITEM BILLING, WORK EFFORT BILLING, TIME ENTRY BILLING (order adjustments too).
- PAYMENT (a receipt or a disbursement, by a method) and PAYMENT APPLICATION (to an invoice,
  an item or a billing account, in part); FINANCIAL ACCOUNT and its transactions.
- From: PARTY, PARTY ROLE, CONTACT MECHANISM (2); PRODUCT (3); ORDER ITEM, ORDER ADJUSTMENT,
  TERM TYPE (4); SHIPMENT ITEM (5); WORK EFFORT, TIME ENTRY (6).

### Ch 8 Accounting and budgeting ~
- Chart of accounts: GENERAL LEDGER ACCOUNT (asset, liability, equity, revenue, expense), used
  by an internal organization through a dated ORGANIZATION GL ACCOUNT, with balances per
  ACCOUNTING PERIOD (nested: year, quarter, month).
- ACCOUNTING TRANSACTION, internal (depreciation, capitalization, inventory variance) or
  external (obligations from invoices, payments), posted as TRANSACTION DETAILs: debits and
  credits to organization GL accounts.
- Budgets: BUDGET (operating, capital) + BUDGET ITEM over standard time periods, with
  revisions, reviews, roles, statuses and scenarios. Usage comes from allocations of order
  items, requirements and payments to budget items; budget item types map to GL accounts.
- From: PARTY (the internal organization, 2); PRODUCT, INVENTORY ITEM (3); ORDER ITEM,
  REQUIREMENT (4); FIXED ASSET (5, extended in 6); INVOICE, PAYMENT (7).

### Ch 9 Human resources ~
- EMPLOYMENT is Ch 2's party relationship (employee → internal organization), carrying pay
  history, benefits and the reason it ended.
- POSITION (+ type, built ahead in Ch 6 ✓): a slot an internal organization creates, authorized by a BUDGET ITEM (8).
  POSITION FULFILLMENT puts a person in it, dated; positions report to positions; positions
  carry responsibilities.
- Pay: grades and salary steps; PAYCHECK, a Ch 7 PAYMENT, with deductions.
- The person's record: skills (Ch 6's PARTY SKILL), qualifications, résumés, training,
  performance reviews, employment applications.
- From: PARTY, PARTY ROLE, PARTY RELATIONSHIP (2); PAYMENT (7); BUDGET ITEM (8); Ch 4's
  employment AGREEMENT ✓ (Table 4.16 has one) may tie in ~.

## Hubs and who hangs lines on them

| Entity (chapter) | Used by |
|---|---|
| PARTY, PARTY ROLE (2) | 3 suppliers ✓ · 4 orders, requests, quotes, agreements ✓ · 5 shipments (sender, receiver), receipt and issuance roles, carriers ✓ · 6 assignments, rates, skills, timesheets on WORKER roles, assets checked out ✓ · 7 invoices ~ · 8 the internal organization's books ~ · 9 employment ~ |
| PARTY RELATIONSHIP (2) | 2 communication events ✓ · 4 agreements ✓ · 9 employment ~ |
| CONTACT MECHANISM (2) | 4 order and request mechanisms ✓ · 5 ship from and to, inquiries and receiving ✓ · 7 invoice sent to ~ |
| FACILITY (2) | 3 inventory ✓ · 4 requirements ✓ · 5 route segments (from, to; not the shipment itself), stock that issues must sit at the ship-from address ✓ · 6 work and assignments at a place ✓ |
| GEOGRAPHIC BOUNDARY (2) | 3 prices ✓ · 4 sales tax, agreement applicability, regional agreement prices ✓ |
| PRODUCT, FEATURE (3) | 4 order, quote and agreement items, requirements ✓ · 5 shipment items (GOOD), shipped features, receipts ✓ · 6 work requirements and kinds of work that produce a product, goods standards ✓ · 7 invoice items ~ · 8 GL accounts ~ |
| INVENTORY ITEM (3) | 5 issuance and receipt, qoh = their balance ✓ · 6 used up by work, produced by work (no quantity on the link) ✓ · 8 variances ~ |
| PRICE COMPONENT (3) | 4 agreement pricing ✓ |
| ORDER ITEM (4) | 5 ORDER SHIPMENT, receipts checked against it ✓ · 6 WORK lines fulfilled by work efforts ✓ · 7 billing ~ · 8 budget allocation ~ |
| REQUIREMENT (4) | 6 work requirements, fulfilled by work efforts ✓ · 8 budget allocation ~ |
| TERM TYPE (4) | 4 order, quote and agreement terms ✓ · 7 invoice terms ~ |
| DOCUMENT (5) | 5 shipping documents ✓ |
| FIXED ASSET (8, built ahead in 5) | 5 vehicles on route segments ✓ · 6 type hierarchy, capacity unit, booked on work, checked out to parties, repaired by work ✓ · 8 the chapter that defines it ~ |
| WORK EFFORT (2, 4, 6) | 2 case follow-ups ✓ · 4 quote items ✓ · 6 the whole chapter ✓ · 7 billing ~ |
| PAYMENT (7) | 8 accounting transactions ~ · 9 paychecks ~ |
| BUDGET ITEM (8) | 9 positions ~ |

## Keeping it true
- At each chapter's architecture figure, `/figures` rewrites that chapter's section here from
  its How it flows and marks it ✓; fix any hub-table line it contradicts.
- Never build from a ~ line. A figure that disagrees with this map is right, and the map is
  wrong.
