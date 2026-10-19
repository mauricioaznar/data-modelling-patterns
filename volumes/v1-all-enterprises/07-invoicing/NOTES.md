# Vol 1, Chapter 7 — Invoicing

## The problem this pattern solves
Orders and shipments say what was promised and what went out. The invoice says what is owed,
and it has to stand on its own: it is a legal and accounting document, so a mistake on one is
corrected by a later line, not by editing the bill. The naive model is an `invoice` table
with `customer_id`, `tax_amount`, `freight_charge` and `total`, plus an `invoice_line` with a
`product_id`. It breaks fast. Lines bill things other than products: a feature sold with a
product, a fee, a discount, a serialized machine, hours of work. Every new kind of charge
becomes a new column. One customer pays through several accounts, and one account has
several payers who change over time. An invoice goes to an e-mail address as easily as to a
street. Ch 7 keeps the order's shape (header + items, Ch 4) and its adjustment idea, but
puts the adjustments **on the items**: tax, shipping and fees are invoice items of their own
type, linked to the item they adjust when they adjust one. Parties hang on the invoice by
billed-to and billed-from lines plus a role table, and a BILLING ACCOUNT can stand in for the
party billed.

## Submodels (proposed 2026-10-19, from the first five figures; later figures may add more)
1. **Invoices and invoice items** (Fig 7.1a; 7.1b the alternate): what does this bill
   charge for, line by line: which product, feature or serialized item, how many, at what
   amount, taxable or not? Which lines are tax, shipping, fees or discounts, and which line
   does each adjust or correct? Which feature was sold with which product line?

2. **Invoice parties and billing accounts** (Figs 7.2–7.3a; 7.3b the alternate): who is
   billed and who bills, where the invoice was sent and from where; who else took part
   (entered it, approved it) and when; which account a charge goes to, who pays on that
   account (primary, secondary) and since when, and where that account's bills go?

3. **Invoice status and terms** (Fig 7.4, added 2026-10-19): where is this bill now
   (approved, sent, void) and since when; what are its payment terms, late fees and
   penalties, and which single line carries a term of its own (non-returnable)?

4. **Billing for what was delivered** (Figs 7.5–7.7, added 2026-10-19): which shipment
   lines, time entries, work efforts and order lines does this invoice line charge for, and
   how much of each? What has been delivered, worked or ordered but not billed yet?

5. **Payments** (Fig 7.8a, added 2026-10-19; Fig 7.8b not shared yet): who paid whom, how,
   when and how much; which invoices (or which account, "on account") each payment settles
   and how much of it; what is still outstanding on each invoice?

## Figures

### Fig 7.1a — Invoice and invoice items
**Transcription** (accepted: ☐; photo with Tables 7.1–7.3; open points under "To check
against the book")

```
INVOICE
  # invoice_id
  * invoice_date
  o message
  o description
  subtypes (from 7.2): SALES INVOICE, PURCHASE INVOICE

INVOICE ITEM                      (identified by its invoice + seq id: tilde on "part of")
  # invoice_item_seq_id
  * taxable_flag
  o quantity
  o amount
  o item_description
  subtypes: SALES INVOICE ITEM, PURCHASE INVOICE ITEM
  -> INVOICE                   (many "part of" 1; invoice "composed of" many)
  -> INVOICE ITEM TYPE         (many "described by" 1; type "the description for" many)
  -> PRODUCT                   (dashed: many "the charge for" 1; product "billed via" many)
  -> PRODUCT FEATURE           (dashed: many "the charge for" 1; feature "billed via" many)
  -> INVENTORY ITEM            (dashed: many "the charge for" 1; item "billed via" many)
  -> INVOICE ITEM              (dashed, recursive: "adjusted by" / "the adjustment for")
  -> INVOICE ITEM              (dashed, recursive: "sold with" / "sold for")

INVOICE ITEM TYPE
  # invoice_item_type_id
  * description

PRODUCT (Ch 3's attributes), PRODUCT FEATURE (id, description), INVENTORY ITEM with
SERIALIZED (serial_num) and NON SERIALIZED (quantity_on_hand) as in Ch 3.
```

**Table 7.1, invoices** (id · date · message · description)
- 30002 · May 25, 2001 · · fulfillment of an office supply order
- 30005 · Jun 5, 2001 · "Thanks for the business!" ·

**Table 7.2, invoice items** (invoice · seq · product · feature · sold with · quantity ·
amount · taxable)
- 30002 · 1 · Johnson fine grade 8½ by 11 bond paper · · · 10 · $8.00 · Y
- 30002 · 2 · · product quality, extra glossy finish · 30002 seq 1 · · $2.00 · Y
- 30002 · 3 · Goldstein Elite pens · · · 4 · $12.00 · Y
- 30002 · 4 · HD 3½-inch diskettes · · · 6 · $7.00 · Y

**Table 7.3, adjustment items** (invoice · seq · type · amount · taxable)
- 30002 · 5 · shipping and handling · $16.00 · N
- 30002 · 6 · fee (order processing fee) · $5.00 · N
- 30002 · 7 · tax · $25.65 · N

**To check against the book**
- Is "described by" INVOICE ITEM TYPE solid at the item end? Read as mandatory, which
  Table 7.2 doesn't show: its product lines carry no type column (point 1).
- Which end of "sold with" is which. Read from Table 7.2: the feature line points at the
  product line it was sold with.
- Is the amount per unit or for the line? Table 7.2's amounts match Ch 4's unit prices for
  order 12560 (8, 12 and 7), so read as per unit (point 2).
- Is the INVENTORY ITEM line dashed? Read as optional, like the other two.

**Discussion**
- **Adjustments are items, not columns.** The order model (Ch 4, Fig 4.6) kept adjustments
  in their own table. Here a tax, a shipping charge or a fee is just another INVOICE ITEM
  with its own type. A new kind of charge is a new type row, never a new column on INVOICE.
- **Two recursive lines, two jobs.** "Adjusted by" ties an adjustment (or a correction) to
  the item it changes: a discount on one line, or a later line with quantity −2 that corrects
  a line billed 10 instead of 8. Corrections by a new line, not by editing the bill, keep the
  audit trail. "Sold with" ties a feature line to its product line, so two servers on one
  invoice keep their own features apart.
- **What a line bills is optional three ways** (a product, a feature, a serialized inventory
  item), and the item description covers the one-offs. The type says which is expected.
- **Quantity is optional** because a feature or a fee has only an amount.
- **Taxable flag per line**, not per product: the same product can be taxable on one bill and
  exempt on another (an exempt customer, a resale certificate).
- **The naive model** (`tax_amount`, `freight_charge` on the invoice; one `product_id` per
  line) can't hold a second kind of fee, a discount on one line, or a feature tied to the
  right one of two identical products.

### Fig 7.1b — Invoice and invoice items, alternate model
**Transcription** (accepted: ☐; not built, see STATUS)

```
INVOICE ITEM                      (7.1a's attributes and the sales/purchase subtypes)
  subtypes, second set:
    INVOICE ADJUSTMENT
      o percentage
      subtypes: INVOICE MISCELLANEOUS CHARGE, INVOICE DISCOUNT ADJUSTMENT,
                INVOICE SURCHARGE ADJUSTMENT, INVOICE SALES TAX,
                INVOICE SHIPPING AND HANDLING CHARGE, INVOICE FEE
      -> ADJUSTMENT TYPE       (many "described by" 1; type "the description for" many)
      -> INVOICE ACQUIRING ITEM (dashed: many "the adjustment for" 1; acquiring item
                                 "adjusted by" many)
    INVOICE ACQUIRING ITEM
      subtypes: INVOICE PRODUCT FEATURE ITEM, INVOICE PRODUCT ITEM, INVOICE WORK EFFORT ITEM,
                INVOICE TIME ENTRY ITEM
      INVOICE PRODUCT FEATURE ITEM -> PRODUCT FEATURE ("the charge for" / "billed via")
      INVOICE PRODUCT FEATURE ITEM -> INVOICE PRODUCT ITEM (many "sold for" 1; product item
                                      "sold with" many)
      INVOICE PRODUCT ITEM -> PRODUCT ("the charge for" / "billed via")
  -> INVOICE                   (many "part of" 1; invoice "composed of" many)

ADJUSTMENT TYPE
  # adjustment_type_id
  * description
```

**What it changes**: the two recursive lines become typed lines between subtypes. Only an
adjustment adjusts, and only an acquiring item (what the party actually got) is adjusted.
Only a feature item is sold with, and only a product item. INVOICE ITEM TYPE becomes
ADJUSTMENT TYPE, on adjustments only. An adjustment gains a **percentage** (as Ch 4's order
adjustment had). Work effort and time entry items appear as subtypes, ahead of the billing
figures. The INVENTORY ITEM line is not drawn.

**Not built**: 7.1a is built, with 7.1b's two subtype sets as the top rows of
`invoice_item_type` (ACQUIRING_ITEM and ADJUSTMENT, the leaves under them), which is how Ch 4
held the order adjustments. The rules 7.1b draws as typed lines become checks: only an
adjustment adjusts, only a feature item is sold with a product item. What the overall figure
keeps decides whether percentage joins invoice_item (point 3).

### Fig 7.2 — Invoice parties
**Transcription** (accepted: ☐; photo with Table 7.4)

```
INVOICE                           (7.1a's attributes)
  subtypes: SALES INVOICE, PURCHASE INVOICE
  -> PARTY                     (many "billed to" 1; party "the receiver of" many)
  -> PARTY                     (many "billed from" 1; party "the sender of" many)
  -> CONTACT MECHANISM         (many "addressed to" 1; mechanism "used for billing" many)
  -> CONTACT MECHANISM         (many "sent from" 1; mechanism "used for sending" many)

INVOICE ROLE                      (identified by invoice + party + type: tildes on all three)
  * datetime
  o percentage
  -> INVOICE                   (many "for" 1; invoice "involving" many)
  -> PARTY                     (many "of" 1; party "involved in" many)
  -> INVOICE ROLE TYPE         (many "described by" 1; type "the description of" many)

INVOICE ROLE TYPE                 (no attributes drawn: id and description assumed)
```

**Table 7.4, invoice parties** (invoice · date · billed to · addressed to · sender · sent
from)
- 30002 · May 25, 2001 · ACME Corporation · 123 Main Street · ABC Subsidiary · 100 Bridge
  Street
- 30005 · Jun 5, 2001 · John Smith · jsmith@us.com · ABC Subsidiary · 100 Bridge Street
- 30010 · Jun 5, 2001 · Tom Jones · 1235,678@cis.com · ACME Corporation · acorp@acme.com

**To check against the book**
- Are the four lines solid at the invoice end? Read: billed to and billed from mandatory,
  addressed to and sent from optional (the text says the model must allow any mechanism, not
  that one is always known).
- INVOICE ROLE TYPE has no attributes drawn. Read as id + description, like every other
  role type.
- The text names "sender" and "receiver" as invoice role types, beside the billed from and
  billed to lines (point 6).

**Discussion**
- **Two key parties are lines, the rest are roles.** Billed to and billed from are on every
  invoice, so they're direct lines to PARTY (not PARTY ROLE, unlike Ch 4's Fig 4.3). Anyone
  else (who keyed it in, who approved it) is an INVOICE ROLE row with a type and a datetime:
  the same split as Ch 4's order (lines for the main parties, ORDER ROLE for the rest).
- **Any contact mechanism, not a postal address.** An invoice addressed to an e-mail is as
  normal as one to a street (30005, 30010). The book's own example of a rule worth enforcing:
  an invoice may only go to a mechanism the billed party uses for billing (Ch 2's PARTY
  CONTACT MECHANISM PURPOSE). That's a check here.
- **Who is "us"?** The invoice doesn't say. Sales and purchase are subtypes; 7.3b will draw
  which roles each side plays. 30010 (ACME billing Tom Jones) is neither, from ABC's point of
  view (point 7).

### Fig 7.3a — Billing account
**Transcription** (accepted: ☐; photo with Tables 7.5–7.6)

```
INVOICE                           (7.1a's attributes; sales and purchase subtypes)
  -> PARTY                     } arc: many "billed to" 1; party "billed for" many
  -> BILLING ACCOUNT           }      many "billed to" 1; account "billed for" many
  -> PARTY                     (many "billed from" 1; party "the sender of" many)
  -> CONTACT MECHANISM         (many "addressed to" 1; "the billing mechanism for")
  -> CONTACT MECHANISM         (many "sent from" 1; "used for sending")
  INVOICE ROLE and INVOICE ROLE TYPE as in 7.2

BILLING ACCOUNT
  # billing_account_id
  * from_date
  o thru_date
  o description
  -> CONTACT MECHANISM         (many "billed at" 1; mechanism "the billing mechanism for"
                                many)

BILLING ACCOUNT ROLE              (identified by account + party + type: tildes)
  * from_date
  o thru_date
  -> BILLING ACCOUNT           (many "for" 1; account "used by" many)
  -> PARTY                     (many "an account for" 1; party "associated with" many)
  -> BILLING ACCOUNT ROLE TYPE (many "described by" 1; type "the description of" many)

BILLING ACCOUNT ROLE TYPE         (no attributes drawn)
```

**Table 7.5, billing accounts** (id · from · thru · party · role · mechanism · description)
- 1295 · Apr 15, 2000 · · ACME Corporation · primary payer · 123 Main Street · all charges
  for office supplies
- 1296 · Apr 15, 2000 · · ACME Corporation · primary payer · 123 Main Street · all charges
  for consulting services

**Table 7.6, an account with more than one party** (account · role from · role thru · party
· role type)
- 1459 · Apr 15, 2000 · · Jane Smith · primary payer
- 1459 · Apr 15, 2000 · Jun 15, 2001 · John Smith · secondary payer
- 1459 · Jun 16, 2001 · · Joe Smith · secondary payer

**To check against the book**
- The arc's ends: billed to PARTY or billed to BILLING ACCOUNT, exactly one. The arc crosses
  both lines near INVOICE.
- "Billed at" CONTACT MECHANISM: solid at the account end? The text says the account must be
  related to a mechanism ("all invoices must end up at a location of some sort"). Read as
  mandatory.
- The text opens account 1459 with "Jane and Joe Smith", then has John as the secondary
  payer replaced by Joe; the table has John first (point 9).
- The ROLE's from date is starred, not hashed. Read as not part of the identifier, as with
  the other role tables (point 10).

**Discussion**
- **Bill an account, not a party.** A telecom company bills phone lines grouped into
  accounts; a customer splits office supplies and consulting into two accounts (Table 7.5),
  each with its own mechanism. The invoice goes to the account, and the account says where it
  goes and who pays.
- **Payers change, the account stays.** BILLING ACCOUNT ROLE is dated: Joe replaces John as
  secondary payer on Jun 16, 2001 (Table 7.6), and the account and its history carry on.
  Other role types the text names: customer service representative, manager, sales
  representative.
- **The arc:** an invoice is billed to a party *or* to an account. The account's payers
  answer "who owes", as of the invoice date.
- **Orders too.** If billing accounts are used, the text adds a "with a requested bill to"
  line from Ch 4's orders (Figs 4.3 and 4.5) to BILLING ACCOUNT, in an arc with the party.
  Built on Ch 4's sales and purchase order tables.
- **Cards** (a credit or bank card issued against an account) would be a CARD entity tied to
  the account and the party. Not drawn; not built.

### Fig 7.3b — Invoice specific party roles
**Transcription** (accepted: ☐; not built, see STATUS)

```
INVOICE                           (attributes as 7.1a; INVOICE ROLE and type as in 7.2)
  SALES INVOICE
    -> BILL TO CUSTOMER        } arc: many "billed to" 1; customer "billed for" many
    -> BILLING ACCOUNT         }      many "billed to" 1; account "billed for" many
    -> INTERNAL ORGANIZATION   (many "billed from" 1; org "the sender of" many)
  PURCHASE INVOICE
    -> INTERNAL ORGANIZATION   } arc: many "billed to" 1; org "the receiver of" many
    -> BILLING ACCOUNT         }      many "billed to" 1; account "billed for" many
    -> SUPPLIER                (many "billed from" 1; supplier "the sender of" many)
  -> CONTACT MECHANISM         ("addressed to" / "the billing mechanism for"; "sent from" /
                                "used for billing", as in 7.3a)

PARTY ROLE                        (Ch 2's) with BILL TO CUSTOMER, INTERNAL ORGANIZATION,
                                  SUPPLIER; PARTY "acting as" PARTY ROLE

BILLING ACCOUNT ROLE              (from, thru; for BILLING ACCOUNT, described by BILLING
                                  ACCOUNT ROLE TYPE, involving PARTY ROLE: drawn to the
                                  roles' box, not to PARTY)
BILLING ACCOUNT                   (7.3a's; "billed at" CONTACT MECHANISM)
```

**What it changes**: the billed-to and billed-from lines move down from INVOICE and PARTY to
the subtypes and PARTY ROLE. A sales invoice comes from an internal organization and goes to a
bill-to customer (or an account); a purchase invoice comes from a supplier and goes to an
internal organization (or an account). The rules 7.2 leaves to checks are drawn. The same
move as Ch 4's Fig 4.3 against Fig 4.5. The account's roles involve party roles, not
parties.

**Not built**: 7.2 and 7.3a are built, with 7.3b's rules as checks (a sales invoice from one
of our internal organizations, a purchase invoice to one). Whether the chapter's overall figure
keeps 7.3a's lines to PARTY or 7.3b's to PARTY ROLE decides (point 11).

### Fig 7.4 — Invoice status and terms
**Transcription** (accepted: ☐; photo with Tables 7.7–7.8; open points under "To check
against the book")

```
INVOICE STATUS                    (identified by invoice + type + date: tildes on both lines)
  # status_date
  -> INVOICE                   (many "a status for" 1; invoice "in the state of" many)
  -> INVOICE STATUS TYPE       (many "described by" 1; type "the description for" many)

INVOICE TERM
  # invoice_term_id
  * term_value
  -> INVOICE                   } arc: many "a condition for" 1; invoice "subject to" many
  -> INVOICE ITEM              }      many "a condition for" 1; item "subject to" many
  -> TERM TYPE                 (many "described by" 1; type "the description for" many)

TERM TYPE
  # term_type_id
  * description

INVOICE, INVOICE ITEM          (7.1a's; INVOICE ITEM drawn with its SALES and PURCHASE
                                subtypes, "part of" INVOICE)
```

**Table 7.7, invoice statuses** (invoice · status type · date)
- 30002 · Approved · May 25, 2001
- 30002 · Sent · May 30, 2001
- 30005 · Sent · Jun 5, 2001
- 30005 · Void · Jun 6, 2001

**Table 7.8, invoice terms** (invoice · item seq · term type · value)
- 30002 · · Payment, net days · 30
- 30002 · · Late fee, percent · 2
- 30002 · · Penalty for collection agency, percent · 5
- 30002 · 2 · Non-returnable sales item ·

**To check against the book**
- Is term value mandatory (`*`)? Read so from the photo, but Table 7.8's last row has no
  value (point 13).
- The status line's tilde: drawn at the INVOICE STATUS end of both lines, so the status is
  identified by invoice, type and date. Read so.
- The text below the figure: the current status is the one with the latest date, and a
  physical model may denormalize a few statuses into dates on INVOICE (approved, sent, void).

**Discussion**
- **Status as history, not a column.** Same move as Ch 4's ORDER STATUS and Ch 5's SHIPMENT
  STATUS: a row per event, with its date. A `status` column on INVOICE says where the bill is
  and forgets how it got there: was 30005 ever sent before it was voided?
- **Terms on the bill or on one line**, never both: the arc. The same shape as Ch 4's ORDER
  TERM (which had no arc drawn) and AGREEMENT TERM, and the same shared TERM TYPE list.
- **Terms copy, they don't point.** The payment term on 30002 may well have come from an
  agreement (Ch 4) or the order, but the invoice keeps its own row: the bill must stand on
  its own if the agreement changes later.
- **The naive model**: `payment_terms text` and `status` on INVOICE. Two late-fee rules, or a
  term on one line, have nowhere to go, and a bare text can't be computed with (is it late?).

### Fig 7.5 — Billing for shipment items
**Transcription** (accepted: ☐; photos with Table 7.9)

```
SHIPMENT ITEM BILLING             (no attributes; identified by both lines: tildes)
  -> SHIPMENT ITEM             (many "of" 1; item "billed via" many)
  -> INVOICE ITEM              (many "for" 1; item "the billing for" many)

SHIPMENT ITEM (Ch 5's: seq id, quantity, shipment contents description), "part of" SHIPMENT
(Ch 5's attributes); INVOICE ITEM "part of" INVOICE (7.1a's)
```

**Table 7.9, shipment invoice data** (shipment · shipment item seq · invoice · invoice item
seq · quantity, from the invoice item)
- 1235 · 1 · 30002 · 1 · 1000
- 1235 · 2 · 30002 · 2 · 1000
- 1235 · 3 · 30002 · 3 · 100
- 1235 · 1 · 30045 · 1 · −10
- 1330 · 1 · 30005 · 1 ·
- 1330 · 2 · 30005 · 1 ·
- 1330 · 3 · 30005 · 1 ·

So the table shows the three cases: one shipment line per invoice line (1235 on 30002), a
later credit line billing the same shipment line again (−10 on 30045: some came back or
were damaged), and several shipment lines gathered on one invoice line (1330 on 30005).

**To check against the book**
- 30002's quantities here (1000, 1000, 100) are Ch 5's shipment 9000 (pencils, pens,
  diskettes), not Table 7.2's lines (10 reams, a feature, 4 pens): point 14.

**Discussion**
- **Many to many, both ways.** One invoice line can bill several shipment lines (10 reams
  sent in two boxes on two shipments), and one shipment line can be billed on several
  invoice lines (half now, half when the customer accepts). The naive model, a
  `shipment_item_id` on the invoice line, holds only the first.
- **Why through the shipment, not the order:** a business that bills what it ships (most
  goods sellers) wants the invoice to follow the truck, not the promise. Fig 7.7 offers the
  order route for the others.
- **No quantity on the link**, unlike Ch 5's ORDER SHIPMENT: the book assumes each shipment
  line is billed whole. Partial billing would need one.

### Fig 7.6 — Billing of time entries and work efforts
**Transcription** (accepted: ☐; photo, no table)

```
TIME ENTRY BILLING                (no attributes; identified by both lines: tildes)
  -> TIME ENTRY                (many "of" 1; entry "billed via" many)
  -> INVOICE ITEM              (many "for" 1; item "the billing for" many)

WORK EFFORT BILLING               (identified by both lines: tildes)
  o percentage
  -> WORK EFFORT               (many "of" 1; effort "billed via" many)
  -> INVOICE ITEM              (many "for" 1; item "the billing for" many)

TIME ENTRY (Ch 6's: id, from date, thru date, hours, comment)
WORK EFFORT (Ch 6's attributes, 6.3a's set); INVOICE ITEM (7.1a's)
```

**To check against the book**
- The text under the figure: if a time entry can be billed over more than one invoice item,
  an **hours** attribute could be added to TIME ENTRY BILLING. Not drawn; read as a
  suggestion (point 15).
- The percentage: read as the share of the effort's agreed price this invoice line bills (a
  milestone: 50% at kick-off, 50% at delivery).

**Discussion**
- **Two ways to bill services:** by the hour (each time entry on the line) or by the job
  (the whole effort, or a percentage of it at each milestone). The same invoice line type
  (TIME_ENTRY_ITEM or WORK_EFFORT_ITEM, 7.1b's) says which.
- **Why time entries, not assignments:** the entry is what was actually worked (Ch 6); the
  assignment (6.5) is only who was on it. Bill what happened.
- **The naive model**: an `invoiced` flag on TIME ENTRY. It can't say which bill, can't
  split an entry, and loses the trail when a bill is voided.

### Fig 7.7 — Billing for order items
**Transcription** (accepted: ☐; photo with Table 7.10)

```
ORDER ITEM BILLING                (identified by both lines: tildes)
  o quantity
  o amount
  -> ORDER ITEM                (many "of" 1; item "billed via" many)
  -> INVOICE ITEM              (many "for" 1; item "the billing for" many)

ORDER ITEM (Ch 4's: seq id, quantity, unit price, estimated delivery date, shipping
instructions, item description, comment; SALES ORDER ITEM with corresponding purchase order
id, PURCHASE ORDER ITEM), "part of" ORDER (with SALES ORDER, PURCHASE ORDER)
INVOICE ITEM, INVOICE (7.1a's)
```

**Table 7.10, billing for order items** (purchase order · order item seq · quantity · unit
price · invoice · invoice item seq · invoice quantity · billing quantity)
- 10001 · 1 · 40 hours · $60 · 990023 · 1 · 100 · 40
- 10002 · 1 · 40 hours · $60 · (990023 · 1) · · 40
- 10003 · 1 · 40 hours · $60 · (990023 · 1) · · 20
- 10003 · 1 · 40 hours · $60 · 990026 · 1 · 20 · 20

Rows 2 and 3 leave the invoice blank; read as "same as above" (990023's one line of 100
hours bills 40 + 40 + 20), since the billing quantities add up to its 100.

**To check against the book**
- Rows 2–3's blank invoice columns (read as above).
- Whose purchase orders: the text speaks of a vendor and its customers' purchase orders.
  Read as **our** purchases: we ordered accounting services three times and the supplier
  billed them on two invoices of its own numbering (990023, 990026), which Table 7.11 shows
  paid by one payment (point 16).
- Is amount on the link per unit or the whole billed? Read as the amount billed for that
  order line (quantity × the order's price unless agreed otherwise).

**Discussion**
- **For businesses that bill the order, not the delivery:** services with no shipment,
  bill-in-advance, deposits. The link carries a quantity, so an order line can be billed in
  parts (10003's 40 hours: 20 on each invoice) and one invoice line can gather several
  orders (990023's 100 hours from three orders).
- **The vendor's choice doesn't matter to the model:** one invoice per order, per month, or
  per project: the link takes them all.
- **Pick one route per business**, or a line billed both through its order and through its
  shipment is counted twice (point 17).

### Fig 7.8a — Invoice payments
**Transcription** (accepted: ☐; photo with Table 7.11)

```
PAYMENT
  # payment_id
  * effective_date
  * payment_ref_num
  * amount
  o comment
  subtypes: RECEIPT, DISBURSEMENT
  -> PAYMENT METHOD TYPE       (many "paid via" 1; type "the method for paying" many)
  -> PARTY                     (many "from" 1; party "the payor of" many)
  -> PARTY                     (many "to" 1; party "the receiver of" many)

PAYMENT APPLICATION
  # payment_application_id
  * amount_applied
  -> PAYMENT                   (many "applying" 1, tilde; payment "used to pay" many)
  -> INVOICE                   (many "applied to" 1; invoice "paid via" many)
  -> BILLING ACCOUNT           (dashed: many "applied to" 1; account "affected via" many)

PAYMENT METHOD TYPE
  # payment_method_type_id
  * description

INVOICE (7.1a's), BILLING ACCOUNT (7.3a's), PARTY (# party id)
```

**Table 7.11, invoice payments** (invoice · item seq · product · feature · adjustment ·
quantity · unit price · payment application amount · payment · payment amount)
- 30002 · · · · · · · $182.20 · 12298398 · $182.20
- 30002 · 1 · Johnson fine grade 8½ by 11 bond paper · · · 10 · $8.00 · $12.84 ·
  12298412 · $12.84
- 30002 · 2 · · product quality, extra glossy finish · · · $2.00
- 30002 · 3 · Goldstein Elite pens · · · 4 · $12.00
- 30002 · 4 · HD 3½-inch diskettes · · · 6 · $7.00
- 30002 · 5 · · · sales tax · · $12.04
- 30002 · 6 · · · shipping and handling · · $16.00
- 30002 · 7 · · · fee (order processing fee) · · $5.00
- 990023 · 1 · accounting services · · · · $6,000 · $6,000 · 488893 · $7,000
- 990026 · 1 · accounting services · · · · $1,200 · $1,000 · (488893)

**To check against the book**
- Is "applied to" INVOICE solid (mandatory)? The text says a payment may instead be applied
  "on account", to a billing account and no invoice. Read as an arc: one or the other
  (point 18).
- Which row the $12.84 sits on: the rotated photo puts it on line 1's row, not the
  invoice's (point 19).
- Table 7.11's line order against Table 7.3: tax is line 5 at $12.04 here, line 7 at $25.65
  there (point 20).
- Payment ref num: read as the check number or the electronic transfer's reference.

**Discussion**
- **Payment and invoice are many to many.** One payment settles several bills (488893 pays
  990023 and part of 990026), one bill is paid in parts (30002 by two payments). The
  application holds how much of which payment went where. The naive model, `paid_date` and
  `amount_paid` on INVOICE, can't hold either.
- **RECEIPT or DISBURSEMENT** is direction: money in to one of our internal organizations,
  or money out. Same entity, the way Ch 4 has SALES and PURCHASE ORDER.
- **On account:** a customer pays $500 against the account before we know which bills it
  covers. The application points at the BILLING ACCOUNT; it moves to invoices later (or
  never, if the business runs balance-forward billing).
- **Outstanding = invoice total − applications.** Nothing stores a balance; it is computed,
  so it can't drift.

### Fig 7.8b — Invoice item payments, alternate model
**Transcription** (accepted: ☐; not built, see STATUS)

```
PAYMENT APPLICATION               (as 7.8a: # id, * amount applied, "applying" PAYMENT)
  -> INVOICE ITEM              (dashed: many "applied to" 1; item "paid via" many)
  -> BILLING ACCOUNT           (dashed: many "applied to" 1; account "affected via" many)
PAYMENT, PAYMENT METHOD TYPE      (as 7.8a; the ref is "payment ref no" here)
INVOICE ITEM                      # seq id, * taxable flag, * quantity, * unit price,
                                  o item description; SALES / PURCHASE INVOICE ITEM;
                                  "part of" INVOICE (# id, * date, o description, o message)
```

**What it changes**: payments apply to invoice **lines**, not whole invoices, so a customer
who disputes one line can pay the others and the books show which line is still open. The
cost: every payment has to be spread across lines, even the plain "here's the total" ones.
INVOICE ITEM is drawn with a mandatory quantity and unit price (7.1a's are optional, and its
amount is called amount): read as a drawing slip, 7.1a's attributes stand.

**Not built**: the overall figure (7.10) keeps 7.8a's INVOICE PAYMENT APPLICATION to
INVOICE. Table 7.11's $12.84 on line 1's row (point 19) reads like a 7.8b example.

### Fig 7.9 — Financial accounts, withdrawals and deposits
**Transcription** (accepted: ☐; photo with Table 7.12)

```
PAYMENT                           (7.8a's: # id, * effective date, * payment ref no,
                                   * amount, o comment; "paid via" PAYMENT METHOD TYPE)
  DISBURSEMENT -> WITHDRAWAL   ("affecting" / "caused by"; no crow's foot: one to one)
  RECEIPT      -> DEPOSIT      (many "deposited via" 1; deposit "the mechanism to deposit"
                                many)

FINANCIAL ACCOUNT TRANSACTION
  # financial_account_trans_id
  * transaction_date
  o entry_date
  subtypes: WITHDRAWAL, DEPOSIT, FINANCIAL ACCOUNT ADJUSTMENT
  -> FINANCIAL ACCOUNT         (many "affecting" 1; account "affected by" many)
  -> PARTY                     (many "executed by" 1; party "the executer of" many)

FINANCIAL ACCOUNT
  # financial_account_id
  * financial_account_name
  subtypes: INVESTMENT ACCOUNT, BANK ACCOUNT
  -> FINANCIAL ACCOUNT TYPE    (dashed: many "described by" 1; type "the description for")

FINANCIAL ACCOUNT ROLE            (identified by account + type + party: tildes)
  * from_date
  o thru_date
  -> FINANCIAL ACCOUNT         (many "of" 1; account "owned by" many)
  -> FINANCIAL ACCOUNT ROLE TYPE (many "for" 1; type "the description for" many)
  -> PARTY                     (many "for" 1; party "involved in" many)

FINANCIAL ACCOUNT TYPE            # id, * description
FINANCIAL ACCOUNT ROLE TYPE, PAYMENT METHOD TYPE (# id, * description)
```

**Table 7.12, deposits and withdrawals** (payment · payment amount · transaction · deposit
amount · withdrawal amount · financial account)
- 1298398 · $182.20 · 398749 · $917.04 · · 8389309984
- 1298412 · $12.84 · (398749)
- 394789 · $343.00 · (398749)
- 97873 · $379.00 · (398749)
- 88394 · $480.00 · 398761 · · $480.00 · 8389309984
- 88756 · $670.00 · 398762 · · $670.00 · 8389309984

The deposit is the four receipts banked together (182.20 + 12.84 + 343 + 379 = 917.04);
each withdrawal is one check. The first two receipts are Table 7.11's.

**To check against the book**
- No amount on FINANCIAL ACCOUNT TRANSACTION: the table's deposit and withdrawal amounts
  add up the payments. A FINANCIAL ACCOUNT ADJUSTMENT (a bank fee, interest) has no payment
  to add up (point 24).
- The financial account id is the bank account number (8389309984) in Table 7.12.
- The text's types: checking, savings, IRA, mutual fund, as FINANCIAL ACCOUNT TYPE rows.
- Does a withdrawal have exactly one disbursement? Read so from the line (no crow's foot)
  and the table (one check per withdrawal).

**Discussion**
- **A payment isn't money in the bank.** A check received is a RECEIPT; it becomes cash when
  it's deposited, usually with others, on another day, into one of several accounts. The
  naive model (`bank_account_id` on PAYMENT) can't say which receipts went in which deposit
  slip, or reconcile the bank statement (one line of $917.04) against four payments.
- **The account belongs to parties in roles** (owner, signer, administrator), dated, the
  same move as Ch 7's billing account roles. Who executed a transaction is a line of its own.
- **Adjustments** are bank charges and interest: transactions with no payment behind them.

### Fig 7.10 — Overall invoice model (architecture)
**Transcription** (accepted: ☐; entities with their identifiers only, lines as drawn)

```
INVOICE (# id) -- the hub
  "composed of" INVOICE ITEM (# seq id; two recursive dashed lines: adjusted by, sold with)
    -> INVOICE ITEM TYPE, PRODUCT, PRODUCT FEATURE (dashed)
    <- ORDER ITEM BILLING -> ORDER ITEM (Ch 4)
    <- SHIPMENT ITEM BILLING -> SHIPMENT ITEM (Ch 5)
    <- WORK EFFORT BILLING -> WORK EFFORT (Ch 6)
    <- TIME ENTRY BILLING -> TIME ENTRY (Ch 6)
  <- INVOICE TERM (arc: invoice or item) -> TERM TYPE
  <- INVOICE STATUS (the type isn't drawn)
  <- INVOICE ROLE -> INVOICE ROLE TYPE, PARTY
  -> PARTY (billed to, billed from) and BILLING ACCOUNT, in an arc on billed to
  -> CONTACT MECHANISM (addressed to, sent from)
BILLING ACCOUNT -> CONTACT MECHANISM; <- BILLING ACCOUNT ROLE -> TYPE, PARTY
INVOICE PAYMENT APPLICATION -> INVOICE, BILLING ACCOUNT (dashed); "applying" PAYMENT
PAYMENT -> PAYMENT METHOD TYPE, PARTY (from, to), FINANCIAL ACCOUNT TRANSACTION
FINANCIAL ACCOUNT TRANSACTION -> FINANCIAL ACCOUNT, PARTY
FINANCIAL ACCOUNT <- FINANCIAL ACCOUNT ROLE -> PARTY
```

**What it adds or settles**
- It keeps **7.1a** (one INVOICE ITEM with a type and two recursive lines, not 7.1b's
  subtypes), **7.3a** (lines to PARTY, not 7.3b's PARTY ROLE subtypes) and **7.8a** (the
  application to the INVOICE, here named INVOICE PAYMENT APPLICATION, not 7.8b's item).
- Misprints: INVOICE TERM is labelled "# status date" and INVOICE STATUS "# invoice date";
  read as swapped captions (point 25). INVOICE STATUS TYPE and the ITEM's INVENTORY ITEM line
  aren't drawn: read as left out for space.
- One line from PAYMENT to FINANCIAL ACCOUNT TRANSACTION, many payments to one transaction,
  where 7.9 draws one per subtype (receipt to deposit, disbursement to withdrawal). Built as
  one FK with the subtype rules as checks.

**How it flows**
- **Hubs:** INVOICE and INVOICE ITEM. Everything else hangs off one of them.
- **What it bills:** each item is typed and names a product, feature or inventory item
  (Ch 3); the billing links reach back to what caused the charge: order items (Ch 4),
  shipment items (Ch 5), work efforts and time entries (Ch 6).
- **Who and where:** billed from a party, to a party or a billing account; addressed to and
  sent from any contact mechanism (Ch 2); other parties by INVOICE ROLE.
- **Its life:** INVOICE STATUS (approved, sent, void) and INVOICE TERM (net days, late fee).
- **Money:** PAYMENT (receipt or disbursement, between two parties) applies to invoices,
  or to a billing account on account; payments are banked as FINANCIAL ACCOUNT
  TRANSACTIONs (deposits gather receipts, a withdrawal clears a check) on FINANCIAL ACCOUNTs
  owned by parties in roles.
- **Hand-over:** Ch 8 (accounting) is where these invoices and payments become ledger
  entries.

### Points to discuss after the overview (Figs 7.1a–7.10)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing.

1. **7.1a, the item type is drawn mandatory**, but Table 7.2's product lines show no type.
   Built mandatory: every item is typed, with 7.1b's two subtype sets as the hierarchy's top
   rows (ACQUIRING_ITEM over PRODUCT_ITEM, FEATURE_ITEM, WORK_EFFORT_ITEM, TIME_ENTRY_ITEM;
   ADJUSTMENT over its six). Table 7.2's lines are seeded as PRODUCT_ITEM and FEATURE_ITEM.
2. **Table 7.2, amount per unit:** the amounts match Ch 4's unit prices for order 12560, so a
   line is worth quantity × amount, or the amount alone with no quantity (the feature, the
   fees). The tax line ($25.65) fits no clean rate on that reading: 172.00 of taxable lines
   gives 14.9%. It is exactly 13.5% of 190 (the $2 glossy finish charged on each of 10 reams)
   or 15% of 171. Seeded as printed; the totals query shows it.
3. **7.1b's percentage:** an INVOICE ADJUSTMENT has a percentage (a 10% discount) in 7.1b,
   not in 7.1a. Not built: Fig 7.10 keeps 7.1a (no attributes shown), so no percentage.
4. **Table 7.4's dates against Ch 4:** invoice 30002 (May 25, 2001) bills the paper, pens and
   diskettes of Ch 4's order 12560, which Table 4.2 dates Jun 8, 2001. A bill before its
   order. No line ties them yet (the billing figures come later); flag when they do.
5. **Table 7.4's addresses against Ch 4:** ACME's billing address is 123 Main Street here,
   its head office 234 Stretch Street in Table 4.5; ABC Subsidiary sends from 100 Bridge
   Street here, takes orders at 100 Main Street there. Seeded as new mechanisms: ACME bills
   at one and is headquartered at the other, ABC Subsidiary has two addresses.
6. **7.2, "sender" and "receiver" role types:** the text lists them beside billed from and
   billed to. Read as the people who sent and received the invoice (a clerk, an accounts
   payable desk), not the companies on the lines. Seeded as types, no check.
7. **Table 7.4, invoice 30010** is ACME billing Tom Jones: neither our sales nor our
   purchase. Seeded as printed, as SALES with ACME as sender; a review query lists invoices
   whose sender or receiver isn't one of our internal organizations, and it shows there.
8. **Two more role-type lookups:** INVOICE ROLE TYPE and BILLING ACCOUNT ROLE TYPE make eleven
   role-type tables in the repo (Ch 2's TODO on a shared ROLE TYPE supertype). Kept separate,
   like the others, until that decision.
9. **Table 7.6 against its text:** the text opens 1459 with Jane and *Joe*, then says *John*
   would be held accountable, then Joe replaces John. Read as a slip for John: the table wins.
10. **7.3a, role identifiers:** the role tables are identified by account (or invoice) +
    party + type, with no date, yet the dated account roles can repeat (John off, John back
    on). Built with a surrogate key; the duplicate check counts account + party + type +
    from date.
11. **7.3a or 7.3b:** lines to PARTY or to PARTY ROLE. Built: 7.3a, with 7.3b's rules as
    checks. Fig 7.10 keeps 7.3a (lines to PARTY), so the build stands.
12. **Who's on the hook for an account invoice:** the arc lets an invoice be billed to an
    account with no party. "Who owes" is then the account's primary payer on the invoice date.
    Built as a query; an account with no primary payer on that date is a check.
13. **7.4, term value drawn mandatory**, yet Table 7.8's non-returnable row has none (the
    type says it all, as Ch 4's NO_EXCHANGE_OR_REFUND). Built nullable, like Ch 4's term
    tables.
14. **Table 7.9's 30002 isn't Table 7.2's:** its quantities (1000, 1000, 100) are Ch 5's
    shipment 9000, and its line 2 is a feature in Table 7.2. Shipments 1235 and 1330 aren't
    in Ch 5. Built to the table's intention, not its numbers: 1235 (ours) sends 30002's
    paper, pens and diskettes to ACME and its lines are billed on 30002's product lines 1,
    3 and 4; the −10 credit on 30045 is played by our 30016 (−2 reams), which bills 1235's
    line 1 again; 1330 (ours) sends John Smith three books in three lines, all billed on
    30005's line 1 (made 3 books).
15. **7.6, hours on TIME ENTRY BILLING:** the text offers it for an entry billed over more
    than one line; not drawn, not built. A review lists TIME_ENTRY_ITEM lines whose quantity
    differs from the hours of the entries they bill.
16. **Table 7.10's purchase orders** read as ours: ABC Subsidiary bought accounting services
    (40 hours a time) from a supplier, who billed them on its own invoices 990023 and 990026
    (purchase invoices), and Table 7.11 shows us paying them. The supplier, "Hartley
    Accounting", is ours.
17. **Two billing routes for one line:** a goods line can be billed through its order
    (7.7) or through its shipment (7.5). Both on one invoice line would count it twice.
    Built: a check catches an invoice line linked both ways.
18. **7.8a, "applied to" INVOICE is drawn solid**, but the text applies a payment "on
    account", to a billing account with no invoice. Read as an arc: exactly one of the two,
    a check constraint.
19. **Table 7.11's $12.84 sits on line 1's row**, not the invoice's: maybe the second
    payment settles one line (the paper): a 7.8b example. Fig 7.10 keeps 7.8a, the
    application to the whole invoice. Built so: both payments apply to 30002.
20. **Table 7.11 against Table 7.3:** tax is line 5 at $12.04 there, line 7 at $25.65 in
    Table 7.3. And the two payments (182.20 + 12.84 = 195.04) fit neither total: 218.65 with
    Table 7.3's tax, 205.04 with Table 7.11's (the $2 finish counted once). Kept 7.3's lines
    (built already) and seeded Table 7.11's payments, so 30002 shows 23.61 outstanding.
21. **Table 7.11's 990023** shows no quantity and a unit price of $6,000; Table 7.10 bills
    the same line as 100 hours. Seeded 100 × $60 = $6,000 (the same total).
22. **No PAID status:** whether a bill is paid is computed from its payment applications.
    Storing a PAID status too would let the two disagree. Seeded only the book's types
    (approved, sent, void) plus our RECEIVED for purchase invoices.
23. **Table 7.8's non-returnable term is on line 2**, the glossy-finish feature line, not on
    a product. Seeded as printed, with Ch 4's NO_EXCHANGE_OR_REFUND type: TERM TYPE is one
    list shared by orders, quotes, agreements and now invoices.
24. **7.9, no amount on FINANCIAL ACCOUNT TRANSACTION:** a deposit's or withdrawal's amount
    is the sum of its payments (Table 7.12 adds them up), but an ADJUSTMENT (a bank fee,
    interest) has no payment behind it. Built: an `amount` used only by adjustments (a
    check), deposits and withdrawals add up their payments.
25. **7.10's swapped captions:** INVOICE TERM shows "# status date" and INVOICE STATUS
    "# invoice date". Read as a slip: 7.4's attributes stand.
26. **The financial account id is the bank's number** (8389309984) in Table 7.12. Kept as the
    key, a `bigint` (too big for an integer): our only non-integer key so far. A surrogate
    with the number as an attribute would follow the convention better.
27. **7.9 draws a disbursement to one withdrawal, 7.10 many payments to one transaction:**
    built as one FK on PAYMENT; a check catches a withdrawal holding other than exactly one
    disbursement, and a receipt in a withdrawal or a disbursement in a deposit.
28. **Table 7.12's other four payments** (394789, 97873 receipts; 88394, 88756 checks) aren't
    in Table 7.11. Ours: 394789 is John Smith paying part of 30012, 97873 ACME paying on
    account 1296; the checks go to Fantastic Supplies (30020, and an advance) and Hartley
    Accounting (an advance). Built with 97873 as Jane Smith's check on account 1459 (the
    family account), not ACME's.
29. **Table 7.12's payment ids** are 1298398 and 1298412, Table 7.11's 12298398 and
    12298412, and the text says they're the same receipts. Table 7.11's ids kept.

## Design decisions (book → SQL)

### Fig 7.1a
- **`invoice`** with an `invoice_kind` discriminator (SALES, PURCHASE), as Ch 4's
  `order_kind`: the subtypes have no attributes or lines of their own until 7.3b, which isn't
  built. `invoice_id` takes the book's numbers.
- **`invoice_item_type`: a hierarchy with a text key** (point 1). Top rows ACQUIRING_ITEM and
  ADJUSTMENT (7.1b's two subtype sets) are grouping rows; under them PRODUCT_ITEM,
  FEATURE_ITEM, WORK_EFFORT_ITEM, TIME_ENTRY_ITEM and MISC_CHARGE, DISCOUNT, SURCHARGE,
  SALES_TAX, SHIPPING_AND_HANDLING, FEE. A check catches an item typed with a grouping row.
- **`invoice_item`** with a surrogate key, `invoice_id` and `invoice_item_seq_id` (unique per
  invoice: a check), mandatory `invoice_item_type_id`, nullable `product_id`,
  `product_feature_id` and `inventory_item_id`, `taxable_flag` (boolean, not null),
  `quantity`, `amount` (per unit, point 2), `item_description`, and the two recursive FKs
  `adjustment_for_invoice_item_id` and `sold_with_invoice_item_id` (not to itself: a check
  constraint).
- **Quantity may be negative**: a correction line credits −2 of a line billed 10 (the book's
  example). The amount stays positive: a DISCOUNT line's type lowers the total, as in Ch 4.
- **No SALES/PURCHASE INVOICE ITEM tables**: an item's kind is its invoice's kind.
- **Checks:** a duplicate seq on one invoice; a grouping-row type; an acquiring line that names
  nothing (no product, feature, inventory item or description); a feature line not sold with a
  product line of the same invoice; an adjustment that adjusts a line of another invoice, or
  a line that adjusts but isn't an adjustment nor a correction of the same thing; an inventory
  item whose product isn't the line's product.
- **Seed:** Tables 7.1–7.3 as printed: 30002's seven lines. Feature 25, "Extra glossy
  finish" (PRODUCT QUALITY), new to Ch 3's list. Ours: 30005's lines (the Data Model Resource
  Book, and the serialized copier OJ900-0001 with a $100 discount on its line); 30010's one
  described service; 30016, the book's correction (−2 reams pointing back at 30002's line
  1); 30020, a purchase invoice from Fantastic Supplies. Bad rows, all on 30011: a second
  line 1, a feature line sold with nothing, a line typed with the ACQUIRING_ITEM group, a line
  that bills nothing, a copier line whose inventory item is paper, and a tax line adjusting a
  line of 30002.

### Fig 7.2
- **`invoice` gains** `billed_to_party_id`, `billed_from_party_id`,
  `addressed_to_contact_mechanism_id` and `sent_from_contact_mechanism_id`. Billed from is
  `not null`. Billed to is nullable, because 7.3a puts it in an arc with the billing account
  (a check constraint there makes it exactly one).
- **Lines to PARTY, not PARTY ROLE**, as drawn (7.3b would move them).
- **`invoice_role_type`** and **`invoice_role`** (`datetime` as `role_datetime`, a
  timestamptz; `percentage` between 0 and 100). Types: ENTERED_BY, APPROVER, SENDER,
  RECEIVER (the text's four). The identifier (invoice, party, type) is a check.
- **Checks:** addressed to a mechanism the billed party has no BILLING purpose for on the
  invoice date (the book's own suggested rule); sent from a mechanism the sender isn't linked
  to on that date; a duplicate invoice role. **Review:** invoices whose sender (sales) or
  receiver (purchase) isn't one of our internal organizations on the invoice date (point 7).
- **Seed:** Table 7.4. New contact mechanisms: 123 Main Street (ACME's billing address), 100
  Bridge Street (ABC Subsidiary's), jsmith@us.com, 1235,678@cis.com and acorp@acme.com, each
  linked to its party with a BILLING purpose where invoices arrive. John Smith is Ch 6's (54),
  now also a customer; Tom Jones (62) is new. Roles: Rosa Diaz (Ch 5, ABC Subsidiary) entered
  30002 and 30005; William Jones (Ch 4, ABC Corporation) approved 30002. Bad rows: invoice
  30011, John Smith's bill addressed to ACME's billing address and sent from ACME's e-mail;
  Rosa entered 30002 twice.

### Fig 7.3a
- **`billing_account`** (`from_date`, `thru_date` exclusive, `description`,
  `billed_at_contact_mechanism_id` not null) and **`billing_account_role_type`** +
  **`billing_account_role`** (dated). Types: PRIMARY_PAYER, SECONDARY_PAYER, and the text's
  CUSTOMER_SERVICE_REP, MANAGER and SALES_REP.
- **The arc** on `invoice`: `billing_account_id` added, and `check (num_nonnulls(
  billed_to_party_id, billing_account_id) = 1)`: one row, one rule, a constraint.
- **Ch 4's orders** gain `bill_to_billing_account_id` on `sales_order` and `purchase_order`,
  with `num_nonnulls(...) <= 1` against the bill-to role (the requested bill-to is optional).
  The generic order roles (Fig 4.5) get nothing: a role row can't point at an account.
- **Checks:** an account invoice dated outside the account's dates; an account invoice
  addressed somewhere other than the account's mechanism; overlapping primary payers on one
  account; an account invoice with no primary payer on its date; a duplicate role (account,
  party, type, from date).
- **Seed:** Tables 7.5–7.6, thru dates +1 day. Jane Smith (Ch 6's 58) and John Smith (54)
  share account 1459 with Joe Smith (61, new); 1459 is billed at Jane's new postal address,
  "45 Elm Street" (ours). Invoices on account (ours): 30012 to 1296 (consulting for ACME),
  30013 to 1459 (the family's phone bill). Bad rows: 30014, billed to 1459 in January 2000,
  before it opened; 30015, billed to 1295 but addressed to jsmith@us.com; Joe Smith as a
  second primary payer on 1459 from Jul 1, 2001, and his secondary role keyed in twice.

### Fig 7.4
- **`invoice_status`** (surrogate key, `status_date` a date as drawn) with its types as a new
  INVOICE_STATUS group in Ch 2's `status_type`: APPROVED, SENT, VOID (the book's) and
  RECEIVED (ours, for supplier bills). No PAID (point 22).
- **`invoice_term`** with `term_type` from Ch 4 (shared with order, quote and agreement
  terms), `term_value` nullable (point 13). The arc is drawn, so `num_nonnulls(invoice_id,
  invoice_item_id) = 1` is a check constraint, unlike Ch 4's order terms, where no arc was
  drawn and "exactly one" was a query.
- **New term types** under FINANCIAL_TERM: LATE_FEE_PCT and COLLECTION_PENALTY_PCT. The
  non-returnable term reuses Ch 4's NO_EXCHANGE_OR_REFUND (point 23).
- **Checks:** a status outside the group; a status before the invoice date; anything after
  a void; a status twice (invoice, type, date); one term type twice on an invoice or line.
- **Seed:** Tables 7.7–7.8; ours: 30016 approved and sent, 30020 received, a 15-day term on
  30005. Bad rows: 30011 sent before its date, 30005 sent again after its void, 30013 given an
  order status, 30016's sent keyed twice, a second payment term (45 days) on 30002.

### Fig 7.5
- **`shipment_item_billing`** (surrogate key, two FKs, no attributes as drawn). The pair
  twice is a check.
- **Checks:** the same pair twice; a shipment line billed on a line for another product; a
  shipment billed to someone else than the party it went to (party-billed invoices only:
  an account invoice is paid by whoever is on the account).
- **Query:** what each customer shipment line has had billed, where a line billed only on a
  void invoice counts as unbilled. That's why a status history matters downstream.
- **Seed** (point 14): shipments 1235 (to ACME) and 1330 (to John Smith), ours; 30005's book
  line becomes 3 books. Bad rows: 9000's diskettes on 30002's pen line, 9000's pens (to
  ACME) on John Smith's 30011, 1235's pens on 30002's line 3 twice.

### Fig 7.6
- **`time_entry_billing`** and **`work_effort_billing`** (`percentage` above 0, at most 100:
  the share of the effort the line bills). No hours on the time link (point 15).
- **The line's type says the route:** time links only on TIME_ENTRY_ITEM lines, effort
  links only on WORK_EFFORT_ITEM lines (7.1b's leaves, already in `invoice_item_type`): a
  check.
- **Checks:** a link on a line of the wrong type; a time entry billed on more than one line
  (nothing says how it splits); an effort billed over 100% in all. **Review:** time lines
  whose hours differ from their entries' hours.
- **Seed** (no table in the book; ours): 30017 bills ACME for John Smith's interview hours
  (entries 3 and 5, 75 hours at $90) and Ch 6's project plan 29000 at 50% on approval.
  Bad rows: entry 3 billed again on 30012's product line, and a second plan line at 60%
  (110% in all).

### Fig 7.7
- **`order_item_billing`** with `quantity` (non-zero: a credit may bill a negative part) and
  `amount`, both optional as drawn.
- **Checks:** an order line billed for more than was ordered; an order billed on the other
  kind of invoice (sales on purchase, or back); an invoice line billed both through its
  order and through its shipment (point 17). **Review:** invoice lines whose quantity isn't
  the sum of what they bill.
- **Seed:** Table 7.10 as our purchases (point 16): Hartley Accounting (63, ours) as a
  SUPPLIER, the service "Accounting services" (27), purchase orders 10001–10003 placed by
  ABC Subsidiary's buyer role, Hartley's invoices 990023 (100 hours) and 990026 (20). Bad
  rows: 10002 billed 10 more hours on 990026; 12560's paper billed through its order on
  30002's line 1, which its shipment already bills; purchase order 12570's paper on sales
  invoice 30015. Purchase lines get their `purchase_order_item` rows (Ch 4's rule), with no
  ship-to: a service ships nothing.

### Fig 7.8a
- **`payment`** with a `payment_kind` discriminator (RECEIPT, DISBURSEMENT: no attributes of
  their own), `payment_method_type` (not null: drawn solid), `from_party_id` and
  `to_party_id` (not null, not the same party), `payment_ref_num` as text (a check number,
  an electronic reference).
- **`payment_application`** with the arc as a check constraint (point 18): an invoice or a
  billing account, exactly one.
- **`invoice_total`, a view:** 7.1a's total (discounts lower it), so balances are computed
  and can't drift from the lines.
- **Checks:** a payment the wrong way round (a receipt not received by an internal
  organization, a disbursement not paid by one); a payment applied past its amount; an
  invoice paid past its total; a receipt on a purchase invoice or a disbursement on a sales
  one. **Review:** payments applied to bills of someone other than the payor (allowed: a
  parent pays; a question when it's a stranger).
- **Seed:** Table 7.11 (30002's two payments; 488893 over 990023 and part of 990026) and
  Table 7.12's other four, ours (point 28): 394789 pays part of 30012, 97873 is Jane Smith's
  check on account 1459, 88394 pays 30020 and leaves $360 unapplied, 88756 is an advance to
  Hartley. 30002 ends 23.61 short (point 20). Bad rows: ACME's cash applied to our purchase
  invoice 30020, 88756 applied for 700 of its 670 (and past 990026's total), our refund to
  ACME typed as a receipt.

### Fig 7.9
- **`financial_account`** keyed on the bank's number, a `bigint` (point 26), with a
  `financial_account_kind` discriminator (BANK, INVESTMENT) and an optional type from a
  `financial_account_type` hierarchy whose top rows are the two kinds (a check keeps a type
  under its account's kind).
- **`financial_account_role`** + type (OWNER, SIGNER, ADMINISTRATOR), dated.
- **`financial_account_transaction`** with a `transaction_kind` (DEPOSIT, WITHDRAWAL,
  ADJUSTMENT) and an `amount` only adjustments carry (point 24): a check constraint, one row
  one rule. `executed_by_party_id` not null, as drawn.
- **`payment` gains `financial_account_transaction_id`** (point 27): one FK for both lines.
- **Checks:** an account typed outside its kind; a payment in the wrong kind of transaction;
  a withdrawal that isn't exactly one check, or a deposit with no payments; a transaction
  executed by someone with no role on the account that day; a role twice.
- **Queries:** Table 7.12 with each transaction's amount as its payments' sum; the account's
  running balance; payments not banked yet; who may act on the account.
- **Seed:** Table 7.12 (point 29), dates ours; ours: the account's owner and Rosa Diaz as
  signer, a $15 bank fee. Bad rows: a savings type on an investment account, Rosa's signer
  role twice, a withdrawal with no check executed by William Jones, check 488893 banked as
  a deposit.

## When NOT to use this
- **One line per product, no fees, one tax:** a small shop's invoice is fine with a total and
  a tax column; the typed items earn their keep when new charges keep appearing.
- **Corrections by credit note only:** if the business issues a whole credit note instead of
  correcting lines, "adjusted by" is unused; a link from the credit note's invoice to the
  original is enough.
- **No accounts:** if everyone is billed as themselves, skip BILLING ACCOUNT and its arc; it
  is for telecoms, utilities, banks and customers who split their spending.
- **Mail only:** a business that only posts paper bills can keep a postal address on the
  invoice. The book's bet is that this gets rarer every year.

## Open questions
- What the chapter's overall figure keeps from 7.1a and 7.1b (point 3), and from 7.3a and
  7.3b (point 11).
- How invoice items tie to order items, shipments, work efforts and time entries (the
  figures still to come).
