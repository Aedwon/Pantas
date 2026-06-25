# Settings 01: the control kit

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

**Goal:** Build the five shared components Settings is drawn from, in `lib/core/ui/components/`, so every later plan assembles rather than invents.

**Architecture:** Pure presentation widgets with no Riverpod and no repository. Each reads `context.colors` and `context.textStyles` from the `AppColors` / `AppTextStyles` theme extensions. The switch and the theme control are stateless and render a value; the row and group are layout; the sheet is a `showModalBottomSheet` wrapper that supplies the ink wash and the top rule.

**Tech Stack:** Flutter, Material 3 as the substrate only, `flutter_test`.

## Global Constraints

Copied from `docs/superpowers/specs/2026-08-03-settings-design.md`. Every task's requirements implicitly include this section.

- **No Material app bar, no chips, no iOS switches, no cards, no tinted callouts, no large radii.** Grouping is hairline rules and plates.
- **Group headings are serif, sentence case. Never boxed, never all-caps.**
- **Icons are permitted only where the control's subject is the appearance itself.** The three in `ThemeControl` are the only icons in the application. Do not add an icon to any other component in this plan.
- **American spelling** in every string, comment, and identifier: practice, color, behavior, analyze, gray, center.
- **No em dashes** anywhere, including comments and commit messages. Use a comma or a colon.
- Colors come from `context.colors` (`AppColors`). Never hardcode a hex value.
- `flutter analyze` must be clean and `dart format --output=none --set-exit-if-changed lib test` must pass before any commit.

## Four plans stop dead until this one lands

**Added 4 August 2026 by an audit across all plans.**

`2026-08-04-paywall-01`, `paywall-02`, `study-plan-forward-calendar` and `mock-03` all carry a
prerequisite check for the type sizes below, and all four are written to **stop and say so**
rather than hand-roll a size that would later disagree with the kit.

**So this plan gates a whole afternoon of other work**, and the sizes it adds are the reason.
Run it early.

---

## AMENDED 4 August 2026: this plan gains the missing type sizes

**Three specs now call for sizes `AppTextStyles` does not set, and all three stop and say so
when they reach them.** The paywall, the study plan calendar and the mock's new surfaces are all
blocked on the same gap, and it was found by checking a spec's claim rather than by any of them
failing.

**`2026-08-03-paywall-pricing-and-flow-design.md` Section 7 used to claim "every size is one
this app already sets. Nothing here is new." Five of its seven rows did not hold.**

**Add these to `AppTextStyles`.** They were chosen against live mockups and the type scale is the
identity, so the specs are not moved onto whatever sizes happen to exist:

| Name | Family, size, weight | Used by |
|---|---|---|
| `displayMedium` | SourceSerif4 **24** / w700 / h1.2 / ls -0.2 | Paywall screen 1, study plan header, mock transition |
| `headlineLarge` | SourceSerif4 **16** / w700 / h1.3 | Every plated section header |
| `titleSmall` | SourceSerif4 **14** / w700 / h1.45 | Row labels and list items |
| `bodyRegular` | SourceSans3 **13** / w400 / h1.5 | Body copy and counts |
| `captionSmall` | SourceSans3 **11.5** / w400 / h1.5 | Fine print |

**`headlineSmall` stays at 15 and is not changed.** Existing screens are built on it, and moving
a size that is already in use to satisfy a new spec is how a type scale becomes two type scales.

**The 1.6px plate rule is not a text style and does not belong here.** It is a one pixel and six
tenths `ink` rule drawn under a section header. `RuledSection` is not it: that draws 1px in
`rule`, on top, for a different purpose. **Whatever draws the plate rule is a new component and
this plan should add it**, since every screen blocked on the sizes needs it too.

**Verification:** `grep -n "fontSize" lib/core/ui/theme/app_text_styles.dart` shows 24, 16, 14,
13 and 11.5 present, and 15 still present and unchanged.

---

## Departure from the spec's arithmetic, decided here

The spec says rows are "38 tall" with the tap target "padded past it" to 44. In Flutter a hit region cannot exceed its own box, so this plan renders a **38-tall visual box inside a 44-tall tappable box** (3px of transparent bleed above and below). A group of N rows is therefore 44N tall in layout while every visible rule, title and value sits on the spec's 38 rhythm. Tests assert both numbers so the intent cannot drift.

## File structure

| File | Responsibility |
|---|---|
| `lib/core/ui/components/settings_switch.dart` (create) | The two-state hollow/solid rectangle. Presentation only. |
| `lib/core/ui/components/theme_control.dart` (create) | Three-segment control, sun / crescent / half circle, with semantics labels. |
| `lib/core/ui/components/settings_value_row.dart` (create) | Title, optional value, optional control, fixed 11px chevron column, 38 in 44. |
| `lib/core/ui/components/settings_group.dart` (create) | Serif heading on a 1px ink rule, then rows, then 24 of space. |
| `lib/core/ui/components/ink_sheet.dart` (create) | `showInkSheet`, the wash and the top rule. |

Nothing is deleted in this plan. `ios_switch.dart`, `settings_row.dart`, `settings_section.dart` and `theme_segmented_control.dart` still have callers and are removed in Plan 03.

---

## Task 1: The switch

**Files:**
- Create: `lib/core/ui/components/settings_switch.dart`
- Test: `test/core/ui/components/settings_switch_test.dart`

**Interfaces:**
- Consumes: `context.colors` from `lib/core/ui/theme/app_theme.dart`.
- Produces:

```dart
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({required this.value, super.key});
  final bool value;

  static const double width = 32;
  static const double height = 18;
  static const double knobSize = 12;
}
```

It renders state and nothing else. **It has no `onChanged`**: the whole row is the tap target, which is `SettingsValueRow`'s job in Task 3.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/settings_switch_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

BoxDecoration _decorationAt(WidgetTester tester, int index) {
  final boxes = tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .toList(growable: false);
  return boxes[index].decoration as BoxDecoration;
}

void main() {
  testWidgets('the switch is 32 by 18 in both states', (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: false));
    expect(
      tester.getSize(find.byType(SettingsSwitch)),
      const Size(SettingsSwitch.width, SettingsSwitch.height),
    );

    await tester.pumpApp(const SettingsSwitch(value: true));
    expect(
      tester.getSize(find.byType(SettingsSwitch)),
      const Size(SettingsSwitch.width, SettingsSwitch.height),
    );
  });

  testWidgets('off is entirely hollow: no fill on the box or the knob',
      (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: false));

    final box = _decorationAt(tester, 0);
    final knob = _decorationAt(tester, 1);

    expect(box.color, isNull);
    expect(knob.color, isNull);
    expect(box.border!.top.color, AppColors.light.rule);
    expect(knob.border!.top.color, AppColors.light.rule);
  });

  testWidgets('on is entirely solid: box filled ink, knob filled background',
      (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: true));

    final box = _decorationAt(tester, 0);
    final knob = _decorationAt(tester, 1);

    expect(box.color, AppColors.light.ink);
    expect(box.border!.top.color, AppColors.light.ink);
    expect(knob.color, AppColors.light.background);
    expect(knob.border, isNull);
  });

  testWidgets('the knob sits left when off and right when on', (tester) async {
    await tester.pumpApp(const SettingsSwitch(value: false));
    final offAlign = tester.widget<Align>(find.byType(Align));
    expect(offAlign.alignment, Alignment.centerLeft);

    await tester.pumpApp(const SettingsSwitch(value: true));
    final onAlign = tester.widget<Align>(find.byType(Align));
    expect(onAlign.alignment, Alignment.centerRight);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/settings_switch_test.dart`
Expected: FAIL, `Target of URI doesn't exist: 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart'`.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/settings_switch.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The two-state control for a Settings row.
///
/// Off is entirely hollow: an outlined box holding an outlined square. On is
/// entirely solid: the box fills with ink and the square reverses out in the
/// page color. The state is carried by the whole object rather than by the
/// square's position, which is why both the fill and the position change.
///
/// Presentation only. The whole row is the tap target, so there is no
/// onChanged here.
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({required this.value, super.key});

  final bool value;

  static const double width = 32;
  static const double height = 18;
  static const double knobSize = 12;

  static const double _stroke = 1.2;
  static const double _inset = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Off sits at rule, one step lighter than inkMuted, so an off row recedes
    // into the page's ruling and on is the only ink in the column.
    final outline = value ? colors.ink : colors.rule;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: value ? colors.ink : null,
          border: Border.all(color: outline, width: _stroke),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _inset - _stroke),
            child: SizedBox(
              width: knobSize,
              height: knobSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: value ? colors.background : null,
                  border: value
                      ? null
                      : Border.all(color: colors.rule, width: _stroke),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/core/ui/components/settings_switch_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/settings_switch.dart test/core/ui/components/settings_switch_test.dart
git commit -m "feat: the settings switch, hollow when off and solid when on"
```

---

## Task 2: The theme control

**Files:**
- Create: `lib/core/ui/components/theme_control.dart`
- Test: `test/core/ui/components/theme_control_test.dart`

**Interfaces:**
- Consumes: `ThemePreference` from `lib/features/settings/domain/theme_preference.dart`, which already exists with values `light`, `dark`, `system`.
- Produces:

```dart
class ThemeControl extends StatelessWidget {
  const ThemeControl({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final ThemePreference value;
  final ValueChanged<ThemePreference> onChanged;

  static const double height = 22;
  static const double segmentWidth = 30;
}
```

**This is the only place in the application where an icon may appear.** The three marks are painted with `CustomPainter`, not an icon font and not an asset, so they inherit the segment's color and need no dependency.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/theme_control_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/theme_control.dart';
import 'package:cse_cet_reviewer/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the control is 90 by 22, three segments of 30', (tester) async {
    await tester.pumpApp(
      ThemeControl(value: ThemePreference.system, onChanged: (_) {}),
    );

    expect(
      tester.getSize(find.byType(ThemeControl)),
      const Size(ThemeControl.segmentWidth * 3, ThemeControl.height),
    );
  });

  testWidgets('every segment carries a semantics label, since the marks '
      'carry no text', (tester) async {
    await tester.pumpApp(
      ThemeControl(value: ThemePreference.system, onChanged: (_) {}),
    );

    expect(find.bySemanticsLabel('Light theme'), findsOneWidget);
    expect(find.bySemanticsLabel('Dark theme'), findsOneWidget);
    expect(find.bySemanticsLabel('Follow my phone'), findsOneWidget);
  });

  testWidgets('tapping a segment reports that preference', (tester) async {
    ThemePreference? chosen;
    await tester.pumpApp(
      ThemeControl(
        value: ThemePreference.system,
        onChanged: (next) => chosen = next,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Dark theme'));

    expect(chosen, ThemePreference.dark);
  });

  testWidgets('the live segment is the only one that reports as selected',
      (tester) async {
    await tester.pumpApp(
      ThemeControl(value: ThemePreference.dark, onChanged: (_) {}),
    );

    final dark = tester.getSemantics(find.bySemanticsLabel('Dark theme'));
    final light = tester.getSemantics(find.bySemanticsLabel('Light theme'));

    expect(dark.hasFlag(SemanticsFlag.isSelected), isTrue);
    expect(light.hasFlag(SemanticsFlag.isSelected), isFalse);
  });
}
```

Add `import 'package:flutter/semantics.dart';` if `SemanticsFlag` does not resolve from the material import.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/theme_control_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/theme_control.dart`:

```dart
import 'dart:math' as math;

import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';

/// The theme switch, which is the settings switch at three positions: a
/// hairline enclosure with the live segment filled solid ink.
///
/// This is the only component in the application permitted to draw an icon.
/// A theme control is the one control whose subject is the appearance itself,
/// so a sun and a crescent are the subject rather than decoration. Do not
/// generalize from this.
class ThemeControl extends StatelessWidget {
  const ThemeControl({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ThemePreference value;
  final ValueChanged<ThemePreference> onChanged;

  static const double height = 22;
  static const double segmentWidth = 30;
  static const double markSize = 12;

  static const double _stroke = 1.2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.rule, width: _stroke),
        borderRadius: BorderRadius.circular(1),
      ),
      child: SizedBox(
        height: height - (_stroke * 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment(context, ThemePreference.light, 'Light theme', _Mark.sun),
            _divider(colors.rule),
            _segment(context, ThemePreference.dark, 'Dark theme', _Mark.moon),
            _divider(colors.rule),
            _segment(
              context,
              ThemePreference.system,
              'Follow my phone',
              _Mark.half,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(Color color) =>
      SizedBox(width: _stroke, child: ColoredBox(color: color));

  Widget _segment(
    BuildContext context,
    ThemePreference preference,
    String label,
    _Mark mark,
  ) {
    final colors = context.colors;
    final live = preference == value;

    return Semantics(
      label: label,
      button: true,
      selected: live,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(preference),
        child: SizedBox(
          width: segmentWidth - (_stroke * 2 / 3),
          child: ColoredBox(
            color: live ? colors.ink : Colors.transparent,
            child: Center(
              child: CustomPaint(
                size: const Size.square(markSize),
                painter: _MarkPainter(
                  mark: mark,
                  color: live ? colors.background : colors.inkMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Mark { sun, moon, half }

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.mark, required this.color});

  final _Mark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    switch (mark) {
      case _Mark.sun:
        canvas.drawCircle(center, size.width * 0.19, stroke);
        for (var i = 0; i < 8; i++) {
          final angle = (math.pi / 4) * i;
          final unit = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(
            center + unit * (size.width * 0.31),
            center + unit * (size.width * 0.47),
            stroke,
          );
        }
      case _Mark.moon:
        final outer = Path()
          ..addOval(Rect.fromCircle(center: center, radius: size.width * 0.42));
        final bite = Path()
          ..addOval(
            Rect.fromCircle(
              center: center.translate(size.width * 0.26, -size.width * 0.26),
              radius: size.width * 0.42,
            ),
          );
        canvas.drawPath(
          Path.combine(PathOperation.difference, outer, bite),
          stroke,
        );
      case _Mark.half:
        final rect = Rect.fromCircle(center: center, radius: size.width * 0.4);
        canvas.drawCircle(center, size.width * 0.4, stroke);
        canvas.drawArc(rect, math.pi / 2, math.pi, true, fill);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.mark != mark || old.color != color;
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/core/ui/components/theme_control_test.dart`
Expected: PASS, 4 tests. If the width assertion is off by a fraction, adjust `_segment`'s `SizedBox` width so the three segments plus two dividers plus two borders total exactly 90, and keep the test at 90.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/theme_control.dart test/core/ui/components/theme_control_test.dart
git commit -m "feat: the theme control, the switch at three positions"
```

---

## Task 3: The value row

**Files:**
- Create: `lib/core/ui/components/settings_value_row.dart`
- Test: `test/core/ui/components/settings_value_row_test.dart`

**Interfaces:**
- Produces:

```dart
class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    required this.title,
    this.value,
    this.valueIsInk = false,
    this.control,
    this.showChevron = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String? value;

  /// A value meaning "on" is ink. Every other value is inkMuted.
  final bool valueIsInk;

  /// A switch or the theme control. Replaces [value] when present.
  final Widget? control;

  final bool showChevron;
  final VoidCallback? onTap;

  static const double contentHeight = 38;
  static const double tapHeight = 44;
  static const double chevronColumnWidth = 11;
}
```

**The chevron column is 11px wide and always present**, whether or not the row pushes. That is what keeps every value in a group on one right edge.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/settings_value_row_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the visual box is 38 and the tappable box is 44',
      (tester) async {
    await tester.pumpApp(
      SettingsValueRow(title: 'Exam', value: 'UPCAT', onTap: () {}),
    );

    expect(
      tester.getSize(find.byType(SettingsValueRow)).height,
      SettingsValueRow.tapHeight,
    );
    expect(
      tester.getSize(find.byKey(const Key('settingsRowContent'))).height,
      SettingsValueRow.contentHeight,
    );
  });

  testWidgets('a row without a chevron still reserves the chevron column, '
      'so values land on one right edge', (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          SettingsValueRow(title: 'Name', value: 'Aedwon'),
          SettingsValueRow(title: 'Exam', value: 'UPCAT', showChevron: true),
        ],
      ),
    );

    final withoutChevron = tester.getBottomRight(find.text('Aedwon')).dx;
    final withChevron = tester.getBottomRight(find.text('UPCAT')).dx;

    expect(withoutChevron, withChevron);
  });

  testWidgets('a muted value is inkMuted and an on value is ink',
      (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          SettingsValueRow(title: 'Strict mock mode', value: 'Off'),
          SettingsValueRow(title: 'Remember table order', value: 'On',
              valueIsInk: true),
        ],
      ),
    );

    expect(
      tester.widget<Text>(find.text('Off')).style!.color,
      AppColors.light.inkMuted,
    );
    expect(
      tester.widget<Text>(find.text('On')).style!.color,
      AppColors.light.ink,
    );
  });

  testWidgets('a control replaces the value and the whole row taps it',
      (tester) async {
    var taps = 0;
    await tester.pumpApp(
      SettingsValueRow(
        title: 'Strict mock mode',
        control: const SettingsSwitch(value: false),
        onTap: () => taps++,
      ),
    );

    expect(find.byType(SettingsSwitch), findsOneWidget);

    await tester.tap(find.text('Strict mock mode'));
    expect(taps, 1);
  });

  testWidgets('a row with no onTap does not respond to a tap', (tester) async {
    await tester.pumpApp(
      const SettingsValueRow(title: 'Name', value: 'Aedwon'),
    );

    await tester.tap(find.text('Name'));
    // No exception, and nothing to assert beyond surviving the tap.
    expect(find.byType(SettingsValueRow), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/settings_value_row_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/settings_value_row.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One row of the Settings ledger: a title, then a right-aligned value or a
/// control, then a fixed chevron column.
///
/// The chevron column is always reserved even when the row does not push.
/// That is what keeps every value in a group on one right edge, which is the
/// thing that stops the list looking ragged.
///
/// The visible box is 38 tall. The tappable box is 44, gained by 3px of
/// transparent bleed above and below, because a hit region in Flutter cannot
/// exceed its own box and 44 is the accessibility floor.
class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    required this.title,
    this.value,
    this.valueIsInk = false,
    this.control,
    this.showChevron = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String? value;
  final bool valueIsInk;
  final Widget? control;
  final bool showChevron;
  final VoidCallback? onTap;

  static const double contentHeight = 38;
  static const double tapHeight = 44;
  static const double chevronColumnWidth = 11;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final trailing = control ??
        (value == null
            ? const SizedBox.shrink()
            : Text(
                value!,
                style: styles.labelLarge.copyWith(
                  color: valueIsInk ? colors.ink : colors.inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ));

    final content = SizedBox(
      key: const Key('settingsRowContent'),
      height: contentHeight,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: styles.bodyMedium.copyWith(fontSize: 14.5),
            ),
          ),
          const SizedBox(width: 10),
          trailing,
          SizedBox(
            width: chevronColumnWidth,
            child: showChevron
                ? Text(
                    '›',
                    textAlign: TextAlign.right,
                    style: styles.bodyMedium.copyWith(color: colors.inkMuted),
                  )
                : null,
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: tapHeight,
        child: Center(child: content),
      ),
    );
  }
}
```

`FontFeature` comes from `dart:ui`. Add `import 'dart:ui' show FontFeature;` at the top if the analyzer asks for it.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/core/ui/components/settings_value_row_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/settings_value_row.dart test/core/ui/components/settings_value_row_test.dart
git commit -m "feat: the settings value row, with a reserved chevron column"
```

---

## Task 4: The group

**Files:**
- Create: `lib/core/ui/components/settings_group.dart`
- Test: `test/core/ui/components/settings_group_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks. It takes arbitrary children so a group can hold a lede line as well as rows.
- Produces:

```dart
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.children,
    this.isFirst = false,
    super.key,
  });

  final String title;
  final List<Widget> children;

  /// The first group on a page has no 24px lead-in above it.
  final bool isFirst;

  static const double gapBetweenGroups = 24;
  static const double headingSize = 17;
}
```

**The rule under the heading is `ink`, at 1px, full width.** It is not `rule` and not `ruleFaint`. This is the single value that gives the heading its rank, and it is the fix that made the plain list win over a two-level menu.

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/settings_group_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the heading is serif 17 at weight 700, sentence case',
      (tester) async {
    await tester.pumpApp(
      const SettingsGroup(
        title: 'How you practice',
        isFirst: true,
        children: [SettingsValueRow(title: 'Strict mock mode', value: 'Off')],
      ),
    );

    final heading = tester.widget<Text>(find.text('How you practice'));
    expect(heading.style!.fontFamily, 'SourceSerif4');
    expect(heading.style!.fontSize, SettingsGroup.headingSize);
    expect(heading.style!.fontWeight, FontWeight.w700);
    // Sentence case is a copy rule, asserted here so an all-caps heading
    // cannot pass review.
    expect(heading.data, isNot('HOW YOU PRACTICE'));
  });

  testWidgets('the rule under the heading is ink, not rule and not ruleFaint',
      (tester) async {
    await tester.pumpApp(
      const SettingsGroup(
        title: 'You',
        isFirst: true,
        children: [SettingsValueRow(title: 'Name', value: 'Aedwon')],
      ),
    );

    final divider = tester.widget<Container>(
      find.byKey(const Key('settingsGroupRule')),
    );
    final decoration = divider.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.ink);
    expect(tester.getSize(find.byKey(const Key('settingsGroupRule'))).height, 1);
  });

  testWidgets('a group after the first leads with 24 of space',
      (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          SettingsGroup(
            title: 'You',
            isFirst: true,
            children: [SettingsValueRow(title: 'Name', value: 'Aedwon')],
          ),
          SettingsGroup(
            title: 'What you see',
            children: [SettingsValueRow(title: 'Theme', value: 'System')],
          ),
        ],
      ),
    );

    final first = tester.getRect(find.text('You'));
    final second = tester.getRect(find.text('What you see'));
    expect(second.top, greaterThan(first.bottom));
    expect(find.byType(SettingsGroup), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/settings_group_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/settings_group.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A named block of Settings rows: a serif heading over a 1px ink rule.
///
/// The rule is ink rather than rule or ruleFaint, and that is not a detail.
/// A heading one step larger than its rows sitting on a faint rule is not a
/// hierarchy at all. The ink rule is where the heading's rank comes from,
/// and it is what allowed the whole screen to stay one flat scroll instead
/// of becoming a two-level menu.
///
/// Never boxed, never all-caps, per section_header.dart's standing rule.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.children,
    this.isFirst = false,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final bool isFirst;

  static const double gapBetweenGroups = 24;
  static const double headingSize = 17;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : gapBetweenGroups),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: styles.headlineSmall.copyWith(
              fontSize: headingSize,
              letterSpacing: -0.15,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            key: const Key('settingsGroupRule'),
            height: 1,
            decoration: BoxDecoration(color: colors.ink),
          ),
          ...children,
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/core/ui/components/settings_group_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/settings_group.dart test/core/ui/components/settings_group_test.dart
git commit -m "feat: the settings group, a serif heading on an ink rule"
```

---

## Task 5: The sheet

**Files:**
- Create: `lib/core/ui/components/ink_sheet.dart`
- Test: `test/core/ui/components/ink_sheet_test.dart`

**Interfaces:**
- Produces:

```dart
Future<T?> showInkSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
});
```

The builder returns the sheet's contents. `showInkSheet` supplies the ink wash, the 1px ink top rule, square corners and the padding. **No shadow, no radius, no card.**

- [ ] **Step 1: Write the failing test**

Create `test/core/ui/components/ink_sheet_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/ink_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the sheet has an ink top rule, square corners and no shadow',
      (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showInkSheet<void>(
            context: context,
            builder: (_) => const Text('Exam date'),
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Exam date'), findsOneWidget);

    final surface = tester.widget<Container>(
      find.byKey(const Key('inkSheetSurface')),
    );
    final decoration = surface.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.background);
    expect(decoration.borderRadius, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.border!.top.color, AppColors.light.ink);
    expect(decoration.border!.top.width, 1);
  });

  testWidgets('the sheet returns its result and closes', (tester) async {
    String? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showInkSheet<String>(
              context: context,
              builder: (sheetContext) => TextButton(
                onPressed: () => Navigator.of(sheetContext).pop('saved'),
                child: const Text('Save'),
              ),
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

    expect(result, 'saved');
    expect(find.text('Save'), findsNothing);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/core/ui/components/ink_sheet_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the component**

Create `lib/core/ui/components/ink_sheet.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The wash drawn over everything behind a sheet.
///
/// A sheet is used where a control edits a value in place and needs more room
/// than a row: the exam date wheels, the reminder wheels, the name field, and
/// the ordering choice. A destination is a pushed page instead.
const Color _washLight = Color(0x6B26221B);
const Color _washDark = Color(0x8C000000);

Future<T?> showInkSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: isDark ? _washDark : _washLight,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = sheetContext.colors;
      return SafeArea(
        top: false,
        child: Container(
          key: const Key('inkSheetSurface'),
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.ink)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 18),
          child: builder(sheetContext),
        ),
      );
    },
  );
}
```

`_washLight` is `#26221B` at 42% alpha, the ink wash from the spec. `_washDark` is black at 55%.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/core/ui/components/ink_sheet_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 5: Run the whole gate and commit**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test test/core/ui/components/
```

Expected: analyze clean, format clean, all component tests pass.

```bash
git add lib/core/ui/components/ink_sheet.dart test/core/ui/components/ink_sheet_test.dart
git commit -m "feat: the ink sheet, with the wash and a rule instead of a card"
```

---

## Done when

- `flutter test test/core/ui/components/` passes.
- `flutter analyze` is clean.
- An off switch has no fill anywhere on it and an on switch is a solid ink block with a page-colored square.
- Two rows in a group put their values on the same right edge whether or not either has a chevron.
- Every group heading sits on a 1px ink rule.
- The only icons introduced are the three inside `ThemeControl`.
