# Ink & Rule Reference Sweep (Plan 2A) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the Ink & Rule identity to the app's navigation spine — Material ColorScheme, shell nav (Home | Study | Quiz | Progress with Settings behind Home's gear), the Progress tab, and the Home tab as the reference implementation — plus the kit-hardening items ordered by Plan 1's branch review.

**Architecture:** Visual/navigation sweep on existing data only. Panels whose data chain is unwired (study-plan pace, per-mock analytics) render as identity-styled placeholders or teasers; no new aggregation layers are built here. Remaining feature screens and the deprecated-alias removal are Plan 2B; new data providers (days-to-exam, lessons count, per-subject accuracy) are the data plan.

**Tech Stack:** Flutter 3.44 / Material 3, Riverpod, go_router `StatefulShellRoute`, the Plan 1 kit in `lib/core/ui/components/`.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-18-ui-redesign-design.md` including its Amendments section (nav structure, header composition, teaser treatment) — normative.
- NEVER add AI/Claude attribution or Co-Authored-By trailers to commits (project rule).
- No emojis in UI copy; sentence case; stat labels lowercase; color budget: board green only on primary action/progress/done-checks; rust/amber only on semantic values.
- Do NOT remove the deprecated `AppColors` alias getters — Plan 2B does that after the full sweep.
- Analyzer baseline is fully clean (`No issues found!`) and must stay so. Lint conventions: `very_good_analysis` — required named params before `super.key`, trailing commas, ≤ 80 char lines, prefer int literals.
- Full `flutter test` suite green before every commit. When a task changes a screen's structure, update that screen's existing tests preserving their behavioral assertions (routes pushed, states shown) — never delete a behavior check to get green.
- Before consuming a provider, read its definition first; if a request object's fields differ from what this plan assumes, adapt the call site while preserving the stated intent, and note it in your report.
- Run from repo root `/Users/aedwon/Documents/Projects/Pantas`; `flutter` on PATH.

---

### Task 1: Explicit ColorScheme override + dark visualDensity

**Files:**
- Modify: `lib/core/ui/theme/app_theme.dart`
- Test: `test/core/ui/theme/app_theme_test.dart` (extend)

**Interfaces:**
- Consumes: `AppColors.light/.dark` tokens.
- Produces: `buildLightTheme()`/`buildDarkTheme()` whose `colorScheme` fields equal the identity tokens exactly (`primary == board`, `surface == surface`, `onSurface == ink`, `error == rust`, `surfaceTint` transparent). Every later screen task relies on Material defaults (dialogs, snackbars, text) matching the identity.

- [ ] **Step 1: Write the failing tests** — append to `test/core/ui/theme/app_theme_test.dart`:

```dart
  test('light scheme overrides Material-seeded colors with identity tokens',
      () {
    final scheme = buildLightTheme().colorScheme;
    const c = AppColors.light;
    expect(scheme.primary, c.board);
    expect(scheme.onPrimary, c.onBoard);
    expect(scheme.surface, c.surface);
    expect(scheme.onSurface, c.ink);
    expect(scheme.error, c.rust);
    expect(scheme.outline, c.rule);
    expect(scheme.surfaceTint, Colors.transparent);
  });

  test('dark scheme overrides Material-seeded colors with identity tokens',
      () {
    final scheme = buildDarkTheme().colorScheme;
    const c = AppColors.dark;
    expect(scheme.primary, c.board);
    expect(scheme.onPrimary, c.onBoard);
    expect(scheme.surface, c.surface);
    expect(scheme.onSurface, c.ink);
    expect(scheme.error, c.rust);
    expect(scheme.outline, c.rule);
    expect(scheme.surfaceTint, Colors.transparent);
  });

  test('dark theme sets adaptive visual density', () {
    expect(
      buildDarkTheme().visualDensity,
      VisualDensity.adaptivePlatformDensity,
    );
  });
```

Add `import 'package:flutter/material.dart';` if not present.

- [ ] **Step 2: Run to verify failure**

Run: `flutter test test/core/ui/theme/app_theme_test.dart`
Expected: FAIL — seeded scheme colors differ from tokens.

- [ ] **Step 3: Implement** — in `lib/core/ui/theme/app_theme.dart` replace both builders:

```dart
ThemeData buildLightTheme() => _buildTheme(AppColors.light, Brightness.light);

ThemeData buildDarkTheme() => _buildTheme(AppColors.dark, Brightness.dark);

ThemeData _buildTheme(AppColors colors, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1D5C50),
    brightness: brightness,
  ).copyWith(
    primary: colors.board,
    onPrimary: colors.onBoard,
    secondary: colors.board,
    onSecondary: colors.onBoard,
    surface: colors.surface,
    onSurface: colors.ink,
    error: colors.rust,
    onError: colors.onBoard,
    outline: colors.rule,
    outlineVariant: colors.ruleFaint,
    surfaceTint: Colors.transparent,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: [colors, AppTextStyles.create()],
  );
}
```

Keep the `AppThemeContext` extension unchanged. (`surfaceTint: Colors.transparent` kills M3 elevation tinting — flat surfaces are the identity.)

- [ ] **Step 4: Run tests + suite + analyze**

Run: `flutter test test/core/ui/theme/ && flutter analyze` then full `flutter test`. Widget tests asserting old seeded Material colors may fail — update expectations to the token values.
Expected: all green, `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/theme test
git commit -m "theme: override Material ColorScheme with identity tokens"
```

---

### Task 2: Kit hardening (branch-review carry-overs)

**Files:**
- Modify: `lib/core/ui/components/progress_rule.dart`, `inline_meter.dart`, `stats_band.dart`, `ink_table_row.dart`
- Test: `test/core/ui/components/progress_rule_test.dart`, `stats_band_test.dart`, `ink_table_row_test.dart`, `test/core/ui/theme/app_colors_test.dart` (extend)

**Interfaces:**
- Consumes: existing kit APIs (unchanged signatures).
- Produces: NaN-safe meters; `StatsBand` asserts non-empty figures; `InkTableRow` min row height 44; `AppColors.lerp` round-trip coverage. No API changes.

- [ ] **Step 1: Write the failing tests**

Append to `test/core/ui/components/progress_rule_test.dart`:

```dart
  testWidgets('ProgressRule treats NaN as zero', (tester) async {
    await tester.pumpWidget(harness(const ProgressRule(value: double.nan)));
    final fill = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(fill.widthFactor, 0.0);
  });
```

Append to `test/core/ui/components/stats_band_test.dart`:

```dart
  test('StatsBand asserts on empty figures', () {
    expect(
      () => StatsBand(figures: const []),
      throwsAssertionError,
    );
  });
```

Append to `test/core/ui/components/ink_table_row_test.dart`:

```dart
  testWidgets('row meets minimum height', (tester) async {
    await tester.pumpWidget(harness(const InkTableRow(title: 'Row')));
    final size = tester.getSize(find.byType(InkTableRow));
    expect(size.height, greaterThanOrEqualTo(44));
  });
```

Append to `test/core/ui/components/board_button_test.dart` (dark-theme smoke — first dark render coverage in the kit):

```dart
  testWidgets('primary renders night board color under dark theme',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildDarkTheme(),
      home: Scaffold(
        body: BoardButton(label: 'Continue', onPressed: () {}),
      ),
    ));
    final ink = tester.widget<Ink>(find.descendant(
      of: find.byType(BoardButton),
      matching: find.byType(Ink),
    ));
    expect((ink.decoration as BoxDecoration?)?.color, AppColors.dark.board);
  });
```

Append to `test/core/ui/theme/app_colors_test.dart`:

```dart
  test('lerp at t=1 lands exactly on the other palette', () {
    final lerped = AppColors.light.lerp(AppColors.dark, 1);
    expect(lerped.background, AppColors.dark.background);
    expect(lerped.surface, AppColors.dark.surface);
    expect(lerped.ink, AppColors.dark.ink);
    expect(lerped.inkMuted, AppColors.dark.inkMuted);
    expect(lerped.rule, AppColors.dark.rule);
    expect(lerped.ruleFaint, AppColors.dark.ruleFaint);
    expect(lerped.board, AppColors.dark.board);
    expect(lerped.boardTint, AppColors.dark.boardTint);
    expect(lerped.onBoard, AppColors.dark.onBoard);
    expect(lerped.rust, AppColors.dark.rust);
    expect(lerped.amber, AppColors.dark.amber);
  });
```

- [ ] **Step 2: Run to verify failures**

Run: `flutter test test/core/ui/components/ test/core/ui/theme/app_colors_test.dart`
Expected: the four new tests FAIL (NaN crashes the assert in FractionallySizedBox; no assert on empty figures; row height ~37; lerp passes already if correct — if it passes, keep it as a pin).

- [ ] **Step 3: Implement**

In `progress_rule.dart` and `inline_meter.dart`, replace the clamp expression:

```dart
    final factor = value.isNaN ? 0.0 : value.clamp(0.0, 1.0).toDouble();
```

and use `widthFactor: factor`.

In `stats_band.dart` constructor:

```dart
  const StatsBand({required this.figures, super.key})
      : assert(figures.length > 0, 'StatsBand needs at least one figure');
```

(`figures.length > 0` not `isNotEmpty` — const assert constraints.)

In `ink_table_row.dart`, wrap the padded row container's child so the whole tappable row meets 44:

```dart
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(alignment: Alignment.centerLeft, child: row),
      ),
```

(44, not 48: rows are dense tabular UI; 44 matches the review's recommendation. Keep the existing vertical padding.)

- [ ] **Step 4: Run kit tests + full suite + analyze** — all green, `No issues found!`. If existing height-sensitive tests break (none known), update per the constraint rules.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components test
git commit -m "components: NaN guards, StatsBand assert, InkTableRow min height, lerp pin"
```

---

### Task 3: Shell nav restyle + branch swap (Progress in, Settings out)

**Files:**
- Modify: `lib/features/shell/presentation/app_shell.dart` (rewrite `_AppNavBar`/`_NavItem`)
- Modify: `lib/app/router.dart` (branch 4, `/settings`, `/more`, remove top-level `/progress`)
- Test: existing shell/router tests (update)

**Interfaces:**
- Consumes: `context.colors`, `context.textStyles`, `AppDimensions.hairline`, existing `ProgressPage`, `SettingsHomePage({String subscriptionSubtitle})`, `entitlementProvider`, `_subscriptionSubtitle(...)` (already in router.dart).
- Produces: shell tabs **Home | Study | Quiz | Progress** (text-only labels per the approved mock); `/settings` is a full-screen page route; `/more` redirects to `/settings`; `ProgressPage` reachable as branch 4. Task 5's gear navigates to `/settings`.

- [ ] **Step 1: Update router** — in `lib/app/router.dart`:

Replace the fourth `StatefulShellBranch` (currently `/more` → `SettingsHomePage`) with:

```dart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (_, __) {
                  final entitlement =
                      ref.watch(entitlementProvider).valueOrNull ??
                          const Entitlement.free();
                  return ProgressPage(proIsActive: entitlement.proIsActive);
                },
              ),
            ],
          ),
```

Delete the top-level `/progress` GoRoute (currently around line 242–249).

Replace the `/settings` redirect route (`redirect: (_, __) => '/more'`) with a page route:

```dart
      GoRoute(
        path: '/settings',
        builder: (_, __) {
          final entitlement = ref.watch(entitlementProvider).valueOrNull ??
              const Entitlement.free();
          return SettingsHomePage(
            subscriptionSubtitle: _subscriptionSubtitle(entitlement),
          );
        },
      ),
      GoRoute(
        path: '/more',
        redirect: (_, __) => '/settings',
      ),
```

`SettingsHomePage` renders full-screen (it has its own Scaffold; verify — if it lacks a back affordance when pushed, wrap: `Scaffold(appBar: AppBar(...))` is NOT the identity; instead confirm go_router's page transition provides pop via system back, which is sufficient for this task; a styled back header for Settings is Plan 2B's settings sweep).

- [ ] **Step 2: Rewrite the nav bar** — in `app_shell.dart`, replace `_AppNavBar` and `_NavItem`:

```dart
class _AppNavBar extends StatelessWidget {
  const _AppNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _labels = ['Home', 'Study', 'Quiz', 'Progress'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.rule,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                _NavItem(
                  label: _labels[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: styles.labelLarge.copyWith(
              color: isActive ? colors.ink : colors.inkMuted,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
```

Remove now-unused imports (`AppDimensions` stays — hairline; drop icon-related ones). Flat bar: no floating container, no radius, no shadow, text-only labels per the approved mock.

- [ ] **Step 3: Run the full suite** — update failing shell/router tests: tab labels (`Settings` → `Progress`), `/more` expectations → `/settings`, icon finders → text finders, preserving each test's behavioral intent (tapping tab N switches branch, etc.).

Run: `flutter test && flutter analyze`
Expected: green, `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib test
git commit -m "shell: Ink & Rule nav — Progress tab in, Settings behind /settings route"
```

---

### Task 4: Progress page — identity restyle + real identity data

**Files:**
- Modify: `lib/features/progress/presentation/progress_page.dart` (rewrite)
- Modify: `lib/features/progress/presentation/paywall_teaser_panel.dart` (rewrite as "unprinted" teaser)
- Test: existing progress tests (update) + new widget test `test/features/progress/presentation/progress_page_test.dart` (create or extend existing)

**Interfaces:**
- Consumes: `progressPanelsForEntitlement({required bool proIsActive})`, `ProgressPanel`/`ProgressPanelAccess`/`ProgressPanelContent`; `activeExamFocusProvider`; `currentArchetypeProvider(CurrentArchetypeRequest(...))`; `metricsSignalProvider(MetricsSignalRequest(...))` for `SignalKey.consistency` and `SignalKey.coverageBreadth`; kit widgets `SectionHeader`, `StatsBand`, `RuledSection`.
- Produces: `ProgressPage({required bool proIsActive})` (signature unchanged; router untouched from Task 3). Free and Pro render the same panel list; analytical panels show teasers (Free) or an identity-styled "coming soon" quiet state (Pro — their real content ships with the data plan).

- [ ] **Step 1: Rewrite `paywall_teaser_panel.dart`** — the approved "unprinted" treatment (no locks, no blur):

```dart
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// "Unprinted" teaser for Pro-gated analytical panels: the heading prints,
/// the content renders as faint paper-toned bars, and the header's trailing
/// slot carries the unlock affordance.
class PaywallTeaserPanel extends StatelessWidget {
  const PaywallTeaserPanel({
    required this.title,
    required this.onUnlock,
    super.key,
  });

  final String title;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget bar(double widthFactor) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor,
          child: Container(
            height: 7,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: colors.ruleFaint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          action: 'Unlock with Pro',
          onAction: onUnlock,
        ),
        const SizedBox(height: 4),
        bar(0.92),
        bar(0.7),
        bar(0.83),
      ],
    );
  }
}
```

Note the constructor changes from `{required ProgressPanel panel}` to `{required String title, required VoidCallback onUnlock}` — update all call sites (only `progress_page.dart`) and tests.

- [ ] **Step 2: Rewrite `progress_page.dart`**:

```dart
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/features/progress/application/progress_providers.dart';
import 'package:cse_cet_reviewer/features/progress/domain/progress_panel.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/paywall_teaser_panel.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({required this.proIsActive, super.key});

  final bool proIsActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final focus = ref.watch(activeExamFocusProvider).valueOrNull;
    final examId = focus?.exam?.id;
    final panels = progressPanelsForEntitlement(proIsActive: proIsActive);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('Progress', style: styles.displaySmall),
        if (examId == null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Pick your exam to start tracking progress.',
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
          )
        else
          for (final panel in panels)
            _ProgressPanelSection(panel: panel, examId: examId),
      ],
    );
  }
}
```

`_ProgressPanelSection` is a `ConsumerWidget` switching on `panel.id`:

- `'archetype'` (identity): watch `currentArchetypeProvider` with a request for this exam (read the request class definition; use the rolling-30d window if a window field exists). Null/loading/error → render nothing (spec: null means skip). Non-null:

```dart
        RuledSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your profile',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted)),
              const SizedBox(height: 2),
              Text(archetype.label, style: styles.headlineMedium),
              const SizedBox(height: 2),
              Text(archetype.synthesis,
                  style: styles.bodySmall.copyWith(color: colors.inkMuted)),
            ],
          ),
        )
```

(Adapt field names `label`/`synthesis` to the actual `CurrentArchetype` class.)

- `'signal_stats'` (identity): watch `metricsSignalProvider` for `SignalKey.consistency` (all-time) and `SignalKey.coverageBreadth` (all-time). Build `StatsBand` figures from the non-null results only — e.g. streak days → `StatFigure(value: '$days', label: 'day streak')`, coverage → `StatFigure(value: '$pct%', label: 'syllabus touched')` (read `StreakPattern`/`CoveragePct` for exact fields). If both null, render nothing. Wrap in `RuledSection(topRule: false, padding: EdgeInsets.zero)` — StatsBand rules itself.

- `'trend_lines'`, `'weakness_narrative'`, `'best_mock'` (analytical): if `panel.access == ProgressPanelAccess.teaser` → `PaywallTeaserPanel(title: <title>, onUnlock: () => context.push('/paywall'))`; else (Pro) →

```dart
        RuledSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: title),
              const SizedBox(height: 4),
              Text(
                'Charts land here in an upcoming update.',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        )
```

Titles (sentence case, no jargon): trend_lines → 'Accuracy trend', weakness_narrative → "Where you're slipping", best_mock → 'Mock exams'.

- `'wrapped_history_stub'` (identity): `RuledSection` + `SectionHeader(title: 'Milestones')` + muted line `'No milestone cards yet — they appear at streaks and mock records.'`.

Wrap the whole widget in padding-free sections; every section separated by `RuledSection`'s hairline.

- [ ] **Step 3: Tests** — update/replace existing progress tests. New assertions (use a ProviderScope with overrides for `activeExamFocusProvider`, archetype/signal providers returning fixed values or nulls, per existing test-helper patterns in `test/`):

```dart
  testWidgets('free user sees teaser with unlock affordance', ...);
  testWidgets('pro user sees coming-soon panel, no unlock text', ...);
  testWidgets('archetype panel renders label when provider resolves', ...);
  testWidgets('null signals render no stats band', ...);
```

Write real assertions (find.text('Unlock with Pro') etc.). Follow existing override patterns in the repo's tests for these providers.

- [ ] **Step 4: Run suite + analyze** — green + clean.

- [ ] **Step 5: Commit**

```bash
git add lib/features/progress test
git commit -m "progress: Ink & Rule restyle with identity data and unprinted teasers"
```

---

### Task 5: Home tab reference implementation

**Files:**
- Modify: `lib/features/assessment/presentation/assessment_home_tab.dart` (rewrite presentation composition; keep provider logic)
- Modify: `lib/app/router.dart` (drop the `afterHeaderBuilder` wiring; `_HomeMetricsAtomSlot` moves into the tab)
- Test: existing assessment home tests (update)

**Interfaces:**
- Consumes: `activeExamFocusProvider`, `assessmentResultProvider(examId)` (→ `AssessmentResult.topicMasteries`: `TopicMastery{topic, correct, total, accuracy, level}` — read the class for exact fields), `homeAtomProvider(HomeAtomRequest(...))` (→ `AtomChip{text, metric, proDepth}`), kit widgets, routes `/settings`, `/assessment/:examId`, `/quiz/quick/:examId`, `/assessment/:examId/results`, study route used by the current `_StudyPlanRow`.
- Produces: the approved Home composition. Data constraints (explicit, decided): the stats band shows **accuracy** (aggregate of `topicMasteries`: `sum(correct)/sum(total)`, skip band if no assessment) and **topics** (`mastered-or-strong count / total topics` — pick the level threshold from `TopicMastery.level`'s actual enum, e.g. strong+). "Days to exam" and "lessons done" figures are DEFERRED to the data plan (study-plan providers are unwired stubs; no lesson-count provider exists) — do not fake them.

- [ ] **Step 1: Rewrite the tab.** Keep `AssessmentHomeTab` as a `ConsumerWidget` watching the same two providers with the same loading/error/needs-selection branches (restyle those states too — see below). Remove the `afterHeaderBuilder` parameter entirely. New selected-exam composition (`ListView`, padding `EdgeInsets.fromLTRB(20, 24, 20, 24)`):

1. **Header** — per approved mock:

```dart
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(DateTime.now()),
                      style: styles.bodySmall
                          .copyWith(color: colors.inkMuted)),
                  const SizedBox(height: 1),
                  Text(exam.shortName, style: styles.displaySmall),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: Icon(Icons.settings_outlined,
                  size: 20, color: colors.inkMuted),
              tooltip: 'Settings',
            ),
          ],
        ),
```

with

```dart
String _greeting(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Magandang umaga,';
  if (h < 18) return 'Magandang hapon,';
  return 'Magandang gabi,';
}
```

(`exam.shortName` — read `ActiveExamFocus`'s exam type for the right display-name field; the masthead is the exam name for now — personal-name greeting waits for the auth surface, noted deviation from the mock.)

2. **Stats band** (only when an assessment result exists):

```dart
        StatsBand(figures: [
          StatFigure(
            value: '$accuracyPct%',
            label: 'accuracy',
          ),
          StatFigure(
            value: '$strongCount',
            suffix: '/$totalTopics',
            label: 'topics strong',
          ),
        ]),
```

3. **Lately line** (the metrics atom; render only when the atom resolves non-null):

```dart
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.rule,
                // ignore: avoid_redundant_argument_values
                width: AppDimensions.hairline,
              ),
            ),
          ),
          child: Text.rich(
            TextSpan(
              text: 'Lately — ',
              style: styles.bodySmall.copyWith(color: colors.inkMuted),
              children: [
                TextSpan(text: chip.text),
              ],
            ),
          ),
        ),
```

Construct `HomeAtomRequest` per its definition (examId + whatever date/window fields it has).

4. **Focus topics** (replaces `_StudyPlanCard`): `SectionHeader(title: 'Focus topics', action: 'View results', onAction: → '/assessment/$examId/results')`, then the top-3 masteries as `InkTableRow`s (title = topic name, meta = `'$accuracyPct%'`; keep each row's existing tap action from `_StudyPlanRow` — study route), then `BoardButton(label: 'Continue studying', onPressed: → the first topic's study route)`.

5. **No-assessment state** (replaces `_NoAssessmentCard`): serif headline `'Build your study plan'` (headlineMedium), muted body line, `BoardButton('Start the assessment')` → `/assessment/$examId`, `BoardButton(secondary: true, 'Try a quick quiz')` → `/quiz/quick/$examId`.

6. **Choose-exam state** (`_ChooseExamHome`): serif headline `'Choose your exam'`, muted line, `BoardButton('Get started')` → `/onboarding`.

7. **Loading state**: three full-width faint bars (same visual as the teaser bars: height 7, `ruleFaint`, radius 2, widths 0.9/0.65/0.8) — no spinners, no gray cards. **Error state**: serif `'Something went wrong'`, muted detail, `BoardButton(secondary: true, 'Try again', onPressed: → ref.invalidate(...))` per current retry behavior.

Color budget check before committing: board appears only on BoardButton primaries and SectionHeader actions; rust/amber only if used for low-accuracy meta values (optional: color topic accuracy < 50% rust, < 70% amber, else ink — matches the approved mock's weakest-areas treatment).

- [ ] **Step 2: Update the router** — branch 1 becomes:

```dart
              GoRoute(
                path: '/home',
                builder: (_, __) => const AssessmentHomeTab(),
              ),
```

Delete `_HomeMetricsAtomSlot` from router.dart (its logic now lives in the tab). Remove unused imports.

- [ ] **Step 3: Update tests** — rewrite `assessment_home_tab` tests to the new structure, preserving behavioral assertions: needs-selection shows Get started → /onboarding; no-assessment shows the two CTAs with correct routes; selected+result shows topic rows and View results action; error state retries. Add: gear pushes `/settings`; stats band absent without a result. Follow the repo's existing router/provider test harness patterns.

- [ ] **Step 4: Run suite + analyze** — green + clean.

- [ ] **Step 5: Commit**

```bash
git add lib test
git commit -m "home: Ink & Rule reference implementation with gear settings and stats band"
```

---

### Task 6: Emulator verification against approved mocks

**Files:** none expected (test-expectation fixes only if the run surfaces them).

- [ ] **Step 1:** Full `flutter test` — green.
- [ ] **Step 2:** Launch on the emulator (AVD `pantas_pixel`; `~/Library/Android/sdk/emulator/emulator -avd pantas_pixel`, wait for boot, `flutter run --flavor dev -t lib/main_dev.dart -d emulator-5554` backgrounded to a log; wait for the run banner).
- [ ] **Step 3:** Drive and screenshot (light mode, `adb exec-out screencap -p`): Home tab; tap the gear → Settings pushes full-screen and pops back; each nav tab (Study, Quiz, Progress); Progress panels (teasers visible on Free).
- [ ] **Step 4:** Repeat Home + Progress in night mode (`adb shell "cmd uimode night yes"` AND in-app theme setting to Dark if a stored preference overrides; restore Light + `night no` after).
- [ ] **Step 5:** Inspect every screenshot: flat hairline nav bar with Progress tab; header matches the approved composition (kicker/name left, centered gear right); stats band serif numerals; Lately line; no pastel blocks, no pill buttons, no floating nav, no stock blue; night mode warm near-black. Report deviations from the approved mocks (`.superpowers/brainstorm/73545-1784382720/content/header-final-v2.html` and `progress.html` are the reference).
- [ ] **Step 6:** Commit only if test files changed:

```bash
git add test && git commit -m "test: expectation updates from reference-sweep verification"
```

---

## After this plan

Plan 2B sweeps the remaining features (onboarding, study, lesson, quiz, assessment, review, mock_exam, metrics surfaces, wrapped, paywall, notifications, settings, auth_flow, legal), removes the deprecated `AppColors` aliases (grep-driven — the repo's lint set does not surface `deprecated_member_use_from_same_package`), annotates the spec (`components/` path; `InlineMeter` bar-only), and gut-checks the InkTableRow active-glyph color against the mock. The data plan wires study-plan providers (days-to-exam figure), a lessons-count provider, and per-subject accuracy for the full approved stats band and Progress analytical panels.
