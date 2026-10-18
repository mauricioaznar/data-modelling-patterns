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

More submodels follow as the rest of the chapter's figures arrive. Figures that answer the
same questions as an existing submodel join it (4.4 and 4.5 joined submodel 1), and its
`Figs` grow.

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

### Points to discuss after the overview (Figs 4.1–4.6)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing. The list moves under the chapter's last figure when that one arrives.

1. **4.1, not built:** read as the book's straw man, which 4.2 replaces, so it gets no SQL
   (STATUS.md lists it as not built). If you'd rather see its failures in data, as with Fig
   2.2a's `person_flat`, we build it at the overview.
2. **4.2, product or feature:** no arc is drawn, yet read as "an item names a product or a
   feature, not both; a feature's item is ordered for a product's item, on the same order,
   and the feature must apply to that product; an item with neither carries a description".
   Built as data-quality queries, not constraints, so the reading is easy to change. Table
   4.4 (shared later) seems to put a feature on the product's own line twice (the pen's blue,
   A2395's billing feature), beside feature lines of their own: if so, the book allows both
   shapes, and the "both or nothing" check should only flag "nothing".
3. **4.3 and 4.4, optionality of the party lines:** all seven on each side read as optional, so the columns are
   nullable. When no bill-to is given, the queries bill the placing customer. That fallback
   is ours, not the book's: is the bill-to meant to be mandatory instead?
4. **4.3, ORDER ROLE's identifier:** read as order + party + type. Bars are visible on "of"
   and "described by" only, but two salespeople on one order need the party in it too.
5. **4.3, ORDER ROLE TYPE vs Ch 2's ROLE TYPE:** this is the second kind of role type, the
   trigger for TODO's refactor (`role_type` as a ROLE TYPE supertype with PARTY ROLE TYPE and
   ORDER ROLE TYPE subtypes). The figure draws ORDER ROLE TYPE alone, so it's its own lookup
   for now; decide at the overview, once more role types have shown up.
6. **4.4, PURCHASE ORDER ITEM's ITEM DESCRIPTION:** drawn on the subtype and on ORDER ITEM
   (4.5 does the same; 4.6 draws it on ORDER ITEM only). Read as one attribute, kept on
   `order_item`. If Silverston meant a second one (the supplier's wording for the line, say),
   it moves to `purchase_order_item`.
7. **4.4, whose buyer roles:** PLACING BUYER, BILL TO PURCHASER and SHIP TO BUYER are grouped
   under a new BUYER type, the mirror of CUSTOMER. Nothing drawn says they must be roles of
   our own organizations (or their employees), so nothing checks it. Should something? Table
   4.7 (shared later) gives every buyer role to one of ABC's own organizations.
8. **4.5 built beside 4.3 and 4.4:** read as an alternate (the text offers it for when roles
   change), and built next to them, as Ch 2 kept Figs 2.5 and 2.6a: order 12571 uses only
   the generic tables, the others the columns, plus generic rows for jobs no column holds. If
   the chapter's overall figure keeps one version, the other becomes comparison only.
9. **4.5, direction-neutral role types:** our new ORDER ROLE TYPE rows (PLACED_BY, TAKEN_BY,
   BILL_TO) serve both directions, and the order's kind says which side is ours. Silverston
   may mean one type per hat (placing customer, supplier, bill-to purchaser…), which keeps
   the role names of 4.3 and 4.4 but doubles the list.
10. **4.6, an order or an item:** no arc is drawn across the two "affecting" lines; read as
    one or the other, never both (a data-quality query). Other readings: an item's adjustment
    also names its order (redundant, but easy to sum), or both are allowed.
11. **4.6, a percentage of what, applied in which order:** the figure doesn't say. Our queries
    take each percentage of the value before any adjustment, so tax is charged on the
    undiscounted price. If Silverston means a sequence (discounts, then tax), an adjustment
    needs a sequence number, or its type an order of application.
12. **4.6, SALES TAX LOOKUP with no dates and no line to the adjustment:** read as a reference
    table the order copies its rate from (the snapshot again). Dates would keep old rates for
    late corrections; we stay with the book.

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

## Open questions
