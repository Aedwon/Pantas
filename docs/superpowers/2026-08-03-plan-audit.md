# Plan audit, 3 August 2026

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

> **CLOSED 3 August.** All six conflicts were ruled on and every amendment in this document
> has been landed in the plans themselves. The five readiness fixes are done: 47 of 47 plans
> now carry a model-agnostic preamble, cite `AGENTS.md`, name their source spec and state the
> analyzer baseline. **The live execution order is `2026-08-04-execution-pipeline.md`**, not
> the checkpoint. This file is kept as the record of what was found and why.
>
> **One correction to Section 3, item 4.** This document and the work checkpoint both said
> `content-seed-delivery` Task 1 asserted `'SQLite format 3 '` with a trailing space. It did
> not: it carried a **literal NUL byte**, which is the correct value and which is why the
> file registered as binary and broke every grep over it. The assertion was right and the
> encoding was wrong. It is now written as the escape `\x00` and the file is plain text.

An audit of every spec and plan in `docs/superpowers/`, looking for four things: what is
still unspecced or unplanned, where plans contradict each other, whether the plans are
executable as written, and whether they carry enough context for an implementor who arrives
cold.

Every claim here was checked against the tree on this date. The question template engine for
Mathematics and Science is treated as **deferred to a later version**, per Aedwon's
instruction of 3 August, and the consequences of deferring it are recorded in Section 2.

Companion document: `2026-08-03-launch-checklist.md`.

---

## Section 0: The shape of the work

| | Count |
|---|---|
| Specs | 42 |
| Plans | 76 |
| Plans written and never executed | 39 |
| Tasks in those 39 plans | ~180 |
| Threads they fall into | 7 |

`flutter analyze` on this date: **27 issues, every one of them in `tools/` or
`test/tool/`. `lib/` is clean.** That is the baseline an implementor inherits.

---

## Section 1: Six conflicts between plans

These are the ones that need a ruling before anything is dispatched. Each gives the options
and what each option costs.

### C1. `ExamDate` is defined twice, with incompatible APIs

Two plans both **create** `lib/features/settings/domain/exam_date.dart`:

| | `2026-08-02-onboarding-flow-and-new-steps.md` Task 1 | `2026-08-03-settings-02-storage.md` Task 1 |
|---|---|---|
| Constructors | `ExamDate.onDay(DateTime)`, `ExamDate.inMonth({year, month})` | `ExamDate.day(DateTime)`, `ExamDate.month(int, int)` |
| The nullable day | `day` | `exactDay` |
| Also has | `year`, `month`, `daysUntil(DateTime)` | `monthStart` |
| Both have | `precision`, `storageValue`, `fromStorage` | same |

The readers split cleanly down the middle:

- `daysUntil` and `inMonth`: `home-03-masthead-and-band`, `progress-02-your-pace`
- `exactDay`, `monthStart` and `ExamDate.day(`: `settings-03`, `settings-04`

**Cost of leaving it:** whichever plan runs second either overwrites the file and breaks
three other plans' call sites, or its implementor invents a merge. `AGENTS.md` forbids
inventing, and no test in either plan covers the other's API, so the invention would pass
the gates.

| Option | What it costs |
|---|---|
| **A. One union type on onboarding's names.** Keep `onDay` / `inMonth` / `day`, add settings' `monthStart`. | Amend three plans: settings 02, 03, 04. |
| **B. One union type on settings' names.** Keep `day(` / `month(` / `exactDay`, add `daysUntil`, `year`, `month`. | Amend three plans: onboarding-flow, home-03, progress-02. |
| **C. Settings 02 drops the type and consumes onboarding's.** | Settings can no longer run before onboarding. Hard ordering dependency where there is none today. |

**Recommended: A.** `ExamDate.onDay(...)` cannot be misread at a call site, and
`ExamDate.day(...)` sitting next to a getter called `exactDay` is exactly the confusion the
type exists to prevent. The amendment is three plans either way.

### C2. Two plans both claim schema version 15

- `custom-track-a-branch-and-scope` Task 3, Step 3: raise `schemaVersion` **from 14 to 15**,
  add `exams.isCustom` and `trackScopeLocal` under `if (from < 15)`.
- `study-01-foundations`: `int get schemaVersion => 15;` with its own branch at
  `if (from < 15)`.
- `custom-track-b-student-built-mock`: **15 to 16**, which inherits the error.

The tree is at 14 today, verified in `lib/core/storage/data/app_database.dart:57`.

**Cost of leaving it:** this does not fail to compile. The second plan to run writes a
migration under a version number an existing install has already passed, so drift skips it
in silence. That is a broken database on upgrade, found by a student and not by a test.

| Option | What it costs |
|---|---|
| **A. Assign the numbers now** against a fixed execution order. | Rots again the moment the order changes. |
| **B. Tell every migration plan to read the current value and take the next one.** | Needs a judgment call from the implementor, which is what we are trying to avoid with Flash. |
| **C. Both.** Assign explicit numbers, and add a verification step that asserts the current value before bumping. | One extra step per plan. |

**Recommended: C**, with study-01 taking 15, custom-track-a 16, custom-track-b 17. Study is
first in its own thread and depends on nothing; the custom track is last in the whole queue.
Every one of these plans already says the bump and its migration land in the same commit,
which is the rule the first background implementor broke.

### C3. Two shared review components, both in `core/ui`, with a same-named model

- `quiz-tab-06-review-component` Task 1 creates `lib/core/ui/components/review_list.dart`:
  `ReviewEntry {number, question, chosenChoiceId, isFlagged, subjectName, label,
  labelIsStem}`, `ReviewFilter {all, wrong, flagged}`, `FilterReviewEntries`.
- `mock-02-the-endings` Task 2 creates
  `lib/core/ui/components/question_review_list.dart`: a different `ReviewEntry`,
  `ReviewGrouping {bySubject, flat}`, `QuestionReviewList` with a `header` slot.

Both plans give the same reason for the location, almost word for word: two features render
it and neither owns it. Both also modify `mock_results_page.dart`. Quiz 6 additionally
creates `mock_review_page.dart`.

**Cost of leaving it:** two components with one purpose and a colliding model name. This is
the near-duplicate `AGENTS.md` calls the most common avoidable defect in this codebase, and
here it would be built deliberately, by two plans that each thought they were the one
preventing it.

| Option | What it costs |
|---|---|
| **A. Quiz 6 owns the component.** Mock 2 Task 2 becomes "add `ReviewGrouping` and the `header` slot to it". | Mock 2 loses a task and gains a dependency it already half declares. |
| **B. Mock 2 owns it.** Quiz 6 consumes. | Quiz 6's filters and short-label fallback have to be added back; it is the richer model. |
| **C. Fold both into one plan.** | Rewrites two plans to save one. |

**Recommended: A.** Mock 2 already says "check Quiz Plan 6 first, it owns this rebuild", so
this makes the intent explicit rather than leaving it to the implementor to notice. Quiz 6's
model also carries `label` / `labelIsStem`, which is how the missing short-label content pass
degrades honestly.

### C4. The Settings thread is not in the execution order, and it collides with three plans that are

`settings-03` Task 4 **deletes** four widgets: `ios_switch.dart`, `settings_row.dart`,
`settings_section.dart`, `theme_segmented_control.dart`.

Three unexecuted plans write against those widgets, and more than that, they build the same
features twice:

| Duplicated work | Plan A | Plan B |
|---|---|---|
| `lib/core/ui/components/exam_selection_row.dart` | `onboarding-polish` T3 (create) | `settings-05` T1 (create) |
| `lib/features/settings/presentation/pages/exam_page.dart` | `onboarding-polish` T4 (create) | `settings-05` T3 (create) |
| The daily reminder row and the exam date row | `onboarding-polish` T5, T6 | `settings-04` (the sheets) |
| The carry-over preference | `exam-switching` T1, in `AppPreferencesRepository` | `settings-02`, in `UserSettings` and `settings.` prefs |
| The carry-over prompt | `exam-switching` T3, `presentation/widgets/carry_over_prompt.dart` | `settings-05` T3, `presentation/carry_over_prompt.dart` |
| The carryable count | `exam-switching` T1, on `AttemptsRepository` | `settings-05` T2, as `carryableCountProvider` |
| Session ordering, as a surface | `quiz-tab-02b` Step 4: `SessionBuildingPage` at `/settings/sessions`, plus a `SettingsRow` in `settings_home_page.dart` | `settings-04`: the ordering sheet at `/settings/ordering` |

`settings-06` Task 5 does mark onboarding-polish T3 and T4 superseded, but it does so as a
documentation edit made **after** settings-05 runs. In the checkpoint's current order,
onboarding-polish is step 2 and the Settings thread is not in the table at all, so the
duplicate build happens first and the note lands on top of it.

**Cost of leaving it:** roughly six tasks of work built twice, then a rework pass to delete
one of each pair, plus one preference with two storage homes, which is the exact fault the
paywall consolidation round existed to fix.

| Option | What it costs |
|---|---|
| **A. Settings runs first**, then amend onboarding-polish, exam-switching and quiz-2b to consume it. | Onboarding, which Aedwon chose as next on 2 August, slips behind six plans. Three plans need edits anyway. |
| **B. Keep the order.** Run onboarding-polish and exam-switching first, rewrite settings 02, 04 and 05 to modify rather than create. | The Spec 8 widgets get built against, then deleted. The exam page is built twice. Settings 03's deletion task grows. |
| **C. Strike the duplicated tasks and fold them into Settings.** Onboarding-polish loses T3, T4, T5, T6; exam-switching loses T1 and T3; quiz-2b loses its settings page and keeps only the reader. Then run in whatever order. | Three plans edited once, no work built twice, and onboarding-polish ends up doing only onboarding. |

**Recommended: C.** It removes the duplication instead of sequencing around it, and after it
the ordering question mostly dissolves. Note that C leaves `exam-switching` with two tasks
(the per-student cooldown, and the figure filter), which may be worth folding into
`settings-05` entirely.

### C5. `/settings/sessions` and `/settings/ordering` are the same preference

Called out separately from C4 because it belongs to the Quiz thread and will be missed
otherwise. `quiz-tab-02b` Step 4 builds a whole page for choosing how sessions are built.
`settings-04` builds a sheet for the same three values, and `settings-02` owns the key.

**Recommended:** delete quiz-2b's page and row. Keep only the part the checkpoint's open
flag 3 actually asks for, which is the session builder **reading**
`settings.session_ordering`. Settings already writes it.

### C6. Already documented in the checkpoint, verified as still accurate

No action needed beyond what the checkpoint says, but confirmed today:

- `topicAccuracyProvider` is defined by `home-04`, `home-05` and `progress-03`. Three plans,
  not two as the checkpoint says. The collapse note needs to name all three.
- `severityFor` is in `home-05` and `progress-03`, moving to `lib/core/ui/severity.dart`.
- `InkCheckbox` is created only by `study-03a`. `quiz-05`, `quiz-06` and `custom-track-a`
  reference it and each say to check first. Adequate.
- `RuledPanel` is created by `quiz-02a` and modified by `home-03`. Correct.
- `StatsBand` is modified by `quiz-02b` and `home-03`. Correct.
- `InkTableRow` is modified by `study-01` T7 and `study-03a` T3. Correct.

---

## Section 2: What is still unspecced or unplanned

### 2.1 The paywall flow has a spec and no plan. This blocks launch.

`specs/2026-08-03-paywall-pricing-and-flow-design.md` is approved and nothing implements it.
It is the purchase screen. The checkpoint records the observations for whoever plans it and
is explicit that it is **a rebuild, not a repair**: the spec was written assuming nothing in
`lib/features/paywall/` survives.

**It also carries one open design hole**, and the checkpoint flags it: a student with no mock
and few attempts cannot fill the Pro specimen on screen 1 convincingly. That fallback is not
designed. It needs a design round before the plan can be written.

### 2.2 Mathematics has no questions, no spec and no plan

This is the real cost of deferring the template engine, and it is larger than the checkpoint
states. Measured from `assets/seed/v1.json` today:

| Topic | Questions |
|---|---|
| Arithmetic & Number Sense | **0** |
| Algebra | **0** |
| Geometry | **0** |
| Trigonometry | **0** |
| Statistics and Probability | **0** |
| Pre-Calculus & Basic Calculus | **0** |

Mathematics is a section in UPCAT, ACET, DLSUCET, USTET and PUPCET. The other three subjects
each have a static content plan (`2026-07-20-question-generation-science.md`,
`-language-proficiency.md`, `-reasoning.md`). **Mathematics has none**, because it was always
going to be the engine's job.

Deferring the engine therefore means one of two things, and it is a decision:

| Option | What it costs |
|---|---|
| **Write a static Mathematics content plan**, in the shape of the other three. | Six topics of authoring. No step-by-step explanations, which is a thing Pro was specified to sell. |
| **Ship without Mathematics.** | `MockSampler` cannot fill a paper for five of the seven exams. The Progress pace-per-question column stays empty, because it is mock-only. |

### 2.3 Three more subjects are authored but not shipped, and two are not authored

Also measured from the seed today:

| Topic | Questions in seed | YAML files in `content/` |
|---|---|---|
| Spatial & Abstract Reasoning | **0** | 5 |
| Mechanical & Technical Reasoning | **0** | 5 |
| Language Application | **0** | 0, manifest rows unticked |
| Text Types | **0** | 0, deferred by the language plan |
| Comprehension Skills | **0** | 0, deferred by the language plan |

`assets/seed/v1.json` carries `generatedAt: 2026-07-25`. The spatial and mechanical YAML
files are dated 31 July. **Ten authored subtopic files are sitting in the repo and are not in
the seed the app reads.** Rebuilding the seed with `tools/build_dev_seed` is a small job that
recovers a whole subject and a half.

Text Types and Comprehension Skills are passage-based and were deferred out of the language
plan explicitly, to "own future plan". That plan does not exist.

### 2.4 `lessonId` and `rationale` are zero across all 1,117 questions

Both are named in the checkpoint as content passes and neither has a plan. Verified today:
`0` questions carry a `lessonId`, `0` carry a `rationale`. Every plan that consumes them
degrades honestly, so this blocks no code, but it does hollow out the reader coda, lesson
selection in the picker, the Lesson level of the Progress table, and note B on the reveal,
which is a thing Pro sells.

### 2.5 The study plan feature

`specs/2026-05-18-study-plan-design.md` and `plans/2026-05-21-study-plan-plan.md` both
predate the Ink and Rule identity by two months. The providers throw, the entry row was
hidden on 25 July, and `study-04-reader` deliberately reserves a shape for a counter it
cannot draw. The checkpoint has called this the largest outstanding design job since
2 August and it is still true.

### 2.6 Mock exam surfaces still covered only by May sketches

Named by the 07-28 spec as not designed, and not in M1 or M2: the setup screen beyond its one
stated requirement, the pause and strict-forfeit flows, the section-transition moment, the
warning overlays, and mock history. Spec 5 sketches all five and they stand until redrawn, so
this is a "confirm or redraw" round, not an empty one.

### 2.7 Still on Aedwon

- `sectionalTiming` for **ACET, DCAT and MSU-SASE**. Three blueprints cannot be completed
  without it.
- **Question identity under FSRS for generated instances** is now moot while the engine is
  deferred. Recommend parking it explicitly rather than leaving it open, so it stops reading
  as a live blocker.

### 2.8 `docs/OPERATIONS.md` is stale and it is a launch document

Last updated 7 May. It still calls the app "CSE/CET Reviewer", lists RevenueCat products as
`cse_cet_pro_monthly`, `cse_cet_pro_yearly` and `cse_cet_pro_lifetime` when the spec settled
on `pro_weekly`, `pro_monthly`, `pro_yearly` **with lifetime removed**, and gives bundle IDs
as `com.aedwon.csecetreviewer` when `android/app/build.gradle.kts` says `com.aerol.csecet`.
Everything in it that is checkbox-shaped is unticked.

---

## Section 3: Are the plans ready to execute?

Mostly yes. The shape is good and it is consistent.

**What 39 of 40 unexecuted plans already carry:** a stated Goal, an Architecture paragraph, a
Tech Stack line, a Global Constraints section restating the identity bans and the voice
rules, a File structure table naming every file and its responsibility, per-task
`**Files:**` and `**Interfaces:**` blocks, checkbox steps in test-first order, and a
verification block with the actual commands.

That is more context than most implementation plans carry, and it is why this audit found
conflicts between plans rather than holes inside them.

**Five things to fix before dispatching to Gemini implementors:**

1. **Only 3 of 40 plans cite `AGENTS.md`.** Every plan restates a subset of the rules in its
   Global Constraints, and no plan restates all of them. A cold implementor never reads the
   banned visual devices by name, the landmines, the "never invent a figure" rule in full, or
   the no-AI-attribution rule. **Add one required-reading line to every plan.**

2. **The banner names a harness-specific skill.** Thirty-nine plans open with "REQUIRED SUB-SKILL:
   Use superpowers:subagent-driven-development". A Gemini subagent has no such skill and will
   either ignore it or hallucinate around it. **Reword it to the plain instruction:** work one
   task at a time, write the failing test first, run the gates after each task, and stop and
   ask rather than invent.

3. **Five plans never name their spec by path**: `content-seed-delivery` (which has none, it
   is a repair) and `settings-02` through `settings-05`, which say "the spec" without saying
   which.

4. **`content-seed-delivery` Task 1 asserts the wrong SQLite header.** It expects
   `'SQLite format 3 '` with a trailing space; the real 16-byte magic ends in a NUL. The test
   as written fails at offset 15. Known since 2 August and still unfixed, and this plan is
   step 1 of the whole queue.

5. **No plan states the analyzer baseline.** It is 27 issues, all in `tools/` and
   `test/tool/`. An implementor running `flutter analyze` and finding 27 issues has no way to
   know whether it caused them. **State the baseline in the verification block.**

**One thing that is right and worth keeping:** every plan that depends on missing content
says what it renders in that content's absence. None of them fabricate a figure to fill a
gap. That is the constraint most likely to be broken by a fast model and the plans defend
against it well.

---

## Section 4: Recommended order of operations

1. Rule on C1 through C5. Nothing should be dispatched before C4 in particular.
2. Land the five readiness fixes in Section 3, which is a mechanical sweep across 39 files.
3. Rebuild `assets/seed/v1.json` so the ten authored reasoning files ship.
4. Decide Mathematics: static content plan, or launch without it.
5. Design the Pro specimen fallback, then plan the paywall.
6. Then dispatch, thread by thread.
