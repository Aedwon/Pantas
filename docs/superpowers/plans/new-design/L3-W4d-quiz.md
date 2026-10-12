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
