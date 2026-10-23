# L3 W4b: Home and progress (implementation plan)

Level 3. Date: October 6, 2026. Author: lead. Policy revision: origin/main 9d2c0b5f.
Level 2 plan: `L2-W4b-home-and-progress.md`. Base: integration branch after W2, W3 and W4h's pattern
task. Executor: one worker (strategy B7 as amended Oct 6: GPT-6.1 Sol High through Codex; GPT-6 Astra audits; Opus lead reviews), own worktree, track A (Tasks 1 to 5) then track B (Tasks 6 to 10)
(`L3-parallel-map.md`: three-worker limit); `lib/app/routes/home_routes.dart` edits in task order.
Closes carry-forward N5-1 (with W4c).

Before each screen task: open its boards and run `timeline.py`; build from the tap; reduce motion
shows the last frame. Every task: widget tests first for each drawn state (light, dark, 200% text),
unit tests for every rule, then code, task checks (`flutter test test/features/home
test/features/roadmap test/features/progress test/features/metrics`), commit. Screens move to W1's
theme API and W2's components; Pro gates read W3's `proForActiveExamProvider`.

While W3's entitlement state is `paused`, each Pro gate shows W2's `ProPausedLine` instead of the Pro
invitation, with a widget test (amended Oct 6, abuse review 1).

## Track A: Home

## Lead rulings, October 12 (W4b stop at ffc8045b)

Read "Standing rulings for the W4 families" in `L3-parallel-map.md` first.
1. HP_ExamDay month text (80% white on teal, 3.95:1): full-opacity `onAccent`.
2. HE_Resume ring: reads W4c's reading fraction (standing ruling 5). Until that contract is merged
   into this branch, build the rest of Task 3 and list the ring under "Waiting on a contract".
3. Task 8 "Your mocks" waits for W4e's mock history; build the rest of Task 8 with the section
   left out and listed. Go on through the plan; do not stop for these.

4. Added October15: Task3 Reviews launch/Continue and any numbered batch metadata consume
   W4d Task4's guarded review-batch contract (current L3-W4d storage ruling). It lands independently
   of Home widgets. Until integrated, omit only those controls under the standing missing-contract
   rule; no local batch, inferred ordinal or mixed-Today substitute. Home and Quiz consume the
   same real membership/chunks. Captured batch settings persist until finish/discard.

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


## Shared Today dependency available, October23

Reviewed source cd283f7b is integrated/uploaded on agreed development4113ad78. W4d's dependency is complete, without unrelated W4b screens. Task3 consumes lib/features/home/application/today_questions.dart (TodayQuestionLauncher, todayQuestionLauncherProvider, TodayQuestionWork, TodayQuestionKind) and lib/core/ui/components/today_questions.dart (TodayQuestionRow, TodayQuestionsSheet), with existing PantasSheet. Capture the launcher's guard at the original page request; retain the same originalGuard through load/error retry and caller lifetime/generation through start. Do not rebind after account/exam/wipe changes. Use actual stored chunks/New membership; missing content fails recoverably, unrelated paused work survives. New last-row divider is false. Preserve batch preferences/answers, shared defaults and real source metadata. No duplicated quiz presentation, inferred figures or mixed Today substitute. Remaining approved W4b tasks and server roadmap coordination remain queued. Evidence: https://github.com/Aedwon/Pantas/blob/4113ad7844f991d9a858c3771be21974270e9340/docs/superpowers/plans/new-design/evidence/W4d.md.


## Lead ruling, October24: necessary C9/C10 completion after Sonnet takeover

User: "continue and finish work on W4b. i authorize you to take over sonnet".
This continues approved balanced PWA behavior. Accepted server source0c17bfb0 remains immutable; new work is isolated on codex/w4b-server-dependency. Native metrics/roadmap math on that source and accepted development4113ad78 is identical. Main policy159afc7f and current workflow control. No unrelated payment, deployment, content, platform or publication changes.

The server currently exports BuildRoadmap only: history is always empty; original day membership, remaining work and advance are absent; lessons always have readAt:null. C9 has no client sender. These are real necessary dependencies, not permission to manufacture client-only web authority.

### Technical scope and simplification

Reuse server_dart and its compiled-Dart bridge, not a new package/runtime/framework. Extract native metrics row aggregation into pure functions used by BOTH existing native readers and the server; preserve windows, thresholds, statistical evidence and archetype rules. This supersedes only the older C10 suggestion to introduce a separate shared package. No new dependencies or native SQL/Drift schema. Existing server-only Firestore event/day/history/derived records are authorized C9/C10 storage; verify deny-client rules.

Server lane owns functions/src/{roadmap,ingestSession,_answers,_examContent,_core,index,serverReviews}.ts, new studyObservations.ts/studyInsights.ts, server_dart bridge/codecs/reference/fixtures and metrics/signals pure extraction/readers/tests. Client lane owns Home/Progress/roadmap presentation/providers/routes, metrics labels/catalog/templates, feature-local API/cache/sender and related tests. Client retains roadmap/domain ownership for Sunday week display and the approved plannedLessonsForDay query; server consumes that same query after handoff. No parallel edits to shared pure files. Lead integrates and personally reviews student-data and entitlement paths.

Do not add a server Record/streak engine in this dependency. Your record keeps its existing measured local data and combines accepted authoritative web mock history without double counting. C10 completion here covers authoritative roadmap, performance depth, profile/tendencies and When you work. No inferred historical streak/settings.

### Measured observations

Extend ingestSession compatibly with paired optional examId/origin and optional per-answer responseMs/questionVersion. New senders provide actual stored values; validate origin and content membership. Public ingest cannot claim mock origin or internal mock IDs. Old payloads remain valid, but ambiguous legacy attribution/timing is absent from metrics needing it. Preserve existing all-answer totals and accepted client-supplied correctness trust limit. Seed ordinary reviews through the existing native scheduler; preserve accepted mock mirroring, deduplication and due-feed behavior.

Add recordLessonRead({lessonId,readAt}), authenticated including anonymous, App Check and bounded/rate-limited. Validate actual authored lesson and timestamp; idempotently preserve earliest actual read observation. The client sends only after existing markRead persistence and can upload actual historical stored readAt, never reconstructed activity. Finished-session and lesson retries bind original account/exam/core generation and immutable payload, survive recoverable network failures, and never resend one account's data as another. Use existing persisted session/progress sources instead of a parallel sync framework.

Missing mock flags, measured answer times or section clocks stay absent; no divided session-time proxy or invented observations. Authored C7 catalog supplies exact subjects/topics/lesson ownership/order; never derive metadata from slugs.

### Roadmap read and mutation contract

Preserve existing getRoadmap tier/state/today/comingUp/history fields. Add explicit examId, serverNow, accessRecheckAt, proCovered, revision, remaining, originalDone, canAdvance and current-week observed day statuses. Every request binds explicit original exam/account; stale settings/event/content revisions cannot overwrite a newer selection. Persist one full native DaySnapshot per exam/Philippine day and RoadmapDiff events server-side. Ordinary completion changes remaining, not original quota. Rebuild native digest only for native shaping changes. Keep full digest/global topic order server-private.

Public Today includes only that day's plan/state/completion plus todayTopicOrder restricted to topics represented by its actual membership. Never return full future scope/topic order/digest in a Free snapshot. Unknown past snapshots remain unknown, not fabricated missed days.

Add advanceRoadmap({examId,requestId,expectedDay,expectedRevision}); validate actual originalDone and current ownership/day/revision transactionally. Retry the same immutable requestId returns its original result, never another advance. Reuse native DaySnapshots/PlanningWindows/StudyDays behavior through the bridge. Add getRoadmapDay({examId,date}) and getRoadmapWeek({examId,start}) with the same authoritative data and the client's shared future-lesson query. Pro future readers may proceed. Free future-day access is pending Aedwon's explicit choice because Home week-strip taps and the Pro future-plan rule conflict; do not silently settle it in code.

History uses actual native cause events and approved sentences, no invented historical reasons. Paginate with a stable server cursor; show five then ten per existing design. NewDay/prerequisite-cycle do not become public history.

### Insights and access

getStudyInsights({examId}) returns serverNow/accessRecheckAt/proCovered plus allowed models. Reuse existing mockCoverage for current EXAM coverage, not generic pro token. Free profile is expressly allowed by YO_Free/DECISIONS; Free may receive public profile and overall/subject performance only. Topic/lesson performance, five tendency findings and When you work require current exam coverage. Raw paid signals, hidden findings and full future roadmap never reach Free. Missing data returns actual insufficient-data models without fabricated figures.

Clients clear/suppress paid cached data on account/core/exam changes and at access expiry, refresh authoritative reads, and invalidate roadmap/insights at actual terminal-session/read boundaries. No client web fallback computes hidden Pro sections. Native behavior remains.

### Verification and acceptance

Regression-first server emulator cases: original day remains stable after completion, repeat advance idempotence/concurrent ownership, settings/exam revision races, real history and missing past dates, exact exam coverage/expiry and Free payload exclusions, legacy missing metadata, normal review seeding, C8 mock due-feed preservation and immutable observation retry. Native pure calculations and VM/JS outputs must agree with actual sparse/full fixtures. Focused checks during work; final Functions plain/emulator/bridge checks and combined Flutter/static checks before acceptance. One independent family audit plus bounded corrections; lead owns integration. Aedwon phone visual/live staging and release remain separate.


### October24 original account envelope correction

New W4b observation/settings/advance writes carry immutable expectedUid captured with the original owner. The server compares it with request.auth.uid before reading/writing and always derives paths from authenticated uid. Local pre/post checks alone cannot prevent the Firebase singleton token changing between the check and actual request dispatch. Reject mismatches; never rebind an old retry. Preserve existing legacy endpoint compatibility without making new W4b callers omit this expectation. Add actual client/token-switch and server mismatch regressions. This is a technical correctness requirement under the existing account-bound data scope, not new entitlement behavior.


### October24 Free future-date access decided

Aedwon selected exactly "Pro invitation for future dates". Both client and server enforce it: Free past/current-day views retain actual data; any future-date/week planning tap opens the existing approved Free plan invitation (DP_PlanFree), with no future lesson/topic payload or local computation behind it. The alternative was current-week future lessons free, later weeks Pro. Recommendation selected preserves the approved future-plan selling point at the cost of requiring Pro for future-day preview. Use existing invitation presentation; no new layout or copy.


### October24 HP_ExamDay warm-up contract

Source review confirms DaySelector already orders due reviews by descending scheduler retrievability, then due date/id. HP_ExamDay's approved optional warm-up uses the first at most10 of that existing ordered selection on the exact exam day, including a non-study weekday, with no lessons/new material. This is a bounded cap over the named existing selection, not a new easy-question classifier or fabricated difficulty/recall threshold. Board 'easy' denotes this highest-estimated-recall order; it is not a guarantee or authored difficulty claim. Display the ACTUAL returned membership count in every sentence/row, never the sample10 when fewer exist. With zero actual eligible reviews, omit the optional warm-up row/start/count claim. The existing guarded review launcher consumes that exact stored membership, preserving batch preferences/answers. Keep native/web parity via the same shared engine, and never infer questions from a count. Add exact exam-day, rest-weekday, fewer-than10/zero, actual order, no-new-material and launch-membership regressions. Server consumes the client-owned pure engine change after handoff.
