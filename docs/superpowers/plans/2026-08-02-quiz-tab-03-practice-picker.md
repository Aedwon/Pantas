# Quiz Tab, Plan 3 of 6: The Practice Picker

> **How to work this plan.** Implement it task by task, in order. For each task: write the
> failing test first, run it and confirm it fails, then write the code that makes it pass. Do
> not skip a step and do not batch tasks. Steps use checkbox (`- [ ]`) syntax so progress can
> be tracked.
>
> **Required reading before Task 1:** `AGENTS.md` at the repository root, in full. It carries
> the build commands, the visual identity bans, the voice rules, the never-invent-a-figure
> rule and the landmines, and every one of them applies to this plan whether or not the
> Global Constraints below happen to repeat it.
>
> **Follow the plan. Do not redesign.** If a step is ambiguous, contradicts the spec, or looks
> wrong, **stop and say so** rather than inventing a solution. A plausible invention is more
> expensive than a question, because it looks finished.
>
> **Analyzer baseline:** `flutter analyze` reports **27 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. `lib/` is clean. Any issue under `lib/` or `test/` is
> one you introduced.
>
> **Work only inside your worktree.** Never write to the main checkout. A previous run left a
> half-applied `app_database.dart` in the main tree with `schemaVersion` bumped and no
> migration: a broken state that compiles.
>
> **Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and never
> committed.** This repo gitignores them.
>
> **No AI attribution in commit messages.** No `Co-Authored-By` trailers, no "Generated with"
> lines, no similar marker.

**Goal:** Build the screen behind "Choose what to practice": a hierarchical index of
subjects, topics and lessons, a live footer that says what the selection buys, and a
session that honours it.

**Architecture:** Four pure units in `features/quiz/domain` carry all the arithmetic, so the
screen is a renderer. One new route, one new use case, and a repair to `DrillPicker`, which
today returns the same questions in the same order forever.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-quiz-tab-design.md` Section 2 in full,
plus Section 5's "Drill becomes honest".

**Decision log:** `docs/superpowers/decisions/2026-07-28-quiz-tab-decision-log.md`. Read the
2 August entries. Two rulings there govern this plan: figures are withheld until they can be
measured, and no number is a measurement multiplied by an assumption.

**Depends on:** Plan 2a for `RuledPanel` and 2c for the "Choose what to practice" row, which
is inert until this plan gives it a destination. 2b's `test/helpers` seeding helper is used
throughout.

---

## Three things in the code that shape this plan

1. **`DrillPicker` returns the first N questions, forever.** It calls
   `SubtopicFilter.general(context.subtopicCandidates)`, and both callers build those
   candidates with `subtopicId: null` on every one, so `general()` returns the whole pool
   unshuffled and `.take(n)` returns the same head every time. Section 5 says the picker's
   sessions "must **shuffle within the pool** and **exclude anything answered in the last 7
   days**, which is what Spec 4 §4.3 specified and what was never built". Task 7.
2. **No question carries a `lessonId`.** The column is nullable and the tagging pass has not
   run: the work checkpoint lists "Tag all 1,117 questions with a `lessonId`" as a
   prerequisite that "gates the reader coda, **lesson selection in the practice picker**,
   and the Lesson level of the Progress table". **Selecting a lesson today would start an
   empty session.** How this plan handles it is below.
3. **The minutes unit needs a pace the app may not have yet.** See the ruling below.

### Lesson rows appear only where they would work

A lesson row is shown when **its topic has at least one question carrying a `lessonId`**.
Where the tagging pass has not reached, the topic still selects as a whole and its caret is
absent, because there is nothing to unfold to.

This is the spec's own treatment of an empty pool, one level down: Section 2 already dims
topics with no questions rather than hiding them, on the reasoning that a student who has
read the lessons will come looking. The difference is that a **dimmed topic still says why**
("no questions yet"), whereas an unfoldable topic says nothing, because "this topic's
questions are not tagged yet" is an implementation detail and not news to a student.

**The screen completes itself when the tagging pass lands.** Nothing here needs revisiting:
the carets appear as the data arrives.

### The minutes unit is withheld until the pace is measured

The footer's unit control offers `questions · minutes`, and choosing minutes means
converting minutes into a number of questions. That conversion is a measured response time
multiplied by an assumption about questions not yet answered, which is the combination the
figure rule bans by name.

Aedwon settled the same collision twice on 2 August: the session panel shows questions alone
until seven finished sessions make an average worth printing, and the mock panel dropped a
figure outright rather than invent a threshold. **This plan applies that ruling rather than
reopening it:**

- **Under seven completed sessions**, the unit control shows `questions` alone, the minutes
  tick is absent, and the summary line reads "45 questions" with no duration.
- **At seven and above**, the minutes unit appears, the wheel gains its minutes range, and
  the summary reads "45 questions · about 40 min", converting through the student's own
  measured average response time.

**The spec's word here is "about"**, unlike the session panel where "about" was explicitly
rejected. That is consistent: the panel was describing one specific session, this is
describing a pool the student is composing, and the spec's own mockup on line 332 reads
"45 questions · about 40 min".

**If Aedwon would rather the minutes unit always show, that is a one-line change** in
`practicePaceProvider`: return a published per-item pace instead of null. Raise it, do not
decide it in code.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** It holds `PageScaffold`,
  `RuledSection`, `RuledPanel`, `SectionHeader`, `StatsBand`, `InkTableRow`, `EmptyState`,
  `ErrorBanner`, `FaintBars`, `BoardButton`, `ConfirmationDialog`, `ProgressRule`,
  `InlineMeter`. **`InkTableRow` is not the picker's row**: it has no checkbox and no split
  tap target. The picker's rows are new and local to this screen.
- **Never invent a figure.** Read the ruling above before touching the footer.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer. The one tint on
  this screen is the wheel's `boardTint` band, which the spec specifies by name.
- **Colour carries meaning.** This screen's one primary `BoardButton` is the footer's
  "Start". "Clear" in the app bar is a board text action, not a button.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. Scores are
  **points**. Every user-facing string here is quoted from the spec.
- **Navigation rule (UI-001).** The picker is a **pushed** route, not a sheet. The spec says
  why: "it has a footer that must stay put and a list that may run to 18 topics".
- **Layering.** R1, R2, R3 as enforced by `tool/check_layering.dart`. **The baseline is 7
  violations.** Do not add an eighth. In particular, do not read
  `PerQuestionSpeedSignal` from `features/quiz`: Task 1 puts the query where it belongs.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/features/quiz/domain/picker/practice_index.dart` — the tree the screen lists.
- `lib/features/quiz/domain/picker/practice_selection.dart` — hierarchical selection and
  its unit counting. Pure.
- `lib/features/quiz/domain/picker/practice_summary.dart` — the footer's arithmetic. Pure.
- `lib/features/quiz/domain/use_cases/start_practice.dart` — one session from many
  selections.
- `lib/features/quiz/presentation/practice_picker_providers.dart`
- `lib/features/quiz/presentation/pages/practice_picker_page.dart`
- `lib/features/quiz/presentation/widgets/length_wheel.dart`
- Tests mirroring each.

**Modify:**
- `lib/core/storage/data/repos/attempts_repository.dart` — the measured pace, and the
  seven-day exclusion list.
- `lib/features/quiz/domain/picker/drill_picker.dart` — shuffle and exclude.
- `lib/features/quiz/presentation/quiz_tab_home.dart` — make the row tappable.
- `lib/app/router.dart` — `/quiz/practice/:examId`.

**Not touched:** `StartDrill`, which keeps working for any caller that wants one topic.
`SubtopicFilter`, which is dead machinery flagged in the 2 August log and is removed from
`DrillPicker`'s path here without being deleted, since `start_inline_lesson_quiz.dart` still
imports it.

---

## Task 1: The measured pace and the recent-answer exclusion

**Files:**
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Test: `test/core/storage/data/repos/attempts_repository_pace_test.dart` (create)

**Interfaces:**
- Consumes: `AppDatabase`, `Attempt`, `AttemptItem`.
- Produces, relied on by Tasks 4 and 7:
  - `AttemptsRepository.averageResponseMs({required ExamId examId, int minimumSessions}) -> Future<int?>`
  - `AttemptsRepository.questionIdsAnsweredSince({required ExamId examId, required DateTime since}) -> Future<Set<QuestionId>>`

**Why not `PerQuestionSpeedSignal`.** It computes this already and lives in
`features/metrics`. Reading it from `features/quiz` is an R2 violation, and all seven
existing violations are exactly that shape. Plan 2b made the same call for
`averageCompletedMinutes` and the reasoning is unchanged.

**Seven is the same gate the session panel uses**, so the app has one answer to "how much
history is enough". Here it counts **completed attempts**, which is the unit this repository
stores.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/data/repos/attempts_repository_pace_test.dart`:

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

  AttemptItem item(String questionId, {int responseMs = 30000}) => AttemptItem(
        questionId: questionId,
        questionVersion: 1,
        chosenChoiceId: 'c_a',
        correctChoiceId: 'c_a',
        responseMs: responseMs,
      );

  Future<void> save(
    String id, {
    required List<AttemptItem> items,
    DateTime? startedAt,
    bool completed = true,
  }) {
    final began = startedAt ?? DateTime.utc(2026, 8, 1);
    return repo.save(
      Attempt(
        id: id,
        examId: 'exam_cse_pro',
        startedAt: began,
        completedAt: completed ? began : null,
        items: items,
      ),
    );
  }

  test('the pace is withheld below seven completed attempts', () async {
    for (var i = 0; i < 6; i++) {
      await save('a_$i', items: [item('q_$i')]);
    }

    expect(
      await repo.averageResponseMs(examId: 'exam_cse_pro'),
      isNull,
    );
  });

  test('the pace averages every answer once seven attempts exist', () async {
    for (var i = 0; i < 7; i++) {
      await save('a_$i', items: [item('q_$i', responseMs: 40000)]);
    }

    expect(
      await repo.averageResponseMs(examId: 'exam_cse_pro'),
      40000,
    );
  });

  test('unfinished attempts do not count toward the pace', () async {
    for (var i = 0; i < 6; i++) {
      await save('a_$i', items: [item('q_$i')]);
    }
    await save('a_open', items: [item('q_open')], completed: false);

    expect(
      await repo.averageResponseMs(examId: 'exam_cse_pro'),
      isNull,
    );
  });

  test('questions answered inside the window come back', () async {
    await save(
      'a_recent',
      items: [item('q_1'), item('q_2')],
      startedAt: DateTime.utc(2026, 8, 1),
    );

    final ids = await repo.questionIdsAnsweredSince(
      examId: 'exam_cse_pro',
      since: DateTime.utc(2026, 7, 28),
    );

    expect(ids, equals({'q_1', 'q_2'}));
  });

  test('questions answered before the window do not', () async {
    await save(
      'a_old',
      items: [item('q_1')],
      startedAt: DateTime.utc(2026, 7, 1),
    );

    final ids = await repo.questionIdsAnsweredSince(
      examId: 'exam_cse_pro',
      since: DateTime.utc(2026, 7, 28),
    );

    expect(ids, isEmpty);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/repos/attempts_repository_pace_test.dart`
Expected: FAIL. Neither method is defined.

- [ ] **Step 3: Add both queries**

In `lib/core/storage/data/repos/attempts_repository.dart`, beneath `tallyForDay`:

```dart
  /// The student's own average time on one question, in milliseconds, or null
  /// until there is enough history to average honestly.
  ///
  /// The practice picker converts a requested number of minutes into a number
  /// of questions with this. Below [minimumSessions] it returns null and the
  /// picker withholds its minutes unit rather than converting through a figure
  /// the app made up.
  ///
  /// `PerQuestionSpeedSignal` computes the same average and gates on the same
  /// seven, but it lives in `features/metrics` and reading it from the quiz
  /// feature would cross a layer boundary.
  Future<int?> averageResponseMs({
    required ExamId examId,
    int minimumSessions = 7,
  }) async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) => t.examId.equals(examId) & t.completedAt.isNotNull(),
          ))
        .get();
    if (rows.length < minimumSessions) return null;

    var total = 0;
    var count = 0;
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        total += item.responseMs;
        count++;
      }
    }
    if (count == 0) return null;
    return (total / count).round();
  }

  /// Every question answered since [since], for any reason.
  ///
  /// The picker excludes these so a repeated drill does not return the same
  /// ten in the same order. Spec 4 section 4.3 asked for this and it was never
  /// built.
  Future<Set<QuestionId>> questionIdsAnsweredSince({
    required ExamId examId,
    required DateTime since,
  }) async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(since),
          ))
        .get();
    return {
      for (final row in rows)
        for (final item in _hydrate(row).items) item.questionId,
    };
  }
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/storage/data/repos/attempts_repository_pace_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): the picker's pace and its recent-answer set

The picker converts minutes into questions, which needs the student's own
measured pace and nothing else. Below seven finished attempts there is no
honest average, so it returns null and the unit is withheld."
```

---

## Task 2: `PracticeIndex`

**Files:**
- Create: `lib/features/quiz/domain/picker/practice_index.dart`
- Create: `lib/features/quiz/presentation/practice_picker_providers.dart`
- Test: `test/features/quiz/domain/picker/practice_index_test.dart`
- Test: `test/features/quiz/presentation/practice_index_provider_test.dart`

**Interfaces:**
- Consumes: `ContentRepository`, `LessonProgressRepository`, both existing.
- Produces, relied on by Tasks 3, 4 and 6:

```dart
class PracticeLessonEntry { LessonId id; String title; bool isRead; int questionCount; }
class PracticeTopicEntry  { TopicId id; String name; int questionCount;
                            List<PracticeLessonEntry> lessons;
                            bool get hasQuestions; bool get canUnfold; }
class PracticeSubjectEntry{ SubjectId id; String name; List<PracticeTopicEntry> topics; }
class PracticeIndex       { List<PracticeSubjectEntry> subjects; }
```
  plus `practiceIndexProvider`, a `FutureProvider.family<PracticeIndex, ExamId>`.

**From the spec, Section 2:** subject headings then topic rows "in the subject's
`ordering`". Topic rows carry **no question count** in the UI: "A count of 248 is inventory,
not a decision". The count is still carried on the model because the footer needs it to say
", 1 had fewer".

**Lesson rows carry the title and nothing else unless unread.** `isRead` drives the "not read
yet" mark, which is the only annotation on this screen.

**`canUnfold` is false when no question in the topic carries a `lessonId`.** See the note at
the top of this plan.

- [ ] **Step 1: Write the failing model test**

Create `test/features/quiz/domain/picker/practice_index_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:flutter_test/flutter_test.dart';

PracticeLessonEntry lesson(
  String id, {
  bool isRead = false,
  int questionCount = 4,
}) =>
    PracticeLessonEntry(
      id: id,
      title: 'Lesson $id',
      isRead: isRead,
      questionCount: questionCount,
    );

void main() {
  test('a topic with questions can be selected', () {
    const topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 12,
      lessons: [],
    );

    expect(topic.hasQuestions, isTrue);
  });

  test('a topic with no questions cannot be selected', () {
    const topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 0,
      lessons: [],
    );

    expect(topic.hasQuestions, isFalse);
    expect(topic.canUnfold, isFalse);
  });

  test('a topic whose lessons hold no tagged questions cannot unfold', () {
    final topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 12,
      lessons: [lesson('l_1', questionCount: 0)],
    );

    expect(topic.canUnfold, isFalse);
  });

  test('a topic with one tagged lesson can unfold', () {
    final topic = PracticeTopicEntry(
      id: 'topic_algebra',
      name: 'Algebra',
      questionCount: 12,
      lessons: [lesson('l_1'), lesson('l_2', questionCount: 0)],
    );

    expect(topic.canUnfold, isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/picker/practice_index_test.dart`
Expected: FAIL. `practice_index.dart` does not exist.

- [ ] **Step 3: Write the model**

Create `lib/features/quiz/domain/picker/practice_index.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';

/// One lesson inside a topic, as the picker lists it.
class PracticeLessonEntry {
  const PracticeLessonEntry({
    required this.id,
    required this.title,
    required this.isRead,
    required this.questionCount,
  });

  final LessonId id;
  final String title;

  /// Drives the only annotation on this screen. Read lessons carry nothing:
  /// most lessons end up read, so marking those marks almost everything.
  final bool isRead;

  /// How many questions carry this lesson's id. Zero everywhere until the
  /// tagging pass runs.
  final int questionCount;
}

/// One topic row.
class PracticeTopicEntry {
  const PracticeTopicEntry({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.lessons,
  });

  final TopicId id;
  final String name;

  /// Never shown. A count of 248 is inventory, not a decision, and the spec
  /// leaves the row's meta slot empty. The footer needs it to know when a pool
  /// held fewer than was asked for.
  final int questionCount;

  final List<PracticeLessonEntry> lessons;

  /// Dimmed and unselectable when false, with "no questions yet" in the meta
  /// slot. Not hidden: its lessons exist and a student who has read them will
  /// come looking.
  bool get hasQuestions => questionCount > 0;

  /// False where no question in the topic carries a lesson id, which is
  /// everywhere until the tagging pass runs. The caret is absent rather than
  /// opening onto rows that would start an empty session.
  bool get canUnfold =>
      lessons.any((lesson) => lesson.questionCount > 0);
}

class PracticeSubjectEntry {
  const PracticeSubjectEntry({
    required this.id,
    required this.name,
    required this.topics,
  });

  final SubjectId id;
  final String name;
  final List<PracticeTopicEntry> topics;
}

class PracticeIndex {
  const PracticeIndex(this.subjects);

  static const empty = PracticeIndex([]);

  final List<PracticeSubjectEntry> subjects;

  bool get isEmpty => subjects.isEmpty;

  Iterable<PracticeTopicEntry> get allTopics =>
      subjects.expand((subject) => subject.topics);
}
```

- [ ] **Step 4: Run the model test**

Run: `flutter test test/features/quiz/domain/picker/practice_index_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Write the failing provider test**

Create `test/features/quiz/presentation/practice_index_provider_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/practice_picker_providers.dart';
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

  test('an exam with no content indexes as empty', () async {
    final index =
        await container.read(practiceIndexProvider('exam_cse_pro').future);

    expect(index.isEmpty, isTrue);
  });

  test('topics arrive under their subject in ordering', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2'],
    );

    final index =
        await container.read(practiceIndexProvider('exam_cse_pro').future);

    expect(index.subjects.single.topics.single.name, 'Algebra');
    expect(index.subjects.single.topics.single.questionCount, 2);
  });

  test('a lesson read is marked read', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1'],
      lessonIds: ['l_1', 'l_2'],
    );
    await LessonProgressRepository(db).markRead('l_1');

    final index =
        await container.read(practiceIndexProvider('exam_cse_pro').future);
    final lessons = index.subjects.single.topics.single.lessons;

    expect(lessons.firstWhere((l) => l.id == 'l_1').isRead, isTrue);
    expect(lessons.firstWhere((l) => l.id == 'l_2').isRead, isFalse);
  });
}
```

`seedTopicWithQuestions` gained no `lessonIds` parameter in Plan 2b. **Extend it** to insert
lessons for the topic and to accept an optional `Map<QuestionId, LessonId>` so a later test
can tag questions. Read the helper first and keep its existing calls working by giving both
parameters defaults.

- [ ] **Step 6: Run the provider test to verify it fails**

Run: `flutter test test/features/quiz/presentation/practice_index_provider_test.dart`
Expected: FAIL. `practice_picker_providers.dart` does not exist.

- [ ] **Step 7: Write the provider**

Create `lib/features/quiz/presentation/practice_picker_providers.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Everything the picker lists: subjects in order, their topics in order, and
/// each topic's lessons with their read state.
final practiceIndexProvider =
    FutureProvider.family<PracticeIndex, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final exams = await content.listExams();
  final exam = exams.where((candidate) => candidate.id == examId).firstOrNull;
  if (exam == null) return PracticeIndex.empty;

  final readIds =
      await ref.watch(lessonProgressRepositoryProvider).readLessonIds();

  final subjects = <PracticeSubjectEntry>[];
  for (final subject in exam.subjects) {
    final topics = <PracticeTopicEntry>[];
    for (final topic in await content.topicsBySubject(subject.id)) {
      final questions = await content.questionsByTopic(topic.id);
      final taggedCounts = <LessonId, int>{};
      for (final question in questions) {
        final lessonId = question.lessonId;
        if (lessonId == null) continue;
        taggedCounts[lessonId] = (taggedCounts[lessonId] ?? 0) + 1;
      }

      topics.add(
        PracticeTopicEntry(
          id: topic.id,
          name: topic.name,
          questionCount: questions.length,
          lessons: [
            for (final lesson in await content.lessonsByTopic(topic.id))
              PracticeLessonEntry(
                id: lesson.id,
                title: lesson.title,
                isRead: readIds.contains(lesson.id),
                questionCount: taggedCounts[lesson.id] ?? 0,
              ),
          ],
        ),
      );
    }
    subjects.add(
      PracticeSubjectEntry(
        id: subject.id,
        name: subject.name,
        topics: topics,
      ),
    );
  }
  return PracticeIndex(subjects);
});
```

`exam.subjects` is already sorted by `ordering` inside `ContentRepository.listExams`, and
`topicsBySubject` sorts its own. Do not sort again.

Check `lessonProgressRepositoryProvider` exists and is exported from
`core/storage/storage.dart`. If not, add it beside the other repository providers.

- [ ] **Step 8: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 9: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz test/helpers
git commit -m "feat(quiz): the practice picker's index

Topics carry their question count on the model and never show it: a count
of 248 is inventory, not a decision. A topic can only unfold where its
questions carry a lesson id, which is nowhere until the tagging pass."
```

---

## Task 3: `PracticeSelection`

**Files:**
- Create: `lib/features/quiz/domain/picker/practice_selection.dart`
- Test: `test/features/quiz/domain/picker/practice_selection_test.dart`

**Interfaces:**
- Consumes: `PracticeIndex` and its entries from Task 2.
- Produces, relied on by Tasks 4, 6 and 8:

```dart
enum PracticeCheckState { off, partial, on }

class PracticeUnit { TopicId topicId; LessonId? lessonId; }   // one selection

class PracticeSelection {
  const PracticeSelection.empty();
  PracticeSelection toggleTopic(PracticeTopicEntry topic);
  PracticeSelection toggleLesson(PracticeTopicEntry topic, PracticeLessonEntry lesson);
  PracticeSelection cleared();
  PracticeCheckState topicState(PracticeTopicEntry topic);
  bool lessonSelected(LessonId lessonId);
  bool get isEmpty;
  List<PracticeUnit> units(PracticeIndex index);
}
```

**From the spec, Section 2, "Selection is hierarchical":**

- Selecting a topic selects **every lesson beneath it**.
- Deselecting one lesson drops the topic checkbox to the **dash**.
- **Counting never double-adds.** A fully selected topic is **one unit** drawing on the
  topic's whole pool. A partly selected topic contributes **one unit per kept lesson**, and
  the topic itself contributes nothing.

**A topic that cannot unfold is all-or-nothing.** With no selectable lessons beneath it, its
only states are off and on, and it is always one unit.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/domain/picker/practice_selection_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';
import 'package:flutter_test/flutter_test.dart';

PracticeLessonEntry lesson(String id, {int questionCount = 4}) =>
    PracticeLessonEntry(
      id: id,
      title: 'Lesson $id',
      isRead: false,
      questionCount: questionCount,
    );

final algebra = PracticeTopicEntry(
  id: 'topic_algebra',
  name: 'Algebra',
  questionCount: 20,
  lessons: [lesson('l_1'), lesson('l_2'), lesson('l_3')],
);

const untagged = PracticeTopicEntry(
  id: 'topic_geometry',
  name: 'Geometry',
  questionCount: 20,
  lessons: [],
);

final index = PracticeIndex([
  PracticeSubjectEntry(
    id: 'subject_maths',
    name: 'Mathematics',
    topics: [algebra, untagged],
  ),
]);

void main() {
  test('nothing is selected to begin with', () {
    const selection = PracticeSelection.empty();

    expect(selection.isEmpty, isTrue);
    expect(selection.topicState(algebra), PracticeCheckState.off);
    expect(selection.units(index), isEmpty);
  });

  test('selecting a topic selects every lesson beneath it', () {
    final selection = const PracticeSelection.empty().toggleTopic(algebra);

    expect(selection.topicState(algebra), PracticeCheckState.on);
    expect(selection.lessonSelected('l_1'), isTrue);
    expect(selection.lessonSelected('l_3'), isTrue);
  });

  test('a fully selected topic is one unit', () {
    final selection = const PracticeSelection.empty().toggleTopic(algebra);

    final units = selection.units(index);
    expect(units, hasLength(1));
    expect(units.single.topicId, 'topic_algebra');
    expect(units.single.lessonId, isNull);
  });

  test('deselecting one lesson drops the topic to the dash', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleLesson(algebra, lesson('l_2'));

    expect(selection.topicState(algebra), PracticeCheckState.partial);
  });

  test('a partly selected topic is one unit per kept lesson', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleLesson(algebra, lesson('l_2'));

    final units = selection.units(index);
    expect(units, hasLength(2));
    expect(units.every((unit) => unit.topicId == 'topic_algebra'), isTrue);
    expect(
      units.map((unit) => unit.lessonId),
      unorderedEquals(['l_1', 'l_3']),
    );
  });

  test('deselecting the last lesson turns the topic off', () {
    var selection = const PracticeSelection.empty().toggleTopic(algebra);
    for (final entry in algebra.lessons) {
      selection = selection.toggleLesson(algebra, entry);
    }

    expect(selection.topicState(algebra), PracticeCheckState.off);
    expect(selection.isEmpty, isTrue);
  });

  test('selecting one lesson alone leaves the topic on the dash', () {
    final selection =
        const PracticeSelection.empty().toggleLesson(algebra, lesson('l_1'));

    expect(selection.topicState(algebra), PracticeCheckState.partial);
    expect(selection.units(index), hasLength(1));
  });

  test('a topic that cannot unfold is all or nothing', () {
    final selection = const PracticeSelection.empty().toggleTopic(untagged);

    expect(selection.topicState(untagged), PracticeCheckState.on);
    expect(selection.units(index).single.lessonId, isNull);
  });

  test('clearing drops everything', () {
    final selection =
        const PracticeSelection.empty().toggleTopic(algebra).cleared();

    expect(selection.isEmpty, isTrue);
  });

  test('toggling a selected topic turns it off', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleTopic(algebra);

    expect(selection.topicState(algebra), PracticeCheckState.off);
  });

  test('toggling a partly selected topic fills it', () {
    final selection = const PracticeSelection.empty()
        .toggleTopic(algebra)
        .toggleLesson(algebra, lesson('l_2'))
        .toggleTopic(algebra);

    expect(selection.topicState(algebra), PracticeCheckState.on);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/picker/practice_selection_test.dart`
Expected: FAIL. `practice_selection.dart` does not exist.

- [ ] **Step 3: Write the selection**

Create `lib/features/quiz/domain/picker/practice_selection.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';

enum PracticeCheckState { off, partial, on }

/// One thing the student picked, and the pool it draws on.
///
/// A [lessonId] of null means the whole topic. The footer's wheel gives every
/// unit the same number of questions, which is why a unit is the counting
/// grain rather than a question total.
class PracticeUnit {
  const PracticeUnit({required this.topicId, this.lessonId});

  final TopicId topicId;
  final LessonId? lessonId;
}

/// What is ticked, and what that buys.
///
/// Immutable: every toggle returns a new selection, so the screen's state is
/// one value and the footer cannot fall out of step with the boxes.
class PracticeSelection {
  const PracticeSelection.empty()
      : _wholeTopics = const {},
        _lessons = const {};

  const PracticeSelection._(this._wholeTopics, this._lessons);

  /// Topics ticked as a whole. A topic here is one unit on the whole pool.
  final Set<TopicId> _wholeTopics;

  /// Lessons ticked individually, keyed by topic so a lesson id colliding
  /// across topics cannot merge two selections.
  final Map<TopicId, Set<LessonId>> _lessons;

  bool get isEmpty => _wholeTopics.isEmpty && _lessons.values.every((s) => s.isEmpty);

  PracticeSelection cleared() => const PracticeSelection.empty();

  PracticeCheckState topicState(PracticeTopicEntry topic) {
    if (_wholeTopics.contains(topic.id)) return PracticeCheckState.on;
    final kept = _lessons[topic.id] ?? const <LessonId>{};
    if (kept.isEmpty) return PracticeCheckState.off;
    return PracticeCheckState.partial;
  }

  bool lessonSelected(LessonId lessonId) =>
      _lessons.values.any((kept) => kept.contains(lessonId));

  /// Tapping the row. Off and partial both fill; on empties.
  PracticeSelection toggleTopic(PracticeTopicEntry topic) {
    if (topicState(topic) == PracticeCheckState.on) {
      return PracticeSelection._(
        {..._wholeTopics}..remove(topic.id),
        _withoutTopic(topic.id),
      );
    }
    return PracticeSelection._(
      {..._wholeTopics, topic.id},
      // Selecting a topic selects every lesson beneath it. Held explicitly so
      // unticking one afterwards leaves the rest, which is what the dash
      // means.
      {
        ..._lessons,
        topic.id: {for (final lesson in topic.lessons) lesson.id},
      },
    );
  }

  PracticeSelection toggleLesson(
    PracticeTopicEntry topic,
    PracticeLessonEntry lesson,
  ) {
    final kept = {...?_lessons[topic.id]};
    if (!kept.remove(lesson.id)) kept.add(lesson.id);

    final lessons = {..._lessons};
    if (kept.isEmpty) {
      lessons.remove(topic.id);
    } else {
      lessons[topic.id] = kept;
    }

    // Any lesson-level change drops the topic out of "whole". A topic with
    // every lesson still ticked reads as partial rather than on, which is
    // wrong, so restore "whole" when the set is complete again.
    final isWhole = topic.lessons.isNotEmpty &&
        kept.length == topic.lessons.length;
    final wholeTopics = {..._wholeTopics};
    if (isWhole) {
      wholeTopics.add(topic.id);
    } else {
      wholeTopics.remove(topic.id);
    }

    return PracticeSelection._(wholeTopics, lessons);
  }

  /// The units the footer counts and the session draws from.
  ///
  /// Counting never double-adds: a whole topic contributes itself and none of
  /// its lessons, and a partly selected topic contributes its kept lessons and
  /// not itself.
  List<PracticeUnit> units(PracticeIndex index) {
    final units = <PracticeUnit>[];
    for (final topic in index.allTopics) {
      if (_wholeTopics.contains(topic.id)) {
        units.add(PracticeUnit(topicId: topic.id));
        continue;
      }
      for (final lessonId in _lessons[topic.id] ?? const <LessonId>{}) {
        units.add(PracticeUnit(topicId: topic.id, lessonId: lessonId));
      }
    }
    return units;
  }

  Map<TopicId, Set<LessonId>> _withoutTopic(TopicId topicId) {
    final lessons = {..._lessons};
    lessons.remove(topicId);
    return lessons;
  }
}
```

**`units` iterates the index rather than the selection**, so the order on screen and the
order in the session match, and a stale id left over from a content update cannot produce a
unit that points at nothing.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/quiz/domain/picker/practice_selection_test.dart`
Expected: PASS, 11 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz/domain/picker/practice_selection.dart \
        test/features/quiz/domain/picker/practice_selection_test.dart
git commit -m "feat(quiz): hierarchical selection for the picker

A whole topic is one unit on the whole pool. Unticking one lesson drops it
to the dash and it becomes one unit per lesson kept, so nothing is counted
twice."
```

---

## Task 4: `PracticeSummary`, the footer's arithmetic

**Files:**
- Create: `lib/features/quiz/domain/picker/practice_summary.dart`
- Test: `test/features/quiz/domain/picker/practice_summary_test.dart`

**Interfaces:**
- Consumes: `PracticeIndex`, `PracticeUnit`, the pace from Task 1.
- Produces, relied on by Task 6:

```dart
enum PracticeUnitMode { questions, minutes }

class PracticeSummary {
  int totalQuestions; int perUnit; int unitCount; int shortfallCount;
  int? estimatedMinutes;
  String get headline;   // "45 questions" or "45 questions · about 40 min"
  String get detail;     // "15 from each of 3 selections", plus ", 1 had fewer"
}

abstract final class BuildPracticeSummary {
  static PracticeSummary call({
    required List<PracticeUnit> units,
    required PracticeIndex index,
    required int wheelValue,
    required PracticeUnitMode mode,
    int? averageResponseMs,
  });
}
```

**From the spec, Section 2, "The footer":**

```
45   questions · about 40 min
     15 from each of 3 selections
```

"When a pool holds fewer than asked, the line appends ", 1 had fewer". With nothing selected:
an em rule and "Pick a topic or a lesson above."

**The number is per selection, never a total.** The spec is explicit: "A total cannot be
split at all when five is asked across six topics, and when it can be split, something has
to decide the shares, which is a rule nobody should have to reason about."

**`estimatedMinutes` is null when `averageResponseMs` is null**, and the headline then omits
the duration entirely. Read the ruling at the top of this plan before changing that.

**In minutes mode the wheel's value is minutes**, converted to a per-unit question count
through the pace. Minutes mode is unreachable when the pace is null, so the conversion never
runs without one.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/domain/picker/practice_summary_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_summary.dart';
import 'package:flutter_test/flutter_test.dart';

PracticeTopicEntry topic(String id, int questionCount) => PracticeTopicEntry(
      id: id,
      name: 'Topic $id',
      questionCount: questionCount,
      lessons: const [],
    );

final index = PracticeIndex([
  PracticeSubjectEntry(
    id: 'subject_maths',
    name: 'Mathematics',
    topics: [topic('t_1', 40), topic('t_2', 40), topic('t_3', 8)],
  ),
]);

void main() {
  test('nothing selected says so', () {
    final summary = BuildPracticeSummary.call(
      units: const [],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.totalQuestions, 0);
    expect(summary.detail, 'Pick a topic or a lesson above.');
  });

  test('three full pools give the wheel value each', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
      ],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.totalQuestions, 30);
    expect(summary.headline, '30 questions');
    expect(summary.detail, '15 from each of 2 selections');
  });

  test('a short pool is named in the detail line', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
        PracticeUnit(topicId: 't_3'),
      ],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.totalQuestions, 38);
    expect(summary.shortfallCount, 1);
    expect(summary.detail, '15 from each of 3 selections, 1 had fewer');
  });

  test('one selection reads in the singular', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't_1')],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.detail, '15 from 1 selection');
  });

  test('no pace means no duration', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't_1')],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.estimatedMinutes, isNull);
    expect(summary.headline, '15 questions');
  });

  test('a measured pace adds the duration', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
      ],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
      // 40 seconds a question, 30 questions, 20 minutes.
      averageResponseMs: 40000,
    );

    expect(summary.estimatedMinutes, 20);
    expect(summary.headline, '30 questions · about 20 min');
  });

  test('minutes mode converts through the pace', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
      ],
      index: index,
      // 20 minutes each, at 40 seconds a question, is 30 each.
      wheelValue: 20,
      mode: PracticeUnitMode.minutes,
      averageResponseMs: 40000,
    );

    expect(summary.perUnit, 30);
    expect(summary.totalQuestions, 60);
  });

  test('minutes mode without a pace asks for nothing', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't_1')],
      index: index,
      wheelValue: 20,
      mode: PracticeUnitMode.minutes,
    );

    expect(summary.totalQuestions, 0);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/picker/practice_summary_test.dart`
Expected: FAIL. `practice_summary.dart` does not exist.

- [ ] **Step 3: Write the summary**

Create `lib/features/quiz/domain/picker/practice_summary.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';

enum PracticeUnitMode { questions, minutes }

/// What the footer says, updating on every tick and every scroll.
class PracticeSummary {
  const PracticeSummary({
    required this.totalQuestions,
    required this.perUnit,
    required this.unitCount,
    required this.shortfallCount,
    this.estimatedMinutes,
  });

  static const empty = PracticeSummary(
    totalQuestions: 0,
    perUnit: 0,
    unitCount: 0,
    shortfallCount: 0,
  );

  final int totalQuestions;

  /// Questions asked of each selection. Per selection, never a total: a total
  /// cannot be split at all when five is asked across six topics.
  final int perUnit;

  final int unitCount;

  /// How many pools held fewer than was asked of them.
  final int shortfallCount;

  /// Null until the student's pace has been measured. Never a figure derived
  /// from anything but their own finished attempts.
  final int? estimatedMinutes;

  bool get isEmpty => unitCount == 0;

  String get headline {
    final questions = '$totalQuestions question${totalQuestions == 1 ? '' : 's'}';
    final minutes = estimatedMinutes;
    if (minutes == null) return questions;
    return '$questions · about $minutes min';
  }

  String get detail {
    if (isEmpty) return 'Pick a topic or a lesson above.';
    final base = unitCount == 1
        ? '$perUnit from 1 selection'
        : '$perUnit from each of $unitCount selections';
    if (shortfallCount == 0) return base;
    return '$base, $shortfallCount had fewer';
  }
}

abstract final class BuildPracticeSummary {
  static PracticeSummary call({
    required List<PracticeUnit> units,
    required PracticeIndex index,
    required int wheelValue,
    required PracticeUnitMode mode,
    int? averageResponseMs,
  }) {
    if (units.isEmpty) return PracticeSummary.empty;

    final perUnit = switch (mode) {
      PracticeUnitMode.questions => wheelValue,
      // Minutes mode is unreachable while the pace is null, so this branch
      // only runs with a measured average. Returning zero rather than
      // guessing keeps the footer honest if it is ever reached anyway.
      PracticeUnitMode.minutes => averageResponseMs == null || averageResponseMs == 0
          ? 0
          : (wheelValue * 60000 / averageResponseMs).floor(),
    };

    final pools = _poolSizes(index);
    var total = 0;
    var shortfall = 0;
    for (final unit in units) {
      final available = pools[_key(unit)] ?? 0;
      if (available < perUnit) shortfall++;
      total += available < perUnit ? available : perUnit;
    }

    return PracticeSummary(
      totalQuestions: total,
      perUnit: perUnit,
      unitCount: units.length,
      shortfallCount: shortfall,
      estimatedMinutes: averageResponseMs == null || total == 0
          ? null
          : (total * averageResponseMs / 60000).round(),
    );
  }

  static String _key(PracticeUnit unit) =>
      unit.lessonId == null ? 'topic:${unit.topicId}' : 'lesson:${unit.lessonId}';

  static Map<String, int> _poolSizes(PracticeIndex index) {
    final sizes = <String, int>{};
    for (final topic in index.allTopics) {
      sizes['topic:${topic.id}'] = topic.questionCount;
      for (final lesson in topic.lessons) {
        sizes['lesson:${lesson.id}'] = lesson.questionCount;
      }
    }
    return sizes;
  }
}
```

**`estimatedMinutes` is computed from the questions actually available**, not from what was
asked. A student who asked for 15 across three topics and can only get 38 should be told how
long 38 takes.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/quiz/domain/picker/practice_summary_test.dart`
Expected: PASS, 8 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz/domain/picker/practice_summary.dart \
        test/features/quiz/domain/picker/practice_summary_test.dart
git commit -m "feat(quiz): the picker footer's arithmetic

The wheel's number is per selection, so the footer does the multiplying
and names how many pools came up short. The duration appears only once
the student's own pace has been measured."
```

---

## Task 5: The length wheel

**Files:**
- Create: `lib/features/quiz/presentation/widgets/length_wheel.dart`
- Test: `test/features/quiz/presentation/widgets/length_wheel_test.dart`

**Interfaces:**
- Consumes: `PracticeUnitMode` from Task 4.
- Produces:

```dart
LengthWheel({
  required PracticeUnitMode mode,
  required int value,
  required ValueChanged<int> onChanged,
})
List<int> wheelValues(PracticeUnitMode mode)
int snapToNearest(int value, List<int> candidates)
```

**From the spec, Section 2, "The wheel":** a horizontal scroll-snapped strip, 58px tall,
items in fixed **52px** columns. Selected value in serif 21/700 `ink`, neighbours in sans
14.5 `inkMuted`. A `boardTint` band, **52 by 38**, behind the selected column, no rails and
no border. Both edges fade with a mask from transparent to opaque between 0 and 22%, and
back between 78% and 100%. **The value commits on scroll**, not only on tap.

**Steps: questions 3 to 50 by one. Minutes 2 to 30 by one, then 35 to 60 by five.**

**Switching units snaps to the nearest available value**, so switching back and forth does
not drift.

**Haptics on each step**, disabled under reduce-motion for the scroll animation only; the
control still functions.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/presentation/widgets/length_wheel_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_summary.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/length_wheel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question steps run 3 to 50 by one', () {
    final values = wheelValues(PracticeUnitMode.questions);

    expect(values.first, 3);
    expect(values.last, 50);
    expect(values, hasLength(48));
  });

  test('minute steps run by one to 30, then by five to 60', () {
    final values = wheelValues(PracticeUnitMode.minutes);

    expect(values.first, 2);
    expect(values, contains(30));
    expect(values, contains(35));
    expect(values, isNot(contains(31)));
    expect(values.last, 60);
  });

  test('snapping picks the nearest available value', () {
    expect(snapToNearest(33, wheelValues(PracticeUnitMode.minutes)), 35);
    expect(snapToNearest(31, wheelValues(PracticeUnitMode.minutes)), 30);
  });

  test('snapping clamps below the range', () {
    expect(snapToNearest(1, wheelValues(PracticeUnitMode.questions)), 3);
  });

  test('snapping clamps above the range', () {
    expect(snapToNearest(90, wheelValues(PracticeUnitMode.questions)), 50);
  });

  testWidgets('the wheel reports the value scrolled into the band',
      (tester) async {
    // Pump a LengthWheel in questions mode at value 10 inside a
    // SizedBox(width: 260, height: 58), drag it left by 52 * 3 and settle.
    // Expect the last onChanged value to be 13.
  });
}
```

**Write the widget test body against the real widget once it exists.** The four pure tests
above are the gate for Step 2; the scroll test is written in Step 4, after the widget is
built, because its drag distance depends on the scroll physics chosen.

- [ ] **Step 2: Run the pure tests to verify they fail**

Run: `flutter test test/features/quiz/presentation/widgets/length_wheel_test.dart`
Expected: FAIL. `length_wheel.dart` does not exist.

- [ ] **Step 3: Write the wheel**

Create `lib/features/quiz/presentation/widgets/length_wheel.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fixed column width, so every value lands on one optical centre whatever
/// its number of digits.
const wheelColumnWidth = 52.0;
const wheelHeight = 58.0;
const _bandHeight = 38.0;

/// Questions 3 to 50 by one. Minutes 2 to 30 by one, then 35 to 60 by five.
List<int> wheelValues(PracticeUnitMode mode) => switch (mode) {
      PracticeUnitMode.questions => [for (var i = 3; i <= 50; i++) i],
      PracticeUnitMode.minutes => [
          for (var i = 2; i <= 30; i++) i,
          for (var i = 35; i <= 60; i += 5) i,
        ],
    };

/// The nearest value in [candidates], so switching units and back does not
/// drift the number a step at a time.
int snapToNearest(int value, List<int> candidates) {
  var best = candidates.first;
  var bestDistance = (value - best).abs();
  for (final candidate in candidates) {
    final distance = (value - candidate).abs();
    if (distance < bestDistance) {
      best = candidate;
      bestDistance = distance;
    }
  }
  return best;
}

/// The picker footer's length control.
///
/// Scroll-snapped rather than a slider: the values are discrete, and a slider
/// would invite a drag to a number between two steps.
class LengthWheel extends StatefulWidget {
  const LengthWheel({
    required this.mode,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PracticeUnitMode mode;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<LengthWheel> createState() => _LengthWheelState();
}

class _LengthWheelState extends State<LengthWheel> {
  late FixedExtentScrollController _controller;

  List<int> get _values => wheelValues(widget.mode);

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: _values.indexOf(widget.value).clamp(0, _values.length - 1),
    );
  }

  @override
  void didUpdateWidget(LengthWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _values.indexOf(widget.value);
    if (target >= 0 && target != _controller.selectedItem) {
      _controller.jumpToItem(target);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      height: wheelHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // No rails and no border. The list above this footer is nothing but
          // hairlines, and a tint marks the choice without adding a fourth
          // kind of rule to the screen.
          Container(
            width: wheelColumnWidth,
            height: _bandHeight,
            color: colors.boardTint,
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, 0.22, 0.78, 1],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: RotatedBox(
              quarterTurns: -1,
              child: ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: wheelColumnWidth,
                perspective: 0.002,
                diameterRatio: 100,
                physics: const FixedExtentScrollPhysics(),
                // The value commits on scroll, not only on tap: whatever sits
                // inside the band is the value.
                onSelectedItemChanged: (index) {
                  if (!reduceMotion) unawaited(HapticFeedback.selectionClick());
                  widget.onChanged(_values[index]);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _values.length,
                  builder: (context, index) {
                    final isSelected = _values[index] == widget.value;
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Center(
                        child: Text(
                          '${_values[index]}',
                          style: isSelected
                              ? styles.displaySmall.copyWith(
                                  fontSize: 21,
                                  color: colors.ink,
                                )
                              : styles.bodyMedium.copyWith(
                                  fontSize: 14.5,
                                  color: colors.inkMuted,
                                ),
                        ),
                      ),
                    );
                  },
                ),
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

**`ListWheelScrollView` inside two `RotatedBox`es is how a horizontal snapping wheel is
built in Flutter without a package.** If the rotation fights the shader mask or the hit
testing, the alternative is a `PageView` with `padEnds: false` and a `viewportFraction`
sized to `wheelColumnWidth / constraints.maxWidth`. **Try the rotation first**, and if you
switch, say why in the commit rather than leaving both.

- [ ] **Step 4: Write the scroll test and run everything**

Fill in the widget test from Step 1 against the widget you built. Then run:
`flutter test test/features/quiz/presentation/widgets/length_wheel_test.dart`
Expected: PASS, 6 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz/presentation/widgets/length_wheel.dart \
        test/features/quiz/presentation/widgets/length_wheel_test.dart
git commit -m "feat(quiz): the picker's length wheel

Fixed 52px columns so every value lands on one optical centre, and the
value commits on scroll rather than needing a tap. A tint marks the
selection because the screen above is nothing but hairlines."
```

---

## Task 6: The picker screen

**Files:**
- Create: `lib/features/quiz/presentation/pages/practice_picker_page.dart`
- Test: `test/features/quiz/presentation/pages/practice_picker_page_test.dart`
- Modify: `lib/features/quiz/presentation/practice_picker_providers.dart`

**Interfaces:**
- Consumes: everything from Tasks 1 to 5.
- Produces: `PracticePickerPage({required String examId})`, plus
  `practicePaceProvider`, a `FutureProvider.family<int?, ExamId>`.

**From the spec, Section 2, "Composition":** app bar with a back chevron and the word
"Quiz", plus **"Clear"** in board 12/600 as a trailing action **shown only when something is
selected**. Title "Choose what to practice" in `displaySmall`. Then the legend, then the
index, then a fixed footer.

**The legend, once, beneath the title, in 11.5 `inkMuted`:** "Lessons you haven't read yet
are marked."

**The topic row**, minimum height 46: a **15px checkbox** in the gutter, radius 3, 1.4px
`inkMuted` border, filling `board` with a white check when selected and showing a **board
dash** when partly selected. The topic name. **No question count.** A trailing **caret**
with its own 44px target.

**The row splits its taps.** Tapping the row selects the whole topic. Tapping the caret
unfolds its lessons.

**Lesson rows** are indented 22px, carry their own 14px checkbox, the title, and nothing
else unless unread, when they carry "not read yet" in `bodySmall` `rust` in the meta column.

**Topics with no questions** are dimmed to `inkMuted`, checkbox at 35% opacity, not
selectable, with **"no questions yet"** in the meta slot.

**The footer:** fixed above the safe area, opened by a 1px `rule`, 13px padding. The
summary, the unit control, the wheel, and **"Start"**, a full-width board button, disabled
while nothing is selected.

**The unit control**, centred, 12px: `questions · minutes`, separated by a 1px by 11px `rule`
tick with 9px margins, the active one in `ink` w700. No pills. **The minutes half is absent
while the pace is null.** See the ruling at the top of this plan.

- [ ] **Step 1: Add the pace provider**

Append to `lib/features/quiz/presentation/practice_picker_providers.dart`:

```dart
/// The student's own average time on one question, or null until seven
/// finished attempts make an average worth using.
///
/// Null hides the footer's minutes unit outright. Converting a request for
/// twenty minutes into a number of questions without a measured pace would be
/// a measurement multiplied by an assumption, which is the one thing no figure
/// in this app may be.
final practicePaceProvider =
    FutureProvider.family<int?, ExamId>((ref, examId) async {
  return ref.watch(attemptsRepositoryProvider).averageResponseMs(examId: examId);
});
```

- [ ] **Step 2: Write the failing test**

Create `test/features/quiz/presentation/pages/practice_picker_page_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/pages/practice_picker_page.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/practice_picker_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

final _index = PracticeIndex([
  PracticeSubjectEntry(
    id: 'subject_maths',
    name: 'Mathematics',
    topics: [
      PracticeTopicEntry(
        id: 'topic_algebra',
        name: 'Algebra',
        questionCount: 40,
        lessons: const [
          PracticeLessonEntry(
            id: 'l_1',
            title: 'Linear equations',
            isRead: true,
            questionCount: 6,
          ),
          PracticeLessonEntry(
            id: 'l_2',
            title: 'Quadratics',
            isRead: false,
            questionCount: 6,
          ),
        ],
      ),
      const PracticeTopicEntry(
        id: 'topic_empty',
        name: 'Trigonometry',
        questionCount: 0,
        lessons: [],
      ),
    ],
  ),
]);

Future<void> pumpPicker(WidgetTester tester, {int? pace}) =>
    tester.pumpAppWithProviders(
      const PracticePickerPage(examId: 'exam_cse_pro'),
      overrides: [
        practiceIndexProvider('exam_cse_pro').overrideWith((_) async => _index),
        practicePaceProvider('exam_cse_pro').overrideWith((_) async => pace),
      ],
    );

void main() {
  testWidgets('the screen names itself and explains its one mark',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Choose what to practice'), findsOneWidget);
    expect(
      find.text("Lessons you haven't read yet are marked."),
      findsOneWidget,
    );
  });

  testWidgets('only unread lessons are marked', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('caret_topic_algebra')));
    await tester.pumpAndSettle();

    expect(find.text('not read yet'), findsOneWidget);
  });

  testWidgets('a topic with no questions says so and does not select',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('no questions yet'), findsOneWidget);

    await tester.tap(find.text('Trigonometry'));
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsNothing);
  });

  testWidgets('Clear appears only once something is selected', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsNothing);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('the empty footer invites a selection', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Pick a topic or a lesson above.'), findsOneWidget);
  });

  testWidgets('Start is disabled with nothing selected', (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    final start = tester.widget<BoardButton>(
      find.widgetWithText(BoardButton, 'Start'),
    );
    expect(start.onPressed, isNull);
  });

  testWidgets('the minutes unit is hidden without a measured pace',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('questions'), findsWidgets);
    expect(find.text('minutes'), findsNothing);
  });

  testWidgets('the minutes unit appears once the pace is known',
      (tester) async {
    await pumpPicker(tester, pace: 40000);
    await tester.pumpAndSettle();

    expect(find.text('minutes'), findsOneWidget);
  });

  testWidgets('tapping the caret unfolds, tapping the row selects',
      (tester) async {
    await pumpPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Quadratics'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('caret_topic_algebra')));
    await tester.pumpAndSettle();
    expect(find.text('Quadratics'), findsOneWidget);
    expect(find.text('Clear'), findsNothing);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    expect(find.text('Clear'), findsOneWidget);
  });
}
```

Add the `BoardButton` import.

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/pages/practice_picker_page_test.dart`
Expected: FAIL. `practice_picker_page.dart` does not exist.

- [ ] **Step 4: Write the screen**

Create `lib/features/quiz/presentation/pages/practice_picker_page.dart`. It is a
`ConsumerStatefulWidget` holding three pieces of local state and nothing else: the
`PracticeSelection`, the set of unfolded topic ids, and the wheel's value and mode.

The structure, with the spec's measurements:

```dart
class PracticePickerPage extends ConsumerStatefulWidget {
  const PracticePickerPage({required this.examId, super.key});

  final String examId;
  ...
}

class _PracticePickerPageState extends ConsumerState<PracticePickerPage> {
  PracticeSelection _selection = const PracticeSelection.empty();
  final Set<TopicId> _unfolded = {};
  PracticeUnitMode _mode = PracticeUnitMode.questions;
  int _wheelValue = 10;
```

**The app bar:**

```dart
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Quiz', style: styles.headlineMedium),
        actions: [
          // Shown only when something is selected: an always-present Clear on
          // an empty screen is a control with nothing to do.
          if (!_selection.isEmpty)
            TextButton(
              onPressed: () => setState(() => _selection = _selection.cleared()),
              child: Text(
                'Clear',
                style: styles.bodySmall.copyWith(
                  color: colors.board,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
```

**The title and legend**, in the scroll view above the index:

```dart
        Text('Choose what to practice', style: styles.displaySmall),
        const SizedBox(height: 4),
        Text(
          "Lessons you haven't read yet are marked.",
          style: styles.bodySmall.copyWith(fontSize: 11.5, color: colors.inkMuted),
        ),
```

**The checkbox**, a private widget used at both sizes:

```dart
class _PickerCheckbox extends StatelessWidget {
  const _PickerCheckbox({
    required this.state,
    required this.size,
    this.enabled = true,
  });

  final PracticeCheckState state;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = state != PracticeCheckState.off;

    return Opacity(
      // 35% on a topic that cannot be selected, so the gutter still reads as
      // a column without offering a tick that would do nothing.
      opacity: enabled ? 1 : 0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? colors.board : null,
          borderRadius: BorderRadius.circular(3),
          border: filled
              ? null
              : Border.all(color: colors.inkMuted, width: 1.4),
        ),
        child: switch (state) {
          PracticeCheckState.on =>
            Icon(Icons.check, size: size - 4, color: colors.onBoard),
          // The dash is the third state the spec names: some but not all.
          PracticeCheckState.partial => Center(
              child: Container(
                width: size - 6,
                height: 1.6,
                color: colors.onBoard,
              ),
            ),
          PracticeCheckState.off => null,
        },
      ),
    );
  }
}
```

**The topic row**, minimum height 46, with its taps split:

```dart
class _TopicRow extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.ruleFaint, width: AppDimensions.hairline),
        ),
      ),
      child: Row(
        children: [
          // Tapping the row selects the whole topic. The caret gets its own
          // 44px target carved out of it, which is the pattern the Study
          // spec committed to for its pinned topic bar.
          Expanded(
            child: InkWell(
              onTap: topic.hasQuestions ? onToggle : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    _PickerCheckbox(
                      state: state,
                      size: 15,
                      enabled: topic.hasQuestions,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topic.name,
                        style: topic.hasQuestions
                            ? styles.bodyMedium
                            : styles.bodyMedium.copyWith(color: colors.inkMuted),
                      ),
                    ),
                    if (!topic.hasQuestions)
                      Text(
                        'no questions yet',
                        style: styles.bodySmall.copyWith(color: colors.inkMuted),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (topic.canUnfold)
            InkWell(
              key: ValueKey('caret_${topic.id}'),
              onTap: onUnfold,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  isUnfolded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: colors.inkMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

**The lesson row**, indented 22px, 14px checkbox, "not read yet" in `rust` only when unread:

```dart
                    const SizedBox(width: 22),
                    _PickerCheckbox(state: state, size: 14),
                    const SizedBox(width: 12),
                    Expanded(child: Text(lesson.title, style: styles.bodyMedium)),
                    if (!lesson.isRead)
                      Text(
                        'not read yet',
                        style: styles.bodySmall.copyWith(color: colors.rust),
                      ),
```

**The footer**, fixed above the safe area:

```dart
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.rule, width: AppDimensions.hairline),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Summary(summary: summary),
              const SizedBox(height: 8),
              _UnitControl(
                mode: _mode,
                minutesAvailable: pace != null,
                onChanged: _switchMode,
              ),
              LengthWheel(
                mode: _mode,
                value: _wheelValue,
                onChanged: (value) => setState(() => _wheelValue = value),
              ),
              const SizedBox(height: 8),
              BoardButton(
                label: 'Start',
                onPressed: summary.isEmpty ? null : _start,
              ),
            ],
          ),
        ),
      ),
```

**`_switchMode` snaps**, so switching units and back does not drift:

```dart
  void _switchMode(PracticeUnitMode mode) {
    setState(() {
      _mode = mode;
      _wheelValue = snapToNearest(_wheelValue, wheelValues(mode));
    });
  }
```

**The summary's headline puts the value in serif 21/700 tabular and the rest in 12
`inkMuted`, with the duration in `ink` w600.** Build it as a `Text.rich` rather than
splitting the string, so the tabular figure and the muted tail sit on one baseline.

**With nothing selected the spec asks for an em rule** in the value slot, which is the
character `—`. That is the one place an em dash is correct: it is a typographic rule
standing in for a missing number, not punctuation in a sentence.

`_start` is Task 8. Leave it calling a method that throws `UnimplementedError` with a
comment naming Task 8, and wire it there.

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib/features/quiz test/features/quiz
git commit -m "feat(quiz): the practice picker screen

The gutter belongs to selection, so read state is annotated instead: only
unread lessons carry a mark, because most lessons end up read and marking
those marks almost everything."
```

---

## Task 7: Drill becomes honest

**Files:**
- Modify: `lib/features/quiz/domain/picker/drill_picker.dart`
- Modify: `lib/features/quiz/domain/picker/pick_context.dart`
- Test: `test/features/quiz/domain/picker/drill_picker_test.dart`

**Interfaces:**
- Consumes: `PickContext`.
- Produces: `PickContext` gains `excludedQuestionIds` and `shuffleSeed`. `DrillPicker`
  shuffles and excludes.

**From the spec, Section 5, "Drill becomes honest":** the picker's sessions "must **shuffle
within the pool** and **exclude anything answered in the last 7 days**, which is what Spec 4
§4.3 specified and what was never built. Without it the subtitle 'questions you haven't seen
this week' is a lie and the row returns the same ten in the same order forever."

**What is there today.** `DrillPicker.pick` calls `SubtopicFilter.general(subtopicCandidates)`
and takes the first N. Both callers build every candidate with `subtopicId: null`, so
`general()` returns the whole pool in table order. The result is deterministic and identical
on every run.

**The exclusion must not empty the session.** A student who has answered every question in a
small topic this week would get nothing. **Excluded questions come back as a fallback tail**,
after the unseen ones, so the session is always full if the pool can fill it.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/domain/picker/drill_picker_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/drill_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:flutter_test/flutter_test.dart';

Question question(String id) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_cse_pro'],
      topicId: 'topic_algebra',
      language: 'en',
      stem: 'stem $id',
      choices: const [
        Choice(id: 'c_a', text: 'a', isCorrect: true),
        Choice(id: 'c_b', text: 'b', isCorrect: false),
      ],
      explanation: 'because',
    );

List<Question> pool(int count) =>
    [for (var i = 0; i < count; i++) question('q_$i')];

void main() {
  test('the pool is shuffled, not taken from the top', () {
    final questions = pool(30);

    final first = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 1,
      ),
    );
    final second = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 2,
      ),
    );

    expect(first.map((q) => q.id), isNot(equals(second.map((q) => q.id))));
  });

  test('the same seed picks the same session', () {
    final questions = pool(30);

    final first = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 7,
      ),
    );
    final second = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 10,
        shuffleSeed: 7,
      ),
    );

    expect(first.map((q) => q.id), equals(second.map((q) => q.id)));
  });

  test('recently answered questions are skipped', () {
    final questions = pool(20);

    final picked = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 5,
        excludedQuestionIds: const {'q_0', 'q_1', 'q_2'},
        shuffleSeed: 1,
      ),
    );

    expect(
      picked.map((q) => q.id),
      isNot(anyElement(isIn(['q_0', 'q_1', 'q_2']))),
    );
  });

  test('an exhausted pool still fills the session', () {
    final questions = pool(6);

    final picked = DrillPicker().pick(
      PickContext(
        allQuestions: questions,
        requestedLength: 6,
        excludedQuestionIds: {for (final q in questions) q.id},
        shuffleSeed: 1,
      ),
    );

    expect(picked, hasLength(6));
  });

  test('a short pool gives what it has', () {
    final picked = DrillPicker().pick(
      PickContext(
        allQuestions: pool(3),
        requestedLength: 10,
        shuffleSeed: 1,
      ),
    );

    expect(picked, hasLength(3));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/picker/drill_picker_test.dart`
Expected: FAIL. `PickContext` has no `shuffleSeed` or `excludedQuestionIds`.

- [ ] **Step 3: Widen `PickContext`**

In `lib/features/quiz/domain/picker/pick_context.dart`, add two fields to the constructor
and the class:

```dart
    this.excludedQuestionIds = const {},
    this.shuffleSeed,
```

```dart
  /// Answered in the last seven days. Skipped where the pool allows, so a
  /// repeated drill does not return the same ten.
  final Set<QuestionId> excludedQuestionIds;

  /// Fixed only in tests. Null means a fresh shuffle each time.
  final int? shuffleSeed;
```

- [ ] **Step 4: Rewrite `DrillPicker`**

Replace `lib/features/quiz/domain/picker/drill_picker.dart`:

```dart
import 'dart:math';

import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';

/// Shuffles the pool and prefers what the student has not just seen.
///
/// It used to filter through `SubtopicFilter`, which both callers fed
/// all-null subtopic ids, so it returned the pool in table order and took the
/// first N. The same ten questions came back in the same order forever, which
/// made "questions you haven't seen this week" untrue.
class DrillPicker implements QuestionPicker {
  @override
  List<Question> pick(PickContext context) {
    final random = Random(context.shuffleSeed);
    final shuffled = [...context.allQuestions]..shuffle(random);

    final fresh = <Question>[];
    final seen = <Question>[];
    for (final question in shuffled) {
      if (context.excludedQuestionIds.contains(question.id)) {
        seen.add(question);
      } else {
        fresh.add(question);
      }
    }

    // Recently answered questions come back as a tail rather than being
    // dropped. A student who worked through a small topic this week should
    // still get a full session, just not the same one first.
    return [...fresh, ...seen].take(context.requestedLength).toList();
  }
}
```

`SubtopicFilter` is no longer imported here. It stays in the tree: `start_inline_lesson_quiz.dart`
still imports it, and removing it is the dead-subtopic cleanup already logged on 2 August,
not this plan's job.

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS. `start_drill` tests that asserted on question order will fail; that is the
point of the change. Update them to assert on length and membership rather than order, and
pass a `shuffleSeed` where a fixed order is genuinely needed.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "fix(quiz): drills stop returning the same ten in the same order

DrillPicker filtered through SubtopicFilter, which both callers fed
all-null ids, so it took the head of the pool in table order every time.
It now shuffles and puts anything answered this week at the back."
```

---

## Task 8: `StartPractice`, and the row opens

**Files:**
- Create: `lib/features/quiz/domain/use_cases/start_practice.dart`
- Test: `test/features/quiz/domain/use_cases/start_practice_test.dart`
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Modify: `lib/features/quiz/presentation/pages/practice_picker_page.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Modify: `lib/app/router.dart`

**Interfaces:**
- Consumes: `PracticeUnit` from Task 3, `DrillPicker` from Task 7,
  `questionIdsAnsweredSince` from Task 1.
- Produces: `StartPractice`, `StartPracticeStarted`, `StartPracticeNoQuestions`,
  `QuizController.startPractice`, `QuizPageMode.practice`, and the routes
  `/quiz/practice/:examId` and `/quiz/practice/:examId/run`.

**Why a new use case and not `StartDrill`.** `StartDrill` takes one `topicId` and creates one
session from one pool. The picker produces many units, each drawing `perUnit` questions from
its own pool, into a single session. `StartDrill` stays exactly as it is for anything that
wants one topic.

**The exclusion window is seven days**, per Section 5.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/domain/use_cases/start_practice_test.dart` following the shape of
`test/features/quiz/domain/use_cases/start_today_session_test.dart`, which already builds a
`ContentRepository` and a `QuizSessionRepository` over an in-memory database. Cover:

```dart
  test('each unit contributes its own questions', () async {
    // Two topics of 20 questions each, perUnit 5.
    // Expect 10 questions in the session, 5 from each topic.
  });

  test('a short pool contributes what it has', () async {
    // One topic of 3 questions, perUnit 5.
    // Expect 3.
  });

  test('no units means no session', () async {
    // Expect StartPracticeNoQuestions.
  });

  test('the session is recorded as a drill', () async {
    // Expect the created row's origin to be SessionOrigin.drill.
  });

  test('a lesson unit draws only that lesson', () async {
    // One topic, two lessons, questions tagged.
    // Expect only the selected lesson's questions.
  });
```

Write the bodies in full against the helpers that file already defines. Do not leave the
comments in place: the plan's rule is that every test step carries real code, and these are
descriptions of tests you are to write from the neighbouring file's idiom.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/use_cases/start_practice_test.dart`
Expected: FAIL. `start_practice.dart` does not exist.

- [ ] **Step 3: Write the use case**

Create `lib/features/quiz/domain/use_cases/start_practice.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/drill_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:uuid/uuid.dart';

/// Anything answered inside this window goes to the back of the pool.
const practiceRecencyWindow = Duration(days: 7);

sealed class StartPracticeResult {
  const StartPracticeResult();
}

class StartPracticeStarted extends StartPracticeResult {
  const StartPracticeStarted(this.session);

  final QuizSession session;
}

class StartPracticeNoQuestions extends StartPracticeResult {
  const StartPracticeNoQuestions(this.message);

  final String message;
}

/// One session from many selections, each drawing [perUnit] from its own pool.
///
/// Per selection rather than a total because a total cannot be split at all
/// when five is asked across six topics, and when it can be split something
/// has to decide the shares.
class StartPractice {
  StartPractice({
    required ContentRepository content,
    required QuizSessionRepository sessions,
    required AttemptsRepository attempts,
    QuestionPicker? picker,
    Uuid? uuid,
  })  : _content = content,
        _sessions = sessions,
        _attempts = attempts,
        _picker = picker ?? DrillPicker(),
        _uuid = uuid ?? const Uuid();

  final ContentRepository _content;
  final QuizSessionRepository _sessions;
  final AttemptsRepository _attempts;
  final QuestionPicker _picker;
  final Uuid _uuid;

  Future<StartPracticeResult> call({
    required String userId,
    required ExamId examId,
    required List<PracticeUnit> units,
    required int perUnit,
    required DateTime now,
  }) async {
    if (units.isEmpty || perUnit <= 0) {
      return const StartPracticeNoQuestions(
        'Pick a topic or a lesson first.',
      );
    }

    final excluded = await _attempts.questionIdsAnsweredSince(
      examId: examId,
      since: now.subtract(practiceRecencyWindow),
    );

    final picked = <Question>[];
    final used = <QuestionId>{};
    for (final unit in units) {
      final pool = await _poolFor(unit);
      final drawn = _picker.pick(
        PickContext(
          allQuestions: pool,
          requestedLength: perUnit,
          excludedQuestionIds: excluded,
        ),
      );
      for (final question in drawn) {
        // A question tagged to a lesson also sits in that lesson's topic, so
        // selecting both would ask it twice.
        if (used.add(question.id)) picked.add(question);
      }
    }

    if (picked.isEmpty) {
      return const StartPracticeNoQuestions(
        'There are no questions in what you picked.',
      );
    }

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
      origin: SessionOrigin.drill,
      // A session spanning several topics is named after none of them.
      topicId: units.length == 1 ? units.single.topicId : null,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: SessionOrigin.drill,
      topicId: session.topicId,
      questionIds: picked.map((question) => question.id).toList(),
      startedAt: now,
    );
    return StartPracticeStarted(session);
  }

  Future<List<Question>> _poolFor(PracticeUnit unit) async {
    final questions = await _content.questionsByTopic(unit.topicId);
    final lessonId = unit.lessonId;
    if (lessonId == null) return questions;
    return questions
        .where((question) => question.lessonId == lessonId)
        .toList();
  }
}
```

- [ ] **Step 4: Wire the controller, the page and the routes**

In `quiz_controller.dart`, add the provider and the method, following `startDrill`'s shape
exactly:

```dart
final startPracticeProvider = Provider<StartPractice>(
  (ref) => StartPractice(
    content: ref.watch(contentRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
    attempts: ref.watch(attemptsRepositoryProvider),
  ),
);
```

```dart
  Future<void> startPractice({
    required ExamId examId,
    required List<PracticeUnit> units,
    required int perUnit,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startPracticeProvider)(
        userId: _localUserId,
        examId: examId,
        units: units,
        perUnit: perUnit,
        now: now,
      );
      switch (result) {
        case StartPracticeStarted(:final session):
          state = QuizRunning(
            session: session,
            questionShownAt: now,
            persisted: true,
          );
        case StartPracticeNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }
```

**The picker's Start does not navigate through a query string.** The units are a list of
pairs and would not survive a URL cleanly. Instead the page starts the session itself and
then pushes the runner:

```dart
  Future<void> _start() async {
    final index = ref.read(practiceIndexProvider(widget.examId)).valueOrNull;
    if (index == null) return;
    await ref.read(quizControllerProvider.notifier).startPractice(
          examId: widget.examId,
          units: _selection.units(index),
          perUnit: _summary.perUnit,
        );
    if (!mounted) return;
    unawaited(context.push('/quiz/practice/${widget.examId}/run'));
  }
```

Add `QuizPageMode.practice` to `quiz_page.dart`'s enum, and in its `initState` switch:

```dart
        case QuizPageMode.practice:
          // The picker already started it. Starting again here would create a
          // second session and throw away the first.
          break;
```

In `router.dart`:

```dart
      GoRoute(
        path: '/quiz/practice/:examId',
        builder: (_, state) => PracticePickerPage(
          examId: state.pathParameters['examId']!,
        ),
      ),
      GoRoute(
        path: '/quiz/practice/:examId/run',
        builder: (_, state) => QuizPage(
          examId: state.pathParameters['examId']!,
          mode: QuizPageMode.practice,
        ),
      ),
```

And in `quiz_tab_home.dart`, the row that Plan 2a deliberately left inert:

```dart
        InkTableRow(
          title: 'Choose what to practice',
          subtitle: 'One topic or one lesson, your choice of length',
          bottomRule: false,
          onTap: () => context.push('/quiz/practice/${exam.id}'),
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
git commit -m "feat(quiz): the picker starts its session

One session from many selections, each drawing its own share, because a
total cannot be split when five is asked across six topics. The tab's
Choose what to practice row finally opens something."
```

---

## What this plan deliberately does not do

- **Weighting the picker toward recently-read topics.** Deferred by name in Section 5, with
  the note that `read_then_quiz_signal.dart` already measures the behaviour.
- **Tagging questions with a `lessonId`.** The picker's lesson rows appear wherever the data
  supports them and stay absent where it does not. The tagging pass is a content job listed
  in the work checkpoint.
- **Deleting `SubtopicFilter`.** `start_inline_lesson_quiz.dart` still imports it. The
  dead-subtopic cleanup is logged on 2 August and belongs to its own pass.
- **The reveal, the debrief and the review component.** Seams 4, 5 and 6.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # still 7, not 8
flutter test                                     # all pass
```

By hand, on a device, since Aedwon does the visual verification:

- "Choose what to practice" opens a pushed screen with a back chevron reading "Quiz".
- "Clear" is absent until something is ticked.
- Tapping a topic row ticks the whole topic; tapping its caret unfolds it without ticking
  anything.
- Unticking one lesson turns the topic's box into a dash.
- Only unread lessons carry "not read yet".
- A topic with no questions is dimmed, says "no questions yet", and does not tick.
- The footer updates as the wheel scrolls, without a tap.
- The unit control shows "questions" alone on a new account, and gains "minutes" once seven
  sessions have been finished.
- Running the same selection twice gives a different set of questions.

## Self-review notes

Checked against Section 2 in full and Section 5's "Drill becomes honest":

- Composition, app bar, conditional Clear, title, legend: Task 6.
- Topic rows with split taps, no count, the caret's own target: Task 6.
- Hierarchical selection and the dash, counting that never double-adds: Task 3.
- Read state as the only annotation: Tasks 2 and 6.
- Topics with no questions dimmed and unselectable: Tasks 2 and 6.
- The footer's summary, shortfall clause, unit control, wheel and Start: Tasks 4, 5 and 6.
- Shuffle within the pool and exclude the last 7 days: Tasks 7 and 8.
- **One deviation, stated at the top and flagged for Aedwon rather than decided quietly:**
  the minutes unit is withheld until the pace is measured, applying the ruling he made twice
  on 2 August rather than reopening it. If he wants it always visible, the change is one
  line in `practicePaceProvider`.
