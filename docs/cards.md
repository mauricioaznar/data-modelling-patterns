# Cards: mantras that explode

A solo routine for every morning, separate from the deep-dive sessions. The deep dives build
understanding; this keeps it from fading. No Claude needed, about 30 minutes, pen and paper.

**Anki:** `npm run cards:anki` writes `docs/cards-anki.txt`; import it with File → Import.
This file stays the source of truth: edit here, rerun, re-import. Each note's id comes from
the volume, chapter and figures in its heading (an architecture card's from its volume and
chapter, a pattern's from its number), so renumbering or rewording a card updates its note;
keep those stable. Anki's scheduling replaces the boxes below; still write S · W · T · D on
paper before you flip.

**Decks and status** (the user's call, 2026-10-18). Submodel and architecture cards each
split into *Drafts* and *Settled*; patterns stay in *Data Models::Patterns*:

| Status (tag) | Comes from the chapter's STATUS.md | Deck |
|---|---|---|
| `dm::status::draft` | Overview not ticked yet | *Data Models::Submodels::Drafts* or *::Architecture::Drafts* |
| `dm::status::reviewed` | Overview ticked (or `–`: built before overviews existed) | *…::Settled* |
| `dm::status::done` | Doc done ticked (practice closed); not for architecture cards | *…::Settled* |

- **Drafts are for looking up, not studying.** Give both Drafts subdecks an options preset
  with *New cards/day* 0 and *Maximum reviews/day* 0: you can browse them, but studying
  *Data Models* never serves them.
- **A re-import updates a note's text and tags but never moves its card**: Anki's deck
  column only places new cards. So when an overview settles a chapter, move its cards by
  hand, once per kind: Browse, search `"deck:Data Models::Submodels::Drafts" tag:v1::ch03`
  (with the chapter's tag), select all, Change Deck to *Data Models::Submodels::Settled*;
  then the same with *Architecture*.

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

Three minutes a card. If it takes ten, it's not a card any more: stop and flag it for a
deep-dive session.

## Rules for a good mantra

- **Claude drafts it, you own it.** Claude writes each card when its figures land (the user's
  call, 2026-10-16). Generating a mantra is half the encoding, so rewriting one in your own
  words is worth more than re-reading it; Claude checks a rewrite still explodes (does every
  spine entity fall out of it?) and isn't wrong.
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
| 0–5 | **Map** | On a blank page, draw the chain of every submodel so far as boxes (Party → Contact → Places → Comms → Product → Features → Inventory…) and write each one's hook. No peeking; then check it against each chapter's "How it flows" (its architecture figure). |
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

New cards start in box 1. Claude drafts a card when its figures are built, but it enters the
deck **at its chapter's overview**, once your feedback has confirmed it (the user's call,
2026-10-18): before that, it's Claude's reading, there to look up but not to drill. Overviews
should follow a chapter's last figure within days, so nothing waits weeks to be revised. Its
Trap starts as the naive-model mistake and becomes one of yours when practice ends.

---

## Deck: submodels

Cue · hook · mantra · the key (click to open, **after** you've recalled). Claude drafts the
hook and mantra when the figures land: rewrite any that don't explode, in your own words.

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

### Card 8 · V1 Ch 3 · Pricing and costing (Figs 3.7–3.8)
- **Cue:** "What do we charge, under which conditions, and what does it cost us?"
- **Hook:** the price is a recipe *(Claude's, drafted when the figures landed)*
- **Mantra:** Price components are conditional rules; matching ones add up to the price; cost
  estimates hit a product or feature, never both.

<details><summary>Key</summary>

- **S:** `price_component` (one pricing rule: base price, discount, surcharge or suggested
  price; for a product and/or a feature; optional "based on" conditions: region, party type,
  category, quantity break, order value, sale type, organization; optionally a one-time,
  recurring or usage charge) · `quantity_break` and `order_value` (ranges, exclusive thru) ·
  `estimated_product_cost` (a dated estimate per cost component type, for a product **or** a
  feature) · `cost_component_type` (a hierarchy under materials, labour, other) · currency
  and time-frequency units of measure.
- **W:** a `price` column on the product: one number, so no discounts, regions, quantity breaks
  or history. One `cost` number gives no margin by materials or labour.
- **T:** *(the naive-model trap until practice gives yours)* looking up "the price" of a
  product: there isn't one. A price is computed per order line from every component whose
  conditions all hold.
- **D:** product and/or feature ← price_component → region / party type / category / quantity
  break / order value / sale type / organization (all optional), → currency; product | feature
  ← estimated_product_cost → cost_component_type.
</details>

### Card 9 · V1 Ch 3 · Product associations and parts (Figs 3.9–3.10)
- **Cue:** "Which products go with, replace, clash with or are built from which others?"
- **Hook:** the product family tree *(Claude's, drafted when the figures landed)*
- **Mantra:** One dated, typed link joins product to product: component (a package or an
  assembly), substitute, successor, complement or clash; components explode level by level.

<details><summary>Key</summary>

- **S:** `product_association` (from product → to product, dated, with a reason; what "from"
  and "to" mean depends on the type) · `product_association_type` (component, substitute,
  obsolescence, complement, incompatibility; component is 3.9b's marketing package and
  3.10a's product component, one link for a kit and a BOM alike) · `quantity_used` and
  `instruction` for components, `quantity` for substitutes · `good.good_kind` (raw material,
  subassembly, finished good).
- **W:** columns like `replaced_by_product_id` and `substitute_product_id`: one of each, no
  dates, no reason, and a new column for every new kind of link.
- **T:** *(the naive-model trap until practice gives yours)* forgetting direction. Substitution
  needs a row each way; incompatibility is read both ways; a BOM explosion multiplies
  quantities down the levels and needs a cycle guard.
- **D:** product ← association (from), association (to) → product; association → type; good
  (= product) carries good_kind. Not built: 3.10b's PART, the physical side of a product,
  which would take the assemblies and leave the component link only the packages.
</details>

### Card 10 · V1 Ch 4 · Orders, items and order parties (Figs 4.1–4.5)
- **Cue:** "What was ordered, which way, at what price, and who placed, took, pays and receives it?"
- **Hook:** one order pad, two desks *(Claude's, drafted when the figures landed)*
- **Mantra:** One order for buying and selling; items name a product or feature; roles name
  placer, taker, bill-to, ship-to, and anyone else.

<details><summary>Key</summary>

- **S:** `"order"` (the header: order date, entry date; `order_kind` SALES or PURCHASE) ·
  `order_item` (one line, numbered within its order: quantity and the unit price agreed that
  day; for a product **or** a feature, the feature's line "ordered for" the product's line) ·
  `sales_order` (placed by, taken by, bill-to: party roles; placed using, taken via, billed
  to: contact mechanisms) and `sales_order_item` (the customer's PO number, the ship-to role
  and address) · `purchase_order` and `purchase_order_item`, the mirror (placing buyer,
  supplier, bill-to purchaser, ship-to buyer) · `order_role` + `order_role_type` (anyone else
  on the order: a salesperson with a percent share, an approver) · the generic alternate
  (4.5): `order_item_role`, `order_contact_mechanism`, `order_item_contact_mechanism` (a party
  or a mechanism plus a type or purpose, on the order or one line).
- **W:** Fig 4.1's twin models: sales order + customer and purchase order + supplier, copies of
  each other. Every rule and report written twice, a party that buys and sells is two unrelated
  rows, one party per order, and no place for a feature or a ship-to per line. (4.4's mirrored
  party columns bring a little of it back; 4.5 is the way out.)
- **T:** *(the naive-model trap until practice gives yours)* pricing an old order from today's
  price list: the item keeps the price agreed that day, because price components change. And
  pointing an order at a PARTY: it loses which hat the party wore (placer or bill-to).
- **D:** order ← item (part of) → product | feature; item → item (ordered for); sales_order
  and purchase_order (= order) → party_role ×3 and → contact_mechanism ×3; sales_order_item
  and purchase_order_item (= item) → party_role (ship-to), → contact_mechanism (ship-to);
  order ← order_role → party, → order_role_type. 4.5: item ← order_item_role → party, →
  order_item_role_type; order ← order_contact_mechanism and item ← order_item_contact_mechanism
  → contact_mechanism, → contact_mechanism_purpose_type (Ch 2). Not built: 4.1's twin model.
</details>

---

### Card 11 · V1 Ch 4 · Order adjustments (Fig 4.6)
- **Cue:** "What changes an order's price besides quantity × unit price, and which tax rate applies where?"
- **Hook:** a receipt covered in stickers *(Claude's, drafted when the figures landed)*
- **Mantra:** Every price change is a typed row, on the order or one line; tax rate copied
  from place and category.

<details><summary>Key</summary>

- **S:** `order_adjustment` (an amount **or** a percentage, stored positive; for the whole
  order **or** one item) · `order_adjustment_type` (the book's six subtypes on top: discount,
  surcharge, sales tax, shipping and handling, fee, miscellaneous; finer types under them) ·
  `sales_tax_lookup` (a rate per geographic boundary, optionally per product category).
- **W:** a column per charge on the order (`discount`, `tax`, `freight`): every new kind of
  charge is a schema change, two discounts don't fit, and a discount on one line has nowhere
  to go.
- **T:** *(the naive-model trap until practice gives yours)* pointing the tax adjustment at
  the lookup row instead of copying its rate: a rate change rewrites old orders. And
  forgetting the sign: a discount stored like a charge adds to the bill.
- **D:** order ← adjustment → item (one or the other); adjustment → adjustment_type (→ its
  parent type); sales_tax_lookup → geographic_boundary (Ch 2), → product_category (Ch 3). No
  line from the lookup to the adjustment: the rate is copied.
</details>

---

### Card 12 · V1 Ch 4 · Order status, terms and item associations (Figs 4.7–4.8)
- **Cue:** "Where does an order or a line stand, under which agreed terms, and which purchase will fill a sales line?"
- **Hook:** a parcel tracker with fine print *(Claude's, drafted when the figures landed)*
- **Mantra:** Status rows stack in time, terms carry typed numbers, on order or line; purchase
  lines fill sales lines.

<details><summary>Key</summary>

- **S:** `order_status` (a status from Ch 2's shared `status_type`, ORDER_STATUS group, and a
  datetime; for the order **or** one line; the latest row is the current status) ·
  `order_term` + `term_type` (a condition agreed for the order **or** one line, with an
  optional number whose meaning, a percentage or days, comes from the type) ·
  `order_item_association` (a sales line filled by a purchase line, many to many; its FKs
  point at `sales_order_item` and `purchase_order_item`, so the direction is built in).
- **W:** one `status` column on the order forgets when each state was reached, and can't say
  the paper shipped while the copier waited. A column per condition (`cancel_fee`,
  `refund_days`) for every new term. And with no link from a sale to the purchase that fills
  it, nobody knows which customers wait on a late delivery.
- **T:** *(the naive-model trap until practice gives yours)* storing "backordered" or
  "shipped" and trusting it: those follow from the association, shipments and invoices, and a
  stored copy can contradict them. And reading a term's value without its type: 10 of what?
- **D:** order ← status → item (one or the other); status → status_type (Ch 2, ORDER_STATUS
  group); order ← term → item (one or the other); term → term_type; sales_order_item ←
  association → purchase_order_item. No quantity on the association.
</details>

---

### Card 13 · V1 Ch 4 · Requirements (Fig 4.9)
- **Cue:** "What is needed, by whom, by when, and which order lines commit to filling it?"
- **Hook:** a shopping list in pencil *(Claude's, drafted when the figures landed)*
- **Mantra:** A need, split by whose and what, wants features, not products; order lines
  commit to it in quantities.

<details><summary>Key</summary>

- **S:** `requirement` (the need: description, required-by date, budget, quantity, reason;
  `requirement_origin` CUSTOMER or INTERNAL and `requirement_kind` PRODUCT or WORK, two
  independent sets; part of another requirement; needed at a facility) ·
  `product_requirement` (an optional product) + `desired_feature` (a Ch 3 feature, must-have
  or optional) · `order_requirement_commitment` (an order line committed to a need, with a
  quantity) · `requirement_role` + type (owner, requester, approver; dated) ·
  `requirement_status` (REQUIREMENT_STATUS group in Ch 2's `status_type`, dated).
- **W:** jumping straight to a draft order loses the need itself (by when, for how much,
  why, who asked). One need often takes several orders, and a need is described before any
  product is chosen.
- **T:** *(the naive-model trap until practice gives yours)* naming a product on the need too
  early: "50 reams, 8½ by 11, fine grade" is the need, choosing Johnson's is buying. And one
  four-way subtype list (customer, internal, product, work), which can't hold a customer's
  work requirement.
- **D:** requirement → requirement (part of); requirement → facility (Ch 2);
  product_requirement (= requirement) → product (Ch 3, optional); product_requirement ←
  desired_feature → product_feature (Ch 3); requirement ← commitment → order_item;
  requirement ← role → party, → role type; requirement ← status → status_type (Ch 2).
</details>

---

### Card 14 · V1 Ch 4 · Requests and quotes (Figs 4.10–4.11)
- **Cue:** "Whom did we ask for information, proposals or prices, what did they quote, and which quote became an order?"
- **Hook:** sealed bids on the table *(Claude's, drafted when the figures landed)*
- **Mantra:** Request items carry needs, no product; quote items price product or work,
  answer them; order lines accept.

<details><summary>Key</summary>

- **S:** `request` + `request_type` (RFI, RFP, RFQ; request date, answer-by date) ·
  `request_item` (required-by date, quantity, maximum amount; no product) ·
  `requirement_request` (which needs an item carries, many to many) · `responding_party`
  (to whom, through which contact mechanism, when) · `request_role` · `quote` + `quote_type`
  (issued by, given to, valid from and thru) · `quote_item` (prices a product **or** a work
  effort; may answer a request item; accepted through `order_item.quote_item_id`) ·
  `quote_term` (on 4.7's `term_type`) · `quote_role`.
- **W:** requests and quotes kept as e-mails, or as draft orders marked "quoted": no link from
  the question to the needs behind it, no room for competing offers, and an offer mixed up
  with a commitment.
- **T:** *(the naive-model trap until practice gives yours)* reaching the quoted product
  through request item → requirement → product: the supplier may quote something else
  (Table 4.15's black pens for a blue need, recycled paper). And accepting a quote after it
  expired.
- **D:** request ← request_item ← requirement_request → requirement; request ←
  responding_party → party, → contact_mechanism; request ← request_role → party; quote →
  party ×2 (issued by, given to); quote ← quote_item → product | work_effort (arc);
  quote_item → request_item (a response to); order_item → quote_item (the acceptance of);
  quote ← quote_term → quote_item (arc), → term_type; quote ← quote_role → party. The chain:
  requirement → request item → quote item → order item → commitment back to the requirement.
</details>

---

### Card 15 · V1 Ch 4 · Agreements (Figs 4.12–4.13)
- **Cue:** "Which standing agreements do we have, with whom, and which of their clauses apply to this order line?"
- **Hook:** a signed binder, its clauses tabbed by customer, product and region, addenda
  stapled at the back *(Claude's, drafted when the figures landed)*
- **Mantra:** Agreements name parties by role, maybe a relationship; items nest, apply by
  organization, product, place; addenda amend, never overwrite.

<details><summary>Key</summary>

- **S:** `agreement` + `agreement_type` (a hierarchy: PRODUCT over SALES and PURCHASE,
  EMPLOYMENT, OTHER over partnership; signed on a date, in force from and thru) ·
  `agreement.party_relationship_id` (optional: the relationship it formalizes) ·
  `agreement_role` + `agreement_role_type` (any number of parties in typed roles) ·
  `agreement_item` + `agreement_item_type` (section, pricing program, exhibit,
  sub-agreement; numbered; part of another item) · `agreement_organization_applicability`,
  `agreement_product_applicability`, `agreement_geographical_applicability` (what a clause
  is limited to; none of a kind = no limit) · `addendum` (on the agreement **or** one item;
  created and effective dates).
- **W:** contracts as files in a folder, or contract columns on the customer: one contract
  per customer, two parties at most, no clause-level scope, and changes typed over what was
  signed.
- **T:** *(the naive-model trap until practice gives yours)* keeping only the party
  relationship: Table 4.16's three partners fit no single relationship. And editing a
  clause's text in place instead of adding an addendum.
- **D:** agreement → agreement_type (→ parent type); agreement → party_relationship
  (optional, Ch 2) → party_role ×2 → party; agreement ← agreement_role → party, →
  agreement_role_type; agreement ← agreement_item → agreement_item_type, → agreement_item
  (part of, same agreement); agreement_item ← organization | product | geographical
  applicability → organization | product | geographic_boundary; addendum → agreement |
  agreement_item (arc). The rule: the relationship's two ends play roles in the agreement.
</details>

---

### Card 16 · V1 Ch 4 · Agreement terms and pricing (Figs 4.14–4.16)
- **Cue:** "Under which terms and at which prices did we agree, and which of them govern this order line?"
- **Hook:** the contract's price sheet held up against each order line, and a tally counter
  clicking toward the cap *(Claude's, drafted when the figures landed)*
- **Mantra:** Terms on agreement or item, dated inside it; agreed prices are program price
  components; orders find agreements by rule.

<details><summary>Key</summary>

- **S:** `agreement_term` (on the agreement **or** one item; a value, from and thru dates
  inside the agreement's) · `term_type` (a hierarchy: LEGAL, FINANCIAL, INCENTIVE, THRESHOLD,
  OTHER at the top; shared with order and quote terms) · `agreement_pricing_program` (a
  subtype table of `agreement_item`) · `price_component.agreement_item_id` (null = a list
  price) · the view `order_item_agreement_item` (which items govern a sales line).
- **W:** conditions buried in the contract's text, or a column per kind (`max_quantity`,
  `exclusive_flag`); agreed prices in a `contract_price` table that repeats every pricing
  condition; an `agreement_id` typed on the order.
- **T:** *(the naive-model trap until practice gives yours)* storing `agreement_id` on the
  order: several items govern one line at once (a price program here, an exclusivity there),
  and a typed key goes stale or is keyed wrong. And recording a cap that no query adds up.
- **D:** agreement_term → term_type (→ its kind), → agreement | agreement_item (arc);
  agreement_item ← agreement_pricing_program ← price_component (Ch 3's conditions: region,
  quantity break), its product inside the program's applicability; order_item ⇢
  agreement_item, derived: the agreement in force on the order date, the customer in an
  agreement_role, the item's applicability matching (organization, product, ship-to
  boundary). Checks: dates inside the agreement's; the charged price against the agreement
  price; a running total past a threshold.
</details>

---

### Card 17 · V1 Ch 5 · Shipments, items and status (Figs 5.1–5.2)
- **Cue:** "What is being shipped, from whom and where to whom and where, which way does it go, and did it leave and arrive as planned?"
- **Hook:** a delivery van with the planned times written on its side in marker, and a log
  beside it stamped with the real ones *(Claude's, drafted when the figures landed)*
- **Mantra:** Shipments run party to party, address to address; the type is the direction;
  plans on the header, facts in the history.

<details><summary>Key</summary>

- **S:** `shipment` (estimated ready, ship and arrival dates, latest cancel date, estimated
  and actual cost; shipped from and to a `party` and a `postal_address`; an inquiry
  `contact_mechanism`; a receiving `telecommunications_number`) · `shipment_type` (a
  hierarchy: OUTGOING over CUSTOMER_SHIPMENT and PURCHASE_RETURN, INCOMING over
  PURCHASE_SHIPMENT and CUSTOMER_RETURN, TRANSFER, DROP_SHIPMENT; `from_internal` and
  `to_internal` flags, ours) · the view `shipment_end` (whose ends are ours, from
  INTERNAL_ORGANIZATION roles) · `shipment_item` (a `good` or a contents description, a
  quantity, numbered within its shipment, maybe in response to another line) ·
  `shipment_status` (SHIPMENT_STATUS group in Ch 2's `status_type`, a datetime; one row per
  type).
- **W:** a ship date, a carrier and a "quantity shipped" on the order: no room for a line in
  two trucks or a truck for two orders, for returns and transfers with no order, or for a
  drop ship we never touch. And the real ship date typed over the estimate: "was it late?"
  is gone.
- **T:** *(the naive-model trap until practice gives yours)* pointing the shipment line at
  the order line: a line of pens filling two orders, or a return with no order, has nowhere
  to go. And trusting the type alone for the direction, when the parties at each end say
  otherwise.
- **D:** shipment → shipment_type (→ its group); shipment → party ×2 (sender, receiver;
  Ch 2), → postal_address ×2 (source, destination), → contact_mechanism (inquiry), →
  telecommunications_number (receiving); shipment ← shipment_item → good (Ch 3), →
  shipment_item (in response to); shipment ← shipment_status → status_type (Ch 2,
  SHIPMENT_STATUS group). Rules: the type's flags match the parties' INTERNAL_ORGANIZATION
  roles; each address is one its party has on file.
</details>

---

### Card 18 · V1 Ch 5 · Shipments and orders (Fig 5.3)
- **Cue:** "Which order lines does a shipment line fill, how much of each, and did what went out match what was ordered?"
- **Hook:** a packing slip stapled to two orders, "700" and "300" pencilled beside its one
  line of pens, and "black, not blue" circled *(Claude's, drafted when the figures landed)*
- **Mantra:** Order lines and shipment lines meet in pairs with quantities; full is a sum;
  shipped features beside ordered ones.

<details><summary>Key</summary>

- **S:** `order_shipment` (an `order_item` from Ch 4 and a `shipment_item`, with the
  quantity shipped; the pair identifies it) · `shipment_item_feature` (a Ch 3
  `product_feature` the shipment line went out with) · what was ordered: Ch 4's feature
  lines under the order line.
- **W:** a `shipment_id` on the order, or an `order_item_id` on the shipment line. The first
  can't say which line or how much; the second can't let one truck line fill two orders.
  And "shipped" typed in as a status.
- **T:** *(the naive-model trap until practice gives yours)* linking ORDER to SHIPMENT: which
  line, and how much of it, is lost. And storing "shipped in full" instead of adding up the
  quantities.
- **D:** order_item (Ch 4) ← order_shipment → shipment_item (a quantity); shipment_item ←
  shipment_item_feature → product_feature (Ch 3); the order line's own features: its
  feature lines (ordered for). Checks: the same good; the line's ship-to is the shipment's
  destination; no shipment line drawn on beyond its quantity; sales lines on customer
  shipments, purchase lines on purchase shipments, either on a drop ship. Derived: the
  orders on a shipment; shipped in full = the sum against the line's quantity.
</details>

---

### Card 19 · V1 Ch 5 · Packages and receipts (Fig 5.4)
- **Cue:** "Which packages hold which lines, how much of an incoming package was accepted or rejected and why, where did it go, and which order line does it settle?"
- **Hook:** a clerk on the receiving dock with a box cutter and a clipboard, ticking
  "accepted" and "rejected" carton by carton *(Claude's, drafted when the figures landed)*
- **Mantra:** Lines ride in packages; receipts count one good per package, accept or reject,
  stock it, settle an order line.

<details><summary>Key</summary>

- **S:** `shipment_package` (the date it was made up; no FK to `shipment`) ·
  `packaging_content` (a shipment line in a package, with the quantity packed) ·
  `shipment_receipt` (within a package; of a `good`, stored into an `inventory_item`,
  applied to an `order_item`, all three optional; time, what the receiver wrote, quantity
  accepted, quantity rejected, a `rejection_reason`) · `shipment_receipt_role` + type
  (receiver, inspector) · the view `shipment_package_shipment` (a package's shipment, from
  its contents).
- **W:** a "received" tick or a received quantity on the order line or the shipment line:
  nothing says which box, how much was rejected and why, who signed, or where it was put
  away, and each partial delivery overwrites the last.
- **T:** *(the naive-model trap until practice gives yours)* counting receipts per shipment
  line and forgetting the package: 1149's three lines share one box, 1146's pencils fill two.
  And trusting the receipt's own order line without checking it against ORDER SHIPMENT.
- **D:** shipment_item ← packaging_content → shipment_package ← shipment_receipt → good
  (Ch 3), → inventory_item (Ch 3), → order_item (Ch 4), → rejection_reason;
  shipment_receipt ← shipment_receipt_role → party (Ch 2), → role type. Derived: a package's
  shipment, through its contents. Checks: one shipment per package; no more packed than the
  line carries; the receipt's good in its package; no more counted than it holds; a
  rejection needs a reason; the receipt's order line tied to its shipment line by ORDER
  SHIPMENT; receipts only on shipments that end at one of ours.
</details>

---

### Card 20 · V1 Ch 5 · Issuances and picklists (Fig 5.5)
- **Cue:** "Which stock was pulled for each outgoing line, by whom and from which picklist, and does each quantity on hand still match its movements?"
- **Hook:** a picker with a pick sheet, pulling 800 pens off the floor and 200 from bin P-2,
  while a ledger on the wall must still balance *(Claude's, drafted when the figures landed)*
- **Mantra:** Picklist plans; each issuance pulls from one stock for a line; on hand equals
  received minus issued plus counted.

<details><summary>Key</summary>

- **S:** `item_issuance` (from an `inventory_item`; for a `shipment_item` and by a
  `picklist_item`, both optional; issued datetime, quantity) · `picklist` (date created) +
  `picklist_item` (an inventory item and a quantity to pick) · `item_issuance_role` + type
  (issuer, approver).
- **W:** a "quantity shipped" on the shipment line and a quantity on hand typed over by
  hand: nothing says which stock was drained, who pulled it or whether the pick was
  followed, and the stored total drifts from what really came and went without anyone
  noticing.
- **T:** *(the naive-model trap until practice gives yours)* tying an issuance to its box
  (the figure's stray label) or a picklist to one shipment; and checking the quantity on
  hand from zero when the stock predates the system, with no opening count.
- **D:** inventory_item (Ch 3) ← item_issuance → shipment_item (optional), → picklist_item
  (optional) → picklist; picklist_item → inventory_item; item_issuance ←
  item_issuance_role → party (Ch 2), → role type. Derived: a picklist's shipments, through
  its issuances. Checks: the issued good is the line's; no more issued than the line
  carries; the issuance's stock is its picklist item's; issuances only on shipments that
  leave one of ours, from stock at the ship-from address; qoh = receipts − issues +
  variances.
</details>

---

### Card 21 · V1 Ch 5 · Shipping documents and route segments (Figs 5.6–5.7)
- **Cue:** "Which papers go with a shipment, a line or a box, and which legs, carriers and vehicles does it travel by, planned against actual?"
- **Hook:** a relay race: at the hand-over depot one driver passes a clipboard of papers
  (bill of lading, packing slips) to the next truck *(Claude's, drafted when the figures
  landed)*
- **Mantra:** Papers name their level: shipment, line or box. Legs chain facility to
  facility: carrier, method, vehicle, plan beside actual.

<details><summary>Key</summary>

- **S:** `document` + `document_type` (SHIPPING_DOCUMENT over eight kinds as rows) ·
  `shipping_document` (for a `shipment`, a `shipment_item` or a `shipment_package`, all
  optional) · `shipment_route_segment` (a leg numbered within its shipment; method, carrier
  role, vehicle, from and to facility; estimated and actual start and arrival; mileage,
  fuel) · `shipment_method_type` · `carrier_shipment_method` (what each carrier offers) ·
  `fixed_asset` + type (VEHICLE, ahead of Ch 8).
- **W:** a bill-of-lading number, a carrier and a tracking number as columns on SHIPMENT:
  one kind of paper at one level, one carrier for the whole trip, and no way to tell which
  truck or leg ran late.
- **T:** *(the naive-model trap until practice gives yours)* putting facilities on the
  shipment instead of its legs; summing fuel per truck when one run carries two shipments
  (Truck #1 with 9000 and 9002).
- **D:** document → document_type; shipping_document (is a document) → shipment |
  shipment_item | shipment_package (no arc); shipment ← shipment_route_segment →
  shipment_method_type, → party_role (Ch 2, CARRIER), → fixed_asset (Ch 8, VEHICLE), →
  facility (Ch 2) twice; carrier_shipment_method → party_role, → shipment_method_type.
  Checks: a document covers something; its type agrees with its subtype row; its levels
  agree; the carrier offers the leg's method; the asset is a vehicle; times and mileage run
  forward; legs chain; no duplicates.
</details>

---

### Card 22 · V1 Ch 6 · Work requirements and roles (Figs 6.1–6.2)
- **Cue:** "What work is needed, of which type, to make which product, fix which machine or hand over which deliverable; and who asked, for whom, who answers for it and when?"
- **Hook:** a workshop job board: each card says "make 2,000 pens", "fix engraving machine
  #12" or "write the 2002 plan", with a row of dated name tags pinned beneath it
  *(Claude's, drafted when the figures landed)*
- **Mantra:** The need for work is typed; the type picks its target: product, machine or
  deliverable. People pin on in dated roles.

<details><summary>Key</summary>

- **S:** `requirement_type` (a hierarchy: PRODUCT_REQUIREMENT and WORK_REQUIREMENT over
  PRODUCTION_RUN, INTERNAL_PROJECT, MAINTENANCE, REPAIR) on Ch 4's `requirement` ·
  `work_requirement` (a subtype table: an optional `product`, `fixed_asset` or
  `deliverable`) · `deliverable` + type · `fixed_asset` gains acquired, last and next
  service, capacity · Ch 4's `requirement_role` gains a comment, with CREATED_FOR,
  CREATED_BY, RESPONSIBLE_FOR and AUTHORIZED_BY.
- **W:** a `job` table with `product_id`, `machine_id`, `report_name` and
  `responsible_party_id` columns: the need welded to the job that fills it, and only the
  latest person responsible kept.
- **T:** *(the naive-model trap until practice gives yours)* one fixed asset per need, so
  "Repair 14 PCs" can't name its machines (split it into children); a type that says WORK
  while the kind says PRODUCT.
- **D:** requirement → requirement_type (→ parent); work_requirement (is a requirement) →
  product (Ch 3) | fixed_asset (Ch 5) | deliverable → deliverable_type (all optional);
  requirement_role → requirement, → party (Ch 2), → requirement_role_type (Ch 4). Checks: a
  leaf type; type agrees with kind; work requirements typed and with their row; maintenance
  or repair names a machine; a production run names a product and a quantity; assets dated;
  a role row once; one responsible at a time.
</details>

---

### Card 23 · V1 Ch 6 · Work effort generation (Fig 6.3a)
- **Cue:** "What work is planned and done, at what level and for what purpose, where, which needs and order lines does it fill, and how many did a production run make and reject?"
- **Hook:** a factory foreman holding two clipboards, "needs" and "orders", with strings
  running from both to the same machines on the floor *(Claude's, drafted when the figures
  landed)*
- **Mantra:** Effort fills needs many to many, or order lines direct. Level and purpose are
  two lookups; only a production run counts.

<details><summary>Key</summary>

- **S:** Ch 2's `work_effort` gains actual start, completion and hours, special terms, a
  `facility` and a `work_effort_purpose_type` (PRODUCTION_RUN, MAINTENANCE, WORK_FLOW,
  RESEARCH) beside its `work_effort_type` (PROGRAM to ACTIVITY, with standard hours) ·
  `production_run` (to produce, produced, rejected) · `work_requirement_fulfillment` (effort
  ↔ work requirement, nothing on it) · `order_item_kind` (PRODUCT or WORK) ·
  `work_order_item_fulfillment` (effort ↔ WORK order line) · Ch 4's
  `order_requirement_commitment`, the other path.
- **W:** a job with one `requirement_id` and one `order_item_id`: 28045 fills two needs, and
  ACME's line takes two runs.
- **T:** *(the naive-model trap until practice gives yours)* looking for the product on the
  production run (it comes through the need or the line); summing a shared run against each
  need it fills.
- **D:** work_effort → work_effort_type (Ch 2), → work_effort_purpose_type (optional), →
  facility (Ch 2, optional); production_run (is a work_effort); work_requirement_fulfillment
  → work_effort, → work_requirement; work_order_item_fulfillment → work_effort, →
  order_item (Ch 4, WORK); order_requirement_commitment (Ch 4) → order_item, → requirement.
  6.3b drops the direct path. Checks: production_run row matches the purpose; direct links
  only to WORK lines; no link twice.
</details>

---

## Deck: architecture

One card per chapter, from its architecture figure (the last, overall one): how the chapter's
submodels hang together. The Map warm-up chains the chapters; these test the inside of one.
Same drill, with the letters read as: **S** the hub entities · **W** how each submodel hands
over to the next · **T** the naive mistake · **D** the submodels as boxes, with the lines in
from earlier chapters marked. Five minutes, not three: a chapter is bigger than a submodel.

### Architecture · V1 Ch 2 · People and organizations (Fig 2.14)
- **Cue:** "Everything we know about whoever we deal with, in one picture."
- **Hook:** the bicycle wheel *(Claude's, at the user's request)*
- **Mantra:** One hub, the party: reached through mechanisms, found at facilities, heard in
  events that cases gather; it wears roles, and a relationship pairs two roles, never two
  parties.

<details><summary>Key</summary>

- **S:** `party` (the one hub: a person or an organization) · `party_role` (what it is to us:
  customer, supplier, employee; typed, dated) · `party_relationship` (joins two roles, from
  and to, dated) · `party_contact_mechanism` (a party's dated use of a shared address, phone
  or e-mail, with purposes) · `facility` (a physical place, nested; parties tie in through
  `facility_role`) · `communication_event` (what was said, with roles and purposes), gathered
  into a `communication_case`.
- **W:** every submodel answers one question about the same party. Who are they to us: a
  role. How are they related: a relationship between two roles. How do we reach them: a
  contact mechanism, through the dated link (facilities get mechanisms the same way). What did
  we say: an event, optionally within a relationship, gathered into a case and followed up
  with a work effort (Ch 6).
- **T:** *(the naive-model trap until practice gives yours)* a table per kind of party
  (customer, supplier, employee), each with its own address columns: a company that is both a
  customer and a supplier becomes two rows that drift apart.
- **D:** party → party_role ← party_relationship (from, to); party ← party_contact_mechanism →
  contact_mechanism (postal address ← postal_address_boundary → geographic_boundary); party ←
  facility_role → facility (part of) ← facility_contact_mechanism → contact_mechanism;
  communication_event → party_relationship and communication_case (both optional), ←
  communication_event_role → party. First chapter, so nothing comes in; Ch 3 borrows
  organization, party_type, facility and geographic_boundary.
</details>

### Architecture · V1 Ch 3 · Products (Fig 3.11)
- **Cue:** "Everything about what we sell, from the catalogue to the shelf to the price tag."
- **Hook:** the catalogue and the warehouse *(Claude's, at the user's request)*
- **Mantra:** Categories and features describe a product, suppliers offer it, associations
  link it to other products; a good is stocked as items at a facility; a price is built from
  components, never stored.

<details><summary>Key</summary>

- **S:** `product` (the catalogue entry: what we sell) · `good` (the tangible kind of product,
  split by `good_kind` into raw material, subassembly, finished good) · `inventory_item` (the
  physical stock of a good) · `product_category` and `product_feature` (describe the product)
  · `price_component` and `estimated_product_cost` (build its numbers).
- **W:** define → describe → source → stock → price → relate. A product sits in categories
  (rollup, classification) that party types show market interest in; features attach through
  applicability, and interaction says which go together or clash. Supplier product says which
  organization sells it to us. Only goods get identification codes, reorder guidelines and
  inventory items. Price components (for a product and/or a feature) and estimated costs (a
  product or a feature, never both) build the numbers. Product association links product to
  product, the bill of materials included.
- **T:** *(the naive-model trap until practice gives yours)* one product table with price,
  cost, quantity on hand and supplier columns: one price, one supplier, no history, and no
  way to tell the catalogue entry from the units on the shelf.
- **D:** product → good (subtype); product ← product_category_classification →
  product_category (rollup) ← market_interest → **party_type**; product ←
  product_feature_applicability → product_feature (interaction); product ← supplier_product →
  **organization**; good ← good_identification, reorder_guideline (→ **facility** or
  **geographic_boundary**), inventory_item (→ **facility** | container); product and/or
  feature ← price_component (→ **geographic_boundary**, **party_type**, **organization**,
  quantity break, order value); product | feature ← estimated_product_cost; product ←
  product_association → product. Bold = from Ch 2. Kept: 3.10a's good subtypes, not 3.10b's
  PART.
</details>

### Architecture · V1 Ch 4 · Ordering products (Fig 4.17)
- **Cue:** "Everything about what was needed, asked, offered, agreed and ordered, in one picture."
- **Hook:** a conveyor belt (need, ask, offer) feeding the orders drawer; the contracts drawer
  beside it, tied by a rulebook, not a string *(Claude's, drafted when the figure landed)*
- **Mantra:** Need, ask, offer, order: item to item. Orders and agreements, both header and
  items, meet by rule, never by key.

<details><summary>Key</summary>

- **S:** `order` + `order_item` (sales or purchase; each line a snapshot of product or
  feature and agreed price) · `agreement` + `agreement_item` (nested; roles, terms, pricing
  programs) · the chain `requirement` → `requirement_request` → `request_item` →
  `quote_item` → `order_item`, with `order_requirement_commitment` back to the need.
- **W:** a need is asked about (request), answered (quote) and accepted (order item), and
  the commitment says how much of it an order fills. Around the order, each on the order or
  one item: roles, contact mechanisms by purpose, statuses, terms, adjustments. Around the
  agreement: roles, the relationship it formalizes, terms, and prices on its pricing
  programs. An agreement governs an order line by rule (its dates, its parties, its items'
  applicability), with no key.
- **T:** *(the naive-model trap until practice gives yours)* twin sales and purchase models
  (4.1), a column per order party, and an `agreement_id` on the order.
- **D:** requirement (part of) ← requirement_request → request_item → request; quote_item →
  request_item, → quote (← quote_term); order_item → quote_item (acceptance), → order, →
  **product** | **product_feature**; order ← order_role → **party**; order | order_item ←
  status, term, adjustment, contact mechanism (by **contact_mechanism_purpose_type**);
  order_requirement_commitment → order_item, requirement; agreement ← agreement_role →
  **party**, → **party_relationship**; agreement ← agreement_item (nested) ← agreement_term,
  ← **price_component**; order_item ⇢ agreement_item (derived). Bold = from Ch 2 and Ch 3.
  Kept: 4.2's one ORDER over 4.1's twins, 4.5's generic parties over 4.3's columns.
</details>

### Architecture · V1 Ch 5 · Shipments (Fig 5.8)
- **Cue:** "Everything about goods on the move, from order line to box, stock, paper and road, in one picture."
- **Hook:** a loading dock seen from above: order lines arriving on one side, boxes and stock
  shelves on the other, a truck backing up to the door *(Claude's, drafted when the figure
  landed)*
- **Mantra:** The shipment line in the middle: orders fill it, boxes hold it, stock feeds or
  takes it, papers and legs carry it.

<details><summary>Key</summary>

- **S:** `shipment` + `shipment_item` (typed by direction; a party and an address at each
  end; the plan on the header, a `shipment_status` history).
- **W:** order lines meet shipment lines through ORDER SHIPMENT, with a quantity, and the
  features that went out; lines go into packages through PACKAGING CONTENT; incoming
  packages turn into stock through SHIPMENT RECEIPT, and stock leaves for outgoing lines
  through ITEM ISSUANCE (by picklist), the quantity on hand checked against both; the
  shipment, a line or a box carry SHIPPING DOCUMENTs; the shipment travels in ROUTE
  SEGMENTs (carrier, method, vehicle, facility to facility).
- **T:** *(the naive-model trap until practice gives yours)* shipping as columns on the
  order (ship date, carrier, tracking number, quantity shipped), which breaks when a line
  ships in parts, a truck carries several orders, or goods move with no order at all.
- **D:** **order_item** ← order_shipment → shipment_item → shipment, → **good**;
  shipment_item ← shipment_item_feature → **product_feature**; shipment_item ←
  packaging_content → shipment_package ← shipment_receipt → **inventory_item**;
  **inventory_item** ← item_issuance → shipment_item; shipment | shipment_item |
  shipment_package ← shipping_document; shipment ← shipment_route_segment → **facility**,
  carrier (**party_role**), vehicle (**fixed_asset**); shipment → **party**,
  **contact_mechanism**. Bold = from Ch 2, 3 and 4 (and Ch 8's fixed asset, built early).
  Kept: every submodel; no line from a package to its shipment, none from an issuance to a
  package.
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
- **P8 · Catalogue vs physical instance.** Cue: "One description, many things you can count on the shelf."

---

## Log

| Date | Card | Grade | Box | Note |
|---|---|---|---|---|
| | | | | |
