# L2 W4d: Quiz

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2, W3 (notes gate).
Traceability: 94 rows with workstream `W4d` (46 boards, 48 other items).

## 1. Purpose and scope

Rebuild the Quiz tab, Customize your own with How long?, the one set of quiz screens with the
floating bar, the questions sheet, the end of a session, the question viewer with notes (Pro), and
Report a question; add the Flagged questions list.

Out of scope: Mock exam screens and the mock card's content (W4e; this family places W4e's `MockCard`); Home Today data (W4b supplies the same Today rows).

## 2. Inputs

Boards (46): QZ_Tab, QZ_Free, QZ_Resume, QZ_Done, QZ_First, QZ_Picker, QZS_1, QZS_1b, QZS_1c, QZS_1d, QZE_Many, QZE_ManyTime, QZE_Short, QZE_RunsShort, QZE_Long, QZE_One, QZE_None, QV_Answer, QV_MissPro, QV_MissFree, QV_Last, QV_Long, QV_Figure, QV_Flag, QV_Grid, QV_GridBack, QV_GridMock, QV_Leave, QV_EndPro, QV_EndFree, QV_EndPerfectB, QV_EndLowB, QV_EndLastToday, QV_All, QV_Sources, QN_Wrong, QN_WrongOpen, QN_Correct, QN_WrongFree, QN_EditNote, QN_OwnWords, QN_Report, QN_ReportOffline, QN_ReportAgain, QN_ReportLimit, L_DebriefSlow.

Other traceability rows (48): D-156, D-157, D-158, D-159, D-161, D-162, D-163, D-164, D-165, D-166, D-169, D-171, D-172, D-173, D-174, D-175, D-177, D-178, D-179, D-180, D-182, D-183, D-235, D-242, D-276, S0-5, S0-14, S0-15, S0-16, S0-17, S0-19, S0-43b, G-b-29, G-d-1, G-d-4, G-d-7, G-d-8, G-d-9, G-d-10, G-d-12, G-d-13, G-d-14, G-h-10, G-h-11, G-h-23, G-h-24, G-h-29, G-h-30.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior. Superseded sections of older specs for this family: amendment
spec B1 (rows naming this family's screens); those sections are not built.

## 3. Contracts

Owned. Routes live in this family's route file  (W1 creates it);
W1 removes retired routes and this family deletes the screens behind them:
- `/quiz` root (W1); rebuild `/quiz/flagged/:examId` (exists; new list design) and keep `/quiz/today/:examId`, `/quiz/resume/:examId`,
  `/quiz/practice/:examId` (picker) and `/quiz/practice/:examId/run`, `/quiz/retake/:examId`,
  `/quiz/inline/:examId/:lessonId`, `/quiz/quick/:examId`, `/quiz/debrief/:attemptId`; new
  `/quiz/viewer/:attemptId`.
- Retired: `/quiz/results/:attemptId` and `/review`, both served by `QuizResultsPage` in
  `lib/features/quiz/` (replaced by See all questions and the viewer); the empty
  `lib/features/review/` folder is deleted.
- `startLessonQuiz(lessonId)` (lesson-scoped set keyed on the W0 lesson id; replaces the topic-scoped
  picker) and `startQuickQuiz()`, consumed by W4c.
- Report queue (offline send later, limits 3 per question and 20 a day).

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W3 `coversExam` for notes; W0 JSON fields `AttemptItem.mistakeTag` (`other`) and `AttemptItem.mistakeNote`, and response time writes; W4e `MockCard`.

## 4. Behavior

- Quiz tab per D-156 to D-159: Today rows, mock card (W4e owns its content), More ways to practice,
  paused, all done, before the assessment states.
- Customize your own per D-160 to D-166: every lesson counts the same; How long? with two modes;
  struck-out times; picker remembers last picks; mixed questions; skips questions answered in the
  last 7 days; time estimate starts at about 50 seconds and learns; a lesson with no questions shows
  "No questions yet" dimmed (G-d-13).
- Quiz screens per D-169 to D-182: pick then Check, colors not words, Flag with the first-time toast
  and a short "Flag removed" toast (G-d-10), questions sheet rules, Leave asks once (system back
  too, G-d-14), session end with mistakes and See all questions, Start Session 2 or Done, "Session"
  never "Sitting".
- Viewer and notes per D-179, D-183 and D-276: Pro only (Free gets no note icon, counter centered);
  reason stored as one nullable column plus optional text (W0 contract).
- Report per D-180 and D-183.
- Flagged questions list (S0-5): built like the mock's All questions list (MK_ReviewAll rows), grouped
  by subject, opens the viewer, Practice these, empty state per the shared pattern.
- Store rating prompt (S0-19): asked once, after a session with 80% or more right, never within 24
  hours after the Settings Pro page was opened; the phone's own dialog.
- The 5-line refresh after a custom assessment (S0-43b, from the archive branch).
- Discarded: miss cause lines, return promise, explainer, study-first sheet (S0-14, S0-15, S0-17).
- Passage questions keep their passage card (S0-41).
- Quick quiz (S0-16): reached only from Study's "Try a Quick Quiz".
- Free and Pro: notes are Pro (W3 `coversExam`); everything else the same (D-232). Placeholders: none.

## 5. Motion

Boards QV_Answer, QV_Flag, QV_Grid, QV_GridBack, QV_EndPro, QN_Wrong, QN_EditNote, QN_Report, QZS_1, QZS_1b, QZS_1c animate.
Run `python3 docs/design/tools/timeline.py docs/design/boards/<Board>.html` for every animated board
and build from the tap, start to last change; reduce motion shows the last frame.

## 6. Acceptance

- Every board listed below matches 1:1 at rest, in each drawn state, in light mode; dark mode uses
  W1 tokens. Motion matches `docs/design/tools/timeline.py` output for each animated board.
- Widget tests for each screen state listed in section 4, including reduce motion (last frame) and
  large text without overflow; unit tests for every rule in section 4.
- Old screens, routes and widgets this family replaces are deleted; no dead route remains.
- Full required checks on the integrated family (SUBAGENTS Part 5).
- Aedwon: visual check on his phones against the boards (Android, and iPhone per S0-49).

## 7. Risks and stop conditions

- A board contradicts this plan, the amendment spec or the decision record: stop; the lead decides
  and records it before code changes (README: "ask instead of guessing").
- A figure with no measured or published source: stop (AGENTS.md), except the recorded placeholders.
- A needed shared component or contract is missing from W1, W2 or W3: stop; do not build a local copy.
- A schema change is needed: stop; W0 owns the data layer and needs an amendment first.
- A board conflicts with the README or DECISIONS.md, or a needed string has no board: stop and ask
  the lead (README "ask instead of guessing").
- Report storage and sending need a backend path; if none exists on the branch, the level 3 plan adds the client queue and stops before any new deployed function until Aedwon approves the deploy.

## 8. Files and directories

`lib/features/quiz/`, `lib/features/review/` (empty; deleted), `lib/features/review_prompt/`, `lib/app/routes/quiz_routes.dart`, tests.

## 9. Order and parallelism

After W2 and W3. Shares the floating bar and grid with W4e through W2; no shared files with W4e (each edits only its own route file). Landing order: this family's `startLessonQuiz` and `startQuickQuiz` task before W4c wires its buttons; W4e's `MockCard` task before this family's Quiz tab task; W4h's pattern task before this family's state screens.
