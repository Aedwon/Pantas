# L2 W4h: App-wide states

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2.
Traceability: 13 rows with workstream `W4h` (2 boards, 11 other items).

## 1. Purpose and scope

Own the app-wide error, update and offline behavior and the shared state patterns every family
applies: Something went wrong, Update required, start-up failure, and the error, empty, loading and
save-failure patterns (S0-33, S0-34).

Out of scope: Each family's own state screens (they apply these patterns).

## 2. Inputs

Boards (2): SY_Error, SY_Update.

Other traceability rows (11): D-244, S0-32, S0-33, S0-34, G-a-22, G-d-3, G-h-8, G-h-12, G-h-13, G-h-16, G-h-17.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior. Superseded sections of older specs for this family: amendment
spec B1 (rows naming this family's screens); those sections are not built.

## 3. Contracts

Owned. Routes live in this family's route file  (W1 creates it);
W1 removes retired routes and this family deletes the screens behind them:
- `/update-required` (W1 keeps the gate; this family owns the screen).
- The pattern rules below; `StateView` usage guide for families.

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W2 `StateView`, `LoadingShapes`, `StepsScreen`.

## 4. Behavior

- Something went wrong per D-244: "Something went wrong." / "Nothing you've done is lost." / Try
  Again; replaces the red error screen; also shown when the app fails to start (G-h-8).
- Update required per D-244: logo, line, Update; cannot be closed; fail open if the check cannot run.
- Patterns: loading shapes only after 300 ms; failures say "Could not load your X." with Try Again;
  a failed section shows the pattern, never a silent gap (G-h-16); never raw error text (G-h-12);
  save failures show one calm line in place with Try Again (S0-34).
- Assessment not ready state for exams without assessment questions (G-a-22, G-d-3).
- Choose your exam fallback pattern used on every tab (S0-32).
- Ownership: W2 owns `StateView`; this family owns the app-wide screen, its triggers and the
  retirement of `app_error_view.dart`.
- Free and Pro: same. Placeholders: none.

## 5. Motion

Boards SY_Error, SY_Update are static with entry motion.
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
- Families that find a state these patterns cannot express: stop; the lead amends this plan.

## 8. Files and directories

`lib/core/error/`, `lib/features/shell/presentation/update_required_page.dart`, `lib/core/ui/components/app_error_view.dart` (replaced), tests.

## 9. Order and parallelism

After W2. Its pattern task (StateView usage, error, empty, loading and save-failure rules) lands before any other family's state screens; every other W4 plan states this order. Small.
