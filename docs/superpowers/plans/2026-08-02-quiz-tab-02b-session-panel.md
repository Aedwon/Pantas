# Quiz Tab, Plan 2b of 6: The Session Panel and the Today Queue

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the Quiz tab's session panel its four states, and make the numbers it
prints true by wiring `FsrsDueSelector`, `WeaknessSelector` and `NewCardSelector` into the
session that the Start button actually creates.

**Architecture:** Four new read queries on existing repositories, two new pure use cases in
`features/quiz/domain`, a rewrite of `StartTodaySession` so the panel and the Start button
compute from one code path, three providers, one widget, and one small settings screen so
the panel's link has somewhere to go.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-quiz-tab-design.md`, Section 1 "The
session panel" and Section 5 "It is a setting, not a rule".

**Decision log:** `docs/superpowers/decisions/2026-07-28-quiz-tab-decision-log.md`, entry
dated 2 August. Read the three findings there before starting. They are the reason this
plan is shaped the way it is.

**Depends on:** Plan 2a, which creates `RuledPanel` and rewrites the tab's frame. Do not
start 2b until 2a is merged. Every task below assumes `RuledPanel` exists and that
`_QuizTabBody` in `quiz_tab_home.dart` has the comment "The session panel and the mock
panel land here in plans 2b and 2c."

---

## What is actually broken, found by reading the code

This is not a decoration job. Four things are wrong underneath the panel.

1. **Today's session ignores every selector.** `StartTodaySession` builds
   `PickContext(allQuestions: all, newQuestions: all)` and leaves `dueQuestions` and
   `weaknessQuestions` empty. `_compose` in `today_topic_picker.dart` then reads
   `hasDue == false`, sets `dueTarget = 0`, finds `weaknessQuestions` empty, and falls
   through to `addFrom(context.allQuestions, requested)`. **Today's session is currently
   the first N questions of the exam in seed order.** No FSRS, no weakness, no new-card
   cap. The composition line `6 due · 3 weak spots · 1 new` would be fiction against this.
2. **Nothing calls `ResumeSession`.** `resumeSessionProvider` exists and no page reads it.
   `QuizPage` in `today` mode always calls `startToday`, which mints a **new** session row
   while the abandoned one stays open. Sessions leak, and `activeFor` quietly returns the
   newest.
3. **`ReviewStateRepository` cannot return all states**, which is what `FsrsDueSelector`
   takes. It has `byQuestionId` and `dirtyStates` only.
4. **Nothing computes accuracy per topic**, which is what weakness needs after the
   2 August decision.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout. The first
  background run left a half-applied `app_database.dart` in the main tree.
- **Generated files are never edited by hand, and never committed.** This repo gitignores
  `*.g.dart` and `*.freezed.dart`.
- **Check `lib/core/ui/components/` before writing any widget.** The kit holds
  `PageScaffold`, `RuledSection`, `RuledPanel` (2a), `SectionHeader`, `StatsBand`,
  `InkTableRow`, `EmptyState`, `ErrorBanner`, `FaintBars`, `BoardButton`,
  `ConfirmationDialog`. Adding a near-duplicate is the most common avoidable defect here.
- **Never invent a figure.** Every number this plan prints is a measurement from the
  student's own use or the output of a named selector used as designed. If you find
  yourself multiplying a measurement by an assumption, stop and say so.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer.
- **Colour carries meaning.** Board green is the single primary action on a screen. At most
  one non-`secondary` `BoardButton` per screen. On this tab the session panel owns it.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. Scores are
  **points**, never marks. Every user-facing string here is quoted from the spec except the
  two called out in Task 8; do not improvise any others.
- **Navigation rule (UI-001).** `push` for destinations outside the tab shell, `go` only
  for tab switches and deliberate resets.
- **Layering.** R1: `lib/core/**` must not import `lib/features/**`. R2:
  `lib/features/X/**` must not import `lib/features/Y/**`. R3: `lib/**/domain/**` must not
  import drift, flutter, riverpod or go_router.
  **The baseline is 7 violations, all of them `progress` and `assessment` reaching into
  `features/metrics`.** This plan must not add an eighth. That is why Task 1 puts the
  average-minutes query on `QuizSessionRepository` instead of reusing
  `SessionShapeSignal`, which lives in `features/metrics`.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/storage/domain/question_outcome.dart` — `QuestionOutcome` and `DayTally`.
  In `domain/` because `features/quiz/domain` consumes them and R3 forbids domain code
  from importing the drift-backed repository file.
- `lib/features/quiz/domain/use_cases/count_today_backlog.dart` — splits one topic's
  questions into three disjoint buckets. Pure.
- `lib/features/quiz/domain/use_cases/build_today_plan.dart` — turns the buckets into the
  session the Start button will create, and counts it. Pure.
- `lib/features/quiz/presentation/today_providers.dart` — `todayTopicQueueProvider` and
  `sessionPanelProvider`.
- `lib/features/quiz/presentation/widgets/session_panel.dart` — the four states.
- `lib/features/settings/presentation/pages/session_building_page.dart` — the ordering
  setting the panel's link opens.
- Tests mirroring each of the above.

**Modify:**
- `lib/core/storage/data/repos/review_state_repository.dart` — `allStates`.
- `lib/core/storage/data/repos/attempts_repository.dart` — `questionOutcomes`, `tallyForDay`.
- `lib/features/quiz/data/repos/quiz_session_repository.dart` — `averageCompletedMinutes`.
- `lib/features/quiz/domain/selectors/weakness_selector.dart` — the field rename.
- `lib/features/quiz/domain/use_cases/start_today_session.dart` — feed the selectors in.
- `lib/features/quiz/presentation/quiz_controller.dart` — new provider wiring,
  `resumeToday`.
- `lib/features/quiz/presentation/quiz_page.dart` — a `resume` mode.
- `lib/features/quiz/presentation/quiz_tab_home.dart` — mount the panel.
- `lib/core/ui/components/stats_band.dart` — `centred` and `compact`, tabular figures.
- `lib/app/router.dart` — `/quiz/resume/:examId` and `/settings/sessions`.
- `lib/features/settings/presentation/settings_home_page.dart` — a row into the new page.

**Not touched:** the mock panel, the practice row counts and the flagged section, which are
Plan 2c. The practice picker, which is seam 3.

---

## Task 1: The four read queries

**Files:**
- Create: `lib/core/storage/domain/question_outcome.dart`
- Modify: `lib/core/storage/data/repos/review_state_repository.dart`
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Modify: `lib/features/quiz/data/repos/quiz_session_repository.dart`
- Test: `test/core/storage/data/repos/review_state_repository_test.dart` (exists, append)
- Test: `test/core/storage/data/repos/attempts_repository_outcomes_test.dart` (create)
- Test: `test/features/quiz/data/repos/quiz_session_repository_average_test.dart` (create)

**Interfaces:**
- Consumes: `AppDatabase`, `ReviewState`, `Attempt`, `AttemptItem`, all existing.
- Produces, relied on by Tasks 3, 5 and 7:
  - `QuestionOutcome({required int attempts, required int correct})`
  - `DayTally({required int answered, required int correct})`
  - `ReviewStateRepository.allStates() -> Future<List<ReviewState>>`
  - `AttemptsRepository.questionOutcomes({required ExamId examId, required DateTime now, Duration window}) -> Future<Map<QuestionId, QuestionOutcome>>`
  - `AttemptsRepository.tallyForDay({required ExamId examId, required DateTime day}) -> Future<DayTally>`
  - `QuizSessionRepository.averageCompletedMinutes({required String userId, required ExamId examId, int minimumSessions}) -> Future<int?>`

**Why `averageCompletedMinutes` and not `SessionShapeSignal`.** The signal already computes
this and lives in `lib/features/metrics/`. Reading it from `features/quiz` would be an R2
violation, and the baseline is 7, all of that exact shape. The signal also averages **mock
durations in with quiz sessions**, and a mock runs 3 hours 30, so a student with one mock
behind them would see an average session of over an hour on a ten-question panel. Quiz
sessions only is both layer-clean and the more truthful number.

**Seven is `SessionShapeSignal.minDataPoints`**, reused deliberately so the app has one
answer to "how much history is enough".

- [ ] **Step 1: Write the failing tests**

Create `lib/core/storage/domain/question_outcome.dart` first, since the tests import it.
It is a pair of plain value types with no logic, so it needs no test of its own:

```dart
/// How a single question has gone recently. Both figures are counted from
/// `attempts_local`, never estimated.
class QuestionOutcome {
  const QuestionOutcome({required this.attempts, required this.correct});

  final int attempts;
  final int correct;
}

/// One day's answering, for the session panel's "caught up" state.
class DayTally {
  const DayTally({required this.answered, required this.correct});

  static const empty = DayTally(answered: 0, correct: 0);

  final int answered;
  final int correct;
}
```

Append to `test/core/storage/data/repos/review_state_repository_test.dart`, inside its
existing `main()`, following the `setUp`/`tearDown` already in that file:

```dart
  test('allStates returns every stored state', () async {
    await repo.upsert(_state('q_1'));
    await repo.upsert(_state('q_2'));

    final states = await repo.allStates();

    expect(states.map((s) => s.questionId), unorderedEquals(['q_1', 'q_2']));
  });

  test('allStates is empty on a fresh database', () async {
    expect(await repo.allStates(), isEmpty);
  });
```

Reuse whatever `ReviewState` factory that file already defines. If it builds states inline
rather than through a helper, add `_state(String id)` at the bottom of the file returning a
`ReviewState` with that id and any valid values.

Create `test/core/storage/data/repos/attempts_repository_outcomes_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AttemptsRepository(db);
  });
  tearDown(() => db.close());

  AttemptItem item(String questionId, {required bool correct}) => AttemptItem(
        questionId: questionId,
        questionVersion: 1,
        chosenChoiceId: correct ? 'c_a' : 'c_b',
        correctChoiceId: 'c_a',
        responseMs: 1200,
      );

  Future<void> save(
    String id,
    DateTime startedAt,
    List<AttemptItem> items, {
    String examId = 'exam_cse_pro',
  }) =>
      repo.save(
        Attempt(
          id: id,
          examId: examId,
          startedAt: startedAt,
          completedAt: startedAt,
          items: items,
        ),
      );

  test('questionOutcomes counts attempts and corrects per question', () async {
    await save('a_1', DateTime.utc(2026, 8, 1), [
      item('q_1', correct: true),
      item('q_2', correct: false),
    ]);
    await save('a_2', DateTime.utc(2026, 8, 2), [
      item('q_1', correct: false),
    ]);

    final outcomes = await repo.questionOutcomes(
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 8, 3),
    );

    expect(outcomes['q_1']!.attempts, 2);
    expect(outcomes['q_1']!.correct, 1);
    expect(outcomes['q_2']!.attempts, 1);
    expect(outcomes['q_2']!.correct, 0);
  });

  test('questionOutcomes ignores attempts older than the window', () async {
    await save('a_old', DateTime.utc(2026, 6, 1), [item('q_1', correct: true)]);

    final outcomes = await repo.questionOutcomes(
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 8, 3),
      window: const Duration(days: 30),
    );

    expect(outcomes, isEmpty);
  });

  test('questionOutcomes ignores other exams', () async {
    await save(
      'a_1',
      DateTime.utc(2026, 8, 1),
      [item('q_1', correct: true)],
      examId: 'exam_upcat',
    );

    final outcomes = await repo.questionOutcomes(
      examId: 'exam_cse_pro',
      now: DateTime.utc(2026, 8, 3),
    );

    expect(outcomes, isEmpty);
  });

  test('tallyForDay counts only that local day', () async {
    await save('a_today', DateTime(2026, 8, 2, 9), [
      item('q_1', correct: true),
      item('q_2', correct: false),
    ]);
    await save('a_yesterday', DateTime(2026, 8, 1, 9), [
      item('q_3', correct: true),
    ]);

    final tally = await repo.tallyForDay(
      examId: 'exam_cse_pro',
      day: DateTime(2026, 8, 2, 21),
    );

    expect(tally.answered, 2);
    expect(tally.correct, 1);
  });

  test('tallyForDay is empty when nothing was answered', () async {
    final tally = await repo.tallyForDay(
      examId: 'exam_cse_pro',
      day: DateTime(2026, 8, 2),
    );

    expect(tally.answered, 0);
    expect(tally.correct, 0);
  });
}
```

Create `test/features/quiz/data/repos/quiz_session_repository_average_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late QuizSessionRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = QuizSessionRepository(db);
  });
  tearDown(() => db.close());

  Future<void> completed(String id, int minutes) {
    final startedAt = DateTime.utc(2026, 8, 1, 10);
    return db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: id,
            userId: 'local',
            examId: 'exam_cse_pro',
            origin: 'today_topic',
            questionIdsJson: '[]',
            startedAt: startedAt,
            completedAt: Value(startedAt.add(Duration(minutes: minutes))),
          ),
        );
  }

  test('returns null below the minimum number of sessions', () async {
    for (var i = 0; i < 6; i++) {
      await completed('s_$i', 10);
    }

    expect(
      await repo.averageCompletedMinutes(
        userId: 'local',
        examId: 'exam_cse_pro',
      ),
      isNull,
    );
  });

  test('averages once the minimum is reached', () async {
    for (var i = 0; i < 6; i++) {
      await completed('s_$i', 10);
    }
    await completed('s_6', 17);

    expect(
      await repo.averageCompletedMinutes(
        userId: 'local',
        examId: 'exam_cse_pro',
      ),
      11,
    );
  });

  test('ignores sessions that were never completed', () async {
    for (var i = 0; i < 7; i++) {
      await completed('s_$i', 10);
    }
    await db.into(db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: 's_open',
            userId: 'local',
            examId: 'exam_cse_pro',
            origin: 'today_topic',
            questionIdsJson: '[]',
            startedAt: DateTime.utc(2026, 8, 1, 10),
          ),
        );

    expect(
      await repo.averageCompletedMinutes(
        userId: 'local',
        examId: 'exam_cse_pro',
      ),
      10,
    );
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run:
```bash
flutter test test/core/storage/data/repos/review_state_repository_test.dart \
             test/core/storage/data/repos/attempts_repository_outcomes_test.dart \
             test/features/quiz/data/repos/quiz_session_repository_average_test.dart
```
Expected: FAIL. `allStates`, `questionOutcomes`, `tallyForDay` and
`averageCompletedMinutes` are not defined.

- [ ] **Step 3: Add `allStates`**

In `lib/core/storage/data/repos/review_state_repository.dart`, directly beneath
`dirtyStates`:

```dart
  /// Every stored state. `FsrsDueSelector` takes the whole list and filters it,
  /// so there is no narrower query worth having here.
  Future<List<ReviewState>> allStates() async {
    final rows = await _db.select(_db.reviewStateLocal).get();
    return rows.map(_hydrate).toList();
  }
```

- [ ] **Step 4: Add the two attempts queries**

In `lib/core/storage/data/repos/attempts_repository.dart`, add the import:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/question_outcome.dart';
```

and these two methods beneath `recentIncorrects`:

```dart
  /// How each question has gone inside [window]. The weakness reading groups
  /// these by topic; see `CountTodayBacklog`.
  Future<Map<QuestionId, QuestionOutcome>> questionOutcomes({
    required ExamId examId,
    required DateTime now,
    Duration window = const Duration(days: 30),
  }) async {
    final cutoff = now.subtract(window);
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(cutoff),
          ))
        .get();

    final attempts = <QuestionId, int>{};
    final corrects = <QuestionId, int>{};
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        attempts[item.questionId] = (attempts[item.questionId] ?? 0) + 1;
        if (item.isCorrect) {
          corrects[item.questionId] = (corrects[item.questionId] ?? 0) + 1;
        }
      }
    }

    return {
      for (final entry in attempts.entries)
        entry.key: QuestionOutcome(
          attempts: entry.value,
          correct: corrects[entry.key] ?? 0,
        ),
    };
  }

  /// Questions answered on one local day, and how many were right. Both are
  /// counted, never estimated: the session panel prints them as figures.
  Future<DayTally> tallyForDay({
    required ExamId examId,
    required DateTime day,
  }) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(start) &
                t.startedAt.isSmallerThanValue(end),
          ))
        .get();

    var answered = 0;
    var correct = 0;
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        answered++;
        if (item.isCorrect) correct++;
      }
    }
    return DayTally(answered: answered, correct: correct);
  }
```

- [ ] **Step 5: Add `averageCompletedMinutes`**

In `lib/features/quiz/data/repos/quiz_session_repository.dart`, beneath `restartActive`:

```dart
  /// The student's own average completed session, in whole minutes, or null
  /// when there is not enough history to average honestly.
  ///
  /// Mocks are deliberately excluded. A mock runs 3 hours 30, so folding one
  /// in would put an hour on a ten-question panel. `SessionShapeSignal` does
  /// include them, and is the right figure for its own surface, but reading it
  /// from here would also cross a feature boundary.
  ///
  /// [minimumSessions] matches `SessionShapeSignal.minDataPoints` so the app
  /// has one answer to "how much history is enough".
  Future<int?> averageCompletedMinutes({
    required String userId,
    required ExamId examId,
    int minimumSessions = 7,
  }) async {
    final rows = await (_db.select(_db.quizSessions)
          ..where(
            (row) =>
                row.userId.equals(userId) &
                row.examId.equals(examId) &
                row.completedAt.isNotNull(),
          ))
        .get();
    if (rows.length < minimumSessions) return null;

    var totalSeconds = 0;
    for (final row in rows) {
      totalSeconds += row.completedAt!.difference(row.startedAt).inSeconds;
    }
    return (totalSeconds / rows.length / 60).round();
  }
```

- [ ] **Step 6: Run the tests to verify they pass**

Run:
```bash
flutter test test/core/storage/data/repos/review_state_repository_test.dart \
             test/core/storage/data/repos/attempts_repository_outcomes_test.dart \
             test/features/quiz/data/repos/quiz_session_repository_average_test.dart
```
Expected: PASS.

- [ ] **Step 7: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage lib/features/quiz/data test/features/quiz/data
git commit -m "feat(storage): the reads the session panel needs

FsrsDueSelector takes every review state and the repository could only
return one at a time. Weakness needs per-question outcomes to group by
topic, the caught-up state needs one day's tally, and the available
state needs the student's own average session, counted from completed
quiz sessions only."
```

---

## Task 2: `WeaknessCandidate` carries a topic, not a subtopic

**Files:**
- Modify: `lib/features/quiz/domain/selectors/weakness_selector.dart`
- Test: `test/features/quiz/domain/selectors/weakness_selector_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `WeaknessCandidate({required Question question, required TopicId topicId, required double rollingAccuracy, required int attemptCount})`. Task 3 constructs these.

**Why.** Settled in the decision log on 2 August. There is no subtopic level anywhere in
this app: the authored lessons under `content/lessons/` are `subject/topic/lesson.md`, every
front matter carries `subject:` and `topic:` and no subtopic key, there is no subtopics
table, and nothing assigns `SubtopicId` in `lib/`. The field was never read by
`select()`, which ranks on `rollingAccuracy` and `question.id` only, so it was an empty
slot inviting a wrong fill.

**And the figures it carries change meaning.** `minAttempts = 5` against a *per question*
`attemptCount` would qualify a question only after it had been answered five times, which
almost never happens, so "weak spots" would print 0 forever. Aedwon settled the group
reading: a **topic** is weak when it has five or more recent attempts and 40% or more
wrong, and its questions are the candidates. `select()` needs no change at all for this;
only what the caller puts in the two figures changes, which is why the docstring below
says so explicitly.

- [ ] **Step 1: Update the test**

In `test/features/quiz/domain/selectors/weakness_selector_test.dart`, replace every
`subtopicId:` argument with `topicId:`, and add this test at the end of `main()`:

```dart
  test('candidates sharing a weak topic all qualify', () {
    final selected = WeaknessSelector.select([
      WeaknessCandidate(
        question: _question('q_1'),
        topicId: 'topic_algebra',
        rollingAccuracy: 0.3,
        attemptCount: 12,
      ),
      WeaknessCandidate(
        question: _question('q_2'),
        topicId: 'topic_algebra',
        rollingAccuracy: 0.3,
        attemptCount: 12,
      ),
    ]);

    expect(selected.map((q) => q.id), equals(['q_1', 'q_2']));
  });
```

Reuse the `Question` factory that file already defines. If it builds questions inline,
add `_question(String id)` at the bottom returning a `Question` with that id and any valid
values.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/selectors/weakness_selector_test.dart`
Expected: FAIL. `WeaknessCandidate` has no named parameter `topicId`.

- [ ] **Step 3: Rename the field**

Replace the `WeaknessCandidate` class in
`lib/features/quiz/domain/selectors/weakness_selector.dart` with:

```dart
/// One question offered to the weakness reading, carrying **its topic's**
/// recent record rather than its own.
///
/// The two figures are the topic's because a question is rarely answered five
/// times, so a per-question reading of [WeaknessSelector.minAttempts] would
/// never fire and the count would print 0 forever. Settled 2 August.
///
/// This field was `subtopicId` and was never assigned anything but null.
/// Subtopics do not exist in this app: the levels are subject, topic, lesson.
class WeaknessCandidate {
  const WeaknessCandidate({
    required this.question,
    required this.topicId,
    required this.rollingAccuracy,
    required this.attemptCount,
  });

  final Question question;
  final TopicId topicId;

  /// The topic's share of correct answers in the recent window, 0 to 1.
  final double rollingAccuracy;

  /// How many questions in the topic were answered in the recent window.
  final int attemptCount;
}
```

`SubtopicId` is no longer referenced here, so the `ids.dart` import may become unused.
`flutter analyze` will say so. `TopicId` also comes from `ids.dart`, so the import stays.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/quiz/domain/selectors/weakness_selector_test.dart`
Expected: PASS.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz/domain/selectors test/features/quiz/domain/selectors
git commit -m "refactor(quiz): weakness is read per topic, not per subtopic

The candidate carried a subtopic id that nothing ever filled, because
subtopics do not exist: the levels are subject, topic, lesson. It also
implied a per-question attempt count, which would need one question
answered five times before anything counted as weak."
```

---

## Task 3: `CountTodayBacklog` and `todayTopicQueueProvider`

**Files:**
- Create: `lib/features/quiz/domain/use_cases/count_today_backlog.dart`
- Create: `test/features/quiz/domain/use_cases/count_today_backlog_test.dart`
- Create: `lib/features/quiz/presentation/today_providers.dart`
- Create: `test/features/quiz/presentation/today_topic_queue_provider_test.dart`

**Interfaces:**
- Consumes: `FsrsDueSelector.select`, `WeaknessSelector.select`, `NewCardSelector.select`,
  `BuildTodayQueue.call`, `QuestionOutcome` from Task 1, `WeaknessCandidate` from Task 2.
- Produces, relied on by Tasks 4, 5 and 7:
  - `TopicBacklog({required List<Question> due, required List<Question> weakness, required List<Question> fresh})`
  - `CountTodayBacklog.forTopic({required TopicId topicId, required List<Question> questions, required List<ReviewState> states, required Map<QuestionId, Question> questionsById, required Map<QuestionId, QuestionOutcome> outcomes, required int capRemaining, required DateTime now}) -> TopicBacklog`
  - `todayTopicQueueProvider`, a `FutureProvider.family<List<TopicQueueRow>, ExamId>`

**Why `fresh` and not `new`.** `new` is a reserved word in Dart.

**The three buckets are disjoint, by construction:**

| Bucket | Rule |
|---|---|
| due | has a review state, and that state's `due` is not after now |
| weakness | has a review state, is **not** due, and its topic is weak |
| fresh | has **no** review state, and the daily new-card cap has room |

Without the exclusions a due question in a weak topic would be counted twice and the
composition line would not add up to the session length.

**`BuildTodayQueue` is already written and tested and this is its first caller.** Do not
rewrite it. It sorts by total descending, breaks ties on topic name, and marks the largest
backlog `isRecommended`. That recommended row is the topic today's session is named after,
which is what Section 5 means by "Today's session chooses the largest backlog".

- [ ] **Step 1: Write the failing test for `CountTodayBacklog`**

Create `test/features/quiz/domain/use_cases/count_today_backlog_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question_outcome.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/count_today_backlog.dart';
import 'package:flutter_test/flutter_test.dart';

Question question(String id, {String topicId = 'topic_algebra'}) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: topicId,
      language: 'en',
      stem: 'stem $id',
      choices: const [
        Choice(id: 'c_a', text: 'a', isCorrect: true),
        Choice(id: 'c_b', text: 'b', isCorrect: false),
      ],
      explanation: 'because',
    );

ReviewState state(String questionId, DateTime due) => ReviewState(
      questionId: questionId,
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 3,
      difficulty: 5,
      due: due,
      lastReview: due.subtract(const Duration(days: 1)),
      reps: 3,
      lapses: 0,
      elapsedDays: 1,
      scheduledDays: 1,
    );

void main() {
  final now = DateTime.utc(2026, 8, 2, 9);

  test('a question with no state and cap room is fresh', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: const [],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {},
      capRemaining: 10,
      now: now,
    );

    expect(backlog.fresh.map((q) => q.id), equals(['q_1']));
    expect(backlog.due, isEmpty);
    expect(backlog.weakness, isEmpty);
  });

  test('no fresh questions once the cap is used up', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: const [],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {},
      capRemaining: 0,
      now: now,
    );

    expect(backlog.fresh, isEmpty);
  });

  test('a state due in the past is due, and never also weak', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [state('q_1', DateTime.utc(2026, 8, 1))],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 10, correct: 1),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.due.map((q) => q.id), equals(['q_1']));
    expect(backlog.weakness, isEmpty);
    expect(backlog.fresh, isEmpty);
  });

  test('a seen, not-due question in a weak topic is weak', () {
    final questions = [question('q_1'), question('q_2')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [
        state('q_1', DateTime.utc(2026, 8, 20)),
        state('q_2', DateTime.utc(2026, 8, 20)),
      ],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 4, correct: 1),
        'q_2': QuestionOutcome(attempts: 4, correct: 1),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.weakness.map((q) => q.id), equals(['q_1', 'q_2']));
    expect(backlog.due, isEmpty);
  });

  test('a topic answered accurately has no weak questions', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [state('q_1', DateTime.utc(2026, 8, 20))],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 10, correct: 9),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.weakness, isEmpty);
  });

  test('a topic with too little history has no weak questions', () {
    final questions = [question('q_1')];

    final backlog = CountTodayBacklog.forTopic(
      topicId: 'topic_algebra',
      questions: questions,
      states: [state('q_1', DateTime.utc(2026, 8, 20))],
      questionsById: {for (final q in questions) q.id: q},
      outcomes: const {
        'q_1': QuestionOutcome(attempts: 4, correct: 0),
      },
      capRemaining: 10,
      now: now,
    );

    expect(backlog.weakness, isEmpty);
  });
}
```

Check `Choice`'s real constructor with
`grep -n "const factory Choice" -A 6 lib/core/storage/domain/choice.dart` and match it. If
its field is `label` rather than `text`, use that. Do the same for `ReviewState`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/use_cases/count_today_backlog_test.dart`
Expected: FAIL. `count_today_backlog.dart` does not exist.

- [ ] **Step 3: Write `CountTodayBacklog`**

Create `lib/features/quiz/domain/use_cases/count_today_backlog.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question_outcome.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/fsrs_due_selector.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/new_card_selector.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/weakness_selector.dart';

/// One topic's questions split three ways. The lists never overlap.
class TopicBacklog {
  const TopicBacklog({
    required this.due,
    required this.weakness,
    required this.fresh,
  });

  static const empty = TopicBacklog(due: [], weakness: [], fresh: []);

  final List<Question> due;
  final List<Question> weakness;

  /// Named `fresh` because `new` is reserved.
  final List<Question> fresh;

  int get total => due.length + weakness.length + fresh.length;
}

/// Splits a topic into what is due, what is weak and what has never been seen.
///
/// The three lists are kept disjoint on purpose. A due question inside a weak
/// topic would otherwise be counted in both, and the session panel's
/// composition line would not add up to the length of the session it
/// describes.
abstract final class CountTodayBacklog {
  static TopicBacklog forTopic({
    required TopicId topicId,
    required List<Question> questions,
    required List<ReviewState> states,
    required Map<QuestionId, Question> questionsById,
    required Map<QuestionId, QuestionOutcome> outcomes,
    required int capRemaining,
    required DateTime now,
  }) {
    final due = FsrsDueSelector.select(
      states: states,
      questionsById: questionsById,
      now: now,
      topicId: topicId,
    );
    final dueIds = {for (final question in due) question.id};
    final seenIds = {for (final state in states) state.questionId};

    var attempts = 0;
    var correct = 0;
    for (final question in questions) {
      final outcome = outcomes[question.id];
      if (outcome == null) continue;
      attempts += outcome.attempts;
      correct += outcome.correct;
    }
    // A topic nobody has answered is not weak, it is unknown. Reading it as
    // 100% accurate keeps it out of the weakness bucket without a special case.
    final accuracy = attempts == 0 ? 1.0 : correct / attempts;

    final weakness = WeaknessSelector.select([
      for (final question in questions)
        if (seenIds.contains(question.id) && !dueIds.contains(question.id))
          WeaknessCandidate(
            question: question,
            topicId: topicId,
            rollingAccuracy: accuracy,
            attemptCount: attempts,
          ),
    ]);

    final fresh = NewCardSelector.select(
      questions: questions,
      seenQuestionIds: seenIds,
      capRemaining: capRemaining,
      limit: capRemaining,
      topicId: topicId,
    );

    return TopicBacklog(due: due, weakness: weakness, fresh: fresh);
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/quiz/domain/use_cases/count_today_backlog_test.dart`
Expected: PASS, 6 tests.

- [ ] **Step 5: Write the failing test for the provider**

Create `test/features/quiz/presentation/today_topic_queue_provider_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/today_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('an exam with no content yields no rows', () async {
    final rows = await container.read(
      todayTopicQueueProvider('exam_cse_pro').future,
    );

    expect(rows, isEmpty);
  });

  test('topics with unseen questions come back as fresh backlog', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2'],
    );

    final rows = await container.read(
      todayTopicQueueProvider('exam_cse_pro').future,
    );

    expect(rows.single.topicName, 'Algebra');
    expect(rows.single.newCount, 2);
    expect(rows.single.isRecommended, isTrue);
  });

  test('the largest backlog is the recommended topic', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1'],
    );
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_geometry',
      topicName: 'Geometry',
      questionIds: ['q_2', 'q_3'],
    );

    final rows = await container.read(
      todayTopicQueueProvider('exam_cse_pro').future,
    );

    expect(rows.first.topicId, 'topic_geometry');
    expect(rows.first.isRecommended, isTrue);
    expect(rows.last.isRecommended, isFalse);
  });
}
```

`seedTopicWithQuestions` does not exist. Add it to `test/helpers/in_memory_database.dart`,
inserting an exam, a subject, a topic and the questions, so Tasks 5 and 7 can reuse it.
Read that file first and match its existing style. The columns it must fill are on
`Exams`, `Subjects`, `Topics` and `Questions` in `lib/core/storage/data/tables/`.
`Questions` needs `examIdsJson` and `choicesJson` as JSON strings.

- [ ] **Step 6: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/today_topic_queue_provider_test.dart`
Expected: FAIL. `today_providers.dart` does not exist.

- [ ] **Step 7: Write the provider**

Create `lib/features/quiz/presentation/today_providers.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/topic_queue_row.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_queue.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/count_today_backlog.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The user id every local write already uses. Mirrors `quiz_controller.dart`.
const todayUserId = 'local';

/// How far back the weakness reading looks.
const weaknessWindow = Duration(days: 30);

/// Everything the panel and the queue read, gathered once so the two never
/// disagree about the state of the day.
class TodayInputs {
  const TodayInputs({
    required this.topics,
    required this.questionsByTopic,
    required this.backlogByTopic,
    required this.now,
  });

  final List<TopicQueueInput> topics;
  final Map<TopicId, List<Question>> questionsByTopic;
  final Map<TopicId, TopicBacklog> backlogByTopic;
  final DateTime now;

  List<Question> get allQuestions =>
      [for (final questions in questionsByTopic.values) ...questions];
}

final todayInputsProvider =
    FutureProvider.family<TodayInputs, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final now = ref.watch(nowProvider)();

  final topics = await content.topicsByExam(examId);
  final questionsByTopic = <TopicId, List<Question>>{};
  for (final topic in topics) {
    questionsByTopic[topic.id] = await content.questionsByTopic(topic.id);
  }
  final questionsById = <QuestionId, Question>{
    for (final questions in questionsByTopic.values)
      for (final question in questions) question.id: question,
  };

  final states = await ref.watch(reviewStateRepositoryProvider).allStates();
  final outcomes = await ref.watch(attemptsRepositoryProvider).questionOutcomes(
        examId: examId,
        now: now,
        window: weaknessWindow,
      );

  final preferences = await ref.watch(quizPreferencesRepositoryProvider).read();
  final introduced =
      await ref.watch(newCardIntroRepositoryProvider).countForDay(
            userId: todayUserId,
            examId: examId,
            day: now,
          );
  final capRemaining =
      (preferences.newCardCap - introduced).clamp(0, preferences.newCardCap);

  return TodayInputs(
    topics: [
      for (final topic in topics)
        TopicQueueInput(topicId: topic.id, topicName: topic.name),
    ],
    questionsByTopic: questionsByTopic,
    backlogByTopic: {
      for (final topic in topics)
        topic.id: CountTodayBacklog.forTopic(
          topicId: topic.id,
          questions: questionsByTopic[topic.id] ?? const [],
          states: states,
          questionsById: questionsById,
          outcomes: outcomes,
          capRemaining: capRemaining,
          now: now,
        ),
    },
    now: now,
  );
});

/// Every topic in the exam with its backlog, largest first, the largest marked
/// recommended. The recommended row is the topic today's session is named
/// after.
final todayTopicQueueProvider =
    FutureProvider.family<List<TopicQueueRow>, ExamId>((ref, examId) async {
  final inputs = await ref.watch(todayInputsProvider(examId).future);
  return BuildTodayQueue.call(
    topics: inputs.topics,
    dueCounts: {
      for (final entry in inputs.backlogByTopic.entries)
        entry.key: entry.value.due.length,
    },
    weaknessCounts: {
      for (final entry in inputs.backlogByTopic.entries)
        entry.key: entry.value.weakness.length,
    },
    newCounts: {
      for (final entry in inputs.backlogByTopic.entries)
        entry.key: entry.value.fresh.length,
    },
  );
});
```

**`newCardCapReached` is not passed.** `CountTodayBacklog` already returns an empty `fresh`
list when `capRemaining` is 0, so passing the flag as well would zero a count that is
already zero. Leave the parameter at its default.

Check that `reviewStateRepositoryProvider`, `attemptsRepositoryProvider` and
`contentRepositoryProvider` are exported from `core/storage/storage.dart`, which
`quiz_controller.dart` already relies on. `quizPreferencesRepositoryProvider` and
`newCardIntroRepositoryProvider` live in `quiz_controller.dart`.

- [ ] **Step 8: Run the tests to verify they pass**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 9: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib/features/quiz test/features/quiz test/helpers
git commit -m "feat(quiz): the today queue reads real backlogs

BuildTodayQueue has been written and tested since the storage work and
nothing in lib/ ever called it. The three selectors now split each topic
into due, weak and unseen, kept disjoint so the counts add up."
```

---

## Task 4: `BuildTodayPlan`

**Files:**
- Create: `lib/features/quiz/domain/use_cases/build_today_plan.dart`
- Create: `test/features/quiz/domain/use_cases/build_today_plan_test.dart`

**Interfaces:**
- Consumes: `TopicBacklog` from Task 3, `PickContext`, `TodayTopicPicker`,
  `TodayInterleavedPicker`, `QuizPreferences`, `QuizOrdering`, all existing.
- Produces, relied on by Tasks 5, 7 and 8:
  - `TodaySessionPlan({required List<Question> questions, required int dueCount, required int weaknessCount, required int freshCount, TopicId? topicId, String? topicName})` with `bool get isEmpty` and `int get length`
  - `BuildTodayPlan.call({required List<Question> due, required List<Question> weakness, required List<Question> fresh, required List<Question> allQuestions, required QuizPreferences preferences, TopicId? topicId, String? topicName, QuestionPicker? topicPicker, QuestionPicker? interleavedPicker}) -> TodaySessionPlan`

**Why this exists.** The panel prints `6 due · 3 weak spots · 1 new` and the Start button
creates a session. If those are two code paths they will disagree, and the line becomes a
figure this project invented. One pure function produces both: the panel reads its counts,
`StartTodaySession` persists its questions.

**The counts are of the picked session, not of the backlog.** The spec's example adds to
ten, which is the session length. A backlog of 40 due cards still yields "6 due" in a
ten-question session.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/domain/use_cases/build_today_plan_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:flutter_test/flutter_test.dart';

Question question(String id, {String topicId = 'topic_algebra'}) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: topicId,
      language: 'en',
      stem: 'stem $id',
      choices: const [
        Choice(id: 'c_a', text: 'a', isCorrect: true),
        Choice(id: 'c_b', text: 'b', isCorrect: false),
      ],
      explanation: 'because',
    );

List<Question> many(String prefix, int count, {String topicId = 'topic_algebra'}) =>
    [for (var i = 0; i < count; i++) question('$prefix$i', topicId: topicId)];

void main() {
  QuizPreferences prefs({
    int sessionLength = 10,
    QuizOrdering ordering = QuizOrdering.blocked,
  }) =>
      QuizPreferences(
        sessionLength: sessionLength,
        ordering: ordering,
        newCardCap: 10,
      );

  test('an empty backlog makes an empty plan', () {
    final plan = BuildTodayPlan.call(
      due: const [],
      weakness: const [],
      fresh: const [],
      allQuestions: const [],
      preferences: prefs(),
    );

    expect(plan.isEmpty, isTrue);
    expect(plan.length, 0);
  });

  test('the plan is no longer than the session length', () {
    final due = many('d_', 40);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(),
    );

    expect(plan.length, 10);
  });

  test('the counts add up to the length of the plan', () {
    final due = many('d_', 20);
    final weakness = many('w_', 20);
    final fresh = many('f_', 20);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: weakness,
      fresh: fresh,
      allQuestions: [...due, ...weakness, ...fresh],
      preferences: prefs(),
    );

    expect(
      plan.dueCount + plan.weaknessCount + plan.freshCount,
      equals(plan.length),
    );
  });

  test('due leads the composition when there is due work', () {
    final due = many('d_', 20);
    final weakness = many('w_', 20);
    final fresh = many('f_', 20);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: weakness,
      fresh: fresh,
      allQuestions: [...due, ...weakness, ...fresh],
      preferences: prefs(),
    );

    expect(plan.dueCount, 6);
    expect(plan.weaknessCount, 3);
    expect(plan.freshCount, 1);
  });

  test('the plan carries the topic it is named after', () {
    final due = many('d_', 12);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(),
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    expect(plan.topicId, 'topic_algebra');
    expect(plan.topicName, 'Algebra');
  });

  test('the interleaved tail draws from other topics', () {
    final due = [
      ...many('d_', 12),
      ...many('o_', 12, topicId: 'topic_geometry'),
    ];

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(ordering: QuizOrdering.interleavedTail),
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    expect(
      plan.questions.map((q) => q.topicId).toSet(),
      contains('topic_geometry'),
    );
  });

  test('all-due length asks for everything available', () {
    final due = many('d_', 14);

    final plan = BuildTodayPlan.call(
      due: due,
      weakness: const [],
      fresh: const [],
      allQuestions: due,
      preferences: prefs(
        sessionLength: QuizPreferences.allDueSessionLength,
      ),
    );

    expect(plan.length, 14);
  });
}
```

The 6/3/1 expectation is not invented: `_compose` in `today_topic_picker.dart` uses
`(requested * 0.6).floor()` for due, `(requested * 0.3).floor()` for weakness and the
remainder for new. At ten questions that is exactly 6, 3 and 1, which is the spec's own
example line.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/use_cases/build_today_plan_test.dart`
Expected: FAIL. `build_today_plan.dart` does not exist.

- [ ] **Step 3: Write `BuildTodayPlan`**

Create `lib/features/quiz/domain/use_cases/build_today_plan.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/today_interleaved_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/today_topic_picker.dart';

/// The session today's panel describes and the Start button creates.
///
/// The three counts describe **this plan**, not the backlog behind it, which
/// is why they sum to [length]. The panel prints them as
/// "6 due · 3 weak spots · 1 new", so they have to be the makeup of the
/// questions the student is about to be asked.
class TodaySessionPlan {
  const TodaySessionPlan({
    required this.questions,
    required this.dueCount,
    required this.weaknessCount,
    required this.freshCount,
    this.topicId,
    this.topicName,
  });

  static const empty = TodaySessionPlan(
    questions: [],
    dueCount: 0,
    weaknessCount: 0,
    freshCount: 0,
  );

  final List<Question> questions;
  final int dueCount;
  final int weaknessCount;
  final int freshCount;

  /// The topic the session is named after, even when the ordering interleaves
  /// other topics into it.
  final TopicId? topicId;
  final String? topicName;

  bool get isEmpty => questions.isEmpty;

  int get length => questions.length;
}

/// Builds today's session from the three buckets and counts what it built.
///
/// One function so the panel's composition line and the session the Start
/// button creates cannot drift apart. Before this existed,
/// `StartTodaySession` passed every question as `newQuestions` and left
/// `dueQuestions` and `weaknessQuestions` empty, so today's session was the
/// first N questions of the exam in seed order.
abstract final class BuildTodayPlan {
  static TodaySessionPlan call({
    required List<Question> due,
    required List<Question> weakness,
    required List<Question> fresh,
    required List<Question> allQuestions,
    required QuizPreferences preferences,
    TopicId? topicId,
    String? topicName,
    QuestionPicker? topicPicker,
    QuestionPicker? interleavedPicker,
  }) {
    final isBlocked = preferences.ordering == QuizOrdering.blocked;
    final requested =
        preferences.sessionLength == QuizPreferences.allDueSessionLength
            ? allQuestions.length
            : preferences.sessionLength;

    final context = PickContext(
      allQuestions: allQuestions,
      dueQuestions: due,
      weaknessQuestions: weakness,
      newQuestions: fresh,
      requestedLength: requested,
      // Only the blocked ordering confines the pick to one topic. The other
      // two still name the session after `topicId`; they just draw the tail
      // from elsewhere, which is Section 5's whole point.
      topicId: isBlocked ? topicId : null,
    );

    final picked = isBlocked
        ? (topicPicker ?? TodayTopicPicker()).pick(context)
        : (interleavedPicker ?? TodayInterleavedPicker()).pick(context);

    final dueIds = {for (final question in due) question.id};
    final weaknessIds = {for (final question in weakness) question.id};
    final freshIds = {for (final question in fresh) question.id};

    var dueCount = 0;
    var weaknessCount = 0;
    var freshCount = 0;
    for (final question in picked) {
      if (dueIds.contains(question.id)) {
        dueCount++;
      } else if (weaknessIds.contains(question.id)) {
        weaknessCount++;
      } else if (freshIds.contains(question.id)) {
        freshCount++;
      }
    }

    return TodaySessionPlan(
      questions: picked,
      dueCount: dueCount,
      weaknessCount: weaknessCount,
      freshCount: freshCount,
      topicId: topicId,
      topicName: topicName,
    );
  }
}
```

**A question can reach the pick through the composer's fallback pass on `allQuestions`,
in which case it lands in none of the three sets and is counted in none.** That is why the
"counts add up" test passes only when the three buckets between them cover what was picked.
If you make that test fail by widening the fallback, do not paper over it by adding an
"other" count. Say so instead: the composition line has no fourth word.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/quiz/domain/use_cases/build_today_plan_test.dart`
Expected: PASS, 7 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz/domain/use_cases/build_today_plan.dart \
        test/features/quiz/domain/use_cases/build_today_plan_test.dart
git commit -m "feat(quiz): one function builds today's session and counts it

The panel prints the session's makeup and the Start button creates the
session. Two code paths would disagree, and the line would become a
number this app made up."
```

---

## Task 5: `StartTodaySession` feeds the selectors

**Files:**
- Modify: `lib/features/quiz/domain/use_cases/start_today_session.dart`
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Test: `test/features/quiz/domain/use_cases/start_today_session_test.dart`

**Interfaces:**
- Consumes: `BuildTodayPlan.call` and `TodaySessionPlan` from Task 4.
- Produces:
  - `StartTodaySession.call({required String userId, required ExamId examId, required QuizPreferences preferences, required DateTime now, TopicId? topicId, TodaySessionPlan? plan})`, unchanged in return type
  - the constructor gains no required parameters

**The design.** `StartTodaySession` does not gain repositories. The provider in Task 7
already holds the built plan, so it passes it in. When `plan` is null the use case falls
back to its current behaviour so `QuizController.startToday` and the existing tests keep
working unchanged. This keeps the diff small and keeps the use case out of the business of
gathering.

**One behaviour change beyond the plan.** The session now records `topicId` whatever the
ordering. Today it writes null unless the ordering is blocked, which is why the
in-progress state could not say "You stopped partway through **Chemistry**". Section 5 is
explicit that under the interleaved tail "the session is still named after one topic and
still feels like that topic", so the name belongs on the row. The **pick** is unaffected:
`BuildTodayPlan` still passes `topicId: null` into `PickContext` for the non-blocked
orderings.

- [ ] **Step 1: Write the failing test**

Append to `test/features/quiz/domain/use_cases/start_today_session_test.dart`, inside its
existing `main()`:

```dart
  test('a supplied plan is the session that gets created', () async {
    final plan = TodaySessionPlan(
      questions: [_question('q_only')],
      dueCount: 1,
      weaknessCount: 0,
      freshCount: 0,
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    final result = await StartTodaySession(
      content: content,
      sessions: sessions,
    )(
      userId: 'local',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences.defaults,
      now: DateTime.utc(2026, 8, 2),
      plan: plan,
    );

    final session = (result as StartTodaySessionStarted).session;
    expect(session.questions.map((q) => q.id), equals(['q_only']));
  });

  test('an empty plan reports no questions', () async {
    final result = await StartTodaySession(
      content: content,
      sessions: sessions,
    )(
      userId: 'local',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences.defaults,
      now: DateTime.utc(2026, 8, 2),
      plan: TodaySessionPlan.empty,
    );

    expect(result, isA<StartTodaySessionNoQuestions>());
  });

  test('the named topic is recorded under the interleaved tail', () async {
    final plan = TodaySessionPlan(
      questions: [_question('q_only')],
      dueCount: 1,
      weaknessCount: 0,
      freshCount: 0,
      topicId: 'topic_algebra',
      topicName: 'Algebra',
    );

    final result = await StartTodaySession(
      content: content,
      sessions: sessions,
    )(
      userId: 'local',
      examId: 'exam_cse_pro',
      preferences: QuizPreferences(
        sessionLength: 10,
        ordering: QuizOrdering.interleavedTail,
        newCardCap: 10,
      ),
      now: DateTime.utc(2026, 8, 2),
      plan: plan,
    );

    final session = (result as StartTodaySessionStarted).session;
    expect(session.topicId, 'topic_algebra');
  });
```

Read the top of that file first. It already builds `content` and `sessions`; reuse those
names and whatever `Question` factory it defines rather than adding another. Add the
imports for `TodaySessionPlan` and `QuizOrdering`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/use_cases/start_today_session_test.dart`
Expected: FAIL. `call` has no named parameter `plan`.

- [ ] **Step 3: Rewrite `call`**

In `lib/features/quiz/domain/use_cases/start_today_session.dart`, add the import:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_plan.dart';
```

and replace the body of `call` with:

```dart
  Future<StartTodaySessionResult> call({
    required String userId,
    required ExamId examId,
    required QuizPreferences preferences,
    required DateTime now,
    TopicId? topicId,
    TodaySessionPlan? plan,
  }) async {
    final resolved = plan ??
        await _planFromContent(
          examId: examId,
          preferences: preferences,
          topicId: topicId,
        );

    if (resolved.isEmpty) {
      return const StartTodaySessionNoQuestions(
        'No questions are available for today.',
      );
    }

    final origin = preferences.ordering != QuizOrdering.blocked
        ? SessionOrigin.todayInterleaved
        : SessionOrigin.todayTopic;
    // The named topic is recorded whatever the ordering. Under the interleaved
    // tail the session is still named after one topic, and the tab's
    // "Still going" state has to be able to say which.
    final namedTopicId = resolved.topicId ?? topicId;

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: resolved.questions,
      startedAt: now,
      origin: origin,
      topicId: namedTopicId,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: origin,
      topicId: namedTopicId,
      questionIds: resolved.questions.map((question) => question.id).toList(),
      startedAt: now,
    );
    return StartTodaySessionStarted(session);
  }

  /// The fallback for callers that have not gathered a plan, which is
  /// `QuizController.startToday`. It picks from content alone, so it has no
  /// review states to work from and the session is composed of unseen
  /// questions. The Quiz tab always supplies a plan.
  Future<TodaySessionPlan> _planFromContent({
    required ExamId examId,
    required QuizPreferences preferences,
    TopicId? topicId,
  }) async {
    final allQuestions = topicId == null
        ? await _questionsByExam(examId)
        : await _content.questionsByTopic(topicId);
    return BuildTodayPlan.call(
      due: const [],
      weakness: const [],
      fresh: allQuestions,
      allQuestions: allQuestions,
      preferences: preferences,
      topicId: topicId,
      topicPicker: _topicPicker,
      interleavedPicker: _interleavedPicker,
    );
  }
```

`PickContext`, `TodayTopicPicker` and `TodayInterleavedPicker` are no longer referenced
directly in this file. `flutter analyze` will name the unused imports; remove them.

- [ ] **Step 4: Pass the plan from the controller**

In `lib/features/quiz/presentation/quiz_controller.dart`, change `startToday` to accept
and forward a plan:

```dart
  Future<void> startToday({
    required ExamId examId,
    TopicId? topicId,
    TodaySessionPlan? plan,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final preferences =
          await _ref.read(quizPreferencesRepositoryProvider).read();
      final result = await _ref.read(startTodaySessionProvider)(
        userId: _localUserId,
        examId: examId,
        topicId: topicId,
        preferences: preferences,
        now: now,
        plan: plan,
      );
```

The rest of the method is unchanged. Add the `build_today_plan.dart` import.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/features/quiz/`
Expected: PASS. If `session_lifecycle_test.dart` or `quiz_controller` tests fail, read the
failure before changing them: a session that now records a topic where it did not before is
the intended change, and those expectations should be updated to match.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "fix(quiz): today's session stops being the first ten questions

StartTodaySession passed every question as newQuestions and left due and
weakness empty, so the composer's due target was always zero and the
session fell through to seed order. It now takes the plan the selectors
built, and records the topic it is named after whatever the ordering."
```

---

## Task 6: Resume is reachable

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/quiz/presentation/quiz_resume_test.dart` (create)

**Interfaces:**
- Consumes: `resumeSessionProvider`, which exists and has never been read by any page.
- Produces: `QuizController.resumeToday({required ExamId examId})`,
  `QuizPageMode.resume`, and the route `/quiz/resume/:examId`. Task 8's Resume button
  pushes it.

**Why this is in 2b.** The panel's fourth state offers "Resume". Nothing in `lib/` calls
`ResumeSession`, and `QuizPage` in `today` mode calls `startToday`, which mints a second
session row while the abandoned one stays open. A Resume button wired to the existing route
would silently discard the student's progress, which is the opposite of "Every answer was
saved."

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/presentation/quiz_resume_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('resuming with no open session fails rather than starting one',
      () async {
    await container
        .read(quizControllerProvider.notifier)
        .resumeToday(examId: 'exam_cse_pro');

    expect(container.read(quizControllerProvider), isA<QuizFailure>());
  });

  test('resuming returns the questions already saved', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );
    await QuizSessionRepository(db).create(
      sessionId: 's_open',
      userId: 'local',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.todayTopic,
      topicId: 'topic_algebra',
      questionIds: const ['q_1', 'q_2', 'q_3'],
      startedAt: DateTime.utc(2026, 8, 2, 9),
    );

    await container
        .read(quizControllerProvider.notifier)
        .resumeToday(examId: 'exam_cse_pro');

    final state = container.read(quizControllerProvider) as QuizRunning;
    expect(state.session.sessionId, 's_open');
    expect(state.persisted, isTrue);
  });
}
```

Add the imports for `QuizSessionRepository` and `SessionOrigin`. `seedTopicWithQuestions`
is the helper added in Task 3.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/quiz_resume_test.dart`
Expected: FAIL. `resumeToday` is not defined.

- [ ] **Step 3: Add `resumeToday`**

In `lib/features/quiz/presentation/quiz_controller.dart`, directly beneath `startToday`:

```dart
  /// Picks up the session already open for this exam. Never creates one: if
  /// there is nothing to resume the panel should not have offered the button.
  Future<void> resumeToday({required ExamId examId}) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final session = await _ref.read(resumeSessionProvider)(
        userId: _localUserId,
        examId: examId,
      );
      if (session == null) {
        state = const QuizFailure('There is no session to pick up.');
        return;
      }
      state = QuizRunning(
        session: session,
        questionShownAt: now,
        persisted: true,
      );
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }
```

- [ ] **Step 4: Add the page mode and the route**

In `lib/features/quiz/presentation/quiz_page.dart`, add `resume` to `QuizPageMode`:

```dart
enum QuizPageMode { quick, today, drill, retake, inline, resume }
```

and a case in the `initState` switch, beside `QuizPageMode.today`:

```dart
        case QuizPageMode.resume:
          controller.resumeToday(examId: widget.examId);
```

In `lib/app/router.dart`, beneath the `/quiz/today/:examId` route:

```dart
      GoRoute(
        path: '/quiz/resume/:examId',
        builder: (_, state) => QuizPage(
          examId: state.pathParameters['examId']!,
          mode: QuizPageMode.resume,
        ),
      ),
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/features/quiz/`
Expected: PASS. The switch in `quiz_page.dart` is exhaustive, so a missing case is an
analyzer error rather than a silent fallthrough.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz lib/app/router.dart test/features/quiz
git commit -m "feat(quiz): an open session can be picked up again

ResumeSession has had a provider and no caller. Reopening a half-finished
session went through startToday, which left the old row open and made a
new one, so the answers already given were stranded."
```

---

## Task 7: `sessionPanelProvider`, the four states

**Files:**
- Modify: `lib/features/quiz/presentation/today_providers.dart`
- Test: `test/features/quiz/presentation/session_panel_provider_test.dart` (create)

**Interfaces:**
- Consumes: `todayInputsProvider` and `todayTopicQueueProvider` from Task 3,
  `BuildTodayPlan` and `TodaySessionPlan` from Task 4, the four queries from Task 1,
  `assessmentRepositoryProvider` and `AssessmentQuestionSelector`, both existing.
- Produces, relied on by Task 8:

```dart
sealed class SessionPanelState
class SessionPanelNeedsAssessment  { final int questionCount; }
class SessionPanelInProgress       { final int answered; final int total; final String? topicName; }
class SessionPanelCaughtUp         { final int answeredToday; final int correctToday; }
class SessionPanelAvailable        { final TodaySessionPlan plan; final int? averageMinutes; }
```
  plus `sessionPanelProvider`, a `FutureProvider.family<SessionPanelState, ExamId>`.

**The order of the checks, and why.**

1. **In progress** wins over everything. A student with a half-finished session in front of
   them does not want to be told to take the assessment.
2. **Needs assessment.** `assessmentRepository.hasCompletedForExam` is false. The count is
   `AssessmentQuestionSelector.select(examId).length`, which is the output of a named
   algorithm used as designed: 21 with 7 contributing topics, 18 once all 18 are authored.
   Do not hardcode 21.
3. **Caught up** when the plan is empty.
4. **Available** otherwise.

**`topicName` is nullable on the in-progress state.** Sessions created before Task 5 landed
have a null `topicId`, and so do drill and inline sessions. Task 8 has a sentence for that
case.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/presentation/session_panel_provider_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/today_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<SessionPanelState> read() =>
      container.read(sessionPanelProvider('exam_cse_pro').future);

  test('a student who has not been assessed is asked to be', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );

    final state = await read();

    expect(state, isA<SessionPanelNeedsAssessment>());
    expect((state as SessionPanelNeedsAssessment).questionCount, 3);
  });

  test('an assessed student with a backlog gets a session', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );
    await AssessmentRepository(db).saveResult(
      'exam_cse_pro',
      DateTime.utc(2026, 8, 1),
      const [],
    );

    final state = await read();

    expect(state, isA<SessionPanelAvailable>());
    expect((state as SessionPanelAvailable).plan.length, 3);
  });

  test('the average minutes are withheld below seven sessions', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1'],
    );
    await AssessmentRepository(db).saveResult(
      'exam_cse_pro',
      DateTime.utc(2026, 8, 1),
      const [],
    );

    final state = await read() as SessionPanelAvailable;

    expect(state.averageMinutes, isNull);
  });

  test('an assessed student with nothing left is caught up', () async {
    await AssessmentRepository(db).saveResult(
      'exam_cse_pro',
      DateTime.utc(2026, 8, 1),
      const [],
    );

    final state = await read();

    expect(state, isA<SessionPanelCaughtUp>());
  });

  test('an open session outranks every other state', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2', 'q_3'],
    );
    await QuizSessionRepository(db).create(
      sessionId: 's_open',
      userId: 'local',
      examId: 'exam_cse_pro',
      origin: SessionOrigin.todayTopic,
      topicId: 'topic_algebra',
      questionIds: const ['q_1', 'q_2', 'q_3'],
      startedAt: DateTime.utc(2026, 8, 2, 9),
    );

    final state = await read();

    expect(state, isA<SessionPanelInProgress>());
    final inProgress = state as SessionPanelInProgress;
    expect(inProgress.total, 3);
    expect(inProgress.answered, 0);
    expect(inProgress.topicName, 'Algebra');
  });
}
```

Add the `AssessmentRepository` import.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/session_panel_provider_test.dart`
Expected: FAIL. `SessionPanelState` is not defined.

- [ ] **Step 3: Add the states and the provider**

Append to `lib/features/quiz/presentation/today_providers.dart`:

```dart
/// What the session panel shows today. One per condition of the day, in the
/// order the panel checks them.
sealed class SessionPanelState {
  const SessionPanelState();
}

/// Nothing has been assessed yet, so there is no basis for a session.
class SessionPanelNeedsAssessment extends SessionPanelState {
  const SessionPanelNeedsAssessment(this.questionCount);

  /// The length `AssessmentQuestionSelector` will actually produce. Never a
  /// constant: it is 21 with seven contributing topics and 18 with eighteen.
  final int questionCount;
}

/// A session was left part way through. It is still open and still counted.
class SessionPanelInProgress extends SessionPanelState {
  const SessionPanelInProgress({
    required this.answered,
    required this.total,
    this.topicName,
  });

  final int answered;
  final int total;

  /// Null for sessions created before the topic was recorded, and for drills
  /// and inline lesson quizzes.
  final String? topicName;
}

/// Everything due, weak and new has been worked through for today.
class SessionPanelCaughtUp extends SessionPanelState {
  const SessionPanelCaughtUp({
    required this.answeredToday,
    required this.correctToday,
  });

  final int answeredToday;
  final int correctToday;
}

/// There is a session to start.
class SessionPanelAvailable extends SessionPanelState {
  const SessionPanelAvailable({required this.plan, this.averageMinutes});

  final TodaySessionPlan plan;

  /// The student's own average completed session, or null until seven have
  /// been finished. Never a projection of how long today will take.
  final int? averageMinutes;
}

/// The plan the Start button will create, built from the recommended topic.
final todaySessionPlanProvider =
    FutureProvider.family<TodaySessionPlan, ExamId>((ref, examId) async {
  final inputs = await ref.watch(todayInputsProvider(examId).future);
  final queue = await ref.watch(todayTopicQueueProvider(examId).future);
  if (queue.isEmpty) return TodaySessionPlan.empty;

  final named = queue.first;
  if (named.totalCount == 0) return TodaySessionPlan.empty;

  final preferences = await ref.watch(quizPreferencesRepositoryProvider).read();
  final due = <Question>[];
  final weakness = <Question>[];
  final fresh = <Question>[];
  for (final backlog in inputs.backlogByTopic.values) {
    due.addAll(backlog.due);
    weakness.addAll(backlog.weakness);
    fresh.addAll(backlog.fresh);
  }

  return BuildTodayPlan.call(
    due: due,
    weakness: weakness,
    fresh: fresh,
    allQuestions: inputs.allQuestions,
    preferences: preferences,
    topicId: named.topicId,
    topicName: named.topicName,
  );
});

final sessionPanelProvider =
    FutureProvider.family<SessionPanelState, ExamId>((ref, examId) async {
  final sessions = ref.watch(quizSessionRepositoryProvider);

  final open = await sessions.activeFor(userId: todayUserId, examId: examId);
  if (open != null) {
    final topicId = open.topicId;
    final topic = topicId == null
        ? null
        : await ref.watch(contentRepositoryProvider).topicById(topicId);
    return SessionPanelInProgress(
      answered: open.currentIndex,
      total: open.questionIds.length,
      topicName: topic?.name,
    );
  }

  final assessed = await ref
      .watch(assessmentRepositoryProvider)
      .hasCompletedForExam(examId);
  if (!assessed) {
    final questions = await AssessmentQuestionSelector(
      ref.watch(contentRepositoryProvider),
      ref.watch(reviewStateRepositoryProvider),
    ).select(examId);
    return SessionPanelNeedsAssessment(questions.length);
  }

  final plan = await ref.watch(todaySessionPlanProvider(examId).future);
  if (plan.isEmpty) {
    final tally = await ref.watch(attemptsRepositoryProvider).tallyForDay(
          examId: examId,
          day: ref.watch(nowProvider)(),
        );
    return SessionPanelCaughtUp(
      answeredToday: tally.answered,
      correctToday: tally.correct,
    );
  }

  return SessionPanelAvailable(
    plan: plan,
    averageMinutes: await sessions.averageCompletedMinutes(
      userId: todayUserId,
      examId: examId,
    ),
  );
});
```

Add the imports this needs: `build_today_plan.dart`, and
`package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart`.

**That last import crosses from `features/quiz` into `features/assessment`, which is an R2
violation.** Run `dart run tool/check_layering.dart` at Step 5. If the count rises from 7
to 8, **stop and report it** rather than committing. The fix, if it is needed, is to read
`assessmentRepositoryProvider.hasCompletedForExam` for the boolean and move the count
behind a provider that already lives in `features/assessment`, exported from
`lib/features/assessment/assessment.dart`. Prefer that shape if the barrel file already
exposes one.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/features/quiz/presentation/session_panel_provider_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart   # must still report 7, not 8
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "feat(quiz): the session panel's four conditions of the day

An open session outranks everything, then the assessment, then an empty
plan means caught up. The assessment's length is the selector's own
output rather than the 21 that was hardcoded into the mockups."
```

---

## Task 8: The panel

**Files:**
- Create: `lib/features/quiz/presentation/widgets/session_panel.dart`
- Create: `test/features/quiz/presentation/widgets/session_panel_test.dart`
- Modify: `lib/core/ui/components/stats_band.dart`
- Modify: `test/core/ui/components/stats_band_test.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`

**Interfaces:**
- Consumes: `RuledPanel` from Plan 2a, `StatsBand`, `BoardButton`, `SessionPanelState` and
  its four subclasses from Task 7.
- Produces: `SessionPanel({required Exam exam})`, a `ConsumerWidget`. Plan 2c mounts the
  mock panel directly beneath it.

**From the spec, Section 1:**

| State | Heading | Trailing count | Body |
|---|---|---|---|
| No assessment taken | "Start with the assessment" | computed length, e.g. "21 questions" | "A few questions from every subject, to find out where you stand. Everything Pantas gives you afterwards is built on it." Board button "Take the assessment" |
| Session available | "Today's session" | none | Two centred figures, the composition line, the settings link, board button "Start" |
| Caught up | "Today's session" | none | Two centred figures, no button at all |
| Session in progress | "Still going" | "6 of 10" | "You stopped partway through **Chemistry**. Every answer was saved." Board button "Resume", then Discard |

Figures: value in serif 21/700 with tabular figures, a 12px sans suffix in `inkMuted` where
one is needed, label beneath in 11.5 `inkMuted`, centred.

Composition line: one tabular line in 12.5 `inkMuted`, `6 due · 3 weak spots · 1 new`.
Beneath it a board 12/600 text action, "Change how sessions are built".

Resume and Discard: "Resume", then centred at 12.5 **"Discard this session"** in board
green.

**Two strings here are not quoted from the spec, and both are recorded in the decision
log:**

1. **The second figure's label is "your average".** The spec named the figure "duration",
   meaning how long today will take. That number cannot be printed: it is a measured
   response time multiplied by an assumption about questions not yet answered, which the
   figure rule forbids by name. Aedwon settled it on 2 August: questions only until seven
   sessions exist, then the measured average. The label has to say it is the average, or
   the figure reads as a prediction again.
2. **Zero segments drop out of the composition line.** "6 due · 0 weak spots · 1 new"
   reads badly and the spec's example has no zero in it. A segment with a count of zero is
   omitted. All three zero cannot happen: that is the caught-up state.

**Singular and plural.** "1 weak spot", not "1 weak spots". "1 new" and "1 due" need no
change.

- [ ] **Step 1: Add `centred` and `compact` to `StatsBand`**

The panel's figures are centred at 21px and `StatsBand` is left-aligned at 30px. Two
optional parameters rather than a second component: `RuledSection` and `RuledPanel` are
already two devices in this kit and a third near-duplicate is the defect this codebase
keeps producing.

In `lib/core/ui/components/stats_band.dart`, change the constructor and the two styles:

```dart
  const StatsBand({
    required this.figures,
    this.centred = false,
    this.compact = false,
    super.key,
  });

  final List<StatFigure> figures;

  /// Centres each figure in its column. The session panel and the Home spec's
  /// band are centred; the Progress table and the results pages are not.
  final bool centred;

  /// The 21px panel size rather than the 30px page size.
  final bool compact;
```

Inside `build`, replace the two style lines:

```dart
    final numeralStyle = styles.displayLarge.copyWith(
      fontSize: compact ? 21 : 30,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final suffixStyle = numeralStyle.copyWith(
      fontSize: compact ? 12 : 16,
      fontWeight: FontWeight.w400,
      color: colors.inkMuted,
    );
```

and the column's alignment:

```dart
          child: Column(
            crossAxisAlignment: centred
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
```

and the label style:

```dart
              Text(
                figure.label,
                textAlign: centred ? TextAlign.center : TextAlign.start,
                style: styles.bodySmall.copyWith(
                  fontSize: compact ? 11.5 : null,
                  color: colors.inkMuted,
                ),
              ),
```

Add `import 'dart:ui' show FontFeature;` at the top.

**Tabular figures become unconditional.** Every existing caller prints numerals that should
line up, so this is a fix rather than a variant. Add a test for it:

```dart
  testWidgets('figures use tabular numerals', (tester) async {
    await tester.pumpApp(
      const StatsBand(figures: [StatFigure(value: '11', label: 'points')]),
    );

    final text = tester.widget<Text>(find.text('11'));
    expect(text.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
  });
```

Match the pump helper `stats_band_test.dart` already uses.

- [ ] **Step 2: Write the failing panel test**

Create `test/features/quiz/presentation/widgets/session_panel_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/today_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/session_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

const _exam = Exam(
  id: 'exam_cse_pro',
  code: 'CSE_PRO',
  name: 'Civil Service Exam Professional',
  shortName: 'CSE Pro',
  language: 'en',
  isActive: true,
  subjects: [],
);

Future<void> pumpPanel(WidgetTester tester, SessionPanelState state) =>
    tester.pumpAppWithProviders(
      const Scaffold(body: SessionPanel(exam: _exam)),
      overrides: [
        sessionPanelProvider('exam_cse_pro').overrideWith((_) async => state),
      ],
    );

void main() {
  testWidgets('the assessment state names its own length', (tester) async {
    await pumpPanel(tester, const SessionPanelNeedsAssessment(21));
    await tester.pumpAndSettle();

    expect(find.text('Start with the assessment'), findsOneWidget);
    expect(find.text('21 questions'), findsOneWidget);
    expect(find.text('Take the assessment'), findsOneWidget);
  });

  testWidgets('the available state shows only questions without history',
      (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 6,
          weaknessCount: 3,
          freshCount: 1,
          topicName: 'Chemistry',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('questions'), findsOneWidget);
    expect(find.text('your average'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('the average appears once there is history', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 6,
          weaknessCount: 3,
          freshCount: 1,
        ),
        averageMinutes: 9,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('your average'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('the composition line reads as the spec writes it',
      (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 6,
          weaknessCount: 3,
          freshCount: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('6 due · 3 weak spots · 1 new'), findsOneWidget);
    expect(find.text('Change how sessions are built'), findsOneWidget);
  });

  testWidgets('a count of one is singular', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 9,
          weaknessCount: 1,
          freshCount: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('9 due · 1 weak spot'), findsOneWidget);
  });

  testWidgets('the caught up state offers no button', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelCaughtUp(answeredToday: 12, correctToday: 9),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('answered today'), findsOneWidget);
    expect(find.text('got right'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('the in progress state names the topic and counts the answers',
      (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelInProgress(
        answered: 6,
        total: 10,
        topicName: 'Chemistry',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Still going'), findsOneWidget);
    expect(find.text('6 of 10'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Discard this session'), findsOneWidget);
    expect(find.textContaining('Chemistry'), findsOneWidget);
  });

  testWidgets('an unnamed session still explains itself', (tester) async {
    await pumpPanel(
      tester,
      const SessionPanelInProgress(answered: 6, total: 10),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('You stopped partway through this session. '
          'Every answer was saved.'),
      findsOneWidget,
    );
  });
}
```

Check `Exam`'s real constructor with
`grep -n "const factory Exam" -A 12 lib/core/storage/domain/exam.dart` and match it.

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/widgets/session_panel_test.dart`
Expected: FAIL. `session_panel.dart` does not exist.

- [ ] **Step 4: Write the panel**

Create `lib/features/quiz/presentation/widgets/session_panel.dart`:

```dart
import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/today_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Quiz tab's first panel: one of four states, one per condition of the
/// day.
class SessionPanel extends ConsumerWidget {
  const SessionPanel({required this.exam, super.key});

  final Exam exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sessionPanelProvider(exam.id));

    return async.when(
      loading: () => const RuledPanel(
        heading: "Today's session",
        child: FaintBars(),
      ),
      // The tab's own error state already carries the message. A second one
      // inside the panel would say it twice, and the exception is never shown.
      error: (_, __) => const SizedBox.shrink(),
      data: (state) => switch (state) {
        SessionPanelNeedsAssessment(:final questionCount) =>
          _NeedsAssessment(exam: exam, questionCount: questionCount),
        SessionPanelInProgress() => _InProgress(exam: exam, state: state),
        SessionPanelCaughtUp() => _CaughtUp(state: state),
        SessionPanelAvailable() => _Available(exam: exam, state: state),
      },
    );
  }
}

class _NeedsAssessment extends StatelessWidget {
  const _NeedsAssessment({required this.exam, required this.questionCount});

  final Exam exam;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return RuledPanel(
      heading: 'Start with the assessment',
      count: '$questionCount questions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A few questions from every subject, to find out where you '
            'stand. Everything Pantas gives you afterwards is built on it.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          BoardButton(
            label: 'Take the assessment',
            onPressed: () => context.push('/assessment/${exam.id}'),
          ),
        ],
      ),
    );
  }
}

class _Available extends ConsumerWidget {
  const _Available({required this.exam, required this.state});

  final Exam exam;
  final SessionPanelAvailable state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final averageMinutes = state.averageMinutes;

    return RuledPanel(
      heading: "Today's session",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatsBand(
            centred: true,
            compact: true,
            figures: [
              StatFigure(value: '${state.plan.length}', label: 'questions'),
              if (averageMinutes != null)
                StatFigure(
                  value: '$averageMinutes',
                  suffix: ' min',
                  // Not a prediction of today. It is what this student's
                  // finished sessions have actually taken, withheld until
                  // seven of them exist.
                  label: 'your average',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            compositionLine(
              dueCount: state.plan.dueCount,
              weaknessCount: state.plan.weaknessCount,
              freshCount: state.plan.freshCount,
            ),
            textAlign: TextAlign.center,
            style: styles.bodySmall.copyWith(
              fontSize: 12.5,
              color: colors.inkMuted,
            ),
          ),
          const SizedBox(height: 6),
          _BoardTextAction(
            label: 'Change how sessions are built',
            onTap: () => context.push('/settings/sessions'),
          ),
          const SizedBox(height: 12),
          BoardButton(
            label: 'Start',
            onPressed: () => unawaited(_start(context, ref)),
          ),
        ],
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    unawaited(context.push('/quiz/today/${exam.id}'));
  }
}

class _CaughtUp extends StatelessWidget {
  const _CaughtUp({required this.state});

  final SessionPanelCaughtUp state;

  @override
  Widget build(BuildContext context) {
    return RuledPanel(
      heading: "Today's session",
      child: StatsBand(
        centred: true,
        compact: true,
        figures: [
          StatFigure(value: '${state.answeredToday}', label: 'answered today'),
          StatFigure(value: '${state.correctToday}', label: 'got right'),
        ],
      ),
    );
  }
}

class _InProgress extends ConsumerWidget {
  const _InProgress({required this.exam, required this.state});

  final Exam exam;
  final SessionPanelInProgress state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final body = styles.bodyMedium.copyWith(color: colors.inkMuted);
    final topicName = state.topicName;

    return RuledPanel(
      heading: 'Still going',
      count: '${state.answered} of ${state.total}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (topicName == null)
            Text(
              'You stopped partway through this session. '
              'Every answer was saved.',
              style: body,
            )
          else
            Text.rich(
              TextSpan(
                style: body,
                children: [
                  const TextSpan(text: 'You stopped partway through '),
                  TextSpan(
                    text: topicName,
                    style: body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const TextSpan(text: '. Every answer was saved.'),
                ],
              ),
            ),
          const SizedBox(height: 16),
          BoardButton(
            label: 'Resume',
            onPressed: () => unawaited(context.push('/quiz/resume/${exam.id}')),
          ),
          const SizedBox(height: 8),
          _BoardTextAction(
            label: 'Discard this session',
            onTap: () => unawaited(_discard(ref)),
          ),
        ],
      ),
    );
  }

  /// Discard rather than restart. `RestartSession` re-asks the same questions
  /// while the answers already given stay written to `quiz_attempts` and the
  /// FSRS state, so it feeds the scheduler twice. Discarding loses nothing,
  /// because everything answered is already recorded.
  Future<void> _discard(WidgetRef ref) async {
    await ref.read(quitSessionProvider)(
      userId: todayUserId,
      examId: exam.id,
      now: ref.read(nowProvider)(),
    );
    ref.invalidate(sessionPanelProvider(exam.id));
  }
}

/// A board 12/600 text action with a full-width tap target.
///
/// Not a secondary [BoardButton]: that draws at `labelLarge`, 13px, and the
/// spec sets these two at 12/600 inside the panel.
class _BoardTextAction extends StatelessWidget {
  const _BoardTextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.board,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// "6 due · 3 weak spots · 1 new", with zero segments left out.
///
/// A zero reads badly in a line meant to describe what is coming, and all
/// three cannot be zero: that condition is the caught-up state.
@visibleForTesting
String compositionLine({
  required int dueCount,
  required int weaknessCount,
  required int freshCount,
}) {
  final parts = <String>[
    if (dueCount > 0) '$dueCount due',
    if (weaknessCount > 0)
      '$weaknessCount weak ${weaknessCount == 1 ? 'spot' : 'spots'}',
    if (freshCount > 0) '$freshCount new',
  ];
  return parts.join(' · ');
}
```

**The Start button does not run the nudge sheet.** `_onStartQuiz` and `_QuizNudgeSheet`
stay in `quiz_tab_home.dart` where 2a left them, and Step 5 wires them back in. Keeping the
sheet out of this file keeps the panel testable without the nudge providers.

- [ ] **Step 5: Mount the panel on the tab**

In `lib/features/quiz/presentation/quiz_tab_home.dart`, inside `_QuizTabBody`'s `ListView`,
replace the comment 2a left with the panel, and hand it the nudge:

```dart
        Text(exam.shortName, style: styles.displaySmall),
        const SizedBox(height: 20),
        SessionPanel(exam: exam, onStart: () => _onStartQuiz(context, ref)),
        // The mock panel lands here in plan 2c.
        const SectionHeader(title: 'More ways to practice'),
```

That means `SessionPanel` takes one more parameter. Add it:

```dart
  const SessionPanel({required this.exam, this.onStart, super.key});

  final Exam exam;

  /// Runs before the session opens. The tab passes its study-first nudge.
  /// Null starts the session directly, which is what the widget tests do.
  final VoidCallback? onStart;
```

and thread it into `_Available` so its Start button reads:

```dart
          BoardButton(
            label: 'Start',
            onPressed: onStart ?? () => unawaited(context.push('/quiz/today/${exam.id}')),
          ),
```

`_Available` needs `onStart` passed down from `SessionPanel.build`. `_start` and its
`unawaited` import are then unused; remove them.

**`_onStartQuiz` already pushes `/quiz/today/${exam.id}` after the sheet**, so nothing else
in `quiz_tab_home.dart` changes.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/features/quiz/ test/core/ui/components/stats_band_test.dart`
Expected: PASS. `quiz_tab_home_test.dart` from 2a may need a `sessionPanelProvider`
override added to its pumps; add one returning `SessionPanelCaughtUp` so the tab renders
without reaching the database.

- [ ] **Step 7: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib/core/ui/components/stats_band.dart test/core/ui/components/stats_band_test.dart \
        lib/features/quiz test/features/quiz
git commit -m "feat(quiz): the session panel, all four states

Figures are centred at the panel size and tabular, which StatsBand now
supports rather than a fourth near-duplicate of it. The available state
shows the length alone until seven finished sessions make an average
worth printing."
```

---

## Task 9: The ordering setting

**Files:**
- Create: `lib/features/settings/presentation/pages/session_building_page.dart`
- Create: `test/features/settings/presentation/session_building_page_test.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/features/settings/presentation/settings_home_page.dart`

**Interfaces:**
- Consumes: `quizPreferencesRepositoryProvider`, `QuizPreferences`, `QuizOrdering`, all
  existing. `QuizOrdering.isRecommended` is already on the enum.
- Produces: the route `/settings/sessions`, which Task 8's link pushes.

**Why this is in 2b and not left for a settings pass.** The panel's link is one of the four
elements the spec lists for the available state. 2a set the precedent that a control with
nowhere to go is not shipped: its "Choose what to practice" row is deliberately inert until
seam 3 builds the picker. A text action reading "Change how sessions are built" cannot be
inert and still mean anything, so its destination is built here.

**From the spec, Section 5:**

| Setting | Behaviour |
|---|---|
| Blocked | Every question from the chosen topic |
| **Interleaved tail** (default, recommended) | Seven from the topic, three from elsewhere |
| Fully mixed | No two consecutive questions from the same topic |

The storage already exists: `QuizPreferencesRepository.interleavedTodayKey` holds the
three-way value and `QuizOrdering.fromStorage` still reads the old `'true'`/`'false'`
booleans.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/presentation/session_building_page_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/session_building_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  testWidgets('every ordering is offered with its explanation',
      (tester) async {
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Every question from the chosen topic'), findsOneWidget);
    expect(find.text('Interleaved tail'), findsOneWidget);
    expect(
      find.text('Seven from the topic, three from elsewhere'),
      findsOneWidget,
    );
    expect(find.text('Fully mixed'), findsOneWidget);
    expect(
      find.text('No two consecutive questions from the same topic'),
      findsOneWidget,
    );
  });

  testWidgets('the default carries a recommended marker', (tester) async {
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Recommended'), findsOneWidget);
  });

  testWidgets('choosing an ordering writes it', (tester) async {
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fully mixed'));
    await tester.pumpAndSettle();

    final saved = await QuizPreferencesRepository(db).read();
    expect(saved.ordering, QuizOrdering.fullyMixed);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/settings/presentation/session_building_page_test.dart`
Expected: FAIL. `session_building_page.dart` does not exist.

- [ ] **Step 3: Write the page**

Create `lib/features/settings/presentation/pages/session_building_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _explain(QuizOrdering ordering) => switch (ordering) {
      QuizOrdering.blocked => 'Every question from the chosen topic',
      QuizOrdering.interleavedTail =>
        'Seven from the topic, three from elsewhere',
      QuizOrdering.fullyMixed =>
        'No two consecutive questions from the same topic',
    };

String _name(QuizOrdering ordering) => switch (ordering) {
      QuizOrdering.blocked => 'Blocked',
      QuizOrdering.interleavedTail => 'Interleaved tail',
      QuizOrdering.fullyMixed => 'Fully mixed',
    };

/// Opened by the session panel's "Change how sessions are built".
class SessionBuildingPage extends ConsumerStatefulWidget {
  const SessionBuildingPage({super.key});

  @override
  ConsumerState<SessionBuildingPage> createState() =>
      _SessionBuildingPageState();
}

class _SessionBuildingPageState extends ConsumerState<SessionBuildingPage> {
  QuizPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final preferences = await _repo.read();
    if (!mounted) return;
    setState(() => _preferences = preferences);
  }

  QuizPreferencesRepository get _repo =>
      QuizPreferencesRepository(ref.read(appDatabaseProvider));

  Future<void> _choose(QuizOrdering ordering) async {
    final current = _preferences;
    if (current == null) return;
    final updated = QuizPreferences(
      sessionLength: current.sessionLength,
      ordering: ordering,
      newCardCap: current.newCardCap,
    );
    setState(() => _preferences = updated);
    await _repo.save(updated);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = _preferences;
    final styles = context.textStyles;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('How sessions are built')),
      body: preferences == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                for (final ordering in QuizOrdering.values)
                  InkWell(
                    onTap: () => unawaited(_choose(ordering)),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colors.ruleFaint,
                            width: AppDimensions.hairline,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _name(ordering),
                                      style: styles.headlineSmall,
                                    ),
                                    if (ordering.isRecommended) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'Recommended',
                                        style: styles.bodySmall.copyWith(
                                          color: colors.board,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _explain(ordering),
                                  style: styles.bodySmall
                                      .copyWith(color: colors.inkMuted),
                                ),
                              ],
                            ),
                          ),
                          if (preferences.ordering == ordering)
                            Icon(Icons.check, size: 18, color: colors.ink),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
```

Add `import 'dart:async';` for `unawaited`.

- [ ] **Step 4: Add the route and the settings row**

In `lib/app/router.dart`, beside the other `/settings/*` routes:

```dart
      GoRoute(
        path: '/settings/sessions',
        builder: (_, __) => const SessionBuildingPage(),
      ),
```

In `lib/features/settings/presentation/settings_home_page.dart`, inside the "Preferences"
`SettingsSection`, beneath the "Daily reminder" row:

```dart
              SettingsRow(
                title: 'How sessions are built',
                subtitle: 'Blocked, interleaved tail, or fully mixed',
                onTap: () => context.push('/settings/sessions'),
              ),
```

- [ ] **Step 5: Run the whole suite**

Run: `flutter test`
Expected: PASS. This is the last task, so the suite is the gate.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(settings): how sessions are built

quiz_today_interleaved has held a three-way value since the storage work
and no screen wrote it. The session panel's link needed somewhere to go,
and a text action with nowhere to go means nothing."
```

---

## What this plan deliberately does not do

- **The mock panel, its cooldown, the practice row counts and the flagged section.**
  Plan 2c. The tab keeps 2a's two rows and its inert picker row.
- **The practice picker.** Seam 3.
- **The interleaved tail's actual proportions.** `TodayInterleavedPicker` composes with
  `TodayTopicPicker` and then applies `RecencyFilter.noConsecutiveSameTopic`, which is not
  the same thing as "seven from the topic, three from elsewhere". Section 5 specifies the
  proportion and the picker does not implement it. **Flagged, not fixed here**: this plan
  makes the panel describe the session that is actually built, and correcting the picker's
  proportions is a change to session composition that deserves its own gate. Raise it with
  Aedwon before seam 3.
- **The picker's "exclude anything answered in the last 7 days" rule**, also Section 5,
  also unbuilt. Same reason.
- **Weighting toward recently-read topics.** Deferred in the spec by name.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # still 7, not 8
flutter test                                     # all pass
```

By hand, on a device, since Aedwon does the visual verification:

- A fresh install shows "Start with the assessment" with a real count in the corner, not 21.
- After the assessment, the panel shows "Today's session" with the question count alone and
  no minutes.
- Starting a session and leaving it part way turns the panel into "Still going", with the
  count in the corner and the topic named in the sentence.
- "Resume" returns to the question that was left, not to question one.
- "Discard this session" returns the panel to its available state and loses no points.
- "Change how sessions are built" opens the setting, and the choice sticks after the app is
  killed and reopened.
- Answering everything for the day turns the panel into two figures and no button.

## Self-review notes

Checked against Section 1's session panel table and Section 5:

- All four states, their headings, their trailing counts and their bodies: Tasks 7 and 8.
- Centred figures, the composition line, the settings link: Task 8.
- Resume and Discard, with "Start over" deleted: Tasks 6 and 8. `RestartSession` is left in
  the tree; nothing on this tab calls it.
- The three orderings with explanations and a recommended marker: Task 9.
- Two strings are not quoted from the spec, both named in Task 8 and both in the decision
  log.
- Two Section 5 requirements are flagged unbuilt rather than silently skipped: the tail's
  proportions and the seven-day exclusion.
