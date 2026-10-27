# Vol 1, Chapter 4 — Exercises log

History behind the tracker in `EXERCISES.md`: answers to section 0 items and the dated gaps
log. Append new entries; read only when a row's evidence is needed.

## Section 0 answers

## Submodel 1 exam (2026-10-23)

**Q1 (Remember): purchase order 7, Acme, Denver and Boston lines, Joe phoned it in.** Taker:
`order_role` TAKEN_BY → Acme, on the order (right; said the rule table "doesn't do anything":
it stores nothing here, but its check needs Acme to hold SUPPLIER). Boston: the line's
`order_item_contact_mechanism` → the office address (right, purpose not named); **missed the
ship-to hat**, `order_item_role` SHIP_TO → the Boston office. Phone: `order_contact_mechanism`
(right). Price: `order_item`'s snapshot (right). Line roles missed for the second time today
(the explode test's S).

**Reinforce (roles), the florist:** florist TAKEN_BY ("seller") in `order_role`, rule (SALES,
TAKEN_BY) → INTERNAL_ORGANIZATION checked after the fact (right, unprompted); bouquet on the line,
price snapshot (right); the mother as `order_item_role` SHIP_TO + `order_item_contact_mechanism`,
same level, after a guiding question (right; reasoned "either level for one line": corrected,
ship-to is a line fact by design); bill-to in `order_role` (right). Missed: PLACED_BY, the
billing address on `order_contact_mechanism`, purposes.

**Q2 (Understand): Hilda's three baskets to Ana, Bea (same apartment) and Carla, against a
teammate's ship-to columns on `order`.** What breaks: "only one place gets the order" (half: one
recipient *and* one address; the shared apartment shows the who breaks even where the where
holds, and "place" is the who/where blur again). Agreed design: SHIP_TO as a role on the line
(right, unprompted, first time today). Said "per product (or feature)": it's per line, so three
baskets of one product need three lines; a feature line follows its parent. Missed: the line's
address (`order_item_contact_mechanism`, Ana's and Bea's lines on the same address row: two
who's, one where) and the why (one bill, many destinations; hats as rows, not columns).
Score: 2.

**Reinforce (who and where), Contoso's 20 laptops:** PLACED_BY Contoso, TAKEN_BY us, BILL_TO
Fabrikam in `order_role`; Fabrikam's 1 Market Street on `order_contact_mechanism` with a billing
purpose (right, purpose named unprompted); two lines, 12 and 8, each with `order_item_role`
SHIP_TO Contoso and `order_item_contact_mechanism` to its office's address, one who and two
wheres (right, unprompted); the address reached through the office's facility contact mechanism
(right). Missed: Priya's e-mail as the order's ORDER_PLACING mechanism. Wondered whether
serialized laptops need a line each: no, the line orders the catalogue product; serial numbers
live on inventory items and meet the order at shipment (Ch 3's catalogue vs physical instance).
Score: 3.

**Q3 (Analyze): seven facts around the Contoso order, where each lives.** 1, Fabrikam at 1
Market Street: party contact mechanism, plus the head office facility to the address (right).
2, the invoice address on this order: `order_contact_mechanism` BILLING, with BILL_TO Fabrikam
(right). 3, $1,150: the line's price snapshot (right). 4, Priya works for Contoso: "employment?"
(half: a party relationship, but EMPLOYMENT is employee to *internal* organization; a customer's
staff is an ORGANIZATION CONTACT RELATIONSHIP, Priya-as-CONTACT to Contoso-as-CUSTOMER, drawn
Contoso to Priya, reversed). 5, only internal organizations take a sales order: a PLACED_BY role
row (wrong twice: the hat is TAKEN_BY, and the fact is a rule, `order_role_rule`; blame split,
Claude worded it "only one of our internal organizations", which also reads as one taker per
order, a check query). 6, serial LX-4471: "shipments" (half: the serial lives on Ch 3's
inventory item, the shipment links it to the Austin line; not on the order, right). 7, the
Denver front desk phone: a receiver role for the courier, an order-level mechanism, and an
employment between courier and Contoso (wrong: `order_item_contact_mechanism` on the Denver
line, purpose DELIVERY_CONTACT; no party needed, the carrier is Ch 5's). Whys mostly not given.
Score: 2.

**Q4 (Evaluate): a teammate's sketch, five points.** 1, two order tables: repetition of dates,
quantity and price (half: the small cost; the big one is every child table, roles, contact
mechanisms, status, terms, adjustments, doubled or arced, and no single place for "all orders";
fix not named: one `order` with the kind and subtypes). 2, ship-to address and phone columns:
one of each, no second destination or delivery contact (right; missed the single `customer_id`
who, no bill-to or placer, and the phone with no purpose; fix not named). 3, price looked up
live: past orders drift (right). 4, lines on the product, not the unit: fine, which unit is
decided at shipment (right, unprompted). 5, `taken_by = 'Northwind'`: read TAKEN_BY as the
client and blamed the wording (wrong: on a sale the taker is us; the flaw is a rule hard-coded in
the schema, broken by a second internal organization and undatable; fix: an `order_role_rule`
row, checked by a query; the wording was clear, the blame is the user's). Score: 2.

**Reinforce (rules beside facts), the ops manager's four notes:** 1, salespeople employees only
from 2027: thru-date the CONTRACTOR rule at 2027-01-01 (exclusive), older orders still pass
because they fall inside its dates (right, unprompted); called the hat PLACED_BY (wrong:
SALESPERSON), and proposed a new EMPLOYEE row that already exists. 2, exactly one bill-to: an
`order_role_rule` row (wrong: a rule row says which standing role a hat needs, not how many;
cardinality is a check query, as the seed's second bill-to shows). 3, Ana the salesperson on
12580: a role row, flagged after the fact if she lacks EMPLOYEE (right), but again as PLACED_BY.
4, ship to anyone: no rule row, so nothing is flagged (right). Rules: 3. Hats: the salesperson
filed as the placer twice, minutes after "the buyer places, the seller takes".

## Submodel 1 round (2026-10-24)

**R1 (Apply): purchase order 9, Acme buys 500 reams from Paperco; Lin keys it in, Raj signs
it off, the invoice goes to Acme.** PLACED_BY Acme (internal organization), TAKEN_BY Paperco,
BILL_TO Acme (internal organization), Lin as "Captured By" (the hat right, ENTERED_BY's name
forgotten), Raj as approver (right). Direction flipped right on a purchase, the person who
keys the order kept off PLACED_BY, point 7's internal-organization rule named unprompted.
The line (copy paper, 500) given though not asked. Score: 4 for the order hats; the row
goes 2 → 3, with the line hats and SALESPERSON left to retest.

**R2 (Apply): Greenleaf sells Hotel Sol palms and soil; the soil goes to Verde SL, which also
uses it; Marta and Joel split the sale 70/30.** SALESPERSON twice on the order with the
70/30 shares (right, cold), SHIP_TO per line (right, cold), and both line addresses with the
SHIPPING purpose though not asked. Missed: END_USER for Verde SL on line 2 (it receives and
uses, two hats). Score: 3. The row stays at 3; SALESPERSON is at 4, END_USER to retest.

**R3 (Apply): the same order, placed from orders@hotelsol.es; for line 2 the driver rings
Verde SL's site mobile first.** The e-mail on `order_contact_mechanism` with a placing
purpose ("issuer", tied to the placed-by hat unprompted) and the mobile on
`order_item_contact_mechanism` as DELIVERY_CONTACT, both cold: the two 10-23 misses (the
placing e-mail at Contoso, the delivery contact on the order in Q3) not repeated. Score: 4;
the wheres row goes 2 → 3 (billing address not retested).

**R4 (Evaluate): two separate tables, `sales_order` and `purchase_order`, no shared order;
what doubles besides the columns?** "Everything that hangs off an order repeats": the
participants, the contact mechanisms, status, connected twice and maybe built twice; and the
other side weighed, "specific only gains readability and a true FK", unprompted. The 10-23
Q4 miss (judged by repeated columns only) not repeated. Not named: the line itself and all
that hangs off it (item roles, item mechanisms, the ordered-for lines), and "every order a
party is in" becoming a union; dates and types are columns, not doubled tables. Score: 3; the
row goes 2 → 3.

## Submodel 1 round (2026-10-25)

**Q2 (Apply): order 31, Ofisur sells desks to Grupo Lema, which places and pays; the invoice
to Calle Mayor 5; line 1, Norte Logística receives and uses 20; line 2, Norte receives 10 for
its tenant Studio Vela.** First asked "who are we?": the wording ("in Ofisur's system")
hinted rather than said, Claude's blame. Then: the sales kind, PLACED_BY and BILL_TO Grupo
Lema, TAKEN_BY Ofisur, the billing address on `order_contact_mechanism` with BILLING; line 1
SHIP_TO and END_USER both for Norte Logística (R2's END_USER miss fixed), line 2 SHIP_TO
Norte and END_USER Studio Vela; SHIPPING per line. All cold. Not asked: both lines link one
address row. Score: 4. Roles 3 → 4, wheres 3 → 4 (the billing address retested, the florist
miss fixed).

## Submodel 2 exam (2026-10-26)

**Q1 (Remember): Harina Norte's order 40, 20 sacks of flour at €30, a 5% loyalty discount
and a €25 delivery charge on the whole order.** Two independent `order_adjustment` rows,
both on the order and not the line (right); the discount typed DISCOUNT with a 5 percentage
(right; LOYALTY_DISCOUNT under it not named, not needed); the delivery stored as a 25 amount
(right) but typed SURCHARGE ✗: a plain delivery charge is SHIPPING_AND_HANDLING (FREIGHT
under it). Blame about 80/20 the user's: the six top types name shipping and handling, but
Table 4.8, seen this morning, files a delivery *outside the normal area* under SURCHARGE.
Score: 3. Typed rows 0 → 3; amount or percentage: the split right, its points (the total,
the base, the convention) untested.

## Gaps log
- 2026-10-23, Q1: who vs where on a line. Gave the ship-to address, not the ship-to party
  (`order_item_role`). Same gap as card 10's S. Reinforce.
- 2026-10-23, florist: line-level ship-to right after a nudge; missed the placer and the
  billing address (where follows the bill-to hat to the order), and named no purposes.
- 2026-10-23, Q2: ship-to hat on the line unprompted (progress), but the line's address
  dropped this time, and the breakage described as "one place": who and where still blur.
  Destination is per line, not per product. No why given. Reinforce.
- 2026-10-23, Contoso reinforce: who and where both on each line, unprompted, split per line.
  Roles to 3. Still open: the placing mechanism on the order (Priya's e-mail missed), and
  catalogue product vs serialized instance on a line (asked, explained).
- 2026-10-23, Q3: a rule stored as a role row (fact 5), and a line-level delivery contact put
  on the order with an invented courier role (fact 7). Priya as employment, not an organization
  contact, direction reversed (Ch 2). Whys mostly missing. Reinforce rules beside facts and
  the line's wheres beyond shipping.
- 2026-10-23, Q4: TAKEN_BY read as the client minutes after it was explained, and a hard-coded
  rule not seen as one: rules beside facts down to 2. Two order tables judged by repeated
  columns, not by doubled child tables. Fixes rarely named.
- 2026-10-23, ops manager reinforce: dated rules and the after-the-fact check right, unprompted
  (rules back to 3); cardinality put in the rule table. SALESPERSON filed as PLACED_BY twice:
  the placer / taker / salesperson trio is a gap (roles down to 2). Reinforce.
- 2026-10-24, R2 (Greenleaf): one party that receives and uses got only SHIP_TO; END_USER
  missed. A party doing two things on a line needs two role rows.
Misunderstandings and reinforce attempts, oldest first.

### 2026-10-26: question round Q6, Submodel 1 (Nevada Sports order 77: Javier in Madrid, a Pico €300, the optional binding mount €20, a one-off engraving of his name at an agreed €12, not in the catalogue)
- Key: three order items. Line 1 names the Pico (product), unit price 300. Line 2 names the
  binding mount (feature), ordered for line 1, 20. Line 3 names neither, its description says
  "engraving: Javier", 12, ordered for line 1 (it's on that board). Prices live on the lines,
  agreed snapshots; the price components say what we'd charge, and the engraving has none.
  The €330 rise changes nothing on order 77.
- Answer: (1) catalogue rows instead of order items ✗ (product, features, applicability
  OPTIONAL); the engraving made a feature with an applicability row ✗ (a one-off pollutes the
  catalogue; the description line is the book's answer); the mount a feature "since it is
  optional" (the reason is off: optional is the applicability type). Ordered for not named.
  (2) prices on `price_component` ✗ (that's the list; the agreed price is on the line).
  (3) nothing changes, snapshot on the order item ✓, which contradicts (2). Score: 2. The line
  row 3 → 2: order items vs catalogue, the description line and ordered for to reinforce.
