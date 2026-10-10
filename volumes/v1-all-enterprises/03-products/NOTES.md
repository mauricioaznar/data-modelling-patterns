# Vol 1, Chapter 3 — Products

## The problem this pattern solves
<!-- Filled in as the figures are built. -->

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

**Discussion**
- *(to write once confirmed)*

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

## When NOT to use this
<!-- Costs of the generality; what a simpler app would do instead. -->

## Open questions
- **Figs 3.2–3.4 were built before they were confirmed** (at the user's request, 2026-10-10).
  The "Check against the book" items under each figure are still open; the SQL follows our
  reading.
- **Fig 3.2:** is the primary flag one per product, or one per product per purpose or
  dimension (one primary for catalogues, another for sales analysis)? The book's text after
  the figure seems to discuss this; check it.
