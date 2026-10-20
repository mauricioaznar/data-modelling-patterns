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

-- ============================================================
-- Fig 9.3 — Position definition
-- ============================================================

-- name: 9.3 — Tables 9.1–9.2: each slot, its type's title and benefit share, its flags and dates
select p.position_id, t.title, t.benefit_percent,
       p.estimated_from_date, p.estimated_thru_date,
       p.salary_flag as salary, p.exempt_flag as exempt, p.fulltime_flag as fulltime, p.temporary_flag as temp,
       p.actual_from_date, p.actual_thru_date
from position p
join position_type t on t.position_type_id = p.position_type_id
where p.position_id in (101, 102, 204)
order by p.position_id;

-- name: 9.3 — Is each funded slot authorized? Its budget item, the budget, and the budget's latest status
select p.position_id, t.title, bi.budget_id, b.comment as budget, it.description as item, bi.amount,
       s.description as budget_status, s.status_date,
       coalesce(s.status_type_id = 'BUDGET_APPROVED', false) as authorized
from position p
join position_type t     on t.position_type_id = p.position_type_id
join budget_item bi      on bi.budget_item_id = p.budget_item_id
join budget b            on b.budget_id = bi.budget_id
join budget_item_type it on it.budget_item_type_id = bi.budget_item_type_id
left join lateral (
  select bs.status_type_id, st.description, bs.status_date
  from budget_status bs join status_type st on st.status_type_id = bs.status_type_id
  where bs.budget_id = b.budget_id
  order by bs.status_date desc, bs.budget_status_id desc
  limit 1
) s on true
order by p.position_id;

-- name: 9.3 — Slot 101's job description on Apr 1, 2001: what its type may be given, and what it is given
select v.responsibility_type_id, r.description,
       (pr.position_responsibility_id is not null) as assigned_to_101
from valid_responsibility v
join responsibility_type r on r.responsibility_type_id = v.responsibility_type_id
left join position_responsibility pr
  on  pr.position_id = 101
  and pr.responsibility_type_id = v.responsibility_type_id
  and pr.from_date <= date '2001-04-01' and (pr.thru_date is null or pr.thru_date > date '2001-04-01')
where v.position_type_id = (select position_type_id from position where position_id = 101)
  and v.from_date <= date '2001-04-01' and (v.thru_date is null or v.thru_date > date '2001-04-01')
order by v.responsibility_type_id;

-- name: 9.3 — Data-quality check: a slot's responsibility that isn't valid for its type on the day it starts (should be empty)
select pr.position_responsibility_id, pr.position_id, t.title, pr.responsibility_type_id, pr.from_date
from position_responsibility pr
join position p      on p.position_id = pr.position_id
join position_type t on t.position_type_id = p.position_type_id
where not exists (
  select 1 from valid_responsibility v
  where v.position_type_id = p.position_type_id
    and v.responsibility_type_id = pr.responsibility_type_id
    and v.from_date <= pr.from_date and (v.thru_date is null or v.thru_date > pr.from_date));

-- name: 9.3 — Data-quality check: slots opened before the budget that funds them was approved (should be empty)
select p.position_id, t.title, p.actual_from_date, bi.budget_id,
       (select min(bs.status_date) from budget_status bs
        where bs.budget_id = bi.budget_id and bs.status_type_id = 'BUDGET_APPROVED') as approved_on
from position p
join position_type t on t.position_type_id = p.position_type_id
join budget_item bi  on bi.budget_item_id = p.budget_item_id
where p.actual_from_date < coalesce((select min(bs.status_date) from budget_status bs
                                     where bs.budget_id = bi.budget_id and bs.status_type_id = 'BUDGET_APPROVED'), 'infinity'::date);

-- ============================================================
-- Fig 9.4 — Position type definition
-- ============================================================

-- name: 9.4 — Table 9.3: how each position type is classified, since when, for how many hours a week
select t.title, c.description as classification, k.from_date, k.thru_date, k.standard_hours_per_week
from position_type_class k
join position_type t                on t.position_type_id = k.position_type_id
join position_classification_type c on c.position_classification_type_id = k.position_classification_type_id
order by t.title, k.from_date, c.description;

-- name: 9.4 — Which position types were classed as Computer on Jan 1, 1999, and on Jan 1, 2001?
select d.as_of, string_agg(distinct t.title, ', ') as computer_types
from (values (date '1999-01-01'), (date '2001-01-01')) d(as_of)
join position_type_class k on k.position_classification_type_id = 'COMPUTER'
                          and k.from_date <= d.as_of and (k.thru_date is null or k.thru_date > d.as_of)
join position_type t       on t.position_type_id = k.position_type_id
group by d.as_of
order by d.as_of;

-- name: 9.4 — Which union represents each position type, and how many slots of that type exist
select t.title, u.name as union_name, count(p.position_id) as slots
from position_type t
join party_role r         on r.party_role_id = t.union_party_role_id
join party_display_name u on u.party_id = r.party_id
left join position p      on p.position_type_id = t.position_type_id
group by t.title, u.name
order by t.title;

-- name: 9.4 — Data-quality check: a position type classed the same way twice over overlapping dates (should be empty)
select a.position_type_class_id, b.position_type_class_id as overlaps_with,
       a.position_type_id, a.position_classification_type_id, a.from_date, b.from_date as other_from
from position_type_class a
join position_type_class b
  on  b.position_type_id = a.position_type_id
  and b.position_classification_type_id = a.position_classification_type_id
  and b.position_type_class_id > a.position_type_class_id
  and b.from_date < coalesce(a.thru_date, 'infinity')
  and a.from_date < coalesce(b.thru_date, 'infinity');

-- name: 9.4 — Data-quality check: position types "unionized by" a role that isn't a union (should be empty)
select t.position_type_id, t.title, r.party_role_id, r.role_type_id, d.name
from position_type t
join party_role r         on r.party_role_id = t.union_party_role_id
join party_display_name d on d.party_id = r.party_id
where r.role_type_id <> 'UNION';

-- ============================================================
-- Fig 9.5 — Position fulfillment
-- ============================================================

-- name: 9.5 — Table 9.5: who filled which slot, from when to when
select d.name as person, f.position_id, t.title, f.from_date, f.thru_date
from position_fulfillment f
join position p           on p.position_id = f.position_id
join position_type t      on t.position_type_id = p.position_type_id
join party_display_name d on d.party_id = f.party_id
order by person, f.from_date;

-- name: 9.5 — ABC Corporation's slots on Jul 1, 2001: state, and who holds each (vacant when nobody)
select p.position_id, t.title, s.description as status,
       coalesce(string_agg(d.name, ', '), '(vacant)') as held_by
from position p
join position_type t on t.position_type_id = p.position_type_id
join status_type s   on s.status_type_id = p.status_type_id
left join position_fulfillment f
  on  f.position_id = p.position_id
  and f.from_date <= date '2001-07-01' and (f.thru_date is null or f.thru_date > date '2001-07-01')
left join party_display_name d on d.party_id = f.party_id
where p.organization_party_id = 12
group by p.position_id, t.title, s.description
order by p.position_id;

-- name: 9.5 — Data-quality check: a slot filled before it opened or after it closed (should be empty)
select f.position_fulfillment_id, f.position_id, t.title, d.name as person,
       f.from_date, f.thru_date, p.actual_from_date, p.actual_thru_date
from position_fulfillment f
join position p           on p.position_id = f.position_id
join position_type t      on t.position_type_id = p.position_type_id
join party_display_name d on d.party_id = f.party_id
where p.actual_from_date is null
   or f.from_date < p.actual_from_date
   or coalesce(f.thru_date, 'infinity') > coalesce(p.actual_thru_date, 'infinity');

-- name: 9.5 — Data-quality check: slots whose hiring company has never been an internal organization (should be empty)
select p.position_id, t.title, d.name as hiring_company
from position p
join position_type t      on t.position_type_id = p.position_type_id
join party_display_name d on d.party_id = p.organization_party_id
where not exists (select 1 from party_role r
                  where r.party_id = p.organization_party_id and r.role_type_id = 'INTERNAL_ORGANIZATION');

-- name: 9.5 — Review: fulfillments by someone not employed by the slot's hiring company on the day they start (contractors, agency staff, or a missing employment)
select f.position_fulfillment_id, d.name as person, t.title, f.from_date
from position_fulfillment f
join position p           on p.position_id = f.position_id
join position_type t      on t.position_type_id = p.position_type_id
join party_display_name d on d.party_id = f.party_id
where not exists (
  select 1 from employment_relationship e
  where e.employee_party_id = f.party_id
    and e.employer_party_id = p.organization_party_id
    and e.from_date <= f.from_date and (e.thru_date is null or e.thru_date > f.from_date));
