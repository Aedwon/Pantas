# Assessment Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a one-time per-exam placement assessment that samples questions from all topics, seeds FSRS from day one, and surfaces a prioritized study plan via a results screen; include a progressive nudge on QuizResultsPage for users who haven't taken the assessment.

**Architecture:** Pure local-first — assessment session is in-memory only (lost on app background), results are persisted to a new `AssessmentResultsLocal` Drift table (schemaVersion → 3). Domain logic lives in feature-scoped use cases; UI reuses existing `QuestionCard` and `QuizProgressBar` components. Nudge logic is injected into the existing `QuizResultsPage` by converting `_ResultsBody` to a `ConsumerStatefulWidget`.

**Tech Stack:** Flutter, Drift (local SQLite), Riverpod (FutureProvider.family, Provider), GoRouter, FSRS scheduler

---

## File Map

**New files:**
- `lib/core/storage/data/tables/assessment_results_local_table.dart` — Drift table definition
- `lib/core/storage/data/repos/assessment_repository.dart` — DB read/write + `TopicScore` DTO
- `lib/features/assessment/domain/models/assessment_question.dart`
- `lib/features/assessment/domain/models/assessment_session.dart`
- `lib/features/assessment/domain/models/topic_mastery.dart` — `TopicMastery` + `MasteryLevel` enum
- `lib/features/assessment/domain/models/assessment_result.dart`
- `lib/features/assessment/domain/services/assessment_question_selector.dart`
- `lib/features/assessment/domain/use_cases/start_assessment.dart`
- `lib/features/assessment/domain/use_cases/complete_assessment.dart`
- `lib/features/assessment/presentation/assessment_page.dart`
- `lib/features/assessment/presentation/assessment_results_page.dart`
- `lib/features/assessment/assessment.dart` — barrel export

**Modified files:**
- `lib/core/storage/data/app_database.dart` — add table, schemaVersion → 3, migration
- `lib/core/storage/storage.dart` — add 4 providers
- `lib/core/storage/data/repos/content_repository.dart` — add `topicsByExam`
- `lib/core/storage/data/repos/attempts_repository.dart` — add `countForExam`
- `lib/app/router.dart` — add 2 assessment routes
- `lib/features/quiz/presentation/quiz_results_page.dart` — add assessment nudge

**Test files:**
- `test/core/storage/data/app_database_test.dart` — update schemaVersion assertion
- `test/core/storage/data/repos/assessment_repository_test.dart`
- `test/features/assessment/domain/models/topic_mastery_test.dart`
- `test/core/storage/data/repos/content_repository_topics_by_exam_test.dart`
- `test/core/storage/data/repos/attempts_repository_count_test.dart`
- `test/features/assessment/domain/services/assessment_question_selector_test.dart`
- `test/features/assessment/domain/use_cases/start_assessment_test.dart`
- `test/features/assessment/domain/use_cases/complete_assessment_test.dart`
- `test/features/assessment/presentation/assessment_page_test.dart`
- `test/features/assessment/presentation/assessment_results_page_test.dart`
- `test/features/quiz/presentation/quiz_results_nudge_test.dart`

---

### Task 1: DB table + schema migration

**Files:**
- Create: `lib/core/storage/data/tables/assessment_results_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `test/core/storage/data/app_database_test.dart`

- [ ] **Step 1: Create the table definition**

Create `lib/core/storage/data/tables/assessment_results_local_table.dart`:

```dart
// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('AssessmentResultLocalRow')
class AssessmentResultsLocal extends Table {
  TextColumn get examId => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get topicScoresJson => text()();
  TextColumn get syncState =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {examId};
}
```

- [ ] **Step 2: Register the table in app_database.dart and bump schemaVersion**

Replace `lib/core/storage/data/app_database.dart` with:

```dart
import 'package:cse_cet_reviewer/core/storage/data/tables/assessment_results_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/attempts_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/exams_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/lesson_progress_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/lessons_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/questions_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/review_state_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/streak_local_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/subjects_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exams,
    Subjects,
    Topics,
    Questions,
    Lessons,
    AttemptsLocal,
    ReviewStateLocal,
    StreakLocal,
    LessonProgressLocal,
    QuizNudgeDismissedLocal,
    AssessmentResultsLocal,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(lessonProgressLocal);
            await m.createTable(quizNudgeDismissedLocal);
          }
          if (from < 3) {
            await m.createTable(assessmentResultsLocal);
          }
        },
      );
}
```

- [ ] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `app_database.g.dart` regenerated with `assessmentResultsLocal` accessor and `AssessmentResultLocalRow` / `AssessmentResultsLocalCompanion` types. No errors.

- [ ] **Step 4: Update the schemaVersion test**

In `test/core/storage/data/app_database_test.dart`, change:

```dart
test('schemaVersion is 2', () {
  expect(db.schemaVersion, equals(2));
});
```

to:

```dart
test('schemaVersion is 3', () {
  expect(db.schemaVersion, equals(3));
});
```

- [ ] **Step 5: Run tests**

```bash
flutter test test/core/storage/data/app_database_test.dart
```

Expected: all tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/core/storage/data/tables/assessment_results_local_table.dart \
        lib/core/storage/data/app_database.dart \
        lib/core/storage/data/app_database.g.dart \
        test/core/storage/data/app_database_test.dart
git commit -m "feat(assessment): add AssessmentResultsLocal table, schemaVersion 3"
```

---

### Task 2: AssessmentRepository

**Files:**
- Create: `lib/core/storage/data/repos/assessment_repository.dart`
- Create: `test/core/storage/data/repos/assessment_repository_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/storage/data/repos/assessment_repository_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AssessmentRepository repo;

  setUp(() {
    final db = inMemoryDatabase();
    repo = AssessmentRepository(db);
  });

  group('resultForExam', () {
    test('returns null when no result exists', () async {
      expect(await repo.resultForExam('exam1'), isNull);
    });

    test('returns row after saveResult', () async {
      final now = DateTime(2026, 1, 1);
      await repo.saveResult('exam1', now, [
        const TopicScore(topicId: 't1', correct: 2, total: 3),
      ]);

      final row = await repo.resultForExam('exam1');
      expect(row, isNotNull);
      expect(row!.examId, equals('exam1'));
      expect(row.completedAt, equals(now));
      final scores = (jsonDecode(row.topicScoresJson) as List)
          .cast<Map<String, dynamic>>();
      expect(scores, hasLength(1));
      expect(scores.first['topicId'], equals('t1'));
      expect(scores.first['correct'], equals(2));
      expect(scores.first['total'], equals(3));
    });
  });

  group('hasCompletedForExam', () {
    test('returns false when no result exists', () async {
      expect(await repo.hasCompletedForExam('exam1'), isFalse);
    });

    test('returns true after saveResult', () async {
      await repo.saveResult('exam1', DateTime.now(), []);
      expect(await repo.hasCompletedForExam('exam1'), isTrue);
    });
  });

  group('saveResult upsert', () {
    test('second saveResult for same exam overwrites, not duplicates', () async {
      final t1 = DateTime(2026, 1, 1);
      final t2 = DateTime(2026, 2, 1);
      await repo.saveResult('exam1', t1, [
        const TopicScore(topicId: 't1', correct: 1, total: 3),
      ]);
      await repo.saveResult('exam1', t2, [
        const TopicScore(topicId: 't1', correct: 3, total: 3),
      ]);

      final row = await repo.resultForExam('exam1');
      expect(row!.completedAt, equals(t2));
      final scores = (jsonDecode(row.topicScoresJson) as List)
          .cast<Map<String, dynamic>>();
      expect(scores.first['correct'], equals(3));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/storage/data/repos/assessment_repository_test.dart
```

Expected: FAIL — `AssessmentRepository` and `TopicScore` not defined.

- [ ] **Step 3: Implement AssessmentRepository**

Create `lib/core/storage/data/repos/assessment_repository.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:drift/drift.dart';

class TopicScore {
  const TopicScore({
    required this.topicId,
    required this.correct,
    required this.total,
  });

  final String topicId;
  final int correct;
  final int total;

  Map<String, dynamic> toJson() => {
        'topicId': topicId,
        'correct': correct,
        'total': total,
      };
}

class AssessmentRepository {
  AssessmentRepository(this._db);

  final AppDatabase _db;

  Future<void> saveResult(
    ExamId examId,
    DateTime completedAt,
    List<TopicScore> scores,
  ) async {
    await _db.into(_db.assessmentResultsLocal).insertOnConflictUpdate(
          AssessmentResultsLocalCompanion.insert(
            examId: examId,
            completedAt: completedAt,
            topicScoresJson:
                jsonEncode(scores.map((s) => s.toJson()).toList()),
          ),
        );
  }

  Future<AssessmentResultLocalRow?> resultForExam(ExamId examId) async {
    return (_db.select(_db.assessmentResultsLocal)
          ..where((r) => r.examId.equals(examId)))
        .getSingleOrNull();
  }

  Future<bool> hasCompletedForExam(ExamId examId) async {
    final row = await resultForExam(examId);
    return row != null;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/core/storage/data/repos/assessment_repository_test.dart
```

Expected: all 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/repos/assessment_repository.dart \
        test/core/storage/data/repos/assessment_repository_test.dart
git commit -m "feat(assessment): add AssessmentRepository with TopicScore DTO"
```

---

### Task 3: Domain models

**Files:**
- Create: `lib/features/assessment/domain/models/assessment_question.dart`
- Create: `lib/features/assessment/domain/models/assessment_session.dart`
- Create: `lib/features/assessment/domain/models/topic_mastery.dart`
- Create: `lib/features/assessment/domain/models/assessment_result.dart`
- Create: `test/features/assessment/domain/models/topic_mastery_test.dart`

- [ ] **Step 1: Write failing tests for TopicMastery**

Create `test/features/assessment/domain/models/topic_mastery_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:flutter_test/flutter_test.dart';

Topic _topic() => const Topic(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    );

void main() {
  group('MasteryLevel derivation', () {
    test('0 of 0 → weak', () {
      expect(
        TopicMastery(topic: _topic(), correct: 0, total: 0).level,
        equals(MasteryLevel.weak),
      );
    });

    test('0% → weak', () {
      expect(
        TopicMastery(topic: _topic(), correct: 0, total: 3).level,
        equals(MasteryLevel.weak),
      );
    });

    test('40% boundary → weak', () {
      // 2/5 = 40%
      expect(
        TopicMastery(topic: _topic(), correct: 2, total: 5).level,
        equals(MasteryLevel.weak),
      );
    });

    test('41% → moderate', () {
      // 41/100 = 41%
      expect(
        TopicMastery(topic: _topic(), correct: 41, total: 100).level,
        equals(MasteryLevel.moderate),
      );
    });

    test('70% boundary → moderate', () {
      // 7/10 = 70%
      expect(
        TopicMastery(topic: _topic(), correct: 7, total: 10).level,
        equals(MasteryLevel.moderate),
      );
    });

    test('71% → strong', () {
      // 71/100 = 71%
      expect(
        TopicMastery(topic: _topic(), correct: 71, total: 100).level,
        equals(MasteryLevel.strong),
      );
    });

    test('100% → strong', () {
      expect(
        TopicMastery(topic: _topic(), correct: 3, total: 3).level,
        equals(MasteryLevel.strong),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/assessment/domain/models/topic_mastery_test.dart
```

Expected: FAIL — `TopicMastery` not defined.

- [ ] **Step 3: Create AssessmentQuestion**

Create `lib/features/assessment/domain/models/assessment_question.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.question,
    required this.topicId,
  });

  final Question question;
  final TopicId topicId;
}
```

- [ ] **Step 4: Create AssessmentSession**

Create `lib/features/assessment/domain/models/assessment_session.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_question.dart';

class AssessmentSession {
  const AssessmentSession({
    required this.examId,
    required this.questions,
    required this.answers,
  });

  final ExamId examId;
  final List<AssessmentQuestion> questions;

  /// questionId → chosen choiceId; null means unanswered
  final Map<String, String?> answers;

  AssessmentSession copyWithAnswer({
    required String questionId,
    required String chosenChoiceId,
  }) {
    return AssessmentSession(
      examId: examId,
      questions: questions,
      answers: Map.of(answers)..[questionId] = chosenChoiceId,
    );
  }
}
```

- [ ] **Step 5: Create TopicMastery**

Create `lib/features/assessment/domain/models/topic_mastery.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';

enum MasteryLevel { weak, moderate, strong }

class TopicMastery {
  const TopicMastery({
    required this.topic,
    required this.correct,
    required this.total,
  });

  final Topic topic;
  final int correct;
  final int total;

  double get accuracy => total == 0 ? 0 : correct / total;

  MasteryLevel get level {
    final pct = accuracy * 100;
    if (pct <= 40) return MasteryLevel.weak;
    if (pct <= 70) return MasteryLevel.moderate;
    return MasteryLevel.strong;
  }
}
```

- [ ] **Step 6: Create AssessmentResult**

Create `lib/features/assessment/domain/models/assessment_result.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';

class AssessmentResult {
  const AssessmentResult({
    required this.examId,
    required this.completedAt,
    required this.topicMasteries,
  });

  final ExamId examId;
  final DateTime completedAt;

  /// Sorted weakest-first (ascending accuracy).
  final List<TopicMastery> topicMasteries;

  factory AssessmentResult.fromRow(
    AssessmentResultLocalRow row,
    List<Topic> topics,
  ) {
    final raw = (jsonDecode(row.topicScoresJson) as List)
        .cast<Map<String, dynamic>>();
    final topicById = {for (final t in topics) t.id: t};
    final masteries = raw
        .where((s) => topicById.containsKey(s['topicId'] as String))
        .map(
          (s) => TopicMastery(
            topic: topicById[s['topicId'] as String]!,
            correct: s['correct'] as int,
            total: s['total'] as int,
          ),
        )
        .toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    return AssessmentResult(
      examId: row.examId,
      completedAt: row.completedAt,
      topicMasteries: masteries,
    );
  }
}
```

- [ ] **Step 7: Run TopicMastery tests**

```bash
flutter test test/features/assessment/domain/models/topic_mastery_test.dart
```

Expected: all 7 tests PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/features/assessment/domain/models/ \
        test/features/assessment/domain/models/topic_mastery_test.dart
git commit -m "feat(assessment): add domain models — session, question, topic mastery, result"
```

---

### Task 4: ContentRepository.topicsByExam + AttemptsRepository.countForExam

**Files:**
- Modify: `lib/core/storage/data/repos/content_repository.dart`
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Create: `test/core/storage/data/repos/content_repository_topics_by_exam_test.dart`
- Create: `test/core/storage/data/repos/attempts_repository_count_test.dart`

- [ ] **Step 1: Write failing tests for topicsByExam**

Create `test/core/storage/data/repos/content_repository_topics_by_exam_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    repo = ContentRepository(db);

    await db.into(db.exams).insert(ExamsCompanion.insert(
      id: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
      language: 'en',
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's1',
      examId: 'e1',
      name: 'Verbal',
      ordering: 1,
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's2',
      examId: 'e1',
      name: 'Numerical',
      ordering: 2,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't2',
      subjectId: 's2',
      name: 'Arithmetic',
      ordering: 1,
    ));
  });

  tearDown(() => db.close());

  test('topicsByExam returns all topics across all subjects', () async {
    final topics = await repo.topicsByExam('e1');
    expect(topics.map((t) => t.id).toSet(), equals({'t1', 't2'}));
  });

  test('topicsByExam returns empty list for unknown exam', () async {
    final topics = await repo.topicsByExam('unknown');
    expect(topics, isEmpty);
  });
}
```

- [ ] **Step 2: Write failing tests for countForExam**

Create `test/core/storage/data/repos/attempts_repository_count_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AttemptsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = AttemptsRepository(db);
  });

  tearDown(() => db.close());

  test('countForExam returns 0 when no attempts exist', () async {
    expect(await repo.countForExam('e1'), equals(0));
  });

  test('countForExam counts only attempts for the given exam', () async {
    final now = DateTime(2026, 1, 1);
    await repo.save(
      Attempt(id: 'a1', examId: 'e1', startedAt: now, completedAt: now, items: []),
    );
    await repo.save(
      Attempt(id: 'a2', examId: 'e1', startedAt: now, completedAt: now, items: []),
    );
    await repo.save(
      Attempt(id: 'a3', examId: 'e2', startedAt: now, completedAt: now, items: []),
    );
    expect(await repo.countForExam('e1'), equals(2));
    expect(await repo.countForExam('e2'), equals(1));
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
flutter test test/core/storage/data/repos/content_repository_topics_by_exam_test.dart \
              test/core/storage/data/repos/attempts_repository_count_test.dart
```

Expected: FAIL — `topicsByExam` and `countForExam` not defined.

- [ ] **Step 4: Add topicsByExam to ContentRepository**

In `lib/core/storage/data/repos/content_repository.dart`, add after the `topicsBySubject` method:

```dart
Future<List<Topic>> topicsByExam(ExamId examId) async {
  final subjectRows = await (_db.select(_db.subjects)
        ..where((s) => s.examId.equals(examId)))
      .get();
  final allTopics = <Topic>[];
  for (final s in subjectRows) {
    allTopics.addAll(await topicsBySubject(s.id));
  }
  return allTopics;
}
```

- [ ] **Step 5: Add countForExam to AttemptsRepository**

In `lib/core/storage/data/repos/attempts_repository.dart`, add before `rawRowById`:

```dart
Future<int> countForExam(ExamId examId) async {
  final rows = await (_db.select(_db.attemptsLocal)
        ..where((t) => t.examId.equals(examId)))
      .get();
  return rows.length;
}
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
flutter test test/core/storage/data/repos/content_repository_topics_by_exam_test.dart \
              test/core/storage/data/repos/attempts_repository_count_test.dart
```

Expected: all tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/core/storage/data/repos/content_repository.dart \
        lib/core/storage/data/repos/attempts_repository.dart \
        test/core/storage/data/repos/content_repository_topics_by_exam_test.dart \
        test/core/storage/data/repos/attempts_repository_count_test.dart
git commit -m "feat(assessment): add topicsByExam and countForExam to repositories"
```

---

### Task 5: AssessmentQuestionSelector

**Files:**
- Create: `lib/features/assessment/domain/services/assessment_question_selector.dart`
- Create: `test/features/assessment/domain/services/assessment_question_selector_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/features/assessment/domain/services/assessment_question_selector_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentRepository content;
  late ReviewStateRepository reviewRepo;
  late AssessmentQuestionSelector selector;

  Future<void> seedExam() async {
    await db.into(db.exams).insert(ExamsCompanion.insert(
      id: 'e1',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
      language: 'en',
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's1',
      examId: 'e1',
      name: 'Verbal',
      ordering: 1,
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's2',
      examId: 'e1',
      name: 'Numerical',
      ordering: 2,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't2',
      subjectId: 's2',
      name: 'Arithmetic',
      ordering: 1,
    ));
  }

  Future<void> seedQuestion(String id, String topicId) async {
    final choices = [
      {'id': '${id}_a', 'label': 'A', 'text': 'Choice A', 'isCorrect': true},
      {'id': '${id}_b', 'label': 'B', 'text': 'Choice B', 'isCorrect': false},
    ];
    await db.into(db.questions).insert(QuestionsCompanion.insert(
      id: id,
      version: 1,
      examIdsJson: jsonEncode(['e1']),
      topicId: topicId,
      language: 'en',
      stem: 'Question $id?',
      choicesJson: jsonEncode(choices),
      explanation: 'Explanation for $id',
    ));
  }

  setUp(() async {
    db = inMemoryDatabase();
    content = ContentRepository(db);
    reviewRepo = ReviewStateRepository(db);
    selector = AssessmentQuestionSelector(content, reviewRepo);
    await seedExam();
  });

  tearDown(() => db.close());

  test('selects up to 3 questions per topic when more are available', () async {
    for (var i = 1; i <= 5; i++) {
      await seedQuestion('q_t1_$i', 't1');
      await seedQuestion('q_t2_$i', 't2');
    }

    final questions = await selector.select('e1');

    final t1Count = questions.where((q) => q.topicId == 't1').length;
    final t2Count = questions.where((q) => q.topicId == 't2').length;
    expect(t1Count, lessThanOrEqualTo(3));
    expect(t2Count, lessThanOrEqualTo(3));
  });

  test('prefers unseen (newCard) questions over seen ones', () async {
    for (final tid in ['t1', 't2']) {
      await seedQuestion('seen_$tid', tid);
      await seedQuestion('new_$tid', tid);
      await reviewRepo.upsert(ReviewState(
        questionId: 'seen_$tid',
        questionVersion: 1,
        stage: ReviewStage.review,
        stability: 10,
        difficulty: 5,
        due: DateTime(2026, 12, 1),
        lastReview: DateTime(2026, 1, 1),
        reps: 1,
        lapses: 0,
        elapsedDays: 1,
        scheduledDays: 10,
      ));
    }

    final questions = await selector.select('e1');
    final ids = questions.map((q) => q.question.id).toSet();

    expect(ids, contains('new_t1'));
    expect(ids, contains('new_t2'));
  });

  test('interleaves questions so first two come from different topics', () async {
    for (var i = 1; i <= 3; i++) {
      await seedQuestion('q_t1_$i', 't1');
      await seedQuestion('q_t2_$i', 't2');
    }

    final questions = await selector.select('e1');

    expect(questions.map((q) => q.topicId), containsAll(['t1', 't2']));
    if (questions.length >= 2) {
      expect(questions[0].topicId, isNot(equals(questions[1].topicId)));
    }
  });

  test('returns empty list when exam has no questions', () async {
    final questions = await selector.select('e1');
    expect(questions, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/assessment/domain/services/assessment_question_selector_test.dart
```

Expected: FAIL — `AssessmentQuestionSelector` not defined.

- [ ] **Step 3: Implement AssessmentQuestionSelector**

Create `lib/features/assessment/domain/services/assessment_question_selector.dart`:

```dart
import 'dart:math' as math;

import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_question.dart';

class AssessmentQuestionSelector {
  AssessmentQuestionSelector(this._content, this._reviewRepo);

  final ContentRepository _content;
  final ReviewStateRepository _reviewRepo;

  Future<List<AssessmentQuestion>> select(ExamId examId) async {
    final topics = await _content.topicsByExam(examId);
    if (topics.isEmpty) return [];

    final questionsPerTopic = math.min(3, 35 ~/ topics.length);
    final buckets = <List<AssessmentQuestion>>[];

    for (final topic in topics) {
      final questions = await _content.questionsByTopic(topic.id);
      if (questions.isEmpty) continue;

      final scored = <(double, Question)>[];
      for (final q in questions) {
        final rs = await _reviewRepo.byQuestionId(q.id);
        final score = (rs == null || rs.stage == ReviewStage.newCard)
            ? 0.0
            : rs.stability;
        scored.add((score, q));
      }
      scored.sort((a, b) => a.$1.compareTo(b.$1));

      final picked = scored
          .take(questionsPerTopic)
          .map((s) => AssessmentQuestion(question: s.$2, topicId: topic.id))
          .toList();
      if (picked.isNotEmpty) buckets.add(picked);
    }

    // Round-robin interleave across topic buckets
    final result = <AssessmentQuestion>[];
    final maxLen = buckets.fold(0, (m, b) => math.max(m, b.length));
    for (var i = 0; i < maxLen; i++) {
      for (final bucket in buckets) {
        if (i < bucket.length) result.add(bucket[i]);
      }
    }
    return result;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/assessment/domain/services/assessment_question_selector_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assessment/domain/services/assessment_question_selector.dart \
        test/features/assessment/domain/services/assessment_question_selector_test.dart
git commit -m "feat(assessment): add AssessmentQuestionSelector"
```

---

### Task 6: StartAssessment use case

**Files:**
- Create: `lib/features/assessment/domain/use_cases/start_assessment.dart`
- Create: `test/features/assessment/domain/use_cases/start_assessment_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/features/assessment/domain/use_cases/start_assessment_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/use_cases/start_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

StartAssessment _makeUseCase(AppDatabase db) {
  final content = ContentRepository(db);
  final review = ReviewStateRepository(db);
  return StartAssessment(AssessmentQuestionSelector(content, review));
}

void main() {
  late AppDatabase db;
  late StartAssessment useCase;

  Future<void> seedQuestion(String id, String topicId) async {
    final choices = [
      {'id': '${id}_a', 'label': 'A', 'text': 'Option A', 'isCorrect': true},
      {'id': '${id}_b', 'label': 'B', 'text': 'Option B', 'isCorrect': false},
    ];
    await db.into(db.questions).insert(QuestionsCompanion.insert(
      id: id,
      version: 1,
      examIdsJson: jsonEncode(['e1']),
      topicId: topicId,
      language: 'en',
      stem: 'Question $id?',
      choicesJson: jsonEncode(choices),
      explanation: 'Explanation',
    ));
  }

  setUp(() async {
    db = inMemoryDatabase();
    useCase = _makeUseCase(db);

    await db.into(db.exams).insert(ExamsCompanion.insert(
      id: 'e1',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
      language: 'en',
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's1',
      examId: 'e1',
      name: 'Verbal',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    ));
    await seedQuestion('q1', 't1');
    await seedQuestion('q2', 't1');
  });

  tearDown(() => db.close());

  test('returns session with correct examId', () async {
    final session = await useCase.call('e1');
    expect(session.examId, equals('e1'));
  });

  test('all answers are null initially', () async {
    final session = await useCase.call('e1');
    expect(session.questions, isNotEmpty);
    for (final q in session.questions) {
      expect(session.answers[q.question.id], isNull);
    }
  });

  test('throws StateError when exam has no questions', () async {
    final emptyDb = inMemoryDatabase();
    addTearDown(() => emptyDb.close());
    await emptyDb.into(emptyDb.exams).insert(ExamsCompanion.insert(
      id: 'empty',
      code: 'XX',
      name: 'Empty',
      shortName: 'XX',
      language: 'en',
    ));
    await emptyDb.into(emptyDb.subjects).insert(SubjectsCompanion.insert(
      id: 's_empty',
      examId: 'empty',
      name: 'S',
      ordering: 1,
    ));
    await emptyDb.into(emptyDb.topics).insert(TopicsCompanion.insert(
      id: 't_empty',
      subjectId: 's_empty',
      name: 'T',
      ordering: 1,
    ));

    expect(
      () => _makeUseCase(emptyDb).call('empty'),
      throwsStateError,
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/assessment/domain/use_cases/start_assessment_test.dart
```

Expected: FAIL — `StartAssessment` not defined.

- [ ] **Step 3: Implement StartAssessment**

Create `lib/features/assessment/domain/use_cases/start_assessment.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_session.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';

class StartAssessment {
  StartAssessment(this._selector);

  final AssessmentQuestionSelector _selector;

  Future<AssessmentSession> call(ExamId examId) async {
    final questions = await _selector.select(examId);
    if (questions.isEmpty) {
      throw StateError(
        'No questions available for assessment of exam $examId',
      );
    }
    return AssessmentSession(
      examId: examId,
      questions: questions,
      answers: {for (final q in questions) q.question.id: null},
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/assessment/domain/use_cases/start_assessment_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assessment/domain/use_cases/start_assessment.dart \
        test/features/assessment/domain/use_cases/start_assessment_test.dart
git commit -m "feat(assessment): add StartAssessment use case"
```

---

### Task 7: CompleteAssessment use case

**Files:**
- Create: `lib/features/assessment/domain/use_cases/complete_assessment.dart`
- Create: `test/features/assessment/domain/use_cases/complete_assessment_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/features/assessment/domain/use_cases/complete_assessment_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_question.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_session.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/use_cases/complete_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late AssessmentRepository assessmentRepo;
  late ReviewStateRepository reviewRepo;
  late ContentRepository contentRepo;
  late CompleteAssessment useCase;

  // Returns (correctChoiceId, wrongChoiceId).
  Future<(String, String)> seedQuestion(String id, String topicId) async {
    final correctId = '${id}_correct';
    final wrongId = '${id}_wrong';
    final choices = [
      {'id': correctId, 'label': 'A', 'text': 'Correct', 'isCorrect': true},
      {'id': wrongId, 'label': 'B', 'text': 'Wrong', 'isCorrect': false},
    ];
    await db.into(db.questions).insert(QuestionsCompanion.insert(
      id: id,
      version: 1,
      examIdsJson: jsonEncode(['e1']),
      topicId: topicId,
      language: 'en',
      stem: 'Q $id?',
      choicesJson: jsonEncode(choices),
      explanation: '',
    ));
    return (correctId, wrongId);
  }

  setUp(() async {
    db = inMemoryDatabase();
    assessmentRepo = AssessmentRepository(db);
    reviewRepo = ReviewStateRepository(db);
    contentRepo = ContentRepository(db);
    useCase = CompleteAssessment(
      assessmentRepo: assessmentRepo,
      reviewRepo: reviewRepo,
      scheduler: const FsrsScheduler(),
      contentRepo: contentRepo,
    );

    await db.into(db.exams).insert(ExamsCompanion.insert(
      id: 'e1',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
      language: 'en',
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's1',
      examId: 'e1',
      name: 'Verbal',
      ordering: 1,
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's2',
      examId: 'e1',
      name: 'Numerical',
      ordering: 2,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't2',
      subjectId: 's2',
      name: 'Arithmetic',
      ordering: 2,
    ));
  });

  tearDown(() => db.close());

  test('saveResult is called once and result is retrievable', () async {
    final (correctId, _) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': correctId},
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));
    expect(await assessmentRepo.hasCompletedForExam('e1'), isTrue);
  });

  test('per-topic scores are correct', () async {
    final (correctId, wrongId) = await seedQuestion('q1', 't1');
    await seedQuestion('q2', 't1');
    final (correctId2, _) = await seedQuestion('q3', 't2');

    final q1 = (await contentRepo.questionsByTopic('t1')).firstWhere((q) => q.id == 'q1');
    final q2 = (await contentRepo.questionsByTopic('t1')).firstWhere((q) => q.id == 'q2');
    final q3 = (await contentRepo.questionsByTopic('t2')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [
        AssessmentQuestion(question: q1, topicId: 't1'),
        AssessmentQuestion(question: q2, topicId: 't1'),
        AssessmentQuestion(question: q3, topicId: 't2'),
      ],
      answers: {
        'q1': correctId,
        'q2': wrongId,
        'q3': correctId2,
      },
    );

    final result = await useCase.call(session: session, now: DateTime(2026, 1, 1));

    final t1 = result.topicMasteries.firstWhere((m) => m.topic.id == 't1');
    final t2 = result.topicMasteries.firstWhere((m) => m.topic.id == 't2');
    expect(t1.correct, equals(1));
    expect(t1.total, equals(2));
    expect(t2.correct, equals(1));
    expect(t2.total, equals(1));
  });

  test('topicMasteries sorted weakest-first', () async {
    final (_, wrongId) = await seedQuestion('q1', 't1');
    final (correctId2, _) = await seedQuestion('q2', 't2');

    final q1 = (await contentRepo.questionsByTopic('t1')).first;
    final q2 = (await contentRepo.questionsByTopic('t2')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [
        AssessmentQuestion(question: q1, topicId: 't1'),
        AssessmentQuestion(question: q2, topicId: 't2'),
      ],
      answers: {
        'q1': wrongId,    // t1: 0/1 = weak
        'q2': correctId2, // t2: 1/1 = strong
      },
    );

    final result = await useCase.call(session: session, now: DateTime(2026, 1, 1));

    expect(result.topicMasteries.first.topic.id, equals('t1'));
    expect(result.topicMasteries.last.topic.id, equals('t2'));
  });

  test('correct answer seeds FSRS with good rating → review stage', () async {
    final (correctId, _) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': correctId},
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));

    final rs = await reviewRepo.byQuestionId('q1');
    expect(rs, isNotNull);
    expect(rs!.reps, equals(1));
    expect(rs.stage, equals(ReviewStage.review));
  });

  test('incorrect answer seeds FSRS with again rating → learning stage', () async {
    final (_, wrongId) = await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': wrongId},
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));

    final rs = await reviewRepo.byQuestionId('q1');
    expect(rs, isNotNull);
    expect(rs!.reps, equals(1));
    expect(rs.stage, equals(ReviewStage.learning));
  });

  test('unanswered questions are skipped for FSRS', () async {
    await seedQuestion('q1', 't1');
    final q1 = (await contentRepo.questionsByTopic('t1')).first;

    final session = AssessmentSession(
      examId: 'e1',
      questions: [AssessmentQuestion(question: q1, topicId: 't1')],
      answers: {'q1': null}, // unanswered
    );

    await useCase.call(session: session, now: DateTime(2026, 1, 1));
    expect(await reviewRepo.byQuestionId('q1'), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/assessment/domain/use_cases/complete_assessment_test.dart
```

Expected: FAIL — `CompleteAssessment` not defined.

- [ ] **Step 3: Implement CompleteAssessment**

Create `lib/features/assessment/domain/use_cases/complete_assessment.dart`:

```dart
import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_session.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';

class CompleteAssessment {
  CompleteAssessment({
    required AssessmentRepository assessmentRepo,
    required ReviewStateRepository reviewRepo,
    required FsrsScheduler scheduler,
    required ContentRepository contentRepo,
  })  : _assessmentRepo = assessmentRepo,
        _reviewRepo = reviewRepo,
        _scheduler = scheduler,
        _contentRepo = contentRepo;

  final AssessmentRepository _assessmentRepo;
  final ReviewStateRepository _reviewRepo;
  final FsrsScheduler _scheduler;
  final ContentRepository _contentRepo;

  Future<AssessmentResult> call({
    required AssessmentSession session,
    required DateTime now,
  }) async {
    // Compute per-topic correct / total
    final counts = <String, ({int correct, int total})>{};
    for (final aq in session.questions) {
      final entry = counts[aq.topicId] ?? (correct: 0, total: 0);
      final chosen = session.answers[aq.question.id];
      final isCorrect = chosen != null &&
          aq.question.choices.any((c) => c.id == chosen && c.isCorrect);
      counts[aq.topicId] = (
        correct: entry.correct + (isCorrect ? 1 : 0),
        total: entry.total + 1,
      );
    }

    final scores = counts.entries
        .map(
          (e) => TopicScore(
            topicId: e.key,
            correct: e.value.correct,
            total: e.value.total,
          ),
        )
        .toList();

    await _assessmentRepo.saveResult(session.examId, now, scores);

    // Seed FSRS for every answered question
    for (final aq in session.questions) {
      final chosen = session.answers[aq.question.id];
      if (chosen == null) continue;
      final isCorrect =
          aq.question.choices.any((c) => c.id == chosen && c.isCorrect);
      final rating = isCorrect ? Rating.good : Rating.again;
      final existing = await _reviewRepo.byQuestionId(aq.question.id);
      final prev = existing ??
          ReviewState.seed(
            questionId: aq.question.id,
            questionVersion: aq.question.version,
            now: now,
          );
      await _reviewRepo.upsert(_scheduler.next(prev: prev, rating: rating, now: now));
    }

    // Hydrate result with Topic models
    final topics = await _contentRepo.topicsByExam(session.examId);
    final topicById = {for (final t in topics) t.id: t};
    final masteries = scores
        .where((s) => topicById.containsKey(s.topicId))
        .map(
          (s) => TopicMastery(
            topic: topicById[s.topicId]!,
            correct: s.correct,
            total: s.total,
          ),
        )
        .toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return AssessmentResult(
      examId: session.examId,
      completedAt: now,
      topicMasteries: masteries,
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/assessment/domain/use_cases/complete_assessment_test.dart
```

Expected: all 6 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assessment/domain/use_cases/complete_assessment.dart \
        test/features/assessment/domain/use_cases/complete_assessment_test.dart
git commit -m "feat(assessment): add CompleteAssessment use case"
```

---

### Task 8: Providers in storage.dart

**Files:**
- Modify: `lib/core/storage/storage.dart`

- [ ] **Step 1: Add imports to storage.dart**

Add to the import section of `lib/core/storage/storage.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
```

- [ ] **Step 2: Add providers at the bottom of storage.dart**

Append to `lib/core/storage/storage.dart`:

```dart
final assessmentRepositoryProvider = Provider<AssessmentRepository>(
  (ref) => AssessmentRepository(ref.watch(appDatabaseProvider)),
);

final assessmentResultProvider =
    FutureProvider.family<AssessmentResult?, ExamId>((ref, examId) async {
  final row = await ref
      .watch(assessmentRepositoryProvider)
      .resultForExam(examId);
  if (row == null) return null;
  final topics =
      await ref.watch(contentRepositoryProvider).topicsByExam(examId);
  return AssessmentResult.fromRow(row, topics);
});

final assessmentCompletedProvider =
    FutureProvider.family<bool, ExamId>((ref, examId) async {
  return ref
      .watch(assessmentRepositoryProvider)
      .hasCompletedForExam(examId);
});

final countForExamProvider =
    FutureProvider.family<int, ExamId>((ref, examId) async {
  return ref.watch(attemptsRepositoryProvider).countForExam(examId);
});
```

- [ ] **Step 3: Verify analysis passes**

```bash
flutter analyze lib/core/storage/storage.dart
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/core/storage/storage.dart
git commit -m "feat(assessment): add assessmentRepositoryProvider and assessment providers"
```

---

### Task 9: AssessmentPage

**Files:**
- Create: `lib/features/assessment/presentation/assessment_page.dart`
- Create: `test/features/assessment/presentation/assessment_page_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/features/assessment/presentation/assessment_page_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String examId) => GoRouter(
      initialLocation: '/assessment/$examId',
      routes: [
        GoRoute(
          path: '/assessment/:examId',
          builder: (_, state) =>
              AssessmentPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/assessment/:examId/results',
          builder: (_, __) => const Scaffold(body: Text('Results')),
        ),
      ],
    );

Future<AppDatabase> _seedDb() async {
  final db = inMemoryDatabase();
  await db.into(db.exams).insert(ExamsCompanion.insert(
    id: 'e1',
    code: 'CSE',
    name: 'CSE',
    shortName: 'CSE',
    language: 'en',
  ));
  await db.into(db.subjects).insert(SubjectsCompanion.insert(
    id: 's1',
    examId: 'e1',
    name: 'Verbal',
    ordering: 1,
  ));
  await db.into(db.topics).insert(TopicsCompanion.insert(
    id: 't1',
    subjectId: 's1',
    name: 'Vocabulary',
    ordering: 1,
  ));
  final choices = jsonEncode([
    {'id': 'c_a', 'label': 'A', 'text': 'Option A', 'isCorrect': true},
    {'id': 'c_b', 'label': 'B', 'text': 'Option B', 'isCorrect': false},
  ]);
  await db.into(db.questions).insert(QuestionsCompanion.insert(
    id: 'q1',
    version: 1,
    examIdsJson: jsonEncode(['e1']),
    topicId: 't1',
    language: 'en',
    stem: 'What does ephemeral mean?',
    choicesJson: choices,
    explanation: 'Short-lived.',
  ));
  return db;
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = await _seedDb();
  });

  tearDown(() => db.close());

  testWidgets('shows progress bar when assessment is running', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 1'), findsOneWidget);
  });

  testWidgets('answering last question navigates to results page',
      (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
  });

  testWidgets('back navigation shows confirm dialog', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    final NavigatorState navigator =
        tester.state(find.byType(Navigator).first);
    navigator.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Leave assessment?'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/assessment/presentation/assessment_page_test.dart
```

Expected: FAIL — `AssessmentPage` not defined.

- [ ] **Step 3: Implement AssessmentPage**

Create `lib/features/assessment/presentation/assessment_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_session.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/services/assessment_question_selector.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/use_cases/complete_assessment.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/use_cases/start_assessment.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/question_card.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/quiz_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _startAssessmentProvider = Provider<StartAssessment>(
  (ref) => StartAssessment(
    AssessmentQuestionSelector(
      ref.watch(contentRepositoryProvider),
      ref.watch(reviewStateRepositoryProvider),
    ),
  ),
);

final _completeAssessmentProvider = Provider<CompleteAssessment>(
  (ref) => CompleteAssessment(
    assessmentRepo: AssessmentRepository(ref.watch(appDatabaseProvider)),
    reviewRepo: ref.watch(reviewStateRepositoryProvider),
    scheduler: const FsrsScheduler(),
    contentRepo: ref.watch(contentRepositoryProvider),
  ),
);

class AssessmentPage extends ConsumerStatefulWidget {
  const AssessmentPage({required this.examId, super.key});

  final ExamId examId;

  @override
  ConsumerState<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends ConsumerState<AssessmentPage> {
  AssessmentSession? _session;
  int _currentIndex = 0;
  String? _errorMessage;
  bool _completing = false;

  // When completing fails, we keep the session alive so the user can retry
  // without re-answering. _pendingCompleteSession holds the session that failed.
  AssessmentSession? _pendingCompleteSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _session = null;
      _errorMessage = null;
      _pendingCompleteSession = null;
    });
    try {
      final session =
          await ref.read(_startAssessmentProvider).call(widget.examId);
      if (!mounted) return;
      setState(() => _session = session);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _complete(AssessmentSession session) async {
    setState(() => _completing = true);
    try {
      await ref.read(_completeAssessmentProvider).call(
            session: session,
            now: DateTime.now(),
          );
      if (!mounted) return;
      context.go('/assessment/${widget.examId}/results');
    } catch (e) {
      if (!mounted) return;
      // Keep session alive so user can retry without re-answering
      setState(() {
        _completing = false;
        _pendingCompleteSession = session;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onAnswer(String chosenChoiceId) async {
    final session = _session;
    if (session == null || _completing) return;

    final aq = session.questions[_currentIndex];
    final updated = session.copyWithAnswer(
      questionId: aq.question.id,
      chosenChoiceId: chosenChoiceId,
    );

    if (_currentIndex < session.questions.length - 1) {
      setState(() {
        _session = updated;
        _currentIndex++;
      });
      return;
    }

    setState(() => _session = updated);
    await _complete(updated);
  }

  Future<bool> _confirmLeave() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave assessment?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    Widget body;
    if (_errorMessage != null) {
      body = ErrorBanner(
        variant: ErrorBannerVariant.error,
        message: _errorMessage!,
        actionLabel: 'Retry',
        // If we have a pending session (complete failed), retry complete.
        // Otherwise retry load.
        onAction: _pendingCompleteSession != null
            ? () => _complete(_pendingCompleteSession!)
            : _load,
      );
    } else if (session == null || _completing) {
      body = const SkeletonCard();
    } else {
      body = Column(
        children: [
          QuizProgressBar(
            current: _currentIndex + 1,
            total: session.questions.length,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: QuestionCard(
                question: session.questions[_currentIndex].question,
                onAnswer: _onAnswer,
              ),
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmLeave();
        if (leave && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Assessment')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: body,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/assessment/presentation/assessment_page_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assessment/presentation/assessment_page.dart \
        test/features/assessment/presentation/assessment_page_test.dart
git commit -m "feat(assessment): add AssessmentPage"
```

---

### Task 10: AssessmentResultsPage

**Files:**
- Create: `lib/features/assessment/presentation/assessment_results_page.dart`
- Create: `test/features/assessment/presentation/assessment_results_page_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/features/assessment/presentation/assessment_results_page_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String examId) => GoRouter(
      initialLocation: '/assessment/$examId/results',
      routes: [
        GoRoute(
          path: '/assessment/:examId/results',
          builder: (_, state) =>
              AssessmentResultsPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/learn/topic/:topicId',
          builder: (_, __) => const Scaffold(body: Text('Lessons')),
        ),
        GoRoute(
          path: '/quiz/quick/:examId',
          builder: (_, __) => const Scaffold(body: Text('Quiz')),
        ),
      ],
    );

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();

    await db.into(db.exams).insert(ExamsCompanion.insert(
      id: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
      language: 'en',
    ));
    await db.into(db.subjects).insert(SubjectsCompanion.insert(
      id: 's1',
      examId: 'e1',
      name: 'Verbal',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't1',
      subjectId: 's1',
      name: 'Vocabulary',
      ordering: 1,
    ));
    await db.into(db.topics).insert(TopicsCompanion.insert(
      id: 't2',
      subjectId: 's1',
      name: 'Reading Comprehension',
      ordering: 2,
    ));

    // t1: 0/3 = 0% (weak), t2: 3/3 = 100% (strong)
    await AssessmentRepository(db).saveResult('e1', DateTime(2026, 1, 1), [
      const TopicScore(topicId: 't1', correct: 0, total: 3),
      const TopicScore(topicId: 't2', correct: 3, total: 3),
    ]);
  });

  tearDown(() => db.close());

  testWidgets('shows topic bars sorted weakest-first', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Vocabulary'), findsWidgets);
    expect(find.text('Reading Comprehension'), findsWidgets);

    final vocabY =
        tester.getTopLeft(find.text('Vocabulary').first).dy;
    final readingY =
        tester.getTopLeft(find.text('Reading Comprehension').first).dy;
    expect(vocabY, lessThan(readingY));
  });

  testWidgets('weak topic shows Start here badge', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Start here'), findsOneWidget);
  });

  testWidgets('Study and Quiz buttons present for weak topic', (tester) async {
    await tester.pumpAppWithRouter(
      _buildRouter('e1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Study →'), findsWidgets);
    expect(find.text('Quiz →'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/assessment/presentation/assessment_results_page_test.dart
```

Expected: FAIL — `AssessmentResultsPage` not defined.

- [ ] **Step 3: Implement AssessmentResultsPage**

Create `lib/features/assessment/presentation/assessment_results_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AssessmentResultsPage extends ConsumerWidget {
  const AssessmentResultsPage({required this.examId, super.key});

  final ExamId examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(assessmentResultProvider(examId));

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: asyncResult.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(assessmentResultProvider(examId)),
          ),
        ),
        data: (result) {
          if (result == null) {
            return const Center(child: Text('No assessment found.'));
          }
          return _ResultsBody(result: result, examId: examId);
        },
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.result, required this.examId});

  final AssessmentResult result;
  final ExamId examId;

  List<TopicMastery> get _weakTopics {
    final weak = result.topicMasteries
        .where((m) => m.level == MasteryLevel.weak)
        .toList();
    if (weak.isNotEmpty) return weak.take(3).toList();
    return result.topicMasteries.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final weak = _weakTopics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Topic Breakdown', style: textStyles.headlineSmall),
        const SizedBox(height: 12),
        for (final mastery in result.topicMasteries) ...[
          _TopicBar(mastery: mastery),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 24),
        Text('Focus Areas', style: textStyles.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Your recommendations update as you study',
          style:
              textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < weak.length; i++) ...[
          _TopicCta(mastery: weak[i], examId: examId, isFirst: i == 0),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TopicBar extends StatelessWidget {
  const _TopicBar({required this.mastery});

  final TopicMastery mastery;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    final Color barColor = switch (mastery.level) {
      MasteryLevel.weak => colors.error,
      MasteryLevel.moderate => colors.warning,
      MasteryLevel.strong => colors.success,
    };
    final pct = (mastery.accuracy * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                mastery.topic.name,
                style: textStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$pct%',
              style: textStyles.bodySmall
                  .copyWith(color: colors.onSurfaceMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: mastery.accuracy,
            backgroundColor: colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}

class _TopicCta extends StatelessWidget {
  const _TopicCta({
    required this.mastery,
    required this.examId,
    required this.isFirst,
  });

  final TopicMastery mastery;
  final ExamId examId;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mastery.topic.name,
                  style: textStyles.headlineSmall,
                ),
              ),
              if (isFirst)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Start here',
                    style: textStyles.labelSmall
                        .copyWith(color: colors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Study →',
                  onPressed: () => context.push(
                    '/learn/topic/${mastery.topic.id}?examId=$examId',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Quiz →',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go('/quiz/quick/$examId'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/assessment/presentation/assessment_results_page_test.dart
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assessment/presentation/assessment_results_page.dart \
        test/features/assessment/presentation/assessment_results_page_test.dart
git commit -m "feat(assessment): add AssessmentResultsPage with topic bars and study CTAs"
```

---

### Task 11: Assessment nudge on QuizResultsPage

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_results_page.dart`
- Create: `test/features/quiz/presentation/quiz_results_nudge_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/features/quiz/presentation/quiz_results_nudge_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_results_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

GoRouter _buildRouter(String attemptId) => GoRouter(
      initialLocation: '/quiz/results/$attemptId',
      routes: [
        GoRoute(
          path: '/quiz/results/:attemptId',
          builder: (_, state) =>
              QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
        ),
        GoRoute(
          path: '/assessment/:examId',
          builder: (_, __) => const Scaffold(body: Text('Assessment')),
        ),
      ],
    );

// Seeds `count` attempts for exam 'e1', plus a specific attempt with the given id.
Future<void> _seedAttempts(
  AppDatabase db, {
  required String id,
  required int count,
}) async {
  final now = DateTime(2026, 1, 1);
  for (var i = 0; i < count; i++) {
    await db.into(db.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: '${id}_bg_$i',
            examId: 'e1',
            startedAt: now,
            completedAt: Value(now),
            itemsJson: jsonEncode([]),
          ),
        );
  }
  // The result page loads by this specific attemptId
  await db.into(db.attemptsLocal).insertOnConflictUpdate(
        AttemptsLocalCompanion.insert(
          id: id,
          examId: 'e1',
          startedAt: now,
          completedAt: Value(now),
          itemsJson: jsonEncode([]),
        ),
      );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() => db.close());

  testWidgets(
      'shows bottom sheet nudge after first attempt with no assessment',
      (tester) async {
    await _seedAttempts(db, id: 'a1', count: 1);

    await tester.pumpAppWithRouter(
      _buildRouter('a1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Get your personalized study plan'),
      findsOneWidget,
    );
  });

  testWidgets('does not show nudge when assessment already completed',
      (tester) async {
    await _seedAttempts(db, id: 'a1', count: 1);
    await AssessmentRepository(db)
        .saveResult('e1', DateTime(2026, 1, 1), []);

    await tester.pumpAppWithRouter(
      _buildRouter('a1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Get your personalized study plan'),
      findsNothing,
    );
  });

  testWidgets('shows bottom sheet nudge after third attempt', (tester) async {
    await _seedAttempts(db, id: 'a3', count: 3);

    await tester.pumpAppWithRouter(
      _buildRouter('a3'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining("You've done 3 quizzes"), findsOneWidget);
  });

  testWidgets('shows persistent banner after 5+ attempts', (tester) async {
    await _seedAttempts(db, id: 'a5', count: 5);

    await tester.pumpAppWithRouter(
      _buildRouter('a5'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Your study plan is waiting. Take the assessment →'),
      findsOneWidget,
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/quiz/presentation/quiz_results_nudge_test.dart
```

Expected: FAIL — nudge UI not present in `QuizResultsPage`.

- [ ] **Step 3: Modify QuizResultsPage**

Replace `lib/features/quiz/presentation/quiz_results_page.dart` with:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final attemptByIdProvider =
    FutureProvider.family<Attempt?, String>((ref, id) async {
  return ref.watch(attemptsRepositoryProvider).byId(id);
});

class QuizResultsPage extends ConsumerWidget {
  const QuizResultsPage({required this.attemptId, super.key});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAttempt = ref.watch(attemptByIdProvider(attemptId));

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: asyncAttempt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (attempt) {
          if (attempt == null) {
            return Center(
              child: EmptyState(
                illustration: '📭',
                headline: 'Attempt not found',
                body: 'We could not locate the quiz attempt.',
                ctaLabel: 'Go back',
                onCta: () => Navigator.of(context).maybePop(),
              ),
            );
          }
          return _ResultsBody(attempt: attempt);
        },
      ),
    );
  }
}

class _ResultsBody extends ConsumerStatefulWidget {
  const _ResultsBody({required this.attempt});

  final Attempt attempt;

  @override
  ConsumerState<_ResultsBody> createState() => _ResultsBodyState();
}

class _ResultsBodyState extends ConsumerState<_ResultsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowNudge());
  }

  Future<void> _maybeShowNudge() async {
    if (!mounted) return;
    final examId = widget.attempt.examId;
    final isDone =
        await ref.read(assessmentCompletedProvider(examId).future);
    if (isDone || !mounted) return;
    final count = await ref.read(countForExamProvider(examId).future);
    if (!mounted) return;

    if (count == 1) {
      await _showNudgeSheet(
        'Get your personalized study plan — see exactly where to focus for this exam.',
      );
    } else if (count == 3) {
      await _showNudgeSheet(
        "You've done 3 quizzes — find out which topics to prioritize.",
      );
    }
  }

  Future<void> _showNudgeSheet(String message) async {
    if (!mounted) return;
    final examId = widget.attempt.examId;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: context.textStyles.bodyMedium),
              const SizedBox(height: 24),
              AppButton(
                label: 'Start assessment',
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  if (context.mounted) context.go('/assessment/$examId');
                },
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Maybe later',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final attempt = widget.attempt;
    final examId = attempt.examId;
    final (correct, total) = attempt.score;
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();

    final isDone = ref.watch(assessmentCompletedProvider(examId)).valueOrNull ?? true;
    final count = ref.watch(countForExamProvider(examId)).valueOrNull ?? 0;
    final showBanner = !isDone && count >= 5;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showBanner) ...[
          GestureDetector(
            onTap: () => context.go('/assessment/$examId'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your study plan is waiting. Take the assessment →',
                style: textStyles.bodyMedium.copyWith(color: colors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        AppCard(
          variant: AppCardVariant.accent,
          child: Column(
            children: [
              Text(
                '$correct / $total ($percent%)',
                style:
                    textStyles.displaySmall.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Score',
                style: textStyles.bodyMedium
                    .copyWith(color: colors.onSurfaceMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...attempt.items.map((item) => _ItemRow(item: item)),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final AttemptItem item;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final isCorrect = item.isCorrect;
    final seconds = (item.responseMs / 1000).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.questionId,
                style: textStyles.bodyMedium.copyWith(color: colors.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${seconds}s',
              style:
                  textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run nudge tests**

```bash
flutter test test/features/quiz/presentation/quiz_results_nudge_test.dart
```

Expected: all 4 tests PASS.

- [ ] **Step 5: Run full quiz test suite to confirm no regression**

```bash
flutter test test/features/quiz/
```

Expected: all tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/quiz/presentation/quiz_results_page.dart \
        test/features/quiz/presentation/quiz_results_nudge_test.dart
git commit -m "feat(assessment): add progressive nudge to QuizResultsPage"
```

---

### Task 12: Router + barrel

**Files:**
- Create: `lib/features/assessment/assessment.dart`
- Modify: `lib/app/router.dart`

- [ ] **Step 1: Create the assessment barrel**

Create `lib/features/assessment/assessment.dart`:

```dart
export 'domain/models/assessment_question.dart';
export 'domain/models/assessment_result.dart';
export 'domain/models/assessment_session.dart';
export 'domain/models/topic_mastery.dart';
export 'domain/services/assessment_question_selector.dart';
export 'domain/use_cases/complete_assessment.dart';
export 'domain/use_cases/start_assessment.dart';
export 'presentation/assessment_page.dart';
export 'presentation/assessment_results_page.dart';
```

- [ ] **Step 2: Add imports and routes to router.dart**

Add to the imports in `lib/app/router.dart`:

```dart
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_page.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_results_page.dart';
```

Add assessment routes inside the `GoRouter` routes list, after the `/quiz` GoRoute block and before `/lesson/:lessonId`:

```dart
GoRoute(
  path: '/assessment/:examId',
  builder: (_, state) =>
      AssessmentPage(examId: state.pathParameters['examId']!),
  routes: [
    GoRoute(
      path: 'results',
      builder: (_, state) =>
          AssessmentResultsPage(examId: state.pathParameters['examId']!),
    ),
  ],
),
```

- [ ] **Step 3: Run the full test suite**

```bash
flutter test
```

Expected: all tests PASS.

- [ ] **Step 4: Run analysis**

```bash
flutter analyze
```

Expected: no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assessment/assessment.dart \
        lib/app/router.dart
git commit -m "feat(assessment): wire up router and assessment barrel export"
```
