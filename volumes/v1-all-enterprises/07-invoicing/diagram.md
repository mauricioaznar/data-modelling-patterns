# Vol 1, Chapter 7 — ER diagram

The diagram shows what `schema.sql` implements, not the book's figures. Sales and purchase
invoices are an `invoice_kind` discriminator; invoice item types are a hierarchy
(ACQUIRING_ITEM and ADJUSTMENT over their leaves, 7.1b's two subtype sets). The billed-to arc
(a party or a billing account, exactly one) is a check constraint. Earlier chapters' tables
show only the columns Ch 7 touches. Every table has a single-column key and plain foreign
keys.

```mermaid
erDiagram
  %% Fig 7.1a — Invoice and invoice items
  INVOICE {
    int  invoice_id PK
    text invoice_kind "SALES or PURCHASE"
    date invoice_date
    text message
    text description
    int  billed_to_party_id FK "7.2; arc with billing_account_id"
    int  billed_from_party_id FK "7.2"
    int  addressed_to_contact_mechanism_id FK "7.2"
    int  sent_from_contact_mechanism_id FK "7.2"
    int  billing_account_id FK "7.3a"
  }
  INVOICE_ITEM_TYPE {
    text invoice_item_type_id PK
    text parent_type_id FK
    text description
  }
  INVOICE_ITEM {
    int     invoice_item_id PK
    int     invoice_id FK
    int     invoice_item_seq_id
    text    invoice_item_type_id FK
    int     product_id FK
    int     product_feature_id FK
    int     inventory_item_id FK
    int     adjustment_for_invoice_item_id FK
    int     sold_with_invoice_item_id FK
    boolean taxable_flag
    numeric quantity
    numeric amount
    text    item_description
  }
  PRODUCT { int product_id PK }
  PRODUCT_FEATURE { int product_feature_id PK }
  INVENTORY_ITEM { int inventory_item_id PK }

  INVOICE ||--o{ INVOICE_ITEM : "composed of"
  INVOICE_ITEM_TYPE ||--o{ INVOICE_ITEM : "the description for"
  INVOICE_ITEM_TYPE |o--o{ INVOICE_ITEM_TYPE : "parent of"
  PRODUCT |o--o{ INVOICE_ITEM : "billed via"
  PRODUCT_FEATURE |o--o{ INVOICE_ITEM : "billed via"
  INVENTORY_ITEM |o--o{ INVOICE_ITEM : "billed via"
  INVOICE_ITEM |o--o{ INVOICE_ITEM : "adjusted by"
  INVOICE_ITEM |o--o{ INVOICE_ITEM : "sold with"

  %% Fig 7.2 — Invoice parties
  PARTY { int party_id PK }
  CONTACT_MECHANISM { int contact_mechanism_id PK }
  INVOICE_ROLE_TYPE {
    text invoice_role_type_id PK
    text description
  }
  INVOICE_ROLE {
    int         invoice_role_id PK
    int         invoice_id FK
    int         party_id FK
    text        invoice_role_type_id FK
    timestamptz role_datetime
    numeric     percentage
  }

  PARTY |o--o{ INVOICE : "the receiver of"
  PARTY ||--o{ INVOICE : "the sender of"
  CONTACT_MECHANISM |o--o{ INVOICE : "used for billing"
  CONTACT_MECHANISM |o--o{ INVOICE : "used for sending"
  INVOICE ||--o{ INVOICE_ROLE : "involving"
  PARTY ||--o{ INVOICE_ROLE : "involved in"
  INVOICE_ROLE_TYPE ||--o{ INVOICE_ROLE : "the description of"

  %% Fig 7.3a — Billing account
  BILLING_ACCOUNT {
    int  billing_account_id PK
    date from_date
    date thru_date
    text description
    int  billed_at_contact_mechanism_id FK
  }
  BILLING_ACCOUNT_ROLE_TYPE {
    text billing_account_role_type_id PK
    text description
  }
  BILLING_ACCOUNT_ROLE {
    int  billing_account_role_id PK
    int  billing_account_id FK
    int  party_id FK
    text billing_account_role_type_id FK
    date from_date
    date thru_date
  }
  SALES_ORDER {
    int order_id PK "Ch 4"
    int bill_to_billing_account_id FK "new; arc with the bill-to role"
  }
  PURCHASE_ORDER {
    int order_id PK "Ch 4"
    int bill_to_billing_account_id FK "new; arc with the bill-to role"
  }

  BILLING_ACCOUNT |o--o{ INVOICE : "billed for"
  CONTACT_MECHANISM ||--o{ BILLING_ACCOUNT : "the billing mechanism for"
  BILLING_ACCOUNT ||--o{ BILLING_ACCOUNT_ROLE : "used by"
  PARTY ||--o{ BILLING_ACCOUNT_ROLE : "associated with"
  BILLING_ACCOUNT_ROLE_TYPE ||--o{ BILLING_ACCOUNT_ROLE : "the description of"
  BILLING_ACCOUNT |o--o{ SALES_ORDER : "requested bill to"
  BILLING_ACCOUNT |o--o{ PURCHASE_ORDER : "requested bill to"
```
