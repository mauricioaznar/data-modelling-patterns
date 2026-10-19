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
