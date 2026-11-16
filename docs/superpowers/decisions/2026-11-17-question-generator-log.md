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

Aedwon's answer: pending.
