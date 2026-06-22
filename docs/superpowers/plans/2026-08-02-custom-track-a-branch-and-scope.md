# The Custom Exam Track, Plan A of 2: The Branch, the Track and What It Scopes

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

## AMENDED 3 August 2026: this plan takes schema version 16, not 15

**Conflict C2, ruled by Aedwon.** This plan and `2026-08-02-study-01-foundations.md` both
claimed **15**. Study 01 keeps 15. **This plan takes 16.**

**In Task 3 Step 3**, read `from 14 to 15` as **`from 15 to 16`**, and the migration guard
`if (from < 15)` as **`if (from < 16)`**.

**Add this step before the bump:**

- [ ] **Step 0: Confirm the current version**

```bash
grep -n "schemaVersion" lib/core/storage/data/app_database.dart
```

Expected: `int get schemaVersion => 15;`, meaning Study 01 has landed. **If it is 14, Study 01
has not run and this plan's dependency is unmet: stop and say so** rather than taking 15
yourself. If it is anything else, stop and say so.

**The bump and its migration land in the same commit**, which this plan already says.

---

**Goal:** Let a student whose exam Pantas has never heard of name it, say what it covers,
and study. Then let any student narrow what their track includes, from Settings, without
losing anything.

**Architecture:** A custom track is an ordinary exam row flagged as custom, plus an exclusion
list of topics. One new provider replaces `topicsByExam` everywhere the app asks "what is in
my exam", so listed exams and custom tracks answer the same question through the same code.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-08-02-custom-exam-track-design.md`, Sections 1
to 5, 7 and 8.

**Decision log:** `docs/superpowers/decisions/2026-08-02-onboarding-name-and-date-log.md`.

**Depends on:** `plans/2026-08-02-onboarding-flow-and-new-steps.md`, whose five-step flow this
branches out of. Do not start until that is merged.

---

## Why this is two plans

The spec covers two separable deliverables. **This one ships alone and is the whole feature
for a student who only wants to study:** they name their exam, tick their subjects, and every
surface works. **Plan B is the mock they build themselves**, which needs a setup screen,
three wheel sheets, a corpus ceiling and a locally authored blueprint, and which is useless
before this exists.

## The three design decisions this plan makes, and why

The spec settles the experience and leaves the storage open. These follow from the code.

### 1. A custom track is a row in `exams`, flagged

`selected_exam_id`, `attempts_local.examId`, `assessment_results_local.examId`,
`quiz_sessions.examId` and `mock_attempts.examId` all key on an exam id. **A parallel
"track" concept would have to be threaded through every one of them.** A flagged exam row is
threaded through none: the app already works.

`Exams` gains `isCustom`, a boolean defaulting false. The exam picker lists `!isCustom` so a
custom track never appears as a seventh exam. Everything else keys on the id and does not
care.

**`Seeder.maybeSeed` bails when any exam row exists and never deletes**, so a custom row is
safe from reseeding. Verified in `seeder.dart:14`.

### 2. Scope is an exclusion list, not an inclusion list

The spec's rule is "narrowing filters, it never purges", and it is set three times across the
2 August specs. **An exclusion list makes that literal**: a row means hidden, no rows means
everything. Re-ticking deletes the row and the content is back, along with every attempt and
every FSRS state, because nothing was ever keyed on the scope.

An inclusion list would have to be written in full for every listed exam at install, and
would silently empty a track if a content update added a topic nobody had ticked.

### 3. A custom track's subjects are the corpus's, not its own

`Subjects.examId` references an exam, so a custom exam row owns no subjects and
`topicsByExam` returns nothing for it. **A custom track ticks subjects that belong to other
exams**, which is the whole point: the corpus is shared.

So this plan introduces `scopedTopicsProvider(examId)`, which answers "what is in my exam"
for both kinds of track, and every caller of `topicsByExam` in a feature moves to it. That
also delivers Section 5's requirement that narrowing is "available to every track, not only
custom ones".

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.** `*.g.dart` is gitignored.
- **A schema bump ships with its migration in the same change.** The first background run
  left `schemaVersion` raised with no migration, in a state that compiles.
- **Check `lib/core/ui/components/` before writing any widget.** Task 5 lifts the picker's
  index out of `features/quiz` rather than drawing a second one.
- **Nothing is ever deleted.** Narrowing hides. If you write a `DELETE` against attempts,
  review state, lesson progress or assessments in this plan, you have misread it.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. **"Migrate" appears
  in no user-facing string**, here or anywhere. **No string leads with what Pantas cannot
  do.**
- **Layering.** R1, R2, R3. **The baseline is 7 violations.** `features/settings` cannot
  import `features/quiz`, which is why Task 5 lifts rather than reuses in place.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/storage/data/tables/track_scope_local_table.dart`
- `lib/core/storage/data/repos/custom_track_repository.dart`
- `lib/core/storage/track_scope.dart` — `scopedTopicsProvider` and its friends.
- `lib/core/ui/components/topic_scope_index.dart` — the hierarchical index, lifted.
- `lib/features/onboarding/presentation/steps/custom_track_name_step.dart`
- `lib/features/onboarding/presentation/steps/custom_track_subjects_step.dart`
- `lib/features/settings/presentation/pages/whats_included_page.dart`
- Tests mirroring each.

**Modify:**
- `lib/core/storage/data/tables/exams_table.dart` — `isCustom`.
- `lib/core/storage/data/app_database.dart` — the table, the schema bump, the migration.
- `lib/core/storage/data/repos/content_repository.dart` — hydrate `isCustom`.
- `lib/core/storage/domain/exam.dart` — carry `isCustom`.
- the exam picker, wherever the onboarding plan left it.
- `lib/features/quiz/presentation/today_providers.dart` and
  `practice_picker_providers.dart` — read the scoped topics.
- `lib/app/router.dart`, `lib/features/settings/presentation/settings_home_page.dart`.

**Not touched:** the mock. Plan B.

---

## Task 1: Storage

**Files:**
- Create: `lib/core/storage/data/tables/track_scope_local_table.dart`
- Modify: `lib/core/storage/data/tables/exams_table.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `lib/core/storage/domain/exam.dart`
- Modify: `lib/core/storage/data/repos/content_repository.dart`
- Test: `test/core/storage/data/custom_track_migration_test.dart`

**Interfaces:**
- Produces: `Exams.isCustom`, `Exam.isCustom`, and the `TrackScopeLocal` table with
  `examId` and `topicId` as a composite primary key.

**The exclusion list's shape:**

```dart
// coverage:ignore-file
import 'package:cse_cet_reviewer/core/storage/data/tables/exams_table.dart';
import 'package:cse_cet_reviewer/core/storage/data/tables/topics_table.dart';
import 'package:drift/drift.dart';

/// Topics a track hides.
///
/// An exclusion list rather than an inclusion list, so "narrowing filters, it
/// never purges" is literal: a row means hidden, no rows means everything is
/// in. Re-ticking deletes the row and everything is back, because nothing was
/// ever keyed on the scope.
@DataClassName('TrackScopeExclusionRow')
class TrackScopeLocal extends Table {
  TextColumn get examId => text().references(Exams, #id)();
  TextColumn get topicId => text().references(Topics, #id)();

  @override
  Set<Column<Object>> get primaryKey => {examId, topicId};
}
```

and on `Exams`:

```dart
  /// A track the student named themselves. Never listed in the exam picker,
  /// and identical to a listed exam everywhere else, because every table in
  /// the app keys on an exam id and none of them care where the row came
  /// from.
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
```

- [ ] **Step 1: Write the failing migration test**

Create `test/core/storage/data/custom_track_migration_test.dart` following whatever migration
test already exists for the schema-14 work; find it with
`grep -rln "schemaVersion\|MigrationStrategy" test/`. Cover:

```dart
  test('an existing exam reads as not custom after the migration', () async {
    // Open at the previous schema version with one exam row, migrate, read
    // isCustom and expect false.
  });

  test('the exclusion table exists and takes a row', () async {
    // Insert (exam, topic) and read it back.
  });

  test('the same exclusion cannot be written twice', () async {
    // insertOnConflictUpdate twice, expect one row.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/custom_track_migration_test.dart`
Expected: FAIL.

- [ ] **Step 3: Bump the schema and write the migration in the same change**

In `app_database.dart`, add `TrackScopeLocal` to `@DriftDatabase(tables: [...])`, raise
`schemaVersion` from 14 to 15, and add the step to `MigrationStrategy.onUpgrade`:

```dart
        if (from < 15) {
          await m.addColumn(exams, exams.isCustom);
          await m.createTable(trackScopeLocal);
        }
```

**Do not raise `schemaVersion` in one commit and write the migration in another.** The last
background run left exactly that state in the main checkout, and it compiles.

Then run the generator and **do not commit its output**:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Carry `isCustom` on the domain model**

`Exam` is freezed. Add `@Default(false) bool isCustom,` and hydrate it in
`ContentRepository.listExams`. `Exam.fromJson` gets the default for free, so the seed file
needs no change.

- [ ] **Step 5: Run the tests**

Run: `flutter test test/core/storage/`
Expected: PASS.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): custom tracks, and a track's scope

A custom track is an exam row flagged as custom, because every table in
the app already keys on an exam id and a parallel concept would have to
be threaded through all of them. Scope is an exclusion list so that
narrowing hides and re-ticking restores."
```

---

## Task 2: `CustomTrackRepository` and the scoped topics

**Files:**
- Create: `lib/core/storage/data/repos/custom_track_repository.dart`
- Create: `lib/core/storage/track_scope.dart`
- Test: `test/core/storage/data/repos/custom_track_repository_test.dart`
- Test: `test/core/storage/track_scope_test.dart`

**Interfaces:**
- Produces, relied on by every later task and by Plan B:

```dart
class CustomTrackRepository {
  Future<ExamId> create({required String name, required Set<TopicId> includedTopicIds});
  Future<void> setExcluded({required ExamId examId, required Set<TopicId> topicIds});
  Future<Set<TopicId>> excludedTopicIds(ExamId examId);
}

final trackScopeProvider = FutureProvider.family<Set<TopicId>, ExamId>(...);   // excluded
final scopedTopicsProvider = FutureProvider.family<List<Topic>, ExamId>(...);
final scopedSubjectsProvider = FutureProvider.family<List<Subject>, ExamId>(...);
```

**`scopedTopicsProvider` is the answer to "what is in my exam" and replaces every feature-side
call to `topicsByExam`.** For a listed exam it is that exam's topics minus its exclusions. For
a custom track it is **the whole corpus** minus its exclusions, because a custom track owns no
subjects of its own.

**"The whole corpus" means every topic reachable from any exam**, deduplicated by topic id. A
topic belongs to one subject and a subject to one exam, so the corpus is the union across
exams, and the shared subjects the spec names (Mathematics, Science, Language Proficiency,
Reading Comprehension, Reasoning) appear once per exam that carries them. **Deduplicate by
topic name within a subject name**, not by id, or a custom track shows Algebra six times.

**That deduplication is a real decision with a real cost**: two exams' "Algebra" may hold
different questions, and collapsing them means a custom track draws from whichever id wins.
**Prefer the id with the most questions**, and say so in the code. If that turns out wrong,
the fix is a corpus-level topic identity, which is a content change and not this plan's job.

- [ ] **Step 1: Write the failing repository test**

Cover, over an in-memory database seeded with two exams sharing a subject name:

```dart
  test('creating a track stores its name and hides nothing it includes',
      () async { ... });

  test('creating a track excludes every topic it did not include', () async {
    // Include Mathematics only; expect every Science topic excluded.
  });

  test('the created track is custom and is not listed', () async {
    expect(exam.isCustom, isTrue);
  });

  test('re-including a topic deletes its exclusion', () async { ... });

  test('setting exclusions never touches attempts or review state', () async {
    // Write an attempt and a review state, narrow, and read both back.
  });
```

- [ ] **Step 2: Write the failing scope test**

```dart
  test('a listed exam with no exclusions scopes to its own topics', () { ... });

  test('an exclusion hides a topic', () { ... });

  test('a custom track scopes to the whole corpus minus its exclusions',
      () { ... });

  test('a shared subject appears once for a custom track', () async {
    // Two exams both carrying "Mathematics · Algebra".
    expect(topics.where((t) => t.name == 'Algebra'), hasLength(1));
  });

  test('the winning id is the one with more questions', () async { ... });
```

- [ ] **Step 3: Run both to verify they fail**

Run: `flutter test test/core/storage/`
Expected: FAIL.

- [ ] **Step 4: Write the repository**

```dart
class CustomTrackRepository {
  CustomTrackRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Creates the track and hides everything it did not include.
  ///
  /// The included set is turned into exclusions immediately, because the
  /// scope is stored as what is hidden. A track that includes everything
  /// therefore stores no rows at all, which is the same state a listed exam
  /// starts in.
  Future<ExamId> create({
    required String name,
    required Set<TopicId> includedTopicIds,
  }) async {
    final examId = 'exam_custom_${_uuid.v4()}';
    await _db.into(_db.exams).insert(
          ExamsCompanion.insert(
            id: examId,
            code: 'custom',
            name: name,
            // The name is the track's identity everywhere the short name
            // would otherwise appear, so both carry it.
            shortName: name,
            language: 'en',
            isCustom: const Value(true),
          ),
        );

    final allTopics = await _db.select(_db.topics).get();
    await setExcluded(
      examId: examId,
      topicIds: {
        for (final topic in allTopics)
          if (!includedTopicIds.contains(topic.id)) topic.id,
      },
    );
    return examId;
  }
  ...
}
```

**`setExcluded` replaces the whole set in one transaction**, deleting rows that are no longer
excluded and inserting the new ones. That delete is the only delete in this plan and it
deletes exclusions, not content.

- [ ] **Step 5: Write the scope providers**

```dart
/// What the student has hidden.
final trackScopeProvider = FutureProvider.family<Set<TopicId>, ExamId>(
  (ref, examId) =>
      ref.watch(customTrackRepositoryProvider).excludedTopicIds(examId),
);

/// What is in this student's exam.
///
/// The single answer for both kinds of track. Every feature that used to ask
/// `topicsByExam` asks this instead, which is also what makes narrowing
/// available to a listed exam rather than only to a custom one.
final scopedTopicsProvider =
    FutureProvider.family<List<Topic>, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final excluded = await ref.watch(trackScopeProvider(examId).future);
  final exam = (await content.listExams())
      .where((candidate) => candidate.id == examId)
      .firstOrNull;

  final topics = exam != null && exam.isCustom
      ? await _corpusTopics(content)
      : await content.topicsByExam(examId);

  return [
    for (final topic in topics)
      if (!excluded.contains(topic.id)) topic,
  ];
});
```

`_corpusTopics` walks every exam's topics and deduplicates:

```dart
/// Every topic in the corpus, once.
///
/// A custom track owns no subjects, so it draws on what every listed exam
/// carries. Shared subjects appear under several exams with different topic
/// ids, so they are collapsed by name and the id holding the most questions
/// wins. That is a real loss where two exams' "Algebra" differ; the proper fix
/// is a corpus-level topic identity, which is a content change.
```

- [ ] **Step 6: Run the tests**

Run: `flutter test test/core/storage/`
Expected: PASS.

- [ ] **Step 7: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib/core/storage test/core/storage
git commit -m "feat(storage): one answer to what is in my exam

scopedTopicsProvider serves a listed exam and a custom track through the
same query, which is also what lets a UPCAT student who has already
passed a subject narrow their track the same way."
```

---

## Task 3: The branch out of the picker

**Files:**
- Modify: the exam picker step, wherever `plans/2026-08-02-onboarding-flow-and-new-steps.md`
  Task 6 left it
- Test: its test file

**Interfaces:**
- Produces: a route to the first branch screen. Tasks 4 and 5 build the screens.

**From the spec, Section 2:** the picker gains one row, **below a full-width 1px `rule`**, set
apart from the exam list:

> My exam isn't on this list                                              ›

**A chevron, not a selection state.** It opens a branch rather than choosing a row, and **it
must not read as a seventh exam. It never participates in the picker's selection or enables
its Continue button.**

**And the picker lists `!isCustom`.** A student who has already made a track must not see it
in the list of exams to choose from; switching to it is Settings' job, which is the exam
switching plan.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the branch row sits below a rule, apart from the exams',
      (tester) async { ... });

  testWidgets('tapping the branch row does not select anything',
      (tester) async {
    await tester.tap(find.text("My exam isn't on this list"));
    await tester.pumpAndSettle();
    // Continue is still disabled, nothing is checked.
  });

  testWidgets('a custom track is never listed as an exam', (tester) async {
    // Seed one custom exam row and expect it absent from the picker.
  });
```

- [ ] **Step 2 to 4: Run it, add the row, run it again**

The row is an `InkTableRow` with a trailing chevron and `onTap` pushing
`/onboarding/custom/name`. It sits after a full-width `rule` and outside whatever widget
holds the selectable exam rows, so it cannot be reached by the selection logic at all.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(onboarding): a way out of the exam list

The row is set apart below a rule and carries a chevron rather than a
check, because it opens a branch and must not read as a seventh exam."
```

---

## Task 4: The two branch screens

**Files:**
- Create: `lib/features/onboarding/presentation/steps/custom_track_name_step.dart`
- Create: `lib/features/onboarding/presentation/steps/custom_track_subjects_step.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/onboarding/presentation/custom_track_steps_test.dart`

**Interfaces:**
- Consumes: `CustomTrackRepository.create`, `scopedSubjectsProvider`.
- Produces: routes `/onboarding/custom/name` and `/onboarding/custom/subjects`.

**From the spec, Section 3. Two screens, not one, and the reason is concrete:** a combined
screen was drawn and rejected because "tapping the name field raises the keyboard, which
covers the subject list beneath it, so the student types blind and only sees what they were
meant to read after dismissing it".

**Screen one, the name:**

> **What are you studying for?**
> Give it a name you'll recognize. "PUP CET", "Nursing board".
>
> [ ruled text field ]
>
> [ Continue ]

Required. It is the track's identity everywhere the exam short name would otherwise appear.

**It is also the demand signal, and that is why the field matters more than it looks.** When
four thousand students name their track "PUP CET", that is a ranked queue of exams worth
authoring properly. **Nothing asks the student to submit their exam**: an earlier draft put
"Tell us your exam and we'll look at adding it" on the mock panel and it was cut, because it
promises an action with no route and the name they already typed is the signal.

**Screen two, the subjects:**

> **What does it cover?**
> Tick the subjects your exam covers. You can choose exact topics later in Settings.
>
> [ subject checkboxes ]
>
> [ Continue ]

**Subjects, not topics.** It is the only level a student can answer honestly on day one,
because it is the level their school publishes. Topic-level selection here was rejected: it
asks the student to write the syllabus, and the Quiz tab's picker does it later and better,
once they have an opinion.

**Every subject arrives ticked.** Doing nothing is a valid answer, which is what makes the
question cheap enough to ask during onboarding at all.

**The subject list is the corpus's**, deduplicated by name, from Task 2. Not any one exam's.

**Where the branch rejoins:** back into the main flow at the exam date step, then the name
step. The custom path is six steps and the listed path is four, which is why the Welcome copy
says "a few" rather than a number.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the name is required', (tester) async {
    expect(continueButton.onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'PUP CET');
    await tester.pump();
    expect(continueButton.onPressed, isNotNull);
  });

  testWidgets('whitespace is not a name', (tester) async {
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('every subject arrives ticked', (tester) async { ... });

  testWidgets('the subject list is the corpus, deduplicated', (tester) async {
    // Two exams both carrying Mathematics.
    expect(find.text('Mathematics'), findsOneWidget);
  });

  testWidgets('unticking everything is allowed and creates a track',
      (tester) async {
    // Cheap to answer means every answer is valid, including none.
  });

  testWidgets('continuing creates the track and lands on the date step',
      (tester) async { ... });
```

- [ ] **Step 2 to 4: Run it, build the screens, run it again**

Both screens follow the onboarding plan's step scaffold; read
`plans/2026-08-02-onboarding-flow-and-new-steps.md` Tasks 9 and 10 and match them rather than
inventing a second layout.

The subject checkbox is `InkCheckbox` from `lib/core/ui/components/`, which Plan 5 of the
quiz work promotes out of the practice picker. **If that has not landed yet, promote it
here** and say so, so the two plans do not each write one.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(onboarding): naming a track and saying what it covers

Two screens because the keyboard on a combined one covers the subject
list, so the student types blind and reads afterwards. Subjects rather
than topics: it is the level their school publishes."
```

---

## Task 5: "What's included"

**Files:**
- Create: `lib/core/ui/components/topic_scope_index.dart`
- Create: `lib/features/settings/presentation/pages/whats_included_page.dart`
- Modify: `lib/features/quiz/presentation/pages/practice_picker_page.dart`
- Modify: `lib/app/router.dart`, `settings_home_page.dart`
- Test: `test/core/ui/components/topic_scope_index_test.dart`
- Test: `test/features/settings/presentation/whats_included_page_test.dart`

**Interfaces:**
- Produces: `TopicScopeIndex`, the hierarchical subject/topic index with the dash for
  partial, used by both this screen and the practice picker.

**From the spec, Section 5:**

> **What's included**
> Unticking something hides it. Nothing you've done is deleted.

**This is the Quiz tab picker's index**, from `2026-07-28-quiz-tab-design.md` Section 2:
subject headings, topic rows, hierarchical selection, the dash for partial. It must be
**lifted into `lib/core/ui/`** to be reused here, "the same move Task 3 of the onboarding
polish plan makes for the exam row, and for the same layering reason: `features/settings/`
cannot import `features/quiz/`".

**Lift, do not copy.** The practice picker's index was built in Plan 3 of the quiz work as
`PracticeIndex` plus private row widgets on the page. Move the row widgets and the checkbox
into `topic_scope_index.dart`, take a generic tree, and have the picker render through it.
**A second index is the defect this codebase keeps producing.**

**Two objects, not one, and they must not be confused:**

| Object | Question | Lifetime | Where |
|---|---|---|---|
| Session scope | what do I practice right now | one session | the Quiz tab picker |
| Track scope | what is in my exam at all | until changed | this screen |

They share a widget and nothing else. **Do not share their state.**

**Available to every track, not only custom ones.** A student sitting UPCAT who has already
passed one subject has the same reason to narrow.

**The lesson row is absent here.** Track scope is topic-level: the spec's mockup shows
subjects and topics only, and a lesson is not a unit of "what my exam covers".

- [ ] **Step 1: Write the failing tests**

```dart
  testWidgets('the screen states the rule before the list', (tester) async {
    expect(
      find.text("Unticking something hides it. Nothing you've done is "
          'deleted.'),
      findsOneWidget,
    );
  });

  testWidgets('everything is ticked for a listed exam with no exclusions',
      (tester) async { ... });

  testWidgets('unticking a topic writes an exclusion', (tester) async { ... });

  testWidgets('unticking one topic drops its subject to the dash',
      (tester) async { ... });

  testWidgets('re-ticking removes the exclusion', (tester) async { ... });

  testWidgets('narrowing deletes no attempt', (tester) async {
    // Write an attempt, untick its topic, read the attempt back.
  });

  testWidgets('there are no lesson rows', (tester) async { ... });
```

- [ ] **Step 2 to 4: Run them, lift the index, build the screen, run again**

The page writes through `CustomTrackRepository.setExcluded` and invalidates
`trackScopeProvider` and `scopedTopicsProvider` so every surface follows immediately.

Add a Settings row: title "What's included", subtitle "Choose what your exam covers".

- [ ] **Step 5: Run the whole suite**

Run: `flutter test`
Expected: PASS. The practice picker's tests must still pass after the lift; if they only pass
because you copied the widgets, you have not lifted them.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(settings): what's included

The index is lifted out of the practice picker rather than drawn twice,
because settings cannot import the quiz feature. Session scope and track
scope share a widget and share nothing else."
```

---

## Task 6: Every surface reads the scope

**Files:**
- Modify: `lib/features/quiz/presentation/today_providers.dart`
- Modify: `lib/features/quiz/presentation/practice_picker_providers.dart`
- Modify: the Study map's topic source
- Test: `test/features/quiz/presentation/scoped_content_test.dart` (create)

**Interfaces:**
- Consumes: `scopedTopicsProvider` from Task 2.
- Produces: nothing new. This is the swap that makes the track mean something.

**From the spec, Section 4:** the ticked subjects filter the corpus everywhere the selected
exam would: **today's session, the Study map, the practice picker, and what Progress counts
as coverage.**

**Find every caller:**

```bash
grep -rn "topicsByExam" --include="*.dart" lib
```

**`ContentRepository.topicsByExam` itself stays**, because `scopedTopicsProvider` calls it and
because `AssessmentQuestionSelector` uses it. **The assessment is deliberately left alone**
only if it already resolves through the scope; check it. The spec's Open section closed the
assessment question by saying a custom track "takes it like any other" and that
`AssessmentQuestionSelector` budgets across *contributing* topics, so a narrowed corpus means
fewer contributing topics and a shorter assessment. **That only holds if the selector sees
the scoped topics**, so it must be given them.

`AssessmentQuestionSelector` takes a `ContentRepository` and calls `topicsByExam` itself.
**Change it to take the topics rather than fetch them**, and have its provider pass
`scopedTopicsProvider`. That keeps the selector pure of the scope concept and puts the
decision in one place.

- [ ] **Step 1: Write the failing test**

```dart
  test("today's queue skips an excluded topic", () async { ... });

  test('the practice picker does not list an excluded topic', () async { ... });

  test('the assessment shortens when the track narrows', () async {
    // 6 contributing topics then 3; expect the selector's own formula
    // output, not a fixed number.
  });

  test('excluding a topic does not delete its attempts', () async { ... });
```

- [ ] **Step 2 to 4: Run it, swap the callers, run it again**

- [ ] **Step 5: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(quiz): the track's scope reaches the content

Today's session, the picker, the Study map and the assessment all ask
what is in my exam through one provider now, so a custom track and a
narrowed listed exam behave the same way."
```

---

## What this plan deliberately does not do

- **The custom mock.** Plan B: the panel's two new states, the setup screen, the three wheel
  sheets, the corpus ceiling and the locally authored blueprint.
- **Switching to or from a custom track.** The exam switching plan.
- **Promoting a custom track to a real exam.** Deferred in the spec: the matching is fuzzy and
  it is worth its own pass once the first promotion actually happens.
- **A corpus-level topic identity.** Task 2 collapses shared subjects by name and takes the
  id with the most questions. Flagged there, and it is a content change rather than a code
  one.

## Verification

```bash
flutter analyze
dart format --set-exit-if-changed lib test
dart run tool/check_layering.dart                # still 7, not 8
flutter test
```

By hand, on a device:

- The picker's branch row never enables Continue, and never appears checked.
- A track named "PUP CET" shows that name everywhere an exam short name would appear,
  including Home's masthead and the Quiz tab.
- Unticking Science in Settings empties it from the Study map and today's session, and
  re-ticking brings back every attempt and every read lesson.
- A custom track takes the assessment, and its length is the selector's own output over the
  ticked subjects rather than a fixed number.
- A custom track never appears in the exam picker.

## Self-review notes

Checked against Sections 1 to 5, 7 and 8:

- Free and uncapped: nothing in this plan reads entitlement.
- The branch row's placement and its inertness: Task 3.
- Two screens, their copy, subjects not topics, all ticked by default: Task 4.
- Filters and never purges, stated in the UI and enforced in storage: Tasks 1, 2, 5.
- "What's included", lifted rather than copied, available to every track: Task 5.
- The scope reaching content, and the assessment following the formula: Task 6.
- Home unchanged, the name standing in for the short name: falls out of Task 1's design.
- **One decision the spec left open and this plan makes**: a custom track is a flagged exam
  row, so the app's existing exam-id keying carries it. Recorded at the top with its
  alternative.
