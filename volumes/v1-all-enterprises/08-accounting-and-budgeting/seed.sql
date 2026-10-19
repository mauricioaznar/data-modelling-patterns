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
