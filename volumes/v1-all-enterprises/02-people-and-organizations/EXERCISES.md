# Vol 1, Chapter 2 — Exercises

All figures (2.1–2.13) are built. Answers and the gaps log go in `EXERCISES-log.md` (or the
chapter's SQL files) and get reviewed; no answers are provided up front.

**Plan (trimmed 2026-10-09 to the time budget in `docs/practice.md`):** practice per submodel,
about 3 hours each. The section 0 core set served as the exam (done). What's left: reinforce
the gap rows marked **reinforce** below, then one small practice scenario per submodel, then
its entry in the design reference doc. Rows marked **recall** get one quick question, not a
reinforce loop. The other section 0 items and sections 1–9 are optional (see the note at
section 1). Ch 2 is done when all three submodels are done.

**Submodels and remaining work**
1. **Parties, roles and relationships** (Figs 2.1–2.6a): reinforce 3 rows, recall 2, scenario. ~1.5 h
2. **Contact mechanisms** (Figs 2.9–2.10): reinforce 1 row, spot-the-flaw 3a, scenario. ~1.5 h
   Postal addresses, facilities and geography (Figs 2.8, 2.11) parked on 2026-10-09 by the user's
   choice; revisit them with Shipments.
3. **Communication events and case** (Figs 2.7, 2.12, 2.13): reinforce 1 row, recall 1, scenario. ~1.5 h

## Progress

### Comprehension (0–4 scale, scored 2026-10-07)
0 untested · 1 recognises (understood once explained, or picked from options) · 2 explains with
help (right after hints or corrections) · 3 explains unprompted (right first time, own words) ·
4 applies cold (new setting, later session, no hints). Target before moving on: 3+ on every
main concept; 4 comes from the practice scenario.

#### 1. Parties, roles and relationships

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| Role vs classification | 2.3, 2.4 | party_type, party_classification (vs party_role) | 3 | — | Item 14: first answer right; "points to no one" in own words |
| PARTY ROLE + ROLE TYPE | 2.4 | role_type, party_role | 3 | — | Item 20 unprompted (one slip: roles set at party creation) |
| PARTY supertype | 2.3 | party, organization, person, party_display_name (view) | 3 | — | Item 1: "avoid duplication", needed a nudge to name the anomalies; 10-09 Q8 (vet clinic, naive client/employee/supplier tables): fix right, first diagnosis vague ("unreliable"), then two concrete anomalies unprompted (new role = new table; two answers for Ruiz's phone) |
| PARTY RELATIONSHIP + TYPE | 2.6a | party_relationship_type, party_relationship, role_type_ancestor (view) | 3 | recall | Item 20 strong; item 17 flipped direction, invented EMPLOYER; 10-09 Q3 cold: direction right (Huellitas → Ruiz), but called EMPLOYMENT a role and the clinic's side EMPLOYER again (should be INTERNAL_ORGANIZATION); relationship type as type + rule in one row understood |
| Specific vs generic relationships | 2.5, 2.6a | employment, customer_relationship, organization_rollup | 2 | reinforce | Item 26: misread as one wide table; salary subtype after questions; 10-09 Q9 not answered: user asked to study the pattern instead (shared-key subtype of party_relationship, salary needs a dated child) |
| Person details (name, marital status, physical characteristic, citizenship/passport) | 2.2 | person_flat, gender_type, person_name_type, person_name, marital_status_type, marital_status, physical_characteristic_type, physical_characteristic, citizenship, passport | 0 | recall | |
| Organization type | 2.1 | organization_type | 0 | recall | Partly covered by the subtype rule |
| Priority / status types | 2.7 | priority_type, status_type | 0 | — | Covered by a scenario question, no own loop |

#### 2. Contact mechanisms (facilities and geography parked for Shipments)

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| Non-solicitation on the link | 2.9 | party_contact_mechanism | 2 | reinforce | Right table in warm-up; reasons came via the switchboard scenario; 10-09 Q4 (Ana's mobile): opted out by ending a PROMOTIONAL purpose instead of the flag, and gave a purpose she never asked for |
| Purpose (dated, within link) | 2.10 | contact_mechanism_purpose_type, party_contact_mechanism_purpose | 3 | — | 10-07: many purposes per link → own table; own dates because a purpose can end before its link but never outlive it (unprompted) |
| Move vs typo; shared mechanism | 2.8, 2.10 | contact_mechanism, party_contact_mechanism | 3 | — | 10-07: Contoso/Fabrikam unprompted; in-place update "returns a false time frame" and loses the old number |
| CONTACT MECHANISM + subtypes | 2.9, 2.10 | contact_mechanism_type, contact_mechanism, telecommunications_number, electronic_address, postal_address, contact_mechanism_link | 3 | — | 10-09 Q4: contact_mechanism of kind PHONE with the value in the subtype row, unprompted. Earlier: Fax as subtype; telecom number needed the "tele…" hint; 10-07: pager inserts (kind → subtype table holds the value, PCM links the party) after three angles |
| Facility vs postal address | 2.11 | facility_type, facility, facility_role_type, facility_role, facility_contact_mechanism | 1 | parked (Shipments) | Needed the definition; "legal boundary", "nesting by size" |
| Geographic boundary | 2.8 | geographic_boundary_type, geographic_boundary, geographic_boundary_association, geographic_boundary_ancestor (view), postal_address_boundary | 0 | parked (Shipments) | |

#### 3. Communication events and case

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| Communication event + roles | 2.7, 2.12 | communication_event, communication_event_role_type, communication_event_role, communication_event_purpose_type, communication_event_purpose, valid_contact_mechanism_role | 3 | in scenario | 10-09 Q1 cold (vet call): caller/callee/attendee right; put a per-event row in valid_contact_mechanism_role, then fixed (Q2 right). Q7: role types right again (missed in Q6). Earlier 10-09 cold: all participants given one role type (read event role type as "type of event"); fixed after explanation, Tom/Maria/Lucy meeting right. Earlier: Item 51 with hints; 10-08 dental call: role + purpose rows right after the role pattern was explained; first put participants in party relationship; 10-08 Q4 (VIDEO): reuse-a-kind reasoning and valid-role inserts right, but kind name and event → type (not mechanism) needed showing; 10-08 own-words definition: what/who/how/why with role, role type, purpose, medium and the role rule (said "party role types" for the rule; context and status left out) |
| Case and work effort | 2.13 | work_effort_type, work_effort, communication_event_work_effort, communication_case, communication_case_role_type, communication_case_role | 2 | reinforce | 10-09 Q5–Q7 (vet clinic, medication issue): grouping and case roles (stakeholders differ from event participants) right; said a case "allows follow-ups" (that's work effort, from events); Q6 left out the work efforts Ruiz decided on, Q7 the check-up exam; case end as status right in Q7 (Q6 still said thru date). Earlier 10-09: case 0 → 1 (claim scenario) |

#### Cross-cutting (tested inside the submodels, no own loop)

| Concept | Fig | Tables | Level | Next | Evidence |
|---|---|---|---|---|---|
| Type / fact / rule layers | all | cross-cutting (every `*_type`; valid_contact_mechanism_role) | 3 | in scenarios | 10-09 Q2: rule table set up once, the DQ query joins event medium + role type (Tom as ATTENDEE on PHONE). Earlier: Spotted unprompted, but "type enforces a rule" needed correcting; 10-08: said rule rows "enforce at creation time" (they only feed a DQ query) |
| Subtype vs type row | 2.1, 2.9 | cross-cutting (organization_type, contact_mechanism_type) | 3 | — | Rule stated in item 44 after the employment/reseller hint; 10-07 reappeared, closed to 2 after much help; 10-08 cold, new domain (payment methods): sorted all nine names into three shapes, test "a grouping of types that share the same shape" (first wording still called the kinds "types") |
| Effectivity (as-of, exclusive thru) | all | cross-cutting (every from_date / thru_date) | 2 | in scenarios | 10-07: Contoso rows right except inclusive thru (fixed after one guiding question); asked why exclusive; 10-09 Q4: "thru = 2026-06-01 minus a day" again |

### Open threads
- **Subtype vs type row: closed 2026-10-08 (3).** Reopen if it slips in the capstone.
- **Move vs typo and purpose (both 3):** neighbourhood question parked. What connects to
  `contact_mechanism`, directly or through `party_contact_mechanism`, and what each connection means.
- **Item 27:** is "read the relationship type as a sentence, subject → object" Silverston's rule?
- **Section 6 exercise 4:** where the rule "SHIPPING needs a postal address" should live.

## 0. To ponder (collected while reading)

Answer in a sentence or three under each item. Tags show which figure raised it.

**Core set (done, served as the exam):** **1, 13, 14, 17, 20, 26, 38, 43, 44, 46, 49, 51.**
**All other items are optional** (trimmed 2026-10-09): kept for reference, not part of the
plan. Pick one only if it catches your interest and the submodel's time budget allows.

### Why the model is shaped this way
1. **[before 2.1]** Why make PARTY a supertype at all, instead of separate `customer`,
   `supplier` and `employee` tables? What goes wrong with the separate tables?
   > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
2. **[2.2b]** Height and weight moved from columns into PHYSICAL CHARACTERISTIC rows (type +
   value). What can you do with rows that you can't with columns? What does the database stop
   checking for you?
3. **[2.1 vs 2.3]** In 2.1 an organization has exactly *one* type (a single column). In 2.3 a
   party has *many* dated classifications. Why did Silverston keep Legal/Informal as a subtype,
   but make Industry and Size classifications? What's the rule for deciding which is which?
4. **[2.2b]** A passport belongs to a CITIZENSHIP, not directly to a PERSON. What does that
   say about the real world, and what would be lost by linking the passport straight to the person?
5. **[2.2b]** Some attributes moved into dated entities (name, marital status) and others stayed
   on PERSON (birth date, SSN, mother's maiden name). What's the test for which is which?

54. **[general, raised by the user 2026-10-07]** Type tables, fact tables and rule tables
    (knowledge level vs operational level). Ch 2 has 19 type tables, 4 role-pattern pairs
    and 3 rules. In your own words: what does each layer say, and why are so few type tables
    also rules? Predict where Ch 3 (Products) will use each layer.

### Challenge the book (and our implementation)
6. **[2.2b]** The book draws PHYSICAL CHARACTERISTIC's `from_date` as `*` (not part of the
   identifier), which allows one value per person and type, ever. Is that an erratum, or can you
   find a reading where it's intentional? We deviated; do you agree?
7. **[2.3]** Fig 2.3 makes first and last name mandatory. Kiri has only one name. Should the
   rule exist? Who pays when a model's rule doesn't match reality: the database, the app, or
   the user?
8. **[2.2b]** Chloe has no marital status rows. How is "unknown" different from "single", and
   why does the flat 2.2a model hide that difference?
9. **[2.2b]** PASSPORT first used a three-column foreign key to CITIZENSHIP (the book's natural
   key: person, country, from_date), and we replaced it with a surrogate `citizenship_id`. What
   did each version give you? What does a surrogate key hide, and does that matter?

### Where rules should live
10. **[2.1, 2.3]** These rules are *not* enforced by the schema: an informal organization can
    have a tax ID; a party can be SMALL and MEDIUM at once; two current last names can coexist;
    a party can exist with no person/organization row. For each one: database constraint,
    application code, or a periodic data-quality query? Why?
11. **[2.3, 2.4]** We first used composite foreign keys so the database itself rejected a
    person being an organization, or an organization playing EMPLOYEE, and then dropped them for
    data-quality queries. What did we give up? In what kind of system would you bring them back?

### When not to use it
12. **[2.2b]** Attributes-as-rows (EAV) vs. plain columns vs. a Postgres `jsonb` column: when
    would you choose each one?
55. **[2.9, raised by the user 2026-10-07]** Why doesn't CONTACT MECHANISM hold one generic
    `value` column instead of subtype tables? (Discussed in chat: parts, boundary links and
    per-shape rules vs the join cost. Revisit with item 12 in section 7.)
13. **[general]** Universal models are generic up front. When is a plain `customers` table the
    *right* design, and what signal tells you it's time to refactor to PARTY?
    > **Answered 2026-10-06 (partial)** See EXERCISES-log.md.

### Roles (Fig 2.4)
14. **[2.4]** Roles and classifications both link a party to a type with dates. What's the
    conceptual difference? Could "customer" be a classification instead? Could "industry" be a role?
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
15. **[2.4]** PARTY ROLE has its own `party_role_id`, and `from_date` isn't part of its
    identifier. PARTY CLASSIFICATION is identified by (party, type, from_date). Why would a role
    need an identity of its own? What might reference it?
16. **[2.4]** A company is both your customer and your supplier. How does a naive
    `customer` + `supplier` table design handle that, and what breaks when its address changes?
17. **[2.4]** "Ana is an EMPLOYEE." Employee *of whom*? What can't a role alone express, and
    where should that information live?
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
18. **[2.4]** Why is DEPARTMENT a *role* an organization plays, rather than an organization
    *type* like CORPORATION in 2.1?
19. **[2.4]** Some roles are person-only, some organization-only, some either. Should the
    database enforce that, or is a data-quality query enough? How would a constraint handle "either"?

### Relationships (Fig 2.6a)
20. **[2.6a]** A relationship links two *roles*, not two parties. What would be lost if
    PARTY RELATIONSHIP pointed straight at two parties plus a type?
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
21. **[2.6a]** Relationships have a direction (from → to). For a symmetric one like PARTNERSHIP,
    which party is "from"? What does direction cost when querying "all of X's relationships"?
22. **[2.6a]** PARTY RELATIONSHIP only carries dates and a comment. Where would data specific
    to one kind of relationship go, such as an employee's salary or a customer's credit terms?
23. **[2.6a]** ORGANIZATION ROLLUP builds a hierarchy out of relationships. How would you
    query a department's whole chain up to the top? What stops a cycle (A rolls up to B, B to A)?
24. **[2.6a]** With relationships in place, can a role exist *without* any relationship? Is
    "Kiri is a PROSPECT" meaningful on its own, or should it always be "a prospect *of* someone"?
25. **[2.6a]** Ana can hold two EMPLOYMENT relationships at the same time, with two internal
    organizations. Is that a feature (part-time in two companies) or a data error? How would you tell?
26. **[2.5 vs 2.6a]** Specific relationships (2.5: one subtype per relationship, each with its own
    lines) vs. generic (2.6a: one PARTY RELATIONSHIP plus a TYPE row). What does each make easy,
    and what does each make hard? Which one tells a new developer more about the business?
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
27. **[2.5]** Employment is drawn *from* the internal organization *to* the employee. Would you
    have drawn it the other way? Does direction carry meaning, or is it just a convention to agree on?
    > **Discussed 2026-10-06:** See EXERCISES-log.md.
28. **[2.6a]** The single data-quality query for 2.6a relies on the role hierarchy (the
    `role_type_ancestor` view). What happens to existing relationships if someone moves a role
    type to a different parent? Is the hierarchy data, or schema in disguise?
29. **[2.6a]** We *assumed* the direction of two relationship types (contact, partnership). If the
    book says otherwise, which rows would have to change, and would any query notice?
30. **[2.6a]** PARTY RELATIONSHIP reaches ROLE TYPE by two paths: through its two PARTY ROLEs
    (what the roles *are*) and through its PARTY RELATIONSHIP TYPE (what they *should be*). Which
    path is a fact and which is a rule? What would you gain and lose by pointing the relationship
    straight at two *parties* and letting the type imply the roles?
31. **[Table 2.5]** ABC Subsidiary's SUBSIDIARY role is used twice: as the child of ABC
    Corporation and as the parent of the Customer Service Division. Its INTERNAL ORGANIZATION role
    is the "to" end of three relationships. Why is one role row per party per role enough? When
    would a party need *two* rows of the same role type?
32. **[Table 2.5]** The book prints inclusive thru dates ("thru 12/31/2001"); we store exclusive
    ones (2002-01-01). What goes wrong if one table in a system uses inclusive dates and another
    exclusive? Which convention makes "consecutive periods" and "as of" queries simpler?
33. **[2.4, Table 2.5]** ACME and XYZ are both customers, and each gets its own PARTY ROLE row
    pointing at the one CUSTOMER role type. Suppose instead they shared a single CUSTOMER
    party-role row: list three things that would break. Then name the three places where the
    model *does* get its reuse.

### Relationship information (Fig 2.7)
34. **[2.7]** A communication event hangs off a PARTY RELATIONSHIP, not off two parties. What
    does that buy you? How would you log a cold call to someone you have no relationship with yet?
35. **[2.7]** Status and priority are single values on the relationship, with no dates. When would
    the business need status *history* ("when did this customer become inactive?"), and how would
    you model it using a pattern from earlier in the chapter?
36. **[2.7]** STATUS TYPE is a shared supertype, with PARTY RELATIONSHIP STATUS TYPE as a subtype.
    One shared status table for every entity, or one status table per entity: what does each make
    easier, and what can go wrong with the shared one?
37. **[2.7 vs 2.3]** "Contoso is a high-priority customer." Is that a PRIORITY TYPE on the customer
    *relationship*, or a CLASSIFICATION of the *party*? When would the answer differ?

### Postal addresses (Fig 2.8)
38. **[2.8]** The address is a separate entity from the party, joined by dated PARTY POSTAL ADDRESS
    rows. What's the difference between "Ana moved" and "Ana's address had a typo"? How does each
    one change the rows?
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
39. **[2.8]** City, state and postal code are *not* columns on POSTAL ADDRESS; they're linked
    GEOGRAPHIC BOUNDARY rows. What does that buy you? What does it cost when you just want to
    print a mailing label?
40. **[2.8]** Boundaries nest through a many-to-many association instead of a `parent_id` column.
    Give a real example that a single parent column couldn't represent.
41. **[2.8, 2.2b]** COUNTRY is a geographic boundary here, but our citizenship uses a standalone
    `country` table. What goes wrong if both exist side by side?
42. **[2.8]** Nothing in this figure says *what an address is for* (billing, shipping, home).
    Where would that information belong: on the address, on the party-address link, or
    somewhere else?

### Contact mechanisms (Fig 2.9)
43. **[2.9]** NON-SOLICITATION IND is on PARTY CONTACT MECHANISM, not on CONTACT MECHANISM or
    PARTY. Give a case where putting it on each of the other two gives the wrong answer.
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
44. **[2.9]** "Mobile" and "fax" are CONTACT MECHANISM TYPE rows, but TELECOMMUNICATIONS NUMBER is
    a subtype. What rule decides whether a kind of thing becomes a subtype or a type row?
    (Compare the Fig 2.1 decision on attribute-less organization subtypes.)
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
45. **[2.9 vs 2.8]** Phone numbers and e-mail addresses share one supertype, but postal address
    has its own separate model. What do a phone number, an e-mail and a street address have in
    common? Would you merge them, and what would you gain?

### Contact mechanisms expanded (Fig 2.10)
46. **[2.10]** Ana's home address is her billing and shipping address, and it stops being her
    shipping address next year. Why does purpose need its own dated entity instead of a
    `purpose` column on PARTY CONTACT MECHANISM?
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
47. **[2.10]** EXTENSION is on PARTY CONTACT MECHANISM, not on TELECOMMUNICATIONS NUMBER. Why?
    (Think of the Northwind switchboard.)
48. **[2.10 vs 2.8]** Folding POSTAL ADDRESS into CONTACT MECHANISM: what does it gain, and what
    gets harder? (A query that only wants mailing labels, the geographic boundaries…)

### Facilities (Fig 2.11)
49. **[2.11]** Give one facility with two postal addresses, and one postal address with several
    facilities. What question does FACILITY answer that POSTAL ADDRESS can't, and the other way
    round?
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
50. **[2.11 vs 2.8]** Facilities nest with a single "part of" link, while geographic boundaries
    needed a many-to-many association. Why is the simpler structure good enough here? What
    real case would break it?

### Communication events (Fig 2.12)
51. **[2.12 vs 2.7]** In 2.7 every communication event belonged to one party relationship. Now
    the relationship is optional and parties join through COMMUNICATION EVENT ROLE. Give two
    events the 2.7 model couldn't store properly.
    > **Answered 2026-10-06 ✓** See EXERCISES-log.md.
52. **[2.12]** VALID CONTACT MECHANISM ROLE stores a rule as rows ("cc" only makes sense for
    e-mail). Compare that with writing the rule as a CHECK constraint or a data-quality query:
    who can change it, and when is each one the better choice?

### Follow-up (Fig 2.13)
53. **[2.13]** CASE groups related events. Why not just link events to each other ("this e-mail
    follows up that call") instead of adding a CASE entity? What can a case hold that a chain
    of events can't?

## Practice scenarios (one per submodel, on paper)
Model the minimal entities and a few sample rows, without the book. Note what you borrowed from
the chapter and what you left out on purpose. Scenarios are set when each submodel's
reinforce step is done.
1. **Parties, roles and relationships:** *(to set)*
2. **Contact mechanisms, facilities and geography:** *(to set)*
3. **Communication events and case:** *(to set)*

---

> **Sections 1–9 are optional (trimmed 2026-10-09).** Only **3a** (spot the flaw) is part of the
> plan, under submodel 2. The rest stay as a menu for spare time; the section 9 capstone is
> replaced by the three practice scenarios above.

## 1. Redraw from memory
Do one piece per sitting, without the book, NOTES or schema. Write it in the transcription
notation (entities, key attributes, relationships with cardinality), then diff it against
`NOTES.md` and list what you missed or got wrong.
1. **Parties:** PARTY, its subtypes, PARTY ROLE, PARTY RELATIONSHIP and their type tables
   (Figs 2.3, 2.4, 2.6a).
2. **Reaching parties:** CONTACT MECHANISM with its subtypes, PARTY CONTACT MECHANISM, purposes,
   and FACILITY with its links (Figs 2.10, 2.11).
3. **Talking to parties:** COMMUNICATION EVENT, its roles and purposes, CASE and the work-effort
   link (Figs 2.12, 2.13).

## 2. Explain why
Short answers, 2–3 sentences each.
1. Why does Northwind's switchboard number exist once, with three party links, instead of
   being stored three times?
2. Almost every link table here has from/thru dates. Name one business question for each of
   party role, party contact mechanism purpose and facility role that needs them.
3. FACILITY TYPE, ORGANIZATION TYPE and CONTACT MECHANISM TYPE are lookup rows, but
   TELECOMMUNICATIONS NUMBER is its own table. What's the rule?
4. A CASE and a PARTY RELATIONSHIP can both group communication events. What's the
   difference in what each one *means*?
5. Relationship, event and case statuses all live in one `status_type` table. What does that
   save, and what does it cost? (Look at the data-quality queries.)

## 3. Spot the flaw
Three small models, each with a mistake. For each: what data can't it hold, or what does it
corrupt? Then fix it.

**a)** (two flaws)
```
PARTY CONTACT MECHANISM
  # party_id               -> PARTY
  # contact_mechanism_id   -> CONTACT MECHANISM
  * from_date
  o thru_date
  o purpose_type_id        -> CONTACT MECHANISM PURPOSE TYPE
```

**b)**
```
FACILITY
  # facility_id
  * description
  * postal_address_id      -> POSTAL ADDRESS
  o part_of_facility_id    -> FACILITY
```

**c)**
```
COMMUNICATION EVENT
  # communication_event_id
  * from_party_id          -> PARTY
  * to_party_id            -> PARTY
  * datetime_started
  o note
```

## 4. Extend it
**Requirement:** Privacy law says Northwind must keep a *history* of marketing consent: for each
party and channel (e-mail, phone, post), when consent was given or withdrawn, and how it was
collected (web form, phone call, signed letter). Today there's only a single
`non_solicitation_ind` flag on the party's link.

Change the model to support it, then add the SQL and seed rows (Ana withdrew phone consent on
a call in 2024). Decide what happens to `non_solicitation_ind`, and say whether the
communication event that captured the consent should be linked.

## 5. Write the queries
Add each one to `queries.sql` under a `-- name:` header.
1. **[2.2b]** Who changed their last name in the last 10 years? Show the old and new name.
2. **[2.10]** Each party's billing address as of 2024-01-01 (purposes and dates both matter).
3. **[2.10]** Parties with no current way to reach them at all: no address, no number, no
   e-mail.
4. **[2.11 + 2.10]** A truck broke down outside the Chatham warehouse. List every party with a
   current role at that warehouse, with their current phone numbers.
5. **[2.12 + 2.13]** For each case that isn't closed: its owner, the date of its last event and
   the days since then.
6. **[2.11]** Recursive: for each facility, the total square footage of its *direct* children.
   Flag any facility whose children add up to more than itself.

## 6. Break the model
Try to insert data that *should* be invalid. For each attempt, note whether it got through,
and if it did, whether it deserves a constraint, a data-quality query, or just a note.
1. **[2.2b]** Give someone two current (open) last names.
2. **[2.3]** Classify Contoso as SIZE_SMALL and SIZE_LARGE for the same period.
3. **[2.6a]** Make Contoso its own customer (both roles in the relationship belong to Contoso).
4. **[2.10]** Give Ana a SHIPPING purpose on her mobile number.
   *(The user asked on 2026-10-06 which rules govern purposes. The book gives PURPOSE TYPE
   none: it's a plain list. When you do this one, pick where the rule "SHIPPING needs a postal
   address" should live: `applies_to_kind`, a 2.12-style rule table, or a query.)*
5. **[2.11]** Make the HQ building part of Office 412.
6. **[2.12]** Log an e-mail with no participants at all.

## 7. Trade-offs
Two ways to model the same thing. Which would you choose, for which kind of system, and why?
1. **Specific relationship tables (2.5) vs one generic PARTY RELATIONSHIP (2.6a).** Take two
   systems: a 3-person startup's CRM, and a company-wide master-data hub.
2. **Rules as rows vs rules in the schema.** `valid_contact_mechanism_role` and
   `applies_to_kind` keep rules as data and check them with queries. The composite FKs we
   removed enforced similar rules in the schema. (Section 0 items 9, 11 and 52 cover this too.)

## 8. In your own words
Rewrite these NOTES.md sections yourself, 3–5 bullets each:
- The problem this pattern solves
- When NOT to use this

## 9. Capstone
**Scenario:** A co-working space wants a small system. Members are people, and many work for
member companies, which pay their bills. The building has floors, and each floor has desks and
bookable meeting rooms. Some rooms have their own phone. Each company has a billing address,
and some have a separate mail-forwarding address. Reception logs calls, e-mails and visits.
Some of these are complaints ("the Wi-Fi on floor 3 is down again") that are tracked until they
are fixed, and some turn into maintenance jobs.

Model it on paper, without the book: entities, keys, relationships and a few sample rows.
Then compare with this chapter's models and note where you differ and why.
