-- Vol 1, Chapter 9 seed data.
-- ABC Corporation (party 12, Ch 2) is the employer and hiring company
-- throughout. Ch 9's parties start at 70; Sue Jones is Ch 8's Susan Jones (68).

-- ============================================================
-- Fig 9.2 — Employment
-- ============================================================
-- Mike Johnson (Table 9.5) is new; Sue Jones is Ch 8's Susan Jones (point 5).
-- Their employer is ABC Corporation's internal organization role (73), ours:
-- the book names none (point 4).
insert into party (party_id, party_kind) values
  (70, 'PERSON');
select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into person (party_id, gender_type_id) values
  (70, 'MALE');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  (70, 'FIRST', '1960-01-01', null, 'Mike'),
  (70, 'LAST',  '1960-01-01', null, 'Johnson');

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (90, 70, 'EMPLOYEE', '1980-05-31', null),
  (91, 68, 'EMPLOYEE', '1995-03-01', null);
select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

-- Two employments, then a bad row: Mike Johnson "hired" again when he became
-- CEO, while his first employment is still open.
insert into party_relationship (party_relationship_id, party_relationship_type_id, from_party_role_id, to_party_role_id, from_date, thru_date, comment, status_type_id) values
  (21, 'EMPLOYMENT', 73, 90, '1980-05-31', null, null, 'REL_ACTIVE'),
  (22, 'EMPLOYMENT', 73, 91, '1995-03-01', null, null, 'REL_ACTIVE'),
  (23, 'EMPLOYMENT', 73, 90, '1996-06-01', null, 'DATA ERROR: a second employment while the first is open', 'REL_ACTIVE');
select setval(pg_get_serial_sequence('party_relationship', 'party_relationship_id'), (select max(party_relationship_id) from party_relationship));

-- ============================================================
-- Fig 9.3 — Position definition
-- ============================================================
-- Table 9.2's two types (the book's ids 1100 and 2200, point 9; descriptions
-- in our words).
insert into position_type (position_type_id, description, title, benefit_percent) values
  ('BUSINESS_ANALYST', 'Recommends business policies, procedures and mechanisms',            'Business Analyst', 100),
  ('ACCOUNTING_CLERK', 'Enters the books, files the papers, does administrative accounting', 'Accounting Clerk', 50);

-- The 2001 staffing budget that funds the slots (ours): one item can fund
-- several slots. Approved Nov 15, 2000; its item types land in Salaries
-- expense, like Table 8.14's.
insert into budget_item_type (budget_item_type_id, description) values
  ('BUSINESS_ANALYSTS', 'Business analysts'),
  ('PROGRAMMERS',       'Programmers'),
  ('TEMPORARY_HELP',    'Temporary help');

insert into budget (budget_id, budget_type_id, standard_time_period_id, comment) values
  (41001, 'OPERATING_BUDGET', 1, 'Information systems staffing');

insert into budget_item (budget_item_id, budget_id, budget_item_seq_id, budget_item_type_id, part_of_budget_item_id, amount, purpose, justification) values
  (410011, 41001, 1, 'BUSINESS_ANALYSTS', null, 120000, 'Two business analysts',     'The new order system needs requirements'),
  (410012, 41001, 2, 'PROGRAMMERS',       null, 150000, 'Three programmers',         'Build the new order system'),
  (410013, 41001, 3, 'TEMPORARY_HELP',    null,   9000, 'A summer accounting clerk', 'Cover the clerks'' holidays');

insert into budget_role (budget_role_id, budget_id, party_id, budget_role_type_id) values
  (10, 41001, 12, 'BUDGET_FOR');
select setval(pg_get_serial_sequence('budget_role', 'budget_role_id'), (select max(budget_role_id) from budget_role));

insert into budget_status (budget_status_id, budget_id, status_type_id, status_date, comment) values
  (20, 41001, 'BUDGET_CREATED',   '2000-10-01', null),
  (21, 41001, 'BUDGET_SUBMITTED', '2000-10-15', null),
  (22, 41001, 'BUDGET_APPROVED',  '2000-11-15', null);
select setval(pg_get_serial_sequence('budget_status', 'budget_status_id'), (select max(budget_status_id) from budget_status));

insert into gl_budget_xref (gl_budget_xref_id, budget_item_type_id, general_ledger_account_id, from_date, thru_date, allocation_percentage) values
  (20, 'BUSINESS_ANALYSTS', 560, '2001-01-01', null, 100),
  (21, 'PROGRAMMERS',       560, '2001-01-01', null, 100),
  (22, 'TEMPORARY_HELP',    560, '2001-01-01', null, 100);
select setval(pg_get_serial_sequence('gl_budget_xref', 'gl_budget_xref_id'), (select max(gl_budget_xref_id) from gl_budget_xref));

-- Position statuses (9.5's line, needed here since 9.5 makes it mandatory;
-- ours, point 15), under their own group as Ch 8's budget statuses.
insert into status_type (status_type_id, parent_type_id, description) values
  ('POSITION_STATUS',   null,              'Position status'),
  ('POSITION_PLANNED',  'POSITION_STATUS', 'Planned for'),
  ('POSITION_ACTIVE',   'POSITION_STATUS', 'Active'),
  ('POSITION_INACTIVE', 'POSITION_STATUS', 'Inactive');

-- Table 9.1 (types ours, point 7; 204's thru Aug 31 stored Sep 1), all in
-- ABC Corporation (9.5's hiring company), then a bad row: a second analyst
-- slot opened on Nov 1, 2000, two weeks before the budget that funds it was
-- approved.
insert into position (position_id, position_type_id, budget_item_id, organization_party_id, status_type_id,
                      estimated_from_date, estimated_thru_date,
                      salary_flag, exempt_flag, fulltime_flag, temporary_flag, actual_from_date, actual_thru_date) values
  (101, 'BUSINESS_ANALYST', 410011, 12, 'POSITION_ACTIVE',   '2001-01-01', null,         true, false, true, false, '2001-01-15', null),
  (204, 'ACCOUNTING_CLERK', 410013, 12, 'POSITION_INACTIVE', '2001-06-01', '2001-09-01', true, true,  true, true,  '2001-06-01', '2001-09-01'),
  (102, 'BUSINESS_ANALYST', 410011, 12, 'POSITION_ACTIVE',   '2001-03-01', null,         true, false, true, false, '2000-11-01', null);   -- DATA ERROR: opened before its budget was approved
select setval(pg_get_serial_sequence('position', 'position_id'), (select max(position_id) from position));

-- Responsibilities (ours: the book gives no table).
insert into responsibility_type (responsibility_type_id, description) values
  ('ANALYZE_PROCESSES',      'Analyze business processes'),
  ('RECOMMEND_POLICIES',     'Recommend policies and procedures'),
  ('GATHER_REQUIREMENTS',    'Gather system requirements'),
  ('TRAIN_USERS',            'Train users on new systems'),
  ('ENTER_BOOKKEEPING',      'Enter bookkeeping figures'),
  ('FILE_ACCOUNTING_PAPERS', 'File accounting papers');

-- What each type may be given. Training users joins the analyst's job
-- description in 2001.
insert into valid_responsibility (valid_responsibility_id, position_type_id, responsibility_type_id, from_date, thru_date, comment) values
  (1, 'BUSINESS_ANALYST', 'ANALYZE_PROCESSES',      '1995-01-01', null, null),
  (2, 'BUSINESS_ANALYST', 'RECOMMEND_POLICIES',     '1995-01-01', null, null),
  (3, 'BUSINESS_ANALYST', 'GATHER_REQUIREMENTS',    '1995-01-01', null, null),
  (4, 'BUSINESS_ANALYST', 'TRAIN_USERS',            '2001-01-01', null, 'Added for the new order system'),
  (5, 'ACCOUNTING_CLERK', 'ENTER_BOOKKEEPING',      '1995-01-01', null, null),
  (6, 'ACCOUNTING_CLERK', 'FILE_ACCOUNTING_PAPERS', '1995-01-01', null, null);
select setval(pg_get_serial_sequence('valid_responsibility', 'valid_responsibility_id'), (select max(valid_responsibility_id) from valid_responsibility));

-- What each slot is given, then a bad row: analyst slot 101 given the
-- clerk's bookkeeping, which is not valid for its type.
insert into position_responsibility (position_responsibility_id, position_id, responsibility_type_id, from_date, thru_date, comment) values
  (1, 101, 'ANALYZE_PROCESSES',   '2001-01-15', null,         null),
  (2, 101, 'GATHER_REQUIREMENTS', '2001-01-15', null,         null),
  (3, 101, 'TRAIN_USERS',         '2001-03-01', null,         'Once the order system goes live'),
  (4, 204, 'ENTER_BOOKKEEPING',   '2001-06-01', '2001-09-01', null),
  (5, 101, 'ENTER_BOOKKEEPING',   '2001-02-01', null,         'DATA ERROR: not a valid responsibility for a business analyst');
select setval(pg_get_serial_sequence('position_responsibility', 'position_responsibility_id'), (select max(position_responsibility_id) from position_responsibility));

-- ============================================================
-- Fig 9.4 — Position type definition
-- ============================================================
-- 9.3's "System", 9.4's "Systems" Administrator: one type (point 13).
insert into position_type (position_type_id, description, title) values
  ('SYSTEMS_ADMINISTRATOR', 'Keeps the servers, networks and system software running', 'Systems Administrator');

insert into position_classification_type (position_classification_type_id, description) values
  ('COMPUTER',      'Computer'),
  ('TECHNICAL',     'Technical'),
  ('ADMIN_SUPPORT', 'Admin support'),
  ('MIS',           'MIS');

-- Table 9.3 (Business Analyst's Computer class thru Dec 31, 1999 stored
-- Jan 1, 2000; the hours ours, point 11), then a bad row: Programmer classed
-- as Computer again in 1998 while the 1995 row is still open.
insert into position_type_class (position_type_class_id, position_type_id, position_classification_type_id, from_date, thru_date, standard_hours_per_week) values
  (1, 'PROGRAMMER',            'COMPUTER',      '1995-01-01', null,         null),
  (2, 'PROGRAMMER',            'TECHNICAL',     '1995-01-01', null,         null),
  (3, 'SYSTEMS_ADMINISTRATOR', 'COMPUTER',      '1995-01-01', null,         null),
  (4, 'SYSTEMS_ADMINISTRATOR', 'ADMIN_SUPPORT', '1997-04-01', null,         null),
  (5, 'BUSINESS_ANALYST',      'COMPUTER',      '1995-01-01', '2000-01-01', null),
  (6, 'BUSINESS_ANALYST',      'MIS',           '2000-01-01', null,         40),
  (7, 'PROGRAMMER',            'COMPUTER',      '1998-01-01', null,         37.5);   -- DATA ERROR: overlaps row 1
select setval(pg_get_serial_sequence('position_type_class', 'position_type_class_id'), (select max(position_type_class_id) from position_type_class));

-- A union (ours, point 14) that represents accounting clerks, then a bad
-- row: systems administrators "unionized by" ABC Corporation's internal
-- organization role.
insert into role_type (role_type_id, parent_type_id, applies_to_kind, description) values
  ('UNION', 'ORGANIZATION_ROLE', 'ORGANIZATION', 'Union');

insert into party (party_id, party_kind) values
  (71, 'ORGANIZATION');
select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (71, 'LEGAL', 'Office Workers Union Local 12');

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (92, 71, 'UNION', '1970-01-01', null);
select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

update position_type set union_party_role_id = 92 where position_type_id = 'ACCOUNTING_CLERK';
update position_type set union_party_role_id = 73 where position_type_id = 'SYSTEMS_ADMINISTRATOR';   -- DATA ERROR: role 73 is ABC Corporation's internal organization role, not a union

-- ============================================================
-- Fig 9.5 — Position fulfillment
-- ============================================================
-- The types of Table 9.5's slots (descriptions ours). Mail clerks are
-- represented by 9.4's union.
insert into position_type (position_type_id, description, title, union_party_role_id) values
  ('MAIL_CLERK',       'Sorts and delivers the mail',                  'Mail Clerk',       92),
  ('MAIL_SUPERVISOR',  'Runs the mail room',                           'Mail Supervisor',  null),
  ('OFFICE_MANAGER',   'Runs an office and its staff',                 'Office Manager',   null),
  ('REGIONAL_MANAGER', 'Runs the offices of a region',                 'Regional Manager', null),
  ('CEO',              'Runs the enterprise',                          'CEO',              null),
  ('MIS_MANAGER',      'Runs the management information systems group', 'MIS Manager',     null),
  ('CIO',              'Runs information systems for the enterprise',   'CIO',             null);

-- Table 9.5's slots, one per row, all in ABC Corporation (ids and dates
-- ours, point 24). The MIS manager slot closed when the CIO slot opened.
-- Then a bad row: a mail clerk slot "within" Ace Cleaning Service, a
-- supplier, not an internal organization.
insert into position (position_id, position_type_id, budget_item_id, organization_party_id, status_type_id,
                      estimated_from_date, estimated_thru_date,
                      salary_flag, exempt_flag, fulltime_flag, temporary_flag, actual_from_date, actual_thru_date) values
  (301, 'MAIL_CLERK',       null, 12, 'POSITION_ACTIVE',   '1978-01-01', null, false, false, true, false, '1978-01-01', null),
  (302, 'MAIL_SUPERVISOR',  null, 12, 'POSITION_ACTIVE',   '1978-01-01', null, true,  false, true, false, '1978-01-01', null),
  (303, 'OFFICE_MANAGER',   null, 12, 'POSITION_ACTIVE',   '1980-01-01', null, true,  true,  true, false, '1980-01-01', null),
  (304, 'REGIONAL_MANAGER', null, 12, 'POSITION_ACTIVE',   '1985-01-01', null, true,  true,  true, false, '1985-01-01', null),
  (305, 'CEO',              null, 12, 'POSITION_ACTIVE',   '1975-01-01', null, true,  true,  true, false, '1975-01-01', null),
  (311, 'PROGRAMMER',       null, 12, 'POSITION_ACTIVE',   '1994-01-01', null, true,  false, true, false, '1994-01-01', null),
  (312, 'BUSINESS_ANALYST', null, 12, 'POSITION_ACTIVE',   '1996-01-01', null, true,  false, true, false, '1996-01-01', null),
  (313, 'MIS_MANAGER',      null, 12, 'POSITION_INACTIVE', '1998-01-01', '2000-11-02', true, true, true, false, '1998-01-01', '2000-11-02'),
  (314, 'CIO',              null, 12, 'POSITION_ACTIVE',   '2000-11-02', null, true,  true,  true, false, '2000-11-02', null),
  (501, 'MAIL_CLERK',       null, 43, 'POSITION_PLANNED',  '2001-01-01', null, false, false, true, false, null,         null);   -- DATA ERROR: the hiring company is a supplier
select setval(pg_get_serial_sequence('position', 'position_id'), (select max(position_id) from position));

-- Kim Park, the summer clerk (ours): no employment with ABC Corporation, so
-- she shows in the review query (point 18).
insert into party (party_id, party_kind) values
  (72, 'PERSON');
select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into person (party_id, gender_type_id) values
  (72, 'FEMALE');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  (72, 'FIRST', '1980-01-01', null, 'Kim'),
  (72, 'LAST',  '1980-01-01', null, 'Park');

-- Table 9.5 (thru dates +1 day; Mike Johnson's clerk days end on the Jun 1
-- handover, point 17), then a bad row: Kim Park still in slot 204 two weeks
-- after it closed.
insert into position_fulfillment (position_fulfillment_id, position_id, party_id, from_date, thru_date, comment) values
  (1,  301, 70, '1980-05-31', '1980-06-01', null),
  (2,  302, 70, '1980-06-01', '1984-01-01', null),
  (3,  303, 70, '1984-01-01', '1990-06-01', null),
  (4,  304, 70, '1990-06-01', '1996-06-01', null),
  (5,  305, 70, '1996-06-01', null,         null),
  (6,  311, 68, '1995-03-01', '1997-02-28', null),
  (7,  312, 68, '1997-02-28', '1999-03-15', null),
  (8,  313, 68, '1999-03-15', '2000-11-02', null),
  (9,  314, 68, '2000-11-02', null,         null),
  (10, 204, 72, '2001-06-01', '2001-09-16', 'DATA ERROR: the slot closed on Sep 1');
select setval(pg_get_serial_sequence('position_fulfillment', 'position_fulfillment_id'), (select max(position_fulfillment_id) from position_fulfillment));
