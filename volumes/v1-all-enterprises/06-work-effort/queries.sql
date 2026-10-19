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
select coalesce(pt.description, '(no purpose)') as purpose, coalesce(lv.description, t.description) as level, count(*) as efforts
from work_effort we
join work_effort_type t               on t.work_effort_type_id = we.work_effort_type_id
left join work_effort_type lv         on lv.work_effort_type_id = t.parent_type_id   -- Fig 6.4: a kind of work sits under its level
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

-- ============================================================
-- Fig 6.4 — Work effort breakdown
-- ============================================================

-- name: 6.4 — Table 6.6: each effort with its level, the efforts it is part of, the standard hours for its kind of work, its schedule and estimate
select we.work_effort_id, coalesce(lv.description, t.description) as level, we.description,
       string_agg(a.from_work_effort_id || ' ' || p.name, '; ' order by a.from_work_effort_id) as part_of,
       t.standard_work_hours, we.scheduled_start_date, we.scheduled_completion_date, we.estimated_hours
from work_effort we
join work_effort_type t       on t.work_effort_type_id = we.work_effort_type_id
left join work_effort_type lv on lv.work_effort_type_id = t.parent_type_id
left join work_effort_association a on a.to_work_effort_id = we.work_effort_id and a.work_effort_association_type_id = 'BREAKDOWN'
                                   and a.from_work_effort_id <> 3454589   -- leave out the bad cycle row
left join work_effort p       on p.work_effort_id = a.from_work_effort_id
where we.work_effort_id in (28045, 120001, 120002, 120003, 120004, 3454587, 3454588, 3454589)
group by we.work_effort_id, lv.description, t.description, we.description, t.standard_work_hours,
         we.scheduled_start_date, we.scheduled_completion_date, we.estimated_hours
order by we.work_effort_id;

-- name: 6.4 — Production run #1 broken down, level by level, with the estimate of each part (the walk stops at depth 5, so a cycle can't run forever)
with recursive tree (work_effort_id, depth, path) as (
  select 28045, 0, '28045'
  union all
  select a.to_work_effort_id, t.depth + 1, t.path || ' > ' || a.to_work_effort_id
  from tree t
  join work_effort_association a on a.from_work_effort_id = t.work_effort_id and a.work_effort_association_type_id = 'BREAKDOWN'
  where t.depth < 5 and a.to_work_effort_id <> 28045
)
select repeat('  ', t.depth) || we.description as effort, t.path, we.estimated_hours
from tree t
join work_effort we on we.work_effort_id = t.work_effort_id
order by t.path;

-- name: 6.4 — Shared parts: efforts that belong to more than one parent (Table 6.6's set-up serves both runs)
select we.work_effort_id, we.description, count(*) as parents,
       string_agg(p.work_effort_id || ' ' || p.name, '; ' order by p.work_effort_id) as part_of
from work_effort_association a
join work_effort we on we.work_effort_id = a.to_work_effort_id
join work_effort p  on p.work_effort_id = a.from_work_effort_id
where a.work_effort_association_type_id = 'BREAKDOWN'
group by we.work_effort_id, we.description
having count(*) > 1;

-- name: 6.4 — What each effort waits for, and what runs alongside it (a concurrency read from both ends)
select we.work_effort_id, we.description, 'waits for' as dependency, o.work_effort_id as other, o.description as other_effort
from work_effort_association a
join work_effort we on we.work_effort_id = a.to_work_effort_id
join work_effort o  on o.work_effort_id = a.from_work_effort_id
where a.work_effort_association_type_id = 'PRECEDENCY'
union all
select e.work_effort_id, e.description, 'runs alongside', o.work_effort_id, o.description
from work_effort_association a
cross join lateral (values (a.from_work_effort_id, a.to_work_effort_id), (a.to_work_effort_id, a.from_work_effort_id)) as ends (this_id, other_id)
join work_effort e on e.work_effort_id = ends.this_id
join work_effort o on o.work_effort_id = ends.other_id
where a.work_effort_association_type_id = 'CONCURRENCY'
order by 1, 3;

-- name: 6.4 — Estimates against the standard for each kind of work: which efforts were planned below standard, and by how much
select we.work_effort_id, we.description, t.description as kind_of_work, t.standard_work_hours, we.estimated_hours,
       we.estimated_hours - t.standard_work_hours as against_standard
from work_effort we
join work_effort_type t on t.work_effort_type_id = we.work_effort_type_id
where t.standard_work_hours is not null
order by we.work_effort_id;

-- name: 6.4 — Work done again: each redo beside the effort it redoes
select r.work_effort_id as redo, r.description, r.scheduled_start_date,
       o.work_effort_id as redoes, o.description as original, o.scheduled_start_date as original_start
from work_effort r
join work_effort o on o.work_effort_id = r.version_of_work_effort_id;

-- name: 6.4 — Data-quality check: associations typed with the DEPENDENCY grouping row instead of precedency or concurrency (should be empty)
select a.work_effort_association_id, a.from_work_effort_id, a.to_work_effort_id, a.work_effort_association_type_id
from work_effort_association a
where exists (select 1 from work_effort_association_type c where c.parent_type_id = a.work_effort_association_type_id);

-- name: 6.4 — Data-quality check: efforts that end up inside their own breakdown, a cycle (should be empty)
with recursive below (top_id, work_effort_id, depth) as (
  select from_work_effort_id, to_work_effort_id, 1
  from work_effort_association where work_effort_association_type_id = 'BREAKDOWN'
  union all
  select b.top_id, a.to_work_effort_id, b.depth + 1
  from below b
  join work_effort_association a on a.from_work_effort_id = b.work_effort_id and a.work_effort_association_type_id = 'BREAKDOWN'
  where b.depth < 10 and b.work_effort_id <> b.top_id
)
select distinct b.top_id as work_effort_id, we.description
from below b
join work_effort we on we.work_effort_id = b.top_id
where b.work_effort_id = b.top_id;

-- name: 6.4 — Data-quality check: precedencies whose second effort is scheduled to start before the first is scheduled to finish (should be empty)
select a.from_work_effort_id as first_id, f.description as first_effort, f.scheduled_completion_date as first_finishes,
       a.to_work_effort_id as then_id, t.description as then_effort, t.scheduled_start_date as then_starts
from work_effort_association a
join work_effort f on f.work_effort_id = a.from_work_effort_id
join work_effort t on t.work_effort_id = a.to_work_effort_id
where a.work_effort_association_type_id = 'PRECEDENCY'
  and t.scheduled_start_date < f.scheduled_completion_date;

-- ============================================================
-- Fig 6.5 — Work effort party assignment
-- ============================================================

-- name: 6.5 — Table 6.7: who is assigned to the sales and marketing plan and its parts, as what, when (thru shown inclusive)
select a.work_effort_id, we.description as work_effort, n.name as party, n.party_kind, rt.description as role,
       a.from_date, a.thru_date - 1 as thru_inclusive, f.description as at_facility, a.comment
from work_effort_party_assignment a
join work_effort we           on we.work_effort_id = a.work_effort_id
join party_display_name n     on n.party_id = a.party_id
join work_effort_role_type rt on rt.work_effort_role_type_id = a.work_effort_role_type_id
left join facility f          on f.facility_id = a.facility_id
order by a.work_effort_id desc, a.from_date, n.name;

-- name: 6.5 — Who is working on the plan (39409) or any of its parts on Aug 20, 2001? John Smith is on vacation; Jane Smith covers
with recursive parts (work_effort_id) as (
  select 39409
  union
  select a.to_work_effort_id
  from parts p
  join work_effort_association a on a.from_work_effort_id = p.work_effort_id and a.work_effort_association_type_id = 'BREAKDOWN'
)
select n.name as party, rt.description as role, we.description as work_effort, a.from_date, a.thru_date
from work_effort_party_assignment a
join parts p                  on p.work_effort_id = a.work_effort_id
join work_effort we           on we.work_effort_id = a.work_effort_id
join party_display_name n     on n.party_id = a.party_id
join work_effort_role_type rt on rt.work_effort_role_type_id = a.work_effort_role_type_id
where a.from_date <= date '2001-08-20' and (a.thru_date is null or a.thru_date > date '2001-08-20')
  and a.work_effort_party_assignment_id <> (select max(work_effort_party_assignment_id) from work_effort_party_assignment where party_id = 54)   -- leave out the bad overlap row
order by n.name;

-- name: 6.5 — Table 6.8: who can manage a project, best rated first, and what each manages today (Jan 15, 2001)
select n.name as party, s.years_experience, s.rating,
       string_agg(we.description, '; ') as managing_now
from party_skill s
join party_display_name n on n.party_id = s.party_id
left join work_effort_party_assignment a on a.party_id = s.party_id and a.work_effort_role_type_id = 'PROJECT_MANAGER'
                                        and a.from_date <= date '2001-01-15' and (a.thru_date is null or a.thru_date > date '2001-01-15')
left join work_effort we  on we.work_effort_id = a.work_effort_id
where s.skill_type_id = 'PROJECT_MANAGEMENT'
  and not (s.party_id = 56 and s.years_experience = 15)   -- leave out the bad duplicate row
group by n.name, s.years_experience, s.rating
order by s.rating desc, s.years_experience desc;

-- name: 6.5 — Skills per party: people and firms alike (why it's PARTY SKILL, not PERSON SKILL)
select n.name as party, n.party_kind, st.description as skill, s.years_experience, s.rating
from party_skill s
join party_display_name n on n.party_id = s.party_id
join skill_type st        on st.skill_type_id = s.skill_type_id
order by n.party_kind, n.name, s.rating desc;

-- name: 6.5 — Table 6.9: each effort's status history, and its current status (the latest; a status with no time counts only when it's the only one)
select ws.work_effort_id, we.description, t.description as status, ws.status_datetime,
       ws.work_effort_status_id = (select s2.work_effort_status_id from work_effort_status s2
                                   where s2.work_effort_id = ws.work_effort_id
                                   order by s2.status_datetime desc nulls last limit 1) as is_current
from work_effort_status ws
join work_effort we  on we.work_effort_id = ws.work_effort_id
join status_type t   on t.status_type_id = ws.status_type_id
where ws.work_effort_id in (28045, 120001, 120002, 120003, 120004)
order by ws.work_effort_id, ws.status_datetime nulls first;

-- name: 6.5 — How long each activity took, from its status events, against its estimate (120001 took one hour of a 20-hour estimate)
select we.work_effort_id, we.description, s.status_datetime as started, c.status_datetime as completed,
       round(extract(epoch from c.status_datetime - s.status_datetime) / 3600, 1) as hours_elapsed, we.estimated_hours
from work_effort we
join work_effort_status s on s.work_effort_id = we.work_effort_id and s.status_type_id = 'WORK_STARTED'
join work_effort_status c on c.work_effort_id = we.work_effort_id and c.status_type_id = 'WORK_COMPLETED'
order by we.work_effort_id;

-- name: 6.5 — Data-quality check: one party in the same role on the same effort for overlapping periods (should be empty)
select a.work_effort_id, n.name as party, a.work_effort_role_type_id,
       a.from_date, a.thru_date, b.from_date as other_from, b.thru_date as other_thru
from work_effort_party_assignment a
join work_effort_party_assignment b on b.work_effort_id = a.work_effort_id and b.party_id = a.party_id
                                   and b.work_effort_role_type_id = a.work_effort_role_type_id
                                   and b.work_effort_party_assignment_id > a.work_effort_party_assignment_id
join party_display_name n on n.party_id = a.party_id
where a.from_date < coalesce(b.thru_date, 'infinity') and b.from_date < coalesce(a.thru_date, 'infinity');

-- name: 6.5 — Data-quality check: a party with the same skill twice (should be empty)
select s.party_id, n.name, s.skill_type_id, count(*) as rows
from party_skill s
join party_display_name n on n.party_id = s.party_id
group by s.party_id, n.name, s.skill_type_id
having count(*) > 1;

-- name: 6.5 — Data-quality check: work effort statuses that aren't a work effort status type, a grouping row included (should be empty)
select ws.work_effort_status_id, ws.work_effort_id, ws.status_type_id
from work_effort_status ws
join status_type t on t.status_type_id = ws.status_type_id
where t.parent_type_id is distinct from 'WORK_EFFORT_STATUS';

-- name: 6.5 — Data-quality check: the same status twice for one effort, the book's key (should be empty)
select work_effort_id, status_type_id, count(*) as rows
from work_effort_status
group by work_effort_id, status_type_id
having count(*) > 1;

-- name: 6.5 — Data-quality check: efforts completed before they started (should be empty)
select s.work_effort_id, s.status_datetime as started, c.status_datetime as completed
from work_effort_status s
join work_effort_status c on c.work_effort_id = s.work_effort_id and c.status_type_id = 'WORK_COMPLETED'
where s.status_type_id = 'WORK_STARTED'
  and c.status_datetime < s.status_datetime;

-- ============================================================
-- Fig 6.6 — Work effort time tracking
-- ============================================================

-- name: 6.6 — Table 6.10: each timesheet, its worker and its time entries (thru shown inclusive)
select ts.timesheet_id, ts.from_date, ts.thru_date - 1 as thru_inclusive, n.name as party, r.role_type_id as as_role,
       te.work_effort_id, we.description as work_effort,
       te.from_datetime::date as entry_from, (te.thru_datetime - interval '1 day')::date as entry_thru, te.hours
from timesheet ts
join party_role r         on r.party_role_id = ts.party_role_id
join party_display_name n on n.party_id = r.party_id
join time_entry te        on te.timesheet_id = ts.timesheet_id
join work_effort we       on we.work_effort_id = te.work_effort_id
where te.time_entry_id not in (6, 7)   -- leave out our two bad entries
order by ts.from_date, ts.timesheet_id, te.from_datetime;

-- name: 6.6 — Hours spent on the sales and marketing plan, part by part, and in total (time is booked on the parts, never on 39409 itself)
with recursive parts (work_effort_id) as (
  select 39409
  union
  select a.to_work_effort_id
  from parts p
  join work_effort_association a on a.from_work_effort_id = p.work_effort_id and a.work_effort_association_type_id = 'BREAKDOWN'
)
select coalesce(we.work_effort_id::text, 'total') as work_effort_id, case when grouping(we.work_effort_id) = 1 then 'all of 39409' else min(we.description) end as work_effort,
       sum(te.hours) as hours
from parts p
join time_entry te  on te.work_effort_id = p.work_effort_id
join work_effort we on we.work_effort_id = p.work_effort_id
group by rollup (we.work_effort_id)
order by we.work_effort_id nulls last;

-- name: 6.6 — Each timesheet's total hours and who else is on it (approver, who keyed it in)
select ts.timesheet_id, n.name as worker, ts.from_date, ts.thru_date - 1 as thru_inclusive,
       (select sum(hours) from time_entry te where te.timesheet_id = ts.timesheet_id) as hours,
       string_agg(rt.description || ': ' || o.name, '; ' order by rt.description, o.name) as others
from timesheet ts
join party_role r                  on r.party_role_id = ts.party_role_id
join party_display_name n          on n.party_id = r.party_id
left join timesheet_role tr        on tr.timesheet_id = ts.timesheet_id
left join timesheet_role_type rt   on rt.timesheet_role_type_id = tr.timesheet_role_type_id
left join party_display_name o     on o.party_id = tr.party_id
group by ts.timesheet_id, n.name, ts.from_date, ts.thru_date
order by ts.from_date;

-- name: 6.6 — Review: time booked with no assignment covering it, on the effort or on any effort it is part of (NOTES, point 24)
with recursive up (work_effort_id, ancestor_id) as (
  select work_effort_id, work_effort_id from work_effort
  union
  select u.work_effort_id, a.from_work_effort_id
  from up u
  join work_effort_association a on a.to_work_effort_id = u.ancestor_id and a.work_effort_association_type_id = 'BREAKDOWN'
)
select te.time_entry_id, n.name as party, te.work_effort_id, we.description, te.from_datetime::date as entry_from,
       (te.thru_datetime - interval '1 day')::date as entry_thru, te.hours
from time_entry te
join timesheet ts         on ts.timesheet_id = te.timesheet_id
join party_role r         on r.party_role_id = ts.party_role_id
join party_display_name n on n.party_id = r.party_id
join work_effort we       on we.work_effort_id = te.work_effort_id
where not exists (
  select 1
  from up u
  join work_effort_party_assignment a on a.work_effort_id = u.ancestor_id
  where u.work_effort_id = te.work_effort_id
    and a.party_id = r.party_id
    and a.from_date <= te.from_datetime::date
    and (a.thru_date is null or a.thru_date >= te.thru_datetime::date))
order by te.from_datetime;

-- name: 6.6 — Data-quality check: timesheets for a party role that isn't a worker (employee or contractor) (should be empty)
select ts.timesheet_id, r.party_role_id, r.role_type_id, n.name
from timesheet ts
join party_role r         on r.party_role_id = ts.party_role_id
join party_display_name n on n.party_id = r.party_id
where not exists (select 1 from role_type_ancestor a where a.role_type_id = r.role_type_id and a.ancestor_id = 'WORKER');

-- name: 6.6 — Data-quality check: time entries outside their timesheet's period (should be empty)
select te.time_entry_id, te.timesheet_id, ts.from_date, ts.thru_date, te.from_datetime, te.thru_datetime
from time_entry te
join timesheet ts on ts.timesheet_id = te.timesheet_id
where te.from_datetime::date < ts.from_date
   or te.thru_datetime::date > ts.thru_date;

-- name: 6.6 — Data-quality check: time entries with more hours than the time between their from and thru (should be empty)
select te.time_entry_id, te.timesheet_id, te.from_datetime, te.thru_datetime, te.hours,
       extract(epoch from te.thru_datetime - te.from_datetime) / 3600 as hours_available
from time_entry te
where te.hours > extract(epoch from te.thru_datetime - te.from_datetime) / 3600;

-- name: 6.6 — Data-quality check: workers who approve their own timesheet (should be empty)
select tr.timesheet_id, n.name
from timesheet_role tr
join timesheet ts         on ts.timesheet_id = tr.timesheet_id
join party_role r         on r.party_role_id = ts.party_role_id
join party_display_name n on n.party_id = tr.party_id
where tr.timesheet_role_type_id = 'APPROVER'
  and tr.party_id = r.party_id;

-- ============================================================
-- Fig 6.7 — Work effort rates
-- ============================================================
-- name: 6.7 — Rates in force for each assignment on two days, by type (May 14 and 21, 2001)
select d.as_of, n.name, we.name as effort, r.rate_type_id, r.rate
from (values (date '2001-05-14'), (date '2001-05-21')) d (as_of)
join work_effort_assignment_rate r   on r.from_date <= d.as_of and (r.thru_date is null or r.thru_date > d.as_of)
join work_effort_party_assignment a  on a.work_effort_party_assignment_id = r.work_effort_party_assignment_id
join work_effort we                  on we.work_effort_id = a.work_effort_id
join party_display_name n            on n.party_id = a.party_id
order by d.as_of, n.name, r.rate_type_id, r.rate;

-- name: 6.7 — What each time entry costs and bills: hours × the regular rate in force that day, the assignment's rate first, else the party's (NOTES, point 29)
with entry as (
  select te.time_entry_id, te.work_effort_id, r.party_id, te.from_datetime::date as day, te.hours
  from time_entry te
  join timesheet ts  on ts.timesheet_id = te.timesheet_id
  join party_role r  on r.party_role_id = ts.party_role_id
),
rate_on (time_entry_id, rate_type_id, rate, level) as (
  select e.time_entry_id, ar.rate_type_id, ar.rate, 'assignment'
  from entry e
  join work_effort_party_assignment a on a.work_effort_id = e.work_effort_id and a.party_id = e.party_id
                                     and a.from_date <= e.day and (a.thru_date is null or a.thru_date > e.day)
  join work_effort_assignment_rate ar on ar.work_effort_party_assignment_id = a.work_effort_party_assignment_id
                                     and ar.from_date <= e.day and (ar.thru_date is null or ar.thru_date > e.day)
  union all
  select e.time_entry_id, pr.rate_type_id, pr.rate, 'party'
  from entry e
  join party_rate pr on pr.party_id = e.party_id
                    and pr.from_date <= e.day and (pr.thru_date is null or pr.thru_date > e.day)
),
best as (
  select distinct on (time_entry_id, rate_type_id) time_entry_id, rate_type_id, rate, level
  from rate_on
  order by time_entry_id, rate_type_id, case level when 'assignment' then 1 else 2 end, rate desc
)
select e.time_entry_id, n.name, e.day, e.hours,
       p.rate as pay_rate, p.level as pay_from, e.hours * p.rate as cost,
       b.rate as billing_rate, b.level as billing_from, e.hours * b.rate as billed
from entry e
join party_display_name n on n.party_id = e.party_id
left join best p on p.time_entry_id = e.time_entry_id and p.rate_type_id = 'REGULAR_PAY'
left join best b on b.time_entry_id = e.time_entry_id and b.rate_type_id = 'REGULAR_BILLING'
where exists (select 1 from rate_on ro where ro.time_entry_id = e.time_entry_id)
order by e.day;

-- name: 6.7 — Standard rates by kind of position, in force today
select pt.description as position_type, ptr.rate_type_id, ptr.rate, ptr.from_date
from position_type_rate ptr
join position_type pt on pt.position_type_id = ptr.position_type_id
where ptr.from_date <= current_date and (ptr.thru_date is null or ptr.thru_date > current_date)
order by pt.description, ptr.rate_type_id;

-- name: 6.7 — Data-quality check: two rates of the same type in force at once for the same position type, party or assignment (should be empty)
with rate (level, owner, rate_type_id, id, from_date, thru_date) as (
  select 'position type', position_type_id, rate_type_id, position_type_rate_id, from_date, thru_date from position_type_rate
  union all
  select 'party', party_id::text, rate_type_id, party_rate_id, from_date, thru_date from party_rate
  union all
  select 'assignment', work_effort_party_assignment_id::text, rate_type_id, work_effort_assignment_rate_id, from_date, thru_date from work_effort_assignment_rate
)
select a.level, a.owner, a.rate_type_id, a.from_date, a.thru_date, b.from_date as other_from, b.thru_date as other_thru
from rate a
join rate b on b.level = a.level and b.owner = a.owner and b.rate_type_id = a.rate_type_id and b.id > a.id
where a.from_date < coalesce(b.thru_date, 'infinity') and b.from_date < coalesce(a.thru_date, 'infinity')
order by a.level, a.owner, a.rate_type_id, a.from_date;

-- name: 6.7 — Data-quality check: assignment rates outside their assignment's dates (should be empty)
select ar.work_effort_assignment_rate_id, n.name, ar.rate_type_id, ar.from_date, ar.thru_date,
       a.from_date as assigned_from, a.thru_date as assigned_thru
from work_effort_assignment_rate ar
join work_effort_party_assignment a on a.work_effort_party_assignment_id = ar.work_effort_party_assignment_id
join party_display_name n           on n.party_id = a.party_id
where ar.from_date < a.from_date
   or (a.thru_date is not null and coalesce(ar.thru_date, 'infinity') > a.thru_date);

-- ============================================================
-- Fig 6.8 — Inventory assignments
-- ============================================================
-- name: 6.8 — Stock each effort used: which item, of which good, from where, how much
select ia.work_effort_id, we.name as effort, ia.inventory_item_id as stock, p.name as good,
       f.description as stored_at, ia.quantity
from work_effort_inventory_assignment ia
join work_effort we    on we.work_effort_id = ia.work_effort_id
join inventory_item ii on ii.inventory_item_id = ia.inventory_item_id
join product p         on p.product_id = ii.product_id
left join facility f   on f.facility_id = ii.facility_id
order by ia.work_effort_id, p.name;

-- name: 6.8 — Goods used by a job and all its parts, rolled up (the pencil run, 41000)
with recursive part (work_effort_id) as (
  select 41000
  union
  select a.to_work_effort_id
  from part p
  join work_effort_association a on a.from_work_effort_id = p.work_effort_id and a.work_effort_association_type_id = 'BREAKDOWN'
)
select g.name as good, sum(ia.quantity) as used
from part
join work_effort_inventory_assignment ia on ia.work_effort_id = part.work_effort_id
join inventory_item ii                   on ii.inventory_item_id = ia.inventory_item_id
join product g                           on g.product_id = ii.product_id
group by g.name
order by g.name;

-- name: 6.8 — Data-quality check: the same inventory item twice on one effort (should be empty)
select work_effort_id, inventory_item_id, count(*) as rows, sum(quantity) as total
from work_effort_inventory_assignment
group by work_effort_id, inventory_item_id
having count(*) > 1;

-- name: 6.8 — Data-quality check: a serialized item used in a quantity other than one (should be empty)
select ia.work_effort_id, ia.inventory_item_id, ii.serial_num, ia.quantity
from work_effort_inventory_assignment ia
join inventory_item ii on ii.inventory_item_id = ia.inventory_item_id
where ii.inventory_item_kind = 'SERIALIZED'
  and ia.quantity is distinct from 1
  and ia.quantity is not null;

-- ============================================================
-- Fig 6.9 — Fixed asset assignments
-- ============================================================
-- name: 6.9 — The fixed asset type tree, with the assets of each type
with recursive tree (fixed_asset_type_id, depth, path) as (
  select fixed_asset_type_id, 0, description
  from fixed_asset_type where parent_type_id is null
  union all
  select t.fixed_asset_type_id, tree.depth + 1, tree.path || ' > ' || t.description
  from fixed_asset_type t
  join tree on t.parent_type_id = tree.fixed_asset_type_id
)
select tree.path, string_agg(fa.name, ', ' order by fa.name) as assets
from tree
left join fixed_asset fa on fa.fixed_asset_type_id = tree.fixed_asset_type_id
group by tree.path
order by tree.path;

-- name: 6.9 — Assets booked on work efforts: when, in what state, at what cost
select fa.name as asset, t.description as asset_type, we.name as effort, s.description as status,
       b.from_date, b.thru_date, b.allocated_cost, b.comment
from work_effort_fixed_asset_assignment b
join fixed_asset fa      on fa.fixed_asset_id = b.fixed_asset_id
join fixed_asset_type t  on t.fixed_asset_type_id = fa.fixed_asset_type_id
join work_effort we      on we.work_effort_id = b.work_effort_id
join status_type s       on s.status_type_id = b.status_type_id
order by fa.name, b.from_date;

-- name: 6.9 — Fixed assets free of work on Jun 14, 2000
select fa.fixed_asset_id, fa.name, t.description as asset_type
from fixed_asset fa
join fixed_asset_type t on t.fixed_asset_type_id = fa.fixed_asset_type_id
where fa.date_acquired <= date '2000-06-14'
  and not exists (select 1 from work_effort_fixed_asset_assignment b
                  where b.fixed_asset_id = fa.fixed_asset_id
                    and b.from_date <= date '2000-06-14' and (b.thru_date is null or b.thru_date > date '2000-06-14'))
order by fa.name;

-- name: 6.9 — Review: asset bookings outside their effort's schedule (NOTES, point 34)
select we.work_effort_id, we.name as effort, we.scheduled_start_date, we.scheduled_completion_date,
       fa.name as asset, b.from_date, b.thru_date
from work_effort_fixed_asset_assignment b
join work_effort we on we.work_effort_id = b.work_effort_id
join fixed_asset fa on fa.fixed_asset_id = b.fixed_asset_id
where b.from_date > we.scheduled_completion_date
   or coalesce(b.thru_date, 'infinity') <= we.scheduled_start_date;

-- name: 6.9 — Data-quality check: one fixed asset booked on two efforts at overlapping times (should be empty)
select fa.name as asset, a.work_effort_id, a.from_date, a.thru_date,
       b.work_effort_id as other_effort, b.from_date as other_from, b.thru_date as other_thru
from work_effort_fixed_asset_assignment a
join work_effort_fixed_asset_assignment b on b.fixed_asset_id = a.fixed_asset_id
                                         and b.work_effort_fixed_asset_assignment_id > a.work_effort_fixed_asset_assignment_id
join fixed_asset fa on fa.fixed_asset_id = a.fixed_asset_id
where a.from_date < coalesce(b.thru_date, 'infinity') and b.from_date < coalesce(a.thru_date, 'infinity');

-- name: 6.9 — Data-quality check: asset bookings with a status outside the booking statuses (should be empty)
select b.work_effort_fixed_asset_assignment_id, b.work_effort_id, b.fixed_asset_id, b.status_type_id
from work_effort_fixed_asset_assignment b
join status_type s on s.status_type_id = b.status_type_id
where s.parent_type_id is distinct from 'WORK_EFFORT_ASSET_ASSIGN_STATUS';

-- name: 6.9 — Data-quality check: a production capacity with no unit of measure (should be empty)
select fixed_asset_id, name, production_capacity
from fixed_asset
where production_capacity is not null and capacity_uom_id is null;

-- ============================================================
-- Fig 6.10 — Party fixed asset assignments
-- ============================================================
-- name: 6.10 — Who holds which asset on Jun 15, 2000, and in what state
select n.name as holder, fa.name as asset, s.description as status, pa.from_date, pa.thru_date
from party_fixed_asset_assignment pa
join party_display_name n on n.party_id = pa.party_id
join fixed_asset fa       on fa.fixed_asset_id = pa.fixed_asset_id
join status_type s        on s.status_type_id = pa.status_type_id
where pa.from_date <= date '2000-06-15' and (pa.thru_date is null or pa.thru_date > date '2000-06-15')
order by fa.name, n.name;

-- name: 6.10 — Each asset's story: the jobs and the parties it went to, in date order
select fa.name as asset, x.from_date, x.thru_date, x.went_to, x.who_or_what, s.description as status
from (
  select fixed_asset_id, from_date, thru_date, 'work effort' as went_to, we.name as who_or_what, b.status_type_id
  from work_effort_fixed_asset_assignment b
  join work_effort we on we.work_effort_id = b.work_effort_id
  union all
  select fixed_asset_id, from_date, thru_date, 'party', n.name, pa.status_type_id
  from party_fixed_asset_assignment pa
  join party_display_name n on n.party_id = pa.party_id
) x
join fixed_asset fa on fa.fixed_asset_id = x.fixed_asset_id
join status_type s  on s.status_type_id = x.status_type_id
order by fa.name, x.from_date;

-- name: 6.10 — Data-quality check: one asset held by two parties at overlapping times (should be empty)
select fa.name as asset, na.name as holder, a.from_date, a.thru_date,
       nb.name as other_holder, b.from_date as other_from, b.thru_date as other_thru
from party_fixed_asset_assignment a
join party_fixed_asset_assignment b on b.fixed_asset_id = a.fixed_asset_id
                                   and b.party_fixed_asset_assignment_id > a.party_fixed_asset_assignment_id
join fixed_asset fa        on fa.fixed_asset_id = a.fixed_asset_id
join party_display_name na on na.party_id = a.party_id
join party_display_name nb on nb.party_id = b.party_id
where a.from_date < coalesce(b.thru_date, 'infinity') and b.from_date < coalesce(a.thru_date, 'infinity');

-- name: 6.10 — Data-quality check: an asset booked or handed out after it was lost (should be empty)
with lost as (
  select fixed_asset_id, min(thru_date) as lost_after
  from party_fixed_asset_assignment
  where status_type_id = 'ASSET_LOST'
  group by fixed_asset_id
)
select fa.name as asset, l.lost_after, 'work effort ' || b.work_effort_id as used_by, b.from_date
from lost l
join work_effort_fixed_asset_assignment b on b.fixed_asset_id = l.fixed_asset_id and b.from_date >= l.lost_after
join fixed_asset fa on fa.fixed_asset_id = l.fixed_asset_id
union all
select fa.name, l.lost_after, n.name, pa.from_date
from lost l
join party_fixed_asset_assignment pa on pa.fixed_asset_id = l.fixed_asset_id and pa.from_date >= l.lost_after
join fixed_asset fa       on fa.fixed_asset_id = l.fixed_asset_id
join party_display_name n on n.party_id = pa.party_id;

-- name: 6.10 — Data-quality check: party asset assignments with a status outside their group (should be empty)
select pa.party_fixed_asset_assignment_id, pa.party_id, pa.fixed_asset_id, pa.status_type_id
from party_fixed_asset_assignment pa
join status_type s on s.status_type_id = pa.status_type_id
where s.parent_type_id is distinct from 'PARTY_ASSET_ASSIGN_STATUS';

-- ============================================================
-- Fig 6.11 — Work effort type standards
-- ============================================================
-- name: 6.11 — Everything a large production run of pencils normally needs: people, goods and assets
select 'skill' as kind, s.description as what, ss.estimated_num_people as quantity, ss.estimated_duration as duration, ss.estimated_cost
from work_effort_skill_standard ss
join skill_type s on s.skill_type_id = ss.skill_type_id
where ss.work_effort_type_id = 'LARGE_PENCIL_RUN'
union all
select 'good', p.name, gs.estimated_quantity, null, gs.estimated_cost
from work_effort_good_standard gs
join product p on p.product_id = gs.product_id
where gs.work_effort_type_id = 'LARGE_PENCIL_RUN'
union all
select 'fixed asset type', t.description, fs.estimated_quantity, fs.estimated_duration, fs.estimated_cost
from work_effort_fixed_asset_standard fs
join fixed_asset_type t on t.fixed_asset_type_id = fs.fixed_asset_type_id
where fs.work_effort_type_id = 'LARGE_PENCIL_RUN'
order by kind, what;

-- name: 6.11 — Enough stock for each planned job? Its kind's goods standards against stock at the job's plant
select we.work_effort_id, we.name as job, p.name as good, sum(gs.estimated_quantity) as needed,
       coalesce((select sum(ii.quantity_on_hand) from inventory_item ii
                 where ii.product_id = gs.product_id and ii.facility_id = we.facility_id), 0) as on_hand
from work_effort we
join work_effort_good_standard gs on gs.work_effort_type_id = we.work_effort_type_id
join product p                    on p.product_id = gs.product_id
group by we.work_effort_id, we.name, we.facility_id, gs.product_id, p.name
order by we.work_effort_id, p.name;

-- name: 6.11 — Enough assets for each planned job? Assets of the needed kind or any kind below it
with recursive below (top_id, fixed_asset_type_id) as (
  select fixed_asset_type_id, fixed_asset_type_id from fixed_asset_type
  union
  select b.top_id, t.fixed_asset_type_id
  from below b
  join fixed_asset_type t on t.parent_type_id = b.fixed_asset_type_id
)
select we.work_effort_id, we.name as job, at.description as asset_type, fs.estimated_quantity as needed,
       fs.estimated_duration, count(fa.fixed_asset_id) as owned,
       string_agg(fa.name, ', ' order by fa.name) as assets
from work_effort we
join work_effort_fixed_asset_standard fs on fs.work_effort_type_id = we.work_effort_type_id
join fixed_asset_type at                 on at.fixed_asset_type_id = fs.fixed_asset_type_id
left join below b                        on b.top_id = fs.fixed_asset_type_id
left join fixed_asset fa                 on fa.fixed_asset_type_id = b.fixed_asset_type_id
group by we.work_effort_id, we.name, at.description, fs.estimated_quantity, fs.estimated_duration
order by we.work_effort_id, at.description;

-- name: 6.11 — The standard plan of each kind of work beside what each kind is for
select t.description as kind_of_work, a.work_effort_association_type_id as link, t2.description as other_kind,
       coalesce('repairs ' || fat.description, 'produces ' || dt.description, 'produces ' || p.name) as is_for
from work_effort_type t
left join work_effort_type_association a on a.from_work_effort_type_id = t.work_effort_type_id
left join work_effort_type t2            on t2.work_effort_type_id = a.to_work_effort_type_id
left join fixed_asset_type fat           on fat.fixed_asset_type_id = t.fixed_asset_type_id
left join deliverable_type dt            on dt.deliverable_type_id = t.deliverable_type_id
left join product p                      on p.product_id = t.product_id
where a.work_effort_type_association_id is not null
   or num_nonnulls(t.fixed_asset_type_id, t.deliverable_type_id, t.product_id) = 1
order by t.description, a.work_effort_association_type_id, t2.description;

-- name: 6.11 — Data-quality check: type associations typed with the DEPENDENCY grouping row (should be empty)
select from_work_effort_type_id, to_work_effort_type_id, work_effort_association_type_id
from work_effort_type_association a
where exists (select 1 from work_effort_association_type c
              where c.parent_type_id = a.work_effort_association_type_id);

-- name: 6.11 — Data-quality check: the same skill, good or asset type twice in one kind of work's standards (should be empty)
select 'skill' as standard, work_effort_type_id, skill_type_id as what, count(*) as rows
from work_effort_skill_standard group by work_effort_type_id, skill_type_id having count(*) > 1
union all
select 'good', work_effort_type_id, product_id::text, count(*)
from work_effort_good_standard group by work_effort_type_id, product_id having count(*) > 1
union all
select 'fixed asset', work_effort_type_id, fixed_asset_type_id, count(*)
from work_effort_fixed_asset_standard group by work_effort_type_id, fixed_asset_type_id having count(*) > 1;

-- ============================================================
-- Fig 6.12 — Work effort results
-- ============================================================
-- name: 6.12 — What each effort produced or repaired
select r.work_effort_id, we.name as effort, r.result, r.what
from (
  select ip.work_effort_id, 'stock produced' as result,
         p.name || ' (item ' || ii.inventory_item_id || ', ' || ii.quantity_on_hand || ' on hand)' as what
  from work_effort_inventory_produced ip
  join inventory_item ii on ii.inventory_item_id = ip.inventory_item_id
  join product p         on p.product_id = ii.product_id
  union all
  select dp.work_effort_id, 'deliverable produced', d.name
  from work_effort_deliverable_produced dp
  join deliverable d on d.deliverable_id = dp.deliverable_id
  union all
  select we.work_effort_id, 'asset repaired', fa.name
  from work_effort we
  join fixed_asset fa on fa.fixed_asset_id = we.repaired_fixed_asset_id
) r
join work_effort we on we.work_effort_id = r.work_effort_id
order by r.work_effort_id, r.result;

-- name: 6.12 — Results rolled up to the top: everything the sales and marketing plan (39409) and its parts produced
with recursive part (work_effort_id, depth) as (
  select 39409, 0
  union
  select a.to_work_effort_id, p.depth + 1
  from part p
  join work_effort_association a on a.from_work_effort_id = p.work_effort_id and a.work_effort_association_type_id = 'BREAKDOWN'
  where p.depth < 5
)
select part.work_effort_id, we.name as produced_by, d.name as deliverable, dt.description as deliverable_type
from part
join work_effort_deliverable_produced dp on dp.work_effort_id = part.work_effort_id
join work_effort we                      on we.work_effort_id = part.work_effort_id
join deliverable d                       on d.deliverable_id = dp.deliverable_id
join deliverable_type dt                 on dt.deliverable_type_id = d.deliverable_type_id
order by part.depth, part.work_effort_id;

-- name: 6.12 — Stock produced against what the runs say they produced: one pile, two runs (NOTES, point 38)
select ii.inventory_item_id, p.name as good, ii.quantity_on_hand,
       string_agg(ip.work_effort_id::text, ', ' order by ip.work_effort_id) as produced_by,
       sum(pr.quantity_produced) as runs_say_produced
from work_effort_inventory_produced ip
join inventory_item ii       on ii.inventory_item_id = ip.inventory_item_id
join product p               on p.product_id = ii.product_id
left join production_run pr  on pr.work_effort_id = ip.work_effort_id
group by ii.inventory_item_id, p.name, ii.quantity_on_hand;

-- name: 6.12 — Review: results against what the kind of work is for (Fig 6.11's arc), where the type says
select we.work_effort_id, we.name as effort, t.description as kind_of_work,
       coalesce('repair a ' || fat.description, 'produce a ' || dt.description, 'produce ' || p.name) as meant_to,
       coalesce(rfa.name, (select string_agg(d.name, ', ') from work_effort_deliverable_produced dp
                           join deliverable d on d.deliverable_id = dp.deliverable_id
                           where dp.work_effort_id = we.work_effort_id),
                (select string_agg(pp.name, ', ') from work_effort_inventory_produced ip
                 join inventory_item ii on ii.inventory_item_id = ip.inventory_item_id
                 join product pp on pp.product_id = ii.product_id
                 where ip.work_effort_id = we.work_effort_id)) as actually
from work_effort we
join work_effort_type t        on t.work_effort_type_id = we.work_effort_type_id
left join fixed_asset_type fat on fat.fixed_asset_type_id = t.fixed_asset_type_id
left join deliverable_type dt  on dt.deliverable_type_id = t.deliverable_type_id
left join product p            on p.product_id = t.product_id
left join fixed_asset rfa      on rfa.fixed_asset_id = we.repaired_fixed_asset_id
where num_nonnulls(t.fixed_asset_type_id, t.deliverable_type_id, t.product_id) = 1
order by we.work_effort_id;

-- name: 6.12 — Data-quality check: an effort repairing a different asset from the one the need it fills names (should be empty)
select we.work_effort_id, we.name as effort, rfa.name as repaired, wr.requirement_id, nfa.name as need_names
from work_effort we
join work_requirement_fulfillment f on f.work_effort_id = we.work_effort_id
join work_requirement wr            on wr.requirement_id = f.requirement_id
join fixed_asset rfa                on rfa.fixed_asset_id = we.repaired_fixed_asset_id
join fixed_asset nfa                on nfa.fixed_asset_id = wr.fixed_asset_id
where we.repaired_fixed_asset_id <> wr.fixed_asset_id;
