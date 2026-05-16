# Selected Exam Dashboard Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the app shell to selected-exam focus with four tabs (`Home | Study | Quiz | More`) and implement Home Dashboard Phase 1: an assessment-driven study plan for the selected exam.

**Architecture:** Add a local selected-exam focus repository/provider, then make Home, Study, and Quiz resolve the active exam from that shared app context. Rename user-facing Learn navigation to Study while preserving lesson functionality. Home uses local `AssessmentResultsLocal` only; future dashboard modules and Pro dynamic profile remain out of scope. The Quiz tab is a shell tab, but quiz-taking and quiz-results routes remain root-level full-screen routes so active quiz sessions are not embedded inside the bottom navigation shell.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test

---

## File Map

**Create:**
- `lib/core/storage/data/tables/app_preferences_local_table.dart` - Drift key/value preferences table.
- `lib/core/storage/data/repos/app_preferences_repository.dart` - typed selected exam methods.
- `lib/core/storage/selected_exam_focus.dart` - active exam resolution provider and focus view model.
- `lib/features/assessment/presentation/assessment_result_providers.dart` - shared assessment result hydration.
- `lib/features/assessment/presentation/assessment_home_tab.dart` - Home Dashboard Phase 1.
- `test/core/storage/data/repos/app_preferences_repository_test.dart`
- `test/core/storage/selected_exam_focus_test.dart`
- `test/features/assessment/presentation/assessment_home_tab_test.dart`

**Modify:**
- `lib/core/storage/data/app_database.dart` - add preferences table and migration.
- `lib/core/storage/storage.dart` - expose preferences repository provider.
- `lib/app/router.dart` - four shell branches and `/study` routes.
- `lib/features/shell/presentation/app_shell.dart` - floating four-tab nav.
- `lib/features/assessment/presentation/assessment_results_page.dart` - use shared providers and `/study` CTAs.
- `lib/features/lesson/presentation/learn_tab_home.dart` - rename class/copy or replace with Study tab wrapper scoped to selected exam.
- `lib/features/quiz/presentation/quiz_tab_home.dart` - scope to selected exam.
- `test/app/app_boot_test.dart` - provide an in-memory database override now that `/home` is data-backed.
- tests for shell, lesson/study, quiz, assessment results route changes.

**UI decision mockup:** `docs/superpowers/mockups/assessment-home-study-plan/phase-1-placeholder-decision.html` shows the selected no-assessment Home card direction. The implementation uses a Flutter-native placeholder illustration instead of an SVG asset to avoid adding `flutter_svg` for one temporary visual.

**Important execution notes:**
- Home study-plan rows always use `result.topicMasteries.take(3)` because `AssessmentResult.fromRow` already sorts weakest-first. Do not filter to weak/moderate before taking 3; that can show fewer than 3 rows when the selected exam has mixed strong and weak topics.
- Each row independently chooses its action: `Study` for weak/moderate and `Quiz` for strong.
- First-launch onboarding is out of scope. Tests and future onboarding/settings code can write the selected exam through `AppPreferencesRepository`; the app defensively shows the choose-exam fallback when there are multiple active exams and no persisted selection.
- Existing app/shell tests that pump `App` must override `appDatabaseProvider` with an in-memory database because `/home` will no longer be a static stub.

---

### Task 1: Local Selected Exam Preference

**Files:**
- Create: `lib/core/storage/data/tables/app_preferences_local_table.dart`
- Create: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Modify: `lib/core/storage/data/app_database.dart`
- Modify: `lib/core/storage/storage.dart`
- Test: `test/core/storage/data/repos/app_preferences_repository_test.dart`

- [ ] **Step 1: Write repository tests**

Create `test/core/storage/data/repos/app_preferences_repository_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('selectedExamId returns null when unset', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    expect(await repo.selectedExamId(), isNull);
  });

  test('setSelectedExamId persists the selected exam id', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setSelectedExamId('cse');

    expect(await repo.selectedExamId(), equals('cse'));
  });

  test('setSelectedExamId overwrites previous value', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = AppPreferencesRepository(db);

    await repo.setSelectedExamId('cse');
    await repo.setSelectedExamId('upcat');

    expect(await repo.selectedExamId(), equals('upcat'));
  });
}
```

- [ ] **Step 2: Run failing test**

Run:

```bash
flutter test test/core/storage/data/repos/app_preferences_repository_test.dart
```

Expected: FAIL because repository/table do not exist.

- [ ] **Step 3: Add Drift table**

Create `lib/core/storage/data/tables/app_preferences_local_table.dart`:

```dart
// coverage:ignore-file
import 'package:drift/drift.dart';

@DataClassName('AppPreferenceLocalRow')
class AppPreferencesLocal extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
```

- [ ] **Step 4: Add repository**

Create `lib/core/storage/data/repos/app_preferences_repository.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class AppPreferencesRepository {
  AppPreferencesRepository(this._db);

  static const _selectedExamIdKey = 'selected_exam_id';

  final AppDatabase _db;

  Future<String?> selectedExamId() async {
    final row = await (_db.select(_db.appPreferencesLocal)
          ..where((p) => p.key.equals(_selectedExamIdKey)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSelectedExamId(String examId) async {
    await _db.into(_db.appPreferencesLocal).insertOnConflictUpdate(
          AppPreferencesLocalCompanion.insert(
            key: _selectedExamIdKey,
            value: examId,
          ),
        );
  }
}
```

- [ ] **Step 5: Register table and provider**

In `lib/core/storage/data/app_database.dart`:

- import `app_preferences_local_table.dart`;
- add `AppPreferencesLocal` to `@DriftDatabase(tables: [...])`;
- bump `schemaVersion` by 1;
- in `onUpgrade`, create `appPreferencesLocal` when upgrading from earlier versions.

In `lib/core/storage/storage.dart`, add:

```dart
final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>(
  (ref) => AppPreferencesRepository(ref.watch(appDatabaseProvider)),
);
```

and import the repository.

- [ ] **Step 6: Run code generation**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generated database code includes `appPreferencesLocal`.

- [ ] **Step 7: Run tests**

Run:

```bash
flutter test test/core/storage/data/repos/app_preferences_repository_test.dart
```

Expected: PASS.

---

### Task 2: Active Exam Focus Provider

**Files:**
- Create: `lib/core/storage/selected_exam_focus.dart`
- Test: `test/core/storage/selected_exam_focus_test.dart`

- [ ] **Step 1: Write provider tests**

Create `test/core/storage/selected_exam_focus_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> insertExam(String id, String name) async {
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: id,
            code: id.toUpperCase(),
            name: name,
            shortName: id.toUpperCase(),
            language: 'en',
          ),
        );
  }

  test('uses persisted selected exam when valid', () async {
    await insertExam('cse', 'Civil Service Exam');
    await insertExam('upcat', 'UPCAT');
    await AppPreferencesRepository(db).setSelectedExamId('cse');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam?.id, equals('cse'));
    expect(focus.needsSelection, isFalse);
  });

  test('uses only exam as fallback when one exam exists', () async {
    await insertExam('cse', 'Civil Service Exam');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam?.id, equals('cse'));
    expect(focus.needsSelection, isFalse);
  });

  test('needs selection when multiple exams exist and none selected', () async {
    await insertExam('cse', 'Civil Service Exam');
    await insertExam('upcat', 'UPCAT');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam, isNull);
    expect(focus.needsSelection, isTrue);
  });

  test('needs selection when persisted exam is invalid', () async {
    await insertExam('cse', 'Civil Service Exam');
    await insertExam('upcat', 'UPCAT');
    await AppPreferencesRepository(db).setSelectedExamId('removed');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam, isNull);
    expect(focus.needsSelection, isTrue);
  });
}
```

- [ ] **Step 2: Run failing test**

Run:

```bash
flutter test test/core/storage/selected_exam_focus_test.dart
```

Expected: FAIL because `selected_exam_focus.dart` does not exist.

- [ ] **Step 3: Add providers**

Create `lib/core/storage/selected_exam_focus.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveExamFocus {
  const ActiveExamFocus._({
    required this.exam,
    required this.needsSelection,
  });

  const ActiveExamFocus.selected(Exam exam)
      : this._(exam: exam, needsSelection: false);

  const ActiveExamFocus.needsSelection()
      : this._(exam: null, needsSelection: true);

  final Exam? exam;
  final bool needsSelection;
}

final activeExamFocusProvider = FutureProvider<ActiveExamFocus>((ref) async {
  final exams = await ref.watch(examListProvider.future);
  final activeExams = exams.where((exam) => exam.isActive).toList();
  final selectedId =
      await ref.watch(appPreferencesRepositoryProvider).selectedExamId();

  if (selectedId != null) {
    for (final exam in activeExams) {
      if (exam.id == selectedId) return ActiveExamFocus.selected(exam);
    }
    return const ActiveExamFocus.needsSelection();
  }

  if (activeExams.length == 1) {
    return ActiveExamFocus.selected(activeExams.single);
  }

  return const ActiveExamFocus.needsSelection();
});
```

- [ ] **Step 4: Run provider tests**

Run:

```bash
flutter test test/core/storage/selected_exam_focus_test.dart
```

Expected: PASS.

---

### Task 3: Shared Assessment Result Provider

**Files:**
- Create: `lib/features/assessment/presentation/assessment_result_providers.dart`
- Modify: `lib/features/assessment/presentation/assessment_results_page.dart`
- Modify: `lib/features/assessment/assessment.dart`
- Test: `test/features/assessment/presentation/assessment_results_page_test.dart`

- [ ] **Step 1: Extract provider**

Create `lib/features/assessment/presentation/assessment_result_providers.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assessmentResultProvider =
    FutureProvider.family<AssessmentResult?, ExamId>((ref, examId) async {
  final row =
      await ref.watch(assessmentRepositoryProvider).resultForExam(examId);
  if (row == null) return null;
  final topics =
      await ref.watch(contentRepositoryProvider).topicsByExam(examId);
  return AssessmentResult.fromRow(row, topics);
});
```

- [ ] **Step 2: Update results page**

In `AssessmentResultsPage`, import the new provider and remove its local `assessmentResultProvider` definition. Keep behavior unchanged except update Study CTAs to `/study/topic/:topicId`.

- [ ] **Step 3: Export provider**

In `lib/features/assessment/assessment.dart`, add:

```dart
export 'presentation/assessment_result_providers.dart';
```

- [ ] **Step 4: Run existing assessment results tests**

Run:

```bash
flutter test test/features/assessment/presentation/assessment_results_page_test.dart
```

Expected: PASS after route expectation updates from `/learn` to `/study`.

---

### Task 4: Home Dashboard Phase 1

**Files:**
- Create: `lib/features/assessment/presentation/assessment_home_tab.dart`
- Modify: `lib/features/assessment/assessment.dart`
- Test: `test/features/assessment/presentation/assessment_home_tab_test.dart`

- [ ] **Step 1: Review UI decision mockup**

Open `docs/superpowers/mockups/assessment-home-study-plan/phase-1-placeholder-decision.html`. This is the visual decision record for the no-assessment hero: large clean Home header, selected exam subtitle, one focused card, and a Flutter-native diagnostic placeholder area. Do not add `flutter_svg` or register a temporary SVG asset in `pubspec.yaml`.

- [ ] **Step 2: Write widget tests**

Create `test/features/assessment/presentation/assessment_home_tab_test.dart` with tests for:

- missing focus shows `Choose your exam`;
- no assessment shows `Build your study plan`, `Start assessment`, `Quiz for now`;
- completed weak results show `Assessment last taken on May 12, 2026`, `Your study plan`, top 3 topics, percent-only metadata, and `Study` actions;
- all-strong results show `Keep sharp` and `Quiz` actions;
- CTAs route to `/assessment`, `/quiz/quick`, `/study/topic`, and `/assessment/:examId/results`.

Use in-memory Drift setup matching existing assessment result tests.

- [ ] **Step 3: Implement Home widget**

Create `lib/features/assessment/presentation/assessment_home_tab.dart` with:

- `AssessmentHomeTab extends ConsumerWidget`;
- watch `activeExamFocusProvider`;
- for missing focus, render choose-exam fallback;
- for active exam, watch `assessmentResultProvider(exam.id)`;
- if null, render no-assessment hero;
- if result exists, render top 3 rows.

Recommendation logic:

```dart
List<TopicMastery> homeTopics(AssessmentResult result) {
  return result.topicMasteries.take(3).toList();
}
```

Row action:

```dart
final action = mastery.level == MasteryLevel.strong ? 'Quiz' : 'Study';
```

Native placeholder widget shape:

```dart
class _DiagnosticPlaceholder extends StatelessWidget {
  const _DiagnosticPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 184,
            height: 112,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          Positioned(
            left: 42,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlaceholderBar(width: 70, color: colors.primary),
                const SizedBox(height: 10),
                _PlaceholderBar(width: 96, color: colors.error),
                const SizedBox(height: 10),
                _PlaceholderBar(width: 58, color: colors.primary),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 8),
            ),
            child: Icon(Icons.search, color: colors.primary, size: 30),
          ),
        ],
      ),
    );
  }
}
```

Date copy:

```dart
'Assessment last taken on ${_formatDate(result.completedAt)}'
```

- [ ] **Step 4: Export Home tab**

In `lib/features/assessment/assessment.dart`, add:

```dart
export 'presentation/assessment_home_tab.dart';
```

- [ ] **Step 5: Run Home tests**

Run:

```bash
flutter test test/features/assessment/presentation/assessment_home_tab_test.dart
```

Expected: PASS.

---

### Task 5: Four-Tab Floating Shell and Router

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `lib/features/shell/presentation/app_shell.dart`
- Modify: `test/features/shell/app_shell_test.dart`
- Modify: `test/app/app_boot_test.dart`

- [ ] **Step 1: Update shell tests**

Update shell tests to expect:

```dart
expect(find.text('Home'), findsWidgets);
expect(find.text('Study'), findsWidgets);
expect(find.text('Quiz'), findsWidgets);
expect(find.text('More'), findsWidgets);
expect(find.text('Learn'), findsNothing);
```

Also test tapping each shell tab reaches the expected screen. Pump `App` with an in-memory database override:

```dart
final db = inMemoryDatabase();
addTearDown(db.close);
await db.into(db.exams).insert(
      ExamsCompanion.insert(
        id: 'cse',
        code: 'CSE',
        name: 'Civil Service Exam',
        shortName: 'CSE',
        language: 'en',
      ),
    );

await tester.pumpWidget(
  ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: const App(flavor: Flavor.dev),
  ),
);
```

Update `test/app/app_boot_test.dart` the same way, and change its navigation label assertion from `Learn` to `Study`/`Quiz`.

- [ ] **Step 2: Update router branches**

In `lib/app/router.dart`, use four `StatefulShellBranch` entries:

- `/home` -> `AssessmentHomeTab`
- `/study` -> selected-exam Study tab
- `/quiz` -> selected-exam Quiz tab
- `/more` -> existing More stub

Keep full-screen quiz execution outside the shell:

- root-level `/quiz/quick/:examId` -> `QuizPage`
- root-level `/quiz/results/:attemptId` -> `QuizResultsPage`

This preserves a clean quiz-taking experience while the `/quiz` tab remains the selected-exam entry point.

Replace `/learn/topic/:topicId` route with `/study/topic/:topicId`.

Route structure target:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, shell) => AppShell(navigationShell: shell),
  branches: [
    StatefulShellBranch(routes: [
      GoRoute(path: '/home', builder: (_, __) => const AssessmentHomeTab()),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(
        path: '/study',
        builder: (_, __) => const StudyTabHome(),
        routes: [
          GoRoute(
            path: 'topic/:topicId',
            builder: (_, state) => LessonListPage(
              topicId: state.pathParameters['topicId']!,
              examId: state.uri.queryParameters['examId'],
            ),
          ),
        ],
      ),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/quiz', builder: (_, __) => const QuizTabHome()),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/more', builder: (_, __) => const _TabStub('More')),
    ]),
  ],
),
GoRoute(
  path: '/quiz/quick/:examId',
  builder: (_, state) => QuizPage(
    examId: state.pathParameters['examId']!,
    topicId: state.uri.queryParameters['topicId'],
  ),
),
GoRoute(
  path: '/quiz/results/:attemptId',
  builder: (_, state) =>
      QuizResultsPage(attemptId: state.pathParameters['attemptId']!),
),
```

- [ ] **Step 3: Update AppShell nav**

In `AppShell`, render four nav items:

```text
Home | Study | Quiz | More
```

Use a floating rounded container style. Keep tap targets at least 48dp. Do not implement new navigation behavior beyond branch switching.

- [ ] **Step 4: Run shell tests**

Run:

```bash
flutter test test/features/shell/app_shell_test.dart
```

Expected: PASS.

---

### Task 6: Study Tab Selected-Exam Scope

**Files:**
- Modify: `lib/features/lesson/presentation/learn_tab_home.dart`
- Modify: `lib/features/lesson/lesson.dart`
- Modify: `test/features/lesson/presentation/learn_tab_home_test.dart`

- [ ] **Step 1: Write Study tab tests**

Tests should seed two exams, set selected exam to `cse`, and assert:

- only CSE subjects/topics are visible;
- UPCAT content is not visible;
- tapping a topic routes to `/study/topic/:topicId?examId=cse`;
- missing focus shows choose-exam fallback.

Use `AppPreferencesRepository(db).setSelectedExamId('cse')` in setup after Task 1 exists. Keep the test file path as `learn_tab_home_test.dart` unless a later cleanup renames files; user-facing class/copy changes are more important than filesystem churn.

- [ ] **Step 2: Implement Study tab scope**

Refactor current `LearnTabHome` into user-facing Study behavior:

- rename the exported widget class to `StudyTabHome`;
- optionally keep a deprecated `LearnTabHome` wrapper only if existing tests or exports need a temporary compatibility bridge during the same task;
- copy uses `Study`;
- it watches `activeExamFocusProvider`;
- it renders only selected exam subjects/topics.
- it pushes `/study/topic/${topic.id}?examId=${focus.exam!.id}`.
- when focus is missing, render the fallback copy:

```text
Choose your exam
Pick the exam you are reviewing for.
[Choose exam]
```

`Choose exam` routes to `/onboarding`.

- [ ] **Step 3: Run Study tests**

Run:

```bash
flutter test test/features/lesson/presentation/learn_tab_home_test.dart
```

or the renamed study test file if created.

Expected: PASS after expectation updates.

---

### Task 7: Quiz Tab Selected-Exam Scope

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Modify: `test/features/quiz/presentation/quiz_tab_nudge_test.dart` and related quiz tab tests.

- [ ] **Step 1: Write Quiz tab tests**

Tests should seed two exams, set selected exam to `cse`, and assert:

- quiz tab shows selected-exam quiz entry;
- it does not list all exams;
- primary action routes to `/quiz/quick/cse`;
- missing focus shows choose-exam fallback.

Use two active exams in setup, then call `AppPreferencesRepository(db).setSelectedExamId('cse')`. Update the test router to expose `/study`, `/quiz/quick/:examId`, and `/onboarding`, not `/learn`.

- [ ] **Step 2: Implement Quiz tab scope**

Update `QuizTabHome`:

- watch `activeExamFocusProvider`;
- render selected exam only;
- remove all-exam list from this tab;
- keep any pre-quiz nudge if it still applies, but route to `/study` instead of `/learn`;
- keep the quick quiz route as `/quiz/quick/${exam.id}`;
- when focus is missing, render the same choose-exam fallback used by Home and Study.

- [ ] **Step 3: Run Quiz tab tests**

Run:

```bash
flutter test test/features/quiz/presentation/quiz_tab_nudge_test.dart
```

and any updated quiz tab tests.

Expected: PASS.

---

### Task 8: Route and Copy Cleanup

**Files:**
- Modify all tests/code that still reference `/learn` user-facing routes.

- [ ] **Step 1: Search old copy/routes**

Run:

```bash
rg -n "Learn|/learn|Browse Lessons|Read lessons" lib test
```

- [ ] **Step 2: Update intentional user-facing references**

Rules:

- Bottom tab label: `Study`
- Study route: `/study`
- Topic route: `/study/topic/:topicId`
- Quiz nudge action route: `/study`
- Assessment results Study CTA route: `/study/topic/:topicId?examId=:examId`
- Existing internal lesson feature folder can stay `lesson`.
- Do not rename files unless needed. If renaming `LearnTabHome` to `StudyTabHome`, update exports/imports and leave file renames for a later cleanup unless the analyzer requires them.

- [ ] **Step 3: Run focused route tests**

Run:

```bash
flutter test test/features/assessment/presentation/assessment_results_page_test.dart \
             test/features/shell/app_shell_test.dart \
             test/features/assessment/presentation/assessment_home_tab_test.dart
```

Expected: PASS.

---

### Task 9: Verification

- [ ] **Step 1: Run focused tests**

Run:

```bash
flutter test test/core/storage/data/repos/app_preferences_repository_test.dart \
             test/core/storage/selected_exam_focus_test.dart \
             test/features/assessment/presentation/assessment_home_tab_test.dart \
             test/features/assessment/presentation/assessment_results_page_test.dart \
             test/features/shell/app_shell_test.dart
```

Expected: PASS.

- [ ] **Step 2: Run analyzer**

Run:

```bash
flutter analyze
```

Expected: no issues.

- [ ] **Step 3: Run layering check**

Run:

```bash
dart run tool/check_layering.dart
```

Expected: PASS. Selected-exam focus lives under `core/storage`, so Study, Quiz, and Assessment can import it without feature-to-feature import violations.

- [ ] **Step 4: Run full tests**

Run:

```bash
flutter test
```

Expected: PASS.

---

## Self-Review

Spec coverage:

- Selected-exam focus: Tasks 1-2.
- Home dashboard Phase 1: Task 4.
- Four-tab shell and floating nav: Task 5.
- `/learn` to `/study`: Tasks 5 and 8.
- Study selected-exam scope: Task 6.
- Quiz selected-exam scope: Task 7.
- No Pro dynamic profile/future dashboard modules: preserved in scope and Home implementation.

Placeholder scan:

- No TBD/TODO placeholders.
- Placeholder illustration is explicit and intentional; final asset replacement is future visual-content work, not missing behavior.

Risk:

- `core/storage/selected_exam_focus.dart` imports Riverpod, matching the existing `core/storage/storage.dart` provider style. Keep assessment, lesson, and quiz feature imports out of this file.
- The native diagnostic placeholder is a temporary visual and avoids adding `flutter_svg`. If the final illustration is delivered as SVG later, add `flutter_svg` in that future asset task.
- `/quiz` is both a shell tab and the prefix for root-level quiz routes. Keep `/quiz/quick/:examId` and `/quiz/results/:attemptId` declared outside the shell route so quiz-taking remains full-screen.
- Because the seed has multiple active exams, development and widget tests must set selected exam preference explicitly when they expect selected-exam content.
