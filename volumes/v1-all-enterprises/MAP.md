# Vol 1 map: how the chapters connect

Read this first for any question that crosses chapters, then read only the chapter slices it
points to. Every line carries a tag:

- **✓**: built in this repo from the book's figures. The chapter's NOTES hold the detail.
- **~**: Claude's recall of the book, **unverified**. It says where the model is heading, not
  what to build. The book wins: when a chapter's figures land, its section is rewritten from
  its "How it flows" and marked ✓, and any ~ line it contradicts is fixed or dropped.

As of 2026-10-18: Ch 2, Ch 3 and Ch 4 whole.

## The chain

```
          PARTY (Ch 2) ✓                       PRODUCT, GOOD (Ch 3) ✓
   roles, relationships, contact         features, prices, costs,
   mechanisms, facilities, boundaries    inventory items at facilities
                 \                               /
need ─────► ask ─────► offer ─────► commitment ─────► fulfilment ─────► bill ─────► settle ─────► book
REQUIREMENT REQUEST    QUOTE        ORDER, under an   SHIPMENT (goods)  INVOICE     PAYMENT      ACCOUNTING
 4 ✓        4 ✓        4 ✓          AGREEMENT 4 ✓     5 ~               7 ~         7 ~          TRANSACTION 8 ~
                                                      WORK EFFORT
                                                      (services, production) 6 ~
people: EMPLOYMENT and POSITION 9 ~, paid by PAYCHECK (a payment) 9 ~, funded by BUDGET ITEM 8 ~
```

Three shapes repeat down the chain:

- **Header + items:** ORDER, REQUEST, QUOTE and AGREEMENT with their items ✓; SHIPMENT,
  INVOICE, ACCOUNTING TRANSACTION (its details) and BUDGET with their items ~.
- **Each header gets** typed rows, a scoped role table, a status history and terms on TERM
  TYPE ✓ (Ch 4); shipments, invoices and budgets repeat this ~.
- **Hand-overs are item-to-item links with their own quantity:** ORDER REQUIREMENT COMMITMENT
  ✓; ORDER SHIPMENT, WORK ORDER ITEM FULFILLMENT, the invoice item BILLING links and PAYMENT
  APPLICATION ~. That is how one order line can ship in parts and be billed in parts.

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

### Ch 5 Shipments ~
- SHIPMENT (customer, purchase, transfer, returns, drop ship as types) + SHIPMENT ITEM; shipped
  from and to a party, a facility and a postal address; a status history.
- ORDER SHIPMENT: order item ↔ shipment item with a quantity, many to many (a line shipped in
  parts, a shipment covering several orders).
- Packing and moving: SHIPMENT PACKAGE, PACKAGING CONTENT, SHIPMENT ROUTE SEGMENT (carrier,
  vehicle, from and to facility), shipping documents.
- Stock: ITEM ISSUANCE (an inventory item picked for a shipment item, through picklists) going
  out; SHIPMENT RECEIPT (a package's content received into an inventory item, with
  rejections) coming in. TODO holds the check against Ch 3's INVENTORY ITEM.
- From: PARTY, FACILITY, CONTACT MECHANISM (2); PRODUCT, FEATURE, INVENTORY ITEM (3); ORDER
  ITEM (4).

### Ch 6 Work effort ~
- A work requirement (Ch 4's REQUIREMENT, work kind) is fulfilled by WORK EFFORTs (project,
  phase, activity, task, production run), broken down and sequenced by WORK EFFORT
  ASSOCIATION; a status history.
- WORK ORDER ITEM FULFILLMENT: the order items a work effort fulfils (a sold service, a
  production run for an order).
- Who and what: party assignments (dated, with a role and rates), timesheets and TIME ENTRY,
  inventory consumed, FIXED ASSET assignments (equipment, vehicles, property), the goods and
  skills a type of effort needs, PARTY SKILL, inventory items produced, deliverables.
- From: PARTY, FACILITY, CASE (2); PRODUCT, INVENTORY ITEM (3); REQUIREMENT, ORDER ITEM, QUOTE
  ITEM (4). This repo's `work_effort` (Ch 2) is extended here, not replaced.

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
  REQUIREMENT (4); FIXED ASSET (6); INVOICE, PAYMENT (7).

### Ch 9 Human resources ~
- EMPLOYMENT is Ch 2's party relationship (employee → internal organization), carrying pay
  history, benefits and the reason it ended.
- POSITION (+ type): a slot an internal organization creates, authorized by a BUDGET ITEM (8).
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
| PARTY, PARTY ROLE (2) | 3 suppliers ✓ · 4 orders, requests, quotes, agreements ✓ · 5 shipments ~ · 6 assignments ~ · 7 invoices ~ · 8 the internal organization's books ~ · 9 employment ~ |
| PARTY RELATIONSHIP (2) | 2 communication events ✓ · 4 agreements ✓ · 9 employment ~ |
| CONTACT MECHANISM (2) | 4 order and request mechanisms ✓ · 5 ship from and to ~ · 7 invoice sent to ~ |
| FACILITY (2) | 3 inventory ✓ · 4 requirements ✓ · 5 shipments and routes ~ · 6 work at a place ~ |
| GEOGRAPHIC BOUNDARY (2) | 3 prices ✓ · 4 sales tax, agreement applicability, regional agreement prices ✓ |
| PRODUCT, FEATURE (3) | 4 order, quote and agreement items, requirements ✓ · 5 shipment items ~ · 6 standards ~ · 7 invoice items ~ · 8 GL accounts ~ |
| INVENTORY ITEM (3) | 5 issuance and receipt ~ · 6 consumed and produced ~ · 8 variances ~ |
| PRICE COMPONENT (3) | 4 agreement pricing ✓ |
| ORDER ITEM (4) | 5 shipments ~ · 6 fulfilment ~ · 7 billing ~ · 8 budget allocation ~ |
| REQUIREMENT (4) | 6 work requirements ~ · 8 budget allocation ~ |
| TERM TYPE (4) | 4 order, quote and agreement terms ✓ · 7 invoice terms ~ |
| WORK EFFORT (2, 4, 6) | 2 case follow-ups ✓ · 4 quote items ✓ · 6 the whole chapter ~ · 7 billing ~ |
| PAYMENT (7) | 8 accounting transactions ~ · 9 paychecks ~ |
| BUDGET ITEM (8) | 9 positions ~ |

## Keeping it true
- At each chapter's architecture figure, `/figures` rewrites that chapter's section here from
  its How it flows and marks it ✓; fix any hub-table line it contradicts.
- Never build from a ~ line. A figure that disagrees with this map is right, and the map is
  wrong.
