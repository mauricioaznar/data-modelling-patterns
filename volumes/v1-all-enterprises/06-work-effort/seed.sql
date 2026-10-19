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
