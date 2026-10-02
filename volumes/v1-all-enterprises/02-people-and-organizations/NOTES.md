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
**Transcription** (confirmed against the book: ☑; identifier bars left unconfirmed, moot with surrogate keys)

```
PARTY RELATIONSHIP
  # from_date
  o thru_date
  o comment
  -> PARTY ROLE   "from"    (many relationships "from" 1 role; role "involved in")
  -> PARTY ROLE   "to"      (many relationships "to" 1 role; role "involved in")  
  -> PARTY RELATIONSHIP TYPE (many "described by" 1 type)
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

### Fig 2.7 — Party relationship information
**Transcription** (confirmed against the book: ☑)

```
PARTY RELATIONSHIP          (same entity and subtypes as Fig 2.6a)
  # from_date
  o thru_date
  o comment
  -> PARTY ROLE "from" / "to"          ("involved in")
  -> PARTY RELATIONSHIP TYPE           ("described by" / "the description for")
  -> PRIORITY TYPE                     ("prioritized by" / "set the priority for"; optional)
  -> PARTY RELATIONSHIP STATUS TYPE    ("defined by" / "set the status for"; optional)

PRIORITY TYPE
  # priority_type_id
  * description

STATUS TYPE
  # status_type_id
  * description
  subtypes: PARTY RELATIONSHIP STATUS TYPE      ← the line lands on this subtype

COMMUNICATION EVENT
  # communication_event_id
  * datetime_started
  o datetime_ended
  o note
  -> PARTY RELATIONSHIP     (many events "in the context of" 1 relationship;
                             a relationship is "contacted via" many events; mandatory for the event)
```

**Discussion**
- **A relationship carries information of its own,** not just the two roles and dates: how
  important it is (priority), where it stands (status), and the history of contact within it
  (communication events).
- **Priority and status are single values with no dates.** The relationship knows its current
  status but not its past statuses. Compare marital status in 2.2b, which kept full history.
- **STATUS TYPE is a supertype, and PARTY RELATIONSHIP STATUS TYPE its only subtype.** It's the
  same shape as ROLE TYPE → PARTY ROLE TYPE: a shared place for "statuses" that other entities
  (orders, shipments…) will presumably get in later chapters.
- **A communication event happens *within a relationship*,** not just between two parties: a call
  from Ben *as Contoso's contact* to us is logged against that contact relationship. The date is a
  datetime here, the first time-of-day attribute in the chapter.

### Fig 2.8 — Postal address information
**Transcription** (confirmed against the book: ☑)

```
PARTY POSTAL ADDRESS
  # from_date
  o thru_date
  o comment
  -> PARTY                  (many "specified for" 1 party; party "residing at")
  -> POSTAL ADDRESS         (many "located at" 1 address; address "the location for")

POSTAL ADDRESS
  (no identifier drawn)
  * address1
  o address2
  o directions

POSTAL ADDRESS BOUNDARY     (no attributes drawn)
  -> POSTAL ADDRESS         (many "specified for" 1 address; address "within")
  -> GEOGRAPHIC BOUNDARY    (many "in" 1 boundary; boundary "for")

GEOGRAPHIC BOUNDARY ASSOCIATION   (no attributes drawn)
  -> GEOGRAPHIC BOUNDARY  "from"   ("within")
  -> GEOGRAPHIC BOUNDARY  "to"     ("in")

GEOGRAPHIC BOUNDARY
  # geo_id
  o geo_code
  * name
  o abbreviation
  -> GEOGRAPHIC BOUNDARY TYPE  ("described by" / "the description for")
  subtypes:
    COUNTY CITY, CITY, COUNTY, POSTAL CODE, PROVINCE, TERRITORY, STATE,
    COUNTRY, SALES TERRITORY, SERVICE TERRITORY, REGION
  specific relationships drawn between subtypes (confirmed with a close-up photo):
    COUNTY CITY: intersection of CITY ("within" / city "containing") and COUNTY ("specified for")
    CITY, COUNTY within STATE ("composed of")
    POSTAL CODE, PROVINCE, TERRITORY, STATE within COUNTRY ("having" / "composed of")
    SALES TERRITORY, SERVICE TERRITORY, REGION: no specific lines, only the generic association

GEOGRAPHIC BOUNDARY TYPE
  # geo_boundary_type_id
  * description
```

**Discussion**
- **The address is separated from the party.** PARTY POSTAL ADDRESS links them many-to-many with
  dates: a person moves (new row, old one gets a thru date), a family shares one address, and a
  company has many sites. The address itself is stored once.
- **Only the street part stays on the address** (address1, address2, directions). City, state,
  postal code and country aren't columns; they're GEOGRAPHIC BOUNDARY rows the address is linked
  to through POSTAL ADDRESS BOUNDARY. One address sits inside many boundaries at once: a city, a
  state, a postal code, a country, and also a *sales territory*.
- **Boundaries nest through a many-to-many association,** not a single parent column. A postal code
  can cross city lines, and a sales territory can cover parts of several states.
- **Same move as 2.5 → 2.6a:** the specific "city within state" lines inside the box are the
  readable version; GEOGRAPHIC BOUNDARY ASSOCIATION is the generic one.
- **COUNTRY is a geographic boundary here,** while our 2.2b schema already has a standalone
  `country` table for citizenship. The two need reconciling.

### Fig 2.9 — Party contact mechanism: telecommunications numbers and electronic addresses
**Transcription** (confirmed against the book: ☑)

```
PARTY CONTACT MECHANISM
  # from_date
  o thru_date
  o non_solicitation_ind
  o comment
  -> PARTY               (many "the mechanism to contact" 1 party; party "contacted via")
  -> CONTACT MECHANISM   (many "specified for" 1 mechanism; mechanism "used by")

CONTACT MECHANISM
  # contact_mechanism_id
  -> CONTACT MECHANISM TYPE  (many "described by" 1 type; type "the description for")
  subtypes:
    TELECOMMUNICATIONS NUMBER
      o country_code
      * area_code
      * contact_number      (the book prints "contact mechanism" here; confirmed as contact number)
    ELECTRONIC ADDRESS
      * electronic_address_string

CONTACT MECHANISM TYPE
  # contact_mechanism_type_id
  * description
```

Optionality (confirmed): a party contact mechanism must point to one party and one mechanism;
a party may have none, and a mechanism may be unused.

**Discussion**
- **Same shape as 2.8:** a contact mechanism is stored once and linked to parties through a
  dated intersection. A shared switchboard number or a team inbox is one row used by many
  parties.
- **The intersection carries the business facts.** `non_solicitation_ind` ("don't market to me
  on this number") belongs to *this party on this mechanism*, not to the number. The same number
  can be off-limits for one person and fine for another.
- **Subtypes vs. type: two classifications at once.** The subtypes split mechanisms by *structure*
  (phone numbers have country/area/number parts, electronic addresses are one string). CONTACT
  MECHANISM TYPE splits by *use* (phone, mobile, fax, modem, e-mail). Mobile and fax are both
  telecommunications numbers with the same columns, so they don't need their own subtype.
- **The type hangs off the mechanism, not the intersection.** A number is a fax line no matter
  who uses it. *What it's for* (work, home, billing) isn't drawn here.
- **Postal address is still separate** from contact mechanism in this figure.

### Fig 2.10 — Party contact mechanism (expanded)
**Transcription** (confirmed against the book: ☑)

```
PARTY CONTACT MECHANISM PURPOSE
  # from_date
  o thru_date
  -> PARTY CONTACT MECHANISM         (many "used within" 1; pcm "used for the purpose of")
  -> CONTACT MECHANISM PURPOSE TYPE  (many "defined via" 1; type "used to specify")

CONTACT MECHANISM PURPOSE TYPE
  # contact_mechanism_purpose_type_id
  * description

PARTY CONTACT MECHANISM
  # from_date
  o thru_date
  o non_solicitation_indicator
  o extension                        (new in 2.10)
  o comment
  -> PARTY              (many "the mechanism to contact" 1; party "contacted via")
  -> CONTACT MECHANISM  (many "specified via" 1; mechanism "used by")
  -> PARTY ROLE TYPE    (many "specified for" 1; role type "used to specify")   new in 2.10

CONTACT MECHANISM LINK               (no attributes drawn)
  -> CONTACT MECHANISM  "from"  ("related to")
  -> CONTACT MECHANISM  "to"    ("related to")

CONTACT MECHANISM
  # contact_mechanism_id
  -> CONTACT MECHANISM TYPE  ("described by" / "the description for")
  subtypes:
    POSTAL ADDRESS               (moved in from 2.8)
      * address1
      o address2
      o directions
    TELECOMMUNICATIONS NUMBER
      * area_code
      * contact_number
      o country_code
    ELECTRONIC ADDRESS
      * electronic_address_string

CONTACT MECHANISM TYPE
  # contact_mechanism_type_id
  * description
```

Optionality (confirmed): PARTY CONTACT MECHANISM → PARTY ROLE TYPE is optional; a purpose must
point to one link and one purpose type.

**Discussion**
- **Postal address becomes a contact mechanism.** A street address, a phone number and an e-mail
  all answer "how do I reach this party?", so they share one link (PARTY CONTACT MECHANISM), one
  set of dates, one do-not-solicit flag and one set of purposes. PARTY POSTAL ADDRESS from 2.8 is
  absorbed.
- **Purpose is its own dated entity,** not a column. One link can be billing *and* shipping, and
  each purpose can start and stop on its own. This answers the 2.8 question about *what an
  address is for*.
- **Extension sits on the link, not the number.** Everyone at the Northwind switchboard shares
  one number but has their own extension.
- **The role type says which hat the party wears** when using this mechanism: Ana's work line as
  an EMPLOYEE, not for her as a CUSTOMER.
- **CONTACT MECHANISM LINK** relates mechanisms to each other, e.g. a phone that forwards to
  another number, or a fax line tied to a phone.

### Fig 2.11 — Facility versus contact mechanism
**Transcription** (confirmed against the book: ☑)

```
PARTY CONTACT MECHANISM      (as in 2.10; purposes and role type not redrawn)
  -> PARTY, -> CONTACT MECHANISM

FACILITY CONTACT MECHANISM   (no attributes drawn)
  -> FACILITY           (many "the mechanism to contact" 1 facility; facility "contacted via")
  -> CONTACT MECHANISM  (many "specified via" 1 mechanism; mechanism "used by")

FACILITY ROLE                (no attributes drawn)
  -> PARTY               (many "for" 1 party; party "involved in")
  -> FACILITY            (many "of" 1 facility; facility "involving")
  -> FACILITY ROLE TYPE  (many "described by" 1 type; type "the description for")

FACILITY ROLE TYPE           (no attributes drawn)

FACILITY
  # facility_id
  * description
  o square_footage
  -> FACILITY       (recursive: "part of" / "made up of")
  -> FACILITY TYPE  ("described by" / "the description for")
  subtypes: WAREHOUSE, PLANT, BUILDING, FLOOR, OFFICE, ROOM   (no attributes)

FACILITY TYPE
  # facility_type_id
  * description

CONTACT MECHANISM            (as in 2.10: POSTAL ADDRESS, TELECOMMUNICATIONS NUMBER,
                              ELECTRONIC ADDRESS)
```

Confirmed: FACILITY ROLE, FACILITY CONTACT MECHANISM and FACILITY ROLE TYPE have no attributes
drawn; "part of" is optional; every facility has a type.

**Discussion**
- **A facility is a physical place; a contact mechanism is a way to reach someone.** A warehouse
  has square footage, is made of floors and rooms, and parties own, rent or use it. A postal
  address only says where to send mail. They often line up 1:1, but not always: a campus has
  several buildings at one address, and a warehouse can have a mailing address and a separate
  delivery-dock address.
- **Facilities get contact mechanisms the same way parties do,** through their own intersection
  (FACILITY CONTACT MECHANISM). The conference room has a phone, the warehouse has an address.
- **Facilities nest with a single "part of" link** (room → floor → building), not a many-to-many
  association like geographic boundaries. A room is in exactly one floor.
- **FACILITY ROLE says how a party is involved with a facility** (owner, tenant, user, manager):
  the same "party plays a role in something" idea as PARTY ROLE, but scoped to one facility.
- **The subtypes have no attributes,** so (as in Fig 2.1 and 2.8) they become FACILITY TYPE rows.

### Fig 2.12 — Communication event
**Transcription** (confirmed against the book: ☑)

```
COMMUNICATION EVENT
  # communication_event_id
  * datetime_started
  o datetime_ended
  o note
  -> COMMUNICATION EVENT STATUS TYPE  ("monitored by" / "used to monitor")
  -> PARTY RELATIONSHIP               ("in the context of" / "contacted via")
  -> CONTACT MECHANISM TYPE           ("occurs via" / "the contact medium for")
  subtypes (no attributes): PHONE, FAX, FACE-TO-FACE, LETTER CORRESPONDENCE, EMAIL,
                            WEB SITE COMMUNICATION

COMMUNICATION EVENT PURPOSE
  o description
  -> COMMUNICATION EVENT               (many "the category for" 1 event; event "categorized by")
  -> COMMUNICATION EVENT PURPOSE TYPE  ("described by" / "the description for")
  subtypes (no attributes): SUPPORT CALL, INQUIRY, CUSTOMER SERVICE CALL, SALES FOLLOW UP,
                            MEETING, CONFERENCE, ACTIVITY REQUEST, SEMINAR

COMMUNICATION EVENT PURPOSE TYPE
  # comm_event_purpose_type_id
  * description

COMMUNICATION EVENT ROLE             (no attributes drawn)
  -> COMMUNICATION EVENT       ("of" / "involving")
  -> PARTY                     ("for" / "involved in")
  -> COMMUNICATION EVENT ROLE TYPE  ("described by" / "the description for")

COMMUNICATION EVENT ROLE TYPE        (no attributes drawn)

VALID CONTACT MECHANISM ROLE         (no attributes drawn)
  -> CONTACT MECHANISM TYPE         ("for" / "used for")
  -> COMMUNICATION EVENT ROLE TYPE  ("described by" / "the description for")

COMMUNICATION EVENT STATUS TYPE      (no attributes drawn)

PARTY RELATIONSHIP, PARTY ROLE, PARTY, CONTACT MECHANISM TYPE   (as before)
```

Optionality (confirmed): the relationship is optional; status type and contact mechanism type
are mandatory.

**Discussion**
- **Events get their own participants.** In 2.7 an event hung off one relationship, so it could
  only involve that relationship's two parties. COMMUNICATION EVENT ROLE lets any number of
  parties take part, each with a role (caller, receiver, attendee, organizer…). A seminar with 30
  attendees fits; a single relationship can't hold it.
- **The relationship is now optional context,** not the owner of the event.
- **An event can have several purposes** (a sales follow-up that turns into a support call), each
  with an optional free-text description.
- **VALID CONTACT MECHANISM ROLE is a rule stored as data:** which event role types make sense for
  each medium (an e-mail has a sender and cc'd parties; a phone call has a caller and a
  receiver).
- **The event subtypes repeat CONTACT MECHANISM TYPE** ("occurs via"): phone, fax, letter,
  e-mail, web site. The type relationship already says the medium, so the subtypes add nothing
  in the schema. FACE-TO-FACE is the odd one: it's a medium with no contact mechanism behind it.

### Fig 2.13 — Communication event follow-up
**Transcription** (confirmed against the book: ☑)

```
COMMUNICATION EVENT WORK EFFORT
  o description
  -> COMMUNICATION EVENT  (many "from" 1 event; event "followed up with")
  -> WORK EFFORT          (many "for" 1 work effort; work effort "has")

WORK EFFORT
  # work_effort_id
  * name
  * description
  o scheduled_start_date
  o scheduled_completion_date
  o total_dollars_allowed
  o total_hours_allowed
  o estimated_hours
  subtypes (no attributes): PROGRAM, PROJECT, PHASE, TASK, ACTIVITY

COMMUNICATION EVENT          (as in 2.12, plus:)
  -> CASE                    ("communicated as part of" / case "encompassing")

CASE
  # case_id
  * description
  * start_datetime
  -> CASE STATUS TYPE        ("in the state of" / "the status of")

CASE ROLE                    (no attributes drawn)
  -> CASE                    ("for" / "involving")
  -> PARTY                   ("of" / "involved in")
  -> CASE ROLE TYPE          ("described by" / "the description for")

CASE STATUS TYPE, CASE ROLE TYPE   (no attributes drawn)
COMMUNICATION EVENT PURPOSE        (as in 2.12)
```

Optionality (confirmed): an event may be part of a case; every case has a status.

**Discussion**
- **Two kinds of follow-up.** Looking back, a CASE groups the events that belong to one issue
  ("late deliveries in June": a call, two e-mails, a meeting). Looking forward, a WORK EFFORT is
  the work an event triggers ("send a revised quote", "fix the routing").
- **A case has its own participants** through CASE ROLE (owner, customer, reporter…), separate
  from who took part in each event.
- **Event ↔ work effort is many-to-many** through COMMUNICATION EVENT WORK EFFORT: one meeting can
  start two tasks, and a project can come out of several calls.
- **WORK EFFORT is a preview of Ch 6.** Only the attributes needed here are drawn; Ch 6 builds it
  out.

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
- **Additions not in the figure:** a standalone `country` table (with a readable name), later folded
  into `geographic_boundary` by Fig 2.8, and `thru_date > from_date` checks on every dated table.
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
  (PERSON_ROLE, ORGANIZATION_UNIT, DISTRIBUTION_CHANNEL…) that aren't assigned directly. A
  data-quality query catches violations (the seed has the Book Club as EMPLOYEE, and the
  Platform Team as plain ORGANIZATION_UNIT). CUSTOMER itself *is* assignable, because Table 2.5
  gives ACME the plain Customer role; its children (bill-to, ship-to, end-user) are more specific
  options. *History:* this was first a `role_type_party_kind` pairs table with composite FKs,
  which the database enforced; we dropped it for simplicity.
- **Identifier.** The book's identifier is (party, `party_role_id`). We use `party_role_id`
  alone, which is already unique.
- **Not enforced: overlapping periods of the same role.** Ana could hold two open EMPLOYEE rows.
  It's the same gap as names and classifications.
- **Known gap, on purpose:** a role says *what* a party is to us, but not *to whom*. Ben is a
  CONTACT and the Platform Team is a DEPARTMENT, but of which organization? The seed and a query
  show the hole, and the relationship figures (2.5, 2.6a) fill it.

### Fig 2.5
- **Key style:** surrogate primary keys and plain FKs, as everywhere in the chapter since the
  simplification. Rules a plain FK can't express become data-quality queries.
- **One table per relationship subtype** (`employment`, `customer_relationship`,
  `organization_rollup`), each with a surrogate id, two FKs to `party_role`, and dates. The
  PARTY RELATIONSHIP supertype only holds dates, so there's no supertype table; each subtype
  carries its own dates.
- **Columns are named for meaning** (`employer_party_role_id`, `employee_party_role_id`) with
  comments saying which is "from" and which is "to". The specific model can afford
  self-explaining names; the generic one in 2.6a can't.
- **Not enforced:** that each FK points at the right *kind* of role. A data-quality query checks
  it, and it catches the seed's deliberate error (Ben "employed" through his CONTACT role).
- **Also not enforced:** that a relationship's dates fall within the dates of both roles.

### Fig 2.6a
- **One `party_relationship` table** with a surrogate id, a type, `from_party_role_id`,
  `to_party_role_id`, dates and a comment. The relationship subtypes (EMPLOYMENT, CUSTOMER
  RELATIONSHIP…) are rows in `party_relationship_type`, as everywhere else in the chapter.
- **`party_relationship_type` keeps the book's single from/to role type**, pointing at
  whatever level of the role hierarchy the book uses (CUSTOMER, ORGANIZATION_ROLE, not only
  leaves). No expanded pairs table.
- **Addition: `role_type_ancestor` view** (recursive). It pairs every role type with itself and
  its ancestors, so one data-quality query can check *every* relationship type at any depth
  ("is BILL_TO_CUSTOMER a kind of CUSTOMER?"). Compare 2.5, which needed one hand-written check
  per table.
- **Directions:** 2.5 gives from/to for EMPLOYMENT, CUSTOMER RELATIONSHIP and ORGANIZATION
  ROLLUP, and Table 2.5 confirms SUPPLIER and DISTRIBUTION CHANNEL (agent), both from the outside
  party to the internal organization. ORGANIZATION CONTACT (contact → the organization they
  represent) and PARTNERSHIP (partner → internal organization) are still assumed.
- **The 2.5 tables stay loaded**, seeded with the same facts, and a consistency query checks
  that employment agrees in both models.
- **Generic payoff in the seed:** SUPPLIER and ORGANIZATION CONTACT relationships were added
  with no schema change. 2.5 would have needed two new tables. That finally answers "Ben is a
  contact *for whom*?" (Contoso).
- **Generic cost in the queries:** column names no longer explain themselves (`from_party_role_id`
  instead of `employer_party_role_id`); "all of X's relationships" needs an OR across both
  directions; and every query filters by type.
- **Not enforced:** cycles in ORGANIZATION ROLLUP (A within B within A). The org-chart query caps
  its recursion depth as a guard.

### Table 2.5
- **Loaded as seed data:** the ABC corporate family, end to end (parties, organizations, roles,
  relationships), in its own block at the end of `seed.sql`. A query rebuilds the table from our
  rows so it can be compared with the book.
- **`thru_date` is exclusive in this repo:** it's the first day the row is *no longer* valid, which
  is why consecutive rows share a date (SINGLE thru 2019-06-15, MARRIED from 2019-06-15). The book
  prints inclusive thru dates, so its "12/31/2001" is stored as 2002-01-01.
- The Customer Service Division is typed OTHER_INFORMAL in `organization_type`, because a
  division isn't a legal entity.

### Fig 2.7
- **Priority and status are added to the 2.6a table with `alter table`** in the 2.7 section of
  `schema.sql`, so each figure's contribution stays visible. Both are optional, current-value-only
  FKs, with no history.
- **`status_type` is one table with a parent column,** like `role_type`. Relationship statuses sit
  under a PARTY_RELATIONSHIP_STATUS grouping row, and later chapters can add their own groups. A
  data-quality query checks that a relationship only uses a relationship status (the seed plants
  the grouping row as a status).
- **Status duplicates what the dates already say.** An ended relationship (`thru_date` in the
  past) that is still "Active" is a contradiction, and a data-quality query catches it (the seed
  plants Ana's ended employment as Active). That's the price of storing a status next to dates.
- **`communication_event`** has a surrogate id, a mandatory FK to its relationship, `timestamptz`
  start and end, and a note. A data-quality query flags events outside the relationship's period
  (the seed plants a call three years after the agent relationship ended).
- **Tooling:** timestamps print as text in UTC (`scripts/db.js` sets the session time zone), so
  results don't depend on the machine.

### Fig 2.8
- **`country` folded into `geographic_boundary`.** A country is a boundary of type COUNTRY
  (ISO code in `geo_code`). `citizenship.country_id` now references `geographic_boundary`, and a
  data-quality query checks that it points at a COUNTRY (the seed plants Kiri with a
  "citizenship" of Illinois). The standalone `country` table from 2.2b is gone.
- **`geographic_boundary_type` and `geographic_boundary` are defined at the top of `schema.sql`**
  (and all boundaries are seeded at the top of `seed.sql`), because citizenship references them.
  This is the second "moved up" exception after `party`.
- **The boundary subtypes are rows** in the book's own GEOGRAPHIC BOUNDARY TYPE table. The book
  draws that type entity itself, so this matches the figure.
- **Keys:** surrogate `geographic_boundary_id` (the book's `geo_id`), `postal_address_id` (no
  identifier drawn in the book), and surrogate ids on the three link tables.
- **`geographic_boundary_association`:** `from` is the smaller boundary (within), `to` the one
  containing it (in), matching the child → parent direction of ORGANIZATION ROLLUP. The specific
  lines drawn between subtypes, COUNTY CITY included, are all just rows here.
- **Addition: `geographic_boundary_ancestor` view** (recursive, depth-capped against cycles).
  It answers "is this address anywhere inside the Midwest Sales territory?" at any depth.
- **Each address links explicitly to its postal code, city, state and country**, even though the
  association could derive the higher levels from the postal code. That's simpler to query, but
  it's duplication: nothing checks that an address's city really lies in its state.
- **Not enforced:** that every address has a city and a country. A data-quality query checks it
  (the seed plants a PO box linked only to a postal code).

### Fig 2.9
- **Real subtype tables:** `telecommunications_number` and `electronic_address` carry attributes,
  so each one shares `contact_mechanism_id` with the supertype. `contact_mechanism_kind` is the
  discriminator, and a data-quality query checks it matches the subtype row (the seed plants an
  e-mail mechanism with no address row).
- **`contact_mechanism_type` stays the book's lookup table** (phone, mobile, fax, modem, pager,
  e-mail, web address). Addition: `applies_to_kind`, so a data-quality query catches a phone
  number typed as e-mail (planted in the seed). Same idea as `role_type.applies_to_kind`.
- **Small drift from the book:** the book labels the local number "contact mechanism"; we call it
  `contact_number`.
- **`non_solicitation_ind` is a nullable boolean** (optional in the book): null means nobody asked.
  The seed shows one inbox (Contoso sales) where Contoso may be solicited and Ben may not.
- **Keys:** surrogate `party_contact_mechanism_id`; the book identifies the row by party +
  mechanism + from_date.
- **Not enforced:** overlapping periods for the same party and mechanism (same as 2.8).
### Fig 2.10
- **2.8 folded in (option A).** `postal_address` is now a contact-mechanism subtype keyed on
  `contact_mechanism_id`, and `postal_address_boundary` keys on it too. `party_postal_address`
  is gone: its rows are ordinary `party_contact_mechanism` rows. The address tables moved from
  the 2.8 section to the 2.10 section of `schema.sql` (they need `contact_mechanism`), and the
  2.8 queries were rewritten to go through contact mechanism. Same move as folding `country`
  into `geographic_boundary`.
- **`contact_mechanism_kind` gains POSTAL_ADDRESS,** and so does `applies_to_kind` (one new
  type row, POSTAL_ADDRESS). The 2.9 subtype check now covers all three subtype tables.
- **`role_type_id` on the link points at our `role_type`** (the book's PARTY ROLE TYPE).
  Not enforced: that the party actually plays that role during the link. A data-quality query
  checks it, at any depth of the role hierarchy (the seed gives Kiri, a prospect, a
  bill-to-customer link).
- **Purposes:** a surrogate key, with the book's from/thru dates. Not enforced: that a purpose
  stays inside its link's period. A data-quality query checks it (planted: a HOME purpose that
  outlives the Guadalajara link).
- **`contact_mechanism_link`** keeps only from/to, as drawn. With no type or dates it can't say
  *why* two mechanisms are linked (forwarding? same line?); a real system would add a
  link type.
### Fig 2.11
- **Deviation: dates added** to `facility_role` and `facility_contact_mechanism` (the book draws
  none). Every other link in the chapter is dated, and "Northwind leased the old warehouse until
  2015" needs them.
- **`facility_role_type`** gets the usual id + description (the book draws no attributes).
- **Subtypes are rows** in the book's FACILITY TYPE table (WAREHOUSE, PLANT, BUILDING, FLOOR,
  OFFICE, ROOM), as in 2.1 and 2.8.
- **"Part of" is a plain `part_of_facility_id` column** (one parent), unlike the many-to-many
  geographic boundary association. Not enforced: cycles. A recursive data-quality query catches
  them (planted: Annex A and Annex B are each part of the other). Also not enforced: a sensible
  nesting order (nothing stops a building being part of a room).
- **Roles sit on whole facilities**, so summing square footage over a party's roles is safe in the
  seed. If a party had roles on a building *and* its floors, the sum would count space twice.
### Fig 2.12
- **The 2.7 table grows:** `communication_event.party_relationship_id` is now nullable, and the
  event gains mandatory `status_type_id` and `contact_mechanism_type_id`. The five 2.7 events
  moved to the 2.12 section of `seed.sql`, so the new columns can be NOT NULL.
- **Event subtypes → `contact_mechanism_type` rows.** The "occurs via" medium already says phone,
  fax, letter (POSTAL_ADDRESS), e-mail or web. FACE_TO_FACE was added as a medium with no
  mechanism behind it, so `applies_to_kind` became nullable. The 2.9 "type fits kind" check now
  uses `is distinct from`, so a mechanism typed FACE_TO_FACE gets caught.
- **Purpose subtypes → `communication_event_purpose_type` rows** (the book's own type table).
- **Event statuses are a new group** (COMMUNICATION_EVENT_STATUS) in the shared `status_type` from
  2.7. A data-quality query catches an event using a relationship status (planted: ACME call).
- **`valid_contact_mechanism_role` is the book's rule table.** Event roles are checked against it
  by a data-quality query, not a composite FK (planted: Ana as "caller" on an e-mail).
- **No dates on event roles,** as drawn: the event's own start and end times cover it.
- **Seen in the queries:** the 2.7 "contact history with Contoso" query only finds events through
  a relationship, so it misses the follow-up e-mail to Ben that has none. Going through event
  roles (2.12) finds it.
### Fig 2.13
- **CASE → `communication_case`** (and `communication_case_role`, `communication_case_role_type`),
  because CASE is a reserved word in SQL.
- **`work_effort` is minimal** (only the attributes drawn here); Ch 6 will extend it. Its
  subtypes are rows in an added `work_effort_type` table, which this figure doesn't draw.
- **Case statuses are another group** (CASE_STATUS) in the shared `status_type`, like relationship
  and event statuses. A data-quality query catches a case using an event status.
- **`communication_event.communication_case_id`** is a plain optional FK, set by updates in the
  2.13 seed.
- **No dates on case roles,** as drawn.
- **Not enforced, checked by queries:** an event filed under a case that hadn't started yet
  (planted: the 1999 ACME call under a 2024 case), and work scheduled to start before the first
  event that triggered it.

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

**Specific (2.5) vs. generic (2.6a) relationships:**
- **Specific tables** fit a system with a few relationship kinds that are central to it
  (an HR system's employment, a CRM's account-contact). You get readable columns, one FK per
  meaning, and a place for kind-specific attributes (salary, credit terms).
- **Generic** fits many relationship kinds that keep growing, or a need to ask "everything
  connected to party X". New kinds are data, not migrations. The price is weaker constraints,
  queries full of type filters, and nowhere obvious to put kind-specific attributes.
- **A common middle ground:** the generic table for the long tail, plus specific tables (or
  extension tables keyed by `party_relationship_id`) for the one or two relationships the
  business revolves around.

**Addresses as boundaries:**
- Printing one address becomes a pivot over boundary rows (see the mailing-label query), and
  address entry needs a boundary picker instead of free-text fields.
- It pays off when the business *reasons* about geography: tax jurisdictions, sales and service
  territories, "all customers in region X", or keeping boundary names consistent. For an app that
  only prints shipping labels, `city`, `state`, `postal_code` and `country` columns on the address
  (or even on the party) are the right call, usually with a separate validated `country` code.
- **Separating the address from the party** is cheap and nearly always worth it once more than
  one party can share an address or a party can have several.

## Open questions
- **Directions of two 2.6a relationship types** (organization contact, partnership) are assumed,
  not taken from the book. Table 2.5 confirmed supplier and distribution channel.
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
