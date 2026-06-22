# Progress, Plan 6 of 6: Your Record

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

**Goal:** Build the sub-screen that answers "am I actually moving": the student's own
history, totals, accuracy line and mock list, wholly free, because nothing they produced
themselves is ever paywalled.

**Architecture:** One provider gathering the student's history from tables that already
hold it, one accuracy line drawn on hairline gridlines, and a pushed screen. No new
signals, no storage.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-30-progress-tab-design.md` Section 5, plus
Section 7's row for this screen and the "Deferred" section.

---

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-progress-01-frame-and-grammar.md` | `NavigationalRow`, `DataRowTile`, the `_goDeeperSection` stub | **Blocking** |
| `2026-08-02-progress-05-how-you-work.md` | Nothing in code, but it adds the **first** Go deeper row | **Not blocking.** Whichever runs second adds its row beneath the other's |
| A mock actually running | "Your mocks" and "Best mock" | **Not blocking.** Both are absent rather than empty |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **This screen is wholly Free.** It is the student's own history and **nothing they
  produced is ever paywalled**. **No teaser, no redaction, no `FaintBars` for a gate**, on
  any tier.
- **"Time in sessions", never "time studied".** Reading time is not tracked, and the label
  carries the limit. This is the evidentiary rule as a copy rule.
- **Milestones are deliberately absent.** Their provenance is real (four Wrapped
  artifacts, `user_metrics_artifacts_local`, the shipped `wrapped_history_stub` panel) but
  the form was never designed and it gets its own pass. **Do not add them here** because
  the data exists.
- **Never invent a figure.** Every number here is counted from the student's own rows.
- **Voice.** Grade-5-simple English, **no em dashes**. Scores are **points**, never
  "marks". The words FSRS, stability, retention, retrievability, algorithm and card never
  appear.
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
| `lib/features/progress/application/record_provider.dart` (create) | Weeks in, streaks, the six totals, the accuracy series, the mock list |
| `lib/features/progress/presentation/widgets/accuracy_line.dart` (create) | One board line on hairline gridlines |
| `lib/features/progress/presentation/pages/your_record_page.dart` (create) | The screen |
| `lib/features/progress/presentation/progress_page.dart` (modify) | The second Go deeper row |
| `lib/app/router.dart` (modify) | `/progress/your-record` |

---

### Task 1: The record

**Files:**
- Create: `lib/features/progress/application/record_provider.dart`
- Test: `test/features/progress/application/record_provider_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (`attempts_local`, `lesson_progress_local`, `streak_local`,
  `mock_attempts`); `AttemptItemReader`; `activeExamFocusProvider`.
- Produces:

```dart
@immutable
class StudentRecord {
  const StudentRecord({
    required this.weeksIn,
    required this.dayStreak,
    required this.streakStartedOn,
    required this.questionsAnswered,
    required this.sessionMinutes,
    required this.lessonsRead,
    required this.daysActive,
    required this.longestStreak,
    required this.bestMockPercent,
    required this.accuracySeries,
    required this.mocks,
  });

  final int weeksIn;
  final int dayStreak;
  final DateTime? streakStartedOn;

  final int questionsAnswered;

  /// Time in sessions, never "time studied". Reading time is not tracked.
  final int sessionMinutes;

  final int lessonsRead;
  final int daysActive;
  final int longestStreak;

  /// Null until a mock has been submitted. Absent, not zero.
  final int? bestMockPercent;

  /// One point per week of prep. Empty below two points, because a line
  /// through one point is not a trend and drawing it would be a shape the
  /// data does not have.
  final List<({DateTime weekStart, double accuracy})> accuracySeries;

  /// Newest first. Empty until a mock has been submitted.
  final List<({DateTime takenOn, int percent, String blueprintName})> mocks;
}

final recordProvider = FutureProvider<StudentRecord>(...);
```

**`streak_local` already holds `current`, `longest` and `lastActiveDate`**
(`lib/core/storage/data/tables/streak_local_table.dart`). It does **not** hold the date the
current streak began. Derive it as `lastActiveDate - (current - 1) days`, and **only when
`current > 0`**. If that derivation is wrong for the streak-freeze case
(`freezesRemaining`), return null rather than a date that is off by the number of freezes
used. **A wrong date is worse than no date**, and this is the student's own history.

**"Weeks in" counts from the first row the student produced**, whichever came first across
attempts and lesson progress, not from account creation. A student who signed up in March
and started in July is three weeks in, not twenty.

**The accuracy series is one point per week**, over completed attempts in that week.
**Empty below two points.** A line through one point is not a trend, and drawing it would
give the data a shape it does not have.

**"Days active" counts distinct local dates** on which the student answered a question or
read a lesson. Compute in local time, not UTC: a student answering at 11pm should get that
day, not the next.

- [ ] **Step 1: Write the failing test**

```dart
  test('weeks in counts from the first thing the student did', () async {
    // Account made 2026-03-01. First attempt 2026-07-12. Today 2026-08-02.
    final record = await container.read(recordProvider.future);
    expect(record.weeksIn, 3);
  });

  test('days active counts distinct local dates, not rows', () async {
    // Four attempts, two of them on the same day.
    final record = await container.read(recordProvider.future);
    expect(record.daysActive, 3);
  });

  test('a late-night answer counts for that day, not the next', () async {
    // One attempt at 23:40 local.
    final record = await container.read(recordProvider.future);
    expect(record.daysActive, 1);
  });

  test('the streak start is derived and null when freezes were used',
      () async {
    final record = await container.read(recordProvider.future);
    expect(record.streakStartedOn, isNull);
  });

  test('with no mock, best mock and the mock list are absent', () async {
    final record = await container.read(recordProvider.future);
    expect(record.bestMockPercent, isNull);
    expect(record.mocks, isEmpty);
  });

  test('the accuracy series is empty below two points', () async {
    // One week of attempts only.
    final record = await container.read(recordProvider.future);
    expect(record.accuracySeries, isEmpty);
  });

  test('two weeks of attempts give two points', () async {
    final record = await container.read(recordProvider.future);
    expect(record.accuracySeries, hasLength(2));
  });

  test('assessment attempts count toward the totals', () async {
    final record = await container.read(recordProvider.future);
    expect(record.questionsAnswered, 21);
  });

  test('mocks are newest first', () async {
    final record = await container.read(recordProvider.future);
    expect(
      record.mocks.first.takenOn.isAfter(record.mocks.last.takenOn),
      isTrue,
    );
  });
```

- [ ] **Step 2 to 4: fail, implement, pass**

- [ ] **Step 5: Commit**

```bash
git commit -m "feat(progress): gather the student's record

Weeks in counts from the first thing they did, not from account
creation. Days active counts distinct local dates so a late-night answer
lands on the right day.

The streak start is derived from lastActiveDate and returns null when
freezes make the derivation wrong: a wrong date is worse than no date in
a student's own history.

The accuracy series is empty below two points, because a line through one
point gives the data a shape it does not have."
```

---

### Task 2: The accuracy line

**Files:**
- Create: `lib/features/progress/presentation/widgets/accuracy_line.dart`
- Test: `test/features/progress/presentation/widgets/accuracy_line_test.dart`

**Interfaces:**
- Consumes: nothing but its own arguments.
- Produces: `class AccuracyLine extends StatelessWidget` taking
  `({required List<({DateTime weekStart, double accuracy})> series})`.

**A single board line on hairline gridlines.** That is the whole specification and it is
deliberately spare: no axis labels, no dots, no fill beneath, no tooltip, no animation.
This is the only chart on the tab and it is a shape, not a dashboard.

**Gridlines are `ruleFaint` at 1px.** The line is `board` at 1.5px. **Board is spent here
on purpose**: it is a progress indicator, which the colour budget names as one of its
three uses.

**With fewer than two points the widget renders nothing at all**, matching the provider.

**No y-axis scaling to the data.** The axis runs 0 to 100, always. A line auto-scaled to a
student's 58-to-63 range would look like a dramatic climb, which is a shape the data does
not have and the tab's whole rewrite was about not doing that.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('renders nothing below two points', (tester) async {
    await tester.pumpWidget(harness(series: onePoint));
    expect(find.byType(CustomPaint), findsNothing);
  });

  testWidgets('draws one line and no decoration', (tester) async {
    await tester.pumpWidget(harness(series: sixPoints));
    expect(find.byType(AccuracyLine), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('the axis is always 0 to 100, never scaled to the data',
      (tester) async {
    await tester.pumpWidget(harness(series: narrowRange58to63));
    final painter = painterOf(tester);
    expect(painter.minY, 0);
    expect(painter.maxY, 100);
  });

  testWidgets('the line is board and the gridlines are ruleFaint',
      (tester) async {
    await tester.pumpWidget(harness(series: sixPoints));
    final painter = painterOf(tester);
    expect(painter.lineColor, AppColors.light.board);
    expect(painter.gridColor, AppColors.light.ruleFaint);
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(progress): draw the accuracy line

The axis is always 0 to 100 and never scaled to the data. A line
auto-scaled to a 58-to-63 range looks like a dramatic climb, which is a
shape the data does not have, and not doing that is what this tab was
rewritten for."
```

---

### Task 3: The screen, and the second Go deeper row

**Files:**
- Create: `lib/features/progress/presentation/pages/your_record_page.dart`
- Modify: `lib/features/progress/presentation/progress_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/progress/presentation/pages/your_record_page_test.dart`

**Interfaces:**
- Consumes: `recordProvider`, `AccuracyLine`, `RuledPanel`, `DataRowTile`,
  `NavigationalRow`.
- Produces: the route `/progress/your-record`.

**Composition, top to bottom:**

1. Panel **"Since you started"**: weeks in, day streak, and the date the streak began.
2. **"Your totals"**: questions answered, time in sessions, lessons read, days active,
   longest streak, best mock. Six data rows.
3. **"Accuracy across your prep"**: the `AccuracyLine`.
4. **"Your mocks"**: one row per submitted mock, newest first, with its date and its
   percentage.

**Absent, not empty.** A student with no mock sees no "Your mocks" panel and no "best
mock" row, rather than a panel saying "none yet" and a row saying "0%". The same rule the
whole tab runs on.

**The Go deeper row** on the tab: title "Your record", subtitle carrying this screen's
verdict, for example "Day 18. Best mock 68%, up 11 since May." **Drop the "Best mock"
clause when there is no mock**, rather than printing a subtitle with a hole in it.

**Push, not go**, since this screen sits outside the tab shell.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('four panels in the spec order', (tester) async {
    await tester.pumpWidget(harness(record: fullRecord));
    await tester.pumpAndSettle();

    final ys = [
      'Since you started', 'Your totals', 'Accuracy across your prep',
      'Your mocks',
    ].map((t) => tester.getTopLeft(find.text(t)).dy).toList();
    expect(ys, orderedEquals(List<double>.from(ys)..sort()));
  });

  testWidgets('the label is time in sessions, never time studied',
      (tester) async {
    await tester.pumpWidget(harness(record: fullRecord));
    await tester.pumpAndSettle();

    expect(find.text('time in sessions'), findsOneWidget);
    expect(find.textContaining('time studied'), findsNothing);
  });

  testWidgets('with no mock, the panel and the row are absent, not empty',
      (tester) async {
    await tester.pumpWidget(harness(record: recordWithNoMock));
    await tester.pumpAndSettle();

    expect(find.text('Your mocks'), findsNothing);
    expect(find.text('best mock'), findsNothing);
    expect(find.text('0%'), findsNothing);
    expect(find.textContaining('none yet'), findsNothing);
  });

  testWidgets('the subtitle drops the mock clause when there is no mock',
      (tester) async {
    await tester.pumpWidget(tabHarness(record: recordWithNoMock));
    await tester.pumpAndSettle();

    expect(find.textContaining('Best mock'), findsNothing);
    expect(find.textContaining('Day 18'), findsOneWidget);
  });

  testWidgets('milestones are absent even though the data exists',
      (tester) async {
    await tester.pumpWidget(harness(record: fullRecord));
    await tester.pumpAndSettle();
    expect(find.text('Milestones'), findsNothing);
  });

  testWidgets('wholly free: no teaser and no redaction on either tier',
      (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(record: fullRecord, isPro: isPro));
      await tester.pumpAndSettle();

      expect(find.text('Unlock with Pro'), findsNothing);
      expect(find.byType(FaintBars), findsNothing);
    }
  });

  testWidgets('no streak start date renders no line, not a null', (tester) async {
    await tester.pumpWidget(harness(record: recordWithNoStreakStart));
    await tester.pumpAndSettle();

    expect(find.textContaining('null'), findsNothing);
    expect(find.textContaining('since'), findsNothing);
  });

  testWidgets('the tab row opens it with push', (tester) async {
    await tester.pumpWidget(tabHarness(record: fullRecord));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Your record'));
    await tester.pumpAndSettle();

    expect(find.byType(YourRecordPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });
```

- [ ] **Step 2 to 4: fail, implement, pass**

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
git commit -m "feat(progress): build Your record, wholly free

It is the student's own history and nothing they produced is paywalled.

Absent, not empty: no mock means no Your mocks panel and no best mock
row, rather than a panel saying none yet and a row saying 0%. Milestones
stay out even though the data exists, because the form was never
designed."
```

---

## What the Progress thread deliberately leaves undone

- **Milestones.** Their own pass.
- **Best subjects as a shareable card.** Sorting Score descending covers the bragging case
  inside Progress, so a separate Wrapped card may be redundant. Revisit when Wrapped is
  next opened.
- **Per-topic decay.** Cut with the "What's fading" screen. The tab shows one average.
- **Difficulty calibration.** `DifficultyCalibrationSignal` stays unused, deliberately: it
  is circular, since scheduler difficulty rises partly because the student got the
  question wrong, so it cannot be evidence about the material.
- **`ConsistencySignal`, `CoverageBreadthSignal`, `FlagRevisitSignal`.** The first two are
  covered by Your record and Your pace; the third belongs beside Quiz's flagged list.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- A student with no mock sees no mock panel, no mock row, no zero and no "none yet".
- A student with one week of attempts sees no accuracy line.
- The screen is identical on Free and Pro.
- `grep -rn "time studied" lib` returns nothing.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
