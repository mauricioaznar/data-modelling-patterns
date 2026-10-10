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
```
