# Vol 1, Chapter 3 — ER diagram

The diagram shows what `schema.sql` implements, not the book's figures.
GOOD and SERVICE are values of `product.product_kind`, not tables.
Every table has a single-column key and plain foreign keys.

```mermaid
erDiagram
  %% Fig 3.1 — Product definition
  PRODUCT {
    int  product_id PK
    text product_kind "GOOD or SERVICE"
  }

  %% Fig 3.2 — Product category
  PRODUCT                 ||--o{ PRODUCT_CATEGORY_CLASSIFICATION : "categorized by"
  PRODUCT_CATEGORY        ||--o{ PRODUCT_CATEGORY_CLASSIFICATION : "used to define"
  PRODUCT_CATEGORY_TYPE   ||--o{ PRODUCT_CATEGORY                : "dimension of"
  PRODUCT_CATEGORY        ||--o{ PRODUCT_CATEGORY_ROLLUP         : "made up of (parent)"
  PRODUCT_CATEGORY        ||--o{ PRODUCT_CATEGORY_ROLLUP         : "part of (child)"
  PRODUCT_CATEGORY        ||--o{ MARKET_INTEREST                 : "of interest to"
  PARTY_TYPE              ||--o{ MARKET_INTEREST                 : "interested in (Ch 2)"

  %% Fig 3.3 — Product identification
  PRODUCT                 ||--o{ GOOD_IDENTIFICATION             : "identified by"
  IDENTIFICATION_TYPE     ||--o{ GOOD_IDENTIFICATION             : "used to define"

  %% Fig 3.4 — Product feature
  PRODUCT_FEATURE_TYPE               ||--o{ PRODUCT_FEATURE               : "kind of"
  PRODUCT_FEATURE_CATEGORY           |o--o{ PRODUCT_FEATURE               : "the category for"
  UNIT_OF_MEASURE                    |o--o{ PRODUCT_FEATURE               : "used in"
  UNIT_OF_MEASURE                    |o--o{ PRODUCT                       : "used in"
  UNIT_OF_MEASURE                    ||--o{ UNIT_OF_MEASURE_CONVERSION    : "converted from"
  UNIT_OF_MEASURE                    ||--o{ UNIT_OF_MEASURE_CONVERSION    : "converted into"
  PRODUCT                            ||--o{ PRODUCT_FEATURE_APPLICABILITY : "available with"
  PRODUCT_FEATURE                    ||--o{ PRODUCT_FEATURE_APPLICABILITY : "used to define"
  PRODUCT_FEATURE_APPLICABILITY_TYPE ||--o{ PRODUCT_FEATURE_APPLICABILITY : "describes"
  PRODUCT_FEATURE                    ||--o{ PRODUCT_FEATURE_INTERACTION   : "selected in (of)"
  PRODUCT_FEATURE                    ||--o{ PRODUCT_FEATURE_INTERACTION   : "a factor in"
  PRODUCT                            |o--o{ PRODUCT_FEATURE_INTERACTION   : "context for"
  PRODUCT_FEATURE_INTERACTION_TYPE   ||--o{ PRODUCT_FEATURE_INTERACTION   : "describes"
```
