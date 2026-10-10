-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/03

-- ============================================================
-- Fig 3.1 — Product definition
-- ============================================================

-- name: 3.1 — Product catalogue with its sales/support status today
select product_id, product_kind, name,
       case
         when introduction_date > current_date                  then 'not yet introduced'
         when sales_discontinuation_date <= current_date
          and (support_discontinuation_date is null
               or support_discontinuation_date > current_date)  then 'support only'
         when sales_discontinuation_date <= current_date        then 'retired'
         else 'on sale'
       end as status
from product
order by product_id;

-- name: 3.1 — What could we sell on 2005-06-01?
select product_id, name
from product
where (introduction_date is null or introduction_date <= date '2005-06-01')
  and (sales_discontinuation_date is null or sales_discontinuation_date > date '2005-06-01')
order by product_id;

-- name: 3.1 — Goods vs services
select product_kind, count(*) as products
from product
group by product_kind
order by product_kind;

-- name: 3.1 — Data-quality check: milestone dates out of order (should be empty)
select product_id, name, introduction_date, sales_discontinuation_date, support_discontinuation_date
from product
where sales_discontinuation_date < introduction_date
   or support_discontinuation_date < introduction_date
   or support_discontinuation_date < sales_discontinuation_date;
