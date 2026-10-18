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
