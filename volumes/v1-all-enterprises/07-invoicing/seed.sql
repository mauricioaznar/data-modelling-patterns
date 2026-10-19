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
update invoice set addressed_to_contact_mechanism_id = 45, sent_from_contact_mechanism_id = 49 where invoice_id = 30011;   -- DATA ERRORS: John Smith's bill sent to ACME's billing address, and from ACME's e-mail, which ABC Subsidiary doesn't hold (both caught by queries)

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

-- ============================================================
-- Fig 7.3a — Billing account
-- ============================================================
-- 50: Jane Smith's home, where account 1459's bills go (ours).
insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (50, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into postal_address (contact_mechanism_id, address1, address2, directions) values
  (50, '45 Elm Street', null, null);

insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (51, 58, 50, '1999-01-01', null, false, null, 'Home');

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

insert into billing_account_role_type (billing_account_role_type_id, description) values
  ('PRIMARY_PAYER',        'Primary payer'),
  ('SECONDARY_PAYER',      'Secondary payer'),
  ('CUSTOMER_SERVICE_REP', 'Customer service representative'),
  ('MANAGER',              'Manager'),
  ('SALES_REP',            'Sales representative');

-- Tables 7.5 and 7.6. 1459's dates, mechanism and description are ours.
insert into billing_account (billing_account_id, from_date, thru_date, description, billed_at_contact_mechanism_id) values
  (1295, '2000-04-15', null, 'All charges for office supplies',     45),
  (1296, '2000-04-15', null, 'All charges for consulting services', 45),
  (1459, '2000-04-15', null, 'Smith household phone service',       50);

select setval(pg_get_serial_sequence('billing_account', 'billing_account_id'), (select max(billing_account_id) from billing_account));

-- Thru dates +1 day (exclusive): John's last day is Jun 15, 2001.
insert into billing_account_role (billing_account_id, party_id, billing_account_role_type_id, from_date, thru_date) values
  (1295, 16, 'PRIMARY_PAYER',   '2000-04-15', null),
  (1296, 16, 'PRIMARY_PAYER',   '2000-04-15', null),
  (1459, 58, 'PRIMARY_PAYER',   '2000-04-15', null),
  (1459, 54, 'SECONDARY_PAYER', '2000-04-15', '2001-06-16'),
  (1459, 61, 'SECONDARY_PAYER', '2001-06-16', null),
  (1459, 61, 'PRIMARY_PAYER',   '2001-07-01', null),   -- DATA ERROR: a second primary payer while Jane still is (caught by a query)
  (1459, 61, 'SECONDARY_PAYER', '2001-06-16', null);   -- DATA ERROR: Joe's secondary role keyed in twice (caught by a query)

-- Invoices on account, ours. Billed to the account, so no party.
insert into invoice (invoice_id, invoice_kind, invoice_date, message, description, billing_account_id, billed_from_party_id,
                     addressed_to_contact_mechanism_id, sent_from_contact_mechanism_id) values
  (30012, 'SALES', '2001-07-01', null, 'Consulting, June 2001',     1296, 13, 45, 46),
  (30013, 'SALES', '2001-07-01', null, 'Phone service, June 2001',  1459, 13, 50, 46),
  (30014, 'SALES', '2000-01-10', null, 'Phone service, December 1999', 1459, 13, 50, 46),   -- DATA ERROR: before the account opened (caught by a query)
  (30015, 'SALES', '2001-07-01', null, 'Paper',                     1295, 13, 47, 46);      -- DATA ERROR: addressed to John Smith's e-mail, not the account's address (caught by a query)

insert into invoice_item (invoice_id, invoice_item_seq_id, invoice_item_type_id, product_id, taxable_flag, quantity, amount, item_description) values
  (30012, 1, 'PRODUCT_ITEM', null, false, 16,   75.00, 'Consulting hours'),
  (30013, 1, 'PRODUCT_ITEM', null, true,  null, 45.00, 'Phone service, June 2001'),
  (30014, 1, 'PRODUCT_ITEM', null, true,  null, 45.00, 'Phone service, December 1999'),
  (30015, 1, 'PRODUCT_ITEM', 1,    true,  5,    8.00,  null);

-- ============================================================
-- Fig 7.4 — Invoice status and terms
-- ============================================================
-- A new group in Ch 2's shared status_type: the book's three, and RECEIVED
-- (ours) for the supplier bills we get. No PAID (NOTES, point 22).
insert into status_type (status_type_id, parent_type_id, description) values
  ('INVOICE_STATUS',   null,             'Invoice status'),
  ('INVOICE_APPROVED', 'INVOICE_STATUS', 'Approved'),
  ('INVOICE_SENT',     'INVOICE_STATUS', 'Sent'),
  ('INVOICE_VOID',     'INVOICE_STATUS', 'Void'),
  ('INVOICE_RECEIVED', 'INVOICE_STATUS', 'Received (a supplier''s bill)');

-- Table 7.7, then ours.
insert into invoice_status (invoice_id, status_type_id, status_date) values
  (30002, 'INVOICE_APPROVED', '2001-05-25'),
  (30002, 'INVOICE_SENT',     '2001-05-30'),
  (30005, 'INVOICE_SENT',     '2001-06-05'),
  (30005, 'INVOICE_VOID',     '2001-06-06'),
  (30016, 'INVOICE_APPROVED', '2001-06-10'),
  (30016, 'INVOICE_SENT',     '2001-06-11'),
  (30020, 'INVOICE_RECEIVED', '2001-06-01'),
  (30011, 'INVOICE_SENT',     '2001-06-10'),   -- DATA ERROR: sent two days before the invoice's own date (caught by a query)
  (30005, 'INVOICE_SENT',     '2001-06-08'),   -- DATA ERROR: sent again after it was voided (caught by a query)
  (30013, 'ORDER_SHIPPED',    '2001-07-02'),   -- DATA ERROR: an order status on an invoice (caught by a query)
  (30016, 'INVOICE_SENT',     '2001-06-11');   -- DATA ERROR: the same event keyed in twice (caught by a query)

-- Table 7.8's new term types, filed under Ch 4's FINANCIAL_TERM. Its
-- "non-returnable sales item" is Ch 4's NO_EXCHANGE_OR_REFUND (point 23).
insert into term_type (term_type_id, parent_type_id, description) values
  ('LATE_FEE_PCT',           'FINANCIAL_TERM', 'Percentage late fee added when the invoice is paid late'),
  ('COLLECTION_PENALTY_PCT', 'FINANCIAL_TERM', 'Percentage added to the amount due if the invoice goes to a collection agency');

-- Table 7.8; item 2 is 30002's glossy finish line.
insert into invoice_term (term_type_id, invoice_id, invoice_item_id, term_value) values
  ('PAYMENT_DUE_DAYS',       30002, null, 30),
  ('LATE_FEE_PCT',           30002, null, 2),
  ('COLLECTION_PENALTY_PCT', 30002, null, 5),
  ('NO_EXCHANGE_OR_REFUND',  null,  2,    null),
  ('PAYMENT_DUE_DAYS',       30005, null, 15),   -- ours
  ('PAYMENT_DUE_DAYS',       30002, null, 45);   -- DATA ERROR: a second payment term on 30002 (caught by a query)

-- ============================================================
-- Fig 7.5 — Billing for shipment items
-- ============================================================
-- Table 7.9 to its intention, not its numbers (NOTES, point 14). Shipments
-- 1235 and 1330 are ours: 1235 sends ACME what 30002 bills, 1330 sends John
-- Smith three books in three lines. Mechanisms as Ch 5's 9000: 40 ABC
-- Subsidiary's warehouse, 32 ACME's head office, 44 the shipping desk, 43
-- ACME's receiving phone. John Smith has no postal address on file.
insert into shipment (shipment_id, shipment_type_id, estimated_ship_date, estimated_arrival_date,
                      shipped_from_party_id, shipped_from_contact_mechanism_id, shipped_to_party_id, shipped_to_contact_mechanism_id,
                      inquiry_contact_mechanism_id, receiving_contact_mechanism_id) values
  (1235, 'CUSTOMER_SHIPMENT', '2001-05-24', '2001-05-25', 13, 40, 16, 32,   44, 43),
  (1330, 'CUSTOMER_SHIPMENT', '2001-06-04', '2001-06-06', 13, 40, 54, null, 44, null);

insert into shipment_item (shipment_item_id, shipment_id, shipment_item_seq_id, product_id, quantity) values
  (26, 1235, 1, 1, 10),   -- bond paper
  (27, 1235, 2, 2, 4),    -- pens
  (28, 1235, 3, 3, 6),    -- diskettes
  (29, 1330, 1, 7, 1),    -- the Data Model Resource Book, in three lines
  (30, 1330, 2, 7, 1),
  (31, 1330, 3, 7, 1);

select setval(pg_get_serial_sequence('shipment_item', 'shipment_item_id'), (select max(shipment_item_id) from shipment_item));

-- 30005's book line (ours) now bills the three books 1330 sends.
update invoice_item set quantity = 3 where invoice_item_id = 8;

-- Invoice items: 1, 3, 4 are 30002's paper, pens and diskettes; 12 is
-- 30016's -2 ream credit (the book's 30045 row); 8 is 30005's books.
insert into shipment_item_billing (shipment_item_id, invoice_item_id) values
  (26, 1),
  (27, 3),
  (28, 4),
  (26, 12),   -- the credit bills 1235's paper line again, for -2
  (29, 8),
  (30, 8),
  (31, 8),
  (3,  3),    -- DATA ERROR: 9000's diskettes billed on 30002's pen line (caught by a query)
  (2,  14),   -- DATA ERROR: pens shipped to ACME billed to John Smith on 30011 (caught by a query)
  (27, 3);    -- DATA ERROR: the same pair twice (caught by a query)

-- ============================================================
-- Fig 7.6 — Billing of time entries and work efforts
-- ============================================================
-- No table in the book. Ours: ABC Subsidiary bills ACME for Ch 6's
-- consulting work: John Smith's interview hours (time entries 3 and 5 on
-- 29003, 30 + 45 hours) by the hour, and the project plan (29000) by the
-- job, half on approval and the rest on delivery.
insert into invoice (invoice_id, invoice_kind, invoice_date, description, billed_to_party_id, billed_from_party_id,
                     addressed_to_contact_mechanism_id, sent_from_contact_mechanism_id) values
  (30017, 'SALES', '2001-03-05', 'Consulting, January and February 2001', 16, 13, 45, 46);

insert into invoice_item (invoice_item_id, invoice_id, invoice_item_seq_id, invoice_item_type_id, taxable_flag, quantity, amount, item_description) values
  (40, 30017, 1, 'TIME_ENTRY_ITEM',  false, 75,   90.00,   'Initial interviews, hours'),
  (41, 30017, 2, 'WORK_EFFORT_ITEM', false, null, 2000.00, 'Project plan: 50% on approval'),
  (42, 30017, 3, 'WORK_EFFORT_ITEM', false, null, 2400.00, 'Project plan: the rest on delivery');

select setval(pg_get_serial_sequence('invoice_item', 'invoice_item_id'), (select max(invoice_item_id) from invoice_item));

-- Invoice item 21 is 30012's consulting line (ours, 7.3a), typed PRODUCT_ITEM.
insert into time_entry_billing (time_entry_id, invoice_item_id) values
  (3, 40),
  (5, 40),
  (3, 21);   -- DATA ERROR: entry 3 billed again, on a line that isn't a time entry line (caught by queries)

insert into work_effort_billing (work_effort_id, invoice_item_id, percentage) values
  (29000, 41, 50),
  (29000, 42, 60);   -- DATA ERROR: the plan billed 110% in all (caught by a query)

-- ============================================================
-- Fig 7.7 — Billing for order items
-- ============================================================
-- Table 7.10, read as our purchases (NOTES, point 16): ABC Subsidiary orders
-- 40 hours of accounting a time from Hartley Accounting (63, ours), which
-- bills them on its own invoices 990023 and 990026.
insert into party (party_id, party_kind) values (63, 'ORGANIZATION');

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (63, 'CORPORATION', 'Hartley Accounting');

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (84, 63, 'SUPPLIER', '2000-01-01', null);

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into product (product_id, product_kind, name, introduction_date) values
  (27, 'SERVICE', 'Accounting services', '1990-01-01');

select setval(pg_get_serial_sequence('product', 'product_id'), (select max(product_id) from product));

insert into "order" (order_id, order_kind, order_date, entry_date) values
  (10001, 'PURCHASE', '2001-04-02', '2001-04-02'),
  (10002, 'PURCHASE', '2001-05-01', '2001-05-01'),
  (10003, 'PURCHASE', '2001-06-01', '2001-06-01');

insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, quantity, unit_price, item_description) values
  (51, 10001, 1, 27, 40, 60.00, 'Accounting, hours'),
  (52, 10002, 1, 27, 40, 60.00, 'Accounting, hours'),
  (53, 10003, 1, 27, 40, 60.00, 'Accounting, hours');

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

-- 69 is ABC Subsidiary's PLACING_BUYER role (Ch 4).
insert into purchase_order (order_id, placed_by_party_role_id, taken_by_party_role_id) values
  (10001, 69, 84),
  (10002, 69, 84),
  (10003, 69, 84);

-- A service: nothing to ship, so no ship-to.
insert into purchase_order_item (order_item_id) values (51), (52), (53);

-- Hartley's bills, addressed to ABC Subsidiary's billing office (46).
insert into invoice (invoice_id, invoice_kind, invoice_date, description, billed_to_party_id, billed_from_party_id,
                     addressed_to_contact_mechanism_id) values
  (990023, 'PURCHASE', '2001-06-15', 'Accounting services', 13, 63, 46),
  (990026, 'PURCHASE', '2001-07-15', 'Accounting services', 13, 63, 46);

-- Table 7.11 shows no quantity and $6,000 for 990023's line; Table 7.10
-- bills it as 100 hours. Seeded 100 x $60 (point 21).
insert into invoice_item (invoice_item_id, invoice_id, invoice_item_seq_id, invoice_item_type_id, product_id, taxable_flag, quantity, amount) values
  (43, 990023, 1, 'PRODUCT_ITEM', 27, false, 100, 60.00),
  (44, 990026, 1, 'PRODUCT_ITEM', 27, false, 20,  60.00);

select setval(pg_get_serial_sequence('invoice_item', 'invoice_item_id'), (select max(invoice_item_id) from invoice_item));

-- Table 7.10. Order item 1 is 12560's paper (Ch 4), which 30002's line 1
-- already bills through shipment 1235; 24 is purchase order 12570's paper;
-- invoice item 24 is 30015's paper line (a sale).
insert into order_item_billing (order_item_id, invoice_item_id, quantity, amount) values
  (51, 43, 40, 2400.00),
  (52, 43, 40, 2400.00),
  (53, 43, 20, 1200.00),
  (53, 44, 20, 1200.00),
  (52, 44, 10, 600.00),    -- DATA ERROR: 10002 billed 50 hours of its 40 (caught by a query)
  (1,  1,  10, 80.00),     -- DATA ERROR: 30002's paper billed through its order as well as its shipment (caught by a query)
  (24, 24, 5,  40.00);     -- DATA ERROR: a purchase order line billed on a sales invoice (caught by a query)

-- ============================================================
-- Fig 7.8a — Invoice payments
-- ============================================================
insert into payment_method_type (payment_method_type_id, description) values
  ('CASH',        'Cash'),
  ('CHECK',       'Check'),
  ('CREDIT_CARD', 'Credit card'),
  ('ELECTRONIC',  'Electronic funds transfer');

-- Table 7.11's three payments (dates and refs ours), then Table 7.12's four
-- others, ours in detail (NOTES, point 28).
insert into payment (payment_id, payment_kind, payment_method_type_id, from_party_id, to_party_id, effective_date, payment_ref_num, amount, comment) values
  (12298398, 'RECEIPT',      'CHECK',      16, 13, '2001-06-20', 'ACME check 5521',    182.20,  null),
  (12298412, 'RECEIPT',      'CHECK',      16, 13, '2001-06-28', 'ACME check 5560',    12.84,   'The rest, once the paper count was settled'),
  (488893,   'DISBURSEMENT', 'CHECK',      13, 63, '2001-07-20', 'ABC check 7012',     7000.00, 'Hartley: 990023 and part of 990026'),
  (394789,   'RECEIPT',      'ELECTRONIC', 16, 13, '2001-07-01', 'ACH 20010701-88',    343.00,  null),
  (97873,    'RECEIPT',      'CHECK',      58, 13, '2001-07-01', 'Smith check 311',    379.00,  'On account: not tied to a bill yet'),
  (88394,    'DISBURSEMENT', 'CHECK',      13, 18, '2001-07-03', 'ABC check 7001',     480.00,  'Fantastic Supplies: 30020 and an advance'),
  (88756,    'DISBURSEMENT', 'CHECK',      13, 63, '2001-07-05', 'ABC check 7002',     670.00,  'Advance to Hartley'),
  (12298500, 'RECEIPT',      'CASH',       16, 13, '2001-07-10', 'Cash slip 18',       50.00,   null),   -- its application below is wrong
  (12298502, 'RECEIPT',      'CHECK',      13, 16, '2001-07-10', 'ABC check 7015',     25.00,   'DATA ERROR: our refund to ACME typed as a receipt (caught by a query)');

-- Table 7.11: 30002 paid in two parts, one payment over 990023 and part of
-- 990026. Ours: 394789 pays part of 30012, 97873 goes on account 1459.
insert into payment_application (payment_id, invoice_id, billing_account_id, amount_applied) values
  (12298398, 30002,  null, 182.20),
  (12298412, 30002,  null, 12.84),
  (488893,   990023, null, 6000.00),
  (488893,   990026, null, 1000.00),
  (394789,   30012,  null, 343.00),
  (97873,    null,   1459, 379.00),
  (88394,    30020,  null, 120.00),
  (12298500, 30020,  null, 50.00),   -- DATA ERROR: a receipt from ACME applied to our purchase invoice (caught by a query)
  (88756,    990026, null, 700.00);  -- DATA ERROR: more than the payment's 670, and 990026 paid past its 1,200 (caught by queries)

-- ============================================================
-- Fig 7.9 — Financial accounts, withdrawals and deposits
-- ============================================================
-- The text's examples of account types, under the two kinds.
insert into financial_account_type (financial_account_type_id, parent_type_id, description) values
  ('BANK',        null,         'Bank account (grouping row)'),
  ('CHECKING',    'BANK',       'Checking account'),
  ('SAVINGS',     'BANK',       'Savings account'),
  ('INVESTMENT',  null,         'Investment account (grouping row)'),
  ('IRA',         'INVESTMENT', 'IRA account'),
  ('MUTUAL_FUND', 'INVESTMENT', 'Mutual fund account');

-- Table 7.12's account (name ours), and ours: a savings account typed under
-- the wrong kind.
insert into financial_account (financial_account_id, financial_account_kind, financial_account_type_id, financial_account_name) values
  (8389309984, 'BANK',       'CHECKING',    'ABC Subsidiary operating account'),
  (8389310001, 'INVESTMENT', 'SAVINGS',     'ABC Subsidiary reserve');   -- DATA ERROR: a savings type on an investment account (caught by a query)

insert into financial_account_role_type (financial_account_role_type_id, description) values
  ('OWNER',         'Owner'),
  ('SIGNER',        'Authorized signer'),
  ('ADMINISTRATOR', 'Administrator');

-- Ours: ABC Subsidiary owns both; Rosa Diaz (50) signs on the operating
-- account.
insert into financial_account_role (financial_account_id, party_id, financial_account_role_type_id, from_date, thru_date) values
  (8389309984, 13, 'OWNER',  '1999-01-01', null),
  (8389310001, 13, 'OWNER',  '2000-01-01', null),
  (8389309984, 50, 'SIGNER', '2000-01-01', null),
  (8389309984, 50, 'SIGNER', '2000-01-01', null);   -- DATA ERROR: Rosa's signer role keyed twice (caught by a query)

-- Table 7.12: one deposit of four receipts, two withdrawals of one check
-- each (dates ours). Then ours: a bank fee, and a withdrawal with no check,
-- executed by William Jones (47), who has no role on the account.
insert into financial_account_transaction (financial_account_transaction_id, transaction_kind, financial_account_id, executed_by_party_id,
                                           transaction_date, entry_date, amount) values
  (398749, 'DEPOSIT',    8389309984, 50, '2001-07-02', '2001-07-02', null),
  (398761, 'WITHDRAWAL', 8389309984, 50, '2001-07-06', '2001-07-09', null),
  (398762, 'WITHDRAWAL', 8389309984, 50, '2001-07-09', '2001-07-09', null),
  (398770, 'ADJUSTMENT', 8389309984, 50, '2001-07-31', '2001-08-01', -15.00),   -- the bank's monthly fee
  (398771, 'WITHDRAWAL', 8389309984, 47, '2001-07-12', '2001-07-12', null),     -- DATA ERRORS: no check behind it, and executed by someone with no role on the account (caught by queries)
  (398772, 'DEPOSIT',    8389309984, 50, '2001-07-21', '2001-07-21', null);

select setval(pg_get_serial_sequence('financial_account_transaction', 'financial_account_transaction_id'),
              (select max(financial_account_transaction_id) from financial_account_transaction));

update payment set financial_account_transaction_id = 398749 where payment_id in (12298398, 12298412, 394789, 97873);   -- Table 7.12 prints 1298398 and 1298412 (point 29)
update payment set financial_account_transaction_id = 398761 where payment_id = 88394;
update payment set financial_account_transaction_id = 398762 where payment_id = 88756;
update payment set financial_account_transaction_id = 398772 where payment_id = 488893;   -- DATA ERROR: a check we paid out, banked as a deposit (caught by a query)
