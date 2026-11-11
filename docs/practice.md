# Practice: one submodel at a time

How the user practises once the reading for a submodel is done. Read this when practice starts
or resumes, not every session.

## Aim
- **Conceptual understanding at a high level.** Implementation depth comes later (the core app).
- **What "understood" means**, for every concept: the user can (a) say what the table or
  pattern is **for**, meaning the problem it solves and what the naive design gets wrong;
  (b) say how it **relates** to its neighbours, conceptually rather than column by column; and
  (c) **spot a wrong implementation** of it and say what data it would lose or corrupt.
  Attribute lists, syntax and exact cardinalities are out of scope. Going deeper risks
  overlearning; a concept can be revisited later (question rounds, the core app, later chapters).
- **Patterns over tables.** Every submodel is practised through the patterns it uses (see Core
  patterns in the design reference doc). At least one question per submodel asks which pattern
  is at work, or which entity owns a fact.

## Time budget
- **About 3 hours per submodel**, split roughly: exam 45 min · reinforce 1 h 15 min · practice
  scenario 45 min · finishing the doc entry 15 min.
- Go over only when a gap still needs reinforcing; say so and agree before continuing.
- Don't build more exercises than fit the budget. Unused menu items are fine to leave undone.

## Submodels
A submodel is a group of figures that answer one set of business questions (e.g. Ch 2:
parties/roles/relationships · contact mechanisms, facilities and geography · communication
events and case). Agree the split at the start of a chapter's practice and list it at the top
of the chapter's `EXERCISES.md`.

## Files
- **`EXERCISES.md`**: the working file. At the top: the submodel list, the **comprehension
  tracker** (rows grouped by submodel) and **open threads**. Below: section 0 "To ponder"
  (at most 5 per submodel) and the format menu (sections 1–9). Answered items keep their
  question and a one-line pointer to the log.
- **`EXERCISES-log.md`**: the history. Answers by item number and the dated **gaps log**.
  Append here; read it only when a row's evidence is needed.
- At session start, read the tracker and open threads only (grep for the headings), not the
  whole file.

## Steps (per submodel)
- **0. Tracker rows.** One row per concept (a pattern or a small group of tables that make
  sense together), listing the `schema.sql` tables it covers so every table belongs to some row.
  Aim for 3–6 rows per submodel, all starting at 0. Don't test anything that isn't in a row.
- **1. Exam: one question at a time, climbing Bloom's levels.** About 6 questions, roughly one
  per level, stopping to reinforce when a level is shaky:

  | Level | Question type |
  |---|---|
  | Remember | Name the entities or subtypes involved |
  | Understand | Why is it shaped this way? What does the naive design get wrong? |
  | Apply | Model a concrete business scenario (rows, not a full schema) |
  | Analyze | Which entity owns this fact? Which pattern is this? |
  | Evaluate | Find and explain the flaw in a proposed model |
  | Create | Sketch a minimal model for a new problem |

  Record answers in `EXERCISES-log.md`.
- **2. Reinforce (close the gaps).** Any row below 3 is a gap. Explain it **through the
  chapter's own schema** (its tables and seed rows, and why each exists), then ask a fresh
  question in a new setting with no hints. If it falls short, log it, explain from a different
  angle, and ask again. Before closing a row, ask one short **neighbourhood question**: which
  entities does it connect to, and what does each connection mean? A row is closed when the
  evidence reaches 3, the neighbourhood is answered, **and** the user agrees. Use cheap formats:
  a sketch on paper, or Claude runs SQL and the user predicts the result. No full schema
  rewrites.
- **3. Practice scenario (Create).** One small new-domain problem for this submodel, modelled
  on paper: the minimal entities, what was borrowed from the book and what was left out on
  purpose. This is where scores of 4 come from.
- **4. Finish the doc entry (`/close-submodel`).** The draft exists since the reading (five sections, see
  `CLAUDE.md`). Add the pitfalls from the user's mistakes and the scenario, fix what practice
  proved wrong, drop the Draft mark and mark it Done on the roadmap. Swap the card's
  Trap for one of the user's real mistakes.
- **Submodel done when:** every row scores 3+, the scenario holds up, and the doc entry is
  written. **Chapter done when** all its submodels are done; then tick it in `TODO.md`.

## Reviewing and scoring
- **Don't include answers.** Review attempts like a pull request: say what's wrong, then ask a
  guiding question before giving the fix. Explain the book's reasoning before any pragmatic
  critique, and check the schema before claiming how the model works.
- Log every misunderstanding in `EXERCISES-log.md` and keep the tracker current. Score each
  concept on the **0–4 evidence scale**, citing the answer behind each score: 0 untested ·
  1 recognises (understood once explained, or picked from options) · 2 explains with help ·
  3 explains unprompted · 4 applies cold (new setting, later session, no hints). Score strictly
  from evidence, not impressions. A gap that reappears lowers its row.
- **Data explorer (`npm run explore`):** keep it closed for the exam and gap checks, and open
  for learning and for checking an answer *after* giving it from memory. An answer found with
  the explorer open scores 2 at most ("with help").
- **The design reference doc, too:** its drafts now exist before practice and answer some of
  the ponders, so the same rule applies. Keep it closed for the exam and gap checks.
- **The question round of seven** (one per session, across finished and in-practice
  submodels of all chapters): 5 gaps and retests (rows below 4 and the last session's
  misses, a reinforce when a gap needs teaching), then 2 maintenance questions. No recalls
  (the user's call, 2026-11-03): no session-start questions and nothing between rounds.
  One question at a time, each naming its Bloom level.
- **Two versions of each question, short by default for now** (the user's call,
  2026-11-07): the full version is the usual scenario with three parts (about 30 minutes
  of writing on the phone). The short one must fit **15 minutes including the feedback**:
  a scenario cut to the facts its key tests, and **two parts, each with a small answer**
  (the user's call, 2026-11-08): two or three rows, e.g. two hats on the order and two on
  the lines, not the whole set a mnemonic lists. **Give all of a question's parts in one go**
  (the user's call, 2026-11-08), so feedback on one part can't steer the answers to the
  next; grade them together once the user says they're done. Keep the concept and the
  Bloom levels the row needs; the short version drops volume, not the test. Write both
  into the round file when the round is written; give the short one unless the user asks
  for the full. Don't list the columns to fill when one of them is what's tested ("which
  line it's ordered for" gave ordered for away, 2026-11-07). When a cut changes a convention's cue (e.g. "until 31 Dec" for an
  exclusive thru date), don't count the result against the user.
- **Show the whole round in chat once it is written** (the user's call, 2026-11-11): the
  closing message gives all seven short questions, WhatsApp-ready (the text between the lines
  in the round file, `*bold*` kept), so the user can copy them to the phone and answer
  offline. Grading still takes one question at a time, as the answers come back.
- **Maintenance in question rounds** (the user's call, 2026-10-29): the round's 2
  maintenance questions go to rows already at 4, picked across chapters by the oldest
  evidence date in the comprehension tables, each in a fresh scenario. A slip drops the row
  to 3 and back into the gap pool; a pass adds the new date, which pushes its next check
  further out. The other 5 stay on gaps and retests.
- **Spread a round's scope** (the user's call, 2026-11-02): prefer questions on different
  rows and topics, but it isn't required. When two questions share a row, the discussion of
  the first means the second can't count as cold, so that row can't reach 4 this round; the
  user accepts that.
- **Distinctions after each round** (the user's call, 2026-11-02): once a round is graded,
  review its mistakes and suggest distinction cards (`docs/cards.md`, *Deck: distinctions*)
  for the mix-ups between two known options. Don't repeat a concept: when a card already
  covers it, add the mistake to that card's Trap instead. Slips that aren't a choice (a
  typo, a skipped part) get no card.
