---
name: overview
description: Fixed procedure for a chapter's overview, once all its figures are built and drafted. Discusses the points one at a time (teaching as needed), collects feedback on the doc drafts, refactors, walks through the concepts on the finished model, then reviews the cards last, runs the card pass and hands over to practice.
argument-hint: vN/NN
---

# /overview: points, concepts, doc, refactor, cards

Order (the user's call, 2026-10-29): doubts first, then the doc, then the refactor, so the
concepts are learnt from the finished doc; the cards come last, so the explode test runs on
understood concepts and on the final card.

## 0. Preconditions
- `npm run check -- vN/NN` shows no ✗, every figure is classified, and every submodel row
  and the `A` row have `Doc draft` ticked. If not, finish `/figures` first and say so.

## 1. Points to discuss, one at a time
- Read the "Points to discuss after the overview" lists in NOTES.md. Take one point per
  message: explain the reading and its alternative, ask one question, wait for the answer.
  The points come first even when the concepts behind them aren't in place yet: teach
  whatever the point needs (the problem, a few rows, the tables) inside the discussion.
  The book is the source of truth: ask for a photo when one would settle it. Hold a position
  under pushback unless the evidence changes.
- Record each outcome under its point: kept or changed, and why, with the alternative
  and when it would win. Note any concept cleared up on the way.
- Once a point is agreed, note under its outcome any card it touches (submodel and
  architecture); the fix waits for the refactor, the check for §5.

## 2. Doc drafts
- Per submodel, and then for the architecture entry, ask for feedback on its doc draft:
  the agreed outcomes and their whys, anything that reads wrong.

## 3. Refactor
- Apply what changed: NOTES, SQL (one commit per figure touched, after
  `npm run db:rebuild && npm run queries -- vN/NN`), the doc entries and the cards' fixes
  noted in §1. Aim at Silverston's intention, not the literal drawing.

## 4. Concepts walk-through (per submodel, ungraded)
- On the refactored model and the finished doc entry, walk each submodel through at the
  Understand level: the problem it solves, the core entities with a few rows, how they
  connect, and where it plugs into
  earlier chapters. About 20 minutes; skip what the points already taught.
- Tell and check ("does this click?"); no scores and no exam questions: finding the gaps
  is practice's job. A misunderstanding found here goes into NOTES, under the figure's
  Discussion (and the doc entry, if it changes what the entry says), and becomes a
  candidate Trap for the card.

## 5. Card review (last)
- Per submodel card, then the architecture card: the explode test (the user unpacks the
  mantra into the key without looking) and does the hook stick? When the user rewrites a
  mantra, check it still unpacks into the key.
- Every submodel has its card, and the chapter has its architecture card (rewritten if the
  refactor changed "How it flows"). Every pattern new to Core patterns gets a pattern card in
  `docs/cards.md` (P-numbers continue).
- Run the card-vs-NOTES check from `/close-submodel` §2 on every card of the chapter, the
  architecture card included, against NOTES as the refactor left it.
- The export waits for §6: it reads the `Overview` tick.

## 6. Close
- Tick `Overview` with today's date for every submodel row and the `A` row. This settles the
  chapter's cards (the user's call, 2026-10-18): run `npm run cards:anki`, and the export
  turns them from draft to reviewed and puts them in the Settled subdecks.
- Remind the user to re-import, then to move the chapter's cards out of Drafts by hand,
  since Anki won't move existing cards: Browse, search
  `"deck:Data Models::Submodels::Drafts" tag:vN::chNN`, select all, Change Deck to
  *Data Models::Submodels::Settled*; then the same for *Architecture*. Give the exact
  searches with the chapter's tag filled in.
- TODO.md and CHANGELOG.md.
- `npm run check -- vN/NN` until no ✗ is left; commit.
- Report the decision on each point, what was refactored and each card fix the
  card-vs-NOTES checks made (or that there were none), then agree the practice order
  for the submodels with the user.
