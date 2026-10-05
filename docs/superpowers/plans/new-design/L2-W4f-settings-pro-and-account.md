# L2 W4f: Settings, Pro and account

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main b52757bf.
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2, W3.
Traceability: 153 rows with workstream `W4f` (71 boards, 82 other items).

## 1. Purpose and scope

Rebuild Settings as a tab with every sub-screen on the Settings page: profile card, Pantas Pro and
its tier pages and passes, Your exam (exam, date, study days, carry over, What's included, exam
switching and upgrade), Practice, Reminders (with the approved v2 changes), Appearance, Account and
backup (name, sign-in, Pantas ID, backup states, sign out, delete), About and legal; and the
reminder service and notifications.

Out of scope: Entitlement and public ID logic (W3), the onboarding picker screen (W4a builds it; this family reuses it), Wrapped shared links screen content (W4g owns its rows).

## 2. Inputs

Boards (71): O_SignIn, ST_Root, ST_Exam, ST_ExamDate, ST_Practice, ST_Reminders, ST_RemindersOff, ST_Appearance, ST_Name, ST_About, ST_Account, ST_AccountIDCopied, ST_AccountPro, ST_AccountOut, ST_ExamSwitch, ST_ExamSwitchCount, ST_Included, ST_IncludedOpen, ST_ProFree, ST_ProCSE, ST_ProCSEPass, ST_ProNCE, ST_ProPro, ST_ProRestoreOffline, ST_SignOut, ST_DeleteAccount, ST_BackupDetails, ST_BackupNow, ST_BackupNowOffline, ST_Privacy, ST_RootNoName, ST_RootSignedOut, ST_RootPro, ST_RootTrial, ST_ProLapsed, ST_ExamMonth, ST_ExamUnknown, ST_ExamPassed, ST_ExamCustom, ST_DaysLast, ST_RemindersOffSwitch, ST_BackupStates, ST_AccountOffline, ST_LargeText, ST_DarkRoot, ST_DarkPractice, ST_ExamPick, ST_SwitchUpgrade, ST_SwitchPassWarn, ST_PassEnded, ST_IncludedLast, ST_AccountIDWait, ST_RestoreDone, ST_RestoreNone, ST_ProPassHave, ST_PassNoDate, ST_ProNCENoDate, ST_PassSoon, ST_ProLET, ST_ProPMA, ST_ProPMAPass, ST_Avatars, L_Restore, L_Delete, L_Purchase, L_RestorePurchase, L_SignIn, L_ChangeExam2, ST_ProPending, ST_ProSubOffline, ST_Reminders_v2.

Other traceability rows (82): D-25, D-203, D-207, D-208, D-209, D-210, D-211, D-212, D-213, D-214, D-215, D-216, D-217, D-219, D-220, D-222, D-223, D-224, D-225, D-226, D-228, D-229, D-239, D-249, D-250, D-267, D-268, D-269, D-270, D-271, D-272, D-273, D-274, D-278, R-18, R-26, R-27, R-28, A-B2a, A-B2c, S0-1, S0-4, S0-6, S0-7, S0-9, S0-20, S0-21, S0-22, S0-24, S0-35, S0-36, G-a-15, G-a-33, G-a-34, G-a-35, G-a-36, G-a-37, G-a-38, G-a-39, G-b-22, G-b-24, G-b-25, G-b-26, G-b-28, G-f-2, G-f-3, G-f-4, G-f-5, G-f-6, G-f-8, G-f-10, G-f-11, G-f-17, G-f-20, G-f-24, G-f-25, G-f-28, G-f-29, G-f-30, G-h-4, G-h-7, G-h-22.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior.

## 3. Contracts

Owned (routes and screen-local state only; nothing shared):
- `/settings` root (W1); `/settings/exam`, `/settings/exam/change`, `/settings/exam/included`,
  `/settings/practice` (replaces `/settings/sessions`, which redirects), `/settings/reminders`,
  `/settings/appearance`, `/settings/account`, `/settings/account/name`,
  `/settings/account/delete`, `/settings/backup`, `/settings/pro`, `/settings/about`, `/legal/:doc`.
- Retired: `/paywall` and its three-screen flow (S0-24); Pro buttons everywhere push `/settings/pro`
  and return.
- Reminder service kinds and schedule (amendment B2); notification tap routing.

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W3 entitlement, tier, pass, switching outcome, purchase operations, public ID, trial-ending trigger; W4a exam picker; W4g shared links rows.

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
- Account per D-213, D-219, D-220, D-278, S0-20, S0-21, S0-36: sign-in conflict dialog, Delete my
  data for signed-out students, fresh sign-in before deletion, failure lines, return to Welcome after
  deletion; Pantas ID grouped in threes, tap copies digits only.
- About per D-214: DPO row, no export (S0-22); legal pages plain (G-f-10).
- Appearance: Light, Dark, Automatic; Text size slider (W1 scale); Remember table order.

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
- Copy differs from the board: the board wins (README rule 1); report any board without copy.
- Deploying any function or rules change needs Aedwon's approval.
- Play Console and RevenueCat setup is Aedwon's (W3 instructions); Pro page tasks that need the new products wait for it.

## 8. Files and directories

`lib/features/settings/`, `lib/features/paywall/presentation/` (rebuilt, flow pages deleted), `lib/features/legal/`, `lib/features/notifications/`, `lib/core/notifications/`, routes, tests.

## 9. Order and parallelism

After W2 and W3, and after W4a's picker screen lands. Largest with W4b; the level 3 plan splits it into Settings screens, Pro pages, account, and reminders tasks.
