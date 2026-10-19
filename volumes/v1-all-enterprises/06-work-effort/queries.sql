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

-- ============================================================
-- Fig 6.3a — Work effort generation
-- ============================================================

-- name: 6.3a — Table 6.4: work efforts and the work requirements each one fills
select we.work_effort_id, we.name, we.description, we.scheduled_start_date,
       string_agg(distinct r.requirement_id || ' ' || r.description, '; ') as fills
from work_effort we
join work_requirement_fulfillment f on f.work_effort_id = we.work_effort_id
join requirement r                  on r.requirement_id = f.requirement_id
group by we.work_effort_id, we.name, we.description, we.scheduled_start_date
order by we.scheduled_start_date, we.work_effort_id;

-- name: 6.3a — Table 6.5: work efforts started from order lines, with the need each line is committed to
select we.work_effort_id, we.name, we.description, we.scheduled_start_date,
       o.order_id, oi.order_item_seq_id, p.name as ordered, oi.quantity as ordered_quantity,
       r.requirement_id, r.description as requirement
from work_order_item_fulfillment f
join work_effort we                          on we.work_effort_id = f.work_effort_id
join order_item oi                           on oi.order_item_id = f.order_item_id
join "order" o                               on o.order_id = oi.order_id
left join product p                          on p.product_id = oi.product_id
left join order_requirement_commitment c     on c.order_item_id = oi.order_item_id
left join requirement r                      on r.requirement_id = c.requirement_id
where oi.order_item_kind = 'WORK'
order by we.scheduled_start_date;

-- name: 6.3a — All the work behind order 23500, by either path: straight from a WORK line, or through the need a line is committed to
select oi.order_item_id, 'direct (work order item fulfillment)' as path, we.work_effort_id, we.name
from order_item oi
join work_order_item_fulfillment f on f.order_item_id = oi.order_item_id
join work_effort we                on we.work_effort_id = f.work_effort_id
where oi.order_id = 23500
union
select oi.order_item_id, 'via requirement ' || c.requirement_id, we.work_effort_id, we.name
from order_item oi
join order_requirement_commitment c  on c.order_item_id = oi.order_item_id
join work_requirement_fulfillment f  on f.requirement_id = c.requirement_id
join work_effort we                  on we.work_effort_id = f.work_effort_id
where oi.order_id = 23500
order by 2, 3;

-- name: 6.3a — Does the planned output cover each production need? Runs that fill several needs are counted in full against each, so they're flagged
select r.requirement_id, r.quantity as needed,
       string_agg(pr.work_effort_id::text, ', ' order by pr.work_effort_id) as runs,
       sum(pr.quantity_to_produce) as planned,
       bool_or((select count(*) from work_requirement_fulfillment f2 where f2.work_effort_id = pr.work_effort_id) > 1) as a_run_is_shared
from requirement r
join (select distinct work_effort_id, requirement_id from work_requirement_fulfillment) f on f.requirement_id = r.requirement_id
join production_run pr on pr.work_effort_id = f.work_effort_id
where r.requirement_type_id = 'PRODUCTION_RUN'
group by r.requirement_id, r.quantity
order by r.requirement_id;

-- name: 6.3a — Does the planned output cover each WORK order line (Table 6.5: 1,500 + 1,000 for 2,500)?
select oi.order_item_id, p.name as product, oi.quantity as ordered,
       count(pr.work_effort_id) as runs, sum(pr.quantity_to_produce) as planned
from order_item oi
join product p                     on p.product_id = oi.product_id
join work_order_item_fulfillment f on f.order_item_id = oi.order_item_id
join production_run pr             on pr.work_effort_id = f.work_effort_id
where oi.order_item_kind = 'WORK'
group by oi.order_item_id, p.name, oi.quantity;

-- name: 6.3a — Production yield for the runs already done: produced, rejected, and the reject rate
select we.work_effort_id, we.description, pr.quantity_to_produce, pr.quantity_produced, pr.quantity_rejected,
       round(100.0 * pr.quantity_rejected / nullif(pr.quantity_produced + pr.quantity_rejected, 0), 1) as reject_pct,
       we.actual_hours
from production_run pr
join work_effort we on we.work_effort_id = pr.work_effort_id
where pr.quantity_produced is not null
order by we.actual_start_datetime;

-- name: 6.3a — Every work effort by level and by purpose: the two subtype sets are independent
select coalesce(pt.description, '(no purpose)') as purpose, t.description as level, count(*) as efforts
from work_effort we
join work_effort_type t               on t.work_effort_type_id = we.work_effort_type_id
left join work_effort_purpose_type pt on pt.work_effort_purpose_type_id = we.work_effort_purpose_type_id
group by 1, 2
order by 1, 2;

-- name: 6.3a — Where the work happens, and how long it took against the plan
select we.work_effort_id, we.name, coalesce(f.description, '(the parent''s site, or it doesn''t matter)') as performed_at,
       we.scheduled_start_date, we.scheduled_completion_date,
       we.actual_start_datetime, we.actual_completion_datetime, we.actual_hours
from work_effort we
left join facility f on f.facility_id = we.facility_id
where we.work_effort_id >= 28000
order by we.scheduled_start_date;

-- name: 6.3a — Review: work scheduled to start after the need it fills was due (Table 6.4's 32898: NOTES, point 9)
select we.work_effort_id, we.name, we.scheduled_start_date, r.requirement_id, r.required_by_date,
       we.scheduled_start_date - r.required_by_date as days_late
from work_requirement_fulfillment f
join work_effort we on we.work_effort_id = f.work_effort_id
join requirement r  on r.requirement_id = f.requirement_id
where we.scheduled_start_date > r.required_by_date
group by we.work_effort_id, we.name, we.scheduled_start_date, r.requirement_id, r.required_by_date;

-- name: 6.3a — Data-quality check: production_run rows that disagree with the effort's purpose, either way (should be empty)
select we.work_effort_id, we.name, we.work_effort_purpose_type_id,
       case when pr.work_effort_id is null then 'PRODUCTION_RUN with no production_run row'
            else 'production_run row on a ' || coalesce(we.work_effort_purpose_type_id, 'purposeless') || ' effort' end as problem
from work_effort we
left join production_run pr on pr.work_effort_id = we.work_effort_id
where (we.work_effort_purpose_type_id is not distinct from 'PRODUCTION_RUN') <> (pr.work_effort_id is not null);

-- name: 6.3a — Data-quality check: work order item fulfillments on a line that isn't a WORK item (should be empty)
select f.work_effort_id, f.order_item_id, oi.order_id, oi.order_item_kind, oi.item_description
from work_order_item_fulfillment f
join order_item oi on oi.order_item_id = f.order_item_id
where oi.order_item_kind <> 'WORK';

-- name: 6.3a — Data-quality check: the same effort linked to the same need or order line twice (should be empty)
select 'work requirement' as link, work_effort_id, requirement_id as linked_to, count(*) as rows
from work_requirement_fulfillment
group by work_effort_id, requirement_id
having count(*) > 1
union all
select 'work order item', work_effort_id, order_item_id, count(*)
from work_order_item_fulfillment
group by work_effort_id, order_item_id
having count(*) > 1;
