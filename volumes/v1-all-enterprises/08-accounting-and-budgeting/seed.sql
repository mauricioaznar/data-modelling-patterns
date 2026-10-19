-- Vol 1, Chapter 8 seed data.
-- ABC Corporation and ABC Subsidiary keep books on one chart of accounts;
-- ABC Corporation's year 2000 (Tables 8.3–8.5) is booked in full, ABC
-- Subsidiary's posts Ch 7's invoice 30002 and its payment. The tricky cases
-- are accounts that end for one organization and not the other, nested
-- periods, split postings and credits that settle a given debit.
--
-- Parties: 12 ABC Corporation (internal since 1990, Ch 4), 13 ABC Subsidiary
-- (internal since 1999, Ch 2), 16 ACME Company, 64 Johnson Recycling (new).

-- ============================================================
-- Fig 8.1 — Chart of accounts for internal organizations
-- ============================================================
insert into party (party_id, party_kind) values
  (64, 'ORGANIZATION');
insert into organization (party_id, organization_type_id, name) values
  (64, 'CORPORATION', 'Johnson Recycling');
select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into general_ledger_account_type (general_ledger_account_type_id, description) values
  ('ASSET',         'Asset'),
  ('LIABILITY',     'Liability'),
  ('OWNERS_EQUITY', 'Owners equity'),
  ('REVENUE',       'Revenue'),
  ('EXPENSE',       'Expense');

-- Table 8.1, then the accounts the later tables use (NOTES, point 1: ids ours).
insert into general_ledger_account (general_ledger_account_id, general_ledger_account_type_id, name, description) values
  (110, 'ASSET',         'Cash',                     'Money on hand and in the bank'),
  (120, 'ASSET',         'Accounts receivable',      'What customers and others owe us'),
  (240, 'LIABILITY',     'Notes payable',            'What we owe on signed promissory notes'),
  (300, 'OWNERS_EQUITY', 'Retained earnings',        'What the owners have earned and kept in the business'),
  (420, 'REVENUE',       'Interest income',          'Interest earned in the period'),
  (520, 'EXPENSE',       'Advertising expense',      'Ads in papers, magazines and the like'),
  (530, 'EXPENSE',       'Office supplies expense',  'Supplies bought for the office'),
  (150, 'ASSET',         'Equipment',                'Machines and tools at cost'),
  (159, 'ASSET',         'Accumulated depreciation, equipment', 'Depreciation taken so far on equipment (a contra account: credit balance)'),
  (410, 'REVENUE',       'Sales revenue',            'What we billed for goods and services'),
  (430, 'REVENUE',       'Capital gain',             'Selling an asset for more than its book value'),
  (510, 'EXPENSE',       'Marketing expense',        'All marketing costs (split into 520 and 525 at ABC Corporation in 1997)'),
  (525, 'EXPENSE',       'Trade show expense',       'Stands, travel and fees for trade shows'),
  (540, 'EXPENSE',       'Depreciation expense',     'Depreciation charged in the period'),
  (550, 'EXPENSE',       'Discount expense',         'Early-payment discounts we gave');

-- Table 8.2 (thru dates +1 day), then the accounts Tables 8.4–8.5 post to (ours).
insert into organization_gl_account (organization_gl_account_id, internal_organization_party_id, general_ledger_account_id, from_date, thru_date) values
  (1,  12, 110, '1995-01-01', null),
  (2,  12, 120, '1995-01-01', null),
  (3,  12, 240, '1995-01-01', null),
  (4,  12, 300, '1995-01-01', null),
  (5,  12, 420, '1995-01-01', null),
  (6,  12, 510, '1995-01-01', '1997-01-01'),   -- marketing ends, split in two
  (7,  12, 520, '1997-01-01', null),
  (8,  12, 525, '1997-01-01', null),
  (9,  12, 530, '1995-01-01', null),
  (10, 12, 150, '1995-01-01', null),
  (11, 12, 159, '1995-01-01', null),
  (12, 12, 410, '1995-01-01', null),
  (13, 12, 430, '1995-01-01', null),
  (14, 12, 540, '1995-01-01', null),
  (15, 12, 550, '1995-01-01', null),
  (21, 13, 110, '1997-06-01', null),
  (22, 13, 120, '1997-06-01', null),
  (23, 13, 240, '1997-06-01', null),
  (24, 13, 300, '1997-06-01', null),
  (25, 13, 420, '1997-06-01', null),
  (26, 13, 510, '1997-06-01', null),           -- ABC Subsidiary still uses marketing
  (27, 13, 530, '1997-06-01', null),
  (28, 13, 410, '1997-06-01', null),
  (30, 16, 110, '2000-01-01', null),           -- DATA ERROR: ACME isn't one of our organizations
  (31, 12, 530, '1999-01-01', null);           -- DATA ERROR: office supplies twice at ABC Corporation

select setval(pg_get_serial_sequence('organization_gl_account', 'organization_gl_account_id'), (select max(organization_gl_account_id) from organization_gl_account));

insert into period_type (period_type_id, description) values
  ('FISCAL_YEAR',    'Fiscal year'),
  ('FISCAL_QUARTER', 'Fiscal quarter'),
  ('FISCAL_MONTH',   'Fiscal month');

-- Table 8.2's two fiscal years (2001); ABC Corporation's 2000 and the
-- quarters are ours.
insert into accounting_period (accounting_period_id, internal_organization_party_id, period_type_id, within_accounting_period_id, acctg_period_num, from_date, thru_date) values
  (1, 12, 'FISCAL_YEAR',    null, 2000, '2000-01-01', '2001-01-01'),
  (2, 12, 'FISCAL_YEAR',    null, 2001, '2001-01-01', '2002-01-01'),
  (3, 12, 'FISCAL_QUARTER', 2,    1,    '2001-01-01', '2001-04-01'),
  (4, 12, 'FISCAL_QUARTER', 2,    2,    '2001-04-01', '2001-07-01'),
  (5, 12, 'FISCAL_QUARTER', 2,    3,    '2001-07-01', '2001-10-01'),
  (6, 12, 'FISCAL_QUARTER', 2,    4,    '2001-10-01', '2002-01-01'),
  (7, 13, 'FISCAL_YEAR',    null, 2001, '2001-01-01', '2002-01-01'),
  (8, 12, 'FISCAL_MONTH',   3,    4,    '2001-04-01', '2001-05-01'),   -- DATA ERROR: April put inside Q1
  (9, 13, 'FISCAL_QUARTER', 2,    1,    '2001-01-01', '2001-04-01');   -- DATA ERROR: ABC Subsidiary's quarter inside ABC Corporation's year

select setval(pg_get_serial_sequence('accounting_period', 'accounting_period_id'), (select max(accounting_period_id) from accounting_period));

-- ============================================================
-- Fig 8.2 — Accounting transactions
-- ============================================================
-- The book's subtype tree first (grouping rows have no parent or sit under
-- EXTERNAL), then Table 8.3's types under their subtype.
insert into accounting_transaction_type (accounting_transaction_type_id, parent_type_id, description) values
  ('INTERNAL',               null,           'Internal accounting transaction (grouping row)'),
  ('DEPRECIATION',           'INTERNAL',     'Depreciation'),
  ('CAPITALIZATION',         'INTERNAL',     'Capitalization'),
  ('AMORTIZATION',           'INTERNAL',     'Amortization'),
  ('ITEM_VARIANCE',          'INTERNAL',     'Inventory item variance'),
  ('OTHER_INTERNAL',         'INTERNAL',     'Other internal accounting transaction'),
  ('EXTERNAL',               null,           'External accounting transaction (grouping row)'),
  ('OBLIGATION',             'EXTERNAL',     'Obligation (grouping row)'),
  ('NOTE',                   'OBLIGATION',   'Note'),
  ('TAX_DUE',                'OBLIGATION',   'Tax due'),
  ('OTHER_OBLIGATION',       'OBLIGATION',   'Other obligation'),
  ('CREDIT_MEMO',            'OBLIGATION',   'Credit memo'),
  ('CREDIT_LINE',            'OBLIGATION',   'Credit line'),
  ('SALES',                  'OBLIGATION',   'Sales accounting transaction'),
  ('PAYMENT',                'EXTERNAL',     'Payment (grouping row)'),
  ('RECEIPT',                'PAYMENT',      'Receipt'),
  ('DISBURSEMENT',           'PAYMENT',      'Disbursement'),
  ('INVOICE',                'SALES',        'Invoice'),
  ('RECEIPT_FOR_INVOICES',   'RECEIPT',      'Payment receipt for invoices'),
  ('RECEIPT_FOR_ASSET_SALE', 'RECEIPT',      'Payment receipt for asset sale'),
  ('RETURNED_PAYMENT',       'DISBURSEMENT', 'Returned payment');   -- ours (NOTES, point 6)

-- Table 8.3 (entry dates ours), Table 8.5's three (dates ours), and ABC
-- Subsidiary posting Ch 7's invoice 30002 and payment 12298398 (ours).
insert into accounting_transaction (accounting_transaction_id, accounting_transaction_type_id, from_party_id, to_party_id,
                                    invoice_id, payment_id, inventory_item_variance_id, transaction_date, entry_date, description) values
  (32389, 'DEPRECIATION',           12, null, null,  null,     null, '2000-01-01', '2000-01-05', 'Depreciation on the pen engraver'),
  (38948, 'INVOICE',                12, 16,   null,  null,     null, '2000-05-31', '2000-06-01', 'Invoiced amount due'),
  (39776, 'RECEIPT_FOR_INVOICES',   16, 12,   null,  null,     null, '2000-06-13', '2000-06-13', 'Payment against invoice'),
  (45783, 'CREDIT_MEMO',            12, 16,   null,  null,     null, '2000-07-02', '2000-07-03', 'Credit to an invoice'),
  (45894, 'RECEIPT_FOR_INVOICES',   16, 12,   null,  null,     null, '2000-08-13', '2000-08-14', 'Payment made on account with an invoice in mind'),
  (46325, 'RETURNED_PAYMENT',       12, 16,   null,  null,     null, '2000-10-10', '2000-10-10', 'Returned payment for moneys held with no invoice'),
  (47874, 'RECEIPT_FOR_ASSET_SALE', 64, 12,   null,  null,     null, '2000-10-11', '2000-10-12', 'Payment received for sale of the pen engraver'),
  (50984, 'INVOICE',                12, 16,   null,  null,     null, '2000-06-20', '2000-06-20', 'Invoiced amount due'),
  (50999, 'INVOICE',                12, 16,   null,  null,     null, '2000-06-25', '2000-06-26', 'Invoiced amount due'),
  (60985, 'RECEIPT_FOR_INVOICES',   16, 12,   null,  null,     null, '2000-09-15', '2000-09-15', 'Payment against two invoices'),
  (61001, 'INVOICE',                13, 16,   30002, null,     null, '2001-05-25', '2001-05-28', 'Office supply order, invoice 30002'),
  (61002, 'RECEIPT_FOR_INVOICES',   16, 13,   null,  12298398, null, '2001-06-20', '2001-06-21', 'ACME pays most of invoice 30002'),
  (32390, 'DEPRECIATION',           12, 16,   null,  null,     null, '2000-12-31', '2001-01-03', 'Depreciation on the delivery van'),   -- DATA ERROR: an internal transaction with a receiver
  (61004, 'INVOICE',                13, 16,   null,  12298412, null, '2001-06-28', '2001-06-28', 'Second payment on invoice 30002'),    -- DATA ERROR: an invoice transaction posting a payment
  (61005, 'EXTERNAL',               16, 13,   null,  null,     null, '2001-07-01', '2001-07-01', 'Cash from ACME, not yet classified'); -- DATA ERROR: typed with a grouping row

select setval(pg_get_serial_sequence('accounting_transaction', 'accounting_transaction_id'), (select max(accounting_transaction_id) from accounting_transaction));

-- ============================================================
-- Fig 8.3a — Accounting transaction details
-- ============================================================
-- Three more transactions whose details go wrong (ours).
insert into accounting_transaction (accounting_transaction_id, accounting_transaction_type_id, from_party_id, to_party_id,
                                    invoice_id, payment_id, inventory_item_variance_id, transaction_date, entry_date, description) values
  (32391, 'OTHER_INTERNAL',       12, null, null, null, null, '2000-03-01', '2000-03-02', 'Stand at the spring trade fair'),
  (61006, 'INVOICE',              13, 16,   null, null, null, '2001-07-05', '2001-07-05', 'Copier toner for ACME'),
  (61007, 'RECEIPT_FOR_INVOICES', 16, 13,   null, null, null, '2001-07-10', '2001-07-11', 'ACME pays for some toner');

-- Detail ids are the transaction id and seq (389481 = 38948 seq 1), so the
-- associations read like Table 8.5. Organization GL accounts (Fig 8.1):
-- ABC Corporation 1 cash, 2 receivables, 6 marketing (closed 1997),
-- 10 equipment, 11 accumulated depreciation, 12 sales revenue, 13 capital
-- gain, 14 depreciation expense, 15 discount expense; ABC Subsidiary 21 cash,
-- 22 receivables, 28 sales revenue.
insert into transaction_detail (transaction_detail_id, accounting_transaction_id, trans_detail_seq_id, organization_gl_account_id,
                                amount, debit_credit_flag, associated_with_transaction_detail_id) values
  -- Table 8.4
  (323891, 32389, 1, 14,  200,    'DEBIT',  null),
  (323892, 32389, 2, 11,  200,    'CREDIT', null),
  (389481, 38948, 1, 2,   900,    'DEBIT',  null),
  (389482, 38948, 2, 12,  900,    'CREDIT', null),
  (397761, 39776, 1, 1,   882,    'DEBIT',  null),
  (397762, 39776, 2, 15,  18,     'DEBIT',  null),
  (397763, 39776, 3, 2,   900,    'CREDIT', 389481),   -- Table 8.5: settles the invoice's debit
  (478741, 47874, 1, 1,   1000,   'DEBIT',  null),
  (478742, 47874, 2, 11,  200,    'DEBIT',  null),
  (478743, 47874, 3, 10,  800,    'CREDIT', null),
  (478744, 47874, 4, 13,  400,    'CREDIT', null),
  -- Table 8.5
  (509841, 50984, 1, 2,   1000,   'DEBIT',  null),
  (509842, 50984, 2, 12,  1000,   'CREDIT', null),
  (509991, 50999, 1, 2,   2000,   'DEBIT',  null),
  (509992, 50999, 2, 12,  2000,   'CREDIT', null),
  (609851, 60985, 1, 1,   3000,   'DEBIT',  null),
  (609852, 60985, 2, 2,   1000,   'CREDIT', 509841),   -- one payment, two invoices
  (609853, 60985, 3, 2,   2000,   'CREDIT', 509991),
  -- The rest of Table 8.3 (ours)
  (457831, 45783, 1, 12,  200,    'DEBIT',  null),     -- the credit memo names no invoice (point 10)
  (457832, 45783, 2, 2,   200,    'CREDIT', null),
  (458941, 45894, 1, 1,   300,    'DEBIT',  null),
  (458942, 45894, 2, 2,   300,    'CREDIT', null),     -- on account: no invoice to settle
  (463251, 46325, 1, 2,   300,    'DEBIT',  458942),   -- the refund undoes the payment on account
  (463252, 46325, 2, 1,   300,    'CREDIT', null),
  -- ABC Subsidiary (ours)
  (610011, 61001, 1, 22,  218.65, 'DEBIT',  null),
  (610012, 61001, 2, 28,  218.65, 'CREDIT', null),
  (610021, 61002, 1, 21,  182.20, 'DEBIT',  null),
  (610022, 61002, 2, 22,  182.20, 'CREDIT', 610011),
  -- Fig 8.2's bad transactions, balanced so only their own check catches them
  (323901, 32390, 1, 14,  50,     'DEBIT',  null),
  (323902, 32390, 2, 11,  50,     'CREDIT', null),
  (610041, 61004, 1, 22,  12.84,  'DEBIT',  null),
  (610042, 61004, 2, 28,  12.84,  'CREDIT', null),
  (610051, 61005, 1, 21,  10,     'DEBIT',  null),
  (610052, 61005, 2, 22,  10,     'CREDIT', null),
  -- Bad details
  (323911, 32391, 1, 6,   150,    'DEBIT',  null),     -- DATA ERROR: marketing expense closed at ABC Corporation in 1997
  (323912, 32391, 2, 1,   150,    'CREDIT', null),
  (610061, 61006, 1, 22,  100,    'DEBIT',  null),     -- DATA ERROR: debits 100, credits 90
  (610062, 61006, 2, 28,  90,     'CREDIT', null),
  (610071, 61007, 1, 1,   40,     'DEBIT',  null),     -- DATA ERROR: ABC Corporation's cash on ABC Subsidiary's receipt
  (610072, 61007, 2, 22,  40,     'CREDIT', null);

select setval(pg_get_serial_sequence('transaction_detail', 'transaction_detail_id'), (select max(transaction_detail_id) from transaction_detail));

-- ============================================================
-- Fig 8.3b — Accounting transaction detail with account balances
-- ============================================================
-- ABC Corporation closes 2000 (period 1) and stores its balances (ours).
insert into organization_gl_account_balance (organization_gl_account_id, accounting_period_id, amount) values
  (1,  1, 4832),    -- DATA ERROR: cash is 4732 by its postings
  (2,  1, -200),
  (6,  1, 150),
  (10, 1, -800),
  (11, 1, -50),
  (12, 1, -3700),
  (13, 1, -400),
  (14, 1, 250),
  (15, 1, 18),
  (21, 1, 0);       -- DATA ERROR: ABC Subsidiary's cash in ABC Corporation's year

-- ============================================================
-- Fig 8.4 — General ledger account associations and subsidiary ledger accounts
-- ============================================================
-- Ours: ABC Corporation's payables per supplier and sales per product line;
-- ABC Subsidiary's receivables per customer. Party roles (Ch 2–4): 37
-- Fantastic Supplies supplier, 38 Johnson Paper Mills supplier, 67 ACME
-- bill-to customer. Categories (Ch 3): 2 paper, 4 writing instruments;
-- product 22 the engraved black pen with gold trim (Ch 6).
insert into general_ledger_account (general_ledger_account_id, general_ledger_account_type_id, name, description) values
  (210, 'LIABILITY', 'Accounts payable', 'What we owe suppliers');

insert into organization_gl_account (organization_gl_account_id, internal_organization_party_id, general_ledger_account_id, from_date, thru_date,
                                     subsidiary_of_organization_gl_account_id, supplier_party_role_id, bill_to_customer_party_role_id,
                                     product_category_id, product_id) values
  (16, 12, 210, '1995-01-01', null, null, null, null, null, null),   -- the control account
  (41, 12, 210, '2001-04-05', null, 16,   37,   null, null, null),   -- payables: Fantastic Supplies
  (42, 12, 410, '1999-01-01', null, 12,   null, null, 4,    null),   -- sales: writing instruments
  (43, 12, 410, '2000-01-01', null, 42,   null, null, null, 22),     --   and within it, the engraved pen
  (44, 12, 410, '1999-01-01', null, 12,   null, null, 2,    null),   -- sales: paper
  (45, 13, 120, '1999-01-01', null, 22,   null, 67,   null, null),   -- ABC Subsidiary's receivables: ACME
  (46, 12, 120, '1999-01-01', null, 22,   null, 67,   null, null),   -- DATA ERROR: ABC Corporation's row under ABC Subsidiary's receivables
  (47, 12, 120, '1999-01-01', null, 2,    null, 38,   null, null);   -- DATA ERROR: the "customer" is Johnson Paper Mills's supplier role

select setval(pg_get_serial_sequence('organization_gl_account', 'organization_gl_account_id'), (select max(organization_gl_account_id) from organization_gl_account));

-- ABC Subsidiary now keeps receivables per customer: its ACME invoice and
-- payment (Fig 8.3a) post to ACME's subsidiary account, not the control.
update transaction_detail set organization_gl_account_id = 45 where transaction_detail_id in (610011, 610022);

-- ============================================================
-- Fig 8.5 — Asset depreciation
-- ============================================================
-- The pen engraver (new, cost $800 by Table 8.4's sale; acquired ours).
-- Fixed assets from Chs 5–6: 1 Truck #1, 3 Dock conveyor C-2, 5025
-- Engraving machine #12.
insert into fixed_asset (fixed_asset_id, fixed_asset_type_id, name, date_acquired, description) values
  (5030, 'EQUIPMENT', 'Pen engraver', '1998-07-01', 'Engraves names on pens; sold to Johnson Recycling in Oct 2000');

insert into depreciation_method (depreciation_method_id, description, formula) values
  ('DOUBLE_DECLINING_BALANCE', 'Double-declining balance depreciation', '(purchase cost - salvage cost) * (1 / estimated life in years) * 2'),
  ('STRAIGHT_LINE',            'Straight-line depreciation',            '(purchase cost - salvage cost) / estimated life in years'),
  ('UNITS_OF_PRODUCTION',      'Units-of-production depreciation',      null);   -- ours: no formula recorded yet

-- Table 8.6 (thru +1 day), then ours.
insert into fixed_asset_depreciation_method (fixed_asset_depreciation_method_id, fixed_asset_id, depreciation_method_id, from_date, thru_date) values
  (1, 5030, 'DOUBLE_DECLINING_BALANCE', '1999-01-01', '2000-01-01'),
  (2, 5030, 'STRAIGHT_LINE',            '2000-01-01', null),           -- still open after the sale (NOTES, point 17)
  (3, 1,    'STRAIGHT_LINE',            '1999-01-01', null),
  (4, 5025, 'STRAIGHT_LINE',            '1997-03-10', null),
  (5, 5025, 'UNITS_OF_PRODUCTION',      '2000-01-01', null);           -- DATA ERROR: the old method was never ended

select setval(pg_get_serial_sequence('fixed_asset_depreciation_method', 'fixed_asset_depreciation_method_id'), (select max(fixed_asset_depreciation_method_id) from fixed_asset_depreciation_method));

-- Fig 8.2's depreciations name their asset: 32389 the engraver (Table 8.3),
-- 32390 (a bad row of 8.2's) Truck #1, the "delivery van".
update accounting_transaction set fixed_asset_id = 5030 where accounting_transaction_id = 32389;
update accounting_transaction set fixed_asset_id = 1    where accounting_transaction_id = 32390;

-- Two more depreciations, each with one mistake (ours, 2001, balanced).
insert into accounting_transaction (accounting_transaction_id, accounting_transaction_type_id, from_party_id, to_party_id,
                                    fixed_asset_id, transaction_date, entry_date, description) values
  (32392, 'DEPRECIATION', 12, null, 3,    '2001-03-31', '2001-04-02', 'Depreciation on the dock conveyor'),   -- DATA ERROR: no method in force for the conveyor
  (32393, 'DEPRECIATION', 12, null, null, '2001-06-30', '2001-07-02', 'Depreciation, second quarter');        -- DATA ERROR: depreciation of no asset

insert into transaction_detail (transaction_detail_id, accounting_transaction_id, trans_detail_seq_id, organization_gl_account_id,
                                amount, debit_credit_flag, associated_with_transaction_detail_id) values
  (323921, 32392, 1, 14, 75, 'DEBIT',  null),
  (323922, 32392, 2, 11, 75, 'CREDIT', null),
  (323931, 32393, 1, 14, 60, 'DEBIT',  null),
  (323932, 32393, 2, 11, 60, 'CREDIT', null);

-- ============================================================
-- Fig 8.6 — Budget definition
-- ============================================================
-- ABC Corporation's departments (ours, NOTES point 23): 65 Marketing, 66
-- Administration, 67 Manufacturing operations, each a DEPARTMENT rolling up
-- to ABC Corporation (role 30, its PARENT_ORGANIZATION role from Ch 2).
insert into party (party_id, party_kind) values
  (65, 'ORGANIZATION'),
  (66, 'ORGANIZATION'),
  (67, 'ORGANIZATION');
insert into organization (party_id, organization_type_id, name) values
  (65, 'OTHER_INFORMAL', 'Marketing department'),
  (66, 'OTHER_INFORMAL', 'Administration department'),
  (67, 'OTHER_INFORMAL', 'Manufacturing operations');
select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (85, 65, 'DEPARTMENT', '1999-01-01', null),
  (86, 66, 'DEPARTMENT', '1999-01-01', null),
  (87, 67, 'DEPARTMENT', '1999-01-01', null);
select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into party_relationship (party_relationship_id, party_relationship_type_id, from_party_role_id, to_party_role_id, from_date, thru_date) values
  (18, 'ORGANIZATION_ROLLUP', 85, 30, '1999-01-01', null),
  (19, 'ORGANIZATION_ROLLUP', 86, 30, '1999-01-01', null),
  (20, 'ORGANIZATION_ROLLUP', 87, 30, '1999-01-01', null);
select setval(pg_get_serial_sequence('party_relationship', 'party_relationship_id'), (select max(party_relationship_id) from party_relationship));

-- Calendar periods beside 8.1's fiscal ones.
insert into period_type (period_type_id, description) values
  ('YEAR',  'Year'),
  ('MONTH', 'Month');

insert into standard_time_period (standard_time_period_id, period_type_id, from_date, thru_date) values
  (1, 'YEAR',  '2001-01-01', '2002-01-01'),
  (2, 'MONTH', '2002-06-01', '2002-07-01'),
  (3, 'YEAR',  '2002-01-01', '2003-01-01');
select setval(pg_get_serial_sequence('standard_time_period', 'standard_time_period_id'), (select max(standard_time_period_id) from standard_time_period));

insert into budget_type (budget_type_id, description) values
  ('OPERATING_BUDGET', 'Operating budget: expense items'),
  ('CAPITAL_BUDGET',   'Capital budget: fixed assets and long-term items');

-- Table 8.7, then one of ours.
insert into budget (budget_id, budget_type_id, standard_time_period_id, comment) values
  (29839, 'OPERATING_BUDGET', 1, 'Marketing budget'),
  (38576, 'OPERATING_BUDGET', 2, 'Office expenses budget'),
  (39908, 'CAPITAL_BUDGET',   1, 'New manufacturing machines needed'),
  (40102, 'OPERATING_BUDGET', 3, 'Travel budget');   -- DATA ERROR: no items, and for no one
select setval(pg_get_serial_sequence('budget', 'budget_id'), (select max(budget_id) from budget));

insert into budget_item_type (budget_item_type_id, description) values
  ('TRADE_SHOWS',             'Trade shows'),
  ('ADVERTISING',             'Advertising'),
  ('DIRECT_MAIL',             'Direct mail'),
  ('INTERNET_ADVERTISING',    'Internet advertising'),   -- Table 8.10's added item
  ('OFFICE_SUPPLIES',         'Office supplies'),
  ('FURNITURE',               'Furniture'),
  ('DESKS',                   'Desks'),
  ('CHAIRS',                  'Chairs'),
  ('MANUFACTURING_MACHINES',  'Manufacturing machines'),
  ('ENGRAVING_MACHINE',       'Engraving machine'),
  ('LABELING_MACHINE',        'Labeling machine');

-- Table 8.8 (purpose and justification in our words), then 39908's items and
-- 38576's furniture parts (ours). Item ids are budget id × 10 + seq.
insert into budget_item (budget_item_id, budget_id, budget_item_seq_id, budget_item_type_id, part_of_budget_item_id, amount, purpose, justification) values
  (298391, 29839, 1, 'TRADE_SHOWS',            null,   20000, 'Meet the markets directly',             'Last year''s spend brought three new clients'),
  (298392, 29839, 2, 'ADVERTISING',            null,   30000, 'Make the products known',               'The competition demands product recognition'),
  (298393, 29839, 3, 'DIRECT_MAIL',            null,   15000, 'Generate sales leads',                  'About 50 leads for every $5,000 spent'),
  (385761, 38576, 1, 'OFFICE_SUPPLIES',        null,   5000,  'Supplies for office administration',    'Spent last year, needed again'),
  (385762, 38576, 2, 'FURNITURE',              null,   10000, 'For the new Benjamin Street facility',  'The new facility needs basic furniture'),
  (399081, 39908, 1, 'MANUFACTURING_MACHINES', null,   60000, 'Replace the oldest machines',           'Breakdowns stopped two production runs last year'),
  (399082, 39908, 2, 'ENGRAVING_MACHINE',      399081, 35000, 'Replace the engraver sold in 2000',     'Custom-engraved pens are back-ordered'),
  (399083, 39908, 3, 'LABELING_MACHINE',       399081, 25000, 'A second pencil labeler',               'The labeler runs at capacity'),
  (385763, 38576, 3, 'DESKS',                  385762, 8000,  'Six desks',                             null),
  (385764, 38576, 4, 'CHAIRS',                 385762, 4000,  'Twelve chairs',                         null);   -- DATA ERROR: desks and chairs come to 12,000 of furniture's 10,000

insert into status_type (status_type_id, parent_type_id, description) values
  ('BUDGET_STATUS',    null,            'Budget status'),
  ('BUDGET_CREATED',   'BUDGET_STATUS', 'Created'),
  ('BUDGET_SUBMITTED', 'BUDGET_STATUS', 'Submitted'),
  ('BUDGET_SENT_BACK', 'BUDGET_STATUS', 'Sent back for modifications'),
  ('BUDGET_APPROVED',  'BUDGET_STATUS', 'Approved');

-- Table 8.9, then ours.
insert into budget_status (budget_status_id, budget_id, status_type_id, status_date, comment) values
  (1, 29839, 'BUDGET_CREATED',   '2000-10-15', null),
  (2, 29839, 'BUDGET_SUBMITTED', '2000-11-01', null),
  (3, 29839, 'BUDGET_SENT_BACK', '2000-11-15', 'Management agreed with the kinds of items but asked for every amount to be lowered'),
  (4, 29839, 'BUDGET_SUBMITTED', '2000-11-20', null),
  (5, 29839, 'BUDGET_APPROVED',  '2000-11-30', null),
  (6, 38576, 'BUDGET_CREATED',   '2002-04-20', null),
  (7, 38576, 'BUDGET_SUBMITTED', '2002-05-02', null),
  (8, 39908, 'BUDGET_CREATED',   '2000-10-20', null),
  (9, 39908, 'ORDER_APPROVED',   '2000-12-01', null);   -- DATA ERROR: an order status on a budget
select setval(pg_get_serial_sequence('budget_status', 'budget_status_id'), (select max(budget_status_id) from budget_status));

insert into budget_role_type (budget_role_type_id, description) values
  ('BUDGET_FOR', 'The party the budget is requested for'),
  ('INITIATOR',  'The party who started the budget request');

insert into budget_role (budget_role_id, budget_id, party_id, budget_role_type_id) values
  (1, 29839, 65, 'BUDGET_FOR'),
  (2, 38576, 66, 'BUDGET_FOR'),
  (3, 39908, 67, 'BUDGET_FOR');
select setval(pg_get_serial_sequence('budget_role', 'budget_role_id'), (select max(budget_role_id) from budget_role));

-- ============================================================
-- Fig 8.7b — Budget revisions: revisions and their impacts
-- ============================================================
-- Item 4 of 29839 exists only through revision 1.1, which added it (NOTES,
-- point 22).
insert into budget_item (budget_item_id, budget_id, budget_item_seq_id, budget_item_type_id, part_of_budget_item_id, amount, purpose, justification) values
  (298394, 29839, 4, 'INTERNET_ADVERTISING', null, 5000, 'Reach buyers online', 'Cheaper per lead than direct mail');

-- Table 8.10's two revisions, dated between the send-back (Nov 15) and the
-- resubmission (Nov 20), ours; then a bad revision of 38576.
insert into budget_revision (budget_revision_id, budget_id, revision_seq_id, date_revised) values
  (1, 29839, 1, '2000-11-17'),
  (2, 29839, 2, '2000-11-19'),
  (3, 38576, 1, '2002-05-20');
select setval(pg_get_serial_sequence('budget_revision', 'budget_revision_id'), (select max(budget_revision_id) from budget_revision));

insert into budget_revision_impact (budget_revision_impact_id, budget_revision_id, budget_item_id, revised_amount, add_delete_flag, revision_reason) values
  (1, 1, 298392, -10000, null,  'Advertising had to be cut substantially'),
  (2, 1, 298393, -7000,  null,  'Direct mail had to be cut substantially'),
  (3, 1, 298394, 5000,   'ADD', 'A budget for Internet advertising is needed'),
  (4, 2, 298393, -2000,  null,  'Direct mail still needs to come down'),
  (5, 3, 298391, -1000,  null,  'Trade show stands paid from admin'),   -- DATA ERROR: an item of the marketing budget, revised in the office budget
  (6, 3, 385761, -6000,  null,  'Supplies cut to the bone');           -- DATA ERROR: office supplies 5,000 cut by 6,000
select setval(pg_get_serial_sequence('budget_revision_impact', 'budget_revision_impact_id'), (select max(budget_revision_impact_id) from budget_revision_impact));
