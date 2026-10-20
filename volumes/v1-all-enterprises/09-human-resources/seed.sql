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
