# Vol 1, Chapter 8 — Accounting and Budgeting

## The problem this pattern solves
Chapters 3 to 7 record what the business did: it ordered, shipped, worked, billed and was
paid. Accounting records what each of those did to the money, in a form every accountant
reads the same way. The naive model is a `ledger` table with `date`, `account_name`,
`amount` and maybe `customer_id`. It breaks fast. Account names drift ("Marketing expense"
splits into "Advertising" and "Trade shows"), two companies in one group share the same
chart of accounts but not the same books, a fiscal year starts in June for one of them, and
a single business event moves money in three or four accounts at once, which have to
balance. Ch 8 splits it: a **chart of accounts** shared by the enterprise (GENERAL LEDGER
ACCOUNT) and switched on per internal organization for a time (ORGANIZATION GL ACCOUNT);
**accounting periods** per organization, nested; and the **accounting transaction**, typed
by the business event that caused it and tied to its source document (invoice, payment,
inventory variance), broken into **debit and credit details** that each post to one
organization's account. **Budgets** are the other half: the money each department plans
to spend, item by item, with its approval history and its revisions.

## Submodels (proposed 2026-10-19; Figs 8.4–8.7 added the same day)
1. **Chart of accounts** (Figs 8.1, 8.4): which ledger accounts exist and what kind each is
   (asset, liability, equity, revenue, expense); which of them each internal organization
   uses, and since when; which subsidiary accounts break a control account down, and which
   customer, supplier, product or category each one is about; how each organization cuts
   its time into fiscal years, quarters and months?

2. **Accounting transactions** (Figs 8.2–8.3b, 8.5): what business events hit the books, of
   which kind (internal: depreciation, variances; external: invoices, credit memos,
   payments), between whom, from which invoice or payment; how each one splits into debits
   and credits on which organization's accounts, which credit settles which debit, and what
   each account's balance is for a period? Which asset a depreciation is of, and which
   method worked it out that year?

3. **Budgets** (Figs 8.6–8.7b): who asks for how much money, for which period, for what
   items and why; what stage each budget has reached; how it was revised, item by item,
   and why?

## Figures

### Fig 8.1 — Chart of accounts for internal organizations
**Transcription** (accepted: ☐; photo with Tables 8.1–8.2)

```
GENERAL LEDGER ACCOUNT
  # general_ledger_account_id
  * name
  * description
  -> GENERAL LEDGER ACCOUNT TYPE (many "defined by" 1; type "used to define" many)

GENERAL LEDGER ACCOUNT TYPE
  # general_ledger_account_type_id
  * description

ORGANIZATION GL ACCOUNT          (identified by its two parents: tildes on both "for")
  * from_date
  o thru_date
  -> GENERAL LEDGER ACCOUNT    (many "for" 1, tilde; account "associated with" many)
  -> INTERNAL ORGANIZATION     (many "for" 1, tilde; organization "associated with" many)

ACCOUNTING PERIOD
  # acctg_period_id
  * acctg_period_num
  * from_date
  * thru_date
  -> INTERNAL ORGANIZATION     (many "for" 1; organization "using" many)
  -> PERIOD TYPE               (many "defined by" 1; type "used to define" many)
  -> ACCOUNTING PERIOD         (dashed, recursive: "within" / "composed of")

PERIOD TYPE
  # period_type_id
  * description
```

**Table 8.1, general ledger accounts** (id · name · type; descriptions in our words)
- 110 · Cash · Asset (money on hand)
- 120 · Accounts receivable · Asset (owed to us)
- 240 · Notes payable · Liability (owed on signed promissory notes)
- 300 · Retained earnings · Owners equity (what the owners have earned and kept)
- 420 · Interest income · Revenue
- 520 · Advertising expense · Expense
- 530 · Office supplies expense · Expense

**Table 8.2, organization GL accounts** (internal organization · period from–thru · period
type · GL account · account type · account from–thru)
- ABC Corporation · Jan 1, 2001–Dec 31, 2001 · fiscal year: cash, accounts receivable,
  notes payable, retained earnings, interest income, office supplies from Jan 1, 1995;
  marketing expense Jan 1, 1995–Dec 31, 1996; advertising expense and trade show expense
  from Jan 1, 1997.
- ABC Subsidiary · Jan 1, 2001–Dec 31, 2001 · fiscal year: cash, accounts receivable,
  notes payable, retained earnings, interest income, marketing expense, office supplies,
  all from Jun 1, 1997.

**To check against the book**
- Table 8.2 names three accounts Table 8.1 doesn't list: marketing, trade show expense
  (and later tables add more). Read as accounts of the same chart left out of Table 8.1;
  ids ours (point 1).
- Is "within" dashed at both ends? Read as optional: a fiscal year sits in nothing.
- Table 8.2 puts the period columns on every account row. Read as the organization's
  current period, shown beside its accounts, not a link between the two (8.1 draws none).

**Discussion**
- **One chart, many books.** GENERAL LEDGER ACCOUNT is the enterprise's list ("cash",
  "accounts receivable"). ORGANIZATION GL ACCOUNT says which internal organization keeps
  which account, and when. ABC Corporation and ABC Subsidiary both have "cash", the same
  account in the chart, but their cash balances are different books.
- **Accounts come and go per organization.** ABC Corporation stopped using "marketing
  expense" at the end of 1996 and split it into advertising and trade shows; ABC Subsidiary
  still uses it. The chart keeps the old account; only the organization's dated row ends.
- **Periods belong to an organization**, because fiscal years differ (the text: one runs
  January to December, another June to May). Quarters and months sit "within" the year.
- **The type** (asset, liability, owners equity, revenue, expense) is what the financial
  statements group by: the balance sheet takes the first three, the income statement the
  last two.
- **The naive model** (an account name typed on each ledger line, or one chart per company
  as separate tables) can't share the chart, rename safely, or consolidate a group.

### Fig 8.2 — Accounting transactions
**Transcription** (accepted: ☐; photo with Table 8.3)

```
ACCOUNTING TRANSACTION
  # transaction_id
  * transaction_date
  * entry_date
  * description
  subtypes:
    INTERNAL ACCTG TRANS: DEPRECIATION, CAPITALIZATION, AMORTIZATION,
                          ITEM VARIANCE ACCTG TRANS, OTHER INTERNAL ACCTG TRANSACTION
    EXTERNAL ACCTG TRANS:
      OBLIGATION ACCTG TRANS: NOTE, TAX DUE, OTHER OBLIGATION, CREDIT MEMO, CREDIT LINE,
                              SALES ACCTG TRANS
      PAYMENT ACCTG TRANS: RECEIPT ACCTG TRANS, DISBURSEMENT ACCTG TRANS
  -> ACCOUNTING TRANSACTION TYPE (many "described by" 1; type "used to describe" many)

INTERNAL ACCTG TRANS  -> PARTY ROLE / INTERNAL ORGANIZATION
                         (many "from" 1; organization "affected by" many)
EXTERNAL ACCTG TRANS  -> PARTY (many "from" 1; party "the sender of" many)
                      -> PARTY (many "to" 1; party "the receiver of" many)
SALES ACCTG TRANS     -> INVOICE (many "originated from" 1; invoice "posted via" many)
PAYMENT ACCTG TRANS   -> PAYMENT (many "originated from" 1; payment "posted via" many)
ITEM VARIANCE ACCTG TRANS -> INVENTORY ITEM VARIANCE
                         (many "originated from" 1; variance "posted via" many)

ACCOUNTING TRANSACTION TYPE
  # acctg_transaction_type_id
  * description

PARTY ROLE (# party role id) with INTERNAL ORGANIZATION; PARTY (# party id);
INVOICE (Ch 7: # id, * date, o description, o message);
PAYMENT (Ch 7: # id, * effective date, * payment ref num, * amount, o comment;
         RECEIPT, DISBURSEMENT);
INVENTORY ITEM VARIANCE (Ch 3: # physical inventory date, * quantity, o comment)
```

**Table 8.3, accounting transactions** (id · from · to · date · amount · type ·
description)
- 32389 · ABC Corporation · · Jan 1, 2000 · $200 · depreciation · depreciation on the pen
  engraver
- 38948 · ABC Corporation · ACME Company · May 31, 2000 · $900 · invoice · invoiced amount
  due
- 39776 · ACME Company · ABC Corporation · Jun 13, 2000 · $700 · payment receipt for
  invoices · payment against an invoice
- 45783 · ABC Corporation · ACME Company · Jul 2, 2000 · $200 · credit memo · credit to an
  invoice
- 45894 · ACME Company · ABC Corporation · Aug 13, 2000 · $300 · payment receipt for
  invoices · paid on account, an invoice in mind
- 46325 · ABC Corporation · ACME Company · Oct 10, 2000 · −$300 · payment receipt for
  invoices · money held with no invoice, returned
- 47874 · Johnson Recycling · ABC Corporation · Oct 11, 2000 · $1,200 · payment receipt
  for asset sale · paid for the pen engraver

**To check against the book**
- The table's column order: the rotated photo reads TO PARTY before FROM PARTY. Read so
  that the invoicer and the payor are "from" (ABC Corporation invoices, ACME pays).
- Table 8.3 has an amount; the entity in 8.2 has none (point 3).
- Are the three "originated from" lines dashed at the transaction end? Read as optional
  in the SQL, with a review query (point 5).
- Whether the "from" line to INTERNAL ORGANIZATION is mandatory. Read as mandatory: an
  internal transaction always changes some organization's books.

**Discussion**
- **The subtype tree is the business event**, not the bookkeeping. Internal transactions
  (depreciation, an inventory count's variance) touch one organization's books with no
  one else involved. External ones have a sender and a receiver: obligations (an invoice,
  a credit memo, a note, tax due) create a debt, payments settle one.
- **Each event points at its source document**: a sales transaction at the invoice, a
  payment transaction at the payment, a variance transaction at the inventory count. The
  ledger stops being a pile of numbers: every line can be traced back to the bill.
- **TYPE beside subtypes:** the subtypes fix what lines a transaction has (a party, an
  invoice); ACCOUNTING TRANSACTION TYPE names finer business kinds under them ("payment
  receipt for invoices" or "for an asset sale", both receipts).
- **Transaction date vs entry date:** when it happened and when it was booked. Booking a
  May invoice in June is normal; reports by period use the transaction date.
- **The naive model** (a ledger line with an optional `invoice_id` and a free-text
  reason) loses who the other party was, can't tell a depreciation from a sale, and mixes
  the event with its postings.

### Fig 8.3a — Accounting transaction details
**Transcription** (accepted: ☐; photo with Tables 8.4–8.5)

```
TRANSACTION DETAIL               (identified by its transaction + seq id: tilde on "part of")
  # trans_detail_seq_id
  * amount
  * debit_credit_flag
  -> ACCOUNTING TRANSACTION    (many "part of" 1, tilde; transaction "composed of" many)
  -> ORGANIZATION GL ACCOUNT   (many "allocated to" 1; account "consisting of" many)
  -> TRANSACTION DETAIL        (dashed, recursive: "associated with" / "related to")

ORGANIZATION GL ACCOUNT (8.1's: * from date, o thru date)
  -> GENERAL LEDGER ACCOUNT    (many "for" 1, tilde; "associated with" many)
  -> INTERNAL ORGANIZATION     (many "for" 1, tilde; "associated with" many)

ACCOUNTING TRANSACTION (8.2's, with its subtypes) -> ACCOUNTING TRANSACTION TYPE
```

**Table 8.4, transaction details** (transaction · seq · amount · debit/credit ·
organization GL account, all ABC Corporation's)
- 32389 depreciation on equipment · 1 · $200 · debit · depreciation expense
- 32389 · 2 · $200 · credit · accumulated depreciation, equipment
- 38948 invoiced amount due · 1 · $900 · debit · accounts receivable
- 38948 · 2 · $900 · credit · revenue
- 39776 payment against invoice · 1 · $882 · debit · cash
- 39776 · 2 · $18 · debit · discount expense
- 39776 · 3 · $900 · credit · accounts receivable
- 47874 payment for the pen engraver · 1 · $1,000 · debit · cash
- 47874 · 2 · $200 · debit · accumulated depreciation
- 47874 · 3 · $800 · credit · asset
- 47874 · 4 · $400 · credit · capital gain

**Table 8.5, transaction detail relationships** (as 8.4, plus the associated transaction
and seq)
- 38948 · 1 · $900 debit AR; 2 · $900 credit revenue
- 39776 · 1 · $882 debit cash; 2 · $18 debit discount expense; 3 · $900 credit AR,
  associated with 38948 seq 1
- 50984 invoiced amount due · 1 · $1,000 debit AR; 2 · $1,000 credit revenue
- 50999 invoiced amount due · 1 · $2,000 debit AR; 2 · $2,000 credit revenue
- 60985 payment against invoice · 1 · $3,000 debit cash; 2 · $1,000 credit AR,
  associated with 50984 seq 1; 3 · $2,000 credit AR, associated with 50999 seq 1

**To check against the book**
- Is "allocated to" dashed? The line looks dashed near ORGANIZATION GL ACCOUNT. Read as
  mandatory at the detail end: a debit that posts to no account isn't a posting (point 7).
- The text says many physical designs use a signed amount instead of the flag. Read as a
  note on implementation; the flag is built (point 8).
- Which end of "associated with" is many. Read from Table 8.5: the payment's credit points
  at the invoice's debit, and one debit can be settled by several credits.

**Discussion**
- **Double entry.** A transaction is the event; its details are the postings. Debits
  equal credits in every transaction, which is the check that the books balance. 39776
  shows why one amount isn't enough: $900 settles the receivable, but $882 came in as cash
  and $18 went to discount expense.
- **Each detail posts to an organization's account**, not to the chart's: ABC
  Corporation's receivables, not "receivables" in general. So the same transaction tables
  serve every internal organization, and a consolidated report sums across them.
- **"Associated with"** ties a detail to the one it relates to: the payment's credit to
  the invoice's debit (Table 8.5). That's how open receivables are found per invoice
  without an "amount paid" column anywhere.
- **The naive model** puts one amount and one account on the transaction, so a split
  payment, a discount or an asset sale (four lines) needs several fake transactions that
  nothing ties together.

### Fig 8.3b — Accounting transaction detail with account balances
**Transcription** (accepted: ☐)

```
ORGANIZATION GL ACCOUNT BALANCE
  * amount
  -> ACCOUNTING PERIOD         (many "within" 1; period "for" many)
  -> ORGANIZATION GL ACCOUNT   (many "of" 1, tilde; account "used in" many)

TRANSACTION DETAIL (8.3a's)
  -> ORGANIZATION GL ACCOUNT BALANCE (many "allocated to" 1; balance "consisting of" many)
  -> ACCOUNTING TRANSACTION, TRANSACTION DETAIL as in 8.3a

ORGANIZATION GL ACCOUNT (* from, o thru)
  -> GENERAL LEDGER ACCOUNT    (many "of" 1, tilde; "used in" many)
ACCOUNTING PERIOD (8.1's: # id, * num, * from, * thru)
ACCOUNTING TRANSACTION, its subtypes and its type as in 8.3a
```

**To check against the book**
- Is the balance identified by its account (tilde on "of") and period? The tilde shows on
  "of"; read as one balance per account per period.
- The detail's "allocated to" line now ends at the balance, not at the account: the
  detail posts to an account-in-a-period (point 9).
- 8.3b doesn't draw INTERNAL ORGANIZATION; read as left out for room (the account and
  the period both belong to one).

**Discussion**
- **Stored balances are derived data.** The text argues both ways: balances can always
  be summed from the details, and keeping both risks them drifting apart; but closed
  periods don't change, and reports want last year's figures fast. 8.3b is the version
  that stores them, per account per period.
- **Hanging details on the balance** means the posting already knows its period; the
  balance row is "this account, this period", and its amount is the sum of its details.

### Fig 8.4 — General ledger account associations and subsidiary ledger accounts
**Transcription** (accepted: ☐; photo)

```
ORGANIZATION GL ACCOUNT (8.1's: * from date, o thru date)
  -> ORGANIZATION GL ACCOUNT   (dashed, recursive: "a subsidiary account of" / "comprised of")
  -> SUPPLIER                  (dashed, many "referencing" 1; supplier "referenced by" many)
  -> BILL TO CUSTOMER          (dashed, many "referencing" 1; customer "referenced by" many)
  -> PRODUCT CATEGORY          (dashed, many "referencing" 1; category "referenced by" many)
  -> PRODUCT                   (dashed, many "referencing" 1; product "referenced by" many)

SUPPLIER, BILL TO CUSTOMER     (Ch 2's party roles, no attributes drawn)
PRODUCT CATEGORY (Ch 3: # id, * description)
PRODUCT (Ch 3: # id, * name, o introduction, sales and support discontinuation dates,
         o comment; GOOD, SERVICE)
```

**To check against the book**
- No arc across the four "referencing" lines. Read as: an account usually references one
  of them, but nothing in the drawing forbids two (point 13).
- What GL account a subsidiary row carries. Read as its parent's: "accounts receivable,
  ACME" is ABC Subsidiary's 120 again, narrowed to one customer, not a new number in the
  enterprise's chart (point 14).
- The "referencing" lines look dashed at both ends: every reference optional.

**Discussion**
- **Control and subsidiary accounts.** Accounts receivable in the general ledger is one
  number, but the business needs it per customer; accounts payable per supplier; sales per
  product line. The control account stays in the ledger, and its subsidiary accounts
  (recursive, any depth) carry the detail. The control's balance is its subsidiaries'.
- **What the account is about** is a plain reference to the thing it tracks: the customer,
  the supplier, the product or the category. So "how much does ACME owe?" is the balance of
  the account that references ACME's bill-to role, not a search through invoices.
- **The naive model** opens a GL account per customer ("120-ACME", "120-Contoso") in the
  chart. The chart then grows with every customer, the enterprise's account list mixes
  structure with business partners, and nothing says that 120-ACME is about ACME.

### Fig 8.5 — Asset depreciation
**Transcription** (accepted: ☐; photo with Table 8.6)

```
ACCOUNTING TRANSACTION (8.2's: # transaction id, * transaction date, * entry date,
                        * description)
  INTERNAL ACCT TRANS
    DEPRECIATION -> FIXED ASSET (many "for" 1; asset "depreciated via" many)

FIXED ASSET
  # fixed_asset_id
  * name
  * date_acquired
  o date_last_serviced
  o date_next_service
  o production_capacity
  o description
  subtypes: PROPERTY, VEHICLE, EQUIPMENT, OTHER ASSET

FIXED ASSET DEPRECIATION METHOD    (identified by both parents: tildes)
  * from_date
  o thru_date
  -> FIXED ASSET               (many "for" 1, tilde; asset "depreciated via" many)
  -> DEPRECIATION METHOD       (many "defined by" 1, tilde; method "used to define" many)

DEPRECIATION METHOD
  # depreciation_method_id
  * description
  o formula
```

**Table 8.6, fixed asset depreciation method** (asset · method · formula · from–thru)
- Pen engraver · double-declining balance · (cost − salvage) × (1 / life in years) × 2 ·
  Jan 1, 1999–Dec 31, 1999
- Pen engraver · straight-line · (cost − salvage) / life in years · from Jan 1, 2000

**To check against the book**
- Is DEPRECIATION's "for" line solid at the transaction end? Read as mandatory: a
  depreciation is always of some asset.
- DATE ACQUIRED is starred here; Ch 6 added it as optional, and Ch 5's dock conveyor has
  none (point 16).
- The pen engraver is sold on Oct 11, 2000 (Table 8.3's 47874), yet its straight-line row
  has no thru date (point 17).

**Discussion**
- **One subtype gets a line.** Of all the internal transactions, only DEPRECIATION names
  its asset; the others stay as 8.2 drew them. That's the pattern again: a subtype exists
  because it has a line the others don't.
- **Methods change over time per asset.** The engraver was depreciated double-declining in
  1999 and straight-line from 2000. The dated association keeps both, so last year's
  depreciation can be recomputed the way it was computed then.
- **The formula is data,** a description of how the amount is worked out, not something
  the model runs; the book leaves the arithmetic to the accountants.
- **The naive model** puts `depreciation_method` on FIXED ASSET, so changing the method
  rewrites history: 1999's figures then look straight-line too.

### Fig 8.6 — Budget definition
**Transcription** (accepted: ☐; photo with Tables 8.7–8.9)

```
BUDGET
  # budget_id
  o comment
  subtypes: OPERATING BUDGET, CAPITAL BUDGET
  -> BUDGET TYPE               (many "described by" 1; type "describing" many)
  -> STANDARD TIME PERIOD      (many "associated with" 1; period "the budget period for" many)

BUDGET TYPE
  # budget_type_id
  o description

BUDGET ITEM                    (identified by its budget + seq id: tilde on "part of")
  # budget_item_seq_id
  * amount
  o purpose
  o justification
  -> BUDGET                    (many "part of" 1, tilde; budget "composed of" many)
  -> BUDGET ITEM TYPE          (many "described by" 1; type "used to describe" many)
  -> BUDGET ITEM               (dashed, recursive: "part of" / "comprised of")

BUDGET ITEM TYPE
  # budget_item_type_id
  * description

BUDGET STATUS                  (identified by its budget and type: tildes)
  * status_date
  o comment
  -> BUDGET                    (many "the status for" 1, tilde; budget "described by" many)
  -> BUDGET STATUS TYPE        (many "defined by" 1, tilde; type "used to define" many)

BUDGET ROLE                    (identified by its three parents: tildes)
  -> BUDGET                    (many "involved in" 1; budget "involving" many)
  -> PARTY                     (many "for" 1; party "involved in" many)
  -> BUDGET ROLE TYPE          (many "for" 1; type "used in" many)

STANDARD TIME PERIOD
  # standard_time_period_id
  * from_date
  * thru_date
  -> PERIOD TYPE               (many "described by" 1; type "used to describe" many)

PERIOD TYPE (8.1's: # id, * description); BUDGET STATUS TYPE (a STATUS TYPE subtype,
per the text); BUDGET ROLE TYPE, PARTY (# party id)
```

**Table 8.7, budgets** (id · type · party the budget is for · period · period type ·
description)
- 29839 · operating · marketing department · 1/1/2001–12/31/2001 · year · marketing
  budget
- 38576 · operating · administration department · 6/1/2002–6/30/2002 · month · office
  expenses budget
- 39908 · capital · manufacturing operations · 1/1/2001–12/31/2001 · year · new
  manufacturing machines needed

**Table 8.8, budget items** (budget · seq · item · amount · purpose and justification
in our words)
- 29839 · 1 · trade shows · $20,000 · meet markets directly; last year's spend brought
  three clients
- 29839 · 2 · advertising · $30,000 · make the products known; competitors force it
- 29839 · 3 · direct mail · $15,000 · sales leads; about 50 leads per $5,000
- 38576 · 1 · office supplies · $5,000 · day-to-day admin; same as last year
- 38576 · 2 · furniture · $10,000 · the new Benjamin Street facility needs basics

**Table 8.9, budget status** (29839 only)
- Oct 15, 2000 created · Nov 1 submitted · Nov 15 sent back for modifications
  (management accepted the kinds of items but wanted every amount lower) · Nov 20
  submitted · Nov 30 approved

**To check against the book**
- Tables 8.7–8.8 show a budget *description*; the entity has only a comment. Read as the
  comment (point 18).
- BUDGET TYPE's description is drawn optional (o), unlike every other type's. Built not
  null like the others; no row lacks one.
- Is BUDGET ROLE identified by its three parents? The tildes sit on "for", "for" and
  "involved in"; read so, with no dates drawn.
- The status line "the status for" has its tilde on the BUDGET STATUS side; read as
  budget + type + date identifying it, like Ch 7's invoice status.

**Discussion**
- **A budget is a plan with the same shape as an order:** a header (whose, which period,
  which kind) and items (what, how much, why). Purpose and justification are the
  budgeting part: why we need it, and why this amount.
- **For a party, at the lowest level.** The text asks for budgets per department, so they
  roll up through Ch 2's organization structure to divisions and the company.
- **Statuses are history**, as with orders and invoices: Table 8.9 shows 29839 going
  round the loop (submitted, sent back, submitted, approved).
- **STANDARD TIME PERIOD** is a calendar period (2001, June 2002) typed by 8.1's PERIOD
  TYPE, not an organization's accounting period (point 19).
- **Items nest:** an item may be part of a bigger one, so a capital budget can say
  "machines: $60,000" and break it down.
- **The naive model** is a spreadsheet per department: one row per line and a total. It
  can't say whose budget it is in the organization tree, what stage it's at, or what kind
  of item each line is across departments ("all trade show money in 2001").

### Fig 8.7a — Budget revisions: a new budget per revision (not built)
**Transcription** (accepted: ☐; photo, the top half of Fig 8.7)

```
BUDGET
  # budget_id
  o comment
  -> BUDGET                    (dashed, recursive: "a revision for" / "the revision of")
```

**Discussion**
- The simple option: every revision is a whole new budget, linked to the one it revises.
  Easy, but every unchanged item is recorded again, and what changed (and why) has to be
  worked out by comparing two budgets. The text keeps it for organizations with simple
  budgets. Not built: 8.7b holds the history of changes (point 20).

### Fig 8.7b — Budget revisions: revisions and their impacts
**Transcription** (accepted: ☐; photo, the bottom half of Fig 8.7, with Table 8.10)

```
BUDGET REVISION                (identified by its budget + seq: tilde on "a revision for")
  # revision_seq
  * date_revised
  -> BUDGET                    (many "a revision for" 1, tilde; budget "revised with" many)

BUDGET REVISION IMPACT         (identified by its item and revision: tildes)
  o revised_amount
  o add_delete_flag
  o revision_reason
  -> BUDGET ITEM               (many "affecting" 1, tilde; item "affected by" many)
  -> BUDGET REVISION           (many "from" 1, tilde; revision "affecting" many)

BUDGET ITEM (8.6's: # seq id, * amount, o purpose, o justification)
  -> BUDGET                    (many "part of" 1, tilde; "composed of" many)
BUDGET (# id, o comment)
```

**Table 8.10, budget revision impacts** (budget 29839, marketing; revision · item ·
change · flag · reason in our words)
- 1.1 · item 2 · −$10,000 · · a big cut to advertising
- 1.1 · item 3 · −$7,000 · · a big cut to direct mail
- 1.1 · item 4 · +$5,000 · added · a new item for Internet advertising
- 1.2 · item 3 · −$2,000 · · direct mail still too high

**To check against the book**
- Table 8.10's "a revision of" column repeats the budget id, and the revision numbers
  read 1.1 and 1.2. Read as the budget plus revision seq 1 and 2, printed "1.N" (point
  21).
- The table's last row says "items 3" and the third row "linternet": misprints.
- The revised amount reads as the change (−$10,000), not the new amount ($20,000): Table
  8.10's signs say so (point 22).
- Item 4 isn't in Table 8.8. Read as the item the revision added (point 22).

**Discussion**
- **Revisions are many-to-many with items:** one revision cuts three items, and item 3 is
  cut twice. The impact is the association, and it carries the change and its reason.
- **The budget stays one budget.** Its history is the list of revisions, so "what did
  marketing ask for first, and what did it end up with?" is a sum, not a comparison of two
  documents.
- **Table 8.9 meets Table 8.10:** management sent 29839 back on Nov 15 asking for lower
  amounts; revisions 1.1 and 1.2 are that answer, before it was resubmitted on Nov 20.
- **The naive model** overwrites the item's amount. The approved figure survives, but not
  what was asked for or why it changed.

### Fig 8.8 — Budget review
**Transcription** (accepted: ☐; photo with Table 8.11)

```
BUDGET REVIEW
  # budget_review_id
  * review_date
  -> BUDGET REVIEW RESULT TYPE (many "described by" 1, tilde; type "the description for" many)
  -> PARTY                     (many "of" 1, tilde; party "involved in" many)
  -> BUDGET                    (many "for" 1, tilde; budget "involving" many)

BUDGET REVIEW RESULT TYPE
  # budget_review_result_type_id
  * description
  o comment

BUDGET REVISION, BUDGET REVISION IMPACT, BUDGET ITEM, BUDGET: as in 8.7b, redrawn
PARTY (# party id)
```

**Table 8.11, budget reviews** (budget 29839; reviewer · date · result · comment in our
words)
- Susan Jones · Nov 10, 2000 · accepted · looks reasonable
- John Smith · Nov 15, 2000 · rejected · the amount is too high
- Susan Jones · Nov 22, 2000 · accepted · fine
- John Smith · Nov 30, 2000 · accepted · fine

**To check against the book**
- The table's second column is headed "budget revision party id". Read as the reviewing
  party: the figure draws no line from the review to a revision.
- The comment is drawn on the result type, but Table 8.11 gives each review its own
  comment. Built on the review (point 25).
- Only rows 1 and 3 print the budget id. Read as one budget, 29839, throughout.

**Discussion**
- **A review is one party's verdict on a budget on a day.** The status (8.6) says what
  stage the budget is at; the reviews say who decided it and why. The two tables tell
  one story: John Smith's rejection on Nov 15 is the send-back, revisions 1.1 and 1.2
  follow, Susan Jones accepts the resubmitted budget on Nov 22 and John Smith's
  acceptance on Nov 30 is the approval.
- **On the budget, not on a revision** (the text): the reviewer judges the budget as it
  stands, revisions included.
- **The naive model** puts `approved_by` and `approved_date` on BUDGET: one reviewer, one
  verdict, and the rejection that caused the revisions is lost.

### Fig 8.9 — Budget scenario
**Transcription** (accepted: ☐; photo with Table 8.12)

```
BUDGET SCENARIO APPLICATION
  # budget_scenario_applic_id
  o amount_change
  o percentage_change
  -> BUDGET ITEM | BUDGET      (arc; many "affecting" 1; item and budget "affected by" many)
  -> BUDGET SCENARIO           (many "from" 1, tilde; scenario "affecting" many)

BUDGET SCENARIO RULE           (identified by its type and scenario: tildes)
  o amount_change
  o percentage_change
  -> BUDGET ITEM TYPE          (many "for" 1, tilde; type "affected by" many)
  -> BUDGET SCENARIO           (many "for" 1, tilde; scenario "affected by" many)

BUDGET SCENARIO
  # budget_scenario_id
  * description

BUDGET ITEM (8.6's, "part of" BUDGET, "described by" BUDGET ITEM TYPE); BUDGET ITEM TYPE
(# id, * description); BUDGET (# id, o comment)
```

**Table 8.12, budget scenarios** (budget 29839, marketing; item · amount · scenario ·
rule's % · applied %)
- 1 trade shows · $20,000 · excellent marketing conditions · +20% · +20%
- 1 trade shows · $20,000 · poor marketing conditions · −15% · −20%
- 2 advertising · $30,000 · excellent marketing conditions · +25% · +25%
- 2 advertising · $30,000 · poor marketing conditions · −15% · −15%
- 3 direct mail · $15,000 · over 2% return responses · +30% · +30%
- 3 direct mail · $15,000 · less than 1% return responses · −40% · −40%

**To check against the book**
- The arc on the application's two "affecting" lines: read as exactly one, an item or a
  whole budget (point 28).
- Amount and percentage change are both optional. Read as exactly one of the two, on the
  rule and on the application (point 27).
- Table 8.12's amounts are Table 8.8's, before revisions 1.1–1.2 cut advertising and
  direct mail. Read as applied to the item as first entered (point 29).

**Discussion**
- **A scenario is a "what if" with a name** ("poor market", "major deal signed"). The
  budget keeps one set of amounts; each scenario says how they would move.
- **Rule and application, the suggestion and the decision.** The rule says how a scenario
  usually moves a *kind* of item (poor market: trade shows −15%); the application says
  what this budget actually plans for this item (−20%). Table 8.12's trade shows are the
  one row where the two differ, and that difference is why both exist.
- **Not a revision:** a revision changes the plan; a scenario leaves it standing and
  prepares alternatives. Nothing is overwritten either way.
- **The naive model** copies the budget per scenario ("Marketing 2001, pessimistic"):
  three budgets to keep in step, and no way to say that −15% is the house rule.

### Points to discuss after the overview (Figs 8.1–8.7b, so far)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing.

1. **Accounts beyond Table 8.1:** Table 8.2 uses marketing and trade show expense, Tables
   8.4–8.5 use revenue, discount expense, depreciation expense, accumulated depreciation,
   the asset itself and capital gain. Seeded in the chart with ids ours (410 sales revenue,
   430 capital gain, 510 marketing, 525 trade shows, 540 depreciation, 550 discount, 150
   equipment, 159 accumulated depreciation, typed Asset as a contra account).
2. **ABC Subsidiary's dates:** Table 8.2 gives it accounts from Jun 1, 1997; Ch 2 makes it
   an internal organization from Jan 1, 1999. The check asks only "ever internal", so both
   stand.
3. **No amount on ACCOUNTING TRANSACTION**, yet Table 8.3 shows one. Built without it: a
   transaction's amount is its debits' sum. That gives Table 8.3's $1,200 for 47874 (the
   four lines of Table 8.4 balance at 1,200), so the reading fits.
4. **39776 is $700 in Table 8.3 but $900 in Table 8.4** ($882 cash + $18 discount). The
   details win (they balance and match the $900 invoice); the query shows 900.
5. **Source documents for Table 8.3:** the book names no invoice or payment for 38948,
   39776 and the rest, and Ch 7's documents are ABC Subsidiary's. Built optional: Table
   8.3's rows have none, and ABC Subsidiary's two transactions of ours (61001, 61002) post
   Ch 7's invoice 30002 and payment 12298398. A review query lists sales and payment
   transactions with no document.
6. **46325, a −$300 "payment receipt":** money going back from ABC Corporation to ACME is a
   disbursement. Built as a DISBURSEMENT typed "returned payment" (a type of ours), whose
   amount is +300; its debit to receivables is associated with 45894's credit.
7. **"Allocated to" read as mandatory** (not null), though the line looks dashed.
8. **Debit/credit flag kept** rather than a signed amount (the book's own model; the text
   offers the other as a physical choice). Balances are computed as debits − credits.
9. **8.3b as an add-on, not a replacement:** built `organization_gl_account_balance` for
   closed periods, but the detail still posts to the organization's account (8.3a's line),
   with a check that each stored balance equals its details. 8.3b's own line (detail →
   balance) waits for the chapter's overall figure to say which version it keeps.
10. **Credit memo 45783 ($200, "credit to invoice #")** names no invoice. Its credit to
    receivables is left unassociated, so open receivables show $200 of unmatched credit.
11. **Table 8.3 says the engraver; Table 8.4 "equipment".** Read as the same asset, the
    pen engraver (not Ch 6's engraving machine #12, which ABC Manufacturing still uses).
12. **Fig 8.2's subtypes and the type entity:** built as one ACCOUNTING TRANSACTION TYPE
    hierarchy whose top rows are the subtype tree (INTERNAL, EXTERNAL, OBLIGATION and
    PAYMENT as grouping rows) and Table 8.3's types below their subtype (an invoice under
    SALES, the two receipts under RECEIPT).

Added with Figs 8.4–8.7b:

13. **No arc on Fig 8.4's four references.** Built as four nullable columns with no rule
    between them: an account could track a product *and* a customer (sales of pens to
    ACME). Should it be at most one?
14. **A subsidiary account carries its parent's GL account** (ABC Subsidiary's
    receivables for ACME is 120 again), so 8.1's "same account twice" check now counts two
    rows as duplicates only when they also share their parent and what they reference. A
    second check: a subsidiary on another organization's or another number's account, or
    outside its parent's dates.
15. **Where 8.4 and 8.5 belong.** Not a submodel of their own: 8.4 is added to the chart of
    accounts (submodel 1: what an account is about), 8.5 to accounting transactions
    (submodel 2: what a depreciation is of, and how it's worked out). Cards 35 and 36
    change their figures, so their Anki note ids change.
16. **DATE ACQUIRED is starred** in 8.5, but Ch 6 built it optional and Ch 5's dock conveyor has
    none. Left nullable; a review lists assets with no acquisition date.
17. **The engraver is sold on Oct 11, 2000** (47874), yet its straight-line method has no
    thru date. Seeded as printed. Nothing in 8.5 links the sale to the asset (47874 is a
    receipt, not a depreciation), so no check can see it.
18. **Budget description = BUDGET's comment** (Tables 8.7–8.8 print a description; the
    entity has only a comment).
19. **STANDARD TIME PERIOD beside ACCOUNTING PERIOD.** Built as its own table: a calendar
    period with no organization, typed by 8.1's PERIOD TYPE (we add YEAR and MONTH beside
    the fiscal ones). Is ACCOUNTING PERIOD meant to be a subtype of it? The overall figure
    may say.
20. **8.7a not built:** the bottom model keeps the history of changes, and the text offers
    the top one only for simple budgets. To confirm against the overall figure.
21. **Revision numbers "1.1" and "1.2"** stored as revision seq 1 and 2 of budget 29839,
    printed as the book does.
22. **The revised amount is the change**, signed (−$10,000). An item's own amount is the
    amount it was first entered with, by the budget or by the revision that added it (item
    4, $5,000; Table 8.8 doesn't list it). An ADD impact isn't counted twice; a DELETE takes
    the item to zero. The budget after each revision is a query.
23. **Ours, for the budgets:** the three departments (Marketing, Administration,
    Manufacturing operations, parties 65–67, rolling up to ABC Corporation), 39908's items
    (the book gives none), the revision dates (Nov 17 and 19, 2000, between the send-back
    and the resubmission), and the budget role types (only "budget for" is used).
24. **An item's parts add up to it** (ours): a parent item holds the total and its parts
    break it down, so a budget's total sums only its top items, and a check catches parts
    that don't add up.

Added with Figs 8.8–8.12:

25. **The review's comment on the review**, not on BUDGET REVIEW RESULT TYPE where it is
    drawn: Table 8.11 gives each review its own ("too high", "fine"). The result type
    keeps only its description.
26. **Reviewers, ours:** Susan Jones and John Smith are new persons at ABC Corporation
    (parties 68 and 69), not Ch 6's John Smith of ABC Manufacturing. Table 8.11's
    "budget revision party id" column is read as the reviewer.
27. **A change is an amount or a percentage, not both** (ours): both are drawn optional on
    the rule and on the application; a check constraint asks for exactly one.
28. **The application's arc:** exactly one of an item or a whole budget. A budget-wide
    application and an item one for the same scenario would count twice: a check.
29. **Scenarios apply to the item as first entered,** as Table 8.12 does ($30,000 of
    advertising, not the $20,000 left after revision 1.1). Which base the business wants
    (first entered, or after revisions) is a question for the overview.

## Design decisions (book → SQL)

### Fig 8.1
- **`general_ledger_account` keyed on the account number** (110, 120...): the book's own
  ids, which accountants use as codes. No surrogate, so the seed reads like Table 8.1.
- **`general_ledger_account_type`** a plain lookup (no hierarchy drawn).
- **`organization_gl_account`** with a surrogate key; the book's key (organization +
  account) plus dates becomes a check on overlapping rows. The organization is a plain FK to
  `organization`; "ever an INTERNAL_ORGANIZATION" is a check (point 2).
- **`accounting_period`** with `within_accounting_period_id`; `thru_date` exclusive and
  not null (a period always ends). **Checks:** a period inside another organization's, or
  outside its parent's dates.
- **Seed:** Table 8.1 plus eight accounts of ours (point 1), Table 8.2 for both
  organizations, ABC Corporation's 2000 and the quarters of 2001 (ours). Bad rows: ACME
  keeping cash, ABC Corporation's office supplies twice, April inside Q1, ABC Subsidiary's
  quarter inside ABC Corporation's year.

### Fig 8.2
- **The subtype tree in the type table** (point 12): `accounting_transaction_type` is a
  hierarchy whose top rows are the book's subtypes; the view
  `accounting_transaction_type_class` gives each type its root (INTERNAL, EXTERNAL), its
  subtype leaf and its group (OBLIGATION, PAYMENT). No discriminator column: the type
  already says it, and two columns could disagree.
- **One `from_party_id`** for both "from" lines (internal: the organization affected;
  external: the sender), `to_party_id` for the receiver. The book's internal line goes to
  a PARTY ROLE; ours goes to the party, and "is an internal organization that day" is a
  check, as in Ch 3 and Ch 7.
- **Source documents** as three nullable FKs, at most one (a check constraint), each on its
  own subtype (a query). A payment's kind must match the subtype (RECEIPT, DISBURSEMENT).
- **No amount column** (point 3).
- **Checks:** a grouping row used as a type; parties that don't fit the subtype; a document
  on the wrong subtype. **Review:** sales and payment transactions with no document.
- **Seed:** Table 8.3 (46325 as a disbursement, point 6), Table 8.5's three (dates ours),
  ABC Subsidiary's posting of Ch 7's invoice 30002 and payment 12298398. Johnson Recycling
  is new (party 64). No item variance transaction yet: the Ch 3 counts have no cost to post.
  Bad rows: a depreciation with a receiver, an invoice transaction posting a payment, a
  transaction typed EXTERNAL.

### Fig 8.3a
- **`transaction_detail`** with a surrogate key (the book's transaction + seq stays as
  columns), `organization_gl_account_id` not null (point 7), `amount` > 0 and a
  `debit_credit_flag` (point 8), `associated_with_transaction_detail_id` as a plain FK.
- **Checks:** a transaction that doesn't balance or has fewer than two postings; a posting
  to an account not open on the transaction date; a posting to the books of an
  organization that isn't a party to the transaction.
- **Queries:** Tables 8.4–8.5; each transaction's worth as its debits (Table 8.3's
  amounts, points 3–4); open receivables debit by debit, with the credits that settle
  nothing (45783's memo, point 10); a trial balance per organization for 2000.
- **Seed:** Tables 8.4–8.5 as printed, the rest of Table 8.3 and ABC Subsidiary's two
  (ours), balanced details for Fig 8.2's bad rows so only their own check fires. Detail
  ids are transaction id × 10 + seq. Bad rows: a trade fair stand on the closed marketing
  account, an invoice whose credits fall $10 short, ABC Corporation's cash on ABC
  Subsidiary's receipt.
- **No opening balances:** ABC Corporation's 2000 starts from nothing, so equipment ends
  the year at −800 (the engraver's cost was booked before our data). The trial balance
  still sums to zero.

### Fig 8.3b
- **`organization_gl_account_balance`** (account, period, amount as debits − credits),
  unique per account and period: the book's key, kept as a constraint because it's one
  row, one rule. Built beside 8.3a, not instead of it (point 9).
- **Checks:** a stored balance that disagrees with its period's postings; a balance whose
  period belongs to another organization.
- **Queries:** the 2000 closing grouped as the statements read it; the year's profit from
  the stored balances.
- **Seed:** ABC Corporation's 2000 closing (ours). Bad rows: cash stored $100 high, ABC
  Subsidiary's cash in ABC Corporation's year.

### Fig 8.4
- **Five nullable columns on `organization_gl_account`:** the parent
  (`subsidiary_of_organization_gl_account_id`), the supplier and bill-to customer as Ch 2
  party roles, the product category and the product. No arc (point 13); a review lists
  rows with more than one.
- **A subsidiary keeps its parent's number** (point 14), so 8.1's duplicate check now
  compares parent and references too.
- **Checks:** a subsidiary on another organization's or another number's account, or
  outside its parent's dates; a supplier or customer reference whose role is something
  else. **Queries:** the control accounts as trees with what each row is about; a control
  account's balance as its own postings plus its subsidiaries'; what ACME owes ABC
  Subsidiary, read off ACME's account.
- **Seed (ours):** accounts payable (210, new) per supplier at ABC Corporation, sales
  revenue per category and, inside writing instruments, for the engraved pen; ABC
  Subsidiary's receivables for ACME, where its invoice 30002 and payment now post. Bad
  rows: ABC Corporation's row under ABC Subsidiary's receivables, a "customer" that is a
  supplier role.

### Fig 8.5
- **`accounting_transaction.fixed_asset_id`**, nullable like the source documents; that
  DEPRECIATION has one and nothing else does is a check (the type already says which
  subtype it is, point 12).
- **`depreciation_method`** a lookup keyed on a code, the formula as text (optional).
  **`fixed_asset_depreciation_method`** dated, surrogate key; two methods at once is a
  check.
- **Fixed asset unchanged:** Ch 5 and Ch 6 already gave it every attribute 8.5 draws, and
  its subtypes are `fixed_asset_type` rows. `date_acquired` stays nullable (point 16).
- **Checks:** a depreciation of no asset, or an asset on another kind of transaction; a
  depreciation with no method in force that day; two methods at once. **Queries:** Table
  8.6; each depreciation with the method in force that day. **Review:** assets with no
  acquisition date.
- **Seed:** the pen engraver (5030, new; cost $800 from Table 8.4, acquired 1998 ours) and
  Table 8.6; 32389 and 32390 now name their assets. Bad rows: the engraving machine's old
  method never ended, a depreciation of the dock conveyor (no method), a depreciation of no
  asset. Both new depreciations are dated 2001, so 2000's stored balances still agree.

### Fig 8.6
- **`standard_time_period`** its own table, typed by 8.1's `period_type`, which gains
  YEAR and MONTH (point 19).
- **The subtypes as `budget_type` rows** (OPERATING_BUDGET, CAPITAL_BUDGET), as in 8.2;
  the description not null though drawn optional. The budget's description is its
  `comment` (point 18).
- **`budget_item`** with a surrogate key and (budget, seq) unique; `part_of_budget_item_id`
  for the recursion; amount ≥ 0 (a revision can take an item to zero).
- **`budget_status`** on Ch 2's `status_type` under a BUDGET_STATUS group, like Ch 4–7's
  statuses. **`budget_role` + `budget_role_type`**, its own lookup like every role type.
- **Checks:** a status from another group; a budget with no items or for no one; parts in
  another budget or not adding up to their parent (point 24). **Queries:** Tables 8.7–8.9
  (items as a tree, the total from top items only, the current status); the 2001 budgets
  rolled up through Ch 2's ORGANIZATION_ROLLUP to ABC Corporation.
- **Seed:** Tables 8.7–8.9; ours: the three departments (point 23), 39908's machines
  broken down into two, the other budgets' statuses. Bad rows: travel budget 40102 (no
  items, for no one), furniture parts adding to $12,000 of $10,000, an order status on
  39908.

### Fig 8.7b
- **8.7a not built** (point 20). **`budget_revision`** numbered within its budget, the
  pair unique (point 21). **`budget_revision_impact`** between revision and item, one per
  pair (the book's key, unique), carrying the signed change, an ADD/DELETE flag and the
  reason (point 22).
- **An added item is a `budget_item` row** with its own amount; the ADD impact records
  when and why. So 8.6's two budget queries now leave such items out: they show the
  budget as first entered.
- **Checks:** a revision changing another budget's item; an item revised below zero, or
  added with an amount other than its own. **Queries:** Table 8.10; the marketing budget
  after each of its revisions (65,000 → 53,000 → 51,000).
- **Seed:** Table 8.10 with item 4 (Internet advertising, $5,000) added by 1.1; revision
  dates ours (point 23). Bad rows: a revision of the office budget that trims a marketing
  item and cuts office supplies by $6,000 of $5,000.

### Fig 8.8
- **`budget_review_result_type`** a plain lookup (ACCEPTED, REJECTED), without the drawn
  comment; **`budget_review`** carries the budget, the reviewing party, the result, the
  date and the comment (point 25).
- **Check:** a review dated before the budget was first submitted. **Queries:** Table
  8.11; 29839's statuses and reviews on one timeline.
- **Seed:** Table 8.11 with Susan Jones and John Smith (parties 68–69, point 26). Bad row:
  Susan Jones accepting the office budget 38576 on Apr 25, 2002, a week before it was
  submitted.

### Fig 8.9
- **`budget_scenario`** with a surrogate key and a description.
  **`budget_scenario_rule`** per scenario and item type (unique, the book's key);
  **`budget_scenario_application`** with nullable `budget_item_id` and `budget_id` under
  an exactly-one check (the arc, point 28), unique per scenario and item or budget.
  Amount or percentage, exactly one (point 27).
- **Check:** a scenario applied to a budget and to one of its items. **Queries:** Table
  8.12; where the plan departs from the rule; the marketing budget's total under each
  scenario.
- **Seed:** Table 8.12's four scenarios, six rules and six applications, on the items as
  first entered (point 29). Bad row: poor marketing conditions also applied to the whole
  of 29839 (−10%), on top of its items.

## When NOT to use this
- **One company, one ledger:** a single small business can key the chart and the books
  together; ORGANIZATION GL ACCOUNT earns its keep with several internal organizations.
- **Buy, don't build:** the general ledger is the classic package. Most enterprises keep
  these tables in their accounting system and only need the links (which invoice posted
  which transaction) in their own models.

## Open questions
- What the rest of budgeting adds (reviews, scenarios, how budgets are used and funded,
  their tie to the ledger), and what the overall figure keeps from 8.3a and 8.3b (point 9)
  and from 8.7 (point 20).
