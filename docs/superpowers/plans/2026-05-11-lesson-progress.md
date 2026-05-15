# Lesson Progress Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Track per-lesson read state locally and surface it as checkmarks on lesson cards, a "Mark as read" button on the lesson detail page, and a one-time quiz nudge bottom sheet.

**Architecture:** Two new Drift tables (`LessonProgressLocal`, `QuizNudgeDismissedLocal`) with their own repositories and Riverpod providers following the existing three-layer pattern. Schema bumps from version 1 to 2 with an `onUpgrade` migration. Three existing widgets become `ConsumerWidget`s to watch the new providers.

**Tech Stack:** Flutter, Drift (drift/native), Riverpod (flutter_riverpod), mocktail, flutter_test

---

## File Map

**New files:**
```
lib/core/storage/data/tables/lesson_progress_local_table.dart
lib/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart
lib/core/storage/data/repos/lesson_progress_repository.dart
lib/core/storage/data/repos/quiz_nudge_repository.dart
lib/features/lesson/domain/use_cases/mark_lesson_read.dart
lib/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart

test/core/storage/data/repos/lesson_progress_repository_test.dart
test/core/storage/data/repos/quiz_nudge_repository_test.dart
test/features/lesson/domain/use_cases/mark_lesson_read_test.dart
test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart
test/features/lesson/presentation/lesson_page_progress_test.dart
test/features/lesson/presentation/lesson_list_progress_test.dart
test/features/quiz/presentation/quiz_tab_nudge_test.dart
```

**Modified files:**
```
lib/core/storage/data/app_database.dart          Add 2 tables, bump schemaVersion to 2
lib/core/storage/storage.dart                    Add 2 repo providers + 4 FutureProviders
lib/features/lesson/presentation/lesson_page.dart        _LessonBody → ConsumerWidget, mark-as-read button
lib/features/lesson/presentation/lesson_list_page.dart   _LessonCard → ConsumerWidget, checkmark icon
lib/features/quiz/presentation/quiz_tab_home.dart        _ExamCard → ConsumerWidget, nudge bottom sheet
lib/features/lesson/lesson.dart                          Export 2 new use cases
```

---

## Task 1: Drift tables and schema migration

**Files:**
- Create: `lib/core/storage/data/tables/lesson_progress_local_table.dart`
- Create: `lib/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`

- [ ] **Step 1: Create `LessonProgressLocal` table**

Create `lib/core/storage/data/tables/lesson_progress_local_table.dart`:

```dart
// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/lessons_table.dart';
import 'package:drift/drift.dart';

@DataClassName('LessonProgressLocalRow')
class LessonProgressLocal extends Table {
  TextColumn get lessonId => text().references(Lessons, #id)();
  DateTimeColumn get readAt => dateTime()();
  TextColumn get syncState =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {lessonId};
}
```

- [ ] **Step 2: Create `QuizNudgeDismissedLocal` table**

Create `lib/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart`:

```dart
// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('QuizNudgeDismissedLocalRow')
class QuizNudgeDismissedLocal extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  DateTimeColumn get dismissedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 3: Register tables and bump schema version**

Replace the full contents of `lib/core/storage/data/app_database.dart`:

```dart
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(lessonProgressLocal);
            await m.createTable(quizNudgeDismissedLocal);
          }
        },
      );
}
```

- [ ] **Step 4: Regenerate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: exits 0, `app_database.g.dart` updated with `lessonProgressLocal` and `quizNudgeDismissedLocal` accessors and companion classes `LessonProgressLocalCompanion` and `QuizNudgeDismissedLocalCompanion`.

- [ ] **Step 5: Verify compilation**

Run: `flutter analyze lib/core/storage/data/`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/core/storage/data/tables/lesson_progress_local_table.dart \
        lib/core/storage/data/tables/quiz_nudge_dismissed_local_table.dart \
        lib/core/storage/data/app_database.dart \
        lib/core/storage/data/app_database.g.dart
git commit -m "feat(progress): add LessonProgressLocal and QuizNudgeDismissedLocal tables, bump schema to v2"
```

---

## Task 2: `LessonProgressRepository` (TDD)

**Files:**
- Create: `lib/core/storage/data/repos/lesson_progress_repository.dart`
- Create: `test/core/storage/data/repos/lesson_progress_repository_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/storage/data/repos/lesson_progress_repository_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late LessonProgressRepository repo;

  setUp(() async {
    db = inMemoryDatabase();
    repo = LessonProgressRepository(db);

    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Lesson 1',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l2',
            topicId: 't1',
            title: 'Lesson 2',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  test('isRead returns false before markRead', () async {
    expect(await repo.isRead('l1'), isFalse);
  });

  test('isRead returns true after markRead', () async {
    await repo.markRead('l1');
    expect(await repo.isRead('l1'), isTrue);
  });

  test('markRead is idempotent', () async {
    await repo.markRead('l1');
    await repo.markRead('l1');
    final rows = await db.select(db.lessonProgressLocal).get();
    expect(rows, hasLength(1));
  });

  test('readLessonIds returns empty set before any reads', () async {
    expect(await repo.readLessonIds(), isEmpty);
  });

  test('readLessonIds returns all read lesson IDs', () async {
    await repo.markRead('l1');
    await repo.markRead('l2');
    expect(await repo.readLessonIds(), containsAll(['l1', 'l2']));
  });

  test('readCountForTopic returns 0 when none read', () async {
    expect(await repo.readCountForTopic('t1'), equals(0));
  });

  test('readCountForTopic returns correct count when some read', () async {
    await repo.markRead('l1');
    expect(await repo.readCountForTopic('t1'), equals(1));
    await repo.markRead('l2');
    expect(await repo.readCountForTopic('t1'), equals(2));
  });

  test('hasAnyRead returns false on empty DB', () async {
    expect(await repo.hasAnyRead(), isFalse);
  });

  test('hasAnyRead returns true after any markRead', () async {
    await repo.markRead('l1');
    expect(await repo.hasAnyRead(), isTrue);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/storage/data/repos/lesson_progress_repository_test.dart -v`
Expected: FAIL — `LessonProgressRepository` not found.

- [ ] **Step 3: Implement `LessonProgressRepository`**

Create `lib/core/storage/data/repos/lesson_progress_repository.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:drift/drift.dart';

class LessonProgressRepository {
  LessonProgressRepository(this._db);

  final AppDatabase _db;

  Future<void> markRead(LessonId lessonId) async {
    await _db.into(_db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion.insert(
            lessonId: lessonId,
            readAt: DateTime.now(),
          ),
        );
  }

  Future<bool> isRead(LessonId lessonId) async {
    final row = await (_db.select(_db.lessonProgressLocal)
          ..where((p) => p.lessonId.equals(lessonId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<LessonId>> readLessonIds() async {
    final rows = await _db.select(_db.lessonProgressLocal).get();
    return rows.map((r) => r.lessonId).toSet();
  }

  Future<int> readCountForTopic(TopicId topicId) async {
    final lessonIds = await (_db.select(_db.lessons)
          ..where((l) => l.topicId.equals(topicId)))
        .map((r) => r.id)
        .get();
    if (lessonIds.isEmpty) return 0;
    final readRows = await (_db.select(_db.lessonProgressLocal)
          ..where((p) => p.lessonId.isIn(lessonIds)))
        .get();
    return readRows.length;
  }

  Future<bool> hasAnyRead() async {
    final row =
        await (_db.select(_db.lessonProgressLocal)..limit(1)).getSingleOrNull();
    return row != null;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/storage/data/repos/lesson_progress_repository_test.dart -v`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/repos/lesson_progress_repository.dart \
        test/core/storage/data/repos/lesson_progress_repository_test.dart
git commit -m "feat(progress): add LessonProgressRepository"
```

---

## Task 3: `QuizNudgeRepository` (TDD)

**Files:**
- Create: `lib/core/storage/data/repos/quiz_nudge_repository.dart`
- Create: `test/core/storage/data/repos/quiz_nudge_repository_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/core/storage/data/repos/quiz_nudge_repository_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/quiz_nudge_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late QuizNudgeRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = QuizNudgeRepository(db);
  });

  tearDown(() => db.close());

  test('hasDismissed returns false before any dismissal', () async {
    expect(await repo.hasDismissed(), isFalse);
  });

  test('hasDismissed returns true after markDismissed', () async {
    await repo.markDismissed();
    expect(await repo.hasDismissed(), isTrue);
  });

  test('markDismissed is idempotent', () async {
    await repo.markDismissed();
    await repo.markDismissed();
    final rows = await db.select(db.quizNudgeDismissedLocal).get();
    expect(rows, hasLength(1));
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/storage/data/repos/quiz_nudge_repository_test.dart -v`
Expected: FAIL — `QuizNudgeRepository` not found.

- [ ] **Step 3: Implement `QuizNudgeRepository`**

Create `lib/core/storage/data/repos/quiz_nudge_repository.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';

class QuizNudgeRepository {
  QuizNudgeRepository(this._db);

  final AppDatabase _db;

  Future<bool> hasDismissed() async {
    final row = await (_db.select(_db.quizNudgeDismissedLocal)
          ..where((n) => n.id.equals(1)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> markDismissed() async {
    await _db.into(_db.quizNudgeDismissedLocal).insertOnConflictUpdate(
          QuizNudgeDismissedLocalCompanion.insert(
            id: const Value(1),
            dismissedAt: DateTime.now(),
          ),
        );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/storage/data/repos/quiz_nudge_repository_test.dart -v`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/data/repos/quiz_nudge_repository.dart \
        test/core/storage/data/repos/quiz_nudge_repository_test.dart
git commit -m "feat(progress): add QuizNudgeRepository"
```

---

## Task 4: Providers in `storage.dart`

**Files:**
- Modify: `lib/core/storage/storage.dart`

- [ ] **Step 1: Add imports and providers**

In `lib/core/storage/storage.dart`, add these two imports after the existing repo imports:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/quiz_nudge_repository.dart';
```

Then append the following at the bottom of the file (after the existing `topicLessonsProvider`):

```dart
final lessonProgressRepositoryProvider = Provider<LessonProgressRepository>(
  (ref) => LessonProgressRepository(ref.watch(appDatabaseProvider)),
);

final quizNudgeRepositoryProvider = Provider<QuizNudgeRepository>(
  (ref) => QuizNudgeRepository(ref.watch(appDatabaseProvider)),
);

final isLessonReadProvider =
    FutureProvider.family<bool, LessonId>((ref, lessonId) async {
  return ref.watch(lessonProgressRepositoryProvider).isRead(lessonId);
});

final readCountForTopicProvider =
    FutureProvider.family<int, TopicId>((ref, topicId) async {
  return ref.watch(lessonProgressRepositoryProvider).readCountForTopic(topicId);
});

final anyLessonReadProvider = FutureProvider<bool>((ref) async {
  return ref.watch(lessonProgressRepositoryProvider).hasAnyRead();
});

final quizNudgeDismissedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(quizNudgeRepositoryProvider).hasDismissed();
});
```

- [ ] **Step 2: Verify compilation**

Run: `flutter analyze lib/core/storage/storage.dart`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/storage/storage.dart
git commit -m "feat(progress): add lesson progress and quiz nudge providers to storage barrel"
```

---

## Task 5: `MarkLessonRead` use case (TDD)

**Files:**
- Create: `lib/features/lesson/domain/use_cases/mark_lesson_read.dart`
- Create: `test/features/lesson/domain/use_cases/mark_lesson_read_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/features/lesson/domain/use_cases/mark_lesson_read_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/mark_lesson_read.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProgress extends Mock implements LessonProgressRepository {}

void main() {
  late _MockProgress progress;
  late MarkLessonRead useCase;

  setUp(() {
    progress = _MockProgress();
    useCase = MarkLessonRead(progress);
    when(() => progress.markRead(any())).thenAnswer((_) async {});
  });

  test('calls markRead with the correct lesson ID', () async {
    await useCase('l1');
    verify(() => progress.markRead('l1')).called(1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/lesson/domain/use_cases/mark_lesson_read_test.dart -v`
Expected: FAIL — `MarkLessonRead` not found.

- [ ] **Step 3: Implement `MarkLessonRead`**

Create `lib/features/lesson/domain/use_cases/mark_lesson_read.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';

class MarkLessonRead {
  MarkLessonRead(this._progress);

  final LessonProgressRepository _progress;

  Future<void> call(LessonId lessonId) => _progress.markRead(lessonId);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/lesson/domain/use_cases/mark_lesson_read_test.dart -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/domain/use_cases/mark_lesson_read.dart \
        test/features/lesson/domain/use_cases/mark_lesson_read_test.dart
git commit -m "feat(progress): add MarkLessonRead use case"
```

---

## Task 6: `DismissQuizNudge` use case (TDD)

**Files:**
- Create: `lib/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart`
- Create: `test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/quiz_nudge_repository.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNudge extends Mock implements QuizNudgeRepository {}

void main() {
  late _MockNudge nudge;
  late DismissQuizNudge useCase;

  setUp(() {
    nudge = _MockNudge();
    useCase = DismissQuizNudge(nudge);
    when(() => nudge.markDismissed()).thenAnswer((_) async {});
  });

  test('calls markDismissed on the repository', () async {
    await useCase();
    verify(() => nudge.markDismissed()).called(1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart -v`
Expected: FAIL — `DismissQuizNudge` not found.

- [ ] **Step 3: Implement `DismissQuizNudge`**

Create `lib/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/quiz_nudge_repository.dart';

class DismissQuizNudge {
  DismissQuizNudge(this._nudge);

  final QuizNudgeRepository _nudge;

  Future<void> call() => _nudge.markDismissed();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart -v`
Expected: PASS.

- [ ] **Step 5: Update barrel and commit**

In `lib/features/lesson/lesson.dart`, add two exports:

```dart
export 'domain/use_cases/dismiss_quiz_nudge.dart';
export 'domain/use_cases/get_lesson.dart';
export 'domain/use_cases/get_topic_lessons.dart';
export 'domain/use_cases/mark_lesson_read.dart';
export 'presentation/learn_tab_home.dart';
export 'presentation/lesson_list_page.dart';
export 'presentation/lesson_page.dart';
```

```bash
git add lib/features/lesson/domain/use_cases/dismiss_quiz_nudge.dart \
        test/features/lesson/domain/use_cases/dismiss_quiz_nudge_test.dart \
        lib/features/lesson/lesson.dart
git commit -m "feat(progress): add DismissQuizNudge use case"
```

---

## Task 7: `LessonPage` mark-as-read button (TDD)

**Files:**
- Modify: `lib/features/lesson/presentation/lesson_page.dart`
- Create: `test/features/lesson/presentation/lesson_page_progress_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/features/lesson/presentation/lesson_page_progress_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  Future<void> seedLesson(AppDatabase db) async {
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Vocabulary Basics',
            summary: 'Core vocab',
            bodyJson: jsonEncode([
              {
                '_type': 'block',
                'style': 'normal',
                'children': [
                  {'_type': 'span', 'text': 'Study hard.', 'marks': []}
                ]
              }
            ]),
            estimatedMinutes: 5,
          ),
        );
  }

  setUp(() async {
    db = inMemoryDatabase();
    await seedLesson(db);
  });

  tearDown(() => db.close());

  testWidgets('shows Mark as read button when lesson is unread', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark as read'), findsOneWidget);
    expect(find.text('Lesson complete ✓'), findsNothing);
  });

  testWidgets('tapping Mark as read shows Lesson complete', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as read'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson complete ✓'), findsOneWidget);
    expect(find.text('Mark as read'), findsNothing);
  });

  testWidgets('shows Lesson complete on open when already read', (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const LessonPage(lessonId: 'l1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Lesson complete ✓'), findsOneWidget);
    expect(find.text('Mark as read'), findsNothing);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/lesson/presentation/lesson_page_progress_test.dart -v`
Expected: FAIL — `Mark as read` button not found.

- [ ] **Step 3: Update `LessonPage`**

Replace the full contents of `lib/features/lesson/presentation/lesson_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LessonPage extends ConsumerWidget {
  const LessonPage({required this.lessonId, this.examId, super.key});

  final LessonId lessonId;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLesson = ref.watch(lessonByIdProvider(lessonId));

    return Scaffold(
      appBar: AppBar(),
      body: asyncLesson.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(lessonByIdProvider(lessonId)),
          ),
        ),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson not found.'));
          }
          return _LessonBody(lesson: lesson, examId: examId);
        },
      ),
    );
  }
}

class _LessonBody extends ConsumerWidget {
  const _LessonBody({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final asyncIsRead = ref.watch(isLessonReadProvider(lesson.id));
    final isRead = asyncIsRead.valueOrNull ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.title, style: textStyles.displaySmall),
          const SizedBox(height: 8),
          PortableTextRenderer(blocks: lesson.bodyJson),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: colors.onSurfaceMuted),
              const SizedBox(width: 4),
              Text(
                '${lesson.estimatedMinutes} min read',
                style:
                    textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isRead)
            AppButton(
              label: 'Lesson complete ✓',
              variant: AppButtonVariant.secondary,
              onPressed: null,
            )
          else
            AppButton(
              label: 'Mark as read',
              onPressed: () async {
                await ref
                    .read(lessonProgressRepositoryProvider)
                    .markRead(lesson.id);
                ref.invalidate(isLessonReadProvider(lesson.id));
                ref.invalidate(anyLessonReadProvider);
              },
            ),
          if (examId != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: 'Quiz this topic',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/quiz/quick/$examId'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 28, width: 240),
          SizedBox(height: 16),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 8),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 8),
          SkeletonBox(height: 14, width: 180),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/lesson/presentation/lesson_page_progress_test.dart -v`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/presentation/lesson_page.dart \
        test/features/lesson/presentation/lesson_page_progress_test.dart
git commit -m "feat(progress): add mark-as-read button to LessonPage"
```

---

## Task 8: `LessonListPage` read checkmarks (TDD)

**Files:**
- Modify: `lib/features/lesson/presentation/lesson_list_page.dart`
- Create: `test/features/lesson/presentation/lesson_list_progress_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/features/lesson/presentation/lesson_list_progress_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/lesson_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'CSE',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Synonyms',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l2',
            topicId: 't1',
            title: 'Antonyms',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows no checkmarks when no lessons are read', (tester) async {
    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('shows checkmark only on read lesson card', (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const LessonListPage(topicId: 't1'),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/lesson/presentation/lesson_list_progress_test.dart -v`
Expected: FAIL — `Icons.check_circle` not found.

- [ ] **Step 3: Update `_LessonCard` in `lesson_list_page.dart`**

In `lib/features/lesson/presentation/lesson_list_page.dart`, change `_LessonCard` from `StatelessWidget` to `ConsumerWidget` and add the checkmark. Replace the entire `_LessonCard` class:

```dart
class _LessonCard extends ConsumerWidget {
  const _LessonCard({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final examParam = examId != null ? '?examId=$examId' : '';
    final isRead = ref.watch(isLessonReadProvider(lesson.id)).valueOrNull ?? false;

    return GestureDetector(
      onTap: () => context.push('/lesson/${lesson.id}$examParam'),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: textStyles.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    lesson.summary,
                    style: textStyles.bodySmall
                        .copyWith(color: colors.onSurfaceMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lesson.estimatedMinutes} min read',
                    style: textStyles.labelSmall
                        .copyWith(color: colors.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            if (isRead) ...[
              const SizedBox(width: 12),
              Icon(Icons.check_circle, color: colors.success),
            ],
          ],
        ),
      ),
    );
  }
}
```

Also add `isLessonReadProvider` to the imports at the top of `lesson_list_page.dart` — it is already imported transitively via `storage.dart`, which is already imported. No additional import needed.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/lesson/presentation/lesson_list_progress_test.dart -v`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/lesson/presentation/lesson_list_page.dart \
        test/features/lesson/presentation/lesson_list_progress_test.dart
git commit -m "feat(progress): add read checkmarks to LessonListPage"
```

---

## Task 9: `QuizTabHome` one-time nudge bottom sheet (TDD)

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Create: `test/features/quiz/presentation/quiz_tab_nudge_test.dart`

- [ ] **Step 1: Write failing widget tests**

Create `test/features/quiz/presentation/quiz_tab_nudge_test.dart`:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 's1',
            examId: 'e1',
            name: 'Verbal',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Vocabulary',
            ordering: 1,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'l1',
            topicId: 't1',
            title: 'Lesson 1',
            summary: 'Summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: 5,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('shows nudge bottom sheet on first quiz tap with no lessons read',
      (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsOneWidget);
  });

  testWidgets('does not show nudge when nudge already dismissed', (tester) async {
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(
            id: const Value(1),
            dismissedAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsNothing);
  });

  testWidgets('does not show nudge when at least one lesson is read',
      (tester) async {
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'l1',
            readAt: DateTime.now(),
          ),
        );

    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Quick Quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Study first for better results'), findsNothing);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/quiz/presentation/quiz_tab_nudge_test.dart -v`
Expected: FAIL — nudge sheet not shown.

- [ ] **Step 3: Update `quiz_tab_home.dart`**

Replace the full contents of `lib/features/quiz/presentation/quiz_tab_home.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/quiz_nudge_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizTabHome extends ConsumerWidget {
  const QuizTabHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExams = ref.watch(examListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: asyncExams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exams) {
          if (exams.isEmpty) {
            return const Center(child: Text('No exams available.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exam = exams[index];
              return _ExamCard(exam: exam);
            },
          );
        },
      ),
    );
  }
}

class _ExamCard extends ConsumerWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  Future<void> _onStartQuiz(BuildContext context, WidgetRef ref) async {
    final isDismissed =
        await ref.read(quizNudgeDismissedProvider.future);
    final anyRead = await ref.read(anyLessonReadProvider.future);

    if (!isDismissed && !anyRead) {
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => _QuizNudgeSheet(
          onReadLessons: () {
            Navigator.of(context).pop();
            context.go('/learn');
          },
          onStartAnyway: () async {
            await ref.read(quizNudgeRepositoryProvider).markDismissed();
            ref.invalidate(quizNudgeDismissedProvider);
            if (!context.mounted) return;
            Navigator.of(context).pop();
            context.go('/quiz/quick/${exam.id}');
          },
        ),
      );
      return;
    }

    context.go('/quiz/quick/${exam.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam.name,
            style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            exam.shortName,
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Start Quick Quiz',
            onPressed: () => _onStartQuiz(context, ref),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Browse Lessons',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/learn'),
          ),
        ],
      ),
    );
  }
}

class _QuizNudgeSheet extends StatelessWidget {
  const _QuizNudgeSheet({
    required this.onReadLessons,
    required this.onStartAnyway,
  });

  final VoidCallback onReadLessons;
  final VoidCallback onStartAnyway;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Study first for better results',
                style: textStyles.headlineSmall),
            const SizedBox(height: 12),
            Text(
              "You haven't read any lessons for this exam yet. "
              'Reading the material before quizzing helps you retain it longer.',
              style: textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Read lessons',
              onPressed: onReadLessons,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Start quiz anyway',
              variant: AppButtonVariant.secondary,
              onPressed: onStartAnyway,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/quiz/presentation/quiz_tab_nudge_test.dart -v`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/quiz/presentation/quiz_tab_home.dart \
        test/features/quiz/presentation/quiz_tab_nudge_test.dart
git commit -m "feat(progress): add one-time quiz nudge bottom sheet to QuizTabHome"
```

---

## Task 10: Full test suite and analysis

**Files:** none new

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze lib/`
Expected: no errors or warnings.

- [ ] **Step 2: Run full test suite**

Run: `flutter test`
Expected: all tests PASS (no regressions).

- [ ] **Step 3: If any tests fail, fix them before proceeding**

Common issues to check:
- `_LessonCard` constructor calls in existing `lesson_list_page_test.dart` — the widget now needs `isLessonReadProvider` available, so tests must use `pumpAppWithProviders` with `appDatabaseProvider.overrideWithValue(db)` (they already do).
- `lesson_page_test.dart` — existing tests pump `LessonPage` without progress DB seed. The `isLessonReadProvider` will return `false` (unread) by default, so "Mark as read" button will show. Existing tests only check title/body/read-time, so they should be unaffected.

- [ ] **Step 4: Final commit if any fixes were needed**

```bash
git add -p
git commit -m "fix(progress): fix test regressions after lesson progress integration"
```
