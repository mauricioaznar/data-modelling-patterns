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
from person_flat
order by person_id;

-- name: 2.2a — Free-text trouble: how many distinct spellings of gender and marital status?
select 'gender' as attribute, gender as value, count(*) from person_flat group by gender
union all
select 'marital_status', marital_status, count(*) from person_flat group by marital_status
order by attribute, value;

-- name: 2.2a — What was Ana's last name in 2015? (the flat model can't answer; best it can do)
select current_last_name as last_name_today, comment as only_clue
from person_flat
where person_id = 1;

-- ============================================================
-- Fig 2.2b — Person, alternate model
-- ============================================================

-- name: 2.2b — Everyone's current display name (the flat columns, rebuilt from name rows)
select p.person_id,
       concat_ws(' ',
         max(n.name) filter (where n.person_name_type_id = 'PERSONAL_TITLE'),
         max(n.name) filter (where n.person_name_type_id = 'FIRST'),
         max(n.name) filter (where n.person_name_type_id = 'MIDDLE'),
         max(n.name) filter (where n.person_name_type_id = 'LAST'),
         max(n.name) filter (where n.person_name_type_id = 'SUFFIX')) as display_name,
       max(n.name) filter (where n.person_name_type_id = 'NICKNAME') as nickname
from person p
left join person_name n on n.person_id = p.person_id and n.thru_date is null
group by p.person_id
order by p.person_id;

-- name: 2.2b — What was Ana's last name in 2015? (the question 2.2a couldn't answer)
select n.name as last_name_on_2015_01_01
from person_name n
where n.person_id = 1
  and n.person_name_type_id = 'LAST'
  and n.from_date <= date '2015-01-01'
  and (n.thru_date is null or n.thru_date > date '2015-01-01');

-- name: 2.2b — Ben's marital status history
select t.description as status, m.from_date, m.thru_date
from marital_status m
join marital_status_type t using (marital_status_type_id)
where m.person_id = 2
order by m.from_date;

-- name: 2.2b — Current marital status of everyone ("unknown" when there are no rows)
select p.person_id, coalesce(t.description, 'unknown') as current_status
from person p
left join marital_status m on m.person_id = p.person_id and m.thru_date is null
left join marital_status_type t using (marital_status_type_id)
order by p.person_id;

-- name: 2.2b — Current dual (or more) citizens
select c.person_id, string_agg(co.name, ', ' order by co.name) as countries
from citizenship c
join country co using (country_id)
where c.thru_date is null
group by c.person_id
having count(*) > 1;

-- name: 2.2b — Passports and whether they are valid today
select pp.person_id, co.name as country, pp.passport_num, pp.expiration_date,
       case when pp.expiration_date >= current_date then 'valid' else 'expired' end as state
from passport pp
join country co using (country_id)
order by pp.person_id, pp.expiration_date;

-- name: 2.2b — Current weight per person (latest open WEIGHT_KG row)
select person_id, value::numeric as weight_kg, from_date as since
from physical_characteristic
where physical_characteristic_type_id = 'WEIGHT_KG'
  and thru_date is null
order by person_id;

-- name: 2.2b — EAV cost: values of numeric characteristics that aren't numbers
select person_id, physical_characteristic_type_id, value
from physical_characteristic
where physical_characteristic_type_id in ('HEIGHT_CM', 'WEIGHT_KG')
  and value !~ '^\d+(\.\d+)?$';
