# The execution pipeline

**Created 3 August 2026**, on Aedwon's instruction to make the pipeline holistic, fluent and
robust. This is the single document a dispatcher reads before sending anything to an
implementor.

It supersedes the execution order in `2026-08-02-work-checkpoint.md`, which was written before
the Settings thread existed and before the six conflicts were ruled on.

**For the rounds that are not plans yet**, the design work still owed and the content plans
that do not exist, see `2026-08-03-next-rounds.md`. It carries a ready-to-paste prompt for
each one and a list of the decisions a model is waiting on.

**46 plans, roughly 210 tasks, none executed.** One plan in the directory,
`quiz-tab-01-storage-and-content-fields`, is already merged and is listed only where other
plans depend on it.

---

## Part 1: How to dispatch

**Every plan now opens with the same preamble.** It is model-agnostic: work task by task,
write the failing test first, read `AGENTS.md` in full before Task 1, do not redesign, stop
and say so on ambiguity, and the analyzer baseline is 27 issues all under `tools/`. Nothing in
it names a skill only one agent harness provides, so a Gemini implementor can follow it as
written.

**One plan per implementor. Never two plans at once against the same tree.** The collision map
in Part 4 is a list of things that break when two plans touch the same file, and it assumes
they run one after another.

**Verify the gates yourself.** The first background implementor run in this project overstated
its analyzer result, claiming zero new issues when there were nine, and wrote outside its
worktree leaving a half-applied `app_database.dart` that compiled. Run these after every plan
and read the output rather than the report:

```bash
flutter test
flutter analyze                      # expect 27, all under tools/ or test/tool/
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart    # expect 7, unchanged
dart run tool/check_no_ai_attribution.dart
```

**A plan that says "stop and say so" means it.** Six plans contain a step that is deliberately
blocked on a decision or a missing dependency. An implementor that invents its way past one of
those has produced something that looks finished and is wrong, which is more expensive than
the question would have been.

---

## Part 2: Phases

Phases are ordered. Everything inside a phase can run in parallel unless the thread table says
otherwise.

### Phase 0: Foundations. Nothing else should start first.

Four plans, 15 tasks. **None of them depends on any other plan in the repository**, and three
of them change how every later plan is verified.

| # | Plan | Tasks | Why first |
|---|---|---|---|
| F1 | `2026-08-03-foundations-01-observability.md` | 4 | Without the error boundary, every defect the next 40 plans introduce is invisible. Build this before the code that will break. |
| F2 | `2026-08-03-content-upgrade-seeder.md` | 5 | Until this lands, no content Aedwon generates reaches anyone who already has the app. It gates the value of every content pass. |
| F3 | `2026-08-03-foundations-02-app-check-and-force-update.md` | 3 | The force-update lever has to exist **before** the first public build, not after. Afterward is too late by definition. |
| F4 | `2026-08-03-offline-posture.md` | 3 | Its Task 1 changes `entitlementProvider`, which the paywall rebuild also touches. Doing it first means the paywall inherits the rule instead of overwriting it. |

**F1 and F2 are the two to run if only two run.**

### Phase 1: The seams everything reads

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| 1 | `2026-08-02-content-seed-delivery.md` | 2 | nothing. **Read spec Section 8 of the content-delivery spec first**: this plan owns `content.db` for blueprints and mocks, F2 owns `v1.json` for questions and lessons. |
| 2 | `2026-08-03-settings-01-the-kit.md` | 5 | nothing |
| 3 | `2026-08-03-settings-02-storage.md` | 4 | nothing. **Its Task 1 is struck**, see the C1 amendment. |
| 4 | `2026-08-02-quiz-tab-02a-frame-and-panel.md` | 3 | quiz-tab-01, merged. Builds `RuledPanel`, which Home and Progress both read. |
| 5 | `2026-08-02-study-01-foundations.md` | 7 | nothing. **Takes schema 15.** Confirm the current value is 14 first. |
| 6 | `2026-08-02-home-02-assessment-attempt-row.md` | 3 | nothing. A live defect as much as a prerequisite: the assessment writes no attempt row, so Progress is blind to its 21 questions. |

### Phase 2: The five threads

Five independent threads. Two people could run two threads. **Within a thread the order is a
chain unless stated.**

#### Onboarding and Settings, now merged into one thread

The C4 ruling folded six duplicated tasks out of onboarding and exam-switching into Settings,
so these are no longer independent.

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| A1 | `2026-08-02-onboarding-flow-and-new-steps.md` | 10 | Phase 1. **Its Task 1 is the canonical `ExamDate`** and gains `monthStart`. |
| A2 | `2026-07-25-onboarding-polish.md` | **9**, was 13 | A1, interleaved. **Tasks 3, 4, 5 and 6 are struck.** |
| A3 | `2026-08-03-settings-03-the-top-level.md` | 4 | Settings 01 and 02. Deletes the four Spec 8 widgets. |
| A4 | `2026-08-03-settings-04-the-sheets.md` | 5 | A3 |
| A5 | `2026-08-03-settings-05-the-exam-page.md` | 4 | A3. Absorbs work from both struck plans. |
| A6 | `2026-08-03-settings-06-about-and-the-pushed-pages.md` | 6 | A3 |
| A7 | `2026-08-02-exam-switching.md` | **2**, was 4 | A5. **Tasks 1 and 3 are struck.** |

#### Quiz

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| Q1 | `2026-08-02-quiz-tab-02b-session-panel.md` | 9 | Phase 1 #4. **Its settings page is struck**; it must still make the builder read `settings.session_ordering`. **Schedule this first after Settings ships**, or Settings shows three choices that change nothing. |
| Q2 | `2026-08-02-quiz-tab-03-practice-picker.md` | 8 | Phase 1 #4 |
| Q3 | `2026-08-02-quiz-tab-02c-mock-panel-and-rows.md` | 7 | Q1 |
| Q4 | `2026-08-02-quiz-tab-04-viewer-and-reveal.md` | 8 | Q2 |
| Q5 | `2026-08-02-quiz-tab-05-debrief.md` | 4 | Q4 |
| Q6 | `2026-08-02-quiz-tab-06-review-component.md` | 5 | Q3, Q4, Q5. **Now owns the review component outright.** |

#### Study

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| S2 | `2026-08-02-study-02-map.md` | 8 | Phase 1 #5 |
| S3a | `2026-08-02-study-03a-bookmarks.md` | 7 | S2 |
| S3b | `2026-08-02-study-03b-search.md` | 5 | S2. Independent of S3a. |
| S4 | `2026-08-02-study-04-reader.md` | 6 | S3a |
| S5 | `2026-08-02-study-05-endings.md` | 4 | S4 |

#### Home

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| H1 | `2026-08-02-home-01-bottom-navigation.md` | 2 | nothing |
| H3 | `2026-08-02-home-03-masthead-and-band.md` | 4 | Phase 1 #4, A1 for `ExamDate` and the name. **Builds the gear that is Settings' only entrance.** |
| H4 | `2026-08-02-home-04-up-next.md` | 2 | H3 |
| H5 | `2026-08-02-home-05-practice-panel.md` | 2 | H3, and Phase 1 #6 |
| H6 | `2026-08-02-home-06-tendencies.md` | 3 | H3 |

#### Progress

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| G1 | `2026-08-02-progress-01-frame-and-grammar.md` | 3 | Phase 1 #4. **Run first: it deletes machinery.** |
| G2 | `2026-08-02-progress-02-your-pace.md` | 2 | G1, A1 for `ExamDate` |
| G3 | `2026-08-02-progress-03-performance-table.md` | 5 | G1, Phase 1 #6 |
| G4 | `2026-08-02-progress-04-why-you-miss.md` | 2 | G1, Phase 1 #6, Q5 for the mistake tags |
| G5 | `2026-08-02-progress-05-how-you-work.md` | 3 | G1. Read H6 before writing strings. |
| G6 | `2026-08-02-progress-06-your-record.md` | 3 | G1 |

### Phase 3: What depends on two threads finishing

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| M1 | `2026-08-02-mock-01-the-paper.md` | 5 | Phase 1 #1, Q4 |
| M2 | `2026-08-02-mock-02-the-endings.md` | **3**, was 4 | M1, Q6. **Task 2 is struck.** |
| C1 | `2026-08-02-custom-track-a-branch-and-scope.md` | 6 | A1, Q1, Q2. **Takes schema 16.** |
| C2 | `2026-08-02-custom-track-b-student-built-mock.md` | 5 | C1, Q3. **Takes schema 17.** |
| N1 | `2026-08-03-notifications-countdown-and-comeback.md` | 4 | A1 for `ExamDate`, A4 for the reminder time |
| P1 | The paywall rebuild | not written | **Blocked on design**, see Part 3 |

### Phase 4: Last, deliberately

| # | Plan | Tasks | Waits on |
|---|---|---|---|
| Z1 | `2026-08-03-foundations-03-l10n-feedback-and-review.md` | 3 | H3 for the greeting, A6 for the feedback row |
| Z2 | `2026-08-03-foundations-04-accessibility.md` | 3 | **Everything.** Its Task 1 is a documentation sweep that should run in Phase 0; its Tasks 2 and 3 sweep a kit that must have stopped changing. |

**Z2 Task 1 is the exception and should be pulled forward into Phase 0.** It adds four
accessibility rules to the Global Constraints of every unexecuted UI plan, so components are
built right the first time and the sweep has less to find.

---

## Part 3: What is blocked, and on whom

| Blocked | On | Owner |
|---|---|---|
| The paywall plan | The Pro specimen fallback is undesigned: a student with no mock and few attempts cannot fill screen 1 | **A design round with Aedwon** |
| Taking money at all | `purchases_flutter` is imported by zero files in `lib/`; the only `RevenueCatGateway` is `DisabledRevenueCatGateway`, whose `purchase()` returns Free | Belongs in the same plan as the paywall rebuild |
| Complete mock papers for 5 of 7 exams | Zero Mathematics questions, and no content plan for them | **Aedwon**, who owns content generation |
| Three blueprints | `sectionalTiming` for ACET, DCAT, MSU-SASE | **Aedwon** |
| The reader coda, lesson selection, the Lesson level of Progress | `lessonId` on all 1,117 questions, currently zero | **Aedwon** |
| Note B on the reveal, the debrief's second sentence | A rationale per choice, currently zero | **Aedwon** |
| The study plan feature | Spec and plan both predate the identity; providers throw | **A design round with Aedwon** |
| Mock setup, pause, forfeit, transitions, overlays, history | Sketched by Spec 5 in May, never redrawn | **A design round with Aedwon** |
| The feedback row's destination | A real support address | **Aedwon** |
| `in_app_review` and `url_launcher` | Both needed, neither in `pubspec.yaml`, and plans forbid adding dependencies | **Aedwon**, one decision covering both |

---

## Part 4: The collision map

Things that break when two plans touch them. **Read the row before dispatching either plan.**

### Resolved on 3 August, recorded so nobody re-derives them

| Was | Ruling |
|---|---|
| `ExamDate` defined twice | One type, onboarding-flow Task 1 is canonical, plus `monthStart`. Settings 02 Task 1 struck. |
| Schema version 15 claimed twice | Study 01 = 15, custom-track-a = 16, custom-track-b = 17. Each confirms the current value first. |
| Two review components in `core/ui` | Quiz 6 owns it. Mock 02 Task 2 struck, keeps `score_headline` and `exam_marks_offer`. |
| Settings duplicating six tasks | Struck from onboarding-polish (3, 4, 5, 6) and exam-switching (1, 3), folded into Settings. |
| `/settings/sessions` vs `/settings/ordering` | Quiz 2b's page struck. It keeps only the read of `settings.session_ordering`. |

### Still live. Whichever plan runs second must collapse the duplicate.

| Symbol | Named by | The failure if ignored |
|---|---|---|
| `topicAccuracyProvider` | **H4, H5 and G3.** Three plans, not two. | Home calls a topic weak and Progress calls it strong. |
| `severityFor` | H5 defines it, G3 moves it to `lib/core/ui/severity.dart` | Two colorings of the same figure. |
| `InkCheckbox` | Created by S3a. Referenced by Q2, Q5 and custom-track A. | Two checkboxes, or three. |
| `InkTableRow` | Changed by S1 Task 7 and again by S3a Task 3. Read by Q3 and Home. | The second change reverts the first. |
| `RuledPanel` | Created by Q (2a), modified by H3 | Fine if ordered. |
| `StatsBand` | Modified by Q1 and H3 | Fine if ordered. |
| `entitlementProvider` | F4 Task 1, and the paywall rebuild | **The paywall must not undo the cached-wins rule.** A paying student loses Pro in a dead zone. |
| `lib/app/router.dart` | **25 plans** | Mechanical, but every one of them adds routes. Merge conflicts, not logic errors. |

---

## Part 5: The health of the pipeline, measured today

| Check | Result |
|---|---|
| Plans carrying the model-agnostic preamble | **47 of 47** |
| Plans citing `AGENTS.md` as required reading | **47 of 47**, was 3 |
| Plans citing their source spec by path | **47 of 47**, was 42 |
| Plans stating the analyzer baseline | **47 of 47**, was 0 |
| Plans with a Goal, Global Constraints, a file table and per-task interfaces | 47 of 47 |
| Plans with test-first steps | 47 of 47 |
| Known conflicts between plans | **0 unresolved**, was 6 |
| `flutter analyze` | 27 issues, all under `tools/` or `test/tool/`. `lib/` clean. |
| `flutter test` | 273 test files |
| Layering violations | 7, the accepted baseline |

---

## Part 6: If you only do five things

1. **F1**, the error boundary. Everything after it is debuggable and nothing before it is.
2. **F2**, the seeder upgrade. Without it Aedwon's content generation reaches nobody.
3. **Design the Pro specimen fallback, then plan and build the paywall including the live
   gateway.** The app cannot currently take money.
4. **Phase 1**, the six seams. Every thread in Phase 2 reads one of them.
5. **Decide Mathematics.** Five of seven exams cannot assemble a mock paper without it.
