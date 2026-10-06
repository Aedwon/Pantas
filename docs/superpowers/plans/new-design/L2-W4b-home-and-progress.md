# L2 W4b: Home and progress

Level 2 workstream plan. Date: October 6, 2026. Author: lead. Policy revision: origin/main 12fb353b. Revised after the level 2 gate review (Oct 6).
Parent: strategy B2, B4. Spec: amendment spec (approved Oct 5). Depends on: W1, W2, W3 (Pro gates), the roadmap engine (already on the branch).
Traceability: 151 rows with workstream `W4b` (61 boards, 90 other items).

## 1. Purpose and scope

Rebuild Home and everything it opens, as the Home page draws it: week strip and exam chip,
greeting, notices, Today checklist with its sheets and advance, states and empty days, Your
performance (half ring, subjects, the Topics and Lessons screen), More about you (Your record, Your
tendencies with profile cards), and Your plan (Today line, Coming up timeline, History, weeks, days).
Retire the Progress tab screens.

Out of scope: The lesson reader (W4c), quiz screens (W4d), mock screens (W4e), Wrapped history (W4g), the notification service (W4f).

## 2. Inputs

Boards (61): HP_Free, HP_Pro, HP_Day, HP_NoDate, HP_MonthOnly, HP_Trial, HP_ProWelcome, HE_BeforeAssessment, HP_ExamDay, HP_ExamPassed, HP_NoContent, HE_ManyLessons, HE_BackAfterBreak, HE_MockDay, HE_Everything, HE_NothingDue, HE_NothingDueReview, HE_DayOff, HE_ReviewWeek, HE_LastDay, HE_Resume, HE_CarryOver, HE_AdvanceAgain, HE_MockMoved, HE_MockDropped, HE_LongTitle, DP_PlanA, DP_History, DP_HistoryEnd, DP_PlanFree, DP_Error, DP_Drill, DP_Week, DP_WeekCustom, DP_Day, DP_DayRead, DP_DayPast, DT_TopicsA, DT_TopicsView, DT_LessonsView, DT_SortFlow, DT_FilterFlow, DT_SubjectTap, DT_SubjectTapFree, DT_Topic, DT_Free, DT_Error, YR_Full, YR_RestDay, YR_FirstWeek, YO_Pro, YO_ProNew, YO_Free, YO_Error, YO3_Profiles, YO4_Picks, L_PlanSlow, L_ProgressSlow, YR_Wrapped, YR_WrappedFree, HP_Service.

Other traceability rows (90): D-9, D-10, D-11, D-12, D-13, D-14, D-15, D-46, D-48, D-49, D-50, D-51, D-52, D-53, D-54, D-55, D-56, D-57, D-58, D-59, D-60, D-61, D-62, D-63, D-64, D-65, D-66, D-69, D-71, D-72, D-73, D-74, D-76, D-77, D-78, D-79, D-80, D-81, D-82, D-83, D-84, D-85, D-86, D-87, D-88, D-91, D-92, D-93, D-94, D-95, D-96, D-97, D-99, D-100, D-103, D-104, D-105, D-106, D-107, D-108, D-109, D-110, D-112, D-236, D-237, D-238, D-252, D-254, D-277, R-13, R-16, S0-10, S0-11, S0-12, S0-13, G-a-32, G-b-3, G-b-4, G-b-6, G-b-7, G-b-8, G-b-9, G-b-14, G-b-15, G-b-17, G-b-19, G-b-20, G-b-21, G-h-9, G-h-25.
Each row's status column in `traceability.md` is binding; "lead default" rows are listed in
section 4 where they shape behavior. Superseded sections of older specs for this family: amendment
spec B1 (rows naming this family's screens); those sections are not built.

## 3. Contracts

Owned. Routes live in this family's route file  (W1 creates it);
W1 removes retired routes and this family deletes the screens behind them:
- `/home` root (W1). New: `/plan`, `/plan/week/:start`, `/plan/day/:date`, `/performance`,
  `/performance/topic/:topicId`, `/record`, `/tendencies`. All pushed with `context.push`.
- Retired: the `/progress` branch, `/progress/how-you-work`, `/progress/your-record`,
  `/plan/dossier/:mockId`.
- Notice priority and dismissal state; Today sheet state.
- `LessonDayContext { date, lessonIds, index }` passed to `/lesson/:lessonId` from Home and the day
  screen (consumed by W4c).
- `tableOrderProvider` and `retainTableOrderProvider` (the existing names, moved from
  `lib/features/progress/application/table_order_prefs.dart` into this family before
  `lib/features/progress/` is deleted; `home/application/topic_accuracy_provider.dart`, which imports
  the progress feature, moves with them); W4f's Appearance writes `retainTableOrderProvider`.
- Your record extension slot after Your mocks, filled by W4g's `WrappedRecordRow`.

Consumed by reference: W1 tokens, type, icons, curves, effects, dates, shell; W2 components; W3 `coversExam` for Pro sections; W4f reminder settings for nothing visible; roadmap engine outputs.

## 4. Behavior

- Today comes from the roadmap engine; Free and Pro Today look the same and Free has no cap (D-51).
- Overall accuracy counts every finished session (D-15). Subjects, topics and lessons with no
  answers do not appear (D-110). Accuracy bars follow D-111.
- Notices (D-65, D-66): one at a time in this order: service message, trial ending, welcome to Pro,
  no date, month only (Aedwon, Oct 6, gate F-19). Close rules per D-66; a closed service message stays closed until
  its text changes (G-h-25). Trial copy per D-254.
- States replace Today: before the assessment (only week, greeting, assessment card; no quick quiz,
  S0-16), exam day, exam passed, no content (D-63, D-65). Choose your exam fallback (S0-32).
- Empty days, advance and carry-over per D-52 to D-62; mock row and skipped mock per D-52, D-58.
- Your performance per D-102 to D-112 and the Free card (D-105); a topic page with Practice This
  Topic (D-104). Remember table order is a Settings value (W4f) read here.
- Your record per D-76 and D-77 (streak not on Home); YR_Wrapped row links to W4g.
- Your tendencies per D-78 to D-88: 12 labels and lines, figures hidden until a tendency is clear,
  How you work folded in; no label yet shows the name only (G-b-17).
- Your plan per D-89 to D-100 and D-237: History (Pro) with See more and the end line; Free sees
  gray shapes and one Unlock with Pro; only week rows drill down (G-b-19); plan states follow Home
  states (G-b-20); History sentences for causes without a board (Aedwon, Oct 6, gate F-19):
  exam switched "You switched to <exam>. Your plan was rebuilt for it."; exam passed "Your exam date
  passed. Your plan waits for a new date."; date removed "Your exam date was removed. Your plan is
  rebuilt when you set one."; assessment "Your plan was built from your assessment results."; the
  topic-order (prerequisite cycle) fix writes no entry. Weeks run Sunday to
  Saturday; rest days read "Rest day".
- Discarded per stage 0: lessons-read total, Lately line, Your pace, time column and why-you-miss
  display (recording stays, W0), spaced-repetition explainer (S0-10 to S0-13, S0-15).
- Charts keep screen-reader summaries (G-b-14). Greeting bands unchanged (G-b-9).
- Free and Pro per D-236 to D-238 via W3 `coversExam`. Placeholders: none.
- Replaces every retired Ink component and `showInkSheet` call in its own screens with W2's components; its sheet call sites: subject scope sheet (`stage0/gap-h-shell-states.md`).

## 5. Motion

Most Home boards animate (HP_Day timeline, notice open and fold, ring fills, plan entrance D-94, timeline draw D-93, Your performance load D-103, tendency pictures D-87).
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
- Lessons for future days: the engine gives topics per week, not lessons per future day (D-100 note). The level 3 plan adds the engine query the day screen needs inside the roadmap module, without a schema change; if a schema change is needed, stop.

## 8. Files and directories

`lib/features/home/`, `lib/features/roadmap/` (presentation and engine queries only), `lib/features/progress/` (deleted after replacement), `lib/features/metrics/` (labels and sentences, D-88), routes, tests.

## 9. Order and parallelism

After W2 and W3. Largest family; the level 3 plan splits it into Home, plan, performance, and record and tendencies tasks that can run in two worktrees, all editing only `lib/app/routes/home_routes.dart` in a stated order. Landing order for consumers: the `LessonDayContext` task before W4c's reader-from-Home task; the `retainTableOrderProvider` move before W4f's Appearance task and before `lib/features/progress/` is deleted; the Your record slot before W4g's history task. W4h's pattern task lands before this family's state screens.
