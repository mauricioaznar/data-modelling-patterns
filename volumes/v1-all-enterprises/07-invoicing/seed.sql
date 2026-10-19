-- Vol 1, Chapter 7 seed data.
-- ABC Subsidiary bills ACME for Ch 4's office supply order, and John Smith
-- for a book and a copier; the tricky cases are adjustments on items, a
-- correction on a later bill, features tied to their product line, and
-- accounts with changing payers.
--
-- Parties: 13 ABC Subsidiary, 16 ACME (the book's ACME Corporation; Ch 2
-- called it ACME Company), 18 Fantastic Supplies, 47 William Jones, 50 Rosa
-- Diaz, 54 John Smith and 58 Jane Smith (Ch 6's, now also customers).
-- Products (Ch 3): 1 bond paper, 2 Goldstein pen, 3 HD 3½-inch diskettes,
-- 6 OfficeJet copier, 7 the Data Model Resource Book.

-- ============================================================
-- Fig 7.1a — Invoice and invoice items
-- ============================================================
insert into invoice_item_type (invoice_item_type_id, parent_type_id, description) values
  ('ACQUIRING_ITEM',        null,             'What the party actually got (grouping row)'),
  ('PRODUCT_ITEM',          'ACQUIRING_ITEM', 'Product'),
  ('FEATURE_ITEM',          'ACQUIRING_ITEM', 'Product feature'),
  ('WORK_EFFORT_ITEM',      'ACQUIRING_ITEM', 'Work effort'),
  ('TIME_ENTRY_ITEM',       'ACQUIRING_ITEM', 'Time entry'),
  ('ADJUSTMENT',            null,             'Adjustment (grouping row)'),
  ('MISC_CHARGE',           'ADJUSTMENT',     'Miscellaneous charge'),
  ('DISCOUNT',              'ADJUSTMENT',     'Discount'),
  ('SURCHARGE',             'ADJUSTMENT',     'Surcharge'),
  ('SALES_TAX',             'ADJUSTMENT',     'Sales tax'),
  ('SHIPPING_AND_HANDLING', 'ADJUSTMENT',     'Shipping and handling'),
  ('FEE',                   'ADJUSTMENT',     'Fee');

-- Table 7.3's glossy finish isn't in Ch 3's feature list.
insert into product_feature (product_feature_id, product_feature_type_id, product_feature_category_id, description, number_specified, uom_id) values
  (25, 'PRODUCT_QUALITY', null, 'Extra glossy finish', null, null);

select setval(pg_get_serial_sequence('product_feature', 'product_feature_id'), (select max(product_feature_id) from product_feature));

-- New people: 61 Joe Smith (on account 1459 in 7.3a), 62 Tom Jones.
insert into party (party_id, party_kind) values
  (61, 'PERSON'),
  (62, 'PERSON');

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into person (party_id, gender_type_id) values
  (61, 'MALE'),
  (62, 'MALE');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  (61, 'FIRST', '1980-01-01', null, 'Joe'),
  (61, 'LAST',  '1980-01-01', null, 'Smith'),
  (62, 'FIRST', '1980-01-01', null, 'Tom'),
  (62, 'LAST',  '1980-01-01', null, 'Jones');

-- Tables 7.1 and 7.4. The billed parties go in now because 7.2 makes the
-- sender mandatory and 7.3a's arc wants a party or an account; 7.2's
-- section adds where each bill went. 30010 is Table 7.4's ACME bill to Tom
-- Jones, neither our sale nor our purchase (NOTES, point 7). 30011 and
-- 30016 onwards are ours. Invoices on account come in 7.3a.
insert into invoice (invoice_id, invoice_kind, invoice_date, message, description, billed_to_party_id, billed_from_party_id) values
  (30002, 'SALES',    '2001-05-25', null,                        'Fulfillment of office supply order', 16, 13),
  (30005, 'SALES',    '2001-06-05', 'Thanks for the business!', null,                                  54, 13),
  (30010, 'SALES',    '2001-06-05', null,                        null,                                  62, 16),
  (30011, 'SALES',    '2001-06-12', null,                        'Pens for John Smith',                 54, 13),   -- carries the bad lines below
  (30016, 'SALES',    '2001-06-10', null,                        'Correction to invoice 30002',         16, 13),
  (30020, 'PURCHASE', '2001-05-30', null,                        'Pens for resale',                     13, 18);   -- Fantastic Supplies bills us

-- Table 7.2 (lines 1-4) and Table 7.3 (5-7): amounts per unit (point 2);
-- the adjustments are for the whole invoice, so they adjust no line.
insert into invoice_item (invoice_item_id, invoice_id, invoice_item_seq_id, invoice_item_type_id, product_id, product_feature_id, inventory_item_id,
                          adjustment_for_invoice_item_id, sold_with_invoice_item_id, taxable_flag, quantity, amount, item_description) values
  (1,  30002, 1, 'PRODUCT_ITEM',          1,    null, null, null, null, true,  10,   8.00,    null),
  (2,  30002, 2, 'FEATURE_ITEM',          null, 25,   null, null, 1,    true,  null, 2.00,    null),   -- sold with line 1
  (3,  30002, 3, 'PRODUCT_ITEM',          2,    null, null, null, null, true,  4,    12.00,   null),
  (4,  30002, 4, 'PRODUCT_ITEM',          3,    null, null, null, null, true,  6,    7.00,    null),
  (5,  30002, 5, 'SHIPPING_AND_HANDLING', null, null, null, null, null, false, null, 16.00,   null),
  (6,  30002, 6, 'FEE',                   null, null, null, null, null, false, null, 5.00,    'Order processing fee'),
  (7,  30002, 7, 'SALES_TAX',             null, null, null, null, null, false, null, 25.65,   null),
  -- 30005, ours: a book, and a serialized copier with a discount on its line
  (8,  30005, 1, 'PRODUCT_ITEM',          7,    null, null, null, null, true,  1,    45.00,   null),
  (9,  30005, 2, 'PRODUCT_ITEM',          6,    null, 5,    null, null, true,  1,    3500.00, null),   -- copier OJ900-0001
  (10, 30005, 3, 'DISCOUNT',              null, null, null, 9,    null, false, null, 100.00,  'Display model'),
  -- 30010, ours: a one-off service, described only
  (11, 30010, 1, 'PRODUCT_ITEM',          null, null, null, null, null, true,  1,    150.00,  'Copier maintenance visit'),
  -- 30016: the book's correction example. 30002 billed 10 reams, ACME got 8:
  -- a later line credits -2 and points back at the original
  (12, 30016, 1, 'PRODUCT_ITEM',          1,    null, null, 1,    null, true,  -2,   8.00,    'Credit: 2 reams billed but not delivered'),
  -- 30020: a purchase
  (13, 30020, 1, 'PRODUCT_ITEM',          2,    null, null, null, null, true,  100,  1.20,    null),
  -- 30011: one good line, then the mistakes
  (14, 30011, 1, 'PRODUCT_ITEM',          2,    null, null, null, null, true,  2,    12.00,   null),
  (15, 30011, 1, 'PRODUCT_ITEM',          3,    null, null, null, null, true,  1,    7.00,    'DATA ERROR: a second line 1 on the invoice (caught by a query)'),
  (16, 30011, 2, 'FEATURE_ITEM',          null, 25,   null, null, null, true,  null, 2.00,    'DATA ERROR: a feature sold with no product line (caught by a query)'),
  (17, 30011, 3, 'ACQUIRING_ITEM',        2,    null, null, null, null, true,  1,    12.00,   'DATA ERROR: typed with the grouping row (caught by a query)'),
  (18, 30011, 4, 'PRODUCT_ITEM',          null, null, null, null, null, true,  1,    10.00,   null),   -- DATA ERROR: bills nothing, not even a description (caught by a query)
  (19, 30011, 5, 'PRODUCT_ITEM',          6,    null, 1,    null, null, true,  1,    3500.00, 'DATA ERROR: inventory item 1 is paper, not a copier (caught by a query)'),
  (20, 30011, 6, 'SALES_TAX',             null, null, null, 1,    null, false, null, 1.20,    'DATA ERROR: tax on a line of invoice 30002 (caught by a query)');

select setval(pg_get_serial_sequence('invoice_item', 'invoice_item_id'), (select max(invoice_item_id) from invoice_item));

-- ============================================================
-- Fig 7.2 — Invoice parties
-- ============================================================
-- Table 7.4's mechanisms (NOTES, point 5): 45 ACME's billing address, 46 ABC
-- Subsidiary's, 47-49 the three e-mails.
insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (45, 'POSTAL_ADDRESS',     'POSTAL_ADDRESS'),
  (46, 'POSTAL_ADDRESS',     'POSTAL_ADDRESS'),
  (47, 'ELECTRONIC_ADDRESS', 'EMAIL'),
  (48, 'ELECTRONIC_ADDRESS', 'EMAIL'),
  (49, 'ELECTRONIC_ADDRESS', 'EMAIL');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into postal_address (contact_mechanism_id, address1, address2, directions) values
  (45, '123 Main Street',   null, null),
  (46, '100 Bridge Street', null, null);

insert into electronic_address (contact_mechanism_id, electronic_address_string) values
  (47, 'jsmith@us.com'),
  (48, '1235,678@cis.com'),   -- as printed: an old CompuServe-style address
  (49, 'acorp@acme.com');

insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (46, 16, 45, '1999-01-01', null, false, null, 'Accounts payable'),
  (47, 13, 46, '1999-01-01', null, false, null, 'Billing office'),
  (48, 54, 47, '1998-01-01', null, false, null, null),
  (49, 62, 48, '1997-01-01', null, false, null, null),
  (50, 16, 49, '1999-01-01', null, false, null, null);

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

-- Where each party wants its bills.
insert into party_contact_mechanism_purpose (party_contact_mechanism_id, contact_mechanism_purpose_type_id, from_date, thru_date) values
  (46, 'BILLING', '1999-01-01', null),
  (47, 'BILLING', '1999-01-01', null),
  (48, 'BILLING', '1998-01-01', null),
  (49, 'BILLING', '1997-01-01', null),
  (50, 'BILLING', '1999-01-01', null);

-- Table 7.4; 30011's address is wrong on purpose.
update invoice set addressed_to_contact_mechanism_id = 45, sent_from_contact_mechanism_id = 46 where invoice_id in (30002, 30016);
update invoice set addressed_to_contact_mechanism_id = 47, sent_from_contact_mechanism_id = 46 where invoice_id = 30005;
update invoice set addressed_to_contact_mechanism_id = 48, sent_from_contact_mechanism_id = 49 where invoice_id = 30010;
update invoice set addressed_to_contact_mechanism_id = 45, sent_from_contact_mechanism_id = 46 where invoice_id = 30011;   -- DATA ERROR: John Smith's bill sent to ACME's billing address (caught by a query)

-- The text's four role types.
insert into invoice_role_type (invoice_role_type_id, description) values
  ('ENTERED_BY', 'Entered by'),
  ('APPROVER',   'Approver'),
  ('SENDER',     'Sender'),
  ('RECEIVER',   'Receiver');

-- Ours: Rosa Diaz keys in ABC Subsidiary's bills, William Jones (ABC
-- Corporation) approves the big one.
insert into invoice_role (invoice_id, party_id, invoice_role_type_id, role_datetime, percentage) values
  (30002, 50, 'ENTERED_BY', '2001-05-25 09:10+00', null),
  (30002, 47, 'APPROVER',   '2001-05-25 14:30+00', null),
  (30005, 50, 'ENTERED_BY', '2001-06-05 10:00+00', null),
  (30002, 50, 'ENTERED_BY', '2001-05-25 09:12+00', null);   -- DATA ERROR: Rosa entered 30002 twice (caught by a query)
