# Quiz Tab, Plan 1 of 6: Storage and Content Fields Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the storage layer and content fields that every other Quiz tab plan
depends on: durable question flags with sync, a mistake tag on each attempt item, a
three-way session-ordering preference, and the `lessonId`, per-choice rationale and
short-label fields on questions.

**Architecture:** No new subsystems and no UI. Three schema migrations on the existing
Drift database (11 to 14), one new local table following the `lesson_progress_local`
shape, one new sync mapper registered in the four places every existing mapper is
registered, and additive nullable fields on the freezed `Question`, `Choice` and
`AttemptItem` models with matching passthrough in `Seeder`. Everything here is
invisible to the student; the surfaces that consume it are Plans 2 to 6.

**Tech Stack:** Flutter, Drift, freezed, `json_serializable`, `flutter_test`. No new
packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-quiz-tab-design.md`, Section 6
(Flags, storage), Section 9 (Data and content work), and Section 5 (ordering).

**Status: executed and merged 2 August 2026**, commit `a91fbdb`. Two errors in this plan
were found during execution and are corrected in place above, so that the remaining five
plans do not inherit them:

1. It told the implementor to `git add` `.g.dart` and `.freezed.dart` files. This repo
   gitignores both. Those lines are removed.
2. Task 6 said to append `lessonId` to the `Question` factory; appending was correct, but
   the instruction was easy to read as "anywhere", and it landed between two required
   parameters, breaking `always_put_required_named_parameters_first`. Fixed in
   `1c7c6de`.

## Global Constraints

- **No new dependencies.** Everything needed is already in `pubspec.yaml`.
- **Generated files are never edited by hand, and never committed.** `.gitignore` excludes
  `**/*.g.dart` and `**/*.freezed.dart`. After any change to a `@freezed` class, a Drift
  table, or `app_database.dart`, run
  `dart run build_runner build --delete-conflicting-outputs`, and do not `git add` its
  output.
- **Work only inside your worktree.** Never write to the main checkout. A previous run
  left a half-applied `app_database.dart` in the main tree, with `schemaVersion` bumped
  and no matching migrations, which is a broken state that compiles.
- **Layering (`tool/check_layering.dart`).** R1: `lib/core/**` must not import
  `lib/features/**`. R2: one feature must not import another. R3: `domain/` must not
  import Flutter or platform packages.
- **Analysis is `very_good_analysis` with `strict-casts` and `strict-inference`.**
  Loosely typed code fails the analyzer. Write the types.
- **Additive only.** Every new field on an existing model is nullable or carries a
  default, because `assets/seed/v1.json` in the repo today has none of them and must
  keep parsing unchanged.
- **No user-facing strings are added by this plan.** If you find yourself writing copy,
  you are in the wrong plan. Stop and say so.
- **Commit messages carry no AI attribution and no co-author trailers.** Explain why,
  not what.
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/storage/data/tables/question_flags_local_table.dart` — the durable practice
  flag. One row per flagged question, mirroring the `lesson_progress_local` shape
  (referenced PK, a timestamp, a `syncState`) plus the nullable `sortIndex` the spec
  reserves for Pro custom ordering.
- `lib/core/storage/data/repos/question_flags_repository.dart` — flag, unflag, query.
  Lives beside the other repos in `core/storage/data/repos/` because both the Quiz tab
  and the mock review read it, and a feature-local home would violate R2.
- `lib/core/sync/mapping/question_flag_mapper.dart` — the Firestore mapper, same shape
  as `LessonProgressMapper`.
- `lib/features/quiz/domain/models/quiz_ordering.dart` — the three-way ordering enum and
  its string codec. Feature-local because only the quiz feature and its Settings row
  read it.
- `test/core/storage/data/tables/question_flags_migration_test.dart`
- `test/core/storage/data/repos/question_flags_repository_test.dart`
- `test/core/sync/mapping/question_flag_mapper_test.dart`
- `test/features/quiz/domain/models/quiz_ordering_test.dart`

**Modify:**
- `lib/core/storage/data/app_database.dart` — register the table, bump `schemaVersion`
  three times across this plan (11 to 14), add three `onUpgrade` branches.
- `lib/core/sync/engine/collection_registry.dart` — one `SyncCollectionEntry`.
- `lib/core/sync/bootstrap/full_push.dart` — one write loop.
- `lib/core/sync/bootstrap/full_pull.dart` — one wipe line and one read loop.
- `lib/core/sync/local_state_wiper.dart` — one delete line and one progress check.
- `lib/core/storage/domain/attempt.dart` — `MistakeTag?` on `AttemptItem`.
- `lib/core/storage/domain/question.dart` — `lessonId` and `shortLabel`.
- `lib/core/storage/domain/choice.dart` — `rationale`.
- `lib/core/storage/data/tables/questions_table.dart` — `lessonId`, `shortLabel`.
- `lib/core/storage/data/seeder.dart` — passthrough for the three new question fields.
- `lib/features/quiz/domain/models/quiz_preferences.dart` — `interleavedToday` becomes
  `ordering`.
- `lib/features/quiz/data/repos/quiz_preferences_repository.dart` — read and write the
  three-way value, with back-compat for the shipped boolean.

**Deliberately not touched:** `lib/features/quiz/application/`, every widget, and
`mock_attempts_table.dart`. Per Section 6 of the spec, `mock_attempt.flagsJson` is a
per-attempt working mark on a different lifetime and **never writes to
`question_flags_local` by itself**. Any step that appears to connect them is wrong.

---

## Task 1: The `question_flags_local` table

**Files:**
- Create: `lib/core/storage/data/tables/question_flags_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Test: `test/core/storage/data/tables/question_flags_migration_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: the Drift getter `db.questionFlagsLocal`, the row class
  `QuestionFlagLocalRow` with fields `questionId` (String), `flaggedAt` (DateTime),
  `sortIndex` (int?), `syncState` (String), and the companion
  `QuestionFlagsLocalCompanion`. Tasks 2 and 3 depend on these exact names.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/data/tables/question_flags_migration_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('new installs create the question flags table', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final tables = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name = 'question_flags_local'",
        )
        .get();

    expect(tables.map((row) => row.read<String>('name')).toList(),
        equals(['question_flags_local']));
  });

  test('a flag row round-trips with a null sort index', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final flaggedAt = DateTime.utc(2026, 8, 2, 9, 30);
    await db.into(db.questionFlagsLocal).insert(
          QuestionFlagsLocalCompanion.insert(
            questionId: 'q1',
            flaggedAt: flaggedAt,
          ),
        );

    final rows = await db.select(db.questionFlagsLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.questionId, 'q1');
    expect(rows.single.flaggedAt, flaggedAt);
    expect(rows.single.sortIndex, isNull);
    expect(rows.single.syncState, 'pending');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/tables/question_flags_migration_test.dart`
Expected: FAIL. The analyzer reports that `questionFlagsLocal` is not defined for
`AppDatabase`.

- [ ] **Step 3: Create the table**

Create `lib/core/storage/data/tables/question_flags_local_table.dart`:

```dart
// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/questions_table.dart';
import 'package:drift/drift.dart';

/// A question the student kept for later, from the reveal or from a mock's
/// review. Durable: unlike `mock_attempt.flagsJson`, which expires with the
/// paper it was set on, a row here outlives every session.
@DataClassName('QuestionFlagLocalRow')
class QuestionFlagsLocal extends Table {
  TextColumn get questionId => text().references(Questions, #id)();
  DateTimeColumn get flaggedAt => dateTime()();

  /// Reserved for Pro custom ordering. Null means "order by flaggedAt".
  IntColumn get sortIndex => integer().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}
```

- [ ] **Step 4: Register the table and bump the schema**

In `lib/core/storage/data/app_database.dart`, add the import beside the other table
imports, keeping them alphabetical:

```dart
import 'package:cse_cet_reviewer/core/storage/data/tables/question_flags_local_table.dart';
```

Add `QuestionFlagsLocal,` to the `tables:` list, after `Questions,`.

Change the schema version:

```dart
  @override
  int get schemaVersion => 12;
```

Add the migration branch at the end of `onUpgrade`, after the `from < 11` branch:

```dart
          if (from < 12) {
            await m.createTable(questionFlagsLocal);
          }
```

- [ ] **Step 5: Regenerate and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/core/storage/data/tables/question_flags_migration_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage/data/tables/question_flags_local_table.dart \
        lib/core/storage/data/app_database.dart \
        test/core/storage/data/tables/question_flags_migration_test.dart
git commit -m "feat(storage): durable question flags need a home of their own

A mock's flagsJson expires with the paper it was set on, so it cannot
carry a flag the student wants weeks later. This table is that record."
```

---

## Task 2: `QuestionFlagsRepository`

**Files:**
- Create: `lib/core/storage/data/repos/question_flags_repository.dart`
- Test: `test/core/storage/data/repos/question_flags_repository_test.dart`

**Interfaces:**
- Consumes: `db.questionFlagsLocal`, `QuestionFlagsLocalCompanion`,
  `QuestionFlagLocalRow` from Task 1.
- Produces: `QuestionFlagsRepository(AppDatabase db)` with
  `Future<void> flag(QuestionId)`, `Future<void> unflag(QuestionId)`,
  `Future<bool> isFlagged(QuestionId)`, `Future<Set<QuestionId>> flaggedIds()`,
  `Future<List<QuestionFlagLocalRow>> flagsNewestFirst()`, and
  `Future<int> flagCount()`. Plans 2 and 6 call these.

`QuestionId` is a `typedef` for `String` in `lib/core/storage/domain/ids.dart`, the same
way `LessonId` is. Import it rather than writing `String`.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/data/repos/question_flags_repository_test.dart`. The
`questionId` column references `Questions`, so seed the exam, subject, topic and
question rows first, exactly as `lesson_progress_repository_test.dart` seeds its chain:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/question_flags_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late QuestionFlagsRepository repo;

  Future<void> insertQuestion(String id) {
    return db.into(db.questions).insert(
          QuestionsCompanion.insert(
            id: id,
            version: 1,
            examIdsJson: jsonEncode(['e1']),
            topicId: 't1',
            language: 'en',
            stem: 'Stem $id',
            choicesJson: jsonEncode(<Map<String, Object?>>[]),
            explanation: 'Because.',
          ),
        );
  }

  setUp(() async {
    db = inMemoryDatabase();
    repo = QuestionFlagsRepository(db);

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
            name: 'Science',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 't1',
            subjectId: 's1',
            name: 'Chemistry',
            ordering: 1,
          ),
        );
    await insertQuestion('q1');
    await insertQuestion('q2');
  });

  tearDown(() => db.close());

  test('flagging a question makes it flagged', () async {
    await repo.flag('q1');

    expect(await repo.isFlagged('q1'), isTrue);
    expect(await repo.isFlagged('q2'), isFalse);
    expect(await repo.flagCount(), 1);
    expect(await repo.flaggedIds(), {'q1'});
  });

  test('flagging twice keeps one row and refreshes the timestamp', () async {
    await repo.flag('q1');
    final first = (await db.select(db.questionFlagsLocal).get()).single.flaggedAt;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.flag('q1');

    final rows = await db.select(db.questionFlagsLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.flaggedAt.isAfter(first), isTrue);
  });

  test('unflagging removes the row', () async {
    await repo.flag('q1');
    await repo.unflag('q1');

    expect(await repo.isFlagged('q1'), isFalse);
    expect(await repo.flagCount(), 0);
  });

  test('unflagging something never flagged is a no-op', () async {
    await repo.unflag('q2');

    expect(await repo.flagCount(), 0);
  });

  test('flags come back newest first, and sortIndex wins when set', () async {
    await repo.flag('q1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.flag('q2');

    expect(
      (await repo.flagsNewestFirst()).map((row) => row.questionId).toList(),
      ['q2', 'q1'],
    );

    await (db.update(db.questionFlagsLocal)
          ..where((row) => row.questionId.equals('q1')))
        .write(const QuestionFlagsLocalCompanion(sortIndex: Value(0)));

    expect(
      (await repo.flagsNewestFirst()).map((row) => row.questionId).toList(),
      ['q1', 'q2'],
    );
  });

  test('a new flag is pending sync', () async {
    await repo.flag('q1');

    final row = (await db.select(db.questionFlagsLocal).get()).single;
    expect(row.syncState, 'pending');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/repos/question_flags_repository_test.dart`
Expected: FAIL. `question_flags_repository.dart` does not exist.

- [ ] **Step 3: Write the repository**

Create `lib/core/storage/data/repos/question_flags_repository.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/sync_state.dart';
import 'package:drift/drift.dart';

/// Durable practice flags. A flag set inside a mock lives on that attempt and
/// only reaches this table when the student converts it from the mock's
/// review, so nothing here writes itself from `mock_attempt.flagsJson`.
class QuestionFlagsRepository {
  QuestionFlagsRepository(this._db);

  final AppDatabase _db;

  Future<void> flag(QuestionId questionId) async {
    // flaggedAt refreshes on a repeat flag: it records the most recent time
    // the student said this one matters, which is what the list sorts on.
    await _db.into(_db.questionFlagsLocal).insertOnConflictUpdate(
          QuestionFlagsLocalCompanion(
            questionId: Value(questionId),
            flaggedAt: Value(DateTime.now()),
            syncState: Value(SyncState.pending.name),
          ),
        );
  }

  Future<void> unflag(QuestionId questionId) async {
    await (_db.delete(_db.questionFlagsLocal)
          ..where((row) => row.questionId.equals(questionId)))
        .go();
  }

  Future<bool> isFlagged(QuestionId questionId) async {
    final row = await (_db.select(_db.questionFlagsLocal)
          ..where((flag) => flag.questionId.equals(questionId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<QuestionId>> flaggedIds() async {
    final rows = await _db.select(_db.questionFlagsLocal).get();
    return rows.map((row) => row.questionId).toSet();
  }

  /// Custom order first for the rows that carry one, then most recently
  /// flagged. Null `sortIndex` sorts last so an unordered flag never
  /// displaces one the student placed by hand.
  Future<List<QuestionFlagLocalRow>> flagsNewestFirst() {
    return (_db.select(_db.questionFlagsLocal)
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.sortIndex,
                  mode: OrderingMode.asc,
                  nulls: NullsOrder.last,
                ),
            (row) => OrderingTerm.desc(row.flaggedAt),
          ]))
        .get();
  }

  Future<int> flagCount() async {
    final count = _db.questionFlagsLocal.questionId.count();
    final query = _db.selectOnly(_db.questionFlagsLocal)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/storage/data/repos/question_flags_repository_test.dart`
Expected: PASS, 6 tests.

- [ ] **Step 5: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/core/storage/data/repos/question_flags_repository.dart \
        test/core/storage/data/repos/question_flags_repository_test.dart
git commit -m "feat(storage): read and write question flags

Custom order sorts ahead of recency so a Pro user's hand ordering is
never displaced by a flag set five minutes ago."
```

---

## Task 3: Sync the flags

**Files:**
- Create: `lib/core/sync/mapping/question_flag_mapper.dart`
- Modify: `lib/core/sync/engine/collection_registry.dart`
- Modify: `lib/core/sync/bootstrap/full_push.dart`
- Modify: `lib/core/sync/bootstrap/full_pull.dart`
- Modify: `lib/core/sync/local_state_wiper.dart`
- Test: `test/core/sync/mapping/question_flag_mapper_test.dart`

**Interfaces:**
- Consumes: `QuestionFlagLocalRow`, `QuestionFlagsLocalCompanion` from Task 1.
- Produces: `QuestionFlagMapper` with `documentId`, `toFirestore`, `fromFirestore` and
  `toCompanion`, and the collection `tableType` and `firestorePath` string
  `'question_flags'`.

A mapper is registered in **four** places, and missing one is silent. All four are in
this task on purpose.

- [ ] **Step 1: Write the failing test**

Create `test/core/sync/mapping/question_flag_mapper_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/engine/collection_registry.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/question_flag_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = QuestionFlagMapper();

  test('a flag row becomes a firestore document', () {
    final doc = mapper.toFirestore(
      QuestionFlagLocalRow(
        questionId: 'q1',
        flaggedAt: DateTime.utc(2026, 8, 2, 9, 30),
        sortIndex: 3,
        syncState: 'pending',
      ),
      updatedAt: DateTime.utc(2026, 8, 2, 10),
      originDeviceId: 'device-1',
    );

    expect(doc, {
      'questionId': 'q1',
      'flaggedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': 3,
      'updatedAt': '2026-08-02T10:00:00.000Z',
      'originDeviceId': 'device-1',
      'schemaVersion': 1,
    });
  });

  test('a firestore document becomes a synced flag row', () {
    final row = mapper.fromFirestore({
      'questionId': 'q1',
      'flaggedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': null,
    });

    expect(row.questionId, 'q1');
    expect(row.flaggedAt, DateTime.utc(2026, 8, 2, 9, 30));
    expect(row.sortIndex, isNull);
    expect(row.syncState, 'synced');
  });

  test('the document id is the question id', () {
    expect(
      mapper.documentId(
        QuestionFlagLocalRow(
          questionId: 'q7',
          flaggedAt: DateTime.utc(2026, 8, 2),
          syncState: 'pending',
        ),
      ),
      'q7',
    );
  });

  test('question flags are an active sync collection', () {
    final entry = activeSyncCollections
        .firstWhere((entry) => entry.tableType == 'question_flags');

    expect(entry.firestorePath, 'question_flags');
    expect(entry.mapper, isA<QuestionFlagMapper>());
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/sync/mapping/question_flag_mapper_test.dart`
Expected: FAIL. `question_flag_mapper.dart` does not exist.

- [ ] **Step 3: Write the mapper**

Create `lib/core/sync/mapping/question_flag_mapper.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/sync_mapper.dart';
import 'package:drift/drift.dart';

class QuestionFlagMapper implements SyncMapper {
  const QuestionFlagMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'question_flags';

  String documentId(QuestionFlagLocalRow row) => row.questionId;

  Map<String, Object?> toFirestore(
    QuestionFlagLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'questionId': row.questionId,
      'flaggedAt': row.flaggedAt.toUtc().toIso8601String(),
      'sortIndex': row.sortIndex,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  QuestionFlagLocalRow fromFirestore(Map<String, Object?> doc) {
    return QuestionFlagLocalRow(
      questionId: doc['questionId']! as String,
      flaggedAt: DateTime.parse(doc['flaggedAt']! as String),
      sortIndex: doc['sortIndex'] as int?,
      syncState: 'synced',
    );
  }

  QuestionFlagsLocalCompanion toCompanion(QuestionFlagLocalRow row) {
    return QuestionFlagsLocalCompanion(
      questionId: Value(row.questionId),
      flaggedAt: Value(row.flaggedAt),
      sortIndex: Value(row.sortIndex),
      syncState: Value(row.syncState),
    );
  }
}
```

- [ ] **Step 4: Register it in the collection registry**

In `lib/core/sync/engine/collection_registry.dart`, add the import beside the others:

```dart
import 'package:cse_cet_reviewer/core/sync/mapping/question_flag_mapper.dart';
```

Add this entry to `syncCollections`, after the `lesson_progress` entry:

```dart
  SyncCollectionEntry(
    tableType: 'question_flags',
    firestorePath: 'question_flags',
    mapper: QuestionFlagMapper(),
  ),
```

- [ ] **Step 5: Register it in the full push**

In `lib/core/sync/bootstrap/full_push.dart`, add the import, then declare the mapper
beside the others in `_buildWrites`:

```dart
    const questionFlags = QuestionFlagMapper();
```

Add this collection literal entry after the `lesson_progress` loop and before the
`preferences` write:

```dart
      for (final row in await _db.select(_db.questionFlagsLocal).get())
        FirestoreWrite.set(
          path: 'users/$_uid/question_flags/${questionFlags.documentId(row)}',
          data: questionFlags.toFirestore(
            row,
            updatedAt: updatedAt,
            originDeviceId: _deviceId,
          ),
        ),
```

- [ ] **Step 6: Register it in the full pull**

In `lib/core/sync/bootstrap/full_pull.dart`, add the import. In `_wipeSyncedState`, add
this line after the `lessonProgressLocal` delete:

```dart
      await _db.delete(_db.questionFlagsLocal).go();
```

In `_applyCloudRows`, add this block after the `lessons` block:

```dart
    const questionFlags = QuestionFlagMapper();
    for (final doc
        in await _gateway.readCollection('users/$_uid/question_flags')) {
      await _db.into(_db.questionFlagsLocal).insertOnConflictUpdate(
            questionFlags.toCompanion(questionFlags.fromFirestore(doc)),
          );
    }
```

- [ ] **Step 7: Register it in the local state wiper**

In `lib/core/sync/local_state_wiper.dart`, add this delete inside the `wipeAll`
transaction, after the `lessonProgressLocal` delete:

```dart
      await _db.delete(_db.questionFlagsLocal).go();
```

Leave `hasMeaningfulProgress` alone. A flag with no attempt behind it is not progress
worth warning about, and the three checks already there cover every case where it
would be.

- [ ] **Step 8: Run the mapper test and the sync suite**

Run: `flutter test test/core/sync/`
Expected: PASS, including the 4 new tests. If an existing full-push or full-pull test
asserts an exact write count, it will fail: update it to include the new collection,
and say so in the commit message.

- [ ] **Step 9: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/sync test/core/sync
git commit -m "feat(sync): carry question flags between devices

A flag is a judgment the student made weeks ago. Losing it on reinstall
would be worse than never offering the mark."
```

---

## Task 4: The mistake tag on an attempt item

**Files:**
- Modify: `lib/core/storage/domain/attempt.dart`
- Test: `test/core/storage/domain/attempt_test.dart` (create if absent)

**Interfaces:**
- Consumes: nothing.
- Produces: `enum MistakeTag { misread, slipped, unknown }` and the nullable field
  `AttemptItem.mistakeTag`. Plan 5 writes it from the debrief; Progress reads it.

**This is not a column.** Attempt items are stored as `itemsJson` on `attempts_local`,
so the field rides inside the existing JSON and needs no migration. Any step that adds
a Drift column here is wrong.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/domain/attempt_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = AttemptItem(
    questionId: 'q1',
    questionVersion: 1,
    chosenChoiceId: 'c2',
    correctChoiceId: 'c1',
    responseMs: 4200,
  );

  test('an attempt item has no mistake tag until one is noted', () {
    expect(base.mistakeTag, isNull);
  });

  test('a mistake tag round-trips through json', () {
    final json = base.copyWith(mistakeTag: MistakeTag.slipped).toJson();

    expect(json['mistakeTag'], 'slipped');
    expect(AttemptItem.fromJson(json).mistakeTag, MistakeTag.slipped);
  });

  test('items written before tagging existed still parse', () {
    final legacy = <String, dynamic>{
      'questionId': 'q1',
      'questionVersion': 1,
      'chosenChoiceId': 'c2',
      'correctChoiceId': 'c1',
      'responseMs': 4200,
    };

    expect(AttemptItem.fromJson(legacy).mistakeTag, isNull);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/domain/attempt_test.dart`
Expected: FAIL. `MistakeTag` is not defined.

- [ ] **Step 3: Add the enum and the field**

In `lib/core/storage/domain/attempt.dart`, add the enum above `AttemptItem`:

```dart
/// What the student said went wrong, noted from the debrief. Null means they
/// were not asked or chose not to say, which is the common case: the debrief
/// states outright that leaving one blank costs nothing.
enum MistakeTag { misread, slipped, unknown }
```

Add the field as the last parameter of the `AttemptItem` factory, after `responseMs`:

```dart
    MistakeTag? mistakeTag,
```

- [ ] **Step 4: Regenerate and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/core/storage/domain/attempt_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Run the attempt suite**

Run: `flutter test test/core/storage/ test/core/sync/mapping/attempt_mapper_test.dart`
Expected: PASS. `AttemptMapper` serialises items through `toJson`, so the new key
appears only once something sets it and old rows are unaffected.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage/domain/attempt.dart \
        test/core/storage/domain/attempt_test.dart
git commit -m "feat(storage): record what the student says went wrong

Four of the five causes are derivable. Misreading is invisible to every
signal we have, which is the whole reason the debrief asks."
```

---

## Task 5: Session ordering becomes a three-way setting

**Files:**
- Create: `lib/features/quiz/domain/models/quiz_ordering.dart`
- Modify: `lib/features/quiz/domain/models/quiz_preferences.dart`
- Modify: `lib/features/quiz/data/repos/quiz_preferences_repository.dart`
- Test: `test/features/quiz/domain/models/quiz_ordering_test.dart`
- Test: `test/features/quiz/data/repos/quiz_preferences_repository_test.dart` (modify if
  it exists, create if not)

**Interfaces:**
- Consumes: nothing.
- Produces: `enum QuizOrdering { blocked, interleavedTail, fullyMixed }` with
  `QuizOrdering.fromStorage(String?)` and `String get storageValue`, and
  `QuizPreferences.ordering` replacing `QuizPreferences.interleavedToday`. Plan 2's
  "Change how sessions are built" link and the Settings row both read this.

The storage key `quiz_today_interleaved` **keeps its name**. It already ships, it is
already synced through `PreferencesMapper`, and renaming it would strand the value on
every device that has one. It widens from `'true'`/`'false'` to the three enum names.

The default is `interleavedTail`, per Section 5. Note this changes behaviour: the
shipped default was `interleavedToday: false`, which is `blocked`. That is the spec's
intent, not an accident.

- [ ] **Step 1: Write the failing test for the enum**

Create `test/features/quiz/domain/models/quiz_ordering_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each ordering round-trips through storage', () {
    for (final ordering in QuizOrdering.values) {
      expect(QuizOrdering.fromStorage(ordering.storageValue), ordering);
    }
  });

  test('the shipped boolean still reads', () {
    expect(QuizOrdering.fromStorage('true'), QuizOrdering.interleavedTail);
    expect(QuizOrdering.fromStorage('false'), QuizOrdering.blocked);
  });

  test('an absent or unrecognised value falls back to the default', () {
    expect(QuizOrdering.fromStorage(null), QuizOrdering.interleavedTail);
    expect(QuizOrdering.fromStorage(''), QuizOrdering.interleavedTail);
    expect(QuizOrdering.fromStorage('sideways'), QuizOrdering.interleavedTail);
  });

  test('interleaved tail is the recommended default', () {
    expect(QuizOrdering.defaultOrdering, QuizOrdering.interleavedTail);
    expect(QuizOrdering.interleavedTail.isRecommended, isTrue);
    expect(QuizOrdering.blocked.isRecommended, isFalse);
    expect(QuizOrdering.fullyMixed.isRecommended, isFalse);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/domain/models/quiz_ordering_test.dart`
Expected: FAIL. `quiz_ordering.dart` does not exist.

- [ ] **Step 3: Write the enum**

Create `lib/features/quiz/domain/models/quiz_ordering.dart`:

```dart
/// How today's session is built. Exposed in Settings as three choices, with
/// the default carrying a recommended marker.
enum QuizOrdering {
  /// Every question from the chosen topic.
  blocked('blocked'),

  /// Seven from the topic, three drawn from other topics' due cards.
  interleavedTail('interleaved_tail'),

  /// No two consecutive questions from the same topic.
  fullyMixed('fully_mixed');

  const QuizOrdering(this.storageValue);

  final String storageValue;

  static const defaultOrdering = QuizOrdering.interleavedTail;

  bool get isRecommended => this == defaultOrdering;

  /// Reads the `quiz_today_interleaved` account preference. The key predates
  /// this enum and shipped holding `'true'` or `'false'`, so both are still
  /// understood rather than silently reset.
  static QuizOrdering fromStorage(String? raw) {
    switch (raw) {
      case 'true':
        return QuizOrdering.interleavedTail;
      case 'false':
        return QuizOrdering.blocked;
    }
    for (final ordering in QuizOrdering.values) {
      if (ordering.storageValue == raw) return ordering;
    }
    return defaultOrdering;
  }
}
```

- [ ] **Step 4: Run the enum test**

Run: `flutter test test/features/quiz/domain/models/quiz_ordering_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Widen `QuizPreferences`**

In `lib/features/quiz/domain/models/quiz_preferences.dart`, add the import:

```dart
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_ordering.dart';
```

Replace the `interleavedToday` field and its constructor parameter with `ordering`:

```dart
class QuizPreferences {
  QuizPreferences({
    required this.sessionLength,
    required this.ordering,
    required this.newCardCap,
  }) {
    if (!_allowedSessionLengths.contains(sessionLength)) {
      throw ArgumentError.value(
        sessionLength,
        'sessionLength',
        'must be 5, 10, 20, or allDueSessionLength',
      );
    }
    if (newCardCap < 0) {
      throw ArgumentError.value(
        newCardCap,
        'newCardCap',
        'cannot be negative',
      );
    }
  }

  static const allDueSessionLength = -1;
  static const _allowedSessionLengths = {5, 10, 20, allDueSessionLength};

  static final defaults = QuizPreferences(
    sessionLength: 10,
    ordering: QuizOrdering.defaultOrdering,
    newCardCap: 10,
  );

  final int sessionLength;
  final QuizOrdering ordering;
  final int newCardCap;
}
```

- [ ] **Step 6: Widen the repository**

In `lib/features/quiz/data/repos/quiz_preferences_repository.dart`, add the
`quiz_ordering.dart` import. Replace the `interleavedToday` read in `read()`:

```dart
      ordering: QuizOrdering.fromStorage(values[interleavedTodayKey]),
```

Replace the `interleavedTodayKey` insert in `save()`:

```dart
        AccountPrefsCompanion.insert(
          key: interleavedTodayKey,
          value: preferences.ordering.storageValue,
        ),
```

Leave the constant `interleavedTodayKey = 'quiz_today_interleaved'` and its name
untouched, and add this comment above it:

```dart
  /// Named for the boolean it used to be. The key is synced and already on
  /// devices, so it widened in place rather than being replaced.
```

- [ ] **Step 7: Fix every call site**

Run: `grep -rn "interleavedToday" --include="*.dart" lib test`

Every hit outside `quiz_preferences_repository.dart` is a call site that must move to
`ordering`. `StartToday` reads this preference. **Do not change how it composes a
session in this plan**: map `QuizOrdering.blocked` to the old `false` behaviour and both
other values to the old `true` behaviour for now, so this task stays a storage change.
Building the real interleaved tail and fully mixed orderings is Plan 3's job, and the
seam is recorded in that plan's source spec at Section 5.

If the mapping is not mechanical at a given call site, **stop and say so** rather than
inventing a composition rule.

- [ ] **Step 8: Run the quiz suite**

Run: `flutter test test/features/quiz/`
Expected: PASS. Tests asserting `interleavedToday: false` become
`ordering: QuizOrdering.blocked`; tests asserting `true` become
`QuizOrdering.interleavedTail`.

- [ ] **Step 9: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "feat(quiz): session ordering widens from a flag to a choice

The stored key keeps its old name because it is already synced to
devices, and reading the legacy true/false keeps those devices working."
```

---

## Task 6: `lessonId` on a question

**Files:**
- Modify: `lib/core/storage/data/tables/questions_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `lib/core/storage/domain/question.dart`
- Modify: `lib/core/storage/data/seeder.dart`
- Test: `test/core/storage/data/seeder_test.dart` (modify)

**Interfaces:**
- Consumes: nothing.
- Produces: the nullable column `questions.lessonId`, the nullable field
  `Question.lessonId` of type `LessonId?`, and `Seeder` passthrough from
  `q['lessonId']`. Plan 3's lesson selection and the reader coda both read it.

**Nullable, and it stays nullable.** All 1,117 questions are untagged today. The
authoring pass that fills this in is content work, tracked separately, and the column
must tolerate the gap until then. Nothing in this plan tags a single question.

**One trap, and the reason this task reorders the seeder.** `Seeder.maybeSeed` inserts
questions **before** lessons, so a question naming a lesson would reference a row that
does not exist yet. It would not fail today, because nothing in this app ever runs
`PRAGMA foreign_keys = ON` and SQLite leaves them off by default, but it is a bug
waiting for the day someone turns them on. This task moves the lessons loop above the
questions loop.

- [ ] **Step 1: Write the failing test**

The existing `seeder_test.dart` seeds from the real `rootBundle` asset and deliberately
asserts no counts. Do not edit `assets/seed/v1.json`: it is regenerated whenever content
is authored and hand edits are lost. Add a fake bundle and a fixture instead.

Add to the top of `test/core/storage/data/seeder_test.dart`:

```dart
class _FixtureBundle extends CachingAssetBundle {
  _FixtureBundle(this.json);

  final String json;

  @override
  Future<String> loadString(String key, {bool cache = true}) async => json;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(json)));
}

const _fixture = '''
{
  "exams": [
    {
      "id": "e1", "code": "CSE", "name": "Civil Service Exam",
      "shortName": "CSE", "language": "en",
      "subjects": [
        {"id": "s1", "examId": "e1", "name": "Science", "ordering": 1}
      ]
    }
  ],
  "topics": [{"id": "t1", "subjectId": "s1", "name": "Chemistry", "ordering": 1}],
  "lessons": [
    {
      "id": "l1", "topicId": "t1", "title": "Balancing equations",
      "summary": "How to balance.", "bodyJson": [], "estimatedMinutes": 5
    }
  ],
  "questions": [
    {
      "id": "q1", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "lessonId": "l1", "language": "en", "stem": "Tagged question",
      "choices": [], "explanation": "Because."
    },
    {
      "id": "q2", "version": 1, "examIds": ["e1"], "topicId": "t1",
      "language": "en", "stem": "Untagged question",
      "choices": [], "explanation": "Because."
    }
  ]
}
''';
```

Add the imports it needs: `dart:convert`, `dart:typed_data`, and `package:flutter/services.dart`
is already imported.

Then add the two tests:

```dart
  test('a question carries its lesson id when the seed provides one', () async {
    await Seeder(db, bundle: _FixtureBundle(_fixture)).maybeSeed();

    final row =
        await (db.select(db.questions)..where((q) => q.id.equals('q1')))
            .getSingle();

    expect(row.lessonId, 'l1');
  });

  test('a question with no lesson id in the seed stores null', () async {
    await Seeder(db, bundle: _FixtureBundle(_fixture)).maybeSeed();

    final row =
        await (db.select(db.questions)..where((q) => q.id.equals('q2')))
            .getSingle();

    expect(row.lessonId, isNull);
  });

  test('lessons are inserted before the questions that reference them',
      () async {
    await Seeder(db, bundle: _FixtureBundle(_fixture)).maybeSeed();

    // Enforce the constraint the app never turns on, to prove the seed order
    // would survive it.
    await db.customStatement('PRAGMA foreign_key_check');
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/seeder_test.dart`
Expected: FAIL. `lessonId` is not defined for `QuestionRow`.

- [ ] **Step 3: Add the column**

In `lib/core/storage/data/tables/questions_table.dart`, add after `topicId`:

```dart
  /// Null until the tagging pass lands. Questions carry `topicId` only today,
  /// which is why every lesson in a topic currently hands out the same five.
  TextColumn get lessonId => text().nullable().references(Lessons, #id)();
```

Add the `lessons_table.dart` import at the top.

- [ ] **Step 4: Migrate**

In `lib/core/storage/data/app_database.dart`, bump the version to 13 and add:

```dart
          if (from < 13) {
            await m.addColumn(questions, questions.lessonId);
          }
```

- [ ] **Step 5: Add the domain field**

In `lib/core/storage/domain/question.dart`, add as the last parameter of the factory:

```dart
    LessonId? lessonId,
```

`LessonId` is already exported from `ids.dart`, which the file imports.

- [ ] **Step 6: Pass it through the seeder, and fix the insert order**

In `lib/core/storage/data/seeder.dart`, add to the `QuestionsCompanion.insert` call,
after `topicId`:

```dart
                lessonId: Value(q['lessonId'] as String?),
```

`Value` comes from `package:drift/drift.dart`, which the seeder already imports.

Then **move the whole `json['lessons']` loop above the `json['questions']` loop**, so
the order inside the transaction reads: exams and their subjects, topics, lessons,
questions. Add this comment above the lessons loop:

```dart
      // Lessons come before questions: a question may name the lesson it was
      // authored for, and foreign keys are only unenforced until someone turns
      // the pragma on.
```

Nothing else about either loop changes.

- [ ] **Step 7: Regenerate and run**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/core/storage/`
Expected: PASS.

- [ ] **Step 8: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): a question can name the lesson it came from

Nullable because nothing is tagged yet. The column is the prerequisite
for the reader coda, which currently hands all 17 Chemistry lessons the
same five questions."
```

---

## Task 7: The per-choice rationale and the question short label

**Files:**
- Modify: `lib/core/storage/domain/choice.dart`
- Modify: `lib/core/storage/domain/question.dart`
- Modify: `lib/core/storage/data/tables/questions_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `lib/core/storage/data/seeder.dart`
- Test: `test/core/storage/domain/question_test.dart` (create if absent)

**Interfaces:**
- Consumes: nothing.
- Produces: `Choice.rationale` of type `String?`, `Question.shortLabel` of type
  `String?`, and the nullable column `questions.shortLabel`. Plan 4's note B reads the
  rationale; Plan 5's miss rows read the label.

`rationale` needs **no column**: choices are stored in `choicesJson` and the field rides
inside it. `shortLabel` is a top-level question field and does need one.

Both are nullable and both stay nullable. The generation pass that fills them is content
work. Every renderer falls back: no rationale means note B does not render, and no label
means the stem is clamped to two lines. Those fallbacks are built in Plans 4 and 5, not
here.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/domain/question_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a choice carries an optional rationale through json', () {
    const choice = Choice(
      id: 'c2',
      label: 'B',
      text: 'Change the subscript',
      isCorrect: false,
      rationale: 'A subscript is part of the molecule’s identity.',
    );

    final parsed = Choice.fromJson(choice.toJson());
    expect(parsed.rationale, choice.rationale);
  });

  test('choices authored before rationales still parse', () {
    final legacy = <String, dynamic>{
      'id': 'c1',
      'label': 'A',
      'text': 'Change the coefficient',
      'isCorrect': true,
    };

    expect(Choice.fromJson(legacy).rationale, isNull);
  });

  test('a question carries an optional short label through json', () {
    final question = Question(
      id: 'q1',
      version: 1,
      examIds: const ['e1'],
      topicId: 't1',
      language: 'en',
      stem: r'Balance $H_2O$ by changing which part?',
      choices: const [Choice(id: 'c1', label: 'A', text: 'A', isCorrect: true)],
      explanation: 'Because.',
      shortLabel: 'Balancing an equation',
    );

    expect(Question.fromJson(question.toJson()).shortLabel,
        'Balancing an equation');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/domain/question_test.dart`
Expected: FAIL. No named parameter `rationale`.

- [ ] **Step 3: Add the fields**

In `lib/core/storage/domain/choice.dart`, add as the last factory parameter:

```dart
    /// Why this specific choice is right or wrong, addressed to the student
    /// who picked it. Null until the generation pass lands, in which case
    /// note B does not render.
    String? rationale,
```

In `lib/core/storage/domain/question.dart`, add as the last factory parameter:

```dart
    /// A few words naming what the question is about, for the debrief's miss
    /// rows. Null falls back to the stem clamped to two lines.
    String? shortLabel,
```

- [ ] **Step 4: Add the column and migrate**

In `lib/core/storage/data/tables/questions_table.dart`:

```dart
  TextColumn get shortLabel => text().nullable()();
```

In `lib/core/storage/data/app_database.dart`, bump the version to 14 and add:

```dart
          if (from < 14) {
            await m.addColumn(questions, questions.shortLabel);
          }
```

- [ ] **Step 5: Pass the label through the seeder**

In `lib/core/storage/data/seeder.dart`, add to the `QuestionsCompanion.insert` call,
after `explanation`:

```dart
                shortLabel: Value(q['shortLabel'] as String?),
```

`rationale` needs nothing here: `jsonEncode(q['choices'])` already carries whatever the
seed holds, and `Choice.fromJson` now understands the key.

- [ ] **Step 6: Regenerate and run the full suite**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test`
Expected: PASS, whole suite green. This is the last task, so the whole suite is the
gate rather than one file.

- [ ] **Step 7: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): fields for the Pro note and the debrief's miss rows

Both nullable and both unpopulated. The generation pass over all 1,117
questions is content work, and every renderer falls back without them."
```

---

## What this plan deliberately does not do

Named here so a reviewer does not read them as omissions:

- **No question is tagged, and no rationale or label is written.** This plan builds the
  fields. Filling them is a content pass over 1,117 questions, reviewed by Aedwon and
  shipped through the Sanity pipeline, and it runs alongside Plans 2 to 6.
- **No session composition changes.** Task 5 stores a three-way value and maps it onto
  the existing two behaviours. The interleaved tail and fully mixed orderings are
  Plan 3.
- **No Settings row.** The row that writes the ordering preference belongs to the
  Settings work, and this plan only makes it storable.
- **No cooldown or clock-tampering work.** Spec Section 9's UTC epoch, server stamp and
  monotonic guard belong with the mock panel in Plan 2, where the cooldown is rendered.
- **Nothing connects `mock_attempt.flagsJson` to `question_flags_local`.** They are the
  same concept on different lifetimes, and the one-time conversion is offered from the
  mock's review screen in Plan 6.

## Verification

The whole plan is green when:

```bash
flutter analyze                                  # clean
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # clean
flutter test                                     # all pass
```

And `AppDatabase.schemaVersion` reads 14, with `onUpgrade` branches for 12, 13 and 14.
