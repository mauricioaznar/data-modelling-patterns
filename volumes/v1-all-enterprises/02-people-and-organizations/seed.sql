-- Vol 1, Chapter 2 seed data.
-- Aim for data that exercises the tricky cases (history, overlapping roles,
-- hierarchies), not just the happy path.

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

insert into organization (organization_id, organization_type_id, name, federal_tax_id_num) values
  (1, 'CORPORATION',       'Northwind Traders Inc.',      '12-3456789'),
  (2, 'CORPORATION',       'Contoso Logistics LLC',       null),          -- legal, but tax id not yet captured
  (3, 'GOVERNMENT_AGENCY', 'Springfield Water Authority', '98-7654321'),
  (4, 'TEAM',              'Northwind Platform Team',     null),
  (5, 'FAMILY',            'The García-López Family',     null),
  (6, 'OTHER_INFORMAL',    'Saturday Book Club',          '11-1111111');  -- informal WITH a tax id: data error the schema allows

select setval(pg_get_serial_sequence('organization', 'organization_id'), (select max(organization_id) from organization));

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
-- Same three people as 2.2a, but now with their history.

insert into gender_type (gender_type_id, description) values
  ('FEMALE',        'Female'),
  ('MALE',          'Male'),
  ('NON_BINARY',    'Non-binary'),
  ('NOT_DISCLOSED', 'Prefer not to say');   -- needed because gender is mandatory

insert into person (person_id, gender_type_id, birth_date, mothers_maiden_name, social_security_no, total_years_work_experience, comment) values
  (1, 'FEMALE', '1990-05-14', 'Hernández', '123-45-6789', 12, null),
  (2, 'MALE',   '1985-11-02', 'Adeyemi',   null,          16, null),
  (3, 'FEMALE', '2001-01-30', null,        null,          2,  null);

select setval(pg_get_serial_sequence('person', 'person_id'), (select max(person_id) from person));

-- Names -------------------------------------------------------
insert into person_name_type (person_name_type_id, description) values
  ('PERSONAL_TITLE', 'Personal title'),
  ('FIRST',          'First name'),
  ('MIDDLE',         'Middle name'),
  ('LAST',           'Last name'),
  ('SUFFIX',         'Suffix'),
  ('NICKNAME',       'Nickname');

insert into person_name (person_id, name_seq_id, person_name_type_id, from_date, thru_date, name) values
  -- Ana: born García, became López on marriage, Dr. after her PhD
  (1, 1, 'FIRST',          '1990-05-14', null,         'Ana'),
  (1, 2, 'MIDDLE',         '1990-05-14', null,         'Lucía'),
  (1, 3, 'LAST',           '1990-05-14', '2019-06-15', 'García'),
  (1, 4, 'LAST',           '2019-06-15', null,         'López'),
  (1, 5, 'NICKNAME',       '1995-01-01', null,         'Anita'),
  (1, 6, 'PERSONAL_TITLE', '2018-07-01', null,         'Dr.'),
  -- Ben
  (2, 1, 'PERSONAL_TITLE', '1985-11-02', null,         'Mr.'),
  (2, 2, 'FIRST',          '1985-11-02', null,         'Ben'),
  (2, 3, 'LAST',           '1985-11-02', null,         'Okafor'),
  (2, 4, 'SUFFIX',         '1985-11-02', null,         'Jr.'),
  -- Chloe: dropped her childhood nickname in 2020
  (3, 1, 'FIRST',          '2001-01-30', null,         'Chloe'),
  (3, 2, 'LAST',           '2001-01-30', null,         'Martin'),
  (3, 3, 'NICKNAME',       '2010-01-01', '2020-01-01', 'Coco');

-- Marital status ----------------------------------------------
insert into marital_status_type (marital_status_type_id, description) values
  ('SINGLE',   'Single'),
  ('MARRIED',  'Married'),
  ('DIVORCED', 'Divorced'),
  ('WIDOWED',  'Widowed');

-- Chloe has no rows: her status is unknown, which is not the same as single.
insert into marital_status (person_id, marital_status_type_id, from_date, thru_date) values
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

insert into physical_characteristic (person_id, physical_characteristic_type_id, from_date, thru_date, value) values
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

insert into citizenship (person_id, country_id, from_date, thru_date) values
  (1, 'MX', '1990-05-14', null),
  (1, 'ES', '2021-02-10', null),    -- dual citizen
  (2, 'NG', '1985-11-02', null),
  (2, 'GB', '2010-06-01', null),    -- dual citizen
  (3, 'FR', '2001-01-30', null);    -- citizen with no passport

insert into passport (passport_id, person_id, country_id, citizenship_from_date, passport_num, issue_date, expiration_date) values
  (1, 1, 'MX', '1990-05-14', 'G11111111', '2014-03-01', '2020-03-01'),   -- expired, replaced
  (2, 1, 'MX', '1990-05-14', 'G22222222', '2020-02-15', '2030-02-15'),
  (3, 1, 'ES', '2021-02-10', 'X1234567',  '2021-03-01', '2031-03-01'),
  (4, 2, 'NG', '1985-11-02', 'A00123456', '2015-01-10', '2020-01-10'),   -- expired, never renewed
  (5, 2, 'GB', '2010-06-01', '555000111', '2019-07-15', '2029-07-15');

select setval(pg_get_serial_sequence('passport', 'passport_id'), (select max(passport_id) from passport));
