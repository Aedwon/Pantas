# L2 W4a: Onboarding and assessment

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2.
Traceability: 59 rows with workstream `W4a` (17 boards, 42 other items).

## 1. Purpose and scope

Rebuild first launch to Home exactly as the Onboarding page and the assessment boards draw it:
Launch, Welcome (Get Started), Age (wheel, under 13 blocked), Terms and Privacy (usage data first,
terms last enables Continue), Exam picker (grouped, search, Coming soon rows, My exam isn't listed
on top, custom track name and subjects), Exam date (known-date card or month first then optional
day), Study days, Name, Reminders, the system permission dialog, then Home; and the one-time
assessment (pick then Next, results by subject shown once).

Out of scope: Change exam from Settings and sign-in screens (W4f); Home before the assessment (W4b); the reminder service (W4f).

## 2. Inputs

Boards (17): O_Flow, O_Launch, O_Age, O_Consent, O_Picker, O_Custom, O_DateKnown, O_DateChange, O_DateToday, O_Days, O_Name, O_Notify, AS_Question, AS_Picked, AS_Leave, AS_Results, O_Notify_v2.

Other traceability rows (42): D-17, D-29, D-30, D-31, D-32, D-34, D-35, D-36, D-37, D-38, D-39, D-40, D-42, D-43, D-266, G-a-1, G-a-2, G-a-3, G-a-4, G-a-5, G-a-6, G-a-7, G-a-8, G-a-9, G-a-10, G-a-11, G-a-12, G-a-13, G-a-14, G-a-17, G-a-18, G-a-21, G-a-23, G-a-24, G-a-25, G-a-26, G-a-27, G-a-28, G-a-29, G-a-30, G-a-40, G-h-20.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior. Superseded sections of older specs for this family: amendment
spec B1 (rows naming this family's screens); those sections are not built.

## 3. Contracts

Owned. Routes live in this family's route file  (W1 creates it);
W1 removes retired routes and this family deletes the screens behind them:
- `/onboarding` (one route with internal steps and Back), `/onboarding/custom/name`,
  `/onboarding/custom/subjects`; `/assessment/:examId`, `/assessment/:examId/results`.
- `/notifications/rationale` is retired; the reminders step lives inside onboarding.
- Onboarding step state and resume point (section 4).
- `ExamPickerScreen(mode: onboarding | settings, onPicked)`: the grouped picker with search, Coming
  soon rows from the W0 exam catalog and My exam isn't listed on top; W4f reuses it for Change exam.

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W0 exam catalog; W4f `ReminderPrefs` (`dailyEnabled`, `dailyTime`, `followUpEnabled`, `followUpTime`, `countdownEnabled`), which W4f's reminders task lands before this family's reminders step.

## 4. Behavior

- Order and progress bar per D-42 (bar counts 6 steps). Back on every step after Welcome; coming
  back to the date step restores year, month and day as left (D-37). System back equals the Back
  link; on the first step it leaves the app (G-a-19).
- Resume after the app is closed: re-enter at the first unfinished step; Terms is required before
  the picker (G-a-1, G-a-2).
- Exam date rules D-30 to D-40, including exam today allowed, under a week's calm line, multi-day
  exams ask the first day, prefilled date passed skips the card. Custom tracks skip the known-date
  card (G-a-6).
- Study days: nothing preselected, at least one, at least one before the exam, else Continue off
  with the card naming days to add (D-39).
- Name: no Skip; Done needs a name; trimmed, 40 characters, words capitalized (G-a-11, G-a-12).
- Reminders: copy per amendment spec (no "Nothing else."); daily time pill (7:00 PM) and optional
  Follow up (9:00 PM); "Not Right Now" saves both off and asks no permission; iOS uses its own
  prompt at the same point; shown once (G-a-13, G-a-14).
- Custom track: name limits, subjects fixed list unticked with at least one, Continue rests while
  creating, Back saves nothing (G-a-9, G-a-10, G-a-40).
- Assessment: 30 questions per the boards (selector formula kept for narrowed tracks, real count
  shown, G-a-28); pick then Next, "8 of 30" with no caret, "Answers show at the end."; X asks once
  (AS_Leave; the attempt is lost, also when the app is killed); results show once with subjects
  weakest first and "YOUR PLAN STARTS WITH" the weakest topic, then Home; a completed assessment
  cannot be retaken; seeds reviews and counts toward overall accuracy (G-a-21, G-a-29).
- Save and load failures per W4h patterns (S0-33, S0-34).
- Terms acceptance keeps recording the policy version (G-a-18) through W4f's settings repository write, which W4f keeps.
- Free and Pro: same. Placeholders: none.
- `/notifications/rationale`: W1 removes the route (W1's list); W4f deletes the page in `lib/features/notifications/`.
- Uses W4h's state patterns; W4h's pattern task lands before this family's state screens.

## 5. Motion

Boards O_Flow, O_Launch, O_DateKnown, O_DateChange, O_Days, O_Notify, AS_Question, AS_Picked, AS_Results carry entry and step motion.
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
- Terms acceptance records the policy version (G-a-18, W0 recorded-only data).

## 8. Files and directories

`lib/features/onboarding/`, `lib/features/assessment/`, `lib/app/routes/onboarding_routes.dart`, tests.

## 9. Order and parallelism

After W2. Parallel with other W4 families. Order with W4f: W4f's reminders task lands before W4a's reminders step; W4a's `ExamPickerScreen` lands before W4f's Change exam task.
