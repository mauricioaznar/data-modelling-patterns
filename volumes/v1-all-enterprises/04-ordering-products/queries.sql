-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/04

-- ============================================================
-- Fig 4.2 — Orders and order items
-- ============================================================

-- name: 4.2 — Order 12560 as Table 4.2 shows it, with line totals
select oi.order_id, oi.order_item_seq_id as item, p.name as product, oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price as line_total
from order_item oi
join product p on p.product_id = oi.product_id
where oi.order_id = 12560
order by oi.order_item_seq_id;

-- name: 4.2 — Each order's value, sales and purchase alike
select o.order_id, o.order_kind, o.order_date, count(oi.order_item_id) as items,
       sum(oi.quantity * oi.unit_price) as order_value
from "order" o
left join order_item oi on oi.order_id = o.order_id
group by o.order_id
order by o.order_id;

-- name: 4.2 — Every order for the pen, both directions, from one table (Fig 4.1 needs a union)
select o.order_kind, o.order_id, o.order_date, oi.quantity, oi.unit_price
from order_item oi
join "order" o on o.order_id = oi.order_id
where oi.product_id = 2
order by o.order_date;

-- name: 4.2 — Order 12561 as a tree: each feature under the item it's ordered for
with recursive tree (order_item_id, depth, path) as (
  select order_item_id, 0, array[order_item_seq_id]
  from order_item
  where order_id = 12561 and ordered_for_order_item_id is null
  union all
  select c.order_item_id, t.depth + 1, t.path || c.order_item_seq_id
  from order_item c
  join tree t on c.ordered_for_order_item_id = t.order_item_id
  where t.depth < 10   -- guard against a loop of items ordered for each other
)
select repeat('    ', t.depth) || coalesce(p.name, f.description, oi.item_description) as item,
       oi.order_item_seq_id as line, oi.quantity, oi.unit_price
from tree t
join order_item oi           on oi.order_item_id = t.order_item_id
left join product p          on p.product_id = oi.product_id
left join product_feature f  on f.product_feature_id = oi.product_feature_id
order by t.path;

-- name: 4.2 — Agreed vs list: each sales line's unit price against the plain list price on the order date
-- The plain list price is the product's base price with no feature and no other
-- condition. The order keeps what was agreed, whatever the list said.
select o.order_id, o.order_date, p.name as product, oi.unit_price as agreed, lp.price as list_that_day,
       case when lp.price is null       then 'no plain list price that day'
            when oi.unit_price = lp.price then 'at list'
            else 'differs from list' end as note,
       lp.rules
from order_item oi
join "order" o on o.order_id = oi.order_id and o.order_kind = 'SALES'
join product p on p.product_id = oi.product_id
left join lateral (
  select min(pc.price) as price, count(*) as rules   -- rules > 1: overlapping list prices (a Ch 3 data error)
  from price_component pc
  where pc.product_id = oi.product_id
    and pc.price_component_type_id = 'BASE_PRICE'
    and pc.product_feature_id is null
    and pc.geographic_boundary_id is null and pc.party_type_id is null and pc.product_category_id is null
    and pc.quantity_break_id is null and pc.order_value_id is null and pc.sale_type_id is null
    and pc.from_date <= o.order_date and (pc.thru_date is null or pc.thru_date > o.order_date)
  having count(*) > 0
) lp on true
where oi.product_feature_id is null
order by o.order_id, oi.order_item_seq_id;

-- name: 4.2 — Data-quality check: items naming both a product and a feature, or nothing at all (should be empty)
select order_item_id, order_id, order_item_seq_id, product_id, product_feature_id, item_description
from order_item
where (product_id is not null and product_feature_id is not null)
   or (product_id is null and product_feature_id is null and item_description is null);

-- name: 4.2 — Data-quality check: items ordered for an item on another order (should be empty)
select c.order_item_id, c.order_id, c.ordered_for_order_item_id, p.order_id as ordered_for_order_id
from order_item c
join order_item p on p.order_item_id = c.ordered_for_order_item_id
where p.order_id <> c.order_id;

-- name: 4.2 — Data-quality check: feature items with no product item above them, or whose feature doesn't apply to that product on the order date (should be empty)
select c.order_item_id, c.order_id, o.order_date, f.description as feature, pp.name as parent_product
from order_item c
join "order" o          on o.order_id = c.order_id
join product_feature f  on f.product_feature_id = c.product_feature_id
left join order_item p  on p.order_item_id = c.ordered_for_order_item_id
left join product pp    on pp.product_id = p.product_id
where not exists (
  select 1
  from product_feature_applicability a
  where a.product_id = p.product_id
    and a.product_feature_id = c.product_feature_id
    and a.from_date <= o.order_date
    and (a.thru_date is null or a.thru_date > o.order_date)
);

-- name: 4.2 — Data-quality check: sales order items for products not on sale on the order date (should be empty)
select oi.order_item_id, oi.order_id, o.order_date, p.name, p.introduction_date, p.sales_discontinuation_date
from order_item oi
join "order" o  on o.order_id = oi.order_id and o.order_kind = 'SALES'
join product p  on p.product_id = oi.product_id
where p.introduction_date > o.order_date
   or p.sales_discontinuation_date <= o.order_date;

-- name: 4.2 — Data-quality check: two items with the same line number on one order (should be empty)
select order_id, order_item_seq_id, count(*) as items
from order_item
group by order_id, order_item_seq_id
having count(*) > 1;

-- name: 4.2 — Data-quality check: sales items without their sales_order_item row, or such rows on other orders (should be empty)
select oi.order_item_id, oi.order_id, o.order_kind,
       case when s.order_item_id is null then 'sales item without a sales_order_item row'
            else 'sales_order_item row on a ' || lower(o.order_kind) || ' order' end as problem
from order_item oi
join "order" o                 on o.order_id = oi.order_id
left join sales_order_item s   on s.order_item_id = oi.order_item_id
where (o.order_kind = 'SALES') <> (s.order_item_id is not null);
