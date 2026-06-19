# Progress, Plan 2 of 6: Your Pace

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Open the Progress tab with two measured figures and one sentence of arithmetic
about the student's current rate, which never becomes a projection of what they will
score.

**Architecture:** One provider computing lessons read, days left and the current weekly
rate, and one panel widget. No storage, no new signals.

**Tech Stack:** Flutter, Riverpod, Drift, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-30-progress-tab-design.md` Section 3,
"Your pace", plus Section 1's evidentiary rule.

---

## The hard rule this whole section turns on

> **This stays arithmetic. It may never become a score projection.** It states a
> conditional about the current rate and nothing else.

The first design of this tab shipped points recoverable per topic and it was withdrawn:
it equated this app's questions to real exam items, assumed study takes an error rate to
zero, swung between sessions on small samples, and decisively **it was a score
projection**, which this project has banned since the redesign spec reserved the word
"readiness". A smaller local projection is still a projection.

"At three lessons a week you finish nine days after the exam" is **not** a projection. It
is division: a measured rate, a measured remainder, and a published date the student
supplied. Every term is a fact and the reader combines them. **The moment a sentence here
mentions a score, it has broken the rule.**

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-progress-01-frame-and-grammar.md` | The `_yourPaceSection` stub, `RuledPanel` | **Blocking** |
| `2026-08-02-onboarding-flow-and-new-steps.md` Task 1 | `ExamDate`, `ExamDatePrecision`, `daysUntil` | **Blocking.** Days left is half the panel |
| `2026-08-02-home-03-masthead-and-band.md` Task 3 | `lessonsReadProvider` | **Not blocking.** If it exists, consume it. If not, write it here and Home consumes it |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **This section is wholly Free.** Spec 11 already placed the on-pace indicator in the
  Free tier and Section 7 keeps it there. **No teaser, no redaction, no `FaintBars` for a
  gate.**
- **Never invent a figure.** Both figures are T1, measured from this student's own use.
  The sentence is arithmetic over T1 and a date the student asserted.
- **Amber on the overshoot only.** Not on the figures, not on the panel, not on the rate.
  Board green appears nowhere in this section.
- **Voice.** Grade-5-simple English, **no em dashes**. Never the word "readiness". Never a
  score, a band, a percentage of the exam, or a probability.
- **Analyzer must be clean.**

## Verification commands

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

---

## File structure

| File | Responsibility |
|---|---|
| `lib/features/progress/application/pace_provider.dart` (create) | Lessons read, days left, the weekly rate, and the finish arithmetic |
| `lib/features/progress/presentation/widgets/your_pace_panel.dart` (create) | The panel |
| `lib/features/progress/presentation/progress_page.dart` (modify) | `_yourPaceSection` returns the real widget |

---

### Task 1: The arithmetic

**Files:**
- Create: `lib/features/progress/application/pace_provider.dart`
- Test: `test/features/progress/application/pace_provider_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (`lessons`, `lesson_progress_local`); `activeExamFocusProvider`;
  `UserSettings.examDate`.
- Produces:

```dart
@immutable
class PaceReading {
  const PaceReading({
    required this.lessonsRead,
    required this.lessonsTotal,
    required this.daysLeft,
    required this.lessonsPerWeek,
    required this.daysPastExam,
    required this.rateToFinishInTime,
  });

  /// T1. Rows in lesson_progress_local against lessons, for this exam.
  final int lessonsRead;
  final int lessonsTotal;

  /// Null when the student gave no date, or gave only a month. A day count
  /// derived from a month is a figure made of a measurement and an
  /// assumption.
  final int? daysLeft;

  /// T1. The student's own rate over the last 28 days, rounded to a whole
  /// number for the sentence. Null below the sample floor.
  final int? lessonsPerWeek;

  /// How many days past the exam the current rate finishes. Null when it
  /// finishes in time, when there is no date, or when there is no rate.
  /// Positive only.
  final int? daysPastExam;

  /// The whole number of lessons a week that closes the gap. Null whenever
  /// [daysPastExam] is null.
  final int? rateToFinishInTime;
}

final paceProvider = FutureProvider<PaceReading?>(...);
```

**The rate is measured over the last 28 days**, not over the whole prep window. A student
who read fifteen lessons in January and none since has a current rate of zero, and saying
so is the point of the panel. Four weeks is the shortest window that survives one quiet
week without swinging.

**The rate has a sample floor.** With fewer than **7 days** since the first lesson was
read, `lessonsPerWeek` is null and the sentence does not render. Two lessons on day one is
not a rate of fourteen a week, and printing that would be exactly the measurement-plus-
assumption the evidentiary rule bans.

**`daysLeft` is null at month precision, not estimated.** `ExamDate.day` returns null
there by design. Do not reach around it.

**The arithmetic, and it is the whole computation:**

```
remaining      = lessonsTotal - lessonsRead
weeksNeeded    = remaining / lessonsPerWeek
daysNeeded     = weeksNeeded * 7
daysPastExam   = daysNeeded - daysLeft, when positive
rateToFinish   = ceil(remaining / (daysLeft / 7)), when daysPastExam is not null
```

**A rate of zero finishes never.** Do not divide by it. Return `daysPastExam: null` and let
the widget render the zero-rate copy in Task 2.

- [ ] **Step 1: Write the failing test**

Use a real in-memory `AppDatabase`.

```dart
  test('counts lessons read against the exam total', () async {
    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsRead, 41);
    expect(pace.lessonsTotal, 96);
  });

  test('a month-precision date yields no day count', () async {
    // examDate: ExamDate.inMonth(year: 2026, month: 10)
    final pace = await container.read(paceProvider.future);
    expect(pace!.daysLeft, isNull);
    expect(pace.daysPastExam, isNull);
  });

  test('no date at all yields no day count', () async {
    final pace = await container.read(paceProvider.future);
    expect(pace!.daysLeft, isNull);
  });

  test('below the sample floor there is no rate', () async {
    // First lesson read 2 days ago.
    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsPerWeek, isNull);
    expect(pace.daysPastExam, isNull);
  });

  test('the rate is measured over 28 days, not over all time', () async {
    // 15 lessons read 90 days ago, 3 read in the last 28.
    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsPerWeek, 1);
  });

  test('a rate that finishes in time reports no overshoot', () async {
    // 55 remaining, 8 a week, 60 days left.
    final pace = await container.read(paceProvider.future);
    expect(pace!.daysPastExam, isNull);
    expect(pace.rateToFinishInTime, isNull);
  });

  test('a rate that finishes late reports the overshoot and the fix',
      () async {
    // 55 remaining, 3 a week, 120 days left.
    // 55/3 = 18.33 weeks = 128.3 days, so 9 days past.
    final pace = await container.read(paceProvider.future);
    expect(pace!.daysPastExam, 9);
    expect(pace.rateToFinishInTime, 4);
  });

  test('a rate of zero never divides by zero', () async {
    // Nothing read in 28 days.
    final pace = await container.read(paceProvider.future);
    expect(pace!.lessonsPerWeek, 0);
    expect(pace.daysPastExam, isNull);
    expect(pace.rateToFinishInTime, isNull);
  });

  test('nothing on this reading is a score', () async {
    final pace = await container.read(paceProvider.future);
    // A guard against the field this section is forbidden to grow.
    expect(
      PaceReading.toString,
      isNot(contains('score')),
      reason: 'Your pace stays arithmetic and never projects a score',
    );
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/progress/application/pace_provider_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the provider**

- [ ] **Step 4: Run the tests and make sure they pass**

Expected: PASS, 9 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/progress/application/pace_provider.dart test/features/progress/application/pace_provider_test.dart
git commit -m "feat(progress): compute the study pace, as arithmetic and nothing more

The rate is the student's own over 28 days, with a 7 day floor: two
lessons on day one is not a rate of fourteen a week, and printing that
would be a measurement multiplied by an assumption.

A month-precision exam date yields no day count, and a rate of zero
yields no finish date rather than a division by zero."
```

---

### Task 2: The panel

**Files:**
- Create: `lib/features/progress/presentation/widgets/your_pace_panel.dart`
- Modify: `lib/features/progress/presentation/progress_page.dart`
- Test: `test/features/progress/presentation/widgets/your_pace_panel_test.dart`

**Interfaces:**
- Consumes: `paceProvider`, `PaceReading`, `RuledPanel`, `StatsBand`, `FaintBars`.
- Produces: `class YourPacePanel extends ConsumerWidget`.

**The composition:** a ruled panel, plated heading **"Your pace"**, two figures, then one
sentence.

```
Your pace

     43%                    120
lessons read              days left

At three lessons a week you finish nine days after the exam.
Four a week closes the gap.
```

**Amber on the overshoot only**, which is the words carrying the day count of the
overshoot. Not the figures, not the rate, not the fix.

**The five sentence states, and there is no sixth:**

| Condition | The sentence |
|---|---|
| Finishes late | `At {rate} lessons a week you finish {n} days after the exam. {fix} a week closes the gap.` The `{n} days after the exam` clause in `amber` |
| Finishes in time | `At {rate} lessons a week you finish before the exam.` |
| Rate is zero | `You have not read a lesson in four weeks. There are {remaining} left.` |
| No rate yet, below the floor | No sentence at all. The two figures stand alone |
| No day count, at month or no precision | `At {rate} lessons a week you have about {weeks} weeks of reading left.` No comparison to the exam, because there is no date to compare to |

**Numbers in the sentence are written as words up to ten** and as figures above, which is
how the spec's own example reads ("three lessons a week", "nine days after"). Write the
helper and test it; do not hand-roll it at each site.

**Singular and plural.** `1 day`, `one lesson a week`, `1 week`. Test each.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('prints two figures and the overshoot sentence', (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 3, past: 9, fix: 4),
    );
    await tester.pumpAndSettle();

    expect(find.text('43%'), findsOneWidget);
    expect(find.text('lessons read'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('days left'), findsOneWidget);
    expect(
      find.textContaining(
        'At three lessons a week you finish nine days after the exam.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Four a week closes the gap.'), findsOneWidget);
  });

  testWidgets('only the overshoot carries amber', (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 3, past: 9, fix: 4),
    );
    await tester.pumpAndSettle();

    final amberSpans = allTextSpans(tester)
        .where((s) => s.style?.color == AppColors.light.amber);
    expect(amberSpans, hasLength(1));
    expect(amberSpans.single.text, contains('nine days after the exam'));
  });

  testWidgets('finishing in time says so and carries no amber',
      (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 200, rate: 8, past: null),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('At eight lessons a week you finish before the exam.'),
      findsOneWidget,
    );
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.amber));
    }
  });

  testWidgets('a zero rate states the fact and the remainder', (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 0, past: null),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('You have not read a lesson in four weeks. There are 55 left.'),
      findsOneWidget,
    );
  });

  testWidgets('below the floor the figures stand alone', (tester) async {
    await tester.pumpWidget(
      harness(read: 2, total: 96, daysLeft: 120, rate: null),
    );
    await tester.pumpAndSettle();

    expect(find.text('days left'), findsOneWidget);
    expect(find.textContaining('a week'), findsNothing);
  });

  testWidgets('with no day count the sentence never mentions the exam',
      (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: null, rate: 3),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('weeks of reading left'), findsOneWidget);
    expect(find.textContaining('the exam'), findsNothing);
    expect(find.text('days left'), findsNothing);
  });

  testWidgets('one day and one lesson read as singular', (tester) async {
    await tester.pumpWidget(
      harness(read: 95, total: 96, daysLeft: 1, rate: 1, past: 1, fix: 2),
    );
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('day left'), findsOneWidget);
    expect(find.textContaining('one day after the exam'), findsOneWidget);
  });

  testWidgets('never a score, a band, a chance or the word readiness',
      (tester) async {
    await tester.pumpWidget(
      harness(read: 41, total: 96, daysLeft: 120, rate: 3, past: 9, fix: 4),
    );
    await tester.pumpAndSettle();

    for (final word in [
      'score', 'Score', 'pass', 'Pass', 'chance', 'likely', 'readiness',
      'Readiness', '—',
    ]) {
      expect(find.textContaining(word), findsNothing);
    }
  });

  testWidgets('no teaser and no redaction, on either tier', (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(read: 41, total: 96, isPro: isPro));
      await tester.pumpAndSettle();
      expect(find.text('Unlock with Pro'), findsNothing);
      expect(find.byType(FaintBars), findsNothing);
    }
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/progress/presentation/widgets/your_pace_panel_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the panel**

- [ ] **Step 4: Wire it in**

```dart
  Widget _yourPaceSection(BuildContext context, WidgetRef ref) =>
      const YourPacePanel();
```

- [ ] **Step 5: Run everything**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: PASS, `No issues found!`, no format diff.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(progress): open the tab on Your pace

Two measured figures and one sentence of arithmetic. Amber on the
overshoot only.

Five sentence states and no sixth, including the two the evidentiary
rule forces: no rate below the sample floor, and no comparison to the
exam when the student gave only a month. This section may never mention
a score."
```

---

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- `grep -rni "score\|readiness\|chance" lib/features/progress/application/pace_provider.dart lib/features/progress/presentation/widgets/your_pace_panel.dart` returns nothing.
- A student with a month-precision exam date sees no day count and no comparison to the
  exam.
- A student who read two lessons yesterday sees two figures and no sentence.
- The panel is identical on Free and Pro.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
