# L3 W4d: Quiz (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4d-quiz.md`. Base: integration branch after W2, W3 and W4h's pattern task.
Executor: one worker, own worktree (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews). Landing order: Task 1 before W4c's quiz-button task; W4e's
`MockCard` before Task 2.

Before each screen task: open its boards and run `timeline.py`. Every task: widget tests first per
drawn state (light, dark, 200% text, W1 lesson text scale on question bodies), unit tests per rule,
then code, task checks (`flutter test test/features/quiz test/features/review_prompt test/app`),
commit. Screens move to W1's theme API and W2's components (`FloatingBar`, `QuestionGridSheet`,
`QuestionCard`, `ChoiceRow`, `AnswerReveal`, `CenteredDialog`, `Toast`, `ScopePicker`,
`ValueWheel`). Notes gate reads W3's `proForActiveExamProvider`.

Traceability fix (Oct 6): D-242 (assessment question screen) belongs to W4a, which builds the
assessment; the row moves there.

Regression tests for GitHub issues #23 (Quiz tab stays on the assessment gate), #24, #27 and #28
(Resume card offered, unambiguous and cleared after completion) are written first in Task 2.

While W3's entitlement state is `paused` (Pro paused offline, not a quiz left partway), each Pro gate shows W2's `ProPausedLine` instead of the Pro
invitation, with a widget test (amended Oct 6, abuse review 1).

Contrast (W1 audit 1, Oct 10): this family's rebuilt screens test wrong-answer text against its real background at 4.5:1 or better in light and dark; if a board's color fails, stop and ask the lead.

## Lead rulings, October 12

Read "Standing rulings for the W4 families" in `L3-parallel-map.md` first.
1. Order: Task 1 first, alone. Second commit, alone: the Task 7 report entry function (standing
   ruling 5), with the form if it does not depend on later tasks. Then the plan in order.
2. Task 2 and W4e's `MockCard`: the Quiz tab keeps a widget slot (today `mockPanel`), and
   `lib/app/routes/quiz_routes.dart` passes `MockCard` into it. The quiz feature does not import
   `mock_exam` presentation (layering rule R2). `MockCard` and its model are on the integration
   branch from 958ed879.

## Lead clarifications, October 13

1. Task 3, Adjust in Total time mode: preserve the selected time and its question budget.
   Redistribute the budget among selected lessons within real question availability; do not let
   a stepper silently change the time wheel. QZS_1c and QZS_1d both keep 30 minutes and roughly 33
   questions while redistributing 28+5 into 20+13. QZE_One shows Questions per lesson, not Total
   time, so it is not evidence for changing the Total time budget. With one selected lesson in
   Total time, redistribution has no alternate destination; the corresponding steppers stay
   bounded and the time wheel changes the budget. Keep the drawn Adjust control in Questions
   per lesson mode. Preserve the approved real-pool shortfall behavior and Reset to the even split.
2. Task 3, seven-day recency: retain the planned AttemptsRepository.questionOutcomes query,
   supplemented by the existing ReviewStateRepository.byQuestionIds and checked-answer lastReview
   timestamps for the selected pool (only states with a real completed review, reps > 0). A checked
   answer is stored before the attempt completes; a discarded partial session therefore may have
   no saved attempt. Include those real checked answers in recency filtering. Reuse the existing
   repository API and account-boundary behavior; no schema or synchronization change. Tests cover a
   checked partial session that was discarded, a fresh seed state, the seven-day boundary and the
   required pool top-up. This fills the existing approved rule, not a new spacing decision.

3. Task 3, Adjust in Questions per lesson mode: the wheel is the base per-lesson allocation.
   Explicit row steppers may override that row's real question count within its available pool;
   recompute total questions and derived time. Do not silently move the wheel. Reset removes the
   overrides and restores the even base allocation; explicitly changing the wheel also removes
   overrides and applies the newly selected base. This keeps QZE_One's drawn Adjust useful and
   follows D-164's question-driven mode, row steppers and Reset behavior. Tests cover single-lesson
   overrides, pool bounds, totals/time, Reset and a wheel change after a manual adjustment.

4. Task 3, switching sizing modes: D-166's current "nearest matching value" means the
   closest equivalent aggregate quiz size using current selected lessons, pool caps and valid
   measured pace. Do not carry the same numeric wheel value from questions per lesson into total
   minutes. The retained July rule belonged to per-selection minutes and cannot reinstate that
   superseded meaning. Evaluate eligible destination wheel values by their actual total-question
   result; choose the closest match, with deterministic ties. Clear manual overrides on an explicit
   mode change. The first nearest match may round; repeated toggles without another user change
   must settle rather than creep. Tests cover 10 per lesson across six lessons at50seconds
   matching50 total minutes, pool shortfalls, a quantized case and repeated toggles. With no selected
   lessons, there is no aggregate size to convert; use the existing nearest valid default.
5. Task 3, measured pace: a nonpositive stored average is unavailable for duration sizing.
   Use the approved initial50-second pace consistently in core calculation and UI until a positive
   measured average exists. Guard zero/negative values before division. Tests cover zero and
   negative inputs in both core and time wheel; do not display zero-duration derived estimates for
   a nonempty quiz or manufacture an unbounded question budget.

6. Task3, positive sub-minute duration: the nonpositive-pace fallback does not replace a
   valid positive measurement. If a nonempty question-driven quiz has a positive derived duration
   that rounds to zero minutes, display the bounded value "<1" with unit "minute" in the existing
   derived metric and "under 1 min" in its summary. Do not clamp or manufacture a full minute.
   Keep zero for an empty quiz and the selected budget for Total time. Cover a real positive
   sub-minute total and ordinary/empty estimates. This is duration formatting of the existing
   approved estimator, not a new pace, layout or data source.

7. Task3, repeated-mode conversion target: actual UI reproduction found shrinking quiz size
   with pools[24,2,13], valid measured70000ms, Questions13. Stateless nearest conversion gives
   wheel sequence45min→12questions→40min→11questions across four toggles, violating rule4.
   Preserve the real aggregate question count at the first sizing-mode switch as a transient
   conversion target across subsequent mode-only toggles. Evaluate destination values against
   that same target and current real pools/valid pace; deterministic lower-wheel ties remain.
   Clear this target after an actual selection, wheel, manual allocation or Reset change, and
   when material selected-pool availability or effective pace changes. Next switch captures the
   new actual aggregate count. Clear overrides on explicit mode changes as already required.
   Reuse existing screen state; no schema, new data source, persisted history or student figure.
   Regression covers the reproduced45/13/45/13 stable sequence and each target-invalidating change.
   This preserves the approved no-creep rule rather than accepting statistical shrinkage.

## Task 1. Start functions (lands first)

`startLessonQuiz(lessonId)`: replaces `StartInlineLessonQuiz`'s topic scope with the lesson's own
questions (W0 lesson id = question file subtopic), five questions. `startQuickQuiz()`: the existing
`StartQuickQuiz`, reached only from Study (S0-16). Both in `lib/features/quiz/application/quiz_starts.dart`.
Tests: lesson scope returns only that lesson's questions; fewer than five returns what exists.

## Task 2. Quiz tab

Boards QZ_Tab, QZ_Free, QZ_Resume, QZ_Done, QZ_First; D-156 to D-159. Today rows (Reviews, New
questions) with rings and sheets, Continue Reviews; W4e's `MockCard`; More ways to practice (Your
past mistakes with count, Customize your own, Flagged questions with count; empty states dimmed);
paused state blocks Customize your own and the mock; all done; before the assessment. Choose your
exam fallback (S0-32). Delete the study-first sheet and its storage (`_QuizNudgeSheet`,
`quizNudgeRepositoryProvider`, S0-17).

## Task 3. Customize your own and How long?

Boards QZ_Picker, QZS_1, QZS_1b, QZS_1c, QZS_1d, QZE_*; D-160 to D-166. W2 `ScopePicker` (every
lesson counts the same, "Unread" orange, "No questions yet" dimmed for topics and lessons, G-d-13),
floating bar with size and Start, How long? with Questions per lesson and Total time modes, struck-out
times, Adjust and Reset. Rules: mixed across lessons; skip questions answered in the last 7 days,
topping up with older ones before showing a smaller count (new selector over
`AttemptsRepository.questionOutcomes`); remember last picks and length (new prefs keys
`practice_last_picks.<examId>`, `practice_last_length.<examId>`); time estimate starts at 50 seconds a
question (Aedwon's approved default, D-166) and switches to the student's measured average once
`averageResponseMs` exists; a custom quiz left partway shows on the Quiz tab as paused.

## Task 4. Question screens

Boards QV_Answer, QV_Last, QV_Flag, QV_Grid, QV_GridBack, QV_Leave, QV_Long, QV_Figure, QV_MissPro, QV_MissFree, QV_GridMock (the
shared W2 sheet in mock mode, used by W4e Task 4; checked here); D-169 to
D-182. Pick then Check (split `QuizController.answer` into `pick` and `check`), colors not words,
explanation fades in, bar right or wrong color, Next and Finish; Flag in the bar, first-time toast
"Flagged. Find it in the Quiz tab." with Undo, and a short "Flag removed" toast (G-d-10); questions
sheet rules (read-only revisit with "Back to 4"); X and system back (`PopScope`) ask "Leave this
session?" once. Remove "back in X days" from the reveal (S0-14). Sessions split by the session
length setting with "Session 1 of 2" lines; wording "Session".

## Task 5. End of session

Boards QV_EndPro, QV_EndFree, QV_EndLowB, QV_EndPerfectB, QV_EndLastToday, QV_All, QV_Sources,
L_DebriefSlow (loading, only if slow); D-178. Half ring fill with popping circles, "in N minutes", YOUR MISTAKES (first three then See all),
See all questions, Pro invitation and Finish the Notes, Start Session 2 or Done; Done returns where
the session started (QV_Sources). Delete miss cause lines, return promise and the spaced-repetition
note (S0-14, S0-15). Store rating prompt after a session with 80% or more right (existing
`ReviewPromptController.maybeAsk`), with the 24-hour cool-off now recorded when the Settings Pro page
opens (`recordPaywallSeen` called from W4f's Pro page; W4f is told).

## Task 6. Viewer and notes

Boards QN_Correct, QN_Wrong, QN_WrongFree, QN_WrongOpen, QN_EditNote, QN_OwnWords; D-179, D-183,
D-276. Route `/quiz/viewer/:attemptId`. ‹ "1 of 10" ›, bar colored; Pro note icon opens "Why did you
miss it?" (I misread it, I knew it I just slipped, I didn't know it, Type my own); Add Note, Update,
Remove; writes W0's `AttemptItem.mistakeTag` (`other`) and `mistakeNote` through
`AttemptsRepository.tagItem` (extended for the note; run `flutter test test/core/storage` with
this task). Free: no icon, counter centered.

## Task 7. Report a question

Boards QN_Report, QN_ReportOffline, QN_ReportAgain, QN_ReportLimit; D-180, D-183. One-field form in
the bar, Send off until typing, thank-you line, teal icon after; limits 3 per question and 20 a day;
offline queue ("Saved. It sends when you're back online."). Client queue in
`lib/features/quiz/data/report_queue.dart` (local prefs). No backend exists: the queue holds reports
and the sender is a no-op until a function is approved (stop before any new deployed function;
report to the lead).

## Task 8. Flagged questions list

Boards: built like MK_ReviewAll rows (S0-5). Route `/quiz/flagged/:examId` rebuilt: grouped by
subject, row opens the viewer, Practice these starts a run through a declared route
(`/quiz/practice/:examId/run` with the flagged ids; the old push to the undeclared
`/quiz/session/:examId` is removed), empty state per W4h.

## Task 9. Delete and check

Delete `QuizResultsPage` and the `/review` and `/quiz/results` screens (routes already redirect via
W1), `lib/features/review/`, the old tab, panel, picker page, length wheel, debrief page and their
tests; stop importing retired components (`showInkSheet` at the questions sheet, `InkTableRow`,
`InkCheckbox`). All required checks; evidence `evidence/W4d.md`; independent review; Aedwon's visual
check against the QZ_*, QZS_*, QZE_*, QV_* and QN_* boards.
