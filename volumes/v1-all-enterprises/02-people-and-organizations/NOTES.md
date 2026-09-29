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

## Design decisions (book → SQL)

### Fig 2.1
- **Surrogate key `organization_id`.** The book draws no identifier; it arrives with PARTY later
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
- Implemented as drawn: one `person` table, all columns nullable, with a surrogate `person_id`.
- Seeded with the same people 2.2b will use, so the queries show what the flat model loses:
  inconsistent gender and marital-status spellings, and a former name that survives only in `comment`.

## When NOT to use this
<!-- Filled in after implementation. -->

## Open questions
- **PHYSICAL CHARACTERISTIC identifier.** Confirmed as drawn: `from_date` is `*`, not `#`, so
  the book's identifier is (person, type). Read literally, that allows one height per person
  ever, which makes `from_date`/`thru_date` pointless. We'll likely deviate and include
  `from_date` in the key; to be decided when implementing 2.2b.
- **PERSON NAME → PERSON NAME TYPE optionality.** Assumed mandatory on the name side, the same
  pattern as gender. Not yet confirmed.

### Resolved
- PERSON → GENDER TYPE: solid on the person side and dashed on the type side, so every person
  *must* have a gender type.
- PERSON NAME is identified by `name_seq_id` within its person.
- ORGANIZATION is the first entity in the book and has no identifier until PARTY.
