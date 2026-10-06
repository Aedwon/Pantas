# L3 W4h: app-wide states (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4h-app-wide-states.md`. Base: integration branch after W2. Executor: Sonnet
worker, own worktree. Task 1 lands before any other family's state screens.

## Task 1. Pattern guide and helpers (lands first)

Traceability: S0-32, S0-33, S0-34, G-a-22, G-d-3, G-h-13, G-h-17.

`lib/core/error/state_patterns.dart`: `loadingFor(asyncValue)` (W2 `LoadingShapes` after 300 ms),
`errorFor(what, onRetry)` ("Could not load your <what>." with Try Again, never the exception text),
`saveFailureLine(onRetry)`, `chooseExamFallback(context)` (the ST_NoExam pattern, opens the exam
picker), `assessmentNotReady()` (copy from the current assessment state, "Back to Quiz"). A short
usage guide `docs/superpowers/plans/new-design/drafts/state-patterns.md` for families.
Tests: each helper's output; an exception's message never appears in the widget tree.
Checks: `flutter test test/core/error` green.

## Task 2. Something went wrong

Board SY_Error; D-244. Full-screen W2 `StateView`: "Something went wrong." / "Nothing you've done is
lost." / Try Again (restarts the root route). Replaces `AppErrorView` in `ErrorWidget.builder`
(release). Start-up failure: `bootstrap.dart` shows the same screen when storage, content install or
Firebase setup fails (today it only logs, G-h-8), with Try Again re-running bootstrap.
Tests: release builder shows it; bootstrap failure shows it and retries.
Checks: `flutter test test/core/error test/app` green.

## Task 3. Update required

Board SY_Update; D-244. Pantas logo, "Pantas needs an update to keep working.", Update; cannot be
closed (existing `PopScope`); fails open when the check cannot run (existing).
Test first: the screen cannot be closed with system back and shows Update. Checks: `flutter test
test/features/shell` green.

## Task 4. Raw errors and silent gaps (check only)

Each family applies the patterns in its own screens (every W4 plan says so); W4h edits no other
family's files. The inventory list of raw-error sites and silent sections goes to each family's
plan evidence. At W4 completion W4h runs `grep -rn "Error: \$\|toString()" lib/features/*/presentation`
and reports any student-facing raw error left to the lead.
Checks: the grep prints no line in a student-facing widget (expected: empty output); any hit goes
to the lead with its file and line.

## Task 5. Check

Delete `app_error_view.dart` and its test once unused. All required checks; evidence
`evidence/W4h.md`; independent review; Aedwon's visual check of SY_Error and SY_Update.
Checks: all required checks (SUBAGENTS Part 5) green.
