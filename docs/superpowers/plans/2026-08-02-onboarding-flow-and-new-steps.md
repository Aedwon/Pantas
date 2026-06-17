# Onboarding: the New Order, the Two New Steps and the Fields Behind Them

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorder onboarding to welcome, age gate, exam picker, exam date, name; add the
two new steps and the fields they write; and give onboarding a real notion of being
finished so a step can exist after the exam picker at all.

**Architecture:** No new subsystems. One new value type carrying a date and its precision,
three new preference keys, one new device preference plus a provider, one line of router
logic, two new step widgets, and copy changes to the two existing ones. The onboarding
page's `_OnboardingStep` enum grows from three cases to five.

**Tech Stack:** Flutter, Riverpod, Drift, go_router, flutter_test. `CupertinoPicker` is
already used by the age gate. No new packages.

**Source specs:** `docs/superpowers/specs/2026-08-02-onboarding-name-and-date-design.md`
is the whole of this plan. `2026-07-26-home-and-navigation-design.md` Section 2 is what it
supersedes.

---

## How this plan interleaves with the onboarding polish plan

`docs/superpowers/plans/2026-07-25-onboarding-polish.md` holds 13 repairs to the same
files and is **unexecuted**. Running them independently means opening
`onboarding_age_gate_step.dart`, `settings_home_page.dart` and the exam date wiring twice.
Run them in this order:

| Phase | What | Why this order |
|---|---|---|
| **A** | This plan, **Tasks 1 to 4** | Storage only, no UI. Conflicts with nothing |
| **B** | The polish plan, **all 13 tasks** | Its Task 6 wires the Settings exam date row and **must use the `ExamDate` API from Task 1**, not `DateTime` |
| **C** | This plan, **Tasks 5 to 10** | Router, reorder, copy and the two new screens |

**Two collisions to know about before starting Phase B:**

1. **Polish Task 6** wires the Settings exam date row against
   `DriftSettingsRepository.updateExamDate(DateTime)`. After Task 1 that method takes an
   `ExamDate`. Adjust that task's code accordingly; the row must offer the same three
   answers this plan's Task 9 offers, per the spec's Section 7.
2. **Polish Task 12** rewrites the Welcome headline. **Task 7 of this plan supersedes it
   entirely.** Skip polish Task 12 and do Task 7 instead.

## Global Constraints

- **No new dependencies.**
- **Generated files are never edited by hand, and never committed.** `.gitignore` excludes
  `**/*.g.dart` and `**/*.freezed.dart`. Run
  `dart run build_runner build --delete-conflicting-outputs` after model changes and do
  not `git add` its output.
- **Work only inside your worktree.** Never write to the main checkout.
- **Ink & Rule identity.** Serif headlines via `context.textStyles`; `BoardButton` for
  actions with **at most one primary (non-`secondary`) BoardButton per screen**; hairline
  rules via `AppDimensions.hairline`; page padding `EdgeInsets.fromLTRB(20, 24, 20, 24)`.
  No card elevation, no drop shadows, no large corner radii, no tinted callout boxes, no
  coloured left-border panels.
- **Voice.** Grade-5-simple English. Short sentences. **No em dashes**, use a comma or a
  colon. Contractions are fine. Every user-facing string in this plan is quoted verbatim
  from the spec: **do not improvise copy.** If a string is missing, stop and say so.
- **Layering (`tool/check_layering.dart`).** R1: `lib/core/**` must not import
  `lib/features/**`. R2: one feature must not import another. R3: `domain/` must not
  import Flutter or platform packages.
- **Navigation rule (UI-001).** Destinations outside the tab shell use `push`. `go` is
  reserved for tab switches and deliberate flow resets such as `/onboarding`.
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/features/settings/domain/exam_date.dart` — the date-with-precision value type.
  Feature-local in `settings/domain/` beside `user_settings.dart`, which already owns
  `SettingsTime` for the same reason.
- `lib/features/onboarding/presentation/onboarding_exam_date_step.dart`
- `lib/features/onboarding/presentation/onboarding_name_step.dart`
- `test/features/settings/domain/exam_date_test.dart`
- `test/features/onboarding/presentation/onboarding_exam_date_step_test.dart`
- `test/features/onboarding/presentation/onboarding_name_step_test.dart`
- `test/app/router_onboarding_completion_test.dart`

**Modify:**
- `lib/features/settings/domain/user_settings.dart` — `examDate` becomes `ExamDate?`, plus
  a new `name` field.
- `lib/features/settings/data/settings_repository.dart` — three new keys, `updateExamDate`
  retyped, `updateName`, `recordPolicyAcceptance`.
- `lib/core/storage/data/repos/app_preferences_repository.dart` — the completion flag.
- `lib/core/storage/age_gate.dart` — a provider for the completion flag, beside
  `passedAgeGateProvider`.
- `lib/app/router.dart` — the redirect waits on the flag.
- `lib/features/onboarding/presentation/onboarding_page.dart` — five steps, new order.
- `lib/features/onboarding/presentation/onboarding_welcome_step.dart` — copy.
- `lib/features/onboarding/presentation/onboarding_age_gate_step.dart` — copy, and the
  blocked state becomes a fork.

---

## Task 1: `ExamDate`, a date that carries its own precision

**Files:**
- Create: `lib/features/settings/domain/exam_date.dart`
- Modify: `lib/features/settings/domain/user_settings.dart`
- Modify: `lib/features/settings/data/settings_repository.dart`
- Test: `test/features/settings/domain/exam_date_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum ExamDatePrecision { day, month }`; `ExamDate` with factories
  `ExamDate.onDay(DateTime)` and `ExamDate.inMonth({required int year, required int month})`,
  getters `year`, `month`, `precision`, `day` (`DateTime?`), method
  `int? daysUntil(DateTime today)`, `String get storageValue`, and
  `static ExamDate? fromStorage(String? date, String? precision)`.
  `UserSettings.examDate` becomes `ExamDate?`. `DriftSettingsRepository.updateExamDate`
  takes an `ExamDate`. Task 9, polish Task 6 and Home all consume these.

**Why a type and not a flag.** The spec's Section 4: a boolean beside the date works
exactly until the first reader forgets to check it, and the failure is silent and prints a
wrong number to a student. `day` returns `null` at month precision, so a caller physically
cannot read a day off a month-precision value.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/domain/exam_date_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a day-precision date exposes its day', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.precision, ExamDatePrecision.day);
    expect(date.day, DateTime(2026, 10, 12));
    expect(date.year, 2026);
    expect(date.month, 10);
  });

  test('a month-precision date refuses to hand over a day', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.precision, ExamDatePrecision.month);
    expect(date.day, isNull);
    expect(date.year, 2026);
    expect(date.month, 10);
  });

  test('a day-precision date counts whole days', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.daysUntil(DateTime(2026, 9, 30)), 12);
    expect(date.daysUntil(DateTime(2026, 10, 12)), 0);
  });

  test('a month-precision date never counts days', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.daysUntil(DateTime(2026, 9, 30)), isNull);
  });

  test('the time of day never affects the count', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12, 23, 59));

    expect(date.daysUntil(DateTime(2026, 10, 11, 0, 1)), 1);
  });

  test('a day-precision date round-trips through storage', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.storageValue, '2026-10-12');
    expect(
      ExamDate.fromStorage(date.storageValue, date.precision.name),
      date,
    );
  });

  test('a month-precision date stores the first of the month', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.storageValue, '2026-10-01');

    final parsed = ExamDate.fromStorage(date.storageValue, 'month');
    expect(parsed, date);
    expect(parsed!.day, isNull);
  });

  test('a missing or unreadable value is no date at all', () {
    expect(ExamDate.fromStorage(null, 'day'), isNull);
    expect(ExamDate.fromStorage('2026-10-12', null), isNull);
    expect(ExamDate.fromStorage('nonsense', 'day'), isNull);
    expect(ExamDate.fromStorage('2026-10-12', 'sideways'), isNull);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/settings/domain/exam_date_test.dart`
Expected: FAIL. `exam_date.dart` does not exist.

- [ ] **Step 3: Write the type**

Create `lib/features/settings/domain/exam_date.dart`:

```dart
import 'package:meta/meta.dart';

/// How much of the exam date the student actually knew.
enum ExamDatePrecision { day, month }

/// A date the student asserted, carrying how precisely they asserted it.
///
/// [day] is null at month precision on purpose. A day count derived from a
/// month would be a figure this app assumed, and a flag beside the date only
/// works until the first reader forgets to check it.
@immutable
class ExamDate {
  const ExamDate._(this._date, this.precision);

  factory ExamDate.onDay(DateTime date) {
    return ExamDate._(
      DateTime(date.year, date.month, date.day),
      ExamDatePrecision.day,
    );
  }

  factory ExamDate.inMonth({required int year, required int month}) {
    return ExamDate._(DateTime(year, month), ExamDatePrecision.month);
  }

  final DateTime _date;
  final ExamDatePrecision precision;

  int get year => _date.year;
  int get month => _date.month;

  /// The exact day, or null when only the month is known.
  DateTime? get day =>
      precision == ExamDatePrecision.day ? _date : null;

  /// Whole days from [today] to the exam, or null when only the month is
  /// known. Never negative-safe: a past date returns a negative number and
  /// the caller decides what that means.
  int? daysUntil(DateTime today) {
    if (precision != ExamDatePrecision.day) return null;
    final from = DateTime(today.year, today.month, today.day);
    return _date.difference(from).inDays;
  }

  /// Always `YYYY-MM-DD`. At month precision the day is the 1st, which is why
  /// the precision must be stored alongside it.
  String get storageValue {
    return '${_date.year.toString().padLeft(4, '0')}-'
        '${_date.month.toString().padLeft(2, '0')}-'
        '${_date.day.toString().padLeft(2, '0')}';
  }

  static ExamDate? fromStorage(String? date, String? precision) {
    if (date == null || precision == null) return null;

    final parts = date.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;

    return switch (precision) {
      'day' => ExamDate.onDay(DateTime(year, month, day)),
      'month' => ExamDate.inMonth(year: year, month: month),
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ExamDate &&
        other._date == _date &&
        other.precision == precision;
  }

  @override
  int get hashCode => Object.hash(_date, precision);

  @override
  String toString() => '$storageValue (${precision.name})';
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/settings/domain/exam_date_test.dart`
Expected: PASS, 8 tests.

- [ ] **Step 5: Retype `UserSettings.examDate`**

In `lib/features/settings/domain/user_settings.dart`, add the import and change the field
type:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
```

```dart
  final ExamDate? examDate;
```

`UserSettings.defaults()` needs no change: `examDate: null` is still correct.

- [ ] **Step 6: Retype the repository**

In `lib/features/settings/data/settings_repository.dart`, add the `exam_date.dart` import
and a second key beside `examDate`:

```dart
  static const examDatePrecision = 'settings.exam_date_precision';
```

Replace the read in `readUserSettings`:

```dart
      examDate: ExamDate.fromStorage(
        values[SettingsPrefKeys.examDate],
        values[SettingsPrefKeys.examDatePrecision],
      ),
```

Replace `updateExamDate` entirely:

```dart
  Future<void> updateExamDate(ExamDate date, {required DateTime today}) async {
    // At month precision the comparison is against the month, not the 1st, so
    // the current month stays selectable while it still has days left in it.
    final earliest = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1));
    final toCompare = date.day ?? DateTime(date.year, date.month + 1, 0);
    if (toCompare.isBefore(earliest)) {
      throw InvalidExamDateException(date);
    }
    await _writeAccountPrefs({
      SettingsPrefKeys.examDate: date.storageValue,
      SettingsPrefKeys.examDatePrecision: date.precision.name,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }
```

`DateTime(year, month + 1, 0)` is the last day of `month`, which is what makes a
month-precision date valid for the whole of the current month.

Delete the now-unused `_formatDate` and `_parseDate` helpers if nothing else calls them.

- [ ] **Step 7: Retype the exception**

In `user_settings.dart`:

```dart
class InvalidExamDateException implements Exception {
  const InvalidExamDateException(this.date);

  final ExamDate date;
}
```

- [ ] **Step 8: Fix every call site**

Run: `grep -rn "examDate\|updateExamDate\|InvalidExamDateException" --include="*.dart" lib test`

`settings_home_page.dart:74` formats the date for its subtitle and must now branch on
precision. Use exactly these two forms, from the spec's Section 4:

- day precision: the existing date format
- month precision: the month and year, for example `October 2026`

If any call site cannot be converted mechanically, **stop and say so** rather than
inventing a rule.

- [ ] **Step 9: Verify, format, analyze and commit**

```bash
flutter test test/features/settings/
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/settings test/features/settings
git commit -m "feat(settings): an exam date carries how precisely it was given

A student who knows only the month must be able to say so, and a day
count derived from a month is a figure we assumed. The type refuses to
hand over a day it never had, which a boolean beside the date would not."
```

---

## Task 2: The student's name

**Files:**
- Modify: `lib/features/settings/domain/user_settings.dart`
- Modify: `lib/features/settings/data/settings_repository.dart`
- Test: `test/features/settings/data/settings_repository_test.dart` (modify, or create)

**Interfaces:**
- Consumes: nothing.
- Produces: `SettingsPrefKeys.name`, `UserSettings.name` of type `String?`, and
  `DriftSettingsRepository.updateName(String?)`. Task 10, Home's masthead and Progress's
  "Your profile" heading all read it.

**Empty and absent are the same state.** A student who types spaces and taps Done has no
name.

- [ ] **Step 1: Write the failing test**

Add to the settings repository test file:

```dart
  test('a name round-trips', () async {
    await repo.updateName('Aedwon');

    expect((await repo.readUserSettings()).name, 'Aedwon');
  });

  test('a blank name is stored as no name', () async {
    await repo.updateName('   ');

    expect((await repo.readUserSettings()).name, isNull);
  });

  test('clearing the name removes it', () async {
    await repo.updateName('Aedwon');
    await repo.updateName(null);

    expect((await repo.readUserSettings()).name, isNull);
  });

  test('no name is stored by default', () async {
    expect((await repo.readUserSettings()).name, isNull);
  });
```

Match the file's existing `setUp` idiom. If the file does not exist, create it using
`inMemoryDatabase()` from `test/helpers/in_memory_database.dart` and
`DriftSettingsRepository(db)`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/settings/data/settings_repository_test.dart`
Expected: FAIL. `updateName` is not defined.

- [ ] **Step 3: Add the key, the field and the writer**

In `settings_repository.dart`, add to `SettingsPrefKeys`:

```dart
  static const name = 'settings.name';
```

Add to the `UserSettings` construction in `readUserSettings`:

```dart
      name: _readName(values[SettingsPrefKeys.name]),
```

Add the writer and the helper:

```dart
  Future<void> updateName(String? name) async {
    final trimmed = name?.trim() ?? '';
    await _writeAccountPrefs({
      SettingsPrefKeys.name: trimmed,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  static String? _readName(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
```

In `user_settings.dart`, add `required this.name,` to the constructor, `name: null,` to
`defaults()`, and:

```dart
  final String? name;
```

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/settings/`
Expected: PASS. Every existing `UserSettings(...)` construction in tests needs `name:`
added.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/features/settings test/features/settings
git commit -m "feat(settings): store what the student wants to be called

Home's masthead and the Progress tab's profile heading both need it, and
nothing in the app has ever asked."
```

---

## Task 3: Recording acceptance of the Terms and Privacy Policy

**Files:**
- Modify: `lib/features/settings/data/settings_repository.dart`
- Test: `test/features/settings/data/settings_repository_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `SettingsPrefKeys.policyAcceptedAt`, `SettingsPrefKeys.policyVersion`,
  the constant `DriftSettingsRepository.currentPolicyVersion`, and
  `Future<void> recordPolicyAcceptance()`. Task 8 calls it when the age gate is cleared.

**The version is the point.** A timestamp alone cannot answer "who accepted the old
document", which is the question the first policy change asks.

- [ ] **Step 1: Write the failing test**

```dart
  test('acceptance records the time and the policy version', () async {
    await repo.recordPolicyAcceptance();

    final rows = await db.select(db.accountPrefs).get();
    final values = {for (final row in rows) row.key: row.value};

    expect(values['settings.policy_version'],
        DriftSettingsRepository.currentPolicyVersion);
    expect(
      DateTime.tryParse(values['settings.policy_accepted_at'] ?? ''),
      isNotNull,
    );
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/settings/data/settings_repository_test.dart`
Expected: FAIL. `recordPolicyAcceptance` is not defined.

- [ ] **Step 3: Implement it**

Add to `SettingsPrefKeys`:

```dart
  static const policyAcceptedAt = 'settings.policy_accepted_at';
  static const policyVersion = 'settings.policy_version';
```

Add to `DriftSettingsRepository`:

```dart
  /// Bumped whenever the Terms or the Privacy Policy change materially. It is
  /// what lets a later release re-prompt only the students who accepted an
  /// older document.
  static const currentPolicyVersion = '1';

  Future<void> recordPolicyAcceptance() async {
    await _writeAccountPrefs({
      SettingsPrefKeys.policyAcceptedAt: _clock().toUtc().toIso8601String(),
      SettingsPrefKeys.policyVersion: currentPolicyVersion,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }
```

- [ ] **Step 4: Run, format, analyze and commit**

```bash
flutter test test/features/settings/
dart format lib test
flutter analyze
git add lib/features/settings test/features/settings
git commit -m "feat(settings): record which policy version was accepted

A timestamp cannot answer who accepted the old document, which is the
only question a policy change actually asks."
```

---

## Task 4: Onboarding gains a completion flag

**Files:**
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Modify: `lib/core/storage/age_gate.dart`
- Test: `test/core/storage/data/repos/app_preferences_repository_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `AppPreferencesRepository.hasCompletedOnboarding()` and
  `setCompletedOnboarding({required bool value})`, plus
  `onboardingCompleteProvider` of type `FutureProvider<bool>`. Tasks 5 and 10 use them.

**Device-scoped**, in `device_prefs`, matching `passed_age_gate` and `selected_exam_id`
which are both device preferences today.

- [ ] **Step 1: Write the failing test**

```dart
  test('onboarding is not complete until it is marked complete', () async {
    expect(await repo.hasCompletedOnboarding(), isFalse);

    await repo.setCompletedOnboarding(value: true);

    expect(await repo.hasCompletedOnboarding(), isTrue);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/storage/data/repos/app_preferences_repository_test.dart`
Expected: FAIL. `hasCompletedOnboarding` is not defined.

- [ ] **Step 3: Implement it**

In `app_preferences_repository.dart`, add the key beside the other two and the pair of
methods. There is **no legacy fallback** for this key, unlike the two above it, because it
never existed in `app_preferences_local`:

```dart
  static const _onboardingCompleteKey = 'onboarding_complete';
```

```dart
  Future<bool> hasCompletedOnboarding() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_onboardingCompleteKey)))
        .getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> setCompletedOnboarding({required bool value}) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: _onboardingCompleteKey,
            value: value ? 'true' : 'false',
          ),
        );
  }
```

In `lib/core/storage/age_gate.dart`, add beside `passedAgeGateProvider`:

```dart
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasCompletedOnboarding();
});
```

- [ ] **Step 4: Run, format, analyze and commit**

```bash
flutter test test/core/storage/
dart format lib test
flutter analyze
git add lib/core/storage test/core/storage
git commit -m "feat(storage): onboarding can say when it is finished

It has only ever known whether an exam was chosen, which is why no step
could exist after the picker."
```

**Phase A ends here. Run the polish plan before continuing, per the table at the top.**

---

## Task 5: The router waits on the flag

**Files:**
- Modify: `lib/app/router.dart`
- Test: `test/app/router_onboarding_completion_test.dart`

**Interfaces:**
- Consumes: `onboardingCompleteProvider` from Task 4.
- Produces: nothing new. The redirect's behaviour changes.

**Why:** `router.dart:63` currently reads `if (passed && !needsSelection && atOnboarding)`
and leaves for `/home` the moment an exam is saved. Under the new order the exam picker is
step 3, so the date and name steps would never render.

- [ ] **Step 1: Write the failing test**

Create `test/app/router_onboarding_completion_test.dart`. Follow the idiom of the existing
router tests in `test/app/`: build a `ProviderContainer` with the preference providers
overridden, read `routerProvider`, and assert the redirect target.

```dart
// Two cases, both at location '/onboarding':
//
// 1. passedAgeGate = true, an exam IS selected, onboardingComplete = false
//    -> the redirect must return null, meaning stay on onboarding.
//    This is the case that is broken today: it currently leaves for /home.
//
// 2. passedAgeGate = true, an exam IS selected, onboardingComplete = true
//    -> the redirect must leave onboarding, exactly as it does today.
```

Write both as real tests against whatever harness `test/app/` already uses. If there is no
router test harness, assert on the redirect logic by driving a `GoRouter` built from
`routerProvider` and reading `routerDelegate.currentConfiguration.uri`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/router_onboarding_completion_test.dart`
Expected: FAIL on case 1, which redirects to `/home` or `/notifications/rationale`.

- [ ] **Step 3: Change the redirect**

Add `onboardingCompleteProvider` to the `RouterRefreshListenable` list, so the router
rebuilds when the flag is written:

```dart
  final refreshListenable = RouterRefreshListenable(ref, [
    passedAgeGateProvider,
    onboardingCompleteProvider,
    activeExamFocusProvider,
    entitlementProvider,
    notificationRationaleShownProvider,
  ]);
```

Inside `redirect`, read it beside the other two and bail while it is loading:

```dart
      final completeAsync = ref.read(onboardingCompleteProvider);
      final complete = completeAsync.valueOrNull;
      if (passed == null || focus == null || complete == null) return null;
```

Then replace the two conditions that use `needsSelection` to decide onboarding:

```dart
      if (!passed && !atOnboarding) return '/onboarding';
      if (passed && !complete && !atOnboarding) return '/onboarding';
      if (passed && complete && atOnboarding) {
        final rationaleShown =
            ref.read(notificationRationaleShownProvider).valueOrNull;
        if (rationaleShown == false) return '/notifications/rationale';
        return '/home';
      }
      if (passed && complete && atNotificationRationale) {
        final rationaleShown =
            ref.read(notificationRationaleShownProvider).valueOrNull;
        if (rationaleShown ?? false) return '/home';
      }
```

**`needsSelection` no longer gates onboarding.** Leave `focus` in place if other branches
below use it; if nothing does, remove the read and the `focus == null` guard with it.

**Existing installs.** A student who finished the old three-step flow has an exam selected
and no completion flag, so they would be sent back through onboarding. Prevent that in the
same change: treat an existing selected exam as completion at read time, in
`hasCompletedOnboarding`:

```dart
  Future<bool> hasCompletedOnboarding() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_onboardingCompleteKey)))
        .getSingleOrNull();
    if (row != null) return row.value == 'true';

    // Installs from before the flag existed finished onboarding the moment
    // they chose an exam. Treat that as complete rather than sending them
    // back through a flow they already did.
    return await selectedExamId() != null;
  }
```

Add a test for that case alongside Task 4's.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/app/ test/core/storage/`
Expected: PASS.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart format lib test
flutter analyze
git add lib/app lib/core/storage test
git commit -m "fix(router): onboarding ends when it says so, not when an exam is picked

Picking an exam is step three of five now. Inferring completion from it
threw the student out before the last two steps could render. Installs
that predate the flag are treated as complete so nobody repeats a flow
they already finished."
```

---

## Task 6: Five steps, new order

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_page.dart`
- Test: `test/features/onboarding/presentation/onboarding_page_test.dart` (modify or
  create)

**Interfaces:**
- Consumes: the two new step widgets from Tasks 9 and 10. **Write those first if you are
  executing out of order**; this task assumes their constructors exist.
- Produces: the order welcome, ageGate, picker, examDate, name.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the flow runs welcome, age gate, picker, date, name',
      (tester) async {
    // Pump OnboardingPage with the preference providers overridden so the
    // initial step is welcome. Advance through each step by tapping its
    // primary action, and assert the next step's headline appears:
    //   'Welcome to Pantas' -> 'Quick check' -> 'Choose your exam'
    //   -> 'When is your exam?' -> 'What should we call you?'
  });
```

Write it against the harness the existing onboarding widget tests use.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/onboarding/`
Expected: FAIL. The picker is currently the last step.

- [ ] **Step 3: Rewrite the step machine**

In `onboarding_page.dart`:

```dart
enum _OnboardingStep { welcome, ageGate, picker, examDate, name }
```

`_initialStep` keeps its existing shape but must not treat a selected exam as finished:

```dart
  _OnboardingStep _initialStep() {
    final passed = ref.read(passedAgeGateProvider).valueOrNull ?? false;
    if (!passed) return _OnboardingStep.welcome;
    final focus = ref.read(activeExamFocusProvider).valueOrNull;
    if (focus?.needsSelection ?? true) return _OnboardingStep.picker;
    // The exam is chosen but onboarding is not complete, or the router would
    // not have sent us here. Resume at the first step that follows it.
    return _OnboardingStep.examDate;
  }
```

Add the two new cases to `_buildStep`, following the existing `KeyedSubtree` pattern
exactly:

```dart
      case _OnboardingStep.picker:
        return KeyedSubtree(
          key: const ValueKey('picker'),
          child: OnboardingPickerStep(
            onCompleted: () => setState(() => _step = _OnboardingStep.examDate),
          ),
        );
      case _OnboardingStep.examDate:
        return KeyedSubtree(
          key: const ValueKey('examDate'),
          child: OnboardingExamDateStep(
            onCompleted: () => setState(() => _step = _OnboardingStep.name),
          ),
        );
      case _OnboardingStep.name:
        return KeyedSubtree(
          key: const ValueKey('name'),
          child: OnboardingNameStep(
            onCompleted: () {
              // Router redirect handles navigation once the flag is written.
            },
          ),
        );
```

**The picker's `onCompleted` now advances rather than doing nothing.** That callback is
currently an empty comment; it becomes the step transition.

- [ ] **Step 4: Run, format, analyze and commit**

```bash
flutter test test/features/onboarding/
dart format lib test
flutter analyze
git add lib/features/onboarding test/features/onboarding
git commit -m "feat(onboarding): five steps, with the age gate first

The gate stands in front of the only personal field we collect. Asking a
name first would mean storing it before we knew we were allowed to ask."
```

---

## Task 7: Welcome, recopied

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_welcome_step.dart`
- Test: `test/features/onboarding/presentation/onboarding_welcome_step_test.dart`

**Supersedes polish plan Task 12.** Do not do both.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('welcome states what Pantas is and what happens next',
      (tester) async {
    await tester.pumpWidget(_wrap(OnboardingWelcomeStep(onAdvance: () {})));

    expect(find.text('Welcome to Pantas'), findsOneWidget);
    expect(
      find.text(
        "Your reviewer for Philippine exams. We'll ask a few quick "
        'questions to set you up.',
      ),
      findsOneWidget,
    );
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('welcome carries no em dash', (tester) async {
    await tester.pumpWidget(_wrap(OnboardingWelcomeStep(onAdvance: () {})));

    final texts = tester.widgetList<Text>(find.byType(Text));
    for (final text in texts) {
      expect(text.data ?? '', isNot(contains('—')));
    }
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/onboarding/presentation/onboarding_welcome_step_test.dart`
Expected: FAIL. The shipped copy reads "Build your study plan" and contains an em dash.

- [ ] **Step 3: Replace the copy and add the policy line**

Replace the two `Text` widgets:

```dart
            Text('Welcome to Pantas', style: styles.displaySmall),
            const SizedBox(height: 10),
            Text(
              "Your reviewer for Philippine exams. We'll ask a few quick "
              'questions to set you up.',
              style: styles.bodyLarge.copyWith(color: colors.inkMuted),
            ),
```

Beneath the `BoardButton`, add the acceptance line. It is **passive text, not a
checkbox**: acceptance is recorded after the age gate, per the spec's Section 2.

```dart
            const SizedBox(height: 14),
            Text(
              'By continuing, you agree to our Terms and Privacy Policy.',
              textAlign: TextAlign.center,
              style: styles.bodySmall.copyWith(color: colors.inkMuted),
            ),
```

**Terms and Privacy Policy are not yet tappable.** `docs/PRIVACY.md` is headed "DRAFT v0,
not for publication", so there is no destination. Leave the words as plain text and add
this comment above the widget:

```dart
            // Plain text until the policies are publishable. Wiring these to
            // routes before there is a document to open would ship a dead tap.
```

- [ ] **Step 4: Run, format, analyze and commit**

```bash
flutter test test/features/onboarding/
dart format lib test
flutter analyze
git add lib/features/onboarding test/features/onboarding
git commit -m "feat(onboarding): welcome says what Pantas is, not what comes next

The old copy promised the exam picker, which is no longer the next
screen, and it carried the one character this project bans by name."
```

---

## Task 8: The age gate, recopied, and its block becomes a fork

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_age_gate_step.dart`
- Test: `test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`

**Do this after the polish plan's Tasks 1, 2 and 9**, which fix this same file's wheel
behaviour and presentation. This task only touches copy, the acceptance call and the
blocked state's shape.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the age gate explains why it is asking', (tester) async {
    await tester.pumpWidget(_wrap(
      OnboardingAgeGateStep(currentYear: 2026, onAgeGatePassed: () {}),
    ));

    expect(find.text('Quick check'), findsOneWidget);
    expect(find.text('When were you born?'), findsOneWidget);
    expect(
      find.text(
        'We need your age to follow the rules for apps like this. '
        "We'll only keep the year, not your full birthday.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('clearing the gate records policy acceptance', (tester) async {
    // Override the settings repository with a fake, pump the step, choose a
    // year old enough to pass, tap Continue, and assert
    // recordPolicyAcceptance() was called exactly once.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/onboarding/presentation/onboarding_age_gate_step_test.dart`
Expected: FAIL. The explanation line does not exist.

- [ ] **Step 3: Add the explanation**

After the "When were you born?" `Text`:

```dart
            const SizedBox(height: 8),
            Text(
              'We need your age to follow the rules for apps like this. '
              "We'll only keep the year, not your full birthday.",
              style: styles.bodySmall.copyWith(color: colors.inkMuted),
            ),
```

**This line stays flat on purpose.** It is a legal notice addressed to a child. Do not
make it warmer.

- [ ] **Step 4: Record acceptance when the gate is cleared**

In `_onContinue`, after `setPassedAgeGate` succeeds and before `onAgeGatePassed()`:

```dart
      await ref.read(settingsRepositoryProvider).recordPolicyAcceptance();
```

Use whatever the settings repository provider is actually named; find it with
`grep -rn "DriftSettingsRepository(" --include="*.dart" lib`. If the onboarding feature
cannot reach it without violating R2, **stop and say so** rather than routing around the
layering rule.

- [ ] **Step 5: Make the blocked state a fork**

`_buildBlocked` currently offers one button back to the wheel. Keep that, and give the
branch a named destination so the under-13 route is a stub to fill in later rather than a
wall to tear down:

```dart
  Widget _buildBlocked(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pantas isn't ready for under 13s yet.",
              style: styles.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              "We're working on a version parents can set up. "
              'Check back with us.',
              style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 24),
            BoardButton(
              label: 'Try a different year',
              secondary: true,
              onPressed: () => setState(() => _blocked = false),
            ),
          ],
        ),
      ),
    );
  }
```

**The copy changes deliberately.** "Sorry, this app isn't available for users under 13" is
a door closing. The replacement is the same refusal with a future in it, and it is honest:
the parent-consent route is captured at
`docs/future/2026-08-02-parent-child-pairing-and-consent.md`.

- [ ] **Step 6: Run, format, analyze and commit**

```bash
flutter test test/features/onboarding/
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/onboarding test/features/onboarding
git commit -m "feat(onboarding): the age gate says why it asks, and leaves a door open

A child deserves to know what we do with the answer. And the under-13
branch is a stub to fill in when parent consent lands, rather than a wall
to tear down."
```

---

## Task 9: The exam date step

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_exam_date_step.dart`
- Test: `test/features/onboarding/presentation/onboarding_exam_date_step_test.dart`

**Interfaces:**
- Consumes: `ExamDate` from Task 1.
- Produces: `OnboardingExamDateStep({required VoidCallback onCompleted})`, used by Task 6.

**The screen, verbatim from the spec's Section 4:**

> **When is your exam?**
> We'll count down the days on your home screen.
>
> [ day | month | year wheels ]
>
> [ Continue ]
> I don't know yet

**Three honest answers:**

| Answer | How | Written |
|---|---|---|
| exact date | all three wheels set | `ExamDate.onDay(...)` |
| month, no day | day resting on the dash | `ExamDate.inMonth(...)` |
| nothing | "I don't know yet" | nothing written |

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the step offers a dash above day 1', (tester) async {
    await tester.pumpWidget(_wrap(OnboardingExamDateStep(onCompleted: () {})));

    expect(find.text('When is your exam?'), findsOneWidget);
    expect(
      find.text("We'll count down the days on your home screen."),
      findsOneWidget,
    );
    expect(find.text('I don\'t know yet'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('skipping writes no date', (tester) async {
    // Override the settings repository with a fake. Tap "I don't know yet".
    // Assert updateExamDate was never called and onCompleted fired.
  });

  testWidgets('a day left on the dash stores month precision',
      (tester) async {
    // Leave the day wheel on the dash, set month and year, tap Continue.
    // Assert updateExamDate received an ExamDate whose precision is month
    // and whose day is null.
  });

  testWidgets('all three wheels set stores day precision', (tester) async {
    // Scroll the day wheel off the dash, tap Continue.
    // Assert the ExamDate has precision day and a non-null day.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/onboarding/presentation/onboarding_exam_date_step_test.dart`
Expected: FAIL. The file does not exist.

- [ ] **Step 3: Build the step**

Create the widget as a `ConsumerStatefulWidget`, matching
`onboarding_age_gate_step.dart`'s structure exactly: `SafeArea`, `Padding` of
`EdgeInsets.fromLTRB(20, 24, 20, 24)`, `Column` with
`crossAxisAlignment: CrossAxisAlignment.stretch`.

Requirements, all from the spec:

- **Three `CupertinoPicker`s in a `Row`**, each `Expanded`, `itemExtent: 32`, matching the
  age gate's wheel treatment.
- **The day wheel's first item is an em dash `—`**, rendered in `inkMuted`. Index 0 means
  no day. Days 1 to 31 follow.
- **The year range starts at the current year** and runs five years forward.
- **The past is not selectable.** `updateExamDate` throws `InvalidExamDateException` for
  anything earlier than tomorrow, so the step must catch it and surface the message rather
  than crashing. Show it in an `ErrorBanner` from `lib/core/ui/components/`, not a
  `SnackBar`.
- **One primary `BoardButton` labelled "Continue"**, then the board text action
  "I don't know yet" beneath it, centred, 12.5, using `colors.board`.
- On Continue: build the `ExamDate` from the wheels, call `updateExamDate`, then
  `onCompleted()`.
- On "I don't know yet": call `onCompleted()` and write nothing.

**Do not invent a duration estimate or any other figure on this screen.**

- [ ] **Step 4: Run, format, analyze and commit**

```bash
flutter test test/features/onboarding/
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/onboarding test/features/onboarding
git commit -m "feat(onboarding): ask when the exam is, and accept not knowing

Most students have not been given a day. The dash above day 1 lets them
say so, which is a true answer rather than a refusal, and it is why Home
names the month instead of counting to it."
```

---

## Task 10: The name step

**Files:**
- Create: `lib/features/onboarding/presentation/onboarding_name_step.dart`
- Test: `test/features/onboarding/presentation/onboarding_name_step_test.dart`

**Interfaces:**
- Consumes: `updateName` from Task 2, `setCompletedOnboarding` from Task 4.
- Produces: `OnboardingNameStep({required VoidCallback onCompleted})`, used by Task 6.

**The screen, verbatim from the spec's Section 5:**

> **What should we call you?**
> We'll use this to greet you across the app. A nickname is fine.
>
> [ ruled text field ]
>
> [ Done ]
> Skip

**This is the last step**, so **both** its actions write the completion flag.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the step asks for a name and offers a skip', (tester) async {
    await tester.pumpWidget(_wrap(OnboardingNameStep(onCompleted: () {})));

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(
      find.text("We'll use this to greet you across the app. "
          'A nickname is fine.'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Done is disabled until something is typed', (tester) async {
    // Assert the BoardButton's onPressed is null, type 'Aedwon', pump,
    // assert it is no longer null.
  });

  testWidgets('Done stores the name and completes onboarding',
      (tester) async {
    // Type 'Aedwon', tap Done. Assert updateName('Aedwon') and
    // setCompletedOnboarding(value: true) were both called.
  });

  testWidgets('Skip completes onboarding and stores no name',
      (tester) async {
    // Tap Skip. Assert setCompletedOnboarding(value: true) was called and
    // updateName was not.
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/onboarding/presentation/onboarding_name_step_test.dart`
Expected: FAIL. The file does not exist.

- [ ] **Step 3: Build the step**

A `ConsumerStatefulWidget` with a `TextEditingController`, same scaffold as the other
steps. Requirements:

- **A hairline-ruled field, not a filled Material box.** A `TextField` with
  `InputDecoration` whose `border` and `enabledBorder` are `UnderlineInputBorder` in
  `colors.rule` at `AppDimensions.hairline`, no `filled`, no `fillColor`.
- `textCapitalization: TextCapitalization.words`, `maxLength: 40` with `counterText: ''`
  so the counter does not render.
- **"Done" is the single primary `BoardButton`**, disabled while the trimmed field is
  empty.
- **"Skip"** beneath it, centred, board 12.5, as a text action.
- Done: `updateName(controller.text)`, then `setCompletedOnboarding(value: true)`, then
  `onCompleted()`.
- Skip: `setCompletedOnboarding(value: true)`, then `onCompleted()`. **No name is
  written.**
- After the flag is written, invalidate `appPreferencesRepositoryProvider` the way
  `onboarding_age_gate_step.dart` already does, so the router's refresh listenable fires
  and the redirect leaves onboarding.

- [ ] **Step 4: Run the whole suite**

Run: `flutter test`
Expected: PASS. This is the last task, so the whole suite is the gate.

- [ ] **Step 5: Format, analyze and commit**

```bash
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib/features/onboarding test/features/onboarding
git commit -m "feat(onboarding): ask for a name last, and let it be skipped

It is the only personal field we collect, so it sits behind the age gate,
and skipping it costs the student nothing but an invitation on Home."
```

---

## What this plan deliberately does not do

- **The custom exam track.** `2026-08-02-custom-exam-track-design.md` adds a branch out of
  the exam picker and two more steps. Its own plan.
- **Exam switching.** `2026-08-02-exam-switching-design.md`, which rides on the polish
  plan's Task 4.
- **Making Terms and Privacy Policy tappable.** Blocked on the documents existing.
- **Home's masthead and countdown.** This plan writes the fields; the Home spec's plan
  renders them, including the month-precision state.

## Verification

```bash
flutter analyze                                  # no issues outside tool/
dart format --set-exit-if-changed lib test       # clean
dart run tool/check_layering.dart                # no new violations
flutter test                                     # all pass
```

And by hand, on a device, since Aedwon does the visual verification:

- Onboarding renders five steps in the order welcome, age gate, exam picker, exam date,
  name.
- Tapping Continue on the exam picker advances rather than leaving onboarding.
- "I don't know yet" and "Skip" both end onboarding cleanly.
- An install that already had an exam selected is not sent back through onboarding.
- No em dash appears on any onboarding screen.
