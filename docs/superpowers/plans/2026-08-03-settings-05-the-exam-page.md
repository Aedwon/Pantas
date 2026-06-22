# Settings 05: the Exam page

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

## AMENDED 3 August 2026: this plan absorbs work from two others

**Conflict C4, ruled by Aedwon.** Four tasks in `2026-07-25-onboarding-polish.md` and two in
`2026-08-02-exam-switching.md` are struck in favor of the Settings thread. This plan is the
beneficiary and nothing in it changes, but **three things are now true that were not when it
was written:**

1. **Task 1 is the only lift of `ExamSelectionRow`.** Onboarding polish Task 3 is struck, so
   this is not a "check whether it exists first" situation: **it does not exist and you create
   it.**
2. **Task 3 is the only build of `exam_page.dart`.** Onboarding polish Task 4 is struck.
3. **Task 2's `carryableCountProvider` is the only carryable count**, and
   `exam-switching` Task 1 is struck. The preference it reads is
   `userSettingsProvider.carryOverProgress` from `2026-08-03-settings-02-storage.md`, not
   `AppPreferencesRepository`.

**`exam-switching` still owns two things** and this plan must not build them: the per-student
mock cooldown, and the carry-over filter on the Progress and Home figure providers.

**`ExamDate` call sites:** `ExamDate.day(x)` becomes `ExamDate.onDay(x)` and `.exactDay`
becomes `.day`, per conflict C1.

---

**Goal:** Build `/settings/exam`, the three-row page under the exam's own name, and make "Change exam" reach the screen a student already met during onboarding.

**Architecture:** `ExamPage` holds three rows and nothing else. The roster is not rebuilt here: `ExamSelectionRow` is lifted out of the onboarding picker into `lib/core/ui/` and a new `ChangeExamPage` renders the same list, so onboarding and Settings share one row and one selection call. The carry-over prompt fires on the way back from a real change, not on arrival.

**Tech Stack:** Flutter, Riverpod, go_router, Drift, `flutter_test`.

**Source spec:** `docs/superpowers/specs/2026-08-03-settings-design.md` Section 7, and `docs/superpowers/specs/2026-08-02-exam-switching-design.md` Section 4.

**Decision log:** `docs/superpowers/decisions/2026-08-03-settings-log.md`.

## Global Constraints

- **American spelling**, no em dashes, Grade-5-simple English in every string.
- **"Migrate" never appears in the UI.** The word is "carry over": it is engineer-speak, it sounds irreversible, and it sounds dangerous.
- **Pantas filters, it does not purge.** Switching exams deletes nothing. Turning carry-over off changes what the figures count, not what exists.
- **Carry-over governs figures and history and never governs scheduling.** No code in this plan may touch FSRS, a due date, or the flagged list.
- **A switch must not grant a new mock.** Nothing here resets a cooldown.
- `flutter analyze` clean and `dart format --output=none --set-exit-if-changed lib test` passing before any commit.

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-03-settings-01-the-kit.md` | `SettingsGroup`, `SettingsValueRow`, `SettingsSwitch`, `SettingsBar` | **Blocking** |
| `2026-08-03-settings-02-storage.md` | `UserSettings.carryOverProgress`, `SettingsActions.setCarryOverProgress` | **Blocking** |
| `2026-08-03-settings-03-the-top-level.md` | The `/settings/exam` stub route this plan replaces | **Blocking** |

## What is deferred, and why it is not a gap

**"What's included" ships as a row with no destination in this plan.** Its page is the Quiz picker's subject and topic index, which does not exist yet: it is built by `2026-08-02-quiz-tab-03-practice-picker.md` and must be lifted into `lib/core/ui/` before Settings can reuse it. `features/settings/` cannot import `features/quiz/`, so building a second index here would be the exact duplication the custom track spec forbids.

The row therefore renders with its value and its chevron and pushes `NotBuiltYetPage`. **Task 4 records the follow-up** so this does not quietly become permanent.

## File structure

| File | Responsibility |
|---|---|
| `lib/core/ui/components/exam_selection_row.dart` (create) | Emblem, short name, selected state. Lifted so both surfaces share it. |
| `lib/features/settings/presentation/pages/exam_page.dart` (create) | The three rows under the exam's name. |
| `lib/features/settings/presentation/pages/change_exam_page.dart` (create) | The roster, using the lifted row. |
| `lib/features/settings/presentation/carry_over_prompt.dart` (create) | The "You're not starting from zero" sheet. |
| `lib/features/settings/application/carry_over_providers.dart` (create) | The carryable count, measured from the student's own attempts. |
| `lib/features/onboarding/presentation/onboarding_picker_step.dart` (modify) | Consume the lifted row instead of its private one. |
| `lib/app/router.dart` (modify) | `/settings/exam` and `/settings/exam/change`. |

---

## Task 1: Lift the exam selection row

**Files:**
- Create: `lib/core/ui/components/exam_selection_row.dart`
- Modify: `lib/features/onboarding/presentation/onboarding_picker_step.dart`
- Test: `test/core/ui/components/exam_selection_row_test.dart`

**Interfaces:**
- Consumes: `Exam` from `lib/core/storage/domain/exam.dart`.
- Produces:

```dart
class ExamSelectionRow extends StatelessWidget {
  const ExamSelectionRow({
    required this.exam,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Exam exam;
  final bool selected;
  final VoidCallback onTap;

  static const double emblemWidth = 96;
}
```

**Two things about the lift, both from the 2026-07-25 emulator pass.** The emblem column must be **96 wide, not 56**: at 56 every code over about five characters wrapped mid-word, so `CSE_PRO` rendered as "CSE_P / RO" and `DLSUCET` as "DLSUC / ET". And it shows **`exam.shortName`, not `exam.code`**, because shortName already holds the human form. Check 96 against the longest shortName on device before calling this done.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/exam_selection_row_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/ui/components/exam_selection_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the emblem shows the short name, not the code', (tester) async {
    await tester.pumpApp(
      ExamSelectionRow(
        exam: buildExam(code: 'CSE_PRO', shortName: 'CSE Pro'),
        selected: false,
        onTap: () {},
      ),
    );

    expect(find.text('CSE Pro'), findsOneWidget);
    expect(find.text('CSE_PRO'), findsNothing);
  });

  testWidgets('the longest short name does not wrap', (tester) async {
    await tester.pumpApp(
      ExamSelectionRow(
        exam: buildExam(code: 'DLSUCET', shortName: 'DLSU CET'),
        selected: false,
        onTap: () {},
      ),
    );

    final text = tester.renderObject<RenderParagraph>(
      find.text('DLSU CET').first,
    );
    expect(text.computeLineMetrics().length, 1);
  });

  testWidgets('the row reports taps', (tester) async {
    var tapped = false;
    await tester.pumpApp(
      ExamSelectionRow(
        exam: buildExam(code: 'UPCAT', shortName: 'UPCAT'),
        selected: true,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byType(ExamSelectionRow));
    expect(tapped, isTrue);
  });
}
```

`buildExam` is a test helper. If `test/helpers/` has no exam builder, add one there constructing a minimal valid `Exam` from the real constructor; do not invent fields.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/exam_selection_row_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Lift the row**

Read the current row markup inside `onboarding_picker_step.dart` and move it verbatim into `lib/core/ui/components/exam_selection_row.dart`, changing exactly two things: the emblem column widens to `emblemWidth` and the emblem text becomes `exam.shortName`. It may import only `core/storage/domain/exam.dart` and the theme, which is what makes the move legal: `features/settings/` cannot import `features/onboarding/`, so `core/ui/` is the only shared home.

- [ ] **Step 4: Point onboarding at it**

Delete the private row from `onboarding_picker_step.dart` and import `ExamSelectionRow`. Run the onboarding tests.

Run: `flutter test test/features/onboarding/`
Expected: PASS. If a test asserts on `exam.code` appearing in the picker, update it to `shortName` and note in the commit that the emulator pass required the change.

- [ ] **Step 5: Commit**

```bash
flutter analyze
git add -A
git commit -m "refactor: lift the exam selection row into core so both surfaces share it"
```

---

## Task 2: The carryable count

**Files:**
- Create: `lib/features/settings/application/carry_over_providers.dart`
- Test: `test/features/settings/application/carry_over_providers_test.dart`

**Interfaces:**
- Consumes: the attempts repository from `lib/core/storage/data/repos/attempts_repository.dart` and the questions table's `examIdsJson`.
- Produces:

```dart
/// How many answered questions also belong to [examId].
///
/// Measured from the student's own attempts, which is why the number may be
/// printed. Nothing here is inferred.
final carryableCountProvider =
    FutureProvider.family<int, String>((ref, examId) async { ... });
```

**An attempt counts only if the question it was on lists the new exam in `examIdsJson`.** Work on a question that is not in the new exam's pool is never counted under any setting. The join already exists; no new storage.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/application/carry_over_providers_test.dart`, seeding an in-memory `AppDatabase` the same way the existing repository tests do:

```dart
  test('counts distinct answered questions that also list the new exam',
      () async {
    // Two questions on DOST, one of which is also on UPCAT.
    await seedQuestion(id: 'q1', examIds: ['DOST', 'UPCAT']);
    await seedQuestion(id: 'q2', examIds: ['DOST']);
    await seedAttempt(questionId: 'q1', examId: 'DOST');
    await seedAttempt(questionId: 'q2', examId: 'DOST');

    final count = await container.read(carryableCountProvider('UPCAT').future);

    expect(count, 1);
  });

  test('answering the same question twice counts once', () async {
    await seedQuestion(id: 'q1', examIds: ['DOST', 'UPCAT']);
    await seedAttempt(questionId: 'q1', examId: 'DOST');
    await seedAttempt(questionId: 'q1', examId: 'DOST');

    final count = await container.read(carryableCountProvider('UPCAT').future);

    expect(count, 1);
  });

  test('a student with no attempts carries nothing over', () async {
    final count = await container.read(carryableCountProvider('UPCAT').future);

    expect(count, 0);
  });
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/application/carry_over_providers_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the provider**

Query distinct `questionId` from `attempts_local` joined to the questions table where `examIdsJson` contains the target exam id. Read the real column and table names from `lib/core/storage/data/app_database.dart` before writing the query. **Count distinct question ids, not attempts**, so a student who answered one question four times is told about one question.

- [ ] **Step 4: Run the tests and commit**

Run: `flutter test test/features/settings/application/carry_over_providers_test.dart`
Expected: PASS, 3 tests.

```bash
git add lib/features/settings/application/carry_over_providers.dart test/features/settings/application/carry_over_providers_test.dart
git commit -m "feat: count the questions that carry over to another exam"
```

---

## Task 3: The Exam page and the change screen

**Files:**
- Create: `lib/features/settings/presentation/pages/exam_page.dart`
- Create: `lib/features/settings/presentation/pages/change_exam_page.dart`
- Create: `lib/features/settings/presentation/carry_over_prompt.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/presentation/exam_page_test.dart`

**Interfaces:**
- Produces: `ExamPage()`, `ChangeExamPage()`, `showCarryOverPrompt({required BuildContext context, required String examShortName, required int carryableCount})` returning `bool?` where true means count them.
- Routes: `/settings/exam`, `/settings/exam/change`.

**The page's heading is the exam's own name**, so the two rows underneath are unmistakably about it. Roster-first was drawn and rejected: carry-over is the row a student returns to, switching is rare, and putting the roster first buries the frequent thing below the fold.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/presentation/exam_page_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/exam_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the heading is the exam name and there are three rows',
      (tester) async {
    await tester.pumpAppWithProviders(const ExamPage(), overrides: [
      // Override the active exam and the settings providers as the other
      // settings tests do.
    ]);
    await tester.pumpAndSettle();

    expect(
      tester.widget<SettingsGroup>(find.byType(SettingsGroup)).title,
      'UPCAT',
    );
    expect(find.byType(SettingsValueRow), findsNWidgets(3));
    expect(find.text('Change exam'), findsOneWidget);
    expect(find.text('Carry over progress'), findsOneWidget);
    expect(find.text("What's included"), findsOneWidget);
  });

  testWidgets('carry over is a switch, on by default', (tester) async {
    await tester.pumpAppWithProviders(const ExamPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsSwitch), findsOneWidget);
    expect(tester.widget<SettingsSwitch>(find.byType(SettingsSwitch)).value,
        isTrue);
  });

  testWidgets('the lede states the rule that surprises people',
      (tester) async {
    await tester.pumpAppWithProviders(const ExamPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Answers from your other exams count toward this one. '
        'Nothing is ever deleted.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the word migrate never appears', (tester) async {
    await tester.pumpAppWithProviders(const ExamPage(), overrides: []);
    await tester.pumpAndSettle();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.toLowerCase().contains('migrat') ?? false, isFalse);
    }
  });
}
```

Fill in the overrides to match the pattern the Plan 03 home page test established.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/presentation/exam_page_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the Exam page**

Create `lib/features/settings/presentation/pages/exam_page.dart` with a `PageScaffold` holding `SettingsBar(title: 'Exam')` then one `SettingsGroup` titled with the active exam's short name and three children:

1. `SettingsValueRow(title: 'Change exam', value: '<n> available', showChevron: true, onTap: push /settings/exam/change)` where `n` is the count of active exams from `examListProvider`.
2. `SettingsValueRow(title: 'Carry over progress', control: SettingsSwitch(value: settings.carryOverProgress), onTap: toggle)`.
3. A lede `Text` immediately under it, `bodySmall` at `inkMuted`: `Answers from your other exams count toward this one. Nothing is ever deleted.`
4. `SettingsValueRow(title: "What's included", value: 'All subjects', showChevron: true, onTap: push /settings/exam/included)`.

- [ ] **Step 4: Write the change screen and the prompt**

`change_exam_page.dart`: `SettingsBar(title: 'Change exam')` over a `ListView` of `ExamSelectionRow` from `examListProvider`, marking the active one selected. Tapping a different exam calls `AppPreferencesRepository.setSelectedExamId`, invalidates `appPreferencesRepositoryProvider` so `activeExamFocusProvider` rebuilds, then **pops back to the Exam page and fires the prompt**.

`carry_over_prompt.dart`: an `showInkSheet` reading

> **You're not starting from zero**
>
> `<count>` of the questions you've answered are also on `<exam>`. We'll count them toward your `<exam>` progress so you can pick up where you are, not where you started.
>
> [ Count them ]
> Start my numbers fresh

`Count them` pops true, `Start my numbers fresh` pops false, and the caller writes `setCarryOverProgress`. **The prompt is skipped entirely when the count is zero**, because "0 of the questions you've answered" is a worse sentence than no sentence.

- [ ] **Step 5: Route both**

In `router.dart`, replace the `/settings/exam` stub builder with `const ExamPage()` and add:

```dart
      GoRoute(
        path: '/settings/exam/change',
        builder: (_, __) => const ChangeExamPage(),
      ),
      GoRoute(
        path: '/settings/exam/included',
        builder: (_, __) => const NotBuiltYetPage(title: "What's included"),
      ),
```

Add `/settings/exam/change` and `/settings/exam/included` to the required list in `test/app/router_settings_test.dart`.

- [ ] **Step 6: Run the gate and commit**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
git add -A
git commit -m "feat: the exam page, and change exam reusing the onboarding picker"
```

---

## Task 4: Record the deferral

**Files:**
- Modify: `docs/superpowers/2026-08-02-work-checkpoint.md`

- [ ] **Step 1: Add the follow-up**

Append to the checkpoint's open items:

```markdown
- **Settings, "What's included" has no page.** `2026-08-03-settings-05-the-exam-page.md`
  ships the row pointing at `NotBuiltYetPage`. Its page is the Quiz picker's subject and
  topic index, which must first be built by `2026-08-02-quiz-tab-03-practice-picker.md`
  and then lifted into `lib/core/ui/`, because `features/settings/` cannot import
  `features/quiz/`. Repoint the row at the lifted index and delete the stub.
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/2026-08-02-work-checkpoint.md
git commit -m "docs: record that What's included is waiting on the quiz picker index"
```

---

## Done when

- `/settings/exam` shows three rows under the exam's own short name.
- "Change exam" reaches the same roster onboarding uses, built from one shared `ExamSelectionRow`, and the emblem column no longer wraps `DLSUCET` mid-word.
- Changing the exam fires the carry-over prompt once, on the way back, and only when the carryable count is above zero.
- The count is distinct questions answered that also list the new exam.
- Turning carry-over off writes one preference and touches no due date, no FSRS state and no flag.
- The word "migrate" appears nowhere in the UI.
- `flutter test` passes across the whole suite.
