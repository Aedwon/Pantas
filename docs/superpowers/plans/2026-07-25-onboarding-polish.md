# Onboarding Polish Implementation Plan

> **Typography, amended 11 August 2026.** Any "serif" below is superseded: the
> app uses one family, Source Sans 3, everywhere. See
> `decisions/2026-08-10-typeface-log.md`.



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

## AMENDED 3 August 2026: four tasks are struck. Settings builds them.

**Conflict C4, ruled by Aedwon.** The Settings thread, written 3 August, builds four things
this plan also builds. Rather than sequencing around the duplication, the duplicated tasks are
struck here and folded into Settings.

| Task here | Struck in favor of |
|---|---|
| **Task 3**, lift the exam row | `2026-08-03-settings-05-the-exam-page.md` Task 1, which lifts the same file and widens the emblem column to 96 so `DLSUCET` stops wrapping |
| **Task 4**, Settings → Exam | `2026-08-03-settings-05-the-exam-page.md` Task 3, which builds it as three rows rather than a roster |
| **Task 5**, wire the Daily reminder row | `2026-08-03-settings-04-the-sheets.md`, the reminder sheet |
| **Task 6**, wire the Exam date row | `2026-08-03-settings-04-the-sheets.md`, the date sheet, on the shared `showExamDateSheet` |

**Do not execute Tasks 3, 4, 5 or 6.** They will collide: `settings-03` Task 4 **deletes**
`settings_row.dart`, `settings_section.dart`, `ios_switch.dart` and
`theme_segmented_control.dart`, which those four tasks build against.

**This plan is now nine tasks and they are all about onboarding:** 1, 2, 7, 8, 9, 10, 11, 12
and 13. That is what the title always said it was.

**Task 13, Verification, still runs**, and its checks against Tasks 3 to 6 are satisfied by
the Settings plans rather than by this one.

---

**Goal:** Fix the two live defects in the age-gate step, make good on the exam-switching promise the picker prints on screen, wire the two dead Settings rows the onboarding flow depends on, bring the flow's presentation in line with the Ink & Rule identity, and reconcile the nine documents that currently disagree about what onboarding is.

**Architecture:** No new subsystems. Widget-local fixes in `onboarding_age_gate_step.dart`; one row widget lifted from `onboarding_picker_step.dart` into `core/ui/components/` so Settings can reuse it without violating the R2 layering rule; three `SettingsRow` `onTap` handlers wired to application actions that already exist and are already tested; layout and copy passes over the four onboarding screens; a documentation pass.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test. `CupertinoPicker` (already present), Material `showTimePicker` / `showDatePicker`. No new packages.

**Source material:** the audit in this session, `docs/ui-audit.md`, and `docs/superpowers/specs/2026-05-16-onboarding-exam-selection-design.md`.

## Global Constraints

- **No new dependencies.** `CupertinoPicker`, `showTimePicker`, and `showDatePicker` all ship with Flutter.
- **Ink & Rule identity.** Serif headlines via `context.textStyles`; `BoardButton` for actions with at most **one primary (non-`secondary`) BoardButton per screen**; hairline rules via `AppDimensions.hairline`; page padding `EdgeInsets.fromLTRB(20, 24, 20, 24)`; no illustrations, no emoji-as-icon, no all-caps labels, no pill buttons, no tinted-circle icon headers.
- **Navigation rule (UI-001).** Destinations outside the tab shell are reached with `push`, never `go`. `go` is reserved for tab switches and deliberate flow resets such as `/onboarding`.
- **Layering (`tool/check_layering.dart`).** R1: `lib/core/**` must not import `lib/features/**`. R2: one feature must not import another. R3: `domain/` must not import Flutter or platform packages.
- **Commit messages carry no AI attribution or co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`, and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/ui/components/exam_selection_row.dart` — the selected/unselected exam row, lifted verbatim from `_ExamRow` in `onboarding_picker_step.dart` so both the onboarding picker and the new Settings page render an identical row. Lives in `core/ui/` because R2 forbids `features/settings/` importing `features/onboarding/`; it imports only `core/storage/domain/exam.dart` and theme tokens, which is core→core and legal.
- `lib/features/settings/presentation/pages/exam_page.dart` — `/settings/exam`, the switch-exam surface the picker promises.
- `test/features/settings/presentation/exam_page_test.dart`
- `test/features/settings/presentation/settings_pickers_test.dart` — covers the two newly wired rows.

**Modify:**
- `lib/features/onboarding/presentation/onboarding_age_gate_step.dart` — wheel anchoring, controller lifecycle, Continue enablement (Tasks 1–2)
- `lib/features/onboarding/presentation/onboarding_picker_step.dart` — delete the private `_ExamRow`, use the shared component (Task 3)
- `lib/features/settings/presentation/settings_home_page.dart` — add the Exam row; wire the Daily reminder and Exam date rows (Tasks 4–6)
- `lib/app/router.dart` — add `/settings/exam` (Task 4)
- `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart` (Tasks 1–2)
- `docs/ui-audit.md`, `docs/superpowers/specs/2026-05-16-onboarding-exam-selection-design.md`, `docs/superpowers/specs/2026-05-18-study-plan-design.md`, `docs/superpowers/specs/2026-05-21-paywall-entitlement-design.md` (Task 7)

**Delete:**
- `lib/features/auth_flow/{data,domain,presentation}/.gitkeep` (Task 8)

**Also modify (from the emulator pass, Tasks 9–12):**
- `lib/features/notifications/presentation/permission_rationale_page.dart` — vertical rhythm (Task 11)
- `android/app/build.gradle.kts` — app display name (Task 10)
- `lib/features/onboarding/presentation/onboarding_welcome_step.dart` — rhythm and headline (Tasks 11–12)
- `test/app/router_redirect_test.dart` — welcome headline assertion (Task 12)

**Scope note:** Tasks 1–8 come from a code read; Tasks 9–12 come from driving the flow on `pantas_pixel` on 2026-07-25. Two emulator findings were folded into existing tasks rather than given their own: the emblem column breaking (Task 3) and the dead Settings rows rendering chevrons (Tasks 5–6). Two more were resolved outside this plan — the contentless roster exams now ship `isActive: false`, which also settles the complaint that alphabetical sorting buried CSE Pro and UPCAT among them.

---

## Task 1: Age-gate wheel resumes at the rejected year

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`
- Test: `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`

**The defect:** `_buildInput` anchors the picker with `initialItem: years.indexOf(_defaultYear)` (line 62). When the under-13 block replaces the input state, the `CupertinoPicker` element is destroyed. Returning via "Try a different year" builds a *fresh* element, so `initialItem` applies again and the wheel snaps back to `currentYear - 18` — while `_selectedYear` still holds the rejected year. The user sees 2008, taps Continue, and is blocked for a year that is not on screen. The spec requires the wheel to return "showing the previously selected year" (design spec line 149).

Note that during ordinary scrolling the rebuild is harmless: `Scrollable.didUpdateWidget` hands the new controller the old position, so the wheel does not jump. The desync appears *only* across the block → retry transition, which is why no existing test caught it.

**Interfaces:**
- Consumes: nothing new.
- Produces: no public API change. `OnboardingAgeGateStep({required VoidCallback onAgeGatePassed, required int currentYear})` is unchanged.

- [ ] **Step 1: Write the failing test**

Append to `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`, before the closing `}` of `main`:

```dart
  testWidgets('retry resumes the wheel at the rejected year, not the default',
      (tester) async {
    await pumpStep(tester);

    // 2008 (default) + 6 items = 2014, which is under 13 in 2026.
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -32.0 * 6));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try a different year'));
    await tester.pumpAndSettle();

    // One item further down. Resuming at 2014 lands on 2015 and blocks again;
    // snapping back to the 2008 default would land on 2009 and pass. Blocking
    // is therefore the assertion that proves the wheel kept its place.
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -32.0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text("Sorry, this app isn't available for users under 13."),
      findsOneWidget,
    );
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
Expected: the new test FAILS — `Expected: exactly one matching candidate / Actual: _TextFinder:<zero widgets>`, because the wheel snapped back to 2008 and 2009 passed the gate. The other four tests pass.

- [ ] **Step 3: Anchor the wheel to the selected year and own the controller**

In `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`, replace the state class fields and `_buildInput`'s wheel construction. The full state class becomes:

```dart
class _OnboardingAgeGateStepState extends ConsumerState<OnboardingAgeGateStep> {
  static const _minAge = 13;
  late final int _minYear = widget.currentYear - 100;
  late final int _maxYear = widget.currentYear;
  late final int _defaultYear = widget.currentYear - 18;
  late final List<int> _years = List<int>.generate(
    _maxYear - _minYear + 1,
    (i) => _minYear + i,
  );
  late int _selectedYear = _defaultYear;
  FixedExtentScrollController? _wheelController;
  bool _blocked = false;
  bool _saving = false;

  /// Built lazily so that a wheel rebuilt after the block state resumes at
  /// the year the user actually chose, not at the default.
  FixedExtentScrollController get _wheel {
    return _wheelController ??= FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear),
    );
  }

  @override
  void dispose() {
    _wheelController?.dispose();
    super.dispose();
  }

  void _resumeInput() {
    setState(() {
      _blocked = false;
      // The picker element was destroyed by the block state; drop its
      // controller so the next build re-anchors on _selectedYear.
      _wheelController?.dispose();
      _wheelController = null;
    });
  }

  Future<void> _onContinue() async {
    final cutoff = widget.currentYear - _minAge;
    if (_selectedYear > cutoff) {
      setState(() => _blocked = true);
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(appPreferencesRepositoryProvider);
      await repo.setPassedAgeGate(value: true);
      ref.invalidate(appPreferencesRepositoryProvider);
      widget.onAgeGatePassed();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_blocked) return _buildBlocked(context);
    return _buildInput(context);
  }

  Widget _buildInput(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Quick check', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              'When were you born?',
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: _wheel,
                onSelectedItemChanged: (i) =>
                    setState(() => _selectedYear = _years[i]),
                children: [
                  for (final y in _years) Center(child: Text('$y')),
                ],
              ),
            ),
            BoardButton(
              label: 'Continue',
              onPressed: _saving ? null : _onContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocked(BuildContext context) {
    final styles = context.textStyles;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sorry, this app isn't available for users under 13.",
              style: styles.headlineMedium,
            ),
            const SizedBox(height: 24),
            BoardButton(
              label: 'Try a different year',
              secondary: true,
              onPressed: _resumeInput,
            ),
          ],
        ),
      ),
    );
  }
}
```

Two things changed beyond the anchoring: the `_yearSelected` field is gone (that is Task 2's subject, and the code above already reflects it — do both in this edit and let Task 2's test cover it), and the controller is now disposed rather than reallocated on every scroll tick.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
Expected: 4 of 5 pass; `renders the prompt and disabled Continue initially` now FAILS because Continue is enabled. Task 2 Step 1 rewrites that test. Do not revert the enablement to make it pass.

- [ ] **Step 5: Commit after Task 2**

This task and Task 2 touch the same lines and land in one commit at the end of Task 2.

---

## Task 2: Continue is enabled at the default year

**Files:**
- Modify: `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`

**The defect:** `_yearSelected` started `false`, so Continue was inert until the user scrolled the wheel — while a perfectly valid 2008 sat visible on screen with no hint that anything was missing. Someone actually born in 2008 had to scroll away and back.

**The reasoning, recorded here because it is a product decision and not a bug:** an age gate is self-declared and unverifiable; its function is that we asked, not that we obstructed. No wheel position makes a blind tap fail — 1926 passes as surely as 2008 — so requiring a scroll is ceremony that costs every honest user and stops no one. A disabled button beside a visible, valid value also reads as a broken screen. The counter-position (keep the requirement, add a "Scroll to your birth year" hint so at least it is legible) is recorded in the audit; if you are reading this because that call was reversed, the change is to restore `_yearSelected` and add the hint line, not to revert Task 1.

**Interfaces:**
- Consumes: `_onContinue`, `_saving` from Task 1's state class.
- Produces: no API change.

- [ ] **Step 1: Rewrite the enablement test**

In `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`, replace the whole `renders the prompt and disabled Continue initially` test with:

```dart
  testWidgets('renders the prompt with Continue enabled at the default year',
      (tester) async {
    await pumpStep(tester);

    expect(find.text('Quick check'), findsOneWidget);
    expect(find.text('When were you born?'), findsOneWidget);
    final cont = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Continue'));
    expect(cont.onPressed, isNotNull);
  });

  testWidgets('Continue at the untouched default passes the gate',
      (tester) async {
    var passed = 0;
    await pumpStep(tester, onPassed: () => passed++);

    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(passed, equals(1));
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });
```

- [ ] **Step 2: Run the file to verify everything is green**

Run: `flutter test test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
Expected: 6 tests pass. Task 1's implementation already removed `_yearSelected`, so no further source edit is needed.

- [ ] **Step 3: Format and analyze**

Run: `dart format lib/features/onboarding test/features/onboarding && flutter analyze lib/features/onboarding`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_age_gate_step.dart test/features/onboarding/presentation/onboarding_age_gate_step_test.dart
git commit -m "fix(onboarding): keep the age-gate wheel and its accepted year in sync"
```

---

## Task 3: Lift the exam row into a shared component

**Files:**
- Create: `lib/core/ui/components/exam_selection_row.dart`
- Modify: `lib/features/onboarding/presentation/onboarding_picker_step.dart`

Task 4 needs this row inside `features/settings/`, and R2 forbids importing it from `features/onboarding/`. `core/ui/` is the only legal shared home, and the row imports nothing but `core/storage/domain/exam.dart` and theme tokens, so R1 and R3 are satisfied.

Not a pure lift: the emulator pass showed the emblem column breaking. At `width: 56` every code over about five characters wrapped mid-word — `CSE_PRO` rendered as "CSE_P / RO", `DLSUCET` as "DLSUC / ET", `PUPCET` as "PUPCE / T". Only ACET, UPCAT and USTET fitted. The component below therefore widens the column and switches from `exam.code` to `exam.shortName`, which is already in the schema and holds the human form ("CSE Pro" rather than "CSE_PRO"). The 96px width is a starting point — check it on device against the longest shortName before calling the task done.

**Interfaces:**
- Produces: `ExamSelectionRow({required Exam exam, required bool selected, required VoidCallback onTap, Key? key})`. Task 4 consumes exactly this.

- [ ] **Step 1: Create the shared component**

Create `lib/core/ui/components/exam_selection_row.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One exam in a pick-one list: emblem code, full name, and the answer-device
/// selection treatment (tint fill plus a board border) when chosen.
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: selected
            ? BoxDecoration(
                color: colors.boardTint,
                border: Border.all(color: colors.board),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                ),
              ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Text(
                // shortName, not code: `code` is a raw identifier that renders
                // as CSE_PRO / CSE_SUB, and at 56px anything over ~5 characters
                // wrapped mid-word — DLSUCET became "DLSUC / ET". Ellipsis
                // rather than wrap so a long name degrades on one line.
                exam.shortName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.headlineSmall.copyWith(
                  color: selected ? colors.board : colors.inkMuted,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exam.name,
                style: styles.bodyMedium.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Point the picker step at it**

In `lib/features/onboarding/presentation/onboarding_picker_step.dart`:

Delete the entire private `class _ExamRow extends StatelessWidget { ... }` at the bottom of the file (lines 117–178).

Replace the import block's `app_dimensions.dart` and `exam.dart` imports with the shared component — the file's imports become:

```dart
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/exam_selection_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

And change the `itemBuilder` body from `_ExamRow(` to `ExamSelectionRow(`:

```dart
                    itemBuilder: (_, i) {
                      final exam = active[i];
                      return ExamSelectionRow(
                        exam: exam,
                        selected: _selectedId == exam.id,
                        onTap: () => setState(() => _selectedId = exam.id),
                      );
                    },
```

- [ ] **Step 3: Run the picker tests**

Run: `flutter test test/features/onboarding/presentation/onboarding_picker_step_test.dart`
Expected: all tests pass with no edits. The fixtures seed `shortName` equal to `code` (`shortName: 'CSE'`, `shortName: 'UPCAT'`), so the emblem assertions hold through the `code` → `shortName` switch.

That equality is also why the existing suite never caught the wrapping. Add a case that separates the two, so a regression to `exam.code` fails:

```dart
  testWidgets('emblem shows the human short name, not the raw code',
      (tester) async {
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'cse_pro',
          code: 'CSE_PRO',
          name: 'Civil Service Examination — Professional',
          shortName: 'CSE Pro',
          language: 'en',
        ));

    await pumpStep(tester);

    expect(find.text('CSE Pro'), findsOneWidget);
    expect(find.text('CSE_PRO'), findsNothing);
  });
```

- [ ] **Step 4: Check layering and analyze**

Run: `dart run tool/check_layering.dart && flutter analyze lib/core/ui lib/features/onboarding`
Expected: exit 0 and `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/exam_selection_row.dart lib/features/onboarding/presentation/onboarding_picker_step.dart
git commit -m "refactor(ui): share the exam selection row between onboarding and settings"
```

---

## Task 4: Settings → Exam, the switch the picker promises

**Files:**
- Create: `lib/features/settings/presentation/pages/exam_page.dart`
- Create: `test/features/settings/presentation/exam_page_test.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/features/settings/presentation/settings_home_page.dart`

The picker step prints "You can switch later in Settings." and no such surface exists. The May design spec assigned exam switching to "More/Settings per Phase 1" and marked it out of scope for onboarding, so it was always another document's job and nobody picked it up.

Selection is persisted through the same call the onboarding picker uses — `AppPreferencesRepository.setSelectedExamId` — and invalidating `appPreferencesRepositoryProvider` rebuilds `activeExamFocusProvider`, which watches it.

**Interfaces:**
- Consumes: `ExamSelectionRow` (Task 3); `examListProvider`, `activeExamFocusProvider`, `appPreferencesRepositoryProvider` from `core/storage/storage.dart`.
- Produces: route `/settings/exam`; `ExamPage` (no constructor arguments).

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/presentation/exam_page_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/exam_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'cse',
          code: 'CSE',
          name: 'Civil Service Exam',
          shortName: 'CSE',
          language: 'en',
        ));
    await db.into(db.exams).insert(ExamsCompanion.insert(
          id: 'upcat',
          code: 'UPCAT',
          name: 'UPCAT',
          shortName: 'UPCAT',
          language: 'en',
        ));
    await AppPreferencesRepository(db).setSelectedExamId('cse');
  });

  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const ExamPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists active exams with the current one preselected',
      (tester) async {
    await pumpPage(tester);

    expect(find.text('Civil Service Exam'), findsOneWidget);
    expect(find.text('UPCAT'), findsWidgets);
    final save = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Save'));
    expect(save.onPressed, isNull, reason: 'nothing changed yet');
  });

  testWidgets('choosing a different exam enables Save and persists it',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('UPCAT').first);
    await tester.pump();

    final save = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Save'));
    expect(save.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(BoardButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      await AppPreferencesRepository(db).selectedExamId(),
      equals('upcat'),
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/settings/presentation/exam_page_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../pages/exam_page.dart'`.

- [ ] **Step 3: Implement the page**

Create `lib/features/settings/presentation/pages/exam_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/exam_selection_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key});

  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage> {
  String? _pendingId;
  bool _saving = false;

  Future<void> _onSave() async {
    final id = _pendingId;
    if (id == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(appPreferencesRepositoryProvider).setSelectedExamId(id);
      ref.invalidate(appPreferencesRepositoryProvider);
      if (mounted) Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Couldn't save your exam. Try again."),
          action: SnackBarAction(label: 'Retry', onPressed: _onSave),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final examsAsync = ref.watch(examListProvider);
    final currentId = ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id;
    final selectedId = _pendingId ?? currentId;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choose your exam', style: styles.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Your home, study, and quiz tabs follow this choice.',
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: examsAsync.when(
                  loading: () => const FaintBars(),
                  error: (_, __) => Center(
                    child: Text(
                      'Could not load exams.',
                      style: styles.bodyMedium.copyWith(color: colors.inkMuted),
                    ),
                  ),
                  data: (exams) {
                    final active = [...exams.where((e) => e.isActive)]
                      ..sort((a, b) => a.name.compareTo(b.name));
                    if (active.isEmpty) {
                      return Center(
                        child: Text(
                          'No exams available right now.',
                          style: styles.bodyMedium
                              .copyWith(color: colors.inkMuted),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: active.length,
                      itemBuilder: (_, i) {
                        final exam = active[i];
                        return ExamSelectionRow(
                          exam: exam,
                          selected: selectedId == exam.id,
                          onTap: () => setState(() => _pendingId = exam.id),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BoardButton(
                label: 'Save',
                onPressed: (_saving ||
                        _pendingId == null ||
                        _pendingId == currentId)
                    ? null
                    : _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Save stays disabled until the pending choice differs from the current one, so the button never implies a write that would change nothing.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/settings/presentation/exam_page_test.dart`
Expected: 2 tests pass.

- [ ] **Step 5: Add the route**

In `lib/app/router.dart`, add the import beside the other settings page imports (they are alphabetical — it goes after `delete_account_page.dart`):

```dart
import 'package:cse_cet_reviewer/features/settings/presentation/pages/exam_page.dart';
```

And add the route immediately after the `/settings/backup` route:

```dart
      GoRoute(
        path: '/settings/exam',
        builder: (_, __) => const ExamPage(),
      ),
```

- [ ] **Step 6: Add the Settings row**

In `lib/features/settings/presentation/settings_home_page.dart`, add a row at the top of the `Preferences` section's children — directly above the existing `Daily reminder` row:

```dart
              SettingsRow(
                title: 'Exam',
                subtitle:
                    ref.watch(activeExamFocusProvider).valueOrNull?.exam?.name ??
                        'Not set',
                onTap: () => _go(context, '/settings/exam'),
              ),
```

Add the import if it is not already present:

```dart
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
```

- [ ] **Step 7: Verify the route and the row**

Run: `flutter test test/app/router_redirect_test.dart test/features/settings`
Expected: all pass. The redirect matrix is untouched; `/settings/exam` is a plain push destination with an AppBar back arrow, per UI-001.

- [ ] **Step 8: Commit**

```bash
git add lib/features/settings/presentation/pages/exam_page.dart lib/features/settings/presentation/settings_home_page.dart lib/app/router.dart test/features/settings/presentation/exam_page_test.dart
git commit -m "feat(settings): let users switch exams after onboarding"
```

---

## Task 5: Wire the Daily reminder row

**Files:**
- Modify: `lib/features/settings/presentation/settings_home_page.dart:61-71`
- Test: `test/features/settings/presentation/settings_pickers_test.dart`

The row renders `'Not set'` and its `onTap` is `() {}` when notifications are permitted. Note what the emulator pass showed: because `() {}` is non-null, `SettingsRow` renders its `chevron_right`, so the row actively advertises navigation and then does nothing. Same for `Exam date` (Task 6) and `Send feedback`, which has no owner in this plan — either wire it or drop its `onTap` so the chevron disappears. Everything behind it already exists and is already tested: `SettingsActions.saveReminderTime(SettingsTime)` writes the preference *and* schedules the notification through `notificationServiceProvider` (`settings_providers.dart`), covered by `test/features/settings/application/settings_actions_test.dart`. Only the picker is missing.

This is also where the reminder time belongs. The paywall spec proposed collecting it as an onboarding step; the notifications spec instead specified the single rationale page that actually shipped. Settings wins because asking a user to choose a study time before they have ever studied is asking for a decision made with no information, at the moment abandonment is most expensive. Task 7 records that resolution in the specs.

**Interfaces:**
- Consumes: `SettingsActions.saveReminderTime(SettingsTime time)`; `SettingsTime({required int hour, required int minute})` from `features/settings/domain/user_settings.dart`.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/presentation/settings_pickers_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SettingsTime maps to and from TimeOfDay', () {
    const time = SettingsTime(hour: 19, minute: 30);
    final tod = TimeOfDay(hour: time.hour, minute: time.minute);

    expect(tod.hour, equals(19));
    expect(tod.minute, equals(30));
    expect(
      SettingsTime(hour: tod.hour, minute: tod.minute).storageValue,
      equals('19:30'),
    );
  });
}
```

The picker dialogs themselves are Flutter-owned; testing `showTimePicker`'s internals would test the framework. What is worth pinning is the conversion at the boundary, which is the only logic this task adds.

- [ ] **Step 2: Run the test to verify it passes**

Run: `flutter test test/features/settings/presentation/settings_pickers_test.dart`
Expected: 1 test passes — `SettingsTime` already exists, so this one is a characterization test rather than a red-green cycle.

- [ ] **Step 3: Wire the row**

In `lib/features/settings/presentation/settings_home_page.dart`, replace the `Daily reminder` row's `onTap` branch:

```dart
              SettingsRow(
                title: 'Daily reminder',
                subtitle: notificationsDenied
                    ? 'Notifications are off - tap to enable'
                    : userSettings.dailyReminderTime?.storageValue ?? 'Not set',
                onTap: notificationsDenied
                    ? () => ref
                        .read(notificationServiceProvider)
                        .openAppNotificationSettings()
                    : () => _pickReminderTime(context, ref, userSettings),
              ),
```

And add this static method beside `_go` at the bottom of the class:

```dart
  static Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final current = settings.dailyReminderTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? const TimeOfDay(hour: 19, minute: 0)
          : TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null) return;
    await ref.read(settingsActionsProvider).saveReminderTime(
          SettingsTime(hour: picked.hour, minute: picked.minute),
        );
  }
```

The 7:00 PM default is the after-work/after-class hour the notifications spec's copy assumes ("one daily study reminder"); it is only the dialog's starting position, not a persisted value.

- [ ] **Step 4: Verify**

Run: `flutter test test/features/settings && flutter analyze lib/features/settings`
Expected: all settings tests pass; `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/presentation/settings_home_page.dart test/features/settings/presentation/settings_pickers_test.dart
git commit -m "feat(settings): pick a daily reminder time"
```

---

## Task 6: Wire the Exam date row

**Files:**
- Modify: `lib/features/settings/presentation/settings_home_page.dart:72-77`

Same shape as Task 5. `DriftSettingsRepository.updateExamDate` already validates that the date is at least tomorrow and throws `InvalidExamDateException` otherwise; bounding the date picker's `firstDate` to tomorrow means that exception is unreachable from this surface.

**Use `SettingsActions.setExamDate`, not `saveExamDate`.** The latter returns "Your study plan is being rebalanced." and calls `studyPlanRebalanceGatewayProvider`, which is wired to `NoopStudyPlanRebalanceGateway` — `/plan` is still a throwing stub (UI-003). Promising a rebalance that cannot happen is exactly the kind of false statement this plan exists to remove. Switch to `saveExamDate` when the study plan is real.

**Interfaces:**
- Consumes: `SettingsActions.setExamDate(DateTime date, {required DateTime today})`.

- [ ] **Step 1: Wire the row**

In `lib/features/settings/presentation/settings_home_page.dart`, replace the `Exam date` row:

```dart
              SettingsRow(
                title: 'Exam date',
                subtitle: _formatDate(userSettings.examDate) ??
                    'Not set - tap to add',
                onTap: () => _pickExamDate(context, ref, userSettings),
              ),
```

And add beside `_pickReminderTime`:

```dart
  static Future<void> _pickExamDate(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final today = DateTime.now();
    final earliest = DateTime(today.year, today.month, today.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: settings.examDate ?? earliest,
      firstDate: earliest,
      lastDate: DateTime(today.year + 3, today.month, today.day),
    );
    if (picked == null) return;
    await ref
        .read(settingsActionsProvider)
        .setExamDate(picked, today: today);
  }
```

- [ ] **Step 2: Verify**

Run: `flutter test test/features/settings && flutter analyze lib/features/settings`
Expected: all pass; `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/presentation/settings_home_page.dart
git commit -m "feat(settings): pick an exam date"
```

---

## Task 7: Reconcile the documents

**Files:**
- Modify: `docs/ui-audit.md`
- Modify: `docs/superpowers/specs/2026-05-16-onboarding-exam-selection-design.md`
- Modify: `docs/superpowers/specs/2026-05-18-study-plan-design.md`
- Modify: `docs/superpowers/specs/2026-05-21-paywall-entitlement-design.md`

Onboarding is governed by nine documents and amended from inside two unrelated specs. The audit that produced this plan cost real time purely to discover that; leaving the drift in place charges that cost again to the next reader.

- [ ] **Step 1: Log the two defects in the audit**

Append to `docs/ui-audit.md`, in the `Findings surfaced while fixing the above` section:

```markdown
### UI-009 [important] Age-gate retry showed a year it would not accept

`onboarding_age_gate_step.dart` anchored the year wheel to `currentYear - 18`
on every fresh build. The under-13 block destroys the picker element, so
"Try a different year" rebuilt it at the default while `_selectedYear` still
held the rejected year: the wheel read 2008, Continue blocked anyway. The
design spec (line 149) required the wheel to return showing the previously
selected year. Fixed by anchoring on `_selectedYear` and giving the
controller a real lifecycle instead of reallocating it on every scroll tick.

### UI-010 [polish] Age-gate Continue was inert beside a valid year

`_yearSelected` started `false`, so the button did nothing until the wheel
was scrolled — with a perfectly valid default year on screen and no hint
that anything was missing. Decision (2026-07-25): enable it. An age gate is
self-declared and unverifiable; no wheel position makes a blind tap fail, so
requiring a scroll taxed honest users and stopped no one, and a dead button
beside a visible value reads as breakage. The alternative — keep the
requirement, add a "Scroll to your birth year" hint — was considered and
rejected as ceremony.
```

- [ ] **Step 2: Give the onboarding spec an amendments table**

In `docs/superpowers/specs/2026-05-16-onboarding-exam-selection-design.md`, insert immediately after the `## Supersession` table:

```markdown
## Later amendments

This spec was amended three times from other documents. They are listed here
so this file remains the single place to learn what onboarding is.

| Amendment | Source | Effect |
|---|---|---|
| Ink & Rule restyle | `plans/2026-07-19-ink-and-rule-feature-sweep.md` Task 9 | The Welcome illustration placeholder described under *Visual Design* is **deleted**, not pending. Steps are serif and left-aligned; `FilledButton` → `BoardButton`. Picker copy is "You can switch later in Settings." |
| Notification permission | `specs/2026-05-22-notifications-fcm-design.md` | A fourth screen, `/notifications/rationale`, follows the picker on first launch, driven by the same router redirect. Supersedes this spec's *Out of Scope* line placing the ask entirely in `features/notifications/`. |
| Reminder time | This plan, 2026-07-25 | The paywall spec's proposed "pick your daily study reminder time" onboarding step is **not built**. Reminder time is collected in Settings, after the user has studied. |
```

- [ ] **Step 3: Correct the study plan spec's mastery source**

In `docs/superpowers/specs/2026-05-18-study-plan-design.md`, line 127 currently reads:

```text
`start_mastery` comes from the diagnostic completed during onboarding (Spec 2/onboarding spec).
```

Replace with:

```text
`start_mastery` comes from the assessment at `/assessment/:examId`, which the
user launches from Home *after* onboarding — not from onboarding itself. The
onboarding diagnostic described in the foundation spec was deliberately
dropped (see `specs/2026-05-16-onboarding-exam-selection-design.md`
§Supersession), so a user who has never run the assessment has no
`start_mastery` at all; the plan must treat that as its own state rather than
assuming a value exists.
```

This is a prerequisite for un-stubbing `/plan` (UI-003): whoever implements `studyPlanExamProvider` would otherwise go looking for data that no code path produces.

- [ ] **Step 4: Correct the paywall spec's permission assumption**

In `docs/superpowers/specs/2026-05-21-paywall-entitlement-design.md`, in the `### Spec 5 — Onboarding (amendment)` section, add at the top of the section:

```markdown
> **Superseded 2026-07-25.** The reminder-time step below was never built.
> Notification permission is acquired by the rationale page specified in
> Spec 9 and shipped at `/notifications/rationale`; the trial-end push
> inherits permission from there. Reminder *time* is collected in Settings.
> The soft trial mention at the "onboarding plan-set celebration" remains
> unbuilt and is blocked on the study plan (UI-003).
```

- [ ] **Step 5: Commit**

```bash
git add docs/ui-audit.md docs/superpowers/specs/
git commit -m "docs: reconcile the onboarding specs with what shipped"
```

---

## Task 8: Remove the empty auth_flow scaffolding

**Files:**
- Delete: `lib/features/auth_flow/data/.gitkeep`, `lib/features/auth_flow/domain/.gitkeep`, `lib/features/auth_flow/presentation/.gitkeep`

All three directories contain nothing but `.gitkeep`. Auth is reachable today through Settings → Account (`account_page.dart`), so the scaffolding points at a feature that lives somewhere else and will mislead the next person who greps for sign-in.

Keeping sign-in out of onboarding stays correct: asking for an account before demonstrating value is a well-documented first-launch killer, and the May spec put it out of scope deliberately.

- [ ] **Step 1: Delete and verify nothing referenced it**

```bash
git rm lib/features/auth_flow/data/.gitkeep lib/features/auth_flow/domain/.gitkeep lib/features/auth_flow/presentation/.gitkeep
grep -rn "auth_flow" lib/ test/ || echo "no references"
```

Expected: `no references`.

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: drop empty auth_flow scaffolding"
```

---

## Task 9: Age-gate wheel presentation

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`

Three presentation findings from the emulator pass, all in one screen, so they land together.

**a. The selection band is a grey pill.** `CupertinoPicker` draws `CupertinoPickerDefaultSelectionOverlay` by default — a light-grey rounded rectangle. That is precisely the pill shape the Ink & Rule sweep hunted and replaced everywhere else, and it is the only one left in the flow.

**b. The wheel is stranded.** `Expanded` hands it the entire middle of the screen, leaving roughly 350 device pixels of blank space between "When were you born?" and the first year.

**c. The block state mixes alignment.** Its headline is left-aligned while "Try a different year" centres itself, because `BoardButton(secondary: true)` centres its label. Reads accidental rather than composed.

- [ ] **Step 1: Replace the overlay and cap the wheel height**

In `_buildInput`, replace the `Expanded`-wrapped picker with a fixed-height box and hairline rules:

```dart
            SizedBox(
              height: 224,
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: _wheel,
                selectionOverlay: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: AppDimensions.hairline, color: colors.rule),
                    Container(height: AppDimensions.hairline, color: colors.rule),
                  ],
                ),
                onSelectedItemChanged: (i) =>
                    setState(() => _selectedYear = _years[i]),
                children: [
                  for (final y in _years) Center(child: Text('$y')),
                ],
              ),
            ),
            const Spacer(),
```

Add the import if absent:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
```

224 is seven rows at the 32px item extent — enough context above and below the selection without the wheel floating in the middle of the page. The trailing `Spacer` keeps `Continue` pinned to the bottom now that the picker no longer expands.

- [ ] **Step 2: Left-align the block state's action**

In `_buildBlocked`, wrap the button so it sits under the headline's left edge rather than centring:

```dart
            Align(
              alignment: Alignment.centerLeft,
              child: BoardButton(
                label: 'Try a different year',
                secondary: true,
                onPressed: _resumeInput,
              ),
            ),
```

- [ ] **Step 3: Verify the existing age-gate tests still pass**

Run: `flutter test test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
Expected: 6 tests pass. The drag offsets in those tests are computed from `itemExtent`, which is unchanged, so a fixed height does not affect them.

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_age_gate_step.dart
git commit -m "onboarding: give the age-gate wheel an Ink & Rule selection band"
```

---

## Task 10: Rename the app to Pantas

**Files:**
- Modify: `android/app/build.gradle.kts:38,44,49`

The app still calls itself "CSE/CET Reviewer". It surfaces inside onboarding at the worst possible moment: the OS notification permission dialog, the one screen in the flow where the system speaks on the app's behalf, reads "Allow **CSE/CET Reviewer Dev** to send you notifications?" The same string is the launcher label.

- [ ] **Step 1: Set the display name per flavor**

In `android/app/build.gradle.kts`, replace the three `resValue` lines:

```kotlin
            resValue("string", "app_name", "Pantas Dev")
            resValue("string", "app_name", "Pantas Staging")
            resValue("string", "app_name", "Pantas")
```

They sit in the `dev`, `staging`, and `prod` blocks respectively — keep each in its own block.

- [ ] **Step 2: Check for other spellings of the old name**

Run: `grep -rn "CSE/CET Reviewer" android ios lib --include=* 2>/dev/null`
Expected: no hits outside generated build output. If iOS carries a `CFBundleDisplayName`, set it to `Pantas` too.

Note: the Dart package is still `cse_cet_reviewer`, and every import in the codebase depends on that name. Renaming the package is a separate, far larger change — out of scope here. This task changes only what users see.

- [ ] **Step 3: Verify on device**

Rebuild and confirm the launcher label and the notification permission dialog both read "Pantas Dev". This one needs eyes on the screen — hand it over rather than asserting it.

- [ ] **Step 4: Commit**

```bash
git add android/app/build.gradle.kts
git commit -m "chore(android): show the app as Pantas, not CSE/CET Reviewer"
```

---

## Task 11: One vertical rhythm across the onboarding steps

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_welcome_step.dart`
- Modify: `lib/features/notifications/presentation/permission_rationale_page.dart`

The flow now has four screens and three different vertical rhythms:

- Welcome floats its text near the middle, between two `Spacer`s.
- Age gate and picker are top-aligned, headline at a consistent height.
- The rationale page centres everything inside a 420px `ConstrainedBox`.

The design spec asks for "the same top padding and header style so transitions feel like steps inside one flow, not three different screens" — screens 1 and 4 both break it. Align both to the age-gate/picker rhythm, which is the majority and the one the spec describes.

- [ ] **Step 1: Top-align the welcome step**

In `onboarding_welcome_step.dart`, replace the leading `const Spacer()` with the same fixed lead-in the other steps use, keeping the trailing `Spacer` so the CTA stays pinned:

```dart
          children: [
            const SizedBox(height: 24),
            Text('Build your study plan', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              "Pick your exam — we'll guide what to study first.",
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            const Spacer(),
            BoardButton(label: 'Get started', onPressed: onAdvance),
          ],
```

- [ ] **Step 2: Top-align the rationale page**

In `permission_rationale_page.dart`, drop the `Center` + `ConstrainedBox(maxWidth: 420)` wrapper and use the step layout:

```dart
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text("I'll be your coach.", style: styles.displaySmall),
              const SizedBox(height: 16),
              Text(
                'Get one daily study reminder and a streak-save warning '
                'when you still have work left today.',
                style: styles.bodyLarge.copyWith(color: colors.inkMuted),
              ),
              const Spacer(),
              BoardButton(
                label: 'Sounds good',
                onPressed:
                    _isSaving ? null : () => _continue(requestPermission: true),
              ),
              const SizedBox(height: 8),
              BoardButton(
                label: 'Not right now',
                secondary: true,
                onPressed:
                    _isSaving ? null : () => _continue(requestPermission: false),
              ),
            ],
          ),
        ),
      ),
```

- [ ] **Step 3: Run the affected tests**

Run: `flutter test test/features/onboarding test/features/notifications`
Expected: all pass. Both edits are layout-only; the copy and callbacks are unchanged, so text-finder assertions still hold.

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_welcome_step.dart lib/features/notifications/presentation/permission_rationale_page.dart
git commit -m "onboarding: give every step the same vertical rhythm"
```

---

## Task 12: Stop Welcome and Home sharing a headline

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_welcome_step.dart`
- Modify: `test/features/onboarding/presentation/onboarding_welcome_step_test.dart`

Welcome reads "Build your study plan"; Home, reached moments later, reads "Build your study plan". The design spec asked for that echo deliberately, so users "feel one continuous narrative" — but in sequence it reads as though the flow never advanced. Onboarding is also the only place a wordmark could plausibly live, and the app currently never says "Pantas" anywhere in the flow.

**This one is a copy decision, so treat the strings below as a proposal rather than a settled requirement.** The structure is what matters; swap the words freely.

- [ ] **Step 1: Update the copy and add the wordmark**

```dart
          children: [
            const SizedBox(height: 24),
            Text('Pantas', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              'Pass your exam with a plan, not a pile of practice tests.',
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            const Spacer(),
            BoardButton(label: 'Get started', onPressed: onAdvance),
          ],
```

- [ ] **Step 2: Update the widget test**

In `onboarding_welcome_step_test.dart`, replace the two headline/subtitle expectations:

```dart
    expect(find.text('Pantas'), findsOneWidget);
    expect(
      find.text('Pass your exam with a plan, not a pile of practice tests.'),
      findsOneWidget,
    );
```

- [ ] **Step 3: Update the redirect test that asserts the welcome headline**

`test/app/router_redirect_test.dart` asserts `find.text('Build your study plan')` to prove the app booted into onboarding. That string now belongs to Home only, so the assertion would pass for the wrong reason. Change it to `find.text('Pantas')`.

Run: `flutter test test/app/router_redirect_test.dart test/features/onboarding`
Expected: all pass.

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_welcome_step.dart test/features/onboarding/presentation/onboarding_welcome_step_test.dart test/app/router_redirect_test.dart
git commit -m "onboarding: give the welcome step its own headline"
```

---

## Task 13: Verification

**Files:** none — verification only.

- [ ] **Step 1: Analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Layering**

Run: `dart run tool/check_layering.dart`
Expected: exit 0. The one new cross-cutting file, `core/ui/components/exam_selection_row.dart`, imports only `core/` — R1 clean.

- [ ] **Step 3: Format**

Run: `dart format --set-exit-if-changed lib test`
Expected: exit 0.

- [ ] **Step 4: Full suite**

Run: `flutter test`
Expected: all pass. Net new cases: +1 age-gate wheel test, +1 age-gate default-year test (replacing the disabled-button test), +2 exam page, +1 settings time mapping.

Note: `test/core/storage/data/seeder_test.dart` fails against the throwaway dev seed described at the top of `docs/ui-audit.md`. If it fails, confirm the failure is that pre-existing seed mismatch and not something this plan caused.

- [ ] **Step 5: Manual smoke on the emulator**

Double-click `tools/onboarding-rebuild.command`, or:

```bash
adb shell pm clear com.aerol.csecet.dev
flutter run --flavor dev -t lib/main_dev.dart
```

For repeat passes without a rebuild, use `tools/onboarding-restart.command`.

Verify, on `pantas_pixel`:
- Welcome → Get started → Quick check.
- Continue is tappable immediately; tapping it at the untouched default advances.
- Restart, scroll to an under-13 year, Continue → block screen → "Try a different year" → **the wheel shows the year you entered**, not 2008.
- Picker lists every active exam; Continue disabled until a row is tapped.
- Rationale page → "Sounds good" → Home.
- Settings → Exam shows the current exam, switching it changes the Home tab's exam.
- Settings → Daily reminder opens a time picker and the row's subtitle updates.
- Settings → Exam date opens a date picker that cannot select today or earlier.

---

## Self-Review

**Coverage of the findings this plan came from:**

- Age-gate retry desync (UI-009) — Task 1.
- Age-gate dead Continue (UI-010) — Task 2.
- "Switch later in Settings" with no such surface — Tasks 3 + 4.
- Dead `Daily reminder` row — Task 5.
- Dead `Exam date` row — Task 6.
- Welcome-illustration contradiction — Task 7 Step 2 (documentation only; the illustration stays deleted).
- Two incompatible notification-permission designs — Task 7 Steps 2 and 4.
- `start_mastery` sourced from a diagnostic that does not exist — Task 7 Step 3.
- Exam-date onboarding step — deliberately not built; the provisional-then-confirm design the study plan spec already anticipates is served by Task 6.
- Plan-set celebration + soft trial mention — deliberately not built; blocked on UI-003, recorded in Task 7 Step 4.
- Empty `auth_flow/` — Task 8.

**Coverage of the emulator pass (2026-07-25):**

- Emblem codes wrapping mid-word; `code` shown instead of `shortName` — Task 3.
- Dead Settings rows rendering chevrons, including `Send feedback` — Tasks 5–6.
- `CupertinoPicker`'s grey pill selection band — Task 9a.
- Wheel stranded in the middle of the screen — Task 9b.
- Block-state alignment mismatch — Task 9c.
- App still named "CSE/CET Reviewer" in the OS permission dialog and launcher — Task 10.
- Four screens, three vertical rhythms — Task 11.
- Welcome and Home sharing a headline; no wordmark anywhere — Task 12.
- Contentless roster exams, and alphabetical sort burying the real ones — resolved outside this plan (`isActive: false`, commit `434c230`).

**Placeholder scan:** none. Every code step carries complete, runnable code; every command has an expected result.

**Type consistency:**
- `ExamSelectionRow({required Exam exam, required bool selected, required VoidCallback onTap})` — same signature in Task 3's definition and both call sites (Task 3 Step 2, Task 4 Step 3).
- `SettingsTime({required int hour, required int minute})` and `.storageValue` — matches `domain/user_settings.dart` as read.
- `SettingsActions.saveReminderTime(SettingsTime)` and `.setExamDate(DateTime, {required DateTime today})` — match `application/settings_providers.dart` as read.
- `AppPreferencesRepository.setSelectedExamId(String)` — matches the onboarding picker's existing call.
- `activeExamFocusProvider.valueOrNull?.exam?.id` — `ActiveExamFocus.exam` is `Exam?`, so both `?.` are required.

**Known gap:** this plan is written from a code read. The emulator pass that follows will likely add findings — copy, spacing, the sparseness of the Welcome screen, and how the four steps feel in sequence. Those land as new tasks appended here, not as edits to the nine above.
