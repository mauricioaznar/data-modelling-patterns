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
select p.party_id,
       concat_ws(' ',
         max(n.name) filter (where n.person_name_type_id = 'PERSONAL_TITLE'),
         max(n.name) filter (where n.person_name_type_id = 'FIRST'),
         max(n.name) filter (where n.person_name_type_id = 'MIDDLE'),
         max(n.name) filter (where n.person_name_type_id = 'LAST'),
         max(n.name) filter (where n.person_name_type_id = 'SUFFIX')) as display_name,
       max(n.name) filter (where n.person_name_type_id = 'NICKNAME') as nickname
from person p
left join person_name n on n.party_id = p.party_id and n.thru_date is null
group by p.party_id
order by p.party_id;

-- name: 2.2b — What was Ana's last name in 2015? (the question 2.2a couldn't answer)
select n.name as last_name_on_2015_01_01
from person_name n
where n.party_id = 1
  and n.person_name_type_id = 'LAST'
  and n.from_date <= date '2015-01-01'
  and (n.thru_date is null or n.thru_date > date '2015-01-01');

-- name: 2.2b — Ben's marital status history
select t.description as status, m.from_date, m.thru_date
from marital_status m
join marital_status_type t using (marital_status_type_id)
where m.party_id = 2
order by m.from_date;

-- name: 2.2b — Current marital status of everyone ("unknown" when there are no rows)
select p.party_id, coalesce(t.description, 'unknown') as current_status
from person p
left join marital_status m on m.party_id = p.party_id and m.thru_date is null
left join marital_status_type t using (marital_status_type_id)
order by p.party_id;

-- name: 2.2b — Current dual (or more) citizens
select c.party_id, string_agg(co.name, ', ' order by co.name) as countries
from citizenship c
join country co using (country_id)
where c.thru_date is null
group by c.party_id
having count(*) > 1;

-- name: 2.2b — Passports and whether they are valid today
select pp.party_id, co.name as country, pp.passport_num, pp.expiration_date,
       case when pp.expiration_date >= current_date then 'valid' else 'expired' end as state
from passport pp
join country co using (country_id)
order by pp.party_id, pp.expiration_date;

-- name: 2.2b — Current weight per person (latest open WEIGHT_KG row)
select party_id, value::numeric as weight_kg, from_date as since
from physical_characteristic
where physical_characteristic_type_id = 'WEIGHT_KG'
  and thru_date is null
order by party_id;

-- name: 2.2b — EAV cost: values of numeric characteristics that aren't numbers
select party_id, physical_characteristic_type_id, value
from physical_characteristic
where physical_characteristic_type_id in ('HEIGHT_CM', 'WEIGHT_KG')
  and value !~ '^\d+(\.\d+)?$';

-- ============================================================
-- Fig 2.3 — Party
-- ============================================================

-- name: 2.3 — One list of every party, person or organization (the supertype payoff)
select party_id, party_kind, name
from party_display_name
order by party_id;

-- name: 2.3 — Current classifications per party, grouped by category
select d.name,
       cat.description as category,
       t.description   as classification,
       c.from_date
from party_classification c
join party_type t   on t.party_type_id = c.party_type_id
join party_type cat on cat.party_type_id = t.parent_type_id
join party_display_name d on d.party_id = c.party_id
where c.thru_date is null
order by d.name, category;

-- name: 2.3 — Northwind's size history
select t.description as size, c.from_date, c.thru_date
from party_classification c
join party_type t using (party_type_id)
where c.party_id = 4
  and t.parent_type_id = 'SIZE'
order by c.from_date;

-- name: 2.3 — Which organizations were small businesses on 2017-06-01?
select d.name
from party_classification c
join party_display_name d using (party_id)
where c.party_type_id = 'SIZE_SMALL'
  and c.from_date <= date '2017-06-01'
  and (c.thru_date is null or c.thru_date > date '2017-06-01');

-- name: 2.3 — Minority- or woman-owned suppliers today (any type under MINORITY)
select d.name, t.description
from party_classification c
join party_type t using (party_type_id)
join party_display_name d using (party_id)
where t.parent_type_id = 'MINORITY'
  and c.thru_date is null;

-- name: 2.3 — Data-quality check: persons missing a current first or last name (the book says both are mandatory)
select p.party_id, d.name,
       bool_or(n.person_name_type_id = 'FIRST') is true as has_first,
       bool_or(n.person_name_type_id = 'LAST')  is true as has_last
from person p
join party_display_name d on d.party_id = p.party_id
left join person_name n on n.party_id = p.party_id and n.thru_date is null
group by p.party_id, d.name
having not (bool_or(n.person_name_type_id = 'FIRST') is true
        and bool_or(n.person_name_type_id = 'LAST')  is true);

-- ============================================================
-- Fig 2.4 — Party roles
-- ============================================================

-- name: 2.4 — Current roles per party
select d.name, d.party_kind, string_agg(t.description, ', ' order by t.description) as current_roles
from party_role r
join role_type t using (role_type_id)
join party_display_name d using (party_id)
where r.thru_date is null
group by d.name, d.party_kind
order by d.party_kind, d.name;

-- name: 2.4 — Current customers of any kind (every role under CUSTOMER)
select distinct d.name, d.party_kind
from party_role r
join role_type t using (role_type_id)
join party_display_name d using (party_id)
where t.parent_type_id = 'CUSTOMER'
  and r.thru_date is null
order by d.name;

-- name: 2.4 — Parties that are currently both our customer and our supplier
select d.name
from party_display_name d
where exists (select 1 from party_role r join role_type t using (role_type_id)
              where r.party_id = d.party_id and t.parent_type_id = 'CUSTOMER' and r.thru_date is null)
  and exists (select 1 from party_role r
              where r.party_id = d.party_id and r.role_type_id = 'SUPPLIER' and r.thru_date is null);

-- name: 2.4 — Prospects that converted to customers, and how long it took
select d.name,
       p.from_date                as prospect_since,
       min(c.from_date)           as customer_since,
       min(c.from_date) - p.from_date as days_to_convert
from party_role p
join party_role c on c.party_id = p.party_id
join role_type ct on ct.role_type_id = c.role_type_id and ct.parent_type_id = 'CUSTOMER'
join party_display_name d on d.party_id = p.party_id
where p.role_type_id = 'PROSPECT'
  and c.from_date >= p.from_date
group by d.name, p.from_date;

-- name: 2.4 — Ana's role history
select t.description as role, r.from_date, r.thru_date
from party_role r
join role_type t using (role_type_id)
where r.party_id = 1
order by r.from_date;

-- name: 2.4 — Who were our employees on 2020-01-01?
select d.name
from party_role r
join party_display_name d using (party_id)
where r.role_type_id = 'EMPLOYEE'
  and r.from_date <= date '2020-01-01'
  and (r.thru_date is null or r.thru_date > date '2020-01-01');

-- name: 2.4 — Contacts and departments: the role alone can't say for whom (see EXERCISES #17)
select d.name, t.description as role, 'for whom? unknown' as of_whom
from party_role r
join role_type t using (role_type_id)
join party_display_name d using (party_id)
where r.role_type_id in ('CONTACT', 'DEPARTMENT');
