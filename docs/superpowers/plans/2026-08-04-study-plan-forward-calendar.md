# Study plan: the forward calendar

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**This plan is model-agnostic.** It names no harness-specific skill in its tasks. Read
`AGENTS.md` and `SUBAGENTS.md` before writing a line. Its spec is
`docs/superpowers/specs/2026-08-04-study-plan-forward-calendar-design.md`.

**Goal:** Replace the stubbed coaching surface with a forward calendar that shows today's
workload, the rest of this week day by day, and where the fixed points fall, with new material
paced to finish before a review-only stretch at the end.

**Architecture:** Everything the screen needs is arithmetic over two counts: how many cards are
due on a given day, and how much material the student has never seen. Both are single queries.
The pacing is a pure function with no I/O. The screen reads one view model and renders it. **No
projection, no verdict, no mastery.**

**Tech Stack:** Flutter, Riverpod, Drift, flutter_test. No new packages.

---

## Prerequisite, and this plan stops if it is absent

**Confirm before Task 1. If it is missing, stop and say so.**

The exam date must carry its precision, from
`docs/superpowers/plans/2026-08-02-onboarding-flow-and-new-steps.md` **Task 1**. Check that
`lib/features/settings/domain/exam_date.dart` exists and exposes `onDay`, `inMonth`,
`daysUntil`, `monthStart`, `day`, `month` and `year`.

**Today the stored exam date is a bare `DateTime?` with no precision.** This plan cannot start
before that lands. **Do not fall back to `DateTime`.** The pacing rule depends on precision:
a month with no day is planned against the **first** of that month, and getting that wrong
paces a student to meet new material after their exam.

---

## Global Constraints

Every task's requirements implicitly include this section.

- **Do not touch `schemaVersion`** in `lib/core/storage/data/app_database.dart`. This plan adds
  no tables and no columns.
- **No em dashes** anywhere: copy, comments or commit messages. A colon or a comma.
- **American spelling.** practice, color, behavior, analyze, gray, center, organize.
- **Never put AI attribution in a commit message.** No "Claude", no "Gemini", no
  "Co-Authored-By", no "Generated with".
- **Never print a figure this project did not measure.** Every number on this screen is the
  student's own schedule, their own exam date, or arithmetic over both.
- **The words `mastery`, `on track`, `behind`, `ahead` and `ready` must not appear** in any file
  this plan leaves behind, in code or in copy.
- **Zero board green elements and zero buttons on the page.** This screen is read, not pressed.
- **Amber only** on the review-only marker, the exam date, and the next-mock-unlock date.
- **Readable at 200% text scale.** No clipping, no overlap, and no text that
  carries meaning truncated to an ellipsis. Rules and rhythm may stretch.
- **Every tap target is at least 44 by 44**, using the pattern in
  `settings-01`: a smaller visual box inside a larger tappable one.
- **Color is never the only carrier.** Severity must also read as a word or a
  position.
- **Every control has a semantics label.** Icons especially: they have no text
  to read.

### The pacing rule, copied from the spec

```
quiet stretch     = min(7 days, one quarter of the time until the exam)
working days      = days from today until the quiet stretch begins
lessons per day   = ceil(lessons remaining / working days)
questions per day = ceil(questions remaining / working days)
```

**Amended 4 August 2026: both counts, not one.** An earlier version of this plan paced
questions only, which left the daily lesson count computed by nobody and two shipped plans
waiting on a number that did not exist.

At month precision, plan against the **first** day of that month. The "Do more each day"
switch may raise either count and may never lower it.

**There is no fixed daily number anywhere in this plan.** Not three lessons, not ten questions.
A student ten days out gets a large number because covering the material in ten days requires
one, and that is the feature working rather than failing.

### Gate command

Run after every task. All must pass.

```bash
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
dart run tool/check_layering.dart            # expect 7
dart run tool/check_no_ai_attribution.dart   # expect 0
```

The analyzer invariant is **zero issues under `lib/` and `test/` outside `test/tool/`**. The raw
total drifts with `tools/`.

---

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `lib/features/study_plan/domain/pace_curve.dart` | **Delete** | 1 |
| `lib/features/study_plan/domain/daily_sizer.dart` | **Delete** | 1 |
| `lib/features/study_plan/domain/compute_plan_view.dart` | **Delete and replace** | 1, 4 |
| `lib/features/study_plan/presentation/today_inset.dart` | **Delete** | 1 |
| `lib/features/study_plan/presentation/upcoming_day_chip.dart` | **Delete** | 1 |
| `lib/features/study_plan/presentation/mock_week_card.dart` | **Delete** | 1 |
| `lib/features/study_plan/presentation/collapsed_plan_section.dart` | **Delete** | 1 |
| `lib/features/study_plan/presentation/plan_updated_chip.dart` | **Delete** | 1 |
| `lib/core/storage/data/repos/review_state_repository.dart` | Add two count queries. Modify | 2 |
| `lib/features/study_plan/domain/plan_pacing.dart` | **Create.** Pure pacing arithmetic | 3 |
| `lib/features/study_plan/domain/plan_calendar.dart` | **Create.** The view model | 4 |
| `lib/features/study_plan/application/study_plan_providers.dart` | Rewrite. Modify | 5 |
| `lib/features/study_plan/presentation/plan_page.dart` | Rewrite as the calendar. Modify | 6 |

---

### Task 1: Delete the coaching machinery

**Do this first and on its own.** Everything after it is easier to reason about once the
mastery vocabulary is gone, and leaving it in invites a later task to quietly read it.

**Files:**
- Delete: `lib/features/study_plan/domain/pace_curve.dart`
- Delete: `lib/features/study_plan/domain/daily_sizer.dart`
- Delete: `lib/features/study_plan/domain/compute_plan_view.dart`
- Delete: `lib/features/study_plan/presentation/today_inset.dart`
- Delete: `lib/features/study_plan/presentation/upcoming_day_chip.dart`
- Delete: `lib/features/study_plan/presentation/mock_week_card.dart`
- Delete: `lib/features/study_plan/presentation/collapsed_plan_section.dart`
- Delete: `lib/features/study_plan/presentation/plan_updated_chip.dart`
- Delete: every test under `test/features/study_plan/` that targets the above
- Modify: `lib/features/study_plan/study_plan.dart`, the barrel
- Modify: `lib/features/study_plan/presentation/plan_page.dart`, to a placeholder that compiles

**Interfaces:**
- Consumes: nothing.
- Produces: a `study_plan` feature containing only `plan_prefs.dart`, the two data files, a
  compiling placeholder page, and providers that no longer reference a plan view.

- [ ] **Step 1: Write the failing test**

Create `test/features/study_plan/no_coaching_vocabulary_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the study plan feature contains no coaching vocabulary', () {
    final banned = RegExp(
      r'\b(mastery|paceStatus|PaceStatus|on track|onTrack|tolerance band)\b',
      caseSensitive: false,
    );
    final offenders = <String>[];
    final dir = Directory('lib/features/study_plan');
    for (final file in dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (banned.hasMatch(file.readAsStringSync())) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/study_plan/no_coaching_vocabulary_test.dart
```

Expected: FAIL, listing `pace_curve.dart`, `daily_sizer.dart`, `compute_plan_view.dart` and
`study_plan_providers.dart`.

- [ ] **Step 3: Delete the files**

```bash
git rm lib/features/study_plan/domain/pace_curve.dart \
       lib/features/study_plan/domain/daily_sizer.dart \
       lib/features/study_plan/domain/compute_plan_view.dart \
       lib/features/study_plan/presentation/today_inset.dart \
       lib/features/study_plan/presentation/upcoming_day_chip.dart \
       lib/features/study_plan/presentation/mock_week_card.dart \
       lib/features/study_plan/presentation/collapsed_plan_section.dart \
       lib/features/study_plan/presentation/plan_updated_chip.dart
```

Then delete the tests that target them. Find them first, do not guess:

```bash
grep -rln "PaceCurve\|DailySizer\|ComputePlanView\|TodayInset\|UpcomingDayChip\|MockWeekCard\|CollapsedPlanSection\|PlanUpdatedChip" test/
```

- [ ] **Step 4: Reduce the providers and the page to something that compiles**

In `lib/features/study_plan/application/study_plan_providers.dart`, delete
`StudyPlanSignals`, `StudyPlanState`, `StudyPlanReady`, `studyPlanExamProvider`,
`studyPlanSignalsProvider` and `studyPlanViewProvider` entirely. **Keep**
`studyPlanTodayProvider` and `planPrefsProvider`. Task 5 rebuilds the rest.

Replace the body of `lib/features/study_plan/presentation/plan_page.dart` with a page that
renders nothing but its app bar. Task 6 rebuilds it:

```dart
import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your plan')),
      body: const SizedBox.shrink(),
    );
  }
}
```

Update `lib/features/study_plan/study_plan.dart` to export only what still exists.

- [ ] **Step 5: Run the tests**

```bash
flutter test
```

Expected: the vocabulary test passes. Fix any other file that referenced a deleted symbol.
**If a file outside `lib/features/study_plan/` referenced one, that is a finding to report**,
not a thing to quietly rewire.

- [ ] **Step 6: Run the full gate set**

Run the gate command from Global Constraints.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor(plan): remove the coaching machinery the plan no longer claims"
```

---

### Task 2: The two counts the calendar needs

**Files:**
- Modify: `lib/core/storage/data/repos/review_state_repository.dart`
- Test: `test/core/storage/data/repos/review_state_repository_test.dart`

**Interfaces:**
- Consumes: the existing `ReviewStateLocal` table, which already has a `due` column.
- Produces: two methods on `ReviewStateRepository`:
  `Future<int> dueCountOn(DateTime day)` and `Future<int> unseenQuestionCount(ExamId examId)`,
  plus `Future<int> unreadLessonCount(ExamId examId)` on the lesson progress repository.
  Task 5 calls all three.

**The lesson count was added 4 August 2026** when the pacing was extended to cover lessons.
Without it nothing computes a daily lesson count, and two shipped plans wait on that number.

- [ ] **Step 1: Write the failing test**

```dart
test('dueCountOn counts cards due on that calendar day only', () async {
  final repo = ReviewStateRepository(db);
  await repo.upsert(stateDue(DateTime(2026, 8, 4, 9)));
  await repo.upsert(stateDue(DateTime(2026, 8, 4, 23, 59)));
  await repo.upsert(stateDue(DateTime(2026, 8, 5, 0, 1)));

  expect(await repo.dueCountOn(DateTime(2026, 8, 4)), 2);
  expect(await repo.dueCountOn(DateTime(2026, 8, 5)), 1);
  expect(await repo.dueCountOn(DateTime(2026, 8, 6)), 0);
});

test('anything overdue counts as due today, never as due in the past', () async {
  final repo = ReviewStateRepository(db);
  await repo.upsert(stateDue(DateTime(2026, 7, 30)));
  expect(await repo.dueCountOn(DateTime(2026, 8, 4)), 1);
});

test('unseenQuestionCount counts questions with no review state', () async {
  final repo = ReviewStateRepository(db);
  await seedQuestions(db, examId, count: 10);
  await repo.upsert(stateFor('q-1'));
  await repo.upsert(stateFor('q-2'));

  expect(await repo.unseenQuestionCount(examId), 8);
});

test('unreadLessonCount counts lessons with no read progress', () async {
  final lessons = LessonProgressRepository(db);
  await seedLessons(db, examId, count: 12);
  await lessons.markRead('l-1');
  await lessons.markRead('l-2');
  await lessons.markRead('l-3');

  expect(await lessons.unreadLessonCount(examId), 9);
});
```

Write `stateDue`, `stateFor` and `seedQuestions` as local helpers in the test file, following
the fixtures the existing repository tests already use.

**The overdue case is the one that matters.** A student returning after a break has cards due
last week, and they are work they must do today.

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/core/storage/data/repos/review_state_repository_test.dart
```

Expected: FAIL to compile. Neither method exists.

- [ ] **Step 3: Write the queries**

```dart
  /// Cards due on [day], counting anything overdue as due today. A student
  /// back from a break owes last week's cards now, not in the past.
  Future<int> dueCountOn(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final isToday = !start.isAfter(DateTime.now());

    final count = _db.reviewStateLocal.questionId.count();
    final query = _db.selectOnly(_db.reviewStateLocal)..addColumns([count]);
    if (isToday) {
      query.where(_db.reviewStateLocal.due.isSmallerThanValue(end));
    } else {
      query.where(
        _db.reviewStateLocal.due.isBiggerOrEqualValue(start) &
            _db.reviewStateLocal.due.isSmallerThanValue(end),
      );
    }
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Questions for this exam the student has never answered. This is the
  /// "material remaining" the pacing divides by the days available.
  Future<int> unseenQuestionCount(ExamId examId) async {
    final seen = _db.selectOnly(_db.reviewStateLocal)
      ..addColumns([_db.reviewStateLocal.questionId]);

    final count = _db.questions.id.count();
    final query = _db.selectOnly(_db.questions)
      ..addColumns([count])
      ..where(
        _db.questions.examId.equals(examId.value) &
            _db.questions.id.isNotInQuery(seen),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
```

**If the questions table does not carry `examId` under that name, stop and say so.** Do not
join through a guess.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/core/storage/data/repos/review_state_repository_test.dart
```

Expected: PASS, all three.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(storage): count what is due on a day, and what has never been seen"
```

---

### Task 3: The pacing arithmetic

**Pure Dart. No Flutter import, no database, no providers.** This is the whole of the rule and
it must be testable without any of them.

**Files:**
- Create: `lib/features/study_plan/domain/plan_pacing.dart`
- Test: `test/features/study_plan/domain/plan_pacing_test.dart`

**Interfaces:**
- Consumes: `ExamDate` from the prerequisite.
- Produces:
  `PlanPacing computePacing({required DateTime today, required ExamDate examDate, required int lessonsRemaining, required int questionsRemaining, required double intensityMultiplier})`
  returning `PlanPacing(lessonsPerDay, questionsPerDay, quietStretchStart, examDay, workingDays)`.

**Amended 4 August 2026.** This used to take one `materialRemaining` and return one
`newPerDay`. **It takes both kinds of material and returns both counts**, because a student has
lessons to read and questions to answer and the promise covers both.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:cse_cet_reviewer/features/study_plan/domain/plan_pacing.dart';
import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 8, 4);

  test('a long window gets the full seven day quiet stretch', () {
    final pacing = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 10, 12)),
      lessonsRemaining: 124,
      questionsRemaining: 414,
      intensityMultiplier: 1,
    );
    expect(pacing.quietStretchStart, DateTime(2026, 10, 5));
    expect(pacing.workingDays, 62);
    expect(pacing.questionsPerDay, 7);
  });

  test('a short window gets a proportional quiet stretch, never seven days', () {
    // 10 days out: a quarter is 2 days, which is shorter than 7.
    final pacing = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 8, 14)),
      lessonsRemaining: 24,
      questionsRemaining: 80,
      intensityMultiplier: 1,
    );
    expect(pacing.quietStretchStart, DateTime(2026, 8, 12));
    expect(pacing.workingDays, 8);
    expect(pacing.questionsPerDay, 10);
  });

  test('a very short window still leaves at least one working day', () {
    final pacing = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 8, 6)),
      lessonsRemaining: 15,
      questionsRemaining: 50,
      intensityMultiplier: 1,
    );
    expect(pacing.workingDays, greaterThanOrEqualTo(1));
    expect(pacing.questionsPerDay, greaterThan(0));
  });

  test('month precision plans against the FIRST of that month', () {
    final pacing = computePacing(
      today: today,
      examDate: ExamDate.inMonth(year: 2026, month: 10),
      lessonsRemaining: 124,
      questionsRemaining: 414,
      intensityMultiplier: 1,
    );
    // 1 October, not 31 October. Finishing early costs review days;
    // finishing late costs the exam.
    expect(pacing.examDay, DateTime(2026, 10, 1));
  });

  test('lessons and questions are paced by the same division', () {
    final pacing = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 10, 12)),
      lessonsRemaining: 124,
      questionsRemaining: 414,
      intensityMultiplier: 1,
    );
    // 62 working days. 124 / 62 = 2. 414 / 62 = 6.68, rounded up.
    expect(pacing.lessonsPerDay, 2);
    expect(pacing.questionsPerDay, 7);
  });

  test('ten days out produces a large daily count, and that is correct', () {
    // Aedwon's test: a fixed three a day could never cover the material.
    final pacing = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 8, 14)),
      lessonsRemaining: 124,
      questionsRemaining: 414,
      intensityMultiplier: 1,
    );
    expect(pacing.workingDays, 8);
    expect(pacing.lessonsPerDay, 16);
    expect(pacing.questionsPerDay, 52);
  });

  test('the student preference can raise the pace but never lower it', () {
    final base = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 10, 12)),
      lessonsRemaining: 124,
      questionsRemaining: 414,
      intensityMultiplier: 1,
    );
    final raised = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 10, 12)),
      lessonsRemaining: 124,
      questionsRemaining: 414,
      intensityMultiplier: 1.5,
    );
    final lowered = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 10, 12)),
      lessonsRemaining: 124,
      questionsRemaining: 414,
      intensityMultiplier: 0.5,
    );
    expect(raised.questionsPerDay, 11); // 7 at 1.5x, rounded up
    expect(lowered.questionsPerDay, base.questionsPerDay);
  });

  test('no material left means no new questions a day', () {
    final pacing = computePacing(
      today: today,
      examDate: ExamDate.onDay(DateTime(2026, 10, 12)),
      lessonsRemaining: 0,
      questionsRemaining: 0,
      intensityMultiplier: 1,
    );
    expect(pacing.questionsPerDay, 0);
  });
}
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/study_plan/domain/plan_pacing_test.dart
```

Expected: FAIL to compile. `plan_pacing.dart` does not exist.

- [ ] **Step 3: Write it**

```dart
import 'dart:math' as math;

import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';

class PlanPacing {
  const PlanPacing({
    required this.lessonsPerDay,
    required this.questionsPerDay,
    required this.quietStretchStart,
    required this.examDay,
    required this.workingDays,
  });

  /// Lessons to read each day so the material is finished before the quiet
  /// stretch begins. The reader's counter and Home's list both read this.
  final int lessonsPerDay;

  /// New questions to introduce each day, by the same division.
  final int questionsPerDay;

  /// First day on which nothing new is introduced. Review only from here.
  final DateTime quietStretchStart;

  /// The day the plan counts to. At month precision this is the FIRST of the
  /// stated month.
  final DateTime examDay;

  final int workingDays;
}

PlanPacing computePacing({
  required DateTime today,
  required ExamDate examDate,
  required int lessonsRemaining,
  required int questionsRemaining,
  required double intensityMultiplier,
}) {
  final from = DateTime(today.year, today.month, today.day);

  // Month precision plans against the FIRST of the month, the opposite of
  // the paywall's rule. Finishing early costs a student some review days.
  // Finishing late costs them material they never saw.
  final examDay = examDate.day ?? DateTime(examDate.year, examDate.month);

  final totalDays = math.max(1, examDay.difference(from).inDays);

  // The shorter of seven days and a quarter of the window. A fixed seven
  // would leave an eight day window with one working day.
  final quietDays = math.min(7, totalDays ~/ 4);
  final workingDays = math.max(1, totalDays - quietDays);
  final quietStretchStart = from.add(Duration(days: workingDays));

  // The preference may raise the pace and may never lower it below what
  // finishing on time requires, so anything under 1 is ignored.
  final multiplier = math.max(1.0, intensityMultiplier);

  int perDay(int remaining) {
    if (remaining <= 0) return 0;
    return (remaining / workingDays * multiplier).ceil();
  }

  return PlanPacing(
    lessonsPerDay: perDay(lessonsRemaining),
    questionsPerDay: perDay(questionsRemaining),
    quietStretchStart: quietStretchStart,
    examDay: examDay,
    workingDays: workingDays,
  );
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/study_plan/domain/plan_pacing_test.dart
```

Expected: PASS, all six. **If an expected number differs, do not change the test to match the
code until you have checked the arithmetic by hand.** The spec's worked example is 62 working
days and a quiet stretch starting 5 October for an exam on 12 October.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(plan): pace new material to finish before the review stretch"
```

---

### Task 4: The calendar view model

**Files:**
- Create: `lib/features/study_plan/domain/plan_calendar.dart`
- Test: `test/features/study_plan/domain/plan_calendar_test.dart`

**Interfaces:**
- Consumes: `PlanPacing` from Task 3.
- Produces: `PlanCalendar`, `PlanDay`, `PlanWeek` and `PlanMarker`, plus
  `PlanCalendar buildCalendar({required DateTime today, required PlanPacing pacing, required String examName, required int todayDueCount, required List<int> restOfWeekDueCounts, required DateTime? nextMockUnlock})`.

- [ ] **Step 1: Write the failing test**

```dart
test('the rest of this week runs from tomorrow to Sunday', () {
  // 4 August 2026 is a Tuesday, so the rest of the week is Wed 5 to Sun 9,
  // five days. Verified, not assumed.
  final calendar = buildCalendar(
    today: DateTime(2026, 8, 4),
    pacing: pacingFixture,
    examName: 'UPCAT',
    todayDueCount: 18,
    restOfWeekDueCounts: const [14, 11, 9, 13, 7],
    nextMockUnlock: null,
  );
  expect(calendar.restOfWeek.length, 5);
  expect(calendar.restOfWeek.first.date, DateTime(2026, 8, 5));
  expect(calendar.restOfWeek.last.date, DateTime(2026, 8, 9));
  expect(calendar.restOfWeek.first.newCount, 7);
});

test('no week beyond this one carries a count', () {
  final calendar = buildCalendar(/* as above */);
  for (final week in calendar.comingUp) {
    expect(week.hasCount, isFalse);
  }
});

test('the review-only marker falls on the quiet stretch start', () {
  final calendar = buildCalendar(/* as above */);
  final marker = calendar.comingUp
      .expand((w) => w.markers)
      .firstWhere((m) => m.kind == PlanMarkerKind.reviewOnly);
  expect(marker.date, pacingFixture.quietStretchStart);
});

test('a Pro student with no cap gets no mock marker at all', () {
  final calendar = buildCalendar(/* ... */, nextMockUnlock: null);
  final mocks = calendar.comingUp
      .expand((w) => w.markers)
      .where((m) => m.kind == PlanMarkerKind.mockUnlock);
  expect(mocks, isEmpty);
});

test('a Free student gets exactly one mock unlock marker', () {
  final calendar = buildCalendar(
    /* ... */,
    nextMockUnlock: DateTime(2026, 8, 18),
  );
  final mocks = calendar.comingUp
      .expand((w) => w.markers)
      .where((m) => m.kind == PlanMarkerKind.mockUnlock);
  expect(mocks.length, 1);
  expect(mocks.first.date, DateTime(2026, 8, 18));
});
```

Define `pacingFixture` at the top of the file as a `PlanPacing` with an exam on 12 October 2026
and a quiet stretch starting 5 October.

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/study_plan/domain/plan_calendar_test.dart
```

Expected: FAIL to compile.

- [ ] **Step 3: Write the view model**

```dart
import 'package:cse_cet_reviewer/features/study_plan/domain/plan_pacing.dart';

enum PlanMarkerKind { reviewOnly, exam, mockUnlock }

class PlanMarker {
  const PlanMarker({required this.date, required this.kind, required this.label});

  final DateTime date;
  final PlanMarkerKind kind;
  final String label;
}

class PlanDay {
  const PlanDay({
    required this.date,
    required this.reviewCount,
    required this.newCount,
  });

  final DateTime date;
  final int reviewCount;
  final int newCount;

  int get total => reviewCount + newCount;
}

/// A week in the forward view. It carries no counts by design: every
/// question answered today changes next week's schedule, so a count printed
/// three weeks out would be a guess presented as a fact.
class PlanWeek {
  const PlanWeek({required this.weekStart, required this.markers});

  final DateTime weekStart;
  final List<PlanMarker> markers;

  bool get hasCount => false;
}

class PlanCalendar {
  const PlanCalendar({
    required this.examName,
    required this.today,
    required this.restOfWeek,
    required this.comingUp,
    required this.questionsPerDay,
    required this.lessonsPerDay,
    required this.quietStretchStart,
    required this.examDay,
  });

  final String examName;
  final PlanDay today;
  final List<PlanDay> restOfWeek;
  final List<PlanWeek> comingUp;
  final int questionsPerDay;
  final int lessonsPerDay;
  final DateTime quietStretchStart;
  final DateTime examDay;
}

PlanCalendar buildCalendar({
  required DateTime today,
  required PlanPacing pacing,
  required String examName,
  required int todayDueCount,
  required List<int> restOfWeekDueCounts,
  required DateTime? nextMockUnlock,
}) {
  final from = DateTime(today.year, today.month, today.day);

  // Nothing new is introduced once the quiet stretch has begun.
  int newFor(DateTime day) =>
      day.isBefore(pacing.quietStretchStart) ? pacing.questionsPerDay : 0;

  final rest = <PlanDay>[];
  for (var i = 0; i < restOfWeekDueCounts.length; i++) {
    final date = from.add(Duration(days: i + 1));
    rest.add(
      PlanDay(
        date: date,
        reviewCount: restOfWeekDueCounts[i],
        newCount: newFor(date),
      ),
    );
  }

  final firstFutureWeek = _weekStartAfter(from, rest.length);
  final weeks = <PlanWeek>[];
  for (var start = firstFutureWeek;
      !start.isAfter(pacing.examDay);
      start = start.add(const Duration(days: 7))) {
    final end = start.add(const Duration(days: 7));
    final markers = <PlanMarker>[];

    if (!pacing.quietStretchStart.isBefore(start) &&
        pacing.quietStretchStart.isBefore(end)) {
      markers.add(
        PlanMarker(
          date: pacing.quietStretchStart,
          kind: PlanMarkerKind.reviewOnly,
          label: 'Review only from here',
        ),
      );
    }
    if (!pacing.examDay.isBefore(start) && pacing.examDay.isBefore(end)) {
      markers.add(
        PlanMarker(
          date: pacing.examDay,
          kind: PlanMarkerKind.exam,
          label: examName,
        ),
      );
    }
    // Null for a Pro student: the marker names a cap, and they do not have
    // one. Their coming up view carries fewer marks, which is truthful.
    if (nextMockUnlock != null &&
        !nextMockUnlock.isBefore(start) &&
        nextMockUnlock.isBefore(end)) {
      markers.add(
        PlanMarker(
          date: nextMockUnlock,
          kind: PlanMarkerKind.mockUnlock,
          label: 'Next mock unlocks',
        ),
      );
    }
    weeks.add(PlanWeek(weekStart: start, markers: markers));
  }

  return PlanCalendar(
    examName: examName,
    today: PlanDay(
      date: from,
      reviewCount: todayDueCount,
      newCount: newFor(from),
    ),
    restOfWeek: rest,
    comingUp: weeks,
    questionsPerDay: pacing.questionsPerDay,
    lessonsPerDay: pacing.lessonsPerDay,
    quietStretchStart: pacing.quietStretchStart,
    examDay: pacing.examDay,
  );
}

DateTime _weekStartAfter(DateTime from, int daysConsumed) {
  return from.add(Duration(days: daysConsumed + 1));
}
```

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/study_plan/domain/plan_calendar_test.dart
```

Expected: PASS, all five.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(plan): assemble the forward calendar, counting only this week"
```

---

### Task 5: Wire the providers

**Files:**
- Modify: `lib/features/study_plan/application/study_plan_providers.dart`
- Test: `test/features/study_plan/application/study_plan_providers_test.dart`

**Interfaces:**
- Consumes: Tasks 2, 3 and 4.
- Produces: `planCalendarProvider`, a `FutureProvider<PlanCalendar?>` returning null when no
  exam date is set. **No provider in this file may throw `UnimplementedError`.**

- [ ] **Step 1: Write the failing test**

```dart
test('with no exam date the calendar is null rather than a thrown error', () async {
  final container = ProviderContainer(overrides: [
    examDateProvider.overrideWithValue(null),
  ]);
  addTearDown(container.dispose);
  expect(await container.read(planCalendarProvider.future), isNull);
});

test('the calendar reads the real due counts, not a placeholder', () async {
  final container = ProviderContainer(overrides: [
    examDateProvider.overrideWithValue(ExamDate.onDay(DateTime(2026, 10, 12))),
    reviewStateRepositoryProvider.overrideWithValue(fakeRepo),
    studyPlanTodayProvider.overrideWithValue(DateTime(2026, 8, 4)),
  ]);
  addTearDown(container.dispose);
  final calendar = await container.read(planCalendarProvider.future);
  expect(calendar!.today.reviewCount, fakeRepo.dueToday);
});

test('no provider in this file throws UnimplementedError', () {
  final source = File(
    'lib/features/study_plan/application/study_plan_providers.dart',
  ).readAsStringSync();
  expect(source.contains('UnimplementedError'), isFalse);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/study_plan/application/study_plan_providers_test.dart
```

Expected: FAIL. `planCalendarProvider` does not exist.

- [ ] **Step 3: Write the provider**

It reads the exam date, returns null if absent, then gathers today's due count, the next six
days' due counts, the unread lesson count, the unseen question count, the "Do more each day"
switch as a multiplier,
and the next mock unlock date, and hands them to `computePacing` and `buildCalendar`.

**The next mock unlock date is 14 days after the student's most recent mock attempt, and it is
null for a Pro student.** Read entitlement through whatever provider exposes it. **Do not
modify that provider**: it is owned by the offline posture work and its cached-wins rule must
survive.

**Map the switch to a multiplier**, in one place: off 1.0, on 1.5. **Off is not a lesser mode**,
it is the pace that finishes the material in time, and there is nothing below it to offer.
**The stored three-way intensity value collapses to a boolean**; migrate any existing value by
treating the old `intense` as on and everything else as off.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/study_plan/application/study_plan_providers_test.dart
```

Expected: PASS, all three.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(plan): the calendar reads real counts instead of throwing"
```

---

### Task 6: The screen

**Files:**
- Modify: `lib/features/study_plan/presentation/plan_page.dart`
- Test: `test/features/study_plan/presentation/plan_page_test.dart`

**Interfaces:**
- Consumes: `planCalendarProvider` from Task 5.
- Produces: the finished page. Nothing consumes it but the router.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('today is the only large figure on the page', (tester) async {
  // 18 due plus 7 new. The fixture matches Task 3's worked example:
  // 4 August to 12 October is 69 days, 7 quiet, 62 working, 414 unseen.
  await pumpPlan(tester);
  expect(find.text('25'), findsOneWidget);
});

testWidgets('the rest of the week is listed day by day with counts',
    (tester) async {
  await pumpPlan(tester);
  expect(find.textContaining('14 review, 7 new'), findsOneWidget);
});

testWidgets('no week beyond this one shows a number', (tester) async {
  await pumpPlan(tester);
  expect(find.textContaining('about'), findsNothing);
});

testWidgets('there is no button and no board green anywhere', (tester) async {
  await pumpPlan(tester);
  expect(find.byType(ElevatedButton), findsNothing);
  expect(find.byType(TextButton), findsNothing);
  expect(find.byType(BoardButton), findsNothing);
});

testWidgets('nothing is tappable except the back arrow', (tester) async {
  await pumpPlan(tester);
  final inkWells = find.byType(InkWell);
  expect(inkWells, findsNothing);
});

testWidgets('no verdict language appears', (tester) async {
  await pumpPlan(tester);
  for (final word in ['on track', 'behind', 'ahead', 'ready', 'mastery']) {
    expect(find.textContaining(word, findRichText: true), findsNothing);
  }
});

testWidgets('a Pro student sees no mock marker', (tester) async {
  await pumpPlan(tester, nextMockUnlock: null);
  expect(find.text('Next mock unlocks'), findsNothing);
});
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
flutter test test/features/study_plan/presentation/plan_page_test.dart
```

Expected: FAIL. The page is still the placeholder from Task 1.

- [ ] **Step 3: Build the page**

Compose in this order, following the spec's Section 4 exactly:

1. App bar titled `Your plan`, with a back arrow.
2. The exam name at rank 2, then one muted line: weeks to go, and the exam date **only at day
   precision**.
3. Plate `Today` with the date in the trailing slot, then the total at rank 1 beside two lines
   of detail at rank 5: `N questions today.` and `X to review, Y new.`
4. Plate `The rest of this week` with the date range trailing, then one row per remaining day:
   the date at rank 4 on the left, `X review, Y new` at rank 5 on the right, a hairline under
   each row.
5. Plate `Coming up`, then one row per week: the week start at rank 4, and any marker label at
   rank 5 in amber on the right.
6. The closing sentence at rank 6, muted.

**The six ranks, in the sizes the spec fixes:** rank 1 serif 30/700, rank 2 serif 24/700,
rank 3 serif 16/700 on a 1.6px `ink` rule, rank 4 serif 14/700, rank 5 sans 13/400, rank 6
sans 11.5/400 `inkMuted`.

**Several of those sizes do not exist in the app's text styles yet.** They are added by
`docs/superpowers/plans/2026-08-03-settings-01-the-kit.md`. **If they are absent when you get
here, stop and say so** rather than hand-rolling sizes that will later disagree with the kit.

Copy for the closing sentence, with the numbers substituted:

```
Seven new questions a day finishes the material by 5 October, a week before your exam.
Daily review counts come from your own schedule. You can go faster in Settings, not slower.
```

**Every number in that sentence is substituted, none is hard coded.** Seven is what the worked
example computes; it is not a default.

- [ ] **Step 4: Run the tests**

```bash
flutter test test/features/study_plan/presentation/plan_page_test.dart
```

Expected: PASS, all seven.

- [ ] **Step 5: Run the full gate set**

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(plan): the forward calendar, read not pressed"
```

---

## What this plan deliberately does not do

- **It does not unhide the entry row.** Whether the plan is reachable in v1 is a separate call.
  The route already exists and this plan leaves its visibility exactly as it found it.
- **It does not touch the entitlement provider**, which is owned by the offline posture work.
- **It does not fill the two reservations elsewhere.** The reader's plan counter and Home's
  three-lesson chain both wait on a daily lesson chain, and this design produces none. Section 6
  of the spec says they should be closed rather than left waiting, and that is a decision for
  Aedwon, not a task here.
- **It adds no table and no column**, so `schemaVersion` does not move.

## Verification for the whole plan

```bash
grep -rniE "mastery|on track|paceStatus|tolerance band" lib/features/study_plan
```

Expected: **nothing.**

```bash
grep -rn "UnimplementedError" lib/features/study_plan
```

Expected: **nothing.**

- The page has zero buttons and zero board green elements.
- No week after the current one carries a number.
- A student whose exam is ten days away gets a plan, with no warning and no triage.
- The "Do more each day" switch can raise both daily counts and can never lower either.
- At month precision the header prints no day count, and the pacing runs against the first of
  that month.
- A Pro student sees no mock marker. A Free student sees exactly one.
- `schemaVersion` in `lib/core/storage/data/app_database.dart` is unchanged.
