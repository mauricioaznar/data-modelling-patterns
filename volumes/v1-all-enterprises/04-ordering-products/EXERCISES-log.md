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

## Gaps log
- 2026-10-23, Q1: who vs where on a line. Gave the ship-to address, not the ship-to party
  (`order_item_role`). Same gap as card 10's S. Reinforce.
- 2026-10-23, florist: line-level ship-to right after a nudge; missed the placer and the
  billing address (where follows the bill-to hat to the order), and named no purposes.
Misunderstandings and reinforce attempts, oldest first.
