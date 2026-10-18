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
```
