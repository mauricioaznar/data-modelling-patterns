-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/09

-- ============================================================
-- Fig 9.2 — Employment
-- ============================================================

-- name: 9.2 — Who is employed by which internal organization, since when, and in what state
select e.party_relationship_id, er.name as employer, ee.name as employee,
       e.from_date, e.thru_date, s.description as status
from employment_relationship e
join party_display_name er on er.party_id = e.employer_party_id
join party_display_name ee on ee.party_id = e.employee_party_id
left join status_type s    on s.status_type_id = e.status_type_id
order by employee, e.from_date;

-- name: 9.2 — Data-quality check: one person employed twice by one employer over overlapping dates (should be empty)
select a.party_relationship_id, b.party_relationship_id as overlaps_with,
       ee.name as employee, a.from_date, a.thru_date, b.from_date as other_from
from employment_relationship a
join employment_relationship b
  on  b.employee_party_id = a.employee_party_id
  and b.employer_party_id = a.employer_party_id
  and b.party_relationship_id > a.party_relationship_id
  and b.from_date < coalesce(a.thru_date, 'infinity')
  and a.from_date < coalesce(b.thru_date, 'infinity')
join party_display_name ee on ee.party_id = a.employee_party_id;
