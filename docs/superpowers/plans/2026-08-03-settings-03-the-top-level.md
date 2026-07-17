# Settings 03: the top level

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
`.day`. `monthStart` is unchanged and still available. Nothing else in this plan moves.

---

**Goal:** Replace `settings_home_page.dart` with the twelve-row, five-group ledger, and delete the four Spec 8 widgets it leaves behind.

**Architecture:** One `ConsumerWidget` assembling `SettingsGroup` and `SettingsValueRow` from Plan 01 over the providers widened in Plan 02. Rows whose destination is built in a later plan get a `TODO`-free stub route that pushes an honest "not built yet" page, so nothing in this plan pretends to be finished.

**Tech Stack:** Flutter, Riverpod, go_router, `flutter_test`.

**Source spec:** `docs/superpowers/specs/2026-08-03-settings-design.md`, Sections 2 and 3.

**Decision log:** `docs/superpowers/decisions/2026-08-03-settings-log.md`.

## AMENDED 4 August 2026: "How you practice" gains a switch

**A control was stored in the tree and reachable from nothing.** The study plan's pace lever
existed as a saved value with no row anywhere in Settings, so a student could not reach it.

**Add one switch to the "How you practice" group**, between "How sessions are built" and "Strict
mock mode":

> **Do more each day**
> Your plan already paces you to finish everything before your exam. Turn this on to go faster
> and leave yourself more time to review.

- **It is a switch, not a three-way choice.** A Light, Standard and Intense sheet was drafted
  first and two of its three options did nothing: the plan's pace is already the minimum that
  finishes the material in time, so there is no slower setting to offer.
- **Off is the default, and off is not a lesser mode.** It is the pace that keeps the promise.
- **It carries a subtitle.** With this row there are exactly **two** subtitled switches on this
  screen, this one and strict mock mode, and they are the only two that change what the app will
  do rather than how it looks. Any test asserting "only one subtitle" must be updated.
- **The stored value collapses from a three-way to a boolean.** Migrate the old `intense` to on
  and everything else to off.
- **This row replaces the 5/10/20/30/50 new-card selector** that
  `2026-05-17-quiz-engine-and-modes-design.md` D7 asked for. **Do not build both.** Two controls
  for one number is how they end up disagreeing, and D7's selector is struck.

**The group now holds four rows**, so the count in "Done when" moves from twelve to thirteen.

---

## Global Constraints

- **American spelling** in every string, comment and identifier.
- **No em dashes** anywhere. The current page uses a hyphen surrounded by spaces in three subtitles; all three strings are being deleted.
- **Settings governs persistence and defaults, never visibility.** No row on this page may hide, disable or badge a control anywhere, including for Free students.
- **`context.push`, never `context.go`.** Every destination sits outside the tab shell and relies on the back arrow, which only appears when the stack can pop.
- **No Material app bar.** The bar is a back chevron at 19px `inkMuted` then a serif 17/700 title.
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
| `2026-08-03-settings-01-the-kit.md` | `SettingsGroup`, `SettingsValueRow`, `SettingsSwitch`, `ThemeControl` | **Blocking** |
| `2026-08-03-settings-02-storage.md` | `UserSettings.name`, `.examDate` as `ExamDate?`, `.carryOverProgress`, `.sessionOrdering`, `.retainTableOrder` | **Blocking** |

## File structure

| File | Responsibility |
|---|---|
| `lib/core/ui/components/settings_bar.dart` (create) | The back chevron and serif title, shared by every Settings page. |
| `lib/features/settings/presentation/settings_home_page.dart` (rewrite) | The twelve rows in five groups. |
| `lib/features/settings/presentation/settings_value_formats.dart` (create) | The value column strings, so the page holds no formatting logic. |
| `lib/features/settings/presentation/pages/not_built_yet_page.dart` (create) | The honest stub behind rows whose destination is a later plan. |
| `lib/app/router.dart` (modify) | `/settings/exam`, `/settings/ordering`, retire `/settings/subscription` in favor of `/settings/pro`. |
| `lib/features/settings/presentation/widgets/ios_switch.dart` (delete) | Banned by the identity. |
| `lib/features/settings/presentation/widgets/settings_row.dart` (delete) | Replaced by `SettingsValueRow`. |
| `lib/features/settings/presentation/widgets/settings_section.dart` (delete) | Replaced by `SettingsGroup`. |
| `lib/features/settings/presentation/widgets/theme_segmented_control.dart` (delete) | Replaced by `ThemeControl`. |

---

## Task 1: The bar, and the value formats

**Files:**
- Create: `lib/core/ui/components/settings_bar.dart`
- Create: `lib/features/settings/presentation/settings_value_formats.dart`
- Test: `test/features/settings/presentation/settings_value_formats_test.dart`

**Interfaces:**
- Consumes: `ExamDate` and `SessionOrdering` from Plan 02, `SyncStatus` from `lib/core/sync/sync_status.dart`, `AuthUser` from `lib/core/auth/auth_user.dart`.
- Produces:

```dart
class SettingsBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsBar({required this.title, super.key});
  final String title;
}

abstract final class SettingsValueFormats {
  static String examDate(ExamDate? date);
  static String name(String? name);
  static String onOff(bool value);
  static String account({required AuthUser? user, required bool isAnonymous});
  static String backup({required bool isAnonymous, required SyncStatus? status});
}
```

**The exam date format is the evidentiary rule in code.** At month precision it prints the month and never a day, and no format in this file ever prints a day count.

**The account row shows a state, not an email.** An address does not fit the value column and truncating one is worse than not printing it. The address lives on the Account page.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/presentation/settings_value_formats_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/settings_value_formats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a day-precision date prints the day', () {
    expect(
      SettingsValueFormats.examDate(ExamDate.day(DateTime(2026, 10, 12))),
      '12 Oct 2026',
    );
  });

  test('a month-precision date prints the month and never a day', () {
    final printed = SettingsValueFormats.examDate(const ExamDate.month(2026, 10));

    expect(printed, 'October 2026');
    expect(printed.contains('1'), isTrue); // the year, and nothing else
    expect(printed.contains('01'), isFalse);
  });

  test('no exam date reads Not set', () {
    expect(SettingsValueFormats.examDate(null), 'Not set');
  });

  test('no format anywhere prints a day count', () {
    final printed = [
      SettingsValueFormats.examDate(ExamDate.day(DateTime(2026, 10, 12))),
      SettingsValueFormats.examDate(const ExamDate.month(2026, 10)),
      SettingsValueFormats.examDate(null),
    ];
    for (final value in printed) {
      expect(value.toLowerCase().contains('day'), isFalse);
      expect(value.toLowerCase().contains('to go'), isFalse);
    }
  });

  test('an absent name invites one', () {
    expect(SettingsValueFormats.name(null), 'Add your name');
    expect(SettingsValueFormats.name('Aedwon'), 'Aedwon');
  });

  test('the backup value is one word per state', () {
    expect(
      SettingsValueFormats.backup(isAnonymous: true, status: null),
      'Not backed up',
    );
    expect(
      SettingsValueFormats.backup(
        isAnonymous: false,
        status: const Syncing(pendingCount: 3),
      ),
      'Backing up',
    );
    expect(
      SettingsValueFormats.backup(isAnonymous: false, status: const SyncIdle()),
      'Saved',
    );
  });

  test('no format contains an em dash', () {
    final all = [
      SettingsValueFormats.name(null),
      SettingsValueFormats.examDate(null),
      SettingsValueFormats.onOff(true),
      SettingsValueFormats.backup(isAnonymous: true, status: null),
    ];
    for (final value in all) {
      expect(value.contains('—'), isFalse);
    }
  });
}
```

Adjust the `SyncStatus` constructors to match the real ones in `lib/core/sync/sync_status.dart` before running; the names above follow what `settings_home_page.dart` currently pattern-matches on.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/presentation/settings_value_formats_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the formats**

Create `lib/features/settings/presentation/settings_value_formats.dart`:

```dart
import 'package:cse_cet_reviewer/core/auth/auth_user.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';

/// Every string that lands in the value column.
///
/// It lives apart from the page so the evidentiary rule is testable on its
/// own: no function here prints a day count, and the exam date prints a month
/// when a month is all the student gave us.
abstract final class SettingsValueFormats {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String examDate(ExamDate? date) {
    if (date == null) return 'Not set';
    final day = date.exactDay;
    if (day != null) {
      return '${day.day} ${_shortMonths[day.month - 1]} ${day.year}';
    }
    final month = date.monthStart;
    return '${_months[month.month - 1]} ${month.year}';
  }

  static String name(String? name) => name ?? 'Add your name';

  static String onOff(bool value) => value ? 'On' : 'Off';

  static String account({
    required AuthUser? user,
    required bool isAnonymous,
  }) {
    if (user != null && !isAnonymous) return 'Signed in';
    return 'Not signed in';
  }

  static String backup({
    required bool isAnonymous,
    required SyncStatus? status,
  }) {
    if (isAnonymous) return 'Not backed up';
    return switch (status) {
      Syncing() => 'Backing up',
      SyncPartialFailure() || SyncFailedSince() => "Couldn't back up",
      SyncOk() || SyncIdle() => 'Saved',
      null => 'Not backed up',
    };
  }
}
```

- [ ] **Step 4: Write the bar**

Create `lib/core/ui/components/settings_bar.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The Settings bar: a back chevron and a serif title, and nothing else.
///
/// Not a Material AppBar. Spec 8 asked for a large app bar and the identity
/// bans it, along with its elevation and its title animation.
class SettingsBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsBar({required this.title, super.key});

  final String title;

  static const double height = 46;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final canPop = Navigator.of(context).canPop();

    return SizedBox(
      height: height,
      child: Row(
        children: [
          if (canPop)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: SizedBox(
                width: 30,
                height: height,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '‹',
                    style: styles.bodyLarge.copyWith(
                      fontSize: 19,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
          Text(
            title,
            style: styles.headlineSmall.copyWith(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run the tests and commit**

Run: `flutter test test/features/settings/presentation/settings_value_formats_test.dart`
Expected: PASS, 7 tests.

```bash
git add lib/core/ui/components/settings_bar.dart lib/features/settings/presentation/settings_value_formats.dart test/features/settings/presentation/settings_value_formats_test.dart
git commit -m "feat: the settings bar, and the value column formats"
```

---

## Task 2: The stub destination

**Files:**
- Create: `lib/features/settings/presentation/pages/not_built_yet_page.dart`
- Test: none. This page exists to be deleted and testing it would only make deleting it harder.

**Interfaces:**
- Produces: `NotBuiltYetPage({required String title})`.

**Why this exists rather than a dead row.** Three rows on the top level point at pages built in Plans 04, 05 and 06. A row that does nothing when tapped is a defect a student will report; a row that says what is coming is honest. **Every use of this page is removed by the end of Plan 06**, and the file is deleted with the last one.

- [ ] **Step 1: Write the page**

Create `lib/features/settings/presentation/pages/not_built_yet_page.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_bar.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Temporary destination for a row whose page lands in a later plan.
///
/// Delete this file when its last caller goes, at the end of Plan 06.
class NotBuiltYetPage extends StatelessWidget {
  const NotBuiltYetPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsBar(title: title),
          const SizedBox(height: 24),
          Text(
            'This screen is not built yet.',
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
flutter analyze
git add lib/features/settings/presentation/pages/not_built_yet_page.dart
git commit -m "chore: an honest stub for the three rows whose pages land later"
```

---

## Task 3: The page

**Files:**
- Rewrite: `lib/features/settings/presentation/settings_home_page.dart`
- Rewrite: `test/features/settings/presentation/settings_home_page_test.dart`

**Interfaces:**
- Consumes: everything from Task 1, Plan 01's four components, and the providers `userSettingsProvider`, `themePreferenceProvider`, `themePreferenceControllerProvider`, `settingsActionsProvider`, `currentUserProvider`, `isAnonymousProvider`, `syncStatusProvider`, `notificationPermissionStatusProvider`, `activeExamFocusProvider`.
- Produces: `SettingsHomePage()`. **The `subscriptionSubtitle` constructor argument is removed**; the Pro row reads the entitlement from its provider like every other row reads its own state.

- [ ] **Step 1: Write the failing test**

Replace `test/features/settings/presentation/settings_home_page_test.dart` entirely:

```dart
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/theme_control.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:cse_cet_reviewer/features/settings/domain/user_settings.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/settings_home_page.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

UserSettings _settings({
  String? name,
  ExamDate? examDate,
  bool strictMockMode = false,
  bool retainTableOrder = true,
}) {
  return UserSettings(
    name: name,
    dailyReminderTime: null,
    examDate: examDate,
    strictMockMode: strictMockMode,
    helpImproveApp: true,
    carryOverProgress: true,
    sessionOrdering: SessionOrdering.interleavedTail,
    retainTableOrder: retainTableOrder,
    updatedAt: null,
  );
}

Future<void> _pump(WidgetTester tester, UserSettings settings) {
  return tester.pumpAppWithProviders(
    const SettingsHomePage(),
    overrides: [
      userSettingsProvider.overrideWith((ref) async => settings),
    ],
  );
}

void main() {
  testWidgets('the top level has five groups in the specified order',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    final headings = tester
        .widgetList<SettingsGroup>(find.byType(SettingsGroup))
        .map((group) => group.title)
        .toList();

    expect(headings, [
      'You',
      'How you practice',
      'What you see',
      'Your account',
      'About',
    ]);
  });

  testWidgets('the top level has twelve rows', (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(find.byType(SettingsValueRow), findsNWidgets(12));
  });

  testWidgets('no heading is all-caps', (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    for (final group
        in tester.widgetList<SettingsGroup>(find.byType(SettingsGroup))) {
      expect(group.title, isNot(group.title.toUpperCase()));
    }
  });

  testWidgets('a month-precision date prints its month and no day count',
      (tester) async {
    await _pump(tester, _settings(examDate: const ExamDate.month(2026, 10)));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.textContaining('days'), findsNothing);
  });

  testWidgets('an absent name invites one', (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(find.text('Add your name'), findsOneWidget);
  });

  testWidgets('the switch appears on exactly the two switch rows',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    // Strict mock mode and Remember table order. Help improve the app moved
    // to the About page in Plan 06.
    expect(find.byType(SettingsSwitch), findsNWidgets(2));
  });

  testWidgets('the theme control is in the row, not behind a page',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(find.byType(ThemeControl), findsOneWidget);
  });

  testWidgets('the table order row uses the short title that fits the column',
      (tester) async {
    await _pump(tester, _settings());
    await tester.pumpAndSettle();

    expect(find.text('Remember table order'), findsOneWidget);
    expect(find.text('Remember how the table is sorted'), findsNothing);
  });

  testWidgets('tapping a switch row toggles it without needing the switch '
      'itself', (tester) async {
    await _pump(tester, _settings(strictMockMode: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Strict mock mode'));
    await tester.pumpAndSettle();

    // The provider override is static, so this asserts only that the row is
    // tappable and does not throw. The write path is covered in Plan 02.
    expect(find.text('Strict mock mode'), findsOneWidget);
  });

  testWidgets('no string on the page contains an em dash', (tester) async {
    await _pump(tester, _settings(name: 'Aedwon'));
    await tester.pumpAndSettle();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.contains('—') ?? false, isFalse);
    }
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/presentation/settings_home_page_test.dart`
Expected: FAIL. The old page renders `SettingsSection` and `SettingsRow`, so the group and row assertions fail.

- [ ] **Step 3: Rewrite the page**

Replace `lib/features/settings/presentation/settings_home_page.dart` entirely:

```dart
import 'dart:async';

import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_bar.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/theme_control.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/settings_value_formats.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings, reached by the gear in Home's masthead. There is no Settings tab.
///
/// Twelve rows in five groups, all on one scroll. Sub-pages exist only where a
/// surface has states or a list too long for a row. The four-door version and
/// the identity-plate version were both drawn and rejected.
class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final theme =
        ref.watch(themePreferenceProvider).valueOrNull ?? ThemePreference.system;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isAnonymous = ref.watch(isAnonymousProvider).valueOrNull ?? false;
    final syncStatus = ref.watch(syncStatusProvider).valueOrNull;
    final notificationsDenied =
        ref.watch(notificationPermissionStatusProvider).valueOrNull ==
            NotificationPermission.denied;
    final actions = ref.read(settingsActionsProvider);

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'Settings'),
          SettingsGroup(
            title: 'You',
            isFirst: true,
            children: [
              SettingsValueRow(
                title: 'Name',
                value: SettingsValueFormats.name(settings.name),
                onTap: () => _push(context, '/settings/name'),
              ),
              SettingsValueRow(
                title: 'Exam',
                value: ref.watch(activeExamShortNameProvider),
                showChevron: true,
                onTap: () => _push(context, '/settings/exam'),
              ),
              SettingsValueRow(
                title: 'Exam date',
                value: SettingsValueFormats.examDate(settings.examDate),
                onTap: () => _push(context, '/settings/exam-date'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'How you practice',
            children: [
              SettingsValueRow(
                title: 'How sessions are built',
                value: settings.sessionOrdering.label,
                showChevron: true,
                onTap: () => _push(context, '/settings/ordering'),
              ),
              SettingsValueRow(
                title: 'Strict mock mode',
                control: SettingsSwitch(value: settings.strictMockMode),
                onTap: () => unawaited(
                  actions.setStrictMockMode(enabled: !settings.strictMockMode),
                ),
              ),
              SettingsValueRow(
                title: 'Daily reminder',
                value: notificationsDenied
                    ? 'Notifications are off'
                    : settings.dailyReminderTime?.storageValue ?? 'Off',
                onTap: notificationsDenied
                    ? () => unawaited(
                          ref
                              .read(notificationServiceProvider)
                              .openAppNotificationSettings(),
                        )
                    : () => _push(context, '/settings/reminder'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'What you see',
            children: [
              SettingsValueRow(
                title: 'Remember table order',
                control: SettingsSwitch(value: settings.retainTableOrder),
                onTap: () => unawaited(
                  actions.setRetainTableOrder(
                    enabled: !settings.retainTableOrder,
                  ),
                ),
              ),
              SettingsValueRow(
                title: 'Theme',
                control: ThemeControl(
                  value: theme,
                  onChanged: (next) => unawaited(
                    ref
                        .read(themePreferenceControllerProvider.notifier)
                        .setThemePreference(next),
                  ),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Your account',
            children: [
              SettingsValueRow(
                title: 'Pro',
                value: ref.watch(proRowValueProvider),
                showChevron: true,
                onTap: () => _push(context, '/settings/pro'),
              ),
              SettingsValueRow(
                title: 'Account',
                value: SettingsValueFormats.account(
                  user: currentUser,
                  isAnonymous: isAnonymous,
                ),
                showChevron: true,
                onTap: () => _push(context, '/settings/account'),
              ),
              SettingsValueRow(
                title: 'Backup',
                value: SettingsValueFormats.backup(
                  isAnonymous: isAnonymous,
                  status: syncStatus,
                ),
                showChevron: true,
                onTap: () => _push(context, '/settings/backup'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'About',
            children: [
              SettingsValueRow(
                title: 'Version, privacy, feedback',
                showChevron: true,
                onTap: () => _push(context, '/settings/about'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Push, never go. Every destination sits outside the tab shell and relies
  /// on a back arrow, which only appears when the stack can pop.
  static void _push(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    if (router != null) unawaited(router.push<void>(location));
  }
}
```

- [ ] **Step 4: Add the two read-only providers the page needs**

Append to `lib/features/settings/application/settings_providers.dart`:

```dart
/// The active exam's short name, for the Exam row's value column.
final activeExamShortNameProvider = Provider<String>((ref) {
  return ref.watch(activeExamFocusProvider).valueOrNull?.shortName ?? 'Not set';
});

/// The Pro row's value. Free students see "Free" and every other row on the
/// screen is unchanged: no row is hidden, disabled or badged by entitlement.
final proRowValueProvider = Provider<String>((ref) {
  final entitlement = ref.watch(entitlementProvider).valueOrNull;
  return entitlement != null && entitlement.isPro ? 'Pro' : 'Free';
});
```

Check the real names on `activeExamFocusProvider` and `entitlementProvider` before writing this and match them; if the exam focus object exposes `shortName` under a different name, use the real one. Do not invent a field.

- [ ] **Step 5: Run the tests and confirm they pass**

Run: `flutter test test/features/settings/presentation/settings_home_page_test.dart`
Expected: PASS, 10 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/features/settings test/features/settings
git commit -m "feat: the settings top level, twelve rows in five groups"
```

---

## Task 4: The routes, and deleting the Spec 8 widgets

**Files:**
- Modify: `lib/app/router.dart`
- Delete: `lib/features/settings/presentation/widgets/ios_switch.dart`
- Delete: `lib/features/settings/presentation/widgets/settings_row.dart`
- Delete: `lib/features/settings/presentation/widgets/settings_section.dart`
- Delete: `lib/features/settings/presentation/widgets/theme_segmented_control.dart`
- Modify: `test/features/settings/presentation/settings_widgets_test.dart` (delete the four widget tests)
- Test: `test/app/router_settings_test.dart` (create)

**Interfaces:**
- Produces: routes `/settings/name`, `/settings/exam-date`, `/settings/reminder`, `/settings/ordering`, `/settings/exam`, `/settings/pro`.

`/settings/subscription` is retired in favor of `/settings/pro`, because the row is called Pro and a route that does not match its row is a trap for the next reader. **Keep a redirect from the old path** so any deep link already in the wild still lands.

- [ ] **Step 1: Write the failing test**

Create `test/app/router_settings_test.dart`:

```dart
import 'package:cse_cet_reviewer/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every settings row has a route to land on', () {
    const required = [
      '/settings',
      '/settings/name',
      '/settings/exam',
      '/settings/exam-date',
      '/settings/ordering',
      '/settings/reminder',
      '/settings/pro',
      '/settings/account',
      '/settings/backup',
      '/settings/about',
    ];

    final paths = collectRoutePaths();

    for (final path in required) {
      expect(paths, contains(path), reason: 'missing route $path');
    }
  });

  test('the retired subscription path still redirects', () {
    expect(collectRoutePaths(), contains('/settings/subscription'));
  });
}
```

`collectRoutePaths()` is a small test seam. Add it to `lib/app/router.dart`:

```dart
/// Flattens the router's declared paths. Exists so a test can assert that
/// every Settings row has somewhere to land.
List<String> collectRoutePaths() {
  final paths = <String>[];
  void visit(List<RouteBase> routes) {
    for (final route in routes) {
      if (route is GoRoute) paths.add(route.path);
      visit(route.routes);
    }
  }

  visit(buildAppRoutes());
  return paths;
}
```

If `router.dart` builds its routes inline inside a `GoRouter(...)` call rather than in a named function, extract them into `List<RouteBase> buildAppRoutes()` first and have the `GoRouter` call it. That extraction is part of this step.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/app/router_settings_test.dart`
Expected: FAIL, missing `/settings/name`.

- [ ] **Step 3: Add the routes**

In `lib/app/router.dart`, add beside the existing `/settings/...` routes:

```dart
      GoRoute(
        path: '/settings/name',
        builder: (_, __) => const NotBuiltYetPage(title: 'Name'),
      ),
      GoRoute(
        path: '/settings/exam-date',
        builder: (_, __) => const NotBuiltYetPage(title: 'Exam date'),
      ),
      GoRoute(
        path: '/settings/reminder',
        builder: (_, __) => const NotBuiltYetPage(title: 'Daily reminder'),
      ),
      GoRoute(
        path: '/settings/ordering',
        builder: (_, __) =>
            const NotBuiltYetPage(title: 'How sessions are built'),
      ),
      GoRoute(
        path: '/settings/exam',
        builder: (_, __) => const NotBuiltYetPage(title: 'Exam'),
      ),
```

Rename the existing `/settings/subscription` route's path to `/settings/pro`, keeping its builder, and add:

```dart
      GoRoute(
        path: '/settings/subscription',
        redirect: (_, __) => '/settings/pro',
      ),
```

Import `NotBuiltYetPage`.

**Plan 04 replaces the name, exam-date, reminder and ordering builders. Plan 05 replaces the exam builder.** Each of those plans deletes the stub it consumes.

- [ ] **Step 4: Delete the four Spec 8 widgets**

```bash
git rm lib/features/settings/presentation/widgets/ios_switch.dart
git rm lib/features/settings/presentation/widgets/settings_row.dart
git rm lib/features/settings/presentation/widgets/settings_section.dart
git rm lib/features/settings/presentation/widgets/theme_segmented_control.dart
```

Run `flutter analyze` and fix every resulting import error by pointing at the Plan 01 component instead. `delete_account_page.dart`, `account_page.dart`, `backup_page.dart` and `about_page.dart` are the likely callers; swap `SettingsRow` for `SettingsValueRow` and `SettingsSection` for `SettingsGroup` in each, leaving their copy alone. **Those four pages are redesigned in Plans 05 and 06; here they only need to compile and keep their tests green.**

Delete the four widget tests from `test/features/settings/presentation/settings_widgets_test.dart`. If that leaves the file empty, delete the file.

- [ ] **Step 5: Run the whole gate**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
```

Expected: all clean, all green.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: route every settings row, and delete the four Spec 8 widgets"
```

---

## Done when

- The top level renders five groups named You, How you practice, What you see, Your account, About, in that order, holding twelve rows.
- `ios_switch.dart`, `settings_row.dart`, `settings_section.dart` and `theme_segmented_control.dart` no longer exist.
- A month-precision exam date shows "October 2026" and no screen in Settings prints a day count.
- Every row taps to a route that exists, and three of them land on an honest stub rather than doing nothing.
- No `Text` on the page contains an em dash.
- `flutter test` passes across the whole suite.
