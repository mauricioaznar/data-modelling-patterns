# Practice: end of a chapter

How the user practises once a chapter's last figure is built. Read this when a chapter's
practice starts or resumes, not every session.

## Aim
- **Conceptual understanding at a high level.** Implementation depth comes later (mini apps).
  Don't build more exercises than will actually be done.
- **What "understood" means**, for every concept: the user can (a) say what the table or
  pattern is **for**, meaning the problem it solves and what the naive design gets wrong;
  (b) say how it **relates** to its neighbours, conceptually rather than column by column; and
  (c) **spot a wrong implementation** of it and say what data it would lose or corrupt.
  Attribute lists, syntax and exact cardinalities are out of scope. Going deeper risks
  overlearning; a concept can be revisited later (recall questions, mini apps, later chapters).

## Files
- **`EXERCISES.md`**: the working file. At the top: the plan, the **comprehension tracker**
  and **open threads**. Below: the exercise menu (section 0 "To ponder", sections 1–9).
  Answered items keep their question and a one-line pointer to the log.
- **`EXERCISES-log.md`**: the history. Answers to section 0 items (by item number) and the
  dated **gaps log**. Append here; read it only when a row's evidence is needed.
- At session start, read the tracker and open threads only (grep for the headings), not the
  whole file.

## Steps
- **0. Build the concept tracker** as soon as the chapter's last figure is built, before the
  exam: one row per concept, covering every figure. A concept is a pattern or a small group of
  tables that make sense together (e.g. "PARTY RELATIONSHIP + TYPE"), not a single table. Each
  row lists the `schema.sql` tables it covers, so every table belongs to some row and
  understanding stays tied to how the schema was built. Aim for roughly 10–20 rows, all
  starting at 0. This table fixes the chapter's scope: don't test anything that isn't in it,
  and add a row only when a real gap shows it's missing. Then pick the exam questions so each
  main row gets at least one.
- **1. Exam (find the gaps).** Ask about 12 questions in chat, one at a time, covering every
  figure's main idea: what problem it solves and what the naive design gets wrong. Record
  answers in `EXERCISES-log.md`.
- **2. Reinforce (close the gaps).** Any row below 3 is a gap. Work through it in a loop:
  explain it **through the chapter's own schema** (open its tables and seed rows, and say why
  each table exists and why it's shaped that way), then ask a fresh question in a new setting
  with no hints. If the answer falls short, log it, explain again from a different angle, and
  ask another fresh question. Before closing a row, ask one short **neighbourhood question**:
  which entities does this concept connect to, and what does each connection mean? Only its
  sub-group of entities counts, not the whole chapter. A table rarely means anything on its own
  (a contact mechanism matters through the parties linked to it). A row is closed only when
  the evidence reaches 3, the neighbourhood is answered, **and** the user agrees they
  understand it; either of us can reopen it. Use cheap formats: a quick sketch on paper, or
  Claude runs SQL and the user predicts the result. Write SQL by hand only when the concept
  lives in the query (e.g. as-of dates). No full schema rewrites; syntax errors don't teach
  modelling.
- **3. Capstone.** One small new-domain problem, modelled on paper and compared with the book.
- **Done when:** every main concept scores 3+, the capstone holds up, and no logged gap
  reappears when tested cold. Only then tick the chapter in `TODO.md`.

## Reviewing and scoring
- **Don't include answers.** Review attempts like a pull request: say what's wrong, then ask a
  guiding question before giving the fix. Explain the book's reasoning before any pragmatic
  critique, and check the schema before claiming how the model works.
- Log every misunderstanding in `EXERCISES-log.md` and keep the tracker current. Score each
  concept on the **0–4 evidence scale**, citing the answer behind each score: 0 untested ·
  1 recognises (understood once explained, or picked from options) · 2 explains with help ·
  3 explains unprompted · 4 applies cold (new setting, later session, no hints). Target before
  moving on: 3+ on every main concept, with 4 coming from the capstone. Score strictly from
  evidence, not impressions. A gap that reappears lowers its row.
- **Data explorer (`npm run explore`):** keep it closed for the exam and gap checks, and open
  for learning and for checking an answer *after* giving it from memory. An answer found with
  the explorer open scores 2 at most ("with help").
- **Next session start:** open with 3 quick recall questions on the most recently finished
  chapter, favouring its open gaps.
