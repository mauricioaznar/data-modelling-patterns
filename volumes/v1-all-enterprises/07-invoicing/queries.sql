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
