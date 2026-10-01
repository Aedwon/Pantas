# Roadmap study days: implementation plan

> For agentic workers: one task per dispatch. Read your task, the Global constraints, and spec
> Part 2 Section 4.10 in full before writing anything.

**Goal:** the roadmap assigns work only on the student's study days (spec Part 1 Section 4a,
approved 1 October 2026), with the streak and reminders following the same days.

**Spec:** `docs/superpowers/specs/2026-09-30-adaptive-roadmap-design.md`, Part 1 Sections 4a and
7 (study days), Part 2 Section 4.10 and Section 9 (study days bullet).
**Decision log:** `docs/superpowers/decisions/2026-09-30-adaptive-roadmap-log.md`, 1 October
entries.
**Branch:** `web/roadmap-engine-r1` (worktree `Pantas-wt-web-roadmap-engine-r1`), base 670c9f15.
Tasks B and C run in parallel in their own worktrees branched from Task A's commit and are
merged by the lead.

## Global constraints

- No UI: no onboarding step, no Settings row, no new copy. Those are the UI round.
- Absent setting means all seven days; with all seven, every existing test must stay green
  unchanged. A changed existing expectation is a stop condition unless this plan names it.
- No schema change: the setting lives in `account_prefs`, which already syncs (Named Pro), wipes
  and demo-switches generically. Do not touch `firestore.rules` or functions.
- Day arithmetic uses calendar dates (`DateTime(y, m, d + n)`, `localDaysBetween`), never
  `Duration.inDays`.
- Never assign a lesson, new question, review or mock to a rest day.
- No new dependencies. No em dashes. American spelling. No attribution in commits. `--no-pub`.
- Gates before reporting: task tests, `flutter analyze --no-pub` (only the accepted
  `bookmarks_sheet.dart` onReorder info), `dart run tool/check_layering.dart`,
  `dart format --output=none --set-exit-if-changed` on changed files.

---

## Task A: the setting and the shared day helper

**Files:**
- Create `lib/core/time/study_days.dart`, `test/core/time/study_days_test.dart`.
- Modify `lib/features/settings/domain/user_settings.dart`,
  `lib/features/settings/data/settings_repository.dart`,
  `lib/features/settings/application/settings_providers.dart`, and their existing tests
  (add cases; extend constructors in test fixtures where `UserSettings` is built).
- Any other file that constructs `UserSettings(...)` and fails to compile: add
  `studyDays: StudyDays.all` only.

**Interface (exact; Tasks B and C depend on it):**

```dart
/// The weekdays a student studies on, as ISO weekdays (DateTime.monday 1
/// to DateTime.sunday 7). Never empty.
@immutable
final class StudyDays {
  factory StudyDays(Iterable<int> weekdays); // ArgumentError if empty or outside 1..7
  static const StudyDays all; // all seven
  static StudyDays fromStorage(String? raw); // null, '', or any invalid token -> all
  Set<int> get weekdays; // unmodifiable
  String get storageValue; // sorted, comma separated, e.g. '1,2,3,4,5'
  bool get isEveryDay;
  bool isStudyDay(DateTime day); // day.weekday
  /// Study days in [from, to), by local calendar day. 0 when to <= from.
  int countInRange(DateTime from, DateTime to);
  /// First study day strictly after [day] and strictly before [before]
  /// when given; null if none.
  DateTime? nextAfter(DateTime day, {DateTime? before});
  /// Study days strictly between [earlier] and [later] (both exclusive).
  int missedBetween(DateTime earlier, DateTime later);
  // == and hashCode by weekdays
}
```

- `UserSettings.studyDays` (required, `StudyDays`); `defaults()` uses `StudyDays.all`.
- `SettingsPrefKeys.studyDays = 'settings.study_days'`. `readUserSettings` reads it with
  `StudyDays.fromStorage`. `updateStudyDays(StudyDays days)` writes `storageValue` and
  `updatedAt` like the other updates.
- The settings controller in `settings_providers.dart` gains `updateStudyDays(StudyDays)` that
  writes through the repository, refreshes `userSettingsProvider` the way the other updates do,
  then calls `notificationServiceProvider`'s `rescheduleForForeground()`.

**Tests:** constructor rejects empty and 0 or 8; `fromStorage` of null, '', '1,3', '9', 'x',
'3,1,3' (dedupes, gives 1,3); `storageValue` sorted; `countInRange` Wed 30 Sep to Mon 7 Dec 2026
with Mon to Fri equals 48 (compute it in the test from a loop, assert the helper equals the
loop and also pin 48 after checking it); `nextAfter` Fri 2 Oct 2026 with Mon to Fri gives
Mon 5 Oct, with `before: Mon 5 Oct` gives null; `missedBetween` Fri to Mon with Mon to Fri is 0,
Mon to Wed is 1; a span crossing a month and year end. Repository round trip, absent reads all
seven, update writes the key.

---

## Task B: the engine (after A)

**Files:** in `lib/features/roadmap/`: `domain/roadmap_inputs.dart`, `domain/planning_window.dart`,
`domain/build_roadmap.dart`, `domain/mock_day.dart`, `domain/week_preview.dart`,
`domain/roadmap.dart`, `domain/day_snapshot.dart`, `domain/roadmap_diff.dart`,
`application/roadmap_inputs_reader.dart`, `application/roadmap_providers.dart`; their tests under
`test/features/roadmap/`. Nothing else.

**Behavior (spec 4.10 is authoritative; this restates it as code shape):**

1. `RoadmapInputs.studyDays` (`StudyDays`, default `StudyDays.all`) and
   `RoadmapInputs.treatTodayAsStudyDay` (`bool`, default false). A study day for the build is
   `treatTodayAsStudyDay || studyDays.isStudyDay(today)`.
2. `PlanningWindows.resolve` takes `StudyDays studyDays` and `bool treatTodayAsStudyDay`.
   `quiet`, `reviewOnlyFrom`, the anchor and `daysLeft` are unchanged (calendar). `workingDays`
   becomes the study days in `[today, reviewOnlyFrom)`, counting today as a study day when
   `treatTodayAsStudyDay`. Add `studyDaysBeforeExam` = study days in `[today, examDay)` under the
   same rule. With all seven both equal the old values, so existing tests hold.
3. `BuildRoadmap`: if today is not a study day for the build, return the normal roadmap
   (state, examDay, reviewOnlyFrom, mockDay, weeksAhead, topicOrder) with an empty `today` and
   `today.isRestDay = true`. Otherwise the per-day divisor is `workingDays > 0 ? workingDays :
   studyDaysBeforeExam` (replacing `window.daysLeft`), never zero on a study day before the exam.
4. `DayPlan.isRestDay` (bool), serialized in the snapshot JSON as `'restDay'`, read as false when
   absent (stored days from earlier builds).
5. `MockDay.place` takes `StudyDays`. Same window and target; then the first study day `>=`
   target in the window, else the last study day `<` target in the window, else null; the Free
   cooldown moves it to the first study day `>=` the cooldown end in the window, else null.
6. `WeekPreviews.build` takes `StudyDays`; the simulation allots lessons only on study days and
   divides by study days left. (`WeekPreview` has no per-day rows, so the spec's "rest days
   carry no counts" is met by allotting nothing to them. Recorded as a technical reading.)
7. `RoadmapDigest` includes `studyDays.storageValue` (JSON key `'studyDays'`; absent in a stored
   digest reads as all seven so existing stored days are not rebuilt by the upgrade alone).
   New cause `RoadmapChangeCause.studyDaysChanged`, used when the stored digest for today
   differs only in study days.
8. `missedWork` is never logged for a stored day whose plan `isRestDay`.
9. `RoadmapInputsReader.digest` and `.inputs` read `settings.studyDays`; `.inputs` takes an
   optional `treatTodayAsStudyDay`.
10. `RoadmapController.advance`:
    - target = `studyDays.nextAfter(day, before: examDay)` when an exam day exists, else
      `day + 1`. If a target exists, build inputs for it as today (as the current code does for
      tomorrow). If none, build inputs for `day` with `treatTodayAsStudyDay: true` (one study day
      left: everything remaining).
    - If today's snapshot `isRestDay`, also build inputs for `day` with
      `treatTodayAsStudyDay: true` and pass its `reviewQuestionIds` to
      `DaySnapshots.advance(..., reviews: ...)`, which appends those not already in the snapshot
      as advanced items. Reviews are never added on a study day.
    - Unchanged: nothing happens before `originalDone`; a no-op advance writes nothing.

**Tests (pure where possible):** spec 4.10 worked checks (Mon to Fri, Wed 30 Sep to Mon 7 Dec
2026, 120 lessons and 900 unseen; compute expected values in the test from the helper and also
pin the numbers you verified); Saturday in that plan is empty and `isRestDay`; property test over
random study-day sets and corpora: following the plan on study days only reads every lesson and
sees every question by `reviewOnlyFrom` whenever `countInRange(today, reviewOnlyFrom) >= 1`, and
no item ever lands on a rest day; reviews due Saturday and Sunday appear Monday under the cap;
mock placement when the target is a rest day (moves later), when only earlier window days are
study days (moves earlier), when no window day is a study day (null), and with the Free cooldown;
week preview allots nothing to rest days; advance from Friday (Mon to Fri) builds Monday's plan;
advance on Saturday adds Monday's lessons and new questions plus Saturday's due reviews and
nothing not yet due; advance with no study day left brings everything; mid-day switch of today
to a rest day empties it and logs `studyDaysChanged`, not `missedWork`; switching back builds it;
an old snapshot JSON without `restDay` and a digest without `studyDays` read back unchanged.

---

## Task C: streak and reminders (after A, parallel with B)

**Files:** `lib/features/quiz/domain/streak/streak_evaluator.dart`, the provider that builds it in
`lib/features/quiz/application/quiz_providers.dart` (that one provider only),
`lib/features/notifications/application/notification_service.dart`,
`lib/features/notifications/application/notifications_providers.dart`,
`lib/features/notifications/domain/reminder_schedule.dart`,
`lib/features/notifications/domain/streak_save_policy.dart`,
`lib/features/notifications/domain/lapse_policy.dart`, and their tests. If another place judges
whether the streak is alive from a date gap (search `lastActiveDate`, `inDays`, `current` streak
reads in `lib/features/home`, `lib/features/metrics`), stop and report it with the file and line
rather than editing it.

**Behavior:**

1. `StreakEvaluator` takes a `Future<StudyDays> Function()` reader (the provider reads
   `userSettingsProvider.future` and returns `studyDays`). Gap = `studyDays.missedBetween(
   lastActive, today)`: 0 continues (+1), 1 with a freeze uses it, more resets to 1. Activity on
   any day credits that day as now. Same-day and ineligible-origin paths unchanged.
2. `NotificationSettingsSnapshot` gains `studyDays`; the reader in `notifications_providers.dart`
   reads `settings.study_days` with `StudyDays.fromStorage` alongside the reminder time key.
3. `ReminderSchedulerClock.nextOccurrence` takes `StudyDays`: the next occurrence of the time
   that falls on a study day (today if still ahead and today is a study day, else the next study
   day).
4. `StreakSavePolicy.shouldSchedule` takes `isStudyDay` for today; false on a rest day.
5. `LapsePolicy.shouldSchedule` takes `StudyDays`: fires only when today is a study day and the
   study days missed from the day after the last session through today, inclusive, equal 3.
   With all seven this equals the current `quietDays == 3`.
6. Exam countdown is unchanged.

**Tests:** Mon to Fri: Friday session, Monday session continues the streak with no freeze used;
Friday session, Tuesday session uses one freeze; Saturday session credits and Monday continues;
all seven reproduces every existing evaluator test. Daily reminder from Friday after the time
goes to Monday; from Saturday to Monday; all seven unchanged. Streak save not scheduled on
Saturday. Lapse: last session Thursday, Mon to Fri: fires Tuesday (Fri, Mon, Tue missed), not
on the weekend.

---

## Integration (lead)

Merge B and C onto the branch after A, resolve nothing by guessing (they share no files), run
the full suite at `-j 4` with `set -o pipefail`, analyze, layering, format, attribution check.
Independent review of the combined diff (`SUBAGENTS.md`). Update the decision log and the
Readiness SSOT, push the branch. The UI brief gains the study-day surfaces (onboarding step,
Settings control, rest-day Today, rest days in weeks ahead) in the same docs commit.
