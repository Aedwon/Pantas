# Progress, Plan 4 of 6: Why You Miss Questions

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tell a Pro student why their wrong answers are wrong, in three counts derived
with no input from them, and pay off the mistake tags the Quiz debrief asks three taps
for.

**Architecture:** One provider classifying every miss into exactly one of three causes,
and one section rendering the counts, the interpreting sentence, and the Pro extras. Free
sees the redaction treatment and the tab's one teaser.

**Tech Stack:** Flutter, Riverpod, Drift, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-30-progress-tab-design.md` Section 3,
"Why you miss questions".
**The tier rule** is `docs/superpowers/specs/2026-08-02-pro-entitlement-consolidation-design.md`,
which is now the single source of truth. Progress's Section 7 cites it.

---

## This section is a commitment, not an option

Quiz plan 5's debrief asks the student to tag their mistakes and writes
`AttemptItem.mistakeTag`. The Quiz spec is explicit that **three taps surfacing nowhere
would be worse than never asking**. This section is where they surface. If it is cut, the
debrief's invitation must be cut with it.

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-progress-01-frame-and-grammar.md` | The `_whyYouMissSection` stub, `RuledPanel`, `DataRowTile` | **Blocking** |
| `2026-08-02-home-02-assessment-attempt-row.md` | Untimed origins excluded from `PerQuestionSpeedSignal` | **Blocking in substance.** "Answered too fast" reads that signal's distribution, and 21 answers at zero milliseconds would make almost everything look rushed |
| `2026-08-02-quiz-tab-05-debrief.md` | `AttemptItem.mistakeTag` being written | **Not blocking.** The three counts derive with no student input at all. Only the Pro extra "misreads the student noted themselves" needs it, and it is absent without it |

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **All three counts are T1**, derived from the student's own attempts with **no input
  from them**. Nothing here asks a question or infers a meaning.
- **This is the only wholly Pro section on the tab**, and it carries the tab's **one
  teaser**. Section 7: one teaser per screen, maximum, placed after the free content,
  never before it, never twice.
- **The redaction treatment is `FaintBars`** where the figures sit, plus one line of prose
  and "Unlock with Pro" in board green. **No lock icons, no blur, no banners, no
  interstitials.** `PaywallTeaserPanel` is retired from this tab.
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
| `lib/features/progress/application/miss_causes_provider.dart` (create) | Classify every miss into exactly one cause, plus the Pro extras |
| `lib/features/progress/presentation/widgets/why_you_miss_section.dart` (create) | The band, the sentence, the redaction |
| `lib/features/progress/presentation/progress_page.dart` (modify) | `_whyYouMissSection` returns the real widget |

---

### Task 1: The three causes

**Files:**
- Create: `lib/features/progress/application/miss_causes_provider.dart`
- Test: `test/features/progress/application/miss_causes_provider_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (`attempts_local`, `review_state_local`); `AttemptItemReader`;
  `PerQuestionSpeedSignal` → `LatencyDistribution`; `SignalContentHelpers`;
  `MistakeTag` from `lib/core/storage/domain/attempt.dart`.
- Produces:

```dart
@immutable
class MissCauses {
  const MissCauses({
    required this.hadItRightBefore,
    required this.neverSeenIt,
    required this.answeredTooFast,
    required this.topicsByCause,
    required this.selfNotedMisreads,
  });

  /// A prior correct attempt on the same question. T1.
  final int hadItRightBefore;

  /// No prior attempt and no scheduler state. T1.
  final int neverSeenIt;

  /// responseMs far below this student's own distribution. T1.
  final int answeredTooFast;

  /// Pro only. Which topics each cause concentrates in.
  final Map<MissCause, List<String>> topicsByCause;

  /// Pro only. Misreads the student noted themselves in the debrief.
  /// Empty until Quiz plan 5 ships.
  final int selfNotedMisreads;

  int get total => hadItRightBefore + neverSeenIt + answeredTooFast;
}

enum MissCause { hadItRightBefore, neverSeenIt, answeredTooFast, unclassified }

final missCausesProvider = FutureProvider<MissCauses?>(...);
```

**The three definitions, exactly:**

| Cause | Test |
|---|---|
| Had it right before | A **prior correct attempt on the same question** |
| Never seen it | **No prior attempt and no scheduler state** |
| Answered too fast | `AttemptItem.responseMs` **far below this student's own distribution** from `PerQuestionSpeedSignal` |

**"Far below this student's own distribution" needs a number, and it is one constant.**
Use **below 40% of `LatencyDistribution.averageMs`**. It is the student's own average, so
the threshold travels with them: a naturally fast reader is not accused of rushing. Put it
in a named constant with this reasoning beside it, so moving it is a one-line change.

**A miss falls into exactly one cause, and the order of the tests matters.** Evaluate in
the table's order: had it right before, then never seen it, then answered too fast. A
question the student once got right and has now rushed is **"had it right before"**,
because that is the actionable reading: they know it, and the fix is a second pass rather
than a first one.

**A miss that fits none is `unclassified` and is not counted anywhere.** Do not distribute
it, do not round the three counts up to the total, and do not print a total that is not
the sum of the three. Two facts may sit side by side; the app does not make them add up.

**Misses from untimed origins cannot be "answered too fast".** They carry
`responseMs: 0`, which is below every threshold. Skip `AttemptOrigins.untimed` rows for
that test only; they still count for the other two.

- [ ] **Step 1: Write the failing test**

```dart
  test('a prior correct attempt is had it right before', () async {
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.hadItRightBefore, 6);
  });

  test('no prior attempt and no scheduler state is never seen it', () async {
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.neverSeenIt, 3);
  });

  test('far below the student own average is answered too fast', () async {
    // Student's average 9000ms; this miss took 2000ms.
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.answeredTooFast, 2);
  });

  test('a fast reader is not accused of rushing', () async {
    // Student's average 3000ms; this miss took 2000ms.
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.answeredTooFast, 0);
  });

  test('a miss falls into exactly one cause', () async {
    // A question once correct, now answered in 500ms.
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.hadItRightBefore, 1);
    expect(causes.answeredTooFast, 0);
  });

  test('an untimed miss is never answered too fast', () async {
    // An assessment miss, responseMs 0, never seen before.
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.answeredTooFast, 0);
    expect(causes.neverSeenIt, 1);
  });

  test('an unclassified miss is counted nowhere', () async {
    final causes = await container.read(missCausesProvider.future);
    expect(
      causes!.total,
      causes.hadItRightBefore + causes.neverSeenIt + causes.answeredTooFast,
      reason: 'the total is the sum of the three, never padded',
    );
  });

  test('with no misses at all the provider returns null', () async {
    expect(await container.read(missCausesProvider.future), isNull);
  });

  test('self-noted misreads are zero until the debrief writes tags',
      () async {
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.selfNotedMisreads, 0);
  });

  test('a tagged misread is counted once the debrief writes it', () async {
    // One AttemptItem with mistakeTag: MistakeTag.misread.
    final causes = await container.read(missCausesProvider.future);
    expect(causes!.selfNotedMisreads, 1);
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/progress/application/miss_causes_provider_test.dart`
Expected: FAIL, unresolved import.

- [ ] **Step 3: Write the provider**

- [ ] **Step 4: Run the tests and make sure they pass**

Expected: PASS, 10 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/progress/application/miss_causes_provider.dart test/features/progress/application/miss_causes_provider_test.dart
git commit -m "feat(progress): classify why questions are missed, with no student input

Three causes, each derived from the student's own attempts. A miss falls
into exactly one, and a question once known and now rushed reads as had
it right before, because that is the actionable reading.

An unclassified miss is counted nowhere and the total is never padded to
match. The rush threshold is a share of the student's own average, so a
naturally fast reader is not accused of rushing."
```

---

### Task 2: The section

**Files:**
- Create: `lib/features/progress/presentation/widgets/why_you_miss_section.dart`
- Modify: `lib/features/progress/presentation/progress_page.dart`
- Test: `test/features/progress/presentation/widgets/why_you_miss_section_test.dart`

**Interfaces:**
- Consumes: `missCausesProvider`, `MissCauses`, `entitlementProvider`, `RuledPanel`,
  `FaintBars`.
- Produces: `class WhyYouMissSection extends ConsumerWidget`.

**Pro sees three counts in a ruled band, then one interpreting sentence:**

```
6 had it right before · 3 never seen it · 2 answered too fast

You mostly know this material already. What is missing is a second pass,
not a first one.
```

**The interpreting sentence follows the largest count, and there are exactly three:**

| Largest | The sentence |
|---|---|
| Had it right before | `You mostly know this material already. What is missing is a second pass, not a first one.` |
| Never seen it | `Most of these are questions you have not met before. This is new ground, not lost ground.` |
| Answered too fast | `Most of these went by quickly. Slowing down on the ones you are unsure of would cost you very little time.` |

**On a tie, the table's order breaks it**, so the sentence is stable across rebuilds. Do
not print two sentences and do not print a hedged one.

**Pro additionally shows** which topics each cause concentrates in, and the misreads the
student noted themselves in the Quiz debrief. **Both are absent rather than zero when
their data does not exist yet.**

**Free sees the redaction treatment, not the counts.** This is a deliberate narrowing of
the earlier proposal and the reason matters: the endowment principle protects a student's
own notes, and **Free users never produce tags** because the debrief's invitation is Pro
only, so nothing of theirs is being withheld.

Free's rendering: the three cause labels with `FaintBars` where each count goes, one line
of prose, and **"Unlock with Pro" in board green**. This is **the tab's only teaser**.

**With no misses at all the section does not render**, on either tier. A student with
nothing wrong does not need to be sold an explanation of why they are wrong.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('Pro sees three counts and one sentence', (tester) async {
    await tester.pumpWidget(
      harness(isPro: true, right: 6, never: 3, fast: 2),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('6'), findsWidgets);
    expect(find.textContaining('had it right before'), findsOneWidget);
    expect(find.textContaining('never seen it'), findsOneWidget);
    expect(find.textContaining('answered too fast'), findsOneWidget);
    expect(
      find.text(
        'You mostly know this material already. What is missing is a second '
        'pass, not a first one.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the sentence follows the largest count', (tester) async {
    await tester.pumpWidget(harness(isPro: true, right: 1, never: 9, fast: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('This is new ground'), findsOneWidget);

    await tester.pumpWidget(harness(isPro: true, right: 1, never: 2, fast: 9));
    await tester.pumpAndSettle();
    expect(find.textContaining('Slowing down'), findsOneWidget);
  });

  testWidgets('a tie prints exactly one sentence', (tester) async {
    await tester.pumpWidget(harness(isPro: true, right: 4, never: 4, fast: 4));
    await tester.pumpAndSettle();

    expect(find.textContaining('second pass'), findsOneWidget);
    expect(find.textContaining('new ground'), findsNothing);
    expect(find.textContaining('Slowing down'), findsNothing);
  });

  testWidgets('Free sees labels and bars, never the counts', (tester) async {
    await tester.pumpWidget(
      harness(isPro: false, right: 6, never: 3, fast: 2),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('had it right before'), findsOneWidget);
    expect(find.text('6'), findsNothing);
    expect(find.byType(FaintBars), findsWidgets);
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('no lock icon, no blur, no banner', (tester) async {
    await tester.pumpWidget(harness(isPro: false, right: 6, never: 3, fast: 2));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('exactly one teaser on the whole tab', (tester) async {
    await tester.pumpWidget(fullTabHarness(isPro: false));
    await tester.pumpAndSettle();
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('the teaser sits after the free content, never before it',
      (tester) async {
    await tester.pumpWidget(fullTabHarness(isPro: false));
    await tester.pumpAndSettle();

    final paceY = tester.getTopLeft(find.text('Your pace')).dy;
    final teaserY = tester.getTopLeft(find.text('Unlock with Pro')).dy;
    expect(paceY, lessThan(teaserY));
  });

  testWidgets('no misses renders no section, on either tier', (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(harness(isPro: isPro, causes: null));
      await tester.pumpAndSettle();
      expect(find.textContaining('had it right before'), findsNothing);
    }
  });

  testWidgets('Pro extras are absent, not zero, without their data',
      (tester) async {
    await tester.pumpWidget(
      harness(isPro: true, right: 6, never: 3, fast: 2, selfNoted: 0),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('you noted'), findsNothing);
    expect(find.text('0'), findsNothing);
  });
```

- [ ] **Step 2 to 4: fail, implement, pass**

- [ ] **Step 5: Wire it in and run everything**

```dart
  Widget _whyYouMissSection(BuildContext context, WidgetRef ref) =>
      const WhyYouMissSection();
```

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: PASS, `No issues found!`, no format diff.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(progress): tell a student why they miss questions

Three counts derived with no input from them, and one sentence following
the largest, with a tie broken by a fixed order so the reading is stable.

Free sees the redaction rather than the counts, which is narrower than
the earlier proposal on purpose: Free never produces mistake tags because
the debrief's invitation is Pro only, so nothing of theirs is withheld.

This is the tab's one teaser and it sits after the free content."
```

---

## What this plan owes and is owed

- **It pays off Quiz plan 5.** The debrief asks three taps for a mistake tag and this is
  where those taps surface. If this section is ever cut, cut the invitation with it.
- **It owes nothing to lesson tagging or the blueprint.** All three counts run on
  `attempts_local` and `review_state_local` alone.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- The three counts always sum to the printed total, and an unclassified miss appears
  nowhere.
- A student whose average response is 3 seconds is never told they answered too fast at 2.
- Free sees exactly one teaser on the whole tab, and it sits below Your pace and
  Performance.
- `grep -rn "PaywallTeaserPanel" lib/features/progress` returns nothing.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
