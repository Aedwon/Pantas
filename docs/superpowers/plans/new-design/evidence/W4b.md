# W4b: Home and progress evidence

## Identity and scope

- Policy retrieved from Aedwon/Pantas main after `git fetch origin`: `e354ebe3c37e2d23a035f79da393c4e0da94a33e`.
- Read AGENTS.md, WORKFLOW.md, SUBAGENTS.md and linked policy records at that revision.
- Assigned source base: `2d438daf460df32e73691f9dbae1ef68356d8ed1`, branch `web/new-design-w4b-r1`.
- Task documents: L3-W4b, L2-W4b, W4b traceability rows and amendment spec read from the same main revision. Later restart decisions and L3-W2 lead rulings read there.
- Shared state contract read first in this worktree: `drafts/state-patterns.md`.
- Design sources read only from `/Users/aedwon/Documents/Projects/Pantas/docs/design/`. No writes to that checkout.
- October 5 restart authorization applies only to this approved work. Other engineering pauses and the application-code freeze remain. No push or merge authorized or performed.
- Relay availability: `gh api repos/Aedwon/chatgpt-terminal-relay/actions/runners` returned the primary Mac runner online and idle. This assigned local worker uses its existing isolated worktree and local terminal. No delegation or hosted workflow launched.

## Current status

Task 1 committed at `c3b053cc4697176dc4c40b236ff69a08fb0583f6` and task checks complete.
Task 3's independent reader contract committed early at `234c761f385333da01831b2bb03b863773dbbdf1`. This supplies the type W4c consumes; it does not finish Task 3's checklist, sheets or route callers.
Task 2 implementation is committed at `448e49d46a592e204d0278f1fc2449f07ae4e682` and its required local checks are complete. The day destination remains intentionally unwired because Task 7 owns that route.
Independent Astra review, integration and Aedwon visual acceptance remain outside this worker's scope. This worker did not start Task 3 or any later task. No claim of family completion, combined acceptance or visual acceptance.

## Task 1: preserve data while retiring the Progress family

Moved, without changing behavior:

- `lib/features/progress/application/table_order_prefs.dart` to `lib/features/home/application/performance/table_order_prefs.dart`.
- `lib/features/progress/application/performance_provider.dart` to `lib/features/home/application/performance/performance_provider.dart`.
- `lib/features/home/application/topic_accuracy_provider.dart` to `lib/features/home/application/performance/topic_accuracy_provider.dart`.
- `lib/features/progress/application/progress_providers.dart` to `lib/features/home/application/performance/progress_providers.dart`.
- `record_provider.dart`, `how_you_work_provider.dart`, `miss_causes_provider.dart` from Progress application to Home application.
- Existing provider tests moved beside their new owners. Test helper relative imports adjusted for the deeper performance directory.
- Existing Home and Progress callers now import their providers from Home. No screen was restyled.
- One cross-family edit: `test/features/quiz/application/roadmap_today_launch_test.dart`, one import path only. It consumes the moved topic-accuracy contract. Its behavior stays unchanged.
- Table-order storage keys and all provider names remain unchanged. The pace provider stays until Task 10.
- Mechanical body comparison against the base: `7 moved implementation bodies unchanged` (imports excluded).

### Verification

Baseline source `2d438daf460df32e73691f9dbae1ef68356d8ed1`:

1. Initial focused baseline could not compile because ignored generated Dart files were absent. Stopped that run before judging source failures.
2. `dart run build_runner build --delete-conflicting-outputs`: exit 0, `Built with build_runner/aot in 49s; wrote 2802 outputs.` The installed runner warns the obsolete flag is ignored. No generated outputs are staged or committed. No signed content package regenerated.
3. `flutter test --no-pub --reporter expanded test/features/home test/features/roadmap test/features/progress test/features/metrics`: exit 0, `01:09 +604: All tests passed!`.

Test-first move:

- Existing behavioral provider tests copied to their new locations and changed to consume the planned Home imports before moving production files.
- `flutter test --no-pub --reporter expanded test/features/home/application/performance test/features/home/application/record_provider_test.dart test/features/home/application/how_you_work_provider_test.dart test/features/home/application/miss_causes_provider_test.dart`: exit 1, expected missing planned source libraries. This is a module-location contract failure, not an invented behavioral regression.
- After the move, `flutter test --no-pub --reporter expanded test/features/home test/features/roadmap test/features/progress test/features/metrics`: exit 0, `01:07 +604: All tests passed!`.
- `flutter analyze --no-pub lib/features/home/application lib/features/progress test/features/home test/features/progress test/features/quiz/application/roadmap_today_launch_test.dart`: exit 0, `No issues found! (ran in 2.9s)`.
- Full `flutter analyze --no-pub`: last full run exit 1, `13 issues found. (ran in 4.5s)`. One moved-test import-order issue was then fixed and confirmed by the scoped check. Twelve findings are outside W4b: one deprecated bookmark API and eleven index-layout test style findings. No exception is inferred for them; lead action is required before full acceptance.
- `dart format --output=none --set-exit-if-changed lib test`: exit 1, `Changed test/tool/firebase_indexes_layout_test.dart`, `Formatted 1430 files (1 changed) in 2.85 seconds.` Output mode `none` left that unrelated file untouched. W4b requires no format change.
- `dart run tool/check_layering.dart`: exit 0, `check_layering: OK`.
- `dart run tool/check_no_ai_attribution.dart`: exit 0, `check_no_ai_attribution: OK`.
- `flutter test --no-pub --reporter expanded test/features/quiz/application/roadmap_today_launch_test.dart`: exit 0, `00:01 +8: All tests passed!`. This verifies the one mechanical cross-family import.
- `git diff --check`: exit 0, no output.

Raw logs remain in `.superpowers/sdd/L3-W4b-home-and-progress/`. Required result excerpts are preserved above. Full Flutter suite has not run; it is reserved for family completion. Backend is unchanged and not run. Visual checking belongs to Aedwon and has not occurred. Current program STATUS and external SSOT updates belong to the lead; this evidence records worker progress without combined acceptance.

## Task 2: week strip, exam chip and greeting

Implementation commit: `448e49d46a592e204d0278f1fc2449f07ae4e682`.

- The Home week strip is Sunday-first through `PantasDates.weekStart` and derives done, partial, missed, day-off, future and today states from the stored roadmap plus the roadmap completion facts. Today's ring uses completion over the day's original planned work.
- The exam chip implements the approved no-date, month-only, future exact-date, exam-day and passed states. The October 12 contrast ruling is applied: exam-day accent text uses full-opacity `onAccent`.
- The greeting uses the approved time bands. The student's name and the old settings affordance are not rendered in this board family.
- Light/dark, 200% text and reduced-motion behavior are covered by the focused widget test.
- The week-strip tap deliberately performs no navigation in Task 2. Task 7 owns `/plan/day/:date`; no later-task route was added.

### Task 2 TDD and verification

- Approved board tooling: `outline.py` and `timeline.py` across `HP_Free`, `HP_Pro`, `HP_NoDate`, `HP_MonthOnly`, `HP_ExamDay` and `HP_ExamPassed`: exit 0. No screenshot capture or visual acceptance was performed.
- RED: the focused Home masthead/provider tests failed before production changes because the planned Task 2 provider/widget APIs did not exist.
- Focused final check: `flutter test test/features/home/presentation/widgets/home_masthead_test.dart test/features/home/presentation/home_week_strip_provider_test.dart`: exit 0, 7 tests passed.
- Required family check after the final owned lint fix: `flutter test test/features/home test/features/roadmap test/features/progress test/features/metrics`: exit 0.
- Full baseline before the formatting-only lint fix: `flutter test`: exit 0, 3969 tests passed. Full rerun after that final lint fix: `flutter test`: exit 0.
- `flutter analyze`: the Task 2 finding was fixed. Final result contains only the already accepted W4c bookmark `onReorder` deprecation in `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart`; there is no W4b analyzer finding.
- `dart format --output=none --set-exit-if-changed lib test tool`: exit 0, 1460 files formatted, 0 changed.
- `dart run tool/check_layering.dart`: exit 0, `check_layering: OK`.
- `dart run tool/check_no_ai_attribution.dart`: exit 0, `check_no_ai_attribution: OK`.
- `git diff --check` and the staged implementation diff check: exit 0.

Task 2 has no unresolved implementation limitation. Independent Astra audit, integration and Aedwon visual acceptance are still intentionally pending.

## Task 3: early reader contract

Commit: `234c761f385333da01831b2bb03b863773dbbdf1`.

Files:
- `lib/features/home/domain/lesson_day_context.dart`.
- `test/features/home/domain/lesson_day_context_test.dart`.

Interface for W4c: `LessonDayContext(date: DateTime, lessonIds: List<LessonId>, index: int)`. Fields have exactly the plan's names. `index` is zero-based. The constructor takes an immutable snapshot of the ordered lesson IDs and rejects an out-of-range index, including an empty list. Home and plan will send it in GoRouter `extra`; `from=home` remains the planned deep-link fallback. W4c owns the route's reader-side decoding. Home/day callers are not yet implemented.

This independent type does not depend on the unresolved exam-chip color. It was landed separately at the explicit request to make the reader contract available early. No other family's source or route was edited.

Checks:
- Failing test first: `flutter test --no-pub --reporter expanded test/features/home/domain/lesson_day_context_test.dart`, exit 1 because the planned class/library did not exist.
- Green: same command, exit 0, `00:00 +4: All tests passed!`.
- Family task check: `flutter test --no-pub --reporter expanded test/features/home test/features/roadmap test/features/progress test/features/metrics`, exit 0, `01:08 +608: All tests passed!`.
- `flutter analyze --no-pub lib/features/home/domain/lesson_day_context.dart test/features/home/domain/lesson_day_context_test.dart`: exit 0, `No issues found! (ran in 1.0s)`.
- `dart format --output=none --set-exit-if-changed lib/features/home/domain/lesson_day_context.dart test/features/home/domain/lesson_day_context_test.dart`: exit 0, `Formatted 2 files (0 changed) in 0.01 seconds.`
- `dart run tool/check_layering.dart`: exit 0, `check_layering: OK`.

## Complete Task 1 file list

The move is preserved as renames in Git. The full reviewed file list follows:

```text
A	docs/superpowers/plans/new-design/evidence/W4b.md
R100	lib/features/progress/application/how_you_work_provider.dart	lib/features/home/application/how_you_work_provider.dart
R100	lib/features/progress/application/miss_causes_provider.dart	lib/features/home/application/miss_causes_provider.dart
R099	lib/features/progress/application/performance_provider.dart	lib/features/home/application/performance/performance_provider.dart
R100	lib/features/progress/application/progress_providers.dart	lib/features/home/application/performance/progress_providers.dart
R100	lib/features/progress/application/table_order_prefs.dart	lib/features/home/application/performance/table_order_prefs.dart
R094	lib/features/home/application/topic_accuracy_provider.dart	lib/features/home/application/performance/topic_accuracy_provider.dart
R100	lib/features/progress/application/record_provider.dart	lib/features/home/application/record_provider.dart
M	lib/features/home/presentation/widgets/practice_panel.dart
M	lib/features/progress/presentation/pages/how_you_work_page.dart
M	lib/features/progress/presentation/pages/your_record_page.dart
M	lib/features/progress/presentation/progress_page.dart
M	lib/features/progress/presentation/widgets/gap_comparison.dart
M	lib/features/progress/presentation/widgets/level_control.dart
M	lib/features/progress/presentation/widgets/performance_section.dart
M	lib/features/progress/presentation/widgets/table_head.dart
M	lib/features/progress/presentation/widgets/why_you_miss_section.dart
R099	test/features/progress/application/how_you_work_provider_test.dart	test/features/home/application/how_you_work_provider_test.dart
R099	test/features/progress/application/miss_causes_provider_test.dart	test/features/home/application/miss_causes_provider_test.dart
R098	test/features/progress/application/performance_provider_test.dart	test/features/home/application/performance/performance_provider_test.dart
R096	test/features/progress/application/table_order_prefs_test.dart	test/features/home/application/performance/table_order_prefs_test.dart
R098	test/features/home/application/topic_accuracy_provider_test.dart	test/features/home/application/performance/topic_accuracy_provider_test.dart
R099	test/features/progress/application/record_provider_test.dart	test/features/home/application/record_provider_test.dart
M	test/features/home/presentation/widgets/practice_panel_test.dart
M	test/features/progress/mock_feeds_progress_test.dart
M	test/features/progress/presentation/pages/how_you_work_page_test.dart
M	test/features/progress/presentation/pages/your_record_page_test.dart
M	test/features/progress/presentation/progress_page_test.dart
M	test/features/progress/presentation/widgets/gap_comparison_test.dart
M	test/features/progress/presentation/widgets/level_control_test.dart
M	test/features/progress/presentation/widgets/performance_section_test.dart
M	test/features/progress/presentation/widgets/subject_scope_test.dart
M	test/features/progress/presentation/widgets/table_head_test.dart
M	test/features/progress/presentation/widgets/why_you_miss_section_test.dart
M	test/features/quiz/application/roadmap_today_launch_test.dart
```

## Questions and findings

1. Resolved for Task 2: `HP_ExamDay` uses the October 12 lead ruling, full-opacity existing `onAccent`, instead of the board value that failed active-text contrast.
2. Base full gates need unrelated index-layout test formatting/style fixes and the existing bookmark API migration. These are reported, not silently accepted or changed here.
3. Task 8 consumes W4e mock-history data. W4e is not integrated into the assigned base. Recheck the contract before dependent work; never build a local substitute.

4. Task 3, `HE_Resume`: the board draws a 24px partial lesson ring (stroke dash array `29.7 66.0`, about 45%) with `Resume` and `Resume Lesson`. At the assigned source, the reader computes offset/max extent only in a transient notifier; its controller saves the opened lesson ID and a binary read mark. It exposes no persisted measured reading fraction. W4c Task 1 plans offset persistence, but no shared fraction field/key is specified or integrated here. The lead must coordinate the measured fraction contract with W4c before Home draws this state. No sample 45% or guessed fraction was added.

## Handoff boundaries

- Task 1 is available for W4f's preferences consumer.
- Task 2 is implemented at `448e49d46a592e204d0278f1fc2449f07ae4e682` and locally verified. It is ready for the lead/Astra review path, but this is not W4b family acceptance or Aedwon visual acceptance.
- The Task 2 week-strip tap stays intentionally inert until Task 7 owns and adds the day route.
- The early Task 3 type is available for the lead to integrate before W4c Task 5. This worker did not start or modify the rest of Task 3.
- The full Flutter suite ran successfully for this Task 2 checkpoint. Later family tasks still require their own plan checks and final family review.
- No application screenshots, device/simulator work, deployment, merge, source revision change or signed asset regeneration occurred.

## Final automated handoff result

Source through `234c761f385333da01831b2bb03b863773dbbdf1`, followed only by this evidence update:

- Full `flutter analyze --no-pub`: exit 1, `12 issues found. (ran in 4.7s)`. Every finding is in the unchanged bookmark sheet or unchanged index-layout tests. Task-scoped analysis is clean. This is not a full-gate pass.
- Global format check remains exit 1 for the unchanged index-layout test. No W4b file needs formatting.
- Named family task check: exit 0, `01:08 +608: All tests passed!`.
- The one affected Quiz import check: exit 0, `00:01 +8: All tests passed!`.

Exact analyzer output:

```text
Analyzing Pantas-wt-new-design-w4b-r1...

   info • 'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. The onReorderItem callback adjusts the newIndex parameter for a removed item at the oldIndex. This feature was deprecated after v3.41.0-0.0.pre. Try replacing the use of the deprecated member with the replacement • lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21 • deprecated_member_use
   info • Unnecessary use of a raw string. Try using a normal string • test/tool/firebase_indexes_layout_test.dart:104:7 • unnecessary_raw_strings
   info • Unnecessary use of a raw string. Try using a normal string • test/tool/firebase_indexes_layout_test.dart:105:7 • unnecessary_raw_strings
   info • Don't use adjacent strings in a list literal. Try adding a comma between the strings • test/tool/firebase_indexes_layout_test.dart:106:7 • no_adjacent_strings_in_list
   info • Unnecessary use of a raw string. Try using a normal string • test/tool/firebase_indexes_layout_test.dart:107:11 • unnecessary_raw_strings
   info • Don't use adjacent strings in a list literal. Try adding a comma between the strings • test/tool/firebase_indexes_layout_test.dart:108:7 • no_adjacent_strings_in_list
   info • Unnecessary use of a raw string. Try using a normal string • test/tool/firebase_indexes_layout_test.dart:110:11 • unnecessary_raw_strings
   info • Don't use adjacent strings in a list literal. Try adding a comma between the strings • test/tool/firebase_indexes_layout_test.dart:111:7 • no_adjacent_strings_in_list
   info • Unnecessary use of a raw string. Try using a normal string • test/tool/firebase_indexes_layout_test.dart:111:7 • unnecessary_raw_strings
   info • Unnecessary use of a raw string. Try using a normal string • test/tool/firebase_indexes_layout_test.dart:119:9 • unnecessary_raw_strings
   info • Unnecessary use of a raw string. Try using a normal string • test/tool/firebase_indexes_layout_test.dart:126:9 • unnecessary_raw_strings
   info • Missing a required trailing comma. Try adding a trailing comma • test/tool/firebase_indexes_layout_test.dart:144:70 • require_trailing_commas

12 issues found. (ran in 4.7s)
```

## October24 continuation: isolated exam-day dependency

Policy refreshed through main73aa5b90; accepted4113ad78 merged by lead into worker27086aab. No worker merge/push. Ignored outputs regenerated successfully (relay11567, build/w4b/recovery-generation.log). Lead HP_ExamDay ruling: actual easiest-ordered due reviews, maximum10, including scheduled rest weekdays; no new difficulty classifier. RED11586 confirmed25 instead of10 and absent rest-weekday reviews. Domain GREEN11592:170 tests passed. Focused final result and analysis below. Other W4b screen work remains in progress and uncommitted. No family completion, independent review, visual acceptance or deployment claim.

00:00 +12: All tests passed!
Analyzing 2 items...
No issues found! (ran in 0.6s)

Shared future query checkpoint: RED11594 missing query; GREEN11600 domain174 tests; final focused/static output build/w4b/task7-future-query-final.log and task7-future-query-analysis.log. WeekPreviews.plannedLessonsForDay uses the existing future queue/pacing for actual authored IDs. Sunday grouping changes display boundaries only; StudyDays remains ISO. Task7 presentation is not complete.

## October24 native roadmap ownership slice

RED11603 reproduced same-identity wipe during delayed Today/advance inputs. RED11626 reproduced same-exam scope/date changes during pending hydration. Guard now retains original auth/preparer lifetime/core token, selected exam, date/study-day/scope/content/assessment shaping inputs and caller lifetime. Hydration runs outside writes; one feature-local per-database queue and guarded Drift transaction commit day and history together. Final token/auth/lifetime check follows all asynchronous guard reads. Task3-guard-final:28 tests passed. Native guard scoped analysis clean. No schema/core helper/framework added. This isolated correction does not complete Task3. Remaining screens and server client feed remain in progress.

## October24 saved Home/API/performance slices

Policy7fe91e30. Tests-first Task3 checklist/sheets and original caller guard, Task4 notice priority/pure states, Task5 measured card/sort/filter/Free/paused presentation, immutable expectedUid API, exact response models and original UID/exam/core encrypted cache are implemented. Public cache may restore immediately; paid cache waits for current server evidence after process restart. These are partial slices: Home root/routes, server reader/sender, topic route and complete motions remain pending. No family/task completion or visual/release acceptance claimed. Focused/static evidence:build/w4b/client-slices-focused.log and client-slices-static.log.

## October24 phase 3a partial continuation

Assignment: A2 through A6, B and C. Policy source: origin/main
94bfe9da3fd906c720bacf9f614496736cd42187. Execution source:
web/new-design-w4b-r1 at f0d19f94347f64b84e7b74db9766e876afae0d5e.
Reviewed server contract read from origin/codex/w4b-server-dependency
2c95a9d910daf49e3526804a8a481af35b298301. No fetch, merge, commit,
push, dependencies, generated-source edits or device screenshots.

### Item status

- A1: preserved the preexisting uncommitted preference dismissal implementation.
  Its original focused test command passed seven tests before other edits.
- A2: Lessons sheet now groups actual subjects in first-seen order and preserves
  lesson order within each subject. D-56/HE_ManyLessons rows contain no subtitles,
  duplicate Read label or navigation chevron. Existing lesson launch remains.
- A3: trial notice uses the timer; service uses the information circle. Date and
  welcome notices retain calendar and sparkle respectively. Welcome sparkle
  uses the board accent color. Uses existing
  Phosphor font per the approved final icon rule. No new font or dependency.
- A4: month-only notice contains its swipeable day row. Save remains disabled
  until selection and writes the selected actual date through existing settings.
  No month-only action opens another date sheet. Shared notice component gained
  an optional editor slot to place the row within the existing strip and
  optional icon color to preserve the welcome sparkle accent.
- A5: searched the boards, decisions, gap files, traceability and both plans.
  Kept current behavior. See unresolved decisions below.
- A6: kept current behavior. See unresolved decision below.
- B: performance subjects/topics/lessons and trial-end seams now consume existing
  authoritative server insights. Parent labels and topic counts use returned
  metadata/counts. Free response decoding suppresses depth. Existing guarded
  request/cache/expiry infrastructure remains. Today and topic detail are NOT
  implemented. No local web authority or substitute figures were added.
- C: NOT started. Work stopped at B's missing authoritative topic-detail inputs.
  No sender or settings-ordering completion is claimed.

### Stop condition: missing topic-detail contract

DT_Topic requires the topic's lessons, their read flags and the measured lessons
read count. At the specified reviewed server revision, getStudyInsights returns
performance rows only for lessons with answers. Those rows carry id, title,
parentId, correct and answered. It returns no lesson read flags or complete
ordered topic lesson inventory. recordLessonRead is write-only. getRoadmap's
remaining lesson membership describes Today only. It cannot establish the read
state of every lesson belonging to an opened topic. The client must not label
an answered lesson as read or count locally stored reads as authoritative web
figures. The existing recoverable topic-detail seam remains unchanged. The lead
must supply the missing authoritative inputs before this view can match its board.

### Open product decisions

1. HE_BackAfterBreak: the calm sentence is approved. Its exact trigger is not
   specified in the inspected board/decision/gap/plan text. Traceability G-b-9
   says to retain the existing Welcome back rule. Current implementation uses
   missedWork plus at least two missed study days since the prior snapshot;
   no inspected design record establishes that exact condition. Left unchanged.
2. HP_ProWelcome: no inspected record defines the destination of See What's New.
   G-b-8 settles notice priority but does not settle this destination. The board
   shows the action without a destination flow. Existing /performance target
   remains unchanged.
3. HE_NothingDue and HP_NoDate: HE_NothingDue shows the covered-everything line
   with an exam date. HP_NoDate shows reviews. Neither inspected board explicitly
   covers an empty planning day with no date and does not establish that it means
   all content is covered. The current Nothing due/covered-everything behavior
   remains unchanged. No new copy was written.

### Tests seen failing before implementation

- Lessons sheet groups subjects and omits row subtitles:
  Expected one MATHEMATICS heading; Actual zero.
- trial notice uses the board timer:
  Expected IconData U+E492; Actual U+E6A2.
- service notice uses the board information circle:
  Expected IconData U+E2CE; Actual null.
- welcome notice uses the board accent sparkle:
  Expected accent (#0B7A68); Actual secondary label (#6E6E73).
- month-only notice picks a day inline before enabling Save:
  Expected null onPressed before selection; Actual a closure.
- web performance uses authoritative counts and authored parent names, and
  Free web performance cannot publish topic or lesson depth:
  Bad state: Server insights reader is required.
- web trial end comes from actual server metadata:
  Expected 1790834400000; Actual null.

All eight new behavior tests subsequently passed. The focused final group passed
23 tests, including actual selected-day persistence. Temporary test-edit compile
errors were corrected before the final group; they are not red-stage evidence.
The initial broad baseline run was interrupted after 9:52 with 2431 passes while
the roadmap coverage property test remained active. Its shutdown errors are not
reported as a completed baseline failure. A new exact requested suite was started
on the final source.

### Changed files

- lib/features/home/presentation/home_today_screen.dart: A2 grouped sheet rows.
- lib/features/home/presentation/widgets/home_notice_strip.dart: preserved A1,
  A3 icons and A4 day row/save.
- lib/core/ui/components/notice_strip.dart: optional editor slot required to put
  the existing month-only board's row inside the strip. This shared file extends
  the family's directory list for necessary component reuse.
- lib/features/home/application/web_study_seam.dart: partial B performance/trial.
- test/features/home/presentation/home_today_screen_test.dart: A2 regression.
- test/features/home/presentation/widgets/home_notice_strip_test.dart: A1 retained,
  A3/A4 regressions and actual date persistence.
- test/features/home/application/web_study_seam_test.dart: B regressions.
- This evidence file: partial handoff and stop record.

No visual acceptance or exact animation acceptance is claimed. Read the
HE_ManyLessons and HP_MonthOnly board sources and ran their timeline tool from
origin/main, using ignored build copies because design assets are absent from
this worktree. Aedwon retains visual checking. Full account/exam/wipe race
verification of the newly requested C sender paths remains undone because C is
not implemented. The worktree does not contain new-design/STATUS.md; no current
SSOT update is claimed there. The lead must record this partial checkpoint.

### Static and focused verification

Commands on the final code, exit 0:

```text
flutter analyze lib test tool
No issues found! (ran in 5.5s)

dart format --output=none --set-exit-if-changed lib test tool
Formatted 1610 files (0 changed) in 3.46 seconds.

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK

flutter test test/features/home/presentation/widgets/home_notice_strip_test.dart test/features/home/presentation/home_today_screen_test.dart test/features/home/application/web_study_seam_test.dart
00:01 +23: All tests passed!
```

The final focused group includes the welcome accent correction made after the
broad suite started. It changes only optional icon color and has no data or engine
effect. Static checks were repeated after it. The exact requested broad command
and its result are recorded separately below when it finishes.

### Exact requested broad suite: incomplete

```text
flutter test test/features/home test/features/roadmap test/features/progress test/features/metrics test/core test/app
15:50 +2438 -1: Some tests failed.

Failing tests:
  test/features/roadmap/domain/coverage_property_test.dart: following the plan covers everything before review-only days (did not complete)
  test/features/roadmap/domain/coverage_property_test.dart: loading test/features/roadmap/domain/coverage_property_test.dart
```

I interrupted this run after 15:50 because the coverage property test remained
active. The 2438 other tests passed. Interrupting caused runner shutdown errors
(Cannot close sink while adding stream / Cannot add event while adding stream).
This is an INCOMPLETE gate, not an assertion failure attributed to this patch,
and not a passing suite. The earlier baseline also remained active on the same
unchanged property test when interrupted after 9:52. Its cause was not diagnosed
or changed. Logs: build/w4b-phase3a/tests.log and initial-baseline.log.

No changes touch the roadmap engine or its property test. Required independent
review, combined acceptance and visual checking remain with the lead/Aedwon.

Final tracked code/test patch SHA-256 (git diff -- lib test tool):
f9c172eafa28b3070519e39ac14b9a49f1eb8139567ae8b95f1e263d3fa35ecc.
New untracked web_study_seam_test.dart SHA-256:
9ac0e223db149be94e4d32e6feaef0e7872fa98d95f3196ca97cbb0d65cf1fe0.

```text
git status --short
 M docs/superpowers/plans/new-design/evidence/W4b.md
 M lib/core/ui/components/notice_strip.dart
 M lib/features/home/application/web_study_seam.dart
 M lib/features/home/presentation/home_today_screen.dart
 M lib/features/home/presentation/widgets/home_notice_strip.dart
 M test/features/home/presentation/home_today_screen_test.dart
 M test/features/home/presentation/widgets/home_notice_strip_test.dart
?? test/features/home/application/web_study_seam_test.dart
```

Seven modified files and one new test file remain uncommitted. No generated
outputs or dependency files appear in status. git diff --check passed.

## October 24 resumed lead brief: current uncommitted continuation

Policy read with `git show origin/main`: `94bfe9da3fd906c720bacf9f614496736cd42187`.
Client HEAD remains `06a917892198ebd773f7df9fcef3ac876f19a083`.
Server HEAD remains `2c95a9d910daf49e3526804a8a481af35b298301`.
Both supplied dirty patches were read and retained. No fetch, pull, commit,
merge, push, deploy, dependency installation, protected-content rebuild, or
app screenshot capture occurred. This is an incomplete implementation checkpoint,
not family acceptance.

### Work-list status

1. Part B: server-backed Today membership, remaining work, advance permission,
   observed week states and topic lesson read states now feed the existing
   client models. The public adapter is never persisted or passed to the local
   planner. Topic details and their paid caches suppress read flags on Free.
   The web Today extras remain incomplete: calm/carry-over/mock-change notes and
   mock duration lack a wired authoritative read. Paid cache restoration remains
   conservative after restart.
2. Part C: immutable session payloads retain actual start/finish, wall duration,
   origin, response times and versions. They omit per-answer answeredAt.
   Existing stored attempts/lesson reads are retried with original account/core
   receipts through the remote-read boundary. Settings writes serialize and a
   newer intent supersedes an old retry. Advance retains one request ID/day/
   revision across retry. Lesson completion now invalidates server reads and
   uploads its actual persisted readAt before refreshing. Native observation
   delivery and all settings/scope/assessment sender entry points are not yet
   verified as a complete platform matrix. Do not mark Part C complete.
3. Task 8: `/record` consumes the W4e history reader and the existing measured
   local record. Web mock totals/history come from that reader without writing
   local mock rows. The extension slot after Your mocks is exposed as
   `wrappedRecordRowProvider`; it draws nothing until W4g supplies a widget.
   Task 9: labels/identity lines, Deep Thinker, retired Pressure Tightener cache
   handling and the narrow native original-owner guard are implemented. The
   tendencies model uses approved no-figure sentences and study shares. Web
   formats only server-returned findings and confidence. `/tendencies` and the
   two Home rows are wired. Presentation is still incomplete against the boards.
   Tasks 6 and 7 are not implemented by this continuation.
4. Task 10 is NOT done. Old Progress/Home widgets and legacy route redirects
   remain. Week-strip taps and View full plan remain unwired.
5. This evidence and the server evidence are updated, with final commands below.

### Decisions and source gaps

- The cited `4113ad78` Home masthead lines 73–84 contain the `<12`, `<18`
  greeting hour bands only. `git grep -i 'welcome.back' 4113ad78 --
  lib/features/home` returns no match. The only all-history introduction found
  by `git log --all -S 'Welcome back' -- lib/features/home` is the later
  `c8b3e32d` implementation. Therefore the requested historical trigger cannot
  be recovered from that cited source. Current native behavior is preserved;
  no replacement trigger was invented. Board HE_BackAfterBreak / G-b-9 remains
  unresolved for exact historical-rule restoration.
- HP_ProWelcome already targets `/performance`; the binding destination stays.
- HE_NothingDue / HP_NoDate: keep the existing no-date empty-day behavior, as
  explicitly instructed. No new copy or coverage claim was authored.
- DP_History: stored native changes carry cause, time, count changes and first
  topic names/IDs. They do not retain every historic exam date, scope change,
  affected content kind or study-day setting needed by the board's exact
  sentences. A fallback for older rows must be settled before inventing their
  missing details. No history sentence was fabricated in this continuation.

### Independent review and fidelity limits

A read-only independent reviewer inspected both dirty patches. They confirmed
missing lesson-read invalidation and missing web Today extras. The former has a
regression-first correction. The latter remains incomplete.

The reviewer proposed that watching a StreamProvider `.future` permanently kept
its first cached public result. A controlled public-then-Pro StreamController
regression passed against the existing production code: the derived performance
model changed from zero topics to one. This finding was declined on observed
behavior, and that regression is retained.

Known D-83 / YO4_Picks differences in the initial tendencies presentation:
pressure scale ticks/drop segment, Stamina percentage and 1H/2H labels, and
extra-time-only coloring still require correction. D-81 Strong Recall and
Thorough Reviewer still need their check detail. Full board motion and the
constant profile-card height are not accepted. No 1:1 visual claim is made.

### Test-first evidence and test environment corrections

Behavioral RED observations in this continuation:
- Approved tendency sentences/shares failed against the old numeric sentences
  and read/answered counts; the updated model tests subsequently passed.
- Web record with server-only mock history expected 10 questions and received 0;
  the updated reader integration subsequently passed 19 record tests.
- A persisted lesson read followed by roadmap revision expected a second
  settings/read-observation/insights sequence but received only the original
  two requests; revision observation now triggers that actual sequence.
- New Today adapter, sender, server tendency formatter and screen APIs were
  introduced with tests that first failed to compile because their planned
  production APIs did not exist. These are API-contract REDs, not semantic
  failure observations. Setup/compile errors from missing test imports are not
  counted as behavioral RED evidence.
- The inherited profile guard race tests initially timed out before entering
  their delayed signal because initial authentication had not been awaited.
  Corrected setup reaches the actual boundary. All nine tests passed.
- The prior run's original RED evidence for inherited server topic details and
  archetype changes was not recovered. No new claim is made about having seen
  those changes fail before their original implementation.

One test run was invalidated by overlapping automatic fixes and formatting,
which damaged new test text. The damaged tests were repaired and focused checks
passed. Source/style mutations are now sequential. A broad run also encountered
three transient missing-sqlite-library errors while other test processes rebuilt
native assets. These are recorded failures, not accepted exceptions. Final full
verification must run without another Flutter test in the same worktree.

Raw commands/results are retained in `build/w4b-resume/` (ignored). A separate
pure-Dart probe confirmed that the roadmap property test was spending hundreds
of milliseconds per daily rebuild, not waiting on a device or network.

### Necessary shared calendar performance ruling

The long preview regression failed at 60.553789 seconds. Profiling the daily
rebuild showed that planning-window construction also calls the existing
`StudyDays.countInRange`, not only the future query. A direct 400-year count
regression also exceeded its two-second budget. The correction belongs in that
existing pure count: full weeks plus at most six remaining weekdays, with all
127 weekday selections checked against calendar iteration over seven starting
weekdays and seven ranges (negative, empty, partial week, full week and year
crossing). No schema, framework, scheduling policy or student-facing figure is
added. `lib/core/time/study_days.dart` is the one additional production file
outside the original task file table. Both worktrees receive identical source.
The intermediate WeekPreviews optimization is removed as unnecessary. The
original future lesson-query implementation remains intact.

### Final scope correction and additional regressions

This section supersedes earlier continuation wording about settings writes on
read. Opening Home/performance must not overwrite an existing account's server
settings with a restored device's local defaults. A read-safety regression saw
`setExamSettings, getStudyInsights` when only the authoritative read was allowed.
Read-time settings publication was removed. `StudyWrites` and immutable advance
requests are tested, but explicit settings/onboarding/scope/assessment sender
entry points are still NOT wired. Part C remains incomplete. Do not infer full
sender completion from its queue tests.

Additional RED-to-GREEN corrections:
- A superseded settings caller completed before its replacement was accepted.
  Two-intent and three-intent tests now require the caller to wait for the actual
  latest accepted write; errors retain the immutable retry.
- A stale local Pro state exposed the Topics table despite current web server
  coverage being Free. Web gates now use current authoritative coverage; paid
  screens discard retained previous data while loading/error states change.
- Public cache restore retained a past paid recheck deadline. The regression
  expected null and received 101. Restored public models now have no paid expiry
  timer; only fresh authoritative responses schedule access rechecks.
- Web Today's week ring counted advanced work against the original day. The
  regression expected 1 and received 0.5. Both platforms now exclude advanced
  membership from that original-day fraction.
- Web Home incorrectly used a missing local assessment result to hide actual
  server Today. The restored-account widget regression now shows authoritative
  Today without requiring a local assessment row.

The shared calendar correction also fast-paths every-day membership and counts
complete weeks without constructing local midnights. The future query retains
one remaining-study-day count and decrements it exactly once per emitted study
 day. A temporary duplicate decrement was caught by the existing exact-membership
 tests and removed. Both shared files are byte-identical across worktrees. No
quota, topic order, weekday convention, schema or planning rule was changed.
The source file additions outside the initial file table are the existing core
calendar helper and its bounded-cost/exhaustive weekday tests. Earlier wording
that the intermediate query refinement was removed is superseded here.


## October 25 continuation: completion audit

The user explicitly selected local policy/workstream revision
`2329b9ee7d404c7e6e750ba375cf1391613c7d0f`. Both worktree HEADs remain
`06a917892198ebd773f7df9fcef3ac876f19a083` (client) and
`2c95a9d910daf49e3526804a8a481af35b298301` (server). At startup the local
origin/main ref was already `6378b0f9fa1387bd155a7616ef522209d95bedf8`.
The diff from the selected revision touches content guides/checklist, the PWA
log, and its resume record. It does not change the selected policies or W4b
controlling documents. No fetch or pull was performed. All supplied dirty
changes were retained. No commit, merge, push, dependency, deploy, package
rebuild, or app screenshot capture was performed.

The preceding October 24 status is a historical checkpoint. The actual supplied
patch at this continuation already includes the plan/day/week route wiring,
web Today extras, settings sender entry points, and Task 9 chart corrections.
The following source inventory supersedes its statements that these are absent.

### Source inventory and remaining contracts

- Part B: Today uses original/remaining server membership, actual observed week
  states, server advance permission and public Today extras. Extras return the
  actual previous stored day, its mock flag, today's missed-work event, stored
  weekdays, and authored blueprint duration. They expose no future plan/history
  to Free. Topic detail uses authored lesson inventory and stored read flags,
  with fresh exam-specific paid coverage. Shared-topic catalogs include lessons
  without questions. Public cache restore remains possible; paid restoration
  after restart waits for fresh server coverage.
- Part C: app lifecycle observes terminal quiz and lesson/roadmap revisions on
  native and web. Stored immutable attempts and lesson reads are retried under
  the captured UID/exam/core. Sessions preserve actual start/finish/wall time,
  origin, response time and question version, without per-answer answeredAt.
  Mock submission keeps W4e's existing atomic server observation path.
- Settings sends occur only after explicit local mutation. Entry points include
  onboarding finish and study-day selection, assessment completion, date save
  and clear, study-day updates, exam switching, and topic/subject scope changes.
  Each capture reserves ordering before hydration; failed local mutations cancel
  it. Publication checks original ownership, sends expectedUid, reads persisted
  exclusions/date/weekdays/assessment state, and retains immutable failed writes.
  Opening Home/performance does not publish device defaults.
- Advance retains the request ID, expected day, revision and expectedUid across
  retries. Existing guarded launch/advance tests cover account, exam, wipe and
  caller lifetime. Native and web retain their separate planner/read authority.
- Tasks 6/7: plan, day and week routes, Sunday week math, past completion facts,
  future lesson queries, early-read state, Free future invitation and history
  pagination are present. Today remains noninteractive on the plan summary.
  Week rows drill down; rest rows do not. Home week-strip taps and View full plan
  are wired. Unknown stored days no longer produce empty lesson rows in a week;
  the week uses the existing recoverable plan error.
- Task 8: measured local record combines W4e's web mock history without local
  web mock-result writes. The Wrapped extension slot remains available to W4g.
- Task 9: approved labels/identity lines, Deep Thinker evidence rule, native
  original-owner cache guard, Home rows and tendencies route are present.
  Pressure scale/drop segment, Stamina axes, extra-time-only loss coloring,
  profile check details and common profile height are implemented in the patch.
  Independent review found an omitted inline-quiz session in server insight
  aggregation; its correction and regression are recorded in server evidence.
- Task 10: old Progress presentation/providers and replaced Home widgets/tests
  are deleted. Recording inputs remain under Home. Retired Progress/dossier
  route redirects are removed. No application navigation pushes /progress or
  /paywall. The old Try Pro row on Settings Pro looped through the retired
  paywall redirect back into itself; that row is omitted pending W4f's purchase
  presentation, under the standing missing-contract rule. Manage/Restore remain.

Missing contracts, not new product choices:

- DP_Week/DP_WeekCustom Change needs W4f's Study days settings destination.
  This worktree has no such screen/route. The optional control remains omitted;
  no dead destination or new settings UI was invented.
- W4f owns the replacement Settings Pro purchase presentation; W4g owns the
  Wrapped record row. This family supplies their destination/extension seams.

### Preserved product decisions

1. HE_BackAfterBreak / G-b-9: the cited historical masthead has greeting hour
   bands but no Welcome back trigger. The existing current trigger and calm line
   remain unchanged pending Aedwon's decision.
2. DP_History / G-b-21: older stored change rows lack details needed for some
   exact board sentences. No historic date, exam, scope, or study-day detail is
   reconstructed from current settings. The existing omissions remain pending
   the approved fallback wording. This is not complete history-copy acceptance.
3. HE_NothingDue / HP_NoDate: an empty no-date day has no matching board that
   establishes covered-everything meaning. Current behavior remains unchanged.

### New regression observations

- Retired-route regression: expected no Progress/dossier routes; actual four
  retired redirects. After deletion, all three route-inventory tests passed.
- Retired paywall-loop regression: expected no Try Pro reentry control on its
  own destination; actual one control. After removing that obsolete row, all
  ten payment-management tests passed.
- Unknown-week regression: expected the recoverable plan error; actual none,
  because the screen rendered unknown days as empty lesson rows. The correction
  passed all three plan-screen tests.

The focused inherited client baseline ran through terminal relay request 11686,
exit 0. Its transport truncated the full output, so no recovered total is
claimed from that request. New RED/GREEN command logs are in /tmp/w4b-*-red.log
and /tmp/w4b-*-green.log for this session. Final durable local gate logs live in
build/w4b-completion/; summary results are appended below after completion.

### Review and fidelity limits

One read-only independent family reviewer inspected tracked and untracked source
in both worktrees. They confirmed the server inline-session parity defect and
reported no additional confirmed Important/Critical finding. The lead reproduced
and corrected that finding with an emulator test. The reviewer ran no tests or
source mutations. No second review is claimed.

No phone/live-staging or visual 1:1 acceptance is claimed. The known omitted
Change control and the pending History/Welcome back/no-date states above remain
explicit board gaps. The source charts and profile refinements do not establish
pixel/motion acceptance. Aedwon retains that check under WORKFLOW.md.


### Final navigation corrections and layout checks

A direct HP_ExamDay source check found the Today header's View full plan action
was omitted at the Home caller. The new warm-up regression expected that visible
action and found none. Wiring the existing callback to /plan passed 21 focused
Home/route tests. No warm-up membership or launch behavior changed.

A day opened from Home also showed Your plan as its return label. Its new
regression expected Home and found none. The day now retains its actual calling
page label: Home from the week strip, the actual week title when opened from a
week. All 9 focused plan-screen/page tests passed. Six additional layout checks
passed for future/past day and week rows in light/dark themes at 200% text,
including read state, actual past counts, future count suppression, study-day
navigation and inert rest rows. No app screenshots were captured.

The first complete Flutter run (relay11689) passed 4811 tests and failed three
obsolete redirect tests: Free dossier redirect, Pro dossier redirect and the old
Progress destination map. This was a recorded failed gate. The two dossier tests
were deleted with their removed route; Progress entries were removed from the
legacy redirect map. Route inventory continues to require those retired paths
to be absent. The subsequent focused 21-test Home/router run passed.

The same first run's static gates were clean:

```text
flutter analyze lib test tool
No issues found! (ran in 5.9s)
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1600 files (0 changed) in 1.67 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
```

The final rerun after the navigation corrections is relay11694. No production
source changes are made while that run is active. Its actual results follow.


### Files beyond the original screen-task table

- `lib/core/time/study_days.dart` and its test: inherited bounded-cost calendar
  correction required to finish the real roadmap coverage gate. See the prior
  exhaustive-weekday and long-preview evidence. Both worktrees match.
- `lib/core/ui/components/pantas_logo.dart` and the onboarding logo wrapper:
  inherited extraction of the existing exact logo paths so the plan milestone
  can reuse them in monochrome instead of drawing a near-duplicate.
- `lib/app/app.dart`: observes the existing feature-local delivery lifecycle on
  native and web. No core synchronization framework was added.
- Settings, onboarding and assessment call sites: necessary Part C explicit
  settings/assessment/scope publication entry points authorized by the lead
  brief and later C9/C10 rulings.
- Settings Pro and its payment test: removes its sole remaining retired-paywall
  push, which redirected back to the same Pro page. The replacement purchase
  presentation remains W4f-owned under the missing-contract rule.
- Route inventory/redirect tests: retire old Progress/dossier expectations with
  the corresponding routes. Other families' redirect coverage remains.

The latest shared-source comparison confirms byte identity for every Dart file
under metrics/signals and roadmap/domain across both worktrees. The server
compiled bridge check remains current. Final logs and per-file dirty-source
hashes are in each worktree's ignored build/w4b-completion directory. These logs
are verification evidence, not a commit or durable remote handoff.


### Native-asset test-runner race

Relay11694 completed with 4816 tests passed and 1 failed. The failed case was
`test/tool/content_seed_writer_test.dart`, seed_writer creates an openable content
database from fixture JSON. Its nested `dart run` exited 255 while dlopen loaded
`.dart_tool/lib/libsqlite3mc.dylib`: Mach-O __TEXT extended beyond the file's
current length 0x100000. This is an observed partial native-asset write, not a seed
assertion or roadmap failure. The first full run had passed this same case.

An isolated rerun of the unchanged seed-writer test file passed 2/2 in two seconds.
No source, dependency, fixture, protected package, or test expectation changed.
The final full suite is rerun with `flutter test --concurrency=1` (relay11695),
serializing test-file child build hooks. The original exact parallel command's
failed result remains recorded; it is not relabeled as a pass. The serialized
full suite's actual output and repeated static gates follow below.


The layout-test addition initially replaced the three pre-existing day-page tests.
All three original cases were recovered verbatim from HEAD and restored alongside
the six new cases. The serial full runner had not yet loaded that file when it
was restored. The restored file retains all nine cases, including the original future-question,
past-completion and rest-day assertions. Execution is confirmed only by the final
log below. No production source changed during the serial run. The final manifest includes the restored
file; the earlier 4816+1 run was not the final acceptance object.


### Final client gate output

Relay11695 exited 0 on the final source. The complete serial suite includes the
restored three original day-page cases and all six additional layout cases.

```text
flutter test --concurrency=1
🎉 4820 tests passed.

flutter analyze lib test tool
Analyzing 3 items...
No issues found! (ran in 4.0s)

dart format --output=none --set-exit-if-changed lib test tool
Formatted 1600 files (0 changed) in 1.52 seconds.

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK

git status --short
 M docs/superpowers/plans/new-design/evidence/W4b.md
 M lib/app/app.dart
 M lib/app/routes/home_routes.dart
 M lib/core/time/study_days.dart
 M lib/features/assessment/presentation/assessment_page.dart
 M lib/features/home/application/home_day_extras.dart
 M lib/features/home/application/home_today.dart
 M lib/features/home/application/how_you_work_provider.dart
 M lib/features/home/application/performance/topic_detail.dart
 M lib/features/home/application/record_provider.dart
 M lib/features/home/application/study_remote_providers.dart
 D lib/features/home/application/tendencies_provider.dart
 D lib/features/home/application/up_next_provider.dart
 M lib/features/home/application/web_study_seam.dart
 M lib/features/home/data/study_read_cache.dart
 M lib/features/home/data/study_snapshot_reader.dart
 M lib/features/home/domain/study_models.dart
 M lib/features/home/presentation/home_providers.dart
 M lib/features/home/presentation/home_tab.dart
 M lib/features/home/presentation/home_today_screen.dart
 M lib/features/home/presentation/performance_screen.dart
 M lib/features/home/presentation/plan_day_page.dart
 M lib/features/home/presentation/plan_page.dart
 M lib/features/home/presentation/widgets/home_masthead.dart
 M lib/features/home/presentation/widgets/home_performance_section.dart
 D lib/features/home/presentation/widgets/home_stats_band.dart
 D lib/features/home/presentation/widgets/practice_panel.dart
 D lib/features/home/presentation/widgets/tendencies_panel.dart
 D lib/features/home/presentation/widgets/tendency_card.dart
 D lib/features/home/presentation/widgets/up_next_panel.dart
 M lib/features/metrics/archetypes/archetype_catalog.dart
 M lib/features/metrics/archetypes/archetype_templates.dart
 M lib/features/metrics/data/user_metrics_archetype_repository.dart
 M lib/features/metrics/providers/current_archetype_provider.dart
 M lib/features/onboarding/presentation/onboarding_page.dart
 M lib/features/onboarding/presentation/onboarding_study_days_step.dart
 M lib/features/onboarding/presentation/onboarding_welcome_step.dart
 D lib/features/progress/application/pace_provider.dart
 D lib/features/progress/data/.gitkeep
 D lib/features/progress/domain/.gitkeep
 D lib/features/progress/presentation/.gitkeep
 D lib/features/progress/presentation/pages/how_you_work_page.dart
 D lib/features/progress/presentation/progress_page.dart
 D lib/features/progress/presentation/widgets/gap_comparison.dart
 D lib/features/progress/presentation/widgets/level_control.dart
 D lib/features/progress/presentation/widgets/performance_section.dart
 D lib/features/progress/presentation/widgets/subject_scope_sheet.dart
 D lib/features/progress/presentation/widgets/table_head.dart
 D lib/features/progress/presentation/widgets/why_you_miss_section.dart
 D lib/features/progress/presentation/widgets/your_pace_panel.dart
 M lib/features/roadmap/application/roadmap_providers.dart
 M lib/features/roadmap/domain/week_preview.dart
 M lib/features/settings/application/settings_providers.dart
 M lib/features/settings/presentation/pages/change_exam_page.dart
 M lib/features/settings/presentation/pages/pro_page.dart
 M lib/features/settings/presentation/pages/whats_included_page.dart
 M test/app/router_paths_preserved_test.dart
 M test/app/router_redirect_test.dart
 M test/core/time/study_days_test.dart
 M test/features/home/application/home_day_extras_test.dart
 M test/features/home/application/how_you_work_provider_test.dart
 M test/features/home/application/record_provider_test.dart
 M test/features/home/application/study_remote_providers_test.dart
 D test/features/home/application/tendencies_provider_test.dart
 D test/features/home/application/up_next_provider_test.dart
 M test/features/home/application/web_study_seam_test.dart
 M test/features/home/data/study_read_cache_test.dart
 M test/features/home/data/study_snapshot_reader_test.dart
 M test/features/home/presentation/home_tab_test.dart
 M test/features/home/presentation/home_today_screen_test.dart
 M test/features/home/presentation/performance_screen_test.dart
 M test/features/home/presentation/plan_day_page_test.dart
 M test/features/home/presentation/plan_page_test.dart
 D test/features/home/presentation/widgets/home_stats_band_test.dart
 D test/features/home/presentation/widgets/practice_panel_test.dart
 D test/features/home/presentation/widgets/tendencies_panel_test.dart
 D test/features/home/presentation/widgets/tendency_card_test.dart
 D test/features/home/presentation/widgets/up_next_panel_test.dart
 M test/features/metrics/archetypes/archetype_resolver_test.dart
 M test/features/metrics/archetypes/archetype_templates_test.dart
 M test/features/metrics/providers/current_archetype_provider_test.dart
 D test/features/progress/application/pace_provider_test.dart
 D test/features/progress/mock_feeds_progress_test.dart
 D test/features/progress/presentation/pages/how_you_work_page_test.dart
 D test/features/progress/presentation/progress_page_test.dart
 D test/features/progress/presentation/widgets/accuracy_line_test.dart
 D test/features/progress/presentation/widgets/gap_comparison_test.dart
 D test/features/progress/presentation/widgets/level_control_test.dart
 D test/features/progress/presentation/widgets/performance_section_test.dart
 D test/features/progress/presentation/widgets/subject_scope_test.dart
 D test/features/progress/presentation/widgets/table_head_test.dart
 D test/features/progress/presentation/widgets/why_you_miss_section_test.dart
 D test/features/progress/presentation/widgets/your_pace_panel_test.dart
 M test/features/settings/application/settings_actions_test.dart
 M test/features/settings/presentation/pro_page_payments_test.dart
 D test/tool/progress_boundary_test.dart
?? lib/core/ui/components/pantas_logo.dart
?? lib/features/home/application/plan_data.dart
?? lib/features/home/application/plan_provider.dart
?? lib/features/home/application/server_tendencies.dart
?? lib/features/home/application/server_today.dart
?? lib/features/home/application/study_delivery.dart
?? lib/features/home/data/plan_history_reader.dart
?? lib/features/home/data/study_observations.dart
?? lib/features/home/data/study_writes.dart
?? lib/features/home/presentation/plan_screen.dart
?? lib/features/home/presentation/record_screen.dart
?? lib/features/home/presentation/tendencies_page.dart
?? lib/features/home/presentation/tendencies_screen.dart
?? test/features/home/application/plan_data_test.dart
?? test/features/home/application/record_server_history_test.dart
?? test/features/home/application/server_tendencies_test.dart
?? test/features/home/application/server_today_test.dart
?? test/features/home/application/study_coverage_test.dart
?? test/features/home/data/plan_history_reader_test.dart
?? test/features/home/data/study_observations_test.dart
?? test/features/home/data/study_writes_test.dart
?? test/features/home/presentation/plan_screen_test.dart
?? test/features/home/presentation/record_screen_test.dart
?? test/features/home/presentation/tendencies_page_test.dart
?? test/features/home/presentation/widgets/accuracy_line_test.dart
?? test/features/metrics/archetypes/archetype_identity_test.dart
?? test/features/roadmap/domain/week_preview_performance_test.dart
```

The exact unmodified `flutter test` invocation was run and its native-asset
copy failure is recorded above. The successful final full-suite command adds
only concurrency 1, so nested Dart build hooks do not overwrite a library another
test file is loading. No failing assertion was skipped, disabled or accepted as
a baseline exception. All 4820 cases ran.

The client source/test manifest contains 122 changed/deleted paths,
including untracked additions. Manifest SHA-256: `46b755a1c2ec618c2a9073a6a5ba947b441806fde81c62b28679e35a60f049fd`.
The machine-readable per-file hashes remain in build/w4b-completion/source-manifest.json.
No production source changed during or after the final serial gate. Evidence-only
edits occur afterwards. `git diff --check` is clean. Client status has 123 paths;
server status has 19. Both HEADs and branches remain as assigned; nothing is saved
to Git history or uploaded as application source.
