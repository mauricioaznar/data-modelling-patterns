# Vol 1, Chapter 9 — ER diagram

Figs 9.2–9.6 (9.1 not built). Tables from earlier chapters are shown by name only.
Employment (9.2) is Ch 2's `party_relationship` typed EMPLOYMENT, read through the
`employment_relationship` view.

```mermaid
erDiagram
  party_role ||--o{ party_relationship : "employer of (internal organization)"
  party_role ||--o{ party_relationship : "employed within (employee)"
  status_type |o--o{ party_relationship : "sets the status of"
  position_type ||--o{ position : "describes"
  budget_item |o--o{ position : "approves"
  organization ||--o{ position : "hiring company for"
  status_type ||--o{ position : "the status of"
  responsibility_type ||--o{ valid_responsibility : "defines"
  position_type ||--o{ valid_responsibility : "may be given"
  responsibility_type ||--o{ position_responsibility : "defines"
  position ||--o{ position_responsibility : "assigned"
  position_classification_type ||--o{ position_type_class : "defines"
  position_type ||--o{ position_type_class : "classified via"
  party_role |o--o{ position_type : "the union for"
  position ||--o{ position_fulfillment : "filled by"
  person ||--o{ position_fulfillment : "accepts"
  position ||--o{ position_reporting_structure : "reports via"
  position ||--o{ position_reporting_structure : "manages"
```
