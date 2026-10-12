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

Task 1 implemented and task checks complete. Independent review and integration remain the lead's work.
Tasks 2 to 10 are not complete. Task 3's reader contract will land separately as requested, as soon as its needed prior work is complete.

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

## Open questions and findings

1. Task 2, `HP_ExamDay`: month text is 8px/700 at `rgba(255,255,255,0.8)` over `#0B7A68`. The composited color is about `#CEE4E1`, contrast 3.95:1. Required active text contrast is 4.5:1. Asked the lead for full-opacity existing `onAccent` or an explicit exception. No affected UI has been implemented.
2. Base full gates need unrelated index-layout test formatting/style fixes and the existing bookmark API migration. These are reported, not silently accepted or changed here.
3. Task 8 consumes W4e mock-history data. W4e is not integrated into the assigned base. Recheck the contract before dependent work; never build a local substitute.
