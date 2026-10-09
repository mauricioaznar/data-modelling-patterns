# Vol 1, Chapter 2 — Exercises log

History behind the tracker in `EXERCISES.md`: answers to section 0 items and the dated gaps
log. Append new entries; read only when a row's evidence is needed.

## Section 0 answers

### Item 1
**Answered 2026-10-06 ✓** (with prompting) The same company gets stored once per role.
Updates then miss a copy (cheque sent to the old address), and nothing ties the copies
together, so "everything about Contoso" means matching by name. One PARTY with many
PARTY ROLE rows fixes both. Started at "avoids duplication"; needed a nudge to name the
consequences.

### Item 13
**Answered 2026-10-06 (partial)** Built a ladder: `customers` → `account` with
`is_client`/`is_supplier` flags → PARTY + PARTY ROLE. Saw that flags lose role dates
and need a new column per role. Didn't name what PARTY *costs* a tiny shop (more joins,
more complex forms, more to learn) without being asked twice.

### Item 14
**Answered 2026-10-06 ✓** A role takes part in relationships; a classification only
labels. Industry can't be a role because it "points to no one" (no *of/to whom*). A role
can do a classification's grouping job (count CUSTOMER roles), but a classification
can't say *whose* customer: only PARTY RELATIONSHIP (from/to roles, checked against
its type) can.

### Item 17
**Answered 2026-10-06 ✓** (with corrections) A role has one end and can't name the
counterparty; that lives in PARTY RELATIONSHIP. First draft flipped the direction and
invented an EMPLOYER role. Fixed: EMPLOYMENT goes from INTERNAL_ORGANIZATION to EMPLOYEE.
INTERNAL_ORGANIZATION marks "our" parties and is the shared anchor for every
relationship type.

### Item 20
**Answered 2026-10-06 ✓** Without roles, the type's rule has nothing to check against.
Putting the role on PARTY allows only one role per party. Dropping it means deriving
roles from relationships, so a role can't exist without a relationship and an ended
relationship leaves the role ambiguous. (In review, Claude claimed 2.10 links contact
mechanisms to PARTY ROLE. The user challenged it, and it was wrong: 2.10 has an optional
ROLE TYPE on the party link, which overlaps a lot with purpose.)

### Item 26
**Answered 2026-10-06 ✓** (after correction) First read 2.6a as single-table inheritance.
Corrected: the generic table has no per-kind columns, and a new kind is an *insert*.
Salary goes in an `employment` subtype table sharing the relationship's PK, so the
specific design is used only where a kind has attributes. Specific tables show the
business in the *schema*; generic ones move that meaning into the *data* (type rows).

### Item 27
**Discussed 2026-10-06:** The user assumed direction is always us → them. The seed shows
it isn't: CUSTOMER and SUPPLIER relationships point *to* INTERNAL_ORGANIZATION. A
working rule is to read the type as a sentence, subject → object ("Acme *employs* Ana",
"Contoso *buys from* Acme"). Still open: is that Silverston's rule, or just ours?

### Item 38
**Answered 2026-10-06 ✓** (with multiple-choice scaffolding) Move: insert a new mechanism
and a new link, and end the old link, to keep history. Typo: update the mechanism in
place, leaving the link untouched. A move changes a *fact about the party* (the link);
a typo fixes a *fact about the place* (the mechanism). Needed help turning the principle
into concrete row changes.

### Item 43
**Answered 2026-10-06 ✓** On the mechanism: one opt-out on a shared number (Northwind
switchboard) blocks everyone linked to it. On the party: Ana opting out of one channel
blocks all her channels. Only the party-mechanism link gets both cases right.

### Item 44
**Answered 2026-10-06 ✓** "A subtype earns its own table once it has attributes the
generic entity doesn't share." TELECOMMUNICATIONS NUMBER has country/area code, while FAX
has nothing of its own, so it's a type row. Closes the warm-up "fax is a subtype" gap.
(Review addition: its own *relationships* can also earn a subtype a table.)

### Item 46
**Answered 2026-10-06 ✓** A link can have several purposes, and each one can end sooner
than the link but never outlive it, so purposes need their own rows and dates. With a
single column, a second purpose means a duplicate link. At first thought the mechanism
itself had dates; corrected: only the link and the purposes do.

### Item 49
**Answered 2026-10-06 ✓** (after scaffolding) Facilities are physical spaces that nest,
have a size and have parties playing roles in them. Addresses are official "where to
deliver" locations. First attempts gave party↔address queries, and read a corner
warehouse's two addresses as a legal-boundary question. Corrected: nesting is by
*containment*, not size.

### Item 51
**Answered 2026-10-06 ✓** (after a recap of 2.7) A cold call: no relationship exists yet
to hang it on. A meeting with more than two people: one relationship has only two ends.
2.12 makes the relationship optional context and adds COMMUNICATION EVENT ROLE for
any number of participants.

## Gaps log
Misunderstandings and reinforce attempts, oldest first.

- **2026-10-06, warm-up: subtype vs type row.** Listed "fax" as a CONTACT MECHANISM subtype.
  The subtypes are POSTAL ADDRESS, TELECOMMUNICATIONS NUMBER and ELECTRONIC ADDRESS. Fax, mobile
  and e-mail are CONTACT MECHANISM TYPE rows. Revisit with section 0 item 44 and section 2.3.
  *Item 44 (same day): stated the rule correctly. Still check it in section 2.3 and the capstone.*
- **2026-10-06, warm-up: effectivity convention.** Couldn't recall the as-of condition or the
  exclusive `thru_date` rule. Revisit in section 5 queries (every as-of query uses it).
  Worked through a concrete timeline: got `<=` / `>` right, but at first missed that a null
  `thru_date` makes `thru_date > d` null, which drops current rows. Check that the null case is
  handled in every as-of query the user writes.
- **2026-10-06, item 13: argues for the generic model without weighing its cost.** When asked
  "when *not* to use PARTY", the user argued for PARTY ("they'll undoubtedly need it"). Revisit
  in section 7 trade-offs: every answer should name what the generic design costs, not only
  what it buys.
- **2026-10-06, item 17: relationship ends.** Put the person at the "from" end of EMPLOYMENT
  and invented an EMPLOYER role. Revisit: relationship types fix both direction and the role
  type at each end, and "our side" is always INTERNAL_ORGANIZATION.
- **2026-10-06, item 26: generic ≠ single-table inheritance.** Read 2.6a's generic PARTY
  RELATIONSHIP as one wide table with a column group per relationship kind. In fact the
  subtypes have no columns and are *rows* in PARTY RELATIONSHIP TYPE, so a new kind is an
  insert, not a schema change. Revisit: "attribute-less subtype → type row" (same root as the
  subtype vs type row gap).
- **2026-10-07, reinforce: move vs typo (new setting).** Contoso's mistyped switchboard vs
  Fabrikam's new number. Unprompted: typo → update `contact_mechanism`; "party contact
  mechanism holds the lifecycle of a party's link to a mechanism"; new number → insert a
  mechanism and a link (thru null), and end the old link with last valid day + 1. Then: an
  in-place update gives March the new number (false time frame) and loses the old one. 1 → 3.
  **Not closed:** the neighbourhood question (what connects to `contact_mechanism`, directly or
  through `party_contact_mechanism`, and what each connection means) is parked for later.
- **2026-10-07, purpose (not a gap).** Said "a contact mechanism can have multiple purposes";
  on asking, meant `party_contact_mechanism` (shorthand). Unprompted: a party's link can have
  many purposes, so purpose needs its own table; a single purpose would be one column.
  Then, on dates: "a purpose cannot outlive the link; it can have a shorter lifespan", so
  SHIPPING ends with its own thru date. Purpose 2 → 3. Neighbourhood folded into the parked
  contact-mechanism one. Asked whether purpose type carries rules: it doesn't (plain list;
  only the "purpose within its link's period" query). The rule question stays on section 6
  exercise 4.
- **2026-10-07, reinforce: contact mechanism subtypes (WhatsApp, pager, X handle, GPS).**
  Applied the attribute rule unprompted: GPS gets a subtype table, the others become type rows.
  Missed two things: a type row's value still lives in an existing subtype table, and the third
  option ("not a contact mechanism at all", for GPS: what is a contact mechanism *for*?).
  Follow-up questions asked. Answers: (1) "each would have its own table": **the subtype vs
  type row gap reappeared**, contradicting the first answer. (2) "postal address is a kind of
  contact mechanism": true but didn't decide GPS. Re-explained with the seed (7 types, 3
  subtype tables; a subtype = a *shape* of value, a type = *what kind*), and asked again.
  Second try: (1) "contact mechanism type": still mixes up *naming the kind* with *storing the
  value* (the type table has only id + description). (2) "place": right (GPS → FACILITY, not a
  contact mechanism). Next angle: list the inserts to store Ben's pager number. Got there after
  seeing `contact_mechanism`'s columns (kind vs type): "for each kind a subtable holds the
  specific attributes; the telecom table holds the number"; PCM links Ben. Didn't remember
  where the number is stored. Asked how to query subtypes ("a union?"): a join on the shared
  PK; a union only to list every kind at once; a view hides it. CONTACT MECHANISM 1 → 2.
  Retest subtype vs type row cold next session.
- **2026-10-07, subtype vs type row: TELEX / SOCIAL_MEDIA_PROFILE.** After asking how
  `applies_to_kind` is built and how to know a kind has a subtype table (answer: every kind
  *is* a subtype table; types are what didn't need one). SOCIAL_MEDIA: new kind + CHECK value
  (table and query branch not named). TELEX: new type row, right, but `applies_to_kind`
  null "like FACE_TO_FACE": **confuses "no attributes of its own" with "no value"**. A
  type borrows an existing kind's shape (PAGER → TELECOMMUNICATIONS_NUMBER). Guiding question
  asked. Then: TELEX → telecommunications_number, right, but "I still don't get it". Own
  summary: mechanism = facts, type = "rules" (corrected: type = category; only
  `applies_to_kind` is a rule), DQ queries check after the fact; new kind = table + CHECK value
  + query branch (asked what the branch means: the union line that registers the table).
  Then, table by table: mechanism = "a way to reach a party that can be shared"; type =
  "categories, with a rule naming the domain (kind) they belong to, possibly none". Then the
  click: "the type points to a subtype the mechanism should enforce; creating a mechanism =
  pick a category, which fixes the subtype table". Subtype vs type row 1 → 2. Retest cold.
- **2026-10-08, subtype vs type row: cold retest (payment methods).** New domain, explorer
  closed. Mapped it onto CONTACT MECHANISM unprompted (facts / types / `applies_to` rule).
  First wording: "the payment method *types* that need a subtype table are card, wallet, bank
  account", so kinds were still called types (one guiding question: which column decides that
  a `card` table exists?). Then sorted all nine names correctly (Visa, Mastercard, Amex, debit,
  corporate → card; PayPal, Apple Pay → wallet; savings, checking → bank account) and gave the
  test in their own words: "a subtype is a grouping of types that share the same shape". 
  `visa_card` table: "duplicates the card logic". Right, but didn't name the cost (each new
  brand becomes a schema change). 2 → 3. Not closed: neighbourhood question and agreement.
  Follow-up, same day: Discover → `visa_card` "adds another kind" (schema change each brand)
  vs one type row. Neighbourhood: type → payment method ("each method is of one type, a type
  can be of many"); `applies_to_kind` → subtype tables "loosely, by text we must maintain, not
  a FK"; the DQ query catches "a mismatch between a payment method's kind and its type's
  applies_to_kind". Raised unprompted: changing or removing a used type rewrites history.
  Settled: retire or add a type, never edit its meaning; the FK blocks deleting a used type.
  User agreed. **Row closed at 3.**
- **2026-10-08, communication event (dental clinic video call: Ana, Tom, Rita; reschedule +
  billing).** Naive `call_log`: named both limits unprompted (one purpose, one receiver);
  damage: "they look like two separate events" (right). Tables: said the participants live in
  **party relationship** ("event → party relationship stores the recipients"), and invented a
  "communication event type (video call)". **Gap: confuses the event's context (one
  relationship, two ends) with its participants (COMMUNICATION EVENT ROLE rows).** Purposes not
  placed. Guiding questions asked.
  Asked how a role type relates to an event; explained COMMUNICATION EVENT ROLE as PARTY ROLE
  scoped to one event (event, party, role type), separate from the relationship (context).
  User noticed unprompted that participants aren't tied to the relationship's ends (right, and
  deliberate: Rita, interpreters, cold calls). Then: one event row; Ana ORGANIZER, Tom and Rita
  ATTENDEE (3 role rows); 2 purpose rows. Right. Called it a "phone call" (it was video);
  channel still open. 1 → 2.
- **2026-10-08, communication event: Q4 (VIDEO channel, valid roles).** Reasoning for VIDEO
  right unprompted: a Zoom/Teams call has a URL, so reuse the kind that holds a URL and add a
  VIDEO type row; a new subtype table only if no kind fits the shape. Two slips, both guesses:
  named the kind "website", then "link" (it's ELECTRONIC_ADDRESS; WEB_ADDRESS is a type row),
  and said the event points to `contact_mechanism` (it's `contact_mechanism_type`, "occurs
  via"). Shown the seed and the column. Then, own words: the type "establishes a medium
  without pointing to a specific fact that is impossible to know in some cases"
  (FACE_TO_FACE). Valid roles: the check flags the call's roles; insert (VIDEO, ORGANIZER) and
  (VIDEO, ATTENDEE). Right. Rule as rows: con right (every new medium needs its pairs or valid
  data gets flagged); pro said the rows "enforce pairings at creation time". **Same root as
  the type / fact / rule gap: the rule rows enforce nothing on insert; only the data-quality
  query catches a bad pair, after the fact.** Guiding question asked. Stays at 2: event → type
  needed showing. Too many stacked questions confused the user; ask one at a time.
  Restated the pro: "users are in control of their own ruling instead of a developer having
  to hardcode rules". Right (a rule change is an insert, no deploy). The insert-time question
  (does Rita's row fail without the pair?) is still unanswered.
  Answered "fail" (wrong: no FK reads the medium; the insert succeeds and only the DQ query
  flags it). Walked through the three FKs; user asked to stop questions and switch to
  explanation. Explained the submodel as a whole instead. Row stays at 2.
- **2026-10-08, communication event: own-words definition (end of session).** "Something
  that happens in a timeframe"; participants (role) with a function (role type); multipurpose
  (purpose rows, free description + type); happens through a channel, "not a particular fact
  like a cellphone number"; the channel has rules for which roles apply; what → event,
  who → participant, how → channel, why → purpose. Right and complete on the core. Slips:
  called the rule's other side "party role types" (it's `communication_event_role_type`, not
  2.4's `role_type`); left out the optional relationship context and the status. 2 → 3, but
  given right after an explanation in the same session: **retest cold next session** before
  closing. Neighbourhood mostly covered by the definition.
- **2026-10-09, communication event: cold retest (submodel 3), property management email.**
  Maria emails Tom, cc Lucy, about a wrong heating charge. Right unprompted: the event is the
  glue; participants through `communication_event_role` (not party relationship, last
  session's gap closed); EMAIL as the event's `contact_mechanism_type`. Slips: gave all three
  participants **the same role type**, reading `communication_event_role_type` as "the type of
  event"; said a `valid_contact_mechanism_role` row is added per event; left out purpose and
  status. After guiding questions: purpose right (own table, predefined type + description);
  rule table = set up once, valid pairs of channel × participant role type (first said
  "channel × type of event"); asked where the party's role for the event comes from →
  explained `communication_event_role` is (event, party, role type), pointing at PARTY, a
  per-event role vs 2.4's enterprise-wide `party_role`. Fresh question (Tom organizes a
  face-to-face meeting): ORGANIZER for Tom, ATTENDEE for Maria and Lucy (first answer said
  only "attendee", corrected straight away); "Maria is a tenant" → `party_role`, "attended" →
  `communication_event_role`. Right. **The gap reappeared cold: 3 → 2.** Status not yet
  answered. Retest event roles inside the submodel 3 practice scenario.
- **2026-10-09, case and work effort: first questions (submodel 3).** Q3 (no CASE: what can't
  you answer?): "which follow-up events belong to the problem, how are they related". Grouping
  only; missed that the issue has facts of its own (status, responsible party). 0 → 1. User
  asked event vs case and whether the case comes first → explained: event = one interaction,
  case = the issue, with its own status and roles; `communication_case_id` is optional and
  usually set after the first event. Q4 (insurance claim, sort four questions): a) adjuster
  visit → event + event roles, face-to-face channel. Right. b) "is the claim settled?" → case,
  but "with thru-date set" (wrong: the case has no thru date; it's the case's
  `status_type`). c) who handles it → case, hedged between "issuer", a property or a role
  (it's `communication_case_role`: party + case role type). d) every interaction with the
  customer about anything → "event". Right entity, but not how to find them: through the
  customer's `communication_event_role` rows (the party relationship is optional since 2.12,
  so it can't be the grouping; first graded wrong on that basis, corrected the same day). **Right entity for b and c,
  wrong mechanism, right after the explanation: case stays at 1.** Paused for a project
  discussion at the user's request.
