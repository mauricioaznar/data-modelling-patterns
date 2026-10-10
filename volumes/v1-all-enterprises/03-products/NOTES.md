# Vol 1, Chapter 3 — Products

## The problem this pattern solves
A naive catalogue is one `item` table with columns for everything: category, SKU, UPC,
colour, size, price, supplier, quantity on hand. It breaks as soon as a product sits in two
categories, carries several codes, comes in three colours, or has two suppliers. Ch 3 splits
that table apart. PRODUCT is only *what we offer*. Everything that is many-valued, dated, or
reused across products (categories, codes, features, units, later suppliers, stock and
prices) becomes its own entity linked back to it. The recurring moves are the ones from Ch 2:
a dated classification link, a many-to-many rollup, type + value rows instead of columns, and
rules stored as data.

## Submodels (proposed, pending the rest of the chapter's figures)
1. **Product definition, categories and identification** (Figs 3.1–3.3): what is the thing
   we sell, how do we group it, and which codes identify it?
2. **Product features** (Fig 3.4): what options and characteristics can a product have,
   which ones go together, and in what units are they measured?

## Figures

### Fig 3.1 — Product definition
**Transcription** (confirmed against the book: ☑)

```
PRODUCT
  # product_id
  * name
  o introduction_date
  o sales_discontinuation_date
  o support_discontinuation_date
  o comment
  subtypes:
    GOOD
    SERVICE
```

Table 3.1 sample products (paraphrased): a ream of bond paper, a pen, a box of diskettes,
preprinted insurance claim forms (all goods), and an inventory management consulting
service (a service). The sample ids are readable codes such as `PAP192` and `CNS109`.

**Discussion**
- **A product is what we offer, not a thing on a shelf.** "The Goldstein Elite pen" is one
  PRODUCT row however many pens we stock, and whoever supplies them. Stock, suppliers and
  prices hang off the product later in the chapter. The naive model mixes these: an `item`
  table with a price, a supplier and a quantity column can't hold two suppliers, a price change,
  or two warehouses.
- **Goods and services share one supertype** for the same reason people and organizations
  share PARTY: orders, invoices and prices refer to "a product", and that may be a box of
  diskettes or an hour of consulting. One FK target instead of two.
- **The three dates describe a life cycle,** not a validity period: launched, stopped selling,
  stopped supporting. Support can outlive sales (diskettes: no longer sold, still supported),
  so the two discontinuation dates are separate.
- **No price, cost or quantity on PRODUCT.** Each varies by supplier, location, time or
  feature, so each gets its own entity later in the chapter.

### Fig 3.2 — Product category
**Transcription** (confirmed against the book: ☐)

```
PRODUCT CATEGORY CLASSIFICATION
  # from_date
  o thru_date
  * primary_flag
  o comment
  -> PRODUCT            (many classifications "a category for" 1 product;
                         product "categorized by" many; part of identifier)
  -> PRODUCT CATEGORY   (many "defined by" 1 category; category "used to define" many;
                         part of identifier)

PRODUCT CATEGORY
  # product_category_id
  * description
  subtypes:
    PRODUCT USAGE CATEGORIZATION
    PRODUCT INDUSTRY CATEGORIZATION
    PRODUCT MATERIALS CATEGORIZATION

PRODUCT CATEGORY ROLLUP            (no attributes shown)
  -> PRODUCT CATEGORY   (parent: "made up of" many rollups)
  -> PRODUCT CATEGORY   (child: "part of" / "containing", "within")

MARKET INTEREST
  # from_date
  o thru_date
  -> PRODUCT CATEGORY   (many "of" 1 category; category "of interest to" many)
  -> PARTY TYPE         (many "for" 1 party type; party type "interested in" many)

PARTY TYPE              (from Ch 2, Fig 2.3)
  # party_type_id
  * description
```

**Check against the book (unclear in the photo):**
- PRODUCT CATEGORY ROLLUP shows **no from/thru dates**, unlike the other associative
  entities in this figure. Is that right?
- Which rollup relationship is the parent and which the child (I read "made up of" as the
  parent side and "part of" as the child side)?

**Discussion**
- **The naive model** puts a `category_id` column on PRODUCT. That breaks as soon as a
  product belongs to two groupings (the forms are "business forms" *and* "for the insurance
  industry" *and* "paper-based"), or moves to another category and you still need last
  year's sales by the old one.
- **PRODUCT CATEGORY CLASSIFICATION is PARTY CLASSIFICATION again** (Ch 2, Fig 2.3): a dated
  many-to-many between the thing and a classification value. Same shape, different subject.
- **The primary flag** answers "if I can show this product in only one place (a catalogue
  page, a sales report line), which one?" Without it, a product in three categories is
  counted three times in a sales-by-category report.
- **Rollup is many-to-many,** so the categories form a network, not a strict tree: Business
  forms can be under both Paper and Printed materials. A single `parent_id` column would force
  one parent. This is ORGANIZATION ROLLUP (Fig 2.5) applied to categories.
- **The subtypes (usage, industry, materials) are dimensions:** independent ways of slicing
  the catalogue. A product usually has one category per dimension.
- **MARKET INTEREST links two knowledge-level tables:** party types (Ch 2) and product
  categories. It says "logistics companies tend to buy office equipment", not "Contoso buys
  copiers". Joined with a party's current classifications, it produces a prospect list.

### Fig 3.3 — Product identification
**Transcription** (confirmed against the book: ☐)

```
GOOD IDENTIFICATION                (no # attribute: identified by its relationships)
  * id_value
  -> PRODUCT              (many "an identifier for" 1 product; product "identified by" many)
  -> IDENTIFICATION TYPE  (many "defined as" 1 type; type "used to define" many)
  subtypes:
    MANUFACTURER ID NO
    SKU
    UPCA
    UPCE
    ISBN
    OTHER ID

IDENTIFICATION TYPE
  # identification_type_id
  * description
```

**Check against the book:**
- The entity is called GOOD identification but the line goes to **PRODUCT**, not to GOOD
  (and the text says a code can identify goods or services). Is that what the figure shows?
- Are both relationships part of GOOD IDENTIFICATION's identifier (bar across the line)?

**Discussion**
- **The naive model** adds a column per code: `sku`, `upc`, `isbn`, `mfr_part_no`. Each new
  standard (EAN-13, GTIN-14, a retailer's own code) means a migration, most columns are empty
  for most products, and "look up whatever was scanned" means OR-ing across every column.
- **Codes as rows (type + value)** is the PERSON NAME / PHYSICAL CHARACTERISTIC move from
  Ch 2 (Fig 2.2b). A new code type is a new row in IDENTIFICATION TYPE, and a scan lookup is
  one `where id_value = ?`.
- **No from/thru dates:** codes are treated as permanent facts about the product. If a UPC
  is reassigned, the model can't tell you which product it meant last year.
- **Identifier = product + type** (no `#` of its own): one value per code type per product.
  The more important real-world rule runs the other way: one code must not identify two
  products, or a scanner can't decide. Neither rule is a plain FK, so both are data-quality
  queries here.
- **Why "good" identification on PRODUCT?** Most standard codes (UPC, ISBN) are for physical
  goods, which explains the name. But a service can still have our own SKU (CNS109 is one), so
  linking to PRODUCT is more flexible than the name suggests.

### Fig 3.4 — Product feature
**Transcription** (confirmed against the book: ☐)

```
PRODUCT FEATURE
  # product_feature_id
  * description
  -> PRODUCT FEATURE CATEGORY  (many "categorized by" 1 category; category "the category for" many)
  -> UNIT OF MEASURE           (optional: many "measured using" 1 UOM; UOM "used in" many)
  subtypes:
    PRODUCT QUALITY
    COLOR
    DIMENSION
      * number_specified
    SIZE
    BRAND
    SOFTWARE FEATURE
    HARDWARE FEATURE
    BILLING FEATURE
    OTHER FEATURE

PRODUCT FEATURE CATEGORY
  # product_feature_category_id
  * description

PRODUCT FEATURE APPLICABILITY
  # from_date
  o thru_date
  -> PRODUCT          (many "available for" 1 product; product "available with" many)
  -> PRODUCT FEATURE  (many "described by" 1 feature; feature "used to define" many)
  subtypes:
    REQUIRED FEATURE
    STANDARD FEATURE
    OPTIONAL FEATURE
    SELECTABLE FEATURE

PRODUCT FEATURE INTERACTION        (no attributes shown)
  -> PRODUCT FEATURE  ("of": the feature selected in the interaction)
  -> PRODUCT FEATURE  ("a factor in": the feature it is dependent on / incompatible with)
  -> PRODUCT          ("applicable within the context of"; product "used to define" many)
  subtypes:
    FEATURE INTERACTION INCOMPATIBILITY
    FEATURE INTERACTION DEPENDENCY

PRODUCT
  -> UNIT OF MEASURE  (many products "measured using" 1 UOM; UOM "used in" many)

UNIT OF MEASURE
  # uom_id
  * abbreviation
  * description

UNIT OF MEASURE CONVERSION         (no # attribute)
  * conversion_factor
  -> UNIT OF MEASURE  ("from" / "converted from")
  -> UNIT OF MEASURE  ("in" / "converted into")
```

**Check against the book:**
- Is PRODUCT → UNIT OF MEASURE mandatory or optional? And PRODUCT FEATURE → UNIT OF MEASURE?
- Is PRODUCT FEATURE INTERACTION → PRODUCT optional (an interaction that holds for every
  product) or mandatory?
- Does PRODUCT FEATURE INTERACTION really have no from/thru dates?
- The applicability subtypes' meanings below are our reading; check the book's text.

**Discussion**
- **The naive model** gives PRODUCT columns like `color`, `size`, `brand`, or splits each
  combination into its own product (blue pen, black pen, red pen). Columns can't hold "comes in
  blue *or* black", and one product per combination explodes (5 options on a copier is 32
  products) and loses the fact that they're the same product.
- **Features are defined once and reused.** "Blue" is one PRODUCT FEATURE row used by the pen,
  a binder and a folder. PRODUCT FEATURE APPLICABILITY is the many-to-many that says which
  products offer which features, how (required, standard, optional, selectable), and when.
- **Applicability (our reading):** *required* is always part of the product; *standard* is
  included by default; *optional* can be added; *selectable* means pick one from a set (pen
  colour, billing method). The same feature can be standard on one product and optional on
  another, which is why the type sits on the link and not on the feature.
- **Feature subtypes vs feature category:** the subtypes say what *kind* of feature it is
  (colour, dimension, billing). The category is a business grouping for display ("Copier
  options", "Paper specifications"). They're independent axes, like product category dimensions
  in 3.2.
- **PRODUCT FEATURE INTERACTION is a rule stored as data,** like Ch 2's VALID CONTACT MECHANISM
  ROLE: "the stapler needs the duplex unit", "the big tray doesn't fit the desktop stand". The
  optional product context makes a rule local to one product or global to all.
- **DIMENSION is the only subtype with an attribute** (number_specified) because it's the only
  one that's a quantity. It needs a unit, hence UNIT OF MEASURE.
- **UNIT OF MEASURE does double duty:** the unit a product is counted in (a ream, a box, an
  hour) and the unit of a dimension (inches, pounds). UNIT OF MEASURE CONVERSION relates two
  units by a factor. Its limit: conversions are per *unit pair*, not per product. "1 box = 10
  each" is true for diskettes and false for forms, and the model can't tell them apart.

## Design decisions (book → SQL)

### Fig 3.1
- **GOOD / SERVICE become a `product_kind` discriminator** (check constraint), not subtype
  tables: exclusive, and no attributes of their own yet. If later figures give GOOD its own
  attributes or relationships, add a `good` table sharing `product_id`, as with `person`.
- **Surrogate `product_id`.** The book's readable codes (PAP192…) are identifiers that can
  change or come in several flavours (SKU, UPC, ISBN), so they move to Fig 3.3's
  identification table. Until then they sit in `comment`.
- **Discontinuation dates are exclusive** (first day no longer sold / supported), matching our
  `thru_date` convention. "Sellable on d": `introduction_date <= d and
  (sales_discontinuation_date is null or sales_discontinuation_date > d)`.
- **Date order is a data-quality query**, not a check constraint (the seed's typewriter ribbon
  stops support before sales).

### Fig 3.2
- **Category subtypes become `product_category_type` rows** (USAGE, INDUSTRY, MATERIALS),
  with an FK from `product_category`. Same move as Ch 2's attribute-less subtypes.
- **Surrogate integer `product_category_id`**, not a text code: categories are business data
  that users add and rename, unlike the fixed `*_type` lookups.
- **Rollup has no dates,** following the figure (flagged for checking). If the catalogue is
  reorganised, the old structure is lost; add from/thru if category history matters.
- **Parent/child columns:** `parent_product_category_id` ("made up of") and
  `child_product_category_id` ("part of"). A check stops a category being its own parent;
  longer cycles are a data-quality query (seed: Recycled ↔ Recycled paper).
- **Addition: `product_category_ancestor` view** (like Ch 2's `role_type_ancestor`), using
  `union` so a cycle ends the walk instead of hanging the query. "Products in category X"
  means X itself plus every category whose ancestor is X.
- **Surrogate `product_category_classification_id`** instead of (product, category, from_date).
- **One current primary per product is a data-quality query** (seed: the pen is primary in both
  Writing instruments and Plastic). We read "primary" as one per product. It could be one per
  product *per dimension*; see Open questions.
- **`market_interest.party_type_id` references Ch 2's `party_type`.** Nothing stops an interest
  pointing at a grouping type (INDUSTRY) rather than a value (IND_LOGISTICS); the query only
  matches exact types.

### Fig 3.3
- **Identification subtypes become `identification_type` rows** (MANUFACTURER_ID, SKU, UPCA,
  UPCE, ISBN, OTHER), in the book's own IDENTIFICATION TYPE table.
- **Table name kept as `good_identification`, FK to `product`**, following the figure (flagged
  for checking). Services may carry codes; a query lists them (CNS109).
- **Surrogate `good_identification_id`** instead of the book's (product, type) identifier.
  "One value per type per product" is a data-quality query (seed: toner has two SKUs).
- **Addition: "one code, one product" data-quality query** (seed: the pen and the copier share a
  UPC). This is the rule a barcode scanner relies on.
- **Addition: `identification_type.value_pattern`**, a regex each code of that type must
  match (UPC-A 12 digits, UPC-E 8, ISBN 10 or 13). A rule stored as data, checked by a
  data-quality query (seed: an 11-digit UPC). Check digits aren't verified.
- **The book's Table 3.1 codes (PAP192…) are stored as SKUs**, which removes them from
  `product.comment`'s job.

### Fig 3.4
- **`product.uom_id` is added with `alter table` in the 3.4 section**, so the schema still
  reads in book order. Nullable until we confirm the cardinality (the maintenance plan has none).
- **Feature subtypes become `product_feature_type` rows.** DIMENSION's `number_specified` is a
  nullable column on `product_feature`. A data-quality query checks that dimensions have a number
  and a unit and other kinds don't (seed: a Height with no number, a Grey with a number). Same
  approach as `federal_tax_id_num` in Ch 2.
- **Applicability subtypes → `product_feature_applicability_type`; interaction subtypes →
  `product_feature_interaction_type`.** Exclusive and attribute-less, so rows.
- **`product_feature.product_feature_category_id` is nullable** (unclear in the photo).
- **Interaction columns:** `product_feature_id` ("of", the feature being chosen) and
  `factor_product_feature_id` ("a factor in"). For DEPENDENCY the direction matters (choosing
  the first needs the second); INCOMPATIBILITY is read in both directions. `product_id` null
  means "any product". A check stops a feature interacting with itself.
- **Conversion row meaning:** 1 `from_uom_id` = `conversion_factor` × `to_uom_id`. Both
  directions are stored, and a data-quality query checks that they multiply to 1 (seed: KG→LB
  says 2.0). Surrogate key instead of the (from, to) pair.
- **Rules as data-quality queries:** interactions naming a feature the context product doesn't
  offer (seed: "fine grade" on the pen); pairs that are both dependent and incompatible (seed:
  the desktop stand). Plus a **configuration check** query: given chosen features, list the
  unmet dependencies and incompatible pairs, counting required and standard features as
  included.
- **Not enforced:** a SELECTABLE set needs exactly one choice. The configuration check doesn't
  test it yet.

## When NOT to use this

**Category classification with a rollup network (3.2):**
- "Products in category X" becomes a recursive query, and sales by category double-count
  unless everyone respects the primary flag.
- A small shop with one flat list of categories needs a `category_id` column on product. Use a
  single `parent_id` tree when every category has exactly one parent. Reach for the full model
  when there are several independent groupings (usage, industry, materials) or the catalogue
  is reorganised and history matters.

**Codes as rows (3.3):**
- Columns are simpler and type-checked when there are one or two fixed codes (an internal SKU
  and a UPC). Rows win when the set of code standards is open-ended or most codes are sparse.

**Feature applicability and interactions (3.4):**
- This is a product configurator in miniature. It's worth it for configurable goods (cars,
  computers, copiers, insurance plans). For a shop where each variant has its own stock and
  price (T-shirts in S/M/L), separate variant products, or a product + variant table, are
  simpler. Interactions are rules in data: easy to add, hard to test, and only the
  application (or a query like ours) enforces them.

**Units of measure (3.4):**
- If everything is sold "each", a UOM table is noise. Once quantities cross units (buy in
  boxes, sell in eaches, ship in kilograms), it's essential. Product-specific pack sizes then
  need more than a unit-pair conversion.

## Open questions
- **Figs 3.2–3.4 were built before they were confirmed** (at the user's request, 2026-10-10).
  The "Check against the book" items under each figure are still open; the SQL follows our
  reading.
- **Fig 3.2:** is the primary flag one per product, or one per product per purpose or
  dimension (one primary for catalogues, another for sales analysis)? The book's text after
  the figure seems to discuss this; check it.
- **Fig 3.4:** conversions are per unit pair, so a product-specific pack size ("a box of forms
  holds 50") has nowhere to live. Does a later figure (inventory, supplier products) solve
  this?
- **Fig 3.4:** "exactly one choice from a SELECTABLE set": is the set all selectable features
  of the same feature type on that product? Not checked yet.
