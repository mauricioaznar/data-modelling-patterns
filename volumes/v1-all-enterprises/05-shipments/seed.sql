-- Vol 1, Chapter 5 seed data.
-- The book's tables first in each section, then ours: edge cases and
-- deliberate mistakes (marked DATA ERROR), each caught by a query.
-- thru_date is exclusive (the first day no longer valid).

-- ============================================================
-- Fig 5.1 — Shipment definition
-- ============================================================
-- The subtypes as rows. The flags say whether each end is one of our own
-- organizations; the grouping rows have none.
insert into shipment_type (shipment_type_id, parent_type_id, from_internal, to_internal, description) values
  ('OUTGOING',          null,       null,  null,  'Outgoing shipment'),
  ('CUSTOMER_SHIPMENT', 'OUTGOING', true,  false, 'Customer shipment'),
  ('PURCHASE_RETURN',   'OUTGOING', true,  false, 'Purchase return'),
  ('INCOMING',          null,       null,  null,  'Incoming shipment'),
  ('PURCHASE_SHIPMENT', 'INCOMING', false, true,  'Purchase shipment'),
  ('CUSTOMER_RETURN',   'INCOMING', false, true,  'Customer return'),
  ('TRANSFER',          null,       true,  true,  'Transfer'),
  ('DROP_SHIPMENT',     null,       false, false, 'Drop shipment');

-- Table 5.1's supplier, new to the seed.
insert into party (party_id, party_kind) values
  (49, 'ORGANIZATION');   -- General Goods Corporation

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (49, 'CORPORATION', 'General Goods Corporation');

-- Table 5.1's three new addresses (the cities are ours), ACME's receiving
-- dock phone and ABC Subsidiary's shipping desk e-mail.
insert into contact_mechanism (contact_mechanism_id, contact_mechanism_kind, contact_mechanism_type_id) values
  (40, 'POSTAL_ADDRESS',            'POSTAL_ADDRESS'),
  (41, 'POSTAL_ADDRESS',            'POSTAL_ADDRESS'),
  (42, 'POSTAL_ADDRESS',            'POSTAL_ADDRESS'),
  (43, 'TELECOMMUNICATIONS_NUMBER', 'PHONE'),
  (44, 'ELECTRONIC_ADDRESS',        'EMAIL');

select setval(pg_get_serial_sequence('contact_mechanism', 'contact_mechanism_id'), (select max(contact_mechanism_id) from contact_mechanism));

insert into postal_address (contact_mechanism_id, address1, address2, directions) values
  (40, '300 Main Street',     null, 'Loading dock behind the building'),
  (41, '300 Jennifer Street', null, null),
  (42, '400 Benny Street',    null, null);

insert into postal_address_boundary (contact_mechanism_id, geographic_boundary_id) values
  (40, 13), (40, 12), (40, 10), (40, 6),   -- Springfield, Sangamon County, IL, US (beside 100 Main Street)
  (41, 14), (41, 12), (41, 10), (41, 6),   -- Chatham IL, US
  (42, 17), (42, 11), (42, 6);             -- St. Louis MO, US

insert into telecommunications_number (contact_mechanism_id, country_code, area_code, contact_number) values
  (43, '1', '314', '555-0150');

insert into electronic_address (contact_mechanism_id, electronic_address_string) values
  (44, 'shipping@abc-subsidiary.example');

-- Parties: 13 ABC Subsidiary, 16 ACME, 17 Sellers Assistance, 49 General Goods.
insert into party_contact_mechanism (party_contact_mechanism_id, party_id, contact_mechanism_id, from_date, thru_date, non_solicitation_ind, role_type_id, comment) values
  (41, 13, 40, '1999-01-01', null, false, 'INTERNAL_ORGANIZATION', 'Warehouse and shipping'),
  (42, 49, 41, '2000-01-01', null, false, null,                    null),
  (43, 17, 42, '1999-06-01', null, false, null,                    null),
  (44, 16, 43, '1999-01-01', null, false, null,                    'Receiving dock'),
  (45, 13, 44, '1999-01-01', null, false, null,                    'Shipping desk');

select setval(pg_get_serial_sequence('party_contact_mechanism', 'party_contact_mechanism_id'), (select max(party_contact_mechanism_id) from party_contact_mechanism));

-- Table 5.1, with its ids, then ours from 9600. Ready dates, costs and
-- handling instructions are ours. Parties: 12 ABC Corporation, 13 ABC
-- Subsidiary, 16 ACME, 17 Sellers Assistance, 49 General Goods. Addresses:
-- 32 234 Stretch Street (ACME's head office), 33 100 Main Street (ABC
-- Corporation), 34 2300 Drident Avenue (ACME's deliveries), 40 300 Main
-- Street (ABC Subsidiary), 41 300 Jennifer Street, 42 400 Benny Street.
-- Mechanisms: 43 ACME's receiving phone, 44 ABC Subsidiary's shipping desk.
insert into shipment (shipment_id, shipment_type_id, estimated_ship_date, estimated_arrival_date, estimated_ready_date,
                      estimated_ship_cost, actual_ship_cost, latest_cancel_date, handling_instructions, last_updated,
                      shipped_from_party_id, shipped_from_contact_mechanism_id, shipped_to_party_id, shipped_to_contact_mechanism_id,
                      inquiry_contact_mechanism_id, receiving_contact_mechanism_id) values
  (9000, 'CUSTOMER_SHIPMENT', '2001-03-06', '2001-03-08', '2001-03-05', 120.00, 115.00, '2001-03-05', 'Keep dry', '2001-03-07 17:00+00', 13, 40, 16, 32, 44,   43),
  (9200, 'CUSTOMER_SHIPMENT', '2001-03-12', '2001-03-14', null,         80.00,  null,   null,         null,       null,                  13, 40, 16, 32, 44,   43),
  (9400, 'CUSTOMER_SHIPMENT', '2001-03-22', '2001-03-25', null,         60.00,  null,   null,         null,       null,                  13, 40, 16, 32, 44,   null),
  (1146, 'PURCHASE_SHIPMENT', '2001-03-19', '2001-03-20', null,         null,   null,   null,         null,       null,                  49, 41, 12, 33, null, null),
  (1149, 'PURCHASE_SHIPMENT', '2001-03-25', '2001-03-31', null,         null,   null,   null,         null,       null,                  49, 41, 12, 33, null, null),
  (1578, 'PURCHASE_RETURN',   '2001-04-09', '2001-04-12', null,         35.00,  null,   null,         null,       null,                  12, 33, 49, 41, null, null),
  (3485, 'TRANSFER',          '2001-06-23', '2001-06-25', null,         null,   null,   null,         null,       null,                  12, 33, 13, 40, null, null),
  (4800, 'DROP_SHIPMENT',     '2001-07-12', '2001-07-13', null,         null,   null,   '2001-07-10', null,       null,                  16, 32, 17, 42, null, null),   -- ACME ships for us, straight to Sellers Assistance
  (9600, 'CUSTOMER_RETURN',   '2001-03-16', '2001-03-19', null,         null,   null,   null,         null,       null,                  16, 32, 13, 40, 44,   null),   -- ours: ACME sends back some of 9000's pens (5.2)
  (9700, 'OUTGOING',          '2001-04-02', '2001-04-04', null,         null,   null,   null,         null,       null,                  13, 40, 16, 32, null, null),   -- DATA ERROR: a grouping row, not a type of shipment (caught by a query)
  (9800, 'TRANSFER',          '2001-04-16', '2001-04-18', null,         null,   null,   null,         null,       null,                  12, 33, 16, 32, null, null),   -- DATA ERROR: a "transfer" to ACME, an outside party (caught by a query)
  (9900, 'CUSTOMER_SHIPMENT', '2001-04-20', '2001-04-23', null,         null,   null,   null,         null,       null,                  13, 40, 16, 41, null, null),   -- DATA ERROR: ACME at General Goods's address (caught by a query)
  (9950, 'CUSTOMER_SHIPMENT', '2001-05-10', '2001-05-08', null,         null,   null,   null,         null,       null,                  13, 40, 16, 34, null, null);   -- DATA ERROR: due to arrive two days before it ships (caught by a query)

select setval(pg_get_serial_sequence('shipment', 'shipment_id'), (select max(shipment_id) from shipment));

-- ============================================================
-- Fig 5.2 — Shipping detail
-- ============================================================
-- New to Ch 3's catalogue: Table 5.2's pencils and Table 5.4's erasers, sold
-- each. Ch 4's "Yellow #2 pencils, box of 12" is another product.
insert into product (product_id, product_kind, name, introduction_date, uom_id) values
  (20, 'GOOD', 'Jones #2 pencil', '1995-01-01', 'EA'),
  (21, 'GOOD', 'Standard eraser', '1995-01-01', 'EA');

select setval(pg_get_serial_sequence('product', 'product_id'), (select max(product_id) from product));

insert into good (product_id, good_kind) values
  (20, 'FINISHED_GOOD'),
  (21, 'FINISHED_GOOD');

-- Categories (Ch 3): 4 Writing instruments, 1 Office supplies.
insert into product_category_classification (product_id, product_category_id, from_date, thru_date, primary_flag, comment) values
  (20, 4, '1995-01-01', null, true, null),
  (21, 1, '1995-01-01', null, true, null);

-- Table 5.2 (9000), Table 5.5 (9200, 9400; shared with Fig 5.3) and Table
-- 5.8 (1146, 1149, 3485; shared with Fig 5.4, which replaced our own lines:
-- NOTES, points 18-19), then ours. Ids 21-24 are 9500's (Fig 5.3). Goods: 2
-- the Goldstein Elite pen, 3 the box of 3½-inch (HD) diskettes, 20 the Jones
-- #2 pencil, 21 the standard eraser.
insert into shipment_item (shipment_item_id, shipment_id, shipment_item_seq_id, product_id, quantity,
                           shipment_contents_description, in_response_to_shipment_item_id) values
  (1,  9000, 1, 20,   1000, null, null),
  (2,  9000, 2, 2,    1000, null, null),
  (3,  9000, 3, 3,    100,  null, null),
  (4,  9200, 1, 21,   350,  null, null),
  (5,  9200, 2, 3,    100,  null, null),
  (6,  9200, 3, 20,   1500, null, null),   -- Table 5.5 as read; no order line in Table 5.6 claims it (NOTES, point 13)
  (7,  9400, 1, 20,   500,  null, null),
  (8,  1146, 1, 20,   2000, null, null),   -- Table 5.8
  (17, 1146, 2, 2,    1000, null, null),
  (18, 1146, 3, 3,    1000, null, null),   -- one package of 100 shown (NOTES, point 21)
  (9,  1149, 1, 21,   200,  null, null),
  (10, 1149, 2, 3,    200,  null, null),
  (19, 1149, 3, 20,   100,  null, null),
  (13, 3485, 1, 20,   500,  null, null),   -- Table 5.8's "4800 (transfer)" (NOTES, point 18)
  (20, 1149, 3, 2,    50,   null, null),   -- ours from here. DATA ERROR: a second line 3 on the shipment (caught by a query)
  (11, 1578, 1, 20,   100,  null, 8),      -- water-damaged pencils sent back from 1146
  (12, 1578, 2, null, 5,    null, null),   -- DATA ERROR: no good and no description (caught by a query)
  (14, 4800, 1, null, 12,   'Promotional display stands', null),   -- not a catalogue good
  (15, 9600, 1, 2,    50,   null, 2),      -- ACME returns 50 of 9000's pens (the wrong colour: Fig 5.3)
  (16, 9600, 2, 2,    10,   null, 15);     -- DATA ERROR: answers a line of its own shipment (caught by a query)

select setval(pg_get_serial_sequence('shipment_item', 'shipment_item_id'), (select max(shipment_item_id) from shipment_item));

-- Shipment statuses, a new group in Ch 2's shared status_type.
insert into status_type (status_type_id, parent_type_id, description) values
  ('SHIPMENT_STATUS',    null,              'Shipment status'),
  ('SHIPMENT_SCHEDULED', 'SHIPMENT_STATUS', 'Scheduled'),
  ('SHIPMENT_SHIPPED',   'SHIPMENT_STATUS', 'Shipped'),
  ('SHIPMENT_IN_ROUTE',  'SHIPMENT_STATUS', 'In route'),
  ('SHIPMENT_DELIVERED', 'SHIPMENT_STATUS', 'Delivered'),
  ('SHIPMENT_RECEIVED',  'SHIPMENT_STATUS', 'Received'),
  ('SHIPMENT_CANCELLED', 'SHIPMENT_STATUS', 'Cancelled');

-- Table 5.3 (4800 read as 2001: NOTES, point 8), then ours. The times are ours.
insert into shipment_status (shipment_status_id, shipment_id, status_type_id, status_datetime) values
  (1,  9000, 'SHIPMENT_SCHEDULED', '2001-03-04 09:00+00'),
  (2,  9000, 'SHIPMENT_SHIPPED',   '2001-03-07 10:00+00'),   -- a day after the estimate (time: Table 5.11's first truck)
  (3,  9000, 'SHIPMENT_RECEIVED',  '2001-03-07 20:30+00'),   -- a day before the estimate (after Table 5.11's second truck)
  (4,  4800, 'SHIPMENT_SCHEDULED', '2001-07-09 10:00+00'),
  (5,  4800, 'SHIPMENT_CANCELLED', '2001-07-10 11:00+00'),   -- on its latest cancel date
  (6,  9200, 'SHIPMENT_SCHEDULED', '2001-03-09 09:00+00'),
  (7,  9200, 'SHIPMENT_SHIPPED',   '2001-03-12 13:00+00'),   -- Table 5.10's leg starts at 1 p.m.
  (8,  9200, 'SHIPMENT_IN_ROUTE',  '2001-03-13 07:00+00'),
  (9,  9200, 'SHIPMENT_DELIVERED', '2001-03-14 10:00+00'),   -- the carrier hands it over ...
  (10, 9200, 'SHIPMENT_RECEIVED',  '2001-03-14 11:30+00'),   --   ... and ACME takes it in
  (11, 9200, 'SHIPMENT_SHIPPED',   '2001-03-12 15:00+00'),   -- DATA ERROR: shipped twice, keyed again that afternoon (caught by a query)
  (12, 9400, 'SHIPMENT_SCHEDULED', '2001-03-20 09:00+00'),
  (13, 9400, 'SHIPMENT_SHIPPED',   '2001-03-23 08:00+00'),   -- a day late ...
  (14, 9400, 'SHIPMENT_RECEIVED',  '2001-03-26 14:00+00'),   --   ... and still a day late
  (15, 1146, 'SHIPMENT_SCHEDULED', '2001-03-15 09:00+00'),
  (16, 1146, 'SHIPMENT_SHIPPED',   '2001-03-19 16:00+00'),   -- Table 5.10's flight leaves at 4 p.m.
  (17, 1146, 'SHIPMENT_RECEIVED',  '2001-03-18 15:00+00'),   -- DATA ERROR: received the day before it shipped (caught by a query)
  (18, 1149, 'SHIPMENT_SCHEDULED', '2001-03-20 09:00+00'),
  (19, 1149, 'ORDER_SHIPPED',      '2001-03-25 08:00+00'),   -- DATA ERROR: an order status on a shipment (caught by a query)
  (20, 1578, 'SHIPMENT_SCHEDULED', '2001-04-05 09:00+00'),
  (21, 1578, 'SHIPMENT_SHIPPED',   '2001-04-09 08:00+00'),
  (22, 3485, 'SHIPMENT_SCHEDULED', '2001-06-20 09:00+00'),
  (23, 3485, 'SHIPMENT_SHIPPED',   '2001-06-23 08:00+00'),
  (24, 3485, 'SHIPMENT_RECEIVED',  '2001-06-25 10:00+00'),
  (25, 9600, 'SHIPMENT_SCHEDULED', '2001-03-15 09:00+00'),
  (26, 9600, 'SHIPMENT_SHIPPED',   '2001-03-16 08:00+00'),
  (27, 9600, 'SHIPMENT_RECEIVED',  '2001-03-19 10:00+00');

select setval(pg_get_serial_sequence('shipment_status', 'shipment_status_id'), (select max(shipment_status_id) from shipment_status));

-- ============================================================
-- Fig 5.3 — Shipment-to-order relationship
-- ============================================================
-- New Ch 2 roles for purchase order 300 (Ch 4's buyer-side roles).
insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (75, 12, 'SHIP_TO_BUYER', '1998-03-04', null),   -- ABC Corporation receives what ABC buys
  (76, 49, 'SUPPLIER',      '2000-01-01', null);   -- General Goods

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

-- Table 5.4's orders 100 and 200 (dates ours), our purchase order 300 behind
-- shipments 1146 and 1149, and our sales order 400, which carries mistakes.
-- Roles: 60 ACME placing, 67 ACME bill-to, 68 ACME ship-to, 32 ABC
-- Subsidiary internal, 69 ABC Subsidiary placing buyer, 70 ABC Corporation
-- bill-to purchaser, 75 its ship-to buyer role, 76 General Goods supplier.
-- Mechanisms: 32 234 Stretch Street, 33 100 Main Street, 34 2300 Drident
-- Avenue, 41 300 Jennifer Street.
insert into "order" (order_id, order_kind, order_date, entry_date) values
  (100, 'SALES',    '2001-03-01', '2001-03-01'),
  (200, 'SALES',    '2001-03-05', '2001-03-05'),
  (300, 'PURCHASE', '2001-03-10', '2001-03-10'),
  (400, 'SALES',    '2001-03-20', '2001-03-20');

insert into sales_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id,
                         placed_using_contact_mechanism_id, taken_via_contact_mechanism_id, bill_to_contact_mechanism_id) values
  (100, 60, 32, 67, 32, 33, 32),
  (200, 60, 32, 67, 32, 33, 32),
  (400, 60, 32, 67, 32, 33, 32);

insert into purchase_order (order_id, placed_by_party_role_id, taken_by_party_role_id, bill_to_party_role_id,
                            placed_using_contact_mechanism_id, taken_via_contact_mechanism_id, bill_to_contact_mechanism_id) values
  (300, 69, 76, 70, 33, 41, 33);

-- Table 5.4's lines, the prices ours. Each pen line gets a blue feature line
-- under it, for Table 5.7 (NOTES, point 14). Goods: 2 pen, 3 diskettes, 20
-- pencil, 21 eraser; feature 3 blue.
insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, product_feature_id, ordered_for_order_item_id,
                        quantity, unit_price, comment) values
  (35, 100, 1, 20,   null, null, 1500, 0.25,  null),
  (36, 100, 2, 2,    null, null, 2500, 12.00, null),
  (37, 100, 3, 21,   null, null, 350,  0.40,  null),
  (38, 100, 4, null, 3,    36,   2500, 0.00,  'Blue: Table 5.7'),
  (39, 200, 1, 2,    null, null, 300,  12.00, null),
  (40, 200, 2, 3,    null, null, 200,  7.00,  null),
  (41, 200, 3, null, 3,    39,   300,  0.00,  'Blue: Table 5.7'),
  (42, 300, 1, 20,   null, null, 2100, 0.10,  'On 1146 and 1149 (Table 5.8)'),
  (43, 300, 2, 21,   null, null, 200,  0.20,  null),
  (47, 300, 3, 2,    null, null, 1000, 1.20,  null),
  (48, 300, 4, 3,    null, null, 1200, 4.00,  'On 1146 and 1149 (Table 5.8)'),
  (44, 400, 1, 21,   null, null, 200,  0.40,  null),
  (45, 400, 2, 20,   null, null, 100,  0.25,  'For ACME''s delivery address, not its head office'),
  (46, 400, 3, 3,    null, null, 50,   7.00,  null);

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

-- Everything to ACME's head office, except order 400's pencils. A feature
-- line ships with its product line (no row of its own).
insert into sales_order_item (order_item_id, ship_to_party_role_id, ship_to_contact_mechanism_id) values
  (35, 68, 32), (36, 68, 32), (37, 68, 32), (38, null, null),
  (39, 68, 32), (40, 68, 32), (41, null, null),
  (44, 68, 32), (45, 68, 34), (46, 68, 32);

insert into purchase_order_item (order_item_id, ship_to_party_role_id, ship_to_contact_mechanism_id) values
  (42, 75, 33),
  (43, 75, 33),
  (47, 75, 33),
  (48, 75, 33);

-- Ours: customer shipment 9500 to ACME, the one carrying the mistakes below.
insert into shipment (shipment_id, shipment_type_id, estimated_ship_date, estimated_arrival_date,
                      shipped_from_party_id, shipped_from_contact_mechanism_id, shipped_to_party_id, shipped_to_contact_mechanism_id,
                      inquiry_contact_mechanism_id) values
  (9500, 'CUSTOMER_SHIPMENT', '2001-03-28', '2001-03-30', 13, 40, 16, 32, 44);

insert into shipment_item (shipment_item_id, shipment_id, shipment_item_seq_id, product_id, quantity) values
  (21, 9500, 1, 21, 150),
  (22, 9500, 2, 20, 100),
  (23, 9500, 3, 20, 50),
  (24, 9500, 4, 21, 60);

select setval(pg_get_serial_sequence('shipment_item', 'shipment_item_id'), (select max(shipment_item_id) from shipment_item));

insert into shipment_status (shipment_status_id, shipment_id, status_type_id, status_datetime) values
  (28, 9500, 'SHIPMENT_SCHEDULED', '2001-03-26 09:00+00'),
  (29, 9500, 'SHIPMENT_SHIPPED',   '2001-03-28 08:00+00');

select setval(pg_get_serial_sequence('shipment_status', 'shipment_status_id'), (select max(shipment_status_id) from shipment_status));

-- Table 5.6, then ours. Order lines: 35-37 order 100, 39-40 order 200, 42-43
-- and 47-48 purchase order 300, 44-46 order 400. Shipment lines: 1-3 on
-- 9000, 4-6 on 9200, 7 on 9400, 8, 17-18 on 1146, 9-10 and 19 on 1149, 21-24
-- on 9500.
insert into order_shipment (order_shipment_id, order_item_id, shipment_item_id, quantity) values
  (1,  35, 1,  1000),   -- order 100's pencils, part one ...
  (2,  35, 7,  500),    --   ... and the rest, on 9400
  (3,  36, 2,  700),    -- 9000's pen line fills order 100 ...
  (4,  37, 4,  350),
  (5,  39, 2,  300),    --   ... and order 200 at once
  (6,  40, 3,  100),
  (7,  40, 5,  100),
  (8,  42, 8,  2000),   -- ours from here: purchase order 300 on Table 5.8's 1146 and 1149
  (9,  42, 19, 100),
  (10, 43, 9,  200),
  (15, 47, 17, 1000),
  (16, 48, 18, 1000),
  (17, 48, 10, 200),
  (11, 44, 21, 200),    -- DATA ERROR: 200 drawn on a line of 150 erasers (caught by a query)
  (12, 45, 22, 100),    -- DATA ERROR: the line ships to 2300 Drident Avenue, 9500 goes to 234 Stretch Street (caught by a query)
  (13, 46, 23, 50),     -- DATA ERROR: diskettes filled by a line of pencils (caught by a query)
  (14, 43, 24, 60);     -- DATA ERROR: a purchase line filled by a customer shipment (caught by two queries: direction and destination)

select setval(pg_get_serial_sequence('order_shipment', 'order_shipment_id'), (select max(order_shipment_id) from order_shipment));

-- Table 5.7: 9000's pen line went out black (feature 4). Then a mistake.
insert into shipment_item_feature (shipment_item_feature_id, shipment_item_id, product_feature_id) values
  (1, 2, 4),
  (2, 2, 4);   -- DATA ERROR: the same feature twice on the line (caught by a query)

select setval(pg_get_serial_sequence('shipment_item_feature', 'shipment_item_feature_id'), (select max(shipment_item_feature_id) from shipment_item_feature));

-- ============================================================
-- Fig 5.4 — Shipment receipt for incoming shipments
-- ============================================================
-- Where received goods go: a warehouse at each of ABC's addresses (Ch 2's
-- facilities; 33 100 Main Street, 40 300 Main Street).
insert into facility (facility_id, facility_type_id, part_of_facility_id, description, square_footage) values
  (11, 'WAREHOUSE', null, 'ABC Corporation warehouse, 100 Main Street', 30000),
  (12, 'WAREHOUSE', null, 'ABC Subsidiary warehouse, 300 Main Street',  12000);

select setval(pg_get_serial_sequence('facility', 'facility_id'), (select max(facility_id) from facility));

insert into facility_contact_mechanism (facility_id, contact_mechanism_id, from_date, thru_date) values
  (11, 33, '1998-03-04', null),
  (12, 40, '1999-01-01', null);

-- The stock the receipts store into (Ch 3). Quantity on hand = what the
-- receipts accepted; nothing is issued yet (the next figure's job).
insert into inventory_item (inventory_item_id, inventory_item_kind, product_id, inventory_item_status_type_id, lot_id, facility_id, container_id, serial_num, quantity_on_hand) values
  (10, 'NON_SERIALIZED', 20, 'GOOD', null, 11, null, null, 2100),   -- pencils at ABC Corporation
  (11, 'NON_SERIALIZED', 2,  'GOOD', null, 11, null, null, 1000),   -- pens
  (12, 'NON_SERIALIZED', 3,  'GOOD', null, 11, null, null, 1200),   -- diskettes
  (13, 'NON_SERIALIZED', 21, 'GOOD', null, 11, null, null, 200),    -- erasers
  (14, 'NON_SERIALIZED', 20, 'GOOD', null, 12, null, null, 300),    -- pencils at ABC Subsidiary, from the transfer
  (15, 'NON_SERIALIZED', 2,  'GOOD', null, 12, null, null, 40);     -- ACME's returned pens

select setval(pg_get_serial_sequence('inventory_item', 'inventory_item_id'), (select max(inventory_item_id) from inventory_item));

-- Table 5.8's packages, then ours (52005 and the 59xxx and 51578 ones). The
-- dates are ours: the day each was packed.
insert into shipment_package (shipment_package_id, date_created) values
  (52000, '2001-03-19'),
  (52001, '2001-03-19'),
  (52002, '2001-03-19'),
  (52003, '2001-03-19'),
  (52005, '2001-03-19'),   -- ours: the rest of 1146's diskettes (NOTES, point 21)
  (53100, '2001-03-25'),
  (52004, '2001-06-23'),   -- Table 5.8's "4800 (transfer)", read as 3485 (point 18)
  (59600, '2001-03-16'),   -- ACME's returned pens
  (51578, '2001-04-09'),   -- our return to General Goods
  (59500, '2001-03-28');

select setval(pg_get_serial_sequence('shipment_package', 'shipment_package_id'), (select max(shipment_package_id) from shipment_package));

-- Shipment lines: 8, 17, 18 on 1146; 9, 10, 19 on 1149; 13 on 3485; 15 on
-- 9600; 11 on 1578; 22, 23 on 9500; 7 on 9400.
insert into packaging_content (packaging_content_id, shipment_package_id, shipment_item_id, quantity) values
  (1,  52000, 8,  1000),   -- Table 5.8: 1146's pencils in two cartons
  (2,  52001, 8,  1000),
  (3,  52002, 17, 1000),
  (4,  52003, 18, 100),
  (5,  52005, 18, 900),    -- ours
  (6,  53100, 9,  200),    -- 1149's three lines in one package
  (7,  53100, 10, 200),
  (8,  53100, 19, 100),
  (9,  52004, 13, 500),
  (10, 59600, 15, 50),     -- ours from here
  (11, 51578, 11, 100),
  (12, 59500, 22, 100),
  (13, 59500, 23, 60),     -- DATA ERROR: 60 packed for a line of 50 (caught by a query)
  (14, 52002, 7,  10);     -- DATA ERROR: ten of 9400's pencils in 1146's carton of pens (caught by a query)

select setval(pg_get_serial_sequence('packaging_content', 'packaging_content_id'), (select max(packaging_content_id) from packaging_content));

insert into rejection_reason (rejection_reason_id, description) values
  ('DAMAGED',       'Damaged in transit'),
  ('WRONG_PRODUCT', 'Not the product ordered'),
  ('NOT_ORDERED',   'More than was ordered'),
  ('POOR_QUALITY',  'Below the agreed quality');

-- Table 5.8's receipts (the pens' 12901 read as 12902: point 20), then ours.
-- Order lines (purchase order 300): 42 pencils, 43 erasers, 47 pens, 48
-- diskettes; 40 is ACME's diskettes on sales order 200. Inventory items
-- 10-15 above. Times and descriptions are ours.
insert into shipment_receipt (shipment_receipt_id, shipment_package_id, product_id, inventory_item_id, order_item_id, rejection_reason_id,
                              datetime_received, item_description, quantity_accepted, quantity_rejected) values
  (12900, 52000, 20, 10,   42,   null,      '2001-03-20 10:00+00', 'Jones #2 pencils, carton of 1,000',           1000, 0),
  (12901, 52001, 20, 10,   42,   null,      '2001-03-20 10:20+00', 'Jones #2 pencils, carton of 1,000',           1000, 0),
  (12902, 52002, 2,  11,   47,   null,      '2001-03-20 10:40+00', 'Goldstein Elite pens, carton of 1,000',       1000, 0),
  (13902, 52003, 3,  12,   48,   null,      '2001-03-20 11:00+00', 'HD diskettes, 100 boxes',                     100,  0),
  (13903, 53100, 21, 13,   43,   null,      '2001-03-31 09:00+00', 'Standard erasers',                            200,  0),
  (13904, 53100, 3,  12,   48,   null,      '2001-03-31 09:10+00', 'HD diskettes, 200 boxes',                     200,  0),
  (13905, 53100, 20, 10,   42,   null,      '2001-03-31 09:20+00', 'Jones #2 pencils',                            100,  0),
  (13804, 52004, 20, 14,   null, 'DAMAGED', '2001-06-25 10:00+00', 'Jones #2 pencils from ABC Corporation',       300,  200),   -- no order behind a transfer
  (19600, 59600, 2,  15,   null, 'DAMAGED', '2001-03-19 10:00+00', 'Goldstein Elite pens returned by ACME, black', 40,   5),     -- ours from here
  (19601, 59600, 2,  null, null, null,      '2001-03-19 10:30+00', 'Goldstein Elite pens returned by ACME',       0,    5),     -- DATA ERROR: five rejected with no reason (caught by a query)
  (12950, 52001, 20, 10,   42,   null,      '2001-03-20 12:00+00', 'Jones #2 pencils',                            50,   0),     -- DATA ERROR: 1,050 counted out of a carton of 1,000 (caught by a query)
  (13906, 53100, 2,  null, null, null,      '2001-03-31 09:30+00', 'Pens found in the mixed package',             10,   0),     -- DATA ERROR: 53100 holds no pens (caught by a query)
  (12960, 52005, 3,  12,   40,   null,      '2001-03-22 09:00+00', 'HD diskettes, 900 boxes',                     900,  0),     -- DATA ERROR: checked against ACME's sales line, which 1146 doesn't fill (caught by a query)
  (15780, 51578, 20, null, null, null,      '2001-04-12 15:00+00', 'Jones #2 pencils',                            100,  0);     -- DATA ERROR: a receipt for our own return to General Goods (caught by a query)

select setval(pg_get_serial_sequence('shipment_receipt', 'shipment_receipt_id'), (select max(shipment_receipt_id) from shipment_receipt));

insert into shipment_receipt_role_type (shipment_receipt_role_type_id, description) values
  ('RECEIVER',  'Signed for the goods'),
  ('INSPECTOR', 'Inspected the goods and decided what to accept');

-- Parties: 47 William Jones (ABC Corporation's employee), 13 ABC Subsidiary.
insert into shipment_receipt_role (shipment_receipt_role_id, shipment_receipt_id, party_id, shipment_receipt_role_type_id) values
  (1,  12900, 47, 'RECEIVER'),
  (2,  12900, 47, 'RECEIVER'),    -- DATA ERROR: the same party in the same role twice (caught by a query)
  (3,  12901, 47, 'RECEIVER'),
  (4,  12902, 47, 'RECEIVER'),
  (5,  13902, 47, 'RECEIVER'),
  (6,  13903, 47, 'RECEIVER'),
  (7,  13904, 47, 'RECEIVER'),
  (8,  13905, 47, 'RECEIVER'),
  (9,  13804, 13, 'RECEIVER'),
  (10, 13804, 13, 'INSPECTOR'),
  (11, 19600, 13, 'RECEIVER'),
  (12, 19600, 13, 'INSPECTOR');

select setval(pg_get_serial_sequence('shipment_receipt_role', 'shipment_receipt_role_id'), (select max(shipment_receipt_role_id) from shipment_receipt_role));

-- ============================================================
-- Fig 5.5 — Item issuance for outgoing shipments
-- ============================================================
-- Rosa Diaz, ABC Subsidiary's warehouse clerk, pulls the stock.
insert into party (party_id, party_kind) values
  (50, 'PERSON');

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into person (party_id, gender_type_id) values
  (50, 'FEMALE');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  (50, 'FIRST', '1999-01-01', null, 'Rosa'),
  (50, 'LAST',  '1999-01-01', null, 'Diaz');

-- Two bins in ABC Subsidiary's warehouse (facility 12, 300 Main Street).
insert into container (container_id, container_type_id, facility_id, description) values
  (4, 'BIN', 12, 'Bin P-1'),
  (5, 'BIN', 12, 'Bin P-2');

select setval(pg_get_serial_sequence('container', 'container_id'), (select max(container_id) from container));

-- The stock 9000, 9200, 9400 and 9500 leave from. Each quantity on hand is
-- what's left after the issues below, the wrong ones included (a cache that
-- applied every row written), except item 19's.
insert into inventory_item (inventory_item_id, inventory_item_kind, product_id, inventory_item_status_type_id, lot_id, facility_id, container_id, serial_num, quantity_on_hand) values
  (16, 'NON_SERIALIZED', 20, 'GOOD', null, 12,   null, null, 440),    -- pencils, floor stock
  (17, 'NON_SERIALIZED', 2,  'GOOD', null, 12,   null, null, 0),      -- pens, floor stock
  (18, 'NON_SERIALIZED', 2,  'GOOD', null, null, 5,    null, 300),    -- pens, bin P-2
  (19, 'NON_SERIALIZED', 3,  'GOOD', null, 12,   null, null, 400),    -- diskettes. DATA ERROR: 9200's 100 never subtracted, the balance is 300 (caught by a query)
  (20, 'NON_SERIALIZED', 21, 'GOOD', null, 12,   null, null, 85),     -- erasers
  (21, 'NON_SERIALIZED', 20, 'GOOD', null, null, 4,    null, 1000);   -- pencils, bin P-1

select setval(pg_get_serial_sequence('inventory_item', 'inventory_item_id'), (select max(inventory_item_id) from inventory_item));

-- Opening stock: counted when the items were set up, a variance against
-- zero (NOTES, point 32), so the balance has a starting point.
insert into reason (reason_id, description) values
  ('OPENING_COUNT', 'First count when the stock was set up');

insert into inventory_item_variance (inventory_item_id, physical_inventory_date, quantity, reason_id, comment) values
  (16, '2001-03-01', 3500, 'OPENING_COUNT', null),
  (17, '2001-03-01', 800,  'OPENING_COUNT', null),
  (18, '2001-03-01', 500,  'OPENING_COUNT', null),
  (19, '2001-03-01', 500,  'OPENING_COUNT', null),
  (20, '2001-03-01', 600,  'OPENING_COUNT', null),
  (21, '2001-03-01', 1000, 'OPENING_COUNT', null);

-- ABC Corporation's stock (Fig 5.4) after the issues below: pencils 2,150
-- received (12950's extra 50 included) less 620 issued; erasers 200 less 150.
update inventory_item set quantity_on_hand = 1530 where inventory_item_id = 10;
update inventory_item set quantity_on_hand = 50   where inventory_item_id = 13;

-- Table 5.9's packages (dates ours: the day before each shipment left).
insert into shipment_package (shipment_package_id, date_created) values
  (62000, '2001-03-06'),
  (62001, '2001-03-11'),
  (62002, '2001-03-11'),
  (62003, '2001-03-11');

-- Shipment lines: 1-3 on 9000; 4-6 on 9200.
insert into packaging_content (packaging_content_id, shipment_package_id, shipment_item_id, quantity) values
  (15, 62000, 1, 1000),
  (16, 62000, 2, 1000),
  (17, 62000, 3, 100),
  (18, 62001, 4, 350),
  (19, 62002, 5, 100),
  (20, 62002, 6, 1000),   -- printed 1,500 (NOTES, point 28)
  (21, 62003, 6, 500);

select setval(pg_get_serial_sequence('packaging_content', 'packaging_content_id'), (select max(packaging_content_id) from packaging_content));

-- Ours: what to pull, for 9000, 9200 and 9400.
insert into picklist (picklist_id, date_created) values
  (1, '2001-03-06'),
  (2, '2001-03-11'),
  (3, '2001-03-21');

select setval(pg_get_serial_sequence('picklist', 'picklist_id'), (select max(picklist_id) from picklist));

insert into picklist_item (picklist_item_id, picklist_id, inventory_item_id, quantity) values
  (1, 1, 16, 1000),
  (2, 1, 17, 800),
  (3, 1, 18, 200),
  (4, 1, 19, 100),
  (5, 2, 20, 350),
  (6, 2, 19, 100),
  (7, 2, 16, 1500),   -- one pick, two issuances (13802, 13803)
  (8, 2, 19, 100),    -- DATA ERROR: the diskette stock listed twice on one picklist (caught by a query)
  (9, 3, 21, 500);    -- 9400's pencils from bin P-1

select setval(pg_get_serial_sequence('picklist_item', 'picklist_item_id'), (select max(picklist_item_id) from picklist_item));

-- Table 5.9's issuances, then ours. Shipment lines: 7 on 9400, 13 on 3485,
-- 11 on 1578, 21-24 on 9500, 8 on 1146. Stock: 16-21 above, 10 and 13 ABC
-- Corporation's (Fig 5.4). Times are ours.
insert into item_issuance (item_issuance_id, inventory_item_id, shipment_item_id, picklist_item_id, issued_datetime, quantity) values
  (12900, 16, 1,    1,    '2001-03-06 14:00+00', 1000),
  (12901, 17, 2,    2,    '2001-03-06 14:10+00', 800),    -- 9000's pens, from two stocks ...
  (13100, 18, 2,    3,    '2001-03-06 14:30+00', 200),    --   ... the floor and bin P-2
  (12902, 19, 3,    4,    '2001-03-06 14:20+00', 100),
  (13800, 20, 4,    5,    '2001-03-11 09:00+00', 350),
  (13801, 19, 5,    6,    '2001-03-11 09:10+00', 100),
  (13802, 16, 6,    7,    '2001-03-11 09:20+00', 1000),
  (13803, 16, 6,    7,    '2001-03-11 09:40+00', 500),
  (14000, 10, 13,   null, '2001-06-22 14:00+00', 500),    -- ours from here: the transfer Fig 5.4 received, leaving ABC Corporation
  (15800, 10, 11,   null, '2001-04-08 10:00+00', 100),    -- our return to General Goods
  (13960, 20, null, null, '2001-03-15 11:00+00', 5),      -- five erasers for our own office: no shipment line
  (13953, 20, 24,   null, '2001-03-27 09:30+00', 60),
  (13900, 16, 7,    9,    '2001-03-21 10:00+00', 500),    -- DATA ERROR: floor stock, though the picklist named bin P-1 (caught by a query)
  (13950, 13, 21,   null, '2001-03-27 09:00+00', 150),    -- DATA ERROR: ABC Corporation's erasers for a shipment leaving 300 Main Street (caught by a query)
  (13951, 20, 22,   null, '2001-03-27 09:10+00', 100),    -- DATA ERROR: erasers pulled for a pencil line (caught by a query)
  (13952, 16, 23,   null, '2001-03-27 09:20+00', 60),     -- DATA ERROR: 60 for a line of 50 (caught by a query)
  (11460, 10, 8,    null, '2001-03-20 11:00+00', 20);     -- DATA ERROR: keyed against 1146, which came in (caught by a query)

select setval(pg_get_serial_sequence('item_issuance', 'item_issuance_id'), (select max(item_issuance_id) from item_issuance));

insert into item_issuance_role_type (item_issuance_role_type_id, description) values
  ('ISSUER',   'Pulled the goods from stock'),
  ('APPROVER', 'Approved the goods leaving stock');

-- Parties: 50 Rosa Diaz (ABC Subsidiary), 47 William Jones (ABC Corporation).
insert into item_issuance_role (item_issuance_role_id, item_issuance_id, party_id, item_issuance_role_type_id) values
  (1,  12900, 50, 'ISSUER'),
  (2,  12900, 50, 'ISSUER'),     -- DATA ERROR: the same party in the same role twice (caught by a query)
  (3,  12901, 50, 'ISSUER'),
  (4,  13100, 50, 'ISSUER'),
  (5,  12902, 50, 'ISSUER'),
  (6,  13800, 50, 'ISSUER'),
  (7,  13801, 50, 'ISSUER'),
  (8,  13802, 50, 'ISSUER'),
  (9,  13803, 50, 'ISSUER'),
  (10, 14000, 47, 'ISSUER'),
  (11, 15800, 47, 'ISSUER'),
  (12, 15800, 47, 'APPROVER'),   -- William pulls and approves his own return: the model allows it
  (13, 13960, 50, 'ISSUER');

select setval(pg_get_serial_sequence('item_issuance_role', 'item_issuance_role_id'), (select max(item_issuance_role_id) from item_issuance_role));

-- ============================================================
-- Fig 5.6 — Shipping documents
-- ============================================================
insert into document_type (document_type_id, parent_type_id, description) values
  ('SHIPPING_DOCUMENT',            null,                'Shipping document'),
  ('BILL_OF_LADING',               'SHIPPING_DOCUMENT', 'Bill of lading'),
  ('PACKAGING_SLIP',               'SHIPPING_DOCUMENT', 'Packaging slip'),
  ('EXPORT_DOCUMENTATION',         'SHIPPING_DOCUMENT', 'Export documentation'),
  ('MANIFEST',                     'SHIPPING_DOCUMENT', 'Manifest'),
  ('PORT_CHARGES_DOCUMENT',        'SHIPPING_DOCUMENT', 'Port charges document'),
  ('TAX_AND_TARIFF_DOCUMENT',      'SHIPPING_DOCUMENT', 'Tax and tariff document'),
  ('HAZARDOUS_MATERIALS_DOCUMENT', 'SHIPPING_DOCUMENT', 'Hazardous materials document'),
  ('OTHER_SHIPPING_DOCUMENT',      'SHIPPING_DOCUMENT', 'Other shipping document');

-- All ours: the book shows no table of documents.
insert into document (document_id, document_type_id, description) values
  (1, 'BILL_OF_LADING',          'Bill of lading, shipment 9000'),
  (2, 'PACKAGING_SLIP',          'Packing slip, package 62000'),
  (3, 'PACKAGING_SLIP',          'Packing slip, package 62002'),
  (4, 'MANIFEST',                'Very Reliable Parcel Service manifest, 2001-03-12'),
  (5, 'OTHER_SHIPPING_DOCUMENT', 'Certificate of conformity, HD diskettes'),
  (6, 'PACKAGING_SLIP',          'General Goods packing slip, carton 52000'),
  (7, 'BILL_OF_LADING',          'Bill of lading, shipment 9400'),     -- DATA ERROR: no shipping_document row says what it covers (caught by a query)
  (8, 'PACKAGING_SLIP',          'Packing slip found loose on the dock'),
  (9, 'PACKAGING_SLIP',          'Packing slip, package 62001');

select setval(pg_get_serial_sequence('document', 'document_id'), (select max(document_id) from document));

-- Shipment lines: 18 is 1146's diskettes. Packages: 62000 (9000), 62001 and
-- 62002 (9200), 52000 (1146).
insert into shipping_document (document_id, shipment_id, shipment_item_id, shipment_package_id) values
  (1, 9000, null, null),    -- the whole shipment
  (2, null, null, 62000),   -- one box
  (3, 9200, null, 62002),   -- a box and its shipment: two levels that agree
  (4, 9200, null, null),
  (5, null, 18,   null),    -- one line
  (6, null, null, 52000),
  (8, null, null, null),    -- DATA ERROR: covers nothing (caught by a query)
  (9, 9000, null, 62001);   -- DATA ERROR: 62001 holds 9200's erasers, not 9000's goods (caught by a query)

-- ============================================================
-- Fig 5.7 — Shipment route segments
-- ============================================================
-- Table 5.11's 9002, in no other table (NOTES, point 36): ours, a transfer
-- from ABC Subsidiary to ABC Corporation on Truck #1's run with 9000.
insert into shipment (shipment_id, shipment_type_id, estimated_ship_date, estimated_arrival_date, estimated_ready_date,
                      estimated_ship_cost, actual_ship_cost, latest_cancel_date, handling_instructions, last_updated,
                      shipped_from_party_id, shipped_from_contact_mechanism_id, shipped_to_party_id, shipped_to_contact_mechanism_id,
                      inquiry_contact_mechanism_id, receiving_contact_mechanism_id) values
  (9002, 'TRANSFER', '2001-03-07', '2001-03-07', null, null, null, null, null, null, 13, 40, 12, 33, null, null);

insert into shipment_item (shipment_item_id, shipment_id, shipment_item_seq_id, product_id, quantity,
                           shipment_contents_description, in_response_to_shipment_item_id) values
  (25, 9002, 1, 21, 200, null, null);   -- ours: erasers for ABC Corporation

select setval(pg_get_serial_sequence('shipment_item', 'shipment_item_id'), (select max(shipment_item_id) from shipment_item));

-- Carriers: a party role (point 40). ABC Subsidiary carries its own goods.
insert into role_type (role_type_id, parent_type_id, applies_to_kind, description) values
  ('CARRIER', 'ORGANIZATION_ROLE', 'ORGANIZATION', 'Carrier');

insert into party (party_id, party_kind) values
  (51, 'ORGANIZATION'),
  (52, 'ORGANIZATION');

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (51, 'CORPORATION', 'Very Reliable Parcel Service'),
  (52, 'CORPORATION', 'Air Goods Delivery Express');

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (77, 13, 'CARRIER', '1999-01-01', null),   -- ABC Subsidiary, with its own trucks
  (78, 51, 'CARRIER', '1990-01-01', null),
  (79, 52, 'CARRIER', '1995-01-01', null);

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

-- Where legs start and end: Fig 5.4's warehouses (11 ABC Corporation, 12
-- ABC Subsidiary) and two more, ours.
insert into facility (facility_id, facility_type_id, part_of_facility_id, description, square_footage) values
  (13, 'BUILDING',  null, 'ACME receiving dock, 234 Stretch Street',      null),
  (14, 'WAREHOUSE', null, 'General Goods warehouse, 300 Jennifer Street', 50000);

select setval(pg_get_serial_sequence('facility', 'facility_id'), (select max(facility_id) from facility));

insert into facility_contact_mechanism (facility_id, contact_mechanism_id, from_date, thru_date) values
  (13, 32, '2000-01-01', null),
  (14, 41, '2000-01-01', null);

insert into shipment_method_type (shipment_method_type_id, description) values
  ('TRUCK',  'Truck'),
  ('GROUND', 'Ground'),
  ('AIR',    'Air'),
  ('RAIL',   'Rail');   -- ours

insert into fixed_asset_type (fixed_asset_type_id, description) values
  ('VEHICLE',   'Vehicle'),
  ('EQUIPMENT', 'Equipment');   -- ours

insert into fixed_asset (fixed_asset_id, fixed_asset_type_id, name) values
  (1, 'VEHICLE',   'Truck #1'),
  (2, 'VEHICLE',   'Truck #25'),
  (3, 'EQUIPMENT', 'Dock conveyor C-2');

select setval(pg_get_serial_sequence('fixed_asset', 'fixed_asset_id'), (select max(fixed_asset_id) from fixed_asset));

-- Carrier roles: 77 ABC Subsidiary, 78 Very Reliable Parcel Service, 79 Air
-- Goods Delivery Express.
insert into carrier_shipment_method (carrier_shipment_method_id, carrier_party_role_id, shipment_method_type_id) values
  (1, 77, 'TRUCK'),
  (2, 78, 'GROUND'),
  (3, 79, 'AIR'),
  (4, 79, 'GROUND'),
  (5, 78, 'GROUND');   -- DATA ERROR: listed twice (caught by a query)

select setval(pg_get_serial_sequence('carrier_shipment_method', 'carrier_shipment_method_id'), (select max(carrier_shipment_method_id) from carrier_shipment_method));

-- Table 5.10's legs with Table 5.11's trucks, then ours. The actual times of
-- 9200 and 1146 are ours. Facilities: 11 ABC Corporation's warehouse, 12 ABC
-- Subsidiary's, 13 ACME's dock, 14 General Goods's warehouse.
insert into shipment_route_segment (shipment_route_segment_id, shipment_id, segment_seq_id, shipment_method_type_id, carrier_party_role_id,
                                    fixed_asset_id, from_facility_id, to_facility_id,
                                    estimated_start_datetime, estimated_arrival_datetime, actual_start_datetime, actual_arrival_datetime,
                                    start_mileage, end_mileage, fuel_used) values
  (1,  9000, 1, 'TRUCK',  77, 1,    12, 11, '2001-03-07 10:00+00', '2001-03-07 13:00+00', '2001-03-07 10:00+00', '2001-03-07 11:35+00', 52000, 52061, 2),
  (2,  9000, 2, 'TRUCK',  77, 2,    11, 13, '2001-03-07 14:00+00', '2001-03-07 16:00+00', '2001-03-07 12:05+00', '2001-03-07 20:16+00', 73525, 74006, 25),   -- left early, arrived four hours late
  (3,  9200, 1, 'GROUND', 78, null, 12, 13, '2001-03-12 13:00+00', '2001-03-14 13:00+00', '2001-03-12 13:10+00', '2001-03-14 10:00+00', null,  null,  null),
  (4,  1146, 1, 'AIR',    79, null, 14, 11, '2001-03-19 16:00+00', '2001-03-20 12:00+00', '2001-03-19 16:20+00', '2001-03-20 09:30+00', null,  null,  null),
  (5,  9002, 1, 'TRUCK',  77, 1,    12, 11, null,                  null,                  '2001-03-07 10:00+00', '2001-03-07 11:35+00', 52000, 52061, 2),    -- Table 5.11: the same run as 9000's first leg (point 37)
  (6,  9400, 1, 'AIR',    78, null, 12, 13, '2001-03-23 08:00+00', '2001-03-24 12:00+00', null,                  null,                  null,  null,  null),   -- ours from here. DATA ERROR: Very Reliable Parcel Service only offers ground (caught by a query)
  (7,  9500, 1, 'TRUCK',  77, 1,    12, 11, '2001-03-28 10:00+00', '2001-03-28 11:40+00', null,                  null,                  null,  null,  null),
  (8,  9500, 2, 'TRUCK',  77, 2,    12, 13, '2001-03-28 13:00+00', '2001-03-28 21:00+00', null,                  null,                  null,  null,  null),   -- DATA ERROR: starts at ABC Subsidiary, though leg 1 ended at ABC Corporation (caught by a query)
  (9,  1149, 1, 'AIR',    79, 3,    14, 11, '2001-03-25 16:00+00', '2001-03-26 12:00+00', null,                  null,                  null,  null,  null),   -- DATA ERROR: shipped using the dock conveyor (caught by a query)
  (10, 3485, 1, 'TRUCK',  77, 2,    11, 12, '2001-06-23 08:00+00', '2001-06-23 10:00+00', '2001-06-23 08:00+00', '2001-06-23 09:40+00', 80000, 79940, 3),    -- DATA ERROR: 60 miles fewer at the end (caught by a query)
  (11, 9600, 1, 'GROUND', 78, null, 13, 12, '2001-03-16 09:00+00', '2001-03-19 09:00+00', null,                  null,                  null,  null,  null),
  (12, 9600, 1, 'GROUND', 78, null, 13, 12, '2001-03-16 09:00+00', '2001-03-19 09:00+00', null,                  null,                  null,  null,  null);   -- DATA ERROR: leg 1 twice (caught by a query)

select setval(pg_get_serial_sequence('shipment_route_segment', 'shipment_route_segment_id'), (select max(shipment_route_segment_id) from shipment_route_segment));
