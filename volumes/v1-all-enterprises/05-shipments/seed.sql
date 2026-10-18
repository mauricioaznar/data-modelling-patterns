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
