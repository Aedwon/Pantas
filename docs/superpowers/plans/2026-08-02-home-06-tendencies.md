# Home, Plan 6 of 6: Your Tendencies

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fill Home's last panel slot with a swipeable deck of four behavioural insights,
one at a time, at a height that never changes, with Free swiping the whole deck and seeing
what is being compared rather than a blank panel.

**Architecture:** One provider assembling four cards from signals already written and
tested, one fixed-height card widget with three renderings (figures, prerequisite,
teaser), and a `PageView` with dots. No new signals, no storage.

**Tech Stack:** Flutter, Riverpod, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-26-home-and-navigation-design.md`
Section 4 in full.

---

## Read this before Task 1: one card cannot be built as specced

**"What works for you" reads `ReadThenQuizSignal` → `WorkflowRatio`, and `WorkflowRatio`
contains no accuracy.** Its two fields are `readThenQuizCount` and `quizFirstCount`, and
the signal computes them by comparing each lesson's `readAt` against the first attempt on
that lesson's topic (`read_then_quiz_signal.dart:47-60`). They are counts of a habit, not
a measure of its payoff.

So the card cannot say which order works better, and the spec's shape for a card is "a
label, two compared figures, one sentence" naming what the gap costs. A count difference
has no cost. **Progress's Section 4 inherits the same gap**, since it lists the same
signal under the same heading with a gap-first treatment.

**This plan builds the honest version and does not invent the missing figure:** the card
states the habit and names nothing about its payoff. Its copy is in Task 2. That is a
placeholder for a ruling, and the ruling is Aedwon's:

| Option | Cost |
|---|---|
| **A. State the habit**, which is what this plan builds | The heading "What works for you" over-promises. Consider renaming it "How you study" in the same pass |
| B. Extend `ReadThenQuizSignal` to carry accuracy per branch | A real signal change with its own tests, and the comparison is confounded: lessons get read on topics the student already finds hard |
| C. Drop the card to four minus one | The deck loses its only non-mock, non-speed insight, and a new user then sees one live card instead of two |

**Do not choose between these while implementing.** Build A, flag it in the handoff, and
`AGENTS.md`'s rule applies: if it looks wrong, stop and say so rather than inventing a
solution.

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-home-03-masthead-and-band.md` | The `_tendenciesPanel` slot, `RuledPanel` with `action` | **Blocking** |
| `2026-08-02-home-02-assessment-attempt-row.md` | Untimed origins excluded from `PerQuestionSpeedSignal` | **Not blocking, but wrong without it.** "How you answer" would report answers given in zero milliseconds |
| Nothing else | All four signals are written and tested | |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** `FaintBars` is the
  redaction treatment and already exists.
- **Ink & Rule identity.** No card elevation, no shadows, no large radii, no tinted
  callouts, no coloured left borders, **no blur, no lock icons, no banners, no
  interstitials**. The teaser treatment is Spec 11 Amendment D's: faint paper-toned bars
  where the figures go, and "Unlock with Pro" in board green in the header slot.
- **No inner card.** The panel is already the enclosure; nesting one would be a card in a
  card.
- **No board green except the header's "Unlock with Pro".** The prerequisite state is
  muted text, never board, so it does not compete with Home's single primary action,
  which is "Continue lesson" in Plan 4.
- **Never invent a figure.** Every figure here is the output of a signal already written
  against this student's own use. Do not compute a fifth from two of the four.
- **Voice.** Grade-5-simple English, **no em dashes**, sentence case, no emoji. The words
  FSRS, stability, retention, retrievability and algorithm never appear. "Readiness" stays
  reserved: these are patterns that repeat, not scores, which is why the panel is called
  "Your tendencies".
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
| `lib/features/home/application/tendencies_provider.dart` (create) | Four cards, their ordering, their prerequisite state |
| `lib/features/home/presentation/widgets/tendency_card.dart` (create) | One card at a fixed height, in three renderings |
| `lib/features/home/presentation/widgets/tendencies_panel.dart` (create) | The panel, the `PageView`, the dots, the Free header action |
| `lib/features/home/presentation/home_tab.dart` (modify) | `_tendenciesPanel` returns the real widget |

---

### Task 1: The four cards

**Files:**
- Create: `lib/features/home/application/tendencies_provider.dart`
- Test: `test/features/home/application/tendencies_provider_test.dart`

**Interfaces:**
- Consumes: `TestModeDeltaSignal` → `PressureDelta` (`practiceAccuracy`, `mockAccuracy`,
  `delta`); `MockStaminaSignal` → `StaminaDelta` (`firstHalfAccuracy`,
  `secondHalfAccuracy`, `delta`); `ReadThenQuizSignal` → `WorkflowRatio`
  (`readThenQuizCount`, `quizFirstCount`, `ratio`); `PerQuestionSpeedSignal` →
  `LatencyDistribution` (`averageMs`, `correctAverageMs`, `incorrectAverageMs`). All four
  live in `lib/features/metrics/domain/signal_outputs.dart` and return **null** when
  `window.hasEnoughData` is false.
- Produces:

```dart
enum TendencyKind { underPressure, stamina, whatWorks, howYouAnswer }

@immutable
class TendencyCard {
  const TendencyCard({
    required this.kind,
    required this.heading,
    required this.leftLabel,
    required this.rightLabel,
    required this.figures,
    required this.sentence,
    required this.unlockAction,
    required this.pointsAtStake,
  });

  final TendencyKind kind;
  final String heading;

  /// Both comparison labels are shown even when the figures are not.
  /// Knowing what is being compared is what creates the want.
  final String leftLabel;
  final String rightLabel;

  /// Null when the prerequisite is unmet. The labels above still render.
  final ({String left, String right})? figures;

  /// Null when the prerequisite is unmet.
  final String? sentence;

  /// What unlocks this card, shown when [figures] is null. For example
  /// "Finish one full length mock".
  final String unlockAction;

  /// Ordering key. Worst first, descending. Cards with no figures sort last.
  final double pointsAtStake;
}

final tendenciesProvider = FutureProvider<List<TendencyCard>>(...);
```

**The four, and what each needs:**

| Kind | Heading | Prerequisite | Unlock action |
|---|---|---|---|
| `underPressure` | Under pressure | One full mock plus practice on matching topics | Finish one full length mock |
| `stamina` | Stamina | One completed full length mock | Finish one full length mock |
| `whatWorks` | What works for you | One lesson read, then a quiz on that topic | Read a lesson, then answer questions on it |
| `howYouAnswer` | How you answer | Any quiz with response timing | Answer a few questions |

**"Worst first, descending. Cards blocked by a missing prerequisite sort last."** For the
three delta-shaped cards, `pointsAtStake` is the absolute delta. For `whatWorks` it is 0
until the ruling above resolves, which puts it after the measurable cards and before the
blocked ones. Say that in a comment so it does not read as an oversight.

**Cards with a null signal are not dropped.** They render the prerequisite state, which is
the point: it turns the two mock-dependent insights into a nudge toward sitting a mock,
which is the behaviour the app wants anyway. A brand new user sees "How you answer"
immediately and three signposts.

- [ ] **Step 1: Write the failing test**

```dart
  test('always four cards, in every data state', () async {
    final cards = await container.read(tendenciesProvider.future);
    expect(cards, hasLength(4));
    expect(
      cards.map((c) => c.kind).toSet(),
      TendencyKind.values.toSet(),
    );
  });

  test('a null signal becomes a prerequisite card, not a missing one',
      () async {
    // No mocks sat.
    final cards = await container.read(tendenciesProvider.future);
    final stamina =
        cards.firstWhere((c) => c.kind == TendencyKind.stamina);

    expect(stamina.figures, isNull);
    expect(stamina.sentence, isNull);
    expect(stamina.leftLabel, isNotEmpty, reason: 'labels always show');
    expect(stamina.rightLabel, isNotEmpty);
    expect(stamina.unlockAction, 'Finish one full length mock');
  });

  test('measurable cards sort before blocked ones', () async {
    // Only howYouAnswer has data.
    final cards = await container.read(tendenciesProvider.future);

    expect(cards.first.kind, TendencyKind.howYouAnswer);
    expect(cards.skip(1).every((c) => c.figures == null), isTrue);
  });

  test('worst first among measurable cards', () async {
    // pressure delta -0.18, stamina delta -0.04.
    final cards = await container.read(tendenciesProvider.future);
    final measurable = cards.where((c) => c.figures != null).toList();

    expect(measurable.first.kind, TendencyKind.underPressure);
  });

  test('a gain sorts by size, not by sign', () async {
    // stamina delta +0.20, pressure delta -0.05.
    final cards = await container.read(tendenciesProvider.future);
    final measurable = cards.where((c) => c.figures != null).toList();

    expect(measurable.first.kind, TendencyKind.stamina);
  });

  test('no user-facing string names the scheduler', () async {
    final cards = await container.read(tendenciesProvider.future);
    const banned = ['FSRS', 'stability', 'retention', 'algorithm', 'marks'];
    for (final card in cards) {
      final text = [
        card.heading,
        card.leftLabel,
        card.rightLabel,
        card.sentence ?? '',
        card.unlockAction,
      ].join(' ');
      for (final word in banned) {
        expect(text.toLowerCase(), isNot(contains(word.toLowerCase())));
      }
      expect(text, isNot(contains('—')));
    }
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/application/tendencies_provider_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the provider**

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/home/application/`
Expected: PASS, 6 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/application/tendencies_provider.dart test/features/home/application/tendencies_provider_test.dart
git commit -m "feat(home): assemble the four tendency cards

A card whose signal returns null is not dropped: it renders its
prerequisite and the action that unlocks it, which turns the two
mock-dependent insights into a nudge toward sitting a mock."
```

---

### Task 2: The card, at a height that never changes

**Files:**
- Create: `lib/features/home/presentation/widgets/tendency_card.dart`
- Test: `test/features/home/presentation/widgets/tendency_card_test.dart`

**Interfaces:**
- Consumes: `TendencyCard` from Task 1; `FaintBars`.
- Produces: `class TendencyCardView extends StatelessWidget` taking
  `({required TendencyCard card, required bool isPro})`.

**Fixed height, 112px.** All four insights share one shape, so the height falls out of the
content rather than being imposed by padding or truncation. Locked cards use the same box,
so nothing jumps mid-swipe. **Assert it in the test at every rendering**, because a panel
that changes height while being swiped is the fault this number exists to prevent.

**Content is centred**, matching the stats band above it.

**Three renderings, and only three:**

| Condition | What it shows |
|---|---|
| Pro, figures present | Heading, both labels, both figures, the sentence |
| Pro, figures null | Heading, both labels, "Not enough data yet", the unlock action, in **muted text, never board** |
| Free, any | Heading, both labels, `FaintBars` where each figure goes |

**Free swipes the full deck.** Each card shows the insight's name and both comparison
labels with rules where the figures go. Knowing what is being compared is what creates the
want, and four moments of curiosity beat one blank panel. Free is **not** shown the
prerequisite state as a separate case: with no figures either way, the redaction is the
same box, and adding a fourth rendering would be complexity nobody sees.

**The copy for `whatWorks`, pending the ruling in this plan's opening section:**

- `leftLabel`: `read first`
- `rightLabel`: `answered first`
- `figures`: the two counts, for example `12` and `4`
- `sentence`: `You read the lesson first on 12 topics and went straight to
  questions on 4.`

**The sentence states the habit and claims nothing about its payoff**, because
`WorkflowRatio` holds no accuracy. Do not write "reading first works better for you". That
would be a figure this project inferred, printed as a fact, which is exactly what
`AGENTS.md` bans.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('every rendering is exactly 112 tall', (tester) async {
    for (final card in [withFigures, blocked]) {
      for (final isPro in [true, false]) {
        await tester.pumpWidget(
          harness(TendencyCardView(card: card, isPro: isPro)),
        );
        expect(
          tester.getSize(find.byType(TendencyCardView)).height,
          112,
          reason: 'nothing may jump mid-swipe',
        );
      }
    }
  });

  testWidgets('Pro with figures shows both figures and the sentence',
      (tester) async {
    await tester.pumpWidget(
      harness(TendencyCardView(card: withFigures, isPro: true)),
    );
    expect(find.text('68%'), findsOneWidget);
    expect(find.text('54%'), findsOneWidget);
    expect(find.byType(FaintBars), findsNothing);
  });

  testWidgets('Pro without figures shows the unlock action, muted not board',
      (tester) async {
    await tester.pumpWidget(
      harness(TendencyCardView(card: blocked, isPro: true)),
    );
    expect(find.text('Not enough data yet'), findsOneWidget);
    expect(find.text('Finish one full length mock'), findsOneWidget);

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('Free sees both labels and bars where the figures go',
      (tester) async {
    await tester.pumpWidget(
      harness(TendencyCardView(card: withFigures, isPro: false)),
    );
    expect(find.text('practising'), findsOneWidget);
    expect(find.text('under time'), findsOneWidget);
    expect(find.text('68%'), findsNothing);
    expect(find.byType(FaintBars), findsWidgets);
  });

  testWidgets('no lock icon, no blur, anywhere', (tester) async {
    await tester.pumpWidget(
      harness(TendencyCardView(card: withFigures, isPro: false)),
    );
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('what works states the habit and not its payoff',
      (tester) async {
    await tester.pumpWidget(
      harness(TendencyCardView(card: whatWorks, isPro: true)),
    );
    expect(
      find.text(
        'You read the lesson first on 12 topics and went straight to '
        'questions on 4.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('works better'), findsNothing);
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/presentation/widgets/tendency_card_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the card**

Wrap the whole thing in `SizedBox(height: 112, ...)`. Do not make it
`ConstrainedBox(minHeight: 112)`: a card that can grow is a card that will, the first time
a sentence runs long, and the swipe will jump.

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/home/presentation/widgets/tendency_card_test.dart`
Expected: PASS, 6 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/widgets/tendency_card.dart test/features/home/presentation/widgets/tendency_card_test.dart
git commit -m "feat(home): draw one tendency card at a fixed 112

Three renderings and no fourth: Pro with figures, Pro without, and Free
with bars where the figures go. Free is not given a separate
prerequisite rendering, because with no figures either way it is the
same box.

What works for you states the habit and claims nothing about its payoff,
because WorkflowRatio holds counts and no accuracy at all."
```

---

### Task 3: The deck

**Files:**
- Create: `lib/features/home/presentation/widgets/tendencies_panel.dart`
- Modify: `lib/features/home/presentation/home_tab.dart`
- Test: `test/features/home/presentation/widgets/tendencies_panel_test.dart`

**Interfaces:**
- Consumes: `tendenciesProvider`, `TendencyCardView`, `RuledPanel` with `action` and
  `onAction`, `entitlementProvider` from
  `lib/features/paywall/application/paywall_providers.dart`.
- Produces: `class TendenciesPanel extends ConsumerWidget`.

**The panel heading is "Your tendencies".** The redesign spec reserves "readiness" until a
real projection model backs it, so the panel avoids it. These are patterns that repeat,
not scores.

**Swipe only. No auto-advance.** Nothing moves while it is being read, and reduce-motion is
satisfied with no special case. A `PageView` with the default physics is the whole
mechanism; do not add a timer.

**Dots show position; hollow dots mark cards not yet unlocked.** "Not yet unlocked" means
`figures == null`, the prerequisite state, and not the Free tier: a Free user's dots
follow the same rule, so the dots never become a second paywall marker.

**The header's trailing slot:**

| Tier | Slot |
|---|---|
| Free | `Unlock with Pro`, in board green, routing to the paywall |
| Pro | `See full details`, routing to `/progress` |

**"See full details" goes to Progress, not to a new page.** Progress is the analytical
dashboard and the tendency work fills in its panels. Two analytics destinations would
drift apart. Use `context.go('/progress')`, the tab-switch case.

**One teaser, once.** The header action is the whole teaser. No second "Unlock with Pro"
inside the deck, no banner beneath it.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('swipes through four cards and never changes height',
      (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();

    final before = tester.getSize(find.byType(TendenciesPanel));
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(TendenciesPanel)), before);
    }
  });

  testWidgets('nothing advances on its own', (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();
    final first = currentCardHeading(tester);

    await tester.pump(const Duration(seconds: 12));
    expect(currentCardHeading(tester), first);
  });

  testWidgets('hollow dots mark cards with no figures, on both tiers',
      (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(
        harness(cards: twoMeasurableTwoBlocked, isPro: isPro),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tendency-dot-hollow')), findsNWidgets(2));
    }
  });

  testWidgets('Free gets Unlock with Pro in board, in the header',
      (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: false));
    await tester.pumpAndSettle();

    final action = tester.widget<Text>(find.text('Unlock with Pro'));
    expect(action.style?.color, AppColors.light.board);
    expect(find.text('See full details'), findsNothing);
  });

  testWidgets('Pro gets See full details and no teaser at all',
      (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();

    expect(find.text('See full details'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsNothing);
  });

  testWidgets('exactly one teaser on the panel', (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: false));
    await tester.pumpAndSettle();
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('the panel is titled Your tendencies and never says readiness',
      (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();
    expect(find.text('Your tendencies'), findsOneWidget);
    expect(find.textContaining('readiness'), findsNothing);
    expect(find.textContaining('Readiness'), findsNothing);
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/home/presentation/widgets/tendencies_panel_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the panel**

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/home/`
Expected: PASS.

- [ ] **Step 5: Wire it into the page**

```dart
  Widget _tendenciesPanel(BuildContext context, WidgetRef ref) =>
      const TendenciesPanel();
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
git commit -m "feat(home): draw the tendency deck, swipe only

Free swipes the whole deck and sees both comparison labels with bars
where the figures go: knowing what is being compared is what creates the
want, and four moments of curiosity beat one blank panel.

This is the first Pro gating on Home. One teaser, in the header slot, no
lock icons and no blur.

Hollow dots mark cards with an unmet prerequisite on both tiers, so the
dots never become a second paywall marker."
```

---

## The ruling this plan is waiting on

**"What works for you" states a habit and its heading promises a payoff.** The signal
holds no accuracy, so the payoff cannot be stated without inventing it. Options A, B and C
are at the top of this plan. Aedwon decides; the implementor builds A and says so.

**Progress's Section 4 has the same gap**, listing the same signal under the same heading
with a gap-first treatment and a sentence "naming what it costs". Whatever is decided here
must be applied there in the same pass, or the two surfaces will describe the same signal
differently.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- The panel is the same height on all four cards, on both tiers, with and without figures.
- Nothing advances on its own after twelve seconds.
- Exactly one "Unlock with Pro" exists on the Home tab.
- `grep -rn "readiness\|Readiness" lib/features/home` returns nothing.
- `grep -rni "fsrs\|stability\|algorithm" lib/features/home` returns nothing.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
