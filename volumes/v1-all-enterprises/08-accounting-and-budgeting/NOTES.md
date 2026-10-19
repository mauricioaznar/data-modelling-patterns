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
organization's account.

## Submodels (proposed 2026-10-19, from the first four figures; budgeting comes later)
1. **Chart of accounts** (Fig 8.1): which ledger accounts exist and what kind each is
   (asset, liability, equity, revenue, expense); which of them each internal organization
   uses, and since when; how each organization cuts its time into fiscal years, quarters
   and months?

2. **Accounting transactions** (Figs 8.2–8.3b): what business events hit the books, of
   which kind (internal: depreciation, variances; external: invoices, credit memos,
   payments), between whom, from which invoice or payment; how each one splits into debits
   and credits on which organization's accounts, which credit settles which debit, and what
   each account's balance is for a period?

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

### Points to discuss after the overview (Figs 8.1–8.3b, so far)
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

## When NOT to use this
- **One company, one ledger:** a single small business can key the chart and the books
  together; ORGANIZATION GL ACCOUNT earns its keep with several internal organizations.
- **Buy, don't build:** the general ledger is the classic package. Most enterprises keep
  these tables in their accounting system and only need the links (which invoice posted
  which transaction) in their own models.

## Open questions
- What the budgeting figures add, and what the chapter's overall figure keeps from 8.3a
  and 8.3b (point 9).
