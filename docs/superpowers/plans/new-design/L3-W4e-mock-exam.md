# L3 W4e: mock exam (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4e-mock-exam.md`. Base: integration branch after W2, W3 and W4h's pattern task.
Executor: Sonnet worker, own worktree (Opus for Task 6, the finale, if a Sonnet worker stops twice).
Landing order: Task 1 (`MockCard`) before W4d's Quiz tab task. Closes N5-2 (decoding old results).

Before each screen task: open its boards and run `timeline.py`. Every task: widget tests first per
drawn state (light, dark, 200% text, reduce motion last frame), unit tests per rule, then code, task
checks (`flutter test test/features/mock_exam test/app`), commit. W1 theme API, W2 components.

## Task 1. Mock card (lands first)

`MockCardModel` and `MockCard` in `lib/features/mock_exam/presentation/widgets/mock_card.dart`,
replacing `MockPanel`. Boards QZ_Tab, QZ_Free, QZ_Resume, QZ_First (card part); D-157. States: never
taken, Free waiting ("Your next one opens Fri, Oct 10." with View Last Results), Pro, in progress with
Resume, paused-quiz block, custom track ("Set one up", "Change the setup"). Free limit from W3
`mockLimit(examId)` (replaces the 14-day constant in `mock_availability_provider.dart`).

## Task 2. Data and scoring

Fill W0's JSON fields: `SectionResult.wrong` and `blank` in `compute_results.dart` and
`submit_mock.dart`; mock answer `missReason`, `blankReason`, `reasonNote` written by the review.
Per-exam scoring rule: UPCAT right minus a quarter per wrong, blanks zero (D-193), others right over
total; the score is computed from the stored counts, never stored as a rounded decimal; retired
questions leave the total (G-e-13). Fix the percent defect (fraction in `mock_results_route.dart`,
0 to 100 in `compute_results.dart`): one representation, 0 to 100, with a test. N5-2: the results
decoder reads old rows with `wrong` and `blank` missing by recomputing them from `answersJson`.
Questions avoid the student's last two finished mocks for the exam (pass their ids to the sampler,
S0-28). Tests for each rule.

## Task 3. Setup

Boards MK_Setup, MK_SetupStrict, MK_SetupDCAT, MK_SetupCSE, L_MockStart (setting out the paper); D-186, D-198. Table with total row, how
it runs, what is left out; strict switch on this screen applies to this mock only (default from
Settings, S0-38); short-paper line when the bank cannot fill a part (S0-29); "Start the Mock Exam"
with "The clock starts when you tap.". Blueprints: author `content/mock/cse_pro.yaml`,
`cse_sub.yaml` and `acet.yaml` with W0's placeholder marker on CSE per-subject item counts and the
ACET aptitude time (R-20), shown through W2 `PlaceholderFigure`; tell the content track first.
These content files need the signed package rebuilt before release: the release package is rebuilt
once after the last content change, before W5 (W0 Task 6 procedure, Aedwon's authorization).

## Task 4. The paper

Boards MK_Paper, MK_FiveMin, MK_LastMinute, MK_Proctor, MK_LastQ, MK_EndEarly, MK_Sheet, MK_SheetCSE,
MK_SubmitCSE, MK_BetweenA, MK_PartEnded; D-187 to D-189, D-195. Centered clock with hours, thick bar
amber under 5 minutes, red in the last minute; pause on the right (gone in strict); part named above
the question; floating bar with centered counter; proctor calls at 10, 5, 1; End Part on the last
question; between-parts screen with the clock stopped (wire `PartTransitionPage`'s replacement);
one-block exams submit from the sheet. Close with a declared route, not `context.go('/')`.

## Task 5. Pause, strict mode, leaving, recovery

Boards MK_PauseWarn, MK_PauseA, MK_PauseFlow, MK_Discard, MK_Forfeit; D-190, D-191; S0-37. Pause
warning with "Don't show this again" stored in app preferences (`mock_pause_warning_seen`);
hourglass; discard deletes answers and does not use up a mock. Strict grace 10 seconds (change
`strict_mode_lifecycle.dart` from 5), then Not finished with everything answered scored. Strict off:
leaving the app pauses; system back acts like pause (strict off) or is blocked with a line (strict
on). Reopening resumes with the clock having run; time run out while closed goes to results; a broken
saved mock offers Discard.

## Task 6. Finale and results

Boards MK_Finale, MK_FinaleUPCAT, MK_Results, MK_ResultsFree, MK_PastFreeOpen, MK_PastFreeLocked,
MK_PastPro, MK_Forfeit; D-192 to D-194, D-197, S0-2. The end animation as one sequence (keep order
and overlaps; if any part cannot be built as drawn, stop and ask); W2 `HalfRingGauge` with the
two-ball UPCAT variant; PERFORMANCE BREAKDOWN bars; VERSUS PAST RESULTS only with earlier mocks; See
all questions (Pro, and Free until the next mock opens; then score and breakdown only with "Go
through all N questions again with Pro."); after a Pro lapse the Free rule applies (Aedwon, Oct 6);
no pill, confetti or comparison sentence; Done returns where results were opened. Remove the "Reopens
in 7 days." footer.

## Task 7. All questions after a mock

Boards MK_ReviewWrong, MK_ReviewAll, MK_ReviewFlagged, MK_ReviewQ, MK_ReviewQNote, MK_ReviewQFree,
MK_ReviewBlank, MK_ReviewWrongFree; D-196, D-197. Tabs All, Wrong, Flagged (Wrong first), rows by
part, viewer moving through the tab, notes (Pro) writing `missReason` and `reasonNote`, blank reasons
writing `blankReason`, save-flags offer on the Flagged tab only; flags never gated.

## Task 8. Custom-track mock setup

Boards CM_Setup, CM_Wheel, CM_Breakdown, CM_Ceiling; D-243; S0-39. Questions and Time open in place
(W2 `ValueWheel`, no sheets); section breakdown; ceiling in red with Tick More Subjects; reopening a
saved setup shows its saved values; the track name replaces the exam name.

## Task 9. Delete and check

Delete `MockPanel`, the value wheel sheets, the mock questions sheet (replaced by W2
`QuestionGridSheet` mock mode), `mock_floating_bar.dart` (replaced by W2 `FloatingBar`), the unwired
history page, the `/mock-exam` stub screen, and their tests. All required checks; evidence
`evidence/W4e.md`; independent review; Aedwon's visual check against the MK_* and CM_* boards.
