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

**OLAP cards** (the user's call, 2026-10-20). A warehouse card (a star schema: Vol 1's
warehouse chapters, or the end of a Vol 2 chapter) carries a `- **Kind:** OLAP` bullet under
its Cue. The export tags it `dm::olap` and puts **[OLAP]** on its front; it stays in its
usual deck. No bullet means OLTP. Search `tag:dm::olap` to drill only the star schemas.

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
- **Hook:** people wearing hats
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
- **Hook:** the switchboard
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
- **Hook:** the map and the floor plan
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
- **Hook:** the meeting minutes
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
- **Hook:** one product, many shelves, many barcodes
- **Mantra:** A product sits on its lowest true shelves, never two in a line, dated, one
  primary; shelves stack on shelves; party types browse shelves; codes are rows, not columns.

<details><summary>Key</summary>

- **S:** `product` (what we offer, good or service via `product_kind`; not who supplies it, not
  stock) · `product_category` with `product_category_rollup` (many parents allowed) ·
  `product_category_classification` (product in a category, dated, one flagged primary) ·
  `market_interest` (which party types care about which categories) · `good_identification`
  (SKU, UPC, ISBN… as type + value rows).
- **W:** a single `category_id` column on the product (one category, no history, no second
  hierarchy) and a column per code (`sku`, `upc`, `isbn`: empty for most products, a schema
  change for every new code).
- **T:** a product can belong to any true category, as long as that category neither
  belongs to one that already contains the product nor contains one that does; when two are
  in a line, keep the lower one (the rollup gives the rest; same subtree ≠ in a line: Crime
  and Children's both). The primary flag is a rule a plain FK can't hold (data-quality query). Rollup,
  good/service and identification are still unpractised; expect this card to be shaky.
- **D:** product ← classification → category; category ← rollup → category (parent, child);
  category ← market_interest → party_type; good (= product) ← good_identification →
  identification_type.
</details>

### Card 6 · V1 Ch 3 · Product features (Fig 3.4)
- **Cue:** "What options does a product come in, which are standard, and which clash?"
- **Hook:** build-your-own bike
- **Mantra:** Features attach to products as required, standard, optional or selectable; features constrain
  features, needing or clashing, sometimes only inside one product.

<details><summary>Key</summary>

- **S:** `product_feature` (a colour, size, quality, dimension…; dimensions carry a unit of
  measure) · `product_feature_applicability` (this feature on this product is required,
  standard, optional or selectable) · `product_feature_interaction` (feature A needs feature B,
  or A and B can't go together, optionally only within one product) · `unit_of_measure` with
  conversions. The product's unit says how it's counted (EACH); a dimension says what's inside
  (250 SHEET).
- **W:** a column per option on the product, or a separate product row for every combination
  (red-small, red-large, blue-small…): an explosion of near-duplicates and no rules between
  them. The other way round: whatever is sold alone, stocked or worked on in its own right (a
  kit's contents, a substitute, a walk-in engraving) is a product. A feature only describes
  what was bought, on a line ordered for the product's line. A unit per pack size (PACK_250)
  is product data disguised as a unit and explodes: count the product in EACH, put the
  contents in a SHEET dimension.
- **T:** applicability is feature ↔ **product**; interaction is feature ↔ **feature** (you mixed
  them up once). Null product on an interaction = it holds everywhere.
- **D:** product ← applicability → feature; feature ← interaction → feature (twice) and →
  product (optional); feature → uom.
</details>

### Card 7 · V1 Ch 3 · Suppliers and inventory (Figs 3.5–3.6)
- **Cue:** "Who can supply it, when do we reorder, and where is the physical stock?"
- **Hook:** the warehouse floor
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
- **Hook:** the price recipe
- **Mantra:** Price components are conditional rules: the most specific base wins, matching
  discounts and surcharges stack on it per unit; cost estimates hit a product or a feature,
  never both.

<details><summary>Key</summary>

- **S:** `price_component` (one pricing rule: base price, discount, surcharge or suggested
  price; for a product and/or a feature; optional "based on" conditions: region, party type,
  category, quantity break, order value, sale type, organization; a charge kind, required on a
  base or suggested price and optional (= any) on a discount or surcharge; recurring is "per" a
  time frequency, usage "per" a unit of measure, two columns) · `quantity_break` and
  `order_value` (ranges, exclusive thru) · `estimated_product_cost` (a dated estimate per cost component type, for a product **or** a
  feature) · `cost_component_type` (a hierarchy under materials, labour, other) · currency
  and time-frequency units of measure.
- **W:** a `price` column on the product: one number, so no discounts, regions, quantity breaks
  or history. One `cost` number gives no margin by materials or labour.
- **T:** *(the naive-model trap until practice gives yours)* looking up "the price" of a
  product: there isn't one. A price is computed per order line: base prices compete (one wins,
  plus one per chosen feature), every matching discount and surcharge adjusts it per unit, and
  the suggested price never enters.
- **D:** product and/or feature ← price_component → region / party type / category / quantity
  break / order value / sale type / organization (all optional), → currency; product | feature
  ← estimated_product_cost → cost_component_type.
</details>

### Card 9 · V1 Ch 3 · Product associations and parts (Figs 3.9–3.10)
- **Cue:** "Which products go with, replace, clash with or are built from which others?"
- **Hook:** the product tree family
- **Mantra:** A typed, dated link joins two products: component (package or assembly),
  substitute, successor, complement, clash. Components explode level by level. Each good is bought in, built in or sent out.

<details><summary>Key</summary>

- **S:** `product_association` (from product → to product, dated, with a reason; what "from"
  and "to" mean depends on the type) · `product_association_type` (component, substitute,
  obsolescence, complement, incompatibility; component is 3.9b's marketing package and
  3.10a's product component, one link for a kit and a BOM alike) · `quantity_used` and
  `instruction` for components, `quantity` for substitutes · `good.good_kind`: raw material (bought
  input), subassembly (built input), finished good (sold as it comes). The kind is one
  column on a good; the component rows link two goods (what goes into what, how many). Only
  the kinds tell a build line (grinder → burr set) from a package line (gift box → grinder),
  and a raw material with components is a check failure.
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
- **Hook:** one order pad, two desks
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
- **Hook:** a receipt whose stickers FLOUTS the printed price
- **Mantra:** Every price change is a typed row, on the order or one line, typed by what it
  pays for; tax rate copied from place, category and date.

<details><summary>Key</summary>

- **S:** `order_adjustment` (an amount **or** a percentage, stored positive; an amount is the
  total charged, never per unit; for the whole order **or** one item; discounts live here, the
  unit price is before discounts) · `order_adjustment_type` (the book's six subtypes on top, FLOUTS: **F**ee,
  **L**ess = discount, **O**ther = miscellaneous, **U**pcharge = surcharge, an extra on top of
  the normal, **T**ax = sales tax, **S**hipping = shipping and handling, moving the goods; finer
  types under them) ·
  `sales_tax_lookup` (a rate per geographic boundary, optionally per product category, dated:
  the rate in force on the order date).
- **W:** a column per charge on the order (`discount`, `tax`, `freight`): every new kind of
  charge is a schema change, two discounts don't fit, and a discount on one line has nowhere
  to go.
- **T:** *(the naive-model trap until practice gives yours)* pointing the tax adjustment at
  the lookup row instead of copying its rate: correcting the row rewrites old orders. And
  forgetting the sign: a discount stored like a charge adds to the bill.
- **D:** order ← adjustment → item (one or the other); adjustment → adjustment_type (→ its
  parent type); sales_tax_lookup → geographic_boundary (Ch 2), → product_category (Ch 3). No
  line from the lookup to the adjustment: the rate is copied.
</details>

---

### Card 12 · V1 Ch 4 · Order status, terms and item associations (Figs 4.7–4.8)
- **Cue:** "Where does an order or a line stand, under which agreed terms, and which purchase will fill a sales line?"
- **Hook:** a parcel tracker with fine print
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
- **Hook:** a shopping list in pencil
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
- **Hook:** sealed bids on the table
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
  stapled at the back
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
  clicking toward the cap
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
  beside it stamped with the real ones
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
  line of pens, and "black, not blue" circled
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
  "accepted" and "rejected" carton by carton
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
  while a ledger on the wall must still balance
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
  (bill of lading, packing slips) to the next truck
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
  running from both to the same machines on the floor
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

### Card 24 · V1 Ch 6 · Work effort breakdown (Fig 6.4)
- **Cue:** "What is this work made of, which parts serve two jobs, what must finish before what or run alongside, which effort redoes which, and what's the standard time for each kind of work?"
- **Hook:** a Gantt chart pinned on the factory wall: bars nested under bars, arrows from
  one bar's end to the next one's start, and one set-up bar with two parents

- **Mantra:** Efforts link to efforts: part-of, before, alongside, one typed dated table.
  Kinds of work carry standard hours.

<details><summary>Key</summary>

- **S:** `work_effort_association` (from effort, to effort, `from_date`, `thru_date`) typed
  by `work_effort_association_type` (BREAKDOWN; DEPENDENCY over PRECEDENCY and CONCURRENCY)
  · `work_effort.version_of_work_effort_id` ("redone via") · Ch 2's `work_effort_type`
  gains a parent: the levels (PROGRAM to ACTIVITY, plus JOB) group the kinds of work, each
  with its standard hours.
- **W:** a `parent_id` on the effort: Table 6.6's set-up 120001 serves runs #1 and #2, and
  "set-up before operating" has nowhere to go.
- **T:** *(the naive-model trap until practice gives yours)* reading a concurrency from one
  end only; a breakdown that loops back on itself.
- **D:** work_effort_association → work_effort (from), → work_effort (to), →
  work_effort_association_type (→ parent); work_effort → work_effort (version of, optional),
  → work_effort_type (→ parent, the level). Checks: no grouping row as a type; no cycle; a
  precedency's second effort not scheduled before the first ends.
</details>

---

### Card 25 · V1 Ch 6 · Work effort assignments and time (Figs 6.5–6.6)
- **Cue:** "Who works on this effort, as what, where and when; what can each party do; what state is the work in; and who spent how many hours on which effort, on whose approved timesheet?"
- **Hook:** a project room door with a roster of dated name badges (one a consulting firm's
  logo), a skills chart beside it, and a punch clock whose cards are stamped with job
  numbers
- **Mantra:** Parties take efforts in dated roles; skills describe the party. Workers book
  hours on efforts, gathered per timesheet.

<details><summary>Key</summary>

- **S:** `work_effort_party_assignment` (effort, party, `work_effort_role_type`, optional
  facility, from, thru, comment) · `party_skill` (years, rating) + `skill_type` ·
  `work_effort_status` (a dated history, Ch 2's `status_type` under WORK_EFFORT_STATUS) ·
  `timesheet` (a WORKER party role, a period) · `time_entry` (timesheet, effort, from and
  thru datetimes, hours) · `timesheet_role` + type (approver, keyed in by) · WORKER over
  Ch 2's EMPLOYEE and CONTRACTOR.
- **W:** an `assigned_to` and an `hours` column on the job: one person, no role, no dates,
  no "when" for the hours; John Smith's return after his vacation and USA Consulting
  can't be held.
- **T:** *(the naive-model trap until practice gives yours)* hanging time on the assignment
  (it hangs on the effort, so time without an assignment slips through); PERSON where the
  book says PARTY.
- **D:** work_effort_party_assignment → work_effort, → party (Ch 2), → work_effort_role_type,
  → facility (Ch 2, optional); party_skill → party, → skill_type; work_effort_status →
  work_effort, → status_type (Ch 2); timesheet → party_role (Ch 2, a WORKER); time_entry →
  timesheet, → work_effort; timesheet_role → timesheet, → party, → timesheet_role_type.
  Checks: no overlapping assignment; a skill once; statuses from the group, once each,
  completed after started; worker timesheets; entries inside their sheet and their span; no
  self-approval.
</details>

---

### Card 26 · V1 Ch 6 · Work effort rates (Fig 6.7)
- **Cue:** "What does an hour of this person on this job cost us and bill the client, regular or overtime, on a given day, and what's the standard rate for a position or a party?"
- **Hook:** a pay slip and an invoice side by side for the same hours, three price tags
  stapled above them: one for the job title, one for the person, one for this job only

- **Mantra:** Hours × the rate in force. Rates are dated and typed, on a position type, a
  party or an assignment; the most specific wins.

<details><summary>Key</summary>

- **S:** `rate_type` (regular and overtime, billing and pay) · `work_effort_assignment_rate`
  (assignment, rate type, from, thru, rate) · `party_rate` (party, …) ·
  `position_type_rate` (position type, …) · `position_type`, built ahead of Ch 9.
- **W:** an `hourly_rate` column on the person: billing and pay can't differ, a raise
  rewrites past invoices, and Table 6.11's six rows (two of them after the raise) can't be
  held.
- **T:** *(the naive-model trap until practice gives yours)* expecting the model to say
  which rate wins (it's a business rule; the cost query takes the assignment's, else the
  party's); dropping the overtime rate once it equals regular.
- **D:** work_effort_assignment_rate → work_effort_party_assignment (→ work_effort, →
  party), → rate_type; party_rate → party (Ch 2), → rate_type; position_type_rate →
  position_type, → rate_type. Checks: two rates of one type in force at once for the same
  owner; an assignment rate outside its assignment's dates.
</details>

---

### Card 27 · V1 Ch 6 · Inventory and fixed asset assignments (Figs 6.8–6.10)
- **Cue:** "Which stock did this job use up; which machines, vehicles and tools are booked on which job and when; and who has which asset checked out, active or lost?"
- **Hook:** a workshop booking board with machine names down the side and job cards pinned
  in dated slots, a bin of used-up parts below, and a sign-out sheet by the door where one
  line says LOST
- **Mantra:** Jobs use up stock items and book assets, one job at a time. Assets also go
  out to parties, active or lost.

<details><summary>Key</summary>

- **S:** `work_effort_inventory_assignment` (effort, inventory item, quantity) ·
  `work_effort_fixed_asset_assignment` (effort, asset, status, from, thru, allocated cost,
  comment) · `party_fixed_asset_assignment` (party, asset, status, …) · `fixed_asset_type`
  nests, its top rows the subtypes PROPERTY, VEHICLE, EQUIPMENT, OTHER · `fixed_asset`
  gains a description and a capacity unit · statuses: two groups in Ch 2's `status_type`
  (requested, assigned; active, lost).
- **W:** a `materials` text and a `machine_id` on the job: no stock count can use the text,
  one machine per job, no dates, so nobody sees the labeler is double-booked.
- **T:** *(the naive-model trap until practice gives yours)* pointing use at the GOOD
  instead of the INVENTORY ITEM; trusting a thru date to say an asset was lost.
- **D:** work_effort_inventory_assignment → work_effort, → inventory_item (Ch 3);
  work_effort_fixed_asset_assignment → work_effort, → fixed_asset, → status_type (Ch 2);
  party_fixed_asset_assignment → party (Ch 2), → fixed_asset, → status_type; fixed_asset →
  fixed_asset_type (→ parent), → unit_of_measure (Ch 3). Checks: an item twice on one
  effort; a serialized item used more than once; one asset on two jobs or two holders at
  once; a foreign status; a capacity with no unit; an asset used after it was lost.
</details>

---

### Card 28 · V1 Ch 6 · Work effort standards and results (Figs 6.11–6.12)
- **Cue:** "What does a kind of work normally need and break into, is there enough for the jobs planned, and what did each job actually produce or repair?"
- **Hook:** a recipe card clipped to a finished cake: the card lists the ingredients, the
  tins and the cooks for "a large batch"; the plate shows what came out of this one

- **Mantra:** The kind of work holds the recipe (skills, goods, asset types, its own
  breakdown); the job records what came out.

<details><summary>Key</summary>

- **S:** `work_effort_skill_standard` (type, skill type, people, duration, cost) ·
  `work_effort_good_standard` (type, good, quantity, cost) ·
  `work_effort_fixed_asset_standard` (type, asset type, quantity, duration, cost) ·
  `work_effort_type_association` (from type, to type, 6.4's association type) ·
  `work_effort_type` repairs an asset type or produces a deliverable type or a product (at
  most one) · `work_effort_inventory_produced`, `work_effort_deliverable_produced` ·
  `work_effort.repaired_fixed_asset_id`.
- **W:** copying the materials list onto every job, or keeping it in a spreadsheet: no way
  to predict what next month's jobs need, or to compare it with what they used.
- **T:** *(the naive-model trap until practice gives yours)* pointing a standard at a real
  asset or stock item; mixing the type's parent ("a kind of") with its association ("made
  of"); expecting a quantity on what was produced.
- **D:** work_effort_skill_standard → work_effort_type, → skill_type; good standard → good
  (Ch 3); fixed asset standard → fixed_asset_type; work_effort_type_association →
  work_effort_type (from, to), → work_effort_association_type; work_effort_type →
  fixed_asset_type | deliverable_type | product (an arc); inventory produced → work_effort,
  → inventory_item (Ch 3); deliverable produced → work_effort, → deliverable; work_effort →
  fixed_asset (repaired). Checks: a grouping row as a type association; a kind twice in one
  type's standards; a repair of another asset than the need names.
</details>

---

### Card 29 · V1 Ch 7 · Invoices and invoice items (Fig 7.1a)
- **Cue:** "What does this bill charge for, line by line, and which lines are tax, fees, discounts or corrections of other lines?"
- **Hook:** a till receipt where the tax, the delivery fee and yesterday's refund are all
  printed as lines, each with an arrow to the line it touches
- **Mantra:** Every charge is a typed line; an adjustment points at what it adjusts, a
  feature at what it was sold with.

<details><summary>Key</summary>

- **S:** `invoice` (date, message, description; `invoice_kind` SALES or PURCHASE) ·
  `invoice_item` (seq within the invoice, taxable flag, quantity optional and signed, amount
  per unit; for a product, a feature, a serialized inventory item, or only a description;
  "adjusted by" and "sold with", both recursive) · `invoice_item_type` (ACQUIRING_ITEM over
  product, feature, work effort, time entry; ADJUSTMENT over discount, surcharge, sales tax,
  shipping and handling, fee, miscellaneous: 7.1b's two subtype sets as top rows).
- **W:** `tax_amount` and `freight_charge` columns on the invoice and one `product_id` per
  line: a new fee is a schema change, a discount on one line has nowhere to go, two servers
  with different features can't keep them apart, and a mistake gets fixed by editing a legal
  document.
- **T:** *(the naive-model trap until practice gives yours)* correcting a billed quantity in
  place instead of adding a −2 line that points back; putting the product and its feature on
  one line; tying an invoice-level tax to a line.
- **D:** invoice ← invoice_item → invoice_item_type (→ parent type); item → product,
  product_feature, inventory_item (Ch 3; all optional); item → item (adjustment for; sold
  with). Checks: a seq twice on one invoice; a grouping-row type; a line that bills nothing; a
  feature not sold with a product line of its invoice; an adjustment of another invoice's
  line, or a correction of another product; an inventory item of a different product.
</details>

---

### Card 30 · V1 Ch 7 · Invoice parties and billing accounts (Figs 7.2–7.3a)
- **Cue:** "Who is billed and who bills, where did the invoice go, who else touched it, and when it's billed to an account, who actually owes?"
- **Hook:** a family phone bill addressed to the account, not the person; inside the
  envelope, the account card lists Mum as primary payer and whoever is secondary this year

- **Mantra:** Billed from a party, billed to a party or an account; sent anywhere; extra
  people are dated roles.

<details><summary>Key</summary>

- **S:** `invoice` gains billed to (party), billed from (party, mandatory), addressed to and
  sent from (any contact mechanism), and `billing_account_id` in an arc with billed to ·
  `invoice_role` (party, type, datetime, percentage) + `invoice_role_type` (entered by,
  approver, sender, receiver) · `billing_account` (from, thru, description, billed at a
  contact mechanism) · `billing_account_role` (party, type, from, thru) +
  `billing_account_role_type` (primary payer, secondary payer, service rep, manager, sales
  rep). Ch 4's orders gain a requested bill-to account, in an arc with the bill-to role.
- **W:** a `customer_id` and a `billing_address` on the invoice: no e-mailed bills, no
  approver or clerk, no way to bill a household account whose payers change, no splitting one
  customer's office supplies from its consulting.
- **T:** *(the naive-model trap until practice gives yours)* pointing billed to at an account
  *and* a party; reading "who owes" off the account without the invoice date; addressing a bill
  to any mechanism the party has instead of one it uses for billing.
- **D:** invoice → party (billed to | billing_account: the arc), → party (billed from), →
  contact_mechanism (addressed to, sent from; Ch 2); invoice ← invoice_role → party, →
  invoice_role_type; billing_account → contact_mechanism (billed at); billing_account ←
  billing_account_role → party, → billing_account_role_type; sales_order, purchase_order (Ch
  4) → billing_account. Checks: addressed where the party takes no bills; a mechanism the
  sender doesn't hold; a role twice; an account invoice outside the account's dates or
  addressed off the account; two primary payers at once; no primary payer on the date.
</details>

---

### Card 31 · V1 Ch 7 · Invoice status and terms (Fig 7.4)
- **Cue:** "Where is this bill now and since when, and what are its payment terms, late fees and line-level conditions?"
- **Hook:** an envelope stamped APPROVED, SENT and, in red, VOID, each with a date, and a
  small-print box on the back: net 30, 2% late, one line marked "no returns"
- **Mantra:** Status is a dated history, never PAID; terms copy onto the bill or one line,
  never both.

<details><summary>Key</summary>

- **S:** `invoice_status` (invoice, status type, date) with the types as an INVOICE_STATUS
  group in Ch 2's `status_type` (approved, sent, void; received for supplier bills) ·
  `invoice_term` (term type, invoice or item, value) on Ch 4's shared `term_type`.
- **W:** a `status` column and a `payment_terms` text on INVOICE: no history (was 30005 sent
  before it was voided?), no second term, no term on one line, nothing to compute a due date
  from.
- **T:** *(the naive-model trap until practice gives yours)* storing PAID as a status
  beside the payments that already say so; pointing at the agreement's term instead of
  copying it; a term on both the invoice and a line.
- **D:** invoice ← invoice_status → status_type (Ch 2); invoice ← invoice_term (arc: invoice
  | invoice_item) → term_type (Ch 4). Current status = the latest. Checks: a status outside
  the group; before the invoice date; anything after a void; a status twice on one day; a
  term type twice on one invoice or line.
</details>

---

### Card 32 · V1 Ch 7 · Billing for what was delivered (Figs 7.5–7.7)
- **Cue:** "Which shipment lines, hours, jobs or order lines does this invoice line charge for, and what's delivered or worked but not billed?"
- **Hook:** an invoice line with four strings pinned to it, running back to a delivery note,
  a timesheet, a project plan and a purchase order
- **Mantra:** An invoice line points back at what caused it: a shipment, hours, a job or an
  order line. One route per line.

<details><summary>Key</summary>

- **S:** `shipment_item_billing` (shipment item, invoice item) · `time_entry_billing` (time
  entry, invoice item) · `work_effort_billing` (work effort, invoice item, percentage) ·
  `order_item_billing` (order item, invoice item, quantity, amount). All many to many.
- **W:** a `shipment_item_id` (or `order_item_id`) on the invoice line, or an `invoiced`
  flag on the time entry: one line can't gather three shipments, an order line can't be
  billed in parts, and a void bill leaves nothing to say what's unbilled again.
- **T:** *(the naive-model trap until practice gives yours)* billing one line through both
  its order and its shipment (counted twice); counting a void invoice as billing; billing a
  time entry on two lines with no hours to split it.
- **D:** invoice_item ← shipment_item_billing → **shipment_item** (Ch 5); invoice_item ←
  time_entry_billing → **time_entry** (Ch 6); invoice_item ← work_effort_billing →
  **work_effort** (Ch 6); invoice_item ← order_item_billing → **order_item** (Ch 4). Checks:
  a pair twice; another product shipped than billed; shipped to someone else than billed; a
  link on a line of the wrong type; an entry on two lines; an effort over 100%; an order
  line billed past its quantity or on the other kind of invoice; a line on both routes.
</details>

---

### Card 33 · V1 Ch 7 · Payments (Fig 7.8a)
- **Cue:** "Who paid whom, how and how much, which invoices or which account it settles, and what's still owed?"
- **Hook:** one check pinned across two bills, with the stub split $6,000 and $1,000, and a
  second bill held by two smaller checks
- **Mantra:** A payment goes party to party; applications split it over invoices, or on
  account. Balance is computed, never stored.

<details><summary>Key</summary>

- **S:** `payment` (kind RECEIPT or DISBURSEMENT, method type, from party, to party,
  effective date, ref num, amount, comment) · `payment_application` (payment, invoice or
  billing account: the arc, amount applied) · `payment_method_type` · view `invoice_total`.
- **W:** `paid_date` and `amount_paid` on INVOICE, or `invoice_id` on PAYMENT: no partial
  payments, no one check for several bills, no money received before anyone knows which bill
  it's for.
- **T:** *(the naive-model trap until practice gives yours)* storing an outstanding balance
  that drifts from the lines; a receipt applied to a purchase invoice; applying more of a
  payment than it's worth.
- **D:** payment → payment_method_type, → **party** (from, to; Ch 2); payment ←
  payment_application → invoice | billing_account (the arc). Outstanding = invoice_total −
  applications. Checks: a payment the wrong way round (receipt not to, disbursement not from,
  an internal organization); applied past its amount; an invoice paid past its total; a
  receipt on a purchase bill or back. 7.8b (per-line applications) dropped.
</details>

---

### Card 34 · V1 Ch 7 · Financial accounts (Fig 7.9)
- **Cue:** "Which payments went into which deposit or withdrawal, on which bank account, who may act on it, and what's its balance?"
- **Hook:** a bank deposit slip with four checks stapled to it and a total of $917.04 at the
  bottom, next to a statement with one line for the whole slip
- **Mantra:** Payments aren't cash until banked: receipts gather into a deposit, a check
  clears as a withdrawal; parties hold the account in roles.

<details><summary>Key</summary>

- **S:** `financial_account` (the bank's number as id, kind BANK or INVESTMENT, optional
  type: checking, savings, IRA, mutual fund; name) · `financial_account_role` (party, type:
  owner, signer, administrator; from, thru) · `financial_account_transaction` (kind DEPOSIT,
  WITHDRAWAL or ADJUSTMENT, account, executed by, transaction and entry date; an amount for
  adjustments only) · `payment` gains its transaction.
- **W:** a `bank_account_id` or a `deposited_date` on PAYMENT: no deposit slip to match the
  statement's one line, no bank fees, no record of who banked it.
- **T:** *(the naive-model trap until practice gives yours)* giving the deposit an amount
  that can disagree with its receipts; a check put in a deposit; a withdrawal executed by
  someone with no role on the account.
- **D:** **payment** (Ch 7) → financial_account_transaction → financial_account (→
  financial_account_type), → **party** (executed by); financial_account ←
  financial_account_role → **party**, → financial_account_role_type. Checks: a type outside
  the account's kind; a payment in the wrong kind of transaction; a withdrawal that isn't
  one check; a deposit with no payments; executed by someone without a role that day; a role
  twice.
</details>

---

### Card 35 · V1 Ch 8 · Chart of accounts (Figs 8.1, 8.4)
- **Cue:** "Which ledger accounts does each of our organizations keep, since when, of which kind, broken down by which customer, supplier or product, and how does each cut its year into periods?"
- **Hook:** one printed chart of accounts pinned on the wall of two offices, with a
  different set of lines highlighted in each and "marketing" crossed out in only one; under
  "receivables", a sticky note per customer
- **Mantra:** One chart for everyone; each organization switches accounts on by date,
  splits them into subsidiaries about someone, and cuts its own periods.

<details><summary>Key</summary>

- **S:** `general_ledger_account` (the account number as id: 110 cash; name, description,
  type) · `general_ledger_account_type` (asset, liability, owners equity, revenue,
  expense) · `organization_gl_account` (internal organization, account, from, thru;
  subsidiary of another, referencing a supplier or bill-to customer role, a product
  category or a product) · `accounting_period` (internal organization, period type,
  within, number, from, thru) · `period_type` (fiscal year, quarter, month).
- **W:** an account name typed on each ledger line, or one chart per company: renaming
  breaks history, two companies' "cash" can't be added up, and one company's split of an
  account changes the other's. "120-ACME" in the chart: the chart grows with every customer
  and nothing says the account is about ACME.
- **T:** *(the naive-model trap until practice gives yours)* ending an account in the chart
  when only one organization stopped using it; periods for the enterprise when fiscal
  years differ; a new chart number per customer instead of a subsidiary account.
- **D:** **organization** (Ch 2, an INTERNAL_ORGANIZATION role) ← organization_gl_account →
  general_ledger_account → general_ledger_account_type; organization_gl_account ↺
  subsidiary of, → **party_role** (supplier, bill-to customer), **product_category**,
  **product** (Ch 3; all optional); **organization** ← accounting_period → period_type, ↺
  within. Checks: an account kept by an organization that was never internal; the same
  account twice at once; a subsidiary of another organization or number, or outside its
  parent's dates; a "customer" whose role is something else; a period inside another
  organization's or outside its parent's dates.
</details>

---

### Card 36 · V1 Ch 8 · Accounting transactions (Figs 8.2–8.3b, 8.5)
- **Cue:** "What did each business event do to the books: which debits and credits on which accounts, from which invoice, payment or asset, which credit settled which debit, and what was each account's balance for a period?"
- **Hook:** a cash register receipt for $900 stapled to a ledger page where it becomes three
  lines: $882 cash and $18 discount on the left, $900 receivables on the right; beside it a
  machine's tag reading "1999 double-declining, 2000 straight-line"
- **Mantra:** One event, typed and traced to its document or asset, splits into debits and
  credits that cancel; balances are sums, stored only as checked caches.

<details><summary>Key</summary>

- **S:** `accounting_transaction` (type, from party, to party for external ones, at most
  one of invoice, payment, inventory item variance; the fixed asset for a depreciation;
  transaction and entry date, description; no amount) · `accounting_transaction_type` (a
  hierarchy: INTERNAL, EXTERNAL → OBLIGATION, PAYMENT over the book's subtypes, Table 8.3's
  types below) · `transaction_detail` (transaction, seq, organization GL account, amount,
  debit or credit, associated with another detail) · `organization_gl_account_balance`
  (account, period, amount) · `depreciation_method` (description, formula) ·
  `fixed_asset_depreciation_method` (asset, method, from, thru).
- **W:** one ledger row with an account, an amount and an optional `invoice_id`: a split
  payment or an asset sale becomes several unrelated rows, nothing proves they balance, and
  no line says which payment settled which invoice. A `depreciation_method` column on the
  asset rewrites last year's figures when the method changes.
- **T:** *(the naive-model trap until practice gives yours)* an amount on the transaction
  that can disagree with its details; a stored balance with no check against its postings;
  a depreciation with a receiver, or of no asset.
- **D:** **party** (from, to) ← accounting_transaction → accounting_transaction_type (↺),
  → **invoice**, **payment** (Ch 7), **inventory_item_variance** (Ch 3), **fixed_asset**
  (Ch 5–6); accounting_transaction ← transaction_detail (↺ associated with) →
  **organization_gl_account** (8.1); organization_gl_account_balance →
  organization_gl_account, **accounting_period** (8.1); **fixed_asset** ←
  fixed_asset_depreciation_method → depreciation_method. Checks: a grouping row as type;
  parties, documents or an asset that don't fit the subtype; debits ≠ credits; a posting to
  a closed account or another organization's books; a stored balance off its postings; a
  depreciation with no method that day; two methods at once.
</details>

---

### Card 37 · V1 Ch 8 · Budgets (Figs 8.6–8.9)
- **Cue:** "Who asks for how much money, for which period, for what and why; where is each budget in its approval, and who said yes or no; how was it revised, item by item; and what would it be in a good or a bad year?"
- **Hook:** a department's budget sheet with a "why" column, a rubber stamp trail down the
  margin (created, submitted, SENT BACK, submitted, approved) with a reviewer's initials on
  each stamp, red pencil deltas beside three lines, and two sticky notes at the bottom:
  "poor year −20%", "great year +25%"
- **Mantra:** Budget: a party, a period; items say what and why; status and reviews
  approve; revisions are deltas; scenarios are what-ifs.

<details><summary>Key</summary>

- **S:** `budget` (type, standard time period, comment) · `budget_type` (operating,
  capital: the subtypes as rows) · `standard_time_period` (period type, from, thru) ·
  `budget_item` (budget + seq, item type, part of another item, amount, purpose,
  justification) · `budget_item_type` · `budget_status` (Ch 2 status types under
  BUDGET_STATUS, date, comment) · `budget_role` + `budget_role_type` (the party it's for,
  the initiator) · `budget_revision` (budget + seq, date) · `budget_revision_impact`
  (revision, item, signed change, add/delete flag, reason) · `budget_review` (budget,
  reviewer, result type, date, comment) + `budget_review_result_type` · `budget_scenario` ·
  `budget_scenario_rule` (scenario × item type, an amount or a %) ·
  `budget_scenario_application` (scenario, an item or a whole budget, an amount or a %).
- **W:** a spreadsheet per department with a total: no place in the organization tree to
  roll up, no approval history or reviewer, no item kinds to compare across departments,
  each revision overwrites what was asked for, and every "what if" is another copy of the
  sheet.
- **T:** *(the naive-model trap until practice gives yours)* overwriting an item's amount
  on revision; summing a parent item and its parts; counting an added item twice;
  `approved_by` on the budget; a copy of the budget per scenario; applying a scenario to a
  budget and to its items at once.
- **D:** **standard_time_period** → **period_type** (8.1) ← budget → budget_type; budget ←
  budget_item (↺ part of) → budget_item_type; budget ← budget_status → **status_type**
  (Ch 2); budget ← budget_role → **party** (Ch 2, rolling up through ORGANIZATION_ROLLUP),
  budget_role_type; budget ← budget_revision ← budget_revision_impact → budget_item;
  budget ← budget_review → **party**, budget_review_result_type; budget_scenario ←
  budget_scenario_rule → budget_item_type; budget_scenario ← budget_scenario_application →
  budget_item | budget. Checks: a status of another group; a budget with no items or for
  no one; parts that don't add up to their parent; a revision touching another budget's
  item; an item revised below zero; a review before submission; a scenario counted twice.
</details>

---

### Card 38 · V1 Ch 8 · Budget usage and the ledger (Figs 8.10–8.11)
- **Cue:** "Which requirements, orders and payments draw on each budget item, how much is left, and which GL accounts does each kind of budget item land in?"
- **Hook:** a budget line with three clips hanging off it (a requisition, a purchase order,
  a check torn in two halves for two lines) and a translation card pinned beside it:
  "marketing = 50% trade shows (525) + 50% advertising (520)"
- **Mantra:** Needs earmark, orders commit, checks spend, each against a budget item;
  item types map to ledger accounts by share.

<details><summary>Key</summary>

- **S:** `order_item.budget_item_id` (Ch 4's line, allocated to one item) ·
  `requirement_budget_allocation` (requirement × item, amount) ·
  `payment_budget_allocation` (payment × item, amount) · `gl_budget_xref` (item type ×
  GL account, from, thru, allocation %).
- **W:** a "spent so far" column on the budget item, bumped by hand, and a GL account
  column on each budget line: the total drifts on the first voided or split check, can't
  say which payments made it, and every department repeats the same mapping with no way
  to split it.
- **T:** *(the naive-model trap until practice gives yours)* storing what's spent instead
  of summing allocations; one budget item per payment, so a split check can't be told;
  mapping items instead of item types; shares that don't add up to 100.
- **D:** **requirement** (Ch 4) ← requirement_budget_allocation → budget_item;
  **order_item** (Ch 4) → budget_item; **payment** (Ch 7) ← payment_budget_allocation →
  budget_item → budget_item_type ← gl_budget_xref → **general_ledger_account** (8.1).
  Checks: a payment allocated beyond its amount; an order or payment outside its budget's
  period; an item type's shares not adding up to 100.
</details>

---

### Card 39 · V1 Ch 9 · Positions (Figs 9.3–9.4)
- **Cue:** "Which slots does the enterprise have, of which type and terms, funded and authorized by which budget item, doing what, classified how, and represented by which union?"
- **Hook:** an org chart of empty boxes, each with a price tag clipped to a budget line
  ("analysts, 2001: $120,000 — APPROVED" stamped on it), a job-description card pinned
  under each box with ticked duties from a master list, and colored stickers on the card
  (Computer, MIS) with dates on them
- **Mantra:** A position is a slot, not a person: typed, funded by a budget item, given
  valid duties, classed by dates.

<details><summary>Key</summary>

- **S:** `position` (type, budget item?, estimated from/thru, salary, exempt, full-time,
  temporary flags, actual from/thru) · `position_type` (Ch 6's, + title, benefit %, union
  role?) · `responsibility_type` · `valid_responsibility` (type × responsibility, dated) ·
  `position_responsibility` (slot × responsibility, dated) · `position_classification_type`
  · `position_type_class` (type × class, dated, standard hours/week) · UNION a Ch 2 role
  type under ORGANIZATION_ROLE.
- **W:** a `job_title` and `duties` text on the employee row: the job vanishes when its
  holder leaves, a vacancy or a planned slot can't exist, nothing ties headcount to the
  budget, and one `job_category` column can't hold two groupings or a change of one.
- **T:** *(the naive-model trap until practice gives yours)* putting the flags on the
  person; storing an `authorized_flag` instead of reading the budget's status; giving a
  slot a duty its type doesn't allow; one category column on the type.
- **D:** **budget_item** (Ch 8) ← position → position_type ← valid_responsibility →
  responsibility_type ← position_responsibility → position; position_type ←
  position_type_class → position_classification_type; position_type → **party_role**
  (Ch 2, UNION). Checks: a duty not valid for the slot's type on its start day; a slot
  opened before its budget's approval; overlapping classes; a "union" that isn't one.
</details>

---

### Card 40 · V1 Ch 9 · Employment, fulfillment and reporting (Figs 9.2, 9.5–9.6)
- **Cue:** "Who is employed by whom, who has filled each slot and when, which slots are vacant, and which slot reports to which on a given day?"
- **Hook:** Mike Johnson climbing a ladder of five boxes (mail clerk to CEO), each box
  staying on the wall after he steps off, with dotted lines from box to box above him and
  one line drawn thicker (the primary), while an employment badge on his lapel never
  changes
- **Mantra:** Employment is a relationship; people fill slots for a while; slots report
  to slots, one line primary.

<details><summary>Key</summary>

- **S:** EMPLOYMENT = Ch 2's `party_relationship` typed EMPLOYMENT (internal organization
  role → employee role, dated, status), read through the `employment_relationship` view ·
  `position` gains hiring `organization` and a current status (Ch 2 `status_type`, group
  POSITION_STATUS) · `position_fulfillment` (slot × person, from, thru, comment) ·
  `position_reporting_structure` (reporting slot, manager slot, from, thru, comment,
  primary flag).
- **W:** 9.1's EMP and DEPT: a title and a hire date on the person, `reports_to` between
  people: each promotion overwrites the last, a rehire loses the first stint, a vacancy
  cuts the chart, one boss only, and a reorganization rewrites every employee.
- **T:** *(the naive-model trap until practice gives yours)* putting the title on the
  employment; banning two people in one slot (job shares); reporting person to person;
  two primary lines at once.
- **D:** **party_role** (Ch 2: internal organization, employee) ← **party_relationship**
  (EMPLOYMENT); **organization** (Ch 2) ← position → **status_type**; position ←
  position_fulfillment → **person** (Ch 2); position ← position_reporting_structure →
  position (reporting, managed by). Checks: overlapping employments by one employer; a
  fulfillment outside its slot's dates; a hiring company never internal; two primary
  lines at once. Review: fulfillments with no employment.
</details>

---

### Card 41 · V1 Ch 9 · Pay and benefits (Figs 9.7–9.8)
- **Cue:** "What should each kind of job pay, by band or by grade step, what has each employee actually been paid, and which benefits does each employment carry, at what cost and share?"
- **Hook:** a ruler pinned to a job's door, marked lowest, average, highest, with a
  ladder of numbered steps beside it (the grade), and John Smith's own pay slips stacked
  on his badge, one per raise, next to a health card stamped "50%" crossed out to "60%"
  and a jar of 15 vacation beans
- **Mantra:** The job has a band, an amount or a grade step; the employment holds what was
  paid and the benefits.

<details><summary>Key</summary>

- **S:** `position_type_rate` (Ch 6's, + period, salary step?, rate optional: amount or
  step, never both) · `pay_grade` · `salary_step` (grade + seq, amount, date modified) ·
  `pay_history` (employment, period, step?, from, thru, amount) · `benefit_type`
  (standard employer %) · `party_benefit` (employment, type, period, from, thru, cost,
  actual employer %, available time) · Ch 8's `period_type` (+ HOUR, DAY).
- **W:** a `salary` column and a `vacation_days` column on the employee: each raise
  overwrites the last, nothing says what the job should pay, a new benefit is a new
  column, and the employer's share can't change without losing the old one.
- **T:** *(the naive-model trap until practice gives yours)* pay on the position or the
  person instead of the employment; an amount and a step on the same rate; keying rates
  without the rate type; a step amount assumed to keep its history.
- **D:** **position_type** (Ch 6) ← position_type_rate → **rate_type** (Ch 6),
  **period_type** (Ch 8), salary_step → pay_grade; **party_relationship** (Ch 2,
  EMPLOYMENT) ← pay_history → period_type, salary_step; **party_relationship** ←
  party_benefit → benefit_type, period_type. Checks: overlapping rates of one type, rate
  type and period; overlapping pay in one employment; a benefit twice at once or outside
  its employment.
</details>

---

### Card 42 · V1 Ch 9 · Payroll (Fig 9.9)
- **Cue:** "How does each employee want to be paid by each employer, what is withheld, and what did each paycheck come to, gross, deductions and net?"
- **Hook:** a paycheck torn into strips: four strips (federal, FICA, state, insurance)
  dropped in labelled bins, the rest cut in half and posted into two bank slots whose
  numbers come from a standing order card pinned to John Smith's badge and ABC's logo

- **Mantra:** Preferences plan the split and the withholding; a paycheck is a payment;
  deductions come off it.

<details><summary>Key</summary>

- **S:** `payroll_preference` (employee role, internal organization role, seq, from, thru,
  percentage, flat amount, routing, account, bank, period?, payment method?, deduction
  type?) · `deduction_type` · `paycheck` (subtype of Ch 7's `payment`, a DISBURSEMENT:
  issued for an employee role, from an internal organization role) · `deduction`
  (paycheck + seq, type, amount). The payment's amount is the gross; the net is derived.
- **W:** a `bank_account` column on the employee and a `net_pay` figure: one account, no
  split, no history of changes, and nothing records what was withheld or why.
- **T:** *(the naive-model trap until practice gives yours)* storing only the net; a
  paycheck table of its own outside PAYMENT, so it is never banked or posted; editing the
  account number in place; shares adding up to more than 100.
- **D:** **party_role** (Ch 2: employee, internal organization) ← payroll_preference →
  **period_type** (Ch 8), **payment_method_type** (Ch 7), deduction_type; **payment**
  (Ch 7) ← paycheck → **party_role** ×2; paycheck ← deduction → deduction_type. Checks:
  deposit shares above 100% on a day; a paycheck whose roles don't match its payment.
</details>

---

### Card 43 · V1 Ch 9 · Applications and qualifications (Figs 9.10–9.11)
- **Cue:** "Who applied for which slot, through which source, referred by whom, in what state, and what can each candidate show: skills, degrees, certifications, training, resumes?"
- **Hook:** a pile of envelopes in a tray labelled with slot 101's box from the org
  chart, one envelope with a sticky note "sent by Sue", each opened onto a resume, a
  diploma that never expires and a certificate with a red expiry stamp, and a framed ISO
  certificate on ABC's own wall
- **Mantra:** People apply, for a slot or any job; parties show skills and
  qualifications; persons train.

<details><summary>Key</summary>

- **S:** `employment_application` (date, slot?, status, source type, applicant person,
  referrer person?) · `employment_application_source_type` · `qualification_type` (DEGREE
  and CERTIFICATION as groups) · `party_qualification` (party, type, from, thru) ·
  `party_skill` (Ch 6's, + started using date; rating = skill level) ·
  `training_class_type` · `person_training` (person, class, from, thru) · `resume`
  (party, date, text).
- **W:** only hired people exist (EMP rows), with `degree` and `skills` text: applicants
  who were turned down vanish, no source or referrer to measure, one degree, no lapse
  dates, nothing an organization can hold.
- **T:** *(the naive-model trap until practice gives yours)* making the slot mandatory
  on an application; qualifications on PERSON only; one status column with no group
  check; a degree with an end date.
- **D:** **person** (Ch 2) ← employment_application → **position**, **status_type**
  (Ch 2), source type, **person** (referrer); **party** (Ch 2) ← party_qualification →
  qualification_type (↺ groups); **party** ← **party_skill** (Ch 6) → **skill_type**;
  **person** ← person_training → training_class_type; **party** ← resume. Checks: an
  application for a closed slot or with a wrong status; an expiring degree or a group
  held.
</details>

---

### Card 44 · V1 Ch 9 · Performance and termination (Figs 9.12a, 9.13)
- **Cue:** "How is each employee reviewed and by whom, scored how, what did each review lead to, which notes were logged, and how and why did each employment end?"
- **Hook:** a report card with three graded lines, three arrows out of it (to a bigger
  pay slip, a bonus check, a door with a new title), sticky notes on the employee's file
  between report cards, and at the end an exit door with two tags, "layoff" and
  "downsizing", and a claim form trailing behind
- **Mantra:** Managers review employees by items, leading to pay, bonus or slot;
  employment ends with a type, a reason and claims.

<details><summary>Key</summary>

- **S:** `performance_review` (employee role, manager role, from, thru, comments, pay
  history?, bonus paycheck?, position?) · `performance_review_item` (review + seq, item
  type, rating type, comment) · `performance_note` (employee, manager, note type, from,
  thru, communication date, comment) · `employment_termination` (on the employment's key:
  termination type?, reason?) · `unemployment_claim` (employment, date, description,
  status). Ch 3's `rating_type`; MANAGER a Ch 2 role type.
- **W:** a `last_review_score` and a `terminated` flag on the employee: no items, no
  reviewer, no history, no tie to the raise it justified; leaving deletes or flags the
  row, so the reason and the claims go with it.
- **T:** *(the naive-model trap until practice gives yours)* reviews on the person
  instead of the employee role; one termination column mixing how and why; a review
  setting another employee's pay; a termination on an open employment.
- **D:** **party_role** (Ch 2: employee, manager) ← performance_review → **pay_history**,
  **paycheck**, **position**; review ← item → perf_review_item_type, **rating_type**
  (Ch 3); **party_role** ×2 ← performance_note → note type; **party_relationship** (Ch 2,
  EMPLOYMENT) ← employment_termination → termination type, reason; ← unemployment_claim →
  **status_type**. Alternate 9.12b (reviews as communication event purposes) not built.
  Checks: wrong role types, another employee's pay or bonus; terminations of open
  employments, claims before the end.
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
- **Hook:** the bicycle wheel
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
- **Hook:** the catalogue and the warehouse
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
  beside it, tied by a rulebook, not a string
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
  shelves on the other, a truck backing up to the door
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

### Architecture · V1 Ch 6 · Work effort (Fig 6.13)
- **Cue:** "Everything about work, from the need or the sold line that starts it to the people, hours, stock and machines it takes and what it gives, in one picture."
- **Hook:** a job ticket on a clipboard: a "why" box at the top (a need or an order line),
  sub-tasks with arrows, a roster with rates, a punch-card pocket, a parts list, a machine
  booking, and a "what came out" box at the bottom
- **Mantra:** Need and work apart. Work is broken down, staffed and priced, timed, fed stock
  and machines; its kind holds the standards, and it records what came out.

<details><summary>Key</summary>

- **S:** `work_requirement` (Ch 4's requirement, work kind) and `work_effort` (a level and a
  purpose), with `work_effort_type` as the catalogue of kinds of work.
- **W:** needs reach work through WORK REQUIREMENT FULFILLMENT, sold WORK lines through WORK
  ORDER ITEM FULFILLMENT (6.3a kept); WORK EFFORT ASSOCIATION breaks work down and orders
  it, a STATUS history tracks it; PARTY ASSIGNMENTs staff it, rates price them, TIME ENTRYs
  on WORKER timesheets time it; INVENTORY and FIXED ASSET ASSIGNMENTs feed it; the type's
  standards plan it; the produced links and the repair line record its results.
- **T:** *(the naive-model trap until practice gives yours)* one `job` table with an
  assignee, an hours column, a materials text and an order number: it breaks when one need
  takes two runs, a person comes back after a holiday, or a machine is double-booked.
- **D:** **requirement** ← work_requirement_fulfillment → work_effort; **order_item** ←
  work_order_item_fulfillment → work_effort; work_effort ↔ work_effort_association;
  work_effort ← work_effort_status → **status_type**; work_effort ←
  work_effort_party_assignment → **party**, **facility** (← work_effort_assignment_rate);
  **party** ← party_rate, party_skill; position_type ← position_type_rate; timesheet →
  **party_role** (WORKER) ← time_entry → work_effort; work_effort ←
  work_effort_inventory_assignment → **inventory_item**; work_effort ←
  work_effort_fixed_asset_assignment → **fixed_asset** → **unit_of_measure**;
  work_effort_type ← skill, **good** and fixed asset type standards; work_effort ←
  inventory and deliverable produced. Bold = from Ch 2, 3, 4 and 5. Kept: every submodel;
  6.3b dropped.
</details>

---

### Architecture · V1 Ch 7 · Invoicing (Fig 7.10)
- **Cue:** "Everything about a bill, from what it charges for and who it goes to, to how it's paid and banked, in one picture."
- **Hook:** an invoice in the middle of a corkboard: strings out to the delivery notes,
  timesheets and orders behind its lines, an address label and an account card above, a
  status stamp and small print in the corner, and checks clipped below, heading for a bank
  slip
- **Mantra:** Typed lines point back at what caused them; parties and accounts are billed;
  status and terms ride along; payments apply, then bank.

<details><summary>Key</summary>

- **S:** `invoice` and `invoice_item` (typed, with adjusted-by and sold-with) as the hubs.
- **W:** lines bill products and features (Ch 3) and link back to order items (Ch 4),
  shipment items (Ch 5), work efforts and time entries (Ch 6); the invoice is billed from a
  party to a party or a BILLING ACCOUNT, addressed and sent through contact mechanisms (Ch
  2), with INVOICE ROLEs, a STATUS history and TERMs; PAYMENTs apply to invoices or on
  account, and are banked as FINANCIAL ACCOUNT TRANSACTIONs on FINANCIAL ACCOUNTs.
- **T:** *(the naive-model trap until practice gives yours)* one `invoice` with customer,
  address, tax, freight, status, terms and paid-amount columns and lines with one product
  each: it breaks on a second fee, an e-mailed bill, a household account, a partial payment
  or a deposit slip.
- **D:** invoice ← invoice_item → invoice_item_type, **product**, **product_feature**;
  invoice_item ← order, shipment, work effort and time entry billing → **order_item**,
  **shipment_item**, **work_effort**, **time_entry**; invoice → **party** (from, to) |
  billing_account (← billing_account_role → **party**), → **contact_mechanism**; invoice ←
  invoice_role, invoice_status (→ **status_type**), invoice_term (→ **term_type**); invoice |
  billing_account ← payment_application → payment → **party**, payment_method_type,
  financial_account_transaction → financial_account ← financial_account_role. Bold = from
  Ch 2 to 6. Kept: 7.1a, 7.3a, 7.8a; 7.1b, 7.3b, 7.8b dropped.
</details>

---

### Architecture · V1 Ch 8 · Accounting and budgeting (Fig 8.12)
- **Cue:** "Every business event in the books, and every plan for money, in one picture: how do they meet?"
- **Hook:** a ledger book open on the left, debits and credits in two columns that add up,
  a budget binder open on the right with stamped and red-pencilled lines, and a row of
  checks and purchase orders between them, each clipped to a budget line and stamped with
  an account number
- **Mantra:** Events post balanced to organization accounts; budgets plan by item;
  spending draws on items; item types map to accounts.

<details><summary>Key</summary>

- **S:** ACCOUNTING TRANSACTION (with TRANSACTION DETAIL) and BUDGET (with BUDGET ITEM) as
  the hubs; GENERAL LEDGER ACCOUNT between them.
- **W:** an internal organization switches chart accounts on through ORGANIZATION GL
  ACCOUNT (broken down by supplier, customer, product category) and cuts its time into
  ACCOUNTING PERIODs; every event (an invoice or payment from Ch 7, a variance, a
  DEPRECIATION of a FIXED ASSET) is an ACCOUNTING TRANSACTION, internal or external, posted
  as balanced details; a BUDGET for a party and a STANDARD TIME PERIOD carries STATUS,
  REVIEW, revisions and SCENARIO APPLICATIONs; requirements, order items and payments draw
  on BUDGET ITEMs; GL BUDGET XREF maps item types to GL accounts.
- **T:** *(the naive-model trap until practice gives yours)* a `ledger` table with date,
  account name and amount, and a budget spreadsheet with a "spent" column: no balancing,
  no shared chart, no tie from a check to the line it pays for or to the account it hits.
- **D:** **party** (internal organization) ← organization_gl_account (↺ subsidiary) →
  general_ledger_account → gl_account_type, → **party role** (supplier, bill-to customer),
  **product_category**; accounting_period (↺) → **party**, period_type;
  accounting_transaction (internal: depreciation → **fixed_asset**; external → **party** ×2)
  ← transaction_detail (↺ associated) → organization_gl_account; budget (↺ 8.7a's loop) →
  standard_time_period ← budget_item → budget_item_type ← gl_budget_xref →
  general_ledger_account; budget ← status, review, role (→ **party**), scenario
  application; budget_item ← **requirement** and **payment** allocations. Bold = from Ch 2
  to 7. Kept: 8.3a (no stored balance); 8.12 draws 8.7a where 8.7b is built (to settle).
</details>

---

### Architecture · V1 Ch 9 · Human resources (Fig 9.14)
- **Cue:** "From application to exit: how do the job, the person and the deal between them hang together?"
- **Hook:** an org chart of boxes on the left (each with a price ruler and a budget tag),
  a person on the right holding an envelope, a diploma and a badge, and between them a
  signed contract (the employment) with pay slips, a health card, report cards and, at
  the bottom, an exit door, while a rope (the fulfillment) ties the person into one box

- **Mantra:** Slots are typed and funded; persons apply and fill them; the employment
  carries pay, benefits and its end.

<details><summary>Key</summary>

- **S:** EMPLOYMENT (Ch 2's party relationship, internal organization → employee) and
  POSITION (a slot, typed by POSITION TYPE) as the hubs; the PERSON and the EMPLOYEE role
  around them.
- **W:** POSITION TYPE carries responsibilities, classes, union and pay band (rate or
  grade step); POSITION is funded by a Ch 8 budget item. A PERSON applies (backed by
  skills, qualifications, training, resumes); hiring opens an EMPLOYMENT and a POSITION
  FULFILLMENT; slots report to slots. PAY HISTORY and PARTY BENEFIT hang on the
  employment; PAYROLL PREFERENCEs and PAYCHECKs (Ch 7 payments, with deductions) on the
  employee role; REVIEWs and NOTES from a MANAGER feed pay, bonus or a new slot; the
  employment ends with a type, a reason and any claim.
- **T:** *(the naive-model trap until practice gives yours)* 9.1's EMP and DEPT: title,
  salary, manager and hire date as columns on the person, overwritten at every change, no
  slot without a holder, no applicant before hire, nothing left after exit.
- **D:** **party_role** (Ch 2: internal organization, employee, manager) ←
  **party_relationship** (EMPLOYMENT) ← pay_history, party_benefit,
  employment_termination, unemployment_claim; employee role ← payroll_preference,
  paycheck (→ **payment**, Ch 7) ← deduction, performance_review, performance_note;
  **position_type** (Ch 6) ← valid_responsibility, position_type_class,
  position_type_rate (→ salary_step → pay_grade); position → position_type,
  **budget_item** (Ch 8), **organization** (Ch 2) ← position_responsibility,
  position_reporting_structure ×2, position_fulfillment (→ **person**),
  employment_application (→ **person**); **party** ← party_skill (Ch 6),
  party_qualification, resume; **person** ← person_training. Bold = from Ch 2 to 8. Kept:
  9.12a over 9.12b.
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
- **P4 · Effectivity dates, bitemporal when corrections matter: valid time (when it held in the business) and recorded time (when the database believed it).** Cue: "It was true then, it isn't now."
- **P5 · Self-referencing link (from / to, rollup).** Cue: "A thing related to another of its own kind."
- **P6 · Rules as rows.** Cue: "Which combinations are allowed, without a code change."
- **P7 · Exclusive arc.** Cue: "Here or there, never both, never neither."
- **P8 · Catalogue vs physical instance.** Cue: "One description, many things you can count on the shelf."

---

## Log

| Date | Card | Grade | Box | Note |
|---|---|---|---|---|
| | | | | |
