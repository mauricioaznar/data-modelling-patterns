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

-- ============================================================
-- Fig 4.4 — Purchase order parties and contact mechanisms
-- ============================================================

-- name: 4.4 — Who placed, took and pays for each purchase order, and through which contact mechanisms (no bill-to: the placer pays)
select o.order_id, o.order_date,
       pl.name as placed_by, tk.name as taken_by, coalesce(bt.name, pl.name) as pays,
       case when po.bill_to_party_role_id is null then 'no bill-to: the placer' else 'requested bill-to' end as payer_from,
       pu.display_name as placed_using, tv.display_name as taken_via, ba.display_name as bill_to_address
from purchase_order po
join "order" o                                   on o.order_id = po.order_id
left join party_role r1                          on r1.party_role_id = po.placed_by_party_role_id
left join party_display_name pl                  on pl.party_id = r1.party_id
left join party_role r2                          on r2.party_role_id = po.taken_by_party_role_id
left join party_display_name tk                  on tk.party_id = r2.party_id
left join party_role r3                          on r3.party_role_id = po.bill_to_party_role_id
left join party_display_name bt                  on bt.party_id = r3.party_id
left join contact_mechanism_display_name pu      on pu.contact_mechanism_id = po.placed_using_contact_mechanism_id
left join contact_mechanism_display_name tv      on tv.contact_mechanism_id = po.taken_via_contact_mechanism_id
left join contact_mechanism_display_name ba      on ba.contact_mechanism_id = po.bill_to_contact_mechanism_id
where o.order_kind = 'PURCHASE'
order by o.order_id;

-- name: 4.4 — Where each purchase order item ships, and whether the address is the buyer's own (a drop ship isn't)
select oi.order_id, oi.order_item_seq_id as line,
       coalesce(p.name, oi.item_description) as item,
       n.name as ship_to, a.display_name as ship_to_address,
       case when s.ship_to_contact_mechanism_id is null then 'no ship-to (a service)'
            when exists (select 1
                         from party_contact_mechanism pcm
                         where pcm.party_id = r.party_id
                           and pcm.contact_mechanism_id = s.ship_to_contact_mechanism_id
                           and pcm.from_date <= o.order_date
                           and (pcm.thru_date is null or pcm.thru_date > o.order_date))
                 then 'the buyer''s own'
            else 'someone else''s: a drop ship?' end as address_is
from order_item oi
join "order" o                               on o.order_id = oi.order_id
join purchase_order_item s                   on s.order_item_id = oi.order_item_id
left join party_role r                       on r.party_role_id = s.ship_to_party_role_id
left join party_display_name n               on n.party_id = r.party_id
left join contact_mechanism_display_name a   on a.contact_mechanism_id = s.ship_to_contact_mechanism_id
left join product p                          on p.product_id = oi.product_id
where o.order_kind = 'PURCHASE'
order by oi.order_id, oi.order_item_seq_id;

-- name: 4.4 — Contoso's orders in both directions: one party, a role per hat (a union over the twin tables)
with line as (
  select so.order_id, v.line, v.party_role_id
  from sales_order so
  cross join lateral (values ('placed by',         so.placed_by_party_role_id),
                             ('taken by',          so.taken_by_party_role_id),
                             ('requested bill-to', so.bill_to_party_role_id)) as v(line, party_role_id)
  union all
  select po.order_id, v.line, v.party_role_id
  from purchase_order po
  cross join lateral (values ('placed by',         po.placed_by_party_role_id),
                             ('taken by',          po.taken_by_party_role_id),
                             ('requested bill-to', po.bill_to_party_role_id)) as v(line, party_role_id)
  union all
  select oi.order_id, 'ship-to', s.ship_to_party_role_id
  from sales_order_item s
  join order_item oi on oi.order_item_id = s.order_item_id
  union all
  select oi.order_id, 'ship-to', s.ship_to_party_role_id
  from purchase_order_item s
  join order_item oi on oi.order_item_id = s.order_item_id
)
select o.order_id, o.order_kind, o.order_date,
       string_agg(distinct l.line || ' as ' || r.role_type_id, ', ') as contoso_is
from line l
join party_role r   on r.party_role_id = l.party_role_id
join "order" o      on o.order_id = l.order_id
where r.party_id = 5
group by o.order_id, o.order_kind, o.order_date
order by o.order_id;

-- name: 4.4 — Data-quality check: order_kind and the purchase_order subtype table disagree (should be empty)
select o.order_id, o.order_kind, (po.order_id is not null) as has_purchase_order_row
from "order" o
left join purchase_order po on po.order_id = o.order_id
where (o.order_kind = 'PURCHASE') <> (po.order_id is not null);

-- name: 4.4 — Data-quality check: purchase items without their purchase_order_item row, or such rows on other orders (should be empty)
select oi.order_item_id, oi.order_id, o.order_kind,
       case when s.order_item_id is null then 'purchase item without a purchase_order_item row'
            else 'purchase_order_item row on a ' || lower(o.order_kind) || ' order' end as problem
from order_item oi
join "order" o                    on o.order_id = oi.order_id
left join purchase_order_item s   on s.order_item_id = oi.order_item_id
where (o.order_kind = 'PURCHASE') <> (s.order_item_id is not null);

-- name: 4.4 — Data-quality check: purchase party lines pointing at a role of the wrong type (should be empty)
-- 4.3's check, copied onto the other table: a role type below the expected one counts.
with line as (
  select po.order_id, v.line, v.party_role_id, v.expected
  from purchase_order po
  cross join lateral (values ('placed by',         po.placed_by_party_role_id, 'PLACING_BUYER'),
                             ('taken by',          po.taken_by_party_role_id,  'SUPPLIER'),
                             ('requested bill-to', po.bill_to_party_role_id,   'BILL_TO_PURCHASER')) as v(line, party_role_id, expected)
  union all
  select oi.order_id, 'ship-to, line ' || oi.order_item_seq_id, s.ship_to_party_role_id, 'SHIP_TO_BUYER'
  from purchase_order_item s
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

-- name: 4.4 — Data-quality check: purchase party lines whose role wasn't current on the order date (should be empty)
with line as (
  select po.order_id, v.line, v.party_role_id
  from purchase_order po
  cross join lateral (values ('placed by',         po.placed_by_party_role_id),
                             ('taken by',          po.taken_by_party_role_id),
                             ('requested bill-to', po.bill_to_party_role_id)) as v(line, party_role_id)
  union all
  select oi.order_id, 'ship-to, line ' || oi.order_item_seq_id, s.ship_to_party_role_id
  from purchase_order_item s
  join order_item oi on oi.order_item_id = s.order_item_id
)
select l.order_id, o.order_date, l.line, r.party_role_id, r.role_type_id, r.from_date, r.thru_date
from line l
join "order" o      on o.order_id = l.order_id
join party_role r   on r.party_role_id = l.party_role_id
where not (r.from_date <= o.order_date and (r.thru_date is null or r.thru_date > o.order_date))
order by l.order_id;

-- ============================================================
-- Fig 4.5 — Generic order roles and contact mechanisms
-- ============================================================

-- name: 4.5 — Order 12571 from the generic tables: every party and contact mechanism, on the order and on its items
select level, line, what, who_or_where
from (
  select 'order' as level, null::integer as line, 'role: ' || r.order_role_type_id as what, n.name as who_or_where
  from order_role r
  join party_display_name n on n.party_id = r.party_id
  where r.order_id = 12571
  union all
  select 'order', null, 'mechanism: ' || m.contact_mechanism_purpose_type_id, d.display_name
  from order_contact_mechanism m
  join contact_mechanism_display_name d on d.contact_mechanism_id = m.contact_mechanism_id
  where m.order_id = 12571
  union all
  select 'item', oi.order_item_seq_id, 'role: ' || r.order_item_role_type_id, n.name
  from order_item_role r
  join order_item oi            on oi.order_item_id = r.order_item_id
  join party_display_name n     on n.party_id = r.party_id
  where oi.order_id = 12571
  union all
  select 'item', oi.order_item_seq_id, 'mechanism: ' || m.contact_mechanism_purpose_type_id, d.display_name
  from order_item_contact_mechanism m
  join order_item oi                     on oi.order_item_id = m.order_item_id
  join contact_mechanism_display_name d  on d.contact_mechanism_id = m.contact_mechanism_id
  where oi.order_id = 12571
) x
order by level desc, line nulls first, what, who_or_where;

-- name: 4.5 — Who pays for each order, whichever model holds it (the bill-to column, else a BILL_TO order role, else the placer)
-- With both models loaded, every report reads both. On 12561 the column wins and
-- the conflicting order role is silently ignored: the data-quality check below catches it.
with specific as (
  select order_id, placed_by_party_role_id, bill_to_party_role_id from sales_order
  union all
  select order_id, placed_by_party_role_id, bill_to_party_role_id from purchase_order
),
generic as (
  select r.order_id,
         string_agg(n.name, ' + ' order by n.name) filter (where r.order_role_type_id = 'BILL_TO')   as bill_to,
         string_agg(n.name, ' + ' order by n.name) filter (where r.order_role_type_id = 'PLACED_BY') as placed_by
  from order_role r
  join party_display_name n on n.party_id = r.party_id
  group by r.order_id
)
select o.order_id, o.order_kind,
       coalesce(bt.name, g.bill_to, pl.name, g.placed_by) as pays,
       case when bt.name is not null      then 'bill-to column (4.3, 4.4)'
            when g.bill_to is not null    then 'BILL_TO order role (4.5)'
            when pl.name is not null      then 'no bill-to: the placer (column)'
            when g.placed_by is not null  then 'no bill-to: the placer (order role)'
            else 'nobody named' end as from_where
from "order" o
left join specific s               on s.order_id = o.order_id
left join party_role r1            on r1.party_role_id = s.bill_to_party_role_id
left join party_display_name bt    on bt.party_id = r1.party_id
left join party_role r2            on r2.party_role_id = s.placed_by_party_role_id
left join party_display_name pl    on pl.party_id = r2.party_id
left join generic g                on g.order_id = o.order_id
order by o.order_id;

-- name: 4.5 — Item parties no column of 4.3 could hold: end users and installers
select oi.order_id, oi.order_item_seq_id as line, coalesce(p.name, oi.item_description) as item,
       r.order_item_role_type_id as role, n.name as party
from order_item_role r
join order_item oi             on oi.order_item_id = r.order_item_id
join party_display_name n      on n.party_id = r.party_id
left join product p            on p.product_id = oi.product_id
where r.order_item_role_type_id <> 'SHIP_TO'
order by oi.order_id, oi.order_item_seq_id;

-- name: 4.5 — Data-quality check: the same row twice in a generic table (should be empty)
-- Each table's identifier is its three parents (a bar on every line). ORDER
-- ROLE's is 4.3's check.
select 'order_item_role' as in_table, order_item_id as of_id, party_id::text as who_or_where, order_item_role_type_id as type, count(*) as rows
from order_item_role group by order_item_id, party_id, order_item_role_type_id having count(*) > 1
union all
select 'order_contact_mechanism', order_id, contact_mechanism_id::text, contact_mechanism_purpose_type_id, count(*)
from order_contact_mechanism group by order_id, contact_mechanism_id, contact_mechanism_purpose_type_id having count(*) > 1
union all
select 'order_item_contact_mechanism', order_item_id, contact_mechanism_id::text, contact_mechanism_purpose_type_id, count(*)
from order_item_contact_mechanism group by order_item_id, contact_mechanism_id, contact_mechanism_purpose_type_id having count(*) > 1;

-- name: 4.5 — Data-quality check: more than one of a job the columns held once, per order or per item (should be empty)
-- Counts distinct parties and mechanisms: a row entered twice is the check above's.
select 'order ' || order_id as of_what, order_role_type_id as job, count(distinct party_id) as how_many
from order_role
where order_role_type_id in ('PLACED_BY', 'TAKEN_BY', 'BILL_TO')
group by order_id, order_role_type_id having count(distinct party_id) > 1
union all
select 'order ' || order_id, contact_mechanism_purpose_type_id, count(distinct contact_mechanism_id)
from order_contact_mechanism
where contact_mechanism_purpose_type_id in ('ORDER_PLACING', 'ORDER_TAKING', 'BILLING')
group by order_id, contact_mechanism_purpose_type_id having count(distinct contact_mechanism_id) > 1
union all
select 'item ' || order_item_id, order_item_role_type_id, count(distinct party_id)
from order_item_role
where order_item_role_type_id = 'SHIP_TO'
group by order_item_id, order_item_role_type_id having count(distinct party_id) > 1
union all
select 'item ' || order_item_id, contact_mechanism_purpose_type_id, count(distinct contact_mechanism_id)
from order_item_contact_mechanism
where contact_mechanism_purpose_type_id = 'SHIPPING'
group by order_item_id, contact_mechanism_purpose_type_id having count(distinct contact_mechanism_id) > 1;

-- name: 4.5 — Data-quality check: one job named in both models on the same order or item (should be empty)
with specific as (
  select so.order_id, null::integer as order_item_id, v.job
  from sales_order so
  cross join lateral (values ('placed by',    so.placed_by_party_role_id),
                             ('taken by',     so.taken_by_party_role_id),
                             ('bill-to',      so.bill_to_party_role_id),
                             ('placed using', so.placed_using_contact_mechanism_id),
                             ('taken via',    so.taken_via_contact_mechanism_id),
                             ('billed to',    so.bill_to_contact_mechanism_id)) as v(job, id)
  where v.id is not null
  union all
  select po.order_id, null, v.job
  from purchase_order po
  cross join lateral (values ('placed by',    po.placed_by_party_role_id),
                             ('taken by',     po.taken_by_party_role_id),
                             ('bill-to',      po.bill_to_party_role_id),
                             ('placed using', po.placed_using_contact_mechanism_id),
                             ('taken via',    po.taken_via_contact_mechanism_id),
                             ('billed to',    po.bill_to_contact_mechanism_id)) as v(job, id)
  where v.id is not null
  union all
  select oi.order_id, oi.order_item_id, v.job
  from order_item oi
  left join sales_order_item s      on s.order_item_id = oi.order_item_id
  left join purchase_order_item p   on p.order_item_id = oi.order_item_id
  cross join lateral (values ('ship-to',    coalesce(s.ship_to_party_role_id, p.ship_to_party_role_id)),
                             ('shipped to', coalesce(s.ship_to_contact_mechanism_id, p.ship_to_contact_mechanism_id))) as v(job, id)
  where v.id is not null
),
generic as (
  select order_id, null::integer as order_item_id,
         case order_role_type_id when 'PLACED_BY' then 'placed by' when 'TAKEN_BY' then 'taken by' when 'BILL_TO' then 'bill-to' end as job
  from order_role
  union all
  select order_id, null,
         case contact_mechanism_purpose_type_id when 'ORDER_PLACING' then 'placed using' when 'ORDER_TAKING' then 'taken via' when 'BILLING' then 'billed to' end
  from order_contact_mechanism
  union all
  select oi.order_id, r.order_item_id, case r.order_item_role_type_id when 'SHIP_TO' then 'ship-to' end
  from order_item_role r
  join order_item oi on oi.order_item_id = r.order_item_id
  union all
  select oi.order_id, m.order_item_id, case m.contact_mechanism_purpose_type_id when 'SHIPPING' then 'shipped to' end
  from order_item_contact_mechanism m
  join order_item oi on oi.order_item_id = m.order_item_id
)
select distinct s.order_id, s.order_item_id, s.job
from specific s
join generic g on g.order_id = s.order_id
              and g.order_item_id is not distinct from s.order_item_id
              and g.job = s.job
order by s.order_id, s.order_item_id, s.job;

-- ============================================================
-- Fig 4.6 — Order adjustments
-- ============================================================

-- name: 4.6 — Order 12561's bill: each line, each adjustment with its value (discounts negative), and the total
-- A percentage is of the value before any adjustment: the order's lines for an
-- order adjustment, the one line for an item adjustment (NOTES, point 11).
with recursive up (order_adjustment_type_id, top_type_id) as (   -- each type with its top-level type
  select order_adjustment_type_id, order_adjustment_type_id from order_adjustment_type where parent_type_id is null
  union all
  select t.order_adjustment_type_id, u.top_type_id
  from order_adjustment_type t
  join up u on t.parent_type_id = u.order_adjustment_type_id
),
line as (
  select oi.order_item_id, oi.order_item_seq_id,
         coalesce(p.name, f.description, oi.item_description) as item,
         oi.quantity * oi.unit_price as value
  from order_item oi
  left join product p           on p.product_id = oi.product_id
  left join product_feature f   on f.product_feature_id = oi.product_feature_id
  where oi.order_id = 12561
),
adjustment as (
  select a.order_adjustment_id, t.description, a.percentage, l.order_item_seq_id,
         case when u.top_type_id = 'DISCOUNT' then -1 else 1 end
         * coalesce(a.amount, round(coalesce(l.value, (select sum(value) from line)) * a.percentage / 100, 2)) as value
  from order_adjustment a
  join up u                       on u.order_adjustment_type_id = a.order_adjustment_type_id
  join order_adjustment_type t    on t.order_adjustment_type_id = a.order_adjustment_type_id
  left join line l                on l.order_item_id = a.order_item_id
  where a.order_id = 12561 or l.order_item_id is not null
)
select what, applies_to, value
from (
  select 1 as part, order_item_seq_id as seq, 'line ' || order_item_seq_id || ': ' || item as what, null as applies_to, value
  from line
  union all
  select 2, order_adjustment_id, description || coalesce(' ' || percentage || '%', ''),
         coalesce('line ' || order_item_seq_id, 'the order'), value
  from adjustment
  union all
  select 3, 0, 'Total', null, (select sum(value) from line) + (select coalesce(sum(value), 0) from adjustment)
) bill
order by part, seq;

-- name: 4.6 — Each order's value: its lines, its adjustments and the total, sales and purchase alike
with recursive up (order_adjustment_type_id, top_type_id) as (
  select order_adjustment_type_id, order_adjustment_type_id from order_adjustment_type where parent_type_id is null
  union all
  select t.order_adjustment_type_id, u.top_type_id
  from order_adjustment_type t
  join up u on t.parent_type_id = u.order_adjustment_type_id
),
lines as (
  select order_id, sum(quantity * unit_price) as lines_value
  from order_item
  group by order_id
),
adjustment as (
  select coalesce(oi.order_id, a.order_id) as order_id,
         case when u.top_type_id = 'DISCOUNT' then -1 else 1 end
         * coalesce(a.amount, round(coalesce(oi.quantity * oi.unit_price, l.lines_value) * a.percentage / 100, 2)) as value
  from order_adjustment a
  join up u                on u.order_adjustment_type_id = a.order_adjustment_type_id
  left join order_item oi  on oi.order_item_id = a.order_item_id
  left join lines l        on l.order_id = a.order_id
)
select o.order_id, o.order_kind, l.lines_value,
       coalesce(sum(a.value), 0) as adjustments,
       l.lines_value + coalesce(sum(a.value), 0) as total
from "order" o
join lines l             on l.order_id = o.order_id
left join adjustment a   on a.order_id = o.order_id
group by o.order_id, o.order_kind, l.lines_value
order by o.order_id;

-- name: 4.6 — Sales tax on order 12561: the rate the lookup gives each line (where it ships, what it is) against the rate charged
-- Every boundary the ship-to address lies in adds its rate; per boundary, a
-- rate for the product's category (or one above it) beats the general one.
with line as (
  select oi.order_item_id, oi.order_item_seq_id, oi.product_id, o.order_date,
         coalesce(p.name, f.description) as item,
         coalesce(s.ship_to_contact_mechanism_id, ps.ship_to_contact_mechanism_id) as ship_to   -- a feature ships with its item
  from order_item oi
  join "order" o                   on o.order_id = oi.order_id
  join sales_order_item s          on s.order_item_id = oi.order_item_id
  left join sales_order_item ps    on ps.order_item_id = oi.ordered_for_order_item_id
  left join product p              on p.product_id = oi.product_id
  left join product_feature f      on f.product_feature_id = oi.product_feature_id
  where oi.order_id = 12561
    and oi.quantity * oi.unit_price > 0
),
boundary as (
  select distinct l.order_item_id, a.ancestor_id as geographic_boundary_id
  from line l
  join postal_address_boundary pab        on pab.contact_mechanism_id = l.ship_to
  join geographic_boundary_ancestor a     on a.geographic_boundary_id = pab.geographic_boundary_id
),
category as (   -- the product's categories on the order date, and every category above them
  select l.order_item_id, c.product_category_id
  from line l
  join product_category_classification c on c.product_id = l.product_id
  where c.from_date <= l.order_date and (c.thru_date is null or c.thru_date > l.order_date)
  union
  select l.order_item_id, an.ancestor_id
  from line l
  join product_category_classification c   on c.product_id = l.product_id
  join product_category_ancestor an        on an.product_category_id = c.product_category_id
  where c.from_date <= l.order_date and (c.thru_date is null or c.thru_date > l.order_date)
),
rate as (
  select distinct on (b.order_item_id, b.geographic_boundary_id)
         b.order_item_id, b.geographic_boundary_id, t.sales_tax_percentage
  from boundary b
  join sales_tax_lookup t on t.geographic_boundary_id = b.geographic_boundary_id
  where t.product_category_id is null
     or t.product_category_id in (select c.product_category_id from category c where c.order_item_id = b.order_item_id)
  order by b.order_item_id, b.geographic_boundary_id, (t.product_category_id is null), t.sales_tax_lookup_id
)
select l.order_item_seq_id as line, l.item, d.display_name as ships_to,
       string_agg(g.name || ' ' || r.sales_tax_percentage, ' + ' order by g.name) as from_lookup,
       sum(r.sales_tax_percentage) as lookup_percent,
       (select sum(x.percentage) from order_adjustment x
        where x.order_item_id = l.order_item_id and x.order_adjustment_type_id = 'SALES_TAX') as charged_percent
from line l
left join rate r                             on r.order_item_id = l.order_item_id
left join geographic_boundary g              on g.geographic_boundary_id = r.geographic_boundary_id
left join contact_mechanism_display_name d   on d.contact_mechanism_id = l.ship_to
group by l.order_item_id, l.order_item_seq_id, l.item, d.display_name
order by l.order_item_seq_id;

-- name: 4.6 — Data-quality check: adjustments for both an order and an item, or for neither (should be empty)
select order_adjustment_id, order_adjustment_type_id, order_id, order_item_id
from order_adjustment
where (order_id is null) = (order_item_id is null);

-- name: 4.6 — Data-quality check: adjustments with both an amount and a percentage, or neither (should be empty)
select order_adjustment_id, order_adjustment_type_id, amount, percentage
from order_adjustment
where (amount is null) = (percentage is null);

-- name: 4.6 — Data-quality check: adjustment types that don't roll up to one of the book's six subtypes (should be empty)
with recursive up (order_adjustment_type_id, top_type_id) as (
  select order_adjustment_type_id, order_adjustment_type_id from order_adjustment_type where parent_type_id is null
  union all
  select t.order_adjustment_type_id, u.top_type_id
  from order_adjustment_type t
  join up u on t.parent_type_id = u.order_adjustment_type_id
)
select order_adjustment_type_id, top_type_id
from up
where top_type_id not in ('DISCOUNT', 'SURCHARGE', 'SALES_TAX', 'SHIPPING_AND_HANDLING', 'FEE', 'MISCELLANEOUS_CHARGE');

-- name: 4.6 — Data-quality check: two sales tax rates for one boundary and category (should be empty)
select t.geographic_boundary_id, g.name, t.product_category_id, count(*) as rates
from sales_tax_lookup t
join geographic_boundary g on g.geographic_boundary_id = t.geographic_boundary_id
group by t.geographic_boundary_id, g.name, t.product_category_id
having count(*) > 1;

-- ============================================================
-- Fig 4.7 — Order status and terms
-- ============================================================

-- name: 4.7 — Where each order stands: its latest order status, and each line's latest status of its own
with latest_order as (
  select distinct on (order_id) order_id, status_type_id, status_datetime
  from order_status
  where order_id is not null and order_item_id is null
  order by order_id, status_datetime desc
),
latest_item as (
  select distinct on (order_item_id) order_item_id, status_type_id
  from order_status
  where order_item_id is not null and order_id is null
  order by order_item_id, status_datetime desc
)
select o.order_id, o.order_kind, ot.description as order_status, lo.status_datetime as since,
       string_agg('line ' || oi.order_item_seq_id || ': ' || it.description, '; ' order by oi.order_item_seq_id) as line_statuses
from "order" o
left join latest_order lo    on lo.order_id = o.order_id
left join status_type ot     on ot.status_type_id = lo.status_type_id
left join order_item oi      on oi.order_id = o.order_id
left join latest_item li     on li.order_item_id = oi.order_item_id
left join status_type it     on it.status_type_id = li.status_type_id
group by o.order_id, o.order_kind, ot.description, lo.status_datetime
order by o.order_id;

-- name: 4.7 — Order 12561's history: order and line statuses in one timeline
select s.status_datetime,
       coalesce('line ' || oi.order_item_seq_id || ' (' || coalesce(p.name, f.description, oi.item_description) || ')',
                'the order') as status_of,
       t.description as status
from order_status s
join status_type t            on t.status_type_id = s.status_type_id
left join order_item oi       on oi.order_item_id = s.order_item_id
left join product p           on p.product_id = oi.product_id
left join product_feature f   on f.product_feature_id = oi.product_feature_id
where coalesce(s.order_id, oi.order_id) = 12561
order by s.status_datetime;

-- name: 4.7 — The terms of orders 12560 and A2395 (2395), as Table 4.9 shows them
select coalesce(t.order_id, oi.order_id) as order_id, oi.order_item_seq_id as line,
       coalesce(p.name, oi.item_description) as product, t.term_value as value, tt.description as term_type
from order_term t
join term_type tt         on tt.term_type_id = t.term_type_id
left join order_item oi   on oi.order_item_id = t.order_item_id
left join product p       on p.product_id = oi.product_id
where coalesce(t.order_id, oi.order_id) in (12560, 2395)
order by coalesce(t.order_id, oi.order_id) = 2395, oi.order_item_seq_id nulls first, t.order_term_id;

-- name: 4.7 — Cancelling for free: each order's penalty-free window from its terms, and what cancelling after it costs
-- The values mean days or a percentage only through their type, so the query
-- has to know which type holds which.
with lines as (
  select order_id, sum(quantity * unit_price) as lines_value
  from order_item
  group by order_id
),
cancelled as (
  select order_id, min(status_datetime)::date as cancelled_on
  from order_status
  where status_type_id = 'ORDER_CANCELLED' and order_id is not null
  group by order_id
)
select o.order_id, o.order_date, w.term_value as free_days,
       o.order_date + w.term_value::int as free_until,
       c.term_value as charge_pct,
       round(l.lines_value * c.term_value / 100, 2) as charge_after,
       x.cancelled_on,
       case when x.cancelled_on is null                               then 'not cancelled'
            when x.cancelled_on <= o.order_date + w.term_value::int  then 'cancelled in time: no charge'
            when c.term_value is null                                then 'cancelled late, but no charge was agreed'
            else 'cancelled late: the charge is due' end as outcome
from "order" o
join order_term w        on w.order_id = o.order_id and w.term_type_id = 'PENALTY_FREE_CANCEL_DAYS'
left join order_term c   on c.order_id = o.order_id and c.term_type_id = 'CANCELLATION_CHARGE_PCT'
join lines l             on l.order_id = o.order_id
left join cancelled x    on x.order_id = o.order_id
order by o.order_id;

-- name: 4.7 — Data-quality check: statuses or terms for both an order and an item, or for neither (should be empty)
select 'status' as row_kind, order_status_id as id, order_id, order_item_id
from order_status
where (order_id is null) = (order_item_id is null)
union all
select 'term', order_term_id, order_id, order_item_id
from order_term
where (order_id is null) = (order_item_id is null);

-- name: 4.7 — Data-quality check: order statuses that aren't order statuses (should be empty)
select s.order_status_id, s.order_id, s.order_item_id, s.status_type_id, t.parent_type_id
from order_status s
join status_type t on t.status_type_id = s.status_type_id
where t.parent_type_id is distinct from 'ORDER_STATUS';

-- name: 4.7 — Data-quality check: statuses dated before their order was placed (should be empty)
select s.order_status_id, o.order_id, o.order_date, s.status_type_id, s.status_datetime
from order_status s
left join order_item oi on oi.order_item_id = s.order_item_id
join "order" o          on o.order_id = coalesce(s.order_id, oi.order_id)
where s.status_datetime::date < o.order_date;

-- name: 4.7 — Data-quality check: one term type twice on the same order or item (should be empty)
select term_type_id, order_id, order_item_id, count(*) as terms,
       string_agg(coalesce(term_value::text, 'no value'), ', ' order by order_term_id) as term_values
from order_term
group by term_type_id, order_id, order_item_id
having count(*) > 1;

-- ============================================================
-- Fig 4.8 — Order item association
-- ============================================================

-- name: 4.8 — Table 4.10 and ours: each sales line, and the purchase lines that will fill it
select s.order_id as sales_order, s.order_item_seq_id as sales_line, coalesce(sp.name, s.item_description) as sold,
       s.quantity as sold_qty,
       p.order_id as purchase_order, p.order_item_seq_id as purchase_line, coalesce(pp.name, p.item_description) as bought,
       p.quantity as bought_qty, n.name as supplier
from order_item_association a
join order_item s               on s.order_item_id = a.sales_order_item_id
join order_item p               on p.order_item_id = a.purchase_order_item_id
left join product sp            on sp.product_id = s.product_id
left join product pp            on pp.product_id = p.product_id
join purchase_order po          on po.order_id = p.order_id
left join party_role r          on r.party_role_id = po.taken_by_party_role_id
left join party_display_name n  on n.party_id = r.party_id
order by s.order_id, s.order_item_seq_id, p.order_id, p.order_item_seq_id;

-- name: 4.8 — Sales lines with a purchase behind them, beside their latest recorded status (whether the goods arrived needs Ch 5's shipments)
with latest as (
  select distinct on (order_item_id) order_item_id, status_type_id
  from order_status
  where order_item_id is not null and order_id is null
  order by order_item_id, status_datetime desc
),
linked as (
  select sales_order_item_id, count(distinct purchase_order_item_id) as purchase_lines
  from order_item_association
  group by sales_order_item_id
)
select oi.order_id, oi.order_item_seq_id as line, coalesce(p.name, oi.item_description) as item,
       coalesce(l.purchase_lines, 0) as purchase_lines_behind_it, t.description as latest_recorded_status
from sales_order_item s
join order_item oi       on oi.order_item_id = s.order_item_id
left join product p      on p.product_id = oi.product_id
left join linked l       on l.sales_order_item_id = s.order_item_id
left join latest x       on x.order_item_id = s.order_item_id
left join status_type t  on t.status_type_id = x.status_type_id
where l.sales_order_item_id is not null or x.status_type_id = 'ORDER_BACKORDERED'
order by oi.order_id, oi.order_item_seq_id;

-- name: 4.8 — For review: purchase lines filling several sales lines, and sales lines filled from several purchase lines (no quantity on the link, so the split is unknown)
select 'one purchase line, several sales lines' as shape, p.order_id, p.order_item_seq_id as line, p.quantity,
       string_agg(distinct s.order_id || ' line ' || s.order_item_seq_id || ' (' || s.quantity || ')', ', ') as linked_lines
from order_item_association a
join order_item p on p.order_item_id = a.purchase_order_item_id
join order_item s on s.order_item_id = a.sales_order_item_id
group by p.order_item_id, p.order_id, p.order_item_seq_id, p.quantity
having count(distinct a.sales_order_item_id) > 1
union all
select 'one sales line, several purchase lines', s.order_id, s.order_item_seq_id, s.quantity,
       string_agg(distinct p.order_id || ' line ' || p.order_item_seq_id || ' (' || p.quantity || ')', ', ')
from order_item_association a
join order_item p on p.order_item_id = a.purchase_order_item_id
join order_item s on s.order_item_id = a.sales_order_item_id
group by s.order_item_id, s.order_id, s.order_item_seq_id, s.quantity
having count(distinct a.purchase_order_item_id) > 1
order by shape, order_id, line;

-- name: 4.8 — Data-quality check: the same sales and purchase lines linked twice (should be empty)
select sales_order_item_id, purchase_order_item_id, count(*) as links
from order_item_association
group by sales_order_item_id, purchase_order_item_id
having count(*) > 1;

-- name: 4.8 — Data-quality check: a purchase line linked to a sales line for another product (should be empty)
select a.order_item_association_id, s.order_id as sales_order, s.order_item_seq_id as sales_line, sp.name as sold,
       p.order_id as purchase_order, p.order_item_seq_id as purchase_line, pp.name as bought
from order_item_association a
join order_item s   on s.order_item_id = a.sales_order_item_id
join order_item p   on p.order_item_id = a.purchase_order_item_id
join product sp     on sp.product_id = s.product_id
join product pp     on pp.product_id = p.product_id
where s.product_id <> p.product_id;

-- name: 4.8 — Data-quality check: lines recorded as backordered with no purchase line behind them (should be empty)
select s.order_status_id, oi.order_id, oi.order_item_seq_id as line, oi.item_description, s.status_datetime
from order_status s
join order_item oi on oi.order_item_id = s.order_item_id
where s.status_type_id = 'ORDER_BACKORDERED'
  and not exists (select 1 from order_item_association a where a.sales_order_item_id = s.order_item_id);

-- ============================================================
-- Fig 4.9 — Requirements
-- ============================================================

-- name: 4.9 — Every requirement, Table 4.11's first: owner on the creation date, parent, quantity, product and desired features
select r.requirement_id, r.requirement_creation_date as created,
       (select string_agg(n.name, ' + ')
        from requirement_role o
        join party_display_name n on n.party_id = o.party_id
        where o.requirement_id = r.requirement_id and o.requirement_role_type_id = 'OWNER'
          and o.from_date <= r.requirement_creation_date
          and (o.thru_date is null or o.thru_date > r.requirement_creation_date)) as owner,
       r.description, r.part_of_requirement_id as part_of, r.quantity, p.name as product,
       string_agg(f.description || coalesce(' ' || f.number_specified || ' ' || f.uom_id, '')
                  || case when d.optional_ind then ' (optional)' else '' end,
                  ', ' order by d.desired_feature_id) as desired_features
from requirement r
left join product_requirement pr  on pr.requirement_id = r.requirement_id
left join product p               on p.product_id = pr.product_id
left join desired_feature d       on d.requirement_id = r.requirement_id
left join product_feature f       on f.product_feature_id = d.product_feature_id
group by r.requirement_id, r.requirement_creation_date, r.description, r.part_of_requirement_id, r.quantity, p.name
order by r.requirement_id >= 50000, r.requirement_id;

-- name: 4.9 — Requirement trees: each requirement under the one it's part of, with whose need and what kind
with recursive tree (requirement_id, depth, path) as (
  select requirement_id, 0, array[requirement_id]
  from requirement
  where part_of_requirement_id is null
  union all
  select r.requirement_id, t.depth + 1, t.path || r.requirement_id
  from requirement r
  join tree t on r.part_of_requirement_id = t.requirement_id
  where t.depth < 10
)
select repeat('    ', t.depth) || r.requirement_id || ' ' || r.description as requirement,
       r.requirement_origin as whose_need, r.requirement_kind as kind, r.quantity
from tree t
join requirement r on r.requirement_id = t.requirement_id
order by t.path;

-- name: 4.9 — Catalogue products that could fill each product requirement: every must-have feature offered on the creation date
with need as (
  select d.requirement_id, d.product_feature_id, r.requirement_creation_date as on_date
  from desired_feature d
  join requirement r on r.requirement_id = d.requirement_id
  where not d.optional_ind
),
must as (
  select requirement_id, count(*) as must_haves
  from need
  group by requirement_id
),
offer as (
  select n.requirement_id, a.product_id, count(*) as met
  from need n
  join product_feature_applicability a
    on a.product_feature_id = n.product_feature_id
   and a.from_date <= n.on_date and (a.thru_date is null or a.thru_date > n.on_date)
  group by n.requirement_id, a.product_id
)
select r.requirement_id, r.description, m.must_haves, p.name as product_named,
       coalesce(string_agg(c.name, '; ' order by c.name) filter (where o.met = m.must_haves),
                '(no product offers them all)') as candidates
from must m
join requirement r               on r.requirement_id = m.requirement_id
left join product_requirement pr on pr.requirement_id = r.requirement_id
left join product p              on p.product_id = pr.product_id
left join offer o                on o.requirement_id = m.requirement_id
left join product c              on c.product_id = o.product_id
group by r.requirement_id, r.description, m.must_haves, p.name
order by r.requirement_id;

-- name: 4.9 — Each requirement against its commitments: needed, committed, left, by which order lines, and its latest status
with committed as (
  select c.requirement_id, sum(c.quantity) as committed,
         string_agg(oi.order_id || ' line ' || oi.order_item_seq_id || ' (' || c.quantity || ')', ', '
                    order by oi.order_id, oi.order_item_seq_id) as order_lines
  from order_requirement_commitment c
  join order_item oi on oi.order_item_id = c.order_item_id
  group by c.requirement_id
),
latest as (
  select distinct on (requirement_id) requirement_id, status_type_id
  from requirement_status
  order by requirement_id, status_date desc, requirement_status_id desc
)
select r.requirement_id, r.description, r.quantity as needed, c.committed,
       r.quantity - coalesce(c.committed, 0) as left_to_commit, c.order_lines, t.description as latest_status
from requirement r
left join committed c   on c.requirement_id = r.requirement_id
left join latest l      on l.requirement_id = r.requirement_id
left join status_type t on t.status_type_id = l.status_type_id
where c.requirement_id is not null or l.requirement_id is not null
order by r.requirement_id;

-- name: 4.9 — Data-quality check: requirement_kind and the product_requirement subtype table disagree (should be empty)
select r.requirement_id, r.description, r.requirement_kind, (p.requirement_id is not null) as has_product_requirement_row
from requirement r
left join product_requirement p on p.requirement_id = r.requirement_id
where (r.requirement_kind = 'PRODUCT') <> (p.requirement_id is not null);

-- name: 4.9 — Data-quality check: commitments beyond the requirement's quantity (should be empty)
select r.requirement_id, r.description, r.quantity as needed, sum(c.quantity) as committed
from requirement r
join order_requirement_commitment c on c.requirement_id = r.requirement_id
group by r.requirement_id, r.description, r.quantity
having sum(c.quantity) > r.quantity;

-- name: 4.9 — Data-quality check: desired features the requirement's product doesn't offer on the creation date (should be empty)
select r.requirement_id, r.description, p.name as product, f.description as feature, r.requirement_creation_date
from desired_feature d
join product_requirement pr on pr.requirement_id = d.requirement_id
join requirement r          on r.requirement_id = d.requirement_id
join product p              on p.product_id = pr.product_id
join product_feature f      on f.product_feature_id = d.product_feature_id
where not exists (
  select 1
  from product_feature_applicability a
  where a.product_id = pr.product_id
    and a.product_feature_id = d.product_feature_id
    and a.from_date <= r.requirement_creation_date
    and (a.thru_date is null or a.thru_date > r.requirement_creation_date)
);

-- name: 4.9 — Data-quality check: requirements using a status that isn't a requirement status (should be empty)
select s.requirement_status_id, s.requirement_id, s.status_type_id, t.parent_type_id
from requirement_status s
join status_type t on t.status_type_id = s.status_type_id
where t.parent_type_id is distinct from 'REQUIREMENT_STATUS';

-- name: 4.9 — Data-quality check: two owners of one requirement at the same time (should be empty)
select a.requirement_id, na.name as owner, nb.name as other_owner, greatest(a.from_date, b.from_date) as overlap_from
from requirement_role a
join requirement_role b         on b.requirement_id = a.requirement_id
                               and b.requirement_role_id > a.requirement_role_id
join party_display_name na      on na.party_id = a.party_id
join party_display_name nb      on nb.party_id = b.party_id
where a.requirement_role_type_id = 'OWNER' and b.requirement_role_type_id = 'OWNER'
  and a.from_date < coalesce(b.thru_date, 'infinity'::date)
  and b.from_date < coalesce(a.thru_date, 'infinity'::date);

-- ============================================================
-- Fig 4.10 — Requests
-- ============================================================

-- name: 4.10 — Requests as Tables 4.12 and 4.13 show them: originator, type, dates, and each item with the requirements it carries
select q.request_id,
       (select string_agg(n.name, ' + ')
        from request_role r
        join party_display_name n on n.party_id = r.party_id
        where r.request_id = q.request_id and r.request_role_type_id = 'ORIGINATOR') as originator,
       q.request_type_id as type, q.request_date, q.response_required_date as answer_by, q.description,
       i.request_item_seq_id as item, i.quantity,
       string_agg(rq.requirement_id || ' ' || rq.description, '; ' order by rq.requirement_id) as requirements
from request q
join request_item i              on i.request_id = q.request_id
left join requirement_request rr on rr.request_item_id = i.request_item_id
left join requirement rq         on rq.requirement_id = rr.requirement_id
group by q.request_id, q.request_type_id, q.request_date, q.response_required_date, q.description,
         i.request_item_id, i.request_item_seq_id, i.quantity
order by q.request_id >= 60000, q.request_date, q.request_id, i.request_item_seq_id;

-- name: 4.10 — Who each request went to, when, and through which contact mechanism (a request we receive has one responding party: us)
select q.request_id, q.request_type_id as type, n.name as sent_to, d.display_name as via, p.date_sent
from responding_party p
join request q                                   on q.request_id = p.request_id
join party_display_name n                        on n.party_id = p.party_id
left join contact_mechanism_display_name d       on d.contact_mechanism_id = p.contact_mechanism_id
order by q.request_id >= 60000, q.request_date, q.request_id, n.name;

-- name: 4.10 — Each requirement's requests in date order (24905 went out on the RFI, then the RFP)
select rq.requirement_id, rq.description,
       string_agg(q.request_type_id || ' ' || q.request_id || ' of ' || q.request_date, ' → '
                  order by q.request_date, q.request_id) as requests
from requirement rq
join requirement_request rr  on rr.requirement_id = rq.requirement_id
join request_item i          on i.request_item_id = rr.request_item_id
join request q               on q.request_id = i.request_id
group by rq.requirement_id, rq.description
order by rq.requirement_id;

-- name: 4.10 — Data-quality check: the same requirement twice on a request item, or the same party twice on a request (should be empty)
select 'requirement on an item' as what, request_item_id as on_id, requirement_id as twice, count(*) as rows
from requirement_request
group by request_item_id, requirement_id
having count(*) > 1
union all
select 'responding party on a request', request_id, party_id, count(*)
from responding_party
group by request_id, party_id
having count(*) > 1;

-- name: 4.10 — Data-quality check: requirements sent out on a request dated before they were created (should be empty)
select q.request_id, q.request_type_id, q.request_date, rq.requirement_id, rq.description, rq.requirement_creation_date
from requirement_request rr
join request_item i on i.request_item_id = rr.request_item_id
join request q      on q.request_id = i.request_id
join requirement rq on rq.requirement_id = rr.requirement_id
where q.request_date < rq.requirement_creation_date;

-- name: 4.10 — Data-quality check: requests sent to a party before the request's own date (should be empty)
select p.request_id, q.request_date, n.name as sent_to, p.date_sent
from responding_party p
join request q            on q.request_id = p.request_id
join party_display_name n on n.party_id = p.party_id
where p.date_sent < q.request_date;

-- name: 4.10 — Data-quality check: requests with more than one originator (should be empty)
select r.request_id, string_agg(n.name, ' + ' order by n.name) as originators
from request_role r
join party_display_name n on n.party_id = r.party_id
where r.request_role_type_id = 'ORIGINATOR'
group by r.request_id
having count(*) > 1;

-- ============================================================
-- Fig 4.11 — Quotes
-- ============================================================

-- name: 4.11 — Quotes as Table 4.14 shows them, with who issued them, to whom, and what each item prices
select q.quote_id, q.quote_type_id as type, q.issue_date, q.description,
       q.valid_from_date as valid_from, q.valid_thru_date - 1 as valid_through,
       ib.name as issued_by, gt.name as given_to,
       i.quote_item_seq_id as item, coalesce(p.name, w.name) as quoted, i.quantity, i.quote_unit_price
from quote q
join party_display_name ib       on ib.party_id = q.issued_by_party_id
left join party_display_name gt  on gt.party_id = q.given_to_party_id
left join quote_item i           on i.quote_id = q.quote_id
left join product p              on p.product_id = i.product_id
left join work_effort w          on w.work_effort_id = i.work_effort_id
order by q.quote_id >= 60000, q.issue_date, q.quote_id, i.quote_item_seq_id;

-- name: 4.11 — Competing quotes for each request item, cheapest first, and whether an order line accepted one
select q.request_id, ri.request_item_seq_id as item, ri.quantity as asked,
       n.name as quoted_by, coalesce(p.name, w.name) as quoted, qi.quantity, qi.quote_unit_price,
       exists (select 1 from order_item oi where oi.quote_item_id = qi.quote_item_id) as accepted
from quote_item qi
join request_item ri         on ri.request_item_id = qi.request_item_id
join request q               on q.request_id = ri.request_id
join quote qt                on qt.quote_id = qi.quote_id
join party_display_name n    on n.party_id = qt.issued_by_party_id
left join product p          on p.product_id = qi.product_id
left join work_effort w      on w.work_effort_id = qi.work_effort_id
order by q.request_id, ri.request_item_seq_id, qi.quote_unit_price;

-- name: 4.11 — From need to order: each requirement's request, the quotes that answered it, the order line that accepted one, and what it committed back
select rq.requirement_id, rq.description as need,
       q.request_type_id || ' ' || q.request_id as asked_on,
       qt.quote_id || ' from ' || n.name || ' at ' || qi.quote_unit_price as quote,
       oi.order_id || ' line ' || oi.order_item_seq_id || ' of ' || o.order_date as accepted_by,
       c.quantity as committed_to_need
from requirement rq
join requirement_request rr                    on rr.requirement_id = rq.requirement_id
join request_item ri                           on ri.request_item_id = rr.request_item_id
join request q                                 on q.request_id = ri.request_id
left join quote_item qi                        on qi.request_item_id = ri.request_item_id
left join quote qt                             on qt.quote_id = qi.quote_id
left join party_display_name n                 on n.party_id = qt.issued_by_party_id
left join order_item oi                        on oi.quote_item_id = qi.quote_item_id
left join "order" o                            on o.order_id = oi.order_id
left join order_requirement_commitment c       on c.order_item_id = oi.order_item_id
                                              and c.requirement_id = rq.requirement_id
where rq.requirement_id in (24905, 30005, 50001)
order by rq.requirement_id, q.request_date, qt.quote_id, oi.order_id;

-- name: 4.11 — The product quoted against what the need asks for: the product it names, or else its must-have features (Table 4.15's black pens for a blue need)
select qt.quote_id, qi.quote_item_seq_id as item, n.name as quoted_by, rq.requirement_id, rq.description as need,
       wanted.name as product_wanted, quoted.name as product_quoted,
       case when pr.product_id = qi.product_id    then 'the same product'
            when pr.product_id is not null        then 'another product'
            when lacking.features is not null     then 'lacks ' || lacking.features
            when exists (select 1 from desired_feature d where d.requirement_id = rq.requirement_id)
                                                  then 'has every must-have feature'
            else 'the need names no product or feature' end as comparison
from quote_item qi
join quote qt                       on qt.quote_id = qi.quote_id
join party_display_name n           on n.party_id = qt.issued_by_party_id
join requirement_request rr         on rr.request_item_id = qi.request_item_id
join requirement rq                 on rq.requirement_id = rr.requirement_id
left join product_requirement pr    on pr.requirement_id = rq.requirement_id
left join product wanted            on wanted.product_id = pr.product_id
join product quoted                 on quoted.product_id = qi.product_id
left join lateral (
  select string_agg(f.description, ', ' order by f.description) as features
  from desired_feature d
  join product_feature f on f.product_feature_id = d.product_feature_id
  where d.requirement_id = rq.requirement_id
    and not d.optional_ind
    and not exists (select 1 from product_feature_applicability a
                    where a.product_id = qi.product_id
                      and a.product_feature_id = d.product_feature_id
                      and a.from_date <= qt.issue_date and (a.thru_date is null or a.thru_date > qt.issue_date))
) lacking on true
order by qt.quote_id, qi.quote_item_seq_id;

-- name: 4.11 — Data-quality check: quote items pricing both a product and a work effort, or neither (should be empty)
select quote_item_id, quote_id, quote_item_seq_id, product_id, work_effort_id, comment
from quote_item
where (product_id is null) = (work_effort_id is null);

-- name: 4.11 — Data-quality check: quote terms for both a quote and an item, or for neither (should be empty)
select quote_term_id, term_type_id, quote_id, quote_item_id
from quote_term
where (quote_id is null) = (quote_item_id is null);

-- name: 4.11 — Data-quality check: order lines accepting a quote that wasn't valid on the order's date (should be empty)
select oi.order_id, oi.order_item_seq_id as line, o.order_date, qt.quote_id, qt.valid_from_date, qt.valid_thru_date - 1 as valid_through
from order_item oi
join "order" o       on o.order_id = oi.order_id
join quote_item qi   on qi.quote_item_id = oi.quote_item_id
join quote qt        on qt.quote_id = qi.quote_id
where not (o.order_date >= qt.valid_from_date and o.order_date < qt.valid_thru_date);

-- ============================================================
-- Fig 4.12 — Agreement definition
-- ============================================================

-- name: 4.12 — Agreements as Table 4.16 shows them: type (under its parent), parties in their roles, the relationship formalized, start and end
select a.agreement_id, t.description || coalesce(' (' || lower(pt.description) || ')', '') as type, a.description,
       (select string_agg(n.name || ' (' || lower(rt.description) || ')', ', ' order by rt.agreement_role_type_id, n.name)
          from agreement_role r
          join party_display_name n       on n.party_id = r.party_id
          join agreement_role_type rt     on rt.agreement_role_type_id = r.agreement_role_type_id
         where r.agreement_id = a.agreement_id) as roles,
       prt.name as party_relationship, a.from_date as starting, a.thru_date - 1 as ending
from agreement a
join agreement_type t                     on t.agreement_type_id = a.agreement_type_id
left join agreement_type pt               on pt.agreement_type_id = t.parent_type_id
left join party_relationship pr           on pr.party_relationship_id = a.party_relationship_id
left join party_relationship_type prt     on prt.party_relationship_type_id = pr.party_relationship_type_id
order by a.agreement_id between 70000 and 79999, a.agreement_id;

-- name: 4.12 — One party, many hats: every agreement ABC Corporation and Northwind are in, the role each plays, and whether it was in force on 2002-06-01 and 2025-06-01
select n.name as party, rt.description as role, a.agreement_id, t.description as type,
       a.from_date, a.thru_date - 1 as ending,
       (a.from_date <= date '2002-06-01' and (a.thru_date is null or a.thru_date > date '2002-06-01')) as in_force_2002_06_01,
       (a.from_date <= date '2025-06-01' and (a.thru_date is null or a.thru_date > date '2025-06-01')) as in_force_2025_06_01
from agreement_role r
join party_display_name n     on n.party_id = r.party_id
join agreement_role_type rt   on rt.agreement_role_type_id = r.agreement_role_type_id
join agreement a              on a.agreement_id = r.agreement_id
join agreement_type t         on t.agreement_type_id = a.agreement_type_id
where r.party_id in (12, 4)
order by n.name, a.from_date;

-- name: 4.12 — Product agreements (sales or purchase, at any depth of the type tree) and the parties on each side
with recursive under_product (agreement_type_id) as (
  select agreement_type_id from agreement_type where agreement_type_id = 'PRODUCT_AGREEMENT'
  union all
  select t.agreement_type_id from agreement_type t join under_product u on t.parent_type_id = u.agreement_type_id
)
select a.agreement_id, a.agreement_type_id as type, a.description,
       string_agg(n.name, ', ' order by n.name) filter (where r.agreement_role_type_id = 'SUPPLIER') as suppliers,
       string_agg(n.name, ', ' order by n.name) filter (where r.agreement_role_type_id = 'CUSTOMER') as customers
from agreement a
join under_product u              on u.agreement_type_id = a.agreement_type_id
left join agreement_role r        on r.agreement_id = a.agreement_id
left join party_display_name n    on n.party_id = r.party_id
group by a.agreement_id, a.agreement_type_id, a.description
order by a.agreement_id;

-- name: 4.12 — Data-quality check: agreements whose party relationship has an end that plays no role in the agreement (should be empty; 10002 is the book's own row, NOTES point 23)
select a.agreement_id, a.description, e.end_name as relationship_end, n.name as party_without_a_role
from agreement a
join party_relationship pr on pr.party_relationship_id = a.party_relationship_id
cross join lateral (values ('from', pr.from_party_role_id), ('to', pr.to_party_role_id)) e(end_name, party_role_id)
join party_role ro               on ro.party_role_id = e.party_role_id
join party_display_name n        on n.party_id = ro.party_id
where not exists (select 1 from agreement_role r
                  where r.agreement_id = a.agreement_id and r.party_id = ro.party_id)
order by a.agreement_id, e.end_name;

-- name: 4.12 — Data-quality check: agreements formalizing a party relationship that wasn't current on the day they began (should be empty)
select a.agreement_id, a.description, a.from_date as agreement_from,
       pr.party_relationship_id, pr.from_date as relationship_from, pr.thru_date as relationship_thru
from agreement a
join party_relationship pr on pr.party_relationship_id = a.party_relationship_id
where not (pr.from_date <= a.from_date and (pr.thru_date is null or pr.thru_date > a.from_date));

-- name: 4.12 — Data-quality check: the same party in the same role twice on one agreement (should be empty)
select agreement_id, party_id, agreement_role_type_id, count(*) as times
from agreement_role
group by agreement_id, party_id, agreement_role_type_id
having count(*) > 1;

-- ============================================================
-- Fig 4.13 — Agreement item
-- ============================================================

-- name: 4.13 — Each agreement as an outline: items nested under the items they sit in, with their type, what limits them, and their addenda
with recursive outline as (
  select i.agreement_item_id, i.agreement_id, i.agreement_item_seq_id, i.agreement_item_type_id, i.agreement_text,
         0 as depth, lpad(i.agreement_item_seq_id::text, 3, '0') as path
  from agreement_item i
  where i.part_of_agreement_item_id is null
  union all
  select c.agreement_item_id, c.agreement_id, c.agreement_item_seq_id, c.agreement_item_type_id, c.agreement_text,
         o.depth + 1, o.path || '.' || lpad(c.agreement_item_seq_id::text, 3, '0')
  from agreement_item c
  join outline o on o.agreement_item_id = c.part_of_agreement_item_id
)
select o.agreement_id, repeat('. ', o.depth) || o.agreement_item_seq_id || ' ' || o.agreement_text as item,
       o.agreement_item_type_id as type,
       (select string_agg(n.name, ', ') from agreement_organization_applicability x
          join party_display_name n on n.party_id = x.party_id
         where x.agreement_item_id = o.agreement_item_id) as organizations,
       (select string_agg(p.name, ', ') from agreement_product_applicability x
          join product p on p.product_id = x.product_id
         where x.agreement_item_id = o.agreement_item_id) as products,
       (select string_agg(g.name, ', ') from agreement_geographical_applicability x
          join geographic_boundary g on g.geographic_boundary_id = x.geographic_boundary_id
         where x.agreement_item_id = o.agreement_item_id) as places,
       (select string_agg(ad.addendum_effective_date || ': ' || ad.addendum_text, '; ' order by ad.addendum_effective_date)
          from addendum ad where ad.agreement_item_id = o.agreement_item_id) as addenda
from outline o
order by o.agreement_id between 70000 and 79999, o.agreement_id, o.path;

-- name: 4.13 — Addenda: what each changes (the whole agreement or one item), from when, and whether it was in force on 2025-04-15
select ad.addendum_id, a.agreement_id,
       case when ad.agreement_item_id is null then 'the whole agreement'
            else 'item ' || i.agreement_item_seq_id || ': ' || i.agreement_text end as changes,
       ad.addendum_creation_date as created, ad.addendum_effective_date as effective, ad.addendum_text,
       coalesce(ad.addendum_effective_date <= date '2025-04-15'
                and a.from_date <= date '2025-04-15' and (a.thru_date is null or a.thru_date > date '2025-04-15'), false) as in_force_2025_04_15
from addendum ad
left join agreement_item i on i.agreement_item_id = ad.agreement_item_id
join agreement a           on a.agreement_id = coalesce(ad.agreement_id, i.agreement_id)
order by a.agreement_id between 70000 and 79999, a.agreement_id, ad.addendum_effective_date;

-- name: 4.13 — Which pricing programs apply to each sales order line: an agreement in force on the order's date, with the placing or bill-to party in a role, and a program whose organizations, products and places all match (none of a kind = no limit)
with line as (
  select oi.order_id, oi.order_item_seq_id, o.order_date, oi.product_id, soi.ship_to_contact_mechanism_id,
         array_remove(array[pl.party_id, bt.party_id], null) as customer_parties
  from order_item oi
  join "order" o                 on o.order_id = oi.order_id
  join sales_order so            on so.order_id = oi.order_id
  left join sales_order_item soi on soi.order_item_id = oi.order_item_id
  left join party_role pl        on pl.party_role_id = so.placed_by_party_role_id
  left join party_role bt        on bt.party_role_id = so.bill_to_party_role_id
  where oi.product_id is not null
)
select l.order_id, l.order_item_seq_id as line, l.order_date, p.name as product, ship.display_name as ship_to,
       coalesce(pp.programs, '(none)') as pricing_programs
from line l
join product p                                on p.product_id = l.product_id
left join contact_mechanism_display_name ship on ship.contact_mechanism_id = l.ship_to_contact_mechanism_id
left join lateral (
  select string_agg(a.agreement_id || '/' || i.agreement_item_seq_id || ' ' || i.agreement_text, '; '
                    order by a.agreement_id, i.agreement_item_seq_id) as programs
  from agreement a
  join agreement_item i on i.agreement_id = a.agreement_id and i.agreement_item_type_id = 'PRICING_PROGRAM'
  where a.from_date <= l.order_date and (a.thru_date is null or a.thru_date > l.order_date)
    and exists (select 1 from agreement_role r
                where r.agreement_id = a.agreement_id and r.party_id = any (l.customer_parties))
    and (not exists (select 1 from agreement_organization_applicability x where x.agreement_item_id = i.agreement_item_id)
         or exists (select 1 from agreement_organization_applicability x
                    where x.agreement_item_id = i.agreement_item_id and x.party_id = any (l.customer_parties)))
    and (not exists (select 1 from agreement_product_applicability x where x.agreement_item_id = i.agreement_item_id)
         or exists (select 1 from agreement_product_applicability x
                    where x.agreement_item_id = i.agreement_item_id and x.product_id = l.product_id))
    and (not exists (select 1 from agreement_geographical_applicability x where x.agreement_item_id = i.agreement_item_id)
         or exists (select 1 from agreement_geographical_applicability x
                    join postal_address_boundary pb         on pb.contact_mechanism_id = l.ship_to_contact_mechanism_id
                    join geographic_boundary_ancestor ga    on ga.geographic_boundary_id = pb.geographic_boundary_id
                    where x.agreement_item_id = i.agreement_item_id and ga.ancestor_id = x.geographic_boundary_id))
) pp on true
order by l.order_date, l.order_id, l.order_item_seq_id;

-- name: 4.13 — Data-quality check: addenda changing both the agreement and an item, or neither (should be empty)
select addendum_id, agreement_id, agreement_item_id, addendum_text
from addendum
where (agreement_id is null) = (agreement_item_id is null);

-- name: 4.13 — Data-quality check: items sitting inside an item of another agreement (should be empty)
select c.agreement_item_id, c.agreement_id, c.agreement_item_seq_id as item, c.agreement_text,
       p.agreement_id as parent_agreement_id, p.agreement_item_seq_id as parent_item
from agreement_item c
join agreement_item p on p.agreement_item_id = c.part_of_agreement_item_id
where p.agreement_id <> c.agreement_id;

-- name: 4.13 — Data-quality check: addenda effective outside their agreement's dates (should be empty)
select ad.addendum_id, a.agreement_id, a.from_date, a.thru_date - 1 as ending, ad.addendum_effective_date, ad.addendum_text
from addendum ad
left join agreement_item i on i.agreement_item_id = ad.agreement_item_id
join agreement a           on a.agreement_id = coalesce(ad.agreement_id, i.agreement_id)
where ad.addendum_effective_date is not null
  and not (ad.addendum_effective_date >= a.from_date and (a.thru_date is null or ad.addendum_effective_date < a.thru_date));

-- ============================================================
-- Fig 4.14 — Agreement terms
-- ============================================================

-- name: 4.14 — Each agreement's terms: on the whole agreement or one item, with their kind (the top of TERM TYPE), value and dates
select a.agreement_id, at.description as agreement_type,
       coalesce('item ' || i.agreement_item_seq_id || ': ' || i.agreement_text, '(the whole agreement)') as applies_to,
       coalesce(k.description, '(no kind)') as kind, t.description as term, tm.term_value,
       tm.from_date, tm.thru_date - 1 as last_day
from agreement_term tm
join term_type t           on t.term_type_id = tm.term_type_id
left join term_type k      on k.term_type_id = t.parent_type_id
left join agreement_item i on i.agreement_item_id = tm.agreement_item_id
join agreement a           on a.agreement_id = coalesce(tm.agreement_id, i.agreement_id)
join agreement_type at     on at.agreement_type_id = a.agreement_type_id
order by a.agreement_id between 70000 and 79999, a.agreement_id, i.agreement_item_seq_id nulls first, tm.from_date;

-- name: 4.14 — One TERM TYPE for orders, quotes and agreements: each kind, its types, and how often each is used where
with recursive kind as (
  select term_type_id, term_type_id as kind_id, 0 as depth
  from term_type where parent_type_id is null
  union all
  select t.term_type_id, k.kind_id, k.depth + 1
  from term_type t join kind k on k.term_type_id = t.parent_type_id
)
select kt.description as kind, t.description as term_type,
       (select count(*) from order_term x     where x.term_type_id = t.term_type_id) as order_terms,
       (select count(*) from quote_term x     where x.term_type_id = t.term_type_id) as quote_terms,
       (select count(*) from agreement_term x where x.term_type_id = t.term_type_id) as agreement_terms
from kind k
join term_type t  on t.term_type_id = k.term_type_id
join term_type kt on kt.term_type_id = k.kind_id
where k.depth > 0
order by kt.description, t.description;

-- name: 4.14 — Data-quality check: agreement terms on both the agreement and an item, or on neither (should be empty)
select agreement_term_id, term_type_id, agreement_id, agreement_item_id, term_value
from agreement_term
where (agreement_id is null) = (agreement_item_id is null);

-- name: 4.14 — Data-quality check: agreement terms dated outside their agreement (should be empty; a null thru date runs with the agreement)
select tm.agreement_term_id, a.agreement_id, t.description as term,
       a.from_date as agreement_from, a.thru_date - 1 as agreement_last_day,
       tm.from_date as term_from, tm.thru_date - 1 as term_last_day
from agreement_term tm
join term_type t           on t.term_type_id = tm.term_type_id
left join agreement_item i on i.agreement_item_id = tm.agreement_item_id
join agreement a           on a.agreement_id = coalesce(tm.agreement_id, i.agreement_id)
where tm.from_date < a.from_date
   or (a.thru_date is not null and tm.from_date >= a.thru_date)
   or (a.thru_date is not null and tm.thru_date > a.thru_date);

-- ============================================================
-- Fig 4.15 — Agreement pricing
-- ============================================================

-- name: 4.15 — Each pricing program's prices: what it charges, for which product, under which conditions, and when
select a.agreement_id, i.agreement_item_seq_id as item, i.agreement_text as program,
       t.description as component, coalesce(pr.name, '(any product)') as product,
       case when pc.price is not null then pc.price || ' ' || pc.currency_uom_id else pc.percent || '%' end as amount,
       concat_ws(', ',
         'in ' || gb.name,
         'qty ' || qb.from_quantity || coalesce(' to <' || qb.thru_quantity, '+'),
         'order ' || ov.from_amount || coalesce(' to <' || ov.thru_amount, '+'),
         'sale ' || st.description) as based_on,
       pc.from_date, pc.thru_date - 1 as last_day
from price_component pc
join agreement_item i            on i.agreement_item_id = pc.agreement_item_id
join agreement a                 on a.agreement_id = i.agreement_id
join price_component_type t      on t.price_component_type_id = pc.price_component_type_id
left join product pr             on pr.product_id = pc.product_id
left join geographic_boundary gb on gb.geographic_boundary_id = pc.geographic_boundary_id
left join quantity_break qb      on qb.quantity_break_id = pc.quantity_break_id
left join order_value ov         on ov.order_value_id = pc.order_value_id
left join sale_type st           on st.sale_type_id = pc.sale_type_id
order by a.agreement_id, i.agreement_item_seq_id, pc.from_date, pc.price_component_id;

-- name: 4.15 — Bond paper's base prices over time: the list (no program) and the agreed ones, side by side
select pc.from_date, pc.thru_date - 1 as last_day, pc.price, pc.currency_uom_id, gb.name as region,
       coalesce('agreement ' || i.agreement_id || ', item ' || i.agreement_item_seq_id, '(list price)') as source,
       pc.comment
from price_component pc
left join agreement_item i       on i.agreement_item_id = pc.agreement_item_id
left join geographic_boundary gb on gb.geographic_boundary_id = pc.geographic_boundary_id
where pc.product_id = 1
  and pc.price_component_type_id = 'BASE_PRICE'
order by pc.from_date, source;

-- name: 4.15 — Data-quality check: pricing-program rows and item types that disagree (should be empty)
select coalesce(p.agreement_item_id, i.agreement_item_id) as agreement_item_id,
       coalesce(x.agreement_id, i.agreement_id) as agreement_id,
       coalesce(x.agreement_text, i.agreement_text) as agreement_text,
       case when p.agreement_item_id is null then 'typed PRICING_PROGRAM, no program row'
            else 'program row, typed ' || x.agreement_item_type_id end as problem
from agreement_pricing_program p
full join (select * from agreement_item where agreement_item_type_id = 'PRICING_PROGRAM') i
  on i.agreement_item_id = p.agreement_item_id
left join agreement_item x on x.agreement_item_id = p.agreement_item_id
where p.agreement_item_id is null
   or i.agreement_item_id is null
order by 1;

-- name: 4.15 — Data-quality check: agreement prices dated outside their agreement (should be empty; a null thru date runs with the agreement, as for terms)
select pc.price_component_id, a.agreement_id, i.agreement_item_seq_id as item, pc.comment,
       a.from_date as agreement_from, a.thru_date - 1 as agreement_last_day,
       pc.from_date as price_from, pc.thru_date - 1 as price_last_day
from price_component pc
join agreement_item i on i.agreement_item_id = pc.agreement_item_id
join agreement a      on a.agreement_id = i.agreement_id
where pc.from_date < a.from_date
   or (a.thru_date is not null and pc.from_date >= a.thru_date)
   or (a.thru_date is not null and pc.thru_date > a.thru_date);

-- name: 4.15 — Data-quality check: agreement prices for a product their program's applicability leaves out (should be empty)
select pc.price_component_id, i.agreement_id, i.agreement_item_seq_id as item, i.agreement_text as program,
       pr.name as priced_product, pc.comment
from price_component pc
join agreement_item i on i.agreement_item_id = pc.agreement_item_id
join product pr       on pr.product_id = pc.product_id
where exists (select 1 from agreement_product_applicability x where x.agreement_item_id = i.agreement_item_id)
  and not exists (select 1 from agreement_product_applicability x
                  where x.agreement_item_id = i.agreement_item_id and x.product_id = pc.product_id);

-- ============================================================
-- Fig 4.16 — Relationship of agreement to order
-- ============================================================

-- name: 4.16 — The agreement items governing each sales order line (the view), with what they bring: terms in force, and prices
select o.order_id, oi.order_item_seq_id as line, o.order_date, pr.name as product, ship.display_name as ship_to,
       v.agreement_id || '/' || i.agreement_item_seq_id || ' ' || i.agreement_text as agreement_item,
       i.agreement_item_type_id as type,
       (select string_agg(t.description || coalesce(' ' || tm.term_value, ''), '; ' order by t.description)
          from agreement_term tm join term_type t on t.term_type_id = tm.term_type_id
         where tm.agreement_item_id = i.agreement_item_id
           and tm.from_date <= o.order_date and (tm.thru_date is null or tm.thru_date > o.order_date)) as item_terms,
       (select string_agg(t.description || coalesce(' ' || tm.term_value, ''), '; ' order by t.description)
          from agreement_term tm join term_type t on t.term_type_id = tm.term_type_id
         where tm.agreement_id = v.agreement_id
           and tm.from_date <= o.order_date and (tm.thru_date is null or tm.thru_date > o.order_date)) as agreement_terms,
       (select count(*) from price_component pc where pc.agreement_item_id = i.agreement_item_id) as prices
from order_item_agreement_item v
join order_item oi                            on oi.order_item_id = v.order_item_id
join "order" o                                on o.order_id = oi.order_id
join product pr                               on pr.product_id = oi.product_id
join agreement_item i                         on i.agreement_item_id = v.agreement_item_id
left join sales_order_item soi                on soi.order_item_id = oi.order_item_id
left join contact_mechanism_display_name ship on ship.contact_mechanism_id = soi.ship_to_contact_mechanism_id
where exists (select 1 from agreement_term tm where tm.agreement_item_id = i.agreement_item_id)
   or exists (select 1 from agreement_pricing_program p where p.agreement_item_id = i.agreement_item_id)
order by o.order_date, o.order_id, oi.order_item_seq_id, v.agreement_id, i.agreement_item_seq_id;

-- name: 4.16 — Each line a pricing program governs: its agreement price against the price charged
-- Ch 3's rule on the programs' components: the most specific applicable base
-- price (then the lowest), less discounts, plus surcharges, per unit.
-- Components with conditions this query can't answer (party type, category,
-- order value, sale type) are left out; ours use none.
with line as (
  select oi.order_item_id, oi.order_id, oi.order_item_seq_id, o.order_date, oi.product_id, oi.quantity, oi.unit_price,
         soi.ship_to_contact_mechanism_id
  from order_item oi
  join "order" o                 on o.order_id = oi.order_id
  left join sales_order_item soi on soi.order_item_id = oi.order_item_id
),
applicable as (
  select l.order_item_id, pc.price_component_id, pc.price_component_type_id, pc.price, pc.percent,
         pc.geographic_boundary_id, pc.quantity_break_id
  from line l
  join order_item_agreement_item v on v.order_item_id = l.order_item_id
  join price_component pc          on pc.agreement_item_id = v.agreement_item_id
  where pc.from_date <= l.order_date and (pc.thru_date is null or pc.thru_date > l.order_date)
    and (pc.product_id is null or pc.product_id = l.product_id)
    and pc.product_feature_id is null
    and num_nonnulls(pc.party_type_id, pc.product_category_id, pc.order_value_id, pc.sale_type_id) = 0
    and (pc.geographic_boundary_id is null or pc.geographic_boundary_id in (
          select ga.ancestor_id
          from postal_address_boundary pb
          join geographic_boundary_ancestor ga on ga.geographic_boundary_id = pb.geographic_boundary_id
          where pb.contact_mechanism_id = l.ship_to_contact_mechanism_id))
    and (pc.quantity_break_id is null or exists (
          select 1 from quantity_break q
          where q.quantity_break_id = pc.quantity_break_id
            and q.from_quantity <= l.quantity and (q.thru_quantity is null or q.thru_quantity > l.quantity)))
),
base as (
  select distinct on (order_item_id) order_item_id, price
  from applicable
  where price_component_type_id = 'BASE_PRICE'
  order by order_item_id, num_nonnulls(geographic_boundary_id, quantity_break_id) desc, price
),
agreed as (
  select b.order_item_id,
         b.price
         - coalesce(sum(coalesce(a.price, round(b.price * a.percent / 100, 2))) filter (where a.price_component_type_id = 'DISCOUNT'), 0)
         + coalesce(sum(coalesce(a.price, round(b.price * a.percent / 100, 2))) filter (where a.price_component_type_id = 'SURCHARGE'), 0)
           as agreement_price
  from base b
  left join applicable a on a.order_item_id = b.order_item_id and a.price_component_type_id in ('DISCOUNT', 'SURCHARGE')
  group by b.order_item_id, b.price
)
select l.order_id, l.order_item_seq_id as line, l.order_date, pr.name as product, l.quantity,
       l.unit_price as charged, g.agreement_price,
       case when l.unit_price = g.agreement_price then 'as agreed' else 'differs' end as note
from agreed g
join line l     on l.order_item_id = g.order_item_id
join product pr on pr.product_id = l.product_id
order by l.order_date, l.order_id, l.order_item_seq_id;

-- name: 4.16 — Thresholds: how much of each cap the lines it governs have used, within the term's dates
-- A term on one item counts the lines that item governs; a term on the whole
-- agreement would count every line any of its items governs, once.
with gov as (
  select tm.agreement_term_id, coalesce(tm.agreement_id, i.agreement_id) as agreement_id, i.agreement_item_seq_id,
         t.description as term, tm.term_value, tm.from_date, tm.thru_date,
         case tm.term_type_id when 'QUANTITY_NOT_TO_EXCEED' then oi.quantity
                              when 'DOLLARS_NOT_TO_EXCEED'  then oi.quantity * oi.unit_price end as used
  from agreement_term tm
  join term_type t           on t.term_type_id = tm.term_type_id and t.parent_type_id = 'THRESHOLD'
  left join agreement_item i on i.agreement_item_id = tm.agreement_item_id
  join lateral (select distinct v.order_item_id
                from order_item_agreement_item v
                where v.agreement_item_id = tm.agreement_item_id or v.agreement_id = tm.agreement_id) g on true
  join order_item oi on oi.order_item_id = g.order_item_id
  join "order" o     on o.order_id = oi.order_id
  where o.order_date >= tm.from_date and (tm.thru_date is null or o.order_date < tm.thru_date)
)
select agreement_id, agreement_item_seq_id as item, term, term_value as cap,
       from_date, thru_date - 1 as last_day, count(*) as lines, sum(used) as used, term_value - sum(used) as left_over
from gov
group by agreement_term_id, agreement_id, agreement_item_seq_id, term, term_value, from_date, thru_date
order by agreement_id, item, term;

-- name: 4.16 — Data-quality check: governed lines charged other than their agreement price (should be empty)
with line as (
  select oi.order_item_id, oi.order_id, oi.order_item_seq_id, o.order_date, oi.product_id, oi.quantity, oi.unit_price,
         soi.ship_to_contact_mechanism_id
  from order_item oi
  join "order" o                 on o.order_id = oi.order_id
  left join sales_order_item soi on soi.order_item_id = oi.order_item_id
),
applicable as (
  select l.order_item_id, pc.price_component_id, pc.price_component_type_id, pc.price, pc.percent,
         pc.geographic_boundary_id, pc.quantity_break_id
  from line l
  join order_item_agreement_item v on v.order_item_id = l.order_item_id
  join price_component pc          on pc.agreement_item_id = v.agreement_item_id
  where pc.from_date <= l.order_date and (pc.thru_date is null or pc.thru_date > l.order_date)
    and (pc.product_id is null or pc.product_id = l.product_id)
    and pc.product_feature_id is null
    and num_nonnulls(pc.party_type_id, pc.product_category_id, pc.order_value_id, pc.sale_type_id) = 0
    and (pc.geographic_boundary_id is null or pc.geographic_boundary_id in (
          select ga.ancestor_id
          from postal_address_boundary pb
          join geographic_boundary_ancestor ga on ga.geographic_boundary_id = pb.geographic_boundary_id
          where pb.contact_mechanism_id = l.ship_to_contact_mechanism_id))
    and (pc.quantity_break_id is null or exists (
          select 1 from quantity_break q
          where q.quantity_break_id = pc.quantity_break_id
            and q.from_quantity <= l.quantity and (q.thru_quantity is null or q.thru_quantity > l.quantity)))
),
base as (
  select distinct on (order_item_id) order_item_id, price
  from applicable
  where price_component_type_id = 'BASE_PRICE'
  order by order_item_id, num_nonnulls(geographic_boundary_id, quantity_break_id) desc, price
),
agreed as (
  select b.order_item_id,
         b.price
         - coalesce(sum(coalesce(a.price, round(b.price * a.percent / 100, 2))) filter (where a.price_component_type_id = 'DISCOUNT'), 0)
         + coalesce(sum(coalesce(a.price, round(b.price * a.percent / 100, 2))) filter (where a.price_component_type_id = 'SURCHARGE'), 0)
           as agreement_price
  from base b
  left join applicable a on a.order_item_id = b.order_item_id and a.price_component_type_id in ('DISCOUNT', 'SURCHARGE')
  group by b.order_item_id, b.price
)
select l.order_id, l.order_item_seq_id as line, l.order_date, pr.name as product,
       l.unit_price as charged, g.agreement_price
from agreed g
join line l     on l.order_item_id = g.order_item_id
join product pr on pr.product_id = l.product_id
where l.unit_price <> g.agreement_price
order by l.order_date, l.order_id, l.order_item_seq_id;

-- name: 4.16 — Data-quality check: lines that take a threshold past its cap, by running total over the term's dates (should be empty)
with gov as (
  select tm.agreement_term_id, coalesce(tm.agreement_id, i.agreement_id) as agreement_id, i.agreement_item_seq_id,
         t.description as term, tm.term_value, o.order_id, oi.order_item_seq_id, o.order_date,
         case tm.term_type_id when 'QUANTITY_NOT_TO_EXCEED' then oi.quantity
                              when 'DOLLARS_NOT_TO_EXCEED'  then oi.quantity * oi.unit_price end as used
  from agreement_term tm
  join term_type t           on t.term_type_id = tm.term_type_id and t.parent_type_id = 'THRESHOLD'
  left join agreement_item i on i.agreement_item_id = tm.agreement_item_id
  join lateral (select distinct v.order_item_id
                from order_item_agreement_item v
                where v.agreement_item_id = tm.agreement_item_id or v.agreement_id = tm.agreement_id) g on true
  join order_item oi on oi.order_item_id = g.order_item_id
  join "order" o     on o.order_id = oi.order_id
  where o.order_date >= tm.from_date and (tm.thru_date is null or o.order_date < tm.thru_date)
),
run as (
  select g.*, sum(used) over (partition by agreement_term_id order by order_date, order_id, order_item_seq_id) as running
  from gov g
)
select agreement_id, agreement_item_seq_id as item, term, term_value as cap,
       order_id, order_item_seq_id as line, order_date, used, running
from run
where running > term_value
order by agreement_id, item, term, order_date;
