# Content 04: the mock panel, and a paper a student can sit

**Plan, 11 August 2026.** Stages 4 and 5 of
`specs/2026-08-11-content-path-and-the-mock.md`.

> **Required reading before Task 1:** `AGENTS.md`, Sections 4.4 and 5 of the
> spec, `specs/2026-07-28-mock-exam-ui-design.md` in full, and
> `lib/features/mock_exam/presentation/widgets/mock_panel.dart` including its
> class doc comment.

**Content 01, 02 and 03 must be merged first.** This is the stage that opens
the door, and the room has to be furnished before it does.

---

## Two doors, and both are missing a hinge

**Found 11 August, after this plan was written.** There is a second route to a
mock and it is in the same state as the first.

**The published route:** `MockPanel` to `/quiz/mock/setup`, which reads a
`mockBlueprint` from the content database. **No blueprint exists** until
Content 03 authors one.

**The custom route:** `/quiz/mock/custom-setup` lets a student compose their
own paper by subject, and `CustomBlueprintRepository.save` writes it to the
**app** database, not the content one. **So a custom mock needs no published
blueprint at all.**

**But nothing reads it back.** `CustomBlueprintRepository.read` and `.exists`
have no callers anywhere in `lib/`, and `mock_setup_page.dart` reads published
blueprints only. **A student could compose a paper and nothing would use it**,
and nothing navigates to `/quiz/mock/custom-setup` either.

**Both routes therefore need finishing**, and this plan gains Task 1b for the
custom one. It is the cheaper of the two to make real, because its data does
not wait on anyone.

---

## Task 1b: the custom paper is read back and can be sat

**Files:**
- Modify: `lib/features/mock_exam/presentation/pages/mock_setup_page.dart`
- Modify: whatever offers the route, per Task 1
- Test: `test/features/mock_exam/custom_blueprint_roundtrip_test.dart`

**A saved custom blueprint is read and sampled.** Compose, save, start, and
the paper drawn matches the composition: the subjects chosen, the counts
chosen, and nothing from a subject that was not.

**A student who has saved one is offered it.** The panel says a custom paper
exists and offers to sit it, rather than sending them through setup again.

**Never invent a duration.** A custom paper has no published timing, so it
either carries the time the student chose or it is untimed and says so. **It
must not borrow another exam's minutes.**

---

## The one thing to understand before you start

**`MockPanel` already documents the contract.** Its comment reads: "Built here
rather than in `features/quiz` because it reads `MockAvailability` and
`MockAttempt`. The Quiz tab receives it as a plain `Widget` from the router, so
no feature imports another."

**That contract was designed and never honoured.** `QuizTabHome` takes a
`mockPanel` parameter; `router.dart` builds `const QuizTabHome()`. **Your job is
to fill it, not to redesign it.** Passing the panel from the router is also what
keeps the layering rule satisfied: Quiz must not import mock_exam.

---

## Global constraints

- **Never run `flutter test` with no arguments, `flutter analyze`, or
  `dart run build_runner`.** You may run a single test file. **The full gate
  set is run for you after you finish.** Never use `&`, `nohup`, or any
  background mechanism.
- **Work only inside your worktree.** Run `pwd` before your first write.
- **Commit the moment a task's own test passes.**
- **No em dashes.** American spelling.
- **`dart run tool/check_layering.dart` must exit 0.** A feature may import
  another feature's domain, application or data layer and never its
  `presentation/`. Wiring this through the router is how that stays true.

### Gate command

```bash
flutter test test/features/mock_exam/ test/features/quiz/ && dart run tool/check_layering.dart
```

---

## Task 1: The router supplies the panel

**Files:**
- Modify: `lib/app/router.dart`
- Test: `test/app/router_mock_panel_test.dart`

The Quiz branch builds `QuizTabHome(mockPanel: ...)`, where the panel is a
small consumer that watches `mockAvailabilityProvider` and the last attempt,
and hands `MockPanel` what it needs.

**`onTake` pushes `/quiz/mock/setup` and `onResume` resumes the in-progress
attempt.** Both routes exist.

**Test that the Quiz tab renders the panel**, and that `check_layering` still
exits 0.

---

## Task 2: Unavailable states are honest

**Files:**
- Test: `test/features/mock_exam/mock_panel_states_test.dart`

`MockAvailability` already models in-progress, available and cooldown, and Free
carries a 14 day cooldown while Pro does not. **Add the state this stage can
still produce: no blueprint for this exam.**

**It must say so plainly rather than showing a dead button.** A student on an
exam with no blueprint, which is five of the seven today, sees the panel state
that the paper is not ready, and no call to action.

**Never invent a figure in that state.** No item count, no duration, no "coming
soon" date.

---

## Task 3: Sit the paper

**Files:**
- Test: `test/features/mock_exam/upcat_end_to_end_test.dart`

Build a mock from the UPCAT blueprint and drive it: start, answer through the
first part, let the part's clock expire, confirm the paper moves on and the
finished part cannot be re-entered.

**The clock is per part, 70, 35, 75 and 50 minutes.** Use an injected clock.

**Assert the paper is 250 questions across four parts**, and that no question
comes from a Reasoning topic.

---

## Task 4: The results reach Progress

**Files:**
- Test: `test/features/progress/mock_feeds_progress_test.dart`

Submit a completed mock and assert the Progress tab's Time column appears,
which it cannot today: `timeIsMeasurable` is false until a timed mock exists,
and the section prints a line saying so.

**That line disappears when the first mock lands.** Test both sides.

---

## Task 5: On the device

**Not a test. Aedwon does this.**

Report to him, text only, per `AGENTS.md`:

- the panel is on the Quiz tab, with the paper's shape
- the setup screen states 4 parts, 250 questions, 3 hours 50 minutes
- a part ends and cannot be re-entered
- Progress shows the Time column afterwards

**Never screenshot the emulator.** Ask him to look, and record what he says in
`docs/ui-audit.md`.

---

## Done when

- A student can open Quiz, see the mock, sit a full UPCAT paper part by part,
  and find the result in Progress.
- Exams without a blueprint say so instead of offering a button.
- `check_layering` exits 0 and the gate command passes.
