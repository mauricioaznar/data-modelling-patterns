# Vendor Price Catalog: the evidence

As described by the user on 2026-11-05 (from the service's own source documents). The only truth
about the service for this comparison: no guessing at fields it doesn't list. **PROPOSED** items
aren't committed.

### Purpose

A **price sheet** stores one vendor's price for some work or goods, within a scope (who and where) and a date range. The service is two things:

- the **master catalog** of what can be priced: activities, materials, trucks, equipment, units, and more
- the **store of the prices** themselves

The domain is field services: water hauling, disposal, chemicals, equipment rental, labor.

There are three audiences:

- **Vendors** price what they sell in their own words and see only their own prices.
- **Data capture apps** (ticketing for recorded field work) need the one correct price for work that was recorded, for example "produced water haul, vacuum truck, area 8".
- **The buyer's staff** search, compare, approve, report and account across vendors.

The shared language between all three is `priceConstraints`.

### Storage: three tables, with flexible JSONB parts

#### A. `attribute_definitions`: the questions a price can answer

| Field | Meaning |
|---|---|
| `key` | Stable identifier, e.g. `material`, `truckType`, `percentActive` |
| `label` | Display name |
| `valueType` | `picklist` \| `decimal` \| `boolean` \| `text` |
| `picklistKey` | For picklist attributes: the catalog list its options come from |
| `canConstrainPrice` | Whether a price may depend on this attribute |

Current attributes and their value lists (picklist unless noted):

- `activity` → activities
- `material` → materials
- `materialType` → material_types
- `truckType` → truck_types
- `equipment` → equipment
- `fracTankType` → frac_tank_types
- `area` → areas
- `department` → departments
- `laborRole` → labor_roles
- `serviceType` → service_types
- `percentActive` (decimal)
- `solventBase` → solvent_bases
- `treatingApplication` → treating_applications
- `waterCondition` → water_conditions
- `waterUse` → water_uses
- `packageQuantity` (decimal)
- `packageUnit` → billing_units

#### B. `picklist_values`: the catalog, all lists in one table

Each row has:

- a **UUID**, which is its identity and integration key
- `listKey`, which says which list the row belongs to
- `code`, a readable stable code
- `label`
- `status`: `active` or `deprecated`. Deprecated means no new use, but the row is kept for existing references.
- `reviewStatus`: `provisional` or `approved`
- `properties`: JSONB. Each list publishes a `propertiesSchema` describing what its properties may hold.

Lists: `activities`, `materials`, `material_types`, `truck_types`, `equipment`, `frac_tank_types`, `billing_units`, `areas`, `divisions`, `departments`, `labor_roles`, `service_types`, `water_sources`, `water_uses`, `water_conditions`, `solvent_bases`, `treating_applications`, `fluid_bases`.

Typed relationships carried inside `properties`:

| On list | Property | Meaning |
|---|---|---|
| activities | `priceAttributes: string[]` | Which attribute keys a price for this activity may use. Haul → material, truckType, area, department. Labor → laborRole. |
| activities | `chargeKind: standalone \| add_on` | A charge on its own, or one attached to another charge |
| truck_types, equipment | `activities: string[]` | Which activities the entry can be used for |
| material_types | `attributes: [{key, label, valueType, picklistKey}]` | Fixed attributes the type gives its materials. For example, water gives `waterSource`. |
| materials | `materialType` | The material's type code, e.g. `water`, `mud`, `chemical`, `soil` |
| materials | `attributeValues` | Values for the type's fixed attributes, e.g. `{waterSource: "produced"}` |
| areas | `division` | The division the area belongs to |
| billing_units | `dimension: volume \| weight \| time \| count` | What the unit measures |

Example values:

- **activities**: haul, dispose, purchase, rent, standby, labor, washout, recycle, …
- **materials**: produced_water, fresh_water, brine, oil_based_mud, h2s_removal, …
- **truck_types**: vacuum, pneumatic, hydro-vac, flatbed, belly dump, hazmat
- **billing_units**: us_oil_barrel, load, hour, us_gallon, pound, item, …

Design rules for the catalog:

- It is flat and compositional. There is **no product/category hierarchy**: activities, materials, trucks and equipment are independent attributes that a price combines.
- A changed meaning gets a new code. An existing entry is never edited to mean something else.
- Other systems adapt to this catalog. It stores no crosswalk to their IDs; `source_refs` records provenance only.

#### C. `vendor_price`: one row per price version

| Part | Contents |
|---|---|
| `id`, `family_id`, `version_number` | This version's UUID, a UUID shared by all versions of the same price, and the version number |
| `status` | `draft` → `submitted` → `approved` \| `rejected`. An approved version becomes `superseded` when a newer version is approved. |
| `archived` (+ by/ts) | A separate flag, not a status. Nothing is ever hard-deleted. |
| `scope` | `vendorId` (the vendor number from an external vendor master), `vendorLocationId`, `divisionIds[]`, `departments[]`, `areas[]` (each area's division must be in `divisionIds`), and effective dates (`effectiveFrom` …) |
| `price_constraints` | JSONB `{attributeKey: catalogCode}`: what the price depends on |
| `unconstrained_keys` | JSONB `string[]`: attributes the vendor explicitly says the price does **not** depend on ("Any") |
| `pricing` | `{rate, billingUnit, includedWith?}`. The rate is a decimal string with 6 places; `0` is a real price, different from a missing one. |
| `description` | `{vendorProductName?, notes?, characteristics?}`: the vendor's own wording, which never affects matching |
| `local_metadata` | `{tags[]}`: buyer-only tags. Filterable, but never affect pricing. |
| `material_snapshot` | A server-built copy of the selected material (list key, UUID, code, label, properties), written in the same transaction as the price. It is evidence, not a cache: catalog edits never refresh it. |
| audit | `created_by/ts`, `updated_by/ts` |

Example row:

```json
{
  "familyId": "fam-001",
  "version": 3,
  "status": "approved",
  "scope": { "vendorId": "v-acme" },
  "priceConstraints": { "activity": "haul", "material": "produced_water", "truckType": "vacuum", "area": "area_8" },
  "unconstrainedKeys": ["waterCondition", "waterUse", "department"],
  "pricing": { "rate": "300.000000", "billingUnit": "load" },
  "effectiveFrom": "2026-09-01"
}
```

### D. How "Any" works

The vendor answers each applicable attribute in one of these ways:

| Answer | How it's stored |
|---|---|
| A specific value | In `priceConstraints`, e.g. `material: oil_based_mud` |
| **Any** | The key goes into `unconstrainedKeys`, e.g. `["material"]` |
| **Any [type]**, e.g. "any water" | `priceConstraints.materialType = "water"`, with `material` left unconstrained. When both a type rate and a specific material rate match, the specific material wins. |
| Blank | Neither is set. This means "not answered yet": allowed in a draft, should block submit. |

The catalog never contains an "any" entry. The UI adds that option.

### E. Bundled charges (committed design)

`pricing.includedWith` is the `familyId` of another price that covers this one's cost. Rules:

- the rate must be `0`
- the covering price must have the same vendor
- the covering price can't itself be included with something else (no chains)

Example: one vendor quote for "trucking and disposal" is stored as two prices. The haul carries the full rate, and the dispose price is $0 `includedWith` the haul.

The other link between prices is the `add_on` charge kind on activities: an extra charge attached to a main price. How add-ons are priced (for example, as a percentage) is **PROPOSED**.

### F. Core rules (axioms)

1. **The goal is explainable invoicing.** Integrating apps (1) describe the work, (2) find the applicable approved price, (3) calculate the charge, and (4) keep the evidence (price version, observations, rule used). This service owns the prices and the catalog. Which system owns steps 2 to 4 is still open.
2. **A price depends only on what the vendor chooses** (the specific / Any / blank answers in section D).
3. **Flexible composition with shared meaning**: flat attributes, stable IDs, units and validation.
4. **A released price depends on specific, retained revisions.** Changing a dependency creates a new draft and never rewrites released pricing.
5. **Search is discovery, not price lookup.** Selecting the one price for recorded work needs separate rules for eligibility, dates, scope, specificity and ambiguity. Those rules aren't designed yet.
6. **Nothing is hard-deleted.** Records are archived or deprecated.

### G. PROPOSED, not committed: price models

A **price model** is a business-owned template for a kind of price. It would be stored as rows in `picklist_values` with `listKey = "price_models"` and the template in `properties`, so it needs no new table.

```json
{
  "code": "water_haul", "label": "Water haul",
  "properties": {
    "version": 1,
    "fixed": { "activity": "haul" },
    "attributes": [
      { "key": "material",  "required": true,  "allowsAny": true,
        "filter": { "resource": "materials",   "payload": { "materialTypes": ["water"] } } },
      { "key": "truckType", "required": true,  "allowsAny": false,
        "filter": { "resource": "truck_types", "payload": { "activities": ["haul"] } } },
      { "key": "area",       "required": false, "allowsAny": true },
      { "key": "department", "required": false, "allowsAny": true }
    ]
  }
}
```

The fields mean:

- `fixed`: values every price of this model carries
- `required` / `allowsAny`: whether the form must get an answer, and whether Any is allowed
- `filter`: a normal catalog search that narrows the picker

Each price would record `priceModel` and `priceModelVersion`, and submit would validate against them. Approved prices are never re-checked when a model changes. Matching still uses only the price's constraints, never the model.

Other example models:

- `disposal`: fixed activity dispose; asks material
- `h2s_chemical`: fixed activity purchase and material h2s_removal; asks percentActive, solventBase, treatingApplication
- `frac_tank_rental`: fixed activity rent and equipment frac_tank; asks fracTankType

Also **PROPOSED**: percentage-based add-on pricing, and letting `vendorProductName` be something a price can depend on.

### H. Out of scope for this service today

- the vendor master (vendors are an external reference)
- accounting / GL mapping (a later, separate layer)
- the price-selection algorithm for invoicing
- tickets and invoices themselves (they live in the data capture apps)

When you map these, flag where this repo's ERP would cover them. Don't treat their absence here as a gap in the Vendor Price Catalog.
