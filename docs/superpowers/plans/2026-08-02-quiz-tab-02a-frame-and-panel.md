# Quiz Tab, Plan 2a of 6: The Tab's Frame and the Panel Device

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

**Goal:** Give the Quiz tab the chrome the spec describes, build the ruled panel device
every later task on this tab needs, stop printing exception strings to students, and
delete the two rows and one screen the spec removes.

**Architecture:** One new component in `lib/core/ui/components/`, a rewrite of
`quiz_tab_home.dart`'s scaffold and states, and three deletions. No new providers, no
storage, no session logic.

**Tech Stack:** Flutter, Riverpod, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-28-quiz-tab-design.md` Section 1, the app
bar, exam name, ruled panels, practice rows and "Other states" subsections.

---

## Why seam 2 is three plans

The spec's closing note calls seam 2 "the tab: panels, rows, all four day states, the mock
panel and its cooldown, and the deletion of `DrillSubtopicBrowser`". Reading the code, that
is three separable deliverables:

| Plan | What | Why it is separate |
|---|---|---|
| **2a**, this one | The frame, the `RuledPanel` component, the deletions | Everything below needs the panel device. Nothing here needs new providers |
| **2b** | The session panel's four states, and `todayTopicQueueProvider` | `BuildTodayQueue` is pure and referenced nowhere. Wiring it needs `FsrsDueSelector`, `WeaknessSelector` and `NewCardSelector` read properly first |
| **2c** | The mock panel and its cooldown, the practice rows, the flagged section | The flagged section reads `question_flags_local`, merged in Plan 1. The mock panel needs `mockAvailabilityProvider` |

Each produces working, testable software on its own. 2a can ship alone: it fixes a live
defect and removes dead surface.

## What this fixes that is live today

1. **`quiz_tab_home.dart:30` prints `e.toString()` to students.** The spec forbids it by
   name.
2. **The "Study" row navigates to a tab whose icon is two pixels below it.** Deleted by
   the spec, Section 1.
3. **`/quiz/drill/:examId` and `DrillSubtopicBrowser`** are superseded by the practice
   picker, which is seam 3. The row and the route go now so nothing new is built against
   them.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.** The kit already holds
  `PageScaffold`, `RuledSection`, `SectionHeader`, `StatsBand`, `InkTableRow`,
  `EmptyState`, `ErrorBanner` and `FaintBars`. Adding a near-duplicate is the most common
  avoidable defect in this codebase.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer. Grouping is
  hairline rules and rectangles.
- **Colour carries meaning.** Board green is reserved for the single primary action on a
  screen. At most one non-`secondary` `BoardButton` per screen.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**. Every user-facing
  string here is quoted from the spec. Do not improvise copy.
- **Navigation rule (UI-001).** `push` for destinations outside the tab shell, `go` only
  for tab switches and deliberate resets.
- **Layering.** R1: `lib/core/**` must not import `lib/features/**`.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/core/ui/components/ruled_panel.dart` — the bordered panel with a plated heading.
  In `core/ui/` because the Quiz tab, the Home spec and the mock panel all use it.
- `test/core/ui/components/ruled_panel_test.dart`

**Modify:**
- `lib/features/quiz/presentation/quiz_tab_home.dart` — scaffold, states, row removal.
- `lib/app/router.dart` — delete the drill route.
- `test/features/quiz/presentation/quiz_tab_nudge_test.dart` — it references the drill
  row.

**Delete:**
- `lib/features/quiz/presentation/drill_subtopic_browser.dart`

**Not touched:** the session panel, the mock panel and the flagged section, which are 2b
and 2c. This plan leaves the tab showing the exam name and the two surviving practice rows.

---

## Task 1: `RuledPanel`

**Files:**
- Create: `lib/core/ui/components/ruled_panel.dart`
- Test: `test/core/ui/components/ruled_panel_test.dart`

**Interfaces:**
- Consumes: `context.colors`, `context.textStyles`, `AppDimensions.hairline`.
- Produces: `RuledPanel({required String heading, required Widget child, String? count})`.
  Plans 2b, 2c and the Home spec's plan all use it.

**Why a new component and not `RuledSection`.** `RuledSection` draws a **top rule only**;
its docstring calls it "a flat content block bounded by a 1px hairline". The spec's panel
is a **bordered rectangle** with a heading plate inside it. They are different devices and
both are used on this tab.

**From the spec, Section 1:** a 1px `rule` border, square corners, on the same paper as
the page, padding 14 by 15 with 16 below. It opens with a plated heading: serif 15/700
underscored by a 1.6px `ink` rule. The header carries at most one trailing element, and it
is **a count in 12px `inkMuted`, tabular figures, never a status word.**

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/ruled_panel_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_themed.dart';

void main() {
  testWidgets('a panel shows its heading and its child', (tester) async {
    await pumpThemed(
      tester,
      const RuledPanel(
        heading: "Today's session",
        child: Text('body'),
      ),
    );

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('a panel shows a count when given one', (tester) async {
    await pumpThemed(
      tester,
      const RuledPanel(
        heading: 'Still going',
        count: '6 of 10',
        child: Text('body'),
      ),
    );

    expect(find.text('6 of 10'), findsOneWidget);
  });

  testWidgets('a panel without a count renders no trailing text',
      (tester) async {
    await pumpThemed(
      tester,
      const RuledPanel(heading: 'Mock exam', child: Text('body')),
    );

    expect(find.text('Mock exam'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('the panel is a square-cornered bordered rectangle',
      (tester) async {
    await pumpThemed(
      tester,
      const RuledPanel(heading: 'Mock exam', child: Text('body')),
    );

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('Mock exam'),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.borderRadius, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.border, isNotNull);
  });
}
```

Use whatever themed-pump helper `test/core/ui/components/` already uses. If there is no
`pump_themed.dart`, copy the wrapper from `answer_row_test.dart` rather than inventing
one.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/ui/components/ruled_panel_test.dart`
Expected: FAIL. `ruled_panel.dart` does not exist.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/ruled_panel.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A stateful object drawn as a bordered rectangle on the page's own paper.
///
/// Distinct from [RuledSection], which is a top-rule block. This one is
/// bounded on all four sides and opens with a heading plate.
///
/// The trailing slot takes a count and nothing else. A status word was tried
/// and cut: in this identity the top right of a section is either an action in
/// board or a count, and a word is neither.
class RuledPanel extends StatelessWidget {
  const RuledPanel({
    required this.heading,
    required this.child,
    this.count,
    super.key,
  });

  final String heading;
  final Widget child;

  /// Tabular figures in 12px `inkMuted`. Never a status word.
  final String? count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.rule,
          // ignore: avoid_redundant_argument_values
          width: AppDimensions.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.ink, width: 1.6),
                    ),
                  ),
                  child: Text(heading, style: styles.headlineSmall),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 12),
                Text(
                  count!,
                  style: styles.bodySmall.copyWith(
                    color: colors.inkMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}
```

`FontFeature` comes from `dart:ui`. Add `import 'dart:ui' show FontFeature;` at the top.

**The heading plate must not stretch.** It is wrapped in `Flexible` so the underline runs
under the words rather than the full panel width, which is what makes it a plate rather
than a divider.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/core/ui/components/ruled_panel_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/core/ui/components/ruled_panel.dart test/core/ui/components/ruled_panel_test.dart
git commit -m "feat(ui): the bordered panel the stateful sections need

RuledSection draws a top rule and nothing else. The session and mock
panels are bounded rectangles with a heading plate, which is a different
device, and both appear on the Quiz tab."
```

---

## Task 2: The tab's frame

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart`
- Test: `test/features/quiz/presentation/quiz_tab_home_test.dart` (create if absent)

**Interfaces:**
- Consumes: `RuledPanel` from Task 1, `PageScaffold`, `ErrorBanner`, `FaintBars`,
  `EmptyState`, all existing.
- Produces: nothing new. Plans 2b and 2c fill the body.

**From the spec, Section 1:**

- **App bar:** height 56, `background`, no elevation, no scroll shadow. Title "Quiz" in
  `headlineMedium`. **No trailing element.**
- **Exam name:** the exam **short name** in `displaySmall`, 6px below the bar, at the 20px
  page gutter. The tab currently prints `exam.name` in `headlineMedium` with `shortName`
  beneath it in `bodySmall`. Both change.
- **Loading:** `FaintBars`.
- **Error:** `ErrorBanner` in its `error` variant, message "Could not load your practice.
  Pull down to try again." **Never the exception string.**
- **No exam chosen:** the existing fallback, "Choose your exam" over "Pick the exam you are
  reviewing for." and a board "Choose exam".
- `PageScaffold` and `EmptyState` exist and are used only by `quiz_results_page.dart`.
  Adopt them here.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the error state never shows the exception', (tester) async {
    // Override activeExamFocusProvider with an AsyncError carrying an
    // exception whose toString() contains 'SocketException'.
    // Pump QuizTabHome.

    expect(
      find.text('Could not load your practice. Pull down to try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('SocketException'), findsNothing);
  });

  testWidgets('the tab shows the exam short name, not the long name',
      (tester) async {
    // Override activeExamFocusProvider with a focus carrying an exam whose
    // name is 'UP College Admission Test' and shortName is 'UPCAT'.

    expect(find.text('UPCAT'), findsOneWidget);
    expect(find.text('UP College Admission Test'), findsNothing);
  });

  testWidgets('the tab no longer offers a Study row', (tester) async {
    expect(find.text('Study'), findsNothing);
  });

  testWidgets('the tab no longer offers a Drill a topic row', (tester) async {
    expect(find.text('Drill a topic'), findsNothing);
  });
```

Follow the override idiom in `test/features/quiz/presentation/quiz_tab_nudge_test.dart`,
which already pumps this widget with providers overridden.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/quiz/presentation/`
Expected: FAIL. The error state prints `e.toString()` and the Study row exists.

- [ ] **Step 3: Rewrite the scaffold**

Replace `QuizTabHome.build`'s `Scaffold` with `PageScaffold`, and give the app bar the
spec's treatment:

```dart
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: context.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Quiz', style: context.textStyles.headlineMedium),
      ),
      body: asyncFocus.when(
        loading: () => const PageScaffold(body: FaintBars()),
        error: (_, __) => PageScaffold(
          body: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message:
                'Could not load your practice. Pull down to try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(activeExamFocusProvider),
          ),
        ),
        data: (focus) {
          if (focus.needsSelection || focus.exam == null) {
            return const _ChooseExamFallback();
          }
          return _QuizTabBody(exam: focus.exam!);
        },
      ),
    );
```

**The error callback takes `(_, __)` deliberately.** The exception is not read, so it
cannot be printed by accident later.

Check `ErrorBannerVariant`'s actual case name with
`grep -n "enum ErrorBannerVariant" -A 5 lib/core/ui/components/error_banner.dart` and use
it exactly. If there is no `error` case, **stop and say so** rather than picking another.

- [ ] **Step 4: Rewrite the body**

Rename `_ExamActions` to `_QuizTabBody` and reduce it to the frame plus the two surviving
rows. The session panel, the mock panel and the flagged section are 2b and 2c; leave a
comment saying so rather than a placeholder widget:

```dart
class _QuizTabBody extends ConsumerWidget {
  const _QuizTabBody({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      children: [
        Text(exam.shortName, style: styles.displaySmall),
        const SizedBox(height: 20),
        // The session panel and the mock panel land here in plans 2b and 2c.
        const SectionHeader(title: 'More ways to practice'),
        InkTableRow(
          title: 'Your mistakes',
          subtitle: "Questions you've got wrong",
          onTap: () => context.push('/quiz/retake/${exam.id}'),
        ),
        InkTableRow(
          title: 'Choose what to practice',
          subtitle: 'One topic or one lesson, your choice of length',
          bottomRule: false,
          // The practice picker is seam 3. Until it exists this row must not
          // be tappable, because a dead chevron is worse than none.
          onTap: null,
        ),
      ],
    );
  }
}
```

**"Your mistakes" keeps its live subtitle for now.** The spec's version reads "28 you've
got wrong in the last month", which needs a count this plan does not compute. The count
and the empty state are 2c. Do not invent a number.

**Keep `_onStartQuiz` and `_QuizNudgeSheet` exactly as they are.** They are wired to the
session start and are 2b's problem, not this plan's. Moving them now would break
`quiz_tab_nudge_test.dart` for no gain.

- [ ] **Step 5: Run the tests**

Run: `flutter test test/features/quiz/`
Expected: PASS. `quiz_tab_nudge_test.dart` may need its finders updated where they
referenced the removed rows.

- [ ] **Step 6: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/quiz test/features/quiz
git commit -m "feat(quiz): the tab stops showing students a stack trace

Its error state printed e.toString(). It also led with the exam's full
name where every other surface leads with the short name, and offered a
Study row pointing at a tab two pixels below it."
```

---

## Task 3: Delete the drill route and its browser

**Files:**
- Modify: `lib/app/router.dart`
- Delete: `lib/features/quiz/presentation/drill_subtopic_browser.dart`
- Test: whichever files reference either

**Interfaces:**
- Consumes: nothing.
- Produces: nothing. `/quiz/drill/:examId` stops existing.

**From the spec, Section 10, item 5:** "`/quiz/drill/:examId` and `DrillSubtopicBrowser`
are deleted and replaced by the picker."

**Why now rather than with the picker.** The row that opened it is gone as of Task 2, so
the route is unreachable. Leaving an unreachable screen invites something new to be built
against it, and `StartDrill` itself stays: the picker in seam 3 uses it.

- [ ] **Step 1: Find every reference**

Run: `grep -rn "DrillSubtopicBrowser\|quiz/drill" --include="*.dart" lib test`

Expect the router's route and import, the file itself, and any test that navigates there.
**`StartDrill`, `startDrillProvider`, `DrillPicker` and `QuizController.startDrill` are
not references to this screen and must stay.** Seam 3's picker calls them.

- [ ] **Step 2: Delete the route**

In `lib/app/router.dart`, remove the `GoRoute` at line 170 whose path is
`/quiz/drill/:examId`, together with the `drill_subtopic_browser.dart` import.

- [ ] **Step 3: Delete the screen and its test**

```bash
git rm lib/features/quiz/presentation/drill_subtopic_browser.dart
```

Delete its test file too if one exists.

- [ ] **Step 4: Verify nothing referenced it**

Run: `grep -rn "DrillSubtopicBrowser\|quiz/drill" --include="*.dart" lib test`
Expected: no output.

Run: `flutter test`
Expected: PASS, whole suite. This is the last task, so the suite is the gate.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add -A lib test
git commit -m "refactor(quiz): remove the drill browser ahead of the picker

Its only entrance is gone, and an unreachable screen invites something
new to be built against it. StartDrill stays: the practice picker uses
it."
```

---

## What this plan deliberately does not do

- **The session panel and its four states**, plus `todayTopicQueueProvider`. Plan 2b.
  `BuildTodayQueue` is pure, tested and referenced nowhere in `lib/`, and wiring it needs
  `FsrsDueSelector`, `WeaknessSelector` and `NewCardSelector` read properly first.
- **The mock panel, the cooldown, the practice row counts and the flagged section.**
  Plan 2c.
- **The practice picker.** Seam 3. Its row is present and deliberately not tappable until
  then.
- **`quiz_results_page.dart`.** It is rebuilt behind `/review` in seam 6, not deleted.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
```

By hand, on a device, since Aedwon does the visual verification:

- The Quiz tab shows "Quiz" in the bar and the exam short name beneath it.
- Killing the network on cold start shows the spec's sentence and no exception text.
- The Study and Drill rows are gone; "Your mistakes" and "Choose what to practice" remain,
  the second one inert.
