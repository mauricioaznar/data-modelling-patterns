# Vol 1, Chapter 8 — ER diagram

Figs 8.1–8.3b. Tables from earlier chapters are shown by name only.

```mermaid
erDiagram
  general_ledger_account_type ||--o{ general_ledger_account : "defines"
  organization ||--o{ organization_gl_account : "keeps"
  general_ledger_account ||--o{ organization_gl_account : "used as"
  period_type ||--o{ accounting_period : "defines"
  organization ||--o{ accounting_period : "uses"
  accounting_period |o--o{ accounting_period : "within"
```
