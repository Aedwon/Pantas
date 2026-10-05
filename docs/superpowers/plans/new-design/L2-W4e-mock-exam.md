# L2 W4e: Mock exam

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2, W3 (`coversExam`, mock limit).
Traceability: 98 rows with workstream `W4e` (41 boards, 57 other items).

## 1. Purpose and scope

Rebuild the mock exam from setup to review: setup table with the strict switch, the paper with the
clock, time bar and floating bar, parts and the between-parts screen, pause with the hourglass,
strict mode, the end animation and score, performance breakdown, versus past results, All questions
with notes and blank reasons, the Free and Pro rules after a mock, other exams, and the custom-track
mock setup.

Out of scope: The Quiz tab layout around the mock card (W4d places it; this family owns its content).

## 2. Inputs

Boards (41): MK_Setup, MK_SetupStrict, MK_Paper, MK_Proctor, MK_FiveMin, MK_LastMinute, MK_Sheet, MK_LastQ, MK_LastQStrict, MK_EndEarly, MK_BetweenA, MK_PauseA, MK_Discard, MK_PartEnded, MK_Forfeit, MK_PauseWarn, MK_PauseFlow, MK_Results, MK_Finale, MK_FinaleUPCAT, MK_ReviewWrong, MK_ReviewAll, MK_ReviewFlagged, MK_ReviewQ, MK_ReviewQNote, MK_ReviewBlank, MK_SetupDCAT, MK_SetupCSE, MK_SheetCSE, MK_SubmitCSE, MK_ReviewWrongFree, MK_ReviewQFree, MK_ResultsFree, MK_PastFreeOpen, MK_PastFreeLocked, MK_PastPro, L_MockStart, CM_Setup, CM_Wheel, CM_Breakdown, CM_Ceiling.

Other traceability rows (57): D-19, D-20, D-21, D-22, D-23, D-186, D-187, D-188, D-189, D-190, D-191, D-192, D-193, D-194, D-195, D-196, D-197, D-198, D-199, D-233, D-234, D-243, D-258, D-261, D-275, R-12, R-20, A-B3b, S0-2, S0-26, S0-27, S0-28, S0-29, S0-37, S0-38, S0-39, G-e-1, G-e-2, G-e-3, G-e-4, G-e-5, G-e-7, G-e-8, G-e-9, G-e-10, G-e-11, G-e-12, G-e-13, G-e-15, G-e-16, G-e-17, G-e-18, G-e-19, G-e-20, G-e-21, G-h-18, G-h-19.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior. Superseded sections of older specs for this family: amendment
spec B1 (rows naming this family's screens); those sections are not built.

## 3. Contracts

Owned. Routes live in this family's route file  (W1 creates it);
W1 removes retired routes and this family deletes the screens behind them:
- Keep `/quiz/mock/setup`, `/quiz/mock/start`, `/quiz/mock/resume/:attemptId`,
  `/quiz/mock/custom-setup`, `/mock/results/:attemptId`, `/mock/review/:attemptId`. Retired:
  `/mock-exam` placeholder, the unwired mock history page.
- Per-exam scoring rule. Scores are derived from stored right, wrong and blank counts per part (UPCAT
  deductions can be decimals; `scoreRaw` stays an integer count, no migration).
- `MockCardModel` and `MockCard` widget for the Quiz tab, placed by W4d.
- The CSE Professional, CSE Subprofessional and ACET blueprints in `content/mock/`, with the
  placeholder marker (W0 contract): CSE per-subject item counts and ACET aptitude time (R-20).

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W3 `coversExam` and `mockLimit`; W0 JSON fields `SectionResult.wrong`, `SectionResult.blank`, mock answer `missReason`, `blankReason`, `reasonNote`; W0 mock blueprint format.

## 4. Behavior

- Setup per D-186 and D-198: table with total row, how it runs, what is left out; strict switch
  applies to this mock only (S0-38); short-paper line under the table (S0-29); placeholders for CSE
  item counts and ACET time marked per R-20.
- Paper per D-187 to D-191: centered clock with hours, amber under 5 minutes, red in the last minute;
  proctor calls at 10, 5, 1; End Part on the last question; between-parts screen; pause with
  "Don't show this again" remembered on the phone; discard; strict 10-second grace then Not finished;
  system back acts like pause (strict off) or is blocked with a line (strict on); reopening resumes
  with the clock having run; time run out while closed goes to results; a broken saved mock offers
  Discard (S0-37).
- Scoring per D-193 and D-195: each exam's own rule (UPCAT right minus a quarter per wrong, blanks
  zero); store right, wrong, blank per part; retired questions leave the total (G-e-13); one-block
  exams submit from the sheet.
- Results per D-192, D-194, D-18 to D-22 as corrected by S0-2: no pill, no confetti, no comparison
  sentence; versus past results only with earlier mocks; Done returns where results were opened.
- After a mock per D-196, D-197, D-234 and R-12: both tiers see every question with answer and
  explanation; Free keeps them until the next mock opens, then score and breakdown only; Pro any
  time; notes and blank reasons Pro only; flags never gated.
- Questions avoid the student's last two mocks (S0-28). Mock answers feed reviews (D-258).
- Custom-track mock per D-243 and S0-39 (card states, saved values reopen).
- Free limit via W3 `mockLimit`; the card says when the next opens.
- After Pro lapses: the Free rule applies, nothing is deleted, renewing restores access (Aedwon,
  Oct 6, gate F-18).
- Discarded: Next blank and Next flagged, Strict badge (S0-26, S0-27).

## 5. Motion

Boards MK_Paper, MK_FiveMin, MK_LastMinute, MK_Proctor, MK_PauseFlow, MK_BetweenA, MK_Finale, MK_FinaleUPCAT, MK_Results and the review boards animate. The finale is one sequence; keep its order and overlaps exactly (MOTION rule 3).
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
- The finale is the most complex animation in the app; if any part cannot be built as drawn, stop and ask (MOTION rule 6).
- Placeholder figures must be listed in the level 3 plan and carry `PlaceholderFigure` (W2).

## 8. Files and directories

`lib/features/mock_exam/`, `lib/app/routes/mock_routes.dart`, `content/mock/` (CSE Professional, CSE Subprofessional, ACET blueprints only), tests.

## 9. Order and parallelism

After W2 and W3. Parallel with other families. Landing order: this family's `MockCard` task before W4d's Quiz tab task; W4h's pattern task before this family's state screens. The CSE and ACET blueprints are content files: the content track is told before they land (strategy B2).
