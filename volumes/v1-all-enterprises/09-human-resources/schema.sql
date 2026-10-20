-- Vol 1, Chapter 9: Human Resources
-- Built up one figure at a time; each section is headed by the figure it implements.
-- Fig 9.1 (the standard emp dept model) is the naive model the chapter replaces:
-- transcribed in NOTES, not built.

-- ============================================================
-- Fig 9.2 — Employment
-- ============================================================
-- Nothing new to store: EMPLOYMENT is Ch 2's party_relationship typed
-- EMPLOYMENT (2.6a), from the internal organization's role to the employee's,
-- with 2.7's status. The view names both parties, so later figures
-- (fulfillment, pay, benefits) can ask "who employed whom, when" without the
-- role joins. Ch 2's 2.5 `employment` table is Ch 2's comparison and stays
-- unused (NOTES, point 2).
create view employment_relationship as
select r.party_relationship_id,
       er.party_id          as employer_party_id,
       ee.party_id          as employee_party_id,
       r.from_party_role_id as employer_party_role_id,
       r.to_party_role_id   as employee_party_role_id,
       r.from_date,
       r.thru_date,
       r.status_type_id,
       r.comment
from party_relationship r
join party_role er on er.party_role_id = r.from_party_role_id
join party_role ee on ee.party_role_id = r.to_party_role_id
where r.party_relationship_type_id = 'EMPLOYMENT';
