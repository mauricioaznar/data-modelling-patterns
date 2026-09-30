# Vol 1, Chapter 2 — ER diagram

The diagram shows what `schema.sql` implements, not the book's figures.
`person_flat` (Fig 2.2a) is also loaded, for comparison only, and is left out here.

`PERSON` and `ORGANIZATION` are subtypes of `PARTY`: they share its `party_id` (1:1).
`party_kind` says which one a party should be (checked by a data-quality query).
Every table has a single-column key and plain foreign keys.

```mermaid
erDiagram
  %% Fig 2.3 — Party supertype and classification
  PARTY        ||--o| PERSON               : "is a"
  PARTY        ||--o| ORGANIZATION         : "is a"
  PARTY        ||--o{ PARTY_CLASSIFICATION : "classified into"
  PARTY_TYPE   ||--o{ PARTY_CLASSIFICATION : "the description for"
  PARTY_TYPE   |o--o{ PARTY_TYPE           : "parent of"

  %% Fig 2.4 — Party roles
  PARTY     ||--o{ PARTY_ROLE : "acting as"
  ROLE_TYPE ||--o{ PARTY_ROLE : "describes"
  ROLE_TYPE |o--o{ ROLE_TYPE  : "parent of"

  %% Fig 2.1 — Organization
  ORGANIZATION_TYPE |o--o{ ORGANIZATION_TYPE : "parent of"
  ORGANIZATION_TYPE ||--o{ ORGANIZATION      : "classifies"

  %% Fig 2.2b — Person, alternate model
  GENDER_TYPE                  ||--o{ PERSON                  : "for"
  PERSON                       ||--o{ PERSON_NAME             : "referred to as"
  PERSON_NAME_TYPE             ||--o{ PERSON_NAME             : "describes"
  PERSON                       ||--o{ MARITAL_STATUS          : "having"
  MARITAL_STATUS_TYPE          ||--o{ MARITAL_STATUS          : "describes"
  PERSON                       ||--o{ PHYSICAL_CHARACTERISTIC : "having"
  PHYSICAL_CHARACTERISTIC_TYPE ||--o{ PHYSICAL_CHARACTERISTIC : "describes"
  PERSON                       ||--o{ CITIZENSHIP             : "from"
  COUNTRY                      ||--o{ CITIZENSHIP             : "for"
  CITIZENSHIP                  ||--o{ PASSPORT                : "issuer of"

  PARTY {
    int  party_id PK
    text party_kind "PERSON | ORGANIZATION"
  }
  PARTY_TYPE {
    text party_type_id PK
    text parent_type_id FK
    text applies_to_kind "PERSON | ORGANIZATION"
    text description
  }
  PARTY_CLASSIFICATION {
    int  party_classification_id PK
    int  party_id FK
    text party_type_id FK
    date from_date
    date thru_date
  }
  ROLE_TYPE {
    text role_type_id PK
    text parent_type_id FK
    text applies_to_kind "PERSON | ORGANIZATION | EITHER | null = grouping"
    text description
  }
  PARTY_ROLE {
    int  party_role_id PK
    int  party_id FK
    text role_type_id FK
    date from_date
    date thru_date
  }
  ORGANIZATION_TYPE {
    text organization_type_id PK
    text parent_type_id FK
    text description
  }
  ORGANIZATION {
    int  party_id PK, FK
    text organization_type_id FK
    text name
    text federal_tax_id_num "legal orgs only"
  }
  PERSON {
    int  party_id PK, FK
    text gender_type_id FK
    date birth_date
    text mothers_maiden_name
    text social_security_no
    int  total_years_work_experience
    text comment
  }
  PERSON_NAME {
    int  person_name_id PK
    int  party_id FK
    text person_name_type_id FK
    date from_date
    date thru_date
    text name
  }
  MARITAL_STATUS {
    int  marital_status_id PK
    int  party_id FK
    text marital_status_type_id FK
    date from_date
    date thru_date
  }
  PHYSICAL_CHARACTERISTIC {
    int  physical_characteristic_id PK
    int  party_id FK
    text physical_characteristic_type_id FK
    date from_date
    date thru_date
    text value
  }
  CITIZENSHIP {
    int  citizenship_id PK
    int  party_id FK
    text country_id FK
    date from_date
    date thru_date
  }
  PASSPORT {
    int  passport_id PK
    int  citizenship_id FK
    text passport_num
    date issue_date
    date expiration_date
  }
  COUNTRY {
    text country_id PK
    text name
  }
```
