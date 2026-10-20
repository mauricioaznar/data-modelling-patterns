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
                               -- Fig 8.4: subsidiaries share their parent's number, so a duplicate also shares what it tracks
                               and a2.subsidiary_of_organization_gl_account_id is not distinct from a1.subsidiary_of_organization_gl_account_id
                               and a2.supplier_party_role_id is not distinct from a1.supplier_party_role_id
                               and a2.bill_to_customer_party_role_id is not distinct from a1.bill_to_customer_party_role_id
                               and a2.product_category_id is not distinct from a1.product_category_id
                               and a2.product_id is not distinct from a1.product_id
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

-- ============================================================
-- Fig 8.2 — Accounting transactions
-- ============================================================

-- name: 8.2 — Table 8.3: each transaction with its sender and receiver, its type and the book's subtype it falls under
select x.accounting_transaction_id as transaction, f.name as from_party, t.name as to_party,
       x.transaction_date, x.entry_date, y.description as type, c.subtype_id, c.root_id, x.description
from accounting_transaction x
join accounting_transaction_type y       on y.accounting_transaction_type_id = x.accounting_transaction_type_id
join accounting_transaction_type_class c on c.type_id = x.accounting_transaction_type_id
join party_display_name f                on f.party_id = x.from_party_id
left join party_display_name t           on t.party_id = x.to_party_id
order by x.transaction_date, x.accounting_transaction_id;

-- name: 8.2 — The type tree: every type under its subtype and group, with how many transactions use it
select c.root_id, c.external_group_id, c.subtype_id, y.accounting_transaction_type_id as type, y.description,
       count(x.accounting_transaction_id) as transactions
from accounting_transaction_type y
join accounting_transaction_type_class c on c.type_id = y.accounting_transaction_type_id
left join accounting_transaction x       on x.accounting_transaction_type_id = y.accounting_transaction_type_id
group by c.root_id, c.external_group_id, c.subtype_id, y.accounting_transaction_type_id, y.description
order by c.root_id, c.external_group_id nulls first, c.subtype_id nulls first, y.accounting_transaction_type_id;

-- name: 8.2 — From the ledger back to the document: each transaction with the invoice, payment or count it posts
select x.accounting_transaction_id as transaction, c.subtype_id,
       coalesce('invoice ' || x.invoice_id, 'payment ' || x.payment_id, 'variance ' || x.inventory_item_variance_id) as document,
       coalesce(v.invoice_date, p.effective_date, iv.physical_inventory_date) as document_date,
       coalesce(it.total_due, p.amount) as document_amount, x.transaction_date
from accounting_transaction x
join accounting_transaction_type_class c on c.type_id = x.accounting_transaction_type_id
left join invoice v                      on v.invoice_id = x.invoice_id
left join invoice_total it               on it.invoice_id = x.invoice_id
left join payment p                      on p.payment_id = x.payment_id
left join inventory_item_variance iv     on iv.inventory_item_variance_id = x.inventory_item_variance_id
where num_nonnulls(x.invoice_id, x.payment_id, x.inventory_item_variance_id) = 1
order by x.accounting_transaction_id;

-- name: 8.2 — Review: sales, payment and variance transactions with no source document (Table 8.3's: the book names none; NOTES, point 5)
select x.accounting_transaction_id as transaction, c.subtype_id, x.transaction_date, x.description
from accounting_transaction x
join accounting_transaction_type_class c on c.type_id = x.accounting_transaction_type_id
where c.subtype_id in ('SALES', 'RECEIPT', 'DISBURSEMENT', 'ITEM_VARIANCE')
  and num_nonnulls(x.invoice_id, x.payment_id, x.inventory_item_variance_id) = 0
order by x.accounting_transaction_id;

-- name: 8.2 — Data-quality check: transactions typed with a grouping row (INTERNAL, EXTERNAL, OBLIGATION, PAYMENT) instead of a kind of event (should be empty)
select x.accounting_transaction_id, x.accounting_transaction_type_id, x.description
from accounting_transaction x
join accounting_transaction_type_class c on c.type_id = x.accounting_transaction_type_id
where c.subtype_id is null;

-- name: 8.2 — Data-quality check: parties that don't fit the subtype: an internal transaction with a receiver or not from one of our organizations, an external one with no receiver or none of our organizations at either end (should be empty)
select x.accounting_transaction_id, c.root_id, f.name as from_party, t.name as to_party
from accounting_transaction x
join accounting_transaction_type_class c on c.type_id = x.accounting_transaction_type_id
join party_display_name f                on f.party_id = x.from_party_id
left join party_display_name t           on t.party_id = x.to_party_id
where (c.root_id = 'INTERNAL'
       and (x.to_party_id is not null
            or not exists (select 1 from party_role r
                           where r.party_id = x.from_party_id and r.role_type_id = 'INTERNAL_ORGANIZATION'
                             and r.from_date <= x.transaction_date and (r.thru_date is null or r.thru_date > x.transaction_date))))
   or (c.root_id = 'EXTERNAL'
       and (x.to_party_id is null
            or not exists (select 1 from party_role r
                           where r.party_id in (x.from_party_id, x.to_party_id) and r.role_type_id = 'INTERNAL_ORGANIZATION'
                             and r.from_date <= x.transaction_date and (r.thru_date is null or r.thru_date > x.transaction_date))));

-- name: 8.2 — Data-quality check: source documents on the wrong subtype: an invoice not on a sales transaction, a payment not on a receipt or disbursement of its own kind, a variance not on an item variance (should be empty)
select x.accounting_transaction_id, c.subtype_id, x.invoice_id, x.payment_id, p.payment_kind, x.inventory_item_variance_id
from accounting_transaction x
join accounting_transaction_type_class c on c.type_id = x.accounting_transaction_type_id
left join payment p                      on p.payment_id = x.payment_id
where (x.invoice_id is not null and c.subtype_id is distinct from 'SALES')
   or (x.payment_id is not null and c.subtype_id is distinct from p.payment_kind)
   or (x.inventory_item_variance_id is not null and c.subtype_id is distinct from 'ITEM_VARIANCE');

-- ============================================================
-- Fig 8.3a — Accounting transaction details
-- ============================================================

-- name: 8.3a — Tables 8.4–8.5: each transaction's postings, the organization's account each goes to, and the posting it settles
select x.accounting_transaction_id as transaction, x.description, d.trans_detail_seq_id as seq, d.amount, d.debit_credit_flag,
       a.name || ' (' || n.name || ')' as organization_gl_account,
       ad.accounting_transaction_id || ', ' || ad.trans_detail_seq_id as associated_with
from transaction_detail d
join accounting_transaction x       on x.accounting_transaction_id = d.accounting_transaction_id
join organization_gl_account o      on o.organization_gl_account_id = d.organization_gl_account_id
join general_ledger_account a       on a.general_ledger_account_id = o.general_ledger_account_id
join organization n                 on n.party_id = o.internal_organization_party_id
left join transaction_detail ad     on ad.transaction_detail_id = d.associated_with_transaction_detail_id
where x.accounting_transaction_id in (32389, 38948, 39776, 47874, 50984, 50999, 60985)
order by x.accounting_transaction_id, d.trans_detail_seq_id;

-- name: 8.3a — What each transaction is worth: its debits, which Table 8.3 prints as the amount (39776 shows 700 there: NOTES, point 4)
select x.accounting_transaction_id as transaction, x.transaction_date, x.description,
       sum(d.amount) filter (where d.debit_credit_flag = 'DEBIT')  as debits,
       sum(d.amount) filter (where d.debit_credit_flag = 'CREDIT') as credits
from accounting_transaction x
join transaction_detail d on d.accounting_transaction_id = x.accounting_transaction_id
group by x.accounting_transaction_id, x.transaction_date, x.description
order by x.transaction_date, x.accounting_transaction_id;

-- name: 8.3a — Open receivables, debit by debit: what each receivable posting still has open after the credits associated with it, and the credits that settle nothing
select x.accounting_transaction_id as transaction, x.transaction_date, x.description, d.debit_credit_flag, d.amount,
       coalesce((select sum(s.amount) from transaction_detail s where s.associated_with_transaction_detail_id = d.transaction_detail_id), 0) as settled,
       d.amount - coalesce((select sum(s.amount) from transaction_detail s where s.associated_with_transaction_detail_id = d.transaction_detail_id), 0) as still_open
from transaction_detail d
join accounting_transaction x  on x.accounting_transaction_id = d.accounting_transaction_id
join organization_gl_account o on o.organization_gl_account_id = d.organization_gl_account_id
where o.general_ledger_account_id = 120
  and ((d.debit_credit_flag = 'DEBIT' and not exists (select 1 from transaction_detail t where t.transaction_detail_id = d.associated_with_transaction_detail_id))
       or (d.debit_credit_flag = 'CREDIT' and d.associated_with_transaction_detail_id is null))
order by o.internal_organization_party_id, x.transaction_date, x.accounting_transaction_id;

-- name: 8.3a — Trial balance of each organization at the end of 2000: every account's debits, credits and balance (debits − credits); the balances sum to zero when the books balance
select n.name as organization, a.general_ledger_account_id as account, a.name,
       sum(d.amount) filter (where d.debit_credit_flag = 'DEBIT')  as debits,
       sum(d.amount) filter (where d.debit_credit_flag = 'CREDIT') as credits,
       sum(case d.debit_credit_flag when 'DEBIT' then d.amount else -d.amount end) as balance
from transaction_detail d
join accounting_transaction x  on x.accounting_transaction_id = d.accounting_transaction_id
join organization_gl_account o on o.organization_gl_account_id = d.organization_gl_account_id
join general_ledger_account a  on a.general_ledger_account_id = o.general_ledger_account_id
join organization n            on n.party_id = o.internal_organization_party_id
where x.transaction_date < date '2001-01-01'
group by rollup ((n.name, a.general_ledger_account_id, a.name))
order by n.name nulls last, a.general_ledger_account_id;

-- name: 8.3a — Data-quality check: transactions that don't balance (debits ≠ credits) or have fewer than two postings (should be empty)
select x.accounting_transaction_id, count(d.transaction_detail_id) as postings,
       coalesce(sum(d.amount) filter (where d.debit_credit_flag = 'DEBIT'), 0)  as debits,
       coalesce(sum(d.amount) filter (where d.debit_credit_flag = 'CREDIT'), 0) as credits
from accounting_transaction x
left join transaction_detail d on d.accounting_transaction_id = x.accounting_transaction_id
group by x.accounting_transaction_id
having count(d.transaction_detail_id) < 2
    or coalesce(sum(d.amount) filter (where d.debit_credit_flag = 'DEBIT'), 0)
       <> coalesce(sum(d.amount) filter (where d.debit_credit_flag = 'CREDIT'), 0);

-- name: 8.3a — Data-quality check: postings to an organization's account that wasn't open on the transaction date (should be empty)
select d.transaction_detail_id, x.transaction_date, a.name as account, o.from_date, o.thru_date
from transaction_detail d
join accounting_transaction x  on x.accounting_transaction_id = d.accounting_transaction_id
join organization_gl_account o on o.organization_gl_account_id = d.organization_gl_account_id
join general_ledger_account a  on a.general_ledger_account_id = o.general_ledger_account_id
where not (o.from_date <= x.transaction_date and (o.thru_date is null or o.thru_date > x.transaction_date));

-- name: 8.3a — Data-quality check: postings to the books of an organization that isn't a party to the transaction (should be empty)
select d.transaction_detail_id, x.accounting_transaction_id, n.name as books_of, f.name as from_party, t.name as to_party
from transaction_detail d
join accounting_transaction x    on x.accounting_transaction_id = d.accounting_transaction_id
join organization_gl_account o   on o.organization_gl_account_id = d.organization_gl_account_id
join organization n              on n.party_id = o.internal_organization_party_id
join party_display_name f        on f.party_id = x.from_party_id
left join party_display_name t   on t.party_id = x.to_party_id
where o.internal_organization_party_id not in (x.from_party_id, coalesce(x.to_party_id, x.from_party_id));

-- ============================================================
-- Fig 8.3b — Accounting transaction detail with account balances
-- ============================================================

-- name: 8.3b — ABC Corporation's 2000 closing as stored, grouped the way the statements read it (balance sheet: assets, liabilities, equity; income statement: revenue, expense)
select case when a.general_ledger_account_type_id in ('REVENUE', 'EXPENSE') then 'Income statement' else 'Balance sheet' end as statement,
       t.description as account_type, a.general_ledger_account_id as account, a.name, b.amount as stored_balance
from organization_gl_account_balance b
join organization_gl_account o       on o.organization_gl_account_id = b.organization_gl_account_id
join general_ledger_account a        on a.general_ledger_account_id = o.general_ledger_account_id
join general_ledger_account_type t   on t.general_ledger_account_type_id = a.general_ledger_account_type_id
where b.accounting_period_id = 1 and o.internal_organization_party_id = 12
order by statement, a.general_ledger_account_id;

-- name: 8.3b — ABC Corporation's 2000 profit from the stored balances: revenue less expense (credits are negative, so the sign flips)
select -sum(b.amount) as profit_2000
from organization_gl_account_balance b
join organization_gl_account o on o.organization_gl_account_id = b.organization_gl_account_id
join general_ledger_account a  on a.general_ledger_account_id = o.general_ledger_account_id
where b.accounting_period_id = 1 and o.internal_organization_party_id = 12
  and a.general_ledger_account_type_id in ('REVENUE', 'EXPENSE');

-- name: 8.3b — Data-quality check: stored balances that disagree with the postings of their period (should be empty)
select b.organization_gl_account_balance_id, a.name as account, p.from_date, p.thru_date, b.amount as stored,
       coalesce(sum(case d.debit_credit_flag when 'DEBIT' then d.amount else -d.amount end), 0) as from_postings
from organization_gl_account_balance b
join accounting_period p             on p.accounting_period_id = b.accounting_period_id
join organization_gl_account o       on o.organization_gl_account_id = b.organization_gl_account_id
join general_ledger_account a        on a.general_ledger_account_id = o.general_ledger_account_id
left join transaction_detail d       on d.organization_gl_account_id = b.organization_gl_account_id
                                    and exists (select 1 from accounting_transaction x
                                                where x.accounting_transaction_id = d.accounting_transaction_id
                                                  and x.transaction_date >= p.from_date and x.transaction_date < p.thru_date)
group by b.organization_gl_account_balance_id, a.name, p.from_date, p.thru_date, b.amount
having b.amount <> coalesce(sum(case d.debit_credit_flag when 'DEBIT' then d.amount else -d.amount end), 0);

-- name: 8.3b — Data-quality check: balances whose period belongs to another organization than the account (should be empty)
select b.organization_gl_account_balance_id, na.name as account_of, np.name as period_of, p.period_type_id, p.acctg_period_num
from organization_gl_account_balance b
join organization_gl_account o on o.organization_gl_account_id = b.organization_gl_account_id
join accounting_period p       on p.accounting_period_id = b.accounting_period_id
join organization na           on na.party_id = o.internal_organization_party_id
join organization np           on np.party_id = p.internal_organization_party_id
where o.internal_organization_party_id <> p.internal_organization_party_id;

-- ============================================================
-- Fig 8.4 — General ledger account associations and subsidiary ledger accounts
-- ============================================================

-- name: 8.4 — Control accounts as trees: each control account, its subsidiaries, and what each one is about
with recursive tree as (
  select o.organization_gl_account_id, 0 as depth, lpad(o.organization_gl_account_id::text, 4) as path
  from organization_gl_account o
  where o.subsidiary_of_organization_gl_account_id is null
    and exists (select 1 from organization_gl_account x where x.subsidiary_of_organization_gl_account_id = o.organization_gl_account_id)
  union all
  select c.organization_gl_account_id, t.depth + 1, t.path || '/' || lpad(c.organization_gl_account_id::text, 4)
  from organization_gl_account c join tree t on t.organization_gl_account_id = c.subsidiary_of_organization_gl_account_id
)
select n.name as organization, repeat('  ', t.depth) || a.general_ledger_account_id || ' ' || a.name as account,
       coalesce('supplier ' || s.name, 'customer ' || b.name, 'category ' || pc.description, 'product ' || p.name) as about,
       o.organization_gl_account_id, o.from_date
from tree t
join organization_gl_account o     on o.organization_gl_account_id = t.organization_gl_account_id
join organization n                on n.party_id = o.internal_organization_party_id
join general_ledger_account a      on a.general_ledger_account_id = o.general_ledger_account_id
left join party_role sr            on sr.party_role_id = o.supplier_party_role_id
left join party_display_name s     on s.party_id = sr.party_id
left join party_role br            on br.party_role_id = o.bill_to_customer_party_role_id
left join party_display_name b     on b.party_id = br.party_id
left join product_category pc      on pc.product_category_id = o.product_category_id
left join product p                on p.product_id = o.product_id
order by t.path;

-- name: 8.4 — A control account's balance is its own postings plus its subsidiaries' (debits − credits, all time)
with recursive under as (
  select o.organization_gl_account_id as control_id, o.organization_gl_account_id as account_id
  from organization_gl_account o
  where o.subsidiary_of_organization_gl_account_id is null
  union all
  select u.control_id, c.organization_gl_account_id
  from under u join organization_gl_account c on c.subsidiary_of_organization_gl_account_id = u.account_id
),
posted as (
  select organization_gl_account_id,
         sum(case debit_credit_flag when 'DEBIT' then amount else -amount end) as balance
  from transaction_detail group by organization_gl_account_id
)
select n.name as organization, a.general_ledger_account_id || ' ' || a.name as control_account,
       coalesce(sum(p.balance) filter (where u.account_id = u.control_id), 0)  as own_postings,
       coalesce(sum(p.balance) filter (where u.account_id <> u.control_id), 0) as subsidiaries,
       coalesce(sum(p.balance), 0)                                             as balance
from under u
join organization_gl_account o on o.organization_gl_account_id = u.control_id
join organization n            on n.party_id = o.internal_organization_party_id
join general_ledger_account a  on a.general_ledger_account_id = o.general_ledger_account_id
left join posted p             on p.organization_gl_account_id = u.account_id
group by n.name, a.general_ledger_account_id, a.name, u.control_id
having count(*) > 1
order by n.name, a.general_ledger_account_id;

-- name: 8.4 — What does ACME owe ABC Subsidiary? The balance of the receivable account that references ACME's bill-to role
select n.name as organization, d.name as customer, o.organization_gl_account_id as account,
       sum(case t.debit_credit_flag when 'DEBIT' then t.amount else -t.amount end) as owed
from organization_gl_account o
join organization n          on n.party_id = o.internal_organization_party_id
join party_role r            on r.party_role_id = o.bill_to_customer_party_role_id
join party_display_name d    on d.party_id = r.party_id
join transaction_detail t    on t.organization_gl_account_id = o.organization_gl_account_id
where o.internal_organization_party_id = 13 and o.general_ledger_account_id = 120
group by n.name, d.name, o.organization_gl_account_id;

-- name: 8.4 — Data-quality check: subsidiary accounts of another organization or another account number, or outside their control account's dates (should be empty)
select c.organization_gl_account_id as subsidiary, c.internal_organization_party_id as sub_org, c.general_ledger_account_id as sub_account,
       p.organization_gl_account_id as control, p.internal_organization_party_id as control_org, p.general_ledger_account_id as control_account,
       c.from_date, p.from_date as control_from
from organization_gl_account c
join organization_gl_account p on p.organization_gl_account_id = c.subsidiary_of_organization_gl_account_id
where c.internal_organization_party_id <> p.internal_organization_party_id
   or c.general_ledger_account_id <> p.general_ledger_account_id
   or c.from_date < p.from_date
   or coalesce(c.thru_date, 'infinity') > coalesce(p.thru_date, 'infinity');

-- name: 8.4 — Data-quality check: supplier and customer references whose party role is something else (should be empty)
select o.organization_gl_account_id, d.name as party, r.role_type_id,
       case when o.supplier_party_role_id = r.party_role_id then 'SUPPLIER' else 'BILL_TO_CUSTOMER' end as expected
from organization_gl_account o
join party_role r          on r.party_role_id in (o.supplier_party_role_id, o.bill_to_customer_party_role_id)
join party_display_name d  on d.party_id = r.party_id
where (o.supplier_party_role_id = r.party_role_id and r.role_type_id <> 'SUPPLIER')
   or (o.bill_to_customer_party_role_id = r.party_role_id and r.role_type_id <> 'BILL_TO_CUSTOMER');

-- name: 8.4 — Review: accounts that reference more than one thing (no arc drawn, NOTES point 13)
select o.organization_gl_account_id,
       num_nonnulls(o.supplier_party_role_id, o.bill_to_customer_party_role_id, o.product_category_id, o.product_id) as references_count
from organization_gl_account o
where num_nonnulls(o.supplier_party_role_id, o.bill_to_customer_party_role_id, o.product_category_id, o.product_id) > 1;

-- ============================================================
-- Fig 8.5 — Asset depreciation
-- ============================================================

-- name: 8.5 — Table 8.6: each asset's depreciation methods over time (thru shown inclusive)
select a.name as fixed_asset, m.description as method, m.formula, d.from_date, d.thru_date - 1 as thru_inclusive
from fixed_asset_depreciation_method d
join fixed_asset a          on a.fixed_asset_id = d.fixed_asset_id
join depreciation_method m  on m.depreciation_method_id = d.depreciation_method_id
order by a.name, d.from_date;

-- name: 8.5 — Each depreciation with its asset, its amount and the method in force for that asset on the day
select x.accounting_transaction_id as transaction, x.transaction_date, a.name as fixed_asset,
       (select sum(t.amount) from transaction_detail t
        where t.accounting_transaction_id = x.accounting_transaction_id and t.debit_credit_flag = 'DEBIT') as amount,
       m.description as method_that_day
from accounting_transaction x
left join fixed_asset a on a.fixed_asset_id = x.fixed_asset_id
left join fixed_asset_depreciation_method d on d.fixed_asset_id = x.fixed_asset_id
                                           and d.from_date <= x.transaction_date and (d.thru_date is null or d.thru_date > x.transaction_date)
left join depreciation_method m on m.depreciation_method_id = d.depreciation_method_id
where x.accounting_transaction_type_id = 'DEPRECIATION'
order by x.transaction_date;

-- name: 8.5 — Data-quality check: depreciations of no asset, and assets on transactions that aren't depreciations (should be empty)
select x.accounting_transaction_id, x.accounting_transaction_type_id, x.fixed_asset_id, x.description
from accounting_transaction x
where (x.accounting_transaction_type_id = 'DEPRECIATION') <> (x.fixed_asset_id is not null);

-- name: 8.5 — Data-quality check: depreciations of an asset with no method in force that day (should be empty)
select x.accounting_transaction_id, x.transaction_date, a.name as fixed_asset
from accounting_transaction x
join fixed_asset a on a.fixed_asset_id = x.fixed_asset_id
where x.accounting_transaction_type_id = 'DEPRECIATION'
  and not exists (select 1 from fixed_asset_depreciation_method d
                  where d.fixed_asset_id = x.fixed_asset_id
                    and d.from_date <= x.transaction_date and (d.thru_date is null or d.thru_date > x.transaction_date));

-- name: 8.5 — Data-quality check: an asset depreciated by two methods at once (should be empty)
select a.name as fixed_asset, d1.depreciation_method_id as first_method, d1.from_date as first_from,
       d2.depreciation_method_id as second_method, d2.from_date as second_from
from fixed_asset_depreciation_method d1
join fixed_asset_depreciation_method d2 on d2.fixed_asset_id = d1.fixed_asset_id
                                       and d2.fixed_asset_depreciation_method_id > d1.fixed_asset_depreciation_method_id
                                       and d2.from_date < coalesce(d1.thru_date, 'infinity')
                                       and d1.from_date < coalesce(d2.thru_date, 'infinity')
join fixed_asset a on a.fixed_asset_id = d1.fixed_asset_id;

-- name: 8.5 — Review: fixed assets with no acquisition date, starred in Fig 8.5 (NOTES, point 16)
select fixed_asset_id, name, fixed_asset_type_id
from fixed_asset
where date_acquired is null;

-- ============================================================
-- Fig 8.6 — Budget definition
-- ============================================================

-- name: 8.6 — Table 8.7: each budget with its type, the party it is for, its period and the period's type
select b.budget_id, t.description as budget_type, d.name as budget_for,
       p.from_date, p.thru_date - 1 as thru_inclusive, pt.description as period_type, b.comment as description
from budget b
join budget_type t           on t.budget_type_id = b.budget_type_id
join standard_time_period p  on p.standard_time_period_id = b.standard_time_period_id
join period_type pt          on pt.period_type_id = p.period_type_id
left join budget_role r      on r.budget_id = b.budget_id and r.budget_role_type_id = 'BUDGET_FOR'
left join party_display_name d on d.party_id = r.party_id
order by b.budget_id;

-- name: 8.6 — Table 8.8: each budget's items as a tree, as first entered, and the budget's total (its top items only: parts break their parent down)
with recursive tree as (
  select i.budget_item_id, 0 as depth, lpad(i.budget_item_seq_id::text, 3) as path
  from budget_item i where i.part_of_budget_item_id is null
    -- Fig 8.7b: items a revision added are not in the budget as entered
    and not exists (select 1 from budget_revision_impact x where x.budget_item_id = i.budget_item_id and x.add_delete_flag = 'ADD')
  union all
  select c.budget_item_id, t.depth + 1, t.path || '/' || lpad(c.budget_item_seq_id::text, 3)
  from budget_item c join tree t on t.budget_item_id = c.part_of_budget_item_id
)
select i.budget_id, b.comment as budget, i.budget_item_seq_id as seq,
       repeat('  ', t.depth) || y.description as item, i.amount, i.purpose, i.justification,
       sum(i.amount) filter (where t.depth = 0) over (partition by i.budget_id) as budget_total
from tree t
join budget_item i       on i.budget_item_id = t.budget_item_id
join budget b            on b.budget_id = i.budget_id
join budget_item_type y  on y.budget_item_type_id = i.budget_item_type_id
order by i.budget_id, t.path;

-- name: 8.6 — Table 8.9: each budget's status history, the latest one marked current
select s.budget_id, s.status_date, t.description as status, s.comment,
       s.status_date = max(s.status_date) over (partition by s.budget_id) as current
from budget_status s
join status_type t on t.status_type_id = s.status_type_id
order by s.budget_id, s.status_date;

-- name: 8.6 — Budgets rolled up the organization: each 2001 budget's total as first entered, counted for its department and for every organization above it
with recursive totals as (
  select b.budget_id, b.standard_time_period_id, r.party_id, sum(i.amount) as total
  from budget b
  join budget_role r on r.budget_id = b.budget_id and r.budget_role_type_id = 'BUDGET_FOR'
  join budget_item i on i.budget_id = b.budget_id and i.part_of_budget_item_id is null
                    and not exists (select 1 from budget_revision_impact x where x.budget_item_id = i.budget_item_id and x.add_delete_flag = 'ADD')   -- Fig 8.7b
  group by b.budget_id, b.standard_time_period_id, r.party_id
),
up as (
  select t.budget_id, t.standard_time_period_id, t.total, t.party_id as org_id
  from totals t
  union all
  select u.budget_id, u.standard_time_period_id, u.total, hi.party_id
  from up u
  join party_role lo        on lo.party_id = u.org_id
  join party_relationship x on x.from_party_role_id = lo.party_role_id and x.party_relationship_type_id = 'ORGANIZATION_ROLLUP'
                           and x.thru_date is null
  join party_role hi        on hi.party_role_id = x.to_party_role_id
)
select d.name as organization, p.from_date as period_from, pt.description as period_type,
       count(*) as budgets, sum(u.total) as budgeted
from up u
join party_display_name d   on d.party_id = u.org_id
join standard_time_period p on p.standard_time_period_id = u.standard_time_period_id
join period_type pt         on pt.period_type_id = p.period_type_id
where p.from_date = '2001-01-01' and pt.period_type_id = 'YEAR'
group by d.name, p.from_date, pt.description
order by budgeted desc;

-- name: 8.6 — Data-quality check: budget statuses that aren't budget status types (should be empty)
select s.budget_status_id, s.budget_id, s.status_type_id, t.parent_type_id
from budget_status s
join status_type t on t.status_type_id = s.status_type_id
where t.parent_type_id is distinct from 'BUDGET_STATUS';

-- name: 8.6 — Data-quality check: budgets with no items, or for no party (should be empty)
select b.budget_id, b.comment,
       not exists (select 1 from budget_item i where i.budget_id = b.budget_id) as no_items,
       not exists (select 1 from budget_role r where r.budget_id = b.budget_id and r.budget_role_type_id = 'BUDGET_FOR') as for_no_one
from budget b
where not exists (select 1 from budget_item i where i.budget_id = b.budget_id)
   or not exists (select 1 from budget_role r where r.budget_id = b.budget_id and r.budget_role_type_id = 'BUDGET_FOR');

-- name: 8.6 — Data-quality check: item parts in another budget, or parts that don't add up to their parent (should be empty)
select p.budget_id, p.budget_item_seq_id as parent_seq, p.amount as parent_amount,
       sum(c.amount) as parts_total, bool_or(c.budget_id <> p.budget_id) as part_in_other_budget
from budget_item p
join budget_item c on c.part_of_budget_item_id = p.budget_item_id
group by p.budget_item_id, p.budget_id, p.budget_item_seq_id, p.amount
having sum(c.amount) <> p.amount or bool_or(c.budget_id <> p.budget_id);

-- ============================================================
-- Fig 8.7b — Budget revisions: revisions and their impacts
-- ============================================================

-- name: 8.7b — Table 8.10: each revision of a budget with the items it changed, by how much and why
select r.budget_id, b.comment as budget, '1.' || r.revision_seq_id as revision, r.date_revised,
       i.budget_id || ', item ' || i.budget_item_seq_id as item, y.description as item_type,
       x.revised_amount, x.add_delete_flag, x.revision_reason
from budget_revision_impact x
join budget_revision r   on r.budget_revision_id = x.budget_revision_id
join budget b            on b.budget_id = r.budget_id
join budget_item i       on i.budget_item_id = x.budget_item_id
join budget_item_type y  on y.budget_item_type_id = i.budget_item_type_id
order by r.budget_id, r.revision_seq_id, i.budget_item_seq_id;

-- name: 8.7b — The marketing budget after each of its revisions: every top item's amount and the total, from the original (0) on
with steps as (
  select 0 as seq union all select revision_seq_id from budget_revision where budget_id = 29839
),
item_at as (
  select s.seq, i.budget_item_seq_id, y.description as item,
         case
           when exists (select 1 from budget_revision_impact x join budget_revision r on r.budget_revision_id = x.budget_revision_id
                        where x.budget_item_id = i.budget_item_id and r.budget_id = i.budget_id and x.add_delete_flag = 'ADD' and r.revision_seq_id > s.seq) then null
           when exists (select 1 from budget_revision_impact x join budget_revision r on r.budget_revision_id = x.budget_revision_id
                        where x.budget_item_id = i.budget_item_id and r.budget_id = i.budget_id and x.add_delete_flag = 'DELETE' and r.revision_seq_id <= s.seq) then 0
           else i.amount + coalesce((select sum(x.revised_amount) from budget_revision_impact x
                                     join budget_revision r on r.budget_revision_id = x.budget_revision_id
                                     where x.budget_item_id = i.budget_item_id and r.budget_id = i.budget_id and x.add_delete_flag is null
                                       and r.revision_seq_id <= s.seq), 0)
         end as amount
  from steps s
  cross join budget_item i
  join budget_item_type y on y.budget_item_type_id = i.budget_item_type_id
  where i.budget_id = 29839 and i.part_of_budget_item_id is null
)
select case seq when 0 then 'original' else '1.' || seq end as version,
       string_agg(item || ' ' || amount, ', ' order by budget_item_seq_id) filter (where amount is not null) as items,
       sum(amount) as total
from item_at
group by seq
order by seq;

-- name: 8.7b — Data-quality check: revisions that change an item of another budget (should be empty)
select r.budget_id as revised_budget, '1.' || r.revision_seq_id as revision, i.budget_id as item_budget, i.budget_item_seq_id as item
from budget_revision_impact x
join budget_revision r on r.budget_revision_id = x.budget_revision_id
join budget_item i     on i.budget_item_id = x.budget_item_id
where i.budget_id <> r.budget_id;

-- name: 8.7b — Data-quality check: items revised below zero, or added with an amount other than the item's own (should be empty)
select i.budget_id, i.budget_item_seq_id as item, i.amount,
       coalesce(sum(x.revised_amount) filter (where x.add_delete_flag is null), 0) as changes,
       i.amount + coalesce(sum(x.revised_amount) filter (where x.add_delete_flag is null), 0) as after_all_revisions,
       bool_or(x.add_delete_flag = 'ADD' and x.revised_amount is distinct from i.amount) as added_amount_differs
from budget_item i
join budget_revision_impact x on x.budget_item_id = i.budget_item_id
group by i.budget_item_id, i.budget_id, i.budget_item_seq_id, i.amount
having i.amount + coalesce(sum(x.revised_amount) filter (where x.add_delete_flag is null), 0) < 0
    or bool_or(x.add_delete_flag = 'ADD' and x.revised_amount is distinct from i.amount);

-- ============================================================
-- Fig 8.8 — Budget review
-- ============================================================

-- name: 8.8 — Table 8.11: who reviewed each budget, when, with what result and why
select r.budget_id, b.comment as budget, d.name as reviewer, r.review_date,
       t.description as result, r.comment
from budget_review r
join budget b                    on b.budget_id = r.budget_id
join party_display_name d        on d.party_id = r.party_id
join budget_review_result_type t on t.budget_review_result_type_id = r.budget_review_result_type_id
order by r.budget_id, r.review_date;

-- name: 8.8 — The marketing budget's story: statuses (8.6), revisions (8.7b) and reviews (8.8) on one timeline
select s.status_date as day, 'status' as kind, t.description as what, s.comment
from budget_status s join status_type t on t.status_type_id = s.status_type_id
where s.budget_id = 29839
union all
select r.date_revised, 'revision', '1.' || r.revision_seq_id, null
from budget_revision r
where r.budget_id = 29839
union all
select v.review_date, 'review', d.name || ': ' || t.description, v.comment
from budget_review v
join party_display_name d        on d.party_id = v.party_id
join budget_review_result_type t on t.budget_review_result_type_id = v.budget_review_result_type_id
where v.budget_id = 29839
order by day, kind;

-- name: 8.8 — Data-quality check: reviews dated before the budget was first submitted (should be empty)
select r.budget_review_id, r.budget_id, r.review_date,
       (select min(s.status_date) from budget_status s
        where s.budget_id = r.budget_id and s.status_type_id = 'BUDGET_SUBMITTED') as first_submitted
from budget_review r
where r.review_date < coalesce((select min(s.status_date) from budget_status s
                                where s.budget_id = r.budget_id and s.status_type_id = 'BUDGET_SUBMITTED'), 'infinity'::date);
