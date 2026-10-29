# Pantas web handoff to Flutter app: board map

Sources: HANDOFF.md (hard rules win), canvas.json titles and notes, the board HTML, shared/pantas.css, and the app at /Users/aedwon/Documents/Projects/Pantas-wt-staging-candidate-r1 (branch web/staging-candidate-r1). App paths below are relative to `lib/` unless they start with `/` (a route).

Verdicts: BUILD = screen/state exists in the app and needs the web layout. NEW-FEATURE = board needs something the app lacks. SKIP = not built (reason given). MOTION = animation spec, build last. Relative file names inherit their area folder: home → features/home/presentation, mock → features/mock_exam/presentation (pages/, widgets/), quiz → features/quiz/presentation, study and reader → features/lesson/presentation, settings → features/settings/presentation (pages/), onboarding → features/onboarding/presentation, `core/ui/...` is lib/core/ui. Mobile reference codes (for example HP_Day) are the board titles' own tags, kept as `[m: ...]`.

## 1. Board table (305 boards)

### Overview (no canvas page; baseline boards, prefix W_ / Main / K_) (13)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| Main | Home · one screen, no scroll: Today leads, the glance column sits beside it | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart + home_tab.dart | BUILD — Overview baseline: Home, Pro, mid-day (no separate HM board for it). Sidebar + Today column + glance column (X_Perf, X_More). |
| W_Study | Study · the map and an open topic side by side, instead of opening in place | /study · features/lesson/presentation/learn_tab_home.dart (StudyTabHome), widgets/study_map_entry.dart | BUILD — Only board of the Study map with an open topic side by side; SD_* and BM_* boards are its states. |
| W_Reader | Reader · a reading column, this lesson's sections in the margin, 5 of 11 in the bar; the pull-up becomes a Next card and | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart | SKIP — Older variant: same layout as RD_Contents (sample "Circles" lesson, 5 of 11). RD_Contents / RD_Real / RD_Focus supersede it. |
| W_QuizTab | Quiz tab · Today, the mock and other practice in one view | /quiz · features/quiz/presentation/quiz_tab_screen.dart | BUILD — Base Quiz tab (Pro, mid-day); QZ_* are its variants. |
| K_Home | (no title) | none (template with {{holes}}) | SKIP — Part template for Home (no title, no canvas page). HM_*/Main hold the real screens. |
| W_Question | A question · click to try it: pick, Check, and the explanation opens beside the question | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart + core/ui/components/new_design/question_card.dart | BUILD — Only static board of the question screen. Uses an older `.bar` instead of `.fbar`; build the bar from the .fbar boards (QS_*). |
| W_QRight | Checked, right · the column moves left and the explanation sits beside it; the bar turns light green | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart + core/ui/components/new_design/answer_reveal.dart, floating_bar.dart | BUILD — Checked right: column moves left, explanation beside it. Motion in RV_Reveal. |
| W_QMiss | A miss (Pro) · light red bar; the note sits in the explanation panel and number keys pick a reason | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart + quiz_note_editor.dart | BUILD — Miss (Pro): number keys pick a reason; viewer version is QN_Wrong. |
| W_QPassage | Reading passage · the passage stays on the left across its questions | quiz_page.dart + new_design/passage_card.dart | BUILD — Only board for the passage-left layout (schema field: passage). |
| W_SessionEnd | End of a session · the score leads, centred; Done right under it; then your mistakes, with See all 10 questions as the c | /quiz/debrief/:attemptId · features/quiz/presentation/quiz_session_end_page.dart, session_end_screen.dart | SKIP — Older variant of QS_EndPro / QS_EndFree (no Start Session 2 button). |
| W_Mock | Mock exam · the questions sheet becomes a panel that stays open | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) + core/ui/components/new_design/question_grid_sheet.dart | BUILD — Only board of answering with the questions panel open (MK_Paper and MK_Sheet are not exported). |
| W_MockResults | Mock results · score and breakdown side by side; past results below | /mock/results/:attemptId · pages/mock_results_page.dart, mock_results_route.dart | BUILD — Only board for Pro results with past results; MK_ResultsFree/First are variants. |
| W_Settings | Settings · a list and its page side by side; no pushing | /settings · features/settings/presentation/settings_home_page.dart | BUILD — List + page split view (app pushes pages on a stack). Base for all ST_* boards. |

### Onboarding (28)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| OB_Welcome | Welcome · Get Started only (replaces O_Launch: the browser shows its own splash) | /onboarding · features/onboarding/presentation/onboarding_page.dart · onboarding_welcome_step.dart | BUILD — OnboardingLaunchStep (native splash) not needed on web. |
| OB_Age | Birth year · type it or use the arrows; the wheel is gone [m: O_Age] | /onboarding · features/onboarding/presentation/onboarding_page.dart · onboarding_age_gate_step.dart | BUILD |
| OB_AgeBlocked | Under 13 · not available yet, Try a Different Year [m: O_Age] | onboarding_age_gate_step.dart | BUILD |
| OB_Terms | Terms and privacy · click to try: ticking the terms turns Continue on (all three O_Consent frames) | onboarding_consent_step.dart | BUILD |
| OB_PickerLoading | Exam picker · loading, only if slow [m: O_Picker] | onboarding/presentation/exam_picker_screen.dart | BUILD |
| OB_PickerError | Exam picker · could not load, Retry [m: O_Picker] | exam_picker_screen.dart | BUILD |
| OB_Picker | Exam picker · the list in three columns, UPCAT picked; Coming soon can't be picked [m: O_Picker] | exam_picker_screen.dart | BUILD — Board shows all exams; app filters to CSE on web (cseOnly = kIsWeb). |
| OB_PickerEmpty | Exam picker · no exams listed: Set Up My Own Exam [m: O_Custom] | exam_picker_screen.dart (onCustom) | BUILD |
| OB_CustomName | My exam isn't listed · its name [m: O_Custom] | /onboarding/custom/name · steps/custom_track_name_step.dart | BUILD |
| OB_CustomCover | My exam isn't listed · what it covers [m: O_Custom] | /onboarding/custom/subjects · steps/custom_track_subjects_step.dart | BUILD |
| OB_DateKnown | Exam date known · Is this your exam day? [m: O_DateKnown] | onboarding_exam_date_step.dart | BUILD |
| OB_DatePick | NEW · Different Date, nothing picked yet · Continue off until a month is picked | onboarding_exam_date_step.dart + core/ui/components/month_first_date_picker.dart | BUILD — Board marks "NEW". |
| OB_DateMonth | Month picked, no day · the month's days sit beside the months [m: O_DateKnown, O_DateChange] | onboarding_exam_date_step.dart | BUILD |
| OB_DateDay | Day picked · the line under the calendar names it [m: O_DateKnown, O_DateChange] | onboarding_exam_date_step.dart | BUILD |
| OB_DateYear | Next year · switching month clears the day [m: O_DateChange] | onboarding_exam_date_step.dart | BUILD |
| OB_DateThisMonth | This month, already started · past days gray, Today marked, plan from today [m: O_DateToday] | onboarding_exam_date_step.dart | BUILD |
| OB_DateToday | The exam is today · allowed; leads to the exam-day Home [m: O_DateToday] | onboarding_exam_date_step.dart | BUILD |
| OB_Days | Study days · six picked [m: O_Days] | onboarding_study_days_step.dart | BUILD |
| OB_DaysNone | Study days · none picked, Continue off [m: O_Days] | onboarding_study_days_step.dart | BUILD |
| OB_DaysTooLate | Study days · none fall before the exam [m: O_Days] | onboarding_study_days_step.dart | BUILD |
| OB_DaysSoon | Study days · exam under a week away, one calm line [m: O_Days] | onboarding_study_days_step.dart | BUILD |
| OB_Name | Your name · Done [m: O_Name] | onboarding_name_step.dart | BUILD |
| OB_Reminders | Reminders · daily time and follow up [m: O_Notify] | none · OnboardingStep.reminders auto-finishes (onboarding_page.dart) | NEW-FEATURE — No reminders UI, no daily time / follow-up, no browser permission. |
| OB_ReminderTime | Changing a time · a list opens under the field instead of the wheel [m: O_Notify] | none | NEW-FEATURE — Time list instead of wheel. |
| OB_Permission | The browser asks · its own prompt replaces the Android dialog [m: O_Notify] | none | NEW-FEATURE — Browser notification prompt state. |
| OB_Install | Parked for later · offer to install Pantas as an app (no mobile board) | none | SKIP — Board says "Parked for later" (PWA install offer); no mobile board. |
| OB_SignIn | Later · signing in from Settings, signed out [m: O_SignIn] | /settings/account · features/settings/presentation/pages/account_page.dart ("Continue with Google") | BUILD — Later: signing in from Settings. |
| OB_Restoring | Later · restoring your progress [m: O_SignIn] | settings sign-in restore · core/ui/components/steps_screen.dart (StepsScreen) | BUILD |

### Home (34)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| HM_Free | Home · Free (HP_Free): the same as Pro, with a small Pro tag on See all topics and lessons | /home · home_tab.dart + core/ui/components/pro_tag.dart | BUILD — Free variant of Main; Pro tag on See all topics and lessons. |
| HM_DayStart | The day · start: nothing done yet [m: HP_Day] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart | BUILD |
| HM_DayDone | The day · done: That's all for today, I Want to Advance [m: HP_Day] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart | BUILD — Done: That's all for today + I Want to Advance. |
| HM_Advanced | The day · advanced: today folds to one line, From tomorrow below [m: HP_Day] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart | BUILD — Advanced: today folds to one line, FROM TOMORROW list (exists in checklist). |
| HM_NoticeClosed | A notice, folded · one thin strip under the header; the whole strip opens it [m: HP_NoDate] | /home · widgets/home_notice_strip.dart, application/home_notices.dart, core/ui/components/notice_strip.dart | BUILD |
| HM_NoDate | Notice open · no exam date: today is reviews only [m: HP_NoDate] | /home · widgets/home_notice_strip.dart, application/home_notices.dart, core/ui/components/notice_strip.dart | BUILD |
| HM_NoDateModal | Add Exam Date · the onboarding picker in a dialog instead of a sheet [m: HP_NoDate] | /home · widgets/home_exam_date_sheet.dart (sheet becomes a dialog) | BUILD — Same picker as onboarding (OB_Date*) in a dialog. |
| HM_MonthOnly | Notice open · month only: pick the day right in the strip [m: HP_MonthOnly] | /home · widgets/home_notice_strip.dart, application/home_notices.dart, core/ui/components/notice_strip.dart | BUILD — Day pick in the strip. |
| HM_MonthOnlyPick | Pick the Day · the day picker in a dialog [m: HP_MonthOnly] | /home · widgets/home_exam_date_sheet.dart (sheet becomes a dialog) | BUILD |
| HM_Trial | Notice open · Pro trial ending [m: HP_Trial] | /home · widgets/home_notice_strip.dart, application/home_notices.dart, core/ui/components/notice_strip.dart (webTrialHomeNotice) | BUILD — Board copy says "You'll be charged ₱99 on Oct 16..." + Manage; app web copy is "You won't be charged", buttons See Pro / Got It. See contradictions. |
| HM_ProWelcome | Notice open · Welcome to Pro, once [m: HP_ProWelcome] | /home · widgets/home_notice_strip.dart, application/home_notices.dart, core/ui/components/notice_strip.dart | BUILD |
| HM_Service | Notice · service message: one line, close, nothing to open [m: HP_Service] | /home · widgets/home_notice_strip.dart, application/home_notices.dart, core/ui/components/notice_strip.dart (remote_flags.serviceMessage) | BUILD |
| HM_BeforeAssessment | State · before the assessment: week, greeting, the assessment card only [m: HE_BeforeAssessment] | /home · HomeTodayKind.assessment (home_tab.dart) → /assessment/:examId | BUILD |
| HM_ExamDay | State · exam day: an optional warm-up [m: HP_ExamDay] | /home · widgets/home_exam_day.dart | BUILD |
| HM_ExamPassed | State · exam date passed: Did you take UPCAT? [m: HP_ExamPassed] | /home · widgets/home_state_card.dart (HomeTodayKind in domain/home_today_view.dart) (HomeTodayKind.passed) | BUILD |
| HM_NoContent | State · no lessons for this exam yet [m: HP_NoContent] | /home · widgets/home_state_card.dart (HomeTodayKind in domain/home_today_view.dart) (HomeTodayKind.noContent) | BUILD — Board uses CSE-SP as the example. |
| HM_ManyLessons | Busy day · many lessons: Up next, then one Lessons row [m: HE_ManyLessons] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart | BUILD — Up next + one Lessons row (exists). |
| HM_LessonsPanel | A row opened · Lessons: a panel from the right instead of a sheet [m: HE_ManyLessons] | /home · home_today_screen.dart _contents() → core/ui/components/today_questions.dart (TodayQuestionsSheet, a bottom sheet today) | BUILD — Right-hand drawer (`.drawer` 440px). Footer "Continue Lesson" button is full width: see contradictions. |
| HM_ReviewsPanel | A row opened · Reviews, by session [m: HE_ManyLessons] | /home · home_today_screen.dart _contents() → core/ui/components/today_questions.dart (TodayQuestionsSheet, a bottom sheet today) | BUILD — Reviews by session; full-width footer button, as above. |
| HM_NewQPanel | A row opened · New questions, by lesson [m: HE_ManyLessons] | /home · home_today_screen.dart _contents() → core/ui/components/today_questions.dart (TodayQuestionsSheet, a bottom sheet today) | BUILD — New questions by lesson; full-width footer button, as above. |
| HM_BackAfterBreak | Back after missed days · one calm line; reviews split into sessions [m: HE_BackAfterBreak] | /home · HomeDayNote.welcomeBack (domain/home_day_note.dart) | BUILD |
| HM_CarryOver | Unfinished items carried into today [m: HE_CarryOver] | /home · HomeDayNote.carried | BUILD |
| HM_Resume | A lesson left halfway · Resume Lesson [m: HE_Resume] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart ("Resume Lesson") | BUILD |
| HM_LongTitle | Long lesson titles truncate to one line [m: HE_LongTitle] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart | BUILD — One-line truncation. |
| HM_NothingDue | Nothing due · everything covered [m: HE_NothingDue] | /home · widgets/home_state_card.dart (HomeTodayKind in domain/home_today_view.dart) (HomeState.nothingDue) | BUILD |
| HM_NothingDueReview | Nothing due · review-only stretch [m: HE_NothingDueReview] | /home · widgets/home_state_card.dart (HomeTodayKind in domain/home_today_view.dart) (HomeState.reviewOnly) | BUILD |
| HM_DayOff | Day off · streak safe; advance only if it adds something [m: HE_DayOff] | /home · widgets/home_state_card.dart (HomeTodayKind in domain/home_today_view.dart) (HomeState.dayOff) | BUILD |
| HM_ReviewWeek | Today done, review-only week · no advance [m: HE_ReviewWeek] | /home · HomeDoneNote.reviewWeek (domain/home_today_view.dart) | BUILD |
| HM_LastDay | Today done, last study day · no advance [m: HE_LastDay] | /home · HomeDoneNote.lastDay | BUILD |
| HM_AdvanceAgain | Finished tomorrow's too · the offer returns [m: HE_AdvanceAgain] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart (canAdvance → onAdvance) | BUILD |
| HM_MockDay | Mock day · the mock leads [m: HE_MockDay] | /home · application/home_day_extras.dart (mock row), checklist | BUILD |
| HM_MockMoved | Skipped mock · moved to the next study day [m: HE_MockMoved] | /home · HomeDayNote.mockMoved | BUILD |
| HM_MockDropped | Skipped mock · moved even to the day before the exam [m: HE_MockDropped] | /home · HomeDayNote.mockMoved; features/roadmap/domain/mock_day.dart (day-before-exam rule) | BUILD |
| HM_Everything | Mock day, after a break, lots of lessons [m: HE_Everything] | /home · features/home/presentation/home_today_screen.dart + widgets/home_today_checklist.dart | BUILD — Combination: mock day + welcome back + many lessons. |

### Parts (3)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| X_Side | Part · the sidebar every main screen uses (props: active, plan) | none · lib/features/shell/presentation/app_shell.dart has only AppNavBar (bottom bar) | BUILD — New web sidebar; replaces the bottom nav on wide screens. Props: active, plan, exam, person. |
| X_Perf | Part · Your performance on Home (prop: plan) | /home · widgets/home_performance_card.dart, home_performance_section.dart | BUILD — Glance card; Pro/Free variants. |
| X_More | Part · More about you on Home (prop: plan) | /home · home_tab.dart "More about you" rows → /record, /tendencies | BUILD — Two rows. |

### Plan and performance (19)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| PL_Plan | Your plan · Pro: weeks on the left, history beside them [m: DP_PlanA, DP_Drill] | /plan · features/home/presentation/plan_screen.dart, plan_page.dart | BUILD — Pro: weeks left, history beside. |
| PL_Week | A week opened · it takes the history column; Esc or × goes back [m: DP_Week] | /plan/week/:start · PlanWeekScreen (plan_screen.dart) | BUILD — Opens in the history column; Esc/× back. |
| PL_WeekCustom | A week with fewer study days · rest days dim [m: DP_WeekCustom] | /plan/week/:start | BUILD — Rest days dimmed. |
| PL_Day | A day opened · lessons can be read early, right here [m: DP_Day] | /plan/day/:date · PlanDayScreen (plan_day_page.dart) | BUILD |
| PL_DayRead | Read a lesson early · the reader slides in from the right; Done ticks it on its day [m: DP_DayRead] | /plan/day/:date → /lesson/:id with LessonDayContext (study_routes.dart, reader_transition.dart) | BUILD — Reader slides in from the right in a drawer. |
| PL_DayPast | A past day from the week strip · a popover, read-only; Esc closes [m: DP_DayPast] | /plan/day/:date (read-only) | BUILD — Popover from the week strip (core/ui/components/week_strip.dart). |
| PL_Free | Your plan · Free: today and the exam only; weeks and history are Pro [m: DP_PlanFree] | /plan · features/home/presentation/plan_screen.dart, plan_page.dart | BUILD — Free: today and exam only. |
| PL_Error | Your plan · could not load [m: DP_Error] | /plan · features/home/presentation/plan_screen.dart, plan_page.dart | BUILD |
| PF_Subjects | Your performance · Pro, Subjects: one wide list, the score stays in the header [m: DT_TopicsA] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart | BUILD |
| PF_SubjectOpen | A subject opened · its topics unfold in place instead of a new screen [m: DT_SubjectTap] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart | BUILD — Topics unfold in place. |
| PF_Topics | Topics view · filter and sort sit beside the switch [m: DT_TopicsView] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart | BUILD |
| PF_Lessons | Lessons view [m: DT_LessonsView] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart | BUILD |
| PF_Filter | Pick a subject · a menu instead of a sheet; the list filters as you pick [m: DT_FilterFlow] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart (All subjects filter) | BUILD — Menu instead of sheet. |
| PF_Sort | Sorting · the three states become one menu; mobile cycled them on one button [m: DT_SortFlow] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart + core/ui/components/sort_cycle_button.dart | BUILD — Three-state cycle becomes one menu. |
| PF_Topic | A topic opened · a panel from the right, the list stays in view [m: DT_Topic] | /performance/topic/:topicId · topic_detail_page.dart | BUILD — Right panel; list stays. |
| PF_Free | Your performance · Free: subjects only; Topics, Lessons and a subject click lead to Pro [m: DT_Free, DT_SubjectTapFree] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart | BUILD |
| PF_Error | Your performance · could not load [m: DT_Error] | /performance · features/home/presentation/performance_screen.dart, performance_page.dart | BUILD |
| PL_History | History · full page, one readable column [m: DP_History] | /plan · features/home/presentation/plan_screen.dart, plan_page.dart (History section; no own route) | BUILD — Full-page History needs a route or a pane; app has it only as a section of the plan list. |
| PL_HistoryEnd | History · the end [m: DP_HistoryEnd] | /plan · features/home/presentation/plan_screen.dart, plan_page.dart (History section) | BUILD — See more → end. |

### More about you (record, tendencies) (10)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| MY_Record | Your record · Pro: totals and the line on the left, mocks and Wrapped beside them [m: YR_Full, YR_Wrapped] | /record · features/home/presentation/record_screen.dart, record_page.dart | BUILD — Contains a "Your Wrapped" row: hide (deferred). App already hides it (wrappedRecordRowProvider = null). |
| MY_RecordFree | Your record · Free: the Wrapped row carries a Pro tag [m: YR_WrappedFree] | /record · features/home/presentation/record_screen.dart, record_page.dart | BUILD — Wrapped row with Pro tag: hide, Wrapped deferred. |
| MY_RecordFirst | Your record · first week: no mocks, no line yet [m: YR_FirstWeek] | /record · features/home/presentation/record_screen.dart, record_page.dart | BUILD |
| MY_RecordRest | Your record · the streak crossed a rest day, so no since date [m: YR_RestDay] | /record · features/home/presentation/record_screen.dart, record_page.dart | BUILD — Has a Wrapped row: hide. |
| MY_TendPro | Your tendencies · Pro: the profile card, then findings two by two [m: YO_Pro] | /tendencies · features/home/presentation/tendencies_screen.dart, tendencies_page.dart | BUILD |
| MY_TendNew | Your tendencies · Pro, first week: nothing clear yet; each card says what unlocks it [m: YO_ProNew] | /tendencies · features/home/presentation/tendencies_screen.dart, tendencies_page.dart | BUILD |
| MY_TendFree | Your tendencies · Free: the profile is free; the findings show their shape only [m: YO_Free] | /tendencies · features/home/presentation/tendencies_screen.dart, tendencies_page.dart | BUILD |
| MY_TendError | Your tendencies · could not load [m: YO_Error] | /tendencies · features/home/presentation/tendencies_screen.dart, tendencies_page.dart | BUILD |
| MY_Profiles | Profile card · all 12 labels at web size [m: YO3_Profiles] | features/metrics/archetypes/archetype_catalog.dart (12 labels, same as app) | BUILD — Reference of all 12 profile cards. |
| MY_Pictures | Tendency pictures · clear, and before it's clear [m: YO4_Picks] | /tendencies · features/home/presentation/tendencies_screen.dart, tendencies_page.dart (finding pictures) | BUILD — Clear vs not-yet-clear shapes. |

### Study and the reader (30)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| SD_SearchRecent | Search · Ctrl K from anywhere opens it over the page; recent lessons first [m: ST_Search] | /study search · widgets/search_field_bar.dart, search_results.dart, application/lesson_search_providers.dart | BUILD — Ctrl K overlay is new; app has an inline search. |
| SD_Search | Search · results as you type, matches highlighted, the first one ready for Enter [m: ST_Search] | /study search · widgets/search_field_bar.dart, search_results.dart, application/lesson_search_providers.dart | BUILD |
| SD_NoMatch | Search · nothing matched [m: ST_NoMatch] | /study search · widgets/search_field_bar.dart, search_results.dart, application/lesson_search_providers.dart | BUILD |
| SD_MapEmpty | Study · no bookmarks yet: one quiet line where they would be [m: ST_MapEmpty] | /study · features/lesson/presentation/learn_tab_home.dart (StudyTabHome), widgets/study_map_entry.dart | BUILD |
| SD_NoLessons | Study · no lessons for this exam yet [m: ST_NoLessons] | /study · features/lesson/presentation/learn_tab_home.dart (StudyTabHome), widgets/study_map_entry.dart | BUILD |
| SD_Loading | Study · loading, only if slow: shapes pulse in place [m: ST_Loading] | /study · features/lesson/presentation/learn_tab_home.dart (StudyTabHome), widgets/study_map_entry.dart + core/ui/components/loading_shapes.dart | BUILD |
| BM_Open | Bookmarks · See all opens a panel from the right (Recent first); click outside or Esc closes [m: BM_Open] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart | BUILD — See all → right panel. |
| BM_Order | Bookmarks · Recent, Oldest, By subject, Custom; By subject groups them [m: BM_Order] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart | BUILD |
| BM_Custom | Bookmarks · drag a row by its grip and the order switches to Custom; Reset order appears [m: BM_Edit, BM_Order] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart | BUILD |
| BM_Edit | Bookmarks · Edit: the switch dims, select rows, Remove [m: BM_Edit] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart | BUILD |
| BM_Removed | Bookmarks · removed, with Undo in a toast [m: BM_Edit] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart + core/ui/components/toast.dart | BUILD |
| BM_Empty | Bookmarks · everything removed: the empty panel, Undo still offered [m: BM_Empty] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart | BUILD |
| BM_One | Bookmarks · only one: no sort switch, no grips [m: BM_One] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart | BUILD |
| BM_Keyboard | Bookmarks · no dragging needed: focus a row, Alt ↑ / Alt ↓ moves it, and the screen reader says where it went [m: BM_Screen] | /study · features/lesson/presentation/widgets/bookmarks_section.dart, bookmarks_sheet.dart, domain/models/bookmark_order.dart | BUILD — Alt ↑/↓ move; app has Move up/Move down but no key binding. |
| BM_MarkTeal | Bookmark · grey at rest; B or a click pops it teal like a check; again, it empties at once [m: BM_MarkTeal] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart (bookmark mark in reader bar) | BUILD — B key; no key bindings exist in the app. |
| RD_RealScroll | Reader · scrolled: the title has moved into the bar beside 1 of 5; the outline marks Crust [m: RD_RealScroll] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart | BUILD — Title fades into the bar. |
| RD_Figure | Reader · click an illustration: a lightbox; scroll or + − zooms the labels, Esc closes [m: RD_Figure] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart + core/ui/components/content_renderer.dart (lightbox) | BUILD |
| RD_Resume | Resume · the lesson opens where you left off, with a quiet way back to the top [m: RD_Resume] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart (?resume=true) | BUILD — Uses the sample "Circles" lesson. |
| RD_Error | Reader · could not load the lesson [m: RD_Error] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart | BUILD |
| RD_DayDone | Ending · a finished day: one line, back to Home [m: RD_DayDone] | lesson_page.dart day-ending (widgets/ending_content.dart) | BUILD |
| RD_TopicDone | Ending · a finished topic: the plate, and the next topic beside it [m: RD_TopicDone] | /study/ending/:topicId · pages/topic_ending_page.dart | BUILD |
| RD_TopicShort | Ending · a topic stopped short: the plate, what's still unread, then the next topic [m: RD_TopicShort] | /study/ending/:topicId | BUILD |
| RD_Focus | Focused reader · the top of a lesson: only 1 of 5 in the bar; the margin outlines this lesson (the reference for every r | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart | BUILD — Declared reference for every reader board. |
| RD_FocusOpen | Focused reader · 1 of 5 clicked: the topic's lessons drop down; click outside or Esc closes | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart + widgets/lesson_contents_sheet.dart | BUILD — Topic lessons dropdown. |
| RD_FocusMotion | Motion · the top bar: 1 of 5 at rest, the lesson title fades in over the first 90px (as on mobile), then hides on scroll | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart + widgets/reader_bar.dart (90px/120px logic already there) | MOTION |
| RD_ImageFail | Reader · an illustration fails: the frame keeps its place, Try Again inside it [m: RD_ImageFail] | core/ui/components/content_renderer.dart, lesson_svg.dart | BUILD |
| RD_Contents | Reader from Study · this lesson's sections in the margin, 4 of 8 in the bar; the end offers the next one, → to go [m: RD_Co] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart | BUILD — Sample "Circles" content; margin outline derives from h2 blocks. Superseded in content by RD_Real but layout is the same. |
| RD_Plan | Reader from Home · 2 of 2 in the bar spans the day, not the topic; next is Reviews [m: RD_Plan] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart with LessonDayContext | BUILD — Bar "2 of 2" spans the day; back label Home. |
| RD_DayEnd | Reader from Home · the day's last lesson: the end card finishes today [m: RD_DayEnd] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart | BUILD |
| RD_Real | Reader · a real lesson, full length: one 680px column, this lesson's sections beside it [m: RD_Real] | /lesson/:lessonId · features/lesson/presentation/lesson_page.dart, widgets/reader_bar.dart, widgets/reader_rail.dart | BUILD — Full-length real lesson, 680px column: layout reference. |

### Quiz (39)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| QZ_Done | Quiz · today's questions done [m: QZ_Done] | /quiz · features/quiz/presentation/quiz_tab_screen.dart | BUILD |
| QZ_First | Quiz · before the assessment [m: QZ_First] | /quiz · features/quiz/presentation/quiz_tab_screen.dart ("First, a short assessment") | BUILD |
| QZ_Free | Quiz · Free: the mock is waiting out its 14 days [m: QZ_Free] | /quiz · features/quiz/presentation/quiz_tab_screen.dart | BUILD — Mock waiting out its 14 days. |
| QZ_Resume | Quiz · a session left partway: Resume or discard; the mock and Customize your own wait [m: QZ_Resume] | /quiz · features/quiz/presentation/quiz_tab_screen.dart (Resume / Discard) | BUILD |
| CZ_None | Customize your own · nothing picked: the summary asks for a pick; Start is off [m: QZE_None] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_Picker | Customize your own · pick a topic for all of it, the caret for its lessons; the summary beside it replaces the floating | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD — Summary beside the tree (floating summary today). |
| CZ_TotalTime | Total time · you set the time, questions follow, split evenly by lesson [m: QZS_1c] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_Adjust | Adjust · set the split by hand with − and +; Reset goes back to even [m: QZS_1d] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_One | Edge · one lesson [m: QZE_One] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_Many | Edge · 8 lessons: one row each; the list scrolls past five [m: QZE_Many] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_ManyTime | Edge · 8 lessons on Total time: the rows show the uneven split [m: QZE_ManyTime] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_Short | Edge · too little time for 8 lessons: times that can't give every lesson a question are struck out [m: QZE_Short] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_RunsShort | Edge · a lesson has fewer questions than asked: its row shows what it has; the total drops [m: QZE_RunsShort] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| CZ_Long | Edge · a very long quiz [m: QZE_Long] | /quiz/practice/:examId · features/quiz/presentation/practice_picker_screen.dart, core/ui/components/scope_picker.dart | BUILD |
| QS_Figure | A question with a figure · it sits on a white card between the question and the choices [m: QV_Figure] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart | BUILD |
| QS_Long | Long content · long choices wrap; the page keeps room under the last so the bar never covers it [m: QV_Long] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart | BUILD |
| QS_Flag | Flag · in the bar or F, before or after answering; pops teal; the first time, a toast with Undo [m: QV_Flag] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart + question_flag_providers.dart, toast.dart | BUILD — F key; no key bindings exist. |
| QS_Grid | Questions · click the counter (or G): a grid above it; the dark edge is where you are [m: QV_Grid] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart + new_design/question_grid_sheet.dart | BUILD — G key; popover over the bar. |
| QS_GridBack | Looking back at 2 · read-only; the dark edge moves to 2, its color stays; Back to 4 returns [m: QV_Grid, QV_GridBack] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart + question_grid_sheet.dart | BUILD |
| QS_Last | The last question · once checked, Next becomes Finish [m: QV_Last] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart | BUILD — Next becomes Finish. |
| QS_Leave | Leaving · × or Esc asks once; nothing is lost either way [m: QV_Leave] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart + core/ui/components/centered_dialog.dart | BUILD |
| QS_MissFree | A miss (Free) · the same, with the note on the answer only [m: QV_MissFree] | /quiz/{today,resume,quick,practice/run,retake,inline}/:examId · features/quiz/presentation/quiz_page.dart | BUILD |
| QS_EndPro | End of a session (Pro) · the score centred, the buttons right under it; another session waits, so Start Session 2 leads | /quiz/debrief/:attemptId · features/quiz/presentation/quiz_session_end_page.dart, session_end_screen.dart | BUILD — Newest end screen (Start Session 2 leads). |
| QS_EndFree | End of a session (Free) · the same, without the notes invitation [m: QV_EndFree] | /quiz/debrief/:attemptId · features/quiz/presentation/quiz_session_end_page.dart, session_end_screen.dart | BUILD |
| QS_EndLow | Many mistakes · the first three, then See all 8 mistakes [m: QV_EndLowB] | /quiz/debrief/:attemptId · features/quiz/presentation/quiz_session_end_page.dart, session_end_screen.dart | BUILD |
| QS_EndPerfect | All ten right · the ring closes and the mistakes section isn't there [m: QV_EndPerfectB] | /quiz/debrief/:attemptId · features/quiz/presentation/quiz_session_end_page.dart, session_end_screen.dart | BUILD |
| QS_All | See all questions · in the order you answered; each opens on its own [m: QV_All] | /quiz/all/:attemptId · quiz_session_end_page.dart | BUILD |
| QS_Sources | Where a quiz starts · one set of screens; only the end line and where Done returns change [m: QV_Sources] | quiz_routes.dart entry points (flow map) | SKIP — Reference/flow note board; no new screen. |
| QN_Correct | Viewer · a right answer: light green, ← → step through, the counter in the middle [m: QN_Correct] | /quiz/viewer/:attemptId · quiz_review_page.dart, quiz_question_viewer.dart, quiz_note_editor.dart | BUILD |
| QN_WrongFree | Viewer · a wrong answer (Free): light red, no note [m: QN_WrongFree] | /quiz/viewer/:attemptId · quiz_review_page.dart, quiz_question_viewer.dart, quiz_note_editor.dart | BUILD |
| QN_Wrong | Viewer · a wrong answer (Pro): the reasons are already open in the panel; Add Note stays off until you pick [m: QN_Wrong, Q] | /quiz/viewer/:attemptId · quiz_review_page.dart, quiz_question_viewer.dart, quiz_note_editor.dart | BUILD |
| QN_OwnWords | Type my own · a field opens under the reasons; saved as Other with your words [m: QN_OwnWords] | /quiz/viewer/:attemptId · quiz_review_page.dart, quiz_question_viewer.dart, quiz_note_editor.dart | BUILD |
| QN_EditNote | Changing a note · your note is marked; Update stays off until you pick another; Remove clears it [m: QN_EditNote] | /quiz/viewer/:attemptId · quiz_review_page.dart, quiz_question_viewer.dart, quiz_note_editor.dart | BUILD |
| QN_Report | Report · from the top right, a small form drops down; X or Esc closes; drag its header to move it; Send [m: QN_Report] | core/ui/components/report_form.dart | BUILD — Draggable header (note qnDrag) is new; app form is a FloatingBar panel, not draggable; its offline line is inside the panel. |
| QN_ReportSent | Report sent · a soft line of thanks just left of the report icon, then it fades; the icon stays teal [m: QN_Report] | report_form.dart + quiz_question_viewer.dart | BUILD |
| QN_ReportAgain | Report again · the icon is teal, the form opens as usual with a line saying you reported it before [m: QN_ReportAgain] | report_form.dart | BUILD |
| QN_ReportLimit | Report, daily limit · the form opens but says why it can't send today [m: QN_ReportLimit] | report_form.dart (ReportResult.dailyLimit) | BUILD |
| QN_ReportOffline | Report with no connection · a soft line left of the report icon says it is saved and will send once online [m: QN_ReportOff] | report_form.dart (queue) | BUILD |
| RV_Reveal | Answer reveal · Right and Not quite: pick, Check, the result settles, then the explanation slides in beside the question | core/ui/components/new_design/answer_reveal.dart | MOTION — Keyframes in the board <style>. |

### Mock exam (35)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| MK_Setup | Before you start · sections, items and time; how it runs; strict mode as a switch, off [m: MK_Setup] | /quiz/mock/setup · features/mock_exam/presentation/pages/mock_setup_page.dart | BUILD |
| MK_SetupStrict | Strict mode on · the switch starts from Settings and can be changed here [m: MK_SetupStrict] | /quiz/mock/setup · features/mock_exam/presentation/pages/mock_setup_page.dart | BUILD |
| MK_SetupCSE | One block (CSE Professional) · items per subject, no time per subject; counts are placeholders until sourced [m: MK_SetupCS] | /quiz/mock/setup · features/mock_exam/presentation/pages/mock_setup_page.dart | BUILD — Counts are placeholders until sourced (board title). |
| MK_SetupDCAT | An exam the app can't fully include (DCAT) · the note says what the mock leaves out [m: MK_SetupDCAT] | /quiz/mock/setup · features/mock_exam/presentation/pages/mock_setup_page.dart | BUILD — Note says what the mock leaves out (app: unscoredItems line). |
| MK_Proctor | The proctor · “10 minutes left in this subject” takes the place of the line under the clock for 2.5 seconds, with three short sounds, then goes [m: MK_Proctor] | pages/mock_session_page.dart + proctor_toast.dart | BUILD — Board: 2.5 s, three sounds, replaces the line under the clock. App: 8 s ProctorToast with haptic. See contradictions. |
| MK_FiveMin | Under 5 minutes · the time bar and clock turn amber [m: MK_FiveMin] | clock_rule.dart (ClockUrgency.closing, amber) | BUILD |
| MK_LastMinute | The last minute · the time bar and clock turn red [m: MK_LastMinute] | clock_rule.dart (ClockUrgency.last, red) | BUILD |
| MK_LastQ | The last question of a part · the bar stays the same; → asks whether to end the part [m: MK_LastQ] | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) | BUILD |
| MK_LastQStrict | The last question, strict on · no Pause; → is dimmed and a quiet line says why [m: MK_LastQStrict] | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) | BUILD |
| MK_EndEarly | Ending a part early · time left and blanks; the time doesn't carry over [m: MK_EndEarly] | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) ("End Part N now?") | BUILD |
| MK_Between | Time is up · the part's questions as shaded circles (blanks stand out), then the parts with the next one marked [m: MK_Betw] | part_transition_page.dart | BUILD |
| MK_PartEnded | A part ended early · the same screen, titled “Part 3 ended.” [m: MK_PartEnded] | part_transition_page.dart | BUILD |
| MK_NavHidden | Question list hidden · the question and the bar re-centre in the freed space; a slim tab at the middle of the left edge brings the list back | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) | BUILD — Hide/show list with edge tab and peek is new layout behavior; app has a counter + grid sheet only. |
| MK_NavMotion | Try it · press Play, then the icon beside Questions to hide the list and the edge tab to bring it back | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) | MOTION — Demo of MK_NavHidden; spec in note mkNav and handoff Motion. |
| MK_PauseWarn | Before pausing · a warning with “Don't show this again”; once ticked, Pause (or P) goes straight through [m: MK_PauseWarn,] | pause_page.dart + application/mock_exam_preferences.dart ("Don't show again") | BUILD |
| MK_Paused | Paused · the hourglass holds as much sand on top as there is time left in the part (here 21 of 75 min), and tips now and then [m: MK_PauseA] | pause_page.dart + mock_hourglass.dart | BUILD |
| MK_Discard | Discarding · the only destructive step in the mock, so a red confirm [m: MK_Discard] | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) ("Discard This Mock") | BUILD — Red confirm. |
| MK_SheetCSE | One block (CSE) · the whole paper in one grid, blanks as empty circles; Submit the Exam lives in the panel [m: MK_SheetCSE] | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) (one block, "Submit the Exam") | BUILD |
| MK_SubmitCSE | One block · → on the last question, or Submit, asks; time left and blanks [m: MK_SubmitCSE] | /quiz/mock/start · pages/mock_session_page.dart (web: pages/server_mock_route.dart) | BUILD |
| MK_PauseMotion | Pause, animated · press Play, then Pause: the clock is ticking; the hourglass drops in with sand running, the last grains fall and the clock freezes, Paused opens above the time, then everything glides home; the frozen time blinks. Resume reverses it and the clock ticks on | pause_page.dart + mock_hourglass.dart | MOTION — Spec in handoff Motion. |
| MK_FinaleUPCAT | The end, UPCAT (right minus ¼ of each wrong) · press Play: the scan marks right teal and wrong red; the reds drop into their own ball while the right ones gather into the green; green lands, the ring draws and the score rolls to 68.4; then red strikes the tip, takes the strip back and it rolls down to 61.2 [m: MK_FinaleUPCAT] | widgets/cse_mock_finale.dart (has the no-deduction version only) | MOTION — No red-ball / 68.4→61.2 deduction variant in the app (mock_results_page.dart only prints "171 correct, minus 18 wrong"). |
| MK_Finale | The end, no deduction · press Play: the scan marks the right ones; the rest fade and the right ones gather into one ball, which lands on the ring; the ring draws and the score rolls up to 68.4; the page builds and Today joins past results [m: MK_Finale] | widgets/cse_mock_finale.dart, cse_finale_motion.dart, cse_finale_tracks.dart | MOTION — App finale is the mobile 13-column booklet geometry. |
| MK_ResultsFree | Your score, Free · the same; a quiet line says how long the questions stay open [m: MK_ResultsFree; W_MockResults on Overvi] | /mock/results/:attemptId · pages/mock_results_page.dart, mock_results_route.dart | BUILD |
| MK_ResultsFirst | Your score, first mock · no past results yet, so that card isn't there [m: MK_Results] | /mock/results/:attemptId · pages/mock_results_page.dart, mock_results_route.dart | BUILD |
| MK_Forfeit | Not finished (strict on, left the page) · the score still shows with a calm line; no comparison [m: MK_Forfeit] | /mock/results/:attemptId · pages/mock_results_page.dart, mock_results_route.dart ("Not finished") | BUILD |
| MK_PastPro | From your record, Pro · the whole results screen again, every question [m: MK_PastPro] | /mock/results/:attemptId (from /record) | BUILD |
| MK_PastFreeOpen | From your record, Free, before the next mock opens · the questions still open, with the date they close [m: MK_PastFreeOpen] | /mock/results/:attemptId | BUILD |
| MK_PastFreeLocked | From your record, Free, after the next mock opens · score and breakdown stay; the questions need Pro [m: MK_PastFreeLocked] | /mock/results/:attemptId | BUILD |
| MK_ReviewWrong | All questions · Wrong opens first: wrong and blank by part, the number in red; Finish the Notes on top [m: MK_ReviewWrong] | /mock/review/:attemptId · pages/mock_review_page.dart, core/ui/components/review_list.dart | BUILD |
| MK_ReviewWrongFree | All questions, Free · Wrong without the notes prompt [m: MK_ReviewWrongFree] | /mock/review/:attemptId · pages/mock_review_page.dart, core/ui/components/review_list.dart | BUILD |
| MK_ReviewAll | All questions · All: every question in order, by part [m: MK_ReviewAll] | /mock/review/:attemptId · pages/mock_review_page.dart, core/ui/components/review_list.dart | BUILD |
| MK_ReviewFlagged | All questions · Flagged: the offer to save them sits on top [m: MK_ReviewFlagged] | /mock/review/:attemptId · pages/mock_review_page.dart, core/ui/components/review_list.dart ("Save All N") | BUILD |
| MK_ReviewQ | A row opened · the same viewer as quizzes, ← → through the tab you came from; the note card waits in the panel [m: MK_Revie] | /mock/review/:attemptId · pages/mock_review_page.dart, core/ui/components/review_list.dart (viewer) | BUILD |
| MK_ReviewQFree | A row opened, Free · the right answer and its explanation, no note [m: MK_ReviewQFree] | /mock/review/:attemptId · pages/mock_review_page.dart, core/ui/components/review_list.dart | BUILD |
| MK_ReviewBlank | A blank one opened · no pick shown, only the right answer; the note asks why it was left blank [m: MK_ReviewBlank] | /mock/review/:attemptId · pages/mock_review_page.dart, core/ui/components/review_list.dart | BUILD |

### Settings (includes paywall, and two Study state boards) (58)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| ST_Account | Settings opens on the profile · Account and backup, Free: Pantas ID to copy; backup is this browser only [m: ST_Root, ST_Ac] | /settings/account · features/settings/presentation/pages/account_page.dart | BUILD |
| ST_AccountPro | Account and backup, Pro · Saved up top, when it last ran, details behind a row; Pantas Pro reads Yearly [m: ST_AccountPro,] | /settings/account · features/settings/presentation/pages/account_page.dart | BUILD |
| ST_AccountIDCopied | Pantas ID clicked · copied; the row says Copied with a check for 2 seconds [m: ST_AccountIDCopied] | /settings/account · features/settings/presentation/pages/account_page.dart ("Copied") | BUILD |
| ST_AccountIDWait | Pantas ID not made yet · offline since signing in: Not ready yet [m: ST_AccountIDWait] | /settings/account · features/settings/presentation/pages/account_page.dart ("Not ready yet") | BUILD |
| ST_AccountOut | Not signed in · the profile reads Not signed in; one button to sign in, no Pantas ID yet [m: ST_AccountOut, ST_RootSignedOu] | /settings/account · features/settings/presentation/pages/account_page.dart | BUILD |
| ST_AccountOffline | Offline · signing in waits for a connection; every other row still works and syncs later [m: ST_AccountOffline] | /settings/account · features/settings/presentation/pages/account_page.dart | BUILD |
| ST_Name | Name · its own page in the pane; saves as you type; clearing it removes the name [m: ST_Name] | /settings/account/name · pages/name_page.dart | BUILD |
| ST_RootNoName | No name · the profile says Add your name with the plain person; clicking it opens Name [m: ST_RootNoName] | /settings · settings_home_page.dart (profile header) | BUILD |
| ST_SignOut | Sign Out · a short confirm; Free is told progress stays in this browser (Pro: it's backed up) [m: ST_SignOut] | /settings/account · features/settings/presentation/pages/account_page.dart (sign-out confirm) | BUILD |
| ST_DeleteAccount | Delete account · what goes, each struck through in red; a line when a subscription is active [m: ST_DeleteAccount] | /settings/account/delete · pages/delete_account_page.dart | BUILD |
| ST_BackupDetails | Backup details (Pro) · when, what's waiting, since when, which device; Back Up Now under it [m: ST_BackupDetails] | /settings/backup · pages/backup_page.dart | BUILD |
| ST_BackupNow | Back Up Now clicked · Backing up with a spinner; the button rests until it's done [m: ST_BackupNow] | /settings/backup · pages/backup_page.dart | BUILD |
| ST_BackupNowOffline | Back Up Now with no connection · dimmed, with one line saying why [m: ST_BackupNowOffline] | /settings/backup · pages/backup_page.dart | BUILD |
| ST_BackupStates | Backup, every other state (Pro) · backing up, offline, couldn't back up, not signed in [m: ST_BackupStates] | /settings/backup · pages/backup_page.dart | BUILD — State sheet (backing up / offline / failed / signed out). |
| ST_Avatars | The profile picture · Google photo first; else the first letter; an emoji stays an emoji; else a plain person [m: ST_Avatar] | core/ui/components/avatar.dart | BUILD |
| ST_Paywall | Pantas Pro, student exams (UPCAT) · Weekly, Monthly with 7 days free, Yearly; billing wording neutral until the web paym | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD — Student exams (UPCAT) Weekly/Monthly/Yearly. Web gateway sells CS products only. |
| ST_ProCSE | Pantas Pro, civil service (CSE Professional) · Monthly with 7 days free, or a Season Pass; no weekly [m: ST_ProCSE] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD — Board: Monthly ₱149 + Season Pass ₱499, no weekly. Web catalog has pantas_cs_weekly. |
| ST_ProCSEPass | Season Pass picked · one payment; the line says when it ends and that it never renews [m: ST_ProCSEPass] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_ProLET | Pantas Pro, licensure (LET, PNLE and later PRC exams) · Monthly ₱249 with 7 days free, or a ₱1,499 Season Pass [m: ST_ProLE] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD — LET/PNLE: web exam picker and web products are CSE only. |
| ST_ProNCE | Pantas Pro, PSHS-NCE · a Season Pass only; no subscription, so no trial [m: ST_ProNCE] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD — Season Pass only; web not selling NCE. |
| ST_ProNCENoDate | PSHS-NCE with no published date · its only plan waits; the button is off [m: ST_ProNCENoDate] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_ProPMA | Pantas Pro, academy exams (PMA, PNPA, PMMA, MAAP) · the student plans, plus a ₱299 Season Pass as a wide card [m: ST_ProPMA] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD — Academy exams; web not selling. |
| ST_ProPMAPass | Academy exam, Season Pass picked [m: ST_ProPMAPass] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_Pro | Pantas Pro, on Pro · the same hero says thanks; your plan and renewal; Manage Subscription [m: ST_ProPro] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD — "Manage Subscription": app shows "Manage in Google Play" and hides it on web (!web); no web destination. |
| ST_RootTrial | Pro trial ending · the list value counts the days left [m: ST_RootTrial] | /settings · settings_home_page.dart (value counts days left) | BUILD |
| ST_ProPassHave | Pro on a Season Pass · Plan, Exam, Ends; nothing to manage [m: ST_ProPassHave] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_ProPending | Payment pending (GCash, over the counter) · the plans step aside for one card: what you picked and how to finish [m: ST_Pro] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart (pending card is built but `pending = web ? null`) | NEW-FEATURE — Web has no pending-payment state (GCash / over the counter) and no "See Payment Steps" action. Web gateway only returns a lag "pending" after checkout return. |
| ST_ProLapsed | Pro ended · says when, that nothing was lost, and offers the plans again, no second trial [m: ST_ProLapsed] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_PassEnded | Season Pass ended (after the exam) · says when and that nothing was lost; a new pass runs to the next published date [m: ST] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_PassNoDate | No published date yet (between exams) · the Season Pass can't be bought and says why; Monthly still can [m: ST_PassNoDate] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_PassSoon | Buying a pass days before the exam · the card says how long it really lasts [m: ST_PassSoon] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD — Card says "Ends in 5 days" while fine print says Mar 1, 2027 (handoff loose end; app computes Ends in N days from the next sitting). |
| ST_RestoreDone | Restore Purchases, found · the page turns into the Pro page with a short note [m: ST_RestoreDone] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_ProRestoreNone | Restore Purchases, nothing found · a short note; the plans stay [m: ST_RestoreNone] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_ProOffline | Subscribing or restoring with no connection · the same short note [m: ST_ProSubOffline, ST_ProRestoreOffline] | /settings/pro (/pro) · features/settings/presentation/pages/pro_page.dart | BUILD |
| ST_Exam | Your exam · exam, date and study days (Sunday first) in one pane, edited in place [m: ST_Exam] | /settings/exam · pages/exam_page.dart | BUILD |
| ST_ExamDate | Exam date clicked · the date opens right in the list: exact day, month only, or I don't know [m: ST_ExamDate] | /settings/exam · pages/exam_page.dart | BUILD |
| ST_ExamMonth | Month only · the day column goes; the row reads November 2026 [m: ST_ExamMonth] | /settings/exam · pages/exam_page.dart | BUILD |
| ST_ExamUnknown | I don't know · no columns; the row reads Not set [m: ST_ExamUnknown] | /settings/exam · pages/exam_page.dart | BUILD |
| ST_ExamPassed | Exam date has passed · the date turns red and the note asks for the next one [m: ST_ExamPassed] | /settings/exam · pages/exam_page.dart | BUILD |
| ST_ExamCustom | Your own track · the Exam row shows the track's name [m: ST_ExamCustom] | /settings/exam · pages/exam_page.dart | BUILD |
| ST_DaysLast | Turning off the last study day · it won't go: the circle shakes and a short line says why [m: ST_DaysLast] | /settings/exam · pages/exam_page.dart | BUILD — Shake + line (exists: "At least one day stays on."). |
| ST_ExamPick | The exam picker from Settings · a dialog, two columns; Coming soon is grey and can't be picked [m: ST_ExamPick] | /settings/exam/change · ChangeExamPage + onboarding/presentation/exam_picker_screen.dart | BUILD — Dialog, two columns. |
| ST_SwitchPassWarn | Season Pass holder picks another exam · warned first: the pass stays with its exam; the new one is on Free [m: ST_SwitchPas] | /settings/exam/change · settings/presentation/carry_over_prompt.dart, paywall/domain/switch_outcome.dart | BUILD |
| ST_ExamSwitch | After picking another exam · UPCAT holds the green, CSE Professional is empty; Count Them, or start fresh [m: ST_ExamSwitch] | /settings/exam/transfer · carry_over_prompt.dart | BUILD |
| ST_ExamSwitchCount | Count Them, animated · press Play: the click lands on Count Them, the words drop away, the two exams glide to the middle; the tube fills, the green drains from UPCAT into CSE Professional (UPCAT keeps a tint: its answers stay), the tube empties, a check pops in and “You pick up where you are” rises [m: ST_ExamSwitchCount] | /settings/exam/transfer · carry_over_prompt.dart ("Count Them") | MOTION — Spec in handoff Motion (6.4 s). |
| ST_SwitchUpgrade | Pro (student exams) picks CSE Professional · its plans as an upgrade, no trial; or switch and use it on Free [m: ST_SwitchU] | /settings/exam/upgrade · pro_page.dart(targetExam) | BUILD |
| ST_Included | What's included · the same picker as Customize your own: subjects as headings, topics ticked, the caret opens lessons [m: S] | /settings/exam/included · pages/whats_included_page.dart | BUILD |
| ST_IncludedOpen | A topic opened · Circles unticked, so Geometry shows a dash; Trigonometry left out whole [m: ST_IncludedOpen] | /settings/exam/included · pages/whats_included_page.dart | BUILD |
| ST_IncludedLast | Unticking the last topic · it won't go: the box shakes and a short line says why [m: ST_IncludedLast] | /settings/exam/included · pages/whats_included_page.dart | BUILD |
| ST_Reminders | Reminders · daily reminder with its time in place, shown only while on; and the follow-up [m: ST_Reminders] | none · row hidden on web (`if (!kIsWeb)` in settings_home_page.dart); /settings/reminders is pushed but not declared | NEW-FEATURE — Reminders are parked ("excluded from launch"); no web notification permission/scheduling path in the app. |
| ST_RemindersOffSwitch | Daily reminder off · the time row goes; Follow up dims, since it needs the daily reminder [m: ST_RemindersOffSwitch] | same as ST_Reminders | NEW-FEATURE — Time row hides, Follow up dims. |
| ST_RemindersOff | Browser notifications blocked · “Notifications are off” and how to allow them for this site [m: ST_RemindersOff] | same as ST_Reminders | NEW-FEATURE — Browser notifications blocked help text. |
| ST_Appearance | Appearance · light or dark by looking; text size slider; remember table order [m: ST_Appearance] | /settings/appearance · pages/appearance_page.dart | BUILD — Text size slider and Remember table order exist (lesson_text_scale.dart). |
| ST_LargeText | Largest text size · rows grow taller; values wrap under the label rather than being cut off [m: ST_LargeText] | /settings/appearance | BUILD |
| ST_About | About · version; legal; your data (with Shared links); Send feedback opens the Pantas Facebook group in a new tab [m: ST_Ab] | /settings/about · pages/about_page.dart | BUILD — "Shared links 2" row belongs to deferred Wrapped sharing: hide. |
| ST_Privacy | Privacy policy · a plain reading page in the pane with the date it changed; Terms of service looks the same [m: ST_Privacy] | /legal/:doc · features/legal/presentation/legal_document_page.dart | BUILD — Terms looks the same. |
| SD_Error | Study · could not load [m: ST_Error] | /study · features/lesson/presentation/learn_tab_home.dart (StudyTabHome), widgets/study_map_entry.dart (error) | BUILD — Filed under Settings page on the canvas; it is a Study state. |
| SD_NoExam | Study · no exam chosen [m: ST_NoExam] | /study · features/lesson/presentation/learn_tab_home.dart (StudyTabHome), widgets/study_map_entry.dart (no exam) | BUILD — Filed under Settings page on the canvas; it is a Study state. |

### Assessment, custom mock, Wrapped, loading, system, dark (36)

| board id | what it shows | existing route / widget | verdict |
|---|---|---|---|
| AS_Question | Assessment · the same question screen; no flag, no Check: pick (A–D) and Next; answers show at the end [m: AS_Question] | /assessment/:examId · features/assessment/presentation/assessment_page.dart | BUILD — No flag, no Check; A–D keys. |
| AS_Picked | A choice picked · Next turns on; you can change your pick until you go on [m: AS_Picked] | assessment_page.dart | BUILD |
| AS_Leave | Leaving the assessment · × or Esc asks once; leaving loses this attempt, so Leave is red [m: AS_Leave] | assessment_page.dart (Esc → onKeepGoing exists) | BUILD |
| AS_Results | Assessment results (once) · the ring fills, subjects weakest first, where the plan starts; then Home takes over [m: AS_Resu] | /assessment/:examId/results · assessment_results_page.dart | BUILD |
| CM_Setup | Your own mock (custom track) · how many questions and how long, each edited in place like Settings [m: CM_Setup] | /quiz/mock/custom-setup · pages/custom_mock_setup_page.dart | BUILD |
| CM_Wheel | Questions clicked · a stepper opens in the list instead of a wheel [m: CM_Wheel] | custom_mock_setup_page.dart | BUILD — Stepper in list instead of wheel (core/ui/components/value_wheel.dart today). |
| CM_Ceiling | More questions than your subjects hold · the number stays, in red; Tick More Subjects; Save waits [m: CM_Ceiling] | custom_mock_setup_page.dart | BUILD |
| CM_Breakdown | The section breakdown open · one row per subject; the totals stop being editable and add up the sections [m: CM_Breakdown] | custom_mock_setup_page.dart | BUILD |
| WR_Exam | Wrapped · the day after the exam: a centred story, ← → or click to move; Share and Done on the last slide [m: WR_Exam] | features/wrapped (wrapped_reveal_page.dart, /wrapped/:artifactId) | SKIP — Wrapped deferred (handoff hard rule; note wrDeferMore). |
| WR_Mock | Wrapped · after a first mock or a new best: five slides [m: WR_Mock] | features/wrapped | SKIP — Wrapped deferred. |
| WR_Streak | Wrapped · a streak of 7, 30, 100 or 365 days [m: WR_Streak] | features/wrapped | SKIP — Wrapped deferred. |
| WR_Topic | Wrapped · a topic turns from weak to strong [m: WR_Topic] | features/wrapped | SKIP — Wrapped deferred. |
| WR_Share | Share · the exact image that goes out, three switches (all off); Copy Link publishes it; Download Image keeps it private | features/wrapped/presentation/share_privacy_sheet.dart | SKIP — Wrapped deferred. |
| WR_ShareExam | A switch on · the image updates as you flip it (UPCAT appears) [m: WR_ShareExam] | share_privacy_sheet.dart | SKIP — Wrapped deferred. |
| WR_ShareOffline | Share with no connection · the buttons rest; one line says why [m: WR_ShareOffline] | share_privacy_sheet.dart | SKIP — Wrapped deferred. |
| WR_History | Your Wrapped (Pro, from Your record) · every Wrapped, newest first, as covers [m: WR_History] | none | SKIP — Wrapped deferred. |
| WR_Links | Shared links (About › Your data) · each image you shared, when, and its link; Remove takes it down [m: WR_Links] | features/wrapped/presentation/my_shared_cards_page.dart | SKIP — Wrapped deferred (About › Shared links). |
| WR_LinkRemove | Remove clicked · a short confirm [m: WR_LinkRemove] | my_shared_cards_page.dart | SKIP — Wrapped deferred. |
| WR_LinksEmpty | Shared links, none yet · one line [m: WR_LinksEmpty] | my_shared_cards_page.dart | SKIP — Wrapped deferred. |
| L_Rules | Loading rules · the same three kinds of waiting on the web [m: L_Rules] | core/ui/components/steps_screen.dart, loading_shapes.dart (rules) | SKIP — Note board: the three loading kinds. Still lists "Setting out a mock paper" steps and "Creating a Wrapped share link". |
| L_Restore | Steps · restoring progress after sign-in: the real stages tick off [m: L_Restore] | core/ui/components/steps_screen.dart (StepsScreen) | BUILD |
| L_Delete | Steps · deleting the account; ends with “Your account is deleted. Nothing of yours is left.” and Close [m: L_Delete] | core/ui/components/steps_screen.dart (StepsScreen) / pages/delete_account_page.dart | BUILD |
| L_ChangeExam | On the button · changing exam: Switch to ACET becomes “Rebuilding your plan”, then “You're now studying for ACET” with t | on-button state · /settings/exam/change | BUILD |
| L_SignIn | On the button · signing in with Google: the button turns into a spinner and a verb, then Signed in [m: L_SignIn] | on-button state · account_page.dart | BUILD |
| L_Purchase | On the button · confirming a purchase, then You're Pro [m: L_Purchase; provider wording TBD] | on-button state · pro_page.dart | BUILD — Provider wording TBD. |
| L_RestorePurchase | On the button · restoring a purchase, then Pro restored [m: L_RestorePurchase] | on-button state · pro_page.dart | BUILD |
| L_Share | On the button · creating a Wrapped share link, then Link copied [m: L_Share] | none | SKIP — Wrapped share link, deferred. |
| L_PlanSlow | Only if slow (past 300 ms) · the first plan of the day: grey shapes pulse where the content will be [m: L_PlanSlow] | core/ui/components/loading_shapes.dart | BUILD — Only past 300 ms. |
| L_ProgressSlow | Only if slow · figures from your history [m: L_ProgressSlow] | loading_shapes.dart | BUILD |
| L_DebriefSlow | Only if slow · the session debrief and results [m: L_DebriefSlow] | loading_shapes.dart | BUILD |
| SY_Error | Something went wrong · one line in the app's voice; Try Again [m: SY_Error] | core/ui/components/state_view.dart; app/AppErrorRecovery | BUILD |
| SY_Update | Update required · on the web, Update reloads into the new version; nothing to download [m: SY_Update] | /update-required · features/shell/presentation/update_required_page.dart | BUILD — App button opens the Google Play listing; board says Update reloads the page. |
| DK_Home | Dark · Home (Pro): black ground, dark grey cards, a slightly brighter teal [m: DK_Home] | dark tokens · /home | BUILD — Dark reference; see section 5 for token mismatch. |
| DK_Quiz | Dark · the Quiz tab [m: DK_Quiz] | dark tokens · /quiz | BUILD |
| DK_Settings | Dark · Settings, list and Practice: segments, checklist and switch on dark [m: ST_DarkRoot, ST_DarkPractice] | dark tokens · /settings | BUILD |
| DK_Question | Dark · a miss in a session: red and green stay readable on black (new for web) | dark tokens · question screen | BUILD — Marked "new for web". |

Per page: Overview: BUILD 10, SKIP 3; Onboarding: BUILD 24, NEW-FEATURE 3, SKIP 1; Home: BUILD 34; Parts: BUILD 3; Plan and performance: BUILD 19; More about you: BUILD 10; Study and the reader: BUILD 29, MOTION 1; Quiz: BUILD 37, MOTION 1, SKIP 1; Mock exam: BUILD 31, MOTION 4; Settings: BUILD 53, MOTION 1, NEW-FEATURE 4; Assessment, custom mock, Wrapped, loading, system, dark: BUILD 23, SKIP 13

Counts: BUILD 273, NEW-FEATURE 7, SKIP 18, MOTION 7, total 305.

## 2. Screens to build per area

Layout families in the boards (from the HTML): (a) sidebar shell = `.shell` with `nav.side` (X_Side, 244px max) plus `main.main > .wrap` (max 1080px, 28/44px padding); (b) focus mode = `.focus` with a 64px `.fhead` top bar, no sidebar, optional `.fbar` bottom pill; (c) onboarding = its own centered layout with a labeled step header ("Birth year, Terms, Your exam, Exam date, Study days, Your name", plus Back), no sidebar. Boards with the sidebar: all HM, PL, PF, MY (except MY_Profiles, MY_Pictures), SD, CZ, CM, QZ, MK_Setup*, ST_* (except ST_Avatars, ST_BackupStates), BM (except BM_MarkTeal), OB_SignIn, on-button L_* boards, Main, W_Study, W_QuizTab, W_Settings. Focus mode: AS_*, QS_*, QN_*, RD_*, MK_* (all except setup/finales), SY_*, L_Restore, L_Delete, L_DebriefSlow.

### Home
- Screens: Today (checklist) with states DayStart / mid-day (Main) / DayDone / Advanced / AdvanceAgain / DayOff / ReviewWeek / LastDay / NothingDue / NothingDueReview / ExamDay / ExamPassed / NoContent / BeforeAssessment / MockDay (+MockMoved, MockDropped) / Resume / LongTitle / ManyLessons; day notes (BackAfterBreak, CarryOver); one notice strip at a time (NoticeClosed, NoDate, MonthOnly, Trial, ProWelcome, Service); dialogs (NoDateModal, MonthOnlyPick); right drawers (LessonsPanel, ReviewsPanel, NewQPanel).
- Newest/final: Main is the Pro baseline; HM_Free is the Free variant; HM_Everything is the busiest composite. HM_DayDone and HM_Advanced supersede nothing; they are states.
- Shared parts: X_Side, header with greeting + `.week` strip + `.exam` calendar chip, `.cols` (Today column flex 1.45 1 480px; glance column with X_Perf and X_More), `.card` + `.row`, `.notice` (`.nh`, `.nb`), `.drawer`, `.modal`, `.btn/.btn2/.btn3`, `.tag/.pro`.

### Study and reader
- Screens: Study map with an open topic beside it (W_Study); Search overlay (Ctrl K; recent, results, no match); Bookmarks right drawer (Open, Order, Custom, Edit, Removed toast, Empty, One, Keyboard); bookmark mark (BM_MarkTeal); Reader (focused, scrolled, lesson list open, figure lightbox, image failed, resume, error); reader from Home (RD_Plan, RD_DayEnd, RD_DayDone); endings (RD_TopicDone, RD_TopicShort); Study states (SD_MapEmpty, SD_NoLessons, SD_Loading, SD_Error, SD_NoExam).
- Newest/final: RD_Focus is the declared reference for every reader; RD_Real (1440x3400) is the full-length real-lesson reference (680px column, outline beside it); RD_RealScroll shows the scrolled bar. W_Reader and RD_Contents/RD_Resume use the fake "Circles" lesson and are older.
- Shared parts: focus-mode `.fhead` reader bar (back label Study or Home, Esc, "n of N", title fading in over 90px, hides after 120px more, 2px progress line always on), "IN THIS LESSON" margin outline (teal dot glides ~250 ms, built from the lesson's h2 blocks), end card "NEXT IN ..." with → , `.popover` lesson list, lightbox scrim, `.toast`, `.drawer`, `.seg`.

### Quiz
- Screens: Quiz tab (W_QuizTab base; QZ_Done, QZ_First, QZ_Free, QZ_Resume); Customize your own (CZ_Picker tree + summary beside it, CZ_TotalTime, CZ_Adjust, edges None/One/Many/ManyTime/Short/RunsShort/Long); question session (W_Question, QS_Figure, QS_Long, QS_Flag, QS_Grid, QS_GridBack, QS_Last, QS_Leave, QS_MissFree, W_QRight, W_QMiss, W_QPassage); end of session (QS_EndPro newest; QS_EndFree, QS_EndLow, QS_EndPerfect; QS_All); viewer with notes and report (QN_Correct, QN_Wrong newest for Pro, QN_WrongFree, QN_OwnWords, QN_EditNote, QN_Report, QN_ReportSent/Again/Limit/Offline); RV_Reveal motion.
- Shared parts: `.fhead`, `.fbar` (neutral / `.right` / `.wrong`; `.cnt` counter, `.pill` primary with `.k` key hint), `.stage`/`.qcol` (720px; 600px with `.n`)/`.xpl` explanation (440px), `.opt` (`.sel .ok .bad .dim .ro`), `.popover` grid, `.modal` Leave, `.toast`, report panel.

### Mock exam
- Screens: Setup (MK_Setup, MK_SetupStrict, MK_SetupCSE, MK_SetupDCAT); in-exam (W_Mock with questions panel, MK_NavHidden, MK_Proctor, MK_FiveMin, MK_LastMinute, MK_LastQ, MK_LastQStrict, MK_EndEarly, MK_Between, MK_PartEnded, MK_PauseWarn, MK_Paused, MK_Discard, MK_SheetCSE, MK_SubmitCSE); finale (MK_Finale no deduction, MK_FinaleUPCAT); results (W_MockResults Pro, MK_ResultsFree, MK_ResultsFirst, MK_Forfeit); past results from the record (MK_PastPro, MK_PastFreeOpen, MK_PastFreeLocked); review (MK_ReviewWrong first tab, MK_ReviewWrongFree, MK_ReviewAll, MK_ReviewFlagged, MK_ReviewQ, MK_ReviewQFree, MK_ReviewBlank). Motion: MK_NavMotion, MK_PauseMotion, both finales. Custom mock (CM_Setup, CM_Wheel, CM_Ceiling, CM_Breakdown) sits on the "more" page.
- Newest/final: handoff and the mkNav note define the list toggle (handoff timings win); MK_Finale/MK_FinaleUPCAT are separate by exam type, not newer/older; W_Mock is the only "answering" board.
- Shared parts: `.fhead`, `.fbar` (questions counter, flag, Pause, Next), left questions panel (340px, hides to 40px content padding), clock + `.bar5`-style time bar (amber under 5 min, red last minute), hourglass, `.modal`, `.scrim`, score ring card, `.seg`/tabs for review.

### Results and performance (plan page: PL_*, PF_*)
- Screens: Your plan (PL_Plan Pro, PL_Free, PL_Error); a week (PL_Week, PL_WeekCustom); a day (PL_Day; PL_DayRead reader drawer; PL_DayPast popover); History page (PL_History, PL_HistoryEnd); Your performance (PF_Subjects default, PF_SubjectOpen, PF_Topics, PF_Lessons, PF_Filter menu, PF_Sort menu, PF_Topic right panel, PF_Free, PF_Error). Mock and session results belong to the Mock and Quiz areas above.
- Shared parts: X_Side, `.week`, `.card` rows, `.seg` view switch, `.popover` menus, `.drawer` (PF_Topic, PL_DayRead), X_Perf (Home glance), accuracy bars.

### You / record
- Screens: Your record (MY_Record Pro, MY_RecordFree, MY_RecordFirst, MY_RecordRest); Your tendencies (MY_TendPro, MY_TendNew, MY_TendFree, MY_TendError); MY_Profiles (12 labels) and MY_Pictures (finding figures, clear vs not-yet-clear) are reference sheets for the cards inside them.
- Newest/final: MY_Record and MY_TendPro; the Wrapped row on every record board must not be built.
- Shared parts: X_Side, `.card`, `.seg`, totals + line chart, profile card.

### Settings and paywall
- Screens: Settings split view (W_Settings base): Account (ST_Account family, Name, Sign Out, Delete, Backup family, Avatars), Pantas Pro (ST_Paywall; per exam family ST_ProCSE, ST_ProCSEPass, ST_ProLET, ST_ProNCE, ST_ProNCENoDate, ST_ProPMA, ST_ProPMAPass; states ST_Pro, ST_RootTrial, ST_ProPassHave, ST_ProPending, ST_ProLapsed, ST_PassEnded, ST_PassNoDate, ST_PassSoon, restore and offline notes), Your exam (ST_Exam family, picker dialog, switch warnings, ST_ExamSwitch, ST_SwitchUpgrade, What's included), Practice (shown in W_Settings), Reminders (ST_Reminders family, NEW-FEATURE), Appearance (ST_Appearance, ST_LargeText), About and legal (ST_About, ST_Privacy), DK_Settings.
- Newest/final: the handoff fine-print rule (terms directly under the CTA, right-aligned; Restore Purchases left) is newer than the board notes. Weekly/Yearly CTA and terms are not designed yet (handoff loose end).
- Shared parts: X_Side, list pane + detail pane, `.row` list, `.seg`, `.sw` switch, `.field`, `.modal`, `.toast`, Pro hero card, plan cards.

### Onboarding
- Screens in order: OB_Welcome, OB_Age (OB_AgeBlocked), OB_Terms, exam picker (OB_Picker; OB_PickerLoading, OB_PickerError, OB_PickerEmpty; custom: OB_CustomName, OB_CustomCover), exam date (OB_DateKnown → OB_DatePick → OB_DateMonth → OB_DateDay; OB_DateYear, OB_DateThisMonth, OB_DateToday), study days (OB_Days; OB_DaysNone, OB_DaysTooLate, OB_DaysSoon), OB_Name, then reminders (OB_Reminders, OB_ReminderTime, OB_Permission: NEW-FEATURE) and OB_Install (parked). Later: OB_SignIn, OB_Restoring.
- Shared parts: step header, `.field`, `.btn` with Enter key hint, `.kc` hints, calendar/month grid, day circles.

### Assessment and custom mock ("more" page)
- Assessment: AS_Question, AS_Picked, AS_Leave, AS_Results (focus mode, A-D keys, `.fbar` with Next). Custom mock: CM_Setup, CM_Wheel, CM_Ceiling, CM_Breakdown (sidebar shell).

### Parts and system
- X_Side (props active, plan, exam, person), X_Perf (380x560, prop plan), X_More (640x110). SY_Error and SY_Update (focus mode). L_* boards: steps screens (L_Restore, L_Delete), on-button states (L_ChangeExam, L_SignIn, L_Purchase, L_RestorePurchase), slow-only shapes (L_PlanSlow, L_ProgressSlow, L_DebriefSlow); L_Rules is the rule note. DK_Home, DK_Quiz, DK_Settings, DK_Question are the dark references.

## 3. Contradictions

1. Dark palette. DK_Home title says "black ground, dark grey cards, a slightly brighter teal". The DK CSS and the handoff use charcoal #151515 / #1F1F1F, and DK_* still use #1A957F for ring strokes while the handoff says button #0F8571 and accent #4CC3AC. The app dark theme is #000000 / #1C1C1E with accent #2FB39C / #1F9C86 and unchanged #D70015 destructive. Handoff wins.
2. Buttons. Handoff: natural width, height 44 / 50. App: PantasButton defaults to `fullWidth: true`, height 52 (PantasShape.buttonHeight = 52).
3. Full-width button in HM_LessonsPanel, HM_ReviewsPanel, HM_NewQPanel ("Continue Lesson", `style="width: 100%"`) against the handoff rule "No full-width buttons on wide screens".
4. HM_Trial copy: "You'll be charged ₱99 on Oct 16 to keep Pro" with Got It / Manage. App web notice (home_notices.dart, approved 24 Oct 2026) says "You won't be charged", buttons See Pro / Got It, because the web trial is a prepaid grant that never charges.
5. Exam scope. Boards default to UPCAT everywhere (Main, HM_*, ST_Paywall, ST_ProPending, X_Side "UPCAT · Pro") and show LET, NCE, PMA plans (ST_ProLET, ST_ProNCE, ST_ProNCENoDate, ST_ProPMA, ST_ProPMAPass) and OB_Picker with UPCAT picked. The app on web restricts the picker to CSE (`ExamPickerScreen.cseOnly = kIsWeb`, exam_cse_pro and exam_cse_sub) and the web payment gateway lists `pantas_cs_*` products only. HM_NoContent itself says CSE Subprofessional has no lessons yet.
6. Reminders. ST_Reminders, ST_RemindersOffSwitch, ST_RemindersOff, OB_Reminders, OB_ReminderTime, OB_Permission, and the "Reminders 7:00 PM" row drawn in every Settings board need web notifications. App: row hidden by `if (!kIsWeb)`, `/settings/reminders` is pushed but never declared, and onboarding's reminders step only calls `_finish()` ("Native reminders are parked with W4f and excluded from launch").
7. Pro page. ST_Pro shows "Manage Subscription"; the app shows "Manage in Google Play" only when `!web`, so web has no destination. ST_ProPending (GCash / counter, "See Payment Steps") has no web counterpart: `pending = web ? null`. ST_ProCSE says "no weekly" while the web catalog defines `pantas_cs_weekly`. ST_PassSoon: "Ends in 5 days" vs "Mar 1, 2027" (handoff loose end). Weekly/Yearly CTA terms undesigned.
8. Wrapped. MY_Record, MY_RecordFree ("Wrapped row carries a Pro tag") and MY_RecordRest draw "Your Wrapped"; ST_About draws "Shared links 2"; L_Rules lists "Creating a Wrapped share link". Handoff and notes wrDeferYou / wrDeferMore say hide all of it. App still ships `/wrapped/:artifactId`, wrapped_reveal_page.dart and my_shared_cards_page.dart; the record row provider is already null.
9. Proctor warning. MK_Proctor: "10 minutes left in this subject" replaces the line under the clock for 2.5 s with three short sounds. App: ProctorToast for 8 s with haptic. Handoff: appears on the clock, not as a toast.
10. Question-list toggle timing. Note mkNav: slide "about 0.25 s". Handoff / MK_NavMotion: .46 s with the edge tab .3 s later. Handoff wins. The app has only a counter and a bottom sheet grid, no side panel.
11. No pre-mock Start screen (handoff, L_MockStart removed) vs app `mock_start_preparation_page.dart` and `/quiz/mock/start`, and L_Rules still lists "Setting out a mock paper" as a steps screen.
12. Finale. MK_FinaleUPCAT needs a deduction variant (red ball, 68.4 to 61.2, "171 correct, minus 18 wrong"). The app has one finale (CseMockFinale, no deduction). Results text with the deduction exists in mock_results_page.dart.
13. Results layout. Handoff: "Done sits top-right, level with the title". W_SessionEnd and QS_EndPro: "score centred, Done right under it". The handoff list does not say whether quiz end screens are exempt; MK_Results* follow the handoff.
14. Mistake reasons. QN_Wrong, QN_EditNote, QN_OwnWords, W_QMiss, DK_Question, MK_ReviewQ list "I misread / I forgot / I didn't know / Type my own". The app (quiz_note_editor.dart) has "I misread it / I knew it, I just slipped / I didn't know it / Type my own"; there is no "I forgot" tag.
15. System update. SY_Update: "Update reloads into the new version; nothing to download". App UpdateRequiredPage opens the Google Play listing.
16. Keyboard. Boards specify Ctrl K, F, G, B, P, ← →, Enter, Esc, Alt ↑/↓, number keys 1-4 for reasons, A-D for assessment answers (hint chips `.kc`: Esc 52, → 32, ← 25, Enter 14, F 12, Ctrl K 8). The app binds only Esc (dialogs, sheets, report, lightbox), arrows in ValueWheel and Enter/Space on the nav bar.
17. Older markup. W_Question uses `.bar`/`.act`, not `.fbar`/`.pill`. W_Reader, RD_Contents and RD_Resume use fake "Circles" content with 5 of 11 / 4 of 8; RD_Real and RD_Focus use real lesson data (1 of 5, 8 sections from h2 blocks).
18. History. PL_History is a full page with a back route; the app renders History as a section inside the plan screen (no route).
19. Fonts. Handoff names Source Serif 4 for math and figures. App bundles only Geist and Phosphor; math uses flutter_math_fork KaTeX_Main.
20. Content schema. No board shows difficulty or clue data (only the copy "10 easy reviews" in HM_ExamDay, which the app already has). Passage, figure and rationale fields used by W_QPassage, QS_Figure and RV_Reveal exist in the schema.
21. Canvas filing. SD_Error and SD_NoExam sit on the Settings page but are Study states. K_Home has no title and no page.

## 4. Responsive notes

- Sizing: 302 of 305 boards are 1440 wide (heights mostly 900; 1000-1560 for long ones, RD_Real 3400). Exceptions: X_Side 244x900, X_Perf 380x560, X_More 640x110. Handoff: "web is 1440 wide, fluid". Every board is saved as `expand: fill`.
- pantas.css has no width media queries. Its only `@media` is `prefers-reduced-motion`. Responsiveness is flex-wrap and flex basis only.
- Sidebar: `.shell` is `flex-wrap: wrap`; `.side` is `flex: 1 1 220px; max-width: 244px`; `.main` is `flex: 999 1 560px` with 28px/44px padding; `.wrap` is max 1080px centered. Below about 780px (220 + 560) the sidebar wraps above the content as a full-width block. No board designs an icon-only or collapsed sidebar, a drawer menu, or a tablet width.
- Columns: Home Today column `flex: 1.45 1 480px` beside the glance column; most card groups use `flex: 1 1 260-380px` and wrap to one column. Quiz `.qcol` is `flex: 0 1 720px` (600px with `.n`) beside `.xpl` at `flex: 0 1 440px`; `.stage` wraps them. `.fbar` is `width: calc(100% - 48px)`, max 720px (`.wide` 1080px). `.modal` 440px (560 wide) with `max-width: calc(100% - 48px)`; `.drawer` 440px, `max-width: 100%`.
- Fixed numbers from the handoff and notes: reader column 680px; mock question panel content padding 340px to 40px; reader bar hides after 90px + 120px of scroll.
- Mobile fallback: handoff points to a separate mobile canvas (390x844, prefixes MK_, QS_, RD_, ST_ and so on) that is not exported. No board or note names the breakpoint where the web layout hands over to the mobile layout. The app already contains the mobile layout (bottom AppNavBar, bottom sheets, full-width pages with 16px side padding).
- Text size: ST_LargeText says rows grow taller and values wrap under the label; ST_Appearance says Ctrl + and Ctrl − still zoom the whole page.
- Light and dark follow the Appearance setting (Light, Dark, Automatic follows the computer). Handoff: all motion respects prefers-reduced-motion.

## 5. Current theme, tokens and component layer in the app

Theme and tokens (lib/core/ui/theme/):
- pantas_colors.dart: `PantasColors` is a `ThemeExtension` with 43 named colors, `PantasColors.light` and `PantasColors.dark` as separate const sets, plus `copyWith`/`lerp` and `accuracyTint()`. Light already matches the handoff for background #F5F5F7, surface #FFFFFF, label #1D1D1F, secondary #6E6E73, separator #E3E3E8, accent #0B7A68, accentTint #E4F1EE, destructive #D70015. Differences: wrongTint light #FDECEE (handoff #FDE8EA); tertiaryLabel #AEAEB2 vs muted #8A8A8E; no `accentHover` (#086A5A) token. Dark set is iOS-style (#000000 background, #1C1C1E surface, #2C2C2E fill, accent #2FB39C, accentFill #1F9C86, wrongTint #3A1215, wrongText #FF6961, destructive stays #D70015), not the handoff charcoal.
- app_theme.dart: `buildLightTheme()` and `buildDarkTheme()` call `_buildTheme(PantasColors.x, Brightness.x)`, which builds a Material 3 `ThemeData` (ColorScheme.fromSeed overridden from the tokens), registers `extensions: [colors, type]`, sets Geist, AppBar, Divider, Dialog and BottomSheet themes. `context.colors` and `context.type` (extension `AppThemeContext`) are how widgets read tokens. /lib/app/theme.dart only re-exports `appLightTheme()` / `appDarkTheme()`.
- pantas_type.dart: `PantasType` ThemeExtension (largeTitle 34, pageTitle 30, pageTitleCompact 28, sectionHero 24, body 17, rowValue, emphasized, subhead, subheadStrong, footnote, sectionHeader, caption, captionSmall, captionStrong, mathSerif). Phone-scale sizes; no web scale (handoff `.h1` 38, `.h2` 26, `.h3` 20, `.qtext` 27, `.big` 40).
- pantas_shape.dart: groupRadius 14, cardRadius 18, floatingRadius 22 / 24, pillRadius 99, buttonHeight 52, buttonRadius 14, rowMinHeight 44, rowInset 16, gutter 16.
- theme_preference.dart: `ThemePreference` light / dark / system; `themePreferenceProvider` (features/settings/application/settings_providers.dart) feeds `MaterialApp.router(theme, darkTheme, themeMode)` in app/app.dart. lesson_text_scale.dart: reader text scale provider.
- Motion: core/ui/motion/pantas_curves.dart (`edgeGrow` Cubic(.32,.72,0,1) equals the handoff shared ease; also houseOut, riseIn, slideA-C, popA-C, checkDraw, shake, burst, liquid) and pantas_effects.dart (pop, rise, gauge, checkDraw builders).
- Fonts: Geist 400/500/600/700 and Phosphor icons (pubspec); core/ui/icons/pantas_icons.dart (Phosphor glyph map) and icons/own/own_icons.dart.
- Routing: app/router.dart builds a `StatefulShellRoute.indexedStack` (Home, Study, Quiz, Settings branches) inside `AppShell` (features/shell/presentation/app_shell.dart, bottom `AppNavBar`). No sidebar, no breakpoint helper, no max-width container; pages stretch full width with 16px padding (`PantasPage`), sheets are bottom-anchored (`PantasSheet`).

Component layer (lib/core/ui/components/):
- Buttons and controls: pantas_button.dart (PantasButton; variants primary, secondary, tertiary, destructive, neutral; fullWidth true by default, height 52), button_pair.dart, segmented_switch.dart, pantas_switch.dart, sort_cycle_button.dart, search_field.dart, value_wheel.dart, month_first_date_picker.dart.
- Layout and surfaces: pantas_page.dart (page/onboarding/settings variants), grouped_section.dart, list_row.dart, floating_bar.dart (FloatingBar neutral / right / wrong, the `.fbar` equivalent), centered_dialog.dart, pantas_sheet.dart, notice_strip.dart, toast.dart, state_view.dart, loading_shapes.dart, steps_screen.dart.
- Content: content_renderer.dart (portable text, lightbox), math_text.dart, math_support.dart, lesson_svg.dart, placeholder_figure.dart, core/ui/figures/ (typed figure widgets and figure_registry.dart).
- Question UI: choice_row.dart (plain / picked / right / wrong / dimmed), new_design/question_card.dart, passage_card.dart, answer_reveal.dart, question_grid_sheet.dart, report_form.dart, review_list.dart, today_questions.dart, scope_picker.dart.
- Data display: progress_ring.dart, half_ring_gauge.dart, accuracy_bar.dart, week_strip.dart, check_mark.dart, contents_glyph.dart, avatar.dart, pantas_logo.dart, pro_tag.dart, pro_paused_line.dart, exam_name_line.dart.
- Gallery: core/ui/gallery/component_gallery_page.dart (route /settings/_gallery).
- Where web pieces would sit: tokens in pantas_colors.dart (dark set, accent hover, muted) and pantas_type.dart / pantas_shape.dart (web scale, 44/50 buttons, 16-22 radii); sidebar and split panes beside app_shell.dart and pantas_page.dart; drawers/popovers beside pantas_sheet.dart and centered_dialog.dart; `.fbar` maps to floating_bar.dart.
