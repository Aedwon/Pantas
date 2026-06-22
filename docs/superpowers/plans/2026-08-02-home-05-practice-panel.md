# Home, Plan 5 of 6: The Practice Panel

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

**Goal:** Fill Home's second panel slot with the student's three weakest topics, measured
from what they have actually answered rather than frozen on assessment day, each row
starting a session on that topic in one tap.

**Architecture:** One provider ranking topics by accuracy over `attempts_local`, one
widget drawing three rows with a meter and a percentage, and a call into the existing
`StartTodaySession` with a `topicId`. No storage changes.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-26-home-and-navigation-design.md`
Section 3, "Practice", as reopened and rewritten on 2 August.
**Decision log:** `docs/superpowers/decisions/2026-08-02-home-weakest-areas-log.md`.

---

## Read the decision log before the first line of code

This section was superseded three times over and its replacement makes choices that look
arbitrary without their reasons. Four in particular:

1. **The figures come from attempts, not from `AssessmentResult.topicMasteries`.** That
   record is written once by `CompleteAssessment` and never recomputed, so it freezes on
   assessment day, and each of its percentages rests on at most three questions.
2. **The floor governs the figure, not the ranking.** My first version excluded
   under-measured topics from the ranking, and that was wrong: once all 18 topics carry
   questions the assessment gives each **one** question, so an exclusion rule would empty
   this panel completely on the day the content is finished.
3. **The three figures are free**, and Progress's Section 7 was amended to say so. This is
   a stated opening in a paywall, not a leak.
4. **The plate reads "Practice", not "Weakest areas".** The rename is from 26 July and
   survived, because its reasoning survived: the two panels stop being duplicates the
   moment they stop sharing a destination.

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-home-02-assessment-attempt-row.md` | The assessment writing an `attempts_local` row | **Blocking.** Without it this panel is empty immediately after the assessment, which is the moment it is most needed |
| `2026-08-02-home-03-masthead-and-band.md` | The `_practicePanel` slot and `RuledPanel`'s action | **Blocking** |
| `2026-08-02-home-04-up-next.md` | Its topic ranking | **Not blocking**, but do not write a second one. See Task 1 |
| `2026-07-30` Progress's Performance table | Nothing | Independent. They read the same data and must agree |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** `InlineMeter` exists and
  was written for exactly this case: it takes a `value` and a `color` and the **caller
  supplies the semantic colour**. `InkTableRow` is the row type.
- **Ink & Rule identity.** No card elevation, no shadows, no large radii, no tinted
  callouts, no coloured left borders, no blur, no shimmer.
- **Severity colour, and no board green in this panel.** Rust below 50, amber below 70,
  plain `ink` at 70 and above. Board is spent on "Continue lesson" in Plan 4 and on the
  header action's text, and nowhere else here.
- **Never invent a figure.** The percentage is this student's own correctness on that
  topic and nothing else. Do not blend in FSRS state, do not weight by difficulty, do not
  project.
- **Voice.** Grade-5-simple English, **no em dashes**, sentence case, no emoji. Scores are
  "points", never "marks".
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
| `lib/features/home/application/topic_accuracy_provider.dart` (create) | The one ranking of topics by measured accuracy. Plan 4 reads it too |
| `lib/features/home/presentation/widgets/practice_panel.dart` (create) | The panel, three rows, the meter, the tap |
| `lib/features/home/presentation/home_tab.dart` (modify) | `_practicePanel` returns the real widget |
| `test/features/home/application/topic_accuracy_provider_test.dart` (create) | The floor, the ranking, the unmeasured case |
| `test/features/home/presentation/widgets/practice_panel_test.dart` (create) | Colour, copy, the tap, the states |

---

### Task 1: The ranking

**Files:**
- Create: `lib/features/home/application/topic_accuracy_provider.dart`
- Test: `test/features/home/application/topic_accuracy_provider_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`; `activeExamFocusProvider`; `AttemptItemReader` from
  `lib/features/metrics/signals/attempt_item_reader.dart`.
- Produces:

```dart
/// A topic's measured accuracy, or the fact that it is not yet measurable.
@immutable
class TopicAccuracy {
  const TopicAccuracy({
    required this.topicId,
    required this.topicName,
    required this.correct,
    required this.answered,
  });

  final TopicId topicId;
  final String topicName;
  final int correct;
  final int answered;

  /// The sample floor. Below this the row is still ranked and still
  /// tappable, and prints no figure at all.
  ///
  /// Three, because the assessment gives a contributing topic
  /// `max(1, min(3, 35 ~/ contributing))` questions: three while the bank
  /// is thin, one once all 18 topics are authored. Excluding under-measured
  /// topics from the ranking would therefore empty this panel on the day
  /// the content is finished.
  ///
  /// One constant. Moving it is a one-line change.
  static const int floor = 3;

  bool get isMeasured => answered >= floor;

  /// Null below the floor, so a caller cannot print a percentage off one
  /// question by forgetting to check.
  double? get accuracy => isMeasured ? correct / answered : null;
}

final topicAccuracyProvider = FutureProvider<List<TopicAccuracy>>(...);
```

**`accuracy` returns null below the floor on purpose.** This is the same discipline
`ExamDate.day` uses for month precision: make the unprintable value physically
unreachable rather than guarding it at every call site.

**The ranking rule, in order:**

1. Every topic in the active exam, including ones with no attempts at all.
2. Sorted by accuracy ascending, weakest first.
3. **Topics with zero answered questions sort last**, never at 0%. Zero of zero is an
   undefined accuracy, and treating it as nought would park every untouched topic at the
   top of the panel forever, which is the opposite of the panel's job.
4. Topics between one and two answered questions sort **by their raw ratio** among the
   measured ones. They are ranked honestly and they print nothing. A one-question sample
   is a fine reason to put Chemistry at the top of a list to work on, and a bad reason to
   print "0%" in rust.

**The query.** `attempts_local` rows for the exam with `completedAt` not null, each row's
`itemsJson` read through `AttemptItemReader`, each item's `questionId` resolved to a topic
by **`SignalContentHelpers.topicIdForQuestion`**, which already exists in
`lib/features/metrics/signals/signal_content_helpers.dart` and is what
`ReadThenQuizSignal` uses. Do not write a parallel lookup.

**Every origin counts, including `assessment`.** Correctness is correctness, whatever the
session was. Only the millisecond figures exclude untimed origins, and this panel prints
no time.

- [ ] **Step 1: Write the failing test**

Use a real in-memory `AppDatabase`, the way `test/core/storage/` does.

```dart
  test('ranks measured topics weakest first', () async {
    // Chemistry 1/5, Algebra 3/5, Geometry 5/5.
    final ranked = await container.read(topicAccuracyProvider.future);

    expect(
      ranked.take(3).map((t) => t.topicId),
      ['chemistry', 'algebra', 'geometry'],
    );
  });

  test('an untouched topic sorts last, never at nought per cent', () async {
    // Chemistry 1/5. Physics has no attempts at all.
    final ranked = await container.read(topicAccuracyProvider.future);

    expect(ranked.first.topicId, 'chemistry');
    expect(ranked.last.topicId, 'physics');
    expect(ranked.last.answered, 0);
    expect(ranked.last.accuracy, isNull);
  });

  test('below the floor a topic is ranked and prints nothing', () async {
    // Chemistry 0/1: worst ratio, and unmeasurable.
    final ranked = await container.read(topicAccuracyProvider.future);

    final chemistry = ranked.firstWhere((t) => t.topicId == 'chemistry');
    expect(ranked.first.topicId, 'chemistry', reason: 'still ranked first');
    expect(chemistry.isMeasured, isFalse);
    expect(chemistry.accuracy, isNull, reason: 'and prints nothing');
  });

  test('exactly three answered clears the floor', () async {
    final ranked = await container.read(topicAccuracyProvider.future);
    final topic = ranked.firstWhere((t) => t.topicId == 'chemistry');

    expect(topic.answered, 3);
    expect(topic.isMeasured, isTrue);
    expect(topic.accuracy, closeTo(1 / 3, 0.001));
  });

  test('assessment attempts count toward accuracy', () async {
    // One attempt row with origin 'assessment', 3 items, 1 correct.
    final ranked = await container.read(topicAccuracyProvider.future);
    final topic = ranked.firstWhere((t) => t.topicId == 'chemistry');

    expect(topic.answered, 3);
    expect(topic.correct, 1);
  });

  test('an unfinished attempt is not counted', () async {
    // One row with completedAt null.
    final ranked = await container.read(topicAccuracyProvider.future);
    expect(ranked.firstWhere((t) => t.topicId == 'chemistry').answered, 0);
  });

  test('a topic from another exam never appears', () async {
    final ranked = await container.read(topicAccuracyProvider.future);
    expect(ranked.map((t) => t.topicId), isNot(contains('cse-only-topic')));
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/application/topic_accuracy_provider_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the provider**

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/home/application/`
Expected: PASS, 7 tests.

- [ ] **Step 5: If Plan 4 landed first, collapse the duplicate ranking**

Run: `grep -rn "accuracy" lib/features/home/application/up_next_provider.dart`

If Plan 4 wrote its own ranking, delete it and have `upNextProvider` watch
`topicAccuracyProvider`. Two rankings of the same data is how Home ends up calling a topic
weak in one panel and strong in the one beneath it.

Run: `flutter test test/features/home/`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/application/topic_accuracy_provider.dart test/features/home/application/topic_accuracy_provider_test.dart
git commit -m "feat(home): rank topics by measured accuracy, with an honest floor

Reads attempts rather than AssessmentResult.topicMasteries, which is
written once and never recomputed and rests on at most three questions
per topic.

accuracy returns null below the floor so a caller cannot print a
percentage off one question by forgetting to check. Untouched topics
sort last rather than at nought per cent."
```

---

### Task 2: The panel

**Files:**
- Create: `lib/features/home/presentation/widgets/practice_panel.dart`
- Modify: `lib/features/home/presentation/home_tab.dart`
- Test: `test/features/home/presentation/widgets/practice_panel_test.dart`

**Interfaces:**
- Consumes: `topicAccuracyProvider`, `TopicAccuracy` from Task 1; `RuledPanel` with
  `action` and `onAction`; `InkTableRow`; `InlineMeter`; `FaintBars`;
  `StartTodaySession` through its existing provider.
- Produces: `class PracticePanel extends ConsumerWidget`, taking no arguments.

**The composition:**

```
Practice                                          See all

Chemistry          ▓▓▓░░░░░░░  31%   ›
Algebra            ▓▓▓▓▓▓░░░░  58%   ›
Geometry           ▓▓▓▓▓▓▓▓░░  81%   ›
```

**Three rows, weakest first.** Take the first three of the ranking.

**No lead line.** The 26 July decision gave this panel "Ten questions on whichever you
tap." That line is cut: session length is the student's own setting,
`quiz_session_length`, which the Quiz tab exposes under "Change how sessions are built".
Home may not promise a number it does not control. The rows carry the verb by being
tappable and by carrying a chevron; nothing else needs saying.

**Every row carries a chevron**, under the Study spec's rule that a chevron marks a row
that is its own destination. Each row is an independent session. Plan 4's Up next rows
correctly carry none.

**The meter and the figure:**

- `InlineMeter(value: accuracy, color: severity)` where severity is `rust` below 0.50,
  `amber` below 0.70, and `ink` at 0.70 and above.
- The percentage in the meta column, same colour as the meter.
- **Below the floor, both are absent.** The row shows the topic name, the chevron, and an
  empty meta slot. Do not draw an empty meter, a zero-width meter or a dash: the slot is
  empty, and the figure appears the moment the third question is answered.

**Tapping a row starts a session on that topic.** `StartTodaySession` already takes an
optional `topicId` (`lib/features/quiz/domain/use_cases/start_today_session.dart:55`), so
this is a call, not a new use case. On `StartTodaySessionStarted`, push the quiz viewer
with the returned session. On `StartTodaySessionNoQuestions`, show the message the use
case returns rather than an invented one.

**The header action is "See all", pointing at `/progress`.** That is where the same
ranking lives as a full sortable table at three levels, and it matches "See full details"
for the tendency deck: Home surfaces the top of a thing and Progress owns the whole of it.
Use `context.go('/progress')`, the tab-switch case.

**States:**

| State | Body |
|---|---|
| Any topics in the exam | Three rows, however few clear the floor |
| Fewer than three topics exist | However many there are |
| No topics at all | The panel does not render |
| Loading | `FaintBars` inside the panel |

There is no "nothing to practise" state and there should not be: weakness is a permanent
bucket, so a weakness-keyed panel never needs a fallback.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('draws three rows, weakest first, with severity colour',
      (tester) async {
    await tester.pumpWidget(
      harness(const [
        TopicAccuracy(
            topicId: 'chem', topicName: 'Chemistry', correct: 3, answered: 10),
        TopicAccuracy(
            topicId: 'alg', topicName: 'Algebra', correct: 6, answered: 10),
        TopicAccuracy(
            topicId: 'geo', topicName: 'Geometry', correct: 9, answered: 10),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('30%'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);

    final meters = tester.widgetList<InlineMeter>(find.byType(InlineMeter));
    expect(
      meters.map((m) => m.color),
      [AppColors.light.rust, AppColors.light.amber, AppColors.light.ink],
    );
  });

  testWidgets('the boundaries land on the right side', (tester) async {
    // 49% rust, 50% amber, 69% amber, 70% ink.
    await tester.pumpWidget(harness(boundaryTopics));
    await tester.pumpAndSettle();

    final meters =
        tester.widgetList<InlineMeter>(find.byType(InlineMeter)).toList();
    expect(meters[0].color, AppColors.light.rust);
    expect(meters[1].color, AppColors.light.amber);
    expect(meters[2].color, AppColors.light.amber);
    expect(meters[3].color, AppColors.light.ink);
  });

  testWidgets('below the floor: ranked, tappable, and no figure at all',
      (tester) async {
    await tester.pumpWidget(
      harness(const [
        TopicAccuracy(
            topicId: 'chem', topicName: 'Chemistry', correct: 0, answered: 1),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.byType(InlineMeter), findsNothing);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('0'), findsNothing);
  });

  testWidgets('every row carries a chevron', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
  });

  testWidgets('no lead line promises a session length', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ten questions'), findsNothing);
    expect(find.textContaining('questions on whichever'), findsNothing);
  });

  testWidgets('tapping a row starts a session on that topic', (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chemistry'));
    await tester.pumpAndSettle();

    expect(fakeStartToday.calls.single.topicId, 'chem');
  });

  testWidgets('no board green in this panel except the header action',
      (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();

    final board = AppColors.light.board;
    for (final meter in tester.widgetList<InlineMeter>(
      find.byType(InlineMeter),
    )) {
      expect(meter.color, isNot(board));
    }
  });

  testWidgets('the plate reads Practice and the action reads See all',
      (tester) async {
    await tester.pumpWidget(harness(threeTopics));
    await tester.pumpAndSettle();
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
    expect(find.text('Weakest areas'), findsNothing);
    expect(find.text('Practice these'), findsNothing);
  });

  testWidgets('no topics at all renders no panel', (tester) async {
    await tester.pumpWidget(harness(const []));
    await tester.pumpAndSettle();
    expect(find.byType(RuledPanel), findsNothing);
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/presentation/widgets/practice_panel_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the panel**

```dart
/// Rust below 50, amber below 70, plain ink above. The same thresholds
/// Progress's performance table uses, because the two surfaces show the
/// same figure and a student who sees a topic rust here and plain there
/// has caught the app disagreeing with itself.
Color severityFor(double accuracy, AppColors colors) {
  final pct = accuracy * 100;
  if (pct < 50) return colors.rust;
  if (pct < 70) return colors.amber;
  return colors.ink;
}
```

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/home/`
Expected: PASS.

- [ ] **Step 5: Wire it into the page**

```dart
  Widget _practicePanel(BuildContext context, WidgetRef ref) =>
      const PracticePanel();
```

- [ ] **Step 6: Run everything**

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: PASS, `No issues found!`, no format diff.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat(home): draw the Practice panel, live and tappable

Three weakest topics measured from what the student has answered, each
row starting a session on that topic in one tap. See all lands on the
Progress performance table, which is the same ranking in full.

Below the sample floor a row is still ranked and still tappable and
prints no figure: a one-question sample is a fine reason to put a topic
at the top of a list and a bad reason to print 0% in rust.

The 26 July lead line promised ten questions. Session length is the
student's own setting, so Home no longer says."
```

---

## A defect these rows inherit, named and not fixed here

`start_today_session.dart:89` writes the session's `topicId` **only when ordering is
`blocked`**, and null otherwise. Passing a `topicId` also narrows the pool to that one
topic, so under the default interleaved ordering `TodayInterleavedPicker` interleaves a
single-topic pool with itself.

So a row from this panel, under default settings, starts a session that is topic-scoped in
fact and unlabelled in storage. **Do not fix it here.** It is listed in the work
checkpoint under "Raised by 2b and awaiting Aedwon", beside the interleaved-tail item, and
it belongs to the Quiz thread where the ordering rules live. Fixing it inside a Home plan
would change quiz behaviour from a file no reviewer of that thread is reading.

## What this plan deliberately leaves undone

- **The tendency deck.** Plan 6, into the last slot.
- **Progress's Performance table**, which is the "See all" destination. It reads the same
  data and is planned separately, last, for the reasons in the work checkpoint.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- A fresh install that has just finished the assessment shows three rows here. If it shows
  none, Plan 2 has not landed.
- A topic with one answered question shows its name and no figure, and is still tappable.
- The severity boundaries are 50 and 70, and a row's colour matches what Progress would
  give the same topic.
- `grep -rn "Weakest areas\|Practice these\|Ten questions" lib` returns nothing.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
