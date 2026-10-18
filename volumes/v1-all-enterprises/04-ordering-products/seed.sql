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
  (12560, 'SALES',    '2001-06-08', '2001-06-08'),   -- Tables 4.2 and 4.3's order
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
  (62, 2,  'PLACING_CUSTOMER', '2023-06-01', null),   -- Ben, once he stopped being a prospect
  (67, 16, 'BILL_TO_CUSTOMER', '1999-01-01', null),   -- ACME, for Table 4.5 (added after 4.4's 63-66)
  (68, 16, 'SHIP_TO_CUSTOMER', '1999-01-01', null);

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

-- Contact mechanisms from Ch 2: 1 and 2 Northwind's phone lines, 7 Contoso's
-- sales inbox (Ben reads it as Contoso's contact), 8 Northwind's website,
-- 14 Northwind's Chatham warehouse, 15 Contoso's office at 1 Market St.
-- New: Contoso's St. Louis depot, for deliveries only.
-- Table 4.5's addresses for order 12560 (the cities are ours): 32 ACME's
-- head office, 33 ABC's at 100 Main Street, 34 ACME's delivery address.
insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (30, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS'),
  (32, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS'),
  (33, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS'),
  (34, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into postal_address (contact_mechanism_id, address1, address2, directions) values
  (30, '800 Riverfront Ave',  'Dock 3', 'Trucks use the river gate'),
  (32, '234 Stretch Street',  null,     null),
  (33, '100 Main Street',     null,     null),
  (34, '2300 Drident Avenue', null,     null);

insert into postal_address_boundary (contact_mechanism_id, geographic_boundary_id) values
  (30, 18), (30, 17), (30, 11), (30, 6),   -- St. Louis MO 63101, US
  (32, 17), (32, 11), (32, 6),             -- St. Louis MO, US
  (33, 13), (33, 12), (33, 10), (33, 6),   -- Springfield, Sangamon County, IL, US
  (34, 17), (34, 11), (34, 6);

insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (30, 5,  30, '2022-01-01', null, true,  'SHIP_TO_CUSTOMER',      'St. Louis depot: deliveries only, no sales mail'),
  (32, 16, 32, '1999-01-01', null, false, 'BILL_TO_CUSTOMER',      'Head office'),
  (33, 13, 33, '1999-01-01', null, false, 'INTERNAL_ORGANIZATION', null),
  (34, 12, 33, '1998-03-04', null, false, null,                    'Shared with ABC Subsidiary'),
  (35, 16, 34, '1999-01-01', null, false, 'SHIP_TO_CUSTOMER',      'Deliveries');

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

insert into sales_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id,
                         placed_using_contact_mechanism_id, taken_via_contact_mechanism_id, bill_to_contact_mechanism_id) values
  (12560, 60, 32, 67,   32,   33,   32),     -- Table 4.5: ACME places it from its head office, ABC Subsidiary takes it, ACME pays
  (12561, 61, 1,  6,    7,    8,    15),     -- Contoso orders from its sales inbox on our website; bill to 1 Market St
  (12562, 62, 1,  6,    7,    2,    15),     -- Ben places it for Contoso, which pays: four parties, four jobs
  (12563, 62, 1,  null, null, 1,    null),   -- Ben's own order, by phone: no bill-to, so Ben pays
  (12565, 62, 1,  null, null, 1,    null),   -- DATA ERROR: Ben's placing role starts 2023-06-01, after this order (caught by a query)
  (12566, 61, 1,  7,    7,    8,    15);     -- DATA ERROR: billed to Contoso's SHIP_TO role, not its BILL_TO role (caught by a query)
  -- 12567: no row at all. DATA ERROR: a sales order without its sales_order row (caught by a query)

-- Ship-to per item. Feature items (5, 6, 8, 10, 12) ship with their product's item.
update sales_order_item set ship_to_party_role_id = 68, ship_to_contact_mechanism_id = 34 where order_item_id in (1, 2);   -- Table 4.5: 12560's paper and pens to Drident Avenue
update sales_order_item set ship_to_party_role_id = 68, ship_to_contact_mechanism_id = 32 where order_item_id = 3;         --   and its diskettes to the head office
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

-- Table 4.7's A2395, stored as 2395 (our keys are numbers). ABC buys office
-- cleaning from a new supplier, for one of its stores.
insert into party (party_id, party_kind) values
  (43, 'ORGANIZATION'),   -- Ace Cleaning Service
  (44, 'ORGANIZATION');   -- ABC Retail Store

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (43, 'CORPORATION',    'Ace Cleaning Service'),
  (44, 'OTHER_INFORMAL', 'ABC Retail Store');   -- a store of ABC's, not a legal entity

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (69, 13, 'PLACING_BUYER',     '1999-01-01', null),   -- ABC Subsidiary
  (70, 12, 'BILL_TO_PURCHASER', '1998-03-04', null),   -- ABC Corporation
  (71, 44, 'SHIP_TO_BUYER',     '2000-01-01', null),   -- ABC Retail Store
  (72, 43, 'SUPPLIER',          '2001-01-01', null);   -- Ace Cleaning Service

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (35, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS'),
  (36, 'POSTAL_ADDRESS', 'POSTAL_ADDRESS');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into postal_address (contact_mechanism_id, address1, address2, directions) values
  (35, '3590 Cottage Avenue', null, null),
  (36, '2345 Johnson Blvd',   null, null);

insert into postal_address_boundary (contact_mechanism_id, geographic_boundary_id) values
  (35, 13), (35, 12), (35, 10), (35, 6),   -- Springfield IL, US (ours)
  (36, 14), (36, 12), (36, 10), (36, 6);   -- Chatham IL, US (ours)

insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (36, 43, 35, '2001-01-01', null, false, 'SUPPLIER',      null),
  (37, 44, 36, '2000-01-01', null, false, 'SHIP_TO_BUYER', 'The store');

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

insert into "order" (order_id, order_kind, order_date, entry_date) values
  (2395, 'PURCHASE', '2001-07-09', '2001-07-09');   -- Tables 4.3 and 4.7's A2395

-- Table 4.3's lines, with no product: our catalogue sells neither.
insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, quantity, unit_price, item_description) values
  (27, 2395, 1, null, 12, 15.00, 'Hourly office cleaning service'),
  (28, 2395, 2, null, 1,  10.00, 'Basic cleaning supplies kit');

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

insert into purchase_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id,
                            placed_using_contact_mechanism_id, taken_via_contact_mechanism_id, bill_to_contact_mechanism_id) values
  (2395, 69, 72, 70, 33, 35, 33);   -- ABC Subsidiary places it, Ace takes it, ABC Corporation pays

-- Ship-to per item. The freight line (23) is a service: no ship-to.
insert into purchase_order_item (order_item_id, ship_to_party_role_id, ship_to_contact_mechanism_id) values
  (16, 65,   14),     -- paper to the Chatham warehouse
  (17, 65,   14),
  (18, 65,   13),     -- books to the office
  (22, 65,   15),     -- a drop ship: our ship-to role, Contoso's address (labelled by a query)
  (23, null, null),
  (24, 65,   14),
  (27, 71,   36),     -- A2395: the cleaning, and the kit, at ABC Retail Store
  (28, 71,   36),
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

-- ============================================================
-- Fig 4.6 — Order adjustments
-- ============================================================
-- The book's six subtypes on top, our finer types under them.
insert into order_adjustment_type (order_adjustment_type_id, parent_type_id, description) values
  ('DISCOUNT',              null,                    'Discount adjustment'),
  ('SURCHARGE',             null,                    'Surcharge adjustment'),
  ('SALES_TAX',             null,                    'Sales tax'),
  ('SHIPPING_AND_HANDLING', null,                    'Shipping and handling charge'),
  ('FEE',                   null,                    'Fee'),
  ('MISCELLANEOUS_CHARGE',  null,                    'Miscellaneous charge'),
  ('LOYALTY_DISCOUNT',      'DISCOUNT',              'Loyalty discount'),
  ('VOLUME_DISCOUNT',       'DISCOUNT',              'Volume discount'),
  ('RUSH_SURCHARGE',        'SURCHARGE',             'Rush order surcharge'),
  ('FREIGHT',               'SHIPPING_AND_HANDLING', 'Freight'),
  ('SETUP_FEE',             'FEE',                   'Set-up fee'),
  ('SMALL_ORDER_FEE',       'FEE',                   'Small order fee'),
  ('GIFT_WRAP',             null,                    'Gift wrapping');   -- DATA ERROR: rolls up to none of the six (caught by a query)

-- Items: 4 the copier on 12561, with 5 its duplex unit and 6 its finisher,
-- 7 the paper for the St. Louis depot; 9 the blue pens on 12562; 11 the red
-- pens; 13 Ben's engraved pen set; 20 the paper on 12566.
insert into order_adjustment (order_adjustment_id, order_adjustment_type_id, order_id, order_item_id, amount, percentage) values
  (1,  'LOYALTY_DISCOUNT', 12561, null, null,   5),       -- on the whole order
  (2,  'FREIGHT',          12561, null, 150.00, null),
  (3,  'SETUP_FEE',        null,  4,    75.00,  null),
  (4,  'SALES_TAX',        null,  4,    null,   9.679),   -- Missouri + St. Louis
  (5,  'SALES_TAX',        null,  5,    null,   9.679),
  (6,  'SALES_TAX',        null,  6,    null,   9.679),
  (7,  'SALES_TAX',        null,  7,    null,   9.679),   -- the general rate; the lookup taxes paper lower in Missouri (shown by a query)
  (8,  'VOLUME_DISCOUNT',  null,  9,    null,   10),      -- 30 pens
  (9,  'SMALL_ORDER_FEE',  12563, null, 5.00,   null),
  (10, 'FREIGHT',          12564, null, 45.00,  null),    -- the supplier's freight on our purchase order
  (11, 'VOLUME_DISCOUNT',  12562, 11,   null,   10),      -- DATA ERROR: names the order AND an item (caught by a query)
  (12, 'RUSH_SURCHARGE',   null,  20,   15.00,  5),       -- DATA ERROR: an amount AND a percentage (caught by a query)
  (13, 'GIFT_WRAP',        null,  13,   3.00,   null);

select setval(pg_get_serial_sequence('order_adjustment', 'order_adjustment_id'), (select max(order_adjustment_id) from order_adjustment));

-- Invented rates. Boundaries (Ch 2): 10 Illinois, 11 Missouri, 12 Sangamon
-- County, 13 Springfield, 17 St. Louis. Category (Ch 3): 2 Paper, above
-- Bond paper.
insert into sales_tax_lookup (sales_tax_lookup_id, geographic_boundary_id, product_category_id, sales_tax_percentage) values
  (1, 10, null, 6.25),
  (2, 12, null, 1.00),
  (3, 13, null, 2.50),
  (4, 11, null, 4.225),
  (5, 11, 2,    3.00),    -- Missouri taxes paper lower
  (6, 17, null, 5.454),
  (7, 11, null, 4.50);    -- DATA ERROR: a second general rate for Missouri (caught by a query)

select setval(pg_get_serial_sequence('sales_tax_lookup', 'sales_tax_lookup_id'), (select max(sales_tax_lookup_id) from sales_tax_lookup));

-- ============================================================
-- Fig 4.7 — Order status and terms
-- ============================================================
-- Order statuses, a new group in Ch 2's shared status_type. Backordered,
-- shipped and invoiced could be worked out from the item association (4.8),
-- shipments (Ch 5) and invoices (Ch 7); stored anyway, as the book allows,
-- and checked against the facts where the facts exist.
insert into status_type (status_type_id, parent_type_id, description) values
  ('ORDER_STATUS',      null,           'Order status'),
  ('ORDER_RECEIVED',    'ORDER_STATUS', 'Received'),
  ('ORDER_APPROVED',    'ORDER_STATUS', 'Approved'),
  ('ORDER_BACKORDERED', 'ORDER_STATUS', 'Backordered'),
  ('ORDER_SHIPPED',     'ORDER_STATUS', 'Shipped'),
  ('ORDER_INVOICED',    'ORDER_STATUS', 'Invoiced'),
  ('ORDER_COMPLETED',   'ORDER_STATUS', 'Completed'),
  ('ORDER_CANCELLED',   'ORDER_STATUS', 'Cancelled');

-- Items: 4 the copier on 12561, 7 its paper for the depot; 9 the blue pens on
-- 12562; 13 Ben's engraved pen set on 12563.
insert into order_status (order_status_id, status_type_id, order_id, order_item_id, status_datetime) values
  (1,  'ORDER_RECEIVED',    12560, null, '2001-06-08 10:00+00'),
  (2,  'ORDER_APPROVED',    12560, null, '2001-06-08 15:30+00'),
  (3,  'ORDER_SHIPPED',     12560, null, '2001-06-12 09:00+00'),
  (4,  'ORDER_RECEIVED',    12561, null, '2025-02-10 09:15+00'),
  (5,  'ORDER_APPROVED',    12561, null, '2025-02-10 11:00+00'),
  (6,  'ORDER_BACKORDERED', null,  4,    '2025-02-11 08:30+00'),   -- the copier waits on purchase order 12568 (linked in 4.8)
  (7,  'ORDER_SHIPPED',     null,  7,    '2025-02-12 14:00+00'),   -- the paper leaves first
  (8,  'ORDER_SHIPPED',     null,  4,    '2025-02-21 16:00+00'),   -- the copier, drop-shipped
  (9,  'ORDER_COMPLETED',   12561, null, '2025-02-25 12:00+00'),
  (10, 'ORDER_RECEIVED',    12562, null, '2025-03-03 16:40+00'),
  (11, 'ORDER_RECEIVED',    12567, null, '2025-05-02 10:00+00'),
  (12, 'ORDER_CANCELLED',   12567, null, '2025-05-07 09:00+00'),
  (13, 'ORDER_APPROVED',    12564, null, '2025-01-20 13:00+00'),   -- a purchase order: Chloe approved it
  (14, 'ORDER_COMPLETED',   12564, null, '2025-02-03 17:00+00'),
  (15, 'ORDER_APPROVED',    2395,  null, '2001-07-09 11:00+00'),
  (16, 'ORDER_BACKORDERED', null,  13,   '2024-11-06 09:00+00'),   -- DATA ERROR: no purchase line behind it (caught by a 4.8 query)
  (17, 'ORDER_APPROVED',    12562, 9,    '2025-03-04 08:00+00'),   -- DATA ERROR: the order AND an item (caught by a query)
  (18, 'CASE_OPEN',         12566, null, '2025-04-01 10:00+00'),   -- DATA ERROR: a case status on an order (caught by a query)
  (19, 'ORDER_RECEIVED',    12565, null, '2023-03-01 10:00+00');   -- DATA ERROR: received two weeks before the order date (caught by a query)

select setval(pg_get_serial_sequence('order_status', 'order_status_id'), (select max(order_status_id) from order_status));

-- Table 4.9's five types, then two of ours. The ids name the unit, since
-- the value doesn't carry one.
insert into term_type (term_type_id, description) values
  ('CANCELLATION_CHARGE_PCT',    'Percentage cancellation charge'),
  ('PENALTY_FREE_CANCEL_DAYS',   'Days within which the order may be cancelled without a penalty'),
  ('NO_EXCHANGE_OR_REFUND',      'No exchanges or refunds once delivered'),
  ('NONPERFORMANCE_PENALTY_PCT', 'Percentage penalty the supplier pays for nonperformance'),
  ('DELIVERY_WITHIN_DAYS',       'Days within which delivery must occur'),
  ('PAYMENT_DUE_DAYS',           'Days within which the invoice must be paid'),
  ('WARRANTY_MONTHS',            'Months of warranty');

-- Items: 2 the pen line on 12560; 27 A2395's cleaning line; 4 the copier on
-- 12561; 9 the blue pens on 12562.
insert into order_term (order_term_id, term_type_id, order_id, order_item_id, term_value) values
  (1,  'CANCELLATION_CHARGE_PCT',    12560, null, 25),     -- Table 4.9
  (2,  'PENALTY_FREE_CANCEL_DAYS',   12560, null, 10),
  (3,  'NO_EXCHANGE_OR_REFUND',      null,  2,    null),   -- the type says it all
  (4,  'NONPERFORMANCE_PENALTY_PCT', null,  27,   5),
  (5,  'DELIVERY_WITHIN_DAYS',       null,  27,   30),
  (6,  'PAYMENT_DUE_DAYS',           12561, null, 30),     -- ours from here
  (7,  'WARRANTY_MONTHS',            null,  4,    12),
  (8,  'PENALTY_FREE_CANCEL_DAYS',   12567, null, 3),      -- the order cancelled above, a day late
  (9,  'PAYMENT_DUE_DAYS',           12561, null, 45),     -- DATA ERROR: a second payment term on 12561 (caught by a query)
  (10, 'WARRANTY_MONTHS',            12562, 9,    6);      -- DATA ERROR: the order AND an item (caught by a query)

select setval(pg_get_serial_sequence('order_term', 'order_term_id'), (select max(order_term_id) from order_term));

-- ============================================================
-- Fig 4.8 — Order item association
-- ============================================================
-- Table 4.10's orders, one line each. Products, quantities, dates and
-- parties are ours: ACME buys 200 pens from ABC Subsidiary, which buys them
-- from Fantastic Supplies for ABC Retail Store. Roles: 60 ACME placing, 32 ABC
-- Subsidiary internal, 68 ACME ship-to; 69 ABC Subsidiary placing buyer, 37
-- Fantastic supplier, 70 ABC Corporation bill-to purchaser, 71 ABC Retail
-- Store ship-to buyer.
insert into "order" (order_id, order_kind, order_date, entry_date) values
  (13480, 'SALES',    '2001-08-20', '2001-08-20'),
  (23490, 'PURCHASE', '2001-08-21', '2001-08-21');

insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, quantity, unit_price) values
  (29, 13480, 1, 2, 200, 11.00),
  (30, 23490, 1, 2, 200, 6.00);

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

insert into sales_order (order_id, placed_by_party_role_id, taken_by_party_role_id) values
  (13480, 60, 32);

insert into sales_order_item (order_item_id, ship_to_party_role_id, ship_to_contact_mechanism_id) values
  (29, 68, 34);

insert into purchase_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id) values
  (23490, 69, 37, 70);

insert into purchase_order_item (order_item_id, ship_to_party_role_id, ship_to_contact_mechanism_id) values
  (30, 71, 36);

insert into order_status (status_type_id, order_id, order_item_id, status_datetime) values
  ('ORDER_RECEIVED',    13480, null, '2001-08-20 09:00+00'),
  ('ORDER_BACKORDERED', null,  29,   '2001-08-21 10:00+00');   -- waiting on 23490's line

-- Sales lines: 4 the copier on 12561, 7 its paper for the depot; 9 and 11 the
-- pens on 12562; 20 the paper on 12566; 29 the pens on 13480. Purchase lines:
-- 16 the 500 reams on 12564, 17 its 100 pens, 18 its books; 22 the copier on
-- 12568; 24 the paper on 12570; 30 the pens on 23490.
insert into order_item_association (sales_order_item_id, purchase_order_item_id) values
  (29, 30),   -- Table 4.10: 13480 line 1, filled by 23490 line 1
  (4,  22),   -- 4.4's drop ship, linked at last
  (7,  16),   -- one sales line, two purchase lines
  (7,  24),
  (20, 16),   -- one purchase line, two sales lines
  (9,  17),
  (11, 17),
  (4,  22),   -- DATA ERROR: the same link twice (caught by a query)
  (9,  18);   -- DATA ERROR: 12564's books "filling" 12562's pens (caught by a query)

-- ============================================================
-- Fig 4.9 — Requirements
-- ============================================================
-- Table 4.11's diskettes are "formatted", a feature Ch 3 didn't have.
insert into product_feature (product_feature_id, product_feature_type_id, description) values
  (24, 'OTHER', 'Formatted');

select setval(pg_get_serial_sequence('product_feature', 'product_feature_id'), (select max(product_feature_id) from product_feature));

insert into status_type (status_type_id, parent_type_id, description) values
  ('REQUIREMENT_STATUS',    null,                 'Requirement status'),
  ('REQUIREMENT_CREATED',   'REQUIREMENT_STATUS', 'Created'),
  ('REQUIREMENT_APPROVED',  'REQUIREMENT_STATUS', 'Approved'),
  ('REQUIREMENT_FULFILLED', 'REQUIREMENT_STATUS', 'Fulfilled'),
  ('REQUIREMENT_CANCELLED', 'REQUIREMENT_STATUS', 'Cancelled');

insert into requirement_role_type (requirement_role_type_id, description) values
  ('OWNER',     'Owner: answers for the requirement'),
  ('REQUESTER', 'Asked for it'),
  ('APPROVER',  'Approved it');

-- Table 4.11, with its ids. "May 16 2002" read as 2001, and 34988 seeded with
-- no parent, beside 24905 (NOTES, point 19). Then ours, 50001-50004.
-- Facilities (Ch 2): 5 the Chatham warehouse, 6 Contoso's Market St North
-- building.
insert into requirement (requirement_id, requirement_origin, requirement_kind, description, requirement_creation_date,
                         required_by_date, estimated_budget, quantity, reason, part_of_requirement_id, facility_id) values
  (24905, 'INTERNAL', 'WORK',    'Repair 14 PCs',                              '2001-04-13', null,         null,  14,   null,                              null,  null),
  (43005, 'INTERNAL', 'WORK',    'Have the office cleaned on a regular basis', '2001-05-16', null,         null,  null, null,                              null,  null),
  (43006, 'INTERNAL', 'PRODUCT', 'Cleaning service',                           '2001-05-16', null,         null,  null, null,                              43005, null),
  (43007, 'INTERNAL', 'PRODUCT', 'Cleaning supplies',                          '2001-05-16', null,         null,  null, null,                              43005, null),
  (30003, 'CUSTOMER', 'PRODUCT', 'Office supplies',                            '2001-05-15', null,         null,  null, null,                              null,  null),
  (30004, 'CUSTOMER', 'PRODUCT', 'Reams of bond paper',                        '2001-05-16', null,         null,  50,   null,                              30003, null),
  (30005, 'CUSTOMER', 'PRODUCT', 'Goldstein Elite pen',                        '2001-05-16', null,         null,  40,   null,                              30003, null),
  (30006, 'CUSTOMER', 'PRODUCT', 'Reams of copier paper',                      '2001-05-16', null,         null,  20,   null,                              30003, null),
  (30007, 'CUSTOMER', 'PRODUCT', 'Diskettes',                                  '2001-05-16', null,         null,  200,  null,                              30003, null),
  (34988, 'INTERNAL', 'WORK',    'Repair 15 PCs',                              '2001-06-20', null,         null,  15,   null,                              null,  null),
  (50001, 'INTERNAL', 'PRODUCT', 'Copier paper for the Chatham warehouse',     '2025-01-10', '2025-01-31', 16000, 400,  'Stock for the first quarter',     null,  5),
  (50002, 'CUSTOMER', 'PRODUCT', 'A copier for the Market St office',          '2025-01-28', '2025-02-28', 4500,  1,    'The old copier is beyond repair', null,  6),
  (50003, 'INTERNAL', 'WORK',    'Repair the loading dock door',               '2025-03-01', '2025-03-15', 1200,  null, 'It sticks half open',             null,  5),
  (50004, 'CUSTOMER', 'PRODUCT', 'Red pens for the sales team',                '2025-03-01', null,         null,  50,   null,                              null,  6);

select setval(pg_get_serial_sequence('requirement', 'requirement_id'), (select max(requirement_id) from requirement));

-- Products (Ch 3): 1 Johnson's bond paper, 2 the Goldstein pen, 6 the copier.
insert into product_requirement (requirement_id, product_id) values
  (43006, null), (43007, null),
  (30003, null), (30004, null), (30005, null), (30006, null), (30007, null),   -- Table 4.11 names no product
  (50001, 1),
  (50002, 6),
  (50004, 2),
  (50003, null);   -- DATA ERROR: a WORK requirement with a product row (caught by a query)

-- Features (Ch 3): 1 Fine grade, 2 White, 3 Blue, 5 Red, 6 Width 8.5 in,
-- 7 Length 11 in, 8 Basis weight 20 lb, 11 3½-inch, 12 Capacity 1.44 MB,
-- 13 Duplex unit, 14 Stapling finisher, 18 Scan-to-email, 24 Formatted.
insert into desired_feature (requirement_id, product_feature_id, optional_ind) values
  (30004, 6,  false), (30004, 7,  false), (30004, 1,  false),   -- 8½ by 11 inches, fine grade
  (30005, 3,  false),                                           -- blue
  (30006, 6,  false), (30006, 7,  false), (30006, 2,  false),   -- 8½ by 11 inches, white
  (30007, 11, false), (30007, 12, false), (30007, 24, false),   -- 3½-inch, high density, formatted
  (50001, 2,  false), (50001, 8,  true),                        -- white; 20 lb if possible
  (50002, 13, false), (50002, 14, true),  (50002, 18, true),    -- a duplex unit; a finisher and scan-to-email are nice to have
  (50004, 5,  false);                                           -- DATA ERROR: red was dropped for the pen in 2020 (caught by a query)

insert into requirement_status (requirement_id, status_type_id, status_date) values
  (30003, 'REQUIREMENT_CREATED',   '2001-05-15'),
  (30004, 'REQUIREMENT_APPROVED',  '2001-05-17'),
  (43005, 'REQUIREMENT_CREATED',   '2001-05-16'),
  (43005, 'REQUIREMENT_APPROVED',  '2001-05-20'),
  (50001, 'REQUIREMENT_CREATED',   '2025-01-10'),
  (50001, 'REQUIREMENT_APPROVED',  '2025-01-15'),
  (50001, 'REQUIREMENT_FULFILLED', '2025-02-03'),
  (50002, 'REQUIREMENT_CREATED',   '2025-01-28'),
  (50002, 'REQUIREMENT_FULFILLED', '2025-02-21'),
  (50003, 'REQUIREMENT_CREATED',   '2025-03-01'),
  (50004, 'REQUIREMENT_CANCELLED', '2025-03-02'),
  (50003, 'ORDER_APPROVED',        '2025-03-02');   -- DATA ERROR: an order status on a requirement (caught by a query)

-- Parties (Ch 2): 2 Ben, 3 Chloe, 4 Northwind, 5 Contoso, 12 ABC Corporation,
-- 13 ABC Subsidiary, 16 ACME.
insert into requirement_role (requirement_id, party_id, requirement_role_type_id, from_date, thru_date) values
  (24905, 12, 'OWNER',     '2001-04-13', null),   -- Table 4.11's owners
  (43005, 13, 'OWNER',     '2001-05-16', null),
  (43006, 13, 'OWNER',     '2001-05-16', null),
  (43007, 13, 'OWNER',     '2001-05-16', null),
  (30003, 16, 'OWNER',     '2001-05-15', null),
  (30004, 13, 'OWNER',     '2001-05-16', null),
  (30005, 13, 'OWNER',     '2001-05-16', null),
  (30006, 13, 'OWNER',     '2001-05-16', null),
  (30007, 13, 'OWNER',     '2001-05-16', null),
  (34988, 12, 'OWNER',     '2001-06-20', null),
  (43005, 12, 'APPROVER',  '2001-05-20', null),   -- ours from here
  (50001, 4,  'OWNER',     '2025-01-10', null),
  (50001, 3,  'REQUESTER', '2025-01-10', null),
  (50002, 5,  'OWNER',     '2025-01-28', null),
  (50002, 2,  'REQUESTER', '2025-01-28', null),   -- Ben asks for it
  (50003, 4,  'OWNER',     '2025-03-01', null),
  (50004, 5,  'OWNER',     '2025-03-01', null),
  (50002, 2,  'OWNER',     '2025-02-01', null);   -- DATA ERROR: a second owner while Contoso still owns it (caught by a query)

-- Order items: 1-3 12560's paper, pens and diskettes; 27-28 A2395's cleaning
-- and kit; 16 12564's 500 reams; 4 12561's copier; 29 13480's 200 pens.
insert into order_requirement_commitment (order_item_id, requirement_id, quantity) values
  (1,  30004, 10),    -- 10 of ACME's 50 reams
  (2,  30005, 4),     -- 4 of its 40 pens
  (3,  30007, 6),     -- 6 of its 200 diskettes
  (27, 43006, 12),    -- A2395's 12 hours of cleaning
  (28, 43007, 1),
  (16, 50001, 400),   -- 400 of 12564's 500 reams; the rest is stock
  (4,  50002, 1),     -- Contoso's copier
  (29, 30005, 40);    -- DATA ERROR: 40 more pens for a need of 40, with 4 already committed (caught by a query)

-- ============================================================
-- Fig 4.10 — Requests
-- ============================================================
insert into request_type (request_type_id, description) values
  ('RFI', 'Request for information'),
  ('RFP', 'Request for proposal'),
  ('RFQ', 'Request for quote');

insert into request_role_type (request_role_type_id, description) values
  ('ORIGINATOR', 'Sent the request'),
  ('CONTACT',    'Answers questions about it'),
  ('APPROVER',   'Approved sending it');

-- Two PC repair vendors (ours), and ABC Subsidiary's supplies@ABC.com (Table
-- 4.5), where ACME's request arrives.
insert into party (party_id, party_kind) values
  (45, 'ORGANIZATION'),   -- Ridgeway PC Repair
  (46, 'ORGANIZATION');   -- Byte Doctors

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (45, 'CORPORATION', 'Ridgeway PC Repair'),
  (46, 'CORPORATION', 'Byte Doctors');

insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (37, 'ELECTRONIC_ADDRESS', 'EMAIL'),
  (38, 'ELECTRONIC_ADDRESS', 'EMAIL'),
  (39, 'ELECTRONIC_ADDRESS', 'EMAIL');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into electronic_address (contact_mechanism_id, electronic_address_string) values
  (37, 'bids@ridgeway.example'),
  (38, 'sales@bytedoctors.example'),
  (39, 'supplies@ABC.com');

insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (38, 45, 37, '2000-01-01', null, false, null,                    null),
  (39, 46, 38, '2000-01-01', null, false, null,                    null),
  (40, 13, 39, '1999-01-01', null, false, 'INTERNAL_ORGANIZATION', 'Orders and requests from customers');

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

-- Tables 4.12 and 4.13, with their ids: 23498 dated 2002 and 38967 an RFP
-- (NOTES, point 21). Then ours, 61001 and 61002.
insert into request (request_id, request_type_id, request_date, response_required_date, description) values
  (23498, 'RFI', '2002-01-12', '2002-02-10', 'Information on PC repair vendors'),
  (38967, 'RFP', '2002-03-13', '2002-04-23', 'Quotes from vendors on repairing PCs'),
  (38948, 'RFQ', '2002-03-13', '2002-03-21', 'A quote on office supplies'),
  (61001, 'RFQ', '2025-01-12', '2025-01-17', 'Copier paper for the Chatham warehouse'),
  (61002, 'RFP', '2025-02-20', '2025-03-10', 'Repair of the Chatham loading dock door');

select setval(pg_get_serial_sequence('request', 'request_id'), (select max(request_id) from request));

-- The required-by dates and amounts are ours.
insert into request_item (request_item_id, request_id, request_item_seq_id, required_by_date, quantity, maximum_amount, description) values
  (1, 23498, 1, '2002-06-30', 29,   null,    'PC repair'),
  (2, 38967, 1, '2002-06-30', 29,   null,    'PC repair'),
  (3, 38948, 1, '2002-04-15', 50,   null,    null),
  (4, 38948, 2, '2002-04-15', 40,   null,    null),
  (5, 38948, 3, '2002-04-15', 20,   null,    null),
  (6, 38948, 4, '2002-04-15', 200,  null,    null),
  (7, 61001, 1, '2025-01-31', 400,  12800.00, null),
  (8, 61002, 1, '2025-03-15', null, 1200.00, 'Repair or replace the dock door');

select setval(pg_get_serial_sequence('request_item', 'request_item_id'), (select max(request_item_id) from request_item));

insert into requirement_request (request_item_id, requirement_id) values
  (1, 24905), (1, 34988),   -- 14 + 15 PCs = 29
  (2, 24905), (2, 34988),
  (3, 30004), (4, 30005), (5, 30006), (6, 30007),
  (7, 50001),
  (8, 50003),               -- DATA ERROR: the RFP went out before the requirement was created (caught by a query)
  (6, 30007);               -- DATA ERROR: the diskettes entered twice (caught by a query)

-- Parties: 3 Chloe, 4 Northwind, 12 ABC Corporation, 16 ACME.
insert into request_role (request_id, party_id, request_role_type_id) values
  (23498, 12, 'ORIGINATOR'),   -- Table 4.12's originators
  (38967, 12, 'ORIGINATOR'),
  (38948, 16, 'ORIGINATOR'),
  (61001, 4,  'ORIGINATOR'),
  (61001, 3,  'CONTACT'),
  (61002, 4,  'ORIGINATOR'),
  (61001, 3,  'ORIGINATOR');   -- DATA ERROR: a second originator (caught by a query)

-- Parties: 5 Contoso, 13 ABC Subsidiary, 18 Fantastic Supplies, 42
-- Paperline, 45 Ridgeway, 46 Byte Doctors. Mechanisms: 7 Contoso's sales
-- inbox, 31 Fantastic's order desk, 37-39 above.
insert into responding_party (request_id, party_id, contact_mechanism_id, date_sent) values
  (23498, 45, 37,   '2002-01-14'),   -- ABC's requests go out to two vendors
  (23498, 46, 38,   '2002-01-14'),
  (38967, 45, 37,   '2002-03-14'),
  (38967, 46, 38,   '2002-03-14'),
  (38948, 13, 39,   null),           -- ACME's request comes in: one responding party, us
  (61001, 18, 31,   '2025-01-12'),
  (61002, 5,  7,    '2025-02-20'),
  (61001, 42, null, '2025-01-10');   -- DATA ERROR: sent two days before the request's date (caught by a query)

-- ============================================================
-- Fig 4.11 — Quotes
-- ============================================================
insert into quote_type (quote_type_id, description) values
  ('PROPOSAL',      'Proposal: an approach and a price'),
  ('PRODUCT_QUOTE', 'Product quote: prices for items'),
  ('OTHER_QUOTE',   'Other quote');

insert into quote_role_type (quote_role_type_id, description) values
  ('PREPARER', 'Prepared the quote'),
  ('APPROVER', 'Approved it'),
  ('CONTACT',  'Answers questions about it');

-- New to Ch 3's catalogue: pencils, for Table 4.14's "pens and pencils";
-- Table 4.15's Johnson black pen (black and Johnson, features 4 and 9) and
-- its PC repair, a service sold by the hour (70 at $75, read as hours).
-- Categories: 4 writing instruments, 12 maintenance.
insert into product (product_id, product_kind, name, introduction_date, uom_id) values
  (17, 'GOOD',    'Yellow #2 pencils, box of 12', '1995-01-01', 'BOX'),
  (18, 'GOOD',    'Johnson black pen',            '1999-01-01', 'EA'),
  (19, 'SERVICE', 'PC repair',                    '2000-01-01', 'HR');

select setval(pg_get_serial_sequence('product', 'product_id'), (select max(product_id) from product));

insert into good (product_id, good_kind) values
  (17, 'FINISHED_GOOD'),
  (18, 'FINISHED_GOOD');

insert into product_category_classification (product_id, product_category_id, from_date, thru_date, primary_flag, comment) values
  (17, 4,  '1995-01-01', null, true, null),
  (18, 4,  '1999-01-01', null, true, null),
  (19, 12, '2000-01-01', null, true, null);

insert into product_feature_applicability (product_id, product_feature_id, product_feature_applicability_type_id, from_date, thru_date) values
  (18, 4, 'REQUIRED', '1999-01-01', null),
  (18, 9, 'REQUIRED', '1999-01-01', null);

-- The planned job Byte Doctors' proposal prices (Ch 2's work_effort).
insert into work_effort (work_effort_id, work_effort_type_id, name, description, scheduled_start_date, scheduled_completion_date,
                         total_dollars_allowed, total_hours_allowed, estimated_hours) values
  (5, 'PROJECT', 'Repair 29 PCs', 'Diagnose and repair ABC Corporation''s PCs on site', '2002-04-01', '2002-04-30', null, 120, 100);

select setval(pg_get_serial_sequence('work_effort', 'work_effort_id'), (select max(work_effort_id) from work_effort));

-- Table 4.14, with its ids: 36908's issue date read as 2002 (NOTES, point
-- 22); the issuers and receivers are ours. Then ours: 62001 and 62002 for
-- Northwind, 62003 Byte Doctors' rival proposal for ABC's PCs. Thru dates
-- are exclusive: "valid until March 19" is stored as March 20.
-- Parties: 4 Northwind, 12 ABC Corporation, 13 ABC Subsidiary, 16 ACME, 18
-- Fantastic Supplies, 42 Paperline, 45 Ridgeway, 46 Byte Doctors.
insert into quote (quote_id, quote_type_id, issued_by_party_id, given_to_party_id, issue_date, valid_from_date, valid_thru_date, description) values
  (35678, 'PROPOSAL',      45, 12, '2002-02-19', '2002-02-19', '2002-03-20', 'Proposal to support the repair of PCs'),
  (36908, 'PRODUCT_QUOTE', 13, 16, '2002-03-12', '2002-03-12', '2002-03-31', 'Bid on pens and pencils'),
  (62001, 'PRODUCT_QUOTE', 18, 4,  '2025-01-14', '2025-01-14', '2025-02-15', 'Bond paper at a volume price'),
  (62002, 'PRODUCT_QUOTE', 42, 4,  '2025-01-15', '2025-01-15', '2025-01-31', 'Recycled bond paper'),
  (62003, 'PROPOSAL',      46, 12, '2002-03-25', '2002-03-25', '2002-04-25', 'Proposal to repair the PCs on site, as one job');

select setval(pg_get_serial_sequence('quote', 'quote_id'), (select max(quote_id) from quote));

-- Table 4.15's three lines (items 1-3), then ours. Request items (4.10): 2
-- 38967's PC repair, 3 and 4 38948's paper and pens, 7 61001's paper.
-- Products: 1 Johnson's bond paper, 12 recycled bond paper, 17 pencils, 18
-- the Johnson black pen, 19 PC repair.
insert into quote_item (quote_item_id, quote_id, quote_item_seq_id, product_id, work_effort_id, request_item_id,
                        quantity, quote_unit_price, estimated_delivery_date, comment) values
  (1, 35678, 1, 19,   null, 2,    70,  75.00,  '2002-04-30', '70 hours, read as the unit'),
  (2, 36908, 1, 1,    null, 3,    50,  3.75,   '2002-03-25', null),
  (3, 36908, 2, 18,   null, 4,    40,  1.25,   '2002-03-25', 'Black Johnson pens offered where the need wants blue ones'),
  (4, 62001, 1, 1,    null, 7,    500, 30.00,  '2025-01-27', 'A volume price: 500 reams, not the 400 asked for'),
  (5, 62002, 1, 12,   null, 7,    400, 31.50,  '2025-01-24', 'Recycled paper offered for white bond paper'),
  (6, 62001, 2, null, null, null, 1,   45.00,  null,         'DATA ERROR: freight, naming neither a product nor a work effort (caught by a query)'),
  (7, 36908, 3, 17,   null, null, 20,  1.80,   '2002-03-25', 'Ours, for Table 4.14''s pencils: offered though nobody asked'),
  (8, 62003, 1, null, 5,    2,    29,  120.00, '2002-04-30', 'Per PC, on site: the planned job, priced as work');

select setval(pg_get_serial_sequence('quote_item', 'quote_item_id'), (select max(quote_item_id) from quote_item));

-- Order lines (4.4): 16 12564's 500 reams, 24 12570's 200 reams.
update order_item set quote_item_id = 4 where order_item_id = 16;   -- 12564 accepts Fantastic's quote
update order_item set quote_item_id = 4 where order_item_id = 24;   -- DATA ERROR: 12570 (2023) accepting a 2025 quote (caught by a query)

insert into quote_role (quote_id, party_id, quote_role_type_id) values
  (62001, 3, 'CONTACT'),   -- Chloe, Northwind's buyer, for both answers to her RFQ
  (62002, 3, 'CONTACT');

-- The text's example of a quote term: the buyer names a central contact,
-- or the price may rise.
insert into term_type (term_type_id, description) values
  ('CENTRAL_CONTACT_REQUIRED', 'The buyer names a central point of contact, or the quoted price may rise');

-- Items: 4 Fantastic's paper, 5 Paperline's.
insert into quote_term (term_type_id, quote_id, quote_item_id, term_value) values
  ('PAYMENT_DUE_DAYS',           62001, null, 30),
  ('DELIVERY_WITHIN_DAYS',       null,  4,    10),
  ('NONPERFORMANCE_PENALTY_PCT', 35678, null, 5),
  ('CENTRAL_CONTACT_REQUIRED',   35678, null, null),
  ('WARRANTY_MONTHS',            62002, 5,    3);   -- DATA ERROR: the quote AND an item (caught by a query)

-- ============================================================
-- Fig 4.12 — Agreement definition
-- ============================================================
insert into agreement_type (agreement_type_id, parent_type_id, description) values
  ('PRODUCT_AGREEMENT',      null,                'Product agreement'),
  ('SALES_AGREEMENT',        'PRODUCT_AGREEMENT', 'Sales agreement'),
  ('PURCHASE_AGREEMENT',     'PRODUCT_AGREEMENT', 'Purchase agreement'),
  ('EMPLOYMENT_AGREEMENT',   null,                'Employment agreement'),
  ('OTHER_AGREEMENT',        null,                'Other agreement'),
  ('PARTNERSHIP_AGREEMENT',  'OTHER_AGREEMENT',   'Partnership agreement'),     -- Table 4.16
  ('DISTRIBUTION_AGREEMENT', 'OTHER_AGREEMENT',   'Distribution agreement');    -- ours

insert into agreement_role_type (agreement_role_type_id, description) values
  ('SUPPLIER',    'Supplier'),
  ('CUSTOMER',    'Customer'),
  ('EMPLOYER',    'Employer'),
  ('EMPLOYEE',    'Employee'),
  ('PARTNER',     'Partner'),
  ('DISTRIBUTOR', 'Distributor'),
  ('SIGNATORY',   'Signatory');   -- ours: signs for one of the parties

-- Table 4.16's new parties: William Jones, and XYZ Corporation (not Ch 2's
-- XYZ Subsidiary, which rolls up to ABC).
insert into party (party_id, party_kind) values
  (47, 'PERSON'),         -- William Jones
  (48, 'ORGANIZATION');   -- XYZ Corporation

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into person (party_id, gender_type_id) values
  (47, 'MALE');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  (47, 'FIRST', '1990-05-07', null, 'William'),
  (47, 'LAST',  '1990-05-07', null, 'Jones');

insert into organization (party_id, organization_type_id, name) values
  (48, 'CORPORATION', 'XYZ Corporation');

-- William's employment (Table 4.16's "employment relationship"): ABC
-- Corporation employs him, so it gets an internal organization role.
insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (73, 12, 'INTERNAL_ORGANIZATION', '1990-01-01', null),   -- ABC Corporation
  (74, 47, 'EMPLOYEE',              '1990-05-07', null);   -- William Jones

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into party_relationship (party_relationship_id, party_relationship_type_id, from_party_role_id, to_party_role_id, from_date, thru_date) values
  (17, 'EMPLOYMENT', 73, 74, '1990-05-07', null);

select setval(pg_get_serial_sequence('party_relationship', 'party_relationship_id'), (select max(party_relationship_id) from party_relationship));

-- Table 4.16, with its ids; the agreement date (none given) is the starting
-- date. Thru dates are exclusive: "December 30, 2002" is stored as December
-- 31. Then ours, 70001-70003. Party relationships (Ch 2): 2 Northwind
-- employs Chloe, 4 Contoso is Northwind's customer, 14 ACME is ABC
-- Subsidiary's customer, 15 Sellers Assistance sold for ABC Subsidiary until
-- 2002, 17 ABC Corporation employs William.
insert into agreement (agreement_id, agreement_type_id, party_relationship_id, agreement_date, from_date, thru_date, description, text) values
  (10002,  'SALES_AGREEMENT',        14,   '2002-01-01', '2002-01-01', '2002-12-31', 'Pricing and terms for buying inventory items', null),
  (86749,  'EMPLOYMENT_AGREEMENT',   17,   '1990-05-07', '1990-05-07', null,         'William hired as an entry-level information systems programmer', null),
  (489589, 'PARTNERSHIP_AGREEMENT',  null, '2000-06-01', '2000-06-01', '2001-06-02', 'An informal partnership, with terms to compensate the partners', null),
  (70001,  'SALES_AGREEMENT',        4,    '2024-12-10', '2025-01-01', '2026-01-01', 'Contoso''s office supply pricing for 2025', null),
  (70002,  'EMPLOYMENT_AGREEMENT',   2,    '2023-08-15', '2023-09-01', null,         'Chloe hired as a buyer', null),
  (70003,  'DISTRIBUTION_AGREEMENT', 15,   '2002-02-20', '2002-03-01', '2003-03-01', 'Sellers Assistance to resell ABC Subsidiary''s supplies', null);   -- DATA ERROR: relationship 15 ended on 2002-01-01 (caught by a query)

select setval(pg_get_serial_sequence('agreement', 'agreement_id'), (select max(agreement_id) from agreement));

-- Parties: 2 Ben, 3 Chloe, 4 Northwind, 5 Contoso, 12 ABC Corporation, 13 ABC
-- Subsidiary, 16 ACME, 17 Sellers Assistance, 47 William, 48 XYZ.
insert into agreement_role (agreement_id, party_id, agreement_role_type_id) values
  (10002,  12, 'SUPPLIER'),   -- Table 4.16: ABC Corporation, though relationship 14 is ABC Subsidiary's (point 23)
  (10002,  16, 'CUSTOMER'),
  (86749,  47, 'EMPLOYEE'),
  (86749,  12, 'EMPLOYER'),
  (489589, 12, 'PARTNER'),    -- three parties in one role: no party relationship could hold them
  (489589, 17, 'PARTNER'),
  (489589, 48, 'PARTNER'),
  (489589, 48, 'PARTNER'),    -- DATA ERROR: XYZ entered twice as a partner (caught by a query)
  (70001,  4,  'SUPPLIER'),
  (70001,  5,  'CUSTOMER'),
  (70001,  2,  'SIGNATORY'),  -- Ben signs for Contoso
  (70002,  3,  'EMPLOYEE'),   -- DATA ERROR: Northwind, the employer, plays no role (caught by a query)
  (70003,  17, 'DISTRIBUTOR'),
  (70003,  13, 'SUPPLIER');

-- ============================================================
-- Fig 4.13 — Agreement item
-- ============================================================
insert into agreement_item_type (agreement_item_type_id, description) values
  ('SECTION',         'Agreement section'),
  ('PRICING_PROGRAM', 'Agreement pricing program'),
  ('EXHIBIT',         'Agreement exhibit'),
  ('SUB_AGREEMENT',   'Sub-agreement');

-- 10002's two items are Table 4.17's (shared with Fig 4.14): the paper, priced
-- in Fig 4.15, and the diskettes, which only get a term. The rest are ours:
-- Contoso's 70001 gets a full outline (sections, three pricing programs under
-- "Pricing", an exhibit, a sub-agreement with a section of its own).
insert into agreement_item (agreement_item_id, agreement_id, agreement_item_seq_id, agreement_item_type_id, agreement_text, agreement_image, part_of_agreement_item_id) values
  (1,  70001,  1, 'SECTION',         'Scope: the office supplies Northwind sells Contoso in 2025', null, null),
  (2,  70001,  2, 'SECTION',         'Pricing',                                                    null, null),
  (3,  70001,  3, 'PRICING_PROGRAM', 'Bond paper at 40.00 a ream, for Contoso',                    null, 2),
  (4,  70001,  4, 'PRICING_PROGRAM', 'Copiers at 5% off list',                                     null, 2),
  (5,  70001,  5, 'PRICING_PROGRAM', 'Pens at 2.25 each, any colour, delivered in Missouri',       null, 2),
  (6,  70001,  6, 'EXHIBIT',         'Exhibit A: the 2025 price list',                             'exhibits/70001-a.pdf', null),
  (7,  70001,  7, 'SUB_AGREEMENT',   'Consignment stock at Contoso''s St. Louis depot',            null, null),
  (8,  70001,  8, 'SECTION',         'Stock is counted on the first working day of each month',    null, 7),
  (9,  10002,  1, 'PRICING_PROGRAM', 'Johnson fine grade 8½ by 11 blue bond paper',                null, null),   -- Table 4.17
  (10, 10002,  2, 'SECTION',         'Jerry''s box of 3½-inch diskettes',                           null, null),
  (11, 86749,  1, 'SECTION',         'Position: entry-level information systems programmer',       null, null),
  (12, 86749,  2, 'SECTION',         'Salary reviewed every year',                                 null, 9),      -- DATA ERROR: inside 10002's paper item (caught by a query)
  (13, 489589, 1, 'SECTION',         'Profits shared equally among the three partners',            null, null);

select setval(pg_get_serial_sequence('agreement_item', 'agreement_item_id'), (select max(agreement_item_id) from agreement_item));

-- Parties: 5 Contoso, 16 ACME. Products: 1 bond paper, 2 the pen, 3 the
-- diskettes, 6 the copier. Boundaries: 11 Missouri, 17 St. Louis.
insert into agreement_organization_applicability (agreement_item_id, party_id) values
  (3,  5),
  (7,  5),
  (9,  16);

insert into agreement_product_applicability (agreement_item_id, product_id) values
  (3,  1),
  (4,  6),
  (5,  2),
  (9,  1),    -- Table 4.17's products
  (10, 3);

insert into agreement_geographical_applicability (agreement_item_id, geographic_boundary_id) values
  (5, 11),   -- the pens: Missouri deliveries only, so the line shipped to Chatham, Illinois, misses it
  (7, 17);

insert into addendum (addendum_id, agreement_id, agreement_item_id, addendum_creation_date, addendum_effective_date, addendum_text) values
  (1, null,   3,    '2025-02-14', '2025-03-01', 'Paper lowered to 38.00 a ream from March'),
  (2, 70001,  null, '2025-05-20', '2025-06-01', 'Pricing extended to Contoso''s new Springfield office'),
  (3, 70001,  5,    '2025-04-01', '2025-04-01', 'Red pens no longer included'),     -- DATA ERROR: the agreement AND an item (caught by a query)
  (4, 489589, null, '2001-08-20', '2001-09-01', 'XYZ''s share raised to 40%');      -- DATA ERROR: effective after the partnership ended (caught by a query)

select setval(pg_get_serial_sequence('addendum', 'addendum_id'), (select max(addendum_id) from addendum));

-- ============================================================
-- Fig 4.14 — Agreement terms
-- ============================================================
-- AGREEMENT TERM's five subtypes become term_type's top rows, and every term
-- type so far is filed under one (the filing of 4.7's and 4.11's is ours).
insert into term_type (term_type_id, parent_type_id, description) values
  ('LEGAL_TERM',           null, 'Legal term'),
  ('FINANCIAL_TERM',       null, 'Financial term'),
  ('INCENTIVE',            null, 'Incentive'),
  ('THRESHOLD',            null, 'Threshold'),
  ('OTHER_AGREEMENT_TERM', null, 'Other term');

update term_type set parent_type_id = 'FINANCIAL_TERM'
 where term_type_id in ('CANCELLATION_CHARGE_PCT', 'NONPERFORMANCE_PENALTY_PCT', 'PAYMENT_DUE_DAYS');
update term_type set parent_type_id = 'LEGAL_TERM'
 where term_type_id in ('PENALTY_FREE_CANCEL_DAYS', 'NO_EXCHANGE_OR_REFUND', 'WARRANTY_MONTHS');
update term_type set parent_type_id = 'OTHER_AGREEMENT_TERM'
 where term_type_id in ('DELIVERY_WITHIN_DAYS', 'CENTRAL_CONTACT_REQUIRED');

-- Table 4.18's types, then ours. Ids name the unit, as in 4.7.
insert into term_type (term_type_id, parent_type_id, description) values
  ('NO_COMPETE_AFTER_END_DAYS', 'LEGAL_TERM',     'Days after the contract ends during which the supplier may not serve the customer''s competitors'),
  ('QUANTITY_NOT_TO_EXCEED',    'THRESHOLD',      'Quantity not to exceed'),
  ('DOLLARS_NOT_TO_EXCEED',     'THRESHOLD',      'Dollars not to exceed'),
  ('EXCLUSIVE_SUPPLIER',        'LEGAL_TERM',     'The customer buys only from this supplier'),
  ('YEAR_END_REBATE_PCT',       'INCENTIVE',      'Percentage rebated on the year''s purchases'),          -- ours
  ('TERMINATION_NOTICE_DAYS',   'LEGAL_TERM',     'Days of notice a party gives to leave the agreement');  -- ours

-- Table 4.18's 23884 isn't in Table 4.16: ours, ABC Corporation buying PC
-- repair from Ridgeway PC Repair after its Fig 4.11 proposal (35678).
-- Parties: 12 ABC Corporation, 45 Ridgeway PC Repair.
insert into agreement (agreement_id, agreement_type_id, party_relationship_id, agreement_date, from_date, thru_date, description, text) values
  (23884, 'PURCHASE_AGREEMENT', null, '2002-02-25', '2002-03-01', '2003-03-01', 'PC repair for ABC Corporation''s offices', null);

insert into agreement_role (agreement_id, party_id, agreement_role_type_id) values
  (23884, 45, 'SUPPLIER'),
  (23884, 12, 'CUSTOMER');

-- Items: 5 70001's pens program, 9 10002's paper, 10 10002's diskettes.
-- Thru dates are exclusive: Table 4.18's "December 31, 2002" is stored as
-- January 1, 2003.
insert into agreement_term (agreement_term_id, term_type_id, agreement_id, agreement_item_id, term_value, from_date, thru_date) values
  (1, 'NO_COMPETE_AFTER_END_DAYS', 23884,  null, 60,    '2002-03-01', null),           -- Table 4.18 gives no dates: the agreement's start
  (2, 'QUANTITY_NOT_TO_EXCEED',    null,   9,    1000,  '2002-01-01', '2003-01-01'),   -- Table 4.18, as printed: a day past 10002's end (caught by a query; point 31)
  (3, 'DOLLARS_NOT_TO_EXCEED',     null,   9,    10000, '2002-01-01', '2002-07-01'),
  (4, 'EXCLUSIVE_SUPPLIER',        null,   10,   null,  '2002-01-01', '2002-12-31'),
  (5, 'PAYMENT_DUE_DAYS',          70001,  null, 30,    '2025-01-01', null),
  (6, 'YEAR_END_REBATE_PCT',       70001,  null, 2,     '2025-01-01', null),
  (7, 'TERMINATION_NOTICE_DAYS',   489589, null, 30,    '2000-06-01', '2002-06-02'),   -- DATA ERROR: outlives the partnership by a year (caught by a query)
  (8, 'DELIVERY_WITHIN_DAYS',      70001,  5,    2,     '2025-01-01', null);           -- DATA ERROR: the agreement AND an item (caught by a query)

select setval(pg_get_serial_sequence('agreement_term', 'agreement_term_id'), (select max(agreement_term_id) from agreement_term));

-- ============================================================
-- Fig 4.15 — Agreement pricing
-- ============================================================
-- Table 4.19's regions, new boundaries in the US, read as split by the
-- Mississippi: Illinois east, Missouri west, so ACME's St. Louis addresses
-- get the western price (NOTES, point 36).
insert into geographic_boundary (geographic_boundary_id, geographic_boundary_type_id, geo_code, name, abbreviation) values
  (40, 'REGION', null, 'Eastern region', null),
  (41, 'REGION', null, 'Western region', null);

select setval(pg_get_serial_sequence('geographic_boundary', 'geographic_boundary_id'), (select max(geographic_boundary_id) from geographic_boundary));

insert into geographic_boundary_association (from_geographic_boundary_id, to_geographic_boundary_id) values
  (40, 6), (41, 6),     -- both regions within the US
  (10, 40), (11, 41);   -- Illinois in the east, Missouri in the west

-- Items: 3, 4, 5 70001's paper, copier and pens programs; 6 its exhibit;
-- 9 10002's paper.
insert into agreement_pricing_program (agreement_item_id) values
  (3), (4), (5), (9),
  (6);   -- DATA ERROR: 70001's exhibit (the price list) entered as a pricing program (caught by a query)

-- Table 4.19 on 10002's paper, with the agreement's dates (thru exclusive),
-- USD, and ABC Corporation (12) as pricer; quantity break 3 is Ch 3's 1000+.
-- Ours: 70001's pens, delivered in Missouri (11). 70001's paper and copier
-- programs stay unpriced (NOTES, Fig 4.15's design decisions).
insert into price_component (price_component_id, price_component_type_id, charge_kind, from_date, thru_date, price, percent, currency_uom_id,
                             product_id, product_feature_id, pricer_party_id,
                             geographic_boundary_id, party_type_id, product_category_id, quantity_break_id, order_value_id, sale_type_id,
                             per_uom_id, quantity, comment, agreement_item_id) values
  (26, 'BASE_PRICE', null, '2002-01-01', '2002-12-31', 7.00, null, 'USD', 1, null, 12, 40,   null, null, null, null, null, null, null, 'Table 4.19: Eastern region', 9),
  (27, 'BASE_PRICE', null, '2002-01-01', '2002-12-31', 7.50, null, 'USD', 1, null, 12, 41,   null, null, null, null, null, null, null, 'Table 4.19: Western region', 9),
  (28, 'DISCOUNT',   null, '2002-01-01', '2002-12-31', null, 2,    null,  1, null, 12, null, null, null, 3,    null, null, null, null, 'Table 4.19: 2% off from 1,000 reams', 9),
  (29, 'BASE_PRICE', null, '2025-01-01', '2026-01-01', 2.25, null, 'USD', 2, null, 4,  11,   null, null, null, null, null, null, null, 'Contoso''s pens, delivered in Missouri', 5),
  (30, 'BASE_PRICE', null, '2001-01-01', '2002-01-01', 6.80, null, 'USD', 1, null, 12, 40,   null, null, null, null, null, null, null, 'DATA ERROR: last year''s price, keyed on the 2002 program (caught by a query)', 9),
  (31, 'BASE_PRICE', null, '2002-01-01', '2002-12-31', 6.50, null, 'USD', 3, null, 12, null, null, null, null, null, null, null, null, 'DATA ERROR: the diskettes priced on the paper program (caught by a query)', 9);

select setval(pg_get_serial_sequence('price_component', 'price_component_id'), (select max(price_component_id) from price_component));

-- ============================================================
-- Fig 4.16 — Relationship of agreement to order
-- ============================================================
-- No book table: ACME's 2002 orders under 10002 are ours, taken by ABC
-- Corporation (the agreement's supplier). Roles (Ch 2 and 4.3): 60 ACME
-- placing, 67 ACME bill-to, 68 ACME ship-to, 73 ABC Corporation internal.
-- Mechanisms: 32 ACME's head office, 34 2300 Drident Avenue, both in St.
-- Louis, so the western price applies.
-- The price check also catches a line seeded long before: 12562's blue pens
-- (item 9), shipped to Contoso in St. Louis at the 2.50 list price, while
-- 70001's pens program says 2.25 delivered in Missouri.
insert into "order" (order_id, order_kind, order_date, entry_date) values
  (12572, 'SALES', '2002-02-04', '2002-02-04'),
  (12573, 'SALES', '2002-04-15', '2002-04-15'),
  (12574, 'SALES', '2002-09-16', '2002-09-16');

insert into sales_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id,
                         placed_using_contact_mechanism_id, taken_via_contact_mechanism_id, bill_to_contact_mechanism_id) values
  (12572, 60, 73, 67, 32, null, 32),
  (12573, 60, 73, 67, 32, null, 32),
  (12574, 60, 73, 67, 32, null, 32);

insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, quantity, unit_price, comment) values
  (31, 12572, 1, 1, 600, 7.50, null),
  (32, 12573, 1, 1, 400, 7.00, 'DATA ERROR: the eastern price on a St. Louis delivery (caught by a query)'),
  (33, 12573, 2, 3, 50,  7.00, 'Diskettes: item 2 governs them (only from this supplier), at no agreed price'),
  (34, 12574, 1, 1, 300, 7.50, 'DATA ERROR: past 2002''s 1,000-ream cap, still at the agreed price (caught by a query)');

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

insert into sales_order_item (order_item_id, ship_to_party_role_id, ship_to_contact_mechanism_id) values
  (31, 68, 34),
  (32, 68, 32),
  (33, 68, 32),
  (34, 68, 34);
