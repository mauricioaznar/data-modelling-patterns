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

### Points to discuss after the overview (Figs 5.1–5.2 so far)
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

## When NOT to use this
- **A shop that ships each order once, whole, to one address** can keep a ship date and a
  tracking number on the order. The separate shipment pays off when shipments and orders
  stop matching one to one, or when goods move with no order (returns, transfers).
- **The direction subtypes** matter when the business ships both ways and between its own
  sites. A seller that only ships out needs no type at all.

## Open questions
