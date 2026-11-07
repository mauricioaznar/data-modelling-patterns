# Comparisons: other models against Silverston

Real-world models held up against what this repo built from the book. Each one gets its own
folder, numbered in arrival order:

| # | Model | Folder | Status |
|---|---|---|---|
| 01 | Vendor Price Catalog (field-services vendor prices) | [01-vendor-price-catalog](01-vendor-price-catalog/) | Comparison drafted 2026-11-05; exercises next |

## Rules (the user's call, 2026-11-05)

- **Silverston stays pure.** Nothing from here goes into a chapter's NOTES, SQL, EXERCISES,
  cards or the design reference doc. The arrows point one way only: a comparison cites the
  chapters, and the chapters never mention a comparison.
- **The repo is the only Silverston source.** Cite the file and line where the repo defines an
  entity. When the book has something the repo doesn't, say "not in this repo"; never fill it
  in from memory (MAP.md's `~` lines don't count).
- **The other model's description is the only truth about it.** Keep its PROPOSED items apart.
- **Each folder holds:** `SOURCE.md` (the other model, as given), `COMPARISON.md` (inventory,
  mapping, structural differences, gaps both ways, open questions) and `EXERCISES.md`
  (Analyze and Evaluate practice on the comparison, scored on `docs/practice.md`'s scale but
  kept out of the chapters' trackers).
