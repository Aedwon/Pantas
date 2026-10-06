# L3 W4f: Settings, Pro and account (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 1958c0f1.
Level 2 plan: `L2-W4f-settings-pro-and-account.md`. Base: integration branch after W2, W3 and W4h's
pattern task. Executor: one Sonnet worker, own worktree (`L3-parallel-map.md`: three-worker limit): track D
(reminders, Task 1) first because W4a's reminders step needs it; then, after W4a, track A (Tasks 2
to 5) then track B (Tasks 6 to 9); `settings_routes.dart` edits in task order.
Landing order: Task 1 before W4a Task 8; W4a's `ExamPickerScreen` before Task 3; W4b Task 1 before
Task 4; Task 5's About slot before W4g's shared links task.

Before each screen task: open its boards and run `timeline.py`. Every task: widget tests first per
drawn state (light, dark, 200% text), unit tests per rule, then code, task checks (`flutter test
test/features/settings test/features/paywall test/features/notifications test/features/legal
test/app`), commit. W1 theme API, W2 components (no sheets anywhere in Settings, D-207).

Regression test for GitHub issue #26 (exam-switch carry-over flashes and reappears) is written first
in Task 3; the in-list transfer screen replaces the sheet.

Plan status (the Settings Pro row, the Pro page's plan name, Your plan rows and Manage link) reads
the any-plan entitlement. Whether the Pro page offers the active exam's plans and pass or shows the
owned state follows W3's `proForActiveExamProvider` (level 3 gate reviews 3 and 4).

## Task 1. Reminder settings and service (track D, lands first)

`ReminderPrefs` (`dailyEnabled`, `dailyTime`, `followUpEnabled`, `followUpTime`, `countdownEnabled`)
in `lib/features/notifications/domain/reminder_prefs.dart`, stored through the settings repository.
`ReminderService` in `lib/features/notifications/application/reminder_service.dart` with kinds
`dailyReminder`, `followUp` (replaces `streakSave`), `examCountdown`, `comeBack`, `trialEnding`
(implements W3's `TrialEndingNotifier` and binds it). Rules (amendment B2): study days only for
daily and follow-up; follow-up after the daily time, only if Today is not started; countdown on
30, 14, 7, 3, 2, 1, 0 days at the daily time or 19:00, exam day 07:00, its own switch, exact day
only; come-back after 3 study days with no session, once, naming a measured subject and score or
not sent; countdown and come-back replace that day's daily reminder; no daily ceiling (remove
`notification_ceiling.dart`); no Wrapped push (delete
`wrapped_trigger_notification_router.dart`). Copy: existing daily variants kept; Follow up "Still time
today" / "One short session gets today's plan started."; trial-ending text with the student's own
plan price and date. Permission denied: nothing is scheduled and Reminders shows
the blocked state (A-B2c, test). Tap routing: all open Home except trial ending, which opens Settings › Pantas
Pro. Tests for every rule and the tap map. Delete `permission_rationale_page.dart` and its test
after W4a's reminders step lands (W1's redirect covers its path).

## Task 2. Settings root and tab (track A)

Boards ST_Root, ST_RootNoName, ST_RootSignedOut, ST_RootPro, ST_RootTrial, ST_DarkRoot; D-207. Profile
card, Pantas Pro row value (plan, "Trial, N days left"), Your exam, Practice, Reminders, Appearance,
About; icons per W1. Settings is the fourth tab (W1's shell); Home's gear goes with W4b's masthead.

## Task 3. Your exam (track A)

Boards ST_Exam, ST_ExamCustom, ST_ExamDate, ST_ExamMonth, ST_ExamUnknown, ST_ExamPassed, ST_DaysLast,
ST_ExamPick, ST_ExamSwitch, ST_ExamSwitchCount, ST_SwitchUpgrade, ST_SwitchPassWarn, ST_Included,
ST_IncludedOpen, ST_IncludedLast; D-208, D-221, D-222, D-224, D-225, S0-1. Exam opens W4a's
`ExamPickerScreen(mode: settings)`; date opens in the list (Exact day, Month only, I don't know);
study days circles, at least one; carry over; What's included with W2 `ScopePicker` (at least one
topic, shake); switching uses W3 `switchOutcome`: transfer screen with Count Them or Start My Numbers
Fresh (replaces `carry_over_prompt.dart` sheet), upgrade offer, pass warning; date and study days
kept with the confirmation (L_ChangeExam2 wait). Tapping the current exam does nothing.

## Task 4. Practice, Reminders screen, Appearance (track A)

Boards ST_Practice, ST_DarkPractice, ST_Reminders_v2, ST_RemindersOff, ST_RemindersOffSwitch,
ST_Appearance, ST_LargeText; D-209 to D-212. Practice at `/settings/practice` (add the redirect from
`/settings/sessions` now): session length 5/10/20/All, how sessions are built, strict mode with its
footer (the default the mock setup switch reads). Reminders per ST_Reminders_v2 with
`ReminderPrefs`; the Follow up time wheel offers only times after the daily time (R-28, test); turning a reminder on asks permission the first time; blocked state opens phone
settings. Appearance: Light, Dark, Automatic previews; text size slider writing W1's
`lessonTextScaleProvider`; Remember table order writing `retainTableOrderProvider` (moved by W4b).
Delete the name, exam date, ordering and reminder sheets.

## Task 5. About and legal (track A)

Boards ST_About, ST_Privacy; D-214. Version, Privacy policy, Terms of service, Help improve the app,
Contact our data protection officer (address shown as selectable text, mail link as a convenience),
Send feedback (Facebook group), Shared links slot for W4g's `SharedLinksRow`, Debug page link (debug
builds) and W2 gallery link. Plain legal pages; legal page error per W4h.

## Task 6. Pro page (track B)

Boards ST_ProFree, ST_ProPro, ST_ProLapsed, ST_RestoreDone, ST_RestoreNone, ST_ProRestoreOffline,
ST_ProSubOffline, L_Purchase, L_RestorePurchase, ST_ProCSE_v2, ST_ProCSEPass_v2, ST_PassEnded,
ST_PassSoon, ST_PassNoDate, ST_ProPassHave; D-217, D-226 to D-229, D-249, D-250, Copy pass. Plans
for the active exam's tier from W3, offered when `proForActiveExamProvider` is false (test: a Student
Pro subscriber on CSE sees the Civil Service plans and pass); Student and Civil Service pages; CS layout per ST_ProCSE_v2 and
its pass-picked state; savings round down; trial line only when eligible; pass end dates from the
catalog; payment pending card; offline notes; W3 states (trial, canceled until a date, grant, unknown,
billing problem, store errors) in the Your plan rows. Coming-soon tier pages are not built (deferred,
Oct 6). When W3's `switchOutcome` (Task 6) carries `studentPlanStillRenews` (a Season Pass bought
while a Student plan is active), the Pro page shows that the Student plan still renews, with Manage
in Google Play, and a test covers it. This waits for Aedwon's decision and copy (asked at the start
of level 4, W3 Task 6); if he chooses otherwise, stop. Opening this page calls `ReviewPromptController.recordPaywallSeen` (W4d's cool-off). Update
`payment_presentation_source_guard_test.dart`: it forbids "₱499" from the superseded Yearly price;
now ₱499 is the CS pass and prices come from the store (no literal prices in presentation code).

## Task 7. Retire the Try Pro flow (track B)

Every Pro button pushes `/settings/pro` and returns (`context.push`); remove the five `/paywall`
pushes as W4b rebuilds Home and Progress, or here for files in this family (W4g has none). Delete
`paywall_page.dart`, `what_pro_adds_page.dart`, `plans_page.dart`, `trial_timeline_page.dart`,
`pro_specimen_panel.dart`, `paywall_package_card.dart`, `plan_row.dart`, `subscription_panel.dart`, `lib/features/paywall/domain/paywall_recommendation.dart` (W3 Task 4
leaves it for this task) and their tests once no caller remains; `trial_notice_banner.dart` and `pro_welcome_banner.dart` are
replaced by W4b's notices.

## Task 8. Account and backup (track B)

Boards ST_Account, ST_AccountPro, ST_AccountOut, ST_AccountOffline, ST_AccountIDCopied,
ST_AccountIDWait, ST_Avatars, ST_Name, ST_SignOut, ST_DeleteAccount, L_Delete, ST_BackupDetails,
ST_BackupNow, ST_BackupNowOffline, ST_BackupStates, O_SignIn, L_SignIn, L_Restore; D-213, D-215,
D-219, D-220, D-223, D-278; S0-20, S0-21, S0-36. Profile card opens Account; Name screen; Pantas ID
from W3 `publicIdProvider` grouped in threes, tap copies digits only, "Copied" for 2 s, "Not ready
yet", signed-out line; backup states and Back Up Now; sign-in with the conflict dialog (W2
`CenteredDialog`, replaces `sync_reconciliation_gate.dart`'s dialog UI); sign out; delete with fresh
sign-in, steps screen, failure line, return to Welcome; Delete my data for signed-out students.
Keeps the Terms policy-version write in `settings_repository.dart`.

## Task 9. Delete and check

Delete any Try Pro flow file Task 7 could not delete yet, now that W4b has landed.

Delete replaced Settings pages, sheets and their tests; stop importing retired components
(`exam_date_sheet`, `theme_control`, `settings_*` components, `ink_*`). Remove the empty
`lib/features/auth_flow/` folders. All required checks; evidence `evidence/W4f.md`; independent
review; Aedwon's visual check against the ST_*, L_* and O_SignIn boards.
