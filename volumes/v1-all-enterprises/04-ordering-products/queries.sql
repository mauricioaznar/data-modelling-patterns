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
