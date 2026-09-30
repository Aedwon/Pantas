# Adaptive Roadmap Engine Implementation Plan

> **For agentic workers:** Read `AGENTS.md`, `WORKFLOW.md` and `SUBAGENTS.md` from `origin/main`
> first, then this plan end to end, then the spec. Execute one task at a time, in order, test
> first. Steps use checkbox (`- [ ]`) syntax for tracking. Stop conditions in `SUBAGENTS.md`
> Part 6 apply to every task.

**Goal:** Replace the fixed daily amounts (10 new questions, 3 lessons) with one engine that
builds each day from the exam date, the student's progress and their results, and make today's
quiz session, Home's Up next and daily reminders read it.

**Spec:** `docs/superpowers/specs/2026-09-30-adaptive-roadmap-design.md` (Part 1 approved by
Aedwon, 30 September 2026; Part 2 is the technical contract). Decisions:
`docs/superpowers/decisions/2026-09-30-adaptive-roadmap-log.md`.

**Complexity:** balanced (Aedwon, 30 September 2026).

**Architecture:** A pure, synchronous domain core in `lib/features/roadmap/domain/` computes a
`Roadmap` from `RoadmapInputs`. A thin application layer gathers inputs from existing
repositories (metadata only), persists one day snapshot per local day, logs changes, and feeds
the existing Today launch path (`TodayQuizPreparer` / `QuizLaunchCoordinator`) through its
`TodayPlanBuilder` seam. Nothing new is built where an existing part already does the job.

**Tech stack:** Flutter/Dart, Riverpod, drift (app database schema 24 → 25), freezed where the
surrounding code uses it, existing FSRS scheduler, existing sync engine.

---

## Global constraints

Every task's requirements include these. Values are copied from the spec.

- **Code branch:** new branch `web/roadmap-engine-r1` from `origin/web/e09-qlp5-prepared-next-r1`
  at `13938943f447956af43d2de7e1f9999eb2418aee`. Worktree:
  `/Users/aedwon/Documents/Projects/Pantas-wt-web-roadmap-engine-r1`. Never write to the main
  checkout or any other worktree.
- **Engineering pause:** no task in this plan starts until Aedwon explicitly lifts the E09 stop
  for this work. Writing this plan does not lift it.
- **Never invent a figure** (`AGENTS.md`). The engine produces counts and dates only from the
  student's data, the exam date and the named arithmetic in spec 4.2. No projections, no
  percentages of readiness, nothing about weeks after the current one except topic ids and the
  two dates `reviewOnlyFrom` and `mockDay`.
- **Banned words in any string the student can see, and in roadmap identifiers used as copy:**
  "behind", "ahead", "on track", "ready", "mastery". Also never "FSRS", "stability",
  "retention", "retrievability", "algorithm" in a user-facing string.
- **Day boundary:** local midnight, the same as streaks.
- **Pacing (spec 4.2):** `quiet = min(7, floor(daysLeft / 4))`; `workingDays = daysLeft - quiet`;
  `reviewOnlyFrom = examDay - quiet`; `lessonsToday = ceil(lessonsLeft / workingDays)` and
  `newToday = ceil(unseenLeft / workingDays)` when `workingDays > 0`, else 0. Month precision
  plans to the first of the month while that month has not started.
- **Metadata only (QLP-1):** the roadmap never hydrates stems, choices, explanations, figures or
  lesson bodies. Questions come from `ContentRepository.selectionRowsByTopics`; lessons from the
  new lightweight query in Task 2. No per-question queries, no unbounded `Future.wait`.
- **Launch path (QLP-2 to QLP-4):** today's sitting is prepared by `TodayQuizPreparer` and started
  by `QuizLaunchCoordinator`. Do not add another launch path.
- **Performance budget (QLP-5):** first recommendation p95 at most 1,000 ms; warm Start p95 at most
  500 ms; prepared Next p95 at most 100 ms; no regression against the recorded `8cbaaeea`
  metrics. Build the roadmap once per local day and per trigger; later reads use the snapshot.
- **Protected content package unchanged.** No edit under `content/`, no `releaseSequence`
  change, no change to the content digest, manifest or signature. Prerequisite links live in
  the app (Task 3).
- **Schema:** `AppDatabase.schemaVersion` is 24 on the base. This plan raises it to 25 once, in
  Task 10, with its migration in the same commit.
- **Generated files** (`*.g.dart`, `*.freezed.dart`) are regenerated with
  `dart run build_runner build --delete-conflicting-outputs`, never edited, never committed.
- **No new dependencies.** Do not edit `pubspec.yaml`.
- **Layering:** `lib/core/**` never imports `lib/features/**`; features never import another
  feature's `presentation/`; `domain/` never imports flutter, riverpod, drift or firebase.
  Check with `dart run tool/check_layering.dart`.
- **Voice:** American spelling, no em dashes, in code comments too.
- **Commits:** message says why. No attribution trailer or marker of any kind.
- **UI:** no new screen, control or layout change. Where the spec needs one, it is listed under
  "Deferred to the UI round" and is not built here. Existing panels keep their layout and show
  the engine's numbers.
- **Do not deploy** Firestore rules, indexes or Cloud Functions. Edit and test them locally only.
  Deployment is a separate authorized step.

---

## Reuse of E09 work

Aedwon asked whether work done through E09 can be reused. It is, almost entirely:

- **Kept as is:** everything integrated on the E09 candidate (E02 repairs, protected content
  storage E04, content protection audit E07, metadata selection and batched hydration QLP-1,
  prepared launch, readiness and freshness QLP-2 to QLP-4). This plan builds on that branch and
  plugs into those parts rather than replacing them.
- **Still valid after this work:** CP-T5 source and device proof of the protected content
  (content identity is unchanged by design), and the QLP-6 test and analysis gates as a method.
- **Must be rerun on the new candidate** (Readiness SSOT rule: any source change reruns affected
  evidence): E09 functional scenarios #22 to #28 (at least #23, which asserted the old
  "4 due · 6 new · 10 questions" panel), QLP-5 device performance, QLP-6 gates, the focused
  CP-T5 source matrix (cheap, confirms nothing regressed). E10 onward follows as already
  planned in the SSOT.

---

## Dependencies and order

| Task | Depends on | Executor | Effort |
|---|---|---|---|
| 0 Baseline | Aedwon lifts the stop | Lead | n/a |
| 1 Shared local day, public retrievability | 0 | Codex `gpt-6-luna` | medium |
| 2 Lesson metadata query | 0 | Codex `gpt-6-luna` | medium |
| 3 Prerequisite map and audit | 0 | Codex `gpt-6.1-sol`; Aedwon or reviewer approves links | high |
| 4 Domain types, planning window, pacing | 1 | Codex `gpt-6.1-sol` | high |
| 5 Topic order | 4 | Lead writes or reviews line by line | high |
| 6 Day selection, reviews, backlog cap | 4, 5 | Lead writes or reviews line by line | high |
| 7 Mock day | 4 | Codex `gpt-6.1-sol` | high |
| 8 Week preview, assembly, coverage property | 5, 6, 7 | Lead writes or reviews line by line | high |
| 9 Change diff, advance, partial advance | 8 | Lead writes or reviews line by line | high |
| 10 Schema 25, day and log repositories | 9 | Codex `gpt-6.1-sol` | high |
| 11 Change log sync (Pro) | DEFERRED 1 Oct 2026 (release cut); not in this build | n/a | n/a |
| 12 Inputs reader and roadmap provider | 2, 3, 10 | Codex `gpt-6.1-sol` | high |
| 13 Sitting planner | 8 | Codex `gpt-6.1-sol` | high |
| 14 Today launch path on the roadmap | 12, 13 | Codex `gpt-6.1-sol`; lead reviews | high |
| 15 Mock answers recorded as answers | 12 | Codex `gpt-6.1-sol` | high |
| 16 Up next and reminders on the roadmap | 12 | Codex `gpt-6-luna` | medium |
| 17 Remove the old plan code | 14, 16 | Codex `gpt-6-luna` | medium |
| 18 Combined verification | all | Lead | n/a |

Tasks 1, 2 and 3 can run in parallel worktrees if the lead wants; everything else runs in
order in the single roadmap worktree. Tasks 5, 6, 8 and 9 are the engine core: per the spec,
the lead writes them or reviews every line.

---

## File map

Create (all under the roadmap worktree):

| Path | Responsibility |
|---|---|
| `lib/core/time/local_day.dart` | `DateTime localDay(DateTime)`, the one definition of "today" |
| `lib/features/roadmap/domain/roadmap_inputs.dart` | Input value types |
| `lib/features/roadmap/domain/roadmap.dart` | `Roadmap`, `DayPlan`, `WeekPreview`, `RoadmapState`, `RoadmapChange`, `RoadmapChangeCause` |
| `lib/features/roadmap/domain/planning_window.dart` | Spec 4.1 and 4.2 |
| `lib/features/roadmap/domain/topic_order.dart` | Spec 4.3 |
| `lib/features/roadmap/domain/day_selection.dart` | Spec 4.4, 4.5, 4.6 |
| `lib/features/roadmap/domain/mock_day.dart` | Spec 4.7 placement |
| `lib/features/roadmap/domain/week_preview.dart` | Weeks ahead, topic ids only |
| `lib/features/roadmap/domain/build_roadmap.dart` | Assembly |
| `lib/features/roadmap/domain/roadmap_diff.dart` | Spec 4.9 causes |
| `lib/features/roadmap/domain/day_snapshot.dart` | Snapshot, completion subtraction, advance |
| `lib/features/roadmap/domain/sitting_planner.dart` | Spec 4.8 |
| `lib/features/roadmap/data/topic_prerequisites.dart` | App-side prerequisite map |
| `lib/features/roadmap/data/roadmap_day_repository.dart` | Day snapshot persistence |
| `lib/features/roadmap/data/roadmap_change_log_repository.dart` | Append-only log, sync-recorded |
| `lib/features/roadmap/application/roadmap_inputs_reader.dart` | Gathers inputs, metadata only |
| `lib/features/roadmap/application/roadmap_providers.dart` | `roadmapProvider`, `roadmapControllerProvider` |
| `lib/core/storage/data/tables/roadmap_day_local_table.dart` | drift table |
| `lib/core/storage/data/tables/roadmap_change_log_local_table.dart` | drift table |
| `lib/core/sync/mapping/roadmap_change_log_mapper.dart` | Firestore mapping |
| `lib/features/mock_exam/application/mock_answer_recorder.dart` | Mock answers into attempts and reviews |
| Tests mirroring each path under `test/` | |

Modify: listed per task. Anything not listed is out of bounds; touching it is a finding to report.

---

## Deferred to the UI round (not built here)

The spec leaves these to the UI round Aedwon is running separately. This plan exposes what they
need and builds no screen:

- The "I want to advance" control. The engine and `RoadmapController.advance()` exist after
  Task 12; no button calls it until the UI round places one.
- The plan screen (`/plan`), its Free and Pro presentation, weeks ahead, the change log viewer.
- The "today done" moment, the lesson reader's "2 of N", Settings copy for "How sessions are
  built", how the passed-exam and month questions are asked.

Until then, a student sees today's amounts through the existing quiz panel, Home's Up next and
the daily reminder.

---

### Task 0: Baseline (lead)

- [ ] **Step 1:** Confirm Aedwon has lifted the E09 stop for this work, in his words, and log it
  in the decision log.
- [ ] **Step 2:** `git fetch origin`; confirm `origin/web/e09-qlp5-prepared-next-r1` is still
  `13938943f447956af43d2de7e1f9999eb2418aee`. If it moved, stop and reconcile.
- [ ] **Step 3:**
  ```bash
  git worktree add -b web/roadmap-engine-r1 \
    /Users/aedwon/Documents/Projects/Pantas-wt-web-roadmap-engine-r1 \
    origin/web/e09-qlp5-prepared-next-r1
  cd /Users/aedwon/Documents/Projects/Pantas-wt-web-roadmap-engine-r1
  dart run build_runner build --delete-conflicting-outputs
  flutter analyze && flutter test && dart run tool/check_layering.dart
  ```
  Expected: analyze clean except the accepted `bookmarks_sheet.dart` `onReorder` deprecation
  info; tests green; layering exit 0. Record the output in the verification record. Any other
  failure is a finding; stop.
- [ ] **Step 4:** Confirm `grep -n "schemaVersion =>" lib/core/storage/data/app_database.dart`
  prints `24`.

---

### Task 1: Shared local day and public retrievability

**Files:**
- Create: `lib/core/time/local_day.dart`, `test/core/time/local_day_test.dart`
- Modify: `lib/features/quiz/domain/streak/streak_evaluator.dart` (use the helper; delete the
  private `_localDay`), `lib/core/fsrs/fsrs_scheduler.dart`,
  `test/core/fsrs/fsrs_scheduler_test.dart` (add cases; create if absent)

**Interfaces produced:**
```dart
// lib/core/time/local_day.dart
DateTime localDay(DateTime value); // DateTime(value.year, value.month, value.day), local
int localDaysBetween(DateTime from, DateTime to); // whole local days, to - from

// FsrsScheduler
double retrievability(ReviewState state, DateTime now);
// = existing _retrievability(elapsedDays, state.stability) where elapsedDays is
//   now.difference(state.lastReview) in fractional days, floored at 0.
```

- [ ] **Step 1:** Tests: `localDay` strips time; `localDaysBetween` across a DST change in a
  zone that has one counts calendar days (use `DateTime(2026, 3, 8)` style local dates);
  `retrievability` equals 1.0 at `now == lastReview`, decreases with elapsed time, and matches
  the private formula for three sampled states (call `next` to create states; compare with a
  copy of the formula in the test only).
- [ ] **Step 2:** Run `flutter test test/core/time test/core/fsrs`; expect failures for missing
  symbols.
- [ ] **Step 3:** Implement. `retrievability` calls the existing private function; do not
  duplicate the math in `lib/`.
- [ ] **Step 4:** Streak evaluator uses `localDay`; its existing tests stay green unchanged.
- [ ] **Step 5:** `flutter test test/core test/features/quiz/domain/streak`; commit
  "roadmap: share one definition of the local day and expose retrievability".

---

### Task 2: Lightweight lesson metadata query

**Files:**
- Create: `lib/core/storage/domain/lesson_meta.dart`
- Modify: `lib/core/storage/data/repos/content_repository.dart`,
  `test/core/content/repos/content_repos_test.dart`

**Interfaces produced:**
```dart
@immutable
class LessonMeta {
  const LessonMeta({required this.id, required this.topicId, required this.title,
      required this.ordering, required this.estimatedMinutes});
  final LessonId id; final TopicId topicId; final String title;
  final int ordering; final int estimatedMinutes;
}
// ContentRepository
Future<Map<TopicId, List<LessonMeta>>> lessonMetaByTopics(Iterable<TopicId> topicIds);
// Every requested topic gets a key. Each list ordered by ordering, then id (same as
// lessonsByTopics). Uses selectOnly over id, topicId, title, ordering, estimatedMinutes.
// Batches with the existing _batches helper. Calls _onQuery once per batch.
```

- [ ] **Step 1:** Tests: ordering matches `lessonsByTopics` for the same topics; a topic with
  no lessons has an empty list; query count through the existing `onQuery` hook equals the
  number of batches; the query never reads `bodyJson` (assert by building the statement and
  checking its column list, or by the query-count and a column spy used in the QLP-1 tests;
  follow whichever pattern `content_repos_test.dart` already uses for `selectionRowsByTopics`).
- [ ] **Step 2:** Run; expect failure.
- [ ] **Step 3:** Implement beside `selectionRowsByTopics`.
- [ ] **Step 4:** `flutter test test/core/content`; commit
  "roadmap: read lesson order without loading lesson bodies".

---

### Task 3: App-side prerequisite map and its audit

**Files:**
- Create: `lib/features/roadmap/data/topic_prerequisites.dart`,
  `test/features/roadmap/data/topic_prerequisites_test.dart`,
  `docs/superpowers/plans/2026-09-30-roadmap-prerequisite-audit.md` (the reviewable table)

**Interfaces produced:**
```dart
/// Topic id to the topic ids that must be covered first. Only links where a topic cannot
/// be understood without the other. Authored order within a subject is not a reason.
const Map<String, List<String>> topicPrerequisites = { /* audited entries */ };
```

**Topic ids** (from `tools/lesson_author/outline.json`, id = `topic_upcat_` + slug with `-`
replaced by `_`): mathematics `arithmetic_number_sense`, `algebra`, `geometry`,
`trigonometry`, `statistics_and_probability`, `precalculus_basic_calculus`,
`data_interpretation`; science `earth_science_astronomy`, `biology`, `chemistry`, `physics`;
language `vocabulary`, `grammar_and_structure`, `language_application`; reading `text_types`,
`comprehension_skills`; reasoning `logical_verbal_reasoning`, `spatial_abstract_reasoning`,
`mechanical_technical_reasoning`, `clerical_ability`, `verbal_logic`; general information
`philippine_constitution`, `code_of_conduct_ra_6713`, `peace_and_human_rights`,
`environment_management`. Confirm the list against `outline.json` before writing; a mismatch
is a stop condition.

- [ ] **Step 1: Validation test first.** Load the shipped topic ids the way
  `test/core/content` tests load the seed (reuse their fixture helper), then assert for
  `topicPrerequisites`: every key and value is a shipped topic id; no self link; no cycle
  (depth-first search with a visiting set; the failure message names the cycle). Also a test
  that an empty map passes.
- [ ] **Step 2:** Run; with the map empty the test passes. Add a deliberate cycle locally,
  confirm the test fails with the cycle named, remove it.
- [ ] **Step 3: Audit.** Read the lessons under `content/lessons/` for each topic, mathematics
  and science first. Propose links only where a topic's lessons use a concept taught only in
  the other topic. Write the table in the audit doc: topic, proposed prerequisites, one-line
  reason citing the lesson that needs it. Do not add the entries to the map yet.
- [ ] **Step 4: Stop for approval.** Report the table. Aedwon or an assigned reviewer approves
  or edits it. Only approved rows go into `topicPrerequisites`.
- [ ] **Step 5:** Add approved entries; run the test; commit
  "roadmap: record which topics must come before others".

The engine (Tasks 5 and 8) works with an empty map, so later tasks do not wait for Step 4.

---

### Task 4: Domain types, planning window and pacing

**Files:**
- Create: `lib/features/roadmap/domain/roadmap_inputs.dart`,
  `lib/features/roadmap/domain/roadmap.dart`, `lib/features/roadmap/domain/planning_window.dart`,
  `test/features/roadmap/domain/planning_window_test.dart`

**Interfaces produced** (plain immutable Dart classes with `==`/`hashCode`; no freezed needed):
```dart
// roadmap_inputs.dart
class RoadmapTopic { final TopicId id; final int authoredIndex; final String name; }
class RoadmapLesson { final LessonId id; final TopicId topicId; final int ordering;
  final DateTime? readAt; }
class RoadmapQuestion { final QuestionId id; final TopicId topicId; final LessonId? lessonId;
  final PassageId? passageId; }
class RoadmapReview { final QuestionId id; final DateTime due; final double retrievability; }
class RoadmapTopicScore { final TopicId id; final int correct; final int answered;
  bool get isMeasured => answered >= 3; }
class RoadmapMockFacts { final bool examHasMock; final bool proIsActive;
  final DateTime? lastSubmittedAt; }
class RoadmapInputs {
  final DateTime today;                 // local day
  final ExamId examId;
  final ExamDate? examDate;
  final List<RoadmapTopic> topics;      // scoped, authored order
  final Map<TopicId, List<TopicId>> prerequisites;
  final List<RoadmapLesson> lessons;
  final List<RoadmapQuestion> questions;      // active, scoped
  final Set<QuestionId> seenQuestionIds;      // has a review state
  final List<RoadmapReview> dueReviews;       // due <= end of today, scoped
  final Map<TopicId, RoadmapTopicScore> scores;
  final List<int> answeredPerActiveDay;       // newest first, at most 7 entries, each >= 1
  final RoadmapMockFacts mock;
  final bool assessmentCompleted;
  final String contentRevision;
}

// roadmap.dart
enum RoadmapState { needsAssessment, noContent, examPassedAwaitingAnswer,
  monthStartedAwaitingDay, planning, reviewOnly, allCovered }
class DayPlan { final DateTime day; final List<LessonId> lessonIds;
  final List<QuestionId> reviewQuestionIds; final List<QuestionId> newQuestionIds;
  final bool isMockDay; final Set<String> advancedIds;  // lesson or question ids
  int get questionCount => reviewQuestionIds.length + newQuestionIds.length; }
class WeekPreview { final DateTime weekStart; final List<TopicId> topicIds; }
enum RoadmapChangeCause { newDay, missedWork, advanced, examDateChanged, examChanged,
  scopeChanged, contentChanged, orderChanged, backlogCapped, assessmentCompleted,
  examPassed, prerequisiteCycle, missingExamDate, mockAnswersRecorded }
class RoadmapDayCounts { final int lessons; final int newQuestions; final int reviews; }
class RoadmapChange { final RoadmapChangeCause cause; final DateTime occurredAt;
  final RoadmapDayCounts? before; final RoadmapDayCounts? after;
  final List<TopicId> firstTopicsBefore; final List<TopicId> firstTopicsAfter;
  final int? advancedCompleted; }
class Roadmap { final RoadmapState state; final DayPlan today; final DateTime? examDay;
  final DateTime? reviewOnlyFrom; final DateTime? mockDay;
  final List<WeekPreview> weeksAhead; final List<TopicId> topicOrder;
  final List<RoadmapChange> changes; }

// planning_window.dart
class PlanningWindow { final RoadmapState state; final DateTime? examDay; final int daysLeft;
  final int quiet; final int workingDays; final DateTime? reviewOnlyFrom; }
abstract final class PlanningWindows {
  static PlanningWindow resolve({required DateTime today, required ExamDate? examDate});
  static int perDay(int remaining, int workingDays); // ceil, 0 when workingDays <= 0
}
```

`mockAnswersRecorded` is a lead technical addition to the spec's cause list (spec 4.7 says the
recompute fires once after recording; this names its log cause). Recorded in the decision log.

**Rules (spec 4.1, 4.2):**
- Day precision: `examDay = examDate.day`. Month precision and the month has not started:
  `examDay = monthStart`. Month precision and today is inside that month: state
  `monthStartedAwaitingDay`, `examDay` = last day of that month. Month over, or day precision
  and `today > examDay`: state `examPassedAwaitingAnswer`, reviews only. `examDate == null`:
  state `planning`, reviews only, no pacing, the builder logs `missingExamDate`.
- `daysLeft = localDaysBetween(today, examDay)`. `daysLeft == 0`: reviews only.
- `quiet`, `workingDays`, `reviewOnlyFrom` as in Global constraints. When today is on or after
  `reviewOnlyFrom` (and `workingDays <= 0`), state `reviewOnly`.

- [ ] **Step 1: Tests, computed not copied:**
  - Today Wed 30 Sep 2026, exam Mon 7 Dec 2026: `daysLeft` 68, `quiet` 7, `workingDays` 61,
    `reviewOnlyFrom` Mon 30 Nov 2026; `perDay(120, 61) == 2`; `perDay(900, 61) == 15`.
  - Exam in 10 days: quiet 2, workingDays 8. Exam in 4 days: quiet 1, workingDays 3.
  - Exam tomorrow: quiet 0, workingDays 1. Exam today: reviews only. Exam yesterday:
    `examPassedAwaitingAnswer`.
  - Month precision: December 2026 seen from 30 Sep plans to 1 Dec; seen from 10 Dec is
    `monthStartedAwaitingDay` with examDay 31 Dec; seen from 2 Jan 2027 is passed.
  - Null exam date: state `planning`, workingDays 0.
- [ ] **Step 2:** Run; expect failures. **Step 3:** Implement. **Step 4:** Run
  `flutter test test/features/roadmap`; `dart run tool/check_layering.dart`.
- [ ] **Step 5:** Commit "roadmap: size the days from the exam date".

---

### Task 5: Topic order (engine core)

**Files:** Create `lib/features/roadmap/domain/topic_order.dart`,
`test/features/roadmap/domain/topic_order_test.dart`.

**Interface:**
```dart
class TopicOrderResult { final List<TopicId> order; final bool cycleDetected; }
abstract final class TopicOrder {
  static TopicOrderResult compute({
    required List<RoadmapTopic> topics,
    required Map<TopicId, RoadmapTopicScore> scores,
    required Map<TopicId, List<TopicId>> prerequisites,
    required List<RoadmapLesson> lessons,
  });
}
```

**Rules (spec 4.3), exactly:**
1. Rank scoped topics by accuracy ascending (`correct / answered`). A topic that is not
   measured (`answered < 3`) ranks at the overall accuracy across measured topics (sum correct
   over sum answered of measured topics). With no measured topic, authored order. Ties:
   `authoredIndex`.
2. Continuity: a topic with at least one read and at least one unread lesson goes first, ahead
   of the ranking, ordered by the earliest `readAt` among its read lessons.
3. Prerequisites: walking the list, before emitting topic T, emit each prerequisite P of T that
   is in scope and not covered, recursively, depth first, in P's own rank order. Covered: every
   lesson of P read. A P with no lessons never blocks. P outside scope is ignored. Visited set;
   on a revisit skip it and set `cycleDetected`.
4. Covered topics are removed from `order` (their unseen questions are handled in Task 6 from
   the full ranked list, so also expose the full ranked list: add `final List<TopicId> ranked`
   to the result, which is steps 1 to 3 without removing covered topics).

- [ ] **Step 1: Tests:** weakest first; unmeasured at overall accuracy (topic with 2 answers
  sits between a 40% and an 80% topic when overall is 60%); no scores gives authored order;
  continuity beats weakness; prerequisite pulled before its dependent even when stronger;
  nested prerequisites depth first; out-of-scope prerequisite ignored; prerequisite with no
  lessons never blocks; covered prerequisite not emitted; a cycle (only possible with a bad
  map) terminates and sets `cycleDetected`; `ranked` keeps covered topics.
- [ ] **Steps 2 to 4:** fail, implement, pass. **Step 5:** Commit
  "roadmap: order topics weakest first with prerequisites before them".

---

### Task 6: Day selection, reviews and the backlog cap (engine core)

**Files:** Create `lib/features/roadmap/domain/day_selection.dart`,
`test/features/roadmap/domain/day_selection_test.dart`.

**Interface:**
```dart
class DaySelection { final List<LessonId> lessonIds; final List<QuestionId> newQuestionIds;
  final List<QuestionId> reviewQuestionIds; final bool backlogCapped; final int dueCount; }
abstract final class DaySelector {
  static DaySelection select({
    required List<TopicId> lessonTopicOrder,   // TopicOrderResult.order
    required List<TopicId> rankedTopics,       // TopicOrderResult.ranked
    required List<RoadmapLesson> lessons,
    required List<RoadmapQuestion> questions,
    required Set<QuestionId> seenQuestionIds,
    required List<RoadmapReview> dueReviews,
    required List<int> answeredPerActiveDay,
    required int lessonsToday,
    required int newToday,
  });
  static int? capacity(List<int> answeredPerActiveDay); // null when empty
}
```

**Rules (spec 4.4 to 4.6):**
- Lessons: the first `lessonsToday` unread lessons walking `lessonTopicOrder`, each topic's
  lessons by `ordering` then id.
- New questions, until `newToday`: (1) unseen questions whose lesson is read, oldest `readAt`
  first, then question id; (2) unseen questions whose lesson is in today's lessons, in today's
  lesson order; (3) unseen questions walking `rankedTopics`, grouped by lesson in lesson order,
  questions without a lesson last within their topic, question id within a lesson.
- Passages: a question with a `passageId` brings every unseen question of that passage right
  after it, even past `newToday` (at most the remainder of that one set).
- Reviews: `dueReviews` sorted by `retrievability` descending, ties by `due` ascending then id.
- Capacity: `max(1, median(answeredPerActiveDay))`; median of an even count is the lower
  middle value (integer, no invented fraction); empty list means no cap. If due count is at most
  capacity, include all; else the first `capacity` and `backlogCapped = true`.
- New material is never reduced by the backlog.

- [ ] **Step 1: Tests:** each priority tier; skipped lesson still yields its questions through
  tier 3 so the pace holds; passage set kept together and allowed to overflow by its remainder;
  reviews in retrievability order; capacity with 0, 1 and 7 history days (0 means no cap; a day
  of only new questions still counts, so capacity is never 0); cap applied and flagged; new
  questions unaffected by a large backlog.
- [ ] **Steps 2 to 4:** fail, implement, pass. **Step 5:** Commit
  "roadmap: choose today's lessons, new questions and reviews".

---

### Task 7: Mock day

**Files:** Create `lib/features/roadmap/domain/mock_day.dart`,
`test/features/roadmap/domain/mock_day_test.dart`.

**Interface:**
```dart
abstract final class MockDay {
  static DateTime? place({required DateTime today, required DateTime? examDay,
    required DateTime? reviewOnlyFrom, required RoadmapMockFacts mock,
    required bool mockSubmittedInWindow});
}
```

**Rules (spec 4.7):** none if `!mock.examHasMock` or `examDay == null` or `daysLeft < 2`.
Window `[max(today, examDay - 6), examDay - 1]`. Target: `reviewOnlyFrom` clamped into the
window. Free (`!proIsActive`) with `lastSubmittedAt`: if target is before
`localDay(lastSubmittedAt) + 14 days`, move to that date if it is still in the window, else
none. A mock already submitted inside the window: none. Pro and Free compute the same way;
presentation decides who sees it ahead of the day.

- [ ] **Step 1: Tests:** today 30 Sep 2026, exam 7 Dec 2026: `reviewOnlyFrom` is 30 Nov, the
  window is 1 Dec to 6 Dec, so the mock is 1 Dec; 2 and 3 days out give `examDay - 1`; 1 day
  out gives none; Free cooldown moving the day inside the window, and pushing it past the
  window (none); Pro ignores the cooldown; no mock for the exam; already taken in the window.
- [ ] **Steps 2 to 4**, **Step 5:** Commit "roadmap: place one mock shortly before the exam".

---

### Task 8: Week preview, assembly and the coverage property (engine core)

**Files:** Create `lib/features/roadmap/domain/week_preview.dart`,
`lib/features/roadmap/domain/build_roadmap.dart`,
`test/features/roadmap/domain/build_roadmap_test.dart`,
`test/features/roadmap/domain/coverage_property_test.dart`.

**Interface:**
```dart
abstract final class BuildRoadmap {
  static Roadmap call(RoadmapInputs inputs); // changes empty; Task 9 fills them
}
```

**Assembly:**
1. `needsAssessment` when `!assessmentCompleted` (today empty). `noContent` when no scoped
   topics or no lessons and no questions.
2. `PlanningWindows.resolve`. For reviews-only states: `DayPlan` with reviews only (cap
   applies), no lessons, no new questions.
3. `TopicOrder.compute` then `DaySelector.select` with `perDay(lessonsLeft, workingDays)` and
   `perDay(unseenLeft, workingDays)`. `lessonsLeft` = unread lessons in scope; `unseenLeft` =
   scoped questions not in `seenQuestionIds`.
4. Coverage wins inside the quiet stretch: if `workingDays <= 0`, `daysLeft > 0`, and anything
   is left, schedule all of it today.
5. `MockDay.place`; `isMockDay = mockDay == today`.
6. `allCovered` when nothing unread and nothing unseen (reviews continue).
7. Weeks ahead: simulate the lesson walk forward day by day from tomorrow to
   `reviewOnlyFrom - 1`, assuming each day's lessons are read, and collect the topic ids whose
   lessons fall in each Monday-started week. Topic ids only, no counts.

- [ ] **Step 1: Tests:** each state; the worked example yields today 2 lessons, 15 new
  questions; quiet-stretch coverage; mock day flagged.
- [ ] **Step 2: Coverage property test.** Seeded random corpora (5 to 25 topics, 0 to 12
  lessons each, 0 to 60 questions each, some without a lesson, some in passages) and random
  exam distances (1 to 200 days). Simulate: each day call `BuildRoadmap`, mark that day's
  lessons read and new questions seen, advance a day. Assert every lesson is read and every
  question seen by `reviewOnlyFrom` (or by the exam when `workingDays <= 0`). 200 seeds; print
  the seed on failure.
- [ ] **Steps 3 to 4:** implement, pass. **Step 5:** Commit
  "roadmap: build the whole plan and prove it covers everything in time".

---

### Task 9: Changes, snapshots, advance and partial advance (engine core)

**Files:** Create `lib/features/roadmap/domain/roadmap_diff.dart`,
`lib/features/roadmap/domain/day_snapshot.dart`, tests beside them.

**Interfaces:**
```dart
class DaySnapshot {   // what is persisted per local day
  final DateTime day; final DayPlan plan; final String inputsDigest;
  final List<TopicId> topicOrderHead; // first three
  Map<String, Object?> toJson(); static DaySnapshot fromJson(Map<String, Object?> json);
}
class CompletionFacts { final Set<LessonId> readLessonIds;
  final Set<QuestionId> seenQuestionIds; final Set<QuestionId> reviewedTodayIds; }
abstract final class DaySnapshots {
  static DayPlan remaining(DaySnapshot snapshot, CompletionFacts facts);
  // lessons minus read; new minus seen; reviews minus reviewed today.
  static bool originalDone(DaySnapshot snapshot, CompletionFacts facts);
  // advanced items never make a day incomplete
  static DaySnapshot advance(DaySnapshot today, DayPlan tomorrow);
  // appends tomorrow's lessons and new questions (not reviews) to today, ids added to
  // advancedIds; only when originalDone
}
abstract final class RoadmapDiff {
  static List<RoadmapChange> between({required DaySnapshot? prior,
    required CompletionFacts? priorCompletion, required DaySnapshot next,
    required String? priorDigestParts, required String nextDigestParts,
    required bool backlogCapped, required bool cycleDetected,
    required RoadmapState state, required DateTime occurredAt});
}
```

**Digest parts** (a `|`-joined string the reader builds in Task 12): `examId`, exam date storage
value and precision, sorted scoped topic ids, content revision, assessment completed flag,
count of recorded mock attempts. Each part maps to one cause when it differs: `examChanged`,
`examDateChanged`, `scopeChanged`, `contentChanged`, `assessmentCompleted`,
`mockAnswersRecorded`.

**Causes (spec 4.9):** a new local day logs `newDay`; if the prior day's original items were
not all done, also `missedWork` with before counts from the prior original plan and after
counts from the new day. Advanced items unfinished at day end log `advanced` with
`advancedCompleted` = the number actually completed, never `missedWork`. `orderChanged` when
`topicOrderHead` differs for a reason other than the digest causes. `backlogCapped`,
`prerequisiteCycle`, `examPassed`, `missingExamDate` as flagged. Before and after carry only
counts that were real at the time. No entry states a verdict.

- [ ] **Step 1: Tests:** each cause; partial advance at day end logs `advanced` with the
  completed count and no `missedWork`; unfinished advanced items reappear in the next day's
  plan through normal selection; `originalDone` ignores advanced items; JSON round trip.
- [ ] **Steps 2 to 4**, **Step 5:** Commit "roadmap: record why the plan changed".

---

### Task 10: Schema 25 and the two repositories

**Files:**
- Create: the two table files, `lib/features/roadmap/data/roadmap_day_repository.dart`,
  `lib/features/roadmap/data/roadmap_change_log_repository.dart`, tests beside them.
- Modify: `lib/core/storage/data/app_database.dart` (tables list, `schemaVersion => 25`,
  `if (from < 25) { createTable x2 }`), `lib/core/sync/local_state_wiper.dart` and
  `lib/core/dev/dev_demo_switch.dart` (delete both tables where `dailyNewCardIntro` is
  deleted), `test/core/storage/data/app_database_test.dart` (migration from 24).

**Tables:**
```dart
@DataClassName('RoadmapDayLocalRow')
class RoadmapDayLocal extends Table {
  TextColumn get examId => text()();
  TextColumn get day => text()();            // local YYYY-MM-DD
  TextColumn get planJson => text()();       // DaySnapshot.toJson
  TextColumn get inputsDigest => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column<Object>> get primaryKey => {examId, day};
}
@DataClassName('RoadmapChangeLogLocalRow')
class RoadmapChangeLogLocal extends Table {
  TextColumn get id => text()();             // uuid v4
  TextColumn get examId => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get cause => text()();          // RoadmapChangeCause.name
  TextColumn get beforeJson => text().nullable()();
  TextColumn get afterJson => text().nullable()();
  @override Set<Column<Object>> get primaryKey => {id};
}
```

**Repositories:** day repository: `Future<DaySnapshot?> read(ExamId, DateTime day)`,
`Future<DaySnapshot?> latestBefore(ExamId, DateTime day)`, `Future<void> write(ExamId,
DaySnapshot)`; keep the last 14 days per exam, delete older on write. Not synced. Change log
repository: `Future<void> append(ExamId, List<RoadmapChange>)` writing each row through
`LocalSyncMutationRecorder.runRecorded(collection: 'roadmap_changes', rowId: id, op: upsert)`
exactly as `ReviewLogRepository.insert` does; `Future<List<RoadmapChange>> recent(ExamId,
{int limit = 100})`. Append-only; no update path.

- [ ] **Step 0:** Confirm schema is 24. If not, stop.
- [ ] **Steps 1 to 4:** migration test from a v24 database creates both tables and keeps data;
  repository tests; fail, implement, regenerate, pass.
- [ ] **Step 5:** One commit with the bump and migration: "roadmap: store the day and the change
  log".

---

> **Deferred on 1 October 2026** (release-first cut, decision log). The change log stays on the
> device for every student in this build; Task 10's repository still records mutations so
> sync can be switched on later without a migration. Do not dispatch Task 11.

### Task 11: Change log sync for Pro

**Files:**
- Create: `lib/core/sync/mapping/roadmap_change_log_mapper.dart`, its test.
- Modify: `lib/core/sync/engine/collection_registry.dart` (entry `roadmap_changes`, active),
  every `switch` that has `case 'review_logs':` in `lib/core/sync/` (currently
  `bootstrap/full_pull.dart:242`, `engine/sync_collection_adapter.dart:135` and `:202`,
  `engine/sync_payload_loader.dart:114`; grep again, add a parallel case in each, and add the
  table to `_replaceSyncOwnedState`), `firestore.rules` (a `match /roadmap_changes/{rowId}`
  block identical to `review_logs`), `firestore.indexes.json` only if `review_logs` needs one
  for the same query shape, `functions/src/cleanupSyncData.ts` (add `'roadmap_changes'` beside
  `'review_logs'`), and the tests that enumerate collections:
  `test/core/sync/collection_registry_test.dart`, `test/core/sync/sync_schema_test.dart`,
  `test/core/sync/sync_collection_adapter_test.dart`, `test/core/sync/bootstrap/full_push_test.dart`,
  `test/tool/firebase_rules_layout_test.dart`, `functions/test/static.test.mjs`.

Eligibility is the existing Named Pro rule; add no new eligibility logic. Mapper follows
`ReviewLogMapper` (schemaVersion 1, identity check, ISO UTC dates).

- [ ] **Steps 1 to 4:** mapper round trip; registry and adapter tests; rules layout test; a
  test that a change log row is queued for upload for a Named Pro account and not for a Free
  account, using the same fixtures the existing sync eligibility tests use; fail, implement,
  pass. Run `flutter test test/core/sync test/tool` and
  `cd functions && npm test` (static tests only; no deploy).
- [ ] **Step 5:** If an emulator suite exists for rules (`firebase emulators:exec` in
  `functions/package.json` or `tool/`), run it; if it needs an account or network, stop and
  report instead of improvising.
- [ ] **Step 6:** Commit "roadmap: back up the change log for Pro like review history".

---

### Task 12: Inputs reader and roadmap provider

**Files:**
- Create: `lib/features/roadmap/application/roadmap_inputs_reader.dart`,
  `lib/features/roadmap/application/roadmap_providers.dart`, tests.
- Modify: `lib/core/storage/data/repos/attempts_repository.dart` (add
  `Future<List<int>> answeredPerActiveDay({required ExamId examId, int days = 7})`: item counts
  grouped by `localDay(startedAt)`, newest first, days with zero answers excluded).

**Reader** (all reads batched; metadata only):
- Scope: the same `_readScope` logic as `quiz_providers.dart` (move it to
  `lib/core/storage/track_scope.dart` as a public `readScopedTopics(ContentRepository, CustomTrackRepository, ExamId)` returning topics and excluded ids, and make `quiz_providers.dart` call it; no behavior change).
- Topics with `authoredIndex` = position in the scoped list.
- `selectionRowsByTopics` and `lessonMetaByTopics` for scoped topic ids.
- `lessonProgressLocal` rows (read state and `readAt`).
- `reviewStateRepositoryProvider.allStates()`: seen ids; due reviews with `retrievability`
  from `FsrsScheduler.retrievability` at now.
- Scores: `topicAccuracyProvider` values mapped to `RoadmapTopicScore` (same source as Home, so
  the plan and Home never disagree).
- Exam date from `userSettingsProvider`; assessment from `assessmentRepositoryProvider`;
  content revision the same way `_readPreparationStamp` reads it; mock facts from
  `mockBlueprintRepoProvider.byExam`, `mockEntitlementProvider` and the attempt repo's last
  submitted attempt; `answeredPerActiveDay`.
- Custom track: `examHasMock` is true when the custom track has a custom blueprint.

**Anchor (added 1 October 2026):** pass `anchoredReviewOnlyFrom` = the stored prior day's
`reviewOnlyFrom` when that day's digest has the same exam id and exam date; otherwise null. Store
the built roadmap's `reviewOnlyFrom` in each new `DaySnapshot`. Also run
`MockAnswerRecorder.reconcile(examId)` (Task 15, landed) before reading inputs, and count recorded
mocks (attempt rows with origin `mock` for the exam) into the digest.

**Provider behavior:**
```dart
final roadmapProvider = FutureProvider.family<Roadmap, ExamId>(...);
final roadmapControllerProvider = Provider<RoadmapController>(...);
class RoadmapController {
  Future<Roadmap> current(ExamId examId);     // same as the provider, for non-widget callers
  Future<void> advance(ExamId examId);         // only when originalDone; logs `advanced`
  void invalidate(ExamId examId);
}
```
- On read: build digest parts. If no snapshot for today, or the digest differs, run
  `BuildRoadmap`, diff against the prior snapshot, write the snapshot, append changes. Else
  return the stored snapshot with `DaySnapshots.remaining` applied.
- Before reading, reconcile mock answers: call `MockAnswerRecorder.reconcile(examId)` from
  Task 15 once that task lands (Task 12 leaves a no-op hook named
  `RoadmapInputsReader.beforeRead` that Task 15 fills).
- Invalidate on: quiz completion (existing `onCommitted` in `quizCompletionCoordinatorProvider`
  also calls `ref.read(roadmapControllerProvider).invalidateAll()`), lesson read, exam or date
  change, scope change, assessment completion. Invalidation re-reads; it only rebuilds when the
  digest or the day changed.

- [ ] **Steps 1 to 4:** tests with an in-memory database and fake content: first read writes a
  snapshot and logs `newDay`; second read the same day does not rebuild (spy on
  `BuildRoadmap` through an injectable builder); answering removes items; changing scope
  rebuilds and logs `scopeChanged`; the reader issues no `hydrateSelectedQuestions` and no
  `lessonsByTopics` call (spy); query count for 25 topics is bounded by batch count, not by
  question count.
- [ ] **Step 5: Budget check.** Time the first build of the day with the existing
  `QuizPerformanceProbe` phases on the test fixture sized like the shipping corpus (25 topics,
  158 lessons, full question bank). Topic scores come from `topicAccuracyProvider`, which runs
  the Progress table; if the build exceeds 300 ms on the host, stop and report before Task 14
  rather than tuning around it.
- [ ] **Step 6:** Commit "roadmap: gather the plan's inputs and keep one plan per day".

---

### Task 13: Sitting planner

**Files:** Create `lib/features/roadmap/domain/sitting_planner.dart`, its test.

**Interface:**
```dart
abstract final class SittingPlanner {
  /// The next sitting's question ids from what remains of today, in presentation order.
  static List<QuestionId> next({
    required DayPlan remaining,
    required Set<LessonId> readLessonIds,
    required Map<QuestionId, RoadmapQuestion> questionsById,
    required int sessionLength,          // QuizPreferences.allDueSessionLength means all
    required QuizOrdering ordering,
    required TopicId vocabularyTopicId,  // 'topic_upcat_vocabulary'
    required List<TopicId> rankedTopics,
  });
}
```

**Rules (spec 4.8):** draw reviews first, then new questions whose lesson is read or have no
lesson, then new questions whose lesson is in today's unread lessons only when nothing else is
left. Take `sessionLength` (All: everything). A passage set is drawn whole or not at all
(`PassageSetFiller.fill`).

**Arrangement.** The Today pickers (`TodayTopicPicker`, `TodayInterleavedPicker`,
`TodayFullyMixedPicker`) select as well as order: with a topic id they drop other topics, and
the fully mixed picker can drop items it cannot place. Reusing them would silently drop planned
items, so the planner arranges the drawn set itself with the existing reordering helpers, which
never drop:
- `blocked` ("one topic only" now means grouped by topic): stable sort by the topic's index in
  `rankedTopics`.
- `interleavedTail` (default): the topic with the most drawn items first (ties by rank), then the
  rest passed through `RecencyFilter.noConsecutiveSameTopic`.
- `fullyMixed`: the draw passed through `RecencyFilter.noConsecutiveSameTopic`.
- Then `groupPassageSets`, then every Vocabulary question moved into one contiguous run at the
  position of the first one.

This replaces the spec's "reuse the existing pickers" (Part 2, Section 2) for the reason above;
recorded in the decision log as a lead technical revision. The interface gains
`required List<TopicId> rankedTopics`.

- [ ] **Steps 1 to 4:** tests for draw order, held-back questions, All, each ordering keeps the
  same set, vocabulary contiguous under `fullyMixed`, passage set not split.
- [ ] **Step 5:** Commit "roadmap: split the day into sittings".

---

### Task 14: Today's launch path on the roadmap

**Files:**
- Modify: `lib/features/quiz/application/quiz_providers.dart`,
  `lib/features/quiz/application/quiz_preparation_stamp.dart`,
  `lib/features/quiz/domain/models/quiz_preferences.dart`,
  `lib/features/quiz/data/repos/quiz_preferences_repository.dart`,
  `lib/features/quiz/presentation/today_providers.dart`,
  `lib/features/quiz/domain/use_cases/count_today_backlog.dart`, and the tests listed by
  `grep -rln newCardCap test` (currently 12 files) plus
  `test/features/quiz/presentation/today_topic_queue_provider_test.dart`,
  `test/features/quiz/presentation/today_inputs_selection_test.dart`,
  `test/features/quiz/presentation/scoped_content_test.dart`.

**Changes:**
1. `_buildTodayPlan` for a request with `topicId == null`: read the roadmap's remaining day,
   take `SittingPlanner.next`, hydrate those ids with `hydrateSelectedQuestions` (the only
   hydration), and return a `TodaySessionPlan` with `dueCount` = reviews in the sitting,
   `freshCount` = new in the sitting, `weaknessCount` 0, `topicId`/`topicName` = the first
   question's topic. Empty remaining day returns `TodaySessionPlan.empty` (the panel then shows
   its existing caught-up state).
2. Requests with a `topicId` (Home's weakest-topic rows): free practice outside the plan, kept
   on the existing bucket path for that topic, with the new-question cap removed: pass
   `capRemaining` = the session length (or the topic's unseen count for All) to
   `CountTodayBacklog.forTopic`. Behavior otherwise unchanged.
3. `QuizPreparationStamp`: remove `newCardCap`; add `roadmapToken` =
   `'${snapshot.day}|${snapshot.inputsDigest}|${advancedIds.length}'`. Include it in `==`,
   `hashCode`, and `_readPreparationStamp`. A roadmap rebuild or an advance therefore
   invalidates a prepared sitting through the existing freshness check.
4. `QuizPreferences`: remove `newCardCap` and its validation. The repository stops reading and
   writing `quiz_new_card_cap`; the stored key is left in place, unread (an older build reading
   synced preferences must not fail). Launch coordinator persist builds preferences without it.
5. Delete the unused `todayInputsProvider`, `todayTopicQueueProvider` and `TodayInputs` from
   `today_providers.dart` (no `lib/` caller; tests that only covered them are deleted with
   them). `sessionPanelProvider` is unchanged apart from reading the preparer as today.
6. `SubmitAnswer` keeps writing `daily_new_card_intro` (harmless, and the table is still wiped
   and synced as before); nothing reads it for a cap any more. Leave the repository in place.

- [ ] **Step 1: Tests first:** the Start route through the real `QuizLaunchCoordinator`
  creates a session whose ids equal `SittingPlanner.next` for the roadmap day; completing it
  removes those items and the next preparation returns the next sitting; a roadmap rebuild
  changes the stamp and the preparer rebuilds; QLP-2 to QLP-4 regressions stay green
  (single session on rapid taps, warm Start without reselection, resume identity, late async
  result discarded); a query-count test proves the preparation reads no stem, choice,
  explanation or figure payloads except the sitting's hydration; topic requests still work.
- [ ] **Steps 2 to 4:** fail, implement, regenerate, pass: `flutter test test/features/quiz
  test/features/home test/features/roadmap`.
- [ ] **Step 5:** `grep -rn "newCardCap\|capRemaining: preferences" lib` prints nothing;
  commit "roadmap: size today's quiz from the plan instead of a fixed ten".

---

### Task 15: Mock answers recorded as answers

**Files:**
- Create: `lib/features/mock_exam/application/mock_answer_recorder.dart`, its test.
- Modify: `lib/features/mock_exam/presentation/pages/mock_start_route.dart` (after
  `submitMockUseCaseProvider` succeeds, call `recorder.record(attemptId)`; failures are caught,
  logged, and left to `reconcile`), `lib/features/mock_exam/application/mock_start_providers.dart`
  (provider), `lib/features/quiz/domain/models/session_origin.dart` (add `mock('mock')`, not
  streak eligible), `lib/core/storage/domain/attempt_origins.dart` (add `'mock'` to `untimed`;
  add `static const mirrored = {'mock'}` documented as rows that duplicate a record kept in
  another table), `lib/core/storage/data/repos/attempts_repository.dart` (`averageResponseMs`
  and `averageResponseMsByTopic` skip `untimed` origins, and `averageResponseMs` counts only
  timed sessions toward `minimumSessions`),
  `lib/features/progress/application/record_provider.dart` and
  `lib/features/metrics/signals/test_mode_delta_signal.dart` (skip `mirrored` rows, because both
  already read `mock_attempts`), `lib/features/roadmap/application/roadmap_inputs_reader.dart`
  (`beforeRead` calls `reconcile`), tests beside each.

**Recorder rules (spec 4.7):**
- `record(attemptId)`: load the mock attempt. Only statuses `completed` and `forfeited` (the
  app stores time-up as `completed`); `discarded` and `in_progress` record nothing. If
  `attempts.byId(attemptId)` exists, return (idempotent).
- For each question id in `sampledQuestionsJson` with an entry in `answersJson`: load the
  question (batched `questionsByIds`), map `selectedIndex` to `question.choices[i].id` exactly
  as `mock_review_providers.dart` does; skip out-of-range indexes and retired (missing)
  questions. Unanswered questions are skipped.
- Save one `Attempt(id: attemptId, origin: 'mock', startedAt: attempt.startedAt,
  completedAt: attempt.submittedAt, items: ...)` with `responseMs: 0` (untimed, the assessment
  precedent), using `attempts.saveAtomically` whose `afterWrite` applies each rating to its
  review state inside the same transaction: `Rating.good` if correct, else `Rating.again`, at
  `submittedAt`, through `FsrsScheduler.next`, exactly as `CompleteAssessment` does. No review
  log rows (no per-question timing exists; same as the assessment).
- `reconcile(examId)`: for each terminal `completed` or `forfeited` mock of this exam without an
  attempt row, call `record`. Cheap: one query for mock ids, one for attempt ids.
- After a successful record, invalidate the roadmap (digest part "recorded mock count"
  changes, logging `mockAnswersRecorded`).

- [ ] **Step 1: Tests:** completed and forfeited record answered items only; discarded records
  nothing; running `record` twice changes nothing; a crash between submit and record is healed
  by `reconcile`; 100 misses produce at most `capacity` reviews in the next day's plan; Your
  record's questions-answered does not double count; the test-mode delta signal ignores mock
  rows; practice picker pace ignores untimed rows.
- [ ] **Steps 2 to 4**, **Step 5:** Commit "roadmap: bring missed mock questions back as
  reviews".

---

### Task 16: Up next and reminders on the roadmap

**Files:** Modify `lib/features/home/application/up_next_provider.dart`,
`lib/features/notifications/application/notifications_providers.dart`, their tests.

- Up next: `lessons` = today's remaining lessons from `roadmapProvider(examId)`, in plan order,
  with title, subject name and minutes from `lessonMetaByTopics` plus the subject lookup the
  provider already does. `allReadInWeakTopics` keeps its meaning of "every lesson in scope is
  read". Remove `targetCount = 3`. Scope comes from the roadmap, so excluded topics no longer
  appear.
- Reminders: `planReader` returns `NotificationPlanSnapshot.ready(reviewCount: today's
  remaining reviews, route: '/quiz', planState: isMockDay ? mock : standard)`; unavailable when
  the roadmap state is `needsAssessment` or `noContent`. Never use `behind` or `calm`.
- [ ] **Steps 1 to 4:** tests; fail, implement, pass. **Step 5:** Commit
  "roadmap: show today's lessons on Home and in reminders".

---

### Task 17: Remove the old plan code

**Files:** Delete `lib/features/study_plan/` and `test/features/study_plan/`,
`test/tool/study_plan_boundary_test.dart`. Modify `lib/app/router.dart` (remove the `/plan`
route and its import; keep `/plan/dossier/:mockId` untouched), and the `study_plan` entry in
`lib/core/sync/engine/collection_registry.dart` stays (inactive placeholder, harmless; removing
it touches sync tests for no gain).

- [ ] **Step 1:** `grep -rn "study_plan\|PlanPage\|StudyPlanIntensity\|pace_curve\|daily_sizer"
  lib test` lists only the dossier route and the inactive registry entry afterwards.
- [ ] **Step 2:** `flutter analyze`, `flutter test`. **Step 3:** Commit
  "roadmap: remove the unwired plan code it replaces".

---

### Task 18: Combined verification (lead)

- [ ] **Step 1: Gates** on the branch head, output preserved:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  flutter analyze
  flutter test
  dart format --output=none --set-exit-if-changed lib test
  dart run tool/check_layering.dart
  dart run tool/check_no_ai_attribution.dart
  (cd functions && npm test)
  ```
- [ ] **Step 2: Grep gates:**
  `grep -rn "targetCount = 3\|newCardCap\|StudyPlanIntensity\|pace_curve" lib` prints nothing;
  `grep -rniE "behind|ahead|on track|\bready\b|mastery" lib/features/roadmap` prints nothing.
- [ ] **Step 3: Content identity:** `git diff origin/web/e09-qlp5-prepared-next-r1 --stat --
  content assets/content` is empty; the protected package files are byte-identical.
- [ ] **Step 4: Independent review** by a reviewer who did not author the engine core
  (`SUBAGENTS.md` Part 7b): diff against this plan's file map, re-derive three pacing results
  and one topic order by hand.
- [ ] **Step 5:** Push `web/roadmap-engine-r1` (completion permission). Update the decision
  log and the Readiness SSOT with the head SHA and results.
- [ ] **Step 6: Device evidence** (needs Aedwon's go-ahead for device work): rerun E09
  functional #22 to #28 and QLP-5 on the new candidate per the SSOT method, then QLP-6. Report
  numbers against the budgets. Aedwon does visual checks.

---

## Codex dispatch

Per Aedwon, 30 September 2026: Codex CLI is the implementor. The lead dispatches one task at a
time into the roadmap worktree and reviews every diff before the next.

```bash
cd /Users/aedwon/Documents/Projects/Pantas-wt-web-roadmap-engine-r1
codex exec -m gpt-6.1-sol -c model_reasoning_effort=high -s workspace-write \
  -C /Users/aedwon/Documents/Projects/Pantas-wt-web-roadmap-engine-r1 \
  "$(cat /path/to/task-N-brief.md)"
```

Use `-m gpt-6-luna -c model_reasoning_effort=medium` for tasks marked Luna. Confirm the exact
model names with the installed CLI (`~/.codex/config.toml` currently names `gpt-6.1-sol`)
before the first dispatch; if a name differs, record the substitution.

**Each brief contains, in this order:** the startup text from `docs/workflow/startup.md` and the
policy commit; the worktree path and branch; "Read `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`
from origin/main, this plan's Global constraints, and Task N in full"; the task's file list as
the only files it may touch; the interfaces it must produce verbatim; the exact test and gate
commands; the stop conditions (`SUBAGENTS.md` Part 6, plus: any file outside the list, any
schema value other than expected, any need for a product decision); and the report format
(`SUBAGENTS.md` Part 7 with pasted output). Workers commit on the branch; they never push,
merge or deploy.

**Lead review after each task:** read the diff against the file list; run the task's tests and
`flutter analyze` on the result; for Tasks 5, 6, 8 and 9 read every line against the spec
section it implements. Reject and re-dispatch with the specific finding rather than fixing
silently.
