# Study Tab, Plan 1 of 5: Foundations Implementation Plan

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
> **Analyzer baseline:** `flutter analyze` reports **25 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. **The number drifts as those tools change; the
> invariant is that `lib/` and `test/` outside `test/tool/` are clean.** Any issue there is
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

## AMENDED 3 August 2026: confirm the schema version before bumping it

**Conflict C2, ruled by Aedwon.** This plan and `2026-08-02-custom-track-a-branch-and-scope.md`
both claimed `schemaVersion` **15**. That does not fail to compile: the second one to run
writes a migration under a version an existing install has already passed, drift skips it in
silence, and the result is a broken database found by a student rather than a test.

**Assigned numbering:** this plan takes **15**, `custom-track-a` takes **16**,
`custom-track-b` takes **17**.

**Add this step before any schema change in this plan:**

- [ ] **Step 0: Confirm the current version**

```bash
grep -n "schemaVersion" lib/core/storage/data/app_database.dart
```

Expected: `int get schemaVersion => 14;`. **If it is not 14, stop and say so.** Another plan
has landed ahead of this one and the numbers below need re-deriving, which is a decision and
not an implementation detail.

**The bump and its migration land in the same commit.** A version raised with no migration is
a state that compiles and is broken, and it has already happened once in this repo.

---

**Goal:** Build the invisible layer every other Study plan reads: an authored lesson
`ordering` carried end to end, the `lesson_bookmarks_local` table with its repository and
sync mapper, the two reading-position preferences, and the `InkTableRow` changes the map's
rows need.

**Architecture:** No new subsystems and no screens. Two schema migrations on the existing
Drift database (14 to 16), one new local table on the `question_flags_local` shape, one new
sync mapper registered in the four places every mapper is registered, two device
preferences, and three additive changes to one kit component. Nothing here is visible to a
student; Plans 2 to 5 are what consume it.

**Tech Stack:** Flutter, Drift, freezed, `json_serializable`, `flutter_test`. No new
packages.

**Source spec:** `docs/superpowers/specs/2026-07-27-study-tab-and-reader-design.md`,
Section 7 (Data and storage), Section 6 (Kit changes), and the first seam of "A note on
plan size".

**Plan set:** 1 of 5. The others are the Study map, bookmarks and search, the reader, and
the endings. Everything in those four depends on this one and none of it can start first.

## Global Constraints

- **No new dependencies.** Everything needed is already in `pubspec.yaml`.
- **Generated files are never edited by hand, and never committed.** `.gitignore` excludes
  `**/*.g.dart` and `**/*.freezed.dart`. After any change to a `@freezed` class, a Drift
  table, or `app_database.dart`, run
  `dart run build_runner build --delete-conflicting-outputs`, and do not `git add` its
  output.
- **Work only inside your worktree.** Never write to the main checkout. A previous run left
  a half-applied `app_database.dart` in the main tree, with `schemaVersion` bumped and no
  matching migrations, which is a broken state that compiles.
- **Layering (`tool/check_layering.dart`).** R1: `lib/core/**` must not import
  `lib/features/**`. R2: one feature must not import another. R3: `domain/` must not import
  Flutter or platform packages.
- **Analysis is `very_good_analysis` with `strict-casts` and `strict-inference`.** Loosely
  typed code fails the analyzer. Write the types.
- **Additive only.** Every new field on an existing model is nullable or carries a default,
  because `assets/seed/v1.json` in the repo today has none of them and must keep parsing
  unchanged.
- **No user-facing strings are added by this plan.** If you find yourself writing copy shown
  to a student, you are in the wrong plan. Stop and say so.
- **No figure is invented.** Nothing here computes a number a student will read. Task 2
  assigns an `ordering` integer, which is a sort key and never printed.
- **Commit messages carry no AI attribution and no co-author trailers.** Explain why, not
  what.
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/storage/data/tables/lesson_bookmarks_local_table.dart` — one row per
  bookmarked lesson. Mirrors `question_flags_local` exactly: referenced text PK, a
  timestamp, a nullable `sortIndex` for the custom order, and a `syncState`.
- `lib/core/storage/data/repos/lesson_bookmarks_repository.dart` — set, unset, query,
  reorder. Lives in `core/storage/data/repos/` beside the other repos because the Study
  map, the sheet and the reader all read it, and a feature-local home would violate R2.
- `lib/core/sync/mapping/lesson_bookmark_mapper.dart` — the Firestore mapper, same shape
  as `QuestionFlagMapper`.
- `lib/core/ui/components/ink_chevron.dart` — the hairline chevron the row rule requires.
  Material's `Icons.chevron_right` is a filled glyph and cannot be drawn at stroke 1.4.
- `test/core/storage/data/tables/lesson_bookmarks_migration_test.dart`
- `test/core/storage/data/repos/lesson_bookmarks_repository_test.dart`
- `test/core/sync/mapping/lesson_bookmark_mapper_test.dart`
- `test/core/ui/components/ink_chevron_test.dart`

**Modify:**
- `lib/core/storage/data/tables/lessons_table.dart` — the `ordering` column.
- `lib/core/storage/data/app_database.dart` — register the table, bump `schemaVersion`
  twice across this plan (14 to 16), add two `onUpgrade` branches.
- `lib/core/storage/domain/lesson.dart` — the `ordering` field.
- `lib/core/storage/data/repos/content_repository.dart` — hydrate `ordering`, and sort
  `lessonsByTopic`.
- `lib/core/storage/data/seeder.dart` — `ordering` passthrough.
- `tools/build_dev_seed/build_dev_seed.dart` — read `ordering` from frontmatter, fall back
  to the file's position within its topic.
- `lib/core/storage/data/repos/app_preferences_repository.dart` — the two reading-position
  preferences.
- `lib/core/sync/engine/collection_registry.dart`, `lib/core/sync/bootstrap/full_push.dart`,
  `lib/core/sync/bootstrap/full_pull.dart`, `lib/core/sync/local_state_wiper.dart` — the
  four mapper registrations.
- `lib/core/ui/components/ink_table_row.dart` — reserved glyph column, chevron slot, and
  `active` stops drawing `○`.
- `test/core/ui/components/ink_table_row_test.dart` — the `○` assertion inverts.

**Deliberately not touched:**

- **`lib/core/content/tables/content_lessons.dart` and its parser.** The content database
  is a second, parallel content path with no UI reader yet, and `ContentDatabase` has an
  `onCreate` and **no `onUpgrade` at all**: bumping its `schemaVersion` against a file
  already on a device throws rather than migrates. That file is replaced wholesale by
  `SeedInstaller` when it is regenerated, so `ordering` belongs to the regeneration pass,
  not to a migration. Adding a column here would be a live defect.
- **Every widget except `InkTableRow`.** `learn_tab_home.dart`, `lesson_page.dart` and
  `lesson_list_page.dart` are Plans 2 and 4's business.
- **`content/lessons/*.md`.** Authoring `ordering:` across 141 files in 18 topics is
  editorial judgment and is Aedwon's pass, not this plan's. Task 2 makes the frontmatter
  key work and preserves today's order until he runs it.

---

## Task 1: Lessons carry an authored order

**Files:**
- Modify: `lib/core/storage/data/tables/lessons_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `lib/core/storage/domain/lesson.dart`
- Modify: `lib/core/storage/data/repos/content_repository.dart`
- Test: `test/core/storage/data/repos/content_repository_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: the column `lessons.ordering` (int, default 0), the field `Lesson.ordering`
  (int, default 0), and `ContentRepository.lessonsByTopic` returning lessons sorted by
  `ordering` then `id`. Plan 2's index and Plan 4's pull both depend on that sort.

**Why a default and not nullable.** Sorting on a nullable integer means every query carries
a `NullsOrder` and every comparison has a null branch. Zero sorts first and is the honest
"unplaced" value, which is what all 141 lessons are until the authoring pass runs.

**Why `id` is the tie-break.** Today's order is seed array order, which is the file glob,
which is alphabetical by filename slug (spec Section 0.2). Lesson ids embed that same slug,
so ordering by `id` reproduces what students see now to within a handful of rows, and after
Task 2 no two lessons in a topic share an `ordering` anyway.

- [ ] **Step 1: Write the failing test**

Add to `test/core/storage/data/repos/content_repository_test.dart`. The existing `setUp`
inserts one lesson `l1`; add a helper and three more lessons inside the tests themselves so
the existing assertions are untouched:

```dart
  Future<void> insertLesson(String id, String title, {int? ordering}) {
    return db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            topicId: 't1',
            title: title,
            summary: 'Summary of $title',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
            ordering: ordering == null ? const Value.absent() : Value(ordering),
          ),
        );
  }

  test('lessons come back in their authored order', () async {
    await insertLesson('l_c', 'Third', ordering: 3);
    await insertLesson('l_a', 'First', ordering: 1);
    await insertLesson('l_b', 'Second', ordering: 2);

    final lessons = await repo.lessonsByTopic('t1');

    // l1 from setUp has no ordering, so it defaults to 0 and sorts first.
    expect(
      lessons.map((lesson) => lesson.id).toList(),
      ['l1', 'l_a', 'l_b', 'l_c'],
    );
  });

  test('lessons with no authored order fall back to id order', () async {
    await insertLesson('l_z', 'Zulu');
    await insertLesson('l_m', 'Mike');

    final lessons = await repo.lessonsByTopic('t1');

    expect(
      lessons.map((lesson) => lesson.id).toList(),
      ['l1', 'l_m', 'l_z'],
    );
  });

  test('an unplaced lesson reports ordering zero', () async {
    final lesson = await repo.lessonById('l1');

    expect(lesson!.ordering, 0);
  });
```

The file already imports `dart:convert`. Add the drift import for `Value`:

```dart
import 'package:drift/drift.dart' hide isNull;
```

`drift` exports an `isNull` that collides with `flutter_test`'s matcher, which is why the
`hide` is required. Without it the file will not compile and the error is unhelpful.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/repos/content_repository_test.dart`
Expected: FAIL. `ordering` is not a named parameter of `LessonsCompanion.insert`.

- [ ] **Step 3: Add the column**

In `lib/core/storage/data/tables/lessons_table.dart`, add after `estimatedMinutes`:

```dart
  /// The authored teaching sequence within a topic. Zero means unplaced, which
  /// every lesson is until the editorial pass over the corpus runs. With the
  /// reader's pull advancing forward only, this is the sole guidance a student
  /// gets about where to begin, so it is load-bearing rather than cosmetic.
  IntColumn get ordering => integer().withDefault(const Constant(0))();
```

- [ ] **Step 4: Migrate**

In `lib/core/storage/data/app_database.dart`, bump the version to 15:

```dart
  @override
  int get schemaVersion => 15;
```

and add the branch at the end of `onUpgrade`, after the `from < 14` branch:

```dart
          if (from < 15) {
            await m.addColumn(lessons, lessons.ordering);
          }
```

- [ ] **Step 5: Add the domain field**

In `lib/core/storage/domain/lesson.dart`, add after `subtopicId`, which is the last
parameter today:

```dart
    @Default(0) int ordering,
```

`@Default` comes from `freezed_annotation`, which the file already imports, and
`attempt.dart:41` uses it the same way.

- [ ] **Step 6: Hydrate it and sort the query**

In `lib/core/storage/data/repos/content_repository.dart`, add the drift import at the top,
keeping the imports alphabetical:

```dart
import 'package:drift/drift.dart';
```

Add `ordering: r.ordering,` to `_hydrateLesson`, after `estimatedMinutes`.

Replace `lessonsByTopic` in full:

```dart
  Future<List<Lesson>> lessonsByTopic(TopicId topicId) async {
    final rows = await (_db.select(_db.lessons)
          ..where((l) => l.topicId.equals(topicId))
          ..orderBy([
            (l) => OrderingTerm.asc(l.ordering),
            // Unplaced lessons all share ordering 0. Their ids embed the
            // filename slug, so this reproduces the order students see today.
            (l) => OrderingTerm.asc(l.id),
          ]))
        .get();
    return rows.map(_hydrateLesson).toList();
  }
```

- [ ] **Step 7: Regenerate and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/core/storage/data/repos/content_repository_test.dart`
Expected: PASS, 10 tests.

- [ ] **Step 8: Run the storage suite**

Run: `flutter test test/core/storage/`
Expected: PASS. `Lesson` gained a defaulted field, so nothing that builds one breaks.

- [ ] **Step 9: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): lessons can hold an authored order

The order students see is the file glob, alphabetical by slug, which put
Sets and Set Notation at 8 of 11 by luck. With the reader's pull going
forward only, the authored sequence is the only guidance anyone gets."
```

---

## Task 2: The seed carries the order

**Files:**
- Modify: `lib/core/storage/data/seeder.dart`
- Modify: `tools/build_dev_seed/build_dev_seed.dart`
- Test: `test/core/storage/data/seeder_test.dart`

**Interfaces:**
- Consumes: `lessons.ordering` from Task 1.
- Produces: `Seeder` passthrough from `l['ordering']`, and a dev seed builder that emits an
  `ordering` for every lesson. No new public API.

**The fallback is the point.** Not one of the 141 lesson files carries `ordering:` today.
If the builder emitted nothing, every lesson would land on 0 and the map would sort by id,
which is a change nobody asked for. Instead the builder numbers each topic's files from 1
in glob order, which is exactly the order students see now, and a frontmatter `ordering:`
overrides it wherever Aedwon has authored one.

**This is a sort key, never a printed figure.** It is not a difficulty, a position badge or
a "lesson 3 of 9" a student reads. Plan 2 prints read fractions, which are counted.

- [ ] **Step 1: Write the failing test**

`test/core/storage/data/seeder_test.dart` seeds from the real bundle. Add a fixture bundle
beside the existing tests, in the same shape `question_flags` used when it needed one:

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

const _orderingFixture = '''
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
      "id": "l1", "topicId": "t1", "title": "Placed second",
      "summary": "S.", "bodyJson": [], "estimatedMinutes": 5, "ordering": 2
    },
    {
      "id": "l2", "topicId": "t1", "title": "Unplaced",
      "summary": "S.", "bodyJson": [], "estimatedMinutes": 5
    }
  ],
  "questions": []
}
''';
```

Add the imports it needs at the top of the file: `dart:convert`, `dart:typed_data`, and
`package:flutter/services.dart` if they are not already there.

Then the two tests:

```dart
  test('a lesson carries its ordering when the seed provides one', () async {
    await Seeder(db, bundle: _FixtureBundle(_orderingFixture)).maybeSeed();

    final row = await (db.select(db.lessons)..where((l) => l.id.equals('l1')))
        .getSingle();

    expect(row.ordering, 2);
  });

  test('a lesson with no ordering in the seed stores zero', () async {
    await Seeder(db, bundle: _FixtureBundle(_orderingFixture)).maybeSeed();

    final row = await (db.select(db.lessons)..where((l) => l.id.equals('l2')))
        .getSingle();

    expect(row.ordering, 0);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/seeder_test.dart`
Expected: FAIL. `row.ordering` is 0 for `l1`, because the seeder drops the key.

- [ ] **Step 3: Pass it through the seeder**

In `lib/core/storage/data/seeder.dart`, add to the `LessonsCompanion.insert` call, after
`estimatedMinutes`:

```dart
                ordering: Value(l['ordering'] as int? ?? 0),
```

`Value` comes from `package:drift/drift.dart`, which the seeder already imports.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/storage/data/seeder_test.dart`
Expected: PASS.

- [ ] **Step 5: Emit an ordering from the dev seed builder**

In `tools/build_dev_seed/build_dev_seed.dart`, replace `_buildLessons` in full. The two
changes are the `orderingByTopic` counter and the `'ordering'` key:

```dart
List<Map<String, Object?>> _buildLessons(Map<String, String> topicIdBySlug) {
  final lessons = <Map<String, Object?>>[];

  // Not one lesson file carries `ordering:` yet. Numbering each topic's files
  // in glob order preserves exactly what students see today, and a frontmatter
  // `ordering:` overrides it wherever the editorial pass has run.
  final nextOrdering = <String, int>{};

  for (final file in _filesUnder('content/lessons', '.md')) {
    final source = file.readAsStringSync();
    final match =
        RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(source);
    if (match == null) {
      stderr.writeln('${file.path}: missing frontmatter');
      exitCode = 65;
      continue;
    }
    final front = loadYaml(match.group(1)!) as YamlMap;
    if (front['isActive'] == false) continue;

    final topicSlug = (front['topic'] as String).replaceFirst('topic-', '');
    final topicId = topicIdBySlug[topicSlug];
    if (topicId == null) {
      stderr.writeln('${file.path}: no outline topic for "$topicSlug"');
      exitCode = 65;
      continue;
    }

    final fallback = (nextOrdering[topicId] ?? 0) + 1;
    nextOrdering[topicId] = fallback;

    lessons.add({
      'id': front['_id'] as String,
      'topicId': topicId,
      'title': front['title'] as String,
      'summary': front['summary'] as String,
      'estimatedMinutes': front['estimatedMinutes'] as int,
      'ordering': front['ordering'] as int? ?? fallback,
      'bodyJson': _markdownToPortableText(source.substring(match.end)),
    });
  }

  return lessons;
}
```

**Do not regenerate `assets/seed/v1.json` in this task.** It is a 6 MB generated artifact,
regenerating it belongs to a content pass, and a diff of it inside a foundations commit
would bury everything else. The builder is correct from this commit forward.

- [ ] **Step 6: Verify the builder compiles**

Run: `dart analyze tools/build_dev_seed/build_dev_seed.dart`
Expected: no issues. `tools/` is excluded from the repo's analyzer gate, so this is a
direct check rather than part of `flutter analyze`.

- [ ] **Step 7: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage/data/seeder.dart \
        tools/build_dev_seed/build_dev_seed.dart \
        test/core/storage/data/seeder_test.dart
git commit -m "feat(content): the seed builder numbers lessons within a topic

Frontmatter wins where it exists. The glob-order fallback keeps today's
sequence intact so the column can land before the editorial pass does."
```

---

## Task 3: The `lesson_bookmarks_local` table

**Files:**
- Create: `lib/core/storage/data/tables/lesson_bookmarks_local_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Test: `test/core/storage/data/tables/lesson_bookmarks_migration_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: the Drift getter `db.lessonBookmarksLocal`, the row class
  `LessonBookmarkLocalRow` with fields `lessonId` (String), `markedAt` (DateTime),
  `sortIndex` (int?), `syncState` (String), and the companion
  `LessonBookmarksLocalCompanion`. Tasks 4 and 5 depend on these exact names.

**It may not live on `lesson_progress_local`.** That table's `readAt` is non-nullable and a
row there means "read". Bookmarking an unread lesson would require making it nullable and
changing what every existing row means. Spec Section 7 states this outright.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/data/tables/lesson_bookmarks_migration_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  test('new installs create the lesson bookmarks table', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final tables = await db
        .customSelect(
          "select name from sqlite_master where type = 'table' "
          "and name = 'lesson_bookmarks_local'",
        )
        .get();

    expect(
      tables.map((row) => row.read<String>('name')).toList(),
      equals(['lesson_bookmarks_local']),
    );
  });

  test('a bookmark row round-trips with a null sort index', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    final markedAt = DateTime.utc(2026, 8, 2, 9, 30);
    await db.into(db.lessonBookmarksLocal).insert(
          LessonBookmarksLocalCompanion.insert(
            lessonId: 'l1',
            markedAt: markedAt,
          ),
        );

    final rows = await db.select(db.lessonBookmarksLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.lessonId, 'l1');
    expect(rows.single.markedAt, markedAt);
    expect(rows.single.sortIndex, isNull);
    expect(rows.single.syncState, 'pending');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/tables/lesson_bookmarks_migration_test.dart`
Expected: FAIL. The analyzer reports that `lessonBookmarksLocal` is not defined for
`AppDatabase`.

- [ ] **Step 3: Create the table**

Create `lib/core/storage/data/tables/lesson_bookmarks_local_table.dart`:

```dart
// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/lessons_table.dart';
import 'package:drift/drift.dart';

/// A lesson the student marked to come back to. Separate from
/// `lesson_progress_local` on purpose: a row there means "read", and its
/// `readAt` is non-nullable, so bookmarking an unread lesson would change what
/// every existing progress row means.
@DataClassName('LessonBookmarkLocalRow')
class LessonBookmarksLocal extends Table {
  TextColumn get lessonId => text().references(Lessons, #id)();
  DateTimeColumn get markedAt => dateTime()();

  /// The student's hand ordering. Null until someone drags, which is why the
  /// default Recent order needs no writes at all.
  IntColumn get sortIndex => integer().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {lessonId};
}
```

- [ ] **Step 4: Register the table and bump the schema**

In `lib/core/storage/data/app_database.dart`, add the import beside the other table
imports, keeping them alphabetical (it sorts directly before `lessons_table.dart`):

```dart
import 'package:cse_cet_reviewer/core/storage/data/tables/lesson_bookmarks_local_table.dart';
```

Add `LessonBookmarksLocal,` to the `tables:` list, after `Lessons,`.

Change the schema version to 16 and add the branch at the end of `onUpgrade`:

```dart
          if (from < 16) {
            await m.createTable(lessonBookmarksLocal);
          }
```

- [ ] **Step 5: Regenerate and run the test**

Run: `dart run build_runner build --delete-conflicting-outputs`
Then: `flutter test test/core/storage/data/tables/lesson_bookmarks_migration_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage/data/tables/lesson_bookmarks_local_table.dart \
        lib/core/storage/data/app_database.dart \
        test/core/storage/data/tables/lesson_bookmarks_migration_test.dart
git commit -m "feat(storage): bookmarks get a table of their own

lesson_progress_local cannot hold them: a row there means read, and its
readAt is non-nullable, so an unread bookmark would rewrite the meaning
of every row already on a device."
```

---

## Task 4: `LessonBookmarksRepository`

**Files:**
- Create: `lib/core/storage/data/repos/lesson_bookmarks_repository.dart`
- Test: `test/core/storage/data/repos/lesson_bookmarks_repository_test.dart`

**Interfaces:**
- Consumes: `db.lessonBookmarksLocal`, `LessonBookmarksLocalCompanion`,
  `LessonBookmarkLocalRow` from Task 3.
- Produces: `LessonBookmarksRepository(AppDatabase db)` with
  `Future<void> mark(LessonId)`, `Future<void> unmark(LessonId)`,
  `Future<void> unmarkAll(Iterable<LessonId>)`, `Future<bool> isMarked(LessonId)`,
  `Future<Set<LessonId>> markedIds()`, `Future<List<LessonBookmarkLocalRow>> recentFirst()`,
  `Future<List<LessonBookmarkLocalRow>> oldestFirst()`,
  `Future<List<LessonBookmarkLocalRow>> customOrder()`,
  `Future<void> reorder(List<LessonId> lessonIdsInOrder)`,
  `Future<void> clearCustomOrder()`, and `Future<int> count()`. Plan 3's sheet calls every
  one of these; Plan 2's head section calls `recentFirst` and `count`; Plan 4's reader
  calls `mark`, `unmark` and `isMarked`.

**Why "By subject" is not here.** That order needs the subject and topic of each lesson,
which lives in `ContentRepository`, and a repository in `core/storage/data/repos/` that
reaches across to another repository to sort is the wrong seam. Plan 3 composes it in a
provider from `markedIds()` and the exam's subject tree.

**A new bookmark lands at the top in Custom.** Spec Section 3: appending to the bottom of a
hand-sorted list makes a fresh bookmark invisible. `mark()` therefore writes a `sortIndex`
one below the current minimum whenever any row already carries one, and null otherwise.

- [ ] **Step 1: Write the failing test**

Create `test/core/storage/data/repos/lesson_bookmarks_repository_test.dart`. The `lessonId`
column references `Lessons`, so seed the exam, subject, topic and lesson chain first,
exactly as `lesson_progress_repository_test.dart` seeds its own:

```dart
import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late LessonBookmarksRepository repo;

  Future<void> insertLesson(String id) {
    return db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            topicId: 't1',
            title: 'Lesson $id',
            summary: 'Summary',
            bodyJson: jsonEncode(<Map<String, Object?>>[]),
            estimatedMinutes: 5,
          ),
        );
  }

  setUp(() async {
    db = inMemoryDatabase();
    repo = LessonBookmarksRepository(db);

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
    await insertLesson('l1');
    await insertLesson('l2');
    await insertLesson('l3');
  });

  tearDown(() => db.close());

  test('marking a lesson bookmarks it', () async {
    await repo.mark('l1');

    expect(await repo.isMarked('l1'), isTrue);
    expect(await repo.isMarked('l2'), isFalse);
    expect(await repo.count(), 1);
    expect(await repo.markedIds(), {'l1'});
  });

  test('marking twice keeps one row and refreshes the timestamp', () async {
    await repo.mark('l1');
    final first = (await db.select(db.lessonBookmarksLocal).get()).single.markedAt;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l1');

    final rows = await db.select(db.lessonBookmarksLocal).get();
    expect(rows, hasLength(1));
    expect(rows.single.markedAt.isAfter(first), isTrue);
  });

  test('unmarking removes the row, and unmarking nothing is a no-op', () async {
    await repo.mark('l1');
    await repo.unmark('l1');
    await repo.unmark('l2');

    expect(await repo.isMarked('l1'), isFalse);
    expect(await repo.count(), 0);
  });

  test('unmarkAll removes several at once', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.mark('l3');

    await repo.unmarkAll(['l1', 'l3']);

    expect(await repo.markedIds(), {'l2'});
  });

  test('recent order is newest first and oldest order is its reverse', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l2');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l3');

    expect(
      (await repo.recentFirst()).map((row) => row.lessonId).toList(),
      ['l3', 'l2', 'l1'],
    );
    expect(
      (await repo.oldestFirst()).map((row) => row.lessonId).toList(),
      ['l1', 'l2', 'l3'],
    );
  });

  test('reorder writes a custom order that survives a re-read', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.mark('l3');

    await repo.reorder(['l3', 'l1', 'l2']);

    expect(
      (await repo.customOrder()).map((row) => row.lessonId).toList(),
      ['l3', 'l1', 'l2'],
    );
  });

  test('a new bookmark lands at the top of a custom order', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.reorder(['l1', 'l2']);

    await repo.mark('l3');

    expect(
      (await repo.customOrder()).map((row) => row.lessonId).toList(),
      ['l3', 'l1', 'l2'],
    );
  });

  test('custom order falls back to recency for unplaced rows', () async {
    await repo.mark('l1');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.mark('l2');
    await repo.reorder(['l2']);

    // l1 was never placed by hand, so it sorts after the one that was.
    expect(
      (await repo.customOrder()).map((row) => row.lessonId).toList(),
      ['l2', 'l1'],
    );
  });

  test('clearing the custom order drops every sort index', () async {
    await repo.mark('l1');
    await repo.mark('l2');
    await repo.reorder(['l2', 'l1']);

    await repo.clearCustomOrder();

    final rows = await db.select(db.lessonBookmarksLocal).get();
    expect(rows.every((row) => row.sortIndex == null), isTrue);
  });

  test('a new bookmark is pending sync', () async {
    await repo.mark('l1');

    expect((await db.select(db.lessonBookmarksLocal).get()).single.syncState,
        'pending');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/repos/lesson_bookmarks_repository_test.dart`
Expected: FAIL. `lesson_bookmarks_repository.dart` does not exist.

- [ ] **Step 3: Write the repository**

Create `lib/core/storage/data/repos/lesson_bookmarks_repository.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/sync_state.dart';
import 'package:drift/drift.dart';

/// Lessons the student marked to come back to. Ordering by subject is not here
/// on purpose: it needs the subject tree, which lives in `ContentRepository`,
/// and is composed a layer up.
class LessonBookmarksRepository {
  LessonBookmarksRepository(this._db);

  final AppDatabase _db;

  /// Marks a lesson. In a hand-sorted list the new row lands at the top:
  /// appending a fresh bookmark to the bottom of a list someone arranged makes
  /// it invisible, which defeats the point of marking it.
  Future<void> mark(LessonId lessonId) async {
    final placed = await _minimumSortIndex();
    await _db.into(_db.lessonBookmarksLocal).insertOnConflictUpdate(
          LessonBookmarksLocalCompanion(
            lessonId: Value(lessonId),
            markedAt: Value(DateTime.now()),
            sortIndex: placed == null ? const Value(null) : Value(placed - 1),
            syncState: Value(SyncState.pending.name),
          ),
        );
  }

  Future<void> unmark(LessonId lessonId) async {
    await (_db.delete(_db.lessonBookmarksLocal)
          ..where((row) => row.lessonId.equals(lessonId)))
        .go();
  }

  Future<void> unmarkAll(Iterable<LessonId> lessonIds) async {
    final ids = lessonIds.toList();
    if (ids.isEmpty) return;
    await (_db.delete(_db.lessonBookmarksLocal)
          ..where((row) => row.lessonId.isIn(ids)))
        .go();
  }

  Future<bool> isMarked(LessonId lessonId) async {
    final row = await (_db.select(_db.lessonBookmarksLocal)
          ..where((bookmark) => bookmark.lessonId.equals(lessonId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<LessonId>> markedIds() async {
    final rows = await _db.select(_db.lessonBookmarksLocal).get();
    return rows.map((row) => row.lessonId).toSet();
  }

  Future<List<LessonBookmarkLocalRow>> recentFirst() {
    return (_db.select(_db.lessonBookmarksLocal)
          ..orderBy([(row) => OrderingTerm.desc(row.markedAt)]))
        .get();
  }

  Future<List<LessonBookmarkLocalRow>> oldestFirst() {
    return (_db.select(_db.lessonBookmarksLocal)
          ..orderBy([(row) => OrderingTerm.asc(row.markedAt)]))
        .get();
  }

  /// Hand-placed rows first, in the order they were placed. A row nobody
  /// dragged has a null `sortIndex` and falls back to recency behind them,
  /// which is why switching to Custom never scrambles the list.
  Future<List<LessonBookmarkLocalRow>> customOrder() {
    return (_db.select(_db.lessonBookmarksLocal)
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.sortIndex,
                  nulls: NullsOrder.last,
                ),
            (row) => OrderingTerm.desc(row.markedAt),
          ]))
        .get();
  }

  Future<void> reorder(List<LessonId> lessonIdsInOrder) async {
    await _db.transaction(() async {
      for (var index = 0; index < lessonIdsInOrder.length; index++) {
        await (_db.update(_db.lessonBookmarksLocal)
              ..where((row) => row.lessonId.equals(lessonIdsInOrder[index])))
            .write(
          LessonBookmarksLocalCompanion(
            sortIndex: Value(index),
            syncState: Value(SyncState.pending.name),
          ),
        );
      }
    });
  }

  Future<void> clearCustomOrder() async {
    await _db.update(_db.lessonBookmarksLocal).write(
          LessonBookmarksLocalCompanion(
            sortIndex: const Value(null),
            syncState: Value(SyncState.pending.name),
          ),
        );
  }

  Future<int> count() async {
    final total = _db.lessonBookmarksLocal.lessonId.count();
    final query = _db.selectOnly(_db.lessonBookmarksLocal)..addColumns([total]);
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  Future<int?> _minimumSortIndex() async {
    final smallest = _db.lessonBookmarksLocal.sortIndex.min();
    final query = _db.selectOnly(_db.lessonBookmarksLocal)
      ..addColumns([smallest]);
    final row = await query.getSingle();
    return row.read(smallest);
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/storage/data/repos/lesson_bookmarks_repository_test.dart`
Expected: PASS, 11 tests.

- [ ] **Step 5: Expose it as a provider**

In `lib/core/storage/storage.dart`, add the import beside the other repo imports and this
provider directly after `lessonProgressRepositoryProvider`:

```dart
final lessonBookmarksRepositoryProvider = Provider<LessonBookmarksRepository>(
  (ref) => LessonBookmarksRepository(ref.watch(appDatabaseProvider)),
);
```

Do not add a `FutureProvider` for the list here. Which order the list comes back in is the
sheet's decision, and Plan 3 owns it.

- [ ] **Step 6: Check layering, format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): read and write lesson bookmarks

A new bookmark lands at the top of a hand-sorted list rather than the
bottom, because a fresh mark appended below twenty others is invisible."
```

---

## Task 5: Sync the bookmarks

**Files:**
- Create: `lib/core/sync/mapping/lesson_bookmark_mapper.dart`
- Modify: `lib/core/sync/engine/collection_registry.dart`
- Modify: `lib/core/sync/bootstrap/full_push.dart`
- Modify: `lib/core/sync/bootstrap/full_pull.dart`
- Modify: `lib/core/sync/local_state_wiper.dart`
- Test: `test/core/sync/mapping/lesson_bookmark_mapper_test.dart`

**Interfaces:**
- Consumes: `LessonBookmarkLocalRow`, `LessonBookmarksLocalCompanion` from Task 3.
- Produces: `LessonBookmarkMapper` with `documentId`, `toFirestore`, `fromFirestore` and
  `toCompanion`, and the collection `tableType` and `firestorePath` string
  `'lesson_bookmarks'`.

A mapper is registered in **four** places and missing one is silent. All four are in this
task on purpose.

- [ ] **Step 1: Write the failing test**

Create `test/core/sync/mapping/lesson_bookmark_mapper_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/engine/collection_registry.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/lesson_bookmark_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = LessonBookmarkMapper();

  test('a bookmark row becomes a firestore document', () {
    final doc = mapper.toFirestore(
      LessonBookmarkLocalRow(
        lessonId: 'l1',
        markedAt: DateTime.utc(2026, 8, 2, 9, 30),
        sortIndex: 3,
        syncState: 'pending',
      ),
      updatedAt: DateTime.utc(2026, 8, 2, 10),
      originDeviceId: 'device-1',
    );

    expect(doc, {
      'lessonId': 'l1',
      'markedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': 3,
      'updatedAt': '2026-08-02T10:00:00.000Z',
      'originDeviceId': 'device-1',
      'schemaVersion': 1,
    });
  });

  test('a firestore document becomes a synced bookmark row', () {
    final row = mapper.fromFirestore({
      'lessonId': 'l1',
      'markedAt': '2026-08-02T09:30:00.000Z',
      'sortIndex': null,
    });

    expect(row.lessonId, 'l1');
    expect(row.markedAt, DateTime.utc(2026, 8, 2, 9, 30));
    expect(row.sortIndex, isNull);
    expect(row.syncState, 'synced');
  });

  test('the document id is the lesson id', () {
    expect(
      mapper.documentId(
        LessonBookmarkLocalRow(
          lessonId: 'l7',
          markedAt: DateTime.utc(2026, 8, 2),
          syncState: 'pending',
        ),
      ),
      'l7',
    );
  });

  test('lesson bookmarks are an active sync collection', () {
    final entry = activeSyncCollections
        .firstWhere((entry) => entry.tableType == 'lesson_bookmarks');

    expect(entry.firestorePath, 'lesson_bookmarks');
    expect(entry.mapper, isA<LessonBookmarkMapper>());
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/sync/mapping/lesson_bookmark_mapper_test.dart`
Expected: FAIL. `lesson_bookmark_mapper.dart` does not exist.

- [ ] **Step 3: Write the mapper**

Create `lib/core/sync/mapping/lesson_bookmark_mapper.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/mapping/sync_mapper.dart';
import 'package:drift/drift.dart';

class LessonBookmarkMapper implements SyncMapper {
  const LessonBookmarkMapper();

  static const schemaVersion = 1;

  @override
  String get name => 'lesson_bookmarks';

  String documentId(LessonBookmarkLocalRow row) => row.lessonId;

  Map<String, Object?> toFirestore(
    LessonBookmarkLocalRow row, {
    required DateTime updatedAt,
    required String originDeviceId,
  }) {
    return {
      'lessonId': row.lessonId,
      'markedAt': row.markedAt.toUtc().toIso8601String(),
      'sortIndex': row.sortIndex,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'originDeviceId': originDeviceId,
      'schemaVersion': schemaVersion,
    };
  }

  LessonBookmarkLocalRow fromFirestore(Map<String, Object?> doc) {
    return LessonBookmarkLocalRow(
      lessonId: doc['lessonId']! as String,
      markedAt: DateTime.parse(doc['markedAt']! as String),
      sortIndex: doc['sortIndex'] as int?,
      syncState: 'synced',
    );
  }

  LessonBookmarksLocalCompanion toCompanion(LessonBookmarkLocalRow row) {
    return LessonBookmarksLocalCompanion(
      lessonId: Value(row.lessonId),
      markedAt: Value(row.markedAt),
      sortIndex: Value(row.sortIndex),
      syncState: Value(row.syncState),
    );
  }
}
```

- [ ] **Step 4: Register it in the collection registry**

In `lib/core/sync/engine/collection_registry.dart`, add the import beside the others, then
this entry to `syncCollections` after the `lesson_progress` entry:

```dart
  SyncCollectionEntry(
    tableType: 'lesson_bookmarks',
    firestorePath: 'lesson_bookmarks',
    mapper: LessonBookmarkMapper(),
  ),
```

- [ ] **Step 5: Register it in the full push**

In `lib/core/sync/bootstrap/full_push.dart`, add the import, then declare the mapper in
`_buildWrites` beside the others:

```dart
    const lessonBookmarks = LessonBookmarkMapper();
```

Add this collection literal entry after the `lesson_progress` loop:

```dart
      for (final row in await _db.select(_db.lessonBookmarksLocal).get())
        FirestoreWrite.set(
          path:
              'users/$_uid/lesson_bookmarks/${lessonBookmarks.documentId(row)}',
          data: lessonBookmarks.toFirestore(
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
      await _db.delete(_db.lessonBookmarksLocal).go();
```

In `_applyCloudRows`, add this block after the `questionFlags` block:

```dart
    const lessonBookmarks = LessonBookmarkMapper();
    for (final doc
        in await _gateway.readCollection('users/$_uid/lesson_bookmarks')) {
      await _db.into(_db.lessonBookmarksLocal).insertOnConflictUpdate(
            lessonBookmarks.toCompanion(lessonBookmarks.fromFirestore(doc)),
          );
    }
```

- [ ] **Step 7: Register it in the local state wiper**

In `lib/core/sync/local_state_wiper.dart`, add this delete inside the `wipeAll`
transaction, after the `questionFlagsLocal` delete on line 34:

```dart
      await _db.delete(_db.lessonBookmarksLocal).go();
```

Leave `hasMeaningfulProgress` alone. A bookmark with no read behind it is not progress worth
warning about, and the checks already there cover every case where it would be.

- [ ] **Step 8: Run the sync suite**

Run: `flutter test test/core/sync/`
Expected: PASS, including the 4 new tests. If an existing full-push or full-pull test
asserts an exact write count, it will fail: update it to include the new collection, and say
so in the commit message.

- [ ] **Step 9: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/sync test/core/sync
git commit -m "feat(sync): carry lesson bookmarks between devices

A bookmark is a judgment about a lesson someone did not absorb. Losing
it on reinstall would be worse than never offering the mark."
```

---

## Task 6: Where the student was, per exam

**Files:**
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Test: `test/core/storage/data/repos/app_preferences_repository_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: on `AppPreferencesRepository`,
  `Future<List<String>> recentlyOpenedLessonIds(String examId)` (newest first, at most
  three), `Future<String?> lastOpenedLessonId(String examId)` (the head of that list, or
  null), `Future<void> pushOpenedLesson({required String examId, required String lessonId})`,
  `Future<String?> openTopicId(String examId)`, and
  `Future<void> setOpenTopicId({required String examId, required String? topicId})`, where
  a null `topicId` clears the row. Plan 2 reads the head; Plan 3b's empty search state reads
  all three; Plan 4 writes them.

**Why a list of three and not one id.** Plan 2's "Last opened" row needs the head, and this
looked like a single value. **Plan 3b's search needs the last three**: the spec's empty
search state is a "Recently opened" kicker over the last three lessons opened. Storing one
id would have made that unbuildable without a second migration. Three is the cap because
three is all any surface draws.

**Device preferences, not account preferences, and that is a choice with a cost.**
`PreferencesMapper` syncs `account_prefs` only, so these two do not follow a student to a
second device: signing in on a tablet opens the Study tab collapsed rather than where the
phone was. That is the right trade. "Which topic is expanded" is a property of a screen on
a device, and syncing it would mean a tablet silently scrolling because a phone was tapped.
Moving them later is two lines and a mapper entry if Aedwon disagrees.

**Keyed per exam.** A student switching exams must not resume the other exam's lesson. The
keys are `recent_lessons_<examId>` and `open_topic_<examId>`. The recent list is stored as
ids joined by commas: lesson ids are slugs and contain no comma, and a JSON array in a
preferences table that holds strings buys nothing here.

**No legacy fallback.** Unlike `selectedExamId`, these keys never existed in
`app_preferences_local`, so reading it would be dead code.

- [ ] **Step 1: Write the failing test**

Add to `test/core/storage/data/repos/app_preferences_repository_test.dart`:

```dart
  test('the last opened lesson round-trips per exam', () async {
    expect(await repo.lastOpenedLessonId('e1'), isNull);

    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');
    await repo.pushOpenedLesson(examId: 'e2', lessonId: 'l9');

    expect(await repo.lastOpenedLessonId('e1'), 'l1');
    expect(await repo.lastOpenedLessonId('e2'), 'l9');
  });

  test('opening a second lesson puts it at the head', () async {
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l2');

    expect(await repo.lastOpenedLessonId('e1'), 'l2');
    expect(await repo.recentlyOpenedLessonIds('e1'), ['l2', 'l1']);
  });

  test('the recent list keeps three and drops the oldest', () async {
    for (final id in ['l1', 'l2', 'l3', 'l4']) {
      await repo.pushOpenedLesson(examId: 'e1', lessonId: id);
    }

    expect(await repo.recentlyOpenedLessonIds('e1'), ['l4', 'l3', 'l2']);
  });

  test('reopening a lesson moves it to the head without duplicating it',
      () async {
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l2');
    await repo.pushOpenedLesson(examId: 'e1', lessonId: 'l1');

    expect(await repo.recentlyOpenedLessonIds('e1'), ['l1', 'l2']);
  });

  test('an exam nobody has opened has no recent lessons', () async {
    expect(await repo.recentlyOpenedLessonIds('e1'), isEmpty);
  });

  test('the open topic round-trips per exam', () async {
    expect(await repo.openTopicId('e1'), isNull);

    await repo.setOpenTopicId(examId: 'e1', topicId: 't1');

    expect(await repo.openTopicId('e1'), 't1');
    expect(await repo.openTopicId('e2'), isNull);
  });

  test('collapsing the open topic clears it', () async {
    await repo.setOpenTopicId(examId: 'e1', topicId: 't1');

    await repo.setOpenTopicId(examId: 'e1', topicId: null);

    expect(await repo.openTopicId('e1'), isNull);
  });
```

If that test file does not already declare `repo` and `db` in a `setUp`, follow the shape of
`lesson_progress_repository_test.dart`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/repos/app_preferences_repository_test.dart`
Expected: FAIL. The method `lastOpenedLessonId` is not defined.

- [ ] **Step 3: Add the keys and the accessors**

In `lib/core/storage/data/repos/app_preferences_repository.dart`, add the two key prefixes
beside the existing constants:

```dart
  static const _recentLessonsPrefix = 'recent_lessons_';
  static const _openTopicPrefix = 'open_topic_';
  static const _recentLessonsKept = 3;
```

and these methods at the end of the class:

```dart
  /// The lessons most recently opened for this exam, newest first, at most
  /// three. Device-local on purpose: only `account_prefs` sync, and where
  /// someone was reading is a property of one screen on one device.
  Future<List<String>> recentlyOpenedLessonIds(String examId) async {
    final raw = await _deviceValue('$_recentLessonsPrefix$examId');
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(',');
  }

  Future<String?> lastOpenedLessonId(String examId) async {
    final recent = await recentlyOpenedLessonIds(examId);
    return recent.isEmpty ? null : recent.first;
  }

  /// Moves [lessonId] to the head. Reopening something already in the list
  /// moves it rather than duplicating it, so three entries always name three
  /// lessons.
  Future<void> pushOpenedLesson({
    required String examId,
    required String lessonId,
  }) async {
    // A copy: the getter returns a const list when nothing is stored, and
    // removing from that throws.
    final recent = [...await recentlyOpenedLessonIds(examId)]
      ..remove(lessonId);
    final next = [lessonId, ...recent].take(_recentLessonsKept);
    await _setDeviceValue(
      '$_recentLessonsPrefix$examId',
      next.join(','),
    );
  }

  Future<String?> openTopicId(String examId) =>
      _deviceValue('$_openTopicPrefix$examId');

  /// A null [topicId] means the student collapsed the topic, so the row goes
  /// rather than storing an empty string that every reader has to special-case.
  Future<void> setOpenTopicId({
    required String examId,
    required String? topicId,
  }) async {
    final key = '$_openTopicPrefix$examId';
    if (topicId == null) {
      await (_db.delete(_db.devicePrefs)..where((p) => p.key.equals(key))).go();
      return;
    }
    await _setDeviceValue(key, topicId);
  }

  Future<String?> _deviceValue(String key) async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _setDeviceValue(String key, String value) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(key: key, value: value),
        );
  }
```

The file does not import drift today and now needs it for the `delete` builder:

```dart
import 'package:drift/drift.dart';
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/storage/data/repos/app_preferences_repository_test.dart`
Expected: PASS, including the 4 new tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage/data/repos/app_preferences_repository.dart \
        test/core/storage/data/repos/app_preferences_repository_test.dart
git commit -m "feat(storage): remember the recent lessons and the open topic per exam

Three rather than one, because search's empty state offers the last
three opened. Keyed by exam so switching never resumes the other one."
```

---

## Task 7: The row kit learns chevrons and a reserved gutter

**Files:**
- Create: `lib/core/ui/components/ink_chevron.dart`
- Modify: `lib/core/ui/components/ink_table_row.dart`
- Test: `test/core/ui/components/ink_chevron_test.dart`
- Test: `test/core/ui/components/ink_table_row_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `InkChevron({double size = 12, bool pointsDown = false})`, the enum
  `InkRowChevron { none, link, disclosure }`, and two new `InkTableRow` parameters:
  `chevron` (defaults to `InkRowChevron.none`) and `reserveGlyph` (defaults to false), plus
  `expanded` (defaults to false) which rotates a disclosure chevron. Plans 2, 3 and 5 all
  build rows with these.

**Three changes, from spec Section 6:**

1. A chevron marks a row that does something when tapped. One that rotates is a disclosure;
   one that does not is a link. 12px, stroke 1.4, `inkMuted`. This amends the earlier 1.2px
   figure.
2. The glyph column is reserved for a whole list, not per row, so titles align down the page
   whether or not a given row carries a glyph. Today it is reserved only when
   `state != plain`, which shifts titles by 22px and is why a started topic looked wrong.
3. `InkRowState.active` stops rendering `○`. A started item is signalled by its meta, not by
   a bullet in the gutter.

**`reserveGlyph` defaults to false and that is deliberate.** Thirteen files build
`InkTableRow` today. Reserving the gutter everywhere would shift every list in the app,
including ones where no row can carry a glyph, and this plan is not a visual sweep. Study
passes `reserveGlyph: true`; nothing else changes appearance.

**One existing test inverts, and that is the point.** `ink_table_row_test.dart` asserts
`find.text('○')` is present for an active row. Change 3 deletes that glyph, so the
assertion becomes `findsNothing`. Do not preserve it.

- [ ] **Step 1: Write the failing chevron test**

Create `test/core/ui/components/ink_chevron_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/ink_chevron.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('a chevron paints at its given size', (tester) async {
    await tester.pumpWidget(harness(const InkChevron()));

    expect(tester.getSize(find.byType(InkChevron)), const Size(12, 12));
  });

  testWidgets('a downward chevron is a quarter turn from a right one',
      (tester) async {
    await tester.pumpWidget(harness(const InkChevron(pointsDown: true)));
    await tester.pumpAndSettle();

    final rotation = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(rotation.turns, 0.25);
  });

  testWidgets('a right chevron has no rotation', (tester) async {
    await tester.pumpWidget(harness(const InkChevron()));
    await tester.pumpAndSettle();

    final rotation = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(rotation.turns, 0);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/ui/components/ink_chevron_test.dart`
Expected: FAIL. `ink_chevron.dart` does not exist.

- [ ] **Step 3: Write the chevron**

Create `lib/core/ui/components/ink_chevron.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A hairline chevron. Material's `Icons.chevron_right` is a filled glyph and
/// cannot be drawn at stroke 1.4, which is what the row rule asks for.
///
/// Pointing down is a disclosure that is open; pointing right is either a
/// closed disclosure or a link.
class InkChevron extends StatelessWidget {
  const InkChevron({this.size = 12, this.pointsDown = false, super.key});

  final double size;
  final bool pointsDown;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: pointsDown ? 0.25 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: CustomPaint(
        size: Size.square(size),
        painter: _ChevronPainter(color: context.colors.inkMuted),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final brush = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Inset so the stroke's own width stays inside the box rather than
    // clipping against it.
    final inset = size.width * 0.28;
    final path = Path()
      ..moveTo(inset, inset * 0.6)
      ..lineTo(size.width - inset, size.height / 2)
      ..lineTo(inset, size.height - inset * 0.6);

    canvas.drawPath(path, brush);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}
```

- [ ] **Step 4: Run the chevron test**

Run: `flutter test test/core/ui/components/ink_chevron_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Write the failing row tests**

In `test/core/ui/components/ink_table_row_test.dart`, change the active-row test's `○`
assertion to `expect(find.text('○'), findsNothing);` and rename the test to
`'active row is semibold with no glyph and fires onTap'`. Then add three tests:

```dart
  testWidgets('a reserved gutter aligns a plain title with a done one',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const Column(
          children: [
            InkTableRow(
              title: 'Read one',
              state: InkRowState.done,
              reserveGlyph: true,
            ),
            InkTableRow(title: 'Unread one', reserveGlyph: true),
          ],
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('Unread one')).dx,
      tester.getTopLeft(find.text('Read one')).dx,
    );
  });

  testWidgets('without a reserved gutter a plain title sits further left',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const Column(
          children: [
            InkTableRow(title: 'Read one', state: InkRowState.done),
            InkTableRow(title: 'Unread one'),
          ],
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('Unread one')).dx,
      lessThan(tester.getTopLeft(find.text('Read one')).dx),
    );
  });

  testWidgets('a disclosure chevron points down when expanded',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const InkTableRow(
          title: 'Algebra',
          chevron: InkRowChevron.disclosure,
          expanded: true,
        ),
      ),
    );

    expect(tester.widget<InkChevron>(find.byType(InkChevron)).pointsDown,
        isTrue);
  });

  testWidgets('a link chevron never points down', (tester) async {
    await tester.pumpWidget(
      harness(
        const InkTableRow(
          title: 'Algebra',
          chevron: InkRowChevron.link,
          expanded: true,
        ),
      ),
    );

    expect(tester.widget<InkChevron>(find.byType(InkChevron)).pointsDown,
        isFalse);
  });
```

Add the `ink_chevron.dart` import at the top of the test file.

- [ ] **Step 6: Run the row tests to verify they fail**

Run: `flutter test test/core/ui/components/ink_table_row_test.dart`
Expected: FAIL. `reserveGlyph` and `chevron` are not named parameters, and the active row
still draws `○`.

- [ ] **Step 7: Change the row**

In `lib/core/ui/components/ink_table_row.dart`, add the import:

```dart
import 'package:cse_cet_reviewer/core/ui/components/ink_chevron.dart';
```

Add the enum below `InkRowState`:

```dart
/// A chevron marks a row that does something when tapped. One that rotates is
/// a disclosure; one that does not is a link.
enum InkRowChevron { none, link, disclosure }
```

Add three parameters to the constructor, after `state`:

```dart
    this.chevron = InkRowChevron.none,
    this.expanded = false,
    this.reserveGlyph = false,
```

and their fields, after `final InkRowState state;`:

```dart
  final InkRowChevron chevron;

  /// Only read when [chevron] is a disclosure.
  final bool expanded;

  /// Reserve the leading glyph column even on rows with no glyph, so titles
  /// align down a list where some rows carry one. A per-list decision: it is
  /// off by default so lists that can never show a glyph keep their gutter.
  final bool reserveGlyph;
```

Replace the leading-glyph block at the top of the `Row`'s children:

```dart
        if (state == InkRowState.done) ...[
          Text('✓', style: styles.bodySmall.copyWith(color: colors.board)),
          const SizedBox(width: 8),
        ] else if (reserveGlyph) ...[
          // A started row draws no glyph: the meta already says it, and a
          // bullet is the same fact told louder. The column is still held so
          // every title in the list sits on one vertical line.
          SizedBox(width: styles.bodySmall.fontSize ?? 12),
          const SizedBox(width: 8),
        ],
```

and add the trailing chevron as the last child of the `Row`:

```dart
        if (chevron != InkRowChevron.none) ...[
          const SizedBox(width: 10),
          InkChevron(
            pointsDown: chevron == InkRowChevron.disclosure && expanded,
          ),
        ],
```

The `Row` uses `CrossAxisAlignment.baseline`, and a `CustomPaint` has no baseline, so wrap
the chevron in a `Center` to keep the row from asserting:

```dart
        if (chevron != InkRowChevron.none) ...[
          const SizedBox(width: 10),
          Center(
            child: InkChevron(
              pointsDown: chevron == InkRowChevron.disclosure && expanded,
            ),
          ),
        ],
```

Use the second form. If the row still asserts on baseline alignment, **stop and say so**
rather than switching the whole row to `CrossAxisAlignment.center`, which would move every
existing list's meta column.

- [ ] **Step 8: Run the row tests**

Run: `flutter test test/core/ui/components/ink_table_row_test.dart`
Expected: PASS, 8 tests.

- [ ] **Step 9: Run the whole suite**

Run: `flutter test`
Expected: PASS. The `○` glyph is gone from every list in the app, so any widget test
elsewhere asserting on it fails and must be updated. Say which ones in the commit message.
This is the last task, so the whole suite is the gate.

- [ ] **Step 10: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/core/ui test/core/ui
git commit -m "feat(ui): rows get a hairline chevron and an optional held gutter

The circle glyph goes: a started row already says so in its meta, and the
bullet was the same fact told louder. The gutter is held per list so a
title does not jump 22px depending on whether its neighbour is read."
```

---

## What this plan deliberately does not do

Named here so a reviewer does not read them as omissions:

- **No screen changes.** `learn_tab_home.dart` still lists topic names, `lesson_page.dart`
  still has its "Mark as read" button, and `/study/topic/:topicId` still exists. Deleting
  and rebuilding them is Plan 2 and Plan 4.
- **No lesson is ordered.** Task 2 makes `ordering:` work and numbers files in glob order so
  nothing changes today. The editorial pass over 141 lessons in 18 topics is Aedwon's.
- **`assets/seed/v1.json` is not regenerated.** The builder is correct from Task 2 forward;
  the artifact is regenerated by a content pass, not by a foundations commit.
- **The content database is untouched.** `ContentDatabase` has no `onUpgrade`, so a column
  there cannot be migrated onto a device. `ordering` reaches it through regeneration.
- **No bookmark UI, and no ordering control.** The sheet, the ribbon glyph, the ink rise and
  the four order labels are Plan 3. This plan gives them somewhere to write to.
- **"By subject" order is not implemented.** It needs the subject tree and is composed in a
  provider in Plan 3, not in a storage repository.
- **Nothing reserves the glyph gutter yet.** `reserveGlyph` defaults to false, so no
  existing list moves. Plan 2 turns it on for the Study index.

## Verification

The whole plan is green when:

```bash
flutter analyze                                  # clean
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
```

And `AppDatabase.schemaVersion` reads 16, with `onUpgrade` branches for 15 and 16.

By hand, nothing. This plan has no visible surface, which is why it can go first.

## Decided without asking, reversible in one line

- **The chevron rotates over 200ms on `Curves.easeOutCubic`.** The spec gives the chevron's
  geometry but no duration for the rotation. The identity's settled constant is 400ms on
  `cubic-bezier(.22, 1, .36, 1)`, which is right for an ink rise across a whole glyph and
  slow for a 12px caret. If Aedwon wants the settled curve here too, it is one line in
  `ink_chevron.dart`.
- **Reading position is device-local.** Stated with its cost in Task 6.
