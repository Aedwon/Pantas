# Settings 06: About, and the four pushed pages

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild About so it absorbs analytics consent and Send feedback, put the debug row behind the build flag alone, and bring Pro, Account and Backup into the ledger grammar.

**Architecture:** No new machinery. Every page here already exists in some form; this plan restates them in `SettingsGroup` and `SettingsValueRow`, moves two rows off the top level into About, and strikes the long-press easter egg. Pro is the one page whose content changes, because the SKU ladder changed under it.

**Tech Stack:** Flutter, Riverpod, go_router, `flutter_test`.

## Global Constraints

- **American spelling**, no em dashes, Grade-5-simple English in every string.
- **No screen may mention or imply a lifetime purchase.** The SKU is gone. Any `pro_lifetime` branch, copy line or test in the tree is deleted, not hidden.
- **Nothing is hidden, disabled or badged by entitlement** anywhere in Settings. A Free student sees every row.
- **Crashlytics is independent of the analytics toggle** and stays on. The lede must say so.
- `flutter analyze` clean and `dart format --output=none --set-exit-if-changed lib test` passing before any commit.

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-03-settings-01-the-kit.md` | `SettingsGroup`, `SettingsValueRow`, `SettingsSwitch`, `SettingsBar` | **Blocking** |
| `2026-08-03-settings-03-the-top-level.md` | The About row, and `/settings/pro` | **Blocking** |

## File structure

| File | Responsibility |
|---|---|
| `lib/features/settings/presentation/pages/about_page.dart` (rewrite) | Version, legal, analytics, DPO, feedback, debug. |
| `lib/features/settings/presentation/pages/pro_page.dart` (create) | Three SKUs, manage, restore. Replaces the subscription page. |
| `lib/features/settings/presentation/pages/account_page.dart` (modify) | Ledger grammar, and the lifetime branch deleted. |
| `lib/features/settings/presentation/pages/backup_page.dart` (modify) | Ledger grammar, five states kept. |
| `lib/features/settings/presentation/pages/delete_account_page.dart` (modify) | Lifetime line deleted from the subscription-aware copy. |
| `lib/features/settings/domain/delete_account_copy.dart` (modify) | Same, at the source. |
| `lib/features/settings/presentation/pages/not_built_yet_page.dart` (delete) | Its last caller goes in Plan 05 or here. |

---

## Task 1: About

**Files:**
- Rewrite: `lib/features/settings/presentation/pages/about_page.dart`
- Rewrite: `test/features/settings/presentation/about_page_test.dart` (extract from `settings_detail_pages_test.dart` if it lives there)

**Interfaces:**
- Consumes: `package_info_plus` for version and build, `userSettingsProvider`, `settingsActionsProvider`, and the `DEBUG_SETTINGS` build flag.
- Produces: `AboutPage()`.

**Two rows arrive here from the top level.** "Help improve the app" moves because analytics consent belongs next to the privacy policy, where a student looking for what the app collects will actually be. "Send feedback" moves because it is an outbound email rather than a setting.

**The debug row appears when `--dart-define=DEBUG_SETTINGS=true` and nothing else reveals it.** Spec 8's long-press on the version row is struck: a second gate on a screen already invisible in release, and an undocumented gesture we would forget within a month.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/presentation/about_page_test.dart`:

```dart
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('about carries legal, analytics, the DPO and feedback',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Terms of service'), findsOneWidget);
    expect(find.text('Help improve the app'), findsOneWidget);
    expect(find.text('Contact our DPO'), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
  });

  testWidgets('the analytics lede says crash reports are always sent',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Shares anonymous usage data. Crash reports are always sent.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('analytics is a switch, on by default', (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsSwitch), findsOneWidget);
    expect(
      tester.widget<SettingsSwitch>(find.byType(SettingsSwitch)).value,
      isTrue,
    );
  });

  testWidgets('without the build flag there is no debug row and no debug '
      'heading', (tester) async {
    await tester.pumpAppWithProviders(
      const AboutPage(debugEnabled: false),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.text('Debug'), findsNothing);
  });

  testWidgets('with the build flag the debug row is plainly visible, with no '
      'gesture needed', (tester) async {
    await tester.pumpAppWithProviders(
      const AboutPage(debugEnabled: true),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.text('Debug'), findsOneWidget);
  });

  testWidgets('nothing on the page mentions a lifetime purchase',
      (tester) async {
    await tester.pumpAppWithProviders(const AboutPage(), overrides: []);
    await tester.pumpAndSettle();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.data?.toLowerCase().contains('lifetime') ?? false, isFalse);
    }
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/presentation/about_page_test.dart`
Expected: FAIL. The current page has no analytics switch and no feedback row.

- [ ] **Step 3: Rewrite the page**

`AboutPage({this.debugEnabled = _kDebugSettings})` where

```dart
const bool _kDebugSettings =
    bool.fromEnvironment('DEBUG_SETTINGS');
```

Making the flag an injectable default is what lets the two debug tests run without two builds. **It must default to the environment value**, so a release build cannot show the row no matter what a caller passes.

Body, in `PageScaffold` under `SettingsBar(title: 'About')`:

- The app name in `displaySmall`, then `Version <version> (build <build>)` in `bodySmall` at `inkMuted`, from `package_info_plus`.
- `SettingsGroup(title: 'Legal', isFirst: true)` with Privacy policy and Terms of service, both pushing the existing legal routes.
- `SettingsGroup(title: 'Your data')` with the analytics row, its lede immediately beneath, and Contact our DPO opening `mailto:`.
- `SettingsGroup(title: 'Get in touch')` with Send feedback, opening `mailto:` with the version and device stubbed into the body.
- `if (debugEnabled) SettingsGroup(title: 'Debug')` with one row pushing `/settings/_debug`.

- [ ] **Step 4: Run the tests and commit**

Run: `flutter test test/features/settings/presentation/about_page_test.dart`
Expected: PASS, 6 tests.

```bash
git add lib/features/settings/presentation/pages/about_page.dart test/features/settings/presentation/about_page_test.dart
git commit -m "feat: about absorbs analytics consent, feedback and the debug row"
```

---

## Task 2: Strike the lifetime SKU

**Files:**
- Modify: `lib/features/settings/domain/delete_account_copy.dart`
- Modify: `lib/features/settings/presentation/pages/delete_account_page.dart`
- Modify: `test/features/settings/domain/delete_account_copy_test.dart`
- Modify: `test/features/settings/presentation/delete_account_page_test.dart`

**Interfaces:**
- Produces: the same functions with the lifetime branch removed from `SettingsEntitlementSnapshot` handling.

**This is a deletion, not a hide.** `2026-08-03-paywall-pricing-and-flow-design.md` drops the SKU entirely, and a dead branch that says "you bought Pro Lifetime" is a sentence one refactor away from reaching a student who never could have.

- [ ] **Step 1: Write the failing test**

Add to `test/features/settings/domain/delete_account_copy_test.dart`:

```dart
  test('no delete copy anywhere mentions a lifetime purchase', () {
    for (final tier in SettingsEntitlementTier.values) {
      final copy = deleteAccountCopyFor(tier);
      expect(copy.toLowerCase().contains('lifetime'), isFalse);
      expect(copy.contains('—'), isFalse);
    }
  });
```

Match the real function and enum names in the file; the assertion is what matters.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/domain/delete_account_copy_test.dart`
Expected: FAIL on the lifetime tier.

- [ ] **Step 3: Delete the branch**

Remove the lifetime case from the enum, the copy map and every `switch` that handles it. `flutter analyze` will point at each exhaustive switch that now needs one fewer arm. Delete the matching test cases rather than updating them.

Search the whole tree and delete every remaining hit:

```bash
grep -rin "lifetime" lib test docs/superpowers/plans | grep -v decisions
```

Anything in `docs/superpowers/decisions/` stays: the log is a record and must keep the reversal.

- [ ] **Step 4: Run the gate and commit**

```bash
flutter analyze
flutter test
git add -A
git commit -m "feat: strike the lifetime SKU from the delete account copy"
```

---

## Task 3: Pro, Account and Backup in the ledger grammar

**Files:**
- Create: `lib/features/settings/presentation/pages/pro_page.dart`
- Modify: `lib/features/settings/presentation/pages/account_page.dart`
- Modify: `lib/features/settings/presentation/pages/backup_page.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/settings/presentation/settings_detail_pages_test.dart` (rewrite)

**Interfaces:**
- Produces: `ProPage()`, replacing whatever the `/settings/pro` route currently builds.

**Content is not decided here.** Pro follows `2026-08-03-paywall-pricing-and-flow-design.md`, Account and Backup follow Spec 8 §5.2 to §5.6. This task owns their frame: `SettingsBar`, `PageScaffold` gutters, `SettingsGroup` and `SettingsValueRow`.

- [ ] **Step 1: Write the failing test**

Rewrite `test/features/settings/presentation/settings_detail_pages_test.dart` around three assertions per page:

```dart
  testWidgets('every settings page uses the settings bar, not an AppBar',
      (tester) async {
    for (final page in [
      const ProPage(),
      const AccountPage(),
      const BackupPage(),
      const AboutPage(),
    ]) {
      await tester.pumpAppWithProviders(page, overrides: []);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsBar), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
    }
  });

  testWidgets('the pro page names three plans and no lifetime',
      (tester) async {
    await tester.pumpAppWithProviders(const ProPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.textContaining('Weekly'), findsOneWidget);
    expect(find.textContaining('Monthly'), findsOneWidget);
    expect(find.textContaining('Yearly'), findsOneWidget);
    expect(find.textContaining('Lifetime'), findsNothing);
  });

  testWidgets('the pro page offers manage and restore', (tester) async {
    await tester.pumpAppWithProviders(const ProPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.text('Manage in Google Play'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('the backup page still renders all five states',
      (tester) async {
    // One pump per SyncStatus, asserting the plain-language headline. Keep
    // whatever the existing test already covers; only the frame changed.
  });
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/presentation/settings_detail_pages_test.dart`
Expected: FAIL, `ProPage` does not exist and the pages still build `AppBar`.

- [ ] **Step 3: Build Pro and reframe the other three**

`pro_page.dart`: `SettingsBar(title: 'Pro')`, then a group naming the current plan and its renewal date when the student has one, then the three SKUs at Weekly ₱29, Monthly ₱99 and Yearly ₱999 with the trial named on Yearly only, then rows for `Manage in Google Play` and `Restore purchases`. A Free student sees what Pro adds and a way in, per that spec's Screen 1.

`account_page.dart` and `backup_page.dart`: swap `Scaffold(appBar: AppBar(...))` for `PageScaffold` plus `SettingsBar`, and swap any remaining `SettingsRow` for `SettingsValueRow`. **Do not touch their copy or their state machines.** Backup keeps all five states and its "Show details" expand.

Point `/settings/pro` at `ProPage`.

- [ ] **Step 4: Run the gate and commit**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
git add -A
git commit -m "feat: pro, account and backup in the ledger grammar"
```

---

## Task 4: Delete the stub, and sweep the spelling

**Files:**
- Delete: `lib/features/settings/presentation/pages/not_built_yet_page.dart` if it has no callers left
- Modify: every spec under `docs/superpowers/specs/` carrying a British spelling

- [ ] **Step 1: Check the stub's callers**

```bash
grep -rn "NotBuiltYetPage" lib
```

If the only hit is `/settings/exam/included` from Plan 05, **leave the file and the route**, and say so in the commit. That deferral is recorded in the work checkpoint and closing it needs the quiz picker index. If there are no hits, delete the file and its route.

- [ ] **Step 2: Sweep the specs**

American spelling became a project rule on 3 August and `AGENTS.md` now carries it. The specs written before that date do not.

```bash
grep -rlniE "practise|colour|behaviour|analyse|organis|centre|grey|favour" docs/superpowers/specs
```

Fix every hit. **Do not touch `docs/superpowers/decisions/`**: those files quote what was on screen at the time and record the moment the rule was set, so rewriting them would erase the reason the rule exists.

- [ ] **Step 3: Verify the whole surface**

Run each check from Section 11 of `docs/superpowers/specs/2026-08-03-settings-design.md` by hand on the emulator, and report the results as text. **Do not screenshot the emulator.** Aedwon does the visual verification and files findings in `docs/ui-audit.md`.

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

Text signals to report:
- The five group headings, in order.
- The twelve row titles and their value strings.
- Whether any value wraps to a second line.
- What the exam date row reads at each of the three precisions.

- [ ] **Step 4: Commit**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
git add -A
git commit -m "chore: sweep British spellings out of the specs"
```

---

## Task 5: Land the amendments this work owes other specs

**Files:**
- Modify: `docs/superpowers/specs/2026-07-30-progress-tab-design.md`
- Modify: `docs/superpowers/specs/2026-07-28-quiz-tab-design.md`
- Modify: `docs/superpowers/plans/2026-07-25-onboarding-polish.md`
- Modify: `docs/superpowers/plans/2026-08-02-quiz-tab-01-storage-and-content-fields.md`

Section 10 of the Settings spec commits to five amendments. Four of them are edits to other documents and none of the tasks above makes them. **A spec that amends another spec and never lands the edit is how the drift this whole round existed to stop gets started again.**

- [ ] **Step 1: The Progress table row title**

In `2026-07-30-progress-tab-design.md` Section 6, change the Settings row's name to **"Remember table order"** and add one line saying the longer phrasing does not fit Settings' value column on a 290px screen, citing `2026-08-03-settings-design.md` Section 5.

- [ ] **Step 2: The three ordering labels**

In `2026-07-28-quiz-tab-design.md` Section 5, change the settings table's first column to the UI labels **One topic only / Interleaved tail / All mixed up**, and state that the stored values keep the spec's names, citing `lib/features/settings/domain/session_ordering.dart`.

- [ ] **Step 3: Onboarding polish Task 4**

In `2026-07-25-onboarding-polish.md`, mark Task 4 as **superseded by `2026-08-03-settings-05-the-exam-page.md`**, which builds the page as three rows rather than a roster. Mark Task 3 as **executed by that plan's Task 1**, which lifts `ExamSelectionRow` and widens the emblem column to 96.

- [ ] **Step 4: The ordering key the quiz engine must read**

`2026-08-03-settings-02-storage.md` replaces `quiz_today_interleaved`, a boolean nobody writes, with `settings.session_ordering`, a three-value key Settings now writes.

**Nothing reads it yet.** Settings owns the preference; the session builder owns the behavior, and that lives in the Quiz plans. Add to `2026-08-02-quiz-tab-01-storage-and-content-fields.md`:

```markdown
**Amended 3 August.** `quiz_today_interleaved` is gone. The value is
`settings.session_ordering`, holding `blocked`, `interleavedTail` or
`fullyMixed`, written by Settings and defined in
`lib/features/settings/domain/session_ordering.dart`. The session builder
reads it through `userSettingsProvider.sessionOrdering`. Until that read
exists the setting is inert: **Settings will show a student three choices
that change nothing**, so this is the first Quiz task to schedule after
Settings ships.
```

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers
git commit -m "docs: land the four amendments the settings spec owes other documents"
```

---

## Task 6: The entrance

**Files:**
- Modify: `docs/superpowers/2026-08-02-work-checkpoint.md`

Section 2 of the Settings spec says Settings is reached by the gear in Home's masthead and has no tab. **The masthead is built by `2026-08-02-home-03-masthead-and-band.md`, which is unexecuted**, so until that lands there is no gear and the only way in is the `/settings` route.

This plan does not build the gear: putting one on the current Home would mean designing a masthead the Home spec has already designed differently.

- [ ] **Step 1: Record the dependency**

Append to the checkpoint's open items:

```markdown
- **Settings has no entrance until Home's masthead lands.**
  `2026-08-03-settings-design.md` Section 2 puts the only entry point on the gear in
  Home's masthead, built by `2026-08-02-home-03-masthead-and-band.md`, which is
  unexecuted. Until then `/settings` is reachable only by route. Settings needs no
  further work when the masthead lands; the gear pushes `/settings` and that route
  already exists.
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/2026-08-02-work-checkpoint.md
git commit -m "docs: record that settings has no entrance until the masthead lands"
```

---

## Done when

- About holds legal, the analytics switch with its crash-report lede, the DPO, feedback, and a debug row that appears only under the build flag.
- Nothing anywhere in `lib` or `test` mentions a lifetime purchase.
- No Settings page builds a Material `AppBar`.
- The Pro page names three plans and offers manage and restore.
- The only remaining `NotBuiltYetPage` caller, if any, is "What's included", and the work checkpoint says why.
- `flutter analyze` is clean and `flutter test` passes across the whole suite.
- The emulator pass is reported as text, with the visual verification left to Aedwon.
