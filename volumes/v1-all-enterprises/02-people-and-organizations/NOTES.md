# Vol 1, Chapter 2 — People and Organizations

## The problem this pattern solves

The same company or person tends to be stored over and over, once as a customer, again as a
supplier, again as a contact, each copy with its own name and address. Those copies drift apart.
The chapter starts by pulling organizations and people into single entities of their own, and
later (the Party figures) generalizes the two.

## Figures

### Fig 2.1 — Organization
**Transcription** (confirmed against the book: ☑)

```
ORGANIZATION
  (no identifier drawn)
  * name
  subtypes:
    LEGAL ORGANIZATION
      o federal_tax_id_num
      subtypes: CORPORATION, GOVERNMENT AGENCY
    INFORMAL ORGANIZATION
      subtypes: TEAM, FAMILY, OTHER INFORMAL ORGANIZATION
```

**Discussion**
- The model is a two-level subtype hierarchy. Only LEGAL ORGANIZATION adds an attribute (the tax
  ID); every other subtype carries no attributes.
- A subtype with no attributes of its own is really a *classification*. That raises a question
  for SQL: a table per subtype, or one `organization` table plus a type column? We'll decide
  when implementing.
- "Family" and "team" count as organizations. The definition is broader than "company": any
  group of people with a shared purpose.

### Fig 2.2a — Person
**Transcription** (confirmed against the book: ☑)

```
PERSON
  (no identifier drawn)
  o current_last_name
  o current_first_name
  o current_middle_name
  o current_personal_title
  o current_suffix
  o current_nickname
  o gender
  o birth_date
  o height
  o weight
  o mothers_maiden_name
  o marital_status
  o social_security_no
  o current_passport_no
  o current_passport_expire_date
  o total_years_work_experience
  o comment
```

**Discussion**
- It's one flat entity and every attribute is optional.
- The word **current** gives it away. This model only knows the present: a new last name or a new
  passport overwrites the old value.
- `gender` and `marital_status` are free values with no list of allowed values.

### Fig 2.2b — Person, alternate model
**Transcription** (confirmed against the book: ☑)

```
PERSON
  o birth_date
  o mothers_maiden_name
  o social_security_no
  o total_years_work_experience
  o comment
  -> GENDER TYPE            (each person must be "of" 1 gender type;
                             each gender type may be "for" many persons)

GENDER TYPE
  # gender_type_id
  * description

PERSON NAME
  # name_seq_id
  * from_date
  o thru_date
  * name
  -> PERSON                 (many names "for" 1 person; identifier = person + name_seq_id)
  -> PERSON NAME TYPE       (many names "described by" 1 type; assumed mandatory on the name side)

PERSON NAME TYPE
  # person_name_type_id
  * description

MARITAL STATUS
  # from_date
  o thru_date
  -> PERSON                 (many "for" 1 person; part of identifier)
  -> MARITAL STATUS TYPE    (many "described by" 1 type; part of identifier)

MARITAL STATUS TYPE
  # marital_status_type_id
  * description

PHYSICAL CHARACTERISTIC
  * from_date               (confirmed: drawn as *, NOT part of the identifier)
  o thru_date
  o value
  -> PERSON                 (many "for" 1 person; part of identifier)
  -> PHYSICAL CHARACTERISTIC TYPE (many "described by" 1 type; part of identifier)

PHYSICAL CHARACTERISTIC TYPE
  # characteristic_type_id
  * description

CITIZENSHIP
  # from_date
  o thru_date
  -> PERSON                 (many "for" 1 person; part of identifier)
  -> COUNTRY                (many "of" 1 country; part of identifier)

PASSPORT
  # passport_id
  * passport_num
  * issue_date
  * expiration_date
  -> CITIZENSHIP            (many passports "issued within" 1 citizenship)

COUNTRY
  (no attributes drawn)
```

**Discussion: what moved where from 2.2a**

| 2.2a attribute | 2.2b home | What it gains |
|---|---|---|
| `current_*_name`, title, suffix, nickname | PERSON NAME rows, typed by PERSON NAME TYPE | Full name history, and any kind of name (maiden, alias, stage name) without a schema change |
| `gender` | GENDER TYPE lookup | A controlled list of values |
| `marital_status` | MARITAL STATUS rows with from/thru | History: married 2010, divorced 2018… |
| `height`, `weight` | PHYSICAL CHARACTERISTIC with a type and a value | New characteristics (eye colour, blood type) are just data |
| `current_passport_*` | PASSPORT under CITIZENSHIP | Several passports, dual citizenship, expired passports kept |

What stayed on PERSON (birth date, SSN, mother's maiden name…) is either a fact that never
changes or something the author didn't consider worth keeping history for.

**Things to notice**
- The recurring shape is **thing + type + from/thru**. It shows up three times in one figure, and
  it's the book's main technique.
- `PHYSICAL CHARACTERISTIC.value` holds any characteristic in one column, a lightweight form of
  the entity-attribute-value (EAV) pattern. The cost is that the database can't check that a
  height is a number.
- A passport belongs to a *citizenship*, not directly to a person, which reads as "a country
  issues it to one of its citizens". The person is reached through the citizenship.

### Fig 2.3 — Party
**Transcription** (confirmed against the book: ☑)

```
PARTY
  # party_id
  subtypes:
    ORGANIZATION
      * name
      subtypes:
        LEGAL ORGANIZATION
          o federal_tax_id_num
        INFORMAL ORGANIZATION
    PERSON
      * current_last_name            ← mandatory here (optional in 2.2a)
      * current_first_name           ← mandatory here (optional in 2.2a)
      o current_middle_name
      o current_personal_title
      o current_suffix
      o current_nickname
      o gender
      o birth_date
      o height
      o weight
      o mothers_maiden_name
      o marital_status
      o social_security_no
      o current_passport_no
      o current_passport_expire_date
      o total_years_work_experience
      o comment

PARTY CLASSIFICATION
  # from_date
  o thru_date
  -> PARTY                  (many classifications "for" 1 party; part of identifier)
  -> PARTY TYPE             (many "described by" 1 type; part of identifier;
                             each type may describe many classifications)
  subtypes:
    ORGANIZATION CLASSIFICATION
      subtypes: MINORITY CLASSIFICATION, INDUSTRY CLASSIFICATION, SIZE CLASSIFICATION
    PERSON CLASSIFICATION
      subtypes: EEOC CLASSIFICATION, INCOME CLASSIFICATION

PARTY TYPE
  # party_type_id
  * description
```

**Discussion**
- **The key idea:** PERSON and ORGANIZATION become subtypes of PARTY, and `party_id` is the
  one identifier for both. Anything that can involve "a person *or* an organization" (a
  customer, a supplier, an address, a contact) can now point at a single `party_id`, instead
  of carrying two nullable foreign keys or being modelled twice.
- **The subtypes are shown in their simplest form:** PERSON with the flat 2.2a attributes, and
  ORGANIZATION without corporation/team/family. The figure is about the supertype and doesn't
  choose between 2.2a and 2.2b. One detail changed: first and last name became mandatory.
- **Classification is separate from subtype.** Being a person or an organization is fixed and
  structural: exactly one, forever. *Classifications* (industry, size, minority-owned, income
  bracket, EEOC category) are many per party, can change over time (from/thru), and are just
  data. That's why they sit in PARTY CLASSIFICATION rows rather than more subtypes.
- **PARTY CLASSIFICATION links PARTY and PARTY TYPE many-to-many, with history.** Compare 2.1,
  where an organization had exactly one type through a single FK column.
- The classification subtypes (minority, industry, EEOC…) have no attributes again, so they're
  the same kind of pure labels we met in 2.1.
- EEOC is the US Equal Employment Opportunity Commission, whose reporting categories (race and
  ethnicity, job category) US employers have to report on.

### Fig 2.4 — Party roles
**Transcription** (confirmed against the book: ☑)

```
PARTY ROLE
  # party_role_id                ← its own identifier (unlike PARTY CLASSIFICATION)
  * from_date                    ← mandatory, NOT part of the identifier
  o thru_date
  -> PARTY                  (each role must be "for" 1 party; a party may be "acting as" many roles;
                             part of identifier)
  -> ROLE TYPE              (each role must be "described by" 1 role type;
                             a role type may describe many roles)
  subtypes:
    PERSON ROLE
      EMPLOYEE, CONTRACTOR, FAMILY MEMBER, CONTACT
    ORGANIZATION ROLE
      DISTRIBUTION CHANNEL
        AGENT, DISTRIBUTOR
      PARTNER, COMPETITOR, HOUSEHOLD, REGULATORY AGENCY, SUPPLIER, ASSOCIATION
      ORGANIZATION UNIT
        PARENT ORGANIZATION, SUBSIDIARY, DEPARTMENT, DIVISION, OTHER ORGANIZATION UNIT
      INTERNAL ORGANIZATION
    CUSTOMER                     ← person OR organization
      BILL TO CUSTOMER, SHIP TO CUSTOMER, END USER CUSTOMER
    PROSPECT                     ← person OR organization
    SHAREHOLDER                  ← person OR organization

ROLE TYPE
  # role_type_id
  * description
  subtypes: PARTY ROLE TYPE      ← only one subtype drawn so far (others later?)

PARTY
  # party_id
  subtypes: PERSON, ORGANIZATION
```

**Discussion**
- **"Customer" isn't a kind of thing; it's a role a party plays.** The same party can be a
  customer, a supplier and a shareholder at once, or a prospect that later becomes a customer,
  stored once, with each role as a dated row. A naive model has `customer` and `supplier` tables
  and duplicates the company that is both.
- **There are three families of roles:** some only a person can play (employee, contact), some
  only an organization can (supplier, department, internal organization), and some either can
  (customer, prospect, shareholder). The subtype tree encodes which parties are allowed which roles.
- **A role has its own identity (`party_role_id`),** while a classification (2.3) is identified by
  (party, type, from_date). That hints that other things will *point at a role*: an order
  references "this party acting as bill-to customer", not just a party.
- **Organization units (department, division, subsidiary) are roles, not organization types.**
  A department is an organization *playing the part of* a unit inside another organization.
  That "inside another" part isn't in this figure; a role alone can't say *whose* department it is.
- **ROLE TYPE has a subtype PARTY ROLE TYPE,** so role types are a broader concept that other
  kinds of roles will reuse later.
- **INTERNAL ORGANIZATION** marks the organizations that are part of *our own* enterprise,
  as opposed to the outside world.

### Fig 2.5 — Specific party relationships
**Transcription** (confirmed against the book: ☑)

```
PARTY RELATIONSHIP
  # from_date
  o thru_date
  subtypes:
    EMPLOYMENT
      -> INTERNAL ORGANIZATION  "from"  (role is "employer of")
      -> EMPLOYEE               "to"    (role is "employed within")
    CUSTOMER RELATIONSHIP
      -> CUSTOMER               "from"  (role "involved in")             ← the grouping role, not BILL TO etc.
      -> INTERNAL ORGANIZATION  "to"    (role "involved in")
    ORGANIZATION ROLLUP
      -> ORGANIZATION UNIT      "from"  (role is "within")
      -> ORGANIZATION ROLE      "to"    (role is "made up of")

PARTY ROLE                  (same subtype tree as Fig 2.4)
  # party_role_id
  -> PARTY                  ("for" / "acting as")
  -> ROLE TYPE              ("described by")

ROLE TYPE
  # party_role_type_id      ← labelled "party role type id" here, "role type id" in 2.6a
  * description
  subtypes: PARTY ROLE TYPE
```

**Discussion**
- **This is the *specific* version:** each kind of relationship is its own subtype, and each draws
  its own two lines to the exact roles it connects. The model *shows* that employment is between
  an internal organization and an employee.
- **2.6a is the *generic* version** of the same thing: one PARTY RELATIONSHIP with a TYPE, and the
  allowed role pairs move out of the diagram into PARTY RELATIONSHIP TYPE rows. It's the same
  pattern as 2.2a → 2.2b and 2.1 → 2.3: structure becomes data.
- **Direction reads as "from the owner to the member":** the employer *employs* the employee,
  and the customer *buys from* us (the internal organization).
- **CUSTOMER RELATIONSHIP connects the CUSTOMER role itself,** not bill-to/ship-to/end-user
  specifically. That matters for us, because in 2.4 we made grouping role types like CUSTOMER
  non-assignable.

### Fig 2.6a — Common party relationships
**Transcription** (confirmed against the book: ☐)

```
PARTY RELATIONSHIP
  # from_date
  o thru_date
  o comment
  -> PARTY ROLE   "from"    (many relationships "from" 1 role; role "involved in")   ⚠ identifier bar?
  -> PARTY ROLE   "to"      (many relationships "to" 1 role; role "involved in")     ⚠ identifier bar?
  -> PARTY RELATIONSHIP TYPE (many "described by" 1 type)                             ⚠ identifier bar? optionality?
  subtypes:
    SUPPLIER RELATIONSHIP, ORGANIZATION CONTACT RELATIONSHIP, EMPLOYMENT,
    CUSTOMER RELATIONSHIP, DISTRIBUTION CHANNEL RELATIONSHIP, PARTNERSHIP,
    ORGANIZATION ROLLUP

PARTY RELATIONSHIP TYPE
  # party_relationship_type_id
  * description
  * name
  -> PARTY ROLE TYPE  "from"   (many relationship types; role type "used to define")
  -> PARTY ROLE TYPE  "to"     (many relationship types; role type "used to define")

PARTY ROLE                  (same subtype tree as Fig 2.4; dates not drawn here)
  # party_role_id
  -> PARTY                  ("for" / "acting as")
  -> ROLE TYPE              ("described by")

ROLE TYPE
  # role_type_id
  * description
  subtypes: PARTY ROLE TYPE

PARTY
  # party_id
  subtypes: PERSON, ORGANIZATION
```

**Discussion**
- **This answers "employee *of whom*?"** A relationship links two *roles*, not two parties:
  Ana-as-EMPLOYEE → Northwind-as-INTERNAL ORGANIZATION is an EMPLOYMENT relationship, and
  Ben-as-CONTACT → Contoso-as-SUPPLIER is an ORGANIZATION CONTACT RELATIONSHIP.
- **Relationship types define which role pairs make sense.** PARTY RELATIONSHIP TYPE points at
  the *role type* allowed on each end. EMPLOYMENT only makes sense from an EMPLOYEE to an
  employer, never from a SUPPLIER to a PROSPECT.
- **This is why ROLE TYPE → PARTY ROLE TYPE is drawn:** relationship types are "used to define"
  by party role types. We deferred that subtype in 2.4, and this figure is its first real use.
- **Relationships are dated and directional** (from/to), with a free-text comment. The
  relationship subtypes have no attributes, so they're labels again.
- **ORGANIZATION ROLLUP** is how org charts get built: department → division → parent
  organization, all as relationships between organization roles.

## Design decisions (book → SQL)

### Fig 2.1
- **Surrogate key `organization_id`** (replaced by `party_id` in 2.3). The book draws no identifier; it arrives with PARTY later
  in the chapter.
- **Subtypes become a type hierarchy, not tables.** Six of the seven subtypes have no attributes,
  so a table per subtype would give six tables holding nothing but a key. They are rows in
  `organization_type`, with `parent_type_id` keeping the LEGAL / INFORMAL grouping. This departs
  from the "subtype table" rule in CLAUDE.md, which only makes sense when a subtype has its own
  attributes.
- **Cost of that choice:** `federal_tax_id_num` sits on `organization`, and the schema does
  *not* stop an informal organization from having one (the seed deliberately includes such a
  row, and a data-quality query catches it). Enforcing it would take a trigger or a
  `legal_organization` subtype table. We accept the gap for now.
- **Also not enforced:** an organization should point at a *leaf* type (CORPORATION, not LEGAL).

### Fig 2.2a
- Implemented as drawn: one table, all columns nullable, with a surrogate `person_id`.
- Renamed to **`person_flat`** when 2.2b arrived, and kept loaded so both models can be queried
  side by side.
- Seeded with the same people as 2.2b, so the queries show what the flat model loses:
  inconsistent gender and marital-status spellings, and a former name that survives only in `comment`.

### Fig 2.2b
- **Surrogate keys instead of the book's identifying relationships.** The book identifies
  PERSON NAME by (person, seq), MARITAL STATUS by (person, type, from_date), CITIZENSHIP by
  (person, country, from_date). Each table has a single surrogate id instead
  (`person_name_id`, which replaces `name_seq_id`, plus `marital_status_id`, `citizenship_id`…)
  and a plain FK to the person. *History:* the first version used the book's composite keys; we
  dropped them for simplicity when 2.5 was built.
- **PASSPORT → CITIZENSHIP is a single `citizenship_id` FK.** It used to be a three-column
  composite FK (person, country, from_date), which showed how an identifying key travels down to
  every child. The person and country are now reached through the citizenship.
- **PHYSICAL CHARACTERISTIC.** The book draws `from_date` as `*`, so its identifier (person,
  type) would allow one weight per person, ever. With a surrogate key that problem disappears:
  `from_date` is simply mandatory, which now matches the book.
- **`value` is `text`.** One column has to hold heights, weights and eye colours, so the
  database can't check that a height is a number. The seed includes `'approx 170'`, and a
  query catches it. The unit lives in the type's description (`Height (cm)`).
- **Additions not in the figure:** `country.name` (so rows are readable) and
  `thru_date > from_date` checks on every dated table.
- **Not enforced: overlapping periods.** Nothing stops two open `LAST` names or two current
  marital statuses for the same person. Postgres could enforce it with an exclusion constraint
  (`btree_gist`); for now it's up to the application.
- **"No rows" ≠ "single."** Chloe has no marital status rows, which means *unknown*. The flat
  model conflated unknown with null, which is the same thing but less visible.

### Fig 2.3
- **`organization` and `person` became subtypes of `party`.** Their primary key is `party_id`,
  which is also a plain FK to `party`, and every person child table uses `party_id` too. We chose
  the 2.2b person as the subtype. `person_flat` stays standalone, outside the party hierarchy.
- **`party` is defined at the top of `schema.sql`**, ahead of 2.1, because the subtypes
  reference it. This is the only exception to "schema.sql follows book order".
- **Addition: `party_kind` discriminator.** It says which subtype a party *should* have. A
  data-quality query checks that every party has exactly that subtype row (the seed's party 11
  has none). *History:* this was first enforced with composite FKs on `(party_id, party_kind)`;
  we dropped those for simplicity.
- **Classification subtypes become a three-level `party_type` hierarchy:** root
  (ORGANIZATION_ / PERSON_CLASSIFICATION), then category (INDUSTRY, SIZE, EEOC…), then the
  actual values. As in 2.1, the subtypes have no attributes, so they're rows, not tables.
  `party_type.applies_to_kind` says which kind of party a type is for, and a data-quality query
  catches mismatches (the seed classifies Ana, a person, as SIZE_SMALL).
- **Surrogate `party_classification_id`** instead of the book's (party, type, from_date).
- **Not enforced: one current value per category.** Nothing stops a party from being SMALL and
  MEDIUM at the same time. It's the overlapping-periods problem again, this time per category.
- **"First and last name are mandatory" (from 2.3) can't be declared** when names are rows (the
  2.2b model). A data-quality query checks it instead, and it flags Kiri, a mononymous person.
  The rule is questionable anyway: plenty of real people have only one name.
- **Addition: `party_display_name` view.** It gives the current name of any party in one place.
  Later chapters (roles, orders, invoices) will need it constantly.

### Fig 2.4
- **Role subtypes become a `role_type` hierarchy** (PERSON_ROLE > EMPLOYEE,
  ORGANIZATION_ROLE > DISTRIBUTION_CHANNEL > AGENT, CUSTOMER > BILL_TO_CUSTOMER…), for the
  same reason as 2.1 and 2.3: the subtypes have no attributes.
- **ROLE TYPE → PARTY ROLE TYPE is not modelled.** The book draws ROLE TYPE as a supertype
  with a single subtype, PARTY ROLE TYPE. With only one subtype, a single `role_type` table is
  enough. Refactor if another role-type subtype ever appears.
- **`role_type.applies_to_kind`** says which kind of party may play a role: PERSON,
  ORGANIZATION, EITHER (customer, prospect, shareholder), or null for grouping types
  (PERSON_ROLE, CUSTOMER, DISTRIBUTION_CHANNEL…) that aren't assigned directly. A data-quality
  query catches violations (the seed has the Book Club as EMPLOYEE, and Contoso as plain
  CUSTOMER). *History:* this was first a `role_type_party_kind` pairs table with composite FKs,
  which the database enforced; we dropped it for simplicity.
- **Identifier.** The book's identifier is (party, `party_role_id`). We use `party_role_id`
  alone, which is already unique.
- **Not enforced: overlapping periods of the same role.** Ana could hold two open EMPLOYEE rows.
  It's the same gap as names and classifications.
- **Known gap, on purpose:** a role says *what* a party is to us, but not *to whom*. Ben is a
  CONTACT and the Platform Team is a DEPARTMENT, but of which organization? The seed and a query
  show the hole, and the relationship figures (2.5, 2.6a) fill it.

## When NOT to use this

**The 2.2b shape (thing + type + from/thru):**
- Every "current" read becomes a join plus `thru_date is null`, and every "as of" read needs the
  date-range predicate. Rebuilding a display name takes a pivot (see queries.sql).
- It's worth it when history matters to the business (legal names, compliance, KYC, HR) or when
  the set of values changes often. For a signup form that shows a name, one `display_name`
  column is the right answer.
- Middle ground: keep the flat `current_*` columns for fast reads *and* a history table
  written on change. That duplicates data, but it's what many production systems do.

**Attributes as rows (PHYSICAL CHARACTERISTIC):**
- This buys new characteristics without a migration. It costs type checking, constraints and
  easy querying (a `value::numeric` cast breaks on bad data).
- Use it for a long, open-ended, sparsely filled list of attributes. With 2–3 known attributes,
  use columns. Postgres `jsonb` is a modern alternative for the same need.

**Organization subtypes as a type table:**
- This is fine while subtypes are just labels. Once a subtype gains several attributes of its
  own, a subtype table is the better choice.

**The PARTY supertype:**
- Every read of a name or subtype attribute becomes a join, and "list all parties with their
  names" needs a view that stitches both subtypes together (`party_display_name`).
- It pays off when the same business roles apply to both people and organizations: customers
  can be consumers or companies, and suppliers can be freelancers or firms. If an app only ever
  deals with companies (a B2B tool with company accounts), or only with individual users, a
  plain `company` or `user` table is simpler, and nothing is lost.

**Classification rows vs. a type column:**
- Use classification rows when there are many, dated categorisations that change often and
  that reporting needs to slice by (industry, size, segment). Use a plain column when there's
  exactly one fixed type.

**Party roles:**
- When a system has exactly one kind of counterparty (a store with only consumer customers),
  a `customer` table is simpler and roles add nothing. Roles pay off when the same real-world
  party appears in several capacities (customer *and* supplier, employee *and* shareholder), or
  when you need a lifecycle history (prospect → customer → former customer).
- The cost is the same as with types: every "list our customers" query goes through a join and a
  date filter, and role-specific data (credit limit, supplier rating) needs somewhere to live,
  either a subtype table per role or attributes elsewhere.

## Open questions
- **PERSON NAME → PERSON NAME TYPE optionality.** Assumed mandatory on the name side, the same
  pattern as gender. Not yet confirmed against the book.

### Resolved
- PERSON → GENDER TYPE: solid on the person side and dashed on the type side, so every person
  *must* have a gender type.
- PERSON NAME is identified by `name_seq_id` within its person.
- ORGANIZATION is the first entity in the book and has no identifier until PARTY.
- PARTY ROLE: must have 1 party (part of identifier) and 1 role type; CUSTOMER, PROSPECT and
  SHAREHOLDER can be played by either kind of party.
- PARTY CLASSIFICATION is identified by (party, party type, from_date); a PARTY TYPE may describe
  many classifications; first and last name are mandatory in 2.3.
- PHYSICAL CHARACTERISTIC `from_date` is drawn as `*`. With surrogate keys that now matches the book
  (see Design decisions).
