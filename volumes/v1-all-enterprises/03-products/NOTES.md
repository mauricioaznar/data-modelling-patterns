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

## Submodels (4–5 proposed 2026-10-16, once every figure was shared)
1. **Product definition, categories and identification** (Figs 3.1–3.3): what is the thing
   we sell, how do we group it, and which codes identify it?
2. **Product features** (Fig 3.4): what options and characteristics can a product have,
   which ones go together, and in what units are they measured?
3. **Suppliers and inventory** (Figs 3.5–3.6): who can sell it to us, when do we reorder,
   and where is the stock, in what state?
4. **Pricing and costing** (Figs 3.7–3.8): what do we charge, to whom, where and for how
   much, and what does it cost us to make?
5. **Product associations and parts** (Figs 3.9–3.10): which products are built from,
   bundled with, replaced by, substitutable for or incompatible with which others?

Fig 3.11 is the chapter's summary: no new submodel, but it adds GOOD's subtypes and shows
which alternates (3.9b, not 3.10b) the overall model keeps.

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
**Transcription** (confirmed against the book: ☑ 2026-10-11)

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

**Checked against the book (2026-10-11):**
- PRODUCT CATEGORY ROLLUP has **no from/thru dates**: confirmed.
- "Made up of" is the parent side and "part of" the child side: confirmed.
- The primary flag is an attribute of PRODUCT CATEGORY CLASSIFICATION; the book doesn't say
  whether it means one per product or one per product per dimension.

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
**Transcription** (confirmed against the book: ☑ 2026-10-11)

```
GOOD IDENTIFICATION                (no # attribute: identified by its relationships)
  * id_value
  -> GOOD                 (many "an identifier for" 1 good; good "identified by" many;
                           part of identifier)
  -> IDENTIFICATION TYPE  (many "defined as" 1 type; type "used to define" many;
                           part of identifier)
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

**Checked against the book (2026-10-11):**
- The line goes to **GOOD**, not PRODUCT (our first reading said PRODUCT): services carry no
  codes in this model.
- Good + identification type are the whole identifier: confirmed.

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
- **Why only goods?** Standard codes (UPC, ISBN, manufacturer part numbers) exist for physical
  things you scan, stock and ship. A service has none of those. If a business does give its
  services catalogue codes (CNS109 in the book's table), linking to PRODUCT instead is a small,
  reasonable deviation; we follow the book.

### Fig 3.4 — Product feature
**Transcription** (confirmed against the book: ☑ 2026-10-11)

```
PRODUCT FEATURE
  # product_feature_id
  * description
  -> PRODUCT FEATURE CATEGORY  (optional: many "categorized by" 1 category; category "the category for" many)
  subtypes:
    PRODUCT QUALITY
    COLOR
    DIMENSION
      * number_specified
      -> UNIT OF MEASURE       (optional on both sides: many "measured using" 1 UOM; UOM "used in" many)
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
  -> PRODUCT          (optional: "applicable within the context of"; product "used to define" many)
  subtypes:
    FEATURE INTERACTION INCOMPATIBILITY
    FEATURE INTERACTION DEPENDENCY

PRODUCT
  -> UNIT OF MEASURE  (optional: many products "measured using" 1 UOM; UOM "used in" many)

UNIT OF MEASURE
  # uom_id
  * abbreviation
  * description

UNIT OF MEASURE CONVERSION         (no # attribute)
  * conversion_factor
  -> UNIT OF MEASURE  ("from" / "converted from")
  -> UNIT OF MEASURE  ("in" / "converted into")
```

**Checked against the book (2026-10-11):**
- PRODUCT → UNIT OF MEASURE is optional.
- The unit of measure hangs off the **DIMENSION** subtype, not PRODUCT FEATURE (our first
  reading), and is optional on both sides.
- PRODUCT FEATURE → PRODUCT FEATURE CATEGORY is optional.
- PRODUCT FEATURE INTERACTION → PRODUCT is optional (null = a rule for every product), and the
  interaction has no from/thru dates.
- Our reading of required / standard / optional / selectable matches the text. For
  selectable, the book only says the feature must be selected; it doesn't define the set.

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
- **DIMENSION is the only subtype with an attribute** (number_specified) and the only one
  linked to UNIT OF MEASURE, because it's the only one that's a quantity. The unit is optional
  in the figure.
- **UNIT OF MEASURE does double duty:** the unit a product is counted in (a ream, a box, an
  hour) and the unit of a dimension (inches, pounds). UNIT OF MEASURE CONVERSION relates two
  units by a factor. Its limit: conversions are per *unit pair*, not per product. "1 box = 10
  each" is true for diskettes and false for forms, and the model can't tell them apart.

### Fig 3.5 — Suppliers and manufacturers of products
**Transcription** (confirmed against the book: ☑ 2026-10-11)

```
REORDER GUIDELINE
  # reorder_guideline_id
  * from_date
  o thru_date
  o reorder_quantity
  o reorder_level
  -> GOOD                   (many "for" 1 good; good "subject to" many)
  -> GEOGRAPHIC BOUNDARY    (many "based on" 1 boundary; boundary "the basis for" many)
  -> FACILITY               (many "based on" 1 facility; facility "the basis for" many)
  -> INTERNAL ORGANIZATION  (many "based on" 1 org; org "the basis for" many)

SUPPLIER PRODUCT
  # available_from_date
  o available_thru_date
  o standard_lead_time
  o comment
  -> PRODUCT          (many "a valid supplier for" 1 product; product "supplied thru" many;
                       part of identifier)
  -> ORGANIZATION     (many "supplied by" 1 org; org "the supplier of" many; part of identifier)
  -> PREFERENCE TYPE  (many "further described by" 1 type; type "used to describe" many)
  -> RATING TYPE      (many "rated by" 1 type; type "the rating for" many)

PREFERENCE TYPE
  # preference_type_id
  * description

RATING TYPE
  # rating_type_id
  * description

PRODUCT
  -> ORGANIZATION     (many products "manufactured by" 1 org; org "the producer of" many)

GEOGRAPHIC BOUNDARY, FACILITY      (from Ch 2, Figs 2.8 and 2.11)
INTERNAL ORGANIZATION              (a Ch 2 party role)
ORGANIZATION                       (from Ch 2)
```

**Checked against the book (2026-10-11):**
- REORDER GUIDELINE links to **GOOD**; no identifier mark on that line.
- SUPPLIER PRODUCT and "manufactured by" both link to **PRODUCT**.
- Optional on the many side: the three "based on" lines and SUPPLIER PRODUCT → PREFERENCE TYPE /
  RATING TYPE. The rest are mandatory on the many side; the "one" side is optional throughout.

**Discussion**
- **The naive model** puts `supplier_id`, `lead_time` and `reorder_level` on PRODUCT. That
  allows one supplier per product, no history of who supplied it when, and one reorder level
  for the whole company, when the main warehouse and a small branch need very different ones.
- **Manufacturer vs supplier.** Who *makes* a product is a single fact about the product (a
  column). Who can *sell it to us* is a many-to-many with dates and terms (SUPPLIER PRODUCT).
  The same organization can be both (Johnson makes the paper and sells it directly).
- **SUPPLIER PRODUCT is the supplier's catalogue entry for our product:** lead time, our
  preference (first choice, backup) and our rating of them. Preference and rating are lookups
  so purchasing can rank sources without free text. Price isn't here; pricing comes later.
- **A service can have a supplier** (subcontracted maintenance), which is why SUPPLIER PRODUCT
  links to PRODUCT, while REORDER GUIDELINE links to GOOD: only things you stock get reordered.
- **REORDER GUIDELINE is a rule stored as data,** scoped by where it applies: a facility, a
  geographic boundary, an internal organization, any mix, or none (everywhere). It is dated, so
  a guideline can be replaced without losing the old one.
- **Parties come from Ch 2.** Supplier, manufacturer and internal organization are organizations
  playing roles; the figure links straight to ORGANIZATION, so the role is a data-quality check.

### Fig 3.6 — Inventory item storage
**Transcription** (confirmed against the book: ☑ 2026-10-11)

```
INVENTORY ITEM
  # inventory_item_id
  -> GOOD                        (many "the physical occurrence of" 1 good;
                                  good "the generic description for" many)
  -> INVENTORY ITEM STATUS TYPE  (many "in the state of" 1 status; status "the state for" many)
  -> LOT                         (many "part of" 1 lot; lot "made up of" many)
  -> FACILITY                    (many "located at" 1 facility; facility "the location for" many)
  -> CONTAINER                   (many "located within" 1 container;
                                  container "the storage container for" many)
  (exclusive arc across FACILITY and CONTAINER: one or the other)
  subtypes:
    SERIALIZED INVENTORY ITEM
      * serial_num
    NON SERIALIZED INVENTORY ITEM
      * quantity_on_hand

INVENTORY ITEM VARIANCE
  # physical_inventory_date
  * quantity
  o comment
  -> INVENTORY ITEM  (many "an adjustment for" 1 item; item "adjusted thru" many; part of identifier)
  -> REASON          (many "explained with" 1 reason; reason "the explanation for" many)

REASON
  # reason_id
  * description

INVENTORY ITEM STATUS TYPE
  (# id, * description; e.g. good, being repaired, slightly damaged, defective, scrap)

LOT
  # lot_id
  * creation_date
  * quantity
  o expiration_date

CONTAINER
  # container_id
  -> CONTAINER TYPE  (many "described by" 1 type; type "the description of" many)
  -> FACILITY        (many "located at" 1 facility; facility "the location of" many)

CONTAINER TYPE
  # container_type_id
  * description

FACILITY                         (from Ch 2)
  subtypes shown: WAREHOUSE, PLANT
```

**Checked against the book (2026-10-11):**
- Exclusive arc across "located at" (FACILITY) and "located within" (CONTAINER).
- INVENTORY ITEM → LOT is optional; → status type and VARIANCE → REASON are mandatory on the
  many side.
- Status type has no subtypes; FACILITY shows only WAREHOUSE and PLANT here.

**Discussion**
- **Product vs inventory item** is the type/instance split again: GOOD is the catalogue
  description, INVENTORY ITEM is physical stock of it. The naive model keeps
  `quantity_on_hand` on PRODUCT, which can't say *where* the stock is, what *state* it's in,
  or *which* lot it came from.
- **Serialized vs non-serialized:** a copier is tracked one unit at a time (a serial number,
  quantity implicitly 1); reams of paper are tracked as a quantity in a place. Same supertype,
  different way of counting.
- **The exclusive arc** says an item sits either directly in a facility or in a container, and
  a container is itself in a facility. So "stock at Chatham" must look through containers.
- **Status** splits stock you can sell from stock you can't (damaged, being repaired, scrap):
  the same good in the same place can be several inventory items.
- **LOT** groups items made or received together, for expiry and recalls ("which shelves hold
  lot 2?").
- **INVENTORY ITEM VARIANCE** records what a physical count found, with a reason. It's the audit
  trail behind a change in quantity on hand.

**Working vocabulary (ours, not the book's; settled 2026-10-15)**
- **qoh**: the stored `quantity_on_hand` (non-serialized items only). The system's current
  belief, a cached running total: each movement applies its delta when it is written.
  Not a count and not a snapshot. Old values are overwritten.
- **balance**: the sum of every movement row since a known starting point (zero, or an
  opening balance / checkpoint). Computed by a query, never stored.
- **movements**: receipts (+), issuances (−) and variances (±). Only variances exist in Ch 3;
  the book records receipts and issuances in Ch 5 (SHIPMENT RECEIPT, ITEM ISSUANCE; recalled,
  to check there). Until then the balance can't be computed.
- **variance**: the gap a physical count finds, `counted − qoh` at that moment, with a date and
  a reason. The count itself isn't stored; a count that matches leaves no gap to record.
- Two checks: **qoh = balance** must always hold (a mismatch is a bug: a row written without the
  column update, or the other way round). **qoh vs counted** may differ; that difference is the
  variance, and recording it brings them back in line.

**Discussed alternatives (not adopted; the schema stays the book's)**
- *Leave qoh alone and add variances on read* (the user's 2026-10-14 idea): the audit trail is
  the same either way; every reader must add the variances, and mixing conventions subtracts
  twice. A true ledger would drop the stored qoh and sum all movements. The book does both: the
  movement rows are the ledger, and qoh is their cached balance.
- *Two columns on the item, reported qoh and qoh after variance*: one is derivable from the other
  plus the variances, so the two must be kept in agreement (update anomaly) for no gain. If
  "expected vs counted at the count" matters, it belongs on the variance row (the count event),
  not as a running column on the item.

### Fig 3.7 — Standard product pricing
**Transcription** (accepted 2026-10-16; open points under "Points to discuss after the overview"; two photos, the figure spans a page break)

```
PRICE COMPONENT
  # price_component_id
  * from_date
  o thru_date
  o price
  o percent
  o comment
  -> GEOGRAPHIC BOUNDARY  (many "based on" 1 boundary; boundary "a location used to define" many)
  -> PARTY TYPE           (many "based on" 1 type; type "used to define" many)
  -> PRODUCT CATEGORY     (many "based on" 1 category; category "used to define" many)
  -> QUANTITY BREAK       (many "based on" 1 break; break "a discount level defined for" many)
  -> ORDER VALUE          (many "based on" 1 value; value "a discount level defined for" many)
  -> SALE TYPE            (many "based on" 1 type; type "used to define" many)
  -> CURRENCY MEASURE     (many "in the currency of" 1 currency; currency "used in" many)
  -> PRODUCT              (many "a price defined for" 1 product; product "priced by" many)
  -> PRODUCT FEATURE      (many "a price defined for" 1 feature; feature "priced by" many)
  -> ORGANIZATION         (many "specified for" 1 org; org "the pricer of" many)
  subtypes, first box:
    BASE PRICE
    DISCOUNT COMPONENT
    SURCHARGE COMPONENT
    MANUFACTURER SUGGESTED PRICE
  subtypes, second box:
    ONE TIME CHARGE
    RECURRING CHARGE
      -> TIME FREQUENCY MEASURE?  (many "per" 1 unit; unit "used in" many)
    UTILIZATION CHARGE
      o quantity
      -> UNIT OF MEASURE          (many "per" 1 unit; unit "used in" many)

QUANTITY BREAK
  # quantity_break_id
  * from_quantity
  o thru_quantity

ORDER VALUE
  # order_value_id
  * from_amount
  o thru_amount

SALE TYPE
  # sale_type_id
  * description

UNIT OF MEASURE                   (Fig 3.4, now with subtypes)
  # uom_id
  * abbreviation
  * description
  subtypes:
    TIME FREQUENCY MEASURE
    CURRENCY MEASURE

GEOGRAPHIC BOUNDARY, PARTY TYPE, ORGANIZATION   (from Ch 2)
PRODUCT (3.1), PRODUCT CATEGORY (3.2), PRODUCT FEATURE (3.4)
```

**Discussion**
- **The naive model** puts `price` on PRODUCT, or keeps a price list of (product, price). That
  holds one price per product. It can't say "cheaper in the Midwest", "5% off 100 reams", "3%
  off for logistics companies", "1% off online" or "99 a month plus 5 per 1,000 pages", and
  without dates it loses every old price.
- **A price component is a rule, not a price.** Each row says what it is worth (an amount or a
  percent) and when it applies (its "based on" links, each one optional). The price of an order
  line is *computed*: collect every component whose conditions hold, pick the base price, apply
  the discounts and surcharges. The model stores the rules; how to combine them (which base
  wins when two apply, whether percents compound) is left to the application.
- **The conditions point at groups, not individuals:** a geographic boundary (not an
  address), a party type (not a customer), a product category, a quantity break, an order value
  band, a sale type. That's how one row can price thousands of order lines. It's the knowledge
  level again: rules about kinds of things, built on Ch 2's party types and 3.2's categories.
- **Two independent subtype sets.** The first says what the component does to the price:
  base, discount, surcharge, or the manufacturer's suggested price (information, not a charge).
  The second says how it's billed over time: once, every period (per month), or per use (per
  page, per hour). That's what services and subscriptions need.
- **A product, a feature, both, or neither.** A component can price a product, a feature on
  any product ("stapling finisher: 180"), a feature on one product ("duplex unit: 250 on the
  OfficeJet"), or no product at all: a rule that reaches products through a category, a party
  type or an order size.
- **The organization is the pricer** (our reading): whoever sets the price, an internal
  organization for our own prices, the manufacturer for a suggested price. Two divisions can
  then price the same product differently.
- **Currencies and time frequencies are units too,** so "in the currency of" and "per month"
  reuse UNIT OF MEASURE through two new subtypes.

### Fig 3.8 — Estimated product cost
**Transcription** (accepted 2026-10-16; open points under "Points to discuss after the overview")

```
ESTIMATED PRODUCT COST
  # cost_component_id     (named after "cost component", not after the entity)
  * from_date
  o thru_date
  * cost
  -> PRODUCT              (many "calculated for" 1 product; product "costed by" many)
  -> PRODUCT FEATURE      (many "calculated for" 1 feature; feature "costed by" many)
  (exclusive arc across PRODUCT and PRODUCT FEATURE: one or the other)
  -> COST COMPONENT TYPE  (many "categorized by" 1 type; type "used to define" many)
  -> GEOGRAPHIC BOUNDARY  (optional: many "specified for" 1 boundary;
                           boundary "used to further define" many)
  -> ORGANIZATION         (optional: many "specified for" 1 org; org "used to further define" many)
  subtypes:
    ESTIMATED MATERIALS COST
    ESTIMATED LABOR COST
    ESTIMATED OTHER COSTS

COST COMPONENT TYPE
  # cost_component_type_id
  * description
```

### Fig 3.9a — Product to product associations
**Transcription** (accepted 2026-10-16; open points under "Points to discuss after the overview")

```
PRODUCT COMPONENT
  * from_date
  o thru_date
  o quantity_used
  o instruction
  o comment
  -> PRODUCT  ("in": many components in 1 product; product "made up of" many)
  -> PRODUCT  ("for": many components for 1 product; product "used in" many)

PRODUCT SUBSTITUTE
  * from_date
  * thru_date              (printed mandatory)
  o quantity
  o comment
  -> PRODUCT  ("for" / product "substituted by")
  -> PRODUCT  ("a use of" / product "used as")

PRODUCT OBSOLESCENCE
  * supercession_date      (one date, no from/thru)
  o reason
  -> PRODUCT  ("for" / product "superseded by")
  -> PRODUCT  ("a use of" / product "a replacement")

PRODUCT COMPLEMENT
  * from_date
  o thru_date
  o reason
  -> PRODUCT  ("for" / product "complemented with")
  -> PRODUCT  ("a use of" / product "a complement for")

PRODUCT INCOMPATIBILITY
  * from_date
  o thru_date
  o reason
  -> PRODUCT  ("for" / product "incompatible with")
  -> PRODUCT  ("a use of" / product "incompatible with")

All ten lines: mandatory at the association end, optional at the product end, and each
carries the bar (part of the identifier). No attribute is marked #.

PRODUCT   (drawn without support_discontinuation_date, which Fig 3.1 has)
  subtypes: GOOD, SERVICE
```

The book spells two labels "superceded" and "complimented"; corrected here.

### Fig 3.9b — Product to product associations, alternate model
**Transcription** (accepted 2026-10-16; open points under "Points to discuss after the overview")

```
PRODUCT ASSOCIATION
  # from_date
  o thru_date
  o reason
  -> PRODUCT                   ("from": many associations from 1 product;
                                product "associated with" many; part of identifier)
  -> PRODUCT                   ("to": many associations to 1 product;
                                product "associated with" many; part of identifier)
  -> PRODUCT ASSOCIATION TYPE  (many "described by" 1 type; type "the description for" many)
  subtypes:
    MARKETING PACKAGE
      o quantity_used
      o instruction
    PRODUCT SUBSTITUTE
      o quantity
    PRODUCT OBSOLESCENCE
    PRODUCT COMPLEMENT
    PRODUCT INCOMPATIBILITY

PRODUCT ASSOCIATION TYPE
  # prod_assoc_type_id
  * description
```

Compared with 3.9a: PRODUCT COMPONENT becomes MARKETING PACKAGE; obsolescence drops its
supercession date (from_date does the job); the comments go; reason moves to the supertype.

### Fig 3.10a — Products and parts
**Transcription** (accepted 2026-10-16; open points under "Points to discuss after the overview")

```
PRODUCT COMPONENT          (3.9a's, redrawn)
  * from_date
  * thru_date              (printed mandatory again)
  o quantity_used
  o instruction
  o comment
  -> PRODUCT  ("in" / product "made up of"; part of identifier)
  -> PRODUCT  ("for" / product "used in"; part of identifier)

PRODUCT
  # product_id
  * name
  o introduction_date
  o sales_discontinuation_date
  o comment
  subtypes:
    RAW MATERIAL
    SUBASSEMBLY
    FINISHED GOOD
```

Here the subtypes hang straight off PRODUCT; Fig 3.11 puts the same three under GOOD.

### Fig 3.10b — Product and parts, alternate model
**Transcription** (accepted 2026-10-16; open points under "Points to discuss after the overview")

```
PART
  # part_id
  * name
  subtypes:
    RAW MATERIAL
    SUBASSEMBLY
    FINISHED GOOD

PART BOM
  # from_date
  o thru_date
  o quantity_used
  o instructions
  o comment
  -> PART  ("for" / part "made up of"; part of identifier)
  -> PART  ("in" / part "used in"; part of identifier)

PRODUCT
  # product_id
  * product_name           (NAME in the other figures)
  subtypes:
    GOOD
      -> FINISHED GOOD  (many goods "offered using" 1 finished good;
                         finished good "used to provide" many goods)
    SERVICE

INVENTORY ITEM             (Fig 3.6, now pointing at PART instead of GOOD)
  # inventory_item_id
  -> PART  (many "the physical occurrence of" 1 part; part "the generic description for" many)
  subtypes:
    SERIALIZED INVENTORY ITEM       * serial_num
    NON-SERIALIZED INVENTORY ITEM   * quantity_on_hand

PRICE COMPONENT            (Fig 3.7, now pointing at PART)
  # price_component_id, * from_date, o thru_date, o price, o percent, o comment
  -> PART  (many "specified for" 1 part; part "priced by" many)
  subtypes: BASE PRODUCT PRICE, DISCOUNT COMPONENT, SURCHARGE COMPONENT,
            MANUFACTURER SUGGESTED PRICE

REORDER GUIDELINE          (Fig 3.5, now pointing at PART)
  * from_date, o thru_date, o reorder_qty, o reorder_level
  -> PART  (many "a basis for ordering" 1 part; part "ordered using" many)

SUPPLIER OFFERING          (Fig 3.5's SUPPLIER PRODUCT, renamed, now pointing at PART)
  # available_from_date
  o available_thru_date
  o standard_lead_time
  o comment
  -> PART  (many "a valid supplier of" 1 part; part "supplied thru" many)
```

### Fig 3.11 — Overall product model
**Transcription** (accepted 2026-10-16; open points under "Points to discuss after the overview"; identifiers only, no attributes)

```
Shown, all from Figs 3.1–3.10:
  PRODUCT CATEGORY, PRODUCT CATEGORY ROLLUP, PRODUCT CATEGORY CLASSIFICATION, MARKET INTEREST,
  PARTY TYPE, PRODUCT (SERVICE, GOOD), GOOD IDENTIFICATION, PRODUCT FEATURE,
  PRODUCT FEATURE APPLICABILITY, PRODUCT FEATURE INTERACTION, UNIT OF MEASURE,
  UNIT OF MEASURE CONVERSION, SUPPLIER PRODUCT, ORGANIZATION, REORDER GUIDELINE,
  INVENTORY ITEM, INVENTORY ITEM STATUS TYPE, INVENTORY ITEM VARIANCE, LOT, CONTAINER,
  FACILITY, PRICE COMPONENT, ESTIMATED PRODUCT COST, PRODUCT ASSOCIATION

GOOD
  subtypes:
    RAW MATERIAL
    SUBASSEMBLY
    FINISHED GOOD
```

What it adds or settles:
- **GOOD gets 3.10a's subtypes** (raw material, subassembly, finished good).
- **Associations use 3.9b:** one PRODUCT ASSOCIATION with two lines to PRODUCT. No PRODUCT
  COMPONENT box, no PART.
- **Suppliers stay 3.5's:** SUPPLIER PRODUCT, pointing at PRODUCT and ORGANIZATION. So the
  overall model is the product-only one, not 3.10b's parts.
- GOOD IDENTIFICATION and INVENTORY ITEM point at GOOD (as we built them in 3.3 and 3.6).
- PRICE COMPONENT and ESTIMATED PRODUCT COST each point at PRODUCT and PRODUCT FEATURE.
- Left out: the lookups (feature category, preference, rating, reason, container type,
  identification type, sale type, cost component type, association type), QUANTITY BREAK,
  ORDER VALUE and GEOGRAPHIC BOUNDARY. I take that as abbreviation, not removal.

### Points to discuss after the overview (Figs 3.7–3.11)
The readings below stand, and the SQL follows them (the user's call, 2026-10-16). We look at
each once the chapter overview is done. Any refactor waits until then and aims at what
Silverston intended, not at the literal drawing.

1. **3.7, two subtype boxes:** read as two independent subtype sets (base / discount /
   surcharge / suggested, and one-time / recurring / utilization).
2. **3.7, RECURRING CHARGE "per":** read as ending at TIME FREQUENCY MEASURE; the line may stop
   at UNIT OF MEASURE itself. UTILIZATION CHARGE's ends at UNIT OF MEASURE.
3. **3.7, optionality:** every line read as dashed (optional) at both ends, including PRODUCT,
   PRODUCT FEATURE and ORGANIZATION.
4. **3.7 vs 3.10b, naming:** BASE PRICE vs BASE PRODUCT PRICE.
5. **3.8:** the arc spans the two "calculated for" lines, both solid at the cost end (each
   estimate is for exactly one product or feature). COST COMPONENT TYPE is mandatory;
   geography and organization are optional.
6. **3.9a and 3.10a, thru dates printed `*`** on PRODUCT SUBSTITUTE and PRODUCT COMPONENT:
   read as slips, so thru dates stay nullable.
7. **3.9a identifiers:** from_date is `*`, not `#`, on all five entities (3.9b marks it `#`);
   the bar is on all ten product lines.
8. **3.9b:** the type line read as solid at the association end and without a bar, so the
   identifier is from product + to product + from_date.
9. **3.10b:** one finished good backs many goods (crow's foot at GOOD, dashed line); PART BOM's
   two lines carry the bar; the organization links and PRICE COMPONENT's other links are
   unchanged, just not drawn.
10. **3.11:** REORDER GUIDELINE's line read as ending at GOOD, as in 3.5.

## Design decisions (book → SQL)

### Fig 3.1
- **GOOD / SERVICE become a `product_kind` discriminator** (check constraint), not subtype
  tables: exclusive, and no attributes of their own yet. If later figures give GOOD its own
  attributes or relationships, add a `good` table sharing `product_id`, as with `person`
  (done in Fig 3.3).
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
- **Rollup has no dates,** following the figure (confirmed). If the catalogue is
  reorganised, the old structure is lost; add from/thru if category history matters.
- **Parent/child columns:** `parent_product_category_id` ("made up of") and
  `child_product_category_id` ("part of"). A check stops a category being its own parent;
  longer cycles are a data-quality query (seed: Recycled ↔ Recycled paper).
- **Addition: `product_category_ancestor` view** (like Ch 2's `role_type_ancestor`), using
  `union` so a cycle ends the walk instead of hanging the query. "Products in category X"
  means X itself plus every category whose ancestor is X.
- **Surrogate `product_category_classification_id`** instead of (product, category, from_date).
- **One current primary per product is a data-quality query** (seed: the pen is primary in both
  Writing instruments and Plastic). The book doesn't say one per what, so "one per product" is
  our choice. One per product *per dimension* (or per owning department) is a valid
  alternative; we discussed it on 2026-10-10 and kept the simpler rule.
- **`market_interest.party_type_id` references Ch 2's `party_type`.** Nothing stops an interest
  pointing at a grouping type (INDUSTRY) rather than a value (IND_LOGISTICS); the query only
  matches exact types.

### Fig 3.3
- **Identification subtypes become `identification_type` rows** (MANUFACTURER_ID, SKU, UPCA,
  UPCE, ISBN, OTHER), in the book's own IDENTIFICATION TYPE table.
- **New `good` subtype table** (`product_id` PK and FK to `product`), because GOOD now has a
  relationship of its own; this is the escape hatch noted under Fig 3.1. `product_kind` stays
  as the discriminator, and a data-quality query checks the two agree (seed: the maintenance
  plan, a SERVICE, has a `good` row). `good_identification.product_id` references `good`, so
  a service can't get a code at all. CNS109 stays in `product.comment`.
- **Surrogate `good_identification_id`** instead of the book's (product, type) identifier.
  "One value per type per product" is a data-quality query (seed: toner has two SKUs).
- **Addition: "one code, one product" data-quality query** (seed: the pen and the copier share a
  UPC). This is the rule a barcode scanner relies on.
- **Addition: `identification_type.value_pattern`**, a regex each code of that type must
  match (UPC-A 12 digits, UPC-E 8, ISBN 10 or 13). A rule stored as data, checked by a
  data-quality query (seed: an 11-digit UPC). Check digits aren't verified.
- **The book's Table 3.1 codes (PAP192…) are stored as SKUs** for the goods.

### Fig 3.4
- **`product.uom_id` is added with `alter table` in the 3.4 section**, so the schema still
  reads in book order. Nullable, as in the book.
- **Feature subtypes become `product_feature_type` rows.** DIMENSION's `number_specified` is a
  nullable column on `product_feature`, and so is `uom_id` (the book links the unit to DIMENSION
  only). A data-quality query checks that dimensions have a number and other kinds have neither
  a number nor a unit; a dimension's unit is optional, as in the book (seed: a Height with no
  number, a Grey with a number, hourly billing with a unit). Same
  approach as `federal_tax_id_num` in Ch 2.
- **Applicability subtypes → `product_feature_applicability_type`; interaction subtypes →
  `product_feature_interaction_type`.** Exclusive and attribute-less, so rows.
- **`product_feature.product_feature_category_id` is nullable**, as in the book.
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
- **Not enforced:** a SELECTABLE feature must be chosen. The book doesn't define the set to
  choose from; our reading is "one of the product's selectable features of the same feature
  type" (one colour). The configuration check doesn't test it yet.

### Fig 3.5
- **`product.manufacturer_party_id`** (FK to `organization`), nullable, added by `alter table` in
  the 3.5 section to keep book order.
- **Surrogate `supplier_product_id`** instead of the book's (product, supplier, available from)
  identifier. Overlapping periods for the same pair are a data-quality query (seed: Paperline
  paper twice).
- **`standard_lead_time` is whole days**; the book gives no unit.
- **The figure links to ORGANIZATION, not to a role,** so FKs go to `organization`. Two
  data-quality queries check the roles: a supplier needs a current SUPPLIER role (seed:
  Goldstein), and a guideline's internal organization needs INTERNAL_ORGANIZATION (seed: ACME, a
  customer).
- **`reorder_guideline.product_id` references `good`** (the Fig 3.3 subtype table), so a service
  can't get a guideline. The three bases are nullable and independent (no arc in the figure).
  Overlapping guidelines for the same good and basis are a data-quality query (seed: two current
  Chatham paper rules).
- **Seed organizations start at party 40** to stay clear of Ch 2's ids. Preference and rating
  values are ours; the book only shows the entities.

### Fig 3.6
- **Inventory item subtypes become `inventory_item_kind`** (SERIALIZED / NON_SERIALIZED) plus
  nullable `serial_num` and `quantity_on_hand`, as with DIMENSION's number in Fig 3.4. A
  data-quality query checks the combination (seed: scrap diskettes with a serial number).
- **The arc is a check constraint** (`num_nonnulls(facility_id, container_id) = 1`): a single-row
  rule, like `thru_date > from_date`, so no bad seed row is possible.
- **`inventory_item.product_id` references `good`**: services can't be stocked.
- **Serial numbers unique per good** is a data-quality query (seed: copier OJ900-0001 twice).
- **Addition: `container.description`** ("Bin A-12"); the book shows only the id.
- **Variance:** `quantity` is the signed adjustment. Surrogate key instead of (item, count
  date); duplicates are a data-quality query. Whether `quantity_on_hand` already includes the
  variances is left to the application (see Open questions).
- **The reorder query compares only facility-based guidelines** with stock at that facility.
  Region- or organization-based guidelines would need stock rolled up by geography or owner.

### Fig 3.7
- **UNIT OF MEASURE subtypes become two subtype tables** (`time_frequency_measure`,
  `currency_measure`) sharing `uom_id`, as GOOD did in 3.3: each has a relationship of its own,
  so `price_component.currency_uom_id` references `currency_measure` and a plain FK insists on
  a currency. No discriminator, because most units (each, ream, inch) are neither.
- **First subtype set → `price_component_type`** lookup rows (BASE_PRICE, DISCOUNT, SURCHARGE,
  MSRP), mandatory.
- **Second subtype set → `charge_kind`** (ONE_TIME / RECURRING / UTILIZATION) plus nullable
  `per_uom_id` and `quantity`, as in 3.6. Nullable, because a ream of paper's base price is no
  kind of charge (discussion point 1). A data-quality query checks the combination (seed: a
  recurring charge "per each").
- **One `per_uom_id` for both "per" lines:** the figure draws two relationships (from RECURRING
  and from UTILIZATION) for one role. It references `unit_of_measure`, and the data-quality
  query requires a time frequency for RECURRING (discussion point 2).
- **UTILIZATION's `quantity`** (our reading): per how many units, as in 5 USD per 1,000 pages;
  null means 1.
- **Price or percent:** both optional in the book. A data-quality query checks them per type
  (base and suggested prices need an amount; discounts and surcharges one of the two) and that
  an amount has a currency (seed: a discount with both). Stored positive; the type gives the sign.
- **Quantity break and order value thru values are exclusive,** like thru dates, so bands meet
  without gaps (100 ≤ quantity < 1000). The book gives order values no currency; ours are USD.
- **No arc between product and feature,** unlike 3.8: a component may name both.
- **`pricer_party_id`** for the organization ("specified for" / "the pricer of"), named like
  `manufacturer_party_id` and `supplier_party_id`.
- **The combining rules in the "Price a line" query are ours,** not the book's: the most
  specific base price wins (most conditions met, then the lowest), percents apply to that base
  without compounding, amounts are per unit, and the suggested price is left out.
- **Duplicate rules** (same type and conditions, overlapping periods) are a data-quality query
  (seed: the pen at 2.50 and 2.75).

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

**Supplier products and reorder guidelines (3.5):**
- With a single supplier per product and one warehouse, `supplier_id` and `reorder_level`
  columns on product are fine. Reach for SUPPLIER PRODUCT when purchasing compares sources or
  switches suppliers, and for scoped guidelines once stock sits in more than one place.

**Inventory items (3.6):**
- A shop with one stockroom can keep a quantity per product. Inventory items pay off with
  several locations, stock in different states, serial-number tracking or lot recalls.

**Price components (3.7):**
- A shop with one price per product and the odd promotion needs a dated price table, nothing
  more. Price components pay off with many discount rules (volume, segment, region, channel),
  subscription or usage billing, or several organizations setting prices. The cost: a price
  is a calculation, not a lookup, and the combining rules live in code, so two applications can
  compute different prices from the same rows.

## Open questions
- **Fig 3.6:** is `quantity_on_hand` updated when a variance is recorded, or is the true
  quantity "on hand + variances"? The figure doesn't say.
- **Figs 3.2–3.4 were built before they were confirmed** (at the user's request, 2026-10-10).
  The "Check against the book" items under each figure are still open; the SQL follows our
  reading.
- **Fig 3.4:** conversions are per unit pair, so a product-specific pack size ("a box of forms
  holds 50") has nowhere to live. Does a later figure (inventory, supplier products) solve
  this? Not in Ch 3: Figs 3.5–3.11 add no product-specific conversion.
