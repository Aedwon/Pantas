# Question generator: decision log

Policy read from `origin/main` at 0edf1dcf6 (`AGENTS.md`, `WORKFLOW.md`,
`docs/workflow/process-improvement.md`). Branch: `spec/question-generator`.
Lead: Claude Fable 5.2, talking with Aedwon directly. Estimate row: E-103.

Status: decision session open. Nothing is approved for build. No spec yet.

## His goal, in his words (the success test)

- October 4, 2026 (`2026-10-04-tiered-pricing-log.md`, recorded as a decision, exact
  words not in the log): the abstract reasoning procedural generation engine is a
  release requirement for the academy exams and PSHS-NCE.
- October 25, 2026 (`2026-10-19-pwa-launch-log.md:1562`): "fixed counts remain 20
  minimum. near-duplicates are okay for launch, we will build a parameterized
  question generation engine later on but this is for another conversation"
- November 17, 2026 (`backlog.md`): "what about the question generation engine? why
  wasn't that surfaced. i'm worried we're missing items"

The success test is not yet confirmed by him in this session. Question 1 below asks
for it.

## November 17, 2026: opening brief

Facts checked on `origin/main` before the brief:

- `docs/pricing.md` gates PSHS-NCE, PMA, PNPA, PMMA and MAAP on the generator. PNPA
  coverage of abstract reasoning is not confirmed from an official source.
- Those five exams have no tagged content (`next-exam-brief.md`, table). PSHS-NCE
  also needs the under-13 parent and child consent work. The generator alone puts
  nothing on sale.
- Dates: PSHS-NCE tests January 30, 2027 (official). PMA, PNPA, PMMA and MAAP have
  no 2027 dates; PMA ran July to September in 2026.
- Abstract reasoning today: 5 question sets of 20 (figure series, figure matrices,
  figure grouping, paper folding, mental rotation), tagged for ACET, USTET,
  DOST-SEI and CSE Professional. Each question already stores its figure as data
  (`figureSpec`), and the app draws it. Answer choices are text descriptions, for
  example "Line pointing lower-right", not figures.
- The October 25 ruling lets near-duplicates stand until the generator exists
  (`question-style-guide.md:248`).
- An earlier out-of-scope note names a "templated math engine" for parameterized
  math questions (`2026-07-20-static-question-pipeline-design.md:245`). It was
  never designed.

Design choices put to him:

1. Scope: abstract reasoning only, or also number-based questions for CSE math and
   reasoning.
2. Where questions are made: pre-made pools that are checked before release, or
   live generation inside the app.
3. Answer choices: figures, as on the real exams, or text, as today. Figure choices
   are a UI change, so Claude workers build them and he approves boards first.

Costs given (rough, before design): 4 to 6 days of build for abstract reasoning
with pre-made pools. Audit: a script proves each generated question has exactly one
correct answer, Codex audits each template, and he checks figures by eye. Usage:
mostly Codex; figure choices need Claude workers.

Recommendation given: settle the design now, build after the beta ends on
November 22. Reasons: no gated exam can go on sale before mid-2027, his Claude
usage is tight this week, and only 1 of 19 testers has studied, so the beta gives
no evidence on repeats yet.

Question 1 asked: is the goal met when a student never sees a repeat in normal
study (large pre-made pools), or must the app make each question new on the spot?

Aedwon's answer, exact words: "it would be ideal if a student never re-encounters the same set of figures for a given problem type, if that makes sense. i think in some other brainstorming session about this i mentioned perhaps we need a sort of system that tags whether a question has already been seen by a user and the system must make sure that it does not serve that question again. this make sense so far?"

## November 17, 2026: success test, first form

Success test, in his words: "a student never re-encounters the same set of figures
for a given problem type".

What the lead took from it:

- A repeat is judged by the figures, not by the question id. Two questions with the
  same figures count as one. The generator must compare figure content and drop
  duplicates.
- He described this as "ideal", so whether the rule is strict or "nearly never" is
  still open. Question 2 asks.

Facts checked:

- The earlier brainstorming session he mentions was not found on `origin/main` (a
  search of `docs/` for seen-question wording). Its record is missing, so this entry
  is the first record of the seen-question idea.
- The app already records which questions each student has answered and serves
  unseen questions first (adaptive roadmap engine plan, Task 6; practice picker
  plan). Not re-read on the current code branch in this session; the spec must
  confirm it there.
- Today a seen question returns in review. Whether a figure question should return
  as itself or as a new question of the same pattern is a study-method question.
  `WORKFLOW.md` says evidence decides it, not preference. The lead will research it
  before the spec and record the sources.

Options put to him for where questions are made:

A. Large pre-made pools (recommended first step). The generator runs before a
   release, a script checks every question, and the app ships, for example, 1,000
   per problem type. The existing seen record keeps repeats away. Cost: 4 to 6 days,
   little app change. Limit: a student who finishes a whole pool sees old questions
   again.
B. Live generation in the app. Strictly never repeats. Cost: roughly 10 to 15 days,
   because review, mistakes, progress, sync and the mock all look questions up in
   the shipped content today and would need changes. Each question is only as
   checked as its template.
C. A now, B later with the same engine, only if real use shows students finish a
   pool.

Recommendation: C.

Question 2 asked: does "nearly never" meet the goal, or must it be strict?

Aedwon's answer, exact words: "okay with your reco

do you recommend being strict with never?"

## November 17, 2026: option C chosen; strictness

Decision: option C. Pre-made pools first; live generation in the app later with
the same engine, only if real use shows students finish a pool. This is a design
choice, not approval to build.

His question: "do you recommend being strict with never?"

Lead's answer: no, not at the start. Reasons given:

- Strict needs live generation (option B), about twice the build, before any gated
  exam can sell.
- Pools can be refilled. The same engine can add another batch of new figures in a
  content update, so a pool can stay ahead of the heaviest student without option B.
- The app can measure how far each student is through each pool. That figure comes
  from the student's own use, so it meets the rule against invented figures.

Rule proposed in place of strict: inside a pool, no figure set returns while an
unseen one remains. If a student finishes a pool, the oldest seen questions return
first. The pool size per problem type is set in the spec. A refill, or option B, is
triggered when real students approach the end of a pool; the spec sets the exact
trigger.

Question 3 asked (scope): abstract reasoning only first, or also number-based
questions for CSE math in the same build. Recommendation: abstract reasoning only.
It is the sale gate and matches his success test, which names figures. Number
questions are a separate set of templates, and the beta has given no evidence yet
that CSE students notice repeats. Cost of adding them now: about 3 to 5 more days
and a second audit.

Aedwon's answer: pending.
