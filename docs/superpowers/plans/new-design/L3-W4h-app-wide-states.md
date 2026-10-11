# L3 W4h: app-wide states (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4h-app-wide-states.md`. Base: integration branch after W2. Executor: one
worker, own worktree (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews). Task 1 lands before any other family's state screens.

## Lead rulings, October 11 (W4h stop at b8de9e05)

1. Save-failure line: "Could not save your progress." with "Try Again" (lead default in the style
   of the approved load line; reported to Aedwon, who may change the wording).
2. Shared components: a screen family may extend a W2 component when a board needs something the
   component lacks, in the component's own file with tests beside W2's, and lists the change in its
   evidence. Never a local copy. For this family: `StateView` gains an optional detail paragraph,
   an action label, and a primary-button action, with ST_NoExam's metrics (40 px faint icon, 6 px
   gaps, 20/700 title at 1.35 and -0.2, 15/400 paragraph at 1.45, 48 px primary button, radius 14,
   26 inset, bottom padding 150); `StateView.fullScreen` follows SY_Error (72 px circle `#EDEDF0`,
   36 px glyph `#6E6E73` through tokens, 14 px gaps, content padding top 8 and bottom 120, the
   button overlaid at the bottom with 16 px side gutters, 14 top and 30 bottom). The earlier
   38 px `#C7C7CC` mark was W2's error; boards rule.

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
plan evidence. At W4 completion W4h runs `grep -rnF 'Error: $' lib/features/*/presentation` and
`grep -rnE '\b(e|err|error|exception)\.toString\(\)' lib/features/*/presentation` and
`grep -rnE "Text\([^)]*\\\$\{?(e|err|error|exception)\b" lib/features/*/presentation`
and reports any student-facing raw error left to the lead. The greps are a backstop to each family's
own inventory; they miss strings split across lines.
Checks: the grep prints no line in a student-facing widget (expected: empty output); any hit goes
to the lead with its file and line.

## Task 5. Check

Delete `app_error_view.dart` and its test once unused. All required checks; evidence
`evidence/W4h.md`; independent review; Aedwon's visual check of SY_Error and SY_Update.
Checks: all required checks (SUBAGENTS Part 5) green.
