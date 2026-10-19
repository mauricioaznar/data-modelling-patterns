-- Vol 1, Chapter 6: Work Effort — seed data
-- Book tables with their ids where given; deliberate bad rows are marked DATA ERROR.

-- ============================================================
-- Fig 6.1 — Work requirement
-- ============================================================
-- ABC Manufacturing, Inc. makes the pens: the "created for" party of Table
-- 6.3, one of our internal organizations.
insert into party (party_id, party_kind) values
  (53, 'ORGANIZATION');

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (53, 'CORPORATION', 'ABC Manufacturing, Inc.');

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (80, 53, 'INTERNAL_ORGANIZATION', '1995-01-01', null);

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into requirement_type (requirement_type_id, parent_type_id, description) values
  ('PRODUCT_REQUIREMENT', null,               'Need for goods or services'),
  ('WORK_REQUIREMENT',    null,               'Need for work'),
  ('PRODUCTION_RUN',      'WORK_REQUIREMENT', 'Production run'),
  ('INTERNAL_PROJECT',    'WORK_REQUIREMENT', 'Internal project'),
  ('MAINTENANCE',         'WORK_REQUIREMENT', 'Maintenance'),
  ('REPAIR',              'WORK_REQUIREMENT', 'Repair'),
  ('OTHER_WORK',          'WORK_REQUIREMENT', 'Other work');   -- ours: Ch 4's office cleaning fits none of the book's types

insert into deliverable_type (deliverable_type_id, description) values
  ('MANAGEMENT_REPORT', 'Management report'),
  ('ANALYSIS_DOCUMENT', 'Analysis document'),
  ('BUSINESS_METHOD',   'A new business method'),
  ('PLAN',              'Plan');

insert into deliverable (deliverable_id, deliverable_type_id, name, description) values
  (1, 'PLAN', '2001 Sales/Marketing Plan', null);   -- as printed in Table 6.2 (NOTES, point 3)

select setval(pg_get_serial_sequence('deliverable', 'deliverable_id'), (select max(deliverable_id) from deliverable));

insert into product (product_id, product_kind, name, introduction_date, uom_id) values
  (22, 'GOOD', 'Engraved black pen with gold trim', '1999-01-01', 'EA');

select setval(pg_get_serial_sequence('product', 'product_id'), (select max(product_id) from product));

insert into good (product_id) values (22);

-- Ch 5's assets get their acquisition dates; 5025 is Table 6.2's.
update fixed_asset set date_acquired = '1998-05-01' where fixed_asset_id = 1;
update fixed_asset set date_acquired = '1999-09-15' where fixed_asset_id = 2;
-- Fixed asset 3, the dock conveyor, is left undated: DATA ERROR (drawn mandatory, caught by a query).

insert into fixed_asset (fixed_asset_id, fixed_asset_type_id, name, date_acquired, date_last_serviced, date_next_service, production_capacity) values
  (5025, 'EQUIPMENT', 'Engraving machine #12', '1997-03-10', '2000-01-14', '2000-07-14', 400);   -- pens an hour

select setval(pg_get_serial_sequence('fixed_asset', 'fixed_asset_id'), (select max(fixed_asset_id) from fixed_asset));

-- Tables 6.1–6.2. 51245 and 51285 have no dates in the book: ours.
insert into requirement (requirement_id, requirement_origin, requirement_kind, requirement_type_id, description,
                         requirement_creation_date, required_by_date, quantity) values
  (50985, 'INTERNAL', 'WORK',    'PRODUCTION_RUN',   'Anticipated demand of 2,000 custom-engraved black pens with gold trim', '2000-07-05', '2000-08-05', 2000),
  (51245, 'INTERNAL', 'WORK',    'PRODUCTION_RUN',   'Anticipated demand of 1,500 custom-engraved black pens with gold trim', '2000-07-05', '2000-08-05', 1500),
  (51285, 'INTERNAL', 'WORK',    'PRODUCTION_RUN',   'Anticipated demand of 3,000 custom-engraved black pens with gold trim', '2000-11-20', '2000-12-20', 3000),
  (60102, 'INTERNAL', 'WORK',    'INTERNAL_PROJECT', 'Develop sales and marketing plan for 2002',                            '2000-10-15', '2000-12-15', null),
  (70485, 'INTERNAL', 'WORK',    'MAINTENANCE',      'Fix engraving machine',                                                '2000-06-16', '2000-06-18', null),
  -- ours, each with one mistake
  (70501, 'INTERNAL', 'WORK',    'MAINTENANCE',      'Service the packing line',                                             '2000-09-01', null,         null),   -- DATA ERROR: names no machine
  (70502, 'INTERNAL', 'WORK',    'PRODUCTION_RUN',   'Restock the pen display cases',                                        '2000-09-01', null,         200),    -- DATA ERROR: names no product
  (70503, 'INTERNAL', 'WORK',    'WORK_REQUIREMENT', 'Tidy the plant floor',                                                 '2000-09-01', null,         null),   -- DATA ERROR: typed with the grouping row
  (70504, 'INTERNAL', 'PRODUCT', 'PRODUCTION_RUN',   'Gold ink for the engraving line',                                      '2000-09-01', null,         20),     -- DATA ERROR: a product need typed as a production run
  (70505, 'INTERNAL', 'WORK',    null,               'Rewire the engraving bay',                                             '2000-09-01', null,         null),   -- DATA ERROR: a work need with no type
  (70506, 'INTERNAL', 'WORK',    'REPAIR',           'Fix the gold-ink pump',                                                '2000-09-01', null,         null);   -- DATA ERROR: no work_requirement row below


-- Ch 4's work requirements get their type (NOTES, point 13: no one asset is 14 PCs).
update requirement set requirement_type_id = 'REPAIR'     where requirement_id in (24905, 34988, 50003);
update requirement set requirement_type_id = 'OTHER_WORK' where requirement_id = 43005;

insert into work_requirement (requirement_id, product_id, fixed_asset_id, deliverable_id) values
  (50985, 22,   null, null),
  (51245, 22,   null, null),
  (51285, 22,   null, null),
  (60102, null, null, 1),
  (70485, null, 5025, null),
  (70501, null, null, null),
  (70502, null, null, null),
  (70503, null, null, null),
  (70505, null, null, null),
  (24905, null, null, null),   -- Ch 4's, now with their rows
  (34988, null, null, null),
  (43005, null, null, null),
  (50003, null, null, null);   -- Ch 4's dock door repair (its product row stays Ch 4's caught mistake)

insert into product_requirement (requirement_id, product_id) values
  (70504, null);

-- ============================================================
-- Fig 6.2 — Work requirement roles
-- ============================================================
-- John Smith, Sam Bossman and Dick Jones, at ABC Manufacturing.
insert into party (party_id, party_kind) values
  (54, 'PERSON'),
  (55, 'PERSON'),
  (56, 'PERSON');

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into person (party_id, gender_type_id) values
  (54, 'MALE'),
  (55, 'MALE'),
  (56, 'MALE');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  (54, 'FIRST', '1995-01-01', null, 'John'),
  (54, 'LAST',  '1995-01-01', null, 'Smith'),
  (55, 'FIRST', '1995-01-01', null, 'Sam'),
  (55, 'LAST',  '1995-01-01', null, 'Bossman'),
  (56, 'FIRST', '1995-01-01', null, 'Dick'),
  (56, 'LAST',  '1995-01-01', null, 'Jones');

-- Table 6.3's role types, beside Ch 4's OWNER, REQUESTER and APPROVER (NOTES, point 14).
insert into requirement_role_type (requirement_role_type_id, description) values
  ('CREATED_FOR',     'Created for: whose need it is'),
  ('CREATED_BY',      'Created by: who recorded it'),
  ('RESPONSIBLE_FOR', 'Responsible for seeing it filled'),
  ('AUTHORIZED_BY',   'Authorized it');

-- Table 6.3, thru dates +1 day (exclusive). Dick Jones's dates read as Dec 16,
-- 2000 and John Smith's return as Feb 21, 2001 (NOTES, point 4). 60102's
-- roles predate its creation as printed (point 5).
insert into requirement_role (requirement_id, party_id, requirement_role_type_id, from_date, thru_date, comment) values
  (50985, 53, 'CREATED_FOR',     '2000-07-05', null,         null),
  (50985, 54, 'CREATED_BY',      '2000-07-05', null,         null),
  (50985, 54, 'RESPONSIBLE_FOR', '2000-07-05', '2000-12-16', null),
  (50985, 55, 'AUTHORIZED_BY',   '2000-07-08', null,         null),
  (50985, 56, 'RESPONSIBLE_FOR', '2000-12-16', '2001-02-21', 'Covers while John Smith is on leave'),   -- the comment is ours
  (50985, 54, 'RESPONSIBLE_FOR', '2001-02-21', null,         null),
  (60102, 55, 'CREATED_FOR',     '2000-06-10', null,         null),
  (60102, 56, 'RESPONSIBLE_FOR', '2000-06-15', '2001-01-02', null),
  -- ours
  (50985, 55, 'RESPONSIBLE_FOR', '2001-01-15', '2001-02-01', null),   -- DATA ERROR: inside Dick Jones's period
  (50985, 53, 'CREATED_FOR',     '2000-07-05', null,         null);   -- DATA ERROR: Table 6.3's first row keyed in twice

-- ============================================================
-- Fig 6.3a — Work effort generation
-- ============================================================
insert into facility (facility_id, facility_type_id, part_of_facility_id, description, square_footage) values
  (15, 'PLANT',    null, 'ABC Manufacturing pen plant',   45000),
  (16, 'BUILDING', null, 'ABC Manufacturing head office', 20000);

select setval(pg_get_serial_sequence('facility', 'facility_id'), (select max(facility_id) from facility));

insert into work_effort_purpose_type (work_effort_purpose_type_id, description) values
  ('PRODUCTION_RUN', 'Production run'),
  ('MAINTENANCE',    'Maintenance'),
  ('WORK_FLOW',      'Work flow'),
  ('RESEARCH',       'Research');

-- Table 6.5's product: the customised pen a customer ordered.
insert into product (product_id, product_kind, name, introduction_date, uom_id) values
  (23, 'GOOD', 'Customized engraved pen with gold lettering', '2001-01-01', 'EA');

select setval(pg_get_serial_sequence('product', 'product_id'), (select max(product_id) from product));

insert into good (product_id) values (23);

-- Table 6.5's "need for customized pens": a customer's need, ours to number.
insert into requirement (requirement_id, requirement_origin, requirement_kind, requirement_type_id, description,
                         requirement_creation_date, required_by_date, quantity) values
  (52001, 'CUSTOMER', 'WORK', 'PRODUCTION_RUN', 'Need for customized pens', '2001-02-05', '2001-04-30', 2500);

insert into work_requirement (requirement_id, product_id) values
  (52001, 23);

-- The sales order behind Table 6.5 (ours): ACME (placing customer, party
-- role 60) orders 2,500 customised pens from ABC Manufacturing (80). A WORK line.
insert into "order" (order_id, order_kind, order_date, entry_date) values
  (23500, 'SALES', '2001-02-05', '2001-02-05');

insert into sales_order (order_id, placed_by_party_role_id, taken_by_party_role_id) values
  (23500, 60, 80);

insert into order_item (order_item_id, order_id, order_item_seq_id, product_id, quantity, unit_price, estimated_delivery_date, order_item_kind) values
  (49, 23500, 1, 23, 2500, 2.40, '2001-04-30', 'WORK'),
  (50, 23500, 2, 22, 500,  1.90, '2001-04-30', 'PRODUCT');   -- plain pens from stock, made against the forecast 51285

select setval(pg_get_serial_sequence('order_item', 'order_item_id'), (select max(order_item_id) from order_item));

insert into sales_order_item (order_item_id, corresponding_po_id) values
  (49, 'ACME-PO-7741'),
  (50, 'ACME-PO-7741');

insert into order_requirement_commitment (order_item_id, requirement_id, quantity) values
  (49, 52001, 2500),
  (50, 51285, 500);    -- the order uses up 500 of the 3,000 forecast: work reached through the need

-- Tables 6.4–6.5, with their ids. No types in the book (NOTES, point 10):
-- runs and the plan typed PROJECT, the repair a TASK. "Pencils" as printed
-- (point 7). Places, completion dates and actuals ours.
insert into work_effort (work_effort_id, work_effort_type_id, work_effort_purpose_type_id, facility_id, name, description,
                         scheduled_start_date, scheduled_completion_date, actual_start_datetime, actual_completion_datetime, actual_hours) values
  (28045, 'PROJECT', 'PRODUCTION_RUN', 15, 'Production run',                       'Production run of 3,500 pencils',
          '2000-06-01', '2000-06-09', '2000-06-01 08:00', '2000-06-08 17:00', 62),
  (51285, 'PROJECT', 'PRODUCTION_RUN', 15, 'Production run',                       'Production run of 1,500 pencils',
          '2000-12-05', '2000-12-05', '2000-12-05 08:00', '2000-12-05 18:00', 10),
  (51298, 'PROJECT', 'PRODUCTION_RUN', 15, 'Production run',                       'Production run of 1,500 pencils',
          '2000-12-06', '2000-12-06', '2000-12-06 08:00', '2000-12-06 17:30', 9.5),
  (32898, 'TASK',    'MAINTENANCE',    15, 'Fix engraving machine',                'Repair engraving machine #12 because it may not be powered up',
          '2000-12-12', '2000-12-12', '2000-12-12 09:00', '2000-12-12 13:30', 4.5),
  (39409, 'PROJECT', null,             16, 'Sales and marketing plan development', 'Develop a sales and marketing plan for 2002 including sales projections, channel distribution strategy, and competitive analysis',
          '2000-12-15', '2001-02-15', '2000-12-18 09:00', null,               null),
  (29534, 'PROJECT', 'PRODUCTION_RUN', 15, 'Production run #1 of pens',            'Production of 1,500 customized engraved pens with gold lettering',
          '2001-02-23', '2001-02-24', null,               null,               null),
  (29874, 'PROJECT', 'PRODUCTION_RUN', 15, 'Production run #2 of pens',            'Production of 1,000 customized engraved pens with gold lettering',
          '2001-03-23', '2001-03-23', null,               null,               null),
  -- ours
  (29900, 'TASK',    'RESEARCH',       15, 'Engrave sample pens',                  'Try the new gold lettering on 50 sample pens',
          '2001-01-10', '2001-01-10', '2001-01-10 10:00', '2001-01-10 12:00', 2);

select setval(pg_get_serial_sequence('work_effort', 'work_effort_id'), (select max(work_effort_id) from work_effort));

insert into production_run (work_effort_id, quantity_to_produce, quantity_produced, quantity_rejected) values
  (28045, 3500, 3460, 40),
  (51285, 1500, 1490, 10),
  (51298, 1500, 1500, 0),
  (29534, 1500, null, null),
  (29874, 1000, null, null),
  (29900, 50,   50,   0);    -- DATA ERROR: a research job with a production-run row

-- Table 6.4. 51298's blank read as "same as above": it fills 51285 too (point 8).
insert into work_requirement_fulfillment (work_effort_id, requirement_id) values
  (28045, 50985),
  (28045, 51245),
  (51285, 51285),
  (51298, 51285),
  (32898, 70485),
  (39409, 60102),
  (28045, 50985);   -- DATA ERROR: the first link keyed in twice

-- Table 6.5: both runs fill the one sales line.
insert into work_order_item_fulfillment (work_effort_id, order_item_id) values
  (29534, 49),
  (29874, 49),
  (51298, 1);       -- DATA ERROR: Ch 4's line 1 is ACME's bond paper, a PRODUCT line

-- ============================================================
-- Fig 6.4 — Work effort breakdown
-- ============================================================
-- JOB, a sixth level (NOTES, point 15), and Table 6.6's kinds of work, each
-- under its level with its standard hours (point 16).
insert into work_effort_type (work_effort_type_id, parent_type_id, description, standard_work_hours) values
  ('JOB',                    null,       'Job',                                   null),
  ('SET_UP_PRODUCTION_LINE', 'ACTIVITY', 'Set up production line',                20),
  ('OPERATE_MACHINERY',      'ACTIVITY', 'Operate machinery',                     10),
  ('CLEAN_UP_MACHINERY',     'ACTIVITY', 'Clean up machinery',                    5),
  ('QUALITY_ASSURE_GOODS',   'ACTIVITY', 'Quality assure goods produced',         10),
  ('MOVE_MACHINERY',         'TASK',     'Move manufacturing machinery in place', 5),
  ('MOVE_RAW_MATERIALS',     'TASK',     'Move raw materials in place for a run', 8),
  ('SET_UP_ROLLERS',         'TASK',     'Set up assembly line rollers',          7);

-- Production runs are jobs (Tables 6.6 and 6.9); 28045's schedule as Table 6.6 prints it.
update work_effort set work_effort_type_id = 'JOB' where work_effort_id in (28045, 51285, 51298, 29534, 29874);
update work_effort set scheduled_completion_date = '2000-06-04' where work_effort_id = 28045;

insert into work_effort_association_type (work_effort_association_type_id, parent_type_id, description) values
  ('BREAKDOWN',   null,         'Breakdown: the "to" effort is part of the "from" effort'),
  ('DEPENDENCY',  null,         'Dependency'),
  ('PRECEDENCY',  'DEPENDENCY', 'Precedency: the "to" effort waits for the "from" effort to finish'),
  ('CONCURRENCY', 'DEPENDENCY', 'Concurrency: the two efforts run at the same time');

-- Table 6.6. 51245 is production run #2 (point 17); its dates and size are ours.
-- Activities and tasks name no place: they happen where their job does.
insert into work_effort (work_effort_id, work_effort_type_id, work_effort_purpose_type_id, facility_id, name, description,
                         scheduled_start_date, scheduled_completion_date, estimated_hours, version_of_work_effort_id) values
  (51245,   'JOB',                    'PRODUCTION_RUN', 15,   'Production run #2', 'Production run #2',                                 '2000-06-05', '2000-06-08', null, null),
  (120001,  'SET_UP_PRODUCTION_LINE', null,             null, 'Set up',            'Set up production line',                            '2000-06-01', '2000-06-02', 20,   null),
  (120002,  'OPERATE_MACHINERY',      null,             null, 'Operate',           'Operate machinery',                                 '2000-06-03', '2000-06-03', 10,   null),
  (120003,  'CLEAN_UP_MACHINERY',     null,             null, 'Clean up',          'Clean up machinery',                                '2000-06-04', '2000-06-04', 5,    null),
  (120004,  'QUALITY_ASSURE_GOODS',   null,             null, 'Quality assurance', 'Quality assure goods produced',                     '2000-06-03', '2000-06-04', 10,   null),
  (3454587, 'MOVE_MACHINERY',         null,             null, 'Move machinery',    'Move pen manufacturing machinery in place',         '2000-06-01', '2000-06-01', 4,    null),
  (3454588, 'MOVE_RAW_MATERIALS',     null,             null, 'Move materials',    'Move raw materials in place for production run',    '2000-06-01', '2000-06-01', 7,    null),
  (3454589, 'SET_UP_ROLLERS',         null,             null, 'Set up rollers',    'Set up assembly line rollers',                      '2000-06-01', '2000-06-01', 6,    null),
  -- ours: the clean-up done again
  (120005,  'CLEAN_UP_MACHINERY',     null,             null, 'Clean up again',    'Clean up machinery again: ink left on the rollers', '2000-06-05', '2000-06-05', 3,    120003);

select setval(pg_get_serial_sequence('work_effort', 'work_effort_id'), (select max(work_effort_id) from work_effort));

insert into production_run (work_effort_id, quantity_to_produce) values
  (51245, 1500);

-- Table 6.6's breakdown ("1200" read as 120001, point 18); the dependencies and the from date are ours.
insert into work_effort_association (work_effort_association_type_id, from_work_effort_id, to_work_effort_id, from_date) values
  ('BREAKDOWN',   28045,   120001,  '2000-05-15'),
  ('BREAKDOWN',   51245,   120001,  '2000-05-15'),   -- one set-up serves two runs
  ('BREAKDOWN',   28045,   120002,  '2000-05-15'),
  ('BREAKDOWN',   28045,   120003,  '2000-05-15'),
  ('BREAKDOWN',   28045,   120004,  '2000-05-15'),
  ('BREAKDOWN',   120001,  3454587, '2000-05-15'),
  ('BREAKDOWN',   120001,  3454588, '2000-05-15'),
  ('BREAKDOWN',   120001,  3454589, '2000-05-15'),
  ('PRECEDENCY',  120001,  120002,  '2000-05-15'),   -- set up before operating
  ('PRECEDENCY',  120002,  120003,  '2000-05-15'),   -- operate before cleaning up
  ('PRECEDENCY',  3454587, 3454589, '2000-05-15'),   -- machinery in place before the rollers
  ('CONCURRENCY', 120002,  120004,  '2000-05-15'),   -- QA while the machines run
  -- ours, each with one mistake
  ('BREAKDOWN',   3454589, 28045,   '2000-05-20'),   -- DATA ERROR: a task drawn as its own job's parent (a cycle)
  ('DEPENDENCY',  120003,  120004,  '2000-05-20'),   -- DATA ERROR: typed with the grouping row
  ('PRECEDENCY',  120004,  120002,  '2000-05-20');   -- DATA ERROR: QA (to Jun 4) must finish before operating (Jun 3)
