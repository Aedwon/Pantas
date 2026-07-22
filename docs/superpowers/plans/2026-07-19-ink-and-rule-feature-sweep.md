# Ink & Rule Feature Sweep (Plan 2B) Implementation Plan

> **Typography, amended 11 August 2026.** Any "serif" below is superseded: the
> app uses one family, Source Sans 3, everywhere. See
> `decisions/2026-08-10-typeface-log.md`.



> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the Ink & Rule identity to every remaining feature surface (quiz, assessment, study/lesson, study plan, mock exam, onboarding, notifications, paywall, wrapped, legal, settings), then remove the transitional `AppColors` aliases, legacy dimension tokens, and dead pre-identity components.

**Architecture:** Visual sweep on existing data and behavior — every screen keeps its information, providers, and routes. New shared devices (AnswerRow, FaintBars, restyled ErrorBanner/EmptyState/ConfirmationDialog, theme surface defaults) land first; feature sweeps compose them; cleanup lands last so the build stays green throughout. `auth_flow` and `review` have no presentation code (`.gitkeep` only) — they are no-ops in this plan.

**Tech Stack:** Flutter 3.44 / Material 3, Riverpod, go_router, the kit in `lib/core/ui/components/`.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-18-ui-redesign-design.md` including its Amendments section — normative. The quiz answer device amendment governs Task 2.
- NEVER add AI/Claude attribution or Co-Authored-By trailers to commits (project rule).
- No emojis in UI copy (glyphs ✓ ○ ✕ used as text characters are fine — InkTableRow already uses ✓/○); sentence case everywhere; stat labels lowercase; no all-caps section labels.
- Color budget: board green only on the primary action, progress indicators, done-checkmarks, and "Unlock with Pro"-class header actions; rust/amber only on semantic values (errors, weak/middling scores); one primary `BoardButton` per screen.
- No new data: never fake figures (days-to-exam, lesson counts, per-subject accuracy stay out until the data plan). Screens keep existing providers and behavior — this is restyling, not feature work.
- Do NOT delete a behavioral test assertion to get green — restyle finders (e.g. `find.byType(AppButton)` → `find.byType(BoardButton)`), preserve the intent (routes pushed, states shown, callbacks fired).
- Analyzer baseline is fully clean (`No issues found!`) and must stay so. Lint conventions: `very_good_analysis` — required named params before `super.key`, trailing commas, ≤ 80 char lines.
- Full `flutter test` green before every commit. Run from repo root `/Users/aedwon/Documents/Projects/Pantas`; `flutter` on PATH.
- Before consuming a provider or domain class, read its definition; if fields differ from what this plan assumes, adapt the call site preserving the stated intent and note it in your report.
- Kit references: `PageScaffold({body, bottomNavigationBar, padding})`, `SectionHeader({title, action, onAction})`, `RuledSection({child, topRule = true, padding})`, `InkTableRow({title, subtitle, category, meta, state, bottomRule, onTap})` with `InkRowState.plain/active/done`, `StatsBand({figures})` + `StatFigure({value, label, suffix})`, `ProgressRule({value})`, `InlineMeter({value, color, width = 70})`, `BoardButton({label, onPressed, secondary})`.
- Established page rhythm (from the Home reference implementation, `assessment_home_tab.dart`): `ListView(padding: EdgeInsets.fromLTRB(20, 24, 20, 24))`, serif page heading `styles.displaySmall` or `headlineMedium`, muted copy `bodyMedium/bodySmall.copyWith(color: colors.inkMuted)`, loading = faint bars, error = serif "Something went wrong" + secondary retry.

---

### Task 1: Theme surface defaults (AppBar, dialog, divider, bottom sheet)

Swept pages keep Material `AppBar`s, `AlertDialog`s, `Divider`s, and bottom sheets. Give those Material defaults the identity once, in the theme, so feature tasks don't hand-style them.

**Files:**
- Modify: `lib/core/ui/theme/app_theme.dart`
- Test: `test/core/ui/theme/app_theme_test.dart` (extend)

**Interfaces:**
- Consumes: `AppColors` tokens, `AppTextStyles.create()`, `AppDimensions.hairline/radiusSurface`.
- Produces: every `ThemeData` from `_buildTheme` carries `appBarTheme` (paper background, no elevation/tint, ink serif title), `dividerTheme` (1px `rule`), `dialogTheme` (surface, radius 8), `bottomSheetTheme` (paper background, top radius 8). All later tasks rely on these.

- [ ] **Step 1: Write the failing tests** — append to `test/core/ui/theme/app_theme_test.dart`:

```dart
  test('app bar is flat paper with ink title', () {
    final theme = buildLightTheme();
    const c = AppColors.light;
    final appBar = theme.appBarTheme;
    expect(appBar.backgroundColor, c.background);
    expect(appBar.surfaceTintColor, Colors.transparent);
    expect(appBar.elevation, 0);
    expect(appBar.scrolledUnderElevation, 0);
    expect(appBar.centerTitle, false);
    expect(appBar.titleTextStyle?.color, c.ink);
  });

  test('dividers are 1px rule hairlines', () {
    final divider = buildLightTheme().dividerTheme;
    expect(divider.color, AppColors.light.rule);
    expect(divider.thickness, 1);
  });

  test('dialogs and sheets are flat identity surfaces', () {
    final theme = buildDarkTheme();
    const c = AppColors.dark;
    expect(theme.dialogTheme.backgroundColor, c.surface);
    expect(
      theme.dialogTheme.shape,
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
    expect(theme.bottomSheetTheme.backgroundColor, c.background);
    expect(theme.bottomSheetTheme.surfaceTintColor, Colors.transparent);
  });
```

- [ ] **Step 2: Run to verify failure**

Run: `flutter test test/core/ui/theme/app_theme_test.dart`
Expected: FAIL — themes carry Material defaults.

- [ ] **Step 3: Implement** — in `_buildTheme`, extend the returned `ThemeData` (keep every existing field):

```dart
  final textStyles = AppTextStyles.create();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textStyles.headlineMedium.copyWith(color: colors.ink),
      iconTheme: IconThemeData(color: colors.inkMuted, size: 20),
    ),
    dividerTheme: DividerThemeData(
      color: colors.rule,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
    ),
    extensions: [colors, textStyles],
  );
```

If `_buildTheme` currently constructs `AppTextStyles.create()` inline in `extensions`, hoist it to the `textStyles` local shown above. Adapt `AppTextStyles.create()`'s actual signature if it takes arguments.

- [ ] **Step 4: Run theme tests + full suite + analyze**

Run: `flutter test test/core/ui/theme/ && flutter test && flutter analyze`
Expected: green, `No issues found!`. Widget tests pinning old AppBar/dialog colors: update expectations to the token values.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/theme test
git commit -m "theme: identity defaults for app bars, dialogs, dividers, sheets"
```

---

### Task 2: Quiz answer device — AnswerRow, QuestionCard, QuizProgressBar

The spec amendment defines the device: hairline-separated rows, serif choice letters, and the selected choice as *the single place* the board tint+border fills (1px board border, `boardTint` background, radius 5). The emoji-state `QuizAnswerTile` dies here.

**Files:**
- Create: `lib/core/ui/components/answer_row.dart`
- Modify: `lib/core/ui/components/question_card.dart` (rewrite)
- Modify: `lib/core/ui/components/quiz_progress_bar.dart` (rewrite)
- Delete: `lib/core/ui/components/quiz_answer_tile.dart`, `test/core/ui/components/quiz_answer_tile_test.dart`
- Test: create `test/core/ui/components/answer_row_test.dart`; update `question_card` tests if any exist (check `test/core/ui/components/`)

**Interfaces:**
- Consumes: `context.colors`, `context.textStyles`, `AppDimensions.hairline/radiusButton`, `Question{stem, choices}` with `Choice{id, label, text}` (read `lib/core/storage/domain/question.dart` for exact fields).
- Produces: `AnswerRow({required String letter, required String text, required VoidCallback? onTap, AnswerRowState state = AnswerRowState.plain, bool isMath = false})` with `enum AnswerRowState { plain, selected, correct, incorrect, correctMissed }`. `QuestionCard({required Question question, required void Function(String) onAnswer})` — signature unchanged; quiz and assessment pages keep working without call-site edits. `QuizProgressBar({required int current, required int total})` — signature unchanged. Tasks 4, 5, 8 rely on these.

- [ ] **Step 1: Write the failing tests** — `test/core/ui/components/answer_row_test.dart` (copy the `harness(...)` helper pattern from `test/core/ui/components/ink_table_row_test.dart`):

```dart
  testWidgets('selected row fills with board tint and border',
      (tester) async {
    await tester.pumpWidget(harness(
      AnswerRow(
        letter: 'B',
        text: 'Manila',
        onTap: () {},
        state: AnswerRowState.selected,
      ),
    ));
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(AnswerRow),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.boardTint);
    expect(decoration.border!.top.color, AppColors.light.board);
    expect(decoration.borderRadius, BorderRadius.circular(5));
  });

  testWidgets('plain row has no fill and a faint bottom rule',
      (tester) async {
    await tester.pumpWidget(harness(
      AnswerRow(letter: 'A', text: 'Cebu', onTap: () {}),
    ));
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(AnswerRow),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, isNull);
    expect(decoration.border!.bottom.color, AppColors.light.ruleFaint);
  });

  testWidgets('graded states show glyphs, never emoji', (tester) async {
    for (final (state, glyph) in [
      (AnswerRowState.correct, '✓'),
      (AnswerRowState.incorrect, '✕'),
      (AnswerRowState.correctMissed, '✓'),
    ]) {
      await tester.pumpWidget(harness(
        AnswerRow(letter: 'C', text: 'Davao', onTap: () {}, state: state),
      ));
      expect(find.text(glyph), findsOneWidget);
      expect(find.textContaining('✅'), findsNothing);
      expect(find.textContaining('❌'), findsNothing);
      expect(find.textContaining('💡'), findsNothing);
    }
  });

  testWidgets('tap fires callback and row meets 44px', (tester) async {
    var tapped = false;
    await tester.pumpWidget(harness(
      AnswerRow(letter: 'D', text: 'Iloilo', onTap: () => tapped = true),
    ));
    await tester.tap(find.byType(AnswerRow));
    expect(tapped, isTrue);
    expect(
      tester.getSize(find.byType(AnswerRow)).height,
      greaterThanOrEqualTo(44),
    );
  });
```

- [ ] **Step 2: Run to verify failure**

Run: `flutter test test/core/ui/components/answer_row_test.dart`
Expected: FAIL — `AnswerRow` doesn't exist.

- [ ] **Step 3: Implement `answer_row.dart`:**

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AnswerRowState { plain, selected, correct, incorrect, correctMissed }

/// Quiz answer device (spec amendment): hairline-separated rows with serif
/// choice letters. The selected row is the single place the board tint+border
/// fills. Graded states mark with text glyphs — board ✓ for correct, rust ✕
/// for a wrong pick, a board ✓ on the missed correct row.
class AnswerRow extends StatelessWidget {
  const AnswerRow({
    required this.letter,
    required this.text,
    required this.onTap,
    this.state = AnswerRowState.plain,
    this.isMath = false,
    super.key,
  });

  final String letter;
  final String text;
  final VoidCallback? onTap;
  final AnswerRowState state;
  final bool isMath;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final selected = state == AnswerRowState.selected;
    final decoration = selected
        ? BoxDecoration(
            color: colors.boardTint,
            border: Border.all(color: colors.board),
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          )
        : BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.ruleFaint,
                // ignore: avoid_redundant_argument_values
                width: AppDimensions.hairline,
              ),
            ),
          );

    final (String prefix, Color prefixColor) = switch (state) {
      AnswerRowState.plain => (letter, colors.inkMuted),
      AnswerRowState.selected => (letter, colors.board),
      AnswerRowState.correct => ('✓', colors.board),
      AnswerRowState.incorrect => ('✕', colors.rust),
      AnswerRowState.correctMissed => ('✓', colors.board),
    };

    final bodyStyle = isMath ? styles.mathBody : styles.bodyMedium;
    final textColor = switch (state) {
      AnswerRowState.incorrect => colors.rust,
      _ => colors.ink,
    };
    final weight = switch (state) {
      AnswerRowState.selected || AnswerRowState.correct => FontWeight.w600,
      _ => FontWeight.w400,
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: decoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                prefix,
                style: styles.headlineSmall.copyWith(color: prefixColor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: bodyStyle.copyWith(
                  color: textColor,
                  fontWeight: weight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

(`styles.headlineSmall` is the serif family — that's what makes the letter serif per the mock. Verify in `app_text_styles.dart`; if `headlineSmall` isn't Source Serif 4, use the smallest serif style that is.)

- [ ] **Step 4: Rewrite `question_card.dart`** — no card, serif stem, rows:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/ui/components/answer_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.question,
    required this.onAnswer,
    super.key,
  });

  final Question question;
  final void Function(String chosenChoiceId) onAnswer;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(question.stem, style: styles.headlineMedium),
        const SizedBox(height: 20),
        for (final choice in question.choices)
          AnswerRow(
            letter: choice.label,
            text: choice.text,
            onTap: () => onAnswer(choice.id),
          ),
      ],
    );
  }
}
```

- [ ] **Step 5: Rewrite `quiz_progress_bar.dart`** — label + 3px ProgressRule:

```dart
import 'package:cse_cet_reviewer/core/ui/components/progress_rule.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    required this.current,
    required this.total,
    super.key,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current of $total',
          style: styles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 8),
        ProgressRule(value: total == 0 ? 0 : current / total),
      ],
    );
  }
}
```

- [ ] **Step 6: Delete the old tile**

```bash
rm lib/core/ui/components/quiz_answer_tile.dart \
   test/core/ui/components/quiz_answer_tile_test.dart
```

Grep to confirm nothing else references it: `grep -rn "QuizAnswerTile\|quiz_answer_tile" lib test` → no hits.

- [ ] **Step 7: Run suite + analyze** — update any question-card/progress-bar tests to the new structure (finders for `AnswerRow`, `ProgressRule`), preserving behavior assertions (answer callback carries the choice id).

Run: `flutter test && flutter analyze`
Expected: green, `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/core/ui/components test
git commit -m "components: AnswerRow answer device, ruled question surface, 3px quiz progress"
```

---

### Task 3: Support kit — ErrorBanner, EmptyState, ConfirmationDialog, FaintBars

Kill the remaining emoji/pastel devices every feature leans on, and extract the faint-bars loading/teaser pattern that Home and the Progress teaser currently duplicate inline.

**Files:**
- Create: `lib/core/ui/components/faint_bars.dart`
- Modify: `lib/core/ui/components/error_banner.dart` (rewrite), `empty_state.dart` (rewrite), `confirmation_dialog.dart` (rewrite)
- Modify: `lib/features/assessment/presentation/assessment_home_tab.dart` (`_HomeLoading` uses `FaintBars`), `lib/features/progress/presentation/paywall_teaser_panel.dart` (bars → `FaintBars`)
- Modify: `lib/features/quiz/presentation/quiz_page.dart` (drop the `icon:` argument), `lib/features/quiz/presentation/quiz_results_page.dart` + `lib/features/lesson/presentation/lesson_list_page.dart` (drop `illustration:` where `EmptyState` is used — quiz_results only; lesson_list has a private `_EmptyState`, untouched here)
- Test: `test/core/ui/components/faint_bars_test.dart` (create); update `error_banner_test.dart`, `empty_state_test.dart`, `confirmation_dialog_test.dart`

**Interfaces:**
- Consumes: kit tokens, `BoardButton`.
- Produces: `FaintBars({List<double> widthFactors = const [0.9, 0.65, 0.8]})`; `ErrorBanner({required ErrorBannerVariant variant, required String message, String? actionLabel, VoidCallback? onAction, VoidCallback? onDismiss})` (unchanged API, new visuals); `EmptyState({required String headline, required String body, required String ctaLabel, required VoidCallback onCta})` (**`illustration` param removed**); `showAppConfirmationDialog({required BuildContext context, required String title, required String body, required String cancelLabel, required String confirmLabel, required VoidCallback onCancel, required VoidCallback onConfirm, bool isDestructive = true})` (**`icon` param removed**). All later feature tasks use these for loading/empty/error states.

- [ ] **Step 1: Write the failing tests**

`test/core/ui/components/faint_bars_test.dart` (reuse the harness pattern):

```dart
  testWidgets('renders one faint bar per width factor', (tester) async {
    await tester.pumpWidget(
      harness(const FaintBars(widthFactors: [0.9, 0.5])),
    );
    expect(find.byType(FractionallySizedBox), findsNWidgets(2));
    final bar = tester.widget<Container>(find.byType(Container).first);
    final decoration = bar.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.ruleFaint);
  });
```

Update `error_banner_test.dart` — keep behavioral assertions (message shown, action fires), replace visual pins with:

```dart
  testWidgets('error variant carries no emoji and a rust accent',
      (tester) async {
    await tester.pumpWidget(harness(
      const ErrorBanner(
        variant: ErrorBannerVariant.error,
        message: 'Something broke',
      ),
    ));
    expect(find.textContaining('⚠'), findsNothing);
    final accent = tester.widget<Container>(
      find.byKey(const Key('error-banner-accent')),
    );
    expect(accent.color, AppColors.light.rust);
  });
```

Update `empty_state_test.dart` and `confirmation_dialog_test.dart` to the new constructors (no `illustration`, no `icon`), asserting headline/body/cta still render and callbacks still fire.

- [ ] **Step 2: Run to verify failures** — `flutter test test/core/ui/components/` → new/updated tests FAIL.

- [ ] **Step 3: Implement `faint_bars.dart`:**

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Rows of faint paper-toned bars — the identity's loading skeleton and
/// "unprinted" teaser fill. No gray blocks, no shimmer.
class FaintBars extends StatelessWidget {
  const FaintBars({this.widthFactors = const [0.9, 0.65, 0.8], super.key});

  final List<double> widthFactors;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final factor in widthFactors)
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: factor,
            child: Container(
              height: 7,
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: colors.ruleFaint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Rewrite `error_banner.dart`** — same API, ruled block, semantic accent bar, no emoji:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ErrorBannerVariant { error, offline, success }

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.variant,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    super.key,
  });

  final ErrorBannerVariant variant;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final accent = switch (variant) {
      ErrorBannerVariant.error => colors.rust,
      ErrorBannerVariant.offline => colors.amber,
      ErrorBannerVariant.success => colors.board,
    };

    final side = BorderSide(
      color: colors.rule,
      // ignore: avoid_redundant_argument_values
      width: AppDimensions.hairline,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(top: side, bottom: side)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('error-banner-accent'),
            width: 3,
            height: 30,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: styles.bodySmall.copyWith(color: colors.ink),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: styles.labelLarge.copyWith(color: colors.board),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: colors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Rewrite `empty_state.dart`** — serif message, one quiet action, no illustration slot:

```dart
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.headline,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    super.key,
  });

  final String headline;
  final String body;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: styles.headlineMedium),
          const SizedBox(height: 6),
          Text(
            body,
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 20),
          BoardButton(label: ctaLabel, onPressed: onCta, secondary: true),
        ],
      ),
    );
  }
}
```

Update the `EmptyState` call site in `quiz_results_page.dart`: remove `illustration: '📭'`.

- [ ] **Step 6: Rewrite `confirmation_dialog.dart`** — remove `icon`, identity actions:

```dart
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
  required VoidCallback onCancel,
  required VoidCallback onConfirm,
  bool isDestructive = true,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ConfirmationDialog(
      title: title,
      body: body,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      onCancel: onCancel,
      onConfirm: onConfirm,
      isDestructive: isDestructive,
    ),
  );
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    required this.isDestructive,
  });

  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: styles.headlineMedium),
            const SizedBox(height: 6),
            Text(
              body,
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: BoardButton(
                    label: cancelLabel,
                    secondary: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: isDestructive
                      ? _RustButton(
                          label: confirmLabel,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                        )
                      : BoardButton(
                          label: confirmLabel,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RustButton extends StatelessWidget {
  const _RustButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      child: Container(
        constraints:
            const BoxConstraints(minHeight: AppDimensions.minTapTarget),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.rust,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: styles.labelLarge.copyWith(color: colors.onBoard),
        ),
      ),
    );
  }
}
```

Update the call site in `quiz_page.dart`: remove `icon: '!'`.

- [ ] **Step 7: DRY the existing bar duplicates** — in `assessment_home_tab.dart`, `_HomeLoading`'s body becomes:

```dart
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: const [FaintBars()],
    );
```

In `paywall_teaser_panel.dart`, replace the local `bar(...)` helper and three `bar(...)` calls with `const FaintBars(widthFactors: [0.92, 0.7, 0.83])`. Remove the now-unused locals/imports in both files.

- [ ] **Step 8: Run suite + analyze** — green + clean (home/progress tests should be unaffected; fix finders if they pinned the inline bars).

- [ ] **Step 9: Commit**

```bash
git add lib test
git commit -m "components: identity error banner, empty state, dialog, FaintBars"
```

---

### Task 4: Quiz feature sweep

**Files:**
- Modify: `lib/features/quiz/presentation/quiz_tab_home.dart` (rewrite), `quiz_page.dart` (states), `quiz_results_page.dart` (rewrite body), `drill_subtopic_browser.dart` (rewrite), `done_for_today_celebration.dart` (restyle)
- Test: `test/features/quiz/` (update)

**Interfaces:**
- Consumes: Task 2's `QuestionCard`/`QuizProgressBar` (already wired), Task 3's `EmptyState`/`ErrorBanner`/`FaintBars`, kit widgets, existing providers (`activeExamFocusProvider`, `quizControllerProvider`, `attemptByIdProvider`, `topicsByExamProvider`, nudge providers) and routes — all unchanged.
- Produces: no API changes; screens restyled.

- [ ] **Step 1: Rewrite `quiz_tab_home.dart`.** Keep the `Scaffold(appBar: AppBar(title: Text('Quiz')))` (Task 1 makes it flat paper). Keep provider logic and the nudge flow byte-for-byte (`_onStartQuiz` untouched). Replace `_ChooseExamFallback` and `_ExamCard` compositions:

`_ChooseExamFallback` → the `_ChooseExamHome` pattern from `assessment_home_tab.dart`: serif `'Choose your exam'` (`headlineMedium`), muted line, `BoardButton('Choose exam', onPressed: → '/onboarding')`, inside `ListView(padding: EdgeInsets.fromLTRB(20, 24, 20, 24))`.

`_ExamCard` → no card. Composition:

```dart
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exam.name, style: textStyles.headlineMedium),
        const SizedBox(height: 2),
        Text(
          exam.shortName,
          style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 20),
        BoardButton(
          label: "Start today's session",
          onPressed: () => _onStartQuiz(context, ref),
        ),
        const SizedBox(height: 16),
        SectionHeader(title: 'More practice'),
        InkTableRow(
          title: 'Retake mistakes',
          onTap: () => context.go('/quiz/retake/${exam.id}'),
        ),
        InkTableRow(
          title: 'Drill a topic',
          onTap: () => context.go('/quiz/drill/${exam.id}'),
        ),
        InkTableRow(
          title: 'Study plan',
          onTap: () => context.go('/plan'),
        ),
        InkTableRow(
          title: 'Study',
          bottomRule: false,
          onTap: () => context.go('/study'),
        ),
      ],
    );
```

Loading state → `FaintBars` in the padded ListView (drop `CircularProgressIndicator`); error state → the serif `'Something went wrong'` + secondary `'Try again'` retry pattern (invalidate `activeExamFocusProvider`). `_QuizNudgeSheet`: keep structure/copy, swap the two `AppButton`s for `BoardButton` (primary 'Study', secondary 'Start quiz anyway'); headline stays `headlineSmall` — change to `headlineMedium` for the serif voice.

- [ ] **Step 2: `quiz_page.dart` states.** Loading → `FaintBars` (replace `SkeletonCard`); title copy to sentence case: `'Quick quiz'`, `"Today's session"`, `'Retake mistakes'` (leave `'Drill'`, `'Quiz yourself'`). Everything else (QuizProgressBar, QuestionCard, ConfirmationDialog, toast listen) is already swept by Tasks 1–3.

- [ ] **Step 3: Rewrite `quiz_results_page.dart` body.** Keep providers, nudge sheet flow (swap its `AppButton`s → `BoardButton` primary/secondary), and banner condition. New `_ResultsBody` build:

```dart
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        if (showBanner)
          RuledSection(
            child: SectionHeader(
              title: 'Your study plan is waiting',
              action: 'Take the assessment',
              onAction: () => context.go('/assessment/$examId'),
            ),
          ),
        StatsBand(
          figures: [
            StatFigure(
              value: '$correct',
              suffix: '/$total',
              label: 'correct',
            ),
            StatFigure(value: '$percent%', label: 'score'),
          ],
        ),
        const SizedBox(height: 12),
        SectionHeader(title: 'Questions'),
        for (final item in attempt.items)
          InkTableRow(
            title: item.questionId,
            state: item.isCorrect ? InkRowState.done : InkRowState.plain,
            meta: '${(item.responseMs / 1000).toStringAsFixed(1)}s',
          ),
      ],
    );
```

Delete `_ItemRow` (the green/red icon card). A wrong answer is `plain` with no rust — the ✓-done treatment marks correct ones; rust is reserved for scores/errors. Loading → `FaintBars`; the raw `Center(Text('Error: $e'))` → serif error + retry (`ref.invalidate(attemptByIdProvider(attemptId))`).

- [ ] **Step 4: Rewrite `drill_subtopic_browser.dart` rows** — card-per-topic becomes a table:

```dart
        data: (topics) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            for (final topic in topics)
              InkTableRow(
                title: topic.name,
                subtitle: 'General bucket',
                onTap: () => context.go(
                  '/quiz/drill/$examId?topicId=${topic.id}',
                ),
              ),
          ],
        ),
```

Loading → `FaintBars` in the padded list; error → serif error + secondary retry (`ref.invalidate(topicsByExamProvider(examId))`).

- [ ] **Step 5: Restyle `done_for_today_celebration.dart`** — drop the celebration icon; serif figure treatment, keep copy and route:

```dart
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isToday ? 'Done for today' : 'Session complete',
              style: styles.headlineMedium,
            ),
            const SizedBox(height: 12),
            StatsBand(
              figures: [
                StatFigure(
                  value: '${score.$1}',
                  suffix: '/${score.$2}',
                  label: 'correct',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isToday
                  ? 'Your streak is updated if this is your first completed '
                      "Today's session for the day."
                  : 'Practice saved. Your review schedule has been updated.',
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 20),
            BoardButton(
              label: 'Review results',
              onPressed: () => context.go('/quiz/results/${attempt.id}'),
            ),
          ],
        ),
      ),
    );
```

(Add the `context.colors` / `context.textStyles` locals and imports; drop `Theme.of(context)` usage.)

- [ ] **Step 6: Update quiz tests** — finders `AppButton`→`BoardButton`, `AppCard`→gone (find by text/`InkTableRow`), `'Retake Mistakes'`→`'Retake mistakes'` etc.; preserve every route/callback assertion (nudge sheet shown when undismissed+unread, start-anyway marks dismissed and routes, results nudge at counts 1/3, banner at ≥5 unassessed).

Run: `flutter test test/features/quiz && flutter test && flutter analyze`
Expected: green, `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/quiz test
git commit -m "quiz: Ink & Rule sweep — tabular home, ruled results, serif celebration"
```

---

### Task 5: Assessment sweep

**Files:**
- Modify: `lib/features/assessment/presentation/assessment_page.dart` (states only), `assessment_results_page.dart` (rewrite body)
- Test: `test/features/assessment/` (update)

**Interfaces:**
- Consumes: Task 2/3 kit; `assessmentResultProvider`, `TopicMastery{topic, correct, total, accuracy, level}` with `MasteryLevel.weak/moderate/strong`.
- Produces: no API changes.

- [ ] **Step 1: `assessment_page.dart`** — loading/completing → `FaintBars` (replace `SkeletonCard`); keep the `AlertDialog` leave-confirm (Task 1 themes it). No other changes: the question surface and progress bar restyle arrived via Task 2.

- [ ] **Step 2: Rewrite `assessment_results_page.dart` body.** AppBar title → `'Your results'`. `_ResultsBody`:

```dart
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('Your $examName profile', style: textStyles.displaySmall),
        const SizedBox(height: 16),
        SectionHeader(title: 'Topic breakdown'),
        for (final mastery in result.topicMasteries)
          _TopicRow(mastery: mastery),
        const SizedBox(height: 20),
        SectionHeader(title: 'Focus areas'),
        Text(
          'Your recommendations update as you study',
          style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < weak.length; i++)
          _FocusAreaRow(
            mastery: weak[i],
            examId: examId,
            isFirst: i == 0,
          ),
      ],
    );
```

`_TopicRow` replaces `_TopicBar` — name, InlineMeter, semantic percentage:

```dart
class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.mastery});

  final TopicMastery mastery;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final pct = (mastery.accuracy * 100).round();
    final meterColor = switch (mastery.level) {
      MasteryLevel.weak => colors.rust,
      MasteryLevel.moderate => colors.amber,
      MasteryLevel.strong => colors.board,
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.ruleFaint,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              mastery.topic.name,
              style: styles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          InlineMeter(value: mastery.accuracy, color: meterColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '$pct%',
              textAlign: TextAlign.right,
              style: styles.bodySmall.copyWith(color: meterColor),
            ),
          ),
        ],
      ),
    );
  }
}
```

`_FocusAreaRow` replaces `_TopicCta` — an `InkTableRow` (active state on the first) plus one shared CTA; the per-card Study/Quiz button pairs collapse into row taps (Study) and the "Focus areas" list keeps quiz reachable through the study flow:

```dart
class _FocusAreaRow extends StatelessWidget {
  const _FocusAreaRow({
    required this.mastery,
    required this.examId,
    required this.isFirst,
  });

  final TopicMastery mastery;
  final ExamId examId;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return InkTableRow(
      title: mastery.topic.name,
      subtitle: isFirst ? 'Start here' : null,
      state: isFirst ? InkRowState.active : InkRowState.plain,
      meta: '${(mastery.accuracy * 100).round()}%',
      onTap: () => context.push(
        '/study/topic/${mastery.topic.id}?examId=$examId',
      ),
    );
  }
}
```

After the focus rows, close with one primary action:

```dart
        const SizedBox(height: 16),
        BoardButton(
          label: 'Start studying',
          onPressed: () => context.push(
            '/study/topic/${weak.first.topic.id}?examId=$examId',
          ),
        ),
```

(Behavior note: the old per-topic `Quiz →` secondary buttons are removed as chrome; quizzing a topic stays reachable from the study flow and quiz tab. This is the one deliberate affordance consolidation in the plan — flag it in your report.) Loading → `FaintBars`; keep `ErrorBanner` retry as-is (restyled by Task 3); `'No assessment found.'` → muted `bodyMedium`.

- [ ] **Step 3: Update assessment tests** preserving behavior (weak-first selection, first-focus 'Start here', study routes). Update copy finders (`'Your Profile'` → `'Your results'`, `'Topic Breakdown'` → `'Topic breakdown'`, `'Focus Areas'` → `'Focus areas'`). If a test asserted the per-topic Quiz button route, replace it with the row-tap study route assertion and note the consolidation.

Run: `flutter test && flutter analyze` — green + clean.

- [ ] **Step 4: Commit**

```bash
git add lib/features/assessment test
git commit -m "assessment: Ink & Rule sweep — metered breakdown, focus rows"
```

---

### Task 6: Study tab + lesson sweep

**Files:**
- Modify: `lib/features/lesson/presentation/learn_tab_home.dart` (rewrite), `lesson_list_page.dart` (rewrite rows/states), `lesson_page.dart` (restyle actions/states)
- Modify: `lib/core/ui/components/portable_text_renderer.dart` (alias swap only)
- Test: `test/features/lesson/` (update), `test/core/ui/components/portable_text_renderer_test.dart` (should stay green)

**Interfaces:**
- Consumes: existing providers (`activeExamFocusProvider`, `topicsBySubjectProvider`, `topicByIdProvider`, `topicLessonsProvider`, `lessonByIdProvider`, `isLessonReadProvider`, `lessonProgressRepositoryProvider`), Task 3 kit.
- Produces: no API changes (`LearnTabHome`/`StudyTabHome` classes stay).

- [ ] **Step 1: Rewrite `StudyTabHome`.** Keep `Scaffold(appBar: AppBar(title: Text('Study')))`. Replace `_ExamAccordion`/`_SubjectExpansion` (cards + ExpansionTiles) with a flat ruled table — subjects always expanded, grouped by `SectionHeader`:

```dart
          data: (focus) {
            if (focus.needsSelection || focus.exam == null) {
              return const _ChooseExamFallback();
            }
            final exam = focus.exam!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Text(exam.name, style: context.textStyles.headlineMedium),
                const SizedBox(height: 12),
                for (final subject in exam.subjects)
                  _SubjectSection(subject: subject, examId: exam.id),
              ],
            );
          },
```

```dart
class _SubjectSection extends ConsumerWidget {
  const _SubjectSection({required this.subject, required this.examId});

  final Subject subject;
  final ExamId examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTopics = ref.watch(topicsBySubjectProvider(subject.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: subject.name),
        asyncTopics.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: FaintBars(widthFactors: [0.8, 0.6]),
          ),
          error: (e, _) => ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
          data: (topics) => Column(
            children: [
              for (final topic in topics)
                InkTableRow(
                  title: topic.name,
                  onTap: () => context.push(
                    '/study/topic/${topic.id}?examId=$examId',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
```

`_ChooseExamFallback` → same serif pattern as the quiz tab (Task 4 Step 1). `_LoadingSkeleton` → `FaintBars` in the padded list. Behavior note: the accordion's collapse affordance goes away (subjects render expanded) — the tabular identity has no accordions; flag in the report.

- [ ] **Step 2: Rewrite `lesson_list_page.dart` rows.** Keep the topic-name AppBar. Lessons become `InkTableRow`s — read lessons get the done state:

```dart
          data: (lessons) {
            if (lessons.isEmpty) {
              return _EmptyLessons(examId: examId);
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                for (final lesson in lessons)
                  _LessonRow(lesson: lesson, examId: examId),
              ],
            );
          },
```

```dart
class _LessonRow extends ConsumerWidget {
  const _LessonRow({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examParam = examId != null ? '?examId=$examId' : '';
    final isRead =
        ref.watch(isLessonReadProvider(lesson.id)).valueOrNull ?? false;
    return InkTableRow(
      title: lesson.title,
      subtitle: lesson.summary,
      state: isRead ? InkRowState.done : InkRowState.plain,
      meta: '${lesson.estimatedMinutes} min',
      onTap: () => context.push('/lesson/${lesson.id}$examParam'),
    );
  }
}
```

`_EmptyState` → rename `_EmptyLessons`, serif treatment: `'No lessons yet'` (`headlineMedium`), muted body `'This topic has no lessons yet.'`, and when `examId != null` a secondary `BoardButton('Try a quick quiz instead')` with the same route. `_LoadingSkeleton` → `FaintBars`.

- [ ] **Step 3: Restyle `lesson_page.dart`.** Keep structure and PortableTextRenderer. Swap: `AppButton('Mark as read')` → `BoardButton` (same callback); the disabled `'Lesson complete ✓'` AppButton → a done line, not a button:

```dart
          if (isRead)
            Row(
              children: [
                Text(
                  '✓ Lesson complete',
                  style: textStyles.bodyMedium.copyWith(color: colors.board),
                ),
              ],
            )
          else
            BoardButton(label: 'Mark as read', onPressed: () async { ... }),
```

(✓ is the budgeted done-check.) `'Quiz yourself'` AppButton → `BoardButton(secondary: true)`. The clock-icon minutes row → plain muted text `'${lesson.estimatedMinutes} min read'` (drop the icon). `_LoadingSkeleton` → `FaintBars`. Padding → `EdgeInsets.fromLTRB(20, 24, 20, 24)`.

- [ ] **Step 4: `portable_text_renderer.dart` aliases** — replace every deprecated alias with its target (`onSurface`→`ink`, `onSurfaceMuted`→`inkMuted`, `border`→`rule`, `primary`→`board`, containers→`ruleFaint`/`boardTint` per the alias table in `app_colors.dart`), and replace any `SkeletonBox` usage in its image loading path with a `FaintBars`-style faint container (`ruleFaint`, radius 2). No layout changes.

- [ ] **Step 5: Update lesson tests** (`learn_tab_home_test.dart` and friends): finders to `InkTableRow`/`BoardButton`/text, preserve route assertions (`/study/topic/:id`, `/lesson/:id`, quiz fallback) and read-state behavior (done state shown when read; mark-as-read invalidates providers).

Run: `flutter test && flutter analyze` — green + clean.

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "study: Ink & Rule sweep — ruled subject tables, lesson rows, serif reader"
```

---

### Task 7: Study plan sweep

**Files:**
- Modify: `lib/features/study_plan/presentation/plan_page.dart` (rewrite), `today_inset.dart` (rewrite), `upcoming_day_chip.dart` (rewrite), `mock_week_card.dart` (rewrite), `collapsed_plan_section.dart` (restyle), `plan_updated_chip.dart` (restyle)
- Delete: `lib/features/study_plan/presentation/home_plan_card.dart`, `test/features/study_plan/presentation/home_plan_card_test.dart` (unused since the Plan 2A home rewrite — verify with `grep -rn "HomePlanCard" lib test` first; if a test file other than its own references it, update that test instead)
- Test: `test/features/study_plan/presentation/plan_widgets_test.dart` + page tests (update)

**Interfaces:**
- Consumes: `studyPlanViewProvider` → `StudyPlanNeedsExamSelection | StudyPlanReady(view: PlanView{today, upcoming, nearestMock, weeksToExam, paceStatus})`, `TodayPlan{headline, why, reviewCount, lessonId, drillTopicName, ctaPath}`, `UpcomingPlanDay{focusLabel, isRestDay, estimatedQuestionCount}`, `MockWeekPreview{title, description}` — read `compute_plan_view.dart` for exact fields.
- Produces: widget signatures unchanged (`TodayInset({plan, onStart})`, `UpcomingDayChip({day})`, `MockWeekCard({preview})`, `CollapsedPlanSection({label})`, `PlanUpdatedChip({onDismissed})`).

- [ ] **Step 1: Rewrite `plan_page.dart`** — keep provider switch; new ready composition:

```dart
            StudyPlanReady(:final view) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(
                    'Week ${view.weeksToExam} to exam · '
                    '${_paceLabel(view.paceStatus.name)}',
                    style: context.textStyles.bodySmall
                        .copyWith(color: context.colors.inkMuted),
                  ),
                  const SizedBox(height: 12),
                  TodayInset(
                    plan: view.today,
                    onStart: () => context.go(view.today.ctaPath),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(title: 'This week'),
                  for (final day in view.upcoming) UpcomingDayChip(day: day),
                  if (view.nearestMock != null)
                    MockWeekCard(preview: view.nearestMock!),
                  const SizedBox(height: 8),
                  const CollapsedPlanSection(label: 'Past 2 weeks'),
                  const CollapsedPlanSection(label: 'Show full plan'),
                ],
              ),
```

Loading → `FaintBars` in the padded list; `'Plan unavailable: $error'` and needs-selection keep their copy, styled muted `bodyMedium`.

- [ ] **Step 2: Rewrite `today_inset.dart`** — card+chips → ruled block with a meta line:

```dart
    final breakdown = [
      '${plan.reviewCount} reviews',
      if (plan.lessonId != null) '1 lesson',
      if (plan.drillTopicName != null) '${plan.drillTopicName} drill',
    ].join(' · ');

    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.headline, style: textStyles.headlineMedium),
          const SizedBox(height: 6),
          Text(
            plan.why,
            style: textStyles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 6),
          Text(
            breakdown,
            style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          BoardButton(label: "Start today's session", onPressed: onStart),
        ],
      ),
    );
```

Delete `_BreakdownChip`.

- [ ] **Step 3: `upcoming_day_chip.dart`** — card → `InkTableRow(title: day.focusLabel, meta: day.isRestDay ? 'Rest' : '${day.estimatedQuestionCount} questions')`. **Step 4: `mock_week_card.dart`** — card → `RuledSection` with `headlineSmall` title (wait — serif hierarchy: use `headlineMedium`? The section sits under 'This week'; use `headlineSmall`-sized serif if that's the serif family, matching InkTableRow scale) + muted description. Use:

```dart
    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(preview.title, style: textStyles.headlineSmall),
          const SizedBox(height: 4),
          Text(
            preview.description,
            style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
```

**Step 5: `collapsed_plan_section.dart`** — `ListTile` → `InkTableRow(title: label, onTap: null)` (keep it non-navigating as today; the chevron affordance goes). **Step 6: `plan_updated_chip.dart`** — green tinted pill → quiet text line, board only as the semantic "done" voice is wrong here; use muted:

```dart
    return GestureDetector(
      onTap: onDismissed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'Plan updated for the week',
          style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
        ),
      ),
    );
```

- [ ] **Step 7: Delete `home_plan_card.dart`** + its test (after the grep check in Files above).

- [ ] **Step 8: Update study-plan tests** — preserve assertions (CTA path fired, rest-day label, breakdown contents now asserted via the joined meta line, dismiss callback). Run `flutter test && flutter analyze` — green + clean.

- [ ] **Step 9: Commit**

```bash
git add lib test
git commit -m "study-plan: Ink & Rule sweep — ruled today block, tabular week"
```

---

### Task 8: Mock exam sweep

These surfaces are built and tested but not yet routed (router still has `_Stub`s); sweep them now so they ship styled when wired.

**Files:**
- Modify: `lib/features/mock_exam/presentation/pages/mock_setup_page.dart`, `mock_session_page.dart`, `mock_results_page.dart`, `mock_history_page.dart`; `widgets/mock_status_card.dart`, `mock_quiz_tab_tile.dart`, `mock_resume_sheet.dart`, `question_navigator_sheet.dart`
- Test: `test/features/mock_exam/` (update)

**Interfaces:**
- Consumes: existing domain types (`ParsedMockBlueprint`, `MockSessionInProgress`, `MockResults`, `MockAttempt`, `MockAvailability`, `SampledMockSection`, `MockAnswer`) and callbacks — all signatures unchanged.
- Produces: no API changes.

- [ ] **Step 1: `mock_setup_page.dart`** — drop `AppCard`; blueprint block becomes ruled:

```dart
        children: [
          Text('Ready to practice?', style: textStyles.headlineMedium),
          const SizedBox(height: 12),
          RuledSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parsedBlueprint.blueprint.name,
                  style: textStyles.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${parsedBlueprint.blueprint.durationMinutes} min · '
                  '$totalQuestions questions',
                  style: textStyles.bodySmall
                      .copyWith(color: colors.inkMuted),
                ),
                const SizedBox(height: 8),
                for (final section in parsedBlueprint.sections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(section.name, style: textStyles.bodyMedium),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BoardButton(label: 'Start mock', onPressed: onStart),
        ],
```

Page padding `EdgeInsets.fromLTRB(20, 24, 20, 24)` (apply to every mock page below too). `MockSetupPlaceholderPage`: center text styled muted `bodyMedium`.

- [ ] **Step 2: `mock_session_page.dart`** — the A/B `AppButton`s become `AnswerRow`s (letters only, matching the device):

```dart
          children: [
            Text(state.currentQuestionId, style: textStyles.headlineMedium),
            const SizedBox(height: 20),
            AnswerRow(letter: 'A', text: 'Choice A', onTap: () => onAnswer(0)),
            AnswerRow(letter: 'B', text: 'Choice B', onTap: () => onAnswer(1)),
            const SizedBox(height: 16),
            BoardButton(
              label: 'Questions',
              secondary: true,
              onPressed: onShowNavigator,
            ),
          ],
```

(The page renders question IDs and two fixed choices today — placeholder data, keep it; only the chrome changes.) Timer text in the AppBar: wrap the existing `Text(_formatRemaining(...))` in a `Center` + padding and give it `textStyles.bodyMedium.copyWith(color: colors.inkMuted, fontFeatures: [const FontFeature.tabularFigures()])`. Keep flag/pause `IconButton`s and the leave dialog.

- [ ] **Step 3: `mock_results_page.dart`** — score card → `StatsBand`; sections + weak topics → rows; Pro teaser → unprinted pattern:

```dart
        children: [
          if (forfeited) ...[
            Text(
              'Forfeited during strict mode',
              style: textStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
          ],
          StatsBand(
            figures: [
              StatFigure(
                value: '${results.scoreRaw}',
                suffix: '/${results.scoreTotal}',
                label: 'score',
              ),
              StatFigure(
                value: '${results.percent.toStringAsFixed(0)}%',
                label: 'accuracy',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionHeader(title: 'How you did per part'),
          for (final section in results.sections)
            InkTableRow(
              title: section.name,
              meta: '${section.correct}/${section.total}',
            ),
          const SizedBox(height: 12),
          SectionHeader(title: 'Practice these next'),
          for (final topic in results.topWeak)
            InkTableRow(title: topic.drillRoute),
          const SizedBox(height: 12),
          if (proIsActive)
            RuledSection(
              child: SectionHeader(title: 'Answer review'),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Answer review',
                  action: 'Unlock with Pro',
                  onAction: () {},
                ),
                const FaintBars(),
              ],
            ),
        ],
```

(The free teaser reuses the unprinted metaphor; `onAction` stays a no-op until the page is routed — match whatever callback the current code has, which is none.)

- [ ] **Step 4: `mock_history_page.dart`** — `ListTile`s → `InkTableRow(title: attempt.id, meta: '${attempt.scoreRaw ?? 0}/${attempt.scoreTotal ?? 0}')`; `AppButton('See all')` → `BoardButton(secondary: true)`. **Step 5: widgets** — `mock_status_card.dart` and `mock_quiz_tab_tile.dart`: `AppCard` → `RuledSection`, title `headlineSmall`, body muted `bodySmall`, `AppButton` → `BoardButton` (primary for Start/Resume, keep single-primary per widget). `mock_resume_sheet.dart`: drop the inner `AppCard` (the sheet surface is themed now); `Resume` → `BoardButton`, `Discard` → `BoardButton(secondary: true)`; times as muted `bodySmall`. `question_navigator_sheet.dart`: replace `_QuestionChip`/`ActionChip` with a bordered square:

```dart
class _QuestionCell extends StatelessWidget {
  const _QuestionCell({
    required this.label,
    required this.answered,
    required this.flagged,
    required this.current,
    required this.onTap,
  });

  final String label;
  final bool answered;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: answered ? colors.boardTint : null,
          border: Border.all(
            color: current ? colors.board : colors.rule,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          flagged ? '$label*' : label,
          style: styles.bodySmall.copyWith(
            color: answered ? colors.board : colors.ink,
            fontWeight: current ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
```

Section names get `SectionHeader`; `'Next blank'`/`'Next flagged'` `TextButton`s → text-only `GestureDetector` labels in `labelLarge` board (they're navigation actions, quiz-device adjacent — acceptable board use as sheet actions; keep both quiet, no fills).

- [ ] **Step 6: Update mock tests** — finders (`AppButton`→`BoardButton`, `AppCard`→`RuledSection`/rows, `ActionChip`→`_QuestionCell` via text), preserving assertions (answer index fired, jump-to index, resume/discard callbacks, strict-mode pause hidden, forfeited headline).

Run: `flutter test && flutter analyze` — green + clean.

- [ ] **Step 7: Commit**

```bash
git add lib/features/mock_exam test
git commit -m "mock-exam: Ink & Rule sweep ahead of routing"
```

---

### Task 9: Onboarding + notifications rationale sweep

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_welcome_step.dart`, `onboarding_age_gate_step.dart`, `onboarding_picker_step.dart`
- Modify: `lib/features/notifications/presentation/permission_rationale_page.dart`
- Test: `test/features/onboarding/`, `test/features/notifications/` (update)

**Interfaces:**
- Consumes: existing callbacks (`onAdvance`, `onAgeGatePassed`, `onCompleted`), `examListProvider`, `appPreferencesRepositoryProvider`, notification providers; kit widgets.
- Produces: no API changes.

- [ ] **Step 1: `onboarding_welcome_step.dart`** — delete the tinted hero container + icon; left-aligned serif:

```dart
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text('Build your study plan', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              "Pick your exam — we'll guide what to study first.",
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
            const Spacer(),
            BoardButton(label: 'Get started', onPressed: onAdvance),
          ],
        ),
      ),
    );
```

(Convert `Theme.of(context)` usage to `context.colors`/`context.textStyles`; add imports.)

- [ ] **Step 2: `onboarding_age_gate_step.dart`** — keep the `CupertinoPicker` and all gate logic. Headline `'Quick check'` → `styles.displaySmall`; sub-line muted `bodyLarge`; `FilledButton` → `BoardButton(label: 'Continue', onPressed: (_saving || !_yearSelected) ? null : _onContinue)`. Blocked state: headline `headlineMedium` serif, `TextButton('Try a different year')` → `BoardButton(secondary: true)`.

- [ ] **Step 3: `onboarding_picker_step.dart`** — headline `displaySmall`; copy fix: `'You can switch later in More.'` → `'You can switch later in Settings.'` (More tab no longer exists). `_ExamCard` → selection row using the answer-device treatment (the single tint+border fill):

```dart
class _ExamRow extends StatelessWidget {
  const _ExamRow({
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  final Exam exam;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: selected
            ? BoxDecoration(
                color: colors.boardTint,
                border: Border.all(color: colors.board),
                borderRadius: BorderRadius.circular(5),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                ),
              ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                exam.code,
                style: styles.headlineSmall.copyWith(
                  color: selected ? colors.board : colors.inkMuted,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exam.name,
                style: styles.bodyMedium.copyWith(
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Drop the `separatorBuilder` gaps (rules separate rows): use `ListView.builder`. `FilledButton('Continue')` → `BoardButton`; keep the disabled/saving predicate. Loading → `FaintBars`; error/empty strings → muted `bodyMedium`.

- [ ] **Step 4: `permission_rationale_page.dart`** — headline → `styles.displaySmall`, left-aligned (drop `textAlign: center` throughout, `crossAxisAlignment: CrossAxisAlignment.start`); body muted `bodyLarge`; `FilledButton('Sounds good')` → `BoardButton`; `TextButton('Not right now')` → `BoardButton(secondary: true)`. Keep `_continue` logic untouched.

- [ ] **Step 5: Update tests** preserving behavior (advance/gate/select/save flows, blocked state, permission request vs. skip, `/home` redirect). Copy finder update: `'You can switch later in More.'` → new string.

Run: `flutter test && flutter analyze` — green + clean.

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "onboarding: Ink & Rule sweep with selection-row exam picker"
```

---

### Task 10: Paywall + wrapped + legal sweep

**Files:**
- Modify: `lib/features/paywall/presentation/paywall_page.dart`, `paywall_package_card.dart` (rewrite), `subscription_panel.dart`, `pro_welcome_banner.dart`, `trial_notice_banner.dart`
- Delete: `lib/features/paywall/presentation/pro_upgrade_chip.dart`, `test/features/paywall/presentation/pro_upgrade_chip_test.dart` (unused pill+lock chip; the `SectionHeader` "Unlock with Pro" action is the identity's upgrade affordance — verify `grep -rn "ProUpgradeChip" lib test` shows only its own file+test first)
- Modify: `lib/features/wrapped/presentation/wrapped_reveal_page.dart`, `my_shared_cards_page.dart`, `share_privacy_sheet.dart`
- Modify: `lib/features/legal/presentation/legal_document_page.dart`
- Test: `test/features/paywall/`, `test/features/wrapped/`, `test/features/legal/` (update)

**Interfaces:**
- Consumes: existing domain (`PaywallPackage`, `PaywallSku`, `Entitlement`, `TrialNotice`, wrapped providers, `legalDocumentFallbacks`); kit widgets.
- Produces: `PaywallPackageCard` keeps its signature; everything else unchanged.

- [ ] **Step 1: `paywall_package_card.dart`** — hardcoded Tailwind greens and the pill die. Selection = the tint+border device; the "7 days free" pill → meta text; badge stays board-colored text:

```dart
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: colors.boardTint,
                border: Border.all(color: colors.board),
                borderRadius: BorderRadius.circular(5),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Text(
                badgeCopy,
                style: styles.labelSmall.copyWith(color: colors.board),
              ),
            Row(
              children: [
                Expanded(child: Text(title, style: styles.headlineSmall)),
                if (package.sku == PaywallSku.yearly)
                  Text(
                    '7 days free',
                    style: styles.labelSmall.copyWith(color: colors.board),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: styles.bodySmall.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
      ),
    );
```

(Keep the `title`/`subtitle` switch expressions verbatim — pricing copy is settled.) Delete `_Pill`.

- [ ] **Step 2: `paywall_page.dart`** — page padding `fromLTRB(20, 24, 20, 24)`; intro line muted `bodyMedium`; drop the `SizedBox(height: 10)` between cards (rules separate them); error text `const TextStyle(color: Colors.red)` → `styles.bodySmall.copyWith(color: colors.rust)`; `FilledButton` CTA → `BoardButton(label: ctaCopyFor(selected), onPressed: ...)` (keep the async purchase handler); `'Paid through Google Play.'` → muted `bodySmall`. Empty-packages state → muted `bodyMedium`.

- [ ] **Step 3: `subscription_panel.dart`** — `Card` → `RuledSection`; status line `bodyMedium`; the `TextButton` wrap → text actions in `labelLarge` board (Try Pro is the primary — make it `BoardButton`; `'Manage in Google Play'`/`'Restore purchases'` (sentence case fix) as quiet `GestureDetector` text in `labelLarge` board). **`pro_welcome_banner.dart`** — tinted `Card` → `RuledSection`: serif `"You're in."` (`headlineMedium`), close icon stays (16, inkMuted), body muted, `TextButton` → text action `labelLarge` board. **`trial_notice_banner.dart`** — `MaterialBanner` → the ruled-banner shape (reuse `ErrorBanner`? No — different semantics; build inline): `Container` with top+bottom hairline `rule` borders, two lines (`bodyMedium` ink headline, `bodySmall` muted body). Keep all copy.

- [ ] **Step 4: Delete `pro_upgrade_chip.dart`** + test (after the grep check).

- [ ] **Step 5: Wrapped** — `wrapped_reveal_page.dart`: slide `Card`/`ListTile`s → `InkTableRow(title: slide.title, subtitle: slide.body)`; page title serif `headlineMedium`; `FilledButton('Share PNG')` → `BoardButton` (label logic kept); `'pantas.app/wrapped'` → muted `labelSmall`; padding `fromLTRB(20, 24, 20, 24)`; loading → `FaintBars`. `my_shared_cards_page.dart`: `Card`/`ListTile` → `InkTableRow(title: card.title, subtitle: 'pantas.app/wrapped/${card.shareId}')` with the Revoke action as row `meta`? No — revoke needs a tap target distinct from the row: keep a trailing `GestureDetector` `Text('Revoke', style: labelLarge.copyWith(color: colors.rust))` in a plain hairline row built like `_TopicRow` (rust = destructive semantic). Empty state → serif `'No shared cards yet'` + muted body. `share_privacy_sheet.dart`: `SwitchListTile`s stay (themed switches now render board); the `Icons.public` disclosure row: icon 16 `inkMuted`, text muted `bodySmall`.

- [ ] **Step 6: Legal** — `legal_document_page.dart`: document title `displaySmall` (drop the duplicate AppBar/body divergence — AppBar keeps `document.title`); updated-label muted `bodySmall`; section headings `headlineSmall`; body `bodyMedium`; `Divider` is themed already; DPO heading `headlineSmall`; `FilledButton('Manage account data')` → `BoardButton(secondary: true)` (not the page's primary — it's a cross-link).

- [ ] **Step 7: Update tests** for all three features — preserve behavioral assertions (selection changes SKU, purchase callback with selected package, restore fires, revoke calls host+repo+invalidates, privacy toggles round-trip, legal fallback renders sections, manage-data routes). Copy finder: `'Restore Purchases'` → `'Restore purchases'`.

Run: `flutter test && flutter analyze` — green + clean.

- [ ] **Step 8: Commit**

```bash
git add lib test
git commit -m "paywall+wrapped+legal: Ink & Rule sweep, selection-row packages"
```

---

### Task 11: Settings sweep

**Files:**
- Modify: `lib/features/settings/presentation/settings_home_page.dart` (minor), `widgets/settings_section.dart` (rewrite), `widgets/settings_row.dart` (rewrite), `widgets/ios_switch.dart` (recolor), `pages/account_page.dart`, `pages/about_page.dart`, `pages/backup_page.dart`, `pages/delete_account_page.dart`
- Modify: `lib/app/router.dart` (the inline `/settings/subscription` Scaffold keeps its AppBar — no change needed; verify only)
- Test: `test/features/settings/` (update)

**Interfaces:**
- Consumes: existing settings providers/actions; kit.
- Produces: `SettingsSection({title, children})`, `SettingsRow({title, subtitle, trailing, onTap, destructive})` — signatures unchanged, visuals new. `IosSettingsSwitch` keeps its API but renders board-green.

- [ ] **Step 1: `settings_section.dart`** — kill `title.toUpperCase()`:

```dart
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(title: title),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 2: `settings_row.dart`** — `ListTile` → the InkTableRow anatomy with a trailing slot (InkTableRow has no `trailing` widget param, so build the row directly):

```dart
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final titleColor = destructive ? colors.rust : colors.ink;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.ruleFaint,
              // ignore: avoid_redundant_argument_values
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: styles.bodyMedium.copyWith(color: titleColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: styles.bodySmall
                          .copyWith(color: colors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 3: `ios_switch.dart`** — replace the hardcoded iOS green/gray: on = `colors.board`, off = `colors.rule` (progress/done-adjacent toggle — board is the budgeted "on" voice). Same geometry.

- [ ] **Step 4: Pages.** `settings_home_page.dart`: the theme row's inner `Padding(horizontal: 16)` → 20 to align with rows; everything else stands (rows/sections restyle via widgets). `account_page.dart`: `FilledButton('Sign in with Google')` → `BoardButton`; name `headlineMedium` serif, email muted; keep the sign-out `AlertDialog` (themed). `about_page.dart`: drop the book icon `Center`; app name `headlineMedium`, version muted `bodySmall`; `'LEGAL'`/`'DATA & PRIVACY'` raw caps `Text`s → `SectionHeader(title: 'Legal')` / `SectionHeader(title: 'Data & privacy')`; copyright block muted `bodySmall` (keep `textAlign: center` → change to start, left-aligned identity). `backup_page.dart`: headline `headlineMedium`; `OutlinedButton` → `BoardButton(secondary: true)`; `TextButton` show/hide → quiet text `labelLarge` board via `GestureDetector`; detail lines muted `bodySmall`. `delete_account_page.dart`: headline `headlineMedium`; body/muted lines; `OutlinedButton('Cancel')` → `BoardButton(secondary: true)`; the red `FilledButton` → the rust-filled treatment from Task 3's `_RustButton` (copy the same Container styling inline — rust bg, `onBoard` text, radius 5, spinner branch kept); page padding `fromLTRB(20, 24, 20, 24)`.

- [ ] **Step 5: Update settings tests** — preserve behavior (toggle callbacks, routes, sign-out confirm flow, delete flow incl. error retry copy, backup flush action). Caps-label finders → sentence case.

Run: `flutter test && flutter analyze` — green + clean.

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "settings: Ink & Rule sweep — ruled rows, board switch, sentence case"
```

---

### Task 12: Cleanup — aliases, legacy tokens, dead components

Everything below must be grep-verified dead before deletion; the repo's lint set does not surface `deprecated_member_use_from_same_package`, so grep is the tool, not the analyzer.

**Files:**
- Modify: `lib/core/ui/theme/app_colors.dart` (delete the alias block), `lib/core/ui/theme/app_dimensions.dart` (delete legacy tokens)
- Delete: `lib/core/ui/components/app_card.dart`, `app_button.dart`, `skeleton_loader.dart`, `coach_mark.dart`, `pro_gate_banner.dart`, `streak_banner.dart`, `sync_status_indicator.dart`, `inline_offline_banner.dart`
- Delete: `lib/features/metrics/atoms/home_atom_chip.dart`
- Delete matching tests: `test/core/ui/components/app_card_test.dart`, `app_button_test.dart`, `skeleton_loader_test.dart`, `coach_mark_test.dart`, `pro_gate_banner_test.dart`, `streak_banner_test.dart`, `sync_status_indicator_test.dart`, `inline_offline_banner_test.dart`, `test/features/metrics/atoms/home_atom_chip_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `AppColors` with only the eleven identity tokens; `AppDimensions` with only `radiusButton`, `radiusSurface`, `hairline`, `progressHeight`, `minTapTarget`.

- [ ] **Step 1: Verify each deletion target is dead** — for every file listed above:

```bash
for c in AppCard AppButton SkeletonBox SkeletonCard CoachMark ProGateBanner \
         StreakBanner SyncStatusIndicator InlineOfflineBanner HomeAtomChip; do
  echo "== $c"; grep -rn "\b$c\b" lib test --include="*.dart" \
    | grep -v "_test.dart" | grep -v "components/\(app_card\|app_button\|skeleton_loader\|coach_mark\|pro_gate_banner\|streak_banner\|sync_status_indicator\|inline_offline_banner\)" \
    | grep -v "atoms/home_atom_chip"; done
```

Expected: no hits outside the files being deleted. If a hit remains, an earlier task missed a call site — sweep it to the kit equivalent first (do not delete around it).

- [ ] **Step 2: Delete the files** (`git rm` each lib file and its test).

- [ ] **Step 3: Remove the alias block** from `app_colors.dart` — delete the comment plus all twelve `@Deprecated` getters (lines with `onSurface` through `errorContainer`). Then verify:

```bash
grep -rn "colors\.\(onSurface\|onSurfaceMuted\|border\b\|borderSelected\|primaryContainer\|successContainer\|warningContainer\|errorContainer\)" lib test --include="*.dart"
grep -rn "colors\.\(primary\|success\|warning\|error\)\b" lib test --include="*.dart"
```

Expected: zero hits (the second grep excludes `colorScheme.primary` etc. by requiring the `colors.` receiver — inspect any hit; `Theme.of(context).colorScheme.error` is fine and out of scope).

- [ ] **Step 4: Remove legacy dimension tokens** from `app_dimensions.dart`: `radiusXS`, `radiusSM`, `radiusMD`, `radiusLG`, `radiusXL`, `radiusFull`, `radiusPill`, `shadowSM`, `shadowMD`, `shadowLG`, `shadowPrimary`. Keep `radiusButton`, `radiusSurface`, `hairline`, `progressHeight`, `minTapTarget`. Grep first:

```bash
grep -rn "radiusXS\|radiusSM\|radiusMD\|radiusLG\|radiusXL\|radiusFull\|radiusPill\|shadowSM\|shadowMD\|shadowLG\|shadowPrimary" lib test --include="*.dart"
```

Any hit outside `app_dimensions.dart` is a missed sweep — replace it (radii → `radiusButton`/`radiusSurface`/literal per the swept pattern; shadows → delete, depth never comes from shadows) before removing the token.

- [ ] **Step 5: Run suite + analyze** — `flutter test && flutter analyze` → green, `No issues found!` (a compile failure here means a stale reference; the build catching it is the point of the deletion).

- [ ] **Step 6: Commit**

```bash
git add -A lib test
git commit -m "theme: remove transitional aliases, legacy tokens, dead components"
```

---

### Task 13: Spec annotation, glyph gut-check, emulator verification

**Files:**
- Modify: `docs/superpowers/specs/2026-07-18-ui-redesign-design.md` (annotations only)
- Possibly: `lib/core/ui/components/ink_table_row.dart` (only if the gut-check fails)

- [ ] **Step 1: Annotate the spec.** In Section 2's intro sentence, change `lib/core/ui/widgets/` to `lib/core/ui/components/` and append a bracketed note: `[Implementation note, 2026-07-19: kit lives in components/; InlineMeter shipped bar-only — the colored percentage renders beside it at call sites, not inside the widget.]` Add one line to the `InlineMeter` table row: `(bar only; caller renders the percentage)`.

- [ ] **Step 2: Full suite** — `flutter test` green.

- [ ] **Step 3: Launch the emulator** (AVD `pantas_pixel`): `~/Library/Android/sdk/emulator/emulator -avd pantas_pixel` (background, wait for boot), then `flutter run --flavor dev -t lib/main_dev.dart -d emulator-5554` backgrounded to a log; wait for the run banner.

- [ ] **Step 4: Drive and screenshot (light)** with `adb exec-out screencap -p`: onboarding (fresh-install path or `/onboarding`): welcome → age gate → picker with a selection made; Study tab (subject tables); a lesson list + lesson page (read + unread); Quiz tab; a running quiz question with a choice tapped (selected fill), post-answer toast; quiz completion + results; assessment results; `/plan`; `/settings` and each subpage (account, about, backup, subscription); `/paywall` with a package selected; `/legal/privacy`.

- [ ] **Step 5: Night pass** — `adb shell "cmd uimode night yes"` plus the in-app Dark setting; re-screenshot Quiz question (selected row), Study tab, Settings, Paywall. Restore Light + `night no`.

- [ ] **Step 6: Inspect against the identity checklist:** no pastel blocks, pill buttons, tinted icon circles, emoji, all-caps labels, shadows, or stock blue/green anywhere; the selected answer/exam/package row is the only tint+border fill on its screen; board only on primaries/progress/done-checks/unlock actions; rust/amber only on semantic values; night mode warm near-black with AA-passing text. **Gut-check the InkTableRow active glyph (○) color against the mock** (`.superpowers/brainstorm/73545-1784382720/content/` — the focus-topic rows in `header-final-v2.html`): if the mock's active marker reads board-green and the shipped glyph renders ink/muted, change the active glyph color to `colors.board` in `ink_table_row.dart` (progress-indicator budget line), update its test, and re-run the suite. If they already match, record that and change nothing.

- [ ] **Step 7: Report deviations** from the mocks with screenshots; fix only identity violations (copy/data gaps belong to the data plan).

- [ ] **Step 8: Commit** (only if Step 1/6 changed files):

```bash
git add docs lib test
git commit -m "docs: annotate spec for kit path and InlineMeter; glyph gut-check"
```

---

## After this plan

The identity sweep is complete app-wide. Next is the **data plan**: study-plan providers (days-to-exam figure), a lessons-count provider, and per-subject accuracy to fill the full approved Home stats band (42 days / 78% / 41-96 lessons composition) and the Progress tab's analytical panels (trend chart, weakness narrative, score impact, per-mock comparison). Mock exam routing (replacing the `/review` and `/mock-exam` `_Stub`s) remains a separate wiring task outside both plans.
