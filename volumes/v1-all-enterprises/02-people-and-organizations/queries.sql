-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/02

-- ============================================================
-- Fig 2.1 — Organization
-- ============================================================

-- name: 2.1 — Every organization with its type and top-level category
select o.name,
       t.description               as type,
       coalesce(p.description, t.description) as category
from organization o
join organization_type t      on t.organization_type_id = o.organization_type_id
left join organization_type p on p.organization_type_id = t.parent_type_id
order by category, o.name;

-- name: 2.1 — Legal organizations missing a federal tax id
select o.name, t.description as type
from organization o
join organization_type t on t.organization_type_id = o.organization_type_id
where t.parent_type_id = 'LEGAL'
  and o.federal_tax_id_num is null;

-- name: 2.1 — Data-quality check: informal organizations that have a tax id (should be empty)
select o.name, o.federal_tax_id_num
from organization o
join organization_type t on t.organization_type_id = o.organization_type_id
where t.parent_type_id = 'INFORMAL'
  and o.federal_tax_id_num is not null;

-- ============================================================
-- Fig 2.2a — Person (flat)
-- ============================================================

-- name: 2.2a — Everyone's current display name
select person_id,
       concat_ws(' ', current_personal_title, current_first_name, current_middle_name, current_last_name, current_suffix) as display_name,
       current_nickname
from person
order by person_id;

-- name: 2.2a — Free-text trouble: how many distinct spellings of gender and marital status?
select 'gender' as attribute, gender as value, count(*) from person group by gender
union all
select 'marital_status', marital_status, count(*) from person group by marital_status
order by attribute, value;

-- name: 2.2a — What was Ana's last name in 2015? (the flat model can't answer; best it can do)
select current_last_name as last_name_today, comment as only_clue
from person
where person_id = 1;
