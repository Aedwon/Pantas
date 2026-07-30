# The execution pipeline

**The single document a dispatcher reads before sending anything to an implementor.**
**Rewritten 4 August 2026**, after a day in which four worktrees merged, three design rounds
closed, five plans were written and every plan was audited for contradictions.
**Parts 0, 1, 2, 4 and 10 rewritten 8 August**, after the paywall, the passage pipeline, reading
comprehension, General Information, the em dash sweep and the quiz frame all landed.

It supersedes the execution order in `2026-08-02-work-checkpoint.md`.

**Companions.** `SUBAGENTS.md` is the contract a dispatched run works under, Part 7b for the
verifier tier. `2026-08-03-execution-resourcing.md` says who runs what and sizes the beta.
`2026-08-04-plan-consistency-audit.md` is what an audit across all 89 plans found and fixed.
`2026-08-03-launch-checklist.md` is everything between here and a paid install.

---

## Part 1: The three tiers

| Tier | Model | Work |
|---|---|---|
| **C** | Claude | Design rounds, specs, conflict rulings, merge decisions, the money path. |
| **P** | Gemini 3.1 Pro | **Verifies F.** Implements schema, sync and entitlement. |
| **F** | Gemini 3.6 Flash | Bulk generation and assembly. |

**Every item below carries its tier.** A verifier reports evidence and never fixes what it
finds: `SUBAGENTS.md` Part 7b.

### The dispatch line

```
Execute `docs/superpowers/plans/<PLAN>.md`, <scope>.
Follow `SUBAGENTS.md`, Part 4 for content or Parts 3 and 5 for code.

Never run `flutter test` with no arguments. Never run `flutter analyze`. Never run
`dart run build_runner`. You may run a single test file, which takes seconds. The full
gate set is run for you after you finish. Never use `&`, `nohup`, or any background
task mechanism.

Work only inside this worktree. Run `pwd` before your first write.
Commit the moment a task's own test passes, before starting the next one.
Report what you completed and any findings.
```

**Every line there was learned expensively.**

- **The ban on long commands replaced "run them in the foreground", which did not work.** That
  wording was in every prompt on 4 and 5 August and was ignored repeatedly: runs launched
  `flutter test`, idled, and timed out with everything uncommitted. **Banning the commands
  outright fixed it on the first try and has not failed since.**
- **"Work only inside this worktree" is not decoration.** On 5 August an agent committed twice
  directly into the main checkout, and it surfaced only when a branch came to merge and sixteen
  files conflicted.
- **"Commit per task" is what makes an interrupted run cheap.** The paywall plan timed out three
  times; the runs that committed per task lost nothing, and the one that did not lost everything.

### Quota, which cannot be checked automatically

**`agy` exposes no usage command and nothing on disk records it.** Verified 4 August rather than
assumed. The only signals are Aedwon's reading of it and an error back from the CLI.

- **Ask him for headroom before each wave.**
- **Below roughly a quarter left, do not start a plan with unfinished tasks.** A run that dies
  mid-task strands its work, which is what cost most of 4 August.
- **When headroom is thin, do the zero-Gemini work instead:** verify and merge finished
  worktrees, rebuild the seed, or design.
- **Confirm which way a percentage runs.** "At 20%" meant 20% consumed; "at 81%" meant 81%
  remaining. Both were misread on 4 August, in opposite directions.

### Dispatching, mechanically

**Never dispatch through a subagent.** The permission classifier refuses the required flag
inside a subagent's context and the run stalls every time, whatever the prompt says. **Dispatch
directly from the orchestrator**, one git worktree per plan.

---

## Part 0: Pick up here

**Rewritten 11 August, end of day.** `main` is pushed and green. **2,245 tests
pass**, analyzer clean, `check_layering` OK, `check_no_ai_attribution` OK.

### Read this before anything else

**`AGENTS.md`, the section "How to talk to Aedwon".** He said on 11 August that he
skips replies because of how they are written. That is now the first rule, ahead of
length. Two more rules went in with it: answer a question and stop rather than
starting work, and read a feature's plan and spec in full before touching it.

### What is running

- The Android emulator and one `flutter run`. Hot restart is `kill -USR2` on the
  pid from `pgrep -f "flutter_tools.snapshot run"`.
- **Aedwon is configuring Firebase and RevenueCat by hand.** Do not create Firebase
  options files or fill the empty adapter bodies. He is doing that.

### Done 11 August

| | What |
|---|---|
| **Content 02** | Repaired and merged. Five parts of the app still read the corpus from the user database. Custom track creation failed silently |
| **Reasoning and General Information** | Reasoning left UPCAT. Six unmapped topics mapped. 2,000 questions to 2,216, 144 lessons to 161 |
| **Content 04** | All tasks. Both doors, the empty state, a paper sat end to end, results in Progress |
| **Bookmarks, mock review, session-building page** | Merged |
| **The app is Pantas** | Package, launcher label, and one store identity, `com.aedwon.pantas`. The database file is `pantas.db` |
| **The consent step** | Terms required, usage optional and off by default, third in onboarding |
| **Firebase packages** | Up one major, all ten, before wiring |
| **Yearly price** | ₱999 to ₱799, and the recommendation boundary moved with it |

### What to do next

1. **`purchases_flutter` 8 to 10.** Before the Play products exist.
2. **The encryption group.** `sqlcipher_flutter_libs` is end of life and does
   nothing from 0.7.0. It goes with drift and sqlite3 and the move to
   SQLite3MultipleCiphers, one change or none. Lower risk than it sounds now: the
   database rename left no data to migrate, and the opener already fails closed.
3. **Telemetry Task 2**, `question_answered`. One call site. Task 3 is deferred.
4. **Riverpod 3, go_router 17, freezed 3**, one branch each. The linter last.

Everything is in `2026-08-11-dependency-audit.md` and
`plans/2026-08-11-telemetry-02-consent-and-item-analytics.md`.

### Blocked on Aedwon

- **The device check.** His attempt history still resolving, Progress showing rows,
  a custom track appearing after he makes one. No test can claim it.
- **Firebase and RevenueCat setup.** In progress.
- **`url_launcher` and `in_app_review`**, each blocking a written task.
- **The CSE blueprint.** A subject belongs to one exam, so CSE Professional cannot
  show Numerical Ability while that content sits under UPCAT's Mathematics. Its
  figures are verified and recorded. Fixing it is a schema stage.

### Two stale worktrees, not live work

`agent-a22d3d5ddf2a5a2a9` and `/private/tmp/seedcheck` both have uncommitted files
from before 11 August. Both are superseded by the content work that has since
merged. Delete them or ignore them.

### First, two things a new session must know

1. **Ask for Gemini headroom and re-authorize the skip-permissions flag** before dispatching
   anything. Both are per session and neither can be read programmatically.
2. **While Aedwon is testing on the emulator, every change ends: gates, commit, push, hot
   restart.** He asked for that explicitly. Hot restart is `kill -USR2 <pid>` where the pid is
   `pgrep -f "flutter_tools.snapshot run"`. **Never restart onto a red suite.**

### What is running

- **The Android emulator** (`pantas_pixel`) and **one `flutter run`** own the app on screen.
  The run process is what hot restart signals; killing it costs a full rebuild.
- **iPhone testing is set up except for a cable.** Xcode, its licence, the platform components,
  CocoaPods and the iOS pods are all done. It needs a USB-C cable for the one-time pairing and
  Aedwon's Apple ID selected as the team in Xcode. Free provisioning expires every 7 days and
  never does push.

### CI, and the one thing blocking it

**CI had failed on every push for weeks and nobody had looked.** Two causes are fixed: the
workflows never ran `build_runner` or `gen-l10n`, and they never built the gitignored
`assets/seed/content.db`. Both now happen before `flutter analyze`.

**The third cause, `dart run tool/check_layering.dart` exiting 1 on 36 violations, is closed.**
`2026-08-10-layering-rule-log.md` has the round. R2 now reads: **a feature may import another
feature's domain, application or data layer, and never its `presentation/`**, a barrel counting
as presentation because every barrel re-exports it. **32 of the 36 were legitimate under that
rule and 4 were real misfilings**, all fixed. `check_layering: OK`.

### Aedwon's UI findings

**`docs/ui-audit.md` is the record**, his words verbatim, with what the code said under each.
UI-012 through UI-034 came from one evening on the emulator.

**Fixed and shipped:** the quiz's missing reveal and its grid navigation, the dead settings
link, the pinned footer, the double back arrow, the caret direction, the post-answer toast,
passage sets answered in one run, the debrief's empty band, the greeting and masthead, the
stats band centring, panel actions on the margin, the tendency indicator, inline maths size and
baseline, raw dollar signs, list numbering through a formula, chevron alignment, the dropdown
displacement, and the Quiz tab's spacing.

**UI-012 through UI-064 are recorded there**, and most of 035 to 064 were fixed on 11 August:
the peso escaping in the choices, the reader's jank, the slow debrief, the pile of open
sessions, the pull to advance and everything around it, one tab header for three tabs, and the
Performance and Why you miss sections.

**Two corrections a new session must not repeat**, both of which cost time here:

- **The navigation glyphs were never stock Material.** This document said they were. They are
  painted paths, and the quiz glyph was decided **twice**: the second round, `quiz-glyph-v2`,
  chose three options and rules over the single bubble, and sat unbuilt for two weeks.
  **A decision can live in a companion session log and nowhere else.** Grep
  `.superpowers/brainstorm/*/state/server.log` before saying a UI matches its spec.
- **The serif is gone.** One family everywhere since 11 August: `decisions/2026-08-10-typeface-log.md`.

### What is left, and none of it is code

| | What | Why it cannot be dispatched |
|---|---|---|
| 1 | **Approve the 2,369 questions** | **Read `docs/content/audit/questions.md` first.** Nothing reads the `approved` flag, and 1,259 questions already carry it |
| 2 | **Firebase** | Nothing exists. `docs/firebase-setup.md` is the whole list |
| 3 | **The store side of the paywall** | Dashboard, products, a signed build |
| 4 | **The feedback row** | Needs the community group URL and a contact email |
| 5 | **11 Geometry figures, 40 formula findings** | Hand-made pictures, and a set that is partly noise |

### What is actually unexecuted, audited 11 August

**"Every written plan is executed" was not true**, and this is the second time
that claim has cost a session. Checked by looking for the artifacts each plan
was meant to produce, not by reading the plans.

**`2026-08-02-onboarding-flow-and-new-steps.md` is half built.** Tasks 1 and 2
landed, so `ExamDate` and the name's storage exist. **Tasks 3, 4, 5, 6, 9 and
10 did not.** Verified by symbol: `OnboardingNameStep`, `OnboardingExamDateStep`
and `acceptedTerms` do not exist anywhere in `lib/`, there is no onboarding
completion flag, and the router still gates on the age gate and exam selection
rather than on completion.

**What that means for a student:** onboarding is welcome, age gate, exam
picker. **Nobody is ever asked their name or their exam date**, though both are
settable in Settings, and **nothing records acceptance of the Terms and Privacy
Policy**. Home's masthead and its countdown are reading fields no one is asked
to fill, which is where UI-013 came from.

**The passage pipeline's Tasks 5 and 6 are done**, contrary to Part 2 below.
`test/features/quiz/passage_regression_test.dart` carries both the Task 5 group
and the no-passage regressions.

**`NotBuiltYetPage` has no callers.** Dead since Settings was built.

---

**The content path is half executed as of 11 August.** `01` and `01b` are merged: the
content database now carries the real corpus, 2,000 questions, 144 lessons, 19 topics
and 32 passages, and a question carries its lesson and its passage. **`02` is running,
`03` and `04` follow.** The one that can orphan a student's history is `02`, and its
done-condition needs a device with real attempts, which is Aedwon's.

**Onboarding's six unexecuted tasks are merged**: a student is asked their name and
their exam date now, and acceptance of the Terms is recorded.

**Two questions are waiting on him**, both written up with data rather than left as
opinions: whether Reasoning stays a UPCAT subject when not one of its 64 questions is
tagged for UPCAT, and the six authored topics missing from the outline.

The original plan text follows: `specs/2026-08-11-content-path-and-the-mock.md`, then
plans `2026-08-11-content-01` through `04`, in that order, each merged before
the next starts. **Content 02 is the one that can lose a student's history**, so
its ids rule is not negotiable. It ends with a student able to sit a full UPCAT
paper, which nobody can do today.

**One chore is written and unplanned:** `2026-08-10-name-cleanup-chore.md`, retiring "CSE/CET
Reviewer" for Pantas. **Its Tier 2, the Android and iOS identifiers, can only be done before the
first store submission**, so it is a dependency of item 3 rather than a tidy-up.

### Open questions waiting on Aedwon

- **The four shared tendencies are written twice**, once per screen, and nothing keeps them
  matched.
- **The quality pass on the questions**, which he asked to schedule and which has not been.

## Part 2: Done, so it stops being re-planned

| | State |
|---|---|
| **Foundations 01**, all four tasks | **Merged.** Error boundary, telemetry seam, consent gate, and the eleven events with `CrashReporter` absorbed. |
| **The exam date with its precision** | **Merged.** Onboarding Task 1. This was the single most blocking piece in the queue: eight plans read it. |
| **The kit, with the five missing type sizes** | **Merged.** `AppTextStyles` gains 24, 16, 14/700, 13/400 and 11.5, `headlineSmall` stays at 15, and `InkPlateRule` exists. Four plans were stopping without these. |
| **The content upgrade seeder** | **Merged.** Schema **17**. A content fix now reaches an installed app without touching a student's progress. |
| **The assessment attempt row** | **Merged.** The defect is fixed, and untimed attempts are kept out of every speed figure. |
| **The seed, rebuilt** | **1,117 questions to 1,840.** It was dated 25 July and 876 behind the corpus. |
| **Content delivery** | **Merged 4 August.** The corpus now reaches a release build. This was the thing everything else was waiting behind. |
| **Study 01 foundations** | **Merged 4 August.** `schemaVersion` **16**, bookmarks, lesson ordering, `InkTableRow`'s chevron and gutter. |
| **Offline posture** | **Merged 4 August.** The cached-wins entitlement rule is live: a paying student keeps Pro in a dead zone. |
| **Mathematics** | **Complete, 689 questions across all 44 subtopics.** |
| **Six plan conflicts, the readiness sweep, the attribution gate, the validator** | As before. |
| **The passage pipeline** | **Merged 4 August, Tasks 1 to 4.** Passages table, schema **18**, the YAML and seed carry them, and a passage set is indivisible in both the picker and the mock sampler. ~~Tasks 5 and 6 remain~~ **Both landed**, verified 11 August |
| **The CSE tagging pass** | **Merged 4 August.** 38 files carry `cse-pro`, 30 of them `cse-sub`, no Science file touched. The CSE goes from 2 questions to most of its verbal, analytical and numerical paper |
| **Reading comprehension** | **Merged 4 August.** All 13 subtopics, 32 passages, **160 questions**, after a revision pass fixed the correct answer being the longest choice in 120 of them |
| **The choice-order defect** | **Fixed 4 August.** The correct answer was first in **2,072 of 2,153 questions**, and choices were never shuffled. A question's choices are now ordered from its id when read. **Do not hand-vary answer position in new content** |
| **The em dash** | **Gone 5 August.** 1,402 in questions and 418 in lessons, now zero, and **the content validator rejects one** in a stem, explanation, choice, passage title or body. The en dash is untouched: it is correct in a range |
| **The paywall, all six tasks** | **Merged 5 August.** The app can take money. A real gateway, selected by config, with the numeric price carried from the store's own field rather than parsed from a formatted string |
| **The paywall's three screens** | **Merged 5 August.** Screen 1 reads no student data at all. A student who gave only a month is never shown a day count |
| **General Information** | **Merged 8 August.** 216 questions across the Code of Conduct, the Constitution, peace and human rights, and environment, every one written against a file in `content/reference/cse/` |
| **The lesson link** | **Merged 5 August.** 1,998 of 2,000 seeded questions carry their lesson and none dangles. The two without are CSE demo rows, not authored content |
| **The quiz frame** | **Merged 8 August.** The tab no longer shows a student a stack trace, and the dead drill route is gone |

**Corpus today:** Science 777, Mathematics 713, Language 319, Reasoning 244, Reading
comprehension 160, General Information 156. **Total 2,369.**

**Health on `main`, measured 8 August:** **1,206 tests pass**, schema **18**, zero analyzer issues under `lib/` and `test/`
outside `test/tool/`, formatter clean, layering 8, attribution 0, content validator 0, content
audit **0 blockers**.

**Layering moved from 7 to 8 deliberately.** The paywall reads the settings providers, which is
the same shape as the seven that were already tolerated. `ExamDate` moved to `core/` at the same
time, because it is a pure value type with no settings dependency and three features read it:
that removed two violations rather than tolerating them.

---

## Part 3: The two that unblock everything else

**Found by the 4 August audit. Neither was called out anywhere, and both are small.**

| | Plan | Tier | Why first |
|---|---|---|---|
| **X1** | `onboarding-flow-and-new-steps.md` **Task 1 only** | **P** | Creates the exam date with its precision. **Eight plans read it.** The study plan and paywall 02 stop dead without it |
| **X2** | `settings-01-the-kit.md` | **F** | Adds five type sizes that do not exist. **Four plans stop and say so** without them |

**Run these before Lane C. They are cheap and they gate about a third of the queue.**

---

## Part 4: Then, in this order

### 1. Finish what is in flight

| | Plan | Tier | State |
|---|---|---|---|
| 1a | `foundations-01` **Task 4** | F | **Merged.** Nothing is in flight |

### 2. The rest of the content path

| | Plan | Tier | Notes |
|---|---|---|---|
| 2a | `content-upgrade-seeder.md` | **P** | Reads the live schema, takes the next number |
| 2b | `passage-pipeline.md` | **P** | **Tasks 1 to 4 merged.** Task 5 needs Quiz 4; Task 6 was dropped alongside it and needs no dependency |
| 2c | `question-generation-reading-comprehension.md` | **F** | Two agents, different directories. Reading comprehension is at zero and ships in v1 |
| 2d | `content-three-passes.md` | **F**, Task 1 is **P** | The lesson link is derivable and needs no authoring. The reasons and labels are a generation pass |
| 2e | `cse-content.md` **Task 1 only** | **F** | A tagging pass with no authoring. **Takes the CSE from 2 questions to most of its verbal, analytical and numerical paper.** Highest value per unit of work left in the queue |
| 2f | `cse-content.md` Tasks 2 to 5 | **F** | General Information and the small gaps. **Every question is written against a file in `content/reference/`** |

### 3. The money path, done

| | Plan | State |
|---|---|---|
| 3a | `paywall-01-ladder-and-live-gateway.md` | **Merged 5 August**, all six tasks |
| 3b | `paywall-02-the-three-screens.md` | **Merged 5 August**, all five tasks |

**The app can take money.** Both plans are closed. What remains before a student can actually
pay is not code: the RevenueCat dashboard, the store products, and a signed build.

---

## Part 5: The parallel lanes

**Nothing in one lane blocks another.**

### Lane A: Finish Phase 0

| | Plan | Tier | Waits on |
|---|---|---|---|
| A1 | `foundations-02-app-check-and-force-update.md` | **P** | nothing |
| A2 | `foundations-04` **Task 1** | F | nothing. It is documentation: it puts four accessibility rules into every unexecuted UI plan |

### Lane B: The seams every UI thread reads

| | Plan | Tier |
|---|---|---|
| B1 | `settings-02-storage.md` | **F** |
| B2 | `quiz-tab-02a-frame-and-panel.md` | **F** |
| B3 | `home-02-assessment-attempt-row.md` | **F** |

**B3 is a live defect:** the assessment writes no attempt row, so Progress is blind to its 21
questions.

### Lane C: The UI threads, after Lane B

Each is a chain. **One agent per plan, in order, with a P verifier between links.**

- **Onboarding and Settings:** onboarding-flow (the rest) → onboarding-polish → settings-03 →
  04 → 05 → 06 → exam-switching. All **F**.
- **Quiz:** 02b (**P**, selector wiring) → 02c → 03 → 04 → 05 → 06. Rest **F**.
- **Study:** 02 → 03a and 03b in parallel → 04 → 05. All **F**.
- **Home:** 01 → 03 → **05** → 04, 06. All **F**. **Corrected 4 August:** Plan 5 owns
  `topicAccuracyProvider` and Plan 4 reads it. In parallel, both find it absent and both write a
  ranking, which is the collision map's own warning happening for real.
- **Progress:** G1 first, it deletes machinery → G2 to G6 in parallel. All **F**.
- **Study plan:** `study-plan-forward-calendar.md`, **after X1**. **F**.
- **Mock:** mock-01 → mock-02 → **mock-03**. All **F**, after X2.

### Lane D: Content, always parallel-safe

**Content agents write `content/` and `assets/seed/`; code agents write `lib/` and `test/`.**
They never conflict.

---

## Part 6: Last

| | Plan | Tier | Waits on |
|---|---|---|---|
| Z1 | `custom-track-a`, then `custom-track-b` | **P** | Lane C. **Both now read the live schema rather than expecting a number** |
| Z2 | `notifications-countdown-and-comeback.md` | F | X1, onboarding, settings-04 |
| Z3 | `foundations-03-l10n-feedback-and-review.md` | F | home-03, settings-06, **and one dependency decision** |
| Z4 | `foundations-04` Tasks 2 and 3 | F | the kit has stopped changing |

---

## Part 7: Needs Claude, not an agent

**All three design rounds closed on 4 August.** What is left here is smaller than it was.

| | Why it is tier C |
|---|---|
| **Any finding a verifier reports**, and any "stop and say so" an implementor hits | Six plans carry one deliberately |
| **Merge decisions and conflict rulings** | Never let an agent resolve a router conflict |
| **The Pro specimen's authored figures** | The design is settled; the sample's own numbers still need choosing and they must never read as measured |

**Closed 4 August:** the Pro specimen fallback and the paywall plan, the study plan, and the
mock's five missing screens.

---

## Part 8: Blocked on Aedwon

| Blocked | On |
|---|---|
| `url_launcher` and `in_app_review` | Two decisions, not one. `url_launcher` is needed by the feedback row **and** the force-update button, and there is no alternative. `in_app_review` only pops a rating prompt and is deferred out of the beta anyway |
| The feedback row | The community group URL, plus a developer contact email Play requires separately |
| Question approval | Every generated file has `approved:` unset by design. Question Studio is yours |
| Illustrations | 11 Geometry figure slugs are logged with described stems, so nothing is blocked, but the pictures are yours |
| **ACET's aptitude timing** | Derived from a rate, not published. It implies 12 seconds an item. **Confirm before that blueprint ships** |
| **Firebase is never initialized** | **Added 9 August, and it was only in the launch checklist before.** The SDK boot adapter's `initialize` is an empty body: auth, sync, crash reporting and App Check are all inert until the Firebase projects exist and `flutterfire configure` has run. **Nothing in `lib/` imports the four Firebase packages in `pubspec.yaml`.** A thing everyone knows and nobody reads is only half tracked, which is why it is here now |

**Closed 4 August:** `sectionalTiming` for all three exams.

---

## Part 9: The collision map

**Read the row before dispatching either plan.**

| Symbol | Named by | The failure if ignored |
|---|---|---|
| `topicAccuracyProvider` | **H5 owns it.** H4 and G3 read it | **Ordered on 4 August.** Run H4 in parallel with H5 and both write a ranking |
| `severityFor` | H5 defines, G3 moves it | Two colorings of one figure |
| `InkCheckbox` | Created by study-03a; referenced by Quiz 3, 5 and custom-track A | Two checkboxes, or three |
| `entitlementProvider` | **Owned by offline posture, now merged.** Both paywall plans say do not touch it | The paywall must not undo the cached-wins rule |
| `seeder.dart` | content delivery, now merged, and the upgrade seeder | Order matters |
| `schemaVersion` | **No plan names a number any more.** Every one reads the live value and takes the next | **Assigned numbers rot, twice now** |
| `AppTextStyles` | X2 owns it. Four plans stop without it | Hand-rolled sizes that disagree with the kit |
| `lib/app/router.dart` | **25 plans** | Merge noise, not logic. Never let an agent resolve a router conflict |

---

## Part 10: If you only do five things

**Rewritten 8 August. The old five are all done.**

1. **Approve the generated questions.** 2,369 of them, every one with `approved:` unset by
   design. **Nothing ships unapproved and it is the one step no agent can do.** This is now the
   single largest thing standing between the corpus and a student.
2. **Finish the quiz chain**, which is the tab a student spends their time in and the longest
   unbuilt thread left.
3. **The store side of the paywall.** The code is done; the dashboard, the products and a signed
   build are not, and none of them are an agent's job.
4. **The 11 Geometry figures and the illustration worklist.** Questions are logged with described
   stems and the pictures are hand-made, so nothing is blocked and nothing is finished.
5. **Triage the 40 formula findings** before sending them anywhere. Part of that set is noise.
