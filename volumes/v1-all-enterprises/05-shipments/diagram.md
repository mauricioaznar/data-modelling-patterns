# Vol 1, Chapter 5 — ER diagram

The diagram shows what `schema.sql` implements, not the book's figures. The shipment subtypes
are rows of `shipment_type` (a hierarchy: OUTGOING and INCOMING over their pairs, TRANSFER and
DROP_SHIPMENT alone). Every table has a single-column key and plain foreign keys.

```mermaid
erDiagram
  %% Fig 5.1 — Shipment definition
  SHIPMENT {
    int  shipment_id PK
    text shipment_type_id FK
    date estimated_ship_date
    date estimated_arrival_date
  }
  SHIPMENT_TYPE {
    text shipment_type_id PK
    text parent_type_id FK
    bool from_internal "ours"
    bool to_internal "ours"
  }
  SHIPMENT_TYPE             ||--o{ SHIPMENT          : "describes"
  SHIPMENT_TYPE             |o--o{ SHIPMENT_TYPE     : "groups"
  PARTY                     ||--o{ SHIPMENT          : "the sender of (Ch 2)"
  PARTY                     ||--o{ SHIPMENT          : "the receiver of (Ch 2)"
  POSTAL_ADDRESS            |o--o{ SHIPMENT          : "the source of (Ch 2)"
  POSTAL_ADDRESS            |o--o{ SHIPMENT          : "the destination of (Ch 2)"
  CONTACT_MECHANISM         |o--o{ SHIPMENT          : "used to inquire about (Ch 2)"
  TELECOMMUNICATIONS_NUMBER |o--o{ SHIPMENT          : "the receiving contact number for (Ch 2)"

  %% Fig 5.2 — Shipping detail
  SHIPMENT_ITEM {
    int     shipment_item_id PK
    int     shipment_id FK
    int     shipment_item_seq_id "line number"
    int     product_id FK "a good, or null"
    numeric quantity
  }
  SHIPMENT                  ||--o{ SHIPMENT_ITEM     : "composed of"
  GOOD                      |o--o{ SHIPMENT_ITEM     : "shipped via (Ch 3)"
  SHIPMENT_ITEM             |o--o{ SHIPMENT_ITEM     : "generating (in response to)"
  SHIPMENT                  ||--o{ SHIPMENT_STATUS   : "tracked using"
  STATUS_TYPE               ||--o{ SHIPMENT_STATUS   : "used to define (Ch 2, SHIPMENT_STATUS group)"

  %% Fig 5.3 — Shipment-to-order relationship
  ORDER_SHIPMENT {
    int     order_shipment_id PK
    int     order_item_id FK
    int     shipment_item_id FK
    numeric quantity
  }
  ORDER_ITEM                ||--o{ ORDER_SHIPMENT        : "shipped via (Ch 4)"
  SHIPMENT_ITEM             ||--o{ ORDER_SHIPMENT        : "the shipment of"
  SHIPMENT_ITEM             ||--o{ SHIPMENT_ITEM_FEATURE : "shipped with"
  PRODUCT_FEATURE           ||--o{ SHIPMENT_ITEM_FEATURE : "shipped via (Ch 3)"

  %% Fig 5.4 — Shipment receipt for incoming shipments (no line from package to shipment)
  SHIPMENT_RECEIPT {
    int         shipment_receipt_id PK
    int         shipment_package_id FK
    int         product_id FK "a good, or null"
    timestamptz datetime_received
    numeric     quantity_accepted
    numeric     quantity_rejected
  }
  SHIPMENT_PACKAGE           ||--o{ PACKAGING_CONTENT     : "composed of"
  SHIPMENT_ITEM              ||--o{ PACKAGING_CONTENT     : "packaged within"
  SHIPMENT_PACKAGE           ||--o{ SHIPMENT_RECEIPT      : "consisting of"
  GOOD                       |o--o{ SHIPMENT_RECEIPT      : "the description for (Ch 3)"
  INVENTORY_ITEM             |o--o{ SHIPMENT_RECEIPT      : "the destination for (Ch 3)"
  ORDER_ITEM                 |o--o{ SHIPMENT_RECEIPT      : "accounted for via (Ch 4)"
  REJECTION_REASON           |o--o{ SHIPMENT_RECEIPT      : "the reason for rejection of"
  SHIPMENT_RECEIPT           ||--o{ SHIPMENT_RECEIPT_ROLE : "involving"
  PARTY                      ||--o{ SHIPMENT_RECEIPT_ROLE : "involved in (Ch 2)"
  SHIPMENT_RECEIPT_ROLE_TYPE ||--o{ SHIPMENT_RECEIPT_ROLE : "the description for"
```
