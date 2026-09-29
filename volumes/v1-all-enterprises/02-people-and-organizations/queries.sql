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
