# T7 credit repair verification

Policy: origin/main 9151e29dc3ad2043a99b4dc2b0559591a65cc8cb, read without fetching.
The dispatch named 99b761579; the local remote reference has advanced.
Code HEAD: 630f8270c7091ac84b195db461cbebbb820a8d48. Pre-record dirty patch SHA-256, tracked diff plus untracked file names and bytes: c5f16079b1d8c35265deb8fbb2ea3f9ef64d2ed8618304d585a049b05502c304.
No staging, commit, UI change, dependency addition, or schema change. Content schemaVersion remains 11.

## Repairs

All four supplied findings addressed. The missing-minutes JSON catalog regression first failed
with `ParseException(catalogLesson.estimatedMinutes: expected int)`, then passed.
Diagnosis uses the shared credit fixture at its input boundary. Before the fix: tests 8,
pass 3, fail 5. After the fix: tests 8, pass 8, fail 0.
The layering check first reported one core-to-feature violation, and now reports OK.
Both named format failures were reproduced and corrected. Analyzer comma and directive findings
were corrected too.

The feature's pure `lessonCredit` entry delegates to a shared core implementation.
The new core file is necessary to remove the forbidden import without duplicating the rule.
Catalog parsing and diagnosis source/tests are additional files authorized by the findings.
This verification record is also outside the original task file list.

## Reader audit

Read-state/count consumers use LessonProgressRepository: storage provider read/count/hasAny;
lesson reader and study-map providers; practice picker; quiz providers; Home plan, record,
performance topic detail, today questions, install offer; roadmap inputs; coverage breadth
and read-then-quiz signals. The study-map builder also accepts raw family metadata and resolves it.
Roadmap domain queues, day selection, mastery and topic order consume those resolved inputs.
Record's activity dates, observation upload, sync mapping/bootstrap, local reset/wipe and sample
seeding retain stored observations because they represent actual events or persistence, not
inferred lesson completion. They must never write derived reads.

## Verification

- `flutter test --no-test-assets --concurrency=1` on all ten touched/added Dart test files: `00:33 +158: All tests passed!`
- Final helper/repository rerun after extracting the shared helper: `00:00 +19: All tests passed!`
- `flutter analyze lib test tool tools`: `No issues found! (ran in 16.0s)`
- `dart run tool/check_layering.dart`: `check_layering: OK`
- `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`
- `dart run tool/checks/run_checks.dart`: exit 0, all 12 registered checks OK.
- `dart format --output=none --set-exit-if-changed lib test tool tools`: exit 1,
  `Formatted 2392 files (2 changed) in 3.48 seconds.` Only untouched
  `tools/lesson_author/illustration_preview_renderer.dart` and
  `tools/lesson_author/render_illustration_previews_test.dart` need formatting. Left unchanged
  because they are outside this assignment. All repaired files pass formatting: `Formatted 8 files (0 changed) in 0.02 seconds.`
- `npm run build`: exit 0. `npm test`: unit tests 659, pass 659, fail 0;
  emulator tests 804, pass 804, fail 0. The emulator script exited successfully (code 0).
  Firebase CLI then exited 2 because its update check could not write the local ~/.config store.

The first concurrent Dart run encountered native dylib signing contention in an exporter subprocess.
The complete serial rerun passed. No unrelated behavioral test failure established.
Earlier implementation's test-first chronology cannot be recovered from its diff.
No device, visual, hosted CI, live content upload, or protected package rebuild was performed.

## Uncommitted candidate files

Includes the inherited T7 implementation and this run's repairs:

```text
 M functions/src/_examContent.ts
 M functions/src/customTracks.ts
 M functions/src/roadmap.ts
 M functions/src/sessionDiagnosis.ts
 M functions/src/studyInsights.ts
 M functions/src/studyObservations.ts
 M functions/test/compatibility-roadmap.test.mjs
 M functions/test/content-upload.test.mjs
 M functions/test/study-roadmap.emulator.mjs
 M lib/core/content/remote/content_catalog.dart
 M lib/core/content/sanity/parsers/lesson_parser.dart
 M lib/core/storage/data/repos/content_repository.dart
 M lib/core/storage/data/repos/lesson_progress_repository.dart
 M lib/features/home/application/performance/topic_detail.dart
 M lib/features/home/application/plan_provider.dart
 M lib/features/home/application/record_provider.dart
 M lib/features/lesson/domain/use_cases/build_study_map.dart
 M lib/features/metrics/signals/coverage_breadth_signal.dart
 M lib/features/metrics/signals/read_then_quiz_signal.dart
 M lib/features/quiz/application/quiz_providers.dart
 M lib/features/roadmap/application/roadmap_inputs_reader.dart
 M test/core/content/remote/content_catalog_test.dart
 M test/core/storage/data/repos/lesson_progress_repository_test.dart
 M test/features/home/application/record_provider_test.dart
 M test/features/lesson/domain/build_study_map_test.dart
 M test/features/roadmap/application/roadmap_controller_test.dart
 M test/tool/build_content_export_test.dart
 M test/tool/checks/lesson_checks_test.dart
 M test/tool/content/approve_test.dart
 M test/tool/content_seed_writer_test.dart
 M tool/checks/lesson_split_coverage_check.dart
 M tool/content/approve.dart
 M tools/build_content_export/build_content_export.dart
 M tools/build_dev_seed/build_dev_seed.dart
?? functions/src/_lessonCredit.ts
?? functions/test/lesson-credit.test.mjs
?? functions/test/session-diagnosis-credit.test.mjs
?? lib/core/storage/domain/lesson_credit.dart
?? lib/features/lesson/domain/lesson_credit.dart
?? test/features/lesson/domain/lesson_credit_test.dart
?? test/fixtures/content/lesson_credit_cases.json
```
