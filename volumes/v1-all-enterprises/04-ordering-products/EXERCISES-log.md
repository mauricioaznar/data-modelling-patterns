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
Misunderstandings and reinforce attempts, oldest first.
