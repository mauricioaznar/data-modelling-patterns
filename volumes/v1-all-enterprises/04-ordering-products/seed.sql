-- Vol 1, Chapter 4 seed data.
-- The Ch 3 office-supply catalogue, now ordered. Aim for data that exercises
-- the tricky cases (features under their product, frozen prices, one party
-- in several roles), not just the happy path.
--
-- Products (Ch 3): 1 bond paper, 2 Goldstein pen, 3 diskettes, 6 OfficeJet
-- copier, 7 the Data Model Resource Book. Features: 3 Blue, 4 Black, 5 Red
-- (dropped for the pen in 2020), 13 duplex unit, 14 stapling finisher,
-- 18 scan-to-email.

-- ============================================================
-- Fig 4.2 — Orders and order items
-- ============================================================
insert into "order" (order_id, order_kind, order_date, entry_date) values
  (12560, 'SALES',    '2001-04-12', '2001-04-12'),   -- Table 4.2's order
  (12561, 'SALES',    '2025-02-10', '2025-02-10'),   -- a copier with options, and paper
  (12562, 'SALES',    '2025-03-03', '2025-03-04'),   -- pens in two colours
  (12563, 'SALES',    '2024-11-05', '2024-11-05'),   -- Ben's own order
  (12564, 'PURCHASE', '2025-01-20', '2025-01-20'),   -- we buy paper, pens and books
  (12565, 'SALES',    '2023-03-15', '2023-03-16'),
  (12566, 'SALES',    '2025-04-01', '2025-04-01'),
  (12567, 'SALES',    '2025-05-02', '2025-05-06');   -- keyed in four days late

select setval(pg_get_serial_sequence('"order"', 'order_id'), (select max(order_id) from "order"));

insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, product_feature_id, ordered_for_order_item_id,
                        quantity, unit_price, estimated_delivery_date, shipping_instructions, item_description, comment) values
  -- 12560, Table 4.2: the book's prices, not our Ch 3 list (the pen lists at 2.50)
  (1,  12560, 1, 1,    null, null, 10,  8.00,    null,         null, null, null),
  (2,  12560, 2, 2,    null, null, 4,   12.00,   null,         null, null, null),
  (3,  12560, 3, 3,    null, null, 6,   7.00,    null,         null, null, null),
  -- 12561: the copier with two options under it, and paper that arrives first
  (4,  12561, 1, 6,    null, null, 1,   3500.00, '2025-02-24', 'Loading dock; bring a pallet jack', null, null),
  (5,  12561, 2, null, 13,   4,    1,   250.00,  '2025-02-24', null, null, 'Duplex unit, for the copier'),
  (6,  12561, 3, null, 14,   4,    1,   180.00,  '2025-02-24', null, null, 'Stapling finisher, for the copier'),
  (7,  12561, 4, 1,    null, null, 20,  42.00,   '2025-02-12', null, null, null),
  (8,  12561, 5, 6,    18,   4,    1,   0.00,    null,         null, null, 'DATA ERROR: names the copier AND the scan-to-email feature (caught by a query)'),
  -- 12562: 30 pens in blue and 20 in red, each colour under its pens
  (9,  12562, 1, 2,    null, null, 30,  2.50,    null,         null, null, null),
  (10, 12562, 2, null, 3,    9,    30,  0.00,    null,         null, null, 'Blue: no extra charge'),
  (11, 12562, 3, 2,    null, null, 20,  2.50,    null,         null, null, null),
  (12, 12562, 4, null, 5,    11,   20,  0.00,    null,         null, null, 'DATA ERROR: red was dropped for the pen in 2020 (caught by a query)'),
  -- 12563: a one-off with no product, and two mistakes
  (13, 12563, 1, null, null, null, 1,   45.00,   null,         null, 'Engraved pen set with the Contoso logo', 'Made once: not in the catalogue'),
  (14, 12563, 2, 3,    null, null, 2,   7.00,    null,         null, null, 'DATA ERROR: the diskettes left sale in 2006 (caught by a query)'),
  (15, 12563, 3, null, 4,    9,    30,  0.00,    null,         null, null, 'DATA ERROR: ordered for order 12562''s pens (caught by a query)'),
  -- 12564, a purchase order: what we buy, at what we pay
  (16, 12564, 1, 1,    null, null, 500, 30.00,   '2025-01-27', null, null, null),
  (17, 12564, 2, 2,    null, null, 100, 1.20,    null,         null, null, null),
  (18, 12564, 2, 7,    null, null, 10,  40.00,   null,         null, null, 'DATA ERROR: a second line 2 on the order (caught by a query)'),
  -- 12565 to 12567: small orders that carry Fig 4.3's party mistakes
  (19, 12565, 1, 2,    null, null, 10,  2.50,    null,         null, null, null),
  (20, 12566, 1, 1,    null, null, 10,  42.00,   null,         null, null, null),
  (21, 12567, 1, 1,    null, null, 5,   42.00,   null,         null, null, null);

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

-- Every sales item has its subtype row; Contoso quotes its own PO numbers,
-- two of them on order 12561.
insert into sales_order_item (order_item_id, corresponding_po_id) values
  (1, null), (2, null), (3, null),
  (4, 'CON-4471'), (5, 'CON-4471'), (6, 'CON-4471'), (7, 'CON-4502'), (8, 'CON-4471'),
  (9, 'CON-4610'), (10, 'CON-4610'), (11, 'CON-4610'), (12, 'CON-4610'),
  (13, null), (14, null), (15, null),
  (16, 'JPM-881'),   -- DATA ERROR: our own PO number typed into a sales-item row on a purchase order (caught by a query)
  (19, null), (20, 'CON-4733'), (21, null);

-- ============================================================
-- Fig 4.3 — Sales order parties and contact mechanisms
-- ============================================================
-- PLACING CUSTOMER is new: a fourth customer role under Ch 2's CUSTOMER.
insert into role_type (role_type_id, parent_type_id, applies_to_kind, description) values
  ('PLACING_CUSTOMER', 'CUSTOMER', 'EITHER', 'Placing customer');

-- Party roles used below. From Ch 2: 1 Northwind INTERNAL_ORGANIZATION,
-- 32 ABC Subsidiary INTERNAL_ORGANIZATION, 6 Contoso BILL_TO, 7 Contoso
-- SHIP_TO. New: who places orders.
insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (60, 16, 'PLACING_CUSTOMER', '1999-01-01', null),   -- ACME Company
  (61, 5,  'PLACING_CUSTOMER', '2021-04-01', null),   -- Contoso, our customer since 2021
  (62, 2,  'PLACING_CUSTOMER', '2023-06-01', null);   -- Ben, once he stopped being a prospect

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

-- Contact mechanisms from Ch 2: 1 and 2 Northwind's phone lines, 7 Contoso's
-- sales inbox (Ben reads it as Contoso's contact), 8 Northwind's website,
-- 14 Northwind's Chatham warehouse, 15 Contoso's office at 1 Market St.
-- New: Contoso's St. Louis depot, for deliveries only.
insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (30, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into postal_address (contact_mechanism_id, address1, address2, directions) values
  (30, '800 Riverfront Ave', 'Dock 3', 'Trucks use the river gate');

insert into postal_address_boundary (contact_mechanism_id, geographic_boundary_id) values
  (30, 18), (30, 17), (30, 11), (30, 6);   -- St. Louis MO 63101, US

insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (30, 5, 30, '2022-01-01', null, true, 'SHIP_TO_CUSTOMER', 'St. Louis depot: deliveries only, no sales mail');

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

insert into sales_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id,
                         placed_using_contact_mechanism_id, taken_via_contact_mechanism_id, bill_to_contact_mechanism_id) values
  (12560, 60, 32, null, null, null, null),   -- ACME to ABC Subsidiary (the book's cast), nothing on file: no bill-to, so ACME pays
  (12561, 61, 1,  6,    7,    8,    15),     -- Contoso orders from its sales inbox on our website; bill to 1 Market St
  (12562, 62, 1,  6,    7,    2,    15),     -- Ben places it for Contoso, which pays: four parties, four jobs
  (12563, 62, 1,  null, null, 1,    null),   -- Ben's own order, by phone: no bill-to, so Ben pays
  (12565, 62, 1,  null, null, 1,    null),   -- DATA ERROR: Ben's placing role starts 2023-06-01, after this order (caught by a query)
  (12566, 61, 1,  7,    7,    8,    15);     -- DATA ERROR: billed to Contoso's SHIP_TO role, not its BILL_TO role (caught by a query)
  -- 12567: no row at all. DATA ERROR: a sales order without its sales_order row (caught by a query)

-- Ship-to per item. Feature items (5, 6, 8, 10, 12) ship with their product's item.
update sales_order_item set ship_to_party_role_id = 7, ship_to_contact_mechanism_id = 15 where order_item_id in (4, 9, 20);   -- Contoso's office
update sales_order_item set ship_to_party_role_id = 7, ship_to_contact_mechanism_id = 30 where order_item_id = 7;             -- the paper goes to the depot
update sales_order_item set ship_to_party_role_id = 7, ship_to_contact_mechanism_id = 14 where order_item_id = 11;            -- Contoso collects the red pens at our Chatham warehouse (on the review list)

insert into order_role_type (order_role_type_id, description) values
  ('SALESPERSON', 'Salesperson: credited with the sale'),
  ('ENTERED_BY',  'Keyed the order in'),
  ('APPROVER',    'Approved the order'),
  ('REVIEWER',    'Reviewed the order');

-- Parties: 1 Ana (a contractor since 2023), 3 Chloe (an employee).
insert into order_role (order_id, party_id, order_role_type_id, percent_contribution) values
  (12561, 3, 'SALESPERSON', 60),     -- Chloe and Ana split the copier sale
  (12561, 1, 'SALESPERSON', 40),
  (12561, 3, 'ENTERED_BY',  null),
  (12562, 3, 'SALESPERSON', 100),
  (12562, 1, 'SALESPERSON', 25),     -- DATA ERROR: 125% of one sale credited (caught by a query)
  (12564, 3, 'APPROVER',    null),   -- a purchase order has order roles too
  (12564, 3, 'APPROVER',    null);   -- DATA ERROR: the same approval entered twice (caught by a query)

-- ============================================================
-- Fig 4.4 — Purchase order parties and contact mechanisms
-- ============================================================
-- The buyer's roles, grouped like Ch 2's CUSTOMER. BUYER itself is a
-- grouping, never assigned (like PERSON_ROLE). SUPPLIER is Ch 2's.
insert into role_type (role_type_id, parent_type_id, applies_to_kind, description) values
  ('BUYER',             null,    null,     'Buyer: our side of a purchase order'),
  ('PLACING_BUYER',     'BUYER', 'EITHER', 'Placing buyer'),
  ('BILL_TO_PURCHASER', 'BUYER', 'EITHER', 'Bill-to purchaser'),
  ('SHIP_TO_BUYER',     'BUYER', 'EITHER', 'Ship-to buyer');

-- Party roles used below. From Ch 2: 5 Contoso SUPPLIER (freight, since
-- 2016), 6 Contoso BILL_TO_CUSTOMER, 37 Fantastic Supplies SUPPLIER.
insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (63, 4, 'PLACING_BUYER',     '2010-01-01', null),   -- Northwind
  (64, 4, 'BILL_TO_PURCHASER', '2010-01-01', null),
  (65, 4, 'SHIP_TO_BUYER',     '2010-01-01', null),
  (66, 3, 'PLACING_BUYER',     '2023-09-01', null);   -- Chloe, since she joined

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

-- Fantastic Supplies' order desk, where our purchase orders are taken.
insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (31, 'ELECTRONIC_ADDRESS', 'EMAIL');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into electronic_address (contact_mechanism_id, electronic_address_string) values
  (31, 'orders@fantastic.example');

insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (31, 18, 31, '2001-04-05', null, false, 'SUPPLIER', 'Order desk');

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

-- Three more purchase orders, each with a story.
insert into "order" (order_id, order_kind, order_date, entry_date) values
  (12568, 'PURCHASE', '2025-02-11', '2025-02-11'),   -- the copier sold on 12561, drop-shipped to Contoso
  (12569, 'PURCHASE', '2025-06-02', '2025-06-02'),   -- freight from Contoso
  (12570, 'PURCHASE', '2023-05-10', '2023-09-12');   -- paper, keyed in months later

select setval(pg_get_serial_sequence('"order"', 'order_id'), (select max(order_id) from "order"));

insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, quantity, unit_price, item_description, comment) values
  (22, 12568, 1, 6,    1,   2600.00, null, 'Fantastic Supplies delivers straight to Contoso'),
  (23, 12569, 1, null, 1,   85.00,   'Freight: one pallet, Chatham to St. Louis', 'A service: nothing to ship'),
  (24, 12570, 1, 1,    200, 29.00,   null, null);

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

-- Contact mechanisms: 2 Northwind's second line, 9 Contoso's phone, 13
-- Northwind's office (100 Commerce Dr), 14 the Chatham warehouse, 15
-- Contoso's office, 31 Fantastic's order desk.
insert into purchase_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id,
                            placed_using_contact_mechanism_id, taken_via_contact_mechanism_id, bill_to_contact_mechanism_id) values
  (12564, 66, 37, 64,   2,    31, 13),     -- Chloe places it for Northwind; Northwind pays
  (12568, 63, 37, null, 2,    31, 13),     -- no bill-to: the placer (Northwind) pays
  (12569, 63, 6,  64,   2,    9,  13),     -- DATA ERROR: taken by Contoso's BILL_TO_CUSTOMER role, not its SUPPLIER role (caught by a query)
  (12570, 66, 37, 64,   null, 31, 13),     -- DATA ERROR: Chloe's buyer role starts 2023-09-01, after this order (caught by a query)
  (12567, null, null, null, null, null, null);   -- DATA ERROR: sales order 12567 keyed on the purchase form (caught by a query)

-- Ship-to per item. The freight line (23) is a service: no ship-to.
insert into purchase_order_item (order_item_id, ship_to_party_role_id, ship_to_contact_mechanism_id) values
  (16, 65,   14),     -- paper to the Chatham warehouse
  (17, 65,   14),
  (18, 65,   13),     -- books to the office
  (22, 65,   15),     -- a drop ship: our ship-to role, Contoso's address (labelled by a query)
  (23, null, null),
  (24, 65,   14),
  (21, null, null);   -- DATA ERROR: the same clerk's mistake, on 12567's item (caught by a query)

-- ============================================================
-- Fig 4.5 — Generic order roles and contact mechanisms
-- ============================================================
-- Direction-neutral jobs: the order's kind says which side is ours (NOTES, point 9).
insert into order_role_type (order_role_type_id, description) values
  ('PLACED_BY', 'Placed the order: the customer on a sale, our buyer on a purchase'),
  ('TAKEN_BY',  'Took the order: our organization on a sale, the supplier on a purchase'),
  ('BILL_TO',   'Gets the bill');

insert into order_item_role_type (order_item_role_type_id, description) values
  ('SHIP_TO',   'Receives the item'),
  ('END_USER',  'Will use the item'),
  ('INSTALLER', 'Installs the item on site');

-- Ch 2's purposes, plus three an order needs. BILLING and SHIPPING are reused.
insert into contact_mechanism_purpose_type (contact_mechanism_purpose_type_id, description) values
  ('ORDER_PLACING',    'Where an order is placed from'),
  ('ORDER_TAKING',     'Where an order is taken'),
  ('DELIVERY_CONTACT', 'Who to call about a delivery');

-- Order 12571, recorded the generic way only: Ana orders a book and pens for
-- the García-López household, which pays; the book is a gift for Kiri. Its
-- sales_order row has every column empty, so the 4.3 subtype check holds.
insert into "order" (order_id, order_kind, order_date, entry_date) values
  (12571, 'SALES', '2025-07-01', '2025-07-01');

select setval(pg_get_serial_sequence('"order"', 'order_id'), (select max(order_id) from "order"));

insert into sales_order (order_id) values (12571);

insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, quantity, unit_price) values
  (25, 12571, 1, 7, 1, 45.00),   -- the Data Model Resource Book
  (26, 12571, 2, 2, 2, 2.50);    -- two pens

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

insert into sales_order_item (order_item_id) values (25), (26);

-- Parties: 1 Ana, 3 Chloe, 4 Northwind, 8 the García-López family, 10 Kiri.
insert into order_role (order_id, party_id, order_role_type_id, percent_contribution) values
  (12571, 1, 'PLACED_BY',   null),
  (12571, 4, 'TAKEN_BY',    null),
  (12571, 8, 'BILL_TO',     null),
  (12571, 3, 'SALESPERSON', 100),
  (12571, 1, 'BILL_TO',     null),   -- DATA ERROR: a second bill-to; a column would have held one (caught by a query)
  (12561, 2, 'BILL_TO',     null);   -- DATA ERROR: 12561 already has a bill-to column (Contoso) (caught by a query)

-- Contact mechanisms: 5 Kiri's phone, 6 Ana's e-mail, 8 our website,
-- 11 the family's house at 742 Evergreen Terrace.
insert into order_contact_mechanism (order_id, contact_mechanism_id, contact_mechanism_purpose_type_id) values
  (12571, 6,  'ORDER_PLACING'),
  (12571, 8,  'ORDER_TAKING'),
  (12571, 11, 'BILLING'),
  (12571, 11, 'BILLING');   -- DATA ERROR: the same row twice (caught by a query)

-- Item roles: what the columns of 4.3 had no place for. 4 is 12561's copier,
-- recorded the specific way; its installer is a generic row beside it.
insert into order_item_role (order_item_id, party_id, order_item_role_type_id) values
  (25, 1,  'SHIP_TO'),
  (25, 10, 'END_USER'),    -- the book is Kiri's
  (26, 1,  'SHIP_TO'),
  (4,  1,  'INSTALLER');   -- Ana, a contractor, installs the copier

insert into order_item_contact_mechanism (order_item_id, contact_mechanism_id, contact_mechanism_purpose_type_id) values
  (25, 11, 'SHIPPING'),
  (25, 5,  'DELIVERY_CONTACT'),   -- the courier calls Kiri
  (26, 11, 'SHIPPING');
