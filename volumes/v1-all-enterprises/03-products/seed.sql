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

-- ============================================================
-- Fig 3.3 — Product identification
-- ============================================================
insert into identification_type (identification_type_id, description, value_pattern) values
  ('MANUFACTURER_ID', 'Manufacturer''s id number',                 null),
  ('SKU',             'Stock-keeping unit (our own product code)', null),
  ('UPCA',            'Universal Product Code, 12 digits',         '^[0-9]{12}$'),
  ('UPCE',            'Universal Product Code, compressed 8 digits', '^[0-9]{8}$'),
  ('ISBN',            'International Standard Book Number (10 or 13, no hyphens)', '^([0-9]{9}[0-9X]|97[89][0-9]{10})$'),
  ('OTHER',           'Other identifier',                          null);

insert into good_identification (product_id, identification_type_id, id_value) values
  -- the book's Table 3.1 codes are really our SKUs
  (1,  'SKU',             'PAP192'),
  (1,  'UPCA',            '036000291452'),
  (1,  'MANUFACTURER_ID', 'JFG-8511-20'),
  (2,  'SKU',             'PEN202'),
  (2,  'UPCA',            '012345678905'),
  (2,  'MANUFACTURER_ID', 'GE-ELITE'),
  (3,  'SKU',             'DSK401'),
  (3,  'UPCE',            '01234565'),
  (4,  'SKU',             'FRMCHFA1500'),
  (5,  'SKU',             'CNS109'),          -- a service with a code: fine, since the link is to PRODUCT
  (6,  'SKU',             'CPY900'),
  (6,  'MANUFACTURER_ID', 'OJ-900'),
  (6,  'UPCA',            '012345678905'),    -- DATA ERROR: same UPC as the pen (caught by a query)
  (7,  'SKU',             'BKS001'),
  (7,  'ISBN',            '9780471380238'),
  (8,  'SKU',             'SVC-CPY-MNT'),
  (9,  'SKU',             'TYP001'),
  (9,  'UPCA',            '07325200016'),     -- DATA ERROR: 11 digits (caught by a query)
  (10, 'SKU',             'TNR100'),
  (10, 'SKU',             'TNR-100');         -- DATA ERROR: a second SKU for one product (caught by a query)

-- ============================================================
-- Fig 3.4 — Product features and units of measure
-- ============================================================
insert into unit_of_measure (uom_id, abbreviation, description) values
  ('EA',   'ea',  'Each'),
  ('BOX',  'bx',  'Box'),
  ('REAM', 'rm',  'Ream'),
  ('IN',   'in',  'Inch'),
  ('CM',   'cm',  'Centimetre'),
  ('LB',   'lb',  'Pound'),
  ('KG',   'kg',  'Kilogram'),
  ('HR',   'hr',  'Hour'),
  ('MB',   'MB',  'Megabyte'),
  ('PPM',  'ppm', 'Pages per minute');

insert into unit_of_measure_conversion (from_uom_id, to_uom_id, conversion_factor) values
  ('REAM', 'EA', 500),     -- a ream is 500 sheets
  ('BOX',  'EA', 10),      -- a box of diskettes holds 10
  ('IN',   'CM', 2.54),
  ('CM',   'IN', 0.3937),
  ('LB',   'KG', 0.4536),
  ('KG',   'LB', 2.0);     -- DATA ERROR: disagrees with LB -> KG (caught by a query)

update product set uom_id = case product_id
  when 1  then 'REAM'
  when 2  then 'EA'
  when 3  then 'BOX'
  when 4  then 'BOX'
  when 5  then 'HR'
  when 6  then 'EA'
  when 7  then 'EA'
  when 9  then 'EA'
  when 10 then 'EA'
end;   -- product 8 (maintenance plan) has no unit: the link is optional

insert into product_feature_category (product_feature_category_id, description) values
  (1, 'Paper specifications'),
  (2, 'Copier options'),
  (3, 'Billing options'),
  (4, 'General appearance');

select setval(pg_get_serial_sequence('product_feature_category', 'product_feature_category_id'), (select max(product_feature_category_id) from product_feature_category));

insert into product_feature_type (product_feature_type_id, description) values
  ('PRODUCT_QUALITY', 'Product quality'),
  ('COLOR',           'Color'),
  ('DIMENSION',       'Dimension (a number in a unit)'),
  ('SIZE',            'Size (a label: S/M/L, Letter, 3½-inch)'),
  ('BRAND',           'Brand'),
  ('SOFTWARE',        'Software feature'),
  ('HARDWARE',        'Hardware feature'),
  ('BILLING',         'Billing feature'),
  ('OTHER',           'Other feature');

insert into product_feature (product_feature_id, product_feature_type_id, product_feature_category_id, description, number_specified, uom_id) values
  (1,  'PRODUCT_QUALITY', 1,    'Fine grade',                null, null),
  (2,  'COLOR',           4,    'White',                     null, null),
  (3,  'COLOR',           4,    'Blue',                      null, null),
  (4,  'COLOR',           4,    'Black',                     null, null),
  (5,  'COLOR',           4,    'Red',                       null, null),
  (6,  'DIMENSION',       1,    'Width',                     8.5,  'IN'),
  (7,  'DIMENSION',       1,    'Length',                    11,   'IN'),
  (8,  'DIMENSION',       1,    'Basis weight',              20,   'LB'),
  (9,  'BRAND',           4,    'Johnson',                   null, null),
  (10, 'BRAND',           4,    'Goldstein',                 null, null),
  (11, 'SIZE',            null, '3½-inch',                   null, null),
  (12, 'DIMENSION',       null, 'Capacity',                  1.44, 'MB'),
  (13, 'HARDWARE',        2,    'Duplex unit',               null, null),
  (14, 'HARDWARE',        2,    'Stapling finisher',         null, null),
  (15, 'HARDWARE',        2,    'Large-capacity paper tray', null, null),
  (16, 'HARDWARE',        2,    'Desktop stand',             null, null),
  (17, 'HARDWARE',        2,    'Network card',              null, null),
  (18, 'SOFTWARE',        2,    'Scan-to-email',             null, null),
  (19, 'DIMENSION',       2,    'Print speed',               35,   'PPM'),
  (20, 'BILLING',         3,    'Hourly billing',            null, 'HR'),
  (21, 'BILLING',         3,    'Fixed-fee billing',         null, null),
  (22, 'DIMENSION',       null, 'Height',                    null, 'IN'),   -- DATA ERROR: a dimension with no number (caught by a query)
  (23, 'COLOR',           4,    'Grey',                      30,   null);   -- DATA ERROR: a number on a colour (caught by a query)

select setval(pg_get_serial_sequence('product_feature', 'product_feature_id'), (select max(product_feature_id) from product_feature));

insert into product_feature_applicability_type (product_feature_applicability_type_id, description) values
  ('REQUIRED',   'Always part of the product; cannot be removed'),
  ('STANDARD',   'Included by default'),
  ('OPTIONAL',   'Not included; may be added'),
  ('SELECTABLE', 'One must be chosen from the selectable features of the same type');

insert into product_feature_applicability (product_id, product_feature_id, product_feature_applicability_type_id, from_date, thru_date) values
  -- bond paper
  (1, 1,  'REQUIRED',   '1995-01-01', null),
  (1, 2,  'STANDARD',   '1995-01-01', null),
  (1, 6,  'REQUIRED',   '1995-01-01', null),
  (1, 7,  'REQUIRED',   '1995-01-01', null),
  (1, 8,  'REQUIRED',   '1995-01-01', null),
  (1, 9,  'REQUIRED',   '1995-01-01', null),
  -- pen: pick a colour; red was dropped in 2020
  (2, 3,  'SELECTABLE', '1998-06-01', null),
  (2, 4,  'SELECTABLE', '1998-06-01', null),
  (2, 5,  'SELECTABLE', '1998-06-01', '2020-01-01'),
  (2, 10, 'REQUIRED',   '1998-06-01', null),
  -- diskettes
  (3, 11, 'REQUIRED',   '1990-01-01', null),
  (3, 12, 'REQUIRED',   '1990-01-01', null),
  -- consulting: choose how it's billed
  (5, 20, 'SELECTABLE', '2003-01-01', null),
  (5, 21, 'SELECTABLE', '2010-01-01', null),
  -- copier
  (6, 19, 'STANDARD',   '2019-01-01', null),
  (6, 17, 'STANDARD',   '2019-01-01', null),
  (6, 23, 'STANDARD',   '2019-01-01', null),
  (6, 13, 'OPTIONAL',   '2019-01-01', null),
  (6, 14, 'OPTIONAL',   '2019-01-01', null),
  (6, 15, 'OPTIONAL',   '2019-01-01', null),
  (6, 16, 'OPTIONAL',   '2019-01-01', null),
  (6, 18, 'OPTIONAL',   '2019-01-01', null);

insert into product_feature_interaction_type (product_feature_interaction_type_id, description) values
  ('DEPENDENCY',      'Choosing the feature requires the factor feature'),
  ('INCOMPATIBILITY', 'The two features cannot be chosen together');

insert into product_feature_interaction (product_feature_interaction_type_id, product_feature_id, factor_product_feature_id, product_id) values
  ('DEPENDENCY',      14, 13, 6),     -- the stapling finisher needs the duplex unit (on the copier)
  ('INCOMPATIBILITY', 15, 16, 6),     -- the big paper tray doesn't fit on the desktop stand
  ('DEPENDENCY',      18, 17, null),  -- scan-to-email needs a network card, on any product
  ('DEPENDENCY',      16, 15, 6),     -- DATA ERROR: contradicts the incompatibility above (caught by a query)
  ('INCOMPATIBILITY', 5,  1,  2);     -- DATA ERROR: "fine grade" is not a pen feature (caught by a query)
