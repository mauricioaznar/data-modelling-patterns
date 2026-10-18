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

-- ============================================================
-- Fig 4.3 — Sales order parties and contact mechanisms
-- ============================================================

-- name: 4.3 — Who placed, took and pays for each sales order, and through which contact mechanisms (no bill-to: the placer pays)
select o.order_id, o.order_date,
       pl.name as placed_by, tk.name as taken_by, coalesce(bt.name, pl.name) as pays,
       case when so.bill_to_party_role_id is null then 'no bill-to: the placer' else 'requested bill-to' end as payer_from,
       pu.display_name as placed_using, tv.display_name as taken_via, ba.display_name as bill_to_address
from sales_order so
join "order" o                                   on o.order_id = so.order_id
left join party_role r1                          on r1.party_role_id = so.placed_by_party_role_id
left join party_display_name pl                  on pl.party_id = r1.party_id
left join party_role r2                          on r2.party_role_id = so.taken_by_party_role_id
left join party_display_name tk                  on tk.party_id = r2.party_id
left join party_role r3                          on r3.party_role_id = so.bill_to_party_role_id
left join party_display_name bt                  on bt.party_id = r3.party_id
left join contact_mechanism_display_name pu      on pu.contact_mechanism_id = so.placed_using_contact_mechanism_id
left join contact_mechanism_display_name tv      on tv.contact_mechanism_id = so.taken_via_contact_mechanism_id
left join contact_mechanism_display_name ba      on ba.contact_mechanism_id = so.bill_to_contact_mechanism_id
order by o.order_id;

-- name: 4.3 — Where each item of orders 12561 and 12562 ships (a feature item ships with its product's item)
select oi.order_id, oi.order_item_seq_id as line,
       coalesce(p.name, f.description, oi.item_description) as item,
       n.name as ship_to, a.display_name as ship_to_address,
       case when s.ship_to_contact_mechanism_id is not null  then 'its own'
            when ps.ship_to_contact_mechanism_id is not null then 'its product item''s'
            else 'none given' end as from_where
from order_item oi
join sales_order_item s                      on s.order_item_id = oi.order_item_id
left join sales_order_item ps                on ps.order_item_id = oi.ordered_for_order_item_id
left join party_role r                       on r.party_role_id = coalesce(s.ship_to_party_role_id, ps.ship_to_party_role_id)
left join party_display_name n               on n.party_id = r.party_id
left join contact_mechanism_display_name a   on a.contact_mechanism_id = coalesce(s.ship_to_contact_mechanism_id, ps.ship_to_contact_mechanism_id)
left join product p                          on p.product_id = oi.product_id
left join product_feature f                  on f.product_feature_id = oi.product_feature_id
where oi.order_id in (12561, 12562)
order by oi.order_id, oi.order_item_seq_id;

-- name: 4.3 — Each salesperson's credited share of the orders they sold
with order_value as (
  select order_id, sum(quantity * unit_price) as order_value
  from order_item
  group by order_id
)
select r.order_id, n.name as salesperson, r.percent_contribution, v.order_value,
       round(v.order_value * r.percent_contribution / 100, 2) as credited
from order_role r
join order_value v            on v.order_id = r.order_id
join party_display_name n     on n.party_id = r.party_id
where r.order_role_type_id = 'SALESPERSON'
order by r.order_id, r.percent_contribution desc;

-- name: 4.3 — Every party on order 12561, from the specific lines and from ORDER ROLE (the cost of having both)
with specific as (
  select v.how, r.party_id
  from sales_order so
  cross join lateral (values ('placed by',         so.placed_by_party_role_id),
                             ('taken by',          so.taken_by_party_role_id),
                             ('requested bill-to', so.bill_to_party_role_id)) as v(how, party_role_id)
  join party_role r on r.party_role_id = v.party_role_id
  where so.order_id = 12561
  union
  select 'ship-to', r.party_id
  from order_item oi
  join sales_order_item s on s.order_item_id = oi.order_item_id
  join party_role r       on r.party_role_id = s.ship_to_party_role_id
  where oi.order_id = 12561
),
generic as (
  select 'order role ' || order_role_type_id as how, party_id
  from order_role
  where order_id = 12561
)
select n.name as party, string_agg(a.how, ', ' order by a.how) as on_the_order_as
from (select * from specific union all select * from generic) a
join party_display_name n on n.party_id = a.party_id
group by n.name
order by n.name;

-- name: 4.3 — For review: items shipping to an address the ship-to party didn't have on file that day
select oi.order_id, oi.order_item_seq_id as line, n.name as ship_to, a.display_name as address
from order_item oi
join "order" o                              on o.order_id = oi.order_id
join sales_order_item s                     on s.order_item_id = oi.order_item_id
join party_role r                           on r.party_role_id = s.ship_to_party_role_id
join party_display_name n                   on n.party_id = r.party_id
join contact_mechanism_display_name a       on a.contact_mechanism_id = s.ship_to_contact_mechanism_id
where not exists (
  select 1
  from party_contact_mechanism pcm
  where pcm.party_id = r.party_id
    and pcm.contact_mechanism_id = s.ship_to_contact_mechanism_id
    and pcm.from_date <= o.order_date
    and (pcm.thru_date is null or pcm.thru_date > o.order_date)
)
order by oi.order_id, oi.order_item_seq_id;

-- name: 4.3 — Data-quality check: order_kind and the sales_order subtype table disagree (should be empty)
select o.order_id, o.order_kind, (so.order_id is not null) as has_sales_order_row
from "order" o
left join sales_order so on so.order_id = o.order_id
where (o.order_kind = 'SALES') <> (so.order_id is not null);

-- name: 4.3 — Data-quality check: party lines pointing at a role of the wrong type (should be empty)
-- A role type below the expected one counts (Ch 2's role_type_ancestor).
with line as (
  select so.order_id, v.line, v.party_role_id, v.expected
  from sales_order so
  cross join lateral (values ('placed by',         so.placed_by_party_role_id, 'PLACING_CUSTOMER'),
                             ('taken by',          so.taken_by_party_role_id,  'INTERNAL_ORGANIZATION'),
                             ('requested bill-to', so.bill_to_party_role_id,   'BILL_TO_CUSTOMER')) as v(line, party_role_id, expected)
  union all
  select oi.order_id, 'ship-to, line ' || oi.order_item_seq_id, s.ship_to_party_role_id, 'SHIP_TO_CUSTOMER'
  from sales_order_item s
  join order_item oi on oi.order_item_id = s.order_item_id
)
select l.order_id, l.line, l.party_role_id, r.role_type_id as actual, l.expected
from line l
join party_role r on r.party_role_id = l.party_role_id
where not exists (
  select 1 from role_type_ancestor a
  where a.role_type_id = r.role_type_id and a.ancestor_id = l.expected
)
order by l.order_id;

-- name: 4.3 — Data-quality check: party lines whose role wasn't current on the order date (should be empty)
with line as (
  select so.order_id, v.line, v.party_role_id
  from sales_order so
  cross join lateral (values ('placed by',         so.placed_by_party_role_id),
                             ('taken by',          so.taken_by_party_role_id),
                             ('requested bill-to', so.bill_to_party_role_id)) as v(line, party_role_id)
  union all
  select oi.order_id, 'ship-to, line ' || oi.order_item_seq_id, s.ship_to_party_role_id
  from sales_order_item s
  join order_item oi on oi.order_item_id = s.order_item_id
)
select l.order_id, o.order_date, l.line, r.party_role_id, r.role_type_id, r.from_date, r.thru_date
from line l
join "order" o      on o.order_id = l.order_id
join party_role r   on r.party_role_id = l.party_role_id
where not (r.from_date <= o.order_date and (r.thru_date is null or r.thru_date > o.order_date))
order by l.order_id;

-- name: 4.3 — Data-quality check: one party twice in the same role on an order (should be empty)
select order_id, party_id, order_role_type_id, count(*) as rows
from order_role
group by order_id, party_id, order_role_type_id
having count(*) > 1;

-- name: 4.3 — Data-quality check: one order's shares of a role type adding up to more than 100% (should be empty)
select order_id, order_role_type_id, sum(percent_contribution) as total_percent
from order_role
group by order_id, order_role_type_id
having sum(percent_contribution) > 100;
