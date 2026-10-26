# Vol 1, Chapter 4 — Ordering Products

## The problem this pattern solves
A naive order system keeps two worlds side by side: sales orders with their customer and
line items, and purchase orders with their supplier and line items (Fig 4.1). The two are
copies, so every rule, report and fix is written twice, and a company that both buys from us
and sells to us is two unrelated records. Each new party the business wants on an order (who
pays, where it ships, who sold it) becomes one more column. Ch 4 merges the two into one
ORDER with subtypes, lets an item name a product *or* one of its features, and attaches the
parties through Ch 2's party roles and contact mechanisms. The recurring moves: a supertype
for things that share their structure, the order item as a snapshot of what was agreed (not a
lookup into the price list), and roles instead of party columns.

## Submodels (proposed 2026-10-18, from the figures shared so far)
1. **Orders, items and order parties** (Figs 4.1–4.5): what was ordered, in which direction
   (sales or purchase), at what price, and who placed, took, pays for and receives it?

2. **Order adjustments** (Fig 4.6): what changes the order's price besides quantity × unit
   price (discounts, surcharges, sales tax, freight, fees), on the whole order or on one
   line, and which tax rate applies where?

3. **Order status, terms and item associations** (Figs 4.7–4.8): where does an order or one
   of its lines stand, under which agreed conditions, and which purchase line will fill a
   sales line we can't fill from stock?

4. **Requirements** (Fig 4.9): what is needed, by whom, by when and where, broken down how,
   and which order lines commit to filling it, for how much?

5. **Requests and quotes** (Figs 4.10–4.11): whom did we ask (or who asked us) for
   information, proposals or prices, about which needs, what did each answer quote, and
   which quote became an order?

6. **Agreements** (Figs 4.12–4.13): which standing agreements do we have, with whom and in
   which roles, formalizing which relationship, in force when, and which of their clauses
   (sections, pricing programs, exhibits) apply to which organizations, products and places,
   as amended by which addenda?

7. **Agreement terms and pricing** (Figs 4.14–4.16): under which terms (legal, financial,
   incentives, thresholds) and at which prices did we agree to trade, on the whole agreement
   or one item, in force when, and which of them govern a given order line, when no line
   joins an order to its agreement? (Split from submodel 6: point 29.)

Figures that answer the same questions as an existing submodel joined it (4.4 and 4.5 joined
submodel 1). Fig 4.17, the overall order model, is the chapter's architecture figure: no
SQL, a **How it flows**, and a card of its own.

## Figures

### Fig 4.1 — Standard order model
**Transcription** (accepted: ☐; open points under "To check against the book")

```
SALES ORDER
  # sales_order_id
  -> CUSTOMER               (many "placed by" 1 customer; customer "the placer of" many)

SALES ORDER LINE ITEM        (no attributes drawn)
  -> SALES ORDER            (many "part of" 1 order, bar: part of the identifier;
                             order "detailed by" many)
  -> PRODUCT                (many "defined using" 1 product; product "used on" many)

PURCHASE ORDER
  # purchase_order_id
  -> SUPPLIER               (many "placed with" 1 supplier; supplier "the fulfiller of" many)

PURCHASE ORDER LINE ITEM     (no attributes drawn)
  -> PURCHASE ORDER         (many "part of" 1 order, bar; order "detailed by" many)
  -> PRODUCT                (many "defined using" 1 product; product "used on" many)

PRODUCT
  # product_code
  * description

CUSTOMER
  # customer_id

SUPPLIER
  # supplier_id
```

**Table 4.2** (order items, the book's sample, in our words): order 12560 has three items,
numbered 1 to 3: 10 reams of the Johnson bond paper at 8.00, 4 Goldstein Elite pens at 12.00
and 6 boxes of Jerry's 3½-inch diskettes at 7.00. Its columns are order id, item id, product,
quantity and unit price, which is what a line item holds although the figure draws none.

**To check against the book**
- Optionality: the photo is too faint to tell solid from dashed. Read as: each line item is
  part of exactly one order and names exactly one product; each order has exactly one customer
  or supplier; the "one" ends are optional (a product needn't be on any order).
- The bar ("~" in the photo) read on both "part of" lines, so a line item is numbered within
  its order (Table 4.2's item ids 1–3 under order 12560).

**Discussion**
- **The book's own straw man.** It's the model most order systems start with, shown so that
  Fig 4.2 can replace it. It isn't built (STATUS.md: not built); see Design decisions.
- **What breaks:**
  - *Two of everything.* "Every order for the pen" is a union of two structures, and a rule
    about line items (a quantity must be positive, a discontinued product can't be ordered) is
    written twice and drifts.
  - *Customer and supplier as entities* repeat the mistake Ch 2 removed: they are roles a
    party plays. Contoso, our supplier since 2016 and our customer since 2021, would be one
    SUPPLIER row and one CUSTOMER row with nothing tying them together.
  - *One party per order.* The customer who places the order is assumed to be the one who
    pays and receives it. When a person orders for a company that pays and a depot that
    receives, the model has no place for three parties.
  - *Nothing below a line.* A copier ordered with a duplex unit has no way to say the duplex
    unit belongs to the copier's line.

### Fig 4.2 — Orders and order items
**Transcription** (accepted: ☐; open points under "To check against the book")

```
ORDER
  # order_id
  * order_date
  o entry_date
  subtypes: SALES ORDER, PURCHASE ORDER

ORDER ITEM
  # order_item_seq_id
  o quantity
  o unit_price
  o estimated_delivery_date
  o shipping_instructions
  o item_description
  o comment
  subtypes: PURCHASE ORDER ITEM, SALES ORDER ITEM (o corresponding_po_id)
  -> ORDER            (many "part of" 1 order, bar: part of the identifier;
                       order "composed of" many)
  -> PRODUCT          (many "for" 1 product, optional; product "ordered via" many)
  -> PRODUCT FEATURE  (many "for" 1 feature, optional; feature "ordered via" many)
  -> ORDER ITEM       (recursive, optional both ways: an item "ordered for" one other item;
                       an item "ordered with" many)

PRODUCT               (from Ch 3, Fig 3.1, with the same attributes)
PRODUCT FEATURE       (from Ch 3, Fig 3.4, with its subtypes: product quality, color,
                       dimension (* number_specified), size, brand, software feature,
                       hardware feature, billing feature, other feature)
```

**Tables 4.3 and 4.4** (the book's samples, in our words; shared after the figure was built)
- *Table 4.3, sales and purchase orders:* 12560 is a sales order of June 8, 2001, with Table
  4.2's three lines. 23000 is a sales order of September 5, 2001: ten "George's Elite pens" at
  11.00. A2395 is a purchase order of July 9, 2001: twelve hours of an hourly office cleaning
  service at 15.00, and one basic cleaning supplies kit at 10.00.
- *Table 4.4, features on items:* 12560 again, numbered 1 to 5 this time. Line 1 is the bond
  paper. Lines 2 and 3 are features ordered for line 1: a gray colour at no price, and an extra
  glossy finish (product quality) at 2.00. Line 4 is the Goldstein pen with blue beside it,
  and line 5 the diskettes. A2395's line 1, the cleaning service, carries a billing feature
  (charged automatically to a credit card).

**To check against the book**
- No arc drawn across the two "for" lines (product, feature). Read as Silverston's intention
  all the same: an item names a product *or* a feature, and a feature's item is "ordered for"
  the product's item. An item may name neither when its description says what it is (a
  one-off). Points to discuss, point 2.
- Table 4.4, as photographed, puts the pen's blue and A2395's billing feature on the
  product's own line, while the paper's gray and glossy finish get lines of their own. If
  that's what the book means, an item may name a product *and* one feature, and our "both or
  nothing" check flags two of the book's rows. The photo is curved, so the row lines are
  uncertain. Point 2 now carries this.
- Table 4.4 numbers 12560's lines 1 to 5, where Tables 4.2 and 4.3 have 1 to 3. Read as a
  separate illustration of feature items, not the same order's later state. The seed keeps
  Table 4.2's three lines.
- Table 4.3's "George's Elite pen" read as a misprint for the Goldstein Elite pen.
- The recursive line: read as each item "ordered for" at most one other item, and an item
  "ordered with" many (the copier's item has its options under it). Dashed at both ends.
- Both "for" lines read as dashed at the item end too, which is what lets an item name only
  one of them.
- CORRESPONDING PO ID read as the customer's own purchase order number for that line.
- The ORDER and ORDER ITEM subtypes read as exclusive (drawn as boxes inside the supertype).

**Discussion**
- **One ORDER for both directions.** What sales and purchase orders share (a date, items,
  products, quantities, prices) lives once; the subtype says which way the goods go. "Every
  order for the pen" is now one query, and a rule about items is written once.
- **An item is numbered within its order** (the bar on "part of"): line 1, 2, 3 of order
  12560, as on the paper form.
- **The unit price is a snapshot, not a lookup.** Ch 3's price components are rules that say
  what we *would* charge under which conditions; the order item records what was *agreed*
  that day. Price lists change and orders mustn't, and a negotiated price follows no rule.
  The "agreed vs list" query shows the two side by side. (Ponder 1.)
- **A feature gets its own item,** "ordered for" the product's item. The copier's duplex unit
  and stapling finisher each have their own quantity and price, and the order reads as a
  tree: the copier, with its options under it. A pen in blue is a pen item with a Blue item
  under it, at no extra charge. (Ponder 2.)
- **The description** covers what isn't in the catalogue (an engraved pen set made once for
  one customer) and lets a line print differently from the product's name. Our reading: the
  figure only shows the attribute.
- **Per item, not per order:** the estimated delivery date and the shipping instructions,
  because lines can arrive separately; and the customer's PO number, because one sales order
  can fill lines from several of the customer's purchase orders.
- **From Ch 3:** PRODUCT and PRODUCT FEATURE; and PRODUCT FEATURE APPLICABILITY (3.4), which
  says which features a product can take, so a feature item has a rule to respect.

### Fig 4.3 — Sales order parties and contact mechanisms
**Transcription** (accepted: ☐; two photos of one landscape page; open points under "To
check against the book")

```
ORDER                        (as 4.2; only the SALES ORDER subtype drawn)
  -> ORDER ITEM              (order "composed of" many; item "part of" 1, bar)

SALES ORDER
  -> PLACING CUSTOMER        (many "placed by" 1 role; role "the placer of" many)
  -> INTERNAL ORGANIZATION   (many "taken by" 1 role; role "the fulfiller of" many)
  -> BILL TO CUSTOMER        (many "with a requested bill to" 1 role;
                              role "the requested bill to" many)
  -> CONTACT MECHANISM       (many "placed using" 1; mechanism "a placer's location for" many)
  -> CONTACT MECHANISM       (many "taken via" 1; mechanism "the location for taking" many)
  -> CONTACT MECHANISM       (many "designated to be billed to" 1;
                              mechanism "the billing location for" many)

ORDER ITEM                   (as 4.2, drawn without item_description)
  subtype SALES ORDER ITEM (o corresponding_po_id)
    -> SHIP TO CUSTOMER      (many "designated to be shipped to" 1 role;
                              role "the requested ship to" many)
    -> CONTACT MECHANISM     (many "designated to be shipped to" 1;
                              mechanism "the shipping location for" many)

ORDER ROLE
  o percent_contribution
  -> ORDER                   (many "of" 1 order, bar; order "involving" many)
  -> PARTY                   (many "involving" 1 party; party "involved in" many)
  -> ORDER ROLE TYPE         (many "described by" 1 type, bar; type "the description for" many)

ORDER ROLE TYPE              (no attributes drawn)

PARTY ROLE                   (from Ch 2, Fig 2.4)
  # party_role_id
  subtypes: SHIP TO CUSTOMER, PLACING CUSTOMER, INTERNAL ORGANIZATION, BILL TO CUSTOMER
  -> PARTY                   (many "for" 1 party, bar; party "acting as" many)

PARTY                        (from Ch 2; subtypes ORGANIZATION, PERSON)
  # party_id

CONTACT MECHANISM            (from Ch 2, Fig 2.9)
  # contact_mechanism_id
```

**Tables 4.5 and 4.6** (the book's samples, in our words; shared after the figure was built)
- *Table 4.5, order roles and contact mechanisms:* ACME Company places 12560 from 234 Stretch
  Street, ABC Subsidiary takes it at 100 Main Street, and ACME is billed at 234 Stretch
  Street. Lines 1 and 2 ship to ACME at 2300 Drident Avenue, line 3 to 234 Stretch Street.
  Jones Corporation places 23000 from 900 Washington Blvd; ABC Subsidiary takes it through
  supplies@ABC.com; Smith Corporation is billed at 900 Washington Blvd; the line ships to
  Jones at 2300 Drident Avenue. 24830 is placed from Bob Ford's e-mail address, taken through
  supplies@ABC.com, and billed and shipped to Bob Ford at 2930 Briarwood Avenue. A2395 is
  listed too (see Table 4.7 under Fig 4.4).
- *Table 4.6, other order roles:* five people on 12560: two salespeople at 50% each, a
  processor, a reviewer and an authorizer.

**To check against the book**
- Table 4.5 confirms our readings: a bill-to that isn't the placer (Smith pays for Jones's
  order), a ship-to per line (12560's lines go to two addresses), and contact mechanisms of
  any kind (an order placed from an e-mail address, taken through an e-mail inbox).
- Table 4.5 lists A2395, a purchase order, under the sales roles' headings. Read as the
  book's slip: Table 4.7 gives it again with the buyer's role names.
- 23000 ships to 2300 Drident Avenue, ACME's delivery address on 12560. Read as a copy slip
  in the table, or a shared site; nothing in the model forbids it, and our "for review" query
  would list it.
- Table 4.6's processor and authorizer are ORDER ROLE TYPEs we don't seed (ours: entered by,
  approver, reviewer). Its 50/50 salespeople are the PERCENT CONTRIBUTION we read.
- Optionality: the photos don't show solid vs dashed reliably. Every line from SALES ORDER
  and SALES ORDER ITEM read as optional at the order end (points to discuss, point 3); the
  role and mechanism ends as optional (a role needn't be on any order).
- Both ship-to lines read as leaving SALES ORDER ITEM (one from its top edge to CONTACT
  MECHANISM, one from its bottom edge to SHIP TO CUSTOMER), not SALES ORDER.
- Which party role answers which line, read from the label pairs: "placed by" ↔ "the placer
  of" (PLACING CUSTOMER), "taken by" ↔ "the fulfiller of" (INTERNAL ORGANIZATION), "with a
  requested bill to" ↔ "the requested bill to" (BILL TO CUSTOMER).
- ORDER ROLE's two "involving" labels read as one at the ORDER end (order "involving" roles)
  and one at the ORDER ROLE end (role "involving" a party). Bars seen on "of" and "described
  by"; the PARTY line's bar unclear (point 4).
- ITEM DESCRIPTION and the PRODUCT / FEATURE lines are missing from ORDER ITEM here. Read as
  abbreviation: the figure is about parties.

**Discussion**
- **Four jobs, often four parties.** Someone places the order, one of our organizations takes
  it, someone pays, and someone receives the goods. In the seed, Ben (a person) places an
  order for Contoso, Contoso pays, Contoso's addresses receive it, and Northwind takes it.
  Fig 4.1's one CUSTOMER can't say that.
- **The lines point at PARTY ROLE, not at PARTY.** The order names "Contoso as bill-to
  customer", the dated role row from Ch 2. So the order states which hat the party wears, and
  a check can ask whether the party held that role on the order date. Ch 2's PARTY ROLE
  subtypes gain one: PLACING CUSTOMER. (Ponder 3.)
- **Three contact mechanisms on the order, one on the item:** how it was placed (Contoso's
  sales inbox), where we took it (our website or a phone line), where the bill goes, and per
  item where it ships. They point at CONTACT MECHANISM, not POSTAL ADDRESS: an order comes in
  by phone, e-mail or the web, and a bill can go by e-mail.
- **Bill-to on the order, ship-to on the item:** one bill, many destinations. Order 12561's
  copier goes to Contoso's office and its paper to the St. Louis depot. A feature item ships
  with the item it's ordered for.
- **Specific lines and a generic ORDER ROLE, side by side.** The parties every sales order
  has get lines of their own (one each, a column, easy to query). The open-ended rest
  (salespeople, the clerk who keyed it in, an approver) go through ORDER ROLE, a party plus a
  type, so a new kind of order party is a new row, not a new column. It's Ch 2's specific vs
  generic trade-off (Figs 2.5 and 2.6a) used together. The cost: "every party on this order"
  is a union of both (a query below).
- **ORDER ROLE names a PARTY and a type, not a PARTY ROLE:** being an order's salesperson is a
  role within that one order, so it isn't kept as a dated role of the party. It hangs on
  ORDER, so purchase orders have order roles too (the seed's approver).
- **PERCENT CONTRIBUTION** shares a role out among parties: Chloe and Ana split the copier sale
  60/40. Our rule: within one order and type, the shares add up to at most 100.
- **Only the sales side is drawn.** Purchase orders have no party lines in this figure.

### Fig 4.4 — Purchase order parties and contact mechanisms
**Transcription** (accepted: ☐; one landscape photo; open points under "To check against the
book")

```
ORDER                        (as 4.2; only the PURCHASE ORDER subtype drawn)
  -> ORDER ITEM              (order "composed of" many; item "part of" 1, bar)

PURCHASE ORDER
  -> PLACING BUYER           (many "placed by" 1 role; role "the placer of" many)
  -> SUPPLIER                (many "taken by" 1 role; role "the fulfiller of" many)
  -> BILL TO PURCHASER       (many "with a requested bill to" 1 role;
                              role "the requested bill to" many)
  -> CONTACT MECHANISM       (many "placed using" 1; mechanism "a placer's location for" many)
  -> CONTACT MECHANISM       (many "taken via" 1; mechanism "the location for taking" many)
  -> CONTACT MECHANISM       (many "designated to be billed to" 1;
                              mechanism "the billing location for" many)

ORDER ITEM                   (as 4.2, drawn without the product and feature lines)
  subtype PURCHASE ORDER ITEM (o item_description)
    -> SHIP TO BUYER         (many "designated to be shipped to" 1 role;
                              role "the requested ship to" many)
    -> CONTACT MECHANISM     (many "designated to be shipped to" 1;
                              mechanism "a shipping location for" many)

ORDER ROLE                   (as 4.3: o percent_contribution; "of" ORDER, bar; "involving"
                              PARTY; "described by" ORDER ROLE TYPE, bar)
ORDER ROLE TYPE              (no attributes drawn)

PARTY ROLE                   (from Ch 2, Fig 2.4)
  # party_role_id
  subtypes: SHIP TO BUYER, PLACING BUYER, SUPPLIER, BILL TO PURCHASER
  -> PARTY                   (many "for" 1 party, bar; party "acting as" many)

PARTY                        (from Ch 2; subtypes ORGANIZATION, PERSON)
CONTACT MECHANISM            (from Ch 2, Fig 2.9)
```

**Table 4.7** (the book's sample, in our words; shared after the figure was built): purchase
order A2395 is placed by ABC Subsidiary from 100 Main Street, taken by Ace Cleaning Service
at 3590 Cottage Avenue, and billed to ABC Corporation at 100 Main Street. Both lines ship to
ABC Retail Store at 2345 Johnson Blvd.

**To check against the book**
- Table 4.7's buyer roles are all played by ABC's own organizations (the parent, the
  subsidiary, a store): evidence for point 7, that buyer roles belong to the enterprise.
- Fig 4.3 turned over: the same six lines on the order and two on the item, with the
  purchase side's role names. Optionality read as in 4.3 (every line optional).
- PURCHASE ORDER ITEM is drawn with its own ITEM DESCRIPTION, while ORDER ITEM keeps one
  too (as in 4.2 and 4.5; 4.6 draws it on ORDER ITEM only). Read as one attribute, ORDER
  ITEM's (points to discuss, point 6).
- Both ship-to lines read as leaving PURCHASE ORDER ITEM, as 4.3's leave SALES ORDER ITEM.
- Which role answers which line, from the label pairs: "placed by" ↔ "the placer of"
  (PLACING BUYER), "taken by" ↔ "the fulfiller of" (SUPPLIER), "with a requested bill to" ↔
  "the requested bill to" (BILL TO PURCHASER), "designated to be shipped to" ↔ "the requested
  ship to" (SHIP TO BUYER).

**Discussion**
- **The same four jobs, with the hats swapped.** On a purchase order *we* place the order
  (a buyer: our purchasing department, or one person in it), the supplier takes and fulfils
  it, we get the bill, and each item comes to one of our sites. In the seed, Chloe places
  order 12564 for Northwind with Fantastic Supplies; the paper goes to the Chatham warehouse
  and the books to the office.
- **New role types, grouped like the customer's.** PLACING BUYER, BILL TO PURCHASER and SHIP
  TO BUYER sit under a new BUYER grouping, the mirror of Ch 2's CUSTOMER; SUPPLIER is Ch 2's.
  A person can be a placing buyer (Chloe), so those roles take either kind of party.
- **Fig 4.1's twin problem comes back one level down.** 4.2 merged the two orders, but the
  party lines are copied: `sales_order` and `purchase_order` have the same six columns, and
  every party check is written twice (the 4.4 queries are 4.3's on the other table).
  Silverston accepts it here because each line expects a different role, and each subtype
  stays easy to read. Fig 4.5 is his way out when the copying starts to hurt. (Ponder 4.)
- **One party, both directions.** Contoso is our customer and our freight supplier. Its
  orders both ways come from its party roles, one per hat (a query below), and putting the
  wrong hat on an order (12569 "taken by" Contoso as *bill-to customer*) is caught.
- **Drop shipping.** Order 12568 buys the copier we sold Contoso on 12561, and Fantastic
  Supplies delivers it straight to Contoso's office. The ship-to role is still ours (we are
  the buyer), the address is Contoso's: allowed, and flagged for review. Nothing yet links
  that purchase line to the sales line it fills.
- **ORDER ROLE is drawn again,** unchanged: purchase orders have approvers too (12564's).

### Fig 4.5 — Generic order roles and contact mechanisms
**Transcription** (accepted: ☐; one upright photo; open points under "To check against the
book")

```
ORDER                        (as 4.2; subtypes SALES ORDER, PURCHASE ORDER, no lines of their own)
  -> ORDER ITEM              (order "composed of" many; item "part of" 1, bar)

ORDER ITEM                   (as 4.2, drawn without the product and feature lines)
  subtypes SALES ORDER ITEM (o corresponding_po_id), PURCHASE ORDER ITEM (o item_description)

ORDER ROLE
  o percent_contribution
  -> ORDER                   (many to 1 order; order "involving" many)
  -> PARTY                   (many "assigned to" 1 party; party "involved in" many)
  -> ORDER ROLE TYPE         (many "described by" 1 type, bar; type "the description for" many)

ORDER ITEM ROLE              (no attributes drawn)
  -> ORDER ITEM              (many "of" 1 item, bar; item "involving" many)
  -> PARTY                   (many "assigned to" 1 party, bar; party "involved in" many)
  -> ORDER ITEM ROLE TYPE    (many "described by" 1 type, bar; type "the description for" many)

ORDER CONTACT MECHANISM      (no attributes drawn)
  -> ORDER                   (many "used with" 1 order, bar; order "having" many)
  -> CONTACT MECHANISM       (many "assigned to" 1, bar; mechanism "used in" many)
  -> CONTACT MECHANISM PURPOSE TYPE (many "used for" 1, bar; type "for" many)

ORDER ITEM CONTACT MECHANISM (no attributes drawn)
  -> ORDER ITEM              (many "used with" 1 item, bar; item "having" many)
  -> CONTACT MECHANISM       (many "assigned to" 1, bar; mechanism "used in" many)
  -> CONTACT MECHANISM PURPOSE TYPE (many "used for" 1, bar; type "for" many)

ORDER ROLE TYPE, ORDER ITEM ROLE TYPE   (no attributes drawn)
CONTACT MECHANISM PURPOSE TYPE          (from Ch 2, Fig 2.10)
  # contact_mechanism_purpose_type_id
  * description
CONTACT MECHANISM, PARTY                (from Ch 2)
```

**To check against the book**
- ORDER ROLE's label at its ORDER end isn't visible; read as 4.3's "of", with its bar.
- Bars read on all three lines of ORDER ITEM ROLE and of both contact mechanism entities
  (the marks are small). ORDER ROLE's party line: unclear, as in 4.3 (point 4).
- CONTACT MECHANISM PURPOSE TYPE read as Ch 2's entity, reused: same name, same attributes.
- SALES ORDER and PURCHASE ORDER have no lines here: read as 4.5 *replacing* the specific
  lines of 4.3 and 4.4, the alternate the text offers when the roles may change.
- PURCHASE ORDER ITEM is again drawn with ITEM DESCRIPTION (point 6).

**Discussion**
- **One shape for every party and every mechanism, in both directions.** On the order, ORDER
  ROLE (a party and a type) and ORDER CONTACT MECHANISM (a mechanism and a purpose); on the
  item, ORDER ITEM ROLE and ORDER ITEM CONTACT MECHANISM. The twelve party and mechanism
  columns of 4.3 and 4.4 become four tables that sales and purchase orders share: a placer is
  a placer either way, and the order's kind says which side is ours.
- **What it gains.** A new kind of order party or mechanism is a row, not a column: the book on
  order 12571 is a gift for Kiri (an item's *end user*), Ana installs 12561's copier (an
  *installer*), and the courier calls Kiri's number (a *delivery contact*). The twin checks of
  4.3 and 4.4 collapse into one.
- **What it loses.** A column holds one value and a typed FK; rows hold any number. "One
  bill-to per order" becomes a check (seed: 12571 billed to the family *and* to Ana). And ORDER
  ROLE names a PARTY, not a PARTY ROLE: whether the party was a customer at the time is no
  longer asked. Every report turns rows back into columns.
- **The purposes are Ch 2's.** CONTACT MECHANISM PURPOSE TYPE already says why a party has a
  mechanism (billing, shipping); the order reuses the list and adds order placing, order
  taking and delivery contact.
- **Each row is identified by its three parents** (the bars): a party can hold two roles on one
  item, but not the same one twice.
- **When not to:** an order system whose parties never change shape is easier to read, check
  and query with 4.3's columns. 4.5 earns its keep when new order parties keep arriving, or
  when sales and purchase orders must be handled by the same code.

### Fig 4.6 — Order adjustments
**Transcription** (accepted: ☐; one landscape photo; open points under "To check against the
book")

```
ORDER ADJUSTMENT
  # order_adjustment_id
  o amount
  o percentage
  subtypes: DISCOUNT ADJUSTMENT, SURCHARGE ADJUSTMENT, SALES TAX, SHIPPING AND HANDLING
            CHARGE, FEE, MISCELLANEOUS CHARGE
  -> ORDER ITEM              (many "affecting" 1 item; item "affected by" many)
  -> ORDER                   (many "affecting" 1 order, dashed; order "affected by" many)
  -> ORDER ADJUSTMENT TYPE   (many "described by" 1 type; type "the description for" many)

ORDER ADJUSTMENT TYPE
  # order_adjustment_type_id
  * description

SALES TAX LOOKUP
  # sales_tax_seq_id
  * sales_tax_percentage
  -> GEOGRAPHIC BOUNDARY     (many "for" 1 boundary, bar; boundary "taxed via" many)
  -> PRODUCT CATEGORY        (many "specified for" 1 category;
                              category "a consideration for" many)

GEOGRAPHIC BOUNDARY          (from Ch 2, Fig 2.8: # geo_id, o geo_code, * name, o abbreviation;
                              subtypes drawn here: COUNTY, CITY, STATE)
PRODUCT CATEGORY             (from Ch 3, Fig 3.2: # product_category_id, * description)
ORDER, ORDER ITEM            (as 4.2; item subtypes SALES ORDER ITEM (o corresponding_po_id)
                              and PURCHASE ORDER ITEM; order "composed of" items, bar)
```

**To check against the book**
- No arc seen across the two "affecting" lines. Read as Silverston's intention all the same:
  an adjustment affects the whole order or one item, not both (point 10). The ORDER line is
  dashed; the ORDER ITEM line read as optional too, which is what lets an adjustment name only
  the order.
- No line from SALES TAX LOOKUP to ORDER ADJUSTMENT or to its SALES TAX subtype: read as a
  reference table that a sales tax adjustment copies its percentage from (point 12).
- The PRODUCT CATEGORY line read as optional: a rate for a whole boundary names no category.
  The bar on "for" makes the boundary part of the lookup's identifier, with the seq id.
- No recursion drawn on ORDER ADJUSTMENT TYPE. Read as Ch 3's cost components: the six
  subtypes are the top of the type list, and finer types sit under them.
- PURCHASE ORDER ITEM drawn with no attribute here, and ORDER ITEM keeps ITEM DESCRIPTION:
  the reading of point 6.

**Discussion**
- **The problem.** An order's price is more than quantity × unit price: a loyalty discount,
  freight, a set-up fee, sales tax. The naive order gets a column for each (`discount`,
  `freight`, `tax`), so every new kind of charge is a schema change, two discounts don't fit,
  and a discount on one line has nowhere to go.
- **One entity for every change to the price,** typed, at either level, as an amount or a
  percentage. Order 12561: 5% loyalty discount and 150.00 freight on the whole order, a 75.00
  set-up fee and sales tax on the copier's line.
- **Which way it goes comes from the type.** A discount reduces the price, every other type
  adds; both are stored positive, as Ch 3 stored its discount components.
- **A percentage of what?** The figure doesn't say what a percentage is taken from, or in
  which order adjustments apply (is tax charged on the discounted price?). Our queries take
  each one of the value before any adjustment (point 11; ponder 1 of submodel 2).
- **The snapshot again.** Like the unit price (4.2), an adjustment records what was charged:
  the tax rate is copied from SALES TAX LOOKUP on the order date, so a later rate change
  doesn't rewrite old orders. That's why no line joins the two (ponder 2).
- **SALES TAX LOOKUP: a rate per place, optionally per kind of product.** A state rate, a
  city's add-on, a lower rate for paper in Missouri. The place comes from Ch 2 (the ship-to
  address's geographic boundaries) and the kind from Ch 3 (the product's categories, and the
  ones above them). The seed's rates are invented.
- **Walking up the boundaries can overreach.** Ch 2's postal code 62707 lies in Springfield
  *and* Chatham, so a Chatham address reaching its boundaries through the postal code also
  "lies in" Springfield and would pick up its city rate. Real tax engines place the exact
  address for this reason. Our tax query only meets St. Louis addresses, which are clean.
- **Purchase orders too:** the adjustment hangs on ORDER and ORDER ITEM, so a supplier's freight
  on our purchase order 12564 is the same entity.
- **Rules vs facts, as in 4.2.** Ch 3's price components say what we *would* charge (a
  discount for big orders); adjustments say what *was* charged on this order.

### Fig 4.7 — Order status and terms
**Transcription** (accepted: ☐; one landscape photo, with Table 4.9; open points under "To
check against the book")

```
ORDER STATUS
  # order_status_id
  * status_datetime
  -> ORDER                   (many "a status for" 1 order; order "in the state of" many)
  -> ORDER ITEM              (many "a status for" 1 item; item "in the state of" many)
  -> ORDER STATUS TYPE       (many "described by" 1 type; type "the description for" many)

ORDER STATUS TYPE            (no attributes drawn)

ORDER TERM
  # order_term_id
  * term_value
  -> ORDER                   (many "a condition for" 1 order; order "subject to" many)
  -> ORDER ITEM              (many "a condition for" 1 item; item "subject to" many)
  -> TERM TYPE               (many "described by" 1 type; type "the description for" many)

TERM TYPE
  # term_type_id
  * description

ORDER, ORDER ITEM            (as 4.2; ORDER's subtypes SALES ORDER and PURCHASE ORDER; ORDER
                              ITEM's SALES ORDER ITEM (o corresponding_po_id) and PURCHASE
                              ORDER ITEM (o item_description); order "composed of" items, bar)
```

**Table 4.9** (order terms, the book's sample, in our words): order 12560 has two terms on
the whole order, a 25% cancellation charge and 10 days in which it may be cancelled without
one. Its line 2, the Goldstein pen, has "no exchanges or refunds once delivered", with no
value. A2395's line 1, the cleaning service, has a 5% penalty the supplier pays if it fails
to perform, and 30 days in which delivery must happen.

**The text beside it**, in short: shipped, completed and invoiced can be worked out from the
shipments and invoices tied to the order, and backordered from the item association of Fig
4.8; a physical design may still list them as status types, for easy reporting.

**To check against the book**
- TERM VALUE drawn mandatory, yet Table 4.9's "no exchanges or refunds" has no value. Read as
  optional, the table's intention (point 13).
- No arc across the two "a status for" lines, nor across the two "a condition for" lines.
  Read as 4.6's adjustment: a status or a term is for the whole order or for one item, not
  both (point 14). Both lines read as optional at the status and term end.
- ORDER STATUS TYPE drawn alone with no attributes: read as another subtype of Ch 2's STATUS
  TYPE (Fig 2.7 drew it as a supertype for this), so its rows join the shared `status_type`
  (point 15).
- TERM TYPE has no ORDER in its name: read as a list meant to be shared by other kinds of
  terms later, so it gets a general name (point 15).
- No bars seen on the status and term lines: each has an id of its own, as drawn.

**Discussion**
- **Where an order stands is a history, not a column.** ORDER STATUS is one row per change,
  with the time it happened: received, approved, backordered, shipped, completed. The current
  status is the latest row, and the history answers "when was it approved?". Compare Ch 2's
  relationship status (Fig 2.7): one value, no past.
- **On the order or on one item.** Lines move separately: 12561's paper shipped on the 12th
  while the copier waited on a purchase until the 21st. An order status speaks for the whole
  order, an item status for one line.
- **Some statuses repeat facts kept elsewhere.** Shipped, invoiced and backordered follow
  from shipments (Ch 5), invoices (Ch 7) and the item association (4.8). Storing them is a
  convenience that can contradict the facts, the price Ch 2 paid for a relationship status
  beside its dates. A 4.8 query works out "a purchase stands behind this line" and catches a
  recorded backorder that no purchase line backs. (Ponder 2.)
- **Terms: the conditions agreed for this order.** A cancellation charge, a window to cancel
  for free, no refunds on one line, a penalty if the supplier fails to deliver. Each is a
  typed row with a number, on the order or on one item: the shape of 4.6's adjustments.
- **The value means something only through its type.** 25 is a percentage because the type
  says "percentage cancellation charge"; 10 is a number of days. Nothing stores the unit, so a
  query that works out a deadline has to know which types hold days. Some terms need no
  value at all. (Ponder 3.)
- **Terms, adjustments and price components differ.** An adjustment (4.6) changes what this
  order costs; a term says what is allowed or owed if something happens (a cancellation, a
  late delivery); a price component (Ch 3) is a rule for prices in general.
- **Both directions:** A2395's nonperformance penalty binds the supplier on a purchase order.

### Fig 4.8 — Order item association
**Transcription** (accepted: ☐; one landscape photo, with Table 4.10; open points under "To
check against the book")

```
ORDER ITEM ASSOCIATION       (no attributes drawn)
  -> SALES ORDER ITEM        (many "from" 1 item, bar; item "associated with" many)
  -> PURCHASE ORDER ITEM     (many "to" 1 item, bar; item "used to fulfill" many)

ORDER ITEM                   (as 4.2; subtypes SALES ORDER ITEM (o corresponding_po_id) and
                              PURCHASE ORDER ITEM, drawn with no attribute here)
  -> ORDER                   (many "part of" 1, bar; order "composed of" many)
ORDER                        (as 4.2; subtypes SALES ORDER, PURCHASE ORDER)
```

**Table 4.10** (the book's sample, in our words): one row. Line 1 of sales order 13480 is
tied to line 1 of purchase order 23490, the purchase that will supply what the sale needs.

**The text beside it**, in short: a distributor that can't fill a sales line from stock buys
the goods on a purchase order, so the sales line waits on the purchase (it's "backordered").
One purchase line may fill several sales lines, and one sales line may need several purchase
lines from different suppliers: many to many, hence the association.

**To check against the book**
- Bars read on both lines (the "~" marks): an association is identified by its two items, as
  Table 4.10's four key columns show.
- Labels read as: a sales item "associated with" many associations, a purchase item "used to
  fulfill" through many.
- The entity is named for any two order items, but its lines land on the subtypes. Read
  literally: from a sales line to a purchase line, as the text says (point 16).
- No quantity drawn: when one purchase line fills several sales lines, how many go to each is
  not recorded (point 17).

**Discussion**
- **The problem.** A sales line we can't fill from stock; we buy the goods. Which purchase
  line will fill which sales line? Without the link, "is the customer's copier on order?" has
  no answer, and when a purchase arrives late nobody knows which customers to call.
- **A many-to-many between two subtypes.** The lines land on SALES ORDER ITEM and PURCHASE
  ORDER ITEM, so the direction is part of the model: a sale is filled by a purchase. 12564's
  500 reams fill 12561's 20 and 12566's 10, and 12561's 20 are bought on 12570 as well.
- **4.4's drop ship, linked at last.** 12568 bought the copier sold on 12561, and nothing tied
  the two lines; now a row does.
- **Backordered, worked out.** A sales line with a purchase line behind it is waiting on a
  purchase, which is how the 4.7 text derives "backordered". The link alone can't say whether
  the goods have arrived: that needs shipments (Ch 5). The 4.8 queries set the link beside the
  status recorded, and catch a backorder with no purchase behind it.
- **No quantity.** Who gets how many from a purchase line that fills several sales lines? The
  association can't say, and Fig 4.9's ORDER REQUIREMENT COMMITMENT, which links an order line
  to a need, carries a quantity where this one doesn't. (Ponder 4.)

### Fig 4.9 — Requirements
**Transcription** (accepted: ☐; one landscape photo, with Table 4.11 in two photos; open
points under "To check against the book")

```
REQUIREMENT
  # requirement_id
  * description
  o requirement_creation_date
  o required_by_date
  o estimated_budget
  o quantity
  o reason
  subtypes, two sets: CUSTOMER REQUIREMENT, INTERNAL REQUIREMENT
                      PRODUCT REQUIREMENT, WORK REQUIREMENT
  -> REQUIREMENT             (recursive: many "part of" 1; one "composed of" many)
  -> FACILITY                (many "needed at" 1 facility; facility "in need of" many)

PRODUCT REQUIREMENT
  -> PRODUCT                 (many "requesting" 1 product; product "asked for via" many)

DESIRED FEATURE
  # desired_feature_id
  o optional_ind
  -> PRODUCT REQUIREMENT     (many "part of" 1, bar; requirement "specifying" many)
  -> PRODUCT FEATURE         (many "described by" 1 feature; feature "the description for" many)

REQUIREMENT STATUS
  * status_date
  -> REQUIREMENT             (many "a status for" 1; requirement "in a state of" many)
  -> REQUIREMENT STATUS TYPE (many "defined by" 1 type; type "used to define" many)

REQUIREMENT STATUS TYPE      (no attributes drawn)

REQUIREMENT ROLE
  # from_date
  o thru_date
  -> REQUIREMENT             (many "related to" 1; requirement "associated with" many)
  -> PARTY                   (many "for" 1 party; party "assigned to" many)
  -> REQUIREMENT ROLE TYPE   (many "defined by" 1 type; type "used to define" many)

REQUIREMENT ROLE TYPE
  # role_type_code
  * description

ORDER REQUIREMENT COMMITMENT
  * quantity
  -> ORDER ITEM              (many "a usage of" 1 item; item "the fulfiller of" many)
  -> REQUIREMENT             (many "the commitment of" 1; requirement "committed by" many)

ORDER ITEM                   (as 4.2; subtypes PURCHASE ORDER ITEM (o item_description) and
                              SALES ORDER ITEM (o corresponding_po_id))
PRODUCT                      (from Ch 3, Fig 3.1)
PRODUCT FEATURE              (from Ch 3, Fig 3.4)
PARTY                        (from Ch 2)
FACILITY                     (from Ch 2, Fig 2.11: # facility_id, * description, o square_footage)
```

**Table 4.11** (requirements, the book's sample, in our words):
- 24905, ABC Corporation's, April 13, 2001: repair 14 PCs.
- 43005, ABC Subsidiary's, May 16, 2002: the office cleaned on a regular basis, with two
  parts of the same day and owner, 43006 (a cleaning service) and 43007 (cleaning supplies).
- 30003, ACME's, May 15, 2001: office supplies. Its parts are ABC Subsidiary's, dated May 16,
  2002: 50 reams of bond paper (8½ by 11 inches, fine grade), 40 Goldstein Elite pens (blue),
  20 reams of copier paper (8½ by 11 inches, white), 200 diskettes (3½-inch, high density,
  formatted).
- 34988, ABC Corporation's, June 20, 2001: repair 15 PCs, listed as part of 30003.
- The PRODUCT column is empty on every row; the desired features say what's wanted.

**To check against the book**
- Two subtype sets, drawn as two boxes inside REQUIREMENT: whose need it is (customer or
  internal) and what's needed (a product or work). Fig 4.10 redraws them the same way, so the
  reading is firm: a requirement is one of each pair.
- The PRODUCT line read as leaving PRODUCT REQUIREMENT, and optional: Table 4.11 names no
  product (point 18).
- DESIRED FEATURE "part of" PRODUCT REQUIREMENT with a bar; the "specifying" end dashed.
- REQUIREMENT ROLE's lines paired from their labels: "related to" ↔ "associated with"
  (REQUIREMENT), "for" ↔ "assigned to" (PARTY). The photo is small, but either way both are
  plain FKs. Its identifier read as its three parents plus the from date.
- REQUIREMENT STATUS draws only a mandatory STATUS DATE (a date, where 4.7's order status has
  a datetime) and no id of its own: identified by its requirement, its type and the date.
- REQUIREMENT ROLE TYPE's identifier is drawn as ROLE TYPE CODE: read as the same kind of key
  as every other type's id.
- Table 4.11's "May 16 2002" rows are parts of requirements created in 2001, and ACME's request
  for quotes on them (Table 4.13) is dated March 2002. Read as misprints for May 16, 2001
  (point 19).
- Table 4.11 puts 34988 (repair 15 PCs, ABC Corporation's) under 30003 (ACME's office
  supplies). Table 4.13 asks vendors about 24905 and 34988 together (29 PCs = 14 + 15), so
  34988 is read as 24905's sibling, with no parent (point 19).
- "ACME Corporation" read as Ch 2's ACME Company; "high density" as the diskettes' 1.44 MB
  capacity; "formatted" is a feature Ch 3 lacks, added.

**Discussion**
- **The problem.** A need exists before any order: a department wants paper, a customer wants
  a copier with a duplex unit, an office needs cleaning. Jumping straight to a draft order
  loses the need itself (by when, for how much, why, who asked), and one need may take
  several orders while one order line may serve several needs.
- **REQUIREMENT is the need, in the asker's terms:** a description, a quantity, a date it's
  needed by, a budget, a reason, and where (a Ch 2 facility: the Chatham warehouse needs its
  dock door fixed).
- **Two ways to split it.** Whose need: a customer's (we sell to fill it) or our own (we buy
  or do the work). What's needed: a product, or work (Ch 6's work efforts will fill those).
  Each pair is exclusive, but the pairs are independent: a customer's work requirement is
  fine. Built as two discriminator columns. (Ponder 4.)
- **Features instead of a product.** "50 reams, 8½ by 11 inches, fine grade" is a need;
  choosing Johnson's bond paper is a buying decision. DESIRED FEATURE reuses Ch 3's PRODUCT
  FEATURE, each a must-have or optional, so a query can list the catalogue products that meet
  a need through Ch 3's feature applicability. (Ponder 2.)
- **Needs break down,** like Ch 3's categories: office supplies into paper, pens and
  diskettes; office cleaning into a service and supplies.
- **Who's involved:** REQUIREMENT ROLE (owner, requester, approver), dated, because a
  requirement can outlive the people around it. 4.3's ORDER ROLE has no dates. Another role
  type lookup (point 5).
- **Status history:** REQUIREMENT STATUS, dated, as 4.7's order status, in the same shared
  status table.
- **ORDER REQUIREMENT COMMITMENT: which order lines fill which needs, and how much.** 12560's
  10 reams fill 10 of ACME's 50; A2395's cleaning fills ABC Subsidiary's need for a cleaning
  service. A need is often filled in parts, so the commitment carries a quantity, which 4.8's
  association lacks. A customer's need is usually filled by a sales line, our own by a
  purchase line. (Ponder 3.)
- **The flow so far:** a requirement (the need) → an order line commits to it → shipments
  and invoices (Ch 5, Ch 7) follow the order.

### Fig 4.10 — Requests
**Transcription** (accepted: ☐; one landscape photo, with Tables 4.12 and 4.13; open points
under "To check against the book")

```
REQUEST
  # request_id
  * request_date
  * response_required_date
  * description
  subtypes: RFP, RFI, RFQ

REQUEST ITEM
  # request_item_seq_id
  * required_by_date
  o quantity
  o maximum_amount
  o description
  -> REQUEST                 (many "part of" 1, bar; request "composed of" many)

REQUIREMENT REQUEST          (no attributes drawn)
  -> REQUEST ITEM            (many "communicated via" 1, bar; item "the method to communicate" many)
  -> REQUIREMENT             (many "associated to" 1, bar; requirement "communicated via" many)

REQUEST ROLE                 (no attributes drawn)
  -> REQUEST                 (many "for" 1, bar; request "involving" many)
  -> PARTY                   (many "of" 1, bar; party "involved in" many)
  -> REQUEST ROLE TYPE       (many "described by" 1; type "the description for" many)

REQUEST ROLE TYPE            (no attributes drawn)

RESPONDING PARTY
  # responding_party_seq_id
  o date_sent
  -> REQUEST                 (many "for" 1, bar; request "submitted to" many)
  -> PARTY                   (many "of" 1, bar; party "the recipient of" many)
  -> CONTACT MECHANISM       (many "sent to" 1; mechanism "used to contact" many)

REQUIREMENT                  (as 4.9, both subtype sets redrawn; "part of" itself)
PARTY, CONTACT MECHANISM     (from Ch 2)
```

**Tables 4.12 and 4.13** (requests and their items, the book's samples, in our words):
- 23498: ABC Corporation's RFI of January 12, 2001, answer due February 10, 2002, asking about
  PC repair vendors. One item: 29 PCs, carrying requirements 24905 and 34988 (14 + 15).
- 38967: ABC Corporation's RFP of March 13, 2002, answer due April 23, 2002, asking vendors to
  quote for repairing the PCs. One item: 29 PCs, the same two requirements. Table 4.13 calls
  it an RFQ.
- 38948: ACME's RFQ of March 13, 2002, answer due March 21, 2002, asking for a quote on office
  supplies. Four items: 50, 40, 20 and 200, one for each of requirements 30004 to 30007.

**The text beside it**, in short: RESPONDING PARTY matters mostly for requests we send out.
One we receive usually has one responding party, the part of the enterprise that got it and
will answer. DATE SENT records when we sent the request to that party.

**To check against the book**
- REQUIREMENT REQUEST's labels read as: a requirement request is "associated to" one
  requirement and "communicated via" one request item; bars on both, so it's identified by
  the pair.
- REQUEST ROLE and RESPONDING PARTY read with bars on their REQUEST and PARTY lines;
  RESPONDING PARTY's own seq id numbers the recipients within the request.
- RFP, RFI and RFQ have no attributes or lines: Table 4.12 calls them REQUEST TYPE.
- REQUEST ITEM has no line to PRODUCT: what it asks for comes from the requirements it
  carries (and its description).
- Table 4.12 dates 23498 January 12, 2001, with an answer due thirteen months later, and
  before both requirements it carries (April and June 2001). Read as January 12, 2002 (point
  21).
- Table 4.13 calls 38967 an RFQ; Table 4.12 an RFP, and Table 4.14's proposal answers a
  request about PC repair. Read as an RFP (point 21).
- Table 4.12's REQUEST ORIGINATOR read as a REQUEST ROLE of type originator.
- REQUEST ITEM's REQUIRED BY DATE is drawn mandatory, but Table 4.13 gives none. Kept
  mandatory; the seed's dates are ours.

**Discussion**
- **The problem.** Before an order there is often a round of asking: who can do this, how
  would they do it, at what price? Kept as e-mails, the questions lose their link to the
  needs behind them and to the answers that come back.
- **A request, typed by what it asks for:** an RFI asks who can supply something and how, an
  RFP asks for a proposal (an approach and a price), an RFQ asks for prices on known items.
- **Items reach back to the needs.** REQUIREMENT REQUEST is a many-to-many: one request item
  can carry two requirements (14 + 15 PCs = 29), and one requirement can go out on several
  requests (24905 on the RFI, then on the RFP).
- **Both directions again.** ABC Corporation sends its requests out to PC repair vendors;
  ACME sends one in to us. RESPONDING PARTY lists who a request went to, when and through
  which contact mechanism; an incoming request has one, the part of us that answers it.
- **Roles:** REQUEST ROLE (the originator, a contact, an approver), a party and a type, no
  dates: ORDER ROLE's shape (4.3), and a fifth role type list (point 5).
- **No product on the request item:** it asks for what its requirements need, so a request
  can go out before anyone has chosen a product. (Ponder 1 of submodel 5.)

### Fig 4.11 — Quotes
**Transcription** (accepted: ☐; one landscape photo, with Table 4.14; open points under "To
check against the book")

```
QUOTE
  # quote_id
  * issue_date
  * valid_from_date
  * valid_thru_date
  o description
  subtypes: PROPOSAL, PRODUCT QUOTE, OTHER QUOTE
  -> PARTY                   (many "issued by" 1 party; party "the creator of" many)
  -> PARTY                   (many "given to" 1 party; party "the receiver of" many)

QUOTE ITEM
  # quote_item_seq_id          (printed "QUOTED ITEM SEQ ID")
  * quantity
  * quote_unit_price
  o estimated_delivery_date
  o comment
  -> QUOTE                   (many "part of" 1, bar; quote "composed of" many)
  -> PRODUCT                 (many "a price quote for" 1; product "quoted via" many)     } arc
  -> WORK EFFORT             (many "a price quote for" 1; effort "quoted via" many)      }
  -> REQUEST ITEM            (many "a response to" 1, dashed; item "priced via" many)

ORDER ITEM                   (as 4.2)
  -> QUOTE ITEM              (many "the acceptance of" 1, dashed; quote item "resulting in" many)

QUOTE ROLE                   (no attributes drawn)
  -> QUOTE                   (many "for" 1, bar; quote "involving" many)
  -> PARTY                   (many "of" 1, bar; party "involved in" many)
  -> QUOTE ROLE TYPE         (many "described by" 1; type "the description for" many)

QUOTE ROLE TYPE              (no attributes drawn)

QUOTE TERM
  # quote_term_id
  o term_value
  -> TERM TYPE               (many "of" 1 type; type "used in" many)
  -> QUOTE                   (many "a condition for" 1; quote "subject to" many)       } arc
  -> QUOTE ITEM              (many "a condition for" 1; item "subject to" many)        }

TERM TYPE                    (as 4.7)
REQUEST ITEM                 (as 4.10)
PRODUCT                      (from Ch 3)
WORK EFFORT                  (# work_effort_id, * name, * description, o scheduled start and
                              completion dates, o total dollars and hours allowed,
                              o estimated hours: Ch 2's Fig 2.13 entity, Ch 6's later)
PARTY                        (from Ch 2)
```

**Table 4.14** (quotes, the book's sample, in our words): 35678 is a proposal issued February
19, 2002, to support the repair of PCs, valid until March 19, 2002. 36908 is a product quote
issued March 12, 2001, a bid on pens and pencils, valid from March 12 to March 30, 2002.

**Table 4.15** (quote items, shared after the figure was built, in our words): 35678's one line
quotes 70 of "PC Repair" at $75, answering item 1 of the RFP 38967. 36908's two lines quote 50
of Johnson's fine grade 8½ by 11 bond paper at $3.75 and 40 Johnson black pens at $1.25,
answering items 1 and 2 of ACME's RFQ 38948.

**The text beside it**, in short: the first is a proposal because it may describe how the PCs
would be repaired; the second just prices pens and pencils. QUOTE ITEM names its own product,
although one could reach a product from the request item through its requirement, because
the product quoted may not be the product asked for. Quote terms work as order terms: a PC
repair quote may require the buyer to name a central point of contact, or the price may rise;
a quote item for furniture may make the buyer pay the actual freight.

**To check against the book**
- Two arcs, the chapter's first: across QUOTE ITEM's lines to PRODUCT and WORK EFFORT, and
  across QUOTE TERM's lines to QUOTE and QUOTE ITEM. Silverston means one or the other. That
  backs our arc-less readings of 4.6's and 4.7's order-or-item lines (points 10, 14).
- QUOTE TERM draws TERM VALUE optional, where ORDER TERM drew it mandatory (point 13), and
  reuses 4.7's TERM TYPE (point 15).
- ORDER ITEM "the acceptance of" one QUOTE ITEM, dashed: an order line needn't come from a
  quote. QUOTE ITEM "a response to" one REQUEST ITEM, dashed: a quote may come unasked.
- "Issued by" and "given to" both land on PARTY. "Given to" read as optional (a quote can be
  published to anyone); "issued by" as mandatory.
- PROPOSAL, PRODUCT QUOTE and OTHER QUOTE have no attributes: Table 4.14 calls them QUOTE
  TYPE.
- WORK EFFORT is drawn with exactly the attributes Ch 2 built for it (Fig 2.13).
- Table 4.14 names no issuer or receiver. Ours: Ridgeway PC Repair proposes to ABC
  Corporation; ABC Subsidiary bids to ACME.
- 36908's issue date (March 12, 2001) comes a year before it's valid, and the day before
  ACME's request (38948) that Table 4.15 says it answers. 35678 answers the RFP 38967
  (Table 4.15), which is dated three weeks after it (point 22).
- Table 4.15's PC repair is a PRODUCT (a service), not a WORK EFFORT: the arc's product
  branch. Its 70 at $75 is read as 70 hours (29 PCs were asked for), so the new product
  "PC repair" is sold by the hour.
- Table 4.15's pens are Johnson black pens, where 38948's item 2 carries 30005, a blue
  Goldstein Elite pen: the text's point (the product quoted isn't the one asked for), shown
  in the book's own data. A new catalogue product.
- Table 4.14 calls 36908 a bid on pens and pencils; Table 4.15 has paper and pens, no
  pencils. Our pencil line stays, as a third line nobody asked for.

**Discussion**
- **The problem.** An offer made before an order: these items, at these prices, under these
  terms, valid for a while. Kept as a draft order marked "quoted", it mixes an offer with a
  commitment, and has no room for the competing offers a buyer compares.
- **QUOTE is an offer, valid between two dates,** issued by one party and given to another,
  and typed: a proposal (an approach and a price), a product quote (prices for items), or
  another kind.
- **A quote item prices a product or a piece of work,** never both: the arc. Ridgeway prices
  PC repair as a service product, by the hour (Table 4.15); Byte Doctors prices the planned
  WORK EFFORT "Repair 29 PCs" per PC; ABC prices paper and pens.
- **The quoted product can differ from the one wanted.** ABC Subsidiary quotes black Johnson
  pens where ACME's need wants a blue pen (Table 4.15); Paperline offers recycled paper for
  Northwind's need of white bond paper. Deriving the product from the request and the
  requirement would hide that, so QUOTE ITEM names its own. A query compares the quoted
  product with the product the need names, or else with its must-have features ("lacks
  Blue"). (Ponder 2 of submodel 5.)
- **Competing answers to one question:** two quote items answer request item 61001/1, and
  order 12564's line accepts Fantastic's; two proposals answer the RFP 38967, one pricing a
  service by the hour, the other a planned job per PC.
- **The chapter's thread, whole:** requirement (the need) → request item (the question) →
  quote item (an answer, "a response to") → order item ("the acceptance of") → commitment
  back to the requirement (4.9). Northwind's paper for Chatham walks the whole of it in the
  seed. (Ponder 3 of submodel 5.)
- **Terms and roles once more:** QUOTE TERM reuses TERM TYPE, on the quote or one item; QUOTE
  ROLE has ORDER ROLE's shape, a sixth role type list (point 5).
- **An accepted quote must still be valid** on the order's date: a check.

### Fig 4.12 — Agreement definition
**Transcription** (accepted: ☐; two landscape photos of the figure, then Table 4.16; open
points under "To check against the book")

```
AGREEMENT
  # agreement_id
  * agreement_date
  * from_date
  o thru_date
  * description
  o text
  subtypes: PRODUCT AGREEMENT (subtypes SALES AGREEMENT, PURCHASE AGREEMENT),
            EMPLOYMENT AGREEMENT, OTHER AGREEMENT
  -> AGREEMENT TYPE          (many "described by" 1; type "used to describe" many)
  -> PARTY RELATIONSHIP      (many "associated with" 1, dashed; relationship "involved in" many)

AGREEMENT TYPE
  # agreement_type_id
  * description

AGREEMENT ROLE               (no attributes drawn)
  -> AGREEMENT               (many "for" 1, bar; agreement "involving" many)
  -> PARTY                   (many "of" 1, bar; party "involved in" many)
  -> AGREEMENT ROLE TYPE     (many "described by" 1, bar; type "the description of" many)

AGREEMENT ROLE TYPE          (no attributes drawn)

PARTY RELATIONSHIP           (Ch 2's 2.6a: # from_date, o thru_date, o comment)
  -> PARTY ROLE              (many "established from" 1, bar; role "involved in" many)
  -> PARTY ROLE              (many "established to" 1, bar; role "involved in" many)
PARTY ROLE                   (# party_id, # party_role_id; Ch 2)
PARTY                        (subtypes ORGANIZATION, PERSON; Ch 2)
```

**Table 4.16** (agreements, the book's sample, in our words):
- 10002: a sales agreement, tied to a customer relationship, on the pricing and terms for
  buying inventory items. ABC Corporation is the supplier, ACME Company the customer. January
  1 to December 30, 2002.
- 86749: an employment agreement, tied to an employment relationship: William Jones hired as
  an entry-level information systems programmer, ABC Corporation the employer. From May 7,
  1990, no end.
- 489589: a partnership agreement, an informal partnership with terms to compensate the
  partners: ABC Corporation, Sellers Assistance Corporation and XYZ Corporation, all three
  partners. No party relationship. June 1, 2000, to June 1, 2001.

**The text beside it**, in short: the third agreement has three parties in one role, which a
party relationship (always two ends) can't hold. Agreement roles take any number of parties,
and new role types are rows, so the model stays flexible.

**To check against the book**
- AGREEMENT is drawn with subtypes *and* an AGREEMENT TYPE. Table 4.16's types are the subtypes'
  names plus a partnership, which has no box: read as the subtypes being the main kinds and
  the type an open list under them.
- The AGREEMENT TYPE line read as mandatory (every agreement has a type); the PARTY
  RELATIONSHIP line as optional, dashed on the agreement's side (489589 has none).
- AGREEMENT ROLE has bars on all three lines: identified by agreement + party + type, as we
  read ORDER ROLE (point 4). No dates, and Table 4.16 gives none.
- Table 4.16's ending dates read as inclusive: December 30, 2002 (not 31) and June 1, 2001.
- Table 4.16 gives no AGREEMENT DATE (when it was signed): the seed uses the starting date.
- ABC Corporation is 10002's supplier, but Ch 2's customer relationship (Table 2.5) is
  between ACME and ABC Subsidiary (point 23).
- XYZ Corporation is read as a new organization: Ch 2's XYZ Subsidiary rolls up to ABC, and
  a partnership between ABC and its own subsidiary would make little sense.
- William Jones is new (a person). ABC Corporation employs him from 1990, years before
  Table 2.5's 1998 dates for ABC's family.

**Discussion**
- **The problem.** Contracts kept as files in a folder, or as columns on the customer
  (`contract_start`, `contract_end`): one contract per customer, two parties at most, no
  history, and no answer to "which agreements is ACME in, and which are in force?".
- **AGREEMENT is dated and typed:** signed on one date, in force from one date to another, and
  of a kind: a product agreement (sales or purchase), an employment agreement, or another
  (a partnership, a distribution deal). Orders (4.2) are one-off; an agreement sets the
  terms for many orders over a period.
- **Two ways to reach the parties.** The PARTY RELATIONSHIP an agreement formalizes (a
  customer relationship, an employment), and AGREEMENT ROLE: any number of parties, each in a
  typed role. The relationship is optional, because a three-way partnership is no binary
  relationship; the roles always say who signed what. (Ponder 1 of submodel 6.)
- **Two paths, so a rule:** when an agreement names a relationship, both its ends should play
  a role in the agreement. Table 4.16's own 10002 breaks it against Ch 2's data (point 23).
- **Subtypes and a type at once:** the subtype boxes are the kinds the model hangs lines on
  (product agreements matter for pricing and orders), the type rows an open list. With no
  attributes, both become rows of one hierarchy. (Ponder 2 of submodel 6.)
- **AGREEMENT ROLE TYPE** is the seventh role-type list (point 5).

### Fig 4.13 — Agreement item
**Transcription** (accepted: ☐; one photo; open points under "To check against the book")

```
AGREEMENT ITEM
  # agreement_item_seq_id
  * agreement_text
  o agreement_image
  subtypes: SUB AGREEMENT, AGREEMENT SECTION, AGREEMENT PRICING PROGRAM, AGREEMENT EXHIBIT
  -> AGREEMENT               (many "part of" 1, bar; agreement "composed of" many)
  -> AGREEMENT ITEM          (many "part of" 1, dashed loop; item "comprised of" many)

ADDENDUM
  # addendum_id
  o addendum_creation_date
  o addendum_effective_date
  * addendum_text
  -> AGREEMENT ITEM          (many "a modification to" 1; item "modified by" many)       } arc
  -> AGREEMENT               (many "a modification to" 1; agreement "modified by" many)  }

AGREEMENT ORGANIZATION APPLICABILITY   (no attributes drawn)
  -> ORGANIZATION            (many "based on" 1)
  -> AGREEMENT ITEM          (many "used to define" 1; item "specified for" many)
AGREEMENT PRODUCT APPLICABILITY        (no attributes drawn)
  -> PRODUCT                 (many "based on" 1; product "used to define" many)
  -> AGREEMENT ITEM          (many "used to define" 1; item "specified for" many)
AGREEMENT GEOGRAPHICAL APPLICABILITY   (no attributes drawn)
  -> GEOGRAPHIC BOUNDARY     (many "based on" 1; boundary "used to define" many)
  -> AGREEMENT ITEM          (many "used to define" 1; item "specified for" many)

AGREEMENT                    (as 4.12, subtypes redrawn)
ORGANIZATION                 (* name; Ch 2)
PRODUCT                      (# product_id, * description; Ch 3)
GEOGRAPHIC BOUNDARY          (# geo_id, * name; Ch 2)
```

No table or text came with this figure. Table 4.17 came later, with Fig 4.14's photos:

**Table 4.17** (agreement items, the book's sample, in our words): agreement 10002 has two
items, each governing the terms for buying one product: item 1 Johnson's fine grade 8½ by 11
blue bond paper, item 2 Jerry's box of 3½-inch diskettes.

**To check against the book**
- Table 4.17's PRODUCT column is read as each item's product applicability (one row each),
  which backs our reading of applicability. Item 1 is typed a pricing program (Table 4.19
  prices it), item 2 a section (Table 4.18 gives it a term, no prices). The seed's two
  made-up items for 10002 were replaced by these.
- "Blue" bond paper: Ch 3's product 1 is Johnson's fine grade bond paper, white as standard,
  and blue isn't among its features. Read as product 1, with the colour kept in the item's
  text only.
- AGREEMENT ITEM's "part of" loop is dashed at both ends: an item may sit inside another
  item, and may hold others. Read as inside the same agreement (a check).
- The arc across ADDENDUM's two lines: an addendum changes the whole agreement or one item,
  never both. Read as exactly one.
- The three applicabilities have no bars and no attributes: read as an item limited to these
  organizations, products and boundaries. What an item with none of a kind means isn't
  drawn (point 26).
- ORGANIZATION applicability lands on ORGANIZATION, not PARTY: a clause can't be limited to
  one person.
- AGREEMENT IMAGE is optional: read as a reference to a scanned page or a drawing, stored as
  text.
- PRODUCT is drawn with DESCRIPTION only, as a reminder; Ch 3's PRODUCT is unchanged.
- PRICING PROGRAM has no lines here; its prices come in Fig 4.15.

**Discussion**
- **The problem.** An agreement's text as one block can't say which clause covers which
  products, customers or regions, and a change overwrites what was signed.
- **AGREEMENT ITEM breaks the agreement into numbered parts,** typed (a section, a pricing
  program, an exhibit, a sub-agreement) and nested: sections inside sections, a
  sub-agreement with its own sections. (Ponder 5 of submodel 6.)
- **Applicability limits an item** to some organizations, products and geographic
  boundaries, which answers "which clauses apply to this order line?": an agreement in force
  on the order's date, with the customer among its parties, and an item whose limits all
  match (the query). (Ponder 3 of submodel 6.)
- **ADDENDUM keeps changes beside the text they change,** dated (created, effective), for the
  whole agreement or one item: the arc. What was signed stays readable, and so does when it
  changed. (Ponder 4 of submodel 6.)

### Fig 4.14 — Agreement terms
**Transcription** (accepted: ☐; one photo, with Tables 4.17 and 4.18 and the text around
them; open points under "To check against the book")

```
AGREEMENT TERM
  # agreement_term_id
  * from_date
  o thru_date
  o term_value
  subtypes: LEGAL TERM, FINANCIAL TERM, INCENTIVE, THRESHOLD, OTHER AGREEMENT TERM
  -> AGREEMENT ITEM          (many "associated with" 1; item "further defined by" many)   } arc
  -> AGREEMENT               (many "associated with" 1; agreement "further defined by" many) }
  -> TERM TYPE               (many "described by" 1; type "used as part of" many)

TERM TYPE
  # term_type_code
  * description

AGREEMENT ITEM               (# agreement_item_seq_id; as 4.13)
  -> AGREEMENT               (many "part of" 1, bar; agreement "composed of" many)
AGREEMENT                    (as 4.12: # agreement_id, * agreement_date, * from_date,
                              * thru_date, * description, o text; subtypes PRODUCT AGREEMENT
                              over SALES and PURCHASE, EMPLOYMENT, OTHER)
```

**Table 4.18** (agreement terms, the book's sample, in our words):
- 23884, on the whole agreement: an exclusive arrangement, the supplier may not supply
  similar services to the customer's competitors for so many days after the contract ends.
  Value 60. No dates.
- 10002, item 1 (the Johnson bond paper): quantity not to exceed 1,000, January 1 to
  December 31, 2002; dollars not to exceed $10,000, January 1 to June 30, 2002.
- 10002, item 2 (the diskettes): the customer buys them only from this supplier, January 1
  to December 30, 2002. No value.

**The text beside it**, in short: an agreement and each of its items may have terms, each
with its value and the dates it holds, typed by TERM TYPE. A simple agreement without items
takes its terms directly. The kinds listed: legal and financial terms, incentives,
thresholds, renewal and termination clauses, indemnification, non-competition, exclusivity.
The text under the figure (partly in the photo) reads 10002's caps as limits on the item:
its terms hold only for the first 1,000 reams.

**To check against the book**
- The curved arc across the two "associated with" lines: a term belongs to the whole
  agreement or to one item, never both. Read as exactly one, as QUOTE TERM's arc (4.11).
- TERM TYPE is keyed TERM TYPE CODE here, TERM TYPE ID in 4.11: read as the same entity.
- The five subtypes have no attributes, and TERM TYPE is drawn beside them, the same shape
  as AGREEMENT's subtypes and type (4.12). Read the same way: the subtypes become the top
  rows of one type hierarchy (point 30).
- AGREEMENT's THRU DATE is drawn mandatory here and in 4.16, optional in 4.12. Kept
  optional: William's 86749 has no end (point 32).
- 23884 isn't in Table 4.16, so its kind, parties and dates aren't given. Ours: ABC
  Corporation buys PC repair from Ridgeway PC Repair (its Fig 4.11 proposal won), March 2002
  to March 2003, a purchase agreement.
- 23884's term has no dates though FROM DATE is drawn mandatory: seeded with the
  agreement's starting date (point 31).
- 10002's quantity cap runs to December 31, a day past the agreement's December 30 (and past
  the diskettes term, which stops on the 30th). Seeded as printed; the check flags it
  (point 31).
- A threshold read as cumulative: every order line the item governs within the term's
  dates counts toward it, not one order at a time (point 33).
- TERM VALUE "$10,000" is a bare number; the type (dollars not to exceed) gives the unit,
  as for order terms (4.7).

**Discussion**
- **The problem.** Conditions buried in the agreement's text can't be checked against
  orders, and a column per kind of condition (`max_quantity`, `exclusive_flag`,
  `noncompete_days`) grows with every contract the lawyers write.
- **AGREEMENT TERM is the third term table,** after ORDER TERM (4.7) and QUOTE TERM (4.11),
  with the same shape: a typed value on the header or one item, the arc. What's new is its
  own dates: a dollar cap for the first half-year only, inside a year-long agreement.
  (Ponder 1 of submodel 7.)
- **The subtypes are kinds of term,** legal, financial, incentive, threshold and other, so
  they sit at the top of TERM TYPE, shared by order, quote and agreement terms. (Ponder 2 of
  submodel 7.)
- **Thresholds are where terms meet orders:** a cap is only worth recording if something
  adds up the order lines it covers. That needs the path from order line to agreement item,
  Fig 4.16's view.

### Fig 4.15 — Agreement pricing
**Transcription** (accepted: ☐; one photo, with the text before it and Table 4.19, printed
after Fig 4.16's opening text; open points under "To check against the book")

```
PRICE COMPONENT              (as 3.7)
  # price_component_id
  * from_date
  o thru_date
  o price
  o percent
  o comment
  subtypes: BASE PRICE, DISCOUNT COMPONENT, SURCHARGE COMPONENT, MANUFACTURER SUGGESTED PRICE
  subtypes: ONE TIME CHARGE, RECURRING CHARGE, UTILIZATION CHARGE (o quantity)
  -> AGREEMENT PRICING PROGRAM (many "specified for" 1, dashed; program "priced using" many)   new
  -> GEOGRAPHIC BOUNDARY     (many "based on" 1, dashed; "a location used to define" many)
  -> PRODUCT CATEGORY        (many "based on" 1, dashed; "used to define" many)
  -> QUANTITY BREAK          (many "based on" 1, dashed; "a discount level defined for" many)
  -> ORDER VALUE             (many "based on" 1, dashed; "a discount level defined for" many)
  -> SALE TYPE               (many "based on" 1, dashed; "used to define" many)
  -> CURRENCY MEASURE        (many "in the currency of" 1, dashed; "used in" many)
  -> ORGANIZATION            (many "specified for" 1, dashed; "the pricer of" many)
  -> PRODUCT                 (many "a price defined for" 1, dashed; "priced by" many)
  -> PRODUCT FEATURE         (many "a price defined for" 1, dashed; "priced by" many)
  RECURRING CHARGE   -> TIME FREQUENCY MEASURE ("per"; "used in")
  UTILIZATION CHARGE -> UNIT OF MEASURE        ("per"; "used in")

AGREEMENT ITEM               (# agreement_item_seq_id)
  subtype: AGREEMENT PRICING PROGRAM
GEOGRAPHIC BOUNDARY          (# geo_id, * name; Ch 2)
PRODUCT CATEGORY             (# product_category_id, * description; Ch 3)
QUANTITY BREAK               (# quantity_break_id, * from_quantity, o thru_quantity; Ch 3)
ORDER VALUE                  (# order_value_id, * from_amount, o thru_amount; Ch 3)
SALE TYPE                    (# sale_type_id, * description; Ch 3)
UNIT OF MEASURE              (# uom_id, * abbreviation, * description;
                              subtypes TIME FREQUENCY MEASURE, CURRENCY MEASURE; Ch 3)
ORGANIZATION                 (Ch 2)
PRODUCT                      (# product_id, * name; Ch 3)
PRODUCT FEATURE              (# product_feature_id, * description; Ch 3)
```

**Table 4.19** (agreement item prices, the book's sample, in our words): 10002's item 1, the
Johnson bond paper: a base price of $7.00 in the Eastern region, a base price of $7.50 in the
Western region, and a 2% discount from 1,000 reams.

**The text beside it**, in short: an agreement item holds the prices agreed between the
parties, which may vary by period, quantity, the parties' addresses and region. Fig 4.15
reuses Ch 3's pricing model (Fig 3.7): a PRICE COMPONENT may now also belong to an AGREEMENT
PRICING PROGRAM, a subtype of AGREEMENT ITEM, and a program has any number of components.
The text under the figure (cut off in the photo) seems to weigh this as an alternate model
whose advantage is reusing the pricing structure.

**To check against the book**
- The new line is dashed at both ends: a list price belongs to no program, and a program
  may have no prices yet.
- The line lands on the subtype AGREEMENT PRICING PROGRAM, not on AGREEMENT ITEM: only
  pricing programs carry prices. With a line of its own, the subtype gets a table (point 34).
- PARTY TYPE's "based on" line (3.7) isn't drawn: read as abbreviation, as Fig 3.11 left
  out boundaries and breaks, so the column stays (point 34).
- Table 4.19 gives no dates, currency or pricer: seeded with the agreement's dates, US
  dollars, and ABC Corporation, the supplier, as pricer.
- The Eastern and Western regions are new boundaries: read as the US split by the
  Mississippi, Illinois east and Missouri west, so ACME's St. Louis addresses get the
  western price (point 36).
- Table 4.19's discount: "2" in the PERCENT column, from 1,000 reams, no upper break. Ch 3's
  quantity break 1,000+ is reused.
- The text beside the figure (where it may say which alternate it prefers) is only partly in
  the photos.

**Discussion**
- **The problem.** Agreed prices kept apart from the price list (a `contract_price` table, a
  spreadsheet per customer) repeat every pricing condition (region, quantity, period) in a
  second structure, and every pricing rule is written twice.
- **One pricing structure, one more condition:** an agreement price is a PRICE COMPONENT
  with the pricing program set; a list price has none. Everything Ch 3 built (regions,
  breaks, order values, charge kinds) works for agreements at no cost. (Ponder 3 of
  submodel 7.)
- **Two paths, so rules:** the program's own applicability (4.13) and its components'
  conditions both say what it prices, and both have dates beside the agreement's. Checks
  keep them in line.
- **The cost:** every query that reads PRICE COMPONENT as "the price list" now has to say
  "with no program", Ch 3's included (point 35).

### Fig 4.16 — Relationship of agreement to order
**Transcription** (accepted: ☐; one photo, with the section's opening text; open points
under "To check against the book")

```
ORDER ITEM                   (as 4.2: # order_item_seq_id, o quantity, o unit_price,
                              o estimated_delivery_date, o shipping_instructions,
                              o item_description, o comment; subtypes SALES ORDER ITEM
                              (o corresponding_po_id), PURCHASE ORDER ITEM)
  -> ORDER                   (many "part of" 1, bar; order "composed of" many)
  -> PRODUCT                 (many "for" 1, dashed; product "ordered via" many)
  -> PRODUCT FEATURE         (many "for" 1, dashed; feature "ordered via" many)
ORDER                        (# order_id, * order_date, o entry_date)
PRODUCT                      (# product_id, * name, o introduction_date,
                              o sales_discontinuation_date, o support_discontinuation_date,
                              o comment)
PRODUCT FEATURE              (# product_feature_id, * description)
PRICE COMPONENT              (# price_component_id, * from_date, o thru_date, o price,
                              o percent, o comment)
  -> PRODUCT                 ("a price defined for"; "priced by")
  -> PRODUCT FEATURE         ("a price defined for"; "priced by")
  -> AGREEMENT PRICING PROGRAM ("specified for"; "priced using")
AGREEMENT ITEM               (# agreement_item_seq_id, * agreement_text, o agreement_image;
                              subtype AGREEMENT PRICING PROGRAM)
  -> AGREEMENT               (many "part of" 1, bar; agreement "composed of" many)
AGREEMENT                    (# agreement_id, * agreement_date, * from_date, * thru_date,
                              * description, o text)

No line joins ORDER or ORDER ITEM to AGREEMENT or AGREEMENT ITEM.
```

**The text beside it**, in short: usually there is no direct relationship between an order
and an agreement, because an agreement's terms and prices are business rules the order is
processed under. The figure is another view of structures already shown, to make plain how
an order reaches its agreement: through the products (and features) both of them price.

**To check against the book**
- Nothing new is drawn: read as a view to be built as queries, not tables (point 37).
- The path is read as more than the product: the agreement in force on the order's date,
  the order's customer among its parties, and the item's applicability (4.13) matching the
  line's party, product and ship-to address. The figure draws only the product legs.
- "In most cases" leaves room for an order that does name its agreement (a call-off against
  a blanket contract, say). Not built.
- AGREEMENT's THRU DATE is drawn mandatory again (point 32).

**Discussion**
- **The problem.** An `agreement_id` on the order looks simpler, but an order is often
  governed by several agreements at once (a price program here, an exclusivity there), the
  clerk may pick the wrong one or none, and an agreement signed after the order was keyed
  would never reach it. (Ponder 4 of submodel 7.)
- **Derive, don't store:** the order line keeps what was agreed for it (its unit price, a
  snapshot, 4.2), and the agreement says what it should have been. Comparing the two is the
  point: a price check and a threshold count, each a query. (Ponder 5 of submodel 7.)
- **When to store it after all:** when the business really does order against one named
  contract (blanket orders, call-offs), when deriving it is too slow, or when it must
  remember which agreement priced the line at the time, whatever later edits say. It's
  cheap: one nullable `agreement_item_id` on the order line, filled by the step that sets the
  price. Then the stored link needs a check that it still agrees with the derivation.
- **Ending an agreement, forward or back:** the match tests the order's own date, so an end
  date set after the orders leaves them governed. An end set back in time (a cancellation
  learnt late) takes the lines placed in between out from under it: their prices stay, the
  agreement behind them goes. That is often the right answer: the discount wasn't owed, and
  the line now shows as charged below list with nothing behind it, for someone to bill or
  write off. A stored link would hide that unless the check above runs. Our dates say when a
  fact held, not when we learnt it, so what we believed before the edit is gone (bitemporal,
  Ch 2 NOTES, Fig 2.2b). (Chat, 2026-10-20; point 41.)

### Fig 4.17 — Overall order model
**Transcription** (accepted: ☐; one photo; identifiers only, no attributes; open points
under "Points to discuss after the overview")

```
Shown, all from Figs 4.2–4.16:
  ORDER, ORDER ITEM, ORDER ROLE, ORDER CONTACT MECHANISM, ORDER ITEM CONTACT MECHANISM,
  CONTACT MECHANISM PURPOSE TYPE, ORDER STATUS, ORDER TERM, ORDER ADJUSTMENT,
  ORDER REQUIREMENT COMMITMENT, REQUIREMENT (loop), REQUIREMENT REQUEST, REQUEST,
  REQUEST ITEM, QUOTE, QUOTE ITEM, QUOTE TERM, AGREEMENT, AGREEMENT ITEM (loop),
  AGREEMENT TERM, AGREEMENT ROLE, PARTY, PARTY RELATIONSHIP, PRODUCT, PRODUCT FEATURE,
  PRICE COMPONENT

Lines, as read:
  ORDER ITEM -> ORDER (part of, bar); -> PRODUCT, PRODUCT FEATURE (dashed);
                -> QUOTE ITEM (the acceptance of)
  ORDER ROLE -> ORDER, PARTY
  ORDER CONTACT MECHANISM      -> ORDER, CONTACT MECHANISM PURPOSE TYPE
  ORDER ITEM CONTACT MECHANISM -> ORDER ITEM, CONTACT MECHANISM PURPOSE TYPE
  ORDER STATUS, ORDER TERM, ORDER ADJUSTMENT -> ORDER and -> ORDER ITEM (each)
  ORDER REQUIREMENT COMMITMENT -> ORDER, REQUIREMENT
  REQUIREMENT REQUEST -> REQUIREMENT, REQUEST ITEM;  REQUEST ITEM -> REQUEST
  QUOTE ITEM -> QUOTE, REQUEST ITEM (dashed);  QUOTE TERM -> QUOTE, QUOTE ITEM (arc)
  AGREEMENT ITEM -> AGREEMENT (bar);  AGREEMENT TERM -> AGREEMENT, AGREEMENT ITEM (arc)
  AGREEMENT ROLE -> AGREEMENT, PARTY;  AGREEMENT -> PARTY RELATIONSHIP
  PRICE COMPONENT -> PRODUCT, PRODUCT FEATURE, AGREEMENT ITEM
  No line between ORDER (or ORDER ITEM) and AGREEMENT (or AGREEMENT ITEM).
```

What it adds or settles:
- **The generic order parties win:** ORDER ROLE and the two contact-mechanism tables of 4.5
  are drawn; 4.3's and 4.4's party-role columns aren't, nor the SALES and PURCHASE subtypes
  (point 38, which answers point 8's question).
- **No line from order to agreement,** as 4.16 said: the agreement reaches the order through
  products, parties and dates.
- **PRICE COMPONENT lands on AGREEMENT ITEM:** the PRICING PROGRAM subtype isn't drawn here,
  so read as abbreviation of 4.15's line.
- **ORDER REQUIREMENT COMMITMENT is drawn to ORDER,** where 4.9 has ORDER ITEM (point 39).
- Left out: CONTACT MECHANISM itself, PARTY ROLE, ORDER ITEM ROLE, ORDER ITEM ASSOCIATION,
  the request, quote and requirement roles, RESPONDING PARTY, DESIRED FEATURE, WORK EFFORT,
  ADDENDUM, the applicabilities, SALES TAX LOOKUP and every type lookup (TERM TYPE included).
  Read as abbreviation, as for Fig 3.11, not removal (point 40).

**How it flows** (architecture figure: no SQL, on assumptions until the overview)
- **Two hubs, both header + items:** ORDER with its ORDER ITEMs (what was agreed this time,
  each line a snapshot of product and price) and AGREEMENT with its nested AGREEMENT ITEMs
  (what was agreed for a period, before any order).
- **Need → ask → offer → order:** a REQUIREMENT (nested) reaches the REQUEST ITEMs of a
  REQUEST through REQUIREMENT REQUEST; a QUOTE ITEM answers a request item; an ORDER ITEM
  accepts a quote item; ORDER REQUIREMENT COMMITMENT says which order fills which need, and
  how much of it.
- **Around the order,** each on the whole order or one item: ORDER ROLE (the parties), the
  contact mechanisms by purpose, ORDER STATUS, ORDER TERM and ORDER ADJUSTMENT. Quotes carry
  QUOTE TERMs the same way.
- **Around the agreement:** AGREEMENT ROLE (the parties), the PARTY RELATIONSHIP it
  formalizes, AGREEMENT TERMs on it or one item, and Ch 3's PRICE COMPONENTs on its pricing
  programs.
- **Agreement → order, with no line:** an agreement governs an order line when it is in
  force on the order's date, the customer plays a role in it, and an item's applicability
  matches the line (product, organization, place). Derived, never stored (4.16).
- **From Ch 2:** PARTY, PARTY RELATIONSHIP, CONTACT MECHANISM and its purpose types,
  GEOGRAPHIC BOUNDARY (tax, applicability, regional prices), WORK EFFORT (quote items).
  **From Ch 3:** PRODUCT, PRODUCT FEATURE, PRICE COMPONENT.
- **Alternates:** one ORDER with subtypes beats 4.1's twin sales and purchase models; the
  overall model keeps 4.5's generic roles and mechanisms over 4.3's and 4.4's columns.

### Points to discuss after the overview (Figs 4.1–4.17)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing.

1. **4.1, not built:** read as the book's straw man, which 4.2 replaces, so it gets no SQL
   (STATUS.md lists it as not built). If you'd rather see its failures in data, as with Fig
   2.2a's `person_flat`, we build it at the overview.
   **Outcome (2026-10-22): kept.** Left unbuilt: its failure is structural (every rule
   twice, a party that buys and sells as two rows), which a seed wouldn't show better than a
   sentence. Card 10's W already names it; no card fix.
2. **4.2, product or feature:** no arc is drawn, yet read as "an item names a product or a
   feature, not both; a feature's item is ordered for a product's item, on the same order,
   and the feature must apply to that product; an item with neither carries a description".
   Built as data-quality queries, not constraints, so the reading is easy to change. Table
   4.4 (shared later) seems to put a feature on the product's own line twice (the pen's blue,
   A2395's billing feature), beside feature lines of their own: if so, the book allows both
   shapes, and the "both or nothing" check should only flag "nothing".
   **Outcome (2026-10-22): kept, the strict reading.** An exclusive arc: a line names a
   product, a feature, or neither (a description-only line), never both, and every feature
   gets its own line ordered for a product's line. Allowing both would give one fact two
   spellings (Blue on the pen's line, or on a line under it), so every feature report would
   need two query shapes, and it records nothing the strict reading can't. Table 4.4's blue
   pen is read as the table squeezing a 0.00 feature onto its product's row. The checks stay
   as they are. Card 10 already says "a product **or** a feature"; no card fix.
3. **4.3 and 4.4, optionality of the party lines:** all seven on each side read as optional, so the columns are
   nullable. When no bill-to is given, the queries bill the placing customer. That fallback
   is ours, not the book's: is the bill-to meant to be mandatory instead?
   **Outcome (2026-10-22): kept optional, to revisit.** The bill-to points at a role (BILL TO
   CUSTOMER, or BILL TO PURCHASER on a purchase order), so only a party already set up to be
   billed can be named, and an order may legitimately not know it yet. The fallback to the
   placer stays in the queries for now; the user will see how it plays out (Ch 7's invoicing,
   the core app) and change it then. Optionality alone doesn't depend on the column being
   shared by both directions. No card fix.
4. **4.3, ORDER ROLE's identifier:** read as order + party + type. Bars are visible on "of"
   and "described by" only, but two salespeople on one order need the party in it too.
   **Outcome (2026-10-23): kept as read.** Order + party + type is the uniqueness rule (our
   surrogate key leaves it to the "one party twice in the same role" check). Order + type
   alone is a per-role-type cardinality rule (one bill-to per order, many buyers or
   salespeople), not the identifier; 4.5's "more than one of a job the columns held once"
   check covers it for the types that need it.
5. **4.3, ORDER ROLE TYPE vs Ch 2's ROLE TYPE:** this is the second kind of role type, the
   trigger for TODO's refactor (`role_type` as a ROLE TYPE supertype with PARTY ROLE TYPE and
   ORDER ROLE TYPE subtypes). The figure draws ORDER ROLE TYPE alone, so it's its own lookup
   for now; decide at the overview, once more role types have shown up. Fig 4.12's AGREEMENT
   ROLE TYPE makes seven.
   **Outcome (2026-10-23): changed, one table** (the user's call). All 18 role-type lookups
   (Ch 2's facility, communication event and case ones included: same shape, same job,
   our reading of Silverston's intention) fold into `role_type` with a `scope` column
   (party, facility, communication event, order, …). Each role table gets a data-quality
   check that its type has the right scope (deviation: a composite FK on (type, scope) with
   a constant scope column would enforce it in the database, the production choice, left
   out by the simple-keys rule). A scope branches out into a shared-key subtype table only
   if it ever earns an attribute of its own. Done in the refactor; point 9 and the order
   role → standing role mapping build on it.
6. **4.4, PURCHASE ORDER ITEM's ITEM DESCRIPTION:** drawn on the subtype and on ORDER ITEM
   (4.5 does the same; 4.6 draws it on ORDER ITEM only). Read as one attribute, kept on
   `order_item`. If Silverston meant a second one (the supplier's wording for the line, say),
   it moves to `purchase_order_item`.
   **Outcome (2026-10-23): kept as read** (the user's call): one free-text field, on
   `order_item` only. A supplier's own wording for a product, if ever needed, is a fact
   about the supplier's offer (Ch 3's SUPPLIER PRODUCT), not about one line. Left for the
   refactor: after point 8 takes the ship-to columns away, `purchase_order_item` has no
   column of its own.
7. **4.4, whose buyer roles:** PLACING BUYER, BILL TO PURCHASER and SHIP TO BUYER are grouped
   under a new BUYER type, the mirror of CUSTOMER. Nothing drawn says they must be roles of
   our own organizations (or their employees), so nothing checks it. Should something? Table
   4.7 (shared later) gives every buyer role to one of ABC's own organizations.
   **Outcome (2026-10-23): changed, rules in the mapping** (the user's call: keep it
   simple, organizations where possible). In the point 8 mapping, on a purchase order:
   PLACED_BY and BILL_TO require an INTERNAL_ORGANIZATION standing role (as Table 4.7 has
   it; the person who raised the order goes under ENTERED_BY or APPROVER, with no such
   rule); SHIP_TO on a purchase line gets no rule, so Ch 5's drop ship 4800 to Sellers
   Assistance passes. **Principle:** a rule only tests the party's own standing role; a
   check never follows a relationship (employment, subsidiary), so "our employee" is not a
   rule. Rules are rows, so they carry from/thru dates and an order is judged by the rules
   in force on its order date. The mapping needs the order's direction (point 9).
8. **4.5 built beside 4.3 and 4.4:** read as an alternate (the text offers it for when roles
   change), and built next to them, as Ch 2 kept Figs 2.5 and 2.6a: order 12571 uses only
   the generic tables, the others the columns, plus generic rows for jobs no column holds. If
   the chapter's overall figure keeps one version, the other becomes comparison only.
   **Outcome (2026-10-22): changed, generic all the way** (the user's call: that's
   Silverston's point, and the overall figure keeps it). In the refactor every order moves to
   `order_role` and the order and item contact-mechanism tables; the party and mechanism
   columns of 4.3 and 4.4 go (whether they stay as a labelled comparison is confirmed then).
   Point 9 still decides the role types. **Card fix:** card 10's S and D lead with the generic
   tables, the columns at most as the W's half-step; the architecture card already keeps the
   generic version. **Mantra (the user's pick, 2026-10-23, at the explode test):** "One
   order, either way; items name a product or feature; order and item each carry hats and
   addresses; rules guard the hats." S gains `order_role_rule` (points 7 and 9) as a guard.
   **Agreed addition (2026-10-22, found under point 4):** `order_role` points at `party`, so a
   BILL_TO order role can name a party never set up to be billed, which the column version's
   FK to `party_role` prevents. For the refactor: a mapping stored as rows, order role type →
   the standing role type it requires (BILL_TO → BILL_TO_CUSTOMER, SALESPERSON → EMPLOYEE,
   APPROVER → none), as Ch 2's medium-to-participant table does, and one data-quality query:
   the party holds a current role of that type (or below it) on the order date, plus a bad
   seed row it catches.
9. **4.5, direction-neutral role types:** our new ORDER ROLE TYPE rows (PLACED_BY, TAKEN_BY,
   BILL_TO) serve both directions, and the order's kind says which side is ours. Silverston
   may mean one type per hat (placing customer, supplier, bill-to purchaser…), which keeps
   the role names of 4.3 and 4.4 but doubles the list.
   **Outcome (2026-10-23): kept neutral, with the rules in one table** (the user's call).
   `order_role_rule` (order kind, role type, an optional required standing role type,
   from/thru) holds the rules; `order_role` (order, party, role type, percent) holds the
   facts. A rule row means "this hat is allowed on this kind of order"; several rows for
   one hat mean "any of these standing roles" (SALESPERSON: EMPLOYEE or CONTRACTOR). Two
   checks: a hat with no rule for the order's kind on its date, and a party holding none
   of the required standing roles on the order date. The direction lives only in the rule
   table, so the role types stay neutral (per-hat names would repeat the kind) and their
   scope stays plain `order` (point 5); no parent types. Lines get the twin
   `order_item_role_rule`. This is the point 8 mapping and point 7's rows, made concrete.
10. **4.6, an order or an item:** no arc is drawn across the two "affecting" lines; read as
    one or the other, never both (a data-quality query). Other readings: an item's adjustment
    also names its order (redundant, but easy to sum), or both are allowed.
    **Outcome (2026-10-26): kept, exactly one** (the user's call, as for point 2's product or
    feature). A line's adjustment doesn't copy its order: the line already knows it, and a
    copy can be read two ways (10% off line 3's 50.00, or off the order's 125.00, or both and
    counted twice) or disagree with the line's own order. The check flags such a row to be
    fixed; until then the queries let the line win (the user's tie-break, already how they
    read it). No SQL change. Card 11 already says "one or the other"; no card fix.
11. **4.6, a percentage of what, applied in which order:** the figure doesn't say. Our queries
    take each percentage of the value before any adjustment, so tax is charged on the
    undiscounted price. If Silverston means a sequence (discounts, then tax), an adjustment
    needs a sequence number, or its type an order of application.
    **Outcome (2026-10-26): kept as built, for now** (the user's call: keep it simple). The
    book is silent (pages 125–127 and Table 4.8 give no base and no order), so this is our
    assumption, not Silverston's. Real billing applies discounts before tax (on Table 4.8's
    order 12560: 10% of 164.00 after the diskettes' 6.00, not of 170.00); if invoicing
    (Ch 7) needs it, add an order of application on the six top adjustment types then. No
    card fix: card 11 doesn't say what a percentage is taken from.
12. **4.6, SALES TAX LOOKUP with no dates and no line to the adjustment:** read as a reference
    table the order copies its rate from (the snapshot again). Dates would keep old rates for
    late corrections; we stay with the book.
    **Outcome (2026-10-26): changed, dated rates** (the user's call). `sales_tax_lookup` gets
    `from_date` (not null) and `thru_date` (exclusive, null = current), as every effective-
    dated table here. The rate copied onto an order is the one as of the order date, so a
    late correction to an old order still finds the old rate. The duplicate-rate check
    becomes an overlap check (two rates for one boundary and category on the same day).
    Refactor: schema, seed (a Missouri rate change on 1 Jan, a December order corrected
    after it), the tax query and the check; card 11's key mentions the dates.
13. **4.7, TERM VALUE optional:** drawn mandatory, but Table 4.9 has a term with no value
    ("no exchanges or refunds"). Built nullable, the table's reading. If every term must carry
    a value, that one needs a made-up value (1 for yes?), which reads oddly. Fig 4.11 draws
    QUOTE TERM's value optional.
14. **4.7, statuses and terms on an order or an item:** no arcs drawn; read as for 4.6's
    adjustments (point 10), one or the other, checked by a data-quality query. Settle the
    three together. Fig 4.11 draws the arc on QUOTE TERM's same pair of lines, which backs
    the reading.
15. **4.7, ORDER STATUS TYPE in Ch 2's `status_type`, TERM TYPE on its own:** order statuses
    joined Ch 2's shared status table, as its notes foresaw, while each role type so far got
    a lookup of its own (point 5). Settle both at once. TERM TYPE is a flat lookup with a
    general name, ready for other terms; Fig 4.11 reuses it for QUOTE TERM. By Fig 4.11 there
    are six role-type lookups (order, order item, requirement, request, quote, and Ch 2's).
16. **4.8, sales to purchase only:** the lines land on the subtypes, so we link a sales line
    to a purchase line and nothing else. The entity's general name could mean any item to any
    item, with a type (a replacement line, a split line); not built.
17. **4.8, no quantity:** built without one, as drawn. When a purchase line fills several
    sales lines, or a sales line draws on several purchase lines, the split is unknown. A
    quantity on the association would fix it.
18. **4.9, the product line:** read as leaving PRODUCT REQUIREMENT and optional, since Table
    4.11 names no product and its desired features say what's wanted. If it leaves
    REQUIREMENT instead, a work requirement could name a product too (the PC to repair).
19. **4.9, Table 4.11's dates and 34988:** "May 16 2002" read as 2001 (parts made the day
    after their parent, and before the 2002 request for quotes on them). 34988 seeded with no
    parent, beside 24905, as Table 4.13 pairs them; Table 4.11 has it under ACME's 30003.
20. **4.9, who owns a part:** 30003 is ACME's, its parts ABC Subsidiary's. Read as "owner"
    meaning who answers for the requirement: ABC Subsidiary breaks ACME's need into lines it
    will fill. If "owner" means whose need it is, the parts should be ACME's too.
21. **4.10, Table 4.12's dates and types:** 23498 read as January 12, 2002; as printed, it
    predates both requirements it carries and gives thirteen months to answer. 38967 read as
    an RFP, as Table 4.12 has it (Table 4.13 says RFQ).
22. **4.11, Table 4.14's dates:** 36908 read as issued March 12, 2002 (as printed, a year
    before it's valid). Table 4.15 (shared later) settles which requests the quotes answer:
    36908 answers ACME's RFQ 38948, 35678 the RFP 38967, so the seed now links them so
    (35678 had been linked to the RFI 23498). Both requests are dated March 13, 2002, after
    the quotes that answer them (by a day, by three weeks). Seeded as printed: either the
    request dates or the quote dates are the slip. A check for quotes issued before the
    request they answer would flag both book rows, so there is none yet.
23. **4.12, Table 4.16's 10002 and Ch 2's customer relationship:** the agreement names ABC
    Corporation as supplier and ACME as customer, and is tied to "the" customer relationship.
    Ch 2's only one for ACME (Table 2.5) is with ABC Subsidiary. Linked to it as printed, so
    the check "the relationship's parties play roles in the agreement" flags the book's own
    row. Either the parent signs for its subsidiary (and the rule should accept a parent
    through the org rollup), or Silverston means a relationship with ABC Corporation, which
    Ch 2 doesn't seed.
24. **4.12, AGREEMENT's subtypes as type rows:** PRODUCT over SALES and PURCHASE, EMPLOYMENT,
    and OTHER over Table 4.16's partnership (and our distribution agreement), all rows of
    `agreement_type`. If a later figure hangs a line on SALES AGREEMENT alone, it needs a
    subtype table, as SALES ORDER got.
25. **4.12, when a relationship-tied agreement may start:** read as while the relationship
    is current (a check). Whether it must also end before the relationship does isn't
    checked.
26. **4.13, applicability with nothing of a kind:** read as "no limit of that kind": an item
    with no product rows applies to every product. The other reading (none = applies to
    nothing) makes every clause list its products. An organization applicability matches
    the order's placing or bill-to party; a geographic one the ship-to address, at any depth
    of boundaries.
27. **4.13, the addendum's arc and dates:** exactly one of agreement and item (a check), and
    effective while its agreement is (a check). Its dates are drawn optional, so an addendum
    with no effective date is allowed and counts as never in force in our queries.
28. **4.13, an item inside an item:** read as inside the same agreement (a check). A
    sub-agreement is an item, not an AGREEMENT of its own, so it can't have its own parties
    or dates; the book may mean a lighter thing than our word suggests.
29. **4.14–4.16 as a submodel of their own:** Silverston puts terms, pricing and the link to
    orders under the same heading as agreement definition and items. We made them submodel 7
    (agreement terms and pricing) rather than growing submodel 6: they answer a different
    question (what was agreed, and how it reaches an order), card 15's Anki id stays stable,
    and submodel 6's five ponders were taken. Merge them if you'd rather practise agreements
    as one, about 3 hours instead of 6.
30. **4.14, the term subtypes as TERM TYPE's top rows:** legal, financial, incentive,
    threshold and other head `term_type`, now a hierarchy, and 4.7's and 4.11's term types
    are filed under them (our filing). Other readings: the subtypes belong to agreement
    terms only (a kind column on `agreement_term`), or TERM TYPE stays flat and the kind is a
    second lookup.
31. **4.14, Table 4.18's dates:** 23884's term has none though FROM DATE is drawn mandatory
    (seeded with the agreement's start; 23884 itself is ours, Table 4.16 doesn't have it).
    10002's quantity cap runs to December 31, a day past the agreement and the diskettes
    term, both ending December 30. Seeded as printed, so the check flags the book's row:
    either the cap or the agreement's end date is the slip.
32. **4.14 and 4.16, AGREEMENT's THRU DATE drawn mandatory,** where 4.12 drew it optional.
    Kept optional: an employment agreement like William's has no end. If Silverston means
    every agreement to end, 86749 needs a made-up date.
33. **4.14 and 4.15, a cap and a discount at the same 1,000 reams:** the cap read as
    cumulative over its dates, across every line the item governs (the text: the item holds
    only for the first 1,000 reams), so 12574's 300 reams past it are flagged. But Table
    4.19's 2% discount starts at 1,000 reams on one line, which only an order using the whole
    year's cap could earn. Is the cap per order, or the break meant for something else?
34. **4.15, AGREEMENT PRICING PROGRAM as a subtype table:** now that it has a line of its
    own, as Ch 3's unit-of-measure subtypes did, with the item type kept as discriminator
    and a check that both agree. PARTY TYPE's "based on" line isn't drawn: read as
    abbreviation and kept, though an agreement price rarely needs it (the agreement names
    its parties).
35. **4.15, Ch 3's queries and agreement prices:** a list price is now a component with no
    program, but Ch 3's price list, price-a-line and overlap check predate the column and
    read every component as a list price. Our agreement prices stay out of their way only
    by carrying a region or old dates, which is why 70001's paper and copier programs have
    no components. At the overview: should Ch 3's queries say "no program", and is that a
    refactor in Ch 3 or a note?
36. **4.15, Table 4.19's regions:** Eastern and Western regions are new boundaries, read as
    the US split by the Mississippi (Illinois east, Missouri west), so ACME's St. Louis
    addresses get 7.50. Table 4.19 gives no dates, currency or pricer: the agreement's
    dates, USD and ABC Corporation.
37. **4.16, a view, sales lines only:** the figure draws nothing new, so the link is a view
    (4.13's applicability for every item type). Purchase lines aren't matched: there the
    agreement's parties meet the order's supplier (the taker), not its placer. Feature lines
    aren't matched either. Is either worth building?
38. **4.17, the generic order parties:** the overall model draws ORDER ROLE and the two
    order contact-mechanism tables (4.5), not 4.3's and 4.4's columns, nor SALES and PURCHASE
    ORDER. That answers point 8: 4.5 is the overall model. Do 4.3's and 4.4's columns become
    comparison only (as Ch 2 kept 2.2a), or stay as the faster, checkable version?
39. **4.17, ORDER REQUIREMENT COMMITMENT to ORDER:** 4.9 draws it to ORDER ITEM, which our
    build keeps (a need is filled line by line, with a quantity). Read as the overall
    figure's simplification.
40. **4.17, what's left out:** contact mechanisms themselves, party roles, item roles and
    associations, the request, quote and requirement roles, responding parties, desired
    features, work efforts, addenda, applicabilities and every lookup. Read as abbreviation,
    as for Fig 3.11. ORDER ITEM ROLE is the one that may be meant: 4.17 draws roles on the
    order only.
41. **4.16, a retroactive end (chat, 2026-10-20):** ending an agreement back in time takes
    the lines placed after the new end out from under it, while their prices stay. Read as
    intended: the order keeps what was agreed (price, adjustments, terms) and which agreement
    governed it is derived, so the mismatch shows up. Keep the view only, or also store the
    item that set the price on the line (one nullable column), with the view as its check?
42. **4.6, Table 4.8 (shared 2026-10-26), an amount per unit:** order 12560 has four
    adjustments: on line 3 (the diskettes, 6 at 7.00) a discount of 1.00, which the text
    calls "off each unit"; on the whole order a 10% discount, a 10.00 surcharge for delivery
    outside the normal area and a 1.50 order processing fee. Ours stores an amount as the
    total for its order or line (the 75.00 set-up fee), so the diskette row would take 1.00
    off where the book means 6.00. Per unit for every line adjustment, per unit only for some
    types, or a column saying which? Ch 7 read its amounts per unit too. Table 4.8 isn't in
    the seed yet: add it in the refactor. The table identifies the line by order + seq id, the
    book's composite key, which is why its line row also shows the order (point 10).
    **Outcome (2026-10-26): changed, the amount is always the total charged** (the user's
    call: no step through the quantity or a per-unit flag, and it reads like the percentage,
    which is of the total too). Table 4.8's diskette row is stored as 6.00, a recorded
    deviation from the book's 1.00; the "1.00 each" lives in Ch 3's price component that
    produced it. The cost: if the line's quantity changes, the adjustment is worked out
    again, as the unit price and the tax are (the snapshot). Refactor: seed Table 4.8's four
    rows; card 11's key says an amount is the total charged.
43. **4.2 and 4.6, a discount in the unit price or as an adjustment (chat, 2026-10-26):**
    the same discount can be folded into the line's unit price (6.00 a box) or kept as an
    adjustment (7.00 a box, 6.00 off the line), and nothing tells the two apart. Both at
    once counts it twice, "total discounts given" misses the folded ones, and the "agreed vs
    list" query can't tell a discount from a negotiated price. The book gives both places
    and no rule (as far as pages 125–127 go).
    **Outcome (2026-10-26): a convention, not enforced** (the user's call): the unit price is
    the price before discounts, and discounts are adjustments; both stay allowed and no check
    is added. A limit of Silverston's design, to revisit when the core app is built (TODO).
    Refactor: card 11's key states the convention.

## Design decisions (book → SQL)

### Fig 4.1 (not built)
- **Not built,** as with an alternate figure: Fig 4.2 replaces it, and building it would add
  six tables (two orders, two line items, customer, supplier) that the next figure throws
  away. The contrast lives in the transcription above and in a 4.2 query that answers "every
  order for the pen, both directions" from one table. Unlike Fig 2.2a's flat person (built as
  `person_flat`), 4.1 has almost no attributes, so its seed would show little. Points to
  discuss, point 1.

### Fig 4.2
- **ORDER is a reserved word,** so the table is `"order"`, quoted. Only the table name needs
  the quotes (`from "order" o`); `order_id`, `order_date` and `order_item` are plain.
- **SALES ORDER and PURCHASE ORDER → `order_kind`** (SALES / PURCHASE), as `product_kind` in
  Ch 3: no attributes of their own here. SALES ORDER gets a subtype table in 4.3, when it gets
  relationships of its own.
- **ORDER ITEM keeps a surrogate `order_item_id`** and the book's identifier as a plain
  `order_item_seq_id` column (the line number). Two lines with one number on an order is a
  data-quality query (seed: purchase order 12564's two line 2s).
- **No `order_item_kind`:** an item's kind is its order's kind, so a second discriminator would
  store one fact twice. SALES ORDER ITEM has an attribute, so it gets a subtype table
  (`sales_order_item`); PURCHASE ORDER ITEM has none and gets no table (until 4.4). A data-quality query
  checks both ways: every sales item has its row, and no row sits on another order (seed: a
  row on the purchase order's paper line).
- **`product_id` and `product_feature_id` are both nullable,** and point 2's reading is three
  data-quality queries: both or nothing (seed: the copier's scan-to-email line naming the
  copier too), ordered for an item on another order (seed: a Black line on Ben's order pointing
  at 12562's pen), and the feature not applying to the parent's product on the order date
  (seed: a red pen in 2025; red was dropped in 2020).
- **`ordered_for_order_item_id`** for the recursive line, named after the "ordered for" end. A
  check stops an item being ordered for itself; longer loops are possible, so the tree query
  carries a depth guard.
- **Quantity and unit price:** a check keeps the quantity positive and the price not negative
  (a selectable colour is 0.00). The quantity is in the product's unit of measure (Ch 3). The
  book gives the price no currency; ours are USD, as Ch 3 did for order values.
- **Products not on sale on the order date** are a data-quality query on sales orders only
  (seed: two diskette boxes in 2024; their sales stopped in 2006). A purchase order may buy what
  we no longer sell.
- **Order 12560 is Table 4.2's order,** with its prices, which aren't our Ch 3 list (the pen
  lists at 2.50, the book's order has 12.00). The "agreed vs list" query keeps that on purpose:
  the order keeps what was agreed. Its date is Table 4.3's (June 8, 2001). Table 4.3's 23000
  isn't seeded; A2395 is (Fig 4.4), because Tables 4.9 and 4.11 build on it.

### Fig 4.3
- **SALES ORDER becomes a subtype table** (`sales_order`, sharing `order_id`), now that it has
  relationships of its own, as GOOD did in Ch 3's Fig 3.3. `order_kind` stays the
  discriminator; a data-quality query checks the two agree (seed: order 12567, a sales order
  with no `sales_order` row).
- **Party lines → `<line>_party_role_id` columns referencing `party_role`:**
  `placed_by_party_role_id`, `taken_by_party_role_id`, `bill_to_party_role_id` on
  `sales_order`, and `ship_to_party_role_id` on `sales_order_item`. A plain FK can't say which
  role type, so a data-quality query walks Ch 2's `role_type_ancestor` (a role type below the
  expected one counts; seed: order 12566 billed to Contoso's SHIP_TO role), and another checks
  the role was current on the order date (seed: Ben's order of 2023-03-15, made while he was
  still a prospect).
- **PLACING_CUSTOMER is a new `role_type` row** under Ch 2's CUSTOMER, beside bill-to, ship-to
  and end-user. ACME, Contoso and Ben get placing roles.
- **Contact mechanism lines → `<line>_contact_mechanism_id` columns** referencing
  `contact_mechanism`, of any kind. Whether the party has that mechanism on file is a review
  query, not a check: shipping to an address the customer doesn't own (collecting at our
  warehouse, a one-off site) is allowed.
- **The ship-to columns are added to `sales_order_item`** with `alter table`, as Ch 3 added
  columns to `product`. Feature items leave them empty; the queries take the parent item's.
- **No bill-to stored as a default:** a null bill-to falls back to the placing customer in the
  queries (point 3), so one fact isn't stored twice.
- **`order_role` has a surrogate key;** the identifier (order + party + type, point 4) is a
  data-quality query (seed: the purchase order's approval entered twice). So is "the shares of
  one type on one order add up to at most 100" (seed: 100% + 25% for order 12562). A check keeps
  each share between 0 and 100.
- **`order_role_type` is a lookup of its own** (point 5): SALESPERSON, ENTERED_BY, APPROVER,
  REVIEWER, our examples.
- **12560's parties are Table 4.5's:** ACME places it from 234 Stretch Street and is billed
  there, ABC Subsidiary takes it at 100 Main Street, and its lines ship to 2300 Drident
  Avenue (1, 2) and 234 Stretch Street (3). ACME gets bill-to and ship-to roles, and the
  three addresses go on file (the cities are ours: St. Louis for ACME, Springfield for ABC).
  Table 4.5's 23000 and 24830 and Table 4.6's five people aren't seeded: they'd add parties
  that show nothing new.
- **`contact_mechanism_display_name`**, a helper view (no book entity): one line of text per
  contact mechanism, so the queries can show addresses and numbers. Its name follows
  `party_display_name`, which also lets the explorer label contact mechanism ids.

### Fig 4.4
- **PURCHASE ORDER and PURCHASE ORDER ITEM become subtype tables** (`purchase_order`,
  `purchase_order_item`), now that they have relationships, as SALES ORDER did in 4.3.
  `order_kind` stays the discriminator, and two data-quality queries check it both ways
  (seed: sales order 12567 keyed on the purchase form, with a `purchase_order` row and a
  `purchase_order_item` row).
- **The same column names as `sales_order`,** so a reader sees the mirror. A question that
  spans both directions (Contoso's orders) is a union of two near-identical selects: the cost
  Fig 4.5 removes.
- **Four `role_type` rows:** BUYER, a grouping (no `applies_to_kind`, never assigned, like
  Ch 2's PERSON_ROLE), with PLACING_BUYER, BILL_TO_PURCHASER and SHIP_TO_BUYER under it, open
  to either kind of party. SUPPLIER is Ch 2's (organizations only). Northwind gets the three
  buyer roles, and Chloe a placing-buyer role from 2023-09-01, when she joined.
- **The party checks are 4.3's, copied** onto the purchase lines: wrong role type (seed: 12569
  taken by Contoso's BILL_TO_CUSTOMER role, not its SUPPLIER role) and role not current on the
  order date (seed: 12570, dated 2023-05-10, placed by Chloe's buyer role).
- **A ship-to address the buyer doesn't have on file is allowed,** and a query labels it (seed:
  12568's drop-shipped copier). Whether buyer roles must belong to our own organizations is
  not drawn and not checked (point 7).
- **`item_description` stays on `order_item`** (point 6), so `purchase_order_item` holds only
  the ship-to pair.
- **Fantastic Supplies gets an order-desk e-mail** (contact mechanism 31), where our purchase
  orders are taken.
- **A2395 is Table 4.7's purchase order,** stored as `order_id` 2395 (our keys are numbers).
  New parties: Ace Cleaning Service (the supplier) and ABC Retail Store (where both lines
  ship; an informal organization, a store of ABC's). ABC Subsidiary places it, ABC
  Corporation pays. Its two lines are Table 4.3's, with no product: our catalogue sells
  neither a cleaning service nor a cleaning kit, so each line's description says what it is.

### Fig 4.5
- **Four new tables, each with a surrogate key:** `order_item_role`, `order_item_role_type`,
  `order_contact_mechanism`, `order_item_contact_mechanism`. ORDER ROLE and ORDER ROLE TYPE
  are 4.3's tables. Each identifier (three parents) is a data-quality query (seed: the
  family's billing address entered twice on 12571).
- **Built beside 4.3 and 4.4** (point 8). Order 12571 has its `sales_order` row with every
  column empty, and its `sales_order_item` rows, so the earlier subtype checks still hold. A
  data-quality query stops one order naming the same job both ways (seed: a BILL_TO order role
  for Ben on 12561, which already has a bill-to column), and the "who pays" query reads
  whichever model holds the answer.
- **`order_role_type` gains PLACED_BY, TAKEN_BY and BILL_TO,** direction-neutral (point 9).
  **`order_item_role_type`** is a lookup of its own (SHIP_TO, END_USER, INSTALLER): the third
  role-type table, after Ch 2's `role_type` and 4.3's, and more weight for TODO's ROLE TYPE
  refactor (point 5).
- **`contact_mechanism_purpose_type` is Ch 2's table,** not a copy. It gains ORDER_PLACING,
  ORDER_TAKING and DELIVERY_CONTACT; BILLING and SHIPPING are reused.
- **"One per order" is a data-quality query:** one placer, taker and bill-to per order, one
  placing, taking and billing mechanism, and one ship-to party and address per item (seed:
  12571 billed to the family and to Ana).
- **No fallback to the parent item** for a feature's ship-to here: 12571 has no feature items.
  The rule from 4.3 (a feature ships with its item) would carry over unchanged.

### Fig 4.6
- **The six subtypes become the top level of `order_adjustment_type`** (DISCOUNT, SURCHARGE,
  SALES_TAX, SHIPPING_AND_HANDLING, FEE, MISCELLANEOUS_CHARGE), with a `parent_type_id` for
  finer types under them (loyalty and volume discounts, rush surcharge, freight, set-up and
  small-order fees): Ch 3's cost component move. A data-quality query checks every type rolls
  up to one of the six (seed: GIFT_WRAP, with no parent).
- **`order_id` and `order_item_id` are both nullable;** exactly one set is a data-quality query,
  as 4.2's product or feature (no arc drawn; point 10). Seed: a volume discount naming order
  12562 *and* its line 3.
- **An amount or a percentage, exactly one:** a data-quality query (seed: a rush surcharge with
  both). Check constraints keep the amount not negative and the percentage in (0, 100]. Where
  both are set, the queries use the amount.
- **Where an adjustment names both an order and an item,** the queries let the item win (its
  value and its order), so nothing is counted twice while the check waits for a fix (point 10).
- **The sign comes from the top-level type:** DISCOUNT reduces, every other type adds. The
  queries find the top with a recursive walk, as Ch 3's cost queries do.
- **A percentage is of the value before any adjustment** (point 11): the order's lines for an
  order adjustment, the one line for an item adjustment. A feature's line is a line of its own.
- **`sales_tax_lookup`:** the boundary (required), the category (null = every category) and
  the percentage, with a surrogate key standing in for the book's seq id. No dates (point
  12). A data-quality query finds two rates for one boundary and category (seed: Missouri's
  general rate twice); the tax query takes the lower id.
- **Which rate applies to a line:** every boundary its ship-to address lies in (Ch 2's
  `postal_address_boundary`, walked up through `geographic_boundary_ancestor`) adds its own
  rate, and per boundary a rate for the product's category (or a category above it, Ch 3's
  `product_category_ancestor`) beats the general one. The query sets it against the rate
  charged (seed: 12561's paper charged the general rate, where Missouri taxes paper lower).

### Fig 4.7
- **ORDER STATUS TYPE → an ORDER_STATUS group in Ch 2's shared `status_type`,** like the
  relationship, event and case statuses (point 15). A data-quality query checks an order
  status comes from the group (seed: 12566 given Ch 2's CASE_OPEN).
- **`order_status` and `order_term` keep the book's own ids** (surrogate keys) and have
  nullable `order_id` and `order_item_id`. Exactly one of them is a data-quality query shared
  by both tables (point 14; seed: an approval for 12562 and its line 1 at once, and a warranty
  term the same way).
- **`status_datetime` is a `timestamptz`,** the chapter's first time of day: statuses change
  within a day. The current status is the latest row. A status dated before its order was
  placed is a data-quality query (seed: 12565 "received" two weeks before its order date).
- **Our order statuses:** received, approved and cancelled (facts nothing else records), and
  backordered, shipped, invoiced and completed (derivable once shipments and invoices exist;
  stored, as the book allows). A backorder no purchase line backs is caught in 4.8.
- **`term_type` is a flat lookup** with Table 4.9's five types and two of ours (payment due
  within so many days, months of warranty). Ids name the unit (`_PCT`, `_DAYS`, `_MONTHS`),
  since the value doesn't carry one.
- **`term_value` is a nullable `numeric`** (point 13): Table 4.9's values are numbers or
  nothing. One term type twice on the same order or item is a data-quality query (seed: 12561
  due in 30 days and in 45).
- **Table 4.9's terms are seeded as given:** 12560's two order terms and its pen line's, and
  A2395's two on its cleaning line (order 2395, item 27).

### Fig 4.8
- **`order_item_association` references the subtype tables,** `sales_order_item` ("from") and
  `purchase_order_item` ("to"), so a plain FK keeps the direction: a reason the subtype tables
  were worth building. Surrogate key; the identifier (both items) is a data-quality query
  (seed: 12561's copier linked to 12568's twice).
- **Table 4.10's orders 13480 and 23490 are seeded with one line each.** The products,
  quantities, dates and parties are ours: ACME buys 200 pens from ABC Subsidiary, which buys
  them from Fantastic Supplies for ABC Retail Store.
- **A purchase line for another product** than the sales line it fills is a data-quality query
  (seed: 12564's books "filling" 12562's pens). Lines without a product are left out.
- **A recorded backorder with no purchase line behind it** is a data-quality query: the 4.7
  status checked against 4.8's facts (seed: Ben's engraved pen set on 12563).
- **No quantity** (point 17): the queries show both sides' quantities and flag where the
  split is unknown.

### Fig 4.9
- **Two discriminators on `requirement`:** `requirement_origin` (CUSTOMER / INTERNAL) and
  `requirement_kind` (PRODUCT / WORK). Neither subtype set has attributes.
- **PRODUCT REQUIREMENT gets a subtype table,** `product_requirement` (sharing the PK), since
  it has relationships of its own (the product, desired features), as SALES ORDER did in 4.3.
  `product_id` is nullable (point 18). A data-quality query checks the kind and the table
  agree (seed: Northwind's dock-door repair, a WORK requirement, with a product row). WORK
  REQUIREMENT gets nothing until Ch 6.
- **`part_of_requirement_id` and `facility_id` are plain FKs;** a check stops a requirement
  being part of itself, and the tree query carries a depth guard.
- **`desired_feature.optional_ind` is `boolean not null default false`:** drawn optional, but
  a missing answer means a must-have. A desired feature the requirement's product doesn't
  offer on the creation date is a data-quality query (seed: Contoso wants the pen in red,
  dropped in 2020). Requirements with no product are matched to the catalogue by a query.
- **REQUIREMENT STATUS TYPE → a REQUIREMENT_STATUS group in Ch 2's `status_type`,** as 4.7's
  order statuses (point 15). `status_date` is a date, as drawn; a surrogate key stands in for
  the identifier. A data-quality query checks the group (seed: an order status on the
  dock-door repair).
- **`requirement_role_type` is a lookup of its own,** the fourth role-type table (point 5):
  owner, requester, approver. `requirement_role` is dated (exclusive thru date). Two owners
  at once is a data-quality query (seed: Contoso's copier also owned by Ben).
- **`order_requirement_commitment`:** a surrogate key, the order item, the requirement and a
  mandatory positive quantity. Commitments beyond the requirement's quantity are a
  data-quality query (seed: 13480's pens committing 40 more to ACME's 40 blue pens). Which
  direction of order fills which origin of need isn't checked: we may buy to fill a
  customer's need (4.8).
- **Table 4.11 keeps its ids;** "May 16 2002" stored as 2001-05-16 and 34988 with no parent
  (point 19). Our own requirements are 50001–50004: Northwind's paper for the Chatham
  warehouse, Contoso's copier, the dock door, Contoso's red pens.
- **A new Ch 3 feature, "Formatted"** (OTHER), for the diskettes of 30007.

### Fig 4.10
- **RFI, RFP and RFQ → rows of a `request_type` lookup:** they have no attributes or lines of
  their own, and Table 4.12 calls the column REQUEST TYPE.
- **`request` keeps the book's id;** a check keeps the answer date on or after the request
  date. **`request_item`** has a surrogate key and the seq id as a plain column;
  `required_by_date` is mandatory, as drawn (the seed's dates are ours).
- **`requirement_request` and `responding_party`** have surrogate keys. Their identifiers
  (the same requirement twice on an item, the same party twice on a request) share one
  data-quality query (seed: 38948's diskettes entered twice).
- **A requirement sent out before it existed** is a data-quality query (seed: Northwind's RFP
  for the dock door, dated before the requirement). It's also the evidence for point 21:
  Table 4.12's 23498, as printed, would be caught.
- **A request sent to a party before the request's own date** is a data-quality query (seed:
  Northwind's RFQ to Paperline). An incoming request's responding party (us) has no date sent.
- **`request_role_type`** (originator, contact, approver) is the fifth role-type lookup (point
  5). Two originators on one request is a data-quality query (seed: Chloe entered as
  originator beside Northwind on 61001).
- **New parties, ours:** two PC repair vendors, Ridgeway PC Repair and Byte Doctors, with
  e-mail addresses; ABC Subsidiary gets Table 4.5's supplies@ABC.com, where ACME's RFQ
  arrives. Our requests: Northwind's RFQ 61001 for 50001's paper (to Fantastic Supplies and
  Paperline), and its RFP 61002 for the dock door (to Contoso, which manages the Chatham
  warehouse in Ch 2).

### Fig 4.11
- **PROPOSAL, PRODUCT QUOTE and OTHER QUOTE → rows of a `quote_type` lookup,** as requests'
  types (Table 4.14's QUOTE TYPE).
- **`quote` names its two parties in columns,** `issued_by_party_id` (mandatory) and
  `given_to_party_id` (optional), plain FKs to PARTY as drawn, beside the generic QUOTE ROLE:
  4.3's specific-plus-generic pairing again. `valid_thru_date` is exclusive, the repo's
  convention: Table 4.14's "valid until March 19" is stored as March 20.
- **`quote_item`:** a surrogate key and the seq id; `product_id` and `work_effort_id` both
  nullable, exactly one set (the arc) a data-quality query (seed: a freight line on
  Fantastic's quote naming neither); `request_item_id` optional ("a response to").
- **`order_item.quote_item_id`** is added with `alter table` ("the acceptance of"). An order
  line accepting a quote outside its validity is a data-quality query (seed: 12570's paper,
  ordered in 2023, accepting Fantastic's 2025 quote).
- **`quote_term` reuses `term_type`;** exactly one of quote and quote item is a data-quality
  query (the arc; seed: a warranty term on Paperline's quote and its item at once).
- **`quote_role_type`** (preparer, approver, contact), the sixth role-type lookup (point 5).
- **`work_effort` is Ch 2's,** unchanged: it already has every attribute Fig 4.11 draws. A
  new planned effort, "Repair 29 PCs", is what Byte Doctors' proposal prices.
- **New products in Ch 3's catalogue:** a box of pencils (writing instruments), for Table
  4.14's "pens and pencils"; Table 4.15's Johnson black pen (features black and Johnson) and
  PC repair (a service, maintenance, sold by the hour).
- **Seeds:** Table 4.15's lines on Table 4.14's quotes: 35678 (Ridgeway to ABC Corporation,
  70 hours of PC repair answering the RFP 38967; point 22) and 36908 (ABC Subsidiary to ACME:
  50 reams and 40 black pens answering 38948's items 1 and 2, plus our pencils nobody asked
  for). The text's term on 35678: a central point of contact (a new term type, no value).
  Ours: Byte Doctors' rival proposal 62003 (the planned job, per PC), Fantastic's 62001 (500
  reams at 30.00 for Northwind's RFQ 61001, accepted by 12564's line 1, which the 4.4 seed
  already had) and Paperline's 62002 (recycled paper, not accepted).
- **The quoted product against the need:** when the requirement names no product, the
  comparison query lists the must-have desired features (4.9) the quoted product doesn't
  offer on the quote's date.

### Fig 4.12
- **AGREEMENT's subtypes → rows of `agreement_type`,** a hierarchy with `parent_type_id`
  (Ch 2's `organization_type`): no subtype has attributes, and the figure draws AGREEMENT
  TYPE beside them anyway. Table 4.16's partnership and our distribution agreement sit under
  OTHER. A recursive query finds every product agreement, at any depth (point 24).
- **`agreement`** keeps the book's ids, `text` as a column (allowed in PostgreSQL), and
  `party_relationship_id` as a nullable FK to Ch 2's 2.6a table. `thru_date` is exclusive:
  Table 4.16's December 30, 2002, is stored as December 31. The agreement date (when signed)
  isn't in Table 4.16; the seed uses the starting date.
- **`agreement_role_type`** (supplier, customer, employer, employee, partner, distributor, and
  our signatory) is the seventh role-type lookup (point 5). **`agreement_role`** has a
  surrogate key; agreement + party + type twice is a data-quality query (seed: XYZ entered
  twice as a partner).
- **The relationship's ends must play roles in the agreement:** a data-quality query. It
  catches our 70002 (Chloe's employment, Northwind left out) and the book's 10002 (point 23).
- **An agreement may start only while its relationship is current:** a data-quality query
  (seed: our 70003, Sellers Assistance's distribution deal, begun after its relationship
  ended in 2002; point 25).
- **New parties:** William Jones (a person, ABC Corporation's employee since 1990, through a
  new internal organization role for ABC Corporation and a new employment relationship) and
  XYZ Corporation. Ours: 70001, Northwind's 2025 sales agreement with Contoso on their
  customer relationship, Ben signing for Contoso; 70002 and 70003, the bad rows above.

### Fig 4.13
- **AGREEMENT ITEM's four subtypes → rows of `agreement_item_type`** (section, pricing
  program, exhibit, sub-agreement): no attributes or lines yet. If a later figure hangs
  prices on PRICING PROGRAM, that line can point at `agreement_item` with a check on its
  type, or the type gets a subtype table then.
- **`agreement_item`:** a surrogate key and the seq id; `part_of_agreement_item_id` for the
  dashed loop, with a check against pointing at itself. An item inside an item of another
  agreement is a data-quality query (seed: a section of William's 86749 placed under
  10002's; point 28). `agreement_image` is text, a file reference.
- **`addendum`:** `agreement_id` and `agreement_item_id` both nullable, exactly one set (the
  arc) a data-quality query (seed: a pens addendum naming 70001 and its item). Effective
  outside its agreement's dates is another (seed: a partnership addendum three months after
  489589 ended; point 27).
- **Three applicability tables,** each a surrogate key and two plain FKs: to `organization`
  (Ch 2, keyed on `party_id`), `product` (Ch 3) and `geographic_boundary` (Ch 2).
- **The applicability query** reads "none of a kind = no limit" (point 26): a pricing program
  applies to an order line when its agreement is in force on the order's date and has the
  order's placing or bill-to party in a role, and each kind of limit it has matches the
  placing or bill-to party, the line's product, and the ship-to address (through Ch 2's
  `postal_address_boundary` and `geographic_boundary_ancestor`, at any depth).
- **Seeds, ours** (no table came with the figure): 70001's outline (scope, pricing with
  three programs, an exhibit with an image reference, a consignment sub-agreement with its
  own section), a section each for 86749 and 489589, and four addenda (Contoso's paper price
  lowered from March, the agreement extended to a new office, and the two bad rows).
  10002's two items follow Table 4.17 (shared with Fig 4.14): the paper as a pricing
  program, the diskettes as a section, each limited to its product.

### Fig 4.14
- **AGREEMENT TERM's five subtypes → the top rows of `term_type`,** which gains
  `parent_type_id` and becomes a hierarchy, as `agreement_type` (4.12). The order and quote
  term types of 4.7 and 4.11 are filed under them (our filing: cancellation and payment terms
  as financial, refunds, warranties and cancelling windows as legal, delivery and the
  central contact as other). A recursive query lists each term with its kind (point 30).
- **`agreement_term`:** a surrogate key, the dates, a nullable `numeric` value, and nullable
  `agreement_id` and `agreement_item_id`; exactly one set (the arc) is a data-quality query
  (seed: a delivery term on 70001 and its pens program at once).
- **A term dated outside its agreement** is a data-quality query: from before the agreement
  starts, or past its end (a null thru date means "for as long as the agreement"). It flags
  Table 4.18's own quantity cap (point 31) and our termination clause on 489589, which
  outlives the partnership by a year.
- **Table 4.18's terms are seeded as given,** with new term types (no compete for so many
  days, quantity and dollars not to exceed, buy only from this supplier). 23884 is new and
  ours: a purchase agreement, Ridgeway supplying PC repair to ABC Corporation, March 2002 to
  March 2003. Ours on 70001: payment due in 30 days (financial) and a 2% year-end rebate (an
  incentive).

### Fig 4.15
- **AGREEMENT PRICING PROGRAM → a subtype table, `agreement_pricing_program`,** sharing
  `agreement_item_id`, now that it has a line of its own (Ch 3's `currency_measure`, and the
  note under 4.13). `agreement_item_type` stays the discriminator; the two must agree, a
  data-quality query (seed: 70001's exhibit, the price list, entered as a program).
- **`price_component.agreement_item_id`,** added with `alter table`: a nullable FK to the
  subtype. Null is a list price (Ch 3), set is a price agreed in that program.
- **Table 4.19's three components** on 10002's item 1, with the agreement's dates, USD and
  ABC Corporation as pricer. Eastern and Western regions are new REGION boundaries in the
  US, with Illinois in the east and Missouri in the west (point 36). Ours: 70001's pens at
  2.25, delivered in Missouri.
- **Two more checks, both "two paths, so a rule":** an agreement price dated outside its
  agreement (seed: last year's 6.80 keyed on the 2002 program), and one for a product its
  program's applicability doesn't cover (seed: the diskettes priced on the paper program).
- **Ch 3's queries predate the column** (point 35): they still read every component as a
  list price. Ours stay out of their way only because each carries a region or dates long
  past. So 70001's paper and copier programs stay unpriced: a component with no condition
  but the program would collide with the list price in Ch 3's overlap check.

### Fig 4.16
- **No table: a view, `order_item_agreement_item`,** the agreement items governing each
  sales order line. It is 4.13's applicability query for every item type, not only pricing
  programs: the agreement in force on the order date, the placing or bill-to party in one of
  its roles, and each kind of limit the item has matching (none of a kind = no limit, point
  26). Sales lines with a product only; a purchase line would match the supplier's side
  instead, and features are left out (point 37).
- **The agreement price of a line,** in a query: the most specific applicable base price
  among its programs' components (region by the ship-to address at any depth, quantity
  break by the line's quantity), less discounts, plus surcharges, as Ch 3's price-a-line
  does. Components with conditions the order can't answer here (party type, category, order
  value, sale type) are left out; ours use none.
- **Two data-quality queries:** lines charged other than their agreement price, and lines
  past a threshold (a running total over the term's dates, the text's reading that the
  item's prices hold only up to the cap; point 33).
- **Seeds, ours:** ACME's three 2002 orders under 10002, taken by ABC Corporation: 12572
  (600 reams to Drident Avenue at the western 7.50), 12573 (400 reams to the head office at
  7.00, the eastern price, a bad row; and 50 boxes of diskettes, which item 2 governs with
  its exclusivity and no price), 12574 (300 reams in September, past the 1,000-ream cap, a
  bad row).
- **The price check found a slip of our own:** 12562's blue pens, shipped to Contoso in St.
  Louis in March 2025, went at the 2.50 list price, while 70001's pens program (4.13) says
  2.25 delivered in Missouri. The row stays as 4.2 seeded it; the 4.16 seed section lists it
  among the check's catches.

## When NOT to use this
- **A shop that only sells**, and buys through some other system, gets little from the ORDER
  supertype. It costs one discriminator, so it's cheap to keep, but don't model purchase
  orders nobody will enter.
- **A consumer web shop,** where the person who orders nearly always pays and receives: three
  role lines per order are overkill. A `customer` on the order and the addresses on it are
  enough until gifts, company accounts or split shipments show up.
- **Feature items:** if options are never priced or shipped on their own, a list of the chosen
  features under the item (or a configuration code) is simpler than one item per feature.
- **ORDER ROLE:** if the only extra party is ever a salesperson, a `salesperson` column says it
  more plainly. Go generic when the list of order parties keeps growing.
- **Pointing at a contact mechanism only works if mechanisms never change in place** (Ch 2: a
  new address is a new row). A system that edits addresses in place must copy the shipping and
  billing addresses onto the order, or yesterday's orders will "move".
- **Generic roles and mechanisms (4.5)** when the order's parties are fixed and few: the
  columns of 4.3 and 4.4 are easier to read, check and query.
- **Order adjustments (4.6)** when the only change to a price is one flat tax rate: a tax
  column (or a computed total) is plainer. Go to rows when discounts, fees and tax start to
  stack, or apply to single lines.
- **Status history (4.7)** when nobody ever asks when an order changed state and its lines
  never move separately: a `status` column on the order is enough.
- **Order terms (4.7)** when every order runs on the same standard terms: keep those once (in
  an agreement, or the terms printed on the form). Term rows are for what was negotiated for
  this order or this line.
- **Order item association (4.8)** when the business never buys to fill a particular sale (it
  sells from stock and restocks by reorder level, Ch 3's reorder guideline): there is
  nothing to link.
- **Requests (4.10)** when you buy from one supplier at its list price: there is nobody to
  ask. They pay off when several suppliers compete, or customers send formal requests.
- **Quotes (4.11)** when prices come from a published list and nobody negotiates: Ch 3's
  price components already answer "what would it cost?". Quotes are for offers made to one
  party, valid for a while.
- **Requirements (4.9)** when every need goes straight to an order (a small shop buying for
  itself): requirement rows are overhead. They earn their keep when needs are gathered,
  approved, broken down, or filled by several orders.
- **Agreements (4.12)** when every customer buys on the same published terms: there is
  nothing negotiated to record. A contract file attached to the customer is enough until
  agreements need dates, several parties, or their clauses must drive prices and checks.
- **Agreement terms (4.14)** when nobody checks orders against the contract: the signed
  text is enough. Term rows pay off when something adds up the orders under a cap, or
  enforces an exclusivity or a payment term.
- **Agreement pricing (4.15)** when an agreement only ever grants a flat percentage off the
  list: one term (a discount percent) says it. Price components per program pay off when
  agreed prices vary by region, quantity or period, as list prices do.
- **Deriving the agreement (4.16)** when every order is placed against one named contract
  (blanket orders, call-offs): then the order should name it, and the derivation becomes a
  check on that link.

## Open questions
