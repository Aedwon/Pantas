# Quiz Tab, Plan 2c of 6: The Mock Panel, the Practice Rows and the Flagged Section

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

**Goal:** Finish the Quiz tab. The mock panel with its four states and its cooldown, the
tier line stated in every one of them, real counts on the practice rows, and the flagged
section.

**Architecture:** One pure formatter, one new panel widget built inside `features/mock_exam`
and handed to the Quiz tab by the router, two providers for the row counts, and one
deletion. The mock's availability and cooldown logic already exists and is not rewritten.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-quiz-tab-design.md`, Section 1 "The mock
panel", "Practice rows" and "The flagged section", plus Section 7 "The tier line".

**Decision log:** `docs/superpowers/decisions/2026-07-28-quiz-tab-decision-log.md`, the
2 August entry "the mock panel's middle figure". Read it first. It records why the panel
shows two figures and not the three the spec drew.

**Depends on:** Plans 2a and 2b, both merged. This plan uses `RuledPanel` from 2a and mounts
its panel directly beneath 2b's session panel.

---

## What is broken underneath, found by reading the code

1. **`MockQuizTabTile` exists, is tested, and is referenced nowhere in `lib/`.** It reads
   "Mock ready" or "Next mock in 3 days" inside a `RuledSection`, with none of the spec's
   four states, no figures and no tier line. It is the surface this plan replaces.
2. **`mockEntitlementProvider` returns `const MockEntitlementSnapshot(proIsActive: false)`,
   hardcoded.** `mockAvailabilityProvider` reads it to decide whether the 14-day cooldown
   applies, so **every Pro user is currently held in the Free cooldown.** Task 4.
3. **`MockQuizTabTile`'s cooldown reads `.inDays`,** so a cooldown of 23 hours displays as
   "Next mock in 0 days". The spec asks for `9d 14h` precisely so an alarm can be set.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** It holds `PageScaffold`,
  `RuledSection`, `RuledPanel`, `SectionHeader`, `StatsBand`, `InkTableRow`, `EmptyState`,
  `ErrorBanner`, `FaintBars`, `BoardButton`, `ConfirmationDialog`. Also check
  `lib/features/mock_exam/presentation/widgets/`, which already holds `MockStatusCard`,
  `MockResumeSheet` and the tile this plan deletes.
- **Never invent a figure.** Every number here is counted from the student's own record or
  published by the testing body. The spec's "parts passed" figure was cut on 2 August
  because no per-section pass mark exists anywhere in this app; do not reintroduce it.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer.
- **Colour carries meaning.** The session panel from 2b owns this screen's one primary
  `BoardButton`. **Every button in this plan is `secondary: true`.**
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. It is an **exam**
  and you **take** it: never "paper", never "sit". Scores are **points**, never marks.
- **Navigation rule (UI-001).** `push` for destinations outside the tab shell.
- **Layering.** R1, R2, R3 as enforced by `tool/check_layering.dart`. **The baseline is 7
  violations.** This plan must not add an eighth, which is why the panel is built inside
  `features/mock_exam` and passed to the Quiz tab by the router rather than imported.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/features/mock_exam/domain/cooldown_label.dart` — `9d 14h`. Pure, so it can be
  tested without a widget.
- `lib/features/mock_exam/presentation/widgets/mock_panel.dart` — the four states.
  In `features/mock_exam` because it reads `MockAvailability` and `MockAttempt`; the Quiz
  tab receives it as a `Widget` and never imports the feature.
- `lib/features/mock_exam/application/mock_panel_providers.dart` — the last submitted
  attempt for the panel's figures.
- `lib/features/quiz/presentation/practice_row_providers.dart` — the mistake count and the
  flag count.
- Tests mirroring each.

**Modify:**
- `lib/app/bootstrap.dart` — override `mockEntitlementProvider` with the real entitlement.
- `lib/app/router.dart` — build the panel and pass it to `QuizTabHome`.
- `lib/features/quiz/presentation/quiz_tab_home.dart` — accept the panel, add the row
  counts and the flagged section.

**Delete:**
- `lib/features/mock_exam/presentation/widgets/mock_quiz_tab_tile.dart`
- `test/features/mock_exam/presentation/mock_quiz_tab_tile_test.dart`

**Not touched:** the mock setup, session and results screens, which are the mock UI spec's
own plans. The flagged **list**, which is seam 6's review component: this plan builds the
section and its count, and the row stays untappable until that exists, exactly as 2a left
"Choose what to practice".

---

## Task 1: Delete `MockQuizTabTile`

**Files:**
- Delete: `lib/features/mock_exam/presentation/widgets/mock_quiz_tab_tile.dart`
- Delete: `test/features/mock_exam/presentation/mock_quiz_tab_tile_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing. `MockQuizTabTile` stops existing.

**Why first, and why at all.** It is the Quiz tab's mock surface, it has never been mounted,
and everything the spec asks for is different: four states not three, a `RuledPanel` not a
`RuledSection`, figures, a cooldown to the hour, and a tier line in every state. Deleting it
before writing the replacement means nothing gets built against it by accident, which is the
same reasoning that retired `DrillSubtopicBrowser` in Plan 2a.

- [ ] **Step 1: Confirm it is unreferenced**

Run: `grep -rn "MockQuizTabTile\|mock_quiz_tab_tile" --include="*.dart" lib test`
Expected: the widget file, its test, and nothing else.

**If anything else references it, stop and say so.** The premise of this task is that it is
dead.

- [ ] **Step 2: Delete both files**

```bash
git rm lib/features/mock_exam/presentation/widgets/mock_quiz_tab_tile.dart \
       test/features/mock_exam/presentation/mock_quiz_tab_tile_test.dart
```

Check whether `lib/features/mock_exam/mock_exam.dart` exports it, and remove the export if
so.

- [ ] **Step 3: Verify**

Run: `grep -rn "MockQuizTabTile" --include="*.dart" lib test`
Expected: no output.

Run: `flutter analyze && flutter test test/features/mock_exam/`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
dart format lib test
git add -A lib/features/mock_exam test/features/mock_exam
git commit -m "refactor(mock): remove the unmounted quiz tab tile

It was written for the Quiz tab and never put on it. The panel the spec
asks for has four states rather than three, figures, a cooldown to the
hour and a tier line, so nothing in it survives."
```

---

## Task 2: The cooldown label

**Files:**
- Create: `lib/features/mock_exam/domain/cooldown_label.dart`
- Test: `test/features/mock_exam/domain/cooldown_label_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `String cooldownLabel(Duration remaining)`. Task 3 puts it in the panel's
  trailing count slot.

**From the spec, Section 1:** the trailing count is "the **cooldown, precise to the hour**:
`9d 14h`. Absent when no cooldown applies."

**From the decision log, 27 July:** `"in 9 days" is imprecise` became `9d 14h`, "so an alarm
can be set". The tile being deleted read `.inDays`, so 23 hours left displayed as "0 days".

**Rounding is up, at the hour.** A student told "0h" who then finds the button still locked
has been lied to. Anything above zero shows at least "1h".

- [ ] **Step 1: Write the failing test**

Create `test/features/mock_exam/domain/cooldown_label_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/mock_exam/domain/cooldown_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('days and hours', () {
    expect(
      cooldownLabel(const Duration(days: 9, hours: 14)),
      '9d 14h',
    );
  });

  test('hours alone when under a day', () {
    expect(cooldownLabel(const Duration(hours: 14)), '14h');
  });

  test('days alone when the hours are zero', () {
    expect(cooldownLabel(const Duration(days: 9)), '9d');
  });

  test('part of an hour still shows an hour', () {
    expect(cooldownLabel(const Duration(minutes: 20)), '1h');
  });

  test('a finished cooldown has no label', () {
    expect(cooldownLabel(Duration.zero), isNull);
    expect(cooldownLabel(const Duration(seconds: -5)), isNull);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/mock_exam/domain/cooldown_label_test.dart`
Expected: FAIL. `cooldown_label.dart` does not exist.

- [ ] **Step 3: Write the formatter**

Create `lib/features/mock_exam/domain/cooldown_label.dart`:

```dart
/// The mock panel's trailing count: "9d 14h", precise to the hour.
///
/// Precise because a student setting an alarm needs to know which day it
/// reopens on, and "in 9 days" does not say. The tile this replaced read
/// `.inDays`, so 23 hours left displayed as "0 days".
///
/// Returns null when nothing is left to wait for, because the panel's header
/// carries a count or nothing at all.
String? cooldownLabel(Duration remaining) {
  if (remaining <= Duration.zero) return null;

  // Round part hours up. "0h" on a button that is still locked is a lie, and
  // the error is at most an hour on a fourteen day wait.
  final totalHours = (remaining.inMinutes / 60).ceil();
  final days = totalHours ~/ 24;
  final hours = totalHours % 24;

  if (days == 0) return '${hours}h';
  if (hours == 0) return '${days}d';
  return '${days}d ${hours}h';
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/mock_exam/domain/cooldown_label_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/mock_exam/domain/cooldown_label.dart \
        test/features/mock_exam/domain/cooldown_label_test.dart
git commit -m "feat(mock): the cooldown reads to the hour

'in 9 days' does not tell a student which day it reopens on, and the
tile it replaces read inDays, so 23 hours left showed as 0 days."
```

---

## Task 3: The mock panel

**Files:**
- Create: `lib/features/mock_exam/application/mock_panel_providers.dart`
- Create: `lib/features/mock_exam/presentation/widgets/mock_panel.dart`
- Test: `test/features/mock_exam/presentation/mock_panel_test.dart`

**Interfaces:**
- Consumes: `RuledPanel` (2a), `StatsBand` with `centred` and `compact` (2b),
  `MockAvailability`, `MockAttempt`, `cooldownLabel` from Task 2.
- Produces, relied on by Task 5:

```dart
MockPanel({
  required MockAvailability availability,
  required MockAttempt? lastAttempt,
  required bool proIsActive,
  required VoidCallback onTake,
  required VoidCallback onResume,
  required VoidCallback onViewResults,
})
```
  plus `lastSubmittedMockProvider`, a
  `FutureProvider.family<MockAttempt?, MockAvailabilityRequest>`.

**From the spec, Section 1:**

| State | Body |
|---|---|
| Never taken | "The whole thing under exam timing. 3 hours 30, and no answers until the end." Then the tier rule. Secondary button "Take the exam" |
| Free, in cooldown | Figures, then the tier rule with the reopen date, then "View your full results from last time" |
| Available with history | Figures, the tier rule, the results link, secondary button "Take another" |
| Session in progress | "Finish your session first. It runs 3 hours 30 and can't be paused." Then the tier rule. No button |

Heading "Mock exam". Trailing count is the cooldown, absent when none applies.

**The tier rule always states itself**, on its own line opened by a 1px `ruleFaint`, in 12
`inkMuted`:

- Free: "**Free users** get one every two weeks. Your next one opens on **5 August**."
- Pro: "**Pro users** can take as many as they want."

**Two figures, not three.** Settled 2 August: **last score** as a percentage and **taken**
as a date. The spec's middle figure, "parts passed" as "3 of 5", was cut because
`SectionResult` carries no pass mark and the only threshold in the app is
`ComputeResults.bandFor`'s whole-paper 75%, which the 17 May mock spec itself calls a
fallback until real per-exam bands load from Sanity. Do not reintroduce it.

**The Free line's date is only shown when there is a cooldown to name.** A Free student who
has never taken one has no reopen date, so their line is "Free users get one every two
weeks." and stops there. Printing a date computed from no attempt would be an invented
figure.

- [ ] **Step 1: Write the failing provider and its test**

Create `lib/features/mock_exam/application/mock_panel_providers.dart`:

```dart
import 'package:cse_cet_reviewer/features/mock_exam/application/mock_availability_provider.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The most recent completed or forfeited attempt for this exam, which is the
/// one the panel's figures describe.
///
/// `lastCooldownAttempt` is exactly this query: newest first, filtered to the
/// two statuses that end an attempt. It is named for the cooldown because that
/// was its first caller, not because it is narrower.
final lastSubmittedMockProvider =
    FutureProvider.family<MockAttempt?, MockAvailabilityRequest>(
  (ref, request) => ref
      .watch(mockAttemptRepoProvider)
      .lastCooldownAttempt(request.userId, request.examId),
);
```

- [ ] **Step 2: Write the failing panel test**

Create `test/features/mock_exam/presentation/mock_panel_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/mock_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

MockAttempt submitted({
  int scoreRaw = 45,
  int scoreTotal = 60,
  DateTime? submittedAt,
}) =>
    MockAttempt(
      id: 'm_1',
      userId: 'local',
      examId: 'exam_cse_pro',
      blueprintId: 'bp_1',
      blueprintName: 'Full paper',
      durationMinutes: 210,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson: '[]',
      elapsedSeconds: 0,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 0,
      scoreRaw: scoreRaw,
      scoreTotal: scoreTotal,
      startedAt: DateTime.utc(2026, 7, 22, 9),
      lastFlushedAt: DateTime.utc(2026, 7, 22, 12),
      submittedAt: submittedAt ?? DateTime.utc(2026, 7, 22, 12),
      updatedAt: DateTime.utc(2026, 7, 22, 12),
    );

Future<void> pumpPanel(
  WidgetTester tester, {
  required MockAvailability availability,
  MockAttempt? lastAttempt,
  bool proIsActive = false,
}) =>
    tester.pumpApp(
      MockPanel(
        availability: availability,
        lastAttempt: lastAttempt,
        proIsActive: proIsActive,
        onTake: () {},
        onResume: () {},
        onViewResults: () {},
      ),
    );

void main() {
  testWidgets('a first time student is told what it is', (tester) async {
    await pumpPanel(tester, availability: const MockAvailability.available());

    expect(find.text('Mock exam'), findsOneWidget);
    expect(
      find.text('The whole thing under exam timing. 3 hours 30, and no '
          'answers until the end.'),
      findsOneWidget,
    );
    expect(find.text('Take the exam'), findsOneWidget);
  });

  testWidgets('the Free rule is stated before the first attempt',
      (tester) async {
    await pumpPanel(tester, availability: const MockAvailability.available());

    expect(
      find.textContaining('get one every two weeks'),
      findsOneWidget,
    );
    expect(find.textContaining('Your next one opens on'), findsNothing);
  });

  testWidgets('the Pro rule is stated too', (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      proIsActive: true,
    );

    expect(
      find.textContaining('can take as many as they want'),
      findsOneWidget,
    );
  });

  testWidgets('a returning student sees two figures and Take another',
      (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      lastAttempt: submitted(),
    );

    expect(find.text('75'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('last score'), findsOneWidget);
    expect(find.text('taken'), findsOneWidget);
    expect(find.text('Take another'), findsOneWidget);
    expect(find.text('View your full results from last time'), findsOneWidget);
  });

  testWidgets('parts passed is not shown', (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      lastAttempt: submitted(),
    );

    expect(find.textContaining('parts'), findsNothing);
    expect(find.textContaining(' of 5'), findsNothing);
  });

  testWidgets('a cooldown shows in the header and offers no button',
      (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.cooldown(
        Duration(days: 9, hours: 14),
      ),
      lastAttempt: submitted(),
    );

    expect(find.text('9d 14h'), findsOneWidget);
    expect(find.text('Take another'), findsNothing);
    expect(find.text('Take the exam'), findsNothing);
    expect(find.text('View your full results from last time'), findsOneWidget);
  });

  testWidgets('a cooldown names the day it reopens', (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.cooldown(
        Duration(days: 9, hours: 14),
      ),
      lastAttempt: submitted(),
    );

    expect(find.textContaining('Your next one opens on'), findsOneWidget);
  });

  testWidgets('an attempt in progress blocks the exam', (tester) async {
    await pumpPanel(
      tester,
      availability: MockAvailability.inProgress(submitted()),
    );

    expect(
      find.text("Finish your session first. It runs 3 hours 30 and can't "
          'be paused.'),
      findsOneWidget,
    );
    expect(find.text('Take the exam'), findsNothing);
    expect(find.text('Take another'), findsNothing);
  });

  testWidgets('every button is secondary, the session panel owns the board',
      (tester) async {
    await pumpPanel(
      tester,
      availability: const MockAvailability.available(),
      lastAttempt: submitted(),
    );

    final buttons = tester.widgetList<BoardButton>(find.byType(BoardButton));
    expect(buttons, isNotEmpty);
    expect(buttons.every((button) => button.secondary), isTrue);
  });
}
```

Add the `BoardButton` import. Check `pump_app.dart`'s `pumpApp` wraps in a `Scaffold`
already; it does, so the panel is passed bare.

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/features/mock_exam/presentation/mock_panel_test.dart`
Expected: FAIL. `mock_panel.dart` does not exist.

- [ ] **Step 4: Write the panel**

Create `lib/features/mock_exam/presentation/widgets/mock_panel.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/cooldown_label.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:flutter/material.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "5 August". The tier line's reopen date and the "taken" figure.
String formatDay(DateTime value) =>
    '${value.day} ${_monthNames[value.month - 1]}';

/// The Quiz tab's second panel.
///
/// Built here rather than in `features/quiz` because it reads
/// [MockAvailability] and [MockAttempt]. The Quiz tab receives it as a plain
/// `Widget` from the router, so no feature imports another.
class MockPanel extends StatelessWidget {
  const MockPanel({
    required this.availability,
    required this.lastAttempt,
    required this.proIsActive,
    required this.onTake,
    required this.onResume,
    required this.onViewResults,
    super.key,
  });

  final MockAvailability availability;

  /// The most recent finished attempt, or null before the first one.
  final MockAttempt? lastAttempt;

  final bool proIsActive;
  final VoidCallback onTake;
  final VoidCallback onResume;
  final VoidCallback onViewResults;

  @override
  Widget build(BuildContext context) {
    final remaining = availability.cooldownRemaining;
    final attempt = lastAttempt;
    final inProgress = availability.state == MockAvailabilityState.inProgress;
    final inCooldown = availability.state == MockAvailabilityState.cooldown;
    final hasHistory = attempt?.submittedAt != null;

    return RuledPanel(
      heading: 'Mock exam',
      count: remaining == null ? null : cooldownLabel(remaining),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (inProgress)
            _Body(
              "Finish your session first. It runs 3 hours 30 and can't be "
              'paused.',
            )
          else if (!hasHistory)
            _Body(
              'The whole thing under exam timing. 3 hours 30, and no answers '
              'until the end.',
            )
          else
            _Figures(attempt: attempt!),
          const SizedBox(height: 12),
          _TierLine(
            proIsActive: proIsActive,
            reopensOn: _reopensOn(remaining),
          ),
          if (hasHistory && !inProgress) ...[
            const SizedBox(height: 4),
            BoardButton(
              label: 'View your full results from last time',
              secondary: true,
              onPressed: onViewResults,
            ),
          ],
          if (inProgress) ...[
            const SizedBox(height: 8),
            BoardButton(
              label: 'Resume',
              secondary: true,
              onPressed: onResume,
            ),
          ] else if (!inCooldown) ...[
            const SizedBox(height: 8),
            BoardButton(
              // The heading already says "Mock exam", so the button does not
              // repeat it. It is an exam and you take it.
              label: hasHistory ? 'Take another' : 'Take the exam',
              secondary: true,
              onPressed: onTake,
            ),
          ],
        ],
      ),
    );
  }

  /// Null unless a cooldown is running. A student who has never taken one has
  /// no reopen date, and computing one from no attempt would be a figure this
  /// app made up.
  DateTime? _reopensOn(Duration? remaining) =>
      remaining == null ? null : DateTime.now().add(remaining);
}

class _Body extends StatelessWidget {
  const _Body(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textStyles.bodyMedium
          .copyWith(color: context.colors.inkMuted),
    );
  }
}

/// Two figures, not three.
///
/// The spec drew "parts passed" between them. It was cut on 2 August:
/// `SectionResult` has no pass mark, and the app's only threshold is
/// `ComputeResults.bandFor`'s whole-paper 75%, which the mock spec calls a
/// fallback until per-exam bands load from Sanity.
class _Figures extends StatelessWidget {
  const _Figures({required this.attempt});

  final MockAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final raw = attempt.scoreRaw;
    final total = attempt.scoreTotal;
    final percent =
        (raw == null || total == null || total == 0) ? null : (raw / total) * 100;

    return StatsBand(
      centred: true,
      compact: true,
      figures: [
        if (percent != null)
          StatFigure(
            value: '${percent.round()}',
            suffix: '%',
            label: 'last score',
          ),
        StatFigure(
          value: formatDay(attempt.submittedAt!),
          label: 'taken',
        ),
      ],
    );
  }
}

/// Stated in every state, on its own line opened by a hairline.
///
/// Always stated so the cadence is learned as a rule of the app rather than
/// discovered as a wall on the ninth day. This is the only visible paywall in
/// the tab.
class _TierLine extends StatelessWidget {
  const _TierLine({required this.proIsActive, this.reopensOn});

  final bool proIsActive;
  final DateTime? reopensOn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final muted = styles.bodySmall.copyWith(color: colors.inkMuted);
    final strong = muted.copyWith(fontWeight: FontWeight.w700, color: colors.ink);
    final reopens = reopensOn;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.ruleFaint,
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: proIsActive
          ? Text.rich(
              TextSpan(
                style: muted,
                children: [
                  TextSpan(text: 'Pro users', style: strong),
                  const TextSpan(text: ' can take as many as they want.'),
                ],
              ),
            )
          : Text.rich(
              TextSpan(
                style: muted,
                children: [
                  TextSpan(text: 'Free users', style: strong),
                  const TextSpan(text: ' get one every two weeks.'),
                  if (reopens != null) ...[
                    const TextSpan(text: ' Your next one opens on '),
                    TextSpan(text: formatDay(reopens), style: strong),
                    const TextSpan(text: '.'),
                  ],
                ],
              ),
            ),
    );
  }
}
```

**`_reopensOn` calls `DateTime.now()` inside a widget**, which makes the tier line's date
untestable to the day and unrepeatable in a golden. If the panel needs a deterministic
clock later, pass the reopen date in from the provider that already knows `submittedAt`
plus 14 days. Left as-is here because `mockAvailabilityProvider` computes the remaining
duration and does not expose the target instant, and widening it is a change to shared
mock code that this plan does not otherwise touch. **Flag it rather than widening it.**

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/features/mock_exam/presentation/mock_panel_test.dart`
Expected: PASS, 9 tests.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib/features/mock_exam test/features/mock_exam
git commit -m "feat(mock): the tab's mock panel, four states and the tier line

The rule is stated in every state including before the first attempt, so
the cadence reads as how the app works rather than as a wall found on the
ninth day. Two figures, not three: no per-section pass mark exists to
count parts passed from."
```

---

## Task 4: Pro users stop being held in the Free cooldown

**Files:**
- Modify: `lib/app/bootstrap.dart`
- Test: `test/app/mock_entitlement_override_test.dart` (create)

**Interfaces:**
- Consumes: `entitlementProvider` from `features/paywall`, `mockEntitlementProvider` from
  `features/mock_exam`.
- Produces: nothing new. `mockAvailabilityProvider` starts telling the truth.

**The defect.** `mockEntitlementProvider` is
`Provider<MockEntitlementSnapshot>((ref) => const MockEntitlementSnapshot(proIsActive: false))`.
`mockAvailabilityProvider` reads it and returns `MockAvailability.available()` early when
Pro is active. Because it never is, **every Pro subscriber sits out the 14-day cooldown**,
which is the one thing they paid to skip.

**Why the override goes in `bootstrap.dart`.** `features/mock_exam` cannot import
`features/paywall` without an R2 violation. `lib/app/` may import anything and already does
exactly this for `notificationServiceProvider` and
`notificationPermissionStatusProvider`.

- [ ] **Step 1: Write the failing test**

Create `test/app/mock_entitlement_override_test.dart`:

```dart
import 'package:cse_cet_reviewer/app/bootstrap.dart';
import 'package:cse_cet_reviewer/features/mock_exam/application/mock_availability_provider.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a Pro entitlement reaches the mock cooldown', () {
    final container = ProviderContainer(
      overrides: [
        ...mockEntitlementOverrides,
        entitlementProvider.overrideWith(
          (ref) => Stream.value(const Entitlement.pro()),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(mockEntitlementProvider).proIsActive, isTrue);
  });

  test('no entitlement reads as Free', () {
    final container = ProviderContainer(
      overrides: [
        ...mockEntitlementOverrides,
        entitlementProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(mockEntitlementProvider).proIsActive, isFalse);
  });
}
```

Check `Entitlement`'s real constructors with
`grep -n "class Entitlement" -A 20 lib/features/paywall/`. If there is no
`Entitlement.pro()` named constructor, build a Pro entitlement whatever way that file
supports, and check the field is `proIsActive`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/mock_entitlement_override_test.dart`
Expected: FAIL. `mockEntitlementOverrides` is not defined.

- [ ] **Step 3: Add the override**

In `lib/app/bootstrap.dart`, above `bootstrap`, add:

```dart
/// Feeds the real subscription into the mock cooldown.
///
/// `mockEntitlementProvider` ships hardcoded to false because
/// `features/mock_exam` cannot import `features/paywall` without breaking the
/// layering rule. `lib/app/` can import both, so the wiring lives here, the
/// same way the notification providers are wired.
///
/// Exposed as a list so tests can apply it without running `bootstrap`.
final mockEntitlementOverrides = <Override>[
  mockEntitlementProvider.overrideWith(
    (ref) => MockEntitlementSnapshot(
      proIsActive:
          ref.watch(entitlementProvider).valueOrNull?.proIsActive ?? false,
    ),
  ),
];
```

and spread it into the container's overrides:

```dart
  final container = ProviderContainer(
    overrides: [
      ...overrides,
      ...mockEntitlementOverrides,
      notificationServiceProvider.overrideWith(
```

Add the imports for `mock_availability_provider.dart` and `mock_availability.dart`.
`paywall.dart` is already imported.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/app/mock_entitlement_override_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib/app/bootstrap.dart test/app
git commit -m "fix(mock): Pro subscribers stop serving the free cooldown

mockEntitlementProvider was hardcoded to false, so the check that lets
Pro skip the fourteen day wait never fired. The wiring belongs in
lib/app, which is the only layer allowed to see both features."
```

---

## Task 5: Mount the panel on the tab

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/quiz/presentation/quiz_tab_home_test.dart`

**Interfaces:**
- Consumes: `MockPanel` from Task 3, `lastSubmittedMockProvider`,
  `mockAvailabilityProvider`, `entitlementProvider`.
- Produces: `QuizTabHome({Widget? mockPanel})`.

**Why the router builds it.** `features/quiz` importing `features/mock_exam` is an R2
violation and the baseline is 7. `lib/app/router.dart` may import both, and it already
reads `entitlementProvider` and injects `proIsActive` into `ProgressPage` on exactly this
pattern. The tab takes a `Widget` and knows nothing about mocks.

- [ ] **Step 1: Write the failing test**

Append to `test/features/quiz/presentation/quiz_tab_home_test.dart`:

```dart
  testWidgets('the tab renders whatever mock panel it is handed',
      (tester) async {
    // Pump QuizTabHome with mockPanel: const Text('MOCK PANEL HERE') and the
    // same provider overrides the other tests in this file use.

    expect(find.text('MOCK PANEL HERE'), findsOneWidget);
  });

  testWidgets('the tab renders without a mock panel', (tester) async {
    // Pump QuizTabHome with no mockPanel argument.

    expect(find.text('More ways to practice'), findsOneWidget);
  });
```

Follow the override idiom already in that file, which 2a and 2b established. It needs a
`sessionPanelProvider` override so the tab does not reach the database.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/quiz_tab_home_test.dart`
Expected: FAIL. `QuizTabHome` has no named parameter `mockPanel`.

- [ ] **Step 3: Accept the panel**

In `lib/features/quiz/presentation/quiz_tab_home.dart`:

```dart
class QuizTabHome extends ConsumerWidget {
  const QuizTabHome({this.mockPanel, super.key});

  /// Built by the router, which is the only layer allowed to see both this
  /// feature and `features/mock_exam`. Null in tests and while the exam is
  /// still loading.
  final Widget? mockPanel;
```

Thread it into `_QuizTabBody`:

```dart
          return _QuizTabBody(exam: focus.exam!, mockPanel: mockPanel);
```

```dart
class _QuizTabBody extends ConsumerWidget {
  const _QuizTabBody({required this.exam, this.mockPanel});

  final Exam exam;
  final Widget? mockPanel;
```

and place it in the `ListView`, directly beneath the session panel:

```dart
        SessionPanel(exam: exam, onStart: () => _onStartQuiz(context, ref)),
        if (mockPanel != null) mockPanel!,
        const SectionHeader(title: 'More ways to practice'),
```

- [ ] **Step 4: Build it in the router**

In `lib/app/router.dart`, replace the `/quiz` route:

```dart
              GoRoute(
                path: '/quiz',
                builder: (_, __) {
                  final entitlement =
                      ref.watch(entitlementProvider).valueOrNull ??
                          const Entitlement.free();
                  final examId =
                      ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id;
                  if (examId == null) return const QuizTabHome();

                  final request = MockAvailabilityRequest(
                    userId: 'local',
                    examId: examId,
                  );
                  final availability =
                      ref.watch(mockAvailabilityProvider(request)).valueOrNull;
                  if (availability == null) return const QuizTabHome();

                  return QuizTabHome(
                    mockPanel: MockPanel(
                      availability: availability,
                      lastAttempt:
                          ref.watch(lastSubmittedMockProvider(request)).valueOrNull,
                      proIsActive: entitlement.proIsActive,
                      onTake: () => context.push('/quiz/mock/setup'),
                      onResume: () => context.push('/mock-exam'),
                      onViewResults: () => context.push('/mock-exam'),
                    ),
                  );
                },
              ),
```

**The three callbacks need checking against the real routes.** Run
`grep -n "mock" lib/app/router.dart` and use the paths that exist: `/quiz/mock/setup` and
`/mock-exam` are both in the table today. If the results screen has its own route taking an
attempt id, push that instead for `onViewResults` and say which you used.

`MockAvailabilityRequest` needs a `const` constructor and value equality for the family key
to be stable across rebuilds. It has neither today: it is a plain class with two final
fields. **Add `operator ==` and `hashCode` to it**, following
`MetricsSignalRequest` in `lib/features/metrics/providers/metrics_signal_providers.dart`,
which solves the identical problem. Without it the provider refetches on every rebuild.

`builder` gives you a `BuildContext`; the placeholder `(_, __)` has to become
`(context, __)`.

- [ ] **Step 5: Run the tests**

Run: `flutter test`
Expected: PASS. Router tests that pump `/quiz` may need the mock providers overridden.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart   # still 7, not 8
git add lib test
git commit -m "feat(quiz): the mock panel goes on the tab

The router builds it and hands it over, so the Quiz tab never imports the
mock feature. Same shape as the entitlement it already injects into
ProgressPage."
```

---

## Task 6: The practice rows get their counts

**Files:**
- Create: `lib/features/quiz/presentation/practice_row_providers.dart`
- Create: `test/features/quiz/presentation/practice_row_providers_test.dart`
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Test: `test/features/quiz/presentation/quiz_tab_home_test.dart`

**Interfaces:**
- Consumes: `AttemptsRepository.recentIncorrects`, which exists;
  `QuestionFlagsRepository.flagCount`, which exists.
- Produces: `recentMistakeCountProvider`, a `FutureProvider.family<int, ExamId>`, and
  `flagCountProvider`, a `FutureProvider<int>`. Task 7 uses the second.

**From the spec, Section 1:**

| Row | Subtitle | Empty state |
|---|---|---|
| Your mistakes | "28 you've got wrong in the last month" | "Nothing to fix yet", dimmed to 50%, no chevron |
| Choose what to practice | "One topic or one lesson, your choice of length" | never empty |

**Plan 2a deliberately left the mistakes row a placeholder subtitle** with the note "Do not
invent a number". This is where the number arrives. `recentIncorrects` already returns
distinct question ids that were answered wrongly inside a window, newest first, which is
exactly the pool "Your mistakes" retakes.

**The window is one month, matching the copy.** `const Duration(days: 30)`.

**`recentIncorrects` caps at `limit: 50` by default.** A student with 80 mistakes would be
told 50, which is a wrong figure rather than a rounded one. Pass a limit high enough that
the cap cannot bind before the pool does, and say so in the provider.

- [ ] **Step 1: Write the failing test**

Create `test/features/quiz/presentation/practice_row_providers_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/practice_row_providers.dart';
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

  AttemptItem item(String questionId, {required bool correct}) => AttemptItem(
        questionId: questionId,
        questionVersion: 1,
        chosenChoiceId: correct ? 'c_a' : 'c_b',
        correctChoiceId: 'c_a',
        responseMs: 1200,
      );

  test('no attempts means nothing to fix', () async {
    expect(
      await container.read(recentMistakeCountProvider('exam_cse_pro').future),
      0,
    );
  });

  test('wrong answers inside the month are counted once each', () async {
    await AttemptsRepository(db).save(
      Attempt(
        id: 'a_1',
        examId: 'exam_cse_pro',
        startedAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now(),
        items: [
          item('q_1', correct: false),
          item('q_1', correct: false),
          item('q_2', correct: false),
          item('q_3', correct: true),
        ],
      ),
    );

    expect(
      await container.read(recentMistakeCountProvider('exam_cse_pro').future),
      2,
    );
  });

  test('the flag count starts at zero', () async {
    expect(await container.read(flagCountProvider.future), 0);
  });

  test('flags are counted', () async {
    await QuestionFlagsRepository(db).flag('q_1');
    await QuestionFlagsRepository(db).flag('q_2');

    expect(await container.read(flagCountProvider.future), 2);
  });
}
```

Add the `QuestionFlagsRepository` import.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/practice_row_providers_test.dart`
Expected: FAIL. `practice_row_providers.dart` does not exist.

- [ ] **Step 3: Write the providers**

Create `lib/features/quiz/presentation/practice_row_providers.dart`:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One month, matching the row's own copy: "28 you've got wrong in the last
/// month".
const mistakeWindow = Duration(days: 30);

/// How many distinct questions the student has got wrong in the last month.
///
/// This is the pool "Your mistakes" retakes, so the subtitle and the session
/// come from the same query.
final recentMistakeCountProvider =
    FutureProvider.family<int, ExamId>((ref, examId) async {
  final ids = await ref.watch(attemptsRepositoryProvider).recentIncorrects(
        examId: examId,
        now: ref.watch(nowProvider)(),
        window: mistakeWindow,
        // The default cap is 50. A student with 80 mistakes would be shown 50,
        // which is not a rounded figure, it is a wrong one. Raised past any
        // plausible month so the pool binds before the cap does.
        limit: 100000,
      );
  return ids.length;
});

final flagCountProvider = FutureProvider<int>(
  (ref) => ref.watch(questionFlagsRepositoryProvider).flagCount(),
);
```

Check `questionFlagsRepositoryProvider` exists and is exported from
`core/storage/storage.dart`. If it does not exist, add it beside the other repository
providers in whichever file declares them, matching their style.

- [ ] **Step 4: Put the counts on the rows**

In `quiz_tab_home.dart`'s `_QuizTabBody`, read the count and give the row its two states:

```dart
    final mistakes = ref.watch(recentMistakeCountProvider(exam.id)).valueOrNull;
```

and replace the mistakes row:

```dart
        InkTableRow(
          title: 'Your mistakes',
          subtitle: mistakes == null
              ? ''
              : mistakes == 0
                  ? 'Nothing to fix yet'
                  : "$mistakes you've got wrong in the last month",
          // Dimmed with no chevron when empty: a door with nothing behind it
          // should not invite a tap.
          onTap: mistakes == null || mistakes == 0
              ? null
              : () => context.push('/quiz/retake/${exam.id}'),
        ),
```

**Check how `InkTableRow` renders a null `onTap`** before relying on it:
`grep -n "onTap" -B 3 -A 12 lib/core/ui/components/ink_table_row.dart`. The spec asks for
the empty row to be dimmed to 50% with no chevron. If `InkTableRow` already drops the
chevron when `onTap` is null but does not dim, add a `dimmed` bool to it rather than
wrapping the row in an `Opacity` at the call site, so the mock panel and the flagged section
get the same treatment for free.

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(quiz): the mistakes row says how many

Plan 2a left the subtitle a placeholder rather than invent a number. It
comes from recentIncorrects, which is the same query the retake session
draws from, so the row cannot promise more than it opens."
```

---

## Task 7: The flagged section

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Test: `test/features/quiz/presentation/quiz_tab_home_test.dart`

**Interfaces:**
- Consumes: `flagCountProvider` from Task 6, `SectionHeader`, `InkTableRow`.
- Produces: nothing. Seam 6 gives the row its destination.

**From the spec, Section 1:** a `SectionHeader` "Flagged" with the count in `bodySmall`
`inkMuted`, a 1px `rule`, then one row: **"Questions you flagged"**, subtitle "12 kept,
across 4 topics". Dimmed with "Flag anything you want to come back to" and no chevron when
empty.

**The subtitle's third sentence is dropped.** Section 1 writes it as "12 kept, across 4
topics. **7 of them from your last exam**". Section 6, written later the same day, settles
that "the tab's Flagged section holds durable practice flags only, whatever their origin,
and it never needs to distinguish where one came from", and `question_flags_local` has no
origin column to distinguish by. Recorded in the decision log on 2 August.

**The row is not tappable in this plan.** It opens a list, and that list is the mock spec's
review component in its practice form, which is seam 6. Same rule 2a applied to "Choose what
to practice": a dead chevron is worse than none.

**"Across 4 topics" needs the flagged questions' topics**, which means resolving each
flagged id through `ContentRepository.questionById`. With flags unlimited on both tiers that
is one query per flag. Do it in the provider, not the widget, and if the flag list is large
enough that this becomes slow, say so rather than trimming the sentence silently.

- [ ] **Step 1: Extend the flag provider**

The section needs two figures, so `flagCountProvider` is not enough. In
`practice_row_providers.dart`, add:

```dart
/// What the flagged row says: how many are kept and how many topics they
/// span.
class FlagSummary {
  const FlagSummary({required this.count, required this.topicCount});

  static const empty = FlagSummary(count: 0, topicCount: 0);

  final int count;
  final int topicCount;
}

final flagSummaryProvider = FutureProvider<FlagSummary>((ref) async {
  final ids = await ref.watch(questionFlagsRepositoryProvider).flaggedIds();
  if (ids.isEmpty) return FlagSummary.empty;

  final content = ref.watch(contentRepositoryProvider);
  final topicIds = <TopicId>{};
  for (final id in ids) {
    final question = await content.questionById(id);
    if (question != null) topicIds.add(question.topicId);
  }
  return FlagSummary(count: ids.length, topicCount: topicIds.length);
});
```

- [ ] **Step 2: Write the failing tests**

Append to `test/features/quiz/presentation/practice_row_providers_test.dart`:

```dart
  test('no flags summarise as empty', () async {
    final summary = await container.read(flagSummaryProvider.future);

    expect(summary.count, 0);
    expect(summary.topicCount, 0);
  });

  test('flags are counted and their topics tallied', () async {
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_algebra',
      topicName: 'Algebra',
      questionIds: ['q_1', 'q_2'],
    );
    await seedTopicWithQuestions(
      db,
      examId: 'exam_cse_pro',
      topicId: 'topic_geometry',
      topicName: 'Geometry',
      questionIds: ['q_3'],
    );
    final flags = QuestionFlagsRepository(db);
    await flags.flag('q_1');
    await flags.flag('q_2');
    await flags.flag('q_3');

    final summary = await container.read(flagSummaryProvider.future);

    expect(summary.count, 3);
    expect(summary.topicCount, 2);
  });
```

`seedTopicWithQuestions` is the helper Plan 2b added to `test/helpers/in_memory_database.dart`.

And append to `test/features/quiz/presentation/quiz_tab_home_test.dart`:

```dart
  testWidgets('the flagged section counts what is kept', (tester) async {
    // Override flagSummaryProvider with FlagSummary(count: 12, topicCount: 4).

    expect(find.text('Flagged'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Questions you flagged'), findsOneWidget);
    expect(find.text('12 kept, across 4 topics'), findsOneWidget);
  });

  testWidgets('an empty flagged section invites the first flag',
      (tester) async {
    // Override flagSummaryProvider with FlagSummary.empty.

    expect(
      find.text('Flag anything you want to come back to'),
      findsOneWidget,
    );
  });

  testWidgets('the flagged row does not open anything yet', (tester) async {
    // Override flagSummaryProvider with FlagSummary(count: 12, topicCount: 4).

    final row = tester.widget<InkTableRow>(
      find.widgetWithText(InkTableRow, 'Questions you flagged'),
    );
    expect(row.onTap, isNull);
  });
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `flutter test test/features/quiz/presentation/`
Expected: FAIL. `flagSummaryProvider` and the section do not exist.

- [ ] **Step 4: Draw the section**

At the end of `_QuizTabBody`'s `ListView`, after the practice rows:

```dart
        const SizedBox(height: 8),
        SectionHeader(
          title: 'Flagged',
          trailing: flags == null || flags.count == 0
              ? null
              : Text(
                  '${flags.count}',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
        ),
        InkTableRow(
          title: 'Questions you flagged',
          subtitle: flags == null
              ? ''
              : flags.count == 0
                  ? 'Flag anything you want to come back to'
                  : '${flags.count} kept, across ${flags.topicCount} '
                      '${flags.topicCount == 1 ? 'topic' : 'topics'}',
          bottomRule: false,
          // The row opens a list, and that list is seam 6's review component.
          // Untappable until it exists, on 2a's rule that a dead chevron is
          // worse than none.
          onTap: null,
        ),
```

with `final flags = ref.watch(flagSummaryProvider).valueOrNull;` beside the mistake count,
and `colors` read from `context.colors`.

**Check `SectionHeader`'s real API** with
`grep -n "SectionHeader({" -A 10 lib/core/ui/components/section_header.dart`. If it has no
`trailing` slot, add one rather than drawing a `Row` at the call site: the spec puts a
count beside "Flagged" and the Study spec's headers want the same thing.

- [ ] **Step 5: Run the whole suite**

Run: `flutter test`
Expected: PASS. This is the last task, so the suite is the gate.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(quiz): the flagged section

Its subtitle drops the spec's third sentence. Section 6 settled that the
tab holds durable flags only and never distinguishes where one came from,
and the table has no origin column to distinguish by."
```

---

## What this plan deliberately does not do

- **The flagged list.** Seam 6's review component in its practice form: the flags grouped by
  subject, each expanding in place, every pennant tappable, and a board "Practice these 12"
  at the bottom. The row here is deliberately inert until then.
- **The pennant mark, its motion and the flag control.** Section 6's mark lives in the quiz
  viewer's app bar, which is seam 4.
- **The practice picker.** Seam 3. Its row stays inert.
- **The mock setup, session and results screens.** They belong to
  `2026-07-28-mock-exam-ui-design.md` and its own plans.
- **Per-exam score bands.** `ComputeResults.bandFor` still falls back to 75/60, which the
  17 May mock spec says is a placeholder until Sanity carries real thresholds. **This plan
  prints no band**, so it does not depend on that, but the mock results screen does. Worth
  raising before the mock UI plans.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # still 7, not 8
flutter test                                     # all pass
```

By hand, on a device, since Aedwon does the visual verification:

- The Quiz tab reads: exam short name, session panel, mock panel, "More ways to practice"
  with two rows, then "Flagged" with one.
- A fresh install's mock panel says what the exam is, states the Free rule with no date, and
  offers "Take the exam".
- After a mock, the panel shows two figures, the cooldown in the header as `13d 22h` and no
  Take button, and the Free line names the day it reopens.
- On a Pro account the line reads "Pro users can take as many as they want" and the Take
  button stays available.
- With no mistakes, "Your mistakes" reads "Nothing to fix yet", is dimmed and does not open.
- With no flags, the flagged row reads "Flag anything you want to come back to".

## Self-review notes

Checked against Section 1's mock panel table, practice rows and flagged section, and
Section 7:

- Four mock states, the heading, the cooldown count, the tier line in every state: Task 3.
- Vocabulary: exam, take, never paper, never sit. The heading carries "Mock exam" so no
  button repeats it: Task 3.
- Two rows not four, with "Where you stand" and "Study" already gone in 2a: Task 6.
- The flagged header, count, row and empty state: Task 7.
- One deviation from the spec, the cut middle figure, decided by Aedwon on 2 August and
  logged.
- One contradiction inside the spec, the flagged subtitle's third sentence, resolved by
  Section 6 and logged.
- Two things flagged and not fixed: `_reopensOn` calling `DateTime.now()` inside a widget,
  and the placeholder score bands.
