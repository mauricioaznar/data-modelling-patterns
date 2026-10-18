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

**To check against the book**
- No arc drawn across the two "for" lines (product, feature). Read as Silverston's intention
  all the same: an item names a product *or* a feature, and a feature's item is "ordered for"
  the product's item. An item may name neither when its description says what it is (a
  one-off). Points to discuss, point 2.
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

### Points to discuss after the overview (Figs 4.1–4.3)
The readings below stand, and the SQL follows them. We look at each once the chapter
overview comes. Any refactor waits until then and aims at what Silverston intended, not at
the literal drawing. The list moves under the chapter's last figure when that one arrives.

1. **4.1, not built:** read as the book's straw man, which 4.2 replaces, so it gets no SQL
   (STATUS.md lists it as not built). If you'd rather see its failures in data, as with Fig
   2.2a's `person_flat`, we build it at the overview.
2. **4.2, product or feature:** no arc is drawn, yet read as "an item names a product or a
   feature, not both; a feature's item is ordered for a product's item, on the same order,
   and the feature must apply to that product; an item with neither carries a description".
   Built as data-quality queries, not constraints, so the reading is easy to change.

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
  (`sales_order_item`); PURCHASE ORDER ITEM has none and gets no table. A data-quality query
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
  the order keeps what was agreed.

## When NOT to use this
<!-- Filled as the figures land. -->

## Open questions
