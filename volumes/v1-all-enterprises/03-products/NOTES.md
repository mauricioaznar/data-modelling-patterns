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
- *(to write once confirmed)*

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
- *(to write once confirmed)*

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

## When NOT to use this
<!-- Costs of the generality; what a simpler app would do instead. -->

## Open questions
