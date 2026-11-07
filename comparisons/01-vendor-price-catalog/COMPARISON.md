# Vendor Price Catalog vs this repo's Silverston (Vol 1)

Drafted 2026-11-05. The service is described in [SOURCE.md](SOURCE.md); Silverston means only
what this repo builds (see the [comparisons rules](../README.md)).

**Citations.** `C2:40` means line 40 of that chapter's `schema.sql`:
[C2](../../volumes/v1-all-enterprises/02-people-and-organizations/schema.sql) ·
[C3](../../volumes/v1-all-enterprises/03-products/schema.sql) ·
[C4](../../volumes/v1-all-enterprises/04-ordering-products/schema.sql) ·
[C5](../../volumes/v1-all-enterprises/05-shipments/schema.sql) ·
[C6](../../volumes/v1-all-enterprises/06-work-effort/schema.sql) ·
[C7](../../volumes/v1-all-enterprises/07-invoicing/schema.sql) ·
[C8](../../volumes/v1-all-enterprises/08-accounting-and-budgeting/schema.sql).
`N3` is Ch 3's [NOTES.md](../../volumes/v1-all-enterprises/03-products/NOTES.md).

## The verdict in five lines

1. **VPC's row is a price for a combination; Silverston's row is a rule that gets
   added up.** A VPC price is a cell in a matrix (haul × produced water × vacuum ×
   area 8 = 300 a load). A price component (C3:425) prices *one* product and/or *one*
   feature, and the line's price is computed by adding components. That's the main
   structural difference, and Silverston (as built here) can't hold a combination rate.
2. **The best home for a vendor price sheet is Ch 4, not Ch 3:** a PURCHASE_AGREEMENT
   with a pricing-program item, whose price components hang on it (C4:648, C4:656), with
   organization and geographic applicability as its scope (C4:594, C4:606).
3. **VPC is richer on the price's own life:** draft → approval, family and version,
   Any vs blank, evidence snapshots, audit. The repo has dated rows and nothing else.
4. **Silverston is richer on what a price *is*:** typed components (base, discount,
   surcharge), currency, quantity and order-value breaks, recurring vs per-use charges,
   unit conversions, costs, and the billing links that would make invoices explainable.
5. **The proposed price model is product feature applicability (C3:206) under another name.**

## 1. Inventory: the repo's entities that matter for pricing

| Area | Entity (table) | Where | What it holds |
|---|---|---|---|
| Parties | PARTY, ORGANIZATION | C2:19, C2:62 | Who; vendors and internal orgs are organizations |
| | PARTY TYPE + CLASSIFICATION | C2:208, C2:215 | Kinds of party (hierarchy); a price can be based on one |
| | ROLE TYPE + PARTY ROLE | C2:256, C2:263 | Supplier, internal organization, … |
| | PARTY RELATIONSHIP | C2:329 | Org rollups (division → department), customer/supplier relationships |
| Places | GEOGRAPHIC BOUNDARY (+ type, association) | C2:40, C2:35, C2:400 | Typed, nestable regions; a price can be based on one |
| | FACILITY | C2:536 | A physical place (a yard, a disposal well) |
| Status | STATUS TYPE | C2:370 | Shared status list used by the status histories |
| Products | PRODUCT (GOOD or SERVICE) | C3:25 | The catalogue idea; services are products too |
| | PRODUCT CATEGORY (+ rollup, classification) | C3:54, C3:60, C3:69 | A hierarchy of groups; a product in many, dated |
| | IDENTIFICATION TYPE, GOOD IDENTIFICATION | C3:128, C3:137 | Codes for a good (SKU, UPC, a supplier's code) |
| | UNIT OF MEASURE (+ conversion) | C3:153, C3:162 | Units and factors between them |
| | PRODUCT FEATURE (+ type, category) | C3:190, C3:185, C3:176 | Typed values (colour, size, a DIMENSION with a number and unit) |
| | PRODUCT FEATURE APPLICABILITY | C3:206 | Which features a product takes: required, standard, optional, selectable; dated |
| | PRODUCT FEATURE INTERACTION | C3:224 | Dependency / incompatibility between features, optionally per product |
| | SUPPLIER PRODUCT | C3:259 | Who can supply what, lead time, preference; **no price** |
| Pricing | PRICE COMPONENT (+ type) | C3:425, C3:403 | Dated rule: price or percent, for a product/feature, based on optional conditions |
| | QUANTITY BREAK, ORDER VALUE, SALE TYPE | C3:381, C3:389, C3:396 | Condition bands |
| | TIME FREQUENCY / CURRENCY MEASURE | C3:371, C3:375 | Units for "per month" and "in USD" |
| | ESTIMATED PRODUCT COST (+ cost component type) | C3:475, C3:465 | Dated cost components, by place or org |
| | PRODUCT ASSOCIATION | C3:516 | Package/component, substitute, complement, … |
| Agreements | AGREEMENT, AGREEMENT ITEM | C4:529, C4:568 | Typed contracts (PURCHASE_AGREEMENT in seed) in numbered parts |
| | Organization / product / geographical applicability | C4:594, C4:600, C4:606 | What an agreement item is limited to |
| | AGREEMENT PRICING PROGRAM + `price_component.agreement_item_id` | C4:648, C4:656 | Prices agreed under a contract |
| | `order_item_agreement_item` view | C4:670 | Derives which agreement items govern an order line |
| Transactions | QUOTE ITEM | C4:471 | A party's offered unit price for a product or work effort |
| | ORDER ITEM | C4:35 | A line with an agreed `unit_price` snapshot; `ordered_for` another line |
| | ORDER ADJUSTMENT | C4:223 | Discounts, surcharges, fees on an order or line |
| Work | WORK EFFORT TYPE, WORK EFFORT | C2:637, C2:642 | Kinds of work and the work done |
| | TIME ENTRY | C6:221 | Hours recorded against work |
| | RATE TYPE, POSITION TYPE RATE, PARTY RATE, ASSIGNMENT RATE | C6:253, C6:264, C6:274, C6:285 | Labour rates at three levels, most specific wins |
| | FIXED ASSET (+ type) | C5:291, C5:286 | Trucks, tanks, equipment as owned assets |
| | WORK EFFORT FIXED ASSET STANDARD | C6:402 | Which asset types a kind of work needs |
| Billing | INVOICE, INVOICE ITEM (+ type) | C7:13, C7:44, C7:25 | Lines for a product, feature or item; `sold_with`, `adjustment_for` |
| | SHIPMENT ITEM / TIME ENTRY / WORK EFFORT / ORDER ITEM BILLING | C7:185, C7:199, C7:205, C7:221 | What each invoice line bills |
| Accounting | GL ACCOUNT, ORGANIZATION GL ACCOUNT | C8:19, C8:28 | Chart of accounts per internal org |

## 2. Mapping

Quality: **direct** · **partial** · **structural** (same idea, different shape) · **none**.

### A. `attribute_definitions`

| VPC | Repo | Quality | Notes |
|---|---|---|---|
| An attribute (`key`, `label`) | PRODUCT FEATURE TYPE (C3:185) for product-describing keys (material, truckType, waterCondition…); the `based on` **columns** of PRICE COMPONENT (C3:425) for scope keys (area → `geographic_boundary_id`) | structural | Silverston fixes the questions in the schema: each condition is a column, each feature kind a type row. VPC makes them data. VPC is more extensible, the repo more checkable (FKs). |
| `valueType` picklist | PRODUCT FEATURE rows of a type (C3:190) | partial | A feature type + its features ≈ an attribute + its picklist. |
| `valueType` decimal (percentActive, packageQuantity) | A DIMENSION feature: `number_specified` + `uom_id` (C3:190) | partial | But each number is its own feature row (40 %, 60 %…), not a free value on the price. |
| `valueType` boolean / text | — | none | |
| `picklistKey` | `product_feature.product_feature_type_id` (C3:190) | partial | The direction is reversed: a value names its type; VPC's attribute names its list. |
| `canConstrainPrice` | — | none | In the repo any feature can be priced (`price_component.product_feature_id`), and only the drawn conditions can scope a price. |

### B. `picklist_values` (the catalog)

| VPC | Repo | Quality | Notes |
|---|---|---|---|
| One table for every list | One table per kind (`*_type` lookups, PRODUCT, FEATURE, BOUNDARY, ORGANIZATION…) | structural | The repo's convention is the opposite: lookup tables, not one generic list. |
| UUID identity + readable `code` | Text code as PK on type tables (e.g. C3:185); integer surrogate on entity tables | partial | VPC separates identity from code; the repo's type codes *are* the identity. |
| `status` active / deprecated | Dated validity: `product.sales_discontinuation_date` (C3:25), thru dates on applicability (C3:206) and classification (C3:69) | structural | The repo says *when* a thing stopped being valid; VPC only says *that* it did. Neither deletes. |
| `reviewStatus` provisional / approved | — | none | No approval of catalog entries in the repo. |
| `properties` JSONB + `propertiesSchema` | Columns and subtype tables | structural | The repo has no schema-as-data. |
| `source_refs` provenance; no crosswalk | GOOD IDENTIFICATION (C3:137) **is** a crosswalk (codes by identification type) | structural | A deliberate opposite: Silverston keeps other systems' codes, VPC refuses to. |
| **activities** (haul, dispose, rent, labor…) | PRODUCT of kind SERVICE (C3:25); the work itself is a WORK EFFORT TYPE (C2:637) | partial | The repo splits "what is bought" (product) from "what is done" (work type). VPC's activity plays both. *Rent* has no home: no rental model in this repo. |
| activities `priceAttributes` | PRODUCT FEATURE APPLICABILITY (C3:206) | partial | Same idea one level apart: VPC says which *keys* an activity takes, Silverston which *values* a product takes. Area and department aren't features in the repo; they're price conditions. |
| activities `chargeKind` standalone / add_on | `order_item.ordered_for_order_item_id` (C4:35), `invoice_item.sold_with_invoice_item_id` (C7:44), SURCHARGE price type (C3:403) | partial | Silverston ties the *line* to its main line, not the activity. ⚠ The repo's `price_component.charge_kind` (one-time / recurring / utilization) is a different axis with the same name. |
| truck_types, equipment `activities` | PRODUCT FEATURE APPLICABILITY (as features of a service), or WORK EFFORT FIXED ASSET STANDARD (C6:402, asset types a kind of work needs) | partial | Depends on whether a truck type is something you pay for (feature) or something the work uses (asset). See open questions. |
| material_types | PRODUCT CATEGORY (C3:54) via CLASSIFICATION (C3:69) | partial | Categories nest (C3:60); material types don't. |
| material_types `attributes` | — | none | A category in the repo gives its products no fixed attributes. |
| materials | PRODUCT of kind GOOD (C3:25) / GOOD (C3:124) | direct | |
| materials `attributeValues` (waterSource: produced) | Features applied to the product (C3:206, STANDARD) | partial | |
| areas | GEOGRAPHIC BOUNDARY of a territory type (C2:40) | direct | |
| areas `division` | GEOGRAPHIC BOUNDARY ASSOCIATION (C2:400), if a division is a region; PARTY RELATIONSHIP (C2:329), if it's an org unit | partial | Open question. |
| divisions, departments | ORGANIZATION with an internal-organization role (C2:62, C2:263), rolled up by PARTY RELATIONSHIP (C2:329) | direct | |
| labor_roles | POSITION TYPE (C6:259), priced by POSITION TYPE RATE (C6:264) | partial | The repo's rates are the enterprise's own (billing or pay), not a vendor's. |
| billing_units | UNIT OF MEASURE (C3:153) | direct | |
| billing_units `dimension` | Only the two UOM subtypes, time frequency and currency (C3:371, C3:375) | partial | VPC classifies every unit; the repo instead has **conversions** (C3:162), which VPC lacks. |
| service_types | PRODUCT CATEGORY (C3:54) or WORK EFFORT TYPE (C2:637) | partial | |
| water_sources, water_uses, water_conditions, solvent_bases, treating_applications, fluid_bases | PRODUCT FEATURE rows, one feature type each (C3:190, C3:185) | direct | The cleanest fit in the catalog. |
| frac_tank_types | PRODUCT FEATURE of the rental, or FIXED ASSET TYPE (C5:286) | partial | |

### C. `vendor_price` (one row per price version)

| VPC | Repo | Quality | Notes |
|---|---|---|---|
| The row itself | PRICE COMPONENT (C3:425), under an AGREEMENT PRICING PROGRAM (C4:648, C4:656) | structural | See §3.1. |
| `id`, `family_id`, `version_number` | Successive dated PRICE COMPONENT rows | structural | No family or version: a new price is a new row with new dates, and nothing says which older row it replaces. The repo's nearest versioning is BUDGET REVISION (C8:288), not used for prices. |
| `status` draft → approved, superseded | — on prices; status histories exist elsewhere (`invoice_status` C7:157, `order_status`, all on STATUS TYPE C2:370) | none | The repo's pattern would be a PRICE COMPONENT STATUS history; not in this repo. *Superseded* is implicit in a thru date. |
| `archived` | — | none | The repo ends things with a thru date. |
| `scope.vendorId` | `price_component.pricer_party_id` → ORGANIZATION (C3:425); better, the AGREEMENT's supplier through AGREEMENT ROLE (C4:549) | partial | "Pricer" in the repo is our reading (N3, Fig 3.7 decisions): whoever sets the price. |
| `scope.vendorLocationId` | FACILITY (C2:536) or a postal address | none | A price component has no location of the pricer. |
| `scope.divisionIds`, `departments` | AGREEMENT ORGANIZATION APPLICABILITY (C4:594) | direct | Many orgs per agreement item, as VPC's arrays. |
| `scope.areas` (+ area's division must be in scope) | `price_component.geographic_boundary_id` (one) or AGREEMENT GEOGRAPHICAL APPLICABILITY (C4:606, many) | direct | The consistency rule (area within division) has no repo equivalent. |
| effective dates | `from_date` / `thru_date` on PRICE COMPONENT and AGREEMENT | direct | The repo's thru date is exclusive. |
| `price_constraints` | `product_id`, `product_feature_id` + the `based on` columns of PRICE COMPONENT | structural | §3.1: one product + one feature + fixed conditions vs any number of keys. |
| `unconstrained_keys` ("Any") | `null` = any on every condition column (comment at C3:425); "none of a kind = no limit" on agreement applicability | partial | Silverston's null can't tell **Any** from **not answered**. VPC is more expressive. |
| `pricing.rate` | `price` (C3:425) | direct | Both keep 0 apart from missing. The repo has no fixed precision. |
| `pricing.billingUnit` | `charge_kind = 'UTILIZATION'` + `per_uom_id` + `quantity` (C3:425) | direct | The repo can also say "per 1,000" and "per month" (recurring). |
| `pricing.includedWith` | — at the price; bundles live on products: PRODUCT ASSOCIATION, package → component (C3:516) | structural | See §3.3. |
| `description.vendorProductName` | — | none | SUPPLIER PRODUCT (C3:259) carries no supplier's name for the product in this repo. A supplier's code could go in GOOD IDENTIFICATION (C3:137). |
| `description.notes` | `price_component.comment` | direct | |
| `local_metadata.tags` | — | none | Categories classify products, never prices. |
| `material_snapshot` | Snapshots live on transaction lines: `order_item.unit_price` (C4:35), `invoice_item.amount`, `item_description` (C7:44) | structural | See §3.4. |
| audit (created/updated by, ts) | — | none | |

### D. How "Any" works

| Answer | Repo | Quality | Notes |
|---|---|---|---|
| A specific value | The FK set on the component | direct | |
| **Any** | The FK left null | partial | Same storage as blank. |
| **Any [type]** ("any water") | `price_component.product_category_id` (C3:425): a price based on a category reaches every product in it | direct | And "the specific material wins" matches the repo's combining rule: the most specific base price wins (N3, Fig 3.7 decisions). That rule is **ours**, not the book's. |
| Blank (not answered yet) | — | none | |
| No "any" entry in the catalog | Same: no "any" rows; null does the job | direct | |

### E. Bundled charges

| VPC | Repo | Quality | Notes |
|---|---|---|---|
| `includedWith` + rate 0, same vendor, no chains | PRODUCT ASSOCIATION package/component (C3:516); `invoice_item.sold_with` (C7:44) on the bill | structural | No zero-rate rule, vendor rule or chain rule in the repo. |
| `add_on` charge kind | SURCHARGE component (C3:403); `ordered_for` (C4:35); ORDER ADJUSTMENT (C4:223) | partial | |
| **PROPOSED** percentage add-ons | `price_component.percent` with a SURCHARGE type (C3:425, C3:403) | direct | The repo already has this, both as a rule and as an order adjustment. |

### F. Core rules

| Axiom | Repo | Quality | Notes |
|---|---|---|---|
| 1. Explainable invoicing (describe, find, calculate, keep evidence) | Describe: WORK EFFORT + TIME ENTRY (C2:642, C6:221); bill: the four `*_billing` links (C7:185–221); find: `order_item_agreement_item` (C4:670) | partial | **No FK from a line to the price component that priced it.** `order_item.unit_price` keeps the number, not the rule. VPC's axiom goes further than the repo. |
| 2. A price depends only on what the vendor chooses | A component depends only on the conditions its pricer set | direct | |
| 3. Flexible composition, shared meaning | Fixed typed tables | structural | |
| 4. Released prices depend on retained revisions | Dated rows; no dependency pinned | partial | A price component points at a product, not a product *version*. |
| 5. Search ≠ price lookup; selection rules not designed | The book stores the rules and leaves combining them to the application; the repo's choice is in the "Price two lines" query (03 queries.sql:518) and N3 | direct | Same stance. |
| 6. Nothing hard-deleted | Thru dates everywhere | direct | |

### G. PROPOSED: price models

| VPC | Repo | Quality | Notes |
|---|---|---|---|
| A price model (template for a kind of price) | A PRODUCT (C3:25) with its PRODUCT FEATURE APPLICABILITY (C3:206) | structural | The product is the template; its applicability rows say what it takes. |
| `fixed` (activity haul) | The product itself (the haul service) | direct | |
| `required` | Applicability REQUIRED | direct | |
| `allowsAny` | Applicability OPTIONAL / SELECTABLE is the nearest | partial | Applicability says what the *buyer* may pick, not whether a *price* may ignore it. |
| `filter` (materials of type water) | Applicability rows list the allowed values; PRODUCT FEATURE INTERACTION (C3:224) adds dependencies and incompatibilities | partial | |
| `version` | Dated applicability rows | partial | |
| Matching never uses the model | Silverston's price points at the product, so the "model" is part of the match | structural | |
| **PROPOSED** vendorProductName as a constraint | — | none | |

### H. Out of scope for the service (where the repo covers them)

| VPC's outside | Repo |
|---|---|
| Vendor master | PARTY / ORGANIZATION with a supplier role (C2:19, C2:62, C2:263); SUPPLIER PRODUCT (C3:259) |
| Accounting / GL mapping | GENERAL LEDGER ACCOUNT, ORGANIZATION GL ACCOUNT (C8:19, C8:28), accounting transactions (C8:100) |
| Price selection for invoicing | `order_item_agreement_item` (C4:670) for agreements; the Ch 3 combining rule (N3) for components |
| Tickets (recorded field work) | WORK EFFORT (C2:642), TIME ENTRY (C6:221), WORK EFFORT FIXED ASSET ASSIGNMENT (C6:326); material moves as SHIPMENT (C5) |
| Invoices | INVOICE, INVOICE ITEM (C7:13, C7:44), and the billing links (C7:185–221) |

## 3. Structural differences

### 3.1 Combination rates vs additive components
The question to check: is the repo's pricing driven by components on products and features,
against VPC's key/value map plus an Any list? **Yes, and it changes what a row means.**
- A PRICE COMPONENT (C3:425) has one `product_id`, one `product_feature_id` and six fixed
  condition columns. The price of a line is *computed*: collect what applies, take the base,
  add the feature prices, apply the discounts and surcharges (the repo's rule, N3 Fig 3.7).
- A VPC row is the *whole* rate for a combination of any number of keys. Nothing adds up.
- "Haul, produced water, vacuum, area 8: 300 a load" needs two features at once (material,
  truck type). The repo can say "haul in area 8: 250" + "vacuum: +50", which is a different
  claim: vacuum costs 50 more on *any* haul. It can't say "300 for this exact cell" unless the
  combination becomes a product of its own. Variant products aren't in this repo.
- Field-services vendors quote matrices, so VPC's shape fits the domain. Silverston's shape
  fits list prices with options (a copier and its finisher).

### 3.2 Questions as schema vs questions as data
Silverston puts each pricing question in a column or a type table, so a new question is a
migration and every answer is an FK. VPC puts the questions in `attribute_definitions`,
so a new question is a row, and integrity moves into the application (property schemas,
validation on submit).

### 3.3 Bundles on the product vs bundles on the price
The repo's bundle is a product made of products (C3:516): reusable, nothing vendor-specific.
VPC's bundle is one vendor's quote split into two prices, with the zero rate pointing at
the one that pays. VPC's version keeps both activities matchable on their own, which a
package product doesn't.

### 3.4 Catalog history vs snapshots
The repo keeps catalog history with dates (applicability, classification), so you can always
ask what a product was on a date, and snapshots only on transaction lines. VPC never
edits a code's meaning (a new meaning gets a new code) and still copies the material into the
price as evidence. Belt and braces: the snapshot covers `properties` edits, which have no dates.

### 3.5 The price's own life
Silverston's price is a timeless rule with dates. VPC's price is a document with a
workflow (draft, submitted, approved, superseded), versions in a family and an author. The repo
has the parts for a status history (STATUS TYPE, C2:370), but not on prices.

## 4. Gaps both ways

**VPC has, the repo doesn't:** combination rates (§3.1); Any vs blank; a price
approval workflow; family and version; archive flag; catalog review status and deprecation;
property schemas; buyer tags on prices; the material snapshot; zero-rate `includedWith` with its
rules; audit columns; the area-within-division check.

**The repo has, VPC may be missing** (the ones that help invoicing and matching first):
- **Unit conversion** (C3:162). A ticket in gallons against a price per barrel needs it.
  `dimension` says two units are comparable, not how to convert.
- **Currency** (C3:375). VPC never names one.
- **Price types** (C3:403): discounts and surcharges as their own rows, not only base rates.
- **Quantity and order-value breaks** (C3:381, C3:389): volume tiers per load count.
- **Recurring charges per time frequency** (C3:371): rental per day, standby per hour as
  "per period" rather than a unit.
- **The contract** (AGREEMENT, C4:529, with terms C4:628): which MSA a price falls under.
- **A link from the billed line to the price rule.** The repo lacks it too; it's the evidence
  axiom 1 asks for, and nobody owns it yet.
- **Quotes** (C4:471): a vendor's offer before it becomes an approved price.
- **Feature interactions** (C3:224): "hazmat truck needs a hazmat material" as data.
- **Estimated cost** (C3:475): only if the buyer wants should-cost comparisons.

## 5. Open questions

1. **Is a division an organization or a region?** It decides between PARTY RELATIONSHIP and
   GEOGRAPHIC BOUNDARY ASSOCIATION for `areas.division`.
2. **Is an activity what's bought or what's done?** Product (service) vs work effort type.
   VPC's activity carries both; tickets probably want the work type.
3. **Is a truck type a priced option or an asset the work uses?** Feature vs fixed asset type.
4. **Rent** has no home in this repo. Equipment rental would need a model the repo doesn't have.
5. **Is a price sheet an agreement or a quote?** Approved prices read like a pricing program
   under a purchase agreement (C4:648); submitted ones read like quote items (C4:471).
6. **vendorLocationId:** a facility, an address, or a vendor sub-organization?
7. **Currency:** single-currency by design, or missing?
