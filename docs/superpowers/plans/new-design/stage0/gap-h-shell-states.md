# Gap pass: family h-shell-states

Policy revision: origin/main 6d508d70 (AGENTS.md, WORKFLOW.md, SUBAGENTS.md read at that revision).
Current app read at integration/new-design-r1 1f79d880 (worktree Pantas-wt-integration-new-design-r1).
Scope: app shell and tab bar, navigation and routes, loading, errors, offline, update required, service message, icons, dark mode, app-wide snackbars, toasts, dialogs and bottom sheets.
Settled by the restart log and not listed as open: bottom sheets only where a board shows one (README rule 5 adds: choices open in place, as their own screen, or as a centered dialog); old Progress screens and routes retired; date format approved; screens with no board, including dark mode outside the main screens, are built by the lead from the shared rules.
Paths below are relative to the worktree unless they start with docs/design (main checkout).

## A. Changed by the design

| old behavior | new behavior | board id(s) | evidence |
|---|---|---|---|
| Tab bar has four tabs: Home, Study, Quiz, Progress. Settings is not a tab. | Tabs are Home, Study, Quiz, Settings. Progress is merged into Home. Settings is a tab with no back button. Tap telemetry labels need "settings" in place of "progress". | HP_Free, QZ_Tab, ST_Map, ST_Root (all show the four-tab bar) | lib/features/shell/presentation/app_shell.dart:15, 45-50; lib/app/router.dart:226-233 (progress branch), 459-462 (/settings is a pushed route); docs/design/DECISIONS.md "Navigation"; spec 2026-07-18-ui-redesign-design.md "Navigation structure" |
| Settings opens from a gear in the Home masthead (pushes /settings with a back button). | No gear or person button at the top of Home. Settings is reached from the tab. | HP_Free, HP_Pro, ST_Root | lib/features/home/presentation/widgets/home_masthead.dart:57-61; DECISIONS "Home (approved)" first bullet; spec 2026-07-26-home-and-navigation-design.md "Masthead" |
| Tab bar is a full-width bar with a hairline top rule, hand-drawn outline glyphs (house, book, three-option bubble, folded sheet), no teal. | Floating pill tab bar, Phosphor glyphs (house, book-open, check-circle, gear-six), teal as the single accent. | IC_Final, any board with a tab bar | app_shell.dart:119-131; lib/core/ui/components/nav_glyph.dart:4; docs/design/README.md "Tokens" (floating pill tab bar); IC_Final "Getting around"; spec 2026-07-26-home-and-navigation-design.md Section 1 |
| Four-tab Progress tab (ProgressPage: performance, your record, how you work, Mock exam row) is a tab and a route. | Progress screens retired as a tab. Your performance opens from Home "See all topics and lessons"; Your record and Your tendencies are Home rows; Your plan is its own screen. Boards name the routes /progress (Your performance), /progress/your-record, /progress/how-you-work, /plan. | DT_*, YR_*, YO_*, DP_* | router.dart:226-233, 260-267; lib/features/progress/presentation/progress_page.dart; DECISIONS "Home: COMPLETE"; restart log decision 5 |
| App-wide error replacement is one muted line, "Something went wrong here.", with no button (release builds only). | "Something went wrong." / "Nothing you've done is lost." / Try Again button. | SY_Error | lib/core/ui/components/app_error_view.dart:7-16, 44-47; DECISIONS "The rest of the app"; spec 2026-08-03-platform-foundations-design.md Section 9 |
| Update-required screen: one line and an Update button, no logo. | Same, with the Pantas logo above the line. Still cannot be closed. If the check cannot run the app opens (fail open, already built). | SY_Update | lib/features/shell/presentation/update_required_page.dart:37-60; router.dart:73-80; DECISIONS "The rest of the app" |
| Service message: parsed from Remote Config and stored, but no screen reads it. Spec says "a single line shown on Home when set". | Home notice strip in the same place and style as the other notices: one line, a close button, nothing to open. | HP_Service | lib/core/platform/remote_flags.dart:7-27 (no reader in lib/features); spec 2026-08-03-platform-foundations-design.md Section 5; DECISIONS "Last gaps" |
| Loading placeholder is static faint bars (FaintBars, "no shimmer"), shown immediately on every local load. | Grey shapes where the content will be, gently pulsing, shown only if loading passes 300 ms, then the real content fades in. Under 300 ms nothing shows. Pro-gate bars stay still so the two are never confused. | L_Rules, ST_Loading, L_PlanSlow, L_ProgressSlow, L_DebriefSlow | lib/core/ui/components/faint_bars.dart:5-6; home_tab.dart:154-163; quiz_tab_home.dart:40; learn_tab_home.dart:160; spec 2026-07-18-ui-redesign-design.md line 111 |
| Round Material spinners (CircularProgressIndicator) on Your record, mock review, mock session, delete account, paywall. | Three tiers: a steps screen for long or irreversible work (restore after sign-in, delete account, set out a mock paper, hand in a mock); the button itself becomes a spinner and a short verb for one wait (purchase, restore purchase, sign in, share link); shapes only if slow. Never a fake wait or a progress bar that measures nothing. | L_Restore, L_Delete, L_MockStart, L_Purchase, L_RestorePurchase, L_SignIn, L_Share, L_ChangeExam2 | lib/features/progress/presentation/pages/your_record_page.dart:22; lib/features/mock_exam/presentation/pages/mock_review_page.dart:84; mock_session_page.dart:331-334; lib/features/settings/presentation/pages/delete_account_page.dart:105; paywall_page.dart:209, 273, 393; DECISIONS "Loading" |
| Reduce Motion: only the tab-bar rise is skipped. | Spinners become a static "Loading" label and nothing pulses. | L_Rules | app_shell.dart:203-204; docs/design/boards/L_Rules.html |
| Load-failure banner (ErrorBanner, rust accent bar) with copy such as "Could not load your topics. Pull down to try again." and a small Try again link. | One line and a Try Again button. Study "Could not load your topics."; reader "Could not load this lesson." (old: "Failed to load lesson."); Your plan "Could not load your plan."; Your performance "Could not load your performance."; Your tendencies "Could not load your progress." | ST_Error, RD_Error, DP_Error, DT_Error, YO_Error | learn_tab_home.dart:161-166; lib/features/lesson/presentation/lesson_page.dart:112-115; progress_page.dart:164-168; lib/core/ui/components/error_banner.dart |
| Offline subscribe and restore copy: "You need a connection to subscribe. Try again when you're back online." / "...to restore purchases. Try again when you're back online." (spec bans "please"). | "No internet connection. Please try again." for both. Sign in keeps "You need a connection to sign in." | ST_ProRestoreOffline, ST_ProSubOffline, ST_AccountOffline | settings/presentation/pages/pro_page.dart:205; paywall_page.dart:187; trial_timeline_page.dart:224; plans_page.dart:292; paywall_controller.dart:114; spec 2026-08-03-offline-and-network-posture-design.md Section 4; DECISIONS "Copy pass" |
| Backup offline: the only disclosure is a "Last backed up" date or "Not backed up yet". Spec bans a queue counter and defers a manual Back up now button. | Backup page shows Offline, "Waiting to back up: 3 changes", and a Back Up Now button that dims offline with "You need a connection to back up." | ST_BackupNowOffline, ST_BackupNow, ST_BackupStates | spec 2026-08-03-offline-and-network-posture-design.md Sections 5, 6 and Deferred; lib/features/settings/domain/backup_status.dart |
| Offline quiz report (spec): none. | Report with no connection: the bar says "Saved. It sends when you're back online." (no separate toast). | QN_ReportOffline | docs/design/boards/QN_ReportOffline.html |
| Sheets replaced by in-place rows, own screens or a dialog: exam date (showExamDateSheet), name, reminder time, session ordering, carry-over prompt, subject scope picker, custom mock wheels (questions and time). | Exam date opens in the list (Exact day / Month only / I don't know); Name is its own screen; Reminders time opens in place; Practice uses segments and a checklist; Carry over is a switch row (and the switch-exam confirm); a Home subject tap opens Topics with that subject picked; Questions and Time open as wheels in the list. | ST_ExamDate, ST_Name, ST_Reminders, ST_Practice, ST_ExamSwitchCount, DT_SubjectTap, CM_Wheel | settings_home_page.dart:62, 80, 106, 133; exam_date_sheet.dart:65; carry_over_prompt.dart:16; name_sheet.dart:12; reminder_sheet.dart:16; ordering_sheet.dart:20; progress/presentation/widgets/subject_scope_sheet.dart:28; mock_exam/presentation/widgets/value_wheel_sheet.dart:244, 273; DECISIONS "Settings" ("No sheets anywhere"); README rule 5 |
| Wrapped share success toast "PNG rendered for sharing." (image only). | Share creates a pantas.app link; the button turns into a spinner then "Link copied". Offline: "Your Wrapped needs a connection. It'll be here when you're back." | L_Share, WR_Share, WR_ShareOffline | lib/features/wrapped/presentation/wrapped_reveal_page.dart:133-135; DECISIONS "The rest of the app" (Sharing) |
| Home weakest-topic Practice panel with its snackbars ("No questions are ready right now.", "Could not prepare this quiz."). | Panel gone. "Needs practice" is See All sorted weakest first; it is not on Home. | DT_SortFlow, DT_TopicsA | lib/features/home/presentation/widgets/practice_panel.dart:101-118; DECISIONS "Home (approved)" |
| Leave-mock dialog "Leave mock? / The clock keeps running." (Leave, Stay). | With strict off, leaving pauses the mock and the student may then discard; with strict on, leaving the app ends and scores the mock. Discard has its own red confirm. | MK_PauseFlow, MK_Discard, MK_Forfeit | mock_session_page.dart:254-282; DECISIONS "Mock exam screens" (Pause, Strict mode) |
| Leave-assessment dialog "Leave assessment? Your progress will be lost." (Stay, Leave, text buttons). | "Leave the assessment?" with Leave in red; the attempt is lost. | AS_Leave | assessment_page.dart:150-171; DECISIONS "The rest of the app" |
| Sign-out dialog (AlertDialog): "Your study progress on this device will be cleared. Only progress already synced through Pantas Pro may be available after you sign in again." | "Sign out?" / "Your progress stays on this phone. Sign in again any time." Cancel / Sign Out. | ST_SignOut | settings/presentation/pages/account_page.dart:117-143 |
| Quiz leave dialog already uses the confirm component; Pause warning reads "Real exams do not pause." with a "Pause" confirm. | "Real exams don't pause." with "Don't show this again"; pause copy per Copy pass. | QV_Leave, MK_PauseWarn | mock_exam/presentation/pause_page.dart (confirm at 35); mock_session_page.dart:112-130; DECISIONS "Copy pass" (Mock pause warning) |
| Icons: Material Icons plus ~10 hand-drawn painters (nav glyphs, chevron, contents, magnifier, pennant, question grid, theme control). No phosphor package. | Phosphor regular everywhere (37 icons) plus nine of ours redrawn at 1.5 weight. Settings icons sit on the row without a tile, each in its own color. Note: IC_Final lists "Locked until Pro: lock" while DECISIONS "Free and Pro" says no locks; DECISIONS also names a sliders icon for Customize your own that IC_Final does not list. | IC_Final | pubspec.yaml (no phosphor); lib/core/ui/components/{nav_glyph,ink_chevron,back_chevron,contents_glyph,ink_magnifier,pennant_mark,theme_control}.dart; DECISIONS "Icons" |
| Dark mode: charcoal (#111214 / #1e1f22) hairline palette (spec) and a three-icon ThemeControl in Settings. | Black background, dark gray groups (#1C1C1E), brighter teal (#2FB39C text, #1F9C86 fills); illustrations keep a white backing. Appearance screen has Light / Dark / Automatic previews. Drawn for Home, Quiz, Study, reader, a miss, end of a mock, Settings root and Practice only. | DK_Home, DK_Quiz, DK_Study, DK_Reader, DK_Miss, DK_MockEnd, ST_DarkRoot, ST_DarkPractice, ST_Appearance | lib/core/ui/theme/app_colors.dart:45; theme_control.dart; spec 2026-08-01-modern-dark-theme-concept-design.md; DECISIONS "Last gaps" (Dark mode) and "Settings" (Appearance) |
| Text size follows only the phone's setting; rows switch layout above 1.0 scale. | Appearance has a Text size slider (lessons and questions use it); at the largest size rows grow and the value moves under the label. | ST_Appearance, ST_LargeText | lib/core/ui/components/settings_value_row.dart:53; data_row_tile.dart:49; DECISIONS "Settings" (Appearance) |
| Questions-sheet and mock-navigator sheets use default Material sheets (DraggableScrollableSheet in the mock). | Both stay as sheets but redrawn: five across (six in the mock, grouped by part, next part dimmed, answered is gray never right or wrong). | QV_Grid, MK_Sheet | quiz_page.dart:662-690; mock_start_route.dart:713-745; question_grid_sheet.dart |

## B. Missing from the design

| item | where it exists now | what it does for the student | nearest board |
|---|---|---|---|
| Tab-switch animation (glyph fills bottom to top over 400 ms; outgoing tab drains at once; skipped under reduce motion) | app_shell.dart:177-208; spec 2026-07-26-home-and-navigation-design.md Section 1 | Shows which tab is active | none (boards show the pill bar static) |
| Re-tapping the active tab returns it to its root screen; each tab keeps its own screen stack | app_shell.dart:28-31; router.dart:129 (StatefulShellRoute.indexedStack) | Lets a student jump back to the top of a tab | none (DECISIONS only says the Study tab remembers its open topic) |
| Pro-only route redirect: /plan/dossier/:mockId is a placeholder page ("Pro dossier: placeholder") and the only route that sends Free to /paywall?returnTo | router.dart:111-118, 254-259, 556-558 | Nothing visible; placeholder | none (MK_PastPro is the nearest Pro mock page) |
| /paywall route: a full-screen Try Pro flow (what Pro adds, plans, trial timeline, Restore in the app bar, Close, returnTo back to the screen that sent the student) separate from /settings/pro | router.dart:453-458; lib/features/paywall/presentation/paywall_page.dart:40-100, trial_timeline_page.dart, plans_page.dart | How a Free student reaches buying from a Pro button, and returns | ST_ProFree (route /settings/pro). DECISIONS "Home (APPROVED 1 Oct)" says how Free reaches the paywall "is still open: needs an in-between step" |
| Paywall store states: "Loading subscriptions...", "Google Play couldn't load subscriptions right now." + Try again, "Subscriptions aren't available right now.", "not available in this version" | paywall_page.dart:205-355 | Tells the student why prices are missing | ST_ProSubOffline (offline only) |
| Legacy redirects /more to /settings and /settings/subscription to /settings/pro | router.dart:467-470, 506-509 | Keeps old links and notification payloads working | none |
| Where a reminder or Wrapped notification lands on tap (route in payload, /quiz, /wrapped/:id; taps older than 4 hours go to /home) | lib/features/notifications/presentation/notification_tap_handler.dart:11-18; notifications_providers.dart:96; wrapped_trigger_notification_router.dart:29 | Opens the right screen from the phone's notification | none (O_Notify is the permission step only) |
| App fails to start: bootstrap errors (storage, content install, Firebase) only reach debugPrint and telemetry | lib/app/bootstrap.dart:100-111, 121-126 | Nothing is shown; the student sees a blank launch | SY_Error (covers widget errors on a running app, not a failed start) |
| Home load failure: "Could not load your home. Pull down to try again." with Try again | home_tab.dart:28-30, 66-69, 172-185 | Recovery when Home data fails | DP_Error (pattern only) |
| Quiz tab load failure: "Could not load your practice. Pull down to try again." | quiz_tab_home.dart:40-47 | Recovery when the Quiz tab fails | ST_Error (pattern only) |
| Quiz session failure with Retry (QuizFailure), and spec's "Couldn't save your answer, try again" when an answer fails to save | quiz_page.dart:502-508; spec 2026-05-17-quiz-engine-and-modes-design.md lines 564-565 | Recovery mid-session | none |
| Raw exception text shown to the student on load failure: "Error: $e" on What's included, Your record, mock review, mock session; "Error loading debrief: $e"; practice picker "Error: $e" | settings/presentation/pages/whats_included_page.dart:105; your_record_page.dart:23; mock_review_page.dart:85; mock_session_page.dart:337; lib/features/quiz/presentation/pages/debrief_page.dart:70; practice_picker_page.dart:85 | Currently leaks internals; a board must say what a failure looks like | ST_Error pattern |
| Other load-failure states with their own copy and no board: flagged list, quiz results, assessment results, topic ending, Change exam list, custom-track subjects | flagged_list_page.dart:37; quiz_results_page.dart:30; assessment_results_page.dart:42; topic_ending_page.dart:49; change_exam_page.dart:43; custom_track_subjects_step.dart:111 | Recovery on those screens | ST_Error pattern |
| Wrapped load failure and Shared links load failure | wrapped_reveal_page.dart:55; my_shared_cards_page.dart:26 | Recovery on Wrapped and Shared links | WR_Links (loaded/empty only) |
| Lesson search load failure "Could not load search results." | lib/features/lesson/presentation/widgets/search_results.dart:29-33 | Recovery in Study search | ST_NoMatch (empty only) |
| Section failures that hide silently (empty gap): Home tendencies, practice and up-next panels; Quiz session panel; progress "why you miss" and pace panels | home/presentation/widgets/tendencies_panel.dart:62; practice_panel.dart:40; up_next_panel.dart:51; quiz/presentation/widgets/session_panel.dart:67; progress/presentation/widgets/why_you_miss_section.dart:34; your_pace_panel.dart:78 | Quietly hides a card when its data fails | none |
| Assessment not ready state: "Assessment isn't ready yet" / "We're still adding questions for this exam..." / Back to Quiz | assessment_page.dart:176-183 | Tells the student the exam has no assessment content | HP_NoContent (Home only) |
| Mock start error screen: "Error" title, message, and "Discard saved mock" for a corrupt saved attempt | mock_exam/presentation/pages/mock_start_route.dart:604-625 | Lets a student escape a broken saved mock | MK_Discard (pause menu discard only) |
| Mock autosave failure snackbar "Could not save your mock progress." | mock_start_route.dart:541-545 | Warns the student that progress may not be saved | none |
| Onboarding exam-pick save failure snackbar "Couldn't save selection. Try again." with Retry | onboarding_picker_step.dart:44-58; spec 2026-05-16-onboarding-exam-selection-design.md lines 174, 222 | Recovery when the pick fails to save | O_Picker (loading, can't load, list only) |
| "Study first for better results" bottom sheet once, when starting today's quiz before reading any lesson: Study / Start quiz anyway | quiz_tab_home.dart:100-125, 233-280 | Nudges reading before quizzing, once | QZ_Tab (no sheet; sheets only where a board shows one, so the nudge has no container) |
| Sync conflict dialog after sign-in when both the phone and the account hold progress: Keep my account / Keep this device, cannot be dismissed | lib/features/settings/presentation/widgets/sync_reconciliation_gate.dart:20-60; lib/l10n/app_en.arb:12-25; spec 2026-05-16-firebase-auth-design.md lines 245-254 | Stops the app overwriting the wrong copy of the student's progress | L_Restore (restore steps only) and O_SignIn |
| Play in-app review prompt: asked once, only after a good finish, never within a cool-off after the paywall | lib/features/review_prompt/application/review_prompt_controller.dart:25-45; debrief_page.dart:118; paywall_page.dart:59; spec 2026-08-03-platform-foundations-design.md Section 8 | Store rating request at a good moment | none |
| "Flag removed" toast when un-flagging | quiz_page.dart:734-736; spec 2026-07-28-quiz-tab-design.md lines 657-658 | Confirms the unflag | QV_Flag (first-flag toast only) |
| Whether a closed service message stays closed, and whether a new message reopens it | n/a (no UI built); spec 2026-08-03-platform-foundations-design.md Section 5 | Avoids nagging after Close | HP_Service |
| Spec-only toasts never built: post-answer rating toast ("Good, next review in 4d"), "Signed out" snackbar after sign out, "Your study plan is being rebalanced" snackbar after an exam-date change | spec 2026-05-17-quiz-engine-and-modes-design.md D5 (lines 124-130); 2026-05-16-firebase-auth-design.md line 301; 2026-05-22-settings-account-design.md line 37 | Feedback after those actions (quiz toast would also reveal scheduling) | ST_Exam footer (plan rebuilds right away) for the third only |
| Offline spec rules: no connectivity banner or indicator, no blocking spinner on local data, last entitlement stands on network failure, failed entitlement refresh stays silent | spec 2026-08-03-offline-and-network-posture-design.md Sections 3, 5, 7 | Keeps studying and Pro working offline | L_Rules ("Offline" panel lists only sign-in, backup, purchases, deletion, share links) |
| Icons in the app with no IC_Final entry: globe (Icons.public) on the share privacy note, collections-bookmark on the Wrapped reveal bar, expand-less and expand-more on the topic scope list, drag-handle on bookmarks | wrapped/presentation/share_privacy_sheet.dart:65; wrapped_reveal_page.dart:40; core/ui/components/topic_scope_index.dart:258; lesson/presentation/widgets/bookmarks_sheet.dart:470 | Visual cues on those screens | IC_Final (reorder icon and caret-right cover the last two) |
| Flagged-questions list screen (list, Practice these, empty state "Flag anything you want to come back to / Go back") | router.dart:326-337; lib/features/quiz/presentation/pages/flagged_list_page.dart:30-70 | Lets a student review and practice flagged questions | QV_Sources names the door and where Done returns; no board draws the list |
| Quick-quiz route /quiz/quick/:examId and its Home entry "Try a quick quiz" (shown before the assessment) | router.dart:286-292; home_tab.dart:140-148 | Lets a student start a quiz without the assessment | ST_NoLessons ("Try a Quick Quiz"); HE_BeforeAssessment shows no such button |

## Route inventory: lib/app/router.dart (requested by the lead, appended outside the two lists)

Redirect rules (router.dart:70-120): update-required blocks every route first (SY_Update); age gate, exam choice and onboarding complete send to /onboarding (O_*); finished onboarding goes to /notifications/rationale then /home (O_Notify); only /plan/dossier is Pro-gated (see B).

| route | covering board(s) |
|---|---|
| /home (tab) | HP_*, HE_* (Home); notices HP_Service, HP_Trial |
| /study (tab) | ST_Map, ST_TopicOpen, ST_Search, ST_Pinned, ST_Loading, ST_Error, ST_NoLessons, ST_NoExam, BM_* |
| /quiz (tab) | QZ_*, QZE_*, QZS_*, MK_PastFreeOpen, MK_PastFreeLocked, MK_PastPro |
| /progress (4th tab) | Retired as a tab. Boards reuse /progress for Your performance (DT_*). No board draws the old Progress tab |
| /onboarding, /onboarding/custom/name, /onboarding/custom/subjects | O_Flow, O_Launch, O_Age, O_Consent, O_Picker, O_Custom, O_DateKnown, O_DateChange, O_DateToday, O_Days, O_Name |
| /notifications/rationale | O_Notify |
| /plan/dossier/:mockId | none (placeholder) |
| /progress/how-you-work | YO_*, YO3_Profiles, YO4_Picks |
| /progress/your-record | YR_*, YR_Wrapped, YR_WrappedFree, WR_History |
| /quiz/today/:examId, /quiz/resume/:examId, /quiz/practice/:examId/run, /quiz/retake/:examId, /quiz/inline/:examId/:lessonId | QV_* (one set of screens, QV_Sources); resume also QZ_Resume |
| /quiz/quick/:examId | ST_NoLessons only (see B) |
| /quiz/practice/:examId | QZ_Picker, QZS_*, QZE_* |
| /quiz/debrief/:attemptId | QN_*, QV_End*, QV_All |
| /quiz/flagged/:examId | QV_Sources (door only); no list board (see B) |
| /quiz/results/:attemptId | none; nothing in lib navigates to it, QuizResultsPage is also served at /review |
| /review | QV_All (reached from debrief_page.dart:294) |
| /quiz/mock/setup | MK_Setup, MK_SetupStrict, MK_SetupDCAT, MK_SetupCSE |
| /quiz/mock/start, /quiz/mock/resume/:attemptId | L_MockStart, MK_Paper and the mock-session boards, MK_PauseFlow |
| /quiz/mock/custom-setup | CM_Setup, CM_Wheel, CM_Breakdown, CM_Ceiling |
| /mock-exam | none; a placeholder stub opened from the old Progress tab (progress_page.dart:130). SCREENS.md lists /mock-exam as the route of the mock-session boards, but the real session runs through /quiz/mock/start |
| /mock/results/:attemptId | MK_Results, MK_ResultsFree, MK_Finale, MK_FinaleUPCAT |
| /mock/review/:attemptId | MK_Review*, MK_ReviewWrongFree, MK_ReviewQFree |
| /lesson/:lessonId | RD_* |
| /study/ending/:topicId | RD_TopicDone, RD_TopicShort, RD_DayDone, RD_DayEnd |
| /assessment/:examId, /assessment/:examId/results | AS_Question, AS_Picked, AS_Leave, AS_Results |
| /wrapped/:artifactId | WR_Mock, WR_Streak, WR_Topic, WR_Exam, WR_Share, WR_ShareExam, WR_ShareOffline (WR_Topic is the dropped weak-to-strong moment per the restart log) |
| /paywall | ST_ProFree and ST_Pro* (board route is /settings/pro); see B |
| /settings (pushed now, becomes tab) | ST_Root, ST_RootNoName, ST_RootSignedOut, ST_RootPro, ST_RootTrial, ST_DarkRoot |
| /settings/sessions | ST_Practice, ST_DarkPractice |
| /more, /settings/subscription | none (redirect aliases) |
| /settings/exam, /settings/exam/change, /settings/exam/included | ST_Exam*, ST_ExamSwitch*, ST_Included* |
| /settings/account, /settings/account/delete | ST_Account*, ST_Name, ST_Avatars, ST_SignOut, ST_DeleteAccount, L_Delete |
| /settings/pro | ST_Pro*, ST_PassEnded, ST_PassNoDate, ST_PassSoon, ST_RestoreDone, ST_RestoreNone, ST_SwitchUpgrade, ST_SwitchPassWarn |
| /settings/backup | ST_BackupDetails, ST_BackupNow, ST_BackupNowOffline, ST_BackupStates |
| /settings/about, /legal/:doc | ST_About, ST_Privacy (Terms looks the same), WR_Links, WR_LinkRemove, WR_LinksEmpty |
| /settings/_debug | none; debug builds only (DECISIONS "Settings": a Debug page exists in test builds only) |
| /update-required | SY_Update |
| Routes in boards with no router entry today | /plan (DP_*), Settings Appearance and Reminders subpages, Wrapped history ("Your Wrapped"), Shared links, Name screen, Home service notice |

## Bottom-sheet call sites (all, with board status)

| call site | sheet | board status |
|---|---|---|
| lib/core/ui/components/ink_sheet.dart:18 | showInkSheet wrapper used by the six sites below | wrapper retires with them |
| settings_home_page.dart:62 (name_sheet.dart:12) | Name | replaced by ST_Name (own screen) |
| settings_home_page.dart:80 (exam_date_sheet.dart:65) | Exam date | replaced by ST_ExamDate (in place) |
| settings_home_page.dart:106 (ordering_sheet.dart:20) | Session ordering | replaced by ST_Practice |
| settings_home_page.dart:133 (reminder_sheet.dart:16) | Reminder time | replaced by ST_Reminders |
| settings/presentation/pages/exam_page.dart:97 (carry_over_prompt.dart:16) | Carry over | replaced by ST_ExamDate row and ST_ExamSwitchCount |
| progress/presentation/widgets/performance_section.dart:179 (subject_scope_sheet.dart:28) | Subject scope | replaced by DT_SubjectTap |
| mock_exam/presentation/pages/custom_mock_setup_page.dart:182, 193 (value_wheel_sheet.dart:244, 273) | Questions and Time wheels | replaced by CM_Wheel (in place) |
| quiz/presentation/quiz_page.dart:662 | Questions grid | board shows a sheet: QV_Grid, QV_GridBack |
| mock_exam/presentation/pages/mock_start_route.dart:713 | Mock questions grid | board shows a sheet: MK_Sheet, MK_SheetCSE, QV_GridMock |
| lesson/presentation/widgets/lesson_contents_sheet.dart:14 (lesson_page.dart:262) | Reader contents | board shows a sheet: RD_Contents |
| lesson/presentation/widgets/bookmarks_sheet.dart:14 | Bookmarks (See all) | board shows a sheet: BM_Open, BM_Edit, BM_Empty (also has a deprecated onReorder, restart log baseline) |
| quiz/presentation/quiz_tab_home.dart:105 | "Study first" nudge | no board (see B) |

## Dialog and toast call sites (for the lead)

Dialogs: confirmation_dialog.dart:16 (used by quiz_page.dart:695 Leave this session, mock_session_page.dart:115 Real exams do not pause, mock_session_page.dart:135 End Part, pause_page.dart:35 Discard this mock); mock_session_page.dart:255 Leave mock; assessment_page.dart:151 Leave assessment; account_page.dart:119 Sign out; sync_reconciliation_gate.dart:30 conflict dialog (B). Boards: QV_Leave, MK_PauseWarn, MK_EndEarly, MK_Discard, AS_Leave, ST_SignOut.
Snackbars: practice_panel.dart:101, 116 (A); quiz_page.dart:716, 734 (flag); wrapped_reveal_page.dart:133 (A); mock_start_route.dart:543 (B); onboarding_picker_step.dart:47 (B). Inline success banner: bookmarks_sheet.dart:278 "N bookmarks removed" with Undo, covered by BM_Empty.

Not checked:
- Board HTML for boards outside my family (Home, Quiz, Settings, mock, Wrapped) were read only for the text needed to map routes and sheets, not for full content.
- Whether the in-flight design prototypes show an animation for the tab bar switch (MOTION.md has no tab-bar section; I did not run docs/design/tools/timeline.py).
- Settings, paywall, Wrapped and mock families' own gaps were not walked in full; rows above appear only where they touch shell, errors, offline, sheets, dialogs or toasts.
- Specs dated 2026-08-04 onward and the 2026-08-2x/09-xx specs were not read for toast or error behavior.
- docs/design/pipelines-handoff.md was not read.
