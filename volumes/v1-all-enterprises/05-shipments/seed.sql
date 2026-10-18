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

-- Table 5.2 (9000) and Table 5.5 (9200, 9400; shared with Fig 5.3), then
-- ours. Goods: 2 the Goldstein Elite pen, 3 the box of 3½-inch (HD)
-- diskettes, 20 the Jones #2 pencil, 21 the standard eraser.
insert into shipment_item (shipment_item_id, shipment_id, shipment_item_seq_id, product_id, quantity,
                           shipment_contents_description, in_response_to_shipment_item_id) values
  (1,  9000, 1, 20,   1000, null, null),
  (2,  9000, 2, 2,    1000, null, null),
  (3,  9000, 3, 3,    100,  null, null),
  (4,  9200, 1, 21,   350,  null, null),
  (5,  9200, 2, 3,    100,  null, null),
  (6,  9200, 3, 20,   1500, null, null),   -- Table 5.5 as read; no order line in Table 5.6 claims it (NOTES, point 13)
  (7,  9400, 1, 20,   500,  null, null),
  (8,  1146, 1, 20,   1200, null, null),   -- ours from here
  (9,  1149, 1, 20,   800,  null, null),
  (10, 1149, 1, 21,   500,  null, null),   -- DATA ERROR: a second line 1 on the shipment (caught by a query)
  (11, 1578, 1, 20,   100,  null, 8),      -- water-damaged pencils sent back from 1146
  (12, 1578, 2, null, 5,    null, null),   -- DATA ERROR: no good and no description (caught by a query)
  (13, 3485, 1, 20,   1000, null, null),   -- stock moved to the subsidiary that ships to ACME
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
  (2,  9000, 'SHIPMENT_SHIPPED',   '2001-03-07 08:00+00'),   -- a day after the estimate
  (3,  9000, 'SHIPMENT_RECEIVED',  '2001-03-07 16:00+00'),   -- a day before the estimate
  (4,  4800, 'SHIPMENT_SCHEDULED', '2001-07-09 10:00+00'),
  (5,  4800, 'SHIPMENT_CANCELLED', '2001-07-10 11:00+00'),   -- on its latest cancel date
  (6,  9200, 'SHIPMENT_SCHEDULED', '2001-03-09 09:00+00'),
  (7,  9200, 'SHIPMENT_SHIPPED',   '2001-03-12 08:00+00'),
  (8,  9200, 'SHIPMENT_IN_ROUTE',  '2001-03-13 07:00+00'),
  (9,  9200, 'SHIPMENT_DELIVERED', '2001-03-14 10:00+00'),   -- the carrier hands it over ...
  (10, 9200, 'SHIPMENT_RECEIVED',  '2001-03-14 11:30+00'),   --   ... and ACME takes it in
  (11, 9200, 'SHIPMENT_SHIPPED',   '2001-03-12 15:00+00'),   -- DATA ERROR: shipped twice, keyed again that afternoon (caught by a query)
  (12, 9400, 'SHIPMENT_SCHEDULED', '2001-03-20 09:00+00'),
  (13, 9400, 'SHIPMENT_SHIPPED',   '2001-03-23 08:00+00'),   -- a day late ...
  (14, 9400, 'SHIPMENT_RECEIVED',  '2001-03-26 14:00+00'),   --   ... and still a day late
  (15, 1146, 'SHIPMENT_SCHEDULED', '2001-03-15 09:00+00'),
  (16, 1146, 'SHIPMENT_SHIPPED',   '2001-03-19 08:00+00'),
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
