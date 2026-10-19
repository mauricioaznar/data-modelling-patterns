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

### Points to discuss after the overview (Figs 7.1a–7.3b so far)
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
   not in 7.1a. Not built. If the overall figure keeps it, `invoice_item` gains a
   `percentage`, as Ch 4's `order_adjustment` has.
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
    checks. The overall figure decides.
12. **Who's on the hook for an account invoice:** the arc lets an invoice be billed to an
    account with no party. "Who owes" is then the account's primary payer on the invoice date.
    Built as a query; an account with no primary payer on that date is a check.

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
  30011, John Smith's bill addressed to ACME's billing address; Rosa entered 30002 twice.

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
  second primary payer on 1459 from Jul 1, 2001.

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
