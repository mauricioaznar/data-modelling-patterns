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
