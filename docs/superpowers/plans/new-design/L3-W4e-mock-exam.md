# L3 W4e: mock exam (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4e-mock-exam.md`. Base: integration branch after W2, W3 and W4h's pattern task.
Executor: one worker, own worktree (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews); if the worker stops twice on Task 6 (the finale), the
lead re-plans it.
Landing order: Task 1 (`MockCard`) before W4d's Quiz tab task. Closes N5-2 (decoding old results).

Before each screen task: open its boards and run `timeline.py`. Every task: widget tests first per
drawn state (light, dark, 200% text, reduce motion last frame), unit tests per rule, then code, task
checks (`flutter test test/features/mock_exam test/app`), commit. W1 theme API, W2 components.

Pro gates read W3's `proForActiveExamProvider` (Pro for the active exam), never `proIsActive` (level 3 gate review 2).

While W3's entitlement state is `paused`, each Pro gate shows W2's `ProPausedLine` instead of the Pro
invitation, with a widget test (amended Oct 6, abuse review 1).

Contrast (W1 audit 1, Oct 10): this family's rebuilt screens test the last-minute timer against its real background at 4.5:1 or better in light and dark; if a board's color fails, stop and ask the lead.

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
0 to 100 in `compute_results.dart`): one representation, 0 to 100, with a test. N5-2: the encoder is
`submit_mock.dart` `_sectionResultsJson` (writes `wrong` and `blank`); the one decoder is the section
parse in `mock_results_route.dart`, which recomputes null `wrong` and `blank` from `answersJson` for
old rows. The metrics reader (`lib/features/metrics/signals/mock_payload_reader.dart`) is unchanged;
a test shows it ignores the new keys (run `flutter test test/features/metrics` with this task).
Questions avoid the student's last two finished mocks for the exam (pass their ids to the sampler,
S0-28). Tests for each rule.

## Task 3. Setup

Boards MK_Setup, MK_SetupStrict, MK_SetupDCAT, MK_SetupCSE, L_MockStart (setting out the paper); D-186, D-198. Table with total row, how
it runs, what is left out; strict switch on this screen applies to this mock only (default from
Settings, S0-38); short-paper line when the bank cannot fill a part (S0-29); "Start the Mock Exam"
with "The clock starts when you tap.". Blueprints: author `content/mock/cse_pro.yaml`,
`cse_sub.yaml` and `acet.yaml` with W0's placeholder marker (first make the app's blueprint
readers accept the marker, `BlueprintValue.fromJson`, with a test; they read plain integers today;
W0 audit, Oct 6) on CSE per-subject item counts and the
ACET aptitude time (R-20), shown through W2 `PlaceholderFigure`; tell the content track first.
These content files need the signed package rebuilt before release: the release package is built once
after the last content change, in W5 Task 1, before the other W5 checks (W0 Task 6 procedure, Aedwon's authorization).

## Task 4. The paper

Boards MK_Paper, MK_FiveMin, MK_LastMinute, MK_Proctor, MK_LastQ, MK_EndEarly, MK_Sheet, MK_SheetCSE,
MK_SubmitCSE, MK_BetweenA, MK_PartEnded; D-187 to D-189, D-195. Centered clock with hours, thick bar
amber under 5 minutes, red in the last minute; pause on the right (gone in strict); part named above
the question; floating bar with centered counter; proctor calls at 10, 5, 1; End Part on the last
question; between-parts screen with the clock stopped (wire `PartTransitionPage`'s replacement);
one-block exams submit from the sheet. Close with a declared route, not `context.go('/')`.

## Task 5. Pause, strict mode, leaving, recovery

Boards MK_PauseWarn, MK_PauseA, MK_PauseFlow, MK_Discard, MK_Forfeit, MK_LastQStrict (strict on:
no pause, › dimmed with a quiet line saying why); D-190, D-191; S0-37. Pause
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
no pill, confetti, comparison sentence or Strict badge (S0-27); Done returns where results were opened. Remove the "Reopens
in 7 days." footer.

## Task 7. All questions after a mock

Boards MK_ReviewWrong, MK_ReviewAll, MK_ReviewFlagged, MK_ReviewQ, MK_ReviewQNote, MK_ReviewQFree,
MK_ReviewBlank, MK_ReviewWrongFree; D-196, D-197. Tabs All, Wrong, Flagged (Wrong first), rows by
part, viewer moving through the tab, notes (Pro) writing `missReason` and `reasonNote`, blank reasons
writing `blankReason`, save-flags offer on the Flagged tab only; flags never gated.

## Task 8. Custom-track mock setup

Boards CM_Setup, CM_Wheel, CM_Breakdown, CM_Ceiling; D-243; S0-39. Questions and Time open in place
(W2 `ValueWheel`, no sheets); section breakdown; ceiling in red with Tick More Subjects; unset subject rows
block Save with a line (G-e-20); reopening a
saved setup shows its saved values; the track name replaces the exam name.

## Task 9. Delete and check

Delete `MockPanel`, the value wheel sheets, the mock questions sheet (replaced by W2
`QuestionGridSheet` mock mode), `mock_floating_bar.dart` (replaced by W2 `FloatingBar`), the unwired
history page, the `/mock-exam` stub screen, and their tests. All required checks; evidence
`evidence/W4e.md`; independent review; Aedwon's visual check against the MK_* and CM_* boards.


## Lead Tasks4–6 ownership and shared contract clarification, October16

Task3 remains separately owned and unverified. Its fifteen saved draft paths are snapshotted
by SHA256 before Tasks4–6 work. The lead inspected the full mock_start_route.dart Task3 diff: it
adds strictMode input, prepared blueprint/sample/parts, delayed explicit start and preparation
view. Those exact additions and setup behavior must be preserved, never absorbed into a verified
Task4/5 commit or silently repaired. Tasks4/5 may edit only existing running-session lifecycle,
paper/grid/pause/part/exit wiring in that shared file. Keep an exact Task3 patch and exclude its
hunks when staging; verify the actual staged/committed Task4/5 candidate in isolation without
Task3 drafts before claiming verification. If the changes cannot remain independent, leave only
that integration pending and report the precise required Task3 contract. Other fourteen Task3
paths stay byte-for-byte unchanged. No Task3 takeover or completion claim is authorized.

The lead opened W2 new_design/QuestionGridSheet and CenteredDialog, plus MK_SheetCSE and
MK_SubmitCSE. Neither exposes the drawn one-block submit action. Authorize only these additive
shared extensions and focused tests before mock callers: an optional grid footer/action child
(default null), rendered in the existing sheet after its ordinary grid/help content, with drawn
spacing; an opt-in non-destructive inline action layout in CenteredDialog, with filled accent
primary/onAccent and fill/label cancel, existing inline pill geometry, and ordinary keyboard/
focus/large-text behavior. Preserve all quiz grid and dialog defaults and existing destructive
actions. Do not call a submit action destructive merely to obtain its layout, build a local
dialog/grid copy, or omit an implementable required submit action. W4e owns these two extensions
in its own worktree and saves them as a verified standalone slice. D's separately saved grid
changes must remain intact at eventual reviewed integration. No other W2 ownership is granted.

W4d currently owns an additive quiz-count HalfRingGauge extension in its separate worktree.
W4e must use existing percentage/overlay contracts while it inspects its finale, and report
any concrete additional gap before editing that shared file. No concurrent shared-gauge edits
or approximate animation substitution is authorized.
