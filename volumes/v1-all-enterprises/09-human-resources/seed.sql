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

-- ============================================================
-- Fig 9.6 — Position reporting relationships
-- ============================================================
insert into position_type (position_type_id, description, title) values
  ('DIRECTOR_BIS',           'Directs business information systems',          'Director of Business Information Systems'),
  ('PROGRAMMER_ANALYST',     'Analyzes needs and programs the solutions',     'Programmer/Analyst'),
  ('IS_DEVELOPMENT_MANAGER', 'Manages the development of new systems',        'IS Development Manager'),
  ('MAINTENANCE_MANAGER',    'Manages the upkeep of the systems in service',  'Maintenance Manager');

-- Table 9.4's slots (ids and dates ours, point 22). Its business analyst is
-- slot 312, the one Sue Jones held until 1999. The director's slot closes at
-- the end of 2000; the two manager slots open on Jan 1, 2001.
insert into position (position_id, position_type_id, budget_item_id, organization_party_id, status_type_id,
                      estimated_from_date, estimated_thru_date,
                      salary_flag, exempt_flag, fulltime_flag, temporary_flag, actual_from_date, actual_thru_date) values
  (401, 'DIRECTOR_BIS',           null,   12, 'POSITION_INACTIVE', '1999-01-01', '2001-01-01', true, true,  true, false, '1999-01-01', '2001-01-01'),
  (403, 'SYSTEMS_ADMINISTRATOR',  null,   12, 'POSITION_ACTIVE',   '1999-01-01', null,         true, false, true, false, '1999-01-01', null),
  (404, 'PROGRAMMER_ANALYST',     410012, 12, 'POSITION_ACTIVE',   '1999-01-01', null,         true, false, true, false, '1999-01-01', null),
  (405, 'IS_DEVELOPMENT_MANAGER', null,   12, 'POSITION_ACTIVE',   '2001-01-01', null,         true, true,  true, false, '2001-01-01', null),
  (406, 'MAINTENANCE_MANAGER',    null,   12, 'POSITION_ACTIVE',   '2001-01-01', null,         true, true,  true, false, '2001-01-01', null);
select setval(pg_get_serial_sequence('position', 'position_id'), (select max(position_id) from position));

-- Table 9.4 (by the text, point 20; every 2000 line ends Dec 31, stored
-- Jan 1, point 21), the managers' own lines to the CIO (ours), then a bad
-- row: the business analyst given a second primary line, to maintenance.
insert into position_reporting_structure (position_reporting_structure_id, reporting_position_id, manager_position_id, from_date, thru_date, comment, primary_flag) values
  (1,  312, 401, '2000-01-01', '2001-01-01', null, true),
  (2,  403, 401, '2000-01-01', '2001-01-01', null, true),
  (3,  404, 401, '2000-01-01', '2001-01-01', null, true),
  (4,  312, 405, '2001-01-01', null,         null, true),
  (5,  403, 405, '2001-01-01', null,         null, false),
  (6,  404, 405, '2001-01-01', null,         null, true),
  (7,  403, 406, '2001-01-01', null,         null, true),
  (8,  404, 406, '2001-01-01', null,         null, false),
  (9,  401, 314, '2000-11-02', '2001-01-01', 'The director reports to the new CIO', true),
  (10, 405, 314, '2001-01-01', null,         null, true),
  (11, 406, 314, '2001-01-01', null,         null, true),
  (12, 312, 406, '2001-01-01', null,         'DATA ERROR: a second primary line', true);
select setval(pg_get_serial_sequence('position_reporting_structure', 'position_reporting_structure_id'), (select max(position_reporting_structure_id) from position_reporting_structure));

-- ============================================================
-- Fig 9.7 — Salary determination and history
-- ============================================================
insert into rate_type (rate_type_id, description) values
  ('AVERAGE_PAY',  'Average pay rate'),
  ('HIGHEST_PAY',  'Highest pay rate'),
  ('LOWEST_PAY',   'Lowest pay rate'),
  ('STANDARD_PAY', 'Standard pay rate');

-- Table 9.6: Programmer's band, revised once in ten years (Dec 31, 1999
-- stored Jan 1, 2000). Then a bad row: a second lowest yearly rate from
-- Jul 1, 2000, while the 2000 one is still open.
insert into position_type_rate (position_type_id, rate_type_id, period_type_id, from_date, thru_date, rate) values
  ('PROGRAMMER', 'AVERAGE_PAY',  'YEAR', '1990-01-01', '2000-01-01', 45000),
  ('PROGRAMMER', 'HIGHEST_PAY',  'YEAR', '1990-01-01', '2000-01-01', 70000),
  ('PROGRAMMER', 'LOWEST_PAY',   'YEAR', '1990-01-01', '2000-01-01', 25000),
  ('PROGRAMMER', 'STANDARD_PAY', 'HOUR', '1990-01-01', '2000-01-01', 30.00),
  ('PROGRAMMER', 'AVERAGE_PAY',  'YEAR', '2000-01-01', null,         55000),
  ('PROGRAMMER', 'HIGHEST_PAY',  'YEAR', '2000-01-01', null,         90000),
  ('PROGRAMMER', 'LOWEST_PAY',   'YEAR', '2000-01-01', null,         30000),
  ('PROGRAMMER', 'STANDARD_PAY', 'HOUR', '2000-01-01', null,         55.00),
  ('PROGRAMMER', 'LOWEST_PAY',   'YEAR', '2000-07-01', null,         28000);   -- DATA ERROR: overlaps the 2000 lowest rate

-- Table 9.7's two grades, then the three Table 9.8 names but 9.7 doesn't
-- list (GG-5, GG-6, GG-8, ten steps each, amounts ours, point 28).
insert into pay_grade (pay_grade_id, name, comment) values
  (1, 'GG-1', null),
  (2, 'GG-2', null),
  (5, 'GG-5', 'Ours: Table 9.8 uses it, Table 9.7 doesn''t list it'),
  (6, 'GG-6', 'Ours: Table 9.8 uses it, Table 9.7 doesn''t list it'),
  (8, 'GG-8', 'Ours: Table 9.8 uses it, Table 9.7 doesn''t list it');

insert into salary_step (pay_grade_id, salary_step_seq_id, amount, date_modified) values
  (1, 1, 10000, '1990-01-01'),
  (1, 2, 10200, '1990-01-01'),
  (1, 3, 10400, '1990-01-01'),
  (1, 4, 10500, '1990-01-01'),
  (1, 5, 10800, '1990-01-01'),
  (2, 1, 10450, '1990-01-01'),
  (2, 2, 10780, '1990-01-01'),
  (2, 3, 11200, '1990-01-01'),
  (2, 4, 11650, '1990-01-01');

insert into salary_step (pay_grade_id, salary_step_seq_id, amount, date_modified)
select g.base_grade, s.n, g.base + (s.n - 1) * g.stride, '2000-01-01'
from (values (5, 30000, 1500), (6, 44500, 1700), (8, 70000, 2000)) as g (base_grade, base, stride)
cross join generate_series(1, 10) as s (n);

-- Table 9.8, a second enterprise's way: rates read off grade steps, no
-- amount. Same type, rate types, period and date as Table 9.6, so it goes on
-- Programmer/Analyst here (point 27).
insert into position_type_rate (position_type_id, rate_type_id, period_type_id, from_date, thru_date, rate, salary_step_id) values
  ('PROGRAMMER_ANALYST', 'AVERAGE_PAY', 'YEAR', '1990-01-01', null, null, (select salary_step_id from salary_step where pay_grade_id = 6 and salary_step_seq_id = 6)),
  ('PROGRAMMER_ANALYST', 'HIGHEST_PAY', 'YEAR', '1990-01-01', null, null, (select salary_step_id from salary_step where pay_grade_id = 8 and salary_step_seq_id = 10)),
  ('PROGRAMMER_ANALYST', 'LOWEST_PAY',  'YEAR', '1990-01-01', null, null, (select salary_step_id from salary_step where pay_grade_id = 5 and salary_step_seq_id = 1));


-- John Smith (Ch 6's party 54, employee role 82) works for ABC Corporation
-- (Table 9.9); Ch 6 placed him at ABC Manufacturing with no relationship
-- row, so the employment is new (point 31).
insert into party_relationship (party_relationship_id, party_relationship_type_id, from_party_role_id, to_party_role_id, from_date, thru_date, comment, status_type_id) values
  (24, 'EMPLOYMENT', 73, 82, '1995-01-01', null, null, 'REL_ACTIVE');
select setval(pg_get_serial_sequence('party_relationship', 'party_relationship_id'), (select max(party_relationship_id) from party_relationship));

-- Table 9.9 (Dec 31 thru dates stored Jan 1), then a bad row: a second
-- current salary from Jul 1, 2001.
insert into pay_history (pay_history_id, party_relationship_id, period_type_id, from_date, thru_date, amount, comment) values
  (1, 24, 'YEAR', '1995-01-01', '1998-01-01', 45000, null),
  (2, 24, 'YEAR', '1998-01-01', '2001-01-01', 55000, null),
  (3, 24, 'YEAR', '2001-01-01', null,         62500, null),
  (4, 24, 'YEAR', '2001-07-01', null,         64000, 'DATA ERROR: the 2001 salary is still open');
select setval(pg_get_serial_sequence('pay_history', 'pay_history_id'), (select max(pay_history_id) from pay_history));

-- ============================================================
-- Fig 9.8 — Benefits tracking
-- ============================================================
-- Vacation and sick leave count days (point 33).
insert into period_type (period_type_id, description) values
  ('DAY', 'Day');

-- The standard shares are ours: Table 9.10 gives only the actual ones.
insert into benefit_type (benefit_type_id, name, description, employer_paid_percentage) values
  ('HEALTH',     'Health',     'Health insurance',          50),
  ('VACATION',   'Vacation',   'Paid vacation days',        100),
  ('SICK_LEAVE', 'Sick leave', 'Paid sick days',            100),
  ('PLAN_401K',  '401k',       'Retirement plan (401k)',    100);

-- Table 9.10, John Smith at ABC Corporation (employment 24). Health's
-- Dec 31, 2000 stored Jan 1, 2001. Vacation and sick leave have no dates in
-- the table: from Jan 1, 2001, the current balance (point 32). Then bad
-- rows: a second health plan from Jul 1, 2000 while the first runs; Sue
-- Jones's health from 1994, before ABC Corporation employed her.
insert into party_benefit (party_benefit_id, party_relationship_id, benefit_type_id, period_type_id, from_date, thru_date, cost, actual_employer_paid_percent, available_time) values
  (1, 24, 'HEALTH',     'YEAR', '1998-01-01', '2001-01-01', 1200, 50,  null),
  (2, 24, 'HEALTH',     'YEAR', '2001-01-01', null,         1500, 60,  null),
  (3, 24, 'VACATION',   'DAY',  '2001-01-01', null,         null, 100, 15),
  (4, 24, 'SICK_LEAVE', 'DAY',  '2001-01-01', null,         null, 100, 10),
  (5, 24, 'PLAN_401K',  'YEAR', '2001-01-01', null,         50,   100, null),
  (6, 24, 'HEALTH',     'YEAR', '2000-07-01', null,         1300, 50,  null),   -- DATA ERROR: overlaps both health rows
  (7, 22, 'HEALTH',     'YEAR', '1994-01-01', null,         1200, 50,  null);   -- DATA ERROR: before Sue Jones's employment (Mar 1, 1995)
select setval(pg_get_serial_sequence('party_benefit', 'party_benefit_id'), (select max(party_benefit_id) from party_benefit));

-- ============================================================
-- Fig 9.9 — Payroll information
-- ============================================================
insert into deduction_type (deduction_type_id, description) values
  ('FEDERAL_TAX', 'Federal tax'),
  ('FICA',        'FICA'),
  ('STATE_TAX',   'State tax'),
  ('INSURANCE',   'Insurance');

-- Table 9.11, John Smith (role 82) at ABC Corporation (role 73): half his
-- pay into each of two accounts, the first swapped for a new one on Nov 2,
-- 1999 (Nov 1 stored Nov 2), and $125 a month for insurance. Routing and
-- account split from the table's "routing no and account number". Then a
-- bad row: a third account taking 30% from 2001, so the shares come to 130.
insert into payroll_preference (payroll_preference_id, employee_party_role_id, internal_organization_party_role_id, payroll_preference_seq_id,
                                from_date, thru_date, percentage, flat_amount, routing_number, account_number, bank_name,
                                period_type_id, payment_method_type_id, deduction_type_id) values
  (1, 82, 73, 1, '1995-01-01', '1999-11-02', 50,   null, '99986-99', '30984098', null, null,    'ELECTRONIC', null),
  (2, 82, 73, 2, '1995-01-01', null,         50,   null, '99986-98', '93485999', null, null,    'ELECTRONIC', null),
  (3, 82, 73, 3, '1999-11-02', null,         50,   null, '11111-22', '67567676', null, null,    'ELECTRONIC', null),
  (4, 82, 73, 4, '1999-11-02', null,         null, 125,  null,       null,       null, 'MONTH', null,         'INSURANCE'),
  (5, 82, 73, 5, '2001-01-01', null,         30,   null, '22222-33', '11112222', null, null,    'ELECTRONIC', null);   -- DATA ERROR: the shares now come to 130%
select setval(pg_get_serial_sequence('payroll_preference', 'payroll_preference_id'), (select max(payroll_preference_id) from payroll_preference));

-- Table 9.12: check 1001, $2,000 gross on Jan 1, 2001 (payment id ours; an
-- electronic payment carrying the check number as its reference, point 36).
-- Then a bad row: paycheck 1002 paid to Sue Jones but issued for John
-- Smith's role.
insert into payment (payment_id, payment_kind, payment_method_type_id, from_party_id, to_party_id, effective_date, payment_ref_num, amount, comment) values
  (90001, 'DISBURSEMENT', 'ELECTRONIC', 12, 54, '2001-01-01', '1001', 2000, 'Paycheck'),
  (90002, 'DISBURSEMENT', 'ELECTRONIC', 12, 68, '2001-01-01', '1002', 3000, 'DATA ERROR: paid to Sue Jones, issued for John Smith');

insert into paycheck (payment_id, employee_party_role_id, internal_organization_party_role_id) values
  (90001, 82, 73),
  (90002, 82, 73);

insert into deduction (payment_id, deduction_seq_id, deduction_type_id, amount) values
  (90001, 1, 'FEDERAL_TAX', 200.00),
  (90001, 2, 'FICA',         54.50),
  (90001, 3, 'STATE_TAX',    80.00),
  (90001, 4, 'INSURANCE',   125.00);

-- ============================================================
-- Fig 9.10 — Employment application
-- ============================================================
-- No sample data in the book: sources, statuses and applicants ours.
insert into employment_application_source_type (employment_application_source_type_id, description) values
  ('NEWSPAPER',         'Newspaper advertisement'),
  ('PERSONAL_REFERRAL', 'Personal referral'),
  ('INTERNET',          'Internet posting'),
  ('WALK_IN',           'Walk-in');

insert into status_type (status_type_id, parent_type_id, description) values
  ('EMPLOYMENT_APPLICATION_STATUS', null,                            'Employment application status'),
  ('APPLICATION_RECEIVED',          'EMPLOYMENT_APPLICATION_STATUS', 'Received'),
  ('APPLICATION_REJECTED',          'EMPLOYMENT_APPLICATION_STATUS', 'Rejected'),
  ('APPLICATION_ON_FILE',           'EMPLOYMENT_APPLICATION_STATUS', 'Kept on file'),
  ('APPLICATION_HIRED',             'EMPLOYMENT_APPLICATION_STATUS', 'Hired');

-- Three applicants: Ana Ruiz (73), John Doe (74), Lee Wong (75).
insert into party (party_id, party_kind) values
  (73, 'PERSON'),
  (74, 'PERSON'),
  (75, 'PERSON');
select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into person (party_id, gender_type_id, birth_date) values
  (73, 'FEMALE', '1975-04-12'),
  (74, 'MALE',   '1970-09-30'),
  (75, 'MALE',   '1978-02-03');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  (73, 'FIRST', '1975-04-12', null, 'Ana'),
  (73, 'LAST',  '1975-04-12', null, 'Ruiz'),
  (74, 'FIRST', '1970-09-30', null, 'John'),
  (74, 'LAST',  '1970-09-30', null, 'Doe'),
  (75, 'FIRST', '1978-02-03', null, 'Lee'),
  (75, 'LAST',  '1978-02-03', null, 'Wong');

-- Two applications for analyst slot 101 (Ana Ruiz, referred by Sue Jones,
-- is hired; John Doe is not), one for no slot in particular, Kim Park for
-- the summer clerk slot 204, referred by Mike Johnson. Then bad rows: John
-- Doe applies for slot 204 after it closed; Lee Wong's second application
-- carries a position status.
insert into employment_application (employment_application_id, application_date, position_id, status_type_id,
                                    employment_application_source_type_id, applicant_party_id, referrer_party_id) values
  (1, '2000-11-20', 101,  'APPLICATION_HIRED',    'PERSONAL_REFERRAL', 73, 68),
  (2, '2000-11-25', 101,  'APPLICATION_REJECTED', 'NEWSPAPER',         74, null),
  (3, '2001-02-10', null, 'APPLICATION_ON_FILE',  'INTERNET',          75, null),
  (4, '2001-05-01', 204,  'APPLICATION_HIRED',    'PERSONAL_REFERRAL', 72, 70),
  (5, '2001-10-01', 204,  'APPLICATION_RECEIVED', 'NEWSPAPER',         74, null),   -- DATA ERROR: slot 204 closed on Sep 1
  (6, '2001-03-01', null, 'POSITION_ACTIVE',      'WALK_IN',           75, null);   -- DATA ERROR: a position status on an application
select setval(pg_get_serial_sequence('employment_application', 'employment_application_id'), (select max(employment_application_id) from employment_application));

-- Ana Ruiz hired: employed by ABC Corporation and in slot 101 from the day it
-- opened (Jan 15, 2001).
insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (93, 73, 'EMPLOYEE', '2001-01-15', null);
select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into party_relationship (party_relationship_id, party_relationship_type_id, from_party_role_id, to_party_role_id, from_date, thru_date, comment, status_type_id) values
  (25, 'EMPLOYMENT', 73, 93, '2001-01-15', null, null, 'REL_ACTIVE');
select setval(pg_get_serial_sequence('party_relationship', 'party_relationship_id'), (select max(party_relationship_id) from party_relationship));

insert into position_fulfillment (position_fulfillment_id, position_id, party_id, from_date, thru_date, comment) values
  (11, 101, 73, '2001-01-15', null, null);
select setval(pg_get_serial_sequence('position_fulfillment', 'position_fulfillment_id'), (select max(position_fulfillment_id) from position_fulfillment));

-- ============================================================
-- Fig 9.11 — Employee skills and qualifications
-- ============================================================
-- No sample data in the book: all ours.
insert into qualification_type (qualification_type_id, parent_type_id, description) values
  ('DEGREE',              null,            'Degree'),
  ('CERTIFICATION',       null,            'Certification'),
  ('BA_ECONOMICS',        'DEGREE',        'BA in economics'),
  ('BS_COMPUTER_SCIENCE', 'DEGREE',        'BS in computer science'),
  ('MBA',                 'DEGREE',        'Master of business administration'),
  ('PMP',                 'CERTIFICATION', 'Project management professional'),
  ('CPA',                 'CERTIFICATION', 'Certified public accountant'),
  ('ISO_9001',            'CERTIFICATION', 'ISO 9001 quality management');

-- Applicants and staff, and ABC Corporation's ISO certification (a firm holds
-- qualifications too). John Doe's PMP lapsed in 2001. Then bad rows: Lee
-- Wong's degree "expiring" in 2003; Sue Jones holding the DEGREE group
-- itself.
insert into party_qualification (party_qualification_id, party_id, qualification_type_id, from_date, thru_date) values
  (1, 73, 'BA_ECONOMICS',        '1997-06-01', null),
  (2, 73, 'MBA',                 '2000-06-01', null),
  (3, 74, 'BS_COMPUTER_SCIENCE', '1992-06-01', null),
  (4, 74, 'PMP',                 '1998-03-01', '2001-03-01'),
  (5, 68, 'MBA',                 '1994-06-01', null),
  (6, 12, 'ISO_9001',            '1999-01-01', '2002-01-01'),
  (7, 75, 'BS_COMPUTER_SCIENCE', '2000-06-01', '2003-06-01'),   -- DATA ERROR: a degree doesn't expire
  (8, 68, 'DEGREE',              '1990-06-01', null);           -- DATA ERROR: the group, not a degree
select setval(pg_get_serial_sequence('party_qualification', 'party_qualification_id'), (select max(party_qualification_id) from party_qualification));

insert into skill_type (skill_type_id, description) values
  ('BUSINESS_ANALYSIS', 'Business analysis'),
  ('SQL_PROGRAMMING',   'SQL programming');

insert into party_skill (party_id, skill_type_id, years_experience, rating, started_using_date) values
  (73, 'BUSINESS_ANALYSIS', 4, 4, '1997-07-01'),
  (74, 'SQL_PROGRAMMING',   8, 3, '1993-01-01'),
  (74, 'BUSINESS_ANALYSIS', 2, 2, '1999-01-01'),
  (75, 'SQL_PROGRAMMING',   1, 2, '2000-01-01');

insert into training_class_type (training_class_type_id, description) values
  ('DATA_MODELING',    'Data modeling'),
  ('LEADERSHIP',       'Leadership for new managers'),
  ('ORDER_SYSTEM_USE', 'Using the new order system');

-- Thru dates exclusive: the day after the last class day.
insert into person_training (person_training_id, party_id, training_class_type_id, from_date, thru_date) values
  (1, 68, 'DATA_MODELING',    '1999-04-05', '1999-04-10'),
  (2, 70, 'LEADERSHIP',       '1996-05-01', '1996-05-04'),
  (3, 73, 'ORDER_SYSTEM_USE', '2001-02-12', '2001-02-15');
select setval(pg_get_serial_sequence('person_training', 'person_training_id'), (select max(person_training_id) from person_training));

insert into resume (resume_id, party_id, resume_date, resume_text) values
  (1, 73, '2000-11-20', 'Business analyst, four years in retail systems; BA economics, MBA.'),
  (2, 74, '2000-11-25', 'SQL developer, eight years; BS computer science; PMP.'),
  (3, 75, '2001-02-10', 'Junior programmer, one year of SQL.');
select setval(pg_get_serial_sequence('resume', 'resume_id'), (select max(resume_id) from resume));

-- ============================================================
-- Fig 9.12a — Employee performance
-- ============================================================
-- MANAGER is a person role (9.12a draws it beside EMPLOYEE). Dick Jones (Ch
-- 6's party 56, who approves John Smith's timesheets there) manages John
-- Smith (ours, point 46).
insert into role_type (role_type_id, parent_type_id, applies_to_kind, description) values
  ('MANAGER', 'PERSON_ROLE', 'PERSON', 'Manager');

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (94, 56, 'MANAGER', '1995-01-01', null);
select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into perf_review_item_type (perf_review_item_type_id, description) values
  ('QUALITY_OF_WORK', 'Quality of work'),
  ('TEAMWORK',        'Teamwork'),
  ('INITIATIVE',      'Initiative');

-- Ch 3's rating types already hold OUTSTANDING (point 45).
insert into rating_type (rating_type_id, description) values
  ('EXCEEDS',           'Exceeds expectations'),
  ('MEETS',             'Meets expectations'),
  ('NEEDS_IMPROVEMENT', 'Needs improvement');

insert into performance_note_type (performance_note_type_id, description) values
  ('COMMENDATION', 'Commendation'),
  ('LATENESS',     'Late arrival'),
  ('WARNING',      'Verbal warning');

-- A bonus paycheck for John Smith, from his 2000 review (ours).
insert into payment (payment_id, payment_kind, payment_method_type_id, from_party_id, to_party_id, effective_date, payment_ref_num, amount, comment) values
  (90003, 'DISBURSEMENT', 'ELECTRONIC', 12, 54, '2001-01-15', '1003', 1000, 'Bonus');

insert into paycheck (payment_id, employee_party_role_id, internal_organization_party_role_id) values
  (90003, 82, 73);

-- John Smith's 1997 and 2000 reviews from Dick Jones (ours), each setting the
-- next year's pay (Table 9.9's raises); 2000's also earns a bonus. Then bad
-- rows: a review "from" Sue Jones's employee role, not a manager; a review
-- of Ana Ruiz that sets John Smith's pay.
insert into performance_review (performance_review_id, employee_party_role_id, manager_party_role_id, from_date, thru_date, comments, pay_history_id, payment_id, position_id) values
  (1, 82, 94, '1997-01-01', '1998-01-01', 'Solid year',                    2,    null,  null),
  (2, 82, 94, '2000-01-01', '2001-01-01', 'Led the order system cutover',  3,    90003, null),
  (3, 82, 91, '2000-01-01', '2001-01-01', 'DATA ERROR: from an employee role, not a manager', null, null, null),
  (4, 93, 94, '2001-01-15', '2001-07-15', 'DATA ERROR: sets another employee''s pay', 3, null, null);
select setval(pg_get_serial_sequence('performance_review', 'performance_review_id'), (select max(performance_review_id) from performance_review));

insert into performance_review_item (performance_review_id, perf_review_seq_id, perf_review_item_type_id, rating_type_id, comment) values
  (1, 1, 'QUALITY_OF_WORK', 'MEETS',       null),
  (1, 2, 'TEAMWORK',        'MEETS',       null),
  (2, 1, 'QUALITY_OF_WORK', 'EXCEEDS',     null),
  (2, 2, 'TEAMWORK',        'MEETS',       'Could share more with the team'),
  (2, 3, 'INITIATIVE',      'OUTSTANDING', 'Took on the cutover weekend');

insert into performance_note (performance_note_id, employee_party_role_id, manager_party_role_id, performance_note_type_id, from_date, thru_date, communication_date, comment) values
  (1, 82, 94, 'LATENESS',     '2000-03-06', null, '2000-03-06', 'Late three days running'),
  (2, 82, 94, 'COMMENDATION', '2000-11-20', null, '2000-11-21', 'Cutover finished a week early');
select setval(pg_get_serial_sequence('performance_note', 'performance_note_id'), (select max(performance_note_id) from performance_note));
