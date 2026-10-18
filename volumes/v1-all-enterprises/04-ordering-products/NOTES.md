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
1. **Orders, items and order parties** (Figs 4.1–4.3): what was ordered, in which direction
   (sales or purchase), at what price, and who placed, took, pays for and receives it?

More submodels follow as the rest of the chapter's figures arrive. If the next figures
answer the same questions (the purchase side's parties, say), they join submodel 1 and its
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

### Points to discuss after the overview (Figs 4.1–4.3)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing. The list moves under the chapter's last figure when that one arrives.

1. **4.1, not built:** read as the book's straw man, which 4.2 replaces, so it gets no SQL
   (STATUS.md lists it as not built). If you'd rather see its failures in data, as with Fig
   2.2a's `person_flat`, we build it at the overview.

## Design decisions (book → SQL)

### Fig 4.1 (not built)
- **Not built,** as with an alternate figure: Fig 4.2 replaces it, and building it would add
  six tables (two orders, two line items, customer, supplier) that the next figure throws
  away. The contrast lives in the transcription above and in a 4.2 query that answers "every
  order for the pen, both directions" from one table. Unlike Fig 2.2a's flat person (built as
  `person_flat`), 4.1 has almost no attributes, so its seed would show little. Points to
  discuss, point 1.

## When NOT to use this
<!-- Filled as the figures land. -->

## Open questions
