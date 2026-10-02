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

  %% Fig 2.5 — Specific party relationships (each links two party roles)
  PARTY_ROLE ||--o{ EMPLOYMENT            : "employer of"
  PARTY_ROLE ||--o{ EMPLOYMENT            : "employed within"
  PARTY_ROLE ||--o{ CUSTOMER_RELATIONSHIP : "customer in"
  PARTY_ROLE ||--o{ CUSTOMER_RELATIONSHIP : "internal org in"
  PARTY_ROLE ||--o{ ORGANIZATION_ROLLUP   : "within"
  PARTY_ROLE ||--o{ ORGANIZATION_ROLLUP   : "made up of"

  %% Fig 2.6a — Common party relationships (generic)
  PARTY_RELATIONSHIP_TYPE ||--o{ PARTY_RELATIONSHIP      : "describes"
  PARTY_ROLE              ||--o{ PARTY_RELATIONSHIP      : "from"
  PARTY_ROLE              ||--o{ PARTY_RELATIONSHIP      : "to"
  ROLE_TYPE               ||--o{ PARTY_RELATIONSHIP_TYPE : "used to define (from)"
  ROLE_TYPE               ||--o{ PARTY_RELATIONSHIP_TYPE : "used to define (to)"

  %% Fig 2.7 — Party relationship information
  PRIORITY_TYPE      |o--o{ PARTY_RELATIONSHIP  : "set the priority for"
  STATUS_TYPE        |o--o{ PARTY_RELATIONSHIP  : "set the status for"
  STATUS_TYPE        |o--o{ STATUS_TYPE         : "parent of"
  PARTY_RELATIONSHIP |o--o{ COMMUNICATION_EVENT : "contacted via"

  %% Fig 2.8 — Postal address information
  POSTAL_ADDRESS           ||--o{ POSTAL_ADDRESS_BOUNDARY         : "within"
  GEOGRAPHIC_BOUNDARY      ||--o{ POSTAL_ADDRESS_BOUNDARY         : "for"
  GEOGRAPHIC_BOUNDARY      ||--o{ GEOGRAPHIC_BOUNDARY_ASSOCIATION : "from (within)"
  GEOGRAPHIC_BOUNDARY      ||--o{ GEOGRAPHIC_BOUNDARY_ASSOCIATION : "to (in)"
  GEOGRAPHIC_BOUNDARY_TYPE ||--o{ GEOGRAPHIC_BOUNDARY             : "the description for"

  %% Fig 2.9 — Party contact mechanism
  PARTY                  ||--o{ PARTY_CONTACT_MECHANISM   : "contacted via"
  CONTACT_MECHANISM      ||--o{ PARTY_CONTACT_MECHANISM   : "used by"
  CONTACT_MECHANISM      ||--o| TELECOMMUNICATIONS_NUMBER : "is a"
  CONTACT_MECHANISM      ||--o| ELECTRONIC_ADDRESS        : "is a"
  CONTACT_MECHANISM_TYPE ||--o{ CONTACT_MECHANISM         : "the description for"

  %% Fig 2.10 — Party contact mechanism (expanded); postal address joins the subtypes
  CONTACT_MECHANISM              ||--o| POSTAL_ADDRESS                  : "is a"
  ROLE_TYPE                      |o--o{ PARTY_CONTACT_MECHANISM         : "used to specify"
  PARTY_CONTACT_MECHANISM        ||--o{ PARTY_CONTACT_MECHANISM_PURPOSE : "used for the purpose of"
  CONTACT_MECHANISM_PURPOSE_TYPE ||--o{ PARTY_CONTACT_MECHANISM_PURPOSE : "used to specify"
  CONTACT_MECHANISM              ||--o{ CONTACT_MECHANISM_LINK          : "from"
  CONTACT_MECHANISM              ||--o{ CONTACT_MECHANISM_LINK          : "to"

  %% Fig 2.11 — Facility versus contact mechanism
  FACILITY_TYPE      ||--o{ FACILITY                   : "the description for"
  FACILITY           |o--o{ FACILITY                   : "made up of"
  PARTY              ||--o{ FACILITY_ROLE              : "involved in"
  FACILITY           ||--o{ FACILITY_ROLE              : "involving"
  FACILITY_ROLE_TYPE ||--o{ FACILITY_ROLE              : "the description for"
  FACILITY           ||--o{ FACILITY_CONTACT_MECHANISM : "contacted via"
  CONTACT_MECHANISM  ||--o{ FACILITY_CONTACT_MECHANISM : "used by"

  %% Fig 2.12 — Communication event
  STATUS_TYPE                      ||--o{ COMMUNICATION_EVENT          : "used to monitor"
  CONTACT_MECHANISM_TYPE           ||--o{ COMMUNICATION_EVENT          : "the contact medium for"
  COMMUNICATION_EVENT              ||--o{ COMMUNICATION_EVENT_PURPOSE  : "categorized by"
  COMMUNICATION_EVENT_PURPOSE_TYPE ||--o{ COMMUNICATION_EVENT_PURPOSE  : "the description for"
  COMMUNICATION_EVENT              ||--o{ COMMUNICATION_EVENT_ROLE     : "involving"
  PARTY                            ||--o{ COMMUNICATION_EVENT_ROLE     : "involved in"
  COMMUNICATION_EVENT_ROLE_TYPE    ||--o{ COMMUNICATION_EVENT_ROLE     : "the description for"
  CONTACT_MECHANISM_TYPE           ||--o{ VALID_CONTACT_MECHANISM_ROLE : "used for"
  COMMUNICATION_EVENT_ROLE_TYPE    ||--o{ VALID_CONTACT_MECHANISM_ROLE : "the description for"

  %% Fig 2.13 — Communication event follow-up
  COMMUNICATION_EVENT          ||--o{ COMMUNICATION_EVENT_WORK_EFFORT : "followed up with"
  WORK_EFFORT                  ||--o{ COMMUNICATION_EVENT_WORK_EFFORT : "has"
  WORK_EFFORT_TYPE             ||--o{ WORK_EFFORT                     : "classifies"
  COMMUNICATION_CASE           |o--o{ COMMUNICATION_EVENT             : "encompassing"
  STATUS_TYPE                  ||--o{ COMMUNICATION_CASE              : "the status of"
  COMMUNICATION_CASE           ||--o{ COMMUNICATION_CASE_ROLE         : "involving"
  PARTY                        ||--o{ COMMUNICATION_CASE_ROLE         : "involved in"
  COMMUNICATION_CASE_ROLE_TYPE ||--o{ COMMUNICATION_CASE_ROLE         : "the description for"

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
  GEOGRAPHIC_BOUNDARY          ||--o{ CITIZENSHIP             : "country for"
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
  PARTY_RELATIONSHIP_TYPE {
    text party_relationship_type_id PK
    text name
    text description
    text from_role_type_id FK
    text to_role_type_id FK
  }
  PARTY_RELATIONSHIP {
    int  party_relationship_id PK
    text party_relationship_type_id FK
    int  from_party_role_id FK
    int  to_party_role_id FK
    date from_date
    date thru_date
    text comment
    text priority_type_id FK "optional (2.7)"
    text status_type_id FK "optional (2.7)"
  }
  PRIORITY_TYPE {
    text priority_type_id PK
    text description
  }
  STATUS_TYPE {
    text status_type_id PK
    text parent_type_id FK
    text description
  }
  COMMUNICATION_EVENT {
    int         communication_event_id PK
    int         party_relationship_id FK "optional since 2.12"
    timestamptz datetime_started
    timestamptz datetime_ended
    text        note
    text        status_type_id FK
    text        contact_mechanism_type_id FK
    int         communication_case_id FK "optional, 2.13"
  }
  EMPLOYMENT {
    int  employment_id PK
    int  employer_party_role_id FK "from: INTERNAL ORGANIZATION"
    int  employee_party_role_id FK "to: EMPLOYEE"
    date from_date
    date thru_date
  }
  CUSTOMER_RELATIONSHIP {
    int  customer_relationship_id PK
    int  customer_party_role_id FK "from: CUSTOMER"
    int  internal_org_party_role_id FK "to: INTERNAL ORGANIZATION"
    date from_date
    date thru_date
  }
  ORGANIZATION_ROLLUP {
    int  organization_rollup_id PK
    int  child_party_role_id FK "from: ORGANIZATION UNIT"
    int  parent_party_role_id FK "to: ORGANIZATION ROLE"
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
    int  country_id FK "a COUNTRY boundary"
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
  GEOGRAPHIC_BOUNDARY_TYPE {
    text geographic_boundary_type_id PK
    text description
  }
  GEOGRAPHIC_BOUNDARY {
    int  geographic_boundary_id PK
    text geographic_boundary_type_id FK
    text geo_code
    text name
    text abbreviation
  }
  GEOGRAPHIC_BOUNDARY_ASSOCIATION {
    int geographic_boundary_association_id PK
    int from_geographic_boundary_id FK "within"
    int to_geographic_boundary_id FK "in"
  }
  POSTAL_ADDRESS {
    int  contact_mechanism_id PK "FK to CONTACT_MECHANISM"
    text address1
    text address2
    text directions
  }
  POSTAL_ADDRESS_BOUNDARY {
    int postal_address_boundary_id PK
    int contact_mechanism_id FK
    int geographic_boundary_id FK
  }
  CONTACT_MECHANISM_TYPE {
    text contact_mechanism_type_id PK
    text applies_to_kind "POSTAL_ADDRESS | TELECOMMUNICATIONS_NUMBER | ELECTRONIC_ADDRESS"
    text description
  }
  CONTACT_MECHANISM {
    int  contact_mechanism_id PK
    text contact_mechanism_kind "POSTAL_ADDRESS | TELECOMMUNICATIONS_NUMBER | ELECTRONIC_ADDRESS"
    text contact_mechanism_type_id FK
  }
  TELECOMMUNICATIONS_NUMBER {
    int  contact_mechanism_id PK "FK to CONTACT_MECHANISM"
    text country_code
    text area_code
    text contact_number
  }
  ELECTRONIC_ADDRESS {
    int  contact_mechanism_id PK "FK to CONTACT_MECHANISM"
    text electronic_address_string
  }
  PARTY_CONTACT_MECHANISM {
    int  party_contact_mechanism_id PK
    int  party_id FK
    int  contact_mechanism_id FK
    date from_date
    date thru_date
    bool non_solicitation_ind
    text extension
    text role_type_id FK
    text comment
  }
  CONTACT_MECHANISM_PURPOSE_TYPE {
    text contact_mechanism_purpose_type_id PK
    text description
  }
  PARTY_CONTACT_MECHANISM_PURPOSE {
    int  party_contact_mechanism_purpose_id PK
    int  party_contact_mechanism_id FK
    text contact_mechanism_purpose_type_id FK
    date from_date
    date thru_date
  }
  CONTACT_MECHANISM_LINK {
    int contact_mechanism_link_id PK
    int from_contact_mechanism_id FK
    int to_contact_mechanism_id FK
  }
  FACILITY_TYPE {
    text facility_type_id PK
    text description
  }
  FACILITY {
    int     facility_id PK
    text    facility_type_id FK
    int     part_of_facility_id FK
    text    description
    numeric square_footage
  }
  FACILITY_ROLE_TYPE {
    text facility_role_type_id PK
    text description
  }
  FACILITY_ROLE {
    int  facility_role_id PK
    int  party_id FK
    int  facility_id FK
    text facility_role_type_id FK
    date from_date
    date thru_date
  }
  FACILITY_CONTACT_MECHANISM {
    int  facility_contact_mechanism_id PK
    int  facility_id FK
    int  contact_mechanism_id FK
    date from_date
    date thru_date
  }
  COMMUNICATION_EVENT_PURPOSE_TYPE {
    text communication_event_purpose_type_id PK
    text description
  }
  COMMUNICATION_EVENT_PURPOSE {
    int  communication_event_purpose_id PK
    int  communication_event_id FK
    text communication_event_purpose_type_id FK
    text description
  }
  COMMUNICATION_EVENT_ROLE_TYPE {
    text communication_event_role_type_id PK
    text description
  }
  COMMUNICATION_EVENT_ROLE {
    int  communication_event_role_id PK
    int  communication_event_id FK
    int  party_id FK
    text communication_event_role_type_id FK
  }
  VALID_CONTACT_MECHANISM_ROLE {
    int  valid_contact_mechanism_role_id PK
    text contact_mechanism_type_id FK
    text communication_event_role_type_id FK
  }
  WORK_EFFORT_TYPE {
    text work_effort_type_id PK
    text description
  }
  WORK_EFFORT {
    int     work_effort_id PK
    text    work_effort_type_id FK
    text    name
    text    description
    date    scheduled_start_date
    date    scheduled_completion_date
    numeric total_dollars_allowed
    numeric total_hours_allowed
    numeric estimated_hours
  }
  COMMUNICATION_EVENT_WORK_EFFORT {
    int  communication_event_work_effort_id PK
    int  communication_event_id FK
    int  work_effort_id FK
    text description
  }
  COMMUNICATION_CASE {
    int         communication_case_id PK
    text        description
    timestamptz start_datetime
    text        status_type_id FK
  }
  COMMUNICATION_CASE_ROLE_TYPE {
    text communication_case_role_type_id PK
    text description
  }
  COMMUNICATION_CASE_ROLE {
    int  communication_case_role_id PK
    int  communication_case_id FK
    int  party_id FK
    text communication_case_role_type_id FK
  }
```
