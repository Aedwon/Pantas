# Home, Plan 2 of 6: The Assessment Writes an Attempt Row

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

**Goal:** Make the assessment record its answers where every other session records them,
so the metrics layer and the Progress table can see its questions, without telling the
speed signals that twenty-one questions were answered in zero milliseconds.

**Architecture:** One new value on `SessionOrigin`, one shared constant naming the
origins that carry no timing, an `AttemptsRepository.save` call added to
`CompleteAssessment`, and three signals taught to skip untimed rows. No UI, no routing,
no schema migration.

**Tech Stack:** Flutter, Drift, freezed, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-07-26-home-and-navigation-design.md`
Section 3, "Two prerequisites this creates".
**Decision log:** `docs/superpowers/decisions/2026-08-02-home-weakest-areas-log.md`,
entry "two prerequisites 1A exposed, decided without asking".

---

## Why this is its own plan, and why it is first

**It has no UI and it unblocks three surfaces.** Home's Practice panel (Plan 5) reads
attempts at topic level and would be empty immediately after the assessment without this.
Progress's Performance table reads `SubjectAffinitySignal` and is blind to the same
twenty-one questions today. And any future surface that asks "what has this student
answered" inherits the same hole.

**It is also a live defect, not only a prerequisite.** Nothing in the app currently
records that the assessment happened, in the place the app records answering. A reviewer
can accept or reject this plan on that ground alone.

## What is true today, verified against the code

- `CompleteAssessment` (`lib/features/assessment/domain/use_cases/complete_assessment.dart`)
  writes exactly two things: `assessment_results_local` via
  `AssessmentRepository.saveResult`, and one FSRS row per answered question via
  `ReviewStateRepository.upsert`. It never touches `attempts_local`.
- `AttemptsRepository.save` already exists and takes a domain `Attempt`
  (`lib/core/storage/data/repos/attempts_repository.dart:14`).
- `Attempt.origin` is a plain `String` defaulting to `'today_topic'`
  (`lib/core/storage/domain/attempt.dart`). The strings come from
  `SessionOrigin.storageValue`.
- `SessionOrigin` (`lib/features/quiz/domain/models/session_origin.dart`) has five
  values: `todayTopic`, `todayInterleaved`, `drill`, `retake`, `inline`. Its
  `fromStorage` falls back to `todayTopic` for anything unknown, so an
  `'assessment'` string written before the enum gains the value would be silently
  misread. **Task 1 must land before Task 2.**
- `AttemptItem.responseMs` is `required int` and `MetricAttemptItem.responseMs` is read
  with `json['responseMs']! as int`. Neither tolerates a null.
- `AssessmentSession.answers` is a `Map<QuestionId, ChoiceId>`. **No timing is captured
  anywhere in the assessment**, which is why the exclusion in Task 3 exists.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files (`*.g.dart`, `*.freezed.dart`) are never edited by hand and never
  committed.** `attempt.dart` is freezed; if you change it, run
  `dart run build_runner build --delete-conflicting-outputs` and do not `git add` the
  output.
- **No schema migration.** `attempts_local` already has every column this needs, and
  `origin` is a `TextColumn` with a default. Do not bump `schemaVersion`.
- **Do not invent a response time.** Writing a plausible-looking millisecond figure for
  an untimed question would be exactly the fabrication `AGENTS.md` bans. Zero is written
  because it is the only honest value the type allows, and the exclusion in Task 3 is
  what keeps it from being read as a measurement.
- **Analyzer must be clean.** `very_good_analysis` with `strict-casts` and
  `strict-inference`.

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
| `lib/features/quiz/domain/models/session_origin.dart` (modify) | Gains `assessment`, and states that it earns no streak |
| `lib/core/storage/domain/attempt_origins.dart` (create) | The one list of origins that carry no timing. Signals import this rather than hardcoding a string |
| `lib/features/assessment/domain/use_cases/complete_assessment.dart` (modify) | Writes the attempt row alongside the result and the FSRS seeds |
| `lib/features/metrics/signals/per_question_speed_signal.dart` (modify) | Skips untimed rows wholesale |
| `lib/features/metrics/signals/difficulty_calibration_signal.dart` (modify) | Skips untimed rows wholesale |
| `lib/features/metrics/signals/subject_affinity_signal.dart` (modify) | Counts correctness from every row, accumulates milliseconds from timed rows only |

---

### Task 1: `SessionOrigin.assessment`, and the untimed list

**Files:**
- Modify: `lib/features/quiz/domain/models/session_origin.dart`
- Create: `lib/core/storage/domain/attempt_origins.dart`
- Test: `test/features/quiz/domain/models/session_origin_test.dart` (create or extend)
- Test: `test/core/storage/domain/attempt_origins_test.dart` (create)

**Interfaces:**
- Produces: `SessionOrigin.assessment` with `storageValue == 'assessment'` and
  `isStreakEligible == false`; and
  `abstract final class AttemptOrigins { static const Set<String> untimed; }`
  containing exactly `{'assessment'}`. Tasks 2 and 3 both read these.

**Why the untimed list lives in `core/storage/domain` and not beside the enum:** the
signals are in `lib/features/metrics/` and must not import from
`lib/features/quiz/`. Feature-to-feature imports are the layering violation this
repository already carries seven of; do not add an eighth.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/storage/domain/attempt_origins_test.dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt_origins.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assessment is the only untimed origin today', () {
    expect(AttemptOrigins.untimed, {'assessment'});
  });
}
```

```dart
// test/features/quiz/domain/models/session_origin_test.dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt_origins.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assessment round-trips through storage', () {
    expect(SessionOrigin.assessment.storageValue, 'assessment');
    expect(
      SessionOrigin.fromStorage('assessment'),
      SessionOrigin.assessment,
    );
  });

  test('the assessment earns no streak', () {
    expect(SessionOrigin.assessment.isStreakEligible, isFalse);
  });

  test('every existing origin still round-trips', () {
    for (final origin in SessionOrigin.values) {
      expect(SessionOrigin.fromStorage(origin.storageValue), origin);
    }
  });

  test('the untimed list names a real origin', () {
    for (final value in AttemptOrigins.untimed) {
      expect(
        SessionOrigin.values.map((o) => o.storageValue),
        contains(value),
      );
    }
  });
}
```

- [ ] **Step 2: Run them to make sure they fail**

Run:
```bash
flutter test test/core/storage/domain/attempt_origins_test.dart test/features/quiz/domain/models/session_origin_test.dart
```
Expected: FAIL, `Couldn't resolve ... attempt_origins.dart` and
`The getter 'assessment' isn't defined for the type 'SessionOrigin'`.

- [ ] **Step 3: Write both**

```dart
// lib/core/storage/domain/attempt_origins.dart

/// Origins whose attempt rows carry no per-question timing.
///
/// The assessment records which choice was made and nothing about how long
/// it took, so its items are written with `responseMs: 0`. Any signal that
/// reads a millisecond figure must skip these rows, or it will read those
/// zeros as twenty-one questions answered instantly.
///
/// Remove an origin from this set the moment it starts capturing timing.
abstract final class AttemptOrigins {
  const AttemptOrigins._();

  static const Set<String> untimed = {'assessment'};
}
```

In `session_origin.dart`, add the value and extend the doc on `isStreakEligible`:

```dart
enum SessionOrigin {
  todayTopic('today_topic'),
  todayInterleaved('today_interleaved'),
  drill('drill'),
  retake('retake'),
  inline('inline'),

  /// The one-off assessment. Recorded as an attempt so the metrics layer and
  /// the Progress table can see its questions, and deliberately outside the
  /// streak: it is taken once and is not a day's work.
  assessment('assessment');

  const SessionOrigin(this.storageValue);

  final String storageValue;

  bool get isStreakEligible =>
      this == SessionOrigin.todayTopic ||
      this == SessionOrigin.todayInterleaved;

  static SessionOrigin fromStorage(String value) {
    return SessionOrigin.values.firstWhere(
      (origin) => origin.storageValue == value,
      orElse: () => SessionOrigin.todayTopic,
    );
  }
}
```

`isStreakEligible` needs no edit: it already allowlists two values, so a new one is
excluded by construction. The test pins that so a later change to an denylist is caught.

- [ ] **Step 4: Run the tests and make sure they pass**

Run:
```bash
flutter test test/core/storage/domain/attempt_origins_test.dart test/features/quiz/domain/models/session_origin_test.dart
```
Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/domain/attempt_origins.dart lib/features/quiz/domain/models/session_origin.dart test/core/storage/domain/attempt_origins_test.dart test/features/quiz/domain/models/session_origin_test.dart
git commit -m "feat(storage): add SessionOrigin.assessment and the untimed-origin list"
```

---

### Task 2: `CompleteAssessment` writes the row

**Files:**
- Modify: `lib/features/assessment/domain/use_cases/complete_assessment.dart`
- Test: `test/features/assessment/domain/use_cases/complete_assessment_test.dart`
  (extend; it exists)

**Interfaces:**
- Consumes: `SessionOrigin.assessment` from Task 1;
  `AttemptsRepository.save(Attempt)` from
  `lib/core/storage/data/repos/attempts_repository.dart:14`;
  `Attempt` and `AttemptItem` from `lib/core/storage/domain/attempt.dart`.
- Produces: exactly one `attempts_local` row per completed assessment, with
  `origin: 'assessment'`, `completedAt` set to the same `now` the result row uses, and
  one `AttemptItem` per **answered** question.

**Three decisions this task makes, each with its reason:**

1. **Unanswered questions are not written.** `session.answers[id]` may be null, and an
   `AttemptItem` needs a `chosenChoiceId`. A skipped question is not a wrong answer and
   writing it as one would make the student's accuracy worse than their behaviour.
   Note that the existing per-topic `total` in `saveResult` **does** count skips, so the
   two figures can differ. That is pre-existing and out of scope here.
2. **`responseMs` is 0.** The assessment captures no timing. Task 3 is what stops that
   zero being read as a measurement.
3. **The attempt id is the session id.** `AssessmentSession` already carries one, and
   reusing it makes the write idempotent: completing twice overwrites rather than
   duplicating, because `save` uses `insertOnConflictUpdate`.

Read `AssessmentSession` before writing this task and use its real field names. If it
carries no id, mint one with `const Uuid().v4()` and add `uuid` to the constructor the
way `StartTodaySession` does (`lib/features/quiz/domain/use_cases/start_today_session.dart:42`),
rather than inventing an id scheme.

- [ ] **Step 1: Write the failing test**

Add to the existing test file. Use whatever fake or in-memory `AppDatabase` the file
already sets up; if it uses hand-written fakes, add a fake `AttemptsRepository` that
records its `save` calls in a list.

```dart
  test('writes one attempt row, with origin assessment and no timing',
      () async {
    final session = /* the same fixture the existing tests build */;
    await useCase(session: session, now: now);

    final saved = attemptsRepo.saved;
    expect(saved, hasLength(1));
    final attempt = saved.single;
    expect(attempt.origin, 'assessment');
    expect(attempt.examId, session.examId);
    expect(attempt.completedAt, now);
    expect(attempt.items.every((i) => i.responseMs == 0), isTrue);
  });

  test('an unanswered question is not written as a wrong answer', () async {
    // Build a session whose answers map omits one question id.
    final session = /* fixture with 3 questions, 2 answered */;
    await useCase(session: session, now: now);

    expect(attemptsRepo.saved.single.items, hasLength(2));
  });

  test('the item carries the chosen and the correct choice', () async {
    final session = /* fixture where question q1 is answered wrongly */;
    await useCase(session: session, now: now);

    final item = attemptsRepo.saved.single.items
        .firstWhere((i) => i.questionId == 'q1');
    expect(item.isCorrect, isFalse);
    expect(item.chosenChoiceId, isNot(item.correctChoiceId));
  });

  test('completing twice writes one row, not two', () async {
    final session = /* any fixture */;
    await useCase(session: session, now: now);
    await useCase(session: session, now: now);

    expect(
      attemptsRepo.saved.map((a) => a.id).toSet(),
      hasLength(1),
      reason: 'the attempt id is the session id, so the write is idempotent',
    );
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/features/assessment/domain/use_cases/complete_assessment_test.dart`
Expected: FAIL. If you added the fake repository as a new required constructor argument,
the failure is a compile error on the existing tests' construction of the use case; fix
those constructions in the same step, since they are the same change.

- [ ] **Step 3: Write the implementation**

Add the repository to the constructor:

```dart
class CompleteAssessment {
  CompleteAssessment({
    required AssessmentRepository assessmentRepo,
    required ReviewStateRepository reviewRepo,
    required FsrsScheduler scheduler,
    required ContentRepository contentRepo,
    required AttemptsRepository attemptsRepo,
  })  : _assessmentRepo = assessmentRepo,
        _reviewRepo = reviewRepo,
        _scheduler = scheduler,
        _contentRepo = contentRepo,
        _attemptsRepo = attemptsRepo;

  final AttemptsRepository _attemptsRepo;
```

Then, after `await _assessmentRepo.saveResult(...)` and before the FSRS loop, write the
row. Placing it before the loop means a crash mid-seed still leaves the answers recorded.

```dart
    // Record the assessment where every other session records itself, so
    // the metrics layer and the Progress table can see these questions.
    // responseMs is 0 because the assessment captures no timing;
    // AttemptOrigins.untimed is what stops that being read as speed.
    final items = <AttemptItem>[];
    for (final aq in session.questions) {
      final chosen = session.answers[aq.question.id];
      if (chosen == null) continue; // a skip is not a wrong answer
      final correct = aq.question.choices.firstWhere((c) => c.isCorrect);
      items.add(
        AttemptItem(
          questionId: aq.question.id,
          questionVersion: aq.question.version,
          chosenChoiceId: chosen,
          correctChoiceId: correct.id,
          responseMs: 0,
        ),
      );
    }
    await _attemptsRepo.save(
      Attempt(
        id: session.id,
        examId: session.examId,
        startedAt: session.startedAt,
        completedAt: now,
        origin: SessionOrigin.assessment.storageValue,
        items: items,
      ),
    );
```

If `AssessmentSession` has no `startedAt`, pass `now` for both and say so in the commit
body rather than inventing a start time.

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/features/assessment/`
Expected: PASS.

- [ ] **Step 5: Fix every construction site of `CompleteAssessment`**

Run: `grep -rn "CompleteAssessment(" lib test`

Every hit must pass the new argument. In `lib/`, the provider that builds it needs the
`AttemptsRepository` provider; find it with
`grep -rn "AttemptsRepository(" lib` and reuse the existing provider rather than
constructing a second repository.

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "fix(assessment): record the assessment as an attempt

The assessment wrote its result row and seeded FSRS and nothing else, so
every metrics signal and the whole Progress performance table were blind
to its questions, and Home's practice panel would have been empty at the
moment it is most needed.

Skips are not written as wrong answers. responseMs is 0 because the
assessment captures no timing at all."
```

---

### Task 3: The speed signals skip untimed rows

**Files:**
- Modify: `lib/features/metrics/signals/per_question_speed_signal.dart:30-55`
- Modify: `lib/features/metrics/signals/difficulty_calibration_signal.dart:27-32`
- Modify: `lib/features/metrics/signals/subject_affinity_signal.dart:33-45` and
  `:77-88` (`_SubjectStats`)
- Test: `test/features/metrics/signals/per_question_speed_signal_test.dart` (extend)
- Test: `test/features/metrics/signals/subject_affinity_signal_test.dart` (extend)

**Interfaces:**
- Consumes: `AttemptOrigins.untimed` from Task 1.
- Produces: no new public API. `LatencyDistribution`, `CalibrationCurve` and
  `SubjectAccuracySpeed` keep their existing shapes.

**The rule is not the same for all three, and the difference is the point:**

| Signal | Treatment | Why |
|---|---|---|
| `PerQuestionSpeedSignal` | Skip the row entirely | Every field it produces is a millisecond figure. An untimed row contributes nothing it can use |
| `DifficultyCalibrationSignal` | Skip the row entirely | It pairs difficulty against both `averageMs` and accuracy. Feeding one axis and poisoning the other produces a curve that looks measured and is not |
| `SubjectAffinitySignal` | Keep correctness, drop the milliseconds | It is the only one whose correctness output is wanted. Progress's Performance table reads its `correct` and `total`, and its `averageMs` is not printed anywhere, because the Progress spec takes time from timed mock attempts only |

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/metrics/signals/per_question_speed_signal_test.dart
  test('an assessment row contributes no latency', () async {
    await insertAttempt(origin: 'assessment', responseMsPerItem: 0, items: 5);
    await insertAttempt(origin: 'today_topic', responseMsPerItem: 8000, items: 5);

    final result = await signal.compute(window: window, examId: examId);

    expect(
      result!.averageMs,
      8000,
      reason: 'the untimed row must not drag the average toward zero',
    );
  });

  test('with only untimed rows there is no distribution at all', () async {
    await insertAttempt(origin: 'assessment', responseMsPerItem: 0, items: 5);

    expect(await signal.compute(window: window, examId: examId), isNull);
  });
```

```dart
// test/features/metrics/signals/subject_affinity_signal_test.dart
  test('an assessment row counts for accuracy', () async {
    await insertAttempt(
      origin: 'assessment',
      subject: 'Science',
      correct: 1,
      wrong: 2,
      responseMsPerItem: 0,
    );

    final row = (await signal.compute(window: window, examId: examId))!
        .subjects['Science']!;
    expect(row.correct, 1);
    expect(row.total, 3);
  });

  test('an assessment row does not count for speed', () async {
    await insertAttempt(
      origin: 'assessment',
      subject: 'Science',
      correct: 3,
      wrong: 0,
      responseMsPerItem: 0,
    );
    await insertAttempt(
      origin: 'today_topic',
      subject: 'Science',
      correct: 1,
      wrong: 0,
      responseMsPerItem: 6000,
    );

    final row = (await signal.compute(window: window, examId: examId))!
        .subjects['Science']!;
    expect(row.total, 4, reason: 'all four count for accuracy');
    expect(
      row.averageMs,
      6000,
      reason: 'only the one timed item divides into the total',
    );
  });

  test('a subject with only untimed items reports zero milliseconds', () async {
    await insertAttempt(
      origin: 'assessment',
      subject: 'Maths',
      correct: 2,
      wrong: 1,
      responseMsPerItem: 0,
    );

    final row = (await signal.compute(window: window, examId: examId))!
        .subjects['Maths']!;
    expect(row.total, 3);
    expect(row.averageMs, 0, reason: 'never a divide by zero');
  });
```

If the existing test files have no `insertAttempt` helper, write one that inserts an
`AttemptsLocalCompanion.insert` row directly with a JSON items list, and reuse it across
both files by putting it in the file that needs it. Do not build a shared test helper
package for two files.

- [ ] **Step 2: Run them to make sure they fail**

Run: `flutter test test/features/metrics/signals/`
Expected: FAIL. `averageMs` comes back as 4000 rather than 8000 in the first test,
because the zeros are being averaged in.

- [ ] **Step 3: `PerQuestionSpeedSignal`, skip the row**

Add the import and one clause to the existing query:

```dart
import 'package:cse_cet_reviewer/core/storage/domain/attempt_origins.dart';
```

```dart
    var query = _db.select(_db.attemptsLocal)
      ..where(
        (row) =>
            row.examId.equals(examId) &
            row.completedAt.isNotNull() &
            row.startedAt.isSmallerOrEqualValue(window.end) &
            // Untimed origins carry responseMs: 0 for every item. Averaging
            // them in would report answers given instantly.
            row.origin.isNotIn(AttemptOrigins.untimed.toList()),
      );
```

- [ ] **Step 4: `DifficultyCalibrationSignal`, skip the row**

Same import, same clause:

```dart
    final attempts = await (_db.select(_db.attemptsLocal)
          ..where(
            (row) =>
                row.examId.equals(examId) &
                row.completedAt.isNotNull() &
                row.origin.isNotIn(AttemptOrigins.untimed.toList()),
          ))
        .get();
```

- [ ] **Step 5: `SubjectAffinitySignal`, split correctness from speed**

The query keeps every row. `_SubjectStats` learns to count its timed items separately.

```dart
    for (final row in rows) {
      final timed = !AttemptOrigins.untimed.contains(row.origin);
      for (final item in _reader.read(row.itemsJson)) {
        final subject = await _content.subjectNameForQuestion(item.questionId);
        if (subject == null) continue;
        stats.putIfAbsent(subject, _SubjectStats.new).add(
              isCorrect: item.isCorrect,
              responseMs: item.responseMs,
              timed: timed,
            );
      }
    }
```

```dart
class _SubjectStats {
  int correct = 0;
  int total = 0;
  int totalMs = 0;

  /// Items from a timed origin. The milliseconds divide by this, never by
  /// [total], or an assessment's zeros would halve the average.
  int timedTotal = 0;

  void add({
    required bool isCorrect,
    required int responseMs,
    required bool timed,
  }) {
    total += 1;
    if (isCorrect) correct += 1;
    if (!timed) return;
    timedTotal += 1;
    totalMs += responseMs;
  }

  double get averageMs => timedTotal == 0 ? 0 : totalMs / timedTotal;
}
```

- [ ] **Step 6: Run the tests and make sure they pass**

Run: `flutter test test/features/metrics/`
Expected: PASS.

- [ ] **Step 7: Run the whole suite**

Run: `flutter test`
Expected: PASS, and the count is above the 963 recorded on 2 August by the tests this
plan added.

- [ ] **Step 8: Analyze and format**

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```
Expected: `No issues found!` and no format diff.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "fix(metrics): keep untimed attempts out of every speed figure

The assessment now writes an attempt row with responseMs: 0, because it
captures no timing. PerQuestionSpeedSignal and DifficultyCalibrationSignal
skip those rows entirely. SubjectAffinitySignal keeps them for accuracy,
which is the point of writing them, and divides its milliseconds by the
timed items only."
```

---

## Two signals deliberately left alone

Both read `attempts_local` and neither reads a millisecond figure, so both are correct
as they stand. Recorded so a reviewer does not read the omission as an oversight.

- **`TestModeDeltaSignal`** compares `attempts_local` against `mock_attempts`. The
  assessment lands on the practice side, which is what it is: untimed, non-mock
  answering.
- **`ReadThenQuizSignal`** compares questions answered after reading the lesson against
  questions answered cold. Assessment questions are genuinely cold, since the assessment
  is taken before any reading.

## Lift this when the assessment learns to time itself

`AttemptOrigins.untimed` exists to be emptied. If the assessment ever records a
per-question response time, delete `'assessment'` from that set and the three signals
pick the rows up with no other change. Nothing else in the codebase hardcodes the
string.

## Verification, for the reviewer

- `flutter test` and `flutter analyze` both clean.
- `grep -rn "'assessment'" lib` returns the enum value and the untimed set, and
  nothing else. No signal hardcodes the string.
- `schemaVersion` in `lib/core/storage/data/app_database.dart` is **unchanged**. This
  plan adds no column and needs no migration.
- Taking the assessment on the emulator and reopening Progress shows subject rows where
  it previously showed none. Report that as a text signal; do not screenshot it.
