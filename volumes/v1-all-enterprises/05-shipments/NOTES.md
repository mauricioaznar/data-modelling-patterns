# Vol 1, Chapter 5 — Shipments

## The problem this pattern solves
The naive move treats shipping as a few columns on the order: a ship date, a carrier, a
tracking number, a "quantity shipped" on each line. That holds until a line leaves in two
trucks, one truck carries lines from two orders, goods move with no order behind them at all
(a return, a transfer between two of our own sites), or a supplier ships straight to our
customer (a drop ship). Then the columns repeat, overflow or lie. Ch 5 makes the shipment a
thing of its own: a SHIPMENT header with its SHIPMENT ITEMs, typed by direction, sent from
one party and address to another, with the plan on the header and what actually happened in
a dated status history. It then ties shipments to orders line to line, with a quantity on
each link (ORDER SHIPMENT), so an order line can ship in parts and a shipment line can fill
several orders. The recurring moves: header + items again, subtypes that are really
directions, estimates beside a history of actuals, and the hand-over between two chapters as
an item-to-item link carrying its own quantity.

## Submodels (proposed 2026-10-18, from the figures shared so far)
1. **Shipments, items and status** (Figs 5.1–5.2): what is being shipped, which goods and how
   many, from whom and where to whom and where, of which kind (customer, purchase, return,
   transfer, drop ship), when it was expected and what actually happened?

2. **Shipments and orders** (Fig 5.3): which order lines does each shipment line fill, and
   how much of each; is an order line shipped in full; and did what went out match what was
   ordered (the good, its features, the destination)?

Later figures join a submodel when they answer the same questions, or start one.

## Figures

### Fig 5.1 — Shipment definition
**Transcription** (accepted: ☐; one photo, with Table 5.1; open points under "To check
against the book")

```
SHIPMENT
  # shipment_id
  * estimated_ship_date
  o estimated_ready_date
  o estimated_arrival_date
  o estimated_ship_cost
  o actual_ship_cost
  o latest_cancel_date
  o handling_instructions
  o last_updated
  subtypes (no attributes):
    OUTGOING SHIPMENT   > CUSTOMER SHIPMENT, PURCHASE RETURN
    INCOMING SHIPMENT   > PURCHASE SHIPMENT, CUSTOMER RETURN
    TRANSFER
    DROP SHIPMENT
  -> PARTY                     (many "shipped from" 1 party; party "the sender of" many)
  -> PARTY                     (many "shipped to" 1 party; party "the receiver of" many)
  -> POSTAL ADDRESS            (many "shipped from" 1 address; address "the source of" many)
  -> POSTAL ADDRESS            (many "shipped to" 1 address; address "the destination" of many)
  -> CONTACT MECHANISM         (many "inquired about via" 1 mechanism; mechanism "used to
                                inquire about" many)
  -> TELECOMMUNICATIONS NUMBER (many "facilitated via" 1 number; number "the receiving
                                contact number for" many)

PARTY                          # party_id (Ch 2)
CONTACT MECHANISM              # contact_mechanism_id (Ch 2), subtypes as Fig 2.10:
  POSTAL ADDRESS               (* address1, o address2, o directions)
  TELECOMMUNICATIONS NUMBER    (* area_code, * contact_number, o country_code)
  ELECTRONIC ADDRESS           (* electronic_address_string)
```

**Table 5.1** (shipments, the book's sample, in our words): eight shipments in 2001, each with
its type, estimated ship and arrival dates, and the party and postal address at each end.
Three customer shipments (9000, 9200, 9400) go from ABC Subsidiary at 300 Main Street to
ACME at 234 Stretch Street in March. Two purchase shipments (1146, 1149) come from General
Goods Corporation at 300 Jennifer Street to ABC Corporation at 100 Main Street, also in
March. 1578 sends goods back from ABC Corporation to General Goods in April (a purchase
return). 3485 moves goods from ABC Corporation to ABC Subsidiary in June (a transfer). 4800
goes from ACME at 234 Stretch Street to Sellers Assistance Corporation at 400 Benny Street in
July (a drop shipment). The table has no customer return.

**To check against the book**
- Optionality: the photo doesn't show which half of each line is dashed. Read as: every
  shipment has a sender and a receiver party (Table 5.1 names both every time); its two
  postal addresses, the inquiry mechanism and the receiving number are optional (point 1).
- Where the lines land, read from where each touches the boxes: the second "shipped from"
  and "shipped to" pair on POSTAL ADDRESS, "inquired about via" on the CONTACT MECHANISM
  supertype, "facilitated via" on TELECOMMUNICATIONS NUMBER.
- "used to inquired about" read as "used to inquire about" (a misprint).
- No SHIPMENT TYPE entity is drawn: the subtypes carry no attributes, so they become rows
  (point 2).
- No FACILITY on the figure: the ends are parties and postal addresses (point 3).
- "ACME Corporation" (the customer shipments) and "ACME Company" (4800) read as one party,
  Ch 2's ACME Company, as Ch 4 did.

**Discussion**
- **A shipment is a record of its own, not part of the order.** It has dates, costs and
  handling instructions that belong to moving goods, not to the promise to sell them. A
  transfer between two of our sites, or a return, has no order behind it at all. How
  shipments meet orders is Fig 5.3.
- **The subtypes are directions.** Outgoing: we send (to a customer, or back to a supplier).
  Incoming: we receive (from a supplier, or back from a customer). Transfer: from one of our
  organizations to another. Drop shipment: from a supplier straight to our customer, so we
  never touch the goods. Each type therefore says whether each end is one of our own
  organizations, which the data can check: ABC Corporation and ABC Subsidiary hold Ch 2's
  INTERNAL ORGANIZATION role; ACME, General Goods and Sellers Assistance don't. 4800 has
  neither end ours, which is what makes it a drop ship.
- **Customer shipment and purchase return both go out.** What separates them isn't the
  direction but the reason: one fills a sales order line (Fig 5.3), the other sends back
  what a supplier shipped us (Fig 5.2's "in response to"). (Ponder 2.)
- **Parties, not party roles.** Ch 4's order named "ACME as placing customer", a dated role.
  A shipment names who sends and who receives, and its type already says which side is ours.
  (Ponder 1.)
- **Party and address apart.** The party says who; the postal address says where. ACME could
  receive at its head office or at its delivery address. The address is a shared Ch 2
  contact mechanism, so "this address is one the party has" is a rule no foreign key holds.
- **Two more mechanisms, each with a job:** where to inquire about the shipment (any kind: a
  phone, an e-mail), and the number to call at the receiving end (a phone, so that line ends
  on TELECOMMUNICATIONS NUMBER).
- **The header holds the plan.** Estimated ready, ship and arrival dates and the estimated
  cost are forecasts; the latest cancel date is the last day the shipment can still be
  called off. Only the actual cost is a fact. When it really shipped and arrived goes into
  Fig 5.2's status history.

### Fig 5.2 — Shipping detail
**Transcription** (accepted: ☐; one photo, with Tables 5.2 and 5.3 and the text between
them; open points under "To check against the book")

```
SHIPMENT ITEM
  # shipment_item_seq_id
  * quantity
  o shipment_contents_description
  -> SHIPMENT                (many "part of" 1 shipment, bar: part of the identifier;
                              shipment "composed of" many)
  -> GOOD                    (many "a shipment of" 1 good; good "shipped via" many)
  -> SHIPMENT ITEM           (many "in response to" 1 item; item "generating" many;
                              dashed at both ends)

SHIPMENT STATUS              (no identifier of its own: both lines carry a bar)
  * status_date
  -> SHIPMENT                (many "the history for" 1 shipment, bar; shipment "tracked
                              using" many)
  -> SHIPMENT STATUS TYPE    (many "defined using" 1 type, bar; type "used to define" many)

SHIPMENT STATUS TYPE         (no attributes drawn)
SHIPMENT                     (as 5.1: the same attributes and subtypes)
GOOD                         (Ch 3)
```

**Table 5.2** (shipment items, the book's sample, in our words): shipment 9000, the customer
shipment to ACME, carries three lines: 1,000 Jones #2 pencils, 1,000 Goldstein Elite pens and
100 boxes of HD diskettes. The column is headed "inventory item", though the text beside it
says the inventory items may not be known when a shipment is scheduled, and that they reach
the shipment item only through entities shown later in the chapter (shipment receipt and
item issuance).

**Table 5.3** (shipment statuses, in our words): 9000 was scheduled on March 4, 2001 (the day
it was first recorded), shipped on March 7 and received the same day. Drop shipment 4800 was
scheduled on July 9 and cancelled on July 10, both printed with the year 2002.

**The text beside them**, in short: possible statuses are scheduled, shipped, in route,
delivered and cancelled. The estimated ship and arrival dates stay on SHIPMENT; SHIPMENT
STATUS records the dates (and times, when needed) things actually happened.

**To check against the book**
- The GOOD line read as optional at the item end: an item names a good or describes its
  contents (a sample, documents, display stands) in its contents description (point 5).
- "In response to" is dashed at both ends: an item may answer one other item, and an item
  may be answered by many (point 10).
- SHIPMENT STATUS has no identifier attribute: its two barred lines identify it, so a
  shipment has at most one status of each type (point 6).
- SHIPMENT STATUS TYPE drawn alone with no attributes: read as another group in Ch 2's
  STATUS TYPE, as Ch 4 did for order statuses (point 7).
- Table 5.3 dates 4800's statuses in 2002, while Table 5.1 expects it to ship on July 12,
  2001: read as 2001 (point 8).
- Table 5.3 says "received" where the text lists "delivered": both kept (point 9).
- Table 5.2's "inventory item" column holds products: read as the good.

**Discussion**
- **Header + items again.** The shipment is the truck; its items are what's on it, numbered
  within it (the bar on "part of"). An item is a good and a quantity, not an order line: one
  shipment line can carry goods for several order lines, which Fig 5.3 records.
- **What isn't a catalogue good** still travels: the contents description says what it is.
- **"In response to" covers returns and replacements with one line.** A customer return's
  line answers the line of the customer shipment it came from; a replacement line could
  answer the return. The shipment's type says which case it is. Ours: 9600 returns 50 of
  9000's pens; 1578 returns 100 of 1146's pencils.
- **The plan on the header, the facts in a history.** Comparing the estimated ship date with
  the "shipped" status answers "did it leave on time?", and the estimated arrival with
  "delivered" or "received" answers "did it arrive on time?" The current status is the
  latest row. (Ponder 3.)
- **One status of each type per shipment.** The two bars make shipment + type the
  identifier: a shipment is shipped once, received once. Ch 4's ORDER STATUS had an id of its
  own and could repeat a status. A truck sent back to the depot and out again can't record
  "in route" twice here. (Ponder 4.)
- **Status on the shipment only, never on one item,** unlike Ch 4's order or item status.
  The items travel together; what was received or rejected line by line is for the receipt
  entities the text promises. (Ponder 5.)

### Fig 5.3 — Shipment-to-order relationship
**Transcription** (accepted: ☐; one photo, with Tables 5.4–5.7 on three more and the text
between them; open points under "To check against the book")

```
ORDER SHIPMENT               (no identifier of its own: both lines carry a bar)
  * quantity
  -> ORDER ITEM              (many "the shipment of" 1 order item, bar; order item
                              "shipped via" many)
  -> SHIPMENT ITEM           (many "shipped via" 1 shipment item, bar; shipment item
                              "the shipment of" many)

SHIPMENT ITEM FEATURE        (no attributes; both lines carry a bar)
  -> SHIPMENT ITEM           (many "for" 1 shipment item, bar; item "shipped with" many)
  -> PRODUCT FEATURE         (many "of" 1 feature, bar; feature "shipped via" many)

SHIPMENT ITEM                (as 5.2: # shipment_item_seq_id, * quantity,
                              o shipment_contents_description)
  -> GOOD                    (many "a shipment of" 1 good; good "shipped via" many)

ORDER ITEM                   (as Ch 4: # order_item_seq_id, o quantity, o unit_price,
                              o estimated_delivery_date, o shipping_instructions,
                              o item_description; subtypes PURCHASE ORDER ITEM and SALES
                              ORDER ITEM (o corresponding_po_id))
  -> PRODUCT                 (many "for" 1 product; product "ordered via" many)
  -> PRODUCT FEATURE         (many "for" 1 feature; feature "ordered via" many)

PRODUCT                      (Ch 3: # product_id, * name, o introduction_date,
                              o sales_discontinuation_date, o support_discontinuation_date,
                              o comment; subtypes GOOD, SERVICE)
PRODUCT FEATURE              (Ch 3: # product_feature_id, * description; subtypes PRODUCT
                              QUALITY, COLOR, DIMENSION (* number_specified), SIZE, BRAND,
                              SOFTWARE, HARDWARE, BILLING and OTHER FEATURE)
```

**Table 5.4** (order items, the book's sample, in our words): order 100 asks for 1,500 Jones
#2 pencils, 2,500 Goldstein Elite pens and 350 standard erasers; order 200 for 300 Goldstein
Elite pens and 200 boxes of HD diskettes.

**Table 5.5** (shipment items, in our words): 9000 carries 1,000 pencils, 1,000 pens and 100
diskettes (Table 5.2's lines); 9200 carries 350 erasers, 100 diskettes and, as the skewed
photo reads, a third line of 1,500 pencils; 9400 carries 500 pencils.

**Table 5.6** (order shipments, in our words): order 100's pencil line ships 1,000 on 9000
and the other 500 on 9400, so it is filled in full over two shipments. Its pens ship 700 on
9000, its erasers 350 on 9200. Order 200's pens ship 300 on 9000 (with order 100's 700,
that is 9000's whole line of 1,000), its diskettes 100 on 9000 and 100 on 9200.

**Table 5.7** (features, in our words): both pen lines were ordered in blue (order 100's
2,500 and order 200's 300), and 9000's pen line of 1,000 went out black. The text gives two
readings: a mistake, or a deliberate substitute the customer accepted because blue was out
of stock.

**The text beside them**, in short: one order line can be spread over several shipments, and
one shipment line can deliver lines of several orders. Combining two orders on one line
assumes rules elsewhere make sure both go to the same place and are for the same product.
The link is drawn to the order item, not the order (the photo cuts off the reason). An
alternative stores the shipped features on ORDER SHIPMENT; differences could also be worked
out from the inventory items behind a shipment line, but that fails for a shipment only
scheduled, with no stock tied to it yet. The example uses customer shipments only, to keep
it simple.

**To check against the book**
- The four labels on ORDER SHIPMENT's two lines are hard to pair in the photo. Read the
  natural way: an order shipment is the shipment of one order item, shipped via one
  shipment item; each of those has many.
- Both ORDER SHIPMENT lines carry a bar: order item + shipment item identify it (point 11).
  SHIPMENT ITEM FEATURE likewise: shipment item + feature.
- Table 5.5 is photographed at an angle; its rows read as above, which leaves 9200's third
  line out of Table 5.6 (point 13).
- Table 5.7's "order item feature" read as Ch 4's feature line ordered for the pen line,
  not as a column on the pen line (point 14; Ch 4's point 2).
- Table 5.7's shipped quantity, 1,000, is 9000's pen line, printed once for both order lines.
- ORDER ITEM is drawn without its order and its "ordered for" line: read as abbreviation,
  Ch 4's model unchanged.

**Discussion**
- **The hand-over is line to line, with its own quantity.** An ORDER SHIPMENT row says "this
  much of this order line went out on this shipment line". That holds both splits: an order
  line spread over shipments (order 100's pencils on 9000 and 9400) and a shipment line
  covering several orders (9000's pens, 700 + 300). A link between order and shipment could
  say neither how much nor which line, and a single "shipment line → order line" foreign key
  would forbid the second split. Ch 4's ORDER REQUIREMENT COMMITMENT had the same shape.
  (Ponder 1 of submodel 2.)
- **"Shipped in full" is now a sum,** not a status: the order shipments of a line against its
  quantity. Ch 4's text said shipped could be worked out from shipments; this is where. An
  order line that ships more than ordered is shown for review, since some businesses allow
  a margin.
- **The rules the text leaves to "processes" become checks:** a shipment line fills order
  lines for its own good, bound for its own destination, and is never drawn on beyond its
  quantity. And by the types' meaning, sales lines fill on customer shipments, purchase lines
  on purchase shipments, either on a drop ship, which fills a purchase line (from our
  supplier) and a sales line (to our customer) at once (point 15).
- **What was shipped can differ from what was ordered.** The order line's features say what
  the customer asked for; the shipment line's features say what went out. Comparing the two
  through ORDER SHIPMENT finds blue ordered and black shipped. The book keeps shipped
  features on the shipment line, so one line of black pens answers both blue orders, and
  weighs storing them on ORDER SHIPMENT instead (point 16; ponder 3 of submodel 2).
- **Some shipment lines fill no order at all:** returns answer shipment lines (5.2), a
  transfer moves our own stock, a sample goes free. So a shipment line without an order
  shipment isn't an error by itself; 9200's 1,500 pencils, which no order claims, is shown
  for review.

### Points to discuss after the overview (Figs 5.1–5.3 so far)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing. The list moves under the chapter's last figure as figures arrive.

1. **5.1, optionality:** the photo can't settle which halves are dashed. Read as sender and
   receiver mandatory (`not null`), the two addresses, the inquiry mechanism and the
   receiving number optional. If the addresses are drawn mandatory, the columns tighten.
2. **5.1, the subtypes as type rows:** no SHIPMENT TYPE is drawn. Built as a `shipment_type`
   hierarchy (OUTGOING and INCOMING as grouping rows over their pairs), with two flags of
   ours, `from_internal` and `to_internal`, saying whose organizations sit at each end. The
   alternative is a flat discriminator with the direction rules in a query.
3. **5.1, no facility:** a shipment goes between parties and postal addresses, not between
   facilities (Ch 2's warehouse or plant). A later figure may add them; until then, which
   dock a shipment leaves from is only the postal address.
4. **Table 5.1, 4800's drop ship:** ACME, our customer everywhere else, ships to Sellers
   Assistance. Read as a drop ship ABC arranged, with ACME as the supplier this time.
   Nothing records that hat, since the shipment points at parties, not roles.
5. **5.2, the GOOD line optional:** an item names a good or describes what it carries. An
   item with neither is a data-quality query. If the line is drawn mandatory, the contents
   description is only a note beside the good.
6. **5.2, SHIPMENT STATUS identified by shipment + type:** one row per status type, built as
   a surrogate key plus a data-quality query, as for Ch 4's identifiers. It can't record a
   status twice (out for delivery, back, out again). Was that Silverston's intention, or are
   the bars a slip, since ORDER STATUS has an id of its own?
7. **5.2, status types in Ch 2's `status_type`:** a SHIPMENT_STATUS group beside Ch 4's
   ORDER_STATUS. Settle with Ch 4's point 15 (shared status table vs a lookup per kind).
8. **Table 5.3, 4800's year:** printed 2002, read as 2001: Table 5.1 expects the shipment to
   leave on July 12, 2001, three days after it was scheduled.
9. **Table 5.3, received or delivered:** the text lists "delivered", the table uses
   "received". Both kept as types: delivered when the carrier hands it over, received when
   the receiver takes it in. If Silverston meant one thing, one goes.
10. **5.2, what "in response to" may join:** read as an item answering one item on another
    shipment (a return, a replacement). Nothing drawn says which kinds may answer which;
    the only check is that an item doesn't answer an item of its own shipment.
11. **5.3, ORDER SHIPMENT identified by order item + shipment item:** built as a surrogate
    key plus a data-quality query (the pair twice), as elsewhere.
12. **5.3, the text's "same place, same product" as checks:** the book leaves them to
    business processes; we check them in the data (the line's ship-to against the
    shipment's destination, the line's product against the shipment line's good). Should
    they stay checks, or is a mismatch sometimes legitimate (a substitute product, a
    redirected truck)?
13. **Table 5.5's 9200 line 3:** read from a skewed photo as 1,500 pencils on 9200 and 500 on
    9400. Table 5.6 claims 9400's 500 but nothing of 9200's 1,500. A slip in the book, or a
    line meant to fill no order? Seeded as read; a review query shows it unclaimed.
14. **Table 5.7, ordered features as Ch 4's feature lines:** orders 100 and 200 get a blue
    line under their pen lines (lines 4 and 3), which Table 5.4 doesn't list. If Ch 4's point
    2 settles that a feature may sit on its product's own line, these become columns there.
15. **5.3, which shipments fill which order lines:** sales lines on customer shipments,
    purchase lines on purchase shipments, either kind on a drop shipment; returns and
    transfers fill none. Ours, from what the types mean, built as a data-quality query. The
    text only says the example sticks to customer shipments.
16. **5.3, shipped features on the shipment line** (as drawn), not on ORDER SHIPMENT (the
    text's alternative). Kept as drawn: one line of black pens answers both blue orders the
    same way. On ORDER SHIPMENT, each order line could get its own answer (black for one,
    blue for the other) on one shipment line, at the cost of repeating them.

## Design decisions (book → SQL)

### Fig 5.1
- **`shipment` keeps the book's ids** (9000, 1146 …) as surrogate integer keys.
- **The subtypes become rows in `shipment_type`,** a hierarchy (point 2): OUTGOING and
  INCOMING are grouping rows with their two subtypes under them; TRANSFER and DROP SHIPMENT
  stand alone. A shipment must use a leaf type (data-quality query; seed: 9700 typed plain
  "outgoing").
- **A rule stored as data:** `from_internal` and `to_internal` on `shipment_type` (ours) say
  whether each end of that type of shipment is one of our own organizations. The view
  `shipment_end` works out the same from the parties' INTERNAL_ORGANIZATION roles on the
  estimated ship date, and a data-quality query compares the two (seed: 9800, a "transfer"
  to ACME).
- **Parties `not null`; the addresses and both mechanisms nullable** (point 1). The address
  FKs point at `postal_address` and the receiving number's at `telecommunications_number`,
  the subtype tables, so a plain FK keeps the kind (as 4.8 did with the order item
  subtypes). The inquiry line takes any contact mechanism.
- **An address must be on file for its party** (Ch 2's `party_contact_mechanism`, current on
  the estimated ship date): a data-quality query (seed: 9900, ACME at General Goods's
  address).
- **The plan's dates in order:** ready no later than ship, arrival no earlier, the latest
  cancel date no later than the ship date: a data-quality query (seed: 9950 arrives two
  days before it ships).
- `last_updated` is a `timestamptz`; the two costs are `numeric`, in USD.
- **Seed:** Table 5.1's eight shipments, then ours: 9600, a customer return (ACME sends back
  some pens, used in 5.2), and four with deliberate mistakes. New parties and mechanisms:
  General Goods Corporation (party 49); 300 Main Street (ABC Subsidiary), 300 Jennifer
  Street (General Goods) and 400 Benny Street (Sellers Assistance), with cities of ours;
  ACME's receiving dock phone and ABC Subsidiary's shipping desk e-mail. The estimated
  ready dates, costs and handling instructions are ours.

### Fig 5.2
- **`shipment_item` has a surrogate key and the line number** `shipment_item_seq_id`. The
  line number's uniqueness within its shipment (the bar) is a data-quality query (seed: 1149
  has two lines numbered 1).
- **`product_id` references `good`,** Ch 3's subtype table, since the line lands on GOOD; a
  service can't be shipped. Nullable (point 5): an item with neither a good nor a contents
  description is a data-quality query (seed: 1578's line 2).
- **`quantity` is `not null` and positive,** in the good's unit of measure.
- **`in_response_to_shipment_item_id`,** a nullable self-reference. An item answering an item
  of its own shipment is a data-quality query (point 10; seed: 9600's line 2).
- **`shipment_status` has a surrogate key** (point 6): one status type twice on a shipment
  is a data-quality query (seed: 9200 shipped twice, the second keyed a few hours later).
- **SHIPMENT STATUS TYPE → a SHIPMENT_STATUS group in Ch 2's `status_type`** (point 7), as
  Ch 4's order statuses: scheduled, shipped, in route, delivered, received and cancelled. A
  status from another group is a data-quality query (seed: Ch 4's ORDER_SHIPPED on 1149).
- **`status_datetime` is a `timestamptz`** (STATUS DATE in the book), as `order_status`: the
  text allows times. The current status is the latest row.
- **The events in order** is a data-quality query: a later step (shipped, in route,
  delivered, received) dated before an earlier one, or anything after a cancellation (seed:
  1146 received the day before it shipped).
- **Seed:** Table 5.2's lines on 9000, and Table 5.5's (shared with Fig 5.3) on 9200 and 9400;
  Table 5.3's statuses on 9000 and 4800 (read as 2001, point 8). The other lines and
  statuses are ours. New to Ch 3's catalogue: the Jones #2 pencil and the standard eraser,
  sold each; the HD diskettes are Ch 3's box of 3½-inch diskettes (1.44 MB), as Ch 4 read
  them.

### Fig 5.3
- **`order_shipment`: a surrogate key, plain FKs to Ch 4's `order_item` and to
  `shipment_item`, and a `quantity` (`not null`, positive).** The pair twice is a
  data-quality query shared with `shipment_item_feature` (point 11).
- **`shipment_item_feature`: a surrogate key, the shipment line and Ch 3's feature.** No
  attributes, as drawn (seed: 9000's pen line black twice).
- **Quantity:** the order shipments drawing on a shipment line add up to no more than it
  carries (data-quality query; seed: 9500's 150 erasers allocated 200). An order line
  shipped beyond its quantity is shown by a review query, not a check: some businesses
  accept a margin.
- **Product:** an order line's product (a feature line's is its product line's) must be the
  shipment line's good (data-quality query, point 12; seed: order 400's diskettes on 9500's
  pencil line).
- **Destination:** an order line's ship-to (4.3's or 4.4's column, a feature line falling
  back to its product line, or 4.5's generic SHIPPING row) must be the shipment's shipped-to
  address (data-quality query, point 12; seed: order 400's pencils for 2300 Drident Avenue
  on 9500, bound for 234 Stretch Street).
- **Direction:** sales lines on customer shipments, purchase lines on purchase shipments,
  either on a drop shipment (data-quality query, point 15; seed: purchase order 300's
  erasers on customer shipment 9500).
- **Seed:** Tables 5.4, 5.6 and 5.7 as orders 100 and 200 (ACME's, taken by ABC Subsidiary;
  dates and prices ours), each pen line with a blue feature line under it (point 14). Ours:
  purchase order 300 (ABC Subsidiary buys pencils and erasers from General Goods for ABC
  Corporation, delivered by 1146 and 1149), sales order 400 and customer shipment 9500,
  which carry the four mistakes. New Ch 2 roles: General Goods as SUPPLIER, ABC Corporation
  as SHIP_TO_BUYER.

## When NOT to use this
- **A shop that ships each order once, whole, to one address** can keep a ship date and a
  tracking number on the order. The separate shipment pays off when shipments and orders
  stop matching one to one, or when goods move with no order (returns, transfers).
- **The direction subtypes** matter when the business ships both ways and between its own
  sites. A seller that only ships out needs no type at all.
- **ORDER SHIPMENT** earns its place when lines split or combine. If every order line always
  ships whole, on one shipment line of its own, a foreign key from the shipment line to the
  order line says the same with one table less.
- **The shipped features** matter where substitutes happen and get billed or returned. A
  warehouse that never ships anything but what was ordered can drop SHIPMENT ITEM FEATURE.

## Open questions
