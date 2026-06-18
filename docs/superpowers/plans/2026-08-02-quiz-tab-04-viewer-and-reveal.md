# Quiz Tab, Plan 4 of 6: The Quiz Viewer and the Answer Reveal

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the screen a session runs in: its bar, rail, question grid and leave
dialog, the graded reveal after a commit, the marginal notes, and the flag.

**Architecture:** Two new components in `lib/core/ui/components/` because the mock uses both,
a rewrite of `QuestionCard` to render graded states through the shared renderer, and a
rewrite of `quiz_page.dart`'s chrome. No new storage: `QuizSession` already holds everything
going back needs.

**Tech Stack:** Flutter, Riverpod, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-quiz-tab-design.md` Section 7.5 (the
viewer), Section 3 (the reveal), Section 6 (the flag's mark, control and motion) and
Section 8 (motion).

**Decision log:** `docs/superpowers/decisions/2026-07-28-quiz-tab-decision-log.md`. The
pennant's shape, its motion and the grid's treatment were all decided against drawn
alternatives; the rejected ones are recorded there and must not be reintroduced.

**Depends on:** Plan 1 (merged: the flags table and the nullable `rationale` field) and
Plan 3, whose sessions this screen runs.

---

## What is broken today

1. **`QuestionCard` renders the stem with a plain `Text`.** Stems carry LaTeX and markdown,
   so `$F_{net} = ma$` shows literally. This is UI-005, UI-006 and UI-007 in the audit log,
   and `PortableTextRenderer` already exists to fix it.
2. **`QuestionCard` passes `AnswerRowState.plain` to every row, every time.** `AnswerRow`
   implements `selected`, `correct`, `incorrect` and `correctMissed` under a docstring
   calling it the spec's answer device, and none of them has ever been used.
3. **There is no reveal.** A tap submits and the page advances. The explanation the content
   pipeline authors is never shown during a session.
4. **`AttemptItem.chosenChoiceId` is stored, synced and consumed by nothing.** The reveal is
   its first reader.

## The content this plan degrades around

**Note B needs a rationale per choice, and no choice has one.** Plan 1 added the nullable
field; the generation pass in Section 9 has not run. **Note B renders when a rationale
exists and is silently absent when it does not**, on both tiers. That is not a compromise:
Section 3 already says Free sees no trace of the missing note, "no locked block, no upgrade
line, no shadow", so absence is the specified appearance. Pro simply gets the note as the
content lands.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** `AnswerRow`,
  `QuestionCard`, `QuizProgressBar`, `PortableTextRenderer`, `ConfirmationDialog` and
  `ProgressRule` all exist and all are relevant here.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, **no coloured left-border panels**, no blur, no shimmer. The
  left-border panel was drawn for the Pro note and rejected on sight as the visual signature
  of generated output; marginal notes replaced it.
- **Colour carries meaning.** Board is right, rust is wrong, amber is answered-without-
  judgment. Nothing else earns them.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. The verdict words are
  **"Correct"** and **"Not this one"**, exactly.
- **Motion.** 400ms on `cubic-bezier(.22, 1, .36, 1)` is the settled constant. Outgoing
  marks do not animate. Everything here is disabled under reduce-motion.
- **Layering.** R1, R2, R3. **The baseline is 7 violations.** Do not add an eighth.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/ui/components/pennant_mark.dart` — the flag glyph, both weights, with its fill.
  In `core/ui/` because the viewer, the grid, the review component and the mock all draw it.
- `lib/core/ui/components/question_grid_sheet.dart` — the navigator. Also shared with the
  mock, which needs six columns to the quiz's five.
- `lib/core/ui/components/answer_reveal.dart` — the verdict line and the marginal notes.
  **In `core/ui/` and not in `features/quiz/`**, because Plan 6's review component draws the
  same notes and the mock reaches that component. A widget in `features/quiz` could not be
  read from `features/mock_exam` without an eighth layering violation. This is why it takes
  primitives rather than an `AnswerOutcome`: `AnswerOutcome` lives in `features/quiz/domain`
  and `core/**` may not import `features/**`.
- Tests mirroring each.

**Modify:**
- `lib/core/ui/components/question_card.dart` — the renderer, and the graded states.
- `lib/features/quiz/presentation/quiz_page.dart` — the whole chrome.
- `lib/features/quiz/presentation/quiz_controller.dart` — going back, and the flag.
- `lib/core/storage/storage.dart` — export `questionFlagsRepositoryProvider` if it is
  missing.

**Not touched:** the debrief, which is Plan 5 and still shows
`DoneForTodayCelebration` at the end of this plan. The review component, Plan 6.

---

## Task 1: The pennant

**Files:**
- Create: `lib/core/ui/components/pennant_mark.dart`
- Test: `test/core/ui/components/pennant_mark_test.dart`

**Interfaces:**
- Produces: `PennantMark({required bool isSet, double size, Color? color, bool animate})`.
  Tasks 4 and 7 use it, and Plans 2c and 6 draw it too.

**From the spec, Section 6:** a triangular flag notched at the fly, on a staff. Drawn in a
**24 viewBox**, rendered at **21px**, stroke **1.5**, round caps and joins.

- Staff, always stroked: `M6 3.2v17.6`
- Pennant: `M6 4.4h12.2L14 9l4.2 4.6H6`
- **Unset:** both stroked in `inkMuted`.
- **Set:** the staff stays stroked, the pennant fills solid in `ink`.

**Motion:** the fill sweeps from the staff outward, left to right, over **400ms** on
`cubic-bezier(.22, 1, .36, 1)`. **Unsetting drains instantly**, matching the rule that an
outgoing mark does not animate.

**Two weights, decided by whether it can be pressed.** In the bar it is a control and takes
full `ink` when set. In a grid cell it is a record and takes `inkMuted`, so it does not
compete with the numbers being scanned. Same glyph. That is what `color` is for.

**It is not a ribbon and not board green.** The ribbon is Study's lesson bookmark and its
paths are fixed by the 27 July spec. Board is spent on the primary action, progress and done
checks.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/pennant_mark_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('an unset pennant paints', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: false));

    expect(find.byType(PennantMark), findsOneWidget);
    expect(tester.getSize(find.byType(CustomPaint).first).width, 21);
  });

  testWidgets('a set pennant paints at the same size', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: true));

    expect(tester.getSize(find.byType(CustomPaint).first).width, 21);
  });

  testWidgets('the size is settable for a grid cell', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: true, size: 12));

    expect(tester.getSize(find.byType(CustomPaint).first).width, 12);
  });

  testWidgets('setting animates and unsetting does not', (tester) async {
    await tester.pumpApp(const PennantMark(isSet: false));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PennantMark(isSet: true))),
    );

    await tester.pump(const Duration(milliseconds: 100));
    // Mid-sweep: the fill is partial, so a frame is still scheduled.
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PennantMark(isSet: false))),
    );
    await tester.pump();
    // Draining is instant: nothing is scheduled after the first frame.
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
```

Match the theme wrapper `pump_app.dart` provides; the second and third pumps above use a
bare `MaterialApp` and will need the same `extensions` if `PennantMark` reads
`context.colors`. Give `color` a default of null meaning "read the theme", and pass an
explicit colour in those two pumps to keep them simple.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/ui/components/pennant_mark_test.dart`
Expected: FAIL. `pennant_mark.dart` does not exist.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/pennant_mark.dart` as an `ImplicitlyAnimatedWidget` or a
`StatefulWidget` driving an `AnimationController`, painting through a `CustomPainter`.

The painter takes the two paths scaled from the 24 viewBox to `size`:

```dart
/// Staff and pennant, in the 24 viewBox the spec fixes them in.
///
/// Scaled rather than redrawn per size: the two paths are the identity, and
/// the mark appears at 21px in a bar and 12px in a grid cell.
Path _staffPath(double scale) => Path()
  ..moveTo(6 * scale, 3.2 * scale)
  ..relativeLineTo(0, 17.6 * scale);

Path _pennantPath(double scale) => Path()
  ..moveTo(6 * scale, 4.4 * scale)
  ..relativeLineTo(12.2 * scale, 0)
  ..lineTo(14 * scale, 9 * scale)
  ..lineTo(18.2 * scale, 13.6 * scale)
  ..lineTo(6 * scale, 13.6 * scale)
  ..close();
```

Verify the pennant path against the spec string `M6 4.4h12.2L14 9l4.2 4.6H6`: the `l4.2 4.6`
is **relative** from `L14 9`, so it lands at `18.2, 13.6`. The Dart above spells that out
absolutely rather than mixing conventions; check the shape on screen before committing.

The paint:

```dart
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
```

**The fill sweeps from the staff outward** by clipping the filled pennant to a rectangle
that grows left to right with the animation value:

```dart
    if (fillProgress > 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(0, 0, size.width * fillProgress, size.height),
      );
      canvas.drawPath(
        _pennantPath(scale),
        Paint()..style = PaintingStyle.fill..color = color,
      );
      canvas.restore();
    }
    canvas.drawPath(_staffPath(scale), stroke);
    canvas.drawPath(_pennantPath(scale), stroke);
```

The controller:

```dart
  static const _sweep = Duration(milliseconds: 400);
  static const _curve = Cubic(0.22, 1, 0.36, 1);
```

```dart
  void _sync() {
    if (!widget.isSet) {
      // An outgoing mark does not animate.
      _controller.value = 0;
      return;
    }
    if (widget.animate && !_reduceMotion) {
      _controller.animateTo(1, duration: _sweep, curve: _curve);
    } else {
      _controller.value = 1;
    }
  }
```

Read reduce-motion with `MediaQuery.disableAnimationsOf(context)`.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/ui/components/pennant_mark_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/ui/components/pennant_mark.dart \
        test/core/ui/components/pennant_mark_test.dart
git commit -m "feat(ui): the pennant

A staff with a shape hanging off one edge, so it cannot be confused with
Study's bookmark ribbon, which is a rectangle with a notch cut from its
bottom. The fill unfurls from the staff and drains instantly, because an
outgoing mark does not animate."
```

---

## Task 2: `QuestionCard` renders properly and grades

**Files:**
- Modify: `lib/core/ui/components/question_card.dart`
- Test: `test/core/ui/components/question_card_test.dart` (create if absent)

**Interfaces:**
- Consumes: `PortableTextRenderer`, `AnswerRow` with its four graded states.
- Produces:

```dart
QuestionCard({
  required Question question,
  required void Function(String chosenChoiceId) onAnswer,
  ChoiceId? chosenChoiceId,   // null while unanswered
  bool revealed = false,
})
```

**From the spec, Section 3, "The mark":**

- The chosen row, when right: board ✓ in the letter column, text w600.
- The chosen row, when wrong: rust ✕, text in `rust`.
- The correct row, when missed: board ✓, text w600.
- **Every other row drops to 50% opacity.**

`AnswerRow` already implements all four states. **Use the states that exist.**

**And the stem stops rendering literally.** `PortableTextRenderer` is in the kit and this is
its second caller. UI-005, UI-006 and UI-007 close here.

**Rows are inert once revealed.** The attempt row and the FSRS update were written the
instant the choice was tapped, so re-answering is not a thing the storage can express.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('an unanswered card offers every choice plainly',
      (tester) async {
    // Pump QuestionCard with revealed: false.

    final rows = tester.widgetList<AnswerRow>(find.byType(AnswerRow));
    expect(rows.every((row) => row.state == AnswerRowState.plain), isTrue);
    expect(rows.every((row) => row.onTap != null), isTrue);
  });

  testWidgets('a right answer marks the chosen row correct', (tester) async {
    // Pump revealed: true, chosenChoiceId equal to the correct choice.

    final chosen = tester.widget<AnswerRow>(
      find.widgetWithText(AnswerRow, 'the right one'),
    );
    expect(chosen.state, AnswerRowState.correct);
  });

  testWidgets('a wrong answer marks both rows', (tester) async {
    // Pump revealed: true, chosenChoiceId equal to a wrong choice.

    expect(
      tester.widget<AnswerRow>(find.widgetWithText(AnswerRow, 'the wrong one'))
          .state,
      AnswerRowState.incorrect,
    );
    expect(
      tester.widget<AnswerRow>(find.widgetWithText(AnswerRow, 'the right one'))
          .state,
      AnswerRowState.correctMissed,
    );
  });

  testWidgets('revealed rows cannot be answered again', (tester) async {
    // Pump revealed: true.

    final rows = tester.widgetList<AnswerRow>(find.byType(AnswerRow));
    expect(rows.every((row) => row.onTap == null), isTrue);
  });

  testWidgets('the stem renders through the shared renderer', (tester) async {
    // Pump a question whose stem is r'What is $F_{net} = ma$?'.

    expect(find.byType(PortableTextRenderer), findsOneWidget);
    expect(find.text(r'What is $F_{net} = ma$?'), findsNothing);
  });
```

Write these bodies in full. Build the `Question` inline with three choices labelled so the
finders above work.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/ui/components/question_card_test.dart`
Expected: FAIL. `QuestionCard` has no `revealed` parameter and uses a plain `Text`.

- [ ] **Step 3: Rewrite the card**

```dart
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.question,
    required this.onAnswer,
    this.chosenChoiceId,
    this.revealed = false,
    super.key,
  });

  final Question question;
  final void Function(String chosenChoiceId) onAnswer;

  /// Null while the question is unanswered.
  final ChoiceId? chosenChoiceId;

  /// Once revealed the rows are a record. The attempt row and the FSRS update
  /// were written the instant the choice was tapped, so there is nothing an
  /// edit could mean.
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stems carry LaTeX and markdown. A plain Text renders them
        // literally, which is UI-005 through UI-007.
        PortableTextRenderer(text: question.stem),
        const SizedBox(height: 20),
        for (final choice in question.choices)
          Opacity(
            opacity: _dimmed(choice) ? 0.5 : 1,
            child: AnswerRow(
              letter: choice.label,
              text: choice.text,
              state: _stateFor(choice),
              onTap: revealed ? null : () => onAnswer(choice.id),
            ),
          ),
      ],
    );
  }

  AnswerRowState _stateFor(Choice choice) {
    if (!revealed) {
      return choice.id == chosenChoiceId
          ? AnswerRowState.selected
          : AnswerRowState.plain;
    }
    if (choice.id == chosenChoiceId) {
      return choice.isCorrect
          ? AnswerRowState.correct
          : AnswerRowState.incorrect;
    }
    if (choice.isCorrect) return AnswerRowState.correctMissed;
    return AnswerRowState.plain;
  }

  /// Every row that is neither the pick nor the answer recedes.
  bool _dimmed(Choice choice) =>
      revealed && choice.id != chosenChoiceId && !choice.isCorrect;
}
```

Check `PortableTextRenderer`'s real constructor before using it:
`grep -n "PortableTextRenderer({" -A 10 lib/core/ui/components/portable_text_renderer.dart`.
If it takes `List<Map<String, dynamic>>` rather than a `String`, the stem may need wrapping;
**say so rather than falling back to `Text`**, because falling back is the defect.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/core/ui/ test/features/quiz/`
Expected: PASS. Existing `quiz_page` tests that assert on a plain stem will need updating.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/ui test/core/ui
git commit -m "fix(ui): the question card grades, and stops printing LaTeX

AnswerRow has implemented correct, incorrect and correctMissed since the
redesign under a docstring calling it the spec's answer device, and the
card passed plain every time. The stem also went through a plain Text, so
\$F_{net} = ma\$ rendered as itself."
```

---

## Task 3: The reveal

**Files:**
- Create: `lib/core/ui/components/answer_reveal.dart`
- Test: `test/core/ui/components/answer_reveal_test.dart`

**Interfaces:**
- Consumes: `Question`, `PortableTextRenderer`. **Not `AnswerOutcome`**: that type lives in
  `features/quiz/domain` and R1 forbids `core/**` from importing `features/**`.
- Produces:

```dart
AnswerReveal({
  required Question question,
  required ChoiceId chosenChoiceId,
  required bool proIsActive,
  int? nextReviewIntervalDays,   // null in the review, where nothing was just scheduled
})
```

**Why here and not in `features/quiz`.** Plan 6's review component draws these same notes,
and the mock reaches that component. A widget under `features/quiz` could not be read from
`features/mock_exam` without an eighth layering violation. Callers in `features/quiz` pass
`outcome.chosenChoiceId` and `outcome.nextReviewIntervalDays`; the widget derives
correctness from the question itself.

**The verdict line is omitted when `nextReviewIntervalDays` is null.** In the review nothing
has just been scheduled, so there is no interval to state and no fresh verdict to deliver:
the marks on the choices already say what happened.

**From the spec, Section 3, "The verdict line":** opened by a 1px `rule`, 14px above.
**"Correct"** or **"Not this one"** in serif 17/700, board or rust. Right-aligned on the same
baseline, the next interval in 11.5 `inkMuted`: "back in 9 days", "back tomorrow".

**"The notes":** the explanation set as marginal notes, lettered in the same 22px gutter the
answer rows use, so the note for B lines up under B.

- Each note opens with a 1px `ruleFaint` and 12px padding.
- The letter in serif 15/700 `inkMuted`.
- The kicker in 11.5 `inkMuted`, lowercase: **"the answer"**, **"what you picked"**.
- The body in `bodySmall` at 13.5, line height 1.6.
- Note **A** always renders. Note **B** renders only on a miss, and only for Pro.

**Free sees the mark, the verdict and note A, and nothing about Pro.** No locked block, no
upgrade line, no shadow of the missing note. A student has just been wrong, and an offer at
that moment reads as the app charging for the thing that would have helped.

**The rejected treatment must not come back.** Note B was first drawn as a tinted panel with
a coloured left border and a coloured label. That is the visual signature of generated output
and it was rejected on sight.

**The letters are the real choice labels.** Note A is lettered with the correct choice's
label and note B with the chosen one's, which is what makes them line up under the rows
above.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('a correct answer says so with its interval', (tester) async {
    // outcome: chosen == correct, nextReviewIntervalDays: 9.

    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('back in 9 days'), findsOneWidget);
  });

  testWidgets('one day reads as tomorrow', (tester) async {
    // nextReviewIntervalDays: 1.

    expect(find.text('back tomorrow'), findsOneWidget);
  });

  testWidgets('a miss says Not this one', (tester) async {
    expect(find.text('Not this one'), findsOneWidget);
  });

  testWidgets('note A always renders, lettered for the answer',
      (tester) async {
    // A correct answer, explanation 'Only coefficients may be changed.'

    expect(find.text('the answer'), findsOneWidget);
    expect(find.text('Only coefficients may be changed.'), findsOneWidget);
  });

  testWidgets('note B renders for Pro on a miss', (tester) async {
    // A miss, the chosen choice carrying a rationale, proIsActive: true.

    expect(find.text('what you picked'), findsOneWidget);
  });

  testWidgets('note B is absent for Free, with nothing in its place',
      (tester) async {
    // The same miss, proIsActive: false.

    expect(find.text('what you picked'), findsNothing);
    expect(find.textContaining('Pro'), findsNothing);
    expect(find.textContaining('Upgrade'), findsNothing);
  });

  testWidgets('note B is absent on a correct answer', (tester) async {
    // A correct answer, proIsActive: true, rationale present.

    expect(find.text('what you picked'), findsNothing);
  });

  testWidgets('note B is absent when the content has no rationale',
      (tester) async {
    // A miss, proIsActive: true, the chosen choice's rationale null.

    expect(find.text('what you picked'), findsNothing);
  });
```

Write the bodies in full. Check whether `Choice` already carries `rationale`:
`grep -n "rationale" lib/core/storage/domain/choice.dart`. **Plan 1 added it as a nullable
field; if it is on `Question` rather than `Choice`, adapt and say so.**

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/widgets/answer_reveal_test.dart`
Expected: FAIL. `answer_reveal.dart` does not exist.

- [ ] **Step 3: Write the reveal**

```dart
/// What appears under the choices the moment a student commits.
class AnswerReveal extends StatelessWidget {
  const AnswerReveal({
    required this.question,
    required this.outcome,
    required this.proIsActive,
    super.key,
  });

  final Question question;
  final AnswerOutcome outcome;
  final bool proIsActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final correct = outcome.isCorrect;
    final chosen = _choiceById(outcome.chosenChoiceId);
    final answer = question.correctChoice;
    final rationale = chosen?.rationale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.rule, width: AppDimensions.hairline),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  correct ? 'Correct' : 'Not this one',
                  style: styles.displaySmall.copyWith(
                    fontSize: 17,
                    color: correct ? colors.board : colors.rust,
                  ),
                ),
              ),
              Text(
                intervalLabel(outcome.nextReviewIntervalDays),
                style: styles.bodySmall
                    .copyWith(fontSize: 11.5, color: colors.inkMuted),
              ),
            ],
          ),
        ),
        _MarginalNote(
          letter: answer.label,
          kicker: 'the answer',
          body: question.explanation,
        ),
        // Only on a miss, only for Pro, and only where the content pass has
        // written a rationale. Free sees nothing in its place: a student has
        // just been wrong, and an offer at that moment reads as the app
        // charging for the thing that would have helped.
        if (!correct && proIsActive && rationale != null && chosen != null)
          _MarginalNote(
            letter: chosen.label,
            kicker: 'what you picked',
            body: rationale,
          ),
      ],
    );
  }

  Choice? _choiceById(ChoiceId id) =>
      question.choices.where((choice) => choice.id == id).firstOrNull;
}

/// "back in 9 days", "back tomorrow".
@visibleForTesting
String intervalLabel(int days) =>
    days <= 1 ? 'back tomorrow' : 'back in $days days';

/// A note in the 22px gutter the answer rows already use, so the note for B
/// lines up under B.
///
/// This replaces a tinted panel with a coloured left border and a coloured
/// label, which was rejected on sight as the visual signature of generated
/// output. A marginal note is a print device, it reuses a grid already on the
/// screen, and it needs no new colour.
class _MarginalNote extends StatelessWidget {
  const _MarginalNote({
    required this.letter,
    required this.kicker,
    required this.body,
  });

  final String letter;
  final String kicker;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.ruleFaint, width: AppDimensions.hairline),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              letter,
              style: styles.headlineSmall.copyWith(color: colors.inkMuted),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker,
                  style: styles.bodySmall
                      .copyWith(fontSize: 11.5, color: colors.inkMuted),
                ),
                const SizedBox(height: 4),
                // Explanations carry the same markup stems do.
                PortableTextRenderer(text: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

The spec sets the note body at `bodySmall` 13.5 with line height 1.6. If
`PortableTextRenderer` does not take a style, add an optional `style` parameter to it rather
than wrapping it in a `DefaultTextStyle` that its internals may ignore.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/quiz/presentation/widgets/answer_reveal_test.dart`
Expected: PASS, 8 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "feat(quiz): the answer reveal

Marginal notes lettered in the answer rows' own gutter, so the note for B
sits under B. The first draft was a tinted panel with a coloured left
border, which is what generated output looks like."
```

---

## Task 4: The flag control

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Create: `lib/features/quiz/presentation/question_flag_providers.dart`
- Test: `test/features/quiz/presentation/question_flag_providers_test.dart`

**Interfaces:**
- Consumes: `QuestionFlagsRepository`, which exists and has `flag`, `unflag`, `isFlagged`,
  `flaggedIds`.
- Produces: `flaggedIdsProvider`, a `FutureProvider<Set<QuestionId>>`, and
  `QuestionFlagController` with `toggle(QuestionId)`. Tasks 5 and 7 read them, and Plan 6
  reuses them.

**From the spec, Section 6, "The control":** in the app bar of the quiz viewer, in the
trailing slot, **outermost**. Available **before and after answering**, and identically
inside a mock. **Flagging never submits and never advances**, which is why the control is not
on the choices themselves.

**On first use, a toast names what happened:** "Flagged. Find it in the Quiz tab.", with an
Undo. Removing a flag toasts "Flag removed".

**"First use" is per install, not per session.** Store it beside the other one-shot
preferences; check `AppPreferencesRepository` for the existing pattern before adding a key.

- [ ] **Step 1: Write the failing test**

```dart
  test('flagging a question stores it', () async {
    await container.read(questionFlagControllerProvider.notifier)
        .toggle('q_1');

    expect(await container.read(flaggedIdsProvider.future), contains('q_1'));
  });

  test('flagging twice removes it', () async {
    final controller =
        container.read(questionFlagControllerProvider.notifier);
    await controller.toggle('q_1');
    await controller.toggle('q_1');

    expect(await container.read(flaggedIdsProvider.future), isEmpty);
  });

  test('the first flag is announced once', () async {
    final controller =
        container.read(questionFlagControllerProvider.notifier);

    expect(await controller.toggle('q_1'), FlagToggle.firstFlagged);
    expect(await controller.toggle('q_2'), FlagToggle.flagged);
    expect(await controller.toggle('q_2'), FlagToggle.unflagged);
  });
```

Write the bodies in full over an in-memory database, following
`test/features/quiz/presentation/practice_row_providers_test.dart` from Plan 3.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/question_flag_providers_test.dart`
Expected: FAIL. Nothing is defined.

- [ ] **Step 3: Write the providers**

```dart
/// What just happened, so the caller knows which toast to raise.
enum FlagToggle { firstFlagged, flagged, unflagged }

final flaggedIdsProvider = FutureProvider<Set<QuestionId>>(
  (ref) => ref.watch(questionFlagsRepositoryProvider).flaggedIds(),
);

final questionFlagControllerProvider =
    NotifierProvider<QuestionFlagController, void>(QuestionFlagController.new);

class QuestionFlagController extends Notifier<void> {
  @override
  void build() {}

  /// Never submits and never advances. It writes one row and nothing else,
  /// which is the reason the control is in the bar rather than on a choice.
  Future<FlagToggle> toggle(QuestionId questionId) async {
    final repo = ref.read(questionFlagsRepositoryProvider);
    final wasFlagged = await repo.isFlagged(questionId);

    if (wasFlagged) {
      await repo.unflag(questionId);
      ref.invalidate(flaggedIdsProvider);
      return FlagToggle.unflagged;
    }

    await repo.flag(questionId);
    ref.invalidate(flaggedIdsProvider);

    final announced = await _announcedBefore();
    if (announced) return FlagToggle.flagged;
    await _markAnnounced();
    return FlagToggle.firstFlagged;
  }
  ...
}
```

Read `AppPreferencesRepository` and use its existing key/value shape for
`_announcedBefore` and `_markAnnounced`. Do not add a table.

Check `questionFlagsRepositoryProvider` exists and is exported from
`core/storage/storage.dart`; Plan 2c may already have added it. If both plans add it, keep
one.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/quiz/presentation/question_flag_providers_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(quiz): flags can be set and cleared

The control writes one row and does nothing else: it never submits and
never advances, which is why it lives in the bar and not on a choice."
```

---

## Task 5: The viewer's bar and rail

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Test: `test/features/quiz/presentation/quiz_page_chrome_test.dart` (create)

**Interfaces:**
- Consumes: `PennantMark` (Task 1), the flag providers (Task 4).
- Produces: nothing new. Tasks 6, 7 and 8 fill the rest of this screen.

**From the spec, Section 7.5, "The bar":** height 56, `background`. **Leading:** a ✕ at 17px,
stroke 1.6, `inkMuted`. **Trailing, in this order:** the counter, then the flag, **flag
outermost**. This is the reader's `[context] [mark]` rule with the counter in the context
slot, so the flag never moves.

The counter reads **"4 of 10"** in 12.5 `inkMuted`, tabular, with an 11px caret beside it,
and it is **tappable**. It opens the grid, which is Task 7; wire it to a callback here and
leave the callback empty with a comment naming Task 7.

**"The rail":** 3px, `ruleFaint` track, `board` fill, **one continuous fill** measuring
position in the session.

**Segments coloured by outcome were rejected.** A running score you cannot look away from
means three rust segments at question four is a reason to quit, and the debrief exists so
that judgment arrives after the work. It would also contradict the mock, where outcomes are
hidden until the end on purpose. **Do not colour the rail by outcome.**

`QuizProgressBar` exists. Check whether it already draws a continuous board fill on a
`ruleFaint` track at 3px; if it does, use it, and if it draws segments, **fix it rather than
adding a second progress component**.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the bar counts the position, not the score', (tester) async {
    // A session of 10, currentIndex 3.

    expect(find.text('4 of 10'), findsOneWidget);
  });

  testWidgets('the flag sits outermost', (tester) async {
    // Find the bar's trailing Row and assert the PennantMark is its last
    // child, after the counter.
  });

  testWidgets('the counter opens the grid', (tester) async {
    // Tap '4 of 10' and expect the grid callback to have fired.
  });

  testWidgets('the rail is one continuous fill', (tester) async {
    // Expect exactly one QuizProgressBar and no per-question segments.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/quiz_page_chrome_test.dart`
Expected: FAIL.

- [ ] **Step 3: Build the bar**

```dart
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: 17, color: colors.inkMuted),
          onPressed: _confirmLeave,   // Task 8
        ),
        actions: [
          // [context] [mark], the reader's rule. The counter takes the context
          // slot so the flag never moves as the number's width changes.
          InkWell(
            onTap: _openGrid,   // Task 7
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${session.currentIndex + 1} of ${session.questions.length}',
                    style: styles.bodySmall.copyWith(
                      fontSize: 12.5,
                      color: colors.inkMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 11, color: colors.inkMuted),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => unawaited(_toggleFlag(question.id)),
            icon: PennantMark(isSet: flagged.contains(question.id)),
          ),
        ],
      ),
```

`_toggleFlag` reads `questionFlagControllerProvider` and raises the toast the returned
`FlagToggle` calls for:

- `firstFlagged`: "Flagged. Find it in the Quiz tab." with an **Undo** action that toggles
  back.
- `flagged`: no toast. The mark on screen is the feedback.
- `unflagged`: "Flag removed".

Use the app's existing toast device. `post_answer_toast.dart` is in this folder already;
read it and reuse it rather than calling `ScaffoldMessenger` directly if it wraps one.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "feat(quiz): the viewer's bar and rail

The rail says how far and nothing else. Segments coloured by outcome were
drawn and cut: a running score you cannot look away from turns three rust
marks at question four into a reason to quit."
```

---

## Task 6: Going back, read-only

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_controller.dart`
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Test: `test/features/quiz/presentation/quiz_back_navigation_test.dart` (create)

**Interfaces:**
- Consumes: `QuizSession.questions`, `currentIndex`, `outcomes`.
- Produces: `QuizController.goTo(int index)`.

**From the spec, Section 7.5, "Going back":** permitted, and read-only. `QuizSession` already
holds `questions`, `currentIndex` and a growing `outcomes` list **in answer order**, so a
past question renders from `outcomes[i]` with no new storage and no resubmission.

**An answered question cannot be re-answered.** The attempt row and the FSRS update were
written the instant it was tapped. Revisiting redraws the reveal, the choices are inert, and
the footer offers a way forward rather than a way to edit.

**`outcomes` is in answer order and questions are in session order, and for a forward-only
session those coincide.** Once `goTo` exists they still do, because answering is only ever
possible at the first unanswered index. **Do not index `outcomes` by anything but position
until that stops being true**, and if you make it untrue, store the question id on the
outcome lookup instead. `AnswerOutcome` already carries `questionId`, so match on that: it
costs one lookup and it cannot go wrong.

- [ ] **Step 1: Write the failing test**

```dart
  test('going back does not lose the outcomes', () async {
    // Answer two of three, then goTo(0).

    final state = container.read(quizControllerProvider) as QuizRunning;
    expect(state.session.currentIndex, 0);
    expect(state.session.outcomes, hasLength(2));
  });

  test('answering is refused on a question already answered', () async {
    // Answer one, goTo(0), then answer again.

    expect(
      () => controller.answer(chosenChoiceId: 'c_b'),
      throwsA(isA<StateError>()),
    );
  });

  test('going forward returns to the unanswered question', () async {
    // Answer two of three, goTo(0), then goTo(2).

    expect(
      (container.read(quizControllerProvider) as QuizRunning)
          .session.currentIndex,
      2,
    );
  });

  test('goTo clamps to the session', () async {
    // goTo(-1) and goTo(99) on a session of 3.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/quiz_back_navigation_test.dart`
Expected: FAIL. `goTo` is not defined.

- [ ] **Step 3: Add `goTo` and guard `answer`**

In `QuizController`:

```dart
  /// Moves the viewer without touching what was recorded.
  ///
  /// Nothing is resubmitted and nothing is rescheduled: `outcomes` already
  /// holds every answer given, so a past question draws its reveal from the
  /// list rather than from storage.
  void goTo(int index) {
    final s = state;
    if (s is! QuizRunning) return;
    final clamped = index.clamp(0, s.session.questions.length - 1);
    state = QuizRunning(
      session: s.session.copyWith(currentIndex: clamped),
      questionShownAt: _ref.read(nowProvider)(),
      persisted: s.persisted,
    );
  }
```

and at the top of `answer`, after the existing `QuizRunning` check:

```dart
    if (outcomeFor(s.session, s.session.currentQuestion.id) != null) {
      throw StateError('answer() called on a question already answered');
    }
```

Add the lookup to `quiz_session.dart` as an extension or a method on `QuizSession`:

```dart
  /// The answer already given for [questionId], or null.
  ///
  /// Matched by id rather than by index: `outcomes` grows in answer order and
  /// `questions` is in session order, and the two only coincide while the
  /// session is forward-only.
  AnswerOutcome? outcomeFor(QuestionId questionId) =>
      outcomes.where((o) => o.questionId == questionId).firstOrNull;
```

**`record` still appends and increments**, which is correct: answering is only reachable at
an unanswered question, and after Task 6 the only unanswered question is the furthest one.
**Verify that**: if `goTo` can land on an unanswered question that is not the last, `record`
would advance to the wrong place. Guard it by having `goTo` allow any index but `answer`
throw on anything already answered, which the test above pins.

- [ ] **Step 4: Draw the past question**

In `quiz_page.dart`, the body renders from the outcome when one exists:

```dart
    final outcome = session.outcomeFor(question.id);

    QuestionCard(
      question: question,
      chosenChoiceId: outcome?.chosenChoiceId,
      revealed: outcome != null,
      onAnswer: (choiceId) =>
          unawaited(controller.answer(chosenChoiceId: choiceId)),
    ),
    if (outcome != null)
      AnswerReveal(
        question: question,
        outcome: outcome,
        proIsActive: proIsActive,
      ),
```

`proIsActive` comes into `QuizPage` from the router, which already reads
`entitlementProvider`, the same injection `ProgressPage` uses. Do not read the paywall
feature from inside `features/quiz`.

**The footer offers a way forward, not a way to edit.** On an answered question that is not
the last, a secondary "Next"; on the last answered question, the board "Done" that ends the
session.

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "feat(quiz): going back through a session

Read-only, and it needed no storage: the session already holds every
answer in order. An answered question cannot be answered again, because
the attempt row and the FSRS update were written when it was tapped."
```

---

## Task 7: The question grid

**Files:**
- Create: `lib/core/ui/components/question_grid_sheet.dart`
- Test: `test/core/ui/components/question_grid_sheet_test.dart`
- Modify: `lib/features/quiz/presentation/quiz_page.dart`

**Interfaces:**
- Consumes: `PennantMark` from Task 1.
- Produces:

```dart
enum GridCellMark { none, correct, wrong, answered }

class GridCell { int number; GridCellMark mark; bool isFlagged; bool isCurrent; }

QuestionGridSheet({
  required List<GridCell> cells,
  required int columns,          // 5 in a quiz, 6 in a mock
  required ValueChanged<int> onTap,
})
```

**From the spec, Section 7.5, "The question grid":** the counter opens **a grid, not a list**,
as a bottom sheet.

**A list answers the wrong question.** A sentence says what a question was about. A navigator
is scanned for what went badly and how much is left, which a grid answers at a glance and a
list answers only by reading. It is also the only shape that survives a mock: 170 items is a
hundred-line scroll as sentences and 29 rows as a grid.

**Treatment: ruled rows.** Horizontal 1px `ruleFaint` under each row, **nothing vertical**.
Six columns in a mock, five in a quiz, cells at least 46px.

**The cell** is a stack, centred as a pair:

| Part | Spec |
|---|---|
| Caret slot | **7px, reserved in every cell**, occupied only by the current one |
| Number | Serif 15/600 in `ink`, tabular. `inkMuted` at 400 when unanswered |
| Mark slot | 11px, 4px above |

**The reserved slot is not optional.** Adding the caret to a cell that has no room for it
grows the cell, and because grid rows size to their tallest cell the whole row grows and
everything below shifts.

**Marks, by surface:**

| Surface | Answered | Wrong | Flagged |
|---|---|---|---|
| Quiz | board ✓ | rust ✕ | not shown |
| Mock | a 5px `amber` dot | never shown | the pennant at 12px |

**Amber, not board, for answered.** A tick in the quiz grid means you were right, which is a
judgment and earns board. Answered in a mock is not a judgment, so it must not wear a
judgment colour.

**The pennant in a cell is `inkMuted`**, because it is a record of something already done and
must not compete with the numbers being scanned.

**Flagged and answered show both marks.** They are different axes: answered is progress,
flagged is doubt.

**The current cell:** a caret above the number, a solid `ink` triangle, **8 by 5**, in the
reserved slot. **No border, box or underline.**

**The caret travels.** One caret per grid, moved by transform, nothing created or destroyed.
Within a part it slides over 400ms on the settled curve. **Across a part boundary it leaves
the plane through the margin**, out past one edge over 200ms on `cubic-bezier(.4, 0, 1, 1)`,
then in from the opposite edge over 300ms on the standard curve. Forward exits right and
enters from the left; backward reverses it. **Nothing scrolls**: the destination was tapped,
so it is on screen by definition. Under reduce-motion the caret simply appears.

**A quiz has one part**, so the boundary case is unreachable here and is exercised by the
mock. Build it anyway, because the component is shared and building it later means rebuilding
the caret.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('a quiz grid is five columns', (tester) async {
    // 10 cells, columns: 5. Expect two rows.
  });

  testWidgets('every cell reserves the caret slot', (tester) async {
    // Assert every cell reports the same height whether current or not.
  });

  testWidgets('a right answer marks board, a wrong one rust', (tester) async {
    expect(find.text('✓'), findsOneWidget);
    expect(find.text('✕'), findsOneWidget);
  });

  testWidgets('flags are not shown in a quiz grid', (tester) async {
    // A flagged cell with mark correct: expect no PennantMark.
  });

  testWidgets('a mock cell shows the dot and the pennant together',
      (tester) async {
    // mark: answered, isFlagged: true.
    expect(find.byType(PennantMark), findsOneWidget);
  });

  testWidgets('tapping a cell reports its number', (tester) async {
    // Tap '7' and expect onTap to have fired with 7.
  });

  testWidgets('the grid has no vertical rules', (tester) async {
    // Assert no Border carries a left or right side.
  });
```

Write the bodies in full.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/ui/components/question_grid_sheet_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write the sheet**

Build it as a `Column` of `Row`s rather than a `GridView`, so each row can carry its own
bottom rule and so the caret can be positioned in a `Stack` over the whole grid.

```dart
/// Reserved in every cell. Adding the caret only to the current one grows
/// that cell, and grid rows size to their tallest cell, so the whole row
/// grows and everything below shifts.
const _caretSlot = 7.0;
const _markSlot = 11.0;
const _minCell = 46.0;
```

The caret is one widget in the `Stack`, moved with `AnimatedPositioned` or an
`AnimatedBuilder` over a controller, never rebuilt per cell:

```dart
  // One caret per grid, moved by transform. Nothing is created or destroyed,
  // which is what lets it cross a part boundary as a single object.
```

The cell's marks:

```dart
              switch (cell.mark) {
                GridCellMark.correct =>
                  Text('✓', style: markStyle.copyWith(color: colors.board)),
                GridCellMark.wrong =>
                  Text('✕', style: markStyle.copyWith(color: colors.rust)),
                // Answered in a mock is not a judgment, so it must not wear a
                // judgment colour.
                GridCellMark.answered => Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                GridCellMark.none => const SizedBox.shrink(),
              },
```

and the flag, at the record weight:

```dart
              if (cell.isFlagged)
                PennantMark(isSet: true, size: 12, color: colors.inkMuted),
```

**Whether flags appear at all is the caller's decision**, expressed by building cells with
`isFlagged: false` in a quiz. Do not add a `surface` enum: the two surfaces differ in the
data they pass, not in the component's behaviour.

- [ ] **Step 4: Open it from the counter**

In `quiz_page.dart`, `_openGrid` shows it as a bottom sheet and calls `controller.goTo` on
tap:

```dart
  Future<void> _openGrid(QuizSession session) async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.colors.background,
      builder: (_) => QuestionGridSheet(
        columns: 5,
        cells: [
          for (var i = 0; i < session.questions.length; i++)
            GridCell(
              number: i + 1,
              mark: _markFor(session, i),
              // Flags are not shown in a quiz grid.
              isFlagged: false,
              isCurrent: i == session.currentIndex,
            ),
        ],
        onTap: (number) => Navigator.of(context).pop(number),
      ),
    );
    if (chosen != null) ref.read(quizControllerProvider.notifier).goTo(chosen - 1);
  }
```

- [ ] **Step 5: Run the tests**

Run: `flutter test test/core/ui/ test/features/quiz/`
Expected: PASS.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
dart run tool/check_layering.dart
git add lib test
git commit -m "feat(ui): the question grid

A grid rather than a list because a navigator is scanned, not read, and
because 170 items is a hundred-line scroll as sentences and 29 rows as a
grid. Horizontal rules only: it sets like a printed results table."
```

---

## Task 8: Leaving

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_page.dart`
- Test: `test/features/quiz/presentation/quiz_leave_test.dart` (create)

**Interfaces:**
- Consumes: `ConfirmationDialog`, which exists.
- Produces: nothing new.

**From the spec, Section 7.5, "Leaving":** the ✕ opens a dialog over an `ink` wash at 34%,
with the page settling 10px and losing a hair of scale on the standard curve. **No blur**,
per the Study spec.

> **Leave this session?**
> Every answer you've given is already saved. You can pick this up from the Quiz tab whenever
> you like.
> [ Keep going ] [ Leave ]

**Leaving does not quit the session.** The row stays open, which is exactly what makes the
Quiz tab's "Still going" state true and what "you can pick this up from the Quiz tab"
promises. **Do not call `QuitSession` here.** Discarding is a deliberate act on the tab, and
Plan 2b built it there.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the close button asks first', (tester) async {
    // Tap the ✕.

    expect(find.text('Leave this session?'), findsOneWidget);
    expect(
      find.text("Every answer you've given is already saved. You can pick "
          'this up from the Quiz tab whenever you like.'),
      findsOneWidget,
    );
  });

  testWidgets('Keep going stays', (tester) async {
    // Tap ✕ then 'Keep going'.

    expect(find.text('Leave this session?'), findsNothing);
    expect(find.byType(QuestionCard), findsOneWidget);
  });

  testWidgets('Leave pops without quitting the session', (tester) async {
    // Tap ✕ then 'Leave'. Assert the route popped and that the session row
    // is still open in the database.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/quiz_leave_test.dart`
Expected: FAIL.

- [ ] **Step 3: Wire the dialog**

Read `lib/core/ui/components/confirmation_dialog.dart` and use it. If it does not support the
34% ink wash or the page settle, add them there rather than building a second dialog: the
mock's leave path wants the same treatment.

```dart
  Future<void> _confirmLeave() async {
    final leave = await showConfirmationDialog(
      context: context,
      title: 'Leave this session?',
      message: "Every answer you've given is already saved. You can pick this "
          'up from the Quiz tab whenever you like.',
      cancelLabel: 'Keep going',
      confirmLabel: 'Leave',
    );
    if (leave != true || !mounted) return;
    // The session row stays open on purpose. That is what makes the tab's
    // "Still going" state true, and what this dialog just promised.
    context.pop();
  }
```

Match `confirmation_dialog.dart`'s actual API; the call above is the shape, not the
signature.

- [ ] **Step 4: Run the whole suite**

Run: `flutter test`
Expected: PASS. This is the last task, so the suite is the gate.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(quiz): leaving a session keeps it

The dialog promises the session can be picked up from the Quiz tab, so
leaving must not quit the row. Discarding is a deliberate act and it
already lives on the tab."
```

---

## What this plan deliberately does not do

- **The debrief.** Plan 5. `DoneForTodayCelebration` still shows at the end of a session when
  this plan lands.
- **The review component.** Plan 6.
- **Note B's content.** The rationale-per-choice generation pass is Section 9's content work.
  The reveal renders note B wherever the field is populated and shows nothing where it is
  not, which is the specified appearance for Free and becomes the Pro note as content lands.
- **The mock's use of the grid.** The component takes six columns and the amber dot, and the
  mock's own plans mount it.
- **The confidence step.** Drawn and rejected: the tap is in a rhythm Spec 4 D4 protects, and
  what it would have bought is recovered by the debrief.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # still 7, not 8
flutter test                                     # all pass
```

By hand, on a device:

- A question with LaTeX in its stem renders as mathematics, not as dollar signs.
- Tapping a choice marks it, dims the others, and shows the verdict with an interval.
- On Free, a miss shows the answer's note and nothing suggesting a second note exists.
- The flag in the bar fills from its staff, and the first one raises a toast with Undo.
- The counter opens a five-column grid; tapping a cell moves there and the caret slides.
- A past question shows its reveal and its choices do not respond.
- The ✕ asks, and leaving keeps the session so the tab says "Still going".

## Self-review notes

Checked against Sections 3, 6 and 7.5:

- The commit with no confidence step, the four marks, the verdict, the interval: Tasks 2, 3.
- Marginal notes with their letters, kickers and tier rule, and no trace on Free: Task 3.
- The pennant's paths, both weights, its motion and its toasts: Tasks 1, 4, 5.
- Bar order, tappable counter, continuous rail: Task 5.
- Read-only back navigation with no resubmission: Task 6.
- The grid's ruled rows, reserved caret slot, per-surface marks, travelling caret: Task 7.
- The leave dialog's exact copy, and that leaving does not quit: Task 8.
- **One documented degradation:** note B is absent until the rationale content pass runs.
