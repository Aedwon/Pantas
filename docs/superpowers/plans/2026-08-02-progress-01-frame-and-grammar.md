# Progress, Plan 1 of 6: The Frame, the Grammar and the Retained Order

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the panel-catalog machinery Progress runs on today with the page the new
spec describes, build the two row types every section below uses, and store the table's
sort, direction and level with a Settings row governing whether they are kept.

**Architecture:** The `ProgressPanel` catalog, its four enums and `PaywallTeaserPanel` are
deleted. `progress_page.dart` becomes a page with named sections and four states, and two
row components land in `lib/core/ui/components/`. Three preference keys, one Settings row.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-30-progress-tab-design.md` Sections 2, 6
("Retained order"), 8, 9 and 11.
**Decision log:** `docs/superpowers/decisions/2026-07-29-progress-tab-decision-log.md`.

---

## Why Progress is planned last, and six plans

It is downstream of almost everything: the onboarding name and date, the mistake tags Quiz
5 commits to producing, the carry-over filter from exam switching, Home's Practice
decision of 2 August, and mocks working for its pace column. Every one of those is now
decided or planned, which is what finally made this plannable.

The split follows the spec's own three destinations plus the four sections of the tab:

| Plan | What | Why separate |
|---|---|---|
| **1**, this one | The frame, the grammar, the stored order | Everything below draws rows with it, and it deletes a machinery no later plan should build against |
| 2 | Your pace | Wholly Free, one panel, one sentence of arithmetic |
| 3 | Performance | The table, its head as sort controls, the level control. The largest by far |
| 4 | Why you miss questions | The only wholly Pro section on the tab |
| 5 | How you work | A sub-screen |
| 6 | Your record | A sub-screen, wholly Free |

## What this plan waits on

| Waits on | For what | If it has not landed |
|---|---|---|
| `2026-08-02-quiz-tab-02a-frame-and-panel.md` | `RuledPanel` | **Blocking** |
| `2026-08-02-home-03-masthead-and-band.md` Task 1 | `RuledPanel`'s `action` slot | **Not blocking.** This plan uses no panel action; Plan 5 does |

## What this plan deletes, and why that is safe

- **`lib/features/progress/domain/progress_panel.dart`** and its four enums
  (`ProgressPanelIntent`, `ProgressPanelContent`, `ProgressPanelAccess`,
  `ProgressPanelWindow`). The new tab has named sections in a fixed order, not a catalog
  with intents and windows. Keeping the catalog would mean every later plan registering
  itself in a registry that models nothing the spec describes.
- **`progress_panelsForEntitlement`** in `progress_providers.dart`. The Free and Pro rule
  is now per section, in Section 7, and three of the five sections are wholly Free.
- **`lib/features/progress/presentation/paywall_teaser_panel.dart`.** Spec Section 11.2
  retires it from Progress by name. The treatment is `FaintBars` where figures would sit,
  plus one line of prose and "Unlock with Pro" in board green.
- **The four `_analytical` stubs** printing "Charts land here in an upcoming update.", the
  `_milestonesPanel`, and the `_SignalStatsPanel` that returns `SizedBox.shrink()`.

**Milestones are deliberately absent from the new design.** Do not preserve the panel.
Its provenance is real (four Wrapped artifacts, `user_metrics_artifacts_local`, the
shipped stub) but its form was never designed, and it gets its own pass.

**`PaywallTeaserPanel` may have callers outside Progress.** Run
`grep -rn "PaywallTeaserPanel" lib test` before deleting the file. If Wrapped or another
surface uses it, leave the file and only stop Progress importing it, and say so in the
commit body.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand and never committed.**
- **Check `lib/core/ui/components/` before writing any widget.**
- **Ink & Rule identity.** No card elevation, no shadows, no large radii, no tinted
  callouts, no coloured left borders, **no blur, no lock icons, no banners, no
  interstitials, never shimmer**.
- **The evidentiary rule, Section 1.** Every figure on this tab is measured from the
  student's own use, published by the testing body, or the output of a named algorithm
  used as designed. **No figure may be the product of a measurement and an assumption.**
  Two facts may sit side by side and let the reader combine them; the app does not do the
  multiplication and print the result.
- **Voice.** Grade-5-simple English, **no em dashes**, sentence case. Stat labels
  lowercase. Scores are **points**, never "marks". **The words FSRS, stability, retention,
  retrievability, algorithm and card never appear in a user-facing string.**
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
| `lib/core/ui/components/data_row_tile.dart` (create) | Title, subtext, two right-aligned figure columns |
| `lib/core/ui/components/navigational_row.dart` (create) | Serif title, subtitle, chevron |
| `lib/features/progress/application/table_order_prefs.dart` (create) | The three keys, their repository, and the retain flag |
| `lib/features/progress/presentation/progress_page.dart` (rewrite) | App bar, exam name, four states, the section slots |
| `lib/features/settings/presentation/pages/settings_page.dart` (modify) | One row, "Remember how the table is sorted" |
| `lib/features/progress/domain/progress_panel.dart` (delete) | |
| `lib/features/progress/presentation/paywall_teaser_panel.dart` (delete, conditionally) | |

---

### Task 1: The two row types

**Files:**
- Create: `lib/core/ui/components/data_row_tile.dart`
- Create: `lib/core/ui/components/navigational_row.dart`
- Test: `test/core/ui/components/data_row_tile_test.dart`
- Test: `test/core/ui/components/navigational_row_test.dart`

**Interfaces:**
- Produces:

```dart
class DataRowTile extends StatelessWidget {
  const DataRowTile({
    required this.title,
    this.subtext,
    this.primaryFigure,
    this.secondaryFigure,
    this.primaryIsActive = true,
    this.primaryColor,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtext;

  /// Right-aligned, 52px wide. Null renders an empty column, never a dash.
  final String? primaryFigure;
  final String? secondaryFigure;

  /// The active column is `ink` at 600 and may carry a severity colour.
  /// The inactive one is `inkMuted` at 400 and never carries colour.
  final bool primaryIsActive;
  final Color? primaryColor;
  final VoidCallback? onTap;
}

class NavigationalRow extends StatelessWidget {
  const NavigationalRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });
}
```

**The grammar, Section 8, and every number in it is load-bearing:**

- **Data rows:** sans 14/400 title, subtext on its own line in 12px `inkMuted`, figures in
  sans **13/600 tabular**, figure columns **52px**.
- **Navigational rows:** serif 14/700 with a chevron.
- Rows are **30 tall with 4px padding**. **Tappable rows keep the same visual box**: the
  44px touch target is padded past it with `MaterialTapTargetSize.padded`. A 44px visual
  floor put 12px of air around every title and was the spacing fault caught on the sixth
  pass. **Do not use `InkTableRow`**, which has `minHeight: 44` and 8px vertical padding;
  that is the shape this component exists to replace on this tab.
- **A null figure renders an empty column**, never a dash and never a zero.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('a data row is 30 tall plus 4px padding, not 44', (tester) async {
    await tester.pumpWidget(
      harness(const DataRowTile(title: 'Chemistry', primaryFigure: '31%')),
    );
    expect(tester.getSize(find.byType(DataRowTile)).height, 38);
  });

  testWidgets('a tappable row keeps the same visual box', (tester) async {
    await tester.pumpWidget(
      harness(DataRowTile(title: 'Chemistry', onTap: () {})),
    );
    expect(tester.getSize(find.byType(DataRowTile)).height, 38);
  });

  testWidgets('a tappable row still reaches 44 of touch target',
      (tester) async {
    await tester.pumpWidget(
      harness(DataRowTile(title: 'Chemistry', onTap: () {})),
    );
    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(
      inkWell.materialTapTargetSize ?? MaterialTapTargetSize.padded,
      MaterialTapTargetSize.padded,
    );
  });

  testWidgets('a null figure is an empty column, never a dash or a zero',
      (tester) async {
    await tester.pumpWidget(
      harness(const DataRowTile(title: 'Chemistry', primaryFigure: null)),
    );
    expect(find.text('-'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.text('0%'), findsNothing);
  });

  testWidgets('the inactive column is muted at 400 and carries no colour',
      (tester) async {
    await tester.pumpWidget(
      harness(
        DataRowTile(
          title: 'Chemistry',
          primaryFigure: '31%',
          secondaryFigure: '48s',
          primaryIsActive: false,
          primaryColor: AppColors.light.rust,
        ),
      ),
    );
    final primary = tester.widget<Text>(find.text('31%'));
    expect(primary.style?.color, AppColors.light.inkMuted);
    expect(primary.style?.fontWeight, FontWeight.w400);
  });

  testWidgets('figures are tabular', (tester) async {
    await tester.pumpWidget(
      harness(const DataRowTile(title: 'Chemistry', primaryFigure: '31%')),
    );
    final figure = tester.widget<Text>(find.text('31%'));
    expect(
      figure.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('a navigational row is serif 14/700 with a chevron',
      (tester) async {
    await tester.pumpWidget(
      harness(
        NavigationalRow(
          title: 'How you work',
          subtitle: 'Night-Owl Sprinter. Sharpest at 9 pm, in 8 minute sits.',
          onTap: () {},
        ),
      ),
    );
    final title = tester.widget<Text>(find.text('How you work'));
    expect(title.style?.fontFamily, 'SourceSerif4');
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
```

- [ ] **Step 2: Run them to make sure they fail**

Run: `flutter test test/core/ui/components/data_row_tile_test.dart test/core/ui/components/navigational_row_test.dart`
Expected: FAIL, unresolved imports.

- [ ] **Step 3: Write both components**

- [ ] **Step 4: Run the tests and make sure they pass**

Expected: PASS, 7 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/ui/components/data_row_tile.dart lib/core/ui/components/navigational_row.dart test/core/ui/components/data_row_tile_test.dart test/core/ui/components/navigational_row_test.dart
git commit -m "feat(ui): add the data row and the navigational row

Rows are 30 tall with 4px padding and tappable rows keep the same
visual box, padding the 44px target past it. A 44px visual floor put
12px of air around every title and was the spacing fault caught on the
sixth pass.

A null figure renders an empty column, never a dash and never a zero."
```

---

### Task 2: The stored order, and the Settings row that governs it

**Files:**
- Create: `lib/features/progress/application/table_order_prefs.dart`
- Modify: `lib/features/settings/presentation/pages/settings_page.dart`
- Test: `test/features/progress/application/table_order_prefs_test.dart`

**Interfaces:**
- Consumes: `AppPreferencesRepository` (`lib/core/storage/data/repos/app_preferences_repository.dart`),
  which already reads and writes `device_prefs` rows by key.
- Produces:

```dart
enum TableSortKey { score, time }
enum TableSortDirection { ascending, descending }
enum TableLevel { subject, topic, lesson }

@immutable
class TableOrder {
  const TableOrder({
    required this.sortKey,
    required this.direction,
    required this.level,
  });

  /// Weakest first, which is the actionable direction. Sorting Score
  /// descending is the deliberate other case: it is the view a student
  /// screenshots.
  static const TableOrder defaults = TableOrder(
    sortKey: TableSortKey.score,
    direction: TableSortDirection.ascending,
    level: TableLevel.subject,
  );
}

final tableOrderProvider =
    AsyncNotifierProvider<TableOrderNotifier, TableOrder>(...);
final retainTableOrderProvider = FutureProvider<bool>(...);
```

**Three preference keys**, per Section 10: the sort key, the direction, and the level.
**Plus the Settings flag** governing whether they are retained.

**Retention is on by default.** Section 6: the chosen sort, direction and level survive
leaving and returning to the tab, stored silently, with no dialogue on change. The Study
spec's rule is the reason: a prompt on every sort change punishes exploring. The Settings
row exists so a student who wants the table to open the same way every time can say so,
following the precedent that quiz ordering is a setting rather than a rule.

**With retention off, the tab opens on `TableOrder.defaults` every time** and changes
still apply within the visit. Off does not mean the controls stop working.

**The Settings row:**

> **Remember how the table is sorted**
> Progress opens the way you left it.        [ on ]

- [ ] **Step 1: Write the failing test**

```dart
  test('the default is Score ascending at Subject level', () async {
    expect(await notifier.load(), TableOrder.defaults);
  });

  test('a chosen order survives a reload', () async {
    await notifier.setSortKey(TableSortKey.time);
    await notifier.setLevel(TableLevel.topic);

    expect((await freshNotifier.load()).sortKey, TableSortKey.time);
    expect((await freshNotifier.load()).level, TableLevel.topic);
  });

  test('with retention off, a reload returns the defaults', () async {
    await settings.setRetainTableOrder(false);
    await notifier.setSortKey(TableSortKey.time);

    expect(await freshNotifier.load(), TableOrder.defaults);
  });

  test('with retention off, a change still applies within the visit',
      () async {
    await settings.setRetainTableOrder(false);
    await notifier.setSortKey(TableSortKey.time);

    expect(notifier.state.value?.sortKey, TableSortKey.time);
  });

  test('an unrecognised stored value falls back to the default', () async {
    await prefs.set('progress_table_sort', 'wibble');
    expect((await notifier.load()).sortKey, TableSortKey.score);
  });
```

- [ ] **Step 2 to 4: fail, implement, pass**

- [ ] **Step 5: Add the Settings row and test it**

```dart
  testWidgets('the settings row toggles retention', (tester) async {
    await tester.pumpWidget(settingsHarness());
    await tester.pumpAndSettle();

    expect(find.text('Remember how the table is sorted'), findsOneWidget);
    expect(find.text('Progress opens the way you left it.'), findsOneWidget);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(await repo.retainTableOrder(), isFalse);
  });
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(progress): store the table's sort, direction and level

Retained by default and changed with no dialogue: a prompt on every sort
change punishes exploring, which is the Study spec's rule. A Settings row
turns it off for a student who wants the table to open the same way every
time, following the precedent that quiz ordering is a setting."
```

---

### Task 3: The page, its states, and the section slots

**Files:**
- Rewrite: `lib/features/progress/presentation/progress_page.dart`
- Delete: `lib/features/progress/domain/progress_panel.dart`
- Modify: `lib/features/progress/application/progress_providers.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/progress/presentation/progress_page_test.dart`

**Interfaces:**
- Consumes: `activeExamFocusProvider`, `entitlementProvider`, `RuledPanel`,
  `NavigationalRow`, `EmptyState`, `ErrorBanner`, `FaintBars`.
- Produces: `class ProgressPage extends ConsumerWidget` and **five build methods returning
  `const SizedBox.shrink()`**: `_yourPaceSection`, `_performanceSection`,
  `_whyYouMissSection`, `_goDeeperSection`, and a `_dayOne` guard. Plans 2 to 6 each
  replace exactly one.

**Composition, top to bottom:** app bar "Progress", the exam short name in serif 22/700
beneath it, then Your pace, Performance, Why you miss questions, and the Go deeper rows.
**The tab opens on the diagnosis, not on a menu**, which is why the two navigational rows
sit at the bottom, after the content.

**`ProgressPage` stops taking `proIsActive` as a constructor argument.** The router
currently reads `entitlementProvider` and passes a bool
(`lib/app/router.dart:124-131`). The Free and Pro rule is now per section, so each section
reads the entitlement itself and the router's builder becomes
`(_, __) => const ProgressPage()`.

**The four states:**

| State | Treatment |
|---|---|
| Loading | `FaintBars`: 7px paper-toned bars at `ruleFaint`, radius 2, 5px vertical margins. **Never gray blocks, never shimmer** |
| Error | `ErrorBanner` in its error variant: 3px `rust` accent, rules top and bottom, "Could not load your progress. Pull down to try again." **Never the exception string** |
| No exam chosen | The existing fallback: "Choose your exam" over "Pick the exam you are reviewing for." and a board "Choose exam" |
| Day one | The invitation below |

**Day one, and this is the tab's whole reason for being rewritten.** A student with no
attempts sees an invitation, not a table of zeros. There is no progress to report for
someone who has not started, and manufacturing one would be the dishonesty this tab was
rewritten to avoid. The assessment is **not** part of onboarding (it lives at
`/assessment/:examId` on its own), so a new user genuinely can arrive here with nothing.

`EmptyState` with:
- headline `Nothing to report yet`
- body `Take the assessment and this fills in. It takes about twenty minutes and it is how
  Pantas learns where you are.`
- a board **`Take the assessment`** routing to `/assessment/:examId`
- a secondary text link to `/mock-exam`

**Partial states are per section, not per tab.** A student who has taken the assessment
but sat no mock sees Performance without its Time column and How you work with two
tendencies showing "Not enough data yet". Do not add a second whole-tab gate for those.

**The Go deeper rows carry each screen's verdict as a subtitle:**

- **How you work**, "Night-Owl Sprinter. Sharpest at 9 pm, in 8 minute sits."
- **Your record**, "Day 18. Best mock 68%, up 11 since May."

**Leave `_goDeeperSection` a stub here.** Plans 5 and 6 each add their own row when they
build the screen it points at, so no plan ships a row leading nowhere.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('opens on the diagnosis, with Go deeper last', (tester) async {
    await tester.pumpWidget(harness(hasAttempts: true));
    await tester.pumpAndSettle();

    final paceY = tester.getTopLeft(find.text('Your pace')).dy;
    final deeperY = tester.getTopLeft(find.text('Go deeper')).dy;
    expect(paceY, lessThan(deeperY));
  });

  testWidgets('day one shows an invitation and never a zero', (tester) async {
    await tester.pumpWidget(harness(hasAttempts: false));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to report yet'), findsOneWidget);
    expect(find.text('Take the assessment'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('an error never shows the exception string', (tester) async {
    await tester.pumpWidget(harnessThatThrows('PlatformException(42)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PlatformException'), findsNothing);
    expect(
      find.text('Could not load your progress. Pull down to try again.'),
      findsOneWidget,
    );
  });

  testWidgets('loading is faint bars, never shimmer or gray blocks',
      (tester) async {
    await tester.pumpWidget(harnessLoading());
    await tester.pump();

    expect(find.byType(FaintBars), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('no exam shows the existing fallback', (tester) async {
    await tester.pumpWidget(harness(examId: null));
    await tester.pumpAndSettle();
    expect(find.text('Choose your exam'), findsOneWidget);
  });

  testWidgets('milestones are gone', (tester) async {
    await tester.pumpWidget(harness(hasAttempts: true));
    await tester.pumpAndSettle();
    expect(find.text('Milestones'), findsNothing);
    expect(find.textContaining('Charts land here'), findsNothing);
  });

  testWidgets('no banned word appears anywhere', (tester) async {
    await tester.pumpWidget(harness(hasAttempts: true));
    await tester.pumpAndSettle();

    for (final word in [
      'FSRS', 'stability', 'retention', 'retrievability', 'algorithm',
      'marks', '—',
    ]) {
      expect(find.textContaining(word), findsNothing);
    }
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/progress/`
Expected: FAIL.

- [ ] **Step 3: Write the page**

- [ ] **Step 4: Delete the catalog and the teaser panel**

```bash
grep -rn "PaywallTeaserPanel" lib test
grep -rn "ProgressPanel\|progressPanelCatalog\|progressPanelsForEntitlement" lib test
```

Delete `progress_panel.dart` and the catalog. Delete `paywall_teaser_panel.dart` **only if
the first grep shows no caller outside Progress**; otherwise leave the file and stop
Progress importing it.

- [ ] **Step 5: Simplify the router**

```dart
              GoRoute(
                path: '/progress',
                builder: (_, __) => const ProgressPage(),
              ),
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
git commit -m "refactor(progress): rebuild the tab's frame and delete the panel catalog

The catalog modelled intents, windows and a per-panel access flag that
the new design does not have: the tab is three destinations with named
sections in a fixed order. PaywallTeaserPanel is retired from this tab by
the spec.

Day one shows an invitation, never a table of zeros. There is no progress
to report for someone who has not started, and manufacturing one is the
dishonesty this tab was rewritten to avoid.

The entitlement moves out of the router and into each section, because
the Free and Pro rule is now per section and three of five are wholly
free."
```

---

## What this plan deliberately leaves undone

Every section. Plans 2 to 6 fill the five stubs. This plan is the frame, the grammar and
the storage, and it is reviewable on its own because it deletes a machinery and replaces
four fake panels with four honest states.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` clean.
- `grep -rn "ProgressPanel" lib` returns nothing.
- `grep -rn "toString()" lib/features/progress` returns nothing.
- `grep -rni "fsrs\|stability\|algorithm\|retrievability" lib/features/progress` returns
  nothing.
- A student with no attempts sees the invitation and no figure at all.
- Sorting state survives killing and reopening the app, and stops surviving when the
  Settings row is off.
- Report as text signals and ask Aedwon to look. Never screenshot the emulator.
