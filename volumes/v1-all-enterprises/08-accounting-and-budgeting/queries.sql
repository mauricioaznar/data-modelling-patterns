-- Vol 1, Chapter 8: Accounting and Budgeting — queries
-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/08

-- ============================================================
-- Fig 8.1 — Chart of accounts for internal organizations
-- ============================================================

-- name: 8.1 — Table 8.1 and the rest of the chart: every account by type, with how many organizations use it today
select t.description as account_type, a.general_ledger_account_id as account, a.name,
       count(o.organization_gl_account_id) filter (where o.from_date <= current_date and (o.thru_date is null or o.thru_date > current_date)) as organizations_now
from general_ledger_account a
join general_ledger_account_type t on t.general_ledger_account_type_id = a.general_ledger_account_type_id
left join organization_gl_account o on o.general_ledger_account_id = a.general_ledger_account_id
group by t.description, a.general_ledger_account_id, a.name
order by a.general_ledger_account_id;

-- name: 8.1 — Table 8.2: each organization's accounts with their dates (thru shown inclusive, as the book prints it)
select n.name as organization, a.general_ledger_account_id as account, a.name, a.general_ledger_account_type_id as type,
       o.from_date, o.thru_date - 1 as thru_inclusive
from organization_gl_account o
join organization n            on n.party_id = o.internal_organization_party_id
join general_ledger_account a  on a.general_ledger_account_id = o.general_ledger_account_id
order by n.name, a.general_ledger_account_id, o.from_date;

-- name: 8.1 — ABC Corporation's chart on Jun 30, 1996 and on Jun 30, 2000: marketing gives way to advertising and trade shows
select d.as_of, string_agg(a.general_ledger_account_id || ' ' || a.name, ', ' order by a.general_ledger_account_id) as accounts
from (values (date '1996-06-30'), (date '2000-06-30')) d(as_of)
join organization_gl_account o on o.internal_organization_party_id = 12
                              and o.from_date <= d.as_of and (o.thru_date is null or o.thru_date > d.as_of)
join general_ledger_account a  on a.general_ledger_account_id = o.general_ledger_account_id
where a.general_ledger_account_type_id = 'EXPENSE'
group by d.as_of
order by d.as_of;

-- name: 8.1 — Each organization's periods as a tree: years, then the quarters and months within them
with recursive tree as (
  select p.accounting_period_id, p.internal_organization_party_id, p.period_type_id, p.acctg_period_num,
         p.from_date, p.thru_date, 0 as depth, lpad(p.from_date::text, 10) as path
  from accounting_period p where p.within_accounting_period_id is null
  union all
  select c.accounting_period_id, c.internal_organization_party_id, c.period_type_id, c.acctg_period_num,
         c.from_date, c.thru_date, t.depth + 1, t.path || '/' || c.from_date::text
  from accounting_period c join tree t on t.accounting_period_id = c.within_accounting_period_id
)
select n.name as organization, repeat('  ', t.depth) || t.period_type_id || ' ' || t.acctg_period_num as period,
       t.from_date, t.thru_date - 1 as thru_inclusive
from tree t join organization n on n.party_id = t.internal_organization_party_id
order by n.name, t.path;

-- name: 8.1 — Data-quality check: accounts kept by organizations that were never one of our internal organizations (should be empty)
select o.organization_gl_account_id, n.name as organization, o.general_ledger_account_id as account
from organization_gl_account o
join organization n on n.party_id = o.internal_organization_party_id
where not exists (select 1 from party_role r
                  where r.party_id = o.internal_organization_party_id and r.role_type_id = 'INTERNAL_ORGANIZATION');

-- name: 8.1 — Data-quality check: the same account kept twice by one organization over overlapping dates (should be empty)
select n.name as organization, a.general_ledger_account_id as account,
       a1.organization_gl_account_id as first_row, a2.organization_gl_account_id as second_row
from organization_gl_account a1
join organization_gl_account a2 on a2.internal_organization_party_id = a1.internal_organization_party_id
                               and a2.general_ledger_account_id = a1.general_ledger_account_id
                               and a2.organization_gl_account_id > a1.organization_gl_account_id
                               and a2.from_date < coalesce(a1.thru_date, 'infinity')
                               and a1.from_date < coalesce(a2.thru_date, 'infinity')
join organization n            on n.party_id = a1.internal_organization_party_id
join general_ledger_account a  on a.general_ledger_account_id = a1.general_ledger_account_id;

-- name: 8.1 — Data-quality check: periods within a period of another organization, or not inside its dates (should be empty)
select c.accounting_period_id, c.period_type_id, c.from_date, c.thru_date,
       p.accounting_period_id as within_period, p.from_date as within_from, p.thru_date as within_thru,
       c.internal_organization_party_id <> p.internal_organization_party_id as other_organization
from accounting_period c
join accounting_period p on p.accounting_period_id = c.within_accounting_period_id
where c.internal_organization_party_id <> p.internal_organization_party_id
   or c.from_date < p.from_date or c.thru_date > p.thru_date;
