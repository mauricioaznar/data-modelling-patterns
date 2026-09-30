-- Vol 1, Chapter 2 seed data.
-- Aim for data that exercises the tricky cases (history, overlapping roles,
-- hierarchies), not just the happy path.

-- ============================================================
-- Fig 2.3 (part 1, moved up) — Parties
-- ============================================================
-- Every person and organization gets its party row first.
insert into party (party_id, party_kind) values
  (1,  'PERSON'),         -- Ana
  (2,  'PERSON'),         -- Ben
  (3,  'PERSON'),         -- Chloe
  (4,  'ORGANIZATION'),   -- Northwind Traders
  (5,  'ORGANIZATION'),   -- Contoso Logistics
  (6,  'ORGANIZATION'),   -- Springfield Water Authority
  (7,  'ORGANIZATION'),   -- Northwind Platform Team
  (8,  'ORGANIZATION'),   -- García-López Family
  (9,  'ORGANIZATION'),   -- Saturday Book Club
  (10, 'PERSON'),         -- Kiri (mononymous)
  (11, 'ORGANIZATION');   -- DATA ERROR: a party with no organization row (caught by a query)

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

-- ============================================================
-- Fig 2.1 — Organization
-- ============================================================
insert into organization_type (organization_type_id, parent_type_id, description) values
  ('LEGAL',                 null,       'Legal organization'),
  ('CORPORATION',           'LEGAL',    'Corporation'),
  ('GOVERNMENT_AGENCY',     'LEGAL',    'Government agency'),
  ('INFORMAL',              null,       'Informal organization'),
  ('TEAM',                  'INFORMAL', 'Team'),
  ('FAMILY',                'INFORMAL', 'Family'),
  ('OTHER_INFORMAL',        'INFORMAL', 'Other informal organization');

insert into organization (party_id, organization_type_id, name, federal_tax_id_num) values
  (4, 'CORPORATION',       'Northwind Traders Inc.',      '12-3456789'),
  (5, 'CORPORATION',       'Contoso Logistics LLC',       null),          -- legal, but tax id not yet captured
  (6, 'GOVERNMENT_AGENCY', 'Springfield Water Authority', '98-7654321'),
  (7, 'TEAM',              'Northwind Platform Team',     null),
  (8, 'FAMILY',            'The García-López Family',     null),
  (9, 'OTHER_INFORMAL',    'Saturday Book Club',          '11-1111111');  -- informal WITH a tax id: data error the schema allows

-- ============================================================
-- Fig 2.2a — Person (flat)
-- ============================================================
-- Ana was born García, married in 2019 and took the name López, and holds
-- Mexican and Spanish passports. The flat model can only keep one of each.
insert into person_flat (person_id, current_personal_title, current_first_name, current_middle_name, current_last_name,
                    current_suffix, current_nickname, gender, birth_date, height, weight, mothers_maiden_name,
                    marital_status, social_security_no, current_passport_no, current_passport_expire_date,
                    total_years_work_experience, comment) values
  (1, 'Dr.', 'Ana',   'Lucía', 'López',   null,  'Anita', 'F',      '1990-05-14', 165, 63,   'Hernández', 'Married',  '123-45-6789', 'ES-X1234567', '2031-03-01', 12, 'Former name García: kept in a comment, the only place left'),
  (2, 'Mr.', 'Ben',   null,    'Okafor',  'Jr.', null,    'Male',   '1985-11-02', 180, 82,   'Adeyemi',   'divorced', null,          'GB-5550001',  '2029-07-15', 16, null),
  (3, null,  'Chloe', null,    'Martin',  null,  'Coco',  'Female', '2001-01-30', null, null, null,        null,       null,          null,          null,         2,  null);

select setval(pg_get_serial_sequence('person_flat', 'person_id'), (select max(person_id) from person_flat));

-- ============================================================
-- Fig 2.2b — Person, alternate model
-- ============================================================
-- Same three people as 2.2a, but now with their history, plus Kiri.

insert into gender_type (gender_type_id, description) values
  ('FEMALE',        'Female'),
  ('MALE',          'Male'),
  ('NON_BINARY',    'Non-binary'),
  ('NOT_DISCLOSED', 'Prefer not to say');   -- needed because gender is mandatory

insert into person (party_id, gender_type_id, birth_date, mothers_maiden_name, social_security_no, total_years_work_experience, comment) values
  (1,  'FEMALE',        '1990-05-14', 'Hernández', '123-45-6789', 12,   null),
  (2,  'MALE',          '1985-11-02', 'Adeyemi',   null,          16,   null),
  (3,  'FEMALE',        '2001-01-30', null,        null,          2,    null),
  (10, 'NOT_DISCLOSED', null,         null,        null,          null, 'Mononymous: has no last name');

-- Names -------------------------------------------------------
insert into person_name_type (person_name_type_id, description) values
  ('PERSONAL_TITLE', 'Personal title'),
  ('FIRST',          'First name'),
  ('MIDDLE',         'Middle name'),
  ('LAST',           'Last name'),
  ('SUFFIX',         'Suffix'),
  ('NICKNAME',       'Nickname');

insert into person_name (party_id, person_name_type_id, from_date, thru_date, name) values
  -- Ana: born García, became López on marriage, Dr. after her PhD
  (1, 'FIRST',          '1990-05-14', null,         'Ana'),
  (1, 'MIDDLE',         '1990-05-14', null,         'Lucía'),
  (1, 'LAST',           '1990-05-14', '2019-06-15', 'García'),
  (1, 'LAST',           '2019-06-15', null,         'López'),
  (1, 'NICKNAME',       '1995-01-01', null,         'Anita'),
  (1, 'PERSONAL_TITLE', '2018-07-01', null,         'Dr.'),
  -- Ben
  (2, 'PERSONAL_TITLE', '1985-11-02', null,         'Mr.'),
  (2, 'FIRST',          '1985-11-02', null,         'Ben'),
  (2, 'LAST',           '1985-11-02', null,         'Okafor'),
  (2, 'SUFFIX',         '1985-11-02', null,         'Jr.'),
  -- Chloe: dropped her childhood nickname in 2020
  (3, 'FIRST',          '2001-01-30', null,         'Chloe'),
  (3, 'LAST',           '2001-01-30', null,         'Martin'),
  (3, 'NICKNAME',       '2010-01-01', '2020-01-01', 'Coco'),
  -- Kiri: one name only. Fig 2.3 says last name is mandatory; reality disagrees.
  (10, 'FIRST',          '2000-01-01', null,         'Kiri');

-- Marital status ----------------------------------------------
insert into marital_status_type (marital_status_type_id, description) values
  ('SINGLE',   'Single'),
  ('MARRIED',  'Married'),
  ('DIVORCED', 'Divorced'),
  ('WIDOWED',  'Widowed');

-- Chloe has no rows: her status is unknown, which is not the same as single.
insert into marital_status (party_id, marital_status_type_id, from_date, thru_date) values
  (1, 'SINGLE',   '1990-05-14', '2019-06-15'),
  (1, 'MARRIED',  '2019-06-15', null),
  (2, 'SINGLE',   '1985-11-02', '2012-04-20'),
  (2, 'MARRIED',  '2012-04-20', '2020-09-01'),
  (2, 'DIVORCED', '2020-09-01', null);

-- Physical characteristics ------------------------------------
insert into physical_characteristic_type (physical_characteristic_type_id, description) values
  ('HEIGHT_CM', 'Height (cm)'),
  ('WEIGHT_KG', 'Weight (kg)'),
  ('EYE_COLOR', 'Eye colour');

insert into physical_characteristic (party_id, physical_characteristic_type_id, from_date, thru_date, value) values
  (1, 'HEIGHT_CM', '2008-01-01', null,         '165'),
  (1, 'WEIGHT_KG', '2015-01-01', '2021-01-01', '60'),
  (1, 'WEIGHT_KG', '2021-01-01', null,         '63'),
  (1, 'EYE_COLOR', '1990-05-14', null,         'brown'),
  (2, 'HEIGHT_CM', '2003-01-01', null,         '180'),
  (2, 'WEIGHT_KG', '2022-03-01', null,         '82'),
  (3, 'HEIGHT_CM', '2019-01-01', null,         'approx 170');   -- the EAV cost: nothing rejects this

-- Citizenship and passports -----------------------------------
insert into country (country_id, name) values
  ('MX', 'Mexico'),
  ('ES', 'Spain'),
  ('NG', 'Nigeria'),
  ('GB', 'United Kingdom'),
  ('FR', 'France');

insert into citizenship (citizenship_id, party_id, country_id, from_date, thru_date) values
  (1, 1, 'MX', '1990-05-14', null),
  (2, 1, 'ES', '2021-02-10', null),    -- dual citizen
  (3, 2, 'NG', '1985-11-02', null),
  (4, 2, 'GB', '2010-06-01', null),    -- dual citizen
  (5, 3, 'FR', '2001-01-30', null);    -- citizen with no passport

select setval(pg_get_serial_sequence('citizenship', 'citizenship_id'), (select max(citizenship_id) from citizenship));

insert into passport (passport_id, citizenship_id, passport_num, issue_date, expiration_date) values
  (1, 1, 'G11111111', '2014-03-01', '2020-03-01'),   -- Ana, Mexico: expired, replaced
  (2, 1, 'G22222222', '2020-02-15', '2030-02-15'),   -- Ana, Mexico
  (3, 2, 'X1234567',  '2021-03-01', '2031-03-01'),   -- Ana, Spain
  (4, 3, 'A00123456', '2015-01-10', '2020-01-10'),   -- Ben, Nigeria: expired, never renewed
  (5, 4, '555000111', '2019-07-15', '2029-07-15');   -- Ben, UK

select setval(pg_get_serial_sequence('passport', 'passport_id'), (select max(passport_id) from passport));

-- ============================================================
-- Fig 2.3 (part 2) — Party classification
-- ============================================================
insert into party_type (party_type_id, parent_type_id, applies_to_kind, description) values
  -- organization classifications
  ('ORGANIZATION_CLASSIFICATION', null,                          'ORGANIZATION', 'Organization classification'),
  ('MINORITY',                    'ORGANIZATION_CLASSIFICATION', 'ORGANIZATION', 'Minority classification'),
  ('MINORITY_OWNED',              'MINORITY',                    'ORGANIZATION', 'Minority-owned business'),
  ('WOMAN_OWNED',                 'MINORITY',                    'ORGANIZATION', 'Woman-owned business'),
  ('INDUSTRY',                    'ORGANIZATION_CLASSIFICATION', 'ORGANIZATION', 'Industry classification'),
  ('IND_WHOLESALE',               'INDUSTRY',                    'ORGANIZATION', 'Wholesale trade'),
  ('IND_LOGISTICS',               'INDUSTRY',                    'ORGANIZATION', 'Transportation and logistics'),
  ('IND_PUBLIC_ADMIN',            'INDUSTRY',                    'ORGANIZATION', 'Public administration'),
  ('SIZE',                        'ORGANIZATION_CLASSIFICATION', 'ORGANIZATION', 'Size classification'),
  ('SIZE_SMALL',                  'SIZE',                        'ORGANIZATION', 'Small (< 50 employees)'),
  ('SIZE_MEDIUM',                 'SIZE',                        'ORGANIZATION', 'Medium (50–249 employees)'),
  ('SIZE_LARGE',                  'SIZE',                        'ORGANIZATION', 'Large (250+ employees)'),
  -- person classifications
  ('PERSON_CLASSIFICATION',       null,                          'PERSON',       'Person classification'),
  ('EEOC',                        'PERSON_CLASSIFICATION',       'PERSON',       'EEOC job category'),
  ('EEOC_EXECUTIVE',              'EEOC',                        'PERSON',       'Executive/senior officials and managers'),
  ('EEOC_PROFESSIONAL',           'EEOC',                        'PERSON',       'Professionals'),
  ('EEOC_TECHNICIAN',             'EEOC',                        'PERSON',       'Technicians'),
  ('INCOME',                      'PERSON_CLASSIFICATION',       'PERSON',       'Income classification'),
  ('INCOME_LOW',                  'INCOME',                      'PERSON',       'Low income'),
  ('INCOME_MIDDLE',               'INCOME',                      'PERSON',       'Middle income'),
  ('INCOME_HIGH',                 'INCOME',                      'PERSON',       'High income');

insert into party_classification (party_id, party_type_id, from_date, thru_date) values
  -- Northwind grew from small to medium in 2018
  (4, 'IND_WHOLESALE',     '2010-01-01', null),
  (4, 'SIZE_SMALL',        '2010-01-01', '2018-01-01'),
  (4, 'SIZE_MEDIUM',       '2018-01-01', null),
  (4, 'WOMAN_OWNED',       '2015-03-01', null),
  -- Contoso: two classifications of different kinds at once
  (5, 'IND_LOGISTICS',     '2016-01-01', null),
  (5, 'SIZE_SMALL',        '2016-01-01', null),
  (5, 'MINORITY_OWNED',    '2016-01-01', null),
  (6, 'IND_PUBLIC_ADMIN',  '1950-01-01', null),
  -- people
  (1, 'EEOC_PROFESSIONAL', '2018-07-01', null),
  (1, 'INCOME_MIDDLE',     '2014-01-01', '2019-01-01'),
  (1, 'INCOME_HIGH',       '2019-01-01', null),
  (2, 'EEOC_EXECUTIVE',    '2020-01-01', null),
  (2, 'INCOME_HIGH',       '2020-01-01', null),
  (1, 'SIZE_SMALL',        '2022-01-01', null);   -- DATA ERROR: a company size on a person (caught by a query)

-- ============================================================
-- Fig 2.4 — Party roles
-- ============================================================
insert into role_type (role_type_id, parent_type_id, applies_to_kind, description) values
  -- person roles
  ('PERSON_ROLE',             null,                   null,           'Person role'),
  ('EMPLOYEE',                'PERSON_ROLE',          'PERSON',       'Employee'),
  ('CONTRACTOR',              'PERSON_ROLE',          'PERSON',       'Contractor'),
  ('FAMILY_MEMBER',           'PERSON_ROLE',          'PERSON',       'Family member'),
  ('CONTACT',                 'PERSON_ROLE',          'PERSON',       'Contact'),
  -- organization roles
  ('ORGANIZATION_ROLE',       null,                   null,           'Organization role'),
  ('DISTRIBUTION_CHANNEL',    'ORGANIZATION_ROLE',    null,           'Distribution channel'),
  ('AGENT',                   'DISTRIBUTION_CHANNEL', 'ORGANIZATION', 'Agent'),
  ('DISTRIBUTOR',             'DISTRIBUTION_CHANNEL', 'ORGANIZATION', 'Distributor'),
  ('PARTNER',                 'ORGANIZATION_ROLE',    'ORGANIZATION', 'Partner'),
  ('COMPETITOR',              'ORGANIZATION_ROLE',    'ORGANIZATION', 'Competitor'),
  ('HOUSEHOLD',               'ORGANIZATION_ROLE',    'ORGANIZATION', 'Household'),
  ('REGULATORY_AGENCY',       'ORGANIZATION_ROLE',    'ORGANIZATION', 'Regulatory agency'),
  ('SUPPLIER',                'ORGANIZATION_ROLE',    'ORGANIZATION', 'Supplier'),
  ('ASSOCIATION',             'ORGANIZATION_ROLE',    'ORGANIZATION', 'Association'),
  ('ORGANIZATION_UNIT',       'ORGANIZATION_ROLE',    null,           'Organization unit'),
  ('PARENT_ORGANIZATION',     'ORGANIZATION_UNIT',    'ORGANIZATION', 'Parent organization'),
  ('SUBSIDIARY',              'ORGANIZATION_UNIT',    'ORGANIZATION', 'Subsidiary'),
  ('DEPARTMENT',              'ORGANIZATION_UNIT',    'ORGANIZATION', 'Department'),
  ('DIVISION',                'ORGANIZATION_UNIT',    'ORGANIZATION', 'Division'),
  ('OTHER_ORGANIZATION_UNIT', 'ORGANIZATION_UNIT',    'ORGANIZATION', 'Other organization unit'),
  ('INTERNAL_ORGANIZATION',   'ORGANIZATION_ROLE',    'ORGANIZATION', 'Internal organization'),
  -- roles either kind of party can play
  ('CUSTOMER',                null,                   null,           'Customer'),
  ('BILL_TO_CUSTOMER',        'CUSTOMER',             'EITHER',       'Bill-to customer'),
  ('SHIP_TO_CUSTOMER',        'CUSTOMER',             'EITHER',       'Ship-to customer'),
  ('END_USER_CUSTOMER',       'CUSTOMER',             'EITHER',       'End-user customer'),
  ('PROSPECT',                null,                   'EITHER',       'Prospect'),
  ('SHAREHOLDER',             null,                   'EITHER',       'Shareholder');

-- "Our" enterprise is Northwind (party 4).
insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  -- Northwind and its platform team are internal
  (1,  4,  'INTERNAL_ORGANIZATION', '2010-01-01', null),
  (2,  4,  'PARENT_ORGANIZATION',   '2010-01-01', null),
  (3,  7,  'INTERNAL_ORGANIZATION', '2019-03-01', null),
  (4,  7,  'DEPARTMENT',            '2019-03-01', null),   -- department of whom? a role can't say
  -- Contoso is our supplier AND, since 2021, our customer: one party, three roles
  (5,  5,  'SUPPLIER',              '2016-01-01', null),
  (6,  5,  'BILL_TO_CUSTOMER',      '2021-04-01', null),
  (7,  5,  'SHIP_TO_CUSTOMER',      '2021-04-01', null),
  (8,  6,  'REGULATORY_AGENCY',     '2010-01-01', null),
  (9,  8,  'HOUSEHOLD',             '2019-06-15', null),
  (10, 8,  'END_USER_CUSTOMER',     '2020-02-01', null),
  (11, 9,  'ASSOCIATION',           '2018-01-01', null),
  -- Ana: employee, then contractor after leaving; also a shareholder and family member
  (12, 1,  'EMPLOYEE',              '2018-07-01', '2023-01-01'),
  (13, 1,  'CONTRACTOR',            '2023-01-01', null),
  (14, 1,  'SHAREHOLDER',           '2020-05-01', null),
  (15, 1,  'FAMILY_MEMBER',         '2019-06-15', null),
  -- Ben: a contact (for which organization? a role can't say), then a prospect who converted
  (16, 2,  'CONTACT',               '2016-01-01', null),
  (17, 2,  'PROSPECT',              '2023-01-10', '2023-06-01'),
  (18, 2,  'BILL_TO_CUSTOMER',      '2023-06-01', null),
  -- Chloe: employee
  (19, 3,  'EMPLOYEE',              '2023-09-01', null),
  -- Kiri: still a prospect
  (20, 10, 'PROSPECT',              '2025-02-01', null),
  -- DATA ERRORS the FKs allow (caught by queries):
  (21, 9,  'EMPLOYEE',              '2024-01-01', null),   -- an organization as an employee
  (22, 5,  'CUSTOMER',              '2024-01-01', null);   -- a grouping type assigned directly

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

-- ============================================================
-- Fig 2.5 — Specific party relationships
-- ============================================================
-- Party role ids used below (from Fig 2.4):
--   1 Northwind INTERNAL_ORGANIZATION    2 Northwind PARENT_ORGANIZATION
--   4 Platform Team DEPARTMENT           6 Contoso BILL_TO   7 Contoso SHIP_TO
--  10 García-López END_USER             12 Ana EMPLOYEE     16 Ben CONTACT
--  18 Ben BILL_TO                       19 Chloe EMPLOYEE

insert into employment (employment_id, employer_party_role_id, employee_party_role_id, from_date, thru_date) values
  (1, 1, 12, '2018-07-01', '2023-01-01'),   -- Northwind employed Ana until she became a contractor
  (2, 1, 19, '2023-09-01', null),           -- Northwind employs Chloe
  (3, 1, 16, '2024-01-01', null);           -- DATA ERROR the FKs allow: Ben's role is CONTACT, not EMPLOYEE

insert into customer_relationship (customer_relationship_id, customer_party_role_id, internal_org_party_role_id, from_date, thru_date) values
  (1, 6,  1, '2021-04-01', null),   -- Contoso buys from Northwind (billed)
  (2, 7,  1, '2021-04-01', null),   -- ... and receives the goods
  (3, 10, 1, '2020-02-01', null),   -- the García-López household uses Northwind's products
  (4, 18, 1, '2023-06-01', null);   -- Ben, after converting from prospect

insert into organization_rollup (organization_rollup_id, child_party_role_id, parent_party_role_id, from_date, thru_date) values
  (1, 4, 2, '2019-03-01', null);    -- the Platform Team is a department within Northwind

select setval(pg_get_serial_sequence('employment', 'employment_id'), (select max(employment_id) from employment));
select setval(pg_get_serial_sequence('customer_relationship', 'customer_relationship_id'), (select max(customer_relationship_id) from customer_relationship));
select setval(pg_get_serial_sequence('organization_rollup', 'organization_rollup_id'), (select max(organization_rollup_id) from organization_rollup));
