# L2 W4f: Settings, Pro and account

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2, W3.
Traceability: 149 rows with workstream `W4f` (66 boards, 83 other items).

## 1. Purpose and scope

Rebuild Settings as a tab with every sub-screen on the Settings page: profile card, Pantas Pro and
its tier pages and passes, Your exam (exam, date, study days, carry over, What's included, exam
switching and upgrade), Practice, Reminders (with the approved v2 changes), Appearance, Account and
backup (name, sign-in, Pantas ID, backup states, sign out, delete), About and legal; and the
reminder service and notifications.

Out of scope: Entitlement and public ID logic (W3), the onboarding picker screen (W4a builds it; this family reuses it), Wrapped shared links screen content (W4g owns its rows).

## 2. Inputs

Boards (66): O_SignIn, ST_Root, ST_Exam, ST_ExamDate, ST_Practice, ST_Reminders, ST_RemindersOff, ST_Appearance, ST_Name, ST_About, ST_Account, ST_AccountIDCopied, ST_AccountPro, ST_AccountOut, ST_ExamSwitch, ST_ExamSwitchCount, ST_Included, ST_IncludedOpen, ST_ProFree, ST_ProCSE_v2, ST_ProCSEPass_v2, ST_ProPro, ST_ProRestoreOffline, ST_SignOut, ST_DeleteAccount, ST_BackupDetails, ST_BackupNow, ST_BackupNowOffline, ST_Privacy, ST_RootNoName, ST_RootSignedOut, ST_RootPro, ST_RootTrial, ST_ProLapsed, ST_ExamMonth, ST_ExamUnknown, ST_ExamPassed, ST_ExamCustom, ST_DaysLast, ST_RemindersOffSwitch, ST_BackupStates, ST_AccountOffline, ST_LargeText, ST_DarkRoot, ST_DarkPractice, ST_ExamPick, ST_SwitchUpgrade, ST_SwitchPassWarn, ST_PassEnded, ST_IncludedLast, ST_AccountIDWait, ST_RestoreDone, ST_RestoreNone, ST_ProPassHave, ST_PassNoDate, ST_PassSoon, ST_Avatars, L_Restore, L_Delete, L_Purchase, L_RestorePurchase, L_SignIn, L_ChangeExam2, ST_ProPending, ST_ProSubOffline, ST_Reminders_v2.

Other traceability rows (83): D-25, D-203, D-207, D-208, D-209, D-210, D-211, D-212, D-213, D-214, D-215, D-216, D-217, D-219, D-220, D-222, D-223, D-224, D-225, D-226, D-228, D-229, D-239, D-249, D-250, D-267, D-268, D-269, D-270, D-271, D-272, D-273, D-274, D-278, R-18, R-26, R-27, R-28, A-B2a, A-B2b, A-B2c, S0-1, S0-4, S0-6, S0-7, S0-9, S0-20, S0-21, S0-22, S0-24, S0-35, S0-36, G-a-15, G-a-33, G-a-34, G-a-35, G-a-36, G-a-37, G-a-38, G-a-39, G-b-22, G-b-24, G-b-25, G-b-26, G-b-28, G-f-2, G-f-3, G-f-4, G-f-5, G-f-6, G-f-8, G-f-10, G-f-11, G-f-17, G-f-20, G-f-24, G-f-25, G-f-28, G-f-29, G-f-30, G-h-4, G-h-7, G-h-22.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior. Superseded sections of older specs for this family: amendment
spec B1 (rows naming this family's screens); those sections are not built.

## 3. Contracts

Owned. Routes live in this family's route file  (W1 creates it);
W1 removes retired routes and this family deletes the screens behind them:
- `/settings` root (W1); `/settings/exam`, `/settings/exam/change`, `/settings/exam/included`,
  `/settings/practice` (replaces `/settings/sessions`, which redirects), `/settings/reminders`,
  `/settings/appearance`, `/settings/account`, `/settings/account/name`,
  `/settings/account/delete`, `/settings/backup`, `/settings/pro`, `/settings/about`, `/legal/:doc`.
- Retired: `/paywall` and its three-screen flow (S0-24); Pro buttons everywhere push `/settings/pro`
  and return.
- `ReminderPrefs` (`dailyEnabled`, `dailyTime`, `followUpEnabled`, `followUpTime`,
  `countdownEnabled`) and `ReminderService` (kinds, schedule, notification tap routing per
  amendment B2 including A-B2b, and the implementation of W3's `TrialEndingNotifier`). Its task lands
  before W4a's reminders step.
- Keeps the Terms policy-version write in `settings_repository.dart` (W0 recorded-only data).
- `SharedLinksRow` slot in About, filled by W4g.

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W3 entitlement, tier, pass, `mockLimit`, `switchOutcome`, purchase operations, public ID, `TrialEndingNotifier`; W4a `ExamPickerScreen`; W4b `retainTableOrderProvider`; W4g `SharedLinksRow`.

## 4. Behavior

- Root and every screen per D-207 to D-229 and the Copy pass (D-266 to D-278); no sheets anywhere;
  Free sees every row; offline rows still work and sync later.
- Exam switching per S0-1 (student chooses Count Them or Start My Numbers Fresh), D-222, D-224 via
  W3 `switchOutcome`; date and study days kept with confirmation.
- Pro pages per tier and pass (D-217, D-226, D-227, D-229) with W3 states (S0-35): trial, canceled
  until a date, grant, unknown, billing problem, store errors; payment pending and offline notes
  (D-249, D-250).
- Reminders per amendment spec Part A and ST_Reminders_v2: daily (switch, time), Follow up (switch,
  its own time row after the daily time), Exam countdown (switch, hidden without an exact day);
  come-back and trial-ending automatic; turning a reminder on asks permission the first time
  (G-f-30); blocked state per ST_RemindersOff.
- Reminder service (amendment B2): kinds dailyReminder, followUp, examCountdown, comeBack,
  trialEnding; countdown and come-back replace that day's daily reminder; follow-up still applies;
  no daily ceiling; no Wrapped push; copy variants kept with no guilt and no unmeasured figures; tap
  routing per amendment B2.
- Notification tap routing per amendment B2 (A-B2b): daily, follow up, come back and countdown open
  Home; trial ending opens Settings › Pantas Pro.
- Account per D-213, D-219, D-220, D-278, S0-20, S0-21, S0-36: sign-in conflict dialog, Delete my
  data for signed-out students, fresh sign-in before deletion, failure lines, return to Welcome after
  deletion; Pantas ID grouped in threes, tap copies digits only.
- About per D-214: DPO row, no export (S0-22); legal pages plain (G-f-10).
- Appearance: Light, Dark, Automatic; Text size slider (W1 scale); Remember table order (writes W4b's
  `retainTableOrderProvider`).
- Pro pages for Licensure, academy exams and PSHS-NCE are deferred until those exams launch (Aedwon,
  Oct 6, gate F-16); their board rows are marked deferred.
- The CSE Pro page follows `ST_ProCSE_v2` and its pass-picked state `ST_ProCSEPass_v2` (Weekly ₱49,
  Monthly ₱149, Yearly ₱1,199, pass ₱499), replacing ST_ProCSE and ST_ProCSEPass (approved by
  Aedwon Oct 6). Savings figures round down ("SAVE 32%" on both Student and CSE).
- Deletes `lib/features/notifications/presentation/permission_rationale_page.dart` and
  `lib/features/notifications/application/wrapped_trigger_notification_router.dart` (S0-8).
- Adds a link to W2's gallery from the debug page (debug builds only).
- Follow up notification copy: "Still time today" / "One short session gets today's plan started."
  (Aedwon, Oct 6, gate F-19).
- Replaces every retired Ink component and `showInkSheet` call in its own screens with W2's components; its sheet call sites: name, exam date, ordering, reminder and carry-over sheets (`stage0/gap-h-shell-states.md`).

## 5. Motion

Boards ST_ExamSwitch, ST_ExamSwitchCount (liquid curve), ST_DaysLast, ST_IncludedLast (shake), ST_AccountIDCopied, ST_BackupNow, ST_RestoreDone animate.
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
- Deploying any function or rules change needs Aedwon's approval.
- Play Console and RevenueCat setup is Aedwon's (W3 instructions); Pro page tasks that need the new products wait for it.

## 8. Files and directories

`lib/features/settings/`, `lib/features/paywall/presentation/` (rebuilt, flow pages deleted), `lib/features/legal/`, `lib/features/notifications/`, `lib/core/notifications/`, `lib/app/routes/settings_routes.dart`, tests.

## 9. Order and parallelism

After W2 and W3, and after W4a's picker screen lands. Landing order: this family's reminders task before W4a's reminders step; W4b's `retainTableOrderProvider` move before this family's Appearance task; this family's About slot before W4g's shared links task; W4h's pattern task before this family's state screens. Largest with W4b; the level 3 plan splits it into Settings screens, Pro pages, account, and reminders tasks.
