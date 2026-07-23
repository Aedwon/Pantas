# Settings 04: the four sheets

> **Typography, amended 11 August 2026.** Any "serif" below is superseded: the
> app uses one family, Source Sans 3, everywhere. See
> `decisions/2026-08-10-typeface-log.md`.



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

## AMENDED 3 August 2026: `ExamDate` call sites change

**Conflict C1, ruled by Aedwon.** One `ExamDate`, defined by
`2026-08-02-onboarding-flow-and-new-steps.md` Task 1.

**In this plan:** `ExamDate.day(x)` becomes `ExamDate.onDay(x)`, `ExamDate.month(y, m)`
becomes `ExamDate.inMonth(year: y, month: m)`, and the nullable getter `.exactDay` becomes
`.day`. Nothing else in this plan moves.

**`showExamDateSheet` and `InkWheel` are still built here** and are still consumed by
onboarding's date step rather than duplicated there.

---

**Goal:** Build the wheel component the whole app has been missing, then the four sheets that edit a value in place: exam date, daily reminder, name, and how sessions are built.

**Architecture:** One `InkWheel` in `lib/core/ui/` wrapping `ListWheelScrollView`, used by the date and reminder sheets. Each sheet is a function returning the new value, so the caller owns the write and the sheets stay testable without Riverpod. The ordering sheet uses ringed choice rows rather than wheels, because it is a choice with reasons rather than a control.

**Tech Stack:** Flutter, `flutter_test`.

**Source spec:** `docs/superpowers/specs/2026-08-03-settings-design.md`, Sections 5 and 6.

**Decision log:** `docs/superpowers/decisions/2026-08-03-settings-log.md`.

## Global Constraints

- **American spelling** in every string, comment and identifier.
- **No em dashes** anywhere, including in the ordering sheet's reasons, which are the exact place one gets typed by reflex.
- **The three exam date answers are not negotiable:** an exact date, a month with the day resting on the dash, or "I don't know yet". Offering fewer would silently promote a month-precision student to day precision and make Home print a day count built on an assumption.
- **No native picker.** `showDatePicker` and `showTimePicker` are banned: a 28px radius, a drop shadow and a raised Material surface, and a calendar cannot express "October, no day" at all.
- **A choice takes effect on tap.** No Save and no Cancel on the ordering sheet, because nothing is lost by changing your mind. The wheel sheets do have a Save, because a wheel mid-scroll is not a choice yet.
- `flutter analyze` clean and `dart format --output=none --set-exit-if-changed lib test` passing before any commit.
- **Readable at 200% text scale.** No clipping, no overlap, and no text that
  carries meaning truncated to an ellipsis. Rules and rhythm may stretch.
- **Every tap target is at least 44 by 44**, using the pattern in
  `settings-01`: a smaller visual box inside a larger tappable one.
- **Color is never the only carrier.** Severity must also read as a word or a
  position.
- **Every control has a semantics label.** Icons especially: they have no text
  to read.

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-03-settings-01-the-kit.md` | `showInkSheet` | **Blocking** |
| `2026-08-03-settings-02-storage.md` | `ExamDate`, `SessionOrdering`, `SettingsActions.setName` / `.setExamDate` / `.setSessionOrdering` | **Blocking** |
| `2026-08-03-settings-03-the-top-level.md` | The four stub routes this plan replaces | **Blocking** |

## What this plan hands to onboarding

`InkWheel` and `showExamDateSheet` are built here in `lib/core/ui/` because Settings reached them first. The onboarding date step specified in `2026-08-02-onboarding-name-and-date-design.md` Section 4 **consumes these two** rather than building its own. That is the whole reason they are not in `features/settings/`.

## File structure

| File | Responsibility |
|---|---|
| `lib/core/ui/components/ink_wheel.dart` (create) | One scrollable column of values with the selection band. |
| `lib/core/ui/components/exam_date_sheet.dart` (create) | Three wheels, the dash, "I don't know yet". Returns `ExamDate?`. |
| `lib/features/settings/presentation/sheets/reminder_sheet.dart` (create) | Two wheels plus AM/PM. Returns `SettingsTime?`. |
| `lib/features/settings/presentation/sheets/name_sheet.dart` (create) | The hairline-ruled field. Returns the new name. |
| `lib/features/settings/presentation/sheets/ordering_sheet.dart` (create) | Three ringed rows, the recommended badge. Returns `SessionOrdering?`. |
| `lib/app/router.dart` (modify) | Four stub builders become sheet launchers. |

---

## Task 1: The wheel

**Files:**
- Create: `lib/core/ui/components/ink_wheel.dart`
- Test: `test/core/ui/components/ink_wheel_test.dart`

**Interfaces:**
- Produces:

```dart
class InkWheel<T> extends StatefulWidget {
  const InkWheel({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.labelBuilder,
    super.key,
  });

  final List<T> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String Function(T value) labelBuilder;

  static const double itemHeight = 30;
  static const int visibleItems = 5;
}

/// The band behind the live row, drawn once by the caller behind a Row of
/// wheels so three columns share one band.
class InkWheelBand extends StatelessWidget { const InkWheelBand({super.key}); }
```

**Why not `CupertinoPicker`.** The age-gate step already uses one and it brings iOS chrome we do not want anywhere else. `ListWheelScrollView` is the same machinery without the styling, and it lets the band be ours.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/ink_wheel_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/ink_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the wheel shows its values and starts on the selected one',
      (tester) async {
    await tester.pumpApp(
      SizedBox(
        height: InkWheel.itemHeight * InkWheel.visibleItems,
        child: InkWheel<int>(
          values: const [10, 11, 12, 13, 14],
          selectedIndex: 2,
          onSelected: (_) {},
          labelBuilder: (value) => '$value',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('scrolling reports the new index', (tester) async {
    int? reported;
    await tester.pumpApp(
      SizedBox(
        height: InkWheel.itemHeight * InkWheel.visibleItems,
        child: InkWheel<int>(
          values: const [10, 11, 12, 13, 14],
          selectedIndex: 2,
          onSelected: (index) => reported = index,
          labelBuilder: (value) => '$value',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(InkWheel<int>),
      const Offset(0, -InkWheel.itemHeight),
    );
    await tester.pumpAndSettle();

    expect(reported, 3);
  });

  testWidgets('an empty list renders without throwing', (tester) async {
    await tester.pumpApp(
      SizedBox(
        height: InkWheel.itemHeight * InkWheel.visibleItems,
        child: InkWheel<int>(
          values: const [],
          selectedIndex: 0,
          onSelected: (_) {},
          labelBuilder: (value) => '$value',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InkWheel<int>), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/ink_wheel_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/ink_wheel.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One column of a wheel picker, without iOS chrome.
///
/// CupertinoPicker was rejected: it brings its own selection overlay and its
/// own type. This is the same ListWheelScrollView underneath with our band
/// and our text styles, so a wheel looks like the rest of the app.
class InkWheel<T> extends StatefulWidget {
  const InkWheel({
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.labelBuilder,
    super.key,
  });

  final List<T> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String Function(T value) labelBuilder;

  static const double itemHeight = 30;
  static const int visibleItems = 5;

  @override
  State<InkWheel<T>> createState() => _InkWheelState<T>();
}

class _InkWheelState<T> extends State<InkWheel<T>> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.selectedIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    if (widget.values.isEmpty) return const SizedBox.shrink();

    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: InkWheel.itemHeight,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 2.4,
      perspective: 0.002,
      onSelectedItemChanged: widget.onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.values.length,
        builder: (context, index) {
          return Center(
            child: Text(
              widget.labelBuilder(widget.values[index]),
              style: styles.bodyLarge.copyWith(
                fontSize: 17,
                color: colors.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The band behind the live row. Drawn once behind a Row of wheels so every
/// column shares one band rather than each drawing its own.
class InkWheelBand extends StatelessWidget {
  const InkWheelBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: InkWheel.itemHeight,
        decoration: BoxDecoration(
          color: context.colors.ruleFaint,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
```

Add `import 'dart:ui' show FontFeature;` if the analyzer asks.

- [ ] **Step 4: Run the tests and commit**

Run: `flutter test test/core/ui/components/ink_wheel_test.dart`
Expected: PASS, 3 tests.

```bash
git add lib/core/ui/components/ink_wheel.dart test/core/ui/components/ink_wheel_test.dart
git commit -m "feat: a wheel column without the iOS chrome"
```

---

## Task 2: The exam date sheet

**Files:**
- Create: `lib/core/ui/components/exam_date_sheet.dart`
- Test: `test/core/ui/components/exam_date_sheet_test.dart`

**Interfaces:**
- Consumes: `InkWheel`, `InkWheelBand`, `showInkSheet`, `ExamDate`.
- Produces:

```dart
/// Returns the chosen date, or [ExamDateSheetResult.cleared] when the student
/// answers "I don't know yet", or null when the sheet is dismissed.
Future<ExamDateSheetResult?> showExamDateSheet({
  required BuildContext context,
  required ExamDate? current,
  required DateTime today,
});

sealed class ExamDateSheetResult {
  const factory ExamDateSheetResult.chosen(ExamDate date) = ExamDateChosen;
  const factory ExamDateSheetResult.cleared() = ExamDateCleared;
}
```

**Three results, not two.** Dismissing and answering "I don't know yet" are different: one changes nothing, the other clears a date the student had. Collapsing them would make the third answer unreachable once a date is set.

**The day column's first entry is a dash.** Resting on it means the day is unset, which turns a ceiling on the control into a state inside it.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/exam_date_sheet_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/exam_date_sheet.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

Future<ExamDateSheetResult?> _open(
  WidgetTester tester, {
  ExamDate? current,
}) async {
  ExamDateSheetResult? result;
  await tester.pumpApp(
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          result = await showExamDateSheet(
            context: context,
            current: current,
            today: DateTime(2026, 8, 3),
          );
        },
        child: const Text('open'),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('the sheet offers all three answers', (tester) async {
    await _open(tester);

    expect(find.text('Exam date'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text("I don't know yet"), findsOneWidget);
    // The dash is the day column's unset state.
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('the lede tells the student what the dash is for',
      (tester) async {
    await _open(tester);

    expect(
      find.text('Leave the day on the dash if you only know the month.'),
      findsOneWidget,
    );
  });

  testWidgets('"I don\'t know yet" clears rather than dismissing',
      (tester) async {
    ExamDateSheetResult? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showExamDateSheet(
              context: context,
              current: ExamDate.day(DateTime(2026, 10, 12)),
              today: DateTime(2026, 8, 3),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I don't know yet"));
    await tester.pumpAndSettle();

    expect(result, isA<ExamDateCleared>());
  });

  testWidgets('saving with the day on the dash returns month precision',
      (tester) async {
    ExamDateSheetResult? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showExamDateSheet(
              context: context,
              current: const ExamDate.month(2026, 10),
              today: DateTime(2026, 8, 3),
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final chosen = (result! as ExamDateChosen).date;
    expect(chosen.precision, ExamDatePrecision.month);
    expect(chosen.exactDay, isNull);
  });

  testWidgets('the wheels never offer a month already finished',
      (tester) async {
    await _open(tester);

    // today is 3 August 2026, so July 2026 must not be reachable.
    expect(find.text('Jul'), findsNothing);
    expect(find.text('Aug'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/exam_date_sheet_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the sheet**

Create `lib/core/ui/components/exam_date_sheet.dart`. Build it to this shape:

- A sealed `ExamDateSheetResult` with `ExamDateChosen(ExamDate date)` and `ExamDateCleared()`.
- A `StatefulWidget` body holding three indices: day, month offset from `today`, and the year implied by the month offset.
- **Month values** run from `DateTime(today.year, today.month)` forward 36 months, labeled `Jan` through `Dec` in the short forms already used by `SettingsValueFormats`, with the year shown in the third column.
- **Day values** are `['-', 1, 2, ... n]` where `n` is the day count of the selected month. When the selected month is the current month, days before tomorrow are omitted, so the wheel cannot express a refused date at all.
- Changing the month rebuilds the day list and clamps the day index, so a 31 selected in October does not survive a move to November.
- The header is `Exam date` in `styles.headlineSmall.copyWith(fontSize: 16)`, then the lede `Leave the day on the dash if you only know the month.` in `bodySmall` at `inkMuted`.
- The wheels sit in a `SizedBox` of `InkWheel.itemHeight * InkWheel.visibleItems` in a `Stack` over one `InkWheelBand`.
- Below them, a `BoardButton` labeled `Save`, then a board text action labeled `I don't know yet` in the slot the Quiz tab gives "Discard this session".
- `Save` pops `ExamDateChosen`, built as `ExamDate.month(year, month)` when the day index is 0 and `ExamDate.day(...)` otherwise.
- The text action pops `ExamDateCleared`.

The whole widget is wrapped by `showInkSheet`, so it supplies no wash, no rule and no padding of its own.

- [ ] **Step 4: Run the tests and commit**

Run: `flutter test test/core/ui/components/exam_date_sheet_test.dart`
Expected: PASS, 5 tests.

```bash
git add lib/core/ui/components/exam_date_sheet.dart test/core/ui/components/exam_date_sheet_test.dart
git commit -m "feat: the exam date sheet, with the dash that means month only"
```

---

## Task 3: The reminder and name sheets

**Files:**
- Create: `lib/features/settings/presentation/sheets/reminder_sheet.dart`
- Create: `lib/features/settings/presentation/sheets/name_sheet.dart`
- Test: `test/features/settings/presentation/sheets/reminder_sheet_test.dart`
- Test: `test/features/settings/presentation/sheets/name_sheet_test.dart`

**Interfaces:**
- Produces:

```dart
Future<SettingsTime?> showReminderSheet({
  required BuildContext context,
  required SettingsTime? current,
});

/// Returns the new name. An empty result clears it, because empty and absent
/// are the same state.
Future<String?> showNameSheet({
  required BuildContext context,
  required String? current,
});
```

- [ ] **Step 1: Write the failing tests**

Create `test/features/settings/presentation/sheets/name_sheet_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/settings/presentation/sheets/name_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('the field is a hairline rule, not a filled Material box',
      (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              showNameSheet(context: context, current: 'Aedwon'),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.filled ?? false, isFalse);
    expect(field.decoration!.border, isA<UnderlineInputBorder>());
  });

  testWidgets('clearing the field and saving clears the name', (tester) async {
    String? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showNameSheet(context: context, current: 'Aedwon');
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, '');
  });
}
```

Create `test/features/settings/presentation/sheets/reminder_sheet_test.dart` with the equivalent two: that the sheet renders three wheels and a Save, and that saving returns the selected `SettingsTime`.

- [ ] **Step 2: Run them and confirm they fail**

Run: `flutter test test/features/settings/presentation/sheets/`
Expected: FAIL, the URIs do not exist.

- [ ] **Step 3: Write the sheets**

`name_sheet.dart`: a `showInkSheet` holding a serif 16/700 `What should we call you?`, a `TextField` with `InputDecoration(border: UnderlineInputBorder(), filled: false, isDense: true)` colored from `context.colors.rule`, and a `BoardButton` labeled `Save` that pops the trimmed text. The hint is `A nickname is fine.`

`reminder_sheet.dart`: three `InkWheel`s over one `InkWheelBand`, hours 1 through 12, minutes in five-minute steps, and AM/PM. Header `Daily reminder`. `Save` pops a `SettingsTime` converted to 24-hour. There is no clear action: turning the reminder off is the notification permission's business, not this sheet's.

- [ ] **Step 4: Run the tests and commit**

Run: `flutter test test/features/settings/presentation/sheets/`
Expected: PASS.

```bash
git add lib/features/settings/presentation/sheets test/features/settings/presentation/sheets
git commit -m "feat: the name and reminder sheets"
```

---

## Task 4: The ordering sheet

**Files:**
- Create: `lib/features/settings/presentation/sheets/ordering_sheet.dart`
- Test: `test/features/settings/presentation/sheets/ordering_sheet_test.dart`

**Interfaces:**
- Consumes: `SessionOrdering` from Plan 02, `showInkSheet` from Plan 01.
- Produces:

```dart
Future<SessionOrdering?> showOrderingSheet({
  required BuildContext context,
  required SessionOrdering current,
});
```

**Tapping a row picks it and closes the sheet.** No Save and no Cancel: nothing is lost by changing your mind, and a confirm button on a three-way preference is friction with no purpose.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/presentation/sheets/ordering_sheet_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/session_ordering.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/sheets/ordering_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

Future<SessionOrdering?> _open(WidgetTester tester) async {
  SessionOrdering? result;
  await tester.pumpApp(
    Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          result = await showOrderingSheet(
            context: context,
            current: SessionOrdering.interleavedTail,
          );
        },
        child: const Text('open'),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('all three orderings appear with their plain labels',
      (tester) async {
    await _open(tester);

    expect(find.text('One topic only'), findsOneWidget);
    expect(find.text('Interleaved tail'), findsOneWidget);
    expect(find.text('All mixed up'), findsOneWidget);
  });

  testWidgets('the lede is the one from the spec', (tester) async {
    await _open(tester);

    expect(
      find.text(
        'Each session has one main topic. This sets how much comes from '
        'other topics.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('only the default carries the recommended badge',
      (tester) async {
    await _open(tester);

    expect(find.text('Recommended'), findsOneWidget);
  });

  testWidgets('tapping a row picks it and closes, with no Save button',
      (tester) async {
    SessionOrdering? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showOrderingSheet(
              context: context,
              current: SessionOrdering.interleavedTail,
            );
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    expect(find.text('Cancel'), findsNothing);

    await tester.tap(find.text('All mixed up'));
    await tester.pumpAndSettle();

    expect(result, SessionOrdering.fullyMixed);
    expect(find.text('All mixed up'), findsNothing);
  });

  testWidgets('no reason on the sheet contains an em dash', (tester) async {
    await _open(tester);

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.contains('—') ?? false, isFalse);
    }
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/presentation/sheets/ordering_sheet_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the sheet**

Create `lib/features/settings/presentation/sheets/ordering_sheet.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/ink_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/domain/session_ordering.dart';
import 'package:flutter/material.dart';

const String _lede =
    'Each session has one main topic. This sets how much comes from '
    'other topics.';

/// The three-way choice for how today's session is built.
///
/// A sheet rather than a page, and there is no Save: a choice takes effect on
/// tap because nothing is lost by changing your mind. The reasons are short
/// on purpose. They were too long for a fifth grader before they were ever
/// too long for a sheet.
Future<SessionOrdering?> showOrderingSheet({
  required BuildContext context,
  required SessionOrdering current,
}) {
  return showInkSheet<SessionOrdering>(
    context: context,
    builder: (sheetContext) {
      final colors = sheetContext.colors;
      final styles = sheetContext.textStyles;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How sessions are built',
            style: styles.headlineSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(_lede, style: styles.bodySmall.copyWith(color: colors.inkMuted)),
          const SizedBox(height: 12),
          for (final ordering in SessionOrdering.values)
            _OrderingRow(
              ordering: ordering,
              isSelected: ordering == current,
              isLast: ordering == SessionOrdering.values.last,
              onTap: () => Navigator.of(sheetContext).pop(ordering),
            ),
        ],
      );
    },
  );
}

class _OrderingRow extends StatelessWidget {
  const _OrderingRow({
    required this.ordering,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  final SessionOrdering ordering;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 11),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: colors.ruleFaint)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: _Ring(isSelected: isSelected),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ordering.label,
                        style: styles.bodyMedium.copyWith(
                          fontSize: 14.5,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (ordering.isRecommended) ...[
                        const SizedBox(width: 7),
                        Text(
                          'Recommended',
                          style: styles.labelSmall.copyWith(
                            fontSize: 10.5,
                            color: colors.board,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ordering.reason,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 13,
      height: 13,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? colors.ink : colors.inkMuted,
            width: 1.3,
          ),
        ),
        child: isSelected
            ? Center(
                child: SizedBox(
                  width: 6.8,
                  height: 6.8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.ink,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
```

- [ ] **Step 4: Run the tests and commit**

Run: `flutter test test/features/settings/presentation/sheets/ordering_sheet_test.dart`
Expected: PASS, 5 tests.

```bash
git add lib/features/settings/presentation/sheets/ordering_sheet.dart test/features/settings/presentation/sheets/ordering_sheet_test.dart
git commit -m "feat: the ordering sheet, three choices and no Save button"
```

---

## Task 5: Wire the four rows

**Files:**
- Modify: `lib/features/settings/presentation/settings_home_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/presentation/settings_home_page_test.dart` (append)

The four rows currently push `NotBuiltYetPage`. They now open sheets instead, so **the four routes `/settings/name`, `/settings/exam-date`, `/settings/reminder` and `/settings/ordering` are deleted**, not repointed. A sheet is not a destination and giving it a URL would let a deep link open a sheet over nothing.

- [ ] **Step 1: Write the failing test**

Append to `test/features/settings/presentation/settings_home_page_test.dart`:

```dart
  testWidgets('tapping the exam date row opens a sheet, not a page',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exam date'));
    await tester.pumpAndSettle();

    expect(find.text("I don't know yet"), findsOneWidget);
  });

  testWidgets('tapping the ordering row opens the ordering sheet',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    await tester.tap(find.text('How sessions are built'));
    await tester.pumpAndSettle();

    expect(find.text('One topic only'), findsOneWidget);
  });
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/presentation/settings_home_page_test.dart`
Expected: FAIL, the sheet content is not found because the row still pushes a route.

- [ ] **Step 3: Swap the four callbacks**

In `settings_home_page.dart`, replace the four `_push` calls:

```dart
              // Name
              onTap: () async {
                final next = await showNameSheet(
                  context: context,
                  current: settings.name,
                );
                if (next != null) await actions.setName(next);
              },
```

```dart
              // Exam date
              onTap: () async {
                final result = await showExamDateSheet(
                  context: context,
                  current: settings.examDate,
                  today: DateTime.now(),
                );
                switch (result) {
                  case ExamDateChosen(:final date):
                    await actions.saveExamDate(date, today: DateTime.now());
                  case ExamDateCleared():
                    await actions.clearExamDate();
                  case null:
                    break;
                }
              },
```

```dart
              // Daily reminder, in the branch where permission is granted
              onTap: () async {
                final next = await showReminderSheet(
                  context: context,
                  current: settings.dailyReminderTime,
                );
                if (next != null) await actions.saveReminderTime(next);
              },
```

```dart
              // How sessions are built
              onTap: () async {
                final next = await showOrderingSheet(
                  context: context,
                  current: settings.sessionOrdering,
                );
                if (next != null) await actions.setSessionOrdering(next);
              },
```

`SettingsHomePage` becomes a `ConsumerStatefulWidget` so the async callbacks can guard on `mounted` before touching `context` after an await. Add that guard to each: `if (!context.mounted) return;`.

- [ ] **Step 4: Add the one missing action**

`clearExamDate` does not exist yet. Add to `SettingsActions` in `settings_providers.dart`:

```dart
  /// "I don't know yet", which is a real answer rather than a refusal, so it
  /// removes both keys instead of leaving a stale precision behind.
  Future<void> clearExamDate() async {
    await _ref.read(settingsRepositoryProvider).clearExamDate();
    _ref.invalidate(userSettingsProvider);
  }
```

and to `DriftSettingsRepository`:

```dart
  Future<void> clearExamDate() async {
    await _writeAccountPrefs({
      SettingsPrefKeys.examDate: '',
      SettingsPrefKeys.examDatePrecision: '',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }
```

`ExamDate.fromStorage` already returns null for an unparseable precision, so an empty string reads back as no date.

- [ ] **Step 5: Delete the four routes**

Remove `/settings/name`, `/settings/exam-date`, `/settings/reminder` and `/settings/ordering` from `router.dart`, and remove them from the required list in `test/app/router_settings_test.dart`.

- [ ] **Step 6: Run the whole gate and commit**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
git add -A
git commit -m "feat: open the four settings sheets from their rows"
```

---

## Done when

- Tapping Name, Exam date, Daily reminder or How sessions are built raises a sheet with the ink wash behind it, and none of the four has a route.
- The exam date sheet offers an exact date, a month with the day on the dash, and "I don't know yet", and "I don't know yet" clears a date rather than dismissing.
- Saving with the day on the dash stores month precision, and the top level then reads "October 2026".
- The ordering sheet has no Save and no Cancel, and tapping a row closes it.
- The wheels never offer a month that has already finished.
- `flutter test` passes across the whole suite.
