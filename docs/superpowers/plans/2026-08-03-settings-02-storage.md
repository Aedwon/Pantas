# Settings 02: storage, and the exam date type

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
> **Analyzer baseline:** `flutter analyze` reports **27 issues** on a clean tree, every one of
> them under `tools/` or `test/tool/`. `lib/` is clean. Any issue under `lib/` or `test/` is
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

## AMENDED 3 August 2026: `ExamDate` is one type, on onboarding's names

**Conflict C1, ruled by Aedwon.** This plan and
`2026-08-02-onboarding-flow-and-new-steps.md` Task 1 both **created**
`lib/features/settings/domain/exam_date.dart` with incompatible APIs. There is now **one
type**, and **onboarding-flow Task 1 is its canonical definition.** Read that task, not
Task 1 below, for the constructors.

**Task 1 of this plan is struck.** Do not create the file. If onboarding-flow has not run,
build the type from **its** definition and say so in the commit.

**The API, settled:**

```dart
enum ExamDatePrecision { day, month }

class ExamDate {
  ExamDate.onDay(DateTime date);
  ExamDate.inMonth({required int year, required int month});

  ExamDatePrecision get precision;
  DateTime? get day;        // null at month precision. NOT `exactDay`.
  DateTime get monthStart;  // added for this plan's readers
  int get year;
  int get month;
  int? daysUntil(DateTime today);
  String get storageValue;
  static ExamDate? fromStorage(String? date, String? precision);
}
```

**Rename every call site in this plan:** `ExamDate.day(x)` becomes `ExamDate.onDay(x)`,
`ExamDate.month(y, m)` becomes `ExamDate.inMonth(year: y, month: m)`, and `.exactDay`
becomes `.day`. The rest of the plan, including the five preference keys and the five
writers, is unchanged and still yours.

---

**Goal:** Give every row on the new Settings screen something to read and write, and replace `DateTime? examDate` with a type that cannot hand out a day it does not have.

**Architecture:** The existing `DriftSettingsRepository` already reads and writes `accountPrefs` and `devicePrefs` key/value rows, so this plan adds keys and methods rather than tables. The one structural change is `ExamDate`, a small value type carrying its own precision, which replaces the nullable `DateTime` on `UserSettings`.

**Tech Stack:** Flutter, Drift, Riverpod, `flutter_test`.

**Source spec:** `docs/superpowers/specs/2026-08-03-settings-design.md`, Sections 4 and 5.

**Decision log:** `docs/superpowers/decisions/2026-08-03-settings-log.md`.

## Global Constraints

- **American spelling** in every string, comment and identifier.
- **No em dashes** anywhere, including commit messages.
- `flutter analyze` clean and `dart format --output=none --set-exit-if-changed lib test` passing before any commit.
- **Preferences about the student sync. Preferences about the device do not.** Everything this plan adds goes in `accountPrefs` except the theme, which is already in `devicePrefs` and stays there.
- **Never print a day count derived from a month.** This is the reason `ExamDate` exists and it is enforced by the type, not by a comment.

## Dependencies

| Plan | What this needs from it | Blocking? |
|---|---|---|
| `2026-08-03-settings-01-the-kit.md` | Nothing. These two plans are independent and can run in parallel. | No |

## File structure

| File | Responsibility |
|---|---|
| `lib/features/settings/domain/exam_date.dart` (create) | `ExamDate` and `ExamDatePrecision`. The only way to read a day. |
| `lib/features/settings/domain/session_ordering.dart` (create) | The three orderings, their storage values and their UI labels. |
| `lib/features/settings/domain/user_settings.dart` (modify) | Add name, examDate as `ExamDate?`, carryOverProgress, sessionOrdering, retainTableOrder. |
| `lib/features/settings/data/settings_repository.dart` (modify) | Five new keys, five new writers, the `ExamDate` read path. |
| `lib/features/settings/application/settings_providers.dart` (modify) | Five new actions on `SettingsActions`. |

---

## Task 1: The exam date type

**Files:**
- Create: `lib/features/settings/domain/exam_date.dart`
- Test: `test/features/settings/domain/exam_date_test.dart`

**Interfaces:**
- Produces:

```dart
enum ExamDatePrecision { day, month }

class ExamDate {
  const ExamDate.day(DateTime date);
  const ExamDate.month(int year, int month);

  ExamDatePrecision get precision;

  /// The stored form, always YYYY-MM-DD. At month precision the day is 01.
  String get storageValue;

  /// Null at month precision. This is the point of the type: a caller
  /// physically cannot read a day off a month-precision value.
  DateTime? get exactDay;

  /// Always available. The first of the month at month precision.
  DateTime get monthStart;

  static ExamDate? fromStorage(String? date, String? precision);
}
```

**Why a type and not a boolean beside the date.** A flag works exactly until the first reader forgets to check it, and that failure is silent and prints a wrong number to a student. `exactDay` returning null is a failure the compiler and the tests can both see.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/domain/exam_date_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a day-precision date hands out its day', () {
    final date = ExamDate.day(DateTime(2026, 10, 12));

    expect(date.precision, ExamDatePrecision.day);
    expect(date.exactDay, DateTime(2026, 10, 12));
    expect(date.storageValue, '2026-10-12');
  });

  test('a month-precision date refuses to hand out a day', () {
    const date = ExamDate.month(2026, 10);

    expect(date.precision, ExamDatePrecision.month);
    expect(date.exactDay, isNull);
    expect(date.monthStart, DateTime(2026, 10));
    expect(date.storageValue, '2026-10-01');
  });

  test('storage round trips at both precisions', () {
    final day = ExamDate.fromStorage('2026-10-12', 'day');
    expect(day!.exactDay, DateTime(2026, 10, 12));

    final month = ExamDate.fromStorage('2026-10-01', 'month');
    expect(month!.exactDay, isNull);
    expect(month.monthStart, DateTime(2026, 10));
  });

  test('an absent precision means no date at all, even with a date string', () {
    expect(ExamDate.fromStorage('2026-10-12', null), isNull);
    expect(ExamDate.fromStorage(null, 'day'), isNull);
    expect(ExamDate.fromStorage('nonsense', 'day'), isNull);
    expect(ExamDate.fromStorage('2026-10-12', 'nonsense'), isNull);
  });

  test('two dates of the same precision and value are equal', () {
    expect(ExamDate.day(DateTime(2026, 10, 12)),
        ExamDate.day(DateTime(2026, 10, 12)));
    expect(const ExamDate.month(2026, 10),
        isNot(ExamDate.day(DateTime(2026, 10))));
  });
}
```

The last expectation is the important one: a month-precision October and a day-precision 1 October store the same string and must still not be equal.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/domain/exam_date_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the type**

Create `lib/features/settings/domain/exam_date.dart`:

```dart
import 'package:meta/meta.dart';

enum ExamDatePrecision {
  day,
  month;

  String get storageValue => name;

  static ExamDatePrecision? fromStorage(String? value) {
    return switch (value) {
      'day' => ExamDatePrecision.day,
      'month' => ExamDatePrecision.month,
      _ => null,
    };
  }
}

/// An exam date that carries its own precision.
///
/// A student who only knows the month must be able to say so, and Home must
/// never print a day count derived from a month, because that is a figure
/// made of a measurement and an assumption. A boolean beside a DateTime would
/// work exactly until the first reader forgot to check it, and that failure is
/// silent and prints a wrong number to a student. This type refuses instead:
/// [exactDay] is null at month precision.
@immutable
class ExamDate {
  const ExamDate._(this._year, this._month, this._day, this.precision);

  ExamDate.day(DateTime date)
      : this._(date.year, date.month, date.day, ExamDatePrecision.day);

  const ExamDate.month(int year, int month)
      : this._(year, month, 1, ExamDatePrecision.month);

  final int _year;
  final int _month;
  final int _day;

  final ExamDatePrecision precision;

  DateTime? get exactDay => precision == ExamDatePrecision.day
      ? DateTime(_year, _month, _day)
      : null;

  DateTime get monthStart => DateTime(_year, _month);

  String get storageValue =>
      '${_year.toString().padLeft(4, '0')}-'
      '${_month.toString().padLeft(2, '0')}-'
      '${_day.toString().padLeft(2, '0')}';

  static ExamDate? fromStorage(String? date, String? precision) {
    final parsedPrecision = ExamDatePrecision.fromStorage(precision);
    if (date == null || parsedPrecision == null) return null;

    final parts = date.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    return switch (parsedPrecision) {
      ExamDatePrecision.day => ExamDate.day(DateTime(year, month, day)),
      ExamDatePrecision.month => ExamDate.month(year, month),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is ExamDate &&
      other._year == _year &&
      other._month == _month &&
      other._day == _day &&
      other.precision == precision;

  @override
  int get hashCode => Object.hash(_year, _month, _day, precision);

  @override
  String toString() => '$storageValue (${precision.name})';
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/features/settings/domain/exam_date_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/domain/exam_date.dart test/features/settings/domain/exam_date_test.dart
git commit -m "feat: an exam date that refuses to hand out a day it does not have"
```

---

## Task 2: The three orderings

**Files:**
- Create: `lib/features/settings/domain/session_ordering.dart`
- Test: `test/features/settings/domain/session_ordering_test.dart`

**Interfaces:**
- Produces:

```dart
enum SessionOrdering {
  blocked,
  interleavedTail,
  fullyMixed;

  String get storageValue;
  String get label;
  String get reason;
  bool get isRecommended;

  static SessionOrdering fromStorage(String? value);
}
```

**The stored values keep the Quiz spec's vocabulary and only the labels are plain.** That is the whole reason this lives in a type rather than in the widget: `blocked` on disk, "One topic only" on screen.

- [ ] **Step 1: Write the failing test**

Create `test/features/settings/domain/session_ordering_test.dart`:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/session_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the default is the interleaved tail, and it is the recommended one',
      () {
    expect(SessionOrdering.fromStorage(null), SessionOrdering.interleavedTail);
    expect(SessionOrdering.interleavedTail.isRecommended, isTrue);
    expect(SessionOrdering.blocked.isRecommended, isFalse);
    expect(SessionOrdering.fullyMixed.isRecommended, isFalse);
  });

  test('an unrecognized stored value falls back to the default', () {
    expect(
      SessionOrdering.fromStorage('nonsense'),
      SessionOrdering.interleavedTail,
    );
  });

  test('storage keeps the spec vocabulary and labels are plain', () {
    expect(SessionOrdering.blocked.storageValue, 'blocked');
    expect(SessionOrdering.blocked.label, 'One topic only');

    expect(SessionOrdering.interleavedTail.storageValue, 'interleavedTail');
    expect(SessionOrdering.interleavedTail.label, 'Interleaved tail');

    expect(SessionOrdering.fullyMixed.storageValue, 'fullyMixed');
    expect(SessionOrdering.fullyMixed.label, 'All mixed up');
  });

  test('every ordering round trips through storage', () {
    for (final ordering in SessionOrdering.values) {
      expect(SessionOrdering.fromStorage(ordering.storageValue), ordering);
    }
  });

  test('no reason uses an em dash', () {
    for (final ordering in SessionOrdering.values) {
      expect(ordering.reason.contains('—'), isFalse);
      expect(ordering.label.contains('—'), isFalse);
    }
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/settings/domain/session_ordering_test.dart`
Expected: FAIL, the URI does not exist.

- [ ] **Step 3: Write the type**

Create `lib/features/settings/domain/session_ordering.dart`:

```dart
/// How today's session is built out of topics.
///
/// The stored values keep the Quiz spec's vocabulary so anyone reading the
/// database recognizes them. The labels are the student's, and only two of
/// the three were plainened: "Interleaved tail" keeps its name because it is
/// the badged default, "interleaved" is the real learning-science word, and
/// the badge is making an authority claim that a plain phrase would not carry.
enum SessionOrdering {
  blocked,
  interleavedTail,
  fullyMixed;

  String get storageValue => name;

  String get label => switch (this) {
        SessionOrdering.blocked => 'One topic only',
        SessionOrdering.interleavedTail => 'Interleaved tail',
        SessionOrdering.fullyMixed => 'All mixed up',
      };

  String get reason => switch (this) {
        SessionOrdering.blocked => 'All 10 questions from your topic.',
        SessionOrdering.interleavedTail =>
          '7 from your topic, 3 from others. Harder now, easier on exam day.',
        SessionOrdering.fullyMixed =>
          'No two in a row from the same topic.',
      };

  bool get isRecommended => this == SessionOrdering.interleavedTail;

  static SessionOrdering fromStorage(String? value) {
    return SessionOrdering.values.firstWhere(
      (ordering) => ordering.storageValue == value,
      orElse: () => SessionOrdering.interleavedTail,
    );
  }
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/features/settings/domain/session_ordering_test.dart`
Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/domain/session_ordering.dart test/features/settings/domain/session_ordering_test.dart
git commit -m "feat: the three session orderings, plain labels over spec storage values"
```

---

## Task 3: Widen UserSettings and the repository

**Files:**
- Modify: `lib/features/settings/domain/user_settings.dart`
- Modify: `lib/features/settings/data/settings_repository.dart`
- Test: `test/features/settings/data/settings_repository_test.dart` (append)

**Interfaces:**
- Consumes: `ExamDate` from Task 1, `SessionOrdering` from Task 2.
- Produces:

```dart
// UserSettings gains five fields and examDate changes type.
class UserSettings {
  const UserSettings({
    required this.name,
    required this.dailyReminderTime,
    required this.examDate,          // now ExamDate?, was DateTime?
    required this.strictMockMode,
    required this.helpImproveApp,
    required this.carryOverProgress,
    required this.sessionOrdering,
    required this.retainTableOrder,
    required this.updatedAt,
  });

  final String? name;
  final ExamDate? examDate;
  final bool carryOverProgress;      // default true
  final SessionOrdering sessionOrdering;
  final bool retainTableOrder;       // default true
}

// SettingsPrefKeys gains five constants.
abstract final class SettingsPrefKeys {
  static const name = 'settings.name';
  static const examDatePrecision = 'settings.exam_date_precision';
  static const carryOverProgress = 'settings.carry_over_progress';
  static const sessionOrdering = 'settings.session_ordering';
  static const retainTableOrder = 'settings.retain_table_order';
}

// DriftSettingsRepository gains five writers.
Future<void> updateName(String? name);
Future<void> updateExamDate(ExamDate date, {required DateTime today});
Future<void> updateCarryOverProgress({required bool enabled});
Future<void> updateSessionOrdering(SessionOrdering ordering);
Future<void> updateRetainTableOrder({required bool enabled});
```

**`updateExamDate` changes signature** from `DateTime` to `ExamDate`. Its existing validation stays but moves to the right grain: at day precision the date must be at least tomorrow; **at month precision the check is against the month**, so the current month stays selectable while it still has days left in it.

**Clearing the name** is `updateName(null)`, which writes an empty string. Empty and absent are the same state, so `readUserSettings` maps an empty string to null.

- [ ] **Step 1: Write the failing tests**

Append to `test/features/settings/data/settings_repository_test.dart`, inside `main()`. Reuse whatever database setup the existing tests in that file already build; the assertions below assume a `repository` and an in-memory `AppDatabase` are in scope exactly as the existing tests have them.

```dart
  test('the new preferences have their specified defaults', () async {
    final settings = await repository.readUserSettings();

    expect(settings.name, isNull);
    expect(settings.examDate, isNull);
    expect(settings.carryOverProgress, isTrue);
    expect(settings.sessionOrdering, SessionOrdering.interleavedTail);
    expect(settings.retainTableOrder, isTrue);
  });

  test('the name round trips, and empty is the same state as absent',
      () async {
    await repository.updateName('Aedwon');
    expect((await repository.readUserSettings()).name, 'Aedwon');

    await repository.updateName(null);
    expect((await repository.readUserSettings()).name, isNull);

    await repository.updateName('   ');
    expect((await repository.readUserSettings()).name, isNull);
  });

  test('a month-precision exam date survives a round trip without gaining '
      'a day', () async {
    await repository.updateExamDate(
      const ExamDate.month(2026, 10),
      today: DateTime(2026, 8, 3),
    );

    final settings = await repository.readUserSettings();
    expect(settings.examDate!.precision, ExamDatePrecision.month);
    expect(settings.examDate!.exactDay, isNull);
    expect(settings.examDate!.monthStart, DateTime(2026, 10));
  });

  test('a day-precision date earlier than tomorrow is refused', () async {
    expect(
      () => repository.updateExamDate(
        ExamDate.day(DateTime(2026, 8, 3)),
        today: DateTime(2026, 8, 3),
      ),
      throwsA(isA<InvalidExamDateException>()),
    );
  });

  test('the current month stays selectable while it still has days left',
      () async {
    await repository.updateExamDate(
      const ExamDate.month(2026, 8),
      today: DateTime(2026, 8, 3),
    );

    expect((await repository.readUserSettings()).examDate,
        const ExamDate.month(2026, 8));
  });

  test('a month already finished is refused', () async {
    expect(
      () => repository.updateExamDate(
        const ExamDate.month(2026, 7),
        today: DateTime(2026, 8, 3),
      ),
      throwsA(isA<InvalidExamDateException>()),
    );
  });

  test('carry over, ordering and table order round trip', () async {
    await repository.updateCarryOverProgress(enabled: false);
    await repository.updateSessionOrdering(SessionOrdering.fullyMixed);
    await repository.updateRetainTableOrder(enabled: false);

    final settings = await repository.readUserSettings();
    expect(settings.carryOverProgress, isFalse);
    expect(settings.sessionOrdering, SessionOrdering.fullyMixed);
    expect(settings.retainTableOrder, isFalse);
  });
```

Add these imports at the top of the test file:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:cse_cet_reviewer/features/settings/domain/session_ordering.dart';
```

- [ ] **Step 2: Run them and confirm they fail**

Run: `flutter test test/features/settings/data/settings_repository_test.dart`
Expected: FAIL. Compile errors on `updateName`, `updateCarryOverProgress`, `updateSessionOrdering`, `updateRetainTableOrder`, and on passing an `ExamDate` to `updateExamDate`.

- [ ] **Step 3: Widen UserSettings**

In `lib/features/settings/domain/user_settings.dart`, replace the `UserSettings` class (lines 40 to 65) with:

```dart
@immutable
class UserSettings {
  const UserSettings({
    required this.name,
    required this.dailyReminderTime,
    required this.examDate,
    required this.strictMockMode,
    required this.helpImproveApp,
    required this.carryOverProgress,
    required this.sessionOrdering,
    required this.retainTableOrder,
    required this.updatedAt,
  });

  factory UserSettings.defaults() {
    return const UserSettings(
      name: null,
      dailyReminderTime: null,
      examDate: null,
      strictMockMode: false,
      helpImproveApp: true,
      carryOverProgress: true,
      sessionOrdering: SessionOrdering.interleavedTail,
      retainTableOrder: true,
      updatedAt: null,
    );
  }

  /// Empty and absent are the same state.
  final String? name;

  final SettingsTime? dailyReminderTime;
  final ExamDate? examDate;
  final bool strictMockMode;
  final bool helpImproveApp;

  /// Governs figures and history. Never governs scheduling.
  final bool carryOverProgress;

  final SessionOrdering sessionOrdering;

  /// Governs persistence of the Progress table's order. Never visibility.
  final bool retainTableOrder;

  final DateTime? updatedAt;
}
```

Add to the top of the same file:

```dart
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:cse_cet_reviewer/features/settings/domain/session_ordering.dart';
```

- [ ] **Step 4: Widen the repository**

In `lib/features/settings/data/settings_repository.dart`, add to `SettingsPrefKeys`:

```dart
  static const name = 'settings.name';
  static const examDatePrecision = 'settings.exam_date_precision';
  static const carryOverProgress = 'settings.carry_over_progress';
  static const sessionOrdering = 'settings.session_ordering';
  static const retainTableOrder = 'settings.retain_table_order';
```

Replace `readUserSettings` with:

```dart
  Future<UserSettings> readUserSettings() async {
    final rows = await _db.select(_db.accountPrefs).get();
    final values = {for (final row in rows) row.key: row.value};
    final name = values[SettingsPrefKeys.name]?.trim();

    return UserSettings(
      name: (name == null || name.isEmpty) ? null : name,
      dailyReminderTime:
          SettingsTime.fromStorage(values[SettingsPrefKeys.dailyReminderTime]),
      examDate: ExamDate.fromStorage(
        values[SettingsPrefKeys.examDate],
        values[SettingsPrefKeys.examDatePrecision],
      ),
      strictMockMode: values[SettingsPrefKeys.strictMockMode] == 'true',
      helpImproveApp: values[SettingsPrefKeys.helpImproveApp] != 'false',
      carryOverProgress:
          values[SettingsPrefKeys.carryOverProgress] != 'false',
      sessionOrdering:
          SessionOrdering.fromStorage(values[SettingsPrefKeys.sessionOrdering]),
      retainTableOrder: values[SettingsPrefKeys.retainTableOrder] != 'false',
      updatedAt: DateTime.tryParse(values[SettingsPrefKeys.updatedAt] ?? ''),
    );
  }
```

Replace `updateExamDate` with:

```dart
  Future<void> updateExamDate(ExamDate date, {required DateTime today}) async {
    _guardNotPast(date, today);
    await _writeAccountPrefs({
      SettingsPrefKeys.examDate: date.storageValue,
      SettingsPrefKeys.examDatePrecision: date.precision.storageValue,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  /// At day precision the date must be at least tomorrow. At month precision
  /// the check is against the month, so the current month stays selectable
  /// while it still has days left in it.
  static void _guardNotPast(ExamDate date, DateTime today) {
    final day = date.exactDay;
    if (day != null) {
      final earliest = _dateOnly(today).add(const Duration(days: 1));
      if (_dateOnly(day).isBefore(earliest)) {
        throw InvalidExamDateException(day);
      }
      return;
    }
    final currentMonth = DateTime(today.year, today.month);
    if (date.monthStart.isBefore(currentMonth)) {
      throw InvalidExamDateException(date.monthStart);
    }
  }
```

Add the four remaining writers next to `updateStrictMockMode`:

```dart
  Future<void> updateName(String? name) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.name: name?.trim() ?? '',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateCarryOverProgress({required bool enabled}) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.carryOverProgress: enabled ? 'true' : 'false',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateSessionOrdering(SessionOrdering ordering) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.sessionOrdering: ordering.storageValue,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateRetainTableOrder({required bool enabled}) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.retainTableOrder: enabled ? 'true' : 'false',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }
```

Add the two new imports and delete the now-unused `_parseDate` helper at the bottom of the file.

- [ ] **Step 5: Run the tests and confirm they pass**

Run: `flutter test test/features/settings/data/settings_repository_test.dart`
Expected: PASS. If any pre-existing test in this file constructs `UserSettings` directly or passes a `DateTime` to `updateExamDate`, update it to the new shape; those are the only call sites that should need touching in the test file.

- [ ] **Step 6: Fix the remaining compile errors across the app**

Run: `flutter analyze`

`settings_home_page.dart` reads `userSettings.examDate` as a `DateTime` and will not compile. **Do not redesign it here.** Change only the one call site to keep it building:

```dart
              SettingsRow(
                title: 'Exam date',
                subtitle: _formatExamDate(userSettings.examDate) ??
                    'Not set - tap to add',
                onTap: () {},
              ),
```

and replace `_formatDate` with:

```dart
  static String? _formatExamDate(ExamDate? date) {
    if (date == null) return null;
    return switch (date.precision) {
      ExamDatePrecision.day => date.storageValue,
      ExamDatePrecision.month => date.storageValue.substring(0, 7),
    };
  }
```

Plan 03 replaces this whole page. This step exists only so the tree compiles between plans.

Expected after the fix: analyze clean.

- [ ] **Step 7: Commit**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test test/features/settings/
git add lib/features/settings test/features/settings
git commit -m "feat: five new settings preferences, and an exam date with precision"
```

---

## Task 4: The actions

**Files:**
- Modify: `lib/features/settings/application/settings_providers.dart`
- Test: `test/features/settings/application/settings_actions_test.dart` (append)

**Interfaces:**
- Consumes: the repository writers from Task 3.
- Produces, on `SettingsActions`:

```dart
Future<void> setName(String? name);
Future<void> setExamDate(ExamDate date, {required DateTime today});
Future<void> setCarryOverProgress({required bool enabled});
Future<void> setSessionOrdering(SessionOrdering ordering);
Future<void> setRetainTableOrder({required bool enabled});
```

`setExamDate` replaces the existing `DateTime` version. **`saveExamDate` also changes to take an `ExamDate`** and keeps its rebalance call and its returned message.

- [ ] **Step 1: Write the failing tests**

Append to `test/features/settings/application/settings_actions_test.dart`, matching the container and override style the existing tests in that file already use:

```dart
  test('setting the name writes it and invalidates the settings provider',
      () async {
    await container.read(settingsActionsProvider).setName('Aedwon');

    final settings = await container.read(userSettingsProvider.future);
    expect(settings.name, 'Aedwon');
  });

  test('setting a month-precision exam date keeps its precision', () async {
    await container.read(settingsActionsProvider).setExamDate(
          const ExamDate.month(2026, 10),
          today: DateTime(2026, 8, 3),
        );

    final settings = await container.read(userSettingsProvider.future);
    expect(settings.examDate!.exactDay, isNull);
  });

  test('carry over, ordering and table order all persist', () async {
    final actions = container.read(settingsActionsProvider);
    await actions.setCarryOverProgress(enabled: false);
    await actions.setSessionOrdering(SessionOrdering.blocked);
    await actions.setRetainTableOrder(enabled: false);

    final settings = await container.read(userSettingsProvider.future);
    expect(settings.carryOverProgress, isFalse);
    expect(settings.sessionOrdering, SessionOrdering.blocked);
    expect(settings.retainTableOrder, isFalse);
  });
```

- [ ] **Step 2: Run them and confirm they fail**

Run: `flutter test test/features/settings/application/settings_actions_test.dart`
Expected: FAIL, the methods are not defined.

- [ ] **Step 3: Add the actions**

In `lib/features/settings/application/settings_providers.dart`, replace `setExamDate` and `saveExamDate` and add the four new methods:

```dart
  Future<void> setName(String? name) async {
    await _ref.read(settingsRepositoryProvider).updateName(name);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setExamDate(ExamDate date, {required DateTime today}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateExamDate(date, today: today);
    _ref.invalidate(userSettingsProvider);
  }

  Future<String> saveExamDate(ExamDate date, {required DateTime today}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateExamDate(date, today: today);
    // The study plan only has something to rebalance against a real day.
    final day = date.exactDay;
    if (day != null) {
      await _ref
          .read(studyPlanRebalanceGatewayProvider)
          .onSettingsExamDateChanged(day, today: today);
    }
    _ref.invalidate(userSettingsProvider);
    return 'Your study plan is being rebalanced.';
  }

  Future<void> setCarryOverProgress({required bool enabled}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateCarryOverProgress(enabled: enabled);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setSessionOrdering(SessionOrdering ordering) async {
    await _ref.read(settingsRepositoryProvider).updateSessionOrdering(ordering);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setRetainTableOrder({required bool enabled}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateRetainTableOrder(enabled: enabled);
    _ref.invalidate(userSettingsProvider);
  }
```

Add the two domain imports at the top.

**The `saveExamDate` change is deliberate and worth a second read.** The rebalance gateway takes a `DateTime`, and there is no honest `DateTime` to give it at month precision. Skipping the call is correct: a study plan built on an assumed day is the same class of error as printing an assumed countdown.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/features/settings/application/`
Expected: PASS.

- [ ] **Step 5: Run the gate and commit**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
git add lib/features/settings test/features/settings
git commit -m "feat: settings actions for name, carry over, ordering and table order"
```

---

## Done when

- `flutter test` passes across the whole suite.
- `ExamDate.exactDay` is null at month precision, and nothing in the app can get a day out of a month-precision value.
- A month that has already finished is refused, and the current month is not.
- The five new preferences read their specified defaults from an empty database: carry over on, ordering interleaved tail, table order retained, name absent, exam date absent.
- `saveExamDate` does not call the rebalance gateway at month precision.
