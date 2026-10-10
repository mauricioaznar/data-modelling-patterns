-- Vol 1, Chapter 3 seed data.
-- An office-supply company (the book's Table 3.1 products plus a few more).
-- Aim for data that exercises the tricky cases (history, hierarchies,
-- conflicting rules), not just the happy path.

-- ============================================================
-- Fig 3.1 — Products
-- ============================================================
insert into product (product_id, product_kind, name, introduction_date, sales_discontinuation_date, support_discontinuation_date, comment) values
  (1, 'GOOD',    'Johnson fine grade 8½ by 11 inch bond paper',          '1995-01-01', null,         null,         'Book code PAP192'),
  (2, 'GOOD',    'Goldstein Elite pen',                                   '1998-06-01', null,         null,         'Book code PEN202'),
  (3, 'GOOD',    'Jerry''s box of 3½-inch diskettes',                     '1990-01-01', '2006-01-01', '2009-01-01', 'Book code DSK401; still supported for 3 years after sales stopped'),
  (4, 'GOOD',    'Preprinted forms for insurance claims',                 '2001-03-01', null,         null,         'Book code FRMCHFA1500'),
  (5, 'SERVICE', 'Office supply inventory management consulting service', '2003-01-01', null,         null,         'Book code CNS109'),
  (6, 'GOOD',    'OfficeJet 900 copier',                                  '2019-01-01', null,         null,         'Configurable: used by Fig 3.4'),
  (7, 'GOOD',    'The Data Model Resource Book, Vol 1',                   '2001-04-01', null,         null,         'Has an ISBN (Fig 3.3)'),
  (8, 'SERVICE', 'Copier maintenance plan',                               '2019-01-01', null,         null,         null),
  (9, 'GOOD',    'Typewriter ribbon',                                     '1980-01-01', '2004-01-01', '2002-01-01', 'DATA ERROR: support ends before sales end (caught by a query)'),
  (10,'GOOD',    'Laser printer toner (coming soon)',                     '2027-01-01', null,         null,         'Not yet introduced');

select setval(pg_get_serial_sequence('product', 'product_id'), (select max(product_id) from product));

-- ============================================================
-- Fig 3.2 — Product categories
-- ============================================================
insert into product_category_type (product_category_type_id, description) values
  ('USAGE',     'What the product is used for'),
  ('INDUSTRY',  'The industry the product is made for'),
  ('MATERIALS', 'What the product is made of');

insert into product_category (product_category_id, product_category_type_id, description) values
  (1,  'USAGE',     'Office supplies'),
  (2,  'USAGE',     'Paper'),
  (3,  'USAGE',     'Bond paper'),
  (4,  'USAGE',     'Writing instruments'),
  (5,  'USAGE',     'Computer supplies'),
  (6,  'USAGE',     'Computer media'),
  (7,  'USAGE',     'Business forms'),
  (8,  'USAGE',     'Printed materials'),
  (9,  'USAGE',     'Books'),
  (10, 'USAGE',     'Services'),
  (11, 'USAGE',     'Consulting'),
  (12, 'USAGE',     'Maintenance'),
  (13, 'USAGE',     'Office equipment'),
  (20, 'INDUSTRY',  'Insurance'),
  (30, 'MATERIALS', 'Paper-based'),
  (31, 'MATERIALS', 'Plastic'),
  (32, 'MATERIALS', 'Recycled'),
  (33, 'MATERIALS', 'Recycled paper');

select setval(pg_get_serial_sequence('product_category', 'product_category_id'), (select max(product_category_id) from product_category));

insert into product_category_rollup (parent_product_category_id, child_product_category_id) values
  (1, 2),    -- Office supplies > Paper
  (2, 3),    -- Paper > Bond paper
  (1, 4),    -- Office supplies > Writing instruments
  (1, 5),    -- Office supplies > Computer supplies
  (5, 6),    -- Computer supplies > Computer media
  (1, 8),    -- Office supplies > Printed materials
  (8, 9),    -- Printed materials > Books
  (2, 7),    -- Paper > Business forms ...
  (8, 7),    -- ... and Printed materials > Business forms (two parents)
  (10, 11),  -- Services > Consulting
  (10, 12),  -- Services > Maintenance
  (32, 33),  -- Recycled > Recycled paper
  (33, 32);  -- DATA ERROR: Recycled paper > Recycled closes a cycle (caught by a query)

insert into product_category_classification (product_id, product_category_id, from_date, thru_date, primary_flag, comment) values
  (1, 3,  '1995-01-01', null,         true,  null),
  (1, 30, '1995-01-01', null,         false, null),
  (2, 4,  '1998-06-01', null,         true,  null),
  (2, 31, '1998-06-01', null,         true,  'DATA ERROR: a second current primary category (caught by a query)'),
  (3, 5,  '1990-01-01', '2000-01-01', true,  'Recategorised in 2000'),
  (3, 6,  '2000-01-01', null,         true,  null),
  (3, 31, '1990-01-01', null,         false, null),
  (4, 7,  '2001-03-01', null,         true,  null),
  (4, 20, '2001-03-01', null,         false, 'Industry dimension'),
  (4, 30, '2001-03-01', null,         false, null),
  (5, 11, '2003-01-01', null,         true,  null),
  (6, 13, '2019-01-01', null,         true,  null),
  (7, 9,  '2001-04-01', null,         true,  null),
  (8, 12, '2019-01-01', null,         true,  null),
  (9, 1,  '1980-01-01', null,         true,  null);
  -- product 10 (toner) has no category yet (caught by a query)

insert into market_interest (product_category_id, party_type_id, from_date, thru_date) values
  (1,  'IND_WHOLESALE',    '2010-01-01', null),
  (2,  'IND_PUBLIC_ADMIN', '2015-01-01', null),
  (7,  'IND_PUBLIC_ADMIN', '2015-01-01', null),
  (6,  'IND_LOGISTICS',    '2005-01-01', '2012-01-01'),   -- interest faded with diskettes
  (13, 'IND_LOGISTICS',    '2019-01-01', null),
  (11, 'SIZE_LARGE',       '2010-01-01', null),
  (11, 'SIZE_MEDIUM',      '2020-01-01', null),
  (9,  'INCOME_HIGH',      '2018-01-01', null);
