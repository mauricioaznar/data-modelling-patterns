---
name: overview
description: Fixed procedure for a chapter's overview, once all its figures are built and drafted. Discusses the points one at a time, collects feedback on the doc drafts and cards, refactors, runs the card pass, then hands over to practice.
argument-hint: vN/NN
---

# /overview: feedback, refactor, card pass

## 0. Preconditions
- `npm run check -- vN/NN` shows no ✗, every figure is classified, and every submodel row
  and the `A` row have `Doc draft` ticked. If not, finish `/figures` first and say so.

## 1. Points to discuss, one at a time
- Read the "Points to discuss after the overview" lists in NOTES.md. Take one point per
  message: explain the reading and its alternative, ask one question, wait for the answer.
  The book is the source of truth: ask for a photo when one would settle it. Hold a position
  under pushback unless the evidence changes.
- Record each outcome under its point: kept or changed, and why.

## 2. Drafts and cards
- Per submodel, ask for feedback on its doc draft and its card: does the mantra explode, does
  the hook stick? When the user rewrites a mantra, check it still unpacks into the key.

## 3. Refactor
- Apply what changed: NOTES, SQL (one commit per figure touched, after
  `npm run db:rebuild && npm run queries -- vN/NN`), the doc entries and the cards. Aim at
  Silverston's intention, not the literal drawing.

## 4. Card pass
- Every submodel has its card. Every pattern new to Core patterns gets a pattern card in
  `docs/cards.md` (P-numbers continue). `npm run cards:anki`, then remind the user to
  re-import.

## 5. Close
- Tick `Overview` with today's date for every submodel row and the `A` row. TODO.md and
  CHANGELOG.md.
- `npm run check -- vN/NN` until no ✗ is left; commit.
- Report the decision on each point and what was refactored, then agree the practice order
  for the submodels with the user.
