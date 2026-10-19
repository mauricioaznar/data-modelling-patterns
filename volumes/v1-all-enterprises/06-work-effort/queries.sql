-- Vol 1, Chapter 6: Work Effort — queries
-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/06

-- ============================================================
-- Fig 6.1 — Work requirement
-- ============================================================

-- name: 6.1 — Work requirements as Tables 6.1–6.2 show them: type, dates, and what each needs (a product and how many, a machine, a deliverable)
select r.requirement_id, t.description as requirement_type, r.requirement_creation_date, r.required_by_date,
       r.description, p.name as product, r.quantity, d.name as deliverable, fa.fixed_asset_id, fa.name as fixed_asset
from requirement r
join requirement_type t     on t.requirement_type_id = r.requirement_type_id
join work_requirement w     on w.requirement_id = r.requirement_id
left join product p         on p.product_id = w.product_id
left join deliverable d     on d.deliverable_id = w.deliverable_id
left join fixed_asset fa    on fa.fixed_asset_id = w.fixed_asset_id
where r.requirement_id in (50985, 51245, 51285, 60102, 70485)
order by r.requirement_id;

-- name: 6.1 — Every requirement by its type's group, beside Ch 4's kind: needs for goods and needs for work in one list
select coalesce(g.description, t.description, '(no type)') as type_group, t.description as requirement_type,
       r.requirement_kind, count(*) as requirements
from requirement r
left join requirement_type t on t.requirement_type_id = r.requirement_type_id
left join requirement_type g on g.requirement_type_id = t.parent_type_id
group by 1, 2, 3
order by 1, 2;

-- name: 6.1 — Machines with work waiting on them, and when each is next due for service
select fa.fixed_asset_id, fa.name, fa.date_last_serviced, fa.date_next_service,
       r.requirement_id, r.description, r.required_by_date
from fixed_asset fa
join work_requirement w on w.fixed_asset_id = fa.fixed_asset_id
join requirement r      on r.requirement_id = w.requirement_id
order by fa.fixed_asset_id, r.required_by_date;

-- name: 6.1 — Demand to produce, per product: how many units the production-run needs ask for
select p.name as product, count(*) as needs, sum(r.quantity) as quantity_needed,
       min(r.required_by_date) as first_due
from work_requirement w
join requirement r on r.requirement_id = w.requirement_id
join product p     on p.product_id = w.product_id
where r.requirement_type_id = 'PRODUCTION_RUN'
group by p.name;

-- name: 6.1 — Data-quality check: requirements typed with a grouping row instead of a type of need (should be empty)
select r.requirement_id, r.description, r.requirement_type_id
from requirement r
where exists (select 1 from requirement_type c where c.parent_type_id = r.requirement_type_id);

-- name: 6.1 — Data-quality check: requirements whose type's group contradicts their kind (should be empty)
select r.requirement_id, r.description, r.requirement_kind, r.requirement_type_id, t.parent_type_id as type_group
from requirement r
join requirement_type t on t.requirement_type_id = r.requirement_type_id
where t.parent_type_id is not null
  and t.parent_type_id <> r.requirement_kind || '_REQUIREMENT';

-- name: 6.1 — Data-quality check: work requirements with no type (should be empty)
select r.requirement_id, r.description
from requirement r
where r.requirement_kind = 'WORK' and r.requirement_type_id is null;

-- name: 6.1 — Data-quality check: work_requirement rows that disagree with requirement_kind, either way (should be empty)
select r.requirement_id, r.description, r.requirement_kind,
       case when w.requirement_id is null then 'WORK with no work_requirement row'
            else 'work_requirement row on a ' || r.requirement_kind || ' requirement' end as problem
from requirement r
left join work_requirement w on w.requirement_id = r.requirement_id
where (r.requirement_kind = 'WORK') <> (w.requirement_id is not null);

-- name: 6.1 — Data-quality check: maintenance or repair needs that name no machine (should be empty; Ch 4's "Repair 14 PCs" shows why: NOTES, point 13)
select r.requirement_id, r.description, r.requirement_type_id
from requirement r
join work_requirement w on w.requirement_id = r.requirement_id
where r.requirement_type_id in ('MAINTENANCE', 'REPAIR') and w.fixed_asset_id is null;

-- name: 6.1 — Data-quality check: production-run needs missing the product or the quantity (should be empty)
select r.requirement_id, r.description, w.product_id, r.quantity
from requirement r
join work_requirement w on w.requirement_id = r.requirement_id
where r.requirement_type_id = 'PRODUCTION_RUN' and (w.product_id is null or r.quantity is null);

-- name: 6.1 — Data-quality check: fixed assets with no acquisition date (should be empty)
select fixed_asset_id, name
from fixed_asset
where date_acquired is null;

-- ============================================================
-- Fig 6.2 — Work requirement roles
-- ============================================================

-- name: 6.2 — Table 6.3: every party on work requirements 50985 and 60102, in which role and when
select ro.requirement_id, n.name as party, t.description as role_type, ro.from_date,
       ro.thru_date - 1 as last_day, ro.comment
from requirement_role ro
join party_display_name n     on n.party_id = ro.party_id
join requirement_role_type t  on t.requirement_role_type_id = ro.requirement_role_type_id
where ro.requirement_id in (50985, 60102)
order by ro.requirement_id, ro.from_date, ro.requirement_role_type_id;

-- name: 6.2 — Who was responsible for 50985 on a given day (Jan 10, 2001: Dick Jones, covering)
select ro.requirement_id, n.name as responsible
from requirement_role ro
join party_display_name n on n.party_id = ro.party_id
where ro.requirement_id = 50985 and ro.requirement_role_type_id = 'RESPONSIBLE_FOR'
  and ro.from_date <= date '2001-01-10' and (ro.thru_date is null or ro.thru_date > date '2001-01-10');

-- name: 6.2 — Each work requirement's people today: whose need, who keyed it, who answers for it, who authorised it
select r.requirement_id, r.description,
       string_agg(distinct case when ro.requirement_role_type_id = 'CREATED_FOR'     then n.name end, ', ') as created_for,
       string_agg(distinct case when ro.requirement_role_type_id = 'CREATED_BY'      then n.name end, ', ') as created_by,
       string_agg(distinct case when ro.requirement_role_type_id = 'RESPONSIBLE_FOR' then n.name end, ', ') as responsible,
       string_agg(distinct case when ro.requirement_role_type_id = 'AUTHORIZED_BY'   then n.name end, ', ') as authorized_by
from requirement r
join requirement_role ro  on ro.requirement_id = r.requirement_id
                         and ro.from_date <= current_date and (ro.thru_date is null or ro.thru_date > current_date)
join party_display_name n on n.party_id = ro.party_id
where r.requirement_kind = 'WORK'
group by r.requirement_id, r.description
order by r.requirement_id;

-- name: 6.2 — Review: roles dated before their requirement was created (Table 6.3's 60102: NOTES, point 5)
select ro.requirement_id, r.requirement_creation_date, n.name as party, ro.requirement_role_type_id, ro.from_date
from requirement_role ro
join requirement r        on r.requirement_id = ro.requirement_id
join party_display_name n on n.party_id = ro.party_id
where ro.from_date < r.requirement_creation_date
order by ro.requirement_id, ro.from_date;

-- name: 6.2 — Data-quality check: the same party in the same role on the same requirement from the same day, twice (should be empty)
select requirement_id, party_id, requirement_role_type_id, from_date, count(*) as rows
from requirement_role
group by requirement_id, party_id, requirement_role_type_id, from_date
having count(*) > 1;

-- name: 6.2 — Data-quality check: two responsible parties at once on one requirement (should be empty)
select a.requirement_id, a.party_id as one, b.party_id as other,
       greatest(a.from_date, b.from_date) as overlap_from
from requirement_role a
join requirement_role b on b.requirement_id = a.requirement_id
                       and b.requirement_role_id > a.requirement_role_id
where a.requirement_role_type_id = 'RESPONSIBLE_FOR' and b.requirement_role_type_id = 'RESPONSIBLE_FOR'
  and a.from_date < coalesce(b.thru_date, 'infinity') and b.from_date < coalesce(a.thru_date, 'infinity');
