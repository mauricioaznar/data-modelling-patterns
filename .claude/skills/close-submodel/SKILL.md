---
name: close-submodel
description: Fixed procedure for ending a submodel's practice. Checks it's really done, finishes its design reference entry (pitfalls, scenario), swaps the card's trap for a real mistake, checks the card against NOTES, ticks STATUS.md and closes out.
argument-hint: vN/NN <submodel #>
---

# /close-submodel: finish what practice proved

## 0. Preconditions (`docs/practice.md`)
- Every tracker row of the submodel in EXERCISES.md scores 3 or more, each close agreed by
  the user, and the practice scenario holds up. If not, stop: list what's missing and offer
  the next exercise instead.

## 1. Finish the doc entry
- **Pitfalls:** the user's own mistakes, from the gaps log in EXERCISES-log.md, not generic
  ones.
- **Practice scenario:** the user's model, what it borrowed and what it left out on purpose.
- Fix whatever practice proved wrong in the five drafted sections. Drop the *Draft
  (assumptions)* mark, set the roadmap to *Done* and settle the question index.
- Patterns first: new Core patterns rows or examples that practice turned up.

## 2. The card
- Swap the Trap for one of the user's real mistakes from the gaps log, and update the key if
  practice changed it.
- **Check the card against NOTES.md**, the submodel's figures (transcriptions, readings,
  "Design decisions (book → SQL)"). The overview and practice change NOTES, and nothing
  carries those changes to the card by itself:
  - **S:** every entity is in NOTES under the name the SQL uses, with the job NOTES gives
    it; nothing NOTES treats as a core entity is missing.
  - **D:** every line is a relationship in the transcription, pointing the same way, with the
    same arc or optionality; a not-built alternate is named as not built.
  - **W and T:** nothing contradicts NOTES or a recorded decision.
  - **Mantra:** every S entity still falls out of it.
  - If the submodel is the chapter's last, check the architecture card against "How it
    flows" the same way.
  - A mismatch: NOTES wins and the card is fixed. If practice proved NOTES wrong instead, say
    so, fix NOTES with the user (and the SQL, one commit per figure), then the card.

## 3. Close out
- STATUS.md: tick `Practice` and `Doc done` with today's date. Then `npm run cards:anki`
  (the `Doc done` tick turns the card's tag to `dm::status::done`; it stays in Settled), and
  remind the user to re-import.
- TODO.md: tick the submodel. If it was the chapter's last, tick the chapter and update the
  README progress table. CHANGELOG.md.
- `npm run check -- vN/NN` until no ✗ is left; commit.

## 4. Report
- What the entry gained, the trap now on the card, each card-vs-NOTES mismatch and how it
  was settled (or that there were none), and what comes next: the next submodel,
  or the mini app once three chapters are done.
