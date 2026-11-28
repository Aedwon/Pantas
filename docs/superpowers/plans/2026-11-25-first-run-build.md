# First run build plan (E-179), Nov 25

UX design lead. Policy main 6824f933b (estimate 26ff1c2fc). Branch `ux/first-run-r1` from origin/main.
Complexity: balanced is followed (the approved board sets the scope; no new service, table, sync
collection, functions change or setting). Estimate: 10 h active, 2 days wall (velocity log E-179).

## Controlling sources

- Board: Claude Design canvas "First Run", https://claude.ai/artifact/D3JLTrRGiN8vjnfLrbhoMN,
  version 1795614653-2f1d (revision E-176). His approval, Nov 25 about 10:50 PM Manila: "okay lgtm!"
  (launch log, "guided first-run board approved").
- Spec: the rulings file `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, entries
  "first run guided taste board (E-165)" and "first-run board revision (E-176)", plus the handoff
  `docs/superpowers/handoffs/2026-11-25-ux-lead-guided-taste-board.md`. The assessment spec
  (`2026-05-11-assessment-flow-design.md`, "in-memory only, never persisted") is superseded on that
  point by his pick B.
- Rules: `design/system/patterns.md` (Button placement, Onboarding and multi-step setup, Offline,
  Loading, Confirm or undo, Dialogs), AGENTS.md voice rules, process rules 1, 2, 4, 7.
- Board-to-code map (lead scratchpad, one Sonnet reader): every frame's strings, sizes, motion and the
  matching widget. Workers get the frame files and the map with their brief.

## Frames built (1:1)

| Frame | Phone light | Phone dark | Wide light | Wide dark |
|---|---|---|---|---|
| 2 Try Pantas first | P02_Intro | P02D_Intro | W02_Intro | W02D_Intro |
| 3 One short lesson | P03_Lesson | P03D_Lesson | W03_Lesson | tokens (not drawn) |
| 4 Question, right | P04_QRight | P04D_QRight | W04_QRight | W04D_QRight |
| 5 Question, wrong | P05_QWrong | tokens | W05_QWrong | tokens |
| 6 You finished the lesson | P06_End, P06_EndRM | P06D_End | W06_End | W06D_End |
| 7 Home, take the assessment | P07_Home | P07D_Home | W07_Home | W07D_Home |
| 8b Leaving keeps your answers | C2B_Leave | tokens | C2B_LeaveWide | tokens |
| 8c Home offers Continue | C2B_Home | tokens | C2B_HomeWide | tokens |

Unchanged frames (1, 8, 9, 10: O_Days/OB_Days, AS_Question, AS_Results, HP_Day/HM_DayStart) stay as
built. "tokens" means the board draws no dark twin: the dark look comes from the same components'
dark tokens, as every other dark screen does.

## Files

New, `lib/features/first_run/`:
- `domain/first_run_content.dart`: per exam, the fixed lesson id and its 3 question ids (lead, task 0).
- `domain/first_run_progress.dart` + `data/first_run_store.dart`: the step and answers, so a reload
  resumes (device prefs, key scoped by account and exam).
- `presentation/first_run_page.dart`: one route, `/try`, holding the steps intro, lesson, question
  1 to 3, end. `presentation/widgets/`: intro list with previews, header ("Try Pantas" and Skip),
  question bar (phone arrows and count, wide count, track and Next), end body (no arc).

Changed:
- Router and routes: `lib/app/router.dart`, a route file for `/try` (above the web shell, like the
  lesson), `lib/app/start_location.dart` (a cold `/try` opens `/try`, which resumes).
- Onboarding: `lib/features/onboarding/presentation/onboarding_page.dart` `_finish` goes to `/try`
  instead of `/home` when the exam has a fixed lesson and no assessment result.
- Lesson reader: `lib/features/lesson/presentation/lesson_page.dart` and its content widget, only to
  let the first run render the lesson body with a section limit and its own top bar and end button.
- Quiz parts reused, not changed unless a parameter is needed: `QuestionCard`, `AnswerReveal`,
  `FloatingBar`, `SessionEndBody` (a no-arc variant), `CenteredDialog`.
- Assessment: `assessment_page.dart` (save on pick, resume), `AssessmentSession` (from stored
  progress), `assessment_question_selector.dart` (exclude ids), a store for progress (device prefs),
  `web_assessment_layout.dart` (leave dialog copy and pair), `local_state_wiper.dart` (clear both
  stores on account wipe).
- Home card: `home_state_card.dart` (a Continue state with the count), `home_tab.dart`,
  `home_today_screen.dart`, and every other place the same card shows (Quiz tab web and phone, Plan
  page) so the card says the same thing everywhere.
- Placement: `test/helpers/button_placement.dart` covers the new screens.
- Check: `tool/checks/internal_terms.dart` (new, see Checks).

## Lead rulings for states no board draws (rule 4)

Searched: the canvas (33 frames, both notes), the rulings file entries E-165 and E-176, the E-165
handoff, patterns.md (sections named above), the approved boards in `docs/design/boards/` (AS_Leave,
AS_Question, QN_Correct, QN_Wrong, QV_Answer, QV_End*, QZ_Resume), the assessment and onboarding
specs, and the code map. None of the states below is drawn or ruled.

1. Where the run starts. The code's setup ends at the name step, not at study days (the board's
   frame 1 is the last setup screen it draws). The run opens where setup now goes to Home.
   Onboarding is stored complete first, so the onboarding redirect never traps the run.
2. Who sees it. Only a learner who just finished setup, whose exam has a fixed lesson, and who has no
   assessment result for that exam. Existing accounts never see it. An exam with no fixed lesson
   (DOST, SM Foundation, custom tracks) goes to Home as today. Why: never invent content.
3. The fixed lesson and questions. For the 7 exams the lesson is tagged for (UPCAT, ACET, DLSUCET,
   USTET, PUPCET, CSE Professional, CSE Subprofessional): lesson
   `lesson-arithmetic-number-sense-fractions-decimals-percentages`; questions 0001, 0003 (both drawn)
   and 0002, in that order. 0002 is the remaining approved easy question in id order; 0016 to 0020 are
   not approved. If the lesson or a question is retired or missing, the run is not offered.
4. Lesson length. The board draws Core Concept, Mnemonics and Memory Aids, and Example 1 with its
   solution open, then "Answer 3 Questions". The run shows those sections only, not the full lesson
   (E-165 handoff: "Core Concept, the D-to-P aid, Example 1"). The lesson counts as read under the
   existing read rule (15 seconds and the end of the shown text reached), ruling 2 of E-165.
5. Before an answer is checked. The board draws only checked questions. The run uses the live quiz
   step: pick a choice, then Check, then the explanation. Why: his goal is that learners try the real
   quizzing before the assessment; Check prevents a mis-tap from counting. Phone bar before Check:
   left arrow (dimmed on question 1), "N of 3", and Check where the right arrow sits; after Check it is
   the drawn bar (left arrow, "N of 3", right arrow). Wide: "N of 3", the track, and Check, which
   becomes the drawn Next. The right arrow and Next on question 3 open the end screen.
6. Going back. The left arrow shows an earlier checked question, read only, as the live quiz does when
   looking back. System or browser Back moves one step back in the run (question 1 to the lesson, the
   lesson to the intro). Back on the intro leaves the app as setup does. Back on the end screen is Done.
7. Skip and Esc. Skip goes to Home with no confirm on the lesson and question screens (E-165 ruling 4);
   on wide, Esc does the same. The intro's Skip is the ghost button. The end screen has only Done.
8. Reload and closing the app. The run resumes at the same step with its answers (patterns.md:
   "Leaving and coming back resumes at the same step"). Done or Skip clears it. A learner who closes
   the app mid-run and opens it later lands in the run again, not on Home.
9. Offline or content that will not load. The step shows the standard ErrorState ("This needs a
   connection.", Try Again); Skip stays in the header so the learner is never stuck. The daily content
   limit shows its existing message the same way.
10. Pro. No wrong-choice notes in the run (the board draws none); the explanation shows for every plan.
11. The wide "From the lesson" link (W04 only). It returns to the lesson step. Kept on the wide right
   answer only, as drawn.
12. Wide end screen mistake row. The board's short label has no data (`short_label` is empty for these
   questions). The row shows the stem on one line with an ellipsis, as the phone frame does.
13. What the run records. Nothing that counts: no quiz attempt, no scheduling state, no accuracy, no
   streak, no `question_answered` event, no server session upload. The lesson read is recorded (item 4).
   The assessment always leaves out the exam's 3 run questions, done or skipped, so its selection does
   not depend on the run.
14. Assessment progress. Each pick is saved on the device when it is made, with the question list,
   so "8 of 30 answered." counts questions with a saved pick. Continue opens the first unanswered
   question. A saved question no longer in the bank is dropped; if none remain, the card is "Start".
   The progress is cleared when the result saves and on account wipe.
15. The Continue card everywhere. Home, the Quiz tab (web and phone) and the Plan page show the same
   Continue state, with the same words, because they show the same assessment card today.
16. Leave dialog. Phone: the drawn side-by-side pair, Keep Going (neutral) and Leave (teal primary).
   Wide: Keep Going (tertiary) then Leave (teal primary, no key hint), right-aligned. The board
   stylesheet confirms `.btn.nok` is the teal primary. Why teal, not red: leaving no longer loses work,
   and patterns.md gives a non-destructive confirm the primary button. Copy: "Leave the assessment?",
   "Your answers are saved on this device. Continue from Home."
17. Stacked pairs. Phone intro Start and Skip: both full width and 52 high (drawn). Every stacked pair
   the build adds shares width and height; the placement check runs on the new wide screens.
18. Reduce Motion. The end count shows its final number at once; dots, line, mistakes and Done appear
   at once (P06_EndRM). Wide intro's slide-in and the right answer's ring are off. Reader and quiz
   parts keep their own Reduce Motion. Motion on wide follows the phone where the phone animates
   (rule 1).
19. Screen names. `/try` reports as `other` in usage visits (unknown addresses already do, and the
   server accepts it), so no functions deploy is needed. A named id can come with the next functions
   deploy if he wants first-run counts.

## Tasks (tests first in each)

0. Lead: `first_run_content.dart` with the table in ruling 3, and a test that each id exists in the
   content source and is approved, tagged for its exams. Commit before dispatch.
1. Worker A, assessment (rulings 13 to 16): failing tests first for save on pick, resume after leave
   and after a cold reload, the count, a dropped question, clear on save and wipe, the exclusion, the
   Continue card on every surface, the leave dialog copy and pair (phone and wide). Then the code.
2. Worker B, first run (rulings 1 to 12, 17 to 19): failing tests first for the onboarding hand-off
   and who sees it, each step's strings and controls, Check then reveal, Back, Skip and Esc, resume
   after reload, error state, nothing recorded, the lesson read rule, Reduce Motion end state, stacked
   pair sizes, placement on wide. Then the screens.
3. Goldens: 390 and 1440, light and dark, one sheet per screen: intro, lesson top, question right,
   question wrong, end (and the Reduce Motion end), Home Continue, leave dialog. Generated on the CI
   image like the other goldens.
4. Lead integration: merge A and B, run the full check set, then the reviews below.

Workers run in their own worktrees, run focused tests only, never `flutter build` or `flutter run`,
and stage nothing; the lead commits. One Flutter build at a time on the Mac, run by the lead.

## Reviews and checks

- Side-by-side review (fresh Sonnet reviewer, did not write the code): each golden next to its board
  frame at 390 and 1440, light and dark; strings word for word; sizes, colors, spacing; motion
  (durations and order from the frames, phone and wide) and Reduce Motion; patterns.md placement and
  the stacked-pair rule. Headless only, `--use-mock-keychain --password-store=basic`, one sheet per
  screen. Findings to the lead; the lead fixes or rules.
- Internal-term scan: the reviewer lists every user-visible string the build adds or changes and
  checks it against the deny list (taste, starter, tutorial, guided, first run, first-run, lane words,
  E-, D-, T- and U- codes, ruling numbers). New check `tool/checks/internal_terms.dart` scans the
  string literals of `lib/features/first_run/` and the changed assessment and Home strings for that
  list; it is shown failing on the old board string "Taste finished" first. "trial" is not on the
  list because the 7-day free trial is user language.
- Full check set before hand-off: `flutter analyze`, `flutter test`, `dart format`, layering,
  attribution, `dart run tool/checks/run_checks.dart`, and hosted CI on the pull request.

## Rule 7 count

- Fixed items added: none. No scheduled job, secret, service, index, Firestore collection, functions
  change, minimum instance or stored image.
- Firestore and server per real learner who runs it: 1 `getContent` call for the lesson (and the
  existing preload of 3 sibling lessons), 1 for the question set, 1 `recordLessonRead` if read. These
  are real-user costs. Assessment progress is device-only: no Firestore write and no sync.
- Telemetry: no new event names. Screen views go to Analytics (no charge) and usage visits under
  `other`. The run fires no `question_answered`, no `ingestSession`.
- Testing: unit, widget and golden tests run locally and on hosted CI with no hosted project. No
  journey against a hosted project in this build. The release lead's staging proof is counted by the
  release lead before it runs; expected for one pass: 2 to 3 `getContent` calls, 1 `recordLessonRead`,
  1 assessment start (no change from today's per-step cost).

## Hand-off

To the CSE release lead r7 (mcp:launch:55d23bdfde1cbdbac9638f0f42400f367a941a688ddb9d6bea85cda3646e2cd2)
with the branch head, the check output, the review findings and their fixes, and this plan. It ships
to prod before the opening under the standing ship-it because the board is approved. His visual pass
on the live build still applies.

## Not in this build

- Named screen-view id for the run (ruling 19).
- A dark twin of frames the board does not draw beyond token-driven dark (listed above).
