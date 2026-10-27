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
- **2026-10-09, mixed recall across submodels 1–3 (vet clinic "Huellitas Vet", 9 questions).**
  From now on, each question names its submodel only, with no concept or table hints (the
  user's request). Q1 (event, cold): three role types (caller, callee, attendee) right; said
  the call adds a row to `valid_contact_mechanism_role` (it's a rule table, set up once); the
  medium is `communication_event.contact_mechanism_type_id` (the kind, not the number). Q2
  (Tom as ATTENDEE, PHONE allows only caller/callee): insert succeeds, the DQ query reports
  it. Right. **Event roles 2 → 3, type/fact/rule 2 → 3.** Q3 (Ruiz employed since 2024-03-01):
  direction right; called EMPLOYMENT a role and the clinic EMPLOYER (book: INTERNAL_ORGANIZATION,
  a reusable "us" role); dates off by a month. Discussed: the relationship type row is lookup
  + rule (one from, one to), so no separate rule table, unlike contact mechanisms (many roles
  per medium); a new pair of roles is a new type; specialised roles use the role type
  hierarchy. **Relationship 2 → 3.** Q4 (Ana's mobile, no promotional calls from 2026-06-01):
  mechanism + subtype right unprompted (**subtypes 2 → 3**); gave a PROMOTIONAL purpose she
  never asked for and opted out by ending it, not with `non_solicitation_ind` (her instruction
  vs our usage); thru date "minus a day" (exclusive convention missed again). **Non-solicitation
  stays 2, effectivity stays 2.** Q5 (what a case solves): grouping + stakeholders separate
  from participants right; "a case allows follow-ups" wrong (work efforts hang off events).
  Q6 (medication issue, three events, Tom in charge): events, case link and case roles right;
  missed the two work efforts Ruiz decided on; role types left out; email logged as "mailing
  address"; case given a thru date. Q7 (closing the issue): role types back, two purposes on
  one event, case closed by status; didn't link the event to the case or treat the check-up
  exam as a work effort. **Case 1 → 2.** Q8/8b (naive client/employee/supplier tables): fix
  right; diagnosis first vague, then two concrete anomalies. **Party supertype 2 → 3.** Q9
  (salary, payment terms) not answered: the user asked to study the relationship subtype
  pattern instead (shared key on `party_relationship`; salary needs a dated child; payment
  terms belong to an agreement later), then the considerations for supertypes and subtypes
  in general.
- **2026-10-12, submodel 3 reinforce: case and work effort (Lucía's leak, building manager
  Omar, FixFast Plumbing, owner Propiedades Sol).** Explained first through the seed (case 2
  groups events 2, 3, 7; work effort 1 triggered by events 2 and 3). First attempt: four
  events right; work efforts linked to the 6 Mar event, not the case (**the 10-09 "case allows
  follow-ups" slip did not come back**); missed "check Pedro's flat" again; case status
  "unresolved" though the story closes it; only Propiedades Sol as a case role; skipped the
  visit question. Revision: found the inspection work effort; status completed; asked why
  status has no date (ponder 56); Lucía as REPORTER ("issuer"); stated unprompted that a case
  role type is the party's function for the case, not the kind of party; event → case FK on
  `communication_event`, one case per event, right. Still missing: Omar as OWNER; Propiedades
  Sol given "stakeholder" (every case role is one; WATCHER fits). Visit question: "both", but
  reasoned from what the visit *triggered* rather than what it *is*; missed that the 4 Mar
  call triggered the visit as work. Ordering the part: argued it isn't work (defensible; the
  order document itself is Ch 4). **Case stays at 2** (right after review).
  Follow-up: pushed back that the 4 Mar call was "only a call" (medium mistaken for the
  trigger); after the "does someone now have work to schedule and track?" test, linked the
  inspection to 4 Mar and placed the check of Pedro's flat on 6 Mar because Omar decided it
  there (right). Summed up as "one work effort for 4 Mar, one for 6 Mar", dropping "fit part",
  which 6 Mar also triggered. Four-event sweep: answer given on request (no score credit). Open for next session: none from this round; (a) case role
  types for Omar (OWNER) and Propiedades Sol (WATCHER): answer given on request, no score credit.
- **2026-10-12, contact mechanisms reinforce: Q1 (gym, Diego and Carla share an inbox; Diego
  opts out of offers from 2026-11-01).** Explained first through seed rows 9/10, 1/3, 6, and
  "purpose = usage, flag = the party's instruction". Answer: one EMAIL mechanism with its
  `electronic_address` row, two links (Diego 2024-02-10, Carla 2025-05-01), one BILLING
  purpose each, flag set true on Diego's link only, Carla untouched. Right unprompted
  (**non-solicitation 2 → 3**, neighbourhood pending). Purpose from dates left out. Asked
  whether a PROMOTIONAL purpose equals flag = false: no, marketing is never a purpose.
  Follow-up (prove which newsletter broke the request): saw that an in-place update loses the
  date, and split the link unprompted. Slips fixed after one guiding question each: new
  row's flag first written false; new from = old thru + 1 day (gap on 11-01; exclusive
  convention missed again); old BILLING purpose not ended (ended on 2026-11-01, new one on
  the new link). **Effectivity stays 2.**
  Q2 (neighbourhood of `party_contact_mechanism`): party, mechanism, purpose right; one step
  away: mechanism type, subtypes, purpose type. Missed the optional `role_type_id` (guessed
  "subtypes", then party_type); `contact_mechanism_link` and `facility_contact_mechanism`
  named for them. **Non-solicitation closed at 3** (user agreed).
- **2026-10-21, random recall across Chs 2–3 (the Ch 2 questions; Ch 3's are in its log).**
  An Acme story (three calls about a batch of broken pens).
  Q1 (what ties the three calls together?): communication case ✓ unprompted (**case 3**).
  Added "us" as an internal organization in the CALLEE role, then said it had linked the
  event role to a party role, not the party: **the 10-09 gap came back, self-caught; event
  roles 2**. Claude had first called it right without asking which table (Claude's slip).
  Q4 (a small HR app with only employment, with a salary on it: generic or specific?):
  framed it as a subtype table vs one fat table, salary as the reason ✓; no pick, and the
  main driver missed (how many kinds of relationship: generic pays off when kinds keep
  coming, or for "everything tied to party X"). **Specific vs generic stays 2.** Side
  question, "kind" or "subtype": Claude first said `_kind` means subtype tables behind it,
  then corrected itself (`inventory_item_kind` keeps one table, `order_kind` has no columns):
  `_kind` is a fixed exclusive split, `_type` an open lookup the business extends.
  Q7 (a technician sent to inspect the batch): a work effort off the last call through
  `communication_event_work_effort`, not off the case ✓ cold, with the case sitting there as
  bait from Q1 (**case vs work effort 4**). Claude added that the link is many-to-many.
  Q8 (Acme's one number, for billing and general calls): one link, two purposes on it, the
  digits in the telecom subtype ✓; purpose dates left out. Follow-up (where the flag lives):
  on the link ✓, true = don't solicit ✓. Why there came only after pushback ("me through this
  mechanism, but it's still my mechanism"; the second half, the link lives on for billing, is
  the user's own point). Ending the link for a new row to keep the flag's history called
  "bitemporal" ✗: it's valid time; bitemporal adds when we recorded it. Claude added the cost
  of the new row: the purposes must move to the new link. **Contact mechanisms 3.**
  Q10 (Acme is minority-owned and a customer): classification, role, and the relationship
  CUSTOMER → INTERNAL_ORGANIZATION ✓; why it matters thin ("tags vs behaviour"). Claude tied
  it to Ch 3, where market interest and price components condition on the party type.
  "Categories" for party classifications (vocabulary). **Role vs classification 3.**
  Process: the user found Claude "extra cold" in the read-backs, and a second "done?" made
  them hesitate; from now on a yes to the read-back counts as done.
- **2026-10-21 (later session), recall: event roles and specific vs generic.**
  Q12 (Tom, Acme's buyer, phones us: how do you record that Tom was the caller?): Acme and
  Tom as the parties, event roles CALLER for Tom and CALLEE for us, PHONE's valid roles
  checked by a data-quality query, the optional context Acme → us (the customer
  relationship) ✓ cold, with Tom's CONTACT role there as bait. Claude first gave 3 because
  the answer didn't say the row points at the party; the user pushed back ("Acme and Tom are
  the parties", then the roles for them) and was right: the doubt came from the Q1 history,
  not the text. **Event roles 2 → 4** (check it holds next time). Side point, not graded: Tom
  ↔ Acme guessed as employment, "no relationship without an internal organization" ✗; it's
  ORGANIZATION CONTACT (CONTACT → ORGANIZATION_ROLE), and employment runs from our internal
  organization only. Clarified: `communication_event_role` holds event, party and role
  type, no `party_role_id`; party roles reach the event only through the relationship context.
  Q13 (a CRM with customers, suppliers, partners, agents and contacts: which relationship
  model, and why?) asked, unanswered: the user stopped here. Opens the next session.
- **2026-10-23, recall (Q13 reworded as a travel agency CRM).** Part 1: one general structure,
  because everything that hangs off a relationship (roles at each end, contact mechanisms and
  communication events in its context) would otherwise repeat per kind ✓ cold; the other
  side not weighed (specific tables give readable columns and an FK per end, and a kind
  earns a subtype when it has attributes of its own, e.g. an agent's commission). Part 2:
  Marta as ORGANIZATION CONTACT ✓ (the Tom and Priya miss fixed), Luis as EMPLOYMENT ✓, Hotel
  Sol as both SUPPLIER and CUSTOMER, the second dated from March ✓. Directions 2 of 5:
  customer and contact drawn reversed (seed: CUSTOMER → INTERNAL_ORGANIZATION, CONTACT →
  ORGANIZATION_ROLE). **Rafa missed**: DISTRIBUTION CHANNEL, AGENT → INTERNAL_ORGANIZATION.
  People moving between companies: only Hotel Sol dated (an ended contact relationship and a
  new one is the history). **Specific vs generic 2 → 3.**
- **2026-10-24, question round Q2 (effectivity).** Paula's work mobile from 1 March 2026,
  last day 31 August: from 2026-03-01, thru 2026-09-01 ✓ cold, the first answer without the
  inclusive or "minus a day" slip (10-07, 10-09, 10-12). No why asked. **Effectivity 2 → 3.**
- **2026-10-25, question round Q3 (case and work effort).** FitZone: Iker phones about a
  double charge (Sara takes it), e-mails a statement (Lola takes charge, asks Ana to refund),
  Lola calls back and it's settled. One case over the three events ✓; event roles (caller /
  callee, sender / recipient) ✓ cold; two work efforts off the 5 March e-mail, not the case ✓
  cold (Lola's review counted as one, fine); Lola as owner and Iker as customer ✓ (names
  loose, the user's question "how specific?": the part played counts, not the type name).
  Sara, who only took one call, filed as a case participant ~: case roles are stakeholders
  in the issue, event roles who took part in one event. **How the case ends not given**
  (asked): its status moves to CLOSED or RESOLVED, no thru date (10-09 Q6's slip). The
  user's follow-up "a finishing date and a status change?" corrected to the status only; then
  asked whether events or cases carry effectivity: neither (a fact holds from/thru; an event
  happens, with start/end timestamps; a case is a process with a status). Tracker fix: the
  case row still said 2 from 10-12, though 10-21 had it at 3 (work effort at 4); now 3, the
  ending to retest. Event roles row 3 → 4 (10-21's later 4 held).
- **2026-10-25, question round Q5, sent as text (answered offline, later session).** The
  travel agency CRM used one generic party relationship table: name two things lost against
  a specific `employment` table, and what to do about each. Key: an FK per end that says who
  may stand there (→ a check query against the type's role rules); its own attributes, e.g.
  salary (→ a subtype sharing the key, or a dated child); readable columns, from/to meaning
  per type and a type filter in every query (→ a view per kind).
- **2026-10-25, Q5 answered the same day (pasted in this session).** Two losses named cold:
  the single-purpose FK per end ✓ (fix: a data-quality query flags non-compliant rows ✓;
  against what not said: the relationship type's valid from/to role types) and readable
  columns ✓ (fix: "proper documentation?" ~; the stronger fix is a view per kind, e.g.
  `employment` over `party_relationship` filtered by type, with employer / employee columns).
  Not needed (two asked), not named: the kind's own attributes (salary → a subtype sharing
  the key, or a dated child). Score: 3. Specific vs generic stays 3; the costs now weighed
  cold (the 10-23 gap), the view to retest.
- **2026-10-26, question round Q2 (case and work effort).** Hostal Lumbre: Marta's noise
  complaint (call 3 Mar, e-mail 4 Mar, desk meeting 5 Mar with a room move; Pablo owns it),
  sorted, then back on 12 Mar by e-mail. Asked: what changes when it's sorted; the 12 Mar
  return; can the model say when it was first sorted. Key: the case's status moves to
  RESOLVED, no thru; the 12 Mar e-mail is a new event on the same case and the status goes
  back to open; no, one status FK keeps only the present: add a dated status row per change
  (as Ch 4's ORDER STATUS).
  Answer: (1) status on the case row ✓ cold (the 10-09 / 10-25 gap closed). (2) the same
  case reopened ✓, a new case weighed and rejected for continuity ✓; the 12 Mar e-mail not
  put on the case ✗ (it's why the case reopens). (3) a status-change table with a date, the
  latest row current, older rows history ✓ cold: Ch 4's ORDER STATUS reinvented. Score: 3.
  Case row stays 3; the ending closed, the new event on the open case to watch.
- **2026-10-26, question round Q5 (specific vs generic).** Clínica Sol: employments, patient
  ↔ GP and suppliers all in `party_relationship`. Asked: what to give the HR analyst who wants
  employment(employer, employee, from, thru) without changing the model, and built from
  what; where each doctor's salary goes, with history. Key: a view over
  `party_relationship` filtered to EMPLOYMENT, joined through its two party roles to the
  parties (names via `party_display_name`); salary not on the generic row (meaningless for
  the other kinds) but in a dated child of the employment (one row per salary, from/thru),
  hung on an `employment` subtype sharing the key: Ch 9's EMPLOYMENT and PAY HISTORY.
  Answer: (1) a view ✓ cold (needed a reworded question: Claude's blame); built from what
  not given. (2) a subtype table ✓ and the why ✓ (salary means nothing on a supplier
  relationship); "with its history" missed: one column holds one value. Score: 3. Row stays
  3: the view closed; the source and the dated child to retest.
  Follow-ups: the complete answer restated by the user; the view's joins through the roles
  added. The dated salary first put on the `employment` subtype itself ✗ (it shares the key:
  one row per employment); the user saw why: a second row reads as fired and rehired. The
  child `pay_history` (own key, FK to employment, amount, from/thru) taken.

### 2026-10-27: round Q2, Submodel 3 (Óptica Clara: Marta's loose frame, case 40 open with the 3 Nov call; her 5 Nov e-mail; the 12 Nov screw and call)
- Key: (1) a new communication event, via EMAIL, 5 Nov, `communication_case_id` 40 (plus its
  roles: Marta sender, the shop recipient). (2) a work effort (replace the screw) followed up
  from the 5 Nov e-mail through `communication_event_work_effort`; a new event, via PHONE,
  12 Nov, on case 40; the case's status changes OPEN → CLOSED, no thru date.
- Answer: (1) the new event on case 40, the medium as its type (EMAIL, name half-remembered),
  cold ✓, the retest from Hostal Lumbre passed. (2) the work effort off the 5 Nov e-mail, with
  the reason (the call came after the work; a work effort looks ahead, not back) ✓ cold; the
  12 Nov call ✓ (its case link not said, read as covered by "everything is tied together");
  the case ended by its status, no thru date ✓ cold. Event roles not mentioned (not asked
  outright). Score: 4. Case and work effort 3 → 4.
- Follow-up, unprompted: Marta a stakeholder on the case, the technician not ✓ (the work
  reaches him through the work effort; a case OWNER is about responsibility, not doing the
  work). Three different "who"s kept apart: case roles, event roles, work effort assignments.
- **2026-10-27, question round Q5 (specific vs generic).** Colmena (coworking): members,
  staff, mentors, new kinds every few months. Asked: one table per kind or generic, and what
  decides; membership(member, from, thru) for the accountant, built from what; a fee per
  membership that changes (€150, €180 from 1 March), with history. Key: generic, because the
  kinds keep coming; a view over `party_relationship` filtered to MEMBERSHIP, joined through
  its party roles to the parties (`party_display_name`); the fee in a dated child of the
  membership (amount, from/thru), its dates inside the membership's, a check query.
  Answer: (1) generic ✓, "scales without code changes" (the kinds keep coming, said
  loosely), attributes → a subtype table ✓. (2) the view, filtered by type, from/thru, joined
  through the roles ✓ cold (the source, missed on 10-26). (3) a dated child with amount and
  from/thru, linked to the relationship ✓ cold (missed on 10-26); its dates inside the
  relationship's, "nothing enforces it" (a check query would). Part 3 needed one
  clarification (the per-membership fee, not a plan's list price: a fair ambiguity).
  Score: 4. Specific vs generic 3 → 4.
- **2026-10-27, question round Q7 (contact mechanisms).** Bodega Sierra: Pablo and Inés share
  Calle Luna 5, move to Calle Sol 8 on 1 Mar; a typo (Sol 9) found on 3 Mar; Pablo's invoices
  and Inés's deliveries to Sol 8. Key: (1) one new contact mechanism + postal address row,
  shared; two new links from 1 Mar; the two Luna links ended thru 1 Mar; the Luna row
  untouched. (2) fix the address row in place: a typo was never true, so there is no history
  to keep; a move was true until 1 Mar, so the old link is ended, not overwritten.
  (3) purpose rows on each party's own link: BILLING on Pablo's, SHIPPING on Inés's, dated
  inside the link.
  Answer: (1) all right, one shared address row, the subtype, the four link dates, cold ✓.
  (2) update in place ✓; the why not given ✗ (asked outright). (3) purpose rows ✓, invoices
  and deliveries guessed as purpose types ✓ (BILLING, SHIPPING), "wine deliveries" put in a
  description ~ (the type says it); which link each purpose sits on not said ~. Score: 3.
  Move vs typo stays 3 (the why to say cold); purpose stays 3 (per party's link).
