# L3 W4b: Home and progress (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 9d2c0b5f.
Level 2 plan: `L2-W4b-home-and-progress.md`. Base: integration branch after W2, W3 and W4h's pattern
task. Executor: one Sonnet worker, own worktree, track A (Tasks 1 to 5) then track B (Tasks 6 to 10)
(`L3-parallel-map.md`: three-worker limit); `lib/app/routes/home_routes.dart` edits in task order.
Closes carry-forward N5-1 (with W4c).

Before each screen task: open its boards and run `timeline.py`; build from the tap; reduce motion
shows the last frame. Every task: widget tests first for each drawn state (light, dark, 200% text),
unit tests for every rule, then code, task checks (`flutter test test/features/home
test/features/roadmap test/features/progress test/features/metrics`), commit. Screens move to W1's
theme API and W2's components; Pro gates read W3's `proForActiveExamProvider`.

## Track A: Home

### Task 1. Move shared data out of `lib/features/progress/` (lands first)

Move `table_order_prefs.dart` (`tableOrderProvider`, `retainTableOrderProvider`, `TableOrder`,
`TableLevel`), `performance_provider.dart` and `topic_accuracy_provider.dart`'s dependency into
`lib/features/home/application/performance/`; move `record_provider.dart` (Task 8),
`how_you_work_provider.dart` (Task 9) and `miss_causes_provider.dart` (kept recording inputs) into
`lib/features/home/application/`; `progress_providers.dart` moves with whatever still reads it.
`pace_provider.dart` stays and is deleted in Task 10 (S0-11). Behavior unchanged; existing provider tests move with
them and stay green. This unblocks W4f's Appearance task and the later deletion.

### Task 2. Week strip, exam chip, greeting

Boards HP_Free, HP_Pro, HP_NoDate, HP_MonthOnly, HP_ExamDay, HP_ExamPassed. New provider
`weekStripProvider(examId)` from `RoadmapDayRepository` and `CompletionFacts`: per day done, half,
missed, day off (not in study days), today ring; Sunday first via `PantasDates.weekStart`. Tapping a
day opens `/plan/day/:date`; the tap is wired in Task 7, which creates that route (gate L3-18). Exam chip states per the boards. Greeting bands kept (`greetingFor`).

### Task 3. Today checklist and its sheets

Boards HP_Day, HE_ManyLessons, HE_Resume, HE_CarryOver, HE_MockDay, HE_MockMoved, HE_MockDropped,
HE_BackAfterBreak, HE_LongTitle, HE_AdvanceAgain, HE_Everything; D-48 to D-62. From `roadmapTodayProvider`: lesson rows, Reviews,
New questions, mock row; 4+ lessons collapse to Up next plus a Lessons row; every row opens its
sheet (W2 `PantasSheet`) that starts that item; Continue Lesson; "View full plan". Advance via
`RoadmapController.canAdvance` and `advance` with "From tomorrow" and repeat (D-50). Lesson rows open
`/lesson/:id` with `LessonDayContext { date, lessonIds, index }` (the contract W4c consumes; lands
before W4c's reader-from-Home task). Replaces `up_next_panel.dart`, `up_next_provider.dart`,
`practice_panel.dart` (Practice Weakest Topics moves to the empty-day card, D-61).

### Task 4. Notices and states

Boards HP_NoDate, HP_MonthOnly, HP_Trial, HP_ProWelcome, HP_Service, HE_BeforeAssessment,
HP_NoContent, HE_NothingDue, HE_NothingDueReview, HE_DayOff, HE_ReviewWeek, HE_LastDay, L_PlanSlow (loading, only if slow).
`homeNoticeProvider`: one notice at a time, order service message, trial ending, welcome to Pro, no
date, month only; dismissal stored in app preferences (`home_notice_dismissed_<kind>`; for the
service message, the dismissed text, so a new text shows again, G-h-25). Trial copy with the
student's own plan price and date (amendment B2). States per D-63 and D-65; Choose your exam
fallback (S0-32); before the assessment no quick quiz. Date picker from Home uses W2
`MonthFirstDatePicker` in a sheet (D-69).

### Task 5. Your performance on Home and the performance screen

Boards HP_Pro (section), DT_TopicsA, DT_TopicsView, DT_LessonsView, DT_SortFlow, DT_FilterFlow,
DT_SubjectTap, DT_SubjectTapFree, DT_Free, DT_Topic, DT_Error, L_ProgressSlow (loading, only if slow). Routes `/performance`,
`/performance/topic/:topicId`. Rules: overall accuracy counts every finished session (D-15, check
each query's origin filter); no answers means hidden (D-110); bars per D-111; sort cycle; subject
picker; Free card (D-105); a topic page with Practice This Topic. Remember table order reads
`retainTableOrderProvider`. No Time column (S0-12; recording stays). N5-1: topic expand uses W1 `sort`/caret getters.

## Track B: plan, record, tendencies

### Task 6. Your plan

Boards DP_PlanA, DP_PlanFree, DP_Drill, DP_History, DP_HistoryEnd, DP_Error. Route `/plan`. Today
line (ring plus "2 of 4 done"), Coming up timeline (Pro; weeks Sunday to Saturday with topic names,
New material stops, Mock exam, exam row), entrance sequence (D-94), Free gray shapes with one
Unlock with Pro. History (Pro) from `RoadmapChangeLogRepository.recent`: sentences follow the board
copy for causes the board shows (newDay none; missedWork, advanced, examDateChanged, scopeChanged,
contentChanged, orderChanged, backlogCapped, mockAnswersRecorded, studyDaysChanged as on DP_History),
and the approved sentences for examChanged, examPassed, missingExamDate, assessmentCompleted;
prerequisiteCycle writes no entry. Five shown, See more adds ten, end line.

### Task 7. Week and day screens

Boards DP_Week, DP_WeekCustom, DP_Day, DP_DayRead, DP_DayPast. Wire Task 2's week-strip day tap to
`/plan/day/:date` here. Routes `/plan/week/:start`,
`/plan/day/:date`. Engine query for lessons per future day (D-100) added inside
`lib/features/roadmap/domain/` (`plannedLessonsForDay(examId, date)`), no schema change; if one is
needed, stop. Rest days read "Rest day"; "You study Monday to Saturday." with Change.
Sunday-first week math in `week_preview.dart` and the roadmap planning window (display only;
`StudyDays` stays ISO).

### Task 8. Your record

Boards YR_Full, YR_RestDay, YR_FirstWeek; YR_Wrapped and YR_WrappedFree show the slot's row (built by W4g Task 5). Route `/record`. Totals, streak with flame (not on Home),
accuracy line with the two-week placeholder, Your mocks (from W4e's mock history data), the
extension slot after Your mocks for W4g's `WrappedRecordRow` (lands before W4g's history task).
`record_provider.dart` weekly buckets move to Sunday start. Error per W4h pattern.

### Task 9. Your tendencies and profile cards

Boards YO_Pro, YO_ProNew, YO_Free, YO_Error, YO3_Profiles, YO4_Picks. Route `/tendencies`. Rename the
12 archetypes and their lines to DECISIONS D-80 (ids map one to one in `archetype_catalog.dart`;
icons D-81); five tendency cards with headings D-82, sentences D-84 without `{n}`, pictures D-83,
figures hidden until clear (D-85); When you work (Pro) with the three rows; How you work folded in.
Update `lib/features/metrics/` labels, templates and their tests; tendency confidence unchanged.

### Task 10. Delete Progress and check

Delete `lib/features/progress/` (presentation, `pace_provider`, `why_you_miss_section`,
`your_pace_panel`) except recording code W0 keeps (`miss_causes_provider` inputs stay; the widget
goes); delete Home widgets replaced in Tasks 2 to 5 and their tests; replace every Ink component
and the subject scope sheet in this family. `grep` finds no `/progress`, `/mock-exam` or
`/plan/dossier` navigation left in `lib/features/home` or `progress`. All required checks; evidence
`evidence/W4b.md`; independent review; Aedwon's visual check against the Home boards.
