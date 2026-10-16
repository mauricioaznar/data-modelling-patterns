# Morning recall: mantras that explode

A solo routine for every morning, separate from the deep-dive sessions. The deep dives build
understanding; this keeps it from fading. No Claude needed, about 30 minutes, pen and paper.

**Anki:** `npm run recall:anki` writes `docs/recall-anki.txt`; import it with File → Import.
It fills two subdecks, *Data Models::Submodels* and *Data Models::Patterns*. This file stays
the source of truth: edit here, rerun, re-import. Each note's id comes from the volume, chapter
and figures in its heading (or the pattern number), so renumbering or rewording a card updates
its note; keep those three stable. A re-import updates a note's text but never moves its card
to another deck: after changing a deck in the script, move the cards with Browse → Change Deck.
Anki's scheduling replaces the boxes below; still write S · W · T · D on paper before you flip.

## The idea: compress, then decompress

Each submodel gets a **card** with three layers, from smallest to biggest:

1. **Hook**: two to four words or an image. Just enough to start the mantra.
2. **Mantra**: one sentence of at most about 20 words. It names the **spine** entities in the
   order they connect, with one verb per link, and ends with the **twist** (the thing the
   naive model gets wrong).
3. **Explosion**: what the mantra must unpack into, in one fixed shape (below). This is the
   answer key, and it's hidden on the card so you recall before you look.

Why the fixed shape: a mantra on its own is a password, not a model. You could recite it for
months and still not know what `party_relationship` points at. What makes memory stick is
**pulling it out of your head against a cue** and then checking, not re-reading. So the
mantra is only the zip file; the drill is unzipping it.

### The explosion shape: S · W · T · D

| Letter | What you produce | Time |
|---|---|---|
| **S**pine | The 3–6 core entities, each with its one-line job | 1 min |
| **W**hy | The problem it solves, and what the naive model breaks | 30 s |
| **T**rap | One mistake you actually made (from the gaps log), and the fix | 30 s |
| **D**raw | Boxes and lines from memory: which table points at which | 1 min |

Three minutes a card. If it takes ten, it's not a recall card any more: stop and flag it for a
deep-dive session.

## Rules for a good mantra

- **You write it, not Claude.** Generating it is half the encoding. Claude only checks that it
  explodes (does every spine entity fall out of it?) and that it's not wrong.
- **Spine nouns in connection order.** "A party plays a role; two roles make a relationship"
  tells you `party_relationship` hangs off roles, not parties. Order *is* the model.
- **One verb per link.** The verb is the FK. "plays", "pairs", "groups", "triggers".
- **End on the twist.** The surprising bit is the part you'll forget first.
- **Lossy is fine.** Attributes, cardinalities and type tables don't go in the mantra. They come
  back with the drawing, or they don't matter (see `practice.md`: attributes are out of scope).
- **Rewrite freely.** If a mantra fails to explode twice in a row, it's a bad mantra, not a bad
  you. Rewrite it, and bring it to the next session.

## The 30-minute morning

| Min | Block | What you do |
|---|---|---|
| 0–5 | **Map** | On a blank page, draw the chain of every submodel so far as boxes (Party → Contact → Places → Comms → Product → Features → Inventory…) and write each one's hook. No peeking. |
| 5–20 | **Deck** | The cards due today (see Schedule). For each: read the cue, say the mantra out loud, write S · W · T · D, then open the key and grade yourself. |
| 20–27 | **Twist** | Pick one due card and apply it to a random business (a dentist, a bike shop, a school, a festival). Two or three example rows, in your head or on paper. This is the step that stops it being parroting. |
| 27–30 | **Log** | One line per card in the log below: date, card, grade, box. Circle anything to bring to the next session. |

While the deck is small (it is now), the Deck block will finish early. Use the spare minutes
on Twist or on the pattern deck, not on adding more cards than you've studied.

## Grading and schedule (Leitner boxes)

Grade each card after opening the key:

- **✓ clean**: all of S, W, T and the drawing right → move up one box.
- **~ shaky**: one piece missing or wrong → stay in the same box.
- **✗ miss**: the mantra didn't come, or two or more pieces wrong → back to box 1, and circle it.

| Box | Review every | Means |
|---|---|---|
| 1 | day | new or just missed |
| 2 | 3 days | came back once |
| 3 | week | holding |
| 4 | 2 weeks | solid; most of the deck should end up here |

New cards start in box 1. A card enters the deck **after its walk-through** (when you first
understand the submodel), not after its practice ends, so nothing waits weeks to be revised.

---

## Deck: submodels

Cue · your hook · your mantra · the key (click to open, **after** you've recalled). Fill the
hook and mantra yourself. Cards 1–7 are Claude's, at the user's request: rewrite any that
don't explode, in your own words.

### Card 1 · V1 Ch 2 · Parties, roles and relationships (Figs 2.1–2.7)
- **Cue:** "Who is this, what are they to us, and how are they tied to each other?"
- **Hook:** people wearing hats *(Claude's, at the user's request)*
- **Mantra:** A party is who; a role is the hat it wears; a relationship joins two hats, and a
  type names each hat; a class says what it is underneath.

<details><summary>Key</summary>

- **S:** `party` (person or organization: one supertype, a `party_kind` discriminator) ·
  `party_role` (a party plays a `role_type`, dated) · `party_relationship` (from party role →
  to party role, of a `party_relationship_type` that says which role types it joins) ·
  `party_classification` (what a party *is*, e.g. an industry or a size band, vs. what it
  *does* for us).
- **W:** the same company is a customer, a supplier and a partner at once. Naive model:
  separate customer and supplier tables, so the name and address are duplicated, drift, and
  "everyone we deal with" needs a union.
- **T:** the relationship joins *roles*, not parties; and the specific tables (employment,
  customer relationship, rollup) vs. the one generic `party_relationship` (your open gap:
  specific vs generic).
- **D:** party ← party_role → role_type; party_relationship → party_role twice;
  party_relationship → party_relationship_type → role_type twice.
</details>

### Card 2 · V1 Ch 2 · Contact mechanisms (Figs 2.9–2.10)
- **Cue:** "How do we reach this party, for what, and since when?"
- **Hook:** the switchboard *(Claude's, at the user's request)*
- **Mantra:** Postal, phone and e-mail are one mechanism; the party's link to it owns the dates, the
  purposes and the "don't call"; mechanisms forward to mechanisms.

<details><summary>Key</summary>

- **S:** `contact_mechanism` (one supertype for postal address, telecom number, e-mail) ·
  `party_contact_mechanism` (this party uses this mechanism, dated, with the non-solicitation
  flag, extension and optional role) · `party_contact_mechanism_purpose` (why we use that link:
  billing, shipping, home…, each dated) · `contact_mechanism_link` (one mechanism tied to
  another, e.g. call forwarding).
- **W:** columns like `home_phone`, `work_phone`, `fax` on the party: a fixed number of slots,
  no history, a shared switchboard copied onto every person, no place to say "don't call".
- **T:** the purpose and the do-not-solicit flag belong to the **link** (party + mechanism),
  not to the mechanism or the party. The same number can be fine to call for one party and
  off-limits for another.
- **D:** party ← party_contact_mechanism → contact_mechanism (→ postal / telecom / electronic);
  party_contact_mechanism ← purpose → purpose_type; contact_mechanism_link → contact_mechanism
  twice.
</details>

### Card 3 · V1 Ch 2 · Postal addresses, facilities and geography (Figs 2.8, 2.11)
- **Cue:** "Which areas is this address inside, and which physical places do parties use?"
- **Hook:** the map and the floor plan *(Claude's, at the user's request)*
- **Mantra:** An address lies in many boundaries, boundaries in many boundaries; a facility nests
  in one, hosts roles, has mechanisms: a place isn't an address.

<details><summary>Key</summary>

- **S:** `postal_address` (only the street part: address lines and directions; a
  contact-mechanism subtype since Fig 2.10, so parties reach it through
  `party_contact_mechanism`) · `geographic_boundary` (city, state, postal code, country, sales
  territory… as `geographic_boundary_type` rows; country lives here, so citizenship points at
  it) linked to addresses by `postal_address_boundary` · `geographic_boundary_association` (a
  boundary within another, many-to-many) · `facility` (a physical place: warehouse, building,
  floor, room as `facility_type` rows, with square footage and one `part_of_facility_id` parent) ·
  `facility_role` (a party owns, rents, uses or manages it) and `facility_contact_mechanism` (its
  own address, phone…), both dated by us.
- **W:** `city`, `state`, `zip`, `country` columns on the address: no place for a sales
  territory, no "everything inside the Midwest" query, and a second country list for
  citizenship. And a warehouse modelled as its address: a campus has several buildings at one
  address, a warehouse can have a mailing and a dock address, a room has a phone and no address,
  and there's nowhere to put square footage or who leases it.
- **T:** facilities nest by **containment** (room in floor in building), not by size; a
  warehouse's two addresses is a facility ↔ mechanism question, not a legal boundary (your
  first answers to item 49). Don't swap the two nestings: boundaries are many-to-many (a postal
  code crosses city lines), facilities have one parent. Geography is still unpractised; expect
  this card to be shaky.
- **D:** contact_mechanism ← postal_address (shared key); postal_address ←
  postal_address_boundary → geographic_boundary → type; geographic_boundary_association →
  geographic_boundary twice (from within, to in); facility → facility (part of), → type; party ←
  facility_role → facility, → role type; facility ← facility_contact_mechanism →
  contact_mechanism. Ch 3 reuses both: reorder guidelines per facility or boundary, inventory in
  a facility.
</details>

### Card 4 · V1 Ch 2 · Communication events and case (Figs 2.7, 2.12–2.13)
- **Cue:** "Who talked to whom, how, about what, and what happened next?"
- **Hook:** the meeting minutes *(Claude's, at the user's request)*
- **Mantra:** An event happens via a medium, with many parties in roles, for purposes; a case groups past
  events, a work effort is the work they trigger.

<details><summary>Key</summary>

- **S:** `communication_event` (one contact, occurs via a medium, has a status, optionally in
  the context of a party relationship) · `communication_event_role` (any number of parties take
  part, each in a role: caller, receiver, attendee…) · `communication_event_purpose` (what it was
  about) · `communication_case` (looking back: groups the events about one issue) ·
  `work_effort` via `communication_event_work_effort` (looking forward: the work an event
  triggers, many-to-many).
- **W:** an event tied to exactly one relationship (Fig 2.7) can't hold a three-way meeting or a
  call with someone we have no relationship with yet. A case alone can't say what work came
  out of a call.
- **T:** case vs work effort: the case **groups past events**; the work effort is **future work
  they cause** (your open gap). Also `valid_contact_mechanism_role`: a rule stored as rows.
- **D:** communication_event ← event_role → party; event → case; event ← event_work_effort →
  work_effort; event → party_relationship (optional).
</details>

### Card 5 · V1 Ch 3 · Product definition, categories, identification (Figs 3.1–3.3)
- **Cue:** "What do we sell, how do we group it, and what codes is it known by?"
- **Hook:** one product, many shelves, many barcodes *(Claude's, at the user's request)*
- **Mantra:** A product sits on many dated shelves, one primary; shelves stack on shelves;
  party types browse shelves; codes are rows, not columns.

<details><summary>Key</summary>

- **S:** `product` (what we offer, good or service via `product_kind`; not who supplies it, not
  stock) · `product_category` with `product_category_rollup` (many parents allowed) ·
  `product_category_classification` (product in a category, dated, one flagged primary) ·
  `market_interest` (which party types care about which categories) · `good_identification`
  (SKU, UPC, ISBN… as type + value rows).
- **W:** a single `category_id` column on the product (one category, no history, no second
  hierarchy) and a column per code (`sku`, `upc`, `isbn`: empty for most products, a schema
  change for every new code).
- **T:** the primary flag is a rule a plain FK can't hold (data-quality query). Rollup,
  good/service and identification are still unpractised; expect this card to be shaky.
- **D:** product ← classification → category; category ← rollup → category (parent, child);
  category ← market_interest → party_type; good (= product) ← good_identification →
  identification_type.
</details>

### Card 6 · V1 Ch 3 · Product features (Fig 3.4)
- **Cue:** "What options does a product come in, which are standard, and which clash?"
- **Hook:** build-your-own bike *(Claude's, at the user's request)*
- **Mantra:** Features attach to products as required, standard, optional or selectable; features constrain
  features, needing or clashing, sometimes only inside one product.

<details><summary>Key</summary>

- **S:** `product_feature` (a colour, size, quality, dimension…; dimensions carry a unit of
  measure) · `product_feature_applicability` (this feature on this product is required,
  standard, optional or selectable) · `product_feature_interaction` (feature A needs feature B,
  or A and B can't go together, optionally only within one product) · `unit_of_measure` with
  conversions.
- **W:** a column per option on the product, or a separate product row for every combination
  (red-small, red-large, blue-small…): an explosion of near-duplicates and no rules between
  them.
- **T:** applicability is feature ↔ **product**; interaction is feature ↔ **feature** (you mixed
  them up once). Null product on an interaction = it holds everywhere.
- **D:** product ← applicability → feature; feature ← interaction → feature (twice) and →
  product (optional); feature → uom.
</details>

### Card 7 · V1 Ch 3 · Suppliers and inventory (Figs 3.5–3.6)
- **Cue:** "Who can supply it, when do we reorder, and where is the physical stock?"
- **Hook:** the warehouse floor *(Claude's, at the user's request)*
- **Mantra:** Suppliers offer products, dated; guidelines say when to reorder a good, and where; items are the
  physical stock in one place; variances explain the count.

<details><summary>Key</summary>

- **S:** `supplier_product` (this organization can supply this product, dated, with lead time,
  preference, rating) · `reorder_guideline` (for a good: reorder level and quantity, optionally
  per facility, geographic boundary and/or internal organization; none = everywhere) ·
  `inventory_item` (physical stock of a good: serialized or not, in a facility **or** a
  container, in a status, optionally from a lot) · `inventory_item_variance` (a count found a
  difference, with a reason).
- **W:** a `supplier_id` and a `stock` column on the product: one supplier, one number for all
  warehouses, no lot to recall, no story of where the missing reams went.
- **T:** good = catalogue description, inventory item = the physical thing. The variance
  *explains* a change to quantity_on_hand; it doesn't replace it (the book's convention, and
  the qoh = balance check). Overlapping reorder scopes need a written convention.
- **D:** product ← supplier_product → organization; good ← reorder_guideline → facility /
  boundary / organization; good ← inventory_item → facility | container, → lot, → status;
  inventory_item ← variance → reason.
</details>

---

## Deck: patterns

The cross-chapter patterns, one line each. The full list lives in the design reference doc's
Core patterns table; add a card here when a pattern gets its first row there. Same drill,
shorter: say the pattern, then give **two examples from different chapters** and **when not
to use it**.

- **P1 · Roles, not subtypes.** Cue: "The same thing plays several parts over time."
- **P2 · Attribute-less subtypes become type rows.** Cue: "A subtype with nothing of its own."
- **P3 · The link owns the fact.** Cue: "A fact that's true of the pair, not of either side."
- **P4 · Effectivity dates.** Cue: "It was true then, it isn't now."
- **P5 · Self-referencing link (from / to, rollup).** Cue: "A thing related to another of its own kind."
- **P6 · Rules as rows.** Cue: "Which combinations are allowed, without a code change."
- **P7 · Exclusive arc.** Cue: "Here or there, never both, never neither."

---

## Log

| Date | Card | Grade | Box | Note |
|---|---|---|---|---|
| | | | | |
