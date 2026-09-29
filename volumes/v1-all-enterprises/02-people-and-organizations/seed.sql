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
