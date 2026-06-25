# Mock 03: boundaries, strict mode and the clock

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**This plan is model-agnostic.** It names no harness-specific skill in its tasks. Read
`AGENTS.md` and `SUBAGENTS.md` before writing a line. Its spec is
`docs/superpowers/specs/2026-07-28-mock-exam-ui-design.md`, **Sections 7, 8 and 9**, all added
4 August 2026.

**Goal:** Build the four surfaces the mock spec left undesigned until 4 August: the section
transition, strict mode's second job, the pause screen, and the clock rule with its proctor.

**Architecture:** Three of the four are pure presentation over state the session controller
already holds. The fourth, the proctor, is a small scheduler that watches remaining time in the
current part and fires at four thresholds. Nothing here touches the database.

**Tech Stack:** Flutter, Riverpod, flutter_test. `HapticFeedback` from the Flutter framework.
**No new packages.**

---

## Where this sits against the other two mock plans

`2026-08-02-mock-01-the-paper.md` and `2026-08-02-mock-02-the-endings.md` were written before
this round and neither covers these surfaces.

| Plan | Owns |
|---|---|
| Mock 01 | Blueprint content fields, the setup screen, the grid's mock variant, the floating bar, part boundaries in the session |
| Mock 02 | Results, review, the one-time offer, the practice ending |
| **Mock 03, this plan** | The transition, strict mode's forbidding, the pause screen, the clock rule and the proctor |

**This plan runs after Mock 01** and touches three of its files. It does not depend on Mock 02.

---

## Prerequisites, and this plan stops if any is absent

**Confirm all three before Task 1. If any is missing, stop and say so.**

| Needs | From | Check |
|---|---|---|
| The floating bar, and the session honoring part boundaries | Mock 01, Tasks 4 and 5 | The bar exists with five controls and `next` dims at the last item of a part |
| The setup screen | Mock 01, Task 2 | It exists and states the sectional rule |
| The strict mock mode setting, with its subtitle | `2026-08-03-settings-01-the-kit.md` and the Settings plans | The stored setting is readable, and the row carries the three-consequence subtitle |

**Also confirm the type tokens.** Sections 7 to 9 use serif 24, serif 16 and sans 13, and **none
of the three exists in `AppTextStyles` today.** They are added by
`2026-08-03-settings-01-the-kit.md`. **If they are absent, stop and say so** rather than
hand-rolling sizes that will later disagree with the kit.

---

## Global Constraints

Every task's requirements implicitly include this section.

- **Do not touch `schemaVersion`.** This plan adds no tables and no columns.
- **No em dashes** anywhere: copy, comments or commit messages. A colon or a comma.
- **American spelling.** practice, color, behavior, analyze, gray, center, organize.
- **Never put AI attribution in a commit message.**
- **Never print a figure this project did not measure.** Every number on these surfaces is the
  student's own count, or the clock.
- **No score and no correctness anywhere in this plan.** The transition and the pause screen
  show answered, blank and flagged only. **Nothing in these files may read a correct answer.**
- **Amber is used in exactly two places** and nowhere else in the mock: the clock rule under one
  minute, and the proctor's final call.
- **Dialogs use the shared confirmation component**, which puts both actions in one row and
  takes a rust confirm when destructive. **Never stack them.**
- **The answer rows are the existing shared component.** A serif letter in a 22px column and a
  board-tinted chosen row. **There are no radio buttons in this app.**

### Copy fixed by the spec, verbatim

| Where | Text |
|---|---|
| Strict, on the last item of a part | `Part 1 runs to the end of its time. Strict mock mode is on.` |
| Proctor, four calls | `20 minutes left in this subject.` and 10, 5, then `1 minute left in this subject.` |
| Transition heading | `Time is up for Part 1.` |
| Transition closure | `Part 1 is closed. You cannot go back to it.` |
| Pause warning | `Real exams do not pause.` |
| Pause body | `Use this only when you have to. The clock stops, but you will not get this in the real room.` |

**"Subject" appears only in the proctor. Everywhere else says "part".** This is deliberate:
part is the structural label, subject is the proctor's spoken word. **Do not unify them.**

### Gate command

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart            # expect 7
dart run tool/check_no_ai_attribution.dart   # expect 0
```

The analyzer invariant is **zero issues under `lib/` and `test/` outside `test/tool/`**.

---

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `lib/features/mock_exam/domain/part_clock.dart` | **Create.** Remaining time in the current part, and the four call thresholds | 1 |
| `lib/features/mock_exam/presentation/clock_rule.dart` | **Create.** The app bar clock and its retreating rule | 2 |
| `lib/features/mock_exam/presentation/proctor_toast.dart` | **Create.** The call, and the haptic | 3 |
| `lib/features/mock_exam/presentation/part_transition_page.dart` | **Create.** The section transition | 4 |
| `lib/features/mock_exam/presentation/pause_page.dart` | **Create.** The pause screen and its two dialogs | 5 |
| `lib/features/mock_exam/presentation/mock_session_page.dart` | Wire the four in. Modify | 2, 3, 5, 6 |
| `lib/features/mock_exam/application/mock_session_controller.dart` | Pause, resume, discard, end part early. Modify | 5, 6 |

---

### Task 1: The part clock

**Pure Dart. No Flutter import, no providers.** Everything the other four tasks read comes from
here, so it must be testable on its own.

**Files:**
- Create: `lib/features/mock_exam/domain/part_clock.dart`
- Test: `test/features/mock_exam/domain/part_clock_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `PartClock`, with
  `Duration remainingInPart({required Duration partLength, required Duration elapsedInPart})`,
  `ClockUrgency urgencyFor(Duration remaining)` returning
  `enum ClockUrgency { ample, closing, last }`, and
  `int? callThresholdCrossed({required Duration before, required Duration after})` returning the
  threshold in minutes when a call is due, otherwise null.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:cse_cet_reviewer/features/mock_exam/domain/part_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('urgency', () {
    test('ample above five minutes', () {
      expect(urgencyFor(const Duration(minutes: 5, seconds: 1)),
          ClockUrgency.ample);
    });

    test('closing at five minutes and below', () {
      expect(urgencyFor(const Duration(minutes: 5)), ClockUrgency.closing);
      expect(urgencyFor(const Duration(minutes: 1, seconds: 1)),
          ClockUrgency.closing);
    });

    test('last at one minute and below', () {
      expect(urgencyFor(const Duration(minutes: 1)), ClockUrgency.last);
      expect(urgencyFor(Duration.zero), ClockUrgency.last);
    });
  });

  group('the four calls', () {
    test('fires once as the clock crosses a threshold', () {
      expect(
        callThresholdCrossed(
          before: const Duration(minutes: 20, seconds: 1),
          after: const Duration(minutes: 20),
        ),
        20,
      );
    });

    test('does not fire again while sitting on the same side', () {
      expect(
        callThresholdCrossed(
          before: const Duration(minutes: 19),
          after: const Duration(minutes: 18, seconds: 59),
        ),
        isNull,
      );
    });

    test('all four thresholds fire', () {
      for (final minutes in [20, 10, 5, 1]) {
        expect(
          callThresholdCrossed(
            before: Duration(minutes: minutes, seconds: 1),
            after: Duration(minutes: minutes),
          ),
          minutes,
        );
      }
    });

    test('a jump past two thresholds reports the lower one only', () {
      // A device that slept through both. The student is at 4 minutes and
      // telling them 10 minutes remain would be false.
      expect(
        callThresholdCrossed(
          before: const Duration(minutes: 11),
          after: const Duration(minutes: 4),
        ),
        5,
      );
    });

    test('never fires at zero', () {
      expect(
        callThresholdCrossed(
          before: const Duration(seconds: 1),
          after: Duration.zero,
        ),
        isNull,
      );
    });
  });

  test('remaining never goes below zero', () {
    expect(
      remainingInPart(
        partLength: const Duration(minutes: 30),
        elapsedInPart: const Duration(minutes: 31),
      ),
      Duration.zero,
    );
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/mock_exam/domain/part_clock_test.dart
```

Expected: FAIL to compile. `part_clock.dart` does not exist.

- [ ] **Step 3: Write it**

```dart
import 'dart:math' as math;

enum ClockUrgency { ample, closing, last }

/// Minutes remaining at which the proctor speaks. Descending, because a
/// clock that jumped past two of them must report the one the student is
/// actually at.
const callThresholdsMinutes = [20, 10, 5, 1];

Duration remainingInPart({
  required Duration partLength,
  required Duration elapsedInPart,
}) {
  final left = partLength - elapsedInPart;
  return left.isNegative ? Duration.zero : left;
}

ClockUrgency urgencyFor(Duration remaining) {
  if (remaining <= const Duration(minutes: 1)) return ClockUrgency.last;
  if (remaining <= const Duration(minutes: 5)) return ClockUrgency.closing;
  return ClockUrgency.ample;
}

/// The threshold just crossed, or null. Called on every tick with the
/// previous and current remaining time.
int? callThresholdCrossed({
  required Duration before,
  required Duration after,
}) {
  // Time up is its own event and the transition screen handles it. A call
  // saying "1 minute left" as the part ends would be a lie.
  if (after <= Duration.zero) return null;

  for (final minutes in callThresholdsMinutes) {
    final mark = Duration(minutes: minutes);
    if (before > mark && after <= mark) return minutes;
  }
  return null;
}

/// A part's length as a fraction still to run, for the retreating rule.
double remainingFraction({
  required Duration partLength,
  required Duration remaining,
}) {
  if (partLength <= Duration.zero) return 0;
  final f = remaining.inMilliseconds / partLength.inMilliseconds;
  return math.min(1, math.max(0, f));
}
```

**The descending threshold list is the reason the jump test passes.** A device that slept from
11 minutes to 4 crosses both 10 and 5, and the student is at 4: telling them 10 remain would be
false.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/mock_exam/domain/part_clock_test.dart
```

Expected: PASS, all seven.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(mock): the part clock, its urgency and its four call marks"
```

---

### Task 2: The clock rule

**Files:**
- Create: `lib/features/mock_exam/presentation/clock_rule.dart`
- Modify: `lib/features/mock_exam/presentation/mock_session_page.dart`
- Test: `test/features/mock_exam/presentation/clock_rule_test.dart`

**Interfaces:**
- Consumes: `ClockUrgency`, `remainingFraction` from Task 1.
- Produces: `class ClockRule extends StatelessWidget` taking
  `{required Duration remaining, required Duration partLength}`, sized to fill an app bar's
  bottom edge. Task 5 does not use it; the transition and pause screens have no clock.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('the rule retreats as time runs out', (tester) async {
  await pumpRule(tester,
      remaining: const Duration(minutes: 15),
      partLength: const Duration(minutes: 30));
  final half = tester.widget<FractionallySizedBox>(
    find.byKey(const Key('clock-rule-fill')),
  );
  expect(half.widthFactor, closeTo(0.5, 0.001));
});

testWidgets('ample time draws a soft hairline', (tester) async {
  await pumpRule(tester,
      remaining: const Duration(minutes: 20),
      partLength: const Duration(minutes: 30));
  final box = tester.widget<Container>(find.byKey(const Key('clock-rule-bar')));
  final decoration = box.decoration! as BoxDecoration;
  expect(box.constraints?.maxHeight ?? 1, 1);
  expect(decoration.color!.a, lessThan(1.0));
});

testWidgets('under five minutes the rule thickens and goes full strength',
    (tester) async {
  await pumpRule(tester,
      remaining: const Duration(minutes: 4),
      partLength: const Duration(minutes: 30));
  final box = tester.widget<Container>(find.byKey(const Key('clock-rule-bar')));
  expect(box.constraints?.maxHeight, 1.6);
});

testWidgets('under one minute the rule and the clock turn amber',
    (tester) async {
  await pumpRule(tester,
      remaining: const Duration(seconds: 45),
      partLength: const Duration(minutes: 30));
  final box = tester.widget<Container>(find.byKey(const Key('clock-rule-bar')));
  final decoration = box.decoration! as BoxDecoration;
  expect(decoration.color, amberOf(tester));
});
```

Write `pumpRule` and `amberOf` as local helpers, reading the amber from the theme rather than
hard coding a hex.

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/mock_exam/presentation/clock_rule_test.dart
```

Expected: FAIL to compile.

- [ ] **Step 3: Write the rule**

A 1px `ink` bar at 55% opacity, aligned left, its width a `FractionallySizedBox` of
`remainingFraction`. At `ClockUrgency.closing` it becomes 1.6px at full opacity. At
`ClockUrgency.last` it becomes 1.6px `amber`.

**It sits on the app bar's own bottom edge**, so in `mock_session_page.dart` it goes in the app
bar's `bottom` slot with a preferred size of 1.6px, not inside the body.

**The clock text takes `amber` at `ClockUrgency.last` and `ink` otherwise.** It is serif 16/700,
tabular figures, centered, and it stays centered: the pause control at the trailing edge must
not shift it.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/mock_exam/presentation/clock_rule_test.dart
```

Expected: PASS, all four.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(mock): the clock carries the part's time as a retreating rule"
```

---

### Task 3: The proctor

**Files:**
- Create: `lib/features/mock_exam/presentation/proctor_toast.dart`
- Modify: `lib/features/mock_exam/presentation/mock_session_page.dart`
- Test: `test/features/mock_exam/presentation/proctor_toast_test.dart`

**Interfaces:**
- Consumes: `callThresholdCrossed` from Task 1.
- Produces: `class ProctorToast extends StatelessWidget` taking `{required int minutes}`, and
  `String proctorCopyFor(int minutes)`.

- [ ] **Step 1: Write the failing test**

```dart
test('the copy says subject, not part, and pluralizes one minute', () {
  expect(proctorCopyFor(20), '20 minutes left in this subject.');
  expect(proctorCopyFor(10), '10 minutes left in this subject.');
  expect(proctorCopyFor(5), '5 minutes left in this subject.');
  expect(proctorCopyFor(1), '1 minute left in this subject.');
});

testWidgets('it is not dismissible and carries no action or icon',
    (tester) async {
  await pumpToast(tester, minutes: 20);
  expect(find.byType(IconButton), findsNothing);
  expect(find.byType(TextButton), findsNothing);
  expect(find.byType(Icon), findsNothing);
});

testWidgets('the final call is amber', (tester) async {
  await pumpToast(tester, minutes: 1);
  final text = tester.widget<Text>(find.text('1 minute left in this subject.'));
  expect(text.style!.color, amberOf(tester));
});

testWidgets('every other call is ink', (tester) async {
  await pumpToast(tester, minutes: 5);
  final text = tester.widget<Text>(find.text('5 minutes left in this subject.'));
  expect(text.style!.color, isNot(amberOf(tester)));
});

testWidgets('it fires the haptic once per call', (tester) async {
  final calls = <MethodCall>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call);
      return null;
    },
  );
  await pumpToast(tester, minutes: 20);
  await tester.pump(const Duration(milliseconds: 200));
  expect(calls.length, 3);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/mock_exam/presentation/proctor_toast_test.dart
```

Expected: FAIL to compile.

- [ ] **Step 3: Write the toast**

```dart
String proctorCopyFor(int minutes) {
  final unit = minutes == 1 ? 'minute' : 'minutes';
  return '$minutes $unit left in this subject.';
}
```

The widget is the floating bar's sibling: 1px `rule` border, radius 8, `background` fill, the
same soft shadow, **10px clear above the bar**. Text centered, sans 13/600, one line, no wrap.
`amber` when `minutes == 1`, `ink` otherwise.

**The haptic is three medium impacts 60ms apart**, fired once when the toast appears:

```dart
Future<void> _proctorHaptic() async {
  for (var i = 0; i < 3; i++) {
    await HapticFeedback.mediumImpact();
    if (i < 2) await Future<void>.delayed(const Duration(milliseconds: 60));
  }
}
```

**A rhythm, deliberately not one long buzz.** With system haptics off this is a silent no-op, so
there is nothing to add to Settings and no permission to request.

In `mock_session_page.dart`, watch the remaining time and show the toast for **2.5 seconds**
when `callThresholdCrossed` returns non-null, then remove it. **Not dismissible, no close, no
action.**

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/mock_exam/presentation/proctor_toast_test.dart
```

Expected: PASS, all five.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(mock): a proctor that calls the time four times a part"
```

---

### Task 4: The section transition

**Files:**
- Create: `lib/features/mock_exam/presentation/part_transition_page.dart`
- Test: `test/features/mock_exam/presentation/part_transition_page_test.dart`

**Interfaces:**
- Consumes: nothing from Tasks 1 to 3.
- Produces: `class PartTransitionPage extends StatelessWidget` taking
  `{required String closedPartName, required int closedPartMinutes, required int answered, required int total, required int blank, required int flagged, required String nextPartName, required int nextPartQuestions, required int nextPartMinutes, required int closedPartNumber, required int nextPartNumber, required VoidCallback onStartNext}`.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('the figure and its label share one line', (tester) async {
  await pumpTransition(tester);
  expect(find.text('28'), findsOneWidget);
  expect(find.text('of 30 answered'), findsOneWidget);
});

testWidgets('blank and flagged are one quiet line, not two rows',
    (tester) async {
  await pumpTransition(tester);
  expect(find.textContaining('2 left blank'), findsOneWidget);
  expect(find.textContaining('3 you flagged'), findsOneWidget);
});

testWidgets('it states the closure plainly', (tester) async {
  await pumpTransition(tester);
  expect(
    find.text('Part 1 is closed. You cannot go back to it.'),
    findsOneWidget,
  );
});

testWidgets('there is no clock, no bar, no back arrow', (tester) async {
  await pumpTransition(tester);
  expect(find.byType(AppBar), findsNothing);
  expect(find.byType(BackButton), findsNothing);
});

testWidgets('nothing on it is a score', (tester) async {
  await pumpTransition(tester);
  for (final word in ['correct', 'wrong', 'score', '%']) {
    expect(find.textContaining(word), findsNothing, reason: word);
  }
});

testWidgets('the button starts the next part', (tester) async {
  var started = 0;
  await pumpTransition(tester, onStartNext: () => started++);
  await tester.tap(find.text('Start Part 2'));
  await tester.pump();
  expect(started, 1);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/mock_exam/presentation/part_transition_page_test.dart
```

Expected: FAIL to compile.

- [ ] **Step 3: Build the page**

Compose in the order Section 7.2 fixes. Heading serif 24/700, `Time is up for Part 1.` Then the
part name and its length at sans 13/400 `inkMuted`.

Plate `What you did`, then the figure at serif 30/700 **on the same baseline** as
`of 30 answered` at serif 14/400 `inkMuted`. **Do not stack them:** the label under the numeral
leaves a hole, which is the fault this composition was rebuilt to fix.

Then one quiet line, sans 13/400 `inkMuted`, blank and flagged separated by a middot. **Not two
ruled rows.** They are footnotes to the figure.

Then the closure sentence at sans 13 `ink` w600. Then plate `Next` with the next part's name,
question count and minutes. Then the board button, then one line of fine print.

**No app bar, no clock, no floating bar, no back arrow.** System back does nothing here.

**No rust and no amber.**

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/mock_exam/presentation/part_transition_page_test.dart
```

Expected: PASS, all six.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(mock): the screen where a part closes for good"
```

---

### Task 5: The pause screen, and strict mode forbidding it

**Files:**
- Create: `lib/features/mock_exam/presentation/pause_page.dart`
- Modify: `lib/features/mock_exam/presentation/mock_session_page.dart`
- Modify: `lib/features/mock_exam/application/mock_session_controller.dart`
- Test: `test/features/mock_exam/presentation/pause_page_test.dart`

**Interfaces:**
- Consumes: the strict mode setting, and the controller's elapsed time.
- Produces: `class PausePage extends StatelessWidget` taking
  `{required String partName, required Duration remaining, required int answered, required int total, required int flagged, required VoidCallback onResume, required VoidCallback onDiscard}`, and a
  `pauseWarningSeen` flag on the attempt so the warning fires once per paper.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('the paper is not visible while paused', (tester) async {
  await pumpPaused(tester);
  expect(find.textContaining('ratio of boys to girls'), findsNothing);
  expect(find.byType(AnswerRow), findsNothing);
});

testWidgets('it shows time left, not time elapsed', (tester) async {
  await pumpPaused(tester, remaining: const Duration(minutes: 21, seconds: 47));
  expect(find.text('21:47'), findsOneWidget);
  expect(find.text('in this part'), findsOneWidget);
});

testWidgets('resume is the only green thing and discard is rust text',
    (tester) async {
  await pumpPaused(tester);
  expect(find.byType(BoardButton), findsOneWidget);
  final discard = tester.widget<Text>(find.text('Discard this paper'));
  expect(discard.style!.color, rustOf(tester));
});

testWidgets('the warning fires on the first pause only', (tester) async {
  await pumpSession(tester, pauseWarningSeen: false);
  await tester.tap(find.byKey(const Key('mock-pause')));
  await tester.pumpAndSettle();
  expect(find.text('Real exams do not pause.'), findsOneWidget);

  await tester.tap(find.text('Pause'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Resume'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('mock-pause')));
  await tester.pumpAndSettle();
  expect(find.text('Real exams do not pause.'), findsNothing);
});

testWidgets('strict mode has no pause control at all', (tester) async {
  await pumpSession(tester, strictMode: true);
  expect(find.byKey(const Key('mock-pause')), findsNothing);
});

testWidgets('discard takes a rust confirm and does not use up a mock',
    (tester) async {
  await pumpPaused(tester);
  await tester.tap(find.text('Discard this paper'));
  await tester.pumpAndSettle();
  expect(find.text('Discard this paper?'), findsOneWidget);
  expect(find.textContaining('does not use up a mock'), findsOneWidget);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/mock_exam/presentation/pause_page_test.dart
```

Expected: FAIL to compile.

- [ ] **Step 3: Add the pause control and build the screen**

**The control goes at the trailing edge of the app bar**, a 46px target, keyed `mock-pause`.
**It is not built at all when strict mode is on.** The clock stays centered regardless.

The page itself: no app bar, no clock widget, no floating bar. Heading `Paused.` at serif
24/700, the part name beneath. Plate `Time left`, then the remaining time at serif 30/700
**tabular** on one baseline with `in this part` at serif 14/400 `inkMuted`. Then the quiet
answered and flagged line. Then `The clock is stopped. It starts again when you resume.`

Footer: the board button `Resume`, then `Discard this paper` as **rust text with no fill**.

**Pausing must stop the clock in the controller**, and resuming restarts it. **Elapsed time
does not advance while paused.**

**The warning uses the shared confirmation dialog**, `isDestructive: false` so the confirm is
green, with `Keep going` and `Pause`. Set `pauseWarningSeen` when it is answered either way.

**Discard uses the same dialog with `isDestructive: true`**, so the confirm is rust.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/mock_exam/presentation/pause_page_test.dart
```

Expected: PASS, all six.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(mock): pausing hides the paper, and strict mode removes it"
```

---

### Task 6: Ending a part early, and the strict line in the paper

**Files:**
- Modify: `lib/features/mock_exam/presentation/mock_session_page.dart`
- Modify: `lib/features/mock_exam/application/mock_session_controller.dart`
- Test: `test/features/mock_exam/presentation/end_part_early_test.dart`

**Interfaces:**
- Consumes: `PartTransitionPage` from Task 4, the strict setting from Task 5.
- Produces: `endPartEarly()` on the controller, which closes the current part and forfeits its
  remaining time.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('with strict off, next on the last item offers to end the part',
    (tester) async {
  await pumpSession(tester, strictMode: false, atLastItemOfPart: true);
  await tester.tap(find.byKey(const Key('mock-next')));
  await tester.pumpAndSettle();
  expect(find.text('End Part 1 now?'), findsOneWidget);
  expect(find.textContaining('does not carry over'), findsOneWidget);
});

testWidgets('with strict on, next is disabled and the reason is shown',
    (tester) async {
  await pumpSession(tester, strictMode: true, atLastItemOfPart: true);
  expect(
    find.text('Part 1 runs to the end of its time. Strict mock mode is on.'),
    findsOneWidget,
  );
  final next = tester.widget<IconButton>(find.byKey(const Key('mock-next')));
  expect(next.onPressed, isNull);
});

testWidgets('the strict line appears only on the last item of a part',
    (tester) async {
  await pumpSession(tester, strictMode: true, atLastItemOfPart: false);
  expect(find.textContaining('runs to the end of its time'), findsNothing);
});

test('ending early forfeits the remaining time and never banks it', () {
  final controller = mockController(
    partLength: const Duration(minutes: 30),
    elapsedInPart: const Duration(minutes: 22),
  );
  controller.endPartEarly();
  expect(controller.state.currentPartIndex, 1);
  expect(controller.state.elapsedInPart, Duration.zero);
  expect(controller.state.bankedTime, isNull);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/mock_exam/presentation/end_part_early_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Wire it**

**With strict off**, `next` at the last item of a part opens the confirmation. **It uses the
shared dialog with `isDestructive: true`, so the confirm is rust**: it destroys the remaining
time and closes the part for good.

> **End Part 1 now?**
> You have 8 minutes left and 2 questions blank.
> Ending now closes Part 1 for good. The time you have left does not carry over.

**With strict on**, `next` is disabled at that item and the strict line renders above the
floating bar, sans 11.5/400 `inkMuted`, centered. **Only on the last item of a part.**

`endPartEarly()` advances the part index and **discards the remaining time. There is no banking
of any kind:** carrying it forward would make ending early strictly advantageous, which no real
paper allows.

Both routes land on `PartTransitionPage`.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/mock_exam/presentation/end_part_early_test.dart
```

Expected: PASS, all four.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(mock): a part can end early, unless the student asked it not to"
```

---

## What this plan deliberately does not do

- **It does not build mock history.** That surface is struck: Progress's record screen already
  carries a "Your mocks" panel.
- **It does not touch the results or review screens.** Mock 02 owns those, and the forfeit
  ending there is already designed.
- **It does not add the missing type tokens**, which belong to the kit.
- **It does not write the three new blueprints.** ACET, DCAT and MSU-SASE timings are now in
  Section 2 of the spec, and turning them into content is Mock 01 Task 1's job.

## Verification for the whole plan

```bash
grep -rniE "radio|Radio" lib/features/mock_exam
```

Expected: **nothing.** The answer device is a serif letter and a tinted row.

```bash
grep -rn "in this part" lib/features/mock_exam/presentation/proctor_toast.dart
```

Expected: **nothing.** The proctor says "subject"; everything else says "part".

- The pause control does not exist in the widget tree when strict mode is on.
- No file in this plan reads a correct answer. The transition and pause screens cannot show a
  score because they never have one.
- Amber appears exactly twice: the clock rule under one minute, and the proctor's final call.
- Every dialog puts both actions in one row. Discard and end-part-early confirm in rust; the
  pause warning confirms in green.
- The haptic fires three times per call and never on a tick that crossed no threshold.
- `schemaVersion` is unchanged.
