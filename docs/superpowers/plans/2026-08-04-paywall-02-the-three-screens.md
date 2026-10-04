# Paywall 02: the three screens

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

> **Typography, amended 11 August 2026.** Any "serif" below is superseded: the
> app uses one family, Source Sans 3, everywhere. See
> `decisions/2026-08-10-typeface-log.md`.



> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**This plan is model-agnostic.** It names no harness-specific skill in its tasks. Read
`AGENTS.md` and `SUBAGENTS.md` before writing a line. Its spec is
`docs/superpowers/specs/2026-08-03-paywall-pricing-and-flow-design.md`, **as amended 4 August
2026**, and its companion `2026-08-02-pro-entitlement-consolidation-design.md`.

**Goal:** Build the three-screen paywall flow: what Pro adds with an authored sample specimen,
the plans screen with its exam-date arithmetic, and the trial timeline shown only for Yearly.

**Architecture:** Three pages behind one route, with a `PageView`-free explicit navigation so
each screen is independently testable. Screen 1 is entirely static: **it reads no student
data at all**, which is the point of the 4 August amendment. Screen 2 is the only one that
computes, and its arithmetic is pure and lives in `domain/`. Screen 3 renders a computed date.

**Tech Stack:** Flutter, Riverpod, go_router, flutter_test. No new packages.

---

## Prerequisites, and this plan stops if they are absent

**Confirm all three before Task 1. If any is missing, stop and say so.**

| Needs | From | Check |
|---|---|---|
| The three-SKU ladder, corrected recommendation and `priceAmount` | `2026-08-04-paywall-01-ladder-and-live-gateway.md` | `grep -rn "lifetime" lib` returns nothing, and `PaywallPackage` has `priceAmount` |
| `ExamDate` with precision | `2026-08-02-onboarding-flow-and-new-steps.md` **Task 1** | `lib/features/settings/domain/exam_date.dart` exists and exposes `onDay`, `inMonth`, `daysUntil`, `monthStart`, `day`, `month`, `year` |
| The type tokens in Section 7 | `2026-08-03-settings-01-the-kit.md` | `AppTextStyles` sets serif 24/700, serif 16/700, serif 14/700, sans 13/400 and sans 11.5/400 |

**Today `UserSettings.examDate` is a bare `DateTime?`.** Precision does not exist yet, and
screen 2 has three states keyed on it. **This plan cannot be started before onboarding Task 1
lands.** Do not invent an `ExamDate`, and do not fall back to `DateTime` and print a day count
for a student who only gave a month: that would be a measurement combined with an assumption,
which Section 1 of the Progress spec forbids.

---

## Global Constraints

Every task's requirements implicitly include this section.

- **Do not modify `entitlementProvider`.** `offline-posture` Task 1 owns it. The cached-wins
  rule must survive this plan untouched.
- **Do not touch `schemaVersion`.**
- **No em dashes** anywhere: copy, comments or commit messages. A colon or a comma.
- **American spelling.** practice, color, behavior, analyze, gray, center, organize.
- **Never put AI attribution in a commit message.**
- **Never print a figure this project did not measure.** The only figures on these three
  screens are the authored sample on screen 1, which is marked as a sample, and screen 2's
  arithmetic, which is a published price multiplied by a date the student asserted.
- **Exactly one board green element per screen**, and it is the button. The recommendation
  badge on screen 2 is the single permitted exception.
- **No lock icons, no blur, no banners, no interstitials, no shimmer.**
- `test/tool/paywall_boundary_test.dart` forbids `package:flutter/` in
  `lib/features/paywall/domain/`. The arithmetic in Task 3 is pure Dart.
- **Readable at 200% text scale.** No clipping, no overlap, and no text that
  carries meaning truncated to an ellipsis. Rules and rhythm may stretch.
- **Every tap target is at least 44 by 44**, using the pattern in
  `settings-01`: a smaller visual box inside a larger tappable one.
- **Color is never the only carrier.** Severity must also read as a word or a
  position.
- **Every control has a semantics label.** Icons especially: they have no text
  to read.

### Copy fixed by the spec, verbatim

Screen 1 headline and second line:

```
You'll understand yourself better with Pro.
This is an example. Pro measures every figure from your own answers.
```

Screen 1 footer fine print: `From ₱29 a week. Cancel any time.`
Screen 2 fine print: `Cancel any time. Paid through Google Play.`

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
| `lib/features/paywall/domain/pro_specimen.dart` | **Create.** The authored sample, as constants | 1 |
| `lib/features/paywall/presentation/pro_specimen_panel.dart` | **Create.** The plated Free/Pro pair with its Sample mark | 1 |
| `lib/features/paywall/presentation/what_pro_adds_page.dart` | **Create.** Screen 1 | 2 |
| `lib/features/paywall/domain/plan_cost.dart` | **Create.** Pure cost and renewal arithmetic | 3 |
| `lib/features/paywall/presentation/plans_page.dart` | **Create.** Screen 2 | 3 |
| `lib/features/paywall/presentation/plan_row.dart` | **Create.** One selectable plan row | 3 |
| `lib/features/paywall/presentation/trial_timeline_page.dart` | **Create.** Screen 3 | 4 |
| `lib/features/paywall/presentation/paywall_page.dart` | Becomes the three-screen host. Modify | 5 |
| `lib/app/router.dart` | One route builder. Modify | 5 |

---

### Task 1: The sample specimen

**Files:**
- Create: `lib/features/paywall/domain/pro_specimen.dart`
- Create: `lib/features/paywall/presentation/pro_specimen_panel.dart`
- Test: `test/features/paywall/domain/pro_specimen_test.dart`
- Test: `test/features/paywall/presentation/pro_specimen_panel_test.dart`

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: `const ProSpecimen proSpecimen` with fields `panelName`, `leftLabel`,
  `rightLabel`, `leftFigure`, `rightFigure`, `gapFigure`, `sentence`. And
  `class ProSpecimenPanel extends StatelessWidget` taking no arguments, because the specimen is
  identical for every student.

- [ ] **Step 1: Write the failing test**

Create `test/features/paywall/domain/pro_specimen_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/paywall/domain/pro_specimen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the specimen is authored and constant, never derived', () {
    expect(proSpecimen.panelName, 'Under pressure');
    expect(proSpecimen.leftLabel, 'practising');
    expect(proSpecimen.rightLabel, 'under time');
    expect(proSpecimen.leftFigure, 68);
    expect(proSpecimen.rightFigure, 54);
    expect(proSpecimen.gapFigure, 14);
  });

  test('the gap is the difference between the two figures', () {
    expect(
      proSpecimen.gapFigure,
      proSpecimen.leftFigure - proSpecimen.rightFigure,
    );
  });

  test('the sentence contains no em dash', () {
    expect(proSpecimen.sentence.contains('—'), isFalse);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/domain/pro_specimen_test.dart
```

Expected: FAIL to compile. `pro_specimen.dart` does not exist.

- [ ] **Step 3: Write the specimen**

Create `lib/features/paywall/domain/pro_specimen.dart`:

```dart
/// The screen 1 specimen. Every student sees these same figures.
///
/// Decided 4 August 2026: the paywall must not fill this panel with the
/// student's own numbers, because that gives away a real Pro insight in
/// order to sell Pro. These figures are authored and are marked as a sample
/// on screen, twice, both times above the figures themselves.
///
/// The panel name and both labels are the ones the tendency deck ships, so
/// the sample demonstrates a surface that exists. Only the figures are
/// authored.
class ProSpecimen {
  const ProSpecimen({
    required this.panelName,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftFigure,
    required this.rightFigure,
    required this.sentence,
  });

  final String panelName;
  final String leftLabel;
  final String rightLabel;
  final int leftFigure;
  final int rightFigure;
  final String sentence;

  int get gapFigure => leftFigure - rightFigure;
}

const proSpecimen = ProSpecimen(
  panelName: 'Under pressure',
  // British spelling, and deliberately so: this is the label the tendency
  // deck ships. The sample must match the surface it illustrates. Fixing
  // the label is a separate job on the deck, not on the paywall.
  leftLabel: 'practising',
  rightLabel: 'under time',
  leftFigure: 68,
  rightFigure: 54,
  sentence: 'You score 14 lower under time than practising. '
      'That is the biggest gap in your work.',
);
```

- [ ] **Step 4: Run the domain test**

```bash
flutter test test/features/paywall/domain/pro_specimen_test.dart
```

Expected: PASS, all three.

- [ ] **Step 5: Write the failing widget test**

Create `test/features/paywall/presentation/pro_specimen_panel_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/paywall/presentation/pro_specimen_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: ProSpecimenPanel())),
      ),
    );
  }

  testWidgets('marks itself as a sample in the plate, above the figures',
      (tester) async {
    await pump(tester);
    expect(find.text('Under pressure'), findsOneWidget);
    expect(find.text('Sample'), findsOneWidget);
  });

  testWidgets('prints both tier tags and both comparison labels',
      (tester) async {
    await pump(tester);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Pro'), findsOneWidget);
    expect(find.textContaining('practising'), findsWidgets);
    expect(find.textContaining('under time'), findsWidgets);
  });

  testWidgets('uses no lock icon and no card', (tester) async {
    await pump(tester);
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byType(Card), findsNothing);
  });
}
```

- [ ] **Step 6: Run it and confirm it fails**

```bash
flutter test test/features/paywall/presentation/pro_specimen_panel_test.dart
```

Expected: FAIL to compile. `pro_specimen_panel.dart` does not exist.

- [ ] **Step 7: Write the panel**

Create `lib/features/paywall/presentation/pro_specimen_panel.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/pro_specimen.dart';
import 'package:flutter/material.dart';

/// Screen 1's argument: one real gated panel, shown as a Free user sees it
/// and as Pro sees it. Both halves are the sample.
class ProSpecimenPanel extends StatelessWidget {
  const ProSpecimenPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    // The tier tag. 10/700 uppercase, exactly how the level control marks
    // its active label: muted for the inactive tier, ink for the active one.
    Widget tag(String text, {required bool active}) {
      return Text(
        text,
        style: styles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: active ? colors.ink : colors.inkMuted,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The plate. Title plus the Sample mark on one baseline, then the
        // rule. Sample is inkMuted, never board green: board green is
        // budgeted to the button, one per screen.
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(proSpecimen.panelName, style: styles.headlineSmall),
            ),
            Text(
              'Sample',
              style: styles.labelSmall.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
        Container(height: 1.6, color: colors.ink, margin: const EdgeInsets.only(top: 6)),

        const SizedBox(height: 14),
        tag('Free', active: false),
        const SizedBox(height: 5),
        Text(
          '${proSpecimen.leftLabel}  vs.  ${proSpecimen.rightLabel}',
          style: styles.headlineSmall.copyWith(
            fontSize: 14,
            color: colors.inkMuted,
          ),
        ),
        const SizedBox(height: 4),
        const FaintBars(widthFactors: [0.9, 0.65]),

        const SizedBox(height: 14),
        tag('Pro', active: true),
        const SizedBox(height: 5),
        Text(
          '${proSpecimen.leftLabel} ${proSpecimen.leftFigure}%  vs.  '
          '${proSpecimen.rightLabel} ${proSpecimen.rightFigure}%',
          style: styles.headlineSmall.copyWith(fontSize: 14),
        ),

        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The figure outranks the headline. Ink, not rust: rust is
            // reserved for a loss and this is an illustration.
            Text(
              '${proSpecimen.gapFigure}',
              style: styles.displayLarge.copyWith(fontSize: 30, height: 1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                proSpecimen.sentence,
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 8: Run the widget test**

```bash
flutter test test/features/paywall/presentation/pro_specimen_panel_test.dart
```

Expected: PASS, all three.

- [ ] **Step 9: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "feat(paywall): the specimen is an authored sample, marked before its figures"
```

---

### Task 2: Screen 1, what Pro adds

**Files:**
- Create: `lib/features/paywall/presentation/what_pro_adds_page.dart`
- Test: `test/features/paywall/presentation/what_pro_adds_page_test.dart`

**Interfaces:**
- Consumes: `ProSpecimenPanel` from Task 1.
- Produces: `class WhatProAddsPage extends StatelessWidget` taking
  `{required VoidCallback onSeePlans}`. Task 5 supplies the callback.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:cse_cet_reviewer/features/paywall/presentation/what_pro_adds_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, {VoidCallback? onSeePlans}) {
    return tester.pumpWidget(
      MaterialApp(
        home: WhatProAddsPage(onSeePlans: onSeePlans ?? () {}),
      ),
    );
  }

  testWidgets('the second line discloses the sample, above every figure',
      (tester) async {
    await pump(tester);
    expect(
      find.text(
        'This is an example. Pro measures every figure from your own answers.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('measured from your own answers'),
      findsNothing,
      reason: 'the old measurement claim must be gone',
    );
  });

  testWidgets('lists the four things Pro adds', (tester) async {
    await pump(tester);
    expect(find.text('Pro also adds'), findsOneWidget);
    expect(find.textContaining('to your wrong answers'), findsOneWidget);
    expect(find.textContaining('you keep missing'), findsOneWidget);
    expect(find.textContaining('down to the lesson'), findsOneWidget);
    expect(find.textContaining('mock exams'), findsOneWidget);
  });

  testWidgets('the CTA opens the plans screen', (tester) async {
    var tapped = 0;
    await pump(tester, onSeePlans: () => tapped++);
    await tester.tap(find.text('See plans'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('shows the fine print verbatim', (tester) async {
    await pump(tester);
    expect(find.text('From ₱29 a week. Cancel any time.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/presentation/what_pro_adds_page_test.dart
```

Expected: FAIL to compile. `what_pro_adds_page.dart` does not exist.

- [ ] **Step 3: Write the page**

```dart
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/pro_specimen_panel.dart';
import 'package:flutter/material.dart';

/// Screen 1 of three. Makes the want. Shown to everyone.
///
/// This page reads no student data. That is deliberate and it is the whole
/// of the 4 August amendment: filling the specimen from the student's own
/// answers would hand over a real Pro insight in order to sell Pro.
class WhatProAddsPage extends StatelessWidget {
  const WhatProAddsPage({required this.onSeePlans, super.key});

  final VoidCallback onSeePlans;

  static const _adds = <(String, String)>[
    ('Explanation', 'to your wrong answers'),
    ('Reasons', 'you keep missing'),
    ('Your mastery', 'down to the lesson'),
    ('Unlimited', 'mock exams'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You'll understand yourself better with Pro.",
                style: styles.displaySmall.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'This is an example. Pro measures every figure from your '
                'own answers.',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),

              const SizedBox(height: 24),
              const ProSpecimenPanel(),

              const SizedBox(height: 26),
              Text('Pro also adds', style: styles.headlineSmall),
              Container(
                height: 1.6,
                color: colors.ink,
                margin: const EdgeInsets.only(top: 6),
              ),
              const SizedBox(height: 12),
              for (final (noun, rest) in _adds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A serif plus, not an icon: the plate says "adds",
                      // so the marker restates the verb.
                      Text('+', style: styles.headlineSmall.copyWith(fontSize: 14)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: noun,
                                style: styles.headlineSmall.copyWith(fontSize: 14),
                              ),
                              TextSpan(
                                text: ' $rest',
                                style: styles.headlineSmall.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: colors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              BoardButton(label: 'See plans', onPressed: onSeePlans),
              const SizedBox(height: 9),
              Center(
                child: Text(
                  'From ₱29 a week. Cancel any time.',
                  style: styles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/paywall/presentation/what_pro_adds_page_test.dart
```

Expected: PASS, all four.

- [ ] **Step 5: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(paywall): screen 1 makes the want without reading a student's data"
```

---

### Task 3: Screen 2, the plans and their arithmetic

**A student is not choosing a price, they are choosing a term.** The app knows their exam date,
so it does the arithmetic rather than making them do it.

**Files:**
- Create: `lib/features/paywall/domain/plan_cost.dart`
- Create: `lib/features/paywall/presentation/plan_row.dart`
- Create: `lib/features/paywall/presentation/plans_page.dart`
- Test: `test/features/paywall/domain/plan_cost_test.dart`
- Test: `test/features/paywall/presentation/plans_page_test.dart`

**Interfaces:**
- Consumes: `PaywallPackage` with `priceAmount` and `recommendedSkuForExamDate`,
  `recommendationBadgeCopy`, `ctaCopyFor` from Paywall 01. `ExamDate` from onboarding Task 1.
- Produces: `PlanCost costForPackage({required PaywallPackage package, required ExamDate? examDate, required DateTime today})`
  returning `PlanCost(total, renewals, overshootDays)`, and
  `class PlansPage extends StatefulWidget`.

- [ ] **Step 1: Write the failing arithmetic test**

Create `test/features/paywall/domain/plan_cost_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/plan_cost.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 8, 2);
  final examOct12 = ExamDate.onDay(DateTime(2026, 10, 12));

  const weekly = PaywallPackage(
    sku: PaywallSku.weekly,
    productId: 'pro_weekly',
    priceString: '₱29',
    priceAmount: 29,
  );
  const monthly = PaywallPackage(
    sku: PaywallSku.monthly,
    productId: 'pro_monthly',
    priceString: '₱99',
    priceAmount: 99,
  );
  const yearly = PaywallPackage(
    sku: PaywallSku.yearly,
    productId: 'pro_yearly',
    priceString: '₱999',
    priceAmount: 999,
  );

  test('Weekly covers 71 days with 11 renewals at ₱319', () {
    final cost = costForPackage(
      package: weekly,
      examDate: examOct12,
      today: today,
    );
    expect(cost.renewals, 11);
    expect(cost.total, 319);
  });

  test('Monthly covers 71 days with 3 months at ₱297', () {
    final cost = costForPackage(
      package: monthly,
      examDate: examOct12,
      today: today,
    );
    expect(cost.renewals, 3);
    expect(cost.total, 297);
  });

  test('Yearly is one payment and runs past the exam', () {
    final cost = costForPackage(
      package: yearly,
      examDate: examOct12,
      today: today,
    );
    expect(cost.renewals, 1);
    expect(cost.total, 999);
    expect(cost.overshootDays, 294);
  });

  test('cover always reaches the exam, never stops short', () {
    // 8 days needs 2 weekly renewals, not 1.
    final cost = costForPackage(
      package: weekly,
      examDate: ExamDate.onDay(DateTime(2026, 8, 10)),
      today: today,
    );
    expect(cost.renewals, 2);
  });

  test('at month precision it computes through the last day of that month', () {
    final cost = costForPackage(
      package: monthly,
      examDate: ExamDate.inMonth(year: 2026, month: 10),
      today: today,
    );
    // 2 August to 31 October is 90 days, so 3 months.
    expect(cost.renewals, 3);
    expect(cost.total, 297);
  });

  test('with no exam date there is no total to print', () {
    final cost = costForPackage(
      package: monthly,
      examDate: null,
      today: today,
    );
    expect(cost.total, isNull);
    expect(cost.renewals, isNull);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/domain/plan_cost_test.dart
```

Expected: FAIL to compile. `plan_cost.dart` does not exist.

- [ ] **Step 3: Write the arithmetic**

Create `lib/features/paywall/domain/plan_cost.dart`. **Pure Dart, no Flutter import:** the
boundary test forbids one in `domain/`.

```dart
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';

/// What a plan costs a student to cover them through their exam.
///
/// Printing this is allowed under the evidentiary rule: it multiplies a
/// published price by a date the student asserted. Both terms are facts, so
/// it is not a measurement combined with an assumption.
class PlanCost {
  const PlanCost({this.total, this.renewals, this.overshootDays});

  /// Null when there is no exam date, because there is nothing to compute to.
  final double? total;
  final int? renewals;

  /// Days the term runs past the exam. Only meaningful for Yearly, and it is
  /// printed deliberately: it looks like it damages the most expensive SKU
  /// and it is exactly what makes the other two figures believable.
  final int? overshootDays;
}

PlanCost costForPackage({
  required PaywallPackage package,
  required ExamDate? examDate,
  required DateTime today,
}) {
  if (examDate == null) return const PlanCost();

  final days = _daysToCover(examDate: examDate, today: today);
  if (days <= 0) return const PlanCost();

  return switch (package.sku) {
    PaywallSku.weekly => _periodCost(package, days, 7),
    PaywallSku.monthly => _periodCost(package, days, 30),
    PaywallSku.yearly => PlanCost(
        total: package.priceAmount,
        renewals: 1,
        overshootDays: 365 - days,
      ),
  };
}

/// Always rounds up. A student needs cover through their exam, so a term
/// that stops one day short is the wrong answer at any price.
PlanCost _periodCost(PaywallPackage package, int days, int periodDays) {
  final renewals = (days / periodDays).ceil();
  return PlanCost(
    total: package.priceAmount * renewals,
    renewals: renewals,
  );
}

/// At month precision, compute against the last day of the stated month.
///
/// The accepted cost is up to 30 days of extra horizon, which can tip a
/// student at 9.2 months from Monthly into Yearly. It is disclosed on screen
/// by the column head, and it errs toward cover rather than toward a cheaper
/// recommendation, which is the safer direction to be wrong in.
int _daysToCover({required ExamDate examDate, required DateTime today}) {
  final target = examDate.day ?? _lastDayOfMonth(examDate.year, examDate.month);
  return target.difference(DateTime(today.year, today.month, today.day)).inDays;
}

DateTime _lastDayOfMonth(int year, int month) {
  return DateTime(year, month + 1, 0);
}
```

**`ExamDate.day` is nullable at month precision.** If the API from onboarding Task 1 spells this
differently, adapt the two lines above and **say so in your report**; do not change `ExamDate`.

- [ ] **Step 4: Run the arithmetic test**

```bash
flutter test test/features/paywall/domain/plan_cost_test.dart
```

Expected: PASS, all six.

- [ ] **Step 5: Write the failing screen test**

Create `test/features/paywall/presentation/plans_page_test.dart`:

```dart
testWidgets('at day precision the column head names the date', (tester) async {
  await pumpPlans(tester, examDate: ExamDate.onDay(DateTime(2026, 10, 12)));
  expect(find.text('Your exam is in 71 days.'), findsOneWidget);
  expect(find.text('Until 12 October'), findsOneWidget);
});

testWidgets('at month precision no day count is printed', (tester) async {
  await pumpPlans(tester, examDate: ExamDate.inMonth(year: 2026, month: 10));
  expect(find.text('Your exam is in October 2026.'), findsOneWidget);
  expect(find.text('Through October'), findsOneWidget);
  expect(find.textContaining('days.'), findsNothing);
});

testWidgets('with no date the head reads Price and the badge reads Best for most',
    (tester) async {
  await pumpPlans(tester, examDate: null);
  expect(find.text('Choose how long you need it.'), findsOneWidget);
  expect(find.text('Price'), findsOneWidget);
  expect(find.text('Best for most'), findsOneWidget);
});

testWidgets('the rows are always Weekly, Monthly, Yearly in that order',
    (tester) async {
  await pumpPlans(tester, examDate: ExamDate.onDay(DateTime(2026, 10, 12)));
  final weekly = tester.getTopLeft(find.text('Weekly')).dy;
  final monthly = tester.getTopLeft(find.text('Monthly')).dy;
  final yearly = tester.getTopLeft(find.text('Yearly')).dy;
  expect(weekly < monthly && monthly < yearly, isTrue);
});

testWidgets('Yearly states that it runs past the exam', (tester) async {
  await pumpPlans(tester, examDate: ExamDate.onDay(DateTime(2026, 10, 12)));
  expect(find.text('294 days past your exam'), findsOneWidget);
});

testWidgets('the fine print is verbatim', (tester) async {
  await pumpPlans(tester, examDate: null);
  expect(find.text('Cancel any time. Paid through Google Play.'), findsOneWidget);
});
```

Write `pumpPlans` as a local helper that pumps `PlansPage` inside a `MaterialApp` with the
three packages from Step 1 and `today: DateTime(2026, 8, 2)`.

- [ ] **Step 6: Run it and confirm it fails**

```bash
flutter test test/features/paywall/presentation/plans_page_test.dart
```

Expected: FAIL to compile. `plans_page.dart` does not exist.

- [ ] **Step 7: Write `plan_row.dart`, then `plans_page.dart`**

`plan_row.dart` renders one row: a 12px selection ring, the term spelled out in plain words,
the right-hand figure, and an optional badge. **Selection is a ring plus a 1.6px `ink` bottom
rule on the chosen row. Never a tinted fill and never a rounded box.**

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PlanRow extends StatelessWidget {
  const PlanRow({
    required this.title,
    required this.termLine,
    required this.rightFigure,
    required this.selected,
    required this.onTap,
    this.badge,
    this.footnote,
    super.key,
  });

  final String title;
  final String termLine;
  final String rightFigure;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? colors.ink : colors.rule,
              width: selected ? 1.6 : 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 3, right: 11),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.ink, width: 1.4),
                color: selected ? colors.ink : Colors.transparent,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: styles.headlineSmall.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    termLine,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      badge!,
                      style: styles.labelSmall.copyWith(color: colors.board),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(rightFigure, style: styles.headlineSmall.copyWith(fontSize: 14)),
                if (footnote != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    footnote!,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

`plans_page.dart` composes the headline, the column head, three `PlanRow`s in fixed order, the
CTA from `ctaCopyFor`, and the fine print. The three headline and column-head states come
straight from the spec:

| Precision | Headline | Right column head |
|---|---|---|
| day | `Your exam is in 71 days.` | `Until 12 October` |
| month | `Your exam is in October 2026.` | `Through October` |
| none | `Choose how long you need it.` | `Price` |

**With no date the right column carries effective-monthly figures instead**, `≈₱126` and
`≈₱83`, plus one line of fine print: `Tell us your exam date and we will show what each plan
costs you.` That is the only nudge on the screen and it offers something rather than asking for
something.

**The badge renders on the recommended row only, and it is the one board green element other
than the button.**

- [ ] **Step 8: Run the tests**

```bash
flutter test test/features/paywall/presentation/plans_page_test.dart
```

Expected: PASS, all six.

- [ ] **Step 9: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "feat(paywall): the plans screen does the arithmetic so the student does not"
```

---

### Task 4: Screen 3, the trial timeline

**Shown only when Yearly is chosen**, because it is the only SKU with a trial.

**Files:**
- Create: `lib/features/paywall/presentation/trial_timeline_page.dart`
- Test: `test/features/paywall/presentation/trial_timeline_page_test.dart`

**Interfaces:**
- Consumes: nothing from Tasks 1 to 3.
- Produces: `class TrialTimelinePage extends StatelessWidget` taking
  `{required DateTime today, required String yearlyPrice, required VoidCallback onStart}`.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('prints the charge date, never a relative phrase', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TrialTimelinePage(
        today: DateTime(2026, 8, 3),
        yearlyPrice: '₱999',
        onStart: () {},
      ),
    ),
  );
  expect(find.textContaining('10 August 2026'), findsOneWidget);
  expect(find.textContaining('in 7 days'), findsNothing);
});

testWidgets('names the price twice, in the lede and on day 7', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TrialTimelinePage(
        today: DateTime(2026, 8, 3),
        yearlyPrice: '₱999',
        onStart: () {},
      ),
    ),
  );
  expect(find.textContaining('₱999'), findsNWidgets(2));
});

testWidgets('has three marks and no icons in them', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TrialTimelinePage(
        today: DateTime(2026, 8, 3),
        yearlyPrice: '₱999',
        onStart: () {},
      ),
    ),
  );
  expect(find.text('Today'), findsOneWidget);
  expect(find.text('Day 5'), findsOneWidget);
  expect(find.text('Day 7'), findsOneWidget);
  expect(find.byType(Icon), findsNothing);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/presentation/trial_timeline_page_test.dart
```

Expected: FAIL to compile.

- [ ] **Step 3: Write the page**

The composition, verbatim from the spec:

```
How your free trial works
Full access to everything in Pantas. The first 7 days are free, then ₱999 a year.

  ○  Today    Everything unlocks. Every explanation, every level of your
              progress, and mock exams with no waiting.

  ○  Day 5    We remind you here in the app that the trial is ending.

  ○  Day 7    Your first charge of ₱999 begins on 10 August 2026.
              Cancel any time before then and you pay nothing.

              [ Start my free trial ]
              No commitment. Cancel any time.
```

**Drawing rules, all of them binding.** A vertical 1px `rule` with three unfilled hairline
marks, not a card stack and not a stepper. Day labels serif 14/700, bodies sans 11.5
`inkMuted`. **The date is computed and printed, never "in 7 days"**, because a named date is
what makes the disclosure checkable. The price appears twice, deliberately. One board button.
No em dashes, no emoji, no icons in the marks.

Compute the charge date as `today.add(const Duration(days: 7))` and format it as
`10 August 2026`.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/paywall/presentation/trial_timeline_page_test.dart
```

Expected: PASS, all three.

- [ ] **Step 5: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(paywall): the trial screen names the date it will charge"
```

---

### Task 5: The flow

**Files:**
- Modify: `lib/features/paywall/presentation/paywall_page.dart`
- Modify: `lib/app/router.dart:242-243`
- Test: `test/features/paywall/presentation/paywall_page_test.dart`

**Interfaces:**
- Consumes: all three pages from Tasks 2 to 4, `paywallControllerProvider` and
  `paywallPackagesProvider` as they already stand.
- Produces: `PaywallPage` hosting the three screens in order.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('starts on screen 1 and See plans advances to screen 2',
    (tester) async {
  await pumpPaywall(tester);
  expect(find.text('Pro also adds'), findsOneWidget);
  await tester.tap(find.text('See plans'));
  await tester.pumpAndSettle();
  expect(find.text('Weekly'), findsOneWidget);
});

testWidgets('choosing Yearly routes through the trial screen', (tester) async {
  await pumpPaywall(tester);
  await tester.tap(find.text('See plans'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Yearly'));
  await tester.pump();
  await tester.tap(find.text('Start my free trial'));
  await tester.pumpAndSettle();
  expect(find.text('How your free trial works'), findsOneWidget);
});

testWidgets('choosing Monthly goes straight to purchase, with no trial screen',
    (tester) async {
  var purchased = 0;
  await pumpPaywall(tester, onPurchase: (_) async {
    purchased++;
    return const PaywallCommandResult(entitlement: Entitlement.free());
  });
  await tester.tap(find.text('See plans'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Monthly'));
  await tester.pump();
  await tester.tap(find.textContaining('Get Pro.'));
  await tester.pumpAndSettle();
  expect(find.text('How your free trial works'), findsNothing);
  expect(purchased, 1);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/paywall/presentation/paywall_page_test.dart
```

Expected: FAIL. `PaywallPage` is still the old single screen.

- [ ] **Step 3: Rebuild `PaywallPage` as the host**

Hold an enum of the three screens in state and switch on it. Screen 3 is reachable **only**
when the selected SKU is `PaywallSku.yearly`. From screen 3's button, and from screen 2's
button for the other two SKUs, call `onPurchase`.

**Keep the existing `returnTo`, `onRestore` and `onPurchase` parameters.** The router already
passes them and `_isProRoute` already redirects a Free user here, so entry stays contextual and
this plan does not touch the redirect.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/paywall/presentation/paywall_page_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(paywall): three screens in order, and the trial step only for Yearly"
```

---

## Verification for the whole plan

```bash
grep -rn "measured from your own answers" lib
```

Expected: **nothing.** The claim was replaced when the specimen became a sample.

- **Screen 1 reads no student data.** No provider on that page touches attempts, sessions or
  mock attempts. Grep the file for `ref.watch` and find nothing that reaches a repository.
- The specimen shows the same figures on a fresh install and on a well-used account.
- `Sample` appears in the plate, and renders in `inkMuted`, not board green.
- Screen 1 has exactly one board green element, the button. Screen 2 has two, the button and
  the badge. Screen 3 has one.
- A student with an exam six months out is recommended Monthly, badged `Best for your exam
  date`.
- A student with no date is recommended Monthly, badged `Best for most`, and no screen prints a
  total.
- At month precision no screen prints a day count, and the column head names the month it
  computed through.
- The three totals equal price times whole renewal periods to the stated date. **No figure is
  rounded in the app's favor.**
- Screen 3 appears only when Yearly is chosen.
- `grep -rn "—" lib/features/paywall` returns nothing.
