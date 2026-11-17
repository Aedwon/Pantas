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

## November 17, 2026: the serving rules checked against the app's systems

Aedwon's exact words: "um i think you have to marry this idea with how the roadmap does things as well" and then "among other systems that exist in the app, there might be some contradictions/conflicts need resolving"

Mistake: the lead had adopted and priced a serving rule without reading how the app
picks questions. Process-improvement entry written the same turn
(`docs/workflow/process-improvement.md`, "Picking rule proposed before reading how
the app picks questions").

Method: one Sonnet reader mapped every system that serves or tracks questions on
`origin/main` (0edf1dcf6 source). The lead spot-checked the roadmap count, the
review table key and the server cap in the source. Not verified by the reader: the
compiled engine the server runs, sync paging limits, whether the content gate runs
in CI, Wrapped internals.

How the app works today (facts):

- Everything is keyed on one question id: review state (one row per question),
  mastery, follow-ups, "why you miss", sync (one document per question), server
  answer totals.
- Roadmap: "seen" means the question has review state. The daily new-question load
  is unseen questions divided by working days left
  (`lib/features/roadmap/domain/build_roadmap.dart:70`). "All covered" needs zero
  unseen questions (`:123`). New questions come in lesson order, then id.
- Review re-serves the same question id.
- Practice and drill push questions answered in the last 7 days to the back. The
  in-lesson quiz does not avoid seen questions. The mock avoids only the last 2
  mocks. Mock and assessment answers count as seen.
- Sized for about 3,200 questions: server answer totals stop at 6,000 questions per
  student (`functions/src/_answerTotals.ts:36`); web delivery allows 300 documents
  per account per day; topic screens load every question in a topic.
- The content gate needs a ledger hash for every shipped question.

Conflicts with the session's choices so far:

1. Pools of about 1,000 questions per problem type, shipped as ordinary questions
   (option A as the lead described it), would push the daily load into the
   hundreds, make "all covered" unreachable, and pass the server, delivery and sync
   limits. The lead's claim "little app change" for option A was wrong.
2. Review brings back the same question. That breaks "never the same figures" and
   the rule that a missed type returns as a new version.
3. If each version were its own question, mastery, follow-ups and "why you miss"
   would see every version as brand new, with no history.
4. No system orders by problem type; the label does not exist in the app.
5. Practice, the in-lesson quiz and the mock each use a different repeat rule.

Resolution proposed by the lead (not yet accepted by him):

- The app treats one problem type as one question. It keeps one id, one review
  state, one history. Each time the app serves it, it shows the next version from
  a checked list made before release. One counter per student per type says which
  version is next, so no version returns until the list ends.
- Effects: the roadmap counts types, so the daily load stays sane and "all
  covered" stays reachable. Its unseen-first rule already gives "every type before
  any repeat". After the first meeting, the review schedule decides when a type
  returns, always with a new version. History per type measures the skill, not
  memory of one question. Server, sync and delivery limits hold, because ids grow
  little.
- A student meets a type only as often as review, practice and mocks serve it, so a
  list of about 100 versions per type should outlast normal study, not 1,000. A
  version is stored as its numbers or figure data; the type holds the shared
  wording. The exact size is set in the spec.
- App changes still needed: fill a type's wording with a version's values; record
  which version each answer used; practice and the in-lesson quiz prefer types not
  yet met; the same on the server side for web. No screen change.
- The lead's earlier claim that live generation would need changes to review,
  mistakes, progress and sync (10 to 15 days) was also wrong under this model.
  Option C's later step becomes cheap: generate versions in the app instead of
  reading a list.

Cost corrected: about 8 to 12 days for abstract reasoning end to end (engine,
templates, checks, the app and server changes above, tests), against the 4 to 6
first given. Rough until the spec.

Question 6 asked: in a lesson, do generated types replace the hand-written
near-duplicate questions, or sit next to them? Options:

A. Replace (recommended). The hand-written questions of one pattern become the
   first versions inside that type; nothing is thrown away. Questions that cannot
   be templated stay single. Cost: a lesson may hold fewer than 20 ids, so his
   October 1 rule ("at least 20 active questions per lesson") must count versions;
   existing answers on live CSE questions must be carried to the type.
B. Sit next to them. No change to live questions. Cost: the same pattern appears
   as hand-written near-duplicates and as a type, the daily load grows, and the
   near-duplicates his October 25 words meant to replace remain.

Aedwon's answer, exact words: "go with your reco"

## November 17, 2026: generated types replace near-duplicates

Decision (question 6): replace. In a lesson, the hand-written questions of one
pattern become the first versions inside that problem type. Questions that cannot
be templated stay single. His October 1 rule of at least 20 active questions per
lesson counts versions. Existing answers on live CSE questions carry over to the
type; the spec must say how.

What his words cover: question 6 only. The model under it (one problem type is one
question to the app, with a checked list of versions and one counter per student)
was shown in the same reply and he raised no objection. It is not separately
approved; his approval of the spec's plain-language section is the gate for it.

Still open: question 5 (figure answer choices, split into a later screen spec),
the build timing, and the complexity level.

## November 17, 2026: figure answer choices, in a second spec

Question 5, as asked again: should answer choices for figure questions be figures,
like the real exams? A: keep text choices. B: figure choices, in two parts (this
spec covers the engine and versions with no screen work; a second, small spec
covers showing figure choices after the beta, with boards).

Aedwon's answer, exact words: "go with your reco"

Decision: B, in two parts. Each version stores every choice as figure data and as
a text description. This spec has no screen change. A later screen spec shows
figure choices, with boards in Claude Design and his visual approval. Figure
choices are part of the sale gate for PSHS-NCE and the academy exams.

Question 7 asked (complexity level, required by `WORKFLOW.md` before a build):

- Minimal: the engine, the checker, the type-and-version model in the app and on
  the server, and abstract reasoning only (5 lessons). Math templates wait for a
  later batch. Check: a script proves every version has exactly one correct
  answer; Codex audits each template once. About 8 to 12 days.
- Balanced (recommended): minimal, plus a math pilot of 2 or 3 CSE lessons in the
  same build, plus a blind solve of a sample of versions per template by a
  different model, plus a measured count of how far students are through each
  list. About 11 to 16 days. Reason: he widened the scope to math, so the build
  should prove the engine on math before 300 to 450 templates are written, and
  the pilot measures the cost per lesson.
- Hardened: balanced, plus versions generated inside the app, plus a full Astra
  audit of every template. About 3 weeks or more. Not needed while lists outlast
  normal study.

Aedwon's question first, exact words: "in hardened wdym by \"versions generated inside the app\""

Lead's answer: it is the live generation of option B. In minimal and balanced, the
versions are made and checked before release and the app reads a fixed list. In
hardened, the app makes each version on the student's phone when needed: strict
never-repeat and no refills, but nobody checks that exact question before the
student sees it, and about a week more build.

Aedwon's answer to question 7, exact words: "go with your reco"

## November 17, 2026: balanced complexity chosen

Decision: balanced. The engine, the checker, the type-and-version model in the app
and on the server, abstract reasoning (5 lessons), a math pilot of 2 or 3 CSE
lessons, a blind solve of a sample of versions per template by a different model,
and a measured count of how far students are through each list. About 11 to 16
days, rough until the spec. This chooses the level; it does not start the build.

Question 8 asked (build timing):

A. Start on November 23, after the beta ends (recommended). The build changes how
   the app records answers and reviews, which should not change under testers.
   Codex is busy with the math lessons this week, and lead review needs Claude
   usage, which is tight this week. Cost of waiting: none for sales, since no
   gated exam can sell before mid-2027.
B. Start the parts that touch no app code as soon as the spec is approved (the
   generator, the checker, abstract reasoning templates), and the app and server
   parts after November 22. Gain: about a week earlier. Cost: it competes with the
   math lesson job for Codex, and needs Claude usage this week for the plan and
   reviews.
C. Later, when the first gated exam is chosen.

Aedwon's answer, exact words: "okay with A
actually correction, PSHS-NCE can still sell"

## November 17, 2026: timing A chosen; correction on PSHS-NCE

Decision (question 8): A. The build starts on November 23, after the beta ends.
This is the planned start, not a go for the build; the spec is not yet approved.

Correction from him: "PSHS-NCE can still sell". The lead had said three times that
no gated exam can sell before mid-2027 and used it as the cost argument for
waiting. That came from the next-exam brief's judgment ("Not feasible for this
cycle"), which he never approved. Process-improvement entry written the same turn.

Facts on record for PSHS-NCE this cycle: the test is January 30, 2027 (PSHS,
official); applications closed November 7, 2026. That is 74 days from today. What
the repository says must exist before it goes on sale:

- the generator, and now figure answer choices (`docs/pricing.md`; question 5);
- PSHS-NCE content (math is being sourced now; scientific, verbal and abstract are
  not started);
- an account path for takers under 13 (most are 11 or 12; launch stays 13+ and the
  parent and child consent work is an idea, backlog D7 and E5);
- the 1,499 peso pass as a product, and live payments (backlog A7, A8);
- the public launch itself (the beta gate is still on).

The lead's reading of his words is not confirmed: he may mean this cycle, or sales
in early 2027 for the next cycle. Question 9 asks.

Question 9 asked: is the aim to sell PSHS-NCE for this cycle (test January 30,
2027)?

A. Yes, this cycle. Then timing A is too late: the generator's offline parts
   should start as soon as the spec is approved (timing B), and the manager must
   line up the other items above. Cost: Claude usage this week, Codex shared with
   the math lesson job, and a selling window of a few weeks at best.
B. No, the next cycle. Timing A stands. PSHS-NCE can go on sale whenever its
   items are done in 2027; nothing in this build needs to move.

Aedwon's answer, exact words: "A"

## November 17, 2026: PSHS-NCE is aimed at this cycle

Decision (question 9): the aim is to sell PSHS-NCE for this cycle, test January 30,
2027.

What his "A" covers: the aim. Option A's text also said the generator's offline
parts should start once he approves the spec, and that the manager must line up
the other items. Those rode along in one option, so the lead does not treat them
as separately approved:

- The earlier start replaces timing A only when he approves the spec, whose
  plain-language section states the start. Until then nothing is built.
- The other items (PSHS-NCE content beyond math, the under-13 account path, the
  pass product, live payments, the public launch) belong to the operations
  manager. The lead told the manager his decision and that none of those items is
  approved by these words; the manager brings him a plan with costs.

Effects on this build, for the spec:

- Abstract reasoning ships first, because it is the sale gate. The math pilot
  follows it and does not block the gate.
- The figure-choice screen spec is now on the path to the sale. It can no longer
  wait for "after the beta" as a loose date; it starts as soon as this spec is
  approved.
- App and server changes are built on a branch and reach production only after
  the beta ends on November 22.

Lead's view given to him once: the generator can be ready in time. The risk to a
sale this cycle is in the other items, mainly the account path for takers under 13
and live payments.

## November 17, 2026: spec written

Spec: `docs/superpowers/specs/2026-11-17-question-generator-design.md`, waiting for
his approval of Part A. It records the seven decisions above and asks three more:
approve Part A (which sets the start: offline parts on approval, app and server
parts from November 23); reword his October 1 rule so the 20 questions per lesson
count versions; approve a type as a whole when its four checks pass, in place of a
separate re-solve of every version.

Evidence added while writing: Freund and Holling (2011) found no large difference
in retest gains between identical and parallel figure matrix forms. So research
does not decide whether review should show the same question or a new version; his
goal decides it. The spec says so in Part A.

The lead told the operations manager about the PSHS-NCE aim and listed the other
sale items, none approved by his words.

No build has started. No plan is written. Both wait for his approval.

## November 17, 2026: Part A approved

Aedwon's exact words (his own message in this thread, checked against the thread
record; a report from the math lessons lead arrived just before it as a separate
message): "Part A is approved. go with your reco for other items"

Decisions:

1. Part A of the spec is approved. Under its decision 1 this sets the start: the
   plan, then the generator, the checker and the abstract reasoning types now; the
   app and server parts from November 23; nothing on prod before the beta ends, and
   prod waits for his "ship it".
2. The 20-question rule counts versions. `docs/content/question-style-guide.md`
   updated.
3. A type is approved as a whole when its four checks pass (checker, blind solve of
   5 versions by a different vendor, Codex GPT 6.1 Sol high audit, his figure
   sheets for the first release). This replaces a separate re-solve of every
   version, for generated types only.

Math lessons report (from the math lessons lead, not re-checked by this lead):
branch `content/math-for-generator-r1` 4b5bd5086, lists in
`docs/content/math-for-generator/lesson-lists.md`. CSE 54 live math lessons; CET
121 with the audit complete; PSHS-NCE 3 new lessons with 5 choices per question,
sourced from the official 2024 reviewer and the 2015 sample, which give no topic
list. The spec's B1 now carries these facts and B5 allows 5 choices per type. The
whole job was reported done in under an hour, so the build plan re-checks the
pilot lessons it uses before writing types against them.

Handoff: the build goes to a build lead under the operations manager (spec B9).
This session stays the adviser for rulings. The figure answer choices spec goes to
a UI lead through the manager.

Handoff sent (November 17): the operations manager was asked to launch a generator
build lead (plan, then build, within the approved spec) and a UI lead for the
figure answer choices spec. Spec, log and both process-improvement entries are on
main at 7e207aebd. Session estimate E-103 closed: 1 h 23 min wall.

## November 17, 2026: build lead starts; wait for Codex resets

Build lead (Opus 5.5) started the plan on `gen/question-generator-r1` (velocity row E-107).

Rule from Aedwon for this lane, relayed verbatim by the operations manager: "wait for codex resets. this is true for lesson-generation related tasks and threads". All three Codex accounts filled their 5-hour windows at about 18:55 UTC Nov 16; the soonest reset is about 22:04 UTC.

What changed: before every Codex run the lead checks `codex-pick --status` and starts nothing until an account shows 5-hour room. No Claude worker substitutes for Codex work in this lane. Plan writing continues, kept lean. One Sonnet reader (started before the rule arrived) re-verifies spec B1 for the plan; the math pilot lesson re-check waits for the first Codex window.

## November 17, 2026: plan written; B1 re-verified

Plan: `docs/superpowers/plans/2026-11-17-question-generator.md`. B1 evidence: `docs/superpowers/verification/2026-11-17-question-generator-b1.md` (Sonnet reader, file and line evidence; prod content 88f38e698, prod web and functions match main).

B1 corrections and lead rulings (Part B only; Part A unchanged):

1. Web "seen" comes from server answer totals, not review state. Ruling: the server aliases merged old ids to their type id when counting seen.
2. Withdrawal by `isActive` cannot be authored in yaml today. Ruling: the exporter writes merged questions inactive while their type is enabled and active when it is disabled; `enabled: false` on the type is the rollback switch. Question yaml is not edited, so ledger hashes stay.
3. `questionVersion` already exists as a content revision. Ruling: the new field is `variantIndex`.
4. The 7-day rule is Practice only. Ruling: Drill gets never-met first and is otherwise unchanged.
5. Abstract reasoning on prod content has 105 questions, 94 with figure data. Types are built from prod content; the 11 without figure data stay singles.
6. The server runs app Dart compiled to JS. Ruling: any shared Dart change regenerates it and diffs a second build.
7. Carry-over is an alias at read time, not a rewrite of stored history, so rollback restores the old ids untouched.
8. A variant counts as served when its answer is submitted, not when shown.

Math pilot candidates, checked live on prod content by the lead: discounted prices (5 questions), age word problems (4), finding number patterns (3). The math lessons branch lacks the Algebra parts, so the pilot reads prod content.

Estimate: 13 to 17 days, top of the spec's 11 to 16, from the server alias and the compiled JS. Rows E-109 to E-112.

## November 16, 2026 23:35 UTC: Codex sharing between lanes

From 22:30 to 23:29 UTC the PSHS-NCE content lead's back-to-back runs kept codex-pick's one-run guard busy, and this lane's queued run never started. The operations manager ruled: both lanes may use `CODEX_PICK_PARALLEL=1` whenever `codex-pick --status` shows room for each run, capped at 3 runs at once across all lanes, as Aedwon allows. No turn order.

Also answered for the PSHS-NCE lead: "dots inside overlapping shapes" (official reviewer IV-13 to IV-16) is not a generator figure kind. Spec B11 keeps new figure kinds out of scope, and a new kind needs a widget (UI). The lead was asked to log it as a backlog engineering item.

## November 17, 2026 09:10 UTC: Phase 1 audit outcome; two matrix types held

Process: Codex GPT 6.1 Sol high audited all 30 listed types (audit-a.md, audit-b.md), then re-audited after each fix round (reaudit-a.md, reaudit-b.md, reaudit-c.md). Lead rulings: `docs/superpowers/plans/2026-11-17-question-generator-briefs/fix-rulings.md` (R1 to R5).

- R1 changed what counts as a new version: the shown figures, the stem slots and the correct answer; wrong choices no longer count, and grouping rows are order-free. This is stricter toward Aedwon's goal ("a student never re-encounters the same set of figures for a given problem type"). Under it, 30 listed types fell to 17.
- Competing rules the audits found were added to the checker's rule library (doubling count tracks, left-right and up-down reflection, counting-sequence continuation, highest ray).
- matrix-ray-turn and matrix-dot-sum: each re-audit found another equally simple rule (diagonal reflection; multiplication and column rules). Lead ruling: hold both rather than keep iterating inside Phase 1. Extending the library for them is later work. Spec B12 already names this risk: "The library must grow with each new rule, or the search proves less than it claims."
- matrix-ray-intersection and series-interleaved-count are held because their hand-written sources admit a second rule; matrix-corner-step is held at 9 distinct tasks.
- Accepted Minors (documented variety limits): group-polygon-replacement, matrix-corner-reflection, matrix-dot-sum (held anyway).

Result: 13 active types with lists of 100, all passing the checker, the final blind solve (blind-solve-4, 75 of 75 on the then-15 types) and the audits. 45 types held.

Prod content issues routed to the content lane through the operations manager: figure-series 0019 (wrong note), figure-series 0017 (two defensible answers), figure-matrices 0019 (wrong note), figure-grouping 0006 (identical figures with position-only distractors, sent at the milestone), figure-matrices 0009 (ray-intersection source admits "keep the highest ray", sent at the milestone).

## November 17, 2026: source fixes landed on a content branch

The operations manager reports all five source issues fixed on `content/fix-figure-series-0019` at 6c1f9402e (next ship-it bundle): series 0017, series 0019, matrices 0019, grouping 0006, matrices 0009. Every type built on them is held (series-interleaved-count, matrix-corner-grid, group-side-count-medium, matrix-ray-intersection; series 0019 had no type), so no active type is affected. Re-sync: when a held type is revisited, its index 0 is rebuilt from 6c1f9402e or its successor, and the checker's merged-source check runs against that ref.
