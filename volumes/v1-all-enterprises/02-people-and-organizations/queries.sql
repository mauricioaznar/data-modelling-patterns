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
join geographic_boundary co on co.geographic_boundary_id = c.country_id
where c.thru_date is null
group by c.party_id
having count(*) > 1;

-- name: 2.2b — Passports and whether they are valid today
select c.party_id, co.name as country, pp.passport_num, pp.expiration_date,
       case when pp.expiration_date >= current_date then 'valid' else 'expired' end as state
from passport pp
join citizenship c using (citizenship_id)
join geographic_boundary co on co.geographic_boundary_id = c.country_id
order by c.party_id, pp.expiration_date;

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

-- name: 2.3 — Data-quality check: parties without exactly the subtype their kind says (should be empty)
select p.party_id, p.party_kind,
       (pe.party_id is not null) as has_person_row,
       (o.party_id  is not null) as has_organization_row
from party p
left join person pe      on pe.party_id = p.party_id
left join organization o on o.party_id  = p.party_id
where (p.party_kind = 'PERSON'       and (pe.party_id is null or o.party_id is not null))
   or (p.party_kind = 'ORGANIZATION' and (o.party_id is null or pe.party_id is not null));

-- name: 2.3 — Data-quality check: classifications on the wrong kind of party (should be empty)
select d.name, d.party_kind, t.party_type_id, t.applies_to_kind
from party_classification c
join party_type t using (party_type_id)
join party_display_name d using (party_id)
where t.applies_to_kind <> d.party_kind;

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

-- name: 2.4 — Data-quality check: roles played by the wrong kind of party, or grouping types assigned directly (should be empty)
select d.name, d.party_kind, r.role_type_id,
       case when t.applies_to_kind is null then 'grouping type, not assignable'
            else 'role is for ' || t.applies_to_kind end as problem
from party_role r
join role_type t using (role_type_id)
join party_display_name d using (party_id)
where t.applies_to_kind is null
   or (t.applies_to_kind <> 'EITHER' and t.applies_to_kind <> d.party_kind);

-- ============================================================
-- Fig 2.5 — Specific party relationships
-- ============================================================

-- name: 2.5 — Employment history: who employed whom (answers "employee of whom?" from 2.4)
select er.name as employer, ee.name as employee, e.from_date, e.thru_date
from employment e
join party_role r1 on r1.party_role_id = e.employer_party_role_id
join party_role r2 on r2.party_role_id = e.employee_party_role_id
join party_display_name er on er.party_id = r1.party_id
join party_display_name ee on ee.party_id = r2.party_id
order by e.from_date;

-- name: 2.5 — Northwind's current customers, and in which capacity
select c.name as customer, t.description as capacity, cr.from_date
from customer_relationship cr
join party_role rc on rc.party_role_id = cr.customer_party_role_id
join party_role ri on ri.party_role_id = cr.internal_org_party_role_id
join role_type t   on t.role_type_id = rc.role_type_id
join party_display_name c on c.party_id = rc.party_id
where ri.party_id = 4
  and cr.thru_date is null
order by c.name, capacity;

-- name: 2.5 — Org chart: which units roll up into which parent
select child.name as unit, ct.description as unit_role, parent.name as within
from organization_rollup o
join party_role rc on rc.party_role_id = o.child_party_role_id
join party_role rp on rp.party_role_id = o.parent_party_role_id
join role_type ct  on ct.role_type_id = rc.role_type_id
join party_display_name child  on child.party_id = rc.party_id
join party_display_name parent on parent.party_id = rp.party_id
where o.thru_date is null;

-- name: 2.5 — Data-quality check: relationships whose roles are the wrong type (should be empty)
select 'employment' as relationship, e.employment_id as id, 'employee role is ' || r.role_type_id as problem
from employment e
join party_role r on r.party_role_id = e.employee_party_role_id
where r.role_type_id <> 'EMPLOYEE'
union all
select 'employment', e.employment_id, 'employer role is ' || r.role_type_id
from employment e
join party_role r on r.party_role_id = e.employer_party_role_id
where r.role_type_id <> 'INTERNAL_ORGANIZATION'
union all
select 'customer_relationship', c.customer_relationship_id, 'customer role is ' || r.role_type_id
from customer_relationship c
join party_role r on r.party_role_id = c.customer_party_role_id
join role_type t  on t.role_type_id = r.role_type_id
where t.role_type_id <> 'CUSTOMER' and coalesce(t.parent_type_id, '') <> 'CUSTOMER';

-- ============================================================
-- Fig 2.6a — Common party relationships (generic)
-- ============================================================

-- name: 2.6a — Every current relationship, read as a sentence
select fp.name as from_party, ft.description as as_role,
       rt.name as relationship,
       tp.name as to_party, tt.description as to_role
from party_relationship pr
join party_relationship_type rt on rt.party_relationship_type_id = pr.party_relationship_type_id
join party_role f  on f.party_role_id = pr.from_party_role_id
join party_role t  on t.party_role_id = pr.to_party_role_id
join role_type ft  on ft.role_type_id = f.role_type_id
join role_type tt  on tt.role_type_id = t.role_type_id
join party_display_name fp on fp.party_id = f.party_id
join party_display_name tp on tp.party_id = t.party_id
where pr.thru_date is null
order by relationship, from_party;

-- name: 2.6a — Who is Ben a contact for? (the other gap from 2.4, which 2.5 had no table for)
select o.name as contact_for, pr.from_date, pr.comment
from party_relationship pr
join party_role f on f.party_role_id = pr.from_party_role_id
join party_role t on t.party_role_id = pr.to_party_role_id
join party_display_name o on o.party_id = t.party_id
where pr.party_relationship_type_id = 'ORGANIZATION_CONTACT'
  and f.party_id = 2;

-- name: 2.6a — All of Contoso's relationships, in either direction (direction makes this an OR)
select rt.name as relationship,
       case when f.party_id = 5 then 'from Contoso' else 'to Contoso' end as direction,
       other.name as other_party
from party_relationship pr
join party_relationship_type rt on rt.party_relationship_type_id = pr.party_relationship_type_id
join party_role f on f.party_role_id = pr.from_party_role_id
join party_role t on t.party_role_id = pr.to_party_role_id
join party_display_name other
  on other.party_id = case when f.party_id = 5 then t.party_id else f.party_id end
where 5 in (f.party_id, t.party_id)
order by relationship;

-- name: 2.6a — Org chart: every unit's chain up to the top (recursive walk over ORGANIZATION_ROLLUP)
with recursive chain (unit_party_id, parent_party_id, depth) as (
  select c.party_id, p.party_id, 1
  from party_relationship pr
  join party_role c on c.party_role_id = pr.from_party_role_id
  join party_role p on p.party_role_id = pr.to_party_role_id
  where pr.party_relationship_type_id = 'ORGANIZATION_ROLLUP' and pr.thru_date is null
  union all
  select ch.unit_party_id, p.party_id, ch.depth + 1
  from chain ch
  join party_role c on c.party_id = ch.parent_party_id
  join party_relationship pr on pr.from_party_role_id = c.party_role_id
                            and pr.party_relationship_type_id = 'ORGANIZATION_ROLLUP'
                            and pr.thru_date is null
  join party_role p on p.party_role_id = pr.to_party_role_id
  where ch.depth < 10   -- guard against cycles
)
select u.name as unit, p.name as rolls_up_to, depth
from chain
join party_display_name u on u.party_id = unit_party_id
join party_display_name p on p.party_id = parent_party_id
order by unit, depth;

-- name: 2.6a — Consistency check: 2.5's employment table and 2.6a's generic rows agree (should be empty)
(select employer_party_role_id, employee_party_role_id, from_date from employment
 except
 select from_party_role_id, to_party_role_id, from_date from party_relationship
 where party_relationship_type_id = 'EMPLOYMENT')
union all
(select from_party_role_id, to_party_role_id, from_date from party_relationship
 where party_relationship_type_id = 'EMPLOYMENT'
 except
 select employer_party_role_id, employee_party_role_id, from_date from employment);

-- name: 2.6a — Data-quality check: relationships whose roles don't fit their type, at any depth of the role hierarchy (should be empty)
select pr.party_relationship_id, pr.party_relationship_type_id,
       f.role_type_id as from_role, rt.from_role_type_id as expected_from,
       t.role_type_id as to_role,   rt.to_role_type_id   as expected_to
from party_relationship pr
join party_relationship_type rt on rt.party_relationship_type_id = pr.party_relationship_type_id
join party_role f on f.party_role_id = pr.from_party_role_id
join party_role t on t.party_role_id = pr.to_party_role_id
where not exists (select 1 from role_type_ancestor a
                  where a.role_type_id = f.role_type_id and a.ancestor_id = rt.from_role_type_id)
   or not exists (select 1 from role_type_ancestor a
                  where a.role_type_id = t.role_type_id and a.ancestor_id = rt.to_role_type_id);

-- ============================================================
-- Table 2.5 — the book's organization-to-organization example
-- ============================================================

-- name: Table 2.5 — Rebuilt from our rows (compare with the book)
select rt.name as relationship,
       fp.name as from_party, ft.description as from_role,
       tp.name as to_party,   tt.description as to_role,
       pr.from_date, pr.thru_date
from party_relationship pr
join party_relationship_type rt on rt.party_relationship_type_id = pr.party_relationship_type_id
join party_role f on f.party_role_id = pr.from_party_role_id
join party_role t on t.party_role_id = pr.to_party_role_id
join role_type ft on ft.role_type_id = f.role_type_id
join role_type tt on tt.role_type_id = t.role_type_id
join party_display_name fp on fp.party_id = f.party_id
join party_display_name tp on tp.party_id = t.party_id
where pr.party_relationship_id between 11 and 16
order by pr.party_relationship_id;

-- name: Table 2.5 — One party, many roles, each role in many relationships (ABC Subsidiary)
select t.description as role, r.party_role_id,
       count(pr.party_relationship_id) as relationships_it_takes_part_in
from party_role r
join role_type t using (role_type_id)
left join party_relationship pr
  on r.party_role_id in (pr.from_party_role_id, pr.to_party_role_id)
where r.party_id = 13
group by t.description, r.party_role_id
order by r.party_role_id;

-- ============================================================
-- Fig 2.7 — Party relationship information
-- ============================================================

-- name: 2.7 — Current relationships by priority, with status
select rt.name as relationship, fp.name as from_party, tp.name as to_party,
       coalesce(p.description, '—') as priority, coalesce(s.description, '—') as status
from party_relationship pr
join party_relationship_type rt on rt.party_relationship_type_id = pr.party_relationship_type_id
join party_role f on f.party_role_id = pr.from_party_role_id
join party_role t on t.party_role_id = pr.to_party_role_id
join party_display_name fp on fp.party_id = f.party_id
join party_display_name tp on tp.party_id = t.party_id
left join priority_type p on p.priority_type_id = pr.priority_type_id
left join status_type s   on s.status_type_id   = pr.status_type_id
where pr.thru_date is null
order by case pr.priority_type_id when 'HIGH' then 1 when 'MEDIUM' then 2 when 'LOW' then 3 else 4 end,
         relationship, from_party;

-- name: 2.7 — Contact history with Contoso, across every relationship it is part of
select ce.datetime_started, rt.name as in_relationship, ce.note
from communication_event ce
join party_relationship pr on pr.party_relationship_id = ce.party_relationship_id
join party_relationship_type rt on rt.party_relationship_type_id = pr.party_relationship_type_id
join party_role f on f.party_role_id = pr.from_party_role_id
join party_role t on t.party_role_id = pr.to_party_role_id
where 5 in (f.party_id, t.party_id)
order by ce.datetime_started;

-- name: 2.7 — Active high-priority relationships and days since last contact
select fp.name as from_party, rt.name as relationship, tp.name as to_party,
       max(ce.datetime_started)::date as last_contact,
       current_date - max(ce.datetime_started)::date as days_since
from party_relationship pr
join party_relationship_type rt on rt.party_relationship_type_id = pr.party_relationship_type_id
join party_role f on f.party_role_id = pr.from_party_role_id
join party_role t on t.party_role_id = pr.to_party_role_id
join party_display_name fp on fp.party_id = f.party_id
join party_display_name tp on tp.party_id = t.party_id
left join communication_event ce on ce.party_relationship_id = pr.party_relationship_id
where pr.priority_type_id = 'HIGH' and pr.status_type_id = 'REL_ACTIVE'
group by fp.name, rt.name, tp.name
order by last_contact nulls first;

-- name: 2.7 — Data-quality check: relationships using a status that isn't a relationship status (should be empty)
select pr.party_relationship_id, pr.status_type_id
from party_relationship pr
join status_type s on s.status_type_id = pr.status_type_id
where coalesce(s.parent_type_id, '') <> 'PARTY_RELATIONSHIP_STATUS';

-- name: 2.7 — Data-quality check: status contradicts the dates (should be empty)
select pr.party_relationship_id, pr.thru_date, pr.status_type_id
from party_relationship pr
where (pr.thru_date is not null and pr.thru_date <= current_date and pr.status_type_id = 'REL_ACTIVE')
   or (pr.thru_date is null and pr.status_type_id = 'REL_INACTIVE');

-- name: 2.7 — Data-quality check: communication events outside their relationship's period (should be empty)
select ce.communication_event_id, ce.datetime_started::date as event_date,
       pr.from_date, pr.thru_date, ce.note
from communication_event ce
join party_relationship pr on pr.party_relationship_id = ce.party_relationship_id
where ce.datetime_started::date < pr.from_date
   or (pr.thru_date is not null and ce.datetime_started::date >= pr.thru_date);

-- ============================================================
-- Fig 2.8 — Postal address information
-- ============================================================
-- Since 2.10 an address is a contact mechanism: parties reach it through
-- party_contact_mechanism, and postal_address shares contact_mechanism_id.

-- name: 2.8 — Mailing labels: current addresses with city, state, postal code and country (rebuilt from boundaries)
select d.name,
       a.address1, a.address2,
       max(g.name) filter (where g.geographic_boundary_type_id = 'CITY')         as city,
       max(g.abbreviation) filter (where g.geographic_boundary_type_id = 'STATE') as state,
       max(g.geo_code) filter (where g.geographic_boundary_type_id = 'POSTAL_CODE') as postal_code,
       max(g.name) filter (where g.geographic_boundary_type_id = 'COUNTRY')      as country
from party_contact_mechanism pcm
join postal_address a using (contact_mechanism_id)
join party_display_name d using (party_id)
left join postal_address_boundary pab using (contact_mechanism_id)
left join geographic_boundary g using (geographic_boundary_id)
where pcm.thru_date is null
group by d.name, a.contact_mechanism_id, a.address1, a.address2
order by d.name, a.address1;

-- name: 2.8 — Where did Ana live on 2015-01-01? (the move keeps history)
select a.address1, a.address2, pcm.from_date, pcm.thru_date
from party_contact_mechanism pcm
join postal_address a using (contact_mechanism_id)
where pcm.party_id = 1
  and pcm.from_date <= date '2015-01-01'
  and (pcm.thru_date is null or pcm.thru_date > date '2015-01-01');

-- name: 2.8 — Addresses shared by more than one party
select a.address1, string_agg(d.name, ', ' order by d.name) as parties
from party_contact_mechanism pcm
join postal_address a using (contact_mechanism_id)
join party_display_name d using (party_id)
where pcm.thru_date is null
group by a.contact_mechanism_id, a.address1
having count(*) > 1;

-- name: 2.8 — Postal codes that cross more than one city
select pc.geo_code as postal_code, string_agg(c.name, ', ' order by c.name) as cities
from geographic_boundary_association x
join geographic_boundary pc on pc.geographic_boundary_id = x.from_geographic_boundary_id
join geographic_boundary c  on c.geographic_boundary_id  = x.to_geographic_boundary_id
where pc.geographic_boundary_type_id = 'POSTAL_CODE'
  and c.geographic_boundary_type_id  = 'CITY'
group by pc.geo_code
having count(*) > 1;

-- name: 2.8 — Parties with a current address anywhere inside the Midwest Sales territory (any depth)
select distinct d.name, a.address1
from party_contact_mechanism pcm
join postal_address a using (contact_mechanism_id)
join postal_address_boundary pab using (contact_mechanism_id)
join geographic_boundary_ancestor anc on anc.geographic_boundary_id = pab.geographic_boundary_id
join party_display_name d using (party_id)
where anc.ancestor_id = 30
  and pcm.thru_date is null
order by d.name;

-- name: 2.8 — Data-quality check: addresses without a city or a country (should be empty)
select a.contact_mechanism_id, a.address1,
       bool_or(g.geographic_boundary_type_id = 'CITY')    is true as has_city,
       bool_or(g.geographic_boundary_type_id = 'COUNTRY') is true as has_country
from postal_address a
left join postal_address_boundary pab using (contact_mechanism_id)
left join geographic_boundary g using (geographic_boundary_id)
group by a.contact_mechanism_id, a.address1
having not (bool_or(g.geographic_boundary_type_id = 'CITY')    is true
        and bool_or(g.geographic_boundary_type_id = 'COUNTRY') is true);

-- name: 2.8 — Data-quality check: citizenships that point at something other than a country (should be empty)
select c.citizenship_id, d.name, g.name as boundary, g.geographic_boundary_type_id
from citizenship c
join geographic_boundary g on g.geographic_boundary_id = c.country_id
join party_display_name d on d.party_id = c.party_id
where g.geographic_boundary_type_id <> 'COUNTRY';

-- ============================================================
-- Fig 2.9 — Party contact mechanism: telecommunications numbers and electronic addresses
-- ============================================================

-- name: 2.9 — Contact sheet: every party's current contact mechanisms, formatted by subtype
select d.name, t.description as type,
       coalesce('+' || tn.country_code || ' ', '') || tn.area_code || ' ' || tn.contact_number as phone,
       ea.electronic_address_string as electronic_address,
       pcm.non_solicitation_ind as do_not_solicit
from party_contact_mechanism pcm
join contact_mechanism cm using (contact_mechanism_id)
join contact_mechanism_type t using (contact_mechanism_type_id)
join party_display_name d using (party_id)
left join telecommunications_number tn using (contact_mechanism_id)
left join electronic_address ea using (contact_mechanism_id)
where pcm.thru_date is null
order by d.name, t.description;

-- name: 2.9 — Who may we e-mail a promotion to? (same inbox, different answer per party)
select d.name, ea.electronic_address_string,
       case when pcm.non_solicitation_ind then 'no: opted out' else 'yes' end as may_solicit
from party_contact_mechanism pcm
join contact_mechanism cm using (contact_mechanism_id)
join electronic_address ea using (contact_mechanism_id)
join party_display_name d using (party_id)
where cm.contact_mechanism_type_id = 'EMAIL'
  and pcm.thru_date is null
order by ea.electronic_address_string, d.name;

-- name: 2.9 — Mechanisms shared by more than one party
select cm.contact_mechanism_id, t.description as type,
       string_agg(d.name, ', ' order by d.name) as parties
from party_contact_mechanism pcm
join contact_mechanism cm using (contact_mechanism_id)
join contact_mechanism_type t using (contact_mechanism_type_id)
join party_display_name d using (party_id)
where pcm.thru_date is null
group by cm.contact_mechanism_id, t.description
having count(*) > 1;

-- name: 2.9 — How could we reach Ana on 2015-01-01? (history kept, like her address in 2.8)
select t.description as type,
       coalesce('+' || tn.country_code || ' ', '') || tn.area_code || ' ' || tn.contact_number as phone,
       ea.electronic_address_string as electronic_address
from party_contact_mechanism pcm
join contact_mechanism cm using (contact_mechanism_id)
join contact_mechanism_type t using (contact_mechanism_type_id)
left join telecommunications_number tn using (contact_mechanism_id)
left join electronic_address ea using (contact_mechanism_id)
where pcm.party_id = 1
  and pcm.from_date <= date '2015-01-01'
  and (pcm.thru_date is null or pcm.thru_date > date '2015-01-01');

-- name: 2.9 — Data-quality check: mechanisms without exactly the subtype row their kind says (should be empty; postal addresses since 2.10)
with subtype_row as (
  select contact_mechanism_id, 'POSTAL_ADDRESS' as kind from postal_address
  union all
  select contact_mechanism_id, 'TELECOMMUNICATIONS_NUMBER' from telecommunications_number
  union all
  select contact_mechanism_id, 'ELECTRONIC_ADDRESS' from electronic_address
)
select cm.contact_mechanism_id, cm.contact_mechanism_kind,
       string_agg(s.kind, ', ') as subtype_rows_found
from contact_mechanism cm
left join subtype_row s using (contact_mechanism_id)
group by cm.contact_mechanism_id, cm.contact_mechanism_kind
having count(s.kind) <> 1 or bool_or(s.kind <> cm.contact_mechanism_kind);

-- name: 2.9 — Data-quality check: mechanisms whose type doesn't fit their kind (should be empty)
select cm.contact_mechanism_id, cm.contact_mechanism_kind, t.contact_mechanism_type_id, t.applies_to_kind
from contact_mechanism cm
join contact_mechanism_type t using (contact_mechanism_type_id)
where t.applies_to_kind <> cm.contact_mechanism_kind;

-- ============================================================
-- Fig 2.10 — Party contact mechanism (expanded)
-- ============================================================

-- name: 2.10 — Where do we ship to each party today? (purpose decides, whatever the mechanism)
select d.name, a.address1, p.from_date as shipping_since
from party_contact_mechanism_purpose p
join party_contact_mechanism pcm using (party_contact_mechanism_id)
join postal_address a using (contact_mechanism_id)
join party_display_name d using (party_id)
where p.contact_mechanism_purpose_type_id = 'SHIPPING'
  and p.thru_date is null and pcm.thru_date is null
order by d.name;

-- name: 2.10 — Ana's contact points with every current purpose, across all three subtypes
select cm.contact_mechanism_kind as kind,
       coalesce(a.address1,
                coalesce('+' || tn.country_code || ' ', '') || tn.area_code || ' ' || tn.contact_number,
                ea.electronic_address_string) as reach_at,
       pcm.extension,
       r.description as as_role,
       string_agg(pt.description, ', ' order by pt.description) as purposes
from party_contact_mechanism pcm
join contact_mechanism cm using (contact_mechanism_id)
left join postal_address a            using (contact_mechanism_id)
left join telecommunications_number tn using (contact_mechanism_id)
left join electronic_address ea       using (contact_mechanism_id)
left join role_type r using (role_type_id)
left join party_contact_mechanism_purpose p
       on p.party_contact_mechanism_id = pcm.party_contact_mechanism_id and p.thru_date is null
left join contact_mechanism_purpose_type pt using (contact_mechanism_purpose_type_id)
where pcm.party_id = 1 and pcm.thru_date is null
group by cm.contact_mechanism_kind, reach_at, pcm.extension, r.description
order by kind, reach_at;

-- name: 2.10 — Switchboard directory: one number, an extension per party
select d.name, tn.area_code || ' ' || tn.contact_number as number, pcm.extension
from party_contact_mechanism pcm
join telecommunications_number tn using (contact_mechanism_id)
join party_display_name d using (party_id)
where pcm.contact_mechanism_id = 1 and pcm.thru_date is null
order by pcm.extension nulls first;

-- name: 2.10 — Linked mechanisms (forwarding, fax tied to a phone)
select l.from_contact_mechanism_id as from_id, ft.description as from_type,
       l.to_contact_mechanism_id   as to_id,   tt.description as to_type
from contact_mechanism_link l
join contact_mechanism f on f.contact_mechanism_id = l.from_contact_mechanism_id
join contact_mechanism t on t.contact_mechanism_id = l.to_contact_mechanism_id
join contact_mechanism_type ft on ft.contact_mechanism_type_id = f.contact_mechanism_type_id
join contact_mechanism_type tt on tt.contact_mechanism_type_id = t.contact_mechanism_type_id;

-- name: 2.10 — Data-quality check: purposes outside their link's period (should be empty)
select p.party_contact_mechanism_purpose_id, d.name, p.contact_mechanism_purpose_type_id,
       p.from_date, p.thru_date, pcm.from_date as link_from, pcm.thru_date as link_thru
from party_contact_mechanism_purpose p
join party_contact_mechanism pcm using (party_contact_mechanism_id)
join party_display_name d using (party_id)
where p.from_date < pcm.from_date
   or (pcm.thru_date is not null and (p.thru_date is null or p.thru_date > pcm.thru_date));

-- name: 2.10 — Data-quality check: links specified for a role the party never plays during the link (should be empty)
select pcm.party_contact_mechanism_id, d.name, pcm.role_type_id
from party_contact_mechanism pcm
join party_display_name d using (party_id)
where pcm.role_type_id is not null
  and not exists (
    select 1
    from party_role r
    join role_type_ancestor anc on anc.role_type_id = r.role_type_id
    where r.party_id = pcm.party_id
      and anc.ancestor_id = pcm.role_type_id
      and r.from_date < coalesce(pcm.thru_date, 'infinity')
      and (r.thru_date is null or r.thru_date > pcm.from_date));

-- ============================================================
-- Fig 2.11 — Facility versus contact mechanism
-- ============================================================

-- name: 2.11 — Northwind HQ broken down: building → floors → rooms (recursive "part of")
with recursive tree (facility_id, path, depth) as (
  select facility_id, description, 0 from facility where facility_id = 1
  union all
  select f.facility_id, t.path || ' → ' || f.description, t.depth + 1
  from tree t
  join facility f on f.part_of_facility_id = t.facility_id
  where t.depth < 10   -- guard against cycles
)
select t.path, f.facility_type_id as type, f.square_footage
from tree t
join facility f using (facility_id)
order by t.path;

-- name: 2.11 — Who is involved with the Chatham warehouse, and how (several parties, one facility)
select d.name, rt.description as role, fr.from_date, fr.thru_date
from facility_role fr
join facility_role_type rt using (facility_role_type_id)
join party_display_name d using (party_id)
where fr.facility_id = 5
order by fr.from_date;

-- name: 2.11 — Facility directory: how to reach each facility (an address is not a facility)
select f.description as facility,
       coalesce(a.address1 || coalesce(', ' || a.address2, ''),
                tn.area_code || ' ' || tn.contact_number) as reach_at
from facility_contact_mechanism fcm
join facility f using (facility_id)
left join postal_address a             using (contact_mechanism_id)
left join telecommunications_number tn using (contact_mechanism_id)
where fcm.thru_date is null
order by f.description, reach_at;

-- name: 2.11 — Addresses shared by more than one facility
select a.address1, string_agg(f.description, ', ' order by f.description) as facilities
from facility_contact_mechanism fcm
join postal_address a using (contact_mechanism_id)
join facility f using (facility_id)
where fcm.thru_date is null
group by a.contact_mechanism_id, a.address1
having count(*) > 1;

-- name: 2.11 — Space Northwind currently owns or leases (summing a building AND its floors would count space twice)
select f.description, rt.description as role, f.square_footage
from facility_role fr
join facility f using (facility_id)
join facility_role_type rt using (facility_role_type_id)
where fr.party_id = 4
  and fr.facility_role_type_id in ('OWNER', 'LESSEE')
  and fr.thru_date is null
union all
select 'Total', null, sum(f.square_footage)
from facility_role fr
join facility f using (facility_id)
where fr.party_id = 4
  and fr.facility_role_type_id in ('OWNER', 'LESSEE')
  and fr.thru_date is null;

-- name: 2.11 — Data-quality check: facilities that end up part of themselves (should be empty)
with recursive walk (facility_id, ancestor_id, depth) as (
  select facility_id, part_of_facility_id, 1 from facility where part_of_facility_id is not null
  union all
  select w.facility_id, f.part_of_facility_id, w.depth + 1
  from walk w
  join facility f on f.facility_id = w.ancestor_id
  where f.part_of_facility_id is not null and w.depth < 10
)
select distinct f.facility_id, f.description
from walk w
join facility f using (facility_id)
where w.ancestor_id = w.facility_id;
