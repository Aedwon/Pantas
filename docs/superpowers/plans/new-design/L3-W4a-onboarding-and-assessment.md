# L3 W4a: onboarding and assessment (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 9d2c0b5f.
Level 2 plan: `L2-W4a-onboarding-and-assessment.md`. Base: integration branch after W2 (and W4h's
pattern task). Executor: Sonnet worker, own worktree. Order with W4f: W4f's reminders task lands
before Task 8; this family's Task 5 (`ExamPickerScreen`) lands before W4f's Change exam task.

Before each screen task: open its boards (`docs/design/boards/<id>.html`) and run `timeline.py`;
build from the tap; reduce motion shows the last frame. Every task: widget tests first for each
drawn state (light, dark, 200% text), then code, then task checks
(`flutter test test/features/onboarding test/features/assessment test/app`), commit. Each screen
moves to W1's new theme API and W2's components and stops importing retired components.

Cross-family file permission (recorded Oct 6): Task 4 edits `updateExamDate` in
`lib/features/settings/data/settings_repository.dart` to allow today (D-34); W4f is told and runs
later.

Regression tests for GitHub issues #22 (custom-exam entry bounces to the picker, Task 6) and #25
(built-in exam with no content crashes assessment start, Task 9 not-ready state) are written first.

## Task 1. Step model and resume

`lib/features/onboarding/application/onboarding_flow.dart`: steps `launch`, `welcome`, `age`,
`terms`, `picker`, `customName`, `customSubjects`, `examDate`, `studyDays`, `name`, `reminders`.
Resume point computed from storage: age gate passed, policy accepted (`policy_accepted_at`), exam
selected, exam date set or "I don't know", study days set, name set, reminders shown
(`notificationRationaleShownProvider`). Terms is required before the picker (G-a-1, G-a-2).
Onboarding completes after the reminders step (the name step no longer sets the flag). Progress bar:
the count and the steps it covers follow the boards' bar (D-42: 6 segments); record which steps in
the test. Tests first: resume from each partial state; completion only after reminders; telemetry
`onboardingStepReached` logs once per step (not per rebuild).
Router: no change here. The gate already reads `onboardingCompleteProvider`, and W1 removes the
rationale step from it; the resume point lives inside `OnboardingPage`.
System back equals the Back link on every step and on the picker in both modes; on the first step
it leaves the app (G-a-19, moved from W1, gate L3-10). Test: system back on each step goes to the
previous step; on Welcome it pops the route.

## Task 2. Launch and Welcome

Boards O_Launch, O_Flow. Copy per DECISIONS D-32. Replace `onboarding_welcome_step.dart`.

## Task 3. Age and Terms

Boards O_Age (wheel, under 13 blocked with "Try a Different Year"), O_Consent (usage data first,
terms last enables Continue; legal pages open and return with boxes kept, G-a-17). Keep
`recordPolicyAcceptance()` and `updateHelpImproveApp` calls (G-a-18).

## Task 4. Exam date

Boards O_DateKnown, O_DateChange, O_DateToday; rules D-30 to D-40 with W2 `MonthFirstDatePicker`.
Known-date card from W0 catalog `publishedSittings` (skipped when none, when passed, and for custom tracks,
G-a-6). Multi-day exams ask the first day. Exam today allowed: change `updateExamDate`'s earliest
date from tomorrow to today (cross-family permission above) with its test (run `flutter test
test/features/settings` with this task). Under a week: the calm
line. Coming back restores year, month and day.

## Task 5. `ExamPickerScreen`

`lib/features/onboarding/presentation/exam_picker_screen.dart`,
`ExamPickerScreen(mode: onboarding | settings, onPicked)`. Board O_Picker (and ST_ExamPick for
settings mode): search, groups and chips from W0 `group`, Coming soon rows from `comingSoon`
(grayed, not tappable), "My exam isn't listed" on top, loading and can't-load states (W4h
patterns), save failure per S0-34. Large text stacking (G-a-20). System back equals the Back link in both
modes (G-a-19).

## Task 6. Custom track

Board O_Custom. Name: trimmed, 40 characters, blank blocks Continue. Subjects: fixed list from the
corpus, all unticked, at least one, Continue rests while creating. After creating, continue to the
exam date step inside onboarding (no longer `go('/home')`). Back saves nothing (G-a-40).

## Task 7. Study days and Name

Boards O_Days (nothing preselected, at least one, at least one before the exam with the card naming
days to add, "Every Day", Sunday first), O_Name (no Skip, Done needs a name, trimmed, 40 characters,
words capitalized).

## Task 8. Reminders step

Boards O_Notify_v2 (copy without "Nothing else."). Daily time pill 7:00 PM and optional Follow up
9:00 PM via W2 `ValueWheel` in `PantasSheet` (D-42); writes W4f's `ReminderPrefs`; The Follow up wheel offers only times after
the daily time (R-28), with a test. Sounds Good asks
the system permission (Android dialog; iOS prompt at the same point); Not Right Now saves both off
and asks nothing (G-a-13, G-a-14); marks reminders shown; completes onboarding; goes to Home.
Reuses the permission logic from `permission_rationale_page.dart` (W4f deletes that page).

## Task 9. Assessment question screen

Boards AS_Question, AS_Picked, AS_Leave. W2 `QuestionCard`, `ChoiceRow`; pick then Next; "8 of
30" with no caret; "Answers show at the end."; X asks once with W2 `CenteredDialog` (Leave in red).
Set the selector cap to 30 (`assessment_question_selector.dart` `_maxQuestions`), keeping the
per-topic formula for narrowed tracks and showing the real count. A completed assessment opens
Home, not a retake. Not-ready state per W4h pattern.

## Task 10. Assessment results

Board AS_Results: "Where you're starting", half ring (`HalfRingGauge`), subjects weakest first,
"YOUR PLAN STARTS WITH" the weakest topic, Go to Today. Shown once: after Go to Today the results
route redirects to Home.
S0-43b (moved from W4d, gate L3-4): cherry-pick the 5-line Today refresh after a custom assessment
from `web/beta-salvage-assessment-cache-r1` (`assessment_page.dart`) into the rebuilt completion
path, with a test that Today shows the new plan after a custom assessment.

## Task 11. Delete and check

Delete replaced onboarding and assessment widgets and their tests; update
`test/app/router_onboarding_completion_test.dart` and `router_redirect_test.dart` onboarding cases.
All required checks; evidence `evidence/W4a.md`; independent review; Aedwon's visual check on his
phones against the O_* and AS_* boards.
