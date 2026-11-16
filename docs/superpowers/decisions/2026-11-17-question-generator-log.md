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

Aedwon's answer, exact words: "let's expand to CSE math (honestly it won't just be CSE math, let's work towards CET and PSHS-NCE math as well). i will have a job start writing the math lessons for these exams"

## November 17, 2026: scope widened to math

Decision: the generator covers abstract reasoning and math. Math means CSE math
first, working toward CET and PSHS-NCE math. He chose this against the lead's
recommendation of abstract reasoning only. He will start a separate job to write
the math lessons; that job is outside this session.

Lead correction: the "3 to 5 more days" given with question 3 covered only the
number engine and a first CSE batch. It does not cover the widened scope. Math
needs one template for each question pattern in each lesson. `origin/main` holds
46 math question sets (44 tagged for the college entrance tests, 12 for CSE, by
the older tags; the live CSE split has more lessons). At about 7 to 10 patterns a
lesson, that is roughly 300 to 450 templates. This is content-scale work, mostly
Codex, and its cost per lesson is unknown until a pilot of 2 or 3 lessons measures
it.

Facts given to him about the lesson job:

- CSE math lessons are final and live.
- The CET math lessons are already rewritten on the paused CET branch
  (`content/cet-finish-r1`; 18 mathematics lessons in the 69 rewritten). They wait
  for the Astra audit, not for writing.
- PSHS-NCE math is the only new writing. No official PSHS-NCE item list was found
  (`next-exam-brief.md`: "Scientific, quantitative, abstract, verbal (2019 news,
  secondary). Items not found"). The lesson guide forbids a claim about a specific
  exam without a source, so that job needs a source first.

Order recommended by the lead, because templates follow finished lessons:

1. The engine and abstract reasoning (its lessons exist; it is the sale gate).
2. CSE math (lessons final; the CSC sitting is March 14, 2027).
3. CET math, after its audit.
4. PSHS-NCE math, after its lessons exist.

Question 4 asked (success test for math): for math, is a repeat "the same problem
with the same numbers"? Under that test a student may meet the same problem type
again with new numbers, as the figure test allows the same problem type with new
figures. The app would space one pattern apart so a student does not get several
in a row. Recommendation: yes. Note for the spec: the question style guide says
variants must differ in more than swapped numbers; that rule was written for
hand-written sets of 20 and needs a stated exception for generated pools.

Aedwon's answer to question 4: pending. He gave an instruction first (next entry).

## November 17, 2026: math lesson work goes to the operations manager

Aedwon's exact words: "can you talk to the Operations Manager thread, have it complete the math things needed for this plan. codex accounts should be available right now, with 2 resets each account so it can exhaust the weekly quota without a problem"

What the lead takes this to approve, and only this:

- The operations manager routes and completes the math lesson work this plan
  depends on: the CET math lessons (finish their audit and fixes on the paused CET
  branch) and the PSHS-NCE math lessons (a source for coverage first, then the
  lessons). CSE math lessons are already final.
- This lifts his November 9 and 10 pause on CET content for the math lessons only.
  Science, reading, reasoning and the figures stay paused.
- Codex does the work through `codex-pick`. He says each account has 2 resets
  available, so the weekly quota may be used up.

Not approved by these words: any generator build, any template writing, any UI,
any change to prices or to what goes on sale. The generator has no spec yet.

Action: the lead sent this brief to the operations manager thread and cited this
entry so the manager can confirm his words before acting.

Routing result (reported by the operations manager, November 17): the manager
confirmed his words at 21d8b44a7 and launched a fresh content lead, thread "Math
lessons for the question generator", on branch `content/math-for-generator-r1` off
`content/cet-finish-r1`. Scope as sent: confirm CSE, finish the CET math audit with
no rewrite, source PSHS-NCE before any writing. The CET pause is lifted for math
only. Codex runs through `codex-pick`; the manager reported about 74% weekly room
on every account. The content lead reports to this session and to the manager when
done or blocked.

Question 4 (what counts as a repeat in math) is still open.

## November 17, 2026: success test for math

Question 4, as asked: for math, is a repeat "the same problem with the same
numbers"? A student could then meet the same problem type again with new numbers.
Recommendation: yes.

Aedwon's answer, exact words: "Q4 yes"

Decision: for math, a repeat is the same problem with the same numbers. The same
problem type with new numbers is allowed. The spec states the exception to the
question style guide's rule on swapped numbers, for generated pools only.

Success test, both parts:

- Figures: "a student never re-encounters the same set of figures for a given
  problem type" (his words).
- Math: a student never meets the same problem with the same numbers (the lead's
  wording, which he accepted with "Q4 yes").
- Both hold while an unseen question remains in the pool (option C, not strict).

Question 5 asked (answer choices for figure questions): figures, as on the real
exams, or text descriptions, as today ("Line pointing lower-right"). Options:

A. Text choices stay. No UI work. Cost: the task becomes reading, not seeing, which
   is not how PSHS-NCE or the academies test it.
B. Figure choices (recommended). The engine stores each choice as figure data and
   also as a text description, which becomes the screen reader label. Showing figure
   choices is a UI change: boards in Claude Design, his visual approval, a Claude
   worker build. Rough cost: 2 to 3 days plus the board round.

Recommendation: B, split in two. This spec covers the engine and the pools, with no
UI. A second, small UI spec covers showing figure choices, after the beta, with
boards. Pools made now work with both, so nothing is generated twice. Figure
choices become part of the sale gate for PSHS-NCE and the academy exams.

Aedwon's answer to question 5: pending. He went back to the repeat rule first (next entry).

## November 17, 2026: every problem type first, then repeats

Aedwon's exact words: "wait a sec, backtrack

let me know what you think of this idea

while it is allowed for a user to meet the same problem type again with new numbers, it would be ideal if all types of question be encountered first before encounters of the same prob with different figures, if that makes sense"

This is a study-method question (practice order), so `WORKFLOW.md` has evidence
decide it. The lead checked sources in this session.

Evidence:

- Rohrer, Dedrick and Stershic (2015), Journal of Educational Psychology 107,
  900-908, doi 10.1037/edu0000001. 126 seventh graders, same problems, mixed order
  against one type at a time. Mixed order scored higher on a test 1 day later
  (d about 0.42) and 30 days later (d about 0.79).
- Rohrer, Dedrick, Hartwig and Cheung (2020), Journal of Educational Psychology
  112(1), 40-52, doi 10.1037/edu0000367. Randomized by class: 54 seventh-grade
  classes, 787 students. On an unannounced test a month later, mixed practice
  scored 61% against 38% (d = 0.83).
- Strength: good for "mix problem types in math practice" (two classroom studies,
  one randomized). Limits: one grade, one district, math only. Neither study
  tested "every type once before any type twice" as such; that step is the lead's
  inference. Figures read from search summaries of the papers, not the full texts.
- Sources read: https://ies.ed.gov/use-work/awards/interleaved-mathematics-practice
  and https://ies.ed.gov/ncee/wwc/Study/88770 and
  https://zendy.io/pdf-viewer/10.1037/edu0000367

Lead ruling (evidence agrees with his idea): adopt it, for math and for figures,
with two additions.

1. The rule, stated for any practice scope: among the lessons a session draws
   from, the problem type the student has seen least comes first. So every type is
   met once before any type is met twice, then twice before three times.
2. A missed type does not wait. A new version of it (new numbers or new figures)
   comes back through review on its normal schedule, even if other types are still
   unseen. Reason: practice after an error should not be delayed behind unrelated
   new material. Sources for this point are still to be confirmed before the spec.

Costs stated: every question needs a problem type label. Generated questions get
it from their template. The hand-written questions need one each, set when the
templates for their lesson are written. The app's question picking order changes
(no screen change): rough 1 to 2 days with tests, on top of the engine.
