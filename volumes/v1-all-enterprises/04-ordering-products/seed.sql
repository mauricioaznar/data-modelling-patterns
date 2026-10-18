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
