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

### Points to discuss after the overview (Figs 5.1–5.1 so far)
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

## When NOT to use this
- **A shop that ships each order once, whole, to one address** can keep a ship date and a
  tracking number on the order. The separate shipment pays off when shipments and orders
  stop matching one to one, or when goods move with no order (returns, transfers).
- **The direction subtypes** matter when the business ships both ways and between its own
  sites. A seller that only ships out needs no type at all.

## Open questions
