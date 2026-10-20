# Vol 1 map: how the chapters connect

Read this first for any question that crosses chapters, then read only the chapter slices it
points to. Every line carries a tag:

- **✓**: built in this repo from the book's figures. The chapter's NOTES hold the detail.
- **~**: Claude's recall of the book, **unverified**. It says where the model is heading, not
  what to build. The book wins: when a chapter's figures land, its section is rewritten from
  its "How it flows" and marked ✓, and any ~ line it contradicts is fixed or dropped.

As of 2026-10-20: Ch 2 to Ch 9 whole.

## The chain

```
          PARTY (Ch 2) ✓                       PRODUCT, GOOD (Ch 3) ✓
   roles, relationships, contact         features, prices, costs,
   mechanisms, facilities, boundaries    inventory items at facilities
                 \                               /
need ─────► ask ─────► offer ─────► commitment ─────► fulfilment ─────► bill ─────► settle ─────► book
REQUIREMENT REQUEST    QUOTE        ORDER, under an   SHIPMENT (goods)  INVOICE     PAYMENT      ACCOUNTING
 4 ✓        4 ✓        4 ✓          AGREEMENT 4 ✓     5 ✓               7 ✓         7 ✓          TRANSACTION 8 ✓
                                                      WORK EFFORT
                                                      (services, production) 6 ✓
people: EMPLOYMENT and POSITION 9 ✓, paid by PAYCHECK (a payment) 9 ✓, funded by BUDGET ITEM 8 ✓
```

Three shapes repeat down the chain:

- **Header + items:** ORDER, REQUEST, QUOTE, AGREEMENT and SHIPMENT with their items ✓;
  INVOICE ✓ (Ch 7); ACCOUNTING TRANSACTION (its details) and BUDGET with their items ✓ (Ch 8).
- **Each header gets** typed rows, a scoped role table, a status history and terms on TERM
  TYPE ✓ (Ch 4). Shipments take the typed rows and the status history, point at parties
  directly and put their scoped roles on receipts and issuances, with no terms ✓ (Ch 5);
  invoices take all four, with billed to and from as lines, not roles ✓ (Ch 7); budgets take
  typed rows, roles and a status history, plus reviews, revisions and scenarios ✓ (Ch 8).
- **Hand-overs are item-to-item links with their own quantity:** ORDER REQUIREMENT COMMITMENT
  and ORDER SHIPMENT ✓, and Ch 5's SHIPMENT RECEIPT and ITEM ISSUANCE between a shipment
  and Ch 3's stock ✓; ORDER ITEM BILLING and PAYMENT APPLICATION ✓ (Ch 7), while
  SHIPMENT ITEM and TIME ENTRY BILLING bill their line whole, no quantity ✓; REQUIREMENT and
  PAYMENT BUDGET ALLOCATION carry an amount against a budget item ✓ (Ch 8). That is how
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

### Ch 7 Invoicing ✓ (Figs 7.1a–7.10)
Hubs: INVOICE (sales or purchase) and INVOICE ITEM, typed in one hierarchy (what was got:
product, feature, work effort, time entry; adjustments: tax, shipping, fees, discounts),
naming a product, feature or inventory item, with two recursive lines: an adjustment or a
correction points at the line it changes, a feature at the product line it was sold with
(7.1a kept, 7.1b dropped). Billed from a party, to a party or a BILLING ACCOUNT (an arc; the
account has dated payer roles and its own contact mechanism), addressed to and sent from any
contact mechanism, other parties by INVOICE ROLE (7.3a kept, 7.3b's party role subtypes
dropped). A STATUS history (approved, sent, void) and INVOICE TERMs on TERM TYPE, on the bill
or a line. What a line bills reaches back through links: ORDER ITEM BILLING (with quantity),
SHIPMENT ITEM BILLING, WORK EFFORT BILLING (a percentage), TIME ENTRY BILLING. Money: PAYMENT
(receipt or disbursement, from a party to a party, by a method) and PAYMENT APPLICATION to an
invoice or on account to a billing account (7.8a kept, 7.8b's per-line application dropped);
payments are banked as FINANCIAL ACCOUNT TRANSACTIONs (a deposit gathers receipts, a
withdrawal clears one check, adjustments for fees) on FINANCIAL ACCOUNTs held by parties in
dated roles.
From Ch 2: PARTY, CONTACT MECHANISM (with its BILLING purpose), STATUS TYPE. From Ch 3:
PRODUCT, PRODUCT FEATURE, INVENTORY ITEM. From Ch 4: ORDER ITEM, TERM TYPE, and the orders
gain a requested bill-to account. From Ch 5: SHIPMENT ITEM. From Ch 6: WORK EFFORT, TIME
ENTRY. Ahead: Ch 8 turns invoices and payments into accounting transactions.

### Ch 8 Accounting and budgeting ✓ (Figs 8.1–8.12)
Two hubs. Accounting: an internal organization switches chart accounts (GENERAL LEDGER
ACCOUNT, typed asset to expense) on through a dated ORGANIZATION GL ACCOUNT, broken down by
subsidiary accounts about a supplier, customer, product or category, and cuts its time into
nested ACCOUNTING PERIODs. Every business event is an ACCOUNTING TRANSACTION, internal
(depreciation of a FIXED ASSET, variances) or external (invoices, payments, from a party to a
party), typed and tied to its source, posted as balanced TRANSACTION DETAILs (debit or
credit, a credit settling a debit) to organization accounts (8.3a kept; 8.3b's stored
balances an add-on). Budgeting: a BUDGET (operating, capital) for a party (BUDGET ROLE) over
a STANDARD TIME PERIOD, of nested BUDGET ITEMs with purpose and justification; STATUS and
REVIEW record its approval, REVISIONs and their IMPACTs its changes (8.7b built; 8.12 draws
8.7a's loop, to settle), SCENARIO RULEs and APPLICATIONs its what-ifs. Requirements earmark,
order items commit and payments spend against budget items; GL BUDGET XREF maps budget
item types to GL accounts, with a share.
From Ch 2: PARTY, PARTY ROLE (internal organization, supplier, bill-to customer), STATUS
TYPE, the organization rollup. From Ch 3: PRODUCT, PRODUCT CATEGORY. From Ch 4: ORDER ITEM,
REQUIREMENT. From Ch 5: INVENTORY ITEM VARIANCE, FIXED ASSET (extended in Ch 6). From Ch 7:
INVOICE, PAYMENT. Ahead: Ch 9's positions are authorized by budget items, paychecks are
payments.

### Ch 9 Human resources ✓ (Figs 9.1–9.14)
Two hubs: EMPLOYMENT (Ch 2's party relationship, internal organization role to employee
role) for the deal with the person, and POSITION, a slot in a hiring organization, funded
by a BUDGET ITEM and typed by POSITION TYPE. The type carries valid responsibilities, dated
classes, a union and a pay band (POSITION TYPE RATE: an amount, or a SALARY STEP of a PAY
GRADE); the slot carries responsibilities and a current status. A PERSON applies
(EMPLOYMENT APPLICATION, for a slot or any job), backed by skills, qualifications,
training and resumes; hiring opens an EMPLOYMENT and a POSITION FULFILLMENT, and slots
report to slots (one primary line). PAY HISTORY and PARTY BENEFIT hang on the employment;
PAYROLL PREFERENCEs (employee and hiring firm) split pay and withhold; a PAYCHECK is a
PAYMENT with DEDUCTIONs. PERFORMANCE REVIEWs and NOTES go to the EMPLOYEE role from a
MANAGER and can set pay, pay a bonus or lead to a slot; an employment ends with a type, a
reason and any UNEMPLOYMENT CLAIM. 9.12a kept over 9.12b (reviews as communication event
purposes); 9.1's EMP and DEPT is the naive model replaced.
From Ch 2: PARTY, PERSON, ORGANIZATION, PARTY ROLE, PARTY RELATIONSHIP, STATUS TYPE. From
Ch 3: RATING TYPE. From Ch 6: POSITION TYPE, RATE TYPE, POSITION TYPE RATE, PARTY SKILL (all
extended). From Ch 7: PAYMENT, PAYMENT METHOD TYPE. From Ch 8: BUDGET ITEM, PERIOD TYPE.

## Hubs and who hangs lines on them

| Entity (chapter) | Used by |
|---|---|
| PARTY, PARTY ROLE (2) | 3 suppliers ✓ · 4 orders, requests, quotes, agreements ✓ · 5 shipments (sender, receiver), receipt and issuance roles, carriers ✓ · 6 assignments, rates, skills, timesheets on WORKER roles, assets checked out ✓ · 7 billed to and from, invoice, billing account and financial account roles, payors and receivers ✓ · 8 the internal organization's books, subsidiary accounts by supplier and customer, budget roles and reviewers ✓ · 9 employee, internal organization and manager roles (payroll preferences, paychecks, reviews, notes), unions; persons apply, train and fill slots; parties hold skills and qualifications ✓ |
| PARTY RELATIONSHIP (2) | 2 communication events ✓ · 4 agreements ✓ · 9 EMPLOYMENT, carrying pay history, benefits, termination and claims ✓ |
| CONTACT MECHANISM (2) | 4 order and request mechanisms ✓ · 5 ship from and to, inquiries and receiving ✓ · 7 invoices addressed to and sent from, billing accounts billed at ✓ |
| FACILITY (2) | 3 inventory ✓ · 4 requirements ✓ · 5 route segments (from, to; not the shipment itself), stock that issues must sit at the ship-from address ✓ · 6 work and assignments at a place ✓ |
| GEOGRAPHIC BOUNDARY (2) | 3 prices ✓ · 4 sales tax, agreement applicability, regional agreement prices ✓ |
| PRODUCT, FEATURE (3) | 4 order, quote and agreement items, requirements ✓ · 5 shipment items (GOOD), shipped features, receipts ✓ · 6 work requirements and kinds of work that produce a product, goods standards ✓ · 7 invoice items ✓ · 8 subsidiary GL accounts by product and category ✓ |
| INVENTORY ITEM (3) | 5 issuance and receipt, qoh = their balance ✓ · 6 used up by work, produced by work (no quantity on the link) ✓ · 7 a serialized item billed ✓ · 8 variances posted as accounting transactions ✓ |
| PRICE COMPONENT (3) | 4 agreement pricing ✓ |
| RATING TYPE (3) | 3 supplier ratings ✓ · 9 performance review items ✓ |
| ORDER ITEM (4) | 5 ORDER SHIPMENT, receipts checked against it ✓ · 6 WORK lines fulfilled by work efforts ✓ · 7 ORDER ITEM BILLING, with a quantity ✓ · 8 allocated to a budget item ✓ |
| REQUIREMENT (4) | 6 work requirements, fulfilled by work efforts ✓ · 8 budget allocation ✓ |
| TERM TYPE (4) | 4 order, quote and agreement terms ✓ · 7 invoice terms ✓ |
| DOCUMENT (5) | 5 shipping documents ✓ |
| FIXED ASSET (8, built ahead in 5) | 5 vehicles on route segments ✓ · 6 type hierarchy, capacity unit, booked on work, checked out to parties, repaired by work ✓ · 8 depreciation transactions and methods ✓ |
| WORK EFFORT (2, 4, 6) | 2 case follow-ups ✓ · 4 quote items ✓ · 6 the whole chapter ✓ · 7 WORK EFFORT BILLING, TIME ENTRY BILLING ✓ |
| SHIPMENT ITEM (5) | 7 SHIPMENT ITEM BILLING ✓ |
| INVOICE, BILLING ACCOUNT (7) | 7 payments applied to them ✓ · 8 accounting transactions ✓ |
| PAYMENT (7) | 7 banked as financial account transactions ✓ · 8 accounting transactions, budget allocations ✓ · 9 paychecks (a disbursement subtype) with deductions, bonuses from reviews ✓ |
| BUDGET ITEM (8) | 9 positions funded and authorized ✓ |
| PERIOD TYPE (8) | 8 accounting and standard time periods ✓ · 9 pay rates, pay history, benefits, payroll preferences ✓ |
| POSITION TYPE, RATE TYPE (6) | 6 work effort rates ✓ · 9 positions, classes, valid responsibilities, unions, pay bands (with a period and a salary step) ✓ |

## Keeping it true
- At each chapter's architecture figure, `/figures` rewrites that chapter's section here from
  its How it flows and marks it ✓; fix any hub-table line it contradicts.
- Never build from a ~ line. A figure that disagrees with this map is right, and the map is
  wrong.
