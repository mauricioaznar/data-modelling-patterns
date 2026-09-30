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
-- Fig 2.8 (part 1, moved up) — Geographic boundaries
-- ============================================================
-- Seeded early because citizenship (2.2b) points at countries. How the
-- boundaries nest is in the 2.8 section at the end (geographic_boundary_association).
insert into geographic_boundary_type (geographic_boundary_type_id, description) values
  ('COUNTRY',           'Country'),
  ('STATE',             'State'),
  ('PROVINCE',          'Province'),
  ('TERRITORY',         'Territory'),
  ('COUNTY',            'County'),
  ('CITY',              'City'),
  ('COUNTY_CITY',       'County city'),
  ('POSTAL_CODE',       'Postal code'),
  ('SALES_TERRITORY',   'Sales territory'),
  ('SERVICE_TERRITORY', 'Service territory'),
  ('REGION',            'Region');

insert into geographic_boundary (geographic_boundary_id, geographic_boundary_type_id, geo_code, name, abbreviation) values
  -- countries (ISO code in geo_code)
  (1,  'COUNTRY',         'MX',    'Mexico',              'MX'),
  (2,  'COUNTRY',         'ES',    'Spain',               'ES'),
  (3,  'COUNTRY',         'NG',    'Nigeria',             'NG'),
  (4,  'COUNTRY',         'GB',    'United Kingdom',      'UK'),
  (5,  'COUNTRY',         'FR',    'France',              'FR'),
  (6,  'COUNTRY',         'US',    'United States',       'USA'),
  -- United States
  (10, 'STATE',           'IL',    'Illinois',            'IL'),
  (11, 'STATE',           'MO',    'Missouri',            'MO'),
  (12, 'COUNTY',          null,    'Sangamon County',     null),
  (13, 'CITY',            null,    'Springfield',         null),
  (14, 'CITY',            null,    'Chatham',             null),
  (15, 'POSTAL_CODE',     '62704', '62704',               null),
  (16, 'POSTAL_CODE',     '62707', '62707',               null),   -- crosses two cities
  (17, 'CITY',            null,    'St. Louis',           null),
  (18, 'POSTAL_CODE',     '63101', '63101',               null),
  -- Mexico
  (20, 'STATE',           'JAL',   'Jalisco',             'Jal.'),
  (21, 'CITY',            null,    'Guadalajara',         null),
  (22, 'POSTAL_CODE',     '44100', '44100',               null),
  -- business-defined boundaries
  (30, 'SALES_TERRITORY', 'MW',    'Midwest Sales',       null),   -- spans two states
  (31, 'REGION',          'NA',    'North America',       null);

select setval(pg_get_serial_sequence('geographic_boundary', 'geographic_boundary_id'), (select max(geographic_boundary_id) from geographic_boundary));

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
-- country_id is a geographic boundary id (countries are seeded in the 2.8
-- block at the top): 1 Mexico, 2 Spain, 3 Nigeria, 4 United Kingdom, 5 France.
insert into citizenship (citizenship_id, party_id, country_id, from_date, thru_date) values
  (1, 1, 1, '1990-05-14', null),
  (2, 1, 2, '2021-02-10', null),    -- dual citizen
  (3, 2, 3, '1985-11-02', null),
  (4, 2, 4, '2010-06-01', null),    -- dual citizen
  (5, 3, 5, '2001-01-30', null),    -- citizen with no passport
  (6, 10, 10, '2020-01-01', null);  -- DATA ERROR: boundary 10 is Illinois, a state, not a country

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
  ('CUSTOMER',                null,                   'EITHER',       'Customer'),                -- assignable itself: Table 2.5 gives ACME plain Customer
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
  (22, 7,  'ORGANIZATION_UNIT',     '2024-01-01', null);   -- a grouping type assigned directly

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

-- ============================================================
-- Fig 2.6a — Common party relationships (generic)
-- ============================================================
-- Directions for EMPLOYMENT, CUSTOMER and ROLLUP come from Fig 2.5; the other
-- four are assumed by analogy (outside party → us). See NOTES.md.
insert into party_relationship_type (party_relationship_type_id, name, from_role_type_id, to_role_type_id, description) values
  ('EMPLOYMENT',                        'Employment',                        'INTERNAL_ORGANIZATION', 'EMPLOYEE',              'An internal organization employs a person'),
  ('CUSTOMER_RELATIONSHIP',             'Customer relationship',             'CUSTOMER',              'INTERNAL_ORGANIZATION', 'A customer buys from an internal organization'),
  ('ORGANIZATION_ROLLUP',               'Organization rollup',               'ORGANIZATION_UNIT',     'ORGANIZATION_ROLE',     'A unit sits within a larger organization'),
  ('SUPPLIER_RELATIONSHIP',             'Supplier relationship',             'SUPPLIER',              'INTERNAL_ORGANIZATION', 'A supplier sells to an internal organization'),
  ('ORGANIZATION_CONTACT',              'Organization contact relationship', 'CONTACT',               'ORGANIZATION_ROLE',     'A person represents an organization'),
  ('DISTRIBUTION_CHANNEL_RELATIONSHIP', 'Distribution channel relationship', 'DISTRIBUTION_CHANNEL',  'INTERNAL_ORGANIZATION', 'An agent or distributor sells for an internal organization'),
  ('PARTNERSHIP',                       'Partnership',                       'PARTNER',               'INTERNAL_ORGANIZATION', 'A partner works with an internal organization');

-- Party role ids as in Fig 2.5, plus 5 Contoso SUPPLIER.
insert into party_relationship (party_relationship_id, party_relationship_type_id, from_party_role_id, to_party_role_id, from_date, thru_date, comment) values
  -- the same facts as the three 2.5 tables…
  (1,  'EMPLOYMENT',            1,  12, '2018-07-01', '2023-01-01', null),
  (2,  'EMPLOYMENT',            1,  19, '2023-09-01', null,         null),
  (3,  'EMPLOYMENT',            1,  16, '2024-01-01', null,         'DATA ERROR: role 16 is Ben''s CONTACT role'),
  (4,  'CUSTOMER_RELATIONSHIP', 6,  1,  '2021-04-01', null,         null),
  (5,  'CUSTOMER_RELATIONSHIP', 7,  1,  '2021-04-01', null,         null),
  (6,  'CUSTOMER_RELATIONSHIP', 10, 1,  '2020-02-01', null,         null),
  (7,  'CUSTOMER_RELATIONSHIP', 18, 1,  '2023-06-01', null,         null),
  (8,  'ORGANIZATION_ROLLUP',   4,  2,  '2019-03-01', null,         null),
  -- …plus kinds 2.5 had no table for: no schema change needed
  (9,  'SUPPLIER_RELATIONSHIP', 5,  1,  '2016-01-01', null,         'Freight services'),
  (10, 'ORGANIZATION_CONTACT',  16, 5,  '2016-01-01', null,         'Account manager at Contoso');

select setval(pg_get_serial_sequence('party_relationship', 'party_relationship_id'), (select max(party_relationship_id) from party_relationship));

-- ============================================================
-- Table 2.5 — the book's organization-to-organization example
-- ============================================================
-- A second, separate corporate family (ABC) loaded end to end: parties,
-- organizations, roles and relationships. It gives the org chart a real
-- multi-level hierarchy.
--
-- thru_date is exclusive in this repo (the first day no longer valid). The
-- book's inclusive "thru 12/31/2001" is stored as 2002-01-01.

insert into party (party_id, party_kind) values
  (12, 'ORGANIZATION'),   -- ABC Corporation
  (13, 'ORGANIZATION'),   -- ABC Subsidiary
  (14, 'ORGANIZATION'),   -- XYZ Subsidiary
  (15, 'ORGANIZATION'),   -- Customer Service Division
  (16, 'ORGANIZATION'),   -- ACME Company
  (17, 'ORGANIZATION'),   -- Sellers Assistance Corporation
  (18, 'ORGANIZATION');   -- Fantastic Supplies

select setval(pg_get_serial_sequence('party', 'party_id'), (select max(party_id) from party));

insert into organization (party_id, organization_type_id, name) values
  (12, 'CORPORATION',    'ABC Corporation'),
  (13, 'CORPORATION',    'ABC Subsidiary'),
  (14, 'CORPORATION',    'XYZ Subsidiary'),
  (15, 'OTHER_INFORMAL', 'Customer Service Division'),   -- a division is not a legal entity
  (16, 'CORPORATION',    'ACME Company'),
  (17, 'CORPORATION',    'Sellers Assistance Corporation'),
  (18, 'CORPORATION',    'Fantastic Supplies');

insert into party_role (party_role_id, party_id, role_type_id, from_date, thru_date) values
  (30, 12, 'PARENT_ORGANIZATION',   '1998-03-04', null),
  (31, 13, 'SUBSIDIARY',            '1998-03-04', null),         -- used as child AND as parent
  (32, 13, 'INTERNAL_ORGANIZATION', '1999-01-01', null),         -- "to" end of three relationships
  (33, 14, 'SUBSIDIARY',            '1999-07-07', null),
  (34, 15, 'DIVISION',              '2000-01-02', null),
  (35, 16, 'CUSTOMER',              '1999-01-01', null),         -- plain Customer, as the book has it
  (36, 17, 'AGENT',                 '1999-06-01', '2002-01-01'),
  (37, 18, 'SUPPLIER',              '2001-04-05', null);

select setval(pg_get_serial_sequence('party_role', 'party_role_id'), (select max(party_role_id) from party_role));

insert into party_relationship (party_relationship_id, party_relationship_type_id, from_party_role_id, to_party_role_id, from_date, thru_date) values
  (11, 'ORGANIZATION_ROLLUP',               31, 30, '1998-03-04', null),
  (12, 'ORGANIZATION_ROLLUP',               33, 30, '1999-07-07', null),
  (13, 'ORGANIZATION_ROLLUP',               34, 31, '2000-01-02', null),
  (14, 'CUSTOMER_RELATIONSHIP',             35, 32, '1999-01-01', null),
  (15, 'DISTRIBUTION_CHANNEL_RELATIONSHIP', 36, 32, '1999-06-01', '2002-01-01'),
  (16, 'SUPPLIER_RELATIONSHIP',             37, 32, '2001-04-05', null);

select setval(pg_get_serial_sequence('party_relationship', 'party_relationship_id'), (select max(party_relationship_id) from party_relationship));

-- ============================================================
-- Fig 2.7 — Party relationship information
-- ============================================================
insert into priority_type (priority_type_id, description) values
  ('HIGH',   'High'),
  ('MEDIUM', 'Medium'),
  ('LOW',    'Low');

insert into status_type (status_type_id, parent_type_id, description) values
  ('PARTY_RELATIONSHIP_STATUS', null,                        'Party relationship status'),
  ('REL_ACTIVE',                'PARTY_RELATIONSHIP_STATUS', 'Active'),
  ('REL_ON_HOLD',               'PARTY_RELATIONSHIP_STATUS', 'On hold'),
  ('REL_INACTIVE',              'PARTY_RELATIONSHIP_STATUS', 'Inactive');

-- Priority and status for the relationships loaded in 2.6a and Table 2.5.
update party_relationship set priority_type_id = 'HIGH',   status_type_id = 'REL_ACTIVE'   where party_relationship_id in (4, 5, 9);   -- Contoso: customer and supplier
update party_relationship set priority_type_id = 'MEDIUM', status_type_id = 'REL_ACTIVE'   where party_relationship_id in (7, 10, 14); -- Ben, Ben-as-contact, ACME
update party_relationship set priority_type_id = 'LOW',    status_type_id = 'REL_ON_HOLD'  where party_relationship_id = 6;            -- the household
update party_relationship set                              status_type_id = 'REL_ACTIVE'   where party_relationship_id in (2, 8, 11, 12, 13, 16);
update party_relationship set                              status_type_id = 'REL_INACTIVE' where party_relationship_id = 15;           -- agent, ended 2002
-- DATA ERRORS the FKs allow (caught by queries):
update party_relationship set status_type_id = 'REL_ACTIVE'                where party_relationship_id = 1;  -- ended in 2023, still "active"
update party_relationship set status_type_id = 'PARTY_RELATIONSHIP_STATUS' where party_relationship_id = 3;  -- a grouping row used as a status

insert into communication_event (communication_event_id, party_relationship_id, datetime_started, datetime_ended, note) values
  (1, 10, '2024-02-12 09:30+00', '2024-02-12 10:00+00', 'Quarterly freight review call with Ben'),
  (2, 10, '2024-05-20 14:00+00', null,                  'Email from Ben: rate increase notice'),
  (3, 4,  '2024-06-03 11:00+00', '2024-06-03 12:15+00', 'Contract renewal meeting with Contoso purchasing'),
  (4, 14, '1999-02-01 10:00+00', '1999-02-01 10:45+00', 'First sales call with ACME'),
  (5, 15, '2005-03-01 16:00+00', '2005-03-01 16:20+00', 'DATA ERROR: call logged against the agent relationship three years after it ended');

select setval(pg_get_serial_sequence('communication_event', 'communication_event_id'), (select max(communication_event_id) from communication_event));

-- ============================================================
-- Fig 2.8 (part 2) — Postal address information
-- ============================================================
-- Boundary ids from the top block: 1 MX, 6 US, 10 IL, 11 MO, 12 Sangamon Co.,
-- 13 Springfield, 14 Chatham, 15 62704, 16 62707, 17 St. Louis, 18 63101,
-- 20 Jalisco, 21 Guadalajara, 22 44100, 30 Midwest Sales, 31 North America.
insert into geographic_boundary_association (from_geographic_boundary_id, to_geographic_boundary_id) values
  (10, 6), (11, 6),               -- Illinois, Missouri within the US
  (12, 10),                       -- Sangamon County in Illinois
  (13, 12), (13, 10),             -- Springfield within Sangamon County and Illinois
  (14, 12), (14, 10),             -- Chatham within Sangamon County and Illinois
  (15, 13),                       -- 62704 within Springfield
  (16, 13), (16, 14),             -- 62707 crosses Springfield AND Chatham
  (17, 11), (18, 17),             -- St. Louis in Missouri; 63101 within St. Louis
  (20, 1), (21, 20), (22, 21),    -- Jalisco in Mexico; Guadalajara in Jalisco; 44100 in Guadalajara
  (10, 30), (11, 30),             -- the Midwest Sales territory spans Illinois and Missouri
  (6, 31), (1, 31);               -- US and Mexico in the North America region

insert into postal_address (postal_address_id, address1, address2, directions) values
  (1, '742 Evergreen Terrace', null,        null),
  (2, 'Av. Juárez 123',        'Depto. 4',  null),
  (3, '100 Commerce Dr',       'Suite 400', null),
  (4, '55 Warehouse Rd',       null,        'Dock entrance on the north side'),
  (5, '1 Market St',           null,        null),
  (6, 'PO Box 99',             null,        null);   -- DATA ERROR: only linked to a postal code (no city or country)

select setval(pg_get_serial_sequence('postal_address', 'postal_address_id'), (select max(postal_address_id) from postal_address));

-- Each address is linked to its postal code, city, state and country explicitly.
insert into postal_address_boundary (postal_address_id, geographic_boundary_id) values
  (1, 15), (1, 13), (1, 10), (1, 6),   -- 742 Evergreen Terrace, Springfield IL 62704, US
  (2, 22), (2, 21), (2, 20), (2, 1),   -- Av. Juárez, Guadalajara, Jalisco 44100, MX
  (3, 16), (3, 13), (3, 10), (3, 6),   -- Northwind HQ, Springfield IL 62707
  (4, 16), (4, 14), (4, 10), (4, 6),   -- Northwind warehouse, Chatham IL 62707 (same postal code)
  (5, 18), (5, 17), (5, 11), (5, 6),   -- Contoso, St. Louis MO 63101
  (6, 15);

insert into party_postal_address (party_id, postal_address_id, from_date, thru_date, comment) values
  (1, 2, '1990-05-14', '2019-06-15', 'Family home in Guadalajara'),
  (1, 1, '2019-06-15', null,         'Moved on marriage'),
  (8, 1, '2019-06-15', null,         'Household shares Ana''s address'),
  (4, 3, '2010-01-01', null,         'Headquarters'),
  (4, 4, '2015-06-01', null,         'Warehouse'),
  (5, 5, '2016-01-01', null,         null),
  (6, 6, '2010-01-01', null,         null);
