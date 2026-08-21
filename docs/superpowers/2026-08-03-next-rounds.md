> **Superseded.** These prompts describe the 3 August tree. The current state
> and next work are in `2026-08-13-handover-checkpoint.md`, updated 22 August.
> Do not paste a prompt below without checking its plan and the current tree.

# Next rounds: prompts to paste after a clear

**Created 3 August 2026.** Every remaining piece of work that needs a session, written as a
prompt you can paste cold. Each one names the files to read first, because a fresh session
knows nothing.

**`2026-08-04-execution-pipeline.md` is the live map**: what to do first, what runs in parallel, and the tier each item belongs to. This file carries only the rounds that are not plans yet.
`2026-08-03-launch-checklist.md` is everything between here and a paid install.
`2026-08-03-plan-audit.md` is what the 3 August audit found.

**Every subagent works under `SUBAGENTS.md`**, at the repository root. It is the contract for
a dispatched run: what to read first, worktree isolation, the task loop for code and the task
loop for content, the verification protocol with its expected values, when to stop rather than
invent, what to report, and the rules for running several agents at once. **The prompts below
assume it and do not repeat it.** `AGENTS.md` remains the standards it enforces.

**How to use this.** Take one prompt, clear, paste. Do not run two design rounds in one
session: the decision log gets tangled and the second round inherits the first one's
assumptions. Execution prompts in Part 3 can run in parallel with each other as long as each
one gets its own worktree.

**When a round finishes, strike its prompt here** and say what closed it.

---

## Part 1: Design rounds still owed

Three, and each ends at a spec and a plan rather than at code.

### 1.1 The Pro specimen fallback, then the paywall plan

**Why it matters:** this is the purchase screen and the app currently cannot take money.
Blocks launch outright.

```
Pantas. I need a design round on one undesigned hole in the paywall, then the
paywall implementation plan.

Read `docs/superpowers/specs/2026-08-03-paywall-pricing-and-flow-design.md` and its
companion `2026-08-02-pro-entitlement-consolidation-design.md`, plus the paywall
observations in `docs/superpowers/2026-08-02-work-checkpoint.md` Section 4.

The hole: screen 1 shows a Pro specimen built from the student's own data. A student
with no mock and few attempts cannot fill it convincingly. That fallback is not
designed and it blocks the whole plan. Never invent a figure applies: the fallback
cannot show a made-up number, and it cannot show a sample student's numbers
presented as anything other than a sample.

Draw the whole screen before asking me about the fallback. Then options with costs
and a recommendation.

Also verify before planning: `purchases_flutter` is imported by zero files in `lib/`
and the only `RevenueCatGateway` is `DisabledRevenueCatGateway`, which returns Free
from `purchase()` and `restorePurchases()`. The app cannot take money. The live
gateway belongs in this plan, and the entitlement rule it must obey is Section 3 of
`specs/2026-08-03-offline-and-network-posture-design.md`: last known entitlement
stands until positively contradicted, and a network failure is not a contradiction.

Plan the presentation as a rebuild, not a repair. The spec was written assuming
nothing in `lib/features/paywall/` survives.
```

### 1.2 The study plan feature

**Why it matters:** the largest outstanding design job, and two shipped plans have already
reserved a shape for it.

```
Pantas. I need a design round on the study plan, which is the largest outstanding
design job.

Read `docs/superpowers/specs/2026-05-18-study-plan-design.md` and
`plans/2026-05-21-study-plan-plan.md`. Both predate the Ink and Rule identity by two
months. The providers throw, and the entry row was deliberately hidden on 25 July.

Two things already reserved a shape for it and you must not contradict them:
`plans/2026-08-02-study-04-reader.md` reserves a slot for a plan counter and a ticked
rail it cannot currently draw, and `plans/2026-08-02-home-04-up-next.md` ships rows
that open their own lesson because the three-lesson chain has nowhere to come from.
Home plan 4's note says nothing is lost when the chain arrives: the panel gains a
start index and its composition does not change. Hold it to that.

First question I want answered before any drawing: does v1 ship with this at all, or
ship with the row still hidden? Give me the cost of each. If it ships, draw the whole
surface before asking me about any part of it, then spec, then plans.
```

### 1.3 The mock exam's five missing screens

**Why it matters:** the mock is a Pro selling point and five of its surfaces are May sketches.

```
Pantas. I need a design round on the five mock exam surfaces that are still only May
sketches.

Read `docs/superpowers/specs/2026-07-28-mock-exam-ui-design.md`, which names them as
not designed: the setup screen beyond its one stated requirement, the pause and
strict-forfeit flows, the section-transition moment, the warning overlays, and mock
history. `specs/2026-05-17-mock-exam-design.md` sketches all five and they stand
until redrawn.

This may be a confirm round rather than a redraw round. The 07-28 spec was once
treated as more open than it was and I lost a round to that. Tell me first which of
the five actually need redrawing against the current identity and which just need
confirming, with your reasoning, before you draw anything.

Mock UI does not inherit the practice quiz's reveal or debrief: no reveals, timed,
exam conditions. Plans `2026-08-02-mock-01-the-paper.md` and `mock-02-the-endings.md`
already exist for the paper and the endings; this is the work around them.
```

---

## Part 2: Content plans that do not exist

Four passes are named as prerequisites by other plans and **nothing builds any of them.**
You own the generation; these rounds produce the plan you generate against.

### 2.1 Mathematics, the decision and then the plan

**Why it matters:** Mathematics is a section in five of your seven exams and has **zero**
questions. Deferring the template engine took the whole subject with it. This is the only
open item in Gate 0 of the launch checklist.

```
Pantas. I need to settle Mathematics content and, if we go ahead, write the plan.

Facts, verified 3 August: all six Mathematics topics have zero questions in
`assets/seed/v1.json`. The other three subjects each have a static content plan
(`plans/2026-07-20-question-generation-science.md`, `-language-proficiency.md`,
`-reasoning.md`). Mathematics has none, because it was always going to be the
template quiz engine's job, and I deferred that engine to a later version.

Two options and I want the costs, not a recommendation dressed as one:
(a) write a static Mathematics content plan in the shape of the other three;
(b) launch without the subject, which means `MockSampler` cannot fill a paper for
    UPCAT, ACET, DLSUCET, USTET or PUPCET, and the Progress pace-per-question column
    stays empty because it is mock-only.

If (a), read one of the three existing content plans first and match its structure
exactly: the manifest table with a Done column, the generation procedure, the
definition of done per subtopic, and the deferred-items section. Math needs LaTeX in
stems, which `flutter_math_fork` already renders, and figures for geometry, which
means reading `specs/2026-07-20-illustration-question-figures-design.md` before
writing the manifest.
```

### 2.2 Reading comprehension and text types

**Why it matters:** three topics at zero, deliberately deferred out of the language plan to a
"future plan" that was never written.

```
Pantas. I need the content plan for the passage-based topics.

`plans/2026-07-20-question-generation-language-proficiency.md` has a "Deferred items"
section that pushes Reading Comprehension and Text Types out of scope entirely, to
their own future plan. That plan does not exist, and Text Types, Comprehension Skills
and Language Application all sit at zero questions today.

Language Application is different: it has three unticked manifest rows in the
existing plan and needs no new plan, just execution. Say so rather than duplicating
it.

Passage-based questions break an assumption the existing plans hold: the language
plan explicitly bans a shared passage read by several questions. That ban exists for
a reason and reading comprehension cannot honor it. Tell me what changes downstream
if a question can belong to a passage: the picker, the session builder, the mock
sampler, the review screen. Then spec, then plan.
```

### 2.3 The `lessonId`, rationale and short-label passes

**Why it matters:** all three are zero across all 1,117 questions, and each one hollows out a
surface that is otherwise built.

```
Pantas. I need a plan for the three content passes that gate finished surfaces.

Verified 3 August against `assets/seed/v1.json`: zero of 1,117 questions carry a
`lessonId`, zero carry a `rationale`, and the short label is unset.

What each one gates, per the work checkpoint's dependency map:
- `lessonId`: the reader coda, lesson selection in the practice picker, and the
  Lesson level of the Progress table.
- A rationale per choice: note B on the reveal and the debrief's second sentence,
  both of which Pro sells.
- A short label per question: the debrief's miss rows and the review's rows, which
  otherwise fall back to a clamped stem.

Every plan that reads them already degrades honestly, so nothing is broken. What is
missing is the pass itself.

These may be one plan or three. Tell me which, with the reasoning, before writing.
`lessonId` in particular may be derivable rather than authored, since questions were
generated per subtopic from lessons: check `tools/import_questions` and the YAML in
`content/questions/` before assuming it needs a human. If it is derivable, that is a
tool change and not a content pass, and it should be said plainly.
```

### 2.4 Rebuild the seed

**Why it matters:** ten authored files are sitting in the repo outside the app. Smallest job
with the biggest immediate content gain.

```
Pantas. Rebuild the content seed and tell me what changed.

`assets/seed/v1.json` carries `generatedAt: 2026-07-25`. The Spatial and Abstract
Reasoning and Mechanical and Technical Reasoning YAML files in
`content/questions/reasoning/` are dated 31 July, ten files in total, and the seed has
zero questions for both topics. Authored content is sitting in the repo and not
reaching the app.

Use `tools/build_dev_seed`. Before and after, report the per-topic question counts so
we can see exactly what arrived. If any count goes down, stop and say so: that means
the tool dropped content.

Note that `plans/2026-08-03-content-upgrade-seeder.md` adds a `contentVersion` to this
file. If that plan has already run, follow it. If it has not, this is a plain
regeneration and the version work is not yours.
```

---

## Part 3: Execution, when you are ready to dispatch

### 3.1 Phase 0, the four foundation plans

```
Pantas. Dispatch Phase 0 from `docs/superpowers/2026-08-04-execution-pipeline.md`.

Four plans, none depending on any other plan in the repository:
`plans/2026-08-03-foundations-01-observability.md`
`plans/2026-08-03-content-upgrade-seeder.md`
`plans/2026-08-03-foundations-02-app-check-and-force-update.md`
`plans/2026-08-03-offline-posture.md`

One plan per implementor, one worktree each, never two plans against the same tree.
Read Part 1 of the pipeline document for the dispatch rules before starting.

Verify the gates yourself rather than relaying the implementor's report. The last
background run claimed zero new analyzer issues when there were nine, and wrote
outside its worktree leaving a half-applied `app_database.dart` that compiled.
Baseline: `flutter analyze` 27 issues all under `tools/` or `test/tool/`,
`dart run tool/check_layering.dart` 7 violations, `flutter test` green.

Two of these plans deliberately stop and ask rather than proceeding. Bring me the
question; do not let an implementor answer it.
```

### 3.2 A single plan, any plan

```
Pantas. Execute `plans/<FILENAME>.md`.

Read `docs/superpowers/2026-08-04-execution-pipeline.md` Part 1 for the dispatch rules
and Part 4 for the collision map before starting, and check whether anything this plan
touches is named there.

Work in a worktree. Follow the plan task by task, test first. Do not redesign: if a
step is ambiguous or looks wrong, stop and bring it to me.

Verify the gates yourself and show me the output, not a summary.
```

### 3.3 Pull the accessibility rules forward

**Why now:** its Task 1 is documentation and belongs in Phase 0. Its Tasks 2 and 3 want a kit
that has stopped changing.

```
Pantas. Run Task 1 only of `plans/2026-08-03-foundations-04-accessibility.md`.

It adds four accessibility rules to the Global Constraints of every unexecuted UI
plan, so components are built right the first time rather than swept later. Tasks 2
and 3 of that plan stay where they are: they sweep a kit that has not stopped changing
yet.

Report how many plans you touched.
```

### 3.4 Content generation, in parallel

**This is the mode for the remaining questions.** Content agents write `content/` and
`assets/seed/`; code agents write `lib/` and `test/`. They never conflict, so these can run
alongside any code thread.

```
Pantas. Dispatch content generation for <SUBJECT>.

Plan: `docs/superpowers/plans/2026-07-20-question-generation-<SUBJECT>.md`.
Every agent reads `SUBAGENTS.md` Part 4 before starting, then `AGENTS.md` in full,
then the plan end to end including its manifest and its definition of done.

One subtopic per agent, one worktree each. Take only rows whose Done column is
unticked. Validate after every single file with
`dart run tools/import_questions/import_questions.dart --root content/questions`
and never batch several subtopics before validating.

The rules no validator enforces are in `SUBAGENTS.md` Part 4 and they are the ones
that matter: exam level rather than textbook level, grade-5-simple English in the
stem, coverage exhaustive within the subtopic, every distractor a real mistake, no
invented figures, no em dashes, American spelling, Filipino items where the manifest
says so, `approved:` left unset, and no AI-generated images ever.

Report per agent: which subtopic, how many questions, the validator's actual exit
code pasted, and any manifest row you could not complete and why. I approve in
Question Studio myself; do not tick a row you have not validated.
```

**Before dispatching, check the manifest.** Unticked rows as of 3 August: three in Language
Application. Spatial and Mechanical Reasoning are authored but **not in the seed**, so run
the rebuild in Part 2.4 rather than regenerating them.

---

## Part 4: Small jobs

```
Pantas. Correct `docs/OPERATIONS.md`. It was last updated 7 May and is a launch
document.

Known wrong, verified 3 August: it calls the app "CSE/CET Reviewer" when it is being
renamed to Pantas; it lists RevenueCat products as `cse_cet_pro_monthly`,
`cse_cet_pro_yearly` and `cse_cet_pro_lifetime` when the settled SKUs are
`pro_weekly`, `pro_monthly` and `pro_yearly` with lifetime removed on 3 August; and it
gives bundle IDs as `com.aedwon.csecetreviewer` when `android/app/build.gradle.kts`
says `com.aerol.csecet`.

Check every other claim in it against the tree the same way. Do not tick any checkbox:
they are all mine and most are still open. Add rows for the two things it is missing,
the community group URL and the developer contact email.
```

```
Pantas. Sweep American spelling across every spec written before 3 August.

That is `plans/2026-08-03-settings-06-about-and-the-pushed-pages.md` Task 4. The rule
entered `AGENTS.md` on 3 August: practice, color, behavior, analyze, gray, center,
organize. Never practise, colour, behaviour, analyse, grey, centre, organise.

The decision logs are exempt. They quote what was on screen at the time and rewriting
them would falsify the record.

Watch for false positives: at least one plan greps for British spellings as a test, and
at least four assert that an em dash is absent. Those are correct as written.
```

---

## Part 5: Only you can do these. No prompt will help.

### Decisions a model is waiting on

| Decision | What is blocked |
|---|---|
| **`url_launcher`** | Two tasks stop and ask on it: the feedback row's link, and the force-update button that opens the store. One answer covers both. |
| **`in_app_review`** | The review prompt. Its eligibility policy is built either way; only the asking waits. |
| **Mathematics** | Part 2.1. The last open item in Gate 0. |
| **Reading comprehension in v1** | Part 2.2. |
| **The study plan in v1** | Part 1.2. |
| **Facebook or Discord** | Not blocking. The row opens a URL and does not care which. |

### Things that need an account, a device or a person

- **`sectionalTiming` for ACET, DCAT and MSU-SASE.** Three blueprints cannot be completed.
  The other four exams are researched.
- **Create the community group** and record its URL in `docs/OPERATIONS.md`.
- **A developer contact email** for the Play listing. The group does not satisfy this.
- **Google Play Console account**, and the store listing: title, descriptions, feature
  graphic, screenshots, content rating.
- **App icon and splash** for the Pantas identity.
- **RevenueCat and Play IAP setup**, all ten lines in Gate 5 of the launch checklist.
- **Firebase deploys**: Firestore rules, the callables, App Check in monitor mode first.
- **NPC registration**, and a PH lawyer on `PRIVACY.md` and `TERMS.md`.
- **Illustrations.** `content/illustrations/` is empty and the figure-heavy reasoning topics
  are the ones that need them.
- **Every visual verification.** No model screenshots the emulator. Findings go in
  `docs/ui-audit.md`.
- **Measure a cold first launch on your slowest real device.** The seed inserts 1,117
  questions and grows with every subject you generate, and nobody has timed it.

---

## What is genuinely done

So the list above reads as what is left, not as everything.

- **All five tab designs**, specced and planned: Home, Study, Quiz, Progress, and the mock's
  paper and endings.
- **Settings**, specced and planned in six plans.
- **Onboarding, custom tracks and exam switching**, planned.
- **The four platform specs** of 3 August: offline, content delivery, platform foundations,
  notification engagement, with seven plans behind them.
- **All six plan conflicts**, ruled and landed.
- **47 of 47 plans** carrying a model-agnostic preamble, citing `AGENTS.md` and their source
  spec, and stating the analyzer baseline.
