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

**Reinforce (hats and wheres), 2026-10-24, Lena's copier purchase from Globex:** PLACED_BY
Northwind (internal organization), APPROVER Dana, BILL_TO Northwind, two lines (2 and 1
copiers), SHIP_TO Northwind and a SHIPPING address on each line (right). Lena filed as
SALESPERSON (wrong, third time: she keyed it in, ENTERED_BY; a purchase credits no sale).
TAKEN_BY Globex missed. Order kind never stated. Placing and taking e-mails missed (again).
HQ address on the order with no purpose (BILLING). Denver's front desk phone on the order
(again: the Denver line's DELIVERY_CONTACT). Sara (END_USER) and TechFix (INSTALLER) missed on
the Denver line; TechFix sent to work effort instead (the job is Ch 6's, the hat is the line's).
Left out: the e-mail as a communication event (fair), Marco not mentioned (fine: Globex's
organization contact, Ch 2). Asked about a subcontractor relationship (not needed: neither end
is ours). Score: 2.

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
- 2026-10-24, Lena's copiers: SALESPERSON misfiled a third time (now for the person who keyed
  it in), TAKEN_BY missed on a purchase, order kind unstated. Wheres: the delivery contact on
  the order again, placing e-mail missed again, purposes dropped at the order level. The
  line's other hats (END_USER, INSTALLER) unknown. Roles and wheres stay at 2.
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

### 2026-10-27: session recall 1, Submodel 2 (Tostadero Luna, €400 of beans to a café in Zaragoza: €8 normal van delivery, €12 extra outside the usual zone, €2.50 order processing, 5% off for three years as a customer)
- Key: the six top types are DISCOUNT, SURCHARGE, SALES_TAX, SHIPPING_AND_HANDLING, FEE and
  MISCELLANEOUS_CHARGE. (1) SHIPPING_AND_HANDLING (it pays for moving the goods); (2) SURCHARGE
  (an extra on top of the normal, like the book's out-of-area delivery); (3) FEE; (4) DISCOUNT
  (a loyalty discount). All four go on the order, and none on a line. Rows 1–3 hold an amount
  and row 4 a percentage of the €400.
- Answer: (1) FEE ✗, the delivery mis-typed again (it was SURCHARGE in Q1); (2) SURCHARGE ✓;
  (3) FEE ✓; (4) DISCOUNT ✓. The six not named; the level and amount vs percentage not
  answered. Score: 2. Typed rows 3 → 2: the delivery has gone wrong twice, in two different
  ways. Test: "what is the charge paying for?" Moving the goods means SHIPPING_AND_HANDLING.

### 2026-10-27: session recall 2, Submodel 1 (Ciclos Brava: Lucía orders a Turia bike listed at €900, its optional rear rack €40, a one-off hand-painted club logo on the frame at an agreed €60; the Turia's list price rises to €950 a week later)
- Key: three order items. Line 1 names the Turia (product), unit price 900. Line 2 names the
  rack (feature), ordered for line 1, 40. Line 3 names neither: its description says what it
  is ("hand-painted club logo"), 60, ordered for line 1 (it's on that frame). Each price is the
  line's unit price, an agreed snapshot. The rise to €950 changes nothing on the order.
- Answer: order items this time, not catalogue rows ✓ (the slip from order 77 fixed);
  product, feature and neither ✓; the rack "linked to the product" (a guess) ✗: it's linked to
  the bike's line, through ordered for; the painting's description and its ordered for missed;
  prices on the order as a snapshot ✓ (on each line, as its unit price); the rise changes
  nothing ✓. Score: 3. The line row 2 → 3; ordered for (one line to another) still to reinforce.

### 2026-10-27: session recall 3, Submodel 2 (Harinera Sur to Panadería Olmo: 10 bags of yeast at €4, 20 boxes of flour at €15; €1 off each box, 10% off the order, €12 for delivery outside the usual zone)
- Key: three rows. DISCOUNT on line 2, amount 20.00 (the total charged, never the €1 per
  unit); DISCOUNT on the order, percentage 10; SURCHARGE on the order, amount 12.00. Line 2's
  unit price stays 15: the unit price is before discounts, and the discount is an adjustment
  so that reports can see it. The 10% is taken from the value before any adjustment, 340, so
  it's 34. Total: 340 − 20 − 34 + 12 = 298.
- Answer: types, levels and amount vs percentage all right, the surcharge with its reason ✓;
  the numbers not given (the 20.00 total never said); the "total" example muddled (2 × 10 + 1
  each = 22 is the line's charge, the adjustment's amount is 2); line 2's unit price not
  named, the reason given was "totals are calculated", not the convention ✗; the 10% taken
  after the line discount (32), total 300 ✗. Score: 2. Amount and percentage row 0 → 2: the
  base before any adjustment and the 15-not-14 convention to reinforce.

### 2026-10-27: Q2, Submodel 2 (Pinecone Supplies, order 501 dated 2026-10-20 to an Austin café, shipped 2026-11-05: an espresso machine (Equipment) and coffee beans (Food); lookup rows Texas 6.25, Texas Food 0, Austin 2.0 to 2026-11-01, Austin 2.5 from it; in December Texas 6.25 corrected to 6.5)
- Key: every boundary the ship-to lies in adds its rate, and per boundary a category rate
  beats the general one, as of the order date (not the ship date). Line 1: Texas 6.25 + Austin
  2.0 = 8.25; line 2: Texas Food 0 + Austin 2.0 = 2.0. Two SALES_TAX adjustments, one on each
  line, the rate copied into the percentage column (8.25, 2.0); no link to the lookup row. The
  December fix changes nothing on order 501: the copy is a snapshot.
- Answer: rows A+C and B+C ✓, C not D by the order date ✓ (the ship date bait avoided);
  the totals 8.25 and 2.0 not said; why B beats A not said (not asked); on the order
  adjustment pointing at the line ✓, the type and the copied percentage not said; the
  snapshot and the optional check ✓. Score: 3. Tax row 0 → 3. A habit across the session:
  numbers left out when asked for (recall 3 and Q2).

### 2026-10-27: Q3, Submodel 2 (Ferretería Llano's columns: order discount_pct, shipping_cost, tax_rate; line discount_per_unit. Order 88: 20 boxes of screws at €5 with €0.50 off each, a drill at €120; 5% loyalty, 3% cash, €9 normal delivery, €4 rush, VAT 21% on both lines)
- Key: (1) the two discounts squeeze into one 8 (they compound differently and lose their
  reasons); no column for the rush; a per-line tax column is one more column per charge (the
  naive trap again). (2) DISCOUNT on line 1, amount 10.00; DISCOUNT on the order, 5; DISCOUNT
  on the order, 3; SHIPPING_AND_HANDLING on the order, amount 9.00; SURCHARGE on the order,
  amount 4.00; SALES_TAX on each line, 21. (3) We store 10.00, the total. At 30 boxes their
  0.50 × 30 = 15 follows by itself; our 10.00 goes stale until the line is repriced. On this
  point their design is better; it's the cost of storing amounts as totals.
- Answer: (1) the 8 losing its audit trail ✓, the rush with no column ✓, then a tax_per_line
  column proposed ✗ (the column-per-charge trap). (2) both order discounts, the rush, the tax
  per line ✓; the €9 normal delivery typed FEE ✗ (third time, half an hour after FLOUTS); the
  line's €0.50 discount row missed ✗. (3) discount_per_unit read as 50% ✗ (it's €0.50, an
  amount); "ours recalculates" ✗, the opposite of what was agreed earlier this session.
  Score: 2. Typed rows stays 2 (the delivery again); amount and percentage 2 → 1.
- Revised after the user's pushback: under their reading (0.50 as 50%), "ours recalculates"
  is right for a percentage row, so part 3 holds one mistake, the misreading (the question
  said €0.50; the column name alone is ambiguous). No evidence on the stale amount: amount
  and percentage back to 2. Part 2's missed line row held (the question asked for every
  adjustment, "order or line"); the layout shares a little of the blame. Score stays 2.

### 2026-10-27: R1 reinforce, Submodel 2 (Panadería Olmo's e-mail: 30 bags of flour at €12 with "the usual €1 off each bag", 5 trays of yeast at €8, the normal van €10; then 40 bags)
- Key: two items (flour 30 at 12, yeast 5 at 8); DISCOUNT on line 1, amount 30.00;
  SHIPPING_AND_HANDLING on the order, amount 10.00. At 40 bags the quantity becomes 40 and the
  discount's 30.00 goes stale (should be 40.00): the row stores the total, not "€1 a bag", so
  nothing in the model notices. Before the freeze the app reprices; a check can only compare
  against a rule stored somewhere (a price component for Olmo's €1).
- Answer: every row and number right, cold; the delivery typed shipping ✓ (first time today);
  the stale 30 → 40 ✓; "frozen" used for stale (the freeze is the business rule, staleness
  comes from storing the total), and a data-quality query said to flag it (it can't without a
  stored rule). Score: 3. Typed rows 2 → 3, amount and percentage 2 → 3.
- Layout note for Q3 (Llano): the €0.50 sat in the line list under a separate "on the whole
  order" list; blame about half and half. Hidden adjustments now marked "(watch the lines)".

### 2026-10-27: round Q1, Submodel 2 (Vivero Alba: 20 pots at €8, 10% off the pots, a 5% rush on the order, the van €12)
- Key: (1) the six cold. (2) DISCOUNT on line 1, percentage 10; SURCHARGE on the order,
  percentage 5; SHIPPING_AND_HANDLING on the order, amount 12.00. (3) Both percentages are
  taken on the value before any adjustment: the line's 20 × 8 = 160, so −16; the rush also
  on 160, so +8. Total 160 − 16 + 8 + 12 = 164.
- Answer: (1) all six named cold, through FLOUTS ✓. (2) the discount and the delivery right,
  delivery typed shipping cold ✓; the rush typed MISCELLANEOUS ✗ (an extra charge on top is a
  surcharge; "other" is the leftover bin, only when nothing else fits). (3) 160 as the base,
  each adjustment on the source and independent of the others, −16, the rush +8, cold ✓
  (part 3 worded badly at first; reworded on request). Score: 3. Typed rows stays 3 (the six
  and the delivery cold, the rush in the leftover bin); amount and percentage stays 3 (the
  base cold, the same day as its mistake: 4 on a later day).

### 2026-10-28: session recall 1, Submodel 2 (Floristería Brisa, order 18, a bouquet of roses: an €8 same-day rush, the €6 normal delivery, €2 for paying by bank card)
- Key: (1, Remember) the six top types: DISCOUNT, SURCHARGE, SALES_TAX,
  SHIPPING_AND_HANDLING, FEE and MISCELLANEOUS_CHARGE. (2, Apply) the rush SURCHARGE (an
  extra on top of the normal), the delivery SHIPPING_AND_HANDLING (it pays for moving the
  goods), the card FEE. All three go on the order (not asked).
- Answer: (1) all six ✓, but not cold: Claude called the user "Señor FLOUTS" just before,
  the hook itself (Claude's slip; yesterday's cold naming stands). (2) all three ✓ cold: the
  rush SURCHARGE (yesterday's MISCELLANEOUS fixed on a later day), the delivery shipping,
  the card FEE. Levels given unasked: the card fee put on the item, from a question that
  named no lines and a follow-up that offered "a card" as one (about 70/30 Claude's); once
  the card read as a bank card, the order, "a payment fee for the order, not one item" ✓.
  Score: 4. Typed rows 3 → 4.

### 2026-10-28: session recall 2, Submodel 2 (Papelería Sol, order 9: 10 notebooks at €6; on the line a DISCOUNT stored as the 10.00 total; on the order a 10% loyalty DISCOUNT)
- Key: (1, Apply) the 10% is of the value before any adjustment, 10 × 6 = 60, so 6.00;
  total 60 − 10 − 6 = 44. (2, Understand) every percentage is taken from the source value,
  so each adjustment row stands alone and no order of application is needed:
  `order_adjustment` stores none (point 11, our assumption, not the book's; real billing
  takes discounts before tax, revisit at Ch 7).
- Answer: (1) the line discount first, then 10% of 50: 5 and 45 ✗, the Olmo slip again on a
  later day. (2) "by convention" ✓, but the convention's direction reversed ✗; no why. After
  "it runs the other way", 60 − (10 × 1) − (60 × 0.10) ✓ (picked between the two). The
  follow-up (a 5% rush beside the 10%: which first, and where is that stored?) was a dud,
  Claude's: two percentages give the same total in either order. The order only bites when
  an amount and a percentage mix (here: the €10 first gives 45, the 10% first gives 44).
  Not counted against the user. Score: 1. Amount and percentage row 3 → 2: the base before
  any adjustment, and its why (no sequence stored), to reinforce.

### 2026-10-28: session recall 3, Submodel 1 (Muebles Roca, order 14: Ana orders two Lino sofas (€700), one in grey velvet (+€60), one in blue linen (+€40), both fabrics selectable features)
- Key: (1, Apply) four order items: line 1 the Lino (product), 1 at 700; line 2 grey velvet
  (feature), 1 at 60, ordered for line 1; line 3 the Lino, 1 at 700; line 4 blue linen
  (feature), 1 at 40, ordered for line 3. Two sofa lines, not one at quantity 2: they
  differ. (2, Analyze) `ordered_for_order_item_id` points line to line; a link to the
  product couldn't tell the two sofas apart.
- Answer: all four lines exactly as the key, with the quantities and prices on the lines,
  cold ✓; ordered for named as the item id ✓, line to line (yesterday's guess, a link to the
  product, fixed on a later day). Score: 4, revised to 3: the user then said the two sofa
  lines were a guess, and asked how they differ (taught: a line holds units alike in
  everything the line and its children say; ordered for points at a line, not a unit, so
  units that differ in a feature, price, ship-to or date split). The line row stays 3:
  ordered for cold; when to split a line and the description line to retest cold.

### 2026-10-28: round Q7, Submodel 2 reinforce (Tueste Café Supplies, order 30: 4 bags of coffee at €10; a grinder at €60 with a DISCOUNT of amount 5.00 on its line; on the order an €8 SHIPPING_AND_HANDLING and a 10% loyalty DISCOUNT)
- Key: (1, Apply) the source is 40 + 60 = 100; the 10% is of that, 10.00 (not of 95 after the
  grinder's discount, not of 108 with the delivery). Total 100 − 5 + 8 − 10 = 93. (2,
  Understand) every percentage is taken from the value before any adjustment, so each row
  stands alone and no order of application is needed; `order_adjustment` stores none.
- Answer: (1) −10 and 93 ✓, the source per line and the delivery kept out of the base,
  unhinted (taught this morning in recall 2, so 3 at most). The grinder's discount written as
  quantity × 5: a fair reading of "€5 off the grinder" (per grinder × 1 = the 5.00 total);
  Claude's note against it withdrawn after the user's pushback (the wording put a per-unit
  phrase beside the stored total, and at quantity 1 the two can't be told apart). The user
  then explained it unprompted: the stored amount is the total, quantity × the per-unit
  discount, so two grinders would store 10 ✓ (the amount as the total, a day after Olmo's
  R1).
  (2) "from the source total, not the total with adjusted items" ✓; the why only "we have
  decided" ~ (the convention, not its reason). Score: 3. Amount and percentage 2 → 3; the
  base with its why, and the amount as the total, cold on a later day for 4.

### 2026-10-30: question round, pending (asked 10-29, answered in a later session; order in TODO)
- **Q1 · Order status, terms and item associations · Apply (recall: on order or line).**
  Mercado Lume takes sales order 52 from Hostal Brisa: line 1, 40 towels; line 2, 12
  bathrobes. On 2026-10-29 the order is approved; the same day line 2 goes on backorder
  (robes out of stock). Brisa pays net 30 on the whole order, and the robes can't be
  returned. Write the rows: table, type, what each points at. Key: `order_status`
  ORDER_APPROVED on order 52 (item null), ORDER_BACKORDERED on line 2 (order null), each
  with its datetime; `order_term` PAYMENT_DUE_DAYS 30 on the order, NO_EXCHANGE_OR_REFUND
  on line 2 with no value (the type says it all). One target per row, never both.
- **Q2 · Order adjustments · Apply (recall: the percentage's base).** Lámpara Norte's order
  61, line 1: 10 desk lamps at €20. On that line, a €15 goodwill discount and a 10% trade
  discount. Write the rows and the line's total. Key: two `order_adjustment` rows on line 1,
  both DISCOUNT (or a subtype), one amount 15 (the total, not per lamp), one percentage 10;
  the 10% taken from 200, the value before any adjustment (20, not 18.50), so 200 − 15 − 20
  = 165; why: no row depends on another, no order of application.
- **Q5 · Orders, items and order parties · Apply (gap: splitting lines, the description
  line).** Taller Pino takes order 63: 3 Nórdica chairs at €90, two in oak, one in walnut
  (walnut a €40 feature); and a one-off fix of a wobbly leg on the customer's old chair,
  agreed by phone at €25, not in the catalogue. Write the order items. Key: two chair lines
  (2 and 1), because units differ in a feature; a walnut feature line (qty 1, €40) ordered
  for the walnut chair's line (oak: no line if standard, or a €0 feature line ordered for
  the oak line if selectable; either, said why); the fix a line with no product and no
  feature, a description and the agreed €25 as its snapshot. Prices on every line.

### 2026-10-30: round Q1 answered, Submodel 3 (Mercado Lume, order 52; key above)
- Answer: (1) `order_status` APPROVED on order 52 with its date ✓, and unprompted: statuses
  stack in time, one row points at the order or a line ✓. (2) The backorder as an item
  association (sales line linked, purchase not yet) ✗: it is an ORDER_BACKORDERED status on
  line 2; an association is the later link to the purchase line that restocks it. (3) Net 30
  as an `order_adjustment` DISCOUNT of 30 on the order ✗: a condition, not money, so
  `order_term` PAYMENT_DUE_DAYS 30 (days). (4) `order_term` with no value ✓, but on the
  order ✗: only the robes, so line 2.
- Score: 1. Placement (order or line) right once in three; terms vs adjustments and status
  vs association blurred. Reinforce: what each of the three tables records.
- Pushback: "pays net 30" read as paid now, so an adjustment (+). Wording partly Claude's
  (present tense), but a payment now is a payment (invoicing chapter), not an adjustment
  either: adjustments change what's owed, payments settle it. Score kept. Line statuses
  seen as unusual; taught they are routine (lines move apart: backordered, shipped, cancelled).

### 2026-10-30: round Q2 answered, Submodel 2 (Lámpara Norte, order 61; key above)
- Answer: base 200 = 10 × 20 ✓, the 10% of 200 not 185 ✓ (cold, unhinted), the €15 once as
  a total ✓. Arithmetic slip: wrote −10 for 200 × −0.10, total 175 (key 165). Rows not
  written (two `order_adjustment` DISCOUNT rows on line 1, one amount 15, one percentage 10).
  No why given.
- Score: 3. The base applied cold on a later day, but the why (each row stands alone, no
  order of application) still missing for 4.
- The why reached with help (asked what deleting the €15 would do if the 10% were taken
  from 185): "chained adjustments need a stored order; from baseline values (the line's or
  the order's) they're independent" ✓. Score kept at 3; the why unprompted for 4.

### 2026-10-30: round Q5 answered, Submodel 1 (Taller Pino, order 63; key above)
- Answer: two chair lines, 2 oak at €90 and 1 walnut at €90 ✓ (the split cold, no hint);
  oak taken as standard, so no feature line ✓ (assumption said); the walnut feature line,
  qty 1, €40, ordered for the walnut chair's line ✓; the fix a line with no product and no
  feature, a description and €25 ✓; prices on every line ✓. Unprompted: TAKEN_BY Taller
  Pino, PLACED_BY the unnamed customer ✓. Order kind "not disclosed": fair, since the
  question never said whose system it is (the question's gap, not the user's).
- Score: 4. The split and the description line applied cold on a later day (the 10-28
  retest). The why of the split (units differing in a feature) was shown, not said.

### 2026-10-31: round Q1, Submodel 3 recall (Mercado Lume: what a status, a term and an adjustment each record)
- Asked: Understand, one line each with a grocery example. Key: status = a dated state
  (where the order or one line stands; the latest row is current), e.g. ORDER_SHIPPED;
  term = an agreed condition on the order or a line, one bare value read through its type
  (or none), e.g. PAYMENT_DUE_DAYS 30, NO_EXCHANGE_OR_REFUND; adjustment = money that
  changes the total, on the order or a line, e.g. a 5% DISCOUNT, SHIPPING_AND_HANDLING.
- Answer: status a dated history, latest is current, shipped / invoiced ✓; "a copy from
  the fact": fair, a SHIPPED status restates what the shipment records. Term "what should
  happen if an event" (half: agreed conditions, some conditional), but the example a 25
  discount for 1000 units ✗ (a catalogue price rule with a quantity break, an adjustment once
  applied); asked whether a term carries two numbers (no: one value, its type says what it
  means). Adjustment: extra charges and discounts on a line or the order, the types listed,
  30% discount ✓; terms called "suggestions" ✗ (agreed and binding, just not money); "check the
  catalogue and recalculate" first read as the total coming from the catalogue; the user's
  meaning: the order stores what was agreed, and how it was reached (which base won, which
  discount matched) is read from the price components as of the order date ✓ (the misreading
  mine). Status "a copy from the fact": a dated handshake, the live truth in the related
  tables (shipments, invoices) ✓; a check can catch the two disagreeing.
- Score: status 3, adjustment 3, term 1 → 2 (the condition sense half there, the example
  still money). Mnemonic given: where it stands, what's agreed, what it costs.

### 2026-10-31: round Q2, Submodel 3 recall (Mercado Lume, sales order 70: honey backordered, bought in)
- Asked: Apply. Mercado Lume's sales order 70, line 1: 200 jars of honey, none in stock on
  3 Nov. On 4 Nov Mercado Lume orders 500 jars from Apiarios Sol (purchase order 15, line 1);
  200 of them are meant for order 70. Write the rows for 3 Nov and for 4 Nov. Key: 3 Nov an
  `order_status` ORDER_BACKORDERED on sales line 1 (the line, not the order), with its
  datetime; 4 Nov purchase order 15 with its line (a purchase, Mercado Lume the placer,
  Apiarios Sol the taker) and an `order_item_association` sales line 1 → purchase line 1 (no
  quantity on it, as drawn; the 200 is a known gap, NOTES point 17). Not an adjustment, not a
  term. The backorder status stays until a later status (e.g. shipped) stacks on top.
- Answer: order 70 and line 70-1 taken as existing (the wording left the order date open:
  the question's gap). 3 Nov: "could have" a status on order 70, "waiting on goods": a
  status, not an association ✓ (the 10-30 Q1 mistake not repeated), but on the order, not
  the line, ORDER_BACKORDERED not named, and offered rather than written. 4 Nov: the purchase
  order and its line ✓ (numbered 69, not 15; parties not named); the sales line linked to
  the purchase line through the subtypes ✓, and unprompted: the link carries no quantity ✓.
  An ORDERED status dated 4 Nov on "line 1" (which order's line not said).
- Score: item association 4 (cold, a later day, its gap seen unprompted); backorder as a
  status 3 (right table, unprompted; the line level and the name missing).

### 2026-10-31: round Q3, Submodel 3 recall (Mercado Lume, sales order 71 to Hotel Brisa)
- Asked: Apply. Order 71 (already placed): line 1 olive oil, line 2 fresh fish. Agreed with
  the hotel: pay within 30 days; the oil delivered within 5 days; no returns on the fish
  once delivered; 5% off the whole order for loyalty. Write the rows. Key: three
  `order_term` rows: PAYMENT_DUE_DAYS 30 on the order; DELIVERY_WITHIN_DAYS 5 on line 1;
  NO_EXCHANGE_OR_REFUND on line 2 with no value; the 5% an `order_adjustment` DISCOUNT,
  percentage 5, on the order (money, so not a term). Each term on the order or one line,
  never both.
- Answer: four terms: net 30 ✓ (level not said), delivery within 5 days on line 1 ✓, no
  returns with no value ✓ (its line not said), and the 5% loyalty discount as a term ✗
  ("all terms, what was agreed"): money, so an `order_adjustment`. The Q1 boundary (money or
  not) missed again, 20 minutes after it was taught.
- Score: term 2 kept (typed values, a line-level term and a valueless one right; the
  money-vs-condition line failed again). The wording shares the blame: the list sat under
  "Agreed with the hotel", the mnemonic's word for a term. Retest on a later day.

### 2026-10-31: round Q7, Submodel 1 maintenance (scoped roles; Oficina Viva, sales order 80 to Grupo Lema)
- Asked: Apply. We are Oficina Viva (office furniture). Grupo Lema's buyer Lucía places
  order 80 by phone; our rep Diego takes it and gets the full commission; Nora, our clerk,
  keys it in; Grupo Lema's head office pays. Line 1, 10 desks: delivered to the Sevilla
  branch, whose team uses them. Line 2, 20 chairs: delivered to Grupo Lema's warehouse, then
  assembled at the Sevilla branch by Montajes Sur. Write the role rows. Key: on the order:
  PLACED_BY Grupo Lema (Lucía too, or as the placer's contact, said which), TAKEN_BY
  Oficina Viva, SALESPERSON Diego (100%), ENTERED_BY Nora, BILL_TO Grupo Lema head office.
  Line 1: SHIP_TO and END_USER the Sevilla branch. Line 2: SHIP_TO the warehouse, INSTALLER
  Montajes Sur, END_USER the Sevilla branch. Nora not PLACED_BY or SALESPERSON; roles per
  line where lines differ.
- Answer: PLACED_BY Grupo Lema with Lucía as its contact ✓, with the why unprompted (a
  person with two employers would leave the placer ambiguous); SALESPERSON Diego ✓;
  ENTERED_BY Nora ✓; BILL_TO Grupo Lema ✓. Line 1 SHIP_TO and END_USER Sevilla ✓ (the
  END_USER written on line 2, a typo by the user's word); line 2 SHIP_TO the warehouse ✓.
  Missed: TAKEN_BY Oficina Viva, line 2's END_USER, and INSTALLER Montajes Sur on line 2.
- Score: scoped roles 4 → 3 (three hats left off either way; the per-line split and the placer's why cold).

### 2026-11-01: question round, pending (written for the phone; wording in `docs/round-2026-11-01.md`; order in TODO)
- **Q1 · Submodel 3 recall · term or adjustment (the 10-31 Q3 retest) · Apply.** Tostadero
  Brío, sales order 90 to Restaurante Ola (line 1 beans, line 2 grinders): paid within 15
  days; 4% off the order, a launch promotion; the grinders cancellable without penalty up to
  5 days before delivery; €10 for delivery. Key: `order_term` PAYMENT_DUE_DAYS 15 on the
  order (item null); `order_adjustment` DISCOUNT, percentage 4, on the order (money, so not a
  term, though it was promised); `order_term` PENALTY_FREE_CANCEL_DAYS 5 on line 2 only;
  `order_adjustment` SHIPPING_AND_HANDLING, amount 10, on the order (a normal delivery: not
  FEE or SURCHARGE). Test: does it change the money? One target per row. The list sits
  under "the order confirmation lists", not "agreed", so the wording leans neither way.
- **Q2 · Submodel 3 recall · status on the line, named · (a) Apply, (b) Understand.**
  Sales order 91 to Hotel Mar (line 1 beans, line 2 a roasting machine): approved 3 Nov, the
  machine cancelled 4 Nov, the beans shipped 6 Nov. Key: (a) `order_status` ORDER_APPROVED
  on order 91 (item null), 3 Nov; ORDER_CANCELLED on line 2 (order null), 4 Nov, not on the
  order, which lives on; ORDER_SHIPPED on line 1, 6 Nov; each with its datetime. (b)
  ORDER_SHIPPED: the latest row pointing at line 1 with a datetime on or before 7 Nov; rows
  stack, none is overwritten. The order's APPROVED row is the order's, not line 1's.
- **Q3 · Submodel 3 recall · a stored status vs its fact (the 10-29 walk-through slip) ·
  (a) Evaluate, (b) Understand.** Mercado Lume, sales order 75: an "invoiced" status row
  dated 10 Nov, the invoice record dated 12 Nov. Key: (a) 12 Nov: the fact wins, the status
  is a copy, so fix the status row (re-date it or remove it); not "neither is true". (b) Two
  places hold one fact, so one can change without the other (a status keyed by hand, an
  invoice re-dated or cancelled later); stored anyway as a quick, dated history of where the
  order stands without joining shipments and invoices, with a data-quality query comparing
  the two to catch the drift (or derive it instead).
- **Q4 · Submodel 1 gap · scoped roles (10-31 Q7: TAKEN_BY, END_USER, INSTALLER) · Apply.**
  Clima Sur, sales order 82: Pablo of Hotel Faro places it; our reps Inés and Raúl split the
  commission; Grupo Faro (the parent) pays; line 1 air conditioners to the hotel, installed by
  Frío Norte, used by the hotel; line 2 filters to Grupo Faro's depot, used by its team. Key:
  `order_role` PLACED_BY Hotel Faro (Pablo as its contact, or Pablo himself; said which),
  TAKEN_BY Clima Sur, SALESPERSON Inés 50 and Raúl 50 (`percent_contribution`), BILL_TO Grupo
  Faro. `order_item_role` line 1: SHIP_TO Hotel Faro, INSTALLER Frío Norte, END_USER Hotel
  Faro; line 2: SHIP_TO Grupo Faro (the depot is the where, a contact mechanism, not asked),
  END_USER Grupo Faro. Inés is not TAKEN_BY: the organization takes the order. "Handles the
  sale" was chosen over "takes it", so the TAKEN_BY recall is unhinted either way.
- **Q6 · Submodel 1 maintenance · contact mechanisms with a purpose on the order and the line
  (last 4 on 10-25) · Apply.** Librería Atlas, sales order 84 from Colegio Pinar. Key:
  `order_contact_mechanism` secretaria@pinar.example ORDER_PLACING, pedidos@atlas.example
  ORDER_TAKING, Calle Mayor 5 BILLING; `order_item_contact_mechanism` line 1 Calle Olmo 2
  SHIPPING, line 1 600 111 222 DELIVERY_CONTACT, line 2 Calle Mayor 5 SHIPPING. Calle Mayor 5
  is one `contact_mechanism` row, linked twice with a different purpose on each link.

### 2026-11-01: round Q4, Submodel 1 gap (scoped roles; Clima Sur, sales order 82; key above)
- Answer: PLACED_BY Hotel Faro with Pablo as its contact ✓; SALESPERSON Inés 50 and Raúl 50 ✓;
  BILL_TO Grupo Faro ✓. Line 1 SHIP_TO Hotel Faro ✓, INSTALLER Frío Norte ✓ (missed on
  10-31); line 2 SHIP_TO and END_USER Grupo Faro ✓ (missed on 10-31). Missed: TAKEN_BY Clima
  Sur (second round running) and line 1's END_USER Hotel Faro ("the hotel uses them" was in
  the question). Side slip, not scored here: invented `order_role_contact` /
  `order_item_role_contact` tables hanging the e-mail and the depot off the role; in the
  generic model a contact mechanism hangs off the order or the line with a purpose
  (`order_contact_mechanism`, `order_item_contact_mechanism`). Q6 tests that.
- Score: scoped roles stays 3 (INSTALLER and line 2's END_USER now cold; TAKEN_BY still
  missing, and the END_USER moved lines). Next retest: TAKEN_BY cold, END_USER on every line.

### 2026-11-01: round Q1, Submodel 3 recall (term or adjustment; Tostadero Brío, sales order 90; key above)
- Answer: (a) a term on the order, 15 ✓, typed "net pay in 15 days" (PAYMENT_DUE_DAYS) ✓;
  (b) an adjustment on the order, DISCOUNT, a percentage ✓, with the why cold (money changes,
  so not a term, though agreed: the 10-31 slip fixed) ✓, but the value written 5, not 4 ✗
  (a slip); (c) a term on line 2 only, 5 ✓; (d) an adjustment on the order, amount 10 ✓,
  typed "shipping and delivery" (SHIPPING_AND_HANDLING, close enough) ✓. Extra ✗: a link from
  the term to a time-frequency unit, "otherwise 5 what?": the type answers that
  (PENALTY_FREE_CANCEL_DAYS); the value is bare and read through its type (ponder 96's "what
  would you add if terms needed units" is where a unit link would come in).
- Score: term row 2 → 3 (all four sorted right, the discount's why cold); not 4 while the
  unit link stands in for the type.

### 2026-11-01: round Q2, Submodel 3 recall (status on the line; Tostadero Brío, sales order 91 to Hotel Mar; key above)
- Answer: (a) APPROVED 3 Nov on order 91 ✓; CANCELLED 4 Nov on line 2 ✓ (the order lives
  on); SHIPPED 6 Nov on line 1 ✓; all cold. "Linked to order 91, line item #2" read as the
  item of order 91 (the row points at the line, order_id null: one target per row); the table
  (`order_status`) implied by "order status rows", not named. (b) SHIPPED, the latest row
  pointing at line 1 ✓; the as-of cut (on or before 7 Nov) left out, harmless here.
- Score: the line-level status cold on a later day (10-31 put the backorder on the order):
  the status part at 4; the row waits for Q3 (the fact wins).

### 2026-11-01: round Q3, Submodel 3 recall (a stored status vs its fact; Mercado Lume, sales order 75; key above)
- Answer: (a) "both are right, one more right": the invoice is the fact ✓, it drifts with
  nothing to stop it, the guards named (write the status with the invoice, a job, a
  data-quality query) ✓; then "leave it as is, a snapshot of the invoice date" ✗: a status
  saying invoiced on 10 Nov when no invoice existed until 12 Nov is wrong, not a snapshot;
  re-date or remove it, or an as-of query on 11 Nov answers wrong. (b) the drift and decisions
  made on the copy ✓; stored for a fast, dated history without the joins ✓; beyond the key:
  statuses with no fact behind them (APPROVED) are themselves the truth, and you must know the
  catalogue to tell the two kinds apart ✓.
- Score: status row stays 3. Q2's status on the line cold (4 on its part), but the fact
  wins only half: named, then left standing ("both right", the 10-29 hedge again). Retest:
  the action when the copy and the fact disagree.
- After grading: the user's reading was the invoice re-dated later, the status left stale;
  the fix (update the status date, or remove the row) said once asked. Score held at 3: the
  written answer said leave it; retest cold on a later day.

### 2026-11-01: round Q6, Submodel 1 maintenance (contact mechanisms with a purpose; Librería Atlas, sales order 84; key above)
- Answer: on the order: pedidos@ "taken by", secretaria@ "placed by", the postal address
  "bill to" ✓ (the purposes named with role words: ORDER_TAKING, ORDER_PLACING, BILLING; the
  billing address not named Calle Mayor 5); on line 1: Calle Olmo 2 SHIPPING ✓ (discussed
  earlier that day, a freebie), 600 111 222 DELIVERY_CONTACT ✓ (on the line, not the order:
  the old 10-24 slip gone); line 2 Calle Mayor 5 SHIPPING ✓. Calle Mayor 5 as one mechanism
  linked twice not said (not asked). Roles added unasked: PLACED_BY, TAKEN_BY, BILL_TO ✓ (the
  10-31 and Q4 TAKEN_BY gap filled, prompted by the question naming "we take it"); SHIP_TO on
  line 1 given to "the school annex" as a party ✗: the annex is a place of Colegio Pinar,
  the where (Calle Olmo 2), so SHIP_TO Colegio Pinar (the Q4 depot point again).
- Score: contact mechanisms stays 4 (every row cold, both levels, the delivery contact on
  the line). Note for the roles row: place-as-party slip, retest with the TAKEN_BY one.

- After grading: SHIP_TO the organization, the place a SHIPPING mechanism; purposes renamed ORDER_TAKING, ORDER_PLACING, BILLING; both by the user, once pointed out.

### 2026-11-02: question round, pending (written for the phone; wording in `docs/round-2026-11-02.md`; order in TODO)
- **Q1 · Submodel 3 recall · term or adjustment, the bare value read through the type ·
  (a) Apply, (b) Understand.** Quesería Valle, purchase order 40 to Granja Roble (line 1
  milk, line 2 rennet). Key: (a) `order_term` NONPERFORMANCE_PENALTY_PCT 3 on line 1 (a
  condition: money only if the milk is late, so the order's price doesn't change; the book
  files it as a term); `order_term` DELIVERY_WITHIN_DAYS 2 on line 1; `order_term`
  NO_EXCHANGE_OR_REFUND on line 2, no value; `order_adjustment` SHIPPING_AND_HANDLING, amount
  25, on the order (it changes the money now). One target per row. (b) The type: its name and
  description say percent or days, so `term_value` stays a bare number and no unit link is
  needed (the 11-01 Q1 extra). The penalty is the twist: "pays us 3%" sounds like money, but
  nothing is charged unless the condition happens.
- **Q2 · Submodel 3 recall · a stored status vs its fact (the 11-01 Q3 retest: fix the copy)
  · (a) Evaluate, (b) Understand.** Panadería Trigo, sales order 120: a "shipped" status row
  dated 14 Nov, no shipment at all. Key: (a) trust the shipments (the fact); the status row
  is a copy that was keyed wrong, so remove it (or record the truth with a new row, e.g.
  ORDER_BACKORDERED, if the history should show the mistake); a data-quality query comparing
  statuses with shipments catches the drift. Not "keep both". (b) The latest `order_status`
  row for order 120 left after the fix (e.g. ORDER_APPROVED, or ORDER_BACKORDERED if added),
  found as the row with the greatest datetime on or before today; rows stack, none overwritten.
- **Q3 · Submodel 3 recall · backorder on the line + item association · (a) Apply,
  (b) Understand.** Ferretería Nudo, sales order 130 (line 2 drills) and purchase order 55
  (line 1, 25 drills). Key: (a) `order_status` ORDER_BACKORDERED on sales line 2 (order
  null), 5 Nov; `order_item_association` sales order 130 line 2 → purchase order 55 line 1
  (through `sales_order_item` and `purchase_order_item`). Not on the order: the cement isn't
  waiting. (b) Nowhere on the link: the association has no quantity. The 10 is the sales
  line's own quantity; the other 15 just go to stock (Ch 3's inventory once received).
- **Q4 · Submodel 1 gap · scoped roles (11-01 Q4: TAKEN_BY, END_USER on every line; SHIP_TO
  the organization) · Apply.** Muebles Encina, sales order 140. Key: `order_role` PLACED_BY
  Gestoría Prado (Laura as its contact, or Laura herself; said which), TAKEN_BY Muebles
  Encina (the organization, not Tomás, though he "takes the call"), SALESPERSON Tomás 100,
  BILL_TO Gestoría Prado. `order_item_role` line 1: SHIP_TO Gestoría Prado (Calle Sauce 4 is
  the where, a SHIPPING contact mechanism, not a party), INSTALLER Montajes Río, END_USER
  Gestoría Prado; line 2: SHIP_TO Laura, END_USER Laura (a person can hold line roles).
- **Q5 · Submodel 2 gap · amount or percentage, the base and its why (10-28 Q7: the base and
  why cold on a later day) · (a) Apply, (b) Apply, (c) Understand.** Floristería Alba, sales
  order 150 (line 1 20 × €15 = 300, line 2 5 × €8 = 40). Key: (a) `order_adjustment` DISCOUNT
  amount 40 on line 1 (the amount is the total charged, not €2 per unit); DISCOUNT (or
  LOYALTY_DISCOUNT) percentage 10 on the order; SHIPPING_AND_HANDLING amount 12 on the order.
  (b) 10% of 340 (the lines before any adjustment) = 34; total 340 − 40 − 34 + 12 = 278.
  (c) Our convention: every percentage is of the value before any adjustment, because nothing
  stores an order of application (no sequence on the adjustment or its type); so the result
  doesn't depend on which row is read first. The book is silent; real billing would usually
  discount first (point 11).

### 2026-11-02: round Q1, Submodel 3 recall (term or adjustment; Quesería Valle, purchase order 40; key above)
- Answer: (a) the late-milk penalty an `order_adjustment` SURCHARGE, percentage 3, on line 1,
  "I don't know how to model the condition" ✗; delivery within 2 days a term ✓ but on the
  order ✗ (the question said "the milk": line 1); the rennet's no-returns a term on line 2 ✓;
  transport an adjustment on the order, amount 25, "shipping and delivery" ✓. (b) the 2's
  days from the type's name ✓; the 3's percent from the adjustment's percentage column
  (consistent with the misfiling).
- Why the penalty is a term: nothing is charged unless the milk is late, so the order's
  price doesn't change; the condition the user couldn't place is exactly what the term's
  type holds (NONPERFORMANCE_PENALTY_PCT: "if they fail, they pay this %"). And a SURCHARGE
  runs the wrong way: on our purchase order it raises what we pay Granja Roble, while the
  penalty is money they'd pay us. If it's ever triggered, the money appears later (on the
  invoice, Ch 7), not on the order.
- Blame: about 70/30 the user's. "Pays us 3%" was a deliberate money-sounding twist, and the
  D1 test ("does it change the money?") reads ambiguously for money that may come later;
  the delivery line slip is the user's alone.
- Score: term row 3 → 2. D1's test sharpened to "the order's price, now", with this trap.
  Next retest: a conditional penalty or rebate as a term, and the target line when the
  wording names one item.
- Pushback (the same day): the user filed the penalty by the mnemonic on the cards, "what's
  agreed besides money", and the 3% is money. Fair: that wording (tightened by Claude on
  10-31) says a term is never about money, and the book's own terms include money ones
  (NONPERFORMANCE_PENALTY_PCT, CANCELLATION_CHARGE_PCT). The misfile is the rule taught, not
  a recall failure, so the blame turns about 70/30 Claude's on that part. Row back to 3; the
  delivery-on-the-order slip still keeps it off 4. Taught: a term is the rule (what happens
  if), and if the penalty triggers, the fact lands downstream on the invoice (Ch 7), not as
  an order adjustment; the order keeps what was agreed when it was placed.

### 2026-11-02: round Q2, Submodel 3 recall (a stored status vs its fact; Panadería Trigo, sales order 120; key above)
- Answer: (a) trust the shipments ✓; the status a copy that doesn't reflect the truth, likely
  added ahead of time ✓ (a cause named); remove the status row ✓, cold: the 11-01 Q3 slip
  ("keep both as a snapshot") fixed. (b) the latest status row for the order ✓; "it could be
  nothing" ✓ given the wording.
- Not given, offered as upgrades: the goods waiting for flour is itself a status worth
  recording (ORDER_BACKORDERED, dated now), so the order doesn't go silent once the wrong row
  is gone; and a data-quality query comparing SHIPPED rows with shipments catches the next
  one. "On or before the as-of time" left implicit.
- Blame on (b): Claude's. The question listed no other rows, so "the latest left, maybe
  none" was the only possible answer.
- Score: this part at 4 cold (the fix and its why). The status row's level is set after Q3,
  which tests the status on the line.

### 2026-11-02: round Q3, Submodel 3 recall (backorder on the line + item association; Ferretería Nudo, orders 130 and 55; key above)
- Answer: (a) the wait not written ✗ (key: `order_status` ORDER_BACKORDERED on sales order
  130's line 2, order null, 5 Nov); the link as "the purchase line has a link to the sales
  order; the purchase line owns the link" ✗: it is its own row in `order_item_association`,
  pointing at both lines (sales order 130 line 2 → purchase order 55 line 1), owned by
  neither, many to many. (b) no quantity on the link, "only a pointer" ✓; where the 10 lives
  (the sales line's own quantity, the 15 go to stock) not said.
- The user asked why the association came back when its row was at 4: the recall targeted
  the wait on the line (10-31 put a backorder on the order), and the link rode along to check
  it hadn't decayed. The answer took it as an association question and skipped the wait.
- Blame: about 80/20 the user's; "the rows that record the wait and the link" named both,
  but bundling a fresh target with a familiar one invited the skip.
- Score: status row stays 3 (the fix-the-copy part at 4 in Q2, the wait on the line missed
  here); item association 4 → 3 (the link pointed at the order and owned by the purchase
  line). Next: a line-level backorder cold, the association as its own row between two lines.

### 2026-11-02: round Q4, Submodel 1 gap (scoped roles; Muebles Encina, sales order 140; key above)
- Answer: on the order PLACED_BY Gestoría Prado ✓, TAKEN_BY Muebles Encina ✓ (cold, after two
  rounds missing it, and Tomás kept off it despite "takes the call"), SALESPERSON Tomás 100 ✓,
  BILL_TO Gestoría Prado ✓; Laura as ENTERED_BY ✗ (that's whoever keys it in on our side; she
  is the placer's contact). Line 1 SHIP_TO Gestoría Prado with Calle Sauce 4 as a SHIPPING
  `order_item_contact_mechanism` ✓ (the 11-01 place-as-party slip fixed), INSTALLER Montajes
  Río ✓, END_USER Gestoría Prado ✓ ("sensing a division": the branch could be its own
  organization if the gestoría's units are tracked; the question gave none). Line 2 SHIP_TO
  Gestoría Prado ✗ and END_USER Gestoría Prado ✗: Laura receives it and uses it, so both are
  Laura, a person; the gestoría only pays (BILL_TO on the order).
- Blame: the user's; "delivered to Laura's home ... she uses it" named her twice.
- Score: scoped roles stays 3. Both 11-01 targets met cold (TAKEN_BY, END_USER on every
  line); the line roles defaulted to the payer on line 2, and ENTERED_BY misused. Next: a
  line whose receiver and user aren't the customer organization; ENTERED_BY vs the placer's
  contact.

### 2026-11-02: round Q5, Submodel 2 gap (amount or percentage, the base and its why; Floristería Alba, sales order 150; key above)
- Answer: (a) line 1 DISCOUNT amount 40 (20 × €2, the total, not per unit) ✓; the order
  DISCOUNT percentage 10 ✓; the order SHIPPING_AND_HANDLING amount 12 ✓. (b) 10% of 340 = 34 ✓,
  total 300 + 40 − 40 − 34 + 12 = 278 ✓. (c) every adjustment is taken from the source
  values, because nothing records an order of application between them ✓, cold.
- Score: amount or percentage 3 → 4 (the base, the total as the amount and the why, all cold
  in a later session, unhinted).

### 2026-11-03: round Q1, Submodel 3 retest (term or adjustment; Pastelería Nube, purchase order 210)
- Asked live. Line 1 500 cake boxes, line 2 200 rolls of ribbon; (a) the boxes within 5
  days, (b) 10% off the ribbon if it arrives late, (c) 2% off the whole order, regular
  customer.
- Answer: (a) a term on the boxes line, the days read from the type's name, value 5 ✓.
  (b) a term on the ribbon line, the percent read from the type, value 10, "an agreement
  applied somewhere else if true" ✓ (the triggered money lands later, on the invoice).
  (c) an `order_adjustment` DISCOUNT on the order, 2 in the percentage column, taken from
  the order's total ✓.
- Both 11-02 slips fixed cold: the conditional penalty as a term, and the line the wording
  names.
- Score: term row 3 → 4.

### 2026-11-03: round Q2, Submodel 3 retest (status on the order and the line; Tienda Coral, sales order 220)
- Asked live. Line 1 6 desk lamps, line 2 4 office chairs; approved Monday, lamps shipped
  Tuesday, chairs out of stock until they ship the next Tuesday.
- Answer: (a) APPROVED on the order (Monday), SHIPPED on the lamps line and BACKORDERED on
  the chairs line (Tuesday) ✓. (b) a new SHIPPED row on the chairs line, dated the
  shipment's day; earlier rows kept, never updated ✓. (c) the latest row is current, the
  rest is history ✓; which wins when the shipments disagree: not answered.
- The 11-02 miss (the wait on the line not written) fixed cold. The skipped half was shown
  cold on 11-02 Q2 (the shipments win, fix the copy), so every part of the row now has a
  cold pass on a later day.
- Score: status row 3 → 4 (the skip noted; a slip on "the fact wins" next time drops it).

### 2026-11-03: round Q3, Submodel 3 retest (item association; Distribuciones Faro, sales orders 230 and 231, purchase order 88)
- Asked live. Sales 230 (Hotel Brisa) line 1 10 kettles, sales 231 (Café Muro) line 1 5
  kettles, both filled by purchase 88 (Hervidores Sur) line 1 15 kettles. (a) the rows,
  (b) how many go to Hotel Brisa and why no quantity, (c) a `purchase_order_id` column on
  the sales order instead.
- Answer: (a) `order_item_association` rows, purchase line to sales line, no quantity ✓
  (a row of its own between two lines: the 11-02 slip fixed), but not counted out (two
  rows: 88/1 to 230/1, 88/1 to 231/1). (b) the link says which, not how many; a quantity
  would mean handling allocation ✓; many-to-many both ways ✓; how Hotel Brisa's 10 is
  known not answered (its own sales line's quantity) ✗. (c) read as a column on the sales
  line: "one purchase line per sales line" ✓ for that reading, but the column was on the
  sales order: it points at an order, not a line, so it can't say which sales line waits
  on which purchase line, and a sales order filled by two purchases can't be written ✗.
- Blame: (c) about 80/20 the user's (the question said "on the sales order"); the misread
  matters because the level is the 11-02 gap.
- Score: association stays 3. Next: the level (line to line, never the order) and the
  how-many read from the sales line.

### 2026-11-03: round Q4, Submodel 1 retest (scoped roles; Clínica Delta, sales order 240)
- Asked live. Andrés (the clinic's office manager) phones it in, Sofía (our clerk) keys
  it, Hugo gets full credit, the clinic pays. Line 1 a reception desk to the clinic, used
  by its front desk; line 2 a chair to Dr. Paula Ríos's home, used by her.
- Answer: (a) PLACED_BY Clínica Delta, TAKEN_BY Oficinas Lux, BILL_TO Clínica Delta,
  ENTERED_BY Sofía, SALESPERSON Hugo 100 ✓ (the 11-02 ENTERED_BY misuse fixed). (b) line 1
  SHIP_TO the clinic ✓, END_USER "front desk" ~ (a party only if the clinic's units are
  tracked as organizations; the question gave none, so the clinic); line 2 SHIP_TO and
  END_USER Dr. Ríos ✓, with SHIPPING postal addresses as `order_item_contact_mechanism`
  rows on each line ✓ (unasked). (c) not answered; Andrés left off the order, which is
  right: the clinic places it, Sofía keys it; he is the clinic's contact, a Ch 2
  relationship, not an order role.
- The 11-02 targets (line roles for a person who isn't the payer, ENTERED_BY vs the
  placer's contact) met cold.
- Score: scoped roles 3 → 4 (the why in (c) unsaid; second skipped last part this round).

### 2026-11-04: round Q1, Submodel 3 retest (item association; Vinos Altamar, sales orders 300 and 301, purchase orders 95 and 96)
- Asked live. Sales order 300 (Restaurante Olivo): line 1 12 Albariño, line 2 6 Rioja.
  Sales order 301 (Hotel Mirador): line 1 18 Albariño. No stock. Purchase order 95 (Bodega
  Rías) line 1 30 Albariño, for both; purchase order 96 (Bodegas Haro) line 1 6 Rioja.
  (a) the association rows, (b) how many of 95's 30 are Mirador's and where it's read,
  (c) a `purchase_order_id` column on the sales order instead.
- Answer: (a) 95/1 → 300/1, 95/1 → 301/1, 96/1 → 300/2, no quantity ✓ cold; called
  "product association rows" (Ch 3's table) and drawn purchase → sales (the book reads
  sales → purchase, "used to fulfill"): slips, no data changes. (b) the link points, it
  doesn't allocate; the question can't be answered; a quantity would need guards when
  either side's quantity changes ✓. (c) can't tell which purchase line fills which sales
  line, and a sale can't point at two purchases ✓ (order 300 needs 95 and 96; not named).
- Claude first graded (b) ✗ ("read 18 off Mirador's sales line"); the user's pushback
  ("you are allocating") was right: that reading assumes 301/1 draws only on 95 and none
  from stock, which the link (used to fulfill, not fully fulfills) doesn't guarantee. Point
  17's outcome says the split isn't recorded. The tracker's retest note (the how-many read
  from the sales line) was Claude's key and contradicted NOTES; the 11-02 and 11-03 "how
  many" misses were the key's fault, not the user's (11-03's order-level miss stands).
- Score: association 3 → 4.

### 2026-11-04: round Q7, maintenance (every price change a typed row; Juguetería Nogal, order 410)
- Asked live. Line 1: two train sets at €45; line 2: a dolls' house at €120. 10% off the
  train sets, €12 delivery for the order, €6 extra for Mallorca, IVA 21% on the order.
  (a) the adjustment rows (Apply), (b) "discount, delivery, surcharge and tax columns on the
  order" (Evaluate).
- Answer: (a) DISCOUNT 10% on line 1 ✓ cold; SHIPPING AND HANDLING €12 on the order ✓;
  SURCHARGE €6 on the order ✓; the tax on the order as a percentage ✓, but written 12 for 21
  ✗ (a slip) and called "tax rate" for SALES TAX ~; signs as − for the discount, + for the
  rest ✓, though the model stores both positive and the sign comes from the type (unsaid ~).
  (b) one column per kind merges two charges of the same kind and loses which is which and
  where it came from ✓; that a column on the order can't hold the train-set discount on one
  line, and that a new kind of charge needs a new column, unsaid ✗.
- Score: every price change a typed row stays 4 ((a) placed the discount on the line
  cold); next time, the line-level break and the new-kind break in (b).

### 2026-11-07: round Q2, Submodel 1 retest (rules beside facts; Vivero Encina, sales order 520)
- Asked in chat, cut short and one part at a time after the user found the phone text too
  long ("contractors only until 31 Dec 2026" in Claude's cut, not "from 1 Jan 2027"; the
  one-bill-to rule dropped). Closed on (a) only (the user's call): (b) the check and its
  date and (c) cardinality in the rule table were not asked.
- Answer: (a) salesperson → employee and salesperson → contractor as two rows ✓ cold, the
  contractor rule ended with a thru date, not deleted ✓ (31 Dec 2026 for the exclusive 1 Jan
  2027, Claude's wording, not counted), bill-to → bill-to customer ✓, approver → null ✓
  (with a "?"); but written as rows of `order_role_type` ~ (the hat list; the rules go in
  `order_role_rule` beside it, agreed at the overview and only built today), no order kind ~.
  Facts: Nuria SALESPERSON ✓, Jardines Ribera BILL_TO ✓, Marcos "as a contractor" ✗ as
  written (the hat is SALESPERSON; CONTRACTOR is his standing role, read by the check), the
  50/50 left out, volunteered as "the split doesn't happen and a data-quality query flags
  Marcos" ~ (the query ✓, but the facts are stored as they happened; the rule only flags).
- Discussion: what `order_role_rule` holds (kind, hat, required standing role or null,
  dates); the order kind because hats are neutral (BILL_TO needs BILL_TO_CUSTOMER on a
  sale, INTERNAL_ORGANIZATION on a purchase); the rule points at a role type, the fact at
  the party, and only the check walks party → party_role. The user had the table built in
  a side session (`claude/order-role-rule-b262b3`, not merged yet).
- Score: rules beside facts stays 3. Next: (b) and (c) cold (facts stored, flagged after
  the fact on the order date; no cardinality in the rule table), the hat vs the standing
  role on a fact row.

### 2026-11-08: round Q2 (b, c), Submodel 1 retest (rules beside facts; Vivero Encina, sales order 520)
- Short, sent on WhatsApp 2026-11-07, answered in chat today. Order 520 on 12 Jan 2027,
  Nuria an employee and Marcos a contractor selling it 50/50; contractors stop being
  salespeople from 1 Jan 2027; one bill-to per order. (b) what gets flagged, by what, when;
  the same order dated 15 Dec 2026 (Analyze). (c) "add a max-per-order column to the rule
  rows" for the one bill-to: right place, why? (Evaluate).
- Key: (b) Marcos (the only salesperson rule in force needs EMPLOYEE, he holds CONTRACTOR),
  flagged by the data-quality check after the fact, nothing blocked; Nuria passes; dated
  15 Dec 2026 it passes, the rule read as of the order's date. (c) no: a rule row says
  which hat and which standing role, not how many; a hat with several rule rows would carry
  several counts that can disagree; cardinality is its own check query with a bad seed row.
  Spoilers in the (a) feedback: grade (b) on the dates and (c) on the why.
- Answer: (b) flagged by a data-quality query (spoiled, not counted); "or a validation rule
  in the backend" ~ (blocking at insert loses the fact as it happened: the order was sold
  50/50, the rule only flags it); Marcos not named as the one flagged, nor why ~. Dated in
  December: not flagged, the rule's time frame covers the order ✓ cold (the date reasoning).
  (c) "that was what I would do" ✗ (the verdict); against it: harder to read ~, only the
  bill-to would use the column ✓ (a type-only nullable column, Q5's cost seen unprompted),
  "no place holds that rule, only a convention" ✓ (nothing says which rows may fill it).
  Missed: several rule rows for one hat, each with its own count, can disagree; where it
  belongs (its own check query).
- Score: rules beside facts stays 3 (the dates cold, but the verdict in (c) went the wrong
  way). Next: cardinality cold (its own check, not a column), flag don't block.
### 2026-11-07: round Q6, Submodel 1 maintenance (the line; Informática Lince, order 530)
- Short version, asked in chat, (a) only (the user tired): two Lince 14 laptops at €1,100,
  both with the 32 GB upgrade (+€150 each), the studio's logo engraved on both lids, a
  one-off job (€20 each). (a) the order lines: product, feature or neither, quantity, unit
  price, ordered for (Apply). The split was cut (both laptops alike).
- Answer: line 1 Lince 14 (product) ×2 at 1,100 ✓, "serial numbers, but one row" ✓; line 2
  the 32 GB upgrade (feature) ×2, ordered for line 1 ✓, its unit price written "32" ~ (a
  slip for 150); line 3 neither ×2 at 20, ordered for line 1 ✓. The feature justified by
  "some labour is needed" ~ (labour is a cost component, D18; it's a feature because the
  customer picks it on the laptop). The user owned up: the question listed "which line it's
  ordered for", and they would have missed it without that (the wording's hint, Claude's).
- Score: the line 4 → 3 (everything else cold, but ordered for no longer recalled unaided,
  by the user's own account). Next: ordered for cold, with no column list in the question.

### 2026-11-08: round Q2, Submodel 1 retest (the line; Floristería Lis, sales order 610)
- Short, both parts in one go (the user's new rule): 20 rose bouquets at €25, the hotel's
  name printed on each bouquet's ribbon, a one-off at €1 each. (a) the order lines (Apply),
  (b) why the ribbon is neither a product nor a feature (Understand). No column list.
- Answer: (a) line 1 the bouquet (product) ×20 ✓, its unit price written 20 ~ (25: a slip);
  line 2 neither product nor feature, the description ✓, ordered for line 1 ✓ cold and
  unprompted (the 11-07 gap); its quantity 1 at €1 ✗ (€1 each on 20 bouquets: ×20 at 1, or
  the line charges €1 instead of €20). (b) not in the catalogue, so only a description,
  and it has to be on the order ✓.
- Score: the line 3 → 4 (ordered for came back cold with no cue, neither and its why
  right); the two numbers are slips, but a line has to multiply out (quantity × unit
  price is what's charged).

### 2026-11-08: round Q6, Submodel 2 maintenance (amount or percentage; Herbolario Salvia, order 620)
- Short, both parts in one go: 3 teas at €8 and a tea set at €46 with €6 off it; on the
  order a €5 delivery and a 10% member discount. (a) the adjustment rows (Apply), (b) the
  total, what the 10% is taken from, and why (Understand).
- Answer: (a) DISCOUNT amount 6 "on the tea line" ✓ (read as the tea set's line; the
  wording could mean the teas); shipping amount 5 on the order ✓; DISCOUNT percentage 10
  on the order ✓. (b) the lines before any adjustment, 24 + 46 = 70 ✓ cold, 10% of 70 = 7
  ✓ (written "70 × .01", a typo), total 62 ✓. The why not given ✗ (each percentage of the
  value before any adjustment, so the result doesn't depend on the order adjustments are
  applied in and none is taken on another); it was the weak part on 10-28 too ("we
  decided").
- Score: amount or percentage 4 → 3 (the numbers and the base cold, but the why, asked,
  missing again). Next: the why cold.

### 2026-11-10: round Q4, Submodel 1 retest (rules beside facts; Imprenta Sol, order 640)
- Short, live, both parts in one go: rule "exactly one bill-to per sales order"; order 640
  keyed with two, Café Luna and its parent Grupo Luna. (a) where the rule lives and what
  it does about 640 (Analyze), (b) block the insert: what each way gives and costs
  (Evaluate).
- Answer: (a) the rule tables hold the allowed hats (order and item), with no count, so
  any number of bill-tos fits ✓ cold (the rule table says which, not how many). Then a
  menu, no pick ✗: a data-quality query ✓, "add the column" ✗ (the 11-08 verdict: several
  dated rule rows per hat would carry counts that disagree), or app validation; and "a
  future solution, not something we have" ✗ (4.5's check, more than one row for a job the
  columns held once, already counts per order and role type). What it does about 640 not
  said ✗ (flags it after the fact, both rows stay stored). (b) blocking gives clean data
  from then on ✓; its costs not given ✗ (needs a trigger or app code, can't keep the order
  while someone sorts out who pays, a changed dated rule would block rows legal on their
  date); flagging's side not given ✗.
- Score: rules beside facts stays 3 (no count in the rule table cold, but the column
  still on the menu, no flag, and (b) one-sided). Next: pick the check query and say why
  not the column; what a flag does to the facts; both sides of block vs flag.

### 2026-11-10: round Q5, Submodel 2 retest (amount or percentage; Joyería Plata, order 650)
- Short, live, both parts in one go: a ring at €120 and two chains at €30, 10% off the
  ring; on the order 5% off for cash and a €10 gift wrap. (a) the adjustment rows (Apply),
  (b) what the 5% is taken from, and why (Understand).
- Answer: (a) DISCOUNT percentage 10 on line 1 ✓; DISCOUNT percentage 5 on the order ✓;
  FEE (or MISCELLANEOUS_CHARGE) amount 10 on the order ✓. All cold. (b) the total before
  any discount is applied ✓ (said "discount", where the key says any adjustment: the gift
  wrap stays out of the base too ~). Why: nothing records the order adjustments are
  applied in, so a base taken after another adjustment would need an extra sequencing
  column on the types ✓ cold (the why, missed on 10-28 and 11-08, now in the user's own
  framing: the result doesn't depend on the order of application). Not said: none is
  taken on another.
- Score: amount or percentage 3 → 4 (rows and base cold, the why given unprompted).

### 2026-11-10: question round, pending (written for the phone, short; wording in `docs/round-2026-11-10.md`; order in TODO)
- **Q7 · Submodel 1 maintenance (contact mechanisms on the order and the line, last 4 on
  11-01) · (a) Apply, (b) Analyze.** Café Norte, order 660. Key (a):
  `order_contact_mechanism`: compras@hotelalba.es ORDER_PLACING, Calle Mayor 5 BILLING
  (our own ORDER_TAKING not given, ✓ if added). `order_item_contact_mechanism`: line 1
  Calle Sur 2 SHIPPING; line 2 Paseo 8 SHIPPING, 600 111 222 DELIVERY_CONTACT. (b) only
  line 1's SHIPPING row changes: it now points at Calle Sur 4 (a new contact mechanism,
  also linked to the hotel's party ✓). Unchanged: line 2, the order's rows, and the old
  address's own row (other orders and the party may still use it). Full version adds (c)
  the order records where *this* order goes; a party has many addresses, several with the
  same purpose, and they change over time, so the order can't be read back from the party.
