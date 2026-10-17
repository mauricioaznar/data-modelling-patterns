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

-- every GOOD product, plus one service by mistake
insert into good (product_id) values
  (1), (2), (3), (4), (6), (7), (9), (10),
  (8);                                        -- DATA ERROR: the maintenance plan is a SERVICE (caught by a query)

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
  (6,  'SKU',             'CPY900'),
  (6,  'MANUFACTURER_ID', 'OJ-900'),
  (6,  'UPCA',            '012345678905'),    -- DATA ERROR: same UPC as the pen (caught by a query)
  (7,  'SKU',             'BKS001'),
  (7,  'ISBN',            '9780471380238'),
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
  (20, 'BILLING',         3,    'Hourly billing',            null, 'HR'),   -- DATA ERROR: only dimensions take a unit (caught by a query)
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

-- ============================================================
-- Fig 3.5 — Suppliers and manufacturers
-- ============================================================
-- New organizations for this chapter (ids from 40, clear of Ch 2's).
-- Fantastic Supplies (18, SUPPLIER since 2001) and Northwind (4, internal)
-- come from Ch 2.
insert into party (party_id, party_kind) values
  (40, 'ORGANIZATION'),   -- Johnson Paper Mills: makes the paper, and sells it to us directly
  (41, 'ORGANIZATION'),   -- Goldstein Pen Co.: makes the pen
  (42, 'ORGANIZATION');   -- Paperline Distributors: a wholesaler

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (40, 'CORPORATION', 'Johnson Paper Mills'),
  (41, 'CORPORATION', 'Goldstein Pen Co.'),
  (42, 'CORPORATION', 'Paperline Distributors');

-- Goldstein gets no SUPPLIER role on purpose (see the supplier_product rows).
insert into party_role (party_id, role_type_id, from_date, thru_date) values
  (40, 'SUPPLIER', '1995-01-01', null),
  (42, 'SUPPLIER', '2010-01-01', null);

update product set manufacturer_party_id = case product_id
  when 1 then 40   -- Johnson paper
  when 2 then 41   -- Goldstein pen
  when 6 then 16   -- ACME Company makes the copier
  end
where product_id in (1, 2, 6);

insert into preference_type (preference_type_id, description) values
  ('FIRST_CHOICE',  'Order from this supplier first'),
  ('SECOND_CHOICE', 'Use when the first choice can''t deliver'),
  ('LAST_RESORT',   'Only in an emergency');

insert into rating_type (rating_type_id, description) values
  ('OUTSTANDING', 'Outstanding'),
  ('GOOD',        'Good'),
  ('FAIR',        'Fair'),
  ('POOR',        'Poor');

insert into supplier_product (product_id, supplier_party_id, available_from_date, available_thru_date, standard_lead_time, preference_type_id, rating_type_id, comment) values
  -- the paper has three sources: the mill itself, a wholesaler, and one we dropped
  (1, 40, '1995-01-01', null,         5,    'FIRST_CHOICE',  'OUTSTANDING', 'Straight from the mill'),
  (1, 42, '2010-01-01', null,         2,    'SECOND_CHOICE', 'GOOD',        'Faster but dearer'),
  (1, 18, '2001-04-05', '2020-01-01', 10,   'LAST_RESORT',   'POOR',        'Dropped after late deliveries'),
  (2, 18, '2001-04-05', null,         7,    'FIRST_CHOICE',  'FAIR',        null),
  (7, 42, '2015-01-01', null,         null, null,            null,          'Books: no preference or rating recorded'),
  (8, 5,  '2019-01-01', null,         1,    'FIRST_CHOICE',  'GOOD',        'A service can have a supplier: Contoso subcontracts the maintenance'),
  (2, 41, '2020-01-01', null,         14,   'SECOND_CHOICE', 'GOOD',        'DATA ERROR: Goldstein has no SUPPLIER role (caught by a query)'),
  (1, 42, '2024-06-01', null,         3,    'SECOND_CHOICE', 'GOOD',        'DATA ERROR: overlaps the Paperline row above (caught by a query)');

-- Reorder guidelines (goods only). Chatham warehouse is Ch 2 facility 5,
-- Illinois is geographic boundary 10, Northwind is party 4.
insert into reorder_guideline (product_id, geographic_boundary_id, facility_id, internal_organization_party_id, from_date, thru_date, reorder_quantity, reorder_level) values
  (1, null, 5,    null, '2020-01-01', null,         200,  50),    -- paper at the Chatham warehouse
  (1, 10,   null, null, '2020-01-01', null,         2000, 500),   -- paper across Illinois
  (2, null, 5,    null, '2018-01-01', '2025-01-01', 50,   10),    -- pen at Chatham, old rule ...
  (2, null, 5,    null, '2025-01-01', null,         100,  20),    -- ... replaced by a bigger one
  (2, null, null, 4,    '2020-01-01', null,         500,  100),   -- pens for Northwind as a whole
  (6, null, 5,    null, '2019-01-01', null,         1,    1),     -- keep at least one copier in stock
  (1, null, 5,    null, '2024-01-01', null,         300,  80),    -- DATA ERROR: overlaps the first Chatham paper rule (caught by a query)
  (2, null, null, 16,   '2022-01-01', null,         10,   5);     -- DATA ERROR: ACME is a customer, not an internal organization (caught by a query)

-- ============================================================
-- Fig 3.6 — Inventory items
-- ============================================================
-- Ch 2 facilities: 5 Chatham warehouse, 8 Old Springfield warehouse.
insert into inventory_item_status_type (inventory_item_status_type_id, description) values
  ('GOOD',             'Good, sellable'),
  ('BEING_REPAIRED',   'Being repaired'),
  ('SLIGHTLY_DAMAGED', 'Slightly damaged: sell at a discount'),
  ('DEFECTIVE',        'Defective'),
  ('SCRAP',            'Scrap');

insert into lot (lot_id, creation_date, quantity, expiration_date) values
  (1, '2026-06-01', 300, null),           -- a paper run from the mill
  (2, '2025-01-15', 50,  '2026-03-01'),   -- pens: the ink expires (lot already expired)
  (3, '2026-09-01', 20,  '2026-08-01');   -- DATA ERROR: expires before it was created (caught by a query)

select setval(pg_get_serial_sequence('lot', 'lot_id'), (select max(lot_id) from lot));

insert into container_type (container_type_id, description) values
  ('BIN',   'Bin'),
  ('SHELF', 'Shelf'),
  ('CAGE',  'Locked cage');

insert into container (container_id, container_type_id, facility_id, description) values
  (1, 'BIN',   5, 'Bin A-12'),
  (2, 'SHELF', 5, 'Shelf B-3'),
  (3, 'CAGE',  8, 'High-value cage');

select setval(pg_get_serial_sequence('container', 'container_id'), (select max(container_id) from container));

insert into inventory_item (inventory_item_id, inventory_item_kind, product_id, inventory_item_status_type_id, lot_id, facility_id, container_id, serial_num, quantity_on_hand) values
  (1,  'NON_SERIALIZED', 1, 'GOOD',             1,    5,    null, null,         30),   -- paper loose on the Chatham floor
  (2,  'NON_SERIALIZED', 1, 'GOOD',             1,    null, 1,    null,         10),   -- more of the same lot in Bin A-12 (still Chatham)
  (3,  'NON_SERIALIZED', 1, 'SLIGHTLY_DAMAGED', null, 8,    null, null,         5),    -- damaged reams at Old Springfield
  (4,  'NON_SERIALIZED', 2, 'GOOD',             2,    null, 2,    null,         15),   -- pens from the expired lot
  (5,  'SERIALIZED',     6, 'GOOD',             null, 5,    null, 'OJ900-0001', null),
  (6,  'SERIALIZED',     6, 'BEING_REPAIRED',   null, null, 3,    'OJ900-0002', null),
  (7,  'NON_SERIALIZED', 7, 'GOOD',             null, 8,    null, null,         3),
  (8,  'SERIALIZED',     6, 'GOOD',             null, 8,    null, 'OJ900-0001', null), -- DATA ERROR: serial already used by item 5 (caught by a query)
  (9,  'NON_SERIALIZED', 3, 'SCRAP',            null, 8,    null, 'DSK-77',     40);   -- DATA ERROR: a serial number on non-serialized stock (caught by a query)

select setval(pg_get_serial_sequence('inventory_item', 'inventory_item_id'), (select max(inventory_item_id) from inventory_item));

insert into reason (reason_id, description) values
  ('THEFT',    'Theft'),
  ('DAMAGE',   'Damaged in storage'),
  ('MISCOUNT', 'Earlier count was wrong'),
  ('FOUND',    'Found stock not on record');

insert into inventory_item_variance (inventory_item_id, physical_inventory_date, quantity, reason_id, comment) values
  (1, '2026-09-30', -3, 'DAMAGE',   'Water leak'),
  (2, '2026-09-30',  2, 'FOUND',    'Two reams behind the bin'),
  (7, '2026-09-30', -1, 'THEFT',    null),
  (1, '2026-09-30', -1, 'MISCOUNT', 'DATA ERROR: a second variance for item 1 on the same count date (caught by a query)');

-- ============================================================
-- Fig 3.7 — Standard product pricing
-- ============================================================
-- Ch 2 geography: 1 Mexico, 2 Spain, 13 Springfield (in Illinois, the US,
-- the Midwest Sales territory 30 and North America 31).
-- Ch 2 parties: Northwind (4) sets our prices; ACME (16) makes the copier;
-- Contoso (5) is classified IND_LOGISTICS.
insert into unit_of_measure (uom_id, abbreviation, description) values
  ('USD',   'USD', 'US dollar'),
  ('EUR',   'EUR', 'Euro'),
  ('MONTH', 'mo',  'Month'),
  ('YEAR',  'yr',  'Year'),
  ('PAGE',  'pg',  'Printed page');

insert into time_frequency_measure (uom_id) values ('HR'), ('MONTH'), ('YEAR');
insert into currency_measure (uom_id) values ('USD'), ('EUR');

insert into quantity_break (quantity_break_id, from_quantity, thru_quantity) values
  (1, 1,    100),
  (2, 100,  1000),
  (3, 1000, null);

insert into order_value (order_value_id, from_amount, thru_amount) values
  (1, 0,    500),
  (2, 500,  2000),
  (3, 2000, null);

select setval(pg_get_serial_sequence('quantity_break', 'quantity_break_id'), (select max(quantity_break_id) from quantity_break));
select setval(pg_get_serial_sequence('order_value', 'order_value_id'), (select max(order_value_id) from order_value));

insert into sale_type (sale_type_id, description) values
  ('INTERNET', 'Internet sale'),
  ('CATALOG',  'Catalog sale'),
  ('STORE',    'In-store sale');

insert into price_component_type (price_component_type_id, description) values
  ('BASE_PRICE', 'Base price'),
  ('DISCOUNT',   'Discount component'),
  ('SURCHARGE',  'Surcharge component'),
  ('MSRP',       'Manufacturer suggested price');

insert into price_component (price_component_id, price_component_type_id, charge_kind, from_date, thru_date, price, percent, currency_uom_id,
                             product_id, product_feature_id, pricer_party_id,
                             geographic_boundary_id, party_type_id, product_category_id, quantity_break_id, order_value_id, sale_type_id,
                             per_uom_id, quantity, comment) values
  -- bond paper (a ream): a price change, and a cheaper regional base price
  (1,  'BASE_PRICE', null,          '2020-01-01', '2025-01-01', 38.00,   null, 'USD', 1,    null, 4,    null, null,            null, null, null, null,       null,    null, 'Old list price'),
  (2,  'BASE_PRICE', null,          '2025-01-01', null,         42.00,   null, 'USD', 1,    null, 4,    null, null,            null, null, null, null,       null,    null, 'List price'),
  (3,  'BASE_PRICE', null,          '2025-01-01', null,         40.00,   null, 'USD', 1,    null, 4,    30,   null,            null, null, null, null,       null,    null, 'Midwest Sales territory price'),
  (4,  'MSRP',       null,          '2025-01-01', null,         45.00,   null, 'USD', 1,    null, 40,   null, null,            null, null, null, null,       null,    null, 'Johnson''s suggested price'),
  (5,  'DISCOUNT',   null,          '2020-01-01', null,         null,    5,    null,  1,    null, null, null, null,            null, 2,    null, null,       null,    null, '100 to 999 reams'),
  (6,  'DISCOUNT',   null,          '2020-01-01', null,         null,    10,   null,  1,    null, null, null, null,            null, 3,    null, null,       null,    null, '1000 reams or more'),
  (7,  'SURCHARGE',  null,          '2020-01-01', null,         3.00,    null, 'USD', 1,    null, null, 1,    null,            null, null, null, null,       null,    null, 'Shipping paper to Mexico'),
  -- rules for no single product: a category, a party type, an order size, a channel
  (8,  'DISCOUNT',   null,          '2022-01-01', null,         null,    3,    null,  null, null, null, null, 'IND_LOGISTICS', 1,    null, null, null,       null,    null, 'Logistics companies: 3% off anything under Office supplies'),
  (9,  'DISCOUNT',   null,          '2022-01-01', null,         null,    2,    null,  null, null, null, null, null,            null, null, 2,    null,       null,    null, 'Orders of 500 to 1999 USD'),
  (10, 'DISCOUNT',   null,          '2022-01-01', null,         null,    4,    null,  null, null, null, null, null,            null, null, 3,    null,       null,    null, 'Orders of 2000 USD or more'),
  (11, 'DISCOUNT',   null,          '2024-01-01', null,         null,    1,    null,  null, null, null, null, null,            null, null, null, 'INTERNET', null,    null, 'Internet orders'),
  -- the pen, and a book priced in euros for Spain
  (12, 'BASE_PRICE', null,          '1998-06-01', null,         2.50,    null, 'USD', 2,    null, 4,    null, null,            null, null, null, null,       null,    null, null),
  (13, 'BASE_PRICE', null,          '2015-01-01', null,         59.95,   null, 'USD', 7,    null, 4,    null, null,            null, null, null, null,       null,    null, null),
  (14, 'BASE_PRICE', null,          '2015-01-01', null,         54.00,   null, 'EUR', 7,    null, 4,    2,    null,            null, null, null, null,       null,    null, 'Spain'),
  -- the copier and its options: feature prices, on this product or on any
  (15, 'BASE_PRICE', null,          '2019-01-01', null,         3500.00, null, 'USD', 6,    null, 4,    null, null,            null, null, null, null,       null,    null, null),
  (16, 'MSRP',       null,          '2019-01-01', null,         3999.00, null, 'USD', 6,    null, 16,   null, null,            null, null, null, null,       null,    null, 'ACME''s suggested price'),
  (17, 'BASE_PRICE', null,          '2019-01-01', null,         250.00,  null, 'USD', 6,    13,   4,    null, null,            null, null, null, null,       null,    null, 'Duplex unit, on the OfficeJet'),
  (18, 'BASE_PRICE', null,          '2019-01-01', null,         180.00,  null, 'USD', null, 14,   4,    null, null,            null, null, null, null,       null,    null, 'Stapling finisher, on any copier'),
  -- services: charged per hour, per month, per page, and once
  (19, 'BASE_PRICE', 'UTILIZATION', '2003-01-01', null,         150.00,  null, 'USD', 5,    null, 4,    null, null,            null, null, null, null,       'HR',    null, 'Consulting by the hour'),
  (20, 'BASE_PRICE', 'RECURRING',   '2019-01-01', null,         99.00,   null, 'USD', 8,    null, 4,    null, null,            null, null, null, null,       'MONTH', null, 'Maintenance plan fee'),
  (21, 'BASE_PRICE', 'UTILIZATION', '2019-01-01', null,         5.00,    null, 'USD', 8,    null, 4,    null, null,            null, null, null, null,       'PAGE',  1000, 'Plus 5 USD per 1000 pages printed'),
  (22, 'BASE_PRICE', 'ONE_TIME',    '2019-01-01', null,         200.00,  null, 'USD', 8,    null, 4,    null, null,            null, null, null, null,       null,    null, 'Set-up fee'),
  -- bad rows
  (23, 'DISCOUNT',   null,          '2024-01-01', null,         1.00,    5,    'USD', 2,    null, null, null, null,            null, 2,    null, null,       null,    null, 'DATA ERROR: an amount AND a percent (caught by a query)'),
  (24, 'BASE_PRICE', 'RECURRING',   '2027-01-01', null,         30.00,   null, 'USD', 10,   null, 4,    null, null,            null, null, null, null,       'EA',    null, 'DATA ERROR: recurring "per each" is not a time frequency (caught by a query)'),
  (25, 'BASE_PRICE', null,          '2024-01-01', null,         2.75,    null, 'USD', 2,    null, 4,    null, null,            null, null, null, null,       null,    null, 'DATA ERROR: overlaps the pen''s 2.50 under the same conditions (caught by a query)');

select setval(pg_get_serial_sequence('price_component', 'price_component_id'), (select max(price_component_id) from price_component));
