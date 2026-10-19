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

3. **Packages and receipts** (Fig 5.4): which packages hold which shipment lines, and when an
   incoming package is opened, how much of each good was accepted or rejected and why, who
   received it, which stock it went into, and which order line it's checked against?

4. **Issuances and picklists** (Fig 5.5): which stock was pulled for each outgoing shipment
   line, how much and by whom, according to which picklist; and does the quantity on hand
   still match what came in, went out and was counted?

5. **Shipping documents and route segments** (Figs 5.6–5.7): what travels with the shipment
   and how it travels: which papers go with the whole shipment, a line or a box; which legs
   it takes, from which facility to which, by which carrier, method and vehicle, planned
   against actual?

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

### Fig 5.4 — Shipment receipt for incoming shipments
**Transcription** (accepted: ☐; one photo, with Table 5.8 on another; open points under "To
check against the book")

```
SHIPMENT PACKAGE
  # shipment_package_id
  * date_created
  (no line to SHIPMENT)

PACKAGING CONTENT            (both lines carry a bar)
  * quantity
  -> SHIPMENT ITEM           (many "of" 1 shipment item, bar; item "packaged within" many)
  -> SHIPMENT PACKAGE        (many "in" 1 package, bar; package "composed of" many)

SHIPMENT RECEIPT
  # receipt_id
  * datetime_received
  * item_description
  * quantity_accepted
  * quantity_rejected
  -> SHIPMENT PACKAGE        (many "within" 1 package; package "consisting of" many)
  -> GOOD                    (many "of" 1 good; good "the description for" many)
  -> INVENTORY ITEM          (many "stored into" 1 item; item "the destination for" many)
  -> ORDER ITEM              (many "verified against and applied to" 1 order item; order
                              item "accounted for via" many)
  -> REJECTION REASON        (many "rejected because of" 1 reason; reason "the reason for
                              rejection of" many; dashed)

SHIPMENT RECEIPT ROLE        (no attributes; all three lines carry a bar)
  -> SHIPMENT RECEIPT        (many "for" 1 receipt, bar; receipt "involving" many)
  -> SHIPMENT RECEIPT ROLE TYPE (many "described by" 1 type, bar; type "the description
                              for" many)
  -> PARTY                   (many "of" 1 party, bar; party "involved in" many)

SHIPMENT RECEIPT ROLE TYPE   (no attributes drawn)
REJECTION REASON
  # rejection_id
  * description

INVENTORY ITEM               (Ch 3: # inventory_item_id)
  -> GOOD                    (many "the physical occurrence of" 1 good; good "the generic
                              description for" many)
SHIPMENT ITEM                (as 5.2, with its "in response to" loop) -> GOOD ("a shipment
                              of" / "shipped via")
ORDER ITEM                   (as Ch 4: # order_item_seq_id, o quantity, o unit_price,
                              o estimated_delivery_date, o shipping_instructions, o comment;
                              PURCHASE ORDER ITEM (o item_description), SALES ORDER ITEM
                              (o corresponding_po_id))
```

**Table 5.8** (shipment receipts, the book's sample, in our words): the two purchase
shipments and one transfer, line by line, with how much of each line went into which
package and what each package's receipt accepted.
- 1146's line 1, 2,000 Jones #2 pencils, arrives in two packages of 1,000 (52000 and 52001),
  each with its own receipt (12900, 12901), all accepted. Line 2, 1,000 Goldstein Elite
  pens, comes in package 52002, its receipt printed 12901 again, all accepted. Line 3, 1,000
  boxes of HD diskettes, shows one package of 100 (52003), receipt 13902, all accepted.
- 1149's three lines (200 standard erasers, 200 boxes of HD diskettes, 100 Jones #2 pencils)
  share one package, 53100, with a receipt each (13903 to 13905), all accepted.
- "4800 (transfer)": 500 Jones #2 pencils in package 52004, receipt 13804, of which 300 are
  accepted.

**The text below it** (one line, opening the next figure's): an item issuance can have many
ITEM ISSUANCE ROLEs, and its line to SHIPMENT ITEM is optional.

**To check against the book**
- Optionality, from the photo: the receipt's line to its package read as mandatory (Table
  5.8 counts every receipt within a package); its good, inventory item, order line and
  rejection reason as optional (point 22). The reason's line is dashed.
- ITEM DESCRIPTION drawn mandatory on the receipt, beside an optional good: kept, read as
  what the receiver wrote down (point 22).
- SHIPMENT PACKAGE has no line to SHIPMENT; its shipment follows from its contents (point
  17).
- Bars: PACKAGING CONTENT is identified by its line and its package; SHIPMENT RECEIPT ROLE by
  its receipt, type and party.
- Table 5.8 contradicts Tables 5.1 and 5.3 on 4800 (point 18), prints receipt 12901 twice
  (point 20), and gives 1146's diskette line 1,000 boxes but one package of 100 (point 21).
  Its lines for 1146 and 1149 replace the ones we had made up (point 19).
- ORDER ITEM drawn with COMMENT and PURCHASE ORDER ITEM's own ITEM DESCRIPTION again (Ch 4's
  point 6).

**Discussion**
- **Packages are how goods physically travel.** A shipment line can be spread over several
  boxes (1146's pencils in two cartons), and one box can hold several lines (1149's three
  lines in 53100). PACKAGING CONTENT is the link with a quantity, the same many-to-many
  shape as ORDER SHIPMENT one level down. A package's shipment is found through its
  contents; nothing drawn stops one box from mixing two shipments. (Ponder 1.)
- **A receipt counts one good in one package, as it is opened:** how much was accepted, how
  much rejected and why. It is the fact the purchase was waiting for: 1146's estimated
  arrival says when it should come, its "received" status that it came, and its receipts
  what was actually in the boxes. (Ponder 3.)
- **The receipt turns a good into stock.** "Stored into" names the INVENTORY ITEM (Ch 3) the
  accepted goods went into: the catalogue's GOOD becomes a physical instance at a facility.
  Ch 3's quantity on hand is what receipts (and, later, issues) leave behind. (Ponder 4.)
- **Two paths to the order line.** A receipt is "verified against and applied to" an order
  line directly, though the long way round already exists: receipt → package → its content
  of that good → shipment line → ORDER SHIPMENT → order line. The direct line says which
  line this count settles; the long path says which lines it could settle. The two must
  agree (a check). (Ponder 2.)
- **Receipts are for incoming shipments,** as the title says: purchase shipments, customer
  returns and, at the receiving site, transfers. What a customer signs for at its door isn't
  our receipt. (Ponder 5.)
- **Who received and inspected** is a scoped role, as for orders and requirements: a party
  and a type within one receipt.

### Fig 5.5 — Item issuance for outgoing shipments
**Transcription** (accepted: ☐; one photo, with Table 5.9 on another; open points under "To
check against the book")

```
ITEM ISSUANCE
  # item_issuance_id
  * issued_datetime
  * quantity
  -> SHIPMENT ITEM           (many "issued for" 1 shipment item; item "obtained via" many;
                              dashed: optional)
  -> INVENTORY ITEM          (many "issued from" 1 item; item "issued via" many)
  -> PICKLIST ITEM           (many "issued according to" 1 picklist item; picklist item "the
                              record of the need to issue" many)

ITEM ISSUANCE ROLE           (no attributes; all three lines carry a bar)
  -> ITEM ISSUANCE           (many "for" 1 issuance; issuance "involving" many)
  -> ITEM ISSUANCE ROLE TYPE (many "described by" 1 type; type "the description for" many)
  -> PARTY                   (many "of" 1 party; party "involved in" many)

ITEM ISSUANCE ROLE TYPE      (no attributes drawn)

PICKLIST
  # picklist_id
  * date_created
  (no line to a shipment, a facility or a party)

PICKLIST ITEM                (both lines carry a bar)
  * quantity
  -> PICKLIST                (many "part of" 1 picklist; picklist "composed of" many)
  -> INVENTORY ITEM          (many "picked from" 1 item; item "picked using" many)

INVENTORY ITEM               (Ch 3) -> GOOD ("the physical occurrence of" / "the generic
                              description for")
SHIPMENT ITEM, PACKAGING CONTENT, SHIPMENT PACKAGE: as 5.4, with 5.2's "in response to" loop

Two labels with no line: "issued via" above PACKAGING CONTENT, "created to send" above
SHIPMENT PACKAGE.
```

**Table 5.9** (item issuances, the book's sample, in our words): the two customer shipments
of Table 5.5, line by line, with each line's packages beside the issuances that pulled its
goods from stock.
- 9000: line 1, 1,000 Jones #2 pencils, packed in 62000, one issuance (12900, 1,000). Line 2,
  1,000 Goldstein Elite pens, also in 62000, pulled in two issuances (12901 for 800, 13100
  for 200). Line 3, 100 boxes of HD diskettes, in 62000, issuance 12902.
- 9200: line 1, 350 standard erasers in 62001 (issuance 13800). Line 2, 100 boxes of
  diskettes in 62002 (13801). Line 3, 1,500 pencils: 1,500 printed as packed in 62002 and
  500 more in 62003, pulled as 1,000 (13802) and 500 (13803).

**To check against the book**
- Optionality, from the photo: the line to SHIPMENT ITEM is dashed (the text under Fig 5.4
  says it's optional); the line to INVENTORY ITEM read as mandatory and the one to PICKLIST
  ITEM as optional (point 29).
- The two labels with no line (point 27). Fig 5.8 draws neither line.
- Table 5.9's 9200 line 3: 1,500 + 500 packed for a line of 1,500 (point 28).
- Bars: PICKLIST ITEM is identified by its picklist and its inventory item; ITEM ISSUANCE
  ROLE by its issuance, type and party.

**Discussion**
- **The issuance is the receipt's mirror.** A receipt counts a good out of a package *into*
  an inventory item; an issuance pulls a quantity *out of* an inventory item for a shipment
  line. Ch 3's stock now has both its movements, and the two hand over at INVENTORY ITEM.
- **One pull, one row.** 9000's pens come out in two issuances (800 and 200): the stock sat
  in two places (in our seed, the loose stock and a bin), each its own INVENTORY ITEM. So a
  line has many issuances, and each names the exact stock it drained. (Ponder 1.)
- **The issuance knows its line, not its box.** Table 5.9 sets packages and issuances side
  by side, but the drawn model joins them only through the shipment line. Which of 9200's
  two pencil boxes 13802's 1,000 went into isn't recorded. (Ponder 2.)
- **Three quantities on one line, plan beside the facts again:** the picklist item says what
  to pull and from where (the plan), the issuance what was pulled (the fact), the packaging
  content what went into which box (another fact). A short pick, a pull from the wrong bin
  or a box packed beyond its line each shows as a gap between two of them. (Ponder 3.)
- **A picklist has no shipment.** It's a warehouse sheet: pull these quantities from these
  stocks. Which shipments it served is worked out through its issuances, so one sheet can
  serve several shipments (a wave pick). (Ponder 4.)
- **The issuance names its stock twice:** directly, and through its picklist item. The two
  must agree, the shortcut-against-path check of Fig 5.4 again.
- **qoh = balance, at last.** Ch 3 cached the quantity on hand and promised a check once
  receipts and issuances existed (Ch 3 NOTES, Fig 3.6 vocabulary). Now the balance is
  receipts accepted − issued + variances, from zero. Stock that predates the system starts
  with an opening count, a variance against zero. (Ponder 5.)
- **Who pulled it** is a scoped role again, now the ninth role-type lookup.

### Fig 5.6 — Shipping documents
**Transcription** (accepted: ☐; one photo, no table; open points under "To check against the
book")

```
DOCUMENT
  # document_id
  * description
  -> DOCUMENT TYPE           (many "described by" 1 type; type "the description for" many)
  subtype SHIPPING DOCUMENT, with its own subtypes (no attributes on any): BILL OF LADING,
    PACKAGING SLIP, EXPORT DOCUMENTATION, MANIFEST, PORT CHARGES DOCUMENT, TAX AND TARIFF
    DOCUMENT, HAZARDOUS MATERIALS DOCUMENT, OTHER SHIPPING DOCUMENT

SHIPPING DOCUMENT            (all three lines dashed at both ends; no arc)
  -> SHIPMENT PACKAGE        (many "for" 1 package; package "having" many)
  -> SHIPMENT ITEM           (many "for" 1 item; item "having" many)
  -> SHIPMENT                (many "for" 1 shipment; shipment "having" many)

DOCUMENT TYPE
  # document_type_id
  * description

SHIPMENT (5.1's attributes), SHIPMENT ITEM (-> GOOD, "part of" SHIPMENT), SHIPMENT PACKAGE,
PACKAGING CONTENT: as before.
```

**To check against the book**
- No arc across the three lines: a document may name more than one level (point 34).
- DOCUMENT TYPE beside the drawn subtypes (point 35).
- DOCUMENT carries only a description: no date, no issuer, no number of its own.

**Discussion**
- **Paperwork comes at three levels.** A bill of lading or a manifest covers the whole
  shipment, a packing slip one box, a hazardous-materials sheet or an export licence one
  line (one good). So the document names what it covers, and the three lines are optional.
  (Ponder 1.)
- **A supertype with a type hierarchy again.** The eight kinds carry no attributes of their
  own: they're rows of DOCUMENT TYPE. SHIPPING DOCUMENT is a real subtype because it has the
  lines; DOCUMENT is left open for other kinds of paper elsewhere. (Ponder 2.)
- **No arc, so the levels must agree.** A packing slip naming package 62001 and shipment
  9000 contradicts itself: 62001 holds 9200's erasers. Naming two levels is allowed, a
  contradiction isn't (a check).
- **The naive model** puts a `bill_of_lading_no` column on SHIPMENT. That holds one kind of
  paper at one level; the next kind (a manifest, a packing slip per box) needs another
  column, and per-line papers have nowhere to go.

### Fig 5.7 — Shipment route segments
**Transcription** (accepted: ☐; one photo, with Tables 5.10 and 5.11 on two others; open
points under "To check against the book")

```
SHIPMENT ROUTE SEGMENT
  # shipment_route_segment_id
  o actual_start_datetime
  o actual_arrival_datetime
  o estimated_start_datetime
  o estimated_arrival_datetime
  o start_mileage
  o end_mileage
  o fuel_used
  -> SHIPMENT                (many "of" 1 shipment, bar; shipment "shipped by way of" many)
  -> SHIPMENT METHOD TYPE    (many "shipped via" 1 type; type "the type of transportation
                              for" many)
  -> VEHICLE                 (many "shipped using" 1 vehicle; vehicle "used to ship" many;
                              dashed)
  -> FACILITY                (many "from" 1 facility; facility "the origin of" many; dashed)
  -> FACILITY                (many "to" 1 facility; facility "the destination of" many;
                              dashed)
  -> CARRIER                 (many "shipped by" 1 carrier; carrier "the shipper of" many)

FIXED ASSET
  # fixed_asset_id
  * name
  subtype VEHICLE (no attributes)

FACILITY                     (Ch 2)
  # facility_id
  * facility_name

CARRIER SHIPMENT METHOD      (no attributes; both lines carry a bar)
  -> SHIPMENT METHOD TYPE    (many "of" 1 type; type "the type of transportation used" many)
  -> CARRIER                 (many "for" 1 carrier; carrier "able to ship via" many)

SHIPMENT METHOD TYPE
  # shipment_method_type_id
  * description

ORGANIZATION ROLE            (Ch 2) with subtype CARRIER
SHIPMENT                     (5.1's attributes)
```

**Table 5.10** (route segments, the book's sample, in our words): 9000, a customer
shipment, goes in two legs by truck with ABC Subsidiary as its own carrier, March 7, 2001,
10 a.m. to 1 p.m., then 2 p.m. to 4 p.m. 9200 goes in one leg by ground with Very Reliable
Parcel Service, March 12 at 1 p.m. to March 14 at 1 p.m. Purchase shipment 1146 comes in one
leg by air with Air Goods Delivery Express, March 19 at 4 p.m. to noon the next day. Only the
estimates are shown.

**Table 5.11** (vehicle data, in our words): 9000's first leg ran on Truck #1, March 7,
10:00 to 11:35 a.m., 52,000 to 52,061 miles, 2 gallons; its second on Truck #25, 12:05 to
8:16 p.m., 73,525 to 74,006 miles, 25 gallons. Shipment 9002 rode Truck #1 on the same run,
with the same times, mileage and fuel.

**The text below Table 5.10** (in our words): VEHICLE is a FIXED ASSET subtype, shown in
full in Ch 8 (Fig 8.5); one vehicle carries many segments, so one truck can deliver many
shipments. Below Table 5.11: estimated and actual start and arrival times per segment show
whether a shipment runs late.

**To check against the book**
- Optionality, from the photo: the shipment, method type and carrier read as mandatory for
  a segment; the vehicle and both facilities as optional (dashed) (point 38).
- The segment's id carries a bar to SHIPMENT: a number within its shipment (Table 5.10's 1
  and 2) (point 39).
- FACILITY NAME here is Ch 2's facility description.
- Shipment 9002 isn't in Table 5.1 (point 36).

**Discussion**
- **A shipment travels in legs.** 9000 goes by one truck to a hand-over point and by
  another to ACME. Each leg has its own carrier, method, vehicle, places and times, so the
  leg is a row: SHIPMENT ROUTE SEGMENT. The naive model puts one carrier and one tracking
  number on SHIPMENT and can't tell which truck was late. (Ponder 3.)
- **Plan beside the facts, a third time:** estimated and actual start and arrival sit side
  by side on the segment, so lateness is a comparison within one row. The status history
  (Fig 5.2) says what happened to the whole shipment; the segment, where and on what.
- **The leg goes facility to facility.** Fig 5.1's shipment goes address to address; the
  segment plugs in Ch 2's FACILITY (point 3 asked where facilities would come in). Legs
  must chain: each starts where the one before it ended (a check).
- **A carrier is a party role** (Ch 2's ORGANIZATION ROLE), not a lookup: carriers are
  organizations we deal with. CARRIER SHIPMENT METHOD lists what each one offers, so a
  segment can be checked against it. (Ponder 5.)
- **One truck, many shipments.** Truck #1 carried 9000 and 9002 on one run, and Table 5.11
  repeats that run's mileage and fuel on both. The figures belong to the run, not to each
  shipment, so totals per truck count the run twice (point 37). (Ponder 4.)
- **VEHICLE borrows from Ch 8:** a FIXED ASSET subtype, built here with just a name and a
  type, for Ch 8 to extend.

### Points to discuss after the overview (Figs 5.1–5.5 so far)
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
   facilities (Ch 2's warehouse or plant). Fig 5.7 adds facilities on the route segment,
   not on the shipment, and Fig 5.8 keeps it that way.
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
    line meant to fill no order? Seeded as read; a review query shows it unclaimed. Table
    5.9 prints the same 1,500 (point 28), so the reading holds; the question stays.
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
17. **5.4, no line from SHIPMENT PACKAGE to SHIPMENT:** a package's shipment is worked out
    from its contents' shipment lines. A package holding lines of two shipments is a
    data-quality query (ours). If Silverston meant a package to belong to one shipment, a
    line of its own would say it with a plain FK.
18. **Table 5.8's "4800 (transfer)":** in Table 5.1, 4800 is a drop shipment, and Table 5.3
    cancels it. Read as 3485, Table 5.1's transfer from ABC Corporation to ABC Subsidiary,
    whose line we had made up as 1,000 pencils: now the table's 500, 300 accepted.
19. **Table 5.8 replaces our own lines on 1146 and 1149:** 1146 carries 2,000 pencils, 1,000
    pens and 1,000 boxes of diskettes; 1149 200 erasers, 200 boxes of diskettes and 100
    pencils. Our purchase order 300 behind them is re-planned to match (four lines).
20. **Table 5.8 prints receipt 12901 twice:** the pencils in 52001 and the pens in 52002. One
    receipt is within one package and of one good, so the pens' is read as 12902.
21. **Table 5.8, 1146's diskettes:** the line says 1,000 boxes, the one package shown holds
    100. Read as a line packed in two: ours, the other 900 sit in package 52005, opened two
    days later. If 1,000 is a misprint for 100, the line shrinks and 52005 goes.
22. **5.4, optionality:** a receipt is within one package (mandatory); its good, inventory
    item, order line and rejection reason are optional. ITEM DESCRIPTION is drawn mandatory
    even with a good: kept, as what the receiver wrote on the slip.
23. **5.4, the receipt's direct line to ORDER ITEM:** read as the line this count is checked
    against, and checked consistent with the long path through ORDER SHIPMENT. The
    alternative reading is that receipts settle order lines with no shipment line (goods
    turning up unannounced), where the check would be wrong.
24. **5.4, receipts for incoming shipments only** (the figure's title): a receipt within a
    package of an outgoing shipment is a data-quality query (ours). Transfers count as
    incoming at the site that receives them.
25. **5.4, SHIPMENT RECEIPT ROLE TYPE as a lookup of its own:** the eighth role-type lookup
    (Ch 4's point 5 and TODO's ROLE TYPE refactor).
26. **5.4, ORDER ITEM's attributes again:** COMMENT on ORDER ITEM and ITEM DESCRIPTION on
    PURCHASE ORDER ITEM, as Fig 4.4 drew them (Ch 4's point 6).
27. **5.5, two labels with no line:** "issued via" above PACKAGING CONTENT and "created to
    send" above SHIPMENT PACKAGE. Read as leftovers of an earlier drawing and built as drawn;
    Fig 5.8 draws neither line. Had they been meant, an issuance would name the package
    content it filled (Table 5.9 lines them up) and a package its shipment (point 17).
28. **Table 5.9, 9200 line 3:** 1,500 printed as packed in 62002 and 500 more in 62003, for a
    line of 1,500. Read 62002's as 1,000, which pairs with issuance 13802's 1,000 and sums
    to the line. If the line was meant to be 2,000, Table 5.5 and the issuances are wrong.
29. **5.5, optionality:** an issuance is from one inventory item (mandatory); its shipment
    line is optional (the text says so; read as stock leaving for other reasons, such as
    our own use) and so is its picklist item. The picklist item's two lines are mandatory.
30. **5.5, which shipments may draw issuances, and from where** (ours, the mirror of point
    24): only shipments that leave one of our organizations, and only from stock at a
    facility at the shipment's ship-from address. Both are data-quality queries.
31. **5.5, ITEM ISSUANCE ROLE TYPE as a lookup of its own:** the ninth role-type lookup
    (point 25).
32. **5.5, opening stock:** the book has no opening balance. Stock that predates the
    shipments gets an opening count, an INVENTORY ITEM VARIANCE against zero (Ch 3) with an
    OPENING_COUNT reason of ours, so qoh = balance can be checked from zero.
33. **5.5, PICKLIST with no line to a shipment, facility or party:** kept. Its shipments come
    through its issuances; which warehouse it's for follows from its picked stock.
34. **5.6, no arc across a shipping document's three lines:** read as "at least one, and
    they agree" (a document for nothing and a document naming levels that contradict are
    data-quality queries). If an arc was meant, a document names exactly one level, and a
    packing slip that also names its shipment becomes an error.
35. **5.6, DOCUMENT TYPE beside the drawn subtypes:** the eight attribute-less kinds become
    rows of `document_type` under a SHIPPING_DOCUMENT grouping row; SHIPPING DOCUMENT is a
    subtype table because it carries the lines. The type and the subtype row must agree (a
    data-quality query).
36. **Table 5.11's 9002:** in no other table. Seeded as ours: a transfer from ABC Subsidiary
    to ABC Corporation, riding Truck #1 with 9000's first leg, so the truck's run ends at
    ABC Corporation's warehouse, where 9000 changes trucks.
37. **Table 5.11 repeats Truck #1's mileage and fuel on 9000 and 9002:** the run's numbers
    sit on each segment, so a total per truck counts the run twice. Kept as drawn; a review
    query shows the naive total beside one per run. A run (vehicle trip) shared by the
    segments would hold them once.
38. **5.7, optionality:** a segment must have its shipment, method type and carrier; the
    vehicle and both facilities are optional (dashed), so a parcel carrier's leg needs no
    truck of ours and no known depot.
39. **5.7, the segment's id with a bar to SHIPMENT:** a number within its shipment (Table
    5.10's 1 and 2), built as `segment_seq_id` beside a surrogate key, its uniqueness a
    data-quality query (as Fig 5.2's line numbers).
40. **5.7, CARRIER as a role:** a CARRIER row under Ch 2's ORGANIZATION_ROLE, and the
    segment and CARRIER SHIPMENT METHOD point at PARTY ROLE, as Ch 4's orders do. ABC
    Subsidiary carries its own goods in Table 5.10, so it holds the role too.
41. **5.7, VEHICLE ahead of Ch 8:** `fixed_asset` with a `fixed_asset_type` (VEHICLE, and
    EQUIPMENT of ours for a bad row); Ch 8's Fig 8.5 extends both.
42. **Tables 5.10–5.11 against our status times:** the statuses' times were ours, so 9000's
    shipped and received move to 10:00 and 20:30 to match its trucks, 9200's shipped to
    13:00 and 1146's to 16:00. The dates stay.

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
  has two lines numbered 3).
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
  Table 5.3's statuses on 9000 and 4800 (read as 2001, point 8); since Fig 5.4, Table 5.8's
  lines on 1146, 1149 and 3485 (points 18–19), which replaced ours. The other lines and
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
  purchase order 300 (ABC Subsidiary buys pencils, erasers, pens and diskettes from General
  Goods for ABC Corporation; re-planned at Fig 5.4 to match Table 5.8's 1146 and 1149),
  sales order 400 and customer shipment 9500, which carry the four mistakes. New Ch 2 roles:
  General Goods as SUPPLIER, ABC Corporation as SHIP_TO_BUYER.

### Fig 5.4
- **`shipment_package` keeps the book's ids** (52000 …) and its `date_created`; no FK to
  `shipment`, as drawn (point 17). A package whose contents come from two shipments is a
  data-quality query (seed: ten of 9400's pencils put in 1146's carton of pens, 52002; until
  Fig 5.5 packed 9000's diskettes in 62000, the ten were 9000's).
- **`packaging_content`: a surrogate key, the package, the shipment line and a quantity.**
  Contents adding up to more than the line carries are a data-quality query (seed: 60
  pencils packed for 9500's line of 50). Less is shown for review: a line may not be packed
  yet, or not recorded box by box.
- **`shipment_receipt` keeps the book's receipt ids.** `shipment_package_id` is `not null`;
  `product_id` (→ `good`), `inventory_item_id`, `order_item_id` and `rejection_reason_id`
  are nullable (point 22). `datetime_received` is a `timestamptz`; `item_description`,
  `quantity_accepted` and `quantity_rejected` are `not null`.
- **A receipt's good must be in its package** (data-quality query; seed: 13906, pens counted
  in 53100, which holds none), and the package's receipts of a good may not count more than
  it holds (data-quality query; seed: 12950, another 50 pencils out of 52001's 1,000).
- **A rejected quantity needs a reason, and a reason needs something rejected:** a
  data-quality query (seed: 19601, five of ACME's returned pens rejected with no reason).
- **The two paths to the order line must agree** (point 23): the order line a receipt names
  must be filled, through ORDER SHIPMENT, by the shipment line its package holds of that
  good (data-quality query; seed: 12960, 1146's diskettes checked against ACME's sales line
  of order 200).
- **Receipts only on incoming shipments** (point 24): purchase shipments, customer returns
  and transfers (data-quality query; seed: 15780, a receipt for our own return 1578).
- **`shipment_receipt_role` + `shipment_receipt_role_type`** (RECEIVER, INSPECTOR), a lookup
  of its own (point 25). The identifier (receipt, type, party) is a data-quality query
  shared with `packaging_content`'s (seed: William as receiver of 12900 twice).
- **`rejection_reason`** has a text key, like Ch 3's `reason`: damaged, wrong product, not
  ordered, poor quality.
- **Stock:** two facilities of ABC's (Ch 2), one per address, and six inventory items (Ch 3)
  the receipts store into; their quantity on hand is what the receipts accepted, since
  nothing is issued yet (Fig 5.5 issues from two of them and updates it).
- **Seed:** Table 5.8's eight receipts (12901's second read as 12902, point 20; "4800" as
  3485, point 18), with their packages and contents. Ours: package 52005 with 1146's other
  900 boxes of diskettes (point 21), packages for 9600, 1578 and 9500, the receipt for
  ACME's returned pens, and the six receipts and rows that carry the mistakes. Dates,
  descriptions, roles and stock are ours.

### Fig 5.5
- **`item_issuance` keeps the book's ids** (12900 …; another table from the receipts of the
  same numbers). `inventory_item_id` is `not null`; `shipment_item_id` and
  `picklist_item_id` are nullable (point 29). `issued_datetime` is a `timestamptz`;
  `quantity` is `not null` and positive.
- **Nothing ties an issuance to a package,** as drawn (point 27): Table 5.9's packages and
  issuances meet only at the shipment line, and the queries show them side by side.
- **`picklist` (its id and `date_created`) and `picklist_item`** (a surrogate key, the
  picklist, the inventory item, a positive quantity). The book's identifier (picklist +
  inventory item) is a data-quality query shared with the role's (seed: picklist 2 lists 9200's
  diskette stock twice).
- **`item_issuance_role` + `item_issuance_role_type`** (ISSUER, APPROVER), a lookup of its
  own (point 31); its identifier is in the same shared query (seed: Rosa Diaz as issuer of
  12900 twice).
- **The issued good must be the line's good:** the inventory item's good against the
  shipment line's (data-quality query; seed: 13951, erasers pulled for 9500's pencil line).
- **No more issued than the line carries** (data-quality query; seed: 13952, 60 pencils for
  9500's line of 50, the same 60 Fig 5.4 packed). Less is shown for review: not yet pulled.
- **The two paths to the stock must agree:** the issuance's inventory item against its
  picklist item's (data-quality query; seed: 13900, 9400's pencils taken from the floor
  stock though the picklist named the bin).
- **Issuances only for shipments that leave one of ours** (point 30: the type's
  `from_internal` flag; data-quality query; seed: 11460, 20 pencils keyed against incoming
  1146).
- **Stock from the shipment's origin** (point 30): an outgoing shipment's issuances come
  from an inventory item whose facility (or its container's) has the shipment's ship-from
  address on file on the issue date (data-quality query; seed: 13950, 9500's erasers taken
  from ABC Corporation's stock, 100 Main Street, for a shipment leaving 300 Main Street).
- **qoh = balance** (Ch 3's promised check, point 32): for every inventory item with a
  receipt or an issuance, `quantity_on_hand` must equal receipts accepted − issued +
  variances (data-quality query; seed: item 19, the diskettes, still at 400 because 9200's
  100 were never subtracted). Ch 3's own items have variances only and no starting point,
  so they stay out.
- **Stock:** ABC Subsidiary's warehouse (9000, 9200, 9400 and 9500 leave from it) gets six
  inventory items (pencils loose and in bin P-1, pens loose and in bin P-2, diskettes,
  erasers), each with an opening count on 2001-03-01. Each quantity on hand is what's left
  after the issues, the wrong ones included, as a cache that applied every row written. ABC
  Corporation's pencils and erasers (Fig 5.4's items 10 and 13) are updated the same way.
- **Seed:** Table 5.9's eight issuances and four packages (62002's 1,500 read as 1,000:
  point 28). Ours: Rosa Diaz (party 50), ABC Subsidiary's warehouse clerk; three
  picklists; legit issuances for 9400, 3485 (from ABC Corporation, the transfer Fig 5.4
  received), 1578 (our return to General Goods) and five erasers for our own use with no
  shipment line; and the six rows that carry the mistakes. Times, roles and stock are ours.

### Fig 5.6
- **`document_type`: a text key and a parent** (point 35): SHIPPING_DOCUMENT is a grouping
  row over the eight kinds. It's the first DOCUMENT in the repo; a later chapter that draws
  DOCUMENT adds its kinds here.
- **`document`** (its id, a type, a description) and **`shipping_document`**, a subtype
  table sharing its key, with three nullable FKs: `shipment_id`, `shipment_item_id`,
  `shipment_package_id` (all dashed, point 34).
- **A shipping document must name at least one level** (data-quality query; seed: document
  8, a packing slip found loose on the dock).
- **The type and the subtype row agree:** a document has a `shipping_document` row exactly
  when its type is a leaf under SHIPPING_DOCUMENT (data-quality query; seed: document 7, a
  bill of lading for 9400 with no row saying what it covers).
- **The levels named must agree:** the line's shipment and the package's (worked out from
  its contents) must be the document's shipment, and the line must be in the package
  (data-quality query; seed: document 9, a packing slip for 9200's package 62001 that also
  names 9000).
- **Seed** (no table in the book; all ours): a bill of lading for 9000, packing slips for
  62000 and 52000, one for 62002 that also names its shipment (two levels that agree), Very
  Reliable Parcel Service's manifest for 9200, a certificate of conformity for 1146's
  diskette line, and the three rows that carry the mistakes.

### Fig 5.7
- **`shipment_route_segment`: a surrogate key and `segment_seq_id`,** the book's number
  within the shipment (point 39). `shipment_id`, `shipment_method_type_id` and
  `carrier_party_role_id` are `not null`; `fixed_asset_id`, `from_facility_id` and
  `to_facility_id` are nullable (point 38). The four datetimes are `timestamptz`; mileage
  (in miles) and fuel (in gallons, Table 5.11's unit) are `numeric`, all nullable.
- **`shipment_method_type`** is a lookup (TRUCK, GROUND, AIR from Table 5.10; RAIL ours).
- **CARRIER is a `role_type` row under ORGANIZATION_ROLE** (point 40). The segment and
  `carrier_shipment_method` point at `party_role`; the role must be a carrier, and the
  carrier must offer the segment's method (one data-quality query; seed: 9400 sent by air
  with Very Reliable Parcel Service, which only offers ground).
- **`carrier_shipment_method`:** a surrogate key, the carrier role, the method. The pair
  twice is a data-quality query shared with the segment's number (seed: Very Reliable
  Parcel Service's ground listed twice; 9600's leg 1 twice).
- **`fixed_asset` + `fixed_asset_type`** (point 41): the segment's asset must be a vehicle
  (data-quality query; seed: 1149's air leg "shipped using" the dock conveyor).
- **Times and mileage in order:** arrival not before start (estimated and actual), end
  mileage not below start (data-quality query; seed: 3485's truck reading 60 miles less at
  the end).
- **Legs chain:** leg n + 1 starts at the facility where leg n ended, when both are known
  (data-quality query; seed: 9500's second leg starting back at ABC Subsidiary's
  warehouse though its first ended at ABC Corporation's).
- **Seed:** Table 5.10's four legs and Table 5.11's trucks; 9002 (point 36). Ours: the
  facilities (ABC Subsidiary's and ABC Corporation's warehouses from Fig 5.4, plus ACME's
  receiving dock and General Goods's warehouse), the actual times for 9200 and 1146, Very
  Reliable Parcel Service and Air Goods Delivery Express (parties 51, 52), and the legs that
  carry the mistakes (9400, 9500, 1149, 3485, 9600). Status times adjusted (point 42).

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
- **Picklists** pay off in a warehouse big enough that the person planning the pull isn't
  the person pulling. A shop that pulls straight from the order can issue without them.
- **Shipping documents as rows** matter when several kinds of paper, at several levels,
  must be found again (customs, hazardous goods, claims). One bill of lading per shipment,
  never searched, fits in a column.
- **Route segments** matter when a shipment changes hands or vehicles on the way, or when
  the business runs its own fleet. A firm that hands every parcel to one carrier and only
  wants its tracking number needs a column, not a table.

## Open questions
