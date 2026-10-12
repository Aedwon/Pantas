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
Independent review and integration remain the lead's work. Task 2 and the rest of Task 3 are waiting on the recorded board/reader contract questions. Tasks 4 to 10 are not started. No claim of family completion, combined acceptance or visual acceptance.

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

## Open questions and findings

1. Task 2, `HP_ExamDay`: month text is 8px/700 at `rgba(255,255,255,0.8)` over `#0B7A68`. The composited color is about `#CEE4E1`, contrast 3.95:1. Required active text contrast is 4.5:1. Asked the lead for full-opacity existing `onAccent` or an explicit exception. No affected UI has been implemented.
2. Base full gates need unrelated index-layout test formatting/style fixes and the existing bookmark API migration. These are reported, not silently accepted or changed here.
3. Task 8 consumes W4e mock-history data. W4e is not integrated into the assigned base. Recheck the contract before dependent work; never build a local substitute.

4. Task 3, `HE_Resume`: the board draws a 24px partial lesson ring (stroke dash array `29.7 66.0`, about 45%) with `Resume` and `Resume Lesson`. At the assigned source, the reader computes offset/max extent only in a transient notifier; its controller saves the opened lesson ID and a binary read mark. It exposes no persisted measured reading fraction. W4c Task 1 plans offset persistence, but no shared fraction field/key is specified or integrated here. The lead must coordinate the measured fraction contract with W4c before Home draws this state. No sample 45% or guessed fraction was added.

## Handoff boundaries

- Task 1 is available for W4f's preferences consumer.
- The early Task 3 type is available for the lead to integrate before W4c Task 5. The whole Home checklist task remains incomplete.
- Remaining source changes await lead rulings and continuation of the exact plan. Do not treat these two commits as W4b acceptance.
- Full suite is still reserved for the end of the complete family, per dispatch. Only the named family task checks and the affected Quiz import check ran.
- No application screenshots, device/simulator work, deployment, push, merge, source revision change or signed asset regeneration occurred.

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
