# Progress, Plan 5 of 6: How You Work

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the sub-screen that answers "who am I as a test taker": a profile heading,
five tendencies drawn gap-first, when the student actually works, and the spaced
repetition explainer, without ever naming the scheduler.

**Architecture:** One provider assembling five comparisons and the working-hours rows, one
gap-first comparison widget, and a pushed screen. The fifth tendency is new and replaces
the deleted "What's fading" screen.

**Tech Stack:** Flutter, Riverpod, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-30-progress-tab-design.md` Section 4, plus
Section 7's Free and Pro row for this screen.

---

## Read this before Task 1: one tendency describes rather than diagnoses

**Settled 2 August.** This section previously listed three open options.

**`ReadThenQuizSignal` → `WorkflowRatio` holds no accuracy.** Its two fields are
`readThenQuizCount` and `quizFirstCount`, computed by comparing each lesson's `readAt`
against the first attempt on that lesson's topic (`read_then_quiz_signal.dart:47-60`).
They are counts of a habit, not a measure of its payoff, so the tendency cannot say which
order works better.

**It is renamed "How you study"** and states the pattern. Extending the signal to carry
accuracy per branch was rejected, and not only on cost: the student chooses which lessons
to read first and reads them on topics they already find hard, so any gap would be
selection rather than effect. That is Section 1's ban, and the same circularity that keeps
`DifficultyCalibrationSignal` unused.

**It keeps the gap-first treatment**, and it is the one tendency of the five where
**neither direction is a loss**, so `isLoss` is always false and it never carries rust. One
card looking different on a screen of five reads as a mistake, and the gap figure being
less pointed here than on its four neighbours is the accepted cost.

**Do not reintroduce a payoff claim.** If a later reader finds this tendency inert, that is
the cost of not inventing a figure, and the fix is a better signal rather than better
wording.

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-progress-01-frame-and-grammar.md` | `NavigationalRow`, `DataRowTile`, the `_goDeeperSection` stub | **Blocking** |
| `2026-08-02-onboarding-flow-and-new-steps.md` Task 2 | `UserSettings.name` | **Not blocking.** With no name the panel shows the "Add your name" invitation Home already specifies |
| `2026-08-02-home-02-assessment-attempt-row.md` | Untimed origins excluded from `PerQuestionSpeedSignal` | **Blocking in substance** for "How you answer" |
| `2026-08-02-home-06-tendencies.md` | Nothing in code | Independent, but **the copy for the four shared tendencies must match**. Read it before writing strings |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **T3 may not be extended past the method's own claims.** The scheduler states how long a
  memory is expected to last. **It does not state what a student will score**, so the
  ninth day may never be phrased as an exam-day outcome and **is never compared to the
  exam date**.
- **`RetentionCurve` returns one average, not a per-topic claim.** Per-topic decay was cut
  with the "What's fading" screen. Do not reintroduce it.
- **The words FSRS, stability, retention, retrievability, algorithm and card never appear
  in a user-facing string.** This screen is the likeliest place in the app to break that
  rule, because it is where the scheduler is explained.
- **Losses carry rust. Gains stay ink. Board green is not spent here.**
- **No em dashes.** Grade-5-simple English, sentence case. No article on archetype names:
  "Night-Owl Sprinter", not "The Night-Owl Sprinter".
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
| `lib/features/progress/application/how_you_work_provider.dart` (create) | Five tendencies, the profile, the working-hours rows |
| `lib/features/progress/presentation/widgets/gap_comparison.dart` (create) | The gap-first treatment |
| `lib/features/progress/presentation/pages/how_you_work_page.dart` (create) | The screen |
| `lib/features/progress/presentation/progress_page.dart` (modify) | The Go deeper row that opens it |
| `lib/app/router.dart` (modify) | `/progress/how-you-work` |

---

### Task 1: The five tendencies and the profile

**Files:**
- Create: `lib/features/progress/application/how_you_work_provider.dart`
- Test: `test/features/progress/application/how_you_work_provider_test.dart`

**Interfaces:**
- Consumes: `TestModeDeltaSignal` → `PressureDelta`; `MockStaminaSignal` → `StaminaDelta`;
  `ReadThenQuizSignal` → `WorkflowRatio`; `PerQuestionSpeedSignal` →
  `LatencyDistribution`; `RetentionShapeSignal` → `RetentionCurve` (`averageStability`,
  `lapseRate`); `TimeOfDaySignal` → `DayHourHistogram`; `SessionShapeSignal` →
  `DurationDistribution` (`averageMinutes`, `sessionCount`);
  `currentArchetypeProvider`; `UserSettings.name`.
- Produces:

```dart
enum TendencyId {
  underPressure,
  stamina,
  howYouStudy,
  howYouAnswer,
  howLongYouRemember,
}

@immutable
class Tendency {
  const Tendency({
    required this.id,
    required this.heading,
    required this.leftLabel,
    required this.rightLabel,
    required this.gap,
    required this.leftFigure,
    required this.rightFigure,
    required this.sentence,
    required this.isLoss,
    required this.unlockAction,
  });

  /// The serif 34/700 figure on the left. Null when the prerequisite is
  /// unmet; the labels still render.
  final String? gap;

  /// Demoted to an 11.5px caption beneath the sentence.
  final String? leftFigure;
  final String? rightFigure;

  final String? sentence;

  /// Losses carry rust. Gains stay ink.
  final bool isLoss;

  final String unlockAction;
}

@immutable
class HowYouWork {
  const HowYouWork({
    required this.name,
    required this.archetype,
    required this.archetypeLine,
    required this.tendencies,
    required this.whenYouWork,
  });

  final String? name;
  final String? archetype;
  final String? archetypeLine;

  /// Always five, in the spec's order. Never filtered.
  final List<Tendency> tendencies;

  /// Three rows: the meta column holds the answer, the subtext says what
  /// it is measured against. Empty when the signals return null.
  final List<({String title, String subtext, String meta})> whenYouWork;
}

final howYouWorkProvider = FutureProvider<HowYouWork>(...);
```

**The five, in this order, and the order is the spec's:**

| Heading | Signal | Tier |
|---|---|---|
| Under pressure | `TestModeDeltaSignal` | T1 |
| Stamina | `MockStaminaSignal` | T1 |
| How you study | `ReadThenQuizSignal` | T1 |
| How you answer | `PerQuestionSpeedSignal` | T1 |
| **How long you remember** | `RetentionShapeSignal` | **T3** |

**The fifth is new and replaces the deleted "What's fading" screen.** Its copy:

> **9d**, and the line reads: what you learn holds about nine days before you need it
> again
> you lapse on 18% of the questions that come back

**The nine days is the scheduler's own estimate and must be phrased as such.** It is never
a promise and **it is never compared to the exam date**. A test must assert that no string
on this screen contains the exam short name beside a day count.

**"When you work"** is three data rows where **the meta column holds the answer and the
subtext says what it is measured against**, from `TimeOfDaySignal` and
`SessionShapeSignal`.

- [ ] **Step 1: Write the failing test**

```dart
  test('always five tendencies, in the spec order', () async {
    final work = await container.read(howYouWorkProvider.future);
    expect(
      work.tendencies.map((t) => t.id),
      [
        TendencyId.underPressure,
        TendencyId.stamina,
        TendencyId.howYouStudy,
        TendencyId.howYouAnswer,
        TendencyId.howLongYouRemember,
      ],
    );
  });

  test('a null signal keeps the heading and both labels', () async {
    final work = await container.read(howYouWorkProvider.future);
    final stamina =
        work.tendencies.firstWhere((t) => t.id == TendencyId.stamina);

    expect(stamina.gap, isNull);
    expect(stamina.leftLabel, isNotEmpty);
    expect(stamina.rightLabel, isNotEmpty);
    expect(stamina.unlockAction, 'Finish one full length mock');
  });

  test('a drop is a loss and a rise is not', () async {
    final work = await container.read(howYouWorkProvider.future);
    final pressure =
        work.tendencies.firstWhere((t) => t.id == TendencyId.underPressure);
    expect(pressure.isLoss, isTrue);
  });

  test('how long you remember states the estimate as an estimate', () async {
    final work = await container.read(howYouWorkProvider.future);
    final retention = work.tendencies
        .firstWhere((t) => t.id == TendencyId.howLongYouRemember);

    expect(retention.gap, '9d');
    expect(
      retention.sentence,
      'what you learn holds about nine days before you need it again',
    );
  });

  test('the retention line is never compared to the exam date', () async {
    final work = await container.read(howYouWorkProvider.future);
    final retention = work.tendencies
        .firstWhere((t) => t.id == TendencyId.howLongYouRemember);

    for (final s in [retention.sentence, retention.leftFigure]) {
      expect(s ?? '', isNot(contains('exam')));
      expect(s ?? '', isNot(contains('UPCAT')));
    }
  });

  test('how you study names the pattern and claims no payoff', () async {
    final work = await container.read(howYouWorkProvider.future);
    final study =
        work.tendencies.firstWhere((t) => t.id == TendencyId.howYouStudy);

    expect(study.heading, 'How you study');
    expect(study.sentence, 'You usually read the lesson first.');
    expect(study.leftFigure, '12');
    expect(study.rightFigure, '4');
    expect(study.gap, '8');
    expect(
      study.isLoss,
      isFalse,
      reason: 'neither direction is a loss, so this one never carries rust',
    );

    for (final claim in ['better', 'works for you', 'What works']) {
      expect(study.sentence!, isNot(contains(claim)));
    }
  });

  test('the three sentences are the whole vocabulary', () async {
    for (final (fixture, sentence) in [
      (readsFirst, 'You usually read the lesson first.'),
      (answersFirst, 'You usually go straight to the questions.'),
      (evenSplit, 'You split about evenly between the two.'),
    ]) {
      final work = await readWith(fixture);
      final study =
          work.tendencies.firstWhere((t) => t.id == TendencyId.howYouStudy);
      expect(study.sentence, sentence);
    }
  });

  test('no banned word appears in any assembled string', () async {
    final work = await container.read(howYouWorkProvider.future);
    const banned = [
      'FSRS', 'stability', 'retention', 'retrievability', 'algorithm',
      'card', 'marks',
    ];
    for (final t in work.tendencies) {
      final text = [
        t.heading, t.leftLabel, t.rightLabel, t.sentence ?? '',
        t.leftFigure ?? '', t.rightFigure ?? '', t.unlockAction,
      ].join(' ').toLowerCase();
      for (final word in banned) {
        expect(text, isNot(contains(word.toLowerCase())));
      }
      expect(text, isNot(contains('—')));
    }
  });

  test('with no name the profile carries none, not an empty string',
      () async {
    final work = await container.read(howYouWorkProvider.future);
    expect(work.name, isNull);
  });
```

- [ ] **Step 2 to 4: fail, implement, pass**

- [ ] **Step 5: Commit**

```bash
git commit -m "feat(progress): assemble How you work, with the fifth tendency

How long you remember replaces the deleted What's fading screen and
reports one average, not a per-topic claim. The estimate is phrased as
the scheduler's own and is never compared to the exam date: the method
states how long a memory lasts and says nothing about what anyone will
score.

How you study names the pattern and claims no payoff, matching Home plan
6, because the signal holds counts and no accuracy."
```

---

### Task 2: The gap-first comparison

**Files:**
- Create: `lib/features/progress/presentation/widgets/gap_comparison.dart`
- Test: `test/features/progress/presentation/widgets/gap_comparison_test.dart`

**Interfaces:**
- Consumes: `Tendency` from Task 1; `FaintBars`.
- Produces: `class GapComparison extends StatelessWidget` taking
  `({required Tendency tendency, required bool isPro})`.

**The treatment:** the difference as a **serif 34/700** figure on the left, the sentence
naming what it costs, and **the two source figures demoted to an 11.5px caption**.

**Losses carry rust. Gains stay ink. Board green is not spent here.**

**Compared figures are joined by "vs." only in prose, never by a hairline.** Section 8 says
so; do not draw a divider between the two caption figures.

**Free** sees the heading and both comparison labels with `FaintBars` where the figures go,
on all five. Knowing what is being compared is what creates the want; this is Home's
already-approved treatment.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the gap leads at 34/700 serif', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    final gap = tester.widget<Text>(find.text('14'));
    expect(gap.style?.fontSize, 34);
    expect(gap.style?.fontWeight, FontWeight.w700);
    expect(gap.style?.fontFamily, 'SourceSerif4');
  });

  testWidgets('a loss is rust and a gain is ink', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    expect(
      tester.widget<Text>(find.text('14')).style?.color,
      AppColors.light.rust,
    );

    await tester.pumpWidget(harness(tendency: gainOf9, isPro: true));
    expect(
      tester.widget<Text>(find.text('9')).style?.color,
      AppColors.light.ink,
    );
  });

  testWidgets('board green is never spent here', (tester) async {
    await tester.pumpWidget(harness(tendency: gainOf9, isPro: true));
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('the source figures are demoted to 11.5', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    expect(tester.widget<Text>(find.text('68%')).style?.fontSize, 11.5);
  });

  testWidgets('no hairline joins the two figures', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    expect(find.byKey(const ValueKey('figure-divider')), findsNothing);
  });

  testWidgets('Free sees both labels and bars where the figures go',
      (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: false));

    expect(find.text('practising'), findsOneWidget);
    expect(find.text('under time'), findsOneWidget);
    expect(find.text('14'), findsNothing);
    expect(find.byType(FaintBars), findsWidgets);
  });

  testWidgets('an unmet prerequisite is muted, never board', (tester) async {
    await tester.pumpWidget(harness(tendency: blocked, isPro: true));

    expect(find.text('Not enough data yet'), findsOneWidget);
    expect(find.text('Finish one full length mock'), findsOneWidget);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });
```

- [ ] **Step 2 to 5: fail, implement, pass, commit**

```bash
git commit -m "feat(progress): add the gap-first comparison

The difference leads, the sentence names what it costs, and the two
source figures are demoted to a caption. Losses carry rust, gains stay
ink, and board is not spent here."
```

---

### Task 3: The screen, and the row that opens it

**Files:**
- Create: `lib/features/progress/presentation/pages/how_you_work_page.dart`
- Modify: `lib/features/progress/presentation/progress_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/progress/presentation/pages/how_you_work_page_test.dart`

**Interfaces:**
- Consumes: `howYouWorkProvider`, `GapComparison`, `NavigationalRow`, `DataRowTile`,
  `RuledPanel`.
- Produces: the route `/progress/how-you-work`.

**Composition, top to bottom:**

1. Panel **"Your profile"**, **centred**: the student's chosen name in serif **24/700**,
   the archetype beneath it in sans **13/600**, then one line. Centring matches Home's
   stats band and tendency deck. **With no name stored, the panel shows the "Add your
   name" invitation Home already specifies.**
2. **Five tendencies**, each a section header over one `GapComparison`.
3. **"When you work"**: three data rows.
4. **The spaced repetition explainer**, which moved here with the decay figure:

> Pantas shows a question again just before you would forget it. The ones you forget fast
> come back often. The ones that stick come back rarely, so your time goes where it is
> needed. This is called **spaced repetition**.

**Free** sees all five headings and both comparison labels with `FaintBars`, **and does not
see "When you work"**. Its teaser sits **after the fifth tendency**.

**The Go deeper row** on the tab: `NavigationalRow`, title "How you work", subtitle
carrying this screen's verdict, for example "Night-Owl Sprinter. Sharpest at 9 pm, in 8
minute sits." Use `context.push`, since this screen sits outside the tab shell.

**Route it under `/progress/`** so the path says where it belongs.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the profile is centred and carries the name', (tester) async {
    await tester.pumpWidget(harness(name: 'Aedwon', isPro: true));
    await tester.pumpAndSettle();

    final name = tester.widget<Text>(find.text('Aedwon'));
    expect(name.style?.fontSize, 24);
    expect(name.textAlign, TextAlign.center);
  });

  testWidgets('with no name it shows the invitation', (tester) async {
    await tester.pumpWidget(harness(name: null, isPro: true));
    await tester.pumpAndSettle();
    expect(find.text('Add your name'), findsOneWidget);
  });

  testWidgets('five tendencies render on both tiers', (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(isPro: isPro));
      await tester.pumpAndSettle();
      expect(find.byType(GapComparison), findsNWidgets(5));
    }
  });

  testWidgets('Free does not see When you work', (tester) async {
    await tester.pumpWidget(harness(isPro: false));
    await tester.pumpAndSettle();
    expect(find.text('When you work'), findsNothing);
  });

  testWidgets('the Free teaser sits after the fifth tendency',
      (tester) async {
    await tester.pumpWidget(harness(isPro: false));
    await tester.pumpAndSettle();

    final fifthY = tester.getTopLeft(find.text('How long you remember')).dy;
    final teaserY = tester.getTopLeft(find.text('Unlock with Pro')).dy;
    expect(fifthY, lessThan(teaserY));
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('the explainer never names the scheduler', (tester) async {
    await tester.pumpWidget(harness(isPro: true));
    await tester.pumpAndSettle();

    expect(find.textContaining('spaced repetition'), findsOneWidget);
    for (final word in [
      'FSRS', 'stability', 'retention', 'retrievability', 'algorithm', 'card',
    ]) {
      expect(find.textContaining(word), findsNothing);
    }
  });

  testWidgets('the archetype name carries no article', (tester) async {
    await tester.pumpWidget(harness(isPro: true, archetype: 'Night-Owl Sprinter'));
    await tester.pumpAndSettle();

    expect(find.text('Night-Owl Sprinter'), findsOneWidget);
    expect(find.textContaining('The Night-Owl'), findsNothing);
  });

  testWidgets('the tab row opens it with push, not go', (tester) async {
    await tester.pumpWidget(tabHarness());
    await tester.pumpAndSettle();
    await tester.tap(find.text('How you work'));
    await tester.pumpAndSettle();

    expect(find.byType(HowYouWorkPage), findsOneWidget);
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
git commit -m "feat(progress): build How you work

Five tendencies gap-first, when the student actually works, and the
spaced repetition explainer that moved here with the decay figure. The
words FSRS, stability, retention, retrievability, algorithm and card
appear nowhere, which is hardest to hold on the one screen that explains
the scheduler."
```

---

## The ruling, closed

**Settled 2 August: "How you study", gap-first kept, stating the pattern and claiming no
payoff.** Both specs and Home plan 6 carry it. Nothing on this tendency is outstanding.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- `grep -rni "fsrs\|stability\|retrievability\|algorithm" lib/features/progress` returns
  nothing.
- The retention line never names the exam and never compares to its date.
- Free sees five headings, ten labels, no figures, no "When you work", and exactly one
  teaser, after the fifth tendency.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
