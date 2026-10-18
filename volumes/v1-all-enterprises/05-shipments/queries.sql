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
