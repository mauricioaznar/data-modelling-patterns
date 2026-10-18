# Vol 1, Chapter 4 — ER diagram

The diagram shows what `schema.sql` implements, not the book's figures. Fig 4.1 isn't built.
SALES and PURCHASE are values of `"order".order_kind`; each also has a subtype table
(`sales_order`, Fig 4.3; `purchase_order`, Fig 4.4). An item's kind is its order's; sales and
purchase items have subtype tables (`sales_order_item`, `purchase_order_item`). Every table has a single-column key and plain foreign keys.

```mermaid
erDiagram
  %% Fig 4.2 — Orders and order items
  ORDER {
    int  order_id PK
    text order_kind "SALES or PURCHASE"
    date order_date
  }
  ORDER                   ||--o{ ORDER_ITEM          : "composed of"
  PRODUCT                 ||--o{ ORDER_ITEM          : "ordered via (Ch 3)"
  PRODUCT_FEATURE         ||--o{ ORDER_ITEM          : "ordered via (Ch 3)"
  ORDER_ITEM              ||--o{ ORDER_ITEM          : "ordered with (features under their product)"
  ORDER_ITEM              ||--o| SALES_ORDER_ITEM    : "subtype (on a sales order)"

  %% Fig 4.3 — Sales order parties and contact mechanisms
  ORDER                   ||--o| SALES_ORDER         : "subtype (kind SALES)"
  PARTY_ROLE              ||--o{ SALES_ORDER         : "placer of / fulfiller of / bill-to (Ch 2)"
  CONTACT_MECHANISM       ||--o{ SALES_ORDER         : "placed using / taken via / billed to (Ch 2)"
  PARTY_ROLE              ||--o{ SALES_ORDER_ITEM    : "requested ship-to"
  CONTACT_MECHANISM       ||--o{ SALES_ORDER_ITEM    : "shipping location for"
  ORDER                   ||--o{ ORDER_ROLE          : "involving"
  PARTY                   ||--o{ ORDER_ROLE          : "involved in (Ch 2)"
  ORDER_ROLE_TYPE         ||--o{ ORDER_ROLE          : "description for"

  %% Fig 4.4 — Purchase order parties and contact mechanisms (4.3 turned over)
  ORDER                   ||--o| PURCHASE_ORDER      : "subtype (kind PURCHASE)"
  ORDER_ITEM              ||--o| PURCHASE_ORDER_ITEM : "subtype (on a purchase order)"
  PARTY_ROLE              ||--o{ PURCHASE_ORDER      : "placer of / fulfiller of / bill-to (Ch 2)"
  CONTACT_MECHANISM       ||--o{ PURCHASE_ORDER      : "placed using / taken via / billed to (Ch 2)"
  PARTY_ROLE              ||--o{ PURCHASE_ORDER_ITEM : "requested ship-to"
  CONTACT_MECHANISM       ||--o{ PURCHASE_ORDER_ITEM : "shipping location for"

  %% Fig 4.5 — Generic order roles and contact mechanisms (built beside 4.3 and 4.4)
  ORDER_ITEM              ||--o{ ORDER_ITEM_ROLE              : "involving"
  PARTY                   ||--o{ ORDER_ITEM_ROLE              : "involved in (Ch 2)"
  ORDER_ITEM_ROLE_TYPE    ||--o{ ORDER_ITEM_ROLE              : "description for"
  ORDER                   ||--o{ ORDER_CONTACT_MECHANISM      : "having"
  CONTACT_MECHANISM       ||--o{ ORDER_CONTACT_MECHANISM      : "used in (Ch 2)"
  CONTACT_MECHANISM_PURPOSE_TYPE ||--o{ ORDER_CONTACT_MECHANISM : "for (Ch 2)"
  ORDER_ITEM              ||--o{ ORDER_ITEM_CONTACT_MECHANISM : "having"
  CONTACT_MECHANISM       ||--o{ ORDER_ITEM_CONTACT_MECHANISM : "used in (Ch 2)"
  CONTACT_MECHANISM_PURPOSE_TYPE ||--o{ ORDER_ITEM_CONTACT_MECHANISM : "for (Ch 2)"

  %% Fig 4.6 — Order adjustments (for the order OR one item: a data-quality query)
  ORDER                   |o--o{ ORDER_ADJUSTMENT    : "affected by"
  ORDER_ITEM              |o--o{ ORDER_ADJUSTMENT    : "affected by"
  ORDER_ADJUSTMENT_TYPE   ||--o{ ORDER_ADJUSTMENT    : "description for"
  ORDER_ADJUSTMENT_TYPE   |o--o{ ORDER_ADJUSTMENT_TYPE : "parent of (the six subtypes on top)"
  GEOGRAPHIC_BOUNDARY     ||--o{ SALES_TAX_LOOKUP    : "taxed via (Ch 2)"
  PRODUCT_CATEGORY        |o--o{ SALES_TAX_LOOKUP    : "a consideration for (Ch 3)"
```
