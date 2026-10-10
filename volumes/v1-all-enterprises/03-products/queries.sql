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

-- ============================================================
-- Fig 3.2 — Product category
-- ============================================================

-- name: 3.2 — Category tree: each category with its parents (Business forms has two)
select c.product_category_id, c.product_category_type_id as dimension, c.description,
       string_agg(p.description, ', ' order by p.description) as parents
from product_category c
left join product_category_rollup r on r.child_product_category_id = c.product_category_id
left join product_category p        on p.product_category_id = r.parent_product_category_id
group by c.product_category_id
order by c.product_category_type_id, c.product_category_id;

-- name: 3.2 — Every product in "Office supplies" or any category below it, today
select distinct pr.product_id, pr.name, c.description as via_category
from product_category_classification pcc
join product pr          on pr.product_id = pcc.product_id
join product_category c  on c.product_category_id = pcc.product_category_id
where pcc.from_date <= current_date
  and (pcc.thru_date is null or pcc.thru_date > current_date)
  and (pcc.product_category_id = 1
       or pcc.product_category_id in (select product_category_id from product_category_ancestor where ancestor_id = 1))
order by pr.product_id;

-- name: 3.2 — Each product's current primary category
select pr.product_id, pr.name, c.description as primary_category
from product pr
left join product_category_classification pcc
       on pcc.product_id = pr.product_id
      and pcc.primary_flag
      and pcc.from_date <= current_date
      and (pcc.thru_date is null or pcc.thru_date > current_date)
left join product_category c on c.product_category_id = pcc.product_category_id
order by pr.product_id, primary_category;

-- name: 3.2 — Where were the diskettes categorised in 1995, and where now?
select d.as_of, c.description as category, pcc.primary_flag
from (values (date '1995-01-01'), (current_date)) as d(as_of)
join product_category_classification pcc
  on pcc.product_id = 3
 and pcc.from_date <= d.as_of
 and (pcc.thru_date is null or pcc.thru_date > d.as_of)
join product_category c on c.product_category_id = pcc.product_category_id
order by d.as_of, pcc.primary_flag desc, category;

-- name: 3.2 — Whom to pitch: products on sale in categories our parties' current types are interested in
select dn.name as party, pc.party_type_id, cat.description as interest, pr.name as product
from party_classification pc
join party_display_name dn on dn.party_id = pc.party_id
join market_interest mi    on mi.party_type_id = pc.party_type_id
                          and mi.from_date <= current_date
                          and (mi.thru_date is null or mi.thru_date > current_date)
join product_category cat  on cat.product_category_id = mi.product_category_id
join product_category_classification pcc
  on (pcc.product_category_id = mi.product_category_id
      or pcc.product_category_id in (select product_category_id from product_category_ancestor
                                     where ancestor_id = mi.product_category_id))
 and pcc.from_date <= current_date
 and (pcc.thru_date is null or pcc.thru_date > current_date)
join product pr on pr.product_id = pcc.product_id
               and (pr.introduction_date is null or pr.introduction_date <= current_date)
               and (pr.sales_discontinuation_date is null or pr.sales_discontinuation_date > current_date)
where pc.from_date <= current_date
  and (pc.thru_date is null or pc.thru_date > current_date)
group by dn.name, pc.party_type_id, cat.description, pr.name
order by party, interest, product;

-- name: 3.2 — Data-quality check: products with more than one current primary category (should be empty)
select pr.product_id, pr.name, string_agg(c.description, ', ') as primary_categories
from product_category_classification pcc
join product pr         on pr.product_id = pcc.product_id
join product_category c on c.product_category_id = pcc.product_category_id
where pcc.primary_flag
  and pcc.from_date <= current_date
  and (pcc.thru_date is null or pcc.thru_date > current_date)
group by pr.product_id, pr.name
having count(*) > 1;

-- name: 3.2 — Data-quality check: products with no current primary category (should be empty)
select pr.product_id, pr.name
from product pr
where not exists (
  select 1 from product_category_classification pcc
  where pcc.product_id = pr.product_id
    and pcc.primary_flag
    and pcc.from_date <= current_date
    and (pcc.thru_date is null or pcc.thru_date > current_date));

-- name: 3.2 — Data-quality check: categories that are their own ancestor, i.e. rollup cycles (should be empty)
select c.product_category_id, c.description
from product_category_ancestor a
join product_category c on c.product_category_id = a.product_category_id
where a.ancestor_id = a.product_category_id;
