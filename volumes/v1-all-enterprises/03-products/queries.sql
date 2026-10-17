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

-- ============================================================
-- Fig 3.3 — Product identification
-- ============================================================

-- name: 3.3 — Scan a code: which product is 9780471380238, whatever kind of code it is?
select gi.id_value, gi.identification_type_id, pr.product_id, pr.name
from good_identification gi
join product pr on pr.product_id = gi.product_id
where gi.id_value = '9780471380238';

-- name: 3.3 — Every product with its codes, one column per type
select pr.product_id, pr.name,
       string_agg(gi.id_value, ', ') filter (where gi.identification_type_id = 'SKU')             as sku,
       string_agg(gi.id_value, ', ') filter (where gi.identification_type_id in ('UPCA', 'UPCE')) as upc,
       string_agg(gi.id_value, ', ') filter (where gi.identification_type_id = 'ISBN')            as isbn,
       string_agg(gi.id_value, ', ') filter (where gi.identification_type_id = 'MANUFACTURER_ID') as manufacturer_id
from product pr
left join good_identification gi on gi.product_id = pr.product_id
group by pr.product_id
order by pr.product_id;

-- name: 3.3 — Data-quality check: product_kind and the good subtype table disagree (should be empty)
select pr.product_id, pr.product_kind, pr.name, (g.product_id is not null) as has_good_row
from product pr
left join good g on g.product_id = pr.product_id
where (pr.product_kind = 'GOOD'    and g.product_id is null)
   or (pr.product_kind = 'SERVICE' and g.product_id is not null);

-- name: 3.3 — Data-quality check: one code identifying two products (should be empty)
select gi.identification_type_id, gi.id_value, string_agg(pr.name, ' / ' order by pr.product_id) as products
from good_identification gi
join product pr on pr.product_id = gi.product_id
group by gi.identification_type_id, gi.id_value
having count(distinct gi.product_id) > 1;

-- name: 3.3 — Data-quality check: a product with two codes of the same type (should be empty)
select pr.product_id, pr.name, gi.identification_type_id, string_agg(gi.id_value, ', ') as values
from good_identification gi
join product pr on pr.product_id = gi.product_id
group by pr.product_id, pr.name, gi.identification_type_id
having count(*) > 1;

-- name: 3.3 — Data-quality check: codes that don't match their type's format (should be empty)
select pr.name, gi.identification_type_id, gi.id_value, t.value_pattern
from good_identification gi
join identification_type t on t.identification_type_id = gi.identification_type_id
join product pr            on pr.product_id = gi.product_id
where t.value_pattern is not null
  and gi.id_value !~ t.value_pattern;

-- ============================================================
-- Fig 3.4 — Product feature
-- ============================================================

-- name: 3.4 — The copier's features today, by applicability
select a.product_feature_applicability_type_id as applicability,
       f.product_feature_type_id as feature_type, f.description as feature,
       c.description as feature_category
from product_feature_applicability a
join product_feature f               on f.product_feature_id = a.product_feature_id
left join product_feature_category c on c.product_feature_category_id = f.product_feature_category_id
where a.product_id = 6
  and a.from_date <= current_date
  and (a.thru_date is null or a.thru_date > current_date)
order by applicability, feature_type, feature;

-- name: 3.4 — Pen colours you could pick in 2019 vs today
select d.as_of, string_agg(f.description, ', ' order by f.description) as colours
from (values (date '2019-06-01'), (current_date)) as d(as_of)
join product_feature_applicability a
  on a.product_id = 2
 and a.product_feature_applicability_type_id = 'SELECTABLE'
 and a.from_date <= d.as_of
 and (a.thru_date is null or a.thru_date > d.as_of)
join product_feature f on f.product_feature_id = a.product_feature_id
                      and f.product_feature_type_id = 'COLOR'
group by d.as_of
order by d.as_of;

-- name: 3.4 — Dimensions with their unit, and in centimetres where a conversion exists
select f.description, f.number_specified, f.uom_id,
       round(f.number_specified * cv.conversion_factor, 2) as in_cm
from product_feature f
left join unit_of_measure_conversion cv on cv.from_uom_id = f.uom_id and cv.to_uom_id = 'CM'
where f.product_feature_type_id = 'DIMENSION'
order by f.product_feature_id;

-- name: 3.4 — An order for 3 of each product: how many base units (EA) is that?
select pr.name, 3 as quantity, pr.uom_id,
       case when pr.uom_id = 'EA' then 3
            else 3 * cv.conversion_factor end as quantity_in_each
from product pr
left join unit_of_measure_conversion cv on cv.from_uom_id = pr.uom_id and cv.to_uom_id = 'EA'
where pr.product_kind = 'GOOD'
order by pr.product_id;

-- name: 3.4 — Feature interactions, readable
select it.product_feature_interaction_type_id as kind,
       f.description  as feature,
       ff.description as factor,
       coalesce(pr.name, '(any product)') as context
from product_feature_interaction it
join product_feature f  on f.product_feature_id  = it.product_feature_id
join product_feature ff on ff.product_feature_id = it.factor_product_feature_id
left join product pr    on pr.product_id = it.product_id
order by context, kind;

-- name: 3.4 — Is this copier configuration valid? (chosen: stapling finisher, big tray, desktop stand, scan-to-email)
with chosen (product_feature_id) as (values (14), (15), (16), (18)),
available as (
  select a.product_feature_id, a.product_feature_applicability_type_id as applicability
  from product_feature_applicability a
  where a.product_id = 6
    and a.from_date <= current_date
    and (a.thru_date is null or a.thru_date > current_date)
),
-- what the customer gets: their choices plus everything required or standard
effective as (
  select product_feature_id from chosen
  union
  select product_feature_id from available where applicability in ('REQUIRED', 'STANDARD')
),
interaction as (
  select * from product_feature_interaction
  where product_id = 6 or product_id is null
)
select 'not available for this product' as problem, f.description as feature, null as other
from chosen c
join product_feature f on f.product_feature_id = c.product_feature_id
where c.product_feature_id not in (select product_feature_id from available)
union all
select 'needs a feature that is not included', f.description, ff.description
from interaction i
join effective e        on e.product_feature_id = i.product_feature_id
join product_feature f  on f.product_feature_id  = i.product_feature_id
join product_feature ff on ff.product_feature_id = i.factor_product_feature_id
where i.product_feature_interaction_type_id = 'DEPENDENCY'
  and i.factor_product_feature_id not in (select product_feature_id from effective)
union all
select 'incompatible pair chosen', f.description, ff.description
from interaction i
join product_feature f  on f.product_feature_id  = i.product_feature_id
join product_feature ff on ff.product_feature_id = i.factor_product_feature_id
where i.product_feature_interaction_type_id = 'INCOMPATIBILITY'
  and i.product_feature_id        in (select product_feature_id from effective)
  and i.factor_product_feature_id in (select product_feature_id from effective)
order by problem, feature;

-- name: 3.4 — Data-quality check: DIMENSION features without a number, or other features with a number or unit (should be empty)
select product_feature_id, product_feature_type_id, description, number_specified, uom_id
from product_feature
where (product_feature_type_id = 'DIMENSION' and number_specified is null)
   or (product_feature_type_id <> 'DIMENSION' and (number_specified is not null or uom_id is not null));

-- name: 3.4 — Data-quality check: unit conversions that disagree with their reverse (should be empty)
select a.from_uom_id, a.to_uom_id, a.conversion_factor, b.conversion_factor as reverse_factor,
       round(a.conversion_factor * b.conversion_factor, 4) as product_should_be_1
from unit_of_measure_conversion a
join unit_of_measure_conversion b on b.from_uom_id = a.to_uom_id and b.to_uom_id = a.from_uom_id
where a.from_uom_id < a.to_uom_id
  and abs(a.conversion_factor * b.conversion_factor - 1) > 0.001;

-- name: 3.4 — Data-quality check: interactions naming a feature the context product doesn't offer (should be empty)
select it.product_feature_interaction_id, pr.name as product, f.description as feature
from product_feature_interaction it
join product pr on pr.product_id = it.product_id
join product_feature f
  on f.product_feature_id in (it.product_feature_id, it.factor_product_feature_id)
where not exists (
  select 1 from product_feature_applicability a
  where a.product_id = it.product_id
    and a.product_feature_id = f.product_feature_id);

-- name: 3.4 — Data-quality check: feature pairs that are both dependent and incompatible (should be empty)
select f.description as feature, ff.description as factor, pr.name as product
from product_feature_interaction d
join product_feature_interaction x
  on x.product_feature_interaction_type_id = 'INCOMPATIBILITY'
 and ((x.product_feature_id = d.product_feature_id and x.factor_product_feature_id = d.factor_product_feature_id)
   or (x.product_feature_id = d.factor_product_feature_id and x.factor_product_feature_id = d.product_feature_id))
 and (x.product_id is not distinct from d.product_id or x.product_id is null or d.product_id is null)
join product_feature f  on f.product_feature_id  = d.product_feature_id
join product_feature ff on ff.product_feature_id = d.factor_product_feature_id
left join product pr    on pr.product_id = d.product_id
where d.product_feature_interaction_type_id = 'DEPENDENCY';

-- ============================================================
-- Fig 3.5 — Suppliers and manufacturers
-- ============================================================

-- name: 3.5 — Where can we buy the bond paper today? (best preference first)
select o.name as supplier, sp.preference_type_id as preference, sp.rating_type_id as rating,
       sp.standard_lead_time as lead_days, sp.comment
from supplier_product sp
join organization o on o.party_id = sp.supplier_party_id
where sp.product_id = 1
  and sp.available_from_date <= current_date
  and (sp.available_thru_date is null or sp.available_thru_date > current_date)
order by case sp.preference_type_id when 'FIRST_CHOICE' then 1 when 'SECOND_CHOICE' then 2 when 'LAST_RESORT' then 3 else 4 end,
         sp.standard_lead_time;

-- name: 3.5 — Who makes each product, and how many current suppliers it has
select pr.name as product, m.name as manufacturer,
       count(sp.supplier_product_id) as current_suppliers
from product pr
left join organization m on m.party_id = pr.manufacturer_party_id
left join supplier_product sp
  on sp.product_id = pr.product_id
 and sp.available_from_date <= current_date
 and (sp.available_thru_date is null or sp.available_thru_date > current_date)
group by pr.product_id, pr.name, m.name
order by pr.product_id;

-- name: 3.5 — Current reorder guidelines, with what each is based on
select pr.name as good, f.description as facility, gb.name as geographic_boundary,
       io.name as internal_organization, rg.reorder_level, rg.reorder_quantity, rg.from_date
from reorder_guideline rg
join product pr                   on pr.product_id = rg.product_id
left join facility f              on f.facility_id = rg.facility_id
left join geographic_boundary gb  on gb.geographic_boundary_id = rg.geographic_boundary_id
left join organization io         on io.party_id = rg.internal_organization_party_id
where rg.from_date <= current_date
  and (rg.thru_date is null or rg.thru_date > current_date)
order by pr.name, rg.from_date;

-- name: 3.5 — Data-quality check: supplying a product without a current SUPPLIER role (should be empty)
select o.name as organization, pr.name as product, sp.available_from_date
from supplier_product sp
join organization o on o.party_id = sp.supplier_party_id
join product pr     on pr.product_id = sp.product_id
where not exists (
  select 1 from party_role r
  where r.party_id = sp.supplier_party_id
    and r.role_type_id = 'SUPPLIER'
    and r.from_date <= current_date
    and (r.thru_date is null or r.thru_date > current_date));

-- name: 3.5 — Data-quality check: overlapping periods for the same product and supplier (should be empty)
select pr.name as product, o.name as supplier,
       a.available_from_date as a_from, a.available_thru_date as a_thru,
       b.available_from_date as b_from, b.available_thru_date as b_thru
from supplier_product a
join supplier_product b
  on b.product_id = a.product_id
 and b.supplier_party_id = a.supplier_party_id
 and b.supplier_product_id > a.supplier_product_id
 and a.available_from_date < coalesce(b.available_thru_date, 'infinity')
 and b.available_from_date < coalesce(a.available_thru_date, 'infinity')
join product pr     on pr.product_id = a.product_id
join organization o on o.party_id = a.supplier_party_id;

-- name: 3.5 — Data-quality check: reorder guideline "internal organization" without that role (should be empty)
select pr.name as good, o.name as organization
from reorder_guideline rg
join product pr     on pr.product_id = rg.product_id
join organization o on o.party_id = rg.internal_organization_party_id
where not exists (
  select 1 from party_role r
  where r.party_id = rg.internal_organization_party_id
    and r.role_type_id = 'INTERNAL_ORGANIZATION'
    and r.from_date <= current_date
    and (r.thru_date is null or r.thru_date > current_date));

-- name: 3.5 — Data-quality check: overlapping guidelines for the same good and basis (should be empty)
select pr.name as good, a.facility_id, a.geographic_boundary_id, a.internal_organization_party_id,
       a.from_date as a_from, b.from_date as b_from
from reorder_guideline a
join reorder_guideline b
  on b.product_id = a.product_id
 and b.reorder_guideline_id > a.reorder_guideline_id
 and b.facility_id                    is not distinct from a.facility_id
 and b.geographic_boundary_id         is not distinct from a.geographic_boundary_id
 and b.internal_organization_party_id is not distinct from a.internal_organization_party_id
 and a.from_date < coalesce(b.thru_date, 'infinity')
 and b.from_date < coalesce(a.thru_date, 'infinity')
join product pr on pr.product_id = a.product_id;

-- ============================================================
-- Fig 3.6 — Inventory items
-- ============================================================

-- name: 3.6 — Stock on hand per good and facility (items in a container count at the container's facility)
select pr.name as good, f.description as facility, i.inventory_item_status_type_id as status,
       sum(case i.inventory_item_kind when 'SERIALIZED' then 1 else i.quantity_on_hand end) as on_hand
from inventory_item i
left join container c on c.container_id = i.container_id
join facility f       on f.facility_id = coalesce(i.facility_id, c.facility_id)
join product pr       on pr.product_id = i.product_id
group by pr.name, f.description, i.inventory_item_status_type_id
order by pr.name, f.description, status;

-- name: 3.6 — What should we reorder? (sellable stock at a facility vs that facility's current guideline)
with stock as (
  select i.product_id, coalesce(i.facility_id, c.facility_id) as facility_id,
         sum(case i.inventory_item_kind when 'SERIALIZED' then 1 else i.quantity_on_hand end) as on_hand
  from inventory_item i
  left join container c on c.container_id = i.container_id
  where i.inventory_item_status_type_id = 'GOOD'
  group by i.product_id, coalesce(i.facility_id, c.facility_id)
)
select pr.name as good, f.description as facility, coalesce(s.on_hand, 0) as on_hand,
       rg.reorder_level, rg.reorder_quantity,
       coalesce(s.on_hand, 0) <= rg.reorder_level as reorder_now
from reorder_guideline rg
join product pr     on pr.product_id = rg.product_id
join facility f     on f.facility_id = rg.facility_id
left join stock s   on s.product_id = rg.product_id and s.facility_id = rg.facility_id
where rg.from_date <= current_date
  and (rg.thru_date is null or rg.thru_date > current_date)
order by reorder_now desc, pr.name;

-- name: 3.6 — Stock from expired lots
select pr.name as good, l.lot_id, l.expiration_date, i.quantity_on_hand
from inventory_item i
join lot l      on l.lot_id = i.lot_id
join product pr on pr.product_id = i.product_id
where l.expiration_date <= current_date;

-- name: 3.6 — Variances from the last physical count, net per item
select pr.name as good, v.physical_inventory_date, sum(v.quantity) as net_adjustment,
       string_agg(v.reason_id, ', ' order by v.reason_id) as reasons
from inventory_item_variance v
join inventory_item i on i.inventory_item_id = v.inventory_item_id
join product pr       on pr.product_id = i.product_id
group by pr.name, v.inventory_item_id, v.physical_inventory_date
order by v.physical_inventory_date, pr.name;

-- name: 3.6 — Data-quality check: kind vs serial_num / quantity_on_hand (should be empty)
select inventory_item_id, inventory_item_kind, serial_num, quantity_on_hand
from inventory_item
where (inventory_item_kind = 'SERIALIZED'     and (serial_num is null or quantity_on_hand is not null))
   or (inventory_item_kind = 'NON_SERIALIZED' and (quantity_on_hand is null or serial_num is not null));

-- name: 3.6 — Data-quality check: one serial number on two items of the same good (should be empty)
select pr.name as good, i.serial_num, string_agg(i.inventory_item_id::text, ', ') as items
from inventory_item i
join product pr on pr.product_id = i.product_id
where i.serial_num is not null
group by pr.name, i.product_id, i.serial_num
having count(*) > 1;

-- name: 3.6 — Data-quality check: lots that expire before they were created (should be empty)
select lot_id, creation_date, expiration_date
from lot
where expiration_date < creation_date;

-- name: 3.6 — Data-quality check: two variances for one item on the same count date (should be empty)
select inventory_item_id, physical_inventory_date, count(*) as variances
from inventory_item_variance
group by inventory_item_id, physical_inventory_date
having count(*) > 1;

-- ============================================================
-- Fig 3.7 — Standard product pricing
-- ============================================================

-- name: 3.7 — Price list today: every current price component, with what it is based on
select pc.price_component_id as id, t.description as component, pc.charge_kind,
       coalesce(pr.name, '(any product)') as product, pf.description as feature,
       case when pc.price is not null then pc.price || ' ' || pc.currency_uom_id else pc.percent || '%' end
         || coalesce(' per ' || coalesce(pc.quantity || ' ', '') || u.abbreviation, '') as amount,
       concat_ws(', ',
         'in ' || gb.name,
         'party type ' || pt.description,
         'category ' || cat.description,
         'qty ' || qb.from_quantity || coalesce(' to <' || qb.thru_quantity, '+'),
         'order ' || ov.from_amount || coalesce(' to <' || ov.thru_amount, '+'),
         'sale ' || st.description) as based_on
from price_component pc
join price_component_type t      on t.price_component_type_id = pc.price_component_type_id
left join product pr             on pr.product_id = pc.product_id
left join product_feature pf     on pf.product_feature_id = pc.product_feature_id
left join unit_of_measure u      on u.uom_id = pc.per_uom_id
left join geographic_boundary gb on gb.geographic_boundary_id = pc.geographic_boundary_id
left join party_type pt          on pt.party_type_id = pc.party_type_id
left join product_category cat   on cat.product_category_id = pc.product_category_id
left join quantity_break qb      on qb.quantity_break_id = pc.quantity_break_id
left join order_value ov         on ov.order_value_id = pc.order_value_id
left join sale_type st           on st.sale_type_id = pc.sale_type_id
where pc.from_date <= current_date
  and (pc.thru_date is null or pc.thru_date > current_date)
order by pc.product_id nulls last, pc.price_component_id;

-- name: 3.7 — Price a line: 250 reams of bond paper for Contoso, shipped to Springfield, in a 9,500 USD internet order, today
-- Our rules (the figure stores components; combining them is the application's
-- job): the most specific applicable base price wins (most conditions met,
-- then the lowest); percents apply to that base; amounts are per unit.
-- The manufacturer's suggested price is information, not part of the price.
with params as (
  select 1 as product_id, 250::numeric as quantity, 5 as customer_party_id, 13 as ship_to_geo_id,
         9500::numeric as order_amount, 'INTERNET'::text as sale_type_id, 'USD'::text as currency,
         current_date as on_date
),
customer_type as (     -- the customer's current classifications (Ch 2)
  select c.party_type_id
  from party_classification c, params p
  where c.party_id = p.customer_party_id
    and c.from_date <= p.on_date and (c.thru_date is null or c.thru_date > p.on_date)
),
product_cat as (       -- the product's current categories and every category above them
  select c.product_category_id
  from product_category_classification c, params p
  where c.product_id = p.product_id
    and c.from_date <= p.on_date and (c.thru_date is null or c.thru_date > p.on_date)
  union
  select a.ancestor_id
  from product_category_classification c
  join product_category_ancestor a on a.product_category_id = c.product_category_id, params p
  where c.product_id = p.product_id
    and c.from_date <= p.on_date and (c.thru_date is null or c.thru_date > p.on_date)
),
applicable as (        -- every condition is either null (any) or met
  select pc.*
  from price_component pc, params p
  where pc.price_component_type_id <> 'MSRP'
    and pc.from_date <= p.on_date and (pc.thru_date is null or pc.thru_date > p.on_date)
    and (pc.product_id is null or pc.product_id = p.product_id)
    and pc.product_feature_id is null                       -- no features chosen on this line
    and (pc.currency_uom_id is null or pc.currency_uom_id = p.currency)
    and (pc.geographic_boundary_id is null or pc.geographic_boundary_id in
          (select ancestor_id from geographic_boundary_ancestor where geographic_boundary_id = p.ship_to_geo_id))
    and (pc.party_type_id is null or pc.party_type_id in (select party_type_id from customer_type))
    and (pc.product_category_id is null or pc.product_category_id in (select product_category_id from product_cat))
    and (pc.quantity_break_id is null or exists (
          select 1 from quantity_break q
          where q.quantity_break_id = pc.quantity_break_id
            and q.from_quantity <= p.quantity and (q.thru_quantity is null or q.thru_quantity > p.quantity)))
    and (pc.order_value_id is null or exists (
          select 1 from order_value o
          where o.order_value_id = pc.order_value_id
            and o.from_amount <= p.order_amount and (o.thru_amount is null or o.thru_amount > p.order_amount)))
    and (pc.sale_type_id is null or pc.sale_type_id = p.sale_type_id)
),
base as (
  select price_component_id, price
  from applicable
  where price_component_type_id = 'BASE_PRICE'
  order by num_nonnulls(geographic_boundary_id, party_type_id, product_category_id,
                        quantity_break_id, order_value_id, sale_type_id) desc, price
  limit 1
),
effect as (
  select a.price_component_id, a.price_component_type_id, a.comment,
         case when a.price is not null then a.price || ' ' || a.currency_uom_id else a.percent || '%' end as amount,
         case a.price_component_type_id
           when 'BASE_PRICE' then case when a.price_component_id = b.price_component_id then a.price end
           when 'DISCOUNT'   then -coalesce(a.price, round(b.price * a.percent / 100, 2))
           when 'SURCHARGE'  then  coalesce(a.price, round(b.price * a.percent / 100, 2))
         end as unit_effect
  from applicable a cross join base b
)
select component, rule, amount, unit_effect
from (
  select 1 as seq, price_component_id,
         price_component_type_id || case when price_component_type_id = 'BASE_PRICE' and unit_effect is null
                                         then ' (not used)' else '' end as component,
         comment as rule, amount, unit_effect
  from effect
  union all
  select 2, null, 'UNIT PRICE', null, null, sum(unit_effect) from effect
  union all
  select 3, null, 'LINE TOTAL', null, null, sum(unit_effect) * (select quantity from params) from effect
) lines
order by seq, price_component_id;

-- name: 3.7 — Services: what each one charges, and per what
select pr.name as service, coalesce(pc.charge_kind, '(none)') as charge_kind,
       pc.price || ' ' || pc.currency_uom_id
         || coalesce(' per ' || coalesce(pc.quantity || ' ', '') || u.abbreviation, '') as charge,
       pc.comment
from price_component pc
join product pr         on pr.product_id = pc.product_id
left join unit_of_measure u on u.uom_id = pc.per_uom_id
where pr.product_kind = 'SERVICE'
  and pc.from_date <= current_date
  and (pc.thru_date is null or pc.thru_date > current_date)
order by pr.name, pc.charge_kind;

-- name: 3.7 — Our list price vs the manufacturer's suggested price, today
select pr.name as product, b.price as our_price, m.price as suggested, o.name as suggested_by,
       round(100 * (m.price - b.price) / m.price, 1) as pct_below_suggested
from price_component m
join product pr      on pr.product_id = m.product_id
join organization o  on o.party_id = m.pricer_party_id
join price_component b
  on b.product_id = m.product_id
 and b.price_component_type_id = 'BASE_PRICE'
 and b.product_feature_id is null
 and b.currency_uom_id = m.currency_uom_id
 and num_nonnulls(b.geographic_boundary_id, b.party_type_id, b.product_category_id,
                  b.quantity_break_id, b.order_value_id, b.sale_type_id) = 0   -- the unconditional list price
 and b.from_date <= current_date and (b.thru_date is null or b.thru_date > current_date)
where m.price_component_type_id = 'MSRP'
  and m.from_date <= current_date and (m.thru_date is null or m.thru_date > current_date);

-- name: 3.7 — Bond paper's list price over time
select from_date, thru_date, price, currency_uom_id, comment
from price_component
where product_id = 1
  and price_component_type_id = 'BASE_PRICE'
  and geographic_boundary_id is null
order by from_date;

-- name: 3.7 — Data-quality check: amount vs percent for each component type (should be empty)
select price_component_id, price_component_type_id, price, percent, currency_uom_id, problem
from (
  select pc.*,
         case
           when price_component_type_id in ('BASE_PRICE', 'MSRP') and (price is null or percent is not null)
             then 'needs an amount, not a percent'
           when price_component_type_id in ('DISCOUNT', 'SURCHARGE') and num_nonnulls(price, percent) <> 1
             then 'needs an amount or a percent, not both'
           when price is not null and currency_uom_id is null then 'an amount without a currency'
           when price is null and currency_uom_id is not null then 'a currency without an amount'
         end as problem
  from price_component pc
) x
where problem is not null;

-- name: 3.7 — Data-quality check: charge kind vs its "per" unit and quantity (should be empty)
select pc.price_component_id, pc.charge_kind, pc.per_uom_id, pc.quantity
from price_component pc
where (pc.charge_kind = 'RECURRING'
       and (pc.quantity is not null
            or not exists (select 1 from time_frequency_measure t where t.uom_id = pc.per_uom_id)))
   or (pc.charge_kind = 'UTILIZATION' and pc.per_uom_id is null)
   or (pc.charge_kind is distinct from 'RECURRING' and pc.charge_kind is distinct from 'UTILIZATION'
       and (pc.per_uom_id is not null or pc.quantity is not null));

-- name: 3.7 — Data-quality check: two components of the same type, same conditions, overlapping periods (should be empty)
select a.price_component_id as a_id, b.price_component_id as b_id, a.price_component_type_id,
       pr.name as product, a.price as a_price, b.price as b_price, a.from_date as a_from, b.from_date as b_from
from price_component a
join price_component b
  on b.price_component_id > a.price_component_id
 and b.price_component_type_id = a.price_component_type_id
 and b.charge_kind            is not distinct from a.charge_kind
 and b.product_id             is not distinct from a.product_id
 and b.product_feature_id     is not distinct from a.product_feature_id
 and b.currency_uom_id        is not distinct from a.currency_uom_id
 and b.per_uom_id             is not distinct from a.per_uom_id
 and b.geographic_boundary_id is not distinct from a.geographic_boundary_id
 and b.party_type_id          is not distinct from a.party_type_id
 and b.product_category_id    is not distinct from a.product_category_id
 and b.quantity_break_id      is not distinct from a.quantity_break_id
 and b.order_value_id         is not distinct from a.order_value_id
 and b.sale_type_id           is not distinct from a.sale_type_id
 and a.from_date < coalesce(b.thru_date, 'infinity')
 and b.from_date < coalesce(a.thru_date, 'infinity')
left join product pr on pr.product_id = a.product_id;

-- ============================================================
-- Fig 3.8 — Estimated product cost
-- ============================================================

-- name: 3.8 — Estimated unit cost today, split into materials / labor / other (general estimates only)
with recursive up (cost_component_type_id, subtype) as (   -- each type with its top-level type
  select cost_component_type_id, cost_component_type_id from cost_component_type where parent_type_id is null
  union all
  select t.cost_component_type_id, u.subtype
  from cost_component_type t
  join up u on t.parent_type_id = u.cost_component_type_id
)
select coalesce(pr.name, 'feature: ' || pf.description) as costed,
       sum(e.cost) filter (where u.subtype = 'MATERIALS') as materials,
       sum(e.cost) filter (where u.subtype = 'LABOR')     as labor,
       sum(e.cost) filter (where u.subtype = 'OTHER')     as other,
       sum(e.cost)                                        as total
from estimated_product_cost e
join up u                    on u.cost_component_type_id = e.cost_component_type_id
left join product pr         on pr.product_id = e.product_id
left join product_feature pf on pf.product_feature_id = e.product_feature_id
where e.geographic_boundary_id is null and e.organization_party_id is null
  and e.from_date <= current_date and (e.thru_date is null or e.thru_date > current_date)
group by pr.name, pf.description
order by costed;

-- name: 3.8 — The insurance forms printed in Mexico: each cost component, using the Mexican estimate where there is one
with candidate as (
  select e.*,
         row_number() over (partition by e.cost_component_type_id
                            order by (e.geographic_boundary_id is not null) desc, e.estimated_product_cost_id) as pick
  from estimated_product_cost e
  where e.product_id = 4
    and (e.geographic_boundary_id is null or e.geographic_boundary_id = 1)
    and e.organization_party_id is null
    and e.from_date <= current_date and (e.thru_date is null or e.thru_date > current_date)
)
select t.description as cost_component, c.cost,
       case when c.geographic_boundary_id is null then 'general' else 'Mexico' end as estimate
from candidate c
join cost_component_type t on t.cost_component_type_id = c.cost_component_type_id
where c.pick = 1
union all
select 'TOTAL', sum(cost), null from candidate where pick = 1;

-- name: 3.8 — Margin today: list price (Fig 3.7) vs estimated cost
with cost as (
  select product_id, product_feature_id, sum(cost) as cost
  from estimated_product_cost
  where geographic_boundary_id is null and organization_party_id is null
    and from_date <= current_date and (thru_date is null or thru_date > current_date)
  group by product_id, product_feature_id
),
list_price as (        -- unconditional current base prices in USD
  select product_id, product_feature_id, price
  from price_component
  where price_component_type_id = 'BASE_PRICE' and charge_kind is distinct from 'ONE_TIME'
    and currency_uom_id = 'USD'
    and num_nonnulls(geographic_boundary_id, party_type_id, product_category_id,
                     quantity_break_id, order_value_id, sale_type_id) = 0
    and from_date <= current_date and (thru_date is null or thru_date > current_date)
)
select coalesce(pr.name, 'feature: ' || pf.description) as costed, p.price, c.cost,
       p.price - c.cost as margin, round(100 * (p.price - c.cost) / p.price, 1) as margin_pct
from cost c
left join list_price p
  on (c.product_id is not null and p.product_id = c.product_id and p.product_feature_id is null)
  or (c.product_feature_id is not null and p.product_feature_id = c.product_feature_id)
left join product pr         on pr.product_id = c.product_id
left join product_feature pf on pf.product_feature_id = c.product_feature_id
order by costed;

-- name: 3.8 — Data-quality check: cost types that don't roll up to materials, labor or other (should be empty)
with recursive up (cost_component_type_id, subtype) as (
  select cost_component_type_id, cost_component_type_id from cost_component_type where parent_type_id is null
  union all
  select t.cost_component_type_id, u.subtype
  from cost_component_type t
  join up u on t.parent_type_id = u.cost_component_type_id
)
select u.cost_component_type_id, u.subtype as top_level,
       (select count(*) from estimated_product_cost e where e.cost_component_type_id = u.cost_component_type_id) as estimates
from up u
where u.subtype not in ('MATERIALS', 'LABOR', 'OTHER');

-- name: 3.8 — Data-quality check: two estimates for the same thing, type and scope in overlapping periods (should be empty)
select a.estimated_product_cost_id as a_id, b.estimated_product_cost_id as b_id,
       coalesce(pr.name, pf.description) as costed, a.cost_component_type_id,
       a.cost as a_cost, b.cost as b_cost, a.from_date as a_from, b.from_date as b_from
from estimated_product_cost a
join estimated_product_cost b
  on b.estimated_product_cost_id > a.estimated_product_cost_id
 and b.product_id             is not distinct from a.product_id
 and b.product_feature_id     is not distinct from a.product_feature_id
 and b.cost_component_type_id = a.cost_component_type_id
 and b.geographic_boundary_id is not distinct from a.geographic_boundary_id
 and b.organization_party_id  is not distinct from a.organization_party_id
 and a.from_date < coalesce(b.thru_date, 'infinity')
 and b.from_date < coalesce(a.thru_date, 'infinity')
left join product pr         on pr.product_id = a.product_id
left join product_feature pf on pf.product_feature_id = a.product_feature_id;

-- ============================================================
-- Fig 3.9b — Product to product associations
-- ============================================================

-- name: 3.9 — Every current association, read as a sentence
select a.product_association_type_id as type,
       case a.product_association_type_id
         when 'MARKETING_PACKAGE' then f.name || ' includes ' || coalesce(a.quantity_used, 1) || ' × ' || t.name
         when 'SUBSTITUTE'        then t.name || ' can replace ' || f.name || coalesce(' (' || a.quantity || ' for 1)', '')
         when 'OBSOLESCENCE'      then f.name || ' was superseded by ' || t.name || ' on ' || a.from_date
         when 'COMPLEMENT'        then f.name || ' goes well with ' || t.name
         when 'INCOMPATIBILITY'   then f.name || ' doesn''t work with ' || t.name
       end as sentence,
       a.reason
from product_association a
join product f on f.product_id = a.from_product_id
join product t on t.product_id = a.to_product_id
where a.from_date <= current_date and (a.thru_date is null or a.thru_date > current_date)
order by a.product_association_type_id, a.product_association_id;

-- name: 3.9 — Out of bond paper: what can replace it, and how much of each substitute is in stock
select s.name as substitute, a.quantity as needed_per_ream,
       coalesce(sum(case i.inventory_item_kind when 'SERIALIZED' then 1 else i.quantity_on_hand end), 0) as sellable_on_hand
from product_association a
join product s              on s.product_id = a.to_product_id
left join inventory_item i  on i.product_id = s.product_id and i.inventory_item_status_type_id = 'GOOD'
where a.product_association_type_id = 'SUBSTITUTE'
  and a.from_product_id = 1
  and a.from_date <= current_date and (a.thru_date is null or a.thru_date > current_date)
group by s.name, a.quantity;

-- name: 3.9 — Selling a copier: what to offer with it, and what must not go with it (incompatibility counts both ways)
select 'offer' as advice, t.name as product, a.reason
from product_association a
join product t on t.product_id = a.to_product_id
where a.product_association_type_id = 'COMPLEMENT' and a.from_product_id = 6
  and (a.thru_date is null or a.thru_date > current_date)
union all
select 'never with', p.name, a.reason
from product_association a
join product p on p.product_id = case when a.from_product_id = 6 then a.to_product_id else a.from_product_id end
where a.product_association_type_id = 'INCOMPATIBILITY' and 6 in (a.from_product_id, a.to_product_id)
  and (a.thru_date is null or a.thru_date > current_date)
order by advice desc, product;

-- name: 3.9 — What's in the office starter kit, at today's list prices (Fig 3.7)
select t.name as product, a.quantity_used, lp.price as list_price, a.quantity_used * lp.price as line_value
from product_association a
join product t on t.product_id = a.to_product_id
left join lateral (
  select pc.price
  from price_component pc
  where pc.product_id = a.to_product_id
    and pc.price_component_type_id = 'BASE_PRICE' and pc.product_feature_id is null
    and pc.currency_uom_id = 'USD'
    and num_nonnulls(pc.geographic_boundary_id, pc.party_type_id, pc.product_category_id,
                     pc.quantity_break_id, pc.order_value_id, pc.sale_type_id) = 0
    and pc.from_date <= current_date and (pc.thru_date is null or pc.thru_date > current_date)
  order by pc.from_date desc
  limit 1
) lp on true
where a.product_association_type_id = 'MARKETING_PACKAGE' and a.from_product_id = 11
  and a.from_date <= current_date and (a.thru_date is null or a.thru_date > current_date)
order by t.name;

-- name: 3.9 — Data-quality check: package and substitute attributes on the wrong type (should be empty)
select product_association_id, product_association_type_id, quantity_used, instruction, quantity
from product_association
where (product_association_type_id <> 'MARKETING_PACKAGE' and (quantity_used is not null or instruction is not null))
   or (product_association_type_id <> 'SUBSTITUTE' and quantity is not null);

-- name: 3.9 — Data-quality check: two products that are complements and incompatible at once, either way round (should be empty)
select f.name as product_a, t.name as product_b, c.from_date as complement_from, i.from_date as incompatible_from
from product_association c
join product_association i
  on i.product_association_type_id = 'INCOMPATIBILITY'
 and ((i.from_product_id = c.from_product_id and i.to_product_id = c.to_product_id)
   or (i.from_product_id = c.to_product_id and i.to_product_id = c.from_product_id))
 and c.from_date < coalesce(i.thru_date, 'infinity')
 and i.from_date < coalesce(c.thru_date, 'infinity')
join product f on f.product_id = c.from_product_id
join product t on t.product_id = c.to_product_id
where c.product_association_type_id = 'COMPLEMENT';

-- name: 3.9 — Data-quality check: the same association twice in overlapping periods (should be empty)
select a.product_association_id as a_id, b.product_association_id as b_id, a.product_association_type_id,
       f.name as from_product, t.name as to_product, a.from_date as a_from, b.from_date as b_from
from product_association a
join product_association b
  on b.product_association_id > a.product_association_id
 and b.product_association_type_id = a.product_association_type_id
 and b.from_product_id = a.from_product_id
 and b.to_product_id   = a.to_product_id
 and a.from_date < coalesce(b.thru_date, 'infinity')
 and b.from_date < coalesce(a.thru_date, 'infinity')
join product f on f.product_id = a.from_product_id
join product t on t.product_id = a.to_product_id;
