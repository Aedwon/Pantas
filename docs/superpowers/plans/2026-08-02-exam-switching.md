# Switching Exams, and Whether Earlier Work Counts

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

## AMENDED 3 August 2026: two tasks are struck. Settings builds them.

**Conflict C4, ruled by Aedwon.** This plan and the Settings thread both built the carry-over
feature, and they disagreed about where the preference lives, which is exactly the fault the
paywall consolidation round existed to fix.

| Task here | Struck in favor of |
|---|---|
| **Task 1**, the carry-over preference and the count | `2026-08-03-settings-02-storage.md`, which puts `carryOverProgress` on `UserSettings` under `settings.carry_over_progress`, and `2026-08-03-settings-05-the-exam-page.md` Task 2, which measures the carryable count as `carryableCountProvider` |
| **Task 3**, the prompt | `2026-08-03-settings-05-the-exam-page.md` Task 3, which builds the same prompt with the same copy |

**The preference lives on `UserSettings`, not on `AppPreferencesRepository`.** It is a
preference about the student and it syncs. Task 1's `AppPreferencesRepository.carriesOverProgress`
is not built.

**This plan is now two tasks, and both are genuinely its own:**

- **Task 2**, the mock cooldown becomes per student rather than per exam. This closes a real
  exploit: a Free student switches exams, or makes a second custom track, and gets a fresh
  paper.
- **Task 4**, the carry-over filter applied to the Progress and Home figure providers.
  **Task 4 now consumes `userSettingsProvider.carryOverProgress`**, not Task 1's method, and
  its "Settings row" step is struck because Settings builds the row.

**Consider folding what remains into `settings-05` entirely.** Two tasks is a thin plan and
Task 4 reads a Settings value. Raised, not decided.

---

**Goal:** Let a student change which exam they are studying for, tell them truthfully what
carries over, and close the hole where switching buys a free mock.

**Architecture:** No migration and no copying. One preference decides whether attempts from
other exams count toward this one's figures, and one query counts how many could. The mock
cooldown moves from per exam to per student.

**Tech Stack:** Flutter, Riverpod, drift, go_router, flutter_test. No new packages.

**Source spec:** `docs/superpowers/specs/2026-08-02-exam-switching-design.md`.

**Decision log:** `docs/superpowers/decisions/2026-08-02-onboarding-name-and-date-log.md`.

**Depends on:** Task 4 of `plans/2026-07-25-onboarding-polish.md`, which builds the
Settings → Exam page this plan adds two things to. Do not start until that is merged.

---

## What already works, established from the code rather than assumed

**Two of the three things you would expect to migrate do not need migrating.**

- **`review_state_local` is keyed by `questionId` alone.** There is no exam column, so every
  piece of FSRS scheduling built while studying DOST already applies to UPCAT.
- **`Questions.examIdsJson` is a list.** A question can already belong to DOST and UPCAT
  simultaneously, in the content model as it stands.

What is genuinely exam-scoped: `selected_exam_id`, `assessment_results_local` keyed by
`examId`, and `attempts_local.examId`, which records the context an attempt happened in.

**So there is nothing to copy or move.** This plan is about what the figures count.

## The one live exploit this closes

**`mockAvailabilityProvider` calls `lastCooldownAttempt(userId, examId)`.** The cooldown is
per exam today. A Free user moves DOST to UPCAT and gets a fresh paper, moves back and gets
another. The Quiz spec's tier table reads "One every 14 days **per track**"; **per track is
the exploit**, and the switching spec corrects it to **per student**.

Plan B of the custom track work names this and deliberately leaves it here, so it is fixed
once.

## Global Constraints

- **No new dependencies.**
- **Work only inside your worktree.** Never write to the main checkout.
- **Generated files are never edited by hand, and never committed.**
- **Nothing is deleted, ever.** Switching leaves the old assessment, every old attempt and
  all FSRS state exactly where they are. **This is the third time this rule has been set
  across the 2 August specs**, after the custom track's subject narrowing and the flag table,
  and it should read as one rule: **Pantas filters, it does not purge.** If you write a
  `DELETE` in this plan, you have misread it.
- **The word "migrate" appears in no user-facing string.** It is engineer-speak, it sounds
  irreversible, and it sounds dangerous. The word is **"carry over"**.
- **Never invent a figure.** The prompt's count is measured from the student's own attempts,
  which is why it may be printed.
- **Ink & Rule identity.** No card elevation, no drop shadows, no large corner radii, no
  tinted callout boxes, no coloured left-border panels, no blur, no shimmer.
- **Voice.** Grade-5-simple English, short sentences, **no em dashes**.
- **Layering.** R1, R2, R3. **The baseline is 7 violations.**
- **Commit messages carry no AI attribution and no co-author trailers.**
- Every task ends green on `flutter analyze`, `dart format --set-exit-if-changed lib test`,
  and the tests it touches.

---

## File Structure

**Create:**
- `lib/features/settings/presentation/widgets/carry_over_prompt.dart`
- Tests mirroring each change.

**Modify:**
- `lib/core/storage/data/repos/app_preferences_repository.dart` — the carry-over flag.
- `lib/core/storage/data/repos/attempts_repository.dart` — the carryable count, and a
  filtered read.
- `lib/features/mock_exam/data/mock_attempt_repo.dart` — the cooldown, per student.
- `lib/features/mock_exam/application/mock_availability_provider.dart`.
- `lib/features/settings/presentation/pages/exam_page.dart` — the prompt and the row.
- the Progress and Home figure providers.

---

## Task 1: The carry-over preference and the count

**Files:**
- Modify: `lib/core/storage/data/repos/app_preferences_repository.dart`
- Modify: `lib/core/storage/data/repos/attempts_repository.dart`
- Test: `test/core/storage/data/repos/carry_over_test.dart` (create)

**Interfaces:**
- Produces, relied on by every later task:
  - `AppPreferencesRepository.carriesOverProgress() -> Future<bool>` and
    `setCarriesOverProgress({required bool value})`, defaulting **true**
  - `AttemptsRepository.carryableQuestionCount({required ExamId examId, required Set<QuestionId> questionsInExam}) -> Future<int>`

**From the spec, "What counts as carryable":** an attempt counts toward the new exam only if
**the question it was on lists the new exam in `examIdsJson`**. Work on a question that is not
in the new exam's pool is never counted under any setting. **No new storage: the join already
exists.**

**The caller supplies `questionsInExam`.** `attempts_local` holds question ids and this
repository must not reach into content to resolve which exams they belong to. The Settings
page has the exam and can ask `ContentRepository`.

**The default is to count them.** It is the truthful position: knowledge does not reset
because a student changed what they are applying for, and FSRS has always behaved this way
without complaint.

**Stored on `devicePrefs`, beside `selected_exam_id`**, following that key's existing shape
including its legacy fallback read.

- [ ] **Step 1: Write the failing test**

```dart
  test('carry over is on until it is turned off', () async {
    expect(await prefs.carriesOverProgress(), isTrue);
    await prefs.setCarriesOverProgress(value: false);
    expect(await prefs.carriesOverProgress(), isFalse);
  });

  test('the carryable count is distinct questions in the new pool', () async {
    // Attempts on q_1, q_1, q_2, q_3. The new exam holds q_1 and q_2.
    expect(count, 2);
  });

  test('a question outside the new pool never counts', () async {
    // Only q_3 answered, and it is not in the new exam.
    expect(count, 0);
  });

  test('attempts already under the new exam still count', () async {
    // The count is about questions, not about which exam the attempt was
    // filed under.
  });
```

- [ ] **Step 2 to 4: Run it, add both, run it again**

```dart
  /// How many distinct questions this student has answered that are also in
  /// [examId]'s pool.
  ///
  /// The caller passes the pool because this layer holds question ids and
  /// nothing that resolves them to exams.
  Future<int> carryableQuestionCount({
    required ExamId examId,
    required Set<QuestionId> questionsInExam,
  }) async {
    final rows = await _db.select(_db.attemptsLocal).get();
    final answered = <QuestionId>{};
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        if (questionsInExam.contains(item.questionId)) {
          answered.add(item.questionId);
        }
      }
    }
    return answered.length;
  }
```

**No `examId` filter on the select.** The whole point is that attempts filed under *other*
exams are the ones being counted.

- [ ] **Step 5: Commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(storage): carrying work over between exams

Nothing is copied. An attempt counts toward the new exam when the
question it was on is also in that exam's pool, which the content model
already expresses as a list."
```

---

## Task 2: The cooldown becomes per student

**Files:**
- Modify: `lib/features/mock_exam/data/mock_attempt_repo.dart`
- Modify: `lib/features/mock_exam/application/mock_availability_provider.dart`
- Test: `test/features/mock_exam/data/mock_cooldown_per_student_test.dart` (create)

**Interfaces:**
- Produces: `MockAttemptRepo.lastCooldownAttemptForUser(String userId)`.
  `lastCooldownAttempt(userId, examId)` stays for anything that genuinely wants one exam's
  history; **if nothing does after this change, delete it.**

**From the spec, Section 3:** **a switch must not grant a new mock.** Otherwise a Free user
moves DOST to UPCAT and back whenever they want another paper, which is the same hole the
custom track's mocks had. The cooldown is computed per student, from the most recent terminal
`submittedAt`, and **it is unaffected by which exam is selected**.

**This also closes the custom-track version of the exploit.** A Free user could otherwise make
a track, take its mock, make another track, and repeat.

- [ ] **Step 1: Write the failing test**

```dart
  test('a mock taken under another exam still holds the cooldown', () async {
    // Submit a DOST mock today, select UPCAT, ask availability.
    expect(availability.state, MockAvailabilityState.cooldown);
  });

  test('a mock taken under a custom track holds it too', () async { ... });

  test('the cooldown still expires after fourteen days', () async { ... });

  test('another student is unaffected', () async {
    // Different userId, no cooldown.
  });
```

- [ ] **Step 2 to 4: Run it, drop the exam filter, run it again**

```dart
  /// The most recent finished mock for this student, whatever exam it was
  /// taken under.
  ///
  /// Per student and not per exam. Per exam is an exploit: a free user
  /// switches exams, or makes a second custom track, and gets another paper.
  Future<MockAttempt?> lastCooldownAttemptForUser(String userId) async { ... }
```

and in `mockAvailabilityProvider`, replace the call. `MockAvailabilityRequest` keeps its
`examId` because `findInProgress` and the panel still want it.

- [ ] **Step 5: Commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "fix(mock): the cooldown is per student, not per exam

Per exam meant a free user could move DOST to UPCAT and back for a fresh
paper whenever they wanted one, and could do the same by making a second
custom track."
```

---

## Task 3: The prompt

**Files:**
- Create: `lib/features/settings/presentation/widgets/carry_over_prompt.dart`
- Modify: `lib/features/settings/presentation/pages/exam_page.dart`
- Test: `test/features/settings/presentation/carry_over_prompt_test.dart`

**Interfaces:**
- Consumes: Task 1's count and preference.
- Produces: the prompt, shown on switch.

**From the spec, "The prompt, shown on switch":**

> **You're not starting from zero**
>
> 412 of the questions you've answered are also on UPCAT. We'll count them toward your UPCAT
> progress so you can pick up where you are, not where you started.
>
> [ Count them ]
> Start my numbers fresh
>
> Either way, we'll keep scheduling your reviews around what you already know.

**"Count them" is a board button and "Start my numbers fresh" is a board text action beneath
it**, matching Discard's treatment on the Quiz tab's session panel: the recommended path is
the button, the other is a text action and not a second button.

**The count is measured** from the student's own attempts, so it is a figure the app is
permitted to print.

**The last line is not decoration.** It states the rule that would otherwise be discovered:
the choice governs figures and history, never scheduling.

**The prompt is skipped when the count is zero.** "0 of the questions you've answered are also
on UPCAT" is not the sentence this screen is for, and there is nothing to decide. Switch
silently, leave the setting at its default, and let the Settings row carry it.

- [ ] **Step 1: Write the failing test**

```dart
  testWidgets('the prompt names the measured count and the exam',
      (tester) async {
    expect(
      find.text("412 of the questions you've answered are also on UPCAT. "
          "We'll count them toward your UPCAT progress so you can pick up "
          'where you are, not where you started.'),
      findsOneWidget,
    );
  });

  testWidgets('counting them is the recommended path', (tester) async {
    // 'Count them' is a BoardButton; 'Start my numbers fresh' is not.
  });

  testWidgets('the scheduling rule is stated either way', (tester) async {
    expect(
      find.text("Either way, we'll keep scheduling your reviews around what "
          'you already know.'),
      findsOneWidget,
    );
  });

  testWidgets('choosing fresh writes the preference', (tester) async {
    await tester.tap(find.text('Start my numbers fresh'));
    await tester.pumpAndSettle();
    expect(await prefs.carriesOverProgress(), isFalse);
  });

  testWidgets('nothing carryable means no prompt', (tester) async {
    // count 0: the switch happens and the prompt never appears.
    expect(find.text("You're not starting from zero"), findsNothing);
  });

  testWidgets('the word migrate appears nowhere', (tester) async {
    expect(find.textContaining('migrate'), findsNothing);
    expect(find.textContaining('Migrate'), findsNothing);
  });
```

- [ ] **Step 2 to 4: Run it, build the prompt, run it again**

- [ ] **Step 5: Commit**

```bash
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(settings): what carries over when you switch

Nothing is copied, so the choice is reversible and can be offered as a
prompt rather than a warning. It states the scheduling rule outright,
because the alternative is discovering it."
```

---

## Task 4: The Settings row, and the figures that follow it

**Files:**
- Modify: `lib/features/settings/presentation/pages/exam_page.dart`
- Modify: the Progress and Home figure providers
- Test: `test/features/progress/carry_over_filter_test.dart` (create)

**Interfaces:**
- Consumes: `carriesOverProgress`.
- Produces: nothing new.

**From the spec, "The Settings row":**

> **Carry over progress**
> Answers from your other exams count toward this one.        [ on ]

Changeable at any time. **A student who chose "start fresh" in November and regrets it in
January flips one switch.**

**"The scoreboard, not the schedule":**

| Surface | Respects the choice |
|---|---|
| Progress figures and tables | yes |
| Home stats band | yes |
| Weakest areas | yes |
| Today's session, and every due date | **no** |
| The flagged list | no, flags are question-level and not exam-scoped |

**If "start fresh" reset FSRS, the app would re-ask 412 questions the student demonstrably
knows.** Nobody wants that, including the person who just tapped it. They asked for clean
numbers, not for the work again.

**This produces one coherent but surprising state**, and it is why the prompt states the rule
rather than letting it be discovered: with "start fresh" on, **Progress can report 0 answered
while today's session serves questions that are not due for months.** That is correct. Do not
"fix" it.

**The filter is on the read, not on the data.** With carry-over on, an attempt counts when the
question it was on is in the current exam's pool, whatever `examId` the attempt carries. With
it off, only attempts whose own `examId` is the current exam count. **Both are reads over the
same rows**, which is what makes the switch instant and lossless.

- [ ] **Step 1: Write the failing test**

```dart
  test('with carry over on, another exam\'s attempt counts', () async {
    // An attempt filed under DOST, on a question also in UPCAT.
    expect(counted, 1);
  });

  test('with carry over off, only this exam\'s attempts count', () async {
    expect(counted, 0);
  });

  test('a question outside this exam never counts, either way', () async {
    // Both settings, expect 0.
  });

  test('scheduling ignores the setting entirely', () async {
    // Carry over off. Expect the due question still to be due.
  });

  test('the flagged list ignores it too', () async { ... });
```

- [ ] **Step 2 to 4: Run it, thread the filter through the figure providers, run it again**

Find them with `grep -rn "attemptsRepositoryProvider" --include="*.dart" lib/features`.
**Change the reads that produce figures. Do not touch `FsrsDueSelector`, the today providers,
the picker or the flag providers.**

Add the Settings row with `IosSwitch`, which `settings_home_page.dart` already uses.

- [ ] **Step 5: Run the whole suite, then commit**

```bash
flutter test
dart run tool/check_layering.dart
dart format lib test
flutter analyze
git add lib test
git commit -m "feat(progress): figures follow the carry-over choice

The choice governs the scoreboard and never the schedule. Resetting FSRS
would re-ask questions the student demonstrably knows, which is not what
anyone means by clean numbers."
```

---

## What this plan deliberately does not do

- **Studying two exams at once.** Deferred in the spec with reasons: it collides with Home's
  single countdown, Progress's single exam, the session's single topic queue and the custom
  track's single track. Aedwon chose one at a time deliberately, for focus and mock fidelity.
- **Merging two assessments.** Only meaningful if two exams are live at once.
- **Migrating anything.** There is nothing to migrate. `review_state_local` has no exam column
  and `examIdsJson` is already a list.
- **A control on the Progress tab.** The switch lives in Settings; the tab gains nothing.

## Verification

```bash
flutter analyze
dart format --set-exit-if-changed lib test
dart run tool/check_layering.dart                # still 7, not 8
flutter test
```

By hand, on a device, from the spec's own list:

- Switching exams deletes nothing, verified by switching back and finding the old assessment
  intact.
- Switching does not make a mock available to a Free user inside 14 days.
- With carry-over off, Progress reports zero while today's session still respects existing due
  dates.
- An attempt on a question not listing the new exam in `examIdsJson` is never counted, under
  either setting.
- The word "migrate" appears in no user-facing string.
- After switching, the new exam has no assessment and the Quiz tab's session panel shows its
  "no assessment taken" state. **This is right and needs no special case**: the student is
  being asked where they stand on the new exam's material, which is a different question.

## Self-review notes

Checked against every section of the spec:

- One exam at a time, switching as replacement: falls out of `selected_exam_id` being single.
- Nothing deleted: enforced by there being no delete in this plan.
- The cooldown per student rather than per track: Task 2, and it is the one live exploit here.
- Carryable defined by `examIdsJson`, no new storage: Task 1.
- The prompt's copy, its default, its skip case, and "migrate" banned: Task 3.
- The Settings row and the scoreboard/schedule split: Task 4.
- The assessment after a switch, deliberately untouched: named in Verification.
