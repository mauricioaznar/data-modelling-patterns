-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/05

-- ============================================================
-- Fig 5.1 — Shipment definition
-- ============================================================

-- name: 5.1 — Shipments as Table 5.1 shows them: type, estimated dates, and who and where at each end
select s.shipment_id, t.description as shipment_type, s.estimated_ship_date, s.estimated_arrival_date,
       tn.name as shipped_to, ta.display_name as to_address,
       fn.name as shipped_from, fa.display_name as from_address
from shipment s
join shipment_type t                         on t.shipment_type_id = s.shipment_type_id
join party_display_name tn                   on tn.party_id = s.shipped_to_party_id
join party_display_name fn                   on fn.party_id = s.shipped_from_party_id
left join contact_mechanism_display_name ta  on ta.contact_mechanism_id = s.shipped_to_contact_mechanism_id
left join contact_mechanism_display_name fa  on fa.contact_mechanism_id = s.shipped_from_contact_mechanism_id
where s.shipment_id in (9000, 9200, 9400, 1146, 1149, 1578, 3485, 4800)
order by array_position(array[9000, 9200, 9400, 1146, 1149, 1578, 3485, 4800], s.shipment_id);

-- name: 5.1 — Which way each shipment goes, worked out from whose organizations sit at each end, beside its recorded type
select s.shipment_id, t.description as recorded_type, coalesce(g.description, t.description) as type_group,
       case when e.from_internal and not e.to_internal then 'ours → theirs (outgoing)'
            when not e.from_internal and e.to_internal then 'theirs → ours (incoming)'
            when e.from_internal and e.to_internal     then 'ours → ours (transfer)'
            else 'theirs → theirs (drop ship)' end as worked_out_from_the_parties
from shipment s
join shipment_end e           on e.shipment_id = s.shipment_id
join shipment_type t          on t.shipment_type_id = s.shipment_type_id
left join shipment_type g     on g.shipment_type_id = t.parent_type_id
order by s.estimated_ship_date, s.shipment_id;

-- name: 5.1 — Everything ABC Subsidiary sent or received, every direction from one table
select s.shipment_id, t.description as shipment_type, s.estimated_ship_date,
       case when s.shipped_from_party_id = 13 then 'sent to' else 'received from' end as abc_subsidiary,
       o.name as other_party
from shipment s
join shipment_type t        on t.shipment_type_id = s.shipment_type_id
join party_display_name o   on o.party_id = case when s.shipped_from_party_id = 13 then s.shipped_to_party_id
                                                 else s.shipped_from_party_id end
where 13 in (s.shipped_from_party_id, s.shipped_to_party_id)
order by s.estimated_ship_date;

-- name: 5.1 — Shipments per type, rolled up to the type's group (outgoing, incoming, transfer, drop ship)
select coalesce(g.description, t.description) as type_group, t.description as shipment_type, count(*) as shipments
from shipment s
join shipment_type t        on t.shipment_type_id = s.shipment_type_id
left join shipment_type g   on g.shipment_type_id = t.parent_type_id
group by rollup (coalesce(g.description, t.description), t.description)
order by 1 nulls last, 2 nulls first;

-- name: 5.1 — Whom to ask about a shipment, and whom to call at the receiving end
select s.shipment_id, r.name as receiver, i.display_name as inquire_via, ct.description as inquiry_kind,
       n.display_name as receiving_number
from shipment s
join party_display_name r                    on r.party_id = s.shipped_to_party_id
left join contact_mechanism cm               on cm.contact_mechanism_id = s.inquiry_contact_mechanism_id
left join contact_mechanism_type ct          on ct.contact_mechanism_type_id = cm.contact_mechanism_type_id
left join contact_mechanism_display_name i   on i.contact_mechanism_id = s.inquiry_contact_mechanism_id
left join contact_mechanism_display_name n   on n.contact_mechanism_id = s.receiving_contact_mechanism_id
where s.inquiry_contact_mechanism_id is not null or s.receiving_contact_mechanism_id is not null
order by s.shipment_id;

-- name: 5.1 — Data-quality check: shipments typed with a grouping row instead of a type of shipment (should be empty)
select s.shipment_id, s.shipment_type_id
from shipment s
where exists (select 1 from shipment_type c where c.parent_type_id = s.shipment_type_id);

-- name: 5.1 — Data-quality check: shipments whose type says one thing about which ends are ours and the parties another (should be empty)
select s.shipment_id, t.description as shipment_type,
       t.from_internal as type_says_from_ours, e.from_internal as from_is_ours,
       t.to_internal   as type_says_to_ours,   e.to_internal   as to_is_ours
from shipment s
join shipment_type t   on t.shipment_type_id = s.shipment_type_id
join shipment_end e    on e.shipment_id = s.shipment_id
where t.from_internal is not null   -- grouping rows are the check above's
  and (t.from_internal <> e.from_internal or t.to_internal <> e.to_internal);

-- name: 5.1 — Data-quality check: shipments from or to an address the party didn't have on file on the estimated ship date (should be empty)
select s.shipment_id, x.end_name, n.name as party, a.display_name as address
from shipment s
cross join lateral (values ('from', s.shipped_from_party_id, s.shipped_from_contact_mechanism_id),
                           ('to',   s.shipped_to_party_id,   s.shipped_to_contact_mechanism_id)) as x(end_name, party_id, contact_mechanism_id)
join party_display_name n               on n.party_id = x.party_id
join contact_mechanism_display_name a   on a.contact_mechanism_id = x.contact_mechanism_id
where not exists (select 1 from party_contact_mechanism pcm
                  where pcm.party_id = x.party_id
                    and pcm.contact_mechanism_id = x.contact_mechanism_id
                    and pcm.from_date <= s.estimated_ship_date
                    and (pcm.thru_date is null or pcm.thru_date > s.estimated_ship_date));

-- name: 5.1 — Data-quality check: plans out of order: ready after the ship date, arriving before it, or cancellable after it (should be empty)
select shipment_id, estimated_ready_date, estimated_ship_date, estimated_arrival_date, latest_cancel_date
from shipment
where estimated_ready_date > estimated_ship_date
   or estimated_arrival_date < estimated_ship_date
   or latest_cancel_date > estimated_ship_date;

-- ============================================================
-- Fig 5.2 — Shipping detail
-- ============================================================

-- name: 5.2 — Shipment 9000's items, as Table 5.2 shows them
select si.shipment_id, si.shipment_item_seq_id as item, si.quantity, p.name as good
from shipment_item si
join product p on p.product_id = si.product_id
where si.shipment_id = 9000
order by si.shipment_item_seq_id;

-- name: 5.2 — The status history of shipments 9000 and 4800, as Table 5.3 shows it
select s.shipment_id, t.description as status, s.status_datetime::date as status_date
from shipment_status s
join status_type t on t.status_type_id = s.status_type_id
where s.shipment_id in (9000, 4800)
order by s.shipment_id = 4800, s.status_datetime;

-- name: 5.2 — Where each shipment stands now: its latest status, or none recorded
select sh.shipment_id, st.description as shipment_type,
       coalesce(t.description, '(none recorded)') as current_status, l.status_datetime as since
from shipment sh
join shipment_type st        on st.shipment_type_id = sh.shipment_type_id
left join lateral (
  select x.status_type_id, x.status_datetime
  from shipment_status x
  where x.shipment_id = sh.shipment_id
  order by x.status_datetime desc
  limit 1
) l on true
left join status_type t      on t.status_type_id = l.status_type_id
order by sh.shipment_id;

-- name: 5.2 — Planned against actual: did each shipment leave and arrive when its header said it would?
-- The plan is on the header, the facts in the history; arriving means
-- delivered or received, whichever came first.
with actual as (
  select shipment_id,
         min(status_datetime) filter (where status_type_id = 'SHIPMENT_SHIPPED')                           as shipped_at,
         min(status_datetime) filter (where status_type_id in ('SHIPMENT_DELIVERED', 'SHIPMENT_RECEIVED')) as arrived_at,
         bool_or(status_type_id = 'SHIPMENT_CANCELLED')                                                   as cancelled
  from shipment_status
  group by shipment_id
)
select s.shipment_id, s.estimated_ship_date, a.shipped_at::date as shipped_on,
       a.shipped_at::date - s.estimated_ship_date as days_late_leaving,
       s.estimated_arrival_date, a.arrived_at::date as arrived_on,
       a.arrived_at::date - s.estimated_arrival_date as days_late_arriving,
       case when a.cancelled           then 'cancelled'
            when a.shipped_at is null  then 'not shipped yet'
            when a.arrived_at is null  then 'on its way'
            else 'arrived' end as outcome
from shipment s
join actual a on a.shipment_id = s.shipment_id
order by s.estimated_ship_date;

-- name: 5.2 — Returns and what they answer: each line sent in response to another, with both shipments
select r.shipment_id, rt.description as shipment_type, r.shipment_item_seq_id as line, p.name as good, r.quantity,
       o.shipment_id as answers_shipment, ot.description as answers_type, o.shipment_item_seq_id as answers_line,
       o.quantity as of_quantity
from shipment_item r
join shipment_item o         on o.shipment_item_id = r.in_response_to_shipment_item_id
join shipment rs             on rs.shipment_id = r.shipment_id
join shipment_type rt        on rt.shipment_type_id = rs.shipment_type_id
join shipment os             on os.shipment_id = o.shipment_id
join shipment_type ot        on ot.shipment_type_id = os.shipment_type_id
left join product p          on p.product_id = r.product_id
order by r.shipment_id, r.shipment_item_seq_id;

-- name: 5.2 — Data-quality check: two lines with the same line number on one shipment (should be empty)
select shipment_id, shipment_item_seq_id, count(*) as lines
from shipment_item
group by shipment_id, shipment_item_seq_id
having count(*) > 1;

-- name: 5.2 — Data-quality check: lines with neither a good nor a contents description (should be empty)
select shipment_item_id, shipment_id, shipment_item_seq_id, quantity
from shipment_item
where product_id is null and shipment_contents_description is null;

-- name: 5.2 — Data-quality check: shipment statuses that aren't shipment statuses (should be empty)
select s.shipment_status_id, s.shipment_id, s.status_type_id, t.parent_type_id
from shipment_status s
join status_type t on t.status_type_id = s.status_type_id
where t.parent_type_id is distinct from 'SHIPMENT_STATUS';

-- name: 5.2 — Data-quality check: one status type twice on a shipment, against the book's identifier (should be empty)
select shipment_id, status_type_id, count(*) as times,
       string_agg(status_datetime::text, ', ' order by status_datetime) as at
from shipment_status
group by shipment_id, status_type_id
having count(*) > 1;

-- name: 5.2 — Data-quality check: events out of order: a later step dated before an earlier one, or anything after a cancellation (should be empty)
with step as (
  select s.*, array_position(array['SHIPMENT_SCHEDULED', 'SHIPMENT_SHIPPED', 'SHIPMENT_IN_ROUTE',
                                   'SHIPMENT_DELIVERED', 'SHIPMENT_RECEIVED'], s.status_type_id) as n
  from shipment_status s
)
select a.shipment_id, a.status_type_id as earlier_step, a.status_datetime as dated,
       b.status_type_id as later_step, b.status_datetime as but_dated
from step a
join step b on b.shipment_id = a.shipment_id and b.n > a.n and b.status_datetime < a.status_datetime
union all
select c.shipment_id, c.status_type_id, c.status_datetime, x.status_type_id, x.status_datetime
from shipment_status c
join shipment_status x on x.shipment_id = c.shipment_id and x.status_datetime > c.status_datetime
where c.status_type_id = 'SHIPMENT_CANCELLED';

-- name: 5.2 — Data-quality check: lines answering a line of their own shipment (should be empty)
select r.shipment_item_id, r.shipment_id, r.shipment_item_seq_id as line, o.shipment_item_seq_id as answers_line
from shipment_item r
join shipment_item o on o.shipment_item_id = r.in_response_to_shipment_item_id
where o.shipment_id = r.shipment_id;

-- ============================================================
-- Fig 5.3 — Shipment-to-order relationship
-- ============================================================

-- name: 5.3 — Order lines against shipment lines, as Table 5.6 shows them
select oi.order_id, oi.order_item_seq_id as order_line, si.shipment_id, si.shipment_item_seq_id as shipment_line,
       os.quantity as quantity_shipped
from order_shipment os
join order_item oi     on oi.order_item_id = os.order_item_id
join shipment_item si  on si.shipment_item_id = os.shipment_item_id
where oi.order_id in (100, 200)
order by oi.order_id, oi.order_item_seq_id, si.shipment_id;

-- name: 5.3 — How each order line was filled: ordered, shipped, still to ship, and on which shipments
-- "Shipped in full" is a sum, not a status. Feature lines ship with their
-- product line, so they're left out.
select oi.order_id, o.order_kind, oi.order_item_seq_id as line, p.name as product, oi.quantity as ordered,
       coalesce(sum(os.quantity), 0) as shipped,
       oi.quantity - coalesce(sum(os.quantity), 0) as to_ship,
       string_agg(si.shipment_id || ' (' || os.quantity || ')', ', ' order by si.shipment_id) as shipments,
       case when coalesce(sum(os.quantity), 0) = 0 then 'not shipped'
            when sum(os.quantity) < oi.quantity    then 'partly shipped'
            when sum(os.quantity) = oi.quantity    then 'shipped in full'
            else 'shipped beyond the order: review' end as state
from order_item oi
join "order" o               on o.order_id = oi.order_id
join product p               on p.product_id = oi.product_id
left join order_shipment os  on os.order_item_id = oi.order_item_id
left join shipment_item si   on si.shipment_item_id = os.shipment_item_id
where oi.order_id in (100, 200, 300, 400)
group by oi.order_item_id, oi.order_id, o.order_kind, oi.order_item_seq_id, p.name, oi.quantity
order by oi.order_id, oi.order_item_seq_id;

-- name: 5.3 — Shipment lines that fill lines of more than one order (one line of pens, two orders)
select si.shipment_id, si.shipment_item_seq_id as line, p.name as good, si.quantity,
       count(distinct oi.order_id) as orders,
       string_agg('order ' || oi.order_id || ' line ' || oi.order_item_seq_id || ' (' || os.quantity || ')', ', '
                  order by oi.order_id) as order_lines
from shipment_item si
join order_shipment os  on os.shipment_item_id = si.shipment_item_id
join order_item oi      on oi.order_item_id = os.order_item_id
join product p          on p.product_id = si.product_id
group by si.shipment_item_id, si.shipment_id, si.shipment_item_seq_id, p.name, si.quantity
having count(distinct oi.order_id) > 1;

-- name: 5.3 — Which orders each shipment fills, worked out through its lines (no line joins an order to a shipment)
select sh.shipment_id, st.description as shipment_type,
       string_agg(distinct oi.order_id::text, ', ' order by oi.order_id::text) as orders
from shipment sh
join shipment_type st   on st.shipment_type_id = sh.shipment_type_id
join shipment_item si   on si.shipment_id = sh.shipment_id
join order_shipment os  on os.shipment_item_id = si.shipment_item_id
join order_item oi      on oi.order_item_id = os.order_item_id
group by sh.shipment_id, st.description
order by sh.shipment_id;

-- name: 5.3 — For review: shipment lines no order line accounts for in full (returns and transfers fill no order; 9200's line 3 is Table 5.5's own)
select si.shipment_id, st.description as shipment_type, si.shipment_item_seq_id as line,
       coalesce(p.name, si.shipment_contents_description) as contents, si.quantity,
       coalesce(sum(os.quantity), 0) as claimed_by_orders,
       case when sh.shipment_type_id in ('CUSTOMER_RETURN', 'PURCHASE_RETURN', 'TRANSFER') then 'no order expected'
            else 'review' end as note
from shipment_item si
join shipment sh             on sh.shipment_id = si.shipment_id
join shipment_type st        on st.shipment_type_id = sh.shipment_type_id
left join product p          on p.product_id = si.product_id
left join order_shipment os  on os.shipment_item_id = si.shipment_item_id
group by si.shipment_item_id, si.shipment_id, st.description, sh.shipment_type_id, si.shipment_item_seq_id,
         p.name, si.shipment_contents_description, si.quantity
having coalesce(sum(os.quantity), 0) < si.quantity
order by si.shipment_id, si.shipment_item_seq_id;

-- name: 5.3 — Ordered features against shipped features, as Table 5.7 shows them (blue ordered, black shipped)
-- What was ordered: the feature lines under the order line (Ch 4). What went
-- out: the shipment line's features. ORDER SHIPMENT sets them side by side.
with ordered as (
  select f.ordered_for_order_item_id as order_item_id,
         string_agg(t.description || ' ' || lower(pf.description), ', ' order by pf.description) as features
  from order_item f
  join product_feature pf       on pf.product_feature_id = f.product_feature_id
  join product_feature_type t   on t.product_feature_type_id = pf.product_feature_type_id
  where f.ordered_for_order_item_id is not null
  group by f.ordered_for_order_item_id
),
shipped as (
  select sf.shipment_item_id,
         string_agg(distinct t.description || ' ' || lower(pf.description), ', ') as features
  from shipment_item_feature sf
  join product_feature pf       on pf.product_feature_id = sf.product_feature_id
  join product_feature_type t   on t.product_feature_type_id = pf.product_feature_type_id
  group by sf.shipment_item_id
)
select oi.order_id, oi.order_item_seq_id as order_line, o.features as ordered_features, oi.quantity,
       si.shipment_id, si.shipment_item_seq_id as shipment_line, si.quantity as quantity_shipped,
       s.features as shipped_features,
       case when o.features is not distinct from s.features then 'as ordered' else 'differs' end as outcome
from order_shipment os
join order_item oi       on oi.order_item_id = os.order_item_id
join shipment_item si    on si.shipment_item_id = os.shipment_item_id
left join ordered o      on o.order_item_id = oi.order_item_id
left join shipped s      on s.shipment_item_id = si.shipment_item_id
where o.features is not null or s.features is not null
order by oi.order_id, oi.order_item_seq_id;

-- name: 5.3 — Data-quality check: the same pair twice, in order_shipment or shipment_item_feature (should be empty)
select 'order_shipment' as table_name, order_item_id as first_id, shipment_item_id as second_id, count(*) as times
from order_shipment
group by order_item_id, shipment_item_id
having count(*) > 1
union all
select 'shipment_item_feature', shipment_item_id, product_feature_id, count(*)
from shipment_item_feature
group by shipment_item_id, product_feature_id
having count(*) > 1;

-- name: 5.3 — Data-quality check: order lines filled by a shipment line of another good (should be empty)
-- A feature line's product is its product line's.
select os.order_shipment_id, oi.order_id, oi.order_item_seq_id as order_line, op.name as ordered,
       si.shipment_id, si.shipment_item_seq_id as shipment_line, sp.name as shipped
from order_shipment os
join order_item oi           on oi.order_item_id = os.order_item_id
left join order_item parent  on parent.order_item_id = oi.ordered_for_order_item_id
join shipment_item si        on si.shipment_item_id = os.shipment_item_id
left join product op         on op.product_id = coalesce(oi.product_id, parent.product_id)
left join product sp         on sp.product_id = si.product_id
where coalesce(oi.product_id, parent.product_id) is distinct from si.product_id;

-- name: 5.3 — Data-quality check: shipment lines drawn on by orders for more than they carry (should be empty)
select si.shipment_id, si.shipment_item_seq_id as line, si.quantity as carries, sum(os.quantity) as drawn_by_orders
from shipment_item si
join order_shipment os on os.shipment_item_id = si.shipment_item_id
group by si.shipment_item_id, si.shipment_id, si.shipment_item_seq_id, si.quantity
having sum(os.quantity) > si.quantity;

-- name: 5.3 — Data-quality check: order lines filled by the wrong kind of shipment: sales on customer shipments, purchases on purchase shipments, either on a drop ship (should be empty)
select os.order_shipment_id, o.order_id, o.order_kind, si.shipment_id, st.description as shipment_type
from order_shipment os
join order_item oi      on oi.order_item_id = os.order_item_id
join "order" o          on o.order_id = oi.order_id
join shipment_item si   on si.shipment_item_id = os.shipment_item_id
join shipment sh        on sh.shipment_id = si.shipment_id
join shipment_type st   on st.shipment_type_id = sh.shipment_type_id
where not ((o.order_kind = 'SALES'    and sh.shipment_type_id in ('CUSTOMER_SHIPMENT', 'DROP_SHIPMENT'))
        or (o.order_kind = 'PURCHASE' and sh.shipment_type_id in ('PURCHASE_SHIPMENT', 'DROP_SHIPMENT')));

-- name: 5.3 — Data-quality check: order lines filled by a shipment bound for somewhere else than the line's ship-to (should be empty)
-- The line's ship-to: 4.3's or 4.4's column, a feature line falling back to
-- its product line, or 4.5's generic SHIPPING row.
with line_ship_to as (
  select oi.order_item_id,
         coalesce(s.ship_to_contact_mechanism_id, ps.ship_to_contact_mechanism_id,
                  p.ship_to_contact_mechanism_id, pp.ship_to_contact_mechanism_id,
                  (select min(g.contact_mechanism_id)
                   from order_item_contact_mechanism g
                   where g.order_item_id in (oi.order_item_id, oi.ordered_for_order_item_id)
                     and g.contact_mechanism_purpose_type_id = 'SHIPPING')) as contact_mechanism_id
  from order_item oi
  left join sales_order_item s      on s.order_item_id = oi.order_item_id
  left join sales_order_item ps     on ps.order_item_id = oi.ordered_for_order_item_id
  left join purchase_order_item p   on p.order_item_id = oi.order_item_id
  left join purchase_order_item pp  on pp.order_item_id = oi.ordered_for_order_item_id
)
select os.order_shipment_id, oi.order_id, oi.order_item_seq_id as order_line, la.display_name as line_ships_to,
       sh.shipment_id, sa.display_name as shipment_goes_to
from order_shipment os
join order_item oi                          on oi.order_item_id = os.order_item_id
join line_ship_to l                         on l.order_item_id = oi.order_item_id
join shipment_item si                       on si.shipment_item_id = os.shipment_item_id
join shipment sh                            on sh.shipment_id = si.shipment_id
join contact_mechanism_display_name la      on la.contact_mechanism_id = l.contact_mechanism_id
join contact_mechanism_display_name sa      on sa.contact_mechanism_id = sh.shipped_to_contact_mechanism_id
where l.contact_mechanism_id <> sh.shipped_to_contact_mechanism_id;

-- ============================================================
-- Fig 5.4 — Shipment receipt for incoming shipments
-- ============================================================

-- name: 5.4 — Shipment receipts as Table 5.8 shows them: each line, its packages and each package's receipt
-- A receipt is within a package and of a good; the package's content of that
-- good says which shipment line it counts.
select si.shipment_id, st.description as shipment_type, si.shipment_item_seq_id as line, si.quantity,
       p.name as product, pc.quantity as packaging_content_quantity, pc.shipment_package_id as package,
       r.shipment_receipt_id as receipt, r.quantity_accepted
from shipment_receipt r
join packaging_content pc  on pc.shipment_package_id = r.shipment_package_id
join shipment_item si      on si.shipment_item_id = pc.shipment_item_id and si.product_id = r.product_id
join shipment sh           on sh.shipment_id = si.shipment_id
join shipment_type st      on st.shipment_type_id = sh.shipment_type_id
join product p             on p.product_id = si.product_id
where r.shipment_receipt_id in (12900, 12901, 12902, 13902, 13903, 13904, 13905, 13804)
  and si.shipment_id in (1146, 1149, 3485)
order by array_position(array[1146, 1149, 3485], si.shipment_id), si.shipment_item_seq_id, pc.shipment_package_id;

-- name: 5.4 — What each package holds, and the shipment it belongs to, worked out from its contents
select pk.shipment_package_id as package, pk.date_created, si.shipment_id, si.shipment_item_seq_id as line,
       coalesce(p.name, si.shipment_contents_description) as contents, pc.quantity
from shipment_package pk
join packaging_content pc  on pc.shipment_package_id = pk.shipment_package_id
join shipment_item si      on si.shipment_item_id = pc.shipment_item_id
left join product p        on p.product_id = si.product_id
order by pk.shipment_package_id, si.shipment_id, si.shipment_item_seq_id;

-- name: 5.4 — Each incoming shipment line: shipped, packed, accepted, rejected, and not yet counted
-- Incoming: the shipment's type ends at one of ours (purchase shipments,
-- customer returns, transfers).
with packed as (
  select shipment_item_id, sum(quantity) as packed
  from packaging_content
  group by shipment_item_id
),
counted as (
  select pc.shipment_item_id, sum(r.quantity_accepted) as accepted, sum(r.quantity_rejected) as rejected
  from shipment_receipt r
  join packaging_content pc  on pc.shipment_package_id = r.shipment_package_id
  join shipment_item si      on si.shipment_item_id = pc.shipment_item_id and si.product_id = r.product_id
  group by pc.shipment_item_id
)
select si.shipment_id, st.description as shipment_type, si.shipment_item_seq_id as line,
       coalesce(p.name, si.shipment_contents_description) as contents, si.quantity as shipped,
       coalesce(k.packed, 0) as packed, coalesce(c.accepted, 0) as accepted, coalesce(c.rejected, 0) as rejected,
       si.quantity - coalesce(c.accepted, 0) - coalesce(c.rejected, 0) as not_yet_counted
from shipment_item si
join shipment sh        on sh.shipment_id = si.shipment_id
join shipment_type st   on st.shipment_type_id = sh.shipment_type_id
left join product p     on p.product_id = si.product_id
left join packed k      on k.shipment_item_id = si.shipment_item_id
left join counted c     on c.shipment_item_id = si.shipment_item_id
where st.to_internal
order by si.shipment_id, si.shipment_item_seq_id;

-- name: 5.4 — Each purchase order line: ordered, shipped to us, and accepted or rejected by the receipts checked against it
select oi.order_id, oi.order_item_seq_id as line, p.name as product, oi.quantity as ordered,
       (select coalesce(sum(os.quantity), 0) from order_shipment os where os.order_item_id = oi.order_item_id)        as shipped,
       (select coalesce(sum(r.quantity_accepted), 0) from shipment_receipt r where r.order_item_id = oi.order_item_id) as accepted,
       (select coalesce(sum(r.quantity_rejected), 0) from shipment_receipt r where r.order_item_id = oi.order_item_id) as rejected
from order_item oi
join "order" o    on o.order_id = oi.order_id
join product p    on p.product_id = oi.product_id
where o.order_kind = 'PURCHASE'
  and exists (select 1 from order_shipment os where os.order_item_id = oi.order_item_id)
order by oi.order_id, oi.order_item_seq_id;

-- name: 5.4 — What was rejected and why, and who received and inspected it
select r.shipment_receipt_id as receipt, s.shipment_id, p.name as good, r.quantity_accepted, r.quantity_rejected,
       coalesce(rr.description, '(no reason given)') as reason,
       string_agg(t.description || ': ' || n.name, '; ' order by t.description) as people
from shipment_receipt r
left join lateral (select min(x.shipment_id) as shipment_id
                   from shipment_package_shipment x
                   where x.shipment_package_id = r.shipment_package_id) s on true
left join product p                      on p.product_id = r.product_id
left join rejection_reason rr            on rr.rejection_reason_id = r.rejection_reason_id
left join shipment_receipt_role ro       on ro.shipment_receipt_id = r.shipment_receipt_id
left join shipment_receipt_role_type t   on t.shipment_receipt_role_type_id = ro.shipment_receipt_role_type_id
left join party_display_name n           on n.party_id = ro.party_id
where r.quantity_rejected > 0
group by r.shipment_receipt_id, s.shipment_id, p.name, r.quantity_accepted, r.quantity_rejected, rr.description
order by r.shipment_receipt_id;

-- name: 5.4 — Where received goods went: accepted quantities by inventory item and facility, beside its quantity on hand
select ii.inventory_item_id, p.name as good, f.description as facility,
       sum(r.quantity_accepted) as accepted_into_it, ii.quantity_on_hand
from shipment_receipt r
join inventory_item ii  on ii.inventory_item_id = r.inventory_item_id
join product p          on p.product_id = ii.product_id
join facility f         on f.facility_id = ii.facility_id
group by ii.inventory_item_id, p.name, f.description, ii.quantity_on_hand
order by ii.inventory_item_id;

-- name: 5.4 — Data-quality check: packages holding lines of more than one shipment (should be empty)
select shipment_package_id as package, string_agg(shipment_id::text, ', ' order by shipment_id) as shipments
from shipment_package_shipment
group by shipment_package_id
having count(*) > 1;

-- name: 5.4 — Data-quality check: shipment lines packed for more than they carry (should be empty)
select si.shipment_id, si.shipment_item_seq_id as line, si.quantity as carries, sum(pc.quantity) as packed
from shipment_item si
join packaging_content pc on pc.shipment_item_id = si.shipment_item_id
group by si.shipment_item_id, si.shipment_id, si.shipment_item_seq_id, si.quantity
having sum(pc.quantity) > si.quantity;

-- name: 5.4 — Data-quality check: receipts of a good their package doesn't hold (should be empty)
select r.shipment_receipt_id as receipt, r.shipment_package_id as package, p.name as good
from shipment_receipt r
join product p on p.product_id = r.product_id
where not exists (select 1
                  from packaging_content pc
                  join shipment_item si on si.shipment_item_id = pc.shipment_item_id
                  where pc.shipment_package_id = r.shipment_package_id
                    and si.product_id = r.product_id);

-- name: 5.4 — Data-quality check: more of a good counted out of a package than it holds (should be empty)
with held as (
  select pc.shipment_package_id, si.product_id, sum(pc.quantity) as held
  from packaging_content pc
  join shipment_item si on si.shipment_item_id = pc.shipment_item_id
  group by pc.shipment_package_id, si.product_id
),
counted as (
  select shipment_package_id, product_id, sum(quantity_accepted + quantity_rejected) as counted,
         string_agg(shipment_receipt_id::text, ', ' order by shipment_receipt_id) as receipts
  from shipment_receipt
  group by shipment_package_id, product_id
)
select c.shipment_package_id as package, p.name as good, h.held, c.counted, c.receipts
from counted c
join held h      on h.shipment_package_id = c.shipment_package_id and h.product_id = c.product_id
join product p   on p.product_id = c.product_id
where c.counted > h.held;

-- name: 5.4 — Data-quality check: rejections with no reason, or a reason with nothing rejected (should be empty)
select shipment_receipt_id as receipt, quantity_rejected, rejection_reason_id
from shipment_receipt
where (quantity_rejected > 0) <> (rejection_reason_id is not null);

-- name: 5.4 — Data-quality check: receipts checked against an order line that ORDER SHIPMENT doesn't tie to their shipment line (should be empty)
-- The direct line to the order item against the long way round: package →
-- its content of the receipt's good → shipment line → order shipment.
select r.shipment_receipt_id as receipt, r.shipment_package_id as package, oi.order_id, oi.order_item_seq_id as order_line
from shipment_receipt r
join order_item oi on oi.order_item_id = r.order_item_id
where not exists (select 1
                  from packaging_content pc
                  join shipment_item si    on si.shipment_item_id = pc.shipment_item_id
                  join order_shipment os   on os.shipment_item_id = si.shipment_item_id
                  where pc.shipment_package_id = r.shipment_package_id
                    and si.product_id = r.product_id
                    and os.order_item_id = r.order_item_id);

-- name: 5.4 — Data-quality check: receipts counting a shipment line whose shipment doesn't end at one of ours (should be empty)
-- Fig 5.4 is for incoming shipments: the type's to_internal flag (5.1). The
-- line is the package's content of the receipt's good.
select r.shipment_receipt_id as receipt, sh.shipment_id, t.description as shipment_type
from shipment_receipt r
join packaging_content pc  on pc.shipment_package_id = r.shipment_package_id
join shipment_item si      on si.shipment_item_id = pc.shipment_item_id and si.product_id = r.product_id
join shipment sh           on sh.shipment_id = si.shipment_id
join shipment_type t       on t.shipment_type_id = sh.shipment_type_id
where t.to_internal is not true;

-- name: 5.4 — Data-quality check: the same row twice, in packaging_content or shipment_receipt_role (should be empty)
select 'packaging_content' as table_name, shipment_package_id || ' / line ' || shipment_item_id as pair, count(*) as times
from packaging_content
group by shipment_package_id, shipment_item_id
having count(*) > 1
union all
select 'shipment_receipt_role', shipment_receipt_id || ' / ' || party_id || ' / ' || shipment_receipt_role_type_id, count(*)
from shipment_receipt_role
group by shipment_receipt_id, party_id, shipment_receipt_role_type_id
having count(*) > 1;

-- ============================================================
-- Fig 5.5 — Item issuance for outgoing shipments
-- ============================================================

-- name: 5.5 — Item issuances as Table 5.9 shows them: each line, its packages and the issuances that pulled it
-- Packages and issuances meet only at the shipment line (NOTES, point 27),
-- so each gets its own column rather than a pairing the model can't hold.
select si.shipment_id, si.shipment_item_seq_id as line, si.quantity, p.name as product,
       (select string_agg(pc.shipment_package_id || ': ' || pc.quantity, ', ' order by pc.shipment_package_id)
        from packaging_content pc where pc.shipment_item_id = si.shipment_item_id) as packages,
       (select string_agg(ii.item_issuance_id || ': ' || ii.quantity, ', ' order by ii.item_issuance_id)
        from item_issuance ii where ii.shipment_item_id = si.shipment_item_id)      as issuances
from shipment_item si
join product p on p.product_id = si.product_id
where si.shipment_id in (9000, 9200)
order by si.shipment_id, si.shipment_item_seq_id;

-- name: 5.5 — Each outgoing shipment line: shipped, picked, issued and packed (the plan beside the facts)
-- Picked: the picklist items its issuances followed (each counted once).
-- Outgoing: the type's from_internal flag (5.1).
with issued as (
  select shipment_item_id, sum(quantity) as issued
  from item_issuance
  group by shipment_item_id
),
picked as (
  select x.shipment_item_id, sum(pi.quantity) as picked
  from (select distinct shipment_item_id, picklist_item_id from item_issuance where picklist_item_id is not null) x
  join picklist_item pi on pi.picklist_item_id = x.picklist_item_id
  group by x.shipment_item_id
),
packed as (
  select shipment_item_id, sum(quantity) as packed
  from packaging_content
  group by shipment_item_id
)
select si.shipment_id, st.description as shipment_type, si.shipment_item_seq_id as line,
       coalesce(p.name, si.shipment_contents_description) as contents, si.quantity as shipped,
       k.picked, coalesce(i.issued, 0) as issued, coalesce(c.packed, 0) as packed
from shipment_item si
join shipment sh        on sh.shipment_id = si.shipment_id
join shipment_type st   on st.shipment_type_id = sh.shipment_type_id
left join product p     on p.product_id = si.product_id
left join picked k      on k.shipment_item_id = si.shipment_item_id
left join issued i      on i.shipment_item_id = si.shipment_item_id
left join packed c      on c.shipment_item_id = si.shipment_item_id
where st.from_internal
order by si.shipment_id, si.shipment_item_seq_id;

-- name: 5.5 — Each picklist: what it said to pull and from where, what was pulled, and the shipments it served
-- A picklist has no shipment of its own: they come through its issuances.
select pl.picklist_id, pl.date_created, pi.picklist_item_id, pi.inventory_item_id as stock, g.name as good,
       pi.quantity as to_pick, coalesce(sum(ii.quantity), 0) as issued,
       string_agg(distinct si.shipment_id::text, ', ') as shipments
from picklist pl
join picklist_item pi      on pi.picklist_id = pl.picklist_id
join inventory_item inv    on inv.inventory_item_id = pi.inventory_item_id
join product g             on g.product_id = inv.product_id
left join item_issuance ii on ii.picklist_item_id = pi.picklist_item_id
left join shipment_item si on si.shipment_item_id = ii.shipment_item_id
group by pl.picklist_id, pl.date_created, pi.picklist_item_id, pi.inventory_item_id, g.name, pi.quantity
order by pl.picklist_id, pi.picklist_item_id;

-- name: 5.5 — The stock ledger: each inventory item's counts, receipts and issues, its balance and its quantity on hand
-- Ch 3's vocabulary: qoh is the stored cache, the balance the sum of the
-- movements from zero. Only items with a known starting point: a receipt,
-- an issuance or an opening count.
with moves as (
  select inventory_item_id, quantity as counted, 0 as received, 0 as issued from inventory_item_variance
  union all
  select inventory_item_id, 0, quantity_accepted, 0 from shipment_receipt where inventory_item_id is not null
  union all
  select inventory_item_id, 0, 0, quantity from item_issuance
)
select inv.inventory_item_id as stock, g.name as good,
       coalesce(f.description, cf.description || ', ' || c.description) as place,
       sum(m.counted) as counted, sum(m.received) as received, sum(m.issued) as issued,
       sum(m.counted + m.received - m.issued) as balance, inv.quantity_on_hand as qoh
from inventory_item inv
join moves m             on m.inventory_item_id = inv.inventory_item_id
join product g           on g.product_id = inv.product_id
left join facility f     on f.facility_id = inv.facility_id
left join container c    on c.container_id = inv.container_id
left join facility cf    on cf.facility_id = c.facility_id
where exists (select 1 from shipment_receipt r where r.inventory_item_id = inv.inventory_item_id)
   or exists (select 1 from item_issuance ii where ii.inventory_item_id = inv.inventory_item_id)
   or exists (select 1 from inventory_item_variance v where v.inventory_item_id = inv.inventory_item_id and v.reason_id = 'OPENING_COUNT')
group by inv.inventory_item_id, g.name, f.description, cf.description, c.description, inv.quantity_on_hand
order by inv.inventory_item_id;

-- name: 5.5 — Who pulled and approved each issuance
select ii.item_issuance_id as issuance, si.shipment_id, ii.quantity,
       string_agg(t.description || ': ' || n.name, '; ' order by t.description) as people
from item_issuance ii
left join shipment_item si             on si.shipment_item_id = ii.shipment_item_id
left join item_issuance_role ro        on ro.item_issuance_id = ii.item_issuance_id
left join item_issuance_role_type t    on t.item_issuance_role_type_id = ro.item_issuance_role_type_id
left join party_display_name n         on n.party_id = ro.party_id
group by ii.item_issuance_id, si.shipment_id, ii.quantity
order by ii.item_issuance_id;

-- name: 5.5 — Data-quality check: issuances pulling a good other than their shipment line's (should be empty)
select ii.item_issuance_id as issuance, si.shipment_id, si.shipment_item_seq_id as line,
       lp.name as line_good, sp.name as stock_good
from item_issuance ii
join shipment_item si   on si.shipment_item_id = ii.shipment_item_id
join inventory_item inv on inv.inventory_item_id = ii.inventory_item_id
join product sp         on sp.product_id = inv.product_id
left join product lp    on lp.product_id = si.product_id
where si.product_id is distinct from inv.product_id;

-- name: 5.5 — Data-quality check: shipment lines issued for more than they carry (should be empty)
select si.shipment_id, si.shipment_item_seq_id as line, si.quantity as carries, sum(ii.quantity) as issued
from shipment_item si
join item_issuance ii on ii.shipment_item_id = si.shipment_item_id
group by si.shipment_item_id, si.shipment_id, si.shipment_item_seq_id, si.quantity
having sum(ii.quantity) > si.quantity;

-- name: 5.5 — Data-quality check: issuances drawing on other stock than their picklist item names (should be empty)
-- The direct line to the inventory item against the path through the
-- picklist item.
select ii.item_issuance_id as issuance, ii.inventory_item_id as issued_from, pi.inventory_item_id as picklist_says,
       pi.picklist_id
from item_issuance ii
join picklist_item pi on pi.picklist_item_id = ii.picklist_item_id
where pi.inventory_item_id <> ii.inventory_item_id;

-- name: 5.5 — Data-quality check: issuances for a shipment that doesn't leave one of ours (should be empty)
-- Fig 5.5 is for outgoing shipments: the type's from_internal flag (5.1).
select ii.item_issuance_id as issuance, sh.shipment_id, t.description as shipment_type
from item_issuance ii
join shipment_item si  on si.shipment_item_id = ii.shipment_item_id
join shipment sh       on sh.shipment_id = si.shipment_id
join shipment_type t   on t.shipment_type_id = sh.shipment_type_id
where t.from_internal is not true;

-- name: 5.5 — Data-quality check: outgoing issuances from stock away from the shipment's ship-from address (should be empty)
-- The stock's facility (or its container's) must have the address on file
-- on the issue date (Ch 2's facility_contact_mechanism).
select ii.item_issuance_id as issuance, sh.shipment_id, f.description as stock_at,
       sh.shipped_from_contact_mechanism_id as ships_from
from item_issuance ii
join shipment_item si   on si.shipment_item_id = ii.shipment_item_id
join shipment sh        on sh.shipment_id = si.shipment_id
join shipment_type t    on t.shipment_type_id = sh.shipment_type_id
join inventory_item inv on inv.inventory_item_id = ii.inventory_item_id
left join container c   on c.container_id = inv.container_id
join facility f         on f.facility_id = coalesce(inv.facility_id, c.facility_id)
where t.from_internal
  and not exists (select 1
                  from facility_contact_mechanism fcm
                  where fcm.facility_id = f.facility_id
                    and fcm.contact_mechanism_id = sh.shipped_from_contact_mechanism_id
                    and fcm.from_date <= ii.issued_datetime::date
                    and (fcm.thru_date is null or fcm.thru_date > ii.issued_datetime::date));

-- name: 5.5 — Data-quality check: quantity on hand that isn't the balance of the movements (should be empty)
-- Ch 3's qoh = balance, now that receipts and issuances exist: accepted −
-- issued + variances, from zero, for items with a receipt, an issuance or
-- an opening count.
with moves as (
  select inventory_item_id, quantity as delta from inventory_item_variance
  union all
  select inventory_item_id, quantity_accepted from shipment_receipt where inventory_item_id is not null
  union all
  select inventory_item_id, -quantity from item_issuance
)
select inv.inventory_item_id as stock, inv.quantity_on_hand as qoh, sum(m.delta) as balance
from inventory_item inv
join moves m on m.inventory_item_id = inv.inventory_item_id
where exists (select 1 from shipment_receipt r where r.inventory_item_id = inv.inventory_item_id)
   or exists (select 1 from item_issuance ii where ii.inventory_item_id = inv.inventory_item_id)
   or exists (select 1 from inventory_item_variance v where v.inventory_item_id = inv.inventory_item_id and v.reason_id = 'OPENING_COUNT')
group by inv.inventory_item_id, inv.quantity_on_hand
having inv.quantity_on_hand is distinct from sum(m.delta);

-- name: 5.5 — Data-quality check: the same row twice, in picklist_item or item_issuance_role (should be empty)
select 'picklist_item' as table_name, picklist_id || ' / stock ' || inventory_item_id as pair, count(*) as times
from picklist_item
group by picklist_id, inventory_item_id
having count(*) > 1
union all
select 'item_issuance_role', item_issuance_id || ' / ' || party_id || ' / ' || item_issuance_role_type_id, count(*)
from item_issuance_role
group by item_issuance_id, party_id, item_issuance_role_type_id
having count(*) > 1;
