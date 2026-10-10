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
