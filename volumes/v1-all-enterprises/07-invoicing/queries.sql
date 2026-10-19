-- Vol 1, Chapter 7: Invoicing — queries
-- Each query starts with "-- name: <the business question>".
-- Run with: npm run queries -- v1/07

-- ============================================================
-- Fig 7.1a — Invoice and invoice items
-- ============================================================

-- name: 7.1a — Tables 7.2–7.3: invoice 30002 line by line, with what each line bills, the line it was sold with, and its value (quantity × amount, or the amount alone)
select i.invoice_item_seq_id as seq, t.description as item_type,
       coalesce(p.name, f.description, i.item_description) as bills,
       w.invoice_item_seq_id as sold_with_seq, i.quantity, i.amount,
       coalesce(i.quantity, 1) * i.amount as line_value, i.taxable_flag
from invoice_item i
join invoice_item_type t       on t.invoice_item_type_id = i.invoice_item_type_id
left join product p            on p.product_id = i.product_id
left join product_feature f    on f.product_feature_id = i.product_feature_id
left join invoice_item w       on w.invoice_item_id = i.sold_with_invoice_item_id
where i.invoice_id = 30002
order by i.invoice_item_seq_id;

-- name: 7.1a — Invoice totals: what was acquired, what adjusts it (discounts lower it), the taxable base, and the total due (30002's tax fits no clean rate: NOTES, point 2)
select v.invoice_id, v.invoice_date,
       sum(case when t.parent_type_id = 'ACQUIRING_ITEM' then coalesce(i.quantity, 1) * i.amount else 0 end) as acquired,
       sum(case when t.parent_type_id = 'ADJUSTMENT'
                then case when i.invoice_item_type_id = 'DISCOUNT' then -1 else 1 end * coalesce(i.quantity, 1) * i.amount
                else 0 end) as adjustments,
       sum(case when i.taxable_flag then coalesce(i.quantity, 1) * i.amount else 0 end) as taxable_base,
       sum(case when i.invoice_item_type_id = 'DISCOUNT' then -1 else 1 end * coalesce(i.quantity, 1) * i.amount) as total_due
from invoice v
join invoice_item i      on i.invoice_id = v.invoice_id
join invoice_item_type t on t.invoice_item_type_id = i.invoice_item_type_id
group by v.invoice_id, v.invoice_date
order by v.invoice_id;

-- name: 7.1a — Corrections and item-level adjustments: each line beside the line it adjusts, on whichever invoice that is (30016 credits 2 of 30002's 10 reams)
select a.invoice_id, a.invoice_item_seq_id as seq, t.description as item_type, a.quantity, a.amount, a.item_description,
       o.invoice_id as adjusts_invoice, o.invoice_item_seq_id as adjusts_seq, o.quantity as original_quantity,
       o.quantity + case when a.product_id = o.product_id then a.quantity else 0 end as quantity_after_correction
from invoice_item a
join invoice_item o      on o.invoice_item_id = a.adjustment_for_invoice_item_id
join invoice_item_type t on t.invoice_item_type_id = a.invoice_item_type_id
order by a.invoice_id, a.invoice_item_seq_id;

-- name: 7.1a — Billed per product, with the features billed with it, corrections netted in
select p.name as product, sum(i.quantity) as quantity_billed, sum(i.quantity * i.amount) as billed,
       (select string_agg(distinct f.description, ', ')
        from invoice_item fi
        join invoice_item pi     on pi.invoice_item_id = fi.sold_with_invoice_item_id
        join product_feature f   on f.product_feature_id = fi.product_feature_id
        where pi.product_id = p.product_id) as features_billed_with_it
from invoice_item i
join product p on p.product_id = i.product_id
where i.invoice_item_type_id = 'PRODUCT_ITEM'
group by p.product_id, p.name
order by p.name;

-- name: 7.1a — Serialized items billed: which bill each copier went out on
select ii.serial_num, p.name as product, i.invoice_id, v.invoice_date, i.amount
from invoice_item i
join inventory_item ii on ii.inventory_item_id = i.inventory_item_id
join invoice v         on v.invoice_id = i.invoice_id
left join product p    on p.product_id = i.product_id
order by ii.serial_num;

-- name: 7.1a — Data-quality check: two lines with the same seq on one invoice (should be empty)
select invoice_id, invoice_item_seq_id, count(*) as lines
from invoice_item
group by invoice_id, invoice_item_seq_id
having count(*) > 1;

-- name: 7.1a — Data-quality check: items typed with a grouping row (ACQUIRING_ITEM, ADJUSTMENT) instead of a kind of line (should be empty)
select i.invoice_id, i.invoice_item_seq_id, i.invoice_item_type_id
from invoice_item i
where exists (select 1 from invoice_item_type c where c.parent_type_id = i.invoice_item_type_id);

-- name: 7.1a — Data-quality check: acquiring lines that bill nothing: no product, feature, inventory item or description (should be empty)
select i.invoice_id, i.invoice_item_seq_id, i.invoice_item_type_id
from invoice_item i
join invoice_item_type t on t.invoice_item_type_id = i.invoice_item_type_id
where t.parent_type_id = 'ACQUIRING_ITEM'
  and num_nonnulls(i.product_id, i.product_feature_id, i.inventory_item_id, i.item_description) = 0;

-- name: 7.1a — Data-quality check: feature lines not sold with a product line of the same invoice (should be empty)
select i.invoice_id, i.invoice_item_seq_id, i.sold_with_invoice_item_id
from invoice_item i
left join invoice_item w on w.invoice_item_id = i.sold_with_invoice_item_id
where i.product_feature_id is not null
  and (w.invoice_item_id is null or w.invoice_id <> i.invoice_id or w.product_id is null);

-- name: 7.1a — Data-quality check: lines that adjust another line without being an adjustment of the same invoice or a correction of the same product (should be empty)
select a.invoice_id, a.invoice_item_seq_id, a.invoice_item_type_id, o.invoice_id as adjusts_invoice, o.invoice_item_seq_id as adjusts_seq
from invoice_item a
join invoice_item o      on o.invoice_item_id = a.adjustment_for_invoice_item_id
join invoice_item_type t on t.invoice_item_type_id = a.invoice_item_type_id
where not (t.parent_type_id = 'ADJUSTMENT' and o.invoice_id = a.invoice_id)
  and not (t.parent_type_id = 'ACQUIRING_ITEM' and a.product_id = o.product_id);

-- name: 7.1a — Data-quality check: lines whose inventory item is a different product from the line's (should be empty)
select i.invoice_id, i.invoice_item_seq_id, i.product_id, ii.inventory_item_id, ii.product_id as inventory_product_id
from invoice_item i
join inventory_item ii on ii.inventory_item_id = i.inventory_item_id
where i.product_id is distinct from ii.product_id;

-- ============================================================
-- Fig 7.2 — Invoice parties
-- ============================================================

-- name: 7.2 — Table 7.4: who each invoice is billed to and from, where it went and where it came from
select v.invoice_id, v.invoice_date, v.invoice_kind,
       coalesce(bt.name, 'account ' || v.billing_account_id) as billed_to, at.display_name as addressed_to,
       bf.name as billed_from, sf.display_name as sent_from
from invoice v
left join party_display_name bt             on bt.party_id = v.billed_to_party_id
join party_display_name bf                  on bf.party_id = v.billed_from_party_id
left join contact_mechanism_display_name at on at.contact_mechanism_id = v.addressed_to_contact_mechanism_id
left join contact_mechanism_display_name sf on sf.contact_mechanism_id = v.sent_from_contact_mechanism_id
order by v.invoice_id;

-- name: 7.2 — Invoices by channel: how many went by post and how many by e-mail
select coalesce(cm.contact_mechanism_kind, '(not recorded)') as sent_as, count(*) as invoices
from invoice v
left join contact_mechanism cm on cm.contact_mechanism_id = v.addressed_to_contact_mechanism_id
group by 1
order by 1;

-- name: 7.2 — Everyone else on each invoice: who entered it, who approved it, and when
select r.invoice_id, t.description as role, p.name as party, r.role_datetime, r.percentage
from invoice_role r
join invoice_role_type t   on t.invoice_role_type_id = r.invoice_role_type_id
join party_display_name p  on p.party_id = r.party_id
order by r.invoice_id, r.role_datetime;

-- name: 7.2 — Review: invoices where neither side is one of our internal organizations on the invoice date (Table 7.4's 30010: NOTES, point 7)
select v.invoice_id, v.invoice_kind, v.invoice_date, bf.name as billed_from, bt.name as billed_to
from invoice v
join party_display_name bf      on bf.party_id = v.billed_from_party_id
left join party_display_name bt on bt.party_id = v.billed_to_party_id
where not exists (
  select 1 from party_role pr
  where pr.party_id = case v.invoice_kind when 'SALES' then v.billed_from_party_id else v.billed_to_party_id end
    and pr.role_type_id = 'INTERNAL_ORGANIZATION'
    and pr.from_date <= v.invoice_date and (pr.thru_date is null or pr.thru_date > v.invoice_date));

-- name: 7.2 — Data-quality check: invoices billed to a party but addressed to a mechanism that party doesn't use for billing on the invoice date (should be empty)
select v.invoice_id, v.invoice_date, p.name as billed_to, cm.display_name as addressed_to
from invoice v
join party_display_name p                   on p.party_id = v.billed_to_party_id
join contact_mechanism_display_name cm      on cm.contact_mechanism_id = v.addressed_to_contact_mechanism_id
where not exists (
  select 1
  from party_contact_mechanism pcm
  join party_contact_mechanism_purpose pu on pu.party_contact_mechanism_id = pcm.party_contact_mechanism_id
  where pcm.party_id = v.billed_to_party_id
    and pcm.contact_mechanism_id = v.addressed_to_contact_mechanism_id
    and pu.contact_mechanism_purpose_type_id = 'BILLING'
    and pcm.from_date <= v.invoice_date and (pcm.thru_date is null or pcm.thru_date > v.invoice_date)
    and pu.from_date  <= v.invoice_date and (pu.thru_date  is null or pu.thru_date  > v.invoice_date));

-- name: 7.2 — Data-quality check: invoices sent from a mechanism the sender isn't linked to on the invoice date (should be empty)
select v.invoice_id, v.invoice_date, p.name as billed_from, cm.display_name as sent_from
from invoice v
join party_display_name p              on p.party_id = v.billed_from_party_id
join contact_mechanism_display_name cm on cm.contact_mechanism_id = v.sent_from_contact_mechanism_id
where not exists (
  select 1 from party_contact_mechanism pcm
  where pcm.party_id = v.billed_from_party_id
    and pcm.contact_mechanism_id = v.sent_from_contact_mechanism_id
    and pcm.from_date <= v.invoice_date and (pcm.thru_date is null or pcm.thru_date > v.invoice_date));

-- name: 7.2 — Data-quality check: the same party in the same role on one invoice twice (should be empty)
select invoice_id, party_id, invoice_role_type_id, count(*) as rows
from invoice_role
group by invoice_id, party_id, invoice_role_type_id
having count(*) > 1;

-- ============================================================
-- Fig 7.3a — Billing account
-- ============================================================

-- name: 7.3a — Tables 7.5–7.6: each account, where its bills go, and who is on it in which role (thru shown inclusive)
select a.billing_account_id, a.description, cm.display_name as billed_at,
       p.name as party, t.description as role, r.from_date, r.thru_date - 1 as thru_date_inclusive
from billing_account a
join contact_mechanism_display_name cm on cm.contact_mechanism_id = a.billed_at_contact_mechanism_id
left join billing_account_role r       on r.billing_account_id = a.billing_account_id
left join billing_account_role_type t  on t.billing_account_role_type_id = r.billing_account_role_type_id
left join party_display_name p         on p.party_id = r.party_id
order by a.billing_account_id, r.from_date, t.description;

-- name: 7.3a — Who owes each invoice: the party billed, or the account's primary payer on the invoice date (NOTES, point 12)
select v.invoice_id, v.invoice_date, v.billing_account_id,
       coalesce(bt.name, string_agg(pp.name, ', ')) as who_owes
from invoice v
left join party_display_name bt on bt.party_id = v.billed_to_party_id
left join billing_account_role r
       on r.billing_account_id = v.billing_account_id
      and r.billing_account_role_type_id = 'PRIMARY_PAYER'
      and r.from_date <= v.invoice_date and (r.thru_date is null or r.thru_date > v.invoice_date)
left join party_display_name pp on pp.party_id = r.party_id
group by v.invoice_id, v.invoice_date, v.billing_account_id, bt.name
order by v.invoice_id;

-- name: 7.3a — Account 1459's payers on three days: Jun 1, 2001 (John is secondary), Jun 20, 2001 (Joe has replaced him), Aug 1, 2001 (the bad second primary shows)
select d.as_of, p.name as party, t.description as role
from (values (date '2001-06-01'), (date '2001-06-20'), (date '2001-08-01')) as d(as_of)
join billing_account_role r          on r.billing_account_id = 1459
                                    and r.from_date <= d.as_of and (r.thru_date is null or r.thru_date > d.as_of)
join billing_account_role_type t     on t.billing_account_role_type_id = r.billing_account_role_type_id
join party_display_name p            on p.party_id = r.party_id
order by d.as_of, t.description, p.name;

-- name: 7.3a — Everything billed per account, and every account a party pays on
select p.name as party, t.description as role, a.billing_account_id, a.description,
       (select count(*) from invoice v where v.billing_account_id = a.billing_account_id) as invoices
from billing_account_role r
join billing_account a            on a.billing_account_id = r.billing_account_id
join billing_account_role_type t  on t.billing_account_role_type_id = r.billing_account_role_type_id
join party_display_name p         on p.party_id = r.party_id
where r.thru_date is null
order by p.name, a.billing_account_id;

-- name: 7.3a — Data-quality check: invoices billed to an account outside the account's dates (should be empty)
select v.invoice_id, v.invoice_date, a.billing_account_id, a.from_date, a.thru_date
from invoice v
join billing_account a on a.billing_account_id = v.billing_account_id
where v.invoice_date < a.from_date or (a.thru_date is not null and v.invoice_date >= a.thru_date);

-- name: 7.3a — Data-quality check: account invoices addressed somewhere other than the account's billing mechanism (should be empty)
select v.invoice_id, a.billing_account_id, cm.display_name as addressed_to, ab.display_name as account_billed_at
from invoice v
join billing_account a                      on a.billing_account_id = v.billing_account_id
left join contact_mechanism_display_name cm on cm.contact_mechanism_id = v.addressed_to_contact_mechanism_id
join contact_mechanism_display_name ab      on ab.contact_mechanism_id = a.billed_at_contact_mechanism_id
where v.addressed_to_contact_mechanism_id is distinct from a.billed_at_contact_mechanism_id;

-- name: 7.3a — Data-quality check: two primary payers at once on one account (should be empty)
select r1.billing_account_id, r1.party_id as first_payer, r2.party_id as second_payer, greatest(r1.from_date, r2.from_date) as overlap_from
from billing_account_role r1
join billing_account_role r2
  on r2.billing_account_id = r1.billing_account_id
 and r2.billing_account_role_id > r1.billing_account_role_id
 and r1.billing_account_role_type_id = 'PRIMARY_PAYER'
 and r2.billing_account_role_type_id = 'PRIMARY_PAYER'
 and r1.from_date < coalesce(r2.thru_date, 'infinity')
 and r2.from_date < coalesce(r1.thru_date, 'infinity');

-- name: 7.3a — Data-quality check: account invoices with no primary payer on the invoice date (should be empty; 30014 predates its account)
select v.invoice_id, v.invoice_date, v.billing_account_id
from invoice v
where v.billing_account_id is not null
  and not exists (
    select 1 from billing_account_role r
    where r.billing_account_id = v.billing_account_id
      and r.billing_account_role_type_id = 'PRIMARY_PAYER'
      and r.from_date <= v.invoice_date and (r.thru_date is null or r.thru_date > v.invoice_date));

-- name: 7.3a — Data-quality check: the same party in the same role on one account from the same day, twice (should be empty)
select billing_account_id, party_id, billing_account_role_type_id, from_date, count(*) as rows
from billing_account_role
group by billing_account_id, party_id, billing_account_role_type_id, from_date
having count(*) > 1;

-- ============================================================
-- Fig 7.4 — Invoice status and terms
-- ============================================================

-- name: 7.4 — Table 7.7: each invoice's status history, in order
select s.invoice_id, t.description as status, s.status_date
from invoice_status s
join status_type t on t.status_type_id = s.status_type_id
order by s.invoice_id, s.status_date, s.invoice_status_id;

-- name: 7.4 — Where each invoice stands now: its latest status (30005 shows Sent, because of the bad row after its void)
select distinct on (v.invoice_id) v.invoice_id, v.invoice_date, t.description as current_status, s.status_date as since
from invoice v
left join invoice_status s on s.invoice_id = v.invoice_id
left join status_type t    on t.status_type_id = s.status_type_id
order by v.invoice_id, s.status_date desc nulls last, s.invoice_status_id desc;

-- name: 7.4 — Table 7.8: the terms on each invoice, and on its lines
select coalesce(r.invoice_id, i.invoice_id) as invoice_id, i.invoice_item_seq_id as item_seq,
       t.description as term, r.term_value
from invoice_term r
join term_type t         on t.term_type_id = r.term_type_id
left join invoice_item i on i.invoice_item_id = r.invoice_item_id
order by 1, 2 nulls first, t.description;

-- name: 7.4 — Due dates: invoice date plus the payment term's net days, beside the date it was first sent
select v.invoice_id, v.invoice_date, r.term_value as net_days,
       (select min(s.status_date) from invoice_status s where s.invoice_id = v.invoice_id and s.status_type_id = 'INVOICE_SENT') as first_sent,
       v.invoice_date + r.term_value::int as due_date
from invoice v
join invoice_term r on r.invoice_id = v.invoice_id and r.term_type_id = 'PAYMENT_DUE_DAYS'
order by v.invoice_id, due_date;

-- name: 7.4 — Data-quality check: invoice statuses that aren't invoice statuses (should be empty)
select s.invoice_id, s.status_type_id, s.status_date
from invoice_status s
join status_type t on t.status_type_id = s.status_type_id
where t.parent_type_id is distinct from 'INVOICE_STATUS';

-- name: 7.4 — Data-quality check: statuses dated before the invoice itself (should be empty)
select s.invoice_id, v.invoice_date, s.status_type_id, s.status_date
from invoice_status s
join invoice v on v.invoice_id = s.invoice_id
where s.status_date < v.invoice_date;

-- name: 7.4 — Data-quality check: anything after a void (should be empty)
select s.invoice_id, x.status_date as voided, s.status_type_id, s.status_date
from invoice_status s
join invoice_status x on x.invoice_id = s.invoice_id and x.status_type_id = 'INVOICE_VOID'
where s.status_date > x.status_date;

-- name: 7.4 — Data-quality check: the same status twice on one day, against the book's identifier (should be empty)
select invoice_id, status_type_id, status_date, count(*) as rows
from invoice_status
group by invoice_id, status_type_id, status_date
having count(*) > 1;

-- name: 7.4 — Data-quality check: one term type twice on the same invoice or line (should be empty)
select invoice_id, invoice_item_id, term_type_id, count(*) as rows, string_agg(coalesce(term_value::text, '-'), ', ') as term_values
from invoice_term
group by invoice_id, invoice_item_id, term_type_id
having count(*) > 1;

-- ============================================================
-- Fig 7.5 — Billing for shipment items
-- ============================================================

-- name: 7.5 — Table 7.9: each shipment line beside the invoice line that bills it, with both quantities
select si.shipment_id, si.shipment_item_seq_id as shipment_seq, p.name as shipped, si.quantity as shipped_qty,
       ii.invoice_id, ii.invoice_item_seq_id as invoice_seq, ii.quantity as invoice_qty
from shipment_item_billing b
join shipment_item si on si.shipment_item_id = b.shipment_item_id
join invoice_item ii  on ii.invoice_item_id = b.invoice_item_id
left join product p   on p.product_id = si.product_id
where si.shipment_id in (1235, 1330)
order by si.shipment_id, si.shipment_item_seq_id, ii.invoice_id;

-- name: 7.5 — What each 2001 customer shipment line went out with, and what is billed for it so far (a void invoice bills nothing: 1330's books are unbilled again)
select si.shipment_id, si.shipment_item_seq_id as seq, s.estimated_ship_date, p.name as good, si.quantity as shipped,
       coalesce(sum(ii.quantity) filter (where not exists (
                  select 1 from invoice_status x where x.invoice_id = ii.invoice_id and x.status_type_id = 'INVOICE_VOID')), 0) as billed,
       string_agg(distinct ii.invoice_id::text, ', ') as invoices
from shipment_item si
join shipment s             on s.shipment_id = si.shipment_id
left join product p         on p.product_id = si.product_id
left join shipment_item_billing b on b.shipment_item_id = si.shipment_item_id
left join invoice_item ii   on ii.invoice_item_id = b.invoice_item_id
where s.shipment_type_id = 'CUSTOMER_SHIPMENT' and s.estimated_ship_date >= '2001-01-01'
group by si.shipment_item_id, si.shipment_id, si.shipment_item_seq_id, s.estimated_ship_date, p.name, si.quantity
order by si.shipment_id, si.shipment_item_seq_id;

-- name: 7.5 — Data-quality check: the same shipment line on the same invoice line twice (should be empty)
select shipment_item_id, invoice_item_id, count(*) as rows
from shipment_item_billing
group by shipment_item_id, invoice_item_id
having count(*) > 1;

-- name: 7.5 — Data-quality check: shipment lines billed on an invoice line for another product (should be empty)
select si.shipment_id, si.shipment_item_seq_id as shipment_seq, sp.name as shipped,
       ii.invoice_id, ii.invoice_item_seq_id as invoice_seq, ip.name as billed
from shipment_item_billing b
join shipment_item si on si.shipment_item_id = b.shipment_item_id
join invoice_item ii  on ii.invoice_item_id = b.invoice_item_id
join product sp       on sp.product_id = si.product_id
join product ip       on ip.product_id = ii.product_id
where si.product_id <> ii.product_id;

-- name: 7.5 — Data-quality check: shipments billed to someone else than the party they went to (party-billed invoices; should be empty)
select s.shipment_id, sn.name as shipped_to, v.invoice_id, bn.name as billed_to
from shipment_item_billing b
join shipment_item si          on si.shipment_item_id = b.shipment_item_id
join shipment s                on s.shipment_id = si.shipment_id
join invoice_item ii           on ii.invoice_item_id = b.invoice_item_id
join invoice v                 on v.invoice_id = ii.invoice_id
join party_display_name sn     on sn.party_id = s.shipped_to_party_id
join party_display_name bn     on bn.party_id = v.billed_to_party_id
where v.billed_to_party_id <> s.shipped_to_party_id;

-- ============================================================
-- Fig 7.6 — Billing of time entries and work efforts
-- ============================================================

-- name: 7.6 — Each service line and what it bills: the time entries (who, when, hours) or the work effort and its share
select ii.invoice_id, ii.invoice_item_seq_id as seq, ii.invoice_item_type_id as item_type, ii.quantity, ii.amount,
       w.name as work_effort, coalesce(eb.percentage::text || '%', '') as share,
       p.name as worker, te.from_datetime::date as entry_from, te.hours
from invoice_item ii
left join time_entry_billing tb  on tb.invoice_item_id = ii.invoice_item_id
left join time_entry te          on te.time_entry_id = tb.time_entry_id
left join timesheet ts           on ts.timesheet_id = te.timesheet_id
left join party_role pr          on pr.party_role_id = ts.party_role_id
left join party_display_name p   on p.party_id = pr.party_id
left join work_effort_billing eb on eb.invoice_item_id = ii.invoice_item_id
left join work_effort w          on w.work_effort_id = coalesce(eb.work_effort_id, te.work_effort_id)
where tb.time_entry_billing_id is not null or eb.work_effort_billing_id is not null
order by ii.invoice_id, ii.invoice_item_seq_id, te.from_datetime;

-- name: 7.6 — Time not billed yet: each time entry and its hours, with the invoices that bill it (Ch 6's in-house work shows too: it was never billable)
select te.time_entry_id, p.name as worker, w.name as work_effort, te.from_datetime::date as entry_from, te.hours,
       string_agg(ii.invoice_id::text, ', ') as billed_on
from time_entry te
join timesheet ts               on ts.timesheet_id = te.timesheet_id
join party_role pr              on pr.party_role_id = ts.party_role_id
join party_display_name p       on p.party_id = pr.party_id
join work_effort w              on w.work_effort_id = te.work_effort_id
left join time_entry_billing tb on tb.time_entry_id = te.time_entry_id
left join invoice_item ii       on ii.invoice_item_id = tb.invoice_item_id
group by te.time_entry_id, p.name, w.name, te.from_datetime, te.hours
order by te.time_entry_id;

-- name: 7.6 — Review: time entry lines whose hours differ from the hours of the entries they bill (no hours on the link to split an entry: NOTES, point 15)
select ii.invoice_id, ii.invoice_item_seq_id as seq, ii.quantity as billed_hours, sum(te.hours) as entry_hours
from invoice_item ii
join time_entry_billing tb on tb.invoice_item_id = ii.invoice_item_id
join time_entry te         on te.time_entry_id = tb.time_entry_id
group by ii.invoice_item_id, ii.invoice_id, ii.invoice_item_seq_id, ii.quantity
having ii.quantity is distinct from sum(te.hours);

-- name: 7.6 — Data-quality check: billing links on a line of the wrong type: time entries on a line not typed TIME_ENTRY_ITEM, efforts on one not typed WORK_EFFORT_ITEM (should be empty)
select 'time entry' as link, tb.time_entry_id as linked_id, ii.invoice_id, ii.invoice_item_seq_id as seq, ii.invoice_item_type_id
from time_entry_billing tb
join invoice_item ii on ii.invoice_item_id = tb.invoice_item_id
where ii.invoice_item_type_id <> 'TIME_ENTRY_ITEM'
union all
select 'work effort', eb.work_effort_id, ii.invoice_id, ii.invoice_item_seq_id, ii.invoice_item_type_id
from work_effort_billing eb
join invoice_item ii on ii.invoice_item_id = eb.invoice_item_id
where ii.invoice_item_type_id <> 'WORK_EFFORT_ITEM';

-- name: 7.6 — Data-quality check: time entries billed on more than one line, with no hours to say how they split (should be empty)
select tb.time_entry_id, count(*) as lines, string_agg(ii.invoice_id || '/' || ii.invoice_item_seq_id, ', ') as billed_on
from time_entry_billing tb
join invoice_item ii on ii.invoice_item_id = tb.invoice_item_id
group by tb.time_entry_id
having count(*) > 1;

-- name: 7.6 — Data-quality check: work efforts billed for more than 100% in all (should be empty)
select w.work_effort_id, w.name, sum(eb.percentage) as billed_pct
from work_effort_billing eb
join work_effort w on w.work_effort_id = eb.work_effort_id
group by w.work_effort_id, w.name
having sum(eb.percentage) > 100;

-- ============================================================
-- Fig 7.7 — Billing for order items
-- ============================================================

-- name: 7.7 — Table 7.10: each purchase order line beside the invoice lines that bill it, with how much of it each bills
select oi.order_id as purchase_order_id, oi.order_item_seq_id as order_seq, oi.quantity, oi.unit_price,
       ii.invoice_id, ii.invoice_item_seq_id as invoice_seq, ii.quantity as invoice_quantity, b.quantity as billing_quantity, b.amount
from order_item_billing b
join order_item oi   on oi.order_item_id = b.order_item_id
join invoice_item ii on ii.invoice_item_id = b.invoice_item_id
where oi.order_id between 10001 and 10003
order by oi.order_id, ii.invoice_id;

-- name: 7.7 — Ordered against billed, per order line billed through its order (10002 shows the over-billing)
select oi.order_id, o.order_kind, oi.order_item_seq_id as seq, oi.quantity as ordered, sum(b.quantity) as billed,
       oi.quantity - sum(b.quantity) as left_to_bill
from order_item oi
join "order" o            on o.order_id = oi.order_id
join order_item_billing b on b.order_item_id = oi.order_item_id
group by oi.order_item_id, oi.order_id, o.order_kind, oi.order_item_seq_id, oi.quantity
order by oi.order_id, oi.order_item_seq_id;

-- name: 7.7 — Review: invoice lines whose quantity isn't the sum of the order quantities they bill
select ii.invoice_id, ii.invoice_item_seq_id as seq, ii.quantity as invoice_quantity, sum(b.quantity) as order_quantities
from invoice_item ii
join order_item_billing b on b.invoice_item_id = ii.invoice_item_id
group by ii.invoice_item_id, ii.invoice_id, ii.invoice_item_seq_id, ii.quantity
having ii.quantity is distinct from sum(b.quantity);

-- name: 7.7 — Data-quality check: order lines billed for more than was ordered (should be empty)
select oi.order_id, oi.order_item_seq_id as seq, oi.quantity as ordered, sum(b.quantity) as billed
from order_item_billing b
join order_item oi on oi.order_item_id = b.order_item_id
group by oi.order_item_id, oi.order_id, oi.order_item_seq_id, oi.quantity
having sum(b.quantity) > oi.quantity;

-- name: 7.7 — Data-quality check: order lines billed on the other kind of invoice: a sales order on a purchase invoice or back (should be empty)
select oi.order_id, o.order_kind, ii.invoice_id, v.invoice_kind
from order_item_billing b
join order_item oi   on oi.order_item_id = b.order_item_id
join "order" o       on o.order_id = oi.order_id
join invoice_item ii on ii.invoice_item_id = b.invoice_item_id
join invoice v       on v.invoice_id = ii.invoice_id
where o.order_kind <> v.invoice_kind;

-- name: 7.7 — Data-quality check: invoice lines billed both through an order and through a shipment, counted twice (should be empty)
select ii.invoice_id, ii.invoice_item_seq_id as seq
from invoice_item ii
where exists (select 1 from order_item_billing b where b.invoice_item_id = ii.invoice_item_id)
  and exists (select 1 from shipment_item_billing s where s.invoice_item_id = ii.invoice_item_id);

-- ============================================================
-- Fig 7.8a — Invoice payments
-- ============================================================

-- name: 7.8a — Table 7.11: each invoice's payments, with how much of each payment went to it
select a.invoice_id, t.total_due, a.payment_id, p.effective_date, a.amount_applied, p.amount as payment_amount
from payment_application a
join payment p        on p.payment_id = a.payment_id
join invoice_total t  on t.invoice_id = a.invoice_id
where a.invoice_id in (30002, 990023, 990026)
order by a.invoice_id, p.effective_date;

-- name: 7.8a — What's still owed on each invoice: total, paid, outstanding, and whether it's past its due date on Jul 31, 2001 (void invoices left out)
select v.invoice_id, v.invoice_kind, v.invoice_date, t.total_due, x.paid, t.total_due - x.paid as outstanding,
       d.due_date, coalesce(d.due_date < date '2001-07-31', false) and t.total_due - x.paid > 0 as overdue
from invoice v
join invoice_total t on t.invoice_id = v.invoice_id
cross join lateral (select coalesce(sum(a.amount_applied), 0) as paid
                    from payment_application a where a.invoice_id = v.invoice_id) x
cross join lateral (select v.invoice_date + min(r.term_value)::int as due_date   -- the strictest term if two were keyed
                    from invoice_term r where r.invoice_id = v.invoice_id and r.term_type_id = 'PAYMENT_DUE_DAYS') d
where not exists (select 1 from invoice_status s where s.invoice_id = v.invoice_id and s.status_type_id = 'INVOICE_VOID')
order by v.invoice_id;

-- name: 7.8a — Each payment: who paid whom, how, and how much of it is applied to bills, on account, or not yet at all
select p.payment_id, p.payment_kind, m.description as method, f.name as payor, r.name as receiver, p.effective_date, p.amount,
       coalesce(sum(a.amount_applied) filter (where a.invoice_id is not null), 0) as to_invoices,
       coalesce(sum(a.amount_applied) filter (where a.billing_account_id is not null), 0) as on_account,
       p.amount - coalesce(sum(a.amount_applied), 0) as unapplied
from payment p
join payment_method_type m      on m.payment_method_type_id = p.payment_method_type_id
join party_display_name f       on f.party_id = p.from_party_id
join party_display_name r       on r.party_id = p.to_party_id
left join payment_application a on a.payment_id = p.payment_id
group by p.payment_id, p.payment_kind, m.description, f.name, r.name, p.effective_date, p.amount
order by p.effective_date, p.payment_id;

-- name: 7.8a — Review: payments applied to an invoice billed to someone else than the payor (a parent paying for a child is fine; a stranger is a question)
select a.payment_id, f.name as payor, v.invoice_id, coalesce(b.name, 'account ' || v.billing_account_id) as billed_to
from payment_application a
join payment p             on p.payment_id = a.payment_id
join invoice v             on v.invoice_id = a.invoice_id
join party_display_name f  on f.party_id = p.from_party_id
left join party_display_name b on b.party_id = v.billed_to_party_id
where v.billed_to_party_id is distinct from p.from_party_id
  and not exists (select 1 from billing_account_role r
                  where r.billing_account_id = v.billing_account_id and r.party_id = p.from_party_id);

-- name: 7.8a — Data-quality check: payments going the wrong way: a receipt not received by one of our internal organizations, or a disbursement not paid by one (should be empty)
select p.payment_id, p.payment_kind, f.name as payor, r.name as receiver
from payment p
join party_display_name f on f.party_id = p.from_party_id
join party_display_name r on r.party_id = p.to_party_id
where not exists (select 1 from party_role pr
                  where pr.party_id = case p.payment_kind when 'RECEIPT' then p.to_party_id else p.from_party_id end
                    and pr.role_type_id = 'INTERNAL_ORGANIZATION'
                    and pr.from_date <= p.effective_date and (pr.thru_date is null or pr.thru_date > p.effective_date));

-- name: 7.8a — Data-quality check: payments applied for more than they're worth (should be empty)
select p.payment_id, p.amount, sum(a.amount_applied) as applied
from payment p
join payment_application a on a.payment_id = p.payment_id
group by p.payment_id, p.amount
having sum(a.amount_applied) > p.amount;

-- name: 7.8a — Data-quality check: invoices paid past their total (should be empty)
select a.invoice_id, t.total_due, sum(a.amount_applied) as paid
from payment_application a
join invoice_total t on t.invoice_id = a.invoice_id
group by a.invoice_id, t.total_due
having sum(a.amount_applied) > t.total_due;

-- name: 7.8a — Data-quality check: receipts applied to purchase invoices, or disbursements to sales invoices (should be empty)
select a.payment_id, p.payment_kind, a.invoice_id, v.invoice_kind
from payment_application a
join payment p on p.payment_id = a.payment_id
join invoice v on v.invoice_id = a.invoice_id
where (p.payment_kind = 'RECEIPT') <> (v.invoice_kind = 'SALES');

-- ============================================================
-- Fig 7.9 — Financial accounts, withdrawals and deposits
-- ============================================================

-- name: 7.9 — Table 7.12: each deposit and withdrawal with the payments in it, and its amount as their sum
select x.financial_account_id, x.financial_account_transaction_id as transaction_id, x.transaction_kind, x.transaction_date,
       p.payment_id, p.payment_kind, p.amount as payment_amount,
       sum(p.amount) over (partition by x.financial_account_transaction_id) as transaction_amount
from financial_account_transaction x
join payment p on p.financial_account_transaction_id = x.financial_account_transaction_id
order by x.transaction_date, x.financial_account_transaction_id, p.payment_id;

-- name: 7.9 — Account balance movements: deposits in, withdrawals out, adjustments as signed, and the running balance
select x.financial_account_id, x.transaction_date, x.financial_account_transaction_id as transaction_id, x.transaction_kind,
       case x.transaction_kind when 'ADJUSTMENT' then x.amount
                               when 'DEPOSIT'    then coalesce(t.total, 0)
                               else -coalesce(t.total, 0) end as movement,
       sum(case x.transaction_kind when 'ADJUSTMENT' then x.amount
                                   when 'DEPOSIT'    then coalesce(t.total, 0)
                                   else -coalesce(t.total, 0) end)
         over (partition by x.financial_account_id order by x.transaction_date, x.financial_account_transaction_id) as running_balance
from financial_account_transaction x
left join lateral (select sum(p.amount) as total from payment p
                   where p.financial_account_transaction_id = x.financial_account_transaction_id) t on true
order by x.financial_account_id, x.transaction_date, x.financial_account_transaction_id;

-- name: 7.9 — Payments not banked yet: receipts not deposited, checks not cleared
select p.payment_id, p.payment_kind, p.effective_date, p.amount, f.name as payor, r.name as receiver
from payment p
join party_display_name f on f.party_id = p.from_party_id
join party_display_name r on r.party_id = p.to_party_id
where p.financial_account_transaction_id is null
order by p.effective_date;

-- name: 7.9 — Who may act on each account, and in which role, on Jul 1, 2001
select a.financial_account_id, a.financial_account_name, t.description as account_type, n.name as party, rt.description as role
from financial_account a
left join financial_account_type t       on t.financial_account_type_id = a.financial_account_type_id
join financial_account_role r            on r.financial_account_id = a.financial_account_id
                                        and r.from_date <= '2001-07-01' and (r.thru_date is null or r.thru_date > '2001-07-01')
join financial_account_role_type rt      on rt.financial_account_role_type_id = r.financial_account_role_type_id
join party_display_name n                on n.party_id = r.party_id
order by a.financial_account_id, rt.description, n.name;

-- name: 7.9 — Data-quality check: accounts typed outside their kind, or with a grouping row (should be empty)
select a.financial_account_id, a.financial_account_kind, a.financial_account_type_id, t.parent_type_id
from financial_account a
join financial_account_type t on t.financial_account_type_id = a.financial_account_type_id
where t.parent_type_id is distinct from a.financial_account_kind;

-- name: 7.9 — Data-quality check: payments in the wrong kind of transaction: a receipt not in a deposit, a disbursement not in a withdrawal (should be empty)
select p.payment_id, p.payment_kind, x.financial_account_transaction_id as transaction_id, x.transaction_kind
from payment p
join financial_account_transaction x on x.financial_account_transaction_id = p.financial_account_transaction_id
where (p.payment_kind, x.transaction_kind) not in (('RECEIPT', 'DEPOSIT'), ('DISBURSEMENT', 'WITHDRAWAL'));

-- name: 7.9 — Data-quality check: withdrawals that aren't exactly one check, and deposits with no receipts (should be empty)
select x.financial_account_transaction_id as transaction_id, x.transaction_kind, count(p.payment_id) as payments
from financial_account_transaction x
left join payment p on p.financial_account_transaction_id = x.financial_account_transaction_id
where x.transaction_kind in ('DEPOSIT', 'WITHDRAWAL')
group by x.financial_account_transaction_id, x.transaction_kind
having (x.transaction_kind = 'WITHDRAWAL' and count(p.payment_id) <> 1)
    or (x.transaction_kind = 'DEPOSIT' and count(p.payment_id) = 0);

-- name: 7.9 — Data-quality check: transactions executed by someone with no role on the account that day (should be empty)
select x.financial_account_transaction_id as transaction_id, x.transaction_date, n.name as executed_by
from financial_account_transaction x
join party_display_name n on n.party_id = x.executed_by_party_id
where not exists (select 1 from financial_account_role r
                  where r.financial_account_id = x.financial_account_id
                    and r.party_id = x.executed_by_party_id
                    and r.from_date <= x.transaction_date and (r.thru_date is null or r.thru_date > x.transaction_date));

-- name: 7.9 — Data-quality check: the same party in the same role on one account from the same day, twice (should be empty)
select financial_account_id, party_id, financial_account_role_type_id, from_date, count(*) as rows
from financial_account_role
group by financial_account_id, party_id, financial_account_role_type_id, from_date
having count(*) > 1;
